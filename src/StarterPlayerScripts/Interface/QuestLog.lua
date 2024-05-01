local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RoQuest = require(ReplicatedStorage.RoQuest).Client

type Quest = RoQuest.Quest

local DEFAULT_COLOR: Color3 = Color3.fromRGB(140, 140, 140)
local ACTIVE_COLOR: Color3 = Color3.fromRGB(255, 255, 127)

local localPlayer: Player = Players.LocalPlayer
local playerGui: PlayerGui = localPlayer:WaitForChild("PlayerGui")
local questLog: ScreenGui = playerGui:WaitForChild("QuestLog")
local template: Frame = questLog.Container.Unavailable.Template:Clone()
questLog.Container.Unavailable.Template:Destroy() -- Delete the template after we cached a clone

local QuestLog = {}
QuestLog.screens = {} :: {[string]: ScrollingFrame}
QuestLog.buttons = {} :: {[string]: GuiButton}
QuestLog.currentScreen = "" :: string

function QuestLog:UpdateButtonColor()
    for buttonName: string, button: GuiButton in self.buttons do
        button.BackgroundColor3 = buttonName == self.currentScreen and ACTIVE_COLOR or DEFAULT_COLOR
    end
end

function QuestLog:SetScreen(name: string)
    if self.currentScreen == name then
        return
    end

    local currentScrollingFrame: ScrollingFrame? = self.screens[self.currentScreen]
    local newScrollingFrame: ScrollingFrame? = self.screens[name]

    if currentScrollingFrame then
        currentScrollingFrame.Visible = false
    end

    if newScrollingFrame then
        newScrollingFrame.Visible = true
    end

    self.currentScreen = name
    self:UpdateButtonColor()
end

function QuestLog:SetupButtons()
    for _, button: Instance in questLog.Container.Buttons:GetChildren() do
        if not button:IsA("GuiButton") then
            continue
        end

        (button :: GuiButton).Activated:Connect(function()
            self:SetScreen(button.Name)
        end)

        self.buttons[button.Name] = button
    end
end

function QuestLog:SetupWindows()
    for _, child: Instance in questLog.Container:GetChildren() do
        if not child:IsA("ScrollingFrame") then
            continue
        end

        self.screens[child.Name] = child
    end
end

function QuestLog:DestroyQuest(scrollingFrame: ScrollingFrame, questId: string)
    local frame: Frame? = scrollingFrame:FindFirstChild(questId)

    if frame then
        frame:Destroy()
    end
end

function QuestLog:CreateQuest(scrollingFrame: ScrollingFrame, quest: Quest)
    local frame: Frame = scrollingFrame:FindFirstChild(quest.QuestId) or template:Clone()
    frame.Name = quest.QuestId
    frame.Title.Text = quest.Name
    frame.Description.Text = quest.Description
    frame.Buttons.Cancel.Visible = quest:GetQuestStatus() == RoQuest.QuestStatus.InProgress

    frame.Visible = true
    frame.Parent = scrollingFrame
end

function QuestLog:PopulateScreen(scrollingFrame: ScrollingFrame, quests: {[string]: Quest})
    for _, child: Instance in scrollingFrame:GetChildren() do -- Remove quests no longer in use
        if not child:IsA("Frame") then
           continue
        end

        if not quests[child.Name] then
            child:Destroy()
        end
    end

    for _, quest: Quest in quests do
        self:CreateQuest(scrollingFrame, quest)
    end
end

function QuestLog:SetAllScreens()
    self:PopulateScreen(self.screens["InProgress"], RoQuest:GetInProgressQuests())
    self:PopulateScreen(self.screens["Available"], RoQuest:GetAvailableQuests())
    self:PopulateScreen(self.screens["Completed"], RoQuest:GetCompletedQuests())
    self:PopulateScreen(self.screens["Delivered"], RoQuest:GetDeliveredQuests())
    self:PopulateScreen(self.screens["Unavailable"], RoQuest:GetUnAvailableQuests())
end

function QuestLog:Init()
    self:SetupWindows() -- Caching our windows
    self:SetupButtons() -- Caching our buttons
    self:SetScreen("InProgress") -- Setting the initial active screen
    self:SetAllScreens() -- Populating all screens

    RoQuest.OnUnAvailableQuestChanged:Connect(function()
        self:PopulateScreen(self.screens["Unavailable"], RoQuest:GetUnAvailableQuests())
    end)

    RoQuest.OnAvailableQuestChanged:Connect(function()
        self:PopulateScreen(self.screens["Available"], RoQuest:GetAvailableQuests())
    end)

    RoQuest.OnCompletedQuestChanged:Connect(function()
        self:PopulateScreen(self.screens["Completed"], RoQuest:GetCompletedQuests())
    end)
    
    RoQuest.OnDeliveredQuestChanged:Connect(function()
        self:PopulateScreen(self.screens["Delivered"], RoQuest:GetDeliveredQuests())
    end)

    RoQuest.OnInProgressQuestChanged:Connect(function()
        self:PopulateScreen(self.screens["InProgress"], RoQuest:GetInProgressQuests())
    end)
    
    RoQuest.OnPlayerDataChanged:Connect(function()
        self:SetAllScreens()
    end) -- Hard reset our screens    
end

return QuestLog