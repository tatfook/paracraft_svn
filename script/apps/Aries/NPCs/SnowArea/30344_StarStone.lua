--[[
Title: StarStone
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/SnowArea/30344_StarStone.lua
------------------------------------------------------------
]]

-- create class
local libName = "StarStone";
local StarStone = {
	state = 0,--0 可以捡取 1 不可以
	selected_id = nil,-- 5 可以被捡取
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.StarStone", StarStone);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- StarStone.main
function StarStone.main()
	local self = StarStone; 
	if(self.HasStarStone())then
		NPC.DeleteNPCCharacter(30344,5);
	end
	
	-- first update when user enter world or return from homeland
	StarStone.bEquipChanged = true;
	
	-- hook into OnUnEquipItem
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnUnEquipItem") then
				StarStone.bEquipChanged = true;
			end
		end, 
		hookName = "StarStone_OnUnEquipItem", appName = "Aries", wndName = "main"});
	-- hook into OnEquipItem
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnEquipItem") then
				StarStone.bEquipChanged = true;
			end
		end, 
		hookName = "StarStone_OnEquipItem", appName = "Aries", wndName = "main"});
end

function StarStone.PreDialog(npc_id, instance)
	local self = StarStone; 
	self.state = 1;
	self.selected_id = nil;
	commonlib.echo(instance);
	commonlib.echo(self.HasStarStone());
	commonlib.echo(self.DetectorInRightHand());
	if(self.HasStarStone() or not self.DetectorInRightHand())then
		return true
	end
	if(instance == 5)then
		self.selected_id = instance;
		self.state = 0;--可以捡
	end
	return true;
end
--自己是否拥有 星形石块
function StarStone.HasStarStone()
	-- 17051_StarStone
	-- 50259_SaveGucci_FoundStarStone
	-- 50260_SaveGucci_Complete
	return hasGSItem(17051) or hasGSItem(50259) or hasGSItem(50260);
end
function StarStone.PickStarStone()
	local self = StarStone; 
	if(self.HasStarStone())then return end
	if(self.selected_id)then
		ItemManager.PurchaseItem(17051, 1, function(msg) end, function(msg) 
			commonlib.echo("+++++++Purchase 17051_StarStone return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				NPC.DeleteNPCCharacter(30344,self.selected_id);
			end
		end);		
	end
end
--探测仪是否在右手上
function StarStone.DetectorInRightHand()
	local self = StarStone;
	-- 1147_Detector
	return equipGSItem(1147);
end

function StarStone.On_Timer()
	-- only update when equip or unequip item
	if(StarStone.bEquipChanged) then
		StarStone.bEquipChanged = nil;
		local self = StarStone; 
		local k;
		for k = 1,14 do
			local stone = NPC.GetNpcCharacterFromIDAndInstance(30344, k);
			if(stone)then
				if(self.DetectorInRightHand())then
					stone:SetScale(1);
				else
					stone:SetScale(0.0001);
				end
			end
		end
	end
end