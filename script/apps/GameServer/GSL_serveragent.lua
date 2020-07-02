--[[
Title: server agent in a server or client
Author(s): LiXizhi
Date: 2009.11.14 
Desc: It is similar to GSL_agent, except that it represents various game objects on the server side, such as server NPC, special game objects in a grid node, etc. 
Unlike GSL_agent (which represents real players), server agent does not time out, therefore no ping messages are sent to client during normal update. 
Everything else behaves much the same like GSL_agent. For example, each server agent has a unique id, and persistent data fields with revision numbers. 

During normal update, all server agents in a gridnode will be patch-send to the clients. Patch-send means that only changed data are sent; 
because server agents are all persistent on the server, both client and server does not needs to implement timeout. 
The client usually renders server agents according to its persistent data fields as well as real time messages received. 
Client and server can communicate by sending real time messages using server agent id. 

---++ Server side
All server-side server agent template class must implement following virtual functions. 

The following are property that one can access from self.xxx in all virtual functions. 
| *property* | *desc* | 
| id		 | id of this server agent | 
| gridnode   | the owner gridnode reference | 
| npc_node	 | the xml configuration node, may contain property and reference. | 

-- when a gridnode is spawned, it will create all server agents in it by calling this function using its template class. 
function serverAgent.CreateInstance(self, revision)
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function serverAgent:OnNetReceive(from_nid, msg, revision)
end

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function serverAgent:OnFrameMove(curTime, revision)
end

-- send a real time message on behalf of this server agent. All clients will receive OnNetReceive() event
function serverAgent:AddRealtimeMessage(msg)
end

---++ Client side
All client-side server agent template class must implement following virtual functions. 

-- when a new server side agent is synchronized, it will call this function to create a new instance of the server agent on the client side for event handling.  
function serverAgent.CreateInstance(self)
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function serverAgent:OnNetReceive(from_nid, msg)
end

-- send a real time message to this server agent on the server side. The server will receive OnNetReceive()
function serverAgent:AddRealtimeMessage(msg)
end

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_serveragent.lua");

local MyEchoNPC_server = {}

-- register class with the GSL server 
Map3DSystem.GSL.config:RegisterNPCTemplate("EchoNPC", MyEchoNPC_server)

function MyEchoNPC_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = MyEchoNPC_server.OnNetReceive;
	self.OnFrameMove = MyEchoNPC_server.OnFrameMove;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
	
	commonlib.log("MyEchoNPC_server.CreateInstance %s\n", tostring(self.id));
	
	-- TODO: add your private per instance data here
	self:SetValue("versioned_data", {nCount=1}, revision)
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function MyEchoNPC_server:OnNetReceive(from_nid, msg, revision)
	-- echo real time message to client
	-- self:AddRealtimeMessage(msg)
	commonlib.log("MyEchoNPC_server (%s):OnNetReceive \n", self.id);commonlib.log("msg is \n");commonlib.echo(msg);
end

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function MyEchoNPC_server:OnFrameMove(curTime, revision)
	-- update persistent data and let normal update to broadcast to all agents. 
	local old_value = self:GetValue("versioned_data");
	old_value.nCount = old_value.nCount + 1;
	self:SetValue("versioned_data", old_value, revision);
	
	commonlib.echo("server on frame moved")
	self:AddRealtimeMessage({body="server to client hello!"})
end

-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local MyEchoNPC_client = {}

-- register class with the GSL client
Map3DSystem.GSL.client.config:RegisterNPCTemplate("EchoNPC", MyEchoNPC_client)

function MyEchoNPC_client.CreateInstance(self)
	self.OnNetReceive = MyEchoNPC_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_client.AddRealtimeMessage;
	commonlib.log("MyEchoNPC_client.CreateInstance %s\n", tostring(self.id));
	-- TODO: add init code and private data structures
	self.private_data = {};
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function MyEchoNPC_client:OnNetReceive(client, msg)
	-- self.id
	commonlib.log("MyEchoNPC_client (%s):OnNetReceive \n", self.id);
	commonlib.log("msg is \n");	commonlib.echo(msg);
	commonlib.log("public data is \n");	commonlib.echo(self:ConvertDataToTable());	commonlib.log("\n\n");
	
	-- renders whatever is received in message box 
	_guihelper.MessageBox(msg)
	
	client:SendRealtimeMessage(self.id, {body="client to server hello!"});
	
	-- one can send real time message to self.id on the server side. 
	-- self:GetValue();
end
------------------------------------------------------------
]]
local serveragent = commonlib.gettable("Map3DSystem.GSL.serveragent");

-- the id of this agent. 
serveragent.id = nil;
-- agent type. 
serveragent.type = nil;

function serveragent:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	-- persistent data fields that are automatically synchronized during normal update. 
	o.data = {};
	
	-- the largest revsion number of all data in self.data
	o.revision =  0;
	
	-- real time message queue, array of real time messages to send to all clients on behalf of this server agent
	o.rt_queue = nil;
	-- per user real time message queue, array of {user_nid, msg} to send to a given client on behalf of this server agent
	o.per_user_msg = nil;
	return o
end

-- for debugging only. dump to log
function serveragent:Dump()
	commonlib.echo({server_agent_dump = self.id})
	commonlib.echo(self.data);
end	

-- add or update a versioned data object to be automatically synchronized
-- use self:UpdateValue() to only auto detect unchanged data
-- @param name: must be string
-- @param value: any value type, including table. 
-- @param revision: the revision number, if nil, it is the first one. 
function serveragent:SetValue(name, value, revision)
	local tracker = self.data[name];
	if(not tracker) then
		tracker = {};
		self.data[name] = tracker;
	end
	tracker.value = value;
	tracker.revision = revision or 0;
	self.revision = revision;
end	

-- this is similar to SetValue, except that it will only use the revision number when value is different from the last revision. 
-- please note if value is table, it only compares reference. 
-- @param name: must be string
-- @param value: any value type, including table. 
-- @param revision: the revision number, if nil, it is the first one. 
function serveragent:UpdateValue(name, value, revision)
	local tracker = self.data[name];
	if(not tracker) then
		tracker = {revision = revision or 0};
		self.data[name] = tracker;
	end
	if(tracker.value ~= value) then
		tracker.value = value;
		tracker.revision = revision or 0;
		self.revision = revision;
	end
end

-- get a versioned data field value by its name.
function serveragent:GetValue(name)
	local tracker = self.data[name];
	if(tracker) then
		return tracker.value;
	end
end

-- remove a given value by name. This function is usually called when node is inactivated and maybe reused in future.
function serveragent:RemoveValue(name)
	self.data[name] = nil;
end

-- clear all values, This function is usually called when node is inactivated and maybe reused in future.
function serveragent:RemoveAllValues()
	self.data = {};
end

-- convert all version controlled data fields to table {name,value}
-- This will create a new table each time this function is called. 
-- @return {name,value}
function serveragent:ConvertDataToTable()
	local output = {};
	local name, data_value
	for name, data_value in pairs(self.data) do
		output[name] = data_value.value;
	end
	return output;
end

-- add a real time message to the rt_queue. This is usually called on the server side, 
-- so that all clients' correspondng agent receives OnNetRecv() event 
-- It will be sent almost at real time to the clients. 
-- e.g. agent:AddRealtimeMessage({name="chat", value="hello world"})
-- @param msg: it is a table or value
-- @param channel_name: if not nil, msg[channel_name] is used to determine if message should be overriden.
function serveragent:AddRealtimeMessage(msg, channel_name)
	if(not channel_name) then
		self.rt_queue = self.rt_queue or {};
		self.rt_queue[#(self.rt_queue) + 1] = msg;
	else
		if(not self.rt_queue) then
			self.rt_queue = {msg};
		else
			local i, is_overriden;
			local count = #(self.rt_queue)
			for i=1, count do
				local msg_ = self.rt_queue[i];
				if(msg_[channel_name] == msg[channel_name]) then
					self.rt_queue[i] = msg;
					is_overriden = true;
					break;
				end
			end
			if(not is_overriden) then
				self.rt_queue[count + 1] = msg;
			end
		end
	end
end

-- send a real time message on behalf of this server object to a given user. This is usually called on the server side, 
-- so that the client's correspondng agent receives OnNetRecv() event 
-- It will be sent almost at real time to the clients. 
-- e.g. agent:SendRealtimeMessage(nid, {name="chat", value="hello world"})
-- @param user_nid: if nil, the message is broadcasted to all clients on behalf of this server agent. 
--  otherwise, it can be the nid of the user to receive.
-- @param msg: it is a table or value
-- @param channel_name: if not nil, msg[channel_name] is used to determine if message should be overriden.
function serveragent:SendRealtimeMessage(user_nid, msg, channel_name)
	if(not channel_name) then
		-- simply append and no override. 
		if(user_nid) then
			self.per_user_msg = self.per_user_msg or {};
			self.per_user_msg[#(self.per_user_msg) + 1] = {nid=user_nid, msg = msg};
		else
			self:AddRealtimeMessage(msg)
		end	
	else
		if(user_nid) then
			if(not self.per_user_msg) then
				self.per_user_msg = {{nid=user_nid, msg = msg}};
			else
				local i, is_overriden;
				local count = #(self.per_user_msg)
				for i=1, count do
					local msg_ = self.per_user_msg[i];
					if(msg_.user_nid == user_nid and msg_.msg[channel_name] == msg[channel_name]) then
						self.per_user_msg[i] = {nid=user_nid, msg = msg};
						is_overriden = true;
						break;
					end
				end
				if(not is_overriden) then
					self.per_user_msg[count + 1] = {nid=user_nid, msg = msg};
				end
			end
		else
			self:AddRealtimeMessage(msg, channel_name);
		end	
	end
end

-- return realtime message and clean up the real time message pool
-- @return rt_queue, per_user_msg: rt_queue is nil if no real time message in the pool, per_user_msg is nil if no per user message
function serveragent:GenerateRealtimeMessage()
	local rt_queue = self.rt_queue;
	local per_user_msg = self.per_user_msg;
	if(rt_queue) then
		self.rt_queue = nil;
	end
	if(per_user_msg) then
		self.per_user_msg = nil;
	end
	return rt_queue, per_user_msg;
end

-- Generate normal update message from this agent data
-- @revision: only generate stream field that has changed since this revision number. if nil, all fields are returned. 
-- @return: a text data string that can be sent over the network to update the agent. It will return nil, if no stream needs to be sent
function serveragent:GenerateNormalUpdateMessage(revision)
	local patch_msg;
	revision = revision or -1;
	-- commonlib.log("revision compare %d > %d\n", self.revision, revision)
	if(self.revision>revision and self.data) then
		local fieldname, tracker;
		for fieldname, tracker in pairs(self.data) do
			if(tracker.revision > revision) then
				patch_msg = patch_msg or {};
				patch_msg[fieldname] = tracker.value;
			end	
		end
	end
	return patch_msg;
end

-- update the persistent data fields by message. 
function serveragent:UpdateFromMessage(msg, revision)
	if(type(msg) == "table") then
		local field_name, field_value;
		for field_name, field_value in pairs(msg) do
			self:SetValue(field_name, field_value, revision);
		end
	end	
end

-- this function is called when it receive some real time message from the client
-- NOTE: This function is usually overwritten by server agent template class. 
-- following code just provides an example
-- @param stream: the message received 
function serveragent:OnNetReceive(from_nid, msg, revision)
end

-- NOTE: This function is usually overwritten by server agent template class. 
-- this function is called whenever the parent gridnode is made from unactive to active mode or vice versa. 
-- A gridnode is made inactive by its gridnode manager whenever all client agents are left, so it calls this 
-- function and put the gridnode to cache pool for reuse later on. 
-- Whenever a gridnode is first loaded or activated again, this function will also be called. 
-- @param bActivate: true if gridnode is active or false if unactive. 
function serveragent:OnActivate(bActivate)
end

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function serveragent:OnFrameMove(curTime, revision)
end