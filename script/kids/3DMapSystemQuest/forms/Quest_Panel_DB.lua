--[[
Title: Quest_Panel_DB
Author(s): Leio
Date: 2008/12/25
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_Panel_DB.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_DB.lua");
local Quest_Panel_DB = {
}
commonlib.setfield("Map3DSystem.Quest.Quest_Panel_DB",Quest_Panel_DB);
------------------------------------------------------------------------------------
-- NPC
------------------------------------------------------------------------------------
function Quest_Panel_DB.DefaultNPCValue(data)
	if(not data)then return end;
	data.Name = data.Name or "Î´ÖªµÄNPC";
	data.AssetName = data.AssetName or "character/v4/Can/can04/can04.x";
	data.IsGlobal = data.IsGlobal or 1;
	data.SnapToTerrain = data.SnapToTerrain or 0;
	data.Weight = data.Weight or 1.2;
	data.Radius = data.Radius or 0.35;
	data.Facing = data.Facing or 1;
	data.Scaling = data.Scaling or 1;
	data.posX = data.posX or 255;
	data.posY = data.posY or 0;
	data.posZ = data.posZ or 255;
	data.CustomAppearance = data.CustomAppearance or 0;
end
function Quest_Panel_DB.InsertNPC(data)
	if(not data)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestNPCDBFile;
	-- set default value
	Quest_Panel_DB.DefaultNPCValue(data)
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("insert into NPC (Name, AssetName, IsGlobal, SnapToTerrain, Weight, Radius, Facing, Scaling, posX, posY, posZ, CustomAppearance) values ('%s', '%s', %d, %d ,%d , %d, %d ,%d, %d, %d ,%d ,%d)",
							data.Name, data.AssetName, data.IsGlobal, data.SnapToTerrain, data.Weight, data.Radius, data.Facing, data.Scaling, data.posX, data.posY, data.posZ, data.CustomAppearance);

	db:exec(_s);
	db:close();
end
function Quest_Panel_DB.UpdateNPC(data)
	if(not data)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestNPCDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("UPDATE NPC SET Name = '%s' , posX = %d , posY = %d , posZ = %d WHERE ID=%d;",
					 data.Name, data.posX, data.posY, data.posZ ,data.ID);

	db:exec(_s);
	db:close();
end
function Quest_Panel_DB.DeleteNPC(id)
	if(not id)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestNPCDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("Delete From NPC WHERE ID=%d;", id);

	db:exec(_s);
	db:close();
end
------------------------------------------------------------------------------------
-- Quest_Template
------------------------------------------------------------------------------------
function Quest_Panel_DB.ResetQuest(quest)
	if(not quest)then return end
	quest["PrevQuestId"] = 0;
	quest["NextQuestId"] = 0;
	quest["NextQuestInChain"] = 0;
end
function Quest_Panel_DB.DefaultQuestTemplateValue(data)
	if(not data)then return end;
	data.Method = tonumber(data.Method) or 2;
	data.PrevQuestId = tonumber(data.PrevQuestId) or 0;
	data.NextQuestId = tonumber(data.NextQuestId) or 0;
	data.NextQuestInChain = tonumber(data.NextQuestInChain) or 0;
	
	data.Title = tostring(data.Title) or "";
	data.Details = tostring(data.Details) or "";
	data.Objectives = tostring(data.Objectives) or "";
	data.OfferRewardText = tostring(data.OfferRewardText) or "";
	data.RequestItemsText = tostring(data.RequestItemsText) or "";
	data.EndText = tostring(data.EndText) or "";
	
	data.ObjectiveText1 = tostring(data.ObjectiveText1) or "";
	data.ObjectiveText2 = tostring(data.ObjectiveText2) or "";
	data.ObjectiveText3 = tostring(data.ObjectiveText3) or "";
	data.ObjectiveText4 = tostring(data.ObjectiveText4) or "";
	
	data.CReqGoalId1 = tonumber(data.CReqGoalId1) or 0;
	data.CReqGoalId2 = tonumber(data.CReqGoalId2) or 0;
	data.CReqGoalId3 = tonumber(data.CReqGoalId3) or 0;
	data.CReqGoalId4 = tonumber(data.CReqGoalId4) or 0;
	
	data.CReqCount1 = tonumber(data.CReqCount1) or 0;
	data.CReqCount2 = tonumber(data.CReqCount2) or 0;
	data.CReqCount3 = tonumber(data.CReqCount3) or 0;
	data.CReqCount4 = tonumber(data.CReqCount4) or 0;
	
	data.RewItemId1 = tonumber(data.RewItemId1) or 0;
	data.RewItemId2 = tonumber(data.RewItemId2) or 0;
	data.RewItemId3 = tonumber(data.RewItemId3) or 0;
	data.RewItemId4 = tonumber(data.RewItemId4) or 0;
	
	data.RewItemCount1 = tonumber(data.RewItemCount1) or 0;
	data.RewItemCount2 = tonumber(data.RewItemCount2) or 0;
	data.RewItemCount3 = tonumber(data.RewItemCount3) or 0;
	data.RewItemCount4 = tonumber(data.RewItemCount4) or 0;
	
	data.RewOrReqMoney = tonumber(data.RewOrReqMoney) or 0;
	
end
function Quest_Panel_DB.InsertQuestTemplate(data)
	if(not data)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestDBFile;
	-- set default value
	Quest_Panel_DB.DefaultQuestTemplateValue(data)
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("insert into quest_template (Method, PrevQuestId, NextQuestId, NextQuestInChain, Title, Details, Objectives, OfferRewardText, RequestItemsText, EndText, ObjectiveText1, ObjectiveText2, ObjectiveText3, ObjectiveText4, CReqGoalId1, CReqGoalId2, CReqGoalId3, CReqGoalId4, CReqCount1, CReqCount2, CReqCount3, CReqCount4, RewItemId1, RewItemId2, RewItemId3, RewItemId4, RewItemCount1, RewItemCount2, RewItemCount3, RewItemCount4, RewOrReqMoney) values (%d, %d, %d, %d ,'%s' , '%s', '%s' ,'%s', '%s', '%s' ,'%s' ,'%s','%s','%s', %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)",
							data.Method, 
							data.PrevQuestId, data.NextQuestId, data.NextQuestInChain, 
							data.Title, data.Details, data.Objectives, data.OfferRewardText, data.RequestItemsText, data.EndText, 
							data.ObjectiveText1, data.ObjectiveText2, data.ObjectiveText3, data.ObjectiveText4, 
							data.CReqGoalId1, data.CReqGoalId2, data.CReqGoalId3, data.CReqGoalId4, 
							data.CReqCount1, data.CReqCount2, data.CReqCount3, data.CReqCount4, 
							
							data.RewItemId1, data.RewItemId2, data.RewItemId3, data.RewItemId4, 
							data.RewItemCount1, data.RewItemCount2, data.RewItemCount3, data.RewItemCount4, 
							
							data.RewOrReqMoney);

	db:exec(_s);
	local entry = db:last_insert_rowid();
	db:close();
	if(entry)then
		local new_quest = commonlib.deepcopy(data);
		new_quest["entry"] = entry;
		return new_quest;
	end
end
function Quest_Panel_DB.UpdateQuestTemplate(data)
	if(not data)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("UPDATE quest_template SET Method = %d, PrevQuestId = %d, NextQuestId = %d, NextQuestInChain = %d, Title = '%s', Details = '%s', Objectives = '%s', OfferRewardText = '%s', RequestItemsText = '%s', EndText = '%s', ObjectiveText1 = '%s', ObjectiveText2 = '%s', ObjectiveText3 = '%s', ObjectiveText4 = '%s', CReqGoalId1 = %d, CReqGoalId2 = %d, CReqGoalId3 = %d, CReqGoalId4 = %d, CReqCount1 = %d, CReqCount2 = %d, CReqCount3 = %d, CReqCount4 = %d, RewItemId1 = %d, RewItemId2 = %d, RewItemId3 = %d, RewItemId4 = %d,RewItemCount1 = %d, RewItemCount2 = %d, RewItemCount3 = %d, RewItemCount4 = %d, RewOrReqMoney = %d WHERE entry=%d;",
							data.Method, 
							data.PrevQuestId, data.NextQuestId, data.NextQuestInChain, 
							data.Title, data.Details, data.Objectives, data.OfferRewardText, data.RequestItemsText, data.EndText, 
							data.ObjectiveText1, data.ObjectiveText2, data.ObjectiveText3, data.ObjectiveText4, 
							data.CReqGoalId1, data.CReqGoalId2, data.CReqGoalId3, data.CReqGoalId4, 
							data.CReqCount1, data.CReqCount2, data.CReqCount3, data.CReqCount4, 
													
							data.RewItemId1, data.RewItemId2, data.RewItemId3, data.RewItemId4, 
							data.RewItemCount1, data.RewItemCount2, data.RewItemCount3, data.RewItemCount4, 
							
							data.RewOrReqMoney,
							data.entry);

	db:exec(_s);
	db:close();
end
function Quest_Panel_DB.DeleteQuestTemplate(id)
	if(not id)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("Delete From quest_template WHERE entry=%d;", id);

	db:exec(_s);
	db:close();
end

------------------------------------------------------------------------------------
-- Goals
------------------------------------------------------------------------------------
function Quest_Panel_DB.DefaultGoalsValue(data)
	if(not data)then return end;
	data.app_key = data.app_key or "";
	data.commandname = data.commandname or "";
	data.questiondata = data.questiondata or "";
	data.answerdata = data.answerdata or "";
end
function Quest_Panel_DB.InsertGoals(data)
	if(not data)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestDBFile;
	-- set default value
	Quest_Panel_DB.DefaultGoalsValue(data)
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("insert into creq_goals (app_key, commandname, questiondata, answerdata) values ('%s', '%s', '%s', '%s')",
							data.app_key, data.commandname, data.questiondata, data.answerdata);

	db:exec(_s);
	db:close();
end
function Quest_Panel_DB.UpdateGoals(data)
	if(not data)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("UPDATE creq_goals SET app_key = '%s' , commandname = '%s' ,questiondata = '%s' , answerdata = '%s' WHERE ID=%d;",
					 data.app_key, data.commandname, data.questiondata, data.answerdata ,data.id);

	db:exec(_s);
	db:close();
end
function Quest_Panel_DB.DeleteGoals(id)
	if(not id)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("Delete From creq_goals WHERE ID=%d;", id);

	db:exec(_s);
	db:close();
end
------------------------------------------------------------------------------------
-- npc_quest_start_relation
------------------------------------------------------------------------------------
function Quest_Panel_DB.DefaultStartRelation(data)
	if(not data)then return end;
	data.id = tonumber(data.id);
	data.quest = tonumber(data.quest);
end
function Quest_Panel_DB.InsertStartRelation(data)
	if(not data)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestDBFile;
	-- set default value
	Quest_Panel_DB.DefaultStartRelation(data)
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("insert into npc_quest_start_relation (id, quest) values (%d, %d)",
							data.id, data.quest);

	db:exec(_s);
	db:close();
end
function Quest_Panel_DB.UpdateStartRelation(data)
	if(not data)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("UPDATE npc_quest_start_relation SET id = %d , quest = %d  WHERE quest=%d;",
					 data.id, data.quest,data.quest);

	db:exec(_s);
	db:close();
end
function Quest_Panel_DB.DeleteStartRelation(quest)
	if(not quest)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("Delete From npc_quest_start_relation WHERE quest=%d;", quest);

	db:exec(_s);
	db:close();
end
------------------------------------------------------------------------------------
-- npc_quest_finish_relation
------------------------------------------------------------------------------------
function Quest_Panel_DB.DefaultFinishRelation(data)
	if(not data)then return end;
	data.id = tonumber(data.id);
	data.quest = tonumber(data.quest);
end
function Quest_Panel_DB.InsertFinishRelation(data)
	if(not data)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestDBFile;
	-- set default value
	Quest_Panel_DB.DefaultFinishRelation(data)
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("insert into npc_quest_finish_relation (id, quest) values (%d, %d)",
							data.id, data.quest);

	db:exec(_s);
	db:close();
end
function Quest_Panel_DB.UpdateFinishRelation(data)
	if(not data)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("UPDATE npc_quest_finish_relation SET id = %d , quest = %d  WHERE quest=%d;",
					 data.id, data.quest,data.quest);

	db:exec(_s);
	db:close();
end
function Quest_Panel_DB.DeleteFinishRelation(quest)
	if(not quest)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("Delete From npc_quest_finish_relation WHERE quest=%d;", quest);

	db:exec(_s);
	db:close();
end
------------------------------------------------------------------------------------
-- npc_gossip
------------------------------------------------------------------------------------
function Quest_Panel_DB.DefaultGossip(data)
	if(not data)then return end;
	data.id = tonumber(data.id);
	data.gossiptext = tostring(data.gossiptext) or "";
end
function Quest_Panel_DB.InsertGossip(data)
	if(not data)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestNPCDBFile;
	-- set default value
	Quest_Panel_DB.DefaultGossip(data)
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("insert into npc_gossip (ID, gossiptext) values (%d, '%s')",
							data.ID, data.gossiptext);

	db:exec(_s);
	db:close();
end
function Quest_Panel_DB.UpdateGossip(data)
	if(not data)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestNPCDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("UPDATE npc_gossip SET ID = %d , gossiptext = '%s'  WHERE ID=%d;", -- ID is NPC's ID
					 data.ID, data.gossiptext,data.ID);

	db:exec(_s);
	db:close();
end
function Quest_Panel_DB.DeleteGossip(id)
	if(not id)then return end;
	local worldpath = ParaWorld.GetWorldDirectory();
	local realDBPath = worldpath..Map3DSystem.Quest.DB.QuestNPCDBFile;
	
	if(not ParaIO.DoesFileExist(realDBPath, true)) then
		return;
	end
	local db = sqlite3.open(realDBPath);
	local _s = string.format("Delete From npc_gossip WHERE ID=%d;", id); -- ID is NPC's ID

	db:exec(_s);
	db:close();
end
------------------------------------------------------------------------------------
-- single quest chain
------------------------------------------------------------------------------------
function Quest_Panel_DB.UpdateASingleQuestChain(questChain)
	if(not questChain)then return end
	local k,v;
	for k,v in ipairs(questChain) do
		local quest = v["quest"];	
		Quest_Panel_DB.UpdateQuestTemplate(quest);	
	end
	return true;
end
------------------------------------------------------------------------------------
-- find all of valid quest chains
-- a valid quest must contains both a start relation npc and a finish relation npc
------------------------------------------------------------------------------------
function Quest_Panel_DB.FindValidQuests()
	Map3DSystem.Quest.DB.GetAllQuests(); -- update db
	local allQuests =  Map3DSystem.Quest.DB.Quests;-- from Map3DSystem.Quest.DB
	local validQuests = {};
	local unValidQuests = {};
	local k,quest
	for k,quest in pairs(allQuests) do
		local PrevQuestId  = quest["PrevQuestId"];
		local NextQuestId  = quest["NextQuestId"];
		local NextQuestInChain  = quest["NextQuestInChain"];
		PrevQuestId = tonumber(PrevQuestId);
		NextQuestId = tonumber(NextQuestId);
		NextQuestInChain = tonumber(NextQuestInChain);
		-- it is a unvalid quest,so can be chained
		if(PrevQuestId == 0 and NextQuestId == 0 and NextQuestInChain == 0)then
			table.insert(unValidQuests,quest);	
		else
			local isFirst = false;
			if(PrevQuestId == 0 and NextQuestId == 0 and NextQuestInChain ~= 0)then
				isFirst = true;
			end
			table.insert(validQuests,{quest = quest, isFirst = isFirst});
		end
		
	end
	local result = {};
	local k,v
	for k,v in ipairs(validQuests) do
		local quest = v["quest"];
		local isFirst = v["isFirst"];
		if(isFirst)then
			local data = {};		
			table.insert(data,v);
			Quest_Panel_DB.ConstructChain(validQuests,quest,data)
			
			table.insert(result,data);
		end
	end
	return result,unValidQuests;
end
function Quest_Panel_DB.ConstructChain(validQuests,preQuest,data)
	if(not validQuests or not preQuest or not data)then return end
	local pre_id = preQuest["entry"];
	local k,v
	for k,v in ipairs(validQuests) do
		local quest = v["quest"];
		local PrevQuestId = quest["PrevQuestId"];
		PrevQuestId = tonumber(PrevQuestId);	
		if(pre_id == PrevQuestId)then		
			table.insert(data,v);
			Quest_Panel_DB.ConstructChain(validQuests,quest,data)
		end
	end
end