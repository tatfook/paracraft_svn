--[[
Title: AI for a summoned agent
Author(s): LiXizhi
Date: 2008/7/17
Desc: the AI of a summoned agent is to make it automatic, but reactive to the current player as well. 
<verbatim>
;NPL.load("(gl)script/AI/templates/SummonedAgent.lua");_AI_templates.SummonedAgent.On_Load();
;NPL.load("(gl)script/AI/templates/SummonedAgent.lua");_AI_templates.SummonedAgent.On_FrameMove();
</verbatim>
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/AI/templates/SummonedAgent.lua");
-------------------------------------------------------
]]

if(not _AI_templates) then _AI_templates={}; end
if(not _AI_templates.SummonedAgent) then 
	_AI_templates.SummonedAgent={};
	math.randomseed(ParaGlobal.GetGameTime()); 
end

-- face tracking
function _AI_templates.SummonedAgent.On_Load(facing, radius, waitlength)
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then 
		local playerChar = player:ToCharacter();
		playerChar:AssignAIController("face", "true");
	end
end

--[[
@param radius: region radius. if nil, it is 20
@param x: region center x, if nil, it is the current player position
@param y: region center y, if nil, it is the current player position
]]
function _AI_templates.SummonedAgent.On_FrameMove(radius, x,y)
	local mem = _AI.GetMemory(sensor_name);
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid()) then 
		
		local px,py,pz = player:GetPosition();
		
		if(radius == nil) then
			radius = 20;
		end
		if(mem.born_x==nil) then
			if(x~=nil) then
				mem.born_x = x;
			else
				mem.born_x = px;
			end
		end
		if(mem.born_y==nil) then
			if(y~=nil) then
				mem.born_y = y;
			else
				mem.born_y = pz;
			end
		end
		
		local nTime = ParaGlobal.GetGameTime();
		local playerChar = player:ToCharacter();
		
		if(mem.LastWalkTime==nil) then
			mem.LastWalkTime = nTime;
		end
		
		-- changes direction every 15 seconds.
		if((nTime-mem.LastWalkTime)>1000*15) then
			-- select a new target randomly
			local s = playerChar:GetSeqController();
			x = (math.random()*2-1)*radius + mem.born_x-px;
			y = (math.random()*2-1)*radius + mem.born_y-pz;
			--log(x..", "..y..", "..mem.born_x..", "..mem.born_y.."\r\n");
			s:WalkTo(x,0,y);
			-- save to memory
			mem.LastWalkTime = nTime;
		end
	end
end


--[[
Speek a sentence, when the character perceives another character for ReactTime. It will wait another speakInverval seconds before speeking again.
@remark: AI memory is used and demostrated here.
@param ReactTime: if nil, it will be 3 seconds.
@param speakInverval: if nil, it will default to 10 seconds
]]
function _AI_templates.SummonedAgent.On_Perception(sent, ReactTime, speakInverval)
	local mem = _AI.GetMemory(sensor_name);
	
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then 
		local playerChar = player:ToCharacter();
	end
end

--[[ say something to the player
@param nCategory: if nil, it is 1. It can be both index or string category key into _AI_tutorials table.
]]
function _AI_templates.SummonedAgent.On_Click(sCategory)
end
