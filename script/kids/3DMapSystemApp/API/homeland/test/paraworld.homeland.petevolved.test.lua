--[[
Title: 
Author(s): Leio
Date: 2008/4/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/test/paraworld.homeland.petevolved.test.lua");
leio  petid:2
leio1 petid:5
leio2 petid:3
leio3 petid:4
http://192.168.0.51:83/API/GoGoGo?petid=2&h=25
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/paraworld.homeland.petevolved.lua");

-- Update
-- %TESTCASE{"Update", func = "paraworld.homeland.petevolved.Update_Test", input ={id = "2", nickname = "gg"}}%
function paraworld.homeland.petevolved.Update_Test(input)
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		id = tonumber(input.id),
		nickname = input.nickname,
	}
	paraworld.homeland.petevolved.Update(msg,"petevolved",function(msg)	
		log("paraworld.homeland.petevolved.Update===============\n")
		log(commonlib.serialize(msg));
	end);
end
-- Get
-- %TESTCASE{"Get", func = "paraworld.homeland.petevolved.Get_Test", input = {nid = "19612", id = "527", cache_policy = "access plus 0 seconds",}}%
function paraworld.homeland.petevolved.Get_Test(input)
	local msg = {
		nid = input.nid,
		id = input.id,
		cache_policy = input.cache_policy or nil,
	}
	paraworld.homeland.petevolved.Get(msg,"petevolved",function(msg)	
		log("paraworld.homeland.petevolved.Get===============\n")
		log(commonlib.serialize(msg));
	end);
end
-- Caress
-- %TESTCASE{"Caress", func = "paraworld.homeland.petevolved.Caress_Test", input ={id = "2",}}%
function paraworld.homeland.petevolved.Caress_Test(input)
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		petid = input.id,
	}
	paraworld.homeland.petevolved.Caress(msg,"petevolved",function(msg)	
		log(commonlib.serialize(msg));
	end);
end
-- UseItem
-- %TESTCASE{"UseItem", func = "paraworld.homeland.petevolved.UseItem_Test", input ={id = "2", itemgsid = "1",}}%
function paraworld.homeland.petevolved.UseItem_Test(input)
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		itemgsid = input.itemgsid,
		petid = input.id,
	}
	paraworld.homeland.petevolved.UseItem(msg,"petevolved",function(msg)	
		log(commonlib.serialize(msg));
	end);
end
