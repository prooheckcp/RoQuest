"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[3423],{67414:(e,t,a)=>{a.r(t),a.d(t,{assets:()=>c,contentTitle:()=>s,default:()=>u,frontMatter:()=>n,metadata:()=>i,toc:()=>o});const i=JSON.parse('{"id":"LifeCycles/CreatingLifeCycle","title":"\u267b\ufe0f Creating LifeCycle","description":"\ud83e\ude9c Create Stairs","source":"@site/docs/LifeCycles/CreatingLifeCycle.md","sourceDirName":"LifeCycles","slug":"/LifeCycles/CreatingLifeCycle","permalink":"/RoQuest/docs/LifeCycles/CreatingLifeCycle","draft":false,"unlisted":false,"editUrl":"https://github.com/prooheckcp/RoQuest/edit/master/docs/LifeCycles/CreatingLifeCycle.md","tags":[],"version":"current","sidebarPosition":2,"frontMatter":{"sidebar_position":2,"sidebar_label":"\u267b\ufe0f Creating LifeCycle"},"sidebar":"defaultSidebar","previous":{"title":"\ud83e\udd14 What is a lifecycle?","permalink":"/RoQuest/docs/LifeCycles/WhatIsLifeCycle"},"next":{"title":"\ud83d\udcbe How to save to DataStore","permalink":"/RoQuest/docs/DataStore"}}');var l=a(74848),r=a(28453);const n={sidebar_position:2,sidebar_label:"\u267b\ufe0f Creating LifeCycle"},s="\u267b\ufe0f Creating LifeCycle",c={},o=[{value:"\ud83e\ude9c Create Stairs",id:"-create-stairs",level:2},{value:"\ud83d\udcc2 Create Folder Structure",id:"-create-folder-structure",level:2},{value:"\ud83d\udc96 Create LifeCycle",id:"-create-lifecycle",level:2},{value:"\ud83d\udd27 Setup Lifecycle",id:"-setup-lifecycle",level:2},{value:"\u231b Load LifeCycles",id:"-load-lifecycles",level:2}];function d(e){const t={admonition:"admonition",code:"code",h1:"h1",h2:"h2",header:"header",img:"img",p:"p",pre:"pre",strong:"strong",...(0,r.R)(),...e.components};return(0,l.jsxs)(l.Fragment,{children:[(0,l.jsx)(t.header,{children:(0,l.jsx)(t.h1,{id:"\ufe0f-creating-lifecycle",children:"\u267b\ufe0f Creating LifeCycle"})}),"\n",(0,l.jsx)(t.h2,{id:"-create-stairs",children:"\ud83e\ude9c Create Stairs"}),"\n",(0,l.jsx)(t.p,{children:"Now that we have a base understanding of a lifecycle let's take a look at it in action!"}),"\n",(0,l.jsx)(t.p,{children:"For this example we'll make an object that is too high for the player to collect! However whenever the player accepts the quest stairs spawn in! These stairs will allow the player to climb up and get the object!"}),"\n",(0,l.jsx)(t.p,{children:"Remember the apple quest from the earlier sections? We'll be using that for this one too! Let's start by creating a platform and some stairs..."}),"\n",(0,l.jsx)(t.p,{children:(0,l.jsx)(t.img,{src:a(84380).A+"",width:"1042",height:"437"})}),"\n",(0,l.jsx)(t.p,{children:"Make sure to keep the stairs as their own model!"}),"\n",(0,l.jsx)(t.h2,{id:"-create-folder-structure",children:"\ud83d\udcc2 Create Folder Structure"}),"\n",(0,l.jsx)(t.p,{children:"For me this is one of the most important steps to take into account! We want to make sure that we have a good place to store our lifeCycles. The following example is my personal recommendation but feel free to store lifecycles as you please!"}),"\n",(0,l.jsx)(t.p,{children:(0,l.jsx)(t.img,{src:a(97994).A+"",width:"180",height:"75"})}),"\n",(0,l.jsx)(t.h2,{id:"-create-lifecycle",children:"\ud83d\udc96 Create LifeCycle"}),"\n",(0,l.jsx)(t.p,{children:"Now let's make the lifecycle! Since we only want to display the stairs for 1 player we'll create this lifecycle on the client folder! Here's an example:"}),"\n",(0,l.jsx)(t.pre,{children:(0,l.jsx)(t.code,{className:"language-lua",children:'local ReplicatedStorage = game:GetService("ReplicatedStorage")\n\nlocal RoQuest = require(ReplicatedStorage.RoQuest).Client\n\nlocal QuestLifeCycle = RoQuest.QuestLifeCycle {\n\tName = "AppleLifeCycle" -- Important unique identifier\n}\n\nfunction QuestLifeCycle:OnInit() -- Called when the player joins\n\tself.stairs = workspace.Stairs\n\tself.stairs.Parent = ReplicatedStorage\nend\n\nfunction QuestLifeCycle:OnStart()\n\tself.stairs.Parent = workspace\nend\n\nfunction QuestLifeCycle:OnDeliver()\n\tself.stairs.Parent = ReplicatedStorage\nend\n\nreturn QuestLifeCycle\n'})}),"\n",(0,l.jsx)(t.h2,{id:"-setup-lifecycle",children:"\ud83d\udd27 Setup Lifecycle"}),"\n",(0,l.jsx)(t.p,{children:"Now that we created our lifecycle we need to connect it to the quest we wish"}),"\n",(0,l.jsx)(t.pre,{children:(0,l.jsx)(t.code,{className:"language-lua",children:'local ReplicatedStorage = game:GetService("ReplicatedStorage")\n\nlocal RoQuest = require(ReplicatedStorage.RoQuest).Server\nlocal appleObjective = require(ReplicatedStorage.QuestObjectives.AppleInfo)\n\nlocal Quest = RoQuest.Quest\n\nreturn Quest {\n\tName = "Collect Apples",\n\tDescription = "Collect 2 apples",\n\tQuestId = "AppleCollection", \n\tLifeCycles = {"AppleQuest"}, -- The lifecycles that will manage this quest\'s behavior\n\tQuestObjectives = {\n\t\tappleObjective:NewObjective(2)\n\t}, \n}\n'})}),"\n",(0,l.jsx)(t.h2,{id:"-load-lifecycles",children:"\u231b Load LifeCycles"}),"\n",(0,l.jsx)(t.admonition,{type:"info",children:(0,l.jsxs)(t.p,{children:["Please remember that lifecycles need to be loaded in ",(0,l.jsx)(t.strong,{children:"both"})," the client and server"]})}),"\n",(0,l.jsx)(t.pre,{children:(0,l.jsx)(t.code,{className:"language-lua",children:'-- Server\nlocal ReplicatedStorage = game:GetService("ReplicatedStorage")\nlocal DataStoreService = game:GetService("DataStoreService")\nlocal Players = game:GetService("Players")\n\nlocal RoQuest = require(ReplicatedStorage.RoQuest).Server\n\nlocal questsStore = DataStoreService:GetDataStore("PlayerQuests")\n\nRoQuest:Init(RoQuest:LoadDirectory(ReplicatedStorage.Quests), RoQuest:LoadDirectory(ReplicatedStorage.LifeCycles.Server))\n'})}),"\n",(0,l.jsx)(t.pre,{children:(0,l.jsx)(t.code,{className:"language-lua",children:'-- Client\nlocal ReplicatedStorage = game:GetService("ReplicatedStorage")\n\nlocal RoQuest = require(ReplicatedStorage.RoQuest).Client\n\nRoQuest:Init(RoQuest:LoadDirectory(ReplicatedStorage.LifeCycles.Client))\n'})})]})}function u(e={}){const{wrapper:t}={...(0,r.R)(),...e.components};return t?(0,l.jsx)(t,{...e,children:(0,l.jsx)(d,{...e})}):d(e)}},97994:(e,t,a)=>{a.d(t,{A:()=>i});const i="data:image/png;base64,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"},84380:(e,t,a)=>{a.d(t,{A:()=>i});const i=a.p+"assets/images/StairsAndHill-24f7e319ca9524b959b69d333b77dc9a.png"},28453:(e,t,a)=>{a.d(t,{R:()=>n,x:()=>s});var i=a(96540);const l={},r=i.createContext(l);function n(e){const t=i.useContext(r);return i.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function s(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(l):e.components||l:n(e.components),i.createElement(r.Provider,{value:t},e.children)}}}]);