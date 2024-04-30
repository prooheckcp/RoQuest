local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server
local flowerObjective = require(ReplicatedStorage.ObjectiveInfos.Flower)

local Quest = RoQuest.Quest

return Quest {
    Name = "Collect Flowers", -- The name of our quest
    Description = "Collect 3 flowers", -- The description that we will display to our user
    QuestId = "FlowerEvent", -- A unique identifier to our quest
    QuestAcceptType = RoQuest.QuestAcceptType.Automatic, -- If the quest automatically gets accepted or rquires manual work
    QuestDeliverType = RoQuest.QuestDeliverType.Automatic, -- If the quest automatically gets delivered or requires manual work
    QuestRepeatableType = RoQuest.QuestRepeatableType.NonRepeatable, -- If the quest can be repeated or not
    QuestStart = os.time() + 10, -- UTC time to define when the quest should become available (specially useful for event quests)
    QuestEnd = os.time() + 15, -- UTC time to define when the quest should no longer be available (specially useful for event quests)
    RequiredQuests = {}, -- A list of quests that are required to be delivered before this quest can be started
    LifeCycles = {"FlowerQuest"}, -- The lifecycles that will manage this quest's behavior
    QuestObjectives = {
        flowerObjective:NewObjective(3)
    }, 
}