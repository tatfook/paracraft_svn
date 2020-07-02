--[[
Title: FireworkLauncher
Author(s): WangTian
Date: 2009/8/20

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30357_FireworkLauncher.lua
------------------------------------------------------------
]]

-- create class
local libName = "FireworkLauncher";
local FireworkLauncher = commonlib.gettable("MyCompany.Aries.Quest.NPCs.FireworkLauncher");

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;


-- firework launcher setup
local instance_joybean_count_per_launcher = 20;
local launcher_count = 3;
-- joybean instances
local instances_joybean = {};
local instances_joybean_range = {1, instance_joybean_count_per_launcher * launcher_count};


local centers = {
				{ 20065.646484375, 0.49955752491951, 19816.935546875 },
				{ 20005.943359375, 0.22364510595798, 19927 },
				{ 20159.470703125, 3.5, 19704.54296875 },
				};
local joybean_positions = {};

local radius_joybean = 7;

local is_inited;
function FireworkLauncher.Init()
	if(not is_inited) then
		is_inited = true;
		for i = 1, launcher_count do
			local j = 1;
			for j = instance_joybean_count_per_launcher * (i - 1) + 1, instance_joybean_count_per_launcher * i do
				joybean_positions[j] = {};
				local a = (6.28 / instance_joybean_count_per_launcher * j);
				local radius = radius_joybean + math.random(0,300)/100;
				joybean_positions[j][1] = centers[i][1] + math.cos(a) * radius;
				joybean_positions[j][2] = centers[i][2];
				joybean_positions[j][3] = centers[i][3] + math.sin(a) * radius;
				joybean_positions[j][2] = ParaTerrain.GetElevation(joybean_positions[j][1], joybean_positions[j][3]);
			end
		end
	end
end

-- FireworkLauncher.main
function FireworkLauncher.main()
	FireworkLauncher.Init();

	local serverobject = Map3DSystem.GSL_client:GetServerObject("s30357");
	if(serverobject) then
		local instances_joybean = serverobject:GetValue("joybeans");
		if(instances_joybean) then
			local start = instances_joybean_range[1];
			local finish = instances_joybean_range[2];
			local index = start;
			local exist;
			for exist in string.gfind(instances_joybean, "([^,]+)") do
				if(exist == "1") then
					FireworkLauncher.CreateJoybean(index);
				elseif(exist == "0") then
					FireworkLauncher.DestroyJoybean(index);
				end
				index = index + 1;
				if(index > finish) then
					break;
				end
			end
		end
	end
	
	--Map3DSystem.GSL_client:SendRealtimeMessage("s30357", {body="[Aries][ServerObject30357]TryPickObj:31"});
end

function FireworkLauncher.main2()
	FireworkLauncher.Init();
	local i, target;
	for i, target in ipairs(targets) do
		local start_time = math.floor(math.random(100, 2000));
		UIAnimManager.PlayCustomAnimation(start_time, function(elapsedTime)
			if(elapsedTime == start_time) then
				FireworkLauncher.GenerateBubble(i);
				FireworkLauncher.CreateGiftBox(i, -100);
			end
		end);
	end
end

function FireworkLauncher.main3()
	FireworkLauncher.Init();
	local i;
	for i = instances_gift_range[1], instances_gift_range[2] do
		FireworkLauncher.DestroyGift(i);
	end
	local i;
	for i = instances_joybean_range[1], instances_joybean_range[2] do
		FireworkLauncher.DestroyJoybean(i);
	end
end

function FireworkLauncher.main4()
	FireworkLauncher.Init();
	local i;
	for i = instances_gift_range[1], instances_gift_range[2] do
		FireworkLauncher.CreateGift(i);
		FireworkLauncher.ThrowGift(i);
	end
	local i;
	for i = instances_joybean_range[1], instances_joybean_range[2] do
		FireworkLauncher.CreateJoybean(i);
		FireworkLauncher.ThrowJoybean(i);
	end
end

function FireworkLauncher.ToNPCid_Joybean(index)
	return 3035700 + 50 + index;
end

function FireworkLauncher.ToJoybeanid(index)
	return index - 3035700 - 50;
end

function FireworkLauncher.ThrowJoybean(index)
	FireworkLauncher.Init();
	if(not FireworkLauncher.IsJoybeanVisualized(index)) then
		return;
	end
	local position = joybean_positions[index];
	local launcher_index = math.ceil(index / instance_joybean_count_per_launcher);
	local x, y, z = position[1], position[2], position[3];
	local c_x, c_y, c_z = centers[launcher_index][1], centers[launcher_index][2], centers[launcher_index][3];
	
	local duration_time = math.mod(index, 7) * 0.2 + math.mod(index, 5) * 0.5;
	local height = (20 / 8) * duration_time * duration_time;
	duration_time = duration_time * 1000;
	
	UIAnimManager.PlayCustomAnimation(duration_time, function(elapsedTime)
		local npcid = FireworkLauncher.ToNPCid_Joybean(index);
		local joybean = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(npcid);
		if(joybean and joybean:IsValid() == true) then
			if(elapsedTime == duration_time) then
				joybean:SetPosition(x, y, z);
			else
				local t_x = c_x - (c_x - x) * (elapsedTime / duration_time);
				local t_z = c_z - (c_z - z) * (elapsedTime / duration_time);
				local t = math.abs(elapsedTime - duration_time / 2) / 1000;
				local t_y = y + height - 0.5 * 20 * t * t;
				joybean:SetPosition(t_x, t_y, t_z);
			end
		end
	end);
end

function FireworkLauncher.CreateJoybean(index)
	FireworkLauncher.Init();
	if(FireworkLauncher.IsJoybeanVisualized(index)) then
		return;
	end
	local position = joybean_positions[index];
	--if(offsety) then
		--position[2] = position[2] + offsety;
	--end
	
	local assetfile = "character/v5/08functional/JoyBean/JoyBean.x";
	--local assetfile = "character/v5/08functional/IceStone/IceStone.x";
	local params = {
		name = "",
		position = position,
		assetfile_char = assetfile,
		facing = math.random(0, 628)/100,
		scaling = 1,
		main_script = "",
		main_function = "",
		talkdist = 2,
		predialog_function = "MyCompany.Aries.Quest.NPCs.FireworkLauncher.Joybean_PreDialog",
		selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
		EnablePhysics = false,
		cursor = "Texture/Aries/Cursor/Pick.tga",
	};
	local npcid = FireworkLauncher.ToNPCid_Joybean(index);
	local NPC = MyCompany.Aries.Quest.NPC;
	local box, boxModel = NPC.CreateNPCCharacter(npcid, params);
end

-- destroy joybean box
function FireworkLauncher.DestroyJoybean(index)
	local npcid = FireworkLauncher.ToNPCid_Joybean(index);
	local NPC = MyCompany.Aries.Quest.NPC;
	NPC.DeleteNPCCharacter(npcid);
end

-- check if joybean visualized in scene
function FireworkLauncher.IsJoybeanVisualized(index)
	local npcid = FireworkLauncher.ToNPCid_Joybean(index);
	local joybean = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(npcid);
	if(joybean and joybean:IsValid() == true) then
		return true;
	end
	return false;
end

---- make the game
--function FireworkLauncher.FallDownGift(index, falldownfrom)
	--local npcid = FireworkLauncher.ToNPCid(index);
	--local NPC = MyCompany.Aries.Quest.NPC;
	--local box = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(npcid);
	--if(falldownfrom and box and box:IsValid() == true) then
		--local x, y, z = box:GetPosition();
		--box:SetPosition(x, falldownfrom, z);
		--box:ToCharacter():FallDown();
	--end
--end

-- FireworkLauncher timer
function FireworkLauncher.On_Timer()
end

function FireworkLauncher.PreDialog()
	return true;
end

function FireworkLauncher.TryLaunchFirework(instance)
	Map3DSystem.GSL_client:SendRealtimeMessage("s30357", {body="[Aries][ServerObject30357]TryLaunch:"..instance});
end

function FireworkLauncher.Joybean_PreDialog()
	local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
	if(targetNPC_id) then
		local instance_id = FireworkLauncher.ToJoybeanid(targetNPC_id);
		Map3DSystem.GSL_client:SendRealtimeMessage("s30357", {body="[Aries][ServerObject30357]TryPickJoybean:"..instance_id});
	end
	return false;
end

function FireworkLauncher.OnRecvJoybean(index)
	local pick_count = math.floor(math.random(3,9)) * 10;
    local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
    if(AddMoneyFunc) then
        AddMoneyFunc(pick_count, function(msg)
			log("============ FireworkLauncher.OnRecvJoybean returns: ============");
			commonlib.echo(pick_count);
			commonlib.echo(msg);
        end);
    end
end

function FireworkLauncher.OnNotReady()
	MyCompany.Aries.Desktop.TargetArea.ShowDialogStyleMessageBox(30357, 1, "我刚放完一次烟花，需要休息一下；你等会再来吧，每15分钟可以放一次烟花哦！")
end

function FireworkLauncher.LaunchFirework(instance)
	local prefix = "g_FireworkLauncher_";
	local effect_name = prefix..i;
	local duration_time = 20000;
	local x, y, z;

	local npcChar = NPC.GetNpcCharacterFromIDAndInstance(30357, instance);
	if(npcChar) then
		x, y, z = npcChar:GetPosition();
	end
	UIAnimManager.PlayCustomAnimation(duration_time, function(elapsedTime)
		
		if(elapsedTime == 0) then
			-- begin animation, create new effect object
			local npcModel = ParaScene.GetCharacter(effect_name);
			if(npcModel:IsValid() == true) then
				ParaScene.Delete(npcModel);
			end
			local asset = ParaAsset.LoadStaticMesh("", "model/07effect/v5/Fireworks/Fireworks.x");
			local obj = ParaScene.CreateMeshPhysicsObject(effect_name, asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
			obj:SetField("progress", 1);
			if(obj and obj:IsValid() == true) then
				obj:SetPosition(x, y, z);
				obj:SetScale(2);
				ParaScene.Attach(obj);
				ParaSelection.AddObject(obj, 2);
			end
		elseif(elapsedTime == duration_time) then
			local npcModel = ParaScene.GetCharacter(effect_name);
			if(npcModel:IsValid() == true) then
				ParaScene.Delete(npcModel);
			end
		end
	end);
	
end