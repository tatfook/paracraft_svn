--[[
Title: dock in InGame UI for 3D Map system
Author(s): WangTian
Date: 2007/12/17
Desc: Macintosh-like dock
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Layout/Dock.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");


-- default member attributes
local Dock = {
	-- the top level control name
	name = "MainDock",
	-- dock alignment, "left"|"right"|"top"|"bottom"
	alignment = "bottom",
	-- dock height
	dockheight = 64,
	
	left = 0,
	top = 0,
	width = 300,
	height = 400, 
	-- the background of container
	container_bg = nil, 
	-- The root tree node. containing all tree node data
	RootNode = nil, 
	-- Default height of Tree Node
	DefaultNodeHeight = 24,
	-- default indentation
	DefaultIndentation = 10,
	-- Gets or sets a function by which the individual TreeNode control is drawn. The function should be of the format:
	-- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
	-- if DrawNode is nil, the default FileTreeView.DrawFileItemHandler function will be used. 
	DrawNodeHandler = nil,
	-- Force no clipping or always using fast render. Unless you know that the unit scroll step is interger times of all TreeNode height. You can disable clipping at your own risk. 
	-- Software clipping is always used to clip all invisible TreeNodes. However, this option allows you to specify whether to use clipping for partially visible TreeNode. 
	NoClipping = nil,
	-- a function of type function (MenuItem, nodepathString) or nil. this function will be called for each menuitem onclick except the group node.
	onclick = nil,
	
	-- the initial directory. 
	sInitDir = "",
	-- e.g."*.", "*.x" or it could be table like {"*.lua", "*.raw"}
	sFilePattern = "*.*",
	-- max file levels. 0 shows files in the current directory.
	nMaxFileLevels = 3,
	-- max number of files in file listbox. e.g. 150
	nMaxNumFiles = 300,
	-- currently selected file path. 
	SelectedFilePath = "",
	-------------------------------------------
	-- private functions
	-------------------------------------------
	IsModified = true,
}

if(not Map3DSystem.UI.DockNode) then
	Map3DSystem.UI.DockNode = {};
	Map3DSystem.UI.DockNode.DefaultNodeWidth = 48;
	Map3DSystem.UI.DockNode.DefaultNodeHeight = 48;
	Map3DSystem.UI.DockNode.DefaultDrawNodeHandler = nil;
	Map3DSystem.UI.DockNode.DefaultIcon = ""; --  TODO: fix the default icon
end

-- constructor
function Map3DSystem.UI.DockNode:new(o)
	o = o or {}; -- create object if user does not provide one
	setmetatable(o, self);
	self.__index = self;
	
	if(o.width == nil) then
		o.width = Map3DSystem.UI.DockNode.DefaultNodeWidth;
	end
	
	if(o.height == nil) then
		o.height = Map3DSystem.UI.DockNode.DefaultNodeHeight;
	end
	
	if(o.DefaultIcon == nil) then
		o.DefaultIcon = Map3DSystem.UI.DockNode.DefaultIcon;
	end
	
	if(o.DrawNodeHandler == nil) then
		o.DrawNodeHandler = Map3DSystem.UI.DockNode.DefaultDrawNodeHandler;
	end
end

function Map3DSystem.UI.DockNode.DefaultDrawNodeHandler()
	-- TODO: implement
	-- draw the DefaultIcon
end

-- constructor
function Map3DSystem.UI.Dock:new(o)
	o = o or {}; -- create object if user does not provide one
	setmetatable(o, self);
	self.__index = self;
	
	-- use default draw function if user does not provide one 
	if(not o.DrawNodeHandler) then
		o.DrawNodeHandler = self.DrawFileItemHandler
	end
	
	-- create a TreeView control for it. 
	local ctl = CommonCtrl.TreeView:new{
		name = o.name.."TreeView",
		alignment = "_fi",
		left=0, top=0,
		width = 0,
		height = 0,
		-- function DrawNodeEventHandler(parent,treeNode) end, where parent is the parent container in side which contents should be drawn. And treeNode is the TreeNode object to be drawn
		DrawNodeHandler = o.DrawNodeHandler,
		container_bg = o.container_bg,
		NoClipping = o.NoClipping,
		DefaultNodeHeight = o.DefaultNodeHeight,
		DefaultIndentation = o.DefaultIndentation,
	};
	o.RootNode = ctl.RootNode;

	CommonCtrl.AddControl(o.name, o);
	
	return o;
end

-- Destroy the UI control
function Map3DSystem.UI.Dock:Destroy()
	ParaUI.Destroy(self.name);
end


-- Show the dock
function Map3DSystem.UI.Dock.Show()
	
	local _this = ParaUI.GetUIObject(self.name);
	
	-- create the dock
	local _dock = ParaUI.CreateUIObject("container", self.name, "_ctl", 0, 0, 48, 200);
	--_dock.background = "Texture/whitedot.png";
	_dock:AttachToRoot();
	
	-- create tree view for dock
	NPL.load("(gl)script/ide/TreeView.lua");
	local ctl = CommonCtrl.TreeView:new{
		name = "LeftDock",
		alignment = "_fi",
		left = 0, top = 0,
		width = 0,
		height = 0,
		DefaultNodeHeight = 40,
		parent = _dock,
		DrawNodeHandler = Map3DSystem.UI.Dock.DrawNodeHandler,
	};
	
	local node = ctl.RootNode;
	node:AddChild("Node1");
	node:AddChild(CommonCtrl.TreeNode:new({Text = "Node2", Name = "sample"}));
	node = node:AddChild("Node3");
	node = node:AddChild("Node3_1");
	node = node:AddChild("Node3_1_1");
	ctl.RootNode:AddChild("Node4");
	ctl.RootNode:AddChild("Node5");

	ctl:Show();
	-- One needs to call Update() if made any modifications to the TreeView after the Show() method, such as adding or removing new nodes, or changing text of a given node. 
	-- ctl:Update();
	
	self.parent:AddChild(_this);
end

function Map3DSystem.UI.Dock.DrawNodeHandler()
end