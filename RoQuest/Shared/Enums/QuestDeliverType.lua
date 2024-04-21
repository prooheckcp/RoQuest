local QuestDeliverType = {
    Automatic = "Automatic",
    Manual = "Manual",
}

table.freeze(QuestDeliverType)

export type QuestDeliverType = typeof(QuestDeliverType)

return QuestDeliverType 