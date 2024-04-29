local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

RoQuest:Init(RoQuest:LoadDirectory(ReplicatedStorage.Quests))

RoQuest.OnStart():andThen(function()
    RoQuest.OnQuestObjectiveChanged:Connect(function(...)
        --print(...)
    end)

    RoQuest.OnQuestStarted:Connect(function(...)
        print("QUEST STARTED LEZGOOO", ...)
    end)

    RoQuest.OnQuestCompleted:Connect(function(...)
        print("QUEST COMPLETED LEZGOOOOOOO", ...)
    end)
end)
