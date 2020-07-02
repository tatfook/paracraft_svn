--[[
Title: 
Author(s): Leio
Date: 2011/07/04
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Family/FamilyManager.lua");
local FamilyManager = commonlib.gettable("Map3DSystem.App.Family.FamilyManager");
local family_manager = FamilyManager.CreateOrGetManager();
family_manager:DoDonateMyItems();

族长：邀请会员 开除会员 任命副族长 转让族长 解散家族 
副族长：邀请会员 退出家族
成员：退出家族


Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nil, nil, function (msg)end,"access plus 15 second")
Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nil, nil, function (msg)end,"access plus 15 second")
-------------------------------------------------------
]]
local Player = commonlib.gettable("MyCompany.Aries.Player");

NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
local Friends = commonlib.gettable("MyCompany.Aries.Friends");
NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.family.lua");
NPL.load("(gl)script/apps/Aries/Chat/BadWordFilter.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatProfile.lua");
NPL.load("(gl)script/apps/Aries/FamilyServer/FamilyServerSelect.lua");
NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
NPL.load("(gl)script/ide/Encoding.lua");
local Encoding = commonlib.gettable("commonlib.Encoding");
NPL.load("(gl)script/apps/IMServer/IMserver_client.lua");
local JabberClientManager = commonlib.gettable("IMServer.JabberClientManager");

NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationHelper.lua");
local GemTranslationHelper = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationHelper");
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");

NPL.load("(gl)script/apps/Aries/Family/FamilyMsg.lua");
local FamilyMsg = commonlib.gettable("Map3DSystem.App.Family.FamilyMsg");
NPL.load("(gl)script/apps/Aries/Family/FamilyMembersPage.lua");
local FamilyMembersPage = commonlib.gettable("Map3DSystem.App.Family.FamilyMembersPage");

local FamilyManager = commonlib.gettable("Map3DSystem.App.Family.FamilyManager");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");

-- members of family
FamilyManager.members_list = nil;
FamilyManager.front_pvp_members_list = nil;
FamilyManager.front_pve_members_list = nil;
FamilyManager.complete_members_info = false;
FamilyManager.family_info = nil;
FamilyManager.global_jc = nil;

FamilyManager.family_bag_id = 50100;

function FamilyManager.CreateOrGetManager()
	if(not FamilyManager.manager_instance)then
		FamilyManager.manager_instance = FamilyManager:new();
		FamilyManager.manager_instance:OnInit();
		FamilyManager.manager_instance:Refresh();
	end
	if(not FamilyManager.global_jc)then
		FamilyManager.global_jc = JabberClientManager.CreateJabberClient(Map3DSystem.User.jid);
	end
	return FamilyManager.manager_instance;
end
function FamilyManager:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end
function FamilyManager:OnInit()
	
end
function FamilyManager:GetJC()
	return FamilyManager.global_jc;
end
--0 族长 1 副族长 2 成员
function FamilyManager:GetMyRole()
	local my_info = self:GetUserInfoAboutFamily();
	local role_status = 2;
	if(my_info and my_info.role_status)then
		role_status = my_info.role_status;
	end
	return role_status;
end
function FamilyManager:IsMember()
	local m = self:GetUserInfoAboutFamily();
	if(m)then
		return true;
	end
end
function FamilyManager:GetUserInfoAboutFamily(nid)
	local nid = nid or Map3DSystem.User.nid;
	if(self.members_list)then
		local k,m;
		for k,m in ipairs(self.members_list) do
			if(m.nid == nid)then
				return m;
			end
		end
	end
end
--@param only_show_online:是否只显示在线成员
function FamilyManager:GetMembers(only_show_online)
	if(only_show_online and self.members_list)then
		local list = {};
		local k,v;
		for k,v in ipairs(self.members_list) do
			if(v.is_online == 1)then
				table.insert(list,v);
			end
		end
		return list;
	end
	return self.members_list;
end
--[[
	local family_info = { 
		createdate="2011-01-13 17:09:45",
		id=48,
		members={{nid=100337537,last="2011-01-28",contribute=1,},{nid=166197559,last="2011-01-28",contribute=3,},{nid=87980783,last="2011-01-13",contribute=0,},{nid=172865464,last="2011-01-13",contribute=0,},{nid=168511580,last="2011-06-08",contribute=4,},{nid=14861822,last="2011-06-29",contribute=1,},{nid=232682842,last="2011-04-12",contribute=0,},{nid=208711216,last="2011-04-20",contribute=0,},},
		desc="asdf",
		activity=9,
		deputy="166197559,87980783,168511580,172865464,14861822",
		nextup=10,
		admin=100337537,
		maxcontain=50,
		level=0,
		name="YY瀹舵棌",
		familyworld="002.",
	}
--]]
function FamilyManager:GetFamilyInfo()
	return self.family_info;
end

function FamilyManager:GetFrontPVPMembers()
	if(not self.front_pvp_members_list) then
		self.front_pvp_members_list = commonlib.copy(self.members_list)
		table.sort(self.front_pvp_members_list,function(a,b)
			return a.pvp > b.pvp;
		end)
	end
	return self.front_pvp_members_list;
end

function FamilyManager:GetFrontPVEMembers()
	if(not self.front_pve_members_list) then
		self.front_pve_members_list = commonlib.copy(self.members_list)
		table.sort(self.front_pve_members_list,function(a,b)
			return a.boss > b.boss;
		end)
	end
	return self.front_pve_members_list;
end

function FamilyManager:BuildMembers(family_info)
	if(family_info)then
		local myself = Map3DSystem.User.nid;
		local members = family_info.members;
		local admin = family_info.admin;
		local deputy = family_info.deputy;
		

		local deputy_map = {};
		if(deputy)then
			local id;
			for id in string.gfind(deputy, "([^,]+)") do
				id = tonumber(id);
				deputy_map[id] = true;
			end
		end
		if(members)then
			local members_list = {};
			local k,m;
			for k,m in ipairs(members) do
				local role_status = 2;
				local is_myself = 0;
				
				local nid = m.nid;
				local last = m.last;
				local contribute = m.contribute or 0;
				local gender = Player.GetGender(nid)
				local pvp = m.pvp or 0;
				local boss = m.boss or 0;
				--check online state
				local is_online = 0;
				--if(Friends.IsUserOnlineInMemory(nid))then
					--is_online = 1;
				--end
				NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
				NPL.load("(gl)script/apps/Aries/Chat/FamilyChatWnd.lua");
				if(MyCompany.Aries.Friends.IsFriendInMemory(nid)) then
					-- if nid is friend of user use jabber online status
					if(MyCompany.Aries.Friends.IsUserOnlineInMemory(nid))then
						is_online = 1;
					end
				else
					-- if nid is not friend of user use family online status
					if(MyCompany.Aries.Chat.FamilyChatWnd.IsFamilyMemberOnline(nid))then
						is_online = 1;
					end
				end
				if(deputy_map[nid])then
					role_status = 1;--副族长
				end
				if(nid == admin)then
					role_status = 0;--族长
				end
				if(nid == myself)then
					is_myself = 1;--是自己 排序用
				end
				table.insert(members_list,{
					nid = nid,
					last = last,
					contribute = contribute,
					role_status = role_status,
					is_myself = is_myself,
					is_online = is_online,
					gender = gender,
					pvp = pvp,
					boss = boss,
				});
			end
			table.sort(members_list,function(a,b)
				return (a.is_myself > b.is_myself) 
				or (a.is_myself == b.is_myself and a.role_status < b.role_status) 
				or (a.is_myself == b.is_myself and a.role_status == b.role_status and a.is_online > b.is_online) 
				or (a.is_myself == b.is_myself and a.role_status == b.role_status and a.is_online == b.is_online and a.contribute > b.contribute);
			end)
			--self.front_pve_members_list = nil;
			--self.front_pvp_members_list = nil;
			return members_list;
		end
	end
end

function FamilyManager:Refresh(callbackFunc)
	self.family_info = nil;
	self.members_list = nil;
	self.front_pve_members_list = nil;
	self.front_pvp_members_list = nil;
	Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nil, nil, function (msg)
		if(msg and msg.users and msg.users[1]) then
			--user info
			local my_info= msg.users[1];
			local id_or_name = my_info.family;
			self:LoadMembers(id_or_name,callbackFunc);
		end
	end,"access plus 15 second")
end

local function completeUerItemCopies(userInfo,gsid,callback)
	local nid = userInfo.nid;
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem)then
		local bag = gsItem.template.bagfamily;
		BagHelper.SearchBag(nid,{bag = bag, search_bag_all = true,},function()
			local item = GemTranslationHelper.GetUserItem(nid,gsid);
			if(item)then
				if(gsid == 20055) then
					userInfo.pvp = item.copies or 0;	
				elseif(gsid == 20057) then
					userInfo.boss = item.copies or 0;
				end
				--userInfo.boss = item.copies or 0;
			end
			if(callback) then
				callback();
			end
		end,"access plus 5 minutes")
	end
end

local function completeMemberInfo(member,callback)
	completeUerItemCopies(member,20055,function() 
		completeUerItemCopies(member,20057,function() 
			if(callback) then
				callback();
			end
		end)
	end)
end

local function completeMembersInfo(index,members)
	if(index < #members) then
		local member = members[index];
		index = index + 1;
		completeMemberInfo(member,function()
			completeMembersInfo(index,members,callbackFunc);
		end)
	else
		FamilyManager.complete_members_info = true;
		FamilyMembersPage.OnlyRefreshPage();
	end
end

--[[
	local members_list = {
		{ 
			nid = nid, 
			last = last,--最后签到的时间，yyyy-MM-dd
			contribute = 0,--对家族的贡献度
			role_status = 0,-- 0 族长 1 副族长 2 成员
			is_myself = 0,-- 1 is myself
			is_online = 0,-- 0 offline,1 online

		},
	}
--]]
function FamilyManager:LoadMembers(id_or_name,callbackFunc, cache_policy)
	if(not id_or_name)then
		if(callbackFunc)then
			callbackFunc();
		end
		return;
	end
	local msg = {
		idorname = id_or_name,
		cache_policy = cache_policy or "access plus 0 day",
	}
	LOG.std(nil, "info","FamilyManager:LoadMembers before load",msg);
	paraworld.Family.Get(msg,"group",function(msg)
		LOG.std(nil, "info","FamilyManager:LoadMembers after load",msg);
		if(msg and not msg.errorcode)then
			self.family_info = msg;--家族信息
			self.members_list = self:BuildMembers(self.family_info)
			LOG.std(nil, "info","FamilyManager:LoadMembers members_list",self.members_list);
			FamilyManager.complete_members_info = false;
			completeMembersInfo(1,self.members_list);
			if(callbackFunc)then
				callbackFunc();
			end
		else
			if(callbackFunc)then
				callbackFunc();
			end
		end
	end)
end
function FamilyManager:CanInviteMember()
	local role_status = self:GetMyRole();
	if(role_status == 2)then
		return;
	end
	return true;
end
--邀请成员
function FamilyManager:DoInvite(nid)
	nid = tonumber(nid);
	local role_status = self:GetMyRole();
	if(not nid)then
		return;
	end
	local myself = Map3DSystem.User.nid;
	if(role_status == 2)then
		_guihelper.MessageBox("只有族长和副族长可以发出邀请！");
		return;
	end
	local family_info = self:GetFamilyInfo();
	if(family_info)then
		local familyid = family_info.id;
		local familyname = family_info.name;
		local msg = {
			familyid = familyid,
			tonid = nid,
		}
		Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nid, nil, function (args)
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
			LOG.std(nil, "info","FamilyManager:DoInvite before do invite",msg);
			paraworld.Family.Invite(msg,"",function(msg)
				LOG.std(nil, "info","FamilyManager:DoInvite after do invite",msg);
				if(msg and msg.issuccess)then
					

					FamilyManager.SendMessage(nid,{
						msg_type = "invite",
						from_nid = myself,
						to_nid = nid,
						familyid = familyid,
						familyname = familyname,
					}, function(msg)
						if(msg) then
							_guihelper.MessageBox("邀请已经发出，请耐心等待对方答复。");
						else
							_guihelper.MessageBox("对方不在线， 换个时间再邀请吧");
						end
					end);
				end
			end);
		end,"access plus 0 day");
	end
end
--开除成员
function FamilyManager:DoFire(nid,callbackFunc)
	local role_status = self:GetMyRole();
	if(not nid)then
		return;
	end
	local myself = Map3DSystem.User.nid;
	if(role_status == 2)then
		_guihelper.MessageBox("只有族长和副族长可以开除成员！");
		return;
	end
	if(myself == nid)then
		_guihelper.MessageBox("你不能开除自己！");
		return;
	end
	local family_info = self:GetFamilyInfo();
	if(family_info)then
		local familyid = family_info.id;
		local familyname = family_info.name;
		local s = string.format([[<div style='margin-left:15px;margin-top:10px;'>你确定要把%s从家族中开除吗？</div>]],FamilyMsg.GetNameStr(nid));
		_guihelper.MessageBox(s, function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				--开除
				local msg = {
					nid = myself,
					familyid = familyid,
					removenid = nid,
				};
				LOG.std(nil, "info","FamilyManager:DoFire before do fire",msg);
				paraworld.Family.RemoveMember(msg,"",function(msg)
					LOG.std(nil, "info","FamilyManager:DoFire after do fire",msg);
					if(msg and msg.issuccess)then
						local s = string.format([[你已经把%s从家族中开除!]],FamilyMsg.GetNameStr(nid));
						_guihelper.MessageBox(s, nil, nil, nil, nil, true);

						FamilyManager.SendMessage(nid,{
							msg_type = "fired",
							from_nid = myself,
							to_nid = nid,
							familyid = familyid,
							familyname = familyname,
						});
						if(callbackFunc)then
							callbackFunc();
						end
					end
				end);
			end
		end, _guihelper.MessageBoxButtons.YesNo, nil, nil, true);
	end
end
--退出家族
function FamilyManager:DoQuit(nid,callbackFunc)
	local role_status = self:GetMyRole();
	if(not nid)then
		return;
	end
	local myself = Map3DSystem.User.nid;
	if(role_status == 0)then
		_guihelper.MessageBox("族长只能转让家族/解散家族！");
		return;
	end
	local family_info = self:GetFamilyInfo();
	local function beep_quit()
		local familyid = family_info.id;
		local admin = family_info.admin;
		local deputy = family_info.deputy;
		local familyname = family_info.name;

		local nid_list = {};
		table.insert(nid_list,admin);
		if(deputy)then
			local exist;
			for exist in string.gfind(deputy, "([^,]+)") do
				exist = tonumber(exist);
				table.insert(nid_list,exist);
			end
		end
		local dest_nid;
		for k,dest_nid in ipairs(nid_list) do
			FamilyMsg.SendMessage(dest_nid,{
				msg_type = "got_quit_info",
				from_nid = Map3DSystem.User.nid,
				to_nid = dest_nid,
				familyid = familyid,
				familyname = familyname,
			})
		end
	end	
	if(family_info)then
		local familyid = family_info.id;
		local familyname = family_info.name;
		local s = string.format("<div style='margin-left:15px;margin-top:10px;text-align:center'>你确定要退出家族：%s(%s)吗？</div>",familyname or "",self:FormatID(familyid) or "");
		_guihelper.MessageBox(s, function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				beep_quit();
				local msg = {
					familyid = familyid,
				};
				LOG.std(nil, "info","FamilyManager:DoQuit before do quit",msg);
				paraworld.Family.Quit(msg,"",function(msg)
					LOG.std(nil, "info","FamilyManager:DoQuit after do quit",msg);
					if(msg and msg.issuccess) then
						-- auto refresh the user self info in memory for family update
						System.App.profiles.ProfileManager.GetUserInfo(nil, nil, nil, "access plus 0 day");
						-- send nickname update to chat channel
						MyCompany.Aries.BBSChatWnd.SendUserNicknameUpdate();
						-- auto leave family chat room
						MyCompany.Aries.Chat.FamilyChatWnd.LeaveMyFamilyChatRoom();
						if(callbackFunc)then
							callbackFunc();
						end
					end
				end);
			end
		end, _guihelper.MessageBoxButtons.YesNo, nil, nil, true);
	end
end
--任命副族长
function FamilyManager:DoAppoint_Assistant(nid,callbackFunc)
	local role_status = self:GetMyRole();
	if(not nid)then
		return;
	end
	local myself = Map3DSystem.User.nid;
	if(role_status == 1 or role_status == 2)then
		_guihelper.MessageBox("只有族长可以任命副族长！");
		return;
	end
	if(myself == nid)then
		_guihelper.MessageBox("你不能任命自己为副族长！");
		return;
	end
	local family_info = self:GetFamilyInfo();
	if(family_info)then
		local familyid = family_info.id;
		local familyname = family_info.name;
		local deputy = family_info.deputy;
		if(deputy)then
			local len = 0;
			for __ in string.gfind(deputy, "([^,]+)") do 
				len = len + 1;
			end
			if(len > 5)then
				local s = "<div style='margin-left:15px;margin-top:10px;text-align:center'>你已经有5名副族长了，不能再任命更多的副族长了。</div>";
				_guihelper.Custom_MessageBox(s,function(result)
					
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
				return
			end
			local m = self:GetUserInfoAboutFamily(nid);
			if(m)then
				local s = string.format([[<div style='margin-left:15px;margin-top:10px;'>你确定要任命%s为副族长吗？</div>]],FamilyMsg.GetNameStr(nid));
				_guihelper.MessageBox(s, function(res)
					if(res and res == _guihelper.DialogResult.Yes) then
						--任命副族长
						local msg = {
							familyid = familyid,
							newdeputynid = nid,
						};
						LOG.std(nil, "info","FamilyManager:DoAppoint_Assistant before do appoint_assistant",msg);
						paraworld.Family.SetDeputy(msg,"",function(msg)
							LOG.std(nil, "info","FamilyManager:DoAppoint_Assistant after do appoint_assistant",msg);
							if(msg and msg.issuccess)then
								local s = string.format([[<div style='margin-left:15px;margin-top:10px;'>你已经任命%s为副族长了！</div>]],FamilyMsg.GetNameStr(nid));
								_guihelper.MessageBox(s, nil, nil, nil, nil, true);

								FamilyManager.SendMessage(nid,{
									msg_type = "appoint_assistant",
									from_nid = myself,
									to_nid = nid,
									familyid = familyid,
									familyname = familyname,
								});
								if(callbackFunc)then
									callbackFunc();
								end
							end
						end);
					end
				end, _guihelper.MessageBoxButtons.YesNo, nil, nil, true);
			end
		end	
	end
end
--撤销副族长
function FamilyManager:DoQuit_Assistant(nid,callbackFunc)
	local role_status = self:GetMyRole();
	if(not nid)then
		return;
	end
	local myself = Map3DSystem.User.nid;
	if(role_status == 1 or role_status == 2)then
		_guihelper.MessageBox("只有族长可以撤销副族长！");
		return;
	end
	if(myself == nid)then
		_guihelper.MessageBox("你不能撤销自己！");
		return;
	end
	local family_info = self:GetFamilyInfo();
	if(family_info)then
		local familyid = family_info.id;
		local familyname = family_info.name;
		local deputy = family_info.deputy;
		if(deputy)then
			local deputy_map = {};
			local id;
			for id in string.gfind(deputy, "([^,]+)") do
				id = tonumber(id);
				deputy_map[id] = true;
			end
			if(not deputy_map[nid])then
				local s = string.format([[<div style='margin-left:15px;margin-top:10px;'>%s不是副族长，不需要撤销！</div>]],FamilyMsg.GetNameStr(nid));
				_guihelper.MessageBox(s, nil, nil, nil, nil, true);
				return;
			end
			local s = string.format([[<div style='margin-left:15px;margin-top:10px;'>你确定要撤销%s的副族长任命吗？</div>]],FamilyMsg.GetNameStr(nid));
			_guihelper.MessageBox(s, function(res)
				if(res and res == _guihelper.DialogResult.Yes) then
					--撤销副族长
					local msg = {
						familyid = familyid,
						removenid = nid,
					};
					LOG.std(nil, "info","FamilyManager:DoQuit_Assistant before do fire_assistant",msg);
					paraworld.Family.RemoveDeputy(msg,"",function(msg)
						LOG.std(nil, "info","FamilyManager:DoQuit_Assistant after do fire_assistant",msg);
						if(msg and msg.issuccess)then
							local s = string.format([[<div style='margin-left:15px;margin-top:10px;'>你已经撤销%s的副族长任命了！</div>]],FamilyMsg.GetNameStr(nid));
							_guihelper.MessageBox(s, nil, nil, nil, nil, true);

							FamilyManager.SendMessage(nid,{
								msg_type = "fire_assistant",
								from_nid = myself,
								to_nid = nid,
								familyid = familyid,
								familyname = familyname,
							});
							if(callbackFunc)then
								callbackFunc();
							end
						end
					end);
				end
			end, _guihelper.MessageBoxButtons.YesNo, nil, nil, true);
		end	
	end
end
--转让族长
function FamilyManager:DoHand_Headman(nid,callbackFunc)
	local role_status = self:GetMyRole();
	if(not nid)then
		return;
	end
	local myself = Map3DSystem.User.nid;
	if(role_status == 1 or role_status == 2)then
		_guihelper.MessageBox("只有族长可以转让族长！");
		return;
	end
	if(myself == nid)then
		_guihelper.MessageBox("你不能转让自己！");
		return;
	end
	local family_info = self:GetFamilyInfo();
	if(family_info)then
		local familyid = family_info.id;
		local familyname = family_info.name;
		local deputy = family_info.deputy;
		if(deputy)then
			local deputy_map = {};
			local id;
			for id in string.gfind(deputy, "([^,]+)") do
				id = tonumber(id);
				deputy_map[id] = true;
			end
			if(not deputy_map[nid])then
				local s = string.format([[<div style='margin-left:15px;margin-top:10px;'>%s不是副族长，族长的职位不能转让给他！</div>]],FamilyMsg.GetNameStr(nid));
				_guihelper.MessageBox(s, nil, nil, nil, nil, true);
				return;
			end
			local s = string.format([[<div style='margin-left:15px;margin-top:10px;'>你确定要将族长职位转让给%s吗？</div>]],FamilyMsg.GetNameStr(nid));
			_guihelper.MessageBox(s, function(res)
				if(res and res == _guihelper.DialogResult.Yes) then
					--转让族长
					local msg = {
						familyid = familyid,
						newadmin = nid,
					};
					LOG.std(nil, "info","FamilyManager:DoHand_Headman before do hand_headman",msg);
					paraworld.Family.SetAdmin(msg,"",function(msg)
						LOG.std(nil, "info","FamilyManager:DoHand_Headman after do hand_headman",msg);
						if(msg and msg.issuccess)then
							local s = string.format([[<div style='margin-left:15px;margin-top:10px;'>你已经将族长职位转让给%s了！</div>]],FamilyMsg.GetNameStr(nid));
							_guihelper.MessageBox(s, nil, nil, nil, nil, true);

							FamilyManager.SendMessage(nid,{
								msg_type = "hand_headman",
								from_nid = myself,
								to_nid = nid,
								familyid = familyid,
								familyname = familyname,
							});
							if(callbackFunc)then
								callbackFunc();
							end
						end
					end);
				end
			end, _guihelper.MessageBoxButtons.YesNo, nil, nil, true);
		end	
	end
end
--解散家族
function FamilyManager:DoDisband(callbackFunc)
	local role_status = self:GetMyRole();
	local myself = Map3DSystem.User.nid;
	if(role_status == 1 or role_status == 2)then
		_guihelper.MessageBox("只有族长可以解散家族！");
		return;
	end
	local family_info = self:GetFamilyInfo();
	local members_list = self:GetMembers();
	if(family_info and members_list)then
		local familyid = family_info.id;
		local len = #members_list;
		if(len > 1)then
			_guihelper.MessageBox("你的家族有其他成员加入，目前不能解散家族。！");
			return;
		end
		local s = "<div style='margin-left:15px;margin-top:10px;text-align:center'>你确定要解散该家族吗？</div>";
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.Yes)then
				--解散家族
				local msg = {
					familyid = familyid,
				}
				LOG.std(nil, "info","FamilyManager:DoDisband before do DoDisband",msg);
				paraworld.Family.Delete(msg,nil,function(msg)
					LOG.std(nil, "info","FamilyManager:DoDisband after do DoDisband",msg);
					if(msg and msg.issuccess)then

						MyCompany.Aries.Friends.familyworld = "";
						MyCompany.Aries.FamilyServer.FamilyServerSelect.familyworldname = "";
						MyCompany.Aries.FamilyServer.FamilyServerSet.familyworldindex = nil;

						local s = "你已经解散了自己的家族。你可以选择其他家族加入。";
						_guihelper.MessageBox(s);
						if(callbackFunc)then
							callbackFunc();
						end
					end
				end)
			end
		end,_guihelper.MessageBoxButtons.YesNo, nil, nil, true);
	end
end
--更改家族信息
function FamilyManager:SaveGroupInfo(content_info,callbackFunc)
	local role_status = self:GetMyRole();
	if(not content_info)then
		return
	end
	local myself = Map3DSystem.User.nid;
	if(role_status == 1 or role_status == 2)then
		_guihelper.MessageBox("只有族长可以更改家族宣言！");
		return;
	end
	
	local family_info = self:GetFamilyInfo();
	if(family_info)then
		local familyid = family_info.id;
		content_info = MyCompany.Aries.Chat.BadWordFilter.FilterStringForUserName(content_info);
		local content_info_len = ParaMisc.GetUnicodeCharNum(content_info);
		if(content_info_len > 30)then
			_guihelper.MessageBox("家族宣言不能超过30个字。");
			return;
		end
		local msg = {
			familyid = familyid,
			desc = content_info,
		}
		LOG.std(nil, "info","FamilyManager:SaveGroupInfo before do SaveGroupInfo",msg);
		paraworld.Family.UpdateDesc(msg,"",function(msg)
			LOG.std(nil, "info","FamilyManager:SaveGroupInfo after do SaveGroupInfo",msg);
			if(msg and msg.issuccess)then
				-- update my family info for new desc
				-- TODO: update the family entry of local server in the post_processor
				local Friends = MyCompany.Aries.Friends;
				Friends.GetMyFamilyInfo(function() end, "access plus 0 day");
				-- send update for family desc update
				NPL.load("(gl)script/apps/Aries/Chat/FamilyChatWnd.lua");
				MyCompany.Aries.Chat.FamilyChatWnd.SendFamilyDescUpdate();
				if(callbackFunc)then
					callbackFunc();
				end
			end
		end);
	end
end
--记录今天签到过
function FamilyManager:SaveChallengedToday(familyid)
	familyid = familyid or 0
	local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local nid = Map3DSystem.User.nid;
	nid = tostring(nid);
	local key = string.format("FamilyManager.DoSignIn%s_%d",nid,familyid);
	MyCompany.Aries.Player.SaveLocalData(key,today);
end
--今天是否已经签到过
function FamilyManager:IsSignInToday(familyid)
	familyid = familyid or 0
	local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local nid = Map3DSystem.User.nid;
	nid = tostring(nid);
	local key = string.format("FamilyManager.DoSignIn%s_%d",nid,familyid);
	local time = MyCompany.Aries.Player.LoadLocalData(key, "");
	if(time == today)then
		return true;
	end
end
--登录自动签到
function FamilyManager:TryAutoSignIn()
	local user = Map3DSystem.App.profiles.ProfileManager.GetUserInfoInMemory();
	if(user and user.family)then
		-- always load members on world load. 
		self:LoadMembers(user.family,function()
			local family_info = self:GetFamilyInfo();
			if(family_info)then
				local date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
				local key = string.format("FamilyManager:TryAutoSignIn_%s",date);
				local signed_today = MyCompany.Aries.Player.LoadLocalData(key, false);
				if(not signed_today)then
					local familyid = family_info.id;
					local msg = {
						familyid = familyid,
					}
					LOG.std(nil, "info","FamilyManager:TryAutoSignIn before do DoSignIn",msg);
					paraworld.Family.SignIn(msg,nil,function(msg)
						LOG.std(nil, "info","FamilyManager:TryAutoSignIn after do DoSignIn",msg);
						if(msg and msg.issuccess)then
							self:SaveChallengedToday(familyid);
							MyCompany.Aries.Player.SaveLocalData(key, true);
						end
					end);
				end

				if (System.options.version == "teen") then
					self:LoadFamilyItems(function()
						self:DoDonateMyItems();
					end);
				end
			end
		end, "access plus 1 day");
		
	end
end
--提升活跃度
function FamilyManager:DoSignIn(callbackFunc)
	local family_info = self:GetFamilyInfo();
	if(family_info)then
		local familyid = family_info.id;
		if(self:IsSignInToday(familyid))then
			_guihelper.MessageBox("每天只能为家族贡献1点活跃度，你今天已经贡献过了。请明天再来吧！");
			return 
		end
		local msg = {
			familyid = familyid,
		}
		LOG.std(nil, "info","FamilyManager:DoSignIn before do DoSignIn",msg);
		paraworld.Family.SignIn(msg,nil,function(msg)
			LOG.std(nil, "info","FamilyManager:DoSignIn after do DoSignIn",msg);
			if(msg and msg.issuccess)then
				self:SaveChallengedToday(familyid);
				_guihelper.MessageBox("太棒了！你已经为你的家族贡献了1点活跃度！");
				if(callbackFunc)then
					callbackFunc();
				end
			elseif(msg and msg.errorcode == 433)then
				local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
				local m = self:GetUserInfoAboutFamily();
				if (today == m.last and m.contribute>0) then
					_guihelper.MessageBox("每天只能为家族贡献1点活跃度，你今天已经贡献过了。请明天再来吧！");
				else
					_guihelper.MessageBox("你今天刚加入家族，还不能提升家族活跃度。请明天再来提升家族活跃度吧！");
				end
			end
		end);
	end
end
function FamilyManager:FormatID(id)
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

local seq = 0;
local msg_queue = {};

local function GetNextID()
	seq = seq + 1;
	return seq;
end

-- refactored by LiXizhi to add callback
-- send a message with callback
-- @param nid: target nid
-- @param msg: the message to sent
-- @param callbackFunc: nil of a callback function(msg_out) end, if msg_out is nil, it means timed out
-- @param timeout: in millisecond when callbackFunc() will be called.  default to 5000
function FamilyManager.SendMessage(nid, msg, callbackFunc, timeout)
	if(callbackFunc and msg) then
		local seq = GetNextID();
		local callback = {
			callbackFunc=callbackFunc, 
			timer = commonlib.Timer:new({callbackFunc = function(timer)
				LOG.std(nil, "info","FamilyManager.SendMessage",msg);
				callbackFunc();
			end}),
		};
		msg_queue[seq] = callback;
		msg.seq = seq;
		callback.timer:Change(timeout or 5000, nil);
	end
	FamilyMsg.SendMessage(nid,msg);
end

-- donate all family items to the owner of the family
-- family items is all tradable items in bag 10062
function FamilyManager:DoDonateMyItems(bWithUI)
	local family_info = self:GetFamilyInfo();
	if(family_info and family_info.admin)then
		local bag_id = 10062;
		ItemManager.GetItemsInBag(bag_id , nil, function(msg)
			if(msg and msg.items) then
				local donate_items; 

				local count = ItemManager.GetItemCountInBag(bag_id);
				local i;
				for i = 1, count do
					local item = ItemManager.GetItemByBagAndOrder(bag_id, i);
				
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
					if(gsItem and gsItem.template and gsItem.template.canexchange and gsItem.template.cangift) then
					
						if(item.copies and item.copies > 0) then
							paraworld.inventory.DonateToBag({
								gsid = item.gsid,
								cnt = item.copies,
								tonid = tonumber(self:GetFamilyInfo().admin),
								tobag = FamilyManager.family_bag_id,
							}, "donate_family_items", function(msg)
								if(msg) then

									if(msg.errorcode and msg.errorcode~=0) then
										LOG.std(nil, "warn", "DoDonateMyItems", "failed to DonateToBag: %d", FamilyManager.family_bag_id);
									elseif(msg.errorcode==0) then
										-- successfully submitted score 
										if(System.options.version == "teen") then
											NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingListMain.teen.lua");
											local GoldRankingListMain = commonlib.gettable("MyCompany.Aries.GoldRankingList.GoldRankingListMain");
											if(item.gsid == 20054) then
												self.pvp_total_score = (self.pvp_total_score or 0) + item.copies;
												GoldRankingListMain.SubmitScore("family_pvp", not bWithUI);
											elseif(item.gsid == 20056) then
												self.pve_total_score = (self.pve_total_score or 0) + item.copies;
												GoldRankingListMain.SubmitScore("family_pve", not bWithUI);
											end
										end
									end
								end
							end);
						end
					end
				end
			end
		end, "access plus 1 year");
	end
end

-- get family items
function FamilyManager:LoadFamilyItems(callbackFunc)
	local family_info = self:GetFamilyInfo();
	if(family_info and family_info.admin)then
		self.pvp_total_score = 0;
		self.pve_total_score = 0;
		Map3DSystem.Item.ItemManager.GetItemsInOPCBag(family_info.admin, FamilyManager.family_bag_id, "family_bag", function(msg)
			if(msg and msg.items) then
				local _, item;
				for _, item in ipairs(msg.items) do
					if(item.gsid == 20054) then
						self.pvp_total_score = item.copies;
					elseif(item.gsid == 20056) then
						self.pve_total_score = item.copies;
					end
				end
			end
			if(callbackFunc) then
				callbackFunc();
			end
		end, "access plus 1 day");
	end
end

local function activate()
	if(FamilyManager.global_jc) then
		if(msg.seq_r) then
			-- this is just a confirm reply message. invoke callback
			local callback = msg_queue[msg.seq_r];
			if(callback and callback.callbackFunc) then
				callback.callbackFunc(msg);
				if(callback.timer) then
					callback.timer:Change();
				end
			end
		else
			-- this is a request message. handle it and immediately send confirm message. 
			FamilyMsg.HandleMessage(msg);
			if(msg.seq and msg.from_nid) then
				-- this does nothing but to confirm that we have received the request. 
				FamilyMsg.SendMessage(msg.from_nid, {msg_type="confirm", seq_r = msg.seq});
			end
		end
	end	
end
NPL.this(activate);