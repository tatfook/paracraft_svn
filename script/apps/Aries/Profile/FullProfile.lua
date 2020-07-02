--[[
Title: code behind for page FullProfile.html
Author(s): WangTian
Date: 2009/6/4
Desc:  script/apps/Aries/Profile/FullProfile.html?nid=123
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local FullProfilePage = {};
commonlib.setfield("MyCompany.Aries.FullProfilePage", FullProfilePage)
local Encoding = commonlib.gettable("commonlib.Encoding");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
---------------------------------
-- page event handlers
---------------------------------

-- the profile page must be manually closed
FullProfilePage.isEditing = false;

-- init
function FullProfilePage.OnInit(nid)
	local page = document:GetPageCtrl();
	-- use nid to fetch all profile data
	log("use nid:"..nid.." to fetch all profile data\n");
end

-- deprecated
--function FullProfilePage.OnClose()
	--document:GetPageCtrl():CloseWindow();
--end

function FullProfilePage.SetEditState(isEditing)
	FullProfilePage.isEditing = isEditing;
end

function FullProfilePage.GetEditState()
	return FullProfilePage.isEditing;
end

-- The data source for items
function FullProfilePage.DS_Func_Items(dsTable, index, pageCtrl)
    if(not dsTable.status) then
		local nid = pageCtrl:GetRequestParam("nid") or System.App.profiles.ProfileManager.GetNID();
		nid = tonumber(nid);
        -- use a default cache
        FullProfilePage.GetItems(nid, pageCtrl, "access plus 5 minutes", dsTable)
    elseif(dsTable.status == 2) then    
        if(index == nil) then
			--commonlib.echo("!!!!!!!!!!!!:DS_Func_Items");
			--commonlib.echo(dsTable);
			return dsTable.Count;
        else
			return dsTable[index];
        end
    end 
end

function FullProfilePage.GetItems(nid, pageCtrl, cachepolicy, output)
	local bag = 10062;
	-- fetching inventory items
	output.status = 1;
	local ItemManager = System.Item.ItemManager;
	if(nid == System.App.profiles.ProfileManager.GetNID()) then
		ItemManager.GetItemsInBag(bag, "FullProfilePage_MyMedal", function(msg)
			-- default table
			local bhas,_,__,count = hasGSItem(50333);
			if(not bhas or not count)then
				count = 0;
			end

			output[1] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPolice_Empty_32bits.png", tooltip = "神勇徽章"};
			output[2] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalAngel_Empty_32bits.png", tooltip = "天使徽章"};
			output[3] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalGenerous_Empty_32bits.png", tooltip = "友情徽章"};
			output[4] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPopularity_Empty_32bits.png", tooltip = "人气徽章"};
			output[5] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalEnvironmental_Empty_32bits.png", tooltip = "环保徽章"};
			output[6] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalEntrance_32bits.png", tooltip = string.format("魔塔奇兵徽章\r\n已完成试炼之塔%d层",count) };
			
			--commonlib.echo("!!!!!!!!!!!:GetItems 1");
			--commonlib.echo(output);
			
			-- medals to show in the profile window
			local medal_series = {
				{20004, 20006, 20007, 20008},
				{20010, 20011, 20012, 20013},
				{20005, 20001, 20002, 20003},
				{20016, 20017, 20018, 20019},
				{20021, 20022, 20023, 20024},
				{20025, 20026, 20027, 20028},
			};
			-- check for each category in the series and show the highest ranking medal
			local hasGSItem = ItemManager.IfOwnGSItem;
			local i;
			for i = 1, #(medal_series) do
				local ii;
				for ii = 1, #(medal_series[i]) do
					if(hasGSItem(medal_series[i][ii])) then
						local gsid = medal_series[i][ii];
						local name = "";
						local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
						if(gsItem) then
							name = gsItem.template.name;
						end
						output[i].isempty = false;
						output[i].isnotempty = true;
						output[i].gsid = gsid;
						output[i].slot = "";

						if(i==6)then
							output[i].tooltip = string.format("%s\r\n已完成试炼之塔%d层",name, count );
						else
							output[i].tooltip = name;
						end
					end
				end
			end
			output.Count = 6;
			commonlib.resize(output, output.Count);

			--commonlib.echo("!!!!!!!!!!!:GetItems 2");
			--commonlib.echo(output);
			
			-- fetched inventory items
			output.status = 2;
			pageCtrl:Refresh();
			
		end, cachepolicy);
	else
		ItemManager.GetItemsInOPCBag(nid, 31001, "FullProfilePage_OPCMedal_0", function(msg)
			local hasGSItem0 = ItemManager.IfOPCOwnGSItem;
			local bhas,guid = hasGSItem0(nid,50333);
			local count = 0;
			if(bhas)then
				local item0 = ItemManager.GetOPCItemByGUID(nid,guid);
				count = item0.copies;
			end

			ItemManager.GetItemsInOPCBag(nid, bag, "FullProfilePage_OPCMedal", function(msg)
				-- default table
				--local bhas,_,__,count = hasGSItem(50333);
				--if(not bhas or not count)then
					--count = 0;
				--end

				output[1] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPolice_Empty_32bits.png", tooltip = "神勇徽章"};
				output[2] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalAngel_Empty_32bits.png", tooltip = "天使徽章"};
				output[3] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalGenerous_Empty_32bits.png", tooltip = "友情徽章"};
				output[4] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPopularity_Empty_32bits.png", tooltip = "人气徽章"};
				output[5] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalEnvironmental_Empty_32bits.png", tooltip = "环保徽章"};
				output[6] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalEntrance_32bits.png", tooltip = string.format("魔塔奇兵徽章\r\n已完成试炼之塔%d层",count) };
			
				--commonlib.echo("!!!!!!!!!!!:GetItems 3");
				--commonlib.echo(output);			 

				-- medals to show in the profile window
				local medal_series = {
					{20004, 20006, 20007, 20008},
					{20010, 20011, 20012, 20013},
					{20005, 20001, 20002, 20003},
					{20016, 20017, 20018, 20019},
					{20021, 20022, 20023, 20024},
					{20025, 20026, 20027, 20028},

				};
				-- check for each category in the series and show the highest ranking medal
				local hasGSItem = ItemManager.IfOPCOwnGSItem;
				local i;
				for i = 1, #(medal_series) do
					local ii;
					for ii = 1, #(medal_series[i]) do
						if(hasGSItem(nid, medal_series[i][ii])) then
							local gsid = medal_series[i][ii];
							local name = "";
							local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
							if(gsItem) then
								name = gsItem.template.name;
							end
							output[i].isempty = false;
							output[i].isnotempty = true;
							output[i].gsid = gsid;
							output[i].slot = "";
							if(i==6)then
								output[i].tooltip = string.format("%s\r\n已完成试炼之塔%d层",name, count );
							else
								output[i].tooltip = name;
							end
						end
					end
				end
				output.Count = 6;
				commonlib.resize(output, output.Count);

				--commonlib.echo("!!!!!!!!!!!:GetItems 4");
				--commonlib.echo(output);
				-- fetched inventory items
				output.status = 2;
				pageCtrl:Refresh();
			
			end, cachepolicy);
		end, cachepolicy);
	end
end

-- remove friend from friend list
function FullProfilePage.OnRemoveFriend(nid)
	if(not nid) then
		log("error: nil nid in FullProfilePage.OnRemoveFriend\n")
		return;
	end
	_guihelper.MessageBox("你确定要把 <pe:name nid='"..nid.."' useyou=false/> ("..tostring(nid)..") 从好友中删除吗？", function(result)
		if(_guihelper.DialogResult.Yes == result) then
			MyCompany.Aries.Friends.RemoveFriendByNID(nid, function(msg)
				if(msg.issuccess == false) then
					_guihelper.MessageBox("删除好友失败, 确定删除好友 <pe:name nid='"..nid.."' useyou=false/> ("..tostring(nid)..") 吗？", function(result)
						if(_guihelper.DialogResult.Yes == result) then
							FullProfilePage.RemoveFriend(nid);
						elseif(_guihelper.DialogResult.No == result) then
							-- do nothing
						end
					end, _guihelper.MessageBoxButtons.YesNo,nil,nil,true);
				elseif(msg.issuccess == true) then
					--local jc = System.App.Chat.GetConnectedClient();
					--if(jc ~= nil) then
						--local jid = nid.."@"..paraworld.GetDomain();
						---- Unsubscribe
						--jc:Unsubscribe(jid, "");
						----jc:RemoveRosterItem(jid, "");  -- NPL_JC: RemoveRosterItem obsoleted. Use Unsubscribe instead 
						--log("Remove RosterItem: "..jid.."\n")
					--else
						--log("error: nil jabber client when trying to remove friend through jabber\n");
					--end
				end
			end);
		elseif(_guihelper.DialogResult.No == result) then
			-- do nothing
		end
	end, _guihelper.MessageBoxButtons.YesNo,nil,nil,true);
end

function FullProfilePage.OnVotePolularity(nid, bSkipShowFullProfile)
	local msg = {
		tonid = nid,
	};

	NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");	
	local myNid=System.App.profiles.ProfileManager.GetNID();
	local canSendMsg=ExternalUserModule:CanViewUser(myNid, nid);
	if (not canSendMsg) then
		LOG.std("", "warn", "Friends", "you can't VotePolularity user(%s) of other region", tostring(nid));
		return
	end

	paraworld.users.VotePopularity(msg, "FullProfile_VotePopularity", function(msg) 
		log("====== VotePopularity "..tostring(nid).." returns: ======\n")
		--commonlib.echo(msg);
		if(msg.issuccess == true) then
			-- success vote popularity
			-- call hook for OnVoteOtherPopularity
			if(nid and nid ~= System.App.profiles.ProfileManager.GetNID()) then
				local hook_msg = { aries_type = "OnVoteOtherPopularity", nid = nid, wndName = "main"};
				CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

				local hook_msg = { aries_type = "onVoteOtherPopularity_MPD", nid = nid, wndName = "main"};
				CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

			end
			-- update the userinfo after a period of time
			UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
				if(elapsedTime == 500) then
					System.App.profiles.ProfileManager.GetUserInfo(nid, "UpdateUserName_AfterVotePopularity", function(msg)
						if(msg and msg.users[1]) then
							if(not bSkipShowFullProfile) then
								System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
							end
							local nickname = msg.users[1].nickname or "";
							nickname = Encoding.EncodeStr(nickname);
							nid = tostring(nid);
							_guihelper.MessageBox(string.format([[<div style="margin-left:10px;margin-top:20px;">成功给%s(%s)增加了1点人气值！</div>]], nickname, MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid)));
							MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"},79038);
						end
					end, "access plus 0 day");
				end
			end);
			local Chat = MyCompany.Aries.Chat;
			local jc = Chat.GetConnectedClient();
			if(jc) then
				-- send tell the user to update the user info by jabber message
				jc:Message(nid.."@"..System.User.ChatDomain, "[Aries][VotePopularityBy]:"..System.App.profiles.ProfileManager.GetNID());
			end
			local userChar = MyCompany.Aries.Pet.GetUserCharacterObj(tonumber(nid));
			if(userChar and userChar:IsValid() == true) then
				-- send popularity update for all clients in current game world, if user is in the same game world
				MyCompany.Aries.BBSChatWnd.SendUserPopularityUpdate(nid);
			end
		elseif(msg.errorcode == 430) then
			-- excced maximum vote per day
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">你每天只能投5票哦，今天的已经投完了，明天再来支持他吧！</div>]]);
		elseif(msg.errorcode == 431) then
			-- vote for one user once per day
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">每天只能给同一个哈奇增加1点人气值哦，明天再来支持他吧！</div>]]);
		elseif(msg.errorcode == 427) then
			-- must at least 40 level
			if(System.options.version == "teen") then
				_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">你还没到40级呢，升到40级再来支持他吧！</div>]]);
			else
				_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">大于等于20级才能进行投票。</div>]]);
			end
		end
	end);
end

-- functional other user operation from left to right
--function FullProfilePage.OnSeeFullProfile(nid)
--end

function FullProfilePage.OnAddAsFriend(nid)
	MyCompany.Aries.Friends.AddFriendByNIDWithUI(nid);
end

function FullProfilePage.OnViewMountPetInfo(nid)
	NPL.load("(gl)script/apps/Aries/Inventory/TabMountOthers.lua");
	MyCompany.Aries.Inventory.TabMountOthersPage.ShowPage(nid);
end

function FullProfilePage.OnVisitHome(nid)
	System.App.Commands.Call("Profile.Aries.GotoHomeLand", {nid = nid});
	--System.App.profiles.ProfileManager.GetUserInfo(nid, "FullProfileGetProfile", function(msg)
		--if(msg and msg.users and msg.users[1]) then
			--local uid = msg.users[1].userid;
			--local nid = msg.users[1].nid;
			--System.App.Commands.Call("Profile.Aries.GotoHomeLand", {uid = uid, nid = nid});
		--end
	--end);
end

function FullProfilePage.OnSearchFriend(nid)
	_guihelper.MessageBox(string.format([[<div style="margin-left:20px;margin-top:20px;">很抱歉，火鸟岛和哈奇小镇通讯建设中，<br/>查找暂停中</div>]]));
	
	do return end;

	--MyCompany.Aries.Friends.QueryFriendPosition(nid);
end

function FullProfilePage.OnAddToBlacklist(nid)
end

function FullProfilePage.OnReportAnnoy(nid)
end

function FullProfilePage.OnRemote1(uid)
end

function FullProfilePage.OnRemote2(uid)
end

function FullProfilePage.OnRemote3(uid)
end
