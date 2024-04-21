local QuestRepeatableType = {
    NonReatable = "NonReatable",
    Daily = "Daily",
    Weekly = "Weekly",
    Custom = "Custom",
}

table.freeze(QuestRepeatableType)

export type QuestRepeatableType = typeof(QuestRepeatableType)

return QuestRepeatableType 