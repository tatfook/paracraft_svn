--[[
Title: Main In-game UI for 3D Map system
Author(s): WangTian
Date: 2007/8/22
Desc: Show the main game UI
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/kids/ui/Load3DMapSystemUI.lua");
------------------------------------------------------------
]]
-- load library
NPL.load("(gl)script/network/ClientServerIncludes.lua");
NPL.load("(gl)script/kids/ui/left_container.lua");
NPL.load("(gl)script/kids/ui/right_container.lua");
NPL.load("(gl)script/kids/ui/middle_container.lua");
NPL.load("(gl)script/kids/ui/itembar_container.lua");
NPL.load("(gl)script/kids/ui/Help.lua");
NPL.load("(gl)script/movie/ClipMovieCtrl.lua");
NPL.load("(gl)script/ide/chat_display.lua");
NPL.load("(gl)script/kids/event_handlers.lua");
NPL.load("(gl)script/kids/Ui/autotips.lua");

NPL.load("(gl)script/kids/CCS/CCS_db.lua");

NPL.load("(gl)script/ide/commonlib.lua");

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

NPL.load("(gl)script/kids/3DMapSystemUI/MainMenu.lua");
--NPL.load("(gl)script/kids/3DMapSystemUI/MapExplorer.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame.lua");

-- Debug purpose
NPL.load("(gl)script/ide/gui_helper.lua");

local L = CommonCtrl.Locale("Kids3DMap");

-- KidsUI: Kids UI library 
if(not KidsUI) then KidsUI={}; end

local function activate()

	State_3DMapSystem = TargetState;
	
	if(State_3DMapSystem == "Startup") then
	
		--Map3DSystem.UI.Login.LoadStartupUI();
		
	elseif(State_3DMapSystem == "MainMenu") then
	
		Map3DSystem.UI.MainMenu.LoadMainMenuUI();
		
	--elseif(State_3DMapSystem == "MapExplorer") then
	--
		--Map3DSystem.UI.MapExplorer.LoadMapExplorerUI();
	
	elseif(State_3DMapSystem == "InGame") then
	
		Map3DSystem.UI.LoadInGameUI();
		
	end

end
NPL.this(activate);

--function Map3DSystem.UI.SwitchToState(targetState)
--
	--if(targetState == "Startup") then
	--
		--State_3DMapSystem = "Startup";
		--NPL.activate("(gl)script/kids/ui/Load3DMapSystemUI.lua");
		--
	--elseif(targetState == "MainMenu") then
	--
		--State_3DMapSystem = "MainMenu";
		--NPL.activate("(gl)script/kids/ui/Load3DMapSystemUI.lua");
		--
	----elseif(targetState == "MapExplorer") then
	----
		----State_3DMapSystem = "MapExplorer";
		----NPL.activate("(gl)script/kids/ui/Load3DMapSystemUI.lua");
	--
	--elseif(targetState == "InGame") then
	--
		--State_3DMapSystem = "InGame";
		--NPL.activate("(gl)script/kids/ui/Load3DMapSystemUI.lua");
		--
	--end
--end