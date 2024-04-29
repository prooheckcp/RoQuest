local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RoQuest = require(ReplicatedStorage.RoQuest).Client

local DEFAULT_COLOR: Color3 = Color3.fromRGB(140, 140, 140)
local ACTIVE_COLOR: Color3 = Color3.fromRGB(255, 255, 127)

local localPlayer: Player = Players.LocalPlayer
local playerGui: PlayerGui = localPlayer:WaitForChild("PlayerGui")
local questLog: ScreenGui = playerGui:WaitForChild("QuestLog")
local template: Frame = questLog.Container.Unavailable.Template:Clone()
questLog.Container.Unavailable.Template:Destroy() -- Delete the template after we cached a clone

local screens: {[string]: ScrollingFrame} = {}
local buttons: {[string]: GuiButton} = {}
local currentScreen: string = ""

local function updateButtonColor()
    for buttonName: string, button: GuiButton in buttons do
        button.BackgroundColor3 = buttonName == currentScreen and ACTIVE_COLOR or DEFAULT_COLOR
    end
end

local function setScreen(name: string)
    if currentScreen == name then
        return
    end

    local currentScrollingFrame: ScrollingFrame? = screens[currentScreen]
    local newScrollingFrame: ScrollingFrame? = screens[name]

    if currentScrollingFrame then
        currentScrollingFrame.Visible = false
    end

    if newScrollingFrame then
        newScrollingFrame.Visible = true
    end

    currentScreen = name
    updateButtonColor()
end

local function setupButtons()
    for _, button: Instance in questLog.Container.Buttons:GetChildren() do
        if not button:IsA("GuiButton") then
            continue
        end

        (button :: GuiButton).Activated:Connect(function()
            setScreen(button.Name)
        end)

        buttons[button.Name] = button
    end
end

local function setupWindows()
    for _, child: Instance in questLog.Container:GetChildren() do
        if not child:IsA("ScrollingFrame") then
            continue
        end

        screens[child.Name] = child
    end
end



RoQuest.OnStart():andThen(function()
    setupWindows()
    setupButtons()
    setScreen("InProgress")

    RoQuest.OnQuestCompleted:Connect(function()
        
    end)
end)