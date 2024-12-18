local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

local ObjectiveInfo = RoQuest.ObjectiveInfo

return ObjectiveInfo.new {
    Description = "%s/%s marbles collected",
    Name = "Collect Marbles",
    ObjectiveId = "Marble",
}