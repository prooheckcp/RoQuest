local Quest = require(script.Parent.Parent.Classes.Quest)

type Quest = Quest.Quest

local REPLICATE_PROPERTIES: {[string]: true} = {
    Name = true,
    Description = true,
    QuestId = true,
    QuestAcceptType = true,
    QuestDeliverType = true,
    QuestRepeatableType = true,
    QuestStart = true,
    QuestEnd = true,
    RequiredQuests = true,
    LifeCycles = true,
    QuestObjectives = true,
}

local function networkQuestParser(quest: Quest): any
    local parsedData: {[string]: any} = {}

    for propertyIndex: string in REPLICATE_PROPERTIES do
        parsedData[propertyIndex] = quest[propertyIndex]
    end

    return parsedData
end

return networkQuestParser