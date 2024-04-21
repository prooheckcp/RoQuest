--!strict
local QuestObjective = require(script.Parent.QuestObjective)
local assertProperties = require(script.Parent.Parent.Functions.assertProperties)

export type QuestObjective = typeof(QuestObjective)

--[=[
    @class ObjectiveInfo
    @tag Class

    The ObjectiveInfo contains the static data for our quest objectives. This is where the developer
    should initiate the data for the objective as long as create the QuestObjective objects.

    ```lua
    local appleQuest = ObjectiveInfo.new {
        ObjectiveId = "CollectApples",
        Name = "Collect Apples",
        Description = "Collect %s apples",
    }

    local flowerQuest = ObjectiveInfo.new {
        ObjectiveId = "CollectFlowers",
        Name = "Collect Flowers",
        Description = "Collect %s flowers",
    }

    local appleObjective1 = appleQuest:NewObjective(5) -- Created an objective to collect 5 apples
    local appleObjective2 = appleQuest:NewObjective(3) -- Created an objective to collect 3 apples
    local appleObjective3 = appleQuest:NewObjective(7) -- Created an objective to collect 7 apples

    local flowerObjective1 = flowerQuest:NewObjective(5) -- Created an objective to collect 5 flowers
    local flowerObjective2 = flowerQuest:NewObjective(3) -- Created an objective to collect 3 flowers
    local flowerObjective3 = flowerQuest:NewObjective(7) -- Created an objective to collect 7 flowers
    ```
]=]
local ObjectiveInfo = {}
ObjectiveInfo.__index = ObjectiveInfo
ObjectiveInfo.__type = "ObjectiveInfo"
--[=[
    This is an ID to represent the objective. Should be used to identify the objective in the code.
    
    When we tell the server that player did X objective this is how it will determine if it should add or not to this objective.

    @prop ObjectiveId string
    @within ObjectiveInfo
]=]
ObjectiveInfo.ObjectiveId = "" :: string 
--[=[
    The name of our objective. Can be used by the player or server to display the name of the objective
    that the player must complete

    @prop Name string
    @within ObjectiveInfo
]=]
ObjectiveInfo.Name = "" :: string
--[=[
    A more detailed description of our objective. Can be used by the developer to display the description

    @prop Description string
    @within ObjectiveInfo
]=]
ObjectiveInfo.Description = "" :: string

--[=[
    Constructor for ObjectiveInfo

    ```lua
    local appleQuest = ObjectiveInfo.new {
        ObjectiveId = "CollectApples",
        Name = "Collect Apples",
        Description = "Collect %s apples",
    }
    ```

    @param properties {[string]: any}

    @return ObjectiveInfo
]=]
function ObjectiveInfo.new(properties: {[string]: any}): ObjectiveInfo
    return assertProperties(properties, ObjectiveInfo)
end

--[=[
    Extends the Objective Info into a Quest Objective which is what we feed into our
    Quests

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

    @return number
]=]
function ObjectiveInfo:NewObjective(target: number): QuestObjective
    return QuestObjective.new {
        TargetProgress = target,
        ObjectiveInfo = self,
    }
end

export type ObjectiveInfo = typeof(ObjectiveInfo)

return ObjectiveInfo