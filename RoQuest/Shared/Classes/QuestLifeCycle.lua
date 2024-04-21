--!strict

--TO DO
local QuestLifeCycle = {}
QuestLifeCycle.__index = QuestLifeCycle

function QuestLifeCycle.new()
    local self = setmetatable({}, QuestLifeCycle)

    return self
end

export type QuestLifeCycle = typeof(QuestLifeCycle)

return QuestLifeCycle