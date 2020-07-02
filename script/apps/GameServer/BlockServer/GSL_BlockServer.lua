--[[
Title: Block server
Author(s): LiXizhi
Date: 2013/8/27
Desc: Main interface class 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/BlockServer/GSL_BlockServer.lua");
local Server = commonlib.gettable("System.GSL.BlockServer.Server");
local server = Server:new();
-----------------------------------------------
]]

NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/World/WorldManager.lua");
local WorldManager = commonlib.gettable("System.GSL.BlockServer.WorldManager");

local tostring = tostring;
local format = format;
local type = type;
local Server = commonlib.inherit(nil, commonlib.gettable("System.GSL.BlockServer.Server"))

------------------------
--  server class registration
------------------------
local BlockServer = {};
System.GSL.config:RegisterNPCTemplate("creator", BlockServer)

function BlockServer.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = BlockServer.OnNetReceive;
	self.OnFrameMove = BlockServer.OnFrameMove;
	self.OnActivate = BlockServer.OnActivate;
	LOG.std(nil, "info","BlockServer", "CreateInstance");

	self._server = Server:new();
	self._server:Init(self);
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function BlockServer:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		-- received a new message. 
		self._server:OnReceiveMessage(from_nid, msg, revision);
	end
end

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function BlockServer:OnFrameMove(curTime, revision)
	self._server:OnFrameMove(curTime, revision);
end

-- Whenever a gridnode is first loaded or activated again, this function will also be called. 
-- @param bActivate: true if gridnode is active or false if unactive. 
function BlockServer:OnActivate(bActivate)
	self._server:Reset();
	self:RemoveAllValues();
end

------------------------
--  Server class
------------------------
function Server:ctor()
end

function Server:Init(serveragent)
	self.serveragent = serveragent;
	self.gridnode = serveragent.gridnode;

	self.Worlds = {};
	self.Entities = {};
	self:CreateWorld("empty");
end

function Server:OnActivate(bActivate)
	self:Init(self.serveragent);	
end

-- @return worldmanager
function Server:CreateWorld(name)
    local world = WorldManager:new();
	world:Init(self);

	-- currently only the first world is supported. 
	self.Worlds[1] = world;

    return world;
end


function Server:OnReceiveMessage(from_nid, msg, revision)
end

function Server:AddEntity()
end

function Server:OnFrameMove(curTime, revision)
end

-- add a real time message to the rt_queue. This is usually called on the server side, 
-- so that all clients' correspondng agent receives OnNetRecv() event 
-- It will be sent almost at real time to the clients. 
-- e.g. agent:AddRealtimeMessage({name="chat", value="hello world"})
-- @param msg: it is a table or value
-- @param channel_name: if not nil, msg[channel_name] is used to determine if message should be overriden.
function Server:AddRealtimeMessage(msg, channel_name)
	return self.serveragent:AddRealtimeMessage(msg, channel_name);
end

-- send a real time message on behalf of this server object to a given user. This is usually called on the server side, 
-- so that the client's correspondng agent receives OnNetRecv() event 
-- It will be sent almost at real time to the clients. 
-- e.g. agent:SendRealtimeMessage(nid, {name="chat", value="hello world"})
-- @param user_nid: if nil, the message is broadcasted to all clients on behalf of this server agent. 
--  otherwise, it can be the nid of the user to receive.
-- @param msg: it is a table or value
-- @param channel_name: if not nil, msg[channel_name] is used to determine if message should be overriden.
function Server:SendRealtimeMessage(user_nid, msg, channel_name)
	return self.serveragent:SendRealtimeMessage(user_nid, msg, channel_name);
end

function Server:GetDefaultWorld()
	return Worlds[1];
end
