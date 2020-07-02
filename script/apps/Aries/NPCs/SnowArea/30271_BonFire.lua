--[[
Title: BonFire
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/SnowArea/30271_BonFire.lua
------------------------------------------------------------
]]

-- create class
local libName = "BonFire";
local BonFire = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.BonFire", BonFire);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- 50257_BonfireMeltSnowBetweenArea2_3

local bonfirepositions = {
	{ 19983.70703125, 37.755535125732, 20375.92578125 },
	{ 19987.255859375, 36.526397705078, 20381.849609375 },
	{ 19992.271484375, 37.315929412842, 20387.8203125 },
};

local bonfirerotations = {
	{	w=0.93331032991409,
		x=-0.056455031037331,
		y=0.021410368382931,
		z=-0.35395801067352 },
	{	w=0.96386253833771,
		x=-0.11703395098448,
		y=0.028846206143498,
		z=-0.2375709861517 },
	{	w=0.96386253833771,
		x=-0.2375709861517,
		y=0.028846211731434,
		z=-0.1170339435339 },
};

local icerocks = {
	["group1"] = {
		{
		AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_06.x",
		  rotation={
			w=0.78450673818588,
			x=-0.057746328413486,
			y=-0.60537624359131,
			z=-0.12138395756483 
		  },
		  scaling=2.8531174659729,
		  x=19988.865234375,
		  y=43.807167053223,
		  z=20392.228515625 },
		{
  AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_04.x",
  rotation={ w=1, x=0, y=0, z=0 },
  scaling=3.1384289264679,
  x=19979.88671875,
  y=40.515434265137,
  z=20381.22265625 },
		{
  AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_02.x",
  rotation={ w=0.9004470705986, x=0, y=0.43496552109718, z=0 },
  scaling=1,
  x=19978.408203125,
  y=41.384418487549,
  z=20379.697265625 },
		{
  AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_05.x",
  rotation={
    w=0.90784627199173,
    x=-0.22376418113708,
    y=-0.34430074691772,
    z=-0.08486258238554 
  },
  scaling=1.6105105876923,
  x=19986.453125,
  y=43.525131225586,
  z=20389.6640625 },
		{
  AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_03.x",
  rotation={ w=0.93937277793884, x=0, y=0.34289741516113, z=0 },
  scaling=1.6105101108551,
  x=19988.35546875,
  y=40.747356414795,
  z=20391.078125 },
		--{},
		--{},
		--{},
	},
	["group2"] = {
		{
  AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_01.x",
  rotation={ w=0.87758255004883, x=0, y=-0.47942554950714, z=0 },
  scaling=1.7715619802475,
  x=19983.921875,
  y=39.432399749756,
  z=20385.947265625 },
		{
  AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_03.x",
  rotation={ w=0.93937283754349, x=0, y=0.34289729595184, z=0 },
  scaling=1.0000001192093,
  x=19990.84765625,
  y=40.20325088501,
  z=20391.458984375 },
		{
  AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_06.x",
  rotation={
    w=0.78450661897659,
    x=-0.057746306061745,
    y=-0.6053763628006,
    z=-0.12138397246599 
  },
  scaling=2.8531174659729,
  x=19981,
  y=39.224086761475,
  z=20383.275390625 },
		{
  AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_04.x",
  rotation={ w=0.99999994039536, x=0, y=0, z=0 },
  scaling=2.8531169891357,
  x=19985.974609375,
  y=39.374317169189,
  z=20391.728515625 },
		--{},
		--{},
		--{},
	},
	["group3"] = {
		{
  AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_02.x",
  rotation={ w=0.95533657073975, x=0, y=-0.29551991820335, z=0 },
  scaling=1,
  x=19980.333984375,
  y=38.399730682373,
  z=20380.912109375 },
		{
  AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_06.x",
  rotation={ w=0.99999994039536, x=0, y=0, z=0 },
  scaling=2.3579480648041,
  x=19978.49609375,
  y=39.249729156494,
  z=20382.462890625 },
		{
  AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_06.x",
  rotation={ w=0.99999994039536, x=0, y=0, z=0 },
  scaling=2.3579480648041,
  x=19982.06640625,
  y=39.464946746826,
  z=20386.38671875 },
		{
  AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_06.x",
  rotation={
    w=0.9691703915596,
    x=-0.23887895047665,
    y=0.014449534006417,
    z=-0.058624003082514 
  },
  scaling=3.1384286880493,
  x=19983.759765625,
  y=38.502788543701,
  z=20388.01953125 },
		{
  AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_06.x",
  rotation={
    w=0.78450667858124,
    x=-0.05774637684226,
    y=-0.60537642240524,
    z=-0.12138400971889 
  },
  scaling=3.4522724151611,
  x=19980.537109375,
  y=37.520999908447,
  z=20384.130859375 },
		{
  AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_05.x",
  rotation={
    w=0.96036231517792,
    x=0.13116458058357,
    y=-0.086990356445313,
    z=-0.23007102310658 
  },
  scaling=0.99999988079071,
  x=19981.443359375,
  y=37.87525177002,
  z=20380.38671875 },
		{
  AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_03.x",
  rotation={ w=0.93937283754349, x=0, y=0.34289729595184, z=0 },
  scaling=1.0000001192093,
  x=19987.296875,
  y=37.828819274902,
  z=20389.279296875 },
		{
  AssetFile="model/06props/v5/01stone/IceStone/IceStoneFM_06.x",
  rotation={
    w=0.95653736591339,
    x=-0.19738127291203,
    y=-0.1973811686039,
    z=0.084365256130695 
  },
  scaling=2.2879137992859,
  x=19989.009765625,
  y=39.380855560303,
  z=20391.77734375 },
		--{},
		--{},
		--{},
	},
};


-- BonFire.main
function BonFire.main()
	local bHas, guid = hasGSItem(50257);
	if(bHas == true) then
		NPC.DeleteNPCCharacter(30271);
		-- create the bonfire if not created before
		BonFire.RefreshBonFires(1);
		BonFire.RefreshBonFires(2);
		BonFire.RefreshBonFires(3);
	else
		-- hook into OnThrowableHit
		CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = function(nCode, appName, msg, value)
				if(msg.aries_type == "OnThrowableHit") then
					if(msg.msg.nid == System.App.profiles.ProfileManager.GetNID()) then
						local msg = msg.msg;
						-- on hit bonfire with fire cracker
						if(msg.throwItem.gsid == 9503) then
							local i;
							for i = 1, 3 do
								local bonfire = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(302711, i);
								if(bonfire and bonfire:IsValid() == true) then
									local _, name;
									for _, name in pairs(msg.hitObjNameList or {}) do
										if(name == bonfire.name) then
											-- hit on self
											BonFire.On_Hit_Bonfire(i);
										end
									end
								end
							end
						end
					end
				end
			end, 
		hookName = "OnThrowableHit_30271_BonFire", appName = "Aries", wndName = "throw"});
		
		-- create the bonfire if not created before
		BonFire.RefreshBonFires(1);
		BonFire.RefreshBonFires(2);
		BonFire.RefreshBonFires(3);
		-- create ice rocks according to memory state
		BonFire.CreateIceRocks();
	end
end

function BonFire.CreateIceRocks()
	local groupcount = 0;
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30271);
	local i = 1;
	for i = 1, 3 do
		if(memory[i] ~= "on") then
			groupcount = groupcount + 1;
		end
	end
	if(groupcount >= 1) then
		local i;
		for i = 1, #icerocks.group3 do
			local params = {
				instance = i,
				position = {icerocks.group3[i].x, icerocks.group3[i].y, icerocks.group3[i].z},
				assetfile_char = "character/common/dummy/cube_size/cube_size.x",
				assetfile_model = icerocks.group3[i].AssetFile,
				facing = 0,
				scaling = 0.5,
				scaling_char = 0.00001,
				scaling_model = icerocks.group3[i].scaling,
				rotation = icerocks.group3[i].rotation,
			};
			local NPC = MyCompany.Aries.Quest.NPC;
			NPC.CreateNPCCharacter(302717, params);
		end
	end
	if(groupcount >= 2) then
		local i;
		for i = 1, #icerocks.group2 do
			local params = {
				instance = i,
				position = {icerocks.group2[i].x, icerocks.group2[i].y, icerocks.group2[i].z},
				assetfile_char = "character/common/dummy/cube_size/cube_size.x",
				assetfile_model = icerocks.group2[i].AssetFile,
				facing = 0,
				scaling = 0.5,
				scaling_char = 0.00001,
				scaling_model = icerocks.group2[i].scaling,
				rotation = icerocks.group2[i].rotation,
			};
			local NPC = MyCompany.Aries.Quest.NPC;
			NPC.CreateNPCCharacter(302718, params);
		end
	end
	if(groupcount >= 3) then
		local i;
		for i = 1, #icerocks.group1 do
			local params = {
				instance = i,
				position = {icerocks.group1[i].x, icerocks.group1[i].y, icerocks.group1[i].z},
				assetfile_char = "character/common/dummy/cube_size/cube_size.x",
				assetfile_model = icerocks.group1[i].AssetFile,
				facing = 0,
				scaling = 0.5,
				scaling_char = 0.00001,
				scaling_model = icerocks.group1[i].scaling,
				rotation = icerocks.group1[i].rotation,
			};
			local NPC = MyCompany.Aries.Quest.NPC;
			NPC.CreateNPCCharacter(302719, params);
		end
	end
end

function BonFire.MeltIceRock(group_id)
	local group = icerocks["group"..group_id];
	local i = 1;
	for i = 1, #group do
		UIAnimManager.PlayCustomAnimation(1500, function(elapsedTime)
			local rock_model = MyCompany.Aries.Quest.NPC.GetNpcModelFromIDAndInstance(302720 - group_id, i);
			if(rock_model) then
				rock_model:SetScale(group[i].scaling * (1500 - elapsedTime) / 1500);
			end
		end);
		UIAnimManager.PlayCustomAnimation(2000, function(elapsedTime)
			if(elapsedTime == 2000) then
				NPC.DeleteNPCCharacter(302720 - group_id, i);
			end
		end);
	end
end

function BonFire.RefreshBonFires(instance)
	-- create bonfire npc objects according to different memory states
	local bonfire = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(302711, instance);
	if(bonfire) then
		NPC.DeleteNPCCharacter(302711, instance);
	end
	
	local assetfile_model;
	-- set the asset file model accoding to different fire pile state
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30271);
	if(memory[instance] == "on" or hasGSItem(50257)) then
		assetfile_model = "model/06props/v5/03quest/FirePile/FirePile.x";
	else
		assetfile_model = "model/06props/v5/03quest/FirePile/FirePile_off.x";
	end
	local params = {
		name = "",
		instance = instance,
		position = bonfirepositions[instance],
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",
		assetfile_model = assetfile_model,
		facing = 0,
		scaling = 0.5,
		scaling_char = 2,
		rotation = bonfirerotations[instance],
		main_script = "script/apps/Aries/NPCs/SnowArea/30271_BonFire.lua",
		main_function = "MyCompany.Aries.Quest.NPCs.BonFire.main_RealFire();",
		predialog_function = "MyCompany.Aries.Quest.NPCs.BonFire.PreDialog_RealFire",
		cursor = "Texture/kidui/main/cursor.tga",
	};
	local NPC = MyCompany.Aries.Quest.NPC;
	NPC.CreateNPCCharacter(302711, params);
end

function BonFire.main_RealFire()
	
end

function BonFire.PreDialog_RealFire()
	return false;
end

function BonFire.On_Hit_Bonfire(instance)
	if(not hasGSItem(50257)) then
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30271);
		memory[instance] = "on";
		BonFire.RefreshBonFires(instance);
		
		if(memory[1] == "on" and memory[2] == "on" and memory[3] == "on") then
			ItemManager.PurchaseItem(50257, 1, function(msg)
				if(msg) then
					log("+++++++ purchase 50257_BonfireMeltSnowBetweenArea2_3 return: +++++++\n")
					commonlib.echo(msg);
					NPC.DeleteNPCCharacter(30271);
				end
			end);
		end
		
		-- melt the ice rock group according to npc memory
		local meltcount = 0;
		local i = 1;
		for i = 1, 3 do
			if(memory[i] == "on") then
				meltcount = meltcount + 1;
			end
		end
		if(meltcount == 1) then
			BonFire.MeltIceRock(1);
		elseif(meltcount == 2) then
			BonFire.MeltIceRock(2);
		elseif(meltcount == 3) then
			BonFire.MeltIceRock(3);
		end
	end
end