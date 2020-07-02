
--[[
Title: terrain region data provider
Author(s): SunLingfeng
Date: 2012/4/27
Desc: 
 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Scene/TerrainRegionProvider.lua");
------------------------------------------------------------
]]

local TerrainRegionProvider = commonlib.gettable("MyCompany.Aries.TerrainRegionProvider");

TerrainRegionProvider.onBgSoundRegionChanged = nil;
TerrainRegionProvider.onAmbSoundRegionChanged = nil;

TerrainRegionProvider.timer = nil;
TerrainRegionProvider.updateInterval = 500;
TerrainRegionProvider.bgSoundConfig = {id = 2,mask=4294967233,bitOffset=1,maxValue=31};
TerrainRegionProvider.ambSoundConig = {id = 3,mask=4294965311,bitOffset=6, maxValue=31};
TerrainRegionProvider.terrainTypeConig = {id = 4,mask = 4294903807,bitOffset=11,maxValue=31};

TerrainRegionProvider.bgRegionValue = -1;
TerrainRegionProvider.ambRegionValue = -1;
TerrainRegionProvider.enabled = false;

------------------------------------------------------------------------
local RegionSoundMapping = commonlib.gettable("MyCompany.Aries.RegionSoundMapping");
RegionSoundMapping.BgSound = {};
RegionSoundMapping.AmbSound = {};
------------------------------------------------------------------------


function TerrainRegionProvider.EnableIfExist(worldName)
	local self = TerrainRegionProvider;

	local enable = false;
	if(worldName ~= nil)then
		local dataEntry = RegionSoundMapping.BgSound[worldName];
		if(dataEntry ~= nil)then
			enable = true;
		end
	end
	
	if(self.enabled == enable)then
		return;
	end

	self.enabled = enable;
	if(self.enabled)then
		self.timer = self.timer or commonlib.Timer:new({callbackFunc=TerrainRegionProvider.OnTimer});	
		self.timer:Change(0,self.updateInterval);
	else
		if(self.timer ~= nil)then
			self.timer:Change();
		end
	end
end

function TerrainRegionProvider.Reset()
	TerrainRegionProvider.bgRegionValue = -1;
	TerrainRegionProvider.ambRegionValue = -1;
end

function TerrainRegionProvider.GetBgSoundRegionValue(x,z)
	return ParaTerrain.GetTerrainData(x,z,self.bgSoundConfig.mask,self.bgSoundConfig.bitOffset);
end

function TerrainRegionProvider.GetAmbSoundRegionValue(x,z)
	return ParaTerrain.GetTerrainData(x,z,self.ambSoundConig.mask,self.ambSoundConig.bitOffset);
end
 
function TerrainRegionProvider.OnTimer()
	local self = TerrainRegionProvider;	

	local x,y,z = ParaScene.GetPlayer():GetPosition();
	local bgValue = ParaTerrain.GetTerrainData(x,z,self.bgSoundConfig.mask,self.bgSoundConfig.bitOffset);
	local ambValue = ParaTerrain.GetTerrainData(x,z,self.ambSoundConig.mask,self.ambSoundConig.bitOffset);
	
	if(bgValue ~= self.bgRegionValue)then
		self.bgRegionValue = bgValue;
		if(self.onBgSoundRegionChanged ~= nil)then
			self.onBgSoundRegionChanged(bgValue);
		end
	end
	
	if(ambValue ~= self.ambRegionValue)then
		self.ambRegionValue = ambValue;
		if(self.onAmbSoundRegionChanged ~= nil)then
			self.onAmbSoundRegionChanged(ambValue);
		end
	end	
end


-------------------Haqi island----------------------
RegionSoundMapping.BgSound["61HaqiTown_teen"] = {};
local map = RegionSoundMapping.BgSound["61HaqiTown_teen"];
map[0] = "HaqiIslandBgMusic_teen";
map[1] = "HaqiTownBgMusic_teen";
map[2] = "HaqiIslandBgMusic_teen";
map[3] = "HaqiIslandBgMusic_teen";
map[4] = "HaqiIslandBgMusic_teen";
map[5] = "HaqiTownBgMusic_teen";
map[6] = "HaqiIslandBgMusic_teen";
map[7] = "HaqiIslandBgMusic_teen";
map[8] = "HaqiIslandBgMusic_teen";
map[9] = "Area_HaqiTown_DragonGlory_teen";
map[10] = "HaqiTownBgMusic_teen";

RegionSoundMapping.AmbSound["61HaqiTown_teen"] = {};
map = RegionSoundMapping.AmbSound["61HaqiTown_teen"];
map[0] =  "ambSeaside";
map[1] =  "ambForest";
map[2] =  "ambGrassland";
map[9] =  "ambTown";
map[10] = "ambTownMarket";


-------------------phoenix island----------------------
RegionSoundMapping.BgSound["FlamingPhoenixIsland"] = {};

RegionSoundMapping.AmbSound["FlamingPhoenixIsland"] = {};
map = RegionSoundMapping.AmbSound["FlamingPhoenixIsland"];
map[0] = "ambSeaside";
map[1] = "ambPhoenixIsland";
map[2] = "ambLava";


-------------------ice island----------------------
RegionSoundMapping.BgSound["FrostRoarIsland"] = {};

RegionSoundMapping.AmbSound["FrostRoarIsland"] = {};
map = RegionSoundMapping.AmbSound["FrostRoarIsland"];
map[0] = "ambIceSeaSide";
map[1] = "ambSnowMountain";


-------------------sand island----------------------
RegionSoundMapping.BgSound["AncientEgyptIsland"] = {};

RegionSoundMapping.AmbSound["AncientEgyptIsland"] = {};
map = RegionSoundMapping.AmbSound["AncientEgyptIsland"];
map[0] = "ambSeaside";
map[1] = "ambDesert";


-------------------darkforest island------------------
RegionSoundMapping.BgSound["DarkForestIsland"] = {};

RegionSoundMapping.AmbSound["DarkForestIsland"] = {};
map = RegionSoundMapping.AmbSound["DarkForestIsland"];
map[0] = "ambDarkForestSea";
map[1] = "ambDarkforest";
map[2] = "ambDarkPlain";

-------------------CloudFortress island------------------
RegionSoundMapping.BgSound["CloudFortressIsland"] = {};
local map = RegionSoundMapping.BgSound["CloudFortressIsland"];
map[0] = "ambSnowMountain";
map[1] = "ambForest";
map[2] = "ambDarkforest";
map[3] = "ambTownMarket";
map[4] = "ambForest";
map[5] = "ambDarkforest";
map[6] = "ambLava";
map[7] = "ambSnowMountain";

RegionSoundMapping.AmbSound["CloudFortressIsland"] = {};


function TerrainRegionProvider.GetBgSoundName(worldName,regionId)
	local result = nil;
	if(worldName ~= nil)then
		local map = RegionSoundMapping.BgSound[worldName];
		if(map ~= nil)then
			result = map[regionId];
		end
	end
	return result;
end

function TerrainRegionProvider.GetAmbSoundName(worldName,regionId)
	local result = nil;
	if(worldName ~= nil)then
		local map = RegionSoundMapping.AmbSound[worldName];
		if(map ~= nil)then
			result = map[regionId];
		end
	end
	return result;
end