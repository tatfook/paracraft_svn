--[[
Title: Recording the current player's action
Author(s): LiXizhi, based on my previous Movie/Recorder.lua code
Date: 2010/1/7
Desc: recording and play back functionality of any characters in the scene. 
Currently it is used for the time machine effect, however, it is a self contained library. 

use the lib:
Internally, it uses a timer to sample all performing actors in the scene. 
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Movie/PlayerRecorder.lua");

local Recorder = commonlib.gettable("MyCompany.Aries.Movie.Recorder")
main_actor = Recorder.CreateGetActor(ParaScene.GetPlayer().name);
main_actor:Rewind();
main_actor:Record();
... recording ...
main_actor:Rewind();
main_actor:Play();
------------------------------------------------------------
]]

local Recorder = commonlib.gettable("MyCompany.Aries.Movie.Recorder")

-- interval in millisecond, when sampling the actor action sequences.
Recorder.timerInterval = 500;
-- the state of recorder or actor
local RecorderStatus = {
	Paused = 1,
	Recording = 2,
	Playing = 3,
	-- playing in the opposite direction. 
	ReversePlaying = 4,
}

-- recording or not. if paused all actors are paused, regardless of whether they are individually paused or not. 
Recorder.status = RecorderStatus.Paused;

-- all performing actors (actors) that is being recorded (maybe paused)¡£ A mapping from actor name to actor. {[actor.name]={actor}}
Recorder.actors = {};

---------------------------------
-- template class for keeping a performing actor in recorder
---------------------------------
local Actor = commonlib.gettable("MyCompany.Aries.Movie.Actor")
-- a global character name in the 3d scene. 
Actor.name = nil;
-- whether recording or paused
Actor.status = RecorderStatus.Paused;
-- current time in milliseconds
Actor.time = 0;
-- whether to use relative positioning
Actor.UseRelativePos = nil;
-- relative position. 
Actor.r_x = nil;
Actor.r_y = nil;
Actor.r_z = nil;
-- file associated with this actor. Where it loads or saves to
Actor.filename = "temp/tempmovie.txt";

-- it is the playback speed scale. 
Actor.PlaySpeed = 1;
-- it is the playback speed scale for reverse playing. 
Actor.ReversePlaySpeed = 3;


-- create a new recorder actor
function Actor:new(o)
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
	-- o.TimeSeries:CreateVariable({name = "scaling", type="Linear"});
	
	o.TimeSeries:CreateVariable({name = "anim", type="Discrete"});
	
	--o.TimeSeries:CreateVariable({name = "ccs", type="Discrete"});
	--o.TimeSeries:CreateVariable({name = "AssetFile", type="Discrete"});
	
	--o.TimeSeries:CreateVariable({name = "talk", type="Discrete"});
	
	-- o.TimeSeries:CreateVariable({name = "creations", type="Discrete"});
	-- o.TimeSeries:CreateVariable({name = "env", type="Discrete"});
	return o
end

-- save the character action sequence to file
function Actor:Save(filename)
	self.filename = filename;
	self.TimeSeries:Save(filename);
end

-- load the character action sequence from a file. 
-- @param filename: a lua table file containing the time series for all action variables. 
function Actor:Load(filename)
	self.filename = filename;
	self.TimeSeries:Load(filename);
	-- rewind time to beginning after load.
	self:Rewind();
end

-- begin recording this actor. actor is started as paused. One needs to call Resume manually. 
function Actor:Record()
	self.status = RecorderStatus.Recording;
	
	-- trim all keys to current time
	if(self.time <= 0) then
		self.TimeSeries:TrimEnd(self.time-1)
	else
		self.TimeSeries:TrimEnd(self.time)
	end	
	
	Recorder.EnableTimer(true);
end

-- play the actor. 
function Actor:Play()
	self.status = RecorderStatus.Playing;
	Recorder.EnableTimer(true);
end

-- play the actor in to the history
function Actor:ReversePlay()
	self.status = RecorderStatus.ReversePlaying;
	Recorder.EnableTimer(true);
end

-- use relative positioning
-- when playing with using relative position. The first frame origin is shifted to what the player is at that frame. 
-- @param enable: true to enable 
function Actor:UseRelativePosition(enable)
	self.UseRelativePos = enable;
end

-- play from beginning again
function Actor:Replay()
	self:Rewind();
	self:Play();
end

-- rewind to beginning
function Actor:Rewind()
	self.time = 0;
end

-- pause recording this actor. 
function Actor:Pause()
	self.status = RecorderStatus.Paused;
end

-- check whether actor is being recorded. 
function Actor:IsRecording()
	return (self.status == RecorderStatus.Recording);
end

-- check whether actor is playing. 
function Actor:IsPlaying()
	return (self.status == RecorderStatus.Playing);
end

-- check whether actor is playing in the opposite direction. 
function Actor:IsReversePlaying()
	return (self.status == RecorderStatus.ReversePlaying);
end

-- check whether actor is paused. 
function Actor:IsPaused()
	return (self.status == RecorderStatus.Paused);
end

-----------------------------------
-- recorder functions
-----------------------------------
-- add an actor to the actor list. if there is already one with the same name, the old one is replaced with the new one. 
function Recorder.AddActor(actor)
	local self = Recorder;
	if(actor.name~=nil and actor.name~="") then
		commonlib.log("actor: %s is added to recorder \n", actor.name);
		self.actors[actor.name] = actor;
	end
end

-- get an actor with a given name. it may return nil if no actor found in the recorder. 
function Recorder.GetActor(name)
	local self = Recorder;
	if(name~=nil and name~="") then
		return Recorder.actors[name];
	end
end

-- create get actor. 
function Recorder.CreateGetActor(name)
	local self = Recorder;
	
	local actor = Recorder.GetActor(name);
	if(not actor) then
		-- add actor if not
		actor = Actor:new({name = name})
		Recorder.AddActor(actor);
	end	
	return actor;
end


-- remove an actor with a given name 
function Recorder.RemoveActor(name)
	local self = Recorder;
	if(name~=nil and name~="") then
		self.actors[name] = nil;
	end
end

-- begin or resume recording this actor. actor is started as paused. One needs to call Resume manually. 
function Recorder.Record()
	local self = Recorder;
	self.status = RecorderStatus.Recording;
	self.EnableTimer(true);
end

-- pause recording this actor. 
function Recorder.Pause()
	local self = Recorder;
	self.status = RecorderStatus.Paused;
end

-- check whether recording. 
function Recorder.IsRecording()
	return (Recorder.status == RecorderStatus.Recording);
end

-- check whether actor is playing. 
function Recorder.IsPlaying()
	return (Recorder.status == RecorderStatus.Playing);
end

-- check whether actor is paused. 
function Recorder.IsPaused()
	return (Recorder.status == RecorderStatus.Paused);
end

-- private: enable or disable recording timer.
function Recorder.EnableTimer(bEnable)
	Recorder.timer = Recorder.timer or commonlib.Timer:new({callbackFunc = Recorder.OnTimer})
	
	if(bEnable) then
		Recorder.timer:Change(Recorder.timerInterval, Recorder.timerInterval);
		commonlib.log("Player recorder timer started %dms\n", Recorder.timerInterval);
	else
		Recorder.timer:Change();
		commonlib.log("Player recorder timer stopped\n")
	end
end

-- private: the recorder timer.
function Recorder.OnTimer(timer)
	local self = Recorder;
	--if(self.IsPaused()) then
		--self.EnableTimer(false);
	--end
	local deltaTime = self.timerInterval;
	-- check for any actor time out
	local _, actor;
	local count = 0;
	local Invalidactors;
	
	for _, actor in pairs(self.actors) do
		
		if(not actor:IsPaused()) then
			-- sample actor variables to time series. 
			local player = ObjEditor.GetObjectByParams(actor.obj_params);
			if(player~=nil and player:IsValid())then
				if(actor:IsRecording()) then
					-------------------------------
					-- recording by sampling the player variables
					-------------------------------
					--commonlib.echo({"recording", actor.time})
					count = count +1;
					local x,y,z = player:GetPosition();
					actor.TimeSeries.x:AutoAppendKey(actor.time, x);
					actor.TimeSeries.y:AutoAppendKey(actor.time, y);
					actor.TimeSeries.z:AutoAppendKey(actor.time, z);
					actor.TimeSeries.facing:AutoAppendKey(actor.time, player:GetFacing());
					--actor.TimeSeries.scaling:AutoAppendKey(actor.time, player:GetScale());
					
					-- animation
					local anim = player:ToCharacter():GetAnimID();
					if(anim>=2000) then
						anim = player:ToCharacter():GetAnimFileName();
					end
					actor.TimeSeries.anim:AutoAppendKey(actor.time, anim);
					---- AssetFile
					--actor.TimeSeries.AssetFile:AutoAppendKey(actor.time, player:GetPrimaryAsset():GetKeyName());
					---- CCS
					--local ccs = Map3DSystem.UI.CCS.GetCCSInfoString(player);
					--if(ccs~=nil) then
						--actor.TimeSeries.ccs:AutoAppendKey(actor.time, ccs);
					--end	
					-- TODO: talk
					
					-- advance time
					actor.time = actor.time + deltaTime;
				elseif(actor:IsReversePlaying()) then		
					-------------------------------
					-- reverse playing by sequence
					-------------------------------
					--commonlib.echo({"ReversePlaying", actor.time})
					count = count +1;
										
					local time = actor.time;
					if(time==nil or time<= 0 ) then
						-- if we have reached the end of animation (use x variable for checking), we will pause. 
						actor:Pause();
						player:ToCharacter():SetSpeedScale(1);
					else
						-- whether the player is standing without any action, if so,  we will jump faster in to next action, instead of waiting. 
						local is_standing;
						
						-- play animation
						local new_x = actor.TimeSeries.x:getValue(1, time);
						local new_y = actor.TimeSeries.y:getValue(1, time);
						local new_z = actor.TimeSeries.z:getValue(1, time);
						
						if(time ~= 0 and actor.UseRelativePos and actor.r_x~=nil) then
							new_x = new_x+actor.r_x;
							new_y = new_y+actor.r_y;
							new_z = new_z+actor.r_z;
						end
						
						--log(string.format("(%d): %f %f %f\n", actor.time, new_x, new_y, new_z));
						
						local x,y,z = player:GetPosition();
						local deltaXZ = math.abs(x-new_x) + math.abs(z-new_z);
						
						local deltaY = math.abs(y-new_y);
						local reachedPos;
						
						if(deltaXZ>0.1 and deltaY < 100) then
							player:ToCharacter():GetSeqController():MoveTo(new_x-x, new_y-y, new_z-z);
						elseif((deltaXZ+deltaY)>0.01 or deltaY> 100) then
							-- if we are almost there or too far away, just set at precise location and facing
							player:SetPosition(new_x, new_y, new_z);
							player:UpdateTileContainer();
							reachedPos = true;
						else
							-- we are already there, no need to change position	
							reachedPos = true;
							is_standing = true;
						end	
						
						-- if our avatar is already in position. 
						if(reachedPos) then
							-- set facing 
							local facing = actor.TimeSeries.facing:getValue(1, time);
							if(facing~=nil) then
								if(math.abs(player:GetFacing()-facing)>0.01) then
									player:SetFacing(facing);
									is_standing = false;
								end	
							end	
							
							-- set animation ID or filename
							local anim = actor.TimeSeries.anim:getValue(1, time);
							
							if(type(anim) == "number") then
								if(player:ToCharacter():GetAnimID() ~= anim) then
									if(anim>46) then
										player:ToCharacter():PlayAnimation(anim)
										is_standing = false;
									end	
								end
							elseif(type(anim) == "string") then
								if(anim ~= player:ToCharacter():GetAnimFileName()) then
									-- play an animation. 
									action_table.PlayAnimationFile(anim,player);
									is_standing = false;
								end
							end
							
							if(is_standing) then
								-- if the player is standing without any action, we will jump faster in to next closest key frame, instead of waiting. 
								local time1 = actor.TimeSeries.x:getTimeRange(1, time);
								local time2 = actor.TimeSeries.y:getTimeRange(1, time);
									--commonlib.echo({x=time1,y=time2})
								if(time1 < time2) then  time1 = time2; end
								time2 = actor.TimeSeries.z:getTimeRange(1, time);
									--commonlib.echo({z=time2})
								if(time1 < time2) then  time1 = time2; end
								time2 = actor.TimeSeries.facing:getTimeRange(1, time);
									--commonlib.echo({facing=time2})
								if(time1 < time2) then  time1 = time2; end
								time2 = actor.TimeSeries.anim:getTimeRange(1, time);
									--commonlib.echo({anim=time2})
								if(time1 < time2) then  time1 = time2; end
								actor.time = time1;
									--commonlib.echo({final=time1})
							end
						end	
					end
					-- advance time in reverse direction. 
					actor.time = actor.time - deltaTime*(actor.speedscale or 1);
					if(actor.time < 0) then
						actor.time = 0;
					end
				elseif(actor:IsPlaying()) then	
					-------------------------------
					-- playing by sequence
					-------------------------------
					--commonlib.echo({"ReversePlaying", actor.time})
					count = count +1;
					
					local time = actor.TimeSeries.x:GetLastTime();
					if(time==nil or (time+self.timerInterval)<actor.time) then
						-- if we have reached the end of animation (use x variable for checking), we will pause. 
						actor:Pause();
						player:ToCharacter():SetSpeedScale(1);
					else
						-- play animation
						local new_x = actor.TimeSeries.x:getValue(1, actor.time);
						local new_y = actor.TimeSeries.y:getValue(1, actor.time);
						local new_z = actor.TimeSeries.z:getValue(1, actor.time);
						
						if(actor.time ~= 0 and actor.UseRelativePos and actor.r_x~=nil) then
							new_x = new_x+actor.r_x;
							new_y = new_y+actor.r_y;
							new_z = new_z+actor.r_z;
						end
						
						--log(string.format("(%d): %f %f %f\n", actor.time, new_x, new_y, new_z));
						
						local x,y,z = player:GetPosition();
						local deltaXZ = math.abs(x-new_x) + math.abs(z-new_z);
						
						local deltaY = math.abs(y-new_y);
						local reachedPos;
						
						if(actor.time == 0) then
							-- if this is the first frame, just set at precise location and facing
							if(actor.UseRelativePos) then
								actor.r_x = x-new_x;
								actor.r_y = y-new_y;
								actor.r_z = z-new_z;
								--log(string.format("%s abs pos %f %f %f\n", actor.name, x,y,z));
								--log(string.format("%s time series pos %f %f %f\n", actor.name, new_x,new_y,new_z));
								--log(string.format("%s relative pos %f %f %f\n", actor.name, actor.r_x, actor.r_y, actor.r_z));
								new_x = x;
								new_y = y;
								new_z = z;
							else
								player:SetPosition(new_x, new_y, new_z);
								player:UpdateTileContainer();		
							end
							reachedPos = true;
						elseif(deltaXZ>0.1 and deltaY<100) then
							player:ToCharacter():GetSeqController():MoveTo(new_x-x, new_y-y, new_z-z);
						elseif((deltaXZ+deltaY)>0.01 or deltaY > 100) then
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
							local facing = actor.TimeSeries.facing:getValue(1, actor.time);
							if(facing~=nil) then
								if(math.abs(player:GetFacing()-facing)>0.01) then
									player:SetFacing(facing);
								end	
							end	
							
							-- set animation ID or filename
							local anim = actor.TimeSeries.anim:getValue(1, actor.time);
							
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
						--local GTwo; -- whether needs to update group 2
						--local mod_msg = {
							--type = Map3DSystem.msg.OBJ_ModifyObject, 
							--silentmode = true, 
							---- forcelocal = true,
							--obj_params = {
								--name = actor.name,
								--IsCharacter = true,
							--},
						--}
						---- set scaling if any 
						--local scaling = actor.TimeSeries.scaling:getValue(1, actor.time);
						--if(math.abs(player:GetScale()-scaling)>0.01) then
							--mod_msg.scale = self.scaling;
							--GTwo = true;
						--end
						--
						---- change appearance if any
						--local AssetFile = actor.TimeSeries.AssetFile:getValue(1, actor.time);
						--if(AssetFile ~= player:GetPrimaryAsset():GetKeyName()) then
							--mod_msg.asset_file = AssetFile;
							--GTwo = true;
						--end
						--
						--if(GTwo) then
							--Map3DSystem.SendMessage_obj(mod_msg);
						--end
						--
						---- ccs appearance
						--local new_ccs = actor.TimeSeries.ccs:getValue(1, actor.time);
						--local ccs = Map3DSystem.UI.CCS.GetCCSInfoString(player)
						--if(ccs~=new_ccs) then
							--Map3DSystem.UI.CCS.ApplyCCSInfoString(player, new_ccs);
						--end
						
						-- advance time
						actor.time = actor.time + deltaTime;
					end
				end
			else
				-- Mark the actor name to be deleted after the iteration
				Invalidactors = Invalidactors or {};
				Invalidactors[actor.name] = true;
				log(actor.name.." is removed from recorder since not found\n")
			end	
		end	
	end
	
	-- delete invalid actors
	if(Invalidactors~=nil) then
		local key, _;
		for key, _ in pairs(Invalidactors) do
			Recorder.RemoveActor(key);
		end
	end
		
	-- disable timer if no active actor	
	if (count == 0)	then
		self.EnableTimer(false);
	end
end