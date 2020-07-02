--[[
Title:  JGSL gateway 
Author(s): LiXizhi
Date: 2008/12/23
Desc: it helps the user to find the best grid server for a given region in a given world.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_gateway.lua");
Map3DSystem.JGSL.gateway:Restart(configfile);

local gateway = Map3DSystem.JGSL.gateway;
local user = gateway:GetUser(jid)
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_clientproxy.lua");

if(not Map3DSystem.JGSL) then Map3DSystem.JGSL={}; end
if(not Map3DSystem.JGSL_grid) then Map3DSystem.JGSL_grid={}; end
local JGSL = Map3DSystem.JGSL;
local JGSL_grid = Map3DSystem.JGSL_grid;
local JGSL_msg = Map3DSystem.JGSL_msg;
------------------------------
-- a gateway, stores all users connecting to the server (grid server)
------------------------------

local gateway = {
	-- a mapping from jid to GridUser info
	users = {},
	-- gate way session key, it is regenerated each time gateway is restarted. This is different from grid node session key. 
	sessionkey = ParaGlobal.GenerateUniqueID(), 
	configfile = nil,
	-- for sending messages to all or any clients.
	clientProxy=nil,
};
Map3DSystem.JGSL.gateway = gateway

------------------------------
-- Grid User
------------------------------
-- grid user info class
local GridUser = {
	-- server session key associated with the user. 
	sessionkey = nil,
	-- The main grid node server id (index)
	gid = nil,
	
	-- this is set when client first login.
	uid = nil,
	-- this is set when client first login.
	jid = nil,
};
gateway.GridUser = GridUser;

-- create an agent. it will overwrite existing one, if any, with a newly created one. 
function gateway:Reset()
	self.users = {};
	self.sessionkey = ParaGlobal.GenerateUniqueID();
	
	if(	self.clientProxy) then
		self.clientProxy:Reset();
	else
		self.clientProxy = Map3DSystem.JGSL.ClientProxy:new({
			DefaultFile = "script/kids/3DMapSystemNetwork/JGSL_client.lua",
		});	
	end
	self.clientProxy:UpdateSessionKey(self.sessionkey)
	-- self.clientProxy.cookies = {sk=self.clientProxy.sk};
end

-- restart the gateway. Usually the config file specifies which grid node serves which region of the world
-- Since we always return the smallest sized grid server to client, we should use small sized grid node 
-- in map positions that have large population. And for large low population world, we can simply use just a single grid node.
-- TODO: Currently, such configuration is manual, in future, we can automatically generate the ideal config file from user analysis
-- it is also possible to work out a dynamic load balancing server, but it is for future release. 
-- @param configfile: nil or config file path
function gateway:Restart(configfile)
	self:Reset();
	if(configfile) then
		self.configfile = configfile;
	end
	if(self.configfile) then
		-- TODO: load from configuration file.
	end
	-- TODO: setup a timer for gateway?
end

-- it will create the agent structure if it does not exist
function gateway:GetUser(jid)
	if(not jid) then return end
	local user = self.users[jid];
	if(not user) then
		user = self:CreateUser(jid)
	end
	return user;
end

-- create an agent. it will overwrite existing one, if any, with a newly created one. 
function gateway:CreateUser(jid)
	local user = {jid=jid};
	self.users[jid] = user;
	return user;
end

-- get the grid node info that is serving a given worldpath and a location in the world. 
-- we always return the smallest sized grid server that exist. 
-- @param worldpath, x,y,z: 
-- @param IsObserver: true if we are just getting for an observer node. 
function gateway:GetBestGridNode(worldpath, x,y,z, IsObserver)
	-- search the local grid node
	return JGSL_grid.CreateGetBestGridNode(msg.worldpath, msg.x, msg.y, msg.z, IsObserver);
end

-- handle server messages
function gateway:HandleMessage(msg)
	-- msg.from may be of format "name@server/resource", so we need to remove resource
	local jid = string.gsub(msg.from, "/.*$", "");
	
	local user = self:GetUser(jid);
	if(not user) then return end
	
	if(msg.type == JGSL_msg.CS_PING) then
		--------------------------------
		-- Client pings: forward client session key and send server session keys. 
		--------------------------------
		-- only be a server if it is not a connected client. comment this out if you want to allow both client and server on the same computer. 
		local msg_reply = {
			type = JGSL_msg.SC_PING_REPLY, 
			-- forward the client session key(csk)
			csk = msg.csk,
			sk = self.sessionkey,
			IsGrid = true,
		};
		self.clientProxy:Send(jid, msg_reply);
		
	elseif(msg.type == JGSL_msg.CS_Login) then
		------------------------------------
		-- a client just request connection
		------------------------------------
		if(not msg.worldpath) then return end
		
		local gridnode = self:GetBestGridNode(msg.worldpath, msg.x, msg.y, msg.z, msg.IsObserver);
		if(not gridnode) then
			-- no grid node is found, forward message back to inform client
			-- possibly because server is full or not available to new requests. 
			self.clientProxy:Send(jid, {
				-- SC: InitGame: first and basic world information.
				type = JGSL_msg.SC_Login_Reply, 
				worldpath = msg.worldpath,
				x=msg.x, y=msg.y, z=msg.z,
			});
		end
		
		-- TODO: shall we verify the UID from jid. 
		user.uid = msg.clientUID;
		user.jid = jid;
		
		-- grid node ID to user
		if(not msg.IsObserver) then
			user.gid = gridnode.id;
		end	
		--commonlib.log("--------server received CS_Login \n");
		--commonlib.echo({gridnode.id, gridnode.sk, gridnode.worldpath})
		
		self.clientProxy:Send(jid, {
			-- SC: InitGame: first and basic world information.
			type = JGSL_msg.SC_Login_Reply, 
			worldpath = gridnode.worldpath,
			x=msg.x, y=msg.y, z=msg.z,
			-- tell the client to about the grid node Session Key.
			gk = gridnode.sk,
			-- grid server jid
			gjid = gridnode.jid,
			gid = gridnode.id,
			-- grid tile pos
			gx = gridnode.x; 
			gy = gridnode.y;
			-- grid tile size
			gsize = gridnode.size;
			-- tell the client that this is a grid server
			IsGrid = true,
			Role = gridnode.UserRole,
			OnlineUserNum = gridnode.OnlineUserNum,
			StartTime = gridnode.statistics.StartTime,
			VisitsSinceStart = gridnode.statistics.VisitsSinceStart,
			ServerVersion = gridnode.ServerVersion, 
			ClientVersion = gridnode.ClientVersion, 
		});
	elseif(msg.type == JGSL_msg.CS_QUERY)then
		------------------------------------
		-- a client send a query
		------------------------------------
		local result = {};
		if(type(msg.fields) =="table") then
			-- TODO: support more fields.
			result.systime = ParaGlobal.timeGetTime();
		end
		local msg_reply = {
			type = JGSL_msg.SC_QUERY_REPLY, 
			-- forward the client session key(csk)
			csk = msg.csk,
			sk = self.sessionkey,
			IsGrid = true,
			forward = msg.forward,
			result = result,
		};
		self.clientProxy:Send(jid, msg_reply);
	end	
end

-- activation function.
local function activate()
	if(JGSL.dump_server_msg) then
		commonlib.echo(msg)
	end
	gateway:HandleMessage(msg);
end
gateway.activate = activate;
NPL.this(activate);