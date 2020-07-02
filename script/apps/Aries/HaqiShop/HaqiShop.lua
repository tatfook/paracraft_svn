--[[
Title: 
Author(s): zhangruofei
Date: 2010/12/13
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.lua");
MyCompany.Aries.HaqiShop.ShowMainWnd()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
NPL.load("(gl)script/apps/Aries/VIP/PurChaseEnergyStone.lua");
NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");
NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopProvider.lua");
local NPCShopProvider = commonlib.gettable("MyCompany.Aries.NPCShopProvider");
local CCS = commonlib.gettable("Map3DSystem.UI.CCS")
local PurchaseEnergyStone = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseEnergyStone");
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local HaqiShop = commonlib.gettable("MyCompany.Aries.HaqiShop");
HaqiShop.curpage = HaqiShop.curpage or 1;
HaqiShop.show = HaqiShop.show or 1001;
HaqiShop.data = HaqiShop.data or {};

-- npcshop information 
HaqiShop.data_from_npcshop = false;
HaqiShop.init_data_npcshop = false;
HaqiShop.data_npcshop = HaqiShop.data_npcshop or {};
HaqiShop.npc_tab_name = HaqiShop.npc_tab_name or "npc_0";

HaqiShop.npc_tabs = {
	["npc_0"] = {npcid = 30431, superclass = "menu2", class = "VipGloves", text = "手套VIP"},
	["npc_1"] = {npcid = 30431, superclass = "menu2", class = "VipS4Fire", text = "烈火系VIP"},
	["npc_2"] = {npcid = 30431, superclass = "menu2", class = "VipS4Ice", text = "寒冰系VIP"},
	["npc_3"] = {npcid = 30431, superclass = "menu2", class = "VipS4Storm", text = "风暴系VIP"},
	["npc_4"] = {npcid = 30431, superclass = "menu2", class = "VipS4Life", text = "生命系VIP"},
	["npc_5"] = {npcid = 30431, superclass = "menu2", class = "VipS4Death", text = "死亡系VIP"},
}


--public function: entry function to create the page
function HaqiShop.ShowMainWnd(tabname,tabname2, zorder)
	if(System.options.version=="kids") then
		NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.kids.lua");
	else
		NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.teen.lua");
	end
	HaqiShop.week = MyCompany.Aries.Scene.GetDayOfWeek() or 1;	
	HaqiShop.CreatePage(tabname,tabname2, zorder);
end
 
-- virtual function: create UI
function HaqiShop.CreatePage(tabname,tabname2)
end

-- public function 
function HaqiShop.RegisterHook()
end

--public function 
function HaqiShop.OnPageClose()
end

-- reset to current avatar
function HaqiShop.ResetPreviewModel(page)
	-- HaqiShop.LoadCurAvatar()
	HaqiShop.head_gsid_cur = 0;
	HaqiShop.head_gsid = HaqiShop.head_gsid_cur;
	HaqiShop.body_gsid_cur = 0;
	HaqiShop.body_gsid = HaqiShop.body_gsid_cur;
	HaqiShop.pants_gsid_cur = 0;
	HaqiShop.pants_gsid = HaqiShop.pants_gsid_cur;
	HaqiShop.shoe_gsid_cur = 0;
	HaqiShop.shoe_gsid = HaqiShop.shoe_gsid_cur;
	HaqiShop.backside_gsid_cur = 0;
	HaqiShop.backside_gsid = HaqiShop.backside_gsid_cur;
	HaqiShop.leftweapon_gsid_cur = 0;
	HaqiShop.leftweapon_gsid = HaqiShop.leftweapon_gsid_cur;
	HaqiShop.rightweapon_gsid_cur = 0;
	HaqiShop.rightweapon_gsid = HaqiShop.rightweapon_gsid_cur;
	HaqiShop.ShowAvatar(HaqiShop.head_gsid_cur,HaqiShop.body_gsid_cur,HaqiShop.pants_gsid_cur,HaqiShop.shoe_gsid_cur,HaqiShop.backside_gsid_cur,HaqiShop.leftweapon_gsid_cur,HaqiShop.rightweapon_gsid_cur, page);
end

-- public function 
function HaqiShop.LoadCurAvatar()
	local item = ItemManager.GetItemByBagAndPosition( 0, 2 );
	if(item.guid == 0)then
		HaqiShop.head_gsid_cur = 0;
	else
		local gsitem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
		local replace_gsid = gsitem.template.stats[53];
		echo(replace_gsid);
		if(replace_gsid) then
			HaqiShop.head_gsid_cur = replace_gsid;
		else
			HaqiShop.head_gsid_cur = item.gsid;
		end
	end

	item = ItemManager.GetItemByBagAndPosition( 0, 5 );
	if(item.guid == 0)then
		HaqiShop.body_gsid_cur = 0;
	else
		local gsitem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
		local replace_gsid = gsitem.template.stats[53];
		if(replace_gsid) then
			HaqiShop.body_gsid_cur = replace_gsid;
		else
			HaqiShop.body_gsid_cur = item.gsid;
		end
	end

	item = ItemManager.GetItemByBagAndPosition( 0, 6 );
	if(item.guid == 0)then
		HaqiShop.pants_gsid_cur = 0;
	else
		HaqiShop.pants_gsid_cur = item.gsid;
	end

	item = ItemManager.GetItemByBagAndPosition( 0, 7 );
	if(item.guid == 0)then
		HaqiShop.shoe_gsid_cur = 0;
	else
		local gsitem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
		local replace_gsid = gsitem.template.stats[53];
		if(replace_gsid) then
			HaqiShop.shoe_gsid_cur = replace_gsid;
		else
			HaqiShop.shoe_gsid_cur = item.gsid;
		end
	end

	item = ItemManager.GetItemByBagAndPosition( 0, 8 );
	if(item.guid == 0)then
		HaqiShop.backside_gsid_cur = 0;
	else
		local gsitem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
		local replace_gsid = gsitem.template.stats[53];
		if(replace_gsid) then
			HaqiShop.backside_gsid_cur = replace_gsid;
		else
			HaqiShop.backside_gsid_cur = item.gsid;
		end
	end

	item = ItemManager.GetItemByBagAndPosition( 0, 10 );
	if(item.guid == 0)then
		HaqiShop.leftweapon_gsid_cur = 0;
	else
		HaqiShop.leftweapon_gsid_cur = item.gsid;
	end

	item = ItemManager.GetItemByBagAndPosition( 0, 11 );
	if(item.guid == 0)then
		HaqiShop.rightweapon_gsid_cur = 0;
	else
		HaqiShop.rightweapon_gsid_cur = item.gsid;
	end

	HaqiShop.head_gsid = HaqiShop.head_gsid_cur;
	HaqiShop.body_gsid = HaqiShop.body_gsid_cur;
	HaqiShop.pants_gsid = HaqiShop.pants_gsid_cur;
	HaqiShop.shoe_gsid = HaqiShop.shoe_gsid_cur;
	HaqiShop.backside_gsid = HaqiShop.backside_gsid_cur;
	HaqiShop.leftweapon_gsid = HaqiShop.leftweapon_gsid_cur;
	HaqiShop.rightweapon_gsid = HaqiShop.rightweapon_gsid_cur;
end

--HaqiShop.itemcatalist =
--{
--{id=10,name="全部"},
--{id=1001,name="新品"},
--{id=1002,name="热卖"},
--{id=2001,name="手持"},
--{id=2002,name="头部"},
--{id=3001,name="1级宝石"},
--{id=3002,name="2级宝石"},
--{id=5001,name="抱抱龙物品"},
--
--};
-- public function:
function HaqiShop.GetItems(cateid)
	paraworld.globalstore.GetByCate({cateid=cateid}, "test".. cateid, function(msg)
		local i;
		HaqiShop.data[cateid] = {};
		for i = 1, #(msg.list) do
			local tmp = msg.list[i];
			local gsitem = ItemManager.GetGlobalStoreItemInMemory(tmp.gsid);
			if(gsitem)then
				
				local disable_buy = false;

				-- 137 school_requirement(CG) 物品穿着必须系别 1金 2木 3水 4火 5土 6火 7冰 8风暴 9神秘 10生命 11死亡 12平衡 
				local myschool;
				local school = MyCompany.Aries.Combat.GetSchool();
				if(school) then
					myschool = school;
				end
				local item_school;
				local school_id = gsitem.template.stats[137] or gsitem.template.stats[169];
				if(school_id == 6) then
					item_school = "fire";
				elseif(school_id == 7) then
					item_school = "ice";
				elseif(school_id == 8) then
					item_school = "storm";
				elseif(school_id == 9) then
					item_school = "myth";
				elseif(school_id == 10) then
					item_school = "life";
				elseif(school_id == 11) then
					item_school = "death";
				elseif(school_id == 12) then
					item_school = "balance";
				end

				if(gsitem.template.stats[522]) then
					-- in case the item is only purchasable at specified date. 
					local value = tostring(gsitem.template.stats[522]);
					if(not value:match(tostring(HaqiShop.week))) then
						disable_buy = "dayofweek_mismatch";
					end
				end

				local total_count = -1;
				if(gsitem.hourlylimitedpurchase or gsitem.dailylimitedpurchase) then
					total_count = math.max(gsitem.hourlylimitedpurchase or -1, gsitem.dailylimitedpurchase or -1);
				end

				if(item_school and myschool ~= item_school) then
					disable_buy = "school_mismatch";
				end

				-- if school mismatch put the items behind all others
				if(disable_buy) then
					tmp.order = tmp.order - 10000;
				end

				if(disable_buy ~= "dayofweek_mismatch") then
					table.insert( HaqiShop.data[cateid], 
						{ gsid=tmp.gsid, 
						order = tmp.order,
						type = gsitem.template.inventorytype,  
						name = gsitem.template.name, 
						icon=gsitem.icon, 
						price = gsitem.count,
						qidouprice = gsitem.ebuyprice,
						orgqidou=gsitem.template.stats[49] or "nil",
						orgmodou=gsitem.template.stats[50] or "nil",
						total_count = total_count,
						disable_buy = disable_buy} );
				end
			end
		end
		
		-- sort the list with predefined order
		table.sort(HaqiShop.data[cateid],function(a, b)
			return a.order > b.order;
		end);

		commonlib.algorithm.sort_by_predicate(HaqiShop.data[cateid], function(a)
			return not a.disable_buy;
		end)

		HaqiShop.RefreshGridPage();

		-- NOTE: need another click 
		
		UIAnimManager.PlayCustomAnimation(100, function(elapsedTime)
			if(elapsedTime == 100) then
				--HaqiShop.OnClickTab(cateid);
				--HaqiShop.ViewData(cateid);
				HaqiShop.RefreshGridPage();
			end
		end);
		
	end);
end

-- public function 
function HaqiShop.Init()
	HaqiShop.page = document:GetPageCtrl(); 
	ItemManager.GetItemsInBag(0, "RefreshBag0AfterPurchaseWithMagicBean", function()  
		local bhas,_,__,count = hasGSItem(984);
		local m_count;
		if(bhas and count)then
			m_count = count
		end
	end, "access plus 10 seconds");
	if(not HaqiShop.init_data_npcshop) then
		--HaqiShop.data_npcshop
		--npc_tabs
		local name,item;
		for name,item in pairs(HaqiShop.npc_tabs) do
			local npcid = item.npcid;
			local superclass = item.superclass;
			local class = item.class;
			local source = NPCShopProvider.FindDataSource(npcid,superclass,class);
			HaqiShop.data_npcshop[name] = source;
		end
		HaqiShop.init_data_npcshop = true;
	end
	HaqiShop.data_from_npcshop = false;
end

-- public function: call this to refresh grid page. 
function HaqiShop.RefreshGridPage(delayTime)
	if(HaqiShop.page)then
		local grid_name = "haqishopgrid";
		--if(HaqiShop.data_from_npcshop) then
			--grid_name = "haqi_npcshop_grid";
		--end
		HaqiShop.page:CallMethod(grid_name, "GotoPage", 1, true);
		HaqiShop.page:CallMethod(grid_name, "DataBind");
	end
end

-- public function: 
function HaqiShop.ViewData(cateid)
	cateid = tonumber(cateid);

	HaqiShop.show = cateid;
	if( HaqiShop.data[cateid] == nil)then
		HaqiShop.GetItems(cateid);
	elseif(HaqiShop.page)then
		HaqiShop.RefreshGridPage();
	end
end

-- public function: 
function HaqiShop.GetPage1()
	return HaqiShop.curpage;
end

-- public function: 
function HaqiShop.ShowQidou()
	return HaqiShop.bshowqidou;
end

-- public function: 
function HaqiShop.OnClickTab(name)
	local selected_page_from_npcshop = false;
	if(string.match(name,"npc")) then
		selected_page_from_npcshop = true;
	else
		local secondray_menu_name = HaqiShop.page:GetValue(name .. "2" );
		if(secondray_menu_name and string.match(secondray_menu_name,"npc")) then
			name = secondray_menu_name;
			selected_page_from_npcshop = true;
		end
	end
	if(System.options.version == "kids" and selected_page_from_npcshop) then
		local item = HaqiShop.npc_tabs[name];
		local npcid = item.npcid;
		local superclass = item.superclass;
		local class = item.class;
		HaqiShop.data_from_npcshop = true;
		HaqiShop.npc_tab_name = name;
		HaqiShop.RefreshGridPage();
		return;
	else
		HaqiShop.data_from_npcshop = false;
	end
	local tmp = tonumber(name);
	if(tmp==nil)then
		if(name=="tabQidou")then
			HaqiShop.bshowqidou = true;
		else
			HaqiShop.bshowqidou = false;		
		end

		name = HaqiShop.page:GetValue(name .. "2" );
	elseif(tmp>6000 and tmp < 7000)then
		HaqiShop.bshowqidou = true;
	else
		HaqiShop.bshowqidou = false;
	end

	

	name = tonumber(name);
	
	if(name)then
		HaqiShop.ViewData(name);
	end
end

function HaqiShop.DS_Func_Npcshop(index)
	local source = HaqiShop.data_npcshop[HaqiShop.npc_tab_name];
	if(index == nil)then
		return #source;
	else
		return source[index];
	end
end

function HaqiShop.DS_Func(index)
	if(HaqiShop.data_from_npcshop) then
		return HaqiShop.DS_Func_Npcshop(index);
	end
	if( index == nil and HaqiShop.data[HaqiShop.show] == nil )then
		
		return 0;
	elseif(index == nil)then
		return #(HaqiShop.data[HaqiShop.show]);
	elseif(HaqiShop.data[HaqiShop.show] == nil)then
		return {};
	else
		return HaqiShop.data[HaqiShop.show][index];
	end
end

-- public function: 
function HaqiShop.ShowMount(file,scaling,x,y,z, page)
	if(x==nil)then
		x= 0;
	end
	if(y==nil)then
		y= 0;
	end
	if(z==nil)then
		z= 0;
	end
	if(scaling==nil)then
		scaling= 1.0;
	end
	local asset = Map3DSystem.App.Assets.asset:new({filename = file})
	local objParams = asset:getModelParams();
	if(objParams ~= nil) then
		objParams.facing = 0;
		objParams.scaling = scaling;
		objParams.x = x;
		objParams.y = y;
		objParams.z = z;
		page = page or HaqiShop.page
		if(page) then
			local shopc3d =  page:FindControl("HaqiShopAvatar");
			if(shopc3d)then
				shopc3d:ShowModel(objParams);
			end
		
			page:SetValue("HaqiShopAvatar", commonlib.serialize_compact(objParams));
		end
	end
end

-- get teen gsid from gsid and gender
local function GetTeenGSID(gsid, gender)
	if(gsid <= 0) then
		return 0;
	end
	local force_gender;
	local isUniSex = false;
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
	if(gsItem) then
		-- 187 is_unisex_teen(C)
		if(gsItem.template.stats[187] == 1) then
			isUniSex = true;
		end
		force_gender = gsItem.template.stats[63];
		if(force_gender == 0) then
			force_gender = "male"; -- only male can wear and buy
			gender = "male";
		elseif(force_gender == 1) then
			force_gender = "female"; -- only female can wear and buy
			gender = "female";
		end
	end
	if(isUniSex == true) then
		gsid = gsid + 30000;
	else
		if(gender == "female") then
			gsid = gsid + 40000;
		else
			gsid = gsid + 30000;
		end
	end
	return gsid, force_gender
end

-- public function: 
function HaqiShop.ShowAvatar(head_gsid,body_gsid,pants_gsid,shoe_gsid,backside_gsid,
							leftweapon_gsid,rightweapon_gsid, page)
	head_gsid = head_gsid or 0;
	body_gsid = body_gsid or 0;
	pants_gsid = pants_gsid or 0;
	shoe_gsid = shoe_gsid or 0;
	backside_gsid = backside_gsid or 0;
	leftweapon_gsid = leftweapon_gsid or 0;
	rightweapon_gsid = rightweapon_gsid or 0;
	
	local avatar_gender = MyCompany.Aries.Player.GetGender();
	local new_gender;
	if(System.options.version == "teen") then
		local gender = avatar_gender;
		
		local function VerifyGsid(gsid, gender)
			local gsid, force_gender = GetTeenGSID(gsid, gender);
			if(force_gender and force_gender~=gender) then
				new_gender = force_gender;
				return 0;
			end
			return gsid;
		end
		head_gsid = head_gsid; -- weird
		
		local body_gsid_, pants_gsid_, shoe_gsid_, head_gsid_, backside_gsid_, leftweapon_gsid_, rightweapon_gsid_ = body_gsid, pants_gsid, shoe_gsid, head_gsid, backside_gsid, leftweapon_gsid, rightweapon_gsid;
		body_gsid = VerifyGsid(body_gsid, gender);
		pants_gsid = VerifyGsid(pants_gsid, gender);
		shoe_gsid = VerifyGsid(shoe_gsid, gender);
		head_gsid = VerifyGsid(head_gsid, gender);
		backside_gsid = VerifyGsid(backside_gsid, gender);
		leftweapon_gsid = VerifyGsid(leftweapon_gsid, gender);
		rightweapon_gsid = VerifyGsid(rightweapon_gsid, gender);

		if(new_gender) then
			-- in case there is unsupported gender in equipment, we will change the avatar model's sex. 
			body_gsid = VerifyGsid(body_gsid_, new_gender);
			pants_gsid = VerifyGsid(pants_gsid_, new_gender);
			shoe_gsid = VerifyGsid(shoe_gsid_, new_gender);
			head_gsid = VerifyGsid(head_gsid_, new_gender);
			backside_gsid = VerifyGsid(backside_gsid_, new_gender);
			leftweapon_gsid = VerifyGsid(leftweapon_gsid_, new_gender);
			rightweapon_gsid = VerifyGsid(rightweapon_gsid_, new_gender);
		end
	end
	local cssinfo;
	
	cssinfo = CCS.GetCCSInfoString(nil, true, {
			[2] = head_gsid, 
			[5] = body_gsid, 
			[6] = pants_gsid,
			[7] = shoe_gsid, 
			[8] = backside_gsid, 
			[10] = leftweapon_gsid,
			[11] = rightweapon_gsid,
		}, new_gender);
	
	--local cssinfo = string.format("0#1#0#1#1#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#0#0#0#0#%d#0#0#%d#%d#%d#%d#%d#0#0#0#0#0#",
    --head_gsid,body_gsid,pants_gsid,shoe_gsid,backside_gsid,0);
	local asset_table = {
		name = "user_createnewavatar",
		AssetFile=MyCompany.Aries.Player.GetAvaterAssetFileByID(new_gender or avatar_gender),
		CCSInfoStr = cssinfo,
		IsCharacter = true,
		-- scaling = if_else(System.options.version=="kids", nil, 0.45),
		x=0,y=0,z=0,
	};
	page = page or HaqiShop.page
	if(page)then
		local shopc3d =  page:FindControl("HaqiShopAvatar");
		if(shopc3d) then
			shopc3d:ShowModel(asset_table);
		end
	end
end 

-- public function: 
function HaqiShop.GetMoDou()
	local bhas,_,__,count = hasGSItem(984);
	if(bhas and count)then
		return count;
	else 
		return 0;
	end
end

function HaqiShop.GetMoDouIcon()
	local gsitem = ItemManager.GetGlobalStoreItemInMemory(984);
	if(gsitem)then
		return gsitem.icon;
	end
end

local inventory_types = {
	[2] = true, -- Hat
	[5] = true, -- Shirt
	[6] = true, -- Pants
	[7] = true, -- Boots
	[8] = true, -- Back
	[10] = true, -- Left Hand Only
	[11] = true, -- Right Hand Only
	[18] = true, -- FashionHat
	[19] = true, -- FashionShirt
	[70] = true, -- FashionBack
	[71] = true, -- FashionBoots
	[72] = true, -- FashionRightHand
}

function HaqiShop.CanPreviewItem(gsid)
	if(gsid == 0 or gsid == "" or gsid == nil )then 
		return; 
	end
	local apparel_gsids = {};
	local gsitem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsitem)then
		if( (gsitem.template.class == 2 and gsitem.template.subclass == 6) or 
			(gsitem.template.class == 11 and gsitem.template.subclass == 1))then
			
			return true;
		elseif(gsitem.template.class == 3 and gsitem.template.subclass == 9)then
			local package_exid = gsitem.template.stats[47];
			if (package_exid) then
				local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(package_exid);
				if(exTemplate) then
					local _, pair;
					for _, pair in pairs(exTemplate.tos) do
						local pair_key = pair.key;
						if(pair_key > 1000 and pair_key < 8999) then
							table.insert(apparel_gsids, pair_key);
						end
					end
				end
			end
		else
			table.insert(apparel_gsids, gsid);
		end
	end
	local can_preview;
	local _, apparel_gsid;
	for _, apparel_gsid in pairs(apparel_gsids) do
		local gsitem = ItemManager.GetGlobalStoreItemInMemory(apparel_gsid);
		if(gsitem)then
			local item_type = gsitem.template.inventorytype;
			if(inventory_types[item_type]) then
				can_preview = true;
				break;
			end
		end
	end
	return can_preview;
end

function HaqiShop.OnClickItem(gsid,inst,index, page)
	if(gsid == 0 or gsid == "" or gsid == nil )then 
		return; 
	end

	local apparel_gsids = {};

	local gsitem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsitem)then
		if( (gsitem.template.class == 2 and gsitem.template.subclass == 6) or 
			(gsitem.template.class == 11 and gsitem.template.subclass == 1))then
			if(gsid==16051)then
				HaqiShop.ShowMount(gsitem.assetfile, 0.35, 0, -5.0, 0, page);
			else
				HaqiShop.ShowMount(gsitem.assetfile, nil,nil, nil, nil, page);
			end	
			return;
		elseif(gsitem.template.class == 3 and gsitem.template.subclass == 9)then
			local package_exid = gsitem.template.stats[47];
			if (package_exid) then
				local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(package_exid);
				if(exTemplate) then
					local _, pair;
					for _, pair in pairs(exTemplate.tos) do
						local pair_key = pair.key;
						if(pair_key > 1000 and pair_key < 8999) then
							table.insert(apparel_gsids, pair_key);
						end
					end
				end
			end
		else
			table.insert(apparel_gsids, gsid);
		end
	end

	local function ApplyApparel(part, apparel_gsid)
		HaqiShop[part] = apparel_gsid;
		if(System.options.version=="teen" and apparel_gsid and apparel_gsid>0) then
			local avatar_gender = if_else(MyCompany.Aries.Player.GetGender()=="male", 1, 0);

			local required_gender = avatar_gender;
			local gsitem = ItemManager.GetGlobalStoreItemInMemory(apparel_gsid);
			if(gsitem)then
				required_gender = gsitem.template.stats[63] or required_gender;
			end

			local parts = {
			"body_gsid", "pants_gsid", "shoe_gsid", "head_gsid", 
			"backside_gsid", "leftweapon_gsid", "rightweapon_gsid"
			}
			local _, part_name;
			for _, part_name in ipairs(parts)  do
				local gsid = HaqiShop[part_name];
				if(gsid and gsid>0) then
					local gsitem_ = ItemManager.GetGlobalStoreItemInMemory(gsid);
					if(gsitem_) then
						local force_gender_ = gsitem_.template.stats[63]
						if(force_gender_ and force_gender_~=required_gender) then
							HaqiShop[part_name] = 0;
						end
					end
				end
			end
		end
	end

	local _, apparel_gsid;
	for _, apparel_gsid in pairs(apparel_gsids) do
		local gsitem = ItemManager.GetGlobalStoreItemInMemory(apparel_gsid);
		if(gsitem)then
			--index=tonumber(index);
			--local item = HaqiShop.data[HaqiShop.show][index];

			local item = { 
				gsid = apparel_gsid, 
				type = gsitem.template.inventorytype,  
				name = gsitem.template.name, 
				icon = gsitem.icon, 
				price = gsitem.count,
				qidouprice = gsitem.ebuyprice,
				orgqidou = gsitem.template.stats[49],
				orgmodou = gsitem.template.stats[50],
			};


			if(item)then
				if(System.options.version == "kids" and (item.type == 2 or item.type == 5 or item.type == 7 or item.type == 8)) then
					local replacement_gsid = gsitem.template.stats[53];
					if(replacement_gsid) then
						apparel_gsid = replacement_gsid;
					end
				end
				if(item.type == 2)then
					if(HaqiShop.head_gsid == apparel_gsid)then
						ApplyApparel("head_gsid", HaqiShop.head_gsid_cur);
					else
						ApplyApparel("head_gsid", apparel_gsid);
					end
				elseif(item.type == 5 )then
					if(HaqiShop.body_gsid == apparel_gsid)then
						ApplyApparel("body_gsid", HaqiShop.body_gsid_cur);
					else
						ApplyApparel("body_gsid", apparel_gsid);
					end
				elseif(item.type == 6 )then
					if(HaqiShop.pants_gsid == apparel_gsid)then
						ApplyApparel("pants_gsid", HaqiShop.pants_gsid_cur);
					else
						ApplyApparel("pants_gsid", apparel_gsid);
					end
				elseif(item.type == 7)then
					if(HaqiShop.shoe_gsid == apparel_gsid)then
						ApplyApparel("shoe_gsid", HaqiShop.shoe_gsid_cur);
					else
						ApplyApparel("shoe_gsid", apparel_gsid);
					end
				elseif(item.type == 8)then
					if(HaqiShop.backside_gsid == apparel_gsid)then
						ApplyApparel("backside_gsid", HaqiShop.backside_gsid_cur);
					else
						ApplyApparel("backside_gsid", apparel_gsid);
					end
				elseif(item.type == 10 )then
					if(HaqiShop.leftweapon_gsid == apparel_gsid)then
						ApplyApparel("leftweapon_gsid", HaqiShop.leftweapon_gsid_cur);
					else
						ApplyApparel("leftweapon_gsid", apparel_gsid);
					end
				elseif(item.type == 11 )then
					if(HaqiShop.rightweapon_gsid == apparel_gsid)then
						ApplyApparel("rightweapon_gsid", HaqiShop.rightweapon_gsid);
					else
						ApplyApparel("rightweapon_gsid", apparel_gsid);
					end
				elseif(item.type == 18)then
					local replacement_gsid = gsitem.template.stats[53];
					if(replacement_gsid) then
						if(HaqiShop.head_gsid == replacement_gsid)then
							ApplyApparel("head_gsid", HaqiShop.head_gsid_cur);
						else
							ApplyApparel("head_gsid", replacement_gsid);
						end
					end
					
				elseif(item.type == 19)then
					local replacement_gsid = gsitem.template.stats[53];
					if(replacement_gsid) then
						if(HaqiShop.body_gsid == replacement_gsid)then
							ApplyApparel("body_gsid", HaqiShop.body_gsid_cur);
						else
							ApplyApparel("body_gsid", replacement_gsid);
						end
					end
				elseif(item.type == 70)then
					local replacement_gsid = gsitem.template.stats[53];
					if(replacement_gsid) then
						if(HaqiShop.backside_gsid == replacement_gsid)then
							ApplyApparel("backside_gsid", HaqiShop.backside_gsid_cur);
						else
							ApplyApparel("backside_gsid", replacement_gsid);
						end
					end
				elseif(item.type == 71)then
					local replacement_gsid = gsitem.template.stats[53];
					if(replacement_gsid) then
						if(HaqiShop.shoe_gsid == replacement_gsid)then
							ApplyApparel("shoe_gsid", HaqiShop.shoe_gsid_cur);
						else
							ApplyApparel("shoe_gsid", replacement_gsid);
						end
					end
				elseif(item.type == 72)then
					local replacement_gsid = gsitem.template.stats[53];
					if(replacement_gsid) then
						if(HaqiShop.rightweapon_gsid == replacement_gsid)then
							ApplyApparel("rightweapon_gsid", HaqiShop.rightweapon_gsid_cur);
						else
							ApplyApparel("rightweapon_gsid", replacement_gsid);
						end
					end
				end
			end
		end
	end

	if(#apparel_gsids >= 1) then
		HaqiShop.ShowAvatar(HaqiShop.head_gsid,HaqiShop.body_gsid,HaqiShop.pants_gsid,
			HaqiShop.shoe_gsid,HaqiShop.backside_gsid,HaqiShop.leftweapon_gsid, HaqiShop.rightweapon_gsid, page);
	end
end

function HaqiShop.ShowModouNum(num)
	if(HaqiShop.page and num)then
	end
end

-- @ctype: pay or guide for kids version
function HaqiShop.BuyMagicBean(ctype)
	if(not DealDefend.CanPass())then
		if(HaqiShop.page)then
			HaqiShop.page:CloseWindow();
		end
		return
	end
	if (ctype~="pay" and ctype~="guide") then
		MyCompany.Aries.Inventory.PurChaseMagicBean.Show("guide"); -- default to guide page. 
	else
		MyCompany.Aries.Inventory.PurChaseMagicBean.Show(ctype);
	end	
end

function HaqiShop.GetMagicStone()
	if(not DealDefend.CanPass())then
		if(HaqiShop.page)then
			HaqiShop.page:CloseWindow();
		end
		return
	end
    local gsid=998;
    Map3DSystem.mcml_controls.pe_item.OnClickGSItem(gsid,true);		
	--PurchaseEnergyStone.Show();
end

function HaqiShop.ShowHelp()
	NPL.load("(gl)script/apps/Aries/Help/Common_help.lua");
	MyCompany.Aries.Help.Common_help.ShopHelp_ShowPage();
end

function HaqiShop.BuyMoDou(gsid)
	gsid = tonumber(gsid);
	local gsitem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	local isvip = MyCompany.Aries.VIP.IsVIPAndActivated();
	if(not DealDefend.CanPass())then
		if(HaqiShop.page)then
			HaqiShop.page:CloseWindow();
		end
		return
	end
	if(gsitem)then
		-- 是否是炫彩卡
		local BuyGoldCardNoTips = true;
		local GoldCardProp = gsitem.template.stats[99];
		local BasicSkillName="";
		if (GoldCardProp) then									 
			local BasicSkillGSID = gsitem.template.stats[100];
			BasicSkillName = ItemManager.GetGlobalStoreItemInMemory(BasicSkillGSID).template.name;
			BuyGoldCardNoTips = hasGSItem(BasicSkillGSID);
		else
			BuyGoldCardNoTips = true;
		end		

		if(gsid == 17317 and System.options.version == "kids") then
			local bHas = ItemManager.IfOwnGSItem(50358);
			if(bHas) then
				_guihelper.MessageBox("每个角色只能使用此物品1次， 你已经使用过了。你是否还要继续购买？",function(result)
					if(result == _guihelper.DialogResult.Yes)then
						Map3DSystem.mcml_controls.pe_item.OnClickGSItem(gsid,true);
					else
					
					end
				end,_guihelper.MessageBoxButtons.YesNo);
				return;
			end
		end
		if (not BuyGoldCardNoTips) then
			_guihelper.Custom_MessageBox("你现在还没有学会该炫彩卡要求的基础技能【"..BasicSkillName.."】哦，" .. gsitem.template.name .. "需要学会基础技能才能使用哦，你确定要购买吗？",function(result)
				if(result == _guihelper.DialogResult.Yes)then
					Map3DSystem.mcml_controls.pe_item.OnClickGSItem(gsid,true);
				else
					
				end
			end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/PurchaseImmediately_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});			
		else
			if(gsitem.template.stats[180] and not isvip)then
				_guihelper.Custom_MessageBox("你现在还没有魔法星哦，" .. gsitem.template.name .. "需要魔法的力量才能使用哦，你确定要购买吗？",function(result)
					if(result == _guihelper.DialogResult.Yes)then
						Map3DSystem.mcml_controls.pe_item.OnClickGSItem(gsid,true);
					else
					
					end
				end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/PurchaseImmediately_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			else
				Map3DSystem.mcml_controls.pe_item.OnClickGSItem(gsid,true);
			end
		end
	end
end

-- disable buy
function HaqiShop.OnDisableBuy(name, mcmlNode)
	local disable_reason = mcmlNode:GetAttribute("param1");
	if(disable_reason == "school_mismatch") then
		_guihelper.MessageBox("系别不符，购买后将不能使用！");
	elseif(disable_reason == "dayofweek_mismatch") then
		_guihelper.MessageBox("这个物品今天不能购买, 请查看物品的购买说明，有些物品只在周末出售");
	end
end

function HaqiShop.BuyButSchoolMismatch()
	_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>系别不符，购买后将不能使用！</div>");
end

function HaqiShop.ShowPrice()
	if(HaqiShop.ShowQidou()==true )then
		return [[<%=Eval("qidouprice") %>奇豆/件]];
	else
		return [[<%=Eval("price") %>魔豆/件]];
	end
end

function HaqiShop.IsDiscount()
end

function HaqiShop.GotoTaomeePage()
	if(System.options.version=="kids") then
		NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.kids.lua");
	else
		NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.teen.lua");
	end
	HaqiShop.GotoTaomeePage()
end

local sequence_id = 0;
local seq_map = {};
function HaqiShop.GetNextSequenceID()
	sequence_id = sequence_id + 1;
	return sequence_id;
end

-- get a callback function by sequence id. 
-- @param seq: the sequence id
function HaqiShop.InvokeCallbackBySeq(seq, ...)
	seq = tonumber(seq);
	if(seq) then
		local params = seq_map[seq];
		if(params and params.callback) then
			params.callback(params, ...);
			seq_map[seq] = nil;
		end
	end
end

-- return the sequence id
function HaqiShop.SetCallback(params)
	if(params and params.callback) then
		local seq = HaqiShop.GetNextSequenceID();
		if(seq) then
			seq_map[seq] = params;
			params.seq = seq;
			return seq;
		end
	end
end

-- purchase item 
-- @param params: {gsid=number, exid=number, count=number, npc_shop=true, callback=function(params) end } 
function HaqiShop.PurchaseItem(params)
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	if(not DealDefend.CanPass())then
		return
	end
	if(params.gsid) then
		local isStackable = true;
		local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(params.gsid);
		if(gsItem) then
			maxcopiesinstack = gsItem.template.maxcopiesinstack;
			maxcount = gsItem.template.maxcount;
			if(maxcopiesinstack == 1 or maxcount == 1) then
				isStackable = false;
			end
			-- 523 物品每次只能买一个， 即使可堆叠。 一般处于前置条件的考虑会使用。入激怒符文 （儿童版首次使用）
			if(gsItem.template.stats[523] == 1) then
				isStackable = false;
			end
		end
		-- call backs if any 
		local seq = HaqiShop.SetCallback(params);

		-- force using standard purchase if exid is nil or 0. 
		if(params.exid == nil or params.exid == 0) then
			params.npc_shop = nil;
			params.exid = nil;
		elseif(params.exid) then
			params.npc_shop = true;
		end


		local url;
		if(params.card)then
			url = System.localserver.UrlHelper.BuildURLQuery("script/apps/Aries/Inventory/Pages/PurchaseCard.html", {gsid = params.gsid, seq=seq});
		elseif(params.npc_shop)then	
			local exid = tonumber(params.exid);
			if(exid >= 2750 and exid <= 2759) then
				local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
				if(exTemplate)then
					local equip_gsid = tonumber(exTemplate.froms[2].key);
					local _, guid = hasGSItem(equip_gsid);
					local item = ItemManager.items[guid];
					if(item.serverdata == "" or item.serverdata == "{}") then

					else
						_guihelper.MessageBox(string.format("你的<pe:slot gsid='%d' isclickable='false' style='width:24px;height:24px;'/>已经强化或镶嵌过宝石，不能出售",equip_gsid));
						return;
					end
				end
			end
			url = System.localserver.UrlHelper.BuildURLQuery(if_else(System.options.version =="kids", "script/apps/Aries/Inventory/Pages/PurchaseNpcShopItem.html","script/apps/Aries/Inventory/Pages/PurchaseNpcShopItem.teen.html"), {gsid = params.gsid,exid = params.exid,count=params.count, seq=seq, do_type = params.do_type});				
		else
			if(isStackable == true) then
				url = System.localserver.UrlHelper.BuildURLQuery("script/apps/Aries/Inventory/Pages/PurchaseStackableItem.html", {gsid = params.gsid,count=params.count, seq=seq});
			elseif(isStackable == false) then
				url = System.localserver.UrlHelper.BuildURLQuery("script/apps/Aries/Inventory/Pages/PurchaseSingleItem.html", {gsid = params.gsid, seq=seq});
			end
		end

		System.App.Commands.Call("File.MCMLWindowFrame", {
			-- TODO:  Add uid to url
			url = url, 
			name = "Aries.PurchaseItemWnd", 
			app_key = MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			isTopLevel = true,
			allowDrag = true,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 12,
			enable_esc_key = true,
			directPosition = true,
				align = "_ct",
				x = -466/2,
				y = -400/2,
				width = 466,
				height = 355,
		});
	end
end