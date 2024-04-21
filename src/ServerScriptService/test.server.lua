local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server
local QuestObjective = require(ReplicatedStorage.RoQuest.Shared.Classes.QuestObjective)

QuestObjective.new {
    Name = "Test",
    Description = "Test",
    Test = "uwu",
}