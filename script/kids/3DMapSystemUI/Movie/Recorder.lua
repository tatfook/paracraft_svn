--[[
Title: Recording character behaviors in the scene into time series. 
Author(s): LiXizhi
Date: 2007/11/11
Desc: 
use the lib:
Internally, it uses a timer to sample all performing actors in the scene. 
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/Recorder.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");
NPL.load("(gl)script/ide/TimeSeries/TimeSeries.lua");

commonlib.setfield("Map3DSystem.Movie.Recorder", {})

Map3DSystem.Movie.Recorder = {
	-- movie recorder timer ID is 52. this timer ID should be reserved for movie lib
	timerID = 52,
	-- interval in millisecond, when sampling the actor action sequences.
	timerInterval = 2000,
	-- the state of recorder or agent
	Status_Paused = 1,
	Status_Recording = 2,
	Status_Playing = 3,
	-- recording or not. if paused all agents are paused, regardless of whether they are individually paused or not. 
	status = Map3DSystem.Movie.Recorder.Status_Recording,
	-- all performing actors (agents) that is being recorded (maybe paused)。 A mapping from agent name to agent. {[agent.name]={agent}}
	agents = {},
};

---------------------------------
-- template class for keeping a performing agent in recorder
---------------------------------
Map3DSystem.Movie.Recorder.agent = {
	-- a global character name in the 3d scene. 
	name = nil,
	-- whether recording or paused
	status = Map3DSystem.Movie.Recorder.Status_Paused,
	-- current time in milliseconds
	time = 0,
	-- whether to use relative positioning
	UseRelativePos = nil,
	-- relative position. 
	r_x = nil,
	r_y = nil,
	r_z = nil,
	-- the Map3DSystem.obj.GetHistory() will keep a time series for user actions. Its time is integer with 1 increment.
	LastCreationHistoryTime = nil,
	LastEnvHistoryTime = nil,
	-- when playing back a video, we will create all cached objects from the current time to this time.
	CurrentCreationPlayBackTime = nil,
	CurrentEnvPlayBackTime = nil,
	-- file associated with this agent. Where it loads or saves to
	filename = "temp/tempmovie.txt"
}

-- create a new recorder agent
function Map3DSystem.Movie.Recorder.agent:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	-- for data keeping. 
	o.obj_params = {name = o.name, IsCharacter = true};
	
	o.x = AnimBlock:new{name = "x", type = "Linear",};
	
	o.TimeSeries = TimeSeries:new{name = "recorder_actor",};
	o.TimeSeries:CreateVariable({name = "x", type="Linear"});
	o.TimeSeries:CreateVariable({name = "y", type="Linear"});
	o.TimeSeries:CreateVariable({name = "z", type="Linear"});
	o.TimeSeries:CreateVariable({name = "facing", type="Linear"});
	o.TimeSeries:CreateVariable({name = "scaling", type="Linear"});
	
	o.TimeSeries:CreateVariable({name = "ccs", type="Discrete"});
	o.TimeSeries:CreateVariable({name = "anim", type="Discrete"});
	o.TimeSeries:CreateVariable({name = "AssetFile", type="Discrete"});
	
	o.TimeSeries:CreateVariable({name = "talk", type="Discrete"});
	o.TimeSeries:CreateVariable({name = "creations", type="Discrete"});
	o.TimeSeries:CreateVariable({name = "env", type="Discrete"});
	return o
end

-- save the character action sequence to file
function Map3DSystem.Movie.Recorder.agent:Save(filename)
	self.filename = filename;
	self.TimeSeries:Save(filename);
end

-- load the character action sequence from a file. 
-- @param filename: a lua table file containing the time series for all action variables. 
function Map3DSystem.Movie.Recorder.agent:Load(filename)
	self.filename = filename;
	self.TimeSeries:Load(filename);
	-- rewind time to beginning after load.
	self:Rewind();
end

-- begin recording this agent. agent is started as paused. One needs to call Resume manually. 
function Map3DSystem.Movie.Recorder.agent:Record()
	self.status = Map3DSystem.Movie.Recorder.Status_Recording;
	
	-- so that it will only record history from this time.
	local history = Map3DSystem.obj.GetHistory();
	local time = history.creations:GetLastTime();
	self.LastCreationHistoryTime = time;
	
	-- so that it will only record history from this time.
	local history = Map3DSystem.Env.GetHistory();
	local time = history.env:GetLastTime();
	self.LastEnvHistoryTime = time;
	
	-- trim all keys to current time
	if(self.time <= 0) then
		self.TimeSeries:TrimEnd(self.time-1)
	else
		self.TimeSeries:TrimEnd(self.time)
	end	
	
	Map3DSystem.Movie.Recorder.EnableTimer(true);
end

-- playing the agent. 
function Map3DSystem.Movie.Recorder.agent:Play()
	self.status = Map3DSystem.Movie.Recorder.Status_Playing;
	Map3DSystem.Movie.Recorder.EnableTimer(true);
end

-- use relative positioning
-- when playing with using relative position. The first frame origin is shifted to what the player is at that frame. 
-- @param enable: true to enable 
function Map3DSystem.Movie.Recorder.agent:UseRelativePosition(enable)
	self.UseRelativePos = enable;
end

-- play from beginning again
function Map3DSystem.Movie.Recorder.agent:Replay()
	self:Rewind();
	self:Play();
end

-- rewind to beginning
function Map3DSystem.Movie.Recorder.agent:Rewind()
	self.time = 0;
	self.CurrentCreationPlayBackTime = nil;
	self.CurrentEnvPlayBackTime = nil;
end

-- pause recording this agent. 
function Map3DSystem.Movie.Recorder.agent:Pause()
	self.status = Map3DSystem.Movie.Recorder.Status_Paused;
end

-- check whether agent is being recorded. 
function Map3DSystem.Movie.Recorder.agent:IsRecording()
	return (self.status == Map3DSystem.Movie.Recorder.Status_Recording);
end

-- check whether agent is playing. 
function Map3DSystem.Movie.Recorder.agent:IsPlaying()
	return (self.status == Map3DSystem.Movie.Recorder.Status_Playing);
end

-- check whether agent is paused. 
function Map3DSystem.Movie.Recorder.agent:IsPaused()
	return (self.status == Map3DSystem.Movie.Recorder.Status_Paused);
end

-----------------------------------
-- recorder functions
-----------------------------------
-- add an agent to the actor list. if there is already one with the same name, the old one is replaced with the new one. 
function Map3DSystem.Movie.Recorder.AddAgent(agent)
	local self = Map3DSystem.Movie.Recorder;
	if(agent.name~=nil and agent.name~="") then
		self.agents[agent.name] = agent;
	end
end

-- get an agent with a given name. it may return nil if no agent found in the recorder. 
function Map3DSystem.Movie.Recorder.GetAgent(name)
	local self = Map3DSystem.Movie.Recorder;
	if(name~=nil and name~="") then
		return self.agents[name];
	end
end

-- remove an agent with a given name 
function Map3DSystem.Movie.Recorder.RemoveAgent(name)
	local self = Map3DSystem.Movie.Recorder;
	if(name~=nil and name~="") then
		self.agents[name] = nil;
	end
end

-- begin or resume recording this agent. agent is started as paused. One needs to call Resume manually. 
function Map3DSystem.Movie.Recorder.Record()
	local self = Map3DSystem.Movie.Recorder;
	self.status = Map3DSystem.Movie.Recorder.Status_Recording;
	Map3DSystem.Movie.Recorder.EnableTimer(true);
end

-- pause recording this agent. 
function Map3DSystem.Movie.Recorder.Pause()
	local self = Map3DSystem.Movie.Recorder;
	self.status = Map3DSystem.Movie.Recorder.Status_Paused;
end

-- check whether recording. 
function Map3DSystem.Movie.Recorder.IsRecording()
	return (Map3DSystem.Movie.Recorder.status == Map3DSystem.Movie.Recorder.Status_Recording);
end

-- check whether agent is playing. 
function Map3DSystem.Movie.Recorder.IsPlaying()
	return (Map3DSystem.Movie.Recorder.status == Map3DSystem.Movie.Recorder.Status_Playing);
end

-- check whether agent is paused. 
function Map3DSystem.Movie.Recorder.IsPaused()
	return (Map3DSystem.Movie.Recorder.status == Map3DSystem.Movie.Recorder.Status_Paused);
end

-- private: enable or disable recording timer.
function Map3DSystem.Movie.Recorder.EnableTimer(bEnable)
	local self = Map3DSystem.Movie.Recorder;
	if(bEnable) then
		NPL.SetTimer(self.timerID, self.timerInterval/1000, ";Map3DSystem.Movie.Recorder.OnTimer();");
	else
		NPL.KillTimer(self.timerID);
		--log("movie recorder timer stopped\n")
	end
end

-- private: the recorder timer.
function Map3DSystem.Movie.Recorder.OnTimer()
	local self = Map3DSystem.Movie.Recorder;
	if(self.IsPaused()) then
		self.EnableTimer(false);
	end
	local deltaTime = self.timerInterval;
	-- check for any agent time out
	local _, agent;
	local count = 0;
	local InvalidAgents;
	
	
	for _, agent in pairs(Map3DSystem.Movie.Recorder.agents) do
		
		if(not agent:IsPaused()) then
			-- sample agent variables to time series. 
			local player = ObjEditor.GetObjectByParams(agent.obj_params);
			if(player~=nil and player:IsValid())then
				if(agent:IsRecording()) then
					-------------------------------
					-- recording by sampling the player variables
					-------------------------------
					count = count +1;
					local x,y,z = player:GetPosition();
					agent.TimeSeries.x:AutoAppendKey(agent.time, x);
					agent.TimeSeries.y:AutoAppendKey(agent.time, y);
					agent.TimeSeries.z:AutoAppendKey(agent.time, z);
					agent.TimeSeries.scaling:AutoAppendKey(agent.time, player:GetScale());
					agent.TimeSeries.facing:AutoAppendKey(agent.time, player:GetFacing());
					
					-- animation
					local anim = player:ToCharacter():GetAnimID();
					if(anim>=2000) then
						anim = player:ToCharacter():GetAnimFileName();
					end
					agent.TimeSeries.anim:AutoAppendKey(agent.time, anim);
					-- AssetFile
					agent.TimeSeries.AssetFile:AutoAppendKey(agent.time, player:GetPrimaryAsset():GetKeyName());
					-- CCS
					local ccs = Map3DSystem.UI.CCS.GetCCSInfoString(player);
					if(ccs~=nil) then
						agent.TimeSeries.ccs:AutoAppendKey(agent.time, ccs);
					end	
					-- TODO: talk
					
					-- object message: creation, modification, deletion
					local history = Map3DSystem.obj.GetHistory();
					local time = history.creations:GetLastTime();
					if(time~=nil and (agent.LastCreationHistoryTime==nil or time > agent.LastCreationHistoryTime)) then
						-- for saving object creation from history to movie
						agent.LastCreationHistoryTime = agent.LastCreationHistoryTime or -1;
						local t;
						for t=agent.LastCreationHistoryTime+1, time do
							local msg = history.creations:getValue(1, t);
							if(msg~=nil and msg.author == agent.name) then
								agent.TimeSeries.creations:AutoAppendKey(agent.time, msg);
							end
						end
						agent.LastCreationHistoryTime = time;
					end
					
					-- environment message: paint, elevation,etc
					local history = Map3DSystem.Env.GetHistory();
					local time = history.env:GetLastTime();
					if(time~=nil and (agent.LastEnvHistoryTime==nil or time > agent.LastEnvHistoryTime)) then
						-- for saving object creation from history to movie
						agent.LastEnvHistoryTime = agent.LastEnvHistoryTime or -1;
						local t;
						for t=agent.LastEnvHistoryTime+1, time do
							local msg = history.env:getValue(1, t);
							if(msg~=nil and msg.author == agent.name) then
								agent.TimeSeries.env:AutoAppendKey(agent.time, msg);
							end
						end
						agent.LastEnvHistoryTime = time;
					end
					
				elseif(agent:IsPlaying()) then	
					-------------------------------
					-- playing by sequence
					-------------------------------
					count = count +1;
					
					local time = agent.TimeSeries.x:GetLastTime();
					if(time==nil or (time+self.timerInterval)<agent.time ) then
						-- if we have reached the end of animation (use x variable for checking), we will pause. 
						Map3DSystem.SendMessage_movie({type = Map3DSystem.msg.MOVIE_ACTOR_Pause, obj_params=agent.obj_params})
					else
						-- play animation
						local new_x = agent.TimeSeries.x:getValue(1, agent.time);
						local new_y = agent.TimeSeries.y:getValue(1, agent.time);
						local new_z = agent.TimeSeries.z:getValue(1, agent.time);
						
						if(agent.time ~= 0 and agent.UseRelativePos and agent.r_x~=nil) then
							new_x = new_x+agent.r_x;
							new_y = new_y+agent.r_y;
							new_z = new_z+agent.r_z;
						end
						
						--log(string.format("(%d): %f %f %f\n", agent.time, new_x, new_y, new_z));
						
						local x,y,z = player:GetPosition();
						local deltaXZ = math.abs(x-new_x) + math.abs(z-new_z);
						
						local deltaY = math.abs(y-new_y);
						local reachedPos;
						
						if(agent.time == 0) then
							-- if this is the first frame, just set at precise location and facing
							if(agent.UseRelativePos) then
								agent.r_x = x-new_x;
								agent.r_y = y-new_y;
								agent.r_z = z-new_z;
								--log(string.format("%s abs pos %f %f %f\n", agent.name, x,y,z));
								--log(string.format("%s time series pos %f %f %f\n", agent.name, new_x,new_y,new_z));
								--log(string.format("%s relative pos %f %f %f\n", agent.name, agent.r_x, agent.r_y, agent.r_z));
								new_x = x;
								new_y = y;
								new_z = z;
							else
								player:SetPosition(new_x, new_y, new_z);
								player:UpdateTileContainer();		
							end
							reachedPos = true;
						elseif(deltaXZ>0.1) then
							player:ToCharacter():GetSeqController():MoveTo(new_x-x, new_y-y, new_z-z);
						elseif((deltaXZ+deltaY)>0.01) then
							-- if we are almost there, just set at precise location and facing
							player:SetPosition(new_x, new_y, new_z);
							player:UpdateTileContainer();
							reachedPos = true;
						else
							-- we are already there, no need to change position	
							reachedPos = true;
						end	
						
						-- if our avatar is already in position. 
						if(reachedPos) then
							-- set facing 
							local facing = agent.TimeSeries.facing:getValue(1, agent.time);
							if(facing~=nil) then
								if(math.abs(player:GetFacing()-facing)>0.01) then
									player:SetFacing(facing);
								end	
							end	
							
							-- set animation ID or filename
							local anim = agent.TimeSeries.anim:getValue(1, agent.time);
							
							if(type(anim) == "number") then
								if(player:ToCharacter():GetAnimID() ~= anim) then
									if(anim>46) then
										player:ToCharacter():PlayAnimation(anim)
									end	
								end
							elseif(type(anim) == "string") then
								if(anim ~= player:ToCharacter():GetAnimFileName()) then
									-- play an animation. 
									action_table.PlayAnimationFile(anim,player);
								end
							end
						end	
						
						-------------------------------
						-- update group 2 if any
						-------------------------------
						local GTwo; -- whether needs to update group 2
						local mod_msg = {
							type = Map3DSystem.msg.OBJ_ModifyObject, 
							silentmode = true, 
							forcelocal = true,
							obj_params = {
								name = agent.name,
								IsCharacter = true,
							},
						}
						-- set scaling if any 
						local scaling = agent.TimeSeries.scaling:getValue(1, agent.time);
						if(math.abs(player:GetScale()-scaling)>0.01) then
							mod_msg.scale = self.scaling;
							GTwo = true;
						end
						
						-- change appearance if any
						local AssetFile = agent.TimeSeries.AssetFile:getValue(1, agent.time);
						if(AssetFile ~= player:GetPrimaryAsset():GetKeyName()) then
							mod_msg.asset_file = AssetFile;
							GTwo = true;
						end
						
						if(GTwo) then
							Map3DSystem.SendMessage_obj(mod_msg);
						end
						
						-- ccs appearance
						local new_ccs = agent.TimeSeries.ccs:getValue(1, agent.time);
						local ccs = Map3DSystem.UI.CCS.GetCCSInfoString(player)
						if(ccs~=new_ccs) then
							Map3DSystem.UI.CCS.ApplyCCSInfoString(player, new_ccs);
						end
						
						-- for object creations, modification, deletions
						if(agent.TimeSeries.creations ~=nil ) then
							
							agent.CurrentCreationPlayBackTime = agent.CurrentCreationPlayBackTime or -1;
							local t, msg;
							for t, msg in agent.TimeSeries.creations:GetKeys_Iter(1, agent.CurrentCreationPlayBackTime, agent.time) do
								-- create without writing to history
								local new_msg = {
									SkipHistory = true,
								}
								commonlib.partialcopy(new_msg, msg);
								
								-- relative position also applies to creations
								if(agent.UseRelativePos and agent.r_x~=nil) then
									if(new_msg.obj_params.x ~= nil) then
										new_msg.obj_params.x =  new_msg.obj_params.x + agent.r_x;
										new_msg.obj_params.y =  new_msg.obj_params.y + agent.r_y;
										new_msg.obj_params.z =  new_msg.obj_params.z + agent.r_z;
									end	
									if(new_msg.obj_params.ViewBox ~= nil) then
										new_msg.obj_params.ViewBox.pos_x =  new_msg.obj_params.ViewBox.pos_x + agent.r_x;
										new_msg.obj_params.ViewBox.pos_y =  new_msg.obj_params.ViewBox.pos_y + agent.r_y;
										new_msg.obj_params.ViewBox.pos_z =  new_msg.obj_params.ViewBox.pos_z + agent.r_z;
									end
									if(new_msg.pos~= nil) then
										new_msg.pos.x =  new_msg.pos.x + agent.r_x;
										new_msg.pos.y =  new_msg.pos.y + agent.r_y;
										new_msg.pos.z =  new_msg.pos.z + agent.r_z;
									end
								end
								Map3DSystem.SendMessage_obj(new_msg);
								--log(t.." "..new_msg.obj_params.AssetFile.."\n")
							end
							agent.CurrentCreationPlayBackTime = agent.time;
						end
						
						-- for environment: terrain paint, elevation
						if(agent.TimeSeries.env ~=nil ) then
							
							agent.CurrentEnvPlayBackTime = agent.CurrentEnvPlayBackTime or -1;
							local t, msg;
							for t, msg in agent.TimeSeries.env:GetKeys_Iter(1, agent.CurrentEnvPlayBackTime, agent.time) do
								-- create without writing to history
								local new_msg = {
									SkipHistory = true,
								}
								commonlib.partialcopy(new_msg, msg);
								
								-- relative position also applies to creations
								if(agent.UseRelativePos and agent.r_x~=nil) then
									if(new_msg.brush~=nil and new_msg.brush.x ~= nil) then
										new_msg.brush.x =  new_msg.brush.x + agent.r_x;
										new_msg.brush.y =  new_msg.brush.y + agent.r_y;
										new_msg.brush.z =  new_msg.brush.z + agent.r_z;
									end	
								end
								
								Map3DSystem.SendMessage_env(new_msg);
							end
							agent.CurrentEnvPlayBackTime = agent.time;
						end
					end
				end
			else
				-- Mark the agent name to be deleted after the iteration
				InvalidAgents = InvalidAgents or {};
				InvalidAgents[agent.name] = true;
				log(agent.name.." is removed from recorder since not found\n")
			end	
			-- advance time
			agent.time = agent.time + deltaTime;
		end	
	end
	
	-- delete invalid agents
	if(InvalidAgents~=nil) then
		local key, _;
		for key, _ in pairs(InvalidAgents) do
			Map3DSystem.Movie.Recorder.RemoveAgent(key);
		end
	end
		
	-- disable timer if no active agent	
	if (count == 0)	then
		self.EnableTimer(false);
	end
end