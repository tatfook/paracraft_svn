--[[
Title: multi-channel chat display window for ChatWnd.html
Author(s): zrf, refactored by lixizhi
Date: 2010/12/27
Desc:  additional channels can be specified in ChatWnd.channels and the mcml page.
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/BBSChat/ChatWnd.lua");
MyCompany.Aries.ChatWnd.AppendTeamChat(channels, nid, user_name, isvip, content, channelText, color)
-- send to channel 2
MyCompany.Aries.ChatWnd.AppendTeamChat({2}, nil, "test_name", nil, "hello world channel 2")
-- send to channel 1 and 2
MyCompany.Aries.ChatWnd.AppendTeamChat({1,2}, nil, "test_name", nil, "hello world channel 1 and 2")
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/Encoding.lua");

local ChatWnd = commonlib.gettable("MyCompany.Aries.ChatWnd");
local Encoding = commonlib.gettable("commonlib.Encoding");
local VIP = commonlib.gettable("MyCompany.Aries.VIP");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");

NPL.load("(gl)script/apps/Aries/Team/TeamMembersPage.lua");
local TeamMembersPage = commonlib.gettable("MyCompany.Aries.Team.TeamMembersPage");

-- the known channels: add additional channels here
ChatWnd.channels = {
	{name = "普通",	color = "000000", bShow = true, cont_name="ChatWnd_tvcon1", treeview_name="ChatWnd_CreateTreeView1_TreeView", tvWidth=262, tvHeight=182, },
	{name = "全部",	color = "0000ff", bShow = true, cont_name="ChatWnd_tvcon2", treeview_name="ChatWnd_CreateTreeView2_TreeView", tvWidth=262, tvHeight=182, },
	{name = "组队",	color = "0000ff", bShow = true, cont_name="ChatWnd_tvcon3", treeview_name="ChatWnd_CreateTreeView3_TreeView", tvWidth=262, tvHeight=182, },
};

-- the default channels. 
ChatWnd.default_channels = {1,2}

ChatWnd.curchannel = ChatWnd.curchannel or 1;

function ChatWnd.Init()
	ChatWnd.page = document:GetPageCtrl();

	if(ChatWnd.page:GetValue("bbschatwnd") ~= tostring(ChatWnd.curchannel))then
		ChatWnd.page:SetValue("bbschatwnd", tostring(ChatWnd.curchannel));
	end
end

function ChatWnd.RestorePage()
	if(ChatWnd.IsShow()) then
		ChatWnd.ShowPage()
	else
		ChatWnd.HidePage()
	end
end

-- show the page
function ChatWnd.ShowPage()
	local dockReservedHeight = commonlib.getfield("MyCompany.Aries.Desktop.Dock.ReservedHeight") or 40;
	
	if(not ChatWnd.bcreated)then
		ChatWnd.bcreated = true;
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/BBSChat/ChatWnd.html", 
			app_key = MyCompany.Aries.app.app_key, 
			name = "newChatWnd.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = false,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = false,
			click_through = true,
			zorder = -10,
			directPosition = true,
				align = "_ctb",
				x = -203,
				y = -dockReservedHeight-25,
				width = 316,
				height = 180,
		});
	else
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="newChatWnd.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				bShow = true,bDestroy = false,});		
	end
	ChatWnd.is_shown = true;

	-- this will refresh the current channel if needed. 
	ChatWnd.RefreshTreeView();
end

-- close the page. 
function ChatWnd.HidePage()
	if(ChatWnd.page)then
		ChatWnd.page:CloseWindow();
	end
	ChatWnd.is_shown = false;
end

-- user selected a new channel
function ChatWnd.OnClickRadio(value)
	-- remember the channel, and select the new channel
	value = tonumber(value) or 1;
	if(ChatWnd.curchannel ~= value) then
		ChatWnd.curchannel = value;
		-- now refresh the page. 
		ChatWnd.page:Refresh(0);
	end
end

-- public: clear channel messages
-- @param channels: to which channel to append the message. it can be an array of channel index. such as {1,2}. if nil, it means to sent to the default channels. 
function ChatWnd.ClearChannelMessges(channels)
	channels = channels or ChatWnd.default_channels;
	local _, channel_index
	for _, channel_index in ipairs(channels) do
		local channel = ChatWnd.channels[channel_index];
		if(channel) then
			local ctl = ChatWnd.GetTreeView(channel);
			if(ctl and ctl.RootNode and ctl.RootNode:GetChildCount()>0) then
				ctl.RootNode:ClearAllChildren();
				channel.need_update = true;
			end
		end
	end
end

-- public: append team message to any of the given channel
-- @param nid: who sent this message. 
-- @param content: the string content of the message. this may be translated to mcml in future. 
-- @param channels: to which channel to append the message. it can be an array of channel index. such as {1,2}. if nil, it means to sent to the default channels. 
function ChatWnd.AppendTeamChat(channels, nid, user_name, isvip, content, channelText, color)
	-- fetch display name if not available. 
	
	--commonlib.echo("!!:AppendTeamChat 0");
	--commonlib.echo(channels);
	if(user_name == nil or isvip == nil) then
		nid = nid or Map3DSystem.App.profiles.ProfileManager.GetNID();
		Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nid, "AppendTeamChat_UserNameUpdate", function(msg)
			if(msg and msg.users and msg.users[1]) then
				local username = msg.users[1].nickname;
				if(username) then
					if(nid == Map3DSystem.App.profiles.ProfileManager.GetNID()) then
						isvip = VIP.IsVIPAndActivated();
						ChatWnd.AppendTeamChat(channels, nid, username, isvip, content,channelText, color);
					else
						local myInfo = ProfileManager.GetUserInfoInMemory(nid);
						if(myInfo and myInfo.energy) then
							isvip = myInfo.energy > 0;
						else
							isvip = false;
						end
						ChatWnd.AppendTeamChat(channels, nid, username, isvip, content,channelText, color);
					end
				end
			end
		end, "access plus 1 hour");
		return;
	end

	channels = channels or ChatWnd.default_channels;
	--commonlib.echo("!!:AppendTeamChat 1");
	--commonlib.echo(channels);
	local _, channel_index
	for _, channel_index in ipairs(channels) do
		local channel = ChatWnd.channels[channel_index];
		if(channel) then
			ChatWnd.AppendChatMessage(channel, nid, user_name, isvip, content, channelText, color);
		else
			LOG.std(nil, "warn", "ChatWnd", "unknown channel %s", tostring(channel_index));
		end
	end
end

-- append chat message to a given channel
-- @param channel: the channel table. 
function ChatWnd.AppendChatMessage(channel, nid, user_name, isvip, content, channelText, color)
	channel = channel or ChatWnd.channels[1];
	--commonlib.echo("!!:AppendChatMessage 0");
	--commonlib.echo(channel);
	if(not content) then return end
	
	local ctl = ChatWnd.GetTreeView(channel);
	--commonlib.echo("!!:AppendChatMessage 1");
	
	local rootNode = ctl.RootNode;
	
	-- only keep 200 recent messages
	if(rootNode:GetChildCount() > 200) then
		rootNode:RemoveChildByIndex(1);
	end
	
	--commonlib.echo("!!:AppendChatMessage 2");
	-- skip the smiley content
	if(not string.find(content, "<img style=")) then
		--commonlib.echo("!!:AppendChatMessage 3");

		rootNode:AddChild(CommonCtrl.TreeNode:new({
				Name = "text", 
				nid = tostring(nid or System.User.nid), 
				user_name = user_name or "",
				isvip = isvip,
				content = content, 
				channelText = channelText, 
				color = color,
				Text = format("%s说:%s", user_name or "", content),
			}));
		channel.need_update = true;
		ChatWnd.RefreshTreeView(channel);
	end
end

-- get the current channel index. 
function ChatWnd.GetCurrentChannel()
	return ChatWnd.channels[ChatWnd.curchannel or 1];
end

-- get current channel index
function ChatWnd.GetCurChannelIndex()
	return ChatWnd.curchannel or 1;
end

-- refresh the treeview control UI of the given channel
-- @note: we will only update the UI if the window is shown and the associated channel needs update. 
-- @param channel: the channel table. if nil, it means the current channel
function ChatWnd.RefreshTreeView(channel)
	channel = channel or ChatWnd.GetCurrentChannel();
	if(channel) then
		-- only show for current channel
		if(ChatWnd.page and ChatWnd.is_shown and (ChatWnd.GetCurrentChannel()==channel) and channel.need_update) then
			local ctl = ChatWnd.GetTreeView(channel);
			if(ctl) then
				-- tricky: this will tells us whether the treeview's container UI is created. 
				local parent = ParaUI.GetUIObject(channel.cont_name);
				if(parent:IsValid())then
					ctl.parent = parent;
					ctl:Update(true);
					channel.need_update = false;
				end
			end
		end
	end
end

-- this is the render callback function in pe:custom 
function ChatWnd.CreateTreeView(param, mcmlNode)
	local nIndex = tonumber(mcmlNode:GetAttributeWithCode("channel_index"));
	local channel = ChatWnd.channels[nIndex];
	if(not channel) then
		log("error: please specify a valid channel for ChatWnd\n");
		return 
	end
    local _this = ParaUI.CreateUIObject("container", channel.cont_name, "_lt", param.left,param.top,param.width,param.height);
	_this.background = "";
	_this:GetAttributeObject():SetField("ClickThrough", true);
	param.parent:AddChild(_this);

	local ctl = ChatWnd.GetTreeView(channel, _this, param.width, param.height);
	-- the second parameter will scroll tot the last element. 
	ctl:Show(true, nil,  true);
end


-- get the treeview control (may not bind to UI)
-- @param channel: the channel table.
-- @param parent: in case UI is specified.
-- @param width: in case UI is specified, this is the treeview width
-- @param height: in case UI is specified, this is the treeview height
function ChatWnd.GetTreeView(channel, parent, width, height)
	if(not channel) then return end
	local ctl = CommonCtrl.GetControl(channel.treeview_name);
	if(not ctl)then
		width = width or channel.tvWidth;
		height = height or channel.tvHeight;

		ctl = CommonCtrl.TreeView:new{
			name = channel.treeview_name,
			alignment = "_lt",
			left = 0,
			top = 0,
			width = width,
			height = height,
			parent = parent,
			container_bg = nil,
			DefaultIndentation = 5,
			NoClipping = false,
			ClickThrough = true,
			DefaultNodeHeight = 22,
			VerticalScrollBarStep = 22,
			VerticalScrollBarPageSize = 22 * 5,
			-- lxz: this prevent clipping text and renders faster
			NoClipping = false,
			HideVerticalScrollBar = false, -- true
				
			DrawNodeHandler = function (_parent, treeNode)
				if(_parent == nil or treeNode == nil) then
					return;
				end
				local _this;
				local height = 22; -- just big enough
				local nodeWidth = treeNode.TreeView.ClientWidth;
				local oldNodeHeight = treeNode:GetHeight();
					
				local mcmlNode;
				local subject;
				if(MyCompany.Aries.Scene.IsGMAccount(treeNode.nid)) then
					subject = format([[<pe:name nid='%s' value='%s' a_style="color:#9f002d"/>]], treeNode.nid, Encoding.EncodeStr(treeNode.user_name));
				else
					subject = format([[<pe:name nid='%s' value='%s'/>]], treeNode.nid, Encoding.EncodeStr(treeNode.user_name));
				end
				local vip_sign = "";
				if(treeNode.isvip) then
					vip_sign = [[<img src="Texture/Aries/Friends/MagicStarSmall_32bits.png; 0 0 22 22" style="width:22px;height:22px;margin-right:2px;"/>]];
				end
				local mcmlStr = format([[%s%s说:<div style='float:left'>%s</div>]], vip_sign, subject, Encoding.EncodeStr(treeNode.content));
				if(mcmlStr ~= nil) then
					local textbuffer = "<div style='font-size:12px;'>"..mcmlStr.."</div>";
					--textbuffer = ParaMisc.EncodingConvert("", "HTML", textbuffer);

					local xmlRoot = ParaXML.LuaXML_ParseString(textbuffer);
					if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
						local xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
							
						-- auto height fix: lxz 2009.10.31
						local myLayout = Map3DSystem.mcml_controls.layout:new();
						myLayout:reset(0, 0, nodeWidth, height);
						Map3DSystem.mcml_controls.create("bbs_lobby", xmlRoot, nil, _parent, 0, 0, nodeWidth, height,nil, myLayout);
						local usedW, usedH = myLayout:GetUsedSize()
						if(usedH>height) then
							return usedH;
						end
					end
				end
			end,
		};
	elseif(parent)then
		ctl.parent = parent;
	end
	return ctl;
end

function ChatWnd.IsShow()
	if(ChatWnd.is_shown==nil)then
		return false;
	else
		return ChatWnd.is_shown;
	end
end