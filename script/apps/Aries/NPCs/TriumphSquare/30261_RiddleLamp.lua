--[[
Title: RiddleLamp
Author(s): WangTian
Date: 2009/8/20

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TriumphSquare/30261_RiddleLamp.lua
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/NPCs/TriumphSquare/30261_RiddleLampQuestionsLib.lua");
-- create class
local libName = "RiddleLamp";
local RiddleLamp = {
	cur_question = nil,
	selected_instance = nil,
	answered_wrong = nil,--是否已经错误回答了一个问题
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.RiddleLamp", RiddleLamp);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local answer_timeout = 100000000;

local lamp_positions = {
	{ 20204.779296875, 21.883098602295, 19816.224609375 },
	{ 20212.32421875, 32.624992370605, 19884.1640625 },
	{ 20151.806640625, 44.805438995361, 19862.201171875 },
	{ 20147.162109375, 44.872886657715, 19839.310546875 },
	{ 20155.75, 47.677845001221, 19817.3828125 },
	{ 20195.705078125, 61.05492401123, 19828.3671875 },
	{ 20202.751953125, 71.527534484863, 19848.341796875 },
	{ 20166.197265625, 85.163375854492, 19863.56640625 },
	{ 20173.05078125, 90.027084350586, 19825.849609375 },
	{ 20195.66015625, 92.720726013184, 19833.498046875 },
};

--local head = {20177.69921875, 0.69979959726334, 19884.490234375};
--local tail = {20194.361328125, 0.46496602892876, 19831.10546875};

local lamp_count = 10;

--local i;
--for i = 1, lamp_count do
	--local new_x = head[1] + (tail[1] - head[1]) * (i - 1) / 19;
	--local new_y = head[2] + (tail[2] - head[2]) * (i - 1) / 19;
	--local new_z = head[3] + (tail[3] - head[3]) * (i - 1) / 19;
	--table.insert(lamp_positions, {new_x, new_y, new_z});
--end

local base_lamp_param = {
	assetfile_char = "character/common/dummy/elf_size/elf_size.x",
	facing = 0,
	--scaling = 0.5,
	scale_char = 1.1,
	scale_model = 2,
	main_script = "script/apps/Aries/NPCs/TriumphSquare/30261_RiddleLamp.lua",
	main_function = "MyCompany.Aries.Quest.NPCs.RiddleLamp.main_lamp();",
	predialog_function = "MyCompany.Aries.Quest.NPCs.RiddleLamp.PreDialog_lamp",
	dialog_page = "script/apps/Aries/NPCs/TriumphSquare/30261_RiddleLamp_dialog.html",
};

-- RiddleLamp.main
function RiddleLamp.main()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30261);
	-- reset if not init
	memory.LastLightupTimes = memory.LastLightupTimes or {};
	
	-- create npc instances of the riddle lamps
	local i;
	for i = 1, lamp_count do
		local riddleLamp_model = NPC.GetNpcModelFromIDAndInstance(302611, i);
		if(riddleLamp_model) then
		else
			--local asset_model = "model/06props/v5/03quest/LanternRiddles/LanternRiddles.x";
			--local asset_model = "model/06props/v5/03quest/LanternRiddles/LanternRiddles_off.x";
			local params = commonlib.deepcopy(base_lamp_param);
			params.instance = i;
			params.name = "第"..i.."盏灯";
			params.position = lamp_positions[i];
			params.assetfile_model = "model/06props/v5/03quest/LanternRiddles/LanternRiddles.x";
			local NPC = MyCompany.Aries.Quest.NPC;
			local npcChar = NPC.CreateNPCCharacter(302611, params);
		end
	end
	
	-- force execute ontimer function, to set the lamp on or off
	RiddleLamp.On_Timer();
	
	
end

function RiddleLamp.main_lamp()
end

-- RiddleLamp.On_Timer
function RiddleLamp.On_Timer()
	local isDuringRiddle = false;
	local i;
	for i = 1, lamp_count do
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30261);
		local lastLightupTime = memory.LastLightupTimes[i];
		local isLampLighten = false;
		if(lastLightupTime) then
			--if((ParaGlobal.GetGameTime() - lastLightupTime) > answer_timeout) then
				---- turn off the lamp and reset lightup time
				--memory.LastLightupTimes[i] = nil;
			--else
				--isLampLighten = true;
			--end
			isLampLighten = true;
		end
		local asset_file;
		if(isLampLighten == true) then
			asset_file = "model/06props/v5/03quest/LanternRiddles/LanternRiddles.x";
		else
			asset_file = "model/06props/v5/03quest/LanternRiddles/LanternRiddles_off.x";
		end
		
		local riddleLamp_model = NPC.GetNpcModelFromIDAndInstance(302611, i);
		if(riddleLamp_model) then
			local asset_keyname = riddleLamp_model:GetPrimaryAsset():GetKeyName();
			if(asset_keyname ~= asset_file) then
				-- reset the NPC name and model asset file
				NPC.ChangeModelAsset(302611, i, asset_file);
				NPC.ChangeHeadonText(302611, i, "第"..i.."盏灯");
			end
		end
		-- if last lightup time exists
		if(isDuringRiddle == false and memory.LastLightupTimes[i]) then
			isDuringRiddle = true;
		end
	end
	
	if(isDuringRiddle == true) then
		-- am i in triumph square?
		local x, y, z = ParaScene.GetPlayer():GetPosition();
		local args = System.App.worlds.Global_RegionRadar.WhereIsXZ(x, z);
		if(args and args.key ~= "Region_TownSquare" and args.key ~= "Region_TriumphSquare") then
			-- reset the riddle progress
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">你已经离开灯谜桥太远了，本次灯谜挑战失败了！</div>]]);
			RiddleLamp.ResetRiddleProgress();
		end
		
		local hour, minute, second = RiddleLamp.GetTimeFromFirstCorrectAnswer();
		if(hour and minute and second and not RiddleLamp.IsAllLampsLightup()) then
			MyCompany.Aries.Scene.ShowRegionLabel("当前答题耗时："..hour.."小时"..minute.."分"..second.."秒", "240 226 43");
		end
	end
end

function RiddleLamp.CorrectRiddle(instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30261);
	memory.LastLightupTimes[instance] = ParaGlobal.GetGameTime();
	
	RiddleLamp.answered_wrong = nil;
	
end

function RiddleLamp.PreDialog_lamp(npc_id, instance)
	-- 1156_YuanXiaoTorch
	if(not equipGSItem(1156)) then
		_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">想要挑战灯谜桥，先找到智者火把，把它拿在手中再来吧！</div>]]);
		return false;
	end
	--生成一个问题
	RiddleLamp.cur_question = MyCompany.Aries.Quest.NPCs.RiddleLampQuestionsLib.Get_Question();
	
	if(RiddleLamp.selected_instance ~= instance)then
		RiddleLamp.answered_wrong = nil;
	end
	RiddleLamp.selected_instance = instance;
	
	return true;
end

function RiddleLamp.PreDialog()
	
	return true;
end

-- correct all riddle from the firework launcher dialog
function RiddleLamp.OnFireworkLuncher_CorrectAllRiddle()
	local __,__,__,seconds = RiddleLamp.GetCompleteTime();
	commonlib.echo("====test seconds");
	commonlib.echo(seconds);
	--发送比分
	if(seconds and seconds > 0)then
		seconds = 1000000 - seconds;
		NPL.load("(gl)script/kids/3DMapSystemApp/API/minigame/paraworld.minigame.lua");
		local msg = {
						gamename = "RiddleLampChallenge",
						score = seconds,
					}
		commonlib.echo("begin send score of RiddleLampChallenge:");
		commonlib.echo(msg);
		paraworld.minigame.SubmitRank(msg,"minigame",function(msg)	
			commonlib.echo("after send score of RiddleLampChallenge:");
			commonlib.echo(msg);
		end);
	end
	local i;
	for i = 1, lamp_count do
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30261);
		local lastLightupTime = memory.LastLightupTimes[i];
		if(not lastLightupTime) then
			-- containing non light up lamp
			return;
		end
	end
end

function RiddleLamp.LaunchFireworkAndSummonYuanXiaoBaby()
	-- reset progress
	RiddleLamp.ResetRiddleProgress()
	-- launch firework
	local params = {
		asset_file = "model/07effect/v5/Fireworks/Fireworks.x",
		ismodel = true,
		binding_obj_name = nil,
		scale = 2,
		start_position = {20188.12109375, 92.923355102539, 19862.484375},
		duration_time = 8000,
		begin_callback = function() 
			end,
		end_callback = function()
			end,
		stage1_time = 2000,
		stage1_callback = function()
			local npcChar = NPC.GetNpcCharacterFromIDAndInstance(30213, 1);
			if(npcChar) then
			else
				-- clear the npc memory first, created the baby with empty memory
				MyCompany.Aries.Quest.NPCAIMemory.ClearMemory(30213);
				-- create 3 yuanxiao babies
				local positions = {
					{ 20189.931640625, 92.923355102539, 19861.947265625 },
					{ 20186.04296875, 92.923355102539, 19862.5390625 },
					{ 20187.95703125, 92.923355102539, 19860.3203125 },
				};
				local base_params = {
					name = "元宵宝宝",
					position = { 20196.240234375, 0.49808216094971, 19813.0859375 },
					assetfile_char = "character/v5/02animals/YuanxiaoBaby/YuanxiaoBaby.x",
					facing = 0.91666221618652,
					scaling = 1.0,
					scaling_char = 1.0,
					talkdist = 10,
					main_script = "script/apps/Aries/NPCs/FollowPets/30213_YuanXiaoBaby.lua",
					main_function = "MyCompany.Aries.Quest.NPCs.YuanXiaoBaby.main();",
					on_timer = ";MyCompany.Aries.Quest.NPCs.YuanXiaoBaby.On_Timer();",
					predialog_function = "MyCompany.Aries.Quest.NPCs.YuanXiaoBaby.PreDialog",
					dialog_page = "script/apps/Aries/NPCs/FollowPets/30213_YuanXiaoBaby_dialog.html",
					--AI_script = "script/apps/Aries/NPCs/FollowPets/30213_YuanXiaoBaby_AI.lua",
					--On_FrameMove = ";MyCompany.Aries.Quest.NPCAI.YuanXiaoBaby_AI.On_FrameMove();",
				};
				local NPC = MyCompany.Aries.Quest.NPC;
				-- create 3 yuanxiao babies
				local i;
				for i = 1, 3 do
					base_params.position = positions[i];
					base_params.instance = i;
					local npcChar = NPC.CreateNPCCharacter(30213, base_params);
					if(i == 2 or i == 3) then
						if(npcChar and npcChar:IsValid() == true) then
							npcChar:SetVisible(false);
						end
					end
				end
				---- auto talk to yuanxiao baby NPC
				--MyCompany.Aries.Desktop.TargetArea.TalkToNPC(30213, 1);
			end
		end,
	};
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.CreateEffect(params);
end

function RiddleLamp.IsAllLampsLightup()
	local i;
	for i = 1, lamp_count do
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30261);
		local lastLightupTime = memory.LastLightupTimes[i];
		if(not lastLightupTime) then
		    return false;
		end
	end
    return true;
end

-- get complete all riddle time
-- @return: hour minute second completeseconds
function RiddleLamp.GetCompleteTime()
	local hour;
	local minute;
	local second;
	local i;
	local min = ParaGlobal.GetGameTime();
	local max = 0;
	for i = 1, lamp_count do
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30261);
		local lastLightupTime = memory.LastLightupTimes[i];
		if(not lastLightupTime) then
		    return;
		end
		if(lastLightupTime > max) then
			max = lastLightupTime;
		end
		if(lastLightupTime < min) then
			min = lastLightupTime;
		end
	end
	local completeseconds;
	if(min < max) then
		local progress = max - min;
		completeseconds = math.floor(progress / 1000);
		second = math.mod(completeseconds, 60);
		minute = math.mod(math.floor(completeseconds / 60), 60);
		hour = math.floor(completeseconds / 3600);
	end
	return hour, minute, second, completeseconds;
end

function RiddleLamp.GetTimeFromFirstCorrectAnswer()
	local hour;
	local minute;
	local second;
	local i;
	local min = ParaGlobal.GetGameTime();
	local max = 0;
	for i = 1, lamp_count do
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30261);
		local lastLightupTime = memory.LastLightupTimes[i];
		if(lastLightupTime) then
			--if(lastLightupTime > max) then
				--max = lastLightupTime;
			--end
			if(lastLightupTime < min) then
				min = lastLightupTime;
			end
		end
	end
	if(min < ParaGlobal.GetGameTime()) then
		local progress = ParaGlobal.GetGameTime() - min;
		local completeseconds = math.floor(progress / 1000);
		second = math.mod(completeseconds, 60);
		minute = math.mod(math.floor(completeseconds / 60), 60);
		hour = math.floor(completeseconds / 3600);
	end
	return hour, minute, second, completeseconds;
end

function RiddleLamp.ResetRiddleProgress()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30261);
	memory.LastLightupTimes = {};
end

function RiddleLamp.PreDialog(npc_id, instance)
	return true;
end
--如果回答问题错误 重新生成一个问题
function RiddleLamp.OpenQuestionAgain()
	RiddleLamp.answered_wrong = true;
	UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
		if(elapsedTime == 500) then
			MyCompany.Aries.Desktop.TargetArea.TalkToNPC(302611, RiddleLamp.selected_instance or 1, true);
		end
	end);
			
end