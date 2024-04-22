--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Signal = require(script.Parent.Vendor.Signal)
local Red = require(script.Parent.Vendor.Red)
local WarningMessages = require(script.Parent.Shared.Data.WarningMessages)
local warn = require(script.Parent.Shared.Functions.warn)
local Quest = require(script.Parent.Shared.Classes.Quest)
local QuestLifeCycle = require(script.Parent.Shared.Classes.QuestLifeCycle)
local ObjectiveInfo = require(script.Parent.Shared.Classes.ObjectiveInfo)
local QuestStatus = require(script.Parent.Shared.Enums.QuestStatus)
local QuestRepeatableType = require(script.Parent.Shared.Enums.QuestRepeatableType)
local QuestDeliverType = require(script.Parent.Shared.Enums.QuestDeliverType)
local QuestAcceptType = require(script.Parent.Shared.Enums.QuestAcceptType)

type ObjectiveInfo = ObjectiveInfo.ObjectiveInfo
type QuestAcceptType = QuestAcceptType.QuestAcceptType
type QuestDeliverType = QuestDeliverType.QuestDeliverType
type QuestStatus = QuestStatus.QuestStatus
type QuestRepeatableType = QuestRepeatableType.QuestRepeatableType
type Quest = Quest.Quest
type QuestLifeCycle = QuestLifeCycle.QuestLifeCycle

-- We want to give enough time for developers to get and save their player data
local DATA_RELEASE_DELAY: number = 5

local RoQuest = {}
RoQuest.OnQuestObjectiveChanged = Signal.new()
RoQuest.OnQuestStarted = Signal.new()
RoQuest.OnQuestCompleted = Signal.new()
RoQuest.OnQuestDelivered = Signal.new()
RoQuest.OnQuestCancelled = Signal.new()
RoQuest.OnQuestAvailable = Signal.new()
RoQuest.Quest = Quest
RoQuest.QuestLifeCycle = QuestLifeCycle
RoQuest.ObjectiveInfo = ObjectiveInfo
RoQuest.QuestAcceptType = QuestAcceptType
RoQuest.QuestDeliverType = QuestDeliverType
RoQuest.QuestRepeatableType = QuestRepeatableType
RoQuest.QuestStatus = QuestStatus
RoQuest._Initiated = false :: boolean
RoQuest._StaticQuests = {} :: {[string]: Quest}
RoQuest._StaticQuestLifeCycles = {} :: {[string]: QuestLifeCycle}
RoQuest._AvailableQuests = {} :: {[string]: Quest}
RoQuest._Quests = {} :: {[Player]: {[string]: Quest}}
RoQuest._AvailableQuests = {} :: {[Player]: {[string]: true}}
RoQuest._UnavailableQuests = {} :: {[Player]: {[string]: true}}
RoQuest._InProgressQuests = {} :: {[Player]: {[string]: true}}
RoQuest._DeliveredQuests = {} :: {[Player]: {[string]: true}}


function RoQuest:Init(quests: {Quest}, lifeCycles: {QuestLifeCycle}?)
    if self._Initiated then
        warn(WarningMessages.RoQuestAlreadyInit)
        return
    end

    self._Initiated = true
    self:_LoadQuests(quests)
    if lifeCycles then
        self:_LoadLifeCycles(lifeCycles)
    end

    Players.PlayerAdded:Connect(function(player: Player)
        self:_PlayerAdded(player)
    end)

    Players.PlayerRemoving:Connect(function(player: Player)
        task.delay(DATA_RELEASE_DELAY, self._PlayerRemoving, self, player)
    end)

    for _, player: Player in Players:GetPlayers() do
        task.spawn(self._PlayerAdded, self, player)
    end
end

function RoQuest:LoadDirectory(directory: Instance): {Quest | LifeCycle}
    
end

function RoQuest:LoadDirectoryDeep(directory: Instance): {Quest | LifeCycle}
    
end

function RoQuest:GetStaticQuest(questId: string): Quest
    
end

function RoQuest:GetQuest(player: Player, questId: string): Quest
    
end

function RoQuest:SetPlayerData(player: Player, data: PlayerQuestData): ()
    
end

function RoQuest:GetPlayerData(player: Player): PlayerQuestData
    
end

function RoQuest:AddObjective(player: Player, objectiveId: string, amount: number): ()
    
end

function RoQuest:SetObjective(player: Player, objectiveId: string, amount: number): ()
    
end

function RoQuest:RemoveObjective(player: Player, objectiveId: string, amount: number): ()
    
end

function RoQuest:GiveQuest(player: Player, questId: string): boolean
    
end

function RoQuest:CompleteQuest(player: Player, questId: string): boolean
    
end

function RoQuest:CancelQuest(player: Player, questId: string): boolean
    
end

function RoQuest:CanGiveQuest(player: Player, questId: string): boolean
    
end

function RoQuest:_QuestBecameAvailable(questId: string): ()
    -- TO DO when quest time is available
end

function RoQuest:_LoadQuests(quests: {Quest}): ()
    
end

function RoQuest:_LoadLifeCycles(lifecycles: {QuestLifeCycle}): ()
    
end

function RoQuest:_LoadPlayerQuests(player: Player): ()
    
end

function RoQuest:_PlayerAdded(player: Player): ()
    
end

function RoQuest:_PlayerRemoving(player: Player): ()
    
end

return RoQuest