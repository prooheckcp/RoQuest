local QuestAcceptType = {
    Automatic = "Automatic",
    Manual = "Manual",
}

table.freeze(QuestAcceptType)

export type QuestAcceptType = typeof(QuestAcceptType)

return QuestAcceptType 