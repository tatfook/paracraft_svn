--[[
Title: 
Author(s): leio
Date: 2011/10/11
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Friends/BestFriendList.lua");
local BestFriendListPage = commonlib.gettable("MyCompany.Aries.Friends.BestFriendListPage");

NPL.load("(gl)script/apps/Aries/Friends/BestFriendList.lua");
local BestFriendListPage = commonlib.gettable("MyCompany.Aries.Friends.BestFriendListPage");
commonlib.echo(BestFriendListPage.best_list);

NPL.load("(gl)script/apps/Aries/Friends/BestFriendList.lua");
local BestFriendListPage = commonlib.gettable("MyCompany.Aries.Friends.BestFriendListPage");
BestFriendListPage.LoadData(callbackFunc)

local Friends = commonlib.gettable("MyCompany.Aries.Friends");
commonlib.echo(Friends.MyFriendNID_map);
-------------------------------------------------------
]]

local Friends = commonlib.gettable("MyCompany.Aries.Friends");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");

local BestFriendListPage = commonlib.gettable("MyCompany.Aries.Friends.BestFriendListPage");
BestFriendListPage.best_list = {
	--{nid = nid, guid = guid, gsid = gsid},
};
function BestFriendListPage.OnInit()
	local self = BestFriendListPage;
	self.page = document:GetPageCtrl();	
end
function BestFriendListPage.GetBestFriendList()
	local self = BestFriendListPage;
	return self.best_list;
end
function BestFriendListPage.DS_Func(index)
	local self = BestFriendListPage;
	if(not self.best_list)then return 0 end
	if(index == nil) then
		return #(self.best_list);
	else
		return self.best_list[index];
	end
end
function BestFriendListPage.DoAddBestFriend(nid)
	 NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
	 local s = string.format([[加一名赛场回避好友需要100魔豆，<br/>确定要加<pe:name nid='%s'/>为赛场回避好友吗？]],tostring(nid));
    _guihelper.Custom_MessageBox(s,function(result)
	    if(result == _guihelper.DialogResult.Yes)then
            BestFriendListPage.DoAddBestFriend_Internal(nid);
	    else
	    end
    end,_guihelper.MessageBoxButtons.YesNo);
end
function BestFriendListPage.DoAddBestFriend_Internal(nid)
	local self = BestFriendListPage;
	if(not nid)then return end
	if(not BestFriendListPage.HasInFriend(nid))then
	 local s = string.format([[<pe:name nid='%s'/>不是你的好友，不需要加入！]],tostring(nid));
		_guihelper.MessageBox(s);
		return;
	end
	if(BestFriendListPage.HasInBestFriend(nid))then
		 local s = string.format([[<pe:name nid='%s'/>已经是你的赛场回避好友了！]],tostring(nid));
		_guihelper.MessageBox(s);
		return;
	end
	local len = #self.best_list;
	if(len >= 5)then
		_guihelper.MessageBox("只能添加5名好友！");
		return;
	end
	local bHas,__,__,copies = hasGSItem(984);
	copies = copies or 0;
	if(copies < 100)then
		--_guihelper.MessageBox("100魔豆可以添加一个赛场回避好友，你的魔豆不够了！");
        _guihelper.Custom_MessageBox("100魔豆可以添加一个赛场回避好友，你的魔豆不够了！是否充值？",function(result)
	        if(result == _guihelper.DialogResult.Yes)then
                NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.lua");
                local PurchaseMagicBean = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseMagicBean");
                PurchaseMagicBean.Show()     
	        end
        end,_guihelper.MessageBoxButtons.YesNo);  
		return;
	end
	ItemManager.PurchaseItem(979, 1, function(msg) 
		if(msg and msg.issuccess)then
			MyCompany.Aries.Desktop.Dock.OnCostNotification(984, -100)
			self.LoadData(function()
				if(self.page)then
					self.page:Refresh(0);
				end
			end);
		end
	end, function(msg) 
		
	end, tostring(nid), "none");
end
--@param nid:user id
--@param ignore_tip: 是否忽略提醒
function BestFriendListPage.DoRemoveBestFriend(nid,ignore_tip)
	local self = BestFriendListPage;
	if(not nid)then return end
	nid = tonumber(nid);
	if(not BestFriendListPage.HasInBestFriend(nid))then
		if(not ignore_tip)then
			_guihelper.MessageBox("不能删除"..nid);
		end
		return;
	end
	local k,v;
	for k,v in ipairs(self.best_list) do
		if(v.nid == nid)then
			local guid = v.guid;
			ItemManager.DestroyItem(guid, 1, function(msg)
				if(msg and msg.issuccess == true) then
					table.remove(self.best_list,k);
					if(self.page)then
						self.page:Refresh(0);
					end
					return;
				end
			end);
		end
	end
end
--是否是赛场回避好友
function BestFriendListPage.HasInBestFriend(nid)
	local self = BestFriendListPage;
	if(not nid)then return end
	local k,v;
	for k,v in ipairs(self.best_list) do
		if(v.nid == nid)then
			return true;
		end
	end
end
--是否是好友
function BestFriendListPage.HasInFriend(nid)
	local self = BestFriendListPage;
	if(not nid)then return end
	return Friends.IsFriendInMemory(nid)
end
--初始化数据
function BestFriendListPage.LoadData(callbackFunc)
	local self = BestFriendListPage;
	self.best_list = {};
	local bag = 1004;
	local goal_gsid = 979;
	ItemManager.GetItemsInBag( bag, "ariesitems_" .. bag, function(msg)
				local i;
				local cnt = ItemManager.GetItemCountInBag(bag);
				for i = 1, cnt do
					local item = ItemManager.GetItemByBagAndOrder(bag, i);
					if(item)then
						local gsid = item.gsid;
						local guid = item.guid;
						if(gsid == goal_gsid)then
							local clientdata = item.clientdata;
							if(clientdata)then
								table.insert(self.best_list,{
									nid = tonumber(clientdata),
									guid = guid,
									gsid = gsid,
								});
							end
						end		
					end
				end
				if(callbackFunc)then
					callbackFunc();
				end
		end, "access plus 0 minutes");
end
function BestFriendListPage.Load_Friends(callbackFunc)
	local self = BestFriendListPage;
	local output = {};
	Friends.GetMyFriends(function(msg)
		output.RealCount = Friends.GetFriendCountInMemory();
	    output.Count = Friends.GetFriendCountInMemory();
	    local i;
	    for i = 1, output.Count do
			local nid = Friends.GetFriendNIDByIndexInMemory(i);
			local priority = i;
			if(Friends.IsUserOnlineInMemory(nid)) then
				-- add the online contact priority by 30000
				priority = 30000 + priority;
			end
			local isvip = false;
			local userinfo = ProfileManager.GetUserInfoInMemory(nid);
			if(userinfo and userinfo.energy and userinfo.energy > 0 and userinfo.mlel) then
				-- add the VIP contact priority by 10000 and sorted by m level
				priority = 10000 + priority + userinfo.mlel * 500;
				isvip = true;
			end
			output[i] = {
				bshow = true, 
				nid = nid, 
				isvip = isvip,
				priority = priority, 
			};
	    end
	    -- sort the table according to priority
	    table.sort(output, function(a, b)
			return (a.priority > b.priority);
	    end);
        -- fill at least 10 rows of friends
		if(output.Count < 10) then
			output.Count = 10;
			local j;
			for j = (output.RealCount + 1), output.Count do
				output[j] = {
					bshow = false,
				};
			end
		end
		
		commonlib.resize(output, output.Count)

		if(callbackFunc)then
			callbackFunc({data = output})
		end
		
	end, "access plus 10 minutes");
end
function BestFriendListPage.OnInit_SelectFriends()
	local self = BestFriendListPage;
	self.temp_page = document:GetPageCtrl();
end
function BestFriendListPage.ClosePage_SelectFriends()
	local self = BestFriendListPage;
	if(self.temp_page)then
		self.temp_page:CloseWindow();
		self.temp_page = nil;
	end
	self.temp_page_is_show = false;
end
function BestFriendListPage.ShowPage_SelectFriends()
	local self = BestFriendListPage;
	if(self.temp_page_is_show)then
		return
	end
	self.temp_page_is_show = true;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Friends/SelectBestFriend.html", 
			name = "BestFriendListPage.ShowPage_SelectFriends", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			bToggleShowHide = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = false,
			allowDrag = false,
			enable_esc_key = true,
			directPosition = true,
				align = "_ctb",
				x = 0,
				y = 70,
				width = 320,
				height = 512,
		});

	self.Load_Friends(function(msg)
		if(msg and msg.data)then
			self.temp_friends_list = msg.data;
			if(self.temp_page)then
				self.temp_page:Refresh(0);
			end
		end
	end)
end
function BestFriendListPage.DS_Func_SelectFriends(index)
	local self = BestFriendListPage;
	if(not self.temp_friends_list)then return 0 end
	if(index == nil) then
		return #(self.temp_friends_list);
	else
		return self.temp_friends_list[index];
	end
end
