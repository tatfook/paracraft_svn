--[[
Title: combat system message handler server for Aries App
Author(s): WangTian
Date: 2009/4/7
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/msg_handler_server.lua");
------------------------------------------------------------
]]
-- create class
local Msg_Handler_server = commonlib.gettable("MyCompany.Aries.Combat_Server.Msg_Handler_server");

-- mob server object
local Mob = commonlib.gettable("MyCompany.Aries.Combat_Server.Mob");
-- player server object
local Player = commonlib.gettable("MyCompany.Aries.Combat_Server.Player");
-- ai module server
local AI_Module = commonlib.gettable("MyCompany.Aries.Combat_Server.AI_Module");
-- arena server
local Arena = commonlib.gettable("MyCompany.Aries.Combat_Server.Arena");
-- combat server
local combat_server = commonlib.gettable("MyCompany.Aries.Combat_Server.combat_server");

local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber
local string_find = string.find;
local string_match = string.match;

-- main message proceedure
function Msg_Handler_server.MsgProc(nid, msg)
	if(not nid or not msg) then
		log("error: nil nid or nil message got in Msg_Handler_server.MsgProc\n")
		return;
	end

	nid = tonumber(nid) or nid;

--	if(nid == 2000019642528 or nid == "2000019642528" or nid == 46650264 or nid == "46650264") then
--		-- record the illegal user traffic
--		combat_server.AppendPostLog({
--			action = "SpecialUserCombatTraffic", 
--			nid = nid,
--			msg = msg,
--		});
--	end
	

	-- NOTE: any message from the user should be a kind of heartbeat
	Arena.OnReponse_HeartBeat(nid);

	local message = string_match(msg, "^%[Aries%]%[combat_to_server%](.+)$");
	if(message) then
		
		--message = ParaMisc.SimpleDecode(message);

		-- parse the message
		local key, value = string_match(message, "^([^:]*):(.*)$");
		if(key and value) then
			if(key == "DumpArenaData") then
				local arena_id = string_match(value, "^(%d+)$");
				if(arena_id) then
					arena_id = tonumber(arena_id);
					local arena = Arena.GetArenaByID(arena_id);
					if(arena) then
						arena:Dump();
					end
				end
			elseif(key == "IWannaLootTreasureBox") then
				local arena_id = tonumber(value);
				-- player wanna loot treasure box
				Arena.OnReponse_IWannaLootTreasureBox(nid, arena_id);
				
			elseif(key == "ShallIEnterCombat") then
				-- enter combat handler
				local arena_id, side, petlevel, current_hp, max_hp, phase, deck_gsid, followpet_guid, itemset_id, loot_scale, leadernid, isoverweight, is_follow_pet_joincombat, dragon_totem_str, deck_cards, equip_cards, deck_cards_rune, deck_cards_pet, equipped_items_all, equipped_gems_all = 
					string.match(value, "^([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,%[]+)%[([^%]]*)%]%[([^%]]*)%]%[([^%]]*)%]%[([^%]]*)%]%[([^%]]*)%]%[([^%]]*)%]%[([^%]]*)%]$");
				if(arena_id and side and petlevel and current_hp and max_hp and phase and deck_gsid and followpet_guid and itemset_id and loot_scale and deck_cards and equip_cards and deck_cards_rune and deck_cards_pet and equipped_items_all and equipped_gems_all) then
					arena_id = tonumber(arena_id);
					petlevel = tonumber(petlevel);
					current_hp = tonumber(current_hp);
					max_hp = tonumber(max_hp);
					deck_gsid = tonumber(deck_gsid);
					followpet_guid = tonumber(followpet_guid);
					itemset_id = tonumber(itemset_id);
					loot_scale = tonumber(loot_scale);
					leadernid = tonumber(leadernid);
					if(isoverweight == "true") then
						isoverweight = true;
					elseif(isoverweight == "false") then
						isoverweight = false;
					end
					if(is_follow_pet_joincombat == "true") then
						is_follow_pet_joincombat = true;
					elseif(is_follow_pet_joincombat == "false") then
						is_follow_pet_joincombat = false;
					end
					
					Arena.OnReponse_TryEnterCombat(nid, arena_id, side, petlevel, current_hp, max_hp, phase, deck_gsid, followpet_guid, itemset_id, loot_scale, leadernid, isoverweight, is_follow_pet_joincombat, dragon_totem_str, deck_cards, equip_cards, deck_cards_rune, deck_cards_pet, equipped_items_all, equipped_gems_all);
				end
				-- ShallIEnterCombat post log
				combat_server.AppendPostLog({
					action = "ShallIEnterCombat_Monitor", 
					nid = nid,
					value = value,
				});
			elseif(key == "IPickCardOnTarget") then
				-- pick card handler
				local seq, card_key, card_seq, isMob, id = string_match(value, "^([^%+]+)%+([^%+]+)%+([^%+]+)%+([^%+]+)%+([^%+]+)$");
				if(seq and card_key and card_seq and isMob and id) then
					if(isMob == "true") then
						isMob = true;
					elseif(isMob == "false") then
						isMob = false;
					end
					seq = tonumber(seq);
					id = tonumber(id) or id;
					card_seq = tonumber(card_seq);
					Arena.OnReponse_PickCardByPlayer(nid, seq, card_key, card_seq, isMob, id, false); -- false for isAutoAICard
				end
			elseif(key == "PickAICardForMe") then
				-- pick ai card for player
				local seq, bSkipCostAICardPill = string_match(value, "^([^%+]+)%+([^%+]+)$");
				if(seq and bSkipCostAICardPill) then
					seq = tonumber(seq);
					if(bSkipCostAICardPill == "true") then
						bSkipCostAICardPill = true;
					else
						bSkipCostAICardPill = false;
					end
					
					Arena.OnReponse_PickAICardForPlayer(nid, bSkipCostAICardPill, seq);
				end

			elseif(key == "ICancelMyPickedCard") then
				-- pick card handler
				local seq = string_match(value, "^(.*)$");
				if(seq) then
					seq = tonumber(seq);
					Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
				end

			elseif(key == "IPickMyPet") then
				-- pick follow pet handler
				local seq, guid, gsid = string_match(value, "^([^%+]+)%+([^%+]+)%+([^%+]+)$");
				if(seq and guid and gsid) then
					seq = tonumber(seq);
					guid = tonumber(guid);
					gsid = tonumber(gsid);
					Arena.OnReponse_PickPetByPlayer(nid, seq, guid, gsid);
				end

			elseif(key == "CatchPetOnTarget") then
				-- catch follow pet handler
				local seq, mob_id = string_match(value, "^([^%+]+)%+([^%+]+)$");
				if(seq and mob_id) then
					seq = tonumber(seq);
					mob_id = tonumber(mob_id);
					Arena.OnReponse_CatchPetOnTarget(nid, seq, mob_id);
				end

			elseif(key == "IDiscardCard") then
				-- discard card handler
				local seq, card_key, card_seq = string_match(value, "^([^%+]+)%+([^%+]+)%+([^%+]+)$");
				if(seq and card_key and card_seq) then
					seq = tonumber(seq);
					card_seq = tonumber(card_seq);
					Arena.OnReponse_DiscardCardByPlayer(nid, seq, card_key, card_seq);
				end
			elseif(key == "IRestoreDiscardedCard") then
				-- discard card handler
				local seq, card_key, card_seq = string_match(value, "^([^%+]+)%+([^%+]+)%+([^%+]+)$");
				if(seq and card_key and card_seq) then
					seq = tonumber(seq);
					card_seq = tonumber(card_seq);
					Arena.OnReponse_RestoreDiscardedCardByPlayer(nid, seq, card_key, card_seq);
				end
			elseif(key == "IFinishedPlayTurn") then
				local seq = tonumber(value);
				-- player finished play turn
				Arena.OnReponse_FinishPlayTurn(nid, seq);
			elseif(key == "CancelMyFollowPetPickedCard") then
				local seq = tonumber(value);
				-- cancel my follow pet picked card
				Arena.OnReponse_CancelMyFollowPetPickedCard(nid, seq);
				
			elseif(key == "OnFollowPet_FollowMode") then
				local seq = tonumber(value);
				-- switch my follow pet to follow mode
				Arena.OnReponse_OnFollowPet_FollowMode(nid, seq);
			elseif(key == "OnFollowPet_CombatMode") then
				local seq = tonumber(value);
				-- switch my follow pet to combat mode
				Arena.OnReponse_OnFollowPet_CombatMode(nid, seq);
				
			elseif(key == "UnlockArena") then
				-- unlock arena handler
				local arena_id = string_match(value, "^(%d+)$");
				if(arena_id) then
					arena_id = tonumber(arena_id);
					Arena.OnReponse_UnlockArena(nid, arena_id);
				end
				
			elseif(key == "RequestAdditionalLootPlain") then
				-- unlock arena handler
				local arena_id = string_match(value, "^(%d+)$");
				if(arena_id) then
					arena_id = tonumber(arena_id);
					if(arena_id) then
						Arena.OnReponse_RequestAdditionalLoot(nid, arena_id, "Plain");
					end
				end
			elseif(key == "RequestAdditionalLootAdv") then
				-- unlock arena handler
				local arena_id = string_match(value, "^(%d+)$");
				if(arena_id) then
					arena_id = tonumber(arena_id);
					if(arena_id) then
						Arena.OnReponse_RequestAdditionalLoot(nid, arena_id, "Adv");
					end
				end
				
			elseif(key == "IWannaFlee") then
				-- flee from the combat
				Arena.OnReponse_TryFleeCombat(nid);
			elseif(key == "HeartBeat") then
				-- heart beat from the client
				Arena.OnReponse_HeartBeat(nid);
			elseif(key == "MarkDebugPoint") then
				-- mark debug point
				Arena.OnReponse_MarkDebugPoint(nid);
			elseif(key == "CheckMyGearScore") then
				-- check my gear score
				Arena.OnReponse_CheckMyGearScore(nid, tonumber(value) or 0);
			elseif(key == "CheckInternetCafeStatus") then
				-- check internetcafe status
				Arena.OnReponse_CheckInternetCafeStatus(nid);
			end

			--if(key == "DumpArenaData") then
				--local arena_id = string_match(value, "^(%d+)$");
				--if(arena_id) then
					--arena_id = tonumber(arena_id);
					--local arena = Arena.GetArenaByID(arena_id);
					--if(arena) then
						--arena:Dump(key,"after");
					--end
				--end
			--end
		end
	end
end