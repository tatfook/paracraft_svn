--[[
Title: 
Author(s): Leio
Date: 2011/09/07
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
QuestHelp.is_kids_version = false;
NPL.load("(gl)script/apps/Aries/Chat/ChatPage.lua");
local ChatPage = commonlib.gettable("MyCompany.Aries.ChatPage");
local nid = Map3DSystem.User.nid;
local nid = 168511580;
System.App.profiles.ProfileManager.GetJID(nid, function(jid)
	if(jid)then
		local chatPageInstance = ChatPage.GetPageInstance(jid)
		chatPageInstance:ShowPage();
	end
end);
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
NPL.load("(gl)script/apps/Aries/Combat/main.lua");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");
NPL.load("(gl)script/ide/Encoding.lua");
local Encoding = commonlib.gettable("commonlib.Encoding");
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
local Chat = commonlib.gettable("MyCompany.Aries.Chat");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
local ChatPage = commonlib.gettable("MyCompany.Aries.ChatPage");

ChatPage.nid = nil;
ChatPage.history = nil;
ChatPage.pages = {};
function ChatPage.GetPageInstance(jid)
	local self = ChatPage;
	if(not jid)then return end
	local nid = System.App.Chat.GetNameFromJID(jid)
	if(not self.pages[nid])then
		self.pages[nid] = ChatPage:new{
			nid = nid,
			jid = jid,
		};
	end
	return self.pages[nid];
end
--根据nid返回实例
function ChatPage.GetPageInstanceByNID(nid)
	local self = ChatPage;
	if(not nid)then return end
	return self.pages[nid];
end
function ChatPage:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o.history = {};
	o.uid = ParaGlobal.GenerateUniqueID();
	return o
end
function ChatPage:ClosePage(pageCtrl)
	if(self.pageCtrl)then
		self.pageCtrl:CloseWindow();
		self.is_show = false;
	end
end
function ChatPage:SetPageCtrl(pageCtrl)
	self.pageCtrl = pageCtrl;
end
function ChatPage:GetPageCtrl()
	return self.pageCtrl;
end
function ChatPage:Refresh()
	if(self.pageCtrl)then
		self.pageCtrl:Refresh(0);
	end
end
function ChatPage:ShowPage()
	local name = string.format("ChatPage:ShowPage_%s",self.nid or "");
	local url = string.format("script/apps/Aries/Chat/ChatPage.teen.html?nid=%s",self.nid);
	self.is_show = true;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = url, 
			name = name, 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			directPosition = true,
				align = "_ct",
				x = -370/2,
				y = -470/2,
				width = 370,
				height = 470,
	});		
	self:SetFocus();
	self:UpdateContent();
end
function ChatPage:SetFocus()
	local pageCtrl = self:GetPageCtrl();
	if(not pageCtrl)then return end
	local _editbox = pageCtrl:FindUIControl("content");
    if(_editbox and _editbox:IsValid() == true) then
        _editbox:Focus();
        _editbox:SetCaretPosition(-1);
    end
end
function ChatPage:SendMSG()
	local pageCtrl = self:GetPageCtrl();
	if(not pageCtrl)then return end
	
	local content = pageCtrl:GetValue("content");
	local len = string.len(content);
	if(len == 0)then
		return;
	end
	len = ParaMisc.GetUnicodeCharNum(content);
	if(len > 120) then
		_guihelper.MessageBox("你输入的文字太多了，请缩短一点吧");
		return;
	end
	if(not ChatChannel.streamRateCtrler:AddMessage()) then
		return;
	end
	self.last_send_time = cur_time;
	content = MyCompany.Aries.Chat.BadWordFilter.FilterString(content);
	self:SendMSGToServer(content);
	self:UpdateContent();
    pageCtrl:SetValue("content","");
    self:SetFocus();
end
function ChatPage:UpdateContent()
	if(self.pageCtrl)then
		self.pageCtrl:CallMethod("chat_view","SetDataSource",self.history);
		self.pageCtrl:CallMethod("chat_view", "DataBind"); 
	end
end
function ChatPage:SendMSGToServer(words)
	NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");	
	local myNid=System.App.profiles.ProfileManager.GetNID();

	if(words)then
		local jc = Chat.GetConnectedClient();
		if(jc ~= nil) then
			local myself = Map3DSystem.User.nid;
			local canSendMsg = ExternalUserModule:CanViewUser(myself, self.nid);
			if (canSendMsg) then
				jc:Message(self.jid, words);
			end				
			self:AppendMSG(System.App.Chat.UserJID, words);
			local myself = Map3DSystem.User.nid;
			local msgdata = { 
				ChannelIndex=ChatChannel.EnumChannels.Private,
				from=myself,
				to=self.nid,
				words=words, 
				toschool = Combat.GetSchool(tonumber(self.nid)),
			};
			ChatChannel.AppendChat( msgdata );
		end
	end
end
function ChatPage:AppendMSG(JID, body)
	if(not JID) then
		return;
	end
	local time = ParaGlobal.GetTimeFormat("HH:mm");
	if(self.LatestMSGTime ~= time) then
		self.LatestMSGTime = time;
	else
		time = nil;
	end
	local nid = System.App.Chat.GetNameFromJID(JID);

	-- added by LXZ 2010.8.27: only pure text allowed.
	body = Encoding.EncodeStr(body);

	if(body) then
		body = body:gsub("\n", "<br/>");
		table.insert(self.history,{nid = nid, content = body});
		self:UpdateContent();
	end
end
-- recv message
-- @param JID
-- @param subject
-- @param body
function ChatPage:RecvMSG(JID, subject, body)
	NPL.load("(gl)script/apps/Aries/Friends/FriendsPage.lua");
	local FriendsPage = commonlib.gettable("MyCompany.Aries.FriendsPage");
	if(FriendsPage.IncludeMember(self.nid))then
		return
	end
	self:AppendMSG(JID, body);
	if(not self.is_show)then
		local Name = "Profile.Aries.Teen_ToggleChatTab"..self.uid;
		local commandName = "Profile.Aries.Teen_ToggleChatTab";
		MyCompany.Aries.Desktop.NotificationArea.AppendMSG({Name = Name, commandName = commandName, JID = JID,});
	end

	local msgdata = { 
		ChannelIndex=ChatChannel.EnumChannels.Private,
		from=self.nid,
		words=body, 
		fromschool = Combat.GetSchool(tonumber(self.nid)),
		};
	ChatChannel.AppendChat( msgdata );
end
