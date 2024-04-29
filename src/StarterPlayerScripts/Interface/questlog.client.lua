local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RoQuest = require(ReplicatedStorage.RoQuest).Client

type Quest = RoQuest.Quest

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

local function destroyQuest(scrollingFrame: ScrollingFrame, questId: string)
    local frame: Frame? = scrollingFrame:FindFirstChild(questId)

    if frame then
        frame:Destroy()
    end
end

local function createQuest(scrollingFrame: ScrollingFrame, quest: Quest)
    local frame: Frame = scrollingFrame:FindFirstChild(quest.QuestId) or template:Clone()
    frame.Name = quest.QuestId
    frame.Title.Text = quest.Name
    frame.Description.Text = quest.Description
    frame.Buttons.Cancel.Visible = quest:GetQuestStatus() == RoQuest.QuestStatus.InProgress

    frame.Visible = true
    frame.Parent = scrollingFrame
end

local function populateScreen(scrollingFrame: ScrollingFrame, quests: {[string]: Quest})
    for _, child: Instance in scrollingFrame:GetChildren() do -- Remove quests no longer in use
        if not child:IsA("Frame") then
           continue
        end

        if not quests[child.Name] then
            child:Destroy()
        end
    end

    for _, quest: Quest in quests do
        createQuest(scrollingFrame, quest)
    end
end

local function setAllScreens()
    populateScreen(screens["InProgress"], RoQuest:GetInProgressQuests())
    populateScreen(screens["Available"], RoQuest:GetAvailableQuests())
    populateScreen(screens["Completed"], RoQuest:GetCompletedQuests())
    populateScreen(screens["Delivered"], RoQuest:GetDeliveredQuests())
    populateScreen(screens["Unavailable"], RoQuest:GetUnAvailableQuests())
end

RoQuest.OnStart():andThen(function()
    setupWindows() -- Caching our windows
    setupButtons() -- Caching our buttons
    setScreen("InProgress") -- Setting the initial active screen
    setAllScreens() -- Populating all screens

    RoQuest.OnUnAvailableQuestChanged:Connect(function()
        
    end)

    RoQuest.OnAvailableQuestChanged:Connect(function()
        
    end)
    RoQuest.OnCompletedQuestChanged:Connect(function()
        
    end)
    
    RoQuest.OnUnDeliveredQuestChanged:Connect(function()
        
    end)

    RoQuest.OnInProgressQuestChanged:Connect(function()
        
    end)
    
    RoQuest.OnPlayerDataChanged:Connect(setAllScreens) -- Hard reset our screens
end)