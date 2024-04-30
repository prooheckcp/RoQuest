local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

RoQuest:Init(RoQuest:LoadDirectory(ReplicatedStorage.Quests))

RoQuest.OnStart():andThen(function()
    RoQuest.OnQuestObjectiveChanged:Connect(function()

    end)

    RoQuest.OnQuestStarted:Connect(function()

    end)

    RoQuest.OnQuestCompleted:Connect(function()

    end)
end)
