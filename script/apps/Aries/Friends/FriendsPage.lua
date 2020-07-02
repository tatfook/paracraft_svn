--[[
Title: 
Author(s): 
Date: 2011/07/18
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
NPL.load("(gl)script/apps/Aries/Friends/FriendsPage.lua");
local FriendsPage = commonlib.gettable("MyCompany.Aries.FriendsPage");
FriendsPage.ShowPage();

NPL.load("(gl)script/apps/Aries/Friends/FriendsPage.lua");
local FriendsPage = commonlib.gettable("MyCompany.Aries.FriendsPage");
FriendsPage.Refresh()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Friends/FriendsManager.lua");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local FriendsManager = commonlib.gettable("MyCompany.Aries.FriendsManager");
local FriendsPage = commonlib.gettable("MyCompany.Aries.FriendsPage");
FriendsPage.selected_type = nil;
FriendsPage.cur_list = nil;
FriendsPage.maps = {
	--["BuddyList"] = {},
	--["NearbyList"] = {},
	--["RecentList"] = {},
};
FriendsPage.buddylist = nil;
function FriendsPage.Refresh(type)
	local self = FriendsPage;
	if(not CommonClientService.IsTeenVersion())then
		return
	end
	type = type or self.selected_type;
	if(self.page)then
		local _app = Map3DSystem.App.AppManager.GetApp(MyCompany.Aries.app.app_key);
		if(_app and _app._app) then
			_app = _app._app;
			local _wnd = _app:FindWindow("FriendsPage.ShowPage");
			if(_wnd:IsVisible())then
				self.DoSelected(type,true);
			end
		end
	end	
end
function FriendsPage.OnInit()
	local self = FriendsPage;
	self.page = document:GetPageCtrl();
end
function FriendsPage.ClosePage()
	local self = FriendsPage;
	if(self.page)then
		self.page:CloseWindow();
		self.selected_type = nil;
		self.cur_list = nil;
		self.maps = {};
	end
end
function FriendsPage.DS_Func_Items(index)
	local self = FriendsPage;
	if(not self.cur_list)then return 0 end
	if(index == nil) then
		return #(self.cur_list);
	else
		return self.cur_list[index];
	end
end
function FriendsPage.ShowPage()
	local self = FriendsPage;
	local params = {
			url = "script/apps/Aries/Friends/FriendsPage.teen.html", 
			name = "FriendsPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			directPosition = true,
				align = "_rb",
				x = -300,
				y = -530,
				width = 280,
				height = 470,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
	if(params._page) then
		params._page.OnClose = function(bDestroy)
			Dock.OnClose("FriendsPage.ShowPage")
		end
	end	
	self.DoSelected(self.selected_type,true)
end
function FriendsPage.DoSelected(type,force_refresh)
	local self = FriendsPage;
	self.selected_type = type or "BuddyList";
	if(self.selected_type == "BlackList")then
		force_refresh = true;
	end
	self.SearchValues(self.selected_type,function(msg)
		if(msg and msg.list)then
			self.cur_list = msg.list;
			if(self.page)then
				self.page:Refresh(0.1);
			end	
		end
	end,force_refresh)
end
function FriendsPage.SearchValues(type,callbackFunc,force_refresh)
	local self = FriendsPage;
	local manager = FriendsManager.CreateOrGetManager();
	type = type or self.selected_type;
	local list = self.maps[type];
	if(not list or force_refresh)then
		if(type == "BuddyList")then
			manager:SearchBuddyList(function(msg)
				if(msg and msg.list)then
					list = msg.list;
					self.maps[type] = list;
					self.buddylist = list;
					if(callbackFunc)then
						callbackFunc({list = list});
					end
				end
			end)
		elseif(type == "NearbyList")then
			local world_info = WorldManager:GetCurrentWorld()
			if(world_info.team_mode == "random_pvp") then
				-- hide random pvp nearby players
				list = {};
			else
				list = manager:SearchNearbyList();
			end
			
			self.maps[type] = list;
			if(callbackFunc)then
				callbackFunc({list = list});
			end
		elseif(type == "RecentList")then
			list = manager:SearchRecentList();
			self.maps[type] = list;
			if(callbackFunc)then
				callbackFunc({list = list});
			end
		elseif(type == "BlackList")then
			list = manager:SearchBlackMemberList();
			self.maps[type] = list;
			if(callbackFunc)then
				callbackFunc({list = list});
			end
		end
	else
		if(callbackFunc)then
			callbackFunc({list = list});
		end
	end
end
function FriendsPage.IsBuddy(nid)
	if(not nid)then return end;
	local self = FriendsPage;
	if(self.buddylist)then
		local k,v;
		for k,v in ipairs(self.buddylist) do
			if(v.nid == nid)then
				return true;
			end
		end
	end
end
function FriendsPage.AddBlackMember(nid)
	local self = FriendsPage;
	if(not nid)then return end
	nid = tonumber(nid);
	local manager = FriendsManager.CreateOrGetManager();
	if(manager:HasBlackMember(nid))then
		_guihelper.MessageBox("已经在黑名单当中!");
		return
	end
	manager:AddBlackMember(nid);
	_guihelper.MessageBox("加入黑名单成功!");
end
function FriendsPage.RemoveBlackMember(nid)
	local self = FriendsPage;
	if(not nid)then return end
	nid = tonumber(nid);
	local manager = FriendsManager.CreateOrGetManager();
	if(not manager:HasBlackMember(nid))then
		return
	end
	manager:RemoveBlackMember(nid);
	self.DoSelected(self.selected_type);
end
--用在聊天时候的判断，如果是黑名单用户，屏蔽聊天消息
--因为调用的很频繁，所以先从cache中取数据
function FriendsPage.IncludeMember(nid)
	local self = FriendsPage;
	if(not nid)then return end
	nid = tonumber(nid);
	local manager = FriendsManager.CreateOrGetManager();
	local list = self.maps["BlackList"];
	if(list)then
		local k,v;
		for k,v in ipairs(list) do
			if(v.nid == nid)then
				return true;
			end
		end
	end
	return manager:HasBlackMember(nid);
end
function FriendsPage.ShowPage_AddFriend(nid)
	local params = {
			url = format("script/apps/Aries/Friends/AddFriendPage.teen.html?nid=%s", tostring(nid or "")), 
			name = "FriendsPage.ShowPage_AddFriend", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			directPosition = true,
				align = "_ct",
				x = -185,
				y = -100,
				width = 370,
				height = 200,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	if(params._page) then
		local pageCtrl = params._page;
		local _editbox = pageCtrl:FindUIControl("content");
		if(_editbox and _editbox:IsValid() == true) then
			_editbox:Focus();
			_editbox:SetCaretPosition(-1);
		end
	end	
end
