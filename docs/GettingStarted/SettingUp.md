---
sidebar_position: 3
sidebar_label: "🔧 Setting Up"
---

# 🔧 Setting Up

## 📐 Structure

Now that RoQuest is finally installed it is time to set it up! In order for it to work we need to both Init it from our Client and Server! What I would personally recommend would be having a local script and a server script specifically just for loading the quest system but feel free to organize it as you please.

And don't worry, the system still works fine if loaded with a delay in case you are using loader framework like Knit.

## 📜 Scripts Content

:::warning

The code from the Client and Server are separate. Make sure that you are using RoQuest.Sever when accessing it from the server-side and RoQuest.Client when on the client-side.

:::

```lua
-- Server Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

RoQuest:Init({})
```

```lua
-- Client Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoQuest = require(ReplicatedStorage.RoQuest).Client

RoQuest:Init()
```

The Init function on the server-side takes an array of quests as the first argument. We'll be creating our first quest and feeding it into the system in the next section!