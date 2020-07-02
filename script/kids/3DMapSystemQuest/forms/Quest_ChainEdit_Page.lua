--[[
Title: Quest_ChainEdit_Page
Author(s): Leio
Date: 2008/12/22
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_ChainEdit_Page.lua");
Map3DSystem.Quest.Quest_ChainEdit_Page.ShowPage("new")
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_DB.lua");
local Quest_ChainEdit_Page = {
	state = nil, -- "new" or "edit"
	name = "Quest_ChainEdit_Page_instance",
}
commonlib.setfield("Map3DSystem.Quest.Quest_ChainEdit_Page",Quest_ChainEdit_Page);
function Quest_ChainEdit_Page.OnInit()
	local self = Quest_ChainEdit_Page;
	self.page = document:GetPageCtrl();
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_Panel.lua");
	Map3DSystem.Quest.Quest_Panel.OnRefreshValidQuestChains();
	self.addedQuest = {};
	self.removedQuest_editState = {};
	
end

function Quest_ChainEdit_Page.ShowPage(state)
	Quest_ChainEdit_Page.state = state;
	local title;
	if( state == "new")then
		title = "新增任务链";
	else
		title = "编辑任务链";
	end
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url=System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemQuest/forms/Quest_ChainEdit_Page.html", {cmdredirect=cmdredirect}), 
			name="Quest_ChainEdit_Page", 
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
function Quest_ChainEdit_Page.ClosePage()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="Quest_ChainEdit_Page", 
		app_key=MyCompany.Aquarius.app.app_key, 
		bShow = false,bDestroy = true,});
end
function Quest_ChainEdit_Page.g_ChainView(params) 
	local self = Quest_ChainEdit_Page;
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
		width = 400,
		height = height,
		parent = parent,
		DefaultNodeHeight = 32,
		DrawNodeHandler = Quest_ChainEdit_Page.DrawViewNodeHandler_Chain,	
	};
	ctl:Show(true);
	self.ChainTreeView = ctl;
end
function Quest_ChainEdit_Page.DataBind(questChain)
	local self = Quest_ChainEdit_Page;
	if( not questChain) then return end;
	local k,v;
	for k,v in ipairs(questChain) do
		local quest = v["quest"];
		Quest_ChainEdit_Page.PushQuest(quest["entry"]);	
	end
end

function Quest_ChainEdit_Page.DrawViewNodeHandler_Chain(_parent,treeNode)
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
		local quest = treeNode.data;
		local title = quest["Title"] or "";
		local details = quest["Details"] or ""
		local info = title.."\r\n"..details;
		_this=ParaUI.CreateUIObject("button","b","_lt", left, top , 200, height - 1);
		--_this.background = "";
		_parent:AddChild(_this);
		_this.tooltip = info;
		_this.text = treeNode.Text;

		left = -35;
		width = 32;
		height = 32
		_this=ParaUI.CreateUIObject("button","b","_rt", left, top, width, height);		
		_this.background = "Texture/3DMapSystem/common/png-1684.png";
		_this.tooltip = "查看任务"		
		_this.onclick = string.format([[;Map3DSystem.Quest.Quest_ChainEdit_Page.OnQuestProperty(%q, %q);]], treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
		left = left -30;
		--_this=ParaUI.CreateUIObject("button","b","_rt", left, top, width, height);
		--_this.background = "Texture/3DMapSystem/common/png-1472.png";
		--_this.tooltip = "关联NPC"
		--_this.onclick = string.format([[;Map3DSystem.Quest.Quest_ChainEdit_Page.NPCRelationNode(%q, %q);]], treeNode.TreeView.name, treeNode:GetNodePath());
		--_parent:AddChild(_this);
		--left = left -30;
		_this=ParaUI.CreateUIObject("button","b","_rt", left, top, width, height);
		_this.background = "Texture/3DMapSystem/common/downarrow.png";
		_this.tooltip = "往下移"
		_this.onclick = string.format([[;Map3DSystem.Quest.Quest_ChainEdit_Page.DownNode(%q, %q);]], treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
		left = left -30;
		_this=ParaUI.CreateUIObject("button","b","_rt", left, top, width, height);
		_this.background = "Texture/3DMapSystem/common/uparrow.png";
		_this.tooltip = "往上移"
		_this.onclick = string.format([[;Map3DSystem.Quest.Quest_ChainEdit_Page.UpNode(%q, %q);]], treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
		left = left -30;
		_this=ParaUI.CreateUIObject("button","b","_rt", left, top, width, height);
		_this.background = "Texture/3DMapSystem/common/wrongsign.png";
		_this.tooltip = "删除"
		_this.onclick = string.format([[;Map3DSystem.Quest.Quest_ChainEdit_Page.RemoveNode(%q, %q);]], treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
end
function Quest_ChainEdit_Page.PushQuest(id)
	local self = Quest_ChainEdit_Page;
	if(not id)then return end;
	local quest = Map3DSystem.Quest.DB.Quests[id];

	if(not quest)then return end;
	
		if(self.addedQuest[id] )then
			_guihelper.MessageBox(string.format("已经导入: %d ！", id))
			return;
		end
		self.addedQuest[id] = quest;
		local ctl = self.ChainTreeView
		local node = CommonCtrl.TreeNode:new({Text = quest.Title, data = quest})
		ctl.RootNode:AddChild(node);
		ctl:Update();
end

function Quest_ChainEdit_Page.OnQuestProperty(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	local quest = node.data;
	if(quest)then
		Map3DSystem.Quest.Quest_Panel.OnEditQuest(quest.entry);
	end
end
function Quest_ChainEdit_Page.PushQuestFromGarbage(id)
	local self = Quest_ChainEdit_Page;
	if(self.state ~= "edit")then return; end
	if(not id)then return end;
	local quest = self.removedQuest_editState[id];
	if(not quest)then return end;
	
	local ctl = self.ChainTreeView
	local node = CommonCtrl.TreeNode:new({Text = quest.Title, data = quest})
	ctl.RootNode:AddChild(node);
	ctl:Update();
	
	self.removedQuest_editState[id] = nil;
end
function Quest_ChainEdit_Page.RemoveNode(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	if(node)then
		local quest = node.data;
		if(quest)then
			local id = quest.entry;
			if(Quest_ChainEdit_Page.state == "new") then
				if(Quest_ChainEdit_Page.addedQuest[id])then
					Quest_ChainEdit_Page.addedQuest[id] = nil;
				end
			else
				Quest_ChainEdit_Page.removedQuest_editState[id] = quest;
			end
		end
		node:Detach();
		self:Update();
	end
end
function Quest_ChainEdit_Page.UpNode(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	local index = node.index;
	if(index > 1)then
		self.RootNode:SwapChildNodes(index, index - 1)
	else
		_guihelper.MessageBox("已经在最前！")
	end
	self:Update();
end
function Quest_ChainEdit_Page.DownNode(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	local index = node.index;
	local len = self.RootNode:GetChildCount();
	if(index < len)then
		self.RootNode:SwapChildNodes(index, index + 1)
	else
		_guihelper.MessageBox("已经在最后！")
	end
	self:Update();
end
function Quest_ChainEdit_Page.Refind()
	local self = Quest_ChainEdit_Page;
	if(self.state ~= "edit")then return; end
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/QuestTempGarbage_Page.lua");
	Map3DSystem.Quest.QuestTempGarbage_Page.ShowPage()
	Map3DSystem.Quest.QuestTempGarbage_Page.DataBind(self.removedQuest_editState);
end

function Quest_ChainEdit_Page.DoSave()
	local self = Quest_ChainEdit_Page;
		local questChain = {};
		if(self.CanSave())then
			local ctl = self.ChainTreeView;
			local k,len = 1,ctl.RootNode:GetChildCount();
			for k =1,len do
				local node = ctl.RootNode:GetChild(k);
				local quest = node.data;
				Map3DSystem.Quest.Quest_Panel_DB.ResetQuest(quest); -- reset quest
				
				local pre_node,next_node,pre_quest,next_quest; 
				pre_node = ctl.RootNode:GetChild(k-1);
				next_node = ctl.RootNode:GetChild(k+1); 
				if(pre_node)then
					pre_quest = pre_node.data;
				end
				if(next_node)then
					next_quest = next_node.data;
				end
				
				
				if(pre_quest)then
					quest["PrevQuestId"] = pre_quest["entry"];
				end
				if(next_quest)then
					quest["NextQuestInChain"] = next_quest["entry"];
				end
				local result = {quest = quest};
				table.insert(questChain,result);
			end
			
			local k,removedQuest;
			-- reset the state of removedQuest
			for k,removedQuest in pairs(self.removedQuest_editState) do
				commonlib.echo(removedQuest["entry"]);
				Map3DSystem.Quest.Quest_Panel_DB.ResetQuest(removedQuest); -- reset quest
				Map3DSystem.Quest.Quest_Panel_DB.UpdateQuestTemplate(removedQuest);
			end
			
			-- save the result
			if(Map3DSystem.Quest.Quest_Panel_DB.UpdateASingleQuestChain(questChain))then			
				_guihelper.MessageBox("保存成功！")
			else
				_guihelper.MessageBox("保存失败！")
			end
		end
end
function Quest_ChainEdit_Page.CanSave()
	local self = Quest_ChainEdit_Page;
	local ctl = self.ChainTreeView;
		if(not ctl)then return end
		local len_removed = #self.removedQuest_editState
		local removed = false;
		local k,v;
		for k,v in pairs(self.removedQuest_editState) do
			removed = true;
			break;
		end
		local k,len = 1,ctl.RootNode:GetChildCount();
		
		if(len == 0 and removed == false)then
			_guihelper.MessageBox("没有任务链可以保存！")
			return;
		end
		--for k =1,len do
			--local node = ctl.RootNode:GetChild(k);
			--local quest = node.data;
			--if(not quest)then
				--_guihelper.MessageBox("没有任务可保存！")
				--return;
			--end
		--end
		return true;
end