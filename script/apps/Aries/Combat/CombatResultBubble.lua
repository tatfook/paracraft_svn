--[[
Title: combat system Entry for Aries App
Author(s): WangTian
Date: 2009/4/7
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/CombatResultBubble.lua");
------------------------------------------------------------
]]
local tostring = tostring
local tonumber = tonumber
local string_match = string.match;
local string_find = string.find;
local table_insert = table.insert;
local math_random = math.random;
local System = System;
local ParaScene_GetObject = ParaScene.GetObject
local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");
local Desktop = commonlib.gettable("MyCompany.Aries.Desktop");
local LOG = LOG;

NPL.load("(gl)script/ide/TooltipHelper.lua");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
local ItemManager = commonlib.gettable("System.Item.ItemManager");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");

NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");

local pvp_points_gsid_list = {
	["1v1"] = {},
	["2v2"] = {},
};
local pvp_point_gsid_inited = false;

local function GetPVPPointList()
	if(not pvp_point_gsid_inited) then
		pvp_point_gsid_inited = true;
		local k,v;
		for k,v in pairs(pvp_points_gsid_list) do
			Combat.GetPVPPointList(k,v);	
		end
	end
	--local type_table = pvp_points_gsid_list[type];
	--if(not type_table) then
		--pvp_points_gsid_list[type] = {};
		--Combat.GetPVPPointList(type,pvp_points_gsid_list[type]);
	--end
end

local function IsPvpPoint_gsid(gsid,type,result)
	local k,v;
	for k,v in pairs(pvp_points_gsid_list) do
		local kk,vv;
		for kk,vv in pairs(v) do
			if(vv[gsid]) then
				local meetCondition = true;
				if(type and type ~= k) then
					meetCondition = false;
				end
				if(result and result ~= kk) then
					meetCondition = false;
				end
				return meetCondition;
			end
		end
	end
	return false;
end

local function IsCardOrRune_gsid(gsid)
	if(not gsid) then
		return false;
	end
	if(gsid >= 22101 and gsid <= 22999) then
		return true;
	elseif(gsid >= 41101 and gsid <= 41999) then
		return true;
	elseif(gsid >= 42101 and gsid <= 42999) then
		return true;
	elseif(gsid >= 43101 and gsid <= 43999) then
		return true;
	elseif(gsid >= 44101 and gsid <= 44999) then
		return true;
	elseif(gsid >= 23101 and gsid <= 23999) then
		return true;
	end
	return false;
end

-- depracated
function MsgHandler.OnCombatResultBubble_pvp(value)
	local nid, gained_exp, original_exp, exp_scale, gained_loot, pet_exp, isWinner, loot_scale = string_match(value, "^([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)$");
	if(nid and gained_exp and original_exp and exp_scale and gained_loot and pet_exp and isWinner and loot_scale) then
		nid = tonumber(nid);
		gained_exp = tonumber(gained_exp);
		original_exp = tonumber(original_exp);
		exp_scale = tonumber(exp_scale);
		pet_exp = tonumber(pet_exp);
		loot_scale = tonumber(loot_scale);
		-- only show the result for player himself
		if(nid == ProfileManager.GetNID()) then
			if(isWinner == "true") then
				isWinner = true;
			elseif(isWinner == "false") then
				isWinner = false;
			elseif(isWinner == "draw") then
				isWinner = "draw";
			end
			MsgHandler.OnCombatResultBubble(nid.."~"..gained_exp.."~"..original_exp.."~"..exp_scale.."~0~"..gained_loot.."~"..pet_exp.."~"..loot_scale, true, isWinner);
		end
	end
end


function MsgHandler.OnCombatResultBubble2(nid, gained_exp, original_exp, exp_scale, pet_exp, gained_joybean, isWinner, loots, loot_scale)
	GetPVPPointList();

	if(nid and gained_exp and original_exp and exp_scale and pet_exp and gained_joybean and loots and loot_scale) then
		
		local isVIP = false;
		local text_color = "2d4dd6";
        --if(exp_scale > 1) then
			--isVIP = true;
			--text_color = "d62d2d";
        --end
		
		local isVIP = false;
		local exp_text_color = "2d4dd6";
        if(exp_scale > 1) then
			isVIP = true;
			exp_text_color = "d62d2d";
        end

		if(System.options.version == "teen") then
			text_color = "fee11c";
			exp_text_color = "fee11c";
		end
		
		local player = ParaScene_GetObject(tostring(nid));
		if(player:IsValid() ~= true) then
			-- player is not valid
			return;
		end
		local dist = player:DistanceToPlayerSq();
		if(dist > 1600) then
			-- player is too far away
			return;
		end

		local item_lines = 0;

		local bubble_mcml = "";
		
		if(isWinner == true or isWinner == false or isWinner == "draw") then
			local word = "";
			local padding_left = 40;
			if(isWinner == true) then
				word = "恭喜你取得了胜利！";
				padding_left = 30;
			elseif(isWinner == false) then
				word = "你被打败了，再接再厉吧！";
				padding_left = 50;
			elseif(isWinner == "draw") then
				word = "你们打成平局，再接再厉！";
				padding_left = 50;
			end
			local single_block = string.format([[
				<div style="color:#f53b0e;height:24px;" >
					<div style="padding-left:-]]..padding_left..[[px;" >%s</div>
				</div>]], word);
			bubble_mcml = bubble_mcml..single_block;
			item_lines = item_lines + 1;

			if(nid == ProfileManager.GetNID()) then
				-- append to channel
				ChatChannel.AppendChat({
					ChannelIndex = ChatChannel.EnumChannels.ItemObtain, 
					fromname = "", 
					fromschool = Combat.GetSchool(), 
					fromisvip = false, 
					words = word,
					is_direct_mcml = true,
					bHideSubject = true,
					bHideTooltip = true,
					bHideColon = true,
				});
			end
			
			if(nid == ProfileManager.GetNID()) then
				if(loot_scale == 0.5) then
					BroadcastHelper.PushLabel({id="anti_indulgence_tip", label = "在线3小时后，战斗经验、宠物经验、战利品减半", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				elseif(loot_scale == 0) then
					BroadcastHelper.PushLabel({id="anti_indulgence_tip", label = "在线5小时后不再获得战斗经验、宠物经验、战利品", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				end
			end
		end

		--local loots = {};
		--local gsid;
		--for gsid in string.gmatch(gained_loot, "[^#]+") do
			--gsid = tonumber(gsid);
			--if(gsid > 0) then
				--loots[gsid] = loots[gsid] or 0;
				--loots[gsid] = loots[gsid] + 1;
			--elseif(gsid < 0) then
				--gsid = -gsid;
				--loots[gsid] = loots[gsid] or 0;
				--loots[gsid] = loots[gsid] - 1;
			--end
		--end

		local drops;
		
		local gsid, count;
		for gsid, count in pairs(loots) do
			
			drops = drops or {};
			table.insert(drops, gsid);
			
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
			if(gsItem) then
				if(gsItem and gsItem.template.stats and gsItem.template.stats[12] ~= 0) then
					
					local WHITE = "ffffff";
					local BLUE = "0099ff";
					local GREEN = "00cc33";
					local PURPLE = "c648e1";
					local ORANGE = "ff9a00";
					local this_item_text_color = WHITE;
					local quality = gsItem.template.stats[221];
					if(quality == 0) then
						this_item_text_color = WHITE;
					elseif(quality == 1) then
						this_item_text_color = GREEN;
					elseif(quality == 2) then
						this_item_text_color = BLUE;
					elseif(quality == 3) then
						this_item_text_color = PURPLE;
					elseif(quality == 4) then
						this_item_text_color = ORANGE;
					end

					local this_icon = gsItem.icon;
					if(IsCardOrRune_gsid(gsid)) then
						this_icon = gsItem.descfile;
					end

					local single_block = string.format([[
						<div style="color:#%s;height:24px;" >
							<img src="%s" style="position:relative;margin-left:-30px;width:24px;height:24px"/>
							%s
						</div>]], this_item_text_color, this_icon, if_else(count > 0, gsItem.template.name.." x "..count, gsItem.template.name.."   "..count));
					bubble_mcml = bubble_mcml..single_block;
					item_lines = item_lines + 1;
					
					if(isPvP == true and nid == ProfileManager.GetNID()) then
						-- append to channel
						Dock.ShowNotificationInChannel(gsid, count);
					end
				elseif((gsid >= 20046 and gsid <= 20049) or IsPvpPoint_gsid(gsid) or gsid == 20091) then
					-- 20046_RedMushroomPvP_1v1_PositiveRankingPoints
					-- 20047_RedMushroomPvP_1v1_NegativeRankingPoints
					-- 20048_RedMushroomPvP_2v2_PositiveRankingPoints
					-- 20049_RedMushroomPvP_2v2_NegativeRankingPoints
					local word = "";
					local channel_word = "";
					if(gsid == 20046) then
						word = "1V1赛场积分 +"..count;
						channel_word = "你的[1V1赛场积分] +"..count;
					elseif(gsid == 20047) then
						word = "1V1赛场积分 -"..count;
						channel_word = "你的[1V1赛场积分] -"..count;
					elseif(gsid == 20048) then
						word = "2V2赛场积分 +"..count;
						channel_word = "你的[2V2赛场积分] +"..count;
					elseif(gsid == 20049) then
						word = "2V2赛场积分 -"..count;
						channel_word = "你的[2V2赛场积分] -"..count;
					end
					if(System.options.version == "kids") then
						if(IsPvpPoint_gsid(gsid,"1v1","win")) then
							word = "1V1赛场积分 +"..count;
							channel_word = "你的[1V1赛场积分] +"..count;
						elseif(IsPvpPoint_gsid(gsid,"1v1","lose")) then
							word = "1V1赛场积分 -"..count;
							channel_word = "你的[1V1赛场积分] -"..count;
						elseif(IsPvpPoint_gsid(gsid,"2v2","win")) then
							word = "2V2赛场积分 +"..count;
							channel_word = "你的[2V2赛场积分] +"..count;
						elseif(IsPvpPoint_gsid(gsid,"2v2","lose")) then
							word = "2V2赛场积分 -"..count;
							channel_word = "你的[2V2赛场积分] -"..count;
						elseif(gsid == 20091) then
							word = "3V3赛场积分 +"..count;
							channel_word = "你的[3V3赛场积分] +"..count;
						end
					end
					local single_block = string.format([[
						<div style="color:#%s;height:24px;" >
							%s
						</div>]], text_color, word);
					bubble_mcml = bubble_mcml..single_block;
					item_lines = item_lines + 1;

					if(nid == ProfileManager.GetNID()) then
						-- append to channel
						ChatChannel.AppendChat({
							ChannelIndex = ChatChannel.EnumChannels.ItemObtain, 
							fromname = "", 
							fromschool = Combat.GetSchool(), 
							fromisvip = false, 
							words = channel_word,
							is_direct_mcml = true,
							bHideSubject = true,
							bHideTooltip = true,
							bHideColon = true,
						});
					end
				end
			end
		end

		if(drops) then
			-- show item drop
			Dock.ShowItemDropSound(drops);
		end

        local exp_str = original_exp;
        if(exp_scale > 1) then
            exp_str = original_exp.." x "..exp_scale;
        end
		local single_block = string.format([[<div style="color:#%s;height:24px;">EXP: %s</div>]], 
			exp_text_color, exp_str);
		bubble_mcml = bubble_mcml..single_block;
		item_lines = item_lines + 1;

		local is_teen = System.options.version
		if(is_teen == "teen") then
			if(gained_exp > 0 and nid == ProfileManager.GetNID()) then
				Dock.OnExpNotification(gained_exp)
			end
		end
		
		if(pet_exp and pet_exp > 0) then
			local single_block
			if(is_teen == "teen") then
				single_block = string.format([[<div style="color:#%s;height:24px;">宠物训练点: %s</div>]], 
					exp_text_color, pet_exp);
			else
				single_block = string.format([[<div style="color:#%s;height:24px;">战宠EXP: %s</div>]], 
					exp_text_color, pet_exp);
			end
			bubble_mcml = bubble_mcml..single_block;
			item_lines = item_lines + 1;
			
			if(is_teen == "teen") then
				if(nid == ProfileManager.GetNID()) then
					-- NOTE: 取消战宠经验
					Dock.OnFollowPetExpNotification(pet_exp);
				end
			end
		end

		if(isWinner == nil and gained_joybean and gained_joybean > 0) then
			local single_block = string.format([[<div style="color:#%s;height:24px;">%s: %s</div>]], 
				text_color, System.options.haqi_GameCurrency, gained_joybean);
			bubble_mcml = bubble_mcml..single_block;
			item_lines = item_lines + 1;
		end

		if(isWinner == nil) then
			if(nid == ProfileManager.GetNID()) then
				if(loot_scale == 0.5) then
					BroadcastHelper.PushLabel({id="anti_indulgence_tip", label = "在线3小时后，战斗经验、宠物经验、战利品减半", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				elseif(loot_scale == 0) then
					BroadcastHelper.PushLabel({id="anti_indulgence_tip", label = "在线5小时后不再获得战斗经验、宠物经验、战利品", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				end
			end
		end

		if(item_lines == 0) then
			-- nothing to show
			return;
		end
		local margin_top = -2 - item_lines * 24;

		bubble_mcml = [[<div style="margin-left:200px;width:300px;font-size:14px;"><div style="width:1000px;font-weight:bold;text-shadow:true;shadow-quality:8;">]]..bubble_mcml..[[</div></div>]];

		local anim_type = "plain";
		local sCtrlName = headon_speech.Speek(tostring(nid), bubble_mcml, 5, true, true, nil, -3);
		if(sCtrlName) then
			if(anim_type == "plain") then
				UIAnimManager.PlayCustomAnimation(5000, function(elapsedTime)
					local parent = ParaUI.GetUIObject(sCtrlName);
					if(parent:IsValid()) then
						--parent.scalingx = 1;
						--parent.scalingy = 1;
						parent.translationy = math.floor(0.5 - elapsedTime * 10 / 1000); -- 10 pixels per seconds
						parent:ApplyAnim();
					end
				end);
			--elseif(anim_type == "critical") then
				--UIAnimManager.PlayCustomAnimation(2500, function(elapsedTime)
					--local parent = ParaUI.GetUIObject(sCtrlName);
					--if(parent:IsValid()) then
						--parent.translationy = 0 - elapsedTime * 10 / 1000;
						--if(isCritical and elapsedTime < 200) then
							--parent.scalingx = 2.4 - 0.6 * math.abs(elapsedTime - 100) / 100;
							--parent.scalingy = 2.4 - 0.6 * math.abs(elapsedTime - 100) / 100;
						--else
							--parent.scalingx = 1.8;
							--parent.scalingy = 1.8;
						--end
						--parent:ApplyAnim();
					--end
				--end);
			end
		end
	end
end

function MsgHandler.OnCombatResultBubble(value, isPvP, isWinner)
	
	local nid, gained_exp, original_exp, exp_scale, gained_joybean, gained_loot, pet_exp, loot_scale = 
		string_match(value, "^([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)$");
	if(nid and gained_exp and original_exp and exp_scale and gained_joybean and gained_loot and pet_exp and loot_scale) then
		
		nid = tonumber(nid);
		gained_exp = tonumber(gained_exp);
		original_exp = tonumber(original_exp);
		exp_scale = tonumber(exp_scale);
		gained_joybean = tonumber(gained_joybean);
		pet_exp = tonumber(pet_exp);
		loot_scale = tonumber(loot_scale);
		
		if(isPvP ~= true and nid == ProfileManager.GetNID()) then
			-- user gain exp post log
			paraworld.PostLog({action = "user_gain_exp", exp_pt = gained_exp, reason = "DefeatMob"}, "user_gain_exp_log", function(msg)
			end);
		end
		
		local isVIP = false;
		local text_color = "2d4dd6";
        --if(exp_scale > 1) then
			--isVIP = true;
			--text_color = "d62d2d";
        --end
		
		local isVIP = false;
		local exp_text_color = "2d4dd6";
        if(exp_scale > 1) then
			isVIP = true;
			exp_text_color = "d62d2d";
        end

		if(System.options.version == "teen") then
			text_color = "fee11c";
			exp_text_color = "fee11c";
		end
		
		local player = ParaScene_GetObject(tostring(nid));
		if(player:IsValid() ~= true) then
			-- player is not valid
			return;
		end
		local dist = player:DistanceToPlayerSq();
		if(dist > 1600) then
			-- player is too far away
			return;
		end

		local item_lines = 0;

		local bubble_mcml = "";
		
		if(isPvP == true and (isWinner == true or isWinner == false or isWinner == "draw")) then
			local word = "";
			local padding_left = 40;
			if(isWinner == true) then
				word = "恭喜你取得了胜利！";
				padding_left = 30;
			elseif(isWinner == false) then
				word = "你被打败了，再接再厉吧！";
				padding_left = 50;
			elseif(isWinner == "draw") then
				word = "你们打成平局，再接再厉！";
				padding_left = 50;
			end
			local single_block = string.format([[
				<div style="color:#f53b0e;height:24px;" >
					<div style="padding-left:-]]..padding_left..[[px;" >%s</div>
				</div>]], word);
			bubble_mcml = bubble_mcml..single_block;
			item_lines = item_lines + 1;

			if(nid == ProfileManager.GetNID()) then
				-- append to channel
				ChatChannel.AppendChat({
					ChannelIndex = ChatChannel.EnumChannels.ItemObtain, 
					fromname = "", 
					fromschool = Combat.GetSchool(), 
					fromisvip = false, 
					words = word,
					is_direct_mcml = true,
					bHideSubject = true,
					bHideTooltip = true,
					bHideColon = true,
				});
			end
			
			if(nid == ProfileManager.GetNID()) then
				if(loot_scale == 0.5) then
					BroadcastHelper.PushLabel({id="anti_indulgence_tip", label = "在线3小时后，战斗经验、宠物经验、战利品减半", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				elseif(loot_scale == 0) then
					BroadcastHelper.PushLabel({id="anti_indulgence_tip", label = "在线5小时后不再获得战斗经验、宠物经验、战利品", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				end
			end
		end

		local loots = {};
		local gsid;
		for gsid in string.gmatch(gained_loot, "[^#]+") do
			gsid = tonumber(gsid);
			if(gsid > 0) then
				loots[gsid] = loots[gsid] or 0;
				loots[gsid] = loots[gsid] + 1;
			elseif(gsid < 0) then
				gsid = -gsid;
				loots[gsid] = loots[gsid] or 0;
				loots[gsid] = loots[gsid] - 1;
			end
		end

		local drops;
		
		local gsid, count;
		for gsid, count in pairs(loots) do
			
			drops = drops or {};
			table.insert(drops, gsid);
			
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
			if(gsItem) then
				if(gsItem and gsItem.template.stats and gsItem.template.stats[12] ~= 0) then
					
					local WHITE = "ffffff";
					local BLUE = "0099ff";
					local GREEN = "00cc33";
					local PURPLE = "c648e1";
					local ORANGE = "ff9a00";
					local this_item_text_color = WHITE;
					local quality = gsItem.template.stats[221];
					if(quality == 0) then
						this_item_text_color = WHITE;
					elseif(quality == 1) then
						this_item_text_color = GREEN;
					elseif(quality == 2) then
						this_item_text_color = BLUE;
					elseif(quality == 3) then
						this_item_text_color = PURPLE;
					elseif(quality == 4) then
						this_item_text_color = ORANGE;
					end

					local this_icon = gsItem.icon;
					if(IsCardOrRune_gsid(gsid)) then
						this_icon = gsItem.descfile;
					end

					local single_block = string.format([[
						<div style="color:#%s;height:24px;" >
							<img src="%s" style="position:relative;margin-left:-30px;width:24px;height:24px"/>
							%s
						</div>]], this_item_text_color, this_icon, if_else(count > 0, gsItem.template.name.." x "..count, gsItem.template.name.."   "..count));
					bubble_mcml = bubble_mcml..single_block;
					item_lines = item_lines + 1;
					
					if(isPvP == true and nid == ProfileManager.GetNID()) then
						-- append to channel
						Dock.ShowNotificationInChannel(gsid, count);
					end
				elseif(gsid >= 20046 and gsid <= 20049) then
					-- 20046_RedMushroomPvP_1v1_PositiveRankingPoints
					-- 20047_RedMushroomPvP_1v1_NegativeRankingPoints
					-- 20048_RedMushroomPvP_2v2_PositiveRankingPoints
					-- 20049_RedMushroomPvP_2v2_NegativeRankingPoints
					local word = "";
					local channel_word = "";
					if(gsid == 20046) then
						word = "1V1赛场积分 +"..count;
						channel_word = "你的[1V1赛场积分] +"..count;
					elseif(gsid == 20047) then
						word = "1V1赛场积分 -"..count;
						channel_word = "你的[1V1赛场积分] -"..count;
					elseif(gsid == 20048) then
						word = "2V2赛场积分 +"..count;
						channel_word = "你的[2V2赛场积分] +"..count;
					elseif(gsid == 20049) then
						word = "2V2赛场积分 -"..count;
						channel_word = "你的[2V2赛场积分] -"..count;
					end
					local single_block = string.format([[
						<div style="color:#%s;height:24px;" >
							%s
						</div>]], text_color, word);
					bubble_mcml = bubble_mcml..single_block;
					item_lines = item_lines + 1;

					if(nid == ProfileManager.GetNID()) then
						-- append to channel
						ChatChannel.AppendChat({
							ChannelIndex = ChatChannel.EnumChannels.ItemObtain, 
							fromname = "", 
							fromschool = Combat.GetSchool(), 
							fromisvip = false, 
							words = channel_word,
							is_direct_mcml = true,
							bHideSubject = true,
							bHideTooltip = true,
							bHideColon = true,
						});
					end
				end
			end
		end

		if(drops) then
			-- show item drop
			Dock.ShowItemDropSound(drops);
		end

        local exp_str = original_exp;
        if(exp_scale > 1) then
            exp_str = original_exp.." x "..exp_scale;
        end
		local single_block = string.format([[<div style="color:#%s;height:24px;">EXP: %s</div>]], 
			exp_text_color, exp_str);
		bubble_mcml = bubble_mcml..single_block;
		item_lines = item_lines + 1;

		local is_teen = System.options.version
		if(is_teen == "teen") then
			if(gained_exp > 0 and nid == ProfileManager.GetNID()) then
				Dock.OnExpNotification(gained_exp)
			end
		end
		
		if(pet_exp and pet_exp > 0) then
			local single_block
			if(is_teen == "teen") then
				single_block = string.format([[<div style="color:#%s;height:24px;">宠物训练点: %s</div>]], 
					exp_text_color, pet_exp);
			else
				single_block = string.format([[<div style="color:#%s;height:24px;">战宠EXP: %s</div>]], 
					exp_text_color, pet_exp);
			end
			bubble_mcml = bubble_mcml..single_block;
			item_lines = item_lines + 1;
			
			if(is_teen == "teen") then
				if(nid == ProfileManager.GetNID()) then
					-- NOTE: 取消战宠经验
					Dock.OnFollowPetExpNotification(pet_exp);
				end
			end
		end

		if(isPvP == nil and gained_joybean and gained_joybean > 0) then
			local single_block = string.format([[<div style="color:#%s;height:24px;">%s: %s</div>]], 
				text_color, System.options.haqi_GameCurrency, gained_joybean);
			bubble_mcml = bubble_mcml..single_block;
			item_lines = item_lines + 1;
		end

		if(isPvP == nil) then
			if(nid == ProfileManager.GetNID()) then
				if(loot_scale == 0.5) then
					BroadcastHelper.PushLabel({id="anti_indulgence_tip", label = "在线3小时后，战斗经验、宠物经验、战利品减半", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				elseif(loot_scale == 0) then
					BroadcastHelper.PushLabel({id="anti_indulgence_tip", label = "在线5小时后不再获得战斗经验、宠物经验、战利品", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				end
			end
		end

		if(item_lines == 0) then
			-- nothing to show
			return;
		end
		local margin_top = -2 - item_lines * 24;

		bubble_mcml = [[<div style="margin-left:200px;width:300px;font-size:14px;"><div style="width:1000px;font-weight:bold;text-shadow:true;shadow-quality:8;">]]..bubble_mcml..[[</div></div>]];

		local anim_type = "plain";
		local sCtrlName = headon_speech.Speek(tostring(nid), bubble_mcml, 5, true, true, nil, -3);
		if(sCtrlName) then
			if(anim_type == "plain") then
				UIAnimManager.PlayCustomAnimation(5000, function(elapsedTime)
					local parent = ParaUI.GetUIObject(sCtrlName);
					if(parent:IsValid()) then
						--parent.scalingx = 1;
						--parent.scalingy = 1;
						parent.translationy = math.floor(0.5 - elapsedTime * 10 / 1000); -- 10 pixels per seconds
						parent:ApplyAnim();
					end
				end);
			--elseif(anim_type == "critical") then
				--UIAnimManager.PlayCustomAnimation(2500, function(elapsedTime)
					--local parent = ParaUI.GetUIObject(sCtrlName);
					--if(parent:IsValid()) then
						--parent.translationy = 0 - elapsedTime * 10 / 1000;
						--if(isCritical and elapsedTime < 200) then
							--parent.scalingx = 2.4 - 0.6 * math.abs(elapsedTime - 100) / 100;
							--parent.scalingy = 2.4 - 0.6 * math.abs(elapsedTime - 100) / 100;
						--else
							--parent.scalingx = 1.8;
							--parent.scalingy = 1.8;
						--end
						--parent:ApplyAnim();
					--end
				--end);
			end
		end
	end
end