--[[
Title: The Kids Movie UI
Author(s): LiuHe, LiXizhi
Date: 2006/1/26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/BasicSetting.lua");
------------------------------------------------------------
]]
-- requires:
NPL.load("(gl)script/kids/kids_db.lua");
NPL.load("(gl)script/kids/mode.lua");
NPL.load("(gl)script/kids/loadworld.lua");
NPL.load("(gl)script/ide/gui_helper.lua");

-- KidsUI: Kids UI library 
if(not KidsUI) then KidsUI={}; end

--[[ show the basic setting dialog 
TODO: maybe a small changing background image is better than nothing.
TODO: LXZ to LiuHe: maybe u should organize things into KidsUI table like this one 
	for all things in this dialog. u can put them in this one file or use multiple files.
	see the example for the button "下一步". I also shows how to use multiple files in mode.lua.
 Note that I called: NPL.load("(gl)script/kids/mode.lua"); at the beginning of this file ]]
function KidsUI.BasicSetting()

	--  地形,地表,天空,环境设置界面
	local __this,__parent,__font,__texture;
	__this=ParaUI.CreateUIObject("container","BasicSetting", "_lt",10,670,800,40);
	__this:AttachToRoot();
	__this.scrollable=false;
	__this.background="Texture/player/outputbox.png;0 0 512 256";
	__this.candrag=false;
	__this=ParaUI.CreateUIObject("button","LandForm", "_lt",30,5,60,30);
	__parent=ParaUI.GetUIObject("BasicSetting");__parent:AddChild(__this);
	__this.text="地形";
	__this.background="Texture/b_up.png";
	__this.onclick="(gl)script/kids/EnvironmentSet/ChooseTerrain.lua";
	__this.candrag=false;
	__this.font="System;15;bold;true";
	__this=ParaUI.CreateUIObject("button","Terrain", "_lt",200,5,60,30);
	__parent=ParaUI.GetUIObject("BasicSetting");__parent:AddChild(__this);
	__this.text="地表";
	__this.background="Texture/b_up.png";
	__this.onclick="(gl)/script/kids/EnvironmentSet/ChooseTerrainSkin.lua";
	__this.candrag=false;
	__this.font="System;15;bold;true";
	__this=ParaUI.CreateUIObject("button","Environment", "_lt",370,5,60,30);
	__parent=ParaUI.GetUIObject("BasicSetting");__parent:AddChild(__this);
	__this.text="环境";
	__this.background="Texture/b_up.png";
	__this.onclick="(gl)/script/kids/EnvironmentSet/ChooseEnvironment.lua";
	__this.candrag=false;
	__this.font="System;15;bold;true";
	__this=ParaUI.CreateUIObject("button","Sky", "_lt",540,5,70,30);
	__parent=ParaUI.GetUIObject("BasicSetting");__parent:AddChild(__this);
	__this.text="天空";
	__this.background="Texture/b_up.png";
	__this.onclick="(gl)/script/kids/EnvironmentSet/ChooseSky.lua";
	__this.candrag=false;
	__this.font="System;15;bold;true";
	__this=ParaUI.CreateUIObject("button","NextToMode", "_lt",710,5,70,30);
	__parent=ParaUI.GetUIObject("BasicSetting");__parent:AddChild(__this);
	__this.text="下一步";
	__this.background="Texture/b_up.png";
	__this.onclick=";KidsUI.BasicSetting_OnNextBtn();";
	__this.candrag=false;
	__this.font="System;15;bold;true";
end

function KidsUI.BasicSetting_OnNextBtn()
	--[[ParaUI.Destroy("BasicSetting");
	ParaUI.Destroy("TerrainSkinContainer");
	ParaUI.Destroy("SkyContainer");
	ParaUI.Destroy("TerrainContainer");
	ParaUI.Destroy("EnvironmentContainer");]]

	if(kids_db.world.sConfigFile ~= "") then
		--  CODE
		--  记录选用的四个模版
		
		if(KidsUI.LoadWorld() == true) then
			-- TODO: show something when the world is created for the first time.
			--NPL.activate("(gl)script/kids/RightClick/RCP.lua", "");
			--KidsUI.ShowModePannel();
		else
			_guihelper.MessageBox(kids_db.world.name.."世界载入失败了。");
			KidsUI.BasicSetting();
		end
	end
end