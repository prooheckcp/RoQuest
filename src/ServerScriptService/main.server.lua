local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

RoQuest:Init(RoQuest:LoadDirectory(ReplicatedStorage.Quests))

RoQuest.OnStart():andThen(function()
    RoQuest.OnQuestStarted:Connect(function(player: Player, questId: string)
        print("Quest Started:", player, questId)
    end)

    RoQuest.OnQuestAvailable:Connect(function(player: Player, questId: string)
        print("Quest Available: ", player, questId)
    end)

    RoQuest.OnQuestUnavailable:Connect(function(player: Player, questId: string)
        print("Quest Unavailable: ", player, questId)
    end)
end)
