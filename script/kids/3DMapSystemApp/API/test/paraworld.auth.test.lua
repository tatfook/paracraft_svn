--[[
Title: It is for client and application to authenticate a user and return or verify a session key. 
Author(s): LiXizhi,CYF
Date: 2008/1/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.auth.test.lua");
paraworld.auth.Test_CheckVersion();
paraworld.auth.Logout_FormatError()
paraworld.auth.Logout_FormatRight()
paraworld.auth.Logout_Logout()
paraworld.auth.TestAuthUser_prep()
paraworld.auth.TestVerfiyUser()
paraworld.auth.TestVerfiyUserCorrect()


%T-ESTCASE{"paraworld.auth.VerifyUser", func="paraworld.auth.TestVerifyUser_Right", input={
		appkey = "fae5feb1-9d4f-4a78-843a-1710992d4e00",
		sessionkey = "a4309e31-b911-407c-8acb-107d071f9b1c"
}}%

-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

-- test passed 2008.12.15
-- %TESTCASE{"paraworld.auth.TestAuthUser_prep", func = "paraworld.auth.TestAuthUser_prep", input={username = "LiXizhi2", password = "1234567",}, output="temp/paraworld.auth.AuthUser.test"}%
function paraworld.auth.TestAuthUser_prep(input)
	paraworld.auth.AuthUser(input, "test", function (msg)
		log(commonlib.serialize(msg))
	end)
end


-- {type=0}
--	==> {issuccess=false,errorcode=431,}
-- {type=1}
--  ==> {sign=true,logintimes=1,list={{day=1,items={{cnt=5,gsid=17213,},},},{day=2,items={{cnt=10,gsid=17213,},},},{day=3,items={{cnt=15,gsid=17213,},},},{day=4,items={{cnt=20,gsid=17213,},},},{day=5,items={{cnt=30,gsid=17213,},},},},}
function paraworld.auth.SignIn_test(input)
	log('aaaaaaaaaaaaa');
	paraworld.Users.SignIn(input, "test", function (msg)
		log(commonlib.serialize(msg));
	end);
end


function paraworld.auth.Lottery_test(input)
	log('bbbbbbbbbbb');
	paraworld.Users.Lottery(input, "test", function (msg)
		log(commonlib.serialize(msg));
	end);
end



-- test passed 2008.1.23
function paraworld.auth.TestVerfiyUser()
	log(tostring(paraworld.auth.VerifyUser).." called \n")
	paraworld.auth.VerifyUser({appkey = "wrong APP key",}, "test1", function(msg) 
		log(commonlib.serialize(msg))
	end)
end

-- test passed 2008.1.23
function paraworld.auth.TestVerfiyUserCorrect()
	
	-- test correct verify
	local msg = {
		operation = "login",
		username = "LiXizhi",
		Password = "anything",
	}
	paraworld.auth.AuthUser(msg, "test", function (msg) 
		log("login OK\n")
		log(commonlib.serialize(msg))
		local sessionkey = msg.sessionkey;
		local userid = msg.userid;
		
		local msg = {
			sessionkey = sessionkey,
			appkey = "wrong APP key",
		};
		paraworld.auth.VerifyUser(msg, "test", function(msg) 
			log("verify OK\n")
			log(commonlib.serialize(msg))
		end)
	end)
end

function paraworld.auth.TestVerifyUser_Right()
	local msg = {
		appkey = "fae5feb1-9d4f-4a78-843a-1710992d4e00",
		sessionkey = "c5e7f955-bc52-4bd6-b109-60aa1b9a45a1"
	};
	paraworld.auth.VerifyUser(msg, "test", function(msg)
		log(commonlib.serialize(msg))
	end);
end


--passed  用户登出，测试格式不正确的sessionkey
function paraworld.auth.Logout_FormatError()
	local msg = {
		operation = "logout",
		sessionkey = "abcdefg",
	}
	paraworld.auth.Logout(msg, "test", function(msg)
		log(commonlib.serialize(msg))
	end)
end


--passed  用户登出，测试格式正确、但数据库中不存在的sessionkey
function paraworld.auth.Logout_FormatRight()
	local msg = {
		operation = "logout",
		sessionkey = "fae5feb1-9d4f-4a78-843a-1710992d4e71",
	}
	paraworld.auth.Logout(msg, "test", function(msg)
		log(commonlib.serialize(msg))
	end)
end


--passed  用户登出，测试格式正确、并且在数据库中存在的sessionkey
function paraworld.auth.Logout_Logout()
	local msg = {
		operation = "logout",
		sessionkey = "A1862D13-A844-4801-B28D-EC9C4C657E8c",
	}
	paraworld.auth.Logout(msg, "test", function(msg)
		log(commonlib.serialize(msg))
	end)
end

-- test check version. 
function paraworld.auth.Test_CheckVersion(input)
	msg = {};
	if(input~=nil and input~="") then
		msg.cache_policy = System.localserver.CachePolicy:new(input)
	end
	paraworld.auth.CheckVersion(msg, "test", function (msg)
		log(commonlib.serialize(msg))
	end);
end



--passed: 发送激活账号的Email
-- %TESTCASE{"auth.SendConfirmEmail", func = "paraworld.auth.SendConfirmEmail_Test", input ={username = "aiaiai", language = 1, password = 'mdmdmd'}}%
function paraworld.auth.SendConfirmEmail_Test(input)
	local msg = {
		username = input.username,
		language = input.language,
		password = input.password,
	};
	paraworld.auth.SendConfirmEmail(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end



-- passed 2008.12.6 
-- %TESTCASE{"paraworld.auth.AuthUser_Rest", func = "paraworld.auth.AuthUser_Rest", input={username = "LiXizhi2", password = "1234567", newSession="true", format = "1"}}%
function paraworld.auth.AuthUser_Rest(input)
	local url = "http://api.test.pala5.cn/Auth/AuthUser.ashx";
	
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
-- %TESTCASE{"paraworld.auth.Logout_Rest", func = "paraworld.auth.Logout_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", format = "1"}}%
function paraworld.auth.Logout_Rest(input)
	local url = "http://api.test.pala5.cn/Auth/Logout.ashx";
	
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
-- %TESTCASE{"paraworld.auth.VerifySession_Rest", func = "paraworld.auth.VerifySession_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", format = "1"}}%
function paraworld.auth.VerifySession_Rest(input)
	local url = "http://api.test.pala5.cn/Auth/VerifySession.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end