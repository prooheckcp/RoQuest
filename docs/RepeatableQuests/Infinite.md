---
sidebar_position: 1
sidebar_label: "♾️ Infinite"
---

# ♾️ Infinite

Sometimes we want quests to be repeatable. There are multiple types of repeatable quests and here we'll cover examples on all of them. Let's start by making a new quest! This time one where the player needs to collect Sticks!

## 🪵 Creating Sticks

Let's create some sticks and tag them all with a tag called **"Stick"**

## 💻 Code

Great! Now that we have some sticks let's create a new script under ServerScriptService and add the following code:

```lua
--Stick.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

local function stickAdded(stick)
	local clone = stick:Clone()
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.ActionText = "Collect Stick"
	proximityPrompt.HoldDuration = 0.25
	
	proximityPrompt.Triggered:Connect(function(player)
		stick:Destroy()
		
		RoQuest:AddObjective(player, "Stick", 1) -- Add to the quest
		
		task.delay(5, function() -- Respawn after 5 seconds
			clone.Parent = workspace
		end)
	end)
	
	proximityPrompt.Parent = stick
end

CollectionService:GetInstanceAddedSignal("Stick"):Connect(stickAdded)

for _, stick in CollectionService:GetTagged("Stick") do
	stickAdded(stick)
end
```

THERES A BUG