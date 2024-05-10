local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

RoQuest:Init(
    RoQuest:LoadDirectory(ReplicatedStorage.Quests), 
    RoQuest:LoadDirectory(ReplicatedStorage.LifeCycles.Server)
)

RoQuest.OnQuestStarted:Connect(function(player, quest)
    print(player.Name .. " started quest: " .. quest)
end)