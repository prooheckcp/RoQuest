local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server
local Red = require(ReplicatedStorage.RoQuest.Vendor.Red).Server

RoQuest.OnStart():andThen(function()
    local Net = Red "QuestManager"

    Net:On("AcceptQuest", function(player: Player, questId: string)
        print("Accept quest: ", player, questId)
        RoQuest:GiveQuest(player, questId)
    end)
end)