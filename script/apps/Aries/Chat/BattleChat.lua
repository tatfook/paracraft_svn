--[[ obsoleted
Title: 
Author(s): zhangruofei
Date: 2010/07/19
Desc: 战斗聊天
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Chat/BattleChat.lua");
--MyCompany.Aries.Chat.BattleChat.Init();
MyCompany.Aries.Chat.BattleChat.ShowChat(true);
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Player/main.lua");
NPL.load("(gl)script/ide/Encoding.lua");
local Encoding = commonlib.gettable("commonlib.Encoding");
local BattleChat = commonlib.gettable("MyCompany.Aries.Chat.BattleChat");
local sentence_history = commonlib.gettable("MyCompany.Aries.BBSChat.sentence_history");

BattleChat.channels = {
	[1] = {name = "Channel_Say",	color = "000000", text = "1.当前", bShow = true, },
	[2] = {name = "Channel_World",	color = "0000FF", text = "2.本地", bShow = true, },
	[3] = {name = "Channel_Public", color = "FFFFFF", text = "3.综合", bShow = true, },
	[4] = {name = "Channel_Trade",	color = "FFD700", text = "4.交易", bShow = true, },
	[5] = {name = "Channel_Ads",	color = "FF0000", text = "5.广告", bShow = true, },
	[6] = {name = "Channel_Official", color = "FFFF00", text = "官方公告", bShow = true, },
};

BattleChat.CurrentChannelIndex = 1;
BattleChat.bActive= false;
BattleChat.last_show = 0;
BattleChat.last_hide = 0;

function BattleChat.Init()

	local _Panel = ParaUI.CreateUIObject("container", "BattleChat", "_lb", 70, -440, 355, 250);
	_Panel.background = "";
	_Panel.visible=false;
	_Panel.zorder = 1;
	_Panel:AttachToRoot();

	local _, __, screen_width, ___ = ParaUI.GetUIObject("root"):GetAbsPosition();

	local left = ( screen_width - 323 ) / 2;
	
	local _Panel0 = ParaUI.CreateUIObject("container", "BattleChat0", "_lb", left, -205, 355, 250);
	_Panel0.background = "";
	_Panel0.visible=false;
	_Panel0.zorder = 1;
	_Panel0:AttachToRoot();

	local _Upper = ParaUI.CreateUIObject("container", "BattleChatUp", "_lt", 0, 15, 323, 136);
	_Upper.background = "Texture/Aries/Chat/_bg2_32bits.png;0 0 323 136";
	_Upper.visible = true;
	_Upper.zorder = 2;
	_Panel0:AddChild( _Upper );

	local _Lower= ParaUI.CreateUIObject("container", "BattleChatDown", "_lt", 0, 151, 323, 34);
	_Lower.background = "Texture/Aries/Chat/_bg_32bits.png;0 0 323 34";
	_Lower.visible = true;
	_Lower.zorder = 3;
	_Panel0:AddChild( _Lower );

	NPL.load("(gl)script/ide/TreeView.lua");
	local ctl = CommonCtrl.GetControl("Aries_BattleChat_TreeView");
	if(ctl == nil) then
		ctl = CommonCtrl.TreeView:new{
			name = "Aries_BattleChat_TreeView",
			alignment = "_lt",
			left = 8,
			top = 20,
			width = 300,
			height = 100,
			parent = _Upper,
			container_bg = "",
			DefaultIndentation = 5,
			NoClipping = false;
			DefaultNodeHeight = 18,
			VerticalScrollBarStep = 18,
			VerticalScrollBarPageSize = 18 * 5,
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
				local subject;
				if(treeNode.user_name) then
					subject = string.format([[<pe:name nid='%s' value='%s' a_style="color:#eeddc4"/>]], treeNode.nid, Encoding.EncodeStr(treeNode.user_name));
				else
					subject = string.format([[<pe:name nid='%s' a_style="color:#eeddc4" />]], treeNode.nid);
				end
				local mcmlStr = string.format([[%s说:<div style='float:left;color:#eeddc4'>%s</div>]], subject, Encoding.EncodeStr(treeNode.content));
				if(mcmlStr ~= nil) then
					local textbuffer = "<div style='font-size:14px;;color:#eeddc4'>"..mcmlStr.."</div>";
					
					local xmlRoot = ParaXML.LuaXML_ParseString(textbuffer);
					if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
						
						local xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
						-- auto height fix: lxz 2009.10.31
						local myLayout = Map3DSystem.mcml_controls.layout:new();
						myLayout:reset(0, 0, nodeWidth, height);
						Map3DSystem.mcml_controls.create("bbs_lobby_1", xmlRoot, nil, _parent, 0, 0, nodeWidth, height,nil, myLayout);
						local usedW, usedH = myLayout:GetUsedSize()

						if(usedH>height) then
							return usedH;
						end
					end
				end

			end,
		};
	else
		ctl.parent = _Upper;
	end
	ctl:Show(true);

	local _edit = ParaUI.CreateUIObject("imeeditbox", "AriesBattleChatEdit", "_lt", 8, 5, 305, 25);
	_guihelper.SetFontColor(_edit, "#eeddc4");
	_edit.background = "";
	_edit.onkeyup = ";MyCompany.Aries.Chat.BattleChat.OnInput();";
	_Lower:AddChild(_edit);
--
	--local _btnSmiley = ParaUI.CreateUIObject("button", "AriesBattleChatSmiley", "_lt", 220, 5, 20, 21);
	--_btnSmiley.background = "Texture/Aries/Chat/ico1_32bits.png;0 0 20 21";
	--_btnSmiley.onclick = ";MyCompany.Aries.Chat.BattleChat.OnSmiley();";
	--_btnSmiley.tooltip = "表情";
	--_btnSmiley.animstyle = 23;
	--_Lower:AddChild(_btnSmiley);
--
	--local _btnQuickword = ParaUI.CreateUIObject("button", "AriesBattleChatQuickword", "_lt", 244, 5, 23, 21);
	--_btnQuickword.background = "Texture/Aries/Chat/ico2_32bits.png;0 0 23 21";
	--_btnQuickword.onclick = ";MyCompany.Aries.Chat.BattleChat.OnQuickword();";
	--_btnQuickword.tooltip = "快捷语言";
	--_btnQuickword.animstyle = 23;
	--_Lower:AddChild(_btnQuickword);
--
	--local _btnAction = ParaUI.CreateUIObject("button", "AriesBattleChatAction", "_lt", 271, 5, 18, 23);
	--_btnAction.background = "Texture/Aries/Chat/ico3_32bits.png;0 0 18 23";
	--_btnAction.onclick = ";MyCompany.Aries.Chat.BattleChat.OnAction();";
	--_btnAction.tooltip = "动作";
	--_btnAction.animstyle = 23;
	--_Lower:AddChild(_btnAction);
--
	--local _btnChannel = ParaUI.CreateUIObject("button", "AriesBattleChatChannel", "_lt", 293, 7, 24, 18);
	--_btnChannel.background = "Texture/Aries/Chat/closedial_32bits.png;0 0 24 18";
	--_btnChannel.onclick = ";MyCompany.Aries.Chat.BattleChat.OnChannel();";
	--_btnChannel.tooltip = "展开或收起聊天记录";
	--_btnChannel.animstyle = 23;
	--_Lower:AddChild(_btnChannel);
--

	local _btnShrink= ParaUI.CreateUIObject("button", "AriesBattleChatShrink", "_lt", 121, 0, 82, 29);
	_btnShrink.background = "Texture/Aries/Chat/arrow2_32bits.png;0 0 82 29";
	_btnShrink.onclick = ";MyCompany.Aries.Chat.BattleChat.Shrink();";
	_btnShrink.tooltip = "收起聊天记录";
	_btnShrink.animstyle = 0;
	_btnShrink.visible = true;
	_btnShrink.zorder = 4;
	_Panel0:AddChild(_btnShrink);

	local _btnExpand = ParaUI.CreateUIObject("button", "AriesBattleChatExpand", "_lt", 121, 135, 82, 29);
	_btnExpand.background = "Texture/Aries/Chat/arrow1_32bits.png;0 0 82 29";
	_btnExpand.onclick = ";MyCompany.Aries.Chat.BattleChat.Expand();";
	_btnExpand.tooltip = "打开聊天记录";
	_btnExpand.animstyle = 0;
	_btnExpand.visible = false;
	_btnExpand.zorder = 4;
	_Panel0:AddChild(_btnExpand);

	local _btnClose = ParaUI.CreateUIObject("button", "AriesBattleChatClose", "_lt", 323, 151, 32, 32);
	_btnClose.background = "Texture/Aries/Chat/_close_32bits.png;0 0 24 24";
	_btnClose.onclick = ";MyCompany.Aries.Chat.BattleChat.ShowChat();";
	_btnClose.tooltip = "关闭";
	_btnClose.animstyle = 0;
	_Panel0:AddChild(_btnClose);

	BattleChat.mytimer = BattleChat.mytimer or commonlib.Timer:new({callbackFunc = BattleChat.OnTimer})
end

function BattleChat.Shrink()
	local _Panel = ParaUI.GetUIObject("BattleChatUp");
	_Panel.visible = false;
	local _btn = ParaUI.GetUIObject("AriesBattleChatExpand");
	_btn.visible=true;
	_btn = ParaUI.GetUIObject("AriesBattleChatShrink");
	_btn.visible=false;
end

function BattleChat.Expand()
	local _Panel = ParaUI.GetUIObject("BattleChatUp");
	_Panel.visible = true;
	local _btn = ParaUI.GetUIObject("AriesBattleChatExpand");
	_btn.visible=false;
	_btn = ParaUI.GetUIObject("AriesBattleChatShrink");
	_btn.visible=true;
end

function BattleChat.OnChannel(bShow)
	local _Panel = ParaUI.GetUIObject("BattleChatUp");
	if(bShow == nil ) then
		bShow = not _Panel.visible;
	end
	
	local _btn = ParaUI.GetUIObject("AriesBattleChatChannel");

	if(_btn==nil) then return; end

	if(bShow ==true) then
		_btn.background = "Texture/Aries/Chat/closedial_32bits.png;0 0 24 18";
	else
		_btn.background = "Texture/Aries/Chat/opendial_32bits.png;0 0 24 18";
	end

	_Panel.visible=bShow;	
end

function BattleChat.OnSmiley(bShow, frommouseup)
	MyCompany.Aries.Desktop.Dock.OnClickSmiley(bShow);
end

function BattleChat.OnAction(bShow)
	local x,y,width, height = ParaUI.GetUIObject("BattleChat"):GetAbsPosition();

	local _mainWnd = ParaUI.GetUIObject("AriesAnimationSelector");
	
	if(_mainWnd:IsValid() == false) then
		if(bShow == false) then
			return;
		end
		
		_mainWnd = ParaUI.CreateUIObject("container", "AriesAnimationSelector", "_fi", 0,0,0,0);
		_mainWnd.background = "";
		_mainWnd.zorder = 1;
		_mainWnd:AttachToRoot();
		
		_mainWnd.onmouseup = ";MyCompany.Aries.Chat.BattleChat.OnAction(false);";
		
		--local _content = ParaUI.CreateUIObject("container", "content", "_ctb", 134, -46, 380, 183);
		local _content = ParaUI.CreateUIObject("container", "content", "_lt", x+227, y+45, 275, 177);
		_content.background = "";
		_mainWnd:AddChild(_content);
		
		BattleChat.contentPage_AnimationSelector = System.mcml.PageCtrl:new({url = "script/apps/Aries/Desktop/AnimationSelector.html"});
		BattleChat.contentPage_AnimationSelector:Create("AnimationSelector", _content, "_fi", 0, 0, 0, 0);
	else
		-- toggle visibility if bShow is nil
		if(bShow == nil) then
			bShow = not _mainWnd.visible;
		end
		if(BattleChat.contentPage_AnimationSelector) then
			BattleChat.contentPage_AnimationSelector:Init("script/apps/Aries/Desktop/AnimationSelector.html");
		end
		_mainWnd.visible = bShow;
	end
end

function BattleChat.OnInput()
	local _editbox = ParaUI.GetUIObject("AriesBattleChatEdit");
	if(_editbox:IsValid() == true) then
		local sentText = _editbox.text;
		if(string.len(sentText) > 120) then
			_editbox.text = string.sub(sentText, 1, 120);
			_editbox:LostFocus();
			_guihelper.MessageBox("你输入的文字太多了，请缩短一点吧");
		end
	end
	
	if(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER) then
		local _text = _editbox.text;

		MyCompany.Aries.Chat.BattleChat.SendMSG( _text );
		_editbox.text = "";
	elseif(virtual_key == Event_Mapping.EM_KEY_UP) then	
		local sentence = sentence_history:PreviousSentence()
		if(sentence) then
			_editbox.text = sentence;
		end
	elseif(virtual_key == Event_Mapping.EM_KEY_DOWN) then	
		local sentence = sentence_history:NextSentence()
		if(sentence) then
			_editbox.text = sentence;
		end
	end
end

function BattleChat.UpdateChannelName()
	local worldpath = ParaWorld.GetWorldDirectory();
	
	-- replace slash with underscore
	worldpath = string.gsub(worldpath, "/", "_");
	
	BattleChat.channels[1].name = "Channel_Say_"..worldpath;
	BattleChat.channels[2].name = "Channel_World_"..worldpath;
end

function BattleChat.ClearChannelMessges()
	NPL.load("(gl)script/ide/TreeView.lua");
	local ctl = CommonCtrl.GetControl("Aries_BattleChat_TreeView");
	if(ctl ~= nil) then
		ctl.RootNode:ClearAllChildren();
	end
end

-- scroll functions including Home, Up, Down and End
function BattleChat.StepHome()
	local ctl = CommonCtrl.GetControl("Aries_BattleChat_TreeView");
	if(ctl ~= nil) then
		-- dirty get first node, scroll to the page front
		local firstNode = ctl.RootNode.Nodes[1];
		ctl:Update(nil, firstNode);
	end
end

function BattleChat.StepUp()
	local ctl = CommonCtrl.GetControl("Aries_BattleChat_TreeView");
	if(ctl ~= nil) then
		ctl:ScrollByStep(-FixedLineHeight*3);
	end
end

function BattleChat.StepDown()
	local ctl = CommonCtrl.GetControl("Aries_BattleChat_TreeView");
	if(ctl ~= nil) then
		ctl:ScrollByStep(FixedLineHeight*3);
	end
end

function BattleChat.StepEnd()
	local ctl = CommonCtrl.GetControl("Aries_BattleChat_TreeView");
	if(ctl ~= nil) then
		ctl:Update(true);
	end
end

function BattleChat.ShowChat(bShow)
	local _Panel = ParaUI.GetUIObject("BattleChat0");
	if(bShow == nil ) then
		bShow = not _Panel.visible;
	end

	_Panel.visible=bShow;
end

-- enable battle chat
function BattleChat.Active(bActive)
	BattleChat.bActive = bActive;

	if(not bActive) then
		BattleChat.mytimer:Change();
		BattleChat.ShowChat(false);
	else
		BattleChat.mytimer:Change(30,30);
	end
end

function BattleChat.IsActive()
	return BattleChat.bActive;
end

-- use timer to check for enter key since user input is blocked during battle mode. 
function BattleChat.OnTimer()
	if(BattleChat.bActive) then
		if(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RETURN) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_NUMPADENTER)) then
			if( not BattleChat.IsShow()) then
				BattleChat.ShowChat(true);
			end
			-- always set the focus to the chat window, when the enter key is presed. 
			local _editbox = ParaUI.GetUIObject("AriesBattleChatEdit");
			if(_editbox:IsValid() == true) then
				_editbox:Focus();
			end
		end
	else
		BattleChat.mytimer:Change();
	end
end

-- Obsoleted: by LiXizhi 2011.3.27
function BattleChat.OnKeyDownEvent()
	if(BattleChat.bActive==true) then
		if( BattleChat.IsShow()) then
			--if(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RETURN)) then
				--local _editbox = ParaUI.GetUIObject("AriesBattleChatEdit");
				--local _text = _editbox.text;
--
				--if(_text=="") then
					--local curTime = ParaGlobal.timeGetTime();
--
					--if((curTime-BattleChat.last_hide) > 1000) then
						--BattleChat.ShowChat(false);
						--BattleChat.last_show = curTime;
					--end
				--end
			--end
		else
			if(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER) then
				local curTime = ParaGlobal.timeGetTime();
				--if((curTime-BattleChat.last_show) < 1000) then
					--return;
				--end
				BattleChat.ShowChat(true);
				BattleChat.last_hide = curTime;
			end
		end
	end
end

function BattleChat.Show(bShow)
	if(bShow==nil)then
		bShow=true;
	end
	if(bShow ==true) then
		NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/BattleQuickWord.lua");
		MyCompany.Aries.ChatSystem.BattleQuickWord.OnQuickword();
	end
end

function BattleChat.IsShow()
	local _Panel = ParaUI.GetUIObject("BattleChat0");
	return _Panel.visible;
end

function BattleChat.RecvText(nid, content, channel)

	if(not content) then return end

	if(string.find(content, "%[Aries%]") == 1) then
		local nid = string.match(content, "^%[Aries%]%[UserNicknameUpdate%]:(%d+)$");
		if(nid) then
			nid = tonumber(nid);
			BattleChat.RecvUserNicknameUpdate(nid);
		end
		local nid = string.match(content, "^%[Aries%]%[UserPopularityUpdate%]:(%d+)$");
		if(nid) then
			nid = tonumber(nid);
			BattleChat.RecvUserPopularityUpdate(nid);
		end
	else
		local channelIndex = channel or 1;
		local color = BattleChat.channels[channelIndex].color;
		local channelText = BattleChat.channels[channelIndex].text;
		local channel = BattleChat.channels[channelIndex];
		local user_name;
		
		local player;
		if(nid == nil) then
			-- current player
			player = MyCompany.Aries.Pet.GetRealPlayer();
			headon_speech.Speek(player.name, content, 5);
			user_name = System.User.NickName or "我";
		else
			-- some other player from network.
			nid = tostring(nid);
			player = MyCompany.Aries.Pet.GetUserCharacterObj(nid);
			
			-- display head on text only if the character is within 100 meters. 
			if(player:IsValid()) then
				headon_speech.Speek(player.name, content, 5);
			end
		end
		BattleChat.AppendText(nid,content, user_name, channelText, color)
	end
end

function BattleChat.AppendText(nid,content, user_name, channelText, color)
	if(not content) then return end
	
	-- By LiXizhi: this is FLAWED, either REST repeated called will be invoked and append dialog may be missing, also message may appear out of order. 
	-- fetch display name if not available. 
	--if(user_name == nil) then
		--nid = tostring(nid or System.User.nid);
		--paraworld.users.getInfo({nids = nid}, "AriesBattleChatUserName"..nid, function(msg)
			--if(msg and msg.users and msg.users[1]) then
				--local username = msg.users[1].nickname;
				--if(username) then
					--BattleChat.AppendText(nid, content, username, channelText, color);
				--end
			--end
		--end);
		--return;
	--end
	
	-- add to UI treeview. 
	local ctl = CommonCtrl.GetControl("Aries_BattleChat_TreeView");
	if(ctl == nil) then
		commonlib.applog("!!!!!!!!!!!!!!!error: empty channel treeview\n");
		return;
	end
	local rootNode = ctl.RootNode;
	
	-- only keep 500 recent messages
	if(rootNode:GetChildCount() > 500) then
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
	ctl:Update(true);
end

function BattleChat.SendUserNicknameUpdate()
	Map3DSystem.GSL_client:AddRealtimeMessage({name="chat", value="[Aries][UserNicknameUpdate]:"..System.App.profiles.ProfileManager.GetNID()});
end

function BattleChat.RecvUserNicknameUpdate(nid)
	if(nid) then
		-- auto get the userinfo
		local ProfileManager = System.App.profiles.ProfileManager;
		ProfileManager.GetUserInfo(nid, "BBSChatWnd.RecvUserNicknameUpdate", function()end, "access plus 0 day");
	end
end

function BattleChat.SendUserPopularityUpdate(nid)
	if(nid) then
		Map3DSystem.GSL_client:AddRealtimeMessage({name="chat", value="[Aries][UserPopularityUpdate]:"..nid});
	end
end

function BattleChat.RecvUserPopularityUpdate(nid)
	-- only update popularity for friends
	if(nid and (MyCompany.Aries.Friends.IsFriendInMemory(nid) or nid == System.App.profiles.ProfileManager.GetNID())) then
		-- auto get the userinfo
		local ProfileManager = System.App.profiles.ProfileManager;
		ProfileManager.GetUserInfo(nid, "BBSChatWnd.RecvUserPopularityUpdate", function()end, "access plus 0 day");
	end
end


function BattleChat.SendMSG(text)
	if(type(text) == "string" and text~="") then

		BattleChat.last_send_time = BattleChat.last_send_time or 0;
		local curTime = ParaGlobal.timeGetTime();
		if((curTime-BattleChat.last_send_time) < 3000) then
			LOG.warn("you are speaking too fast.");
			return;
		end
		BattleChat.last_send_time = curTime;

		text = MyCompany.Aries.Chat.BadWordFilter.FilterString(text);
		
		Map3DSystem.GSL_client:AddRealtimeMessage({name="chat", value=text})
		BattleChat.RecvText(nil, text);
	end	
end
