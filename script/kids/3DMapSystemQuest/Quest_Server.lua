--[[
Title: Quest system server.
Author(s): WangTian
Date: 2008/12/10

Quest server will handle every CMSG message and perform database query or update
And returns the result with SMSG messages

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_Server.lua");
------------------------------------------------------------
]]

--NPL.load("(gl)script/kids/3DMapSystemQuest/Main.lua");
--NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_MSGDef.lua");
--NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_DB.lua");
--
--if(not Map3DSystem.Quest.Server) then Map3DSystem.Quest.Server = {}; end
--
--local Quest_Server = Map3DSystem.Quest.Server;
--local Quest_MSG = Map3DSystem.Quest_MSG;
--local Quest_DB = Map3DSystem.Quest.DB;
--
--------------------------------------------------
---- quest server send according to API calls
--------------------------------------------------
--
--
---- return player quest logs
--function Quest_Server.PlayerQuestLog(UID, quest_id, Title, Details, Objectives, Requires, RewItems, RewOrReqMoney)
	--local msg = {
		--Opcode = Quest_MSG.SMSG_PLAYER_QUEST_LOGS,
		--questlogs = {
			--[1] = {status = Quest_DB.AllQuestStatus[quest_id].status;
			--quest_id = quest_id,
			--Title = Title,
			--Details = Details,
			--Objectives = Objectives, 
			--Requires = Requires, 
			--RewItems = RewItems,
			--RewOrReqMoney = RewOrReqMoney,
			--}
		--},
	--};
	---- SMSG_PLAYER_QUEST_LOGS
	--Map3DSystem.Quest.SendToClient(nil, msg, nil);
--end
--
---- reply Nearby NPCs
--function Quest_Server.ReplyNearbyNPCs(UID, posX, posY, posZ, NearbyNPCs)
	---- NOTE: send the NPC one by one
	---- currently the sCode has string length limit
	---- multiple NPCs or onloadscipt field of NPC can easily exceed the length
	--local k, v;
	--for k, v in pairs(NearbyNPCs) do
		--local msg = {
			--Opcode = Quest_MSG.SMSG_NEARBY_NPCS,
			--posX = posX,
			--posY = posY,
			--posZ = posZ,
			--NPCs = {[1] = v},
		--};
		---- SMSG_NEARBY_NPCS
		--Map3DSystem.Quest.SendToClient(nil, msg, nil);
	--end	
--end
--
---- return quest giver NPC status
---- avaible quest or complete quest .etc
---- @param UID: client UID
---- @param NPC_id: NPC ID
---- @param status: 
--function Quest_Server.QuestgiverStatus(UID, NPC_id, status)
	--local msg = {
		--Opcode = Quest_MSG.SMSG_QUESTGIVER_STATUS,
		--NPC_id = NPC_id, -- NPC name as identifier
		--status = status, -- NPC status
	--};
	---- SMSG_QUESTGIVER_STATUS
	--Map3DSystem.Quest.SendToClient(nil, msg, nil);
--end
--
---- return quest giver quest list
---- mainly avaible quest and imcomplete quests
---- @param UID: client UID
---- @param NPC_id: NPC id
---- @param gossipText: gossip text
---- @param questlist: quest list
--function Quest_Server.QuestgiverQuestList(UID, NPC_id, Title, MenuItems)
	--local msg = {
		--Opcode = Quest_MSG.SMSG_QUESTGIVER_QUEST_LIST,
		--NPC_id = NPC_id,
		--Title = Title,
		--MenuItems = MenuItems,
	--};
	---- SMSG_QUESTGIVER_QUEST_LIST
	--Map3DSystem.Quest.SendToClient(nil, msg, nil);
--end
--
---- quest giver details
---- NOTE: is the Objectives, Requires, RewOrReqMoney are all nil, this is a QUEST_STATUS_INCOMPLETE response. Quest is active in quest log but incomplete
--function Quest_Server.QuestgiverQuestDetails(UID, NPC_id, quest_id, Title, Details, Objectives, Requires, RewItems, RewOrReqMoney)
	--local msg = {
		--Opcode = Quest_MSG.SMSG_QUESTGIVER_QUEST_DETAILS,
		--NPC_id = NPC_id,
		--quest_id = quest_id,
		--Title = Title,
		--Details = Details,
		--Objectives = Objectives,
		--Requires = Requires,
		--RewItems = RewItems,
		--RewOrReqMoney = RewOrReqMoney,
	--};
	---- SMSG_QUESTGIVER_QUEST_DETAILS
	--Map3DSystem.Quest.SendToClient(nil, msg, nil);
--end
--
---- reply the quest invalid message
--function Quest_Server.QuestgiverAcceptQuestConfirm(UID, NPC_id, quest_id)
	--local msg = {
		--Opcode = Quest_MSG.SMSG_QUESTGIVER_ACCEPT_QUEST_CONFIRM,
		--NPC_id = NPC_id,
		--quest_id = quest_id,
	--};
	---- SMSG_QUESTGIVER_ACCEPT_QUEST_CONFIRM
	--Map3DSystem.Quest.SendToClient(nil, msg, nil);
--end
--
---- offer reward
--function Quest_Server.QuestgiverOfferReward(UID, NPC_id, quest_id, Title, OfferRewardText, Rewards)
	--local msg = {
		--Opcode = Quest_MSG.SMSG_QUESTGIVER_OFFER_REWARD,
		--NPC_id = NPC_id,
		--quest_id = quest_id,
		--Title = Title,
		--OfferRewardText = OfferRewardText,
		--Rewards = Rewards,
	--};
	---- SMSG_QUESTGIVER_OFFER_REWARD
	--Map3DSystem.Quest.SendToClient(nil, msg, nil);
--end
--
---- finish quest
--function Quest_Server.QuestgiverFinishQuest(UID, NPC_id, quest_id)
	--local msg = {
		--Opcode = Quest_MSG.SMSG_QUESTGIVER_FINISH_QUEST,
		--NPC_id = NPC_id,
		--quest_id = quest_id,
	--};
	---- SMSG_QUESTGIVER_FINISH_QUEST
	--Map3DSystem.Quest.SendToClient(nil, msg, nil);
--end
--
--
--
--
--
---- reply the quest invalid message
--function Quest_Server.QuestgiverQuestInvalid(UID, msg)
	--local msg = {
		--Opcode = Quest_MSG.SMSG_QUESTGIVER_QUEST_INVALID,
		--msg = msg, -- message ID
	--};
	---- SMSG_QUESTGIVER_QUEST_INVALID
	--Map3DSystem.Quest.SendToClient(nil, msg, nil);
--end
--
---- say bye to the player
--function Quest_Server.QuestgiverBye(UID, NPC_id)
	--local msg = {
		--Opcode = Quest_MSG.SMSG_QUESTGIVER_BYE,
		--NPC_id = NPC_id,
	--};
	---- SMSG_QUESTGIVER_BYE
	--Map3DSystem.Quest.SendToClient(nil, msg, nil);
--end
--
---- reply the quest is completed
--function Quest_Server.QuestgiverQuestComplete(UID, quest_id, XP, RewOrReqMoney, RewItems)
	--local msg = {
		--Opcode = Quest_MSG.SMSG_QUESTGIVER_QUEST_COMPLETE,
		--quest_id = quest_id, -- quest ID
		--XP = XP, -- experience
		--RewOrReqMoney = RewOrReqMoney, -- money
		--RewItems = RewItems, -- items
	--};
	---- SMSG_QUESTGIVER_QUEST_COMPLETE
	--Map3DSystem.Quest.SendToClient(nil, msg, nil);
--end
--
--
--
--
---- CRequire right answer
--function Quest_Server.QuestUpdateCRequireRightAnswer(UID, id, count, CurrentDialog_NPC_id)
	--local msg = {
		--Opcode = Quest_MSG.SMSG_QUESTUPDATE_CREQUIRE_RIGHTANSWER,
		--id = id, -- goal id
		--count = count, -- old count + add count
		--CurrentDialog_NPC_id = CurrentDialog_NPC_id,
	--};
	---- SMSG_QUESTUPDATE_CREQUIRE_RIGHTANSWER
	--Map3DSystem.Quest.SendToClient(nil, msg, nil);
--end
--
---- CRequire wrong answer
--function Quest_Server.QuestUpdateCRequireWrongAnswer(UID, id, CurrentDialog_NPC_id)
	--local msg = {
		--Opcode = Quest_MSG.SMSG_QUESTUPDATE_CREQUIRE_WRONGANSWER,
		--id = id, -- goal id
		--CurrentDialog_NPC_id = CurrentDialog_NPC_id,
	--};
	---- SMSG_QUESTUPDATE_CREQUIRE_WRONGANSWER
	--Map3DSystem.Quest.SendToClient(nil, msg, nil);
--end
--
---- update the client the quest is completed
--function Quest_Server.QuestUpdateComplete(UID, quest_id)
	--local msg = {
		--Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTUPDATE_COMPLETE,
		--quest_id = quest_id, 
	--};
	---- SMSG_QUESTUPDATE_COMPLETE
	--Map3DSystem.Quest.SendToClient(nil, msg, nil);
--end
--
--isQuestDBInit = false;


NPL.load("(gl)script/ide/commonlib.lua"); -- many sub dependency included


-- quest server receive. 
local function activate()
	if(msg.TestCase == "TP") then	
		log("server received: \n")
		commonlib.echo(msg);
		if(not msg.nid) then
			-- quick authentication, just accept any connection as simpleclient
			msg.nid = "simpleclient";
			NPL.accept(msg.tid, msg.nid);
		end
		NPL.activate("(main):script/kids/3DMapSystemQuest/Quest_MSGHandler_Server.lua", msg)
		NPL.activate("simpleclient:script/kids/3DMapSystemQuest/Quest_Client.lua", {TestCase = "TP", data="from server"})
	end
	
	do return end
	
	--if(msg.type == "startup") then
		--Quest_Server.Init();
		--return;
	--end
	--
	--local text = commonlib.serialize(msg);
	--
	----local logtext = ParaUI.CreateUIObject("button", "logtext", "_lt", 0, 0, 400, 400);
	----logtext.text = text;
	----logtext:AttachToRoot();
	--log("11111111111111111111111111111111111111111\n"..text.."\n");
	--
	--
	--if(Map3DSystem.Quest.DebugQuestMessage == true) then
		---- just log any message it receives
		--log("Quest_Server recv msg: \n");
		--commonlib.log(msg);
	--end
	--
	---- TODO: attach UID of the client
	--msg.UID = "myself";
	--
	--if(isQuestDBInit == false) then
		--isQuestDBInit = true;
		---- refetch database data
		--System.Quest.DB.GetAllNPCs();
		--System.Quest.DB.GetAllQuests();
		--System.Quest.DB.GetAllGossip();
		--System.Quest.DB.GetAllNPC_Quest_Start_Relations();
		--System.Quest.DB.GetAllNPC_Quest_Finish_Relations();
		--System.Quest.DB.GetAllCharacter_QuestStatus();
		--System.Quest.DB.GetAllCReq_Goals();
	--end
	--
	---- call server msg handler
	--Map3DSystem.Quest.Server.MSGHandler.MSGProc(msg);
end

NPL.this(activate);

--function Quest_Server.EnterServerMode()
	--log("Quest_Server.EnterServerMode()\n");
	--NPL.activate("script/kids/3DMapSystemQuest/Quest_Server.lua", {type = "startup"});
--end
--
--function Quest_Server.Init()
	--log("Quest_Server.Init()\n");
--end