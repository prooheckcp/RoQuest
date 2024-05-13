---
sidebar_position: 6
sidebar_label: "⛓️ My First Quest Chain"
---

# ⛓️ My First Quest Chain

## ❓ What is a quest chain?

A quest chain as the name indicates is when we have a sequence of quests. This means that the player needs to deliver a quest before being allowed to move into the next one!

We'll make an example one with the apple quest that we have done in the earlier sections! Make sure to check [My First Quest](./MyFirstQuest/DeclaringQuest.md) if you haven't already!

## 🏹 Our second quest

Let's make a quest just like the previous one but instead of 2 apples we'll need 5 apples to complete!

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server
local appleObjective = require(ReplicatedStorage.QuestObjectives.AppleInfo)

local Quest = RoQuest.Quest

return Quest {
	Name = "Collect Apples", -- The name of our quest
	Description = "Collect 5 apples", -- The description that we will display to our user
	QuestId = "AppleCollection2", -- A unique identifier to our quest
	QuestAcceptType = RoQuest.QuestAcceptType.Automatic, -- If the quest automatically gets accepted or rquires manual work
	QuestDeliverType = RoQuest.QuestDeliverType.Automatic, -- If the quest automatically gets delivered or requires manual work
	QuestRepeatableType = RoQuest.QuestRepeatableType.NonRepeatable, -- If the quest can be repeated or not
	QuestStart = -1, -- UTC time to define when the quest should become available (specially useful for event quests)
	QuestEnd = -1, -- UTC time to define when the quest should no longer be available (specially useful for event quests)
	RequiredQuests = {}, -- A list of quests that are required to be delivered before this quest can be started
	LifeCycles = {}, -- The lifecycles that will manage this quest's behavior
	QuestObjectives = {
		appleObjective:NewObjective(5)
	}, 
}
```

Don't forget to change the QuestID if you're copy pasting the previous quest!

## ⛓️ Chaining quest

Now that we chained the quest ensure it is connected to the previous quest by adding the ID from the previous quest to the **"RequiredQuests"** property!

```lua
return Quest {
	Name = "Collect Apples", -- The name of our quest
	Description = "Collect 5 apples", -- The description that we will display to our user
	QuestId = "AppleCollection2", -- A unique identifier to our quest
	QuestAcceptType = RoQuest.QuestAcceptType.Automatic, -- If the quest automatically gets accepted or rquires manual work
	QuestDeliverType = RoQuest.QuestDeliverType.Automatic, -- If the quest automatically gets delivered or requires manual work
	QuestRepeatableType = RoQuest.QuestRepeatableType.NonRepeatable, -- If the quest can be repeated or not
	QuestStart = -1, -- UTC time to define when the quest should become available (specially useful for event quests)
	QuestEnd = -1, -- UTC time to define when the quest should no longer be available (specially useful for event quests)
	RequiredQuests = {"AppleCollection"}, -- A list of quests that are required to be delivered before this quest can be started
	LifeCycles = {}, -- The lifecycles that will manage this quest's behavior
	QuestObjectives = {
		appleObjective:NewObjective(5)
	}, 
}
```

Now hop in the play test and give it a try!