local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

RoQuest:Init(RoQuest:LoadDirectory(ReplicatedStorage.Quests))

RoQuest.OnQuestStarted:Connect(function(player: Player, quest)
    print(player.Name, "started quest: ", quest)
end)