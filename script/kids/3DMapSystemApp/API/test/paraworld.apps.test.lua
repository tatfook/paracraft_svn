--[[
Title: a central place per application for selling and buying tradable items. 
Author(s): LiXizhi,CYF
Date: 2008/1/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.apps.test.lua");
paraworld.apps.TestAddApp()
paraworld.apps.TestGetDirByID()
paraworld.apps.TestGetDir()
paraworld.apps.TestGetDir_WrongAppID()
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

function paraworld.apps.Test()
end


-- passed: test passed by CYF on 2008.1.23. Test wrong appid
function paraworld.apps.TestGetDir_WrongAppID()
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
			operation = "get",
			sessionkey = sessionkey,
			--userid = userid,
			appid = "Wrong ID"
		};
		paraworld.apps.GetDirectory(msg, "test", function(msg) 
			log("app OK\n")
			log(commonlib.serialize(msg))
		end)
	end)
end


-- passed: 获取某个应用程序（格式正确的appid）
function paraworld.apps.TestGetDirByID()
	local msg = {
		operation = "login",
		username = "LiXizhi",
		Password = "anything"
	};
	paraworld.auth.AuthUser(msg, "test", function(msg)
		log(commonlib.serialize(msg));
		local sessionkey = msg.sessionkey;
		local userid = msg.userid;
		
		local msg = {
			operation = "get",
			sessionkey = sessionkey,
			appid = "3A62BCAC-FDCD-4B8D-B2B3-42372D4F073D"
		};
		paraworld.apps.GetDirectory(msg, "test", function(msg)
			log(commonlib.serialize(msg));
		end);
	end);
end


-- passed: 获取所有已经开发完成的应用程序
function paraworld.apps.TestGetDir()
	local msg = {
		operation = "login",
		username = "LiXizhi",
		Password = "anything"
	}
	paraworld.auth.AuthUser(msg, "test", function(msg)
		log(commonlib.serialize(msg));
		local sessionkey = msg.sessionkey;
		local userid = msg.userid;
		
		local msg = {
			operation = "get",
			sessionkey = sessionkey,
		};
		paraworld.apps.GetDirectory(msg, "test", function(msg)
			log(commonlib.serialize(msg));
		end);
	end)
end


-- passed: 用户新增一个应用程序，即申请一个appid
function paraworld.apps.TestAddApp()
	local msg = {
		operation = "add",
		appkey = "TestApp333",
		sessionkey = "f48c3a0c-8dd1-492d-a24d-eac57aea6fc7",
		nplappname = "LiXizhiApp333",
		userid = "6ea1ce24-bdf7-4893-a053-eb5fd2a74281",
		downloadurl = "URL",
		size = 100
	};
	paraworld.apps.GetDirectory(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end);
end

--[[
paraworld.CreateRPCWrapper("paraworld.apps.GetUserApp", "http://apps.paraengine.com/GetUserApp.asmx");

paraworld.CreateRPCWrapper("paraworld.apps.AddApp", "http://apps.paraengine.com/AddApp.asmx");
paraworld.CreateRPCWrapper("paraworld.apps.RemoveApp", "http://apps.paraengine.com/RemoveApp.asmx");
paraworld.CreateRPCWrapper("paraworld.apps.UpdateApp", "http://apps.paraengine.com/UpdateApp.asmx");
paraworld.CreateRPCWrapper("paraworld.apps.GetDirectory", "http://apps.paraengine.com/GetDirectory.asmx");

]]