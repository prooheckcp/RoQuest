local QuestStatus = require(script.Parent.Parent.Enums.QuestStatus)
local createStruct = require(script.Parent.Parent.Functions.createStruct)
local QuestObjectiveProgress = require(script.Parent.QuestObjectiveProgress)

type QuestStatus = QuestStatus.QuestStatus
type QuestObjectiveProgress = QuestObjectiveProgress.QuestObjectiveProgress

--[=[
    @class QuestProgress
    @tag Struct

    ```csharp
    struct PlayerQuestData {
        QuestObjectiveProgresses: {[string]: QuestObjectiveProgress},
        QuestStatus: QuestStatus,
        CompletedCount: number,
        FirstCompletedTick: number,
        LastCompletedTick: number,
    }
    ```
]=]
local QuestProgress = {
    QuestObjectiveProgresses = {},
    QuestStatus = QuestStatus.NotStarted,
    CompletedCount = 0,
    FirstCompletedTick = -1,
    LastCompletedTick = -1,
}

--[=[
    A hashmap containing all the quest progress objectives of our quest

    @prop QuestObjectiveProgresses {[string]: QuestObjectiveProgress}
    @within QuestProgress
]=]

--[=[
    The current status of the quest. Wheter it is in progress, completed or delivered

    @prop QuestStatus QuestStatus
    @within QuestProgress
]=]

--[=[
    The amount of times this quest has been completed

    @prop CompletedCount number
    @within QuestProgress
]=]

--[=[
    The time date at which the quest was first completed

    @prop FirstCompletedTick number
    @within QuestProgress
]=]

--[=[
    The time date at which the quest was last completed

    @prop LastCompletedTick number
    @within QuestProgress
]=]

export type QuestProgress = {
    QuestObjectiveProgresses: {[string]: QuestObjectiveProgress},
    QuestStatus: QuestStatus,
    CompletedCount: number,
    FirstCompletedTick: number,
    LastCompletedTick: number,
}

return createStruct(QuestProgress)