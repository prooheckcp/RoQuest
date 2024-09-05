local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server
local zombieObjective = require(ReplicatedStorage.ObjectiveInfos.Zombie)

local Quest = RoQuest.Quest

return Quest {
    Name = "An undead problem!", -- The name of our quest
    Description = "Kill 1 Zombie", -- The description that we will display to our user
    QuestId = "KillZombie1", -- A unique identifier to our quest
    QuestAcceptType = RoQuest.QuestAcceptType.Manual, -- If the quest automatically gets accepted or rquires manual work
    QuestDeliverType = RoQuest.QuestDeliverType.Manual, -- If the quest automatically gets delivered or requires manual work
    QuestRepeatableType = RoQuest.QuestRepeatableType.NonRepeatable, -- If the quest can be repeated or not
    QuestStart = -1, -- UTC time to define when the quest should become available (specially useful for event quests)
    QuestEnd = -1, -- UTC time to define when the quest should no longer be available (specially useful for event quests)
    RequiredQuests = {}, -- A list of quests that are required to be delivered before this quest can be started
    LifeCycles = {"ZombieQuest"}, -- The lifecycles that will manage this quest's behavior
    QuestObjectives = {
        zombieObjective:NewObjective(1)
    }, 
}