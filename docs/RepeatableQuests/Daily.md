---
sidebar_position: 2
sidebar_label: "📅 Daily/Weekly"
---

# 📅 Daily/Weekly

RoQuest by default provides support for daily and weekly quests. These are quests you can do either once a day or once a week!

All you have to do is set the **QuestRepeatableType** to either **Weekly** or **Daily**

```lua
return Quest {
    QuestRepeatableType = RoQuest.QuestRepeatableType.Daily
}
```