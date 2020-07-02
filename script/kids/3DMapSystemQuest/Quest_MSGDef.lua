--[[
Title: all messages used by both Quest server and client
Author(s): WangTian
Date: 2008/12/11

Desc: all quest messages are beginned with a field called Opcode. 
It defines the message structure sent between client and server. 
Message name begins with SMSG means message send from server, and CMSG means message send from client.
Messages usually come in pairs. e.g. client query and server reply.

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_MSGDef.lua");
------------------------------------------------------------
]]

if(not Map3DSystem.Quest_MSG) then Map3DSystem.Quest_MSG = {}; end

local Quest_MSG = Map3DSystem.Quest_MSG;


local i=0;
local function AutoEnum()
	i = i + 1;
	return i;
end
local function LastEnum(index)
	if(index ~= nil) then
		i = index;
	end
	return i;
end


-- NOTE: we use these message pairs to transfer the quest logs at player login
-- TODO: need refine logic
--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_PLAYER_LOGIN,
--	UID = , -- player uid
--};
Quest_MSG.CMSG_PLAYER_LOGIN = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_PLAYER_QUESTS_AND_STATUS,
--	questlogs = {
--		[1] = {status, quest_id = , Title = , Details = , Objectives = , Requires= , RewOrReqMoney = , }
--		[2] = {status, quest_id = , Title = , Details = , Objectives = , Requires= , RewOrReqMoney = , }
--		},
--	Quest Status
--0  QUEST_STATUS_NONE  Quest isn't shown in quest list; default  
--1  QUEST_STATUS_COMPLETE  Quest has been completed  
--2  QUEST_STATUS_UNAVAILABLE  Quest is unavailable to the character  
--3  QUEST_STATUS_INCOMPLETE  Quest is active in quest log but incomplete  
--4  QUEST_STATUS_AVAILABLE  Quest is available to be taken by character  
--};
Quest_MSG.SMSG_PLAYER_QUEST_LOGS = AutoEnum()


--"CMSG_PLAYER_LOGIN"
--
--"SMSG_CHARACTER_LOGIN_FAILED"
--
--"CMSG_PLAYER_LOGOUT"
--
--"SMSG_LOGOUT_COMPLETE"


-----------------------------
-- near by NPCs
-----------------------------
--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_NEARBY_NPCS,
--	posX = ,
--	posY = ,
--	posZ = ,
--};
Quest_MSG.CMSG_NEARBY_NPCS = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_NEARBY_NPCS,
--	posX = ,
--	posY = ,
--	posZ = ,
--	NPCs = {
--			[1] = {ID = ..., Name = ..., AssetName = ...,},
--			[2] = {ID = ..., Name = ..., AssetName = ...,},
--		},
--};
Quest_MSG.SMSG_NEARBY_NPCS = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_MOVE,
--	posX = ,
--	posY = ,
--	posZ = ,
--};
Quest_MSG.CMSG_MOVE = AutoEnum()

-----------------------------
-- questgiver status
-----------------------------
--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_QUESTGIVER_STATUS_QUERY,
--	NPC_id = , guid of NPC or game object
--};
Quest_MSG.CMSG_QUESTGIVER_STATUS_QUERY = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTGIVER_STATUS,
--	NPC_id = ,
--	status = , -- QuestGiverStatus
    --DIALOG_STATUS_NONE                     = 0,
    --DIALOG_STATUS_UNAVAILABLE              = 1,
    --DIALOG_STATUS_CHAT                     = 2,
    --DIALOG_STATUS_INCOMPLETE               = 3,
    --DIALOG_STATUS_REWARD_REP               = 4,
    --DIALOG_STATUS_AVAILABLE_REP            = 5,
    --DIALOG_STATUS_AVAILABLE                = 6,
    --DIALOG_STATUS_REWARD2                  = 7,             not yellow dot on minimap
    --DIALOG_STATUS_REWARD                   = 8              yellow dot on minimap
    
    -- old definition
	-- status = 0: no available quest information related
	-- status = 1: available quest may be shown as a yellow exclamatory mark "!"
	-- status = 2: not available quest(maybe due to reputation or level) may be shown as a grey exclamatory mark "!"
	-- status = 3: quest waited to complete may be shown as a grey question mark "?"
	-- status = 4: completed quest waited for accomplish may be shown as a yellow question mark "?"
	-- status = 5: daily quest available
	-- status = 6: daily quest completed
--};
Quest_MSG.SMSG_QUESTGIVER_STATUS = AutoEnum()


-- NOTE: this pair of message will handle the all the NPCs around player range
--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_QUESTGIVER_STATUS_MULTIPLE_QUERY,
--};
Quest_MSG.CMSG_QUESTGIVER_STATUS_MULTIPLE_QUERY = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTGIVER_STATUS_MULTIPLE,
--	results = {
--		[1] = {NPC_id, status = },
--		[2] = {NPC_id, status = },
--		},
--};
Quest_MSG.SMSG_QUESTGIVER_STATUS_MULTIPLE = AutoEnum()



-----------------------------
-- communications with NPC
-----------------------------
--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_QUESTGIVER_HELLO,
--	NPC_id = , 
--};
Quest_MSG.CMSG_QUESTGIVER_HELLO = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTGIVER_QUEST_LIST,
--	NPC_id = , 
--	Title = ,
--	playerEmote = , -- TODO
--	NPCEmote = , -- TODO
--	MenuItems = {
--		[1] = {quest_id = ..., status[int], QuestLevel, title[string]},
--		[2] = {quest_id = ..., status[int], QuestLevel, title[string]},
--	Quest Status
--0  QUEST_STATUS_NONE  Quest isn't shown in quest list; default  
--1  QUEST_STATUS_COMPLETE  Quest has been completed  
--2  QUEST_STATUS_UNAVAILABLE  Quest is unavailable to the character  
--3  QUEST_STATUS_INCOMPLETE  Quest is active in quest log but incomplete  
--4  QUEST_STATUS_AVAILABLE  Quest is available to be taken by character  
--};
Quest_MSG.SMSG_QUESTGIVER_QUEST_LIST = AutoEnum()


--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_QUESTGIVER_QUERY_QUEST,
--	NPC_id = , 
--	quest_id = , 
--};
-- e.g. player get the quest list and choose one quest to accept
Quest_MSG.CMSG_QUESTGIVER_QUERY_QUEST = AutoEnum()

-- NOTE: not used
--Quest_MSG.CMSG_QUESTGIVER_QUEST_AUTOLAUNCH = AutoEnum()


--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTGIVER_QUEST_DETAILS,
--	NPC_id = , 
--	quest_id = ,
--	Title = , 
--	Details = , 
--	Objectives = , 
--	ActivateAccept = bool, -- TODO
--	SuggestedPlayers = , -- TODO
--	isHiddenRewards = bool, -- TODO
--	Requires = {
--		[1] = {id = , app_key = , commandname = , questiondata = },
--		[2] = {id = , app_key = , commandname = , questiondata = },
--		},
--	if(isHiddenRewards == true) then
--		-- no more rewards field required
--	elseif(isHiddenRewards == false) then
--		-- currently we might only support money rewards
--		RewChoiceItems = {
--			[1] = {item_id = , item_count = , DisplayInfoID, }, -- TODO
--			[2] = {item_id = , item_count = , DisplayInfoID, }, -- TODO
--			},
--		RewItems = {
--			[1] = {item_id = , item_count = , DisplayInfoID, }, -- TODO
--			[2] = {item_id = , item_count = , DisplayInfoID, }, -- TODO
--			},
--		RewOrReqMoney = , -- currently rewards money
--		RewSpell = , -- reward spell, this spell will display (icon) -- TODO
--		RewSpellCast = , -- casted spell -- TODO
--		RewCharTitleId = , -- player gets this title -- TODO
--	end
--};
Quest_MSG.SMSG_QUESTGIVER_QUEST_DETAILS = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_QUESTGIVER_ACCEPT_QUEST,
--	NPC_id = , 
--	quest_id = , 
--};
Quest_MSG.CMSG_QUESTGIVER_ACCEPT_QUEST = AutoEnum()

-- NOTE: additional message that response the quest accept, otherwise it will send back an 
--		SMSG_QUESTGIVER_QUEST_INVALID message containing the invalid reason
--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTGIVER_ACCEPT_QUEST_CONFIRM,
--	NPC_id = , 
--	quest_id = , 
--};
Quest_MSG.SMSG_QUESTGIVER_ACCEPT_QUEST_CONFIRM = AutoEnum()

----------------------------------------------------------------
-- For quest complete process, please refer to QuestDB.lua
----------------------------------------------------------------

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_QUESTGIVER_COMPLETE_QUEST,
--	NPC_id = , 
--	quest_id = , 
--};
Quest_MSG.CMSG_QUESTGIVER_COMPLETE_QUEST = AutoEnum()


-- This message may be sent ONLY when there is actually items required
-- Currently not used in Aquarius implementation
--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTGIVER_REQUEST_ITEMS,
--	NPC_id = , --npc id
--	quest_id = , 
--	Title = ,
--	RequestItemsText = , -- RequestItemsText
--};
--Quest_MSG.SMSG_QUESTGIVER_REQUEST_ITEMS = AutoEnum()


-- This message may be sent ONLY when there is actually rewards required
-- Currently not used in Aquarius implementation
--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_QUESTGIVER_REQUEST_REWARD,
--	NPC_id = , 
--	quest_id = , 
--};
--Quest_MSG.CMSG_QUESTGIVER_REQUEST_REWARD = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTGIVER_OFFER_REWARD,
--	NPC_id = , 
--	quest_id = , 
--	Title = ,
--	OfferRewardText = ,
--	OfferRewardEmote = , -- TODO
--	NOTE: currently we might only support money rewards
--	Rewards = {
--		RewChoiceItems = {
--			[1] = {item_id = , item_count = , DisplayInfoID, }, -- TODO
--			[2] = {item_id = , item_count = , DisplayInfoID, }, -- TODO
--			},
--		RewItems = {
--			[1] = {item_id = , item_count = , DisplayInfoID, }, -- TODO
--			[2] = {item_id = , item_count = , DisplayInfoID, }, -- TODO
--			},
--		RewOrReqMoney = , -- currently rewards money
--		RewSpell = , -- reward spell, this spell will display (icon) -- TODO
--		RewSpellCast = , -- casted spell -- TODO
--		RewCharTitleId = , -- player gets this title -- TODO
--		},
--};
Quest_MSG.SMSG_QUESTGIVER_OFFER_REWARD = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTGIVER_FINISH_QUEST,
--	NPC_id = , 
--	quest_id = , 
--};
Quest_MSG.SMSG_QUESTGIVER_FINISH_QUEST = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_QUESTGIVER_CHOOSE_REWARD,
--	NPC_id = , 
--	quest_id = , 
--	reward = , -- index into RewChoiceItems
--};
Quest_MSG.CMSG_QUESTGIVER_CHOOSE_REWARD = AutoEnum()


--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTGIVER_QUEST_INVALID,
--	msg = , int QuestFailedReasons:
    --INVALIDREASON_DONT_HAVE_REQ                 = 0,
    --INVALIDREASON_QUEST_FAILED_LOW_LEVEL        = 1,        //You are not high enough level for that quest.
    --INVALIDREASON_QUEST_FAILED_WRONG_RACE       = 6,        //That quest is not available to your race.
    --INVALIDREASON_QUEST_ALREADY_DONE            = 7,        //You have completed that quest.
    --INVALIDREASON_QUEST_ONLY_ONE_TIMED          = 12,       //You can only be on one timed quest at a time.
    --INVALIDREASON_QUEST_ALREADY_ON              = 13,       //You are already on that quest
    --INVALIDREASON_QUEST_FAILED_EXPANSION        = 16,       //This quest requires an expansion enabled account.
    --INVALIDREASON_QUEST_ALREADY_ON2             = 18,       //You are already on that quest
    --INVALIDREASON_QUEST_FAILED_MISSING_ITEMS    = 21,       //You don't have the required items with you. Check storage.
    --INVALIDREASON_QUEST_FAILED_NOT_ENOUGH_MONEY = 23,       //You don't have enough money for that quest.
    --INVALIDREASON_DAILY_QUESTS_REMAINING        = 26,       //You have already completed 10 daily quests today
    --INVALIDREASON_QUEST_FAILED_CAIS             = 27,       //You cannot complete quests once you have reached tired time
--};
Quest_MSG.SMSG_QUESTGIVER_QUEST_INVALID = AutoEnum()



--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_QUESTGIVER_BYE,
--  NPC_id = ,
--};
-- e.g.  player says "Bye" or leave the NPC dialog range
Quest_MSG.CMSG_QUESTGIVER_BYE = AutoEnum()


--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTGIVER_BYE,
--  NPC_id = ,
--};
-- e.g. NPC says dialog session complete, usually happened after player says "Bye" or leave the NPC dialog range
Quest_MSG.SMSG_QUESTGIVER_BYE = AutoEnum()


--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTGIVER_QUEST_COMPLETE,
--	quest_id = , 
--	XP = , -- experience point TODO
--	RewOrReqMoney = , -- reward money
--	RewItems = {
--		[1] = {item_id = , item_count = , }, -- TODO
--		[2] = {item_id = , item_count = , }, -- TODO
--		},
--};
Quest_MSG.SMSG_QUESTGIVER_QUEST_COMPLETE = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTGIVER_QUEST_FAILED,
--	quest_id = , 
--};
Quest_MSG.SMSG_QUESTGIVER_QUEST_FAILED = AutoEnum()



--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_QUESTLOG_SWAP_QUEST,
--	slot1 = , 
--	slot2 = , 
--};
Quest_MSG.CMSG_QUESTLOG_SWAP_QUEST = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_QUESTLOG_REMOVE_QUEST,
--	slot = , 
--};
Quest_MSG.CMSG_QUESTLOG_REMOVE_QUEST = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTLOG_FULL,
--};
Quest_MSG.SMSG_QUESTLOG_FULL = AutoEnum()



--  NOTE: send client require update
--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_QUESTUPDATE_CREQUIRE,
--	id = , -- creq_goal id
--	answerdata = , -- answerdata
--};
Quest_MSG.CMSG_QUESTUPDATE_CREQUIRE = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTUPDATE_CREQUIRE_RIGHTANSWER,
--	id = , -- creq_goal id
--	count = , -- old count + add count
--	CurrentDialog_NPC_id = , -- current dialog session NPC id
--};
Quest_MSG.SMSG_QUESTUPDATE_CREQUIRE_RIGHTANSWER = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTUPDATE_CREQUIRE_WRONGANSWER,
--	id = , -- creq_goal id
--	CurrentDialog_NPC_id = , -- current dialog session NPC id
--};
Quest_MSG.SMSG_QUESTUPDATE_CREQUIRE_WRONGANSWER = AutoEnum()



--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTUPDATE_FAILED,
--	quest_id = , 
--};
Quest_MSG.SMSG_QUESTUPDATE_FAILED = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTUPDATE_FAILEDTIMER,
--	quest_id = , 
--};
Quest_MSG.SMSG_QUESTUPDATE_FAILEDTIMER = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTUPDATE_COMPLETE,
--	quest_id = , 
--};
Quest_MSG.SMSG_QUESTUPDATE_COMPLETE = AutoEnum()


--	NOTE: some fields are not
--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTUPDATE_ADD_KILL,
--	quest_id = , 
--	ReqCreatureOrGOId = , 
--	count = , -- old count + add count
--	ReqCreatureOrGOCount = , -- required count
--	guid = , -- creature id? what for?
--};
-- e.g.: please kill ReqCreatureOrGOId : count / ReqCreatureOrGOCount
Quest_MSG.SMSG_QUESTUPDATE_ADD_KILL = AutoEnum()

--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUESTUPDATE_ADD_ITEM,
--	ReqItemId = , 
--	count = , 
--};
Quest_MSG.SMSG_QUESTUPDATE_ADD_ITEM = AutoEnum()



--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_QUEST_CONFIRM_ACCEPT,
--	quest_id = , 
--};
Quest_MSG.CMSG_QUEST_CONFIRM_ACCEPT = AutoEnum()

-- NOTE: Not used currently. If player in party, all players that can accept this quest 
--		will receive confirmation box to accept quest CMSG_QUEST_CONFIRM_ACCEPT/SMSG_QUEST_CONFIRM_ACCEPT
--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.SMSG_QUEST_CONFIRM_ACCEPT,
--};
--Quest_MSG.SMSG_QUEST_CONFIRM_ACCEPT = AutoEnum()


-- NOTE: currently not used
--local msg = {
--	Opcode = Map3DSystem.Quest_MSG.CMSG_PUSHQUESTTOPARTY,
--	quest_id = , 
--};
--Quest_MSG.CMSG_PUSHQUESTTOPARTY = AutoEnum()