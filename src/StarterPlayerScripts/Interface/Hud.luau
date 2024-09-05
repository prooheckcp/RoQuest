--!strict
local Players = game:GetService("Players")

local localPlayer: Player = Players.LocalPlayer
local playerGui: PlayerGui = localPlayer:WaitForChild("PlayerGui")
local questLog: ScreenGui = playerGui:WaitForChild("QuestLog")
local prompts: ScreenGui = playerGui:WaitForChild("Prompts")
local hud: ScreenGui = playerGui:WaitForChild("HUD")

local screens = {
    QuestLog = questLog.Container,
    QuestPrompt = prompts.QuestPrompt,
}

local Hud = {}
Hud.currentScreen = ""

function Hud:DisableScreen(screenName: string)
    if not screens[screenName] then
        return
    end
    
    screens[screenName].Visible = false
    self.currentScreen = ""
end

function Hud:EnableScreen(screenName: string)
    local currentScreen = self.currentScreen
    self:DisableScreen(self.currentScreen)

    if screenName == currentScreen then
        return
    end

    screens[screenName].Visible = true
    self.currentScreen = screenName
end

function Hud:Init()
    for _, instance: Instance in hud.Container:GetChildren() do
        if not instance:IsA("ImageButton") then
            continue
        end

        (instance :: ImageButton).Activated:Connect(function()
            self:EnableScreen(instance.Name)
        end)   
    end
end


return Hud