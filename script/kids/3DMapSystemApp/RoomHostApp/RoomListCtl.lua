--[[
Title: A room list control that can be used by many applications for room services. 
Author(s): LiXizhi
Date: 2007/2/7
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/RoomHostApp/RoomListCtl.lua");
local ctl = Map3DSystem.App.RoomListCtl:new{
	name = "RoomListCtl1",
	alignment = "_lt",
	left=0, top=0,
	width = 512,
	height = 290,
	parent = nil,
};
ctl:Show();
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local RoomListCtl = {
	-- the top level control name
	name = "RoomListCtl1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 512,
	height = 290, 
	parent = nil,
	bShowLevel = true,
}

Map3DSystem.App.RoomListCtl = RoomListCtl;

-- constructor
function RoomListCtl:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function RoomListCtl:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function RoomListCtl:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("RoomListCtl instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		--_this.background="Texture/whitedot.png;0 0 0 0";
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);

		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 425, 17, 72, 16)
		_this.text = "房间名称";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button1", "_lt", 15, 14, 96, 23)
		_this.text = "房间编号";
		_guihelper.SetVistaStyleButton(_this, "", "Texture/alphadot.png");
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button2", "_lt", 131, 14, 96, 23)
		_this.text = "状态";
		_guihelper.SetVistaStyleButton(_this, "", "Texture/alphadot.png");
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button3", "_lt", 248, 14, 96, 23)
		_this.text = "人数";
		_guihelper.SetVistaStyleButton(_this, "", "Texture/alphadot.png");
		_parent:AddChild(_this);


		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = self.name.."RoomListTreeView",
			alignment = "_fi",
			left = 15,
			top = 43,
			width = 14,
			height = 51,
			parent = _parent,
			DefaultIndentation = 5,
			DefaultNodeHeight = 22,
			DrawNodeHandler = Map3DSystem.App.RoomListCtl.DrawRoomNodeHandler,
			onclick = Map3DSystem.App.RoomListCtl.OnClickRoomNode,
		};
		local node = ctl.RootNode;
		node:AddChild( CommonCtrl.TreeNode:new({type="room_node", Text = "大大地", Name = "RoomID1", roomid = 1, app_key="abc app", status = "等待中",
			HostUser_ID="LiXizhi", bRequirePassword=true, CreationDurationTime=10,MaxPeopleAllowed=10, CurPeopleCount=1, Level=1 }) );
		node:AddChild( CommonCtrl.TreeNode:new({type="room_node", Text = "Another one", Name = "RoomID2", roomid = 2, app_key="abc app", status = "等待中",
			HostUser_ID="LiXizhi2", bRequirePassword=true, CreationDurationTime=10,MaxPeopleAllowed=10,CurPeopleCount=3, Level=1 }) );
		node:AddChild( CommonCtrl.TreeNode:new({type="room_node", Text = "大大地", Name = "RoomID1", roomid = 1, app_key="abc app", status = "等待中",
			HostUser_ID="LiXizhi3", bRequirePassword=true, CreationDurationTime=10,MaxPeopleAllowed=10, CurPeopleCount=1, Level=1 }) );
		node:AddChild( CommonCtrl.TreeNode:new({type="room_node", Text = "Another one", Name = "RoomID2", roomid = 2, app_key="abc app", status = "等待中",
			HostUser_ID="LiXizhi4", bRequirePassword=true, CreationDurationTime=10,MaxPeopleAllowed=10,CurPeopleCount=3, Level=1 }) );
		
		node:AddChild( CommonCtrl.TreeNode:new({type="room_node", Text = "大大地", Name = "RoomID1", roomid = 1, app_key="abc app", status = "等待中",
			HostUser_ID="LiXizhi5", bRequirePassword=true, CreationDurationTime=10,MaxPeopleAllowed=10, CurPeopleCount=1, Level=1 }) );
		node:AddChild( CommonCtrl.TreeNode:new({type="room_node", Text = "Another one", Name = "RoomID2", roomid = 2, app_key="abc app", status = "等待中",
			HostUser_ID="LiXizhi6", bRequirePassword=true, CreationDurationTime=10,MaxPeopleAllowed=10,CurPeopleCount=3, Level=1 }) );
			node:AddChild( CommonCtrl.TreeNode:new({type="room_node", Text = "大大地", Name = "RoomID1", roomid = 1, app_key="abc app", status = "等待中",
			HostUser_ID="LiXizhi7", bRequirePassword=true, CreationDurationTime=10,MaxPeopleAllowed=10, CurPeopleCount=1, Level=1 }) );
		node:AddChild( CommonCtrl.TreeNode:new({type="room_node", Text = "Another one", Name = "RoomID2", roomid = 2, app_key="abc app", status = "等待中",
			HostUser_ID="LiXizhi8", bRequirePassword=true, CreationDurationTime=10,MaxPeopleAllowed=10,CurPeopleCount=3, Level=1 }) );
			ctl:Show();

		_this = ParaUI.CreateUIObject("button", "btnCreateRoom", "_lb", 15, -45, 121, 32)
		_this.text = "创建房间";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnQuickJoin", "_lb", 161, -45, 121, 32)
		_this.text = "随机进入";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnRefresh", "_rb", -135, -45, 121, 32)
		_this.text = "刷新";
		_parent:AddChild(_this);

		
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
	end	
end

-- close the given control
function RoomListCtl.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting RoomListCtl instance "..sCtrlName.."\r\n");
		return;
	end
	ParaUI.Destroy(self.name);
end

-- this function is called, when a room node is clicked. 
function RoomListCtl.OnClickRoomNode(treeNode)
	local sCtrlName = string.gsub(treeNode.TreeView.name, "RoomListTreeView$", "");
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting RoomListCtl instance "..sCtrlName.."\r\n");
		return;
	end
	
	-- only one node is selected for editing at a time
	if(self.SelectedAppNode~=nil) then
		self.SelectedAppNode.NodeHeight = nil;
		self.SelectedAppNode.Selected = nil;
	end
	treeNode.NodeHeight = 90;
	treeNode.Selected = true;
	self.SelectedAppNode = treeNode;
	
	-- update view
	treeNode.TreeView:Update(true);
end

-- owner draw function to RoomListCtl
function RoomListCtl.DrawRoomNodeHandler(_parent, treeNode)
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
			_this=ParaUI.CreateUIObject("button","b","_lt", left, top , IconSize, IconSize);
			_this.background = treeNode.Icon;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
		end	
		left = left + IconSize;
	end	
	if(treeNode.TreeView.RootNode:GetHeight() > 0) then
		left = left + treeNode.TreeView.DefaultIndentation*treeNode.Level + 2;
	else
		left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1) + 2;
	end	
	
	if(treeNode.type == "group") then
		-- render my map group treeNode: a colored name and an expand arrow
		width = 24 -- check box width
		
		_this=ParaUI.CreateUIObject("button","b","_lt", left, top , width, width);
		_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
		left = left + width + 2;
		
		if(treeNode.Expanded) then
			_this.background = "Texture/3DMapSystem/common/itemopen.png";
		else
			_this.background = "Texture/3DMapSystem/common/itemclosed.png";
		end
		
		_this=ParaUI.CreateUIObject("text", "b", "_lt", left, 5, nodeWidth - left-1, height);
		_parent:AddChild(_this);
		_this:GetFont("text").format=36; -- single line and vertical align
		
		_this.text = treeNode.Text;
		
	elseif(treeNode.type == "room_node") then
		-- render my map treeNode: a name and close button (and edit button for map created by user)
		
		-- Room ID
		_this=ParaUI.CreateUIObject("button","b","_lt", left, 2 , 75, 20);
		_parent:AddChild(_this);
		_this.background = "";
		_this.onclick = string.format(";CommonCtrl.TreeView.OnClickNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_this.text = tostring(treeNode.roomid);
		_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
		
		-- Status
		_this=ParaUI.CreateUIObject("text","b","_lt", left+80, 2 , 75, 2);
		_parent:AddChild(_this);
		_this.text = tostring(treeNode.status);
		
		-- people
		_this=ParaUI.CreateUIObject("text","b","_lt", left+140, 2 , 75, 2);
		_parent:AddChild(_this);
		_this.text = string.format("%d/%d",treeNode.CurPeopleCount, treeNode.MaxPeopleAllowed );
		
		-- Locked
		if(treeNode.bRequirePassword) then
			_this=ParaUI.CreateUIObject("button","b","_lt", left+180, 2 , 50, 16);
			_parent:AddChild(_this);
			_this.text = "上锁了";
		end	
		
		-- room name
		if(treeNode.Text~=nil or treeNode.Text == "") then
			_this=ParaUI.CreateUIObject("text","b","_lt", left+260, 2 , 50, 16);
			_parent:AddChild(_this);
			_this.text = treeNode.Text;
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
		end
			
		if(not treeNode.Selected) then
			_parent.background = "";
		else
			_parent.background = "Texture/alphadot.png";
			
			-- Display the join button
			if(treeNode.Text~=nil or treeNode.Text == "") then
				_this=ParaUI.CreateUIObject("button","b","_lt", left+10, 20 , 70, 22);
				_this.text = "加入房间";
				_parent:AddChild(_this);
			end
		end
	end
end


