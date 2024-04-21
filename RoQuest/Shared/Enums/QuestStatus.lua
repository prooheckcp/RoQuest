--[=[
    @class QuestStatus
    @tag Enum

    Tracks the current status of the player's quest
]=]
local QuestStatus = {
    NotStarted = "NotStarted",
    InProgress = "InProgress",
    Completed = "Completed",
    Delivered = "Delivered",
}

--[=[
    @interface Status
    @within QuestStatus
    .NotStarted "NotStarted" -- The quest hasn't been initiated by the player
    .InProgress "InProgress" -- The quest is still in progress
    .Completed "Completed" -- The quest objectives have been fullfilled and the quest is now completed
    .Delivered "Delivered" -- Means the quest has been delivered and closed
]=]

table.freeze(QuestStatus)

export type QuestStatus = typeof(QuestStatus)

return QuestStatus 