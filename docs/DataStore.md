---
sidebar_position: 10
sidebar_label: "💾 How to save to DataStore"
---

# 💾 How to save to DataStore

Most developers will want to connect their Quest System to a data store in order to save/load their data.

Here you can find some examples on how to do it

## 🔍 Native DataStore

```lua
-- main.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

local questsStore = DataStoreService:GetDataStore("PlayerQuests")

RoQuest:Init(RoQuest:LoadDirectory(ReplicatedStorage.Quests))

local function playerAdded(player: Player)
	local success, playerData = pcall(function()
		return questsStore:GetAsync("player_"..player.UserId)
	end)
	

	if playerData then -- Set the data on RoQuest
		RoQuest:SetPlayerData(player, playerData)
	end
end

local function playerRemoved(player: Player)
	local success, errorMessage = pcall(function()
		questsStore:SetAsync("player_"..player.UserId, RoQuest:GetPlayerData(player))
	end)
	
	if not success then
		print(errorMessage)
	end
end

RoQuest.OnStart():andThen(function()
	Players.PlayerAdded:Connect(playerAdded)
	
	for _, player: Player in Players:GetPlayers() do
		playerAdded(player)
	end
	
	Players.PlayerRemoving:Connect(playerRemoved)
end)
```

## 🔍 ProfileService

```lua
    local ProfileStore = ProfileService.GetProfileStore("RandomKey", {})
    local profile = ProfileStore:LoadProfileAsync("USER_"..userId)

    if not profile.Data then
        profile.Data = {}
    end

    if not playerData.Data.PlayerQuestData then -- New player, create new quest data
        playerData.Data.PlayerQuestData = PlayerQuestData {}
    end

    -- Since RoQuest stores the player data as a pointer we don't need to update anymore. Once the profile gets released it will automatically safe the player data with it
    RoQuest:SetPlayerData(player, playerData.Data.PlayerQuestData)
```