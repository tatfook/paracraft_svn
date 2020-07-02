--[[
Title: HaqiGroupManage
Author(s): Leio
Date: 2010/01/09

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupManage.lua");
MyCompany.Aries.Quest.NPCs.HaqiGroupManage.ShowPage()

NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupManage.lua");
local familyid = 48
MyCompany.Aries.Quest.NPCs.HaqiGroupManage.SaveChallengedToday(familyid)

local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
local nid = Map3DSystem.User.nid;
nid = tostring(nid);
local key = string.format("NPCs.HaqiGroupManage.DoSignIn%s_%d",nid,familyid);
local time = MyCompany.Aries.Player.LoadLocalData(key, "");
commonlib.echo("=======time");
commonlib.echo(time);
local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
commonlib.echo(today);

------------------------------------------------------------
]] 
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/Chat/BadWordFilter.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatProfile.lua");
NPL.load("(gl)script/apps/Aries/FamilyServer/FamilyServerSelect.lua");
NPL.load("(gl)script/apps/Aries/Friends/Main.lua");

local Pet = MyCompany.Aries.Pet;
-- create class
local libName = "HaqiGroupManage";
local HaqiGroupManage = {
	my_status = 2,--0:headman 1: assistant 2: normal
	group_info = nil,--家族信息
	member_list = nil,--成员信息
	selected_index = 1,--选中的索引
	assistant_list = nil,--副族长列表
	
	my_info = nil,--自己的信息
	my_group_last_signin = nil,--自己上一次签到时间
	
	myfamilyrank ={}, -- 成员积分榜
	is_edit = false,--是否在编辑状态
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.HaqiGroupManage", HaqiGroupManage);

function HaqiGroupManage.OnInit()
	local self = HaqiGroupManage;
	self.page = document:GetPageCtrl();
end
--获取个人的信息
function HaqiGroupManage.GetMyInfo(callbackFunc)
	local self = HaqiGroupManage;
	Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nil, "HaqiGroupManage.GetMyInfo", function (msg)
		--commonlib.echo("====after get user info in HaqiGroupManage");
		--commonlib.echo(msg);
		if(msg and msg.users and msg.users[1]) then
			--user info
			self.my_info= msg.users[1];
			if(callbackFunc)then
				callbackFunc();
			end
		end
	end,"access plus 0 day")
end
function HaqiGroupManage.SetValue_IsDirty(v)
	local self = HaqiGroupManage;
	self.is_dirty = v;	
end
--获取自己家族才信息
function HaqiGroupManage.GetMyGroup(id,callbackFunc,cache_policy)
	local self = HaqiGroupManage;
	if(not id)then return end
	if(self.is_dirty)then
		cache_policy = "access plus 0 day";
		self.is_dirty = false;
	end
	local msg = {
		idorname = id,
		cache_policy = cache_policy,
	}
	--commonlib.echo("===========before get a group in HaqiGroupManage.GetMyGroup");
	--commonlib.echo(msg);
	paraworld.Family.Get(msg,"group",function(msg)
		--commonlib.echo("===========after get a group in HaqiGroupManage.GetMyGroup");
		--commonlib.echo(msg);
		if(msg and not msg.errorcode)then
			self.group_info = msg;--家族信息
			self.group_info.blacklist = self.group_info.blacklist or {};--黑名单
			self.group_info.join_requirement = self.group_info.join_requirement or {};--家族设置

			self.my_status = 2;--假设自己是普通人员
			
			local status_list = {};--族长 副族长 身份列表
			local admin = msg.admin;
			local deputy = msg.deputy;
			admin = tonumber(admin);
			if(admin)then
				if(Map3DSystem.User.nid == admin)then
					self.my_status = 0; --自己是族长
				end
				status_list[admin] = 0;--记录族长
			end
			self.assistant_list = {};
			if(deputy)then
				local exist;
				for exist in string.gfind(deputy, "([^,]+)") do
					exist = tonumber(exist);
					if(Map3DSystem.User.nid == exist)then
						self.my_status = 1; --自己是副族长
					end
					status_list[exist] = 1;--记录副族长
					table.insert(self.assistant_list,exist);--副族长列表
				end
			end
			local members = msg.members;
			local members_list = {};
			--commonlib.echo("====before get user info in HaqiGroupManage.GetMyGroup");
			--commonlib.echo(members);
			
			-- NOTE: change of return format of msg.members 
			-- OLD: 
			--///     members  String，家族所有成员的NID，多个NID之间用英文逗号分隔
			-- NEW: 
			--///     members[list]  家族所有成员
			--///         nid  NID
			--///         contribute  对家族的贡献度
			--///         last  最后签到的时间，yyyy-MM-dd
			local userinfo_input_nids = "";
			local userinfo_input_nids_table = {};
	        local _, member;
	        for _, member in ipairs(msg.members) do
				userinfo_input_nids = userinfo_input_nids..member.nid..",";
				members_list[member.nid] = member;
				userinfo_input_nids_table[#userinfo_input_nids_table+1] = member.nid;
	        end

			local function Batch_callback(msg)
				--commonlib.echo("====after get user info in HaqiGroupManage.GetMyGroup");
				--commonlib.echo(msg);
				if(msg and msg.users and msg.users) then
					--user info
					self.member_list = msg.users; --成员列表
					
					--修正列表
					local k,v;
					for k,v in ipairs(self.member_list) do
						local nid = v.nid;
						v.vip = false;--设置vip
						v.online = true;--设置online
						v.status = status_list[nid] or 2;
						if(members_list[nid])then
							local group_ex = members_list[nid];
							v.contribute = group_ex.contribute;
							v.last = group_ex.last;
							--commonlib.echo("============myfamilyrank")
							--commonlib.echo(self.myfamilyrank[nid])
							if (self.myfamilyrank[nid]) then
								v.pvp = self.myfamilyrank[nid].pvp or 0;
								v.boss= self.myfamilyrank[nid].boss or 0;
								v.treasure= self.myfamilyrank[nid].treasure or 0;
								v.total_score = self.myfamilyrank[nid].total_score or 0;
							else
								v.pvp = 0;
								v.boss = 0;
								v.treasure = 0;
								v.total_score = 0;
							end

							if(nid == Map3DSystem.User.nid)then
								self.my_group_last_signin = group_ex.last;--记录自己上次签到时间
								self.my_group_contribute = group_ex.contribute; --记录自己上次签到次数
							end
						end
					end
					
					--commonlib.echo("====member");
					--commonlib.echo(self.member_list);
					if(callbackFunc)then
						callbackFunc();
					end
				end
			end

			local nCounter = 0;
			local nTotalCounter = #userinfo_input_nids_table;
			local users = {};
			local _, user_nid;
			for _, user_nid in ipairs(userinfo_input_nids_table) do
				Map3DSystem.App.profiles.ProfileManager.GetUserInfo(user_nid, "GetUserInfo", function (msg)
					nCounter = nCounter + 1;
					if(msg and msg.users and msg.users) then
						users[#users+1] = msg.users[1];
					end
					if(nTotalCounter == nCounter) then
						local msg = {users = users};
						Batch_callback(msg);
					end
				end, "access plus 1 year");
			end
		end
	end)
end

function HaqiGroupManage.TeleportToLaLa()
	 local insame_world = QuestHelp.InSameWorldByNum(0);
	if(not insame_world)then
			_guihelper.MessageBox("家族管理处位于哈奇岛上，不在当前岛屿，请先去哈奇岛吧");
		return
	end
	local pos = {20086.87,3.53,19828.49};
	local camera = {8.29,0.35,0.14};
	local msg = { aries_type = "OnMapTeleport", 
		position = pos, 
		camera = camera, 
		wndName = "map", 
	};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);

    --local HomeLandGateway = Map3DSystem.App.HomeLand.HomeLandGateway;
    --if(HomeLandGateway.IsInHomeland()) then
        ---- leave the homeland and teleport to lala
        --HomeLandGateway.SetTeleportBackPosition(20311, 0.8, 19737);
        --HomeLandGateway.Away();
    --else
        ---- directly teleport to lala
		--local params = {
			--asset_file = "character/v5/temp/Effect/LoyaltyDown_Impact_Base.x",
			--binding_obj_name = ParaScene.GetPlayer().name,
			--start_position = nil,
			--duration_time = 800,
			--force_name = nil,
			--begin_callback = function() 
					--local player = ParaScene.GetPlayer();
					--if(player and player:IsValid() == true) then
						--player:ToCharacter():Stop();
					--end
				--end,
			--end_callback = nil,
			--stage1_time = 600,
			--stage1_callback = function()
					--local player = ParaScene.GetPlayer();
					--if(player and player:IsValid() == true) then
						--player:SetPosition(20311, 0.8, 19737);
					--end
				--end,
			--stage2_time = nil,
			--stage2_callback = nil,
		--};
		--local EffectManager = MyCompany.Aries.EffectManager;
		--EffectManager.CreateEffect(params);
    --end
end

function HaqiGroupManage.GetRemoteRank(fmname)
	local self = HaqiGroupManage;
	local fid = ParaMisc.md5(fmname);
	local url = "%LOG%/rank/"..fid..".txt";
	--local url = "d:/cd.txt";
	-- 该函数仅在 userloginProcess 调用，考虑到用户可能切换帐号，所以每次帐号登录都需要重新下载该 url
	paraworld.CreateRPCWrapper("paraworld.GetMyFamilyRank", url);
	
	local function LoadRankStrToTable(s)
		local dt,t0={},{};
		local a=s,0;
		while true do			
			s1=string.find(a,"\n");
			if not s1 then break end;
			s2=string.sub(a,1,s1-1);
			a=string.sub(a,s1+1);
			--local _,_,nid,rtype,goal=string.find(s2,"^(%d+),(%a+),(%d+)$");	
			--nid=tonumber(nid);
			--if (not dt[nid]) then
				--dt[nid]={};
			--end
			--if (rtype=="pvp") then
				--dt[nid].pvp = tonumber(goal);
			--elseif (rtype=="boss") then
				--dt[nid].boss = tonumber(goal);
			--end
			local _,_,nid,rtype,goal,treasure = string.find(s2,"^(%d+),(%a+),(%d+),(%d+)$");	
			nid=tonumber(nid);
			if (not dt[nid]) then
				dt[nid]={};
			end
			if(goal) then
				dt[nid].total_score = tonumber(goal);
				dt[nid].pvp = tonumber(goal);
			end
			--if (rtype=="pvp") then
				--dt[nid].pvp = tonumber(goal);
			--elseif (rtype=="boss") then
				--dt[nid].boss = tonumber(goal);
			--end
			if(treasure) then
				dt[nid].treasure = tonumber(treasure);
			end
		end
		return dt; 
	end

	paraworld.GetMyFamilyRank(
		-- added forbid_reuse to close the connection immediately after request, since we no longer needs a connection to this server any more. 
		--{forbid_reuse=true},
		{}, 
		"default", function(msg)
		if(msg and msg.code==0 and msg.data and msg.rcode==200) then
			local data = msg.data;
			self.myfamilyrank= LoadRankStrToTable(data);
		end
	end)
end

function HaqiGroupManage.ShowPage(bRefresh)
	local self = HaqiGroupManage;
	
	self.Reset();
	self.GetMyInfo(function()
		if(not self.my_info)then return end
		if(not self.my_info.family or self.my_info.family == "")then
			_guihelper.Custom_MessageBox("<div style='margin-left:15px;margin-top:20px;text-align:center'>你尚未加入任何家族，可以在家族管理处创建或加入家族。</div>",function(result)
				if(result == _guihelper.DialogResult.Yes)then
					--local x,y,z = 20311,0.8,19737;
					--Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x= x, y = y, z = z});
					HaqiGroupManage.TeleportToLaLa()
				else
					--commonlib.echo("no");
				end
			end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/Coming_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return
		end
		local id = self.my_info.family;
		local cache_policy;
		if(bRefresh)then
			cache_policy = "access plus 0 day";
		end

		self.GetMyGroup(id,function(msg)
			
			--排序
			self.member_list = self.SortGroupList(self.member_list);
			
			--self.group_info = {
				--id = 1,
				--name = "永恒之塔",
				--desc = "哈哈哈哈",
				--level = 1,
				--maxcontain = 500,
			--}
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupManage.html", 
				name = "HaqiGroupManage.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				-- zorder = 1,
				allowDrag = false,
				directPosition = true,
					align = "_ct",
					x = -765/2,
					y = -495/2,
					width = 765,
					height = 495,
		});
		end,cache_policy);
	end);
end
--排序
--[[
	group_info = {
		///     id  家族ID
        ///     name  家族名称
        ///     desc  家族宣言
        ///     level  家族级别
        ///     admin  家族家族的NID
        ///     deputy  String，家族所有的副族长的NID，多个NID之间用英文逗号分隔
        ///     members  String，家族所有成员的NID，多个NID之间用英文逗号分隔
        ///     maxcontain  最大可拥有的家族成员数
        ///     createdate  创建时间 yyyy-MM-dd HH:mm:ss
        member_list = {
			{nid = 0, nickname = "", vip = false, online = false, status = 2,},
        }
	}
--]]
function HaqiGroupManage.OnClickSort(stype)
	local self = HaqiGroupManage;
	--commonlib.echo("============before sort");
	--commonlib.echo(self.member_list);
	self.member_list = self.SortGroupList(self.member_list,stype);
	self.page:Refresh(0.1);
end

function HaqiGroupManage.SortGroupList(temp,stype)
	local self = HaqiGroupManage;
	local result = {};
	if (stype) then
		stype = string.lower(stype);
	end
	if (stype=="pvp") then
		table.sort(temp, function(a, b)
		-- pvp 积分相等，比魔法星等级mlel；魔法星等级相等，比人气值popularity
			if (a.pvp==b.pvp and a.mlel==b.mlel) then
				return a.popularity >b.popularity
			elseif (a.pvp==b.pvp) then
				return a.mlel>b.mlel
			else
				return a.pvp>b.pvp
			end
		end);
		result = commonlib.deepcopy(temp);
	elseif (stype=="boss") then
		table.sort(temp, function(a, b)
		-- 挑战boss 积分相等，比魔法星等级mlel；魔法星等级相等，比人气值popularity
			if (a.boss==b.boss and a.mlel==b.mlel) then
				return a.popularity >b.popularity
			elseif (a.boss==b.boss) then
				return a.mlel>b.mlel
			else
				return a.boss>b.boss
			end
		end);
		result = commonlib.deepcopy(temp);
	elseif (stype=="contribute") then
		table.sort(temp, function(a, b)
			return (a.contribute > b.contribute);
		end);
		result = commonlib.deepcopy(temp);
	elseif (stype=="treasure") then
		table.sort(temp, function(a, b)
			return (a.treasure > b.treasure);
		end);
		result = commonlib.deepcopy(temp);
	elseif (stype=="combatlel") then
		table.sort(temp, function(a, b)
			return (a.combatlel > b.combatlel);
		end);
		result = commonlib.deepcopy(temp);
	elseif (stype=="school") then
		table.sort(temp, function(a, b)
			return (a.combatschool < b.combatschool);
		end);
		result = commonlib.deepcopy(temp);
	elseif (stype=="occup") then
		table.sort(temp, function(a, b)
			return (a.status < b.status);
		end);
		result = commonlib.deepcopy(temp);
	else
		local list_online = {};
		local list_offline = {};
		local my_item;
		local my_nid = Map3DSystem.User.nid;
		local k,v;
		for k,v in ipairs(temp)  do
			if(v.nid == my_nid)then
				 my_item = v;
			else
	   			if(v.online)then
	   	   			table.insert(list_online,v);
	   			else
	   				table.insert(list_offline,v);
	   			end
   			end
		end
		--table.sort(list_online, sort_vip);

		if(my_item)then
			table.insert(result,my_item);
		end
		for k,v in  ipairs(list_online)  do
   			table.insert(result,v);
		end
		for k,v in  ipairs(list_offline)  do
   			table.insert(result,v);
		end
	end	

	--commonlib.echo("===============after sort table in HaqiGroupManage.SortGroupList");
	--commonlib.echo(result);
	return result;
end

function HaqiGroupManage.BuildURL(index)
	if(MyCompany.Aries.Quest.NPCs.HaqiGroupManage.member_list)then
		local item = MyCompany.Aries.Quest.NPCs.HaqiGroupManage.member_list[index];
		if(item)then
		    local nid = item.nid;
		    local url = System.localserver.UrlHelper.BuildURLQuery("script/apps/Aries/Profile/FullProfile.html", {nid=nid, minifamilyview = "true",});
            return url;
        end
    end
end

function HaqiGroupManage.DoClick(index)
	local self = HaqiGroupManage;
	self.selected_index = index;
	
	if(self.page)then
		local url = HaqiGroupManage.BuildURL(index)
		if(url)then
			self.page:SetValue("contentframe",url);
		end
		self.page:Refresh(0.01);
	end
end
function HaqiGroupManage.ShowInvitePanel()
	local self = HaqiGroupManage;
	if(self.group_info and self.member_list)then
		local maxcontain = self.group_info.maxcontain;
		local len = #self.member_list;
		if(len >= maxcontain)then
			local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你的家族人数已满，无法邀请其他人加入了。</div>";
			_guihelper.Custom_MessageBox(s,function(result)
				
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return
		end
		
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupManage_invite.html", 
			name = "HaqiGroupManage.ShowInvitePanel", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -322/2,
				y = -216,
				width = 322,
				height = 216,
		});
	end
end
--家族聊天
function HaqiGroupManage.DoChat()
	local self = HaqiGroupManage;
	if(self.IsBlackMember(Map3DSystem.User.nid))then
		_guihelper.MessageBox("你已经在家族的黑名单中，不能家族聊天了！");
		return;
	end
	-- call family chat window
	System.App.Commands.Call("Profile.Aries.FamilyChatWnd");
	-- close manager page
	HaqiGroupManage.ClosePage();
end
--邀请成员
function HaqiGroupManage.DoInvite(nid)
	local self = HaqiGroupManage;
	if(not nid or not self.group_info)then return end
	local msg = {
		familyid = self.group_info.id,
		tonid = nid,
	}
	--commonlib.echo("============before invite in HaqiGroupManage.DoInvite");
	--commonlib.echo(msg);
	Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nid, "", function (args)
		--commonlib.echo("=======args");
		--commonlib.echo(args);
		if(args and args.users)then
			local userinfo = args.users[1];
			local family = commonlib.Encoding.EncodeStr(userinfo.family);
			local len = ParaMisc.GetUnicodeCharNum(family);
			if(len > 0)then
				local nickname = userinfo.nickname;
				local s = string.format("%s已经加入家族了，不需要被邀请了！",commonlib.Encoding.EncodeStr(nickname));
				_guihelper.MessageBox(s);
				return
			end
		end
		paraworld.Family.Invite(msg,"",function(msg)
			--commonlib.echo("============after invite in HaqiGroupManage.DoInvite");
			--commonlib.echo(msg);
			if(msg and msg.issuccess)then
			
				local ids = nid..","..Map3DSystem.User.nid;
				Map3DSystem.App.profiles.ProfileManager.GetUserInfo(ids, "", function (msg)
					if(msg and msg.users) then
						local users = msg.users;
						local k,v;
						local nickname = "";
						local sender_nickname = "";
						for k,v in ipairs(users) do
							if(v.nid == nid)then
								nickname = v.nickname;
							elseif(v.nid == Map3DSystem.User.nid)then
								sender_nickname = v.nickname;
							end
						end
					
						Map3DSystem.App.profiles.ProfileManager.GetJID(nid, function(jid)
							if(jid)then
								local args = {
									type = "invite",
									nid = nid,
									jid = jid,
									nickname = nickname,
									group_id = self.group_info.id,
									group_name = self.group_info.name,
								
									sender_jid = Map3DSystem.User.jid,
									sender_nid = Map3DSystem.User.nid,
									sender_nickname = sender_nickname,
								}
								if(MyCompany.Aries.Quest.NPCs.HaqiGroupClient.SendMessage(args,jid)) then
									local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>邀请已经发出，请耐心等待对方答复。</div>";
									_guihelper.Custom_MessageBox(s,function(result)
								
									end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
								else
									_guihelper.MessageBox("你发送请求的频率太高了,请稍候再试");
								end
							end
						end)
					end
				end)
			end
		end);
	end);
end
--开出成员
function HaqiGroupManage.DoFire()
	local self = HaqiGroupManage;
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	local can_pass = DealDefend.CanPass();
	if(not can_pass)then
		return
	end
	local index = self.selected_index;
	if(self.member_list)then
		local item = self.member_list[index];
		if(item)then
			if(item.nid == Map3DSystem.User.nid)then
				local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你不能开除自己。</div>";
				_guihelper.Custom_MessageBox(s,function(result)
					
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
				return
			end
			local link_str = HaqiGroupManage.GetLinkStr(item.nickname,item.nid);
			local s = string.format("<div style='margin-left:15px;margin-top:20px;'>你确定要把%s从家族中开除吗？</div>",link_str);
			_guihelper.MessageBox(s, function(res)
				if(res and res == _guihelper.DialogResult.Yes) then
					--开除
					local msg = {
						nid = Map3DSystem.User.nid,
						familyid = self.group_info.id,
						removenid = item.nid,
					};
					--commonlib.echo("=============before fire a member in HaqiGroupManage.DoAppoint_Assistant");
					--commonlib.echo(msg);
					paraworld.Family.RemoveMember(msg,"",function(msg)
						--commonlib.echo("=============after fire a member in HaqiGroupManage.DoAppoint_Assistant");
						--commonlib.echo(msg);
						if(msg and msg.issuccess)then
							Map3DSystem.App.profiles.ProfileManager.GetJID(item.nid, function(jid)
							if(jid)then
								local args = {
									type = "fired",
									nid = item.nid,
									jid = jid,
									nickname = "",
									group_id = self.group_info.id,
									group_name = self.group_info.name,
									
								}
								MyCompany.Aries.Quest.NPCs.HaqiGroupClient.SendMessage(args,jid);
								self.DoRefresh();
							end
						end)
						end
					end);
				end
			end, _guihelper.MessageBoxButtons.YesNo);
		end
	end
end
function HaqiGroupManage.FormatID(id)
    id = tonumber(id);
    if(id)then
        if(id <= 9999)then
            id = string.format("%05d", id)
            return id;
        end
        return tostring(id);
    end
    return "";
end
--退出家族
function HaqiGroupManage.DoQuit()
	local self = HaqiGroupManage;
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	local can_pass = DealDefend.CanPass();
	if(not can_pass)then
		return
	end
	--族长不能直接退出家族 只能转让
	if(self.my_status == 0)then
		return 
	end
	--通知 族长 副族长
	local function beep_quit()
		if(self.group_info)then
			local name = self.group_info.name;
			local id = self.group_info.id;
			if(self.group_info)then

				local nid_list = {};
				local admin = self.group_info.admin;
				if(admin)then
					table.insert(nid_list,admin);
				end
				local deputy = self.group_info.deputy;
				if(deputy)then
					local exist;
					for exist in string.gfind(deputy, "([^,]+)") do
						exist = tonumber(exist);
						table.insert(nid_list,exist);
					end
				end
				MyCompany.Aries.Quest.NPCs.HaqiGroupClient.GetUserInfo(nil,function(msg)
					local is_joined = false;
					if(msg.family and msg.family ~= "")then
						--已经加入家族
						is_joined = true; 
					end
					if(not is_joined)then
						return
					end
					local args = {
						type = "got_quit_info",
						nid = msg.nid,
						jid = msg.jid,
						nickname = msg.nickname,
						group_id = id,
						group_name = name,
					}
					for k,dest_nid in ipairs(nid_list) do
						Map3DSystem.App.profiles.ProfileManager.GetJID(dest_nid, function(jid)
							if(jid)then
								local bIsSucceed = MyCompany.Aries.Quest.NPCs.HaqiGroupClient.SendMessage(args,jid, function(msg)
								end)
							end
						end)
					end
				end)
			end
		end
	end	

	local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你确定要退出家族：%s(%s)吗？</div>",name or "",self.FormatID(id) or "");
	_guihelper.MessageBox(s, function(res)
		if(res and res == _guihelper.DialogResult.Yes) then
			--开除
			local msg = {
				familyid = self.group_info.id,
			};
			beep_quit();
			--commonlib.echo("=============before quit in HaqiGroupManage.DoAppoint_Assistant");
			--commonlib.echo(msg);
			paraworld.Family.Quit(msg,"",function(msg)
				--commonlib.echo("=============after quit in HaqiGroupManage.DoAppoint_Assistant");
				--commonlib.echo(msg);
				if(msg and msg.issuccess) then
					-- auto refresh the user self info in memory for family update
					System.App.profiles.ProfileManager.GetUserInfo(nil, nil, nil, "access plus 0 day");
					-- send nickname update to chat channel
					MyCompany.Aries.BBSChatWnd.SendUserNicknameUpdate();
					-- auto leave family chat room
					MyCompany.Aries.Chat.FamilyChatWnd.LeaveMyFamilyChatRoom();
					--退出家族后 直接关闭页面
					self.ClosePage();
				end
			end);
		end
	end, _guihelper.MessageBoxButtons.YesNo);
end
--任命副族长
function HaqiGroupManage.DoAppoint_Assistant(index)
	local self = HaqiGroupManage;
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	local can_pass = DealDefend.CanPass();
	if(not can_pass)then
		return
	end
	index = tonumber(index);
	if(self.group_info)then
		local deputy = self.group_info.deputy;
		if(deputy)then
			local len = 0;
			for __ in string.gfind(deputy, "([^,]+)") do 
				len = len + 1;
			end
			if(len > 5)then
				local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你已经有5名副族长了，不能再任命更多的副族长了。</div>";
				_guihelper.Custom_MessageBox(s,function(result)
					
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
				return
			end
		end
	end
	if(self.member_list)then
		local item = self.member_list[index];
		if(item)then
			local link_str = HaqiGroupManage.GetLinkStr(item.nickname,item.nid);
			local s = string.format("<div style='margin-left:15px;margin-top:20px;'>你确定要任命%s为副族长吗？</div>",link_str);
			_guihelper.MessageBox(s, function(res)
				if(res and res == _guihelper.DialogResult.Yes) then
					--任命副族长
					local msg = {
						familyid = self.group_info.id,
						newdeputynid = item.nid,
					};
					--commonlib.echo("=============before set deputy in HaqiGroupManage.DoAppoint_Assistant");
					--commonlib.echo(msg);
					paraworld.Family.SetDeputy(msg,"",function(msg)
						--commonlib.echo("=============after set deputy in HaqiGroupManage.DoAppoint_Assistant");
						--commonlib.echo(msg);
						if(msg and msg.issuccess)then
							--找自己的名字
							Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nil, "", function (msg)
								if(msg and msg.users and msg.users[1]) then
									local result = msg.users[1];
									local nid = result.nid;
									local nickname = result.nickname;
									
									--找副族长的jid
									Map3DSystem.App.profiles.ProfileManager.GetJID(item.nid, function(jid)
										if(jid)then
											local args = {
												type = "appoint_assistant",
												nid = item.nid,
												jid = jid,
												nickname = nickname,
												group_id = self.group_info.id,
												group_name = self.group_info.name,
												
											}
											MyCompany.Aries.Quest.NPCs.HaqiGroupClient.SendMessage(args,jid);
											self.DoRefresh();
										end
									end)
								end
							end)
						end
					end);
				end
			end, _guihelper.MessageBoxButtons.YesNo);
		end
	end
end
--撤销副族长
function HaqiGroupManage.DoQuit_Assistant(index)
	local self = HaqiGroupManage;
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	local can_pass = DealDefend.CanPass();
	if(not can_pass)then
		return
	end
	index = tonumber(index);
	if(self.member_list)then
		local item = self.member_list[index];
		if(item)then
			local link_str = HaqiGroupManage.GetLinkStr(item.nickname,item.nid); 
			local s = string.format("<div style='margin-left:15px;margin-top:20px;width:278px;height:150px;'>你确定要撤销%s的副族长任命吗？</div>",link_str);
			_guihelper.MessageBox(s, function(res)
				if(res and res == _guihelper.DialogResult.Yes) then
					--撤销副族长
					local msg = {
						familyid = self.group_info.id,
						removenid = item.nid,
					};
					--commonlib.echo("=============before RemoveDeputy in HaqiGroupManage.DoAppoint_Assistant");
					--commonlib.echo(msg);
					paraworld.Family.RemoveDeputy(msg,"",function(msg)
						--commonlib.echo("=============after RemoveDeputy in HaqiGroupManage.DoAppoint_Assistant");
						--commonlib.echo(msg);
						if(msg and msg.issuccess)then
							--找自己的名字
							Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nil, "", function (msg)
								if(msg and msg.users and msg.users[1]) then
									local result = msg.users[1];
									local nid = result.nid;
									local nickname = result.nickname;
									
									--找副族长的jid
									Map3DSystem.App.profiles.ProfileManager.GetJID(item.nid, function(jid)
										if(jid)then
											local args = {
												type = "fire_assistant",
												nid = item.nid,
												jid = jid,
												nickname = nickname,
												group_id = self.group_info.id,
												group_name = self.group_info.name,
												
											}
											MyCompany.Aries.Quest.NPCs.HaqiGroupClient.SendMessage(args,jid);
											self.DoRefresh();
										end
									end)
								end
							end)
						end
					end);
				end
			end, _guihelper.MessageBoxButtons.YesNo);
		end
	end
end
--转让族长
function HaqiGroupManage.DoHand_Headman(index)
	local self = HaqiGroupManage;
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	local can_pass = DealDefend.CanPass();
	if(not can_pass)then
		return
	end
	index = tonumber(index);
	if(self.member_list)then
		local item = self.member_list[index];
		if(item)then
			local link_str = HaqiGroupManage.GetLinkStr(item.nickname,item.nid);
			local s = string.format("<div style='margin-left:15px;margin-top:20px;'>你确定要将族长职位转让给%s吗？</div>",link_str);
			_guihelper.MessageBox(s, function(res)
				if(res and res == _guihelper.DialogResult.Yes) then
					--TODO:转让族长
					local msg = {
						familyid = self.group_info.id,
						newadmin = item.nid,
					};
					commonlib.echo("=============before set admin in HaqiGroupManage.DoAppoint_Assistant");
					commonlib.echo(msg);
					paraworld.Family.SetAdmin(msg,"",function(msg)
						commonlib.echo("=============after set admin in HaqiGroupManage.DoAppoint_Assistant");
						commonlib.echo(msg);
						if(msg and msg.issuccess)then
							--找自己的名字
							Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nil, "", function (msg)
								if(msg and msg.users and msg.users[1]) then
									local result = msg.users[1];
									local nid = result.nid;
									local nickname = result.nickname;
									
									--找接任族长的jid
									Map3DSystem.App.profiles.ProfileManager.GetJID(item.nid, function(jid)
										if(jid)then
											local args = {
												type = "hand_headman",
												nid = item.nid,
												jid = jid,
												nickname = nickname,
												group_id = self.group_info.id,
												group_name = self.group_info.name,
												
											}
											MyCompany.Aries.Quest.NPCs.HaqiGroupClient.SendMessage(args,jid);
											self.DoRefresh();
										end
									end)
								end
							end)
						end
					end);
				end
			end, _guihelper.MessageBoxButtons.YesNo);
		end
	end
end
--编辑群信息
function HaqiGroupManage.EditGroupInfo()
	local self = HaqiGroupManage;
	--只有群主 可以更改群信息
	if(self.my_status == 0)then
		self.is_edit = true;
		if(self.page)then
			self.page:SetValue("content_info",self.group_info.desc or "");
			self.page:Refresh(0.01);
		end
	end
end
--保存黑名单
function HaqiGroupManage.SaveBlackListInfo(blacklist)
	local self = HaqiGroupManage;
	--只有群主 可以更改群信息
	if(self.group_info)then
		local msg = {
				familyid = self.group_info.id,
				desc = self.group_info.desc,
				blacklist = blacklist,
				join_requirement = self.group_info.join_requirement --家族设置
			}
		commonlib.echo("===========before update group blacklist in HaqiGroupManage.SaveBlackListInfo");
		commonlib.echo(msg);
		paraworld.Family.UpdateDesc(msg,"",function(msg)
			commonlib.echo("===========before update group blacklist in HaqiGroupManage.SaveBlackListInfo");
			commonlib.echo(msg);
			if(msg and msg.issuccess)then
				_guihelper.MessageBox("保存成功！");
			end
		end);
	end
end
--保存群信息
function HaqiGroupManage.SaveGroupInfo()
	local self = HaqiGroupManage;
	--只有群主 可以更改群信息
	if(self.my_status == 0)then
		if(self.page)then
			local content_info = self.page:GetValue("content_info");
			local content_info_len = ParaMisc.GetUnicodeCharNum(content_info);
			if(content_info_len > 30)then
				_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>家族宣言不能超过30个字。</div>");
				return;
			end
			content_info = MyCompany.Aries.Chat.BadWordFilter.FilterString(content_info);
			if(content_info)then
				local msg = {
					familyid = self.group_info.id,
					desc = content_info,
					blacklist = self.group_info.blacklist,
					join_requirement = self.group_info.join_requirement --家族设置
				}
				commonlib.echo("===========before update group desc in HaqiGroupManage.SaveGroupInfo");
				commonlib.echo(msg);
				paraworld.Family.UpdateDesc(msg,"",function(msg)
					commonlib.echo("===========before update group desc in HaqiGroupManage.SaveGroupInfo");
					commonlib.echo(msg);
					if(msg and msg.issuccess)then
						self.is_edit = false;
						self.group_info.desc = content_info;
						self.page:Refresh(0.01);
						-- update my family info for new desc
						-- TODO: update the family entry of local server in the post_processor
						local Friends = MyCompany.Aries.Friends;
						Friends.GetMyFamilyInfo(function() end, "access plus 0 day");
						-- send update for family desc update
						NPL.load("(gl)script/apps/Aries/Chat/FamilyChatWnd.lua");
						MyCompany.Aries.Chat.FamilyChatWnd.SendFamilyDescUpdate();
					end
				end);
			end
		end
	end
end
--记录今天签到过
function HaqiGroupManage.SaveChallengedToday(familyid)
	familyid = familyid or 0
	local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local nid = Map3DSystem.User.nid;
	nid = tostring(nid);
	local key = string.format("NPCs.HaqiGroupManage.DoSignIn%s_%d",nid,familyid);
	MyCompany.Aries.Player.SaveLocalData(key,today);
end
--今天是否已经签到过
function HaqiGroupManage.IsSignInToday(familyid)
	familyid = familyid or 0
	local my_last_signin = HaqiGroupManage.my_group_last_signin;	

	local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local nid = Map3DSystem.User.nid;
	nid = tostring(nid);
	local key = string.format("NPCs.HaqiGroupManage.DoSignIn%s_%d",nid,familyid);
	local time = MyCompany.Aries.Player.LoadLocalData(key, "");
	if(time == today)then
		return true;
	else
	-- 如果本机没有保存签到记录，则判断用户最近一次签到时间是否是今天，如果是新加入家族或者已在其他机器上签过到，就返回true
		if (my_last_signin) then 
			if(today==my_last_signin)then
				return true;
			end
		end
	end
end

--提升活跃度
--@IsAutoSign : 自动签到
function HaqiGroupManage.DoSignIn(IsAutoSign)
	local self = HaqiGroupManage;
	--local group_info = self.group_info;
	--local createdate = group_info.createdate;
	if (IsAutoSign) then
		if (IsAutoSign=="clicksign") then
			IsAutoSign = false;
		end
	end

	if(MyCompany.Aries.Player.GetLevel() < 20) then
		if(not IsAutoSign) then
			_guihelper.MessageBox("家族签到20级之后开启， 你的等级不够，快做任务升级吧");
		end
		return;
	end

	function isTheSameDay(a,b)
		--local a = "2010-01-01 12586";
		if(not a or not b)then return end
		local __,__,a_year = string.find(a,"(.+)%s");
		if(a_year == b)then
			return true;
		end
	end
	----今天刚加入家族
	--if(isTheSameDay(createdate,self.my_group_last_signin))then
		--local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你今天刚加入家族，还不能提升家族活跃度。请明天再来提升家族活跃度吧！</div>";
		--_guihelper.Custom_MessageBox(s,function(result)
			--if(result == _guihelper.DialogResult.OK)then
			--end
		--end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		--return
	--end
	--今天是否已经签到过
	
--	if(group_info and group_info.id)then
--		local familyid = group_info.id;
	local familyid = MyCompany.Aries.Friends.GetMyFamilyID();
	if (familyid) then
		if(self.IsSignInToday(familyid))then
--			commonlib.echo("================IsAutoSign");
--			commonlib.echo(IsAutoSign);
			if (IsAutoSign) then
			else
				local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>每天只能为家族贡献1点活跃度，你今天已经贡献过了。请明天再来吧！</div>";
				_guihelper.Custom_MessageBox(s,function(result)
					if(result == _guihelper.DialogResult.OK)then
					end
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			end
			return 
		end
		
		local msg = {
			familyid = familyid,
		}
		--commonlib.echo("==========before singin");
		--commonlib.echo(msg);
		paraworld.Family.SignIn(msg,nil,function(msg)
			--commonlib.echo("==========after singin");
			--commonlib.echo(msg);	
			if(msg and msg.issuccess)then
				self.SaveChallengedToday(familyid);--记录今天已经签到过
				if (IsAutoSign) then
				else
					local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>太棒了！你已经为你的家族贡献了1点活跃度！</div>";
					_guihelper.Custom_MessageBox(s,function(result)
						if(result == _guihelper.DialogResult.OK)then
							self.DoRefresh();
						end
					end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
				end
			elseif(msg and msg.errorcode == 433)then

				if (IsAutoSign) then
				else
					local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
					local s;
					if(today==self.my_group_last_signin and self.my_group_contribute>0)then
						s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>每天只能为家族贡献1点活跃度，你今天已经贡献过了。请明天再来吧！</div>";
					else
						s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你今天刚加入家族，还不能提升家族活跃度。请明天再来提升家族活跃度吧！</div>";
					end

					_guihelper.Custom_MessageBox(s,function(result)
						if(result == _guihelper.DialogResult.OK)then
						end
					end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
				end
			end
			
		end);
	end
--	end
end

--解散家族
function HaqiGroupManage.DoDisband()
	local self = HaqiGroupManage;
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	local can_pass = DealDefend.CanPass();
	if(not can_pass)then
		return
	end
	--判断家族人数
	local list = self.member_list;
	if(list)then
		local count = #list;
		if(count > 1)then
			local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你的家族有其他成员加入，目前不能解散家族。</div>";
			_guihelper.Custom_MessageBox(s,function(result)
				if(result == _guihelper.DialogResult.OK)then
				end
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return
		end
	end
	
	local group_info = self.group_info;
	if(group_info and group_info.id)then
		local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你确定要解散该家族吗？</div>";
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.Yes)then
				--解散家族
				local familyid = group_info.id;
				local msg = {
					familyid = familyid,
				}
				commonlib.echo("==========before Delete group");
				commonlib.echo(msg);
				paraworld.Family.Delete(msg,nil,function(msg)
					commonlib.echo("==========after Delete group");
					commonlib.echo(msg);	
					if(msg and msg.issuccess)then
						self.ClosePage();

						MyCompany.Aries.Friends.familyworld = "";
						MyCompany.Aries.FamilyServer.FamilyServerSelect.familyworldname = "";
						MyCompany.Aries.FamilyServer.FamilyServerSet.familyworldindex = nil;

						local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你已经解散了自己的家族。你可以选择其他家族加入。</div>";
						_guihelper.Custom_MessageBox(s,function(result)
							if(result == _guihelper.DialogResult.OK)then
							end
						end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
					end
				end)
				
			else
				commonlib.echo("no");
			end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Cancel_32bits.png; 0 0 153 49"});

	end
end
--刷新列表
function HaqiGroupManage.DoRefresh()
	local self = HaqiGroupManage;
	--self.GetMyInfo(function()
		--local id = self.my_info.family;
		--self.GetMyGroup(id,function(msg)
			----排序
			--self.member_list = self.SortGroupList(self.member_list);
			--if(self.page)then
				--self.page:Refresh(0);
			--end
		--end);
	--end);
	self.ClosePage();
	self.ShowPage(true);
end
function HaqiGroupManage.ClosePage()
	local self = HaqiGroupManage;
	if(self.page)then
		self.page:CloseWindow();
	end
end
function HaqiGroupManage.Reset()
	local self = HaqiGroupManage;
	self.my_status = 2;--0:headman 1: assistant 2: normal
	self.group_info = nil;--家族信息
	self.member_list = nil;--成员信息
	self.selected_index = 1;--选中的索引
	self.assistant_list = nil;--副族长列表
	
	self.my_info = nil;--自己的信息
	self.is_edit = false;
end
function HaqiGroupManage.ShowFullProfile(nid)
	if(not nid)then return end
	System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
end
function HaqiGroupManage.GetLinkStr(nickname,nid)
	if(not nickname or not nid)then return "" end
	nid = tostring(nid);
	local s = string.format([[<a onclick="MyCompany.Aries.Quest.NPCs.HaqiGroupManage.ShowFullProfile" param1='%s'>%s(%s)</a>]],nid,nickname,MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid));
	return s;
end

function HaqiGroupManage.GetMLevel(index)
	if(HaqiGroupManage.member_list)then
		local item = HaqiGroupManage.member_list[index];
				--commonlib.echo("!!!!!!!!!!!!:GetMLevel");
				--commonlib.echo(HaqiGroupManage.member_list);

		if(item)then
			if( item.mlevel == nil)then
				local nid = item.nid;
				--commonlib.echo("!!!!!!!!!!!!:GetMLevel1");
				--commonlib.echo(nid);
				if( nid ~= System.App.profiles.ProfileManager.GetNID() )then
					Pet.CreateOrGetDragonInstanceBean( nid, function(msg)
						--commonlib.echo("!!!!!!!!!!!!:GetMLevel 2");
						--commonlib.echo(msg);
						if(msg and msg.bean)then
							--commonlib.echo(index);
							--commonlib.echo(HaqiGroupManage.member_list[index]);
							--HaqiGroupManage.member_list[index].mlevel = msg.bean.mlel;
							--HaqiGroupManage.member_list[index].energy = msg.bean.energy;
							--commonlib.echo(HaqiGroupManage.member_list[index]);

							if(item)then
								item.mlevel = msg.bean.mlel;
								item.energy = msg.bean.energy;
							end
							if(HaqiGroupManage.page)then
								HaqiGroupManage.page:Refresh(0.01);
							end
						end
					end,"access plus 1 minutes");
					return "";
				else
					local bean = MyCompany.Aries.Pet.GetBean();
					--HaqiGroupManage.member_list[index].mlevel = bean.mlel;
					--HaqiGroupManage.member_list[index].energy = bean.energy;

					if(item)then
						item.mlevel = bean.mlel;
						item.energy = bean.energy;
					end
					if(bean.mlel>0)then
						return "Texture/Aries/Desktop/CombatCharacterFrame/MagicStar/" .. bean.mlel .. "_32bits.png;0 0 16 10";
					else
						return "";
					end
				end
			else
				if( item.mlevel>0)then
					return "Texture/Aries/Desktop/CombatCharacterFrame/MagicStar/" .. item.mlevel .. "_32bits.png;0 0 16 10";
				else
					return "";
				end
			end
        end
    end
end

function HaqiGroupManage.OnClickMagicStar(index)
	if(HaqiGroupManage.member_list)then
		local item = HaqiGroupManage.member_list[index];
		if(item)then
			MyCompany.Aries.Desktop.CombatProfile.ShowPage(item.nid);
		end
	end
end

function HaqiGroupManage.ShowLevel(index)
	if(HaqiGroupManage.member_list)then
		local item = HaqiGroupManage.member_list[index];
		if(item)then
			--commonlib.echo("!!:ShowLevel");
			--commonlib.echo(item.mlevel);
			if(item.mlel and item.mlel > 0)then
				return item.mlel;
			else
				return "0";
			end
		end
	end
end

function HaqiGroupManage.ShowMS(index)
	if(HaqiGroupManage.member_list)then
		local item = HaqiGroupManage.member_list[index];
		if(item)then
			--commonlib.echo("!!:ShowMS 0");
			--commonlib.echo(item.energy);
			--commonlib.echo(item.mlel);

			if(item.energy and item.energy > 0 and item.mlel and item.mlel > 0)then
				--commonlib.echo("!!:ShowMS 1");
				
				return true;
			else
				--commonlib.echo("!!:ShowMS 2");

				return false;
			end
		end
	end
end
function HaqiGroupManage.ShowPage_BlackList()
	System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupBlackList.html", 
				name = "HaqiGroupManage.ShowPage_BlackList", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				--enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				-- zorder = 1,
				allowDrag = false,
				directPosition = true,
					align = "_ct",
					x = -300/2,
					y = -495/2,
					width = 300,
					height = 495,
		});
end
function HaqiGroupManage.IsBlackMember(nid)
	local self = HaqiGroupManage;
	nid = tonumber(nid);
	if(not nid)then return end
	if(self.group_info and self.group_info.blacklist)then
		local blacklist = self.group_info.blacklist;
		local k,v;
		for k,v in ipairs(blacklist) do
			if(nid == v)then
				return true;
			end
		end
	end
end
function HaqiGroupManage.ShowPage_GroupSetting()
	System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupSettingPage.html", 
				name = "HaqiGroupManage.ShowPage_GroupSetting", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				-- zorder = 1,
				allowDrag = false,
				directPosition = true,
					align = "_ct",
					x = -400/2,
					y = -250/2,
					width = 400,
					height = 250,
		});
end
--保存家族设置
function HaqiGroupManage.SaveGroupSetting(setting)
	local self = HaqiGroupManage;
	if(not setting)then return end
	--只有群主 可以保存家族设置
	if(self.group_info)then
		local msg = {
				familyid = self.group_info.id,
				desc = self.group_info.desc,
				blacklist = self.group_info.blacklist,
				join_requirement = setting,
			}
		commonlib.echo("===========before update group blacklist in HaqiGroupManage.SaveGroupSetting");
		commonlib.echo(msg);
		paraworld.Family.UpdateDesc(msg,"",function(msg)
			commonlib.echo("===========after update group blacklist in HaqiGroupManage.SaveGroupSetting");
			commonlib.echo(msg);
			if(msg and msg.issuccess)then
				self.group_info.join_requirement = setting;
				_guihelper.MessageBox("保存成功！");
			end
		end);
	end
end