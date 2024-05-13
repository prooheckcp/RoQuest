---
sidebar_position: 4
sidebar_label: "🎬 Wrap Up"
---

# 🎬 Wrap Up

## 🎯 Adding Objective to Quest

Now that we have both our quest and objective done we need to add this to the quest. To do so you just need to require the quest objective. Once you did that you can call the function ``:NewObjective(target)``

```lua
-- Apple.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server
local appleObjective = require(ReplicatedStorage.QuestObjectives.AppleInfo)

local Quest = RoQuest.Quest

return Quest {
	Name = "Collect Apples", -- The name of our quest
	Description = "Collect 2 apples", -- The description that we will display to our user
	QuestId = "AppleCollection", -- A unique identifier to our quest
	QuestAcceptType = RoQuest.QuestAcceptType.Automatic, -- If the quest automatically gets accepted or rquires manual work
	QuestDeliverType = RoQuest.QuestDeliverType.Automatic, -- If the quest automatically gets delivered or requires manual work
	QuestRepeatableType = RoQuest.QuestRepeatableType.NonRepeatable, -- If the quest can be repeated or not
	QuestStart = -1, -- UTC time to define when the quest should become available (specially useful for event quests)
	QuestEnd = -1, -- UTC time to define when the quest should no longer be available (specially useful for event quests)
	RequiredQuests = {}, -- A list of quests that are required to be delivered before this quest can be started
	LifeCycles = {"AppleQuest"}, -- The lifecycles that will manage this quest's behavior
	QuestObjectives = {
		appleObjective:NewObjective(2) -- Creates an objective with a goal of 2
	}, 
}
```

In the example above we created an objective with a goal of 2. Basically the player needs to collect 2 apples in order to complete this quest! A quest can contain an infinite amount of objects!

## 💾 Load quest into RoQuest

In the server-side, we now need to feed the quests into RoQuest in order for the library to know that they exist. Remember the :Init function? Yes, we passed an empty table into it! You should instead of an empty table, you should send an array with all your quests into it.

To help you doing this you can take advantage of a neat function called LoadDirectory. See the following example:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

RoQuest:Init(RoQuest:LoadDirectory(ReplicatedStorage.Quests))
```

## 🔍 Track Progress

Okay but now how do we know when the player completed the quest? We don't have any UI or feedback to indicate that! In the next section I'll teach you how to make a UI to track the quests and make your own quest log but for now let's just use some events to listen to changes to the quest.

:::info
    
When accessing to anything from RoQuest the developer **shoud** use RoQuest.OnStart (returns a Promise) to ensure that the quest system has been initiated

:::

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

RoQuest:Init(RoQuest:LoadDirectory(ReplicatedStorage.Quests))

RoQuest.OnStart():andThen(function()
	RoQuest.OnQuestObjectiveChanged:Connect(function(player: Player, questId: string, objectiveId: string, newValue: number)
		print(player.Name, " got ", newValue, objectiveId)
	end)
	
	RoQuest.OnQuestCompleted:Connect(function(player: Player, questId: string)
		print(player.Name, " just completed the quest: ", questId)
	end)
end)
```