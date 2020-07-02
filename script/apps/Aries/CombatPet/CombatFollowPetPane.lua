--[[
Title: CombatFollowPetPane
Author(s): Leio 
Date: 2011/07/19
Desc: 青年版使用
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatPet/CombatFollowPetPane.lua");
local CombatFollowPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatFollowPetPane");
CombatFollowPetPane.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
NPL.load("(gl)script/apps/Aries/Combat/main.lua");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Scene/main.lua");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetConfig.lua");
local CombatPetConfig = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetConfig");
local HPMyPlayerArea = commonlib.gettable("MyCompany.Aries.Desktop.HPMyPlayerArea");
local CombatFollowPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatFollowPetPane");
CombatFollowPetPane.my_pet_cnt = 0;
CombatFollowPetPane.pet_list = nil;
CombatFollowPetPane.selected_gsid = nil;
CombatFollowPetPane.is_auto_fight = true;
CombatFollowPetPane.menu = {
	{label = "辅助主人属性", selected = true, keyname = "1",},
	{label = "自身战斗属性", keyname = nil, keyname = "2",},
};
CombatFollowPetPane.exp_map = {};
local ItemManager = System.Item.ItemManager;
local CombatPetHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetHelper");
local hasGSItem = ItemManager.IfOwnGSItem;
function CombatFollowPetPane.SelectedMenuFirstNode()
	local k,v;
	for k,v in ipairs(CombatFollowPetPane.menu) do
		if(k == 1)then
			v.selected = true;
		else
			v.selected = nil;
		end
	end
end
--返回选中的菜单
function CombatFollowPetPane.GetSelectedMenuNode()
	local k,v;
	for k,v in ipairs(CombatFollowPetPane.menu) do
		if(v.selected)then
			return v;
		end
	end
end
function CombatFollowPetPane.OnInit()
	CombatFollowPetPane.page = document:GetPageCtrl();
end
function CombatFollowPetPane.RefreshPage()
	if(CombatFollowPetPane.page)then
		CombatFollowPetPane.page:Refresh(0.01);
	end
end
function CombatFollowPetPane.ShowPage()
	local params = {
		url = "script/apps/Aries/CombatPet/CombatFollowPetPane.teen.html", 
		name = "CombatFollowPetPane.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		zorder = 0,
		directPosition = true,
			align = "_ct",
			x = -800/2,
			y = -530/2,
			width = 800,
			height = 530,
	}
	CombatFollowPetPane.foodsWnd_visible = false;
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
	CombatFollowPetPane.SelectedMenuFirstNode();
	CombatFollowPetPane.pet_list = CombatFollowPetPane.Load();
	CombatFollowPetPane.selected_index = 1;
	if(CombatFollowPetPane.pet_list)then
		CombatFollowPetPane.OnSelected(CombatFollowPetPane.pet_list[CombatFollowPetPane.selected_index])
	end
end
function CombatFollowPetPane.OnSelected(node)
	if(not node)then return end
	CombatFollowPetPane.is_edit = 0;
	CombatFollowPetPane.selected_gsid = node.gsid;
	CombatFollowPetPane.selected_node = node;
	CombatFollowPetPane.BuildStatOrCardList();
	CombatFollowPetPane.RefreshPage();
end
function CombatFollowPetPane.Load()
	CombatFollowPetPane.my_pet_cnt = 0;
	local pet_config = CombatPetConfig.GetInstance_Client();
	local serverdate = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local rows = pet_config:GetAllRows();
	local pet_list = {};
	local gsid,row;
	for gsid,row in pairs(rows) do
		local locale = row.locale or "zhCN";
		if(string.find(locale,System.options.locale))then
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
			if(gsItem)then
				local pet_name = gsItem.template.name;
				local exp = 0;
				local cur_feed_num = 0;
				local name_cnt = 0;
				local is_top = 0;
				local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
				if(item and item.guid > 0 and item.gsid == gsid) then
					is_top = 1;
				end
				local is_my_pet = 0;
				local bHas,guid = hasGSItem(gsid);
				local levels_info;
				local pet_level = 0;
				local is_evolve_state = false;
				if(bHas)then
					CombatFollowPetPane.my_pet_cnt = CombatFollowPetPane.my_pet_cnt + 1;
					is_my_pet = 1;
					local item = ItemManager.GetItemByGUID(guid);
					if(item and item.GetName_client)then
						pet_name = item:GetName_client();
					end

					if(item.GetServerData)then
						local serverdata = item:GetServerData();
						exp = serverdata.exp;
						cur_feed_num = serverdata.cur_feed_num;
						name_cnt = serverdata.name_cnt or name_cnt;--改名次数
						local cur_feed_date = serverdata.cur_feed_date;
						if(not cur_feed_date)then
							cur_feed_num = 0;
						else
							--如果不是在同一天
							if(cur_feed_date ~= serverdate)then
								cur_feed_num = 0;
							end
						end
					end
				
				end
				local color_name = pet_config:BuildColorName(pet_name,gsid);
				levels_info = pet_config:GetLevelsInfo(gsid,exp)
				if(levels_info)then
					if(levels_info.cur_level and levels_info.start_evolve_level and levels_info.cur_level >= levels_info.start_evolve_level)then
						is_evolve_state = true;
					end
					pet_level = levels_info.cur_level;
				end
				local quality_level = row.quality_level or 0;
				table.insert(pet_list,{
					gsid = gsid,
					color_name = color_name,
					pet_name = pet_name,
					exp = exp,
					cur_feed_num = cur_feed_num,
					name_cnt = name_cnt,
					is_top = is_top,
					is_my_pet = is_my_pet,
					quality_level = quality_level,
					levels_info = levels_info,
					is_evolve_state = is_evolve_state,
					pet_level = pet_level,
				});
			end
		end
	end
	table.sort(pet_list,function(a,b)
		return ( (a.is_top > b.is_top)  
		or (a.is_top == b.is_top and a.is_my_pet > b.is_my_pet) 
		or (a.is_top == b.is_top and a.is_my_pet == b.is_my_pet and a.pet_level > b.pet_level) 
		or (a.is_top == b.is_top and a.is_my_pet == b.is_my_pet and a.pet_level == b.pet_level and a.quality_level > b.quality_level) 
		or (a.is_top == b.is_top and a.is_my_pet == b.is_my_pet and a.pet_level == b.pet_level and a.quality_level == b.quality_level and  a.gsid < b.gsid) 
		);
	end); 
	return pet_list;
end
function CombatFollowPetPane.DS_Func_pet_list(index)
	if(not CombatFollowPetPane.pet_list)then return 0 end
	if(index == nil) then
		return #(CombatFollowPetPane.pet_list);
	else
		return CombatFollowPetPane.pet_list[index];
	end
end
--[[
type: 
属性
cur_stat_list 虚体 当前级别
stat_list 虚体 最高级
cur_entity_stat_list 实体 当前级别
entity_stat_list 实体 最高级

卡片
cur_cards_list 虚体 当前级别
cards_list 虚体 最高级
cur_entity_cards_list  实体 当前级别
entity_cards_list 实体 最高级
--]]
function CombatFollowPetPane.BuildStatOrCardList(pagesize)
	pagesize = pagesize or 10;
	if(CombatFollowPetPane.selected_node)then
		local pet_config = CombatPetConfig.GetInstance_Client();
		local levels_info = CombatFollowPetPane.selected_node.levels_info;
		if(levels_info)then
			local menu_node = CombatFollowPetPane.GetSelectedMenuNode();
			local state = menu_node.keyname;
			if(state == "1")then
				CombatFollowPetPane.cur_stat_list_gridview = levels_info["cur_stat_list"];
				CommonClientService.Fill_List(CombatFollowPetPane.cur_stat_list_gridview,pagesize);

				CombatFollowPetPane.stat_list_gridview = levels_info["stat_list"];
				CommonClientService.Fill_List(CombatFollowPetPane.stat_list_gridview,pagesize);

				CombatFollowPetPane.cur_cards_list_gridview = levels_info["cur_cards_list"];
				CommonClientService.Fill_List(CombatFollowPetPane.cur_cards_list_gridview,pagesize);

				CombatFollowPetPane.cards_list_gridview = levels_info["cards_list"];
				CommonClientService.Fill_List(CombatFollowPetPane.cards_list_gridview,pagesize);
			else
				CombatFollowPetPane.cur_stat_list_gridview = levels_info["cur_entity_stat_list"];
				CommonClientService.Fill_List(CombatFollowPetPane.cur_stat_list_gridview,pagesize);

				CombatFollowPetPane.stat_list_gridview = levels_info["entity_stat_list"];
				CommonClientService.Fill_List(CombatFollowPetPane.stat_list_gridview,pagesize);

				CombatFollowPetPane.cur_cards_list_gridview = levels_info["cur_entity_cards_list"];
				CombatFollowPetPane.cur_cards_list_gridview = CombatFollowPetPane.CutEntityCards(CombatFollowPetPane.cur_cards_list_gridview);
				CommonClientService.Fill_List(CombatFollowPetPane.cur_cards_list_gridview,pagesize);

				CombatFollowPetPane.cards_list_gridview = levels_info["entity_cards_list"];
				CombatFollowPetPane.cards_list_gridview = CombatFollowPetPane.CutEntityCards(CombatFollowPetPane.cards_list_gridview);
				CommonClientService.Fill_List(CombatFollowPetPane.cards_list_gridview,pagesize);
			end
		end
	end
end
--实体卡片 过滤重复gsid和数量为0的卡片
function CombatFollowPetPane.CutEntityCards(list)
	if(not list)then return end
	local len = #list;
	while(len > 0) do
		local node = list[len];
		if(node and node.gsid and node.count and node.count <= 0)then
			table.remove(list,len);
		end
		len = len - 1;
	end
	local map = {};
	local result = {};
	local k,v;
	for k,v in ipairs(list) do
		local gsid = v.gsid;
		if(gsid and not map[gsid])then
			map[gsid] = true;
			table.insert(result,v);
		end
	end
	return result;
end
function CombatFollowPetPane.Ds_func_cur_stat_list(index)
	if(not CombatFollowPetPane.cur_stat_list_gridview)then return 0 end
	if(index == nil) then
		return #(CombatFollowPetPane.cur_stat_list_gridview);
	else
		return CombatFollowPetPane.cur_stat_list_gridview[index];
	end
end
function CombatFollowPetPane.Ds_func_stat_list(index)
	if(not CombatFollowPetPane.stat_list_gridview)then return 0 end
	if(index == nil) then
		return #(CombatFollowPetPane.stat_list_gridview);
	else
		return CombatFollowPetPane.stat_list_gridview[index];
	end
end
function CombatFollowPetPane.Ds_func_cur_cards_list(index)
	if(not CombatFollowPetPane.cur_cards_list_gridview)then return 0 end
	if(index == nil) then
		return #(CombatFollowPetPane.cur_cards_list_gridview);
	else
		return CombatFollowPetPane.cur_cards_list_gridview[index];
	end
end
function CombatFollowPetPane.Ds_func_cards_list(index)
	if(not CombatFollowPetPane.cards_list_gridview)then return 0 end
	if(index == nil) then
		return #(CombatFollowPetPane.cards_list_gridview);
	else
		return CombatFollowPetPane.cards_list_gridview[index];
	end
end

-- @param gsid: if nil, we will true if there is a follow pet. 
function CombatFollowPetPane.IsFollowing(gsid)
	local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
    if(item and item.guid > 0 and (not gsid or item.gsid == gsid) ) then
        return true;
    end
end

function CombatFollowPetPane.DoToggleHome(gsid, callbackFunc)
	if(not gsid)then return end
	local bHas, guid = hasGSItem(gsid);
	if(bHas == true) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
            if(System.options.version == "teen") then
				NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
				local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
				local title = string.format("正在召唤宠物");
				GathererBarPage.Start({ duration = 1000, title = title, disable_shortkey = true, },nil,function()
					item:OnClick("left", nil, nil, true, callbackFunc); -- true for bShowStatsDiff
					HPMyPlayerArea.UpdateUI(true);
				end);
			else
				item:OnClick("left", nil, nil, nil, callbackFunc);
				HPMyPlayerArea.UpdateUI(true);
			end
		end
	end
end

-- play effect for my follow pet on level up
function CombatFollowPetPane.PlayMyFollowPetLevelUpEffect()
	NPL.load("(gl)script/apps/Aries/Combat/SpellCast.lua");
	local SpellCast = commonlib.gettable("MyCompany.Aries.Combat.SpellCast");
	local Pet = commonlib.gettable("MyCompany.Aries.Pet");
	if(Pet.GetUserFollowObj) then
		local spell_file = "";
		if(CommonClientService.IsTeenVersion())then
			spell_file = "config/Aries/Spells/Action_OnLevelUp_teen.xml";
		else
			spell_file = "config/Aries/Spells/Action_OnLevelUp.xml";
		end
		local current_playing_id = ParaGlobal.GenerateUniqueID();
		local playerChar = Pet.GetUserFollowObj();
		if(playerChar and playerChar:IsValid() == true) then
			SpellCast.EntitySpellCast(0, playerChar, 1, playerChar, 1, spell_file, nil, nil, nil, nil, nil, function()
			end, nil, true, current_playing_id, true);
		end
	end
end
function CombatFollowPetPane.UpdateExp(msg)
	if(not msg or not msg.add_exp)then
		return
	end
	local add_exp = msg.add_exp;
	local notification_msg = {};
	notification_msg.adds = {
		{gsid = 966, cnt = add_exp}
	};
	notification_msg.updates = {};
	notification_msg.stats = {};
	NPL.load("(gl)script/apps/Aries/Desktop/Dock.lua");
	local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
	Dock.OnExtendedCostNotification(notification_msg);
end
function CombatFollowPetPane.GetNode(gsid)
	if(not gsid or not CombatFollowPetPane.pet_list)then return end

	local k,v;
	for k,v in ipairs(CombatFollowPetPane.pet_list) do
		if(v.gsid == gsid)then
			return v;
		end	
	end
end
function CombatFollowPetPane.PlayLevelUp_Effect_MiniScene()
	if(not CombatFollowPetPane.page)then
		return
	end
	local canvas3d = CombatFollowPetPane.page:FindControl("FollowPetCanvas");
	if(canvas3d and canvas3d.GetScene)then
		local mini_scene = canvas3d:GetScene();
		local obj = canvas3d:GetObject();
		if(mini_scene and obj)then
			local x,y,z = obj:GetPosition();
			local scale = obj:GetScale()
			local assetfile = "character/v5/09effect/Common/Shexian01_Shangsheng_Yellow.x";
			local asset = Map3DSystem.App.Assets.asset:new({filename = assetfile})
			local objParams = asset:getModelParams()
			local obj = ObjEditor.CreateObjectByParams(objParams);
			obj:SetPosition(x,y,z);
			obj:SetScale(scale);
			mini_scene:AddChild(obj);
			if(not CombatFollowPetPane.effect_timer)then
				CombatFollowPetPane.effect_timer = commonlib.Timer:new();
			end
			CombatFollowPetPane.effect_timer.callbackFunc = function(timer)
				CombatFollowPetPane.OnSelected(CombatFollowPetPane.selected_node);
			end
			CombatFollowPetPane.effect_timer:Change(2000, nil)
		end
	end
end
--喂食回调
function CombatFollowPetPane.DoFeed_Handler(msg)
	if(not msg)then return end
	local pet_config = CombatPetConfig.GetInstance_Client();
	local pet_gsid = msg.pet_gsid;
	local add_exp = msg.add_exp or 0;
	local exp = msg.exp or 0;
	local level = msg.level or 0;
	local level_up = msg.level_up;
	
	if(pet_gsid and add_exp >= 0)then
		local node = CombatFollowPetPane.GetNode(pet_gsid);
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(pet_gsid);
		if(not gsItem) then return end
		local pet_name = gsItem.template.name;
		if(node)then
			pet_name = node.pet_name;
			node.exp = exp;--更新内存经验
			node.levels_info = pet_config:GetLevelsInfo(pet_gsid,exp)
		end
			
		MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"},79019)

		local levels_info = pet_config:GetLevelsInfo(pet_gsid,exp or 0);
		local isfull = levels_info.isfull;
		local s;
		if(isfull)then
			s = string.format([[你的战宠<span style="color:#ffffff">[%s]</span>已经满级！]],pet_name);
		else
			if(level_up)then
				s = string.format([[你的战宠<span style="color:#ffffff">[%s]</span>从%d级升到了%d级！]],pet_name,level,level+1);
			else
				s = string.format([[你的战宠<span style="color:#ffffff">[%s]</span>获得了%d训练点！]],pet_name,add_exp);
			end
		end
		local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
		if(level_up and item and item.gsid and item.gsid == pet_gsid)then
			-- play level up effect
			CombatFollowPetPane.PlayMyFollowPetLevelUpEffect();
		end
		NPL.load("(gl)script/apps/Aries/Desktop/HPMyPlayerArea.lua");
		local HPMyPlayerArea = commonlib.gettable("MyCompany.Aries.Desktop.HPMyPlayerArea");
		HPMyPlayerArea.UpdateUI(true);
		ChatChannel.AppendChat({
			ChannelIndex = ChatChannel.EnumChannels.ItemObtain, 
			fromname = "", 
			fromschool = Combat.GetSchool(), 
			fromisvip = false, 
			words = s,
			is_direct_mcml = true,
			bHideSubject = true,
			bHideTooltip = true,
			bHideColon = true,
		});
		CombatFollowPetPane.OnSelected(CombatFollowPetPane.selected_node);
		MyCompany.Aries.Desktop.HPMyPlayerArea.UpdateUI(true);
		if(level_up)then
			if(not CombatFollowPetPane.effect_time_1)then
				CombatFollowPetPane.effect_time_1 = commonlib.Timer:new();
			end
			CombatFollowPetPane.effect_time_1.callbackFunc = function(timer)
				CombatFollowPetPane.PlayLevelUp_Effect_MiniScene()
			end
			CombatFollowPetPane.effect_time_1:Change(500, nil)
		end
	end
end
--改名回调
function CombatFollowPetPane.DoChangeName_Handler(msg)
    CombatFollowPetPane.is_edit = 0;
	NPL.load("(gl)script/ide/timer.lua");
	if(not CombatFollowPetPane.name_timer)then
		CombatFollowPetPane.name_timer = commonlib.Timer:new({callbackFunc = function(timer)
			ItemManager.RefreshMyself();
		end})
	end
	CombatFollowPetPane.name_timer:Change(2000, nil);
end
function CombatFollowPetPane.Reload()
	if(CombatFollowPetPane.page)then
		CombatFollowPetPane.pet_list = CombatFollowPetPane.Load();
		CombatFollowPetPane.selected_index = CombatFollowPetPane.selected_index or 1;
		if(CombatFollowPetPane.pet_list)then
			CombatFollowPetPane.OnSelected(CombatFollowPetPane.pet_list[CombatFollowPetPane.selected_index])
		end
	end
end
--自动参加战斗的开关
function CombatFollowPetPane.IsAutoFight()
	if(not CombatFollowPetPane.loaded_clientdata)then
		local bHas,guid = hasGSItem(993);
		if(bHas)then
			local item = ItemManager.GetItemByGUID(guid);
			if(item)then
				local clientdata = item.clientdata;
				if(clientdata == "")then
					clientdata = "{}"
				end
				clientdata = commonlib.LoadTableFromString(clientdata);
				local is_auto_fight = clientdata.is_auto_fight;
				if(is_auto_fight and is_auto_fight == 0)then
					is_auto_fight = false
				else
					is_auto_fight = true
				end
				CombatFollowPetPane.is_auto_fight = is_auto_fight;
			end
		end
		CombatFollowPetPane.loaded_clientdata = true;
	end
	return CombatFollowPetPane.is_auto_fight;
end
function CombatFollowPetPane.EnableAutoFight(b)
	CombatFollowPetPane.is_auto_fight = b;
	local bHas,guid = hasGSItem(993);
	if(bHas)then
		local item = ItemManager.GetItemByGUID(guid);
		if(item)then
			local clientdata = item.clientdata;
			if(clientdata == "")then
				clientdata = "{}"
			end
			clientdata = commonlib.LoadTableFromString(clientdata);
			if(not CombatFollowPetPane.is_auto_fight)then
				clientdata.is_auto_fight = 0;
			else
				clientdata.is_auto_fight = nil;
			end
			clientdata = commonlib.serialize_compact2(clientdata);
			ItemManager.SetClientData(guid,clientdata,function(msg_setclientdata)
			end);
		end
	end
end
function CombatFollowPetPane.LevelUp_NeedExp()
    local node = CombatFollowPetPane.selected_node;
	if(node and node.levels_info)then
        local levels_info = node.levels_info;
        local cur_level_exp = levels_info.cur_level_exp or 0;
        local cur_level_max_exp = levels_info.cur_level_max_exp or 0;
    	local exp_gsid = 966;
        local __,__,__,copies = hasGSItem(exp_gsid);
        copies = copies or 0;
        local add_exp = cur_level_max_exp - cur_level_exp;
        return add_exp,copies;
    end
end
--正在跟随的宠物是否可以升级
function CombatFollowPetPane.CanLevelUp_FollowingPet()
	local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
    if(item and item.guid > 0 and item.gsid and item.GetServerData) then
		local pet_config = CombatPetConfig.GetInstance_Client();
		local gsid = item.gsid;
		local serverdata = item:GetServerData() or {};
		local exp = serverdata.exp or 0;
		local levels_info = pet_config:GetLevelsInfo(gsid,exp)
		if(levels_info)then
			local is_full = levels_info.is_full;
			if(is_full)then
				return
			end
			local cur_level = levels_info.cur_level;
			local bean = MyCompany.Aries.Pet.GetBean();
			if(cur_level and bean and bean.combatlel and cur_level>= bean.combatlel)then
				return
			end
			local cur_level_exp = levels_info.cur_level_exp or 0;
			local cur_level_max_exp = levels_info.cur_level_max_exp or 0;
    		local exp_gsid = 966;
			local __,__,__,useful_exp = hasGSItem(exp_gsid);
			useful_exp = useful_exp or 0;
			local add_exp = cur_level_max_exp - cur_level_exp;
			if(add_exp <= useful_exp and useful_exp > 0)then
				return true;
			end
		end
    end
end

-- get the current pet info
-- @return: levels_info.cur_level
function CombatFollowPetPane.CanCurrentPetInfo()
	local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
    if(item and item.guid > 0 and item.gsid and item.GetServerData) then
		local pet_config = CombatPetConfig.GetInstance_Client();
		local gsid = item.gsid;
		local serverdata = item:GetServerData() or {};
		local exp = serverdata.exp or 0;
		local levels_info = pet_config:GetLevelsInfo(gsid,exp)
		return levels_info;
	end
end