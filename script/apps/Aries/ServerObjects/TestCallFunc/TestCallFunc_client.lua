--[[
Title: 
Author(s):  Leio
Date: 2010/03/22
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/TestCallFunc/TestCallFunc_client.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/ExternalInterface.lua");

-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local TestCallFunc_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("testcallfunc", TestCallFunc_client)


function TestCallFunc_client.CreateInstance(self)
	self.OnNetReceive = TestCallFunc_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function TestCallFunc_client:OnNetReceive(client, msgs)
	
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	NPL.load("(gl)script/apps/Aries/app_main.lua");
	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	if(msgs)then
		ExternalInterface.OnNetReceive_FromServer(client, msgs);
	else
		local result = self:GetValue("SetValueFromServer");
		commonlib.echo("============SetValueFromServer");
		commonlib.echo(result);
	end
end
------------------------------------------------
--TestCallFunc_client_Instance
--[[
NPL.load("(gl)script/ide/ExternalInterface.lua");
local callArgs = {
		server_obj_id = "s_testcallfunc",
		functionName = "TestCallFunc_server_Instance.HelloServer",
	 }
ExternalInterface.CallServer(callArgs,"aaa")

------------------------------------------------
NPL.load("(gl)script/ide/ExternalInterface.lua");
local callArgs = {
		server_obj_id = "s_testcallfunc",
		functionName = "TestCallFunc_server_Instance.HelloServer2",
	 }
ExternalInterface.CallServer(callArgs,"aaa",2,nil,nil)

--]]
------------------------------------------------

local TestCallFunc_client_Instance = {}
commonlib.setfield("TestCallFunc_client_Instance",TestCallFunc_client_Instance);
function TestCallFunc_client_Instance.HelloClient(a,b,c,d,e,f,...)
	commonlib.echo("===============HelloClient");
	commonlib.echo({"HelloClient",a,b,c,d,e,f});
	_guihelper.MessageBox({"HelloClient",a,b,c,d,e,f});
end
------------------------------------------------
--[[
NPL.load("(gl)script/ide/ExternalInterface.lua");
local callArgs = {
		server_obj_id = "s_testcallfunc",
		functionName = "TestCallFunc_server_Instance.HelloServer3",
		callbackName = "TestCallFunc_client_Instance.HelloServer3_Callback", -- can be nil
	 }
ExternalInterface.CallServer(callArgs,"aaa",2,nil,nil,nil)
--]]
------------------------------------------------
function TestCallFunc_client_Instance.HelloServer3_Callback(a,b,c,d,e)
	commonlib.echo("===============HelloServer_Callback3");
	commonlib.echo({a,b,c,d});
	_guihelper.MessageBox({a,b,c,d});
end
------------------------------------------------
--[[
NPL.load("(gl)script/ide/ExternalInterface.lua");
local callArgs = {
		server_obj_id = "s_testcallfunc",
		functionName = "TestCallFunc_server_Instance.HelloServer4",
		callbackName = "TestCallFunc_client_Instance.HelloServer4_Callback", -- can be nil
	 }
ExternalInterface.CallServer(callArgs,"1",true,nil,0,{ "callback" })
--]]
------------------------------------------------
function TestCallFunc_client_Instance.HelloServer4_Callback(a,b,c,d,e)
	commonlib.echo("===============HelloServer_Callback4");
	commonlib.echo({a,b,c,d,e});
	_guihelper.MessageBox({a,b,c,d,e});
end
------------------------------------------------
--[[
NPL.load("(gl)script/ide/ExternalInterface.lua");
local callArgs = {
		server_obj_id = "s_testcallfunc",
		functionName = "TestCallFunc_server_Instance.HelloServer5",
	 }
ExternalInterface.CallServer(callArgs)
--]]
------------------------------------------------
--[[
NPL.load("(gl)script/ide/ExternalInterface.lua");
local callArgs = {
		server_obj_id = "s_testcallfunc",
		functionName = "TestCallFunc_server_Instance.HelloServer6",
		callbackName = "TestCallFunc_client_Instance.HelloServer6_Callback", -- can be nil
	 }
ExternalInterface.CallServer(callArgs)
--]]
------------------------------------------------
function TestCallFunc_client_Instance.HelloServer6_Callback()
	commonlib.echo("===============HelloServer_Callback6");
	commonlib.echo("HelloServer_Callback6");
	_guihelper.MessageBox("HelloServer_Callback6");
end