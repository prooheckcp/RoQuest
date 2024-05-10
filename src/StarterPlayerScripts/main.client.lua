local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Client

RoQuest:Init(RoQuest:LoadDirectory(ReplicatedStorage.LifeCycles.Client))