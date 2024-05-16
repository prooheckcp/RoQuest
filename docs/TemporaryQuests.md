---
sidebar_position: 8
sidebar_label: "⏳ Temporary Quests"
---

# ⏳ Temporary Quests

Imagine temporary quests as event quests that you're adding to your game! You can set a starting date and an end date! This means the player can only access this quest, complete, and deliver it during this time period.

To create a temporary quest all you have to do is modify the ``QuestStart`` and ``QuestEnd``. These dates should be in UTC format. You can create your own UTC timers here: https://www.epochconverter.com/.

Example of a quest a player can only complete in the first 60 seconds of a new server!

```lua
return Quest {
	Name = "Collect Sticks",
	Description = "Collect 3 sticks",
	QuestId = "StickCollection", 
	QuestAcceptType = RoQuest.QuestAcceptType.Automatic, 
	QuestDeliverType = RoQuest.QuestDeliverType.Automatic,
	QuestRepeatableType = RoQuest.QuestRepeatableType.Custom, -- If the quest can be repeated or not
	QuestStart = os.time(), -- UTC time to define when the quest should become available 
	QuestEnd = os.time() + 60, -- UTC time to define when the quest should no longer be available 
	QuestObjectives = {
		stickObjective:NewObjective(3)
	}, 
}
```