--[[
Title: code behind for page FollowPetManager.html
Author(s): Andy
Date: 2009/12/22
Desc:  script/kids/3DMapSystemUI/HomeLand/Pages/FollowPetManager.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/FollowPetManager.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetHelper.lua");
local CombatPetHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetHelper");

local FollowPetManagerPage = {
	page = nil,
	home_name = nil,
};
commonlib.setfield("MyCompany.Aries.Inventory.FollowPetManagerPage", FollowPetManagerPage);

local ItemManager = System.Item.ItemManager;

function FollowPetManagerPage.Init()
	FollowPetManagerPage.page = document:GetPageCtrl();
end

-- datasoure function
function FollowPetManagerPage.DS_Func_FollowPets(nid, dsTable, index, pageCtrl)
    if(not dsTable.status) then
        -- use a default cache
        FollowPetManagerPage.GetPets(nid, pageCtrl, "access plus 10 minutes", dsTable);
    elseif(dsTable.status == 2) then    
        if(index == nil) then
			if(pageCtrl) then
				pageCtrl:SetUIValue("followpetcount", ""..dsTable.RealCount);
			end
            return dsTable.Count;
        else
            return dsTable[index];
        end
    end 
end

FollowPetManagerPage.CurrentSelected_FollowPet_GSID = nil;

function FollowPetManagerPage.ViewPetInfo(gsid, nid)
	-- keep a reference of the selected follow pet gsid
	FollowPetManagerPage.CurrentSelected_FollowPet_GSID = gsid;
	if(gsid == nil) then
		-- empty gsid
		local canvasCtl = FollowPetManagerPage.page:FindControl("FollowPetCanvas");
		if(canvasCtl) then
			canvasCtl:ShowModel();
			FollowPetManagerPage.page:SetValue("FollowPetCanvas", "");
		end
		local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory(nid);
		local nickname = "";
		if(userinfo) then
			nickname = userinfo.nickname;
		end
		FollowPetManagerPage.page:SetValue("petdesc", string.format([[用户 %s (%d) 一只宠物都没有呢！]], nickname, nid));
		return;
	end
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem) then
		-- refresh the model in FollowPetCanvas control
		local asset = Map3DSystem.App.Assets.asset:new({filename = gsItem.assetfile})
		local objParams = asset:getModelParams()
		if(objParams ~= nil) then
			local canvasCtl = FollowPetManagerPage.page:FindControl("FollowPetCanvas");
			if(canvasCtl) then
				canvasCtl:ShowModel(objParams);
				FollowPetManagerPage.page:SetValue("FollowPetCanvas", commonlib.serialize_compact(objParams));
			end
		end
		local provider = CombatPetHelper.GetClientProvider();
		local description = gsItem.template.description;
		if(provider)then
			local iscombat_pet = provider:IsCombatPet(gsid);
			if(iscombat_pet)then
				local p = provider:GetPropertiesByID(gsid)
				description = commonlib.serialize_compact(p)
			end
		end
		FollowPetManagerPage.page:SetValue("petdesc", description);
		
		-- normal button, toggle home and follow
		local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
		local toggle_btn_bg = "Texture/Aries/Profile/SendMeHome_32bits.png;0 0 153 49";
		if(item and item.guid > 0 and item.gsid == gsid) then
			toggle_btn_bg = "Texture/Aries/Profile/SendMeHome_32bits.png;0 0 153 49";
		else
			toggle_btn_bg = "Texture/Aries/Profile/FollowMe_32bits.png;0 0 153 49";
		end
		
		-- check if the gsitem has special ability
		if(gsItem.template.stats[14] == 1) then
			local special_bg = System.Item.Item_FollowPet.GetSpecialAbilityBtnBackground(gsid) or "";
			FollowPetManagerPage.page:SetUIBackground("btn_special", special_bg);
			FollowPetManagerPage.page:SetUIEnabled("btn_special", true);
			FollowPetManagerPage.page:SetUIBackground("btn_togglehome_single", "");
			FollowPetManagerPage.page:SetUIEnabled("btn_togglehome_single", false);
			FollowPetManagerPage.page:SetUIBackground("btn_togglehome", toggle_btn_bg);
			FollowPetManagerPage.page:SetUIEnabled("btn_togglehome", true);
		else
			FollowPetManagerPage.page:SetUIBackground("btn_special", "");
			FollowPetManagerPage.page:SetUIEnabled("btn_special", false);
			FollowPetManagerPage.page:SetUIBackground("btn_togglehome_single", toggle_btn_bg);
			FollowPetManagerPage.page:SetUIEnabled("btn_togglehome_single", true);
			FollowPetManagerPage.page:SetUIBackground("btn_togglehome", "");
			FollowPetManagerPage.page:SetUIEnabled("btn_togglehome", false);
		end
	end
end

-- toggle homeland and follow of the selected follow pet item
function FollowPetManagerPage.ToggleCurrentSelected()
	local gsid = FollowPetManagerPage.CurrentSelected_FollowPet_GSID;
	if(gsid) then
		local hasGSItem = ItemManager.IfOwnGSItem;
		local bHas, guid = hasGSItem(gsid);
		if(bHas == true) then
			local item = ItemManager.GetItemByGUID(guid);
			if(item and item.guid > 0) then
				-- toggle the item in homeland and follow
				item:OnClick("left");
			end
		end
	end
	FollowPetManagerPage.page:CloseWindow();
end

-- do special ability of the selected follow pet item
function FollowPetManagerPage.DoSpecialCurrentSelected()
	local gsid = FollowPetManagerPage.CurrentSelected_FollowPet_GSID;
	if(gsid) then
		local hasGSItem = ItemManager.IfOwnGSItem;
		local bHas, guid = hasGSItem(gsid);
		if(bHas == true) then
			local item = ItemManager.GetItemByGUID(guid);
			if(item and item.guid > 0) then
				-- do some special ability
				item:DoSpecialAbility();
			end
		end
	end
	FollowPetManagerPage.page:CloseWindow();
end

-- get follow pet items web service call. it will refresh page once finished. 
function FollowPetManagerPage.GetPets(nid, pageCtrl, cachepolicy, output)
	-- fetching
	output.status = 1;
	ItemManager.LoadPetsInHomeland(nid, function(msg)
		-- msg if no friends:
		-- echo:return { pagecnt=0, nids="" }
		
        -- my friends
		output.RealCount = ItemManager.GetFollowPetCount(nid);
		output.Count = ItemManager.GetFollowPetCount(nid);
	    local i;
	    for i = 1, output.Count do
			local item = ItemManager.GetFollowPetByOrder(nid, i);
			local priority = item.obtaintime;
			local name = "";
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
			if(gsItem) then
				name = gsItem.template.name;
				if(gsItem.template.stats[14] == 1) then
					priority = "9_"..priority;
				end
			end
			output[i] = {
				bshow = true, 
				gsid = item.gsid, 
				name = name, 
				priority = priority, 
			};
	    end
	    -- sort the table according to priority
	    table.sort(output, function(a, b)
			return (a.priority > b.priority);
	    end);
        -- fill at least 10 rows of friends
		if(output.Count < 10) then
			output.Count = 10;
			local j;
			for j = (output.RealCount + 1), output.Count do
				output[j] = {
					bshow = false,
				};
			end
		end
		
		commonlib.resize(output, output.Count)
		output.status = 2;
		pageCtrl:Refresh(0.1);
	end, "access plus 30 minutes");
end