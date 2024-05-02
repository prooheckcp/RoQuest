local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

local TAGS: {string} = {"Flower", "Apple", "Marble"}
local RESPAWN_DELAY: number = 5

local function collectibleAdded(instance: Instance, tag: string)
    local clone: Instance = instance:Clone()
    local instanceParent: Instance = instance.Parent
    local proximityPrompt: ProximityPrompt = Instance.new("ProximityPrompt")
    proximityPrompt.ActionText = "Collect"
    proximityPrompt.ObjectText = "Collect " .. tag
    proximityPrompt.HoldDuration = 0.5
    proximityPrompt.Parent = instance:IsA("BasePart") and instance or instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")

    proximityPrompt.Triggered:Connect(function(playerWhoTriggered: Player)
        RoQuest:AddObjective(playerWhoTriggered, tag, 1)
        instance:Destroy()

        task.delay(RESPAWN_DELAY, function()
            clone.Parent = instanceParent
        end)
    end)
end

RoQuest.OnStart():andThen(function()
    for _, tag: string in TAGS do
        for _, instance: Instance in CollectionService:GetTagged(tag) do
            collectibleAdded(instance, tag)
        end

        CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance: Instance)
            collectibleAdded(instance, tag)
        end)    
    end
end)

