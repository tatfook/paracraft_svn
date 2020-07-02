--[[
Title: Load world server
Author(s): LiXizhi
Date: 2007/7/31
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/gameserver_hostworld.lua");
GameServer.HostWorld()
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("IDE");
NPL.load("(gl)script/network/gameserver_loadworld.lua");
NPL.load("(gl)script/network/ClientServerIncludes.lua");
NPL.load("(gl)script/network/KM_WorldDownloader.lua");
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/gui_helper.lua");

-- network: Kids UI library 
if(not GameServer) then GameServer={}; end

-- load the personal world associated with the user name and make it a game server. 
function GameServer.HostWorld()
	if(not GameServer.HostingInProgress) then
		GameServer.HostingInProgress = true;
		KM_WorldDownloader.NewTask({source="http://www.kids3dmovie.com/"..kids_db.User.Name, type = KM_WorldDownloader.TaskType.NormalWorld,
			onstop = GameServer.OnHostWorldStop, oncomplete = GameServer.OnHostWorldComplete,
		});
	else
		log("正在做主机中...");
	end
end

function GameServer.OnHostWorldStop(task)
	GameServer.HostingInProgress = nil;
	log("无法同步Space Server，原因是:\n"..tostring(task.errormessage));
	if(not task.errormessage) then
		log("This may caused by the DNS is down or the game server does not have HTTP access to the domain server.\n");
	end
	if(GameServer.DefaultHostWorld~=nil) then
		task.worldpath = GameServer.DefaultHostWorld;
		log("WARNING: Failed sync with domain and space server, instead, the game server used the defaultworld specified from command line. Please note: that this world is not sync with the space server or domain server. It may be an inconsistent world with what users see.");
		GameServer.OnHostWorldComplete(task);
	else
		ParaGlobal.ExitApp();
	end
end

function GameServer.OnHostWorldComplete(task)
	GameServer.HostingInProgress = nil;
	
	log("主机世界文件为:"..tostring(task.worldpath).."\n");
	
	-- try starting a server world at hostworldfile
	local worldpath = task.worldpath;
	if(GameServer.LoadWorld(worldpath)) then
		ParaNetwork.Restart();
		ParaWorld.SetServerState(1);
		CommonCtrl.chat_display.AddText("chat_display1", string.format("[server started]:\nInternalID:%s\nExternalID:%s",ParaNetwork.GetInternalID(), ParaNetwork.GetExternalID(kids_db.User.Name)));
	else
		-- TODO: if the world does not exist, ask the user to create one.
		log(L"you does not have a personal world yet. Please create a new world with your user name "..kids_db.User.Name);
	end		
end

-- to restart the game server.This function is only functional when this engine is the game server
-- it will display a dialog asking for confirmation, and then restart the game server. 
-- Once a game server is restarted, the server world is reloaded losing all unsaved changes, all connected clients
-- also restarted to synchronous with the new game world on the game server. 
function GameServer.OnClickRestartGameserver()
	if(ParaWorld.GetServerState() ~= 1) then
		log("You need to host a game server first in order to restart it");
		return
	end
	_guihelper.MessageBox("Are you sure that you want to restart the server? \r\nNote: Once a game server is restarted, the server world is reloaded losing all unsaved changes.", function()
		if(server.RestartGameServer()) then
		else
			log("error: failed to restart\r\n");
		end
	end);
end