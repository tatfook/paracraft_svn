--[[
Title: 
Author(s): Leio
Date: 2011/02/18
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/CombatRoom/CombatRoomServer.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/ServerObjects/CombatRoom/CombatRoomServerLogics.lua");
local CombatRoomServerLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.CombatRoomServerLogics");

-- create class
local CombatRoomServer = {};
Map3DSystem.GSL.config:RegisterNPCTemplate("combatroom", CombatRoomServer)
local string_find = string.find;
local string_match = string.match;

function CombatRoomServer.DoFunction(from_nid,msg)
	local self = CombatRoomServer;
	if(not from_nid or not msg)then return end
	local func_str,args_str = string_match(msg, "^%[Aries%]%[CombatRoom%]%[(.-)%]%[(.-)%]$");
		
	LOG.std("", "info","CombatRoomServer.DoFunction",{func_str = func_str, args_str = args_str});
	if(func_str)then
		local func = commonlib.getfield(func_str);
		if(func)then
			local args;
			if(args_str)then
				args = commonlib.LoadTableFromString(args_str);
			end
			func(from_nid,args); 
		end
	end
end
function CombatRoomServer.MsgProc(from_nid, msg)
	local self = CombatRoomServer;
	if(not from_nid or not msg)then return end
	if(string_find(msg, "%[Aries%]%[CombatRoom%]") == 1) then
		self.DoFunction(from_nid,msg);
	end
end
function CombatRoomServer.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = CombatRoomServer.OnNetReceive;
	self.OnFrameMove = CombatRoomServer.OnFrameMove;
end
-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function CombatRoomServer:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		CombatRoomServer.MsgProc(from_nid, msg.body);	
	end
end
-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function CombatRoomServer:OnFrameMove(curTime, revision)
end
