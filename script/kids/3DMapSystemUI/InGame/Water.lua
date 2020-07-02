--[[
Title: Water in main bar for 3D Map system
Author(s): WangTian, LiXizhi
Date: 2007/9/17
Desc: Show the Water panel in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Water.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");
local LL = CommonCtrl.Locale("KidsUI");


function Map3DSystem.UI.Water.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		-- Do your code
		--_guihelper.MessageBox("WaterWnd recv MSG WM_CLOSE.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- Do your code
		--_guihelper.MessageBox("WaterWnd recv MSG WM_SIZE.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		-- Do your code
		--_guihelper.MessageBox("WaterWnd recv MSG WM_HIDE.\n");
		Map3DSystem.UI.Water.CloseUI();
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		-- Do your code
		--_guihelper.MessageBox("WaterWnd recv MSG WM_SHOW.\n");
		Map3DSystem.UI.Water.ShowUI();
	elseif(msg.type == Map3DSystem.msg.MAINPANEL_Water_Show) then
		-- show or hide the water panel, nil to toggle current setting
		Map3DSystem.UI.Water.Show(msg.bShow);
	end
end

function Map3DSystem.UI.Water.InitMessageSystem(app, mainWndName)

	Map3DSystem.UI.Water.WndObject = app:RegisterWindow(
		"WaterWnd", mainWndName, Map3DSystem.UI.Water.MSGProc);
	
end

-- show or hide the water panel, bShow == nil, toggle current setting
function Map3DSystem.UI.Water.Show(bShow)
	Map3DSystem.UI.MainPanel.ShowPanel(9, bShow);
end

function Map3DSystem.UI.Water.ShowUI()

	local _panel = ParaUI.GetUIObject("MainBar_panel");
	
	--local _icon = ParaUI.GetUIObject("MainBar_icons_9"); --  the main bar water icon
	local _icon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Water");
	local x, y, width, height = _icon:GetAbsPosition();
	
	Map3DSystem.UI.MainPanel.SendMeMessage(
			{type = Map3DSystem.msg.MAINPANEL_SetPosX,
			posX = x - Map3DSystem.UI.MainBar.IconSize});
	
	if(_panel:IsValid() == true) then
	
		local _sub_panel = _panel:GetChild("_sub_panel_water");
		if(_sub_panel:IsValid() == false) then
			-- Water sub panel for the first run
			local _sub_panel = ParaUI.CreateUIObject("container", "_sub_panel_water", "_lt",
				Map3DSystem.UI.MainPanel.SubPanelOffsetX, Map3DSystem.UI.MainPanel.SubPanelOffsetY, 
				Map3DSystem.UI.MainPanel.SubPanelWidth, Map3DSystem.UI.MainPanel.SubPanelHeight);
			_sub_panel.background = "";
			_panel:AddChild(_sub_panel);
			
			---- test button
			--local _temp = ParaUI.CreateUIObject("button", "testButton", "_lt", 10, 10, 128, 32);
			--_temp.text = "water";
			--_sub_panel:AddChild(_temp);
			
			left= 260;
			width = 70;
			
			_this=ParaUI.CreateUIObject("text","static","_lt",0, 10, 70,25);
			_sub_panel:AddChild(_this);
			_this.text=LL"water level:";
			left=left+width;
			
			_this=ParaUI.CreateUIObject("container","c","_lt",71,0,145,81);
			_sub_panel:AddChild(_this);
			_this.background="Texture/kidui/middle/water/water_bg.png;0 0 145 81";
			
			_this=ParaUI.CreateUIObject("button","kidui_w_height2_btn","_lt",76,45,32,32);
			_sub_panel:AddChild(_this);
			_this.onclick=";Map3DSystem.UI.Water.WaterLevel(-1, true);";
			_this.tooltip=LL"down 1 meter";
			_this.background="Texture/kidui/middle/water/btn_h1.png";
			_this.animstyle = 12;
			
			_this=ParaUI.CreateUIObject("button","kidui_w_height3_btn","_lt",115,23,52,32);
			_sub_panel:AddChild(_this);
			_this.onclick=";Map3DSystem.UI.Water.WaterLevel(0, true);";
			_this.tooltip=LL"To current player's feet";
			_this.background="Texture/kidui/middle/water/btn_h3.png;0 0 52 32";
			_this.animstyle = 12;

			_this=ParaUI.CreateUIObject("button","kidui_w_height5_btn","_lt",175,3,36,36);
			_sub_panel:AddChild(_this);
			_this.background="Texture/kidui/middle/water/btn_h5.png;0 0 36 36";
			_this.onclick=";Map3DSystem.UI.Water.WaterLevel(1, true);";
			_this.tooltip=LL"up 1 meter";
			_this.animstyle = 12;
			
			
			_this=ParaUI.CreateUIObject("button","kidui_w_disable_btn","_lt",240,10,32,32);
			_sub_panel:AddChild(_this);
			_this.background="Texture/player/close.png";
			_this.onclick=";Map3DSystem.UI.Water.WaterLevel(0, false);";
			_this.tooltip=LL"no water";
			
			
			
			NPL.load("(gl)script/ide/SliderBar.lua");
			
			local ctl = CommonCtrl.SliderBar:new{
				name = "map3dsystem_water_level_slider",
				alignment = "_lt",
				left = 300,
				top = 20,
				width = 40,
				height = 100,
				parent = _sub_panel,
				value = 0,
				min = -3.1415926,
				max = 3.1415926,
				min_step = 3.1415926/18,
				onchange = Map3DSystem.UI.Water.OnOceanLevelChanged,
			};
			ctl:Show();
			
			--_this=ParaUI.CreateUIObject("container","kidui_w_level_slider_BG","_lt",272,14,200,32);
			--_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background.png: 8 14 8 14";
			--_this.enable = false;
			--_sub_panel:AddChild(_this);
			--
			--_this=ParaUI.CreateUIObject("slider","kidui_w_level_slider","_lt",272,14,200,32);
			--_sub_panel:AddChild(_this);
			--_this.background="";
			--_this.button = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button.png";
			--_this.value = 50;
			--_this.onchange=";Map3DSystem.UI.Water.OnOceanLevelChanged();";
			--_this.onmousedown=";Map3DSystem.UI.Water.OnOceanLevelSliderBegin();";
			--_this.onmouseup=";Map3DSystem.UI.Water.OnOceanLevelSliderEnd();";
			
			-- TODO: instead of writing a handler, we can bind it attribute field
			left, top = 0,76;
			width = 70;
			_this=ParaUI.CreateUIObject("text","static","_lt",left, top, width, 25);
			_sub_panel:AddChild(_this);
			_this.text=LL"water color:";
			left=left+width+1;
			
			local ctl = CommonCtrl.CCtrlColorEditor:new {
				name = "KidUI_w_color",
				parent = _sub_panel,
				left = left, top = top, 
				r = 255,g = 255,b = 255,
				onchange = "Map3DSystem.UI.Water.OnOceanColorChanged();",
			};
			ctl:Show();
			
		else
			-- show Water sub panel
			_sub_panel.visible = true;
		end
	else
		log("MainBar panel container is not yet initialized.\r\n");
	end
end

function Map3DSystem.UI.Water.CloseUI()
	
	local _panel = ParaUI.GetUIObject("MainBar_panel");
	
	if(_panel:IsValid() == true) then
	
		local _sub_panel = _panel:GetChild("_sub_panel_water");
		if(_sub_panel:IsValid() == false) then
			log("Water panel container is not yet initialized.\r\n");
		else
			-- show Water sub panel
			_sub_panel.visible = false;
		end
	else
		log("MainBar panel container is not yet initialized.\r\n");
	end
end


-----------------------------------------
-- functions
-----------------------------------------

-- called when the ocean color changes
function Map3DSystem.UI.Water.OnOceanColorChanged()
	local ctl = CommonCtrl.GetControl("KidUI_w_color");
	if(ctl~=nil) then
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.OCEAN_SET_WATER, r = ctl.r/255, g = ctl.g/255, b = ctl.b/255,})
	end
end
-- update ocean color UI based on the current ocean color
function Map3DSystem.UI.Water.UpdateOceanColorUI()
	local ctl = CommonCtrl.GetControl("KidUI_w_color");
	if(ctl~=nil) then
		local att = ParaScene.GetAttributeObjectOcean();
		if(att~=nil) then
			local color = att:GetField("OceanColor", {1, 1, 1});
			ctl:SetRGB(color[1]*255, color[2]*255, color[3]*255);
		end
	end
end

function Map3DSystem.UI.Water.OnOceanLevelSliderBegin()
	local tmp = ParaUI.GetUIObject("kidui_w_level_slider");
	if(tmp:IsValid()==true) then
		Map3DSystem.UI.Water.LastOceanSliderValue = tmp.value;
	end
end

function Map3DSystem.UI.Water.OnOceanLevelSliderEnd()
	local tmp = ParaUI.GetUIObject("kidui_w_level_slider");
	if(tmp:IsValid()==true) then
		Map3DSystem.UI.Water.LastOceanSliderValue = 50;
		tmp.value = 50;
	end
end

function Map3DSystem.UI.Water.OnOceanLevelChanged(value)
	--local tmp = ParaUI.GetUIObject("kidui_w_level_slider");
	--if(tmp:IsValid()==true) then
		--local delta = (tmp.value-Map3DSystem.UI.Water.LastOceanSliderValue)*0.04; -- 2 centimeters per slider
		--if(delta~=0) then
			---- this will allow the ocean level to increase faster when at the ends of the slider bar. 
			--delta = delta*(math.abs(tmp.value-50)*0.3+1);
			--Map3DSystem.UI.Water.WaterLevel(delta, true);
			--Map3DSystem.UI.Water.LastOceanSliderValue = tmp.value;
		--end	
	--end
	
	local ctl = CommonCtrl.GetControl("map3dsystem_water_level_slider");
	if(ctl ~= nil)then
		local _level = ParaScene.GetGlobalWaterLevel();
		local delta = -value - _level;
		Map3DSystem.UI.Water.WaterLevel(delta, true);
	end
end

--[[ set the current water level by the current player's position plus the offset.
@param fOffset: offset
@param bEnable: true to enable water, false to disable. 
]]
function Map3DSystem.UI.Water.WaterLevel(fOffset, bEnable)
	local height;
	local player = ParaScene.GetPlayer();
	if (player:IsValid() == true) then
		local x,y,z = player:GetPosition();
		if(fOffset ~= 0) then
			y = ParaScene.GetGlobalWaterLevel();
		end
		height = y+fOffset;
		local tmp = ParaUI.GetUIObject("waterlevel__text");
		if (tmp:IsValid()==true)then
			tmp.text = string.format(L"%.1fm", ParaScene.GetGlobalWaterLevel());
		end
	end
	
	Map3DSystem.SendMessage_env({type = Map3DSystem.msg.OCEAN_SET_WATER, height = height, bEnable = bEnable})
end


function Map3DSystem.UI.Water.OnMouseEnter()
end

function Map3DSystem.UI.Water.OnMouseLeave()
end