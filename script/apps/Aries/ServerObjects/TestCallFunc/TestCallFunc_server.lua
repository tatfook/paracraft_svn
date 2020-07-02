--[[
Title: Server agent template class
Author(s): Leio
Date: 2010/03/22
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/TestCallFunc/30371_TestCallFunc_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");
NPL.load("(gl)script/ide/ExternalInterface.lua");

------------------------------------------------
--TestCallFunc_server_Instance
------------------------------------------------
local TestCallFunc_server_Instance = {}
commonlib.setfield("TestCallFunc_server_Instance",TestCallFunc_server_Instance);

-- invoke from client
function TestCallFunc_server_Instance.HelloServer(from_nid,a)
	commonlib.echo("===============HelloServer");
	commonlib.echo(from_nid);
	commonlib.echo(a);
end
-- invoke from client
function TestCallFunc_server_Instance.HelloServer2(from_nid,a,b,c,d)
	commonlib.echo("===============HelloServer2");
	commonlib.echo(from_nid);
	commonlib.echo({a,b,c,d});
end
-- invoke from client
function TestCallFunc_server_Instance.HelloServer3(from_nid,a,b,c,d,e,...)
	commonlib.echo("===============HelloServer3");
	commonlib.echo(from_nid);
	commonlib.echo({a,b,c,d,e});
	commonlib.echo(...);
	local functionName = ExternalInterface.GetCallBack(...);
	if(functionName)then
		local callArgs = {
			server =  TestCallFunc_server_Instance.server,
			functionName = functionName,
			call_nid = from_nid, 
		 }
		ExternalInterface.CallClientByNID(callArgs,"1",true,nil,0,{ "callback" });
	end
end
-- invoke from client
function TestCallFunc_server_Instance.HelloServer4(from_nid,a,b,c,d,e,...)
	commonlib.echo("===============HelloServer4");
	commonlib.echo(from_nid);
	commonlib.echo({a,b,c,d,e});
	commonlib.echo(...);
	local functionName = ExternalInterface.GetCallBack(...);
	if(functionName)then
		local callArgs = {
			server =  TestCallFunc_server_Instance.server,
			functionName = functionName,
			call_nid = from_nid, 
		 }
		ExternalInterface.CallClientByNID(callArgs,a,b,c,d,e);
	end
end
-- invoke from client
function TestCallFunc_server_Instance.HelloServer5(from_nid)
	commonlib.echo("===============HelloServer5");
	commonlib.echo(from_nid);
end
-- invoke from client
function TestCallFunc_server_Instance.HelloServer6(from_nid,...)
	commonlib.echo("===============HelloServer6");
	commonlib.echo(from_nid);
	commonlib.echo(...);
	local functionName = ExternalInterface.GetCallBack(...);
	if(functionName)then
		local callArgs = {
			server =  TestCallFunc_server_Instance.server,
			functionName = functionName,
			call_nid = from_nid, 
		 }
		ExternalInterface.CallClientByNID(callArgs);
	end
end
-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local TestCallFunc_server = {
}

Map3DSystem.GSL.config:RegisterNPCTemplate("testcallfunc", TestCallFunc_server)

function TestCallFunc_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = TestCallFunc_server.OnNetReceive;
	self.OnFrameMove = TestCallFunc_server.OnFrameMove;
	
	TestCallFunc_server_Instance.server = self;
	self:SetValue("SetValueFromServer", {"Test SetValueFromServer"}, revision);
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function TestCallFunc_server:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		 ExternalInterface.OnNetReceive_FromClient(self, from_nid, gridnode, msg, revision)
	end
end
local nextupdate_time = 0;
local clear_time = 0;
-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function TestCallFunc_server:OnFrameMove(curTime, revision)
	if(curTime > nextupdate_time) then
		--每秒检查一次
		nextupdate_time = curTime + 1000;	
		clear_time = clear_time + 1;
		if(clear_time > 10)then
			nextupdate_time = 0;
			clear_time = 0;
			local callArgs = {
				server = self,
				functionName = "TestCallFunc_client_Instance.HelloClient",
			}
			--ExternalInterface.CallClientAll(callArgs,curTime,"a",false,1,nil,{ a = 1, b = 2, c = {1,2,3},})
		end
	end
end


