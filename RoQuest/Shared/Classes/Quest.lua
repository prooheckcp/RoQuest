--!strict
local assertProperties = require(script.Parent.Parent.Functions.assertProperties)
local QuestAcceptType = require(script.Parent.Parent.Enums.QuestAcceptType)
local QuestDeliverType = require(script.Parent.Parent.Enums.QuestDeliverType)
local QuestRepeatableType = require(script.Parent.Parent.Enums.QuestRepeatableType)
local QuestStatus = require(script.Parent.Parent.Enums.QuestStatus)
local Trove = require(script.Parent.Parent.Parent.Vendor.Trove)
local Signal = require(script.Parent.Parent.Parent.Vendor.Signal)
local QuestObjective = require(script.Parent.QuestObjective)
local QuestLifeCycle = require(script.Parent.QuestLifeCycle)
local QuestProgress = require(script.Parent.Parent.Structs.QuestProgress)
local QuestObjectiveProgress = require(script.Parent.Parent.Structs.QuestObjectiveProgress)

type Trove = Trove.Trove
type Signal = Signal.Signal
type QuestStatus = QuestStatus.QuestStatus
type QuestAcceptType = QuestAcceptType.QuestAcceptType
type QuestDeliverType = QuestDeliverType.QuestDeliverType
type QuestRepeatableType = QuestRepeatableType.QuestRepeatableType
type QuestObjective = QuestObjective.QuestObjective
type QuestLifeCycle = QuestLifeCycle.QuestLifeCycle
type QuestProgress = QuestProgress.QuestProgress
type QuestObjectiveProgress = QuestObjectiveProgress.QuestObjectiveProgress

local NO_OBJECTIVE: string = "There is no ObjectiveId %s in the Quest %s"

--[=[
    @class Quest
    @tag Class
]=]
local Quest = {}
Quest.__index = Quest
Quest.__type = "Quest"
Quest.OnQuestObjectiveChanged = newproxy() :: Signal
Quest.OnQuestCompleted = newproxy() :: Signal
Quest.OnQuestDelivered = newproxy() :: Signal
Quest.OnQuestCanceled = newproxy() :: Signal
Quest.Name = "" :: string
Quest.Description = "" :: string
Quest.QuestId = "" :: string
Quest.QuestAcceptType = QuestAcceptType.Automatic :: QuestAcceptType
Quest.QuestDeliverType = QuestDeliverType.Automatic :: QuestDeliverType
Quest.QuestRepeatableType = QuestRepeatableType.NonRepeatable :: QuestRepeatableType
Quest.QuestStart = 0 :: number
Quest.QuestEnd = 0 :: number
Quest.RequiredQuests = {} :: {string}
Quest.LifeCycles = {} :: {string}
Quest.QuestObjectives = {} :: {QuestObjective}
Quest._QuestObjectives = {} :: {[string]: QuestObjective}
Quest._QuestProgress = newproxy() :: QuestProgress
Quest._Trove = newproxy() :: Trove

--[=[
    Constructor for Quest

    ```lua
    local quest = Quest.new {
        ObjectiveId = "CollectApples",
        Name = "Collect Apples",
        Description = "Collect %s apples",
    }
    ```

    @param properties {[string]: any}

    @return Quest
]=]
function Quest.new(properties: {[string]: any}): Quest    
    local self: Quest = assertProperties(properties, Quest)
    self.OnQuestObjectiveChanged = Signal.new()
    self.OnQuestCompleted = Signal.new()
    self.OnQuestDelivered = Signal.new()
    self.OnQuestCanceled = Signal.new()
    self.RequiredQuests = {}
    self.LifeCycles = {}
    self.QuestObjectives = {}
    self:SetQuestProgress(QuestProgress {
        QuestObjectiveProgresses = {},
        QuestStatus = QuestStatus.NotStarted,
        CompletedCount = 0,
        FirstCompletedTick = 0,
        LastCompletedTick = 0,
    })
    self._Trove = Trove.new()
    self._Trove:Add(self.OnQuestCompleted)
    self._Trove:Add(self.OnQuestDelivered)
    self._Trove:Add(self.OnQuestCanceled)

    return self
end

function Quest:GetQuestStatus(): QuestStatus
    return self._QuestProgress.QuestStatus
end

function Quest:GetCompleteCount(): number
    return self._QuestProgress.CompletedCount
end

function Quest:GetFirstCompletedTick(): number
    return self._QuestProgress.FirstCompletedTick
end

function Quest:GetLastCompletedTick(): number
    return self._QuestProgress.LastCompletedTick
end

function Quest:AddObjective(objectiveId: string, amount: number): ()
    return self:SetObjective(objectiveId, self:GetObjective(objectiveId) + amount)
end

function Quest:RemoveObjective(objectiveId: string, amount: number): ()
    return self:SetObjective(objectiveId, self:GetObjective(objectiveId) - amount)
end

function Quest:SetObjective(objectiveId: string, newAmount: number): ()
    local questObjective: QuestObjective? = self._QuestObjectives[objectiveId]

    if not questObjective then
        warn(string.format(NO_OBJECTIVE, objectiveId, self.Name))
    end

    if questObjective:Set(newAmount) then
        self.OnQuestObjectiveChanged:Fire(objectiveId, newAmount)
    end
end

function Quest:GetObjective(objectiveId: number): number
    local questObjective: QuestObjectiveProgress? = self:_GetObjectiveProgress(objectiveId)

    if not questObjective then
        return 0
    end
    
    return questObjective.CurrentProgress or 0
end

function Quest:Complete(): ()
    if self:GetQuestStatus() ~= QuestStatus.InProgress then return end

    self:_GetQuestProgress().QuestStatus = QuestStatus.Completed
    self.OnQuestCompleted:Fire()

    if self.QuestDeliverType == QuestDeliverType.Automatic then
        self:Deliver()
    end
end

function Quest:Deliver(): ()
    if self:GetQuestStatus() ~= QuestStatus.Completed then return end

    self:_GetQuestProgress().QuestStatus = QuestStatus.Delivered
    self.OnQuestDelivered:Fire()
end

function Quest:SetQuestProgress(newQuestProgress: QuestProgress): ()
    for _, questObjective: QuestObjective in self._QuestObjectives do
        questObjective:Destroy()
    end
    self._QuestObjectives = {}

    for _, questObjective: QuestObjective in self.QuestObjectives do
        local objectiveId: string = questObjective.ObjectiveInfo.ObjectiveId
        local questObjectiveProgress: QuestObjectiveProgress? = newQuestProgress.QuestObjectiveProgresses[objectiveId]

        if not questObjectiveProgress then
            questObjectiveProgress = QuestObjectiveProgress {
                CurrentProgress = 0,
                Completed = false,
            }
        end

        newQuestProgress.QuestObjectiveProgresses[objectiveId] = questObjectiveProgress

        local newQuestObjective: QuestObjective = QuestObjective.new()
        newQuestObjective.ObjectiveInfo = questObjective.ObjectiveInfo
        newQuestObjective.TargetProgress = questObjective.TargetProgress
        newQuestObjective._QuestObjectiveProgress = questObjectiveProgress

        newQuestObjective.Completed:Connect(function()
            self:_CheckProgress()
        end)

        self._QuestObjectives[objectiveId] = newQuestObjective
    end

    self._QuestProgress = newQuestProgress
end

function Quest:Destroy()
    self._Trove:Destroy()
end

function Quest:_GetObjectiveProgress(objectiveId: string): QuestObjectiveProgress?
    local questObjective: QuestObjectiveProgress? = self._QuestProgress.QuestObjectiveProgresses[objectiveId]

    if not questObjective then
        warn(string.format(NO_OBJECTIVE, objectiveId, self.Name))
    end

    return questObjective
end

function Quest:_GetQuestProgress(): QuestProgress
    return self._QuestProgress
end

function Quest:_CheckProgress(): ()
    if self:GetQuestStatus() ~= QuestStatus.InProgress then return end
    
    for _, questObjective: QuestObjective in self._QuestObjectives do
        if not questObjective:IsCompleted() then
            return
        end
    end

    self:Complete()
end

export type Quest = typeof(Quest)

return Quest