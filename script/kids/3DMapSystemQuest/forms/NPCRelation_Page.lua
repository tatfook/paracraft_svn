--[[
Title: NPCRelation_Page
Author(s): Leio
Date: 2008/12/22
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemQuest/forms/NPCRelation_Page.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_DB.lua");
local NPCRelation_Page = {
	name = "NPCRelation_Page_instance",
}
commonlib.setfield("Map3DSystem.Quest.NPCRelation_Page",NPCRelation_Page);
function NPCRelation_Page.OnInit()
	local self = NPCRelation_Page;
	self.page = document:GetPageCtrl();
	NPL.load("(gl)script/kids/3DMapSystemQuest/forms/Quest_Panel.lua");
	Map3DSystem.Quest.Quest_Panel.OnRefreshNPC();
end

function NPCRelation_Page.ShowPage()
	local title = "NPC";
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url=System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemQuest/forms/NPCRelation_Page.html", {cmdredirect=cmdredirect}), 
			name="NPCRelation_Page", 
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
function NPCRelation_Page.ClosePage()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="NPCRelation_Page", 
		app_key=MyCompany.Aquarius.app.app_key, 
		bShow = false,bDestroy = true,});
end
function NPCRelation_Page.g_ChainView(params) 
	local self = NPCRelation_Page;
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
		name = self.name.."start",
		alignment = "_lt",
		left= 0, top=0,
		width = 300,
		height = 200,
		parent = parent,
		DefaultNodeHeight = 32,
		DrawNodeHandler = NPCRelation_Page.DrawViewNodeHandler_Finish,	
	};
	ctl:Show(true);
	self.ChainTreeView_start = ctl;
	
	ctl = CommonCtrl.TreeView:new{
		name = self.name.."finish",
		alignment = "_lt",
		left= 0, top=250,
		width = 300,
		height = 200,
		parent = parent,
		DefaultNodeHeight = 32,
		DrawNodeHandler = NPCRelation_Page.DrawViewNodeHandler_Finish,	
	};
	ctl:Show(true);
	self.ChainTreeView_finish = ctl;
end
function NPCRelation_Page.DataBind(start_npc,finish_npc)
	local self = NPCRelation_Page;
	self.start_npc = start_npc;
	self.finish_npc = finish_npc;
	if(start_npc)then
		local start_id = start_npc.ID;
		self.PushStartNode(start_id);
	end
	if(finish_npc)then
		local finish_id = finish_npc.ID;
		self.PushFinishNode(finish_id);
	end
end
function NPCRelation_Page.DrawViewNodeHandler_Finish(_parent,treeNode)
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
		local npc = treeNode.data;
		local position;
		if(npc)then
			position = string.format("(%d,%d)",npc.posX,npc.posZ);
		end
		_this=ParaUI.CreateUIObject("button","b","_lt", left, top , 200, height - 1);
		--_this.background = "";
		_parent:AddChild(_this);
		_this.text = treeNode.Text.." ".. position;

		left = -35;
		width = 32;
		height = 32
		left = left -30;
		_this=ParaUI.CreateUIObject("button","b","_rt", left, top, width, height);
		_this.background = "Texture/3DMapSystem/common/png-1684.png";
		_this.tooltip = "属性"
		_this.onclick = string.format([[;Map3DSystem.Quest.NPCRelation_Page.Property_NPC(%q, %q);]], treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
		left = left -30;
		_this=ParaUI.CreateUIObject("button","b","_rt", left, top, width, height);
		_this.background = "Texture/3DMapSystem/common/bug.png";
		_this.tooltip = "瞬移"
		_this.onclick = string.format([[;Map3DSystem.Quest.NPCRelation_Page.Move_NPC(%q, %q);]], treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
end
function NPCRelation_Page.Property_NPC(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	if(node)then	
		local id = node.data.ID
		Map3DSystem.Quest.Quest_Panel.OnEditNPC(id)
	end
end
function NPCRelation_Page.Move_NPC(sCtrlName, nodePath)
	local self, node = CommonCtrl.TreeView.GetCtl(sCtrlName, nodePath)
	if(node)then
		local id = node.data.ID
		Map3DSystem.Quest.Quest_Panel.OnMoveToNPC(id)
	end
end
function NPCRelation_Page.PushStartNode(id)
	local self = NPCRelation_Page;
	if(not id)then return end
	local ctl = self.ChainTreeView_start;
	local npc = self.PushNode(ctl,id);
	if(npc)then
		Map3DSystem.Quest.Quest_QuestForm_Page.SetStartRelation(npc)
	end
end
function NPCRelation_Page.PushFinishNode(id)
	local self = NPCRelation_Page;
	if(not id)then return end
	local ctl = self.ChainTreeView_finish;
	local npc = self.PushNode(ctl,id);
	if(npc)then
		Map3DSystem.Quest.Quest_QuestForm_Page.SetFinishRelation(npc)
	end
end
function NPCRelation_Page.PushNode(ctl,id)
	if(not ctl or not id)then return end
	local npc = Map3DSystem.Quest.DB.AllNPCs[id]
	local node = CommonCtrl.TreeNode:new({Text = npc.Name, data = npc});
	ctl.RootNode:ClearAllChildren();
	ctl.RootNode:AddChild(node);
	ctl:Update();
	return npc;
end