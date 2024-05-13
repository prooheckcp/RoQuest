local QuestStatus = require(script.Parent.Parent.Enums.QuestStatus)

return {
    [QuestStatus.InProgress] = "OnStart",
    [QuestStatus.Completed] = "OnComplete",
    [QuestStatus.Delivered] = "OnDeliver",
}