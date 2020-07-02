--[[
Title: Echo NPC Server
Author(s): LiXizhi
Date: 2009/11/16
Desc: sample npc class template on server side
a special server NPC that just echos whatever received. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/ServerObjects/EchoNPC/EchoNPC_server.lua");
------------------------------------------------------------
]]

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
function MyEchoNPC_server:OnNetReceive(from_nid, gridnode, msg, revision)
	-- echo real time message to all client
	-- self:AddRealtimeMessage(msg)
	-- echo real time message only to the caller
	-- self:SendRealtimeMessage(from_nid, "server to client hello! using SendRealtimeMessage")
	
	commonlib.log("MyEchoNPC_server (%s):OnNetReceive \n", self.id);commonlib.log("msg is \n");commonlib.echo(msg);
end

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function MyEchoNPC_server:OnFrameMove(curTime, revision)
	-- update persistent data and let normal update to broadcast to all agents. 
	local old_value = self:GetValue("versioned_data");
	old_value.nCount = old_value.nCount + 1;
	old_value.revision = revision;
	self:SetValue("versioned_data", old_value, revision);
	
	commonlib.log("server on frame moved: revision: %d\n", revision)
	self:AddRealtimeMessage({body="server to client hello!"})
end
