"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[5606],{18172:(e,t,s)=>{s.r(t),s.d(t,{assets:()=>r,contentTitle:()=>o,default:()=>h,frontMatter:()=>u,metadata:()=>n,toc:()=>l});const n=JSON.parse('{"id":"MyFirstQuestChain","title":"\u26d3\ufe0f My First Quest Chain","description":"\u2753 What is a quest chain?","source":"@site/docs/MyFirstQuestChain.md","sourceDirName":".","slug":"/MyFirstQuestChain","permalink":"/RoQuest/docs/MyFirstQuestChain","draft":false,"unlisted":false,"editUrl":"https://github.com/prooheckcp/RoQuest/edit/master/docs/MyFirstQuestChain.md","tags":[],"version":"current","sidebarPosition":6,"frontMatter":{"sidebar_position":6,"sidebar_label":"\u26d3\ufe0f My First Quest Chain"},"sidebar":"defaultSidebar","previous":{"title":"\ud83d\udce6 Deliver Type","permalink":"/RoQuest/docs/AutomaticVsManual/DeliverType"},"next":{"title":"\u267e\ufe0f Infinite","permalink":"/RoQuest/docs/RepeatableQuests/Infinite"}}');var i=s(74848),a=s(28453);const u={sidebar_position:6,sidebar_label:"\u26d3\ufe0f My First Quest Chain"},o="\u26d3\ufe0f My First Quest Chain",r={},l=[{value:"\u2753 What is a quest chain?",id:"-what-is-a-quest-chain",level:2},{value:"\ud83c\udff9 Our second quest",id:"-our-second-quest",level:2},{value:"\u26d3\ufe0f Chaining quest",id:"\ufe0f-chaining-quest",level:2}];function c(e){const t={a:"a",code:"code",h1:"h1",h2:"h2",header:"header",p:"p",pre:"pre",strong:"strong",...(0,a.R)(),...e.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(t.header,{children:(0,i.jsx)(t.h1,{id:"\ufe0f-my-first-quest-chain",children:"\u26d3\ufe0f My First Quest Chain"})}),"\n",(0,i.jsx)(t.h2,{id:"-what-is-a-quest-chain",children:"\u2753 What is a quest chain?"}),"\n",(0,i.jsx)(t.p,{children:"A quest chain as the name indicates is when we have a sequence of quests. This means that the player needs to deliver a quest before being allowed to move into the next one!"}),"\n",(0,i.jsxs)(t.p,{children:["We'll make an example one with the apple quest that we have done in the earlier sections! Make sure to check ",(0,i.jsx)(t.a,{href:"/RoQuest/docs/MyFirstQuest/DeclaringQuest",children:"My First Quest"})," if you haven't already!"]}),"\n",(0,i.jsx)(t.h2,{id:"-our-second-quest",children:"\ud83c\udff9 Our second quest"}),"\n",(0,i.jsx)(t.p,{children:"Let's make a quest just like the previous one but instead of 2 apples we'll need 5 apples to complete!"}),"\n",(0,i.jsx)(t.pre,{children:(0,i.jsx)(t.code,{className:"language-lua",children:'local ReplicatedStorage = game:GetService("ReplicatedStorage")\n\nlocal RoQuest = require(ReplicatedStorage.RoQuest).Server\nlocal appleObjective = require(ReplicatedStorage.QuestObjectives.AppleInfo)\n\nlocal Quest = RoQuest.Quest\n\nreturn Quest {\n\tName = "Collect Apples", -- The name of our quest\n\tDescription = "Collect 5 apples", -- The description that we will display to our user\n\tQuestId = "AppleCollection2", -- A unique identifier to our quest\n\tQuestAcceptType = RoQuest.QuestAcceptType.Automatic, -- If the quest automatically gets accepted or rquires manual work\n\tQuestDeliverType = RoQuest.QuestDeliverType.Automatic, -- If the quest automatically gets delivered or requires manual work\n\tQuestRepeatableType = RoQuest.QuestRepeatableType.NonRepeatable, -- If the quest can be repeated or not\n\tQuestStart = -1, -- UTC time to define when the quest should become available (specially useful for event quests)\n\tQuestEnd = -1, -- UTC time to define when the quest should no longer be available (specially useful for event quests)\n\tRequiredQuests = {}, -- A list of quests that are required to be delivered before this quest can be started\n\tLifeCycles = {}, -- The lifecycles that will manage this quest\'s behavior\n\tQuestObjectives = {\n\t\tappleObjective:NewObjective(5)\n\t}, \n}\n'})}),"\n",(0,i.jsx)(t.p,{children:"Don't forget to change the QuestID if you're copy pasting the previous quest!"}),"\n",(0,i.jsx)(t.h2,{id:"\ufe0f-chaining-quest",children:"\u26d3\ufe0f Chaining quest"}),"\n",(0,i.jsxs)(t.p,{children:["Now that we chained the quest ensure it is connected to the previous quest by adding the ID from the previous quest to the ",(0,i.jsx)(t.strong,{children:'"RequiredQuests"'})," property!"]}),"\n",(0,i.jsx)(t.pre,{children:(0,i.jsx)(t.code,{className:"language-lua",children:'return Quest {\n\tName = "Collect Apples", -- The name of our quest\n\tDescription = "Collect 5 apples", -- The description that we will display to our user\n\tQuestId = "AppleCollection2", -- A unique identifier to our quest\n\tQuestAcceptType = RoQuest.QuestAcceptType.Automatic, -- If the quest automatically gets accepted or rquires manual work\n\tQuestDeliverType = RoQuest.QuestDeliverType.Automatic, -- If the quest automatically gets delivered or requires manual work\n\tQuestRepeatableType = RoQuest.QuestRepeatableType.NonRepeatable, -- If the quest can be repeated or not\n\tQuestStart = -1, -- UTC time to define when the quest should become available (specially useful for event quests)\n\tQuestEnd = -1, -- UTC time to define when the quest should no longer be available (specially useful for event quests)\n\tRequiredQuests = {"AppleCollection"}, -- A list of quests that are required to be delivered before this quest can be started\n\tLifeCycles = {}, -- The lifecycles that will manage this quest\'s behavior\n\tQuestObjectives = {\n\t\tappleObjective:NewObjective(5)\n\t}, \n}\n'})}),"\n",(0,i.jsx)(t.p,{children:"Now hop in the play test and give it a try!"})]})}function h(e={}){const{wrapper:t}={...(0,a.R)(),...e.components};return t?(0,i.jsx)(t,{...e,children:(0,i.jsx)(c,{...e})}):c(e)}},28453:(e,t,s)=>{s.d(t,{R:()=>u,x:()=>o});var n=s(96540);const i={},a=n.createContext(i);function u(e){const t=n.useContext(a);return n.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function o(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:u(e.components),n.createElement(a.Provider,{value:t},e.children)}}}]);