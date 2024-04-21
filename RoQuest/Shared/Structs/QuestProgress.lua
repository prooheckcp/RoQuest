local QuestStatus = require(script.Parent.Parent.Enums.QuestStatus)
local createStruct = require(script.Parent.Parent.Functions.createStruct)
local QuestObjectiveProgress = require(script.Parent.QuestObjectiveProgress)

type QuestStatus = QuestStatus.QuestStatus
type QuestObjectiveProgress = QuestObjectiveProgress.QuestObjectiveProgress

local QuestProgress = {
    QuestObjectiveProgresses = {},
    QuestStatus = QuestStatus.NotStarted,
    CompletedCount = 0,
    FirstCompletedTick = -1,
    LastCompletedTick = -1,
}

export type QuestProgress = {
    QuestObjectiveProgresses: {[string]: QuestObjectiveProgress},
    QuestStatus: QuestStatus,
    CompletedCount: number,
    FirstCompletedTick: number,
    LastCompletedTick: number,
}

return createStruct(QuestProgress)