"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[9357],{3905:(e,t,a)=>{a.d(t,{Zo:()=>l,kt:()=>m});var r=a(67294);function n(e,t,a){return t in e?Object.defineProperty(e,t,{value:a,enumerable:!0,configurable:!0,writable:!0}):e[t]=a,e}function c(e,t){var a=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),a.push.apply(a,r)}return a}function o(e){for(var t=1;t<arguments.length;t++){var a=null!=arguments[t]?arguments[t]:{};t%2?c(Object(a),!0).forEach((function(t){n(e,t,a[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(a)):c(Object(a)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(a,t))}))}return e}function p(e,t){if(null==e)return{};var a,r,n=function(e,t){if(null==e)return{};var a,r,n={},c=Object.keys(e);for(r=0;r<c.length;r++)a=c[r],t.indexOf(a)>=0||(n[a]=e[a]);return n}(e,t);if(Object.getOwnPropertySymbols){var c=Object.getOwnPropertySymbols(e);for(r=0;r<c.length;r++)a=c[r],t.indexOf(a)>=0||Object.prototype.propertyIsEnumerable.call(e,a)&&(n[a]=e[a])}return n}var i=r.createContext({}),u=function(e){var t=r.useContext(i),a=t;return e&&(a="function"==typeof e?e(t):o(o({},t),e)),a},l=function(e){var t=u(e.components);return r.createElement(i.Provider,{value:t},e.children)},s="mdxType",y={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},d=r.forwardRef((function(e,t){var a=e.components,n=e.mdxType,c=e.originalType,i=e.parentName,l=p(e,["components","mdxType","originalType","parentName"]),s=u(a),d=n,m=s["".concat(i,".").concat(d)]||s[d]||y[d]||c;return a?r.createElement(m,o(o({ref:t},l),{},{components:a})):r.createElement(m,o({ref:t},l))}));function m(e,t){var a=arguments,n=t&&t.mdxType;if("string"==typeof e||n){var c=a.length,o=new Array(c);o[0]=d;var p={};for(var i in t)hasOwnProperty.call(t,i)&&(p[i]=t[i]);p.originalType=e,p[s]="string"==typeof e?e:n,o[1]=p;for(var u=2;u<c;u++)o[u]=a[u];return r.createElement.apply(null,o)}return r.createElement.apply(null,a)}d.displayName="MDXCreateElement"},36564:(e,t,a)=>{a.r(t),a.d(t,{assets:()=>i,contentTitle:()=>o,default:()=>y,frontMatter:()=>c,metadata:()=>p,toc:()=>u});var r=a(87462),n=(a(67294),a(3905));const c={id:"acceptType",sidebar_position:1,sidebar_label:"\ud83e\udd1d Accept Type"},o="\ud83e\udd1d Accept Type",p={unversionedId:"AutomaticVsManual/acceptType",id:"AutomaticVsManual/acceptType",title:"\ud83e\udd1d Accept Type",description:"There are 2 different types of QuestAcceptType",source:"@site/docs/AutomaticVsManual/AcceptType.md",sourceDirName:"AutomaticVsManual",slug:"/AutomaticVsManual/acceptType",permalink:"/RoQuest/docs/AutomaticVsManual/acceptType",draft:!1,editUrl:"https://github.com/prooheckcp/RoQuest/edit/master/docs/AutomaticVsManual/AcceptType.md",tags:[],version:"current",sidebarPosition:1,frontMatter:{id:"acceptType",sidebar_position:1,sidebar_label:"\ud83e\udd1d Accept Type"},sidebar:"defaultSidebar",previous:{title:"\ud83d\udcdc Making a Quest Log",permalink:"/RoQuest/docs/MyFirstUI/QuestLog"},next:{title:"\ud83d\udce6 Deliver Type",permalink:"/RoQuest/docs/AutomaticVsManual/DeliverType"}},i={},u=[{value:"\ud83d\udd04 Change QuestAcceptType",id:"-change-questaccepttype",level:2},{value:"\ud83e\udd16 Automatic",id:"-automatic",level:2},{value:"\u270b Manual",id:"-manual",level:2}],l={toc:u},s="wrapper";function y(e){let{components:t,...a}=e;return(0,n.kt)(s,(0,r.Z)({},l,a,{components:t,mdxType:"MDXLayout"}),(0,n.kt)("h1",{id:"-accept-type"},"\ud83e\udd1d Accept Type"),(0,n.kt)("p",null,"There are 2 different types of QuestAcceptType"),(0,n.kt)("h2",{id:"-change-questaccepttype"},"\ud83d\udd04 Change QuestAcceptType"),(0,n.kt)("p",null,"When declaring a quest we can change the accept type by modifying the following property:"),(0,n.kt)("pre",null,(0,n.kt)("code",{parentName:"pre",className:"language-lua"},"Quest {\n    QuestAcceptType = RoQuest.QuestAcceptType.Automatic;\n}\n")),(0,n.kt)("h2",{id:"-automatic"},"\ud83e\udd16 Automatic"),(0,n.kt)("p",null,"This is the default behavior of our quests. With this behavior the quests will automatically be accepted by the player as soon as they become available! That's why our example quest gets given to the player as soon as he joins the game without any extra steps!"),(0,n.kt)("h2",{id:"-manual"},"\u270b Manual"),(0,n.kt)("p",null,"Manual on the other hand requires the developer to give the quest to the player. The developer can do this by calling the function :GiveQuest"),(0,n.kt)("pre",null,(0,n.kt)("code",{parentName:"pre",className:"language-lua"},"--Example\nRoQuest:GiveQuest(player, questId)\n")))}y.isMDXComponent=!0}}]);