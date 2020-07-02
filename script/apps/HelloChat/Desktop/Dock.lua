--[[
Title: Hello chat dock interface
Author(s): WangTian
Date: 2008/10/24
Desc: The dock is the first level user interface that collects the most clicked icons in HelloChat. It provides a user with 
	a way of launching and switching between different functions. Since the functions are rather limited in HelloChat, the dock are 
	devided into three areas:
	Left: An input text box is shown on the left side of the dock. User can input chat text and add smileys or perform actions.
	Middle: Character customization and social tools, including: hair, skin color, clothes, cartoon face, explore friends .etc
	Right: Current chat window tabs. 
]]


NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/autotips.lua");

local libName = "HelloChatDock";
local libVersion = "1.0";

local Dock = commonlib.LibStub:NewLibrary(libName, libVersion)
HelloChat.Dock = Dock;


NPL.load("(gl)script/ide/treeview.lua");

Dock.Nodes = CommonCtrl.TreeNode:new({Name = "root", Icon = "", });
Dock.Nodes:AddChild(CommonCtrl.TreeNode:new({Tooltip = "聊天", Icon = "Texture/3DMapSystem/Chat/AppIcon_32.png", Name = "Chat"}));
Dock.Nodes:AddChild(CommonCtrl.TreeNode:new({Tooltip = "面部", Icon = "Texture/3DMapSystem/CCS/Level1_Facial.png", Name = "Facial"}));
Dock.Nodes:AddChild(CommonCtrl.TreeNode:new({Tooltip = "卡通脸", Icon = "Texture/3DMapSystem/CCS/Level1_CartoonFace.png", Name = "Cartoon Face"}));
Dock.Nodes:AddChild(CommonCtrl.TreeNode:new({Tooltip = "服装", Icon = "Texture/3DMapSystem/CCS/Level1_Inventory.png", Name = "Inventory"}));
Dock.Nodes:AddChild(CommonCtrl.TreeNode:new({Tooltip = "头发", Icon = "Texture/3DMapSystem/CCS/Level1_Hair.png", Name = "Hair"}));
Dock.Nodes:AddChild(CommonCtrl.TreeNode:new({Tooltip = "交友", Icon = "Texture/3DMapSystem/Profile/MyProfile_32.png", Name = "Friend Explorer"}));

-- init the dock user interface
function Dock.Init()
	-- Dock is aligned to the bottom of the screen. It's further divided into three areas
	
	-- left
	local _dock = ParaUI.CreateUIObject("container", "Dock", "_mb", 0, 0, 0, 75);
	_dock.background = "";
	_dock:AttachToRoot();
	
	-- middle icon count
	local nCount = Dock.Nodes:GetChildCount();
	local middleWidth = nCount * (32 + 8) - 8 + 32;
	
	-- left
	local _left = ParaUI.CreateUIObject();
	_left.background = "";
	_left:AttachToRoot();
	
	-- right
	local _right = ParaUI.CreateUIObject();
	_right.background = "";
	_right:AttachToRoot();
	
	-- middle
	local _middle = ParaUI.CreateUIObject("container", "DockMiddle", "_ctb", 0, 0, 0, 75);
	_middle.background = "";
	_middle:AttachToRoot();
	
	
		local left,top,width, height = 2,2, 48,48;
		_this = ParaUI.CreateUIObject("container", libName, "_mb", 0, 0, 0, 75);
		_this.background = "";
		_this.zorder = 5; -- make it stay on top. 
		_this:AttachToRoot();
		_parent = _this;
	
	-- left
	local _left = ParaUI.CreateUIObject();
	
	-- right
	local _right = ParaUI.CreateUIObject();
	
end