local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Client

RoQuest.OnStart():andThen(function()
    for _, moduleScript: ModuleScript in script:GetChildren() do
        require(moduleScript):Init()
    end
end)
