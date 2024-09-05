local createStruct = require(script.Parent.Parent.Functions.createStruct)

--[=[
    @class QuestObjectiveProgress
    @tag Struct

    ```csharp
    struct QuestObjectiveProgress {
        CurrentProgress: number,
        Completed: boolean
    }
    ```
]=]
local QuestObjectiveProgress = {
    CurrentProgress = 0,
    Completed = false,
}

--[=[
    Contains the data for the current progress of this objective

    @prop CurrentProgress number
    @within QuestObjectiveProgress
]=]

--[=[
    A flat to determine is the objective is complete or not

    @prop Completed boolean
    @within QuestObjectiveProgress
]=]

export type QuestObjectiveProgress = typeof(QuestObjectiveProgress)

return createStruct(QuestObjectiveProgress)