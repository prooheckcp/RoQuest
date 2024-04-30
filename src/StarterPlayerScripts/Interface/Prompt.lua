--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Client
local Hud = require(script.Parent.Hud)

type Quest = RoQuest.Quest
type QuestObjective = RoQuest.QuestObjective

local localPlayer: Player = Players.LocalPlayer
local playerGui: PlayerGui = localPlayer:WaitForChild("PlayerGui")
local prompts: ScreenGui = playerGui:WaitForChild("Prompts")
local questPrompt: Frame = prompts.QuestPrompt
local objectivesFrame: Frame = questPrompt.Objectives
local objectiveTemplate: TextLabel = objectivesFrame.Template:Clone()
local buttons: Frame = questPrompt.Buttons

objectivesFrame.Template:Destroy()

local Prompt = {}

function Prompt:SetQuest(questId: string)
    local quest: Quest? = RoQuest:GetStaticQuest(questId)

    if not quest then
        return
    end

    questPrompt.Title.Text = quest.Name
    questPrompt.Description.Description.Text = quest.Description

    for _, child: Instance in objectivesFrame:GetChildren() do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    for _, questObjective: QuestObjective in quest:GetQuestObjectives() do
        local newTemplate: TextLabel = objectiveTemplate:Clone()
        newTemplate.Text = string.format(questObjective:GetDescription(), "0", questObjective:GetTargetProgress())
        newTemplate.Parent = objectivesFrame
    end
end

function Prompt:Init() 
    buttons.Accept.Activated:Connect(function()
        print("Activate!")
    end)

    buttons.Decline.Activated:Connect(function()
        Hud:DisableScreen("QuestPrompt")
    end)
end

return Prompt