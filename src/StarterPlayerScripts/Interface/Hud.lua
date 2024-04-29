--!strict
local Players = game:GetService("Players")

local localPlayer: Player = Players.LocalPlayer
local playerGui: PlayerGui = localPlayer:WaitForChild("PlayerGui")
local questLog: ScreenGui = playerGui:WaitForChild("QuestLog")
local hud: ScreenGui = playerGui:WaitForChild("HUD")

local screens = {
    QuestLog = questLog.Container,
}

local Hud = {}
Hud.currentScreen = ""

function Hud:DisableScreen(screenName: string)
    if not screens[screenName] then
        return
    end
    
    screens[screenName].Visible = false
end

function Hud:EnableScreen(screenName: string)
    self:DisableScreen(self.currentScreen)

    if screenName == self.currentScreen then
        self.currentScreen = ""
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