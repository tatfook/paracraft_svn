
--[[
Title: 
Author(s): Clayman
Date: 2010/6/29
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script");
-------------------------------------------------------
]]


local AriesSoundEffectConfig = commonlib.gettable("AudioEngine.AriesSoundEffectConfig");
  
AriesSoundEffectConfig.ID = "sound";
AriesSoundEffectConfig.currentWorld = nil;
AriesSoundEffectConfig.currentPos = {};
AriesSoundEffectConfig.infoValue = 0;
AriesSoundEffectConfig.bgSoundMap = nil;
AriesSoundEffectConfig.envSoundMap = nil;
AriesSoundEffectConfig.footstepMap = nil;
AriesSoundEffectConfig.defaultBgMusic = nil;

--location = {x,y}
function AriesSoundEffectConfig.UpdateTerrainInfo(location)
	if(location.x ~= AriesSoundEffectConfig.currentPos.x or location.y ~= AriesSoundEffectConfig.currentPos.y)then
		AriesSoundEffectConfig.infoValue = ParaTerrain.GetRegionValue("sound",location.x,location.y);
		AriesSoundEffectConfig.currentPos.x = location.x;
		AriesSoundEffectConfig.currentPos.y = location.y;
	end
end

local GroundType =  commonlib.gettable("AudioEngine.AriesSoundEffectConfig.GroundType");
GroundType.Dirt = 10;
GroundType.Sand = 20;
GroundType.Grass = 30;
GroundType.Rock = 40;
GroundType.Wood = 50;
GroundType.Water= 60;
GroundType.Snow = 70;


--location = {x,y}
function AriesSoundEffectConfig.GetGroundMaterial(location)
	AriesSoundEffectConfig.UpdateTerrainInfo(location);
	local r,g,b,a = _guihelper.DWORD_TO_RGBA(AriesSoundEffectConfig.infoValue);

	if(r == GroundType.Dirt)then
		return GroundType.Dirt;
	elseif(r == GroundType.Sand)then
		return GroundType.Sand;
	elseif(r == GroundType.Grass)then
		return GroundType.Grass;
	elseif(r == GroundType.Rock)then
		return GroundType.Rock;
	elseif(r == GroundType.Wood)then
		return GroundType.Wood;
	elseif(r == GroundType.Water)then
		return GroundType.Water;
	elseif(r == GroundType.Snow)then
		return GroundType.Snow;
	else
		return GroundType.Dirt;
	end
end



AriesSoundEffectConfig.flyingMount = {};
AriesSoundEffectConfig.flyingMount["character/v6/02animals/MagicBesom/MagicBesom.x"] = true;
AriesSoundEffectConfig.flyingMount["character/v5/02animals/HorsePhoenix/HorsePhoenix.x"] = true;

--[[
AriesSoundEffectConfig.flyingMount["character/v5/02animals/BlueDragon/BlueDragon.x"] = true;
AriesSoundEffectConfig.flyingMount["character/v5/02animals/GoldenDragon/GoldenDragon.x"] = true;
AriesSoundEffectConfig.flyingMount["character/v5/02animals/WhiteDragon/WhiteDragon.x"] = true;
AriesSoundEffectConfig.flyingMount["character/v5/02animals/GreenDragon/GreenDragon.x"] = true;
AriesSoundEffectConfig.flyingMount["character/v5/02animals/ChasingWindEagle/ChasingWindEagle.x"] = true;
AriesSoundEffectConfig.flyingMount["character/v5/02animals/Pegasus_Black/Pegasus_Black.x"] = true;
AriesSoundEffectConfig.flyingMount["character/v5/02animals/Pegasus/Pegasus.x"] = true;
--]]

function AriesSoundEffectConfig.IsFlyingMount(name)
	return AriesSoundEffectConfig.flyingMount[name];
end


local AmbienceSoundType = commonlib.gettable("MyCompany.Aries.AmbienceSoundType");
AmbienceSoundType.Forest = 10;
AmbienceSoundType.Grassland = 20;
AmbienceSoundType.City = 30;
AmbienceSoundType.Ocean = 40;

local AmbienceSounds = commonlib.gettable("MyCompany.Aries.AmbienceSounds");
function AriesSoundEffectConfig.GetAmbSoundName(id)
	if(id == AmbienceSoundType.Forest)then
		return "ambForest";
	elseif(id == AmbienceSoundType.Grassland)then
		return "ambGrassland";
	elseif(id == AmbienceSoundType.City)then
		return nil;
	elseif(id == Ocean)then
		return "ambOcean";
	else
		return nil;
	end
end