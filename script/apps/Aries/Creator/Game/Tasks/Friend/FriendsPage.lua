--[[
Title: FriendsPage
Author(s): 
Date: 2020/7/3
Desc:  
Use Lib:
-------------------------------------------------------
local FriendsPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Friend/FriendsPage.lua");
FriendsPage.Show();
--]]
local FriendsPage = NPL.export();


local page;


FriendsPage.data_sources = {
    {
        { name = "1", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png", nid = "10086"},
       { name = "1", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
       { name = "1", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
       { name = "1", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
       { name = "1", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
       { name = "1", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
       { name = "1", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
       { name = "1", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
       { name = "1", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
    },
    {
        { name = "2", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "2", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "2", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "2", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "2", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "2", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "2", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "2", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "2", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "2", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "2", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "2", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "2", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
    },
    {
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "3", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
    },
    {
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
        { name = "4", mouseover_bg = "Texture/Aries/Common/underline_blue_32bits.png"},
    },
}
FriendsPage.Current_Item_DS = {};
FriendsPage.index = 1;
function FriendsPage.OnInit()
	page = document:GetPageCtrl();
end

function FriendsPage.Show()
    local params = {
			url = "script/apps/Aries/Creator/Game/Tasks/Friend/FriendsPage.html",
			name = "FriendsPage.Show", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			enable_esc_key = true,
			zorder = -1,
			app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			directPosition = true,
				align = "_lt",
				x = 10,
				y = 10/2,
				width = 300,
				height = 500,
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
    FriendsPage.OnChange(1);
end
function FriendsPage.OnChange(index)
	index = tonumber(index)
    FriendsPage.index = index;
    FriendsPage.Current_Item_DS = FriendsPage.data_sources[index] or {}
    FriendsPage.OnRefresh()
end
function FriendsPage.OnRefresh()
    if(page)then
        page:Refresh(0);
    end
end
function FriendsPage.ClickItem(index)
    print("fffffffffffffffffff", mouse_button)
    if mouse_button == "left" then
    
    elseif mouse_button == "right" then
        FriendsPage.OpenFriendMenu()
    end
    
end

function FriendsPage.OpenFriendMenu(nid)
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
					-- NewProfileMain.OnVotePolularity(ctl.nid,true);
				end, Icon = "Texture/Aries/NewProfile/onvote_32bits.png;0 1 24 23"}));	
			node:AddChild(CommonCtrl.TreeNode:new({Text = "  加为好友", Name = "addasfriend",Type = "Menuitem", onclick = function()
					-- NewProfileMain.OnAddAsFriend(ctl.nid);
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
					-- NewProfileMain.OnSendGift(ctl.nid)
				end, }));
		else
			node:AddChild(CommonCtrl.TreeNode:new({Text = "发送邮件", Name = "sendgift", Type = "Menuitem", onclick = function()
					-- NewProfileMain.OnSendGift(ctl.nid)
				end, }));
		end
		
		if(System.options.version == "kids") then
			node:AddChild(CommonCtrl.TreeNode:new({Text = "收礼物", Name = "getgift", Type = "Menuitem", onclick = function()
					-- NewProfileMain.OnGetGift(ctl.nid)
				end, }));
		end

		--node:AddChild(CommonCtrl.TreeNode:new({Text = "加入队伍", Name = "JoinToTeam", Type = "Menuitem", onclick = function()
				--TeamMembersPage.JoinToTeam(ctl.nid);
			--end, Icon = nil,}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "传送到他(她)身边", Name = "teleporttouser", Type = "Menuitem", onclick = function()
				-- NewProfileMain.OnSearchFriend(ctl.nid);
			end, }));

		-- 青年版暂时关闭家园访问
		if(System.options.version=="kids") then
			node:AddChild(CommonCtrl.TreeNode:new({Text = "访问家园", Name = "visithome", Type = "Menuitem", onclick = function()
					-- NewProfileMain.OnVisitHome(ctl.nid)
				end, }));
			
			NPL.load("(gl)script/apps/Aries/Mail/MailBox.lua");
			MyCompany.Aries.Mail.ViewMail.Visible = true;
			node:AddChild(CommonCtrl.TreeNode:new({Text = "发信件", Name = "sendmail", Type = "Menuitem", onclick = function()
			MyCompany.Aries.Mail.MailBox.ShowPage({nid=ctl.nid, title="",});				
			end, }));
		else
			node:AddChild(CommonCtrl.TreeNode:new({Text = "访问空间", Name = "visithome", Type = "Menuitem", onclick = function()
					-- NewProfileMain.OnVisitHome(ctl.nid)
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
						-- NewProfileMain.OnViewMountPetInfo(ctl.nid);
					elseif(System.options.version=="teen") then
						NPL.load("(gl)script/apps/Aries/Inventory/PetOtherPlayerPage.lua");
						local PetOtherPlayerPage = commonlib.gettable("MyCompany.Aries.Inventory.PetOtherPlayerPage");
						PetOtherPlayerPage.ShowPage(ctl.nid);
					end
				end, }));
		end
		if(System.options.version=="teen") then
			node:AddChild(CommonCtrl.TreeNode:new({Text = "加为好友", Name = "addasfriend",Type = "Menuitem", onclick = function()
					-- NewProfileMain.OnAddAsFriend(ctl.nid);
				end, }));	
		end
		if(System.options.version=="kids") then
			node:AddChild(CommonCtrl.TreeNode:new({Text = "删除好友", Name = "removefriend", Type = "Menuitem", onclick = function()
					-- NewProfileMain.OnRemoveFriend(ctl.nid);
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
				-- NewProfileMain.ShowPage(ctl.nid);
			end, }));
	end	
	if(ctl.RootNode) then	
		local node = ctl.RootNode:GetChildByName("pe:name");
		if(node) then
			-- local is_friend_ = NewProfileMain.IsMyFriend(nid);
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

				tmp.Invisible = Invisible;
			end

			--离开队伍
			local tmp = node:GetChildByName("leave_team");
			if(tmp) then
				local Invisible = true;--消失

				tmp.Invisible = Invisible;
			end

			--召唤全队
			local tmp = node:GetChildByName("call_all_team");
			if(tmp) then
				tmp.nid = nid;
				local Invisible = true;

				tmp.Invisible = Invisible;
			end
			--全队跟随
			local tmp = node:GetChildByName("team_followme");
			if(tmp) then
				tmp.nid = nid;
				local Invisible = true;

				tmp.Invisible = Invisible;
			end

			
			--踢出队伍
			local tmp = node:GetChildByName("kickout_team");
			if(tmp) then
				tmp.nid = nid;
				local Invisible = true;

				tmp.Invisible = Invisible;
			end
			--指定队长
			local tmp = node:GetChildByName("captian_team");
			if(tmp) then
				tmp.nid = nid;
				local Invisible = true;

				tmp.Invisible = Invisible;
			end
			--召唤队友
			local tmp = node:GetChildByName("call_team");
			if(tmp) then
				tmp.nid = nid;
				local Invisible = true;

				tmp.Invisible = Invisible;
			end

			--business
			local tmp = node:GetChildByName("trade");
			if(tmp)then
				tmp.nid = nid;
				tmp.Invisible =  is_myself
			end

			--private chat
			local tmp = node:GetChildByName("chat");
			if(tmp)then
				tmp.Invisible = is_myself;
			end

			-- invite to team
			local tmp = node:GetChildByName("InviteToTeam");


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
