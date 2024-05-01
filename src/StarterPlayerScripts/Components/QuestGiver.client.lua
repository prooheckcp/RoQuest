local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local RoQuest = require(ReplicatedStorage.RoQuest).Client
local Hud = require(script.Parent.Parent.Interface.Hud)
local Prompt = require(script.Parent.Parent.Interface.Prompt)

local TAG: string = "QuestGiver"

local function questGiverAdded(instance: Instance)
    local questId: string = instance:GetAttribute("QuestId")
    local clickDetector: ClickDetector = Instance.new("ClickDetector")
    local highlight: Highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.85
    highlight.Adornee = instance
    highlight.Enabled = false

    clickDetector.MouseHoverEnter:Connect(function()
        highlight.Enabled = true
    end)

    clickDetector.MouseHoverLeave:Connect(function()
        highlight.Enabled = false
    end)

    clickDetector.MouseClick:Connect(function()
        if not RoQuest:CanGiveQuest(questId) then
            return
        end
        
        Prompt:SetQuest(questId)
        Hud:EnableScreen("QuestPrompt")
    end)

    clickDetector.Parent = instance
    highlight.Parent = instance
end

RoQuest.OnStart():andThen(function()
    for _, instance: Instance in CollectionService:GetTagged(TAG) do
        questGiverAdded(instance)
    end

    CollectionService:GetInstanceAddedSignal(TAG):Connect(function(instance: Instance)
        questGiverAdded(instance)
    end)    
end)