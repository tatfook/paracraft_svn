--[[
Title: Quest_FinishRelationForm_Page
Author(s): Leio
Date: 2008/12/23
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_FinishRelationForm_Page.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_DB.lua");
local Quest_FinishRelationForm_Page = {
	state = nil, -- "new" or "edit"
}
commonlib.setfield("Map3DSystem.Quest.Quest_FinishRelationForm_Page",Quest_FinishRelationForm_Page);
function Quest_FinishRelationForm_Page.OnInit()
	local self = Quest_FinishRelationForm_Page;
	self.page = document:GetPageCtrl();
end
function Quest_FinishRelationForm_Page.DataBind(data)
	local self = Quest_FinishRelationForm_Page;
	if( not data) then return end;
	self.BindData = data;
	self.bindingContext = commonlib.BindingContext:new();	
	self.bindingContext:AddBinding(data, "id", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "id")
	self.bindingContext:AddBinding(data, "quest", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "quest")
	self.bindingContext:UpdateDataToControls();
end
function Quest_FinishRelationForm_Page.OnSave(name, values)
	local self = Quest_FinishRelationForm_Page;
	if(Quest_FinishRelationForm_Page.state == "new")then
		Map3DSystem.Quest.Quest_Panel_DB.InsertFinishRelation(values);
	else
		if(self.bindingContext and self.BindData)then
		self.bindingContext:UpdateControlsToData();
		Map3DSystem.Quest.Quest_Panel_DB.UpdateFinishRelation(self.BindData)
		end
	end
	Quest_FinishRelationForm_Page.ClosePage();
end
function Quest_FinishRelationForm_Page.OnCancel(name, values)
	Quest_FinishRelationForm_Page.ClosePage();
end
function Quest_FinishRelationForm_Page.ShowPage(state)
	Quest_FinishRelationForm_Page.state = state;
	local title;
	if( state == "new")then
		title = "新增FinishRelation";
	else
		title = "编辑FinishRelation";
	end
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url=System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemQuest/forms/Quest_FinishRelationForm_Page.html", {cmdredirect=cmdredirect}), 
			name="Quest_FinishRelationForm_Page", 
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
function Quest_FinishRelationForm_Page.ClosePage()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="Quest_FinishRelationForm_Page", 
		app_key=MyCompany.Aquarius.app.app_key, 
		bShow = false,bDestroy = true,});
end