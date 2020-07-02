--[[
Title: IceOnLake
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/SnowArea/30365_IceOnLake.lua
------------------------------------------------------------
]]

-- create class
local libName = "IceOnLake";
local IceOnLake = {
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.IceOnLake", IceOnLake);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- IceOnLake.main
function IceOnLake.main()
	local self = IceOnLake;
	-- if already saved swan delete the npc immediately
	-- 50285_TrachtenbergToWhiteSwan
	if(not self.IsFreeze()) then
		NPC.DeleteNPCCharacter(30365);
		return;
	end
	
	-- preload the ice textures
	NPL.load("(gl)script/ide/AssetPreloader.lua");
	local loader = commonlib.AssetPreloader:new({
		callbackFunc = function(nItemsLeft, loader)
		end
	});
	loader:AddAssets(ParaAsset.LoadTexture("", "model/06props/v5/03quest/IceRiver/IceRiver.dds", 1));
	loader:AddAssets(ParaAsset.LoadTexture("", "model/06props/v5/03quest/IceRiver/IceRiver_p1.dds", 1));
	loader:AddAssets(ParaAsset.LoadTexture("", "model/06props/v5/03quest/IceRiver/IceRiver_p2.dds", 1));
	loader:AddAssets(ParaAsset.LoadTexture("", "model/06props/v5/03quest/IceRiver/IceRiver_p3.dds", 1));
	loader:AddAssets(ParaAsset.LoadTexture("", "model/06props/v5/03quest/IceRiver/IceRiver_p4.dds", 1));
	
	-- first update when user enter world or return from homeland
	IceOnLake.bEquipChanged = true;
	
	-- hook into OnUnEquipItem
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnUnEquipItem") then
				IceOnLake.bEquipChanged = true;
			end
		end, 
		hookName = "IceOnLake_OnUnEquipItem", appName = "Aries", wndName = "main"});
	-- hook into OnEquipItem
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnEquipItem") then
				IceOnLake.bEquipChanged = true;
			end
		end, 
		hookName = "IceOnLake_OnEquipItem", appName = "Aries", wndName = "main"});
		
end

function IceOnLake.PreDialog(npc_id, instance)
	local self = IceOnLake; 
	self.DoChiselIce();
	return false;
end
function IceOnLake.CanChiselIce()
	local self = IceOnLake; 
	if(self.IsFreeze() and equipGSItem(1157))then
		return true;
	end
end
function IceOnLake.DoChiselIce()
	local self = IceOnLake; 
	
	local nid = Map3DSystem.User.nid;
	local key = nid.."NPCs.IceOnLake.DoChiselIce.Num";
	local num = MyCompany.Aries.Player.LoadLocalData(key, 0);
	
	local function ProceedIceCrack()
		num = num + 1;
		
		MyCompany.Aries.Player.SaveLocalData(key, num);
		
		local npcModel = NPC.GetNpcModelFromIDAndInstance(30365);
		if(npcModel) then
			local tex_name;
			if(num == 0) then
				tex_name = "model/06props/v5/03quest/IceRiver/IceRiver.dds";
			elseif(num == 1) then
				tex_name = "model/06props/v5/03quest/IceRiver/IceRiver_p1.dds";
			elseif(num == 2) then
				tex_name = "model/06props/v5/03quest/IceRiver/IceRiver_p2.dds";
			elseif(num == 3) then
				tex_name = "model/06props/v5/03quest/IceRiver/IceRiver_p3.dds";
			elseif(num == 4) then
				tex_name = "model/06props/v5/03quest/IceRiver/IceRiver_p4.dds";
			end
			if(tex_name) then
				npcModel:SetReplaceableTexture(1, ParaAsset.LoadTexture("", tex_name, 1));
			end	
		end
	end
	
	
	--TODO:冰面的变化
	if((num + 1) >= 5)then
		-- last ice crack
		--丑小鸭变成白天鹅
		
		-- 50285_TrachtenbergToWhiteSwan
		ItemManager.PurchaseItem(50285, 1, function(msg) end, function(msg) 
			log("+++++++Purchase item #50285_TrachtenbergToWhiteSwan return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				-- last ice crack
				NPC.DeleteNPCCharacter(30365);
				-- proceed with ice crack
				ProceedIceCrack();
				
				-- change to swan and effect 
				local npcChar = NPC.GetNpcCharacterFromIDAndInstance(30362);
				if(npcChar and npcChar:IsValid() == true) then
					local params = {
						asset_file = "character/v5/temp/Effect/LoyaltyDown_Impact_Base.x",
						binding_obj_name = npcChar.name,
						start_position = nil,
						duration_time = 8000,
						force_name = nil,
						begin_callback = function() end,
						end_callback = nil,
						stage1_time = 6000,
						stage1_callback = function()
								MyCompany.Aries.Quest.NPCs.UglyDuckling.ChangeToSwan();
							end,
						stage2_time = nil,
						stage2_callback = nil,
					};
					local EffectManager = MyCompany.Aries.EffectManager;
					EffectManager.CreateEffect(params);
				end
			end
		end, nil, "none", true);
		
	else
		-- normal ice crack
		ProceedIceCrack()
	end
end

function IceOnLake.IsFreeze()
	-- NOTE 2010/3/10: the ice is never freezed
	if(true) then
		return false;
	end
	
	-- 50285_TrachtenbergToWhiteSwan
	if(hasGSItem(50285)) then
		return false;
	else
		return true;
	end 
	--local self = IceOnLake; 
	--local nid = Map3DSystem.User.nid;
	--local key = nid.."NPCs.IceOnLake.DoChiselIce.Num";
	--local num = MyCompany.Aries.Player.LoadLocalData(key, 0);
	--commonlib.echo("====key");
	--commonlib.echo(key);
	--commonlib.echo(num);
	--if(num >= 0 and num < 5)then
		--return true;
	--end
end
function IceOnLake.On_Timer()
	-- only update when equip or unequip item
	if(IceOnLake.bEquipChanged) then
		IceOnLake.bEquipChanged = nil;
		local self = IceOnLake; 
		local chisel = NPC.GetNpcCharacterFromIDAndInstance(30365);
		if(chisel)then
			if(equipGSItem(1157))then
				chisel:SetScale(10);
			else
				chisel:SetScale(0.0001);
			end
		end
	end
end