--[[
Title: a central place per application for selling and buying tradable items. 
Author(s): LiXizhi
Date: 2008/1/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.users.test.lua");
paraworld.users.Find_Test(input)
paraworld.users.Registration_Test()
paraworld.users.setInfo_Test()
paraworld.users.getInfo_Test()
paraworld.users.Test()
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

function paraworld.users.Test()
end
--[[
paraworld.CreateRPCWrapper("paraworld.users.getInfo", "http://users.paraengine.com/getInfo.asmx");
paraworld.CreateRPCWrapper("paraworld.users.setInfo", "http://users.paraengine.com/setInfo.asmx");
paraworld.CreateRPCWrapper("paraworld.users.isAppAdded", "http://users.paraengine.com/isAppAdded.asmx");
]]


function paraworld.users.CheckCDKey_Test(input)
	input = input or {keycode="1234567"}
	paraworld.users.CheckCDKey(input, "test", function(msg)
		commonlib.echo(msg)
		if(msg.result == 1) then
			commonlib.echo("key is NOT used")
		elseif(msg.result == 0) then
			commonlib.echo("key is used")
		end
	end);
end	


function paraworld.users.UseCDKey_Test(input)
	input = input or {keycode="1234567"}
	paraworld.users.UseCDKey(input, "test", function(msg)
		commonlib.echo(msg)
		-- result 0:成功 1:CDKEY不存在 2:CDKEY已被使用
		if(msg.result == 0) then
			commonlib.echo("key Succeed")
		elseif(msg.result == 1) then
			commonlib.echo("key does not exist")
		elseif(msg.result == 2) then			
			commonlib.echo("key is already in use")
		end
	end);
end	


--passed: 获取一组指定用户的指定信息
-- %TESTCASE{"user.getInfo", func = "paraworld.users.getInfo_Test", input ={nids="001,002,003"}, output="temp/paraworld.users.GetInfo.test"}%
function paraworld.users.getInfo_Test(input,output)
	if(input.nids and input.nids~="") then
		msg.nids = input.nids;
	end
	paraworld.users.getInfo(msg, "test", function(msg)
		log(commonlib.serialize(msg));
		if (output) then
			local file = ParaIO.open(output, "a");
			if(file:IsValid()) then
				file:WriteString("==Test Result ===\n");
				file:WriteString(commonlib.serialize(msg));
				file:close();
			end
		end		
	end);
end



--passed: 登录用户更改自己的个人信息
-- %TESTCASE{"user.SetInfo", func = "paraworld.users.setInfo_Test", input ={nickName="testAAA"},output="temp/paraworld.users.SetInfo.test"}%
function paraworld.users.setInfo_Test(input,output)
	paraworld.users.setInfo(msg, "test", function(msg)
		log(commonlib.serialize(msg));
		if (output) then
			local file = ParaIO.open(output, "a");
			if(file:IsValid()) then
				file:WriteString("==Test Result ===\n");
				file:WriteString(commonlib.serialize(msg));
				file:close();
			end
		end		
	end);
end


--passed: 
-- %TESTCASE{"user.AddMoney", func = "paraworld.users.AddMoney_Test", input ={nid="",emoney="100"},output="temp/paraworld.users.AddMoney.test"}%
function paraworld.users.AddMoney_Test(input,output)
	local msg = {
		emoney = input.emoney,
	};
	paraworld.users.AddMoney(msg, "test", function(msg)
		log("======== paraworld.users.AddMoney returns: ========\n")
		commonlib.echo(msg);
		if (output) then
			local file = ParaIO.open(output, "a");
			if(file:IsValid()) then
				file:WriteString("==Test Result ===\n");
				file:WriteString(commonlib.serialize(msg));
				file:close();
			end
		end	
	end);
end


--passed: 注册一个新用户
-- %TESTCASE{"user registration", func = "paraworld.users.Registration_Test", input ={username="LiXizhi", password="abcdefg", email="nobody@yeah.net"}}%
function paraworld.users.Registration_Test(input)
	input = input or {};
	local msg = {
		appkey = "fae5feb1-9d4f-4a78-843a-1710992d4e00",
		username = input.username or "NPLTestName",
		password = input.password or "1234567",
		email = input.email or "NPLTestName@163.com",
		passquestion = "00000",
		passanswer = "00000"
	};
	paraworld.users.Registration(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end


--passed: 依据输入的Email查找已在PE注册的用户，并将注册用户的ID返回
-- %TESTCASE{"user Find", func = "paraworld.users.Find_Test", input ={email = "zzzzz@163.com";}}%
function paraworld.users.Find_Test(input)
	input = input or {};
	local msg = {
		email = input.email,
	};
	paraworld.users.Find(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end



--passed: 依据传入的MCQL语句查找用户
-- %TESTCASE{"user Search", func = "paraworld.users.Search_Test", input ={mql=""}}%
function paraworld.users.Search_Test(input)
	input = input or {};
	local msg = {
		mql = input.mql,
	};
	paraworld.users.Search(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end



--passed: 执行传入的MQL语句，并将结果返回
-- %TESTCASE{"MQL Query", func = "paraworld.MQL.Query_Test", input ={query = "", appkey = "", sessionkey = ""}}%
function paraworld.MQL.Query_Test(input)
	input = input or {};
	local msg = {
		query = input.query,
	};
	paraworld.MQL.query(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end


--passed: 执行传入的MQL语句，并将结果返回
-- %TESTCASE{"users.Invite", func = "paraworld.users.Invite_Test", input ={sessionkey = "", from = "", to = "", message = "", language = 1}}%
function paraworld.users.Invite_Test(input)
	input = input or {};
	local msg = {
		from = input.from,
		to = input.to,
		message = input.message,
		language = input.language,
	};
	if(input.sessionkey==nil or input.sessionkey=="") then
		msg.sessionkey = Map3DSystem.User.sessionkey;
	else
		msg.sessionkey = input.sessionkey;
	end

	commonlib.echo(msg)
	paraworld.users.Invite(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end




-- passed 2008.12.8 
-- %TESTCASE{"paraworld.users.Find_Rest", func = "paraworld.users.Find_Rest", input={email = "caoyongfeng0214@gmail.com", format = "1"}}%
function paraworld.users.Find_Rest(input)
	local url = "http://api.test.pala5.cn/Users/Find.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end


-- passed 2008.12.8 
-- %TESTCASE{"paraworld.users.GetInfo_Rest", func = "paraworld.users.GetInfo_Rest", input={uids = "e03b3286-2e42-49d6-8a74-736223bfedca", fields = "username,nickname,Gender", format = "1"}}%
function paraworld.users.GetInfo_Rest(input)
	local url = "http://api.test.pala5.cn/Users/GetInfo.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end



-- passed 2008.12.8 
-- %TESTCASE{"paraworld.users.SetInfo_Rest", func = "paraworld.users.SetInfo_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", nickname = "HelloKitty", Gender = "女", format = "1"}}%
function paraworld.users.SetInfo_Rest(input)
	local url = "http://api.test.pala5.cn/Users/SetInfo.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end


-- passed 2008.12.8 
-- %TESTCASE{"paraworld.users.Invite_Rest", func = "paraworld.users.Invite_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", from = "HelloKitty", to = "md-111111@163.com", message = "hello world", language = "1", format = "1"}}%
function paraworld.users.Invite_Rest(input)
	local url = "http://api.test.pala5.cn/Users/Invite.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end