--[[
Title: synchronizing a remote world with this local computer
Author(s): LiXizhi
Date: 2007/6/21
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/KM_HostAndJoinWorld.lua");
KM_HostAndJoinWorld.OnClickHostWorld();
KM_HostAndJoinWorld.OnClickJoinWorld(UserURL);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/network/KM_WorldDownloader.lua");

local L = CommonCtrl.Locale("KidsUI");

if(not KM_HostAndJoinWorld) then KM_HostAndJoinWorld={}; end

------------------------------------------------------------
-- host functions
------------------------------------------------------------

-- load the personal world associated with the user and make it a server. 
function KM_HostAndJoinWorld.OnClickHostWorld()
	if(not KM_HostAndJoinWorld.HostingInProgress) then
		KM_HostAndJoinWorld.HostingInProgress = true;
		KM_WorldDownloader.ShowUIForTask(KM_WorldDownloader.NewTask({source="http://www.kids3dmovie.com/"..kids_db.User.Name, type = KM_WorldDownloader.TaskType.NormalWorld,
			onstop = KM_HostAndJoinWorld.OnHostWorldStop, oncomplete = KM_HostAndJoinWorld.OnHostWorldComplete,
		}));
	else
		_guihelper.MessageBox("正在做主机中...");
	end
end

function KM_HostAndJoinWorld.OnHostWorldStop(task)
	KM_HostAndJoinWorld.HostingInProgress = nil;
	_guihelper.MessageBox("无法做主机原因是:\n"..tostring(task.errormessage));
end
function KM_HostAndJoinWorld.OnHostWorldComplete(task)
	KM_HostAndJoinWorld.HostingInProgress = nil;
	
	-- try starting a server world at hostworldfile
	local worldpath = task.worldpath;
	if(KidsUI.LoadWorldImmediate(worldpath)) then
		kids_db.User.SetRole("administrator");
		ParaNetwork.Restart();
		ParaWorld.SetServerState(1);
		CommonCtrl.chat_display.AddText("chat_display1", string.format("[server started]:\nInternalID:%s\nExternalID:%s",ParaNetwork.GetInternalID(), ParaNetwork.GetExternalID(kids_db.User.Name)));
	else
		-- TODO: if the world does not exist, ask the user to create one.
		_guihelper.MessageBox(L"you does not have a personal world yet. Please create a new world with your user name "..kids_db.User.Name);
	end		
end

-- to restart the game server.This function is only functional when this engine is the game server
-- it will display a dialog asking for confirmation, and then restart the game server. 
-- Once a game server is restarted, the server world is reloaded losing all unsaved changes, all connected clients
-- also restarted to synchronous with the new game world on the game server. 
function KM_HostAndJoinWorld.OnClickRestartGameserver()
	if(ParaWorld.GetServerState() ~= 1) then
		_guihelper.MessageBox("You need to host a game server first in order to restart it");
		return
	end
	_guihelper.MessageBox("Are you sure that you want to restart the server? \r\nNote: Once a game server is restarted, the server world is reloaded losing all unsaved changes.", function()
		if(server.RestartGameServer()) then
		else
			log("error: failed to restart\r\n");
		end
	end);
end

------------------------------------------------------------
-- join functions
------------------------------------------------------------
-- called when entering the 3d world. 
function KM_HostAndJoinWorld.OnClickJoinWorld(UserURL)
	-- only enter the 3d world, when we have successfully retrieved the 3d world IPs.
	if(not KM_HostAndJoinWorld.JoiningInProgress ) then
		KM_HostAndJoinWorld.JoiningInProgress = true;
		KM_WorldDownloader.ShowUIForTask(KM_WorldDownloader.NewTask({source=UserURL, type = KM_WorldDownloader.TaskType.NormalWorld,
			onstop = KM_HostAndJoinWorld.OnJoinWorldStop, oncomplete = KM_HostAndJoinWorld.OnJoinWorldComplete,
		}));
	else
		_guihelper.MessageBox("正在做主机中...");
	end
end


function KM_HostAndJoinWorld.OnJoinWorldStop(task)
	KM_HostAndJoinWorld.JoiningInProgress = nil;
	_guihelper.MessageBox("无法做连接原因是:\n"..tostring(task.errormessage));	
end

function KM_HostAndJoinWorld.OnJoinWorldComplete(task)
	KM_HostAndJoinWorld.JoiningInProgress = nil;
	
	-- enter the world without user intervention
	KM_WorldDownloader.EnterNetWorld(task);
end