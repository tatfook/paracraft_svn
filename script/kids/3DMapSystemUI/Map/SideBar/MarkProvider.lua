--[[
Title: mcml 2d map mark data provider
Author(s): LiXizhi, Leio zhang, refactored by LiXizhi 2008.2.11
Date: 2008/1/25
Desc: it loads and saves data from local disk and web services. 
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/MarkProvider.lua");
-------------------------------------------------------
]]
if(not Map3DApp.MarkProvider)then Map3DApp.MarkProvider={};end

-- the map object for the local user. 
Map3DApp.MarkProvider.MyMapTree=nil;
-- default name of the local my map file. it is always in the map app folder. 
Map3DApp.MarkProvider.MyMapFile="mymap.map";

--------------------------------------------
-- my map related
--------------------------------------------

-- call this to load my map from local disk.
function Map3DApp.MarkProvider.Init()
	Map3DApp.MarkProvider.GetMyMap();
end

-- get the current user's map, it will retrieve it if not loaded before. If loading failed it will create a new map as the current user map.
function Map3DApp.MarkProvider.GetMyMap()
	if(not Map3DApp.MarkProvider.MyMapTree) then
		-- load from file is not loaded before. 
		Map3DApp.MarkProvider.MyMapTree = Map3DApp.MarkProvider.LoadMap(Map3DApp.MarkProvider.MyMapFile);
		if(not Map3DApp.MarkProvider.MyMapTree)then
			-- If loading failed it will create a new map as the current user map.
			Map3DApp.MarkProvider.MyMapTree = Map3DApp.MarkProvider.NewMap();
		end
	end
	return Map3DApp.MarkProvider.MyMapTree;
end

-- save map map to the default local file folder. 
function Map3DApp.MarkProvider.SaveLocalMyMap()
	Map3DApp.MarkProvider.SaveMap(Map3DApp.MarkProvider.MyMapTree, Map3DApp.MarkProvider.MyMapFile)
end

--------------------------------------------
-- map to/from disk functions
--------------------------------------------

-- create an empty map without any folder
function Map3DApp.MarkProvider.NewMap()
	return Map3DApp.mapInfo:new();
end

-- Load map from a file.
-- return the map object. it may return nil if failed. 
function Map3DApp.MarkProvider.LoadMap(filename)
	local file = Map3DSystem.App.Map.app:openfile(filename, "r");
	if(file:IsValid())then
	    local mapInfo = commonlib.LoadTableFromString(file:GetText());
	    mapInfo = Map3DApp.mapInfo:new(mapInfo);
	    file:close();
	    
		local k,folderInfo
		for k,folderInfo in ipairs(mapInfo) do
			local temp={}
			folderInfo = Map3DApp.folderInfo:new(folderInfo);
			if(folderInfo.list)then
				local kk,markInfo
				for kk,markInfo in ipairs(folderInfo.list) do
					markInfo = Map3DApp.markInfo:new(markInfo);
				end
			end
			table.insert(temp,v);
		end
		return mapInfo;
	end
end

-- save a map object to a given file. 
-- @param map: the map object
-- @param filename: where to save the file. 
function Map3DApp.MarkProvider.SaveMap(map, filename)
	if(map)then
		local file = Map3DSystem.App.Map.app:openfile(filename, "w");
		if(file:IsValid()) then
			commonlib.serializeToFile(file, map);
			file:close();
		end
	end
end



