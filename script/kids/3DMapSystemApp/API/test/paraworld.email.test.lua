--[[
Title: game email
Author(s): LiXizhi
Date: 2008/1/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.email.test.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

-- test passed 2009.1.20
-- %TESTCASE{"paraworld.email.test_Send", func = "paraworld.email.test_Send", input={to="", title="test email", attachment="", content="hello, paraengine!"}}%
function paraworld.email.test_Send(input)
	if(input.to == "") then
		input.to = Map3DSystem.User.userid;
	end
	paraworld.email.send(input, "test", function (msg)
		log(commonlib.serialize(msg))
	end)
end

-- test passed 2009.1.20
-- %TESTCASE{"paraworld.email.test_Check", func = "paraworld.email.test_Check", input={pageindex=0,pagesize=10}}%
function paraworld.email.test_Check(input)
	paraworld.email.check(input, "test", function (msg)
		log(commonlib.serialize(msg))
	end)
end

-- test passed 2009.1.21
-- %TESTCASE{"paraworld.email.test_Get", func = "paraworld.email.test_Get", input={emailID=14}}%
function paraworld.email.test_Get(input)
	paraworld.email.get(input, "test", function (msg)
		log(commonlib.serialize(msg))
	end)
end

-- test passed 2009.1.21
-- %TESTCASE{"paraworld.email.test_Remove", func = "paraworld.email.test_Remove", input={emailID=14}}%
function paraworld.email.test_Remove(input)
	paraworld.email.remove(input, "test", function (msg)
		log(commonlib.serialize(msg))
	end)
end

