--[[
Title: Quest Server
Author(s): LiXizhi
Date: 2010/8/21
Desc: QuestServer is the high level logics of a quest server object on the game server. This class runs in each virtual world thread. 
Because each NPL thread may host multiple game world (thus having multiple Quest Server objects), however, all the QuestServer object instances shares the same data structure on it belonging to the world thread.
The most important data structure shared is the QuestPlayerManager which contains all the QuestPlayer instances. 
The combat server system or the client endpoints may send messages to the QuestServer object, all such requests are routed to QuestServer_handlers for processing. 
Most processing involves calling functions on QuestPlayer to update quest status and quest item server data. 
QuestServer communicates with client by means of sending replies to QuestClient

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestServer.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestServerLogics.lua");
local QuestServerLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestServerLogics");

NPL.load("(gl)script/apps/Aries/UserBag/BagExtendServerHelper.lua");
local BagExtendServerHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagExtendServerHelper");
-- create class
local QuestServer = commonlib.gettable("MyCompany.Aries.Quest.QuestServer");
Map3DSystem.GSL.config:RegisterNPCTemplate("quest", QuestServer)
local string_find = string.find;
local string_match = string.match;
QuestServer.valid_func_map= {
	["MyCompany.Aries.Quest.QuestServerLogics.Test_Handler"] = true,
	["MyCompany.Aries.Quest.QuestServerLogics.DoAddValue_FromClient"] = true,
	["MyCompany.Aries.Quest.QuestServerLogics.DoSync_Server_ClientGoalItem"] = true,
	["MyCompany.Aries.Quest.QuestServerLogics.CallInit_Handler"] = true,
	["MyCompany.Aries.Quest.QuestServerLogics.DoReset_Handler"] = true,
	["MyCompany.Aries.Quest.QuestServerLogics.TryAccept_Handler"] = true,
	["MyCompany.Aries.Quest.QuestServerLogics.TryFinished_Handler"] = true,
	["MyCompany.Aries.Quest.QuestServerLogics.TryDelete_Handler"] = true,
	["MyCompany.Aries.Quest.QuestServerLogics.TryDrop_Handler"] = true,
	["MyCompany.Aries.Quest.QuestServerLogics.TryReAccept_Handler"] = true,
	["MyCompany.Aries.Quest.QuestServerLogics.DoUserDisconnect"] = true,
	["MyCompany.Aries.Quest.QuestServerLogics.DoFeed_FollowPet"] = true,
	["MyCompany.Aries.Quest.QuestServerLogics.DoChangeName_FollowPet"] = true,
	["MyCompany.Aries.Quest.QuestServerLogics.AttachGem"] = true,
	["MyCompany.Aries.Quest.QuestServerLogics.UnAttachGem"] = true,
	["MyCompany.Aries.Quest.QuestServerLogics.CheckDate_FollowPet"] = true,
	["MyCompany.Aries.Quest.QuestServerLogics.DoUseItem_AddExpPercent"] = true,

	["MyCompany.Aries.Inventory.BagExtendServerHelper.DoBagExtend"] = true,

	["MyCompany.Aries.Inventory.UserServerMemory.DoInit_Handle"] = true,
	["MyCompany.Aries.Inventory.UserServerMemory.SetData"] = true,
}
function QuestServer.DoFunction(from_nid,msg)
	local self = QuestServer;
	if(not from_nid or not msg)then return end
	local func_str,args_str = string_match(msg, "^%[Aries%]%[Quest%]%[(.-)%]%[(.-)%]$");
		
	LOG.std("", "info","QuestServer.DoFunction",{func_str = func_str, args_str = args_str});
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
			LOG.std("", "warning","client try call a invalid server function in QuestServer",{func_str = func_str, args_str = args_str});
		end
	end
end
function QuestServer.MsgProc(from_nid, msg)
	local self = QuestServer;
	if(not from_nid or not msg)then return end
	if(string_find(msg, "%[Aries%]%[Quest%]") == 1) then
		self.DoFunction(from_nid,msg);
	end
end
function QuestServer.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = QuestServer.OnNetReceive;
	self.OnFrameMove = QuestServer.OnFrameMove;

	QuestServerLogics.server = self;
	LOG.std(nil, "info","QuestServer", "CreateInstance");
end
-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function QuestServer:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		QuestServerLogics.server = self;
		QuestServer.MsgProc(from_nid, msg.body);	
	end
end
-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function QuestServer:OnFrameMove(curTime, revision)
end
