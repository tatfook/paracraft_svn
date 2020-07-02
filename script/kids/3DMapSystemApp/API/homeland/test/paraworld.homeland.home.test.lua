--[[
Title: 
Author(s): Leio
Date: 2008/4/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/test/paraworld.homeland.home.test.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/paraworld.homeland.home.lua");
-- %TESTCASE{"GetHomeInfo", func = "paraworld.homeland.home.GetHomeInfo_Test", input ={nid = "12713"}}%
function paraworld.homeland.home.GetHomeInfo_Test(input)
	local msg = {
		nid = input.nid,
	}
	paraworld.homeland.home.GetHomeInfo(msg,"home",function(msg)	
		log(commonlib.serialize(msg));
	end);
end
-- %TESTCASE{"SendFlower", func = "paraworld.homeland.home.SendFlower_Test", input ={homeuid = "71d6a011-69da-4a4a-bcea-750d2ac954cd"}}%
function paraworld.homeland.home.SendFlower_Test(input)
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		homeuid = input.homeuid,
	}
	paraworld.homeland.home.SendFlower(msg,"home",function(msg)	
		log(commonlib.serialize(msg));
	end);
end
-- %TESTCASE{"SendPug", func = "paraworld.homeland.home.SendPug_Test", input ={homeuid = "71d6a011-69da-4a4a-bcea-750d2ac954cd"}}%
function paraworld.homeland.home.SendPug_Test(input)
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		homeuid = input.homeuid,
	}
	paraworld.homeland.home.SendPug(msg,"home",function(msg)	
		log(commonlib.serialize(msg));
	end);
end
-- %TESTCASE{"Update", func = "paraworld.homeland.home.Update_Test", input ={name = "测试名称"}}%
function paraworld.homeland.home.Update_Test(input)
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		name = input.name,
	}
	paraworld.homeland.home.Update(msg,"home",function(msg)	
		log(commonlib.serialize(msg));
	end);
end
-- %TESTCASE{"Visit", func = "paraworld.homeland.home.Visit_Test", input ={homeuid = "71d6a011-69da-4a4a-bcea-750d2ac954cd"}}%
function paraworld.homeland.home.Visit_Test(input)
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		homeuid = input.homeuid,
	}
	paraworld.homeland.home.Visit(msg,"home",function(msg)	
		log(commonlib.serialize(msg));
	end);
end


