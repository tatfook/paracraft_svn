--[[
Title: a server that initialize a client
Author(s): LiXizhi
Date: 2006/11/5
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/ClientServerIncludes.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/chat_display.lua");

if(not server) then server={}; end

-- server version
server.ServerVersion = 1;

-- required client version
server.ClientVersion = 1;

-- if true, the game server is a dedicated server usually without any user interface. Pure server will use a different restart function. 
server.IsPureServer = nil;

-- When the server has broadcasted this number of objects, the server will be automatically restarted; this is usually the setting for testing public server.
server.RestartOnCreateNum = tonumber(ParaEngine.GetAppCommandLineByParam("RestartOnCreateNum", "0"));

-- some statistics
server.statistics = {
	StartTime = ParaGlobal.GetDateFormat(nil)..ParaGlobal.GetTimeFormat(nil),
	OnlineUserNum = 0,
	VisitsSinceStart = 0,
	NumObjectCreated = 0,
}
function server.OnNewIncomingConnection(username)
	-- _guihelper.MessageBox("用户登陆到本服务器："..msg.username.."\r\n");
	if(KidsUI_ShowChatWindow~=nil) then
		KidsUI_ShowChatWindow(true);
		CommonCtrl.chat_display.AddText("chat_display1", "用户登陆到本服务器："..username);
	end	
	
	-- randomly generate the spawn position for the incoming user. The spawn position is within a certain radius of the current player. 
	local OnlineUserNum = ParaNetwork.GetConnectionList(0);
	local radius = 10+math.sqrt(OnlineUserNum+1)*3;
	local player = ParaScene.GetPlayer();
	local px,py,pz = player:GetPosition();
	local x = (math.random()*2-1)*radius + px;
	local z = (math.random()*2-1)*radius + pz;
	if(x<0) then x=0 end
	if(z<0) then z=0 end
	local y = ParaTerrain.GetElevation(x,z);
	
	-- TODO: authenticate user, if failed its role can only be "guest"
	local UserRole = "friend"; -- make it friend for testing purposes
	
	-- TODO: Remove this: we will make any one whose name contains "LiXizhi" , "poweruser".
	if(string.find(username, "LiXizhi") ~= nil) then
		UserRole = "poweruser";
	end
	
	local msg = {
		type = KMNetMsg.SC_InitGame, -- SC: InitGame: first and basic world information.
		worldpath = ParaWorld.GetWorldDirectory(),
		worldname = ParaWorld.GetWorldName(),
		desc = "TODO",
		x=x,
		y=y,
		z=z,
		-- TODO: authenticate to decide "guest", "administrator", "friend"
		Role = UserRole,
		OnlineUserNum = OnlineUserNum,
		StartTime = server.statistics.StartTime,
		VisitsSinceStart = server.statistics.VisitsSinceStart,
		ServerVersion = server.ServerVersion, 
		ClientVersion = server.ClientVersion, 
	};
	NPL.activate(username.."@local:script/client/init_client.lua", msg);
	
	server.statistics.VisitsSinceStart = server.statistics.VisitsSinceStart+1;
end

-- Once a game server is restarted, the server world is reloaded losing all unsaved changes, all connected clients
-- also restarted to synchronous with the new game world on the game server. 
-- return true if success
function server.RestartGameServer()
	
	-- restart the world
	local worldpath = kids_db.world.worldzipfile or kids_db.world.name;
	
	-- use a different load world function according to whether the server is pure. 
	local LoadWorldFunction;
	if(server.IsPureServer and GameServer~=nil) then
		NPL.load("(gl)script/network/gameserver_loadworld.lua");
		LoadWorldFunction = GameServer.LoadWorld;
	else
		LoadWorldFunction = KidsUI.LoadWorldImmediate;
	end
	
	if( LoadWorldFunction~=nil and LoadWorldFunction(worldpath)) then
		-- restart local world on the server
		ParaWorld.SetServerState(1);
	
		-- tell all clients that this server is restarted
		local player = ParaScene.GetPlayer();
		local px,py,pz = player:GetPosition();
				
		local msg = {
			type = KMNetMsg.SC_RestartGame, -- restart the game server.
			worldzipfile = kids_db.world.worldzipfile,
			worldpath = ParaWorld.GetWorldDirectory(),
			worldname = ParaWorld.GetWorldName(),
			desc = "TODO",
			x=px,
			y=py,
			z=pz,
		};
		NPL.activate("all@local:script/client/init_client.lua", msg);
		return true;
	end	
end


local function activate()
	if(msg.type == KMNetMsg.CS_RestartGame) then
		-- TODO: need a serious authentication, here anyone whose name contains "LiXizhi" is authenticated.
		if(string.find(msg.username, "LiXizhi")~=nil) then
			server.RestartGameServer();
		end
	end
end
NPL.this(activate);
