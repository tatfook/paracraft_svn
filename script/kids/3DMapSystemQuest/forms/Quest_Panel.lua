--[[
Title: Quest_Panel
Author(s): Leio
Date: 2008/12/22
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_Panel.lua");
Map3DSystem.Quest.Quest_Panel.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_DB.lua");
NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_Panel_DB.lua");
local Quest_Panel = {
	AllNPCs = nil,
}
commonlib.setfield("Map3DSystem.Quest.Quest_Panel",Quest_Panel);
function Quest_Panel.OnInit()
	Quest_Panel.OnRefreshNPC();
	Quest_Panel.OnRefreshQuest();
	Quest_Panel.OnRefreshGoals();
	Quest_Panel.OnRefreshStartRelation();
	Quest_Panel.OnRefreshFinishRelation();
	Quest_Panel.OnRefreshGossip();
	Quest_Panel.OnRefreshValidQuestChains();
	
end
function Quest_Panel.SortList(data,flag)
	if(not data)then return end;
	local k,v;
	local list = {};
	for k,v in ipairs(data) do
		local index = tonumber(v[flag]);
		if(index)then
			table.insert(list,{index = index, value = v});
		end
	end
	table.sort(list, CommonCtrl.TreeNode.GenerateLessCFByField("index"));
	local result = {};
	for k,v in ipairs(list) do
		table.insert(result,v["value"]);
	end
	return result;
end
function Quest_Panel.SortList_2(data,flag)
	if(not data)then return end;
	local k,v;
	local list = {};
	for k,v in pairs(data) do
		local index = tonumber(v[flag]);	
		if(index)then
			table.insert(list,{index = index, value = v});
		end
	end
	table.sort(list, CommonCtrl.TreeNode.GenerateLessCFByField("index"));
	local result = {};
	for k,v in ipairs(list) do
		table.insert(result,v["value"]);
	end
	return result;
end
function Quest_Panel.SortList_3(data,flag)
	if(not data)then return end;
	local k,v;
	local list = {};
	for k,v in pairs(data) do
		local index = tonumber(v[flag]);
		if(index)then
			table.insert(list,{index = index, value = v});
		end
	end
	for k,v in ipairs(data) do
		local index = tonumber(v[flag]);
		if(index)then
			table.insert(list,{index = index, value = v});
		end
	end
	table.sort(list, CommonCtrl.TreeNode.GenerateLessCFByField("index"));
	local result = {};
	for k,v in ipairs(list) do
		table.insert(result,v["value"]);
	end
	return result;
end
------------------------------------------------------------------------------------
-- NPC
------------------------------------------------------------------------------------
function Quest_Panel.NPC_DS_Func(index)
	if(index == nil) then
		return #(Quest_Panel.AllNPCs);
	else
		return Quest_Panel.AllNPCs[index];
	end
end
function Quest_Panel.OnMoveToNPC(id)
	if(not id)then return end
	local data = Map3DSystem.Quest.DB.AllNPCs[id];
	if(not data)then return end;
	local x = tonumber(data.posX)
	local z = tonumber(data.posZ)
	if(x and z) then
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x=x, z=z});
	end
end
function Quest_Panel.OnNewNPC()
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_NPCForm_Page.lua");
	Map3DSystem.Quest.Quest_NPCForm_Page.ShowPage("new");
end
function Quest_Panel.OnRefreshNPC()
	local self = Quest_Panel;
	Map3DSystem.Quest.DB.GetAllNPCs()
	local AllNPCs = Map3DSystem.Quest.DB.AllNPCs;
	
	--local temp = {};
	--local k,v;
	--for k,v in pairs(AllNPCs) do
		--table.insert(temp,v);
	--end
	local result = Quest_Panel.SortList_2(AllNPCs,"ID")
	self.AllNPCs = result;
end
function Quest_Panel.OnEditNPC(id)
	if(not id)then return end
	local data = Map3DSystem.Quest.DB.AllNPCs[id];
	if(not data)then return end;
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_NPCForm_Page.lua");
	Map3DSystem.Quest.Quest_NPCForm_Page.ShowPage("edit");
	Map3DSystem.Quest.Quest_NPCForm_Page.DataBind(data);
end
function Quest_Panel.OnDeleteNPC(id)
	_guihelper.MessageBox(string.format("你确定要删除:%s?", id), function()
					Map3DSystem.Quest.Quest_Panel_DB.DeleteNPC(id)
				end)
end
------------------------------------------------------------------------------------
-- Quest template
------------------------------------------------------------------------------------
function Quest_Panel.Quest_DS_Func(index)
	if(index == nil) then
		return #(Quest_Panel.Quests);
	else
		return Quest_Panel.Quests[index];
	end
end

function Quest_Panel.OnNewQuest()
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_QuestForm_Page.lua");
	Map3DSystem.Quest.Quest_QuestForm_Page.ShowPage("new");
end
function Quest_Panel.OnRefreshQuest()
	local self = Quest_Panel;
	Map3DSystem.Quest.DB.GetAllQuests()
	local Quests = Map3DSystem.Quest.DB.Quests;
	--local temp = {};
	--local k,v;
	--for k,v in pairs(Quests) do
		--table.insert(temp,v);
	--end
	local result = Quest_Panel.SortList_2(Quests,"entry")
	self.Quests = result;
end
function Quest_Panel.OnEditQuest(id)
	if(not id)then return end
	local data = Map3DSystem.Quest.DB.Quests[id];
	if(not data)then return end;
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_QuestForm_Page.lua");
	Map3DSystem.Quest.Quest_QuestForm_Page.ShowPage("edit");
	Map3DSystem.Quest.Quest_QuestForm_Page.DataBind(data);
end
function Quest_Panel.OnDeleteQuest(id)
	local canDelete = Quest_Panel.CanDeleteQuest(id);
	if(not canDelete)then return end;
	_guihelper.MessageBox(string.format("你确定要删除:%s?", id), function()
					local quest = Map3DSystem.Quest.DB.Quests[id];
					Map3DSystem.Quest.Quest_Panel_DB.DeleteQuestTemplate(id)
					local startRelation = Map3DSystem.Quest.DB.NPC_Quest_Start_Relations[id];
					local finishRelation = Map3DSystem.Quest.DB.NPC_Quest_Finish_Relations[id];
					
					if(startRelation)then
						Map3DSystem.Quest.Quest_Panel_DB.DeleteStartRelation(startRelation["quest"]);
					end
					if(finishRelation)then
						Map3DSystem.Quest.Quest_Panel_DB.DeleteFinishRelation(finishRelation["quest"]);
					end
				end)
end
function Quest_Panel.CanDeleteQuest(id)
	local quest = Map3DSystem.Quest.DB.Quests[id]
	if(not quest)then return end
	local PrevQuestId  = quest["PrevQuestId"];
		local NextQuestId  = quest["NextQuestId"];
		local NextQuestInChain  = quest["NextQuestInChain"];
		PrevQuestId = tonumber(PrevQuestId);
		NextQuestId = tonumber(NextQuestId);
		NextQuestInChain = tonumber(NextQuestInChain);
		-- it is a unvalid quest,so can be chained
		if(PrevQuestId == 0 and NextQuestId == 0 and NextQuestInChain == 0)then
			return true;
		else
			--_guihelper.MessageBox(string.format("任务:%s存在于链中，暂时不能删除！", id))
			return true;
		end
end
------------------------------------------------------------------------------------
-- Goals
------------------------------------------------------------------------------------
function Quest_Panel.Goals_DS_Func(index)
	if(index == nil) then
		return #(Quest_Panel.CReq_Goals);
	else
		return Quest_Panel.CReq_Goals[index];
	end
end
function Quest_Panel.OnNewGoals()
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_GoalsForm_Page.lua");
	Map3DSystem.Quest.Quest_GoalsForm_Page.ShowPage("new");
end
function Quest_Panel.OnRefreshGoals()
	local self = Quest_Panel;
	Map3DSystem.Quest.DB.GetAllCReq_Goals()
	local CReq_Goals = Map3DSystem.Quest.DB.CReq_Goals;
	
	--local temp = {};
	--local k,v;
	--for k,v in pairs(CReq_Goals) do
		--table.insert(temp,v);
	--end
	local result = Quest_Panel.SortList_2(CReq_Goals,"id")
	self.CReq_Goals = result;
end
function Quest_Panel.OnEditGoals(id)
	if(not id)then return end
	local data = Map3DSystem.Quest.DB.CReq_Goals[id];
	if(not data)then return end;
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_GoalsForm_Page.lua");
	Map3DSystem.Quest.Quest_GoalsForm_Page.ShowPage("edit");
	Map3DSystem.Quest.Quest_GoalsForm_Page.DataBind(data);
end
function Quest_Panel.OnDeleteGoals(id)
	_guihelper.MessageBox(string.format("你确定要删除:%s?", id), function()
					Map3DSystem.Quest.Quest_Panel_DB.DeleteGoals(id)
				end)
end
------------------------------------------------------------------------------------
-- npc_quest_start_relation
------------------------------------------------------------------------------------
function Quest_Panel.StartRelation_DS_Func(index)
	if(index == nil) then
		return #(Quest_Panel.NPC_Quest_Start_Relations);
	else
		return Quest_Panel.NPC_Quest_Start_Relations[index];
	end
end

function Quest_Panel.OnNewStartRelation()
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_StartRelationForm_Page.lua");
	Map3DSystem.Quest.Quest_StartRelationForm_Page.ShowPage("new");
end
function Quest_Panel.OnRefreshStartRelation()
	local self = Quest_Panel;
	Map3DSystem.Quest.DB.GetAllNPC_Quest_Start_Relations()
	local NPC_Quest_Start_Relations = Map3DSystem.Quest.DB.NPC_Quest_Start_Relations;
	
	--local temp = {};
	--local k,v;
	--for k,v in pairs(NPC_Quest_Start_Relations) do
		--table.insert(temp,v);
	--end
	local result = Quest_Panel.SortList_2(NPC_Quest_Start_Relations,"id")
	self.NPC_Quest_Start_Relations = result;
end
function Quest_Panel.OnEditStartRelation(id)
	if(not id)then return end
	local data = Map3DSystem.Quest.DB.NPC_Quest_Start_Relations[id];
	if(not data)then return end;
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_StartRelationForm_Page.lua");
	Map3DSystem.Quest.Quest_StartRelationForm_Page.ShowPage("edit");
	Map3DSystem.Quest.Quest_StartRelationForm_Page.DataBind(data);
end
function Quest_Panel.OnDeleteStartRelation(id)
	_guihelper.MessageBox(string.format("你确定要删除:%s?", id), function()
					Map3DSystem.Quest.Quest_Panel_DB.DeleteStartRelation(id)
				end)
end
------------------------------------------------------------------------------------
-- npc_quest_finish_relation
------------------------------------------------------------------------------------
function Quest_Panel.FinishRelation_DS_Func(index)
	if(index == nil) then
		return #(Quest_Panel.NPC_Quest_Finish_Relations);
	else
		return Quest_Panel.NPC_Quest_Finish_Relations[index];
	end
end

function Quest_Panel.OnNewFinishRelation()
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_FinishRelationForm_Page.lua");
	Map3DSystem.Quest.Quest_FinishRelationForm_Page.ShowPage("new");
end
function Quest_Panel.OnRefreshFinishRelation()
	local self = Quest_Panel;
	Map3DSystem.Quest.DB.GetAllNPC_Quest_Finish_Relations()
	local NPC_Quest_Finish_Relations = Map3DSystem.Quest.DB.NPC_Quest_Finish_Relations;
	
	--local temp = {};
	--local k,v;
	--for k,v in pairs(NPC_Quest_Finish_Relations) do
		--table.insert(temp,v);
	--end
	local result = Quest_Panel.SortList_2(NPC_Quest_Finish_Relations,"id")
	self.NPC_Quest_Finish_Relations = result;
end
function Quest_Panel.OnEditFinishRelation(id)
	if(not id)then return end
	local data = Map3DSystem.Quest.DB.NPC_Quest_Finish_Relations[id];
	if(not data)then return end;
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_FinishRelationForm_Page.lua");
	Map3DSystem.Quest.Quest_FinishRelationForm_Page.ShowPage("edit");
	Map3DSystem.Quest.Quest_FinishRelationForm_Page.DataBind(data);
end
function Quest_Panel.OnDeleteFinishRelation(id)
	_guihelper.MessageBox(string.format("你确定要删除:%s?", id), function()
					Map3DSystem.Quest.Quest_Panel_DB.DeleteFinishRelation(id)
				end)
end
------------------------------------------------------------------------------------
-- npc_gossip
------------------------------------------------------------------------------------
function Quest_Panel.Gossip_DS_Func(index)
	if(index == nil) then
		return #(Quest_Panel.GossipTexts);
	else
		return Quest_Panel.GossipTexts[index];
	end
end

function Quest_Panel.OnNewGossip()
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_GossipForm_Page.lua");
	Map3DSystem.Quest.Quest_GossipForm_Page.ShowPage("new");
end
function Quest_Panel.OnRefreshGossip()
	local self = Quest_Panel;
	Map3DSystem.Quest.DB.GetAllGossip()
	local GossipTexts = Map3DSystem.Quest.DB.GossipTexts;
	
	local temp = {};
	local k,v;
	for k,v in pairs(GossipTexts) do
		local data = {ID = k, gossiptext = v};
		table.insert(temp,data);
	end
	local result = Quest_Panel.SortList(temp,"ID")
	self.GossipTexts = result;
end
function Quest_Panel.OnEditGossip(id)
	if(not id)then return end
	local data = Map3DSystem.Quest.DB.GossipTexts[id];
	if(not data)then return end;
	data = {ID = id, gossiptext = data};
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_GossipForm_Page.lua");
	Map3DSystem.Quest.Quest_GossipForm_Page.ShowPage("edit");
	Map3DSystem.Quest.Quest_GossipForm_Page.DataBind(data);
end
function Quest_Panel.OnDeleteGossip(id)
	_guihelper.MessageBox(string.format("你确定要删除:%s?", id), function()
					Map3DSystem.Quest.Quest_Panel_DB.DeleteGossip(id)
				end)
end
------------------------------------------------------------------------------------
-- valid quest chains
------------------------------------------------------------------------------------
function Quest_Panel.ValidQuestChains_DS_Func(index)
	if(index == nil) then
		return #(Quest_Panel.ValidQuestChains);
	else
		return Quest_Panel.ValidQuestChains[index];
	end
end
function Quest_Panel.UnValidQuestChains_DS_Func(index)
	if(index == nil) then
		return #(Quest_Panel.UnValidQuestChains);
	else
		return Quest_Panel.UnValidQuestChains[index];
	end
end
function Quest_Panel.OnNewValidQuestChains()
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_ChainEdit_Page.lua");
	Map3DSystem.Quest.Quest_ChainEdit_Page.ShowPage("new");
end
function Quest_Panel.OnRefreshValidQuestChains()
	local self = Quest_Panel;
	local ValidQuestChains,UnValidQuestChains = Map3DSystem.Quest.Quest_Panel_DB.FindValidQuests()
	local temp = {};
	local temp_mapping = {};
	local k,questChain;
	for k,questChain in ipairs(ValidQuestChains) do
		local firstQuestChain = questChain[1];
		local firstQuest = firstQuestChain["quest"]
		local ID = firstQuest["entry"]
		local data = {ID = ID, questChain = questChain};
		table.insert(temp,data);
		temp_mapping[ID] = questChain;
	end
	local result = Quest_Panel.SortList(temp,"ID")
	self.ValidQuestChains = result;
	self.ValidQuestChains_mapping = temp_mapping;
	
	result = Quest_Panel.SortList(UnValidQuestChains,"entry")
	self.UnValidQuestChains = result;
end
function Quest_Panel.OnEditValidQuestChains(id)
	if(not id)then return end
	local questChain = Quest_Panel.ValidQuestChains_mapping[id];
	if(not questChain)then return end;
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_ChainEdit_Page.lua");
	Map3DSystem.Quest.Quest_ChainEdit_Page.ShowPage("edit");
	Map3DSystem.Quest.Quest_ChainEdit_Page.DataBind(questChain);
end
function Quest_Panel.OnDeleteValidQuestChains(id)
	_guihelper.MessageBox(string.format("你确定要删除任务链:%s?", id), function()
					
				end)
end
------------------------------------------------------------------------------------
function Quest_Panel.ShowPage()
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url=System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemQuest/forms/Quest_Panel.html", {cmdredirect=cmdredirect}), 
			name="Quest_Panel", 
			app_key=MyCompany.Aquarius.app.app_key, 
			text = "任务编辑器",
			icon = "Texture/3DMapSystem/common/png-0762.png",
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			isShowMinimizeBox = false,
			bToggleShowHide = false,
			DestroyOnClose = true,
			directPosition = true,
				align = "_lt",
				x = (screenWidth - 800)/2,
				y = (screenHeight - 600)/2,
				width = 800,
				height = 600,
				bAutoSize=false,
			zorder=3,
		});
end
function Quest_Panel.ClosePage()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="Quest_Panel", 
		app_key=MyCompany.Aquarius.app.app_key, 
		bShow = false,bDestroy = true,});
end