--[[
Title: a central place per application for selling and buying tradable items. 
Author(s): LiXizhi,CYF
Date: 2008/1/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.friends.test.lua");
paraworld.friends.remove_Test()
paraworld.friends.add_Test()
paraworld.friends.get_Test()
paraworld.friends.Test()

-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

function paraworld.friends.Test()
end

--[[
paraworld.CreateRPCWrapper("paraworld.friends.areFriends", "http://friends.paraengine.com/areFriends.asmx");
paraworld.CreateRPCWrapper("paraworld.friends.get", "http://friends.paraengine.com/get.asmx");
paraworld.CreateRPCWrapper("paraworld.friends.add", "http://friends.paraengine.com/add.asmx");
paraworld.CreateRPCWrapper("paraworld.friends.remove", "http://friends.paraengine.com/remove.asmx");
]]


--passed: 取得指定用户的所有好友
-- %TESTCASE{"friends.get", func = "paraworld.friends.get_Test", input ={uid = "e0dba2eb-8495-4b7d-8c3c-cf76d7cc85df",pageindex = 0, onlyonline = 0, order = 1, isinverse = 0}}%
function paraworld.friends.get_Test(input)
	local msg = {
		uid = input.uid or "e0dba2eb-8495-4b7d-8c3c-cf76d7cc85df",
		pageindex = input.pageindex or 0,
		onlyonline = input.onlyonline or 0,
		order = input.order or 1,
		isinverse = input.isinverse or 0
	};
	paraworld.friends.get(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end



--TODO: 新增一条好友记录
-- %TESTCASE{"friends.add", func = "paraworld.friends.add_Test", input ={appkey = "fae5feb1-9d4f-4a78-843a-1710992d4e72", sessionkey = "f770dcfe-cd18-4e05-9d2f-6eb1f1859864", frienduserid = "0a3b1121-b72f-4100-9943-bf0bacf7d045", relationType = 0}}%
function paraworld.friends.add_Test(input)
	local msg = {
		appkey = input.appkey or "fae5feb1-9d4f-4a78-843a-1710992d4e72",
		sessionkey = input.sessionkey or Map3DSystem.User.sessionkey,
		frienduserid = input.frienduserid or "58a53508-3ed7-4d17-8155-0e1eff36eed9",
		relationType = input.relationType or 0
	};
	paraworld.friends.add(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end



--TODO: 移除两个用户之间的关系
-- %TESTCASE{"friends.remove", func = "paraworld.friends.remove_Test", input ={sessionkey = "f48c3a0c-8dd1-492d-a24d-eac57aea6fc7", frienduserid = "58a53508-3ed7-4d17-8155-0e1eff36eed9"}}%
function paraworld.friends.remove_Test(input)
	local msg = {
		sessionkey = input.sessionkey,
		frienduserid = input.frienduserid or "9b31f7fe-c9e7-4483-9611-6eb25220edac"
	};
	paraworld.friends.remove(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end


-- passed 2008.12.6 
-- %TESTCASE{"paraworld.friends.Add_Rest", func = "paraworld.friends.Add_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", frienduserid = "1a2e3f76-7087-46f7-b563-980bf394facd", relationType = "0", format = "1"}}%
function paraworld.friends.Add_Rest(input)
	local url = "http://api.test.pala5.cn/Friends/Add.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end


-- passed 2008.12.6 
-- %TESTCASE{"paraworld.friends.Get_Rest", func = "paraworld.friends.Get_Rest", input={uid = "e03b3286-2e42-49d6-8a74-736223bfedca", pageindex = "0", onlyonline = "0", order = "1", isinverse = "0", format = "1"}}%
function paraworld.friends.Get_Rest(input)
	local url = "http://api.test.pala5.cn/Friends/Get.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end


-- passed 2008.12.6 
-- %TESTCASE{"paraworld.friends.Remove_Rest", func = "paraworld.friends.Remove_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", frienduserid = "5C33B959-0F68-41B6-B8DB-7BFD039F6BD7", format = "1"}}%
function paraworld.friends.Remove_Rest(input)
	local url = "http://api.test.pala5.cn/Friends/Remove.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end