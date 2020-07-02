--[[
Title: Desktop (Mini)Map Area for Aries App
Author(s): WangTian
Date: 2009/4/7
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/MapArea.lua");
MyCompany.Aries.Desktop.MapArea.Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp2.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/Map/LocalMap.lua");
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local LocalMap = commonlib.gettable("MyCompany.Aries.Desktop.LocalMap");
local page;
-- create class
local MapArea = commonlib.gettable("MyCompany.Aries.Desktop.MapArea");

local texdata = { 
    -- {left=18000,top=18000,right=22000,bottom=22000,background="Texture/Aries/WorldMaps/Teen/FlamingPhoenixIsland.png",}, 
};

function MapArea.CreateV2()
	local self = MapArea;
	local _parent = ParaUI.CreateUIObject("container", "MapArea", "_rb", -200, -180, 200, 175);
	_parent.background = "";
	_parent.zorder = -2;
	_parent:GetAttributeObject():SetField("ClickThrough", true);
	_parent:AttachToRoot();
	
	page = page or Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Desktop/MapArea/MapArea.kids.html",click_through = true,
		SelfPaint = System.options.IsMobilePlatform,
	});
	-- one can create a UI instance like this. 
	page:Create("Aries_MiniMapArea_mcml", _parent, "_fi", 98, 81, 0, 0);
end

function MapArea.OnInit()
	page = document:GetPageCtrl();
	NPL.load("(gl)script/apps/Aries/Scene/AutoCameraController.lua");
	MyCompany.Aries.AutoCameraController:Init();
	local Player = commonlib.getfield("MyCompany.Aries.Player");
	if(Player) then
		local curMode = Player.LoadLocalData("CameraMode", "") or "3d";
		
		if(curMode ~= "") then
			MyCompany.Aries.AutoCameraController:ApplyStyle(curMode);
			page:SetValue("btnCameraMode", curMode=="3d");
		else
		end
		
		-- load music state
		local bEnableMusic = MyCompany.Aries.Player.LoadLocalData("enable_music", true);
		if(bEnableMusic)then
			ParaAudio.SetVolume(1);
		else
			ParaAudio.SetVolume(0);
		end
		page:SetNodeValue("EnableSound", bEnableMusic);
	end
end

-- refresh camera mode
function MapArea.RefreshCameraMode(show_marker)
	if(page) then
		local Player = commonlib.getfield("MyCompany.Aries.Player");
		local curMode = Player.LoadLocalData("CameraMode", "") or "3d";
		if(curMode ~= "") then
			page:SetValue("btnCameraMode", curMode=="3d");
		end
		MapArea.IsShowCameraTip = show_marker;
		page:Refresh(0.01);
	end
end

-- virtual function: Create UI
function MapArea.Create()
	local _mapArea = ParaUI.CreateUIObject("container", "MapArea", "_lb", 12, -82, 64, 64);
	_mapArea.background = "";
	_mapArea:GetAttributeObject():SetField("ClickThrough", true);
	_mapArea:AttachToRoot();
	
	local _map = ParaUI.CreateUIObject("button", "Map", "_lt", 0, 0, 64, 64);
	_map.background = "Texture/Aries/Dock/Web/Map_32bits.png; 0 0 64 64";
	_map.animstyle = 22;
	_map.onclick = ";System.App.Commands.Call(\"Profile.Aries.LocalMap\");";
	_map.tooltip = "地图 (M)";
	_mapArea:AddChild(_map);

	local _this = ParaUI.CreateUIObject("button", "TeleportBack", "_lt", 0, 18, 64, 21);
	_this.text = "返回主城";
	_this.font = "System;12;bold";
	_this:SetScript("onclick", function()
		NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
		local world_info = WorldManager:GetCurrentWorld()
		local s = string.format("确认要离开【%s】吗？",world_info.world_title or "");
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.Yes)then
				WorldManager:TeleportBack();
			end
		end,_guihelper.MessageBoxButtons.YesNo);
	end)
	_this.visible = false;
	_mapArea:AddChild(_this);
end

-- virtual Public API:enable map teleporting button
function MapArea.EnableButton()
	local _mapArea = ParaUI.GetUIObject("MapArea");
	if(_mapArea:IsValid() == true) then
		_mapArea:GetChild("Map").enabled = true;
	end
end

-- virtual Public API: disable map teleporting button
function MapArea.DisableButton()
	local _mapArea = ParaUI.GetUIObject("MapArea");
	if(_mapArea:IsValid() == true) then
		_mapArea:GetChild("Map").enabled = false;
	end
end

function MapArea.DS_Func_MapTexture(index)
	if(index==nil)then
        return #texdata;
    else
        return texdata[index];
    end
end

-- call this function to enable music programmatically. 
function MapArea.EnableMusic(bChecked)
	if(page) then
		if(page) then
			page:SetValue("EnableSound", bChecked)
		end
		MapArea.OnClickToggleMusic(bChecked);
	else
		local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");
		if(AntiIndulgenceArea.OnClickEnableSound_BySetting) then
			AntiIndulgenceArea.OnClickEnableSound_BySetting(bChecked);
		end
	end
end

-- toggle music. this is onclick callback
function MapArea.OnClickToggleMusic(bChecked)
	if(bChecked)then
		ParaAudio.SetVolume(1);
	else
		ParaAudio.SetVolume(0);
	end
	MyCompany.Aries.Player.SaveLocalData("enable_music",bChecked);
end

function MapArea.SetBtnTime(time)
	--if(QuestHelp.IsPowerUser(Map3DSystem.User.nid))then
		--return
	--end
	if(page)then
		page:SetValue("timeBtn",time);
	end
end

-- if a map is specified, and should be displayed. 
-- a instanced world has no map, and the map area displays a exit button by which to exit the current scene.  
function MapArea.HasLocalMap()
	return #texdata > 0;
end

function MapArea.OnActivateDesktop()
	local cur_world = WorldManager:GetCurrentWorld();
	if(cur_world and cur_world.local_map_settings) then
		texdata[1] = cur_world.local_map_settings;
	else
		texdata[1] = nil;
	end

	if(page) then
		page:Refresh();
	else
		-- toggle leave town button
		local _mapArea = ParaUI.GetUIObject("MapArea");
		if(_mapArea:IsValid()) then
			_mapArea:GetChild("TeleportBack").visible = WorldManager:IsInInstanceWorld();
		end
	end
end
