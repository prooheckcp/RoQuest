--!strict
local Players = game:GetService("Players")

local Signal = require(script.Parent.Vendor.Signal)
local Red = require(script.Parent.Vendor.Red)
local WarningMessages = require(script.Parent.Shared.Data.WarningMessages)
local warn = require(script.Parent.Shared.Functions.warn)
local Quest = require(script.Parent.Shared.Classes.Quest)
local QuestLifeCycle = require(script.Parent.Shared.Classes.QuestLifeCycle)
local ObjectiveInfo = require(script.Parent.Shared.Classes.ObjectiveInfo)
local QuestObjective = require(script.Parent.Shared.Classes.QuestObjective)
local QuestProgress = require(script.Parent.Shared.Structs.QuestProgress)
local QuestObjectiveProgress = require(script.Parent.Shared.Structs.QuestObjectiveProgress)
local QuestStatus = require(script.Parent.Shared.Enums.QuestStatus)
local QuestRepeatableType = require(script.Parent.Shared.Enums.QuestRepeatableType)
local QuestDeliverType = require(script.Parent.Shared.Enums.QuestDeliverType)
local QuestAcceptType = require(script.Parent.Shared.Enums.QuestAcceptType)
local PlayerQuestData = require(script.Parent.Shared.Structs.PlayerQuestData)
local networkQuestParser = require(script.Parent.Shared.Functions.networkQuestParser)
local Promise = require(script.Parent.Vendor.Promise)

export type QuestObjective = QuestObjective.QuestObjective
export type QuestObjectiveProgress = QuestObjectiveProgress.QuestObjectiveProgress
export type QuestAcceptType = QuestAcceptType.QuestAcceptType
export type QuestDeliverType = QuestDeliverType.QuestDeliverType
export type QuestStatus = QuestStatus.QuestStatus
export type QuestRepeatableType = QuestRepeatableType.QuestRepeatableType
export type ObjectiveInfo = ObjectiveInfo.ObjectiveInfo
export type Quest = Quest.Quest
export type QuestLifeCycle = QuestLifeCycle.QuestLifeCycle
export type PlayerQuestData = PlayerQuestData.PlayerQuestData
export type QuestProgress = QuestProgress.QuestProgress

-- We want to give enough time for developers to get and save their player data
local DATA_RELEASE_DELAY: number = 5
local LOAD_DIRECTORY_TYPES: {[string]: true} = {
	["Quest"] = true,
	["QuestLifeCycle"] = true,
}

--[=[
	@class RoQuest
]=]
local RoQuest = {}
RoQuest.OnPlayerDataChanged = Signal.new()
RoQuest.OnQuestObjectiveChanged = Signal.new()
RoQuest.OnQuestStarted = Signal.new() -- Event (player: Player, questId: string)
RoQuest.OnQuestCompleted = Signal.new() -- Event (player: Player, questId: string)
RoQuest.OnQuestDelivered = Signal.new() -- Event (player: Player, questId: string)
RoQuest.OnQuestCancelled = Signal.new() -- Event (player: Player, questId: string)
RoQuest.OnQuestAvailable = Signal.new() -- Event (player: Player, questId: string)
RoQuest.OnQuestUnavailable = Signal.new() -- Event (player: Player, questId: string)
RoQuest.Quest = Quest
RoQuest.QuestLifeCycle = QuestLifeCycle
RoQuest.ObjectiveInfo = ObjectiveInfo
RoQuest.QuestAcceptType = QuestAcceptType
RoQuest.QuestDeliverType = QuestDeliverType
RoQuest.QuestRepeatableType = QuestRepeatableType
RoQuest.QuestStatus = QuestStatus
RoQuest._Initiated = false :: boolean
RoQuest._StaticQuests = {} :: {[string]: Quest}
RoQuest._RequiredQuestPointer = {} :: {[string]: {[string]: true}}
RoQuest._StaticNetworkParse = {} :: {[string]: any}
RoQuest._StaticQuestLifeCycles = {} :: {[string]: QuestLifeCycle}
RoQuest._StaticAvailableQuests = {} :: {[string]: true}
RoQuest._StaticObjectiveReference = {} :: {[string]: {[string]: true}}
RoQuest._Quests = {} :: {[Player]: {[string]: Quest}}
RoQuest._PlayerQuestData = {} :: {[Player]: PlayerQuestData}
RoQuest._AvailableQuests = {} :: {[Player]: {[string]: true}}
RoQuest._UnavailableQuests = {} :: {[Player]: {[string]: true}}

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

--[=[
	:::info

	This function should only get called once in the server-side. It will initialize our quest system and start listening to player events

	:::

	Initiates our quest system and feeds it all the data about the quests and lifecycles

	@param quests {Quest}
	@param lifeCycles {QuestLifeCycle}?

	@return ()
]=]
function RoQuest:Init(quests: {Quest}, lifeCycles: {QuestLifeCycle}?): ()
	if self._Initiated then
		warn(WarningMessages.RoQuestAlreadyInit)
		return
	end

	self:_LoadQuests(quests)
	if lifeCycles then
		self:_LoadLifeCycles(lifeCycles)
	end

	local net = Red.Server("QuestNamespace", {
		"OnQuestObjectiveChanged",
		"OnQuestStarted",
		"OnQuestDelivered",
		"OnQuestCompleted",
		"OnQuestCancelled",
		"OnQuestAvailable",
		"OnQuestUnavailable",
		"OnPlayerDataChanged",
	})

	self.OnQuestObjectiveChanged:Connect(function(player: Player, questId: string, objectiveId: string, newAmount: number)
		net:Fire(player, "OnQuestObjectiveChanged", questId, objectiveId, newAmount)
	end)

	self.OnQuestStarted:Connect(function(player: Player, questId: string)
		net:Fire(player, "OnQuestStarted", questId)
	end)

	self.OnQuestCompleted:Connect(function(player: Player, questId: string)
		net:Fire(player, "OnQuestCompleted", questId)
	end)

	self.OnQuestDelivered:Connect(function(player: Player, questId: string)
		net:Fire(player, "OnQuestDelivered", questId)
	end)
	
	self.OnQuestCancelled:Connect(function(player: Player, questId: string)
		net:Fire(player, "OnQuestCancelled", questId)
	end)

	self.OnQuestAvailable:Connect(function(player: Player, questId: string)
		net:Fire(player, "OnQuestAvailable", questId)
	end)

	self.OnQuestUnavailable:Connect(function(player: Player, questId: string)
		net:Fire(player, "OnQuestUnavailable", questId)
	end)

	self.OnPlayerDataChanged:Connect(function(player: Player)
		net:Fire(player, "OnPlayerDataChanged", self:GetPlayerData(player))
	end)

	net:On("GetPlayerData", function(player: Player)
		return self:GetPlayerData(player)
	end)

	net:On("GetQuests", function(player: Player)
		while not self._PlayerQuestData[player] and player.Parent == Players do -- Wait for player to load
			task.wait()
		end

		return RoQuest._StaticNetworkParse
	end)

	Players.PlayerAdded:Connect(function(player: Player)
		self:_PlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		task.delay(DATA_RELEASE_DELAY, self._PlayerRemoving, self, player)
	end)

	for _, player: Player in Players:GetPlayers() do
		task.spawn(self._PlayerAdded, self, player)
	end

	self._Initiated = true
end

--[=[
	Loads all the quests and lifecycles right under the given director and returns them in an array

	@param directory {Instance}

	@return {Quest | QuestLifeCycle}
]=]
function RoQuest:LoadDirectory(directory: Instance): {Quest | QuestLifeCycle}
	return self:_LoadDirectory(directory:GetChildren())
end

--[=[
	Loads all the quests and lifecycles from the descendants of the directory and returns them in an array

	@param directory {Instance}

	@return {Quest | QuestLifeCycle}
]=]
function RoQuest:LoadDirectoryDeep(directory: Instance): {Quest | QuestLifeCycle}
	return self:_LoadDirectory(directory:GetDescendants())
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

	@param player Player
	@param questId string

	@return Quest?
]=]
function RoQuest:GetQuest(player: Player, questId: string): Quest?
	return self._Quests[player][questId]
end

function RoQuest:GetQuests(player: Player): {[string]: Quest}
	return self._Quests[player] or {}
end

function RoQuest:GetCompletedQuests(player: Player): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for questId: string in self:GetPlayerData(player).Completed do
		quests[questId] = self:GetQuest(player, questId)
	end

	return quests
end

function RoQuest:GetDeliveredQuests(player: Player): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for questId: string in self:GetPlayerData(player).Delivered do
		quests[questId] = self:GetQuest(player, questId)
	end

	return quests
end

function RoQuest:GetInProgressQuests(player: Player): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for questId: string in self:GetPlayerData(player).InProgress do
		quests[questId] = self:GetQuest(player, questId)
	end

	return quests
end

function RoQuest:GetAvailableQuests(player: Player): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for questId: string in self._AvailableQuests[player] do
		quests[questId] = self:GetStaticQuest(questId)
	end

	return quests
end

function RoQuest:GetUnAvailableQuests(player: Player): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for questId: string in self._UnavailableQuests[player] do
		quests[questId] = self:GetStaticQuest(questId)
	end

	return quests
end

--[=[
	
]=]
function RoQuest:SetPlayerData(player: Player, data: PlayerQuestData): ()
	self._PlayerQuestData[player] = data

	self:_LoadPlayerData(player)
end

--[=[
	
]=]
function RoQuest:GetPlayerData(player: Player): PlayerQuestData
	return self._PlayerQuestData[player] or PlayerQuestData {}
end

--[=[
	
]=]
function RoQuest:AddObjective(player: Player, objectiveId: string, amount: number): ()
	if not self._PlayerQuestData[player] then
		return
	end
	
	if not self._StaticObjectiveReference[objectiveId] then
		warn(string.format(WarningMessages.NoObjectiveId, objectiveId))
		return
	end

	for questId: string in self._StaticObjectiveReference[objectiveId] do
		local quest: Quest? = self:GetQuest(player, questId)

		if not quest or quest:GetQuestStatus() ~= QuestStatus.InProgress then
			continue
		end

		quest:AddObjective(objectiveId, amount)
	end
end

--[=[
	
]=]
function RoQuest:SetObjective(player: Player, objectiveId: string, amount: number): ()
	if not self._PlayerQuestData[player] then
		return
	end
	
	for questId: string in self._StaticObjectiveReference[objectiveId] do
		local quest: Quest? = self:GetQuest(player, questId)

		if not quest or quest:GetQuestStatus() ~= QuestStatus.InProgress then
			continue
		end

		quest:SetObjective(objectiveId, amount)
	end
end

--[=[
	
]=]
function RoQuest:RemoveObjective(player: Player, objectiveId: string, amount: number): ()
	if not self._PlayerQuestData[player] then
		return
	end
	
	for questId: string in self._StaticObjectiveReference[objectiveId] do
		local quest: Quest? = self:GetQuest(player, questId)

		if not quest or quest:GetQuestStatus() ~= QuestStatus.InProgress then
			continue
		end

		quest:RemoveObjective(objectiveId, amount)
	end
end

--[=[
	
]=]
function RoQuest:GiveQuest(player: Player, questId: string): boolean
	if not self:CanGiveQuest(player, questId) then
		return false		
	end

	if not self:_GiveQuest(player, questId) then
		return false
	end
	
	self.OnQuestStarted:Fire(player, questId)

	return true
end

--[=[
	
]=]
function RoQuest:CompleteQuest(player: Player, questId: string): boolean
	local quest: Quest? = self:GetQuest(player, questId)

	if not quest then
		return false
	end

	return quest:Complete()
end

function RoQuest:DeliverQuest(player: Player, questId: string)
	local quest: Quest? = self:GetQuest(player, questId)

	if not quest then
		return false
	end

	return quest:Deliver()
end

--[=[
	
]=]
function RoQuest:CancelQuest(player: Player, questId: string): boolean
	local quest: Quest? = self:GetQuest(player, questId)

	if not quest or quest:GetQuestStatus() == QuestStatus.Delivered then
		return false
	end

	quest.OnQuestCanceled:Fire()
	self._Quests[player][questId] = nil
	self._PlayerQuestData[player][quest:GetQuestStatus()][questId] = nil
	quest:Destroy()
	self.OnQuestCancelled:Fire(player, questId)
end

--[=[
	
]=]
function RoQuest:CanGiveQuest(player: Player, questId: string): boolean
	local quest: Quest? = self:GetStaticQuest(questId)

	if not quest then
		return false
	end

	if not self._StaticAvailableQuests[questId] then
		return false
	end

	for _, requiredQuestId: string in quest.RequiredQuests do
		if not self._PlayerQuestData[player].Delivered[requiredQuestId] then
			return false
		end
	end

	return self:GetQuest(player, questId) == nil
end

function RoQuest:_QuestCompleted(player: Player, questId: string): ()
	local quest: Quest? = self:GetQuest(player, questId)

	if not quest then
		return
	end

	self._PlayerQuestData[player].InProgress[questId] = nil
	self._PlayerQuestData[player].Completed[questId] = quest:_GetQuestProgress()
end

function RoQuest:_QuestDelivered(player: Player, questId: string): ()
	local quest: Quest? = self:GetQuest(player, questId)

	if not quest then
		return
	end

	self._PlayerQuestData[player].Completed[questId] = nil
	self._PlayerQuestData[player].Delivered[questId] = quest:_GetQuestProgress()

	if self._RequiredQuestPointer[questId] then
		for requiredQuestId: string in self._RequiredQuestPointer[questId] do
			self:_NewPlayerAvailableQuest(player, requiredQuestId)
		end
	end
end

--[=[
	Loads all the quests and lifecycles from the directory and returns them in an array

	@private
	@param instancesToFilter {Instance}

	@return {Quest | QuestLifeCycle}
]=]
function RoQuest:_LoadDirectory(instancesToFilter: {Instance}): {Quest | QuestLifeCycle}
	local array: {Quest | QuestLifeCycle} = {}

	for _, childInstance: Instance in instancesToFilter do
		if not childInstance:IsA("ModuleScript") then
			continue
		end

		local requiredObject: any = require(childInstance)

		if LOAD_DIRECTORY_TYPES[requiredObject.__type] then
			if #array > 0 and array[1].__type ~= requiredObject.__type then
				error(WarningMessages.LoadDirectoryMixedType)
			end

			array[#array+1] = requiredObject
		end
	end

	return array
end

--[=[
	
]=]
function RoQuest:_QuestBecameAvailable(questId: string): ()
	if self._StaticAvailableQuests[questId] then
		return false
	end

	self._StaticAvailableQuests[questId] = true -- Should give to players if possible

	for player: Player in self._Quests do
		self:_NewPlayerAvailableQuest(player, questId)
	end
end

function RoQuest:_QuestBecameUnavailable(questId: string)
	for player: Player, questData: {[string]: Quest} in self._Quests do
		if questData[questId] and questData[questId]:GetQuestStatus() ~= QuestStatus.Delivered then
			self:CancelQuest(player, questId)
		end
	end

	self._StaticAvailableQuests[questId] = nil

	for player: Player in self._Quests do
		self:_NewPlayerAvailableQuest(player, questId)
	end
end

function RoQuest:_GiveQuest(player: Player, questId: string, questProgress: QuestProgress?): boolean
	if self:GetQuest(player, questId) then
		return false
	end

	local questProperties = self._StaticNetworkParse[questId]
	local questClone: Quest = Quest.new(table.clone(questProperties))

	questClone.OnQuestCompleted:Connect(function()
		self.OnQuestCompleted:Fire(player, questId)
		self:_QuestCompleted(player, questId)
	end)

	questClone.OnQuestDelivered:Connect(function()
		self.OnQuestDelivered:Fire(player, questId)
		self:_QuestDelivered(player, questId)
	end)

	questClone.OnQuestObjectiveChanged:Connect(function(objectiveName: string, newValue: number)
		self.OnQuestObjectiveChanged:Fire(player, questId, objectiveName, newValue)
	end)

	local questObjectiveProgresses: {[string]: QuestObjectiveProgress} = {}

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

	self._AvailableQuests[player][questId] = nil
	self._Quests[player][questId] = questClone
	self._PlayerQuestData[player].InProgress[questId] = questClone:_GetQuestProgress()

	return true
end

--[=[
	Loads all the quests for the given player

	@private
	@param player Player

	@return ()
]=]
function RoQuest:_LoadPlayerData(player: Player): ()
	self._Quests[player] = {} -- Reset our player quest

	for _questStatus, questArray: {[string]: QuestProgress} in self:GetPlayerData(player) do
		for questId: string, questProgress: QuestProgress in questArray do
			self:_GiveQuest(player, questId, questProgress)
		end
	end

	for questId: string in self._StaticAvailableQuests do
		self:_NewPlayerAvailableQuest(player, questId)
	end

	self.OnPlayerDataChanged:Fire(player, self:GetPlayerData(player))
end

--[=[
	Checks if the player can accept the quest and if so, gives it to the player

	@private
	@param player Player
	@param questId string

	@return ()
]=]
function RoQuest:_NewPlayerAvailableQuest(player: Player, questId: string)
	local quest: Quest? = self:GetStaticQuest(questId)

	if not quest then
		return
	end

	if not self:CanGiveQuest(player, questId) then
		if not self:GetQuest(player, questId) then
			if not self._UnavailableQuests[player][questId] then
				self._UnavailableQuests[player][questId] = true
				self.OnQuestUnavailable:Fire(player, questId)
			end
		end
		return
	end

	if self._UnavailableQuests[player][questId] then
		self._UnavailableQuests[player][questId] = nil
	end

	if quest.QuestAcceptType == QuestAcceptType.Automatic then
		self:GiveQuest(player, questId)
	elseif not self._AvailableQuests[player][questId] then
		self._AvailableQuests[player][questId] = true
		self.OnQuestAvailable:Fire(player, questId)
	end
end

--[=[
	Loads all the quests into the cache

	@private
	@param quests {Quest}

	@return ()
]=]
function RoQuest:_LoadQuests(quests: {Quest}): ()
	for _, quest: Quest in quests do
		if quest.__type ~= "Quest" then
			continue
		end

		if self._StaticQuests[quest.QuestId] then
			error(string.format(WarningMessages.DuplicateQuestId, quest.QuestId))
		end

		self._StaticQuests[quest.QuestId] = quest
		self._StaticNetworkParse[quest.QuestId] = networkQuestParser(quest)

		local questStart: number = quest.QuestStart
		local questEnd: number = quest.QuestEnd
		local currentTime: number = os.time()

		for _, requiredQuest: string in quest.RequiredQuests do
			if not self._RequiredQuestPointer[requiredQuest] then
				self._RequiredQuestPointer[requiredQuest] = {}
			end

			self._RequiredQuestPointer[requiredQuest][quest.QuestId] = true
		end

		for objectiveId: string in quest._QuestObjectives do
			if not self._StaticObjectiveReference[objectiveId] then
				self._StaticObjectiveReference[objectiveId] = {}
			end

			self._StaticObjectiveReference[objectiveId][quest.QuestId] = true
		end

		if
			questStart <= currentTime and questEnd >= currentTime or
			questStart == questEnd
		then
			self:_QuestBecameAvailable(quest.QuestId)
			
			if questEnd > currentTime and questEnd > questStart then
				task.delay(questEnd - currentTime, self._QuestBecameUnavailable, self, quest.QuestId)
			end
		elseif currentTime < questStart then
			task.delay(questStart - currentTime, self._QuestBecameAvailable, self, quest.QuestId)
			task.delay(questEnd - currentTime, self._QuestBecameUnavailable, self, quest.QuestId)
		end
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

--[=[
	Called whenever the player joins the game and initiates the cache for the player

	@private
	@param player Player

	@return ()
]=]
function RoQuest:_PlayerAdded(player: Player): ()
	self._Quests[player] = {}
	self._AvailableQuests[player] = {}
	self._UnavailableQuests[player] = {}
	self._PlayerQuestData[player] = PlayerQuestData {}

	self:_LoadPlayerData(player)
end

--[=[
	Called 5 seconds after the player leaves the game. Used to clear the cache of the player

	@private
	@param player Player

	@return ()
]=]
function RoQuest:_PlayerRemoving(player: Player): ()
	self._Quests[player] = nil
	self._AvailableQuests[player] = nil
	self._UnavailableQuests[player] = nil
	self._PlayerQuestData[player] = nil
end

return RoQuest