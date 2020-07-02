--[[
Title: Load world server
Author(s): LiXizhi
Date: 2007/7/31
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/gameserver_loadworld.lua");
GameServer.LoadWorld(worldpath)
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("IDE");
NPL.load("(gl)script/network/ClientServerIncludes.lua");
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/gui_helper.lua");

-- network: Kids UI library 
if(not GameServer) then GameServer={}; end

-- load a world on the game server without a user interface in 3D space. 
function GameServer.LoadWorld(worldpath)
	if(string.find(worldpath, ".*%.zip$")~=nil) then
		-- open zip archive with relative path
		kids_db.world.worldzipfile = worldpath;
		ParaAsset.OpenArchive(worldpath, true);
		ParaIO.SetDiskFilePriority(-1);
		
		local search_result = ParaIO.SearchFiles("","*.", worldpath, 0, 10, 0);
		local nCount = search_result:GetNumOfResult();
		if(nCount>0) then
			-- just use the first directory in the world zip file as the world name.
			local WorldName = search_result:GetItem(0);
			WorldName = string.gsub(WorldName, "[/\\]$", "");
			worldpath = string.gsub(worldpath, "([^/\\]+)%.zip$", WorldName); -- get rid of the zip file extension for display 
		else
			-- make it the directory path
			worldpath = string.gsub(worldpath, "(.*)%.zip$", "%1"); -- get rid of the zip file extension for display 		
		end
		
		kids_db.world.readonly = true;
	else
		kids_db.world.worldzipfile = nil;
		kids_db.world.readonly = nil;	
		ParaIO.SetDiskFilePriority(0);
	end
	
	kids_db.world.name = worldpath;
	kids_db.UseDefaultFileMapping();
	if(ParaIO.DoesFileExist(kids_db.world.sConfigFile, true) == true) then
		if(GameServer.LoadWorld_imp() == true) then
			return true;
		else
			return worldpath..L" failed loading the world."
		end
	else
		return worldpath..L" world does not exist"
	end	
end

function GameServer.LoadWorld_imp()
	-- clear the scene, not the GUI
	server.IsPureServer = true;
	
	-- reset everything except the UI.
	ParaScene.Reset();
	ParaAsset.GarbageCollect();
	collectgarbage();
	log("scene has been reset\n");
	
	-- rebind event
	if(GameServer.ReBindEventHandlers~=nil) then
		GameServer.ReBindEventHandlers();
	end	
	
	if(kids_db.world.sConfigFile ~= "") then
		-- disable the game 
		ParaScene.EnableScene(false);
		
		-- create world
		ParaScene.CreateWorld("", 32000, kids_db.world.sConfigFile); 
		
		-- load from database
		kids_db.LoadWorldFromDB();
		
		-- load different UI for different applications
		if(application_name == "gameserver") then
			-- TODO: do some special UI for game server here
		end
		
		-- we have built the scene, now we can enable the game
		ParaScene.EnableScene(true);
		
		-- call the onload script for the given world
		local sOnLoadScript = ParaWorld.GetWorldDirectory().."onload.lua";
		if(ParaIO.DoesFileExist(sOnLoadScript, true))then
			NPL.activate("(gl)"..sOnLoadScript);
		end

		return true;
	else
		return false;
	end
end