--[[
Title: 
Author(s): leio
Date: 2013/1/23
Desc:  

NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/ItemBuildPage.lua");
local ItemBuildPage = commonlib.gettable("MyCompany.Aries.Desktop.ItemBuildPage");
ItemBuildPage.ShowPage();
]]
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/MinorSkillPage.lua");
local MinorSkillPage = commonlib.gettable("MyCompany.Aries.Desktop.MinorSkillPage");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local ItemBuildPage = commonlib.gettable("MyCompany.Aries.Desktop.ItemBuildPage");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
ItemBuildPage.selected_gsid = nil;
ItemBuildPage.need_skill_point = 0;--需要熟练度
ItemBuildPage.need_stamina = 0;--需要精力值
ItemBuildPage.build_cnt = 1;--建造数量
ItemBuildPage.is_pending = nil;
--青年版中 建造分类 
--"rune" 符印相关
--"medicine" 草药相关
--"gem" 宝石相关
ItemBuildPage.page_state = nil; 
ItemBuildPage.all_skills = {
	 [21105] = { label= "烹饪学", level = 10, learn_exid = 1316, icon = "Texture/Aries/Common/ThemeTeen/Spec/cooking_icon_32bits.png",},
	 [21106] = { label= "符文学", level = 25, learn_exid = 1319, icon = "Texture/Aries/Common/ThemeTeen/Spec/magic_icon_32bits.png", },
	 [21107] = { label= "药剂学", level = 15, learn_exid = 1317, icon = "Texture/Aries/Common/ThemeTeen/Spec/stuff_icon_32bits.png",},
	 [21108] = { label= "宝石学", level = 20, learn_exid = 1318, icon = "Texture/Aries/Common/ThemeTeen/Spec/jewelry_icon_32bits.png",},
	 [21109] = { label= "采集学", level = 5, learn_exid = 1315, icon = "Texture/Aries/Common/ThemeTeen/Spec/medic_icon_32bits.png",},
	 [21110] = { label= "采矿学", level = 5, learn_exid = 1314, icon = "Texture/Aries/Common/ThemeTeen/Spec/mineral_icon_32bits.png",},

	 [50387] = { label= "封印师", level = 0, learn_exid = nil, icon = "Texture/Aries/Common/ThemeTeen/Spec/mineral_icon_32bits.png",},
	 [50398] = { label= "药剂学", level = 0, learn_exid = nil, icon = "Texture/Aries/Common/ThemeTeen/Spec/stuff_icon_32bits.png",},
}
ItemBuildPage.all_skills_kids = {
	 [50357] = { label= "魔匠学", level = 0, icon = "Texture/Aries/Common/ThemeTeen/Spec/cooking_icon_32bits.png",},
}
ItemBuildPage.skill_source = {};
function ItemBuildPage.GetCopies(gsid)
    if(not gsid)then return end
    local __,__,__,copies = hasGSItem(gsid);
    copies = copies or 0;
    return copies;
end
function ItemBuildPage.ShowLockedItem_ChangedState()
	local locked = ItemBuildPage.ShowLockedItem();
	MyCompany.Aries.Player.SaveLocalData("ItemBuildPage.ShowLockedItem", not locked)
	local node = ItemBuildPage.GetMenu_CheckedNode();
	if(node)then
		ItemBuildPage.skill_source[node.skill_gsid] = nil;--force load
		ItemBuildPage.OnClickFolder(node.skill_gsid);
	end
end
function ItemBuildPage.ShowLockedItem()
	return MyCompany.Aries.Player.LoadLocalData("ItemBuildPage.ShowLockedItem", true);
end
function ItemBuildPage.IsLocked(need_skill_point,need_skill_gsid)
    if(need_skill_gsid)then
        need_skill_point = need_skill_point or -1;
		if(need_skill_point <= 0)then
			return false
		end
        local copies = ItemBuildPage.GetCopies(need_skill_gsid);
        if(copies >= need_skill_point)then
            return false;
        end
        return true;
    end
end
function ItemBuildPage.BuildMenus()
	if(CommonClientService.IsTeenVersion())then
		if(ItemBuildPage.page_state == "rune")then
			ItemBuildPage.menus = {
				{ label = "符印", selected = true, skill_gsid = 50387, },
			}
		elseif(ItemBuildPage.page_state == "medicine")then
			ItemBuildPage.menus = {
				{ label = "药剂", selected = true, skill_gsid = 50398, },
			}
		elseif(ItemBuildPage.page_state == "gem")then
			ItemBuildPage.menus = {
				{ label = "珠宝", selected = true, skill_gsid = 21108, },
			}
		end
	else
		ItemBuildPage.menus = {
			{ label = "魂印", selected = true, skill_gsid = 50357, },
		}
	end
end
function ItemBuildPage.GetLearnLevel(gsid)
	if(ItemBuildPage.all_skills and ItemBuildPage.all_skills[gsid])then
		return ItemBuildPage.all_skills[gsid].level;
	end
    return 0;
end

function ItemBuildPage.CanLearn(gsid)
    local level = ItemBuildPage.GetLearnLevel(gsid);
    if(MyCompany.Aries.Player.GetLevel() >= level)then
        return true;
    end
end
function ItemBuildPage.GetMenu_CheckedNode()
	local k,v;
	for k,v in ipairs(ItemBuildPage.menus) do
		if(v.selected)then
			return v;
		end
	end
end
function ItemBuildPage.GetConfigPath()
	if(CommonClientService.IsTeenVersion())then
		return "config/Aries/Others/make_item.csv";
	else
		return "config/Aries/Others/make_item.kids.csv";
	end
end
function ItemBuildPage.LoadSource_Skill(skill_gsid)
	if(not skill_gsid)then return end
	if(ItemBuildPage.skill_source[skill_gsid])then
		return ItemBuildPage.skill_source[skill_gsid];
	end
	local csv_source = ItemBuildPage.LoadSource();
	local result = {};
	if(csv_source)then
		local k,v;
		for k,v in ipairs(csv_source) do
			if(v.skill_gsid == skill_gsid)then
				local need_stamina,need_skill_point,need_skill_gsid = ItemBuildPage.GetPreSkillPointByExid(v.exid);
				local is_locked = ItemBuildPage.IsLocked(need_skill_point,need_skill_gsid);
				v.need_stamina = need_stamina;
				v.need_skill_point = need_skill_point;
				v.need_skill_gsid = need_skill_gsid;
				if(is_locked)then
					if(ItemBuildPage.ShowLockedItem())then
						table.insert(result,v);
					end
				else
					table.insert(result,v);
				end
			end
		end
	end
	ItemBuildPage.skill_source[skill_gsid] = result;
	return result;
end
function ItemBuildPage.LoadSource()
	if(not ItemBuildPage.csv_source)then
		ItemBuildPage.csv_source = {};
		local file = ParaIO.open(ItemBuildPage.GetConfigPath(), "r");
		if(file and file:IsValid())then
			local line = file:readline();
			while(line)do
				local skill_gsid,gsid,exid = string.match(line,"(.+),(.+),(.+)");
				skill_gsid = tonumber(skill_gsid);
				gsid = tonumber(gsid);
				exid = tonumber(exid);
				if(skill_gsid and gsid and exid)then
					table.insert(ItemBuildPage.csv_source,{
						skill_gsid = skill_gsid,
						gsid = gsid,
						exid = exid,
					});
				end
				line = file:readline();
			end
			file:close();
		end
	end
	return ItemBuildPage.csv_source;
end
function ItemBuildPage.OnInit()
	ItemBuildPage.page = document:GetPageCtrl();
end
function ItemBuildPage.DS_Func_Items(index)
	if(not ItemBuildPage.items)then return 0 end
	if(index == nil) then
		return #(ItemBuildPage.items);
	else
		return ItemBuildPage.items[index];
	end
end
function ItemBuildPage.DS_Func_item_info(index)
	if(not ItemBuildPage.froms)then return 0 end
	if(index == nil) then
		return #(ItemBuildPage.froms);
	else
		return ItemBuildPage.froms[index];
	end
end
--return need_stamina,need_skill_point,need_skill_gsid
function ItemBuildPage.GetPreSkillPointByExid(exid)
	if(exid)then
		local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
		if(exTemplate)then
			local need_stamina = 0;
			local need_skill_point = 0;
			local need_skill_gsid;
			local k,v;
			for k,v in ipairs(exTemplate.froms) do
				if(v.key == -20)then
					need_stamina = v.value;--需要精力值
					break;
				end
			end
			for k,v in ipairs(exTemplate.pres) do
				if(CommonClientService.IsTeenVersion())then
					if(ItemBuildPage.all_skills[v.key])then
						need_skill_point = v.value;--需要熟练度
						need_skill_gsid = v.key;
						break;
					end	
				else
					if(ItemBuildPage.all_skills_kids[v.key])then
						need_skill_point = v.value;--需要熟练度
						need_skill_gsid = v.key;
						break;
					end	
				end
				
			end
			return need_stamina,need_skill_point,need_skill_gsid;
		end
	end
end
function ItemBuildPage.GetSelectedNode()
	if(ItemBuildPage.selected_gsid)then
		local k,v;
		for k,v in ipairs(ItemBuildPage.items) do
			if(v.gsid == ItemBuildPage.selected_gsid)then
				return v;
			end
		end
	end
end
function ItemBuildPage.DoSelectedItem(gsid)
    ItemBuildPage.selected_gsid = gsid;
	ItemBuildPage.need_skill_point = 0;--需要熟练度
	ItemBuildPage.need_stamina = 0;--需要精力值
	ItemBuildPage.build_cnt = 1;--建造数量
	ItemBuildPage.froms = nil;
	local exid = nil;
	if(gsid)then
		local k,v;
		for k,v in ipairs(ItemBuildPage.items) do
			if(v.gsid == gsid)then
				exid = v.exid;
				break;
			end
		end
	end
	if(exid)then
		local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
		if(exTemplate)then
			local froms = {};
			local k,v;
			for k,v in ipairs(exTemplate.froms) do
				--只判断物品
				if(v.key >= 0)then
					table.insert(froms,v);
				end
			end
			ItemBuildPage.froms = froms;
			CommonClientService.Fill_List(ItemBuildPage.froms,8);
		end
		local need_stamina,need_skill_point,need_skill_gsid = ItemBuildPage.GetPreSkillPointByExid(exid);
		ItemBuildPage.need_skill_point = need_skill_point or 0;
		ItemBuildPage.need_stamina = need_stamina or 0;
	end
	if(ItemBuildPage.page)then
		ItemBuildPage.page:Refresh(0);
	end
end

function ItemBuildPage.OnClickFolder(skill_gsid)
	ItemBuildPage.skill_gsid = skill_gsid;
	ItemBuildPage.items = ItemBuildPage.LoadSource_Skill(skill_gsid)
	CommonClientService.Fill_List(ItemBuildPage.items,49);
	if(ItemBuildPage.page)then
		ItemBuildPage.page:Refresh(0);
	end
end
function ItemBuildPage.ShowPage(page_state)
	ItemBuildPage.page_state = page_state or "gem";
	ItemBuildPage.is_pending = nil;
	ItemBuildPage.BuildMenus();
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	local url;
	if(CommonClientService.IsTeenVersion())then
		url = string.format("script/apps/Aries/Desktop/CombatCharacterFrame/ItemBuildPage.teen.html");
		if(ItemBuildPage.page_state == "rune")then
			if(not MinorSkillPage.IsBuilder()) then
				_guihelper.MessageBox("你还不是封印师, 不能合成魂印！");
				return;
			end
		end
	else
		url = string.format("script/apps/Aries/Desktop/CombatCharacterFrame/ItemBuildPage.html");
		if(not MinorSkillPage.IsBuilder()) then
			_guihelper.MessageBox("你的职业不是魔法工匠, 不能合成魂印！");
			return;
		end
	end
	local params = {
		url = url, 
		app_key = MyCompany.Aries.app.app_key, 
		name = "ItemCheckPage.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		cancelShowAnimation = true,
		style = style,
		bToggleShowHide = true,
		-- zorder = 0,
		allowDrag = true,
		-- isTopLevel = true,
		enable_esc_key = true,
		directPosition = true,
			align = "_ct",
			x = -760/2,
			y = -470/2,
			width = 760,
			height = 470,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	local node = ItemBuildPage.GetMenu_CheckedNode();
	if(node)then
		ItemBuildPage.OnClickFolder(node.skill_gsid);
		ItemBuildPage.DoSelectedItem(nil)
	end
end