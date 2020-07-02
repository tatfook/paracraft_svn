--[[
Title: quest path finder 
Author(s): Clayman
Date: 2011/9/2
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestPathfinderNavUI.lua");
MyCompany.Aries.Quest.QuestPathfinderNavUI.CreatePage();
MyCompany.Aries.Quest.QuestPathfinderNavUI.ShowPage(true);
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestPathFinder.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPane.lua");
local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
local QuestPathfinderNavUI = commonlib.gettable("MyCompany.Aries.Quest.QuestPathfinderNavUI");
local Player = commonlib.gettable("MyCompany.Aries.Player");
NPL.load("(gl)script/ide/Director/CardMovieHelper.lua");
local CardMovieHelper = commonlib.gettable("Director.CardMovieHelper");
NPL.load("(gl)script/apps/Aries/mcml/pe_goal_pointer.lua");
local goal_manager = commonlib.gettable("MyCompany.Aries.mcml_controls.goal_manager");
local BasicArena = commonlib.gettable("MyCompany.Aries.Quest.NPCs.BasicArena");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local Pet = commonlib.gettable("MyCompany.Aries.Pet");
NPL.load("(gl)script/apps/Aries/Quest/QuestLinksViewPage.lua");
local QuestLinksViewPage = commonlib.gettable("MyCompany.Aries.Quest.QuestLinksViewPage");
local math_abs = math.abs;

-- this attritbute can only be set at the beginning of the game. to enable or disable this tracker. 
-- whether full 3d path finding is disabled. 
QuestPathfinderNavUI.enable_3d_tracker = false;
-- if distance is bigger than 100, do teleport to save player time. 
-- this params is only used when QuestPathfinderNavUI.enable_3d_tracker is false. 
QuestPathfinderNavUI.max_walk_dist_during_pathfinding = 100;

QuestPathfinderNavUI.stopped = false;
--QuestPathfinderNavUI.pathfinder = commonlib.gettable("MyCompany.Aries.Quest.QuestPathFinder");
QuestPathfinderNavUI.pathfinder = nil;
--QuestPathfinderNavUI.pathfinder.navInfoCallback = QuestPathfinderNavUI.RefreshDisplay;
QuestPathfinderNavUI.page = nil;
QuestPathfinderNavUI.currentDir = 0;
QuestPathfinderNavUI.IsArrowVisible = true;

local page_3d; 
local page_width = 280;
function QuestPathfinderNavUI.CreatePage()
	if(not QuestPathfinderNavUI.enable_3d_tracker) then
		-- enable anyway
		QuestPathfinderNavUI.stopped = false;
		QuestPathfinderNavUI.pathfinder = commonlib.gettable("MyCompany.Aries.Quest.QuestPathFinder");
		return;
	end

	local _parent =  ParaUI.GetUIObject("AriesQuestArea3D");
	if(not _parent:IsValid()) then
		_parent = ParaUI.CreateUIObject("container", "AriesQuestArea3D", "_ctb", 0, -66, page_width, 90+60);
		_parent.background = "";
		_parent.zorder = -2;
		_parent:GetAttributeObject():SetField("ClickThrough", true);
		_parent:AttachToRoot();
		_parent.visible = false;
	
		page_3d = page_3d or Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Quest/QuestPathfinderNavUI.html",click_through = true,});
	
		-- one can create a UI instance like this. 
		page_3d:Create("Aries_QuestArea_3d_mcml", _parent, "_fi", 0, 0, 0, 0);
	else
		if(QuestPathfinderNavUI.page)then
			QuestPathfinderNavUI.page:CloseWindow();
		end
		page_3d:Create("Aries_QuestArea_3d_mcml", _parent, "_fi", 0, 0, 0, 0);
	end
	
	--[[System.App.Commands.Call("File.MCMLWindowFrame",{
		url = "script/apps/Aries/Quest/QuestPathfinderNavUI.html",
		name = "QuestPathfinderNavUI.ShowPage",
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = false,
		enable_esc_key = false,
		bShow = true,
		click_through = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = false,
				directPosition = true,
					align = "_ctb",
					x = 22,
					y = -90,
					width = 64,
					height = 64,
		});]]
end
 
function QuestPathfinderNavUI.OnInit()
	QuestPathfinderNavUI.page = document:GetPageCtrl();

	QuestPathfinderNavUI.GetTimer():Change();
	QuestPathfinderNavUI.stopped = false;
	QuestPathfinderNavUI.pathfinder = commonlib.gettable("MyCompany.Aries.Quest.QuestPathFinder");
	QuestPathfinderNavUI.pathfinder.navInfoCallback = QuestPathfinderNavUI.RefreshDisplay;
	QuestPathfinderNavUI.currentDir = 0;
end

function QuestPathfinderNavUI.IsInitialized()
	return QuestPathfinderNavUI.pathfinder~=nil;
end

-- public method
function QuestPathfinderNavUI.RefreshPage(bShow)
	if(not QuestPathfinderNavUI.enable_3d_tracker) then
		return;
	end

	if(bShow)then
		if(QuestPathfinderNavUI.page == nil)then
			if(System.options.version == "kids") then
				return;
			end
			QuestPathfinderNavUI.CreatePage();
		end
		QuestHelp.ShowHideAreaTip(true);
		QuestPathfinderNavUI.pathfinder:OnHideUI(false);
		local scene = ParaScene.GetMiniSceneGraph("QuestPathFinderArrow");
		if(scene:IsValid()) then
			local _this=scene:GetObject("NavArrows");
			if(_this:IsValid()) then
				_this:SetVisible(false);
			end
		end
	else
		QuestHelp.ShowHideAreaTip(false);
		if(QuestPathfinderNavUI.pathfinder)then
			QuestPathfinderNavUI.pathfinder:OnHideUI(true);
		end
	end
end

function QuestPathfinderNavUI.ShowPage(bShow)
	if(not QuestPathfinderNavUI.enable_3d_tracker) then
		return;
	end

	if(bShow)then
		if(QuestPathfinderNavUI.page == nil)then
			if(System.options.version == "kids") then
				return;
			end
			QuestPathfinderNavUI.CreatePage();
		end
		ParaUI.GetUIObject("AriesQuestArea3D").visible = true;
		QuestHelp.ShowHideAreaTip(true);
		QuestPathfinderNavUI.pathfinder:OnHideUI(false);
		local scene = ParaScene.GetMiniSceneGraph("QuestPathFinderArrow");
		if(scene:IsValid()) then
			local _this=scene:GetObject("NavArrows");
			if(_this:IsValid()) then
				_this:SetVisible(false);
			end
		end
	else
		QuestHelp.ShowHideAreaTip(false);
		if(QuestPathfinderNavUI.pathfinder)then
			QuestPathfinderNavUI.pathfinder:OnHideUI(true);
		end
		ParaUI.GetUIObject("AriesQuestArea3D").visible = false;
	end
	
end

function QuestPathfinderNavUI.ClosePage()
	if(System.options.version == "kids") then
		return;
	end
	QuestPathfinderNavUI.GetTimer():Change();
	QuestPathfinderNavUI.stopped = true;
		
	if(QuestPathfinderNavUI.page)then
		QuestPathfinderNavUI.page:CloseWindow();
		-- QuestPathfinderNavUI.page = nil;
	end
	QuestPathfinderNavUI.pathfinder = nil;
end

function QuestPathfinderNavUI.RecreatePage()
	if(page_3d) then
		local _parent = ParaUI.GetUIObject("AriesQuestArea3D")
		if(_parent:IsValid())then
			if(QuestPathfinderNavUI.page)then
				QuestPathfinderNavUI.page:CloseWindow();
			end
			page_3d:Create("Aries_QuestArea_3d_mcml", _parent, "_fi", 0, 0, 0, 0);
		end
	end
end

function QuestPathfinderNavUI.GetTimer()
	if(not QuestPathfinderNavUI.timer)then
		QuestPathfinderNavUI.timer = commonlib.Timer:new({callbackFunc = QuestPathfinderNavUI.OnTimer});
	end
	return QuestPathfinderNavUI.timer;
end

-- call this function when world is switched.  Since different target are tracked differently in different world. 
-- currently this function is called in MapArea.OnActivateDesktop
function QuestPathfinderNavUI.RefreshTarget()
	if(QuestPathfinderNavUI.IsInitialized()) then
		local quest = QuestPathfinderNavUI.GetTargetQuest()
		QuestPathfinderNavUI.SetTargetQuest(quest);
	end
end

local last_quest = {};
local bounce_timer;
local tip_display_count = 0;
local tip_elapsed_time = 0;
local max_tip_time = 10000;
local last_player_pos;

function QuestPathfinderNavUI.OnCloseTip()
	if(QuestPathfinderNavUI.page)then
		--local marker = QuestPathfinderNavUI.page:FindControl("marker");
		--if(marker) then
			--marker.visible = false;
		--end
		if(QuestPathfinderNavUI.bounce_timer) then
			QuestPathfinderNavUI.bounce_timer:Change();
		end
	end
end

function QuestPathfinderNavUI.SetTargetQuest(quest)
	if(not QuestPathfinderNavUI.enable_3d_tracker) then
		
		if(QuestPathfinderNavUI.IsInitialized()) then
			if(QuestPathfinderNavUI.pathfinder:SetTarget(quest))then
				QuestPathfinderNavUI.GetTimer():Change(0,100);
				QuestPathfinderNavUI.stopped = false;
			end
		end

		if(Player.GetLevel() <= 6) then
			local last_quest = QuestPathfinderNavUI.last_quest;
			if( (last_quest == nil) or 
				(quest and (last_quest.targetName~= quest.targetName or last_quest.find_path_questid~= quest.find_path_questid or last_quest.find_path_goalid~= quest.find_path_goalid)) ) then
				QuestPathfinderNavUI.last_quest = quest;

				if(QuestLinksViewPage.HasInclude_QuestIds(quest.find_path_questid))then
					goal_manager.SetDefaultGoal("do_quest_battle");
				elseif(quest.is_npc) then
					goal_manager.SetDefaultGoal("do_quest_npc");
				else
					goal_manager.SetDefaultGoal("do_quest_place");
				end
			end
		else
			-- no default goal after level 6. 
			goal_manager.SetDefaultGoal(nil);
		end
		return;
	end
	if(QuestPathfinderNavUI.IsInitialized()) then
		if(QuestPathfinderNavUI.pathfinder:SetTarget(quest))then
			if(quest.is_area_tip and quest.same_world) then
				QuestHelp.ActiveAreaTip(true,quest.x,quest.y,quest.z);
			end
			QuestPathfinderNavUI.GetTimer():Change(0,100);
			QuestPathfinderNavUI.stopped = false;

			if(Player.GetLevel() <= 4) then
				if(QuestLinksViewPage.HasInclude_QuestIds(quest.find_path_questid))then
					goal_manager.SetDefaultGoal("do_quest_battle");
				elseif(quest.is_npc) then
					goal_manager.SetDefaultGoal("do_quest_npc");
				else
					goal_manager.SetDefaultGoal("do_quest_place");
				end
			else
				-- no default goal after level 6. 
				goal_manager.SetDefaultGoal(nil);
			end

			if(last_quest.x~=quest.x or last_quest.y~=quest.y or last_quest.z~=quest.z) then
				last_quest = quest;

				CardMovieHelper.GoalActived(nil,function()
					-- CommonCtrl.BroadcastHelper.PushLabel({label = "你有了新目标,请按照下方箭头移动",});
				end);
				--[[
				if( (Player.GetLevel()<=5) or tip_display_count<1) then
					tip_display_count = tip_display_count + 1;
					last_quest = quest;
					if(QuestPathfinderNavUI.page)then
						local marker = QuestPathfinderNavUI.page:FindControl("marker");
						if(marker) then
							marker.visible = false;
							tip_elapsed_time = 0;
							last_player_pos = nil;
							bounce_timer = bounce_timer or commonlib.Timer:new({callbackFunc = function(timer)
								local marker = QuestPathfinderNavUI.page:FindControl("marker");
								if(marker) then
									if(DockTip.GetInstance():IsVisible() or not QuestPathfinderNavUI.page:IsVisible()) then
										-- make invisible. 
										marker.visible = false;
									else
										marker.visible = true;
										
										if((Player.GetLevel()<=5)) then
											-- always show until player moves. 
											local x, y, z = Player.GetPlayer():GetPosition();
											if(not last_player_pos and x) then
												last_player_pos = {};
												last_player_pos.x, last_player_pos.y, last_player_pos.z = x, y, z;
											else
												local dist_sq = (last_player_pos.x - x)*(last_player_pos.x - x) + (last_player_pos.z - z)*(last_player_pos.z - z)
												if(last_player_pos.x ==x and last_player_pos.z == z)then
													-- always display if player does not move. 
												else
													if( dist_sq > 100) then
														tip_elapsed_time = max_tip_time
													else
														tip_elapsed_time = tip_elapsed_time + timer:GetDelta();
													end
												end
											end
										else
											tip_elapsed_time = tip_elapsed_time + timer:GetDelta();
										end
										
									end
									
									if(tip_elapsed_time >= max_tip_time or not QuestPathfinderNavUI.IsArrowVisible) then
										marker.visible = false;
										timer:Change();
									end
								end
							end})
							QuestPathfinderNavUI.bounce_timer = bounce_timer;
							bounce_timer:Change(500,500);
						end
						
					end
				end
				]]
			end
		else
			QuestPathfinderNavUI.GetTimer():Change();
			QuestPathfinderNavUI.stopped = true;
			QuestPathfinderNavUI.OnCloseTip()
		end
		
	end
end

-- get the current quest target
function QuestPathfinderNavUI.GetTargetQuest()
	--if(not QuestPathfinderNavUI.enable_3d_tracker) then
		--return;
	--end
	if(QuestPathfinderNavUI.pathfinder and not QuestPathfinderNavUI.stopped) then
		return QuestPathfinderNavUI.pathfinder:GetTarget();
	end
end

-- return the world info table or nil of the currently tracked world. 
function QuestPathfinderNavUI.GetCurrentQuestWorld()
    local quest = QuestPathfinderNavUI.GetTargetQuest()
	if(quest and quest.worldInfo and quest.worldInfo) then
		return quest.worldInfo;
	end
end

local last_cd = nil;
local last_tip_visible;
function QuestPathfinderNavUI.OnTimer()
	local location = {};
	location.x,location.y,location.z = Player.GetPlayer():GetPosition();
	location.y = 1;
	local _;
	_, _, location.facing = ParaCamera.GetEyePos();
	location.worldInfo = WorldManager:GetCurrentWorld();
	QuestPathfinderNavUI.pathfinder:OnPlayerMove(location);

	if(not QuestPathfinderNavUI.enable_3d_tracker) then
		return 
	end

	if(WorldManager.teleport_stone_cool_down_seconds) then
		local current_teleport_cd = WorldManager.teleport_stone_cool_down_seconds - math.floor((commonlib.TimerManager.GetCurrentTime() - (WorldManager.last_teleport_time or 0))/1000);
		if(current_teleport_cd<0) then
			current_teleport_cd = 0;
		end
		if(last_cd ~= current_teleport_cd) then
			last_cd = current_teleport_cd;
			if(current_teleport_cd<=0) then
				QuestPathfinderNavUI.page:SetUIValue("transpotBtnCoolDown", "");
			else
				QuestPathfinderNavUI.page:SetUIValue("transpotBtnCoolDown", format("%ds", current_teleport_cd));
			end
		end
		-- totally disabled timer
		if(last_tip_visible or Player.GetLevel() <= 7) then
			-- highlight the teleport button
			local tip = QuestPathfinderNavUI.page:FindControl("transpotBtnTip");
			if(tip) then
				if(current_teleport_cd<=0) then
					if(QuestPathfinderNavUI.last_dist and QuestPathfinderNavUI.last_dist > 20) then
						tip.visible = true;
						last_tip_visible = true;
					else
						tip.visible = false;
					end
				else
					tip.visible = false;
				end
			end
		end
	end
end

function QuestPathfinderNavUI.RefreshDisplay(str,angle,show3DArrow, dist)
	local target = QuestPathfinderNavUI.pathfinder:GetTarget();
    if(target) then
		local item_info,about_questtype = QuestHelp.SearchTemplateItemByID(target.find_path_goalid);
		if(item_info and item_info.helpfunction and item_info.helpfunction~="" )then
			str = string.format("点击传送石查看帮助:%s",target.targetName or "");
			show3DArrow = false;
		end
	end

	local scene = ParaScene.GetMiniSceneGraph("QuestPathFinderArrow");
	if(scene:IsValid()) then
		local _this=scene:GetObject("NavArrows");
		if(_this:IsValid()) then
			QuestPathfinderNavUI.IsArrowVisible = show3DArrow;
			_this:SetVisible(show3DArrow);
			_this:SetFacing(angle);
		end		
	end

	QuestPathfinderNavUI.last_dist = dist;
	if(QuestPathfinderNavUI.page)then
		local ct = QuestPathfinderNavUI.page:FindControl("transport_cont");
		if(ct) then
			local text_width = _guihelper.GetTextWidth(str,System.DefaultFontString);
			local left = text_width*0.5+ page_width*0.5 + 10;
			ct.x = left
			if(str==nil or str=="" )then
				ct.visible = false;
			else
				ct.visible = true;
			end
			local navInfo = QuestPathfinderNavUI.page:FindControl("navInfo");
			if(navInfo) then
				if(navInfo.width ~= text_width) then
					navInfo.x = (page_width-text_width-20)*0.5;
					navInfo.width = text_width+20;
				end
				navInfo.text = str;
			end
		end
	end
end

-- let the character automatically go to the target. 
function QuestPathfinderNavUI.EnterAutoNavigationMode()
	NPL.load("(gl)script/apps/Aries/mcml/pe_goal_pointer.lua");
	local goal_manager = commonlib.gettable("MyCompany.Aries.mcml_controls.goal_manager");
	goal_manager.finish("teleport_quest");

	--if(not QuestPathfinderNavUI.enable_3d_tracker) then
		--return;
	--end

	local target = QuestPathfinderNavUI.pathfinder:GetTarget();
    if(target) then
		local find_path_goalid = target.find_path_goalid;
		local item_info,about_questtype = QuestHelp.SearchTemplateItemByID(find_path_goalid);
		if(item_info and item_info.helpfunction and item_info.helpfunction~="" )then
			QuestPathfinderNavUI.LeaveAutoNavigationMode();
			QuestPathfinderNavUI.TransportToCurrentTarget();
			return;
		end

		-- tricky: force waypoint to be calculated at least once before nav timer callback is called. 
		QuestPathfinderNavUI.OnTimer();

		if(not QuestPathfinderNavUI.enable_3d_tracker) then
			-- if distance is bigger than 100, do teleport to save player time. 
			if(QuestPathfinderNavUI.pathfinder:CalcDistance() > QuestPathfinderNavUI.max_walk_dist_during_pathfinding) then
				QuestPathfinderNavUI.LeaveAutoNavigationMode();
				QuestPathfinderNavUI.TransportToCurrentTarget();
				return;
			end
		end
	end

	QuestPathfinderNavUI.nav_timer = QuestPathfinderNavUI.nav_timer or commonlib.Timer:new({callbackFunc = function(timer)
		QuestPathfinderNavUI.AutoNavigationFrameMove();
	end})
	QuestPathfinderNavUI.nav_timer:Change(200,200);
	QuestPathfinderNavUI.last_move_count = Map3DSystem.HandleMouse.GetMovementCount();
	QuestPathfinderNavUI.reached_last_waypoint = false;
end

function QuestPathfinderNavUI.AutoNavigationFrameMove()
	local self = QuestPathfinderNavUI;
	local bReached = false;
	local isNav = false;
	local target = QuestPathfinderNavUI.pathfinder:GetTarget();
    if(target) then
		local wp = QuestPathfinderNavUI.pathfinder:GetCurWayPoint();
		if(wp) then
			local p_x, p_y, p_z = wp.x, wp.y, wp.z;
			local tx, ty, tz = target.x, target.y, target.z;
			
			local stop_dist = 5;
			local dist_to_player;
			local no_stop_when_reached;
			local target_facing;

			if(QuestPathfinderNavUI.pathfinder.needTranspot) then
				dist_to_player = (QuestPathfinderNavUI.last_dist or 0);
			else
				local x,y,z = Player.GetPlayer():GetPosition();
				
				if(target.jump_pos) then
					tx, ty, tz = target.jump_pos[1], target.jump_pos[2], target.jump_pos[3];
				end
				local target_dist_to_player = math.max(math_abs(tx-x), math_abs(tz-z));
				local waypoint_dist_to_player = math.max(math_abs(p_x-x), math_abs(p_z-z));
				
				
				if(target.is_npc or target.is_area_tip) then
					
					if( QuestPathfinderNavUI.reached_last_waypoint or 
						(not target.is_area_tip and tx == p_x and tz == p_z) or 
						(target.is_area_tip and target.x == p_x and target.z == p_z) ) then

						QuestPathfinderNavUI.reached_last_waypoint = true;

						local facing = target.facing or 0;
						facing = facing + 1.57
						local radius = 5;
						p_x = tx + radius * math.sin(facing);
						p_z = tz + radius * math.cos(facing);
						tx = p_x;
						tz = p_z;
						stop_dist = 0.1;
						if(target.facing and not target.is_area_tip) then
							target_facing = target.facing + 3.14;
						end
						no_stop_when_reached = true;
					end
				end
				dist_to_player = math.max(math_abs(tx-x), math_abs(tz-z));
			end

			if(dist_to_player < stop_dist) then
				bReached = true;
				local player = Player.GetPlayer()
				if(no_stop_when_reached) then
				else
					player:ToCharacter():Stop();
				end
				if(target.is_area_tip and target.facing) then
					local att = ParaCamera.GetAttributeObject();
					if(target.is_arena) then
						att:SetField("CameraRotY", target.facing);
					elseif(target.camPos and target.camPos[3]) then
						att:SetField("CameraRotY", target.camPos[3]);
					end
				end
				if(ty and not QuestPathfinderNavUI.pathfinder.needTranspot) then
					local x, y, z = player:GetPosition();
					if(math.abs(ty-y) > 3) then
						-- tricky: just in case, the object is below terrain, we will use the terrain height instead. 
						local terrain_y = ParaTerrain.GetElevation(x,z);
						if(ty < terrain_y) then
							ty = terrain_y;
						end
						player:SetPosition(x,ty,z);
					end
				end
				QuestPathfinderNavUI.TransportToCurrentTarget(true);
			else
				local bUserMovedSinceLastFollow;
				if(self.last_move_count and self.last_move_count ~=Map3DSystem.HandleMouse.GetMovementCount()) then
					self.last_move_count = Map3DSystem.HandleMouse.GetMovementCount();
					bUserMovedSinceLastFollow = true;
				elseif(Player.GetPlayer():GetField("GetLastWayPointType", 0) == 3) then
					-- COMMAND_MOVING is 3
					-- user is using other method to move the character such as using keyboard or mouse key combo. 
					bUserMovedSinceLastFollow = true;
				end
				if(not bUserMovedSinceLastFollow) then
					isNav = true;
					-- above terrain and model 
					local player = Player.GetPlayer()
					player:SetField("MovementStyle", 1);
					
					local world_info = WorldManager:GetCurrentWorld();

					if (world_info.min_fly_height and world_info.lowest_land_height) then
						local x, y, z = player:GetPosition();
						local terrain_y = ParaTerrain.GetElevation(x,z);

						if(p_y < world_info.min_fly_height) then
							p_y = world_info.min_fly_height;
						end

						--[[
						if(world_info.lowest_land_height < terrain_y) then
							if(Player.IsFlying()) then
								--LOG.std(nil, "debug", "nav fly mode", "cancel fly mode")
								Player.ToggleFly(false);
							end
						elseif( y < world_info.min_fly_height ) then
							if(not Player.IsFlying()) then
								Player.ToggleFly(true);
								--LOG.std(nil, "debug", "nav fly mode", "set fly mode")
							end
							
							if(y < world_info.min_fly_height) then
								p_y = world_info.min_fly_height;
								local dy;
								if( (p_y - y) >3) then
									player:SetPosition(x,p_y,z);
								else
									Player.Jump_imp();
								end
							end
						end]]
					end
					


					self.last_move_count = Map3DSystem.HandleMouse.MovePlayerToPoint(p_x, p_y, p_z, nil, target_facing);
					BasicArena.Set_immortal_countdown(4);
					Pet.UpdateAvatarSpeed(true);
					-- disable camera collision
					ParaCamera.GetAttributeObject():SetField("PhysicsGroupMask", 268435456); -- 0x10000000
					BroadcastHelper.PushLabel({id="auto_nav", label = "自动寻路中...", max_duration=2000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
				end
			end
		end
	end
	if(bReached or not isNav) then
		QuestPathfinderNavUI.LeaveAutoNavigationMode();
	end
end

-- leave auto navigation mode. 
function QuestPathfinderNavUI.LeaveAutoNavigationMode()
	if(QuestPathfinderNavUI.nav_timer) then
		BasicArena.Set_immortal_countdown(0);
		BroadcastHelper.PushLabel({id="auto_nav", label = nil, max_duration=0, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
		QuestPathfinderNavUI.nav_timer:Change();
		Pet.UpdateAvatarSpeed();
		-- re-enable camera collision
		ParaCamera.GetAttributeObject():SetField("PhysicsGroupMask", 4294967295);
		-- height only mode. 
		Player.GetPlayer():SetField("MovementStyle", 0);
	end
end

-- teleport to the current target. 
function QuestPathfinderNavUI.TransportToCurrentTarget(bSilentModeNoTeleport)
	NPL.load("(gl)script/apps/Aries/mcml/pe_goal_pointer.lua");
	local goal_manager = commonlib.gettable("MyCompany.Aries.mcml_controls.goal_manager");
	goal_manager.finish("teleport_quest");

	local target = QuestPathfinderNavUI.pathfinder:GetTarget();
    if(target) then
	    local position;
        local camPos;
        local is_npc = target.is_npc;
		local jump_pos = target.jump_pos;--跳转坐标
        local find_path_goalid = target.find_path_goalid;
		local item_info,about_questtype = QuestHelp.SearchTemplateItemByID(find_path_goalid);
		if(item_info and item_info.helpfunction and item_info.helpfunction~="" )then
			QuestTrackerPane.TrackCurrentGoal(find_path_goalid);
            NPL.DoString(item_info.helpfunction);
            return;
		end
        if(is_npc)then
            local facing = target.facing or 0;
            facing = facing + 1.57
            local radius = 5;
            local  x,y,z = jump_pos[1],jump_pos[2],jump_pos[3];
            x = x + radius * math.sin(facing);
			z = z + radius * math.cos(facing);
            position = {x,y,z, facing + 1.57};
			camPos = { 15, 0.27, facing + 1.57 - 1};
        else
            position = jump_pos;
			if(not position and target.x) then
				position = {target.x, target.y, target.z, target.facing}
			end
            camPos = target.camPos
            if(camPos==nil or next(camPos)==nil)then
                camPos = { 15, 0.27, 0};
            end
        end
		local ignore_jump_stone;

		-- do not cost jump stone if distance is smaller than 20 meters.
		if((QuestPathfinderNavUI.last_dist or 0)<20) then
			ignore_jump_stone = true;
		end
		if(bSilentModeNoTeleport) then
			if(QuestPathfinderNavUI.pathfinder.needTranspot) then
				NPL.load("(gl)script/apps/Aries/Map/LocalMap.lua");
				local LocalMap = commonlib.gettable("MyCompany.Aries.Desktop.LocalMap");
				MyCompany.Aries.Desktop.LocalMap.ShowWorldMap();
			else
				if(is_npc and find_path_goalid)then
					local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");
					TargetArea.TalkToNPC(find_path_goalid, nil, false);
				end
			end
		else
			WorldManager:GotoWorldPosition(target.worldInfo.name,position,camPos,nil,function()
				if(is_npc and find_path_goalid)then
					local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");
					TargetArea.TalkToNPC(find_path_goalid, nil, false);
				end
			end, ignore_jump_stone);
		end
    end
end
