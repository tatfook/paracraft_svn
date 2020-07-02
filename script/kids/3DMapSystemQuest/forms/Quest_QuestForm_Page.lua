--[[
Title: Quest_QuestForm_Page
Author(s): Leio
Date: 2008/12/22
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_QuestForm_Page.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_DB.lua");
local Quest_QuestForm_Page = {
	state = nil, -- "new" or "edit"
}
commonlib.setfield("Map3DSystem.Quest.Quest_QuestForm_Page",Quest_QuestForm_Page);
function Quest_QuestForm_Page.OnInit()
	local self = Quest_QuestForm_Page;
	self.page = document:GetPageCtrl();
end
function Quest_QuestForm_Page.DataBind(data)
	local self = Quest_QuestForm_Page;
	if( not data) then return end;
	self.BindData = data;
	self.bindingContext = commonlib.BindingContext:new();	
	self.bindingContext:AddBinding(data, "Method", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "Method")
	self.bindingContext:AddBinding(data, "PrevQuestId", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "PrevQuestId")
	self.bindingContext:AddBinding(data, "NextQuestId", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "NextQuestId")
	self.bindingContext:AddBinding(data, "NextQuestInChain", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "NextQuestInChain")	
	
	self.bindingContext:AddBinding(data, "Title", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "Title")
	self.bindingContext:AddBinding(data, "Details", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "Details")
	self.bindingContext:AddBinding(data, "Objectives", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "Objectives")
	self.bindingContext:AddBinding(data, "OfferRewardText", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "OfferRewardText")	
	self.bindingContext:AddBinding(data, "RequestItemsText", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "RequestItemsText")
	self.bindingContext:AddBinding(data, "EndText", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "EndText")
	
	self.bindingContext:AddBinding(data, "ObjectiveText1", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "ObjectiveText1")
	self.bindingContext:AddBinding(data, "ObjectiveText2", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "ObjectiveText2")
	self.bindingContext:AddBinding(data, "ObjectiveText3", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "ObjectiveText3")
	self.bindingContext:AddBinding(data, "ObjectiveText4", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "ObjectiveText4")
	
	self.bindingContext:AddBinding(data, "CReqGoalId1", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "CReqGoalId1")
	self.bindingContext:AddBinding(data, "CReqGoalId2", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "CReqGoalId2")
	self.bindingContext:AddBinding(data, "CReqGoalId3", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "CReqGoalId3")
	self.bindingContext:AddBinding(data, "CReqGoalId4", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "CReqGoalId4")
	
	self.bindingContext:AddBinding(data, "CReqCount1", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "CReqCount1")
	self.bindingContext:AddBinding(data, "CReqCount2", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "CReqCount2")
	self.bindingContext:AddBinding(data, "CReqCount3", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "CReqCount3")
	self.bindingContext:AddBinding(data, "CReqCount4", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "CReqCount4")
	
	self.bindingContext:AddBinding(data, "RewItemId1", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "RewItemId1")
	self.bindingContext:AddBinding(data, "RewItemId2", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "RewItemId2")
	self.bindingContext:AddBinding(data, "RewItemId3", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "RewItemId3")
	self.bindingContext:AddBinding(data, "RewItemId4", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "RewItemId4")
	
	self.bindingContext:AddBinding(data, "RewItemCount1", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "RewItemCount1")
	self.bindingContext:AddBinding(data, "RewItemCount2", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "RewItemCount2")
	self.bindingContext:AddBinding(data, "RewItemCount3", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "RewItemCount3")
	self.bindingContext:AddBinding(data, "RewItemCount4", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "RewItemCount4")
	
	self.bindingContext:AddBinding(data, "RewOrReqMoney", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "RewOrReqMoney")
	self.bindingContext:UpdateDataToControls();
end
function Quest_QuestForm_Page.CanSave()
	local self = Quest_QuestForm_Page;
	if(not self.startRelationNPC or not self.finishRelationNPC)then
		_guihelper.MessageBox("请关联NPC！")
		return;
	end
	return true;
end
function Quest_QuestForm_Page.OnSave(name, values)
	local self = Quest_QuestForm_Page;
	if(self.CanSave())then
		if(Quest_QuestForm_Page.state == "new")then		
			local quest = Map3DSystem.Quest.Quest_Panel_DB.InsertQuestTemplate(values);
			if(quest)then
				local data = {};
				data["id"] = self.startRelationNPC["ID"];
				data["quest"] = quest["entry"];
				Map3DSystem.Quest.Quest_Panel_DB.InsertStartRelation(data)
				
				data = {};
				data["id"] = self.finishRelationNPC["ID"];
				data["quest"] = quest["entry"];
				Map3DSystem.Quest.Quest_Panel_DB.InsertFinishRelation(data)
			end
		else
			if(self.bindingContext and self.BindData)then
				self.bindingContext:UpdateControlsToData();
				Map3DSystem.Quest.Quest_Panel_DB.UpdateQuestTemplate(self.BindData)
				
				local quest = self.BindData;
				if(quest)then
					local data = {};
					data["id"] = self.startRelationNPC["ID"];
					data["quest"] = quest["entry"];
					Map3DSystem.Quest.Quest_Panel_DB.UpdateStartRelation(data)
					
					data = {};
					data["id"] = self.finishRelationNPC["ID"];
					data["quest"] = quest["entry"];
					Map3DSystem.Quest.Quest_Panel_DB.UpdateFinishRelation(data)
				end
			end
		end
		Quest_QuestForm_Page.ClosePage();
	end
end
function Quest_QuestForm_Page.OnCancel(name, values)
	Quest_QuestForm_Page.ClosePage();
end
function Quest_QuestForm_Page.ShowPage(state)
	Quest_QuestForm_Page.state = state;
	local title;
	if( state == "new")then
		title = "新增任务";
	else
		title = "编辑任务";
	end
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url=System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemQuest/forms/Quest_QuestForm_Page.html", {cmdredirect=cmdredirect}), 
			name="Quest_QuestForm_Page", 
			app_key=MyCompany.Aquarius.app.app_key, 
			text = title,
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
function Quest_QuestForm_Page.ClosePage()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="Quest_QuestForm_Page", 
		app_key=MyCompany.Aquarius.app.app_key, 
		bShow = false,bDestroy = true,});
end
function Quest_QuestForm_Page.NPCRelation()
	local self = Quest_QuestForm_Page;
	self.startRelationNPC = nil;
	self.finishRelationNPC = nil;
	if(Quest_QuestForm_Page.state == "edit")then
		local quest = self.BindData		
		local entry = quest["entry"];
		
		local start_relation = Map3DSystem.Quest.DB.NPC_Quest_Start_Relations[entry];
		if(start_relation)then
			self.startRelationNPC = Map3DSystem.Quest.DB.AllNPCs[start_relation.id];
		end
		
		local finish_relation = Map3DSystem.Quest.DB.NPC_Quest_Finish_Relations[entry];
		if(finish_relation)then
			self.finishRelationNPC = Map3DSystem.Quest.DB.AllNPCs[finish_relation.id];
		end
	end
	
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/NPCRelation_Page.lua");
	Map3DSystem.Quest.NPCRelation_Page.ShowPage()
	Map3DSystem.Quest.NPCRelation_Page.DataBind(self.startRelationNPC,self.finishRelationNPC)

end
function Quest_QuestForm_Page.SetStartRelation(npc)
	if(not npc)then return end
	local self = Quest_QuestForm_Page;
	self.startRelationNPC = npc;
end
function Quest_QuestForm_Page.SetFinishRelation(npc)
	if(not npc)then return end
	local self = Quest_QuestForm_Page;
	self.finishRelationNPC = npc;
end