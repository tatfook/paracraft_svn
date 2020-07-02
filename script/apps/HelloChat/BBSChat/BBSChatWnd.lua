--[[
Title: The BBS Chat window on the left bottom
Author(s): lxz for Andy
Date: 2008/10/26
Desc: It show/hide the chat window on the left bottom. the chat window displays chat message logs and is able to switch 
channel displays. 
Implementation: this can be done either in pure NPL, or pure MCML.
for NPL: we simply code everything in npl.
for MCML: we can create <pe:channel-wnd /> which automatically renders latest content of a given channel.

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/HelloChat/BBSChat/BBSChatWnd.lua");
MyCompany.HelloChat.ChatWnd.Show(bShow);
------------------------------------------------------------
]]

-- create class
local ChatWnd = {
	name = "HelloBBSChat",
};

-- text line height of a message. some fixed line height. 
local FixedLineHeight = 18; 

commonlib.setfield("MyCompany.HelloChat.ChatWnd", ChatWnd);

-- show or hide task bar UI
function ChatWnd.Show(bShow)
	local _this, _parent;
	local left,top,width,height;
	
	_this = ParaUI.GetUIObject(ChatWnd.name);
	if(_this:IsValid())then
		if(bShow==nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	else
		if( bShow == false)then
			return;
		end
		local left,top,width, height = 0, 0, 350,27;
		_this = ParaUI.CreateUIObject("container", ChatWnd.name, "_lb", 2, -190, 348, 165);
		_this.background = "Texture/HelloChat/mainbar.png;0 0 29 29: 8 25 8 3";
		_this.zorder = 5; -- make it stay on top. 
		_this.onframemove = ";MyCompany.HelloChat.ChatWnd.DoFramemove();";
		_this:AttachToRoot();
		_parent = _this;
		
		-- close button
		_this = ParaUI.CreateUIObject("button", "close", "_rt", -20, 4, 16, 16);
		_this.background = "Texture/HelloChat/mainbar.png;77 12 16 16";
		_this.onclick = ";MyCompany.HelloChat.ChatWnd.Show();";
		_parent:AddChild(_this);
		
		-- separator
		_this = ParaUI.CreateUIObject("button", "separator", "_lt", 60, 0, 4, 21);
		_this.background = "Texture/HelloChat/mainbar.png;34 7 4 21";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "separator", "_lt", 124, 0, 4, 21);
		_this.background = "Texture/HelloChat/mainbar.png;34 7 4 21";
		_parent:AddChild(_this);
		
		-- channel selector
		_this = ParaUI.CreateUIObject("button", "PublicChannel", "_lt", 0, 0, 60, 21);
		_this.background = "";
		_this.text = "公共频道";
		_guihelper.SetFontColor(_this, "255 255 255");
		_this.onclick = ";MyCompany.HelloChat.ChatWnd.ChangeFocusChannel(\"Channel_Public\");"
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "HelpChannel", "_lt", 64, 0, 60, 21);
		_this.background = "";
		_this.text = "帮助频道";
		_this.onclick = ";MyCompany.HelloChat.ChatWnd.ChangeFocusChannel(\"Channel_Help\");"
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "WorldChannel", "_lt", 128, 0, 60, 21);
		_this.background = "";
		_this.text = "世界频道";
		_this.onclick = ";MyCompany.HelloChat.ChatWnd.ChangeFocusChannel(\"Channel_World\");"
		_parent:AddChild(_this);
		
		System.App.Chat.ChannelManager.ChangeFocusChannel("Channel_Public");
		
		-- channel text treeview
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.GetControl("HelloChat_ChannelPage_TreeView");
		if(ctl == nil) then
			ctl = CommonCtrl.TreeView:new{
				name = "HelloChat_ChannelPage_TreeView",
				alignment = "_fi",
				left = 2,
				top = 24,
				width = 2,
				height = 2,
				parent = _parent,
				container_bg = "",
				DefaultIndentation = 5,
				DefaultNodeHeight = FixedLineHeight,
				VerticalScrollBarStep = FixedLineHeight,
				VerticalScrollBarPageSize = FixedLineHeight * 5,
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
		end
		ctl:Show();
				
	end
end

function ChatWnd.ChangeFocusChannel(channelName)
	local _parent = ParaUI.GetUIObject(ChatWnd.name);
	if(_parent:IsValid() == true) then
		if(channelName == "Channel_Public") then
			local _this = _parent:GetChild("PublicChannel");
			_guihelper.SetFontColor(_this, "255 255 255");
			_this = _parent:GetChild("HelpChannel");
			_guihelper.SetFontColor(_this, "0 0 0");
			_this = _parent:GetChild("WorldChannel");
			_guihelper.SetFontColor(_this, "0 0 0");
		elseif(channelName == "Channel_Help") then
			local _this = _parent:GetChild("PublicChannel");
			_guihelper.SetFontColor(_this, "0 0 0");
			_this = _parent:GetChild("HelpChannel");
			_guihelper.SetFontColor(_this, "255 255 255");
			_this = _parent:GetChild("WorldChannel");
			_guihelper.SetFontColor(_this, "0 0 0");
		elseif(channelName == "Channel_World") then
			local _this = _parent:GetChild("PublicChannel");
			_guihelper.SetFontColor(_this, "0 0 0");
			_this = _parent:GetChild("HelpChannel");
			_guihelper.SetFontColor(_this, "0 0 0");
			_this = _parent:GetChild("WorldChannel");
			_guihelper.SetFontColor(_this, "255 255 255");
		end
	end
	
	System.App.Chat.ChannelManager.ChangeFocusChannel(channelName);
end

local _elapsedtime = 0;
ChatWnd.FirstShowUpdateLatency = 0.05;

-- on init show the current avatar in pe:avatar
function ChatWnd.DoFramemove()
	
	if(ChatWnd.isCurrentShowUpdated == false) then
		_elapsedtime = _elapsedtime + deltatime;
		if(_elapsedtime >= ChatWnd.FirstShowUpdateLatency) then
			ChatWnd.isCurrentShowUpdated = true;
		else
			return;
		end
	end
	
	-- update the messages
	System.App.Chat.ChannelManager.UpdateMessages()
	
	-- update the treeviews
	local ctl = CommonCtrl.GetControl("HelloChat_ChannelPage_TreeView");
	if(ctl ~= nil) then
		
		local CurrentFocusChannelName = System.App.Chat.ChannelManager.CurrentFocusChannelName;
		local channelRootNode = System.App.Chat.ChannelManager.GetChannelRootTreeNode()
		channelRootNode = channelRootNode[CurrentFocusChannelName];
				
		if(channelRootNode ~= nil) then
			ctl.RootNode = channelRootNode;
			ctl.RootNode.TreeView = ctl;
			
			-- assign each node with the treeview
			local nCount = ctl.RootNode:GetChildCount();
			local i;
			
			if(nCount == 0) then
				--return;
			end
			for i = 1, nCount do
				local node = ctl.RootNode:GetChild(i);
				if(node.TreeView == nil) then
					node.TreeView = ctl;
				end
			end
			
			-- update only on new message appended
			if(ChatWnd.LastMSGCount ~= channelRootNode:GetChildCount()
				or ChatWnd.LastFocusChannelName ~= CurrentFocusChannelName) then
				--ctl:Update();
				-- owner draw node handler will update the node height
				
				ctl:Update(true);
				ctl:Update(true);
			end
			
			ChatWnd.LastMSGCount = ctl.RootNode:GetChildCount();
			ChatWnd.LastFocusChannelName = CurrentFocusChannelName;
		end
	end
end

function ChatWnd.SendMSG(text)
	local username;
	local profile = System.App.profiles.ProfileManager.GetProfile();
	
	if(profile) then
		username = profile:getFullName() or L"anonymous";
	end
	
	NPL.load("(gl)script/ide/XPath.lua");
	-- encode the content string
	local sendText = commonlib.XPath.XMLEncodeString(text);
	
	-- original implementation
	--local mcmlStr = string.format("<pe:name uid='%s' a_class='a_inverse' value='%s'/>:<span %s>%s</span>",
		--Map3DSystem.App.profiles.ProfileManager.GetUserID() or "", username, QuickChatPage.TextStyle or "", sendText);
	
	local worldpath = ParaWorld.GetWorldDirectory();
	local textColor;
	
	local currentFocusChannelName = System.App.Chat.ChannelManager.CurrentFocusChannelName;
	if(currentFocusChannelName == "Channel_Public") then
		textColor = System.App.Chat.ChannelManager.TextColors["Public"];
	elseif(currentFocusChannelName == "Channel_Help") then
		textColor = System.App.Chat.ChannelManager.TextColors["Help"];
	elseif(currentFocusChannelName == "Channel_World_"..worldpath) then
		textColor = System.App.Chat.ChannelManager.TextColors["World"];
	end
	
	local textStyle = string.format("style='color:#%s'", textColor);
	
	local mcmlStr = string.format("<pe:name uid='%s' a_%s value='%s'/>:<span %s>%s</span>",
		System.App.profiles.ProfileManager.GetUserID() or "", textStyle or "", username, 
		textStyle or "", sendText);
	
	System.App.Chat.ChannelManager.PostMessage(mcmlStr);
end



--ChatWnd.channels = {
	--[1] = {Name = "Channel_Public", Text = "公共频道", channelNode = CommonCtrl.TreeNode:new({Name = "Channel_Public", })},
	--[2] = {Name = "Channel_Help", Text = "帮助频道", channelNode = CommonCtrl.TreeNode:new({Name = "Channel_Help", })},
	--[2] = {Name = "Channel_World", Text = "世界频道", channelNode = CommonCtrl.TreeNode:new({Name = "Channel_World", })},
--};
--
---- text color of the default channel messages
--ChatWnd.TextColors = {
		--["Public"] = "FAEBD7",
		--["Help"] = "ADD8E6",
		--["World"] = "32CD32",
		--["Chat"] = "FFC0CB",
	--};
--
--function ChatWnd.UpdateMessages()
--
	--local k, v;
	--for k, v in ipairs(ChatWnd.channels) do
		---- update messages from each channel
		--local channelName = v.Name;
		--local channelText = v.Text;
		--local channelNode = v.channelNode;
		--local msg = {
			--sessionkey = System.User.sessionkey,
			--channel = channelName,
			--afterDate = v.NextGetMessageDate,
			--pageindex = 0,
			--pagesize = 50,
		--};
		--
		--if(not System.User.IsAuthenticated) then
			--_elapsedtime = 0;
			--isProcessing = false;
			--return;
		--end
		--
		--paraworld.lobby.GetBBS(msg, "HelloChat_GetLobbyBBSChannelMessages"..channelName, function(msg)
			----log("getlobbymessage "..channelName.."\n");
			----log(commonlib.serialize(msg));
			--
			--_elapsedtime = 0;
			--isProcessing = false;
			--
			--if(msg) then
				--if(msg.errorcode) then
					--log("GetBBS error on channel:"..channelName..", errorcode:"..msg.errorcode.."\n")
					--return;
				--end
				--
				--local channelName = msg.channel;
				--
				---- append messages to the channel node
				--local i, n;
				--for i, n in ipairs(msg.msgs) do
					--local color = "808080";
					--if(channelName == "Channel_Public") then
						--color = ChatWnd.TextColors["Public"];
					--elseif(channelName == "Channel_Help") then
						--color = ChatWnd.TextColors["Help"];
					--elseif(string.find(channelName, "Channel_World")) then
						--color = ChatWnd.TextColors["World"];
					--end
					--local contentPlusChannelName = string.format("<span style='color:#%s;' >[%s]</span>%s",
						--color, channelText, n.content);
					--
					--channelNode:AddChild(CommonCtrl.TreeNode:new({
						--date = n.date, 
						--uid = n.uid, 
						--content = contentPlusChannelName, 
						--}));
					---- update the NextGetMessageDate
					--v.NextGetMessageDate = n.date;
				--end
			--end
		--end);
	--end
--end