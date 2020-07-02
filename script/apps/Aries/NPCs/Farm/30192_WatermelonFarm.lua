--[[
Title: WatermelonFarm
Author(s): 
Date: 2009/12/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Farm/30192_WatermelonFarm.lua");
------------------------------------------------------------
]]

-- create class
local libName = "WatermelonFarm";
local WatermelonFarm = {};
local positions = {
}
local k;
local x,y,z = 20057, 0.4, 19731 ;
for k = 1, 20 do
	x = x + 1
	positions[k] = { x, y, z};
end

positions = {
	{ 19722.85546875, 0.43803983926773, 19809.455078125 },
	{ 19766.2890625, 1.4520454406738, 19816.240234375 },
	{ 19780.810546875, 0.38895624876022, 19838.36328125 },
	{ 19752.234375, 0.36634373664856, 19826.529296875 },
	{ 19728.220703125, 0.24563537538052, 19830.06640625 },
	
	{ 19713.662109375, 0.31251141428947, 19837.529296875 },
	{ 19735.947265625, 0.049128990620375, 19845.677734375 },
	{ 19758.67578125, -0.047700639814138, 19850.498046875 },
	{ 19752.935546875, 0.051920607686043, 19886.3125 },
	{ 19725.03125, -0.07718013972044, 19874.314453125 },
	
	{ 19714.943359375, -0.42223760485649, 19860.7890625 },
	{ 19723.9140625, -0.20485702157021, 19851.296875 },
	{ 19745.8359375, -0.19548618793488, 19839.509765625 },
	{ 19751.228515625, -0.038341734558344, 19857.255859375 },
	{ 19741.65234375, 0.38582104444504, 19814.2890625 },
	
	{ 19782.794921875, 0.071809396147728, 19857.345703125 },
	{ 19767.34765625, 0.091707810759544, 19842.337890625 },
	{ 19736.142578125, -0.40966957807541, 19860.51953125 },
	{ 19797.810546875, 2.391553401947, 19833.83203125 },
	{ 19763.806640625, 0.50620484352112, 19828.94921875 },
};

local watermelon_npcid = 301921;

commonlib.setfield("MyCompany.Aries.Quest.NPCs.WatermelonFarm", WatermelonFarm);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function WatermelonFarm.main()
	
end

function WatermelonFarm.On_Timer()
end

function WatermelonFarm.PreDialog(npc_id, instance)
	WatermelonFarm.PickedWatermelon(instance)
	return false;
end
function WatermelonFarm.CreateWatermelon(index)
	-- invoked multiple times
	if(not index)then return end
	
	local npcChar = NPC.GetNpcCharacterFromIDAndInstance(watermelon_npcid, index);
	if(npcChar and npcChar:IsValid() == true) then
		return;
	end
	
	local pos = positions[index];
	local params = { 
		name = "西瓜",
		instance = index,
		position = pos,
		facing = 0.89258199930191,
		scaling = 2,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",
		assetfile_model = "model/06props/v5/05other/Watermelon/Watermelon.x",
		--assetfile_model = "model/06props/v5/03quest/Arena/Arena_Purple.x",
		cursor = "Texture/Aries/Cursor/Pick.tga",
		main_script = "script/apps/Aries/NPCs/Farm/30192_WatermelonFarm.lua",
		main_function = "MyCompany.Aries.Quest.NPCs.WatermelonFarm.main_watermelon();",
		predialog_function = "MyCompany.Aries.Quest.NPCs.WatermelonFarm.PreDialog_watermelon",
		--dialog_page = "script/apps/Aries/NPCs/Farm/30192_WatermelonFarm_dialog.html",
		isdummy = true,
		autofacing = true,
	};-- 西瓜田
	NPC.CreateNPCCharacter(watermelon_npcid, params);
end

function WatermelonFarm.main_watermelon()
end

function WatermelonFarm.PreDialog_watermelon(npc_id, instance)
	WatermelonFarm.PickedWatermelon(instance);
	return false;
end

function WatermelonFarm.DeleteWatermelon(index)
	if(not index)then return end
	NPC.DeleteNPCCharacter(watermelon_npcid, index);
end
function WatermelonFarm.PickedWatermelon(index)
	if(not index)then return end
	local body = string.format("[Aries][ServerObject30192]TryPickObj:%d", index);
	Map3DSystem.GSL_client:SendRealtimeMessage("s30192", { body = body });
end
function WatermelonFarm.OnRecvWatermelon()
	
	-- 17033_Watermelon
	ItemManager.PurchaseItem(17033, 1, function(msg) end, function(msg)
		if(msg) then
			log("+++++++Purchase 17033_Watermelon return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">哇，你的运气真好，捡到了一个西瓜！ </div>]])
			end
		end
	end);
end