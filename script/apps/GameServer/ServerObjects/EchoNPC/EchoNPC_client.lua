--[[
Title: Echo NPC Client 
Author(s):  LiXizhi
Date: 2009/11/17
Desc: sample npc class template on client side
a special client NPC on behalf of a server agent, it just shows what is received.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/ServerObjects/EchoNPC/EchoNPC_client.lua");
------------------------------------------------------------
]]

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
	-- _guihelper.MessageBox(msg)
	
	client:SendRealtimeMessage(self.id, {body="client to server hello!"});
	
	-- one can send real time message to self.id on the server side. 
	-- self:GetValue();
end