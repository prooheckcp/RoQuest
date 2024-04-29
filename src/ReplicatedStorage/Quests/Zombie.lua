local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server
local zombieObjective = require(ReplicatedStorage.ObjectiveInfos.Zombie)

local Quest = RoQuest.Quest

return Quest {
    Name = "Collect Flowers", -- The name of our quest
    Description = "Collect 5 flowers", -- The description that we will display to our user
    QuestId = "FlowerCollection", -- A unique identifier to our quest
    QuestAcceptType = RoQuest.QuestAcceptType.Manual, -- If the quest automatically gets accepted or rquires manual work
    QuestDeliverType = RoQuest.QuestDeliverType.Automatic, -- If the quest automatically gets delivered or requires manual work
    QuestRepeatableType = RoQuest.QuestRepeatableType.NonRepeatable, -- If the quest can be repeated or not
    QuestStart = -1, -- UTC time to define when the quest should become available (specially useful for event quests)
    QuestEnd = -1, -- UTC time to define when the quest should no longer be available (specially useful for event quests)
    RequiredQuests = {}, -- A list of quests that are required to be delivered before this quest can be started
    LifeCycles = {"AppleQuest"}, -- The lifecycles that will manage this quest's behavior
    QuestObjectives = {
        zombieObjective:NewObjective(4)
    }, 
}