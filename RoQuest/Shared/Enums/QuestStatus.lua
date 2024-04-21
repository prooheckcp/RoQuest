local QuestStatus = {
    NotStarted = "NotStarted",
    InProgress = "InProgress",
    Completed = "Completed",
    Delivered = "Delivered",
}

table.freeze(QuestStatus)

export type QuestStatus = typeof(QuestStatus)

return QuestStatus 