local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

RoQuest:Init(RoQuest:LoadDirectory(ReplicatedStorage.Quests))

RoQuest.OnStart():andThen(function()
    RoQuest.OnQuestObjectiveChanged:Connect(function()

    end)

    RoQuest.OnQuestCompleted:Connect(function()

    end)

    RoQuest.OnQuestDelivered:Connect(function()
        task.wait(1)
        print("Available: ", RoQuest._AvailableQuests)
        print("Unavailable: ", RoQuest._UnavailableQuests)
    end)
end)
