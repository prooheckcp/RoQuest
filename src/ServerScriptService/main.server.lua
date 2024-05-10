local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

RoQuest:Init(
    RoQuest:LoadDirectory(ReplicatedStorage.Quests), 
    RoQuest:LoadDirectory(ReplicatedStorage.LifeCycles.Server)
)