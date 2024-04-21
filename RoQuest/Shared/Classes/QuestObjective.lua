--!strict
local QuestObjectiveProgress = require(script.Parent.Parent.Structs.QuestObjectiveProgress)
local assertProperties = require(script.Parent.Parent.Functions.assertProperties)

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

    A quest objective is one of the steps that a player must complete in order to finish a quest

    It contains the data for the objective as well as some utility functions to allow us to 
    manipulate the objective
]=]
local QuestObjective = {}
QuestObjective.__type = "QuestObjective"
QuestObjective.__index = QuestObjective
QuestObjective.ObjectiveInfo = newproxy()
QuestObjective.TargetProgress = 0 :: number
QuestObjective._QuestObjectiveProgress = newproxy() :: QuestObjectiveProgress

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
    return assertProperties(properties, QuestObjective)
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

export type QuestObjective = typeof(QuestObjective)

return QuestObjective