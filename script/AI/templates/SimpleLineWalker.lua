--[[ template<facing=nil, radius=nil, waitlength=nil> SimpleLineWalker character
author: LiXizhi
date: 2006.9.8
desc: walk back and forth between two points, the distance between the two points are 2*radius, 
	the line direction is given by the absolute facing. It will wait waitlength seconds at each end points. 
usage:
==On_Load==
;NPL.load("(gl)script/AI/templates/SimpleLineWalker.lua");_AI_templates.SimpleLineWalker.On_Load();
]]

if(not _AI_templates) then _AI_templates={}; end
if(not _AI_templates.SimpleLineWalker) then _AI_templates.SimpleLineWalker={}; end

_AI_templates.SimpleLineWalker.LastRadius = 2;
_AI_templates.SimpleLineWalker.LastWaitlength = 1.57;

--[[
@param facing: if nil, it will be the sensor character's facing
@param radius: if nil, it will be random between [5,10]
@param waitlength: if nil, it will be be random between [2,10]
]]
function _AI_templates.SimpleLineWalker.On_Load(facing, radius, waitlength)
	local self = _AI_templates.SimpleLineWalker;
	local player = ParaScene.GetObject(sensor_name);
	
	if(player:IsValid() == true) then 
		local playerChar = player:ToCharacter();
		
		if(facing == nil) then
			facing = player:GetFacing();
		end
		
		if(radius == nil) then
			self.LastRadius = self.LastRadius+2;
			if(self.LastRadius>=10) then
				self.LastRadius = 5;
			end
			radius = self.LastRadius;
		end
		
		if(waitlength == nil) then
			self.LastWaitlength = self.LastWaitlength+1;
			if(self.LastWaitlength>=10) then
				self.LastWaitlength = 2;
			end
			waitlength = self.LastWaitlength;
		end
	
		playerChar:AssignAIController("face", "true");
		
		local s = playerChar:GetSeqController();
		local destx,desty;
		destx=radius*math.cos(facing);
		desty=radius*math.sin(facing);
		-- delete alll previous keys
		s:DeleteKeysRange(0,-1);
		s:SetStartFacing(0);
		-- add keys
		s:BeginAddKeys();
		s:Lable("start");
		s:WalkTo(destx, 0, desty);
		s:Wait(0);
		s:Turn(facing-3.1416);
		s:Wait(waitlength);
		s:WalkTo(-2*destx, 0,-2*desty);
		s:Wait(0);
		s:Turn(facing);
		--s:Exec(string.format([[;headon_speech.Speek("%s", "你好！", 3);]], sensor_name));
		s:Wait(waitlength);
		s:Goto("start");
		s:EndAddKeys();
	end
end
