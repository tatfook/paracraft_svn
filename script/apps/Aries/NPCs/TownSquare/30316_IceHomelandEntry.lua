--[[
Title: IceHomelandEntry
Author(s): WangTian
Date: 2009/8/20

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30316_IceHomelandEntry.lua
------------------------------------------------------------
]]

-- create class
local libName = "IceHomelandEntry";
local IceHomelandEntry = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.IceHomelandEntry", IceHomelandEntry);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- 39101_SnowHomelandTemplate

-- ChristmasTree.main
function IceHomelandEntry.main()
end

function IceHomelandEntry.PreDialog()
	return true;
end

function IceHomelandEntry.TryExchange()
	local bHas_39101, guid_39101 = hasGSItem(39101);
	local bEquip_39101 = equipGSItem(39101);
	if(bHas_39101 and bEquip_39101) then
		--if(not equipGSItem(39101)) then
			--local item = ItemManager.GetItemByGUID(guid_39101);
			--if(item and item.guid > 0) then
				--item:OnClick("left");
			--end
		--end
		_guihelper.MessageBox([[<div style="margin-top:30px;margin-left:20px;">你已经住在冰雪之家啦，去换点别的吧！</div>]]);
	else
		local bHas_17016, guid_17016, __, copies_17016 = hasGSItem(17016, 12);
		local bHas_17017, guid_17017, __, copies_17017 = hasGSItem(17017, 12);
		local bHas_17018, guid_17018, __, copies_17018 = hasGSItem(17018, 12);
		local bHas_17019, guid_17019, __, copies_17019 = hasGSItem(17019, 12);
		local bHas_17020, guid_17020, __, copies_17020 = hasGSItem(17020, 12);
		local bHas_17021, guid_17021, __, copies_17021 = hasGSItem(17021, 12);
		local bHas_17022, guid_17022, __, copies_17022 = hasGSItem(17022, 12);
		if(bHas_17016 and bHas_17017 and bHas_17018 and bHas_17019 and bHas_17020 and bHas_17021 and bHas_17022 and 
			copies_17016 >= 2 and 
			copies_17017 >= 2 and 
			copies_17018 >= 2 and 
			copies_17019 >= 2 and 
			copies_17020 >= 2 and 
			copies_17021 >= 2 and 
			copies_17022 >= 2) then
			
			local froms = guid_17016..",2|"..guid_17017..",2|"..guid_17018..",2|"..guid_17019..",2|"..guid_17020..",2|"..guid_17021..",2|"..guid_17022..",2|";
			local bags = {12, 12, 12, 12, 12, 12, 12};
			
			-- extended cost bubble machine
			-- old exid 140: Get_39101_SnowHomelandTemplate
			-- exid 294: MoveTo_39101_SnowHomelandTemplate 
			ItemManager.ExtendedCost(294, froms, bags, function(msg)end, function(msg)
				log("+++++++ExtendedCost 294: MoveTo_39101_SnowHomelandTemplate return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess) then
					local bHas_39101, guid_39101 = hasGSItem(39101)
					if(bHas_39101) then
						if(not equipGSItem(39101)) then
							local item = ItemManager.GetItemByGUID(guid_39101);
							if(item and item.guid > 0) then
								item:UseItem(function(msg)
									if(msg.issuccess) then
										_guihelper.MessageBox([[<div style="margin-top:24px;margin-left:10px;">恭喜你已经成功搬到冰雪之家了，赶紧回家看看去吧！</div>]]);
									end
								end);
							end
						end
					end
				end
			end);
		else
			_guihelper.MessageBox([[<div style="margin-top:24px;margin-left:10px;">很抱歉，你的卡片不足，去泡泡机的礼盒里多去找找再来吧！</div>]]);
		end
	end
end