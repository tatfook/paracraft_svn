--[[
Title: Map explorer UI for 3D Map system
Author(s): WangTian
Date: 2007/8/30
Desc: Show the map explorer UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MapExplorer.lua");
Map3DSystem.UI.MapExplorer.ToggleMapExplorerUI();
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");


function Map3DSystem.UI.MapExplorer.ToggleMapExplorerUI()


	local _cont = ParaUI.GetUIObject("Kids3DMap_MapExplorer");
	
	local _this, _parent;
	--_this = ParaUI.GetUIObject("Kids3DMap_LoginBox");
	--if(_this:IsValid() == true) then
		--_this.visible = not _this.visible;
	--end
	
	_this = ParaUI.GetUIObject("Kids3DMap_MainMenuBox_NewsBox");
	if(_this:IsValid() == true) then
		_this.visible = not _this.visible;
	end
	
	-- TODO: invisible left and middle container
		
	if(_cont:IsValid()==false) then
		
		local _width, _height = 800, 600;
		local _top_height = 200;
		local _icon_width, _info_width, _bbs_width = 200, 200, 400;
		
		_this = ParaUI.CreateUIObject("container","Kids3DMap_MapExplorer", "_fi", 0, 0, 0, 0);
		_this:AttachToRoot();
		_this.background = "";
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("container","Kids3DMap_MapExplorer_Wnd", "_ct",-_width/2, -_height/2, _width, _height);
		_parent:AddChild(_this);
		_this.background = "";
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("3dcanvas", "Kids3DMap_MapExplorer_Icon", "_lt", 0, 0, _icon_width, _top_height)
		_parent:AddChild(_this);
		_this.canvasindex=0;
		_this.background="Texture/whitedot.png;0 0 0 0";
		
		_this = ParaUI.CreateUIObject("container", "Kids3DMap_MapExplorer_InfoBox", "_lt", _icon_width, 0, _info_width, _top_height)
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "Kids3DMap_MapExplorer_InfoText", "_lt", _icon_width + 10, 10, _info_width-10, _top_height-10)
		_parent:AddChild(_this);
		
		
		
		_this = ParaUI.CreateUIObject("container", "Kids3DMap_MapExplorer_BBSBox", "_lt", _icon_width + _info_width, 0, _bbs_width, _top_height)
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "Kids3DMap_MapExplorer_BBSText", "_lt", _icon_width + _info_width + 10, 10, _bbs_width-10, _top_height-40)
		_this.text = "BBS";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("editbox", "Kids3DMap_MapExplorer_SpeakTextbox", "_rt", -_bbs_width, _top_height-30, _bbs_width - 95, 30)
		_this.text = "Speak";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Kids3DMap_MapExplorer_SpeakButton", "_rt", -90, _top_height-30, 90, 30)
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Kids3DMap_MapExplorer_Info_MyworldBtn", "_lt", _icon_width + 40, _top_height-50, 128, 32)
		_this.text = L"Enter My World!";
		_parent:AddChild(_this);
		
		Map3DSystem.UI.MapExplorer.GetUserInfo_Callback();
		
		-- _this is still Kids3DMap_MapExplorer_Info_MyworldBtn
		_this.tooltip = "UserWorldURL";--Map3DSystem.UserWorldURL;
		
		NPL.load("(gl)script/network/MapExplorerWnd.lua");
		local ctl = CommonCtrl.MapExplorerWnd:new{
			name = "Temp_MapExplorerWnd1",
			alignment = "_lt",
			left = 0, top = _top_height,
			width = _width,
			height = _height - _top_height,
			parent = _parent,
		};
		ctl:Show();
	else
		
	end
	
	_cont = ParaUI.GetUIObject("Kids3DMap_MapExplorer");
	
	if(Map3DSystem.UI.MapExplorer.IsShowMapExplorerUI == false) then
		_cont.visible = true;
		Map3DSystem.UI.MapExplorer.IsShowMapExplorerUI = true;
	elseif(Map3DSystem.UI.MapExplorer.IsShowEscPopupUI == true) then
		_cont.visible = false;
		Map3DSystem.UI.MapExplorer.IsShowMapExplorerUI = false;
	else -- Map3DSystem.UI.MapExplorer.IsShowMapExplorerUI == nil
		_cont.visible = true;
		Map3DSystem.UI.MapExplorer.IsShowMapExplorerUI = true;
	end
	
	-- TODO: add to map system
	Map3DSystem.UI.MapExplorer.OnEnterSpace();
	
end

function Map3DSystem.UI.MapExplorer.OnEnterSpace()
	--State_3DMapSystem = "InGame";
	Map3DSystem.World.SpaceURL = "http://www.minixyz.com/TEST_Nav";
end

-- TODO: web service call back
function Map3DSystem.UI.MapExplorer.GetUserInfo_Callback()

	Map3DSystem.User.Level = 10;
	Map3DSystem.User.UserPie = 1902;
	--Map3DSystem.UserWorldURL = "http://www.minixyz.com/TEST";
	
	local _this = ParaUI.GetUIObject("Kids3DMap_MapExplorer_InfoText");
	if(_this:IsValid()) then
		_this.text = L"User Level:" .. Map3DSystem.User.Level .."\r\n"
					.. L"Space Views:" .. "TODO" .."\r\n"
					.. L"Pie:" .. Map3DSystem.User.UserPie;
	end
end