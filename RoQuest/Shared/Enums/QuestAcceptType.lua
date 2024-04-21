--[=[
    @class QuestAcceptType
    @tag Enum

    Sets if the quest should be accepted automatically or manually
]=]
local QuestAcceptType = {
    Automatic = "Automatic",
    Manual = "Manual",
}

--[=[
    @interface Status
    @within QuestAcceptType
    .Automatic "Automatic" -- The quest will automatically be accepted when the player meets the requirements
    .Manual "Manual" -- The quest will be accepted when the player manually accepts it
]=]

table.freeze(QuestAcceptType)

export type QuestAcceptType = typeof(QuestAcceptType)

return QuestAcceptType 