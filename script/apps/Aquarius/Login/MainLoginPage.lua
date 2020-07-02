--[[
Title: code behind for page MainLoginPage.html
Author(s): LiXizhi
Date: 2008/12/15
Desc:  script/apps/Aquarius/Login/MainLoginPage.html?cmdredirect=Profile.HomePage
Login stages are following. Offline mode can be enabled only when network is not found and the user has signed in before. 
stage==nil: initial stage
stage==1: paraworld.auth.GetServerList
stage==2: paraworld.auth.AuthUser
stage==3: paraworld.auth.VerifyNickName
stage==4: paraworld.auth.DownloadFullProfile
stage==5: paraworld.auth.AppReg
stage==6: paraworld.auth.VerifyAvatar
stage==7: Proc_PrepareEnterWorld
stage==10: Proc_Complete. waiting for JGSL to connect...
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Login/MainLoginPage.lua");
MyCompany.Aquarius.LoginPage.Proc_Start(values, funcCallBack, bSkipAppRegistration)
-------------------------------------------------------
]]
local L = CommonCtrl.Locale("ParaWorld");

local LoginPage = {};
commonlib.setfield("MyCompany.Aquarius.LoginPage", LoginPage)

LoginPage.sVersionFileName = "config/paraworld.ver";
---------------------------------
-- page event handlers
---------------------------------

-- init
function LoginPage.OnInit()
	--local self = document:GetPageCtrl();
	--local name = self:GetRequestParam("name")
	--self:SetNodeValue("fileName", name);
end

-- @param defaultVersion: if this is nil, 
function LoginPage.GetClientVersion(defaultVersion)
	if(not LoginPage.ClientVersion) then
		local bNeedUpdate = true;
		if( ParaIO.DoesFileExist(LoginPage.sVersionFileName)) then
			local file = ParaIO.open(LoginPage.sVersionFileName, "r");
			if(file:IsValid()) then
				local text = file:GetText();
				LoginPage.ClientVersion = tonumber(text);
				file:close();
			end
		end
		if(not LoginPage.ClientVersion) then
			LoginPage.ClientVersion = 1;
		end
	end
	return LoginPage.ClientVersion;
end

LoginPage.LoginCallBack = nil;
LoginPage.bSkipAppRegistration = true;
LoginPage.stage = nil;
-- start the login process, first get the server list and version and proceed to Proc_DownloadProfile()
-- if the client version is too old, remind the user to download update patch
-- @param values, funcCallBack, bSkipAppRegistration: values passed to the Proc_DownloadProfile()
function LoginPage.Proc_Start(values, funcCallBack, bSkipAppRegistration)
	LoginPage.stage = 0;
	paraworld.ShowMessage("正在获取服务器列表, 请稍候...", nil, _guihelper.MessageBoxButtons.Nothing);
	paraworld.auth.GetServerList(nil, "GetAquariusServerList", function(msg)
		if(LoginPage.stage >= 1) then
			return
		end
		LoginPage.stage = 1;
		commonlib.log("login stage %d: Getting server list\n", LoginPage.stage)
		
		if(msg == nil) then
			paraworld.ShowMessage("获取服务器列表失败，请查看网络连接\n");
		elseif(type(msg) == "table") then
			log("GetServerList: ")
			commonlib.echo(msg);
			-- change domain
			paraworld.ChangeDomain({
				domain = msg.domain,
				-- at Production time, chatdomain should be chatdomain = msg.ChatDomain, 
				chatdomain = msg.ChatDomain or msg.domain,
				--chatdomain = msg.domain,
				-- chatdomain = "192.168.0.233", 
				});
			
			--
			-- checking update
			--
			--msg.MinClientVersion = LoginPage.GetClientVersion()+1; -- for testing upgrading
			--msg.ClientVersion = LoginPage.GetClientVersion()+1; -- for testing upgrading
			
			-- remind the user to download update patch if the client version don't reach the minimum
			-- FIX: on some computer, the getserverlist gives me ClientVersion=1.00100004673, where trailing numbers are meaningless. This is due to TinyJson implementation of double type variables. 
			if(msg.MinClientVersion and LoginPage.GetClientVersion(msg.ClientVersion) < (msg.MinClientVersion-0.0001)) then
				local downloadurl = msg.DownloadPage or "http://www.pala5.com/"
				paraworld.ShowMessage(string.format("客户端需要更新才能使用,下载地址:\n%s\n 是否现在打开更新页面?", downloadurl), function(res)
					if(res and res == _guihelper.DialogResult.Yes) then
						ParaGlobal.ShellExecute("open", "iexplore.exe", downloadurl, "", 1);
						ParaGlobal.ExitApp()
					end	
				end, _guihelper.MessageBoxButtons.YesNo);
				return;
			end
			if(msg.ClientVersion and LoginPage.GetClientVersion(msg.ClientVersion) < (msg.ClientVersion-0.0001)) then
				local downloadurl = msg.DownloadPage or "http://www.pala5.com/"
				paraworld.ShowMessage(string.format("客户端有新的升级版,下载地址:\n%s\n 是否现在更新?(不更新也可以登录)", downloadurl), function(res)
					if(res and res == _guihelper.DialogResult.Yes) then
						ParaGlobal.ShellExecute("open", "iexplore.exe", downloadurl, "", 1);
						ParaGlobal.ExitApp()
					else
						paraworld.ShowMessage("正在验证用户身份, 请等待...", nil, _guihelper.MessageBoxButtons.Nothing)
						LoginPage.Proc_Authentication(values, funcCallBack, bSkipAppRegistration);
					end	
				end, _guihelper.MessageBoxButtons.YesNo);
				return;
			end
			
			paraworld.ShowMessage("正在验证用户身份, 请等待...", nil, _guihelper.MessageBoxButtons.Nothing)
			LoginPage.Proc_Authentication(values, funcCallBack, bSkipAppRegistration);
		end
	end)
end

-- Authenticate user and proceed to Proc_DownloadProfile(). it will assume the normal login procedures. It starts with authentification and ends with callback function or user profile page. 
-- @param values: a table containing authentification info {username, password, domain, rememberpassword}. username, password should be validated locally before passing them here. 
-- @param funcCallBack: this is a callback function to be invoked when login complete. If nil, it will display the profile page for the user. 
-- @param bSkipAppRegistration: whether to skip uncompleted application registration. 
function LoginPage.Proc_Authentication(values, funcCallBack, bSkipAppRegistration)
	local msg = {
		username = values.username,
		password = values.password,
		format = 1,
	}
	
	paraworld.auth.AuthUser(msg, "login", function (msg)
		if(LoginPage.stage >= 2) then
			return
		end
		LoginPage.stage = 2;
		commonlib.log("login stage %d: AuthUser\n", LoginPage.stage)
		
		if(msg==nil) then
			paraworld.ShowMessage(L"连接的主机没有反应,连接尝试失败");
		elseif(msg.issuccess) then	
			System.User.Name = values.username;
			System.User.Password = values.password;
			--System.User.ChatDomain = values.domain;
			
			paraworld.ShowMessage(L"登陆成功, 正在同步用户信息, 请稍候...", nil, _guihelper.MessageBoxButtons.Nothing);
			if(not MyCompany.Aquarius.app:ReadConfig("Registered", false)) then
				MyCompany.Aquarius.app:WriteConfig("Registered", true);
			end
			if(values.rememberpassword) then
				System.User.SaveCredential(System.User.Name, System.User.Password);
			end
			MyCompany.Aquarius.app:WriteConfig("rememberpassword", values.rememberpassword);
			
			-- call the get info once logged in, to validate the fullname, we assume that the CachePolicy is "1 day"
			-- TODO: this policy will fail if user stay up across two days, the first paraworld.users.getInfo call on the next day 
			--		will execute the post function twice. First one is an immediate return from local server and the second is 
			--		returned from a new established web service call.
			--System.App.profiles.ProfileManager.GetUserInfo(nil,nil,nil, "access plus 0 day");
			-- System.App.profiles.ProfileManager.GetMCML();
			
			-- ProfileManager.GetMCML(uid, Map3DSystem.App.appkeys["profiles"], callbackFunc)
			-- paraworld.profile.GetMCML({uid = System.User.userid, }, "AquariusMyselfMCML");
			
			-- download full profile and may optionally invoke app registration pages.
			LoginPage.LoginCallBack = funcCallBack;
			LoginPage.bSkipAppRegistration = bSkipAppRegistration;
			
			--LoginPage.Proc_DownloadProfile(System.User.sessionkey, System.User.userid)
			
			LoginPage.Proc_VerifyNickName();
			
			--LoginPage.Proc_Complete();
		else
			if(msg.errorcode == 412) then
				paraworld.ShowMessage(string.format("%s\n\n%s", tostring(msg.info), 
					"维护性封号！"), 
					--"账号未激活, 我们需要您通过Email等方式确认您的身份后才能登陆\n是否希望重新发送确认信到你注册时提供的邮箱?"), 
					function()
						paraworld.auth.SendConfirmEmail({username = values.username, password = values.password,}, "Login", function(msg)
							if(msg ~= nil) then
								if(msg.issuccess) then
									paraworld.ShowMessage("发送成功, 请查看你的邮箱");
								else
									-- 497：数据不存在或已被删除 414：账号已是激活状态不必再次激活 
									if(msg.errorcode==497) then
										paraworld.ShowMessage("数据不存在或已被删除");
									elseif(msg.errorcode==414) then
										paraworld.ShowMessage("账号已是激活状态不必再次激活");
									else
										paraworld.ShowMessage("未知服务器错误, 请稍候再试");
									end
								end	
							end
						end)
					end);
			else
				-- to disable offline mode, simply undefine below. 2008.12.27 by LXZ
				local SupportOfflineMode = true;
				
				if(SupportOfflineMode and msg.HasOfflineMode) then
					-- tricky,this set us back to auth stage for offline mode login. 2008.12.27
					LoginPage.stage = 1;
				else
					paraworld.ShowMessage(msg.info);
				end	
			end
		end
	end)
end

-- verify nickname and avatar CCS info
-- if no nickname and avatar CCS infomation is filled, remind the user to choose a permient nickname and avatar
function LoginPage.Proc_VerifyNickName()
	paraworld.ShowMessage("正在获取人物信息", nil, _guihelper.MessageBoxButtons.Nothing);
	
	System.App.profiles.ProfileManager.GetUserInfo(System.User.nid, "Proc_VerifyNickName", function(msg)
		if(LoginPage.stage >= 3) then
			return
		end
		LoginPage.stage = 3;
		commonlib.log("login stage %d: Proc_VerifyNickName\n", LoginPage.stage)
		
		if(msg == nil or not msg.users or not msg.users[1]) then
			commonlib.echo(msg)
			paraworld.ShowMessage("确认用户信息失败，请稍候再试");
			return;
		end
		
		local nickname = msg.users[1].nickname;
		if(nickname == nil or nickname == "") then
			--paraworld.ShowMessage("请选择昵称");
			paraworld.ShowMessage();
			
			local _panel = ParaUI.CreateUIObject("container", "SelectNickName_panel", "_fi", 0, 0, 0, 0);
			_panel.background = "";
			_panel.zorder = 5;
			_panel:AttachToRoot();
			
			local _selectNickName = ParaUI.CreateUIObject("container", "SelectNickName", "_ct", -175, -64, 350, 200);
			_selectNickName.background = "Texture/Aquarius/Login/MessageBox_32bits.png:8 8 16 16";
			_panel:AddChild(_selectNickName);
			
			local _text = ParaUI.CreateUIObject("text", "NickName", "_lt", 30, 25, 290, 40);
			_text.font = System.DefaultLargeBoldFontString;
			_text.text = "    为你的角色起一个昵称吧，它是你在这个社区中的名号，也将是其他人区分你和别的玩家最重要的标识呢！\n\n    每个玩家的昵称都是独一无二的，所以尽量让它独具特色，彰显你自己的个性吧！";
			_selectNickName:AddChild(_text);
			
			local _nickname = ParaUI.CreateUIObject("imeeditbox", "Proc_VerifyNickName", "_lt", 60, 150, 130, 24);
			_selectNickName:AddChild(_nickname);
			
			local _confirm = ParaUI.CreateUIObject("button", "Confirm", "_lt", 205, 150, 80, 24);
			_confirm.onclick = ";MyCompany.Aquarius.LoginPage.SelectNickName();";
			_confirm.text = "选择昵称";
			_confirm:SetDefault(true);
			_selectNickName:AddChild(_confirm);
		else
			ParaUI.Destroy("SelectNickName_panel");
			LoginPage.Proc_DownloadProfile();
		end
	end, "access plus 0 day");
end

function LoginPage.SelectNickName()
	local _nickname = ParaUI.GetUIObject("Proc_VerifyNickName");
	if(_nickname:IsValid() == true) then
		if(_nickname.text == "") then
			paraworld.ShowMessage("请输入一个昵称");
			return;
		end
		local msg = {
			sessionkey = System.User.sessionkey,
			nickname = _nickname.text,
		};
		paraworld.users.setInfo(msg, "SelectNickName", function(msg)
			if(msg == nil) then
				paraworld.ShowMessage("设置昵称失败，请稍候再试");
				return;
			end
			if(msg.issuccess == true) then
				ParaUI.Destroy("SelectNickName_panel");
				LoginPage.Proc_DownloadProfile();
			else
				if(msg.errorcode == 418) then
					paraworld.ShowMessage("该昵称已经有人使用了，请选择其他昵称");
				else
					paraworld.ShowMessage("该昵称不能使用");
				end
			end
		end);
	end
end

-- Download profile and proceed to Proc_AppReg()
function LoginPage.Proc_DownloadProfile()
	paraworld.ShowMessage("正在获取个人信息", nil, _guihelper.MessageBoxButtons.Nothing);
	
	System.App.profiles.ProfileManager.DownloadFullProfile(nil, function (uid, appkey, bSucceed)
		if(LoginPage.stage >= 4) then
			return
		end
		LoginPage.stage = 4;
		commonlib.log("login stage %d: Proc_DownloadProfile\n", LoginPage.stage)
		
		if(bSucceed) then
			-- after downloading current user profile, call application login procedure
			LoginPage.Proc_AppReg();
		else
			-- paraworld.ShowMessage("无法从服务器获取用户信息, 可能服务器正忙, 请稍候再试.");
			-- NOTE: for offline mode, proceed anyway. Find a better way, since this could be Online mode error as well.
			log("DownloadFullProfile: failed. Proceed to offline mode anyway. \n")
			LoginPage.Proc_AppReg();
		end
	end, "access plus 0 day"); -- added a cache policy that will always get the full profile in download full profile stage
end

-- OBSOLETED:  proceed to Proc_VerifyAvatar immediately
function LoginPage.Proc_AppReg()
	LoginPage.Proc_VerifyAvatar();
end


function LoginPage.Proc_VerifyAvatar()
	--paraworld.ShowMessage("Proc_VerifyAvatar");
	paraworld.ShowMessage("正在获取人物形象", nil, _guihelper.MessageBoxButtons.Nothing);
	
	System.App.profiles.ProfileManager.GetMCML(System.User.userid, System.App.appkeys["CCS"], function(uid, app_key, bSucceed)
		if(LoginPage.stage >= 6) then
			return
		end
		LoginPage.stage = 6;
		commonlib.log("login stage %d: Proc_VerifyAvatar\n", LoginPage.stage)
		
		if(bSucceed) then
			local profile = System.App.profiles.ProfileManager.GetMCMLInMemory(uid, app_key);
			if(profile and profile.CharParams and profile.CharParams.AssetFile) then
				-- contiune
				LoginPage.Proc_PrepareEnterWorld()
			else
				paraworld.ShowMessage();
				local _panel = ParaUI.CreateUIObject("container", "SelectAvatar_panel", "_fi", 0, 0, 0, 0);
				_panel.background = "";
				_panel.zorder = 5;
				_panel:AttachToRoot();
				
				local _selectAvatar = ParaUI.CreateUIObject("container", "SelectAvatar", "_ct", -320, -200, 640, 480);
				_selectAvatar.background = "Texture/Aquarius/Login/MessageBox_32bits.png:8 8 16 16";
				_panel:AddChild(_selectAvatar);
				
				local _avatarRegPage = System.mcml.PageCtrl:new({url="script/apps/Aquarius/Login/AvatarRegPage.html"});
				_avatarRegPage:Create("SelectAvatar", _selectAvatar, "_fi", 10, 30, 9, 18);
			end
		else
			-- TODO 2008.4.3: if update failed, shall we display something different(a 3D exclamation mark) in canvas?
			paraworld.ShowMessage("获取人物形象失败");
		end
	end, "access plus 0 day");
end

function LoginPage.Proc_PrepareEnterWorld()
	paraworld.ShowMessage("准备进入公共世界, 请稍候...", nil, _guihelper.MessageBoxButtons.Nothing);
	ParaUI.Destroy("SelectNickName_panel");
	ParaUI.Destroy("SelectAvatar_panel");
	
	System.App.profiles.ProfileManager.GetMCML(System.User.userid, System.App.appkeys["CCS"], function(uid, app_key, bSucceed)
		if(LoginPage.stage >= 7) then
			return
		end
		LoginPage.stage = 7;
		commonlib.log("login stage %d: Proc_PrepareEnterWorld\n", LoginPage.stage)
		
		if(bSucceed) then
			-- contiune
			LoginPage.Proc_Complete();
		else
			-- TODO 2008.4.3: if update failed, shall we display something different(a 3D exclamation mark) in canvas?
			paraworld.ShowMessage("获取人物形象失败");
		end
	end, "access plus 0 day", "Proc_PrepareEnterWorld_GetCCSProfile");
	
end


-- login procedure completed. 
function LoginPage.Proc_Complete()
	if(LoginPage.stage >= 10) then
		return
	end
	LoginPage.stage = 10;
	commonlib.log("login stage %d: Proc_Complete\n", LoginPage.stage)
	
	paraworld.ShowMessage("准备装载世界, 请稍候...", nil, _guihelper.MessageBoxButtons.Nothing);
	
	-- login to JGSL chat 
	NPL.load("(gl)script/kids/3DMapSystemUI/Chat/Main.lua");
	System.App.Chat.OneTimeInit();
	-- TODO: LiXizhi 2008.12.24. Connect to the world if it is not yet connected. 
	System.App.Chat.AddEventListener("JE_OnAuthenticate", function(msg)
		System.App.Commands.Call("File.ConnectAquariusWorld");
	end)
		
	if(type(LoginPage.LoginCallBack) =="function") then
		-- call the user call back
		LoginPage.LoginCallBack();
	end
end