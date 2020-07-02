--[[
Title: The Kids Movie UI
Author(s): LiuHe, LiXizhi
Date: 2006/1/26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/mode.lua");
------------------------------------------------------------
]]

-- KidsUI: Kids UI library 
if(not KidsUI) then KidsUI={}; end

--  模式切换的入口脚本
--  三种模式分别为:
--  1.俯视视角:LookDownMode
--  2.第一视角:FirstPersonMode
--  3.浏览模式:BrowseMode

-- [[ display the mode pannel]]
function KidsUI.ShowModePannel()
	local __this,__parent,__font,__texture;

	if(ParaUI.GetUIObject("ModeContainer"):IsValid() == true) then 
		ParaUI.Destroy("ModeContainer");
		return
	end
	--  创建了三种模式切换的按钮,分别激发对应模式的脚本
	__this=ParaUI.CreateUIObject("container","ModeContainer", "_lt",15,630,129,109);
	__this:AttachToRoot();
	__this.scrollable=false;
	__this.background="Texture/b_up.png;0 0 91 28";
	__this.candrag=true;
	__this=ParaUI.CreateUIObject("button","LookDownMode", "_lt",3,3,60,50);
	__parent=ParaUI.GetUIObject("ModeContainer");__parent:AddChild(__this);
	__this.text="俯视";
	__this.background="Texture/b_up.png;0 0 91 28";
	__this.onclick=";KidsUI.LookDownMode();";
	__this.candrag=false;
	__this.font="System;15;bold;true";
	__this=ParaUI.CreateUIObject("button","FirstPersonMode", "_lt",66,3,60,50);
	__parent=ParaUI.GetUIObject("ModeContainer");__parent:AddChild(__this);
	__this.text="主视角";
	__this.background="Texture/b_up.png;0 0 91 28";
	__this.onclick=";KidsUI.FirstPersonMode();";
	__this.candrag=false;
	__this.font="System;15;bold;true";
	__this=ParaUI.CreateUIObject("button","BrowseMode", "_lt",5,56,120,50);
	__parent=ParaUI.GetUIObject("ModeContainer");__parent:AddChild(__this);
	__this.text="浏览模式";
	__this.background="Texture/b_up.png;0 0 91 28";
	__this.onclick=";KidsUI.BrowseMode();";
	__this.candrag=false;
	__this.font="System;15;bold;true";
end

--[[from LD_LRArrow ]]
function KidsUI.LD_LRArrowPannel()
	local __this,__parent,__font,__texture;
	__this=ParaUI.CreateUIObject("container","LD_LRarrow", "_lt",850,630,126,109);
	__this:AttachToRoot();
	__this.scrollable=false;
	__this.background="Texture/player/outputbox.png;0 0 512 256";
	__this.candrag=false;
	__this=ParaUI.CreateUIObject("button","LeftArrow", "_lt",3,3,120,50);
	__parent=ParaUI.GetUIObject("LD_LRarrow");__parent:AddChild(__this);
	__this.text="左转90度";
	__this.background="Texture/b_up.png;0 0 128 32";
	__this.onclick="";
	__this.candrag=false;
	__this.font="System;15;bold;true";
	__this=ParaUI.CreateUIObject("button","RightArrow", "_lt",3,56,120,50);
	__parent=ParaUI.GetUIObject("LD_LRarrow");__parent:AddChild(__this);
	__this.text="右转90度";
	__this.background="Texture/b_up.png;0 0 128 32";
	__this.onclick="";
	__this.candrag=false;
	__this.font="System;15;bold;true";
end

--  创建功能模块入口脚本
function KidsUI.CreatePatPannel()
	local __this,__parent,__font,__texture;

	--  创建人物按钮
	__this=ParaUI.CreateUIObject("button","CreatePeople", "_lt",180,680,60,60);
	__this:AttachToRoot();
	__this.text="1";
	__this.background="Texture/b_up.png;0 0 128 32";
	__this.onclick="(gl)script/demo/create_player.lua";
	__this.candrag=false;
	__this.font="System;15;bold;true";

	--  创建动物按钮
	__this=ParaUI.CreateUIObject("button","CreateAnimal", "_lt",245,680,60,60);
	__this:AttachToRoot();
	__this.text="2";
	__this.background="Texture/b_up.png;0 0 128 32";
	__this.onclick="(gl)script/demo/create_zoo.lua";
	__this.candrag=false;
	__this.font="System;15;bold;true";

	--  创建物体按钮
	__this=ParaUI.CreateUIObject("button","CreateThings", "_lt",310,680,60,60);
	__this:AttachToRoot();
	__this.text="3";
	__this.background="Texture/b_up.png;0 0 128 32";
	__this.onclick="(gl)script/demo/object/main.lua";
	__this.candrag=false;
	__this.font="System;15;bold;true";
end

--  俯视视角模式入口脚本
function KidsUI.LookDownMode()
	--  清除可能存在的功能模块
	ParaUI.Destroy("ModeText");
	ParaUI.Destroy("CreatePeople");
	ParaUI.Destroy("CreateAnimal");
	ParaUI.Destroy("CreateThings");
	ParaUI.Destroy("CreateAnimals_dialog");
	ParaUI.Destroy("cp_dialog");
	ParaUI.Destroy("obj_main");
	ParaUI.Destroy("RCP_size");
	ParaUI.Destroy("RCP_direction");
	ParaUI.Destroy("RCP_skin");
	ParaUI.Destroy("RCP_words");
	ParaUI.Destroy("RCP_action");
	ParaUI.Destroy("SetTalkContainer");
	ParaUI.Destroy("action_main");

	--  载入该模式功能模块
	KidsUI.LD_LRArrowPannel();
	KidsUI.CreatePatPannel();

	local __this,__parent,__font,__texture;

	--  指示文字,发行版本中不包含
	__this=ParaUI.CreateUIObject("text","ModeText", "_lt",369,398,100,21);
	__this:AttachToRoot();
	__this.text="俯视模式";
	__this.autosize=true;
	__this.background="Texture/dxutcontrols.dds;0 0 0 0";
	__this.candrag=false;
	__this.font="System;15;bold;true";
	__this.onclick="";
	__this.onmousehover="";
end

--  第一视角模式入口脚本
function KidsUI.FirstPersonMode()
	--  清除可能存在的功能模块
	ParaUI.Destroy("CreatePeople");
	ParaUI.Destroy("CreateAnimal");
	ParaUI.Destroy("CreateThings");
	ParaUI.Destroy("LD_LRarrow");
	ParaUI.Destroy("ModeText");
	ParaUI.Destroy("CreateAnimals_dialog");
	ParaUI.Destroy("cp_dialog");
	ParaUI.Destroy("obj_main");
	ParaUI.Destroy("RCP_size");
	ParaUI.Destroy("RCP_direction");
	ParaUI.Destroy("RCP_skin");
	ParaUI.Destroy("RCP_words");
	ParaUI.Destroy("RCP_action");
	ParaUI.Destroy("SetTalkContainer");
	ParaUI.Destroy("action_main");

	--  载入该模式功能模块
	KidsUI.CreatePatPannel();

	local __this,__parent,__font,__texture;

	--  指示文字,发行版本中不包含
	__this=ParaUI.CreateUIObject("text","ModeText", "_lt",369,398,100,21);
	__this:AttachToRoot();
	__this.text="主视角模式";
	__this.autosize=true;
	__this.background="Texture/dxutcontrols.dds;0 0 0 0";
	__this.candrag=false;
	__this.font="System;15;bold;true";
	__this.onclick="";
	__this.onmousehover="";
end

--  浏览模式入口脚本
function KidsUI.BrowseMode()
	--  清除可能存在的非改功能模块
	ParaUI.Destroy("LD_LRarrow");
	ParaUI.Destroy("ModeText");
	ParaUI.Destroy("CreatePeople");
	ParaUI.Destroy("CreateAnimal");
	ParaUI.Destroy("CreateThings");
	ParaUI.Destroy("CreateAnimals_dialog");
	ParaUI.Destroy("cp_dialog");
	ParaUI.Destroy("obj_main");
	ParaUI.Destroy("RCP_size");
	ParaUI.Destroy("RCP_direction");
	ParaUI.Destroy("RCP_skin");
	ParaUI.Destroy("RCP_words");
	ParaUI.Destroy("RCP_action");
	ParaUI.Destroy("SetTalkContainer");
	ParaUI.Destroy("action_main");

	local __this,__parent,__font,__texture;

	--  指示文字,发行版本中不包含
	__this=ParaUI.CreateUIObject("text","ModeText", "_lt",369,398,70,21);
	__this:AttachToRoot();
	__this.text="浏览模式";
	__this.autosize=true;
	__this.background="Texture/dxutcontrols.dds;0 0 0 0";
	__this.candrag=false;
	__this.font="System;15;bold;true";
	__this.onclick="";
	__this.onmousehover="";
end

