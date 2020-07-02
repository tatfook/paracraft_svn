--[[
Title: family chat window
Author(s): WangTian
Company: ParaEnging Co. & Taomee Inc.
Date: 2010/1/11

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Chat/FamilyChatWnd.lua");
MyCompany.Aries.Chat.FamilyChatWnd.Show(True);
MyCompany.Aries.Chat.FamilyChatWnd.RecvMSG(content);
MyCompany.Aries.Chat.FamilyChatWnd.SendMSG(content);
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Chat/BadWordFilter.lua");
local BadWordFilter = commonlib.gettable("MyCompany.Aries.Chat.BadWordFilter");
NPL.load("(gl)script/ide/Encoding.lua");
local Encoding = commonlib.gettable("commonlib.Encoding");
-- create class
local FamilyChatWnd = commonlib.gettable("MyCompany.Aries.Chat.FamilyChatWnd");
FamilyChatWnd.name = "AriesFamilyChat";

local Chat = commonlib.gettable("MyCompany.Aries.Chat");

NPL.load("(gl)script/apps/IMServer/IMserver_client.lua");
local JabberClientManager = commonlib.gettable("IMServer.JabberClientManager");

local bIMRoom = (JabberClientManager.type == "IMServer.JabberClientManager");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");

NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
-- text line height of a message. some fixed line height. 
local FixedLineHeight = 18;

-- invoked on each world load
function FamilyChatWnd.Init( bshow )
	if(bshow==nil)then
		bshow = true;
	end
	if(FamilyChatWnd.isInit ~= true) then
		-- validate the ui and treeview object
		FamilyChatWnd.Show(bshow);
		FamilyChatWnd.ToggleHide();
		FamilyChatWnd.isInit = true;
	end
end

-- whether group chat is blocked. 
function FamilyChatWnd.IsBlocked()
	return FamilyChatWnd.is_blocked;
end

-- enable/disable family chat. it will disconnect/connect to chat room. 
-- @param bBlock
-- @param text: text to send before we sign out the chat frame.
function FamilyChatWnd.BlockChat(bBlock, text)
	if(FamilyChatWnd.is_blocked == bBlock) then
		return;
	end
	if(bBlock) then
		-- text = text or "屏蔽聊天";
		BroadcastHelper.PushLabel({id="chat_tip", label = "你屏蔽了聊天", max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
		if(FamilyChatWnd.SendFamilyMSG(text)) then
			FamilyChatWnd.LeaveChatRoom();
		end
	else
		-- text = text or "取消屏蔽聊天";
		BroadcastHelper.PushLabel({id="chat_tip", label = "你取消屏蔽了聊天", max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
		-- sending a message will automatically connect if blocked. 
		FamilyChatWnd.SendFamilyMSG(text); 
	end
	FamilyChatWnd.is_blocked = bBlock;
end

function FamilyChatWnd.LeaveChatRoom()
	local Friends = MyCompany.Aries.Friends;
	local family_id = Friends.GetMyFamilyID();
	if(not family_id) then
		return;
	end
	if(bIMRoom) then
		local jc = FamilyChatWnd.GetJC();
		if(jc) then
			jc:LeaveRoom();
		end
	end
end

-- connect to my family chat room
function FamilyChatWnd.ConnectToMyFamilyChatRoom()
	if(FamilyChatWnd.is_blocked) then
		LOG.std(nil, "system", "FamilyChat", "ConnectToMyFamilyChatRoom ignored.")
		return
	end
	local Friends = MyCompany.Aries.Friends;
	local family_id = Friends.GetMyFamilyID();
	if(not family_id) then
		return;
	end
	
	if(bIMRoom) then
		local jc = FamilyChatWnd.GetJC();
		if(jc) then
			if(JabberClientManager.AddPublicFile) then
				-- add trusted file here in order for jc:activate to work. 
				JabberClientManager.AddPublicFile("script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupClient.lua", 1);
				JabberClientManager.AddPublicFile("script/kids/3DMapSystemUI/PENote/PENoteClient.lua", 2);
				JabberClientManager.AddPublicFile("script/apps/Aries/Mail/MailClient.lua", 3);
				JabberClientManager.AddPublicFile("script/apps/Aries/Family/FamilyManager.lua", 4);
			end
			
			jc:AddEventListener("JE_OnFamilyPresence", "MyCompany.Aries.Chat.FamilyChatWnd.JE_OnFamilyPresence()");
			jc:AddEventListener("JE_OnFamilyMessage", "MyCompany.Aries.Chat.FamilyChatWnd.JE_OnFamilyMessage()");
			
			jc:JoinRoom(family_id);
			
			log("IMServer_client: FamilyChatWnd.ConnectToMyFamilyChatRoom\n");
		else
			log("error: unable to ConnectToMyFamilyChatRoom because jc is not online. \n");
		end
	else
		NPL.load("(gl)script/apps/Aries/Chat/GSL_muc_client.lua");
		-- join an MUC room, currently any one can join 
		Chat.GSL_muc_client:JoinRoom(family_id);
		
		log("FamilyChatWnd.ConnectToMyFamilyChatRoom\n");
	end	
end

-- get the jabber client
function FamilyChatWnd.GetJC()
	if(FamilyChatWnd.jc) then
		return FamilyChatWnd.jc;
	else
		FamilyChatWnd.jc = Chat.GetConnectedClient();
		return FamilyChatWnd.jc;
	end
end

function FamilyChatWnd.JE_OnFamilyPresence()

	if(msg and msg.nid) then
		local nid = tostring(msg.nid);
		if(msg.presence == 0)then
			-- online
			FamilyChatWnd.MemberJoinChatRoom(nid)
		else
			-- offline
			FamilyChatWnd.MemberLeaveChatRoom(nid)
		end
	end
end

function FamilyChatWnd.JE_OnFamilyMessage()
	if(msg.from and msg.msg) then
		FamilyChatWnd.RecvMSG(tostring(msg.from), msg.msg or "");
	end	
end

-- leave my family chat room
function FamilyChatWnd.LeaveMyFamilyChatRoom()
	if(bIMRoom) then
		local jc = FamilyChatWnd.GetJC();
		if(jc) then
			jc:LeaveRoom();
		end
	else
		NPL.load("(gl)script/apps/Aries/Chat/GSL_muc_client.lua");
		-- reset the MUC room
		Chat.GSL_muc_client:Reset();
	end	
	log("FamilyChatWnd.LeaveMyFamilyChatRoom()\n")
end

-- show or hide task bar UI
function FamilyChatWnd.Show(bShow)

	local _this, _parent;
	local left,top,width,height;
	
	_this = ParaUI.GetUIObject(FamilyChatWnd.name);
	if(_this:IsValid())then
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	else
		if( bShow == false)then
			return;
		end
		
		local _BBSChatPanel = ParaUI.CreateUIObject("container", FamilyChatWnd.name, "lt", 190, 50, 640, 450);
		_BBSChatPanel.background = "Texture/Aries/Friends/chatwnd_bg_32bits.png;0 0 484 392:30 30 30 30";
		--_BBSChatPanel.fastrender = false;
		_BBSChatPanel.zorder = 1;
		_BBSChatPanel.candrag = true;
		_BBSChatPanel.ondragbegin = [[;ParaUI.AddDragReceiver("root");]];
		_BBSChatPanel:AttachToRoot();
		
		local _FamilyChatWnd = ParaUI.CreateUIObject("container", "FamilyChatWnd.name", "_fi", 30, 48, 280, 120);
		--_FamilyChatWnd.background = "Texture/Aries/mainbar.png;0 0 29 29: 8 25 8 3";
		_FamilyChatWnd.background = "Texture/Aries/Friends/chatwnd_input_32bits.png: 15 15 15 15";
		_FamilyChatWnd.zorder = -1; -- make it stay on bottom. 
		_BBSChatPanel:AddChild(_FamilyChatWnd);
		
		local _close = ParaUI.CreateUIObject("button", "FamilyChatWnd.name", "_rt", -48, -6, 54, 54);
		--_close.background = "Texture/Aries/mainbar.png;0 0 29 29: 8 25 8 3";
		_close.background = "Texture/Aries/Common/Close_Big_54_32bits.png;0 0 54 54";
		_close.onclick = ";MyCompany.Aries.Chat.FamilyChatWnd.ToggleHide();";
		_BBSChatPanel:AddChild(_close);
		
		-- channel text treeview
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.GetControl("Aries_FamilyPage_TreeView");
		if(ctl == nil) then
			ctl = CommonCtrl.TreeView:new{
				name = "Aries_FamilyPage_TreeView",
				alignment = "_fi",
				left = 4,
				top = 24,
				width = 4,
				height = 4,
				parent = _FamilyChatWnd,
				container_bg = "",
				DefaultIndentation = 5,
				NoClipping = false;
				DefaultNodeHeight = FixedLineHeight,
				VerticalScrollBarStep = FixedLineHeight,
				VerticalScrollBarPageSize = FixedLineHeight * 5,
				-- lxz: this prevent clipping text and renders faster
				NoClipping = false,
				HideVerticalScrollBar = false, -- true
				
				DrawNodeHandler = function (_parent, treeNode)
					if(_parent == nil or treeNode == nil) then
						return;
					end
					local _this;
					local height = 20; -- just big enough
					local nodeWidth = treeNode.TreeView.ClientWidth;
					local oldNodeHeight = treeNode:GetHeight();
					
					local mcmlNode;
					local mcmlStr;
					local content = Encoding.EncodeStr(treeNode.content);
					if(content) then	
						content = content:gsub("\n", "<br/>");
					end
					if(treeNode.user_name) then
						mcmlStr = string.format("<pe:name nid='%s' value='%s'/>说:<div style='float:left'>%s</div>", treeNode.nid, Encoding.EncodeStr(treeNode.user_name), content);
					else
						mcmlStr = string.format("<pe:name nid='%s'/>说:<div style='float:left'>%s</div>", treeNode.nid, content);
					end
					if(mcmlStr ~= nil) then
						local textbuffer = "<div style='font-size:14px;'>"..mcmlStr.."</div>";
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
		else
			ctl.parent = _FamilyChatWnd;
		end
		ctl:Show();
		
		local _title_text = ParaUI.CreateUIObject("text", "AriesFamilyChat_title_text", "_lt", 36, 24, 400, 26);
		_title_text.text = "与家族：家族名称（家族号）通话中";
		_BBSChatPanel:AddChild(_title_text);
		
		local _this = ParaUI.CreateUIObject("container", "WarningIcon", "_lt", 8, 6, 16, 16);
		_this.background = "Texture/Aries/Friends/ChatWnd_Exclaim.png";
		_FamilyChatWnd:AddChild(_this);
		_this = ParaUI.CreateUIObject("text", "WarningText", "_lt", 30, 6, 200, 24);
		_this.text = "请不要向任何人泄露你的密码哦";
		_this.font = System.DefaultFontFamily..";12;norm";
		_guihelper.SetFontColor(_this, "#ff009a");
		_FamilyChatWnd:AddChild(_this);
		
		local _inputBox = ParaUI.CreateUIObject("container", "InputBox", "_lb", 30, -110, 330, 90);
		_inputBox.background = "";
		_BBSChatPanel:AddChild(_inputBox);
		
		_this = ParaUI.CreateUIObject("container", "BG", "_fi", 0, 0, 0, 54);
		_this.background = "Texture/Aries/Friends/chatwnd_input_32bits.png: 15 15 15 15";
		_inputBox:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("imeeditbox", "AriesFamilyChatEdit", "_lt", 8, 6, 310, 26);
		_this.background = "";
		_this.onkeyup = ";MyCompany.Aries.Chat.FamilyChatWnd.OnKeyUp();";
		_inputBox:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Send", "_rb", -173, -45, 107, 37);
		_this.background = "Texture/Aries/Friends/ChatWnd_Send_32bits.png; 0 0 107 37";
		_this.onclick = ";MyCompany.Aries.Chat.FamilyChatWnd.SendInputMSG();";
		_inputBox:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "InputOption", "_rb", -65, -45, 60, 37);
		_this.background = "Texture/Aries/Friends/ChatWnd_SendOption_32bits.png; 0 0 60 37";
		_inputBox:AddChild(_this);
		
		local _FamilyMemberWnd = ParaUI.CreateUIObject("container", "_FamilyMemberWnd", "_lt", 370, 20, 237, 394);
		_FamilyMemberWnd.background = "";
		_BBSChatPanel:AddChild(_FamilyMemberWnd);
		
		-- create member mcml page
		FamilyChatWnd.memberlist_page = System.mcml.PageCtrl:new({url = "script/apps/Aries/Chat/FamilyMemberList.html"});
		FamilyChatWnd.memberlist_page:Create("FamilyChatWnd.Memberlist", _FamilyMemberWnd, "_fi", 0, 0, 0, 0);
		
		---- first hide the BBS chat
		--FamilyChatWnd.ToggleHide()
		
		---- init the timer
		--FamilyChatWnd.InitTimer()
	end
	
	-- update the treeview
	local ctl = CommonCtrl.GetControl("Aries_FamilyPage_TreeView");
	if(ctl ~= nil) then
		ctl:Show(true);
		ctl:Update(true);
	end
	
	-- update the window text
	FamilyChatWnd.UpdateWindowText();
	
	-- refresh the member list page
	FamilyChatWnd.memberlist_page:Init("script/apps/Aries/Chat/FamilyMemberList.html");
end

function FamilyChatWnd.UpdateWindowText()
	local _title = ParaUI.GetUIObject("AriesFamilyChat_title_text");
	if(_title:IsValid() == true) then
		local Friends = MyCompany.Aries.Friends;
		local family_name = Friends.GetMyFamilyName() or "";
		local family_id = Friends.GetMyFamilyID() or 0;
		_title.text = string.format("与家族：%s（%d）通话中", family_name, family_id);
	end
end

--local heartbeat_interval = 3000;
--local heartbeat_timeout = 15000;
--
--FamilyChatWnd.LastHeartbeat_Times = {};
--
---- send heart beat message in timer every heartbeat_interval
--function FamilyChatWnd.InitTimer()
	--FamilyMemberOnline_Timer = commonlib.Timer:new({callbackFunc = function()
		--FamilyChatWnd.SendMSG("[Aries][FamilyMemberHeartBeat]:"..System.App.profiles.ProfileManager.GetNID());
	--end});
	--FamilyMemberOnline_Timer:Change(0, heartbeat_interval);
--end

-- check if family member online in memory
-- @return if online
function FamilyChatWnd.IsFamilyMemberOnline(nid)
	-- myself
	if(nid == System.App.profiles.ProfileManager.GetNID()) then
		return true;
	end
	
	if(bIMRoom) then
		local jc = FamilyChatWnd.GetJC();
		if(jc) then
			return jc:IsGroupMemberOnline(nid)
		end	
	
	elseif(Chat.GSL_muc_client) then
		local all_users = Chat.GSL_muc_client:GetAllUsers();
		if(all_users) then
			local member_nid, _;
			for member_nid, _ in pairs(all_users) do
				if(tonumber(member_nid) == tonumber(nid)) then
					return true;
				end
			end
		end
	end
	return false;
	
	---- family member
	--if(FamilyChatWnd.LastHeartbeat_Times[nid]) then
		--if((ParaGlobal.GetGameTime() - FamilyChatWnd.LastHeartbeat_Times[nid]) < heartbeat_timeout) then
			--return true;
		--end
	--end
	--return false;
end

---- on receive heart beat message
--function FamilyChatWnd.OnHeartBeat(nid)
	--if(FamilyChatWnd.LastHeartbeat_Times[nid] == nil) then
		---- if the nid is first beat and the nid is not in the current family member list,
		---- it means the user is a newly joined user, force update the list
		--local Friends = MyCompany.Aries.Friends;
		--if(not Friends.IsMyFamilyMemberInMemory(nid)) then
			--Friends.GetMyFamilyInfo(function() end, "access plus 0 day");
		--end
	--end
	--FamilyChatWnd.LastHeartbeat_Times[nid] = ParaGlobal.GetGameTime();
--end

-- show or hide task bar UI
function FamilyChatWnd.IsShow()
	local _this = ParaUI.GetUIObject(FamilyChatWnd.name);
	if(_this:IsValid())then
		return _this.visible;
	else
		return false;
	end
end

function FamilyChatWnd.ToggleHide()
	local isShow = FamilyChatWnd.IsShow();
	if(isShow == false) then
		local _wnd = ParaUI.GetUIObject(FamilyChatWnd.name);
		_wnd.visible = true;
		local ctl = CommonCtrl.GetControl("Aries_FamilyPage_TreeView");
		if(ctl ~= nil) then
			ctl:Show(true);
			ctl:Update(true);
		end
		-- refresh the member list page
		FamilyChatWnd.memberlist_page:Init("script/apps/Aries/Chat/FamilyMemberList.html");
	elseif(isShow == true) then
		local _wnd = ParaUI.GetUIObject(FamilyChatWnd.name);
		_wnd.visible = false;
		local ctl = CommonCtrl.GetControl("Aries_FamilyPage_TreeView");
		if(ctl ~= nil) then
			--ctl:Show(false);
		end
	end
end

function FamilyChatWnd.OnKeyUp()
	local _editbox = ParaUI.GetUIObject("AriesFamilyChatEdit");
	if(_editbox:IsValid() == true) then
		local sentText = _editbox.text;
		if(string.len(sentText) > 120) then
			_editbox.text = string.sub(sentText, 1, 120);
			_editbox:LostFocus();
			_guihelper.MessageBox("你输入的文字太多了，请缩短一点吧");
		end
	end
	
	if(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER) then
		FamilyChatWnd.SendInputMSG();
	end
end

function FamilyChatWnd.SendInputMSG()
	local _editbox = ParaUI.GetUIObject("AriesFamilyChatEdit");
	if(_editbox:IsValid() == true) then
		local sentText = _editbox.text;
		FamilyChatWnd.SendFamilyMSG(sentText);
		_editbox.text = "";
	end
end


function FamilyChatWnd.ClearChannelMessges()
	NPL.load("(gl)script/ide/TreeView.lua");
	local ctl = CommonCtrl.GetControl("Aries_FamilyPage_TreeView");
	if(ctl ~= nil) then
		ctl.RootNode:ClearAllChildren();
	end
end

-- scroll functions including Home, Up, Down and End
function FamilyChatWnd.StepHome()
	local ctl = CommonCtrl.GetControl("Aries_FamilyPage_TreeView");
	if(ctl ~= nil) then
		-- dirty get first node, scroll to the page front
		local firstNode = ctl.RootNode.Nodes[1];
		ctl:Update(nil, firstNode);
	end
end

function FamilyChatWnd.StepUp()
	local ctl = CommonCtrl.GetControl("Aries_FamilyPage_TreeView");
	if(ctl ~= nil) then
		ctl:ScrollByStep(-FixedLineHeight*3);
	end
end

function FamilyChatWnd.StepDown()
	local ctl = CommonCtrl.GetControl("Aries_FamilyPage_TreeView");
	if(ctl ~= nil) then
		ctl:ScrollByStep(FixedLineHeight*3);
	end
end

function FamilyChatWnd.StepEnd()
	local ctl = CommonCtrl.GetControl("Aries_FamilyPage_TreeView");
	if(ctl ~= nil) then
		ctl:Update(true);
	end
end

-- This function is called by the GSL_client whenever it receives a message or when the current user sends out a message. 
-- @param nid: who sends the message. if nil, it is the current player 
-- @param content: chat dialog, it may be mcml string. 
-- @param channel: nil or the channel index. if nil, it is the default index 1
function FamilyChatWnd.AddDialog(nid, content, channel)
	if(not content) then return end
	
	--local Friends = MyCompany.Aries.Friends;
	--local family_id = Friends.GetMyFamilyID();
	--if(not family_id) then
		--return;
	--end
	
	if(string.find(content, "%[Aries%]") == 1) then
		-- special tag for family related update
		local nid = string.match(content, "^%[Aries%]%[FamilyUserNicknameUpdate%]:(%d+)$");
		if(nid) then
			nid = tonumber(nid);
			FamilyChatWnd.RecvFamilyUserNicknameUpdate(nid);
		end
		--local nid = string.match(content, "^%[Aries%]%[FamilyMemberHeartBeat%]:(%d+)$");
		--if(nid) then
			--nid = tonumber(nid);
			--FamilyChatWnd.OnHeartBeat(nid);
		--end
		
		--local nid = string.match(content, "^%[Aries%]%[UserPopularityUpdate%]:(%d+)$");
		--if(nid) then
			--nid = tonumber(nid);
			--FamilyChatWnd.RecvUserPopularityUpdate(nid);
		--end
	else
		local isVisible = FamilyChatWnd.IsShow()
		if(isVisible == false) then
			local commandName = "Profile.Aries.FamilyChatWnd";
			NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
			local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
			if(CommonClientService.IsKidsVersion())then
				MyCompany.Aries.Desktop.NotificationArea.AppendMSG({Name = commandName, commandName = commandName}, "FamilyChatMSGRootNode");
			end
			
		elseif(isVisible == true) then
			-- do nothing if family window is shown
		end
		-- directly append to the dialog treeview
		local user_name, channelText, color;
		FamilyChatWnd.AppendDialog(nid, content, user_name, channelText, color)
	end
end

-- append text to dialog UI. 
-- @param nid;
-- @param content: text string
-- @param user_name: the user name to be displayed in pe:name. if nil, we shall fetch by nid.  
-- @param channelText: the channel text string 
-- @param color: the text color 
function FamilyChatWnd.AppendDialog(nid, content, user_name, channelText, color)
	if(not content) then return end
	
	-- By LiXizhi: this is FLAWED, either REST repeated called will be invoked and append dialog may be missing, also message may appear out of order. 
	-- fetch display name if not available. 
	--if(user_name == nil) then
		--nid = tostring(nid or System.User.nid);
		--paraworld.users.getInfo({nids = nid}, "AriesFamilyUserName"..nid, function(msg)
			--if(msg and msg.users and msg.users[1]) then
				--local username = msg.users[1].nickname;
				--if(username) then
					--FamilyChatWnd.AppendDialog(nid, content, username, channelText, color);
				--end
			--end
		--end);
		--return;
	--end
	
	-- add to UI treeview. 
	local ctl = CommonCtrl.GetControl("Aries_FamilyPage_TreeView");
	if(ctl == nil) then
		commonlib.applog("error: empty family treeview\n");
		return;
	end
	local rootNode = ctl.RootNode;
	
	-- only keep 200 recent messages
	if(rootNode:GetChildCount() > 200) then
		rootNode:RemoveChildByIndex(1);
	end
	
	-- skip the smiley content
	if(not string.find(content, "<img style=")) then
		rootNode:AddChild(CommonCtrl.TreeNode:new({
				Name = "text", 
				nid = tostring(nid or System.User.nid), 
				user_name = user_name,
				content = content, 
				channelText = channelText, 
				color = color,
				Text = string.format("%s说:%s", tostring(user_name or nid), content),
			}));
	end
	
	-- scroll to the end of the treeview ONLY when the bbs channel is visible
	if(FamilyChatWnd.IsShow()) then
		FamilyChatWnd.StepEnd();
	end

	local msgdata = { ChannelIndex=ChatChannel.EnumChannels.Home,from=tostring(nid or System.User.nid), fromname=user_name, words=content, };
	ChatChannel.AppendChat( msgdata );
end

-- @return true if succed. it may fail if user is sending at a high frequency. 
function FamilyChatWnd.SendFamilyMSG(text)
	-- if user is sending a message, we will unblock it. 
	if(FamilyChatWnd.is_blocked) then
		FamilyChatWnd.is_blocked = nil;
		FamilyChatWnd.ConnectToMyFamilyChatRoom();
	end

	-- validate the text (length and filter sensitive word) and convert to mcml if needed. 
	if(type(text) == "string" and text~="") then
		text = Chat.BadWordFilter.FilterString(text);
		
		if(FamilyChatWnd.SendMSG(text)) then
			FamilyChatWnd.AddDialog(nil, text);
			return true;
		else
			return;
		end
	else
		return true;
	end	
end

function FamilyChatWnd.SendFamilyUserNicknameUpdate()
	FamilyChatWnd.SendMSG("[Aries][FamilyUserNicknameUpdate]:"..System.App.profiles.ProfileManager.GetNID());
end

function FamilyChatWnd.RecvFamilyUserNicknameUpdate(nid)
	if(nid) then
		-- auto get the userinfo
		local ProfileManager = System.App.profiles.ProfileManager;
		ProfileManager.GetUserInfo(nid, "FamilyChatWnd.RecvUserNicknameUpdate", function()end, "access plus 0 day");
	end
end

function FamilyChatWnd.SendFamilyDescUpdate()
	FamilyChatWnd.SendMSG("[Aries][SendFamilyDescUpdate]");
end

function FamilyChatWnd.RecvFamilyDescUpdate()
	-- update my family info for new desc
	local Friends = MyCompany.Aries.Friends;
	Friends.GetMyFamilyInfo(function() end, "access plus 0 day");
end

-- member join chat room
function FamilyChatWnd.MemberJoinChatRoom(nid)
	-- if the nid has joined the chat room and the nid is not in the current family member list,
	-- it means the user is a newly joined user, force update the family member list
	local Friends = MyCompany.Aries.Friends;
	if(not Friends.IsMyFamilyMemberInMemory(nid)) then
		Friends.GetMyFamilyInfo(function() end, "access plus 0 day");
	end
	local isShow = FamilyChatWnd.IsShow();
	if(isShow == true) then
		-- refresh the member list page
		FamilyChatWnd.memberlist_page:Init("script/apps/Aries/Chat/FamilyMemberList.html");
	end
end

-- member leave chat room
function FamilyChatWnd.MemberLeaveChatRoom(nid)
	local isShow = FamilyChatWnd.IsShow();
	if(isShow == true) then
		-- refresh the member list page
		FamilyChatWnd.memberlist_page:Init("script/apps/Aries/Chat/FamilyMemberList.html");
	end
end

-- receive a family message
function FamilyChatWnd.RecvMSG(nid, content)
	if(string.match(content, "^%[Aries%]%[SendFamilyDescUpdate%]$")) then
		-- this is a family desc update message from the admin
		FamilyChatWnd.RecvFamilyDescUpdate();
		return
	end
	
	if(System.options.version == "kids") then
		if(BadWordFilter.HasCheatingWord(content)) then
			content = (content or "").."\n【官方安全提示】如果聊天中有涉及财产的交易，请一定先核实好友身份；私人间交易发生纠纷，不受官方保护，切勿随意和陌生人交易"
		end
	end
	FamilyChatWnd.AddDialog(nid, content);
end

-- send a message 
function FamilyChatWnd.SendMSG(content)
	if(type(content) == "string") then
		content = string.gsub(content, "\n", "");
		
		if(bIMRoom) then
			local jc = FamilyChatWnd.GetJC();
			if(jc) then
				return jc:SendMucMessage(content);
			end
		else
			NPL.load("(gl)script/apps/Aries/Chat/GSL_muc_client.lua");
			return Chat.GSL_muc_client:SendMucMessage(content);
		end	
	end	
end