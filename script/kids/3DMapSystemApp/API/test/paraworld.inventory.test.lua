--[[
Title: a central place per application for selling and buying tradable items. 
Author(s): LiXizhi
Date: 2008/1/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.inventory.test.lua");
paraworld.inventory.Test_GetItemsInBag(input)
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");



-- %TESTCASE{"inventory.Test_GetItemsInBag", func = "paraworld.inventory.Test_GetItemsInBag", input = {bag="1"}}%
function paraworld.inventory.Test_GetItemsInBag(input)

	local msg = {
		bag = input.bag,
	};
	paraworld.inventory.GetItemsInBag(msg, "test", function(msg)
		log("==============paraworld.inventory.Test_GetItemsInBag  return:\n")
		log(commonlib.serialize(msg));
	end);
end

-- %TESTCASE{"inventory.Test_GetItemsInOPCBag", func = "paraworld.inventory.Test_GetItemsInOPCBag", input = {bag="1", nid=""}}%
function paraworld.inventory.Test_GetItemsInOPCBag(input)

	local msg = {
		bag = input.bag,
		nid = input.nid,
		cache_policy = "access plus 0 day",
	};
	paraworld.inventory.GetItemsInBag(msg, "test", function(msg)
		log("==============paraworld.inventory.Test_GetItemsInOPCBag  return:\n")
		commonlib.echo(msg);
	end);
end

-- %TESTCASE{"inventory.Test_SetClientData", func = "paraworld.inventory.Test_SetClientData", input = {guid="146", bag="10010", clientdata="so"}}%
function paraworld.inventory.Test_SetClientData(input)

	local msg = {
		guid = tonumber(input.guid),
		bag = tonumber(input.bag),
		clientdata = input.clientdata,
	};
	paraworld.inventory.SetClientData(msg, "test", function(msg)
		log("==============paraworld.inventory.Test_SetClientData  return:\n")
		log(commonlib.serialize(msg));
	end);
end


-- %TESTCASE{"inventory.Test_PurchaseItem", func = "paraworld.inventory.Test_PurchaseItem", input = {gsid=64, count=1, clientData=""}}%
function paraworld.inventory.Test_PurchaseItem(input)

	local msg = {
		gsid = input.gsid,
		count = input.count,
		clientData = input.clientData,
	};
	paraworld.inventory.PurchaseItem(msg, "test", function(msg)
		log("paraworld.inventory.Test_PurchaseItem  return:\n")
		log(commonlib.serialize(msg));
	end);
end


-- %TESTCASE{"inventory.Test_DestroyItem", func = "paraworld.inventory.Test_DestroyItem", input = {guid="1", count="1", bag="1"}}%
function paraworld.inventory.Test_DestroyItem(input)

	local msg = {
		guid = input.guid,
		count = input.count,
		bag = input.bag,
	};
	paraworld.inventory.DestroyItem(msg, "test", function(msg)
		log("paraworld.inventory.Test_DestroyItem  return:\n")
		log(commonlib.serialize(msg));
	end);
end


-- %TESTCASE{"inventory.Test_ExtendedCost", func = "paraworld.inventory.Test_ExtendedCost", input = {exid="1", froms="1", bags="12"}}%
function paraworld.inventory.Test_ExtendedCost(input)
	local msg = {
		exid = tonumber(input.exid),
		froms = input.froms,
		bags = input.bags,
	};
	paraworld.inventory.ExtendedCost(msg, "test", function(msg)
		log("==================\n")
		log("paraworld.inventory.Test_ExtendedCost return:\n")
		commonlib.echo(msg);
	end);
end

-- %TESTCASE{"inventory.Test_GetExtendedCost", func = "paraworld.inventory.Test_GetExtendedCost", input = {exid="1", cache_policy = "access plus 1 minute"}}%
function paraworld.inventory.Test_GetExtendedCost(input)
	local msg = {
		exid = tonumber(input.exid),
		cache_policy = input.cache_policy,
	};
	paraworld.inventory.GetExtendedCost(msg, "test", function(msg)
		log("==================\n")
		log("paraworld.inventory.Test_GetExtendedCost return:\n")
		commonlib.echo(msg);
	end);
end

-- %TESTCASE{"inventory.Test_SellItem", func = "paraworld.inventory.Test_SellItem", input = {guid=1260, bag=1, cnt=1}}%
function paraworld.inventory.Test_SellItem(input)

	local msg = {
		guid = input.guid,
		bag = input.bag,
		cnt = input.cnt,
	};
	paraworld.inventory.SellItem(msg, "test", function(msg)
		log("paraworld.inventory.Test_SellItem  return:\n")
		log(commonlib.serialize(msg));
	end);
end