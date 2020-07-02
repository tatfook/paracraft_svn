--[[
Title: Follow a given player at a given distance
Author(s): LiXizhi
Date: 2011/5/12
Desc: Usually we can apply this AI to the current player to let it follow another player within a given distance. This works with GSL game client
The follow algorithm is like below:
 we will remember the target player position track. 
 the follower will always be on target player's movement track and try to keep a specified distance from it(interpolating the track). 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Scene/AutoFollowAI.lua");
local AutoFollowAI = commonlib.gettable("MyCompany.Aries.AI.AutoFollowAI");
AutoFollowAI:Register(slash_command);
-- follow a given player at 1.5 meters
AutoFollowAI:Follow("follow", target_nid, 1.5)
-- do not follow any player
AutoFollowAI:Follow("follow", nil)
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/ide/math/vector.lua");
NPL.load("(gl)script/ide/TooltipHelper.lua");
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");
local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");

local vector3d = commonlib.gettable("mathlib.vector3d");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local math_abs = math.abs;

NPL.load("(gl)script/apps/GameServer/common/ValueTracker.lua");
local AutoFollowAI = commonlib.createtable("MyCompany.Aries.AI.AutoFollowAI", {
	last_follow_nid = nil,
	last_position = {},
	follow_style = "follow", 
	-- how many meter to spy above the head of the target player
	spy_hover_height = 20,
	-- if the target player position is this far from us, we will teleport instead of move. 
	teleport_dist = 20,
	-- preferred distance from the target player
	dist = 1,
	default_dist = 1,
	-- max movement time, if the player moves after this time, we will display a dialog to ask the user whether to cancel following. 
	max_movement_time = 7000,
});

-------------------------------------
-- PlayerTrack: a list of connected line vectors with variable length. and we can interpolate by dist a position on the segment of lines.
-------------------------------------
local PlayerTrack = commonlib.inherit();
function PlayerTrack:ctor()
	self.data = commonlib.List:new();
	self.max_count = self.max_count or 50
end

-- push a new position.
function PlayerTrack:PushPosition(x,y,z)
	local last = self.data:first();
	if(not last or (last.pos.x ~= x or last.pos.y ~= y or last.pos.z ~= z)) then
		local pos = vector3d:new(x,y,z);
		local new_data = {pos = pos}
		if(last and last.pos) then
			local diff_pos = last.pos - pos;
			new_data.diff_len = diff_pos:length();
			if(new_data.diff_len < 0.5) then
				-- ignore this new position if it only diffs 0.5 with previous point.
				return;
			end
			new_data.diff_pos = diff_pos;
		end
		self.data:push_front(new_data);

		-- too many records? delete them
		if(self.data:size()>self.max_count) then
			self.data:remove(self.data:last());
		end
		return true;
	end
end

-- get a position that is dist away from the last cached position. 
-- @return x,y,z if exist.
function PlayerTrack:GetPosition(dist)
	local item = self.data:first();
	local from_dist = 0;
	local item_from, item_to;
	while (item) do
		if(item.diff_len)  then
			if((from_dist+item.diff_len)<dist) then
				from_dist = from_dist + item.diff_len;
				item_from = item;
				item = self.data:next(item)
			else
				item_to = item;
				break;
			end
		else
			item_to = item;
			break;
		end
	end
	if(item_to) then
		item_from = self.data:next(item_to);
		if(item_from) then
			local pos = ((item_to.pos - item_from.pos)*((item_to.diff_len-(dist-from_dist))/item_to.diff_len))+item_from.pos;
			return pos:get();
		else
			return item_to.pos:get();
		end
	elseif(item_from) then
		return item_from.pos:get();
	end
end

function PlayerTrack:Reset()
	self.data:clear();
end

-------------------------------------
-- follow command
-------------------------------------
local cmd_follow = {};
local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");
local GSL_client = commonlib.gettable("Map3DSystem.GSL_client");

-- @param follow_style: "spy" or "follow". if spy we will teleport to the head of the player. 
--  if follow we will find the target
-- @param target_nid: nid of the target player to follow. if nil it cancels following. 
function cmd_follow:run(follow_style, target_nid)
	return AutoFollowAI:Follow(follow_style, target_nid);
end

function cmd_follow.handler(cmd_name, cmd_text, cmd_params)
	-- follow the currently selected player or a given nid. 
	return cmd_follow:run(cmd_name, cmd_params.target or cmd_params.value or TargetArea.TargetNID)
end

-------------------------------------------
-- a class of auto follow
-------------------------------------------

-- call this function to register the slash command and init
function AutoFollowAI:Register(slash_command)
	if(self.isInitialized) then
		return;
	end
	self.isInitialized = true;
	-- follow command
	slash_command:RegisterSlashCommand({name="follow", quick_ref="/follow [nid]", desc="local commands", handler = cmd_follow.handler});
	-- spy command
	slash_command:RegisterSlashCommand({name="spy", quick_ref="/spy [nid]", desc="local commands", handler = cmd_follow.handler});
end

-- create get the player position track 
function AutoFollowAI:GetPlayerTrack()
	self.player_track = self.player_track or PlayerTrack:new({max_count = 50})
	return self.player_track;
end

-- unmount from target player just in case it is a multi-player vehicle.
function AutoFollowAI:TryUnmountFromTarget(last_follow_nid)
	if(last_follow_nid and last_follow_nid~="nil") then
		-- unmount from follow target if we are currently mounted on it.  
		local player = Player.GetPlayer();
		local char = ParaScene.GetPlayer():ToCharacter();
		local BeingMountedObj = player:GetRefObject(0);
		local target = ParaScene.GetObject(tostring(last_follow_nid));

		if(BeingMountedObj and target:IsValid() and target:equals(BeingMountedObj)) then
			player:AddEvent("umnt", 0, true);
		end
	end
end

local g_MountIDs  = {0, 20,21,22,23,};

-- mount on target player just in case it is a multi-player vehicle.
-- @param slot_id: if nil, the next free slot is used. 
-- @return true: if we are mounted on the vehicle
function AutoFollowAI:CheckMountMultiSlot(last_follow_nid, slot_id)
	if(Player.IsInCombat()) then
		self:TryUnmountFromTarget(last_follow_nid);
	elseif(last_follow_nid and not Player.GetDriverObject():IsValid()) then
		local player = Player.GetPlayer();
		
		local target_player = ParaScene.GetObject(tostring(last_follow_nid));

		if(not slot_id) then
			local jc = TeamClientLogics:GetJC()
			if(jc) then
				local target_idx = jc:GetTeamMemberIndexByNid(last_follow_nid);
				local my_idx = jc:GetTeamMemberIndexByNid(jc.nid);
				if(my_idx and target_idx and my_idx~= target_idx) then
					if(my_idx < target_idx) then
						slot_id = my_idx + 1;
					else
						slot_id = my_idx;
					end
				else
					return
				end
			end
		end

		if(target_player:IsValid()) then
			local BeingMountedObj = player:GetRefObject(0);
			if(target_player:HasAttachmentPoint(g_MountIDs[slot_id])) then
				if(not player:ToCharacter():IsMounted()) then
					if(System.options.version == "kids") then
						player:AddEvent(format("mont %s %d character/Animation/v5/DefaultMount.x", last_follow_nid, slot_id-1), 0, true);
					else
						player:AddEvent(format("mont %s %d character/Animation/v5/DefaultMount_teen.x", last_follow_nid, slot_id-1), 0, true);
					end
					-- ccs strings will be automatically broadcasted via gsl. 
					return true;
				end
			else
				if(target_player:equals(BeingMountedObj)) then
					player:AddEvent("umnt", 0, true);
				end
			end
		end
	end
end


-- @param follow_style: "spy" or "follow". if spy we will teleport to the head of the player. 
--  if follow we will find the target
-- @param target_nid: nid of the target player to follow. if nil it cancels following. 
-- @param target_dist: distance to the target during the following
-- @return a text message.
function AutoFollowAI:Follow(follow_style, target_nid, target_dist)
	self.target_in_combat = nil;
	local last_follow_nid = self.last_follow_nid;
	self.last_follow_nid = target_nid;
	if(not target_dist) then
		self.dist = self.default_dist;
	else
		self.dist = target_dist;
	end
	
	self.last_follow_nid = tostring(self.last_follow_nid);
	self:Reset();
	self.follow_style = follow_style;
		
	if(self.last_follow_nid == "nil") then
		if(self.mytimer) then
			self.mytimer:Change();
		end

		self:TryUnmountFromTarget(last_follow_nid);

		return "follow target canceled"
	else
		self.force_follow = true;
		self.mytimer = self.mytimer or commonlib.Timer:new({callbackFunc = function(timer)
			local agent
			self.target_in_combat = false;
			if(self.last_follow_nid) then
				agent = GSL_client:FindAgent(self.last_follow_nid);

				local jc = TeamClientLogics:GetJC()
				if(jc and not jc:GetTeamMemberByNid(self.last_follow_nid)) then
					-- if no longer team leader cancel it. 
					self:Follow("follow", nil);
				end
			end
			if(agent and agent.y) then
				self.has_asked_position = false;
				local bPositionChanged;
				if(self.last_position.x ~= agent.x or self.last_position.y ~= agent.y or self.last_position.z ~= agent.z) then
					self.last_position.x = agent.x;
					self.last_position.y = agent.y;
					self.last_position.z = agent.z;
					if(self.follow_style == "spy") then
						-- the simple spy command only used by GM
						if(Player.IsInCombat()) then
							return
						end
						Player.GetPlayer():SetPosition(agent.x, agent.y+self.spy_hover_height, agent.z);	
					else
						bPositionChanged = true;
					end
				end
				-- cancel move if detected. 
				self:UserMoveCancelDetection();
					
				local world_info = WorldManager:GetCurrentWorld();
				if(world_info.can_teleport or world_info.can_follow) then
					local target = ParaScene.GetObject(tostring(self.last_follow_nid));
					if(target:GetDynamicField("IsInCombat", false)) then
						self.target_in_combat = true;
						local x, y, z = target:GetPosition();
						local player = Player.GetPlayer();
						if(not player:GetDynamicField("IsInCombat", false)) then
							--BroadcastHelper.Clear("entercombat_disabled_tip");
							--BroadcastHelper.Clear("auto_follow");
							-- self:TryUnmountFromTarget(self.last_follow_nid);

							Player.GetPlayer():SetPosition(x,y,z);
						end
						local target_player = ParaScene.GetObject(tostring(self.last_follow_nid));
						if(target_player:IsValid() and target_player:HasAttachmentPoint(20)) then
							self:Follow(nil);
						end
					else
						self.target_in_combat = false
						-- only do smooth follow when we are not mounted on target's multi-player vehicle
						if(not self:CheckMountMultiSlot(self.last_follow_nid, nil)) then
							-- smooth follow implementation
							self:DoSmoothFollowByPoint(agent.x, agent.y, agent.z, bPositionChanged)	
						end
					end
				else
					BroadcastHelper.PushLabel({id="auto_follow", label = "当前世界不能跟随目标, 已经禁止", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
					self:Follow(nil);
				end
			else
			
				local do_not_teleport;
				local cur_world = WorldManager:GetCurrentWorld();
				if(LobbyClientServicePage.GetRoomID) then
					local login_room_id = LobbyClientServicePage.GetRoomID();
					local game_info = LobbyClient:GetCurrentGame();
					if(login_room_id and game_info and game_info.keyname ~= cur_world.name) then
						local game_world_info = WorldManager:GetWorldInfo(game_info.keyname);
						if(game_world_info and game_world_info.force_teamworld) then
							if(not self.force_follow) then
								do_not_teleport = true;
							else
								self.force_follow = nil;
							end
						end
					end
				end

				if( cur_world.force_teamworld or do_not_teleport) then
					-- do not ask for its position if the current world is force_teamworld
				else
					-- note: we need to ask the target player where it is. and teleport. 
					if(not self.has_asked_position) then
						self.has_asked_position = true;
						local jc = TeamClientLogics:GetJC()
						if(jc and jc:GetTeamMemberByNid(self.last_follow_nid)) then
							-- only ask if target is inside the current team.
							if (not MyCompany.Aries.ExternalUserModule:CanViewUser(self.last_follow_nid)) then
								BroadcastHelper.PushLabel({id="auto_follow", label = "非同区用户不能跟随, 已经禁止", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
								self:Follow(nil);
								return
							end
							TeamClientLogics:SendTeamChatMessage({type="query_address", nid=self.last_follow_nid}, true)
						end
					end
				end
			end
		end})
		if(self.follow_style == "spy") then
			self.mytimer:Change(30, 3000);
		else
			self.mytimer:Change(30, 200);
		end
		return "follow target set "..self.last_follow_nid;
	end
end

-- reply for "query_address" from TeamClientLogics
function AutoFollowAI:OnReplyLastAddressRequest(address)
	if(address) then
		local world = WorldManager:GetWorldInfo(address.name);
		if(world) then
			local cur_world = WorldManager:GetCurrentWorld();
			if( world.force_teamworld or (cur_world.can_save_location and world.can_save_location) ) then
				if( world.force_teamworld ) then
					NPL.load("(gl)script/apps/Aries/CombatRoom/WorldTeamQuest.lua");
					local WorldTeamQuest = commonlib.gettable("MyCompany.Aries.CombatRoom.WorldTeamQuest");
					WorldTeamQuest.CloseWindow();
					_guihelper.CloseMessageBox();
				end

				NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
				local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
				GathererBarPage.Start({ duration = 2000, title = "准备进入世界", disable_shortkey = true, align="_ct", x=-100, y=-100,},nil,function()
					WorldManager:TeleportByWorldAddress(address);
				end);
				
			else
				BroadcastHelper.PushLabel({id="auto_follow", label = format("您跟随的目标已经进入[%s]", world.world_title), max_duration=8000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,
					background = "Texture/Aries/Common/gradient_white_32bits.png",background_color = "#1f3243",
				});
			end
		end
	end
end

-- check whether the user moves, if so, and cancel following
function AutoFollowAI:UserMoveCancelDetection()
	-- check whether the user moves, and cancel following if so.
	if(Player.IsInCombat()) then
		return
	end
		
	local bUserMovedSinceLastFollow;
	if(self.last_move_count and self.last_move_count ~=Map3DSystem.HandleMouse.GetMovementCount()) then
		self.last_move_count = Map3DSystem.HandleMouse.GetMovementCount();
		bUserMovedSinceLastFollow = true;
	elseif(ParaScene.GetPlayer():GetField("GetLastWayPointType", 0) == 3) then
		-- COMMAND_MOVING is 3
		-- user is using other method to move the character such as using keyboard or mouse key combo. 
		bUserMovedSinceLastFollow = true;
	end
	if(bUserMovedSinceLastFollow) then
		local cur_world = WorldManager:GetCurrentWorld();
		if( cur_world.force_teamworld) then
			BroadcastHelper.PushLabel({id="teamworld", label = "当前世界必须以队伍模式行动", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});

			-- this will force the player to follow the target. 
			self.last_position.y = nil;
			
			--_guihelper.MessageBox("当前世界必须以队伍模式行动, 是否离开世界？", function(res)
					--if(res and res == _guihelper.DialogResult.Yes) then
						---- pressed YES
						--self:Follow("follow", nil);
						--WorldManager:TeleportBack();
					--end
				--end, _guihelper.MessageBoxButtons.YesNo);
		else
			_guihelper.MessageBox("是否停止自动跟随？", function(res)
					if(res and res == _guihelper.DialogResult.Yes) then
						-- pressed YES
						self:Follow("follow", nil);
					end
				end, _guihelper.MessageBoxButtons.YesNo);
		end
	end

	--[[
	-- this is old raw method to detect if user moved. it has the drawback of being unable to detect if the target moves very often.
	local x,y,z = Player.GetPlayer():GetPosition();
	if(not self.move_x or not self.move_y or not self.move_z) then
		self.move_x, self.move_y, self.move_z = x,y,z;
	elseif( math_abs(x-self.move_x)>0.5 or math_abs(z-self.move_z)>0.5) then
		self.move_x, self.move_y, self.move_z = nil,nil,nil;
		_guihelper.MessageBox("是否停止自动跟随？", function()
			self:Follow("follow", nil);
		end)
	end]]
end

-- the internal implementation to move to a position. 
function AutoFollowAI:DoSmoothFollowByPoint(agent_x, agent_y, agent_z, bPositionChanged)
	if(bPositionChanged) then
		local player_track = self:GetPlayerTrack();
		player_track:PushPosition(agent_x, agent_y, agent_z);
		if(Player.IsInCombat()) then
			return
		end
		local p_x, p_y, p_z = player_track:GetPosition(self.dist);
		if(p_x and p_y and p_z) then
			local x,y,z = Player.GetPlayer():GetPosition();
			dist_to_player = math.max(math_abs(x-p_x), math_abs(y-p_y), math_abs(z-p_z));
			if(dist_to_player>self.teleport_dist) then
				ParaScene.GetPlayer():SetPosition(p_x, p_y, p_z);
			else
				if( (math_abs(x-p_x)+math_abs(y-p_y)+math_abs(z-p_z)) > 0.1) then
					self.last_move_count = Map3DSystem.HandleMouse.MovePlayerToPoint(p_x, p_y, p_z);
				end
			end
		end
	end
end

-- whether we can enter combat. 
function AutoFollowAI:CanEnterCombat()
	if(System.options.version == "kids") then
		return true;
	else
		local target_nid = self:GetFollowTarget()
		if(target_nid) then
			return self.target_in_combat;
		end
	end
	return true;
end

-- get the nid of the follow target
-- if no active target, return nil.
function AutoFollowAI:GetFollowTarget()
	if(self.last_follow_nid and self.last_follow_nid ~= "nil") then
		if(self.mytimer and self.mytimer:IsEnabled()) then
			return self.last_follow_nid;
		end
	end
end

-- mark the start of the movement. call this whenever the user automatically moves.
function AutoFollowAI:StartMovement()
	if(self.movement_timer) then
		self.bAutoMovementStarted = true;
		self.move_x, self.move_y, self.move_z = nil,nil,nil;
		self.movement_timer:Change(self.max_movement_time, nil);
	end
end

-- whether automatica movement is in progress. 
function AutoFollowAI:HasAutoMovement()
	return self.bAutoMovementStarted;
end

function AutoFollowAI:Reset()
	local player_track = self:GetPlayerTrack();
	player_track:Reset();
	self.last_position = {};
	self.has_asked_position = false;
	self.movement_timer = self.movement_timer or commonlib.Timer:new({callbackFunc = function(timer)
		self.bAutoMovementStarted = false;
	end});
end