--[[
Title: Quest_GoalsForm_Page
Author(s): Leio
Date: 2008/12/22
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_GoalsForm_Page.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_DB.lua");
local Quest_GoalsForm_Page = {
	state = nil, -- "new" or "edit"
}
commonlib.setfield("Map3DSystem.Quest.Quest_GoalsForm_Page",Quest_GoalsForm_Page);
function Quest_GoalsForm_Page.OnInit()
	local self = Quest_GoalsForm_Page;
	self.page = document:GetPageCtrl();
end
function Quest_GoalsForm_Page.DataBind(data)
	local self = Quest_GoalsForm_Page;
	if( not data) then return end;
	self.BindData = data;
	self.bindingContext = commonlib.BindingContext:new();	
	self.bindingContext:AddBinding(data, "app_key", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "app_key")
	self.bindingContext:AddBinding(data, "commandname", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "commandname")
	self.bindingContext:AddBinding(data, "questiondata", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "questiondata")
	self.bindingContext:AddBinding(data, "answerdata", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "answerdata")	
	self.bindingContext:UpdateDataToControls();
end
function Quest_GoalsForm_Page.OnSave(name, values)
	local self = Quest_GoalsForm_Page;
	if(Quest_GoalsForm_Page.state == "new")then
		Map3DSystem.Quest.Quest_Panel_DB.InsertGoals(values);
	else
		if(self.bindingContext and self.BindData)then
		self.bindingContext:UpdateControlsToData();
		Map3DSystem.Quest.Quest_Panel_DB.UpdateGoals(self.BindData)
		end
	end
	Quest_GoalsForm_Page.ClosePage();
end
function Quest_GoalsForm_Page.OnCancel(name, values)
	Quest_GoalsForm_Page.ClosePage();
end
function Quest_GoalsForm_Page.ShowPage(state)
	Quest_GoalsForm_Page.state = state;
	local title;
	if( state == "new")then
		title = "新增问答";
	else
		title = "编辑问答";
	end
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url=System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemQuest/forms/Quest_GoalsForm_Page.html", {cmdredirect=cmdredirect}), 
			name="Quest_GoalsForm_Page", 
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
function Quest_GoalsForm_Page.ClosePage()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="Quest_GoalsForm_Page", 
		app_key=MyCompany.Aquarius.app.app_key, 
		bShow = false,bDestroy = true,});
end