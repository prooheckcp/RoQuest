local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

type QuestLifeCycle = RoQuest.QuestLifeCycle

local QuestLifeCycle = RoQuest.QuestLifeCycle

local CornQuest: QuestLifeCycle = QuestLifeCycle {
    Name = "CornQuest",
}

return CornQuest