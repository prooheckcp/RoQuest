local QuestProgress = require(script.Parent.QuestProgress)
local createStruct = require(script.Parent.Parent.Functions.createStruct)

export type QuestProgress = QuestProgress.QuestProgress

--[=[
    @class PlayerQuestData
    @tag Struct

    ```csharp
    struct PlayerQuestData {
        InProgress: {[string]: QuestProgress},
        Completed: {[string]: QuestProgress},
        Delivered: {[string]: QuestProgress},
    }
    ```
]=]
local PlayerQuestData = {
    InProgress = {},
    Completed = {},
    Delivered = {},
}

--[=[
    Contains all the quests in progress by the Player

    @prop InProgress {[string]: QuestProgress}
    @within PlayerQuestData
]=]

--[=[
    Contains all the completed quests by the Player

    @prop Completed {[string]: QuestProgress}
    @within PlayerQuestData
]=]


--[=[
    Contains all the delivered quests by the Player

    @prop Delivered {[string]: QuestProgress}
    @within PlayerQuestData
]=]

export type PlayerQuestData = {
    InProgress: {[string]: QuestProgress},
    Completed: {[string]: QuestProgress},
    Delivered: {[string]: QuestProgress},
}

return createStruct(PlayerQuestData)