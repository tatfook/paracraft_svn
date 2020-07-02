--[[
Title: 
Author(s): Leio
Date: 2010/12/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/LuckyTree/LuckyTreeServer.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/ServerObjects/LuckyTree/LuckyTreeServerLogics.lua");
local LuckyTreeServerLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.LuckyTreeServerLogics");

-- create class
local LuckyTreeServer = {};
Map3DSystem.GSL.config:RegisterNPCTemplate("luckytree", LuckyTreeServer)
local string_find = string.find;
local string_match = string.match;
LuckyTreeServer.valid_func_map= {
	["MyCompany.Aries.ServerObjects.LuckyTreeServerLogics.DoLottery"] = true,
	["MyCompany.Aries.ServerObjects.LuckyTreeServerLogics.DoLottery_Bread"] = true,
}
function LuckyTreeServer.DoFunction(from_nid,msg)
	local self = LuckyTreeServer;
	if(not from_nid or not msg)then return end
	local func_str,args_str = string_match(msg, "^%[Aries%]%[LuckyTree%]%[(.-)%]%[(.-)%]$");
		
	LOG.std("", "info","LuckyTreeServer.DoFunction",{func_str = func_str, args_str = args_str});
	if(func_str)then
		if(self.valid_func_map[func_str])then
		local func = commonlib.getfield(func_str);
			if(func)then
				local args;
				if(args_str)then
					args = commonlib.LoadTableFromString(args_str);
				end
				func(from_nid,args); 
			end
		else
			LOG.std("", "warning","client try call a invalid server function in LuckyTreeServer",{func_str = func_str, args_str = args_str});
		end
	end
end
function LuckyTreeServer.MsgProc(from_nid, msg)
	local self = LuckyTreeServer;
	if(not from_nid or not msg)then return end
	if(string_find(msg, "%[Aries%]%[LuckyTree%]") == 1) then
		self.DoFunction(from_nid,msg);
	end
end
function LuckyTreeServer.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = LuckyTreeServer.OnNetReceive;
	self.OnFrameMove = LuckyTreeServer.OnFrameMove;
end
-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function LuckyTreeServer:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		LuckyTreeServer.MsgProc(from_nid, msg.body);	
	end
end
-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function LuckyTreeServer:OnFrameMove(curTime, revision)
end
