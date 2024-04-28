local Red = require(script.Parent.Vendor.Red).Client
local Signal = require(script.Parent.Vendor.Signal)
local QuestLifeCycle = require(script.Parent.Shared.Classes.QuestLifeCycle)
local Quest = require(script.Parent.Shared.Classes.Quest)
local WarningMessages = require(script.Parent.Shared.Data.WarningMessages)
local PlayerQuestData = require(script.Parent.Shared.Structs.PlayerQuestData)
local QuestProgress = require(script.Parent.Shared.Structs.QuestProgress)
local QuestObjectiveProgress = require(script.Parent.Shared.Structs.QuestObjectiveProgress)
local QuestObjective = require(script.Parent.Shared.Classes.QuestObjective)
local QuestStatus = require(script.Parent.Shared.Enums.QuestStatus)

export type QuestStatus = QuestStatus.QuestStatus
export type QuestObjective = QuestObjective.QuestObjective
export type QuestObjectiveProgress = QuestObjectiveProgress.QuestObjectiveProgress
export type Quest = Quest.Quest
export type QuestLifeCycle = QuestLifeCycle.QuestLifeCycle
export type PlayerQuestData = PlayerQuestData.PlayerQuestData
export type QuestProgress = QuestProgress.QuestProgress

local RoQuest = {}
RoQuest.OnPlayerDataChanged = Signal.new()
RoQuest.OnQuestObjectiveChanged = Signal.new()
RoQuest.OnQuestStarted = Signal.new()
RoQuest.OnQuestCompleted = Signal.new()
RoQuest.OnQuestDelivered = Signal.new()
RoQuest.OnQuestCancelled = Signal.new()
RoQuest.OnQuestAvailable = Signal.new()
RoQuest.QuestLifeCycle = QuestLifeCycle
RoQuest._Initiated = false :: boolean
RoQuest._StaticQuestLifeCycles = {} :: {[string]: QuestLifeCycle}
RoQuest._StaticQuests = {} :: {[string]: Quest}
RoQuest._Quests = {} :: {[string]: Quest}
RoQuest._PlayerQuestData = {} :: PlayerQuestData

function RoQuest:Init(lifeCycles: {QuestLifeCycle}?): ()
    if self._Initiated then
		warn(WarningMessages.RoQuestAlreadyInit)
		return
	end

    self._Initiated = true
    self:_LoadLifeCycles(lifeCycles or {})

	local net = Red "QuestNamespace"

	net:On("OnPlayerDataChanged", function(playerQuestData: PlayerQuestData)
		self:_OnPlayerDataChanged(playerQuestData)
	end)

	net:On("OnQuestObjectiveChanged", function(questId: string, objectiveId: string, newAmount: number)
		self:_OnQuestObjectiveChanged(questId, objectiveId, newAmount)
	end)

	net:On("OnQuestStarted", function(questId: string)
		self:_OnQuestStarted(questId)
	end)

	net:On("OnQuestCompleted", function(questId: string)
		self:_OnQuestCompleted(questId)
	end)

	net:On("OnQuestDelivered", function(questId: string)
		self:_OnQuestDelivered(questId)
	end)

	net:On("OnQuestCancelled", function(questId: string)
		self:_OnQuestCancelled(questId)
	end)

	net:On("OnQuestAvailable", function(questId: string)
		self:_OnQuestAvailable(questId)
	end)

	net:Call("GetPlayerData", function(playerQuestData: PlayerQuestData)
		self:_OnPlayerDataChanged(playerQuestData)
	end)

	-- Need to change the way quests are loaded to allow for dynamic loading
	net:Call("GetQuests"):Then(function(quests: {[string]: any})
		self:_LoadQuests(quests)
	end)
end

--[=[
	Gets the static data of a cached quest

	@param questId string

	@return Quest?
]=]
function RoQuest:GetStaticQuest(questId: string): Quest?
	local quest: Quest? = self._StaticQuests[questId]

	if not quest then
		warn(string.format(WarningMessages.NoQuestById, questId))
	end

	return quest
end

--[=[
	Gets the static data of all of the cached quests

	@return {[string]: Quest}
]=]
function RoQuest:GetStaticQuests(): {[string]: Quest}
	return self._StaticQuests
end

--[=[
	Gets a player quest object. It will return nil if the player has never started
	the quest!

	@param questId string

	@return Quest?
]=]
function RoQuest:GetQuest(questId: string): Quest?
	return self._Quests[questId]
end

function RoQuest:GetQuests(): {[string]: Quest}
	return self._Quests or {}
end

function RoQuest:_LoadQuests(questsData: {[string]: any}): ()
	for questId: string, properties in questsData do
		self._StaticQuests[questId] = Quest.new(properties)
	end
end

function RoQuest:_OnPlayerDataChanged(playerQuestData: PlayerQuestData)
	self._PlayerQuestData = playerQuestData

	for questId: string, questProgress: QuestProgress in playerQuestData.InProgress do
		self:_GiveQuest(questId, questProgress)
	end

	for questId: string, questProgress: QuestProgress in playerQuestData.Completed do
		self:_CompleteQuest(questId, questProgress)
	end

	for questId: string, questProgress: QuestProgress in playerQuestData.Delivered do
		self:_DeliverQuest(questId, questProgress)
	end

	self.OnPlayerDataChanged:Fire(playerQuestData)
end

function RoQuest:_OnQuestObjectiveChanged(questId: string, objectiveId: string, newAmount: number): ()
	if not self._PlayerQuestData then
		return
	end
	
	local quest: Quest? = self:GetQuest(questId)
	quest:SetObjective(objectiveId, newAmount)
end

function RoQuest:_OnQuestStarted(questId: string): ()
	if self:_GiveQuest(questId) then
		self.OnQuestStarted:Fire(questId)
	end
end

function RoQuest:_OnQuestCompleted(questId: string): ()
	if self:_CompleteQuest(questId) then
		self.OnQuestCompleted:Fire(questId)
	end
end

function RoQuest:_OnQuestDelivered(questId: string): ()
	if self:_DeliverQuest(questId) then
		self.OnQuestDelivered:Fire(questId)
	end
end

function RoQuest:_OnQuestCancelled(questId: string)
	
end

function RoQuest:_OnQuestAvailable(questId: string)
	
end

function RoQuest:_GiveQuest(questId: string, questProgress: QuestProgress?): boolean
	if self:GetQuest(questId) then
		return false
	end

	local questClone: Quest = table.clone(self:GetStaticQuest(questId))
	local questObjectiveProgresses: {[string]: QuestObjectiveProgress} = {}

	questClone.OnQuestObjectiveChanged:Connect(function(objectiveName: string, newValue: number)
		self.OnQuestObjectiveChanged:Fire(questId, objectiveName, newValue)
	end)

	for _, questObjective: QuestObjective in questClone.QuestObjectives do
		questObjectiveProgresses[questObjective.ObjectiveInfo.ObjectiveId] = table.clone(questObjective._QuestObjectiveProgress)
	end

	if questProgress then
		for objectiveId: string, questObjectiveProgress: QuestObjectiveProgress in questObjectiveProgresses do
			if not questProgress.QuestObjectiveProgresses[objectiveId] then
				questProgress.QuestObjectiveProgresses[objectiveId] = questObjectiveProgress
			end
		end
		questClone:_SetQuestProgress(questProgress)
	else
		questClone:_SetQuestProgress(QuestProgress {
			QuestObjectiveProgresses = questObjectiveProgresses,
			QuestStatus = QuestStatus.InProgress,
			CompletedCount = 0,
			FirstCompletedTick = -1,
			LastCompletedTick = -1,
		})
	end

	self._Quests[questId] = questClone
	self._PlayerQuestData.InProgress[questId] = questClone:_GetQuestProgress()

	return true
end

function RoQuest:_CompleteQuest(questId: string, questProgress: QuestProgress?): boolean
	if questProgress then
		return self:_GiveQuest(questId, questProgress)
	end


end

function RoQuest:_DeliverQuest(questId: string, questProgress: QuestProgress?): boolean
	if questProgress then
		return self:_GiveQuest(questId, questProgress)
	end
end

--[=[
	Loads all the lifecycles into the cache

	@private
	@param lifecycles {QuestLifeCycle}

	@return ()
]=]
function RoQuest:_LoadLifeCycles(lifecycles: {QuestLifeCycle}): ()
	for _, questLifeCycle: QuestLifeCycle in lifecycles do
		if questLifeCycle.__type ~= "QuestLifeCycle" then
			continue
		end

		if self._StaticQuestLifeCycles[questLifeCycle.Name] then
			error(string.format(WarningMessages.DuplicateLifeCycleName, questLifeCycle.Name))
		end

		self._StaticQuestLifeCycles[questLifeCycle.Name] = questLifeCycle
	end
end

return RoQuest