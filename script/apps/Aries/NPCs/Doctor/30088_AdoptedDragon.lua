--[[
Title: AdoptedDragon
Author(s): WangTian
Date: 2009/8/24

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30088_AdoptedDragon.lua
------------------------------------------------------------
]]

-- create class
local libName = "AdoptedDragon";
local AdoptedDragon = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.AdoptedDragon", AdoptedDragon);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- AdoptedDragon.main
function AdoptedDragon.main()
	local instance;
	for instance = 1, 8 do
		local npcChar = NPC.GetNpcCharacterFromIDAndInstance(30088, instance);
		if(npcChar and npcChar:IsValid()) then
			local assetfile = "character/v3/PurpleDragonEgg/PurpleDragonEgg.xml";
			if(instance <= 3) then
				assetfile = "character/v3/PurpleDragonEgg/PurpleDragonEgg.xml";
			elseif(instance <= 6) then
				assetfile = "character/v3/PurpleDragonMinor/PurpleDragonMinor.xml";
			else
				assetfile = "character/v3/PurpleDragonMajor/Female/PurpleDragonMajorFemale.xml";
			end
			local asset = ParaAsset.LoadParaX("", assetfile);
			local npcCharChar = npcChar:ToCharacter();
			npcCharChar:ResetBaseModel(asset);
			
			local replaceable_r1;
			if(instance <= 3) then
				if(instance == 1) then
					replaceable_r1 = "character/v3/PurpleDragonEgg/SkinColor03.dds";
				elseif(instance == 2) then
					replaceable_r1 = "character/v3/PurpleDragonEgg/SkinColor04.dds";
				elseif(instance == 3) then
					replaceable_r1 = "character/v3/PurpleDragonEgg/SkinColor01.dds";
				end
				npcChar:SetReplaceableTexture(1, ParaAsset.LoadTexture("", replaceable_r1, 1));
			elseif(instance <= 6) then
				if(instance == 4) then
					replaceable_r1 = "character/v3/PurpleDragonMinor/SkinColor01.dds";
				elseif(instance == 5) then
					replaceable_r1 = "character/v3/PurpleDragonMinor/SkinColor02.dds";
				elseif(instance == 6) then
					replaceable_r1 = "character/v3/PurpleDragonMinor/SkinColor03.dds";
				end
				npcChar:SetReplaceableTexture(1, ParaAsset.LoadTexture("", replaceable_r1, 1));
			else
				if(instance == 7) then
					npcChar:ToCharacter():SetBodyParams(2, -1, -1, -1, -1);
				elseif(instance == 8) then
					npcChar:ToCharacter():SetBodyParams(4, -1, -1, -1, -1);
				end
			end
			
		end
	end
end
