--[[
Title: quest helper and status buttons
Author(s): WangTian
Date: 2009/4/7
Desc: See Also: script/apps/Aries/Desktop/AriesDesktop.lua
Such as ranking, task list, lobby, mijiuhulu, lobby count down, toggle camera mode, etc. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/QuestArea.lua");
MyCompany.Aries.Desktop.QuestArea.Init();


NPL.load("(gl)script/apps/Aries/Desktop/QuestArea.lua");
local QuestArea = commonlib.gettable("MyCompany.Aries.Desktop.QuestArea");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Combat/main.lua");
NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingListMain.teen.lua");
NPL.load("(gl)script/apps/Aries/Desktop/ActivityNote.lua");
--NPL.load("(gl)script/apps/Aries/Desktop/MiJiuHuLu.lua");
NPL.load("(gl)script/apps/Aries/BigEvents/BigEvents.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestPathfinderNavUI.lua");
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CharacterBagPage.lua");
local CharacterBagPage = commonlib.gettable("MyCompany.Aries.Inventory.CharacterBagPage");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
-- create class
local QuestArea = commonlib.gettable("MyCompany.Aries.Desktop.QuestArea");
local page;
QuestArea.max_size = 30;
-- virtual function: create UI
function QuestArea.Create()
	local self = QuestArea;
	local _parent = ParaUI.CreateUIObject("container", "AriesQuestArea", "_lt", 80, 75, 350, 30);
	_parent.background = "";
	_parent:GetAttributeObject():SetField("ClickThrough", true);
	_parent:AttachToRoot();
	--_parent.zorder= -10;
	page = page or Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Desktop/QuestArea/QuestArea.teen.html",click_through = true,});
	if(System.options.IsMobilePlatform) then
		page.SelfPaint = true;
	end
	-- one can create a UI instance like this. 
	page:Create("Aries_QuestArea_mcml", _parent, "_fi", 0, 0, 0, 0);

	QuestArea.RegistGsids();

	NPL.load("(gl)script/apps/Aries/Desktop/LinksArea/LinksAreaPage.lua");
	local LinksAreaPage = commonlib.gettable("MyCompany.Aries.Desktop.LinksAreaPage");
	LinksAreaPage.Create();
end

function QuestArea.MSGProc(msg)
	if(msg.type == 1003) then
		-- create tracker page if any
		MyCompany.Aries.Quest.QuestPathfinderNavUI.CreatePage();		
	end
end

-- show/hide quest 3d tracker
function QuestArea.Show3DTracker(bShow)
	if(bShow == nil) then
		bShow = true;
	end
	MyCompany.Aries.Quest.QuestPathfinderNavUI.ShowPage(bShow);
end

-- virtual function: fresh the quest area
function QuestArea.Refresh()
end

-- virtual function: called by the mijiuhulu module to turn on its visibility
function QuestArea.ShowMijiuhulu(show)
end

-- virtual function: called by the mijiuhulu module
function QuestArea.SetMiJiuHuLuTips(tips)
	QuestArea.MiJiuHuLu_Label = tips or "";
end

-- virtual function: called by the mijiuhulu module
function QuestArea.FlashMiJiuHuLu(bbounce)
end

-- virtual function: 
-- @param name: "MiJiuHuLu", "QuestList", etc
-- @param bounce_or_stop: "stop", "bounce"
function QuestArea.Bounce_Static_Icon(name,bounce_or_stop)
end
--更新buff状态
function QuestArea.UpdateGsidStatus()
	local k,v;
	local show_gsids = {};
	for k,v in ipairs(QuestArea.gsids) do
		local gsid = v.gsid;
		local icon = v.icon;
		local tooltip = v.tooltip;
		local copies = v.copies;

		if(gsid == "cafe_double_exp")then
			NPL.load("(gl)script/apps/Aries/Desktop/LinksArea/LinksAreaPage.lua");
			local LinksAreaPage = commonlib.gettable("MyCompany.Aries.Desktop.LinksAreaPage");
			if(LinksAreaPage.ImFromInternetCafe_zhTW)then
				table.insert(show_gsids,{gsid = gsid, copies = copies, icon = icon, tooltip = tooltip,});		
			end
		elseif(gsid == "global_double_exp")then
			if(copies == 1)then
				table.insert(show_gsids,{gsid = gsid, copies = copies, icon = icon, tooltip = tooltip,});		
			end
		elseif(gsid == "over_weight")then
			if(Combat.IsOverWeight())then
				table.insert(show_gsids,{gsid = gsid, copies = 1, icon = icon, tooltip = tooltip,});		
			end
		elseif(gsid == "zero_durability")then
			local p = Combat.GetLowestDurabilityPercent();
			if(p <= 50 and p > 20)then
				table.insert(show_gsids,{gsid = gsid, click_action = "Bag", copies = 1, tooltip="装备已破损<br/>当一件装备耐久度为0%时，它的属性就会完全失效。", extra_info = string.format([[<div style="color:#fee11c">%d%%</div>]],p), icon = "Texture/Aries/Desktop/ExpBuff/durability_60_32bits.png", });		
			elseif(p <= 20)then
				table.insert(show_gsids,{gsid = gsid, click_action = "Bag", copies = 1, tooltip="装备已严重破损<br/>当一件装备耐久度为0%时，它的属性就会完全失效。", extra_info = string.format([[<div style="color:#f61909">%d%%</div>]],p), icon = "Texture/Aries/Desktop/ExpBuff/durability_20_32bits.png", });		
			end
		elseif(gsid == "slot_position_bag_0")then
			local bag = v.bag;
			local from_position = v.from_position;
			local to_position = v.to_position;
			if(bag and from_position and to_position)then
				local position;
				for position = from_position,to_position do
					local item = ItemManager.GetItemByBagAndPosition(bag, position);
					if(item and item.guid and item.guid ~= 0)then
						local guid = item.guid;
						table.insert(show_gsids,{guid = guid,});		
					end
				end
			end

		else
			local bHas,__,__,copies = hasGSItem(gsid);
			if(bHas)then
				table.insert(show_gsids,{gsid = gsid, copies = copies, icon = icon, tooltip = tooltip,});		
			end
		end
	end
	
	-- how many items per line, this should match the one in the mcml page's gridview control. currently 40 items with 4 lines is supported. 
	--local nItemsPerLine = 10;
	--local nCount = 0;
	--local nFirstLineItem = 1;
	--for k = 1,QuestArea.max_size do
		--nCount = k % nItemsPerLine;
		--local tmp = show_gsids[k];
		--if(nCount == 1) then
			--nFirstLineItem = k;
		--end
		--if(nCount == nItemsPerLine or k == QuestArea.max_size or (not tmp and nCount>1)) then
			--QuestArea.SwapTable(nFirstLineItem, nFirstLineItem + nItemsPerLine - 1, show_gsids);
		--end
		--if(not tmp) then
			--break;
		--end
	--end
	if(not commonlib.compare(QuestArea.show_gsids, show_gsids)) then
		-- only refresh if at least one item changes
		QuestArea.show_gsids = show_gsids;
		if(page)then
			page:Refresh(0);
		end
	end
end

local tmp_item_template = {is_null=true}
-- swap items in the given range. 
function QuestArea.SwapTable(start_index,end_index,source)
	if(not source)then return end
	local min = start_index
	local max = end_index
	
	local k;
	local count = math.floor((max - min+1)/2+0.5)
	for k = 0,count-1 do
		local a, b = source[min+k], source[max - k]
		source[max - k], source[min+k] = if_else(a, a, tmp_item_template), if_else(b, b, tmp_item_template);
	end
end

--注册需要显示的buff
function QuestArea.RegistGsids()
	if(not QuestArea.gsids)then
		QuestArea.gsids = {
			{ gsid = "zero_durability", label = "装备耐久损失", icon = "Texture/Aries/Desktop/ExpBuff/durability_60_32bits.png", tooltip = ""},
			{ gsid = "over_weight", label = "负重超载", icon = "Texture/Aries/Desktop/ExpBuff/over_weight_32bits.png", tooltip = "<b>负重超载</b><br/>背包中的物品超出了上限，战斗力下降一半<br/>快卖掉一些不需要的物品，或者扩展背包"},
			{ gsid = 40001, label = "经验强化药丸", icon = "Texture/Aries/Item_Teen/12001_ExpPowerPotion.png", tooltip = "<b>经验强化药丸</b><br/>使用后20场战斗经验额外增加100%",},
			{ gsid = 40003, label = "假日努力药丸", icon = "Texture/Aries/Item_Teen/12002_ExpPowerPotion_Holiday.png", tooltip = "<b>假日努力药丸</b><br/>假日使用<br/>使用后20场战斗经验加成50%",},
			{ gsid = 40006, label = "超级经验药丸", icon = "Texture/Aries/Item_Teen/12046_ExpPowerPotionAdd10Times.png", tooltip = "<b>超级经验药丸</b><br/>战斗获得10倍经验，持续20场。",},
			{ gsid = "global_double_exp", label = "青龙祝福", icon = "Texture/Aries/Desktop/ExpBuff/expbuff_double_icon_32bits.png", tooltip = "<b>青龙的祝福</b><br/>青龙大人在每个周末的晚上赐予所有哈奇魔法师的祝福<br/>战斗经验翻倍，防御强度+3%。"},
			{ gsid = "cafe_double_exp", label = "网咖的祝福", icon = "Texture/Aries/Desktop/ExpBuff/cafe_double_exp_32bits.png", tooltip = "<b>网咖活动</b><br/>战斗经验得到双倍强化!"},
			--{ gsid = 15512, label = "攻击药丸", icon = "Texture/Aries/Item/12012_CombatPills_DamageBoost.png", tooltip = "攻击药丸\n今天有效\n通用攻击:+5%",},
			--{ gsid = 15513, label = "防御药丸", icon = "Texture/Aries/Item/12013_CombatPills_ResistBoost.png", tooltip = "防御药丸\n今天有效\n通用防御:+2%",},
			--{ gsid = 15514, label = "耐力药丸", icon = "Texture/Aries/Item/12014_CombatPills_HPBoost.png", tooltip = "耐力药丸\n今天有效\nHP:+200",},
			{ gsid = "slot_position_bag_0", label = "bag", bag = 0, from_position = 45, to_position = 45, icon = "Texture/Aries/Desktop/ExpBuff/durability_60_32bits.png", tooltip = "bag_0"},
			{ gsid = "slot_position_bag_0", label = "bag", bag = 0, from_position = 90, to_position = 107, icon = "Texture/Aries/Desktop/ExpBuff/durability_60_32bits.png", tooltip = "bag_0"},
			{ gsid = "slot_position_bag_0", label = "bag", bag = 0, from_position = 111, to_position = 127, icon = "Texture/Aries/Desktop/ExpBuff/durability_60_32bits.png", tooltip = "bag_0"},
			{ gsid = "slot_position_bag_0", label = "bag", bag = 0, from_position = 131, to_position = 137, icon = "Texture/Aries/Desktop/ExpBuff/durability_60_32bits.png", tooltip = "bag_0"},
		}
	end
	if(not QuestArea.timer)then
		QuestArea.timer = commonlib.Timer:new({callbackFunc = function(timer)
			QuestArea.UpdateGsidStatus();
		end});
	end
	QuestArea.timer:Change(0,5000)
end

function QuestArea.Get_tooltip_zero_durability()
	return Combat.GetDurabilityTooltip();
end

--青龙祝福
function QuestArea.ResetGsidStatus_global_double_exp(bShow, n_ExpScaleAcc)
	if(QuestArea.gsids)then
		local k,v;
		for k,v in ipairs(QuestArea.gsids) do
			if(v.gsid == "global_double_exp")then
				if(bShow)then
					v.copies = 1;
					v.tooltip = "<b>青龙的祝福</b><br/>青龙大人在每个周末的晚上赐予所有哈奇魔法师的祝福<br/>战斗经验翻倍，防御强度+3%。";
				else
					v.copies = nil;
				end
			end
		end
		QuestArea.UpdateGsidStatus();
	end
end

-- open user bag
function QuestArea.OpenUserBag()
    NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CharacterBagPage.lua");
    local CharacterBagPage = commonlib.gettable("MyCompany.Aries.Inventory.CharacterBagPage");
    CharacterBagPage.ShowPage();
end