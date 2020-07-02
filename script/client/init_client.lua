--[[
Title: a initialize client
Author(s): LiXizhi
Date: 2006/11/5
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/ClientServerIncludes.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/kids/kids_db.lua");
NPL.load("(gl)script/kids/loadworld.lua");
local L = CommonCtrl.Locale("IDE");

if(not client) then client={}; end

-- client version
client.ClientVersion = 1;

-- required server version
client.ServerVersion = 1;

-- login to a server with a known name
function client.LoginToServer(serverName)
	-- login to NPL runtime, if we have not done so. 
	log("try connecting to "..serverName.."\r\n");
	ParaNetwork.ConnectToCenter(serverName);
end

-- it just displays whatever messages it receive. 
local function activate()
	if(msg.type == KMNetMsg.SC_InitGame) then
		local bWorldPrepared = (msg.worldpath==ParaWorld.GetWorldDirectory());
		--log("local world dir "..ParaWorld.GetWorldDirectory().."\n")
		--log("serverworld dir "..msg.worldpath.."\n")
		
		-- it will load the game scene if it is not already loaded. 
		if(not bWorldPrepared) then
			-- figure out the exact name of the world to load
			local len = string.len(msg.worldpath);
			local worldpath; 
			if(len>1) then
				worldpath = string.sub(msg.worldpath, 1, len-1);
			else
				worldpath = msg.worldpath;
			end
			kids_db.world.name = worldpath;
			kids_db.UseDefaultFileMapping();
			
			--[[
			-- create the world if it does not exist and that the worldpath is under worlds/ directory
			if(string.find(worldpath, "worlds/") ~= nil) then
				if(ParaIO.DoesFileExist(kids_db.world.sConfigFile, true) == false) then
					NPL.load("(gl)script/kids/newworld.lua");
					KidsUI.CreateWorldImmediate(kids_db.world.name);
				end
			end	
			--]]
			
			-- set main player name
			kids_db.player.name = ParaNetwork.GetLocalNerveCenterName();
			
			-- load the world
			bWorldPrepared = KidsUI.LoadWorldImmediate(worldpath);
		end
		
		-- if world is prepared and loaded, we will set player position and begin normal updates with the server.
		if(bWorldPrepared) then
			
			-- check client and server version. 
			if(not msg.ClientVersion or not msg.ServerVersion or msg.ClientVersion >client.ClientVersion or msg.ServerVersion <client.ServerVersion) then
				-- client and server version does not match.
				-- TODO: display exact reason to the user. 
				_guihelper.MessageBox(L"Sorry your client and server version does not match, please update your client or the server.");
				-- disable network, so that it is an offline world.
				ParaNetwork.EnableNetwork(false, "","");
				return;
			end
			
			-- the server tells the role of clients
			if(not msg.Role) then
				msg.Role = "guest"
			end
			kids_db.User.SetRole(msg.Role);
			if(not msg.OnlineUserNum) then
				msg.OnlineUserNum = 0;
			end
			if(not msg.StartTime) then
				msg.StartTime = ParaGlobal.GetDateFormat(nil)..ParaGlobal.GetTimeFormat(nil);
			end
			if(not msg.VisitsSinceStart) then
				msg.VisitsSinceStart = 0;
			end
			
			_guihelper.MessageBox(string.format(L"Successfully logged in. \nworld name: %s\nRole: %s\nOnline users:%d\nGame Server Start Time:%s\nVisits: %d\n",
				kids_db.world.name, msg.Role, msg.OnlineUserNum, msg.StartTime, msg.VisitsSinceStart));
				
			-- set the spawn position.
			local player = ParaScene.GetPlayer();
			player:SetPosition(msg.x, msg.y, msg.z);
			player:UpdateTileContainer();
			-- change simulator to client state and begins sending normal updates.
			ParaWorld.SetServerState(2);
		else
			_guihelper.MessageBox(string.format(L"The server world is not synchronized with the local machine. Failed connecting to %s", kids_db.world.name));	
		end
	elseif(msg.type==KMNetMsg.SC_RestartGame) then
		-- the remote game server is restarted, we will display a dialog to inform the user and then load the user world. 
		
		--[[ retrieve the basic server world information. 
		local len = string.len(msg.worldpath);
		local worldpath; 
		if(len>1) then
			worldpath = string.sub(msg.worldpath, 1, len-1);
		else
			worldpath = msg.worldpath;
		end
		
		kids_db.world.name = worldpath;
		kids_db.UseDefaultFileMapping();
		
		-- create the world if it does not exist and that the worldpath is under worlds/ directory
		if(string.find(worldpath, "worlds/") ~= nil) then
			if(ParaIO.DoesFileExist(kids_db.world.sConfigFile, true) == false) then
				NPL.load("(gl)script/kids/newworld.lua");
				KidsUI.CreateWorldImmediate(kids_db.world.name);
			end
		end	
		--]]
		
		local worldpath = kids_db.world.worldzipfile or kids_db.world.name;
		-- load the game.
		if(KidsUI.LoadWorldImmediate(worldpath)) then
			-- set the spawn position.
			
			-- randomly generate a spawn position near the server player
			local radius = 20;
			local px,py,pz = msg.x, msg.y, msg.z;
			local x = (math.random()*2-1)*radius + px;
			local z = (math.random()*2-1)*radius + pz;
			if(x<0) then x=0 end
			if(z<0) then z=0 end
			local y = ParaTerrain.GetElevation(x,z);
	
			local player = ParaScene.GetPlayer();
			player:SetPosition(x,y,z);
			
			player:UpdateTileContainer();
			-- change simulator to client state and begins sending normal updates.
			ParaWorld.SetServerState(2);
			
			-- display a dialog to inform the user
			_guihelper.MessageBox(string.format(L"The remote game server %s has just been restarted.", msg.worldpath));
		else
			_guihelper.MessageBox(string.format(L"The server world is not synchronized with the local machine. Failed connecting to %s", kids_db.world.name));	
		end
	end
end

NPL.this(activate);
