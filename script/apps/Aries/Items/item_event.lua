--[[
Title: item_event
Author(s): LiXizhi
Date: 2012/8/13
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Items/item_event.lua");
local item_event = commonlib.gettable("MyCompany.Aries.Items.item_event");
item_event.init();
------------------------------------------------------------
]]

local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
-- create class
local item_event = commonlib.gettable("MyCompany.Aries.Items.item_event");

-- load everything from file
function item_event.init()
	if(item_event.is_inited) then
		return
	end
	item_event.is_inited = true;
	
	-- ItemManager.GetEvents():AddEventListener("Item_CombatApparel_OnClick", item_event.OnClick, item_event, "item_event");
	ItemManager.GetEvents():AddEventListener("pe_slot_OnClick", item_event.OnClick, item_event, "item_event");
end

function item_event:OnClick(event)
	--if(System.options.version == "kids") then
		if(mouse_button == "left") then
			NPL.load("(gl)script/apps/Aries/Items/item_on_click_page.lua");
			local item_on_click_page = commonlib.gettable("MyCompany.Aries.Items.item_on_click_page");
			return item_on_click_page.ShowPage(event.item);
		else
			if(event.item and event.item.OnClick and event.item.gsid) then
				local isCombatApparel = false;
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(event.item.gsid);
				if(gsItem) then
					if(string.find(string.lower(gsItem.category), "combat")) then
						isCombatApparel = true;
					end
				end
				if(isCombatApparel) then
					event.item:OnClick("left", nil, nil, true); -- mouse_button, bSkipMessageBox, bForceUsing, bShowStatsDiff, bSkipBindingTest
				else
					event.item:OnClick("left");
				end
				return true;
			end
		end
	--end
end