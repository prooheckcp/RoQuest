--!strict
--[=[
    @class QuestRepeatableType
    @tag Enum

    Sets how often and if it is possible to repeat a quest
]=]
local QuestRepeatableType = {
    NonRepeatable = "NonRepeatable",
    Daily = "Daily",
    Weekly = "Weekly",
    Custom = "Custom",
}

--[=[
    @interface Status
    @within QuestRepeatableType
    .NonRepeatable "NonRepeatable" -- The quest can only be completed once
    .Daily "Daily" -- Quest can be completed everyday
    .Weekly "Weekly" -- Quest can be completed weekly
    .Custom "Custom" -- Quest can only be completed when the developer sets it to be
]=]

table.freeze(QuestRepeatableType)

export type QuestRepeatableType = typeof(QuestRepeatableType)

return QuestRepeatableType 