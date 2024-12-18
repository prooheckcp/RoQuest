"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[2119],{6946:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>R,contentTitle:()=>N,default:()=>E,frontMatter:()=>q,metadata:()=>r,toc:()=>T});const r=JSON.parse('{"id":"GettingStarted/Installing","title":"\ud83d\udce5 Installing","description":"RoQuest can be installed in different ways, depending on your project\'s needs. Choose the method that suits you best:","source":"@site/docs/GettingStarted/Installing.md","sourceDirName":"GettingStarted","slug":"/GettingStarted/Installing","permalink":"/RoQuest/docs/GettingStarted/Installing","draft":false,"unlisted":false,"editUrl":"https://github.com/prooheckcp/RoQuest/edit/master/docs/GettingStarted/Installing.md","tags":[],"version":"current","sidebarPosition":2,"frontMatter":{"sidebar_position":2,"sidebar_label":"\ud83d\udce5 Installing"},"sidebar":"defaultSidebar","previous":{"title":"\ud83d\udca1 How It Works","permalink":"/RoQuest/docs/GettingStarted/HowItWorks"},"next":{"title":"\ud83d\udd27 Setting Up","permalink":"/RoQuest/docs/GettingStarted/SettingUp"}}');var a=n(74848),s=n(28453),l=n(96540),o=n(34164),u=n(23104),i=n(56347),c=n(205),d=n(57485),h=n(31682),p=n(70679);function b(e){return l.Children.toArray(e).filter((e=>"\n"!==e)).map((e=>{if(!e||(0,l.isValidElement)(e)&&function(e){const{props:t}=e;return!!t&&"object"==typeof t&&"value"in t}(e))return e;throw new Error(`Docusaurus error: Bad <Tabs> child <${"string"==typeof e.type?e.type:e.type.name}>: all children of the <Tabs> component should be <TabItem>, and every <TabItem> should have a unique "value" prop.`)}))?.filter(Boolean)??[]}function f(e){const{values:t,children:n}=e;return(0,l.useMemo)((()=>{const e=t??function(e){return b(e).map((e=>{let{props:{value:t,label:n,attributes:r,default:a}}=e;return{value:t,label:n,attributes:r,default:a}}))}(n);return function(e){const t=(0,h.XI)(e,((e,t)=>e.value===t.value));if(t.length>0)throw new Error(`Docusaurus error: Duplicate values "${t.map((e=>e.value)).join(", ")}" found in <Tabs>. Every value needs to be unique.`)}(e),e}),[t,n])}function m(e){let{value:t,tabValues:n}=e;return n.some((e=>e.value===t))}function g(e){let{queryString:t=!1,groupId:n}=e;const r=(0,i.W6)(),a=function(e){let{queryString:t=!1,groupId:n}=e;if("string"==typeof t)return t;if(!1===t)return null;if(!0===t&&!n)throw new Error('Docusaurus error: The <Tabs> component groupId prop is required if queryString=true, because this value is used as the search param name. You can also provide an explicit value such as queryString="my-search-param".');return n??null}({queryString:t,groupId:n});return[(0,d.aZ)(a),(0,l.useCallback)((e=>{if(!a)return;const t=new URLSearchParams(r.location.search);t.set(a,e),r.replace({...r.location,search:t.toString()})}),[a,r])]}function v(e){const{defaultValue:t,queryString:n=!1,groupId:r}=e,a=f(e),[s,o]=(0,l.useState)((()=>function(e){let{defaultValue:t,tabValues:n}=e;if(0===n.length)throw new Error("Docusaurus error: the <Tabs> component requires at least one <TabItem> children component");if(t){if(!m({value:t,tabValues:n}))throw new Error(`Docusaurus error: The <Tabs> has a defaultValue "${t}" but none of its children has the corresponding value. Available values are: ${n.map((e=>e.value)).join(", ")}. If you intend to show no default tab, use defaultValue={null} instead.`);return t}const r=n.find((e=>e.default))??n[0];if(!r)throw new Error("Unexpected error: 0 tabValues");return r.value}({defaultValue:t,tabValues:a}))),[u,i]=g({queryString:n,groupId:r}),[d,h]=function(e){let{groupId:t}=e;const n=function(e){return e?`docusaurus.tab.${e}`:null}(t),[r,a]=(0,p.Dv)(n);return[r,(0,l.useCallback)((e=>{n&&a.set(e)}),[n,a])]}({groupId:r}),b=(()=>{const e=u??d;return m({value:e,tabValues:a})?e:null})();(0,c.A)((()=>{b&&o(b)}),[b]);return{selectedValue:s,selectValue:(0,l.useCallback)((e=>{if(!m({value:e,tabValues:a}))throw new Error(`Can't select invalid tab value=${e}`);o(e),i(e),h(e)}),[i,h,a]),tabValues:a}}var y=n(92303);const x={tabList:"tabList__CuJ",tabItem:"tabItem_LNqP"};function I(e){let{className:t,block:n,selectedValue:r,selectValue:s,tabValues:l}=e;const i=[],{blockElementScrollPositionUntilNextRender:c}=(0,u.a_)(),d=e=>{const t=e.currentTarget,n=i.indexOf(t),a=l[n].value;a!==r&&(c(t),s(a))},h=e=>{let t=null;switch(e.key){case"Enter":d(e);break;case"ArrowRight":{const n=i.indexOf(e.currentTarget)+1;t=i[n]??i[0];break}case"ArrowLeft":{const n=i.indexOf(e.currentTarget)-1;t=i[n]??i[i.length-1];break}}t?.focus()};return(0,a.jsx)("ul",{role:"tablist","aria-orientation":"horizontal",className:(0,o.A)("tabs",{"tabs--block":n},t),children:l.map((e=>{let{value:t,label:n,attributes:s}=e;return(0,a.jsx)("li",{role:"tab",tabIndex:r===t?0:-1,"aria-selected":r===t,ref:e=>i.push(e),onKeyDown:h,onClick:d,...s,className:(0,o.A)("tabs__item",x.tabItem,s?.className,{"tabs__item--active":r===t}),children:n??t},t)}))})}function w(e){let{lazy:t,children:n,selectedValue:r}=e;const s=(Array.isArray(n)?n:[n]).filter(Boolean);if(t){const e=s.find((e=>e.props.value===r));return e?(0,l.cloneElement)(e,{className:(0,o.A)("margin-top--md",e.props.className)}):null}return(0,a.jsx)("div",{className:"margin-top--md",children:s.map(((e,t)=>(0,l.cloneElement)(e,{key:t,hidden:e.props.value!==r})))})}function j(e){const t=v(e);return(0,a.jsxs)("div",{className:(0,o.A)("tabs-container",x.tabList),children:[(0,a.jsx)(I,{...t,...e}),(0,a.jsx)(w,{...t,...e})]})}function k(e){const t=(0,y.A)();return(0,a.jsx)(j,{...e,children:b(e.children)},String(t))}const S={tabItem:"tabItem_Ymn6"};function V(e){let{children:t,hidden:n,className:r}=e;return(0,a.jsx)("div",{role:"tabpanel",className:(0,o.A)(S.tabItem,r),hidden:n,children:t})}const q={sidebar_position:2,sidebar_label:"\ud83d\udce5 Installing"},N="\ud83d\udce5 Installing",R={},T=[];function C(e){const t={h1:"h1",header:"header",p:"p",...(0,s.R)(),...e.components};return(0,a.jsxs)(a.Fragment,{children:[(0,a.jsx)(t.header,{children:(0,a.jsx)(t.h1,{id:"-installing",children:"\ud83d\udce5 Installing"})}),"\n",(0,a.jsx)(t.p,{children:"RoQuest can be installed in different ways, depending on your project's needs. Choose the method that suits you best:"}),"\n",(0,a.jsxs)(k,{className:"unique-tabs",children:[(0,a.jsxs)(V,{value:"wally",label:"\ud83d\udc36 Wally",default:!0,children:[(0,a.jsx)("a",{href:"https://wally.run/package/prooheckcp/roquest",children:"Watch wally's page"}),(0,a.jsx)("pre",{children:(0,a.jsx)("code",{className:"language-bash",children:'roquest = "prooheckcp/roquest@>0.0.0, <10.0.0"'})})]}),(0,a.jsx)(V,{value:"studio",label:"\ud83d\udd28Studio",children:(0,a.jsx)("a",{href:"https://create.roblox.com/store/asset/17475376719",children:"Get the Roblox Model"})}),(0,a.jsx)(V,{value:"github",label:"\ud83d\udc19GitHub",children:(0,a.jsx)("a",{href:"https://github.com/prooheckcp/RoQuest/releases",children:"Download from Github Releases"})})]}),"\n",(0,a.jsx)(t.p,{children:"If you installed it via the Model or GitHub I would highly recommend if you kept it under ReplicatedStorage as both the client and server should have access to it"})]})}function E(e={}){const{wrapper:t}={...(0,s.R)(),...e.components};return t?(0,a.jsx)(t,{...e,children:(0,a.jsx)(C,{...e})}):C(e)}},28453:(e,t,n)=>{n.d(t,{R:()=>l,x:()=>o});var r=n(96540);const a={},s=r.createContext(a);function l(e){const t=r.useContext(s);return r.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function o(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(a):e.components||a:l(e.components),r.createElement(s.Provider,{value:t},e.children)}}}]);