

NPL.load("(gl)script/ide/GraphHelp.lua");
NPL.load("(gl)script/ide/Graph.lua");


local GraphHelper = commonlib.gettable("commonlib.GraphHelp");

local WaypointProvider = commonlib.gettable("MyCompany.Aries.Quest.WaypointProvider");
WaypointProvider.waypointGraph = nil;
WaypointProvider.worldName = nil;
WaypointProvider.openWorlds = {
	["61HaqiTown_teen"] = "config/Aries/WayPoints/61HaqiTown_teen.WayPoint.xml",
	["FlamingPhoenixIsland"] = "config/Aries/WayPoints/FlamingPhoenixIsland_teen.WayPoint.xml",
	["FrostRoarIsland"] = "config/Aries/WayPoints/FrostRoarIsland_teen.WayPoint.xml",
	["DarkForestIsland"] = "config/Aries/WayPoints/DarkForestIsland_teen.WayPoint.xml",
	["AncientEgyptIsland"] = "config/Aries/WayPoints/AncientEgyptIsland_teen.WayPoint.xml",
	["CloudFortressIsland"] = "config/Aries/WayPoints/CloudFortressIsland_teen.WayPoint.xml",
};

function WaypointProvider.GetWaypointGraph(worldName)
	if(not WaypointProvider.IsInOpenWorld(worldName))then
		return nil;
	end
	
	if(WaypointProvider.worldName ~= worldName)then
		WaypointProvider.worldName = worldName;
		local file = WaypointProvider.GetWaypointFile(worldName);
		if(file~= nil and file~="")then
			WaypointProvider.waypointGraph = GraphHelper.BuildGraph(file);
		else
			WaypointProvider.waypointGraph = nil;
		end
	end
	
	return WaypointProvider.waypointGraph;
end

function WaypointProvider.GetWaypointFile(worldName)
	return WaypointProvider.openWorlds[worldName];
end

function WaypointProvider.IsInOpenWorld(worldName)
	if(WaypointProvider.openWorlds[worldName])then
		return true;
	end
	return false;
end