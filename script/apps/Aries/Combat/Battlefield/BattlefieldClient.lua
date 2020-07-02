--[[
Title: battle field client main code
Author(s): LiXizhi
Date: 2011/12/20
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/Battlefield/BattlefieldClient.lua");
local BattlefieldClient = commonlib.gettable("MyCompany.Aries.Battle.BattlefieldClient");
BattlefieldClient.Show();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/BattlefieldService/GSL_BattleClient.lua");
NPL.load("(gl)script/apps/Aries/Combat/Battlefield/BattleProgressBar.lua");
NPL.load("(gl)script/ide/TooltipHelper.lua");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local BattleProgressBar = commonlib.gettable("MyCompany.Aries.Battle.BattleProgressBar");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local Pet = commonlib.gettable("MyCompany.Aries.Pet");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local BattlefieldClient = commonlib.gettable("MyCompany.Aries.Battle.BattlefieldClient");
local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");

local client;

BattlefieldClient.mini_scene_name = "bf";

function BattlefieldClient.OnActivateDesktop()
	local self = BattlefieldClient;
	local worldname = WorldManager:GetCurrentWorld().name or "";
	if( worldname:match("^BattleField_ChampionsValley") ) then
		BattlefieldClient.Reset();

		if(System.options.version == "kids") then
			local url = "script/apps/Aries/Combat/Battlefield/BattleProgressBar.html";
			System.App.Commands.Call("File.MCMLWindowFrame", {
				-- Add uid to url
				url = url, 
				name = "Aries.BattleProgressBar", 
				app_key = MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, 
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = -2,
				allowDrag = false,
				click_through = true,
				directPosition = true,
					align = "_rt",
					x = -250-5,
					y = 10,
					width = 250,
					height = 300,
			});
			BattleProgressBar.ShowMiniMapPage(true);
		else
			local url = "script/apps/Aries/Combat/Battlefield/BattleProgressBar.teen.html";
			System.App.Commands.Call("File.MCMLWindowFrame", {
				-- Add uid to url
				url = url, 
				name = "Aries.BattleProgressBar", 
				app_key = MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, 
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = -2,
				allowDrag = false,
				click_through = true,
				directPosition = true,
					align = "_rt",
					x = -250-5,
					y = 180,
					width = 250,
					height = 300,
			});
		end
		QuestTrackerPane.is_disabled = true;
		MyCompany.Aries.Desktop.QuestArea.is_diable_ui = true;
		MyCompany.Aries.Desktop.QuestArea.Show(false);
		Player.SetHeadonTextColorFunction(BattlefieldClient.Battle_HeadonTextColorFunction);
	else
		QuestTrackerPane.is_disabled = nil;
		if(MyCompany.Aries.Desktop.QuestArea.is_diable_ui) then
			MyCompany.Aries.Desktop.QuestArea.is_diable_ui = nil;

			local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
			MyCompany.Aries.Desktop.QuestArea.Show(true);
			if(not QuestTrackerPane.IsShown())then
				QuestTrackerPane.Show(true);
			end
		end
		ParaScene.DeleteMiniSceneGraph(self.mini_scene_name);
		System.App.Commands.Call("File.MCMLWindowFrame", {name = "Aries.BattleProgressBar", bShow=false, bDestroy=true,});
		System.App.Commands.Call("File.MCMLWindowFrame", {name = "Aries.BattleMiniMap", bShow=false, bDestroy=true,});
		client = nil;
		Player.SetHeadonTextColorFunction(nil);
		self.my_side = nil;
	end
end

function BattlefieldClient.Battle_HeadonTextColorFunction(nid)
	local self = BattlefieldClient;
	if(self.bf and self.my_side) then
		local other_side = self.bf:get_player_side(nid);
		if(other_side) then
			if(other_side == self.my_side) then
				return Player.HeadOnDisplayColor_Ally or "64 249 66"; -- ally color
			else
				return Player.HeadOnDisplayColor_Opponent or "255 64 64"; -- opponent color
			end
		end
	end

	if(not self.pending_nids) then
		self.pending_nids = {};
	end
	self.pending_nids[nid] = true;
end

-- private function: called in each framemove until unknown nid side is known. 
function BattlefieldClient.UpdatePendingNidHeadonTextColor()
	local self = BattlefieldClient;
	if(self.pending_nids) then
		if(self.bf and self.my_side) then
			local remove_list;
			local nid, _;
			for nid, _ in pairs(self.pending_nids) do
				local _player;
				_player = ParaScene.GetObject(Pet.GetUserCharacterName(nid));
				if(_player:IsValid()) then
					local other_side = self.bf:get_player_side(nid);
					if(other_side) then
						Player.ShowHeadonTextForNID(nid, _player);
						remove_list = remove_list or {};
						remove_list[nid] = true;
					end
				else
					remove_list = remove_list or {};
					remove_list[nid] = true;
				end
			end
			if(remove_list) then
				for nid, _ in pairs(remove_list) do
					self.pending_nids[nid] = nil;
				end
			end
		end
	end
end

-- call this to reset all state. 
function BattlefieldClient.Reset()
	local self = BattlefieldClient;
	NPL.load("(gl)script/apps/GameServer/BattlefieldService/GSL_BattleClient.lua");
	client = Map3DSystem.GSL.Battle.GSL_BattleClient.GetSingleton();
	client:ResetAllEventListeners();
	client:Reset()
	client:AddEventListener("normal_update", self.OnNormalUpdate, self);
	client:AddEventListener("realtime_update", self.OnRealtimeUpdate, self);
	self.my_side = nil;
	self.is_blocked = nil;
	self.start_count_down = nil;
	self.is_shown_finished = nil;
	self.closest_rp = nil;
	self.display_text = nil;
	self.bf = nil;
	self.pending_nids = nil;
end

-- get the born position
-- @param my_side: can be nil. it will use the current known side. 
function BattlefieldClient:GetMyBornPos(my_side)
	my_side = my_side or self.my_side;
	local world_info = WorldManager:GetCurrentWorld()
	local born_pos;
	if(my_side == 0) then
		born_pos = world_info.born_pos0 or world_info.born_pos;
	elseif(my_side == 1) then
		born_pos = world_info.born_pos1 or world_info.born_pos;
	else
		born_pos = world_info.born_pos;
	end
	return born_pos;
end

-- return nil if we are not in battle, or [0,1] if in battle. 
function BattlefieldClient:GetMySide()
	return self.my_side;
end

-- return nil if we are not in battle, or [0,1] if in battle. 
function BattlefieldClient:GetPlayerSide(nid)
	local self = BattlefieldClient;
	if(nid and self.bf and self.my_side) then
		local other_side = self.bf:get_player_side(nid);
		if(other_side) then
			return other_side;
		end
	end
end

-- private function to prepare the battle state.
function BattlefieldClient:PrepareBattle(scene, my_side, player, nid, bf)
	if(bf.is_started and self.is_blocked == false) then
		return
	end
	-- block user movement when battle has not begun. 
	if(self.my_side ~= my_side and my_side) then
		local born_pos = self:GetMyBornPos(my_side);
		
		self.my_side = my_side;
		if(born_pos) then
			-- block the user movement.  
			-- local player = Player.GetPlayer();
			-- teleport the user to one of the born position according to my_side 
			player:SetPosition(born_pos.x, born_pos.y, born_pos.z);
			if(born_pos.facing) then
				player:SetFacing(born_pos.facing);
			end
			local att = ParaCamera.GetAttributeObject();
			if(born_pos.CameraObjectDistance) then
				att:SetField("CameraObjectDistance", born_pos.CameraObjectDistance);
			end
			if(born_pos.CameraLiftupAngle) then
				att:SetField("CameraLiftupAngle", born_pos.CameraLiftupAngle);
			end
			if(born_pos.CameraRotY) then
				att:SetField("CameraRotY", born_pos.CameraRotY);
			end

			player:SetMovableRegion(born_pos.x, born_pos.y, born_pos.z, born_pos.radius or 10, 0, born_pos.radius or 10);
			self.is_blocked = true;

			-- display a green blocker in the 3d scene. 
			local obj = scene:GetObject("born_blocker");
			if(obj:IsValid()) then
				scene:DestroyObject("born_blocker");
			end
			obj = ObjEditor.CreateObjectByParams({
				name = "born_blocker",
				AssetFile = "character/v5/09effect/Common/SheXianGuang01_Xuanzhuan_Green.x", 
				x = born_pos.x,
				y = born_pos.y,
				z = born_pos.z,
				IsCharacter = true,
				scaling = 1,
			});
			scene:AddChild(obj);
		end
	end
	if(self.start_count_down ~= bf.start_count_down and bf.start_count_down) then
		self.start_count_down = bf.start_count_down;
		if(self.start_count_down < bf.start_time_after_full and bf:can_start()) then
			local params = {id="worldteam_timer", priority=0, color="255 0 0", scaling=1.2, bold=true, shadow=true,
					max_duration=5000, 
					label = format("%d秒后战斗将开始", math.floor(bf.start_count_down/1000) ) }
			BroadcastHelper.PushLabel(params);
		end
	end
	if(bf.is_started and self.is_blocked) then
		self.is_blocked = false;
		local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
			local scene = ParaScene.GetMiniSceneGraph(self.mini_scene_name);
			scene:DestroyObject("born_blocker");
			local player = Player.GetPlayer();
			player:SetMovableRegion(16000,0,16000, 16000,16000,16000);
		end})
		mytimer:Change(3000, nil)
	end
end

-- the normal update message
function BattlefieldClient:OnNormalUpdate(msg)
	local bf = msg.bf;
	local raw_bf = msg.raw_bf;
	local player = Player.GetPlayer();
	local nid = tostring(System.User.nid);
	local my_side = bf:get_player_side(nid)
	self.bf = bf;

	local scene = ParaScene.GetMiniSceneGraph(self.mini_scene_name);
	local closest_rp;
	if(bf.is_finished) then
		if(not self.is_shown_finished) then
			-- when battle is finished, reclaim its cooldown by saving to local user data
			MyCompany.Aries.Player.SaveLocalData("BattlefieldClient", {is_finished=true})

			self.is_shown_finished = true;

			-- show the stat page. 
			BattleProgressBar.ShowStatPage();
			
			--local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
				--WorldManager:TeleportBack();
			--end})
			--mytimer:Change(20000, nil)
			BattleProgressBar.OnRefreshData(bf, raw_bf, closest_rp);
		end
		return;
	end

	if(bf.is_started and my_side) then
		if(self.is_blocked) then
			-- do not block any user movement when battle is started. 
			self.is_blocked = false;
			scene:DestroyObject("born_blocker");
			player:SetMovableRegion(16000,0,16000, 16000,16000,16000);
			BroadcastHelper.PushLabel({id="worldteam", priority=1, max_duration=5000, scaling=1.1, bold=true, shadow=true,
				label = "战斗已经开始！ 开始行动吧", }); 
		elseif(self.is_blocked == nil) then
			BroadcastHelper.PushLabel({id="worldteam", priority=1, max_duration=5000, scaling=1.1, bold=true, shadow=true,
				label = "中途加入战斗！ 开始行动吧", }); 
			self:PrepareBattle(scene, my_side, player, nid, bf);
		end

		closest_rp = self:RefreshTower(bf, player, scene, my_side);
	else
		
		if(my_side) then
			BroadcastHelper.PushLabel({id="worldteam", priority=1, max_duration=100000, scaling=1.1, bold=true, shadow=true,
				label = format("请等待双方人员加入, 至少%d人后开启",bf.can_start_players_count*0.5), }); 
		else
			BroadcastHelper.PushLabel({id="worldteam", priority=1, max_duration=100000, scaling=1.1, bold=true, shadow=true,
				label = "正在排队中, 请等待被分配阵营 ...", }); 
		end
		self:PrepareBattle(scene, my_side, player, nid, bf)

		if(client and System.options.isAB_SDK) then -- and System.User.nid == 14861822
			-- this is tricky: if it is SDK version, we will send a message to server to force it start. 
			_guihelper.MessageBox("SDK版本可以不用等待人满开启， 是否现在强制开启?", function()
				LOG.std(nil, "system", "BattlefieldClient", "force start battle");
				client:SendMessage("StartGame", {password="1234567"});
			end)
		end
	end

	-- update the page
	BattleProgressBar.OnRefreshData(bf, raw_bf, closest_rp);
	-- called every framemove
	BattlefieldClient.UpdatePendingNidHeadonTextColor();
end

-- the realtime message. 
function BattlefieldClient:OnRealtimeUpdate(msg)
	local msg = msg.msg;
	LOG.std(nil, "system", "BattlefieldClient", {"real time message from server ", msg});
	if(msg) then
		local msg_type = msg.type;
		if(msg_type == "add_loots") then
			local adds = {};
			if(msg.loots) then
				local gsid, count;
				for gsid, count in pairs(msg.loots) do
					if(count > 0) then
						adds[#adds+1] = {gsid = gsid, cnt = count}
					end
				end
			end
			LOG.std(nil, "system", "BattlefieldClient", {"add loots", adds});
			Dock.OnExtendedCostNotification({adds = adds});
		end
	end
end

local rp_text_map = {
	[1] = "南方高地",
	[2] = "北方高地",
	[3] = "英雄台",
	[4] = "南方盆地",
	[5] = "北方盆地",
}
--local rp_text_map = {
	--[1] = "资源点1",
	--[2] = "资源点2",
	--[3] = "资源点3",
	--[4] = "资源点4",
	--[5] = "资源点5",
--}
-- return true if succeed. 
local function rebuild_arena_to_rp_map(bf)
	local all_arenas = {};
	local arena_data_map = MsgHandler.Get_arena_meta_data();
	local arena_id, data;
	for arena_id, data in pairs(arena_data_map) do
		all_arenas[#all_arenas+1] = tonumber(arena_id);
	end
	table.sort(all_arenas, function(a, b) return a<b; end);
	
	LOG.std(nil, "system", "BattlefieldClient", {"resource point to arena id reassigned", all_arenas})

	-- very tricky here: this will remove any id that is not consecutive in 5
	local index
	while (all_arenas[1] and all_arenas[5] and (all_arenas[5]-all_arenas[1]) >= 5) do
		table.remove(all_arenas, 1);
		LOG.std(nil, "system", "BattlefieldClient", {"resource point to arena id reassigned second pass: ", all_arenas})
	end
	
	if(#all_arenas >= 5) then
		-- the arena_data example is like this
		-- {slotbuffs={},p_x=1120.93,p_y=-9.42, p_z=1021.82,bIncludedMyselfInArena=false,aura="",arena_id=1092,mode="free_pvp",pips_power={0,0,0,0,0,0,0,0,},players={{},{},{},{},{},{},{},{},},mobs={},bIncludedAnyAliveMob=false,bPlayersFull=false,fledslots={},bIncludedAnyPlayer=false,pips={0,0,0,0,0,0,0,0,},bMyselfFarSideInArena=false,arrow_position=0,slotunits={},},}
		local i;
		for i=1,5 do 
			local rp = bf:get_resource_point(i);
			if(rp) then
				rp.arena_id = all_arenas[i];
				rp.text = rp_text_map[i] or ("资源点"..i);
			end
		end
		return true;
	end
end

-- can be 1 or 2.  1 is preferred. 
local flag_count_per_rp = 1;

-- return flag position x,y,z
local function GetTowerFlagPos(x,y,z, my_side, flag_index)
	if(flag_index == 1) then
		return x,y,z-27*if_else(my_side==0, 1, -1);
	elseif(flag_index == 2) then
		return x,y,z+27*if_else(my_side==0, 1, -1);
	else
		return x,y,z;
	end
end

-- 3 state flags: 
local function GetTowerFlagAssetByOwner(owner, my_side)		
	if(owner == my_side) then
		return "model/06props/v5/06combat/Common/WarBanner/WarBanner_Green.x";
	elseif(owner ~= nil) then
		return "model/06props/v5/06combat/Common/WarBanner/WarBanner_Red.x";
	else
		return "model/06props/v5/06combat/Common/WarBanner/WarBanner_Gray.x";
	end
end

local offset_text = nil; -- {y=-1}
-- return text, color, offset
local function GetTowerFlagTextByOwner(rp, my_side)
	if(rp.owner == nil) then
		return format("%s\n争夺中%d%%", rp.text or "资源点", ((rp.cursor_percentage or 0)*if_else(my_side == 0, -1, 1)+100)*0.5), "148 148 148", offset_text;
	elseif(rp.owner == my_side) then
		return format("%s\n我方占领中", rp.text or "资源点"), "0 255 0", offset_text
	else
		return format("%s\n对方占领中", rp.text or "资源点"), "255 0 0", offset_text
	end
end		

-- refresh the tower display
-- @return the closeset resouce point if any. 
function BattlefieldClient:RefreshTower(bf, player, scene, my_side)
	if(my_side == nil) then
		return;
	end
	local p_x,p_y,p_z = player:GetPosition();
	local nearest_rp;
	local arena_data_map = MsgHandler.Get_arena_meta_data();
	local closest_rp;
	local closest_arena_dist_sq;
	local i;
	for i=1,5 do 
		local rp = bf:get_resource_point(i);
		if(rp) then
			if(not rp.arena_id) then
				if( not rebuild_arena_to_rp_map(bf)) then
					break;
				end
			end
			local arena;
			if(rp.arena_id) then
				arena = arena_data_map[rp.arena_id];
			end
			if(arena and arena.p_x) then
				local arena_distance_sq = (arena.p_x - p_x) * (arena.p_x - p_x) + (arena.p_z - p_z) * (arena.p_z - p_z);
				if(not closest_arena_dist_sq or closest_arena_dist_sq>arena_distance_sq) then
					closest_arena_dist_sq = arena_distance_sq;
					closest_rp = rp;
				end
				local str_owner = tostring(rp.owner)
				if(rp.display_owner ~= str_owner) then
					rp.display_owner = str_owner;
					local flag_index
					for flag_index = 1,flag_count_per_rp do
						local tower_flag_name = "tower"..flag_index..i;

						local asset_file = GetTowerFlagAssetByOwner(rp.owner, my_side);
						local flag_x, flag_y, flag_z = GetTowerFlagPos(arena.p_x, arena.p_y, arena.p_z, my_side, flag_index);

						local obj = scene:GetObject(tower_flag_name);
					
						if(obj:IsValid()) then
							scene:DestroyObject(tower_flag_name);
						end
						obj = ObjEditor.CreateObjectByParams({
							name = tower_flag_name,
							AssetFile = asset_file, 
							x = flag_x,
							y = flag_y,
							z = flag_z,
							scaling = 1,
							EnablePhysics = false,
						});
						obj:SetField("progress", 1);
						scene:AddChild(obj);
					end
					
					LOG.std(nil, "debug", "BattlefieldClient", "tower owner changed rp:%d  new owner is %s", i, str_owner);
				end
				local str_text, str_color, str_offset = GetTowerFlagTextByOwner(rp, my_side);
				if( rp.display_text ~= str_text and str_text and str_color) then
					rp.display_text = str_text;
					local flag_index
					for flag_index = 1,flag_count_per_rp do
						local tower_flag_name = "tower_text"..flag_index..i;
						local flag_x, flag_y, flag_z = GetTowerFlagPos(arena.p_x, arena.p_y, arena.p_z, my_side, flag_index);
						local obj = scene:GetObject(tower_flag_name);
				
						if(not obj:IsValid()) then
							obj = ObjEditor.CreateObjectByParams({
									name = tower_flag_name,
									AssetFile = "character/common/dummy/cube_size/cube_size.x", 
									x = flag_x,
									y = flag_y,
									z = flag_z,
									scaling = 12,
									IsCharacter=true,
								});
							scene:AddChild(obj);
						end
						System.ShowHeadOnDisplay(true, obj, str_text, str_color, str_offset);
					end
				end
			end
		end
	end
	self.closest_rp = closest_rp;
	return closest_rp;
end