--[[
Title: Test profile manager
Author(s): LiXizhi
Date: 2008/3/26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/test/test_ProfileManager.lua");
-------------------------------------------------------
]]
if not test then test = {} end

-- %TESTCASE{"ProfileManager.DownloadFullProfile", func = "test.test_DownloadFullProfile", input ={uid = ""}}%
function test.test_DownloadFullProfile(input)
	input = input or {};
	if(input.uid== "") then
		input.uid = Map3DSystem.User.userid;
	end
	
	Map3DSystem.App.profiles.ProfileManager.DownloadFullProfile(input.uid, function (uid)
		local profile = Map3DSystem.App.profiles.ProfileManager.GetProfile(uid);
		commonlib.log(profile);
	end)
end

-- %TESTCASE{"ProfileManager.GetMCML", func = "test.test_GetMCML", input = {uid = "", appkey="profiles_GUID"}}%
function test.test_GetMCML(input)
	input = input or {};
	if(input.uid== "") then
		input.uid = Map3DSystem.User.userid;
	end
	
	Map3DSystem.App.profiles.ProfileManager.GetMCML(input.uid, input.appkey, function (uid, appkey)
		local profile = Map3DSystem.App.profiles.ProfileManager.CreateGetProfile(uid);
		commonlib.log(profile:GetMCML(appkey));
	end)
end

-- %TESTCASE{"ProfileManager.SetMCML", func = "test.test_SetMCML", input = {uid = "", appkey="profiles_GUID", profile="Any string"}}%
function test.test_SetMCML(input)
	input = input or {};
	if(input.uid== "") then
		input.uid = Map3DSystem.User.userid;
	end
	
	if(input.profile == "")then 
		input.profile = nil; -- this will delete it. 
	end
	
	Map3DSystem.App.profiles.ProfileManager.SetMCML(input.uid, input.appkey, input.profile, function(uid, appkey, bSucceed)
		log("test result is "..tostring(bSucceed).."\n");
	end)
end