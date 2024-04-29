local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Client

type Quest = RoQuest.Quest
type QuestObjective = RoQuest.QuestObjective

local QuestStatus = RoQuest.QuestStatus

local localPlayer: Player = Players.LocalPlayer
local playerGui: PlayerGui = localPlayer:WaitForChild("PlayerGui")
local scrollingFrame: ScrollingFrame = playerGui:WaitForChild("Quests"):WaitForChild("Main"):WaitForChild("ScrollingFrame")
local template: Frame = scrollingFrame:WaitForChild("Template")
local clone = template:Clone()
template:Destroy()
template = clone

local function updateObjective(quest: Quest, objectiveId: string, newValue: number)
    local existingFrame: Frame? = scrollingFrame:FindFirstChild(quest.QuestId)

    if not existingFrame then
        return
    end

    local objectivesWindow: Frame = existingFrame.TextContainer.Objectives
    local objectiveText: TextLabel? = objectivesWindow:FindFirstChild(objectiveId)

    if not objectiveText then
        return
    end

    local questObjective: QuestObjective = quest:GetQuestObjective(objectiveId)

    objectiveText.Text = string.format(questObjective:GetDescription(), newValue, questObjective:GetTargetProgress())
end

local function updateQuestFrame(quest: Quest, frame: Frame)
    local textContainer: Frame = frame:WaitForChild("TextContainer")

    print("quest status: ", quest:GetQuestStatus())
    if quest:GetQuestStatus() == QuestStatus.Completed then
        textContainer.Description.Text = "Read to deliver!"
    elseif quest:GetQuestStatus() == QuestStatus.Delivered then
        frame:Destroy()
    else
        textContainer.Title.Text = quest.Name
        textContainer.Description.Text = quest.Description
    end
end

local function updateInterface()
    local quests: {[string]: Quest} = RoQuest:GetQuests()

    for _, instance: Instance in scrollingFrame:GetChildren() do -- Delete quests that dont exit
        if instance:IsA("Frame") and not quests[instance.Name] then
            instance:Destroy()
        end
    end

    for questId: string, quest: Quest in quests do
        local existingFrame: Frame = scrollingFrame:FindFirstChild(questId)

        if existingFrame then
            updateQuestFrame(quest, existingFrame)
            continue -- Quest already exists
        end

        local newTemplate: Frame = template:Clone()
        newTemplate.Name = questId
        local textContainer: Frame = newTemplate:WaitForChild("TextContainer")
        textContainer.Title.Text = quest.Name
        textContainer.Description.Text = quest.Description
        local objectives: Frame = textContainer:WaitForChild("Objectives")

        for _, questObjective: QuestObjective in quest:GetQuestObjectives() do
            local objectiveTemplate: TextLabel = textContainer.Description:Clone()
            objectiveTemplate.Name = questObjective:GetObjectiveId()
            objectiveTemplate.TextSize = 14
            objectiveTemplate.Text = string.format(questObjective:GetDescription(), questObjective:Get(), questObjective:GetTargetProgress())
            objectiveTemplate.Parent = objectives
        end

        newTemplate.Parent = scrollingFrame
        updateQuestFrame(quest, newTemplate)
    end
end

RoQuest.OnStart():andThen(function()
    RoQuest.OnPlayerDataChanged:Connect(updateInterface)
    RoQuest.OnQuestCompleted:Connect(updateInterface)
    RoQuest.OnQuestDelivered:Connect(updateInterface)
    --RoQuest.OnQuestCancelled:Connect(updateInterface)

    RoQuest.OnQuestObjectiveChanged:Connect(function(questId: string, objectiveId: string, newValue: number)
        updateObjective(RoQuest:GetQuest(questId), objectiveId, newValue)
    end)

    updateInterface()
end)