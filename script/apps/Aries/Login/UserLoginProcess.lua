--[[
Title: Aries User Login Process
Author(s): WangTian, LiXizhi
Date: 2009/4/6
Desc:  script/apps/Aries/Login/UserLoginProcess.html?cmdredirect=Profile.HomePage
Login stages are following. Offline mode can be enabled only when network is not found and the user has signed in before. 
stage==nil: initial stage
stage==1: connect to gateway (game) server for user auth
stage==2: paraworld.auth.AuthUser
stage==3: Proc_VerifyNickName
stage==4: Proc_DownloadFullProfile
stage==5: Proc_SyncGlobalStore
stage==6: Proc_VerifyInventory
stage==7: Proc_VerifyPet
stage==8: Proc_VerifyFriends
stage==10: Proc_Complete. waiting for JGSL to connect...
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/UserLoginProcess.lua");
MyCompany.Aries.UserLoginProcess.Proc_Start(values, funcCallBack, bSkipAppRegistration)
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/SwfLoadingBarPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/ShutdownTimer.lua");
NPL.load("(gl)script/apps/Aries/Chat/Main.lua");
local UserLoginProcess = commonlib.gettable("MyCompany.Aries.Login.UserLoginProcess");

NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");

local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");

UserLoginProcess.LoginCallBack = nil;

-- whether to use flash loader
local bUseFlashLoader = true;

-- Display error message and go back to login page. 
-- @msg: text to shown in message box
-- @state: nil or a table to pass to MainLogin:next_step(). if nil it defaults to {IsLoginStarted = false}
-- @callbackFunc: a callback function to be invoked
function UserLoginProcess.Fail(msg, state, callbackFunc)
	if(bUseFlashLoader)then
		Map3DSystem.App.MiniGames.SwfLoadingBarPage.UpdateText(nil);
		Map3DSystem.App.MiniGames.SwfLoadingBarPage.ClosePage();
	end
	UserLoginProcess.percentage = 0;
	
	
	local isClosed = Map3DSystem.App.MiniGames.ShutdownTimer_Instance.IsClosedTime()
	if(not isClosed)then
		_guihelper.MessageBox(msg or "无法登录, 未知错误", callbackFunc, _guihelper.MessageBoxButtons.OK);
	else
		--启动服务器关闭提醒
		Map3DSystem.App.MiniGames.ShutdownTimer_Instance.Start();
		_guihelper.MessageBox(msg or "无法登录, 未知错误", callbackFunc, _guihelper.MessageBoxButtons.OK);
	end
	
	MainLogin:next_step(state or {IsLoginStarted = false});
end

function UserLoginProcess.HideProgressUI()
	if(bUseFlashLoader)then
		Map3DSystem.App.MiniGames.SwfLoadingBarPage.UpdateText(nil);
		Map3DSystem.App.MiniGames.SwfLoadingBarPage.ClosePage();
	end
end


local msgbox_icon = {src="Texture/Aquarius/Common/Waiting_32bits.png; 0 0 24 24", animstyle=39};

-- current login procentage. 
UserLoginProcess.percentage = 0;

-- display current progress. Pass nil to all params like UserLoginProcess.ShowProgress(); will hide UI. 
-- @param msg: message string. If nil, it means 100% finished. 
-- @param percentage: value in [0,100]. If nil, it will just increase the self.percentage by step or 10. 
-- @param step: the step to increase when percentage is nil. default to 10. 
function UserLoginProcess.ShowProgress(msg, percentage, step)
	if(percentage) then
		UserLoginProcess.percentage = percentage;
	else
		UserLoginProcess.percentage = UserLoginProcess.percentage + (step or 10);
		if(UserLoginProcess.percentage >= 100) then
			UserLoginProcess.percentage = 99
		end
	end
	if(not msg) then
		UserLoginProcess.percentage = 100;
	end
	
	-- commonlib.echo({"ShowProgress", msg})
	
	-- TODO: leio, update Loader UI here. message is {text=msg, percent = UserLoginProcess.percentage}, msg may be nil, percent is [0,100]
	if(bUseFlashLoader)then
		local p = UserLoginProcess.percentage or 0;
		if(p == 0)then
			Map3DSystem.App.MiniGames.SwfLoadingBarPage.ShowPage(
				{ top = -50 }
			);
		else
			Map3DSystem.App.MiniGames.SwfLoadingBarPage.ShowPage({top = -50});
		end
		p = p / 100;
		Map3DSystem.App.MiniGames.SwfLoadingBarPage.Update(p);
		Map3DSystem.App.MiniGames.SwfLoadingBarPage.UpdateText(msg);
		if(p == 1)then
			Map3DSystem.App.MiniGames.SwfLoadingBarPage.UpdateText(nil);
			Map3DSystem.App.MiniGames.SwfLoadingBarPage.ClosePage();
		end
	else
		_guihelper.MessageBox(msg, nil, _guihelper.MessageBoxButtons.Nothing, msgbox_icon, "script/ide/styles/ThinFrameMessageBox.html");
	end
end

-- we will load the default host and port if any, according to last user successful login or preferred port. 
function UserLoginProcess.LoadDefaultGatewayServer()
	if(UserLoginProcess.is_default_gateway_setting_loaded) then
		return;
	end
	UserLoginProcess.is_default_gateway_setting_loaded = true;

	NPL.load("(gl)script/apps/Aries/Player/main.lua");
	NPL.load("(gl)script/apps/GameServer/rest_client.lua");
	-- we shall load the last game server by default. 
	local last_server = MyCompany.Aries.Player.LoadLocalData("LastWorldServer", nil, true);
	if(last_server and last_server.nid) then
		GameServer.rest.client.preferred_nid = last_server.nid;
	end
	
	-- we shall load predefined login port. 
	GameServer.rest.client.preferred_port = MyCompany.Aries.Player.LoadLocalData("preferred_port", nil, true);
	local last_port = MyCompany.Aries.Player.LoadLocalData("LastPort", nil, true);
	
	if(last_port ~= tostring(GameServer.rest.client.preferred_port)) then
		-- if we have never successfully logged in using the preferred port, we will remove the preferred port. 
		if(GameServer.rest.client.preferred_port~=nil) then
			LOG.std(nil, "info", "UserLoginProcess", "revert preferred port of %s", tostring(GameServer.rest.client.preferred_port));
			MyCompany.Aries.Player.SaveLocalData("preferred_port", nil, true);
		end
	end
	if(GameServer.rest.client.preferred_port) then
		if(GameServer.rest.client.preferred_port == -1) then
			GameServer.rest.client.preferred_port = nil;
		else
			LOG.std(nil, "info", "UserLoginProcess", "we are now replacing remote port with %d", GameServer.rest.client.preferred_port);
			-- MyCompany.Aries.Player.SaveLocalData("preferred_port", nil, true)
		end
	end
end

-- establish the first rest connection with the initial gateway game server. 
function UserLoginProcess.Proc_ConnectRestGateway()
	UserLoginProcess.ShowProgress("正在建立连接...", 0);
	
	UserLoginProcess.LoadDefaultGatewayServer();
	-- max number of login server to retry in sequence. 
	-- set to 0 to disable retry and a dialog is displayed to the user. 
	local max_retry_count = 2;
	local cur_retry_count = 0;
	
	if(paraworld.use_game_server) then
		
		local function StartConnect_()
			LOG.std("", "system", "Login", "try connecting to game server the %d times", cur_retry_count+1);
			-- set redirecting to true to prevent disconnection message box to appear. 
			System.User.IsRedirecting = true;
			local res = GameServer.rest.client:start(System.options.clientconfig_file, 0, function(msg)
				if(msg and msg.connected) then
					GameServer.rest.client:EnableKeepAlive(true, 9000);
					MainLogin:next_step({IsRestGatewayConnected = true});
				else
					MainLogin.state.gateway_server = nil;
					if(cur_retry_count<max_retry_count) then
						cur_retry_count = cur_retry_count + 1;
						UserLoginProcess.ShowProgress(string.format("正在建立连接...(第%d次尝试)", cur_retry_count+1), 0);
						StartConnect_();
					else
						System.User.IsRedirecting = true;
						UserLoginProcess.Fail([[<div style="margin-left:24px;margin-top:32px;">服务器的链接无法建立, 请稍候再试</div>]], {IsRestGatewayConnected = false, IsLoginStarted=false, IsUserSelected= false, IsRegistrationRequested=false, IsLocalUserSelected=false}, function()
							MainLogin:OnSolveNetworkIssue();
						end);
					end	
				end
			end, MainLogin.state.gateway_server)
			if( res ~= 0) then
				UserLoginProcess.Fail("服务器的链接无法建立",{IsRestGatewayConnected = false, IsLoginStarted=false, IsUserSelected= false, IsRegistrationRequested=false, IsLocalUserSelected=false}, function()
					MainLogin:OnSolveNetworkIssue();
				end);
			end
		end
		StartConnect_();
	else
		MainLogin:next_step({IsRestGatewayConnected = true});
	end
end

function UserLoginProcess.Proc_Registration()
	UserLoginProcess.ShowProgress("正在注册, 请等待...");
	
	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_Registration"}, "user_login_process_stage_progress_log", function(msg)
	end);

	paraworld.users.Registration(commonlib.deepcopy(MainLogin.state.reg_user), "TaoMee", function(msg)
		if(not msg) then
			UserLoginProcess.Fail("无法连接到服务器! 请使用网页注册！", {IsRegistrationRequested=true, IsRegUserRequested=false});
			ParaGlobal.ShellExecute("open", "http://account.61.com/register?gid=21", "", "", 1);
			-- send log information
			paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_Registration_connect_server_fail"}, 
				"user_login_process_stage_fail_log", function(msg)
			end);
		elseif(msg.issuccess) then
			-- send log information
			paraworld.PostLog({reg_nid = tostring(msg.nid), action = "regist_success"}, "regist_success_log", function(msg)
			end);
			-- proceed to registration succeed page. 
			UserLoginProcess.ShowProgress();
			MainLogin.state.reg_user.nid = tostring(msg.nid);
			--MainLogin.state.auth_user.username = tostring(msg.nid);
			MainLogin.state.auth_user = {username = tostring(msg.nid), password = MainLogin.state.reg_user.password, rememberusername=true, is_new_user = true, rememberpassword=false};
			MainLogin:next_step({IsRegUserRequested = false, IsRegUserConfirmRequested = true});
			-- commonlib.echo("============users.Registration success==========");
			-- commonlib.echo(MainLogin.state.auth_user);
			
		elseif(msg.errorcode) then	
			if(msg.errorcode == 401) then
				local s = string.format("这个邮箱地址已经注册过啦!<br/>【哈奇提醒】你的一个邮箱地址只能注册一个%s哦！",MyCompany.Aries.ExternalUserModule:GetConfig().account_name);
				UserLoginProcess.Fail(s, {IsRegistrationRequested=true, IsRegUserRequested=false});
				-- send log information
				paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_Registration_email_registered"}, 
					"user_login_process_stage_fail_log", function(msg)
				end);
			elseif (msg.errorcode == 444) then
				UserLoginProcess.Fail("验证码错误，请重新输入！", {IsRegistrationRequested=true, IsRegUserRequested=false});
			else
				log("error: can not register through paraworld.users.Registration, errorcode:"..msg.errorcode.."\n")
				UserLoginProcess.Fail("哈奇内暂时无法注册，请使用网页注册！", {IsRegistrationRequested=true, IsRegUserRequested=false});				
				ParaGlobal.ShellExecute("open", "http://account.61.com/register?gid=21", "", "", 1);
				-- send log information
				paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_Registration_unknown_errorcode"}, 
					"user_login_process_stage_fail_log", function(msg)
				end);
			end
		else
			UserLoginProcess.Fail("无法连接到服务器", {IsRegistrationRequested=true, IsRegUserRequested=false});
		end	
	end, nil, 20000, function(msg)
		-- timeout request
		LOG.std("", "error","Login", "Proc_Registration timed out");
		UserLoginProcess.Fail("用户注册超时了, 请使用网页注册！", {IsRegistrationRequested=true, IsRegUserRequested=false});					
		ParaGlobal.ShellExecute("open", "http://account.61.com/register?gid=21", "", "", 1);
		-- send log information
		paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_Registration_timed_out"}, 
			"user_login_process_stage_fail_log", function(msg)
		end);
	end)
end

-- Authenticate user and proceed to Proc_DownloadProfile(). it will assume the normal login procedures. It starts with authentification and ends with callback function or user profile page. 
function UserLoginProcess.Proc_Authentication()
	local values = MainLogin.state.auth_user;
	local msg = {
		username = values.username,
		password = values.password,
		plat = values.plat,
		loginplat = values.loginplat,
		oid = values.oid,
		nid2 = values.nid2,
		token = values.token,
		from = values.from,
		time = values.time,
		website = values.website,
		sid = values.sid,
		game = values.game,
		valicode = UserLoginProcess.last_veri_code,
		sessionid = System.User.sessionid,
	}
	
	LOG.std("", "debug","Login.begin", msg);
	UserLoginProcess.ShowProgress("验证用户身份");
	LOG.std("", "system","Login", "Start Proc_Authentication");
	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_Authentication"}, "user_login_process_stage_progress_log", function(msg)
	end);
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Chat/Main.lua");
	-- close jabber if we authenticate again. 
	System.App.Chat.CleanUp();
			
	paraworld.auth.AuthUser(msg, "login", function (msg)

		 --commonlib.echo("============users.Authentication after ==========");
		 --commonlib.echo(msg);

		if(msg==nil) then
			UserLoginProcess.Fail("连接的主机没有反应,连接尝试失败");
			-- send log information
			paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_Authentication_server_no_response"}, 
				"user_login_process_stage_fail_log", function(msg)
			end);
		elseif(msg.issuccess) then
			--System.User.Name = values.username; -- 2010/2/25: fix the tutorial bug
			System.User.Name = tostring(msg.nid);
			System.User.Password = values.password;
			System.User.sessionid = "";
			System.User.LastAuthGameTime = ParaGlobal.timeGetTime();
			System.User.LastAuthServerTime = msg.dt or "2009-11-23 21:18:38"; -- yyyy-MM-dd HH:mm:ss
			--System.User.ChatDomain = values.domain;

			--local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");							
			--if (ExternalUserModule:GetRegionID()==2) then
				--local _realname= msg.real_name;
				--if (_realname=="") then
					--System.User.IsRealname=true;
				--else
					--System.User.IsRealname=false;
				--end
			--end

			if(not MyCompany.Aries.app:ReadConfig("Registered", false)) then
				MyCompany.Aries.app:WriteConfig("Registered", true);
			end
			--if(values.rememberpassword) then
				--System.User.SaveCredential(System.User.Name, System.User.Password);
			--end
			UserLoginProcess.rememberusername = values.rememberusername;
			UserLoginProcess.rememberpassword = values.rememberpassword;
			
			if(not values.is_new_user) then
				MyCompany.Aries.app:WriteConfig("rememberpassword", values.rememberpassword);
			end
			
			NPL.load("(gl)script/apps/Aries/Desktop/AriesSettingsPage.lua");
			local stats = MyCompany.Aries.Desktop.AriesSettingsPage.GetPCStats()
			local stats_str = string.format("%s|vs:%d|ps:%d|OS:%s|mem:%d|res:%d*%d|fullscreen:%s|webplayer:%s|", 
				stats.videocard or "", stats.vs or 0, stats.ps or 0, stats.os or "", stats.memory or 0, 
				stats.resolution_x, stats.resolution_y, tostring(stats.IsFullScreenMode), tostring(stats.IsWebBrowser));
			-- send log information
			paraworld.PostLog({action = "graphic_stats", stats = stats_str}, "graphic_stats_log", function(msg)
			end);
			
			-- post log with debug app loaded
			local isDebugAppLoaded = commonlib.getfield("System.App.AppManager.isDebugAppLoaded");
			if(isDebugAppLoaded == true) then
				-- send log information
				paraworld.PostLog({action = "debugapp_loaded"}, "debugapp_loaded_log", function(msg)
				end);
			end
			
			-- post log for debug app written in db but not loaded
			local isDebugAppRemoved = commonlib.getfield("System.App.AppManager.isDebugAppRemoved");
			if(isDebugAppRemoved == true) then
				-- send log information
				paraworld.PostLog({action = "debugapp_breakin"}, "debugapp_breakin_log", function(msg)
				end);
			end			
	
			--if(values.username == "newuser") then
				---- this is just for testing the create user process. 
				--commonlib.applog("remove me to hide avatar creation on start up")
				--MainLogin:next_step({IsAuthenticated = true, IsAvatarCreationRequested = true});
			--else	
				--MainLogin:next_step({IsAuthenticated = true, IsAvatarCreationRequested = (msg.isreg==false)});
			--end
			
			-- NOTE by andy 2009/8/18: leave for the CreateNewAvatar process to test if the creation process is completed
			MainLogin:next_step({IsAuthenticated = true, IsAvatarCreationRequested = true});
			UserLoginProcess.AuthFailCounter = nil;
		else
			UserLoginProcess.AuthFailCounter = UserLoginProcess.AuthFailCounter or 0;
			UserLoginProcess.AuthFailCounter = UserLoginProcess.AuthFailCounter + 1;
			if(UserLoginProcess.AuthFailCounter >= 5) then
				-- shut down app if user input wrong password 5 times in a row
				ParaGlobal.ExitApp();
			end
			if(msg.errorcode == 412) then
				_guihelper.MessageBox(string.format("%s\n\n%s", tostring(msg.info), 
					"账号未激活, 我们需要您通过Email等方式确认您的身份后才能登录\n是否希望重新发送确认信到你注册时提供的邮箱?"), function()
					paraworld.auth.SendConfirmEmail({username = values.username, password = values.password,}, "Login", function(msg)
						if(msg ~= nil) then
							if(msg.issuccess) then
								UserLoginProcess.ShowProgress("发送成功, 请查看你的邮箱");
							else
								-- 497：数据不存在或已被删除 414：账号已是激活状态不必再次激活 
								if(msg.errorcode==497) then
									UserLoginProcess.ShowProgress("数据不存在或已被删除");
								elseif(msg.errorcode==414) then
									UserLoginProcess.ShowProgress("账号已是激活状态不必再次激活");
								else
									UserLoginProcess.ShowProgress("未知服务器错误, 请稍候再试");
								end
							end	
						end
					end)
				end);
			else
				LOG.std("", "error","Login", {"Auth failed because", msg});
				local error_msg;
				if(msg.errorcode == 407) then
					error_msg = "用户名或密码错误";
				elseif(msg.errorcode == 413) then
					error_msg = "你的账号已违反游戏秩序,已给予冻结处理（10分钟或更久），如有疑问请联系客服。";
				elseif(msg.errorcode == 412) then
					error_msg = "很抱歉, 我们的客服正在维护您的账号！一般会在1小时内完成. 如有疑问请联系客服.";
				elseif(msg.errorcode == 419) then
					error_msg = MyCompany.Aries.ExternalUserModule:GetConfig().account_name .. "不存在。"
				elseif(msg.errorcode == 500) then	
					error_msg = string.format("夜深了，%s已经关闭了，大家也早点休息吧！",MyCompany.Aries.ExternalUserModule:GetConfig().product_name or "魔法哈奇");
				elseif(msg.errorcode == 426) then
					error_msg = "密码连续输入错误的次数太多，请15秒后再试"
				elseif(msg.errorcode == 444) then
					error_msg = "验证码输入错误"
				elseif(msg.errorcode == 446) then
					error_msg = "登录失败并且错误次数过多，请输入验证码后再登录";
				elseif(msg.errorcode == 447) then
					error_msg = "同一米米号或同一ip密码错误尝试次数过多，请输入验证码后再登陆";
				elseif(msg.errorcode == 496) then
					error_msg = "用户凭证无效或已过期, 请退出游戏重新登录";
				else	
					error_msg = "服务器繁忙，请稍后重试"
				end

				-- 验证码逻辑
				local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
				if (ExternalUserModule:GetRegionID()==0) then
					if(msg.errorcode ~= 426 and msg.valibmp) then
						UserLoginProcess.SavImg(msg.errorcode,msg.valibmp,msg.sessionid);
						return;
					end
				end

				UserLoginProcess.Fail(error_msg or msg.info);
				-- send log information
				paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_Authentication_errorcode:"..msg.errorcode}, 
					"user_login_process_stage_fail_log", function(msg)
				end);
			end
		end
	end, nil, 20000, function(msg)
		-- timeout request
		LOG.std("", "error","Login", "Proc_Authentication timed out");
		UserLoginProcess.Fail("用户验证超时了, 可能服务器太忙了, 或者您的网络质量不好.");
		-- send log information
		paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_Authentication_timed_out"}, 
			"user_login_process_stage_fail_log", function(msg)
		end);
	end)
end

function UserLoginProcess.SavImg(errcode,valibmp,sessionid,calltype)
	-- 验证码逻辑
	local base64_data = valibmp;
	System.User.sessionid = sessionid;
	local bin_data = commonlib.Encoding.unbase64(base64_data);
	local _url;
	if (calltype) then
		_url = string.format("script/apps/Aries/Login/EnterVerificationCodePage.html?callback=%s&errorcode=%d",calltype,errcode); 
	else
		_url = string.format("script/apps/Aries/Login/EnterVerificationCodePage.html?errorcode=%d",errcode); 
	end
	if(bin_data) then
		ParaIO.CreateDirectory("temp/");
		local file = ParaIO.open("temp/last_validation_image.png", "w");
		file:write(bin_data, #bin_data);
		file:close();
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = _url, 
			name = "Aries.EnterVerificationCodePage", 
			isShowTitleBar = false,
			allowDrag = true,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 3000,
			directPosition = true,
				align = "_ct",
				x = -360/2,
				y = -200/2,
				width = 360,
				height = 200,
		});
	end	
end

-- verify nickname and avatar CCS info
-- if no nickname and avatar CCS infomation is filled, remind the user to choose a permernent nickname and avatar
function UserLoginProcess.Proc_VerifyNickName()
	UserLoginProcess.ShowProgress("正在获取人物信息");
	
	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_VerifyNickName"}, "user_login_process_stage_progress_log", function(msg)	end);
	
	System.App.profiles.ProfileManager.GetUserInfo(System.User.nid, "Proc_VerifyNickName", function(msg)
		if(msg == nil or not msg.users or not msg.users[1]) then
			LOG.std("", "error","Login", msg);
			UserLoginProcess.Fail("获取人物信息失败，请稍候再试");
			-- send log information
			paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyNickName_invalid_userinfo"}, 
				"user_login_process_stage_fail_log", function(msg)
			end);
			return;
		end
		
		-- sync the homeland tutorial items for users register before 2009/11/20
		if(false) then
			local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory(System.User.nid);
			if(userinfo and userinfo.birthday) then
				local month, day, year, hour, minute, second = string.match(userinfo.birthday, "(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)");
				if(month and day and year and hour and minute and second) then
					year = tonumber(year);
					month = tonumber(month);
					day = tonumber(day);
					hour = tonumber(hour);
					minute = tonumber(minute); 
					second = tonumber(second);
					
					if(year < 2009 or month < 11 or day < 20) then
						log("==========purchase item for all users before 2009/11/20==========\n")
						-- 50116_NewbieQuest_Homeland_CompletePlant
						System.Item.ItemManager.PurchaseItem(50116, 1, function(msg) end, function(msg) 
							log("+++++++Purchase item #50116_NewbieQuest_Homeland_CompletePlant return: +++++++\n")
							commonlib.echo(msg);
						end, nil, "none", false);
						-- 50117_NewbieQuest_Homeland_CompleteDeco
						System.Item.ItemManager.PurchaseItem(50117, 1, function(msg) end, function(msg) 
							log("+++++++Purchase item #50117_NewbieQuest_Homeland_CompleteDeco return: +++++++\n")
							commonlib.echo(msg);
						end, nil, "none", false);
						-- 50118_NewbieQuest_Homeland_CompleteAll
						System.Item.ItemManager.PurchaseItem(50118, 1, function(msg) end, function(msg) 
							log("+++++++Purchase item #50118_NewbieQuest_Homeland_CompleteAll return: +++++++\n")
							commonlib.echo(msg);
						end, nil, "none", false);
					end
				end
			end
		end
		
		local nickname = msg.users[1].nickname;
		if(nickname == nil or nickname == "") then
			System.User.NickName = "匿名";
			MainLogin:next_step({IsNickNameVerified = true});
		else
			System.User.NickName = nickname;
			MainLogin:next_step({IsNickNameVerified = true});
		end
	end, "access plus 0 day", 5000, function(msg)
		-- timeout request
		UserLoginProcess.Fail("获取人物信息失败，请稍候再试");
		-- send log information
		paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyNickName_timed_out"}, 
			"user_login_process_stage_fail_log", function(msg)
		end);
	end)
end

-- Download family info and proceed to Proc_VerifyServerObjects()
function UserLoginProcess.Proc_VerifyFamilyInfo()
	UserLoginProcess.ShowProgress("正在获取家族信息");
	
	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_VerifyFamilyInfo"}, "user_login_process_stage_progress_log", function(msg)
	end);
	
	NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
	MyCompany.Aries.Friends.GetMyFamilyInfo(function(msg)
		if(msg.issuccess == true) then
			-- continue with the next stage
			MainLogin:next_step({IsFamilyInfoVerified = true});
			
		elseif(msg.issuccess == false) then
		    log("warning: error fetching family info\n");
		    commonlib.echo(msg);
			UserLoginProcess.Fail("获取家族信息失败，请稍候再试");
			-- send log information
			paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyFamilyInfo_fail"}, 
				"user_login_process_stage_fail_log", function(msg)
			end);
		end
	end, "access plus 0 day", 25000, function(msg)
		-- timeout request
		UserLoginProcess.Fail("获取家族信息失败，请稍候再试");
		-- send log information
		paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyFamilyInfo_timedout"}, 
			"user_login_process_stage_fail_log", function(msg)
		end);
	end);
	
	---- skip the MCML profile
	--System.App.profiles.ProfileManager.DownloadFullProfile(nil, function (uid, appkey, bSucceed)
		--if(bSucceed) then
			--MainLogin:next_step({IsFamilyInfoVerified = true});
		--else
			--UserLoginProcess.Fail("获取个人信息失败，请稍候再试");
			--return;
			---- UserLoginProcess.ShowProgress("无法从服务器获取用户信息, 可能服务器正忙, 请稍候再试.");
			---- NOTE: for offline mode, proceed anyway. Find a better way, since this could be Online mode error as well.
		--end
	--end, "access plus 0 day", 20000, function(msg)
		---- timeout request
		--UserLoginProcess.Fail("获取个人信息失败，请稍候再试");
	--end) -- added a cache policy that will always get the full profile in download full profile stage
end

-- Sync server objects and proceed to Proc_SyncGlobalStore()
function UserLoginProcess.Proc_VerifyServerObjects()
	UserLoginProcess.ShowProgress("正在同步世界变量");
	
	NPL.load("(gl)script/apps/Aries/Login/DailyCheckin.lua");
	local DailyCheckin = commonlib.gettable("MyCompany.Aries.DailyCheckin");
	DailyCheckin.OnUserLogin();

	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_VerifyServerObjects"}, "user_login_process_stage_progress_log", function(msg)
	end);
	
	NPL.load("(gl)script/apps/Aries/Scene/main.lua");
	MyCompany.Aries.Scene.GetAllServerObjects(function(msg)
		if(msg.issuccess == true) then
			-- continue with the next stage
			MainLogin:next_step({IsServerObjectsVerified = true});
			
		elseif(msg.issuccess == false) then
			LOG.std("", "error","Login", "error fetching server objects|"..LOG.tostring(msg));
			UserLoginProcess.Fail("同步世界变量失败，请稍候再试");
			-- send log information
			paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyServerObjects_fail"}, 
				"user_login_process_stage_fail_log", function(msg)
			end);
		end
	end, "access plus 0 day", 20000, function(msg)
		-- timeout request
		UserLoginProcess.Fail("同步世界变量失败，请稍候再试");
		-- send log information
		paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyServerObjects_timedout"}, 
			"user_login_process_stage_fail_log", function(msg)
		end);
	end);

	-- check items in shop
	if(not UserLoginProcess.checkitemsinshop_checked_) then
		UserLoginProcess.checkitemsinshop_checked_ = true;
		paraworld.auction.CheckItemsInShop(params,nil,function(msg)
			if(msg and msg.issuccess) then
				LOG.std("", "system", "auction", "CheckItemsInShop succeeded. expired items will be sent via mail system.");
			else
				LOG.std("", "error", "auction", "CheckItemsInShop failed");
			end
		 end);
	end
end

-- Sync all bag items with user inventory and proceed to Proc_VerifyInventory
function UserLoginProcess.Proc_SyncGlobalStore()
	UserLoginProcess.ShowProgress("正在同步物品描述");
	
	NPL.load("(gl)script/apps/Aries/Items/item.addonlevel.lua");
	local addonlevel = commonlib.gettable("MyCompany.Aries.Items.addonlevel");
	addonlevel.init();

	NPL.load("(gl)script/apps/Aries/Items/item_event.lua");
	local item_event = commonlib.gettable("MyCompany.Aries.Items.item_event");
	item_event.init();

	if(System.options.isAB_SDK) then
		GameServer.rest.client:EnableRateController(false);
	end

	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_SyncGlobalStore"}, "user_login_process_stage_progress_log", function(msg)
	end);
	
	-- read gsid region from config file
	local filename = "config/Aries/GlobalStore.IDRegions.xml";

	if(System.options.version == "teen") then
		filename = "config/Aries/GlobalStore.IDRegions.teen.xml";
	end

	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		LOG.std("", "error", "Login", "error: failed loading GlobalStore.IDRegions config file: %s, using default", filename);
		-- use default config file xml root
		xmlRoot = 
		{
		  {
			{
			  attr={ from=999, to=999 },
			  n=1,
			  name="region" 
			},
			n=1,
			name="gsidregions" 
		  },
		  n=1 
		};
	end
	
	local gsidRegions = {};
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/gsidregions/region") do
		if(node.attr and node.attr.from and node.attr.to and (not node.attr.version or node.attr.version==System.options.version)) then
			table.insert(gsidRegions, {tonumber(node.attr.from), tonumber(node.attr.to)});
		end
	end
	
	-- TODO: global store regions are read from the GetServerList file
	-- TODO: we can also specify some of the regions are newly modified, with a cache policy 
	
	-- direct gsid regions are deprecated and switch to xml config
	--local gsidRegions = {
		--{998, 999}, -- user avatar base ccs info
		--{1001, 1215}, -- avatar apparels and hand-held
		--{9001, 9010}, -- character animation
		--{9501, 9504}, -- throwable
		--{10001, 10001}, -- mount pet dragon
		--{10101, 10131}, -- follow pet
		--{11001, 11012}, -- mount pet apparel and base color
		--{15001, 15002}, -- pet animation
		--{16001, 16050}, -- consumable
		--{17001, 17095}, -- collectable
		--{19001, 19003}, -- reading
		--{20001, 20020}, -- medals
		--{21001, 21006}, -- quest related, acinus
		--{21101, 21104}, -- skill levels
		--{30001, 30134}, -- home land items
		--{39101, 39103}, -- homeland template
		--{50001, 50006}, -- quest tags
		--{50010, 50302}, -- quest tags
	--};
	
	-- #array of gsid query, 10 in a group. 
	local gsidLists = {};
	local gsid_max_group_count = 10;
	
	local accum = 0;
	local gsids = "";
	for _, pair in ipairs(gsidRegions) do
		local i;
		for i = pair[1], pair[2] do
			accum = accum + 1;
			gsids = gsids..i..",";
			if(accum == gsid_max_group_count) then
				gsidLists[#gsidLists+1] = gsids;
				accum = 0;
				gsids = "";
			end
		end
	end
	if(gsids ~= "") then
		gsidLists[#gsidLists+1] = gsids;
	end
	local replied_count = 0;

	NPL.load("(gl)script/ide/timer.lua");

	

	local function FetchGS(gsids)
		System.Item.ItemManager.GetGlobalStoreItem(gsids, "Proc_SyncGlobalStore_", function(msg)
			-- TODO: we don't care if the globalstore item templates are really replied, response is success
			--		for more unknown item templates please refer to Item_Unknown for late item visualization or manipulation
			-- NOTE: global store item can be directly accessed from memory by ItemManager.GetGlobalStoreItemInMemory(gsid);
			replied_count = replied_count + 1;
			if(replied_count == #gsidLists) then
				paraworld.globalstore.SaveToFile();
				NPL.load("(gl)script/apps/Aries/Items/item.property.lua");
				local addonproperty = commonlib.gettable("MyCompany.Aries.Items.addonproperty");
				addonproperty.init();

				-- init the card key and gsid mapping
				NPL.load("(gl)script/apps/Aries/Combat/main.lua");
				MyCompany.Aries.Combat.Init_OnGlobalStoreLoaded();

				if(System.options.version == "teen") then
					System.Item.ItemManager.RedirectAllGlobalStoreIconPath();
				end

				if(System.options.isAB_SDK) then
					GameServer.rest.client:EnableRateController(true);
				end

				System.Item.ItemManager.GetAllGSObtainCntInTimeSpan(function(bSucceed)
					if(bSucceed) then
						MainLogin:next_step({IsGlobalStoreSynced = true});
					else
						UserLoginProcess.Fail("同步物品获得记数失败了，请稍候再试");
						-- send log information
						paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_SyncGlobalStore_gsobtainintimespan_fail"}, 
							"user_login_process_stage_fail_log", function(msg)
						end);
					end
				end, "access plus 0 day", 25000, function(msg)
					-- timeout request
					UserLoginProcess.Fail("同步物品获得记数失败了，请稍候再试");
					-- send log information
					paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_SyncGlobalStore_gsobtainintimespan_timedout"}, 
						"user_login_process_stage_fail_log", function(msg)
					end);
				end);
			end
		end, "access plus 1 year", 25000, function(msg)
			-- timeout request
			UserLoginProcess.Fail("同步物品描述失败了，请稍候再试");
		end)
	end

	local nIndex = 1;
	local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
		if(nIndex <= #gsidLists) then
			local fromTime = ParaGlobal.timeGetTime();
			while (true) do
				FetchGS(gsidLists[nIndex]);
				nIndex = nIndex + 1;
				if(nIndex > #gsidLists or (ParaGlobal.timeGetTime() - fromTime)>1000) then
					break;
				end;
			end
			UserLoginProcess.ShowProgress(string.format("正在同步物品描述: %d/%d", nIndex, #gsidLists), nil, 1);
		else
			timer:Change();
		end
	end})
	mytimer:Change(0, 1);
end

function UserLoginProcess.Proc_SyncExtendedCost()
	UserLoginProcess.ShowProgress("正在同步物品兑换描述");
	
	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_SyncExtendedCost"}, "user_login_process_stage_progress_log", function(msg)
	end);
	
	-- uncomment to skip this step
	-- MainLogin:next_step({IsExtendedCostSynced = true});
	-- do return end
	
	if(System.options.isAB_SDK) then
		GameServer.rest.client:EnableRateController(false);
	end

	-- read extended cost id region from config file
	local filename = "config/Aries/ExtendedCost.IDRegions.xml";
	
	if(System.options.version == "teen") then
		filename = "config/Aries/ExtendedCost.IDRegions.teen.xml";
	end

	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		commonlib.log("error: failed loading ExtendedCost.IDRegions config file: %s, using default\n", filename);
		-- use default config file xml root
		xmlRoot = 
		{
		  {
			{
			  attr={ from=1, to=1 },
			  n=1,
			  name="region" 
			},
			n=1,
			name="exidregions" 
		  },
		  n=1 
		};
	end
	
	local exidRegions = {};
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/exidregions/region") do
		if(node.attr and node.attr.from and node.attr.to  and (not node.attr.version or node.attr.version==System.options.version)) then
			table.insert(exidRegions, {tonumber(node.attr.from), tonumber(node.attr.to)});
		end
	end
	
	-- direct extendedcost regions are deprecated and switch to xml config
	--local exidRegions = {
		--{1, 403}, 
	--};
	
	local exidLists = {};
	
	local accum = 0;
	local _, pair;
	for _, pair in ipairs(exidRegions) do
		local i;
		for i = pair[1], pair[2] do
			exidLists[i] = false;
		end
	end
	
	local i = 0;
	local exid, hasReplied;
	for exid, hasReplied in pairs(exidLists) do
		i = i + 1;
		System.Item.ItemManager.GetExtendedCostTemplate(exid, "Proc_SyncExtendedCostTemplate", function(msg)
			-- TODO: we don't care if the ExtendedCost templates are really replied, response is success
			-- NOTE: global store item can be directly accessed from memory by ItemManager.GetExtendedCostTemplateInMemory(gsid);
			exidLists[exid] = true;
			local allReplied = true;
			local _, bReply;
			for _, bReply in pairs(exidLists) do
				if(bReply == false) then
					allReplied = false;
					break;
				end
			end
			if(allReplied == true) then
				paraworld.extendedcost.SaveToFile();
				if(System.options.isAB_SDK) then
					GameServer.rest.client:EnableRateController(true);
				end
				MainLogin:next_step({IsExtendedCostSynced = true});
			end
		end, "access plus 1 year", 20000, function(msg)
			-- timeout request
			UserLoginProcess.Fail("正在同步物品兑换描述，请稍候再试");
		end)
	end
end

-- Sync all bag items with user inventory and proceed to Proc_VerifyPet
function UserLoginProcess.Proc_VerifyInventory()
	UserLoginProcess.ShowProgress("正在获取物品信息");
	
	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_VerifyInventory"}, "user_login_process_stage_progress_log", function(msg)
	end);
	
	local Start_Percent = UserLoginProcess.percentage;
	
	System.Item.ItemManager.GetItemsInAllBags(nil, function(bSucceed)
		if(bSucceed) then
			-- after downloading current user inventory, verify user avatar
			MainLogin:next_step({IsInventoryVerified = true});
		else
			-- UserLoginProcess.ShowProgress("无法从服务器获取物品信息, 可能服务器正忙, 请稍候再试.");
			-- NOTE: for offline mode, proceed anyway. Find a better way, since this could be Online mode error as well.
			--log("GetItemsInAllBags: failed. Proceed to offline mode anyway. \n")
			--MainLogin:next_step({IsInventoryVerified = true});
			UserLoginProcess.Fail("获取物品信息失败，请稍候再试");
			-- send log information
			paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyInventory_fail"}, 
				"user_login_process_stage_fail_log", function(msg)
			end);
			return;
		end
	end, "access plus 0 day", 30000, function(msg)
		-- timeout request
		UserLoginProcess.Fail("获取物品信息失败，请稍候再试");
		-- send log information
		paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyInventory_timedout"}, 
			"user_login_process_stage_fail_log", function(msg)
		end);
	end, function(msg)
		if(msg.finished_count and msg.total_count) then
			UserLoginProcess.ShowProgress(string.format("正在获取物品信息: %d/%d", msg.finished_count, msg.total_count), Start_Percent + math.floor(10*msg.finished_count / msg.total_count));
		end
	end); -- added a cache policy that will always get the inventory data
end

function UserLoginProcess.Proc_VerifyEssentialItems()
	UserLoginProcess.ShowProgress("正在同步基础物品");
	
	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_VerifyEssentialItems"}, "user_login_process_stage_progress_log", function(msg)
	end);
	
	System.Item.ItemManager.VerifyEssentialItems(function(bSucceed)
		if(bSucceed) then
			---- uncomment the following line to return to original code
			---- after downloading current user inventory, verify user avatar
			--MainLogin:next_step({IsEssentialItemsVerified = true});

			if(System.options.version == "teen") then
				-- NOTE: 2013/9/10: 关闭青年版新手礼包
				---- comment the following line to return to original code
				--if(not System.Item.ItemManager.IfOwnGSItem(50325)) then
					---- 631 Init_GoldenGiftPack 
					--Map3DSystem.Item.ItemManager.ExtendedCost(631, nil, nil, function(msg)
						--LOG.std("", "system","Item", "+++++++ Init_GoldenGiftPack return: +++++++"..LOG.tostring(msg));
						--if(msg.issuccess == true) then
							---- after downloading current user inventory, verify user avatar
							--MainLogin:next_step({IsEssentialItemsVerified = true});
						--else
							--UserLoginProcess.Fail("同步基础物品失败，请稍候再试");
							---- send log information
							--paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyEssentialItems_fail"}, 
								--"user_login_process_stage_fail_log", function(msg)
							--end);
						--end
					--end, function(msg) end);
				--else
					-- after downloading current user inventory, verify user avatar
					MainLogin:next_step({IsEssentialItemsVerified = true});
				--end
			else
				-- escape exid 631 Init_GoldenGiftPack for kids version
				MainLogin:next_step({IsEssentialItemsVerified = true});
			end

		else
			-- send log information
			paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyEssentialItems_fail"}, 
				"user_login_process_stage_fail_log", function(msg)
			end);
			-- UserLoginProcess.Fail("同步基础物品失败，请稍候再试");
			_guihelper.MessageBox("同步基础物品失败，请联系客服")
			-- we will continue anyway
			MainLogin:next_step({IsEssentialItemsVerified = true});
		end
	end, 20000, function(msg)
		-- timeout request
		UserLoginProcess.Fail("同步基础物品失败，请稍候再试");
		-- send log information
		paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyEssentialItems_timedout"}, 
			"user_login_process_stage_fail_log", function(msg)
		end);
	end);
end

function UserLoginProcess.Proc_VerifyPet()
	UserLoginProcess.ShowProgress("正在获取宠物信息");
	
	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_VerifyPet"}, "user_login_process_stage_progress_log", function(msg)
	end);
	
	-- tricky: we will init item guides here to accelerate loading in-game.
	NPL.load("(gl)script/apps/Aries/HaqiShop/ItemGuides.lua");
	local ItemGuides = commonlib.gettable("MyCompany.Aries.ItemGuides");
	ItemGuides.Init();

	local item = System.Item.ItemManager.GetMyMountPetItem();
	if(item and item.guid > 0) then
		-- load homeland config
		NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
		Map3DSystem.App.HomeLand.HomeLandConfig.Load();
		-- init the dragon data
		NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandProvider.lua");
		System.App.HomeLand.HomeLandProvider.PetInit(System.User.nid, function(msg)
			if(msg and not msg.errorcode) then
				-- verify combat items, don't need a confirm
				Map3DSystem.Item.ItemManager.VerifyCombatItems();
				-- next step
				MainLogin:next_step({IsPetVerified = true});
			else
				UserLoginProcess.Fail("获取宠物信息失败，请稍候再试");
				-- send log information
				paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyPet_timedout"}, 
					"user_login_process_stage_fail_log", function(msg)
				end);
				return;
			end
		end);
	else
		-- load homeland config
		NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
		Map3DSystem.App.HomeLand.HomeLandConfig.Load();
		-- dragon is not fetched from sophie yet
		MainLogin:next_step({IsPetVerified = true});
	end
	
	--local ItemManager = System.Item.ItemManager;
	--local bOwn, guid = ItemManager.IfOwnGSItem(10001);
	--if(bOwn == true and guid > 0) then
		--local item = ItemManager.GetItemByGUID(guid);
		--if(item and item.guid > 0) then
			--log("Leio: init the pet here, the pet is already fetched in stage 6\nMount Pet item:")
			--commonlib.echo({item.guid, item.gsid})
			--commonlib.echo("call init of the pet item here to fetch the data, when received call UserLoginProcess.Proc_VerifyFriends()\n");
			--MainLogin:next_step({IsPetVerified = true});
		--else
			--MainLogin:next_step({IsPetVerified = true});
		--end
	--else
		---- directly enter world
		---- TODO: if nude avatar the user is first login to the community, launch the tutorial
		--MainLogin:next_step({IsPetVerified = true});
	--end
end

function UserLoginProcess.Proc_VerifyVIPItems()
	UserLoginProcess.ShowProgress("正在检查付费物品");
	
	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_VerifyVIPItems"}, "user_login_process_stage_progress_log", function(msg)
	end);
	
	System.Item.ItemManager.VerifyVIPItems(function(bSucceed)
		if(bSucceed) then
			-- after downloading current user inventory, verify user avatar
			MainLogin:next_step({IsVIPItemsVerified = true});
		else
			UserLoginProcess.Fail("检查付费物品失败，请稍候再试");
			-- send log information
			paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyVIPItems_fail"}, 
				"user_login_process_stage_fail_log", function(msg)
			end);
			return;
		end
	end, 20000, function(msg)
		-- timeout request
		UserLoginProcess.Fail("检查付费物品失败，请稍候再试");
		-- send log information
		paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyVIPItems_timedout"}, 
			"user_login_process_stage_fail_log", function(msg)
		end);
	end);
end

function UserLoginProcess.Proc_VerifyFriends()
	UserLoginProcess.ShowProgress("正在获取好友信息");
	
	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_VerifyFriends"}, "user_login_process_stage_progress_log", function(msg)
	end);
	
	NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
	MyCompany.Aries.Friends.GetMyFriends(function(msg)
		if(msg.issuccess == true) then
			-- continue with the next stage
			MainLogin:next_step({IsFriendsVerified = true});
			
			-- login to jabber. jabber must be created after friends have been fetched. 
			-- comment this to test
			System.App.Chat.OneTimeInit();
			
		elseif(msg.issuccess == false) then
			LOG.std("", "error","Login", "warning: error fetching friends"..LOG.tostring(msg));
		    
			UserLoginProcess.Fail("获取好友信息失败，请稍候再试");
			-- send log information
			paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyFriends_fail"}, 
				"user_login_process_stage_fail_log", function(msg)
			end);
		end
	end, "access plus 0 day", 25000, function(msg)
		-- timeout request
		UserLoginProcess.Fail("获取好友信息失败，请稍候再试");
		-- send log information
		paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyFriends_timedout"}, 
			"user_login_process_stage_fail_log", function(msg)
		end);
	end);
end


-- login procedure completed. 
function UserLoginProcess.Proc_InitJabber()
	UserLoginProcess.ShowProgress("登录即时通讯系统");
	
	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_InitJabber"}, "user_login_process_stage_progress_log", function(msg)
	end);
	
	-- wait 10 seconds. if still no connection,we will connect without jabber
	UserLoginProcess.MaxWaitTime = 10000;
	UserLoginProcess.TimeElapsed = 0;
	UserLoginProcess.JabberConnected = false;
	
	-- use a timer to check if jabber is connected or not. 
	UserLoginProcess.jabber_timer = UserLoginProcess.jabber_timer or commonlib.Timer:new({
		callbackFunc = function(timer)
			local bNext; 
			if(System.App.Chat.GetConnectedClient()) then
				if(UserLoginProcess.JabberConnected) then
					bNext = true;
				else
					UserLoginProcess.JabberConnected = true;
					-- TRICKY: wait at least 500 before going to next step, this allows some presence messages to arrive. 
					UserLoginProcess.jabber_timer:Change(500, nil);
					return;
				end	
			end
			if(not bNext) then
				UserLoginProcess.TimeElapsed = UserLoginProcess.TimeElapsed + 500;
				if(UserLoginProcess.TimeElapsed < UserLoginProcess.MaxWaitTime) then
					UserLoginProcess.jabber_timer:Change(500, nil);
				else
					LOG.std("", "warning","Login", "warning: jabber client is not connected ater 20 seconds, we will sign in without IM. Some game functions may not be available.");
					bNext = true;
					-- send log information
					paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_InitJabber_timedout_continue_signin"}, 
						"user_login_process_stage_fail_log", function(msg)
					end);
				end	
			end
			if(bNext) then
				UserLoginProcess.ShowProgress();
				MainLogin:next_step({IsJabberInited = true});
			end	
		end});
	
	-- init Aries specific features
	NPL.load("(gl)script/apps/Aries/Chat/Main.lua");
	MyCompany.Aries.Chat.Init();
	
	UserLoginProcess.TrySaveUserInfo();	

	-- change timer
	UserLoginProcess.jabber_timer:Change(10, nil);
end

-- only save when user try to remember it. 
function UserLoginProcess.TrySaveUserInfo()
	local region_id = ExternalUserModule:GetRegionID();
	if(System.User.IsAuthenticated) then
		-- since we have successfully logged in, let us save user info to local disk
		local userInfo = {user_nid = tostring(System.User.nid), user_name = System.User.NickName, password=nil, region_id = region_id,
			asset_table={
				-- TODO: for andy: just replace this with the real CCS string. 
				CCSInfoStr=System.UI.CCS.GetCCSInfoString(nil, true),
			}};
		if(UserLoginProcess.rememberpassword) then
			userInfo.password = System.User.Password;
		end
		if (region_id~=0) then
            if(region_id ~= 7)then
			    userInfo.user_nid = System.User.username;
            end
		end

		-- user from other platform. 
		userInfo.plat = System.User.plat;
		userInfo.oid = System.User.oid;

		--local index, user
		if(not userInfo.school) then
			for index, user in ipairs(MyCompany.Aries.LocalUserSelectPage.dsUsers) do 
				if(user.user_nid==userInfo.user_nid) then
					userInfo.school = userInfo.school or user.school;
				end
			end
		end

		MyCompany.Aries.LocalUserSelectPage:SaveUserInfo(userInfo, not UserLoginProcess.rememberusername);
	end	
end

function UserLoginProcess.Proc_OneTimeInitAfterLogin()
	if(System.options.version=="kids") then
		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardDeckSubPage.lua");
	else
		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardManager.teen.lua");
	end
	System.User.oldLvl = MyCompany.Aries.Combat.GetMyCombatLevel();

	local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
	MyCardsManager.InitCombatBag_RemoteLoad();
	commonlib.echo("====Init combat bag from 995 to bag0 pos 24====");

	local ItemManager = System.Item.ItemManager;
	local usernid= System.User.nid; -- 用户nid
	--local classprop=ItemManager.GetItemByBagAndPosition(0, 23); -- 玩家系别 classprop.gsid
	local classprop_gsid = MyCompany.Aries.Combat.GetSchoolGSID();

	NPL.load("(gl)script/apps/Aries/GoldRankingList/ranking_server.lua");
	local RankingServer = commonlib.gettable("MyCompany.Aries.GoldRankingList.RankingServer");
	RankingServer.Init();

	NPL.load("(gl)script/apps/Aries/Scene/main.lua");
	local Scene = commonlib.gettable("MyCompany.Aries.Scene");
	local serverDate = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local year,month,day = string.match(serverDate,"(.+)-(.+)-(.+)");
	year = tonumber(year);
	month = tonumber(month);
	day = tonumber(day);

	local GoldRankingListMain;
	if (System.options.version=="kids") then
		NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingListMain.lua");
		GoldRankingListMain = MyCompany.Aries.GoldRankingList.GoldRankingListMain;
		-- 当前本系排行榜名次 rank_order >100 不在排行榜上
		System.User.rank_order=101;
		System.User.rank_order_class=101;
		System.User.pve_rank_order=101;

		System.User.rank_order_old=101;
		System.User.rank_order_class_old=101;
		System.User.pve_rank_order_old=101;

		--GoldRankingListMain.GetRankPos(usernid,classprop_gsid,"pk_all",function (rankorder)
			--System.User.rank_order = rankorder;
			--end);
		GoldRankingListMain.GetRankPos(usernid,classprop_gsid,"pk_class",function (rankorder)
			System.User.rank_order_class = rankorder;
			-- use the class order
			System.User.rank_order = rankorder;
			end);

		GoldRankingListMain.GetRankPos(usernid,classprop_gsid,"boss",function (rankorder)
			System.User.pve_rank_order = rankorder;
			end);

		NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingPKListMain_history.lua");
		local GoldRankingPKListMain = commonlib.gettable("MyCompany.Aries.GoldRankingList.GoldRankingPKListMain");

		month = month-1;
		if (month==0) then
			year=year-1;
			month=12;
		end
		local rdate=year*100+month;

		--GoldRankingPKListMain.GetRankPos(usernid,classprop_gsid,"pk_all",rdate,function (rankorder)
			--System.User.rank_order_old = rankorder;
			--end);
		--GoldRankingPKListMain.GetRankPos(usernid,classprop_gsid,"pk_class",rdate,function (rankorder)
			--System.User.rank_order_class_old = rankorder;
			--end);
		--GoldRankingPKListMain.GetRankPos(usernid,classprop_gsid,"boss",rdate,function (rankorder)
			--System.User.pve_rank_order_old = rankorder;
			--end);

	else  
		--- 青年版
		NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingListMain.teen.lua");
		GoldRankingListMain = MyCompany.Aries.GoldRankingList.GoldRankingListMain;
		-- 当前本系排行榜名次 rank_order <0 不在排行榜上
		System.User.rank_order = -1;
		System.User.pve_rank_order = -1;
		GoldRankingListMain.GetRankPos(usernid,classprop_gsid,"pk",function (rankorder)
			LOG.std(nil, "debug", "ranking", "my pk rank position is %d", rankorder)
			System.User.rank_order = rankorder;
		end);

		--GoldRankingListMain.GetRankPos(usernid,classprop_gsid,"boss",function (rankorder)
			--System.User.pve_rank_order = rankorder;
			--end);
	end

	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
	if(System.options.locale ~= "zhCN") then
		-- only Chinese version will do have it. 
		System.User.IsRealname = true;
		System.User.IsAdult = 1;
	else
		if (ExternalUserModule:GetRegionID()==0 ) then
			paraworld.auth.GetUserInfo({nid=usernid}, "Auth_GetUserInfo", function(msg) 
					log("====== Auth_GetUserInfo: ======\n")
					--commonlib.echo(msg);
					if(msg) then
						if (msg.realname=="000000000000000000000000000000") then
							System.User.IsRealname = false;
							System.User.IsAdult = 0;
						else
							if (System.options.version=="kids") then
								System.User.IsRealname=true;
								System.User.IsAdult = 1;
							else
								local birthday = msg.birthday;
								local b_year, b_month, b_day = string.match(birthday,"(%d%d%d%d)(%d%d)(%d%d)");
								local age_year = ((year - b_year)*12 + (month - b_month))/12;
								if (age_year < 18) then
									System.User.IsRealname=false;
									System.User.IsAdult = 2;
								else
									System.User.IsRealname=true;
									System.User.IsAdult = 1;
								end
							end
						end
					end

			end);
		elseif (ExternalUserModule:GetRegionID()==2) then
			local msg = {
				username = System.User.username,
				password = System.User.Password,
				from =2,
			}
			paraworld.auth.GetUserInfo(msg, "getuserinfo", function(msg) 
					log("====== Auth_GetUserInfo: ======\n")
					--commonlib.echo(msg);
					if(msg) then
						if (msg.realname=="") then
							System.User.IsRealname=false;
						else
							System.User.IsRealname=true;
						end
						-- TODO: for kuaiwan user always disable this. 
						System.User.IsRealname=true;
						System.User.IsAdult = 1;
					end
			end);
		else
			System.User.IsRealname = true;
			System.User.IsAdult = 1;
		end
	end
	if (System.options.version=="kids") then
		-- 儿童版自动给本家族签到，GetRemoteRank 通过 http 下载家族排名
		NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupManage.lua");
		local HaqiGroupManage = MyCompany.Aries.Quest.NPCs.HaqiGroupManage;

		local bean = MyCompany.Aries.Pet.GetBean();
		if(bean)then
			local fmname = bean.family;
			if (fmname) then
				HaqiGroupManage.GetRemoteRank(fmname);
				--if (bean.combatlel >=30) then
					local Friends = commonlib.gettable("MyCompany.Aries.Friends");
					local MyFamilyInfo = Friends.MyFamilyInfo;
					if(MyFamilyInfo) then
						local contribute = 0;
						local i;
						for i = 1, #(MyFamilyInfo.members) do
							local member = MyFamilyInfo.members[i];
							if(member.nid == usernid) then
								contribute = member.contribute;
								break;
							end
						end

						if (contribute >= 15) then
							HaqiGroupManage.DoSignIn(true);
						end;
					end
				
				--end
			end
		end
	end
end

-- login procedure completed. 
function UserLoginProcess.Proc_CleanCache()
	if(System.options.IsMobilePlatform) then
		UserLoginProcess.Proc_OneTimeInitAfterLogin();
		MainLogin:next_step({IsCleanCached = true});
		return true;
	end
	UserLoginProcess.ShowProgress("清理并优化数据,请耐心等待...");
	
	LOG.std("", "system","Login", "begin to  Proc_CleanCache:");
	local string_match = string.match;
	local string_sub = string.sub;
	local manifest_md5 = {};
	local line;
	local file = ParaIO.open("assets_manifest.txt", "r");
	if(file:IsValid()) then
		line=file:readline();
		while line~=nil do 
				--commonlib.echo(line);
			local _,md5 = string_match(line,"(.-),(.-),(.-)");
			if(md5) then
				--commonlib.echo(md5);
				manifest_md5[md5] = true;
			end
			line=file:readline();
		end
		file:close();
	end
	
	local files = {};
	commonlib.SearchFiles(files, "temp/cache/", "*", 1, 20000, true);
	--commonlib.echo(files);
	--LoadManifest();
	local i=0;
	local count = 0;
	local md5;
	LOG.std("", "system","Login", "begin to  clean.");
	local count_level0 = 0;
	for i = 1, #files do 
		local filename = files[i];
		if(#filename >= 32) then
			if(filename:sub(2,2) == '/') then
				md5 = filename:sub(3, 34);
			else
				md5 = filename:sub(1, 32);
				count_level0 = count_level0 + 1;
			end
			-- echo({filename, md5})
			if(not manifest_md5[md5]) then
				commonlib.echo(files[i]);
				ParaIO.DeleteFile("temp/cache/" .. files[i]);
				count = count + 1;
				if(count > 1000) then
					break;
				end
			end
		end
	end
	LOG.std("", "system","Login", "delete count is %d",count);

	UserLoginProcess.Proc_OneTimeInitAfterLogin();
	MainLogin:next_step({IsCleanCached = true});
end