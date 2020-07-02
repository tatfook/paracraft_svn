--[[
Title: 
Author(s): leio
Date: 2011/01/06
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NewProfile/NewProfileMain.lua");
local NewProfileMain = commonlib.gettable("MyCompany.Aries.NewProfileMain");
NewProfileMain.ShowPage(nid,index);
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/XPath.lua");
NPL.load("(gl)script/apps/Aries/Pet/main.lua");
NPL.load("(gl)script/apps/Aries/NewProfile/NewProfileCombat.lua");
local NewProfileCombat = commonlib.gettable("MyCompany.Aries.NewProfile.NewProfileCombat");
NPL.load("(gl)script/apps/Aries/NewProfile/NewProfileHonour.lua");
local NewProfileHonour = commonlib.gettable("MyCompany.Aries.NewProfile.NewProfileHonour");
NPL.load("(gl)script/apps/Aries/NewProfile/NewProfilePvP.lua");
local NewProfilePvP = commonlib.gettable("MyCompany.Aries.NewProfile.NewProfilePvP");
NPL.load("(gl)script/apps/Aries/Team/TeamMembersPage.lua");
local TeamMembersPage = commonlib.gettable("MyCompany.Aries.Team.TeamMembersPage");
NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");
local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");
NPL.load("(gl)script/apps/Aries/Family/FamilyMembersPage.lua");
local FamilyManager = commonlib.gettable("Map3DSystem.App.Family.FamilyManager");
local Player = commonlib.gettable("MyCompany.Aries.Player");

NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
local HomeLandGateway = Map3DSystem.App.HomeLand.HomeLandGateway;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local NewProfileMain = commonlib.gettable("MyCompany.Aries.NewProfileMain");
function NewProfileMain.OnInit()
	local self = NewProfileMain;
	self.page = document:GetPageCtrl();
end

-- public function. 
function NewProfileMain.ShowPage(nid,index,zorder, mouse_button)
	-- load implementation
	if(System.options.version=="kids") then
		NPL.load("(gl)script/apps/Aries/NewProfile/NewProfileMain.kids.lua");
		if(not mouse_button or mouse_button == "left") then
			NewProfileMain.CreatePage(nid,index,zorder);
		else
			NewProfileMain.OnShowContextMenu(nid);
		end
	else
		NPL.load("(gl)script/apps/Aries/NewProfile/ProfilePane.lua");
		local ProfilePane = commonlib.gettable("MyCompany.Aries.ProfilePane");
		ProfilePane.ShowPage(nid);
	end
	
end

-- virtual function: create the page
function NewProfileMain.CreatePage(nid,index,zorder)
end

-- whether a user is my friends
function NewProfileMain.IsMyFriend(nid)
	return MyCompany.Aries.Friends.IsFriendInMemory(nid);
end

-- show the context menu when right click the user
function NewProfileMain.OnShowContextMenu(nid, pos_x, pos_y)
	
	local ctl = CommonCtrl.GetControl("pe_name_aries_ContextMenu");
	if(ctl==nil)then
		NPL.load("(gl)script/ide/ContextMenu.lua");
		ctl = CommonCtrl.ContextMenu:new{
			name = "pe_name_aries_ContextMenu",
			width = if_else(System.options.version=="kids", 120, 120),
			height = 160,
			DefaultNodeHeight = 24,
			style = if_else(System.options.version=="teen", nil, {
				borderTop = 4,
				borderBottom = 4,
				borderLeft = 4,
				borderRight = 4,
				
				fillLeft = 0,
				fillTop = 0,
				fillWidth = 0,
				fillHeight = 0,
				
				titlecolor = "#283546",
				level1itemcolor = "#283546",
				level2itemcolor = "#3e7320",
				
				iconsize_x = 24,
				iconsize_y = 21,
				
				menu_bg = "Texture/Aries/Creator/border_bg_32bits.png:3 3 3 3",
				menu_lvl2_bg = "Texture/Aries/Creator/border_bg_32bits.png:3 3 3 3",
				shadow_bg = nil,
				separator_bg = "Texture/Aries/Dock/menu_separator_32bits.png", -- : 1 1 1 4
				item_bg = "Texture/Aries/Dock/menu_item_bg_32bits.png: 10 6 10 6",
				expand_bg = "Texture/Aries/Dock/menu_expand_32bits.png; 0 0 34 34",
				expand_bg_mouseover = "Texture/Aries/Dock/menu_expand_mouseover_32bits.png; 0 0 34 34",
				
				menuitemHeight = 24,
				separatorHeight = 2,
				titleHeight = 24,
				
				titleFont = "System;12;bold";
			}),
		};
		local node = ctl.RootNode;
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "pe:name", Name = "pe:name", Type = "Group", NodeHeight = 0 });
		if(System.options.version =="teen")then
			node:AddChild(CommonCtrl.TreeNode:new({Text = "邀请加入家族", Name = "InviteToFamily", Type = "Menuitem", onclick = function()
					local manager = FamilyManager.CreateOrGetManager();
					if(manager and ctl.nid)then
						manager:DoInvite(ctl.nid);
					end
				end, Icon = nil,}));
		end
		if(System.options.version=="kids") then
			node:AddChild(CommonCtrl.TreeNode:new({Text = "  投人气", Name = "onvote", Type = "Menuitem", onclick = function()
					NewProfileMain.OnVotePolularity(ctl.nid,true);
				end, Icon = "Texture/Aries/NewProfile/onvote_32bits.png;0 1 24 23"}));	
			node:AddChild(CommonCtrl.TreeNode:new({Text = "  加为好友", Name = "addasfriend",Type = "Menuitem", onclick = function()
					NewProfileMain.OnAddAsFriend(ctl.nid);
				end,  Icon = "Texture/Aries/NewProfile/addasfriend_32bits.png;0 0 24 21"}));	
		end
		node:AddChild(CommonCtrl.TreeNode:new({Text = "邀请组队", Name = "InviteToTeam", Type = "Menuitem", onclick = function()
				TeamMembersPage.InviteToTeam(ctl.nid);
			end, Icon = nil,}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "单独聊天", Name = "chat", Type = "Menuitem", onclick = function()
				System.App.Commands.Call("Profile.Aries.ChatWithFriendImmediate", {nid = ctl.nid});
			end, }));
		
		local function OnClickTrade_()
			if(System.options.disable_trading) then
				_guihelper.MessageBox("因个人账户安全原因，物品交换/邮件系统进行维护。预计将在下次更新后修复功能，若提前恢复交易功能不做另行通知。");
				return;
			end
			NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
			local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
			local can_pass = DealDefend.CanPass(function()
				OnClickTrade_();
			end);
			if(not can_pass) then
				return;
			end

			if(System.options.version =="teen")then
				NPL.load("(gl)script/apps/Aries/Trade/TradeClientPage.teen.lua");
			else
				NPL.load("(gl)script/apps/Aries/Trade/TradeClientPage.kids.lua");		
			end

			if(not MyCompany.Aries.ExternalUserModule:CanViewUser(ctl.nid)) then
				_guihelper.MessageBox("不同区之间的用户无法交易");
			elseif(MyCompany.Aries.Trade.TradeClientPage:CanTrade(ctl.nid))then
				MyCompany.Aries.Trade.TradeClientPage.ShowPage(ctl.nid);	
			else
				_guihelper.MessageBox("距离太远了。");
			end
		end
		node:AddChild(CommonCtrl.TreeNode:new({Text = "交易", Name = "trade", Type = "Menuitem", onclick = OnClickTrade_, }));

		if(System.options.version == "kids") then
			node:AddChild(CommonCtrl.TreeNode:new({Text = "送礼物", Name = "sendgift", Type = "Menuitem", onclick = function()
					NewProfileMain.OnSendGift(ctl.nid)
				end, }));
		else
			node:AddChild(CommonCtrl.TreeNode:new({Text = "发送邮件", Name = "sendgift", Type = "Menuitem", onclick = function()
					NewProfileMain.OnSendGift(ctl.nid)
				end, }));
		end
		
		if(System.options.version == "kids") then
			node:AddChild(CommonCtrl.TreeNode:new({Text = "收礼物", Name = "getgift", Type = "Menuitem", onclick = function()
					NewProfileMain.OnGetGift(ctl.nid)
				end, }));
		end

		--node:AddChild(CommonCtrl.TreeNode:new({Text = "加入队伍", Name = "JoinToTeam", Type = "Menuitem", onclick = function()
				--TeamMembersPage.JoinToTeam(ctl.nid);
			--end, Icon = nil,}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "传送到他(她)身边", Name = "teleporttouser", Type = "Menuitem", onclick = function()
				NewProfileMain.OnSearchFriend(ctl.nid);
			end, }));

		-- 青年版暂时关闭家园访问
		if(System.options.version=="kids") then
			node:AddChild(CommonCtrl.TreeNode:new({Text = "访问家园", Name = "visithome", Type = "Menuitem", onclick = function()
					NewProfileMain.OnVisitHome(ctl.nid)
				end, }));
			
			NPL.load("(gl)script/apps/Aries/Mail/MailBox.lua");
			MyCompany.Aries.Mail.ViewMail.Visible = true;
			node:AddChild(CommonCtrl.TreeNode:new({Text = "发信件", Name = "sendmail", Type = "Menuitem", onclick = function()
			MyCompany.Aries.Mail.MailBox.ShowPage({nid=ctl.nid, title="",});				
			end, }));
		else
			node:AddChild(CommonCtrl.TreeNode:new({Text = "访问空间", Name = "visithome", Type = "Menuitem", onclick = function()
					NewProfileMain.OnVisitHome(ctl.nid)
				end, }));
		end
			
		if(System.options.version == "teen") then
			node:AddChild(CommonCtrl.TreeNode:new({Text = "加入黑名单", Name = "banplayer", Type = "Menuitem", onclick = function()
					NPL.load("(gl)script/apps/Aries/Friends/FriendsPage.lua");
					local FriendsPage = commonlib.gettable("MyCompany.Aries.FriendsPage");
					FriendsPage.AddBlackMember(ctl.nid);
				end, }));
		end

		if(System.options.version=="kids") then
			node:AddChild(CommonCtrl.TreeNode:new({Text = "查看家族", Name = "showfamily", Type = "Menuitem", onclick = function()
					NPL.load("(gl)script/apps/Aries/Profile/FamilyProfile.lua");
					MyCompany.Aries.FamilyProfilePage.ShowFamilyInfoOfNID(ctl.nid);
				end, }));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "查看坐骑", Name = "viewmountpet", Type = "Menuitem", onclick = function()
					if(System.options.version=="kids") then
						NewProfileMain.OnViewMountPetInfo(ctl.nid);
					elseif(System.options.version=="teen") then
						NPL.load("(gl)script/apps/Aries/Inventory/PetOtherPlayerPage.lua");
						local PetOtherPlayerPage = commonlib.gettable("MyCompany.Aries.Inventory.PetOtherPlayerPage");
						PetOtherPlayerPage.ShowPage(ctl.nid);
					end
				end, }));
		end
		if(System.options.version=="teen") then
			node:AddChild(CommonCtrl.TreeNode:new({Text = "加为好友", Name = "addasfriend",Type = "Menuitem", onclick = function()
					NewProfileMain.OnAddAsFriend(ctl.nid);
				end, }));	
		end
		if(System.options.version=="kids") then
			node:AddChild(CommonCtrl.TreeNode:new({Text = "删除好友", Name = "removefriend", Type = "Menuitem", onclick = function()
					NewProfileMain.OnRemoveFriend(ctl.nid);
				end, }));	
		end
		-- 青年版有效
			--common info
    		node:AddChild(CommonCtrl.TreeNode:new({Text = "离开队伍", Name = "leave_team", Type = "Menuitem", onclick = function()
				TeamMembersPage.DoMenu( {state = "leave", nid = Map3DSystem.User.nid,});
			end, }));
			--leader info
			node:AddChild(CommonCtrl.TreeNode:new({Text = "召唤全队", Name = "call_all_team", Type = "Menuitem", onclick = function()
				TeamMembersPage.DoMenu( {state = "call_all", nid = ctl.nid,});
			end, }));
        	node:AddChild(CommonCtrl.TreeNode:new({Text = "全队跟随", Name = "team_followme", Type = "Menuitem", onclick = function()
				TeamMembersPage.DoMenu( {state = "team_followme", nid = ctl.nid,});
			end, }));

			--member info
        	node:AddChild(CommonCtrl.TreeNode:new({Text = "踢出队伍", Name = "kickout_team", Type = "Menuitem", onclick = function()
				TeamMembersPage.DoMenu( {state = "kickout", nid = ctl.nid,});
			end, }));
        	node:AddChild(CommonCtrl.TreeNode:new({Text = "指定队长", Name = "captian_team", Type = "Menuitem", onclick = function()
				TeamMembersPage.DoMenu( {state = "captian", nid = ctl.nid,});
			end, }));
        	node:AddChild(CommonCtrl.TreeNode:new({Text = "召唤队友", Name = "call_team", Type = "Menuitem", onclick = function()
				TeamMembersPage.DoMenu( {state = "call", nid = ctl.nid,});
			end, }));

        	node:AddChild(CommonCtrl.TreeNode:new({Text = "跟随", Name = "follow_target", Type = "Menuitem", onclick = function()
				TeamMembersPage.DoMenu( {state = "follow_target", nid = ctl.nid,});
			end, }));


		node:AddChild(CommonCtrl.TreeNode:new({Text = "查看信息", Name = "viewprofile", Type = "Menuitem", onclick = function()
				NewProfileMain.ShowPage(ctl.nid);
			end, }));
	end	
	if(ctl.RootNode) then	
		local node = ctl.RootNode:GetChildByName("pe:name");
		if(node) then
			local is_friend_ = NewProfileMain.IsMyFriend(nid);
			local is_myself = (nid == Map3DSystem.User.nid);
			local tmp = node:GetChildByName("addasfriend");
			if(tmp) then
				tmp.Invisible = is_friend_ or is_myself;
			end
			local tmp = node:GetChildByName("teleporttouser");
			if(tmp) then
				tmp.Invisible = not is_friend_ or is_myself or Player.IsInCombat();
			end
			local tmp = node:GetChildByName("removefriend");
			if(tmp) then
				tmp.Invisible = not is_friend_ or is_myself;
			end
			local tmp = node:GetChildByName("onvote");
			if(tmp) then
				tmp.Invisible = is_myself;
			end
			local tmp = node:GetChildByName("banplayer");
			if(tmp) then
				tmp.Invisible = is_myself;
			end


			-- 邀请加入家族
			local tmp = node:GetChildByName("InviteToFamily");
			if(tmp)then
				local manager = FamilyManager.CreateOrGetManager();
				tmp.Invisible = is_myself or (not manager:CanInviteMember());
			end

			--同一队伍可以跟随
			local tmp = node:GetChildByName("follow_target");
			if(tmp) then
				local Invisible = true;--消失
				if(not is_myself and TeamClientLogics:MyTeamIncludeMember(nid))then
					Invisible = false;--显示
				end
				tmp.Invisible = Invisible;
			end

			--离开队伍
			local tmp = node:GetChildByName("leave_team");
			if(tmp) then
				local Invisible = true;--消失
				if(is_myself and TeamClientLogics:IsInTeam())then
					Invisible = false;--显示
				end
				tmp.Invisible = Invisible;
			end

			--召唤全队
			local tmp = node:GetChildByName("call_all_team");
			if(tmp) then
				tmp.nid = nid;
				local Invisible = true;
				if(is_myself and TeamClientLogics:IsTeamLeader())then
					Invisible = false;
				end
				tmp.Invisible = Invisible;
			end
			--全队跟随
			local tmp = node:GetChildByName("team_followme");
			if(tmp) then
				tmp.nid = nid;
				local Invisible = true;
				if(is_myself and TeamClientLogics:IsTeamLeader())then
					Invisible = false;
				end
				tmp.Invisible = Invisible;
			end

			
			--踢出队伍
			local tmp = node:GetChildByName("kickout_team");
			if(tmp) then
				tmp.nid = nid;
				local Invisible = true;
				if(not is_myself and TeamClientLogics:IsTeamLeader() and TeamClientLogics:MyTeamIncludeMember(nid))then
					Invisible = false;
				end
				tmp.Invisible = Invisible;
			end
			--指定队长
			local tmp = node:GetChildByName("captian_team");
			if(tmp) then
				tmp.nid = nid;
				local Invisible = true;
				if(not is_myself and TeamClientLogics:IsTeamLeader() and TeamClientLogics:MyTeamIncludeMember(nid))then
					Invisible = false;
				end
				tmp.Invisible = Invisible;
			end
			--召唤队友
			local tmp = node:GetChildByName("call_team");
			if(tmp) then
				tmp.nid = nid;
				local Invisible = true;
				if(not is_myself and TeamClientLogics:IsTeamLeader() and TeamClientLogics:MyTeamIncludeMember(nid))then
					Invisible = false;
				end
				tmp.Invisible = Invisible;
			end

			--business
			local tmp = node:GetChildByName("trade");
			if(tmp)then
				tmp.nid = nid;
				tmp.Invisible =  is_myself or Player.IsInCombat() or HomeLandGateway.IsInHomeland();
			end

			--private chat
			local tmp = node:GetChildByName("chat");
			if(tmp)then
				tmp.Invisible = is_myself;
			end

			-- invite to team
			local tmp = node:GetChildByName("InviteToTeam");
			if(tmp)then
				tmp.Invisible = is_myself or TeamClientLogics:MyTeamIncludeMember(nid);
			end

			-- sendgift
			local tmp = node:GetChildByName("sendgift");
			if(tmp)then
				tmp.Invisible = is_myself;
			end

			-- getgift
			local tmp = node:GetChildByName("getgift");
			if(tmp)then
				tmp.Invisible = not is_myself or Player.IsInCombat();
			end

			-- send mail
			local tmp = node:GetChildByName("sendmail");
			if(tmp)then
				tmp.Invisible = not is_friend_ or is_myself or Player.IsInCombat();
			end
		end
	end
	ctl.nid = nid;
	ctl:Show(pos_x, pos_y);
end

function NewProfileMain.GetSelectedNID()
	local self = NewProfileMain;
	return self.nid;	
end
function NewProfileMain.ClearSelectedNID()
	local self = NewProfileMain;
	self.nid = nil;
end
function NewProfileMain.SetEditState(isEditing)
	local self = NewProfileMain;
	self.isEditing = isEditing;
end

function NewProfileMain.GetEditState()
	local self = NewProfileMain;
	return self.isEditing;
end

-- send gift to this user
function NewProfileMain.OnSendGift(nid)
	if(System.options.disable_trading) then
		_guihelper.MessageBox("因个人账户安全原因，物品交换/邮件系统进行维护。预计将在下次更新后修复功能，若提前恢复交易功能不做另行通知。");
		return;
	end

	if(System.options.version == "kids") then
		NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
		Map3DSystem.App.HomeLand.HomeLandGateway.GiveGiftToUser(nid)
	else
		NPL.load("(gl)script/apps/Aries/Mail/WriteMailPage.lua");
		local WriteMailPage = commonlib.gettable("MyCompany.Aries.Mail.WriteMailPage");
		WriteMailPage.ShowPage(nid);
	end
end
function NewProfileMain.OnGetGift(nid)
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
	if(nid)then
		local myself = tostring(Map3DSystem.User.nid);
		nid = tostring(nid)
		if(nid ~= myself)then
			_guihelper.MessageBox("你只能打开自己的礼物盒！");
			return
		end
	end
	Map3DSystem.App.HomeLand.HomeLandGateway.ShowGiftBox()
end
-- remove friend from friend list
function NewProfileMain.OnRemoveFriend(nid)
	if(not nid) then
		log("error: nil nid in NewProfileMain.OnRemoveFriend\n")
		return;
	end
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	local can_pass = DealDefend.CanPass();
	if(not can_pass)then
		return
	end
	_guihelper.MessageBox("你确定要把 <pe:name nid='"..nid.."' useyou=false/> ("..tostring(MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid))..") 从好友中删除吗？", function(result)
		if(_guihelper.DialogResult.Yes == result) then
			MyCompany.Aries.Friends.RemoveFriendByNID(nid, function(msg)
				if(msg.issuccess == false) then
					_guihelper.MessageBox("删除好友失败, 确定删除好友 <pe:name nid='"..nid.."' useyou=false/> ("..tostring(MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid))..") 吗？", function(result)
						if(_guihelper.DialogResult.Yes == result) then
							NewProfileMain.RemoveFriend(nid);
						elseif(_guihelper.DialogResult.No == result) then
							-- do nothing
						end
					end, _guihelper.MessageBoxButtons.YesNo);
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
					NPL.load("(gl)script/apps/Aries/Friends/FriendsPage.lua");
					local FriendsPage = commonlib.gettable("MyCompany.Aries.FriendsPage");
					FriendsPage.Refresh();
				end
			end);
		elseif(_guihelper.DialogResult.No == result) then
			-- do nothing
		end
	end, _guihelper.MessageBoxButtons.YesNo,nil,nil,true);
end

function NewProfileMain.OnVotePolularity(nid, bSkipShowFullProfile)
	local msg = {
		tonid = nid,
	};
	nid = tonumber(nid);
	if(nid and nid == System.App.profiles.ProfileManager.GetNID())then
		return
	end
	
	NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");	
	local myNid=System.App.profiles.ProfileManager.GetNID();
	local canSendMsg=ExternalUserModule:CanViewUser(myNid, nid);
	if (not canSendMsg) then
		_guihelper.MessageBox("不同区之间的用户, 暂时无法投票");
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
							nickname = commonlib.XPath.XMLEncodeString(nickname);
							nid = tostring(nid);
							local s = string.format([[<div style="margin-left:10px;margin-top:20px;">成功给%s(%s)增加了1点人气值！</div>]], nickname, MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid));
							_guihelper.MessageBox(s);
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
			-- must at least 20 level
			if(System.options.version == "teen") then
				_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">你还没到20级呢，升到20级再来支持他吧！</div>]]);
			else
				_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">大于等于20级才能进行投票。</div>]]);
			end
		end
	end);
end

-- functional other user operation from left to right
--function NewProfileMain.OnSeeFullProfile(nid)
--end

function NewProfileMain.OnAddAsFriend(nid)
	MyCompany.Aries.Friends.AddFriendByNIDWithUI(nid);
end

function NewProfileMain.OnViewMountPetInfo(nid)
	NPL.load("(gl)script/apps/Aries/Inventory/TabMountOthers.lua");
	MyCompany.Aries.Inventory.TabMountOthersPage.ShowPage(nid);
end

function NewProfileMain.OnVisitHome(nid)
	System.App.Commands.Call("Profile.Aries.GotoHomeLand", {nid = nid});
	--System.App.profiles.ProfileManager.GetUserInfo(nid, "FullProfileGetProfile", function(msg)
		--if(msg and msg.users and msg.users[1]) then
			--local uid = msg.users[1].userid;
			--local nid = msg.users[1].nid;
			--System.App.Commands.Call("Profile.Aries.GotoHomeLand", {uid = uid, nid = nid});
		--end
	--end);
end

function NewProfileMain.OnSearchFriend(nid)
	MyCompany.Aries.Friends.QueryFriendPosition(nid);
end

function NewProfileMain.OnAddToBlacklist(nid)
end

function NewProfileMain.OnReportAnnoy(nid)
end

function NewProfileMain.OnRemote1(uid)
end

function NewProfileMain.OnRemote2(uid)
end

function NewProfileMain.OnRemote3(uid)
end

-- get nick name in memory. 
function NewProfileMain.GetNicknameInMem()
    local ProfileManager = System.App.profiles.ProfileManager;
    local profile = ProfileManager.GetUserInfoInMemory(ProfileManager.GetNID());
    if(profile) then
        return profile.nickname;
    end
    return "";
end

function NewProfileMain.OnClose()
    NewProfileMain.SetEditState(false);
    NewProfileMain.page:CloseWindow();
    NewProfileMain.ClearSelectedNID();
end

-- the user has changed to a new nick name
-- @param nickname: the new user name.
-- @param page: the mcml page, if nil, NewProfileMain.page is used.
-- @return true if name can be modified. 
function NewProfileMain.ChangeNickName(nickname, page)
	-- do not do anything if nick name is not changed. 
	if(NewProfileMain.GetNicknameInMem() == nickname or not nickname) then
		if(not page) then
			NewProfileMain.SetEditState(false);
			NewProfileMain.page:Refresh(0.1);
		else
			page:Refresh(0.1);
		end
		return;
	end

	local count_charCN = math.floor((string.len(nickname) - ParaMisc.GetUnicodeCharNum(nickname))/2);
	local count_weight = ParaMisc.GetUnicodeCharNum(nickname) + count_charCN;
	
	local certified_nickname = MyCompany.Aries.Chat.BadWordFilter.FilterString(nickname);
	if(certified_nickname ~= nickname) then
		_guihelper.MessageBox(format("你的昵称中包含非法语言:%s", certified_nickname));
		return;
	elseif(nickname == "") then
		_guihelper.MessageBox("你还没有名字呢，不能保存！");
		return
	elseif(count_weight > 16) then
		_guihelper.MessageBox("你的昵称太长了，请挑选一个短点的吧。");
		return
	end

	-- nick name free change count
	local bOwn, guid, bag, copies = ItemManager.IfOwnGSItem(981, 1002);
	local max_free_change_name_count = 1;
	local free_changename_left_count = max_free_change_name_count - if_else(bOwn, copies, 0);
	-- local free_changename_left_count = tonumber(Player.LoadLocalData("change_nickname_count", "1")) or 1;

	-- how much glod is needed to change the name. 
	local required_gold_count = ItemManager.GetExtendedCostTemplateFromItemCount(825, nil);

	-- @param bUseGold: whether to use gold to change name.
	local function ChangeName_(bUseGold)
		paraworld.users.setInfo({nickname = nickname, }, "SetInfoInFullProfile", function(msg)
			if(msg and msg.issuccess)then
				-- user name changed
				local hook_msg = { aries_type = "UserNameChanged", changed_name = nickname, wndName = "main"};
				CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
				-- auto refresh the user self info in memory
				System.App.profiles.ProfileManager.GetUserInfo();
				-- send nickname update to chat channel
				MyCompany.Aries.BBSChatWnd.SendUserNicknameUpdate();
				if(not page) then
					-- set editing state
					NewProfileMain.SetEditState(false);
				end
				page = page or NewProfileMain.page;
				page:SetValue("FullProfileUserName", nickname);
				page:Refresh(0.1);

				if(free_changename_left_count > 0) then
					free_changename_left_count = free_changename_left_count -1;
					ItemManager.PurchaseItem(981, 1, function()end, function()end, nil, "none");
					--Player.SaveLocalData("change_nickname_count", tostring(free_changename_left_count));
				end
				LOG.std(nil, "system", "userprofile", "change name success. new name is %s", nickname);
				if(bUseGold) then
					-- now remove gold. we do this last, since even this fail, the user name is gauranteed to be changed. 
					ItemManager.ExtendedCost(825, nil, nil, function(msg)
						if(msg and msg.issuccess)then
							LOG.std(nil, "system", "userprofile", "change name gold removed");
						else
							LOG.std(nil, "error", "userprofile", "change name remove gold failed");
						end
					end)
				end
			end
		end);
	end

	if(MyCompany.Aries.Player.GetLevel() <20) then
		_guihelper.MessageBox(format("20级前可免费改名，此后需要%d魔豆，确定要改名吗？",required_gold_count), function()
			ChangeName_(false);
		end);
	elseif(free_changename_left_count>0) then
		_guihelper.MessageBox(format("首次改名免费，此后改名则需要%d魔豆，确定要改名吗？",required_gold_count), function()
			ChangeName_(false);
		end);
	else
		local hasGold, _, _, my_gold_count = hasGSItem(984, 0);
		if(hasGold and my_gold_count and my_gold_count>=required_gold_count) then
			_guihelper.MessageBox(format("改名要花费%d魔豆，您目前有%d魔豆, 是否要改名？", required_gold_count, my_gold_count), function()
				ChangeName_(true);
			end)
		else
			_guihelper.MessageBox(format("改名要花费%d魔豆，您目前只有%d魔豆. <br/> 充值后再来改名吧.", required_gold_count, my_gold_count or 0));
		end
	end
end