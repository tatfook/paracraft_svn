--[[
Title:
Author(s): Leio
Date: 2010/04/19
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Mail/MailState.lua");
local MailState = commonlib.gettable("MyCompany.Aries.Quest.Mail.MailState");
local b = MailState.CanSend_HappyNewYear_2011("2011-02-04")
commonlib.echo(b);
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/Scene/main.lua");
NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");

local Pet = commonlib.gettable("MyCompany.Aries.Pet");
local MailState = commonlib.gettable("MyCompany.Aries.Quest.Mail.MailState");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
local ItemManager = commonlib.gettable("System.Item.ItemManager");
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
--龙是否大于3级
function MailState.Pet3()
	if(not Pet.IsMyDragonFetchedFromSophie()) then
		return false;
	end
	local petLevel = 0;
	-- get pet level
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		petLevel = bean.level or 0;
	end
	if(petLevel < 3)then
		return false
	end
	return true;
end
function MailState.CanSend_CrystalBunny()
	local self = MailState;
	if(not self.Check_CrystalBunny)then
		self.Check_CrystalBunny = true;
		local pet3 = self.Pet3();
		if(pet3 == false)then
			return false;
		end
		NPL.load("(gl)script/apps/Aries/NPCs/DrDoctor/30376_CrystalBunny.lua");
		if(MyCompany.Aries.Quest.NPCs.CrystalBunny.IsOpened()
			 or MyCompany.Aries.Quest.NPCs.CrystalBunny.ExchangeFinishedFromDrDoctor()
			 or MyCompany.Aries.Quest.NPCs.CrystalBunny.HasBunny())then
			return false;
		end
		return true;
	end
end
function MailState.CanSend_DepressedBarth()
	local self = MailState;
	if(not self.Check_DepressedBarth)then
		self.Check_DepressedBarth = true;
		local pet3 = self.Pet3();
		if(pet3 == false)then
			return false;
		end

		NPL.load("(gl)script/apps/Aries/NPCs/DrDoctor/30390_DepressedBarth.lua");
		if(MyCompany.Aries.Quest.NPCs.DepressedBarth.IsOpened()
			 or MyCompany.Aries.Quest.NPCs.DepressedBarth.IsFinished())then
			return false;
		end
		return true;
	end
end

function MailState.CanSend_OpenCombat()
	return true;
end

function MailState.CanSend_Anti()
	local self = MailState;
	local remained_sec = AntiIndulgenceArea.GetRemainedSec();
	if(not AntiIndulgenceArea.show_time_mail)then
		if(remained_sec <= 0)then
			AntiIndulgenceArea.show_time_mail = true;
			return true;
		end
	end
end

function MailState.CanSend_MagicStar_Energe_0_6()
	local self = MailState;
	local bean = Pet.GetBean();
	if(bean) then
		local energy = bean.energy or 0;
		if(energy > 0 and energy < 6)then
			if(not MailState.CanSend_MagicStar_Energe_0_6_hassent)then
				MailState.CanSend_MagicStar_Energe_0_6_hassent = true;
				return true;
			end
		end
	end
end
function MailState.CanSend_MagicStar_Energe_0()
	local self = MailState;
	local bean = Pet.GetBean();
	if(bean) then
		if(not MailState.CanSend_MagicStar_Energe_0_hassent)then
			local energy = bean.energy or 0;
			local last_bean = Pet.Load_Local_Bean();
			if(energy == 0 and last_bean)then
				local last_energy = last_bean.energy;
				if(last_energy and last_energy > energy)then
					MailState.CanSend_MagicStar_Energe_0_hassent = true;
					return true;
				end
			end
		end
	end
end
function MailState.CanSend_Research_2010_12_10()
	local self = MailState;
	local serverDate = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local year,month,day = string.match(serverDate,"(.+)-(.+)-(.+)");
	year = tonumber(year);
	month = tonumber(month);
	day = tonumber(day);
	if(year and month and day and year == 2010 and month == 12 and (day >=9 and day <=16))then
		if(not hasGSItem(50319))then
			return true;
		end
	end
end

function MailState.CanSend_LuckyTree()
	if(not MailState.is_lucky_tree_sent) then
		MailState.is_lucky_tree_sent = true;
		local date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
		local key = string.format("MailState.CanSend_LuckyTree%s",date);
		local sent_date = MyCompany.Aries.Player.LoadLocalData(key,"");
		NPL.load("(gl)script/apps/Aries/Pet/main.lua");
		local bean = MyCompany.Aries.Pet.GetBean();
		if(bean and bean.combatlel < 6) then
			return false;
		end
		if(sent_date ~= date)then
			MyCompany.Aries.Player.SaveLocalData(key,date)
			return true;
		end
	else
		return false;
	end
end

function MailState.CanSend_HappyNewYear_2011(date)
	if(not date)then
		return
	end
	local gsid = 50335;
	local hasItem,guid = hasGSItem(gsid);
	if(hasItem)then
		local item = ItemManager.GetItemByGUID(guid);
		if(item)then
			local clientdata = item.clientdata;
			if(not clientdata or clientdata == "")then
				clientdata = "{}"
			end
			clientdata = commonlib.LoadTableFromString(clientdata);

			if(clientdata and type(clientdata) == "table")then
				local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
				--local today = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
				local function hasDate(gift_date)
					local k,v;
					for k,v in ipairs(clientdata) do
						if(gift_date and v.date == gift_date)then
							return true;
						end
					end
				end

				local hasSend = hasDate(today);
				if(not hasSend and date == today)then
					return true;
				end
			end
		end			
	end 
end