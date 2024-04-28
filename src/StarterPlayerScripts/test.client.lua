local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Client

RoQuest.OnPlayerDataChanged:Connect(function(playerQuestData)
    print("Player data changed", playerQuestData)
end)

RoQuest:Init()