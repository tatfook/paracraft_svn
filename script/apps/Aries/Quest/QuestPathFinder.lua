--[[
Title: Quest path finder
Author(s): Clayman
Date: 2011/10/22
use the lib:
------------------------------------------------------------
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/Graph.lua");
NPL.load("(gl)script/ide/GraphHelp.lua");
local graphHelp = commonlib.gettable("commonlib.GraphHelp");
NPL.load("(gl)script/apps/Aries/Desktop/MapArea.lua");

NPL.load("(gl)script/apps/Aries/Quest/WaypointProvider.lua");
local WaypointProvider = commonlib.gettable("MyCompany.Aries.Quest.WaypointProvider");
local MapArea = commonlib.gettable("MyCompany.Aries.Desktop.MapArea");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local QuestPathfinder = commonlib.gettable("MyCompany.Aries.Quest.QuestPathFinder");
QuestPathfinder.curLocation = nil;
QuestPathfinder.waypointProvider = nil;
QuestPathfinder.target = nil;
QuestPathfinder.path = nil;
QuestPathfinder.needTranspot = false;
QuestPathfinder.findPath = false;
QuestPathfinder.failedRefreshDist = 0;
QuestPathfinder.currentWp = nil;
QuestPathfinder.lastWp = nil;
QuestPathfinder.navInfoCallback = nil;
QuestPathfinder.hideUI = false;

local quest_map_point = {
	background = "Texture/Aries/Common/ThemeTeen/others/quest_jump_32bits.png",
	width = 16,
    height = 16,
	zorder = 1,
}

-- set new target point
-- @param location = {x,y,z,facing, camPos,worldInfo,radius, targetName}
function QuestPathfinder:SetTarget(location)
	self:Reset();
	
	if (location) then
		self.target = location;
		self.target.radius = location.radius or 15;
		self.failedRefreshDist = 100000;

		if(location.worldInfo.name == WorldManager:GetCurrentWorld().name)  then
			-- only show on map if target is within the current world. 
			quest_map_point.x = location.x;
			quest_map_point.y = location.z;
			-- quest_map_point.tooltip = location.targetName;
			quest_map_point.text = location.targetName;
			MapArea.ShowPoint("quest", quest_map_point, true);

			-- in case there is no waypoint infor in current world. 
			if(not WaypointProvider.IsInOpenWorld(location.worldInfo.name)) then
				self.target = nil;
				self.hideUI = true;
				self:UpdateDisplay();
			end
		else	
			MapArea.ShowPoint("quest", nil, true);
		end
		return true;
	else
		self.target = nil;
		MapArea.ShowPoint("quest", nil, true);
		self.hideUI = true;
		self:UpdateDisplay();
		return false;
	end
end

-- get target
function QuestPathfinder:GetTarget()
	return self.target;
end

-- get the current way point
function QuestPathfinder:GetCurWayPoint()
	return self.currentWp;
end

--newLocation = {x,y,z,facing,worldInfo}
function QuestPathfinder:OnPlayerMove(newLocation)
	if(self.target == nil)then
		self:UpdateDisplay();
		return;
	end
	if(not self.curLocation)then
		self.curLocation = newLocation;
		self.findPath = false;
		self:UpdateDisplay();
		self.failedRefreshDist = 100000;
		-- return;
	end
	
	--disable pathfinding in world without waypoint information, such as intanced world.
	if(not WaypointProvider.IsInOpenWorld(newLocation.worldInfo.name))then
		self.findPath = false;
		-- tricky: we will tell the user where the target is by text only if no waypoint info is available in current world. 
		self.needTranspot = true; 
		self:UpdateDisplay();
		return;
	end

	--transpot to a new world,find new path
	if(self.curLocation.worldInfo ~= newLocation.worldInfo)then
		self.findPath = false;
		self.failedRefreshDist = 100000;
	end

	if(self.findPath == false)then
		--try to find a new path evey 20(20^2=400) meter if we don't have a path yet
		if(self.failedRefreshDist > 400)then
			self.failedRefreshDist = 0;
			self:SearchPath();
		else
			self.failedRefreshDist = self.failedRefreshDist + math.sqrt(QuestPathfinder.DistSqare(self.curLocation,newLocation));
		end

		--still can't find a path-.-
		if(not self.findPath)then
			self.curLocation = newLocation;
			self:UpdateDisplay();
			return;
		else
			self.currentWp = self.path[#(self.path)];
			self.lastWp = nil;
		end
	end

	--where are we ?
	local force_recheck = false;
	if( QuestPathfinder.DistSqare(self.curLocation, newLocation) >= 20*20) then
		force_recheck = true;
	end 

	self.curLocation = newLocation;
	local dist2 = QuestPathfinder.DistSqare(self.curLocation,self.currentWp);
	if(dist2 <= (self.currentWp.radius*self.currentWp.radius))then  --case1: enter new waypoint
		local wpCount = #(self.path);
		if(wpCount > 1)then     --not final target? remove it!
			self.lastWp = self.currentWp;
			self.currentWp = self.path[wpCount-1];
			table.remove(self.path);
		end
		self:UpdateDisplay();
		return;
	else
		if(self.lastWp)then
			local d2LastWp = QuestPathfinder.DistSqare(self.curLocation,self.lastWp);
			if(d2LastWp < (self.lastWp.radius*self.lastWp.radius))then
				--case 2: in last waypoint
				self:UpdateDisplay();
				return;
			end
		end

		--case 3 :not in any waypoint
		local graph = WaypointProvider.GetWaypointGraph(self.curLocation.worldInfo.name);
		if(not graph)then
			self.findPath = false;
			self:UpdateDisplay();
			return;
		end

		-- if the player location changed a lot since last move we will run a recheck. 
		if(force_recheck) then
			local nearestNode = QuestPathfinder.FindNearestWaypoint(graph,self.curLocation);

			--nearest waypoint is current target, we're heading to the right direction
			if(nearestNode:GetData() == self.currentWp)then
				self:UpdateDisplay();
				return;
			end

			--nearest waypoint is last target, fall back one step
			if(self.lastWp and nearestNode:GetData() == self.lastWp)then
				local deltaDist = QuestPathfinder.DistSqare(self.lastWp,self.currentWp);
				local dist2Cur = QuestPathfinder.DistSqare(self.curLocation,self.currentWp);

				if(dist2Cur > deltaDist)then
					table.insert(self.path,self.lastWp);
					self.currentWp = self.lastWp;
					self.lastWp = nil;
				end

				self:UpdateDisplay();
				return;
			end

			--worst case not in known path, try to find new one
			self:SearchPath();
			if(self.findPath)then
				self.currentWp = self.path[#(self.path)];
			else
				self.currentWp = nil;
				self.failedRefreshDist = 0;
			end
			self.lastWp = nil;
		end

		self:UpdateDisplay();
	end
end

function QuestPathfinder:SearchPath()
	--need transpot to other world first?
	self.needTranspot = false;
	self.currentWp = nil;
	self.path = nil;
	self.lastWp = false;

	if(self.curLocation.worldInfo ~= self.target.worldInfo)then
		self.needTranspot = true;
	end

	local graph = WaypointProvider.GetWaypointGraph(self.curLocation.worldInfo.name);
	if(graph == nil)then
		self.findPath = false;
		return;
	end

	local startWp = QuestPathfinder.FindNearestWaypoint(graph,self.curLocation);

	local endWp;
	if(self.needTranspot)then
		endWp = QuestPathfinder.FindTranspotPoint(graph);
	else
		endWp = QuestPathfinder.FindNearestWaypoint(graph,self.target);
	end

	if((startWp == nil) or (endWp == nil))then
		self.findPath = false;
		return;
	end

	if(startWp == endWp)then
		if(self.needTranspot)then
			self.path = {startWp:GetData()};
		else
			local dist1 = QuestPathfinder.DistSqare(self.curLocation,startWp:GetData());
			local dist2 = QuestPathfinder.DistSqare(self.curLocation,self.target);
			if(dist1 < dist2)then
				self.path = {self.target,startWp:GetData()};
			else
				self.path = {self.target};
			end
		end
		self.findPath = true;
		return;
	end

	__,self.path = graphHelp.Search_Astar(graph,startWp,endWp);
	if(self.path == nil)then
		self.findPath = false;
		return;
	end
	
	if(not self.needTranspot)then
		table.insert(self.path,1,self.target);
	end

	--optimize path
	local removeIndex = #(self.path) + 1;
	for i=#(self.path),2,-1 do
		local wp = self.path[i];
		local dist2 = QuestPathfinder.DistSqare(self.curLocation,wp);
		if(dist2 < (wp.radius*wp.radius))then
			removeIndex = i;
		end
	end
	for i=#(self.path),removeIndex+1,-1 do
		table.remove(self.path);
	end
	self.lastWp = nil;
	self.currentWp = self.path[#(self.path)];
	self.findPath = true;
end

function QuestPathfinder.FindTranspotPoint(graph)
	for node in graph:Next() do
		if(node:GetData().isTranspotNode)then
			return node;
		end
	end
end

function QuestPathfinder:Reset()
	self.curLocation = nil;
	self.target = nil;
	self.path = nil;
	self.needTranspot = false;
	self.findPath = false;
	self.failedRefreshDist = 0;
	self.currentWp = nil;
	self.lastWp = nil;
	MapArea.ShowPoint("quest", nil);
	self:UpdateDisplay();
end

function QuestPathfinder:OnHideUI(isHide)
	QuestPathfinder.hideUI = isHide;
end

function QuestPathfinder.FindNearestWaypoint(graph,position)
	--local list = graph.nodes;
	--local item = list:first();
	
	--if(item)then
	   --minDist = QuestPathfinder.DistSqare(position,item:GetData());
	--else
		--minDist = 4294967295;
	--end
	--minDist = 4294967295

	--local minDist = 4294967295;
	--lo*cal result = nil;
	--for node in graph:Next() do
		--local data = node:GetData();
		--local dist = QuestPathfinder.DistSqare(position,data);
		--if(dist <= minDist) then
			--minDist = dist;
			--result = node;
		--end
	--end
	--return result;

	local result = nil;
	local result1 = nil;
	local minDist1 = 4294967295;
	local minDist = 4294967295;
	for node in graph:Next() do
		local data = node:GetData();
		local dist2Wp = QuestPathfinder.DistSqare(position,data);
		local radius = data.radius or 5;
		local wpRegion = radius * radius;
		if(dist2Wp <= minDist)then
			minDist = dist2Wp;
			result = node;
		end
		if(dist2Wp < wpRegion)then
			if(dist2Wp <= minDist1)then
				result1 = node;			
				minDist1 = dist2Wp;
			end
		end
	end

	return result1 or result;
end

function QuestPathfinder:UpdateDisplay()
	if(self.navInfoCallback == nil)then
		return;
	end

	if(self.findPath == false or self.hideUI)then
		if(self.needTranspot and not self.hideUI and self.target)then
			local targetName = "";
			if(self.target.targetName)then
				targetName = "("..self.target.targetName..")";
			end
			self.navInfoCallback(format("目标%s在%s", targetName, self.target.worldInfo.world_title), 0, false);
		else
			self.navInfoCallback("",0,false);
		end
		return;
	end
	
	-- removedtricky: the meters are too big /4
	local dist = math.floor(self:CalcDistance());
	local targetFacing = math.atan2(self.currentWp.z - self.curLocation.z,self.currentWp.x - self.curLocation.x);
	local deltaAngle = -targetFacing - self.curLocation.facing;
	
	
	if((self.target and dist < self.target.radius) and #(self.path)==1)then
		if(self.needTranspot)then
			self.navInfoCallback(format("让法斯特船长带你到%s", self.target.worldInfo.world_title),deltaAngle,false);
		else
			local targetName = "";
			if(self.target and self.target.targetName)then
				targetName = "("..self.target.targetName..")";
			end
			self.navInfoCallback(format("已到达目的地%s附近", targetName), deltaAngle,false);
		end
	else	
		if(self.needTranspot)then
			self.navInfoCallback(format("%d米到达传送点", dist), deltaAngle,true, dist);
		else
			local targetName = "";
			if(self.target and self.target.targetName)then
				targetName = ":"..self.target.targetName;
			end
			self.navInfoCallback(format("%d米到达目标%s", dist, targetName), deltaAngle,true,dist);
		end
	end
end

function QuestPathfinder:CalcDistance()
	local dist;
	if(self.curLocation and self.currentWp) then
		dist = math.sqrt(QuestPathfinder.DistSqare(self.curLocation,self.currentWp));
		local wpCount = #(self.path);
		while(wpCount > 1)do
			dist = dist + math.sqrt(QuestPathfinder.DistSqare(self.path[wpCount],self.path[wpCount-1]));
			wpCount = wpCount - 1;
		end
	end
	return dist or 9999;
end

function QuestPathfinder.DistSqare(v0,v1)
	local dx = v0.x - v1.x;
	local dz = v0.z - v1.z;
	return dx*dx + dz*dz;
end


 