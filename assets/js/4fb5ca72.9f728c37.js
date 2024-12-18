"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[2669],{45034:e=>{e.exports=JSON.parse('{"functions":[{"name":"new","desc":"Constructor for Quest\\n\\n```lua\\nlocal appleQuest = QuestLifeCycle.new {\\n\\tName = \\"AppleQuest\\",\\n}\\n```","params":[{"name":"properties","desc":"","lua_type":"{[string]: any}"}],"returns":[{"desc":"","lua_type":"Quest"}],"function_type":"static","source":{"line":129,"path":"RoQuest/Shared/Classes/QuestLifeCycle.luau"}},{"name":"OnInit","desc":"Called when the quest object gets created. \\n\\nIf the player just joined the game and the quest is already in progress it will still call OnInit!\\n\\n:::info\\n\\nThis is a virtual method. Meaning you can override it in your lifecycle\\n\\n:::","params":[],"returns":[{"desc":"","lua_type":"()"}],"function_type":"method","source":{"line":146,"path":"RoQuest/Shared/Classes/QuestLifeCycle.luau"}},{"name":"OnStart","desc":"Called when the player quest starts the quest\\n\\n:::info\\n\\nThis is a virtual method. Meaning you can override it in your lifecycle\\n\\n:::","params":[],"returns":[{"desc":"","lua_type":"()"}],"function_type":"method","source":{"line":161,"path":"RoQuest/Shared/Classes/QuestLifeCycle.luau"}},{"name":"OnComplete","desc":"Called when the quest gets completed \\n\\n:::info\\n\\nThis is a virtual method. Meaning you can override it in your lifecycle\\n\\n:::","params":[],"returns":[{"desc":"","lua_type":"()"}],"function_type":"method","source":{"line":176,"path":"RoQuest/Shared/Classes/QuestLifeCycle.luau"}},{"name":"OnDeliver","desc":"Called when the quest gets delivered. Doesn\'t get called if the player joined the game\\nand the quest was already delivered\\n\\n:::info\\n\\nThis is a virtual method. Meaning you can override it in your lifecycle\\n\\n:::","params":[],"returns":[{"desc":"","lua_type":"()"}],"function_type":"method","source":{"line":192,"path":"RoQuest/Shared/Classes/QuestLifeCycle.luau"}},{"name":"OnObjectiveChange","desc":"Called when an objective of the quest gets updated\\n\\n:::info\\n\\nThis is a virtual method. Meaning you can override it in your lifecycle\\n\\n:::","params":[{"name":"_objectiveId","desc":"","lua_type":"string"},{"name":"_newAmount","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"()"}],"function_type":"method","source":{"line":210,"path":"RoQuest/Shared/Classes/QuestLifeCycle.luau"}},{"name":"OnDestroy","desc":"Called when the quest object gets destroyed. This happens when the player leaves the game or the quest gets removed\\n\\n:::info\\n\\nThis is a virtual method. Meaning you can override it in your lifecycle\\n\\n:::","params":[],"returns":[{"desc":"","lua_type":"()"}],"function_type":"method","source":{"line":225,"path":"RoQuest/Shared/Classes/QuestLifeCycle.luau"}}],"properties":[{"name":"Name","desc":"The name of the lifecycle. This needs to be unique for each lifecycle","lua_type":"string","source":{"line":100,"path":"RoQuest/Shared/Classes/QuestLifeCycle.luau"}},{"name":"Player","desc":"A reference to the player to which this lifecycle is associated","lua_type":"Player","source":{"line":107,"path":"RoQuest/Shared/Classes/QuestLifeCycle.luau"}},{"name":"Quest","desc":"A reference to the quest that this lifecycle is managing","lua_type":"Quest","source":{"line":114,"path":"RoQuest/Shared/Classes/QuestLifeCycle.luau"}}],"types":[],"name":"QuestLifeCycle","desc":"QuestLifeCycles are classes that are used to give behavior to our quests. They get associated to a quest when it gets declared\\nand will allow the developer to update world instances and other things when the quest is available, started, completed or delivered\\n\\n:::info\\n\\nThe lifecycle runs on the side where you injected it meaning that if you load a lifecycle in the server-side it will be\\nmanaged by the server while if you inject it in the client it will be managed by the client\\n\\n:::\\n\\n```lua\\nlocal appleQuest = QuestLifeCycle.new {\\n\\tName = \\"AppleQuest\\",\\n}\\n\\nfunction appleQuest:OnInit()\\n\\tprint(\\"AppleQuest OnInit\\")\\nend\\n\\nfunction appleQuest:OnStart()\\n\\tprint(\\"AppleQuest has been started!\\")\\nend\\n\\nfunction appleQuest:OnComplete()\\n\\tprint(\\"AppleQuest has been completed!\\")\\nend\\n\\nfunction appleQuest:OnDeliver()\\n\\tprint(\\"AppleQuest has been delivered!\\")\\nend\\n\\nfunction appleQuest:OnObjectiveChange(objectiveId: string, newAmount: number)\\n\\tprint(\\"Objective \\" .. objectiveId .. \\" has been updated to \\" .. newAmount)\\nend\\n\\nfunction appleQuest:OnDestroy()\\n\\tprint(\\"AppleQuest has been destroyed!\\")\\nend\\n```","tags":["Class"],"source":{"line":90,"path":"RoQuest/Shared/Classes/QuestLifeCycle.luau"}}')}}]);