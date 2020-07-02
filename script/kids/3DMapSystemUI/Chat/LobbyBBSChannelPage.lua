--[[
Title: Lobby BBS channel page
Author(s): WangTian
Date: 2008/6/23
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Chat/LobbyBBSChannelPage.lua");
Map3DSystem.App.Chat.LobbyBBSChannelPage.Show()
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemUI/Chat/ChannelManager.lua");

-- create class
local LobbyBBSChannelPage = {};
commonlib.setfield("Map3DSystem.App.Chat.LobbyBBSChannelPage", LobbyBBSChannelPage);

-- text line height of a message. some fixed line height. 
local FixedLineHeight = 18; 

-- on init show the current avatar in pe:avatar
function LobbyBBSChannelPage.OnInit()
	local self = document:GetPageCtrl();
	
	Map3DSystem.App.Chat.ChannelManager.UpdateMessages()
	
	LobbyBBSChannelPage.isCurrentShowUpdated = false;
	
	LobbyBBSChannelPage.LastMSGCount = nil;
	LobbyBBSChannelPage.LastFocusChannelName = nil;
	
	---- set a timer to update the BBS channel information
	--NPL.SetTimer(LobbyBBSChannelPage.TimerID, 0.3, ";Map3DSystem.App.Chat.LobbyBBSChannelPage.DoTimer();");
end

-- open using external system web browser, such as ie
function LobbyBBSChannelPage.OnClose()
	log("LobbyBBSChannelPage.OnClose()\n")
	ParaUI.Destroy(LobbyBBSChannelPage.Name);
	
	-- delete the treeview
	CommonCtrl.DeleteControl("LobbyBBSChannelMessages_TreeView");
	
	---- kill the timer to update the BBS channel information
	--NPL.KillTimer(LobbyBBSChannelPage.TimerID);
end

-- update 0.05 second after first shown
local _elapsedtime = 0;
LobbyBBSChannelPage.FirstShowUpdateLatency = 0.05;

-- on init show the current avatar in pe:avatar
function LobbyBBSChannelPage.DoFramemove()
	
	if(LobbyBBSChannelPage.isCurrentShowUpdated == false) then
		_elapsedtime = _elapsedtime + deltatime;
		if(_elapsedtime >= LobbyBBSChannelPage.FirstShowUpdateLatency) then
			LobbyBBSChannelPage.isCurrentShowUpdated = true;
		else
			return;
		end
	end
	
	
	-- update the messages
	Map3DSystem.App.Chat.ChannelManager.UpdateMessages()
	
	-- update the treeviews
	local ctl = CommonCtrl.GetControl("LobbyBBSChannelMessages_TreeView");
	if(ctl ~= nil) then
		local CurrentFocusChannelName = Map3DSystem.App.Chat.ChannelManager.CurrentFocusChannelName;
		local channelRootNode = Map3DSystem.App.Chat.ChannelManager.GetChannelRootTreeNode()
		channelRootNode = channelRootNode[CurrentFocusChannelName];
		
		if(channelRootNode ~= nil) then
			ctl.RootNode = channelRootNode;
			ctl.RootNode.TreeView = ctl;
			
			-- assign each node with the treeview
			local nCount = ctl.RootNode:GetChildCount();
			local i;
			if(nCount == 0) then
				return;
			end
			for i = 1, nCount do
				local node = ctl.RootNode:GetChild(i);
				if(node.TreeView == nil) then
					node.TreeView = ctl;
				end
			end
			
			-- update only on new message appended
			if(LobbyBBSChannelPage.LastMSGCount ~= channelRootNode:GetChildCount()
				or LobbyBBSChannelPage.LastFocusChannelName ~= CurrentFocusChannelName) then
				--ctl:Update();
				-- owner draw node handler will update the node height
				ctl:Update(true);
				ctl:Update(true);
			end
			
			LobbyBBSChannelPage.LastMSGCount = ctl.RootNode:GetChildCount();
			LobbyBBSChannelPage.LastFocusChannelName = CurrentFocusChannelName;
		end
	end
end

LobbyBBSChannelPage.Name = "LobbyBBSChannelPage_Main";

-- show the lobby BBS channel page
function LobbyBBSChannelPage.Show(bShow)
	local _this, _parent;
	_this = ParaUI.GetUIObject(LobbyBBSChannelPage.Name);
	
	if(not _this:IsValid()) then
		if(bShow == false) then return end
		bShow = true;
		
		local x, y;
		local width, height = 512, 256;
		
		local name = Map3DSystem.App.Chat.QuickChat.container_name;
		local _quickChat = ParaUI.GetUIObject(name);
		if(_quickChat:IsValid() == true) then
			local q_x, q_y, q_width, q_height = _quickChat:GetAbsPosition();
			local _, _, s_width, s_height = ParaUI.GetUIObject("root"):GetAbsPosition();
			x = q_x;
			y = - (s_height - q_y + height);
			width = q_width;
			height = height;
		else
			log("Try to show the LobbyBBSChannelPage before the QuickChat window\n");
			return;
		end
		
		_this = ParaUI.CreateUIObject("container", LobbyBBSChannelPage.Name, "_lb", x, y, width, height);
		_this.background = "Texture/3DMapSystem/Desktop/BottomPanel/Panel2.png: 8 8 8 8";
		_this:AttachToRoot();
		_this.zorder = -1;
		_parent = _this;
		
		if(LobbyBBSChannelPage.MyPage == nil) then
			LobbyBBSChannelPage.MyPage = Map3DSystem.mcml.PageCtrl:new({url="script/kids/3DMapSystemUI/Chat/LobbyBBSChannelPage.html"});
		end	
		LobbyBBSChannelPage.MyPage:Create("LobbyBBSChannelPage", _parent, "_fi", 0, 0, 0, 0);
		_this = _parent;
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		if(not bShow) then
			LobbyBBSChannelPage.OnClose()
		end
	end
end


function LobbyBBSChannelPage.DS_ChannelsInfo(index)
	local channels = Map3DSystem.App.Chat.ChannelManager.channels;
	
	local t = {};
	local i, v;
	for i, v in ipairs(channels) do
		local isChecked;
		if(v.Name == Map3DSystem.App.Chat.ChannelManager.CurrentFocusChannelName) then
			isChecked = true;
		else
			isChecked = false;
		end
		table.insert(t, {channelName = v.Name, channelText = v.Text, isChecked = isChecked});
	end
	
    if(index == nil) then
        return table.getn(t);
    else
		return t[index];
	end
end

function LobbyBBSChannelPage.ChangeChannel(channelName)
	Map3DSystem.App.Chat.ChannelManager.ChangeFocusChannel(channelName);
	-- update the quick chat contact
	Map3DSystem.App.Chat.QuickChatPage.UpdateContact();
end

function LobbyBBSChannelPage.OnChannelCheckBoxClicked(value, mcmlNode)
    local channelName = value;
    LobbyBBSChannelPage.ChangeChannel(channelName);
end


LobbyBBSChannelPage.Name_MSGs = "LobbyBBSChannelPage_MSGs";

-- @param params: a table containing
function LobbyBBSChannelPage.ShowBBS(bShow, _parent, params)
	params = params or {};
	params.alignment = params.alignment or "_fi"
	params.left = params.left or 0;
	params.top = params.top or 0;
	params.width = params.width or 0;
	params.height = params.height or 0;
	
	local _this;
	_this = ParaUI.GetUIObject(LobbyBBSChannelPage.Name_MSGs);
	
	if(not _this:IsValid()) then
		if(bShow == false) then return end
		bShow = true;
		
		if(_parent == nil or _parent:IsValid() == false) then
			log("Invalid parent container in Map3DSystem.UI.Chat.LobbyBBSChannelPage.ShowBBS\n");
			return;
		end
		
		_this = ParaUI.CreateUIObject("container", LobbyBBSChannelPage.Name_MSGs, params.alignment, params.left, params.top, params.width, params.height);
		_this.background = "";
		_this.onframemove = ";Map3DSystem.App.Chat.LobbyBBSChannelPage.DoFramemove();";
		_parent:AddChild(_this);
		--_this.zorder = -1;
		_parent = _this;
		
		
		local _channelTab = ParaUI.CreateUIObject("container", "ChannelTab", "_mt", 0, 0, 0, 32);
		_channelTab.background = "";
		_parent:AddChild(_channelTab);
		
		--local channels = Map3DSystem.App.Chat.ChannelManager.channels;
		--local k, v;
		--for k, v in ipairs(channels) do
			--local _tab = ParaUI.CreateUIObject("button", v.name, "_lt", (k-1)*64, 0, 64, 32);
			--_tab.background = "";
			--_tab.text = v.Text;
			--_guihelper.SetFontColor(_tab, "#FFFFFF");
			--_tab.onclick = string.format(";Map3DSystem.App.Chat.LobbyBBSChannelPage.ChangeChannel(%q);", v.Name);
			--_channelTab:AddChild(_tab);
		--end
		
		NPL.load("(gl)script/ide/TreeView.lua");
		local tabPagesNode = CommonCtrl.TreeNode:new({Name = "ChannelPage_TabControlRootNode"});
		tabPagesNode:AddChild(CommonCtrl.TreeNode:new({
			ShowUICallback = function(bShow, _parent, __) 
				local _this;
				_this = ParaUI.GetUIObject("ChannelPage_TabControl_PAGE");
				
				if(not _this:IsValid()) then
					if(bShow == false) then return end
					bShow = true;
					
					_this = ParaUI.CreateUIObject("container", "ChannelPage_TabControl_PAGE", "_fi", 0, 0, 0, 0);
					_this.background = "";
					_parent:AddChild(_this);
					_parent = _this;
					
					_this = ParaUI.CreateUIObject("container", "ChannelPage_TabControl_PAGE", "_fi", 4, 4, 4, 4);
					_this.background = "";
					-- _this.fastrender = false; -- This is not needed? lixizhi 2008.12.4
					_parent:AddChild(_this);
					_parent = _this;
					
					NPL.load("(gl)script/ide/TreeView.lua");
					local ctl = CommonCtrl.TreeView:new{
						name = "LobbyBBSChannelMessages_TreeView",
						alignment = "_fi",
						left = 2,
						top = 8,
						width = 0,
						height = 8,
						parent = _parent,
						container_bg = "",
						DefaultIndentation = 5,
						DefaultNodeHeight = FixedLineHeight,
						VerticalScrollBarStep = FixedLineHeight,
						VerticalScrollBarPageSize = FixedLineHeight*5,
						-- lxz: this prevent clipping text and renders faster
						NoClipping = true,
						HideVerticalScrollBar = true,
						DrawNodeHandler = function (_parent, treeNode)
							if(_parent == nil or treeNode == nil) then
								return;
							end
							local _this;
							local height = 50; -- just big enough since we are not clipping anyway
							local nodeWidth = 380; -- just big enough since we are not clipping anyway
							
							local mcmlStr = treeNode.content;
							local mcmlNode;
							if(mcmlStr ~= nil) then
								local textbuffer = "<p>"..mcmlStr.."</p>";
								--textbuffer = ParaMisc.EncodingConvert("", "HTML", textbuffer);
								local xmlRoot = ParaXML.LuaXML_ParseString(textbuffer);
								if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
									local xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
									mcmlNode = xmlRoot[1];
									mcmlNode:SetAttribute("style", "color:#C8E3F1")
									
									local myLayout = Map3DSystem.mcml_controls.layout:new();
									myLayout:reset(0, 0, nodeWidth, height);
									Map3DSystem.mcml_controls.create("bbs_lobby", mcmlNode, nil, _parent, 0, 0, nodeWidth, height, nil, myLayout);
									
									local _, usedHeight = myLayout:GetUsedSize();
									treeNode.NodeHeight = usedHeight - 6;
								end
							end
							treeNode.TreeView = ctl;
						end,
					};
					ctl:Show();
				else
					if(bShow == nil) then
						bShow = not _this.visible;
					end
					if(not bShow) then
						LobbyBBSChannelPage.OnClose()
					end
				end
			end,
			}));
		
		local channels = Map3DSystem.App.Chat.ChannelManager.channels;
		local i;
		for i = 2, table.getn(channels) do
			tabPagesNode:AddChild(CommonCtrl.TreeNode:new({RedirectIndex = 1}));
		end
		
		NPL.load("(gl)script/ide/TabControl.lua");
		local ctl = CommonCtrl.TabControl:new{
				name = "ChannelPage_TabControl",
				parent = _parent,
				background = "",
				pagebackground = "Texture/3DMapSystem/Chat/message_bg.png;0 8 16 8:7 0 7 7";
				alignment = "_fi",
				wnd = nil,
				left = 0,
				top = 0,
				width = 0,
				height = 0,
				zorder = 0,
				
				TabAlignment = "Top", -- Left|Right|Top|Bottom, Top if nil
				TabPages = tabPagesNode, -- CommonCtrl.TreeNode object, collection of tab pages
				TabHeadOwnerDraw = function(_parent, tabControl) 
						local _head = ParaUI.CreateUIObject("button", "Item", "_fi", 0, 0, 0, 0);
						_head.background = "";
						_head.enabled = false;
						_parent:AddChild(_head);
					end, --function(_parent, tabControl) end, -- area between top/left border and the first item
				TabTailOwnerDraw = function(_parent, tabControl) 
						local _tail = ParaUI.CreateUIObject("button", "Item", "_fi", 0, 0, 0, 0);
						_tail.background = "";
						_tail.enabled = false;
						_parent:AddChild(_tail);
					end, --function(_parent, tabControl) end, -- area between the last item and buttom/right border
				TabStartOffset = 16, -- start of the tabs from the border
				TabItemOwnerDraw = function(_parent, index, bSelected, tabControl) 
						local _item = ParaUI.CreateUIObject("button", "Item", "_fi", 0, 0, 0, 0);
						if(bSelected == true) then
							_item.background = "Texture/3DMapSystem/Chat/message_bg.png;0 0 16 8:7 7 7 0";
						else
							_item.background = "";
						end
						_item.text = Map3DSystem.App.Chat.ChannelManager.channels[index].Text;
						_item.onclick = string.format(";CommonCtrl.TabControl.OnClickTab(%q, %s);", tabControl.name, index);
						_parent:AddChild(_item);
					end,
				TabItemWidth = 64, -- width of each tab item
				TabItemHeight = 32, -- height of each tab item
				MaxTabNum = 10, -- maximum number of the tabcontrol, pager required when tab number exceeds the maximum
				OnSelectedIndexChanged = function(fromIndex, toIndex)
					local name = Map3DSystem.App.Chat.ChannelManager.channels[toIndex].Name;
					Map3DSystem.App.Chat.LobbyBBSChannelPage.ChangeChannel(name);
				end,
			};
		ctl:Show(true);
		
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		if(not bShow) then
			LobbyBBSChannelPage.OnClose()
		end
	end
end

-- onclick the four control button in the channel page
function Map3DSystem.App.Chat.LobbyBBSChannelPage.ChatOption()
	NPL.load("(gl)script/ide/ContextMenu.lua");
	local ctl = CommonCtrl.GetControl("ContextMenuChatOption");
	if(ctl == nil)then
		ctl = CommonCtrl.ContextMenu:new{
			name = "ContextMenuChatOption",
			width = 150,
			height = 100,
			--container_bg = "Texture/3DMapSystem/Desktop/ExtensionMenu.png:8 8 8 8",
			container_bg = "Texture/3DMapSystem/ContextMenu/BG2.png:8 8 8 8",
			onclick = function (node, param1)
					if(node.Name ~= nil) then
						local _input = ParaUI.GetUIObject(Map3DSystem.App.Chat.QuickChatPage.input_name);
						if(_input:IsValid() == true) then
							_input.text = node.Name;
						end
						Map3DSystem.App.Chat.QuickChatPage.OnSpace()
					end
				end
			--container_bg = "Texture/tooltip_text.PNG",
		};
		local node = ctl.RootNode;
		node:AddChild(CommonCtrl.TreeNode:new({Text = "/p 公共频道", Name = "/p "}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "/h 帮助频道", Name = "/h "}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "/w 世界频道", Name = "/w "}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "/r 回复最近联系人", Name = "/r "}));
	end	

	ctl:Show(nil, nil, nil);
end

function Map3DSystem.App.Chat.LobbyBBSChannelPage.PageUp()
	local ctl = CommonCtrl.GetControl("LobbyBBSChannelMessages_TreeView");
	if(ctl ~= nil) then
		ctl:ScrollByStep(-FixedLineHeight*3);
	end
end

function Map3DSystem.App.Chat.LobbyBBSChannelPage.PageDown()
	local ctl = CommonCtrl.GetControl("LobbyBBSChannelMessages_TreeView");
	if(ctl ~= nil) then
		ctl:ScrollByStep(FixedLineHeight*3);
	end
end

function Map3DSystem.App.Chat.LobbyBBSChannelPage.PageEnd()
	local ctl = CommonCtrl.GetControl("LobbyBBSChannelMessages_TreeView");
	if(ctl ~= nil) then
		ctl:Update(true);
	end
end
