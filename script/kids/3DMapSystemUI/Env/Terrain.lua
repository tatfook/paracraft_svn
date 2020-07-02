--[[
Title: Terrain in main bar for 3D Map system
Author(s): WangTian, LiXizhi
Date: 2007/9/17
Desc: Show the Terrain panel in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Terrain.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");
local LL = CommonCtrl.Locale("KidsUI");

-- this override default terrain texture list
Map3DSystem.UI.Terrain.terrainTexList = {
	[1]={filename = "Texture/tileset/generic/StoneRoad.dds"},
	[2]={filename = "Texture/tileset/generic/sandRock.dds"},
	[3]={filename = "Texture/tileset/generic/sandSmallRock.dds"},
	[4]={filename = "Texture/tileset/generic/greengrass.dds"},
	[5]={filename = "Texture/tileset/generic/stonegrass.dds"},
	[6]={filename = "Texture/tileset/generic/GridMarker.dds"},
};

function Map3DSystem.UI.Terrain.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		-- Do your code
		--_guihelper.MessageBox("TerrainWnd recv MSG WM_CLOSE.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- Do your code
		--_guihelper.MessageBox("TerrainWnd recv MSG WM_SIZE.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		-- Do your code
		--_guihelper.MessageBox("TerrainWnd recv MSG WM_HIDE.\n");
		Map3DSystem.UI.Terrain.CloseUI();
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		-- Do your code
		--_guihelper.MessageBox("TerrainWnd recv MSG WM_SHOW.\n");
		Map3DSystem.UI.Terrain.ShowUI();
	elseif(msg.type == Map3DSystem.msg.MAINPANEL_Terrain_Show) then
		-- show or hide the terrain panel, nil to toggle current setting
		Map3DSystem.UI.Terrain.Show(msg.bShow);
	end
end

function Map3DSystem.UI.Terrain.InitMessageSystem(app, mainWndName)

	Map3DSystem.UI.Terrain.WndObject = app:RegisterWindow(
		"TerrainWnd", mainWndName, Map3DSystem.UI.Terrain.MSGProc);
	
end

-- show or hide the water panel, bShow == nil, toggle current setting
function Map3DSystem.UI.Terrain.Show(bShow)
	Map3DSystem.UI.MainPanel.ShowPanel(10, bShow);
end

function Map3DSystem.UI.Terrain.ShowUI()

	local _panel = ParaUI.GetUIObject("MainBar_panel");
	
	--local _icon = ParaUI.GetUIObject("MainBar_icons_10"); --  the main bar terrain icon
	local _icon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Terrain");
	local x, y, width, height = _icon:GetAbsPosition();
	
	Map3DSystem.UI.MainPanel.SendMeMessage(
			{type = Map3DSystem.msg.MAINPANEL_SetPosX,
			posX = x - Map3DSystem.UI.MainBar.IconSize * 2});
	
	if(_panel:IsValid() == true) then
	
		local _sub_panel = _panel:GetChild("_sub_panel_terrain");
		if(_sub_panel:IsValid() == false) then
			-- Terrain sub panel for the first run
			local _sub_panel = ParaUI.CreateUIObject("container", "_sub_panel_terrain", "_lt",
				Map3DSystem.UI.MainPanel.SubPanelOffsetX, Map3DSystem.UI.MainPanel.SubPanelOffsetY, 
				Map3DSystem.UI.MainPanel.SubPanelWidth, Map3DSystem.UI.MainPanel.SubPanelHeight);
			_sub_panel.background = "";
			_panel:AddChild(_sub_panel);
			
			---- test button
			--local _temp = ParaUI.CreateUIObject("button", "testButton", "_lt", 10, 10, 128, 32);
			--_temp.text = "terrain";
			--_sub_panel:AddChild(_temp);
			
			
			left, top =0, 0;
			width = 60;
			_this=ParaUI.CreateUIObject("text","static","_lt",left,top+25,width,25);
			_sub_panel:AddChild(_this);
			_this.text=LL"height:";
			
			left = left+width;
			width = 144;
			_this=ParaUI.CreateUIObject("container","kidui_t_cont","_lt",left,top,width,84);
			_sub_panel:AddChild(_this);
			_this.background="Texture/kidui/middle/terrain/btn_bg.png;0 0 144 84";
			_parent = _this;
			
			_this=ParaUI.CreateUIObject("button","kidui_t_height1_btn","_lt",22,44,32,32);
			_parent:AddChild(_this);
			_this.tooltip=LL"Lower terrain";
			_this.animstyle = 12;
			_this.background="Texture/kidui/middle/terrain/btn_h1.png";
			_this.onclick=";Map3DSystem.UI.Terrain.GaussianHill(-1);";
			
			_this=ParaUI.CreateUIObject("button","kidui_t_height3_btn","_lt",47,22,32,32);
			_parent:AddChild(_this);
			_this.tooltip=LL"Flatten terrain";
			_this.animstyle = 14;
			_this.background="Texture/kidui/middle/terrain/btn_h3.png";
			_this.onclick=";Map3DSystem.UI.Terrain.Flatten();";
			
			_this=ParaUI.CreateUIObject("button","kidui_t_height5_btn","_lt",85,0,32,32);
			_parent:AddChild(_this);
			_this.tooltip=LL"Raise terrain";
			_this.animstyle = 12;
			_this.background="Texture/kidui/middle/terrain/btn_h5.png";
			_this.onclick=";Map3DSystem.UI.Terrain.GaussianHill(1);";
			
			left = left+width+10;
			width = 32;
			_this=ParaUI.CreateUIObject("button","b","_lt",left,top+25,width,width);
			_sub_panel:AddChild(_this);
			_this.tooltip=LL"Reset";
			_this.onclick=";Map3DSystem.UI.Terrain.Reset_TerrainMod();";
			_this.background="Texture/kidui/middle/terrain/btn_reset.png";
			left=left+width+5;
			
			_this=ParaUI.CreateUIObject("button","b","_lt",left,top+25,width,width);
			_sub_panel:AddChild(_this);
			_this.tooltip=LL"smooth";
			_this.background="Texture/kidui/middle/terrain/btn_pinghua.png";
			_this.onclick=";Map3DSystem.UI.Terrain.Roughen_Smooth(false);";
			left=left+width+5;
			
			_this=ParaUI.CreateUIObject("button","b","_lt",left,top+25,width,width);
			_sub_panel:AddChild(_this);
			_this.tooltip=LL"Roughen";
			_this.background="Texture/kidui/middle/terrain/btn_ruihua.png";
			_this.onclick=";Map3DSystem.UI.Terrain.Roughen_Smooth(true);";
			left=left+width+10;
			
			-- terrain brush range
			width = 128;
			_this=ParaUI.CreateUIObject("container","kidui_t_brush_cont","_lt",left,top+16,width,64);
			_sub_panel:AddChild(_this);
			_this.background=LL"Texture/kidui/middle/terrain/btn_range_bg1.png";
			_parent = _this;
			
			_this=ParaUI.CreateUIObject("button","kidui_t_range1_btn","_lt",5,2,32,32);
			_parent:AddChild(_this);
			_this.background="Texture/kidui/middle/terrain/btn_range1.png";
			_this.onclick=";Map3DSystem.UI.Terrain.OnSetTerrainBrushSize(15);";
			
			_this=ParaUI.CreateUIObject("button","kidui_t_range2_btn","_lt",40,4,32,32);
			_parent:AddChild(_this);
			_this.background="Texture/kidui/middle/terrain/btn_range2.png";
			_this.onclick=";Map3DSystem.UI.Terrain.OnSetTerrainBrushSize(20);";
			
			_this=ParaUI.CreateUIObject("button","kidui_t_range3_btn","_lt",77,5,32,32);
			_parent:AddChild(_this);
			_this.background="Texture/kidui/middle/terrain/btn_range3.png";
			_this.onclick=";Map3DSystem.UI.Terrain.OnSetTerrainBrushSize(30);";
			
			_this=ParaUI.CreateUIObject("editbox","kidui_t_range_editbox","_lt",9,39,40,22);
			_parent:AddChild(_this);
			_this.text="15";
			_this.background="Texture/whitedot.png;0 0 0 0";
			_this.onchange=";Map3DSystem.UI.Terrain.OnSetCustomTerrainBrushSize();";
			
			Map3DSystem.UI.Terrain.OnSetTerrainBrushSize();
			
			-- terrain texture paints
			left,top=0,80;
			width = 60;
			_this=ParaUI.CreateUIObject("text","static","_lt",left,top+15,width,25);
			_sub_panel:AddChild(_this);
			_this.text=LL"Texture:";
			
			left = left+width;
			width = 50;
			_this=ParaUI.CreateUIObject("button","btn1","_lt",left,top+15,width, 32);
			_sub_panel:AddChild(_this);
			_this.text = LL"base";
			_this.tooltip=LL"Left click to paint\nRight click to erase";
			_this.onclick=";Map3DSystem.UI.Terrain.OnTerrainTexturePaint();";
			
			left = left+width+5;
			width = 16;
			_this=ParaUI.CreateUIObject("button","kidui_t_leftarr_btn","_lt",left,top+15,width,32);
			_sub_panel:AddChild(_this);
			_this.background="Texture/kidui/middle/terrain/left_arr.png";
			--_this.tooltip = "上一页";
			_this.onclick=[[;local ctl = GetControl("KidUI_t_texture");if(ctl~=nil) then ctl:PageUp();end]];
			
			left=left+width+5;
			width = 48;

			-- load the terrain paint texture list for this version.
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_TextureList, texList = Map3DSystem.UI.Terrain.terrainTexList, })
			local msg = {type = Map3DSystem.msg.TERRAIN_GET_TextureList}
			Map3DSystem.SendMessage_env(msg)
			
			local ctl = CommonCtrl.CCtrlItemList:new{
				name = "KidUI_t_texture",
				parent = _sub_panel,
				left = left, top = top+8, 
				spacing = 2,
				columncount=3,
				width= (width+2)*3+2;
				height= width+4;
				items=msg.texList,
				btnpool={},
				rowcount=1,
				tooltip = LL"Left click to paint\nRight click to erase",
				placeholder="Texture/kidui/common/item_bg.png";
				onclick = Map3DSystem.UI.Terrain.OnTerrainTexturePaint,
			};
			ctl:Show();
			left=left+ctl.width+5;
			
			width = 16;
			_this=ParaUI.CreateUIObject("button","kidui_t_rightarr_btn","_lt",left,top+15,16,32);
			_sub_panel:AddChild(_this);
			_this.background="Texture/kidui/middle/terrain/right_arr.png";
			--_this.tooltip = "下一页";
			_this.onclick=[[;local ctl = GetControl("KidUI_t_texture");if(ctl~=nil) then ctl:PageDown();end]];
			left=left+width+21;
				
			-- terrain texture brush range
			width = 128;
			_this=ParaUI.CreateUIObject("container","kidui_t_brush_cont","_lt",left,top,width,64);
			_sub_panel:AddChild(_this);
			_this.background=LL"Texture/kidui/middle/terrain/btn_range_bg2.png";
			_parent = _this;
			
			_this=ParaUI.CreateUIObject("button","kidui_t_tex_range1_btn","_lt",5,1,32,32);
			_parent:AddChild(_this);
			_this.background="Texture/kidui/middle/terrain/btn_range1.png";
			_this.onclick=";Map3DSystem.UI.Terrain.OnSetTextureBrushSize(1);";
			
			_this=ParaUI.CreateUIObject("button","kidui_t_tex_range2_btn","_lt",40,3,32,32);
			_parent:AddChild(_this);
			_this.background="Texture/kidui/middle/terrain/btn_range2.png";
			_this.onclick=";Map3DSystem.UI.Terrain.OnSetTextureBrushSize(2);";
			
			_this=ParaUI.CreateUIObject("button","kidui_t_tex_range3_btn","_lt",77,4,32,32);
			_parent:AddChild(_this);
			_this.background="Texture/kidui/middle/terrain/btn_range3.png";
			_this.onclick=";Map3DSystem.UI.Terrain.OnSetTextureBrushSize(3);";
			
			_this=ParaUI.CreateUIObject("editbox","kidui_t_tex_range_editbox","_lt", 10,35,40,22);
			_parent:AddChild(_this);
			_this.background="Texture/whitedot.png;0 0 0 0";
			_this.onchange=";Map3DSystem.UI.Terrain.OnSetCustomTextureBrushSize();";
			
			-- update the default
			Map3DSystem.UI.Terrain.OnSetTextureBrushSize();
			
		else
			-- show Terrain sub panel
			_sub_panel.visible = true;
		end
	else
		log("MainBar panel container is not yet initialized.\r\n");
	end
end

function Map3DSystem.UI.Terrain.CloseUI()
	
	local _panel = ParaUI.GetUIObject("MainBar_panel");
	
	if(_panel:IsValid() == true) then
	
		local _sub_panel = _panel:GetChild("_sub_panel_terrain");
		if(_sub_panel:IsValid() == false) then
			log("Terrain panel container is not yet initialized.\r\n");
		else
			-- show Terrain sub panel
			_sub_panel.visible = false;
		end
	else
		log("MainBar panel container is not yet initialized.\r\n");
	end
end

----------------------------------------------------------
-- functions
----------------------------------------------------------

--[[ user specified brush size]]
function Map3DSystem.UI.Terrain.OnSetCustomTextureBrushSize()
	local tmp = ParaUI.GetUIObject("kidui_t_tex_range_editbox");
	if(tmp:IsValid()==true) then
		local nSize = tonumber(tmp.text);
		if(nSize~=nil and nSize>0.1 and nSize<100) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_PaintBrush, brush = {radius = nSize}, })
		else
			_guihelper.MessageBox(L"the terrain brush size can only be within (0.1, 100)");
		end
	end
end

-- set the current terrain texture brush size and update the UI
-- @param nSize: if this is nil, the current brush size is used, if not the current brush size will be set accordingly
function Map3DSystem.UI.Terrain.OnSetTextureBrushSize(nSize)
	ParaAudio.PlayUISound("Btn3");
	-- texture brush radius
	if(nSize~=nil) then
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_PaintBrush, brush = {radius = nSize}, })
	else
		local msg = {type = Map3DSystem.msg.TERRAIN_GET_PaintBrush,}
		Map3DSystem.SendMessage_env(msg)
		nSize = msg.brush.radius;
	end
	
	local radiobuttons = {"kidui_t_tex_range1_btn","kidui_t_tex_range2_btn","kidui_t_tex_range3_btn"};
	if(nSize<=1) then 
		_guihelper.CheckRadioButtons(radiobuttons, "kidui_t_tex_range1_btn", "255 0 0");
	elseif(nSize<=2) then 
		_guihelper.CheckRadioButtons(radiobuttons, "kidui_t_tex_range2_btn", "255 0 0");
	elseif(nSize>=3) then 
		_guihelper.CheckRadioButtons(radiobuttons, "kidui_t_tex_range3_btn", "255 0 0");
	end
	_guihelper.SafeSetText("kidui_t_tex_range_editbox", tostring(nSize));
end

--[[ called to paint textures on to the terrain surface]]
function Map3DSystem.UI.Terrain.OnTerrainTexturePaint(nIndex)
	local x,y,z;
	local player = ParaScene.GetPlayer();
	if(player:IsValid() == true) then
		x,y,z = player:GetPosition();
	
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_PaintBrush, brush = {
			filename = nIndex or "",
			x=x,
			y=y,
			z=z,
			bErase = (mouse_button == "right"),
		},})
		
		
		Map3DSystem.Animation.SendMeMessage({
				type = Map3DSystem.msg.ANIMATION_Character,
				obj_params = nil, --  <player>
				animationName = "ModifyTerrainTexture",
				});
		
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_Paint,})
	end
end

--[[ user specified brush size]]
function Map3DSystem.UI.Terrain.OnSetCustomTerrainBrushSize()
	local tmp = ParaUI.GetUIObject("kidui_t_range_editbox");
	if(tmp:IsValid()==true) then
		local nSize = tonumber(tmp.text);
		if(nSize~=nil and nSize>=5 and nSize<=250) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_HeightFieldBrush, brush = {radius = nSize}, })
		else
			_guihelper.MessageBox(L"the height field brush size can only be within (5, 250)");
		end
	end
end

function Map3DSystem.UI.Terrain.Reset_TerrainMod()
	Map3DSystem.UI.Terrain.OnSetTerrainBrushSize(20);
	Map3DSystem.UI.Terrain.OnSetTextureBrushSize(2);
end

-- set the current terrain brush size and update the UI
-- @param nSize: if this is nil, the current brush size is used, if not the current brush size will be set accordingly
function Map3DSystem.UI.Terrain.OnSetTerrainBrushSize(nSize)
	ParaAudio.PlayUISound("Btn3");
	-- texture brush radius
	if(nSize~=nil) then
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_HeightFieldBrush, brush = {radius = nSize}, })
	else
		local msg = {type = Map3DSystem.msg.TERRAIN_GET_HeightFieldBrush,}
		Map3DSystem.SendMessage_env(msg)
		nSize = msg.brush.radius;
	end
	
	local radiobuttons = {"kidui_t_range1_btn","kidui_t_range2_btn","kidui_t_range3_btn"};
	if(nSize<=15) then 
		_guihelper.CheckRadioButtons(radiobuttons, "kidui_t_range1_btn", "255 0 0");
	elseif(nSize<=25) then 
		_guihelper.CheckRadioButtons(radiobuttons, "kidui_t_range2_btn", "255 0 0");
	elseif(nSize>25) then 
		_guihelper.CheckRadioButtons(radiobuttons, "kidui_t_range3_btn", "255 0 0");
	end
	_guihelper.SafeSetText("kidui_t_range_editbox", tostring(nSize));
end


function Map3DSystem.UI.Terrain.GaussianHill(height)
	local x,y,z;
	local player = ParaScene.GetPlayer();
	if(player:IsValid()) then
		x,y,z = player:GetPosition();
	
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_HeightFieldBrush, brush = {
			type = "GaussianHill",
			x=x,
			y=y,
			z=z,
			heightScale = height,
		},})
		
		-- play animation according to terrain height operation
		if(height > 0) then
			Map3DSystem.Animation.SendMeMessage({
					type = Map3DSystem.msg.ANIMATION_Character,
					obj_params = nil, --  <player>
					animationName = "RaiseTerrain",
					});
		elseif(height < 0) then
			Map3DSystem.Animation.SendMeMessage({
					type = Map3DSystem.msg.ANIMATION_Character,
					obj_params = nil, --  <player>
					animationName = "LowerTerrain",
					});
		end
		
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_HeightField,})
	end
end

function Map3DSystem.UI.Terrain.Flatten()
	local x,y,z;
	local player = ParaScene.GetPlayer();
	if(player:IsValid()) then
		x,y,z = player:GetPosition();
	
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_HeightFieldBrush, brush = {
			type = "Flatten",
			x=x,
			y=y,
			z=z,
		},})

		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_HeightField,})
	end
end

function Map3DSystem.UI.Terrain.Roughen_Smooth(bRoughen)	
	local x,y,z;
	local player = ParaScene.GetPlayer();
	if(player:IsValid()) then
		x,y,z = player:GetPosition();
	
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_HeightFieldBrush, brush = {
			type = "Roughen_Smooth",
			x=x,
			y=y,
			z=z,
			bRoughen = bRoughen,
		},})

		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_HeightField,})
	end
end

function Map3DSystem.UI.Terrain.OnMouseEnter()
end

function Map3DSystem.UI.Terrain.OnMouseLeave()
end