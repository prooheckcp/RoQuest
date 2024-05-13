---
sidebar_position: 2
sidebar_label: "📜 Making a Quest Log"
---

# 📜 Making a Quest Log

For the quest log let's create 2 local scripts. One for the HUD and nother one for the quest log! Feel free to copy paste the example.

## 👀 Example

```lua
--Hud.lua
--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Client

local localPlayer: Player = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local questLog = playerGui:WaitForChild("QuestLog")
local hud = playerGui:WaitForChild("HUD")

local screens = {
	QuestLog = questLog.Container,
}

local Hud = {}
Hud.currentScreen = ""

function Hud:DisableScreen(screenName: string)
	if not screens[screenName] then
		return
	end

	screens[screenName].Visible = false
	self.currentScreen = ""
end

function Hud:EnableScreen(screenName: string)
	local currentScreen = self.currentScreen
	self:DisableScreen(self.currentScreen)

	if screenName == currentScreen then
		return
	end

	screens[screenName].Visible = true
	self.currentScreen = screenName
end

RoQuest.OnStart():andThen(function()
	for _, instance: Instance in hud.Container:GetChildren() do
		if not instance:IsA("ImageButton") then
			continue
		end

		(instance :: ImageButton).Activated:Connect(function()
			Hud:EnableScreen(instance.Name)
		end)   
	end	

end)
```
--QuestLog.lua
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RoQuest = require(ReplicatedStorage.RoQuest).Client
local Red = require(ReplicatedStorage.RoQuest.Vendor.Red).Client

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
	local Net = Red "QuestManager"

	local frame: Frame = scrollingFrame:FindFirstChild(quest.QuestId) or template:Clone()
	frame.Name = quest.QuestId
	frame.Title.Text = quest.Name
	frame.Description.Text = quest.Description
	frame.Buttons.Cancel.Visible = quest:GetQuestStatus() == RoQuest.QuestStatus.InProgress
	frame.Buttons.Cancel.Activated:Connect(function()
		Net:Fire("CancelQuest", quest.QuestId)
	end)

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

RoQuest.OnStart():andThen(function()
	QuestLog:SetupWindows() -- Caching our windows
	QuestLog:SetupButtons() -- Caching our buttons
	QuestLog:SetScreen("InProgress") -- Setting the initial active screen
	QuestLog:SetAllScreens() -- Populating all screens

	RoQuest.OnUnAvailableQuestChanged:Connect(function()
		QuestLog:PopulateScreen(QuestLog.screens["Unavailable"], RoQuest:GetUnAvailableQuests())
	end)

	RoQuest.OnAvailableQuestChanged:Connect(function()
		QuestLog:PopulateScreen(QuestLog.screens["Available"], RoQuest:GetAvailableQuests())
	end)

	RoQuest.OnCompletedQuestChanged:Connect(function()
		QuestLog:PopulateScreen(QuestLog.screens["Completed"], RoQuest:GetCompletedQuests())
	end)

	RoQuest.OnDeliveredQuestChanged:Connect(function()
		QuestLog:PopulateScreen(QuestLog.screens["Delivered"], RoQuest:GetDeliveredQuests())
	end)

	RoQuest.OnInProgressQuestChanged:Connect(function()
		QuestLog:PopulateScreen(QuestLog.screens["InProgress"], RoQuest:GetInProgressQuests())
	end)

	RoQuest.OnPlayerDataChanged:Connect(function()
		QuestLog:SetAllScreens()
	end) -- Hard reset our screens    	
end)
```

## 🔑 Main take aways

We used multiple events from RoQuest to listen to the changes from specific quest states. We also used different quest getters to get the information from said quests.

:::info
You should always have a listener for when the player data changes that resets everything. This ensure that if a player's data gets hard reset that you can update the interface accordingly.

```lua
	RoQuest.OnPlayerDataChanged:Connect(function()
		QuestLog:SetAllScreens()
	end) -- Hard reset our screens    
```
:::