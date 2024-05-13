---
id: acceptType
sidebar_position: 1
sidebar_label: "🤝 Accept Type"
---

# 🤝 Accept Type

There are 2 different types of QuestAcceptType

## 🔄 Change QuestAcceptType

When declaring a quest we can change the accept type by modifying the following property:

```lua
Quest {
    QuestAcceptType = RoQuest.QuestAcceptType.Automatic;
}
```

## 🤖 Automatic

This is the default behavior of our quests. With this behavior the quests will automatically be accepted by the player as soon as they become available! That's why our example quest gets given to the player as soon as he joins the game without any extra steps!

## ✋ Manual

Manual on the other hand requires the developer to give the quest to the player. The developer can do this by calling the function :GiveQuest

```lua
--Example
RoQuest:GiveQuest(player, questId)
```