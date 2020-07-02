--[[
Title: Quest system client.
Author(s): WangTian
Date: 2008/12/10

Quest client will send CMSG message to the server whenever an quest API requires a remote data query
When a quest client receive SMSG message it will call approporiate client functions to visualize message information

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_Client.lua");
------------------------------------------------------------
]]

--NPL.load("(gl)script/kids/3DMapSystemQuest/Main.lua");
--NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_MSGDef.lua");
--
--if(not Map3DSystem.Quest.Client) then Map3DSystem.Quest.Client = {}; end
--
--local Quest_MSGHandler_Client = Map3DSystem.Quest.Client.MSGHandler;
--local Quest_Client = Map3DSystem.Quest.Client;
--local Quest_MSG = Map3DSystem.Quest_MSG;
--
--------------------------------------------------
---- quest client send according to API calls
--------------------------------------------------
--
---- It will logged out from previous server and then logged in to the new one. 
--function Quest_Client.LoginServer(SID)
	---- TODO: player login and waiting for character status from server, e.g. quest logs
	---- currently in Aquarius all function calls are local
	--
	---- clear quest log
	----Map3DSystem.Quest.Client.Log = {};
	--local k, v;
	--for k, v in pairs(Map3DSystem.Quest.Client.Log) do
		--Map3DSystem.Quest.Client.Log[k] = nil;
	--end
	--
	--local msg = {
		--Opcode = Map3DSystem.Quest_MSG.CMSG_PLAYER_LOGIN,
		----UID = , -- player uid
	--};
	---- CMSG_PLAYER_LOGIN
	--Map3DSystem.Quest.SendToServer(nil, msg, nil);
--end
--
---- log out either by sending the logout message to server or not. 
--function Quest_Client.LogoutServer(bSilent)
	---- TODO: 
	---- currently in Aquarius all function calls are local
--end
--
---- get all nearby NPCs
--function Quest_Client.GetNearbyNPCs()
	--local x, y, z = ParaScene.GetPlayer():GetPosition();
	--local msg = {
		--Opcode = Quest_MSG.CMSG_NEARBY_NPCS,
		--posX = x,
		--posY = y,
		--posZ = z,
	--};
	---- CMSG_NEARBY_NPCS
	--Map3DSystem.Quest.SendToServer(nil, msg, nil);
--end
--
---- move the player
---- NOTE: this is a temporary opcode that update the player position at a common rate
---- this field or message will be updated to the MMORPG-like move management and restrict the velocity
--function Quest_Client.BroadcastMyPosition(x, y, z)
	--local x, y, z = ParaScene.GetPlayer():GetPosition();
	--local msg = {
		--Opcode = Quest_MSG.CMSG_MOVE,
		--posX = x,
		--posY = y,
		--posZ = z,
	--};
	---- CMSG_MOVE
	--Map3DSystem.Quest.SendToServer(nil, msg, nil);
--end
	--
---- query the quest giver NPC status
---- avaible quest or complete quest .etc
---- @param NPC_id: NPC ID
--function Quest_Client.QuestgiverStatusQuery(NPC_id)
	--local msg = {
		--Opcode = Quest_MSG.CMSG_QUESTGIVER_STATUS_QUERY,
		--NPC_id = NPC_id, 
	--};
	---- CMSG_QUESTGIVER_STATUS_QUERY
	--Map3DSystem.Quest.SendToServer(nil, msg, nil);
--end
--
---- query giver hello, say hi to NPC
---- @param NPC_id: NPC ID
--function Quest_Client.QuestgiverHello(NPC_id)
	--local msg = {
		--Opcode = Quest_MSG.CMSG_QUESTGIVER_HELLO,
		--NPC_id = NPC_id, 
	--};
	---- CMSG_QUESTGIVER_HELLO
	--Map3DSystem.Quest.SendToServer(nil, msg, nil);
--end
--
---- query quest details
---- @param NPC_id: NPC ID
---- @param quest_id: quest ID
--function Quest_Client.QuestgiverQueryQuest(NPC_id, quest_id)
	--local msg = {
		--Opcode = Quest_MSG.CMSG_QUESTGIVER_QUERY_QUEST,
		--NPC_id = NPC_id, 
		--quest_id = quest_id,
	--};
	---- CMSG_QUESTGIVER_QUERY_QUEST
	--Map3DSystem.Quest.SendToServer(nil, msg, nil);
--end
--
--
---- accept quest
---- @param NPC_id: NPC ID
---- @param quest_id: quest ID
--function Quest_Client.QuestgiverAcceptQuest(NPC_id, quest_id)
	--local msg = {
		--Opcode = Quest_MSG.CMSG_QUESTGIVER_ACCEPT_QUEST,
		--NPC_id = NPC_id, 
		--quest_id = quest_id,
	--};
	---- CMSG_QUESTGIVER_ACCEPT_QUEST
	--Map3DSystem.Quest.SendToServer(nil, msg, nil);
--end
--
---- complete quest
---- @param NPC_id: NPC ID
---- @param quest_id: quest ID
--function Quest_Client.QuestgiverCompleteQuest(NPC_id, quest_id)
	--local msg = {
		--Opcode = Quest_MSG.CMSG_QUESTGIVER_COMPLETE_QUEST,
		--NPC_id = NPC_id, 
		--quest_id = quest_id,
	--};
	--
	----------------------------------------------------------------------
	---- TODO: temp code to remove log, never expose such logic
	----		add another hand shake message pair
	--Map3DSystem.Quest.Client.Log[msg.quest_id] = nil;
	----------------------------------------------------------------------
	--
	---- CMSG_QUESTGIVER_COMPLETE_QUEST
	--Map3DSystem.Quest.SendToServer(nil, msg, nil);
--end
--
---- player says "Bye" to NPC
---- @param NPC_id: NPC ID
---- @param quest_id: quest ID
--function Quest_Client.QuestgiverBye(NPC_id)
	--local msg = {
		--Opcode = Quest_MSG.CMSG_QUESTGIVER_BYE,
		--NPC_id = NPC_id, 
	--};
	---- CMSG_QUESTGIVER_BYE
	--Map3DSystem.Quest.SendToServer(nil, msg, nil);
--end
--
---- request quest reward
---- @param NPC_id: NPC ID
---- @param quest_id: quest ID
--function Quest_Client.QuestgiverRequestReward(NPC_id, quest_id)
	--local msg = {
		--Opcode = Quest_MSG.CMSG_QUESTGIVER_REQUEST_REWARD,
		--NPC_id = NPC_id, 
		--quest_id = quest_id,
	--};
	---- CMSG_QUESTGIVER_REQUEST_REWARD
	--Map3DSystem.Quest.SendToServer(nil, msg, nil);
--end
--
--
---- crequire update
---- @param id: goal ID
---- @param answerdata: 
--function Quest_Client.QuestUpdateCRequire(id, answerdata)
	--local msg = {
		--Opcode = Quest_MSG.CMSG_QUESTUPDATE_CREQUIRE,
		--id = id,  -- goal id
		--answerdata = answerdata,
	--};
	---- CMSG_QUESTUPDATE_CREQUIRE
	--Map3DSystem.Quest.SendToServer(nil, msg, nil);
--end

---- quest client receive. 
--local function activate()
	--if(Map3DSystem.Quest.DebugQuestMessage == true) then
		---- just log any message it receives
		--log("Quest_Client recv msg: \n");
		--commonlib.log(msg);
	--end
	--
	---- TODO: attach UID of the client
	---- currently in Aquarius its all local client and server
	--msg.UID = nil;
	--
	---- call server msg handler
	--Map3DSystem.Quest.Client.MSGHandler.MSGProc(msg);
--end
--
--NPL.this(activate);


local function activate()
	-- receive message
	-- direct to main thread
	NPL.activate("(main):script/kids/3DMapSystemQuest/Main.lua", msg);
	
	if(msg.TestCase == "TP") then	
		log("client received: \n")
		commonlib.echo(msg)
	end
end
NPL.this(activate)