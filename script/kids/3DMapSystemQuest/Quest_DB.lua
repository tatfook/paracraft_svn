--[[
Title: Quest system database
Author(s): WangTian
Date: 2008/12/11
Decs: this file contains database helper function and a full description of the relations between tables.

----------------------------------------------------
Database files and tables  

QuestNPCDBFile: QuestNPC.db
	NPC: use the original #WorldName#.NPC.db table
	npc_gossip: NPC gossip texts

QuestStatusDBFile: QuestStatus.db
	character_queststatus: hold the user quest status

QuestDBFile: Quest.db
	quest_template: quest
	npc_quest_start_relation: Holds NPC quest giver relations on which NPCs start which quests.
	npc_quest_finish_relation: Holds NPC quest ender relations on which NPCs finishes which quests.
	creq_goals: Holds CReq goal command name and data
	
--------------------------------------------------------
----		UNDERSTAND CREQUIRES ENGAGEMENT			----
--------------------------------------------------------

On player quest query, the quest server will answer with an SMSG_QUESTGIVER_QUEST_DETAILS message. On server side 
quest_template contains four fields CReqGoalId* that index into the creq_goals table. and four CReqCount* fields 
that the number of times the CRequires must be finished. The SMSG_QUESTGIVER_QUEST_DETAILS message contains 
a field called CRequires that list all the CRequire data. Each entry contains an app_key, a commandname and 
a questiondata. Client side quest system will use the data to detect whether the quest objective is completed. 
CRequires uses a question-and-answer metaphore that quest server send the app commandname and question 
to the client to answer back. Both questiondata and answerdata can be any string value, a real answer 
or a serialized table. Once client detect objective is completed, it will send a CMSG_QUESTUPDATE_CREQUIRE message 
with the answerdata to the CReq_Goal. If answer is right, quest server will mark the quest objective completed 
in queststatus table, and send back an SMSG_QUESTUPDATE_ADD_ITEM or SMSG_QUESTUPDATE_COMPLETE message. 
Otherwise the answer doesn't match, and no answer is replied.

Both SReq and CReq shares the same update messages and response e.g. SMSG_QUESTUPDATE_COMPLETE or 
SMSG_QUESTUPDATE_ADD_ITEM. And each quest has a maximum 4 requirements(SReq or CReq). 
And one requirement index(1-4) can only be SReq or CReq. The only difference is the objective detection is 
on server side or on client side.


--------------------------------------------------------
----		UNDERSTAND QUEST COMPLETE PROCESS		----
--------------------------------------------------------
	CMSG_QUESTGIVER_COMPLETE_QUEST		C--->S
	SMSG_QUESTGIVER_REQUEST_ITEMS		C<---S
	CMSG_QUESTGIVER_REQUEST_REWARD		C--->S
	SMSG_QUESTGIVER_OFFER_REWARD		C<---S
	SMSG_QUESTGIVER_FINISH_QUEST		C<---S

TODO: the code logic and name meaning for Complete and Finish
Quest status is complete is not actually completed. It must be rewarded until the next quest in chain 
can be obtained. Quest completed is only an indication of quest can be rewards or not.
Here in current implementation, SMSG_QUESTGIVER_REQUEST_ITEMS and CMSG_QUESTGIVER_REQUEST_REWARD are skipped.
Need to refine the logic to real reward process, when item system in introduced.


----------------------------------------------------
----		UNDERSTAND QUEST STRUCTURE			----
----------------------------------------------------

[entry] INTEGER NOT NULL PRIMARY KEY UNIQUE, 
		Quest Id. Quest ID is the Primary Key for the Table. Each Quest ID must be unique
[Method] INTEGER NOT NULL DEFAULT (2), 
		Accepted values: 0, 1 or 2. If value = 0 then Quest is autocompleted (skip objectives/details). 
[PrevQuestId] INTEGER NOT NULL DEFAULT (0), 
[NextQuestId] INTEGER NOT NULL DEFAULT (0), 
[ExclusiveGroup] INTEGER NOT NULL DEFAULT (0), 
[NextQuestInChain] INTEGER NOT NULL DEFAULT (0), 
		See UNDERSTAND QUEST ENGAGEMENT section
[Title] VARCHAR NOT NULL DEFAULT ('Title'), 
		Title of the quest. 
[Details] VARCHAR DEFAULT ('Details'), 
		The quest text. 
[Objectives] VARCHAR DEFAULT ('Objectives'), 
		Objectives of the quest. If empty, quest is an auto-complete quest 
		that can be immediately finished without accepting it first. 
[OfferRewardText] VARCHAR DEFAULT ('OfferRewardText'), 
		First text send to the player by the NPC when completing the quest. 
[RequestItemsText] VARCHAR DEFAULT ('RequestItemsText'), 
		Text sent to player when the player tries to talk to the NPC with the quest active but incomplete.
[EndText] VARCHAR DEFAULT ('EndText'), 
[ObjectiveText1] VARCHAR, 
[ObjectiveText2] VARCHAR, 
[ObjectiveText3] VARCHAR, 
[ObjectiveText4] VARCHAR, 
		Used to define non-standard objective texts, that show up in the questlog.
[SReqItemId1] INTEGER NOT NULL DEFAULT (0), 
[SReqItemId2] INTEGER NOT NULL DEFAULT (0), 
[SReqItemId3] INTEGER NOT NULL DEFAULT (0), 
[SReqItemId4] INTEGER NOT NULL DEFAULT (0), 
		Item_template Id of required item to complete the quest. 
[SReqItemCount1] INTEGER NOT NULL DEFAULT (0), 
[SReqItemCount2] INTEGER NOT NULL DEFAULT (0), 
[SReqItemCount3] INTEGER NOT NULL DEFAULT (0), 
[SReqItemCount4] INTEGER NOT NULL DEFAULT (0), 
		Amount of required items 
[SReqCreatureOrGOId1] INTEGER NOT NULL DEFAULT (0), 
[SReqCreatureOrGOId2] INTEGER NOT NULL DEFAULT (0), 
[SReqCreatureOrGOId3] INTEGER NOT NULL DEFAULT (0), 
[SReqCreatureOrGOId4] INTEGER NOT NULL DEFAULT (0), 
		Value > 0: required creature_template ID the player needs to kill/cast on in order to complete the quest.
		Value < 0: required gameobject_template ID the player needs to cast on in order to complete the quest.
[SReqCreatureOrGOCount1] INTEGER NOT NULL DEFAULT (0), 
[SReqCreatureOrGOCount2] INTEGER NOT NULL DEFAULT (0), 
[SReqCreatureOrGOCount3] INTEGER NOT NULL DEFAULT (0), 
[SReqCreatureOrGOCount4] INTEGER NOT NULL DEFAULT (0), 
		The number of times the creature or gameobject must be killed or casted upon. 
[CReqGoalId1] INTEGER NOT NULL DEFAULT (0), 
[CReqGoalId2] INTEGER NOT NULL DEFAULT (0), 
[CReqGoalId3] INTEGER NOT NULL DEFAULT (0), 
[CReqGoalId4] INTEGER NOT NULL DEFAULT (0), 
		required CRequireGoal, id index into the creq_goals table
[CReqCount1] INTEGER NOT NULL DEFAULT (0), 
[CReqCount2] INTEGER NOT NULL DEFAULT (0), 
[CReqCount3] INTEGER NOT NULL DEFAULT (0), 
[CReqCount4] INTEGER NOT NULL DEFAULT (0), 
		The number of times the crequire must be finished. 
[RewChoiceItemId1] INTEGER NOT NULL DEFAULT (0), 
[RewChoiceItemId2] INTEGER NOT NULL DEFAULT (0), 
[RewChoiceItemId3] INTEGER NOT NULL DEFAULT (0), 
[RewChoiceItemId4] INTEGER NOT NULL DEFAULT (0), 
[RewChoiceItemId5] INTEGER NOT NULL DEFAULT (0), 
[RewChoiceItemId6] INTEGER NOT NULL DEFAULT (0), 
[RewChoiceItemCount1] INTEGER NOT NULL DEFAULT (0), 
[RewChoiceItemCount2] INTEGER NOT NULL DEFAULT (0), 
[RewChoiceItemCount3] INTEGER NOT NULL DEFAULT (0), 
[RewChoiceItemCount4] INTEGER NOT NULL DEFAULT (0), 
[RewChoiceItemCount5] INTEGER NOT NULL DEFAULT (0), 
[RewChoiceItemCount6] INTEGER NOT NULL DEFAULT (0), 
[RewItemId1] INTEGER NOT NULL DEFAULT (0), 
[RewItemId2] INTEGER NOT NULL DEFAULT (0), 
[RewItemId3] INTEGER NOT NULL DEFAULT (0), 
[RewItemId4] INTEGER NOT NULL DEFAULT (0), 
[RewItemCount1] INTEGER NOT NULL DEFAULT (0), 
[RewItemCount2] INTEGER NOT NULL DEFAULT (0), 
[RewItemCount3] INTEGER NOT NULL DEFAULT (0), 
[RewItemCount4] INTEGER NOT NULL DEFAULT (0), 
[RewOrReqMoney] INTEGER NOT NULL DEFAULT (0), 
[RewSpell] INTEGER NOT NULL DEFAULT (0), 
[RewSpellCast] INTEGER NOT NULL DEFAULT (0), 
[RewCharTitleId] INTEGER NOT NULL DEFAULT (0), 
		Rewards
[StartScript] INTEGER DEFAULT (''), 
[EndScript] INTEGER DEFAULT (''))
		Start and end script

----------------------------------------------------
----		UNDERSTAND QUEST ENGAGEMENT			----
----------------------------------------------------

[PrevQuestId] INTEGER NOT NULL,
[NextQuestId] INTEGER NOT NULL,
[ExclusiveGroup] INTEGER NOT NULL,
[NextQuestInChain] INTEGER NOT NULL,

PrevQuestId:
if value > 0: Contains the previous quest id, that must be completed before this quest can be started. 
If value < 0: Contains the parent quest id, that must be active before this quest can be started. 

NextQuestId:
If value > 0: Contains the next quest id, if PrevQuestId of that quest is not sufficient. 
If value < 0: Contains the sub quest id, if PrevQuestId of that quest is not sufficient. 
		If quest have many alternative next quests (class specific quests lead from 
		single not class specific quest) field PrevQuestId in next quests can used for setting this dependence. 

ExclusiveGroup:
if ExclusiveGroup > 0: Allows to define a group of quests of which only one may be chosen and completed. 
		E.g. if from quests 1200, 1201 and 1202 only one should be allowed to be chosen, 
		insert 1200 into ExclusiveGroup of all 3 quests. 
if ExclusiveGroup < 0: Allows to define a group of quests of which all must be completed and 
		rewarded to start next quest. E.g. if quest 1000 dependent from one of quests 1200, 
		1201 and 1202 and all this quests have same negative exclusive group then all this quest 
		must be completed and rewarded before quest 1000 can be started. 

NextQuestInChain:
The quest entry from a creature or gameobject that ends a quest and starts a new one. The result is, 
		that if you end the quest, the new quest instantly appears from the quest giver. 

Examples:
---------------------------------------------------------------------------------
Basic quest 

Single, stand-alone quest with no prerequisites 

    *questA*
    
PrevQuestId = 0        NextQuestId = 0        ExclusiveGroup = 0        NextQuestInChain = 0        entry = questA


When this quest require another quest to be rewarded 

    *questA*
    
PrevQuestId = questX   NextQuestId = 0        ExclusiveGroup = 0        NextQuestInChain = 0        entry = questA


---------------------------------------------------------------------------------
Chain of quests 

Player get quests in a strict chain that must be completed in a specific order. 

    *questA*
        |
    *questB*
        |
    *questC*
        |
    *questD*
    
PrevQuestId = 0        NextQuestId = 0        ExclusiveGroup = 0        NextQuestInChain = questB    entry = questA
PrevQuestId = questA   NextQuestId = 0        ExclusiveGroup = 0        NextQuestInChain = questC    entry = questB
PrevQuestId = questB   NextQuestId = 0        ExclusiveGroup = 0        NextQuestInChain = questD    entry = questC
PrevQuestId = questC   NextQuestId = 0        ExclusiveGroup = 0        NextQuestInChain = 0         entry = questD


---------------------------------------------------------------------------------
Chain of quests with multiple start quests. 

Player should only be allowed to complete one of three possible 

    *questA*     *questB*    *questC*
        \           |           /
          ------ *questD* -----
                    |
                 *questE*
                 
PrevQuestId = 0        NextQuestId = questD   ExclusiveGroup = questA   NextQuestInChain = questD    entry = questA
PrevQuestId = 0        NextQuestId = questD   ExclusiveGroup = questA   NextQuestInChain = questD    entry = questB
PrevQuestId = 0        NextQuestId = questD   ExclusiveGroup = questA   NextQuestInChain = questD    entry = questC
PrevQuestId = 0        NextQuestId = 0        ExclusiveGroup = 0        NextQuestInChain = questE    entry = questD
PrevQuestId = questD   NextQuestId = 0        ExclusiveGroup = 0        NextQuestInChain = 0         entry = questE


---------------------------------------------------------------------------------
Chain of quests with multiple start quests. 

Player must complete all three initial quests before D becomes available 

    *questA*    *questB*    *questC*
        \          |          /
         ------ *questD* -----
                   |
                *questE*
                
PrevQuestId = 0        NextQuestId = questD   ExclusiveGroup = -questA    NextQuestInChain = questD    entry = questA
PrevQuestId = 0        NextQuestId = questD   ExclusiveGroup = -questA    NextQuestInChain = questD    entry = questB
PrevQuestId = 0        NextQuestId = questD   ExclusiveGroup = -questA    NextQuestInChain = questD    entry = questC
PrevQuestId = 0        NextQuestId = 0        ExclusiveGroup = 0          NextQuestInChain = questE    entry = questD
PrevQuestId = questD   NextQuestId = 0        ExclusiveGroup = 0          NextQuestInChain = 0         entry = questE


---------------------------------------------------------------------------------
Quests with split and a child quest 

Completing A unlocks B and C that can be done at the same time. They both need to be completed 
before D becomes available. X is needed to obtain item for C and this quest should only be available if C is active 

                *questA*
                /        \
           *questB     *questC* - *questX*
                \        /
                *questD*
                
PrevQuestId = 0        NextQuestId = 0        ExclusiveGroup = 0         NextQuestInChain = 0        entry = questA
PrevQuestId = questA   NextQuestId = questD   ExclusiveGroup = -questB   NextQuestInChain = 0        entry = questB
PrevQuestId = questA   NextQuestId = questD   ExclusiveGroup = -questB   NextQuestInChain = 0        entry = questC
PrevQuestId = 0        NextQuestId = 0        ExclusiveGroup = 0         NextQuestInChain = 0        entry = questD
PrevQuestId = -questC  NextQuestId = 0        ExclusiveGroup = 0         NextQuestInChain = 0        entry = questX


---------------------------------------------------------------------------------
Multiple quest chains, leading to one final quest 

Player may complete (not required to) X, but has to complete all three quest chains 
before final quest becomes available 

                *questX*
                   |
    *questA*    *questC*    *questE*
       |           |            |
    *questB*    *questD*    *questF*
       \           |           /
         ------ *questG* -----
         
PrevQuestId = 0        NextQuestId = 0         ExclusiveGroup = 0          NextQuestInChain = questC    entry = questX

PrevQuestId = 0        NextQuestId = 0         ExclusiveGroup = 0          NextQuestInChain = questB    entry = questA
PrevQuestId = questA   NextQuestId = questG    ExclusiveGroup = -questB    NextQuestInChain = 0         entry = questB
PrevQuestId = 0        NextQuestId = 0         ExclusiveGroup = 0          NextQuestInChain = questD    entry = questC
PrevQuestId = questC   NextQuestId = questG    ExclusiveGroup = -questB    NextQuestInChain = 0         entry = questD
PrevQuestId = 0        NextQuestId = 0         ExclusiveGroup = 0          NextQuestInChain = questF    entry = questE
PrevQuestId = questE   NextQuestId = questG    ExclusiveGroup = -questB    NextQuestInChain = 0         entry = questF

PrevQuestId = 0        NextQuestId = 0         ExclusiveGroup = 0          NextQuestInChain = 0         entry = questG


------------------------------------------------
----		UNDERSTAND QUEST STATUS			----
------------------------------------------------

[guid] INTEGER UNIQUE PRIMARY KEY NOT NULL,
		The guid now is quest_id
		TODO: It should be the guid of the character, currently we only support one local quest database
[quest] INTEGER NOT NULL,
		The quest ID
[status] INTEGER NOT NULL,
		The current quest status. 
		0  QUEST_STATUS_NONE			Quest isn't shown in quest list; default  
		1  QUEST_STATUS_COMPLETE		Quest has been completed  
		2  QUEST_STATUS_UNAVAILABLE		Quest is unavailable to the character  
		3  QUEST_STATUS_INCOMPLETE		Quest is active in quest log but incomplete  
		4  QUEST_STATUS_AVAILABLE		Quest is available to be taken by character  
[rewarded] BOOL NOT NULL,
		1 or 0 representing whether the quest has been rewarded or not. 



use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_DB.lua");
------------------------------------------------------------
]]

if(not Map3DSystem.Quest.DB) then Map3DSystem.Quest.DB = {}; end

local Quest_DB = Map3DSystem.Quest.DB;

-- NOTE: currently quest database and queststatus database are all local in Aquarius
-- queststatus only records the current user
Quest_DB.QuestNPCDBFile = "QuestNPC.db";
Quest_DB.QuestDBFile = "Quest.db";
Quest_DB.QuestStatusDBFile = "QuestStatus.db";

function Quest_DB.Blablabla()
end


function Quest_DB.GetAllNPCs()
	
	Quest_DB.AllNPCs = {};
	
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Quest_DB.QuestNPCDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local row;
	for row in db:rows("select ID, Name, AssetName, IsGlobal, SnapToTerrain, Weight, Radius, Facing, Scaling, posX, posY, posZ, CustomAppearance from NPC") do
		if(row ~= nil) then
			local NPC = commonlib.deepcopy(row);
			Quest_DB.AllNPCs[tonumber(row.ID)] = NPC;
		end
	end
	
	db:close();
end
-- automatically call Quest_DB.GetAllGossip()
Quest_DB.GetAllNPCs()

function Quest_DB.GetAllGossip()
	
	Quest_DB.GossipTexts = {};
	
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Quest_DB.QuestNPCDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	
	local db = sqlite3.open(realDBPath);
	local row;
	for row in db:rows("select ID, gossiptext from npc_gossip") do
		if(row ~= nil) then
			local ID = tonumber(row.ID);
			local gossiptext = tostring(row.gossiptext);
			Quest_DB.GossipTexts[ID] = gossiptext;
		end
	end
	
	db:close();
end
-- automatically call Quest_DB.GetAllGossip()
Quest_DB.GetAllGossip()

function Quest_DB.GetAllQuests()
	
	Quest_DB.Quests = {};
	
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Quest_DB.QuestDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	
	local db = sqlite3.open(realDBPath);
	local row;
	for row in db:rows("select entry, Method, PrevQuestId, NextQuestId, NextQuestInChain, Title, Details, Objectives, OfferRewardText, RequestItemsText, EndText, ObjectiveText1, ObjectiveText2, ObjectiveText3, ObjectiveText4, CReqGoalId1, CReqGoalId2, CReqGoalId3, CReqGoalId4, CReqCount1, CReqCount2, CReqCount3, CReqCount4, RewItemId1, RewItemId2, RewItemId3, RewItemId4, RewItemCount1, RewItemCount2, RewItemCount3, RewItemCount4, RewOrReqMoney from quest_template") do
		if(row ~= nil) then
			local quest = commonlib.deepcopy(row);
			Quest_DB.Quests[tonumber(row.entry)] = quest;
		end
	end
	
	db:close();
end
-- automatically get all Quests
Quest_DB.GetAllQuests()

function Quest_DB.GetAllNPC_Quest_Start_Relations()
	
	Quest_DB.NPC_Quest_Start_Relations = {};
	
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Quest_DB.QuestDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	
	local db = sqlite3.open(realDBPath);
	local row;
	for row in db:rows("select id, quest from npc_quest_start_relation") do
		if(row ~= nil) then
			-- currently we only allow one quest given by one NPC, but one NPC can start multiple quests
			local relation = commonlib.deepcopy(row);
			Quest_DB.NPC_Quest_Start_Relations[row.quest] = relation;
		end
	end
	
	db:close();
end
-- automatically get all NPC_Quest_Start_Relations
Quest_DB.GetAllNPC_Quest_Start_Relations()

function Quest_DB.GetAllNPC_Quest_Finish_Relations()
	
	Quest_DB.NPC_Quest_Finish_Relations = {};
	
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Quest_DB.QuestDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	
	local db = sqlite3.open(realDBPath);
	local row;
	for row in db:rows("select id, quest from npc_quest_finish_relation") do
		if(row ~= nil) then
			-- currently we only allow one quest finished by one NPC, but one NPC can finish multiple quests
			local relation = commonlib.deepcopy(row);
			Quest_DB.NPC_Quest_Finish_Relations[row.quest] = relation;
		end
	end
	
	db:close();
end
-- automatically get all NPC_Quest_Finish_Relations
Quest_DB.GetAllNPC_Quest_Finish_Relations()

function Quest_DB.GetAllCReq_Goals()
	
	Quest_DB.CReq_Goals = {};
	
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Quest_DB.QuestDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	
	local db = sqlite3.open(realDBPath);
	local row;
	for row in db:rows("select id, app_key, commandname, questiondata, answerdata from creq_goals") do
		if(row ~= nil) then
			local goal = commonlib.deepcopy(row);
			Quest_DB.CReq_Goals[tonumber(row.id)] = goal;
		end
	end
	
	db:close();
end
-- automatically get all quest CReq_Goals
Quest_DB.GetAllCReq_Goals();

function Quest_DB.GetAllCharacter_QuestStatus()
	
	Quest_DB.AllQuestStatus = {};
	
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Quest_DB.QuestStatusDBFile;
	
	local db;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		-- create a new database, if not exists
		db = sqlite3.open(realDBPath);
		if( db ~= nil)then
			db:exec([[
DROP TABLE IF EXISTS `character_queststatus`;
CREATE TABLE [character_queststatus](
	[guid] INTEGER UNIQUE PRIMARY KEY NOT NULL,
	[quest] INTEGER NOT NULL,
	[status] INTEGER NOT NULL DEFAULT ((0)),
	[rewarded] INTEGER NOT NULL DEFAULT ((0)),
	[explored] INTEGER NOT NULL DEFAULT ((0)),
	[timer] INTEGER NOT NULL DEFAULT ((0)),
	[mobcount1] INTEGER NOT NULL DEFAULT ((0)),
	[mobcount2] INTEGER NOT NULL DEFAULT ((0)),
	[mobcount3] INTEGER NOT NULL DEFAULT ((0)),
	[mobcount4] INTEGER NOT NULL DEFAULT ((0)),
	[itemcount1] INTEGER NOT NULL DEFAULT ((0)),
	[itemcount2] INTEGER NOT NULL DEFAULT ((0)),
	[itemcount3] INTEGER NOT NULL DEFAULT ((0)),
	[itemcount4] INTEGER NOT NULL DEFAULT ((0)),
	[creqcount1] INTEGER NOT NULL DEFAULT ((0)),
	[creqcount2] INTEGER NOT NULL DEFAULT ((0)),
	[creqcount3] INTEGER NOT NULL DEFAULT ((0)),
	[creqcount4] INTEGER NOT NULL DEFAULT ((0))
);
			]]);
			Quest_DB.UpdateAllQuestStatusFromEmpty(db);
		end
	else
		db = sqlite3.open(realDBPath);
	end
	
	local row;
	for row in db:rows("select guid, quest, status, rewarded, explored, creqcount1, creqcount2, creqcount3, creqcount4 from character_queststatus") do
		if(row ~= nil) then
			local status = commonlib.deepcopy(row);
			Quest_DB.AllQuestStatus[tonumber(row.guid)] = status;
		end
	end
	
	db:close();
end
-- automatically get all quest status
Quest_DB.GetAllCharacter_QuestStatus()


--0  QUEST_STATUS_NONE  Quest isn't shown in quest list; default  
--1  QUEST_STATUS_COMPLETE  Quest has been completed  
--2  QUEST_STATUS_UNAVAILABLE  Quest is unavailable to the character  
--3  QUEST_STATUS_INCOMPLETE  Quest is active in quest log but incomplete  
--4  QUEST_STATUS_AVAILABLE  Quest is available to be taken by character  

-- update all the quest status from empty database
function Quest_DB.UpdateAllQuestStatusFromEmpty(db)
	local i, quest;
	for i, quest in pairs(Quest_DB.Quests) do
		if(quest.PrevQuestId == 0) then
			-- QUEST_STATUS_AVAILABLE
			db:exec(string.format("insert into character_queststatus (guid, quest, status) values (%d, %d, %d)", 
				quest.entry, quest.entry, 4));
		elseif(quest.PrevQuestId > 0) then
			-- QUEST_STATUS_UNAVAILABLE
			db:exec(string.format("insert into character_queststatus (guid, quest, status) values (%d, %d, %d)", 
				quest.entry, quest.entry, 2));
		end
		--quest.PrevQuestId
		--quest.NextQuestId
		--quest.ExclusiveGroup
		--quest.NextQuestInChain
	end
end

-- update the quest status in Quest_DB.AllQuestStatus table and database
function Quest_DB.UpdateQuestStatus(quest_id, status, rewarded)
	
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Quest_DB.QuestStatusDBFile;
	
	if(ParaIO.DoesFileExist(realDBPath, true)) then
		local db;
		db = sqlite3.open(realDBPath);
		if(rewarded == true) then
			db:exec(string.format("UPDATE character_queststatus SET status = %d, rewarded = 1 WHERE quest=%d;", 
				status, quest_id));
			Quest_DB.AllQuestStatus[quest_id].status = status;
			Quest_DB.AllQuestStatus[quest_id].rewarded = 1; -- true
		else
			db:exec(string.format("UPDATE character_queststatus SET status = %d, rewarded = 0 WHERE quest=%d;", 
				status, quest_id));
			Quest_DB.AllQuestStatus[quest_id].status = status;
			Quest_DB.AllQuestStatus[quest_id].rewarded = 0; -- false
		end
		
		if(Quest_DB.AllQuestStatus[quest_id].status == 1 -- QUEST_STATUS_COMPLETE
			and Quest_DB.AllQuestStatus[quest_id].rewarded == 1) then
			if(Quest_DB.Quests[quest_id].NextQuestInChain > 0) then
				db:exec(string.format("UPDATE character_queststatus SET status = %d, rewarded = 0 WHERE quest=%d;", 
					4, Quest_DB.Quests[quest_id].NextQuestInChain));
				Quest_DB.AllQuestStatus[Quest_DB.Quests[quest_id].NextQuestInChain].status = 4;
				Quest_DB.AllQuestStatus[Quest_DB.Quests[quest_id].NextQuestInChain].rewarded = 0; -- false
			end
		end
		
		db:close();
	end	
end

-- update the quest status counts in Quest_DB.AllQuestStatus table and database
function Quest_DB.UpdateQuestStatusCounts(quest_id, count1, count2, count3, count4)
	
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Quest_DB.QuestStatusDBFile;
	
	if(ParaIO.DoesFileExist(realDBPath, true)) then
		local db;
		db = sqlite3.open(realDBPath);
		if(type(count1) == "number") then
			db:exec(string.format("UPDATE character_queststatus SET creqcount1 = %d WHERE quest=%d;", 
				count1, quest_id));
			Quest_DB.AllQuestStatus[quest_id].creqcount1 = count1;
		elseif(type(count2) == "number") then
			db:exec(string.format("UPDATE character_queststatus SET creqcount2 = %d WHERE quest=%d;", 
				count2, quest_id));
			Quest_DB.AllQuestStatus[quest_id].creqcount2 = count2;
		elseif(type(count3) == "number") then
			db:exec(string.format("UPDATE character_queststatus SET creqcount3 = %d WHERE quest=%d;", 
				count3, quest_id));
			Quest_DB.AllQuestStatus[quest_id].creqcount3 = count3;
		elseif(type(count4) == "number") then
			db:exec(string.format("UPDATE character_queststatus SET creqcount4 = %d WHERE quest=%d;", 
				count4, quest_id));
			Quest_DB.AllQuestStatus[quest_id].creqcount4 = count4;
		end
		db:close();
	end	
end






