---
sidebar_position: 2
sidebar_label: "📦 Deliver Type"
---

# 📦 Deliver Type

There are 2 different types of QuestDeliverType

## 🔄 Change QuestDeliverType

When declaring a quest we can change the deliver type by modifying the following property:

```lua
Quest {
    QuestDeliverType = RoQuest.QuestDeliverType.Automatic;
}
```

## 🤖 Automatic

This is the default behavior of our quests. With this behavior the quests will automatically be delivered as soon as they get completed. That's why our example quest gets delivered as soon as the player completes it!

## ✋ Manual

Manual on the other hand requires the developer to deliver the quest for the player. The developer can do this by calling the function :DeliverQuest

:::info
RoQuest only allows you to deliver a quest if it is completed. If the quest is still not complete make sure to call :CompleteQuest beforehand
:::

```lua
--Example
RoQuest:DeliverQuest(player, questId)
```