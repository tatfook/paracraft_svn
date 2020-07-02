--[[
Title: QuestTempGarbage_Page
Author(s): Leio
Date: 2008/12/22
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemQuest/forms/QuestTempGarbage_Page.lua");
Map3DSystem.Quest.QuestTempGarbage_Page.ShowPage("new")
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_DB.lua");
local QuestTempGarbage_Page = {
	name = "QuestTempGarbage_Page_instance",

}
commonlib.setfield("Map3DSystem.Quest.QuestTempGarbage_Page",QuestTempGarbage_Page);
function QuestTempGarbage_Page.OnInit()
	local self = QuestTempGarbage_Page;
	self.page = document:GetPageCtrl();
end

function QuestTempGarbage_Page.ShowPage()
	local title = "重新找回删除的任务";
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url=System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemQuest/forms/QuestTempGarbage_Page.html", {cmdredirect=cmdredirect}), 
			name="QuestTempGarbage_Page", 
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
				x = (screenWidth - 400)/2,
				y = (screenHeight - 300)/2,
				width = 400,
				height = 300,
				bAutoSize=false,
			zorder=3,
		});
end
function QuestTempGarbage_Page.ClosePage()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="QuestTempGarbage_Page", 
		app_key=MyCompany.Aquarius.app.app_key, 
		bShow = false,bDestroy = true,});
end
function QuestTempGarbage_Page.g_ChainView(params) 
	local self = QuestTempGarbage_Page;
	NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieClipEditor.lua");
	local alignment,left,top,width,height,parent =  params.alignment,params.left,params.top,params.width,params.height,params.parent;
	local _this = ParaUI.GetUIObject("container"..self.name);
	if(not _this:IsValid()) then
		_this = ParaUI.CreateUIObject("container","container"..self.name, alignment, left, top, width, height);
		_this.background =  "";
		params.parent:AddChild(_this);
	end	
	local parent = _this;
	ctl = CommonCtrl.TreeView:new{
		name = self.name.."chain",
		alignment = "_lt",
		left= 0, top=0,
		width = width,
		height = height,
		parent = parent,
		DefaultNodeHeight = 32,
		DrawNodeHandler = QuestTempGarbage_Page.DrawViewNodeHandler_Chain,	
	};
	ctl:Show(true);
	self.ChainTreeView = ctl;
end
function QuestTempGarbage_Page.DataBind(data)
	local self = QuestTempGarbage_Page;
	if( not data) then return end;
	local ctl = self.ChainTreeView;
	local k,v;
	for k,v in pairs(data) do
		local quest = v;
		local node = CommonCtrl.TreeNode:new({Text = quest.Title, data = quest})
		ctl.RootNode:AddChild(node);
	end
	ctl:Update();
end

function QuestTempGarbage_Page.DrawViewNodeHandler_Chain(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2; -- indentation of this node. 
	local top = 3;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	if(treeNode.TreeView.RootNode:GetHeight() > 0) then
		left = left + treeNode.TreeView.DefaultIndentation*treeNode.Level + 2;
	else
		left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1) + 2;
	end	
	-- render each node type	
		_parent.background = ""
		
		_this=ParaUI.CreateUIObject("button","b","_lt", left, top , 200, height - 1);
		--_this.background = "";
		_parent:AddChild(_this);
		_this.text = treeNode.Text;

		left = -35;
		width = 32;
		height = 32
		_this=ParaUI.CreateUIObject("button","b","_rt", left, top, width, height);		
		_this.background = "Texture/3DMapSystem/common/png-1684.png";
		_this.tooltip = "查看任务"		
		_this.onclick = string.format([[;Map3DSystem.Quest.QuestTempGarbage_Page.OnQuestProperty(%q, %q);]], treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
		left = left -30;
		
		_this=ParaUI.CreateUIObject("button","b","_rt", left, top, width, height);
		_this.background = "Texture/3DMapSystem/common/rightsign.png";
		_this.tooltip = "重新找回"
		_this.onclick = string.format([[;Map3DSystem.Quest.QuestTempGarbage_Page.PushQuestFromGarbage(%q, %q);]], treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
end

function QuestTempGarbage_Page.OnQuestProperty(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	local quest = node.data;
	if(quest)then
		Map3DSystem.Quest.Quest_Panel.OnEditQuest(quest.entry);
	end
end
function QuestTempGarbage_Page.PushQuestFromGarbage(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	if(node)then
		local quest = node.data;
		if(quest)then
			local id = quest.entry;
			if(Map3DSystem.Quest.Quest_ChainEdit_Page.state == "edit")then
				Map3DSystem.Quest.Quest_ChainEdit_Page.PushQuestFromGarbage(id)				
			end
		end
		node:Detach();
		self:Update();
	end
end

