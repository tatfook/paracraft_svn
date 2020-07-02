--[[
Title: 30011_SpecialChristmasGift
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/091218/SpecialChristmasGift.lua
------------------------------------------------------------
]]

-- create class
local libName = "SpecialChristmasGift";
local SpecialChristmasGift = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.SpecialChristmasGift", SpecialChristmasGift);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- SpecialChristmasGift.main
function SpecialChristmasGift.main()
	SpecialChristmasGift.RefreshStatus()
	
	-- hook into OnWorldClosing
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnWorldLoad") then
				-- refresh status
				SpecialChristmasGift.RefreshStatus()
			end
		end, 
		hookName = "WorldClosing_SpecialChristmasGift", appName = "Aries", wndName = "main"});
end

function SpecialChristmasGift.On_Timer()
end

function SpecialChristmasGift.CanAcquireQuest()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		return false;
	end
	if(not hasGSItem(50202) and not hasGSItem(50203)) then
		return true;
	end
	return false
end

function SpecialChristmasGift.AcquireQuest()
	---- check if dragon fetched from sophie
	--if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		--_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		--return;
	--end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(not hasGSItem(50202) and not hasGSItem(50203)) then
		ItemManager.PurchaseItem(50202, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50202_SpecialChristmasGift_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/091218/SpecialChristmasGift_Acquire.html");
				end
			end
		end);
	end
end

-- 50202_SpecialChristmasGift_Acquire
-- 50203_SpecialChristmasGift_Complete
-- 50204_SpecialChristmasGift_RewardFriendliness

-- refresh quest status
function SpecialChristmasGift.RefreshStatus()
	---- check if dragon fetched from sophie
	--if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		--_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		--return;
	--end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(hasGSItem(50202) and not hasGSItem(50203)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/091218/SpecialChristmasGift_status.html",
			"dragon", "", "抱抱龙送的圣诞节礼物", 50202);
		SpecialChristmasGift.RegisterHook();
		
		-- create game object if not exist
		local gameobj = GameObject.GetGameObjectCharacterFromIDAndInstance(40164);
		if(gameobj and gameobj:IsValid() == true) then
		else
			local params = { 
				name = "糖果背包",
				position = { 20001.744140625, 2.1027548885345, 20065.123046875 },
				facing = 0.8,
				scaling = 2,
				scaling_model = 1,
				isalwaysshowheadontext = false,
				assetfile_char = "character/common/dummy/cube_size/cube_size.x",
				assetfile_model = "model/06props/v5/03quest/GiftCandy/GiftCandy.x",
				gameobj_type = "FreeItem",
				isdeleteafterpick = true,
				gsid = 1106,
				onpick_msg = [[<div style="margin-top:10px;">我是你的抱抱龙特意为你准备的糖果背包，快把我背在身上看看吧，你的抱抱龙一定很开心的。</div>]],
			};
			GameObject.CreateGameObjectCharacter(40164, params);
		end
		
	elseif(hasGSItem(50202) and hasGSItem(50203)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/091218/SpecialChristmasGift_status.html");
		SpecialChristmasGift.UnregisterHook();
		
		-- destroy game object if exist
		local gameobj = GameObject.GetGameObjectCharacterFromIDAndInstance(40164);
		if(gameobj and gameobj:IsValid() == true) then
			GameObject.DeleteGameObjectCharacter(40164);
		end
	end
end

-- SpecialChristmasGift.OnObtainSpecialChristmasGift
function SpecialChristmasGift.OnObtainSpecialChristmasGift()
    -- finish the quest
    -- exid 147: DragonQuest_SpecialChristmasGift 
    ItemManager.ExtendedCost(147, nil, nil, function(msg)end, function(msg)
	    log("+++++++ExtendedCost 147: DragonQuest_SpecialChristmasGift return: +++++++\n")
	    commonlib.echo(msg);
	    SpecialChristmasGift.RefreshStatus();
		MyCompany.Aries.Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/091218/SpecialChristmasGift_Finish.html");
		-- 50204_SpecialChristmasGift_RewardFriendliness
		if(msg.issuccess == true) then
			-- use the item 50204 to increase pet friendliness
            local bHas, guid = hasGSItem(50204);
            if(bHas and guid) then
                local item = ItemManager.GetItemByGUID(guid);
                if(item and item.guid > 0) then
                    item:OnClick("left");
                end
            end
		end
    end);
end

-- register hook into pet name change
function SpecialChristmasGift.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				if(msg.gsid == 1106) then
					SpecialChristmasGift.OnObtainSpecialChristmasGift();
				end
			end
		end, 
		hookName = "SpecialChristmasGift_OnObtain", appName = "Aries", wndName = "main"});
end

-- unregister hook
function SpecialChristmasGift.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "SpecialChristmasGift_OnObtain", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end