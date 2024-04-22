--!strict
local RoQuest = {}

function RoQuest:Init(quests: {Quest}, lifeCycles: {QuestLifeCycle}?)
    
end

function RoQuest:LoadDirectory(directory: Instance): {Quest | LifeCycle}
    
end

function RoQuest:LoadDirectoryDeep(directory: Instance): {Quest | LifeCycle}
    
end

function RoQuest:GetStaticQuest(questId: string): Quest
    
end

function RoQuest:GetQuest(player: Player, questId: string): Quest
    
end

function RoQuest:SetPlayerData(player: Player, data: PlayerQuestData): ()
    
end

function RoQuest:GetPlayerData(player: Player): PlayerQuestData
    
end

function RoQuest:AddObjective(player: Player, objectiveId: string, amount: number): ()
    
end

function RoQuest:SetObjective(player: Player, objectiveId: string, amount: number): ()
    
end

function RoQuest:RemoveObjective(player: Player, objectiveId: string, amount: number): ()
    
end

function RoQuest:GiveQuest(player: Player, questId: string): boolean
    
end

function RoQuest:CompleteQuest(player: Player, questId: string): boolean
    
end

function RoQuest:CancelQuest(player: Player, questId: string): boolean
    
end

function RoQuest:CanGiveQuest(player: Player, questId: string): boolean
    
end

function RoQuest:_QuestBecameAvailable(questId: string): ()
    -- TO DO when quest time is available
end

function RoQuest:_LoadQuests(quests: {Quest}): ()
    
end

function RoQuest:_LoadLifeCycles(lifecycles: {QuestLifeCycle}): ()
    
end

function RoQuest:_LoadPlayerQuests(player: Player): ()
    
end

function RoQuest:_PlayerAdded(player: Player): ()
    
end

function RoQuest:_PlayerRemoving(player: Player): ()
    
end

return RoQuest