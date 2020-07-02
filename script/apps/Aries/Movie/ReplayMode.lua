--[[
Title: Replay the current player's action in history
Author(s): LiXizhi
Company: ParaEnging Co. & Taomee Inc.
Date: 2010/1/8
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Movie/ReplayMode.lua");
MyCompany.Aries.Movie.ReplayMode.Restart();
MyCompany.Aries.Movie.ReplayMode.Replay();
MyCompany.Aries.Movie.ReplayMode.ReversePlay()
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Movie/PlayerRecorder.lua");
NPL.load("(gl)script/apps/Aries/Movie/TimeEffect.lua");

local ReplayMode = commonlib.gettable("MyCompany.Aries.Movie.ReplayMode")

local Recorder = commonlib.gettable("MyCompany.Aries.Movie.Recorder")
local Actor = commonlib.gettable("MyCompany.Aries.Movie.Actor")

-- the play speedscale, where 1.0 is the original speed. 
ReplayMode.speedscale = 2;
-- the main actor
local main_actor;

-- reset time and start from the beginning. 
function ReplayMode.Restart()
	main_actor = Recorder.CreateGetActor(ParaScene.GetPlayer().name);
	main_actor:Rewind();
	main_actor:Record();
	
	commonlib.log("ReplayMode.Restart: \n")
	
	-- make it default character movement style
	local player = ParaScene.GetPlayer()
	player:GetAttributeObject():SetField("MovementStyle", 0)
	player:ToCharacter():SetSpeedScale(1);
	
	MyCompany.Aries.Movie.TimeEffect:StopEffect();
end

function ReplayMode.IsRecording()
	if(main_actor) then
		return main_actor:IsRecording()
	else
		return true;	
	end	
end

function ReplayMode.StopEffect()
	MyCompany.Aries.Movie.TimeEffect:StopEffect();
end

function ReplayMode.IsPlaying()
	if(main_actor) then
		return main_actor:IsPlaying()
	end	
end

function ReplayMode.IsPaused()
	if(main_actor) then
		return main_actor:IsPaused()
	end	
end

function ReplayMode.IsReversePlaying()
	if(main_actor) then
		return main_actor:IsReversePlaying()
	end	
end

-- reset time and start from the beginning. 
function ReplayMode.Replay()
	if(main_actor) then
		main_actor:Rewind();
		main_actor:Play();
		
		-- make it OPC movement style
		local player = ParaScene.GetPlayer()
		player:GetAttributeObject():SetField("MovementStyle", 4)
		player:ToCharacter():SetSpeedScale(1);
		
		MyCompany.Aries.Movie.TimeEffect:StopEffect();
	end	
end

-- Play forward from the current location. 
function ReplayMode.Play()
	if(main_actor) then
		commonlib.log("ReplayMode.Play: \n")
		main_actor:Play();
		
		-- make it OPC movement style
		local player = ParaScene.GetPlayer()
		player:GetAttributeObject():SetField("MovementStyle", 4)
		player:ToCharacter():SetSpeedScale(1);
		
		MyCompany.Aries.Movie.TimeEffect:StopEffect();
	end	
end

-- play into history from current location
function ReplayMode.ReversePlay()
	if(main_actor) then
		commonlib.log("ReplayMode.ReversePlay: \n")
		main_actor.speedscale = ReplayMode.speedscale or 1;
	
		-- make it OPC movement style
		local player = ParaScene.GetPlayer()
		player:GetAttributeObject():SetField("MovementStyle", 4)
		player:ToCharacter():SetSpeedScale(main_actor.speedscale);
		
		MyCompany.Aries.Movie.TimeEffect:StartEffect();
		main_actor:ReversePlay();
	end	
end

-- resume recording from the current location. 
function ReplayMode.ResumeRecord()
	main_actor = Recorder.CreateGetActor(ParaScene.GetPlayer().name);
	main_actor:Record();
	
	commonlib.log("ReplayMode.ResumeRecord: \n")
	
	-- make it default character movement style
	local player = ParaScene.GetPlayer()
	player:GetAttributeObject():SetField("MovementStyle", 0)
	player:ToCharacter():SetSpeedScale(1);
	
	-- ensure that player is on top of terrain. 
	local x,y,z = player:GetPosition();
	local terra_y = ParaTerrain.GetElevation(x,z);
	if(terra_y > y) then
		player:SetPosition(x,terra_y,z);
	end
	
	MyCompany.Aries.Movie.TimeEffect:StopEffect();
end

-- set the play speedscale
-- @param speedscale: the play speed scale, where 1.0 is the original speed. 
function ReplayMode.SetPlaySpeed(speedscale)
	ReplayMode.speedscale = speedscale or 1;
	if(main_actor) then
		main_actor.speedscale = ReplayMode.speedscale or 1;
		if(main_actor:IsReversePlaying()) then
			local player = ParaScene.GetPlayer()
			player:ToCharacter():SetSpeedScale(main_actor.speedscale);	
		end
	end
end
