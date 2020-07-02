--[[
Title: FleaChick
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FollowPets/30202_FleaChick.lua
------------------------------------------------------------
]]

-- create class
local libName = "FleaChick";
local FleaChick = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.FleaChick", FleaChick);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local is_inited;
-- FleaChick.main
function FleaChick.main()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30202);
	
	if(not is_inited and not hasGSItem(50185)) then
		is_inited = true;
		System.Item.ItemManager.PurchaseItem(50185, 1, function(msg)
			if(msg) then
				log("+++++++Purchase 50185_FleaChick_LastFeedDate return: +++++++\n")
				commonlib.echo(msg);
			end
		end, nil, nil, "none");
	end
end

-- FleaChick.On_Timer
function FleaChick.On_Timer()
end

-- 10107_FollowPetXJBB
-- 50048_FleaChick_Feed
-- 17009_BeehiveWorm

-- quest speech
-- @return: false if speak the headon speech
--			true if continue with the next dialog answer condition
function FleaChick.PreDialog(npc_id, instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30202);
	local chick = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30202, instance);
	if(chick and chick:IsValid() == true) then
		local feed_count = 0;
		local lastFeedDate;
		-- 50185_FleaChick_LastFeedDate
		local bHas, guid = hasGSItem(50185);
		if(bHas == true) then
			local item = ItemManager.GetItemByGUID(guid);
			if(item and item.guid > 0) then
				lastFeedDate = item.clientdata;
			end
		end
		-- 50048_FleaChick_Feed
		local bHas, guid = hasGSItem(50048);
		if(bHas == true) then
			local item = ItemManager.GetItemByGUID(guid);
			if(item and item.guid > 0) then
				feed_count = item.copies;
			end
		end
		memory.feed_count = feed_count;
		
		local today = MyCompany.Aries.Scene.GetServerDate();
		if(lastFeedDate ~= today) then
			-- 17009_BeehiveWorm
			if(hasGSItem(17009)) then
				-- 10107_FollowPetXJBB
				if(hasGSItem(10107)) then
					if(feed_count < 2) then
						memory.dialog_state = 6;
					else
						memory.this_random = memory.this_random or math.random(0, 100);
						if(memory.this_random < 80) then
							memory.dialog_state = 7;
						else
							memory.dialog_state = 8;
						end
					end
					--local r = math.random(0, 100);
					--if(r < 30) then
						--headon_speech.Speek(chick.name, headon_speech.GetBoldTextMCML("哎，我今天心情不好，啥也给不了你，明天再来喂我吧。"), 3, true);
						--return false;
					--end
				else
					if(feed_count < 2) then
						memory.dialog_state = 4;
					else
						memory.dialog_state = 5;
					end
				end
			else
				memory.dialog_state = 3;
				--headon_speech.Speek(chick.name, headon_speech.GetBoldTextMCML("你没有虫子呢，我不跟你玩了。去蜂窝树那摇点虫子下来吧。"), 3, true);
				--return false;
			end
		else
			-- 10107_FollowPetXJBB
			if(hasGSItem(10107)) then
				memory.dialog_state = 2;
			else
				memory.dialog_state = 1;
			end
			--headon_speech.Speek(chick.name, headon_speech.GetBoldTextMCML("我今天已经吃饱了，你明天再来喂我吧。"), 3, true);
			--return false;
		end
	end
	return true;
end