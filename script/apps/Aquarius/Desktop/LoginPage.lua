--[[
Title: code behind for page LoginPage.html
Author(s): LiXizhi
Date: 2008/10/27
Desc:  script/apps/Aquarius/Desktop/LoginPage.html?cmdredirect=Profile.HomePage
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Desktop/LoginPage.lua");
MyCompany.Aquarius.LoginPage.Proc_Authentication(values, funcCallBack, bSkipAppRegistration)
-------------------------------------------------------
]]


commonlib.echo("script/apps/Aquarius/Desktop/LoginPage.lua is depracated");

local L = CommonCtrl.Locale("ParaWorld");

local LoginPage = {};
commonlib.setfield("MyCompany.Aquarius.LoginPage", LoginPage)

---------------------------------
-- page event handlers
---------------------------------

-- init
function LoginPage.OnInit()
	--local self = document:GetPageCtrl();
	--local name = self:GetRequestParam("name")
	--self:SetNodeValue("fileName", name);
end

LoginPage.LoginCallBack = nil;
LoginPage.bSkipAppRegistration = nil;

-- Authenticate user and proceed to Proc_DownloadProfile(). it will assume the normal login procedures. It starts with authentification and ends with callback function or user profile page. 
-- @param values: a table containing authentification info {username, password, domain}. username, password should be validated locally before passing them here. 
-- @param funcCallBack: this is a callback function to be invoked when login complete. If nil, it will display the profile page for the user. 
-- @param bSkipAppRegistration: whether to skip uncompleted application registration. 
function LoginPage.Proc_Authentication(values, funcCallBack, bSkipAppRegistration)
	paraworld.ChangeDomain({domain=values.domain});
	local msg = {
		username = values.username,
		password = values.password,
	}
	paraworld.auth.AuthUser(msg, "login", function (msg)
		if(msg==nil) then
			paraworld.ShowMessage(L"连接的主机没有反应,连接尝试失败");
		
		elseif(msg.issuccess) then	
			System.User.Name = values.username;
			System.User.Password = values.password;
			System.User.ChatDomain = values.domain;
			
			paraworld.ShowMessage(L"登陆成功, 正在同步用户信息, 请稍候...");
			if(not MyCompany.Aquarius.app:ReadConfig("Registered", false)) then
				MyCompany.Aquarius.app:WriteConfig("Registered", true);
			end
			if(values.rememberpassword) then
				System.User.SaveCredential(System.User.Name, System.User.Password);
			end
			MyCompany.Aquarius.app:WriteConfig("rememberpassword", values.rememberpassword);
			
			-- login to JGSL chat 
			NPL.load("(gl)script/kids/3DMapSystemUI/Chat/Main.lua");
			System.App.Chat.OneTimeInit();
			
			-- download full profile and may optionally invoke app registration pages.
			LoginPage.LoginCallBack = funcCallBack;
			LoginPage.bSkipAppRegistration = bSkipAppRegistration;
			LoginPage.Proc_DownloadProfile(System.User.sessionkey, System.User.userid)
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
function LoginPage.Proc_DownloadProfile()
	-- TODO: System.App.profiles.ProfileManager.DownloadMCML(System.User.userid)
	-- TODO: after downloading, call LoginPage.Proc_AppReg()
	System.App.profiles.ProfileManager.DownloadFullProfile(nil, function (uid, appkey, bSucceed)
		if(bSucceed) then
			log("full user profile is downloaded for current user\n")
			-- after downloading current user profile, call application login procedure
			LoginPage.Proc_AppReg();
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
function LoginPage.Proc_AppReg()
	if(LoginPage.bSkipAppRegistration) then	
		return LoginPage.Proc_Complete();
	end
	
	-- we will check for these applications in order. 
	local RequiredApps = {
		{name="profiles", title=L"身份信息", status},
	};
	local required_count = 0;
	--
	-- pass one: get all application registration status. 
	--
	local index, appReg;
	for index, appReg in ipairs(RequiredApps) do
		local msg = System.App.Commands.Call("Registration."..appReg.name, {operation="query"});
		if(msg) then
			appReg.status = msg.response;
			if(appReg.status and not appReg.status.RequiredComplete) then
				required_count = required_count + 1;
			end	
		end
	end
	
	-- close popup and front page browser. 
	paraworld.ShowMessage(nil);
	local ctl = CommonCtrl.GetControl(LoginPage.browsername);
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
		LoginPage.AppRegPage.RequiredApps = RequiredApps;
		LoginPage.AppRegPage.OnFinishedFunc = LoginPage.Proc_Complete;
		local width, height = 640, 512
		local _parent = LoginPage.AppRegPage:Create("LoginApp.AppRegPage", nil, "_ct", -width/2, -height/2+15, width, height);
		if(_parent) then
			_parent:SetTopLevel(true);
		end
	else
		LoginPage.Proc_Complete();	
	end	
end

-- login procedure completed. 
function LoginPage.Proc_Complete()
	if(type(LoginPage.LoginCallBack) =="function") then
		-- call the user call back
		LoginPage.LoginCallBack();
	end
end