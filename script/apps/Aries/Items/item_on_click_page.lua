--[[
Title: item_on_click_page
Author(s): LiXizhi
Date: 2012/8/13
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Items/item_on_click_page.lua");
local item_on_click_page = commonlib.gettable("MyCompany.Aries.Items.item_on_click_page");
item_on_click_page.ShowPage(item)
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/HaqiShop/AuctionHouse.lua");
local AuctionHouse = commonlib.gettable("MyCompany.Aries.AuctionHouse");
NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationPage.lua");
local GemTranslationPage = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationPage");
NPL.load("(gl)script/apps/Aries/HaqiShop/ItemGuides.lua");
local ItemGuides = commonlib.gettable("MyCompany.Aries.ItemGuides");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetHelper.lua");
local CombatPetHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetHelper");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
local hasGSItem = ItemManager.IfOwnGSItem;
-- create class
local item_on_click_page = commonlib.gettable("MyCompany.Aries.Items.item_on_click_page");

local page;

-- @param item: the Item object
function item_on_click_page.ShowPage(item)
	if(not item or not item.gsid or not item.guid or item.guid<=0) then
		return;
	end
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
	if(not gsItem) then
		return;
	end
	item_on_click_page.guid = item.guid;
	item_on_click_page.item = item;

	local class = gsItem.template.class;
	local subclass = gsItem.template.subclass;
	local stat_75 = gsItem.template.stats[75];--ForceHideUseItemButton
	if(stat_75 and stat_75 == 1)then
		return
	end
	-- prepare location
	local x,y,width, height = _guihelper.GetLastUIObjectPos();
	item_on_click_page.icon_size = width;

	-- prepare menu item
	item_on_click_page.left_menu = {};
	item_on_click_page.right_menu = {};

	-- local equipped_item, isEquipped = ItemManager.GetEquippedItem(gsItem);
	-- fix bug 2012/9/6: multple item with the same gsid
	local isEquipped = false;
	if(item.bag == 0) then
		isEquipped = true;
	end

	if (System.options.version == "kids") then
		local has_use_item;
		if(class == 1) then					
			has_use_item = true;
			local can_upgrade;
			-- can has addon level?
			if(item.CanHaveAddonProperty and item:CanHaveAddonProperty()) then
				can_upgrade = true;
				if( item:GetAddonLevel() < item:GetMaxAddonLevel()) then
					table.insert(item_on_click_page.right_menu, {name="addonlevel", text="强化", is_default=false})
				end
			end

			-- has gem hole?
			if(gsItem) then
				local hole_cnt = gsItem.template.stats[36] or 0;
				if(hole_cnt > 0) then
					can_upgrade = true;
					if(item.GetSocketedGems)then
						--local _holdgems = item:GetSocketedGems();
						--if(not _holdgems or ((#_holdgems) < hole_cnt)) then
							table.insert(item_on_click_page.right_menu, {name="mount_gem", text="镶嵌", is_default=false}); -- mount/unmount gems
						--end
					end
				end
			end

			if(gsItem.template.stats[521] == 1 ) then
				local svrdata = item:GetServerData();
				if(svrdata and svrdata.money) then
					if(svrdata.nid == System.User.nid)then
						table.insert(item_on_click_page.right_menu, {name="sign_item", text="签名", is_default=false})
					end
				else
					table.insert(item_on_click_page.right_menu, {name="sign_item", text="签名", is_default=false})
				end
			end

			-- use item
			if(isEquipped) then
				table.insert(item_on_click_page.left_menu, {name="use_item", text="脱下", is_default=true})
			else
				table.insert(item_on_click_page.left_menu, {name="use_item", text="穿上", is_default=true})
			end
			if(can_upgrade) then
				-- only upgrade if we are use the current item
				table.insert(item_on_click_page.right_menu, {name="upgrade_item", text="继承", is_default=false})
			end
		end

		if(class == 3 and ( subclass == 6 or subclass == 7)) then
			has_use_item = true;
			if(item.gsid == 17179)then
				-- cut gem
				table.insert(item_on_click_page.right_menu, {name="cut_gem", text="摘除宝石", is_default=false})
			elseif(item.gsid == 17289)then
				table.insert(item_on_click_page.right_menu, {name="cut_combatpet_gem", text="剥离项圈宝石", is_default=false})
			else
				-- mount gem
				table.insert(item_on_click_page.right_menu, {name="mount_gem", text="镶嵌", is_default=false})
				if(subclass == 6) then
					-- merge gem
					table.insert(item_on_click_page.right_menu, {name="merge_gem", text="合成", is_default=false})
				end
			end
		end

		if(class == 3 and subclass == 22) then
			-- mount gem
			table.insert(item_on_click_page.right_menu, {name="identify_item", text="鉴定", is_default=false})
		end

		if(AuctionHouse.IsTradable(item.gsid)) then
			-- auction item
			table.insert(item_on_click_page.left_menu, {name="send_chat_link", text="聊天链接", is_default=false})
		end


		if(not isEquipped) then
			-- sell item
			if(gsItem.template.cansell) then
				if(gsItem.esellprice and gsItem.esellprice == 0) then
					table.insert(item_on_click_page.left_menu, {name="discard_item", text="丢掉", is_default=false})
				else
					table.insert(item_on_click_page.left_menu, {name="sell_item", text="卖奇豆", is_default=false})
				end
			end
		end
		
		if(gsItem.goto_npc) then
			--local npcid = tonumber(gsItem.goto_npc);
			table.insert(item_on_click_page.right_menu, {name="goto_npc", text="去看看", is_default=false})
		end

		if((#(item_on_click_page.left_menu) +  #(item_on_click_page.right_menu))>0) then
			if(not has_use_item) then
				has_use_item = true;
				-- Note: since some pres have probabilities, kids version should disable use all
				--if(false and item.CanUseAll and item:CanUseAll()) then
					--table.insert(item_on_click_page.left_menu, 1, {name="use_item_all", text="全部使用", is_default=true})
					--table.insert(item_on_click_page.left_menu, 2, {name="use_item", text="使用", is_default=false})
				--else
					table.insert(item_on_click_page.left_menu, 1, {name="use_item", text="使用", is_default=true})
				--end
			end

			table.insert(item_on_click_page.left_menu, {name="cancel", text="取消", is_default=false})

			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/Items/item_on_click_page.html", 
				name = "Aries.item_on_click_page", 
				app_key = MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				isTopLevel = true,
				is_click_to_close = true;
				zorder = 2002,
				allowDrag = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				enable_esc_key = true,
				click_through = true,
				directPosition = true,
					align = "_lt",
					x = x-100,
					y = y,
					width = 220+width,
					height = 180,
			});
			return true;
		end
	else
		local has_use_item;
		if(class == 1) then					
			has_use_item = true;
			local can_upgrade;
			-- can has addon level?
			if(item.CanHaveAddonProperty and item:CanHaveAddonProperty()) then
				can_upgrade = true;
				if( item:GetAddonLevel() < item:GetMaxAddonLevel()) then
					table.insert(item_on_click_page.right_menu, {name="addonlevel", text="强化", is_default=false})
				end
			end

			-- has gem hole?
			if(gsItem) then
				local hole_cnt = (gsItem.template.stats[36] or 0) + (gsItem.template.stats[67] or 0);
				if(hole_cnt > 0) then
					table.insert(item_on_click_page.right_menu, {name="mount_gem", text="镶嵌", is_default=false}); -- mount/unmount gems
				end

				if(GemTranslationPage.CanTrans(item.gsid))then
					table.insert(item_on_click_page.right_menu, {name="apparel_trans", text="平移", is_default=false});
				end
			end

			if(gsItem.template.stats[521] == 1 ) then
				local svrdata = item:GetServerData();
				if(svrdata and svrdata.money) then
					if(svrdata.nid == System.User.nid)then
						table.insert(item_on_click_page.right_menu, {name="sign_item", text="签名", is_default=false})
					end
				else
					table.insert(item_on_click_page.right_menu, {name="sign_item", text="签名", is_default=false})
				end
			end

			-- use item
			if(isEquipped) then
				table.insert(item_on_click_page.left_menu, {name="use_item", text="脱下", is_default=true})
			else
				table.insert(item_on_click_page.left_menu, {name="use_item", text="穿上", is_default=true})
			end
			if(can_upgrade) then
				-- only upgrade if we are use the current item
				-- table.insert(item_on_click_page.right_menu, {name="upgrade_item", text="继承", is_default=false})
			end
		end
		if(class == 2 and subclass == 8) then
			has_use_item = true;
			if(isEquipped) then
				table.insert(item_on_click_page.left_menu, {name="use_item", text="卸掉", is_default=true})
			else
				table.insert(item_on_click_page.left_menu, {name="use_item", text="驾驭", is_default=true})
			end
		end
		if(class == 3 and ( subclass == 6 or subclass == 7)) then
			has_use_item = true;
			if(item.gsid == 17179)then
				-- cut gem
				table.insert(item_on_click_page.right_menu, {name="cut_gem", text="摘除宝石", is_default=false})
			else
				-- mount gem
				table.insert(item_on_click_page.right_menu, {name="mount_gem", text="镶嵌", is_default=false})
			end
		end
		if(item.gsid == 17177)then
			has_use_item = true;
			table.insert(item_on_click_page.right_menu, {name="mount_gem", text="镶嵌", is_default=false})
		end

		if(not isEquipped) then
			-- sell item
			if(gsItem.template.cansell) then
				if(gsItem.esellprice and gsItem.esellprice == 0) then
					table.insert(item_on_click_page.right_menu, {name="discard_item", text="丢掉", is_default=false})
				else
					table.insert(item_on_click_page.right_menu, {name="sell_item", text="卖银币", is_default=false})
				end
			end
		end
		
		if(AuctionHouse.IsTradable(item.gsid)) then
			-- auction item
			if(AuctionHouse.CanExchange(item)) then
				table.insert(item_on_click_page.left_menu, {name="auction_item", text="寄售", is_default=false})
			end
			table.insert(item_on_click_page.left_menu, {name="send_chat_link", text="聊天链接", is_default=false})
		end

		if(ItemGuides.HasGuidesForItem(item.gsid)) then
			table.insert(item_on_click_page.left_menu, {name="item_guide", text="百科", is_default=false})
		end
			
		if(class == 18 and ( subclass == 1 or subclass == 2)) then
			-- Card does not have use button
			has_use_item = true;
		end
		if(class == 3 and ( subclass == 16 or subclass == 17 or subclass == 18 or subclass==19)) then
			-- material does not have use button
			has_use_item = true;
		end
		if(item.gsid == 17265 or item.gsid == 17295 or item.gsid == 17296 or item.gsid == 17297)then
			table.insert(item_on_click_page.left_menu, {name="open_cardpack", text="打开", is_default=false})
			has_use_item = true;
		end

		local len = #(item_on_click_page.left_menu) +  #(item_on_click_page.right_menu);
		if(len >= 0) then
			if(not has_use_item) then
				has_use_item = true;
				if(item.CanUseAll and item:CanUseAll()) then
					table.insert(item_on_click_page.left_menu, 1, {name="use_item_all", text="全部使用", is_default=true})
					table.insert(item_on_click_page.left_menu, 2, {name="use_item", text="使用", is_default=false})
				else
					table.insert(item_on_click_page.left_menu, 1, {name="use_item", text="使用", is_default=true})
				end
			end
			table.insert(item_on_click_page.left_menu, {name="cancel", text="取消", is_default=false})

			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/Items/item_on_click_page.teen.html", 
				name = "Aries.item_on_click_page", 
				app_key = MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				isTopLevel = true,
				is_click_to_close = true;
				zorder = 2002,
				allowDrag = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				enable_esc_key = true,
				click_through = true,
				directPosition = true,
					align = "_lt",
					x = x-100,
					y = y,
					width = 220+width,
					height = 180,
			});
			return true;
		end
	end
end


-- load everything from file
function item_on_click_page.init()
	page = document:GetPageCtrl();
end

function item_on_click_page.on_click(name)
	local item = item_on_click_page.item;
	if(not item or not item.gsid) then
		return;
	end
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
	if(not gsItem) then
		return;
	end

	if(name == "addonlevel") then
		NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_equip_upgrade.lua");
		local Avatar_equip_upgrade = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equip_upgrade");
		Avatar_equip_upgrade.ShowPage(item.gsid);
	elseif(name == "use_item") then
		local isCombatApparel = false;
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
		if(gsItem) then
			if(string.find(string.lower(gsItem.category), "combat")) then
				isCombatApparel = true;
			end
		end
		if(isCombatApparel) then
			item:OnClick("left", nil, nil, true); -- mouse_button, bSkipMessageBox, bForceUsing, bShowStatsDiff, bSkipBindingTest
		else
			item:OnClick("left");
		end
	elseif(name == "use_item_all") then
		if(item.UseAll) then
			item:UseAll();
		end
	elseif(name == "cut_gem") then
		if(System.options.version == "kids") then
			NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30042_SueSue_equipment_cutgem_panel.lua");
			MyCompany.Aries.Quest.NPCs.SueSue_equipment_cutgem_panel.ShowPage();
		else
			local gsid;
			-- just in case the gsid is not equipment 
			if( gsItem.template.class == 1) then
				gsid = item.gsid;
			end
			NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30042_SueSue_equipment_cutgem.teen.lua");
			local Retrieve_gems_from_equipment = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Retrieve_gems_from_equipment");
			Retrieve_gems_from_equipment.ShowPage(gsid);
		end
	elseif(name == "cut_combatpet_gem") then
		if(System.options.version == "kids") then
			NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetPane.lua");
			local CombatPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPane");
			CombatPetPane.ShowPage();
		end
	elseif(name == "merge_gem") then
		NPL.load("(gl)script/apps/Aries/Desktop/GemMerge.lua");
		MyCompany.Aries.Desktop.GemMerge.ShowMainWnd();
	elseif(name == "mount_gem") then
		if(System.options.version == "kids") then
			NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30042_SueSue_equipment_extend_panel.lua");
			MyCompany.Aries.Quest.NPCs.SueSue_equipment_extend_panel.ShowPage();
		else
			local gsid;
			-- just in case the gsid is not equipment 
			if( gsItem.template.class == 1) then
				gsid = item.gsid;
			end
			NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemAttachPage.lua");
			local GemAttachPage = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemAttachPage");
			GemAttachPage.ShowPage(gsid);
		end
	elseif(name == "sell_item") then
		if(item.guid) then
			NPL.load("(gl)script/apps/Aries/Desktop/ItemSellPanel.lua");
			MyCompany.Aries.Desktop.ItemSellPanel.OnClickSellItem(item.guid);
			--MyCompany.Aries.Desktop.ItemSellPanel.OnClickDiscardItem(item.guid);
		end
	elseif(name == "discard_item") then
		if(item.guid) then
			NPL.load("(gl)script/apps/Aries/Desktop/ItemSellPanel.lua");
			MyCompany.Aries.Desktop.ItemSellPanel.OnClickDiscardItem(item.guid);
		end
	elseif(name == "auction_item") then
		if(System.options.version == "kids") then
		else
			AuctionHouse.ShowPage("sell", true, item.gsid);
		end
	elseif(name == "upgrade_item") then
		NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_item_upgrade.lua");
		local Avatar_item_upgrade = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_item_upgrade");
		Avatar_item_upgrade.ShowPageWithGsid(item.gsid);
	elseif(name == "sign_item") then
		NPL.load("(gl)script/apps/Aries/Items/sign_item_page.lua");
		local sign_item_page = commonlib.gettable("MyCompany.Aries.Items.sign_item_page");
		sign_item_page.ShowPage(item);
	elseif(name == "item_guide") then
		ItemGuides.OnClickViewItem(item.gsid);
	elseif(name == "apparel_trans")then
		GemTranslationPage.ShowPage(item.gsid);
	elseif(name == "send_chat_link")then
		MyCompany.Aries.ChatSystem.ChatEdit.InsertSymbol(format("$%d", item.gsid), nil, format("[%s]", gsItem.template.name));
	elseif(name == "identify_item")then
		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/ItemCheckPage.lua");
		local ItemCheckPage = commonlib.gettable("MyCompany.Aries.Desktop.ItemCheckPage");
		ItemCheckPage.ShowPage(item.gsid);
	elseif(name == "open_cardpack") then
		NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
		local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
		DockTip.OnClick_Item_NeedShowBar(item.gsid);
	elseif(name == "cancel") then

	elseif(name == "goto_npc") then
		local npcidTable = gsItem.goto_npc;
		
		local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");
		local userinfo = ProfileManager.GetUserInfoInMemory();
		local userlevel = userinfo.combatlel;
		local npcid,item,_;

		for _,item in pairs(npcidTable) do
			if(item.maxlevel and item.minlevel) then
				if(userlevel <= tonumber(item.maxlevel) and userlevel >= tonumber(item.minlevel)) then
					npcid = tonumber(item.npcid);
					break;
				end
			else
				npcid = tonumber(item.npcid);
				break;
			end
		end


		NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
		local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
		WorldManager:GotoNPC(npcid);
	end
end