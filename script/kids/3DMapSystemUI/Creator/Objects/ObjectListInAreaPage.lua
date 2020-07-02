--[[
Title:
Author(s): Leio
Date: 2010/04/08
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Objects/ObjectListInAreaPage.lua");
------------------------------------------------------------
]]

local ObjectListInAreaPage = {
	name = "ObjectListInAreaPage1",
};
commonlib.setfield("Map3DSystem.App.Creator.ObjectListInAreaPage", ObjectListInAreaPage)

function ObjectListInAreaPage.OnInit()
	local self = ObjectListInAreaPage;
	self.page = document:GetPageCtrl();
end
-- search nodes in a area
function ObjectListInAreaPage.SearchNodes()
	local self = ObjectListInAreaPage;
	local x = self.page:GetValue("x");
	local y = self.page:GetValue("y");
	local width = self.page:GetValue("width");
	local height = self.page:GetValue("height");
	local includeMyself = self.page:GetValue("includeMyself");
	x = tonumber(x) or 0;
	y = tonumber(y) or 0;
	width = tonumber(width) or 1020;
	height = tonumber(height) or 680;
	
	local result = {}; 
	local objList = {};
	ParaScene.GetObjectsByScreenRect(result, x, y, x + width, y + height, "4294967295", -1);
	local ctl = CommonCtrl.GetControl(self.name.."treeView");
	if(ctl) then
		ctl.RootNode:ClearAllChildren();
		local k,obj;
		local player_id = ParaScene.GetPlayer():GetID();
		for k,obj in ipairs(result) do
			if(obj and obj:IsValid())then
				local id = obj:GetID();
				local name = obj.name or "";
				local node = CommonCtrl.TreeNode:new({ Name = name, ID = id,})
				if(id == player_id)then
					if(includeMyself == true)then
						ctl.RootNode:AddChild(node);
						table.insert(objList,id);
					end
				else
					ctl.RootNode:AddChild(node);
					table.insert(objList,id);
				end
			end
		end
		ctl:Update();
	end
	self.objList = objList;
end
function ObjectListInAreaPage.DeleteAll()
	local self = ObjectListInAreaPage;
	if(self.objList)then
		local k,id;
		for k,id in ipairs(self.objList) do
			 self.DeleteObj(id);
		end
	end
end
function ObjectListInAreaPage.SelectedObject(id)
	local self = ObjectListInAreaPage;
	if(not id)then return end
	local entity = ParaScene.GetObject(id);
	if(entity and entity:IsValid())then
		ParaSelection.AddObject(entity,1);
	end
end
function ObjectListInAreaPage.DeleteObj(id)
	local self = ObjectListInAreaPage;
	if(not id)then return end
	local entity = ParaScene.GetObject(id);
	if(entity and entity:IsValid())then
		ParaScene.Delete(entity);
	end
end
function ObjectListInAreaPage.Show(params)
	if(not params)then return end
	local self = ObjectListInAreaPage;
	local _this = ParaUI.GetUIObject("container"..self.name);
	if(not _this:IsValid()) then
		_this = ParaUI.CreateUIObject("container", "container"..self.name, params.alignment, params.left, params.top, params.width, params.height);
		params.parent:AddChild(_this);
	end	
	local ctl = CommonCtrl.TreeView:new{
		name = self.name.."treeView",
		alignment = "_fi",
		left=0, top=0,
		width = 0,
		height = 0,
		parent = _this,
		DefaultNodeHeight = 22,
		ShowIcon = false,
		DrawNodeHandler = ObjectListInAreaPage.DrawSingleSelectionNodeHandler,	
	};
	ctl:Show();
	CommonCtrl.AddControl(ctl.name,ctl);
end
function ObjectListInAreaPage.DrawSingleSelectionNodeHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2; -- indentation of this node. 
	local top = 2;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	if(treeNode.TreeView.ShowIcon) then
		local IconSize = treeNode.TreeView.DefaultIconSize;
		if(treeNode.Icon~=nil and IconSize>0) then
			_this=ParaUI.CreateUIObject("button","b","_lt", left, (height-IconSize)/2 , IconSize, IconSize);
			_this.background = treeNode.Icon;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
		end	
		if(not treeNode.bSkipIconSpace) then
			left = left + IconSize;
		end	
	end	
	if(treeNode.TreeView.RootNode:GetHeight() > 0) then
		left = left + treeNode.TreeView.DefaultIndentation*treeNode.Level + 2;
	else
		left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1) + 2;
	end	
	if(treeNode.ID ~= nil) then
			_this=ParaUI.CreateUIObject("button","b","_lt", left, 0 , nodeWidth - left-2, height - 1);
			_parent:AddChild(_this);
			
			_this.onclick = string.format(";Map3DSystem.App.Creator.ObjectListInAreaPage.OnSelectNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = tostring(treeNode.ID)..":"..tostring(treeNode.Name);
			
			_this=ParaUI.CreateUIObject("button","b","_rt", -55, top, 16, 16);
			_this.background = "Texture/3DMapSystem/common/searchIcon.png";
			_this.tooltip = "瞬移";
			_this.onclick = string.format(";Map3DSystem.App.Creator.ObjectListInAreaPage.OnGotoPos(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);	
			_this=ParaUI.CreateUIObject("button","b","_rt", -35, top, 16, 16);
			_this.background = "Texture/3DMapSystem/common/Close.png";
			_this.tooltip = "删除";
			_this.onclick = string.format(";Map3DSystem.App.Creator.ObjectListInAreaPage.OnDeleteNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);	
	end	
end
function ObjectListInAreaPage.OnSelectNode(sCtrlName, nodePath)
	local self = ObjectListInAreaPage;
	local ctl = CommonCtrl.GetControl(sCtrlName);
	if(ctl)then
		local node = ctl:GetNodeByPath(nodePath);
		if(node ~= nil) then
			self.SelectedObject(node.ID);
		end
	end
end
function ObjectListInAreaPage.OnDeleteAll()
	local self = ObjectListInAreaPage;
	self.DeleteAll();
	local ctl = CommonCtrl.GetControl(self.name.."treeView");
	if(ctl)then
		ctl.RootNode:ClearAllChildren();
		ctl:Update();
	end
end
function ObjectListInAreaPage.OnGotoPos(sCtrlName, nodePath)
	local ctl = CommonCtrl.GetControl(sCtrlName);
	if(ctl)then
		local node = ctl:GetNodeByPath(nodePath);
		if(node ~= nil) then
			local id = node.ID;
			local obj = ParaScene.GetObject(id);
			if(obj and obj:IsValid())then
				local x,y,z = obj:GetPosition();
				Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x= x, y = y, z = z});
			end
		end
	end
end
function ObjectListInAreaPage.OnDeleteNode(sCtrlName, nodePath)
	local self = ObjectListInAreaPage;
	local ctl = CommonCtrl.GetControl(sCtrlName);
	if(ctl)then
		local node = ctl:GetNodeByPath(nodePath);
		if(node ~= nil) then
			local id = node.ID;
			self.DeleteObj(id);
			node:Detach();
			ctl:Update();
		end
	end
end