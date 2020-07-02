--[[
Title: 全齐齐
Author(s): zrf
Date: 2010/12/09

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/FireCave/30507_QuanQiQi.lua");
------------------------------------------------------------
]]

local QuanQiQi = commonlib.gettable("MyCompany.Aries.Quest.NPCs.QuanQiQi");
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

function QuanQiQi.Init()
	if(QuanQiQi.tick == nil)then
		QuanQiQi.LoadExchangeNum1();
	end
end

function QuanQiQi.HasHuoYu()
	local bHas, guid, _, copies = hasGSItem(17143);
	if(bHas and copies >= 3)then
		return true;
	else
		return false;
	end
end

function QuanQiQi.SaveExchangeNum()
	local gsid = 50318;
	local bag = 30011;
	local scene = commonlib.gettable("MyCompany.Aries.Scene");
	ItemManager.GetItemsInBag(bag, "30507_QuanQiQi", function(msg)
		local hasitem, guid = hasGSItem(gsid);
		if(hasitem)then
			local item = ItemManager.GetItemByGUID(guid);
			if(item)then
				local clientdata = item.clientdata;
				if( clientdata=="")then
					clientdata="{}";
				end
				clientdata = commonlib.LoadTableFromString(clientdata);
				clientdata.date = scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
				clientdata.tick = QuanQiQi.tick;
				local clientdata = commonlib.serialize_compact2(clientdata);
				ItemManager.SetClientData( guid, clientdata, function(msg_setclientdata)end);
			end
		end
	end, "access plus 1 minutes");
end

function QuanQiQi.LoadExchangeNum2()
	local gsid = 50318;
	local bag = 30011;
	local hasitem, guid = hasGSItem(gsid);
	local scene = commonlib.gettable("MyCompany.Aries.Scene"); 
	if(hasitem)then
		local item = ItemManager.GetItemByGUID(guid);
		if(item)then
			local clientdata = item.clientdata;
			if( clientdata=="")then
				clientdata="{}";
			end
			clientdata = commonlib.LoadTableFromString(clientdata);

			if( clientdata and type(clientdata)=="table")then
				local date = clientdata.date;
				local today = scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");

				
				if(not(date and today==date))then
					QuanQiQi.tick = 0;
				else
					QuanQiQi.tick = clientdata.tick or 0;
				end 
			end
		end
	end
end

function QuanQiQi.LoadExchangeNum1()
	local gsid = 50318;
	local bag = 30011;

	ItemManager.GetItemsInBag(bag, "30507_QuanQiQi", function(msg)
		local hasitem, guid = hasGSItem(gsid);

		if(hasitem)then
			QuanQiQi.LoadExchangeNum2();
		else
			ItemManager.PurchaseItem(gsid, 1, function(msg) end, function(msg)
				if(msg and msg.issuccess) then
					QuanQiQi.LoadExchangeNum2();
				end
			end);
		end
	end, "access plus 1 minutes");
	return true;
end

function QuanQiQi.Exchange()

	ItemManager.ExtendedCost(604, nil, nil, function(msg)
		--commonlib.echo("!!!!!!!!!!!:Exchange");
		--commonlib.echo(msg);
		if(msg.issuccess == true)then
		--commonlib.echo("!!!!!!!!!!!:Exchange1");
				
			QuanQiQi.tick = QuanQiQi.tick + 1;
			QuanQiQi.SaveExchangeNum();
			_guihelper.Custom_MessageBox("恭喜恭喜，你成功兑换了2星面包！",function(result)
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});	
		end
	end);
	return true;
end

function QuanQiQi.CheckExchangeNum()
	if(QuanQiQi.tick and QuanQiQi.tick<5)then
		return true;
	else
		return false;
	end
end