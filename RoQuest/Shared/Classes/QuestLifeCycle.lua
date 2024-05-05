--!strict
local QuestObjective = require(script.Parent.QuestObjective)
local QuestStatus = require(script.Parent.Parent.Enums.QuestStatus)
local Signal = require(script.Parent.Parent.Parent.Vendor.Signal)
local QuestAcceptType = require(script.Parent.Parent.Enums.QuestAcceptType)
local QuestDeliverType = require(script.Parent.Parent.Enums.QuestDeliverType)
local QuestRepeatableType = require(script.Parent.Parent.Enums.QuestRepeatableType)
local assertProperties = require(script.Parent.Parent.Functions.assertProperties)

type QuestObjective = QuestObjective.QuestObjective
type QuestStatus = QuestStatus.QuestStatus
type Signal = Signal.Signal
type QuestAcceptType = QuestAcceptType.QuestAcceptType
type QuestDeliverType = QuestDeliverType.QuestDeliverType
type QuestRepeatableType = QuestRepeatableType.QuestRepeatableType

type Quest = { -- Fake quest type for autocomplete candy
	AddObjective: (self: Quest, objectiveId: string, amount: number) -> (),
	Complete: (self: Quest) -> (),
	Deliver: (self: Quest) -> (),
	Description: string,
	GetCompleteCount: (self: Quest) -> number,
	GetFirstCompletedTick: (self: Quest) -> number,
	GetLastCompletedTick: (self: Quest) -> number,
	GetObjective: (self: Quest, objectiveId: string) -> number,
	GetQuestStatus: (self: Quest) -> QuestStatus,
	LifeCycles: {string},
	Name: string,
	OnQuestCanceled: Signal,
	OnQuestCompleted: Signal,
	OnQuestDelivered: Signal,
	OnQuestObjectiveChanged: Signal,
	QuestAcceptType: QuestAcceptType,
	QuestDeliverType: QuestDeliverType,
	QuestEnd: number,
	QuestId: string,
	QuestObjectives: {QuestObjective},
	QuestRepeatableType: QuestRepeatableType,
	QuestStart: number,
	RemoveObjective: (self: Quest, objectiveId: string, newAmount: number) -> (),
	RequiredQuests: {string},
	SetObjective: (self: Quest, objectiveId: string, newAmount: number) -> (),
}

--[=[
	@class QuestLifeCycle
	@tag Class
	
	QuestLifeCycles are classes that are used to give behavior to our quests. They get associated to a quest when it gets declared
	and will allow the developer to update world instances and other things when the quest is available, started, completed or delivered

	:::info

	The lifecycle runs on the side where you injected it meaning that if you load a lifecycle in the server-side it will be
	managed by the server while if you inject it in the client it will be managed by the client

	:::

	```lua
	local appleQuest = QuestLifeCycle.new {
		Name = "AppleQuest",
	}

	function appleQuest:OnAvailable()
		print("AppleQuest is now available!")
	end

	function appleQuest:OnStarted()
		print("AppleQuest has been started!")
	end

	function appleQuest:OnCompleted()
		print("AppleQuest has been completed!")
	end

	function appleQuest:OnDelivered()
		print("AppleQuest has been delivered!")
	end

	function appleQuest:OnObjectiveChanged(objectiveId: string, newAmount: number)
		print("Objective " .. objectiveId .. " has been updated to " .. newAmount)
	end
	```

]=]
local QuestLifeCycle = {}
QuestLifeCycle.__index = QuestLifeCycle
QuestLifeCycle.__type = "QuestLifeCycle"

--[=[
	The name of the lifecycle. This needs to be unique for each lifecycle

	@prop Name string
	@within QuestLifeCycle
]=]
QuestLifeCycle.Name = "" :: string
--[=[
	A reference to the player to which this lifecycle is associated

	@prop Player Player
	@within QuestLifeCycle
]=]
QuestLifeCycle.Player = newproxy() :: Player
--[=[
	A reference to the quest that this lifecycle is managing

	@prop Quest Quest
	@within QuestLifeCycle
]=]
QuestLifeCycle.Quest = newproxy() :: Quest

--[=[
	Constructor for Quest

	```lua
	local appleQuest = QuestLifeCycle.new {
		Name = "AppleQuest",
	}
	```

	@param properties {[string]: any}

	@return Quest
]=]
function QuestLifeCycle.new(properties: {[string]: any})
	return assertProperties(properties, QuestLifeCycle)
end

--[=[
	Called when the player starts the quest

	:::warning

	This method only gets called on the first time the player starts a quest with this LifeCycle.
	This means if there are 2 quests with the same lifecycle and the player already started one of them
	then this method won't get called

	:::

	@return ()
]=]
function QuestLifeCycle:FirstStart(): ()
	
end

--[=[
	Called when the player completes the quest
	:::warning

	This method only gets called when the player completed **ALL** quests that contain this lifecyle.
	This means if the player has 2 quests with the same lifeycle in progress, only after he completes both of them
	then will this method be called

	:::

	@return ()
]=]
function QuestLifeCycle:AllComplete(): ()
	
end

--[=[
	Called when the player quest starts the quest

	:::info

	This is a virtual method. Meaning you can override it in your lifecycle

	:::

	@return ()
]=]
function QuestLifeCycle:OnStart(): ()
	
end

--[=[
	Called when the quest gets completed 

	:::info

	This is a virtual method. Meaning you can override it in your lifecycle

	:::

	@return ()
]=]
function QuestLifeCycle:OnComplete(): ()
	
end

--[=[
	Called when the quest gets delivered. Doesn't get called if the player joined the game
	and the quest was already delivered

	:::info

	This is a virtual method. Meaning you can override it in your lifecycle

	:::

	@return ()
]=]
function QuestLifeCycle:OnDeliver(): ()
	
end

--[=[
	Called when an objective of the quest gets updated

	:::info

	This is a virtual method. Meaning you can override it in your lifecycle

	:::

	@param _objectiveId string
	@param _newAmount number

	@return ()
]=]
function QuestLifeCycle:OnObjectiveChange(_objectiveId: string, _newAmount: number): ()
	
end

--[=[
	Called when the quest object gets destroyed. This happens when the player leaves the game or the quest gets removed

	:::info

	This is a virtual method. Meaning you can override it in your lifecycle

	:::

	@return ()
]=]
function QuestLifeCycle:OnDestroy(): ()
	
end

export type QuestLifeCycle = typeof(QuestLifeCycle)

return setmetatable(QuestLifeCycle, {
    __call = function(_, properties)
        return QuestLifeCycle.new(properties)
    end
})