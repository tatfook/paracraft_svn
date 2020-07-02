--[[
Title: Quest system client message handler.
Author(s): WangTian
Date: 2008/12/10

Quest client will handle every SMSG message and perform user interface visualization

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_MSGHandler_Client.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemQuest/Main.lua");
NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_MSGDef.lua");

if(not Map3DSystem.Quest.Client.MSGHandler) then Map3DSystem.Quest.Client.MSGHandler = {}; end

local Quest_Client = Map3DSystem.Quest.Client;
local Quest_MSGHandler_Client = Map3DSystem.Quest.Client.MSGHandler;
local Quest_MSG = Map3DSystem.Quest_MSG;
local Quest_Log = Map3DSystem.Quest.Client.Log;


local MSGHandlers = {};
Map3DSystem.Quest.Client.MSGHandler.ABC = MSGHandlers;

-- entry point to process each message according to its opcode
-- called from client neuron file activate function
function Quest_MSGHandler_Client.MSGProc(msg)
	
	-- TODO: msg.UID, currently it's all nil
	
	if(msg.Opcode == nil or type(msg.Opcode) ~= "number" ) then
		log("invalid message Opcode\n")
		return;
	end
	
	-- get the message handler callback function
	local handler;
	local k, v;
	for k, v in pairs(Quest_MSG) do
		if(v == msg.Opcode) then
			handler = MSGHandlers[k];
			if(type(handler) ~= "function") then
				log("invalid message handler for message: "..k.."\n")
				return;
			end
			break;
		end
	end
	
	
	if(msg.Opcode == Quest_MSG.SMSG_PLAYER_QUEST_LOGS) then
		handler(msg);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTGIVER_STATUS) then
		handler(msg.NPC_id, msg.status);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTGIVER_STATUS_MULTIPLE) then
		handler(msg.results);
	elseif(msg.Opcode == Quest_MSG.SMSG_NEARBY_NPCS) then
		local k, v;
		for k, v in pairs(msg.NPCs) do
			handler(v);
		end
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTGIVER_QUEST_LIST) then
		handler(msg.NPC_id, msg.Title, msg.MenuItems);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTGIVER_QUEST_DETAILS) then
		if(msg.Objectives ~= nil and msg.Requires ~= nil and msg.RewOrReqMoney ~= nil) then
			Quest_Log[msg.quest_id] = {
				NPC_id = msg.NPC_id, 
				quest_id = msg.quest_id, 
				Title = msg.Title, 
				Details = msg.Details, 
				Objectives = msg.Objectives, 
				Requires = msg.Requires, 
				RewItems = msg.RewItems,
				RewOrReqMoney = msg.RewOrReqMoney,
				status = 4, -- QUEST_STATUS_AVAILABLE
				};
		end
		handler(msg.NPC_id, msg.quest_id, msg.Title, msg.Details, msg.Objectives, msg.Requires, msg.RewItems, msg.RewOrReqMoney);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTGIVER_ACCEPT_QUEST_CONFIRM) then
		if(Quest_Log[msg.quest_id]) then
			Quest_Log[msg.quest_id].status = 3; --QUEST_STATUS_INCOMPLETE
		end
		handler(msg.NPC_id, msg.quest_id);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTGIVER_OFFER_REWARD) then
		handler(msg.NPC_id, msg.quest_id, msg.Title, msg.OfferRewardText, msg.Rewards);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTGIVER_FINISH_QUEST) then
		handler(msg);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTGIVER_QUEST_INVALID) then
		handler(msg.msg);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTGIVER_BYE) then
		handler(msg.NPC_id);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTGIVER_QUEST_COMPLETE) then
		if(Quest_Log[msg.quest_id]) then
			Quest_Log[msg.quest_id].status = 1; -- QUEST_STATUS_COMPLETE
		end
		handler(msg.quest_id, msg.XP, msg.RewOrReqMoney, msg.RewItems);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTGIVER_QUEST_FAILED) then
		handler(msg.quest_id);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTLOG_FULL) then
		handler();
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTUPDATE_CREQUIRE_RIGHTANSWER) then
		handler(msg.id, msg.count, msg.CurrentDialog_NPC_id);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTUPDATE_CREQUIRE_WRONGANSWER) then
		handler(msg.id, msg.CurrentDialog_NPC_id);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTUPDATE_FAILED) then
		handler(msg.quest_id);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTUPDATE_FAILEDTIMER) then
		handler(msg.quest_id);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTUPDATE_COMPLETE) then
		Quest_Log[msg.quest_id].status = 1; -- QUEST_STATUS_COMPLETE
		handler(msg.quest_id);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTUPDATE_ADD_KILL) then
		handler(msg.quest_id, msg.ReqCreatureOrGOId, msg.count, msg.ReqCreatureOrGOCount, msg.guid);
	elseif(msg.Opcode == Quest_MSG.SMSG_QUESTUPDATE_ADD_ITEM) then
		handler(msg.quest_id, msg.ReqItemId, msg.count);
	end
end

------------------------------------------
-- register message handler
------------------------------------------

function Quest_MSGHandler_Client.RegisterHandler_SMSG_PLAYER_QUEST_LOGS(callback)
	MSGHandlers["SMSG_PLAYER_QUEST_LOGS"] = callback;
end
Quest_MSGHandler_Client.RegisterHandler_SMSG_PLAYER_QUEST_LOGS(function(msg) 
		local i, log;
		for i, log in pairs(msg.questlogs) do
			Quest_Log[log.quest_id] = {
				status = log.status,
				NPC_id = log.NPC_id, 
				quest_id = log.quest_id, 
				Title = log.Title, 
				Details = log.Details, 
				Objectives = log.Objectives, 
				Requires = log.Requires, 
				RewItems = log.RewItems,
				RewOrReqMoney = log.RewOrReqMoney,
			};
		end
	end);

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_STATUS(callback)
	MSGHandlers["SMSG_QUESTGIVER_STATUS"] = callback;
end

function Quest_MSGHandler_Client.RegisterHandler_SMSG_NEARBY_NPCS(callback)
	MSGHandlers["SMSG_NEARBY_NPCS"] = callback;
end

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_QUEST_LIST(callback)
	MSGHandlers["SMSG_QUESTGIVER_QUEST_LIST"] = callback;
end

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_QUEST_DETAILS(callback)
	MSGHandlers["SMSG_QUESTGIVER_QUEST_DETAILS"] = callback;
end

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_ACCEPT_QUEST_CONFIRM(callback)
	MSGHandlers["SMSG_QUESTGIVER_ACCEPT_QUEST_CONFIRM"] = callback;
end

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_OFFER_REWARD(callback)
	MSGHandlers["SMSG_QUESTGIVER_OFFER_REWARD"] = callback;
end

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_FINISH_QUEST(callback)
	MSGHandlers["SMSG_QUESTGIVER_FINISH_QUEST"] = callback;
end
Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_FINISH_QUEST(function (msg)
		-- just delete the quest log
		Quest_Log[msg.quest_id] = nil;
	end);

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_QUEST_INVALID(callback)
	MSGHandlers["SMSG_QUESTGIVER_QUEST_INVALID"] = callback;
end

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_BYE(callback)
	MSGHandlers["SMSG_QUESTGIVER_BYE"] = callback;
end

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_QUEST_COMPLETE(callback)
	MSGHandlers["SMSG_QUESTGIVER_QUEST_COMPLETE"] = callback;
end

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTGIVER_QUEST_FAILED(callback)
	MSGHandlers["SMSG_QUESTGIVER_QUEST_FAILED"] = callback;
end

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTLOG_FULL(callback)
	MSGHandlers["SMSG_QUESTLOG_FULL"] = callback;
end

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTUPDATE_FAILED(callback)
	MSGHandlers["SMSG_QUESTUPDATE_FAILED"] = callback;
end

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTUPDATE_CREQUIRE_RIGHTANSWER(callback)
	MSGHandlers["SMSG_QUESTUPDATE_CREQUIRE_RIGHTANSWER"] = callback;
end

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTUPDATE_CREQUIRE_WRONGANSWER(callback)
	MSGHandlers["SMSG_QUESTUPDATE_CREQUIRE_WRONGANSWER"] = callback;
end

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTUPDATE_FAILEDTIMER(callback)
	MSGHandlers["SMSG_QUESTUPDATE_FAILEDTIMER"] = callback;
end

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTUPDATE_COMPLETE(callback)
	MSGHandlers["SMSG_QUESTUPDATE_COMPLETE"] = callback;
end

Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTUPDATE_COMPLETE(function (quest_id)
		-- update quest complete
		--quest_id
	end);

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTUPDATE_ADD_KILL(callback)
	MSGHandlers["SMSG_QUESTUPDATE_ADD_KILL"] = callback;
end

function Quest_MSGHandler_Client.RegisterHandler_SMSG_QUESTUPDATE_ADD_ITEM(callback)
	MSGHandlers["SMSG_QUESTUPDATE_ADD_ITEM"] = callback;
end