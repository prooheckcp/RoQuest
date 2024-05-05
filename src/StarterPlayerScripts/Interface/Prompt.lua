--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Client
local Red = require(ReplicatedStorage.RoQuest.Vendor.Red).Client
local Hud = require(script.Parent.Hud)

type Quest = RoQuest.Quest
type QuestObjective = RoQuest.QuestObjective
type QuestStatus = RoQuest.QuestStatus

local localPlayer: Player = Players.LocalPlayer
local playerGui: PlayerGui = localPlayer:WaitForChild("PlayerGui")
local prompts: ScreenGui = playerGui:WaitForChild("Prompts")
local questPrompt: Frame = prompts.QuestPrompt
local objectivesFrame: Frame = questPrompt.Objectives
local objectiveTemplate: TextLabel = objectivesFrame.Template:Clone()
local buttons: Frame = questPrompt.Buttons
local QuestStatus = RoQuest.QuestStatus

objectivesFrame.Template:Destroy()

local Prompt = {}
Prompt._CurrentQuestId = ""

function Prompt:SetQuest(questId: string)
    local staticQuest: Quest? = RoQuest:GetStaticQuest(questId)

    if not staticQuest then
        return
    end

    questPrompt.Title.Text = staticQuest.Name
    questPrompt.Description.Description.Text = staticQuest.Description

    for _, child: Instance in objectivesFrame:GetChildren() do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    for _, questObjective: QuestObjective in staticQuest:GetQuestObjectives() do
        local newTemplate: TextLabel = objectiveTemplate:Clone()
        newTemplate.Text = string.format(questObjective:GetDescription(), "0", questObjective:GetTargetProgress())
        newTemplate.Parent = objectivesFrame
    end

    local questStatus: QuestStatus = staticQuest:GetQuestStatus()

    buttons.Accept.Visible = questStatus == QuestStatus.Available
    buttons.Deliver.Visible = 
    self._CurrentQuestId = questId
end

function Prompt:Init()
    local Net = Red "QuestManager"

    buttons.Accept.Activated:Connect(function()
        Net:Fire("AcceptQuest", self._CurrentQuestId)
        Hud:DisableScreen("QuestPrompt")
    end)

    buttons.Decline.Activated:Connect(function()
        Hud:DisableScreen("QuestPrompt")
    end)

    buttons.Deliver.Activated:Connect(function()
        Net:Fire("DeliverQuest", self._CurrentQuestId)
        Hud:DisableScreen("QuestPrompt")
    end)
end

return Prompt