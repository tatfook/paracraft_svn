--[[
Title: all client side logics in the team system
Author(s): LiXizhi
Date: 2010/12/26
Desc: Internally, it registers event listener using the current IMServer_client and invoke method on it. 
it has a bunch of handy functions for user interface stuffs. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");
local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");
TeamClientLogics:Init()
TeamClientLogics:JoinTeamMember(87980783)
TeamClientLogics:InviteTeamMember(nid)
TeamClientLogics:QueryTeam()
TeamClientLogics:SendTeamChatMessage({type="summon_members", address={"worldaddress is here"}})
TeamClientLogics:SendTeamChatMessage({type="hp", hp=100, cur_hp=99})
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
NPL.load("(gl)script/apps/Aries/Desktop/HPMyPlayerArea.lua");
NPL.load("(gl)script/apps/Aries/Scene/AutoFollowAI.lua");
NPL.load("(gl)script/apps/Aries/Dialog/Headon_OPC.lua");
NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopPage.lua");
local NPCShopPage = commonlib.gettable("MyCompany.Aries.NPCShopPage");
local Headon_OPC = commonlib.gettable("MyCompany.Aries.Dialog.Headon_OPC");
local AutoFollowAI = commonlib.gettable("MyCompany.Aries.AI.AutoFollowAI");
local HPMyPlayerArea = commonlib.gettable("MyCompany.Aries.Desktop.HPMyPlayerArea");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");
local GSL_client = commonlib.gettable("Map3DSystem.GSL_client");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");

-- create class
local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");
local Chat = commonlib.gettable("MyCompany.Aries.Chat");
local LOG = LOG;
local Encoding = commonlib.Encoding;
local ProfileManager = System.App.profiles.ProfileManager;

NPL.load("(gl)script/apps/Aries/Team/TeamMembersPage.lua");
local TeamMembersPage = commonlib.gettable("MyCompany.Aries.Team.TeamMembersPage");

NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");
NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotionHelper.lua");
local CombatSceneMotionHelper = commonlib.gettable("MotionEx.CombatSceneMotionHelper");
-- can only send one invitation every 20 seconds. 
TeamClientLogics.min_invite_interval = 20000;
-- min join interval
TeamClientLogics.min_join_interval = 20000;
-- min team msg interval
TeamClientLogics.min_teammsg_interval = 3000;

NPL.load("(gl)script/apps/Aries/Desktop/TargetArea.lua");
local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");
local Player = commonlib.gettable("MyCompany.Aries.Player");

NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");

NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");

NPL.load("(gl)script/apps/Aries/Instance/main.lua");
local Instance = commonlib.gettable("MyCompany.Aries.Instance");

-- invoked at MyCompany.Aries.OnActivateDesktop()
function TeamClientLogics:Init()
	local jc = self:GetJC();
	if(jc == nil) then
		LOG.std("", "system", "TeamClientLogics", "failed to get jc client on init");
		return
	end
	if(self.inited) then
		return 
	end
	LOG.std("", "system", "TeamClientLogics", "team logics inited");
	self.inited = true;
	jc:RemoveEventListener("JE_OnTeamUpdate");
	jc:AddEventListener("JE_OnTeamUpdate", TeamClientLogics.OnTeamUpdate_callback);

	jc:RemoveEventListener("JE_OnTeamMessage");
	jc:AddEventListener("JE_OnTeamMessage", TeamClientLogics.OnTeamMessage_callback);

	-- a mapping from nid to last invite message send
	self.last_invite_times = {}; 
	self.last_join_times = {}; 
	-- a mapping from nid to true. 
	self.pending_invite = {};
	self.pending_invite_lobbyservice = {};
	self.pending_join = {};	
end
      
function TeamClientLogics:GetJC()
	if(self.jc or Chat.GetConnectedClient)then
		return self.jc or Chat.GetConnectedClient();
	end
end
--组队房间中，队员发送 加入队伍邀请，忽略一些没有必要的提醒
--@param nids_list:{"123456","123456",}
--@param value:true or false
function TeamClientLogics:Set_pending_invite_lobbyservice(nids_list,value)
	if(nids_list)then
		local k,nid;
		for k,nid in ipairs(nids_list) do
			nid = tostring(nid);
			if(nid)then
				self.pending_invite_lobbyservice[nid] = value;
			end
		end
	end
end
-- usually this function is not called, and jc defaults to Chat.GetConnectedClient()
function TeamClientLogics:SetJC(jc)
	self.jc = jc;
end

function TeamClientLogics.OnTeamUpdate_callback(jc, msg)
	local bChecked = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.checkBoxEnableTeamInvite",true);
	if(not bChecked)then
		jc.team:clear()
		jc.others_team:clear()
		return
	end

	local self = TeamClientLogics;
	if(msg.type == "JE_OnTeamUpdate") then
		
		-- TODO: invoke leio's TeamPad.html page.  msg.team contains all the team info. linked list of team info {nid, hp, level, school}
		-- log("TeamClientLogics.OnTeamUpdate_callback is received\n");
		-- jc:PrintTeam();
		if (not jc:IsInTeam()) then
			self.last_invite_times = {}; 
		end
		TargetArea.ShowTarget("");
		TeamMembersPage.ShowPage(true);
		self:BroadcastMyHPInfo();
		self:UpdateTeamHeadonDisplay();
		
		-- whenever the team info changes, check room statue. 
		local login_room_id = LobbyClientServicePage.GetRoomID();
		if(login_room_id)then
			LobbyClient:GetGameDetail(login_room_id, false, function(result)
				if(result and result.formated_data) then
					local game_info = result.formated_data;
					if(game_info and game_info.players)then
						local team_leader = TeamClientLogics:GetTeamLeaderNid()
						if(team_leader and game_info.owner_nid ~= tostring(team_leader))then
							-- if room owner is not the team leader, quit the room. 
							LOG.std(nil, "info", "TeamClientLogics", "we shall leave the lobby room since the room owner is no longer our team leader")

							NPL.load("(gl)script/apps/Aries/CombatRoom/RoomDetailPage.lua");
							local RoomDetailPage = commonlib.gettable("MyCompany.Aries.CombatRoom.RoomDetailPage");
							RoomDetailPage.LeaveAndClose();
						elseif(TeamClientLogics:IsTeamLeader()) then
							-- for team leader, if there is no more room for current team member, lock the room with a random password if not and then kick out the last additional user. 
							
							local team_member_count = TeamClientLogics:GetMemberCount();
							local count = 0;
							local player_count = game_info.player_count or 0;
							local max_players = game_info.max_players or 4;
							local nid, _
							for nid, _ in pairs(game_info.players) do
								if(TeamClientLogics:MyTeamIncludeMember(nid)) then
									count = count + 1;
								end
							end
							if ( (team_member_count-count) > max_players-player_count ) then
								for nid, _ in pairs(game_info.players) do
									if(not TeamClientLogics:MyTeamIncludeMember(tonumber(nid))) then
										-- kick out a user. 
										LOG.std(nil, "info", "TeamClientLogics", "kick last user %s when there is no more room for the current room", tostring(nid))
										LobbyClientServicePage.DoKickGame(game_info.id,nid);
									end
								end
								-- lock the room  
								LobbyClientServicePage.DoResetGame({name="locked", password = LobbyClientServicePage.GetNextPassword()})
							end
						end
					end
				end
			end);
		end

	end
end


local query_timer;
local last_query_time;
function TeamClientLogics.OnTeamMessage_callback(jc, msg)
	local self = TeamClientLogics;
	local bChecked = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.checkBoxEnableTeamInvite",true);
	if(not bChecked)then
		return 
	end

	if(msg.type == "JE_OnTeamMessage") then
		local from = msg.from;
		if(type(msg.msg) == "string") then
			local table_msg = string.match(msg.msg, "^#table#(.+)$");
			if(table_msg) then
				msg.msg = NPL.LoadTableFromString(table_msg);
			else
				-- received a chat string message
				TeamClientLogics.OnReceiveTeamChatMessage(from, msg.msg)
				return;
			end
		end
		if(type(msg.msg) == "table") then
			local msg = msg.msg;
			local msg_type = msg.type;
			
			if(msg_type == "talk")  then
				-- received a chat message
				TeamClientLogics.OnReceiveTeamChatMessage(from, msg.content)
			elseif(msg_type == "hp" and from) then
				-- health points updates
				if(msg.hp) then
					local member = jc:GetTeamMemberByNid(from)
					if(member) then
						local is_changed;
						if(msg.hp and msg.hp~=member.hp) then
							member.hp = msg.hp;
							is_changed = true;
						end
						if(msg.cur_hp and msg.cur_hp~=member.cur_hp) then
							member.cur_hp = msg.cur_hp;
							is_changed = true;
						end
						if(is_changed and not jc:IsSelf(from)) then
							-- refresh the team pannel page. 
							TeamMembersPage.UpdateHealthPoint();
							-- LOG.std(nil, "debug", "TeamClientLogics", "hp changes nid %s: cur_hp:%d max_hp:%d", from, member.cur_hp, member.hp);
						end
					end
				end
			elseif(msg_type == "summon_members") then
				-- summon all players to this class.
				local myself = tostring(System.User.nid);
				from = tostring(from);
				if(myself ~= from)then
					if(msg.address)then
						local address = msg.address;
						local s = string.format("队长召唤你到他身边，确认要立即过去吗？<br/>需要20秒内回复");

						if (not MyCompany.Aries.ExternalUserModule:CanViewUser(from)) then
							
							if(WorldManager:IsPublicWorld(address.name)) then
								_guihelper.MessageBox("队长召唤你到他身边， 但是你与队长不是同区, 无法跟随");
								return;
							end
						end

						local cur_time = ParaGlobal.timeGetTime();
						_guihelper.Custom_MessageBox(s,function(result)
							if(result == _guihelper.DialogResult.Yes)then
								if( (address.force_nid or address.room_key) and (cur_time - ParaGlobal.timeGetTime()) > 20000) then
									_guihelper.MessageBox("邀请过期了， 请让队长再次邀请你过去");
								else
									local can_pass = LobbyClientServicePage.CheckTicket_CanPass(address.name,true);
									if(can_pass)then
										WorldManager:TeleportByWorldAddress(address);
									end
								end
							else
								_guihelper.MessageBox("是否离开队伍并禁止别人对你发起组队请求?", function(result)
									if(result == _guihelper.DialogResult.Yes)then
										-- quit team
										TeamClientLogics:LeaveTeam();
										MyCompany.Aries.Player.SaveLocalData("AriesSettingsPage.checkBoxEnableTeamInvite", false);
										_guihelper.MessageBox("已经禁止了组队请求功能，你可以在设置中重新打开");
									end
								end, _guihelper.MessageBoxButtons.YesNo)
							end
						end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/Coming_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
					end
				end
			elseif(msg_type == "team_followme") then
				-- the team leader wants me to follow him/her.
				local myself = tostring(System.User.nid);
				from = tostring(from);
				if(myself ~= from)then
					if(msg.leader_nid)then
						local bChecked = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.checkBoxEnableTeamInvite",true);
						if(not bChecked)then
							local msgdata = { ChannelIndex=ChatChannel.EnumChannels.Team,from=tostring(msg.leader_nid), words="队长召集全队跟随移动",};
							ChatChannel.AppendChat( msgdata );
							return
						end
						if (not MyCompany.Aries.ExternalUserModule:CanViewUser(from)) then
							if(WorldManager:IsPublicWorld(address.name)) then
								_guihelper.MessageBox("队长召唤全队跟随， 但是你与队长不是同区, 无法跟随");
								return;
							end
						end
						local address = msg.address;
						if(address) then
							local s = string.format("队长召集全队跟随移动，你是否同意？");
							_guihelper.Custom_MessageBox(s,function(result)
								if(result == _guihelper.DialogResult.Yes)then
									local can_pass = LobbyClientServicePage.CheckTicket_CanPass(address.name,true);
									if(can_pass)then
										WorldManager:TeleportByWorldAddress(address);
										TeamMembersPage.DoFollowUser(msg.leader_nid)
									end
								else
									_guihelper.MessageBox("是否离开队伍并禁止别人对你发起组队请求?", function(result)
										if(result == _guihelper.DialogResult.Yes)then
											-- quit team
											TeamClientLogics:LeaveTeam();
											MyCompany.Aries.Player.SaveLocalData("AriesSettingsPage.checkBoxEnableTeamInvite", false);
											_guihelper.MessageBox("已经禁止了组队请求功能，你可以在设置中重新打开");
										end
									end, _guihelper.MessageBoxButtons.YesNo)
								end
							end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/Coming_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
						end
					end
				end
			
			elseif(msg_type == "query_lobby_room") then
				-- this message is sent from team members to team leader, asking the current lobby room. 
				local myself = tostring(System.User.nid);
				from = tostring(from);
				if(myself == from)then
					return;
				end 
				if(TeamClientLogics:IsTeamLeader()) then
					local room_id = LobbyClientServicePage.GetRoomID();
					if(room_id)then
						LobbyClientServicePage.SendCreateGameMsgToTeamMembers();
					end
				end
			
			elseif(msg_type == "create_game") then
				local myself = tostring(System.User.nid);
				from = tostring(from);
				if(myself == from)then
					return;
				end
				local room_id = LobbyClientServicePage.GetRoomID();
				if(room_id)then
					return;
				end
				local id = msg.id or 0;
				local name = msg.name or "";
				local worldname = msg.worldname or "";
				local keyname = msg.keyname or "";
				local tempaltes = LobbyClientServicePage.GetGameTemplates();
				local template = tempaltes[keyname];
				local world_title = "";
				if(template)then
					world_title = template.name or "";
				end
				LobbyClientServicePage.last_password = msg.password;

				local msgdata = { ChannelIndex=ChatChannel.EnumChannels.Team,from=tostring(from), words=format("快加入去【%s】的队伍", world_title),};
				ChatChannel.AppendChat( msgdata );

				local world = WorldManager:GetWorldInfo(worldname or keyname);
				if(world and world.force_teamworld) then
					LobbyClient:GetGameDetail(id, true, function(result)
						if(result)then
							local game_info = result.formated_data;
							LobbyClientServicePage.DoJoinGame_Internal(id,msg.password,game_info)
						end
					end,true);
				else
					local s = string.format("你的队长创建了去【%s】的队伍:%s(%d),是否立即加入?",world_title,name,id);
					-- 队长创建房间后 邀请队员加入
					_guihelper.Custom_MessageBox(s,function(result)
							if(not template or not LobbyClientServicePage.CheckRoomState(template.game_type,worldname))then
								return
							end
							if(result == _guihelper.DialogResult.Yes)then
								LobbyClient:GetGameDetail(id, true, function(result)
									if(result)then
										local game_info = result.formated_data;
										if(worldname and worldname == "HaqiTown_LafeierCastle_PVP_OneTeam" or worldname == "HaqiTown_LafeierCastle_PVP_TwoTeam" or worldname == "HaqiTown_LafeierCastle_PVP_ThreeTeam") then
											local canGet3v3Score = LobbyClientServicePage.PVP3v3GetScoreCheck();
											if(not canGet3v3Score) then
												--local reward_times = LobbyClientServicePage.Get3v3ScoreTimesPerDay();
												--local text = string.format("3v3战斗每天仅前<font style='font-weight:bolder;color:#FF0000;font-size:13px;'>%d</font>次可以获得积分，你今天获得积分的次数已用尽，但是战斗胜利仍然可以获得<pe:item gsid='17213' style='width:24px;height:24px;' isclickable='false'/>和<pe:item gsid='17577' style='width:24px;height:24px;' isclickable='false'/>。是否进行参加战斗？",reward_times);
												--_guihelper.MessageBox(text,function (dialogResult)
													--if(dialogResult == _guihelper.DialogResult.Yes) then
														--LobbyClientServicePage.DoJoinGame_Internal(id,msg.password,game_info);
													--end
												--end, _guihelper.MessageBoxButtons.YesNo);
												_guihelper.MessageBox("你的3v3门票已经用完，不能参加3v3比赛,是否现在购买？",function (dialogResult)
													if(dialogResult == _guihelper.DialogResult.Yes) then
														WorldManager:GotoNPC(30559,function()
															NPCShopPage.ShowPage(30559,"menu1");
														end)
													end
												end, _guihelper.MessageBoxButtons.YesNo);
											else
												local text = "";
												local bHas52108, _, __, copies52108 = System.Item.ItemManager.IfOwnGSItem(52108);
												text = text..string.format("本月战斗额外奖励场次：%d<br/>",copies52108 or 0);	

												local bHas50420, _, __, copies50420 = System.Item.ItemManager.IfOwnGSItem(50420);
												text = text..string.format("免费入场卷:%d<pe:item gsid='%d' style='width:24px;height:24px;' isclickable='false'/><br/>", copies50420 or 0, 50420);	

												local bHas52109, _, __, copies52109 = System.Item.ItemManager.IfOwnGSItem(52109);
												text = text..string.format("剩余入场卷:%d<pe:item gsid='%d' style='width:24px;height:24px;' isclickable='false'/><br/>", copies52109 or 0, 52109);	

												text = text.."<a onclick='MyCompany.Aries.Instance.Buy3v3ticket'>补充入场券<a/>";

												_guihelper.MessageBox(text,function (dialogResult)
													if(dialogResult == _guihelper.DialogResult.OK) then
														LobbyClientServicePage.DoJoinGame_Internal(id,msg.password,game_info);
													end
												end, _guihelper.MessageBoxButtons.OK);
											end
										else
											LobbyClientServicePage.DoJoinGame_Internal(id,msg.password,game_info);
										end
										
									end
								end,true);
							end
						end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Cancel_32bits.png; 0 0 153 49"});
				end

				
			elseif(msg_type == "query_address") then
				-- some user asks me about my current address(position). 

				local myself = tostring(System.User.nid);
				from = tostring(from);
				if(myself ~= from and myself==tostring(msg.nid))then
					if (not MyCompany.Aries.ExternalUserModule:CanViewUser(from)) then
						return
					end

					last_query_time = commonlib.TimerManager.GetCurrentTime();
					if(System.User.is_ready) then
						self:SendTeamChatMessage({type="address_reply", address=WorldManager:GetWorldAddress()}, true)
						if(query_timer) then
							query_timer:Change();
						end
					else
						-- reply until time is ready. 
						query_timer = query_timer or commonlib.Timer:new({callbackFunc = function(timer)
							if(System.User.is_ready) then
								self:SendTeamChatMessage({type="address_reply", address=WorldManager:GetWorldAddress()}, true)
								timer:Change();
							elseif((commonlib.TimerManager.GetCurrentTime() - last_query_time) > 20000) then
								-- stop any way if user is not ready for 20 seconds 
								timer:Change();
								LOG.std(nil,"warn", "TeamClientLogics", "query address ingored since user is not ready for 20 seconds");
							end
						end})
						query_timer:Change(300, nil);
					end
				end
			elseif(msg_type == "address_reply") then
				-- we get an world address of some team member. possibly we need to follow him. 
				local myself = tostring(System.User.nid);
				from = tostring(from);
				if(myself ~= from)then
					if(msg.address) then
						if(from == AutoFollowAI:GetFollowTarget() and AutoFollowAI.has_asked_position) then
							AutoFollowAI:OnReplyLastAddressRequest(msg.address);
						end
					else
						_guihelper.MessageBox("你无法到达对方所在地点. 只有常规岛屿之间才能传送.");
					end
				end
			elseif(msg_type == "user_info" and from) then
				-- update member attribute
				local member = jc:GetTeamMemberByNid(from)
				if(member) then
					local user_info = msg.user_info;
					if(user_info) then
						member.hp = user_info.hp or member.hp;
						member.cur_hp = user_info.cur_hp or member.cur_hp or member.hp;
						member.level = user_info.level or member.level;
						member.school = user_info.school or member.school;
					end
				end
			elseif(msg_type == "team_invite" and from) then
				-- some one invites me
				local jc = self:GetJC();
				if(jc) then
					nid = tonumber(from);
					local userinfo = ProfileManager.GetUserInfoInMemory(nid);
					if (userinfo) then
						nickname = userinfo.nickname or "";
					else
						ProfileManager.GetUserInfo(nid, "TeamInviteNotification", function(msg)
							local userinfo = ProfileManager.GetUserInfoInMemory(nid);
								if(userinfo) then
									nickname = userinfo.nickname  or "";
								end
						end);
					end
					-- if client in team discard this invite msg
					if (jc:IsInTeam()) then
						return
					end
					local bChecked = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.checkBoxEnableTeamInvite",true);
					if(not bChecked)then
						local s = string.format("邀请你加入队伍,被系统自动拒绝了,在系统设置里面可以取消这个限制。",nickname or "",nid or 0);
						ChatChannel.AppendChat({ChannelIndex=ChatChannel.EnumChannels.System, from=nid, words=s});
						return;
					else
						local s = string.format("邀请你加入队伍", nickname or "", nid or 0);
						ChatChannel.AppendChat({ChannelIndex=ChatChannel.EnumChannels.System, from=nid, words=s});
						BroadcastHelper.PushLabel({id="team_invite", label = "你有组队邀请, 请查看", max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
					end
					MyCompany.Aries.Desktop.NotificationArea.AppendFeed("request", {
						type = "Team.ReceiveTeamInviteRequest", 
						Name = "Team.ReceiveTeamInviteRequest"..nid, 
						nid = nid, 
						nickname = nickname, 
						ShowCallbackFunc = function(node)
							local nickname = node.nickname or "";
							local nid = node.nid;
							nickname = Encoding.EncodeStr(nickname);
							if(not jc:IsInTeam()) then	
								local src_gameid=tonumber(msg.src_gameid) or 0;
								local src_worldid=tonumber(msg.src_worldid) or 0;
								local tipmsg="";
								local self_gameid=tonumber(System.GSL_client.gameserver_nid);
								local self_worldid=tonumber(System.GSL_client.worldserver_id);

								if (self_gameid==src_gameid and self_worldid==src_worldid) then
									tipmsg="<pe:name value='"..nickname.."' nid='"..nid.."' profile_zorder=\"20000\" useyou=false/> ("..MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid)..") 邀请你加入他的队伍, 你是否同意呢?";
								else
									tipmsg="<font color='#ff0000'>其他服务器的</font><pe:name value='"..nickname.."' nid='"..nid.."' profile_zorder=\"20000\" useyou=false/> ("..MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid)..") 邀请你加入他的队伍, 你是否同意呢?";
								end
								if (src_gameid == 0 and src_worldid==0) then
									tipmsg="<pe:name value='"..nickname.."' nid='"..nid.."' profile_zorder=\"20000\" useyou=false/> ("..MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid)..") 邀请你加入他的队伍， 你是否同意呢?";
								end
								_guihelper.MessageBox(tipmsg, function(result)
										if(_guihelper.DialogResult.Yes == result) then
										-- accept the team request
											self:JoinTeamMember(nid);
										end	
									end,_guihelper.MessageBoxButtons.YesNo, nil, nil, true); -- true for isNotTopLevel
							end;
						end
					});
				end
			elseif(msg_type == "join_fail" and from) then
				-- some one i cannot invite
				local jc = self:GetJC();
				if(jc) then
					nid = tonumber(from);
					local userinfo = ProfileManager.GetUserInfoInMemory(nid);
					if (userinfo) then
						nickname = userinfo.nickname or "";
					else
						ProfileManager.GetUserInfo(nid, "TeamInviteNotification", function(msg)
							local userinfo = ProfileManager.GetUserInfoInMemory(nid);
								if(userinfo) then
									nickname = userinfo.nickname  or "";
								end
						end);
					end
					nickname = Encoding.EncodeStr(nickname);
					_guihelper.MessageBox("真遗憾！你慢了一步, <pe:name value='"..nickname.."' nid='"..nid.."' profile_zorder=\"20000\" useyou=false linked=false /> ("..MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid)..") 的队伍已经满了！");
				end
			elseif((msg_type == "invite_unable" or msg_type == "addteammember_fail") and from) then
				-- some one i cannot invite
				local jc = self:GetJC();
				if(jc) then
					nid = tonumber(from);
					local userinfo = ProfileManager.GetUserInfoInMemory(nid);
					if (userinfo) then
						nickname = userinfo.nickname or "";
					else
						ProfileManager.GetUserInfo(nid, "TeamInviteNotification", function(msg)
							local userinfo = ProfileManager.GetUserInfoInMemory(nid);
								if(userinfo) then
									nickname = userinfo.nickname  or "";
								end
						end);
					end
					nickname = Encoding.EncodeStr(nickname);
					_guihelper.MessageBox("真遗憾！你慢了一步, <pe:name value='"..nickname.."' nid='"..nid.."' profile_zorder=\"20000\" useyou=false linked=false /> ("..MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid)..") 已经加入别的队伍了！");
				end
			elseif(msg_type == "team_join" and from) then
				local jc = self:GetJC();
				if(jc) then
					local login_room_id = LobbyClientServicePage.GetRoomID();
					if(login_room_id)then
						LobbyClient:GetGameDetail(login_room_id, false, function(result)
							if(result and result.formated_data) then
								if(LobbyClientServicePage.auto_start) then
									LOG.std("", "info", "team", "as team leader, we will approve user %s to join us since we are auto_starting from public lobby service", tostring(from or 0));
									jc:AddTeamMember(from);
								else
									local nid = tonumber(from);
									local tipmsg = "<pe:name nid='"..nid.."' profile_zorder=\"20000\" useyou=false/> ("..MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid)..") 申请加入你的队伍, 你是否同意呢?";
									_guihelper.MessageBox(tipmsg, function(res)
										if(res and res == _guihelper.DialogResult.Yes) then
											-- the team leader should confirm and add the user. 
											jc:AddTeamMember(nid);
										else
											-- send reject message to from because the team leader rejects it explicitly. 
											jc:TeamRejectJoin(nid);
											LobbyClientServicePage.DoKickGame(login_room_id, nid);
										end
									end, _guihelper.MessageBoxButtons.YesNo,nil,nil,true);
								end
							end
						end);
					elseif(self.pending_invite[from] or self.pending_invite_lobbyservice[tostring(from)]) then
						-- the team leader should confirm and add the user.
						LOG.std("", "info", "team", "as team leader, we will approve user %s to join us", tostring(from or 0));
						jc:AddTeamMember(from);
						self.pending_invite[from] = false;
					else
						nid = tonumber(from);
						LOG.std("", "info", "team", "team_join %s ", tostring(nid));
						local userinfo = ProfileManager.GetUserInfoInMemory(nid);
						if (userinfo) then
							nickname = userinfo.nickname or "";
						else
							ProfileManager.GetUserInfo(nid, "TeamJoinNotification", function(msg)
								local userinfo = ProfileManager.GetUserInfoInMemory(nid);
									if(userinfo) then
										nickname = userinfo.nickname  or "";
									end
							end);
						end
						if(not jc:IsTeamFull()) then
							MyCompany.Aries.Desktop.NotificationArea.AppendFeed("request", {
								type = "Team.ReceiveTeamJoinRequest", 
								Name = "Team.ReceiveTeamJoinRequest"..nid, 
								nid = nid, 
								nickname = nickname, 
								ShowCallbackFunc = function(node)
									local nickname = node.nickname or "";
									local nid = node.nid;
									nickname = Encoding.EncodeStr(nickname);
									local tipmsg=""
									local src_gameid=tonumber(msg.src_gameid) or 0;
									local src_worldid=tonumber(msg.src_worldid) or 0;
									local self_gameid=tonumber(System.GSL_client.gameserver_nid);
									local self_worldid=tonumber(System.GSL_client.worldserver_id);

									if (self_gameid==src_gameid and self_worldid==src_worldid) then
										tipmsg="<pe:name value='"..nickname.."' nid='"..nid.."' profile_zorder=\"20000\" useyou=false/> ("..MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid)..") 申请加入你的队伍, 你是否同意呢?";
									else
										tipmsg="<font color='#ff0000'>其他服务器的</font><pe:name value='"..nickname.."' nid='"..nid.."' profile_zorder=\"20000\" useyou=false/> ("..MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid)..") 申请加入你的队伍, 你是否同意呢?";
									end
									if (src_gameid == 0 and src_worldid==0) then
										tipmsg="<pe:name value='"..nickname.."' nid='"..nid.."' profile_zorder=\"20000\" useyou=false/> ("..MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid)..") 申请加入你的队伍，你是否同意呢?";
									end
									_guihelper.MessageBox(tipmsg, function(res)
											if(res and res == _guihelper.DialogResult.Yes) then
												-- the team leader should confirm and add the user. 
												jc:AddTeamMember(nid);
											else
												-- send reject message to from because the team leader rejects it explicitly. 
												jc:TeamRejectJoin(nid);
											end
									end, _guihelper.MessageBoxButtons.YesNo, nil, nil, true);
								end
							});
						else					
							-- send reject message to from (because team is already full). 
							jc:TeamRejectJoin(nid);
						end;
					end
				end
			elseif(msg_type == "join_reject" and from) then
				local jc = self:GetJC();
				if(jc) then
					nid = tonumber(from);
					LOG.std("", "info", "team", "join_reject %s", tostring(nid));
					
					local userinfo = ProfileManager.GetUserInfoInMemory(nid);
					if (userinfo) then
						nickname = userinfo.nickname or "";
					else
						ProfileManager.GetUserInfo(nid, "TeamRejectJoinNotification", function(msg)
							local userinfo = ProfileManager.GetUserInfoInMemory(nid);
								if(userinfo) then
									nickname = userinfo.nickname  or "";
								end
						end);
					end
					MyCompany.Aries.Desktop.NotificationArea.AppendFeed("request", {
						type = "Team.ReceiveTeamRejectJoinRequest", 
						Name = "Team.ReceiveTeamRejectJoinRequest"..nid, 
						nid = nid, 
						nickname = nickname, 
						ShowCallbackFunc = function(node)
							local nickname = node.nickname or "";
							local nid = node.nid;
							nickname = Encoding.EncodeStr(nickname);
							_guihelper.MessageBox("很抱歉，该队队长<pe:name value='"..nickname.."' nid='"..nid.."' profile_zorder=\"20000\" useyou=false linked=false /> ("..MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid)..") 拒绝了你的入队申请，去其他队伍试试吧！");
						end
					});
				end
			elseif(msg_type == "joinworld" and from) then
				if(Player.IsInCombat())then
					return
				end
				local function loadworld()
					local params = msg.params;
					-- TODO: for leio. now move to the spot and join the world quickly.
					--_guihelper.MessageBox(params);
					if(params)then
						local name = params.name;
						local room_key = params.room_key;
						
						local force_nid = string.gsub(room_key,"[^%d]", "");
						if(force_nid) then
							if(#force_nid>10) then
								force_nid = force_nid:sub(#force_nid-10);
							end
							force_nid = tonumber(force_nid)%10000;
						end
						NPL.load("(gl)script/apps/Aries/Scene/AutoCameraController.lua");
						local AutoCameraController = commonlib.gettable("MyCompany.Aries.AutoCameraController");
						AutoCameraController:SaveCamera();
						System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {
							name = name,
							room_key = room_key,
							force_nid = force_nid,
							create_join = true,
							--is_local_instance = true,
							-- instance = world_name,
							-- uncomment if one wants to use local instance
							-- is_local_instance = true, nid = ProfileManager.GetNID()..tostring(math.random(10000, 99999)), 
							on_finish = function()
								local world = WorldManager:GetWorldInfo(params.name);
								if(world and world.motion_file)then
									CombatSceneMotionHelper.PlayCombatMotion_LoginWorld(world.motion_file);
								end
							end,
						});
					end
				end
				from = tostring(from);
				local nid = tostring(Map3DSystem.User.nid);

				if(msg.params) then
					local world_key = msg.params.name;
					local worldinfo = WorldManager:GetWorldInfo(world_key);
					if(worldinfo.team_mode == "battlefield" or worldinfo.team_mode == "single") then
						_guihelper.MessageBox(format("组队状态不能进入[%s]", worldinfo.name));
						return;
					end
				end

				if(from == nid)then
					NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
					local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
					GathererBarPage.Start({ duration = 1000, title = "准备进入世界", disable_shortkey = true, align="_ct", x=-100, y=-100,},nil,function()
						loadworld();
					end);
				else
					local world_key = msg.params.name;
					local world = WorldManager:GetWorldInfo(world_key);
					local name = "";
					if(world)then
						name = world.world_title;
					end
					local s = string.format("你的队长进入了%s副本，你也要一起进入吗？不进就没机会了哟！",name or "");
					NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
					_guihelper.Custom_MessageBox(s,function(result)
						if(result == _guihelper.DialogResult.Yes)then
							loadworld();
						end
					end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/Coming_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/refuse_login_32bits.png; 0 0 153 49"});
				end
			end
		end
	end
end

function TeamClientLogics.OnReceiveTeamChatMessage(from, content)
	-- invoke global chat channel module. 
	log("TeamClientLogics.OnReceiveTeamChatMessage is received\n");
	LOG.std(nil, "system", "TeamClientLogics", {"rec_team_chat", from=from, content=content})
	
	local fromschool = Combat.GetSchool(from);
	local msgdata = { ChannelIndex=ChatChannel.EnumChannels.Team,from=tostring(from), fromschool = fromschool,words=content,};
	ChatChannel.AppendChat( msgdata );

	TeamMembersPage.AppendTeamChat(from,content)
end

-- send the current health info to all users. This is called, whenever the team info changes. 
-- @note repeated calls in a short time will be merged to a single call. 
-- @param bUpdateSelfUI: if true, the UI of self display in team member page is immediately updated. 
function TeamClientLogics:BroadcastMyHPInfo(bUpdateSelfUI)
	local jc = self:GetJC();
	if (jc and jc:IsInTeam()) then
		-- health timer 
		self.hp_timer = self.hp_timer or commonlib.Timer:new({callbackFunc = function(timer)
			local jc = self:GetJC();
			if (jc:IsInTeam()) then
				local cur_value,max_value = HPMyPlayerArea.GetHP();
				TeamClientLogics:SendTeamChatMessage({type="hp", hp=max_value, cur_hp=cur_value});
			end
		end})
		self.hp_timer:Change(5000, nil);
		if(bUpdateSelfUI) then
			TeamMembersPage.UpdateHealthPoint();
		end
	end
end

-- public: send a message to all team members in the current team. 
-- @param content: this can be string or a table of {type="talk", content = "any string"}
-- @param bIgnoreTimeCheck: true to ignore repeated call to this function, and it ensures that all messages are sent to the server. 
-- however, the the server side may still block it. 
function TeamClientLogics:SendTeamChatMessage(msg, bIgnoreTimeCheck)
	local jc = self:GetJC();
	if(jc) then
		if(jc:IsInTeam()) then
			if(type(msg) == "table") then
				msg = "#table#"..commonlib.serialize_compact(msg);
			end
			-- min_teammsg_test
			return jc:SendTeamMessage(msg, bIgnoreTimeCheck);
		else
			LOG.std(nil, "warn", "TeamClientLogics", "send team chat message is ignored, since we are not in a team");
		end
	else
		LOG.std(nil, "error", "TeamClientLogics", "unable to get jc client");
	end
end
--自己的队伍中是否包含某个用户
-- @param nid: should be number
function TeamClientLogics:MyTeamIncludeMember(nid)
	if(not nid or not self:IsInTeam())then return end
	local jc = self:GetJC();
	if(jc)then
		local team = jc:GetTeam();
		local item = team:first();
		while (item) do
			if(item.nid == nid)then
				return true;
			end
			item = team:next(item)
		end
	end
end

-- get the total number of members in the team. 
function TeamClientLogics:GetMemberCount()
	local jc = self:GetJC();
	if(jc and jc:IsInTeam()) then
		local team = jc:GetTeam();
		if(team) then
			return team:size();
		end
	end
	return 0;
end

--自己是否在一个队伍中
function TeamClientLogics:IsInTeam()
	local jc = self:GetJC();
	if(jc) then
		if(jc:IsInTeam()) then
			return true;
		end
	end
end
-- public:remove a given nid from the team. 
function TeamClientLogics:DelTeamMember(nid)
	nid = tonumber(nid);
	if(not nid) then return end

	local jc = self:GetJC();
	if(jc and (jc:IsTeamLeader() or jc:IsSelf(nid)) and jc:GetTeamMemberByNid(nid)) then
		jc:DelTeamMember(nid);
		if (self.last_invite_times[nid]) then
			self.last_invite_times[nid]=nil;
		end
	else
		_guihelper.MessageBox(string.format("你不是队长，不能删除队员%s", tostring(nid)));
	end
end

-- queries the team. 
-- call this function when user first login the game world to resume team status. 
function TeamClientLogics:QueryTeam(nid)
	local jc = self:GetJC();
	if(jc) then
		jc:TeamQuery(nid);		
	end
	return true;
end

-- public:leave the current team.
function TeamClientLogics:LeaveTeam()
	local jc = self:GetJC();
	if(jc and jc:IsInTeam()) then
		jc:DelTeamMember(jc.nid);
		if (self.last_invite_times[jc.nid]) then
			-- self.last_invite_times[jc.nid]=nil;
			self.last_invite_times={};
		end
	end
end

-- public:assign a new team leader. only the team leader can call this function.
function TeamClientLogics:SetTeamLeader(nid)
	nid = tonumber(nid);
	if(not nid) then return end

	local jc = self:GetJC();
	if(jc and jc:IsTeamLeader() and jc:GetTeamMemberByNid(nid)) then
		jc:SetTeamLeader(nid);
	else
		_guihelper.MessageBox(format("你不是队长，不能指定队员%s为队长", MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid)));
	end
end

-- return the team leader nid. if not in a team, this function will return nil.
function TeamClientLogics:GetTeamLeaderNid()
	local jc = self:GetJC();
	if(jc) then
		return jc:GetTeamLeaderNid()
	end
end

-- whether current user is the team leader. 
function TeamClientLogics:IsTeamLeader()
	local jc = self:GetJC();
	if(jc)then
		return jc:IsTeamLeader();
	end
end
function TeamClientLogics:InviteTeamMember_ByLobbyClient(nids)
	if(not nids)then return end
	local jc = self:GetJC();
	local bSend = false;
	if(jc) then
		if(jc:IsTeamFull()) then
			_guihelper.MessageBox("很抱歉， 队伍已经满了， 不能再邀请新的队员了！");
		elseif(jc:IsInTeam() and not jc:IsTeamLeader()) then
			_guihelper.MessageBox("很抱歉，你不是队长，不能邀请其他哈奇加入队伍！");
		elseif(jc:IsSelf(nid)) then
			_guihelper.MessageBox("你不能邀请自己加入自己的队伍!");
		else
			local k,nid;
			for k,nid in ipairs(nids) do
				nid = tonumber(nid);
				if (not jc:GetTeamMemberByNid(nid)) then
					jc:TeamInviteMember(nid);
					-- tricky: we will never clear the pending_invite map, so that member can leave and rejoin freely
					self.pending_invite[nid] = true;
					bSend = true;
				end
			end
		end
	end
	return bSend;
end
-- public: send an invitation to a given user, asking him to join our team. 
-- only the team leader can call this function to invite other members. 
function TeamClientLogics:InviteTeamMember(nid)
	nid = tonumber(nid);
	--InOtherTeam_id = tonumber(InOtherTeam_id);

	if(not nid) then return end

	local jc = self:GetJC();
	if(jc) then
		if(jc:IsTeamFull()) then
			_guihelper.MessageBox("很抱歉， 队伍已经满了， 不能再邀请新的队员了！");
		elseif(jc:IsInTeam() and not jc:IsTeamLeader()) then
			_guihelper.MessageBox("很抱歉，你不是队长，不能邀请其他哈奇加入队伍！");
		elseif(jc:IsSelf(nid)) then
			_guihelper.MessageBox("你不能邀请自己加入自己的队伍!");
		else
			if (not jc:GetTeamMemberByNid(nid)) then
				if(self.last_invite_times[nid] and (self.last_invite_times[nid] + self.min_invite_interval) > commonlib.TimerManager.GetCurrentTime()) then
					_guihelper.MessageBox("你刚刚已经向这位哈奇发起过邀请了，请耐心等待或过会再发吧！");
				else
					local is_in_same_gameserver = true;
					if(not is_in_same_gameserver) then
						_guihelper.MessageBox("很抱歉，你们不在同一个服务器， 不能邀请他入队哦！");
					else
						-- now send the invitation to the nid
						jc:TeamInviteMember(nid);
						self.last_invite_times[nid] = commonlib.TimerManager.GetCurrentTime();
						-- tricky: we will never clear the pending_invite map, so that member can leave and rejoin freely
						self.pending_invite[nid] = true;
					end
				end
			else
				_guihelper.MessageBox("这位哈奇已经是你的队友了！");
			end
		end
	end
end

-- any one that is not already in a team can call this function to join a given person (any person). 
-- @param bSilent: true if silent mode. 
function TeamClientLogics:JoinTeamMember(nid, bSilent)
	nid = tonumber(nid);
	if(not nid) then return end
	if(System.User.nid == nid) then
		-- one can not join itself. 
		return;
	end

	local jc = self:GetJC();
	if(jc) then
		local bCanJoin;
		local bForceJoin; -- true to join without any checking or ui interactions.

		-- join team 
		local function JoinTeam_()
			jc:TeamJoinMember(nid);
			self.last_join_times[nid] = commonlib.TimerManager.GetCurrentTime();
			self.pending_join[nid] = true;
		end

		if(jc:IsInTeam()) then
			local curTeamLeader = jc:GetTeamLeaderNid();
			
			if(LobbyClientServicePage.GetLoginRoomOwnerNID) then
				local curLobbyGameLeader = LobbyClientServicePage.GetLoginRoomOwnerNID();
				if(curLobbyGameLeader and tostring(nid)==tostring(curLobbyGameLeader) and curTeamLeader and tostring(nid)~=tostring(curTeamLeader)) then
					-- leave current room
					self:LeaveTeam();
					-- then join the new room after 2 second
					local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
						LOG.std(nil, "system", "TeamClientLogics", "force leaving current room since we need to join another team: %s", tostring(nid))
						JoinTeam_();

						timer:Change();
					end})
					mytimer:Change(3000, nil);
					return;
				end
			end
			_guihelper.MessageBox("很抱歉， 你已经在队伍中， 不能再申请加入其他队伍！<br/>点击左上角的人物名称, 从下拉菜单中可以【退出队伍】");
		else
			if(self.last_join_times[nid] and (self.last_join_times[nid] + self.min_join_interval) > commonlib.TimerManager.GetCurrentTime()) then
				if(not bSilent) then
					_guihelper.MessageBox("你刚刚已经向这个队伍发起过入队申请，请耐心等待或过会再发吧！");
				end
			else
				JoinTeam_();
			end
		end
	end
end

-- get next room key. 
function TeamClientLogics:GetNextRoomKey()
	self.next_key = (self.next_key or math.random(1,40)) + 1;
	local room_key = tostring(System.User.nid)..":"..tostring(self.next_key);
	return room_key;
end

-- call this function to prepare all team members before entering a world together. 
-- only the team leader can call this function. it will generate the room key and broadcast it to all users. 
-- @param params: {name=worldname, }
-- @return params. 
function TeamClientLogics:PrepareTeamWorld(params)
	local jc = self:GetJC();
	if(jc) then
		if(jc:IsTeamLeader()) then
			params.room_key = self:GetNextRoomKey();

			-- TODO: now broadcast the room_key and world name to all other team members. 
			self:SendTeamChatMessage({type="joinworld", params={name = params.name, room_key = params.room_key}}, true)

			--[[ having this room_key, each team member can join using this function. 
			System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {
				name = "HaqiTown_FireCavern",
				room_key = "some_nid_12345:1",
				create_join = true,
				is_local_instance = true,
			});]]
			return params;
		else
			_guihelper.MessageBox("你不是队长，不能开启副本");
		end
	end
end

local function ForceEnterLobby(world_info, force_owner)
	local login_room_id = LobbyClientServicePage.GetRoomID();
	local game = LobbyClient:GetCurrentGame();
	if(not login_room_id or not game or 
		(game.keyname ~= world_info.name) or 
		(force_owner and tostring(game.owner_nid)~=tostring(System.User.nid))) then
		local game = {
				game_type = "PvE",
				keyname = world_info.name,
				max_players = 4,
				min_level = 0,
				max_level = 100,
				name = "30分钟",
				leader_text = "",
				is_persistent = nil,
			}
		LobbyClientServicePage.DoCreateGame(game, nil, false);
	else
		-- do nothing, if user already in a lobby of its containing world. 
	end
end

function TeamClientLogics:EnableWorldTeamTimer()
	self.teamworld_timer = self.teamworld_timer or commonlib.Timer:new({callbackFunc = function(timer)
		self:OnWorldTeamTimer();
	end})
	self.teamworld_timer:Change(5000, 5000);
end


-- this timer is enabled when user is inside a world whose force_teamworld=="true"
function TeamClientLogics:OnWorldTeamTimer()
	local jc = self:GetJC();
	if (not jc or not System.User.is_ready) then
		return
	end
	local world_info = WorldManager:GetCurrentWorld();
	local login_room_id = LobbyClientServicePage.GetRoomID();
	local game_info = LobbyClient:GetCurrentGame();
	if(not login_room_id) then
		game_info = nil;
	end

	-- update team head on display
	self:UpdateTeamHeadonDisplay();

	if(world_info.force_teamworld) then
		if(game_info) then
			if(game_info.keyname ~= world_info.name) then
				LobbyClientServicePage.DoLeaveGame(game_info.id);
			end
		end
		-- 1. If a user is not in a team, kick out from the world.
		if (not jc:IsInTeam()) then

			if(GSL_client:GetAgentCount() == 0) then
				-- register on lobby page. 
				ForceEnterLobby(world_info, true);
			else
				if(not login_room_id) then
					-- kick the user out, if there are too many users in the world and that the user is not in a team. 
					_guihelper.MessageBox("你不在队伍中, 不能留在这个世界了");
					NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
					local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
					GathererBarPage.Start({ duration = 5000, auto_resume=true, title = "正在离开世界", disable_shortkey = true, align="_ct", x=-100, y=260,},nil,function()
						WorldManager:TeleportBack();
					end);
					
				elseif(game_info and tostring(game_info.owner_nid) ~= tostring(System.User.nid)) then
					-- not in a team and not the owner of the game, leave the world. 
					LobbyClientServicePage.DoLeaveGame(game_info.id);
					_guihelper.MessageBox("你不在队伍中, 不能留在这个世界了");
					NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
					local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
					GathererBarPage.Start({ duration = 5000, auto_resume=true, title = "正在离开世界", disable_shortkey = true, align="_ct", x=-100, y=260,},nil,function()
						WorldManager:TeleportBack();
					end);
				end
			end
		else
			local follow_nid = AutoFollowAI:GetFollowTarget();
			local team_leader_nid = self:GetTeamLeaderNid();
			if(self:IsTeamLeader()) then
				if(follow_nid) then
					-- team leader should never follow any target in force_teamworld world.  
					AutoFollowAI:Follow("follow", nil)
				end

				-- The team leader in team world shall kick any team member that is not in the lobby room. 
				-- If two team members already pre-form a team, we will assume they quickly join a lobby before this logic takes effect. 
				if(login_room_id and game_info) then
					local team = jc:GetTeam();
					local item = team:first();
					while (item) do
						if(not game_info.players[tostring(item.nid)] ) then
							self:DelTeamMember(item.nid);
							break;
						end
						item = team:next(item)
					end
				end

				if(self:GetMemberCount()<4) then
					ForceEnterLobby(world_info);
				else
					-- TODO: exit lobby if full. 
				end
			else
				-- follow the team leader, it has not been followed yet (the user can only leave follow mode if it leaves the world). 
				if(tostring(team_leader_nid) ~= tostring(follow_nid)) then
					AutoFollowAI:Follow("follow", self:GetTeamLeaderNid(), nil)
				end
				
			end
		end
		
	else
		local leader_in_teamworld;
		if(game_info and game_info.keyname ~= world_info.name) then
			local game_world_info = WorldManager:GetWorldInfo(game_info.keyname);
			if(game_world_info and game_world_info.force_teamworld) then
				if(tostring(game_info.owner_nid) == tostring(System.User.nid)) then
					-- leave the lobby if the game owner leaves a force_teamworld world. 
					LobbyClientServicePage.DoLeaveGame(game_info.id);
					-- TODO: if there is only two people and the team leader left the world, it may also cause the other people to be forced out of the world. 
					-- any way to fix this?

					if(jc:IsInTeam()) then
						NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
						local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
						GathererBarPage.Start({ duration = 5000, auto_resume=true, title = "正在离开队伍", disable_shortkey = true, align="_ct", x=-100, y=200,},nil,function()
							TeamClientLogics:LeaveTeam();
						end);
					end
				else
					if(jc:IsInTeam()) then
						if( not self:IsTeamLeader()) then
							local follow_nid = AutoFollowAI:GetFollowTarget();
							local team_leader_nid = self:GetTeamLeaderNid();
							-- ask the team leader to join the game world
							if(tostring(team_leader_nid) ~= tostring(follow_nid)) then
								TeamMembersPage.DoFollowUser(self:GetTeamLeaderNid());
							else
							
								leader_in_teamworld = true;
								BroadcastHelper.PushLabel({id="teamworld", label = "请让队长召唤你或者跟随队长进入副本继续悬赏任务", max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
								-- wait for 5 ticks (5*5=25 seconds) before we prompt again. 
								if(not self.get_back_ticks or self.get_back_ticks > 5) then
									self.get_back_ticks = 1;
									_guihelper.MessageBox("你和队长不在同一个世界中, 是否马上回到队长身边", function(res)
										if(res and res == _guihelper.DialogResult.Yes) then
											TeamMembersPage.DoFollowUser(self:GetTeamLeaderNid());
										end
									end, _guihelper.MessageBoxButtons.YesNo);
								else
									self.get_back_ticks = self.get_back_ticks + 1;
								end
							end
						end
					else
						-- let the lobby to resend make team request. 
						self:JoinTeamMember(game_info.owner_nid, true);
					end
				end
			end
		end

		if(not leader_in_teamworld) then
			self.get_back_ticks = nil;
		end

		if(self:IsTeamLeader()) then
			-- for simplicity leave the team if out of the world. 
			-- TODO: we may give the team leader to the next team member in the target world. 
			--TeamClientLogics:LeaveTeam();
			
			if(game_info and game_info.keyname == world_info.name) then
				local nid, _
				for nid, _ in pairs(game_info.players) do
					if(TeamClientLogics:MyTeamIncludeMember(nid)) then
						count = count + 1;
					end
				end
			end
			
		end
	end
end


-- mapping from nid to "leader" or "member"
local last_teams = {{}, {}, {}, {}};

-- @param identity: nil or "leader" or "member"
local function UpdateUserHeadonDisplay_(index, nid, identity)
	local item  = last_teams[index];
	--if( item.nid ~= nid or item.identity ~= identity) then
		if(item.nid ~= nid and item.nid) then
			Headon_OPC.ChangeHeadonMark(item.nid, nil);
		end
		item.nid = nid;
		item.identity = identity;
		if(nid) then
			Headon_OPC.ChangeHeadonMark(nid, identity);
		end
	--end
end

-- update the headon display of team members in framemove function. every 5 seconds. 
function TeamClientLogics:UpdateTeamHeadonDisplay()
	if(System.options.version == "kids") then
		-- only for kids version 
		local jc = self:GetJC();
		if(jc)then
			local team = jc:GetTeam();
			local item = team:first();
			local index = 1;
			while (item) do
				UpdateUserHeadonDisplay_(index, item.nid, if_else(index==1, "leader", "member"));
				item = team:next(item);
				index = index + 1;
			end

			for index = index, 4 do
				UpdateUserHeadonDisplay_(index, nil, nil);
			end
		end
	end
end
