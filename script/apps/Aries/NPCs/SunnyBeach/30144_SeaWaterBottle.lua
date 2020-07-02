--[[
Title: SeaWaterBottle
Author(s): WangTian
Date: 2009/7/22

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/SunnyBeach/30144_SeaWaterBottle.lua
------------------------------------------------------------
]]

-- create class
local libName = "SeaWaterBottle";
local SeaWaterBottle = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.SeaWaterBottle", SeaWaterBottle);

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

SeaWaterBottle.respawn_interval = 300000;

asset_model_dryup = "model/06props/v5/03quest/ChinaBottle/ChinaBottle_Dryrot.x";
asset_model_filled = "model/06props/v5/03quest/ChinaBottle/ChinaBottle_Water.x";

-- SeaWaterBottle.main()
function SeaWaterBottle.main()
	SeaWaterBottle.Show(false);
end

-- SeaWaterBottle.main()
function SeaWaterBottle.On_Timer()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30144);
	if(memory.nextvisibletime == nil) then
		memory.nextvisibletime = ParaGlobal.GetGameTime() + math.random(SeaWaterBottle.respawn_interval/2, SeaWaterBottle.respawn_interval);
		SeaWaterBottle.Show(false);
	end
	if(ParaGlobal.GetGameTime() > memory.nextvisibletime) then
		SeaWaterBottle.Show(true);
	end
end

-- SeaWaterBottle.Show(bShow)
-- @param bShow: show the bottle with sea water or not
function SeaWaterBottle.Show(bShow)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30144);
	local npcModel = Quest.NPC.GetNpcModelFromIDAndInstance(30144);
	if(npcModel) then
		if(bShow == true) then
			commonlib.ResetModelAsset(npcModel, asset_model_filled);
			memory.nextvisibletime = ParaGlobal.GetGameTime() + SeaWaterBottle.respawn_interval;
		else
			commonlib.ResetModelAsset(npcModel, asset_model_dryup);
		end
	end
end

-- SeaWaterBottle.DryUp()
function SeaWaterBottle.DryUp()
	System.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30144);
	memory.nextvisibletime = ParaGlobal.GetGameTime() + SeaWaterBottle.respawn_interval;
	-- hide the sea water
	SeaWaterBottle.Show(false);
end

-- SeaWaterBottle.RefreshStatus()
function SeaWaterBottle.RefreshStatus()
end

-- SeaWaterBottle.PreDialog()
function SeaWaterBottle.PreDialog()
	local npcModel = Quest.NPC.GetNpcModelFromIDAndInstance(30144);
	if(npcModel) then
		local asset_file = npcModel:GetPrimaryAsset():GetKeyName();
		if(asset_file == asset_model_filled) then
			-- 17088_CondensedSeaWater
			ItemManager.PurchaseItem(17088, 1, function(msg) end, function(msg) 
				log("+++++++Purchase item #17088_CondensedSeaWater return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					-- dry up the bottle
					SeaWaterBottle.DryUp();
				end
			end);
			return false;
		end
	end
	return false;
end

