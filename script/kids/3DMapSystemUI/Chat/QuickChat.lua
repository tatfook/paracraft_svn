--[[
Title: Quick chat window
Author(s): WangTian
Date: 2008/6/16
Desc: Quick chat window is shown on the bottom of the screen area, right above the application toolbar.
		Quich chat window is trigger by hitting enter button if not focusing on any editbox.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Chat/QuickChat.lua");
------------------------------------------------------------
]]

--NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

commonlib.echo("\n script/kids/3DMapSystemUI/Chat/QuickChat.lua loaded\n")

local L = CommonCtrl.Locale("IDE");

local QuickChat = commonlib.gettable("Map3DSystem.App.Chat.QuickChat");


-- Show the Quick chat window
function QuickChat.ShowMainWnd(bShow)
	local _app = Map3DSystem.App.CCS.app._app;
	local _wnd = _app:FindWindow("QuickChatWnd") or _app:RegisterWindow("QuickChatWnd", nil, QuickChat.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
	if(frame ~= nil) then
		frame:Show2(bShow);
	else
		local sampleWindowsParam = {
			wnd = _wnd, -- a CommonCtrl.os.window object
			
			isShowTitleBar = false, -- default show title bar
			isShowToolboxBar = false, -- default hide title bar
			isShowStatusBar = false, -- default show status bar
			
			initialPosX = 0,
			initialPosY = 32, -- added by LXZ, 2008.8.16. to give it a lift on left bottom. 
			
			initialWidth = 512, -- initial width of the window client area
			initialHeight = 100, -- initial height of the window client area
			
			style = CommonCtrl.WindowFrame.DefaultPanel,
			alignment = "LeftBottom", -- Free|Left|Right|Bottom
			ShowUICallback = QuickChat.Show,
		};
		
		frame = CommonCtrl.WindowFrame:new2(sampleWindowsParam);
		frame:Show2(bShow);
	end
	
	-- bind the BBS with the quick chat window
	NPL.load("(gl)script/kids/3DMapSystemUI/Chat/LobbyBBSChannelPage.lua");
	Map3DSystem.App.Chat.LobbyBBSChannelPage.Show(bShow);
	
	-- update the quick chat window
	QuickChat.UpdateContact()
end

function QuickChat.UpdateContact()
	NPL.load("(gl)script/ide/dropdownlistbox.lua");
	local ctl = CommonCtrl.GetControl("priorityContactDropdownlistbox");
	if(ctl ~= nil and ctl:GetText() == "最近和你联系的人") then
		-- talk to the latest contact person
		QuickChat.mode = "LastestContact";
		
		local LatestReceiveMSG = Map3DSystem.App.Chat.LatestReceiveMSG;
		if(LatestReceiveMSG ~= nil) then
			local lastContactJID = LatestReceiveMSG.from;
			commonlib.log(lastContactJID);
			QuickChat.CurrentJID = lastContactJID;
			--LatestReceiveMSG.subject;
			--LatestReceiveMSG.body;
			local _quickChat = ParaUI.GetUIObject(QuickChat.container_name);
			if(_quickChat:IsValid() == true) then
				local name = Map3DSystem.App.Chat.GetNameFromJID(lastContactJID);
				_quickChat:GetChild("ContactTo").text = "对 ".. name.." 说:";
				_quickChat:GetChild("InputMessage").enabled = true;
				_guihelper.SetUIColor(_quickChat:GetChild("InputMessage"), "255 255 255 255");
				_quickChat:GetChild("InputMessage"):Focus();
				_quickChat:GetChild("send").enabled = true;
			end
		else
			local _quickChat = ParaUI.GetUIObject(QuickChat.container_name);
			if(_quickChat:IsValid() == true) then
				_quickChat:GetChild("ContactTo").text = "最近没有人和你联系";
				_quickChat:GetChild("InputMessage").enabled = false;
				_guihelper.SetUIColor(_quickChat:GetChild("InputMessage"), "255 255 255 150");
				_quickChat:GetChild("send").enabled = false;
			end
		end
	elseif(ctl ~= nil and ctl:GetText() == "频道中的人") then
		-- talk to channel if any
		QuickChat.mode = "Channel";
		
		local _quickChat = ParaUI.GetUIObject(QuickChat.container_name);
		if(_quickChat:IsValid() == true) then
			local channelText = Map3DSystem.App.Chat.ChannelManager.GetFocusChannelText() or Map3DSystem.App.Chat.ChannelManager.CurrentFocusChannelName;
			_quickChat:GetChild("ContactTo").text = "对频道\""..channelText.."\"中的人说:";
			_quickChat:GetChild("InputMessage").enabled = true;
			_guihelper.SetUIColor(_quickChat:GetChild("InputMessage"), "255 255 255 255");
			_quickChat:GetChild("send").enabled = true;
		end
	end	
end

-- Message Processor of QuickChat window control
function QuickChat.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		log("WM_SIZE not handled in Map3DSystem.App.Chat.QuickChat.MSGProc()\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		log("WM_CLOSE not handled in Map3DSystem.App.Chat.QuickChat.MSGProc()\n");
		-- bind the BBS with the quick chat window
		NPL.load("(gl)script/kids/3DMapSystemUI/Chat/LobbyBBSChannelPage.lua");
		Map3DSystem.App.Chat.LobbyBBSChannelPage.Show(false);
	end
end

QuickChat.container_name = "QuickChat_Main";

-- show QuickChat in the parent window
-- @param bShow: boolean to show or hide. if nil, it will toggle current setting.
-- @param _parent: parent window inside which the content is displayed. it can be nil.
-- @param parentWindow: parent os window object, parent window for sending messages
function QuickChat.Show(bShow, _parent, parentWindow)
	QuickChat.parentWindow = parentWindow;
	
	local _this;
	_this = ParaUI.GetUIObject(QuickChat.container_name);
	
	if(_this:IsValid() == false) then
		if(bShow == false) then
			return;
		end
		
		if(_parent == nil) then
			_this = ParaUI.CreateUIObject("container", QuickChat.container_name, "_lt", 0, 50, 300, 500);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", QuickChat.container_name, "_fi", 0, 0, 0, 0);
			_this.background = "";
			_parent:AddChild(_this);
			
			--_BG = ParaUI.CreateUIObject("container", "Creator_Main_BG", "_fi", -60, 0, 0, 0);
			--_BG.background = "Texture/3DMapSystem/Desktop/RightPanel/RightPanel.png: 105 1 8 1";
			--_BG.enabled = false;
			--_this:AddChild(_BG);
		end
		
		local _parent = _this;
		
		_this = ParaUI.CreateUIObject("container", "chaticon", "_lt", 10, -30, 48, 48);
		_this.background = "Texture/3DMapSystem/Chat/AppIcon_64.png";
		_this.enable = false;
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("text", "ISay", "_lt", 240, 20, 150, 32);
		--_this.background = "";
		_this.text = "优先发消息给:";
		_guihelper.SetFontColor(_this, "255 255 255");
		_parent:AddChild(_this);
		
		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "priorityContactDropdownlistbox",
			alignment = "_lt",
			left = 320,
			top = 17,
			width = 120,
			height = 24,
			dropdownheight = 72,
 			parent = _parent.parent, -- show this control on the parent's parent or it may be disabled
			text = "频道中的人",
			items = {
				--"离你最近的人", 
				"最近和你联系的人", 
				"频道中的人", 
				--"当前选中的人", 
				--"世界中的所有人",
				},
			onselect = function ()
				QuickChat.UpdateContact();
			end,
		};
		ctl:Show();
		
		QuickChat.mode = "LastestContact";
		
		--_this = ParaUI.CreateUIObject("button", "Invite", "_lt", 260, 17, 48, 24);
		----_this.background = "";
		--_this.text = "邀请";
		--_parent:AddChild(_this);
		--
		--_this = ParaUI.CreateUIObject("button", "Map", "_lt", 315, 17, 48, 24);
		----_this.background = "";
		--_this.text = "地图";
		--_parent:AddChild(_this);
		--
		--_this = ParaUI.CreateUIObject("button", "Trade", "_lt", 370, 17, 48, 24);
		----_this.background = "";
		--_this.text = "交易";
		--_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Close", "_rt", -32, 8, 16, 16);
		--_this.background = "Texture/3DMapSystem/Chat/png-0652.png";
		_this.background = "Texture/3DMapSystem/common/title_bar_restore_press.png";
		
		_this.tooltip = "隐藏(Enter键可以切换)"
		--_this.onclick = [[;ParaUI.GetUIObject("EasyTalkPanel").visible = false;]];
		_this.onclick = ";Map3DSystem.App.Chat.QuickChat.ShowMainWnd(false);";
		_parent:AddChild(_this);
		
		
		_this = ParaUI.CreateUIObject("text", "ContactTo", "_lt", 20, 20, 200, 32);
		--_this.background = "";
		_this.text = "对......说:";
		_guihelper.SetFontColor(_this, "255 255 255");
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("imeeditbox", "InputMessage", "_lt", 20, 45, 420, 24);
		--_this.background = "";
		_this.onchange = ";Map3DSystem.App.Chat.QuickChat.OnInputTextChange();";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "send", "_lt", 445, 45, 48, 24);
		--_this.background = "";
		_this.text = "发送";
		_this.onclick = ";Map3DSystem.App.Chat.QuickChat.SendMSG();";
		_parent:AddChild(_this);
		
		--_this = ParaUI.CreateUIObject("button", "action", "_rt", -60, 50, 48, 24);
		----_this.background = "";
		--_this.text = "动作";
		--_parent:AddChild(_this);
		
		---- manually set the tab to facial panel
		--Main2.ChangeToCCSTab(1);
		
		--_guihelper.SetContainerEnabled(_parent, false);
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end
end

function QuickChat.OnInputTextChange()
	if(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER) then
		QuickChat.SendMSG();
	end
end

function QuickChat.SendMSG()
	local JID = QuickChat.CurrentJID;
	local _quickChat = ParaUI.GetUIObject(QuickChat.container_name);
	if(_quickChat:IsValid() == true) then
		local sendText = _quickChat:GetChild("InputMessage").text;
		if(sendText ~= "") then
			_quickChat:GetChild("InputMessage").text = "";
			
			if(QuickChat.mode == "LastestContact" and JID ~= nil) then
				-- send the message to the last contact
				local jc = Map3DSystem.App.Chat.GetConnectedClient();
				if(jc ~= nil) then
					jc:Message(JID, sendText);
				end
				
				local _chatWnd = Map3DSystem.App.Chat.ChatWnd:CreateGetWnd({[1] = JID});
				_chatWnd:AppendMSG(Map3DSystem.App.Chat.UserJID, sendText);
				
				-- close quick chat window
				QuickChat.ShowMainWnd(false);
			elseif(QuickChat.mode == "Channel") then
				-- send the message to channel
				--log("Send message "..sendText.." to Channel\n")
				
				--log("sendlobbymessage\n");
				
				local username;
				local profile = Map3DSystem.App.profiles.ProfileManager.GetProfile();
				
				if(profile) then
					username = profile:getFullName() or L"anonymous";
				end
				
				local mcmlStr = string.format([[<div style="float:left;color:#A0A0A0"><pe:name uid='%s' value='%s' style="color:#A0A0A0"/> says: </div><div style="float:left;color:#DDDDDD">%s</div>]], 
					Map3DSystem.App.profiles.ProfileManager.GetUserID() or "", username, sendText);
					
				
				local channelName = Map3DSystem.App.Chat.ChannelManager.CurrentFocusChannelName;
				local msg = {
					sessionkey = Map3DSystem.User.sessionkey,
					channel = channelName,
					content = mcmlStr,
				};
				paraworld.lobby.PostBBS(msg, "PostLobbyBBSChannelMessage", function(msg)
					--log(commonlib.serialize(msg));
				end);
				
				---- close quick chat window
				--QuickChat.ShowMainWnd(false);
			end
		else
			-- close the quick chat window
			QuickChat.ShowMainWnd(false);
		end
	end
end
