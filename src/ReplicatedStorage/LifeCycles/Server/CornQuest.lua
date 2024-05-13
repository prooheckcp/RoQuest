local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

type QuestLifeCycle = RoQuest.QuestLifeCycle

local QuestLifeCycle = RoQuest.QuestLifeCycle

local CornQuest: QuestLifeCycle = QuestLifeCycle {
    Name = "CornQuest",
}

function CornQuest:OnInit()
    
end

function CornQuest:OnStart()
    task.delay(1, function()
        print("Delayed set!")
        --self.Quest:AddObjective("Corn", 100)
    end)
end

function CornQuest:OnComplete()
    print("Completed corn!")
end

function CornQuest:OnDeliver()
    print("OnDeliver")
end

return CornQuest