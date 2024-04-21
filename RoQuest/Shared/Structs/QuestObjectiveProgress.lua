local createStruct = require(script.Parent.Parent.Functions.createStruct)

local QuestObjectiveProgress = {
    CurrentProgress = 0,
    Completed = false,
}

export type QuestObjectiveProgress = typeof(QuestObjectiveProgress)

return createStruct(QuestObjectiveProgress)