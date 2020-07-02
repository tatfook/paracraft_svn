--[[
Title: code behind for page MyCards.html
Author(s): WangTian
Date: 2009/6/12
Desc:  script/apps/Aries/Combat/UI/MyCards.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");

local MyCards = commonlib.gettable("MyCompany.Aries.Combat.MyCards");

local Combat = commonlib.gettable("MyCompany.Aries.Combat");

NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/ArrowPointer.lua");
local ArrowPointer = commonlib.gettable("MyCompany.Aries.Desktop.GUIHelper.ArrowPointer");

NPL.load("(gl)script/ide/TooltipHelper.lua");
local TooltipHelper = commonlib.gettable("CommonCtrl.TooltipHelper");

local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local playerlist;
local moblist;

local players = {};
local mobs = {}; 
local dsItems_cards;
local dsItems_runes;
local dsItems_followpetcards;
local res_width, res_height;
local page; 

function MyCards.OnInit()
	page = document:GetPageCtrl();

	playerlist = page:GetRequestParam("playerlist");
	moblist = page:GetRequestParam("moblist");

	-- status: nil not available, 1 fetching all, 2 fetched. 
	dsItems_cards = {status = nil, };
	dsItems_runes = {status = nil, };
	dsItems_followpetcards = {status = nil, };

	local _;
	_, _, res_width, res_height = ParaUI.GetUIObject("root"):GetAbsPosition();

	---- show the arrow tutorial in my card picker
	--local CombatTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatTutorial");
	--if(CombatTutorial and CombatTutorial.IsInTutorial and CombatTutorial.IsInTutorial()) then
		--ArrowPointer.ShowArrow(9842, 2, "_ct", -342, -170, 64, 64);
	--end
	
	MyCards.producecount = MyCompany.Aries.app:ReadConfig("AriesProduceCount", 0 );

	local CombatTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatTutorial");
	if(CombatTutorial and CombatTutorial.IsInTutorial and CombatTutorial.IsInTutorial()) then
		MyCards.producecount = 3;
	end
end

-- The data source for items
function MyCards.DS_Func_Card_Items_(dsTable, index, pageCtrl)
	---- original implementation of card item version
    --if(not dsTable.status) then
        ---- use a default cache
        --MyCards.GetItems(pageCtrl, "access plus 5 minutes", dsTable, pipscount)
    --elseif(dsTable.status == 2) then    
        --if(index == nil) then
			--return dsTable.Count;
        --else
			--return dsTable[index];
        --end
    --end

	-- new implementation of deck version
	MyCards.GetItems2(dsTable)
    if(index == nil) then
		return dsTable.Count;
    else
		return dsTable[index];
    end
end

function MyCards.DS_Func_Rune_Items_(index, pageCtrl)
	
	local dsTable = MyCards.GetRuneItems2()
    if(index == nil) then
		return dsTable.Count;
    else
		return dsTable[index];
    end
end

function MyCards.DS_Func_FollowPetCards_Items_(dsTable, index, pageCtrl)
	
	MyCards.GetFollowPetCardItems2(dsTable)
    if(index == nil) then
		return dsTable.Count;
    else
		return dsTable[index];
    end
end

function MyCards.GetItems2(output)
    local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
	local CardPickerCardsAtHandList = MsgHandler.CardPickerCardsAtHandList;

	local seq_card_hand = 0;
	local _, pair;
	for _, pair in ipairs(CardPickerCardsAtHandList or {}) do
		
		local gsid = Combat.Get_gsid_from_cardkey(pair.key);
		if(gsid) then
			seq_card_hand = seq_card_hand + 1;

			local bAvailable = pair.bCanCast;
			local discarded = if_else(not pair.discarded, false, true);
			if(discarded == true) then
				bAvailable = false;
			end
			output[seq_card_hand] = {
				seq = pair.seq,
				key = pair.key,
				gsid = gsid,
				bAvailable = bAvailable,
				cooldown = pair.cooldown,
				discarded = discarded,
				cooldown_pic = if_else(pair.cooldown and pair.cooldown > 0 and pair.cooldown < 10, "Texture/Aries/Desktop/CountDownHelper/countdown_"..pair.cooldown..".png", ""),
				cooldown_pic_digit1 = if_else(pair.cooldown and pair.cooldown >= 10, "Texture/Aries/Desktop/CountDownHelper/countdown_"..math.floor(pair.cooldown / 10)..".png", ""),
				cooldown_pic_digit2 = if_else(pair.cooldown and pair.cooldown >= 10, "Texture/Aries/Desktop/CountDownHelper/countdown_"..math.mod(pair.cooldown, 10)..".png", ""),
			};
		end
	end
	output.Count = seq_card_hand;
end

function MyCards.GetRuneCardCount()
	return 8;
	--if(MsgHandler.CardPickerRunesAtHandList) then
		--return #MsgHandler.CardPickerRunesAtHandList;
	--else
		--return 0;
	--end
end

--MyCards.runeList={}; -- 所有的符文

--function MyCards.GetRuneList()
	--return MyCards.runeList;
--end

function MyCards.GetRuneItems2(output)
	--output = commonlib.copy(MyCardsManager.rune_bags);
	local output = MyCardsManager.rune_bags;
    local CardPickerRunesAtHandList = MsgHandler.CardPickerRunesAtHandList or {};

	MyCardsManager.UpdateQuickRune();
	--if(not CardPickerRunesAtHandList) then
		--output.Count = 0;
	--end
	local seq_card_hand = 0;
	local _, pair;
	for _, pair in ipairs(CardPickerRunesAtHandList) do
		
		local gsid = Combat.Get_gsid_from_rune_cardkey(pair.key);
		if(gsid) then
			seq_card_hand = seq_card_hand + 1;
			--local count = 0;
			--local bHas, _, __, copies = hasGSItem(gsid + 1000);
			--if(bHas) then
				--count = copies;
			--end
			local cooldown = if_else(pair.count > 0, pair.cooldown, 0);
			local rune = {
				seq = pair.seq,
				key = pair.key,
				gsid = gsid,
				bAvailable = pair.bCanCast,
				cooldown = cooldown,
				cooldown_pic = if_else(cooldown and cooldown > 0 and cooldown < 10, "Texture/Aries/Desktop/CountDownHelper/countdown_"..cooldown..".png", ""),
				cooldown_pic_digit1 = if_else(cooldown and cooldown >= 10, "Texture/Aries/Desktop/CountDownHelper/countdown_"..math.floor(cooldown / 10)..".png", ""),
				cooldown_pic_digit2 = if_else(cooldown and cooldown >= 10, "Texture/Aries/Desktop/CountDownHelper/countdown_"..math.mod(cooldown, 10)..".png", ""),
				copies = pair.count,
			};
			if(MyCardsManager.runeListMap[gsid]) then
				local index = MyCardsManager.runeListMap[gsid]["index"];
				MyCardsManager.runeList[index] = rune;
			end
			
			--MyCards.runeList[seq_card_hand] = rune;

			if(MyCardsManager.quickRuneMap[gsid]) then
				local index = MyCardsManager.quickRuneMap[gsid]["index"];
				output[index] = nil;
				output[index] = rune;
			end
			--[[
			output[seq_card_hand] = {
				seq = pair.seq,
				key = pair.key,
				gsid = gsid,
				bAvailable = pair.bCanCast,
				cooldown = pair.cooldown,
				cooldown_pic = if_else(pair.cooldown and pair.cooldown > 0 and pair.cooldown < 10, "Texture/Aries/Desktop/CountDownHelper/countdown_"..pair.cooldown..".png", ""),
				cooldown_pic_digit1 = if_else(pair.cooldown and pair.cooldown >= 10, "Texture/Aries/Desktop/CountDownHelper/countdown_"..math.floor(pair.cooldown / 10)..".png", ""),
				cooldown_pic_digit2 = if_else(pair.cooldown and pair.cooldown >= 10, "Texture/Aries/Desktop/CountDownHelper/countdown_"..math.mod(pair.cooldown, 10)..".png", ""),
				count = pair.count,
			};
			--]]
		end
	end
	--for i = 1,#output do
		--if(not output[i]) then
			--output[i] = {gsid = 0,}
		--end
	--end
	output.Count = 8;
	return output;
end

function MyCards.GetPetCardCount()
	if(MsgHandler.CardPickerFollowPetCardsAtHandList) then
		return #MsgHandler.CardPickerFollowPetCardsAtHandList;
	else
		return 0;
	end
end

function MyCards.GetFollowPetCardItems2(output)
    local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
	local CardPickerFollowPetCardsAtHandList = MsgHandler.CardPickerFollowPetCardsAtHandList or {};

	if(#CardPickerFollowPetCardsAtHandList == 0) then
		output.Count = 0;
	end

	local seq_card_hand = 0;
	local _, pair;
	for _, pair in ipairs(CardPickerFollowPetCardsAtHandList) do
		
		local gsid = Combat.Get_gsid_from_cardkey(pair.key);
		if(not gsid) then
			gsid = Combat.Get_gsid_from_rune_cardkey(pair.key);
		end
		if(gsid) then
			seq_card_hand = seq_card_hand + 1;
			--local count = 0;
			--local bHas, _, __, copies = hasGSItem(gsid + 1000);
			--if(bHas) then
				--count = copies;
			--end
			output[seq_card_hand] = {
				seq = pair.seq + 10000,
				key = pair.key,
				gsid = gsid,
				bAvailable = pair.bCanCast,
				cooldown = pair.cooldown,
				cooldown_pic = if_else(pair.cooldown and pair.cooldown > 0 and pair.cooldown < 10, "Texture/Aries/Desktop/CountDownHelper/countdown_"..pair.cooldown..".png", ""),
				cooldown_pic_digit1 = if_else(pair.cooldown and pair.cooldown >= 10, "Texture/Aries/Desktop/CountDownHelper/countdown_"..math.floor(pair.cooldown / 10)..".png", ""),
				cooldown_pic_digit2 = if_else(pair.cooldown and pair.cooldown >= 10, "Texture/Aries/Desktop/CountDownHelper/countdown_"..math.mod(pair.cooldown, 10)..".png", ""),
				count = pair.count,
			};
		end
	end
	output.Count = seq_card_hand;
end


function MyCards.DS_Func_Card_Items(index)
	dsItems_cards = {status = nil, };
    return MyCards.DS_Func_Card_Items_(dsItems_cards, index, page);
end

function MyCards.DS_Func_Rune_Items(index)
    return MyCards.DS_Func_Rune_Items_(index, page);
end

function MyCards.DS_Func_FollowPetCards_Items(index)
	dsItems_followpetcards = {status = nil, };
    return MyCards.DS_Func_FollowPetCards_Items_(dsItems_followpetcards, index, page);
end

function MyCards.ShowTip()
	if(MyCards.producecount < 3 ) then
		return true;
	else
		return false;
	end
end

function MyCards.OnPass()
    local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
	MsgHandler.OnPass();
end

function MyCards.OnAuto()
	-- 12007_AutomaticCombatPills
	local bHas = hasGSItem(12007);
	if(not bHas) then
		_guihelper.MessageBox([[<div style="margin-top:16px;">没有自动战斗药丸不能进入自动战斗模式</div>]]);
		return;
	end
    local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
	MsgHandler.OnAuto();
end

function MyCards.OnFlee()
	--PvP
    local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
	local my_arena_data = MsgHandler.GetMyArenaData();
	if(my_arena_data and my_arena_data.mode == "free_pvp") then
		-- pvp arena
		paraworld.ShowMessage([[<div style="margin-top:16px;">即使失败也是有经验的，但逃跑没有。你确定要逃跑吗？</div>]], function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
				MsgHandler.OnFlee();
			end	
		end, _guihelper.MessageBoxButtons.YesNo);
	else
		if(System.options.version == "teen") then
			paraworld.ShowMessage([[<div style="margin-top:16px;">逃跑后你将无法获得任何战利品，且会损失5%的装备耐久度（VIP3级不会损耗），确定要逃跑吗？</div>]], function(res)
				if(res and res == _guihelper.DialogResult.Yes) then
					local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
					MsgHandler.OnFlee();
				end	
			end, _guihelper.MessageBoxButtons.YesNo);
		else
			-- pve arena
			local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
			MsgHandler.OnFlee();
		end
	end
end

function MyCards.OnPickPet()
	-- hide the arrow in tutorial
	local isInTutorial = false;
	local CombatTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatTutorial");
	local CombatPipTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatPipTutorial");
	if(CombatTutorial and CombatTutorial.IsInTutorial and CombatTutorial.IsInTutorial()) then
		ArrowPointer.HideArrow(9842);
		isInTutorial = true;
	end
	if(CombatPipTutorial and CombatPipTutorial.IsInTutorial and CombatPipTutorial.IsInTutorial()) then
		ArrowPointer.HideArrow(9842);
		isInTutorial = true;
	end

	local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
	if(mouse_button == "left") then
		-- pick pet
		-- first hide card picker
		MsgHandler.HideCardPicker();
		MsgHandler.PickedCardKey = nil;
		MsgHandler.PickedCardSeq = nil;

		-- show the pet picker
		MsgHandler.ShowPetPicker();
	end
end

function MyCards.OnShowCatchPetItemPicker(mob_id, level, current_hp, max_hp)
	-- hide the arrow in tutorial
	local isInTutorial = false;
	local CombatTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatTutorial");
	local CombatPipTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatPipTutorial");
	if(CombatTutorial and CombatTutorial.IsInTutorial and CombatTutorial.IsInTutorial()) then
		ArrowPointer.HideArrow(9842);
		isInTutorial = true;
	end
	if(CombatPipTutorial and CombatPipTutorial.IsInTutorial and CombatPipTutorial.IsInTutorial()) then
		ArrowPointer.HideArrow(9842);
		isInTutorial = true;
	end

	local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
	if(mouse_button == "left") then
		-- catch pet item
		-- first hide card picker
		MsgHandler.HideCardPicker();
		MsgHandler.PickedCardKey = nil;
		MsgHandler.PickedCardSeq = nil;

		-- show the pet picker
		MsgHandler.ShowCatchPetItemPicker(mob_id, level, current_hp, max_hp);
	end
end

function MyCards.OnCatchPet()
	-- hide the arrow in tutorial
	local isInTutorial = false;
	local CombatTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatTutorial");
	local CombatPipTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatPipTutorial");
	if(CombatTutorial and CombatTutorial.IsInTutorial and CombatTutorial.IsInTutorial()) then
		ArrowPointer.HideArrow(9842);
		isInTutorial = true;
	end
	if(CombatPipTutorial and CombatPipTutorial.IsInTutorial and CombatPipTutorial.IsInTutorial()) then
		ArrowPointer.HideArrow(9842);
		isInTutorial = true;
	end

	local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
	if(mouse_button == "left") then
		-- pick pet
		-- first hide card picker
		MsgHandler.HideCardPicker();
		MsgHandler.PickedCardKey = nil;
		MsgHandler.PickedCardSeq = nil;
		
		-- catch pet
		MsgHandler.PickedCardKey = "CatchPet";

		-- pick target mob
		MsgHandler.ShowTargetPicker(nil, true);
	end
end

--function MyCards.PickCard(gsid)
    --gsid = tonumber(gsid);
--
    --local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid)
    --if(gsItem) then
        --local assetkey = gsItem.assetkey;
        --local _, key = string.match(assetkey, "^(%d+)_(.+)$")
        --if(key) then
            --MyCompany.Aries.Combat.MyCards.debug_picked_card_key = key;
        --end
    --end
--end

--function MyCards.PickTarget(id)
    --MyCompany.Aries.Combat.MyCards.debug_picked_card_key = MyCompany.Aries.Combat.MyCards.debug_picked_card_key or "Pass";
--
    --local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
	---- first hide all card picker
	--MsgHandler.HideCardPicker();
	---- clear count down timer
	--MsgHandler.OnUpdateCountDown(0);
--
	--if(id == "self") then
		--MsgHandler.OnPickCard(MyCompany.Aries.Combat.MyCards.debug_picked_card_key, false, 0); -- 0 stands for self
	--else
		--local npc_id = tonumber(id);
		--MsgHandler.OnPickCard(MyCompany.Aries.Combat.MyCards.debug_picked_card_key, true, npc_id);
	--end
--
    --MyCompany.Aries.Combat.MyCards.debug_picked_card_key = "Pass";
--end


function MyCards.ShowCardPickHint(params)
	local Desktop = MyCompany.Aries.Desktop;
	Desktop.GUIHelper.ArrowPointer.ShowArrow(7946, 8, "_lt", 47, 140, 64, 64, nil, params.parent);
end

MyCards.advanced_tip_index = 1;
MyCards.advanced_tip_unit = nil;
MyCards.advanced_tip_word = "左键点击，选取一张魔法卡片";

-- set the card pick hint index and word
function MyCards.SetCardPickHint(index, unit, word)
	MyCards.advanced_tip_index = index;
	MyCards.advanced_tip_unit = unit;
	MyCards.advanced_tip_word = word;
end

function MyCards.ShowCardPickHint_advanced(params)
	local index = MyCards.advanced_tip_index;
	local advanced_tip_word = MyCards.advanced_tip_word;

	if(index and advanced_tip_word) then
		
		local offest_x = params.left or 0;
		local offest_y = params.top or 0;
		local offest_gap = 0;

		if(System.options.version == "kids") then
			local _arrow = ParaUI.CreateUIObject("container", "arrow_bg", "_lt", offest_x + 50 + (88 + offest_gap) * (index - 1), -30+offest_y, 32, 64);
			_arrow.background = "Texture/Aries/Combat/MyCards/CombatHint_Arrow.png; 0 0 32 56";
			_arrow.zorder = 1000;
			params.parent:AddChild(_arrow);

			local _img = ParaUI.CreateUIObject("container", "surround_img", "_lt", offest_x + 17 + (88 + offest_gap) * (index - 1), 17+offest_y, 103, 149);
			_img.background = "Texture/Aries/Common/ThemeTeen/animated/btn_anim_32bits_fps10_a012.png";
			--_img.zorder = 1000;
			params.parent:AddChild(_img);
		else
			local Desktop = MyCompany.Aries.Desktop;
			Desktop.GUIHelper.ArrowPointer.ShowArrow(7946, 2, "_lt", offest_x + 38 + (88 + offest_gap) * (index - 1), -80+offest_y, 64, 64, nil, params.parent);
		end

		local text_width = _guihelper.GetTextWidth(advanced_tip_word);
		 
		local _bg ;
		if(System.options.version == "kids") then
			_bg = ParaUI.CreateUIObject("container", "Tip_bg", "_lt", offest_x + 32 + 38 + (88 + offest_gap) * (index - 1) - ((text_width + 40) / 2), -90+offest_y, 256, 88);
			--_bg.background = "Texture/Aries/Combat/MyCards/CombatHint_BG_32bits.png: 24 10 24 10";
			_bg.background = "Texture/Aries/Combat/MyCards/CombatHint_BG_32bits.png; 0 0 256 88";
			_bg.zorder = 1000;
		else
			_bg = ParaUI.CreateUIObject("container", "Tip_bg", "_lt", offest_x + 32 + 38 + (88 + offest_gap) * (index - 1) - ((text_width + 40) / 2), -130+offest_y, text_width + 40, 48);
			_bg.background = "Texture/Aries/Common/ThemeTeen/rookiehelp_bg_32bits.png: 6 6 6 6";
		end
		params.parent:AddChild(_bg);
		
		if(System.options.version == "kids") then
			--local text_img = ParaUI.CreateUIObject("container", "text_img", "_lt", (256-text_width)/2 - 20, 20, text_width + 20, 40);
			--text_img.background = "Texture/Aries/Common/ThemeTeen/animated/btn_anim_32bits_fps10_a012.png";
			--_bg:AddChild(text_img);

			local _text = ParaUI.CreateUIObject("button", "Tip_text", "_lt", (256-text_width)/2 - 15, 32, text_width + 5, 17);
			_text.text = advanced_tip_word;
			_text.background = "";
			_text.enabled = false;
			_bg:AddChild(_text);

		elseif(System.options.version == "teen") then
			local _text = ParaUI.CreateUIObject("button", "Tip_text", "_fi", 0, 0, 0, 0);
			_guihelper.SetFontColor(_text, "#05f7ff");
			_text.background = "";
			_text.text = advanced_tip_word;
			_text.background = "";
			_text.enabled = false;
			_bg:AddChild(_text);

			local _arrow = ParaUI.CreateUIObject("container", "arrow_bg", "_lt", 38 + 88 * (index - 1) + 60+offest_x, -130 + 50+offest_y, 12, 13);
			_arrow.background = "Texture/Aries/Common/ThemeTeen/rookiehelp_downarrow_32bits.png#0 0 12 13";
			params.parent:AddChild(_arrow);
		end
	end
end

function MyCards.ShowInfo()
end

-- return the self unit on current arena
function MyCards.GetMySelfUnitOnArena()
	local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");
	local data = MyCompany.Aries.Combat.MsgHandler.GetMyArenaData();
	if(data) then
		local bMyselfFarSideInArena = data.bMyselfFarSideInArena;
		local unit_self;
		local index;
		for index = 1, 4 do
			index = 5 - index;
			if(bMyselfFarSideInArena == true) then
				index = index + 4;
			end
			if(data.players[index].nid == ProfileManager.GetNID()) then
				unit_self = data.players[index];
				break;
			end
		end
		return unit_self;
	end
end

-- compute the total number of normal and powerpips 
-- e.g. local pips_normal, pips_power = MyCards.ComputeCostPip(gsid);
-- @param gsid: the card gsid
-- @param pips_normal: normal pips count or nil 
-- @param pips_power: power pips count or nil. 
-- @param school: nil or 1金 2木 3水 4火 5土 6火 7冰 8风暴 9神秘 10生命 11死亡 12平衡 
-- @return pips_normal_cost, pips_power_cost, pips_normal, pips_power, realcost, pip_count: the number of pips cost
function MyCards.ComputeCostPip(gsid, pips_normal, pips_power, school)
	local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem) then
		local pip_count = gsItem.template.stats[134] or 0;
		if(pip_count == 114) then
			-- this is an x pip cost, cost as much as possible
			pip_count = 14;
		end
		
		school = school or gsItem.template.stats[136];
		local is_same_school = (MyCompany.Aries.Inventory.Cards.MyCardsManager.class_type == school);
		
		if(not pips_power or not pips_normal) then
			local unit_self = MyCards.GetMySelfUnitOnArena();
			if(unit_self) then
				pips_normal = unit_self.pips or 0
				pips_power = unit_self.power_pips or 0;
			end
		end
		local pips_normal_old = pips_normal;
		local pips_power_old = pips_power;
		local pip_count_old = pip_count;
		local realcost = 0;

		if(is_same_school) then
			-- own school spell, costing power pips as 2 pips
			while(pip_count > 0) do
				if(pip_count >= 2) then
					-- cost power pips as possible
					if(pips_power > 0) then
						pips_power = pips_power - 1;
						pip_count = pip_count - 2;
						realcost = realcost + 2;
					elseif(pips_normal > 0) then
						pips_normal = pips_normal - 1;
						pip_count = pip_count - 1;
						realcost = realcost + 1;
					else
						pips_normal = pips_normal - 1;
						pip_count = pip_count - 1;
					end
				else
					-- cost normal pips as possible
					if(pips_normal > 0) then
						pips_normal = pips_normal - 1;
						pip_count = pip_count - 1;
						realcost = realcost + 1;
					elseif(pips_power > 0) then
						pips_power = pips_power - 1;
						pip_count = pip_count - 1;
						realcost = realcost + 1;
					else
						pips_power = pips_power - 1;
						pip_count = pip_count - 1;
					end
				end
			end
		else
			-- other school spell, costing all pips as normal pips
			if(pip_count <= pips_normal) then
				pips_normal = pips_normal - pip_count;
				realcost = realcost + pip_count;
			else
				realcost = realcost + math.min(pips_power, (pip_count - pips_normal));
				pips_power = pips_power - (pip_count - pips_normal);
				realcost = realcost + pips_normal;
				pips_normal = 0;
			end
		end
		-- make sure pips_power and pips_normal are all positive
		if(pips_power < 0) then
			pips_power = 0;
		end
		if(pips_normal < 0) then
			pips_normal = 0;
		end
		return (pips_normal_old - pips_normal), (pips_power_old - pips_power), pips_normal_old, pips_power_old, realcost, pip_count_old;
		-- echo({gsid=gsid, pip_count = pip_count, sch = school, same_school=is_same_school, gsItem.template.description, pips_power=pips_power, pips=pips})
	end
end

function MyCards.getCardTip(templategsid)
    templategsid = tonumber(templategsid);
    if(not templategsid)then return end

	local pips_helper_section = "&pips_helper=true";
	if(System.options.version == "teen") then
		pips_helper_section = "";
	end
	local bFromInCombatDeck_section = "";
	if(System.options.version == "teen") then
		bFromInCombatDeck_section = "&bFromInCombatDeck=true";
	end
    local s = string.format("page://script/apps/Aries/Inventory/Cards/CardsTooltip.html?gsid=%d&state=4%s%s", templategsid, pips_helper_section, bFromInCombatDeck_section);
    return s;
end

function MyCards.getCardTipUnavailable(templategsid, cooldown)
    templategsid = tonumber(templategsid);
	cooldown = tonumber(cooldown)
    if(not templategsid)then return end
	
	local pips_helper_section = "&pips_helper=true";
	if(System.options.version == "teen") then
		pips_helper_section = "";
	end
	local bFromInCombatDeck_section = "";
	if(System.options.version == "teen") then
		bFromInCombatDeck_section = "&bFromInCombatDeck=true";
	end
    local s = string.format("page://script/apps/Aries/Inventory/Cards/CardsTooltip.html?gsid=%d&state=5&cooldown=%d%s%s", templategsid, cooldown, pips_helper_section, bFromInCombatDeck_section);
    return s;
end

-- self only keys
local base_self_only_keys_kids = {
	["Ice_ReflectionShield"] = true,
	["Ice_Rune_ReflectionShield"] = true,
	["Ice_Absorb_LevelX"] = true,
	["Ice_DefensiveStance"] = true,
	["Ice_Rune_DefensiveStance"] = true,
	["Balance_Rune_TauntStance"] = true,
	["Life_FuryStance"] = true,

	["Life_HealingStance"] = true,
	["Fire_BlazingStance"] = true,
	["Storm_ElectricStance"] = true,
	["Ice_PierceStance"] = true,
	["Death_VampireStance"] = true,
};
local base_self_only_keys_teen = {
	["Ice_Absorb_LevelX"] = true,
	["Ice_DefensiveStance"] = true,
	["Ice_Rune_DefensiveStance"] = true,
	["Balance_Rune_TauntStance"] = true,
	["Life_FuryStance"] = true,

	["Life_HealingStance"] = true,
	["Fire_BlazingStance"] = true,
	["Storm_ElectricStance"] = true,
	["Ice_PierceStance"] = true,
	["Death_VampireStance"] = true,
};

local self_only_keys_lower_kids = {};
local base_name, _;
for base_name, _ in pairs(base_self_only_keys_kids) do
	self_only_keys_lower_kids[string.lower(base_name)] = true;
end

local self_only_keys_lower_teen = {};
local base_name, _;
for base_name, _ in pairs(base_self_only_keys_teen) do
	self_only_keys_lower_teen[string.lower(base_name)] = true;
	self_only_keys_lower_teen[string.lower(base_name.."_Green")] = true;
	self_only_keys_lower_teen[string.lower(base_name.."_Blue")] = true;
	self_only_keys_lower_teen[string.lower(base_name.."_Purple")] = true;
	self_only_keys_lower_teen[string.lower(base_name.."_Orange")] = true;
end

-- onclick, picked a card. 
function MyCards.OnClickCard(gsid, instname, seq)
	-- hide the arrow in tutorial
	local isInTutorial = false;
	local CombatTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatTutorial");
	local CombatPipTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatPipTutorial");
	if(CombatTutorial and CombatTutorial.IsInTutorial and CombatTutorial.IsInTutorial()) then
		ArrowPointer.HideArrow(9842);
		isInTutorial = true;
	end
	if(CombatPipTutorial and CombatPipTutorial.IsInTutorial and CombatPipTutorial.IsInTutorial()) then
		ArrowPointer.HideArrow(9842);
		isInTutorial = true;
	end

	local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
	if(mouse_button == "left") then
		if(MsgHandler.callback_after_card_click) then
			MsgHandler.callback_after_card_click();
		end
		-- pick card
		-- first hide card picker
		MsgHandler.HideCardPicker();
		-- hide the my runes page
		MsgHandler.HideMyRunesPage();
		MsgHandler.PickedCardKey = nil;
		MsgHandler.PickedCardSeq = nil;

		if( MyCards.producecount < 3 ) then
			MyCards.producecount = MyCards.producecount + 1;
			MyCompany.Aries.app:WriteConfig("AriesProduceCount", MyCards.producecount);
		end

		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);

		if(gsItem) then
			local assetkey = gsItem.assetkey;
			local _, key = string.match(assetkey, "^(%d+)_(.+)$");
			if(key) then
				MsgHandler.PickedCardKey = key;
				MsgHandler.PickedCardSeq = seq;
				local key_lower = string.lower(key);
				
				local CardPickerCardsAtHandList = MsgHandler.CardPickerCardsAtHandList;

				local _, pair;
				for _, pair in ipairs(CardPickerCardsAtHandList or {}) do
					if(MyCards.advanced_tip_index == _ and seq == pair.seq) then
						MsgHandler.SetTargetPickerHintUnitOnChoosePickHint(MyCards.advanced_tip_unit);
						break;
					end
				end

				--if(string.find(key_lower, "revive")) then
					--MsgHandler.ShowTargetPicker(gsid, false);
				--elseif(string.find(key_lower, "focusprism")) then
					--MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, false, 0);
				if(string.find(key_lower, "areaglobalshield")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, false, 0);
				elseif(string.find(key_lower, "areaabsorb")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, false, 0);
				elseif(string.find(key_lower, "life_singleheal_fornonlife_level2")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, false, 0);
				elseif(System.options.version == "kids" and self_only_keys_lower_kids[key_lower]) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, false, 0);
				elseif(System.options.version == "teen" and self_only_keys_lower_teen[key_lower]) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, false, 0);
				elseif(string.find(key_lower, "boostpowerpipchance")) then
					MsgHandler.ShowTargetPicker(gsid, false);
				elseif(string.find(key_lower, "gainpip")) then
					MsgHandler.ShowTargetPicker(gsid, false);
				elseif(string.find(key_lower, "boostdodgechance")) then
					MsgHandler.ShowTargetPicker(gsid, false);
				elseif(string.find(key_lower, "enrage")) then
					MsgHandler.ShowTargetPicker(gsid, true);
				elseif(string.find(key_lower, "singletaunt")) then
					MsgHandler.ShowTargetPicker(gsid, true);
				elseif(string.find(key_lower, "areataunt")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, true, -1);
				elseif(string.find(key_lower, "stealcharm")) then
					MsgHandler.ShowTargetPicker(gsid, true);
				elseif(string.find(key_lower, "removenegativecharm")) then
					MsgHandler.ShowTargetPicker(gsid, false);
				elseif(string.find(key_lower, "removepositivecharm")) then
					MsgHandler.ShowTargetPicker(gsid, true);
				elseif(string.find(key_lower, "conversepositiveward")) then
					MsgHandler.ShowTargetPicker(gsid, true);
				elseif(string.find(key_lower, "removecardsinhand")) then
					MsgHandler.ShowTargetPicker(gsid, true);
				elseif(string.find(key_lower, "singlestealth")) then
					MsgHandler.ShowTargetPicker(gsid, false);
				elseif(string.find(key_lower, "areasingleattackwithdot")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, true, -1);
				elseif(string.find(key_lower, "singleattack")) then
					MsgHandler.ShowTargetPicker(gsid, true);
				elseif(string.find(key_lower, "arenaattack")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, true, -1);
				elseif(string.find(key_lower, "areaattack")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, true, -1);
				elseif(string.find(key_lower, "areadotattack")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, true, -1);
				elseif(string.find(key_lower, "areasingleattack")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, true, -1);
				elseif(string.find(key_lower, "dotattack")) then
					MsgHandler.ShowTargetPicker(gsid, true);
				elseif(string.find(key_lower, "singleguardianwithimmolate")) then
					MsgHandler.ShowTargetPicker(gsid, false);
				elseif(string.find(key_lower, "singleheal")) then
					MsgHandler.ShowTargetPicker(gsid, false, true); -- true for bShowDeadFriendly
				elseif(string.find(key_lower, "areaheal")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, false, 0);
				elseif(string.find(key_lower, "areacleanse")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, false, 0);
				elseif(string.find(key_lower, "areapowerpipboost")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, false, 0);
				elseif(string.find(key_lower, "singlestun")) then
					MsgHandler.ShowTargetPicker(gsid, true);
				elseif(string.find(key_lower, "singlefreeze")) then
					MsgHandler.ShowTargetPicker(gsid, true);
				elseif(string.find(key_lower, "singledisease")) then
					MsgHandler.ShowTargetPicker(gsid, true);
				elseif(string.find(key_lower, "singlecleanse")) then
					MsgHandler.ShowTargetPicker(gsid, false);
				elseif(string.find(key_lower, "areastunabsorb")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, false, 0);
				elseif(string.find(key_lower, "areastun")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, true, -1);
				elseif(string.find(key_lower, "areadamageweakness")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, true, -1);
				elseif(string.find(key_lower, "areaaccuracyweakness")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, true, -1);
				elseif(string.find(key_lower, "areadamagetrap")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, true, -1);
				elseif(string.find(key_lower, "areadamageshield")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, false, 0);
				elseif(string.find(key_lower, "areaaccuracyblade")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, false, 0);
				elseif(string.find(key_lower, "areadamageblade")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, false, 0);
				elseif(string.find(key_lower, "globalaura")) then
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, false, 0);
				elseif(string.find(key_lower, "miniaura")) then
					MsgHandler.ShowTargetPicker(gsid, false);
				elseif(string.find(key_lower, "blade")) then
					MsgHandler.ShowTargetPicker(gsid, false);
				elseif(string.find(key_lower, "weakness")) then
					MsgHandler.ShowTargetPicker(gsid, true);
				elseif(string.find(key_lower, "shield")) then
					MsgHandler.ShowTargetPicker(gsid, false);
				elseif(string.find(key_lower, "trap")) then
					MsgHandler.ShowTargetPicker(gsid, true);
				elseif(string.find(key_lower, "prism")) then
					MsgHandler.ShowTargetPicker(gsid, true);
				elseif(string.find(key_lower, "absorb")) then
					MsgHandler.ShowTargetPicker(gsid, false);
				elseif(string.find(key_lower, "catchpet")) then
					MsgHandler.ShowTargetPicker(gsid, true);
				else
					MsgHandler.ShowTargetPicker(gsid, true);
				end

				-- reset the pick hint unit
				MsgHandler.SetTargetPickerHintUnitOnChoosePickHint(nil);
				
				-- click card button
				local audio_src = AudioEngine.CreateGet("Audio/Haqi/UI/Button07.ogg");
				audio_src.file = "Audio/Haqi/UI/Button07.ogg";
				audio_src:play();
			end
		end
	elseif(mouse_button == "right") then
		if(isInTutorial) then
			return;
		end
		-- discard card
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem) then
			local assetkey = gsItem.assetkey;
			local _, key = string.match(assetkey, "^(%d+)_(.+)$");
			if(key) then
				-- reset pick card
				MsgHandler.PickedCardKey = nil;
				MsgHandler.PickedCardSeq = nil;

				local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
				local CardPickerCardsAtHandList = MsgHandler.CardPickerCardsAtHandList;
				
				local _, pair;
				for _, pair in ipairs(CardPickerCardsAtHandList or {}) do
					if(key == pair.key and seq == pair.seq) then
						if(CardPickerCardsAtHandList[_].discarded) then
							CardPickerCardsAtHandList[_].discarded = false;
							-- tell the server to restore discarded card
							MsgHandler.OnRestoreDiscardedCard(key, seq);
						else
							CardPickerCardsAtHandList[_].discarded = true;
							-- tell the server discarded card
							MsgHandler.OnDiscardCard(key, seq);
						end
						-- update card pick hint
						local index, unit, word = MsgHandler.MakeCardPickHint();
						MyCards.SetCardPickHint(index, unit, word);
						page:Init(page.url);
						break;
					end
				end
			end
		end
	end

	TooltipHelper.HideLast();
end

function MyCards.RefreshMycardsPage()
	page:Init(page.url);
end

-- onclick Unavailable card
function MyCards.OnClickCardUnavailable(gsid, instname, seq)
	local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
	if(mouse_button == "left") then
		-- unavaliable card
	elseif(mouse_button == "right") then
		local isInTutorial = false;
		local CombatTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatTutorial");
		local CombatPipTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatPipTutorial");
		if(CombatTutorial and CombatTutorial.IsInTutorial and CombatTutorial.IsInTutorial()) then
			isInTutorial = true;
		end
		if(CombatPipTutorial and CombatPipTutorial.IsInTutorial and CombatPipTutorial.IsInTutorial()) then
			isInTutorial = true;
		end
		if(isInTutorial) then
			return;
		end
		-- discard card
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem) then
			local assetkey = gsItem.assetkey;
			local _, key = string.match(assetkey, "^(%d+)_(.+)$");
			if(key) then
				-- reset pick card
				MsgHandler.PickedCardKey = nil;
				MsgHandler.PickedCardSeq = nil;
				
				local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
				local CardPickerCardsAtHandList = MsgHandler.CardPickerCardsAtHandList;
				
				local _, pair;
				for _, pair in ipairs(CardPickerCardsAtHandList or {}) do
					if(key == pair.key and seq == pair.seq) then
						if(CardPickerCardsAtHandList[_].discarded) then
							CardPickerCardsAtHandList[_].discarded = false;
							-- tell the server to restore discarded card
							MsgHandler.OnRestoreDiscardedCard(key, seq);
						else
							CardPickerCardsAtHandList[_].discarded = true;
							-- tell the server discarded card
							MsgHandler.OnDiscardCard(key, seq);
						end
						-- update card pick hint
						local index, unit, word = MsgHandler.MakeCardPickHint();
						MyCards.SetCardPickHint(index, unit, word);
						page:Init(page.url);
						break;
					end
				end
			end
		end
	end
end

function MyCards.OnFollowPet_FollowMode()
    local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
	MsgHandler.OnFollowPet_FollowMode();
end

function MyCards.OnFollowPet_CombatMode()
    local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
	MsgHandler.OnFollowPet_CombatMode();
end

--function MyCards.GetItems(pageCtrl, cachepolicy, output, pipscount)
	--MyCardsManager.Bag_RemoteLoad(function()
		--local cards_list = MyCardsManager.GetLocalCombatBag();
		--if(cards_list)then
			--local count = MyCardsManager.GetCanEquipNum() or 8;
			--output.Count = count;
			----local k,node;
			----for k,node in ipairs(cards_list) do
				----if(node.gsid and node.gsid ~= 0)then
					----output[k] = { gsid = node.gsid};
				----end
			----end
			--local k;
			--for k = 1,count do
				--local node = cards_list[k];
				--if(node)then
					--local gsid;
					--local templategsid = node.gsid;
					--if(templategsid and templategsid ~= 0)then
						--gsid = templategsid + 1000;
					--end
					--output[k] = { gsid = gsid or 0 ,templategsid = templategsid};
				--else
					--output[k] = { gsid = 0};
				--end
			--end
			--MyCards.__GetItems(pageCtrl, cachepolicy, output, pipscount)
		--end
	--end)
--end
--function MyCards.__GetItems(pageCtrl, cachepolicy, output, pipscount)
	---- fetching inventory items
	--output.status = 1;
	------ reacord each slot gsid
	----local base_gsid = 23000;
	------ 14 pages of items
	----output.Count = 20;
	----local i = 1;
	----for i = 1, 20 do
		----output[i] = {gsid = base_gsid + i};
	----end
	--local ItemManager = System.Item.ItemManager;
	--local hasGSItem = ItemManager.IfOwnGSItem;
	--local equipGSItem = ItemManager.IfEquipGSItem;
	--
	---- find the right bag for inventory items
	--local bags = {25};
	--local ItemManager = Map3DSystem.Item.ItemManager;
	--bags.ReturnCount = 0;
	--local _, bag;
	--for _, bag in ipairs(bags) do
		--ItemManager.GetItemsInBag(bag, "mycards_"..bag, function(msg)
			--bags.ReturnCount = bags.ReturnCount + 1;
			--if(bags.ReturnCount >= #bags) then
				--if(msg and msg.items) then
					--local i;
					--for i = 1, #output do
						--local gsid = output[i].gsid;
						--local bHas, guid = hasGSItem(gsid);
						--if(bHas) then
							--output[i].bAvailable = true;
							--output[i].guid = guid;
						--else
							--output[i].bAvailable = false;
						--end
--
						--local pips_cost = 0;
						--local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid)
						--if(gsItem) then
							--pips_cost = gsItem.template.stats[134];
						--end
--
						--if(gsid and gsid ~= 0 and pips_cost and pips_cost > pipscount) then
							--output[i].bAvailable = false;
						--end
					--end
				--end
				--commonlib.resize(output, output.Count);
				---- fetched inventory items
				--output.status = 2;
				--pageCtrl:Refresh(0.1);
			--end
		--end, cachepolicy);
	--end
--end