--[[
Title: client file for per world temporary team 
Author(s):  LiXizhi
Date: 2010/11/24
Desc: When a user joins an instance world, it immediately become a team member of that specific world. 
The first user joining the team is usually the team leader. 
The team leader is able to declare start of the level. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/Team/worldteam_client.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/TooltipHelper.lua");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
NPL.load("(gl)script/apps/Aries/Team/TeamWorldInstancePortal.lua");

local worldteam_client = {};
local LOG = LOG;
Map3DSystem.GSL.client.config:RegisterNPCTemplate("aries_worldteam_system", worldteam_client);
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");

function worldteam_client.CreateInstance(self)
	self.OnNetReceive = worldteam_client.OnNetReceive;
	self.OnDestroy = worldteam_client.OnDestroy;

	self.game_started = false;
	self.timer = commonlib.Timer:new({callbackFunc = function(timer)
		worldteam_client.OnTeamTimer(self, timer);
	end})
end

-- This function is called by the server object is actually destroyed and set to nil
function worldteam_client:OnDestroy()
	if(self.timer) then
		self.timer:Change();
		self.timer = nil;
		BroadcastHelper.Clear("worldteam_timer")
		BroadcastHelper.Clear("worldteam")
	end
end

-- on team timer. 
function worldteam_client:OnTeamTimer(timer)
	if(self.game_started) then
		-- kill timer if already started.
		timer:Change();
	elseif(self.is_tick_started and self.tick_count_down) then
		local worldinfo = WorldManager:GetCurrentWorld();
		if(worldinfo.team_mode == "battlefield") then
			-- do nothing
			timer:Change();
		else
			if(self.tick_count_down >= 0 ) then
				local params = {id="worldteam_timer", priority=0, color="255 0 0", scaling=1.2, bold=true, shadow=true,
					max_duration=1000, 
					label = format("倒计时: %d", self.tick_count_down or 0) }
				if(self.tick_count_down>20) then
					params.max_duration = 3000;
					params.fade_in_time = 0;
					params.fade_out_time = 0;
				end
				BroadcastHelper.PushLabel(params);
				self.tick_count_down = self.tick_count_down - 1;
			end

			if(self.tick_count_down < 0 ) then
				self.force_start_game = true;
			end
		end
	end
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msgs is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function worldteam_client:OnNetReceive(client, msgs)
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			if(type(msg) == "table") then
				if(msg.type == "TickStart") then
					-- the team leader can now start the game, since there is already enough players on the server. 
					--_guihelper.MessageBox("Do you want to start the game?", function()
						---- tell the remote user to start.
						--client:SendRealtimeMessage(self.id, {type="StartGame"});
					--end)

				elseif(msg.type == "TickWait") then
					--_guihelper.MessageBox("Waiting for other players, please stand by..., do you want to play anyway", function()
						---- tell the remote user to start.
						--client:SendRealtimeMessage(self.id, {type="StartGame"});
					--end)
				end
				
				-- 你已进入战斗准备状态，倒计时结束后可以开始战斗，期间可能有其他哈奇加入，请留意倒计时：　１０　（到计时显示10到1，最后显示 战斗开始！）
				if(not self.is_tick_started) then
					self.is_tick_started = true;

					-- team_mode
					local worldinfo = WorldManager:GetCurrentWorld();
					
					if(not self.tick_count_down) then
						self.tick_count_down = tonumber(worldinfo.team_waiting_secs) or 25;
					end

					if(worldinfo.team_mode == "single") then
						BroadcastHelper.PushLabel({id="worldteam", priority=1, max_duration=(self.tick_count_down or 10)*1000, scaling=1.1, bold=true, shadow=true,
							label = "此副本只能一个人进入，小心前行！", }); 
					elseif(worldinfo.team_mode == "battlefield") then
						
					else
						BroadcastHelper.PushLabel({id="worldteam", priority=1, max_duration=(self.tick_count_down or 10)*1000, scaling=1.1, bold=true, shadow=true,
							label = "战斗准备状态，请等待其他队友加入", }); 
						self.timer:Change(0,1000);

						-- 对于队长给出副本主动提示
						local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");
						local TeamWorldInstancePortal = commonlib.gettable("MyCompany.Aries.Team.TeamWorldInstancePortal");
						if(TeamClientLogics.GetJC)then
							local isleader = TeamWorldInstancePortal.IsTeamLeader();
							local system_looptip = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips.system_looptip");
							local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
							if (isleader and (not system_looptip.entercopy) and (string.lower(system_looptip.currentcopy)=="pve")) then
								AutoTips.CheckShowEnterCopy();
							end
						end
					end
				end
				if(self.force_start_game) then
					self.force_start_game = false;
					local worldinfo = WorldManager:GetCurrentWorld();
					if(worldinfo.team_mode ~= "battlefield") then
						client:SendRealtimeMessage(self.id, {type="StartGame"});
					end
				end
			end
		end
	elseif(msgs == nil) then
		local IsStarted = self:GetValue("IsStarted");
		if(IsStarted) then
			LOG.std("", "system", "worldteam", "All members are ready. Game Is Started.");
			self.game_started = true;
			if(self.timer) then
				-- kill timer
				self.timer:Change();
			end
			--BroadcastHelper.Clear("worldteam");
			--BroadcastHelper.Clear("worldteam_timer");

			local worldinfo = WorldManager:GetCurrentWorld();
			if(worldinfo.team_mode == "single") then
				BroadcastHelper.PushLabel({id="worldteam", label = "此副本只能一个人进入，小心前行！", max_duration=10000, scaling=1.1, bold=true, shadow=true,
					background = "Texture/Aries/Common/gradient_white_32bits.png",
					background_color = "#1f3243",
					}); 
			elseif(worldinfo.team_mode == "battlefield") then
				-- BroadcastHelper.PushLabel({id="worldteam", label = "战斗已经开始，开始行动吧！", max_duration=10000, scaling=1.1, bold=true, shadow=true,}); 						
			elseif(worldinfo.team_mode == "random_pvp") then
				BroadcastHelper.PushLabel({id="worldteam", label = "准备战斗", max_duration=5000, scaling=1.1, bold=true, shadow=true,}); 
			else
				BroadcastHelper.PushLabel({id="worldteam", label = "副本关闭, 新队友不能加入了", max_duration=10000, scaling=1.1, bold=true, shadow=true,}); 
				BroadcastHelper.PushLabel({id="worldteam_timer", label = "让我们开始行动吧!", color="0 255 0", max_duration=10000, scaling=1.1, bold=true, shadow=true,
					background = "Texture/Aries/Common/gradient_white_32bits.png",
					background_color = "#1f3243",
				}); 
			end

			-- make player free to move
			--NPL.load("(gl)script/apps/Aries/Creator/WorldCommon.lua");
			--local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon")
			--WorldCommon.SetPlayerMovableRegion(16000);

			-- _guihelper.MessageBox("Game is started");
		end
	end
end
