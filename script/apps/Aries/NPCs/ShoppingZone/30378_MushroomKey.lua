--[[
Title: MushroomKey
Author(s): Leio
Date: 2010/04/24

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/ShoppingZone/30378_MushroomKey.lua
------------------------------------------------------------
]]
-- create class
local libName = "MushroomKey";
local MushroomKey = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.MushroomKey", MushroomKey);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- MushroomKey.main
function MushroomKey.main()
	local self = MushroomKey;
	self.LoadUserInfo();
	self.DeleteNPC();
end
function MushroomKey.PreDialog()
	local self = MushroomKey;
end
--是否已经有新的蘑菇小屋了（可以进入室内的）
function MushroomKey.HasNewHouse()
	local self = MushroomKey;
	local has = hasGSItem(30145);
	commonlib.echo("===============MushroomKey.HasNewHouse()");
	commonlib.echo(has);
	return has;
end
function MushroomKey.GetCountInBag(bag,gsid,output)
	if(not bag or not gsid)then return end
	local count = ItemManager.GetItemCountInBag(bag);
	local i;
	local copies = 0;
	commonlib.echo("============MushroomKey.GetCountInBag start");
	commonlib.echo({bag = bag, gsid = gsid});
	for i = 1, count do
		local item = ItemManager.GetItemByBagAndOrder(bag, i);
		if(item and item.gsid == gsid) then
			commonlib.echo(item);
			copies = copies + item.copies;
			if(output and type(output) == "table")then
				table.insert(output,{guid = item.guid , copies = item.copies});
			end
		end
	end
	commonlib.echo("============MushroomKey.GetCountInBag end");
	return copies;
end
function MushroomKey.HasOldHouse()
	local self = MushroomKey;
	commonlib.echo("===============MushroomKey.HasOldHouse()");
	--local __,__,__,copies_homeland = hasGSItem(30019,10001);
	local copies_homeland = self.GetCountInBag(10001,30019)
	commonlib.echo("=============copies_homeland");
	commonlib.echo(copies_homeland);
	
	--local __,__,__,copies_others = hasGSItem(30019,41);
	local copies_others = self.GetCountInBag(41,30019)
	commonlib.echo("=============copies_others");
	commonlib.echo(copies_others);
	
	local copies = copies_homeland + copies_others;
	commonlib.echo("=============copies");
	commonlib.echo(copies);
	if(copies > 0)then
		return true,copies;
	end
end
--检测用户的注册日期，如果是2010/04/30 以后注册的，删除兑换的NPC
function MushroomKey.LoadUserInfo()
	local self = MushroomKey;
	System.App.profiles.ProfileManager.GetUserInfo(System.User.nid, "MushroomKey.IsInRegister()", function(msg)
		if(msg and msg.users[1]) then
			local birthday = msg.users[1].birthday;
			commonlib.echo("=============check birthday");
			if(birthday)then
				local __,__,mon,day,year = string.find(birthday,"(.+)/(.+)/(.+) (.+)");
				mon = tonumber(mon);
				day = tonumber(day);
				year = tonumber(year);
				commonlib.echo({year = year, mon = mon, day = day});
				if(year and mon and day)then
					if(year == 2010)then
						if(mon > 4 )then
							self.isOldUser = "false";
							self.DeleteNPC();
						elseif(mon == 4)then
							if(day >= 30)then
								self.isOldUser = "false";
								self.DeleteNPC();
							else
								self.isOldUser = "true";
							end
						else
							self.isOldUser = "true";
						end
					elseif(year > 2010)then
						self.isOldUser = "false";
					else
						self.isOldUser = "true";
					end
				end
				commonlib.echo("=============self.isOldUser ");
				commonlib.echo(self.isOldUser );
			end
		end
	end);
end
--是否在注册日期之内
function MushroomKey.IsInRegister()
	local self = MushroomKey;
	if(self.isOldUser)then
		if(self.isOldUser == "false")then
			return false;
		end
	end
	return true;
end
function MushroomKey.CanGetKey()
	local self = MushroomKey;
	local has_new_house = self.HasNewHouse();
	local has_old_house = self.HasOldHouse();
	local in_reg = self.IsInRegister();
	commonlib.echo("===============MushroomKey.CanGetKey()");
	commonlib.echo(has_new_house);
	commonlib.echo(has_old_house);
	commonlib.echo(in_reg);
	return (not has_new_house and has_old_house and in_reg);
end
function MushroomKey.DeleteNPC()
	local self = MushroomKey;
	if(not self.CanGetKey())then
		--TODO:delete npc
		NPC.DeleteNPCCharacter(30378);
	end
end
function MushroomKey.DoFinished()
	local self = MushroomKey;
	if(not self.CanGetKey())then return end
	local has,copies = self.HasOldHouse();
	commonlib.echo("===============MushroomKey.DoFinished()");
	commonlib.echo(has);
	commonlib.echo(copies);
	if(has and copies)then
		commonlib.echo("======before SwitchTo_NewMushroomHouse");
		ItemManager.ExtendedCost(413, nil, nil, function(msg)end, function(msg)
				commonlib.echo("======after SwitchTo_NewMushroomHouse");
				commonlib.echo(msg);
				if(msg.issuccess) then
					NPC.DeleteNPCCharacter(30378,nil,true);
					if(copies > 1)then
						copies = copies - 1;
						if(copies == 1)then
							self.DoRecycle_DeprecatedMushroomHouse_1();
						elseif(copies == 2)then
							self.DoRecycle_DeprecatedMushroomHouse_2();
						end
					end
				end
		end)
	end
end
function MushroomKey.DoRecycle_DeprecatedMushroomHouse_1()
	commonlib.echo("======before DoRecycle_DeprecatedMushroomHouse_1");
	ItemManager.ExtendedCost(414, nil, nil, function(msg)end, function(msg)
		commonlib.echo("======after DoRecycle_DeprecatedMushroomHouse_1");
		commonlib.echo(msg);
		if(msg.issuccess) then
		end
	end)
end
function MushroomKey.DoRecycle_DeprecatedMushroomHouse_2()
	local self = MushroomKey;
	--local __,guid_homeland,__,__ = hasGSItem(30019,10001);
	local output_homeland = {};
	local copies_homeland = self.GetCountInBag(10001,30019,output_homeland)	;
	commonlib.echo("================output_homeland");
	commonlib.echo(copies_homeland);
	commonlib.echo(output_homeland);
	copies_homeland = copies_homeland or 0;
	
	--local __,guid_others,__,__ = hasGSItem(30019,41);
	local output_others = {};
	local copies_others = self.GetCountInBag(41,30019,output_others);	
	commonlib.echo("================output_others");
	commonlib.echo(copies_others);
	commonlib.echo(output_others);
	copies_others = copies_others or 0;
	local froms;
	local bags;
	local exID;
	if(copies_homeland == 2)then
		local copies = output_homeland[1].copies or 0;
		if(copies == 2)then
			froms = string.format("%d,2",output_homeland[1].guid);
		else
			froms = string.format("%d,1|%d,1",output_homeland[1].guid,output_homeland[2].guid);
		end
		bags = {10001};
		exID = 415;
	elseif(copies_others == 2)then
		local copies = output_others[1].copies or 0;
		if(copies == 2)then
			froms = string.format("%d,2",output_others[1].guid);
		else
			froms = string.format("%d,1|%d,1",output_others[1].guid,output_others[2].guid);
		end
		bags = {41};
		exID = 415;
	elseif(copies_homeland == 1 and copies_others == 1)then
		froms = string.format("%d,1|%d,1",output_homeland[1].guid,output_others[1].guid);
		bags = {10001,41};
		exID = 415;
	end
	
	commonlib.echo("======before DoRecycle_DeprecatedMushroomHouse");
	commonlib.echo(froms);
	commonlib.echo(bags);
	commonlib.echo(exID);
	if(froms and bags and exID)then
		ItemManager.ExtendedCost(exID, froms, bags, function(msg)end, function(msg)
				commonlib.echo("======after DoRecycle_DeprecatedMushroomHouse");
				commonlib.echo(msg);
				if(msg.issuccess) then
					------刷新bag
					--Map3DSystem.Item.ItemManager.GetItemsInBag(41, "", function(msg) 
						--end, "access plus 0 day");
					--Map3DSystem.Item.ItemManager.GetItemsInBag(10001, "", function(msg) 
						--end, "access plus 0 day");
					System.App.profiles.ProfileManager.GetUserInfo(nil, nil, nil, "access plus 0 day");
				end
		end)
	end
end