local Red = require(script.Parent.Vendor.Red).Client
local Signal = require(script.Parent.Vendor.Signal)
local QuestLifeCycle = require(script.Parent.Shared.Classes.QuestLifeCycle)
local Quest = require(script.Parent.Shared.Classes.Quest)
local WarningMessages = require(script.Parent.Shared.Data.WarningMessages)
local PlayerQuestData = require(script.Parent.Shared.Structs.PlayerQuestData)

type Quest = Quest.Quest
type QuestLifeCycle = QuestLifeCycle.QuestLifeCycle
type PlayerQuestData = PlayerQuestData.PlayerQuestData

local RoQuest = {}
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
RoQuest._Quests = {} :: {[Player]: {[string]: Quest}}

function RoQuest:Init(lifeCycles: {QuestLifeCycle}?): ()
    if self._Initiated then
		warn(WarningMessages.RoQuestAlreadyInit)
		return
	end

    self._Initiated = true
    self:_LoadLifeCycles(lifeCycles or {})

	local net = Red "QuestNamespace"

	net:On("OnQuestObjectiveChanged", function()
		
	end)

	net:On("OnQuestStarted", function()
		print("quest started")
	end)

	net:On("OnQuestCompleted", function()
		
	end)

	net:On("OnQuestDelivered", function()
		
	end)

	net:On("OnQuestCancelled", function()
		
	end)

	net:On("OnQuestAvailable", function()
		
	end)

	net:Call("GetPlayerData"):Then(function(playerData: PlayerQuestData)
		print("Loaded player data: ", playerData) -- do stuff with the data
	end)
end

function RoQuest:_LoadQuests(quests: {Quest}): ()

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