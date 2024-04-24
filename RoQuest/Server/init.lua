--!strict
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
local PlayerQuestData = require(script.Parent.Shared.Structs.PlayerQuestData)

type ObjectiveInfo = ObjectiveInfo.ObjectiveInfo
type QuestAcceptType = QuestAcceptType.QuestAcceptType
type QuestDeliverType = QuestDeliverType.QuestDeliverType
type QuestStatus = QuestStatus.QuestStatus
type QuestRepeatableType = QuestRepeatableType.QuestRepeatableType
type Quest = Quest.Quest
type QuestLifeCycle = QuestLifeCycle.QuestLifeCycle
type PlayerQuestData = PlayerQuestData.PlayerQuestData

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
RoQuest._StaticAvailableQuests = {} :: {[string]: true}
RoQuest._StaticObjectiveReference = {} :: {[string]: {[string]: true}}
RoQuest._Quests = {} :: {[Player]: {[string]: Quest}}
RoQuest._PlayerQuestData = {} :: {[Player]: PlayerQuestData}
RoQuest._AvailableQuests = {} :: {[Player]: {[string]: true}}
RoQuest._UnavailableQuests = {} :: {[Player]: {[string]: true}}
RoQuest._InProgressQuests = {} :: {[Player]: {[string]: true}}
RoQuest._CompletedQuests = {} :: {[Player]: {[string]: true}}
RoQuest._DeliveredQuests = {} :: {[Player]: {[string]: true}}

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
	Gets a player quest object. It will return nil if the player has never started
	the quest!

	@param player Player
	@param questId string

	@return Quest?
]=]
function RoQuest:GetQuest(player: Player, questId: string): Quest?
	return self._Quests[player][questId]
end

--[=[
	
]=]
function RoQuest:SetPlayerData(player: Player, data: PlayerQuestData): ()
	--[[
	RoQuest._InProgressQuests = {} :: {[Player]: {[string]: true}}
	RoQuest._CompletedQuests = {} :: {[Player]: {[string]: true}}
	RoQuest._DeliveredQuests = {} :: {[Player]: {[string]: true}}

	self:_LoadPlayerAvailableQuests(player)		
	]]
	self._PlayerQuestData[player] = data
end

--[=[
	
]=]
function RoQuest:GetPlayerData(player: Player): PlayerQuestData
	return self._PlayerQuestData[player] or PlayerQuestData {}
end

--[=[
	
]=]
function RoQuest:AddObjective(player: Player, objectiveId: string, amount: number): ()
	if not self._InProgressQuests[player] then
		return
	end
	
	--[[
	for questId: string in self._InProgressQuests[player] do
		local quest: Quest? = self._Quests[player][questId]

		if not quest then
			continue
		end

		quest:AddObjective(objectiveId, amount)
	end		
	]]

end

--[=[
	
]=]
function RoQuest:SetObjective(player: Player, objectiveId: string, amount: number): ()

end

--[=[
	
]=]
function RoQuest:RemoveObjective(player: Player, objectiveId: string, amount: number): ()
	
end

--[=[
	
]=]
function RoQuest:GiveQuest(player: Player, questId: string): boolean
	
end

--[=[
	
]=]
function RoQuest:CompleteQuest(player: Player, questId: string): boolean
	
end

--[=[
	
]=]
function RoQuest:CancelQuest(player: Player, questId: string): boolean
	
end

--[=[
	
]=]
function RoQuest:CanGiveQuest(player: Player, questId: string): boolean
	local quest: Quest? = self:GetStaticQuest(questId)

	if not quest then
		return false
	end

	for _, requiredQuestId: string in quest.RequiredQuests do
		if not self._DeliveredQuests[player][requiredQuestId] then
			return false
		end
	end

	return not self._InProgressQuests[player][questId] or not not self._CompletedQuests[player][questId] or not not self._DeliveredQuests[player][questId]
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
end

function RoQuest:_QuestBecameUnavailable(questId: string)
	-- Should cancel quest from players if necessary
end

-- Check if any of the quests can become available
function RoQuest:_CheckUnavailableQuests(player: Player)
	
end

--[=[
	Loads all the quests for the given player

	@private
	@param player Player

	@return ()
]=]
function RoQuest:_LoadPlayerAvailableQuests(player: Player): ()
	for questId: string in self._StaticAvailableQuests do
		self:_NewPlayerAvailableQuest(player, questId)
	end

	for questId: string in self._InProgressQuests[player] do
		local quest: Quest = self:GetStaticQuest(questId)

	
	end
end

--[=[
	Checks if the player can accept the quest and if so, gives it to the player

	@private
	@param player Player
	@param questId string

	@return ()
]=]
function RoQuest:_NewPlayerAvailableQuest(player: Player, questId: string)
	if not self:CanGiveQuest(player, questId) then
		return
	end

	local quest: Quest? = self:GetStaticQuest(questId)

	if not quest then
		return
	end

	if quest.QuestAcceptType == QuestAcceptType.Automatic then
		self:GiveQuest(player, questId)
	else
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

		if self._Quests[quest.QuestId] then
			error(string.format(WarningMessages.DuplicateQuestId, quest.QuestId))
		end

		self._Quests[quest.QuestId] = quest

		local questStart: number = quest.QuestStart
		local questEnd: number = quest.QuestEnd
		local currentTime: number = os.time()

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
	self._InProgressQuests[player] = {}
	self._DeliveredQuests[player] = {}
	self._CompletedQuests[player] = {}
	self._PlayerQuestData[player] = PlayerQuestData {}

	self:_LoadPlayerAvailableQuests(player)
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
	self._InProgressQuests[player] = nil
	self._DeliveredQuests[player] = nil
	self._CompletedQuests[player] = nil
	self._PlayerQuestData[player] = nil
end

return RoQuest