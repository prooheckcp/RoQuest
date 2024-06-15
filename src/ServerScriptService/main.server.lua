local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local RoQuest = require(ReplicatedStorage.RoQuest).Server

local questsStore = DataStoreService:GetDataStore("PlayerQuests")
local PlayerQuestData = RoQuest.PlayerQuestData

RoQuest:Init(
    RoQuest:LoadDirectory(ReplicatedStorage.Quests), 
    RoQuest:LoadDirectory(ReplicatedStorage.LifeCycles.Server)
)

RoQuest.OnStart():andThen(function()
    local function playerAdded(player: Player)
        local success, playerData = pcall(function()
            return questsStore:GetAsync("player_"..player.UserId)
        end)

        if playerData then -- Set the data on RoQuest
            task.delay(2, function()
                print("[test] Set player data!", playerData)
                RoQuest:SetPlayerData(player, playerData)
            end)
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

    Players.PlayerAdded:Connect(playerAdded)
	
	for _, player: Player in Players:GetPlayers() do
		playerAdded(player)
	end
	
	Players.PlayerRemoving:Connect(playerRemoved)

    RoQuest.OnQuestDelivered:Connect(function(player)
        print(RoQuest:GetPlayerData(player))
    end)
end)