--[[
Title: 
Author(s): Leio
Date: 2010/12/28
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Team/TeamMembersPage.lua");
local TeamMembersPage = commonlib.gettable("MyCompany.Aries.Team.TeamMembersPage");
TeamMembersPage.ShowPage(true);
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");
local TeamMembersPage = commonlib.gettable("MyCompany.Aries.Team.TeamMembersPage");
local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");

NPL.load("(gl)script/apps/Aries/Team/TeamWorldInstancePortal.lua");
local TeamWorldInstancePortal = commonlib.gettable("MyCompany.Aries.Team.TeamWorldInstancePortal");

NPL.load("(gl)script/apps/Aries/Pet/main.lua");
local Pet = commonlib.gettable("MyCompany.Aries.Pet");

NPL.load("(gl)script/ide/TooltipHelper.lua");
local BubbleHelper = commonlib.gettable("CommonCtrl.BubbleHelper");

NPL.load("(gl)script/ide/XPath.lua");
TeamMembersPage.min_invite_interval = 10000;
if(TeamClientLogics.Init)then
	TeamClientLogics:Init();
end

-- distance in meters between two players when following mode is on. 
local default_follow_spacing = 4; 

TeamMembersPage.data_source = nil;
TeamMembersPage.chat_tooltip_map = {};
TeamMembersPage.show_state = "expand"; --"expand" or "hide"
function TeamMembersPage.OnInit()
	local self = TeamMembersPage;
	self.page = document:GetPageCtrl();
end
function TeamMembersPage.HidePage()
	if(not TeamClientLogics:IsInTeam())then
		return
	end
	local self = TeamMembersPage;
	self.show_state = "hide";
	if(self.page)then
		self.page:Refresh(0);
	end
end

function TeamMembersPage.IsExpanded()
	return TeamMembersPage.show_state == "expand";
end

function TeamMembersPage.ChangeShowState()
	local self = TeamMembersPage;
	if(self.show_state == "expand")then
		self.show_state = "hide";
	else
		self.show_state = "expand";
	end	
	if(self.page)then
		self.page:Refresh(0);
	end
end
function TeamMembersPage.DS_Func_Items(index)
	local self = TeamMembersPage;
	if(not self.data_source)then return 0 end
	if(index == nil) then
		return #(self.data_source);
	else
		return self.data_source[index];
	end
end

function TeamMembersPage.InviteToTeam(nid)
	local self = TeamMembersPage;
	commonlib.echo("==invite nid=="..nid);
	TeamClientLogics:InviteTeamMember(nid);
end

function TeamMembersPage.JoinToTeam(nid)
	local self = TeamMembersPage;
	commonlib.echo("==join nid=="..nid);
	TeamClientLogics:JoinTeamMember(nid);
end
function TeamMembersPage.SendTeamChatMessage()
	local self = TeamMembersPage;
	local isleader = TeamWorldInstancePortal.IsTeamLeader();
	if(not isleader)then return end
	local msg = "队长在召唤你，快快过来集合吧！"
	if(not self.last_invite_times or (self.last_invite_times + self.min_invite_interval) < commonlib.TimerManager.GetCurrentTime()) then
		self.last_invite_times = commonlib.TimerManager.GetCurrentTime();
		TeamClientLogics:SendTeamChatMessage(msg, true);
	end
end
function TeamMembersPage.ShowPage(bShow)
	local self = TeamMembersPage;
	if(not self.IsTeamValid())then return end
	local data = TeamWorldInstancePortal.GetTeamTable();
	if(bShow)then
		self.ClosePage();
		self.CreatePage(data);
		--if(CommonClientService.IsTeenVersion())then
			--NPL.load("(gl)script/apps/Aries/Desktop/MyPlayerArea/MyPlayerArea.teen.lua");
			local HPMyPlayerArea = commonlib.gettable("MyCompany.Aries.Desktop.HPMyPlayerArea");
			HPMyPlayerArea.UpdateUI(true);
		--end
	else
		self.ClosePage();
	end
end

-- update the health point
-- using page:refresh(0.1) so that repeated calls to this function are automatically ignored. 
function TeamMembersPage.UpdateHealthPoint()
	-- optimized by LXZ 2011.9.8. Refresh page or simply update UI instead of recreating the page. 
	-- TeamMembersPage.ShowPage(true)
	local self = TeamMembersPage;
	local page = self.page;
	if(page) then
		local data = TeamWorldInstancePortal.GetTeamTable();
		self.SetDataSource(data);
		page:Refresh(0.1);
		--local nIndex, member_info;
		--for nIndex, member_info in ipairs(self.data_source) do
			--local new_member_info = data[nIndex];
			--if(new_member_info and new_member_info.nid ==member_info.nid and
				--( new_member_info.cur_hp~=member_info.cur_hp or new_member_info.hp~=member_info.hp)) then
				--member_info.cur_hp = new_member_info.cur_hp;
				--member_info.hp = new_member_info.hp;
				--local progressbar = page:FindControl("pb"..tostring(new_member_info.nid));
				--if(progressbar) then
					--progressbar.Maximum = member_info.hp;
					--progressbar:SetValue(member_info.cur_hp);
				--end
			--end
		--end
	end
end
--青年版队伍不需要显示自己
function TeamMembersPage.SetDataSource(data)
	local self = TeamMembersPage;
	self.data_source = data;
	--if(System.options.version == "teen") then
		local myself = Map3DSystem.User.nid;

		if(self.data_source)then
			local list = {};
			local k,v;
			for k,v in ipairs(self.data_source) do
				if(v.nid ~= myself)then
					table.insert(list,v);
				end
			end
			self.data_source = list;
		end
	--end
end
function TeamMembersPage.CreatePage(data)
	local self = TeamMembersPage;
	if(not data)then return end;
	local len = #data;
	if(len == 0)then return end
	self.SetDataSource(data);
	local url;
	local x,y,width,height;
	local zorder = 1;
	if(System.options.version == "kids") then
		url = "script/apps/Aries/Team/TeamMembersPage.html";
		x,y,width,height = 0,100,200,300;
	else
		url = "script/apps/Aries/Team/TeamMembersPage.teen.html";
		x,y,width,height = 0,135,240,300;
		zorder = 0;
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = url, 
			name = "TeamMembersPage.CreatePage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = zorder,
			isTopLevel = false,
			allowDrag = false,
			click_through = true, -- allow clicking through
			directPosition = true,
				align = "_lt",
				x = x,
				y = y,
				width = width,
				height = height,
		});
end
function TeamMembersPage.ClosePage()
	local self = TeamMembersPage;
	if(self.page)then
		self.page:CloseWindow();
	end
end
function TeamMembersPage.IsTeamValid()
	return true;
end
function TeamMembersPage.AppendTeamChat(nid,content)
	local self = TeamMembersPage;
	nid = tonumber(nid);
	--if(not nid or nid == Map3DSystem.User.nid)then
		--return
	--end 
	local tooltip_params = self.chat_tooltip_map[nid];
	content = tostring(content);
	content = commonlib.XPath.XMLEncodeString(content);
	if(content and content ~= "" and tooltip_params)then
		local page = string.format([[script/apps/Aries/Team/TeamChatPage.html?chat=%s]],content);
		BubbleHelper.Show(tooltip_params.id,page,tooltip_params.force_offset_x,tooltip_params.force_offset_y,tooltip_params.show_width,tooltip_params.show_height,tooltip_params.show_duration,tooltip_params.click_through)
	end
end
function TeamMembersPage.OnCreate(param, mcmlNode)
	local self = TeamMembersPage;
	local nid = tonumber(mcmlNode:GetAttributeWithCode("nid"));
	if(not nid)then return end
	local name = "TeamMembersPage_Chat"..nid
	local _this = ParaUI.CreateUIObject("container", name, "_lt", param.left,param.top,param.width,param.height);
	_this.background = "";
	param.parent:AddChild(_this);
	local id = _this.id;
	local force_offset_x = tonumber(mcmlNode:GetAttributeWithCode("force_offset_x")) or 0;
	local force_offset_y = tonumber(mcmlNode:GetAttributeWithCode("force_offset_y")) or 0;
	local show_duration = tonumber(mcmlNode:GetAttributeWithCode("show_duration")) or 10000;
	local show_width = tonumber(mcmlNode:GetAttributeWithCode("show_width")) or 400;
	local show_height = tonumber(mcmlNode:GetAttributeWithCode("show_height")) or 80;

	self.chat_tooltip_map[nid] = {
		id = id,
		force_offset_x = force_offset_x,
		force_offset_y = force_offset_y,
		show_duration = show_duration, 
		show_width = show_width,
		show_height = show_height,
		click_through = true,
	}
end
function TeamMembersPage.DoMenu(node)
	local self = TeamMembersPage;
	if(not node or not node.state or not node.nid)then return end
	local state = node.state;
	local nid = node.nid;
	if(state == "show_profile")then
		System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
	elseif(state == "leave")then
		 nid = tonumber(nid)
		_guihelper.Custom_MessageBox("你确定要退出当前队伍吗？",function(result)
			if(result == _guihelper.DialogResult.Yes)then
				TeamClientLogics:DelTeamMember(nid);
				local login_room_id = LobbyClientServicePage.GetRoomID();
				if(login_room_id)then
					LobbyClientServicePage.DoLeaveGame(login_room_id);
				end
			else
				commonlib.echo("no");
			end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
	
	elseif(state == "kickout")then
		nid = tonumber(nid)
		local s = string.format([[你确认要把<pe:name nid="%s" linked="false"/>从当前队伍里踢出吗？]], tostring(nid));
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.Yes)then
				TeamClientLogics:DelTeamMember(nid);
			else
				commonlib.echo("no");
			end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
	elseif(state == "captian")then
		nid = tonumber(nid)
		local s = string.format([[你确认让<pe:name nid="%s" linked="false"/>当队长吗？ ]], tostring(nid));
		 _guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.Yes)then
				TeamClientLogics:SetTeamLeader(nid);
			else
				commonlib.echo("no");
			end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
	elseif(state == "call_all")then
		if(not self.last_invite_times or (self.last_invite_times + self.min_invite_interval) < commonlib.TimerManager.GetCurrentTime()) then
			self.last_invite_times = commonlib.TimerManager.GetCurrentTime();
			local data = TeamWorldInstancePortal.GetTeamTable();
			if(data)then
				local k,v;
				local nids = {};
				for k,v in ipairs(data) do
					if(v.nid)then
						table.insert(nids,v.nid);
					end
				end
				System.App.Commands.Call("Profile.Aries.ComeHereByTeamChat", { nids = nids });
			end
		else
			_guihelper.MessageBox("你的动作太频繁了，等下再试试吧！");
		end
		
	elseif(state == "call")then
		if(not self.last_invite_times or (self.last_invite_times + self.min_invite_interval) < commonlib.TimerManager.GetCurrentTime()) then
			self.last_invite_times = commonlib.TimerManager.GetCurrentTime();
			System.App.Commands.Call("Profile.Aries.ComeHereByTeamChat", { nids = {nid}});
		else
			_guihelper.MessageBox("你的动作太频繁了，等下再试试吧！");
		end
	elseif(state == "team_followme")then
		-- let all other team members to follow me 
		local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
		local address = WorldManager:GetWorldAddress();
		if(address) then
			TeamClientLogics:SendTeamChatMessage({type="team_followme", leader_nid=nid, address=address})
		end
	elseif(state == "follow_target")then
		-- follow this target
		TeamMembersPage.DoFollowUser(nid);
	end
end

-- internally used to follow a given nid(usually the leader) at a given distance derived from rank_index
-- @param nid:  nid of the target to be followed
function TeamMembersPage.DoFollowUser(nid)
	NPL.load("(gl)script/apps/Aries/Scene/AutoFollowAI.lua");
	local AutoFollowAI = commonlib.gettable("MyCompany.Aries.AI.AutoFollowAI");

	local jc = TeamClientLogics:GetJC();
	if(jc) then
		local rank_from = jc:GetTeamMemberIndexByNid(nid);
		local rank_to = jc:GetTeamMemberIndexByNid(Map3DSystem.User.nid);
		if(rank_from and rank_to) then
			-- follow a given player at 1.5 meters
			AutoFollowAI:Follow("follow", nid, (rank_to - rank_from)*default_follow_spacing);
		end
	end
end
