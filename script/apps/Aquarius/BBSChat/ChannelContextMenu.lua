--[[
Title: The content menu to be displayed when user clicks to change the current input channel.
Author(s): LiXizhi
Date: 2008/11/1
Desc: The content menu to be displayed when user clicks to change the current input channel.
It can switch to channels and commands. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/BBSChat/ChannelContextMenu.lua");
MyCompany.Aquarius.ChannelContextMenu.Show(bShow);
------------------------------------------------------------
]]

-- create class
local ChannelContextMenu = {
	name = "HelloChannelContextMenu",
};
commonlib.setfield("MyCompany.Aquarius.ChannelContextMenu", ChannelContextMenu);

-- show or hide task bar UI
function ChannelContextMenu.Show(bShow)
	local ctl = CommonCtrl.GetControl(ChannelContextMenu.name);
	if(ctl==nil)then
		NPL.load("(gl)script/ide/ContextMenu.lua");
		ctl = CommonCtrl.ContextMenu:new{
			name = ChannelContextMenu.name,
			width = 130,
			height = 250,
			--container_bg = "Texture/3DMapSystem/ContextMenu/BG2.png:8 8 8 8",
			container_bg = "Texture/3DMapSystem/ContextMenu/BG3.png:8 8 8 8",
			AutoPositionMode = "_lb",
			--DrawNodeHandler = Map3DSystem.UI.ContextMenu.DrawMenuItemHandler,
		};
		local node = ctl.RootNode;
		local subNode;
		-- channels
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "所有人", Name = "alluser", onclick = ChannelContextMenu.OnChangeChannel, Icon = "Texture/3DMapSystem/common/color_swatch.png"}));
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "世界留言", Name = "world", onclick = ChannelContextMenu.OnChangeChannel, Icon = "Texture/3DMapSystem/common/comment.png"}));
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "帮助频道", Name = "help", onclick = ChannelContextMenu.OnChangeChannel, Icon = "Texture/3DMapSystem/common/help_16.png"}));
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "聊天室", Name = "chatrooms", onclick = ChannelContextMenu.OnChangeChannel}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "交友", Name = "room_social", onclick = ChannelContextMenu.OnChangeChatRoom}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "创造世界", Name = "room_creation", onclick = ChannelContextMenu.OnChangeChatRoom}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "开发网", Name = "room_developer", onclick = ChannelContextMenu.OnChangeChatRoom}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "人才招聘", Name = "room_hire", onclick = ChannelContextMenu.OnChangeChatRoom}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "官方新闻", Name = "room_news", onclick = ChannelContextMenu.OnChangeChatRoom}));
		-- commands
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "命令行", Name = "command", Expanded=false});
			node:AddChild(CommonCtrl.TreeNode:new({Text = "常用", Name = "cmd_common", onclick = ChannelContextMenu.OnCommandMode}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "APP", Name = "cmd_app", onclick = ChannelContextMenu.OnCommandMode}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "Debug", Name = "cmd_debug", onclick = ChannelContextMenu.OnCommandMode}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "人物", Name = "cmd_char", onclick = ChannelContextMenu.OnCommandMode}));
	end
	
	ctl:Show(0, ParaUI.GetUIObject("root").height-27);
end

-- change to a given channel
function ChannelContextMenu.OnChangeChannel(treeNode)
	_guihelper.MessageBox(string.format("Command not available in this tech release: Channel:%s", treeNode.Text))
end

-- change to a given chat room
function ChannelContextMenu.OnChangeChatRoom(treeNode)
	_guihelper.MessageBox(string.format("Command not available in this tech release: Room:%s", treeNode.Text))
end

-- change to a given command mode
function ChannelContextMenu.OnCommandMode(treeNode)
	_guihelper.MessageBox(string.format("Command not available in this tech release: Command:%s", treeNode.Text))
end