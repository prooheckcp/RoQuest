local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

type QuestLifeCycle = RoQuest.QuestLifeCycle

local QuestLifeCycle = RoQuest.QuestLifeCycle

local ZombieQuest = QuestLifeCycle {
    Name = "AppleQuest",
}

function ZombieQuest:FirstStart()
    print("Zombie First Start")
end

function ZombieQuest:AllComplete()
    print("Zomie All Complete")
end

function ZombieQuest:OnStart()
    print("Zombie On Start")
end

function ZombieQuest:OnComplete()
    print("Zombie On Complete")
end

function ZombieQuest:OnObjectiveChange(...)
    print(...)
end

function ZombieQuest:OnDeliver()
    print("Zombie On Deliver")
end

function ZombieQuest:OnDestroy()
    print("Zombie On Destroy")
end

return ZombieQuest