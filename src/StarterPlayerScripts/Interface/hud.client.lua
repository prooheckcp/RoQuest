local Players = game:GetService("Players")

local localPlayer: Player = Players.LocalPlayer
local playerGui: PlayerGui = localPlayer:WaitForChild("PlayerGui")
local questLog: ScreenGui = playerGui:WaitForChild("QuestLog")
local hud: ScreenGui = playerGui:WaitForChild("HUD")

local screens = {
    QuestLog = questLog.Container,
}

local currentScreen: string = ""

local function disableScreen(screenName: string)
    if not screens[screenName] then
        return
    end
    
    screens[screenName].Visible = false
end

local function enableScreen(screenName: string)
    disableScreen(currentScreen)

    if screenName == currentScreen then
        currentScreen = ""
        return
    end

    screens[screenName].Visible = true
    currentScreen = screenName
end

for _, instance: Instance in hud.Container:GetChildren() do
    if not instance:IsA("ImageButton") then
        continue
    end

    (instance :: ImageButton).Activated:Connect(function()
        enableScreen(instance.Name)
    end)   
end
