local QuestProgress = require(script.Parent.QuestProgress)
local createStruct = require(script.Parent.Parent.Functions.createStruct)

export type QuestProgress = QuestProgress.QuestProgress

local PlayerQuestData = {
    InProgress = {},
    Completed = {},
    Delivered = {},
}

export type PlayerQuestData = {
    InProgress: {[string]: QuestProgress},
    Completed: {[string]: QuestProgress},
    Delivered: {[string]: QuestProgress},
}

return createStruct(PlayerQuestData)