--[[
Title: Some misc settings
Author(s): LiXizhi
Date: 2006/4
Revised:2006/6
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/demo/setting/t7_setting.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/property_control.lua");
NPL.load("(gl)script/ide/visibilityGroup.lua");
NPL.load("(gl)script/ide/ParaEngineSettings.lua");

local function activate()
	local __this,__parent,__font,__texture;

	local temp = ParaUI.GetUIObject("parasetting_dialog");
	if (temp:IsValid() == true) then
		CommonCtrl.VizGroup.Show("group1", not temp.visible, "parasetting_dialog");
	else
	CommonCtrl.VizGroup.Show("group1", false);
	CommonCtrl.VizGroup.AddToGroup("group1", "parasetting_dialog");

	__this=ParaUI.CreateUIObject("container","parasetting_dialog", "_lt",50,40,400,610);
	__this:AttachToRoot();
	__this.scrollable=false;
	__this.background="Texture/cr_zoo.png";
	__this.candrag=true;
	__texture=__this:GetTexture("background");
	__texture.transparency=255;--[0-255]

	__this=ParaUI.CreateUIObject("text","static", "_lt",25,40,382,38);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="当前时间:";
	__this.autosize=true;
	
	
	__this=ParaUI.CreateUIObject("slider","slider_time","_lt",150,35,200,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.background="Texture/box.png";
	__this.value = (ParaScene.GetTimeOfDaySTD()/2+0.5)*100;
	__this.onchange=";ParaSettingsUI.OnTimeSliderChanged();";
	
	__this=ParaUI.CreateUIObject("text","static", "_lt",25,85,382,38);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="游戏内每天设定为（分钟）：";
	__this.autosize=true;
	
	
	__this=ParaUI.CreateUIObject("editbox","editbox_daylength", "_lt",250,80,85,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text=""..string.format("%.1f", ParaScene.GetDayLength());
	__this.background="Texture/box.png";
	
	__this.readonly=false;
	
	__this=ParaUI.CreateUIObject("text","static", "_lt",25,130,100,38);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="特效选择：";
	__this.autosize=true;

	
	__this=ParaUI.CreateUIObject("text","static", "_lt",85,160,60,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="最佳性能";
	
	
	__this=ParaUI.CreateUIObject("slider","slider_perf","_lt",150,155,100,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.background="Texture/box.png";
	__this.onchange=";ParaSettingsUI.OnPerfSliderChanged();";
	
	__this=ParaUI.CreateUIObject("text","static", "_lt",250,160,60,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="最佳效果";
	__this.autosize=true;
	
	
	__this=ParaUI.CreateUIObject("button","btn_terrain_shadow", "_lt",85,195,85,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="□地面阴影";
	__this.background="Texture/b_up.png;";
	__this.onclick=";ParaSettingsUI.ToggleShadow();";
	
	
	__this=ParaUI.CreateUIObject("button","btn_char_shadow", "_lt",180,195,60,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="□光照";
	__this.background="Texture/b_up.png;";
	__this.onclick=";ParaSettingsUI.ToggleLighting();";
			
	__this=ParaUI.CreateUIObject("button","static", "_lt",260,195,90,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="P.E.设置";
	__this.background="Texture/b_up.png;";
	__this.onclick=[[;CommonCtrl.ShowObjProperty("setting", ParaEngine.GetAttributeObject(), true);]];
	
	__this=ParaUI.CreateUIObject("button","btn_obj_shadow", "_lt",85,230,110,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="全局地形设置";
	__this.background="Texture/b_up.png;";
	__this.onclick=[[;CommonCtrl.ShowObjProperty("setting", ParaTerrain.GetAttributeObject(), true);]];
	
	__this=ParaUI.CreateUIObject("button","static", "_lt",215,230,110,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="当前地形设置";
	__this.background="Texture/b_up.png;";
	__this.onclick=";ParaSettingsUI.ShowCurrentTerrainProperty();";
	
	__this=ParaUI.CreateUIObject("button","static", "_lt",85,265,50,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="场景";
	__this.background="Texture/b_up.png;";
	__this.onclick=[[;CommonCtrl.ShowObjProperty("scene", ParaScene.GetAttributeObject(), true, 180, -300);]];
		
	__this=ParaUI.CreateUIObject("button","static", "_lt",180,265,50,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="海洋";
	__this.background="Texture/b_up.png;";
	__this.onclick=[[;CommonCtrl.ShowObjProperty("scene", ParaScene.GetAttributeObjectOcean(), true, 180, -300);]];
	
	
	__this=ParaUI.CreateUIObject("button","static", "_lt",260,265,50,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="天空";
	__this.background="Texture/b_up.png;";
	__this.onclick=[[;CommonCtrl.ShowObjProperty("scene", ParaScene.GetAttributeObjectSky(), true, 180, -300);]];
	
	__this=ParaUI.CreateUIObject("button","static", "_lt",85,300,90,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="摄影机设置";
	__this.background="Texture/b_up.png;";
	__this.onclick=[[;CommonCtrl.ShowObjProperty("camera", ParaCamera.GetAttributeObject(), true, 180, 100);]];
	
	
	__this=ParaUI.CreateUIObject("text","static", "_lt",215,305,90,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="雾化范围";
	__this.background="";
	__this.onclick="";
	
	__this=ParaUI.CreateUIObject("slider","fogrange_slider","_lt",280,300,100,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	
	local att =	ParaScene.GetAttributeObject();
	local fogend = att:GetField("FogEnd", 120);
	local fogstart = att:GetField("FogStart", 60);
	local fogmin = 0;
	if(fogend > fogmin) then
		__this.value = (fogstart-fogmin)/(fogend-fogmin)*100;
	end
	__this.background="Texture/box.png";
	__this.onchange=";ParaSettingsUI.OnFogRangeSliderChanged();";
		
	__this=ParaUI.CreateUIObject("text","static", "_lt",25,330,382,38);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="天空选择：";
	__this.autosize=true;
	__this.background="Texture/dxutcontrols.dds;0 0 0 0";
	
	
	__this=ParaUI.CreateUIObject("button","static", "_lt",85,360,90,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="□明亮";
	__this.background="Texture/b_up.png;";
	__this.onclick=";ParaScene.SetTimeOfDaySTD(0);";
	
	
	__this=ParaUI.CreateUIObject("button","static", "_lt",85,395,90,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="□暗淡";
	__this.background="Texture/b_up.png;";
	__this.onclick=";ParaScene.SetTimeOfDaySTD(0.5);";
	
	
	__this=ParaUI.CreateUIObject("button","static", "_lt",85,430,90,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="□昏暗";
	__this.background="Texture/b_up.png;";
	__this.onclick=";ParaScene.SetTimeOfDaySTD(0.99);";
	
	__this=ParaUI.CreateUIObject("button","static", "_lt",85,465,130,25);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="effect pannel";
	__this.background="Texture/b_up.png;";
	__this.onclick="(gl)script/demo/skill/skill.lua;";	

	__this=ParaUI.CreateUIObject("button","static", "_lt",240,520,60,30);
	__parent=ParaUI.GetUIObject("parasetting_dialog");__parent:AddChild(__this);
	__this.text="关闭";
	__this.background="Texture/b_up.png;";
	--__this.onclick=";ParaUI.Destroy(\"parasetting_dialog\");";
	__this.onclick="(gl)script/demo/setting/t7_setting.lua";
	
	end
end
NPL.this(activate);
