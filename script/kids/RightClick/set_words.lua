--  设置人物对白界面脚本

local function activate()
local __this,__parent,__font,__texture;

--  总框
__this=ParaUI.CreateUIObject("container","SetTalkContainer", "_lt",100,100,200,300);
__this:AttachToRoot();
__this.scrollable=false;
__this.background="Texture/player/outputbox.png;0 0 512 256";
__this.candrag=true;

--  取消键
__this=ParaUI.CreateUIObject("button","cancel", "_lt",113,256,70,30);
__parent=ParaUI.GetUIObject("SetTalkContainer");__parent:AddChild(__this);
__this.text="取消"; 
__this.background="Texture/b_up.png;0 0 128 32";
__this.onclick="(gl)script/kids/RightClick/RCP_words_cancel.lua";
__this.candrag=false;
__this.font="System;15;bold;true";

--  确定键
__this=ParaUI.CreateUIObject("button","confirm", "_lt",18,256,70,30);
__parent=ParaUI.GetUIObject("SetTalkContainer");__parent:AddChild(__this);
__this.text="确定";
__this.background="Texture/b_up.png;0 0 128 32";
__this.onclick="(gl)script/kids/RightClick/RCP_words_confirm.lua";
__this.candrag=false;
__this.font="System;15;bold;true";  

--  随机对白区
__this=ParaUI.CreateUIObject("text","text1", "_lt",10,10,100,21);
__parent=ParaUI.GetUIObject("SetTalkContainer");__parent:AddChild(__this);
__this.text="随机对白";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
__this.font="System;15;bold;true";
__this.onclick=""; 
__this.onmousehover="";
__this=ParaUI.CreateUIObject("text","text6", "_lt",10,40,100,21);
__parent=ParaUI.GetUIObject("SetTalkContainer");__parent:AddChild(__this);
__this.text="1.";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
__this.font="System;15;bold;true";
__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("editbox","RandomWords1", "_lt",30,40,160,22);
__parent=ParaUI.GetUIObject("SetTalkContainer");__parent:AddChild(__this);
__this.text="";
__this.background="Texture/box.png;0 0 128 32";
__this.candrag=false;
__this.font="System;12;bold;true";
__this.onstring="";
__this.onchange="";
__this.readonly=false;
__this=ParaUI.CreateUIObject("text","text8", "_lt",10,75,100,21);
__parent=ParaUI.GetUIObject("SetTalkContainer");__parent:AddChild(__this);
__this.text="2.";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
__this.font="System;15;bold;true";
__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("editbox","RandomWords2", "_lt",30,75,160,22);
__parent=ParaUI.GetUIObject("SetTalkContainer");__parent:AddChild(__this);
__this.text="";
__this.background="Texture/box.png;0 0 128 32";
__this.candrag=false;
__this.font="System;12;bold;true";
__this.onstring="";
__this.onchange="";
__this.readonly=false;
__this=ParaUI.CreateUIObject("text","text10", "_lt",10,110,100,21);
__parent=ParaUI.GetUIObject("SetTalkContainer");__parent:AddChild(__this);
__this.text="3.";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
__this.font="System;15;bold;true";
__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("editbox","RandomWords3", "_lt",30,110,160,22);
__parent=ParaUI.GetUIObject("SetTalkContainer");__parent:AddChild(__this);
__this.text="";
__this.background="Texture/box.png;0 0 128 32";
__this.candrag=false;
__this.font="System;12;bold;true";
__this.onstring="";
__this.onchange="";
__this.readonly=false;

--  点击对白区
__this=ParaUI.CreateUIObject("text","text12", "_lt",10,150,100,21);
__parent=ParaUI.GetUIObject("SetTalkContainer");__parent:AddChild(__this);
__this.text="点击对白";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";
__this.candrag=false;
__this.font="System;15;bold;true";
__this.onclick="";
__this.onmousehover="";
__this=ParaUI.CreateUIObject("editbox","ClickWords", "_lt",10,180,180,22);
__parent=ParaUI.GetUIObject("SetTalkContainer");__parent:AddChild(__this);
__this.text="aaa";
__this.background="Texture/box.png;0 0 128 32";
__this.candrag=false;
__this.font="System;12;bold;true";
__this.onstring="";
__this.onchange="";
__this.readonly=false;
end
NPL.this(activate);
