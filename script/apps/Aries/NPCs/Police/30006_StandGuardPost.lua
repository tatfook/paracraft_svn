--[[
Title: StandGuardPost
Author(s): WangTian
Date: 2009/7/24

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Police/30006_StandGuardPost.lua
------------------------------------------------------------
]]

-- create class
local libName = "StandGuardPost";
local StandGuardPost = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.StandGuardPost", StandGuardPost);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local footsteps ={};

-- StandGuardPost.main
function StandGuardPost.main()
	StandGuardPost.GetFootSteps();
	StandGuardPost.RefreshStatus();
end

function StandGuardPost.GetFootSteps()
	local config_file="config/Aries/FootSteps/61HaqiTown.FootSteps_Scene.xml";
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading mentor config file: %s\n", config_file);
		return;
	end
	
	local xmlnode="/FootSteps_scenes/FootSteps_scene"
	local each_place,i,keyname;
	i=1
	for each_place in commonlib.XPath.eachNode(xmlRoot, xmlnode) do
		for each_name in commonlib.XPath.eachNode(each_place, "/key") do
			keyname = each_name.attr.name;
		end
		footsteps[i]={name=keyname};
		footsteps[i].positions={};
		for each_pos in commonlib.XPath.eachNode(each_place, "/instances") do
        footsteps[i].positions= NPL.LoadTableFromString(each_pos.attr.positions);
    end
		i=i+1;
	end
end

-- update the NPC quest status in quest area
function StandGuardPost.RefreshStatus()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local equipGSItem = ItemManager.IfEquipGSItem;
	
	if(not hasGSItem(50002)) then
		-- delete quest status
		MyCompany.Aries.Desktop.QuestArea.DeleteQuestStatus(
			"script/apps/Aries/NPCs/Police/30006_StandGuardPost_DailyQuest_status.html" 
			);
	else
		-- append accept quest
		MyCompany.Aries.Desktop.QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Police/30006_StandGuardPost_DailyQuest_status.html",
			"medal", "", "为哈奇小镇的和平巡逻放哨", 50003);
	end
	
	StandGuardPost.RefreshFootSteps();
end

---- begin the stand on gurad post
--function StandGuardPost.BeginGuard(npc_id, instance)
	--local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30006);
	--memory.BeginGuard = true;
	--memory.BeginGuard_npc_id = npc_id;
	--memory.BeginGuard_instance = instance;
--end
--
---- end the stand on gurad post
--function StandGuardPost.EndGuard()
	--_guihelper.MessageBox("感谢你为小镇的安定与和平作出贡献！\n 完成巡逻后，记得去警察局的值勤表上签到。");
	--
	--local ItemManager = System.Item.ItemManager;
	--ItemManager.PurchaseItem(50004, 1, function(msg)
		--if(msg) then
			--log("+++++++Purchase 50004_StandGuardPost_DailyQuestGuard return: +++++++\n")
			--commonlib.echo(msg);
		--end
	--end);
--end

-- StandGuardPost.PreDialog
function StandGuardPost.PreDialog(npc_id, instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30006);
	
	local postIndex = StandGuardPost.GetPostIndex();
	local zoneName = StandGuardPost.GetPostZoneName();	

	memory.zoneNameToday = zoneName;
	
	if(not hasGSItem(50002)) then
		memory.dialog_state = 7;
	else
		if(equipGSItem(1008) and equipGSItem(1009) and equipGSItem(1010) and equipGSItem(1011) and equipGSItem(10106)) then
			-- 50003_StandGuardPost_DailyQuestAccept
			local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50003);
			if(gsObtain and gsObtain.inday > 0 and not hasGSItem(50003)) then
				-- finished today's quest
				memory.dialog_state = 6;
			else
				local memory_dutylist = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30002);
				if(gsObtain and gsObtain.inday > 0 and hasGSItem(50003) and StandGuardPost.HasUntouchedFootSteps()) then
					-- accepted, but requests not finished
					memory.dialog_state = 4;
				elseif(gsObtain and gsObtain.inday > 0 and hasGSItem(50003) and not StandGuardPost.HasUntouchedFootSteps()) then
					-- accepted, and requests finished
					memory.dialog_state = 5;
				elseif(postIndex ~= instance or memory_dutylist.zoneAssigned ~= true) then
					-- not the selected post
					memory.dialog_state = 2;
				elseif(gsObtain and gsObtain.inday == 0 and not hasGSItem(50003)) then
					-- not accepted today
					memory.dialog_state = 3;
				else
					-- unknown
					memory.dialog_state = -1;
				end
				
				
				local memory_dutylist = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30002);
				if(postIndex ~= instance) then
					-- not the selected post
					memory.dialog_state = 2;
				else
					if(hasGSItem(50003)) then
						if(gsObtain and gsObtain.inday > 0 and StandGuardPost.HasUntouchedFootSteps()) then
							-- accepted, but requests not finished
							memory.dialog_state = 4;
						elseif(gsObtain and gsObtain.inday > 0 and not StandGuardPost.HasUntouchedFootSteps()) then
							-- accepted, and requests finished
							memory.dialog_state = 5;
						else
							-- unknown
							memory.dialog_state = -1;
						end
					else
						-- not hasGSItem(50003)
						if(memory_dutylist.zoneAssigned ~= true) then
							-- hasn't assigned the zone yet
							memory.dialog_state = 2;
						elseif(gsObtain and gsObtain.inday == 0) then
							-- not accepted today
							memory.dialog_state = 3;
						else
							-- unknown
							memory.dialog_state = -1;
						end
					end
				end
			end
		else
			-- not equiped with police dog and police suit
			memory.dialog_state = 1;
		end
	end
	return true;
end

-- accept daily quest
function StandGuardPost.AcceptDailyQuest()
	-- accept the quest
	ItemManager.PurchaseItem(50003, 1, function(msg) end, function(msg) 
		if(msg) then
			log("+++++++Purchase 50003_StandGuardPost_DailyQuestAccept return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				-- refresh the foot steps
				StandGuardPost.RefreshStatus();
			end
		end
	end);
end

-- get daily reward
function StandGuardPost.GetDailyReward()
	local has_50002 = hasGSItem(50002);
	local has_20004 = hasGSItem(20004);
	local has_20006 = hasGSItem(20006);
	local has_20007 = hasGSItem(20007);
	local has_20008 = hasGSItem(20008);
	
	if(has_20008) then
        -- exid 122: Get_Police_FirstClassDailyReward
        ItemManager.ExtendedCost(122, nil, nil, function(msg)end, function(msg)
		    log("+++++++ExtendedCost 122: Get_Police_FirstClassDailyReward return: +++++++\n")
		    commonlib.echo(msg);
		    StandGuardPost.RefreshStatus();
        end);
	elseif(has_20007) then
        -- exid 121: Get_Police_SecondClassDailyReward
        ItemManager.ExtendedCost(121, nil, nil, function(msg)end, function(msg)
		    log("+++++++ExtendedCost 121: Get_Police_SecondClassDailyReward return: +++++++\n")
		    commonlib.echo(msg);
		    StandGuardPost.RefreshStatus();
        end);
	elseif(has_20006) then
        -- exid 120: Get_Police_ThirdClassDailyReward
        ItemManager.ExtendedCost(120, nil, nil, function(msg)end, function(msg)
		    log("+++++++ExtendedCost 120: Get_Police_ThirdClassDailyReward return: +++++++\n")
		    commonlib.echo(msg);
		    StandGuardPost.RefreshStatus();
        end);
	elseif(has_20004) then
        -- exid 119: Get_Police_AmateurClassDailyReward
        ItemManager.ExtendedCost(119, nil, nil, function(msg)end, function(msg)
		    log("+++++++ExtendedCost 119: Get_Police_AmateurClassDailyReward return: +++++++\n")
		    commonlib.echo(msg);
		    StandGuardPost.RefreshStatus();
        end);
	elseif(has_50002) then
        -- exid 124: Get_Police_InitClassDailyReward
        ItemManager.ExtendedCost(124, nil, nil, function(msg)end, function(msg)
		    log("+++++++ExtendedCost 124: Get_Police_InitClassDailyReward return: +++++++\n")
		    commonlib.echo(msg);
		    StandGuardPost.RefreshStatus();
        end);
	end
end

--local footsteps = {
	--[1] = { name = "多克特营地", positions = {
			--{ 19861.04296875, 8.3889045715332, 20041.4375 },
			--{ 19901.611328125, 0.66019362211227, 19994.27734375 },
			--{ 19921.888671875, 8.8811407089233, 20099.498046875 },
			--{ 19994.80859375, -0.20115931332111, 20015.787109375 },
			--{ 20028.47265625, -2.0216562747955, 20037.46875 },
		--},
	--},
	--[2] = { name = "农场", positions = {
			--{ 19849.23828125, 1.4285410642624, 19883.619140625 },
			--{ 19875.45703125, 0.12965220212936, 19947.9453125 },
			--{ 19918.65234375, 0.51925659179688, 19845.833984375 },
			--{ 19949.357421875, 1.0686893463135, 19882.525390625 },
			--{ 20004.337890625, 0.25922980904579, 19937.08984375 },
		--},
	--},
	--[3] = { name = "阳光海岸", positions = {
			--{ 20070.17578125, -1.169951581955, 19656.18359375 },
			--{ 20084.771484375, -2.4906344890594, 19606.99609375 },
			--{ 20119.087890625, -1.1008357286453, 19628.94140625 },
			--{ 20177.50390625, -3.207506942749, 19590.646484375 },
			--{ 20241.55859375, -1.5148959159851, 19635.53125 },
		--},
	--},

	--[4] = { name = "警署", positions = {
			--{ 20045.685546875, 1.5, 19787.322265625 },
			--{ 20090.41796875, 0.50730276107788, 19900.251953125 },
			--{ 20110.1953125, 1.2088786363602, 19835.40625 },
			--{ 20104.9609375, 3.491005897522, 19711.634765625 },
			--{ 20192.02734375, 3.5, 19755.62890625 },
		--},
	--},
--};

-- get post index 
function StandGuardPost.GetPostIndex()
	local nid = System.App.profiles.ProfileManager.GetNID();
	local serverdate = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	serverdate = string.gsub(serverdate, "%D", "");
	local days = tonumber(serverdate);
	
	local i = math.mod(math.mod((days * nid), 3571), 4) + 1; -- 3571: the 500th prime number
	return i;
end

-- get post zone name
function StandGuardPost.GetPostZoneName()
	commonlib.echo("=================Getzonename=============")
	commonlib.echo(footsteps);
	local i = StandGuardPost.GetPostIndex();
	return footsteps[i].name;
end

-- StandGuardPost.RefreshFootSteps()
function StandGuardPost.RefreshFootSteps()
	if(not hasGSItem(50003)) then
		StandGuardPost.DeleteAllFootSteps();
		return;
	end
	local i = StandGuardPost.GetPostIndex();
	local params = { 
		copies = 5,
		positions = footsteps[i].positions,
		name = "巡逻脚印",
		position = { 20047.056640625, 0.00011985249147983, 19927.291015625 },
		facing = 0.91666221618652,
		scaling = 1.5,
		talkdist = -1,
		isalwaysshowheadontext = false,
		assetfile_char = "character/v5/06quest/PolicePatrolFootStep/PolicePatrolFootStep.x",
		--character/v5/06quest/PolicePatrolFootStep/PolicePatrolFootStep.x
		--model\06props\v5\03quest\PolicePatrolFootStep
		main_script = "script/apps/Aries/NPCs/Police/30007_StandGuardPostFootStep.lua",
		main_function = "MyCompany.Aries.Quest.NPCs.StandGuardPostFootStep.main();",
		AI_script = "script/apps/Aries/NPCs/Police/30007_StandGuardPostFootStep_AI.lua",
		On_FrameMove = ";MyCompany.Aries.Quest.NPCAI.StandGuardPostFootStep_AI.On_FrameMove();",
	};
	local npc_id = 30007;
	--NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");
	--MyCompany.Aries.Quest.NPCAIMemory.ClearMemory(30007);
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30007);
	memory.steps = memory.steps or {};
	local visibleSteps = memory.steps;
	local i;
	for i = 1, 5 do
		if(visibleSteps[i] ~= false) then
			-- the heart is not fetched before
			local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(npc_id, i);
			if(not npcChar or npcChar:IsValid() == false) then
				-- heart npc character is not valid
				local params_this = commonlib.deepcopy(params);
				params_this.position = params_this.positions[i];
				params_this.position[2] = params_this.position[2] + 0.7;
				params_this.positions = nil;
				params_this.npc_id = npc_id;
				params_this.instance = i;
				NPC.CreateNPCCharacter(npc_id, params_this);
			end
			visibleSteps[i] = true;
		end
	end
end

-- StandGuardPost.DeleteAllFootSteps()
function StandGuardPost.DeleteAllFootSteps()
	local i;
	for i = 1, 5 do
		NPC.DeleteNPCCharacter(30007, i);
	end
end

-- StandGuardPost.TriggerStep()
function StandGuardPost.TriggerStep(instance)
	local step = NPC.GetNpcCharacterFromIDAndInstance(30007, instance);
	if(step and step:IsValid() == true) then
		local params = {
			asset_file = "model/07effect/v3/xingxing/xingxing.x",
			ismodel = true,
			binding_obj_name = ParaScene.GetPlayer().name,
			start_position = {step:GetPosition()},
			duration_time = 800,
			force_name = nil,
			elapsedtime_callback = function(elapsedTime)
				local step = NPC.GetNpcCharacterFromIDAndInstance(30007, instance);
				if(step and step:IsValid() == true) then
					step:SetScale(1.5 - 1.5 * elapsedTime / 800);
				end
			end,
			begin_callback = nil,
			end_callback = function()
				NPC.DeleteNPCCharacter(30007, instance);
				local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30007);
				memory.steps[instance] = false;
				StandGuardPost.TryEndDialyQuestTip();
			end,
		};
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
	else
		NPC.DeleteNPCCharacter(30007, instance);
	end
end

function StandGuardPost.HasUntouchedFootSteps()
	local npc_id = 30007;
	local i;
	for i = 1, 5 do
		-- the step is not touched before
		local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(npc_id, i);
		if(npcChar and npcChar:IsValid() == true) then
			return true;
		end
	end
	return false;
end

function StandGuardPost.IsFootStepVisible(index)
	local npc_id = 30007;
	local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(npc_id, index);
	if(npcChar and npcChar:IsValid() == true) then
		return true;
	end
	return false;
end

-- StandGuardPost.TryEndDialyQuest()
function StandGuardPost.TryEndDialyQuestTip()
	--local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30007);
	--local i;
	--for i = 1, 5 do
		--if(memory.steps[instance] == true) then
			--return;
		--end
	--end
	
	if(StandGuardPost.HasUntouchedFootSteps()) then
		return;
	end
	
	-- all foot steps are invisible(picked)
	local Scene = MyCompany.Aries.Scene;
	Scene.ShowRegionLabel("巡逻任务完成", "240 226 43");
end