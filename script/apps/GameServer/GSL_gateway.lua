--[[
Title:  GSL gateway 
Author(s): LiXizhi
Date: 2009/7/30
Desc: it helps the user to find the best grid node server for a given region in a given world.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_gateway.lua");
Map3DSystem.GSL.gateway:Restart(configfile);

local gateway = commonlib.gettable("Map3DSystem.GSL.gateway");
local user = gateway:GetUser(nid)
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_clientproxy.lua");
NPL.load("(gl)script/apps/GameServer/GSL_stat.lua");
NPL.load("(gl)script/apps/IMServer/IMserver_broker.lua");
NPL.load("(gl)script/apps/GameServer/GSL_grid.lua");
NPL.load("(gl)script/apps/GameServer/GSL_user.lua");
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatMessage.lua");
local ChatMessage = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatMessage");
local GSL = commonlib.gettable("Map3DSystem.GSL");
local GSL_grid = commonlib.gettable("Map3DSystem.GSL_grid");
local GSL_homegrid = commonlib.gettable("Map3DSystem.GSL_homegrid");
local GSL_msg = commonlib.gettable("Map3DSystem.GSL.GSL_msg");
local GSL_proxy = commonlib.gettable("Map3DSystem.GSL.GSL_proxy");
local GSL_stat = commonlib.gettable("Map3DSystem.GSL.GSL_stat");
local IMServer_broker = commonlib.gettable("IMServer_broker");
local system = commonlib.gettable("Map3DSystem.GSL.system");
local user_class = commonlib.gettable("Map3DSystem.GSL.user_class");

local string_match = string.match;
local string_gfind = string.gfind;
local string_gsub = string.gsub;
local tostring = tostring
local tonumber = tonumber
local NPL_activate = NPL.activate;
local LOG = LOG;

-- for logging
local thread_or_word = "";

-- the disconnect message, 
local disconnect_msg = {type="OnUserDisconnect", nid=nil,};
------------------------------
-- a gateway, stores all users connecting to the server (grid server)
------------------------------

local gateway = commonlib.gettable("Map3DSystem.GSL.gateway");
-- a mapping from nid to GridUser info
gateway.users = {};
-- gate way session key, it is regenerated each time gateway is restarted. This is different from grid node session key. 
gateway.sessionkey = ParaGlobal.GenerateUniqueID();
-- the config file
gateway.configfile = nil;
-- for sending messages to all or any clients.
gateway.clientProxy = nil;
-- the config table of {nid, ws_id, addr, homegrids}
gateway.config = nil;
-- 20000 milliseconds, for background task timer
gateway.TimerInterval = 20000;
-- ignore sending gsl stat to web db server if true.
--gateway.ignoreWebGSLStat = true;

-- we will only send agent stat when it diff since last send, such as 1
local mini_send_agent_diff = 10;
-- we will at least send one agent at this interval. such as 200000
local max_send_interval = 200000;



-- reset
function gateway:Reset()
	self.users = {};
	self.sessionkey = ParaGlobal.GenerateUniqueID();
	
	if(	self.clientProxy) then
		self.clientProxy:Reset();
	else
		self.clientProxy = Map3DSystem.GSL.ClientProxy:new({
			DefaultFile = "script/apps/GameServer/GSL_client.lua",
		});	
	end
end

-- restart the gateway. Usually the config file specifies which grid node serves which region of the world
-- Since we always return the smallest sized grid server to client, we should use small sized grid node 
-- in map positions that have large population. And for large low population world, we can simply use just a single grid node.
-- TODO: Currently, such configuration is manual, in future, we can automatically generate the ideal config file from user analysis
-- it is also possible to work out a dynamic load balancing server, but it is for future release. 
-- @param config: a table of {nid, ws_id}. 
--	where nid is the game server; ws_id is the global world server id. Both should be string. 
--  homegrids is a table of array of {address, id}
function gateway:Restart(config)
	self.is_started = true;
	self:Reset();
	if(type(config)=="table") then
		self.config = config;
	end
	if(gateway.config.nid== "localuser" and gateway.config.ws_id=="") then
		thread_or_word = ""
	else
		thread_or_word = string.format("%s:%s",gateway.config.nid,gateway.config.ws_id)
	end

	LOG.std(nil, "debug", "GSL_gateway", "gateway started");

	-- set the gateway server timer for some background tasks like stats.
	NPL.load("(gl)script/ide/timer.lua");
	self.mytimer = self.mytimer or commonlib.Timer:new({callbackFunc = function(timer)
		curTime = ParaGlobal.timeGetTime();
		self:OnFrameMove(curTime);
	end})
	self.mytimer:Change(self.TimerInterval, self.TimerInterval);
end

-- get the thread name such as "1001(1)"
function gateway:GetThreadName()
	return thread_or_word;
end

-- perform background task here. 
function gateway:OnFrameMove(curTime)
	-- TODO: for gosling, add your task here. 
	--commonlib.applog("gateway backgound task framemove:");
	
	if(GSL_grid.is_started and GSL_homegrid.is_started) then
		local agent_count = GSL_grid:GetTotalAgentCount() + GSL_homegrid:GetTotalAgentCount();
		--GSL_stat[self.config.addr] = agent_count;
		local bNeedUpdate;
		 
		-- only update if agent count changes by 3 or last send time is 600 seconds ago. 
		if( math.abs((GSL_stat.last_agent_count or 0) - agent_count) >= mini_send_agent_diff or 
			((GSL_stat.last_send_time or 0) + max_send_interval) < curTime) then
			bNeedUpdate = true;
		end
		if(bNeedUpdate) then
			if(not self.ignoreWebGSLStat) then
				GSL_stat:SendWebRequest(self.config.addr, agent_count);
				LOG.std(nil, "debug", "stat", "GSL agent count on this thread is %d", agent_count);
			end
			GSL_stat.last_send_time = curTime;
			GSL_stat.last_agent_count = agent_count;
			
		end
	end

	--LOG.std(nil, "debug", "stat", "REMOVE THIS: current time is "..tostring(ParaGlobal.timeGetTime()));

	--commonlib.log("\nagent %s total count now is %s\n",self.config.addr, agent_count)
	
	--local users1,count1 = GSL_grid:GetAllOnlineUsers();
	--local users2,count2 = GSL_homegrid:GetAllOnlineUsers();
	--local all_users;
	--if(count1 == 0)	then
		--all_users = users2;
	--else
		--all_users = users1 .. "," .. users2;
	--end
	--commonlib.log("ws_id %s:count:%d,%s\n",tostring(gateway.config.ws_id), count1+count2, tostring(all_users));
	---- send online users to the IMServer for heart beat. 
	--IMServer_broker:SendGameHeart({game_nid = 1002, g_rts = gateway.config.ws_id,users = all_users});
end

-- it will create the agent structure if it does not exist
function gateway:GetUser(nid)
	if(not nid) then return end
	local user = self.users[nid];
	if(not user) then
		user = self:CreateUser(nid)
	end
	return user;
end

-- simply get but does not create if not exist
function gateway:FindUser(nid)
	if(not nid) then return end
	return self.users[nid];
end

-- get the primary grid node for a given nid. may return nil
function gateway:GetPrimGridNode(nid)
	if(nid) then 
		local griduser = self.users[nid];
		if(griduser) then
			return griduser.gridnode;
		end
	end
end

-- set the primary grid node for a given nid. may return nil
function gateway:SetPrimGridNode(nid, gridnode)
	local griduser = self:GetUser(nid);
	if(griduser) then
		if(griduser.gridnode ~= gridnode) then
			if(griduser.gridnode~=nil) then
				self:RemovePrimGridNode(nid, griduser.gridnode, true);
			end
			griduser.gridnode = gridnode;
		end
		LOG.std(thread_or_word, "debug", "GSL", "set primary grid node for nid %s worldpath %s", nid, gridnode.worldpath or "")
	end
end

-- it will only remove if the current gridnode is same as the input gridnode. 
function gateway:RemovePrimGridNode(nid, gridnode, bNoLogout)
	local griduser = self:GetUser(nid);
	if(griduser and (griduser.gridnode == gridnode)) then
		griduser.gridnode = nil;
		LOG.std(thread_or_word, "debug", "GSL", "remove primary grid node for nid %s worldpath %s", nid, gridnode.worldpath or "")

		if(not bNoLogout) then
			disconnect_msg.nid = nid;
			system:Activate(disconnect_msg);
		end
	end
end

-- create an agent. it will overwrite existing one, if any, with a newly created one. 
function gateway:CreateUser(nid)
	local user = user_class:new({nid=nid});
	self.users[nid] = user;
	return user;
end

-- remove a gateway user
-- this function is called when we detect TCP connection is broken. 
-- @return true if we actually removed an existing user.
function gateway:RemoveUser(nid)
	local griduser = self:FindUser(nid);
	if(griduser and not griduser.is_moving) then 
		griduser.is_moving = true;
		-- first kick out the user from primary gridnode. 
		-- (this is optional, since gridnode has timeout anyway.)
		if(griduser.gridnode) then
			griduser.gridnode:KickAgent(nid);
		end
		LOG.std(thread_or_word, "debug", "GSL", "remove grid user from gateway for nid %s", nid)
		self.users[nid] = nil;
		griduser.is_moving = nil;
		return true;
	end
end

-- return true if gateway has a user
function gateway:HasUser(nid)
	if(nid and (self.users[nid] ~= nil)) then 
		return true
	end
end

-- get the grid node server address that is serving a given worldpath and a location in the world. 
-- we always return the smallest sized grid server that exist. 
-- @param worldpath: it can be world path like "worlds/MyWorlds/AlphaWorld/", or it can contain world owner nid like 
--		"worlds/MyWorlds/AlphaWorld/?nid=1234567", 
-- 			if nid is present is the world path, we will return GSL_homegrid node for simulation
-- 			if nid is Not present, we will return local GSL_grid node for simulation
-- @param x,y,z: 
-- @param IsObserver: true if we are just getting for an observer node. 
-- @param params: nil or a table of additional params. {nid, is_local_instance,room_key}
-- @return server_address, IsProxy: gridnode is the best gridnode found for the given world and location. 
--	address may be local, or it can be the proxy address used to communicate with the returned gridnode. In the latter case, IsProxy is true. 
function gateway:GetBestGridServer(worldpath, x,y,z, IsObserver,params)
	local nid;
	
	if(type(params) == "table") then
		nid = tonumber(params.nid);
	end
	
	if((not params or not params.is_local_instance) and nid) then
		-- search the home grid node by nid
		if(nid and self.config.homegrids) then
			local home_thread_count = #(self.config.homegrids);
			-- tricky: if nid is 1 and room_key is not specified, we will redirect nid to be something random according to global time. 
			if(nid==1 and not params.room_key) then
				-- just evenly distribute. only specify nid==1, for high load users, otherwise people will less likely to be together. 
				-- TODO: find a better way, such as using global time. 
				nid = math.random(1,4);
				params.nid = tostring(nid);
			end
			local grid_index = (nid % home_thread_count) + 1;
			local homegrid_info = self.config.homegrids[grid_index];
			if(homegrid_info) then
				return homegrid_info.address, true
			end	
		end
	end
	
	-- use local grid server, if previous node type failed. 
	return "";
end

-- handle server messages
function gateway:HandleMessage(msg)
	local nid = msg.nid;
	
	local user = self:GetUser(nid);
	if(not user) then return end
	
	local msg_type =  msg.type;
	if(msg_type == GSL_msg.CS_Login) then
		------------------------------------
		-- a client just request connection
		------------------------------------
		if(not msg.worldpath) then return end
		
		-- set stat info
		--if(msg.nid) then
			--GSL_stat[self.config.addr][msg.nid] = 'online';
		--end
		
		local server_address, IsProxy = self:GetBestGridServer(msg.worldpath, msg.x, msg.y, msg.z, msg.IsObserver, msg.params);
		if(server_address) then
			-- grid node ID to user
			if(not msg.IsObserver) then
				if(user.grid_address and user.grid_address ~=server_address) then
					-- TODO: we shall send log out message to previous grid server?
					--local msg_out = {type = GSL_msg.CS_Logout, nid=msg.nid}
					--if(IsProxy) then
						--msg_out.proxy = {addr=self.config.addr, src=msg.nid}
						--GSL_proxy:SendMessage({addr=server_address}, "script/apps/GameServer/GSL_homegrid.lua", msg_out)
					--else
						--NPL.activate("script/apps/GameServer/GSL_grid.lua", msg_out);
					--end	
				end
				user.grid_address = server_address;
			end
			
			if(IsProxy) then
				msg.proxy = {addr=self.config.addr, src=msg.nid}
				msg.nid = nil;
				msg.gid = self.config.nid; -- this will authenticate on the first connection
				GSL_proxy:SendMessage({addr=server_address}, "script/apps/GameServer/GSL_homegrid.lua", msg)

				-- TODO: shall we log out the current user, since the user is using a proxy?
				-- i.e. self:SetPrimGridNode(nid, nil);
				-- this way, it will cause the quest and user info to be resynced. 
			else
				-- NPL_activate("script/apps/GameServer/GSL_grid.lua", msg);
				GSL_grid:activate(msg);
			end	
			
		else
			LOG.std("", "warning", "GSL", "no grid server is found for user %s, worldpath %s", msg.nid, msg.worldpath);
		end
		
	elseif(msg_type == GSL_msg.CS_QUERY)then
		------------------------------------
		-- a client send a query
		------------------------------------
		local result = {};
		if(type(msg.fields) =="table") then
			-- TODO: support more fields.
			result.systime = ParaGlobal.timeGetTime();
		end
		local msg_reply = {
			type = GSL_msg.SC_QUERY_REPLY, 
			forward = msg.forward,
			result = result,
			cid = msg.cid,
		};
		self.clientProxy:Send(nid, msg_reply);
	elseif(msg_type == GSL_msg.CS_IM) then
		------------------------------------
		-- a client send a message to the IM server
		------------------------------------
		msg.g_rts = tonumber(gateway.config.ws_id);
		--LOG.std(nil, "debug", "IMServer", {"gateway receiving:", msg})
		if(not msg.game_nid) then
			msg.game_nid = tonumber(gateway.config.nid);
		end
		if(user:RateLimitCheck()) then
			if(msg.data_table and msg.data_table.msg) then
				if(#(msg.data_table.msg) > 256) then
					-- invalid message length, some attacker?
					LOG.std(nil, "warn", "IM server", "attack detected, killing user %s", nid or "");
					NPL.reject(nid);
					return;
				end
			end
			IMServer_broker:handle_request(msg);
		end
	elseif(msg_type == GSL_msg.CS_Chat) then
		------------------------------------
		-- global broadcast message or local thread broadcast request from user or GM.
		------------------------------------
		if(system.SendChat and nid and msg.text and string.sub(msg.text,1,1) == "{" and user:RateLimitCheck()) then
			
			if(#(msg.text) > 500) then
				-- ignore attacks if text is too long. 
				return;
			end
			-- so msg validation here
			-- 1. all chat msg shall be send with server validation. 
			-- 2. remove 
			local msgdata = ChatMessage.DecompressMsgServer(msg.text);
			if(msgdata) then
				if(not msgdata.from and msg.password == "paraengine") then
					-- let client admin bbs to pass
				elseif(tostring(msgdata.from) ~= nid or msgdata.ChannelIndex == 9 or (msgdata.ChannelIndex == 10 and not msg.is_bbs)) then
					-- invalid msg is dropped, client is faking message. 
					return;
				end
			end
			
			system:SendChat(nid, msg.text, msg.is_bbs, function()
					local msg_reply = {
						type = GSL_msg.SC_Chat_REPLY, 
						forward = msg.forward,
						cid = msg.cid,
					};
					self.clientProxy:Send(nid, msg_reply);
				end, msg.password);
			
		end
	end	
end

-- activation function.
local function activate()
	local msg = msg;
	
	LOG.std(thread_or_word, "user", "gateway recv:", msg);
	if(not msg.nid) then
		return
	end

	gateway:HandleMessage(msg);
end
NPL.this(activate);