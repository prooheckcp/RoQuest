local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

RoQuest:Init(RoQuest:LoadDirectory(ReplicatedStorage.Quests))

RoQuest.OnQuestStarted:Connect(function(player: Player, quest)
    print(player.Name, "started quest: ", quest)
    print("Player Data", RoQuest:GetPlayerData(player))
end)

RoQuest.OnQuestAvailable:Connect(function(player: Player, quest)
    print(player.Name, "available quest: ", quest)
    print("Player Data", RoQuest:GetPlayerData(player))
end)

RoQuest.OnQuestCompleted:Connect(function(player: Player, quest)
    print(player.Name, "completed quest: ", quest)
    print("Player Data", RoQuest:GetPlayerData(player))
end)

RoQuest.OnQuestDelivered:Connect(function(player: Player, quest)
    print(player.Name, "completed quest: ", quest)
    print("Player Data", RoQuest:GetPlayerData(player))
end)

RoQuest.OnQuestCancelled:Connect(function(player: Player, quest)
    print(player.Name, "completed quest: ", quest)
    print("Player Data", RoQuest:GetPlayerData(player))
end)