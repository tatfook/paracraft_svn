--[[
Title: Load UI in addition to LoadMainGameUI.lua
Author(s): WangTian
Date: 2007/8/28
Desc: Show the main game UI
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/kids/ui/Load3DMapAdditionalUI.lua");
------------------------------------------------------------



------------------------------------------------------------
NOTE: THIS IS A DUMMY FILE NEVER USE IT
------------------------------------------------------------




]]
-- load library
NPL.load("(gl)script/network/ClientServerIncludes.lua");
NPL.load("(gl)script/kids/ui/Help.lua");
NPL.load("(gl)script/movie/ClipMovieCtrl.lua");
NPL.load("(gl)script/ide/chat_display.lua");
NPL.load("(gl)script/kids/event_handlers.lua");
NPL.load("(gl)script/kids/Ui/autotips.lua");

NPL.load("(gl)script/kids/CCS/CCS_db.lua");

NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/ui/LoadMainGameUI.lua");

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

-- Debug purpose
NPL.load("(gl)script/ide/gui_helper.lua");

local L = CommonCtrl.Locale("Kids3DMap");

-- KidsUI: Kids UI library 
if(not KidsUI) then KidsUI={}; end

local function activate()
	
	if(State_3DMapSystem == "Startup") then
		log("error activate Load3DMapAdditionalUI.lua\r\n");
	elseif(State_3DMapSystem == "MainMenu") then
		log("error activate Load3DMapAdditionalUI.lua\r\n");
	elseif(State_3DMapSystem == "InGame") then
		
		local userURL = Map3DSystem.UserWorldURL;
		local naviURL = Map3DSystem.CurrentNavigatingSpaceURL;
		if(userURL ~= nil and naviURL ~= nil) then
			if( userURL == naviURL ) then
				Map3DSystem.IsOwner = true;
			else
				Map3DSystem.IsOwner = false;
			end
		end
		
		local _this, _parent;
		
		local _width, _height = 200, 600;
		local _height_Icon = 100;
		local _height_Info = 100;
		local _height_Board = 200;
		
		_this = ParaUI.CreateUIObject("container", "Kids3DMap_Ingame_LeftBox","_lt", 0, 0, _width, _height);
		_this.background = "";
		_this:AttachToRoot();
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("container", "Kids3DMap_Ingame_LeftBox_Icon", "_lt", 0, 0, _height_Icon, _height_Icon)
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "Kids3DMap_Ingame_LeftBox_Info", "_lt", 0, _height_Icon, _width, _height_Info)
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "Kids3DMap_Ingame_LeftBox_Board", "_lt", 0, _height_Icon + _height_Info, _width, _height_Board)
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "Kids3DMap_Ingame_LeftBox_InfoText", "_lt", 10, _height_Icon + 10, _width - 20, _height_Info - 20)
		_this.text = "Info";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "Kids3DMap_Ingame_LeftBox_BoardText", "_lt", 10, _height_Icon + _height_Info + 10, _width - 20, _height_Board - 20)
		_this.text = "Board";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Kids3DMap_Ingame_LeftBox_Postbutton", "_lt", 10, _height_Icon + _height_Info - 40, 128, 32)
		_this.text = "Post";
		_this.onclick = ";Map3DSystem.PrintMap3DSystemTable();";
		_parent:AddChild(_this);
		
		Map3DSystem.GetSpaceInfo_Callback(naviURL);
		
	end

end
NPL.this(activate);


-- web service call back
function Map3DSystem.GetSpaceInfo_Callback(SpaceURL)

	Map3DSystem.NavigatingSpaceUserLevel = 100;
	Map3DSystem.NavigatingSpaceUserSpaceViews = 2180;
	
	local _this = ParaUI.GetUIObject("Kids3DMap_Ingame_LeftBox_InfoText");

	if(_this:IsValid()) then
		_this.text = L"User Level:" .. Map3DSystem.NavigatingSpaceUserLevel .."\r\n"
					.. L"Space Views:" .. Map3DSystem.NavigatingSpaceUserSpaceViews;
	end
end


function Map3DSystem.PrintMap3DSystemTable()
	-- print Map3DSystem table
	commonlib.SaveTableToFile(Map3DSystem, "TestTable/Map3DSystem.ini", true);
	commonlib.SaveTableToFile(kids_db, "TestTable/Kids_DB.ini", true);
	commonlib.SaveTableToFile(KidsUI, "TestTable/KidsUI.ini", true);
	--commonlib.SaveTableToFile(Kids, "TestTable/Map3DSystem.ini", true);
end