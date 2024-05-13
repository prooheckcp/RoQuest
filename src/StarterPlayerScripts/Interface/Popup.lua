local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local RoQuest = require(ReplicatedStorage.RoQuest).Client

type Quest = RoQuest.Quest

local localPlayer: Player = Players.LocalPlayer
local playerGui: PlayerGui = localPlayer:WaitForChild("PlayerGui")
local popups: ScreenGui = playerGui:WaitForChild("Popups")
local questTemplate = popups:WaitForChild("QuestCompleted"):Clone()
popups.QuestCompleted:Destroy()

local Popup = {}

function Popup:Completed(quest: Quest)
    SoundService:WaitForChild("QuestComplete"):Play()

    local newQuest: Frame = questTemplate:Clone()
    local questNamePosition: UDim2 = newQuest.QuestName.Position
    local initialSize: UDim2 = newQuest.Size
    newQuest.Size = UDim2.fromScale(0, 0)
    newQuest.QuestName.Text = quest.Name
    newQuest.QuestName.Position = UDim2.fromScale(0, 1)

    newQuest.Parent = popups

    local frameTween: Tween = TweenService:Create(newQuest, TweenInfo.new(0.5), {Size = initialSize})
    frameTween:Play()
    frameTween.Completed:Wait()

    local textTween: Tween = TweenService:Create(newQuest.QuestName, TweenInfo.new(0.75), {Position = questNamePosition})
    textTween:Play()
    textTween.Completed:Wait()

    task.wait(2)

    local frameTween2: Tween = TweenService:Create(newQuest, TweenInfo.new(0.5), {Size = UDim2.fromScale(0, 0)})
    frameTween2:Play()
    frameTween2.Completed:Wait()

    newQuest:Destroy()
end

function Popup:Init()
    RoQuest.OnQuestCompleted:Connect(function(questId: string)
        self:Completed(RoQuest:GetStaticQuest(questId))
    end)

    RoQuest.OnQuestObjectiveChanged:Connect(function()
        SoundService:WaitForChild("Collect"):Play()
    end)
end

return Popup