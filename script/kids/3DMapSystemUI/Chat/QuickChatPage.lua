--[[
Title: Quick chat page
Author(s): WangTian
Date: 2008/6/26
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Chat/QuickChatPage.lua");
Map3DSystem.App.Chat.QuickChatPage....()
-------------------------------------------------------

NOTE: predefines channels are public, help and local world.
	Below is a listing of the options contained in the Chat Button menu and their corresponding chat commands: 
	World Channel /w
	Public Channel /p
	Help Channel /h
	
	Say /s
	Reply /r
	Tell /t
	Yell /y
	Whisper /w
]]

NPL.load("(gl)script/kids/3DMapSystemUI/Chat/ChannelManager.lua");

local L = CommonCtrl.Locale("IDE");

-- create class
local QuickChatPage = commonlib.gettable("Map3DSystem.App.Chat.QuickChatPage");

local page;

-- text style to use like "style='color:#ff0000'", please note to use single quotation mark.
QuickChatPage.TextStyle = nil;

-- on init 
function QuickChatPage.OnInit()
	page = document:GetPageCtrl();
end

-- close quick chat
function QuickChatPage.OnClose()
	
	Map3DSystem.PopState("QuickChatPage");
	
	-- hide the window
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name = "QuickChatPage", app_key = Map3DSystem.App.Chat.app.app_key, bShow = false,});
	
	--local command = Map3DSystem.App.Commands.GetCommand("Profile.Chat.QuickChat");
	--if(command) then
		--command:Call({bShow = false});
	--end
end

-- show input wnd
function QuickChatPage.OnShowInput()
	local _wnd = ParaUI.GetUIObject("Chat_GUID_QuickChatPage_window");
	if(_wnd:IsValid() == true) then
		_wnd.y = -266;
	end
	
	local inputWnd = page:FindControl("inputWnd");
	if(inputWnd) then
		inputWnd.visible = true;
		local _input = ParaUI.GetUIObject(QuickChatPage.input_name);
		_input:Focus();
		QuickChatPage.UpdateContact();
		QuickChatPage.SetEnabled(true);
	end	
end

-- close input wnd
function QuickChatPage.OnHideInput()
	local _wnd = ParaUI.GetUIObject("Chat_GUID_QuickChatPage_window");
	if(_wnd:IsValid() == true) then
		_wnd.y = -234;
	end
	
	Map3DSystem.PopState("QuickChatPage");
	
	local inputWnd = page:FindControl("inputWnd");
	if(inputWnd) then
		inputWnd.visible = false;
		local _input = ParaUI.GetUIObject(QuickChatPage.input_name);
		_input:LostFocus();
		--page:SetUIValue("ContactTargetLable", "");
		QuickChatPage.SetEnabled(false);
	end
end

function QuickChatPage.SetEnabled(bEnabled)
	local window = CommonCtrl.WindowFrame.GetWindowFrame2(Map3DSystem.App.Chat.app._app.name, "QuickChatPage");
	if(window ~= nil) then
		local _window = window:GetWindowUIObject();
		if(_window ~= nil) then
			if(bEnabled == false) then
				_window:GetChild("BG").color = "255 255 255 0";
			else
				_window:GetChild("BG").color = "255 255 255 255";
			end
			
			-- whether to enable mouse scrolling over the content. Disable it will allow mouse wheel messages to leak to the 3d scene. 
			local ctl = CommonCtrl.GetControl("LobbyBBSChannelMessages_TreeView");
			if(ctl ~= nil) then
				ctl:EnableMouseWheel(bEnabled);
			end
			
			--_window.enabled = bEnabled;
			--_guihelper.SetContainerEnabled(_window, bEnabled)
		end
	end
end

function QuickChatPage.OnSelectQuickChatTarget(name, target)
	QuickChatPage.UpdateContact();
end

QuickChatPage.ChatTarget = "Channel";

function QuickChatPage.UpdateContact()
	--local chatTarget = page:GetUIValue("QuickChatTarget");
	local chatTarget = QuickChatPage.ChatTarget;
	
	if(chatTarget == "LastestContact") then
		-- talk to the latest contact person
		QuickChatPage.mode = chatTarget;
		
		local LatestSelectedContactJID = QuickChatPage.LatestSelectedContactJID;
		
		if(LatestSelectedContactJID ~= nil) then
			
			local name = Map3DSystem.App.Chat.GetNameFromJID(LatestSelectedContactJID);
			page:SetUIValue("ContactTargetLable", string.format("对%s说:", tostring(name)))
			local _input = ParaUI.GetUIObject(QuickChatPage.input_name);
			_input.enabled = true;
			_input:Focus();
			_guihelper.SetUIColor(_input, "255 255 255 255");
			
			--local _send = page:FindControl("btnSendMSG");
			--_send.enabled = true;
		else
			-- switch back to channel
			QuickChatPage.ChatTarget = "Channel";
			QuickChatPage.UpdateContact();
			
			--page:SetUIValue("ContactTargetLable", "最近没有人和你联系")
			
			--local _input = ParaUI.GetUIObject(QuickChatPage.input_name);
			--if(_input) then
				--_input.enabled = false;
				--_guihelper.SetUIColor(_input, "255 255 255 150");
			--end
			
			--local send = page:FindControl("btnSendMSG");
			--if(send) then
				--send.enabled = false;
			--end	
		end
	elseif(chatTarget == "Channel") then
		-- talk to channel if any
		QuickChatPage.mode = chatTarget;
		
		local channelText = Map3DSystem.App.Chat.ChannelManager.GetFocusChannelText() or Map3DSystem.App.Chat.ChannelManager.CurrentFocusChannelName;
		page:SetUIValue("ContactTargetLable", string.format("在[%s]中说:", tostring(channelText)))
		
		local _input = ParaUI.GetUIObject(QuickChatPage.input_name);
		if(_input) then
			_input.enabled = true;
			-- TODO: strange, why this Focus will cause the program crash, when already logged in and enter world + change channel 
			--_input:Focus();
			_guihelper.SetUIColor(_input, "255 255 255 255");
		end
		
		local send = page:FindControl("btnSendMSG");
		if(send) then
			send.enabled = true;
		end	
	end	
end

QuickChatPage.input_name = "QuickChatPage_Input";

function QuickChatPage.ShowInput(bShow, _parent, params)
	local _this = ParaUI.CreateUIObject("imeeditbox", QuickChatPage.input_name, params.alignment, params.left, params.top, params.width, params.height);
	_this.onchange = ";Map3DSystem.App.Chat.QuickChatPage.OnInputTextChange();";
	_this.onkeyup = ";Map3DSystem.App.Chat.QuickChatPage.OnInputTextKeyUp();";
	--_this.background = "Texture/3DMapSystem/common/href.png:2 2 2 2";
	--_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/listbox_bg.png:4 4 4 4";
	_this.background = "";
	--default set to public channel text color
	_guihelper.SetFontColor(_this, "#"..Map3DSystem.App.Chat.ChannelManager.TextColors["Public"]);
	_parent:AddChild(_this);
end

function QuickChatPage.OnInputTextKeyUp()
	if(virtual_key == Event_Mapping.EM_KEY_SPACE) then
		QuickChatPage.OnSpace();
	elseif(virtual_key == Event_Mapping.EM_KEY_TAB) then
		QuickChatPage.OnTab();
	elseif(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER) then
		QuickChatPage.SendMSG();
	end
end

function QuickChatPage.OnInputTextChange()
	if(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER) then
		QuickChatPage.SendMSG();
	elseif(virtual_key == Event_Mapping.EM_KEY_ESCAPE) then
		QuickChatPage.OnHideInput();
	end
end

-- change the current text color
-- @param textcolor: like "ff0000"
function QuickChatPage.OnChangeTextColor(textColor)
	if(textColor) then
		QuickChatPage.TextStyle = string.format("style='color:#%s'", textColor);
	end	
end

-- check the input box for channel switch command
function QuickChatPage.OnSpace()
	local _input = ParaUI.GetUIObject(QuickChatPage.input_name);
	if(_input:IsValid() == true) then
		local inputText = _input.text;
		if(inputText == "/p ") then
			-- switch to public channel
			QuickChatPage.ChatTarget = "Channel";
			Map3DSystem.App.Chat.ChannelManager.ChangeFocusChannel("Channel_Public");
			_input.text = "";
			_guihelper.SetFontColor(_input, "#"..Map3DSystem.App.Chat.ChannelManager.TextColors["Public"]);
			local ctl = CommonCtrl.GetControl("ChannelPage_TabControl");
			if(ctl ~= nil) then
				ctl:SetSelectedIndex(1);
			end
		elseif(inputText == "/h ") then
			-- switch to help channel
			QuickChatPage.ChatTarget = "Channel";
			Map3DSystem.App.Chat.ChannelManager.ChangeFocusChannel("Channel_Help");
			_input.text = "";
			_guihelper.SetFontColor(_input, "#"..Map3DSystem.App.Chat.ChannelManager.TextColors["Help"]);
			local ctl = CommonCtrl.GetControl("ChannelPage_TabControl");
			if(ctl ~= nil) then
				ctl:SetSelectedIndex(2);
			end
		elseif(inputText == "/w ") then
			-- switch to world channel
			QuickChatPage.ChatTarget = "Channel";
			local worldpath = ParaWorld.GetWorldDirectory();
			Map3DSystem.App.Chat.ChannelManager.ChangeFocusChannel("Channel_World_"..worldpath);
			_input.text = "";
			_guihelper.SetFontColor(_input, "#"..Map3DSystem.App.Chat.ChannelManager.TextColors["World"]);
			local ctl = CommonCtrl.GetControl("ChannelPage_TabControl");
			if(ctl ~= nil) then
				ctl:SetSelectedIndex(3);
			end
		elseif(inputText == "/r ") then
			-- switch to latest contact
			QuickChatPage.ChatTarget = "LastestContact";
			QuickChatPage.LatestSelectedContactJID = Map3DSystem.App.Chat.LatestReceiveMSGJIDs[1];
			if(QuickChatPage.LatestSelectedContactJID == nil) then
				-- switch back to channel
				QuickChatPage.ChatTarget = "Channel";
			end
			_input.text = "";
			_guihelper.SetFontColor(_input, "#"..Map3DSystem.App.Chat.ChannelManager.TextColors["Chat"]);
		end
		-- update the quick chat contact
		Map3DSystem.App.Chat.QuickChatPage.UpdateContact();
	end
end

-- check the input box for channel target switch command
function QuickChatPage.OnTab()
	if(QuickChatPage.ChatTarget == "LastestContact") then
		-- switch between different contacts
		QuickChatPage.LatestIndex = QuickChatPage.LatestIndex or 1;
		QuickChatPage.LatestIndex = (QuickChatPage.LatestIndex + 1);
		if(QuickChatPage.LatestIndex > Map3DSystem.App.Chat.LatestReceiveMSGJIDs) then
			QuickChatPage.LatestIndex = 1;
		end
		QuickChatPage.LatestSelectedContactJID = Map3DSystem.App.Chat.LatestReceiveMSGJIDs[QuickChatPage.LatestIndex];
		-- update the quick chat contact
		Map3DSystem.App.Chat.QuickChatPage.UpdateContact();
	end
end

function QuickChatPage.SendMSG()
	local JID = QuickChatPage.LatestSelectedContactJID;
	local _input = ParaUI.GetUIObject(QuickChatPage.input_name);
	if(_input:IsValid() == true) then
		local sendText = _input.text;
		if(sendText ~= "") then
			-- TODO: lxz: Make sure string.len(sendText)<256
			_input.text = "";
			
			if(QuickChatPage.mode == "LastestContact" and JID ~= nil) then
				-- send the message to the last contact
				local jc = Map3DSystem.App.Chat.GetConnectedClient();
				if(jc ~= nil) then
					jc:Message(JID, sendText);
				end
				
				local _chatWnd = Map3DSystem.App.Chat.ChatWnd:CreateGetWnd({[1] = JID});
				_chatWnd:AppendMSG(Map3DSystem.App.Chat.UserJID, sendText);
				
				-- reset LatestSelectedContactJID
				QuickChatPage.LatestSelectedContactJID = nil;
				QuickChatPage.mode = "Channel";
				Map3DSystem.App.Chat.QuickChatPage.UpdateContact();
				
				---- close quick chat window
				--QuickChatPage.OnClose(false);
			elseif(QuickChatPage.mode == "Channel") then
				-- send the message to channel
				--log("Send message "..sendText.." to Channel\n")
				
				local username;
				local profile = Map3DSystem.App.profiles.ProfileManager.GetProfile();
				
				if(profile) then
					username = profile:getFullName() or L"anonymous";
				end
				
				NPL.load("(gl)script/ide/XPath.lua");
				-- encode the content string
				sendText = commonlib.XPath.XMLEncodeString(sendText);
				
				-- original implementation
				--local mcmlStr = string.format("<pe:name uid='%s' a_class='a_inverse' value='%s'/>:<span %s>%s</span>",
					--Map3DSystem.App.profiles.ProfileManager.GetUserID() or "", username, QuickChatPage.TextStyle or "", sendText);
				
				local worldpath = ParaWorld.GetWorldDirectory();
				local textColor;
				
				local currentFocusChannelName = Map3DSystem.App.Chat.ChannelManager.CurrentFocusChannelName;
				if(currentFocusChannelName == "Channel_Public") then
					textColor = Map3DSystem.App.Chat.ChannelManager.TextColors["Public"];
				elseif(currentFocusChannelName == "Channel_Help") then
					textColor = Map3DSystem.App.Chat.ChannelManager.TextColors["Help"];
				elseif(currentFocusChannelName == "Channel_World_"..worldpath) then
					textColor = Map3DSystem.App.Chat.ChannelManager.TextColors["World"];
				end
				
				local textStyle = string.format("style='color:#%s'", textColor);
				
				local mcmlStr = string.format("<pe:name uid='%s' a_%s value='%s'/>:<span %s>%s</span>",
					Map3DSystem.App.profiles.ProfileManager.GetUserID() or "", textStyle or "", username, 
					textStyle or "", sendText);
				
				Map3DSystem.App.Chat.ChannelManager.PostMessage(mcmlStr);
			end
		else
			-- close the quick chat window
			--QuickChatPage.OnClose(false);
			
			-- close the quick chat input
			QuickChatPage.OnHideInput()
		end
	end
end
