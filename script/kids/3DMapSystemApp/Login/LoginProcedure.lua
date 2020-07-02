--[[
Title: The login and registration procedure. 
Author(s): LiXizhi
Date: 2008/3/18
Desc: The (Login|Registration)->Download user profile->Require application registration status->Show uncompleted registration steps->CallbackFunc(Show profile)
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Login/LoginProcedure.lua");
Map3DSystem.App.Login.Proc_Authentication(values);
-------------------------------------------------------
]]
local L = CommonCtrl.Locale("ParaWorld");


Map3DSystem.App.Login.LoginCallBack = nil;
Map3DSystem.App.Login.bSkipAppRegistration = nil;

-- Authenticate user and proceed to Proc_DownloadProfile(). it will assume the normal login procedures. It starts with authentification and ends with callback function or user profile page. 
-- @param values: a table containing authentification info {username, password, domain}. username, password should be validated locally before passing them here. 
-- @param funcCallBack: this is a callback function to be invoked when login complete. If nil, it will display the profile page for the user. 
-- @param bSkipAppRegistration: whether to skip uncompleted application registration. 
function Map3DSystem.App.Login.Proc_Authentication(values, funcCallBack, bSkipAppRegistration)
	paraworld.ChangeDomain({domain=values.domain});
	local msg = {
		username = values.username,
		password = values.password,
	}
	paraworld.auth.AuthUser(msg, "login", function (msg)
		if(msg==nil) then
			paraworld.ShowMessage(L"连接的主机没有反应,连接尝试失败");
		
		elseif(msg.issuccess) then	
			Map3DSystem.User.Name = values.username;
			Map3DSystem.User.Password = values.password;
			Map3DSystem.User.ChatDomain = values.domain;
			
			paraworld.ShowMessage(L"登陆成功, 正在同步用户信息, 请稍候...");
			if(not Map3DSystem.App.Login.app:ReadConfig("Registered", false)) then
				Map3DSystem.App.Login.app:WriteConfig("Registered", true);
			end
			if(values.rememberpassword) then
				Map3DSystem.User.SaveCredential(Map3DSystem.User.Name, Map3DSystem.User.Password);
			end
			Map3DSystem.App.Login.app:WriteConfig("rememberpassword", values.rememberpassword);
			
			-- login to JGSL chat 
			NPL.load("(gl)script/kids/3DMapSystemUI/Chat/Main.lua");
			Map3DSystem.App.Chat.OneTimeInit();
			
			-- download full profile and may optionally invoke app registration pages.
			Map3DSystem.App.Login.LoginCallBack = funcCallBack;
			Map3DSystem.App.Login.bSkipAppRegistration = bSkipAppRegistration;
			Map3DSystem.App.Login.Proc_DownloadProfile(Map3DSystem.User.sessionkey, Map3DSystem.User.userid)
		else
			if(msg.errorcode==412) then
				paraworld.ShowMessage(string.format("%s\n\n%s", tostring(msg.info), L"是否希望重新发送确认信到你注册时提供的邮箱?"), function()
					paraworld.auth.SendConfirmEmail({username = values.username, password = values.password,}, "Login", function(msg)
						if(msg ~= nil) then
							if(msg.issuccess) then
								paraworld.ShowMessage(L"发送成功, 请查看你的邮箱");
							else
								-- 497：数据不存在或已被删除 414：账号已是激活状态不必再次激活 
								if(msg.errorcode==497) then
									paraworld.ShowMessage(L"数据不存在或已被删除");
								elseif(msg.errorcode==414) then
									paraworld.ShowMessage(L"账号已是激活状态不必再次激活");
								else
									paraworld.ShowMessage(L"未知服务器错误, 请稍候再试");
								end
							end	
						end
					end)
				end);
			else
				paraworld.ShowMessage(msg.info);
			end
		end
	end)
end

-- Download profile and proceed to Proc_AppReg()
function Map3DSystem.App.Login.Proc_DownloadProfile()
	-- TODO: Map3DSystem.App.profiles.ProfileManager.DownloadMCML(Map3DSystem.User.userid)
	-- TODO: after downloading, call Map3DSystem.App.Login.Proc_AppReg()
	Map3DSystem.App.profiles.ProfileManager.DownloadFullProfile(nil, function (uid, appkey, bSucceed)
		if(bSucceed) then
			log("full user profile is downloaded for current user\n")
			-- after downloading current user profile, call application login procedure
			Map3DSystem.App.Login.Proc_AppReg();
		else
			paraworld.ShowMessage(L"无法从服务器获取用户信息, 可能服务器正忙, 请稍候再试.");	
		end
	end)
end

-- Require application registration status->Show uncompleted registration steps
-- In order for an application to have a registration page with this login application. The app must install and implement a command as below:
-- The command name must be "Registration.AppName", such as "Registration.ProfileApp"
-- The command must recognize input {operation="query|show", callbackFunc = nil, browsername, parent}
--  if operation is "query", the command must immediately return a registration status table, containing about the registration complete progress. see below
--    status = {
--      RequiredComplete=true, -- whether required fields have been completed
--      CompleteProgress=0.2, -- the overall completeness in percentage. 
-- }
--  if operation is "show", msg.callbackFunc should be called when the returned. msg.browsername and msg.parent maybe used to display the registration page. 
--   If none of them are present, an application display its own windows at the center of the screen. 
function Map3DSystem.App.Login.Proc_AppReg()
	if(Map3DSystem.App.Login.bSkipAppRegistration) then	
		return Map3DSystem.App.Login.Proc_Complete();
	end
	
	-- we will check for these applications in order. 
	local RequiredApps = {
		{name="CCS", title=L"选择形象", status},
		{name="profiles", title=L"身份信息", status},
		{name="Map", title=L"申请土地", status}
	};
	local required_count = 0;
	--
	-- pass one: get all application registration status. 
	--
	local index, appReg;
	for index, appReg in ipairs(RequiredApps) do
		local msg = Map3DSystem.App.Commands.Call("Registration."..appReg.name, {operation="query"});
		if(msg) then
			appReg.status = msg.response;
			if(appReg.status and not appReg.status.RequiredComplete) then
				required_count = required_count + 1;
			end	
		end
	end
	
	-- close popup and front page browser. 
	paraworld.ShowMessage(nil);
	local ctl = CommonCtrl.GetControl(Map3DSystem.App.Login.browsername);
	if(ctl)then
		ctl:Goto(nil);
	end
	
	--
	-- pass two: show registration page for those whose status.RequiredComplete is false. 
	--
	if(required_count>0) then
		--
		-- we display a summary of registration progress to allow user to skip or fill?
		-- 
		NPL.load("(gl)script/kids/3DMapSystemApp/Login/AppRegPage.lua");
		Map3DSystem.App.Login.AppRegPage.RequiredApps = RequiredApps;
		Map3DSystem.App.Login.AppRegPage.OnFinishedFunc = Map3DSystem.App.Login.Proc_Complete;
		local width, height = 640, 512
		local _parent = Map3DSystem.App.Login.AppRegPage:Create("LoginApp.AppRegPage", nil, "_ct", -width/2, -height/2+15, width, height);
		if(_parent) then
			_parent:SetTopLevel(true);
		end
	else
		Map3DSystem.App.Login.Proc_Complete();	
	end	
end

-- login procedure completed. 
function Map3DSystem.App.Login.Proc_Complete()
	if(type(Map3DSystem.App.Login.LoginCallBack) =="function") then
		-- call the user call back
		Map3DSystem.App.Login.LoginCallBack();
	end
end

---------------------------
-- helper function
---------------------------

