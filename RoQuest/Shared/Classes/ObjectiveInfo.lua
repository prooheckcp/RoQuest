--!strict
local QuestObjective = require(script.Parent.QuestObjective)

export type QuestObjective = typeof(QuestObjective)

--[[
    @class ObjectiveInfo


]]
local ObjectiveInfo = {}
ObjectiveInfo.__index = ObjectiveInfo
ObjectiveInfo.__type = "ObjectiveInfo"

function ObjectiveInfo.new()
    local self = setmetatable({}, ObjectiveInfo)

    return self
end

function ObjectiveInfo:NewObjective(target: number): QuestObjective
    return QuestObjective.new {
        TargetProgress = target,
        ObjectiveInfo = self,
    }
end

export type ObjectiveInfo = typeof(ObjectiveInfo)

return ObjectiveInfo