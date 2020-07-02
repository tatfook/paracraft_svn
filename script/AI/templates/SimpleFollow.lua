--[[ template<targetName=nil, radius=nil, angle=nil> SimpleFollow character
author: LiXizhi
date: 2006.9.8
desc: Follow a given character at radius and angle, and face tracking nearby character. 
usage:
==On_Load==
;NPL.load("(gl)script/AI/templates/SimpleFollow.lua");_AI_templates.SimpleFollow.On_Load();

==On_Perception==[alternative]
;NPL.load("(gl)script/AI/templates/SimpleFollow.lua");_AI_templates.SimpleFollow.On_Perception();
	
]]

if(not _AI_templates) then _AI_templates={}; end
if(not _AI_templates.SimpleFollow) then _AI_templates.SimpleFollow={}; end

_AI_templates.SimpleFollow.LastRadius = 2;
_AI_templates.SimpleFollow.LastAngle = 1.57;

--[[
@param targetName: if nil, it will be the main player's name
@param radius, angle: if nil, it will be random.between [2,5] and [-3.14,3.14]
]]
function _AI_templates.SimpleFollow.On_Load(targetName, radius, angle)
	local self = _AI_templates.SimpleFollow;
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then 
		if(targetName == nil) then
			targetName = kids_db.player.name;
		end
		if(radius == nil) then
			self.LastRadius = self.LastRadius+0.5;
			if(self.LastRadius>=5) then
				self.LastRadius = 2;
			end
			radius = self.LastRadius;
		end
		if(angle == nil) then
			self.LastAngle = self.LastAngle+0.4;
			if(self.LastAngle>=3.1416) then
				self.LastAngle = -3.1416;
			end
			angle = self.LastAngle;
		end

		local playerChar = player:ToCharacter();
		playerChar:AssignAIController("face", "true");
		playerChar:AssignAIController("follow", targetName.." "..radius.." "..angle);
	end
end

-- follow the closest object in sight.
function _AI_templates.SimpleFollow.On_Perception()
	-- do your AI code here.
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then 
		local mem = _AI.GetMemory(sensor_name);
		
		local nCount = player:GetNumOfPerceivedObject();
		local closest = nil;
		local min_dist = 100000;
		for i=0,nCount-1 do
			local gameobj = player:GetPerceivedObject(i);
			if(mem.LastFollowTarget == gameobj.name) then
				-- continue to follow old target, instead of the closest one 
				closest =gameobj;
				break;
			else
				local dist = gameobj:DistanceTo(player);
				if( dist < min_dist) then
					closest = gameobj;
					min_dist = dist;
				end
			end	
		end
		if(closest~=nil) then
			if(mem.LastFollowTarget ~= closest.name) then
				mem.LastFollowTarget = closest.name;
				_AI_templates.SimpleFollow.On_Load(mem.LastFollowTarget);
			else
				-- reenable follow controller and select new target in the next frame, if not.
				if( player:ToCharacter():IsAIControllerEnabled("follow") == false) then
					mem.LastFollowTarget = nil;
				end
			end	
		end
	end
end