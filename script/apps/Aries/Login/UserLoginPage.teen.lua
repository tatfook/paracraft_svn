--[[
Title: UserLoginPage for teen version
Author(s): WD
Date: 2011/09/02
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/UserLoginPage_teen.teen.lua");
-------------------------------------------------------
]]
local UserLoginPage_teen = commonlib.gettable("MyCompany.Aries.UserLoginPage_teen");

--是否处于服务器关闭时间，如果是 隐藏此页面，只显示服务器关闭提醒
UserLoginPage_teen.isClosedTime = false; 

local echo = commonlib.echo;

---------------------------------
-- page event handlers
---------------------------------
-- singleton page
local page;

local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");

-- init
function UserLoginPage_teen.OnInit()
	page = document:GetPageCtrl();
	
	local name = page:GetRequestParam("username");
	local password = page:GetRequestParam("password");
	
	if(MainLogin.state.local_user) then
		name = name or MainLogin.state.local_user.email or MainLogin.state.local_user.user_nid;
		password = password or MainLogin.state.local_user.password;
	end
	if(name == nil or name == "") then
		name = ParaEngine.GetAppCommandLineByParam("uid", "");
	end

	if(name) then
		if(tonumber(name)) then
			name = MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(name);
		end
		page:SetNodeValue("user_name", name);
	end	
	if(password and password~="") then
		page:SetNodeValue("password", password);
		page:SetValue("checkbox_remember_password", true);
	elseif(System.options.IsMobilePlatform)then
		page:SetValue("checkbox_remember_password", true);
	end	
	
	-- 2010/5/5 instant login
	-- if the following file exist the login process will use the username and password in the file to process instant login
	if(ParaIO.DoesFileExist("temp/instant_login/username", true) == true) then
		if(ParaIO.DoesFileExist("temp/instant_login/password", true) == true) then
			
			local user_name, password;
			local file = ParaIO.open("temp/instant_login/username", "r");
			if(file:IsValid() == true) then
				user_name = file:readline();
				file:close();
			end
			local file = ParaIO.open("temp/instant_login/password", "r");
			if(file:IsValid() == true) then
				password = file:readline();
				file:close();
			end
			
			UserLoginPage_teen.OnClickLogin(btnName, {
				user_name = user_name,
				password = password,
				checkbox_remember_username = true,
				checkbox_remember_password = true,
			})
		end
	end
end

function UserLoginPage_teen.OnClickBackToLocalUserSelect()
	if(MainLogin.state.local_user) then
		MainLogin.state.local_user.password = nil;
	end
	if(page) then
		page:CloseWindow();
	end
	MyCompany.Aries.MainLogin:SelectLocalUser();
end

function UserLoginPage_teen.OnClickRegister(realnm)
	
	if(System.options.locale == "zhTW") then
		ParaGlobal.ShellExecute("open", MyCompany.Aries.ExternalUserModule:GetConfig().registration_url, "", "", 1);
		return;
	end

	if(page) then
		page:CloseWindow();
	end
	if (realnm==1) then
		MainLogin:next_step({IsRegistrationRequested = true, IsLoginStarted=false,IsRegRealnm=true});
	else
		MainLogin:next_step({IsRegistrationRequested = true, IsLoginStarted=false,IsRegRealnm=false});
	end	
end

function UserLoginPage_teen.OnClickChangePassword()
	NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
	local cfg = ExternalUserModule:GetConfig();
	local url_changepasswd= cfg.account_change_url;
	ParaGlobal.ShellExecute("open", url_changepasswd, "", "", 1);
end

function UserLoginPage_teen.OnClickForgetPassword()
	NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
	local cfg = ExternalUserModule:GetConfig();
	local url_forgetpasswd= cfg.account_forget_url;
	ParaGlobal.ShellExecute("open", url_forgetpasswd, "", "", 1);
end

function UserLoginPage_teen.OnClickProtectPassword()
	NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
	local cfg = ExternalUserModule:GetConfig();
	local url_protectpasswd= cfg.account_protect_url;
	ParaGlobal.ShellExecute("open", url_protectpasswd, "", "", 1);
end

-- uncheck remember password if remember username is unchecked. 
function UserLoginPage_teen.OnCheckRememberUsername(bChecked)
	if(not bChecked) then
		page:SetValue("checkbox_remember_password", false);
	end
end

-- notify the user if the password checkbox is checked
function UserLoginPage_teen.OnCheckRememberPassword(bChecked)
	if(bChecked == true) then
		local s = string.format([[只有在自己家里上网才能选择“记住密码”；<br/>
		并且要牢记自己的%s和密码哦！
		]],MyCompany.Aries.ExternalUserModule:GetConfig().account_name);
		_guihelper.MessageBox(s);
	end
end


function UserLoginPage_teen.OnClickLogin(btnName,forms)
	if(System.options.login_tokens) then
		local tokens = System.options.login_tokens;
		forms = forms or {};
		page:CloseWindow();
		MainLogin:next_step({IsLoginStarted=true, auth_user = {
			username=tokens.id or tokens.userid or tokens.nid, 
			password=tokens.password,
			loginplat = tokens.loginplat, 
			from = tokens.from,
			plat = tokens.plat,
			time = tokens.time,
			token = tokens.key,
			oid = tokens.oid,
			website = tokens.website,
			sid = tokens.sid,
			game = tokens.game,
			rememberpassword=false, rememberusername=true}});
		return;
	end

	local user_name = string.gsub(page:GetValue("user_name"), "^%s*(.-)%s*$", "%1");
	local password = string.gsub(page:GetValue("password"), "^%s*(.-)%s*$", "%1");
	local user_nid = tonumber(user_name);
	
	NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
	local region_config = ExternalUserModule:GetConfig();

	if(not forms.checkbox_remember_password) then
		forms.checkbox_remember_password = false;
	end

	local email;
	if(user_nid) then
		if (user_nid<10000 or user_nid>999999999999) then
			local s = string.format([[请输入正确的%s或Email]],MyCompany.Aries.ExternalUserModule:GetConfig().account_name);
			_guihelper.MessageBox(s)
			return
		end	
	else
		email = user_name;

		if (region_config.is_username_email) then
			if(not string.find(email, "[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?")) then
				if (System.options.locale == "zhCN") then
					local _chk = string.match(user_name,"([^A-Za-z0-9_]+)");
					if (_chk) then
						local s = string.format([[请输入正确的%s或Email]],MyCompany.Aries.ExternalUserModule:GetConfig().account_name);
						_guihelper.MessageBox(s)
						return
					end
				end
			end
			local userPart, domainPart = string.match(email, "(.*)@(.*)$");
			-- this is for debugging purposes only. "@paraengine.com" will be ignored. 
			if(domainPart == "paraengine.com") then
				-- strip domain part 
				user_name = userPart
				commonlib.applog("UserLoginPage_teen's domain part is ignored. Remove this in release build. ")
			end		
		end
		
	end

	local min_passwdlen = tonumber(region_config.min_passwdlen) or 0;
	if(string.len(password)<min_passwdlen) then
		local s = string.format("密码需要在 % d位以上哦!",min_passwdlen)
		_guihelper.MessageBox(s)
		return
	end
	
	if(string.len(user_name)>50) then
		local s = string.format([[请输入正确的%s或Email]],MyCompany.Aries.ExternalUserModule:GetConfig().account_name);
		_guihelper.MessageBox(s)
		return
	end
	
	page:CloseWindow();
	MainLogin:next_step({IsLoginStarted=true, auth_user = {username=user_name, password=password, 
		rememberpassword=forms.checkbox_remember_password, rememberusername=forms.checkbox_remember_username}});
end
