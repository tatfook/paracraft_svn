--[[
Title: Quest_NPCForm_Page
Author(s): Leio
Date: 2008/12/22
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_NPCForm_Page.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_DB.lua");
local Quest_NPCForm_Page = {
	state = nil, -- "new" or "edit"
}
commonlib.setfield("Map3DSystem.Quest.Quest_NPCForm_Page",Quest_NPCForm_Page);
function Quest_NPCForm_Page.OnInit()
	local self = Quest_NPCForm_Page;
	self.page = document:GetPageCtrl();
end
function Quest_NPCForm_Page.DataBind(data)
	local self = Quest_NPCForm_Page;
	if( not data) then return end;
	self.BindData = data;
	self.bindingContext = commonlib.BindingContext:new();	
	self.bindingContext:AddBinding(data, "Name", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "Name")
	self.bindingContext:AddBinding(data, "posX", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "posX")
	self.bindingContext:AddBinding(data, "posY", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "posY")
	self.bindingContext:AddBinding(data, "posZ", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "posZ")	
	self.bindingContext:UpdateDataToControls();
end
function Quest_NPCForm_Page.OnSave(name, values)
	local self = Quest_NPCForm_Page;
	if(Quest_NPCForm_Page.state == "new")then
		Map3DSystem.Quest.Quest_Panel_DB.InsertNPC(values);
	else
		if(self.bindingContext and self.BindData)then
		self.bindingContext:UpdateControlsToData();
		Map3DSystem.Quest.Quest_Panel_DB.UpdateNPC(self.BindData)
		end
	end
	Quest_NPCForm_Page.ClosePage();
end
function Quest_NPCForm_Page.OnCancel(name, values)
	Quest_NPCForm_Page.ClosePage();
end
function Quest_NPCForm_Page.ShowPage(state)
	Quest_NPCForm_Page.state = state;
	local title;
	if( state == "new")then
		title = "新增NPC";
	else
		title = "编辑NPC";
	end
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url=System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemQuest/forms/Quest_NPCForm_Page.html", {cmdredirect=cmdredirect}), 
			name="Quest_NPCForm_Page", 
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
function Quest_NPCForm_Page.ClosePage()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="Quest_NPCForm_Page", 
		app_key=MyCompany.Aquarius.app.app_key, 
		bShow = false,bDestroy = true,});
end