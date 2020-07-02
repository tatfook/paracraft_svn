--[[
Title: code behind for page BuddyList.html
Author(s): WangTian
Date: 2009/5/3
Desc:  script/apps/Aries/Friends/BuddyList.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]

local BuddyListPage = commonlib.gettable("MyCompany.Aries.Friends.BuddyListPage");

function BuddyListPage.OnInit(page)

end

function BuddyListPage.ToggleAllowAddFriend(pageCtrl, bAllow)
	NPL.load("(gl)script/apps/Aries/Desktop/AriesSettingsPage.lua");
	MyCompany.Aries.Desktop.AriesSettingsPage.checkBoxAllowAddFriend(bAllow);
	pageCtrl:Refresh(0.01);
end

-- The data source function. 
function BuddyListPage.DS_Func_Buddies(dsTable, index, pageCtrl)
    if(not dsTable.status) then
        -- use a default cache
        BuddyListPage.GetFriends(pageCtrl, "access plus 10 minutes", dsTable)
    elseif(dsTable.status == 2) then    
        if(index == nil) then
			if(pageCtrl) then
				pageCtrl:SetUIValue("onlinecount", format("(%d/%d)", dsTable.RealCount or 0, MyCompany.Aries.Friends.GetMaxFriendsCount()));
			end
            return dsTable.Count;
        else
            return dsTable[index];
        end
    end 
end

-- get friends web service call. it will refresh page once finished. 
function BuddyListPage.GetFriends(pageCtrl, cachepolicy, output)
	local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");
	-- fetching
	output.status = 1;
	local Friends = MyCompany.Aries.Friends;
	Friends.GetMyFriends(function(msg)
		-- msg if no friends:
		-- echo:return { pagecnt=0, nids="" }
		
        -- my friends
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
		output.status = 2;

		if(pageCtrl)then
			pageCtrl:Refresh();
		end
		--local msg = {
			--cache_policy = cachepolicy, 
			--nid = nil, -- myself
			--pageindex = pageindex or -1,
			--onlyonline = 1,
			--order = order or 1,
			--isinverse = isinverse or 0,
		--};
		--paraworld.friends.get(msg, "ariesfriends_online", function(msg)
			---- msg if no friends:
			---- echo:return { pagecnt=0, nids="" }
			--
			--if(msg and (msg.errorcode==0 or errorcode==nil)) then
				--if(msg.nids) then
					--local onlineOrder = 0;
					--local nid;
					--for nid in string.gfind(msg.nids, "([%w%-]+)") do 
						--onlineOrder = onlineOrder + 1;
						--local i;
						--for i = 1, output.Count do
							--local node = output[i];
							--if(node.nid == nid) then
								--output[i].icon = "Texture/Aries/Friends/FriendsWnd_BuddyIcon_Online_32bits.png;0 0 32 26";
								---- swap the online order
								--local temp;
								--temp = output[i].icon;
								--output[i].icon = output[onlineOrder].icon;
								--output[onlineOrder].icon = temp;
								--temp = output[i].nid;
								--output[i].nid = output[onlineOrder].nid;
								--output[onlineOrder].nid = temp;
								--break;
							--end
						--end
					--end
				--end
			--end
			--output.status = 3;
			--pageCtrl:Refresh();
		--end);
	end, "access plus 10 minutes");
end

function BuddyListPage.AddFriend()
	
	local _panel = ParaUI.GetUIObject("AddFriendPanel");
	if(_panel:IsValid() == true) then
		return;
	end
	
	local _panel = ParaUI.CreateUIObject("container", "AddFriendPanel", "_ct", -161, -108, 322, 216);
	_panel.background = "Texture/Aries/Friends/addfriend_bg_32bits.png;0 0 322 216:40 40 40 40";
	_panel.zorder = 3;
	_panel:AttachToRoot();
	
	local _text = ParaUI.CreateUIObject("text", "text", "_lt", 40, 50, 200, 24);
	_text.text = string.format("请输入对方%s",MyCompany.Aries.ExternalUserModule:GetConfig().account_name)
	_text.font = System.DefaultBoldFontString;
	_guihelper.SetFontColor(_text, "#1b2534");
	_panel:AddChild(_text);
	
	local _editbox = ParaUI.CreateUIObject("editbox", "AddFriendPanel_nid", "_lt", 40, 80, 230, 32);
	_editbox.background = "Texture/Aries/Friends/addfriend_input_32bits.png:10 10 10 10";
	_panel:AddChild(_editbox);
	
	local _OK = ParaUI.CreateUIObject("button", "OK", "_lt", 40, 128, 108, 32);
	_OK.text = "";
	_OK.background = "Texture/Aries/Friends/addfriend_OK_32bits.png;0 0 108 32";
	_OK.onclick = [[;
	MyCompany.Aries.Friends.BuddyListPage.AddFriendByNID(tonumber(ParaUI.GetUIObject("AddFriendPanel_nid").text));
	ParaUI.Destroy("AddFriendPanel");
	]];
	_panel:AddChild(_OK);
	
	local _cancel = ParaUI.CreateUIObject("button", "Cancel", "_lt", 170, 128, 108, 32);
	_cancel.text = "";
	_cancel.background = "Texture/Aries/Friends/addfriend_Cancel_32bits.png;0 0 108 32";
	_cancel.onclick = ";ParaUI.Destroy(\"AddFriendPanel\");";
	_panel:AddChild(_cancel);
	
end

function BuddyListPage.AddFriendByNID(nid)
	NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
	
	if (ExternalUserModule:CanViewUser(nid))then  -- 仅本区用户可以相互加好友
		MyCompany.Aries.Friends.AddFriendByNIDWithUI(nid);
	else
		_guihelper.MessageBox("不同区之间的用户, 暂时无法加好友");
	end
end


--["uids"]="6ea1ce24-bdf7-4893-a053-eb5fd2a74281,f114ae44-f5e5-4072-9e40-0d792a9cfe7a,8ec11316-bc2e-491d-8f18-667501687e69,6ea770c6-92b2-4b2b-86da-6f574641ec11,f5f3de7a-05b2-42a0-bd78-415a939020c2,4bc27a7d-f8b5-4124-9f1a-07cae50ef3d3,eedf93e6-eb5c-4bbd-876b-66e6d7547ad7,a11109e3-29aa-41ed-aaf7-c7f59f151162,5c33b959-0f68-41b6-b8db-7bfd039f6bd7,e03b3286-2e42-49d6-8a74-736223bfedca,4c9e50e9-c25b-4e3f-b5e5-c7a4f5a91dc5,201403e7-be7f-4b23-930c-f40b37aba5c5,25ba0d73-766f-4a3d-a923-c57398497dc1,c739538a-4521-4051-a5a2-d26ee537e1b6,6e89ff45-cc1f-4bb1-a72e-db7f2bc10d32,2d893e57-72c6-4769-b0b8-56bbfceedec8,863a1094-7dfe-406d-a06e-083e6d69b616,e19f155e-5a38-456b-a07d-3bf976967c06",
