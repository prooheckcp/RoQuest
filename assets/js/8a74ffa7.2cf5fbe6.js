"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[2055],{88527:e=>{e.exports=JSON.parse('{"functions":[{"name":"new","desc":"Constructor for ObjectiveInfo\\n\\n```lua\\nlocal appleQuest = ObjectiveInfo.new {\\n    ObjectiveId = \\"CollectApples\\",\\n    Name = \\"Collect Apples\\",\\n    Description = \\"Collect %s apples\\",\\n}\\n```","params":[{"name":"properties","desc":"","lua_type":"{[string]: any}"}],"returns":[{"desc":"","lua_type":"ObjectiveInfo"}],"function_type":"static","source":{"line":79,"path":"RoQuest/Shared/Classes/ObjectiveInfo.luau"}},{"name":"NewObjective","desc":"Extends the Objective Info into a Quest Objective which is what we feed into our\\nQuests\\n\\n```lua\\nlocal appleQuest = ObjectiveInfo.new {\\n    ObjectiveId = \\"CollectApples\\",\\n    Name = \\"Collect Apples\\",\\n    Description = \\"Collect %s apples\\",\\n}\\n\\nlocal objective1 = appleQuest:NewObjective(5) -- Created an objective to collect 5 apples\\nlocal objective2 = appleQuest:NewObjective(3) -- Created an objective to collect 3 apples\\nlocal objective3 = appleQuest:NewObjective(7) -- Created an objective to collect 7 apples\\n```","params":[{"name":"target","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number"}],"function_type":"method","source":{"line":101,"path":"RoQuest/Shared/Classes/ObjectiveInfo.luau"}}],"properties":[{"name":"ObjectiveId","desc":"This is an ID to represent the objective. Should be used to identify the objective in the code.\\n\\nWhen we tell the server that player did X objective this is how it will determine if it should add or not to this objective.","lua_type":"string","source":{"line":47,"path":"RoQuest/Shared/Classes/ObjectiveInfo.luau"}},{"name":"Name","desc":"The name of our objective. Can be used by the player or server to display the name of the objective\\nthat the player must complete","lua_type":"string","source":{"line":55,"path":"RoQuest/Shared/Classes/ObjectiveInfo.luau"}},{"name":"Description","desc":"A more detailed description of our objective. Can be used by the developer to display the description","lua_type":"string","source":{"line":62,"path":"RoQuest/Shared/Classes/ObjectiveInfo.luau"}}],"types":[],"name":"ObjectiveInfo","desc":"The ObjectiveInfo contains the static data for our quest objectives. This is where the developer\\nshould initiate the data for the objective as long as create the QuestObjective objects.\\n\\n```lua\\nlocal appleQuest = ObjectiveInfo.new {\\n    ObjectiveId = \\"CollectApples\\",\\n    Name = \\"Collect Apples\\",\\n    Description = \\"Collect %s apples\\",\\n}\\n\\nlocal flowerQuest = ObjectiveInfo.new {\\n    ObjectiveId = \\"CollectFlowers\\",\\n    Name = \\"Collect Flowers\\",\\n    Description = \\"Collect %s flowers\\",\\n}\\n\\nlocal appleObjective1 = appleQuest:NewObjective(5) -- Created an objective to collect 5 apples\\nlocal appleObjective2 = appleQuest:NewObjective(3) -- Created an objective to collect 3 apples\\nlocal appleObjective3 = appleQuest:NewObjective(7) -- Created an objective to collect 7 apples\\n\\nlocal flowerObjective1 = flowerQuest:NewObjective(5) -- Created an objective to collect 5 flowers\\nlocal flowerObjective2 = flowerQuest:NewObjective(3) -- Created an objective to collect 3 flowers\\nlocal flowerObjective3 = flowerQuest:NewObjective(7) -- Created an objective to collect 7 flowers\\n```","tags":["Class"],"source":{"line":36,"path":"RoQuest/Shared/Classes/ObjectiveInfo.luau"}}')}}]);