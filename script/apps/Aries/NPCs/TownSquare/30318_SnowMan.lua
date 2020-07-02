--[[
Title: SnowMan
Author(s): WangTian
Date: 2009/8/20

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30318_SnowMan.lua
------------------------------------------------------------
]]

-- create class
local libName = "SnowMan";
local SnowMan = commonlib.gettable("MyCompany.Aries.Quest.NPCs.SnowMan");

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

--17016_CheerCard_Ha
--17017_CheerCard_Qi
--17018_CheerCard_Xiao
--17019_CheerCard_Zhen
--17020_CheerCard_Huan
--17021_CheerCard_Ying
--17022_CheerCard_Ni

--30043_CheerBalloon_Ha
--30044_CheerBalloon_Qi
--30045_CheerBalloon_Xiao
--30046_CheerBalloon_Zhen
--30047_CheerBalloon_Huan
--30048_CheerBalloon_Ying
--30049_CheerBalloon_Ni

--17023_CheerCard_Sheng
--17024_CheerCard_Dan
--17025_CheerCard_Bing
--17026_CheerCard_Xue
--17027_CheerCard_Le
--17028_CheerCard_Jie

local nozzles = {{20022.80859375, 6.7192091941833, 19785.158203125},
				{20017.14453125, 6.6272482872009, 19789.939453125},
				{20012.30859375, 6.5930647850037, 19785.181640625},
				{20091.599609375, 6.7430772781372, 19772.07421875},
				{20096.560546875, 6.8220038414001, 19777.328125},
				{20085.740234375, 6.8868045806885, 19777.234375},
				};
				
				
local targets = {{1, 20030.193359375, 1.5, 19789.93359375}, -- nozzle id, x, y, z
				{1, 20026.400390625, 1.5, 19787.697265625},
				{1, 20026.29296875, 1.5, 19783.9921875},
				{1, 20029.515625, 1.5, 19785.37890625},
				{1, 20031.12890625, 1.5, 19781.2890625},
				{1, 20028.8515625, 1.5, 19782.466796875},
				{1, 20032.26953125, 1.5, 19784.419921875},
				{1, 20031.78515625, 1.5, 19787.271484375},
				{1, 20028.69140625, 1.5, 19787.765625},
				{1, 20028.96484375, 1.5, 19779.501953125},
				
				{2, 20010.00390625, 1.5, 19786.791015625},
				{2, 20010.1796875, 1.5, 19784.345703125},
				{2, 20008.0234375, 1.4263619184494, 19786.025390625},
				{2, 20005.91796875, 0.92410355806351, 19786.046875},
				{2, 20008.21875, 1.4730643033981, 19788.080078125},
				{2, 20008.296875, 1.4915902614594, 19783.91796875},
				{2, 20006.26953125, 1.0079686641693, 19783.701171875},
				{2, 20006.015625, 0.94763708114624, 19787.744140625},
				{2, 20004.015625, 0.50604659318924, 19784.84765625},
				{2, 20004.02734375, 0.50604659318924, 19787.01171875},
				
				{3, 20016.177734375, 1.5, 19791.77734375},
				{3, 20018.63671875, 1.5, 19791.857421875},
				{3, 20017.681640625, 1.5, 19794.22265625},
				{3, 20019.537109375, 1.5, 19794.0234375},
				{3, 20015.916015625, 1.5, 19794.15234375},
				{3, 20019.177734375, 1.3809312582016, 19796.46484375},
				{3, 20017.158203125, 1.4514912366867, 19796.08984375},
				{3, 20018.287109375, 1.1170660257339, 19797.8671875},
				{3, 20015.625, 1.3331297636032, 19796.630859375},
				{3, 20020.87109375, 1.4939497709274, 19795.859375},
				
				{4, 20091.4296875, 0.86213958263397, 19768.185546875},
				{4, 20093, 0.78170740604401, 19767.84765625},
				{4, 20089.77734375, 0.51861566305161, 19766.724609375},
				{4, 20091.4453125, 0.50052887201309, 19765.400390625},
				{4, 20095.822265625, 0.54530984163284, 19766.849609375},
				{4, 20089.52734375, 0.50418573617935, 19764.015625},
				{4, 20090.80859375, 0.50074326992035, 19762.46484375},
				{4, 20092.822265625, 0.50000005960464, 19761.337890625},
				{4, 20088.29296875, 0.50692528486252, 19765.1015625},
				{4, 20088.671875, 0.50259697437286, 19762.20703125},
				
				{5, 20100.26171875, 1.4999166727066, 19776.845703125},
				{5, 20099.83984375, 1.4998204708099, 19779.13671875},
				{5, 20102.23828125, 1.4999130964279, 19778.39453125},
				{5, 20101.796875, 1.4999551773071, 19780.578125},
				{5, 20103.431640625, 1.4999669790268, 19776.0625},
				{5, 20104.474609375, 1.5, 19779.59765625},
				{5, 20105.2890625, 1.5, 19777.439453125},
				{5, 20104.25390625, 1.5, 19781.521484375},
				{5, 20106.767578125, 1.5, 19779.5},
				{5, 20105.931640625, 1.5, 19775.541015625},
				
				{6, 20082.97265625, 1.4999700784683, 19778.646484375},
				{6, 20082.984375, 1.4999883174896, 19776.224609375},
				{6, 20081.10546875, 1.499987244606, 19777.357421875},
				{6, 20080.404296875, 1.499981880188, 19780.61328125},
				{6, 20081.69921875, 1.4999935626984, 19774.626953125},
				{6, 20079.734375, 1.4999893903732, 19775.220703125},
				{6, 20078.541015625, 1.4999887943268, 19776.412109375},
				{6, 20078.353515625, 1.4999848604202, 19779.037109375},
				{6, 20078.90625, 1.4999933242798, 19773.53125},
				{6, 20079.810546875, 1.4999788999557, 19779.203125},
				
				};
				


local center = {19799.587890625, 24.733015060425, 20184.42578125};
local gift_positions = {};
local joybean_positions = {};

local radius_gift = 7;
local radius_joybean = 10;

local i = 1;
for i = 1, 45 do
	gift_positions[i] = {};
	local a = (6.28 / 45 * i);
	local radius = radius_gift + math.random(0,300)/100;
	gift_positions[i][1] = center[1] + math.cos(a) * radius;
	gift_positions[i][2] = center[2];
	gift_positions[i][3] = center[3] + math.sin(a) * radius;
	gift_positions[i][2] = ParaTerrain.GetElevation(gift_positions[i][1], gift_positions[i][3]);
end

local i = 1;
for i = 1, 45 do
	joybean_positions[i] = {};
	local a = (6.28 / 45 * i);
	local radius = radius_joybean + math.random(0,300)/100;
	joybean_positions[i][1] = center[1] + math.cos(a) * radius;
	joybean_positions[i][2] = center[2];
	joybean_positions[i][3] = center[3] + math.sin(a) * radius;
	joybean_positions[i][2] = ParaTerrain.GetElevation(joybean_positions[i][1], joybean_positions[i][3]);
end

-- gift instances
local instances_gift = {};
local instances_gift_range = {1, 45};
local instances_gift_update_count = 30;

-- joybean instances
local instances_joybean = {};
local instances_joybean_range = {1, 45};
local instances_joybean_update_count = 30;

-- SnowMan.main
function SnowMan.main()
	local serverobject = Map3DSystem.GSL_client:GetServerObject("s30318");
	if(serverobject) then
		local instances_gifts = serverobject:GetValue("gifts");
		if(instances_gifts) then
			local start = instances_gift_range[1];
			local finish = instances_gift_range[2];
			local index = start;
			local exist;
			for exist in string.gfind(instances_gifts, "([^,]+)") do
				if(exist == "1") then
					SnowMan.CreateGift(index);
				elseif(exist == "0") then
					SnowMan.DestroyGift(index);
				end
				index = index + 1;
				if(index > finish) then
					break;
				end
			end
		end
		local instances_joybean = serverobject:GetValue("joybeans");
		if(instances_joybean) then
			local start = instances_joybean_range[1];
			local finish = instances_joybean_range[2];
			local index = start;
			local exist;
			for exist in string.gfind(instances_joybean, "([^,]+)") do
				if(exist == "1") then
					SnowMan.CreateJoybean(index);
				elseif(exist == "0") then
					SnowMan.DestroyJoybean(index);
				end
				index = index + 1;
				if(index > finish) then
					break;
				end
			end
		end
		local stage_hitcount = serverobject:GetValue("stage_hitcount");
		if(stage_hitcount) then
			local stage, hitcount = string.match(stage_hitcount, "(%d+)%+(%d+)");
			if(stage and hitcount) then
				stage = tonumber(stage);
				hitcount = tonumber(hitcount);
				-- TODO: set the stage scale and hitcount
				SnowMan.SetStage(stage);
				SnowMan.SetHitcount(hitcount);
			end
		end
		local stage_hitcount = serverobject:GetValue("stage_hitcount_CampfireChallenge");
		if(stage_hitcount) then
			local stage, hitcount = string.match(stage_hitcount, "(%d+)%+(%d+)");
			if(stage and hitcount) then
				stage = tonumber(stage);
				hitcount = tonumber(hitcount);
				-- TODO: set the stage scale and hitcount
				SnowMan.SetStage_Campfire(stage);
				SnowMan.SetHitcount_Campfire(hitcount);
			end
		end
	end
	
	-- hook into OnThrowableHit
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnThrowableHit") then
				if(msg.msg.nid == System.App.profiles.ProfileManager.GetNID()) then
					local msg = msg.msg;
					-- on hit dirty elk with snow ball
					if(msg.throwItem.gsid == 9504) then
						local snowMan = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30318);
						if(snowMan and snowMan:IsValid() == true) then
							local _, name;
							for _, name in pairs(msg.hitObjNameList or {}) do
								if(name == snowMan.name) then
									-- hit on self
									Map3DSystem.GSL_client:SendRealtimeMessage("s30318", {body="[Aries][ServerObject30318]AppendSnow:1"});
									-- auto show snowman select page 
									MyCompany.Aries.Desktop.TargetArea.ShowNPCSelectPage(30318);
								end
							end
						end
					elseif(msg.throwItem.gsid == 9503) then
						-- ThrowableSpecialFirecracker
						local campfire = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(31318);
						if(campfire and campfire:IsValid() == true) then
							local _, name;
							for _, name in pairs(msg.hitObjNameList or {}) do
								if(name == campfire.name) then
									-- hit on self
									Map3DSystem.GSL_client:SendRealtimeMessage("s30318", {body="[Aries][ServerObject30318]AppendFire:1"});
									-- auto show campfire select page 
									MyCompany.Aries.Desktop.TargetArea.ShowNPCSelectPage(31318);
								end
							end
						end
					end
				end
			end
		end, 
	hookName = "OnThrowableHit_30318_Snowman", appName = "Aries", wndName = "throw"});
	
	--Map3DSystem.GSL_client:SendRealtimeMessage("s30318", {body="[Aries][ServerObject30318]TryPickObj:31"});
end

function SnowMan.main_campfire()
end

function SnowMan.SetHitcount(hitcount)
	SnowMan.hitcount = hitcount;
end

function SnowMan.SetHitcount_Campfire(hitcount)
	SnowMan.hitcount_Campfire = hitcount;
end

local stage_delta_scale = 0.3;

function SnowMan.SetStage(stage)
	SnowMan.stage = stage;
	local npcChar, npcModel = Quest.NPC.GetNpcCharModelFromIDAndInstance(30318);
	if(npcModel) then
		local scale_model = 1 + stage * stage_delta_scale;
		npcChar:SetScale(scale_model * 3);
		npcModel:SetScale(scale_model);
	end
end

function SnowMan.SetStage_Campfire(stage)
	SnowMan.stage_Campfire = stage;
	local npcChar, npcModel = Quest.NPC.GetNpcCharModelFromIDAndInstance(31318);
	if(npcChar) then
		local assetfile = "character/v5/06quest/Bonfire/Bonfire_Off.x";
		if(stage == 1) then
			assetfile = "character/v5/06quest/Bonfire/Bonfire_On.x";
		end
		if(assetfile ~= npcChar:GetPrimaryAsset():GetKeyName()) then
			local asset = ParaAsset.LoadParaX("", assetfile);
			local npcCharChar = npcChar:ToCharacter();
			npcCharChar:ResetBaseModel(asset);
		end
	end
end

function SnowMan.EnterStage(stage)
	SnowMan.stage = stage;
	--SnowMan.SetStage(stage);
	
	if(stage < 5) then
		local scale_from = 1 + (stage - 1) * stage_delta_scale;
		local scale_to = 1 + (stage) * stage_delta_scale;
		local deltaScale = scale_to - scale_from;
		local times = {1, 50, 100, 150, 200, 250, 300, 350};
		local data = {0, 9,  16,  21,  24,  25,  24,  21};
		UIAnimManager.PlayCustomAnimation(350, function(elapsedTime)
			local npcModel = MyCompany.Aries.Quest.NPC.GetNpcModelFromIDAndInstance(30318);
			if(npcModel) then
				if(elapsedTime == 350) then
					npcModel:SetScale(scale_to);
				end
				local first, second;
				local i, time;
				for i, time in pairs(times) do
					if(times[i + 1] and elapsedTime >= times[i] and elapsedTime < times[i + 1]) then
						first = i;
						second = i + 1;
						break;
					end
				end
				if(first and second) then
					local delta = ((elapsedTime - times[first])/(times[second] - times[first]) * (data[second] - data[first]) + data[first]) * deltaScale / 25;
					npcModel:SetScale(delta + scale_from);
				end
			end
		end);
	elseif(stage == 5) then
		UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
			local npcModel = Quest.NPC.GetNpcModelFromIDAndInstance(30318);
			if(npcModel) then
				if(elapsedTime < 100) then
					npcModel:SetScale(1 + (stage - 1) * stage_delta_scale + (elapsedTime / 100) * stage_delta_scale);
				else
					npcModel:SetScale(1 + (stage) * stage_delta_scale - ( (elapsedTime - 100) / 400) * stage_delta_scale * 5);
				end
			end
		end);
	end
end

function SnowMan.main2()
	local i, target;
	for i, target in ipairs(targets) do
		local start_time = math.floor(math.random(100, 2000));
		UIAnimManager.PlayCustomAnimation(start_time, function(elapsedTime)
			if(elapsedTime == start_time) then
				SnowMan.GenerateBubble(i);
				SnowMan.CreateGiftBox(i, -100);
			end
		end);
	end
end

function SnowMan.main3()
	local i;
	for i = instances_gift_range[1], instances_gift_range[2] do
		SnowMan.DestroyGift(i);
	end
	local i;
	for i = instances_joybean_range[1], instances_joybean_range[2] do
		SnowMan.DestroyJoybean(i);
	end
end

function SnowMan.main4()
	local i;
	for i = instances_gift_range[1], instances_gift_range[2] do
		SnowMan.CreateGift(i);
		SnowMan.ThrowGift(i);
	end
	local i;
	for i = instances_joybean_range[1], instances_joybean_range[2] do
		SnowMan.CreateJoybean(i);
		SnowMan.ThrowJoybean(i);
	end
end

function SnowMan.ToNPCid_Gift(index)
	return 3031800 + index;
end

function SnowMan.ToGiftid(index)
	return index - 3031800;
end

function SnowMan.ToNPCid_Joybean(index)
	return 3031800 + 50 + index;
end

function SnowMan.ToJoybeanid(index)
	return index - 3031800 - 50;
end

function SnowMan.ThrowGift(index)
	if(not SnowMan.IsGiftVisualized(index)) then
		return;
	end
	local position = gift_positions[index];
	local x, y, z = position[1], position[2], position[3];
	local c_x, c_y, c_z = center[1], center[2], center[3];
	
	local duration_time = math.mod(index, 7) * 0.2 + math.mod(index, 5) * 0.5;
	local height = (20 / 8) * duration_time * duration_time;
	duration_time = duration_time * 1000;
	
	UIAnimManager.PlayCustomAnimation(duration_time, function(elapsedTime)
		local npcid = SnowMan.ToNPCid_Gift(index);
		local gift, gift_model = MyCompany.Aries.Quest.NPC.GetNpcCharModelFromIDAndInstance(npcid);
		if(gift and gift_model) then
			if(elapsedTime == duration_time) then
				gift:SetPosition(x, y, z);
				gift_model:SetPosition(x, y, z);
			else
				local t_x = c_x - (c_x - x) * (elapsedTime / duration_time);
				local t_z = c_z - (c_z - z) * (elapsedTime / duration_time);
				local t = math.abs(elapsedTime - duration_time / 2) / 1000;
				local t_y = y + height - 0.5 * 20 * t * t;
				gift:SetPosition(t_x, t_y, t_z);
				gift_model:SetPosition(t_x, t_y, t_z);
			end
		end
	end);
end

function SnowMan.ThrowJoybean(index)
	if(not SnowMan.IsJoybeanVisualized(index)) then
		return;
	end
	local position = joybean_positions[index];
	local x, y, z = position[1], position[2], position[3];
	local c_x, c_y, c_z = center[1], center[2], center[3];
	
	local duration_time = math.mod(index, 7) * 0.2 + math.mod(index, 5) * 0.5;
	local height = (20 / 8) * duration_time * duration_time;
	duration_time = duration_time * 1000;
	
	UIAnimManager.PlayCustomAnimation(duration_time, function(elapsedTime)
		local npcid = SnowMan.ToNPCid_Joybean(index);
		local joybean = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(npcid);
		if(joybean) then
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

function SnowMan.CreateGift(index)
	if(SnowMan.IsGiftVisualized(index)) then
		return;
	end
	local position = gift_positions[index];
	--if(offsety) then
		--position[2] = position[2] + offsety;
	--end
	
	local assetfile = "model/06props/v5/03quest/SnowMen/SnowMan_Blue.x";
	local scaling = 0.5;
	if(math.mod(index, 4) == 0) then
		assetfile = "model/06props/v5/03quest/SnowMen/SnowMan_Blue.x";
		scaling = 0.3;
	elseif(math.mod(index, 4) == 1) then
		assetfile = "model/06props/v5/03quest/SnowMen/SnowMan_Purple.x";
		scaling = 0.3;
	elseif(math.mod(index, 4) == 2) then
		assetfile = "model/06props/v5/03quest/SnowMen/SnowMan_Pink.x";
		scaling = 0.3;
	elseif(math.mod(index, 4) == 3) then
		assetfile = "model/06props/v5/03quest/SnowMen/SnowMan_Red.x";
		scaling = 0.3;
	end
	local params = {
		name = "",
		position = position,
		assetfile_char = "character/common/dummy/elf_size/elf_size.x",
		assetfile_model = assetfile,
		facing = math.random(0, 628)/100,
		scaling = scaling,
		main_script = "",
		main_function = "",
		talkdist = 2,
		predialog_function = "MyCompany.Aries.Quest.NPCs.SnowMan.Gift_PreDialog",
		EnablePhysics = false,
		cursor = "Texture/Aries/Cursor/Pick.tga",
	};
	local npcid = SnowMan.ToNPCid_Gift(index);
	local NPC = MyCompany.Aries.Quest.NPC;
	local box, boxModel = NPC.CreateNPCCharacter(npcid, params);
end

-- destroy gift box
function SnowMan.DestroyGift(index)
	local npcid = SnowMan.ToNPCid_Gift(index);
	local NPC = MyCompany.Aries.Quest.NPC;
	NPC.DeleteNPCCharacter(npcid);
end

-- check if gift box visualized in scene
function SnowMan.IsGiftVisualized(index)
	local npcid = SnowMan.ToNPCid_Gift(index);
	local gift = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(npcid);
	if(gift) then
		return true;
	end
	return false;
end

function SnowMan.CreateJoybean(index)
	if(SnowMan.IsJoybeanVisualized(index)) then
		return;
	end
	local position = joybean_positions[index];
	--if(offsety) then
		--position[2] = position[2] + offsety;
	--end
	
	--local assetfile = "character/v5/08functional/JoyBean/JoyBean.x";
	local assetfile = "character/v5/08functional/IceStone/IceStone.x";
	local params = {
		name = "",
		position = position,
		assetfile_char = assetfile,
		facing = math.random(0, 628)/100,
		scaling = 1,
		main_script = "",
		main_function = "",
		talkdist = 2,
		predialog_function = "MyCompany.Aries.Quest.NPCs.SnowMan.Joybean_PreDialog",
		EnablePhysics = false,
		cursor = "Texture/Aries/Cursor/Pick.tga",
	};
	local npcid = SnowMan.ToNPCid_Joybean(index);
	local NPC = MyCompany.Aries.Quest.NPC;
	local box, boxModel = NPC.CreateNPCCharacter(npcid, params);
end

-- destroy gift box
function SnowMan.DestroyJoybean(index)
	local npcid = SnowMan.ToNPCid_Joybean(index);
	local NPC = MyCompany.Aries.Quest.NPC;
	NPC.DeleteNPCCharacter(npcid);
end

-- check if joybean visualized in scene
function SnowMan.IsJoybeanVisualized(index)
	local npcid = SnowMan.ToNPCid_Joybean(index);
	local gift = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(npcid);
	if(gift) then
		return true;
	end
	return false;
end

---- make the game
--function SnowMan.FallDownGift(index, falldownfrom)
	--local npcid = SnowMan.ToNPCid(index);
	--local NPC = MyCompany.Aries.Quest.NPC;
	--local box = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(npcid);
	--if(falldownfrom and box and box:IsValid() == true) then
		--local x, y, z = box:GetPosition();
		--box:SetPosition(x, falldownfrom, z);
		--box:ToCharacter():FallDown();
	--end
--end

-- SnowMan timer
function SnowMan.On_Timer()
end

function SnowMan.PreDialog()
	-- TODO: request for object pick
	-- TODO: wait for response
	
	--id
	--SnowMan_ids[id]
	
	--Map3DSystem.GSL_client:SendRealtimeMessage("s30318", {body="[Aries][ServerObject30318]TryPickObj:31"});
	
	--_guihelper.MessageBox("“再给我来点雪球吧，我会长得更大！”")
	--
	
	--哇~，你获得了一张”X”字贺卡，赶紧再找找，贺卡可以兑换气球或者泡泡机哦！
	
	
	local snowMan = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30318);
	if(snowMan) then
		headon_speech.Speek(snowMan.name, headon_speech.GetBoldTextMCML("再给我来点雪球吧，我会长得更大！"), 3, true);
	end
	
	return false;
end

function SnowMan.PreDialog_Campfire()
	local campfire = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(31318);
	if(campfire) then
		
		headon_speech.Speek(campfire.name, headon_speech.GetBoldTextMCML("火魔之子费尔斯通被抓走了，封印在沙漠岛的落日神殿深处，快去救他吧！"), 3, true);

		_guihelper.MessageBox([[<div style="margin-top:20px;margin-left:10px;width:240px;">火魔之子费尔斯通被抓走了，封印在沙漠岛的落日神殿深处，快去救他吧！<div>]]);

		do return end
		

		local nElapsedSeconds = MyCompany.Aries.Scene.GetElapsedSecondsSince0000();
		if(nElapsedSeconds < 20 * 3600 and nElapsedSeconds > 18 * 3600) then
			headon_speech.Speek(campfire.name, headon_speech.GetBoldTextMCML("我要旺……更旺……让我的火焰照亮整个哈奇小镇！"), 3, true);
		else
			headon_speech.Speek(campfire.name, headon_speech.GetBoldTextMCML("活动时间为每天的下午6点至晚上8点，时间到了你们就来找我吧！"), 3, true);
			return;
		end
		if(SnowMan.stage_Campfire == 1) then
			--MyCompany.Aries.Instance.EnterInstance_PreDialog(9931318);
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/NPCs/TownSquare/30318_SnowMan_LobbyMenu.html", 
				name = "30318_SnowMan_LobbyMenu.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 1,
				isTopLevel = true,
				enable_esc_key = true,
				allowDrag = false,
				directPosition = true,
					align = "_ct",
					x = -240/2,
					y = -200/2,
					width = 240,
					height = 200,
			});
		end
	end
end

function SnowMan.Gift_PreDialog()
	local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
	if(targetNPC_id) then
		local instance_id = SnowMan.ToGiftid(targetNPC_id);
		Map3DSystem.GSL_client:SendRealtimeMessage("s30318", {body="[Aries][ServerObject30318]TryPickGift:"..instance_id});
	end
	return false;
end

function SnowMan.Joybean_PreDialog()
	local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
	if(targetNPC_id) then
		local instance_id = SnowMan.ToJoybeanid(targetNPC_id);
		Map3DSystem.GSL_client:SendRealtimeMessage("s30318", {body="[Aries][ServerObject30318]TryPickJoybean:"..instance_id});
	end
	return false;
end

--17016_CheerCard_Ha
--17017_CheerCard_Qi
--17018_CheerCard_Xiao
--17019_CheerCard_Zhen
--17020_CheerCard_Huan
--17021_CheerCard_Ying
--17022_CheerCard_Ni

-- SnowMan timer
function SnowMan.OnRecvGift(index)
	--_guihelper.MessageBox("OnRecvGift"..tostring(index));
	local gsid = 30069;
	local text = "逗逗雪人";
	if(math.mod(index, 4) == 0) then
		gsid = 30069;
		text = "逗逗雪人";
	elseif(math.mod(index, 4) == 1) then
		gsid = 30070;
		text = "丫丫雪人";
	elseif(math.mod(index, 4) == 2) then
		gsid = 30071;
		text = "妮妮雪人";
	elseif(math.mod(index, 4) == 3) then
		gsid = 30072;
		text = "乐乐雪人";
	end
	
	ItemManager.PurchaseItem(gsid, 1, function(msg)
		if(msg) then
			log("+++++++SnowMan.OnRecvGift#"..tostring(gsid).." Purchase item return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess) then
				_guihelper.MessageBox(string.format([[<div style="margin-top:24px;margin-left:20px;">恭喜你获得一个%s，已经放进你家园仓库啦！</div>]], text));
			end
		end
	end);
end

function SnowMan.OnRecvJoybean(index)
	--local pick_count = math.floor(math.random(3,9)) * 10;
    --local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
    --if(AddMoneyFunc) then
        --AddMoneyFunc(pick_count, function(msg)
			--log("============ SnowMan.OnRecvJoybean returns: ============");
			--commonlib.echo(pick_count);
			--commonlib.echo(msg);
        --end);
    --end
    
    -- 17040_IceBrick
	ItemManager.PurchaseItem(17040, 1, function(msg)
		if(msg) then
			log("+++++++SnowMan.OnRecvGift Purchase 17040_IceBrick return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess) then
				_guihelper.MessageBox(string.format([[<div style="margin-top:24px;margin-left:20px;">恭喜你获得一个%s，已经放进你的背包里啦！</div>]], "冰块"));
			end
		end
	end);
end

function SnowMan.OnPickedThisRound()
	_guihelper.MessageBox([[<div style="margin-top:24px;margin-left:10px;">很抱歉，这批雪人你已经拿过了，每批只能拿1个哦！</div>]]);
end

local texts = {"哈", "奇", "小", "镇", "欢", "迎", "你"};

-- SnowMan timer
function SnowMan.OnRecvReward(gsid, count)
	if(gsid and gsid >= 17016 and gsid <= 17022) then
		local index = gsid - 17016 + 1;
		local text = texts[index];
		ItemManager.PurchaseItem(gsid, 1, function(msg)
			if(msg) then
				log("+++++++SnowMan.OnRecvReward: Purchase item return: #"..tostring(gsid).." +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess) then
					_guihelper.MessageBox(string.format([[<div style="margin-top:32px;margin-left:32px;">哇~，你获得了一张”%s”字贺卡！</div>]], text));
				end
			end
		end);
	elseif(gsid == 16012) then
		-- 16012_PineApplePie
		ItemManager.PurchaseItem(16012, 1, function(msg)
			if(msg) then
				log("+++++++SnowMan.OnRecvReward: Purchase item 16012_PineApplePie return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess) then
					_guihelper.MessageBox([[<div style="margin-top:24px;margin-left:10px;">哇，你的运气真不错！捡到了一个大礼盒，里面有一个菠萝派，快快收起来吧！</div>]]);
				end
			end
		end);
	elseif(gsid == 0 and count) then
        local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
        if(AddMoneyFunc) then
	        AddMoneyFunc(count, function(msg) 
		        log("+++++++SnowMan.OnRecvReward: JoyBean:"..count.." returns: +++++++\n")
		        commonlib.echo(msg);
				if(msg.issuccess == true) then
					_guihelper.MessageBox(string.format([[<div style="margin-top:24px;margin-left:10px;">哇，你的运气真不错！捡到了一个大礼盒，里面有%s奇豆，快快收起来吧！</div>]], count));
				end
				-- send log information
				if(msg.issuccess == true) then
					paraworld.PostLog({action = "joybean_obtain_from_other", joybeancount = count, desc = "SnowMan.GiftBox"}, 
						"joybean_obtain_from_other_log", function(msg)
					end);
				end
	        end);
        end
	end
end