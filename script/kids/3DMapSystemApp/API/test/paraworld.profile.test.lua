--[[
Title: get profile of a given user; set profile of a given user for a given application
Author(s): LiXizhi,CYF
Date: 2008/1/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.profile.test.lua");
paraworld.profile.SetMCML_Test()
paraworld.profile.GetMCML_Test()
paraworld.profile.Test()

-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

function paraworld.profile.Test()
end
--[[
paraworld.CreateRPCWrapper("paraworld.profile.SetMCML", "http://profile.paraengine.com/SetMCML.asmx");
paraworld.CreateRPCWrapper("paraworld.profile.GetMCML", "http://profile.paraengine.com/GetMCML.asmx");
]]



--passed: 设置、修改某个用户的MCML
-- %TESTCASE{"profile.SetMCML", func = "paraworld.profile.SetMCML_Test", input ={appkey = "BCS_GUID", sessionkey = "", profile = [[<pe:app app_key="GUID_CCS"><pe:avatar AssetFile="character/.../BBB.x"></pe:avatar></pe:app>]]}}%
function paraworld.profile.SetMCML_Test(input)
	input = input or {};
	if(input.sessionkey == "") then
		input.sessionkey =nil;
	end
	local msg = {
		appkey = input.appkey or "BCS_GUID",
		sessionkey = Map3DSystem.User.sessionkey or input.sessionkey,
		profile = input.profile or [[<pe:app app_key="GUID_CCS"><pe:avatar AssetFile="character/.../BBB.x"></pe:avatar></pe:app>]],
	};
	paraworld.profile.SetMCML(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end


--passed: 获取某个用户的MCML
-- %TESTCASE{"profile.GetMCML", func = "paraworld.profile.GetMCML_Test", input ={appkey = "", uid = "4bc27a7d-f8b5-4124-9f1a-07cae50ef3d3"}}%
function paraworld.profile.GetMCML_Test(input)
	input = input or {};
	if(input.uid== "") then
		input.uid = Map3DSystem.User.userid;
	end
	local msg = {
		appkey = input.appkey or "BCS_GUID",
		uid = input.uid or ""
	};
	paraworld.profile.GetMCML(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end




-- passed 2008.12.8 
-- %TESTCASE{"paraworld.profile.GetMCML_Rest", func = "paraworld.profile.GetMCML_Rest", input={appkey = "ActionFeed_GUID", uid = "e03b3286-2e42-49d6-8a74-736223bfedca", format = "1"}}%
function paraworld.profile.GetMCML_Rest(input)
	local url = "http://api.test.pala5.cn/Profile/GetMCML.ashx";
	
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
-- %TESTCASE{"paraworld.profile.SetMCML_Rest", func = "paraworld.profile.SetMCML_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", appkey = "ActionFeed_GUID", profile = "", format = "1"}}%
function paraworld.profile.SetMCML_Rest(input)
	local url = "http://api.test.pala5.cn/Profile/SetMCML.ashx";
	
	log("post "..url.."\n")
	local c = cURL.easy_init()
	
	c:setopt_url(url)
	c:post(input)
	c:perform({writefunction = function(str) 
			log("-->:"..str.."\r\n")
		 end})
		 
	log("\r\nDone!\r\n")
end