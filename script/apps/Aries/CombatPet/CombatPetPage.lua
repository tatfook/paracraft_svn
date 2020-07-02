--[[
Title: CombatPetPage
Author(s): Leio 
Date: 2010/12/14
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetPage.lua");
local CombatPetPage = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPage");
CombatPetPage.ShowPage(nid);
CombatPetPage.DoRadio(value)

local t = {
	{index = "2010-12-15"},
	{index = "2010-12-14"},
	{index = "2010-12-12"},
};
table.sort(t,function(a,b)
	return a.index > b.index;
end);
commonlib.echo(t);
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
local HomeLandGateway = commonlib.gettable("Map3DSystem.App.HomeLand.HomeLandGateway");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetFoodsPage.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetHelper.lua");
local ItemManager = System.Item.ItemManager;
local CombatPetHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetHelper");
local CombatPetPage = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPage");
CombatPetPage.must_in_homeland = {
	10112,--蜗牛
	10113,--飞飞
	10115,--松树
	10130,--燕子
	10129,--元宵
}
CombatPetPage.all_gsids = {10101,10999}
CombatPetPage.is_edit = 0;
--强制显示combat state,在进行战斗的时候，可以调出宠物面板
--任意选择出战的宠物，这个时候需要屏蔽额外的按钮，只显示"出战"按钮
CombatPetPage.is_combat_state = false;
--1 我的宠物 2 战宠大全
CombatPetPage.state = 1;
CombatPetPage.selected_pet_index = nil;
CombatPetPage.pets_datasource = nil;
CombatPetPage.common_pets_datasource = nil;
function CombatPetPage.Init()
	local self = CombatPetPage;
	self.page = document:GetPageCtrl();
end
function CombatPetPage.ClosePage()
	local self = CombatPetPage;
	if(self.page)then
		self.page:CloseWindow();
	end
end
function CombatPetPage.DoRefresh()
	local self = CombatPetPage;
	if(self.page)then
		self.page:Refresh(0);
	end
end
function CombatPetPage.DoClick(index)
	local self = CombatPetPage;
	index = tonumber(index);
	self.selected_pet_index = index;
	self.is_edit = 0;
	self.OnShowModel();
	if(self.page)then
		self.page:Refresh(0);
	end
end
function CombatPetPage.GetLevel()
	local self = CombatPetPage;
    local data = self.GetDataSource();
    if(data and self.selected_pet_index)then
        local pet = data[self.selected_pet_index];
        if(pet)then
            local gsid = pet.gsid;
            local exp = pet.exp;
            local provider = CombatPetHelper.GetClientProvider();
		    if(provider)then
			    local level,cur_exp,total_exp,isfull = provider:GetLevelInfo(gsid,exp or 0);
                return level,cur_exp,total_exp,isfull;
            end
        end
    end
end
function CombatPetPage.GetDataSource()
	local self = CombatPetPage;
	local data;
	if(self.state == 1)then
		data = self.pets_datasource;
	else
		data = self.common_pets_datasource;
	end
	return data;
end
function CombatPetPage.OnShowModel()
	local self = CombatPetPage;
	local data = self.GetDataSource();
	if(data and self.selected_pet_index)then
		local pet = data[self.selected_pet_index];
		if(pet and self.page)then
			local gsid = pet.gsid;
			--检查战宠喂食的日期
			QuestClientLogics.Do_CheckDate_FollowPet(gsid);
			--model
			local asset = Map3DSystem.App.Assets.asset:new({filename = pet.assetfile})
			local objParams = asset:getModelParams()
			if(objParams ~= nil) then
				objParams.facing = 0;
				if(gsid == 10135)then
					objParams.scaling = 0.5;
				elseif(gsid == 10137)then
					--objParams.scaling = 0.6;
				end
				if(pet.is_combat_pet == 1)then
					local canvasCtl = self.page:FindControl("FollowPetCanvas_1");
					if(canvasCtl) then
						canvasCtl:ShowModel(objParams);
					end
					self.page:SetValue("FollowPetCanvas_1", commonlib.serialize_compact(objParams));
				else
					local canvasCtl = self.page:FindControl("FollowPetCanvas_2");
					if(canvasCtl) then
						canvasCtl:ShowModel(objParams);
					end
					self.page:SetValue("FollowPetCanvas_2", commonlib.serialize_compact(objParams));
				end
			end
			--exp
			local level,cur_exp,total_exp,isfull = self.GetLevel();
			if(cur_exp and total_exp)then
				if(self.page)then
					local mcmlNode = self.page:GetNode("progress");
					if(mcmlNode)then
						mcmlNode:SetAttribute("Value", cur_exp);
						mcmlNode:SetAttribute("Maximum", total_exp);
					end
				end
			end
			-- normal button, toggle home and follow
			local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
			local toggle_btn_bg = "Texture/Aries/Profile/SendMeHome_32bits.png;0 0 153 49";
			if(item and item.guid > 0 and item.gsid == gsid) then
				toggle_btn_bg = "Texture/Aries/Profile/SendMeHome_32bits.png;0 0 153 49";
			else
				toggle_btn_bg = "Texture/Aries/Profile/FollowMe_32bits.png;0 0 153 49";
			end
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
			if(gsItem and self.state == 1 and self.nid == Map3DSystem.User.nid)then
				--如果是需要战宠出战(在战斗是调用),仅显示出战按钮
				if(self.is_combat_state)then
						self.page:SetUIBackground("btn_special", "");
						self.page:SetUIEnabled("btn_special", false);
						self.page:SetUIBackground("btn_togglehome_single", "Texture/Aries/Common/FightForMe_32bits.png;0 0 153 49");
						self.page:SetUIEnabled("btn_togglehome_single", true);
						self.page:SetUIBackground("btn_togglehome", "");
						self.page:SetUIEnabled("btn_togglehome", false);
				else
					-- check if the gsitem has special ability
					if(gsItem.template.stats[14] == 1) then
						local special_bg = System.Item.Item_FollowPet.GetSpecialAbilityBtnBackground(gsid) or "";
						self.page:SetUIBackground("btn_special", special_bg);
						self.page:SetUIEnabled("btn_special", true);
						self.page:SetUIBackground("btn_togglehome_single", "");
						self.page:SetUIEnabled("btn_togglehome_single", false);
						self.page:SetUIBackground("btn_togglehome", toggle_btn_bg);
						self.page:SetUIEnabled("btn_togglehome", true);
					else
						self.page:SetUIBackground("btn_special", "");
						self.page:SetUIEnabled("btn_special", false);
						self.page:SetUIBackground("btn_togglehome_single", toggle_btn_bg);
						self.page:SetUIEnabled("btn_togglehome_single", true);
						self.page:SetUIBackground("btn_togglehome", "");
						self.page:SetUIEnabled("btn_togglehome", false);
					end
				end
			end
			if(pet.is_combat_pet == 1)then
				self.page:SetUIBackground("btn_feedpet", "Texture/Aries/NPCs/CombatPet/do_feed_32bits.png;0 0 98 46");
				self.page:SetUIEnabled("btn_feedpet", true);
			else
				self.page:SetUIBackground("btn_feedpet", "");
				self.page:SetUIEnabled("btn_feedpet", false);
			end
		end
	end
end
function CombatPetPage.DoRadio(value,mcmlNode,selected_pet_index)
	local self = CombatPetPage;
	if(self.page)then
		self.page:SetValue("Level2Tabs",tostring(value));
	end

	value = tonumber(value) or 1;
	self.state = value;
	
	self.selected_pet_index = selected_pet_index or 1;
	self.is_edit = 0;
	self.pets_datasource = nil;
	self.common_pets_datasource = nil;
	if(value == 1)then
		self.LoadData_Pets();
	else
		self.LoadData_Common_Pets();
	end
end
function CombatPetPage.ShowPage(nid,is_combat_state)
	NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetPane.lua");
	local CombatPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPane");
	CombatPetPane.ShowPage(nid);
	--local self = CombatPetPage;
	--self.nid = nid or Map3DSystem.User.nid;
    --self.is_edit = 0;
	--self.is_combat_state = is_combat_state;
	--System.App.Commands.Call("File.MCMLWindowFrame", {
			--url = "script/apps/Aries/CombatPet/CombatPetPage.html", 
			--name = "CombatPetPage.ShowPage", 
			--app_key=MyCompany.Aries.app.app_key, 
			--isShowTitleBar = false,
			--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			--bToggleShowHide = true,
			--style = CommonCtrl.WindowFrame.ContainerStyle,
			--zorder = 1,
			--isTopLevel = true,
			--allowDrag = false,
			--enable_esc_key = true,
			--directPosition = true,
				--align = "_ct",
				--x = -690/2,
				--y = -480/2,
				--width = 690,
				--height = 500,
		--});
	--self.DoRadio(1);
end
function CombatPetPage.DS_Func_Pets(index)
	local self = CombatPetPage;
	local datasource;
	if(self.state == 1)then
		datasource = self.pets_datasource;
	else
		datasource = self.common_pets_datasource;
	end
	if(not datasource)then return 0 end
	if(index == nil) then
		return #(datasource);
	else
		return datasource[index];
	end
end
function CombatPetPage.LoadData_Pets()
	local self = CombatPetPage;
	local nid = self.nid;
	if(not nid)then return end
	local hide_map = HomeLandGateway.LoadMyPetLocalShowInfo();
	ItemManager.LoadPetsInHomeland(nid, function(msg)
	local cnt = ItemManager.GetFollowPetCount(nid);
	local i;
	local list = {};
	for i = 1, cnt do
		local item = ItemManager.GetFollowPetByOrder(nid, i);
		if(item)then
			local gsid = item.gsid;
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
			local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
			-- top level if is followed user
			if(item and item.guid > 0 and item.gsid == gsid) then
				is_top_level = 1;
			end
			local defaultvalue = 1 + #list;
			local order = self.GetOrder(gsid,defaultvalue);
			local hide_in_homeland = hide_map[gsid];
			table.insert(list,{
				gsid = gsid,
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
				hide_in_homeland = hide_in_homeland,
			});
		end
		
	end
	--table.sort(list, function(a, b)
		--return (a.priority > b.priority );
	--end);
	--table.sort(list, function(a, b)
		--return ( (a.is_combat_pet > b.is_combat_pet)  );
	--end);
	--table.sort(list, function(a, b)
		--return ( (a.order < b.order)  );
	--end);
	--table.sort(list, function(a, b)
		--return ( (a.is_top_level > b.is_top_level)  );
	--end);
	
	
	table.sort(list, function(a, b)
		return 
				((a.is_combat_pet > b.is_combat_pet))
				or ((a.is_combat_pet == b.is_combat_pet) and (a.is_top_level > b.is_top_level))
				or ((a.is_combat_pet == b.is_combat_pet) and (a.is_top_level == b.is_top_level) and (a.order < b.order))
	end);
	
    self.pets_datasource = list;
	self.OnShowModel();
	if(self.page)then
		self.page:Refresh(0);
	end
end, "access plus 30 minutes");
end
function CombatPetPage.LoadData_Common_Pets()
	local self = CombatPetPage;
	local gsid;
	local list = {};
	for gsid = self.all_gsids[1],self.all_gsids[2] do
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem) then
			local assetfile = gsItem.assetfile;
			local name = gsItem.template.name;
			local description = gsItem.template.description;
			

			local provider = CombatPetHelper.GetClientProvider();
			local is_combat_pet = 0;
			local is_combat,isvip;
			if(provider)then
				is_combat,isvip = provider:IsCombatPet(gsid);
				if(is_combat)then
					is_combat_pet = 1;
				end
			end
			local req_magic_level = -1;
			local p = provider:GetPropertiesByID(gsid);
			local order = 0;
			if(p)then
				order = p.order or 0;
				req_magic_level = p.req_magic_level or -1;
			end
			table.insert(list,{
				gsid = gsid,
				assetfile = assetfile,
				name = name,
				is_combat_pet = is_combat_pet,
				isvip = isvip,
				description = description,
				order = order,
				req_magic_level = req_magic_level,
			});
		end
	end
	-- sort in decending order. 
	table.sort(list, function(a, b)
		return (a.order > b.order);
	end);
	--table.sort(list, function(a, b)
		--return (a.is_combat_pet > b.is_combat_pet);
	--end);
	self.common_pets_datasource = list;
	self.OnShowModel();
	if(self.page)then
		self.page:Refresh(0);
	end

end
-- swap two node index
function CombatPetPage.SwapNodeOrder(index1,index2,list)
	local self = CombatPetPage;
	if(not index1 or not index2 or not list)then return end	
	local node_1 = list[index1];
	local node_2 = list[index2];
	if(node_1 and node_2)then
		list[index1] = node_2;
		list[index2] = node_1;

		-- save all of order in local data
		local k,v;
		local map = {};
		for k,v in ipairs(list) do
			local gsid = v.gsid;
			map[gsid] = k;
		end
		CombatPetPage.SetAllOrder(map)
	end
end
-- get value of order show in combatpet list
function CombatPetPage.GetOrder(gsid,defaultvalue)
	local self = CombatPetPage;
	if(not gsid)then return end
	local nid = Map3DSystem.User.nid;
	local key = string.format("CombatPetPage.ShowOrder_%s",tostring(nid));
	local map = MyCompany.Aries.Player.LoadLocalData(key, {});
	local v = map[gsid] or defaultvalue;
	return v;
end
function CombatPetPage.SetAllOrder(map)
	local self = CombatPetPage;
	local nid = Map3DSystem.User.nid;
	local key = string.format("CombatPetPage.ShowOrder_%s",tostring(nid));
	MyCompany.Aries.Player.SaveLocalData(key, map);
end
function CombatPetPage.SetValue_PetLocalShowInfo(gsid,v)
	HomeLandGateway.SetValue_PetLocalShowInfo(gsid,v);
end