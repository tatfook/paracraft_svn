--[[
Title: code behind for page 30071_MicroOven_panel.html
Author(s): WangTian
Date: 2009/10/13
Desc:  script/apps/Aries/NPCs/Playground/30071_MicroOven_panel.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local MicroOvenPanelPage = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.MicroOvenPanelPage", MicroOvenPanelPage);

local page;
function MicroOvenPanelPage.OnInit()
	page = document:GetPageCtrl();
end

-- clear the selected item index
function MicroOvenPanelPage.ClearSelectedItems()
	MicroOvenPanelPage.selected1_gsid = nil;
	MicroOvenPanelPage.selected2_gsid = nil;
	MicroOvenPanelPage.selected3_gsid = nil;
	MicroOvenPanelPage.selected1_guid = nil;
	MicroOvenPanelPage.selected2_guid = nil;
	MicroOvenPanelPage.selected3_guid = nil;
	MicroOvenPanelPage.method = nil;
end

-- The data source for items
function MicroOvenPanelPage.DS_Func_Items(dsTable, index, pageCtrl)
	-- very tricky to keep a reference of the dstable and reset the status explicitly
	MicroOvenPanelPage.dsTable = dsTable;
    if(not dsTable.status) then
        -- use a default cache
        if(index == nil) then
			dsTable.Count = 100;
			MicroOvenPanelPage.GetItems(class, subclass, bag, pageCtrl, "access plus 20 minutes", dsTable);
			return dsTable.Count;
        else
			if(index <= 100) then
				return {guid = 0};
			end
        end
    elseif(dsTable.status == 2) then
        if(index == nil) then
			return dsTable.Count;
        else
			return dsTable[index];
        end
    end 
end

function MicroOvenPanelPage.GetItems(class, subclass, bag, pageCtrl, cachepolicy, output)
	-- find the right bag for inventory items
	local bags;
	if(bags == nil) then
		bags = {12};
	end
	-- fetching inventory items
	output.status = 1;
	local ItemManager = System.Item.ItemManager;
	bags.ReturnCount = 0;
	local _, bag;
	for _, bag in ipairs(bags) do
		ItemManager.GetItemsInBag(bag, "ariesitems_"..bag, function(msg)
			bags.ReturnCount = bags.ReturnCount + 1;
			if(bags.ReturnCount >= #bags) then
				if(msg and msg.items) then
					local count = 0;
					local __, bag;
					for __, bag in ipairs(bags) do
						local i;
						for i = 1, ItemManager.GetItemCountInBag(bag) do
							local item = ItemManager.GetItemByBagAndOrder(bag, i);
							if(item ~= nil) then
								local selected = false;
								if(item.guid == MicroOvenPanelPage.selected1_guid) then
									selected = true;
								elseif(item.guid == MicroOvenPanelPage.selected2_guid) then
									selected = true;
								elseif(item.guid == MicroOvenPanelPage.selected3_guid) then
									selected = true;
								end
								
								if(item.gsid == 17001 or item.gsid == 17002 or item.gsid == 17005 or item.gsid == 17006 or 
									item.gsid == 17008 or item.gsid == 17010 or item.gsid == 17012 or item.gsid == 17015 or
									item.gsid == 17031 or item.gsid == 17032 or item.gsid == 17033 or item.gsid == 17044 or 
									item.gsid == 17049 or item.gsid == 17046 or item.gsid == 17048) then
									count = count + 1;
									output[count] = {guid = item.guid, selected = selected, };
								end
							end
						end
					end
					-- fill the 4 tiles per page
					local displaycount = math.ceil(count/4) * 4;
					if(count == 0) then
						displaycount = 4;
					end
					local i;
					for i = count + 1, displaycount do
						output[i] = {guid = 0};
					end
					output.Count = displaycount;
				end
				commonlib.resize(output, output.Count);
				-- fetched inventory items
				output.status = 2;
				pageCtrl:Refresh(0.1);
			end
		end, cachepolicy);
	end
end

-- start cooking on the selected items
function MicroOvenPanelPage.StartCooking()
	if(not MicroOvenPanelPage.selected1_gsid or not MicroOvenPanelPage.selected2_gsid or not MicroOvenPanelPage.selected3_gsid) then
		_guihelper.MessageBox("要放入三种食材才行哦，你放入的食材还不够呢，炉子是不会工作的哦。");
		return
	end
	if(not MicroOvenPanelPage.method) then
		_guihelper.MessageBox("快选择一种烹饪方法哦。");
		return
	end
	
	local gsids = MicroOvenPanelPage.selected1_gsid..","..MicroOvenPanelPage.selected2_gsid..","..MicroOvenPanelPage.selected3_gsid;
	gsids = commonlib.Encoding.SortCSVString(gsids);
	
	local ItemManager = System.Item.ItemManager;
	local type = "free";
	
	local cookedfood_gsid = 16001;
	if(gsids == "17002,17008,17015" and MicroOvenPanelPage.method == "bake") then
		type = "extendedcost";
		cookedfood_gsid = 16012;
		--34 Get_16012_PineApplePie
		ItemManager.ExtendedCost(34, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost MircoOven Get_16012_PineApplePie return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(gsids == "17001,17005,17015" and MicroOvenPanelPage.method == "boil") then
		type = "extendedcost";
		cookedfood_gsid = 16013;
		--35 Get_16013_CherryBall
		ItemManager.ExtendedCost(35, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost MircoOven Get_16013_CherryBall return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(gsids == "17005,17006,17008" and MicroOvenPanelPage.method == "boil") then
		type = "extendedcost";
		cookedfood_gsid = 16014;
		--36 Get_16014_HoneyBeeHiveSoup
		ItemManager.ExtendedCost(36, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost MircoOven Get_16014_HoneyBeeHiveSoup return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
		
	elseif(gsids == "17002,17031,17032" and MicroOvenPanelPage.method == "steam") then
		type = "extendedcost";
		cookedfood_gsid = 16001;
		--132 Get_16001_SeaweedFlavorCone
		ItemManager.ExtendedCost(132, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost MircoOven Get_16001_SeaweedFlavorCone return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
		
	elseif(gsids == "17001,17010,17032" and MicroOvenPanelPage.method == "bake") then
		type = "extendedcost";
		cookedfood_gsid = 16002;
		-- 149 Get_16002_DeliciousPizza
		ItemManager.ExtendedCost(149, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost MircoOven Get_16002_DeliciousPizza return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(gsids == "17006,17012,17031" and MicroOvenPanelPage.method == "steam") then
		type = "extendedcost";
		cookedfood_gsid = 16021;
		-- 150 Get_16021_AssoetedSeafood
		ItemManager.ExtendedCost(150, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost MircoOven Get_16021_AssoetedSeafood return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
		
	elseif(gsids == "17006,17012,17033" and MicroOvenPanelPage.method == "boil") then
		type = "extendedcost";
		cookedfood_gsid = 16022;
		-- 152 Get_16022_HotWatermelonDrink
		ItemManager.ExtendedCost(152, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost MircoOven Get_16022_HotWatermelonDrink return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(gsids == "17008,17010,17033" and MicroOvenPanelPage.method == "steam") then
		type = "extendedcost";
		cookedfood_gsid = 16023;
		-- 151 Get_16023_SweetWatermelonEgg
		ItemManager.ExtendedCost(151, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost MircoOven Get_16023_SweetWatermelonEgg return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
		
	elseif(gsids == "17006,17008,17044" and MicroOvenPanelPage.method == "steam") then
		type = "extendedcost";
		cookedfood_gsid = 16024;
		-- 276 Get_16024_SweetRiceCake
		ItemManager.ExtendedCost(276, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost MircoOven Get_16024_SweetRiceCake return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(gsids == "17010,17015,17049" and MicroOvenPanelPage.method == "boil") then
		type = "extendedcost";
		cookedfood_gsid = 16025;
		-- 277 Get_16025_PearlTangYuan
		ItemManager.ExtendedCost(277, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost MircoOven Get_16025_PearlTangYuan return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(gsids == "17010,17012,17046" and MicroOvenPanelPage.method == "bake") then
		type = "extendedcost";
		cookedfood_gsid = 16026;
		-- 278 Get_16026_PlumFlavorTart 
		ItemManager.ExtendedCost(278, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost MircoOven Get_16026_PlumFlavorTart return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(gsids == "17001,17006,17048" and MicroOvenPanelPage.method == "boil") then
		type = "extendedcost";
		cookedfood_gsid = 16027;
		-- 279 Get_16027_WishComeTrueSoup 
		ItemManager.ExtendedCost(279, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost MircoOven Get_16027_WishComeTrueSoup return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
		
	else
		type = "free";
		-- manually delete the raw materials
		System.Item.ItemManager.DestroyItem(MicroOvenPanelPage.selected1_guid, 1, function(msg) 
			log("+++++++ Destroy raw food gsid:"..tostring(MicroOvenPanelPage.selected1_gsid).." guid:"..(MicroOvenPanelPage.selected1_guid or "") .." return: +++++++\n")
			commonlib.echo(msg);
		end);
		System.Item.ItemManager.DestroyItem(MicroOvenPanelPage.selected2_guid, 1, function(msg) 
			log("+++++++ Destroy raw food gsid:"..tostring(MicroOvenPanelPage.selected2_gsid).." guid:"..(MicroOvenPanelPage.selected2_guid or "").." return: +++++++\n")
			commonlib.echo(msg);
		end);
		System.Item.ItemManager.DestroyItem(MicroOvenPanelPage.selected3_guid, 1, function(msg) 
			log("+++++++ Destroy raw food gsid:"..tostring(MicroOvenPanelPage.selected3_gsid).." guid:"..(MicroOvenPanelPage.selected3_guid or "").." return: +++++++\n")
			commonlib.echo(msg);
		end);
		-- pick a random item
		--30 Free_16003_VanillaCake
		--31 Free_16015_FlavouredPineApple
		--32 Free_16016_ChocolatePuff
		--33 Free_16017_FragransMilkCake
		local bHas, guid = ItemManager.IfOwnGSItem(999);
		if(bHas and guid) then
			local exid = math.random(30, 33);
			if(exid == 30) then
				cookedfood_gsid = 16003;
			elseif(exid == 31) then
				cookedfood_gsid = 16015;
			elseif(exid == 32) then
				cookedfood_gsid = 16016;
			elseif(exid == 33) then
				cookedfood_gsid = 16017;
			end
			ItemManager.ExtendedCost(exid, nil, nil, function() 
				log("+++++++ Extended cost MircoOven exid:"..exid.." return: +++++++\n")
				commonlib.echo(msg);
			end);
		end
	end
	
	local name = "";
	local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(cookedfood_gsid);
	if(gsItem) then
		name = gsItem.template.name;
	end
	
	if(type == "extendedcost") then
		_guihelper.MessageBox(string.format([[<div style="margin-left:-10px;margin-top:10px;margin-right:-10px;">神奇的微波炉做出了一份美味的<div style="float:left;color:#FF0000">%s</div><div style="float:left;">，</div><br/><div style="">已经放入抱抱龙的背包里了。</div></div>]], name));
	elseif(type == "free") then
		_guihelper.MessageBox(string.format([[<div style="margin-top:10px;">喔噢～这样做菜我还真没尝试过，你只得到了<br/>一份<div style="float:left;color:#FF0000">%s</div><div style="float:left;">，</div><div style="float:left;">如果想让抱抱龙喜欢</div><br/>吃你做的食物，最好还是看看我们的食谱吧。</div>]], name));
	end
	
	--System.Item.ItemManager.DestroyItem(MicroOvenPanelPage.selected1_guid, 1, function() 
		--log("+++++++ Destroy raw food gsid:"..MicroOvenPanelPage.selected1_gsid.." guid:"..MicroOvenPanelPage.selected1_guid.." return: +++++++\n")
		--commonlib.echo(msg);
	--end);
	--System.Item.ItemManager.DestroyItem(MicroOvenPanelPage.selected2_guid, 1, function() 
		--log("+++++++ Destroy raw food gsid:"..MicroOvenPanelPage.selected2_gsid.." guid:"..MicroOvenPanelPage.selected2_guid.." return: +++++++\n")
		--commonlib.echo(msg);
	--end);
	--System.Item.ItemManager.DestroyItem(MicroOvenPanelPage.selected3_guid, 1, function() 
		--log("+++++++ Destroy raw food gsid:"..MicroOvenPanelPage.selected3_gsid.." guid:"..MicroOvenPanelPage.selected3_guid.." return: +++++++\n")
		--commonlib.echo(msg);
	--end);
	--
	--System.Item.ItemManager.PurchaseItem(cookedfood_gsid, 1, function() 
		--log("+++++++ Purchase food gsid:"..cookedfood_gsid.." return: +++++++\n")
		--commonlib.echo(msg);
	--end);
	
	
	MicroOvenPanelPage.ClearSelectedItems();
	-- refresh with the item selected
	--page:Init(page.url);
	page:Refresh(0.01);
end

-- choose cooking method
-- @param method: "steam" | "bake" | "boil"
function MicroOvenPanelPage.ChooseCookingMethod(method)
	if(not MicroOvenPanelPage.selected1_gsid or not MicroOvenPanelPage.selected2_gsid or not MicroOvenPanelPage.selected3_gsid) then
		_guihelper.MessageBox("要放入三种食材才行哦，你放入的食材还不够呢，炉子是不会工作的哦。");
		return
	end
	if(method == "steam") then
		page:SetValue("glass", "Texture/Aries/NPCs/MicroOven/glass_32bits.png");
		MicroOvenPanelPage.method = "steam";
	elseif(method == "bake") then
		page:SetValue("glass", "Texture/Aries/NPCs/MicroOven/glass_32bits.png");
		MicroOvenPanelPage.method = "bake";
	elseif(method == "boil") then
		page:SetValue("glass", "Texture/Aries/NPCs/MicroOven/glass_32bits.png");
		MicroOvenPanelPage.method = "boil";
	end
	
	-- automatically start cooking
	MicroOvenPanelPage.ChosenMethod = true;
	-- refresh with the item selected
	--page:Init(page.url);
	page:Refresh(0.01);
end

-- select one of the raw food to 3 selected slots
function MicroOvenPanelPage.OnClickItem(guid, mcmlNode)
	local ItemManager = System.Item.ItemManager;
	local item = ItemManager.GetItemByGUID(guid);
	local gsid;
	if(item and item.guid > 0) then
		gsid = item.gsid;
	end
	if(gsid) then
		if(MicroOvenPanelPage.selected1_gsid == nil) then
			MicroOvenPanelPage.selected1_gsid = gsid;
			MicroOvenPanelPage.selected1_guid = guid;
		elseif(MicroOvenPanelPage.selected2_gsid == nil) then
			if(MicroOvenPanelPage.selected1_gsid ~= gsid) then
				MicroOvenPanelPage.selected2_gsid = gsid;
				MicroOvenPanelPage.selected2_guid = guid;
			end
		elseif(MicroOvenPanelPage.selected3_gsid == nil) then
			if(MicroOvenPanelPage.selected1_gsid ~= gsid and MicroOvenPanelPage.selected2_gsid ~= gsid) then
				MicroOvenPanelPage.selected3_gsid = gsid;
				MicroOvenPanelPage.selected3_guid = guid;
			end
		else
			_guihelper.MessageBox("你已经选好3份食材了，快选择一种烹饪方法吧。");
		end
		-- refresh with the item selected
		--page:Init(page.url);
		page:SetValue("slot1", MicroOvenPanelPage.selected1_gsid);
		page:SetValue("slot2", MicroOvenPanelPage.selected2_gsid);
		page:SetValue("slot3", MicroOvenPanelPage.selected3_gsid);
		if(MicroOvenPanelPage.dsTable) then
			-- very tricky to keep a reference of the dstable and reset the status explicitly
			MicroOvenPanelPage.dsTable.status = nil;
		end
		page:Refresh(0.01);
	end
end