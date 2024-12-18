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

    This is the main class of our quest system. Quest objects define exactly the kind of quest and how
    can a player complete it. When declaring a quest there are multiple properties that should
    be taken into consideration. On the following example we can see how could we, per example, make
    a quest to collect 5 apples.

    ```lua
    local appleQuest = ObjectiveInfo.new { -- We are creating an objective info object to store the data of our objective
        ObjectiveId = "CollectApples",
        Name = "Collect Apples",
        Description = "Collect %s apples",
    }

    local quest = Quest.new { -- We are creating a quest object with all the relevant data
        Name = "Collect Apples", -- The name of our quest
        Description = "Collect %s apples", -- The description that we will display to our user
        QuestId = "AppleCollection", -- A unique identifier to our quest
        QuestAcceptType = QuestAcceptType.Automatic, -- If the quest automatically gets accepted or rquires manual work
        QuestDeliverType = QuestDeliverType.Automatic, -- If the quest automatically gets delivered or requires manual work
        QuestRepeatableType = QuestRepeatableType.NonRepeatable, -- If the quest can be repeated or not
        QuestStart = -1, -- UTC time to define when the quest should become available (specially useful for event quests)
        QuestEnd = -1, -- UTC time to define when the quest should no longer be available (specially useful for event quests)
        RequiredQuests = {}, -- A list of quests that are required to be delivered before this quest can be started
        LifeCycles = {"AppleQuest"}, -- The lifecycles that will manage this quest's behavior
        QuestObjectives = {
            appleQuest:NewObjective(5)
        },
    }
    ```
]=]
local Quest = {}
Quest.__index = Quest
Quest.__type = "Quest"
--[=[
    Called whenever a quest objective gets completed

    ```lua
    quest.OnQuestObjectiveCompleted:Connect(function(objectiveId: string)
        print("Completed Objective: " .. objectiveId)
    end)
    ```

    @prop OnQuestObjectiveCompleted Signal
    @within Quest
]=]
Quest.OnQuestObjectiveCompleted = newproxy() :: Signal
--[=[
    Called whenever one of the quests objective changes the value

    ```lua
    quest.OnQuestObjectiveChanged:Connect(function(objectiveId: string, newAmount: number)
        print("Objective " .. objectiveId .. " has changed to " .. newAmount)
    end)
    ```

    @prop OnQuestObjectiveChanged Signal
    @within Quest
]=]
Quest.OnQuestObjectiveChanged = newproxy() :: Signal
--[=[
    Called when the quest gets completed

    ```lua
    quest.OnQuestCompleted:Connect(function()
        print("The quest got completed!")
    end)
    ```

    @prop OnQuestCompleted Signal
    @within Quest
]=]
Quest.OnQuestCompleted = newproxy() :: Signal
--[=[
    Called when the quest gets delivered

    ```lua
    quest.OnQuestDelivered:Connect(function()
        print("The quest got delivered!")
    end)
    ```

    @prop OnQuestDelivered Signal
    @within Quest
]=]
Quest.OnQuestDelivered = newproxy() :: Signal
--[=[
    Called when the quest gets cancelled

    ```lua
    quest.OnQuestCanceled:Connect()
        print("The quest got cancelled!")
    end)
    ```

    @prop OnQuestCanceled Signal
    @within Quest
]=]
Quest.OnQuestCanceled = newproxy() :: Signal
--[=[
    The name of the quest

    @prop Name string
    @within Quest
]=]
Quest.Name = "" :: string
--[=[
    The description of the quest
    
    @prop Description string
    @within Quest
]=]
Quest.Description = "" :: string
--[=[
    If the quest is disabled or not. If the quest is disabled it will
    be ignored when loaded into the system

    @prop Disabled boolean
    @within Quest
]=]
Quest.Disabled = false :: boolean
--[=[
    The quest ID. This must be a unique identifier for the quest
    
    @prop Name string
    @within Quest
]=]
Quest.QuestId = "" :: string
--[=[
    The type of the quest accepting system. This can be either automatic or manual
    
    @prop QuestAcceptType QuestAcceptType
    @within Quest
]=]
Quest.QuestAcceptType = QuestAcceptType.Automatic :: QuestAcceptType
--[=[
    The type of the quest delivering system. This can be either automatic or manual
    
    @prop QuestDeliverType QuestDeliverType
    @within Quest
]=]
Quest.QuestDeliverType = QuestDeliverType.Automatic :: QuestDeliverType
--[=[
    How many times can this quest be repeated
    
    @prop QuestRepeatableType QuestRepeatableType
    @within Quest
]=]
Quest.QuestRepeatableType = QuestRepeatableType.NonRepeatable :: QuestRepeatableType
--[=[
    UTC time to define when the quest should become available (specially useful for event quests)

    @prop QuestStart number
    @within Quest
]=]
Quest.QuestStart = -1 :: number
--[=[
    UTC time to define when the quest should no longer be available (specially useful for event quests)
    
    @prop QuestEnd number
    @within Quest
]=]
Quest.QuestEnd = -1 :: number
--[=[
    This is an array with all the required quest IDs in order for this quest to become available

    @prop RequiredQuests {string}
    @within Quest
]=]
Quest.RequiredQuests = {} :: {string}
--[=[
    This is an array with all the LifeCycles names that will manage this quest's behavior

    @prop LifeCycles {string}
    @within Quest
]=]
Quest.LifeCycles = {} :: {string}
--[=[
    An array with all the objectives required to complete this quest

    @prop QuestObjectives {QuestObjective}
    @within Quest
]=]
Quest.QuestObjectives = {} :: {QuestObjective}
--[=[
    This is a boolean that determines whether the player can repeat this
    quest after it has been completed or not

    @private
    @prop _CanRepeatQuest boolean
    @within Quest
]=]
Quest._CanRepeatQuest = false :: boolean
--[=[
    A hash map that stores and tracks all the quest objectives that are currently active in the quest

    @private
    @prop _QuestObjectives {[string]: QuestObjective}
    @within Quest
]=]
Quest._QuestObjectives = {} :: {[string]: QuestObjective}
--[=[
    Cached value of our quest progress

    @private
    @prop _QuestProgress QuestProgress
    @within Quest
]=]
Quest._QuestProgress = newproxy() :: QuestProgress
--[=[
    Our trove used to cleanup connections

    @private
    @prop _Trove Trove
    @within Quest
]=]
Quest._Trove = newproxy() :: Trove

--[=[
    Constructor for Quest

    ```lua
    local appleQuest = ObjectiveInfo.new {
        ObjectiveId = "CollectApples",
        Name = "Collect Apples",
        Description = "Collect %s apples",
    }

    local quest = Quest.new {
        Name = "Collect Apples",
        Description = "Collect %s apples",
        QuestId = "AppleCollection",
        QuestAcceptType = QuestAcceptType.Automatic,
        QuestDeliverType = QuestDeliverType.Automatic,
        QuestRepeatableType = QuestRepeatableType.NonRepeatable,
        QuestStart = 0,
        QuestEnd = 0,
        RequiredQuests = {},
        LifeCycles = {"AppleQuest"},
        QuestObjectives = {
            appleQuest:NewObjective(5)
        },
    }
    ```

    @param properties {[string]: any}

    @return Quest
]=]
function Quest.new(properties: {[string]: any}): Quest
    properties = properties or {}
    local self: Quest = assertProperties(properties, Quest)
    self.OnQuestObjectiveCompleted = Signal.new()
    self.OnQuestObjectiveChanged = Signal.new()
    self.OnQuestCompleted = Signal.new()
    self.OnQuestDelivered = Signal.new()
    self.OnQuestCanceled = Signal.new()

    if not properties["RequiredQuests"] then
        self.RequiredQuests = {}
    end
    if not properties["LifeCycles"] then
        self.LifeCycles = {}
    end
    if not properties["QuestObjectives"] then
        self.QuestObjectives = {}
    end
    
    self:_SetQuestProgress(QuestProgress {
        QuestObjectiveProgresses = {},
        QuestStatus = QuestStatus.NotStarted,
        CompletedCount = 0,
        FirstCompletedTick = 0,
        LastCompletedTick = 0,
    })
    self._Trove = Trove.new()
    self._Trove:Add(self.OnQuestObjectiveCompleted)
    self._Trove:Add(self.OnQuestObjectiveChanged)
    self._Trove:Add(self.OnQuestCompleted)
    self._Trove:Add(self.OnQuestDelivered)
    self._Trove:Add(self.OnQuestCanceled)

    return self
end

--[=[
    Checks if the objective with the given objectiveID has already been completed
    by the quest owner or not

    @param objectiveId string

    @return boolean
]=]
function Quest:IsObjectiveCompleted(objectiveId: string): boolean
    return self:GetObjective(objectiveId) == self:GetTargetObjective(objectiveId)
end

--[=[
    Gets the current status of the quest

    @return QuestStatus
]=]
function Quest:GetQuestStatus(): QuestStatus
    return self._QuestProgress.QuestStatus
end

--[=[
    Gets the amount of times that this quest has been completed.
    Will return 0 if it has never been completed

    @return number
]=]
function Quest:GetCompleteCount(): number
    return self._QuestProgress.CompletedCount
end

--[=[
    Gets the first UTC time that this quest was completed

    @return number
]=]
function Quest:GetFirstCompletedTick(): number
    return self._QuestProgress.FirstCompletedTick
end

--[=[
    Gets the last UTC time at which this quest was completed

    @return number
]=]
function Quest:GetLastCompletedTick(): number
    return self._QuestProgress.LastCompletedTick
end

--[=[
    Adds to the objective of the quest by the amount specified

    @param objectiveId string
    @param amount number

    @return ()
]=]
function Quest:AddObjective(objectiveId: string, amount: number): ()
    return self:SetObjective(objectiveId, self:GetObjective(objectiveId) + amount)
end

--[=[
    Removes to the objective by the amount specfiied
    
    @param objectiveId string
    @param amount number

    @return ()
]=]
function Quest:RemoveObjective(objectiveId: string, amount: number): ()
    return self:SetObjective(objectiveId, self:GetObjective(objectiveId) - amount)
end

--[=[
    Gets how long until the quest becomes available.
    It will return 0 if it is already available

    @return number
]=]
function Quest:GetTimeForAvailable(): number
    local serverTime: number = workspace:GetServerTimeNow()

    if serverTime < self:GetQuestStart() then
        return self:GetQuestStart() - serverTime
    end

    return 0
end

--[=[
    Will return how long until the quest becomes unavailable.
    It will return 0 if it is already unavailable
    
    @return number
]=]
function Quest:GetTimeForUnavailable(): number
    local serverTime: number = workspace:GetServerTimeNow()

    if serverTime < self:GetQuestEnd() then
        return self:GetQuestEnd() - serverTime
    end

    return 0
end

--[=[
    Gets the UTC time at which this quest should become available

    @return number
]=]
function Quest:GetQuestStart(): number
    return self.QuestStart
end

--[=[
    Gets the UTC time at which this quest should become disabled and no longer be available

    @return number
]=]
function Quest:GetQuestEnd(): number
    return self.QuestEnd
end

--[=[
    Sets the quest objective to the given new value

    @param objectiveId string
    @param newAmount number

    @return ()
]=]
function Quest:SetObjective(objectiveId: string, newAmount: number): ()
    local questObjective: QuestObjective? = self._QuestObjectives[objectiveId]

    if not questObjective then
        warn(string.format(NO_OBJECTIVE, objectiveId, self.Name))
        return
    end

    if questObjective:Set(newAmount) then
        self.OnQuestObjectiveChanged:Fire(objectiveId, self:GetObjective(objectiveId))
    end
end

--[=[
    Gets the time since the quest was completed

    @return number
]=]
function Quest:GetTimeSinceCompleted(): number
    return os.time() - self:GetLastCompletedTick()
end

--[=[
    Gets an objective value by its id

    @param objectiveId number

    @return number
]=]
function Quest:GetObjective(objectiveId: number): number
    local questObjective: QuestObjectiveProgress? = self:_GetObjectiveProgress(objectiveId)

    if not questObjective then
        return 0
    end
    
    return questObjective.CurrentProgress or 0
end

--[=[
    Gets the target objective by the id

    @param objectiveId string

    @return number
]=]
function Quest:GetTargetObjective(objectiveId: string): number
    local questObjective: QuestObjective = self:GetQuestObjective(objectiveId)

    if not questObjective then
        return 0
    end

    return questObjective:GetTargetProgress()
end

--[=[
    Returns a number with the amount of objectives that exist within
    this quest

    @return number
]=]
function Quest:GetQuestObjectivesCount(): number
    local counter: number = 0

    for _ in self:GetQuestObjectives() do
        counter += 1
    end

    return counter
end

--[=[
    Returns a number with the amount of **completed** objectives that exist within
    this quest
    
    @return number
]=]
function Quest:GetQuestObjectivesCompletedCount(): number
    local counter: number = 0

    for _, questObjective: QuestObjective in self:GetQuestObjectives() do
        if questObjective:IsCompleted() then
            counter += 1
        end
    end

    return counter
end

--[=[
    Returns an array of quest objectives for this given quest

    @return {[string]: QuestObjective} -- The index stands for the questId while the value stands for the QuestObjective class
]=]
function Quest:GetQuestObjectives(): {[string]: QuestObjective}
    return self._QuestObjectives
    
end

--[=[
    Gets the objective by its id

    @param objectiveId string

    @return QuestObjective?
]=]
function Quest:GetQuestObjective(objectiveId: string): QuestObjective?
    return self._QuestObjectives[objectiveId]
end

--[=[
    Sets the quest to complete if possible

    @return boolean
]=]
function Quest:Complete(): boolean
    if self:GetQuestStatus() ~= QuestStatus.InProgress then return false end

    local questProgress: QuestProgress = self:_GetQuestProgress()
    questProgress.CompletedCount += 1
    questProgress.LastCompletedTick = os.time()
    questProgress.QuestStatus = QuestStatus.Completed

    if questProgress.FirstCompletedTick < 0 then
        questProgress.FirstCompletedTick = questProgress.LastCompletedTick
    end

    self.OnQuestCompleted:Fire()

    if self.QuestDeliverType == QuestDeliverType.Automatic then
        -- The scheduler sometimes schedules the deliver before the complete, this ensures it will only schedule delivered afterwards
        task.delay(0, self.Deliver, self)
    end

    return true
end

--[=[
    Sets the quest to delivered if possible

    @return boolean
]=]
function Quest:Deliver(): boolean
    if self:GetQuestStatus() ~= QuestStatus.Completed then return false end

    self:_GetQuestProgress().QuestStatus = QuestStatus.Delivered
    self.OnQuestDelivered:Fire()
    return true
end

--[=[
    Cleans up our class

    @return ()
]=]
function Quest:Destroy(): ()
    self._Trove:Destroy()
end

--[=[
    Overrides and updates the quest progress. Should only be used when loading in
    player data

    @private
    @param newQuestProgress QuestProgress

    @return ()
]=]
function Quest:_SetQuestProgress(newQuestProgress: QuestProgress): ()
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
            self.OnQuestObjectiveCompleted:Fire(objectiveId)
            self:_CheckProgress()
        end)

        self._QuestObjectives[objectiveId] = newQuestObjective
    end

    self._QuestProgress = newQuestProgress
end

--[=[
    Wrapper to get the objective progress quickly

    @private
    @param objectiveId string

    @return QuestObjectiveProgress?
]=]
function Quest:_GetObjectiveProgress(objectiveId: string): QuestObjectiveProgress?
    local questObjective: QuestObjectiveProgress? = self._QuestProgress.QuestObjectiveProgresses[objectiveId]

    if not questObjective then
        warn(string.format(NO_OBJECTIVE, objectiveId, self.Name))
    end

    return questObjective
end

--[=[
    Wrapper to get the quest progress

    @private

    @return QuestProgress
]=]
function Quest:_GetQuestProgress(): QuestProgress
    return self._QuestProgress
end

--[=[
    Checks if the quest is completed

    @private

    @return ()
]=]
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

return setmetatable(Quest, {
    __call = function(_, properties)
        return Quest.new(properties)
    end
})