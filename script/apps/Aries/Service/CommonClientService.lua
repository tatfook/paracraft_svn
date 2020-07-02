--[[
Title: 
Author(s): Leio
Date: 2011/11/14
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local is_right_school = CommonClientService.IsRightSchool(gsid)
commonlib.echo(is_right_school);
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetHelper.lua");
local CombatPetHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetHelper");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
--find a result if is a right school item
--@param gsid:gsid of global store item
--@param school:系别，如果为空 取自己的系别Combat.GetSchool()
--@param stat_num:stat编号，默认为137物品穿着必须系别，如果是136则是卡片或卷轴的属性
--return: ture if it is a right school item 
function CommonClientService.IsRightSchool(gsid,school,stat_num, item_school)
	if(not gsid)then
		return false;
	end
	stat_num = stat_num or 137
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem) then
		-- stats type ids:
		-- 137 school_requirement(CG) 物品穿着必须系别 1金 2木 3水 4火 5土 6火 7冰 8风暴 9神秘 10生命 11死亡 12平衡 
		-- 138 combatlevel_requirement(CG) 物品穿着必须战斗等级 
		local stats = gsItem.template.stats;
		school = school or Combat.GetSchool();
		item_school = item_school or stats[stat_num];
		if(item_school == 6 and school ~= "fire") then
			return false;
		elseif(item_school == 7 and school ~= "ice") then
			return false;
		elseif(item_school == 8 and school ~= "storm") then
			return false;
		--elseif(item_school == 9 and school ~= "myth") then
		elseif(item_school == 10 and school ~= "life") then
			return false;
		elseif(item_school == 11 and school ~= "death") then
			return false;
		elseif(item_school == 12 and school ~= "balance") then
			return false;
		end
		return true;
	end
	return false;
end
--get incode version
--return "kids" or "teen" or "" or nil
function CommonClientService.GetVersion()
	local options = commonlib.gettable("System.options");
	version = options.version;
	return version;
end
function CommonClientService.IsKidsVersion()
	local version = CommonClientService.GetVersion();
	if(version and version == "kids")then
		return true;
	end
end
function CommonClientService.IsTeenVersion()
	local version = CommonClientService.GetVersion();
	if(version and version == "teen")then
		return true;
	end
end
function CommonClientService.IsEnabled_HelpTooltip(min_combatlel,max_combatlel)
	local bean = MyCompany.Aries.Pet.GetBean();
	local combatlel = 0;
	min_combatlel = min_combatlel or 0;
	max_combatlel = max_combatlel or 50;
	if(bean) then
		combatlel = bean.combatlel or 0;
	end
	if(combatlel >= min_combatlel and combatlel <= max_combatlel)then
		return true;
	end
	return false;
end
function CommonClientService.GetTooltipString(s)
	if(not s)then return end

	local url;
	if(CommonClientService.IsTeenVersion())then
		url = "page://script/apps/Aries/Service/CommonTooltip.teen.html";
	else
		url = "page://script/apps/Aries/Service/CommonTooltip.html";
	end
	local tooltip = string.format("%s?s=%s",url,s);
	return tooltip;
end
--购买物品
function CommonClientService.OnPurchaseItem(gsid)
	
	gsid = tonumber(gsid);
	if(not gsid)then return end
	local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
	if(command) then
		command:Call({gsid = gsid});
	end
end
--显示对话页面
function CommonClientService.ShowDialogPage(url,npc_id)
	if(not url)then return end
	npc_id = tonumber(npc_id) or 0;
	System.App.Commands.Call("Profile.Aries.ShowNPCDialog_Teen_Native",{
		dialog_url = url,
		npc_id = param1,
	});
end

function CommonClientService.OnClick_Item_Special(gsid,callbackFunc)
	if(not gsid)then
        return
    end
	local bHas, guid = ItemManager.IfOwnGSItem(gsid);
	if(bHas) then
		CommonClientService.OnClick_Slot_Special(guid,callbackFunc)
	end
end

function CommonClientService.OnClick_Slot_Special(guid,callbackFunc)
	 if(not guid)then
        return
    end
    local item = ItemManager.GetItemByGUID(guid);
	if(item and item.guid > 0) then
        local gsid = item.gsid;
        if (gsid==998) then
	        ItemManager.UseEnergyStone(function(msg)
	        end, function()
				if(callbackFunc)then
					callbackFunc({
						gsid = gsid,
					});
				end
				MyCompany.Aries.Desktop.HPMyPlayerArea.UpdateUI(true);
	        end);
        elseif(gsid==977) then
			ItemManager.UseEnergyStoneShard(function(msg)
	        end, function()
				if(callbackFunc)then
					callbackFunc({
						gsid = gsid,
					});
				end
				MyCompany.Aries.Desktop.HPMyPlayerArea.UpdateUI(true);
	        end);
        end
		return true;
	end
end
function CommonClientService.UnionList(list1,list2)
	list1 = list1 or {};
	list2 = list2 or {};
	local k,v;
	for k,v in ipairs(list2) do
		table.insert(list1,v);
	end
	return list1;
end
function CommonClientService.Fill_List(list,pagesize)
	if(not list or not pagesize)then
		return;
	end
	local count = #list;
	local displaycount = math.ceil(count / pagesize) * pagesize;

	if(count == 0 )then
		displaycount = pagesize;
	end
	local i;
	for i = 1, displaycount do
		if( i >= (count + 1))then
			table.insert(list,{});
		end
	end
	--for i = count + 1, displaycount do
		--list[i] = {};
	--end
end
function CommonClientService.KidsContextMenuStyle()
	if(not CommonClientService.kids_style)then
		CommonClientService.kids_style = {
			borderTop = 4,
			borderBottom = 4,
			borderLeft = 4,
			borderRight = 4,
				
			fillLeft = 0,
			fillTop = 0,
			fillWidth = 0,
			fillHeight = 0,
				
			titlecolor = "#283546",
			level1itemcolor = "#283546",
			level2itemcolor = "#3e7320",
				
			iconsize_x = 24,
			iconsize_y = 21,
				
			menu_bg = "Texture/Aries/Creator/border_bg_32bits.png:3 3 3 3",
			menu_lvl2_bg = "Texture/Aries/Creator/border_bg_32bits.png:3 3 3 3",
			shadow_bg = nil,
			separator_bg = "Texture/Aries/Dock/menu_separator_32bits.png", -- : 1 1 1 4
			item_bg = "Texture/Aries/Dock/menu_item_bg_32bits.png: 10 6 10 6",
			expand_bg = "Texture/Aries/Dock/menu_expand_32bits.png; 0 0 34 34",
			expand_bg_mouseover = "Texture/Aries/Dock/menu_expand_mouseover_32bits.png; 0 0 34 34",
				
			menuitemHeight = 24,
			separatorHeight = 2,
			titleHeight = 24,
				
			titleFont = "System;12;bold";
		};
	end
	return CommonClientService.kids_style;
end
--获取最大孔位数量
function CommonClientService.GetMaxHoleCnt(gsid)
	if(not gsid)then return 0 end
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem) then
		local stat_36 = gsItem.template.stats[36] or 0;
		return stat_36;
	end
	return 0;
end
--防御宝石和多彩宝石不能同时镶嵌
function CommonClientService.GemIsSameResistType(gsid1,gsid2)
	if(gsid1 and gsid2)then
		local gsItem1 = ItemManager.GetGlobalStoreItemInMemory(gsid1);
		local gsItem2 = ItemManager.GetGlobalStoreItemInMemory(gsid2);
		if(gsItem1 and gsItem2) then
			local stat_42_1 = gsItem1.template.stats[42] or 0;
			local stat_42_2 = gsItem2.template.stats[42] or 0;

			if( stat_42_1 == 21 and (stat_42_2 == 11 or stat_42_2 == 12 or stat_42_2 == 13 or stat_42_2 == 14 or stat_42_2 == 15) )then
				return true;
			elseif( stat_42_2 == 21 and (stat_42_1 == 11 or stat_42_1 == 12 or stat_42_1 == 13 or stat_42_1 == 14 or stat_42_1 == 15) )then
				return true;
			end
		end
	end
end
--是否是同一类型的宝石
function CommonClientService.GemIsSameType(gsid1,gsid2)
	if(gsid1 and gsid2)then
		local gsItem1 = ItemManager.GetGlobalStoreItemInMemory(gsid1);
		local gsItem2 = ItemManager.GetGlobalStoreItemInMemory(gsid2);
		if(gsItem1 and gsItem2) then
			local stat_42_1 = gsItem1.template.stats[42] or 0;
			local stat_42_2 = gsItem2.template.stats[42] or 0;
			if(stat_42_1 == stat_42_2 
				and gsItem1.template.class == gsItem2.template.class 
				and gsItem1.template.subclass == gsItem2.template.subclass)then
				return true;
			end
		end
	end
end
--自己是否和宠物是相同系别
function CommonClientService.PetIsSameSchool(pet_gsid)
	if(not pet_gsid)then return end
    local provider = CombatPetHelper.GetClientProvider();
	if(provider)then
		local p = provider:GetPropertiesByID(pet_gsid);
		if(p)then
            local item_school = tonumber(p.school);
			return CommonClientService.IsRightSchool(pet_gsid,nil,nil, item_school)
		end
	end
end