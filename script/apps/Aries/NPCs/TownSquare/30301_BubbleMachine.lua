--[[
Title: BubbleMachine
Author(s): WangTian
Date: 2009/8/20

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30301_BubbleMachine.lua
------------------------------------------------------------
]]

-- create class
local libName = "BubbleMachine";
local BubbleMachine = commonlib.gettable("MyCompany.Aries.Quest.NPCs.BubbleMachine");

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
				{3, 20016.13671875, 0.93925732374191, 19798.75390625},
				
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
				{6, 20081.802734375, 1.4999819993973, 19781.33984375},
				{6, 20081.69921875, 1.4999935626984, 19774.626953125},
				{6, 20079.734375, 1.4999893903732, 19775.220703125},
				{6, 20078.541015625, 1.4999887943268, 19776.412109375},
				{6, 20077.775390625, 1.4999949932098, 19782.541015625},
				{6, 20078.90625, 1.4999933242798, 19773.53125},
				{6, 20079.7734375, 1.499990105629, 19782.123046875},
				
				};
				


local instances = {};
local instance_range = {1, 60};
local machines = {  {range = {1, 10}, update_count = 5, update_interval = 300000, clear_afterupdate = 240000, },
					{range = {11, 20}, update_count = 5, update_interval = 300000, clear_afterupdate = 240000, },
					{range = {21, 30}, update_count = 5, update_interval = 300000, clear_afterupdate = 240000, },
					{range = {31, 40}, update_count = 5, update_interval = 360000, clear_afterupdate = 300000, },
					{range = {41, 50}, update_count = 5, update_interval = 360000, clear_afterupdate = 300000, },
					{range = {51, 60}, update_count = 5, update_interval = 360000, clear_afterupdate = 300000, },
				};
local machine_count = #machines;

-- BubbleMachine.main
function BubbleMachine.main()
	local serverobject = Map3DSystem.GSL_client:GetServerObject("s30301");
	if(serverobject) then
		local machine_id;
		for machine_id = 1, machine_count do
			local instances = serverobject:GetValue("machine"..machine_id);
			if(instances) then
				local start = machines[machine_id].range[1];
				local finish = machines[machine_id].range[2];
				local index = start;
				local exist;
				for exist in string.gfind(instances, "([^,]+)") do
					if(exist == "1") then
						BubbleMachine.CreateGiftBox(index);
					elseif(exist == "0") then
						BubbleMachine.DestroyGiftBox(index);
					end
					index = index + 1;
					if(index > finish) then
						break;
					end
				end
			end
		end
	end
	
	--Map3DSystem.GSL_client:SendRealtimeMessage("s30301", {body="[Aries][ServerObject30301]TryPickObj:31"});
end

function BubbleMachine.main2()
	local i, target;
	for i, target in ipairs(targets) do
		local start_time = math.floor(math.random(100, 2000));
		UIAnimManager.PlayCustomAnimation(start_time, function(elapsedTime)
			if(elapsedTime == start_time) then
				BubbleMachine.GenerateBubble(i);
				BubbleMachine.CreateGiftBox(i, -100);
			end
		end);
	end
end

function BubbleMachine.main3()
	local i, target;
	for i, target in ipairs(targets) do
		local start_time = math.floor(math.random(100, 2000));
		UIAnimManager.PlayCustomAnimation(start_time, function(elapsedTime)
			if(elapsedTime == start_time) then
				BubbleMachine.DestroyGiftBox(i);
			end
		end);
	end
end

function BubbleMachine.main4()
	local i, target;
	for i, target in ipairs(targets) do
		local start_time = math.floor(math.random(100, 2000));
		UIAnimManager.PlayCustomAnimation(start_time, function(elapsedTime)
			if(elapsedTime == start_time) then
				BubbleMachine.CreateGiftBox(i);
			end
		end);
	end
end

function BubbleMachine.ToNPCid(index)
	return 3030100 + index;
end

function BubbleMachine.ToBubbleid(index)
	return index - 3030100;
end

function BubbleMachine.GenerateBubble(index)
	local duration_time = 2000 + math.mod(index, 5) * 300 + math.floor(math.random(0, 100));
	local speed_y = 0.0001 * (10 + math.mod(index, 7) * 4 + math.floor(math.random(0, 1)));
	local target = {targets[index][2], targets[index][3], targets[index][4]};
	local nozzle = {nozzles[targets[index][1]][1], nozzles[targets[index][1]][2], nozzles[targets[index][1]][3]};
	local bubble_name = "bubble_name_"..index;
	-- play bubble animation
	local durationTimeSqSq = math.pow(duration_time, 4);
	UIAnimManager.PlayCustomAnimation(duration_time, function(elapsedTime)
		if(elapsedTime == 0) then
			-- begin animation, create new effect object
			local effectGraph = ParaScene.GetMiniSceneGraph("aries_effect");
			if(effectGraph and effectGraph:IsValid() == true) then
				effectGraph:DestroyObject(bubble_name);
				local assetfile = "character/v5/06quest/Bubbles/Bubbles_a.x";
				local remaining = math.mod(index, 7);
				if(remaining == 0) then
					assetfile = "character/v5/06quest/Bubbles/Bubbles_a.x";
				elseif(remaining == 1) then
					assetfile = "character/v5/06quest/Bubbles/Bubbles_b.x";
				elseif(remaining == 2) then
					assetfile = "character/v5/06quest/Bubbles/Bubbles_c.x";
				elseif(remaining == 3) then
					assetfile = "character/v5/06quest/Bubbles/Bubbles_d.x";
				elseif(remaining == 4) then
					assetfile = "character/v5/06quest/Bubbles/Bubbles_e.x";
				elseif(remaining == 5) then
					assetfile = "character/v5/06quest/Bubbles/Bubbles_f.x";
				elseif(remaining == 6) then
					assetfile = "character/v5/06quest/Bubbles/Bubbles_g.x";
				end
				local asset = ParaAsset.LoadParaX("", assetfile);
				local obj = ParaScene.CreateCharacter(bubble_name, asset , "", true, 1.0, 0, 1.0);
				if(obj and obj:IsValid() == true) then
					obj:SetScale(5);
					obj:SetPosition(nozzle[1], nozzle[2], nozzle[3]);
					effectGraph:AddChild(obj);
				end
			end
		elseif(elapsedTime ~= duration_time) then
			local effectGraph = ParaScene.GetMiniSceneGraph("aries_effect");
			if(effectGraph and effectGraph:IsValid() == true) then
				local bubble = effectGraph:GetObject(bubble_name);
				
				local npcid = BubbleMachine.ToNPCid(index);
				local box = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(npcid);
				if(box and box:IsValid() == true) then
					local x, y, z = box:GetPosition();
					box:SetPosition(x, -10000, z);
				end
				
				if(bubble and bubble:IsValid() == true) then
					local togoTimeSqSq = math.pow((duration_time - elapsedTime), 4);
					local x, y, z = bubble:GetPosition();
					local ratio = togoTimeSqSq/durationTimeSqSq;
					local new_x = target[1] + ratio * (nozzle[1] - target[1]);
					local new_z = target[3] + ratio * (nozzle[3] - target[3]);
					local new_y = nozzle[2] + elapsedTime * speed_y;
					bubble:SetPosition(new_x, new_y, new_z);
				end
			end
		elseif(elapsedTime == duration_time) then
			-- end animation, destroy effect object
			local effectGraph = ParaScene.GetMiniSceneGraph("aries_effect");
			if(effectGraph and effectGraph:IsValid() == true) then
				local bubble = effectGraph:GetObject(bubble_name);
				local x, y, z;
				if(bubble and bubble:IsValid() == true) then
					x, y, z = bubble:GetPosition();
				end
				effectGraph:DestroyObject(bubble_name);
				-- create gift box fall down from y
				BubbleMachine.FallDownGiftBox(index, y);
			end
		end
	end, bubble_name);
end

function BubbleMachine.CreateGiftBox(index, offsety, serverobject_id)
	if(BubbleMachine.IsGiftBoxVisualized(index)) then
		return;
	end
	local target = {targets[index][2], targets[index][3], targets[index][4]};
	local position = { target[1], target[2], target[3] };
	if(offsety) then
		position[2] = position[2] + offsety;
	end
	
	local assetfile = "character/v5/06quest/GiftBox/GiftBox_Blue.x";
	local scaling = 0.8;
	if(math.mod(index, 3) == 0) then
		assetfile = "character/v5/06quest/GiftBox/GiftBox_Pink.x";
		scaling = 0.6;
	elseif(math.mod(index, 3) == 1) then
		assetfile = "character/v5/06quest/GiftBox/GiftBox_Orange.x";
		scaling = 0.6;
	elseif(math.mod(index, 3) == 2) then
		assetfile = "character/v5/06quest/GiftBox/GiftBox_Blue.x";
		scaling = 0.6;
	end
	local params = {
		name = "",
		position = position,
		assetfile_char = assetfile,
		facing = 0.91666221618652,
		scaling = scaling,
		main_script = "",
		main_function = "",
		talkdist = 2,
		predialog_function = "MyCompany.Aries.Quest.NPCs.BubbleMachine.Gift_PreDialog",
		EnablePhysics = false,
		cursor = "Texture/Aries/Cursor/Pick.tga",
	};
	local npcid = BubbleMachine.ToNPCid(index);
	local NPC = MyCompany.Aries.Quest.NPC;
	local box, boxModel = NPC.CreateNPCCharacter(npcid, params);
end

-- destroy gift box
function BubbleMachine.DestroyGiftBox(index)
	local npcid = BubbleMachine.ToNPCid(index);
	local NPC = MyCompany.Aries.Quest.NPC;
	NPC.DeleteNPCCharacter(npcid);
end

-- check if gift box visualized in scene
function BubbleMachine.IsGiftBoxVisualized(index)
	local npcid = BubbleMachine.ToNPCid(index);
	local box = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(npcid);
	if(box and box:IsValid() == true) then
		return true;
	end
	return false;
end

-- make the game
function BubbleMachine.FallDownGiftBox(index, falldownfrom)
	local npcid = BubbleMachine.ToNPCid(index);
	local NPC = MyCompany.Aries.Quest.NPC;
	local box = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(npcid);
	if(falldownfrom and box and box:IsValid() == true) then
		local x, y, z = box:GetPosition();
		box:SetPosition(x, falldownfrom, z);
		box:ToCharacter():FallDown();
	end
end

-- BubbleMachine timer
function BubbleMachine.On_Timer()
end

function BubbleMachine.PreDialog()
	-- TODO: request for object pick
	-- TODO: wait for response
	
	--id
	--bubblemachine_ids[id]
	
	--Map3DSystem.GSL_client:SendRealtimeMessage("s30301", {body="[Aries][ServerObject30301]TryPickObj:31"});
	
	--_guihelper.MessageBox("哇，你的运气真不错！捡到了一个大礼盒，里面有XX，快快收起来吧！")
	--
	
	--哇~，你获得了一张”X”字贺卡，赶紧再找找，贺卡可以兑换气球或者泡泡机哦！
	return true;
end

function BubbleMachine.Gift_PreDialog(npc_id, instance_id)
	LOG.std("", "system", "BubbleMachine", "try picking gift %s", tostring(npc_id));
	if(npc_id) then
		local instance_id = BubbleMachine.ToBubbleid(npc_id);
		Map3DSystem.GSL_client:SendRealtimeMessage("s30301", {body="[Aries][ServerObject30301]TryPickObj:"..instance_id});
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

--17023_CheerCard_Xin
--17024_CheerCard_Nian
--17025_CheerCard_Kuai
--17026_CheerCard_Le

-- BubbleMachine timer
function BubbleMachine.OnRecvGift()
	--_guihelper.MessageBox("OnRecvGift");
	local ran = math.random(0, 1400);
	if(ran <= 100) then
		BubbleMachine.OnRecvReward(17016, 1);
	elseif(ran <= 100 * 2) then
		BubbleMachine.OnRecvReward(17017, 1);
	elseif(ran <= 100 * 3) then
		BubbleMachine.OnRecvReward(17018, 1);
	elseif(ran <= 100 * 4) then
		BubbleMachine.OnRecvReward(17019, 1);
	elseif(ran <= 100 * 5) then
		BubbleMachine.OnRecvReward(17020, 1);
	elseif(ran <= 100 * 6) then
		BubbleMachine.OnRecvReward(17021, 1);
	elseif(ran <= 100 * 7) then
		BubbleMachine.OnRecvReward(17022, 1);
	elseif(ran <= 100 * 8) then
		BubbleMachine.OnRecvReward(17023, 1);
	elseif(ran <= 100 * 9) then
		BubbleMachine.OnRecvReward(17024, 1);
	elseif(ran <= 100 * 10) then
		BubbleMachine.OnRecvReward(17025, 1);
	elseif(ran <= 100 * 11) then
		BubbleMachine.OnRecvReward(17026, 1);
	elseif(ran <= 100 * 11 + 50) then
		BubbleMachine.OnRecvReward(16012, 1);
	elseif(ran <= 100 * 11 + 50 + 150) then
		BubbleMachine.OnRecvReward(0, 100);
	elseif(ran <= 100 * 11 + 50 + 150 + 80) then
		BubbleMachine.OnRecvReward(0, 200);
	elseif(ran <= 1400) then
		BubbleMachine.OnRecvReward(0, 1000);
	end
end

function BubbleMachine.RecvLoot(gsid, guid, count)
	if(gsid == 17284 and guid and count) then
		-- 17284_BubbleMachinePack
		-- 1495 Get_17284_BubbleMachinePack
		ItemManager.ExtendedCost(1495, guid..","..count.."|", {12}, function() end, function() end);
	end

	do return end

	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem) then
		_guihelper.MessageBox(string.format([[<div style="margin-top:32px;margin-left:32px;">哇~，你获得了一个”%s”！</div>]], gsItem.template.name));
		local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
		Dock.OnPurchaseNotification(gsid, 1);
	end
end

local texts = {"哈", "奇", "小", "镇", "欢", "迎", "你", "新", "年", "快", "乐"};

-- BubbleMachine timer
function BubbleMachine.OnRecvReward(gsid, count)
	if(gsid and gsid >= 17016 and gsid <= 17026) then
		local index = gsid - 17016 + 1;
		local text = texts[index];
		ItemManager.PurchaseItem(gsid, 1, function(msg)
			if(msg) then
				log("+++++++BubbleMachine.OnRecvReward: Purchase item return: #"..tostring(gsid).." +++++++\n")
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
				log("+++++++BubbleMachine.OnRecvReward: Purchase item 16012_PineApplePie return: +++++++\n")
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
		        log("+++++++BubbleMachine.OnRecvReward: JoyBean:"..count.." returns: +++++++\n")
		        commonlib.echo(msg);
				if(msg.issuccess == true) then
					_guihelper.MessageBox(string.format([[<div style="margin-top:24px;margin-left:10px;">哇，你的运气真不错！捡到了一个大礼盒，里面有%s奇豆，快快收起来吧！</div>]], count));
				end
				-- send log information
				if(msg.issuccess == true) then
					paraworld.PostLog({action = "joybean_obtain_from_other", joybeancount = count, desc = "BubbleMachine.GiftBox"}, 
						"joybean_obtain_from_other_log", function(msg)
					end);
				end
	        end);
        end
	end
end