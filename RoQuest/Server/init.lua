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
	@class RoQuestServer
	@server

	This is the main MOdule for the RoQuest server-side. 
	This is the module developers have to access 
	to and can use to interact with libraris' API from the server-side

	Here the developer can feed quests, change their progress, give quests, 
	automatically complete, deliver, cancel and much more!

	The data isn't automatically saved, so you have to save it yourself, you can find a guide
	to that in the Docs section!
]=]
local RoQuestServer = {}
--[=[
	Called whenever the player data gets changed. This should only happen when we decide 
	to completely overwrite the player data

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	RoQuest.OnPlayerDataChanged:Connect(function(player: Player, playerQuestData: PlayerQuestData)
		self:SetAllScreens(playerQuestData)
	end) -- Hard reset our screens
	```

	@server
	@prop OnPlayerDataChanged Signal
	@within RoQuestServer
]=]
RoQuestServer.OnPlayerDataChanged = Signal.new()
--[=[
	Called when one of the quest's objective gets changed

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	RoQuest.OnQuestObjectiveChanged:Connect(function(player: Player, questId: string, objectiveId: string, newValue: number)
		self:UpdateObjective(RoQuest:GetQuest(player, questId), objectiveId, newValue)
	end)
	```

	@server
	@prop OnQuestObjectiveChanged Signal
	@within RoQuestServer
]=]
RoQuestServer.OnQuestObjectiveChanged = Signal.new()
--[=[
	Called whenever the player starts a new quest!

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	RoQuest.OnQuestStarted:Connect(function(player: Player, questId: string)
		print("Player has started the quest: ", RoQuest:GetQuest(player, questId).Name)
	end)
	```

	@server
	@prop OnQuestStarted Signal
	@within RoQuestServer
]=]
RoQuestServer.OnQuestStarted = Signal.new()
--[=[
	Called whenever the player completes a quest!

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	RoQuest.OnQuestCompleted:Connect(function(player: Player, questId: string)
		print("Player has completed the quest: ", RoQuest:GetQuest(player, questId).Name)
	end)
	```

	@server
	@prop OnQuestCompleted Signal
	@within RoQuestServer
]=]
RoQuestServer.OnQuestCompleted = Signal.new() -- Event (player: Player, questId: string)
--[=[
	Called whenever the player delivers a quest!

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	RoQuest.OnQuestDelivered:Connect(function(player: Player, questId: string)
		print("Player has delivered the quest: ", RoQuest:GetQuest(player, questId).Name)
	end)
	```

	@server
	@prop OnQuestDelivered Signal
	@within RoQuestServer
]=]
RoQuestServer.OnQuestDelivered = Signal.new() -- Event (player: Player, questId: string)
--[=[
	Called whenever a quest gets cancelled. This might happen when a player
	asks to cancel a quest or the developer disables a quest at run-time (per example when an
	event finishes)

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	RoQuest.OnQuestCancelled:Connect(function(player: Player, questId: string)
		print("The following quest just got removed: ", RoQuest:GetQuest(player, questId).Name)
	end)
	```

	@server
	@prop OnQuestCancelled Signal
	@within RoQuestServer
]=]
RoQuestServer.OnQuestCancelled = Signal.new()
--[=[
	This gets called when a quest becomes available. This usually means that the player
	can now accept this quest at a given quest giver

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	RoQuest.OnQuestAvailable:Connect(function(questId: string)
		print("The following quest just became available: ", RoQuest:GetQuest(player, questId).Name)
	end)
	```

	@server
	@prop OnQuestAvailable Signal
	@within RoQuestServer
]=]
RoQuestServer.OnQuestAvailable = Signal.new()
--[=[
	This gets called when a quest becomes unavailable. Usually only happens when a quest
	gets disabled at run-time or when the quest's end time has passed 

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	RoQuest.OnQuestUnavailable:Connect(function(player: Player, questId: string)
		print("The player's quest has just been cancelled: ", RoQuest:GetStaticQuest(questId).Name)
	end)
	```

	@server
	@prop OnQuestUnavailable Signal
	@within RoQuestServer
]=]
RoQuestServer.OnQuestUnavailable = Signal.new() -- Event (player: Player, questId: string)
--[=[
	This is a reference to our Quest class

	@server
	@prop Quest Quest
	@within RoQuestServer
]=]
RoQuestServer.Quest = Quest
--[=[
	This is a reference to our QuestLifeCycle class

	@server
	@prop QuestLifeCycle QuestLifeCycle
	@within RoQuestServer
]=]
RoQuestServer.QuestLifeCycle = QuestLifeCycle
--[=[
	This is a reference to our ObjectiveInfo class

	@server
	@prop ObjectiveInfo ObjectiveInfo
	@within RoQuestServer
]=]
RoQuestServer.ObjectiveInfo = ObjectiveInfo
--[=[
	This is a reference to our QuestAcceptType enum

	@server
	@prop QuestAcceptType QuestAcceptType
	@within RoQuestServer
]=]
RoQuestServer.QuestAcceptType = QuestAcceptType
--[=[
	This is a reference to our QuestDeliverType enum

	@server
	@prop QuestDeliverType QuestDeliverType
	@within RoQuestServer
]=]
RoQuestServer.QuestDeliverType = QuestDeliverType
--[=[
	This is a reference to our QuestRepeatableType enum

	@server
	@prop QuestRepeatableType QuestRepeatableType
	@within RoQuestServer
]=]
RoQuestServer.QuestRepeatableType = QuestRepeatableType
--[=[
	This is a reference to our QuestStatus enum

	@server
	@prop QuestStatus QuestStatus
	@within RoQuestServer
]=]
RoQuestServer.QuestStatus = QuestStatus
--[=[
	Debounce for our :Init function
	
	@server
	@private
	@prop _Initiated boolean
	@within RoQuestServer
]=]
RoQuestServer._Initiated = false :: boolean
--[=[
	Caches all the static data from all the quests

	@server
	@private
	@prop _StaticQuests {[string]: Quest}
	@within RoQuestServer
]=]
RoQuestServer._StaticQuests = {} :: {[string]: Quest}
--[=[
	This is a pointer that allows us to quickly check with O(1) 
	complexity on which quests are required to start a quest
	
	@server
	@private
	@prop _RequiredQuestPointer {[string]: {[string]: true}}
	@within RoQuestServer
]=]
RoQuestServer._RequiredQuestPointer = {} :: {[string]: {[string]: true}}
--[=[
	Caches the data that we want to send to the client. This is a simplified
	version of a static quest object that we can send to the client
	
	@server
	@private
	@prop _StaticNetworkParse {[string]: any}
	@within RoQuestServer
]=]
RoQuestServer._StaticNetworkParse = {} :: {[string]: any}
--[=[
	Caches all the static data from all the lifecycles
	
	@server
	@private
	@prop _StaticQuestLifeCycles {[string]: QuestLifeCycle}
	@within RoQuestServer
]=]
RoQuestServer._StaticQuestLifeCycles = {} :: {[string]: QuestLifeCycle}
--[=[
	A static reference to the quests that are available for the server
	to give to the players
	
	@server
	@private
	@prop _StaticAvailableQuests {[string]: true}
	@within RoQuestServer
]=]
RoQuestServer._StaticAvailableQuests = {} :: {[string]: true}
--[=[
	A reference to check the objectives of our quests
	
	@server
	@private
	@prop _StaticObjectiveReference {[string]: {[string]: true}}
	@within RoQuestServer
]=]
RoQuestServer._StaticObjectiveReference = {} :: {[string]: {[string]: true}}
--[=[
	Cached data of all of the quests that the players are currently engaged with.
	This includes quests that are: InProgress, Completed and Delivered
	
	@server
	@private
	@prop _Quests {[Player]: {[string]: Quest}}
	@within RoQuestServer
]=]
RoQuestServer._Quests = {} :: {[Player]: {[string]: Quest}}
--[=[
	Cahed PlayerQuestData for all of the players. This is the dynamic data
	of the player quests that he is currently holding

	@server
	@private
	@prop _PlayerQuestData {[Player]: PlayerQuestData}
	@within RoQuestServer
]=]
RoQuestServer._PlayerQuestData = {} :: {[Player]: PlayerQuestData}
--[=[
	Cached pointer to all the quests that are available for this player to start

	@server
	@private
	@prop _AvailableQuests {[Player]: {[string]: true}}
	@within RoQuestServer
]=]
RoQuestServer._AvailableQuests = {} :: {[Player]: {[string]: true}}
--[=[
	Cached pointer to all the quests that are unavailable for this player

	@server
	@private
	@prop _UnavailableQuests {[Player]: {[string]: true}}
	@within RoQuestServer
]=]
RoQuestServer._UnavailableQuests = {} :: {[Player]: {[string]: true}}

--[=[
	This is one of the most important methods of this Module. It is used
	to ensure that your code is only called **after** the RoQuestServer has been initiated.

	It is safe to get player data and quest data after this method has been called

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	RoQuest.OnStart():andThen(function()
		print("RoQuestServer has been initiated!")

		RoQuest.OnQuestStarted:Connect(function(player: Player, questId: string)
		print(player.Name, "has just started the quest: ", RoQuest:GetStaticQuest(questId).Name, "!")
		end)

		RoQuest.OnQuestCompleted:Connect(function(player: Player, questId: string)
			print(player.Name, "has just completed the quest: ", RoQuest:GetStaticQuest(questId).Name, "!")
		end)
	end)
	```
	@server
	@return Promise
]=]
function RoQuestServer.OnStart()
	return Promise.new(function(resolve)
		if RoQuestServer._Initiated then
			resolve()
			return
		end

		while not RoQuestServer._Initiated do
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

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	RoQuest:Init(RoQuest:LoadDirectory(ReplicatedStorage.Quests))
	```
	@server
	@param quests {Quest}
	@param lifeCycles {QuestLifeCycle}?

	@return ()
]=]
function RoQuestServer:Init(quests: {Quest}, lifeCycles: {QuestLifeCycle}?): ()
	if self._Initiated then
		warn(WarningMessages.RoQuestServerAlreadyInit)
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
		self:_WaitForPlayerToLoad(player)

		return RoQuestServer._StaticNetworkParse
	end)

	net:On("GetAvailableQuests", function(player: Player)
		self:_WaitForPlayerToLoad(player)

		return RoQuestServer._AvailableQuests[player]
	end)

	net:On("GetUnAvailableQuests", function(player: Player)
		self:_WaitForPlayerToLoad(player)

		return RoQuestServer._UnavailableQuests[player]
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

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	RoQuest:Init(RoQuest:LoadDirectory(ReplicatedStorage.Quests))
	```

	@server
	@param directory {Instance}

	@return {Quest | QuestLifeCycle} -- Returns an array with either just Quests or QuestLifeCycles
]=]
function RoQuestServer:LoadDirectory(directory: Instance): {Quest | QuestLifeCycle}
	return self:_LoadDirectory(directory:GetChildren())
end

--[=[
	Loads all the quests and lifecycles from the descendants of the directory and returns them in an array.
	The difference from :LoadDirectoryDeep and :LoadDirectory is that this one takes all descendants into account
	instead of just the children

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	RoQuest:Init(RoQuest:LoadDirectoryDeep(ReplicatedStorage.Quests))
	```

	@server
	@param directory {Instance}

	@return {Quest | QuestLifeCycle} -- Returns an array with either just Quests or QuestLifeCycles
]=]
function RoQuestServer:LoadDirectoryDeep(directory: Instance): {Quest | QuestLifeCycle}
	return self:_LoadDirectory(directory:GetDescendants())
end

--[=[
	Gets the static data of a cached quest by the given ID

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	local quest: Quest = RoQuest:GetStaticQuest("QuestId")
	```

	@server
	@param questId string

	@return Quest?
]=]
function RoQuestServer:GetStaticQuest(questId: string): Quest?
	local quest: Quest? = self._StaticQuests[questId]

	if not quest then
		warn(string.format(WarningMessages.NoQuestById, questId))
	end

	return quest
end

--[=[
	Gets the static data of all of the cached quests

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	local quests: {[string]: Quest} = RoQuest:GetStaticQuests()
	```

	@server

	@return {[string]: Quest} -- <questId: string, quest: Quest>
]=]
function RoQuestServer:GetStaticQuests(): {[string]: Quest}
	return self._StaticQuests
end

--[=[
	:::info

	This function returns a quest object if the status of the quest is InProgress, Completed or Delivered

	:::

	Gets a player quest object. It will return nil if the player has never started
	the quest!

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	local quest: Quest? = RoQuest:GetQuest(player, "QuestId")
	--...
	```

	@server
	@param player Player
	@param questId string

	@return Quest?
]=]
function RoQuestServer:GetQuest(player: Player, questId: string): Quest?
	return self._Quests[player][questId]
end

--[=[
	:::info

	This function returns all the quests of the status of the quest is InProgress, Completed or Delivered

	:::

	Returns all the quests of the given player

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	local quests: {[string]: Quest} = RoQuest:GetQuests(player)
	--...
	```

	@server
	@param player Player

	@return {[string]: Quest} -- <questId: string, quest: Quest>
]=]
function RoQuestServer:GetQuests(player: Player): {[string]: Quest}
	return self._Quests[player] or {}
end

--[=[
	Gets all the completed quests by the given player
	
	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	local completedQuests: {[string]: Quest} = RoQuest:GetCompletedQuests(player)
	print(completeQuests) -- {QuestId = QuestObject, QuestId2 = QuestObject2, ...}
	--...
	```

	@server
	@param player Player -- The player that owns all the quests

	@return {[string]: Quest} -- <questId: string, quest: Quest>
]=]
function RoQuestServer:GetCompletedQuests(player: Player): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for questId: string in self:GetPlayerData(player).Completed do
		quests[questId] = self:GetQuest(player, questId)
	end

	return quests
end

--[=[
	Gets all the delivered quests by the given player
	
	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	local deliveredQuests: {[string]: Quest} = RoQuest:GetDeliveredQuests(player)
	print(deliveredQuests) -- {QuestId = QuestObject, QuestId2 = QuestObject2, ...}
	--...
	```

	@server
	@param player Player -- The player that owns all the quests

	@return {[string]: Quest} -- <questId: string, quest: Quest>
]=]
function RoQuestServer:GetDeliveredQuests(player: Player): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for questId: string in self:GetPlayerData(player).Delivered do
		quests[questId] = self:GetQuest(player, questId)
	end

	return quests
end

--[=[
	Gets all the quests that are in progress by the given player
	
	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	local questsInProgress: {[string]: Quest} = RoQuest:GetInProgressQuests(player)
	print(questsInProgress) -- {QuestId = QuestObject, QuestId2 = QuestObject2, ...}
	--...
	```

	@server
	@param player Player -- The player that owns all the quests

	@return {[string]: Quest} -- <questId: string, quest: Quest>
]=]
function RoQuestServer:GetInProgressQuests(player: Player): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for questId: string in self:GetPlayerData(player).InProgress do
		quests[questId] = self:GetQuest(player, questId)
	end

	return quests
end

--[=[
	Gets all the quests that are available to the player. This means that the player can start the quest
	
	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	local availableQuests: {[string]: Quest} = RoQuest:GetAvailableQuests(player)
	print(availableQuests) -- {QuestId = QuestObject, QuestId2 = QuestObject2, ...}
	--...
	```

	@server
	@param player Player -- The player that owns all the quests

	@return {[string]: Quest} -- <questId: string, quest: Quest>
]=]
function RoQuestServer:GetAvailableQuests(player: Player): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for questId: string in self._AvailableQuests[player] do
		quests[questId] = self:GetStaticQuest(questId)
	end

	return quests
end

--[=[
	Gets all the quests that are unavailable to the player. This means that the player can't start the quest
	
	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	local unavailableQuests: {[string]: Quest} = RoQuest:GetUnAvailableQuests(player)
	print(unavailableQuests) -- {QuestId = QuestObject, QuestId2 = QuestObject2, ...}
	--...
	```

	@server
	@param player Player -- The player that owns all the quests

	@return {[string]: Quest} -- <questId: string, quest: Quest>
]=]
function RoQuestServer:GetUnAvailableQuests(player: Player): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for questId: string in self._UnavailableQuests[player] do
		quests[questId] = self:GetStaticQuest(questId)
	end

	return quests
end

--[=[
	Sets the player data. This will overwrite the current player data with the given data

	:::warning

	This should only be used when loading a player. It should be avoided at all costs unless
	completely necessary

	:::

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	RoQuest:SetPlayerData(player, playerQuestData)
	--...
	```

	@server
	@param player Player
	@param data PlayerQuestData

	@return ()
]=]
function RoQuestServer:SetPlayerData(player: Player, data: PlayerQuestData): ()
	self._PlayerQuestData[player] = data

	self:_LoadPlayerData(player)
end

--[=[
	Gets the player data. This is how we are capable of retreiving data to use when
	storing it to a DataStore

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	local playerData: PlayerQuestData = RoQuest:GetPlayerData(player)
	--...
	```

	@server
	@param player Player

	@return PlayerQuestData
]=]
function RoQuestServer:GetPlayerData(player: Player): PlayerQuestData
	return self._PlayerQuestData[player] or PlayerQuestData {}
end

--[=[
	Gets the current value of the quest's objective. This will return 0 if the quest doesn't exist

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	local objectiveValue: number = RoQuest:GetObjective(player, "QuestId", "ObjectiveId")
	--...
	```

	@server
	@param player Player -- The player that owns the quest
	@param questId string -- The ID of our objective
	@param objectiveId string

	@return number
]=]
function RoQuestServer:GetObjective(player: Player, questId: string, objectiveId: string): number
	local quest: Quest? = self:GetQuest(player, questId)

	if not quest then
		return 0
	end

	return quest:GetObjective(objectiveId)
end

--[=[
	Adds X amount from all the quests that contain the given objective ID

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	RoQuest:AddObjective(player, "ObjectiveId", 5)
	--...
	```

	@server
	@param player Player -- The player that owns the quests
	@param objectiveId string -- The ID of our objective
	@param amount number -- The amount we want to increment to the objective of our quests

	@return ()
]=]
function RoQuestServer:AddObjective(player: Player, objectiveId: string, amount: number): ()
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
	Sets all the quests that contain the given objective ID to the given amount

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	RoQuest:GetObjective(player, "questId", "ObjectiveId") -- 0
	RoQuest:SetObjective(player, "ObjectiveId", 5)
	RoQuest:GetObjective(player, "questId", "ObjectiveId") -- 5
	--...
	```

	@server
	@param player Player -- The player that owns the quests
	@param objectiveId string -- The ID of our objective
	@param amount number -- The amount to which the objective should be set to

	@return ()
]=]
function RoQuestServer:SetObjective(player: Player, objectiveId: string, amount: number): ()
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
	Removes X amount from all the quests that contain the given objective ID

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	RoQuest:RemoveObjective(player, "ObjectiveId", 5)
	--...
	```

	@server
	@param player Player -- The player that owns the quests
	@param objectiveId string -- The ID of our objective
	@param amount number -- The amount we want to decrement to the objective of our quests

	@return ()
]=]
function RoQuestServer:RemoveObjective(player: Player, objectiveId: string, amount: number): ()
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
	Gives the quest to the player for him to start. Usually used when quests are set 
	to manual mode

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	RoQuest:GiveQuest(player, "QuestId")
	--...
	```

	@server
	@param player Player
	@param questId string

	@return boolean -- If it managed to give the player the quest or not
]=]
function RoQuestServer:GiveQuest(player: Player, questId: string): boolean
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
	Completes the quest of a player instantly. This will not deliver the quest unless deliver
	is set to automatically

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	RoQuest:CompleteQuest(player, "QuestId")
	--...

	```

	@server
	@param player Player
	@param questId string

	@return boolean -- If it managed to complete the quest or not
]=]
function RoQuestServer:CompleteQuest(player: Player, questId: string): boolean
	local quest: Quest? = self:GetQuest(player, questId)

	if not quest then
		return false
	end

	return quest:Complete()
end

--[=[
	Delivers the quest of a player

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	RoQuest:DeliverQuest(player, "QuestId")
	--...

	```

	@server
	@param player Player
	@param questId string

	@return boolean -- If it managed to deliver the quest or not
]=]
function RoQuestServer:DeliverQuest(player: Player, questId: string)
	local quest: Quest? = self:GetQuest(player, questId)

	if not quest then
		return false
	end

	return quest:Deliver()
end

--[=[
	Cancels the quest of a player. This will remove the quest from the player's cache

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	--...
	RoQuest:CancelQuest(player, "QuestId")
	--...

	```

	@server
	@param player Player
	@param questId string

	@return boolean -- If it managed to cancel the quest or not
]=]
function RoQuestServer:CancelQuest(player: Player, questId: string): boolean
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
	Checks if the player can or not accept the quest

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Server

	local player: Player = game.Players:GetPlayers()[1]

	if RoQuest:CanGiveQuest(player, "QuestId") then
		print("Player can accept the quest!")
	else
		print("Player can't accept the quest!")
	end
	```

	@server
	@param player Player
	@param questId string

	@return boolean -- If the player can accept the quest or not
]=]
function RoQuestServer:CanGiveQuest(player: Player, questId: string): boolean
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

--[=[
	Called when a quest gets completed. Updates the cache about the quest status

	@private
	@server
	@param player Player
	@param questId string

	@return ()
]=]
function RoQuestServer:_QuestCompleted(player: Player, questId: string): ()
	local quest: Quest? = self:GetQuest(player, questId)

	if not quest then
		return
	end

	self._PlayerQuestData[player].InProgress[questId] = nil
	self._PlayerQuestData[player].Completed[questId] = quest:_GetQuestProgress()
end

--[=[
	Called when a quest gets delivered. Updates the cache about the quest status

	@private
	@server
	@param player Player
	@param questId string

	@return ()
]=]
function RoQuestServer:_QuestDelivered(player: Player, questId: string): ()
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
	@server
	@param instancesToFilter {Instance}

	@return {Quest | QuestLifeCycle}
]=]
function RoQuestServer:_LoadDirectory(instancesToFilter: {Instance}): {Quest | QuestLifeCycle}
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
	Yields until the player finishes loading

	@server
	@private
	@yields
	@param player Player

	@return ()
]=]
function RoQuestServer:_WaitForPlayerToLoad(player: Player): ()
	while not self._PlayerQuestData[player] and player.Parent == Players do -- Wait for player to load
		task.wait()
	end
end

--[=[
	Called whenever a quest became available to update our cache

	@server
	@private
	@param questId string

	@return ()
]=]
function RoQuestServer:_QuestBecameAvailable(questId: string): ()
	if self._StaticAvailableQuests[questId] then
		return false
	end

	self._StaticAvailableQuests[questId] = true -- Should give to players if possible

	for player: Player in self._Quests do
		self:_NewPlayerAvailableQuest(player, questId)
	end
end

--[=[
	Called whenever a quest became unavailable to update our cache

	@server
	@private
	@param questId string

	@return ()
]=]
function RoQuestServer:_QuestBecameUnavailable(questId: string): ()
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

--[=[
	If possible we'll give the quest to the player

	@server
	@private
	@param player Player -- The player that should receive the quest
	@param questId string -- The ID of the quest
	@param questProgress QuestProgress? -- The progress of the quest if there was already any

	@return boolean -- If it managed to give the quest to the player or not
]=]
function RoQuestServer:_GiveQuest(player: Player, questId: string, questProgress: QuestProgress?): boolean
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

	@server
	@private
	@param player Player

	@return ()
]=]
function RoQuestServer:_LoadPlayerData(player: Player): ()
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

	@server
	@private
	@param player Player
	@param questId string

	@return ()
]=]
function RoQuestServer:_NewPlayerAvailableQuest(player: Player, questId: string)
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

	@server
	@private
	@param quests {Quest}

	@return ()
]=]
function RoQuestServer:_LoadQuests(quests: {Quest}): ()
	for _, quest: Quest in quests do
		if quest.__type ~= "Quest" then
			continue
		end

		if quest.Disabled then
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

	@server
	@private
	@param lifecycles {QuestLifeCycle}

	@return ()
]=]
function RoQuestServer:_LoadLifeCycles(lifecycles: {QuestLifeCycle}): ()
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

	@server
	@private
	@param player Player

	@return ()
]=]
function RoQuestServer:_PlayerAdded(player: Player): ()
	self._Quests[player] = {}
	self._AvailableQuests[player] = {}
	self._UnavailableQuests[player] = {}
	self._PlayerQuestData[player] = PlayerQuestData {}

	self:_LoadPlayerData(player)
end

--[=[
	Called 5 seconds after the player leaves the game. Used to clear the cache of the player

	@server
	@private
	@param player Player

	@return ()
]=]
function RoQuestServer:_PlayerRemoving(player: Player): ()
	self._Quests[player] = nil
	self._AvailableQuests[player] = nil
	self._UnavailableQuests[player] = nil
	self._PlayerQuestData[player] = nil
end

return RoQuestServer