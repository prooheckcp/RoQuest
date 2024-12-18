"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[6546],{25323:(e,t,s)=>{s.r(t),s.d(t,{assets:()=>c,contentTitle:()=>i,default:()=>l,frontMatter:()=>a,metadata:()=>n,toc:()=>u});const n=JSON.parse('{"id":"TemporaryQuests","title":"\u23f3 Temporary Quests","description":"Imagine temporary quests as event quests that you\'re adding to your game! You can set a starting date and an end date! This means the player can only access this quest, complete, and deliver it during this time period.","source":"@site/docs/TemporaryQuests.md","sourceDirName":".","slug":"/TemporaryQuests","permalink":"/RoQuest/docs/TemporaryQuests","draft":false,"unlisted":false,"editUrl":"https://github.com/prooheckcp/RoQuest/edit/master/docs/TemporaryQuests.md","tags":[],"version":"current","sidebarPosition":8,"frontMatter":{"sidebar_position":8,"sidebar_label":"\u23f3 Temporary Quests"},"sidebar":"defaultSidebar","previous":{"title":"\ud83d\udcc6 Custom","permalink":"/RoQuest/docs/RepeatableQuests/Custom"},"next":{"title":"\ud83e\udd14 What is a lifecycle?","permalink":"/RoQuest/docs/LifeCycles/WhatIsLifeCycle"}}');var o=s(74848),r=s(28453);const a={sidebar_position:8,sidebar_label:"\u23f3 Temporary Quests"},i="\u23f3 Temporary Quests",c={},u=[];function d(e){const t={a:"a",code:"code",h1:"h1",header:"header",p:"p",pre:"pre",...(0,r.R)(),...e.components};return(0,o.jsxs)(o.Fragment,{children:[(0,o.jsx)(t.header,{children:(0,o.jsx)(t.h1,{id:"-temporary-quests",children:"\u23f3 Temporary Quests"})}),"\n",(0,o.jsx)(t.p,{children:"Imagine temporary quests as event quests that you're adding to your game! You can set a starting date and an end date! This means the player can only access this quest, complete, and deliver it during this time period."}),"\n",(0,o.jsxs)(t.p,{children:["To create a temporary quest all you have to do is modify the ",(0,o.jsx)(t.code,{children:"QuestStart"})," and ",(0,o.jsx)(t.code,{children:"QuestEnd"}),". These dates should be in UTC format. You can create your own UTC timers here: ",(0,o.jsx)(t.a,{href:"https://www.epochconverter.com/",children:"https://www.epochconverter.com/"}),"."]}),"\n",(0,o.jsx)(t.p,{children:"Example of a quest a player can only complete in the first 60 seconds of a new server!"}),"\n",(0,o.jsx)(t.pre,{children:(0,o.jsx)(t.code,{className:"language-lua",children:'return Quest {\n\tName = "Collect Sticks",\n\tDescription = "Collect 3 sticks",\n\tQuestId = "StickCollection", \n\tQuestAcceptType = RoQuest.QuestAcceptType.Automatic, \n\tQuestDeliverType = RoQuest.QuestDeliverType.Automatic,\n\tQuestRepeatableType = RoQuest.QuestRepeatableType.Custom, -- If the quest can be repeated or not\n\tQuestStart = os.time(), -- UTC time to define when the quest should become available \n\tQuestEnd = os.time() + 60, -- UTC time to define when the quest should no longer be available \n\tQuestObjectives = {\n\t\tstickObjective:NewObjective(3)\n\t}, \n}\n'})})]})}function l(e={}){const{wrapper:t}={...(0,r.R)(),...e.components};return t?(0,o.jsx)(t,{...e,children:(0,o.jsx)(d,{...e})}):d(e)}},28453:(e,t,s)=>{s.d(t,{R:()=>a,x:()=>i});var n=s(96540);const o={},r=n.createContext(o);function a(e){const t=n.useContext(r);return n.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function i(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(o):e.components||o:a(e.components),n.createElement(r.Provider,{value:t},e.children)}}}]);