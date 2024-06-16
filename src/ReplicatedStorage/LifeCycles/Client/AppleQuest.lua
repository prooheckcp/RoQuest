local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Client

type QuestLifeCycle = RoQuest.QuestLifeCycle

local QuestLifeCycle = RoQuest.QuestLifeCycle

local AppleQuest = QuestLifeCycle {
    Name = "AppleQuest",
}

function AppleQuest:OnStart()
   -- print("Apple On Start")
end

function AppleQuest:OnComplete()
   -- print("Apple On Complete")
end

function AppleQuest:OnObjectiveChange(...)
   -- print(...)
end

function AppleQuest:OnDeliver()
   -- print("Apple On Deliver")
end

function AppleQuest:OnDestroy()
    --print("Apple On Destroy")
end

return AppleQuest