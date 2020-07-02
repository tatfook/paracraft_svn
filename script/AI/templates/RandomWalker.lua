--[[ template<radius=nil,x=nil,y=nil> RandomWalker character
author: LiXizhi
date: 2006.9.8
desc: Walks randomly in a region with centered at (x,y) and radius "radius". If it is blocked by an object, a new random direction will be chosen.
usage:
==On_Load==[optional]
;NPL.load("(gl)script/AI/templates/RandomWalker.lua");_AI_templates.RandomWalker.On_Load();
==On_FrameMove==
;NPL.load("(gl)script/AI/templates/RandomWalker.lua");_AI_templates.RandomWalker.On_FrameMove();
]]

if(not _AI_templates) then _AI_templates={}; end
if(not _AI_templates.RandomWalker) then 
	-- set seed
	_AI_templates.RandomWalker={};
	math.randomseed(ParaGlobal.GetGameTime()); 
end

-- face tracking
function _AI_templates.RandomWalker.On_Load(facing, radius, waitlength)
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
function _AI_templates.RandomWalker.On_FrameMove(radius, x,y)
	local mem = _AI.GetMemory(sensor_name);
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then 
		
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
		
		if(mem.LastWalkTime==nil) then
			mem.LastWalkTime = 0;
		end
		
		local playerChar = player:ToCharacter();
		local nTime = ParaGlobal.GetGameTime();
		
		-- changes direction every 5 seconds.
		if((nTime-mem.LastWalkTime)>1000*5) then
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
