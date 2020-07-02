--[[
Title: Lobby Page
Author(s): LiXizhi
Date: 2011/3/17
Desc: script/apps/Aries/CombatRoom/LobbyClientServicePage.html
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
LobbyClientServicePage.ShowPage();
LobbyClientServicePage.ShowPageByType("PvE");

NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
LobbyClientServicePage.__ShowPage();


NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
LobbyClientServicePage.ClosePage();

NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
LobbyClientServicePage.LoadRoomState(function(msg)
	commonlib.echo("=========msg");
	commonlib.echo(msg);
end)
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
LobbyClientServicePage.selected_game_id = 1;
LobbyClientServicePage.OnClickJoinGame();

NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
QuestHelp.is_kids_version = false;

local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
LobbyClientServicePage.StopRefreshTimer()

NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
LobbyClientServicePage.LoadRemoteData(nid,980,1002,function(msg)
	commonlib.echo("========msg");
	commonlib.echo(msg);
end)
LobbyClientServicePage.SaveRemoteData(980,1002,{ test = "hello"},function(msg)
	commonlib.echo("========savemsg");
end)

NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
local cnt = LobbyClientServicePage.GetTodayCnt_WorldInstance("HaqiTown_YYsNightmare")
commonlib.echo("=========cnt");
commonlib.echo(cnt);
LobbyClientServicePage.AddTodayCnt_WorldInstance("HaqiTown_YYsNightmare")
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPane.lua");
local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
NPL.load("(gl)script/apps/Aries/CombatRoom/ModeMenuPage.lua");
local ModeMenuPage = commonlib.gettable("MyCompany.Aries.CombatRoom.ModeMenuPage");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Desktop/MapArea.lua");
local MapArea = commonlib.gettable("MyCompany.Aries.Desktop.MapArea");
NPL.load("(gl)script/apps/Aries/Scene/main.lua");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");
NPL.load("(gl)script/apps/Aries/Scene/main.lua");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
NPL.load("(gl)script/ide/TooltipHelper.lua");
local HolidayHelper = commonlib.gettable("CommonCtrl.HolidayHelper");
NPL.load("(gl)script/apps/Aries/Player/main.lua");
local Player = commonlib.gettable("MyCompany.Aries.Player");
NPL.load("(gl)script/ide/TooltipHelper.lua");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
NPL.load("(gl)script/apps/Aries/Team/TeamMembersPage.lua");
local TeamMembersPage = commonlib.gettable("MyCompany.Aries.Team.TeamMembersPage");

NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");
local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");

NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");

NPL.load("(gl)script/apps/Aries/CombatRoom/RoomDetailPage.lua");
local RoomDetailPage = commonlib.gettable("MyCompany.Aries.CombatRoom.RoomDetailPage");

NPL.load("(gl)script/apps/Aries/CombatRoom/RoomFilterPage.lua");
local RoomFilterPage = commonlib.gettable("MyCompany.Aries.CombatRoom.RoomFilterPage");

NPL.load("(gl)script/apps/Aries/Desktop/EXPBuffArea.lua");
local EXPBuffArea = commonlib.gettable("MyCompany.Aries.Desktop.EXPBuffArea");

NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");

NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatMessage.lua");
local ChatMessage = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatMessage");

NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfileManager.lua");
local ProfileManager = commonlib.gettable("Map3DSystem.App.profiles.ProfileManager");

NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyChatPage.lua");
local LobbyChatPage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyChatPage");

NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");

NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotionHelper.lua");
local CombatSceneMotionHelper = commonlib.gettable("MotionEx.CombatSceneMotionHelper");

NPL.load("(gl)script/apps/Aries/Instance/main.lua");
local Instance = commonlib.gettable("MyCompany.Aries.Instance");

NPL.load("(gl)script/apps/Aries/Team/TeamWorldInstancePortal.lua");
local TeamWorldInstancePortal = commonlib.gettable("MyCompany.Aries.Team.TeamWorldInstancePortal");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");

NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");

NPL.load("(gl)script/apps/Aries/CombatRoom/CreateRoomPage.lua");
local CreateRoomPage = commonlib.gettable("MyCompany.Aries.CombatRoom.CreateRoomPage");

local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
			
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
NPL.load("(gl)script/apps/Aries/CombatRoom/WorldTeamQuest.lua");
local WorldTeamQuest = commonlib.gettable("MyCompany.Aries.CombatRoom.WorldTeamQuest");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
LobbyClientServicePage.rooms_map = nil;
-- this is the formated data source. 
LobbyClientServicePage.rooms_list = {};
-- current selection in the page for game detail display. 
LobbyClientServicePage.selected_game_id = nil;
LobbyClientServicePage.selected_game = nil;
LobbyClientServicePage.selected_game_info = {};
LobbyClientServicePage.selected_game_type = "PvE";
LobbyClientServicePage.auto_start = true;
LobbyClientServicePage.refresh_timer = nil;
LobbyClientServicePage.loots_str_list = {};
LobbyClientServicePage.boss_str_list = {};--副本boss信息
LobbyClientServicePage.filter_state = nil;
LobbyClientServicePage.lock_mode_maps = {
	["HaqiTown_GraduateExam_54_55"] = true,
}
LobbyClientServicePage.is_search_state = false;
LobbyClientServicePage.search_txt = nil;
LobbyClientServicePage.search_result_list = nil;
LobbyClientServicePage.mode_template = {
	"单人","普通","精英","英雄","炼狱",
};

LobbyClientServicePage.award_tag_gsid_for_3v3_kids = 50420;

function LobbyClientServicePage.StopRefreshTimer()
	local self = LobbyClientServicePage;
	if(self.refresh_timer)then
		self.refresh_timer:Change();
	end
end
--当撮合大厅面板打开时，每3秒自动刷新一次数据，保持显示最新数据
function LobbyClientServicePage.StartRefreshTimer()
	local self = LobbyClientServicePage;
	if(not self.refresh_timer)then
		self.refresh_timer = commonlib.Timer:new({callbackFunc = function(timer)
			if(not self.page)then
				self.StopRefreshTimer();
				return;
			end
			self.RefreshRooms();
		end})
	end
	self.refresh_timer:Change(0,10000);
end
--true,auto login world nothing tooltip
function LobbyClientServicePage.IsAutoStart()
	local self = LobbyClientServicePage;
	return self.auto_start;
end
function LobbyClientServicePage.OnInit()
	local self = LobbyClientServicePage;
	self.page = document:GetPageCtrl();
end

function LobbyClientServicePage.DS_Func(index)
	local self = LobbyClientServicePage;
	local list;
	if(self.IsSearchState())then
		list = self.search_result_list;
	else
		list = self.rooms_list;
	end
	if(not list)then return nil end
	if(index == nil) then
		self.none_result = true;
		return #(list);
	else
		return list[index];
	end
end

function LobbyClientServicePage.RefreshPage()
	local self = LobbyClientServicePage;
	if(self.page)then
		self.RefreshRooms();
	end
end
function LobbyClientServicePage.ClosePage()
	local self = LobbyClientServicePage;
	if(self.page)then
		self.none_result = nil;
		self.page:CloseWindow();
		self.page = nil;
		self.selected_game_id = nil;
		self.selected_game = nil;
		self.selected_game_type = "PvE";
		self.loots_list = nil;
		RoomFilterPage.ClearData();
		self.is_search_state = false;
		self.search_txt = nil;
	end	
	self.StopRefreshTimer();
end
--[[
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
LobbyClientServicePage.DirectShowPage("PvP",{ 
	HaqiTown_RedMushroomArena_1v1= true, 
	HaqiTown_RedMushroomArena_2v2 = true, 
	});
--]]
--@param game_type:"PvP" or "PvE"
--@param worldname_map:要显示的副本列表
--@param dofilter:是否过滤为适合自己等级的结果
function LobbyClientServicePage.DirectShowPage(game_type,worldname_map,dofilter)
	local self = LobbyClientServicePage;
	self.selected_game_type = game_type;
	worldname_map = worldname_map or {};
	local combat_level = LobbyClient:GetMyCombatLevel()
	local game_key_array = LobbyClient:GetGameKeysByUserLevel(nil, game_type, true);
	local game_templates = LobbyClient:GetGameTemplates();
	local right_game_key_array = LobbyClient:GetGameKeysByUserLevel(combat_level, game_type, true);
	if(game_key_array and game_templates)then
		local unchecked_list = {};
		local k,v; 
		for k,v in pairs(game_templates) do
			local __,keyname;
			for __,keyname in ipairs(game_key_array) do
				if(v.keyname == keyname)then
					unchecked_list[keyname] = false;
					if(not worldname_map[v.worldname])then
						unchecked_list[keyname] = true;
					end
				end
			end
		end
		if(dofilter)then
			local keyname,v;
			for keyname,v in pairs(unchecked_list) do
				--检查已经选中的
				if(v == false)then
					local bfind = false;
					local kk,keyname_2;
					for kk,keyname_2 in ipairs(right_game_key_array) do
						if(keyname == keyname_2)then
							bfind = true;
						end
					end
					if(not bfind)then
						--取消选中
						unchecked_list[keyname] = true;
					end
				end
			end
		end
		RoomFilterPage.SetUncheckedArray(game_type,unchecked_list)
		self.__ShowPage();
	end
end
--显示全部 或者 只适合自己等级的
function LobbyClientServicePage.DoFilter(filter_state)
	local self = LobbyClientServicePage;
	local game_type = self.selected_game_type;
	--所有的都选中
	local unchecked_list = {};
	if(filter_state == "my_combat_level")then
		RoomFilterPage.SetUncheckedArray(game_type,nil)
		unchecked_list = RoomFilterPage.GetUncheckedArray(game_type,true)
		RoomFilterPage.SetUncheckedArray(game_type,unchecked_list)
	else
		RoomFilterPage.SetUncheckedArray(game_type,unchecked_list)
	end
	self.filter_state = filter_state;
	self.RefreshPage();
end
function LobbyClientServicePage.ShowPage_SearchRoomDialog()
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/CombatRoom/SearchRoomDialog.html", 
			name = "LobbyClientServicePage.ShowPage_SearchRoomDialog", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			enable_esc_key = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -295/2,
				y = -130/2,
				width = 275,
				height = 130,
		});
end

function LobbyClientServicePage.__ShowPage()
	local self = LobbyClientServicePage;
	local url = "script/apps/Aries/CombatRoom/LobbyClientServicePage.html";
	local allowDrag = false;
	if(not QuestHelp.IsKidsVersion())then
		url = "script/apps/Aries/CombatRoom/Teen/LobbyClientServicePage.v2.teen.html";
		allowDrag = true;
	end
	LobbyClientServicePage.selected_mode_loots_menu = nil;
	local params = {
			url = url, 
			name = "LobbyClientServicePage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			enable_esc_key = true,
			allowDrag = allowDrag,
			directPosition = true,
				align = "_ct",
				x = -950/2,
				y = -550/2,
				width = 950,
				height = 550,
		}
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	if(params._page and Dock.OnClose) then
		params._page.OnClose = function(bDestroy)
			Dock.OnClose("LobbyClientServicePage.ShowPage")
		end
	end
	self.is_search_state = false;
	self.search_txt = nil;
	-- force a refresh whenever the user click to open this page. 
	self.RefreshRooms();
	self.StartRefreshTimer();
end
function LobbyClientServicePage.ShowPage_ByMenu(node)
	local self = LobbyClientServicePage;
	if(not node)then return end
	local state = node.state;
	if(state == "myroom")then
		local login_room_id = self.GetRoomID();
		RoomDetailPage.ShowPage(login_room_id);
	elseif(state == "roomlist")then
		self.__ShowPage();
	end
end
function LobbyClientServicePage.MenuClick(node)
	local self = LobbyClientServicePage;
    local bean = MyCompany.Aries.Pet.GetBean() or {};
	local combatlel = bean.combatlel or 0;
	local name = node.Name;
	if(name == "open_world")then
		local worldname = node.worldname;
		self.DoAutoJoinRoom(worldname, "PvE");
	elseif(name == "myroom")then
		local login_room_id = self.GetRoomID();
		RoomDetailPage.ShowPage(login_room_id);
	elseif(name == "pvp_practice")then
		NPL.load("(gl)script/apps/Aries/NPCs/SunnyBeach/PvPTicket.lua");
		local PvPTicket_NPC = commonlib.gettable("MyCompany.Aries.Quest.NPCs.PvPTicket_NPC");
		PvPTicket_NPC.Join_HaqiTown_Practice_PVP_1V1()
	elseif(name == "pvp_1v1_join")then
		NPL.load("(gl)script/apps/Aries/NPCs/SunnyBeach/PvPTicket.lua");
		local PvPTicket_NPC = commonlib.gettable("MyCompany.Aries.Quest.NPCs.PvPTicket_NPC");
		PvPTicket_NPC.Join1v1();
		--self.DoAutoJoinRoom("HaqiTown_RedMushroomArena_1v1", "PvP");
	elseif(name == "pvp_2v2_join")then
		NPL.load("(gl)script/apps/Aries/NPCs/SunnyBeach/PvPTicket.lua");
		local PvPTicket_NPC = commonlib.gettable("MyCompany.Aries.Quest.NPCs.PvPTicket_NPC");
		PvPTicket_NPC.Join2v2();
		--self.DoAutoJoinRoom("HaqiTown_RedMushroomArena_2v2", "PvP");
	elseif(name == "pvp_3v3_join") then
		WorldManager:GotoNPC(30559,function()
		end)
	elseif(name == "pvp_2v2_join_forkids") then
		WorldManager:GotoNPC(30423,function()
		end)
	elseif(name == "pvp_rank")then
		MyCompany.Aries.GoldRankingList.GoldRankingListMain.ShowMainWnd();
	elseif(name == "pvp_room")then
		LobbyClientServicePage.ShowPageByType("PvP");
	elseif(name == "pve_room")then
		LobbyClientServicePage.ShowPageByType("PvE");
	elseif(name == "pvp_fairplay")then
		NPL.load("(gl)script/apps/Aries/Instance/main.lua");
		MyCompany.Aries.Instance.ShowPracticeArenaDialog(true);
	elseif(name == "crazy_tower")then
		NPL.load("(gl)script/apps/Aries/CrazyTower/CrazyTowerPage.lua");
		local CrazyTowerPage = commonlib.gettable("MyCompany.Aries.CrazyTower.CrazyTowerPage");
		CrazyTowerPage.ShowPage();
	elseif(name == "pvp_fair_1v1")then
		local worldname = "HaqiTown_TrialOfChampions_Amateur1v1";
		if(combatlel >= 40)then
			worldname = "HaqiTown_TrialOfChampions_Intermediate1v1";
		else
			worldname = "HaqiTown_TrialOfChampions_Amateur1v1";
		end
		if(not TeamClientLogics:IsInTeam())then
			LobbyClientServicePage.DoAutoJoinRoom(worldname, "PvP");
		else
			_guihelper.MessageBox("你在组队中, 请先离开现在的队伍");
		end
	elseif(name == "pvp_fair_2v2")then
		local worldname = "HaqiTown_TrialOfChampions_Amateur";
		if(combatlel >= 50)then
			worldname = "HaqiTown_TrialOfChampions_Master";
		elseif(combatlel >= 40)then
			worldname = "HaqiTown_TrialOfChampions_Intermediate";
		elseif(combatlel >= 20)then
			worldname = "HaqiTown_TrialOfChampions_Amateur";
		end
		if(not TeamClientLogics:IsInTeam())then
			_guihelper.MessageBox("你还没有组队. <br/>确定需要系统帮你安排队友吗？", function(res)
				if(res and res == _guihelper.DialogResult.Yes) then
					LobbyClientServicePage.DoAutoJoinRoom(worldname, "PvP")
				end
			end, _guihelper.MessageBoxButtons.YesNo)
		else
			LobbyClientServicePage.DoAutoJoinRoom(worldname, "PvP", true)
		end
	elseif(name == "battlefield")then
		NPL.load("(gl)script/apps/Aries/Instance/main.lua");
		MyCompany.Aries.Instance.EnterInstance_BattlefieldClient();
	end
end

-- @param game_type: if nil, default to "PvE"
function LobbyClientServicePage.ShowPageByType(game_type)
	LobbyClientServicePage.selected_game_type = game_type or "PvE";
	LobbyClientServicePage.__ShowPage();
end

-- check to see if we are in a room already. if so return 
function LobbyClientServicePage.CheckTeamMode()
	local login_room_id = LobbyClientServicePage.GetRoomID();
	if(login_room_id)then
		return true;
	else
		if(TeamClientLogics:IsInTeam() and not TeamClientLogics:IsTeamLeader()) then
			-- if we are in a team but not team leader, we will ask the team leader which room it is in. 

		end
	end
	
end

function LobbyClientServicePage.ShowPage()
	local room_id = LobbyClientServicePage.GetRoomID();
	if(not room_id) then
		if(TeamClientLogics:IsInTeam() and not TeamClientLogics:IsTeamLeader()) then
			BroadcastHelper.PushLabel({id="lobbyquery", label = "你在队伍中,请等待队长的邀请", max_duration=5000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
			_guihelper.MessageBox("你在队伍中,请等待队长的邀请<br/>点击左上角的人物名称, 从下拉菜单中可以【退出队伍】");
			LobbyClientServicePage.QueryLobbyRoom()
			return;
		end
	else
		if(not TeamClientLogics:IsInTeam() or TeamClientLogics:IsTeamLeader()) then
			-- only the team leader can change room. 
		else
			RoomDetailPage.ShowPage(room_id);
			return;
		end
	end

	local cur_world = WorldManager:GetCurrentWorld();
	if(cur_world.force_teamworld) then
		_guihelper.MessageBox("请先离开你所在的世界, 才能使用这个功能");
		return
	end

	local self = LobbyClientServicePage;
	--取消防沉迷 leio:2011/10/26 
	--if(AntiIndulgenceArea.IsAntiSystemIsEnabled()) then
		--self.selected_game_type = "PvP";
	--end
	if(CommonClientService.IsKidsVersion())then
				
		local ctl = LobbyClientServicePage.menu_ctl;
		if(not ctl)then
			ctl = CommonCtrl.ContextMenu:new{
				name = "LobbyClientServicePage.LobbyMainMenu.ShowPage",
				width = 200,
				height = 80, -- add menuitemHeight(30) with each new item
				DefaultNodeHeight = 26,
				style = CommonCtrl.ContextMenu.DefaultStyleThick,
			};
			local node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "", Name = "root_node", Type = "Group", NodeHeight = 0 });
			node:AddChild(CommonCtrl.TreeNode:new({Text = "我的队伍", Name = "myroom", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));

			--local crazy_node = CommonCtrl.TreeNode:new({Text = "怪物军团", Name = "crazytower_menu", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, });
			--crazy_node:AddChild(CommonCtrl.TreeNode:new({Text = "咕噜军团的大本营(4人)", Name = "open_world", worldname = "CrazyTower_WaterBubbleSupreme", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
			--crazy_node:AddChild(CommonCtrl.TreeNode:new({Text = "铁壳军团的大本营(4人)", Name = "open_world", worldname = "CrazyTower_IroncladSupreme", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
			--crazy_node:AddChild(CommonCtrl.TreeNode:new({Text = "胖胖军团的大本营(4人)", Name = "open_world", worldname = "CrazyTower_SnowmanSupreme", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
			--node:AddChild(crazy_node);

			node:AddChild(CommonCtrl.TreeNode:new({Text = "试炼秘境", Name = "crazy_tower", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "勇士大厅", Name = "pve_room", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "PK练习赛", Name = "pvp_fairplay", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
			local pvp_node = CommonCtrl.TreeNode:new({Text = "红蘑菇赛场", Name = "pvp_menu", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, });
			pvp_node:AddChild(CommonCtrl.TreeNode:new({Text = "智能加入1v1(推荐)", Name = "pvp_1v1_join", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
			pvp_node:AddChild(CommonCtrl.TreeNode:new({Text = "智能加入2v2(推荐)", Name = "pvp_2v2_join_forkids", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
			pvp_node:AddChild(CommonCtrl.TreeNode:new({Text = "智能加入3v3(推荐)", Name = "pvp_3v3_join", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
			-- 2014.05 2v2 暂时关闭
			--pvp_node:AddChild(CommonCtrl.TreeNode:new({Text = "智能加入2v2(推荐)", Name = "pvp_2v2_join", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
			pvp_node:AddChild(CommonCtrl.TreeNode:new({Text = "排行榜", Name = "pvp_rank", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
			node:AddChild(pvp_node);
			
			LobbyClientServicePage.menu_ctl = ctl;
		end
	
		if(ctl.RootNode) then	
			local node = ctl.RootNode:GetChildByName("root_node");
			if(node) then
				local tmp = node:GetChildByName("myroom");
				if(tmp) then
					local login_room_id = LobbyClientServicePage.GetRoomID();
					if(login_room_id)then
    					tmp.Invisible = false;
					else    
    					tmp.Invisible = true;
					end
				end
			end
		end
		local x, y, width, height = _guihelper.GetLastUIObjectPos();
		if(x and y)then
			ctl:Show(x, y + height - (ctl.style.fillTop or 0));
		end
		return;
	else
		local login_room_id = LobbyClientServicePage.GetRoomID();
		if(not login_room_id) then
			self.selected_game_type = "PvE";
			self.__ShowPage();
			return;
		end
		-- teen version
		local ctl = self.menu_ctl;
		if(not ctl)then
			ctl = CommonCtrl.ContextMenu:new{
				name = "LobbyClientServicePage.ShowPage",
				width = 140,
				height = 80, -- add menuitemHeight(30) with each new item
				DefaultNodeHeight = 24,
				AutoPositionMode = "_lb",
				style = CommonCtrl.ContextMenu.DefaultStyleThick,
			};
			local node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "", Name = "root_node", Type = "Group", NodeHeight = 0 });
			node:AddChild(CommonCtrl.TreeNode:new({Text = "我的队伍", Name = "myroom", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "副本大厅", Name = "pve_room", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
			
			self.menu_ctl = ctl;
		end
		if(ctl.RootNode) then	
			local node = ctl.RootNode:GetChildByName("root_node");
			if(node) then
				local tmp = node:GetChildByName("myroom");
				if(tmp) then
					if(login_room_id)then
    					tmp.Invisible = false;
					else    
    					tmp.Invisible = true;
					end
				end
			end
		end
		local x, y, width, height = _guihelper.GetLastUIObjectPos();
		if(x and y)then
			ctl:Show(x, y-10);
		end
	end
end

function LobbyClientServicePage.ShowPagePvP()
	local self = LobbyClientServicePage;
	local room_id = LobbyClientServicePage.GetRoomID();
	if(not room_id) then
		if(TeamClientLogics:IsInTeam() and not TeamClientLogics:IsTeamLeader()) then
			BroadcastHelper.PushLabel({id="lobbyquery", label = "你在队伍中,请等待队长的邀请", max_duration=5000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
			LobbyClientServicePage.QueryLobbyRoom()
			return;
		end
	else
		if(not TeamClientLogics:IsInTeam() or TeamClientLogics:IsTeamLeader()) then
			-- only the team leader can change room. 
		else
			RoomDetailPage.ShowPage(room_id);
			return;
		end
	end

	--取消防沉迷 leio:2011/10/26 
	--if(AntiIndulgenceArea.IsAntiSystemIsEnabled()) then
		--self.selected_game_type = "PvP";
	--end
	if(CommonClientService.IsKidsVersion())then
	else
		local login_room_id = self.GetRoomID();
		if(login_room_id or true)then
			local ctl = self.menu_pvp_ctl;
			if(not ctl)then
				ctl = CommonCtrl.ContextMenu:new{
					name = "LobbyClientServicePage.ShowPagePvp",
					width = 140,
					height = 80, -- add menuitemHeight(30) with each new item
					DefaultNodeHeight = 24,
					--AutoPositionMode = "_lb",
					style = CommonCtrl.ContextMenu.DefaultStyleThick,
				};
				local node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "", Name = "root_node", Type = "Group", NodeHeight = 0 });
				
				node:AddChild(CommonCtrl.TreeNode:new({Text = "我的队伍", Name = "myroom", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
				node:AddChild(CommonCtrl.TreeNode:new({Text = "红蘑菇赛场 (1v1)", Name = "pvp_1v1_join", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
				--node:AddChild(CommonCtrl.TreeNode:new({Text = "红蘑菇赛场 (2v2)", Name = "pvp_2v2_join", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
				node:AddChild(CommonCtrl.TreeNode:new({Text = "公平竞技场 (1v1)", Name = "pvp_fair_1v1", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
				--node:AddChild(CommonCtrl.TreeNode:new({Text = "公平竞技场 (2v2)", Name = "pvp_fair_2v2", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
				node:AddChild(CommonCtrl.TreeNode:new({Text = "英雄谷战场 (16v16)", Name = "battlefield", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
				--node:AddChild(CommonCtrl.TreeNode:new({Text = "练习赛", Name = "pvp_fairplay", Type = "Menuitem", onclick = LobbyClientServicePage.MenuClick, }));
				
				self.menu_pvp_ctl = ctl;
			end
			if(ctl.RootNode) then	
				local node = ctl.RootNode:GetChildByName("root_node");
				if(node) then
					local tmp = node:GetChildByName("myroom");
					if(tmp) then
						local login_room_id = LobbyClientServicePage.GetRoomID();
						if(login_room_id)then
    						tmp.Invisible = false;
						else    
    						tmp.Invisible = true;
						end
					end
				end
			end
			local x, y, width, height = _guihelper.GetLastUIObjectPos();
			if(x and y)then
				ctl:Show(x, y+height);
			end

		else
			self.__ShowPage();
		end
	end
end

function LobbyClientServicePage.ShowDefaultRooms()
	LobbyClientServicePage.__ShowPage();
end

function LobbyClientServicePage.CutDifferenceRegionIDs()
	local self = LobbyClientServicePage;
	if(self.rooms_list)then
		local result = {};
		local k,v;
		for k,v in ipairs(self.rooms_list) do
			local owner_nid = v.owner_nid;
			local cnt = v.count or 0;
			local host_region_id = ExternalUserModule:GetRegionIDFromNid(owner_nid)
			local client_region_id = ExternalUserModule:GetRegionID();
			if(host_region_id and client_region_id)then
				local host_config = ExternalUserModule:GetConfig(host_region_id) or {};
				local client_config = ExternalUserModule:GetConfig(client_region_id) or {};	

				--同一个region 不过滤
				if(host_region_id == client_region_id)then
					table.insert(result,v);
				else
					if(host_config.is_share_lobbyclient)then
						table.insert(result,v);
					end
				end
			end
		end
		self.rooms_list = result;
	end
end
-- refresh the room list with the server.  
function LobbyClientServicePage.RefreshRooms(callbackFunc)
	local self = LobbyClientServicePage;
	local combatlevel = 1;
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		combatlevel = bean.combatlel;
	end
	local game_type = self.selected_game_type or "PvE";
	local game_key_array = LobbyClient:GetGameKeysByUserLevel(nil, game_type, true);
	local unchecked_array = RoomFilterPage.GetUncheckedArray(game_type);
	if(game_key_array and unchecked_array)then
		local new_game_key_array = {};
		local k,v;
		for k,v in ipairs(game_key_array) do
			if(not unchecked_array[v])then
				table.insert(new_game_key_array,v);
			end
		end
		game_key_array = new_game_key_array;
	end
	-- get room list data source. 
	local result = LobbyClient:GetRoomListDataSource(game_key_array, true, function(result)
		if(not result.is_fetching) then
			local list = result.formated_data;
			if(list)then
				local len = #list;
				while(len > 0) do
					
					local room_info = list[len];
					if(room_info and room_info.status == "started")then
						table.remove(list,len);
					end
					len = len - 1;
				end
				LobbyClientServicePage.rooms_list = list;
				if(CommonClientService.IsTeenVersion())then
					CommonClientService.Fill_List(list,13);
				end
				LobbyClientServicePage.CutDifferenceRegionIDs();
				if(LobbyClientServicePage.page)then
					LobbyClientServicePage.page:Refresh(0);
				end
				LobbyClientServicePage.OnSelectGame();
				if(callbackFunc)then
					callbackFunc();
				end
			end
		end
	end)
end
-- Not Implemented: Used for filtering
-- @param game_filters: array of game keys.
function LobbyClientServicePage.UpdateFilter(game_filters)
	local self = LobbyClientServicePage;
	if(not game_filters)then return end
	-- TODO: 
end
-- user selected a game. 
-- this function is also called whenever the room list is refreshed. 
-- @param game_id: int of the room id. if this is nil, it will default to current selection (self.selected_game_id). 
-- if there is no current selection, we will select the first one in the game list. 
function LobbyClientServicePage.OnSelectGame(game_id)
	if(LobbyClientServicePage.rooms_list) then
		game_id = game_id or LobbyClientServicePage.selected_game_id;
		if(not game_id) then
			local room = LobbyClientServicePage.rooms_list[1];
			if(room) then
				game_id = room.game_id;
			end
		end
		local bNeedRefresh = true;
		local index, room;
		for index, room in pairs(LobbyClientServicePage.rooms_list) do
			if(room.game_id ~= game_id) then
				if(room.is_selected) then
					room.is_selected = nil;
				end
			else
				if(not room.is_selected) then
					room.is_selected = true;
					LobbyClientServicePage.selected_game = room;
					--bNeedRefresh = true;
				end
			end
		end
		if(bNeedRefresh) then
			LobbyClientServicePage.selected_game_id = game_id;
			if(LobbyClientServicePage.page)then
				-- refresh the grid view to render the selection. 
				LobbyClientServicePage.page:CallMethod("gvRooms", "DataBind");
			end
			local game_info = LobbyClientServicePage.GetGameInfoByID(LobbyClientServicePage.selected_game_id);
			if(game_info)then
				LobbyClientServicePage.selected_mode_loots_menu = LobbyClientServicePage.selected_mode_loots_menu or game_info.mode;
				
				LobbyClientServicePage.SetLootsList(game_info.keyname,LobbyClientServicePage.selected_mode_loots_menu);
			end
			-- refresh the room details from network. 
			-- LobbyClientServicePage.page:Refresh();
			LobbyClient:GetGameDetail(game_id, true, function(result)
				if(not result.is_fetching) then
					if(result.formated_data) then
						if(LobbyClientServicePage.selected_game_info ~= result.formated_data) then
							LobbyClientServicePage.selected_game_info = result.formated_data;
							--LobbyClientServicePage.SetLootsList(LobbyClientServicePage.selected_game_info);
							if(LobbyClientServicePage.page)then
								LobbyClientServicePage.page:Refresh(0);
							end
						end
					end
				end
			end)
		end
	end
end
function LobbyClientServicePage.GetGameInfoByID(game_id)
	local self = LobbyClientServicePage;
	if(not game_id)then return end
	if(self.rooms_list)then
		local k,room;
		for k,room in ipairs(self.rooms_list) do
			if(room.game_id == game_id)then
				return room;
			end
		end
	end
end

function LobbyClientServicePage.OnClickJoinGame()
	local self = LobbyClientServicePage;
	if(not self.selected_game_id)then return end
	local game_info = self.GetGameInfoByID(self.selected_game_id);
	if(game_info)then
		local can_pass = self.CheckRoomState(game_info.game_type,game_info.worldname);
		if(not can_pass)then
			return
		end
		if(game_info.needpassword)then
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/CombatRoom/PasswordPage.html", 
				name = "LobbyClientServicePage.OnClickJoinGame.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 1,
				isTopLevel = true,
				enable_esc_key = true,
				allowDrag = false,
				directPosition = true,
					align = "_ct",
					x = -255/2,
					y = -120/2,
					width = 255,
					height = 120,
			});
		else
			self.DoJoinGame(self.selected_game_id);
		end
	end
end
-----------------------------------------------------------------
--用户主动发起的行为
-----------------------------------------------------------------
function LobbyClientServicePage.DoInviteAllUser()
	local self = LobbyClientServicePage;
	local min_invite_interval = 10000;
	if(not self.last_invite_times_team or (self.last_invite_times_team + min_invite_interval) < commonlib.TimerManager.GetCurrentTime()) then
		self.last_invite_times_team = commonlib.TimerManager.GetCurrentTime();
		if(self.login_room_id)then
			if(not self.CanCallUser())then
				_guihelper.MessageBox("当前世界不能召唤队友!");
				return
			end
			LobbyClient:GetGameDetail(self.login_room_id, true, function(result)
					if(result and result.formated_data) then
						local game_info = result.formated_data;
						 local player_count = game_info.player_count or 0;
						if(player_count <= 1)then
							_guihelper.MessageBox("你不需要给自己发邀请！");
							return;
						end
						local nid,__;
						local nids = {};
						for nid,__ in pairs(game_info.players) do
							local my_self = tostring(Map3DSystem.User.nid);
							if(my_self ~= nid)then
								table.insert(nids,nid);
							end
						end
						local bSend = TeamClientLogics:InviteTeamMember_ByLobbyClient(nids);
						if(bSend)then
							_guihelper.MessageBox("邀请已经发出，请稍等！");
						else
							_guihelper.MessageBox("他们已经在你的队伍中了！");
						end
					end
			end,true)
		end
	else
		_guihelper.MessageBox("你的动作太频繁了，等下再试试吧！");
	end
end
function LobbyClientServicePage.DoCallAllUser()
	local self = LobbyClientServicePage;
	local min_invite_interval = 10000;
	if(not self.last_invite_times or (self.last_invite_times + min_invite_interval) < commonlib.TimerManager.GetCurrentTime()) then
		self.last_invite_times = commonlib.TimerManager.GetCurrentTime();
		if(self.login_room_id)then
			if(not self.CanCallUser())then
				_guihelper.MessageBox("当前世界不能召唤队友!");
				return
			end
			LobbyClient:GetGameDetail(self.login_room_id, true, function(result)
					if(result and result.formated_data) then
						local game_info = result.formated_data;
						if(game_info and game_info.players)then
							local nid,v;
							for nid,v in pairs(game_info.players) do
								self.DoCallUser(nid);
							end
						end	
						if(game_info.player_count > 1)then
							_guihelper.MessageBox("召唤已经发出，请稍等！");
						else
							_guihelper.MessageBox("你现在还没有队员呢，不需要召唤队员！");
						end
					end
			end,true)
		end
	else
		_guihelper.MessageBox("你的动作太频繁了，等下再试试吧！");
	end
end
function LobbyClientServicePage.CanCallUser()
	local self = LobbyClientServicePage;
	local address = WorldManager:GetWorldAddress();
	if(not address)then
		return
	end
	return true;
end

--NOTE:对发起者没有权限判断
function LobbyClientServicePage.DoCallUser(nid)
	local self = LobbyClientServicePage;
	if(not nid)then return end
	nid = tostring(nid);
	local myself = tostring(System.User.nid);
	if(myself == nid)then
		return
	end
	local address = WorldManager:GetWorldAddress();
	if(not address)then
		return
	end
	local game_id = self.GetRoomID();
	if(not game_id)then
		return
	end
	local address_info = {
		game_id = game_id,
		nid = nid,
		address = address,
	}
	LobbyClient:CallUserToWorldAddress(address_info);
end
--更改副本难度
function LobbyClientServicePage.DoResetGameMode(game_settings)
	local self = LobbyClientServicePage;
	if(not game_settings)then return end
	LobbyClient:ResetGameMode(game_settings,function(result)
		--RoomDetailPage.ShowPage(result.msg.msg.id)
		--self.SetRoomID(result.msg.msg.id);
	end)
end
-- reset a game. 
function LobbyClientServicePage.DoResetGame(game_settings)
	local self = LobbyClientServicePage;
	if(not game_settings)then return end
	LobbyClient:ResetGame(game_settings,function(result)
		--RoomDetailPage.ShowPage(result.msg.msg.id)
		--self.SetRoomID(result.msg.msg.id);
	end)
end

-- create a new game. 
-- @param is_start_now: whether to start immediately after game is created. 
-- @param is_auto_start: whether the auto start is checked when creating the game. 
function LobbyClientServicePage.DoCreateGame(game_settings, is_start_now, is_auto_start)
	local self = LobbyClientServicePage;
	if(not game_settings)then return end
	--check state
	local game_type = game_settings.game_type;
	local keyname = game_settings.keyname;

	local template = self.GetGameTemplateByKeyName(keyname);
	local worldname;
	if(template)then
		worldname = template.worldname;
	end
	local can_pass = self.CheckRoomState(game_type,worldname);
	if(not can_pass)then
		return
	end

	local world = WorldManager:GetWorldInfo(worldname);
	if(world and world.force_teamworld) then
		local cur_world = WorldManager:GetCurrentWorld();
		if(cur_world and cur_world.name == worldname) then
			-- we will only allow creating room when we are already in the world. 
		else
			local room_key = TeamClientLogics:GetNextRoomKey();

			local force_nid = string.gsub(room_key,"[^%d]", "");
			if(force_nid) then
				if(#force_nid>10) then
					force_nid = force_nid:sub(#force_nid-10);
				end
				force_nid = tonumber(force_nid)%10000;
			end

			-- if we have not been in the world yet, first login to the world. 
			System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {
					name = worldname,
					force_nid = force_nid,
					room_key = room_key,
					on_finish = function()
						
					end,
				});
			return;
		end
	end

	if(TeamClientLogics:IsInTeam()) then
		if( not TeamClientLogics:IsTeamLeader() ) then
			_guihelper.MessageBox("你已经在队伍中, 请等待你们的队长创建或开启房间.<br/>或者你可以点击左上角的人物名称,从下拉菜单中选择【退出队伍】,再重新进入.");
			return;
		else
			-- if team leader is starting a game, it is never auto started. 
			is_auto_start = false;
			-- if the member count already exceed the max_players count, we will lock the room when creating it. 
			if( TeamClientLogics:GetMemberCount() >= (template.max_players or 4)) then
				game_settings.password = game_settings.password or LobbyClientServicePage.GetNextPassword();
			end
		end
	end

	LobbyClient:CreateGame(game_settings,function(result)
		if(result) then
			self.ClosePage();
			LobbyChatPage.Clear();
			local game_info = result.msg.msg;
			local game_id = game_info.id;
			self.SetRoomID(game_id);
			if(not is_start_now)then
				if(is_auto_start~=nil) then
					LobbyClientServicePage.auto_start = is_auto_start;
				end
				if(world and world.force_teamworld) then
					-- show nothing if in force_teamworld world. 
				else
					RoomDetailPage.ShowPage(game_id);
				end
			else
				self.DoStartGame(game_id,game_type);
			end
			EXPBuffArea.Update_LobbyBtn();
			if(ModeMenuPage.need_broadcast)then
				if(hasGSItem(12049))then
					LobbyClientServicePage.BroadcastRoomMsg(game_info)
				end
				ModeMenuPage.NeedBroadcastWhenCreateRoom(false);
			end
		else
			_guihelper.MessageBox("无法创建房间， 请稍候再试");
		end
	end)
end

function LobbyClientServicePage.GetWorldNameByGameID(game_id)
	local self = LobbyClientServicePage;
	local game_info = self.GetGameInfoByID(game_id);
	local template;
	local worldname;
	if(not game_info) then
		if(RoomDetailPage.game_info and RoomDetailPage.game_info.id == game_id) then
			game_info = RoomDetailPage.game_info;
		end
	end
	if(game_info)then
		template = self.GetGameTemplateByKeyName(game_info.keyname);
		if(template)then
			worldname = template.worldname;
		end
	end
	return worldname;
end
function LobbyClientServicePage.GetGameTemplateByKeyName(keyname)
	if(not keyname)then return end
	local game_templates = LobbyClient:GetGameTemplates();
	local k,v
	for k,v in pairs(game_templates) do
		if(v.keyname == keyname)then
			return v;
		end
	end
end
-- start game
function LobbyClientServicePage.DoStartGame(game_id,game_type,callbackFunc)
	local self = LobbyClientServicePage;
	if(not game_type)then return end
	local worldname = LobbyClientServicePage.GetWorldNameByGameID(game_id);
	local can_pass = self.CheckRoomState(game_type,worldname);
	if(not can_pass)then
		return
	end	

	local world = WorldManager:GetWorldInfo(worldname);
	if(world and world.force_teamworld) then
		local cur_world = WorldManager:GetCurrentWorld();
		if(cur_world and cur_world.name == worldname) then
			_guihelper.MessageBox("你已经在世界中了,  请等待或召换队友前来");
		else
			_guihelper.MessageBox("这个世界无需开始, 请通过队友来传送");
		end
		return;
	end

	local system_looptip = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips.system_looptip");

	if(game_type == "PvP")then
		system_looptip.currentcopy="pvp";-- 记录当前副本类型
		LobbyClient:GetGameDetail(game_id, true, function(result)
				if(result and result.formated_data) then
					local game_info = result.formated_data;
					if(game_info.player_count >= game_info.max_players)then
						LobbyClient:MatchMaking(game_id)
						if(callbackFunc)then
							callbackFunc();
						end
					else
						NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
						local s = string.format("竞技场撮合需要%d个人,你的队伍人数现在还不够呢！",game_info.max_players);
						_guihelper.Custom_MessageBox(s,function(result)
							if(result == _guihelper.DialogResult.OK)then
								commonlib.echo("OK");
							end
						end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
					end

				end
		end,true)
	else
		system_looptip.currentcopy="pve";-- 记录当前副本类型
		LobbyClient:StartGame(game_id);
		if(callbackFunc)then
			callbackFunc();
		end
	end
end
function LobbyClientServicePage.Plain_JoinGame(game_id,password, game_info, success_callback,error_callback)
	if(not game_id)then
		if(error_callback)then
			error_callback();
		end
		return;
	end
	local game_settings = {
		game_id = game_id,
		password = password,
		keyname = game_info.keyname,
	};
	LobbyClient:JoinGame(game_settings,function(result)
		if(result and result.msg and result.msg.msg)then
			if(result.msg.msg.errorcode)then
				local errorcode = result.msg.msg.errorcode;
				local s = "";
				if(errorcode == "wrong_school")then
					s = "你的魔法系别不符合此队伍的要求！"
				elseif(errorcode == "wrong_password")then
					s = "密码错误！"
				elseif(errorcode == "wrong_level")then
					s = "等级不符合要求！"
				elseif(errorcode == "max_user")then
					s = "超过最大人数！"
				elseif(errorcode == "unopen")then
					s = "房间已经关闭！"
				elseif(errorcode =="room_is_nil")then
					s = "房间不存在！"
				elseif(errorcode =="wrong_magic_star_level")then
					s = "魔法星等级不够！"
				elseif(errorcode =="wrong_attack")then
					s = "攻击力不够！"
				elseif(errorcode =="wrong_hit")then
					s = "命中率不够！"
				elseif(errorcode =="wrong_hp")then
					s = "血量不够！"
				elseif(errorcode =="wrong_cure")then
					s = "治疗加成不够！"
				elseif(errorcode =="wrong_guard")then
					s = "防御力不够！"
				elseif(errorcode =="wrong_family_id")then
					s = "你和队长不是同一家族,不能以3人队伍模式参加3v3比赛！"
				elseif(errorcode =="wrong_team_school")then
					s = "3v3比赛3个队伍成员不能是同一系别！"
				elseif(errorcode =="wrong_gear_score")then
					s = "你和队长的战斗力差距超过400，不可以组队参加3v3比赛！"
				elseif(errorcode =="wrong_team_school_2v2")then
					s = "你和队长是同一系别，不可以组队参加2v2比赛！"
				elseif(errorcode =="wrong_family_id_2v2")then
					s = "你和队长不是同一家族,不能组队参加2v2比赛！"
				elseif(errorcode =="wrong_gear_score_2v2")then
					s = "2v2比赛分【1000-1999】战斗力和【大于2000】战斗力段，你和队长不在同一战斗力段，不能一起比赛！"
				else
					s = errorcode;
				end
				if(error_callback)then
					error_callback({
						errorcode = s,
					});
				end
				return
			end
			if(success_callback)then
				success_callback({
					msg = result.msg.msg,
				});
			end
		else
			if(error_callback)then
				error_callback({
					errorcode = "加入失败!",
				});
			end
		end
	end);
end

function LobbyClientServicePage.DoJoinGame_Internal(game_id,password, game_info)
	local self = LobbyClientServicePage;
	game_id = tonumber(game_id);
	if(not game_id)then
		return
	end
	local keyname = game_info.keyname;

	self.Plain_JoinGame(game_id,password,game_info, function(msg)
		if(msg)then
			self.ClosePage();
			LobbyChatPage.Clear();
			self.SetRoomID(game_id);

			local world = WorldManager:GetWorldInfo(game_info.keyname);
			if(world and world.force_teamworld) then
				local cur_world = WorldManager:GetCurrentWorld();
				if(cur_world.name ~= game_info.keyname) then
					_guihelper.MessageBox("已经成功进入房间, 请等待队长同意. 你也可以试试起它房间!");
				end
			else
				RoomDetailPage.ShowPage(game_id);
			end
			
			EXPBuffArea.Update_LobbyBtn();
		end
	end,function(msg)
		if(msg and msg.errorcode)then
			_guihelper.MessageBox(msg.errorcode);
		end
	end);
end

-- @param game_id: game_id or game_info table. 
function LobbyClientServicePage.DoJoinGame(game_id,password)
	local self = LobbyClientServicePage;
	local game_info;
	if(type(game_id) == "table") then
		game_info = game_id
		game_id = game_info.game_id;
	else
		game_id = tonumber(game_id);
	end
	if(not game_id)then
		return
	end
	if(self.login_room_id and self.login_room_id == game_id)then
		return false
	end

	local cur_world = WorldManager:GetCurrentWorld();
	if(cur_world.force_teamworld) then
		_guihelper.MessageBox("请先离开你所在的世界, 才能加入这个队伍");
		return false;
	end

	game_info = game_info or self.GetGameInfoByID(game_id);
	if(game_info)then
		local can_pass = self.CheckRoomState(game_info.game_type,game_info.worldname);
		if(not can_pass)then
			return false;
		end
		if(TeamClientLogics:IsInTeam()) then
			if(game_info.owner_nid ~= tostring(TeamClientLogics:GetTeamLeaderNid() or nil)) then
				_guihelper.MessageBox("请先退出你当前的队伍，才能加入其他人的房间。");
				return false;
			end
		end
		self.DoJoinGame_Internal(game_id,password, game_info);
	end
end

--  this function is similar to DoLeaveGame. except that it will also quit the team if the room owner is also the team leader(and the team leader is not me.)
-- @param game_id: game id
function LobbyClientServicePage.LeaveGameAndTeam(game_id, bBackToMainPage)
	local self = LobbyClientServicePage;
	if(not game_id)then return end

	local game_info = LobbyClient:GetGameInfoInMemory(game_id);
	if (game_info and game_info.owner_nid) then
		if(TeamClientLogics:IsInTeam() and not TeamClientLogics:IsTeamLeader()) then
			if(game_info.owner_nid == tostring(TeamClientLogics:GetTeamLeaderNid())) then
				TeamClientLogics:LeaveTeam();
			end
		end
	end
	LobbyClientServicePage.DoLeaveGame(game_id, bBackToMainPage);
end


--离开房间
-- @param bBackToMainPage: default to true. if true, it will go back to the main lobby page when leaving the room
function LobbyClientServicePage.DoLeaveGame(game_id, bBackToMainPage)
	local self = LobbyClientServicePage;
	if(not game_id)then return end 

	LobbyClient:LeaveGame(game_id);
	--主动离开房间没有 callback,所以直接执行以下函数
	self.SetRoomID(nil);
	self.selected_game_id = nil;
	if(bBackToMainPage) then
		self.ShowPage();
	end
	RoomDetailPage.ClosePage();
	EXPBuffArea.Update_LobbyBtn();
end


function LobbyClientServicePage.DoLoginGameFromGameInfo(game_info)
	local self = LobbyClientServicePage;
	if(game_info and game_info.players) then
		local nid = tostring(System.User.nid);
		local match_info = game_info.match_info;
		local has_player = game_info.players[nid];
		local mode = game_info.mode;-- = get_mode(game_info.mode);
					
		-- for kids version default to the most difficult one. 
		--if(System.options.version == "kids") then
		--	mode = 3;
		--end
					
		LOG.std(nil, "debug", "LobbyClientServicePage.DoLoginGame", game_info);

		if(game_info.wait_ack_start_time and game_info.wait_ack_start_time > 120000)then
			_guihelper.MessageBox("刚刚的队伍已经完全关闭，请重新加入其他队伍吧！");
			return
		end
		if(has_player)then
			local keyname = game_info.keyname;
			local worldname = game_info.worldname;
			local room_key = game_info.grid_node_key;
			if(not worldname or not room_key)then 
				LOG.std(nil, "info", "LobbyClientServicePage.DoLoginGame worldname or room_key is nil", {worldname = worldname, room_key = room_key});
				return 
			end
						
			--处理队伍关系
			local owner_nid = game_info.owner_nid;
			--如果自己不是房间主人
			if(nid ~= owner_nid)then
				--如果自己在一个队伍中
				if(TeamClientLogics:IsInTeam())then
					local leader_nid = TeamClientLogics:GetTeamLeaderNid();
					leader_nid = tostring(leader_nid);
								
					--队长不是房间的主人
					if(leader_nid ~= owner_nid)then
						TeamClientLogics:LeaveTeam();
						TeamClientLogics:JoinTeamMember(owner_nid);
					end
				else
					TeamClientLogics:JoinTeamMember(owner_nid);
				end
			else
				--如果自己是房间主人，并且在一个队伍中
				if(TeamClientLogics:IsInTeam())then
					--如果自己是队长
					if(TeamClientLogics:IsTeamLeader())then
						--把不是同一个房间的人踢出队伍
						local team = TeamWorldInstancePortal.GetTeamTable();
						if(team)then
							local k,v;
							for k,v in ipairs(team) do
								local nid = tostring(v.nid);
								if(not game_info.players[nid])then
									TeamClientLogics:DelTeamMember(tonumber(nid));
								end
							end
						end
					else
						--离开队伍
						TeamClientLogics:LeaveTeam();
					end
				else
					--等待其他队员的申请
				end							
			end
			---------------------------------------------------------------------
			--记录次数
			if(worldname == "HaqiTown_RedMushroomArena_1v1" 
				or worldname == "HaqiTown_RedMushroomArena_2v2" 
				or worldname == "HaqiTown_RedMushroomArena_3v3" 
				or worldname == "HaqiTown_RedMushroomArena_4v4") then
				ItemManager.PurchaseItem(40005, 1, function(msg) end, function(msg) end, nil, "none");
			end
						
			-- AI bot logics goes here. 
			if(worldname and worldname:match("^HaqiTown_RedMushroomArena_")) then
				if(room_key == "local") then
					-- this is local game server AI bot, such as 1v1
					room_key = nil;
					worldname = worldname:gsub("^HaqiTown_RedMushroomArena_", "HaqiTown_RedMushroomArena_AI_");
				elseif(room_key and room_key:match("^a:")) then
					-- this is home server AI bot, such as 2v2, 4v4
					worldname = worldname:gsub("^HaqiTown_RedMushroomArena_", "HaqiTown_RedMushroomArena_AI_");
				end
			end

			---------------------------------------------------------------------
			--进入副本
			local force_nid
			if(room_key) then
				force_nid = string.gsub(room_key,"[^%d]", "");
				if(force_nid) then
					if(#force_nid>10) then
						force_nid = force_nid:sub(#force_nid-10);
					end
					force_nid = tonumber(force_nid)%10000;
				end
			end
						
			-- disable follow AI. 
			NPL.load("(gl)script/apps/Aries/Scene/AutoFollowAI.lua");
			local AutoFollowAI = commonlib.gettable("MyCompany.Aries.AI.AutoFollowAI");
			AutoFollowAI:Follow("follow", nil);
			NPL.load("(gl)script/apps/Aries/Scene/AutoCameraController.lua");
			local AutoCameraController = commonlib.gettable("MyCompany.Aries.AutoCameraController");
			AutoCameraController:SaveCamera();


			LOG.std(nil, "debug", "LobbyClientServicePage.EnterWorld", {worldname, keyname, force_nid, mode});

			System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {
				name = worldname,
				keyname = keyname,
				room_key = room_key,
				force_nid = force_nid,
				match_info = match_info,
				--create_join = true,
				mode = mode,
				on_finish = function()
					TeamMembersPage.ShowPage(true);
					MapArea.Refresh();
					MsgHandler.OnCheckHPTip();
					local world = WorldManager:GetWorldInfo(worldname);
					if(world and world.motion_file)then
						CombatSceneMotionHelper.PlayCombatMotion_LoginWorld(world.motion_file);
					end
					--记录当前副本的难度
					self.mode_cur_worldinstance = mode;
				end,
			});
		else
			_guihelper.MessageBox("刚刚的队伍已经完全关闭，请重新加入其他队伍吧！");
		end
	else
		_guihelper.MessageBox("刚刚的队伍已经完全关闭，请重新加入其他队伍吧！");
	end
end

	--local function get_mode(mode)
		--mode = mode or 1;
		--local s;
		--if(mode == 1)then
			--s = "easy";
		--elseif(mode == 2)then
			--s = "normal";
		--elseif(mode == 3)then
			--s = "hard";
		--end
		--return s;
	--end

function LobbyClientServicePage.DoLoginGame(game_id)
	LobbyClient:GetGameDetail(game_id, true, function(result)
			if(not result.is_fetching) then
				local game_info = result.formated_data;
				LobbyClientServicePage.DoLoginGameFromGameInfo(game_info);
			end
		end,true)
end
function LobbyClientServicePage.DoKickGame(game_id,kick_nid)
	local self = LobbyClientServicePage;
	if(not game_id or not kick_nid)then return end
	local game_settings = {
		game_id = game_id,
		kick_nid = tostring(kick_nid),
	}
	LobbyClient:KickGame(game_settings);
end

-- this function can only be called by team leader and when it is inside a room. 
-- @param game_info: if nil, the current game_info is used. 
function LobbyClientServicePage.SendCreateGameMsgToTeamMembers(game_info)
	if(not game_info) then
		game_info = LobbyClientServicePage.game_info;
	end
	if(game_info) then
		local id = game_info.id;
		local name = game_info.name;
		local worldname = game_info.worldname;
		local keyname = game_info.keyname;
		TeamClientLogics:SendTeamChatMessage({type="create_game", id = id, name = name, worldname = worldname, keyname = keyname, password=game_info.password}, true)
	end
end

--[[
	处理所有接收到的消息
--]]
function LobbyClientServicePage.OnHandleAllMsg(self,msg)
	local self = LobbyClientServicePage;


	--commonlib.echo("==========LobbyClientServicePage.OnHandleAllMsg");
	--commonlib.echo(msg);
	--commonlib.echo(msg.msg);

	
	if(msg and msg.msg and msg.msg[1])then
		local function get_players(data)
			if(not data)then
				return
			end
			local list = {};
			local nid;
			for nid,__ in pairs(data) do
				table.insert(list,nid);
			end
			return list;
		end
		local result = msg.msg[1];
		local user_nid = result.msg.user_nid;
		local game_info = result.msg.msg;
		self.room_state = nil;
		if(game_info)then
			if(result.type == "create_game" or result.type == "join_game" or result.type == "leave_game")then
				RoomDetailPage.RefreshPage();
				EXPBuffArea.Update_LobbyBtn();
				--如果是队长创建的房间，发送消息给队员
				if(result.type == "create_game" and TeamWorldInstancePortal.IsInTeam() and TeamWorldInstancePortal.IsTeamLeader())then
					LobbyClientServicePage.SendCreateGameMsgToTeamMembers(game_info);
				end
				WorldTeamQuest.ReSelected();
			elseif(result.type == "reset_game")then
				RoomDetailPage.RefreshPage();
			elseif(result.type == "reset_game_mode")then
				RoomDetailPage.RefreshPage();
				local owner_nid = game_info.owner_nid;
				owner_nid = tonumber(owner_nid)
				if(owner_nid and owner_nid ~= Map3DSystem.User.nid)then
					local mode = game_info.mode or 1;
					local modelist = LobbyClientServicePage.LoadModeList(game_info.keyname);
					local node = LobbyClient:GetModeNode(modelist,mode) or {}
					local s = string.format("队长已经将副本难度更改为【%s】难度。",node.lable_1 or "");
					MyCompany.Aries.Desktop.NotificationArea.AppendFeed("story", {
					ShowCallbackFunc = function(msg) 
						_guihelper.MessageBox(s);	
					end,
				});
				end
				
			elseif(result.type == "start_game")then
				-- use a random timeout to prevent the user from knowing which side of the team. 
				commonlib.TimerManager.SetTimeout(function()  
					self.Handle_StartGame(result)
					local players = get_players(game_info.players);
					TeamClientLogics:Set_pending_invite_lobbyservice(players,true);
					EXPBuffArea.Update_LobbyBtn();
				end, math.random(0, 2000));

			elseif(result.type == "game_clear")then
				if(game_info.id and self.login_room_id and game_info.id == self.login_room_id)then
					--记录副本进入的次数
					self.AddTodayCnt_WorldInstance(game_info.worldname);
					self.SetRoomID(nil);
					RoomDetailPage.ClosePage();

					local players = get_players(game_info.players);
					TeamClientLogics:Set_pending_invite_lobbyservice(players,nil);
					EXPBuffArea.Update_LobbyBtn();
					LobbyClientServicePage.PoP_PanelForMaster(true);
				end
			elseif(result.type == "kick_game")then
				if(game_info.id and self.login_room_id and game_info.id == self.login_room_id)then
					self.SetRoomID(nil);
					RoomDetailPage.RefreshPage();
					_guihelper.MessageBox("你已经被移出队伍！");
					EXPBuffArea.Update_LobbyBtn();
				end
			elseif(result.type == "update_game")then
				if(game_info.id and self.login_room_id and game_info.id == self.login_room_id)then
					RoomDetailPage.RefreshPage();
					EXPBuffArea.Update_LobbyBtn();
				end
			elseif(result.type == "match_making")then
				EXPBuffArea.Update_LobbyBtn();
			elseif(result.type == "chat_update")then
				local sender_nid = game_info.sender_nid;
				local chat_data = game_info.chat_data;

				ChatMessage.DecompressMsg(chat_data);
				local nid = tostring(System.User.nid);

				if(chat_data and user_nid and sender_nid ~= nid)then
					ChatChannel.AppendChat(chat_data);
				end
			elseif(result.type == "goto_address")then
				local caller = game_info.caller;
				local address = game_info.address;
				if(caller and address)then
					local s = string.format("队长召唤你到他身边，确认要立即过去吗？");

					if (not MyCompany.Aries.ExternalUserModule:CanViewUser(caller)) then
						if(WorldManager:IsPublicWorld(address.name)) then
							_guihelper.MessageBox("队长召唤你到他身边， 但是你与队长不是同区, 无法过去");
							return;
						end
					end
					_guihelper.Custom_MessageBox(s,function(result)
						if(result == _guihelper.DialogResult.Yes)then
							local can_pass = LobbyClientServicePage.CanPassToday_WorldInstance(address.name,true);
							if(can_pass)then
								WorldManager:TeleportByWorldAddress(address);
							end
						end
					end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/Coming_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
				end
			end
		end
	end
end

function LobbyClientServicePage.ShowPage_ResetMode(gameid,mode,game_type,keyname)
	local self = LobbyClientServicePage;
	--显示副本难度面板
	CreateRoomPage.ShowPage_ResetMode(gameid,mode,game_type,keyname);
	local wait_sec = 0;
	if(not self.reset_mode_timer)then
		self.reset_mode_timer = commonlib.Timer:new()
	end
	self.reset_mode_timer.callbackFunc = function(timer)
		wait_sec = wait_sec + 1;
		if(wait_sec > 10)then
			self.reset_mode_timer:Change();
			CreateRoomPage.Close_ResetModePage();
			--等待10秒自动开启
			self.DoStartGame(gameid,game_type);
		else
			CreateRoomPage.Refresh_ResetModePage(10 - wait_sec);
		end	
	end
	self.reset_mode_timer:Change(0, 1000);
end
--更改副本难度
function LobbyClientServicePage.DoResetMode_InAutoStart(gameid,mode,game_type)
	local self = LobbyClientServicePage;
	local game_settings = {
        id = gameid,
        mode = mode,
    }
	if(self.reset_mode_timer)then
		self.reset_mode_timer:Change();
	end
	LobbyClient:ResetGameMode(game_settings,function(result)
		self.DoStartGame(gameid,game_type);
	end)
end
function LobbyClientServicePage.Handle_StartGame(result)
	local self = LobbyClientServicePage;
	LOG.std(nil,"info","LobbyClientServicePage.Handle_StartGame",result);
	local game_info = result.msg.msg;
	if(game_info)then
		local nid = tostring(System.User.nid);
		local owner_nid = game_info.owner_nid;
		local game_type = game_info.game_type;
		if(nid == owner_nid)then
			LobbyClientServicePage.StartTimer_PvPToolTip(game_info,function()
				--self.DoLoginGame(game_info.id);
				LobbyClientServicePage.DoLoginGameFromGameInfo(game_info);
			end)
		else
			self.ClosePage();
			RoomDetailPage.ClosePage();

			NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
			local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
			local worldname = game_info.worldname;

			local world_info = WorldManager:GetWorldInfo(worldname);
			local name="";
			if(world_info)then
				name = world_info.world_title;
			end
			--pvp强制自动开启
			if(self.IsAutoStart() or game_type == "PvP")then
				LobbyClientServicePage.StartTimer_PvPToolTip(game_info,function()
					--self.DoLoginGame(game_info.id);
					LobbyClientServicePage.DoLoginGameFromGameInfo(game_info);
				end)
				return
			end
			
			local s = string.format("小队成员已经到达%s副本，快过来帮忙吧！",name);
			_guihelper.Custom_MessageBox(s,function(result)
				if(result == _guihelper.DialogResult.OK)then
					LobbyClientServicePage.StartTimer_PvPToolTip(game_info,function()
						-- self.DoLoginGame(game_info.id);
						LobbyClientServicePage.DoLoginGameFromGameInfo(game_info);
					end)
				end
			end,_guihelper.MessageBoxButtons.OK);
		end
	end
end

function LobbyClientServicePage.SentChatMessage(msgdata)
	local self = LobbyClientServicePage;
	local login_room_id = self.GetRoomID();
	if(not login_room_id or not msgdata)then return end
	local chat_data= ChatMessage.CompressMsg(msgdata)
	local chat_msg = {
		game_id = login_room_id,
		chat_data = chat_data,
	}
	LobbyClient:SentChatMessage(chat_msg);
end

--[[ sending a message to all users on the server. 
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
LobbyClientServicePage.SendServerChatMessage("hello world all users");
]]
function LobbyClientServicePage.SendServerChatMessage(text)
	local chat_data= ChatMessage.CompressMsg({ChannelIndex=10, words=text})
	local chat_msg = {
		chat_data = chat_data,
	}
	LobbyClient:SendServerChatMessage(chat_msg);
end


function LobbyClientServicePage.GetGameTemplates()
	local self = LobbyClientServicePage;
	local game_templates = LobbyClient:GetGameTemplates();
	return game_templates; 
end
--在满员的时刻，弹出面板提醒主人
--如果主人是在战斗状态，等待战斗结束再弹出
function LobbyClientServicePage.PoP_PanelForMaster(bClose)
	local self = LobbyClientServicePage;
	if(not self.pop_panel_timer)then
		self.pop_panel_timer = commonlib.Timer:new()
	end
	self.pop_panel_timer:Change();
	if(bClose)then
		return
	end
	self.pop_panel_timer.callbackFunc = function(timer)
		local is_combat = Player.IsInCombat();
		if(not is_combat)then
			local login_room_id = self.GetRoomID();
			if(login_room_id)then
				--RoomDetailPage.ShowPage(login_room_id);
				local game_templates = LobbyClient:GetGameTemplates();
				LobbyClient:GetGameDetail(login_room_id, true, function(result)
					local player_count = 0;
					local max_players = 0;
					local game_type;
					local status;
					if(result and result.formated_data) then
						local game_info = result.formated_data;
						if(game_info and game_info.players)then
							local nid = tostring(System.User.nid);
							local has_player = game_info.players[nid];
							local game_type = game_info.game_type;
							local keyname = game_info.keyname;
							max_players = game_info.max_players or 4;
							player_count = game_info.player_count or 0;
							local template = game_templates[keyname];
							if(not template)then return end 
							local door_closed = template["door_closed"];
							if(has_player)then
								if(self.IsAutoStart())then
									if(game_type == "PvE")then
										if(door_closed and door_closed == "true")then
											--_guihelper.MessageBox("你的队伍已达到推荐人数，可以召唤全队立即过去啦。");
											return
										end
										RoomDetailPage.ClosePage();
										--再次提醒副本难度选择
										if(CommonClientService.IsKidsVersion())then
											LobbyClientServicePage.ShowPage_ResetMode(game_info.id,game_info.mode,game_type,keyname);
										else
											self.DoStartGame(game_info.id,game_type);
										end
									else
										self.DoStartGame(game_info.id,game_type);
									end
									return
								end
								--local s;
								--if(game_type == "PvE")then
									--if(door_closed and door_closed == "true")then
										--_guihelper.MessageBox("你的队伍已达到推荐人数，可以召唤全队立即过去啦。");
										--return
									--end
									--s = "已达到推荐人数，是否立刻进入副本？";
								--else
									--s = "你的队伍人数已满，是否立即进入排队？";
								--end
								--_guihelper.Custom_MessageBox(s,function(result)
									--if(result == _guihelper.DialogResult.Yes)then
										--if(player_count >= max_players)then
											--RoomDetailPage.ClosePage();
											--self.DoStartGame(game_info.id,game_type);
										--else
											--RoomDetailPage.ShowPage(login_room_id);
										--end
									--else
										--RoomDetailPage.ShowPage(login_room_id);
									--end
								--end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Cancel_32bits.png; 0 0 153 49"});
							end
						end
					end
				end);
			end
			self.pop_panel_timer:Change();
		end
	end
	self.pop_panel_timer:Change(0,5000);
end
--准备进入副本或者pvp 有个倒计时的等待
function LobbyClientServicePage.StartTimer_PvPToolTip(game_info,callbackFunc)
	local self = LobbyClientServicePage;
	if(not game_info)then
		if(callbackFunc)then
			callbackFunc();
		end
		return
	end
	local game_type = game_info.game_type;
	--pvp取消倒计时
	if(game_type == "PvP")then
		if(callbackFunc)then
			callbackFunc();
		end
		return
	end
	local tempaltes = LobbyClientServicePage.GetGameTemplates();
	local keyname = game_info.keyname;
	local template = tempaltes[keyname] or {};
	local name = template.name or "副本";

	local title = string.format("[%s]启动中,马上进入...",name);
	NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
	local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
	GathererBarPage.Start({ duration = 10000, title = title, disable_shortkey = true,},nil,function()
		if(callbackFunc)then
			callbackFunc();
		end
	end);
end

-- room state msg
local room_state_msg_template = {status = nil}

--[[
	status = "match_making"
	LobbyClientServicePage.LoadRoomState(function(msg)
		if(msg and msg.status == "match_making")then
			_guihelper.MessageBox("排队当中，不能加入战斗！");
		else

		end
	end)
--]]
function LobbyClientServicePage.LoadRoomState(callbackFunc, auto_refresh)
	if(auto_refresh == nil) then
		auto_refresh = true;
	end
	local self = LobbyClientServicePage;
	local login_room_id = self.GetRoomID();
	if(not login_room_id)then
		if(callbackFunc)then
			room_state_msg_template.status = nil;
			callbackFunc(room_state_msg_template);
		end
		return
	end
	if(login_room_id)then
		LobbyClient:GetGameDetail(login_room_id, auto_refresh, function(result)
				local player_count = 0;
				local max_players = 0;
				local game_type;
				local status;
				if(result and result.formated_data) then
					local game_info = result.formated_data;
					status = game_info.status or "waiting";
				end
				if(callbackFunc)then
					callbackFunc({status = status});
				end
		end,nil);
	end
end
--记录用户当前登录的房间
function LobbyClientServicePage.SetRoomID(id)
	local self = LobbyClientServicePage;
	self.login_room_id = id;
end
function LobbyClientServicePage.GetRoomID()
	local self = LobbyClientServicePage;
	return self.login_room_id;
end
function LobbyClientServicePage.GetLoginRoomOwnerNID()
	local self = LobbyClientServicePage;
	if(self.login_room_id)then
		local game_info = self.GetGameInfoByID(self.login_room_id);
		if(game_info)then
			local owner_nid = game_info.owner_nid;
			return owner_nid;
		end
	end
end

function LobbyClientServicePage.GetNextPassword()
	if(not LobbyClientServicePage.last_password) then
		LobbyClientServicePage.last_password = math.floor(math.random(0,1000));
	else
		LobbyClientServicePage.last_password = LobbyClientServicePage.last_password + 1;
	end
	return LobbyClientServicePage.last_password;
end

-- query lobby room. 
function LobbyClientServicePage.QueryLobbyRoom()
	local room_id = LobbyClientServicePage.GetRoomID();
	if(not room_id) then
		if(TeamClientLogics:IsInTeam() and not TeamClientLogics:IsTeamLeader()) then
			TeamClientLogics:SendTeamChatMessage({type="query_lobby_room"})
		end
	end
end

--快速加入房间
-- @param worldname:副本名称，可以为空，如果为空，默认匹配一个适合自己等级的副本
-- @param game_type:副本类型 "PvE" or "PvP"
-- @param bTeamMode: if true, we do not create the game immediately, instead we send a message to team member for confirmation. 
function LobbyClientServicePage.DoAutoJoinRoom(worldname, game_type, bTeamMode)
	local self = LobbyClientServicePage;
	local combatlevel;
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		combatlevel = bean.combatlel;
	end

	game_type = game_type or "PvE"
	if(not worldname)then

		local games,closest_game_tmpl;
		if(game_type == "PvE")then
			games, closest_game_tmpl = LobbyClient:GetGamesByWorldName(worldname, game_type, combatlevel,true)
		else
			--pvp等级严格判断
			games, closest_game_tmpl = LobbyClient:GetGamesByWorldName(worldname, game_type, combatlevel);
		end
		if(games)then
			local len = #games;
			local i = math.random(len);
			local game = games[i];
			if(game)then
				worldname = game.worldname;
			end
		end
	end

	local games, closest_game_tmpl = LobbyClient:GetGamesByWorldName(worldname, game_type, combatlevel,true)		
	if(not worldname or not games or #games == 0) then
		if(game_type == "PvP") then
			if(closest_game_tmpl and (closest_game_tmpl.min_level or 0)>(combatlevel or 0) ) then
				_guihelper.MessageBox(format("你需要到达%d级，才能进入%s", closest_game_tmpl.min_level or 0, closest_game_tmpl.name));
			else
				_guihelper.MessageBox("你当前的等级不能参加PK赛");
			end
		else
			if(closest_game_tmpl and (closest_game_tmpl.min_level or 0)>(combatlevel or 0) ) then
				_guihelper.MessageBox(format("你需要到达%d级，才能进入%s", closest_game_tmpl.min_level or 0, closest_game_tmpl.name));
			else
				_guihelper.MessageBox("没有找到合适的队伍, 或等级不够不能进入.");
			end
		end
		return;
	end

	local canpass = self.CheckTicket_CanPass(worldname)
	if(not canpass)then
		return;
	end

	local password;
	if(bTeamMode and game_type == "PvP") then
		if(TeamClientLogics:IsInTeam()) then
			if(TeamClientLogics:IsTeamLeader()) then
				password = LobbyClientServicePage.GetNextPassword();
			else
				-- ask team leader
				BroadcastHelper.PushLabel({id="lobbyquery", label = "你在队伍中,请等待队长的邀请", max_duration=5000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
				LobbyClientServicePage.QueryLobbyRoom()
				return;
			end
		end
	end

	--if(bTeamMode) then
		--if(TeamClientLogics:IsInTeam()) then
			--if(not TeamClientLogics:IsTeamLeader()) then
				---- only join where the team leader is in, otherwise display a message.  
				--self.AutoFindRoom(worldname, game_type, function(user_level, games)
					--_guihelper.MessageBox("你的队长没有在房间中，请先离开当前的队伍，或等待你们的队长开启房间。");
				--end);
			--else
				---- sending a request to all team members to join the game. 
				----LobbyClientServicePage.last_create_game_request_seq = (LobbyClientServicePage.last_create_game_request_seq or 0)+1;
				----LobbyClientServicePage.last_create_game_request = {type="create_game_request", keyname = worldname, password="1", seq=LobbyClientServicePage.last_create_game_request_seq};
				----TeamClientLogics:SendTeamChatMessage({type="create_game_request", keyname = worldname, password="1", seq=LobbyClientServicePage.last_create_game_request_seq, game_type=game_type}, true)
--
				---- the team leader should create a non-auto start game with a random password. 
				--
				--local password = LobbyClientServicePage.GetNextPassword();
				--LobbyClientServicePage.AutoFindRoom(worldname, game_type, function(user_level, games)
					--_guihelper.MessageBox("没有找到合适的房间");
				--end, false, true, password);
			--end
		--else
			---- if it is not in a team. 
			--LobbyClientServicePage.AutoFindRoom(worldname, game_type, function(user_level, games)
					--_guihelper.MessageBox("没有找到合适的房间");
				--end);
		--end
	--else
		self.AutoFindRoom(worldname, game_type, function(user_level, games)
			
			--if(game_type == "PvP") then
				--_guihelper.MessageBox("你当前的等级不能参加PK赛");
			--else
				--_guihelper.MessageBox("没有找到合适的队伍, 或等级不够不能进入.");
			--end
		end, nil, if_else(password,true,nil), password);
	-- end
end
--自动找到相匹配的房间，如果没有找到触发callback_func
-- @param worldname: worldname as defined in aries game world config file. 
-- @param game_type: "PvP" or "PvE", which game type to search. If nil, it means any type.
-- @param user_level: nil or number in range [1,50] according to game settings. 
-- @param callback_func: function(my_combatlevel, games)  end, this function is only called when there is no room to join or create. 
-- @param is_auto_start:在创建完房间后，是否自动开启副本，默认false,加入其他人创建的房间，此属性无效
-- @param is_force_create: true to force creating a game instead of joining one. 
--  where my_combatlevel is the combat level, and games is nil or an array of game_templates. 
-- @param password: 
function LobbyClientServicePage.AutoFindRoom(worldname, game_type, callback_func,is_auto_start, is_force_create, password, mode_difficulty)
	local self = LobbyClientServicePage;
	local combatlevel;
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		combatlevel = bean.combatlel;
	end
	local can_pass = LobbyClientServicePage.CheckRoomState(game_type,worldname)
	if(not can_pass)then
		return;
	end
	
	LobbyClientServicePage.RefreshRooms(function()
		local login_room_id = self.GetRoomID();
		local game_info = self.GetGameInfoByID(login_room_id);
		if(game_info and game_info.worldname == worldname and game_info.game_type == game_type and 
			(mode_difficulty and game_info.mode == mode_difficulty) )then
			RoomDetailPage.ShowPage();
			return
		end	
		LobbyClient:AutoFindRoom(worldname, game_type, combatlevel, function(candidate_rooms, games)
			if(not candidate_rooms) then
				-- use normal way to load the world
				LOG.std(nil, "system", "lobbyclient", "auto find room does not find any game with the world name:%s, we will just load the world using default config file", worldname);

				if(callback_func)then
					local games = LobbyClient:GetGamesByWorldName(worldname, game_type);
					callback_func(combatlevel, games);
				end
			elseif(#candidate_rooms == 0 or is_force_create) then
				if(games and games[1])then
					local keyname = games[1].keyname;
					-- create a new room with keyname
					LOG.std(nil, "system", "lobbyclient", "no empty rooms found for worldname %s, we will create one by ourself", worldname);
					self.CreateRoomKeyName(keyname, game_type, nil, is_auto_start, password);
				end
			else
				--[[
					自动匹配房间逻辑:
					确定尝试次数
						local max_try_num = 3;
						local len = #candidate_rooms;
						max_try_num = math.min(max_try_num,len);
					尝试房间查找,如果全部失败,自动创建一个房间
				--]]
				if(candidate_rooms) then
					local try_num = 0;
					local max_try_num = 3;
					local len = #candidate_rooms;
					max_try_num = math.min(max_try_num,len);
					local nStartIndex = math.random(1,len);

					local function create_room()
						--echo("1111111111111111111");
						if(games and games[1])then
							local keyname = games[1].keyname;
							-- create a new room with keyname
							LOG.std(nil, "system", "lobbyclient", "no empty rooms found for worldname %s, we will create one by ourself", worldname);
							self.CreateRoomKeyName(keyname, game_type, nil, is_auto_start, password);
						end
					end
					local function try_login(success_callback,error_callback)
						local room_index = ((nStartIndex+try_num) % len) +1
						local room = candidate_rooms[room_index];
						
						if(room and room.game_id) then
							local game_id = room.game_id;
							LOG.std(nil, "system", "lobbyclient", "try to login room for worldname %s(%d): the %d times. owner_nid:%s", tostring(room.worldname), game_id, try_num or 1, tostring(room.owner_nid));
							
							self.Plain_JoinGame(game_id,nil, room, function(msg)
								success_callback(game_id);
							end,function(msg)
								error_callback();
							end);
						else
							error_callback();
						end
					end
					--查找房间成功
					local function success_callback(game_id)
						if(not game_id)then return end
						LOG.std(nil, "system", "lobbyclient", "find a room (game_id:%d)to join ", game_id);
						self.ClosePage();
						LobbyChatPage.Clear();
						self.SetRoomID(game_id);
						RoomDetailPage.ShowPage(game_id);
						EXPBuffArea.Update_LobbyBtn();
					end
					--尝试失败 继续查找
					local function error_callback()
						try_num = try_num + 1;
						if(try_num >= max_try_num)then
							create_room();
							return
						end
						try_login(success_callback,error_callback);
					end

					if(TeamClientLogics:IsInTeam() and  not TeamClientLogics:IsTeamLeader()) then
						-- team member can only login to room where their team leader is in. 
						local leader_nid = tostring(TeamClientLogics:GetTeamLeaderNid() or nil);
						local i, room
						for i = 1, len do
							if(candidate_rooms[i].owner_nid == leader_nid) then
								nStartIndex = i;
								LOG.std(nil, "info", "lobbyclient", "We found the team leader's room. t try to join the game where the team leader is in.")
								try_login(success_callback, function()
									if(callback_func) then
										callback_func();
									end
								end)
								return;
							end
						end
						return;
					end

					try_login(success_callback,error_callback)
				end
			end
		end)
	end);

end

function LobbyClientServicePage.CreateRoomKeyName(keyname, game_type, is_start_now, is_auto_start, password, mode)
	local self = LobbyClientServicePage;
	if(not keyname)then return end
	game_type = game_type or "PvE";
	local game_templates = LobbyClient:GetGameTemplates();
	if(keyname and game_templates)then
		local template = game_templates[keyname];
		if(template)then
			local name;
			if(game_type == "PvE")then
				name = "一起打副本啦！";
			else
				name = "一起去PK吧！";
			end
			mode = mode or 1;
			local mode_list = self.LoadModeList(keyname) or {};
			local len = #mode_list;

			local min_mode = 1; 
			local max_mode = 3;
			if(mode_list[1])then
				min_mode = mode_list[1].mode;
			end
			if(mode_list[len])then
				max_mode = mode_list[len].mode;
			end
			mode = math.min(mode,max_mode);
			mode = math.max(mode,min_mode);
			local game = {
				mode = mode,
				game_type = game_type,
				keyname = keyname,
				name = name,
				leader_text = "",
				min_level = template.min_level,
				max_level = template.max_level,
				password = password,
				requirement_tag = "storm|fire|life|death|ice",
				is_persistent = nil,
			}
			LobbyClientServicePage.DoCreateGame(game,is_start_now, is_auto_start);		
		end
	end
end
--------------------------------------------------------------------------------
--check state
--------------------------------------------------------------------------------
function LobbyClientServicePage.IsOpen_PvP_kids(worldname)
	local self = LobbyClientServicePage;
	if(worldname and worldname:match("^HaqiTown_LafeierCastle_PVP")) then
		return self.IsOpen_PvP3v3_kids();
	end
	NPL.load("(gl)script/apps/Aries/Scene/main.lua");
	local Scene = commonlib.gettable("MyCompany.Aries.Scene");
	local sec = Scene.GetElapsedSecondsSince0000();
	--if(System.options.isAB_SDK)then
		--return true;
	--end
	local week = Scene.GetDayOfWeek();
	if(worldname and worldname:match("^HaqiTown_RedMushroomArena_2v2")) then
		if(week < 5)then
			return false;
		end		
	end

	local a_clock,b_clock;
	if(worldname and worldname:match("^HaqiTown_RedMushroomArena_1v1")) then
		a_clock = 16;
		b_clock = 22;
	elseif(worldname and worldname:match("^HaqiTown_RedMushroomArena_2v2")) then
		a_clock = 14;
		b_clock = 22;
	end

	local a_start = commonlib.timehelp.GetSeconds(a_clock,0,0);
	local a_end = commonlib.timehelp.GetSeconds(b_clock,0,0);
	--local b_start = commonlib.timehelp.GetSeconds(18,0,0);
	--local b_end = commonlib.timehelp.GetSeconds(22,0,0);

	--if((sec >= a_start and sec <= a_end) or (sec >= b_start and sec <= b_end))then
	if(sec >= a_start and sec <= a_end)then
		return true;
	end
end

function LobbyClientServicePage.IsOpen_PvP3v3_kids()
	local self = LobbyClientServicePage;
	NPL.load("(gl)script/apps/Aries/Scene/main.lua");
	local Scene = commonlib.gettable("MyCompany.Aries.Scene");
	local sec = Scene.GetElapsedSecondsSince0000();
	--if(System.options.isAB_SDK)then
		--return true;
	--end
	local week = Scene.GetDayOfWeek();
	if(week > 4)then
		return false;
	end
	local a_start = commonlib.timehelp.GetSeconds(16,0,0);
	local a_end = commonlib.timehelp.GetSeconds(22,0,0);

	--local b_start = commonlib.timehelp.GetSeconds(17,0,0);
	--local b_end = commonlib.timehelp.GetSeconds(22,0,0);

	if((sec >= a_start and sec <= a_end))then
		return true;
	end
end

function LobbyClientServicePage.IsOpen_PvP_teen()
	local self = LobbyClientServicePage;
	NPL.load("(gl)script/apps/Aries/Scene/main.lua");
	local Scene = commonlib.gettable("MyCompany.Aries.Scene");
	local sec = Scene.GetElapsedSecondsSince0000();
	local a_start = commonlib.timehelp.GetSeconds(12,0,0);
	local a_end = commonlib.timehelp.GetSeconds(14,0,0);

	local b_start = commonlib.timehelp.GetSeconds(17,0,0);
	local b_end = commonlib.timehelp.GetSeconds(24,0,0);

	local c_start = commonlib.timehelp.GetSeconds(0,0,0);
	local c_end = commonlib.timehelp.GetSeconds(1,0,0);
	--if(System.options.isAB_SDK)then
		--return true;
	--end
	--local week = Scene.GetDayOfWeek();
	--if(week == 2 or week == 4 or week == 6)then
		--return false;
	--end
	if((sec >= a_start and sec <= a_end) or (sec >= b_start and sec <= b_end) or (sec >= c_start and sec <= c_end))then
		return true;
	end
end
function LobbyClientServicePage.IsOpen_PvP(worldname)
	if(System.options.isAB_SDK) then
		return true;
	end
	if(CommonClientService.IsTeenVersion())then
		return LobbyClientServicePage.IsOpen_PvP_teen();
	else
		return LobbyClientServicePage.IsOpen_PvP_kids(worldname);
	end
end

function LobbyClientServicePage.IsOpen_PvP_Practice()
	local isHoliday = AntiIndulgenceArea.IsInHoliday();
	
	if(isHoliday) then
		-- open every holiday and open every day if it is fairplay.
	else
		if(System.options.isAB_SDK) then
			return true;
		end
		local time = Scene.GetElapsedSecondsSince0000();
		if(time)then
			if( (time >= 0 and time <= 1 * 60 * 60) or (time >= 9 * 60 * 60 and time <= 24 * 60 * 60))then
				return true;
			end
		end
		BroadcastHelper.PushLabel({id="free_pvp_noticket_tip", label = "公平竞技场只在9:00~次日1:00点开启。", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
		return;
		--if(not time or time < 9 * 60 * 60 or (time > 22 * 60 * 60)) then
			--if(System.options.isAB_SDK) then
				--return true;
			--end
			--BroadcastHelper.PushLabel({id="free_pvp_noticket_tip", label = "PK试练场只在9:00~22:00点开启。", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			--return;
		--end
	end
	return true;
end

function LobbyClientServicePage.GetTicket()
	local self = LobbyClientServicePage;
	local __,__,__,copies_12005 = hasGSItem(12005);			
	copies_12005 = copies_12005 or 0;

	local __,__,__,copies_12006 = hasGSItem(12006);			
	copies_12006 = copies_12006 or 0;
	local copies = copies_12005 + copies_12006;
	return copies;
end
--判断每天可以进入的次数
-- @param worldname: world name
-- @param bDisplayMessage: true to display message box. if nil, it means true. 
function LobbyClientServicePage.CheckTicket_CanPass(worldname, bDisplayMessage)
	
	if( not WorldManager:HasTicket(worldname)) then
		local cur_world_info = WorldManager:GetCurrentWorld();
		local world_info = WorldManager:GetWorldInfo(worldname);

		if(cur_world_info ~= world_info) then
			if(world_info.ticket_gsid) then
				-- automatically purchase ticket
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(world_info.ticket_gsid);
				if(gsItem) then
					local maxdailycount = gsItem.maxdailycount;
					local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(world_info.ticket_gsid);
					if(gsObtain and gsObtain.inday < maxdailycount) then
						ItemManager.PurchaseItem(world_info.ticket_gsid, maxdailycount-gsObtain.inday, function(msg) 
								LOG.std("", "system","Item", "auto purchase ticket %d for user", world_info.ticket_gsid);
								if(msg.issuccess == true) then
									if(bDisplayMessage~=false) then
										_guihelper.MessageBox(format("进入这个世界需要门票, 我们为您免费申请了%d张门票", maxdailycount));
									end
								else
									--_guihelper.MessageBox("进入这个世界需要门票, 今天你的免费门票已经用完, 不能进入这个世界了");
								end
							end, function(msg) end, nil, "none", nil, nil, timeout, timeout_callback);

						-- we will assume return purchase will succeed. 
						return true;
					else
						if(bDisplayMessage~=false) then
							_guihelper.MessageBox(format("每天最多%d张门票, 今天你的免费门票已经用完, 不能进入这个世界了", maxdailycount));
						end
					end
				end
			end
			return false;
		end
	end

	local self = LobbyClientServicePage;
	if(false and (worldname == "HaqiTown_RedMushroomArena_1v1" or 
		worldname == "HaqiTown_RedMushroomArena_2v2" or 
		worldname == "HaqiTown_RedMushroomArena_3v3" or 
		worldname == "HaqiTown_RedMushroomArena_4v4")) then
		local gsid = 40004;
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		local maxcount = gsItem.template.maxcount or 0;
		local __,__,__,copies = hasGSItem(gsid);			
		copies = copies or 0;
		if(copies <= 0)then
			local s = string.format("你今天的比赛次数用完了，请明天再来吧。今天你最多可以比赛%d次。",maxcount);
			if(bDisplayMessage~=false) then
				_guihelper.MessageBox(s);
			end
			return false;
		end
	elseif(worldname == "HaqiTown_FireCavern_Hero" 
		or worldname == "HaqiTown_YYsNightmare" 
		or worldname == "AncientEgyptIsland_PharaohFortress" 
		or worldname == "HaqiTown_LightHouse_Hero"
		or worldname == "AncientEgyptIsland_LostTemple_NanJue"
		or worldname == "FlamingPhoenixIsland_TheGreatTree_Hero"
		)then
		return self.CanPassToday_WorldInstance(worldname,bDisplayMessage);
	elseif(worldname == "HaqiTown_LightHouse_S4")then
		local bHas = hasGSItem(17154);
		if(not bHas)then
			if(bDisplayMessage ~= false)then
				_guihelper.MessageBox("你没有金钥匙，不能进入这个副本!");
			end
			return false;
		end
	end
	return true;
end
function LobbyClientServicePage.GetPvP_Label(worldname)
	if(worldname and worldname:match("^HaqiTown_LafeierCastle_PVP")) then
		return "拉斐尔城堡积分赛开放时间为周一至周四16:00~22:00.";
	end
	local self = LobbyClientServicePage;
	if(CommonClientService.IsTeenVersion())then
		return "红蘑菇赛场开放时间为每天12:00~14:00和17:00~次日1:00.";
	else
		if(worldname and worldname:match("^HaqiTown_RedMushroomArena_1v1")) then
			return "红蘑菇1v1开放时间为每天16:00~22:00.";
		elseif(worldname and worldname:match("^HaqiTown_RedMushroomArena_2v2")) then
			return "红蘑菇2v2开放时间为周五至周天14:00~22:00.";
		end

		--return "PK竞技场开放时间为周一至周五，周日————12:00~14:00,17:00~22:00";
		return "PK竞技场开放时间为每天11:00~15:00.";
	end
end
--检查比赛时间
function LobbyClientServicePage.CheckPvPTime_CanPass(worldname)
	local self = LobbyClientServicePage;
	if(not self.IsOpen_PvP(worldname))then
		_guihelper.MessageBox(self.GetPvP_Label(worldname));
		return false;
	end
	return true;
end
--检查各种限制条件 return true if passed
function LobbyClientServicePage.CheckRoomState(game_type,worldname)
	local self = LobbyClientServicePage;
	if(game_type == "PvP")then
		if(worldname and worldname:match("^HaqiTown_TrialOfChampions_")) then
			-- every one can enter trial champion. 
			return LobbyClientServicePage.IsOpen_PvP_Practice();
		elseif(worldname and worldname:match("^HaqiTown_LafeierCastle_PVP")) then
			local can_pass = self.CheckPvPTime_CanPass(worldname);
			if(not can_pass)then
				return
			end
			return true;
		elseif(worldname and (worldname:match("^HaqiTown_RedMushroomArena_1v1") or worldname:match("^HaqiTown_RedMushroomArena_2v2"))) then
			local can_pass = self.CheckPvPTime_CanPass(worldname);
			if(not can_pass)then
				return
			end
			return true;
		elseif(worldname and worldname ~= "HaqiTown_RedMushroomArena_4v4")then
			local copies = self.GetTicket();
			if(copies <= 0)then
				-- show the tip for free ticket 
				NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
				local s;
				if(CommonClientService.IsKidsVersion())then
					s = "没有赛场门票，不能进入！去阳光海岸领取免费门票，或者去商城购买吧！";
				else
					s = "没有赛场门票，不能进入。立即领取免费门票！";
					if(worldname == "HaqiTown_RedMushroomArena_1v1") then
						return true;
					end
				end
				_guihelper.Custom_MessageBox(s,function(result)
					if(result == _guihelper.DialogResult.Yes)then
						self.ClosePage();
						if(CommonClientService.IsKidsVersion())then
							local item = {CameraPosition={15, 0.26, -0.82,},Name="赛场管理员",Position={20316.82, -2.36, 19688.65,},Desc="bla",}
							NPL.load("(gl)script/apps/Aries/Help/MapHelp.lua");
							MyCompany.Aries.Help.MapHelp.GotoPlaceByItem(item);
						else
							local worldname,position,camera = WorldManager:GetWorldPositionByNPC(31119); -- in main land
							if(not worldname) then
								worldname,position,camera = WorldManager:GetWorldPositionByNPC(31893); -- in darkforest land
							end
							WorldManager:GotoWorldPosition(worldname,position,camera, nil, nil, true);
						end
					end
				end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/Coming_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
				return
			end
			if(ExternalUserModule:GetConfig().disable_pvp) then
				if(System.options.version == "teen") then
					_guihelper.MessageBox("本月红蘑菇赛场不开放, 下个赛季来参加吧");
				else
					_guihelper.MessageBox("本月红蘑菇赛场不开放, 下个赛季来参加吧");
				end
				return;
			end
		end

		local can_pass = self.CheckPvPTime_CanPass();
		if(not can_pass)then
			return
		end
	end
	--判断每天可以进入的次数
	local can_pass = self.CheckTicket_CanPass(worldname);
	if(not can_pass)then
		return
	end

	local combatlevel = 1;
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		combatlevel = bean.combatlel;
	end

	--local games, closest_game_tmpl = LobbyClient:GetGamesByWorldName(worldname, game_type, combatlevel);
	--if(#games==0 and closest_game_tmpl and (closest_game_tmpl.min_level or 0)>(combatlevel or 0) ) then
		--_guihelper.MessageBox(format("你需要到达%d级，才能进入%s", closest_game_tmpl.min_level or 0, closest_game_tmpl.name));
		--return;
	--end
	
	return true;
end
--设置奖励列表
function LobbyClientServicePage.SetLootsList(keyname,mode)
	local self = LobbyClientServicePage;
	self.loots_list = nil;
	if(keyname)then
		self.loots_list = self.BuildLootsList(keyname,mode);
	end
end
--更改分类
function LobbyClientServicePage.UpdateLootsList()
	local game_info = LobbyClientServicePage.GetGameInfoByID(LobbyClientServicePage.selected_game_id);
	if(game_info)then
		local keyname = game_info.keyname;
		local mode = LobbyClientServicePage.selected_mode_loots_menu;
		LobbyClientServicePage.SetLootsList(keyname,mode);
	end
end
--转换奖励为table格式
function LobbyClientServicePage.BuildLootsList(keyname,mode)
	local self = LobbyClientServicePage;
	if(not keyname)then return end
	local list;
	local tempaltes = self.GetGameTemplates();
    local template = tempaltes[keyname];
    if(template)then
		local worldname = template.worldname;
		local loots = template.loots;
		if(not loots or loots == "")then
			local __,max_mode = LobbyClientServicePage.LoadModeList(keyname);
			max_mode = max_mode or 3;
			mode = mode or max_mode;
			loots = self.GetLootsByWorldName(worldname,mode);
		end
        if(loots)then
            list = {};
            local line;
			for line in string.gfind(loots, "[^|]+") do
                local gsid,cnt = string.match(line,"(.+),(.+)");
                gsid = tonumber(gsid);
                cnt = tonumber(cnt) or 0;
                if(gsid)then
                    table.insert(list,{
                        gsid = gsid,
                        cnt = cnt,
                    })
                end
            end
			table.sort(list,function(a,b)
				return a.gsid < b.gsid;
			end);
        end
    end
	return list;
end
function LobbyClientServicePage.ShowProfile(nid)
	if(not nid)then return end
	System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid=nid});
end
function LobbyClientServicePage.CanPassToday_WorldInstance(worldname,bDisplayMessage)
	local self = LobbyClientServicePage;
	local cnt = self.GetTodayCnt_WorldInstance(worldname);
	local world_info = WorldManager:GetWorldInfo(worldname);
	
	if(cnt and cnt >= 3)then
		local s = "每天只能进入3次，明天再来吧！";
		if(world_info)then
			s = string.format("%s每天只能进入3次，明天再来吧！",world_info.world_title or "");
		end
		if(bDisplayMessage ~= false)then
			_guihelper.MessageBox(s);
		end
		return false;
	end
	return true;
end
--初始化副本进入情况
function LobbyClientServicePage.DoLoadWorldInstanceCnt(callbackFunc)
	local self = LobbyClientServicePage;
	self.LoadRemoteData(nil,980,1002,function(msg)
		if(msg and msg.data)then
			self.world_instance_cnt_map = msg.data;

			local today = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
			local date = self.world_instance_cnt_map["date"];

			--[[
				self.world_instance_cnt_map = {
					date = "",
					HaqiTown_FireCavern_Hero = 0,
					HaqiTown_YYsNightmare = 0,
					AncientEgyptIsland_PharaohFortress = 0，
				}
			--]]
			if(not date  or date ~= today)then
				self.world_instance_cnt_map = {
					date = today,
				}
				self.SaveRemoteData(980,1002,self.world_instance_cnt_map);
			end

			if(callbackFunc)then
				callbackFunc();
			end
		end
	end)
end
--进入副本次数+1
function LobbyClientServicePage.AddTodayCnt_WorldInstance(worldname)
	local self = LobbyClientServicePage;
	if(not worldname)then
		return;
	end
	if(worldname == "HaqiTown_LightHouse_S4")then
		--消耗金钥匙
		TeamWorldInstancePortal.DestroyItemFromKey(17154);
		return
	end
	if(worldname == "HaqiTown_FireCavern_Hero" 
		or worldname == "HaqiTown_YYsNightmare" 
		or worldname == "AncientEgyptIsland_PharaohFortress" 
		or worldname == "HaqiTown_LightHouse_Hero"
		or worldname == "AncientEgyptIsland_LostTemple_NanJue"
		or worldname == "FlamingPhoenixIsland_TheGreatTree_Hero"
		) then
		if(self.world_instance_cnt_map)then
			local cnt = self.world_instance_cnt_map[worldname] or 0;
			cnt = cnt + 1;
			self.world_instance_cnt_map[worldname] = cnt;
			self.SaveRemoteData(980,1002,self.world_instance_cnt_map);
		end
	end					

end
--获取进入副本的次数
function LobbyClientServicePage.GetTodayCnt_WorldInstance(worldname)
	local self = LobbyClientServicePage;
	if(not worldname)then
		return;
	end
	if(self.world_instance_cnt_map)then
		local cnt = self.world_instance_cnt_map[worldname] or 0;
		return cnt;
	end
end
function LobbyClientServicePage.LoadRemoteData(nid,gsid,bag,callbackFunc)
	local self = LobbyClientServicePage;
	local myself = Map3DSystem.User.nid;
	if(not gsid or not bag)then return end
	if(not nid)then
		nid = myself;
	end
	if(nid == myself)then
			ItemManager.GetItemsInBag(bag, nid.."LoadRemoteData", function(msg)
				local hasItem,guid = hasGSItem(gsid);
				if(hasItem)then
					local item = ItemManager.GetItemByGUID(guid);
					if(item)then
						local clientdata = item.clientdata;
						if(clientdata == "")then
							clientdata = "{}"
						end
						clientdata = commonlib.LoadTableFromString(clientdata);
						if(callbackFunc and type(callbackFunc) == "function")then
							callbackFunc({
								data = clientdata,
							});
						end
					end
				end
			end, "access plus 5 minutes");
	else
		ItemManager.GetItemsInOPCBag(nid, bag, nid.."LoadRemoteData", function(msg)
			local hasItem,guid = ItemManager.IfOPCOwnGSItem(nid, gsid);
			if(hasItem)then
				local item = ItemManager.GetOPCItemByGUID(nid,guid);
				if(item)then
					local clientdata = item.clientdata;
					if(clientdata == "")then
						clientdata = "{}"
					end
					clientdata = commonlib.LoadTableFromString(clientdata);
					if(callbackFunc and type(callbackFunc) == "function")then
						callbackFunc({
							data = clientdata,
						});
					end
				end
			end
		end, "access plus 5 minutes");
	end
end
function LobbyClientServicePage.SaveRemoteData(gsid,bag,data,callbackFunc)
	local self = LobbyClientServicePage;
	if(not gsid or not bag or not data)then return end
	ItemManager.GetItemsInBag(bag, "SaveRemoteData", function(msg)
		local hasItem,guid = hasGSItem(gsid);
		if(hasItem)then
			local item = ItemManager.GetItemByGUID(guid);
			if(item)then
				local clientdata = commonlib.serialize_compact2(data);
				ItemManager.SetClientData(guid,clientdata,function(msg_setclientdata)
					if(callbackFunc and type(callbackFunc) == "function")then
						callbackFunc({
						});
					end
				end);
			end
		end
	end, "access plus 5 minutes");
end
function LobbyClientServicePage.OnInitClient()
	local lc = LobbyClient:GetClient();
	LobbyClient.events:AddEventListener("on_handle_all_msg",LobbyClientServicePage.OnHandleAllMsg,{});
end
LobbyClientServicePage.loots_keys = {
	"_easy","","_hard","_hero","_nightmare",
}
LobbyClientServicePage.loots_school_keys = {
	"fire","ice","storm","life","death","myth",
}
--返回副本中boss信息
function LobbyClientServicePage.GetBossInfoByWorldName(worldname,mode)
	if(not worldname)then return end
	local self = LobbyClientServicePage;
	mode = mode or 3;
	local arenas_mobs_name;
	if(CommonClientService.IsTeenVersion())then
		arenas_mobs_name = string.format("config/Aries/WorldData_Teen/%s.Arenas_Mobs.xml",worldname);
	else
		arenas_mobs_name = string.format("config/Aries/WorldData/%s.Arenas_Mobs.xml",worldname);
	end	
	local key = string.format("%s_%d",arenas_mobs_name,mode);
	if(not self.boss_str_list[key])then
		LobbyClientServicePage.GetLootsByWorldName(worldname,mode);
	end
	return self.boss_str_list[key];
end
function LobbyClientServicePage.GetLootsByWorldName(worldname,mode)
	local arenas_mobs_name;
	if(CommonClientService.IsTeenVersion())then
		arenas_mobs_name = string.format("config/Aries/WorldData_Teen/%s.Arenas_Mobs.xml",worldname);
	else
		arenas_mobs_name = string.format("config/Aries/WorldData/%s.Arenas_Mobs.xml",worldname);
	end	
	return LobbyClientServicePage.GetLootsByWorldName_Fullpath(arenas_mobs_name,mode);
end
LobbyClientServicePage.mode_str_map = {
	["easy"] = 1,
	["normal"] = 2,
	["hard"] = 3,
	["hero"] = 4,
	["nightmare"] = 5,
}
function LobbyClientServicePage.ModeStrToNum(mode_str)
	if(mode_str)then
		return LobbyClientServicePage.mode_str_map[mode_str];
	end
end
--return loots list
function LobbyClientServicePage.GetLootsListByWorldName_Fullpath(arenas_mobs_name,mode,position)
	local loots = LobbyClientServicePage.GetLootsByWorldName_Fullpath(arenas_mobs_name,mode,position)
	 if(loots)then
        list = {};
        local line;
		for line in string.gfind(loots, "[^|]+") do
            local gsid,cnt = string.match(line,"(.+),(.+)");
            gsid = tonumber(gsid);
            cnt = tonumber(cnt) or 0;
            if(gsid)then
                table.insert(list,{
                    gsid = gsid,
                    cnt = cnt,
                })
            end
        end
		table.sort(list,function(a,b)
			return a.gsid < b.gsid;
		end);
		return list;
    end
end
--@param arenas_mobs_name:法阵完整路径
--@param mode: 1,2,3,4,5
--@param position:具体法阵的过滤条件 string 精确为整数"20759,214,20414"
function LobbyClientServicePage.GetLootsByWorldName_Fullpath(arenas_mobs_name,mode,position)
	if(not arenas_mobs_name)then return end
	local self = LobbyClientServicePage;
	local function to_int_str(str)
		if(str)then
			local x,y,z = string.match(str,"(.+),(.+),(.+)");
			x = tonumber(x) or 0;
			y = tonumber(y) or 0;
			z = tonumber(z) or 0;
			str = string.format("%d,%d,%d",x,y,z);
			return str;
		end
	end
	mode = mode or 3;
	local key;
	if(position)then
		position = to_int_str(position);
		key = string.format("%s_%d_s",arenas_mobs_name,mode,position);
	else
		key = string.format("%s_%d",arenas_mobs_name,mode);
	end
	if(self.loots_str_list[key])then
		return self.loots_str_list[key];
	end
    local xmlRoot = ParaXML.LuaXML_ParseFile(arenas_mobs_name);

    local all_mob_templates = {};
    
    local available_loots = {};

	local hp_scale = 1;
	local max_hp = 0;--boss血量
	local all_hp = 0;--怪物总血量
	local boss_template;
	local mode_map = LobbyClientServicePage.mode_str_map;
	
    if(xmlRoot) then
		local each_arena;
	    for each_arena in commonlib.XPath.eachNode(xmlRoot, "/arenas/arena") do
			local each_mob;
			for each_mob in commonlib.XPath.eachNode(each_arena, "/mob") do
				if(each_mob.attr.mob_template and each_mob.attr.mob_template ~= "") then
					all_mob_templates[each_mob.attr.mob_template] = true;
				end
			end
			local position_str = each_arena.attr.position;
			--根据位置过滤法阵
			if(position and position_str)then
				position_str = to_int_str(position_str);
				if(position == position_str)then
					local each_mob;
					for each_mob in commonlib.XPath.eachNode(each_arena, "/mob") do
						if(each_mob.attr.mob_template and each_mob.attr.mob_template ~= "") then
							all_mob_templates[each_mob.attr.mob_template] = true;
						end
					end
				end
			else
				local each_mob;
				for each_mob in commonlib.XPath.eachNode(each_arena, "/mob") do
					if(each_mob.attr.mob_template and each_mob.attr.mob_template ~= "") then
						all_mob_templates[each_mob.attr.mob_template] = true;
					end
				end
			end
		end
		local modifier
	    for modifier in commonlib.XPath.eachNode(xmlRoot, "/arenas/difficulty_modifier/modifier") do
			if(modifier.attr.mode and mode_map[modifier.attr.mode] == mode)then
				hp_scale = 	tonumber(modifier.attr.hp);
			end
		end
    end

    local template_path, _;
    for template_path, _ in pairs(all_mob_templates) do
        
        local xmlRoot = ParaXML.LuaXML_ParseFile(template_path);
        
        if(not xmlRoot) then
		    commonlib.log("warning: failed loading common loot list file: %s\n", template_path);
        else
			local each_mob;
			for each_mob in commonlib.XPath.eachNode(xmlRoot, "/mobtemplate/mob") do
				local loot_key = LobbyClientServicePage.loots_keys[mode];
				local hp = tonumber(each_mob.attr.hp) or 0;
				all_hp = all_hp + hp;
				if(hp and hp > max_hp)then
					max_hp = hp;
					boss_template = each_mob;
				end
				if(loot_key)then
					local k,v;
					local loot_group_index;
					for loot_group_index = 1,10 do
						--loot1_easy loot2_easy ... loot10_easy
						--loot1 loot2 ... loot10
						--loot1_hard loot2_hard ... loot10_hard
						--loot1_hero loot2_hero ... loot10_hero
						--loot1_nightmare loot2_nightmare ... loot10_nightmare
						local key = string.format("loot%d%s",loot_group_index,loot_key);
						local section,cnt;
						local source = each_mob.attr[key];
						if(source)then
							for section,cnt in string.gmatch(source, "%[(%d+),(%d+)%]=%d+") do
								available_loots[tonumber(section)] = cnt;
							end
						end
					end
					local k,v;
					for k,v in ipairs(LobbyClientServicePage.loots_school_keys) do
						--loot_fire_easy loot_ice_easy ...
						--loot_fire loot_ice ...
						--loot_fire_hard loot_ice_hard ...
						--loot_fire_hero loot_ice_hero ...
						--loot_fire_nightmare loot_ice_nightmare ...
						local key = string.format("loot_%s%s",v,loot_key);
						local section,cnt;
						local source = each_mob.attr[key];
						if(source)then
							for section,cnt in string.gmatch(source, "%[(%d+),(%d+)%]=%d+") do
								available_loots[tonumber(section)] = cnt;
							end
						end
					end
				end
			end
		end
    end
    local log_line = "";
    local gsid, cnt;
    for gsid, cnt in pairs(available_loots) do
		if(not LobbyClientServicePage.IsInExcludeRegion_Loot(gsid))then
			log_line = string.format("%s%d,%d|",log_line,gsid,tonumber(cnt));
		end
        --log_line = log_line..gsid..",1|";
    end
	--echo("========log_line");
	--echo(log_line);
	self.loots_str_list[key] = log_line;
	local boss_info = {
		hp = max_hp * hp_scale,
		all_hp = all_hp * hp_scale,
		boss_template = boss_template,
	}
	self.boss_str_list[key] = boss_info;
	return log_line;
end
--搜索同一个副本 不同难度的列表
function LobbyClientServicePage.LoadModeList_ByWorldName(worldname)
	local mode_list = LobbyClient:LoadModeList_ByWorldName(worldname)
	if(CommonClientService.IsKidsVersion())then
		return LobbyClientServicePage.__LoadModeList_kids(mode_list);
	else
		return LobbyClientServicePage.__LoadModeList_teens(mode_list);
	end
end
--[[
--获副本难度列表
local mode_list = {
		{ mode = 1, max_players = 4, lable_1="单人", lable_2="1~2人", lable_3="很少", is_checked = true},
		{ mode = 2, max_players = 4, lable_1="普通", lable_2="3人", lable_3="一般", },
		{ mode = 3, max_players = 4, lable_1="精英", lable_2="3~4人", lable_3="很多", },
	}
return mode_list,max_mode
--]]
function LobbyClientServicePage.LoadModeList(keyname)
	local mode_list = LobbyClient:LoadModeList(keyname);
	if(CommonClientService.IsKidsVersion())then
		return LobbyClientServicePage.__LoadModeList_kids(mode_list);
	else
		return LobbyClientServicePage.__LoadModeList_teens(mode_list);
	end
end
function LobbyClientServicePage.__LoadModeList_kids(mode_list)
	local self = LobbyClientServicePage;
	if(not mode_list)then
		return
	end
	local k,v;
	for k,v in ipairs(mode_list) do
		local mode = v.mode;
		local recommend_players = v.recommend_players;
		local max_players = v.max_players;
		if(mode == 1)then
			v.lable_1 = "单人";
			if(recommend_players == max_players)then
				v.lable_2 = string.format("%d人",recommend_players);
			else
				v.lable_2 = string.format("%d~%d人",recommend_players,max_players);
			end
			v.lable_3 = "很少";
		elseif(mode == 2)then
			v.lable_1 = "普通";
			if(recommend_players == max_players)then
				v.lable_2 = string.format("%d人",recommend_players);
			else
				v.lable_2 = string.format("%d~%d人",recommend_players,max_players);
			end
			v.lable_3 = "一般";
		elseif(mode == 3)then
			v.lable_1 = "精英";
			if(recommend_players == max_players)then
				v.lable_2 = string.format("%d人",recommend_players);
			else
				v.lable_2 = string.format("%d~%d人",recommend_players,max_players);
			end
			v.lable_3 = "很多";
		elseif(mode == 4)then
			v.lable_1 = "英雄";
			if(recommend_players == max_players)then
				v.lable_2 = string.format("%d人",recommend_players);
			else
				v.lable_2 = string.format("%d~%d人",recommend_players,max_players);
			end
			v.lable_3 = "很多";
		elseif(mode == 5)then
			v.lable_1 = "炼狱";
			if(recommend_players == max_players)then
				v.lable_2 = string.format("%d人",recommend_players);
			else
				v.lable_2 = string.format("%d~%d人",recommend_players,max_players);
			end
			v.lable_3 = "很多";
		end
	end
	local len = #mode_list;
	local max_mode;
	if(len > 0)then
		mode_list[1].is_checked = true;
		max_mode = mode_list[len].mode;
	end
	return mode_list,max_mode;
end
function LobbyClientServicePage.__LoadModeList_teens(mode_list)
	local self = LobbyClientServicePage;
	if(not mode_list)then
		return
	end
	local k,v;
	for k,v in ipairs(mode_list) do
		local mode = v.mode;
		local recommend_players = v.recommend_players;
		local max_players = v.max_players;
		if(mode == 1)then
			v.lable_1 = "单人";
			if(recommend_players == max_players)then
				v.lable_2 = string.format("%d人",recommend_players);
			else
				v.lable_2 = string.format("%d~%d人",recommend_players,max_players);
			end
			v.lable_3 = "很少";
		elseif(mode == 2)then
			v.lable_1 = "双人";
			if(recommend_players == max_players)then
				v.lable_2 = string.format("%d人",recommend_players);
			else
				v.lable_2 = string.format("%d~%d人",recommend_players,max_players);
			end
			v.lable_3 = "一般";
		elseif(mode == 3)then
			v.lable_1 = "多人";
			if(recommend_players == max_players)then
				v.lable_2 = string.format("%d人",recommend_players);
			else
				v.lable_2 = string.format("%d~%d人",recommend_players,max_players);
			end
			v.lable_3 = "很多";
		elseif(mode == 4)then
			v.lable_1 = "英雄";
			if(recommend_players == max_players)then
				v.lable_2 = string.format("%d人",recommend_players);
			else
				v.lable_2 = string.format("%d~%d人",recommend_players,max_players);
			end
			v.lable_3 = "很多";
		elseif(mode == 5)then
			v.lable_1 = "炼狱";
			if(recommend_players == max_players)then
				v.lable_2 = string.format("%d人",recommend_players);
			else
				v.lable_2 = string.format("%d~%d人",recommend_players,max_players);
			end
			v.lable_3 = "很多";
		end
	end
	local len = #mode_list;
	local max_mode;
	if(len > 0)then
		mode_list[1].is_checked = true;
		max_mode = mode_list[len].mode;
	end
	return mode_list,max_mode;
end
function LobbyClientServicePage.IsSearchState()
	local self = LobbyClientServicePage;
	return self.is_search_state;
end
function LobbyClientServicePage.SearchGame()
	local self = LobbyClientServicePage;
	if(not self.page)then
		return
	end
    local key = self.page:GetValue("search_words");
	if(not key or key == "")then 
		self.search_result_list= self.rooms_list;
		self.page:Refresh(0);
		return;
	end
	key = string.lower(key);
	if(self.rooms_list)then
		self.is_search_state = true;
		local result = {};
		local k,v;
		for k,v in ipairs(self.rooms_list) do
			local game_id = v.game_id or "";
			game_id = tostring(game_id);
			local game_name = v.game_name or "";
			local name = v.name or "";	

			game_id = string.lower(game_id);
			game_name = string.lower(game_name);
			name = string.lower(name);
			if(string.find(game_id,key) or string.find(game_name,key) or string.find(name,key))then
				table.insert(result,v);
			end
		end
		if(CommonClientService.IsTeenVersion())then
			CommonClientService.Fill_List(result,13);
		end
		self.search_result_list= result;
		if(self.page)then
			self.page:Refresh(0);
			local _editbox = self.page:FindUIControl("search_words");
			if(_editbox and _editbox:IsValid()) then
				_editbox:Focus();
				_editbox:SetCaretPosition(-1);
			end
		end
	end
	
end
function LobbyClientServicePage.OnKeyUp(name, mcmlNode)
	local self = LobbyClientServicePage;
	if(self.page)then
		local _editbox = self.page:FindUIControl("search_words");
		if(_editbox and _editbox:IsValid()) then
			local sentText = _editbox.text;
			if(string.len(sentText) > 120) then
				_editbox.text = string.sub(sentText, 1, 120);
				_editbox:SetCaretPosition(-1);
			end
	
			if(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER) then
				self.SearchGame();
			else
				self.search_txt = sentText;
			end
		end
	end
end
function LobbyClientServicePage.SearchModeWorld(worldname,game_type,callbackFunc)
	local self = LobbyClientServicePage;
	local combatlevel;
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		combatlevel = bean.combatlel;
	end
	game_type = game_type or "PvE";
	local can_pass = LobbyClientServicePage.CheckRoomState(game_type,worldname)
	if(not can_pass)then
		return;
	end
	LobbyClientServicePage.RefreshRooms(function()
		local login_room_id = self.GetRoomID();
		local game_info = self.GetGameInfoByID(login_room_id);
		if(game_info and game_info.worldname == worldname and game_info.game_type == game_type)then
			RoomDetailPage.ShowPage();
			return
		end
		LobbyClient:AutoFindRoom(worldname, game_type, combatlevel, function(candidate_rooms, games)
			if(not candidate_rooms) then
				-- use normal way to load the world
				if(callback_func)then
					local games = LobbyClient:GetGamesByWorldName(worldname, game_type);
					callback_func(combatlevel, games);
				end
				return
			elseif(#candidate_rooms == 0) then
				if(games and games[1])then
					local keyname = games[1].keyname;
					local mode_list = self.LoadModeList_ByWorldName(worldname) or {};
					if(#mode_list == 1)then
						--直接创建房间
						LobbyClientServicePage.CreateRoomKeyName(keyname, game_type, is_start_now, is_auto_start, password)
						return
					end
				end
			end
			local keyname;
			if(#candidate_rooms == 0) then
				if(games and games[1])then
					keyname = games[1].keyname;
				end
			elseif(candidate_rooms[1])then
				keyname = candidate_rooms[1].keyname;
			end
			local mode_list = self.LoadModeList_ByWorldName(worldname) or {};
			local quest_track_mode_world = QuestTrackerPane.GetModeWorldList();
			local mode = 1;
			if(mode_list[1] and mode_list[1].mode)then
				mode = mode_list[1].mode;
			end
			LobbyClientServicePage.CreateRoomKeyName(keyname, game_type, true, true, password, mode);
			--ModeMenuPage.ShowPage(worldname,mode_list,candidate_rooms,quest_track_mode_world,function(args)
				--if(args)then
					--local state = args.state;
					--local mode = args.mode;
					--local room_index = args.room_index;
					--if(state == "create")then
						--if(keyname)then
							--LobbyClientServicePage.CreateRoomKeyName(keyname, game_type, is_start_now, is_auto_start, password, mode)
						--end
					--else
						--local room = candidate_rooms[room_index];
						--if(room) then
							--local game_id = room.game_id;
							--LobbyClientServicePage.DoJoinGame_Internal(game_id,nil, room);
						--end
					--end
				--end
			--end);
		end)
	end);
end
function LobbyClientServicePage.BroadcastRoomMsg(game_info)
	if(not game_info)then return end
	NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
	local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
	local owner_nid = game_info.owner_nid;
	local gameid = game_info.id;
	local mode = game_info.mode or 1;
	local worldname = game_info.worldname;
	local tempaltes = LobbyClientServicePage.GetGameTemplates();
	local keyname = game_info.keyname;
	
	if(mode > 3)then
		return
	end
	local words = string.format([[lobby|%d|%d|%s|lobby]],gameid,mode,keyname);
	ChatChannel.SendMessage( ChatChannel.EnumChannels.BroadCast, nil, nil, words );
end
function LobbyClientServicePage.GetLobbyCallMsg(from_nid,text)
	if(not from_nid or not text)then
		return
	end
	local gameid,mode,keyname = string.match(text,"lobby|(.+)|(.+)|(.+)|lobby");
	mode = tonumber(mode);
	if(gameid and mode and keyname)then
		local tempaltes = LobbyClientServicePage.GetGameTemplates();
		local template = tempaltes[keyname];
		if(not template)then
			return
		end
		local is_myself = false;
		if(Map3DSystem.User.nid == from_nid)then
			is_myself = true;
		end
		local combatlel = 0;
		local bean = MyCompany.Aries.Pet.GetBean();
		if(bean)then
			combatlel = bean.combatlel or 0;
		end
		local name = template.name or "";
		local min_level = template.min_level or 0;
		local max_level = template.max_level or 100;

		local can_show = true;
		
		local unchecked_list = RoomFilterPage.GetUncheckedArray("PvE");
		if(not is_myself and unchecked_list)then
			local k,v; 
			for k,v in pairs(unchecked_list) do
				if(v and k == keyname)then
					can_show = false;
				end
			end
		end
		----(用户等级-10)<=显示的副本进入等级<=用户等级
		--if(is_myself or (min_level >= (combatlel - 10) and min_level <= combatlel))then
			--can_show = true;
		--end
		if(not can_show)then
			return
		end
		local modelist = LobbyClientServicePage.LoadModeList(keyname)
		local node = LobbyClient:GetModeNode(modelist,mode)
		local mode_name = "";
		local recommend_players_str = "";
		if(node)then
			mode_name = node.lable_1;
			recommend_players_str = node.lable_2 or "";
		end
		local color;
		if(mode == 1)then
			color = "#ffffff";
		elseif(mode == 2)then
			color = "#40dd2a";
		elseif(mode == 3)then
			color = "#27d1ea";
		elseif(mode == 4)then
			color = "#e920eb";
		elseif(mode == 5)then
			color = "#ebb920";
		else
			color = "#27d1ea";
		end
		local tooltip = string.format("点击加入\r\n%s(%s)\r\n队伍ID:%d\r\n推荐等级:%d-%d\r\n推荐人数:%s",name,mode_name,gameid,min_level,max_level,recommend_players_str);
		local words = string.format([[<span><input type="button" tooltip="%s" style="margin-left:3px;margin-top:-5px;color:%s;background:;" onclick="MyCompany.Aries.CombatRoom.LobbyClientServicePage.TryDoJoinGame" name="%s" value="%s(%s)"/>寻找队友。</span>]],tooltip,color,gameid,name,mode_name);
		return words;
	end
end
function LobbyClientServicePage.TryDoJoinGame(game_id)
	local self = LobbyClientServicePage;
	game_id = tonumber(game_id);
	if(not game_id)then
		return
	end
	local login_room_id = self.GetRoomID();
	if(login_room_id)then
		if(login_room_id == game_id)then
			_guihelper.MessageBox("你现在已经在这个房间里面了！");
			return
		else
			_guihelper.Custom_MessageBox("你现在已经在一个副本房间里面了，确认要加入新的房间？",function(result)
				if(result == _guihelper.DialogResult.Yes)then
					LobbyClientServicePage.__TryDoJoinGame(game_id);
				end
			end,_guihelper.MessageBoxButtons.YesNo);
		end
	else
		_guihelper.Custom_MessageBox("是否要加入这个房间？",function(result)
			if(result == _guihelper.DialogResult.Yes)then
				LobbyClientServicePage.__TryDoJoinGame(game_id);
			end
		end,_guihelper.MessageBoxButtons.YesNo);
	end
end
function LobbyClientServicePage.__TryDoJoinGame(game_id)
	local self = LobbyClientServicePage;
	game_id = tonumber(game_id);
	local game_info = self.GetGameInfoByID(game_id);
	if(not game_info)then
		LobbyClientServicePage.RefreshRooms(function()
			game_info = self.GetGameInfoByID(game_id);
			if(not game_info)then
				_guihelper.MessageBox("房间不存在！");
				return
			end
			LobbyClientServicePage.DoJoinGame(game_id);
		end);
	else
		LobbyClientServicePage.DoJoinGame(game_id);
	end
end
function LobbyClientServicePage.GetWorldInfoByKeyname(keyname)
	if(not keyname)then return end
	local game_templates = LobbyClient:GetGameTemplates();
	if(game_templates)then
		local template = game_templates[keyname];
		if(template and template.worldname)then
			return WorldManager:GetWorldInfo(template.worldname);
		end
	end
end
function LobbyClientServicePage.LoadLootFilter()
	if(not CommonClientService.IsTeenVersion())then
		return
	end
	if(not LobbyClientServicePage.loot_exclude_regions)then
		LobbyClientServicePage.loot_exclude_regions = {};
		LobbyClientServicePage.loot_exclude_path = "config/Aries/LobbyService_Teen/loots_filter.xml";
		local xmlRoot = ParaXML.LuaXML_ParseFile(LobbyClientServicePage.loot_exclude_path);
		local exclude_node
		for exclude_node in commonlib.XPath.eachNode(xmlRoot, "/items/exclude/item") do
			local from_gsid = tonumber(exclude_node.attr.from);
			local to_gsid = tonumber(exclude_node.attr.to);
			local gsid = tonumber(exclude_node.attr.gsid);
			local node = {
				from = from_gsid,
				to = to_gsid,
				gsid = gsid,
			}
			table.insert(LobbyClientServicePage.loot_exclude_regions,node);
		end
	end
end
function LobbyClientServicePage.IsInExcludeRegion_Loot(gsid)
	gsid = tonumber(gsid);
	if(not gsid)then return end
	local loot_exclude_regions = LobbyClientServicePage.LoadLootFilter();
	if(loot_exclude_regions)then
		local k,v;
		for k,v in ipairs(loot_exclude_regions) do
			if(v.to and v.from)then
				if(gsid >= v.from and gsid <= v.to)then
					return true;
				end
			end
			if(v.gsid and gsid == v.gsid)then
				return true;
			end
		end	
	end
end


function LobbyClientServicePage.HasGameRoom(game_type,worldname_map,dofilter,callbackfunc)
	LobbyClientServicePage.selected_game_type = game_type;
	worldname_map = worldname_map or {};
	local combat_level = LobbyClient:GetMyCombatLevel()
	local game_key_array = LobbyClient:GetGameKeysByUserLevel(nil, game_type, true);
	local game_templates = LobbyClient:GetGameTemplates();
	local right_game_key_array = LobbyClient:GetGameKeysByUserLevel(combat_level, game_type, true);
	if(game_key_array and game_templates)then
		local unchecked_list = {};
		local k,v; 
		for k,v in pairs(game_templates) do
			local __,keyname;
			for __,keyname in ipairs(game_key_array) do
				if(v.keyname == keyname)then
					unchecked_list[keyname] = false;
					if(not worldname_map[v.worldname])then
						unchecked_list[keyname] = true;
					end
				end
			end
		end
		if(dofilter)then
			local keyname,v;
			for keyname,v in pairs(unchecked_list) do
				--检查已经选中的
				if(v == false)then
					local bfind = false;
					local kk,keyname_2;
					for kk,keyname_2 in ipairs(right_game_key_array) do
						if(keyname == keyname_2)then
							bfind = true;
						end
					end
					if(not bfind)then
						--取消选中
						unchecked_list[keyname] = true;
					end
				end
			end
		end
		
		local unchecked_array = unchecked_list;
		if(game_key_array and unchecked_array)then
			local new_game_key_array = {};
			local k,v;
			for k,v in ipairs(game_key_array) do
				if(not unchecked_array[v])then
					table.insert(new_game_key_array,v);
				end
			end
			game_key_array = new_game_key_array;
		end
		
	-- get room list data source. 
		local result = LobbyClient:GetRoomListDataSource(game_key_array, true, function(result)

			if(not result.is_fetching) then
				local list = result.formated_data;
				if(list)then
					local len = #list;
					while(len > 0) do					
						local room_info = list[len];
						if(room_info and room_info.status == "started")then
							table.remove(list,len);
						end
						len = len - 1;
					end
					
					if (#list>0) then 						
						callbackfunc(true)
					else
						callbackfunc(false)
					end		
				end
			end
		end)

	else
		callbackfunc(false)
	end
end

local tickets_3v3 = {50420,52109};

function LobbyClientServicePage.PVP3v3GetScoreCheck()
	for i = 1,#tickets_3v3 do
		local gsid = tickets_3v3[i];
		local bHas, _, __, copies = hasGSItem(gsid);
		if(bHas) then
			return true;
		end
	end
	return false;
end

function LobbyClientServicePage.Get3v3ScoreTimesPerDay()
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(LobbyClientServicePage.award_tag_gsid_for_3v3_kids);
	local value;
	if(gsItem and gsItem.maxdailycount) then
		value = gsItem.maxdailycount;
	end
	return value or 10;
end