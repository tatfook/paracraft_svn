--[[
Title: 30011_WishLevel8
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30011_WishLevel8.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishLevel8";
local WishLevel8 = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishLevel8", WishLevel8);

local Quest = commonlib.gettable("MyCompany.Aries.Quest");
local GameObject = commonlib.gettable("MyCompany.Aries.Quest.GameObject");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");

local ItemManager = commonlib.gettable("System.Item.ItemManager");
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishLevel8.main
function WishLevel8.main()
end

--50034_WishLevel8_Acquire
--50035_WishLevel8_Complete
--50036_WishLevel8_RewardFriendliness
--50054_WishLevel8_TalkedWithBlueDragonTotem
--50053_WishLevel8_HeartOfFlyingDragon

-- refresh quest status
function WishLevel8.RefreshStatus()
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	if(not hasGSItem(50034) and not hasGSItem(50035)) then
		ItemManager.PurchaseItem(50034, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50034_WishLevel8_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel8_Acquire.html");
				end
			end
		end);
	elseif(hasGSItem(50034) and not hasGSItem(50035) and not hasGSItem(50054)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/30011_WishLevel8_status.html",
			"dragon", "", "抱抱龙飞向天空", 50034);
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel8_status2.html");
		WishLevel8.RegisterHook();
	elseif(hasGSItem(50034) and not hasGSItem(50035) and hasGSItem(50054)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/30011_WishLevel8_status2.html",
			"dragon", "", "抱抱龙飞向天空", 50034);
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel8_status.html");
		WishLevel8.RegisterHook();
		-- create the hearts if not created
		WishLevel8.CreateHeartNPCs();
	elseif(hasGSItem(50034) and hasGSItem(50035)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel8_status.html");
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel8_status2.html");
		WishLevel8.UnregisterHook();
		-- delete all hearts
		WishLevel8.DeleteHeartNPCs();
	end
end

-- item purchase hook
-- @param gsid: global store id of the purchased item
-- @param count: count of the purchased item
function WishLevel8.OnItemPurchase(gsid, count)
	if(gsid == 50035 and count == 1) then
		WishLevel8.RefreshStatus();
		Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel8_Finish.html");
	end
end

function WishLevel8.OnFireMasterGameClose()
end

-- register hook into 
function WishLevel8.RegisterHook()
	---- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				WishLevel8.OnItemPurchase(msg.gsid, msg.count);
			end
		end, 
		hookName = "WishLevel8_PurchaseQuestComplete", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishLevel8.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishLevel8_PurchaseQuestComplete", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end

-- create hearts if not created
function WishLevel8.CreateHeartNPCs()
	local params = { 
		copies = 10,
		positions = {
					{ 20151.3359375, 20 + 3.4968597888947, 19721.89453125 },
					{ 20065.6640625, 20 + 2.1589970588684, 19784.72265625 },
					{ 20039.83984375, 20 + 1.4999301433563, 19852.48046875 },
					{ 19870.921875, 20 + -2.5440554618835, 19857.109375 },
					{ 19968.15234375, 20 + 1.1995887756348, 19893.517578125 },
					{ 20095.966796875, 20 + 0.21544122695923, 19911.83203125 },
					{ 20194.099609375, 20.27225112915, 19988.755859375 }, --{ 20198.525390625, 25 + 6.1911988258362, 20003.501953125 },
					{ 20034.4140625, 20 + -4.905535697937, 20049.630859375 },
					{ 19913.83984375, 20 + 3.2279262542725, 20016.591796875 },
					{ 19891.583984375, 20 + 8.8433294296265, 20119.94140625 },
					
					--{ 19959.703125, 10.7912380695343, 20034.50390625 },
					--{ 19959.703125, 10.7912380695343, 20044.50390625 },
					--{ 19959.703125, 10.7912380695343, 20054.50390625 },
					--{ 19959.703125, 10.7912380695343, 20064.50390625 },
					--{ 19959.703125, 10.7912380695343, 20074.50390625 },
					--{ 19959.703125, 10.7912380695343, 20084.50390625 },
					--{ 19959.703125, 10.7912380695343, 20094.50390625 },
					--{ 19959.703125, 10.7912380695343, 20104.50390625 },
					--{ 19959.703125, 10.7912380695343, 20114.50390625 },
					--{ 19959.703125, 10.7912380695343, 20124.50390625 },
					},
		name = "飞龙之心",
		position = { 20047.056640625, 0.00011985249147983, 19927.291015625 },
		facing = 0.91666221618652,
		scaling = 1.5,
		talkdist = -1,
		isalwaysshowheadontext = false,
		assetfile_char = "character/v5/06quest/HeartOfFlyingDragon/HeartOfFlyingDragon.x",
		main_script = "script/apps/Aries/NPCs/Dragon/30112_HeartOfFlyingDragon.lua",
		main_function = "MyCompany.Aries.Quest.NPCs.HeartOfFlyingDragon.main();",
		AI_script = "script/apps/Aries/NPCs/Dragon/30112_HeartOfFlyingDragon_AI.lua",
		On_FrameMove = ";MyCompany.Aries.Quest.NPCAI.HeartOfFlyingDragon_AI.On_FrameMove();",
	};
	local npc_id = 30112;
	NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");
	MyCompany.Aries.Quest.NPCAIMemory.ClearMemory(30112);
	local copies = 0;
	local bHas, guid = hasGSItem(50053);
	if(bHas) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			copies = item.copies;
		end
	end
	-- 50034_WishLevel8_Acquire
	local bHas, guid = hasGSItem(50034);
	if(bHas) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			local triggerCount = 0;
			if(not string.match(item.clientdata, "^({.*})$")) then
				item.clientdata = "{}";
			end
			local heartTrigger = commonlib.LoadTableFromString(item.clientdata) or {};
			if(heartTrigger) then
				local i;
				for i = 1, 10 do
					if(heartTrigger[i] == true) then
						triggerCount = triggerCount + 1;
					end
				end
			end
			if(triggerCount == copies) then
				-- destroy first then create
				WishLevel8.DeleteHeartNPCs();
				local i;
				for i = 1, 10 do
					if(heartTrigger[i] ~= true) then
						-- the heart is not fetched before
						local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(npc_id, i);
						if(not npcChar or npcChar:IsValid() == false) then
							-- heart npc character is not valid
							local params_this = commonlib.deepcopy(params);
							params_this.position = params_this.positions[i];
							params_this.positions = nil;
							params_this.npc_id = npc_id;
							params_this.instance = i;
							NPC.CreateNPCCharacter(npc_id, params_this);
						end
					end
				end
			else
				-- destroy first then create
				WishLevel8.DeleteHeartNPCs();
				local i;
				for i = copies + 1, 10 do
					-- the heart is not fetched before
					local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(npc_id, i);
					if(not npcChar or npcChar:IsValid() == false) then
						-- heart npc character is not valid
						local params_this = commonlib.deepcopy(params);
						params_this.position = params_this.positions[i];
						params_this.positions = nil;
						params_this.npc_id = npc_id;
						params_this.instance = i;
						NPC.CreateNPCCharacter(npc_id, params_this);
					end
				end
			end
		end
	end
end

-- delete hearts
function WishLevel8.DeleteHeartNPCs()
	local i;
	for i = 1, 10 do
		NPC.DeleteNPCCharacter(30112, i);
	end
end

-- HeartOfFlyingDragon
function WishLevel8.TriggerHeart(instance)
	local params = {
		asset_file = "character/v5/09effect/FlyingHeart/FlyingHeart.x",
		--asset_file = "model/07effect/v3/xingxing/xingxing.x",
		--ismodel = true,
		binding_obj_name = ParaScene.GetPlayer().name,
		start_position = {NPC.GetNpcCharacterFromIDAndInstance(30112, instance):GetPosition()},
		duration_time = 800,
		force_name = nil,
		elapsedtime_callback = function(elapsedTime)
			local heart = NPC.GetNpcCharacterFromIDAndInstance(30112, instance);
			if(heart and heart:IsValid() == true) then
				heart:SetScale(1.5 - 1.5 * elapsedTime / 800);
			end
		end,
		begin_callback = nil,
		end_callback = function()
			NPC.DeleteNPCCharacter(30112, instance);
		end,
	};
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.CreateEffect(params);
	
	
    ItemManager.PurchaseItem(50053, 1, function(msg) end, function(msg)
        if(msg) then
	        log("+++++++ Purchase 50053_WishLevel8_HeartOfFlyingDragon return: +++++++\n")
	        commonlib.echo(msg);
	        if(msg.issuccess == true) then
				-- 50034_WishLevel8_Acquire
				local bHas, guid = hasGSItem(50034);
				if(bHas) then
					local item = ItemManager.GetItemByGUID(guid);
					if(item and item.guid > 0) then
						local function GenerateTriggerStr()
							local i;
							local heartTrigger = {true, true, true, true, true, true, true, true, true, true}; -- default to true
							for i = 1, 10 do
								if(i == instance) then
									heartTrigger[instance] = true;
								else
									local heart = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30112, i);
									if(heart and heart:IsValid() == true) then
										heartTrigger[i] = false;
									end
								end
							end
							return commonlib.serialize_compact(heartTrigger);
						end
						local heartTriggerStr = GenerateTriggerStr()
						ItemManager.SetClientData(item.guid, heartTriggerStr, function(msg)
							log("setclientdata to 50034_WishLevel8_Acquire with "..tostring(heartTriggerStr).." returns:\n")
							commonlib.echo(msg);
						end);
					end
				end
	        end
        end
    end);
end