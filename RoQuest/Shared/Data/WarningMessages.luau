return  {
    RoQuestAlreadyInit = "RoQuest has already been initialized",
    LoadDirectoryMixedType = "Cannot load directory with mixed file types. Make sure you only load Quests or only QuestLifeCycles",
    NoQuestById = "No quest with the id %s was found",
    DuplicateQuestId = "Duplicate quest id %s found",
    DuplicateLifeCycleName = "Duplicate life cycle name %s found",
    NoObjectiveId = "No objective with the id %s exists in any of the loaded quests",
    NoLifeCycleMethod = "No method %s exists in the life cycle %s",
    SetPlayerData = "When using RoQuest:SetPlayerData make sure to pass a PlayerQuestData struct\n\nlocal RoQuest = require(ReplicatedStorage.RoQuest).Server\nlocal PlayerQuestData = RoQuest.PlayerQuestData\nRoQuest:SetPlayerData(player, PlayerQuestData {})",
    WaitForLoad = "Wait For Load timed out. Traceback: \n%s",
}