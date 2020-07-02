--[[
Title: CombatPetPane
Author(s): Leio 
Date: 2011/07/19
Desc: 儿童版使用
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetPane.lua");
local CombatPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPane");
CombatPetPane.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
local HomeLandGateway = commonlib.gettable("Map3DSystem.App.HomeLand.HomeLandGateway");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
NPL.load("(gl)script/apps/Aries/Combat/main.lua");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");
NPL.load("(gl)script/apps/Aries/Scene/main.lua");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetFoodsPage.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetHelper.lua");
local ItemManager = System.Item.ItemManager;
local CombatPetHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetHelper");
local hasGSItem = ItemManager.IfOwnGSItem;
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");

local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
local CombatPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPane");
CombatPetPane.must_in_homeland = {
	10112,--蜗牛
	10113,--飞飞
	10115,--松树
	10130,--燕子
	10129,--元宵
}
CombatPetPane.search_start_gsid = 10101;
CombatPetPane.search_end_gsid = 10999;
CombatPetPane.pet_list = nil;
CombatPetPane.nid = nil;
CombatPetPane.selected_index = nil;
CombatPetPane.selected_node = nil;
CombatPetPane.show_type = nil; --"mypets" or "allpets"
CombatPetPane.show_grow_type = "junior"; --成长类型"junior" or "senior"
CombatPetPane.pet_list_mypet = nil;--我的宠物
CombatPetPane.pet_list_templates = nil;--宠物大全 常量
CombatPetPane.show_type_menu = nil;
CombatPetPane.show_grow_type_menu = nil;
CombatPetPane.title = nil;
CombatPetPane.foodsWnd_visible = nil;
CombatPetPane.gemsWnd_visible = nil;
--记录每只宠物的经验
CombatPetPane.exp_map = {};
function CombatPetPane.UpdateExp(gsid,exp)
	local self = CombatPetPane;
	if(not gsid or not exp)then return end
	local last_exp = self.exp_map[gsid] or exp;
	local provider = CombatPetHelper.GetClientProvider();
	self.exp_map[gsid] = exp;
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(not gsItem) then return end
	local HPMyPlayerArea = commonlib.gettable("MyCompany.Aries.Desktop.HPMyPlayerArea");
	HPMyPlayerArea.UpdateUI(true);
	local pet_name = gsItem.template.name;
	if(provider)then
		local last_level,__,__,isfull = provider:GetLevelInfo(gsid,last_exp or 0);
		local level,__,__,isfull = provider:GetLevelInfo(gsid,exp or 0);
		local has_senior_level = provider:HasSeniorLevel(gsid);
		if(level > last_level)then
			local s;
			if(not isfull)then
				s = string.format([[你的战宠<span style="color:#ffffff">[%s]</span>从%d级升到了%d级！]],pet_name,last_level,level);
			else
				if(not has_senior_level)then
					s = string.format([[你的战宠<span style="color:#ffffff">[%s]</span>已经满级！]],pet_name);
				else
					s = string.format([[你的战宠<span style="color:#ffffff">[%s]</span>成长已经满级，现在进入进化阶段！]],pet_name);
				end
			end
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
			-- play level up effect
			CombatPetPane.PlayMyFollowPetLevelUpEffect();
			
			return;
		end
		if(isfull and provider:HasSeniorLevel(gsid))then
			local last_level = provider:GetSeniorLevelInfo(gsid,last_exp or 0);
			local level = provider:GetSeniorLevelInfo(gsid,exp or 0);
			if(level > last_level)then
				local s;
				if(not isfull)then
					s = string.format("你的战宠[%s]升级了！",pet_name);
				else
					s = string.format("你的战宠[%s]已经满级！",pet_name);
				end
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
				-- play level up effect
				CombatPetPane.PlayMyFollowPetLevelUpEffect();
				return;
			end
		end
	end
end

-- play effect for my follow pet on level up
function CombatPetPane.PlayMyFollowPetLevelUpEffect()
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

function CombatPetPane.SetAnchorTip(b)
	local self = CombatPetPane;
	self.anchor_tip = b;	
end
function CombatPetPane.OnInit()
	local self = CombatPetPane;
	self.page = document:GetPageCtrl();
end
function CombatPetPane.ClosePage()
	local self = CombatPetPane;
	if(self.page)then
		self.page:CloseWindow();
		self.page = nil;	
	end
	self.nid = nil;
	self.pet_list = nil;
	self.selected_index = nil;
	self.selected_node = nil;
end
--所有等级显示
function CombatPetPane.DS_Func_all_level_list(index)
	local self = CombatPetPane;
    if(not self.all_level_list)then return 0 end
	if(index == nil) then
		return #(self.all_level_list);
	else
		return self.all_level_list[index];
	end
end
--附加属性卡片数据显示
function CombatPetPane.DS_Func_combine_props_list(index)
	local self = CombatPetPane;
    if(not self.combine_props_list)then return 0 end
	if(index == nil) then
		return #(self.combine_props_list);
	else
		return self.combine_props_list[index];
	end
end
--食物列表数据显示
function CombatPetPane.DS_Func_foods_list(index)
	local self = CombatPetPane;
    if(not self.foods_list)then return 0 end
	if(index == nil) then
		return #(self.foods_list);
	else
		return self.foods_list[index];
	end
end
--宠物列表数据显示
function CombatPetPane.DS_Func_Items(index)
	local self = CombatPetPane;
	if(not self.pet_list)then return 0 end
	if(index == nil) then
		return #(self.pet_list);
	else
		return self.pet_list[index];
	end
end
--获取普通成长的等级信息
function CombatPetPane.GetLevelInfo()
	local self = CombatPetPane;
	local provider = CombatPetHelper.GetClientProvider();
    local node = CombatPetPane.selected_node;
    if(provider and node)then
        local level,cur_exp,total_exp,isfull = provider:GetLevelInfo(node.gsid,node.exp or 0);
        return level,cur_exp,total_exp,isfull;
    end
end
--获取高级成长的等级信息
function CombatPetPane.GetSeniorLevelInfo()
	local provider = CombatPetHelper.GetClientProvider();
    local node = CombatPetPane.selected_node;
    if(provider and node)then
        local level,cur_exp,total_exp,isfull = provider:GetSeniorLevelInfo(node.gsid,node.exp or 0);
        return level,cur_exp,total_exp,isfull;
    end
end
--在宠物大全中，返回选中等级是在哪个成长阶段 "junior" or "senior"
function CombatPetPane.GetTemplateLevelState()
	local self = CombatPetPane;
    local node = CombatPetPane.selected_node;
    local provider = CombatPetHelper.GetClientProvider();
	if(self.all_level_list and node and provider)then
		local k,v;
		for k,v in ipairs(self.all_level_list) do
			if(v.selected == "true")then
				local level_node = v;
				local p = provider:GetPropertiesByID(node.gsid);
				if(level_node and p)then
					local grown_state = level_node.grown_state;
					return grown_state,level_node;
				end
			end
		end
	end	
end
--在宠物大全中，感觉选中的级别显示具体的附加属性和卡片
function CombatPetPane.UpdateTemplateLevelShow()
	local self = CombatPetPane;
    local node = CombatPetPane.selected_node;
    local provider = CombatPetHelper.GetClientProvider();
	if(node and provider)then
		local grown_state,level_node = self.GetTemplateLevelState()
		local p = provider:GetPropertiesByID(node.gsid);
		if(p and grown_state and level_node)then
			local level = level_node.level;
			if(grown_state == "junior")then
				local append_prop_level = p.append_prop_level;
				local append_card_level = p.append_card_level;

				if(append_prop_level)then
					--CombatPetPane.template_prop_selected_level = provider:Get_Props_Info(append_prop_level[level],"is_mcml",225,25,1);
					--CombatPetPane.template_card_selected_level = provider:Get_Gsid_Info(append_card_level[level]);

					CombatPetPane.template_prop_selected_level = provider:Get_Props_List(append_prop_level[level]);
					CombatPetPane.template_card_selected_level = provider:Get_Cards_List(append_card_level[level]);
				end
			elseif(grown_state == "senior")then
				local senior_append_prop_level = p.senior_append_prop_level;
				local senior_append_card_level = p.senior_append_card_level;
				--CombatPetPane.template_prop_selected_level = provider:Get_Props_Info(senior_append_prop_level[level],"is_mcml",225,25,1);
				--CombatPetPane.template_card_selected_level = provider:Get_Gsid_Info(senior_append_card_level[level]);

				CombatPetPane.template_prop_selected_level = provider:Get_Props_List(senior_append_prop_level[level]);
				CombatPetPane.template_card_selected_level = provider:Get_Cards_List(senior_append_card_level[level]);
			end

			--CombatPetPane.max_template_prop_selected_level = provider:Get_Props_Info(provider:GetTemplateMaxLevelProps(node.gsid),"is_mcml",225,25,1);
			--CombatPetPane.max_template_card_selected_level = provider:Get_Gsid_Info(provider:GetTemplateMaxLevelCards(node.gsid));

			CombatPetPane.max_template_prop_selected_level = provider:Get_Props_List(provider:GetTemplateMaxLevelProps(node.gsid));
			CombatPetPane.max_template_card_selected_level = provider:Get_Cards_List(provider:GetTemplateMaxLevelCards(node.gsid));

			CombatPetPane.prop_selected_level = provider:Get_Props_List(CombatPetPane.GetSelectedNodeProps());
			CombatPetPane.card_selected_level = provider:Get_Cards_List(CombatPetPane.GetSelectedNodeCards());
			CommonClientService.Fill_List(CombatPetPane.card_selected_level,10);
			CommonClientService.Fill_List(CombatPetPane.template_card_selected_level,10);
		end
	end	
end
--更新页面状态
function CombatPetPane.UpdateNode()
	local self = CombatPetPane;
	self.is_edit = 0;
	self.template_prop_selected_level = nil;
	self.template_card_selected_level = nil;
	self.gems_list = self.GetGems();
	if(self.pet_list)then
		table.sort(self.gems_list,function(a,b)
			if(a.gsid and b.gsid)then
				return a.gsid < b.gsid
			end
		end);
		CommonClientService.Fill_List(self.gems_list,18);
		local node = self.pet_list[self.selected_index];
		self.selected_node = node;
		local k,v;
		for  k,v in ipairs(self.pet_list)do
			v.checked = false;
		end
		if(node)then
			if(node.checked)then
				node.checked = false;
			else
				node.checked = true;
			end
		end
		local title = string.format("我的宠物(%d/%d)",self.my_pet_len or 0,#self.pet_list_templates);
		self.title = title;
		self.show_type_menu = {
			{label = title, value="mypets", selected = true, },
			--{label = string.format("宠物大全(%d)",#self.pet_list_templates), value="allpets", },
		}
		local k,v;
		for k,v in ipairs(self.show_type_menu) do
			if(v.value == self.show_type)then
				v.selected = true;
			else
				v.selected = false;
			end
		end
		local provider = CombatPetHelper.GetClientProvider();
		if(node and not provider:HasSeniorLevel(node.gsid))then
			self.show_grow_type = "junior";	
			self.show_grow_type_menu = {
				{label = "成长", value="junior", selected = true, },
			}
		else
			self.show_grow_type_menu = {
				{label = "成长", value="junior", selected = true, },
				{label = "进化", value="senior", },
			}
			if(self.show_type == "mypets")then
				local __,__,__,isfull = CombatPetPane.GetLevelInfo()				
				if(isfull)then
					self.show_grow_type = "senior";	
					self.show_grow_type_menu = {
						{label = "进化", value="senior", selected = true, },
					}	
				end
			end
		end
		local k,v;
		for k,v in ipairs(self.show_grow_type_menu) do
			if(v.value == self.show_grow_type)then
				v.selected = true;
			else
				v.selected = false;
			end
		end
		self.all_level_list = self.GetLevelList();
		self.combine_props_list = self.GetCombineList();
		self.foods_list= self.GetFoodList();
		self.UpdateTemplateLevelShow();
		if(self.page)then
			local mcmlnode = self.page:GetNode("toggle_showtype");
			if(mcmlnode)then
				mcmlnode:SetAttribute("DataSource",self.show_type_menu);
			end
			mcmlnode = self.page:GetNode("toggle_show_growtype");
			if(mcmlnode)then
				mcmlnode:SetAttribute("DataSource",self.show_grow_type_menu);
			end
			self.page:Refresh(0);
		end
	end
end
--更新所有信息
--@param show_type:"mypets" or "allpets"
--@param selected_index:
--@param show_grow_type:"junior" or "senior"
--@param bReload:ture reload all info
function CombatPetPane.Update(show_type,selected_index,show_grow_type,bReload)
	local self = CombatPetPane;
	self.show_type = show_type or "mypets";	
	self.selected_index = selected_index or 1;
	self.show_grow_type = show_grow_type or "junior";	
	if(not self.pet_list_templates)then
		self.pet_list_templates = self.SearchAllPetList();
	end
	if(self.show_type == "mypets")then
		if(bReload)then
			self.pet_list = {};
			self.pet_list_mypet = {};
			self.SearchPetList(self.nid,function(msg)
				if(msg and msg.list)then
					self.pet_list = msg.list or {};
					self.pet_list_mypet = msg.list or {};
					self.my_pet_len = msg.my_pet_len;
					self.my_pet_list = msg.my_pet_list;
				end
				self.UpdateNode();
			end)
		else
			self.UpdateNode();
		end
	else
		self.pet_list = self.pet_list_templates;
		self.UpdateNode();
	end
end
function CombatPetPane.ShowPage(nid,zorder)
	if(MyCompany.Aries.Player.IsInCombat()) then
		return;
	end
	if(CommonClientService.IsTeenVersion())then
		NPL.load("(gl)script/apps/Aries/CombatPet/CombatFollowPetPane.lua");
		local CombatFollowPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatFollowPetPane");
		CombatFollowPetPane.ShowPage();
		return
	end
	local self = CombatPetPane;
	self.nid = nid;
	-- zorder = zorder or 1;
	self.foodsWnd_visible = false;
	self.gemsWnd_visible = false;
	self.show_type_menu = {
		{label = "我的宠物", value="mypets", selected = true, },
		{label = "宠物大全", value="allpets", },
	}
	self.show_grow_type_menu = {
		{label = "成长", value="junior", selected = true, },
		{label = "进化", value="senior", },
	}
	local params;
	if(CommonClientService.IsTeenVersion())then
		local list = CombatPetPane.GetMyPetList_Memory();
		if(not list or (#list == 0))then
			_guihelper.MessageBox("你还没有宠物！");
			return
		end
		params = {
			url = "script/apps/Aries/CombatPet/CombatPetPane.teen.html", 
			name = "CombatPetPane.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			zorder = zorder,
			directPosition = true,
				align = "_ct",
				x = -800/2,
				y = -470/2,
				width = 800,
				height = 470,
		}
		System.App.Commands.Call("File.MCMLWindowFrame", params);	
		CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, callback = CombatPetPane.HookHandler, 
				hookName = "Hook_CombatPetPane", appName = "Aries", wndName = "main"});	
		if(params._page) then
			params._page.OnClose = function(bDestroy)
				Dock.OnClose("CombatPetPane.ShowPage")
				CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Hook_CombatPetPane", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
			end
		end
	else
		params = {
			url = "script/apps/Aries/CombatPet/CombatPetPane.xml", 
			name = "CombatPetPane.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			bToggleShowHide = true,
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			zorder = zorder,
			directPosition = true,
				align = "_ct",
				x = -627/2,
				y = -485/2,
				width = 627,
				height = 485,
		}
		System.App.Commands.Call("File.MCMLWindowFrame", params);	
	end
	
	self.Update(nil,nil,nil,true);
end
--获取用户宠物列表
--[[
	return list = {
		{
			gsid = gsid,
			assetfile = assetfile,
			icon = icon,
			name = name,
			exp = exp,
			is_combat_pet = is_combat_pet,
			isvip = isvip,
			priority = priority,
			description = description,
			cur_feed_num = cur_feed_num,
			level = level,
			cur_exp = cur_exp,
			total_exp = total_exp,
			isfull = isfull,
			is_top_level = is_top_level,
			req_magic_level = req_magic_level,
			quality_level = quality_level,
		},
		...
	}
--]]
function CombatPetPane.GetMyPetList_Memory(nid)
	local self = CombatPetPane;
	nid = nid or Map3DSystem.User.nid;
	local cnt = ItemManager.GetFollowPetCount(nid);
	LOG.std("","info","CombatPet cnt", cnt);
	local i;
	local list = {};
	local map = {};
	local hide_map = HomeLandGateway.LoadMyPetLocalShowInfo();
	local serverdate = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");

	local provider = CombatPetHelper.GetClientProvider();
	for i = 1, cnt do
		local item = ItemManager.GetFollowPetByOrder(nid, i);
		if(item)then
			local gsid = item.gsid;
			local priority = item.obtaintime;
			local name = "";
			local color_name = "";
			if(item.GetName_client)then
				name = item:GetName_client();
			end
			local exp = 0;
			local cur_feed_num = 0;
			local gem_gsid;
			local name_cnt = 0;
			if(item.GetServerData)then
				local serverdata = item:GetServerData();
				exp = serverdata.exp;
				cur_feed_num = serverdata.cur_feed_num;
				name_cnt = serverdata.name_cnt or name_cnt;--改名次数
				color_name = provider:BuildColorName(name,gsid,exp);
				local cur_feed_date = serverdata.cur_feed_date;
				--镶嵌的宝石
				gem_gsid = serverdata.gem_gsid;
				if(not cur_feed_date)then
					cur_feed_num = 0;
				else
					--如果不是在同一天
					if(cur_feed_date ~= serverdate)then
						cur_feed_num = 0;
					end
				end
			end
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
			local description;
			local assetfile;
			local icon;
			local special_ability = false;
			local special_string = "";
			if(gsItem) then
				if(gsItem.template.stats[14] == 1) then
					special_ability = true;
					special_string = System.Item.Item_FollowPet.GetSpecialAbilityBtnString(gsid) or "";
				end
				assetfile = gsItem.assetfile;
				icon = gsItem.icon;
				description = gsItem.template.description;
			end
			local is_combat_pet = 0;
			local is_combat,isvip;
			local req_magic_level = -1;
			local quality_level = 0;
			local quality = 0;--品质
			local senior_quality = 0;--进化后的品质
			local level,cur_exp,total_exp,isfull;
			local pIndex = 100000;
			local has_senior_level = 0;
			if(provider)then
				is_combat,isvip = provider:IsCombatPet(gsid);
				level,cur_exp,total_exp,isfull = provider:GetLevelInfo(gsid,exp or 0);
				if(is_combat)then
					is_combat_pet = 1;
				end
				if(isfull and provider:HasSeniorLevel(gsid))then
					level,cur_exp,total_exp,isfull = provider:GetSeniorLevelInfo(gsid,exp or 0);
				end
				if(provider:HasSeniorLevel(gsid))then
					has_senior_level = 1;
				end
				local p = provider:GetPropertiesByID(gsid);
				if(p)then
					pIndex = p.pIndex or 100000;
					req_magic_level = p.req_magic_level;
					quality_level = p.quality_level;
				end
			end
			local is_top_level = 0;
			local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
			-- top level if is followed user
			if(item and item.guid > 0 and item.gsid == gsid) then
				is_top_level = 1;
			end

			local order = self.GetOrder(gsid) or 5000;
			local hide_in_homeland = hide_map[gsid];
			local node = {
				gsid = gsid,
				pIndex = pIndex,
				assetfile = assetfile,
				icon = icon,
				name = name,
				color_name = color_name,
				exp = exp,
				is_combat_pet = is_combat_pet,
				isvip = isvip,
				priority = priority,
				description = description,
				cur_feed_num = cur_feed_num,
				level = level,
				cur_exp = cur_exp,
				total_exp = total_exp,
				isfull = isfull,
				is_top_level = is_top_level,
				req_magic_level = req_magic_level,
				quality_level = quality_level,
				has_senior_level = has_senior_level,
				name_cnt = name_cnt,
				quality = quality,
				senior_quality = senior_quality,
				--儿童版使用
				order = order,
				hide_in_homeland = hide_in_homeland,
				gem_gsid = gem_gsid,
				special_string = special_string,
				special_ability = special_ability,

			};
			table.insert(list,node);
			map[gsid] = node;
		end
		
	end
	return list,map;
end
--返回我的宠物 经过排序的
--[[
local node = {
				gsid = gsid,
				pIndex = pIndex,
				assetfile = assetfile,
				icon = icon,
				name = name,
				exp = exp,
				is_combat_pet = is_combat_pet,
				isvip = isvip,
				priority = priority,
				description = description,
				cur_feed_num = cur_feed_num,
				level = level,
				cur_exp = cur_exp,
				total_exp = total_exp,
				isfull = isfull,
				is_top_level = is_top_level,
				req_magic_level = req_magic_level,
				quality_level = quality_level,
				has_senior_level = has_senior_level,
				--儿童版使用
				order = order,
				hide_in_homeland = hide_in_homeland,
				gem_gsid = gem_gsid,
				special_string = special_string,
				special_ability = special_ability,
			};
--]]
function CombatPetPane.GetPetList_Sorted(nid)
	local self = CombatPetPane;
	local all_pets = self.GetAllPetList_Memory(nid) or {};
	local result = {};
	local k,v;
	for k,v in ipairs(all_pets) do
		if(v.is_my_pet and v.is_my_pet == 1)then
			table.insert(result,v);
		end
	end
	return result;
end
--获取所有的宠物 已经拥有的排在上面
--return result_list,result_map,my_pet_len,my_pet_list
function CombatPetPane.GetAllPetList_Memory(nid)
	local self = CombatPetPane;
	local result_list = {};
	local result_map = {};

	local list,map = self.GetMyPetList_Memory(nid);
	local pet_templates = self.SearchAllPetList();
	local k,v;
	for k,v in ipairs(pet_templates) do
		local gsid = v.gsid;
		local pet_node;
		if(map[gsid])then
			pet_node = map[gsid];
			pet_node.is_my_pet = 1;
		else
			pet_node = v;
			--排序用
			pet_node.is_top_level = 0;
			pet_node.is_my_pet = 0;
			pet_node.priority = "";
		end
		table.insert(result_list,pet_node);
		result_map[gsid] = pet_node;
	end
	if(CommonClientService.IsKidsVersion())then
		table.sort(result_list,function(a,b)
			if(a.is_my_pet == 0) then
				if(a.gsid == 10195 or a.gsid == 10196 or a.gsid == 10197) then
					return false;
				end
			end
			if(b.is_my_pet == 0) then
				if(b.gsid == 10195 or b.gsid == 10196 or b.gsid == 10197) then
					return true;
				end
			end
			--if(a.gsid == 10195 or a.gsid == 10196 or a.gsid == 10197) then
				--return false;
			--elseif(b.gsid == 10195 or b.gsid == 10196 or b.gsid == 10197) then
				--return true;
			--end
			return (  
			(a.is_my_pet > b.is_my_pet) 
			or (a.is_my_pet == b.is_my_pet and a.is_combat_pet > b.is_combat_pet) 
			or (a.is_my_pet == b.is_my_pet and a.is_combat_pet == b.is_combat_pet and a.order < b.order) 
			or (a.is_my_pet == b.is_my_pet and a.is_combat_pet == b.is_combat_pet and a.order == b.order and a.priority > b.priority ) 
			or (a.is_my_pet == b.is_my_pet and a.is_combat_pet == b.is_combat_pet and a.order == b.order and a.priority == b.priority and a.gsid > b.gsid) 
			);
		end);
	else
		table.sort(result_list,function(a,b)
			return ( (a.is_top_level > b.is_top_level)  
			or (a.is_top_level == b.is_top_level and a.is_my_pet > b.is_my_pet) 
			or (a.is_top_level == b.is_top_level and a.is_my_pet == b.is_my_pet and a.has_senior_level > b.has_senior_level) 
			or (a.is_top_level == b.is_top_level and a.is_my_pet == b.is_my_pet and a.has_senior_level == b.has_senior_level and a.quality_level > b.quality_level) 
			or (a.is_top_level == b.is_top_level and a.is_my_pet == b.is_my_pet and a.has_senior_level == b.has_senior_level and a.quality_level == b.quality_level and a.gsid < b.gsid) 
			);
		end); 

	end
	return result_list,result_map,#list,list;
end
--查找我的宠物
function CombatPetPane.SearchPetList(nid,callbackFunc)
	local self = CombatPetPane;
	nid = nid or Map3DSystem.User.nid;
	LOG.std("","info","before CombatPetPane.SearchPetList", nid);
	local serverdate = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");

	ItemManager.LoadPetsInHomeland(nid, function(msg)
		LOG.std("","info","CombatPetPane.SearchPetList", msg);
		
		local list,__,my_pet_len,my_pet_list = CombatPetPane.GetAllPetList_Memory(nid);
		if(callbackFunc)then
			callbackFunc({list = list,my_pet_len = my_pet_len,my_pet_list = my_pet_list,});
		end
    
	end, "access plus 30 seconds");
end
--查找宠物大全
function CombatPetPane.SearchAllPetList()
	local self = CombatPetPane;
	local gsid;
	local list = {};
	for gsid = self.search_start_gsid,self.search_end_gsid do
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem) then
			local assetfile = gsItem.assetfile;
			local name = gsItem.template.name;
			local description = gsItem.template.description;
			local icon = gsItem.icon;
			

			local provider = CombatPetHelper.GetClientProvider();
			local is_combat_pet = 0;
			local req_magic_level = -1;
			local quality_level = 0;
			local is_combat,isvip;
			local has_senior_level = 0;
			if(provider)then
				is_combat,isvip = provider:IsCombatPet(gsid);
				if(is_combat)then
					is_combat_pet = 1;
				end
				if(provider:HasSeniorLevel(gsid))then
					has_senior_level = 1;
				end
			end
			local p = provider:GetPropertiesByID(gsid);
			local pIndex = 100000;
			if(p)then
				pIndex = p.pIndex or 100000;
				req_magic_level = p.req_magic_level or -1;
				quality_level = p.quality_level;
			end
			local can_push = false;
			if(gsItem.template.bagfamily == 10010)then
				can_push = true;
			end
			--已配置文件为准，只显示配置文件里面的宠物
			if(CommonClientService.IsTeenVersion())then
				can_push = provider:HasPet(gsid);
			end
			if(can_push)then
				table.insert(list,{
					gsid = gsid,
					assetfile = assetfile,
					name = name,
					icon = icon,
					is_combat_pet = is_combat_pet,
					isvip = isvip,
					description = description,
					pIndex = pIndex,
					req_magic_level = req_magic_level,
					quality_level = quality_level,
					has_senior_level = has_senior_level,
					--儿童版使用
					order = 100000,
				});
			end
		end
	end
	--table.sort(list, function(a, b)
		--return (a.pIndex < b.pIndex);
	--end);
	return list;
end
--附加属性列表
function CombatPetPane.GetCombineList()
	local self = CombatPetPane;
	local node = self.selected_node;
	if(node)then
		local gsid = node.gsid;
		local provider = CombatPetHelper.GetClientProvider();
		local p = provider:GetPropertiesByID(gsid);
		if(p)then
			local combine_props_list;
			if(self.show_grow_type == "junior")then
				combine_props_list = p.combine_props_list or {};
			else
				combine_props_list = p.senior_combine_props_list or {};
			end
			table.sort(combine_props_list,function(a,b)
				return a.level > b.level;
			end);
			return combine_props_list;
		end
	end
end
function CombatPetPane.UpdateTemplateFoodList()
	local self = CombatPetPane;
	self.foods_list = self.GetFoodList();
end
--食物列表
function CombatPetPane.GetFoodList()
	local self = CombatPetPane;
	local node = self.selected_node;
	local provider = CombatPetHelper.GetClientProvider();
	if(node)then
		local gsid = node.gsid;
		local p = provider:GetPropertiesByID(gsid);

		local food_list = {};
		local pagesize = 6;
		local grown_state;

		if(self.show_type == "allpets")then
			grown_state = self.GetTemplateLevelState()
		else
			grown_state = self.GetSelectedNodeGrownState()
		end
		if(grown_state == "junior")then
			food_list = {
				{gsid = 17172, can_buy = true,},
				{gsid = 17185, can_buy = true,},
				{gsid = 17211, can_buy = true,},
			};
		elseif(grown_state == "senior")then
			if(p.senior_gsid)then
				local k,v;
				for k,v in ipairs(p.senior_gsid) do
					table.insert(food_list,{gsid = v});
				end
			end	
		end
		if(self.show_type == "mypets")then
			local k,v;
			for k,v in ipairs(food_list) do
				local __,guid = hasGSItem(v.gsid);
				v.guid = guid;
			end
		end
		local count = #food_list;
		local displaycount = math.ceil(count / pagesize) * pagesize;

		if(count == 0 )then
			displaycount = pagesize;
		end
		local i;
		for i = count + 1, displaycount do
			food_list[i] = { gsid = nil,guid = nil};
		end
		return food_list;
	end
end
--改名回调
function CombatPetPane.DoChangeName_Handler(msg)
    CombatPetPane.is_edit = 0;
	CombatPetPane.OnRefresh();
	NPL.load("(gl)script/ide/timer.lua");
	if(not CombatPetPane.name_timer)then
		CombatPetPane.name_timer = commonlib.Timer:new({callbackFunc = function(timer)
			ItemManager.RefreshMyself();
		end})
	end
	CombatPetPane.name_timer:Change(2000, nil);
end
--喂食回调
function CombatPetPane.DoFeed_Handler(msg)
	local self = CombatPetPane;
	if(not msg or not msg.food_gsid)then return end
	local food_gsid = msg.food_gsid;
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(food_gsid);
	local provider = CombatPetHelper.GetClientProvider();

	if(gsItem)then
		local fruit_name = gsItem.template.name;
		local stats = gsItem.template.stats;
		local pet_gsid = msg.pet_gsid;
		local add_exp = msg.add_exp or 0;
		local exp = msg.exp or 0;
		if(pet_gsid and add_exp >= 0)then
			ItemManager.GetItemsInBag(12, "", function(msg)
				ItemManager.GetItemsInBag(10010, "", function(msg)
					self.OnRefresh();

					local gsItem = ItemManager.GetGlobalStoreItemInMemory(pet_gsid);
					if(not gsItem) then return end
					local pet_name = gsItem.template.name;
					local label = "经验值";
					if(provider:IsSeniorFoodGsid(pet_gsid,food_gsid))then
						label = "进化值";
					end
					local s = string.format([[你的战宠<span style="color:#ffffff">[%s]</span>吃掉1个<span style="color:#ffffff">[%s]</span>获得了%d%s。]],pet_name,fruit_name,add_exp,label);
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
					MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"},79019)
					self.UpdateExp(pet_gsid,exp);
				end, "access plus 0 minutes");
			end, "access plus 0 minutes");
		end
	end
end
function CombatPetPane.OnRefresh()
	local self = CombatPetPane;
	self.Update(self.show_type,self.selected_index,self.show_grow_type,true)
end
function CombatPetPane.HookHandler(nCode, appName, msg, value)
	local self = CombatPetPane;
	if(msg.action_type == "post_pe_slot_PageRefresh")then
		self.OnRefresh();
	end
	return nCode;
end
--获取成长等级列表 包括junior and senior 两个阶段
--[[
从高到低排序
	return list = {
		{ checked = true, p_level = p_level,level = level,grown_state = "senior",},
		{p_level = p_level,level = level,grown_state = "junior",},
	}
]]
function CombatPetPane.GetLevelList()
	local self = CombatPetPane;
	local node = self.selected_node;
	local provider = CombatPetHelper.GetClientProvider();
    if(node and provider)then
		local gsid = node.gsid;
        local p = provider:GetPropertiesByID(gsid);
		if(p)then
			local result = {};
			local exp_level_list = p.exp_level_list;
			local senior_exp_level_list = p.senior_exp_level_list;
			local p_level = 0;
			if(exp_level_list)then
				local k,v;
				for k,v in ipairs(exp_level_list) do
					local level = v.level;
					local level_label = v.level-1;
					local tooltip = string.format("成长:%d级",level_label);
					
					table.insert(result,{
						text = tooltip, value = (p_level + 1), p_level = p_level,level = level, level_label = level_label, grown_state = "junior",tooltip = tooltip,
					});
					p_level = p_level + 1;

				end
			end
			if(senior_exp_level_list)then
				local k,v;
				for k,v in ipairs(senior_exp_level_list) do
					local level = v.level;
					local level_label = v.level-1;
					local tooltip = string.format("进化:%d级",level_label);
					table.insert(result,{
						text = tooltip, value = (p_level + 1), p_level = p_level,level = level, level_label = level_label, grown_state = "senior",tooltip = tooltip,
					});
					p_level = p_level + 1;
				end
			end
			--table.sort(result,function(a,b)
				--return a.p_level > b.p_level;
			--end);
			local len = #result;
			if(len >0)then
				result[len].selected = "true";
			end
			return result;
		end
	end
end

--返回我的宠物 成长阶段 "junior" or "senior"
function CombatPetPane.GetSelectedNodeGrownState()
    local state = "junior"
    local node = CombatPetPane.selected_node;
    local provider = CombatPetHelper.GetClientProvider();
    if(provider and node)then
        if(provider:Locate_SeniorLevel(node.gsid,node.exp))then
            state = "senior"
        end
    end
    return state;
end
function CombatPetPane.GetSelectedNodeLevel()
    local node = CombatPetPane.selected_node;
    local provider = CombatPetHelper.GetClientProvider();
    if(provider and node)then
        local gsid = node.gsid;
        local p = provider:GetPropertiesByID(gsid);
        if(p)then
			local level,cur_exp,total_exp,isfull = provider:GetLevelInfo(gsid,node.exp or 0);
            if(isfull and provider:HasSeniorLevel(gsid))then
				level,cur_exp,total_exp,isfull = provider:GetSeniorLevelInfo(gsid,node.exp or 0);
			end
			--TODO:最高级索引错误
			if(isfull)then
				level = level - 1;
			end
            return level,isfull;
        end
    end
end
function CombatPetPane.GetSelectedNodeProps()
    local node = CombatPetPane.selected_node;
    local provider = CombatPetHelper.GetClientProvider();
    if(provider and node)then
		return provider:GetCurLevelProps(node.gsid,node.exp);
    end
end
function CombatPetPane.GetSelectedNodeCards()
    local node = CombatPetPane.selected_node;
    local provider = CombatPetHelper.GetClientProvider();
    if(provider and node)then
		return provider:GetCurLevelCards(node.gsid,node.exp);
    end
end
function CombatPetPane.SwapToTop(index,pet_list)
	local self = CombatPetPane;
	if(not index or not pet_list)then return end	
	local node = pet_list[index];
	if(node)then

		local sort_list = self.GetOrderList();
		local k,gsid;
		for k,gsid in ipairs(sort_list) do
			if(gsid == node.gsid)then
				table.remove(sort_list,k);
				break;
			end
		end
		table.insert(sort_list,node.gsid);
		CombatPetPane.SaveOrderList(sort_list)
	end
end
function CombatPetPane.GetOrderList()
	local nid = Map3DSystem.User.nid;
	local key = string.format("CombatPetPane.Order_%s",tostring(nid));
	local list = MyCompany.Aries.Player.LoadLocalData(key, {});
	return list;
end
function CombatPetPane.SaveOrderList(list)
	if(not list)then return end
	local self = CombatPetPane;
	local nid = Map3DSystem.User.nid;
	local key = string.format("CombatPetPane.Order_%s",tostring(nid));
	MyCompany.Aries.Player.SaveLocalData(key, list);
end
-- get value of order show in combatpet list
function CombatPetPane.GetOrder(gsid)
	local self = CombatPetPane;
	if(not gsid)then return end

	local order_list = self.GetOrderList();
	local max_cnt = 5000;
	local k,v;
	for k,v in ipairs(order_list) do
		if(v == gsid)then
			return max_cnt - k;
		end
	end 
	return max_cnt;
end

function CombatPetPane.SetValue_PetLocalShowInfo(gsid,v)
	HomeLandGateway.SetValue_PetLocalShowInfo(gsid,v);
end
function CombatPetPane.RefreshBagAfterAttachGem()
	local self = CombatPetPane;
	ItemManager.GetItemsInBag(12, "", function(msg)
		ItemManager.GetItemsInBag(10010, "", function(msg)
			self.OnRefresh();
		end, "access plus 0 minutes");
	end, "access plus 0 minutes");
end
function CombatPetPane.AttachGem_Handler(msg)
	local self = CombatPetPane;
	if(not msg)then return end
	local pet_gsid = msg.pet_gsid;
	local gem_gsid = msg.gem_gsid;
	CombatPetPane.RefreshBagAfterAttachGem();
end
function CombatPetPane.UnAttachGem_Handler(msg)
	local self = CombatPetPane;
	if(not msg)then return end
	local pet_gsid = msg.pet_gsid;
	local gem_gsid = msg.gem_gsid;
	if(gem_gsid)then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gem_gsid);
		local name = gsItem.template.name;
		local s = string.format("恭喜你成功拆除了【%s】！",name);
		_guihelper.MessageBox(s);
	end
	CombatPetPane.RefreshBagAfterAttachGem();
end
--获取宝石列表
function CombatPetPane.GetGems()
	local bag = 12;
	local count = ItemManager.GetItemCountInBag(bag);
	local i;
	local result = {};
	local provider = CombatPetHelper.GetClientProvider();
	local valid_stats_map = provider.valid_stats_map or {};
	for i = 1, count do
		local item = ItemManager.GetItemByBagAndOrder(bag, i);
		if(item ~= nil) then
			local gsid = item.gsid;
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
			if(gsItem)then
				local gem_level = gsItem.template.stats[41] or 0;
				if(gem_level > 0)then
					local k,__;
					for k,__ in pairs(valid_stats_map) do
						local stat_value = gsItem.template.stats[k] or 0;
						if(stat_value > 0 and provider:IsValidStat_AttachGem(k))then
							table.insert(result,{gem_level = gem_level,guid = item.guid,gsid = item.gsid});
							break;
						end
					end
				end
			end
		end
	end
	table.sort(result,function(a,b)
		return a.gem_level < b.gem_level;
	end);
	return result;
end
function CombatPetPane.DS_Func_Items_gems_list(index)
	local self = CombatPetPane;
	if(not self.gems_list)then return 0 end
	if(index == nil) then
		return #(self.gems_list);
	else
		return self.gems_list[index];
	end
end
function CombatPetPane.IsFollowing(gsid)
	if(not gsid)then return end
	local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
    if(item and item.guid > 0 and item.gsid == gsid) then
        return true;
    end
end
function CombatPetPane.DoToggleHome(gsid)
	if(not gsid)then return end
	local bHas, guid = hasGSItem(gsid);
	if(bHas == true) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
            if(System.options.version == "teen") then
				item:OnClick("left", nil, nil, true); -- true for bShowStatsDiff
			else
				item:OnClick("left");
			end
		end
	end
end

function CombatPetPane.CombatPetAdvanced(exid)
	NPL.load("(gl)script/kids/3DMapSystemItem/PowerExtendedCost.lua");
	local PowerExtendedCost = commonlib.gettable("Map3DSystem.Item.PowerExtendedCost");
	PowerExtendedCost.LoadFromConfig();

	local ex_template = PowerExtendedCost.GetExtendedCostTemplateInMemory(exid);

	local attr = ex_template.attr;

	local from_pet_gsid = attr.from_pet_gsid;
	local from_others = attr.from_others;
	local need_pet_exp = attr.need_pet_exp;
	local to_pet_gsid = attr.to_pet_gsid;

	local info = string.format("宠物<pe:item gsid='%d' style='width:24px;height:24px;' isclickable='false'/>满级后可以进阶为<pe:item gsid='%d' style='width:24px;height:24px;' isclickable='false'/>，获得更强能力。<br/>",from_pet_gsid,to_pet_gsid);
	local fail_word = nil;

	local bHas, from_pet_guid = ItemManager.IfOwnGSItem(from_pet_gsid);

	if(bHas) then
		local item = ItemManager.GetItemByGUID(from_pet_guid);
		if(item and item.serverdata) then
			local params = item.serverdata;
			if(params) then
				if((params.exp or 0) < need_pet_exp) then
					--_guihelper.MessageBox(string.format("宠物<pe:item gsid='%d' style='width:24px;height:24px;' isclickable='false'/>经验不足，不能进阶！",from_pet_gsid))

					fail_word = fail_word or string.format("宠物<pe:item gsid='%d' style='width:24px;height:24px;' isclickable='false'/>经验不足，不能进阶！",from_pet_gsid);
					--return;
				end
			end
		end
	else
		--_guihelper.MessageBox(string.format("你还没有宠物<pe:item gsid='%d' style='width:24px;height:24px;' isclickable='false'/>！",from_pet_gsid))
		--return;
		fail_word = fail_word or string.format("你还没有宠物<pe:item gsid='%d' style='width:24px;height:24px;' isclickable='false'/>！",from_pet_gsid);
	end

	info = info.."进阶需消耗";
	for i = 1,#from_others do
		local item = from_others[i];
		local gsid,number = item.gsid,item.number;
		info = info..string.format("%d个<pe:item gsid='%d' style='width:24px;height:24px;' isclickable='false'/>",number,gsid);

		local bHas, _, _, copies = ItemManager.IfOwnGSItem(gsid);
		if(bHas and copies >= number) then
			
		else
			fail_word = fail_word or string.format("宠物进阶需要的<pe:item gsid='%d' style='width:24px;height:24px;' isclickable='false'/>不足，不能进阶！",gsid)
			--_guihelper.MessageBox(string.format("宠物进阶需要的<pe:item gsid='%d' style='width:24px;height:24px;' isclickable='false'/>不足，不能进阶！",gsid))
			--return;
		end
	end
	info = info.."<br/>你确认要现在进阶吗";
	info = info.."<br/>（温馨提示：宠物进阶后等级和宝石将会被清空）";
	
	local bHas = ItemManager.IfOwnGSItem(to_pet_gsid);
	if(bHas) then
		fail_word = fail_word or string.format("你已经获得宠物<pe:item gsid='%d' style='width:24px;height:24px;' isclickable='false'/>！",to_pet_gsid);
		--_guihelper.MessageBox(string.format("你已经获得宠物<pe:item gsid='%d' style='width:24px;height:24px;' isclickable='false'/>！",to_pet_gsid))
		--return;
	end

	_guihelper.MessageBox(info,function(res)
		if(res and res == _guihelper.DialogResult.Yes) then
			if(fail_word) then
				_guihelper.MessageBox(fail_word);
			else
				System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="PowerExtendedCost", params={exid = exid}});
			end
		end
	end, _guihelper.MessageBoxButtons.YesNo);
end

function CombatPetPane.GetFollowPetDS()
	local CardPickerFollowPetHistoryList = MsgHandler.CardPickerFollowPetHistoryList;
	local list_pets_sorted = CombatPetPane.GetPetList_Sorted(nil);
	local order_pets = {};

	local _, node;
	for _, node in ipairs(list_pets_sorted) do
		if(node and node.gsid) then
			order_pets[node.gsid] = _;
		end
	end

	local cnt = ItemManager.GetFollowPetCount();
	local i;
	local list = {};
	for i = 1, cnt do
		local item = ItemManager.GetFollowPetByOrder(nil, i);
		if(item)then
			local gsid = item.gsid;
			local guid = item.guid;
			local priority = item.obtaintime;
			local name = "";
			if(item.GetName_client)then
				name = item:GetName_client();
			end
			local exp = 0;
			local cur_feed_num = 0;
			if(item.GetServerData)then
				local serverdata = item:GetServerData();
				exp = serverdata.exp;
				cur_feed_num = serverdata.cur_feed_num;
			end
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
			local description;
			local assetfile;
			if(gsItem) then
				if(gsItem.template.stats[14] == 1) then
					--priority = "9_"..priority;
				end
				assetfile = gsItem.assetfile;
				description = gsItem.template.description;
			end
			local provider = CombatPetHelper.GetClientProvider();
			local is_combat_pet = 0;
			local is_combat,isvip;
			local req_magic_level = -1;
			local level,cur_exp,total_exp,isfull;
			if(provider)then
				is_combat,isvip = provider:IsCombatPet(gsid);
				level,cur_exp,total_exp,isfull = provider:GetLevelInfo(gsid,exp);
				if(is_combat)then
					is_combat_pet = 1;
				end

				local p = provider:GetPropertiesByID(gsid);
				if(p)then
					req_magic_level = p.req_magic_level;
				end
			end
			local is_top_level = 0;
			local defaultvalue = 1 + #list;
			--local order = CombatPetPage.GetOrder(gsid,defaultvalue);

			local order = order_pets[gsid] or defaultvalue;
        
			if(is_combat_pet == 1) then
				table.insert(list,{
					gsid = gsid,
					guid = guid,
					assetfile = assetfile,
					name = name,
					exp = exp,
					is_combat_pet = is_combat_pet,
					isvip = isvip,
					priority = priority,
					description = description,
					cur_feed_num = cur_feed_num,
					level = level,
					cur_exp = cur_exp,
					total_exp = total_exp,
					isfull = isfull,
					is_top_level = is_top_level,
					req_magic_level = req_magic_level,
					order = order,--order can be changed by user

					bAvailable = not CardPickerFollowPetHistoryList[guid],
				});
			end
		end
		
	end
	
	table.sort(list, function(a, b)
		return 
				((a.is_combat_pet > b.is_combat_pet))
				or ((a.is_combat_pet == b.is_combat_pet) and (a.is_top_level > b.is_top_level))
				or ((a.is_combat_pet == b.is_combat_pet) and (a.is_top_level == b.is_top_level) and (a.order < b.order))
	end);
	return list;
end

--local follow_pet_list = nil;
function CombatPetPane.DS_Func_FollowPets(index)
	local list = CombatPetPane.GetFollowPetDS();
    if(index == nil) then
        return #list;
    else
        return list[index];
    end
end