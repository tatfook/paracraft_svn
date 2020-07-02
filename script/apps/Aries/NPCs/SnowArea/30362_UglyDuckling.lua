--[[
Title: UglyDuckling
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/SnowArea/30362_UglyDuckling.lua
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/30365_IceOnLake.lua");
-- create class
local libName = "UglyDuckling";
local UglyDuckling = {
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.UglyDuckling", UglyDuckling);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- UglyDuckling.main
function UglyDuckling.main()
	local self = UglyDuckling; 
	--if(self.IsFinished() or not self.IsFreeze()) then
		--self.ChangeToSwan();
	--end
	self.ChangeToSwan();
end

function UglyDuckling.On_Timer()
	-- NOTE 2010/3/10: the duck is never freezed
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30362);
	memory.isFreeWaterSurfaceMove = true;
	do return end
	
	-- check if the ducking is saved from the ice block
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30362);
	if(memory and memory.isFreeWaterSurfaceMove == true) then
		return;
	end
	-- 50285_TrachtenbergToWhiteSwan
	if(hasGSItem(50285)) then
		memory.isFreeWaterSurfaceMove = true;
	end
end

function UglyDuckling.PreDialog(npc_id, instance)
	local self = UglyDuckling; 
end
function UglyDuckling.IsAccepted()
	local self = UglyDuckling; 
	local nid = Map3DSystem.User.nid;
	local key = nid.."NPCs.UglyDuckling.IsAccepted";
	return MyCompany.Aries.Player.LoadLocalData(key, false);
end
function UglyDuckling.IsFreeze()
	local self = UglyDuckling; 
	return MyCompany.Aries.Quest.NPCs.IceOnLake.IsFreeze();
end
function UglyDuckling.HasWaterSpring()
	local self = UglyDuckling; 
	return hasGSItem(17086);
end
function UglyDuckling.IsFinished()
	-- NOTE 2010/3/10: the duck is never freezed
	return true;
	---- 50293_SaveWhiteSwan_Finished
	--return hasGSItem(50293);
end
function UglyDuckling.DoAccept()
	local self = UglyDuckling;
	if(not self.IsAccepted())then
		local nid = Map3DSystem.User.nid;
		local key = nid.."NPCs.UglyDuckling.IsAccepted";
		MyCompany.Aries.Player.SaveLocalData(key, true);
	end 
end
function UglyDuckling.GiveSpringWater()
	local self = UglyDuckling; 
	commonlib.echo("=========before extend in UglyDuckling");
	ItemManager.ExtendedCost(350, nil, nil, function(msg)end, function(msg) 
	commonlib.echo("=========after extend in UglyDuckling");
		commonlib.echo(msg);
		if(msg and msg.issuccess)then
		end
	end);
end

function UglyDuckling.ChangeToSwan()
	local npcChar = NPC.GetNpcCharacterFromIDAndInstance(30362);
	if(npcChar and npcChar:IsValid() == true) then
		local asset = ParaAsset.LoadParaX("", "character/v5/02animals/Swan/Swan.x");
		local npcCharChar = npcChar:ToCharacter();
		npcCharChar:ResetBaseModel(asset);
		
		NPC.ChangeHeadonText(30362, nil, "白天鹅");
	end
end

function UglyDuckling.CanShow()
	 local hasHouse = MyCompany.Aries.Quest.NPCs.DongDong.HasNaturalHouse();
    local num = MyCompany.Aries.Quest.NPCs.DongDong.GetNaturalCrystal();
    if(not hasHouse)then
        if(num == 1 or num == 2)then
            return true;
        end
    end
end