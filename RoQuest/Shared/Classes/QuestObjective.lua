--!strict
local QuestObjectiveProgress = require(script.Parent.Parent.Structs.QuestObjectiveProgress)
local assertProperties = require(script.Parent.Parent.Functions.assertProperties)
local Signal = require(script.Parent.Parent.Parent.Vendor.Signal)
local Trove = require(script.Parent.Parent.Parent.Vendor.Trove)

type Signal = Signal.Signal
type Trove = Trove.Trove
type QuestObjectiveProgress = QuestObjectiveProgress.QuestObjectiveProgress
type ObjectiveInfo = {
    New: ({[string]: any}) -> ObjectiveInfo,
    NewObjective: (self: ObjectiveInfo, target: number) -> (),

    ObjectiveId: string | {string},
    Name: string,
    Description: string,
}

--[=[
    @class QuestObjective
    @tag Class

    A quest objective is one of the steps that a player must complete in order to finish a quest

    It contains the data for the objective as well as some utility functions to allow us to 
    manipulate the objective.

    This class shouldn't be created directly by the developer. Instead they should use the Objective
    info object and extend it with the NewObjective function.

    ```lua
    local appleQuest = ObjectiveInfo.new {
        ObjectiveId = "CollectApples",
        Name = "Collect Apples",
        Description = "Collect %s apples",
    }

    local objective1 = appleQuest:NewObjective(5) -- Created an objective to collect 5 apples
    local objective2 = appleQuest:NewObjective(3) -- Created an objective to collect 3 apples
    local objective3 = appleQuest:NewObjective(7) -- Created an objective to collect 7 apples
    ```
]=]
local QuestObjective = {}
QuestObjective.__type = "QuestObjective"
QuestObjective.__index = QuestObjective
--[=[
    A reference to the ObjectiveInfo object that this QuestObjective is based on

    @prop ObjectiveInfo ObjectiveInfo
    @within QuestObjective
]=]
QuestObjective.ObjectiveInfo = newproxy()
--[=[
    The target progress required for the player complete this objective

    @prop TargetProgress number
    @within QuestObjective
]=]
QuestObjective.TargetProgress = 0 :: number
--[=[
    A Signal that fires whenever the quest objective is marked as completed

    ```lua
    local flowerQuest = ObjectiveInfo.new {
        ObjectiveId = "CollectFlowers",
        Name = "Collect Flowers",
        Description = "Collect %s flowers",
    }

    local appleObjective1 = appleQuest:NewObjective(5) -- Created an objective to collect 5 apples

    appleObjective1.Completed:Connect(function()
        print("Objective 1 has been completed!")
    end)
    ```

    @prop Completed Signal
    @within QuestObjective
]=]
QuestObjective.Completed = newproxy() :: Signal
--[=[
    A reference to our QuestObjectiveProgress to track the dynamic data of our objective

    @private

    @prop _QuestObjectiveProgress QuestObjectiveProgress
    @within QuestObjective
]=]
QuestObjective._QuestObjectiveProgress = newproxy() :: QuestObjectiveProgress
--[=[
    The Trove object from our QuestObjective that allows us to clearup the object

    @private

    @prop _Trove Trove
    @within QuestObjective
]=]
QuestObjective._Trove = newproxy() :: Trove

--[=[
    Constructor for QuestObjective

    ```lua
    QuestObjective.new {
        TargetProgress = 10, -- Creates a new objective with a target progress of 10
    }
    ```

    @param properties {[string]: any}

    @return QuestObjective
]=]
function QuestObjective.new(properties: {[string]: any}): QuestObjective
    local self: QuestObjective = assertProperties(properties, QuestObjective)
    self.Completed = Signal.new()
    self._Trove = Trove.new()
    self._QuestObjectiveProgress = QuestObjectiveProgress {
        CurrentProgress = 0,
        Completed = false,
    }

    return self
end

--[=[
    Gets the current target progress of our objective

    ```lua
     print(QuestObjective:Get()) -- 0
    QuestObjective:Set(5)
    print(QuestObjective:Get()) -- 5
    ```

    @return number
]=]
function QuestObjective:Get(): number
    return self._QuestObjectiveProgress.CurrentProgress
end

--[=[
    Adds an amount to the current progress of the objective

    ```lua
     print(QuestObjective:Get()) -- 0
    QuestObjective:Add(1)
    print(QuestObjective:Get()) -- 1
    ```

    @param amount number

    @return boolean
]=]
function QuestObjective:Add(amount: number): boolean
    if self:IsCompleted() then return false end -- No point on updating

    return self:Set(self:Get() + amount)
end

--[=[
    Removes an amount to the current progress of the objective

    ```lua
     print(QuestObjective:Get()) -- 1
    QuestObjective:Remove(1)
    print(QuestObjective:Get()) -- 0
    ```

    @param amount number

    @return boolean
]=]
function QuestObjective:Remove(amount: number): boolean
    if self:IsCompleted() then return false end -- No point on updating

    return self:Set(self:Get() - amount)
end

--[=[
    Sets the current progress amount of our objective

    ```lua
     print(QuestObjective:Get()) -- 0
    QuestObjective:Set(1)
    print(QuestObjective:Get()) -- 1
    QuestObjective:Set(5)
    print(QuestObjective:Get()) -- 5
    ```

    @param newAmount number

    @return boolean
]=]
function QuestObjective:Set(newAmount: number): boolean
    if self:IsCompleted() then return false end -- No point on updating
    if self:Get() == newAmount then return false end -- Same value

    self._QuestObjectiveProgress.CurrentProgress = newAmount

    if newAmount > self.TargetProgress then
        self._QuestObjectiveProgress.Completed = true
        self.Completed:Fire()
    end

    return true
end

--[=[
    Checks if the quest has already been completed or not

    ```lua
    print(QuestObjective:IsCompleted()) -- false
    QuestObjective:Set(5)
     print(QuestObjective:IsCompleted()) -- true
    ```

    @return boolean
]=]
function QuestObjective:IsCompleted(): boolean
    return self._QuestObjectiveProgress.Completed
end

--[=[
    Destroys the QuestObjective and clears up the object

    ```lua
    QuestObjective:Destroy()
    ```

    @return ()
]=]
function QuestObjective:Destroy(): ()
    self._Trove:Destroy()
end

export type QuestObjective = typeof(QuestObjective)

return QuestObjective