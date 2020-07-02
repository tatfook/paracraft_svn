--[[
Title: 30011_WishLevel1
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30011_WishLevel1.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishLevel1";
local WishLevel1 = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishLevel1", WishLevel1);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishLevel1.main
function WishLevel1.main()
end

-- refresh quest status
function WishLevel1.RefreshStatus()
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	if(not hasGSItem(50013) and not hasGSItem(50014)) then
		ItemManager.PurchaseItem(50013, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50013_WishLevel1_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel1_Acquire.html");
				end
			end
		end);
	elseif(hasGSItem(50013) and not hasGSItem(50014)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/30011_WishLevel1_status.html",
			"dragon", "", "贪吃的抱抱龙喜欢泡泡浴液", 50013);
		WishLevel1.RegisterHook();
	elseif(hasGSItem(50013) and hasGSItem(50014)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel1_status.html");
		WishLevel1.UnregisterHook();
	end
end

-- on pet feed
-- @param gsid: global store id of the item feeded
function WishLevel1.OnPetFeed(gsid)
	if(gsid == 16003) then
		local bHas, guid = hasGSItem(50013);
		if(bHas == true) then
			local item = ItemManager.GetItemByGUID(guid);
			if(item and item.guid > 0) then
				local clientdata = item.clientdata;
				if(clientdata == "00" or clientdata == "" or clientdata == nil) then
                    ItemManager.SetClientData(guid, "10", function(msg_setclientdata)
                        log("SetClientDataAfterSunbowFlowerFeed with 10 returns:\n")
                        commonlib.echo(msg_setclientdata);
                    end);
				elseif(clientdata == "01") then
                    ItemManager.SetClientData(guid, "11", function(msg_setclientdata)
                        log("SetClientDataAfterSunbowFlowerFeed with 11 returns:\n")
                        commonlib.echo(msg_setclientdata);
                        if(msg_setclientdata.issuccess == true) then
							WishLevel1.DoCompleteQuest();
                        end
                    end);
				elseif(clientdata == "10") then
				elseif(clientdata == "11") then
				end
			end
		end
	end
end

-- on pet bath
-- @param gsid: global store id of the item feeded
function WishLevel1.OnPetBath(gsid)
	if(gsid == 16005) then
		local bHas, guid = hasGSItem(50013);
		if(bHas == true) then
			local item = ItemManager.GetItemByGUID(guid);
			if(item and item.guid > 0) then
				local clientdata = item.clientdata;
				if(clientdata == "00" or clientdata == "" or clientdata == nil) then
                    ItemManager.SetClientData(guid, "01", function(msg_setclientdata)
                        log("SetClientDataAfterSunbowFlowerFeed with 01 returns:\n")
                        commonlib.echo(msg_setclientdata);
                    end);
				elseif(clientdata == "01") then
				elseif(clientdata == "10") then
                    ItemManager.SetClientData(guid, "11", function(msg_setclientdata)
                        log("SetClientDataAfterSunbowFlowerFeed with 11 returns:\n")
                        commonlib.echo(msg_setclientdata);
                        if(msg_setclientdata.issuccess == true) then
							WishLevel1.DoCompleteQuest();
                        end
                    end);
				elseif(clientdata == "11") then
				end
			end
		end
	end
end

-- complete the quest
function WishLevel1.DoCompleteQuest()
	if(hasGSItem(50013)) then
        -- finish the quest
        -- exid 84: DragonQuestGrow_Level1
        ItemManager.ExtendedCost(84, nil, nil, function(msg)end, function(msg)
		    log("+++++++ExtendedCost 84: DragonQuestGrow_Level1 return: +++++++\n")
		    commonlib.echo(msg);
			WishLevel1.RefreshStatus();
			Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel1_Finish.html");
			--50015_WishLevel1_RewardFriendliness
			if(msg.issuccess == true) then
				-- use the item 50015 to increase pet friendliness
                local bHas, guid = hasGSItem(50015);
                if(bHas and guid) then
                    local item = ItemManager.GetItemByGUID(guid);
                    if(item and item.guid > 0) then
                        item:OnClick("left");
                    end
                end
				--WishLevel0.RefreshStatus();
			end
        end);
	end
end

-- register hook into pet name change
function WishLevel1.RegisterHook()
	-- hook into pet feed
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "PetFeed") then
				WishLevel1.OnPetFeed(msg.gsid);
			end
		end, 
		hookName = "WishLevel1_PetFeed", appName = "Aries", wndName = "main"});
	-- hook into pet bath
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "PetBath") then
				WishLevel1.OnPetBath(msg.gsid);
			end
		end, 
		hookName = "WishLevel1_PetBath", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishLevel1.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishLevel1_PetFeed", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishLevel1_PetBath", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end