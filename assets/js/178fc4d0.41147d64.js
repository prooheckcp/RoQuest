"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[8308],{70210:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>c,contentTitle:()=>a,default:()=>u,frontMatter:()=>o,metadata:()=>r,toc:()=>l});const r=JSON.parse('{"id":"GettingStarted/SettingUp","title":"\ud83d\udd27 Setting Up","description":"\ud83d\udcd0 Structure","source":"@site/docs/GettingStarted/SettingUp.md","sourceDirName":"GettingStarted","slug":"/GettingStarted/SettingUp","permalink":"/RoQuest/docs/GettingStarted/SettingUp","draft":false,"unlisted":false,"editUrl":"https://github.com/prooheckcp/RoQuest/edit/master/docs/GettingStarted/SettingUp.md","tags":[],"version":"current","sidebarPosition":3,"frontMatter":{"sidebar_position":3,"sidebar_label":"\ud83d\udd27 Setting Up"},"sidebar":"defaultSidebar","previous":{"title":"\ud83d\udce5 Installing","permalink":"/RoQuest/docs/GettingStarted/Installing"},"next":{"title":"\u270d\ufe0f Declaring Quest","permalink":"/RoQuest/docs/MyFirstQuest/DeclaringQuest"}}');var i=n(74848),s=n(28453);const o={sidebar_position:3,sidebar_label:"\ud83d\udd27 Setting Up"},a="\ud83d\udd27 Setting Up",c={},l=[{value:"\ud83d\udcd0 Structure",id:"-structure",level:2},{value:"\ud83d\udcdc Scripts Content",id:"-scripts-content",level:2}];function d(e){const t={admonition:"admonition",code:"code",h1:"h1",h2:"h2",header:"header",p:"p",pre:"pre",...(0,s.R)(),...e.components};return(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(t.header,{children:(0,i.jsx)(t.h1,{id:"-setting-up",children:"\ud83d\udd27 Setting Up"})}),"\n",(0,i.jsx)(t.h2,{id:"-structure",children:"\ud83d\udcd0 Structure"}),"\n",(0,i.jsx)(t.p,{children:"Now that RoQuest is finally installed it is time to set it up! In order for it to work we need to both Init it from our Client and Server! What I would personally recommend would be having a local script and a server script specifically just for loading the quest system but feel free to organize it as you please."}),"\n",(0,i.jsx)(t.p,{children:"And don't worry, the system still works fine if loaded with a delay in case you are using loader framework like Knit."}),"\n",(0,i.jsx)(t.h2,{id:"-scripts-content",children:"\ud83d\udcdc Scripts Content"}),"\n",(0,i.jsx)(t.admonition,{type:"warning",children:(0,i.jsx)(t.p,{children:"The code from the Client and Server are separate. Make sure that you are using RoQuest.Sever when accessing it from the server-side and RoQuest.Client when on the client-side."})}),"\n",(0,i.jsx)(t.pre,{children:(0,i.jsx)(t.code,{className:"language-lua",children:'-- Server Script\nlocal ReplicatedStorage = game:GetService("ReplicatedStorage")\n\nlocal RoQuest = require(ReplicatedStorage.RoQuest).Server\n\nRoQuest:Init({})\n'})}),"\n",(0,i.jsx)(t.pre,{children:(0,i.jsx)(t.code,{className:"language-lua",children:'-- Client Script\nlocal ReplicatedStorage = game:GetService("ReplicatedStorage")\n\nlocal RoQuest = require(ReplicatedStorage.RoQuest).Client\n\nRoQuest:Init()\n'})}),"\n",(0,i.jsx)(t.p,{children:"The Init function on the server-side takes an array of quests as the first argument. We'll be creating our first quest and feeding it into the system in the next section!"})]})}function u(e={}){const{wrapper:t}={...(0,s.R)(),...e.components};return t?(0,i.jsx)(t,{...e,children:(0,i.jsx)(d,{...e})}):d(e)}},28453:(e,t,n)=>{n.d(t,{R:()=>o,x:()=>a});var r=n(96540);const i={},s=r.createContext(i);function o(e){const t=r.useContext(s);return r.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function a(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(i):e.components||i:o(e.components),r.createElement(s.Provider,{value:t},e.children)}}}]);