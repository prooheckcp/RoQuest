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

local STATUS_CHANGED_REFERENCE: {[QuestStatus]: string} = {
	[QuestStatus.InProgress] = "_ChangeInProgressQuest",
	[QuestStatus.Completed] = "_ChangeCompletedQuest",
	[QuestStatus.Delivered] = "_ChangeDeliveredQuest",
}

--[=[
	:::info

	The client-side only has access to the data and cannot modify it directly (to avoid exploits).
	If you wish to modify data you should do it through the server-side API.

	:::

	@class RoQuestClient
	@client
	
	This is the main Module for the RoQuest Client-side. 
	This is the module developers have access to and can use
	to interact with the libraries' API from the client-side.

	This module gives access to the developer to properly update his quest logs and/or play
	animations and modify client-sided behavior of our quests! 
	
	All the quest data is by default replicated from the server-side into this module using
	the Red library. This means that all the data is up-to-date and can be used to update the player's
	UI or any other client-sided behavior.

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest:Init()
	```
]=]
local RoQuestClient = {}
--[=[
	Called whenever the player data gets changed. This should only happen when the
	server decides to completely overwrite the player data. 
	
	Should be used to reset data on the UI and/or other client-sided displays

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnPlayerDataChanged:Connect(function(playerQuestData: PlayerQuestData)
		self:SetAllScreens(playerQuestData)
	end) -- Hard reset our screens
	```

	@client
	@prop OnPlayerDataChanged Signal
	@within RoQuestClient
]=]
RoQuestClient.OnPlayerDataChanged = Signal.new()
--[=[
	Called when one of the quest's objective gets changed. Useful to update UI elements

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnQuestObjectiveChanged:Connect(function(questId: string, objectiveId: string, newValue: number)
		self:UpdateObjective(RoQuest:GetQuest(questId), objectiveId, newValue)
	end)
	```

	@client
	@prop OnQuestObjectiveChanged Signal
	@within RoQuestClient
]=]
RoQuestClient.OnQuestObjectiveChanged = Signal.new()
--[=[
	Called whenever the player starts a new quest!

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnQuestStarted:Connect(function(questId: string)
		print("Player has started the quest: ", RoQuest:GetQuest(questId).Name)
	end)
	```

	@client
	@prop OnQuestStarted Signal
	@within RoQuestClient
]=]
RoQuestClient.OnQuestStarted = Signal.new() -- Event(questId: string)
--[=[
	Called whenever the player completes a quest!

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnQuestCompleted:Connect(function(questId: string)
		print("Player has completed the quest: ", RoQuest:GetQuest(questId).Name)
	end)
	```

	@client
	@prop OnQuestCompleted Signal
	@within RoQuestClient
]=]
RoQuestClient.OnQuestCompleted = Signal.new() -- Event(questId: string)
--[=[
	Called whenever the player delivers a quest!

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnQuestDelivered:Connect(function(questId: string)
		print("Player has delivered the quest: ", RoQuest:GetQuest(questId).Name)
	end)
	```

	@client
	@prop OnQuestDelivered Signal
	@within RoQuestClient
]=]
RoQuestClient.OnQuestDelivered = Signal.new() -- Event(questId: string)
--[=[
	Called whenever a quest gets cancelled. This might happen when a player
	asks to cancel a quest or the developer disables a quest at run-time (per example when an
	event finishes)

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnQuestCancelled:Connect(function(questId: string)
		print("The following quest just got removed: ", RoQuest:GetQuest(questId).Name)
	end)
	```

	@client
	@prop OnQuestCancelled Signal
	@within RoQuestClient
]=]
RoQuestClient.OnQuestCancelled = Signal.new() -- Event(questId: string)
--[=[
	This gets called when a quest becomes available. This usually means that the player
	can now accept this quest at a given quest giver

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnQuestAvailable:Connect(function(questId: string)
		print("The following quest just became available: ", RoQuest:GetQuest(questId).Name)
	end)
	```

	@client
	@prop OnQuestAvailable Signal
	@within RoQuestClient
]=]
RoQuestClient.OnQuestAvailable = Signal.new()
--[=[
	This gets called whenever the quests that are unavailable changes.
	This means that either a quest just became available OR that a quest became
	unavailable (such as a quest with an end time)

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnUnAvailableQuestChanged:Connect(function()
		print(self:GetUnAvailableQuests())
	end)
	```

	@client
	@prop OnUnAvailableQuestChanged Signal
	@within RoQuestClient
]=]
RoQuestClient.OnUnAvailableQuestChanged = Signal.new()
--[=[
	This gets called whenever the quests that are available changes.
	Called when one of the available quests becomes unavailable or when a quest
	gets started by the player

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnAvailableQuestChanged:Connect(function()
		print(self:GetAvailableQuests())
	end)
	```

	@client
	@prop OnAvailableQuestChanged Signal
	@within RoQuestClient
]=]
RoQuestClient.OnAvailableQuestChanged = Signal.new()
--[=[
	This gets called whenever the quests that are completed changes.
	This gets called when either a quest got delivered, a quest just got completed
	or somehow the quest got cancelled while completed

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnCompletedQuestChanged:Connect(function()
		print(self:GetCompletedQuests())
	end)
	```

	@client
	@prop OnCompletedQuestChanged Signal
	@within RoQuestClient
]=]
RoQuestClient.OnCompletedQuestChanged = Signal.new()
--[=[
	This gets called whenever the quests that are delivered changes.
	This gets called when either a quest got delivered or a delivered quest gets restarted

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnDeliveredQuestChanged:Connect(function()
		print(self:GetDeliveredQuests())
	end)
	```

	@client
	@prop OnDeliveredQuestChanged Signal
	@within RoQuestClient
]=]
RoQuestClient.OnDeliveredQuestChanged = Signal.new()
--[=[
	This gets called whenever the quests that are in progress change.
	This gets called when either a quest got completed or started by the player

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnInProgressQuestChanged:Connect(function()
		print(self:GetInProgressQuests())
	end)
	```

	@client
	@prop OnInProgressQuestChanged Signal
	@within RoQuestClient
]=]
RoQuestClient.OnInProgressQuestChanged = Signal.new()
--[=[
	This is a reference to our Quest class

	@client
	@prop Quest Quest
	@within RoQuestClient
]=]
RoQuestClient.Quest = Quest
--[=[
	This is a reference to our QuestLifeCycle class
	
	@client
	@prop QuestLifeCycle QuestLifeCycle
	@within RoQuestClient
]=]
RoQuestClient.QuestLifeCycle = QuestLifeCycle
--[=[
	This is a reference to our ObjectiveInfo class
	
	@client
	@prop ObjectiveInfo ObjectiveInfo
	@within RoQuestClient
]=]
RoQuestClient.ObjectiveInfo = ObjectiveInfo
--[=[
	This is a reference to our QuestAcceptType enum
	
	@client
	@prop QuestAcceptType QuestAcceptType
	@within RoQuestClient
]=]
RoQuestClient.QuestAcceptType = QuestAcceptType
--[=[
	This is a reference to our QuestDeliverType enum
	
	@client
	@prop QuestDeliverType QuestDeliverType
	@within RoQuestClient
]=]
RoQuestClient.QuestDeliverType = QuestDeliverType
--[=[
	This is a reference to our QuestRepeatableType enum
	
	@client
	@prop QuestRepeatableType QuestRepeatableType
	@within RoQuestClient
]=]
RoQuestClient.QuestRepeatableType = QuestRepeatableType
--[=[
	This is a reference to our QuestStatus enum
	
	@client
	@prop QuestStatus QuestStatus
	@within RoQuestClient
]=]
RoQuestClient.QuestStatus = QuestStatus
--[=[
	Debounce for our :Init function
	
	@client
	@private
	@prop _Initiated boolean
	@within RoQuestClient
]=]
RoQuestClient._Initiated = false :: boolean
--[=[
	A cache with all of the quest lifecycles that were fed into the system
	
	@client
	@private
	@prop _StaticQuestLifeCycles {[string]: QuestLifeCycle}
	@within RoQuestClient
]=]
RoQuestClient._StaticQuestLifeCycles = {} :: {[string]: QuestLifeCycle}
--[=[
	A cache with all of the quests that were fed into the system
	
	@client
	@private
	@prop _StaticQuests {[string]: Quest}
	@within RoQuestClient
]=]
RoQuestClient._StaticQuests = {} :: {[string]: Quest}
--[=[
	A cache with all of the quests that the player is currently engaged on
	
	@client
	@private
	@prop _Quests {[string]: Quest}
	@within RoQuestClient
]=]
RoQuestClient._Quests = {} :: {[string]: Quest}
--[=[
	A cache with all the IDs of quests that are available for our player
	
	@client
	@private
	@prop _AvailableQuests {[string]: true}
	@within RoQuestClient
]=]
RoQuestClient._AvailableQuests = {} :: {[string]: true}
--[=[
	A cache with all the IDs of quests that are unavailable for our player
	
	@client
	@private
	@prop _UnavailableQuests {[string]: true}
	@within RoQuestClient
]=]
RoQuestClient._UnavailableQuests = {} :: {[string]: true}
--[=[
	The cached dynamic data from our player
	
	@client
	@private
	@prop _PlayerQuestData PlayerQuestData
	@within RoQuestClient
]=]
RoQuestClient._PlayerQuestData = nil :: PlayerQuestData

--[=[
	This is one of the most important methods of this Module. It is used
	to ensure that your code is only called **after** the RoQuestClient has been initiated.

	It is safe to get player data and quest data after this method has been called

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnStart():andThen(function()
		print("RoQuestClient has been initiated!")

		RoQuest.OnQuestStarted:Connect(function(questId: string)
			print("Player has started the quest: ", RoQuest:GetQuest(questId).Name)
		end)

		RoQuest.OnQuestCompleted:Connect(function(questId: string)
			print("Player has completed the quest: ", RoQuest:GetQuest(questId).Name)
		end)
	end)
	```
	@client
	@return Promise
]=]
function RoQuestClient.OnStart()
	return Promise.new(function(resolve)
		if RoQuestClient._Initiated then
			resolve()
			return
		end

		while not RoQuestClient._Initiated do
			task.wait()
		end

		resolve()
		return
	end)	
end

--[=[
	:::info

	This function can and should only be called once. It is used to initialize the RoQuestClient

	:::

	Feed the lifecycles of our quests into the Module and initialize the RoQuestClient

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest:Init()
	```

	@client
	@param lifeCycles {QuestLifeCycle}?

	@return ()
]=]
function RoQuestClient:Init(lifeCycles: {QuestLifeCycle}?): ()
	if self._Initiated then
		warn(WarningMessages.RoQuestClientAlreadyInit)
		return
	end

	self:_LoadLifeCycles(lifeCycles or {})

	local net = Red "QuestNamespace"

	-- Need to change the way quests are loaded to allow for dynamic loading
	local quests: {[string]: any} = net:Call("GetQuests"):Await()
	local availableQuests: {[string]: true} = net:Call("GetAvailableQuests"):Await()
	local unavailableQuests: {[string]: true} = net:Call("GetUnAvailableQuests"):Await()
	self:_LoadQuests(quests)

	for questId: string in availableQuests do
		self:_ChangeAvailableState(questId, true)
	end

	for questId: string in unavailableQuests do
		self:_ChangeUnAvailableState(questId, true)
	end

	net:On("OnPlayerDataChanged", function(playerQuestData: PlayerQuestData)
		self:_OnPlayerDataChanged(playerQuestData)
	end)

	net:On("OnQuestObjectiveChanged", function(questId: string, objectiveId: string, newAmount: number)
		self:_OnQuestObjectiveChanged(questId, objectiveId, newAmount)
	end)

	net:On("OnQuestStarted", function(questId: string, questProgress: QuestProgress?)
		self:_OnQuestStarted(questId, questProgress)
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

	net:On("OnQuestUnavailable", function(questId: string)
		self:_OnQuestUnavailable(questId)
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

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnStart():andThen(function()
		local quest: Quest? = RoQuest:GetStaticQuest("QuestId")

		if quest then
			print(quest.Name)
		end
	end)
	```
	@client
	@param questId string

	@return Quest?
]=]
function RoQuestClient:GetStaticQuest(questId: string): Quest?
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

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnStart():andThen(function()
		local quests: {[string]: Quest} = RoQuest:GetStaticQuests()

		for questId: string, quest: Quest in pairs(quests) do -- Prints the name of all the quests
			print(quest.Name)
		end
	end)
	```
	@client
	@return {[string]: Quest}
]=]
function RoQuestClient:GetStaticQuests(): {[string]: Quest}
	return self._StaticQuests
end

--[=[
	Gets a player quest object. It will return nil if the player has never started
	the quest!

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnStart():andThen(function()
		local quest: Quest? = RoQuest:GetQuest("QuestId")

		if quest then
			print(quest.Name)
		else
			print("Player never started this quest!")
		end
	end)
	```

	@client
	@param questId string

	@return Quest?
]=]
function RoQuestClient:GetQuest(questId: string): Quest?
	return self._Quests[questId]
end

--[=[
	Gets all the quests from the player. This includes quests InProgress, Completed and Delivered

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnStart():andThen(function()
		local quests: {[string]: Quest} = RoQuest:GetQuests()

		for questId: string, quest: Quest in pairs(quests) do
			print(quest.Name)
		end
	end)
	```

	@client

	@return {[string]: Quest} -- <questId: string, quest: Quest>
]=]
function RoQuestClient:GetQuests(): {[string]: Quest}
	return self._Quests or {}
end

--[=[
	Gets all the quests that have already been completed by the player

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnStart():andThen(function()
		local quests: {[string]: Quest} = RoQuest:GetCompletedQuests()

		for questId: string, quest: Quest in pairs(quests) do
			print(quest.Name, " is completed!")
		end
	end)
	```

	@client

	@return {[string]: Quest} -- <questId: string, quest: Quest>
]=]
function RoQuestClient:GetCompletedQuests(): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for _, quest: Quest in self:GetQuests() do
		if quest:GetQuestStatus() == QuestStatus.Completed then
			quests[quest.QuestId] = quest
		end
	end

	return quests
end

--[=[
	Gets all the quests that have already been delivered by the player

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnStart():andThen(function()
		local quests: {[string]: Quest} = RoQuest:GetDeliveredQuests()

		for questId: string, quest: Quest in pairs(quests) do
			print(quest.Name, " is delivered!")
		end
	end)
	```

	@client

	@return {[string]: Quest} -- <questId: string, quest: Quest>
]=]
function RoQuestClient:GetDeliveredQuests(): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for _, quest: Quest in self:GetQuests() do
		if quest:GetQuestStatus() == QuestStatus.Delivered then
			quests[quest.QuestId] = quest
		end
	end

	return quests
end

--[=[
	Gets all the quests that the player currently has in progress

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnStart():andThen(function()
		local quests: {[string]: Quest} = RoQuest:GetInProgressQuests()

		for questId: string, quest: Quest in pairs(quests) do
			print(quest.Name, " is in progress!")
		end
	end)
	```

	@client

	@return {[string]: Quest} -- <questId: string, quest: Quest>
]=]
function RoQuestClient:GetInProgressQuests(): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for _, quest: Quest in self:GetQuests() do
		if quest:GetQuestStatus() == QuestStatus.InProgress then
			quests[quest.QuestId] = quest
		end
	end

	return quests
end

--[=[
	Gets all the available quests that the player currently has

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnStart():andThen(function()
		local quests: {[string]: Quest} = RoQuest:GetAvailableQuests()

		for questId: string, quest: Quest in pairs(quests) do
			print(quest.Name, " is available!")
		end
	end)
	```

	@client

	@return {[string]: Quest} -- <questId: string, quest: Quest>
]=]
function RoQuestClient:GetAvailableQuests(): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for questId: string in self._AvailableQuests do
		quests[questId] = self:GetStaticQuest(questId)
	end

	return quests
end

--[=[
	Gets all the unavailable quests that the player currently has

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnStart():andThen(function()
		local quests: {[string]: Quest} = RoQuest:GetUnAvailableQuests()

		for questId: string, quest: Quest in pairs(quests) do
			print(quest.Name, " is unavailable!")
		end
	end)
	```

	@client

	@return {[string]: Quest} -- <questId: string, quest: Quest>
]=]
function RoQuestClient:GetUnAvailableQuests(): {[string]: Quest}
	local quests: {[string]: Quest} = {}

	for questId: string in self._UnavailableQuests do
		quests[questId] = self:GetStaticQuest(questId)
	end

	return quests
end

--[=[
	Checks if the player can accept the quest or not

	```lua
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RoQuest = require(ReplicatedStorage.RoQuest).Client

	RoQuest.OnStart():andThen(function()
		if RoQuest:CanGiveQuest("QuestId") then
			print("Player can accept the quest!")
		else
			print("Player cannot accept the quest!")
		end
	end)
	```

	@client
	@param questId string

	@return boolean -- If we can or not give the quest to the player
]=]
function RoQuestClient:CanGiveQuest(questId: string): boolean
	return self._AvailableQuests[questId]
end

--[=[
	Used to update all the static quests that are cached in our quest system

	@client
	@private

	@param questsData {[string]: any}

	@return ()
]=]
function RoQuestClient:_LoadQuests(questsData: {[string]: any}): ()
	for questId: string, properties in questsData do
		if properties.QuestObjectives then
			for index: number, questObjective in properties.QuestObjectives do
				properties.QuestObjectives[index] = setmetatable(questObjective, QuestObjective)
			end
		end
		self._StaticQuests[questId] = Quest.new(properties)
	end
end

--[=[
	Called whenever the server informs the client that the player data has been hard
	resetted. This usually happens when the player joins the game or when the server
	decides to reset the player data

	@client
	@private

	@param playerQuestData PlayerQuestData

	@return ()
]=]
function RoQuestClient:_OnPlayerDataChanged(playerQuestData: PlayerQuestData)
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

--[=[
	Called whenever the server informs the client that the quest objectives have been updated

	@client
	@private

	@param questId string
	@param objectiveId string
	@param newAmount number

	@return ()
]=]
function RoQuestClient:_OnQuestObjectiveChanged(questId: string, objectiveId: string, newAmount: number): ()
	if not self._PlayerQuestData then
		return
	end
	
	local quest: Quest? = self:GetQuest(questId)
	quest:SetObjective(objectiveId, newAmount)
end

--[=[
	Called whenever the server informs the client that the quest has been started

	@client
	@private

	@param questId string

	@return ()
]=]
function RoQuestClient:_OnQuestStarted(questId: string, questProgress: QuestProgress?): ()
	self:_GiveQuest(questId, questProgress)
	self.OnQuestStarted:Fire(questId)
end

--[=[
	Called whenever the server informs the client that the quest has been completed

	@client
	@private

	@param questId string

	@return ()
]=]
function RoQuestClient:_OnQuestCompleted(questId: string): ()
	local quest: Quest? = self:GetQuest(questId)

	if not quest then
		return
	end

	quest:Complete()
end

--[=[
	Called whenever the server informs the client that the quest has been delivered

	@client
	@private

	@param questId string

	@return ()
]=]
function RoQuestClient:_OnQuestDelivered(questId: string): ()
	local quest: Quest? = self:GetQuest(questId)

	if not quest then
		return
	end

	quest:Deliver()
end

--[=[
	Called whenever the server informs the client that the quest has been cancelled

	@client
	@private

	@param questId string

	@return ()
]=]
function RoQuestClient:_OnQuestCancelled(questId: string): ()
	local quest: Quest? = self:GetQuest(questId)

	if not quest or quest:GetQuestStatus() == QuestStatus.Delivered then
		return
	end

	quest.OnQuestCanceled:Fire()
	self._Quests[questId] = nil
	if STATUS_CHANGED_REFERENCE[quest:GetQuestStatus()] then
		self[STATUS_CHANGED_REFERENCE[quest:GetQuestStatus()]](self, questId, nil)
	end
	quest:Destroy()
	self.OnQuestCancelled:Fire(questId)
end

--[=[
	Called whenever the server informs the client that the quest became available

	@client
	@private

	@param questId string

	@return ()
]=]
function RoQuestClient:_OnQuestAvailable(questId: string)
	self:_ChangeAvailableState(questId, true)
	self:_ChangeUnAvailableState(questId, nil)
end

--[=[
	Called whenever the server informs the client that the quest became unavailable

	@client
	@private

	@param questId string

	@return ()
]=]
function RoQuestClient:_OnQuestUnavailable(questId: string)
	self:_ChangeAvailableState(questId, nil)
	self:_ChangeUnAvailableState(questId, true)
end

--[=[
	Called whenever we need to update the status of a quest that was available

	@client
	@private

	@param questId string
	@param state true?

	@return ()
]=]
function RoQuestClient:_ChangeAvailableState(questId: string, state: true?): ()
	if self._AvailableQuests[questId] == state then
		return
	end

	if state then
		self.OnQuestAvailable:Fire(questId)
	end

	self._AvailableQuests[questId] = state
	self.OnAvailableQuestChanged:Fire(questId, state)
end

--[=[
	Called whenever we need to update the status of a quest that was unavailable

	@client
	@private

	@param questId string
	@param state true?

	@return ()
]=]
function RoQuestClient:_ChangeUnAvailableState(questId: string, state: true?): ()
	if self._UnavailableQuests[questId] == state then
		return
	end

	self._UnavailableQuests[questId] = state
	self.OnUnAvailableQuestChanged:Fire(questId, state)
end

--[=[
	Called whenever we need to update the progress of a quest that was completed

	@client
	@private

	@param questId string
	@param questProgress QuestProgress?

	@return ()
]=]
function RoQuestClient:_ChangeCompletedQuest(questId: string, questProgress: QuestProgress?): ()
	if self._PlayerQuestData.Completed[questId] == questProgress then
		return
	end

	self._PlayerQuestData.Completed[questId] = questProgress
	self.OnCompletedQuestChanged:Fire(questId)
end

--[=[
	Called whenever we need to update the progress of a quest that was delivered

	@client
	@private

	@param questId string
	@param questProgress QuestProgress?

	@return ()
]=]
function RoQuestClient:_ChangeDeliveredQuest(questId: string, questProgress: QuestProgress?): ()
	if self._PlayerQuestData.Delivered[questId] == questProgress then
		return
	end

	self._PlayerQuestData.Delivered[questId] = questProgress
	self.OnDeliveredQuestChanged:Fire(questId)
end

--[=[
	Called whenever we need to update the progress of a quest that is in progress

	@client
	@private

	@param questId string
	@param questProgress QuestProgress?

	@return ()
]=]
function RoQuestClient:_ChangeInProgressQuest(questId: string, questProgress: QuestProgress?): ()
	if self._PlayerQuestData.InProgress[questId] == questProgress then
		return
	end

	self._PlayerQuestData.InProgress[questId] = questProgress
	self.OnInProgressQuestChanged:Fire(questId)
end

--[=[
	Called whenever the server informs our client that a quest has been started

	@client
	@private

	@param questId string
	@param questProgress QuestProgress?

	@return boolean -- If it managed to give the quest to the player or not
]=]
function RoQuestClient:_GiveQuest(questId: string, questProgress: QuestProgress?): boolean
	-- We also check if the quest is available because of repeatable quests
	if self:GetQuest(questId) and not self:CanGiveQuest(questId) then
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

	self:_ChangeAvailableState(questId, nil)
	self:_ChangeUnAvailableState(questId, nil)
	self:_ChangeDeliveredQuest(questId, nil)
	
	self._Quests[questId] = questClone
	self:_ChangeInProgressQuest(questId, questClone:_GetQuestProgress())

	return true
end

--[=[
	Called whenever the server informs our client that a quest has been completed

	@client
	@private

	@param questId string

	@return ()
]=]
function RoQuestClient:_QuestCompleted(questId: string): ()
	local quest: Quest? = self:GetQuest(questId)

	if not quest then
		return
	end

	self:_ChangeInProgressQuest(questId, nil)
	self:_ChangeCompletedQuest(questId, quest:_GetQuestProgress())
end

--[=[
	Called whenever the server informs our client that a quest has been delivered

	@client
	@private

	@param questId string

	@return ()
]=]
function RoQuestClient:_QuestDelivered(questId: string): ()
	local quest: Quest? = self:GetQuest(questId)

	if not quest then
		return
	end

	self:_ChangeCompletedQuest(questId, nil)
	self:_ChangeDeliveredQuest(questId, quest:_GetQuestProgress())
end

--[=[
	Loads all the lifecycles into the cache

	@private
	@client
	@param lifecycles {QuestLifeCycle}

	@return ()
]=]
function RoQuestClient:_LoadLifeCycles(lifecycles: {QuestLifeCycle}): ()
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

return RoQuestClient