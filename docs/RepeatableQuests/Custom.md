---
sidebar_position: 4
sidebar_label: "📆 Custom"
---

# 📆 Custom

Custom repeatable quests are quests that are repeatable but only when the developer decides that they should become available once again!

Here I'll be showing an example on how to make a quest available again


## 🧱 Create Part

First we'll be creating a part. We will use this part as a way to reset our players quest!

![](QuestReset.png)

## 🗺️ Set Quest

Let's set the quest repeatable type to **Custom**

```lua
return Quest {
	Name = "Collect Sticks",
	Description = "Collect 3 sticks",
	QuestId = "StickCollection",
	QuestAcceptType = RoQuest.QuestAcceptType.Automatic,
	QuestDeliverType = RoQuest.QuestDeliverType.Automatic,
	QuestRepeatableType = RoQuest.QuestRepeatableType.Custom, -- Set to Custom
	QuestStart = -1, 
	QuestEnd = -1, 
	RequiredQuests = {},
	LifeCycles = {},
	QuestObjectives = {
		stickObjective:NewObjective(3)
	}, 
}
```

## 🧹 Reset Quest

Now let's write some code to allow us to reset the quest status!

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

local part = workspace:WaitForChild("QuestReset")

local proximityPrompt = Instance.new("ProximityPrompt")
proximityPrompt.ActionText = "Quest Reset"
proximityPrompt.Parent = part

proximityPrompt.Triggered:Connect(function(player)
	RoQuest:MakeQuestAvailable(player, "StickCollection")	
end)
```
Using the ``RoQuest:MakeQuestAvailable(player, "StickCollection")`` we're capable of resetting a quest status to available!