--[[
Title: code behind for page QuestStatusDragon.html
Author(s): WangTian
Date: 2009/7/22
Desc:  script/apps/Aries/Quest/QuestStatusDragon.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local QuestStatusDragonPage = {};
commonlib.setfield("MyCompany.Aries.Desktop.QuestArea.QuestStatusDragonPage", QuestStatusDragonPage);

-- The data source for items
function QuestStatusDragonPage.DS_Func_QuestStatusDragon(dsTable, index, pageCtrl)
    if(index == nil) then
		local dragonQuestCount = 0;
		local page_url, param;
		local statusList = commonlib.getfield("MyCompany.Aries.Desktop.QuestArea.StatusList") or {}
		
		local ItemManager = System.Item.ItemManager;
		local hasGSItem = ItemManager.IfOwnGSItem;
		
		for page_url, param in pairs(statusList) do
			if(param.type == "dragon") then
				dragonQuestCount = dragonQuestCount + 1;
				dsTable[dragonQuestCount] = {gsid = param.gsid, title = param.title, page_url = param.page_url};
				
				local obtaintime;
				local bHas, guid = hasGSItem(param.gsid);
				if(bHas) then
					local item = ItemManager.GetItemByGUID(guid);
					if(item and item.guid > 0) then
						obtaintime = item.obtaintime;
					end
				end
				
				dsTable[dragonQuestCount].obtaintime = obtaintime or "3000-10-10 10:10:10";
			end
		end
		
		-- sort the table according to the obtaintime
		-- TODO: sort the table according to the order: operation --> random --> growing
		table.sort(dsTable, function(a, b)
			return (a.obtaintime > b.obtaintime);
		end)
		
		local count = dragonQuestCount;
		if(count == 0) then
			count = 1;
		end
		-- fill the 6 tiles per page
		count = math.ceil(count/6) * 6;
		
		local i
		for i = (dragonQuestCount + 1), count do
			dsTable[i] = {gsid = 0, title = "", page_url = "", obtaintime = "1000-10-10 10:10:10"};
		end
		
		return count;
    elseif(index > 0) then
		return dsTable[index];
    end
end
