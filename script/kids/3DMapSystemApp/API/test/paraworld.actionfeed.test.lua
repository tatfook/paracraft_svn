--[[
Title: a central place per application for selling and buying tradable items. 
Author(s): LiXizhi
Date: 2008/1/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.actionfeed.test.lua");
paraworld.actionfeed.Test()
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

function paraworld.actionfeed.Test()
end

--[[
paraworld.CreateRPCWrapper("paraworld.actionfeed.get", "http://actionfeed.paraengine.com/get.asmx");
paraworld.CreateRPCWrapper("paraworld.actionfeed.PublishStoryToUser", "http://actionfeed.paraengine.com/PublishStoryToUser.asmx");
paraworld.CreateRPCWrapper("paraworld.actionfeed.PublishActionToUser", "http://actionfeed.paraengine.com/PublishActionToUser.asmx");
paraworld.CreateRPCWrapper("paraworld.actionfeed.PublishRequestToUser", "http://actionfeed.paraengine.com/PublishRequestToUser.asmx");
paraworld.CreateRPCWrapper("paraworld.actionfeed.PublishMessageToUser", "http://actionfeed.paraengine.com/PublishMessageToUser.asmx");
paraworld.CreateRPCWrapper("paraworld.actionfeed.PublishItemToUser", "http://actionfeed.paraengine.com/PublishItemToUser.asmx");
paraworld.CreateRPCWrapper("paraworld.actionfeed.sendEmail", "http://actionfeed.paraengine.com/sendEmail.asmx");
]] 




--passed: 使用系统服务邮箱发送电子邮件
-- %TESTCASE{"actionfeed.sendEmail", func = "paraworld.actionfeed.sendEmail_Test", input ={sessionkey = "f770dcfe-cd18-4e05-9d2f-6eb1f1859864", to = "0a3b1121-b72f-4100-9943-bf0bacf7d045,a354ea8f-6ef6-4db7-ba6a-c6df2d47abb8",title = "Hello World", body = "this is a test email", isbodyhtml = "true"}}%
function paraworld.actionfeed.sendEmail_Test(input)
	local msg = {
		sessionkey = input.sessionkey,
		to = input.to,
		title = input.title,	
		body = input.body,
		isbodyhtml = input.isbodyhtml,
	};
	paraworld.actionfeed.sendEmail(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end


--passed: PublishStoryToUser
-- %TESTCASE{"actionfeed.PublishStoryToUser", func = "paraworld.actionfeed.PublishStoryToUser_Test", input ={sessionkey = "fec67110-f54b-4b63-b90d-1a4a52c82387", to_uids = "8ec11316-bc2e-491d-8f18-667501687e69,f5f3de7a-05b2-42a0-bd78-415a939020c2,e0dba2eb-8495-4b7d-8c3c-cf76d7cc85df",story = "Hello World 111111",}}%
function paraworld.actionfeed.PublishStoryToUser_Test(input)
	local msg = {
		sessionkey = input.sessionkey,
		to_uids = input.to_uids,
		story = input.story,	
	};
	paraworld.actionfeed.PublishStoryToUser(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end



--passed: PublishActionToUser
-- %TESTCASE{"actionfeed.PublishActionToUser", func = "paraworld.actionfeed.PublishActionToUser_Test", input ={sessionkey = "fec67110-f54b-4b63-b90d-1a4a52c82387", to_uids = "8ec11316-bc2e-491d-8f18-667501687e69,f5f3de7a-05b2-42a0-bd78-415a939020c2,e0dba2eb-8495-4b7d-8c3c-cf76d7cc85df",action = "Hello World",}}%
function paraworld.actionfeed.PublishActionToUser_Test(input)
	local msg = {
		sessionkey = input.sessionkey,
		to_uids = input.to_uids,
		action = input.action,	
	};
	paraworld.actionfeed.PublishActionToUser(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end



--passed: PublishRequestToUser
-- %TESTCASE{"actionfeed.PublishRequestToUser", func = "paraworld.actionfeed.PublishRequestToUser_Test", input ={sessionkey = "fec67110-f54b-4b63-b90d-1a4a52c82387", to_uids = "8ec11316-bc2e-491d-8f18-667501687e69,f5f3de7a-05b2-42a0-bd78-415a939020c2,e0dba2eb-8495-4b7d-8c3c-cf76d7cc85df",request = "Hello World",}}%
function paraworld.actionfeed.PublishRequestToUser_Test(input)
	local msg = {
		sessionkey = input.sessionkey,
		to_uids = input.to_uids,
		request = input.request,	
	};
	paraworld.actionfeed.PublishRequestToUser(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end


--passed: PublishMessageToUser
-- %TESTCASE{"actionfeed.PublishMessageToUser", func = "paraworld.actionfeed.PublishMessageToUser_Test", input ={sessionkey = "fec67110-f54b-4b63-b90d-1a4a52c82387", to_uids = "8ec11316-bc2e-491d-8f18-667501687e69,f5f3de7a-05b2-42a0-bd78-415a939020c2,e0dba2eb-8495-4b7d-8c3c-cf76d7cc85df",message = "Hello World",}}%
function paraworld.actionfeed.PublishMessageToUser_Test(input)
	local msg = {
		sessionkey = input.sessionkey,
		to_uids = input.to_uids,
		message = input.message,	
	};
	paraworld.actionfeed.PublishMessageToUser(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end




--passed: PublishItemToUser
-- %TESTCASE{"actionfeed.PublishItemToUser", func = "paraworld.actionfeed.PublishItemToUser_Test", input ={sessionkey = "fec67110-f54b-4b63-b90d-1a4a52c82387", to_uids = "8ec11316-bc2e-491d-8f18-667501687e69,f5f3de7a-05b2-42a0-bd78-415a939020c2,e0dba2eb-8495-4b7d-8c3c-cf76d7cc85df",item = "Hello World",}}%
function paraworld.actionfeed.PublishItemToUser_Test(input)
	local msg = {
		sessionkey = input.sessionkey,
		to_uids = input.to_uids,
		item = input.item,	
	};
	paraworld.actionfeed.PublishItemToUser(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end







-- passed: PublishActionToUser_Rest
-- %TESTCASE{"paraworld.actionfeed.PublishActionToUser_Rest", func = "paraworld.actionfeed.PublishActionToUser_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", to_uids = "368a459d-0c86-4ae0-9319-22b484e615f3,4f4d7018-67f2-479c-b7e5-655cf3065c7a", action = "Hello World", format = "1"}}%
function paraworld.actionfeed.PublishActionToUser_Rest(input)
	local url = "http://api.test.pala5.cn/ActionFeed/PublishActionToUser.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end


-- passed: PublishItemToUser_Rest
-- %TESTCASE{"paraworld.actionfeed.PublishItemToUser_Rest", func = "paraworld.actionfeed.PublishItemToUser_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", to_uids = "368a459d-0c86-4ae0-9319-22b484e615f3,4f4d7018-67f2-479c-b7e5-655cf3065c7a", item = "Hello World", format = "1"}}%
function paraworld.actionfeed.PublishItemToUser_Rest(input)
	local url = "http://api.test.pala5.cn/ActionFeed/PublishItemToUser.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end


-- passed: PublishMessageToUser_Rest
-- %TESTCASE{"paraworld.actionfeed.PublishMessageToUser_Rest", func = "paraworld.actionfeed.PublishMessageToUser_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", to_uids = "368a459d-0c86-4ae0-9319-22b484e615f3,4f4d7018-67f2-479c-b7e5-655cf3065c7a", message = "Hello World", format = "1"}}%
function paraworld.actionfeed.PublishMessageToUser_Rest(input)
	local url = "http://api.test.pala5.cn/ActionFeed/PublishMessageToUser.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end


-- passed: PublishRequestToUser_Rest
-- %TESTCASE{"paraworld.actionfeed.PublishRequestToUser_Rest", func = "paraworld.actionfeed.PublishRequestToUser_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", to_uids = "368a459d-0c86-4ae0-9319-22b484e615f3,4f4d7018-67f2-479c-b7e5-655cf3065c7a", request = "Hello World", format = "1"}}%
function paraworld.actionfeed.PublishRequestToUser_Rest(input)
	local url = "http://api.test.pala5.cn/ActionFeed/PublishRequestToUser.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end


-- passed: PublishStoryToUser_Rest
-- %TESTCASE{"paraworld.actionfeed.PublishStoryToUser_Rest", func = "paraworld.actionfeed.PublishStoryToUser_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", to_uids = "368a459d-0c86-4ae0-9319-22b484e615f3,4f4d7018-67f2-479c-b7e5-655cf3065c7a", story = "Hello World", format = "1"}}%
function paraworld.actionfeed.PublishStoryToUser_Rest(input)
	local url = "http://api.test.pala5.cn/ActionFeed/PublishStoryToUser.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end


-- passed: SendEmail_Rest
-- %TESTCASE{"paraworld.actionfeed.SendEmail_Rest", func = "paraworld.actionfeed.SendEmail_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", to = "6EA1CE24-BDF7-4893-A053-EB5FD2A74281,6EA770C6-92B2-4B2B-86DA-6F574641EC11", title = "This is a test EMail", body = "Hello,this is a test email.", isbodyhtml = "true", format = "1"}}%
function paraworld.actionfeed.SendEmail_Rest(input)
	local url = "http://api.test.pala5.cn/ActionFeed/SendEmail.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end