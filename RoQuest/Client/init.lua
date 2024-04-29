local Red = require(script.Parent.Vendor.Red).Client
local Signal = require(script.Parent.Vendor.Signal)
local QuestLifeCycle = require(script.Parent.Shared.Classes.QuestLifeCycle)
local Quest = require(script.Parent.Shared.Classes.Quest)
local ObjectiveInfo = require(script.Parent.Shared.Classes.ObjectiveInfo)
local WarningMessages = require(script.Parent.Shared.Data.WarningMessages)
local PlayerQuestData = require(script.Parent.Shared.Structs.PlayerQuestData)
local QuestProgress = require(script.Parent.Shared.Structs.QuestProgress)
local QuestObjectiveProgress = require(script.Parent.Shared.Structs.QuestObjectiveProgress)
local QuestObjective = require(script.Parent.Shared.Classes.QuestObjective)
local QuestRepeatableType = require(script.Parent.Shared.Enums.QuestRepeatableType)
local QuestDeliverType = require(script.Parent.Shared.Enums.QuestDeliverType)
local QuestAcceptType = require(script.Parent.Shared.Enums.QuestAcceptType)
local QuestStatus = require(script.Parent.Shared.Enums.QuestStatus)
local Promise = require(script.Parent.Vendor.Promise)

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
RoQuest.Quest = Quest
RoQuest.QuestLifeCycle = QuestLifeCycle
RoQuest.ObjectiveInfo = ObjectiveInfo
RoQuest.QuestAcceptType = QuestAcceptType
RoQuest.QuestDeliverType = QuestDeliverType
RoQuest.QuestRepeatableType = QuestRepeatableType
RoQuest.QuestStatus = QuestStatus
RoQuest._Initiated = false :: boolean
RoQuest._StaticQuestLifeCycles = {} :: {[string]: QuestLifeCycle}
RoQuest._StaticQuests = {} :: {[string]: Quest}
RoQuest._Quests = {} :: {[string]: Quest}
RoQuest._AvailableQuests = {} :: {[string]: true}
RoQuest._UnavailableQuests = {} :: {[string]: true}
RoQuest._PlayerQuestData = nil :: PlayerQuestData

RoQuest.OnStart = function()
	return Promise.new(function(resolve)
		if RoQuest._Initiated then
			resolve()
			return
		end

		while not RoQuest._Initiated do
			task.wait()
		end

		resolve()
		return
	end)
end

function RoQuest:Init(lifeCycles: {QuestLifeCycle}?): ()
    if self._Initiated then
		warn(WarningMessages.RoQuestAlreadyInit)
		return
	end

    self:_LoadLifeCycles(lifeCycles or {})

	local net = Red "QuestNamespace"

	-- Need to change the way quests are loaded to allow for dynamic loading
	local quests: {[string]: any} = net:Call("GetQuests"):Await()
	self:_LoadQuests(quests)

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

	self:_OnPlayerDataChanged(net:Call("GetPlayerData"):Await())

	task.spawn(function()
		while not self._PlayerQuestData do
			task.wait()
		end

		self._Initiated = true		
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

function RoQuest:GetCompletedQuests(): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for _, quest: Quest in self:GetQuests() do
		if quest:GetQuestStatus() == QuestStatus.Completed then
			quests[quest.QuestId] = quest
		end
	end

	return quests
end

function RoQuest:GetDeliveredQuests(): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for _, quest: Quest in self:GetQuests() do
		if quest:GetQuestStatus() == QuestStatus.Delivered then
			quests[quest.QuestId] = quest
		end
	end

	return quests
end

function RoQuest:GetInProgressQuests(): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for _, quest: Quest in self:GetQuests() do
		if quest:GetQuestStatus() == QuestStatus.InProgress then
			quests[quest.QuestId] = quest
		end
	end

	return quests
end

function RoQuest:GetAvailableQuests(): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for questId: string in self._AvailableQuests do
		quests[questId] = self:GetStaticQuest(questId)
	end

	return quests
end

function RoQuest:GetUnAvailableQuests(): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for questId: string in self._UnavailableQuests do
		quests[questId] = self:GetStaticQuest(questId)
	end

	return quests
end

function RoQuest:_LoadQuests(questsData: {[string]: any}): ()
	for questId: string, properties in questsData do
		if properties.QuestObjectives then
			for index: number, questObjective in properties.QuestObjectives do
				properties.QuestObjectives[index] = setmetatable(questObjective, QuestObjective)
			end
		end
		self._StaticQuests[questId] = Quest.new(properties)
	end
end

function RoQuest:_OnPlayerDataChanged(playerQuestData: PlayerQuestData)
	self._PlayerQuestData = playerQuestData

	for questId: string, questProgress: QuestProgress in playerQuestData.InProgress do
		self:_GiveQuest(questId, questProgress)
	end

	for questId: string, questProgress: QuestProgress in playerQuestData.Completed do
		self:_GiveQuest(questId, questProgress)
	end

	for questId: string, questProgress: QuestProgress in playerQuestData.Delivered do
		self:_GiveQuest(questId, questProgress)
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
	self:_GiveQuest(questId)
	self.OnQuestStarted:Fire(questId)
end

function RoQuest:_OnQuestCompleted(questId: string): ()
	local quest: Quest? = self:GetQuest(questId)

	if not quest then
		return
	end

	quest:Complete()
end

function RoQuest:_OnQuestDelivered(questId: string): ()
	local quest: Quest? = self:GetQuest(questId)

	if not quest then
		return
	end

	quest:Deliver()
end

function RoQuest:_OnQuestCancelled(questId: string): ()
	local quest: Quest? = self:GetQuest(questId)

	if not quest or quest:GetQuestStatus() == QuestStatus.Delivered then
		return
	end

	quest.OnQuestCanceled:Fire()
	self._Quests[questId] = nil
	self._PlayerQuestData[quest:GetQuestStatus()][questId] = nil
	quest:Destroy()
	self.OnQuestCancelled:Fire(questId)
end

function RoQuest:_OnQuestAvailable(questId: string)
	self._AvailableQuests[questId] = true
end

function RoQuest:_GiveQuest(questId: string, questProgress: QuestProgress?): boolean
	if self:GetQuest(questId) then
		return false
	end

	local questClone: Quest = table.clone(self:GetStaticQuest(questId))
	local questObjectiveProgresses: {[string]: QuestObjectiveProgress} = {}

	questClone.OnQuestCompleted:Connect(function()
		self.OnQuestCompleted:Fire(questId)
		self:_QuestCompleted(questId)
	end)

	questClone.OnQuestDelivered:Connect(function()
		self.OnQuestDelivered:Fire(questId)
		self:_QuestDelivered(questId)
	end)

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

	self._AvailableQuests[questId] = nil
	self._Quests[questId] = questClone
	self._PlayerQuestData.InProgress[questId] = questClone:_GetQuestProgress()

	return true
end

function RoQuest:_QuestCompleted(questId: string): ()
	local quest: Quest? = self:GetQuest(questId)

	if not quest then
		return
	end

	self._PlayerQuestData.InProgress[questId] = nil
	self._PlayerQuestData.Completed[questId] = quest:_GetQuestProgress()
end

function RoQuest:_QuestDelivered(questId: string): ()
	local quest: Quest? = self:GetQuest(questId)

	if not quest then
		return
	end

	self._PlayerQuestData.Completed[questId] = nil
	self._PlayerQuestData.Delivered[questId] = quest:_GetQuestProgress()
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