---
sidebar_position: 1
sidebar_label: "🤔 What is a lifecycle?"
---

# 🤔 What is a lifecycle?

LifeCycles are a feature that I've been a huge fan ever since I started developing libraries. Although it is something simple, it is also something incredibly powerful to create fragmented reusable code.

But before we jump into making our own lifecycle first we need to understand what it is. Imagine a lifecycle as the behavior of a quest. With this you can determine how a quest behaves when you start it, progress on it, complete it, cancel it, deliver it and so on! In short you can see the Quest as the data and the lifecycle as the behavior of said data!

![](QuestLifecycle.png)

:::info
If a player rejoins the game and reloads his data, it will **only** call the lifecycle part where the player was left on.
So if the player already completed the quest but didn't deliver it, when he rejoins it will only call the OnComplete function
:::

## Client Vs Server

LifeCycles can both run on the server and or client. This all depends on how the developer injects the lifeCycles into their RoQuest! I'll be showing some examples on the following section for lifeCycles.