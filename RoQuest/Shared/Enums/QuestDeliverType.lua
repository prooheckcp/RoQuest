--[=[
    @class QuestDeliverType
    @tag Enum

    Sets if the quest should be delivered automatically or manually
]=]
local QuestDeliverType = {
    Automatic = "Automatic",
    Manual = "Manual",
}

--[=[
    @interface Status
    @within QuestDeliverType
    .Automatic "Automatic" -- The quest will automatically be delivered when completed
    .Manual "Manual" -- It requires to be manually delivered by the developer
]=]

table.freeze(QuestDeliverType)

export type QuestDeliverType = typeof(QuestDeliverType)

return QuestDeliverType 