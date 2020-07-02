--[[
Title: a central place per application for selling and buying tradable items. 
Author(s): LiXizhi
Date: 2008/1/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.marketplace.test.lua");
paraworld.marketplace.TestGetCorrectBag()
paraworld.marketplace.TestGetWrongBag()
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

-- TODO: test passed by CYF on 2008.1.23. Test wrong ID
function paraworld.marketplace.TestGetWrongBag()
	local msg = {
		operation = "login",
		username = "LiXizhi",
		Password = "anything",
	}
	paraworld.auth.AuthUser(msg, "test", function (msg) 
		log("login OK\n")
		local sessionkey = msg.sessionkey;
		local userid = msg.userid;
		
		local msg = {
			operation = "get",
			sessionkey = sessionkey,
			userid = userid,
			appid = "Wrong ID"
		};
		paraworld.marketplace.GetBags(msg, "test", function(msg) 
			log("market OK\n")
			log(commonlib.serialize(msg))
		end)
	end)
end

-- TODO: test passed by CYF on 2008.1.23. Test correct ID
function paraworld.marketplace.TestGetCorrectBag()
	local msg = {
		operation = "login",
		username = "LiXizhi",
		Password = "anything",
	}
	paraworld.auth.AuthUser(msg, "test", function (msg) 
		log("login OK\n")
		local sessionkey = msg.sessionkey;
		local userid = msg.userid;
		
		local msg = {
			operation = "get",
			sessionkey = sessionkey,
			userid = userid,
			appid = "Correct ID"
		};
		paraworld.marketplace.GetBags(msg, "test", function(msg) 
			log("market OK\n")
			log(commonlib.serialize(msg))
		end)
	end)
end


--[[
paraworld.CreateRPCWrapper("paraworld.marketplace.GetBags", "http://marketplace.paraengine.com/AddBag.asmx");
paraworld.CreateRPCWrapper("paraworld.marketplace.AddBag", "http://marketplace.paraengine.com/AddBag.asmx");
paraworld.CreateRPCWrapper("paraworld.marketplace.RemoveBag", "http://marketplace.paraengine.com/RemoveBag.asmx");
]]