local QuestRepeatableType = require(script.Parent.Parent.Enums.QuestRepeatableType)

local function hoursToSeconds(hours: number): number
    return hours * 3600
end

return {
    [QuestRepeatableType.Custom] = 0,
    [QuestRepeatableType.Daily] = hoursToSeconds(23),
    [QuestRepeatableType.Weekly] = hoursToSeconds(167),
    [QuestRepeatableType.Infinite] = 0,
    [QuestRepeatableType.NonRepeatable] = 0,
}