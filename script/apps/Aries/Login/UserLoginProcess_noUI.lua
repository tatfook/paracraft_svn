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

NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/ShutdownTimer.lua");
local UserLoginProcess = commonlib.gettable("MyCompany.Aries.Login.UserLoginProcess");

local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");

UserLoginProcess.LoginCallBack = nil;

-- whether to use flash loader
local bUseFlashLoader = true;

-- Display error message and go back to login page. 
-- @msg: text to shown in message box
-- @state: nil or a table to pass to MainLogin:next_step(). if nil it defaults to {IsLoginStarted = false}
function UserLoginProcess.Fail(msg, state)
	commonlib.log(msg or "无法登陆, 未知错误");
	MainLogin:next_step(state or {IsLoginStarted = false});
end

-- current login procentage. 
UserLoginProcess.percentage = 0;

-- display current progress. Pass nil to all params like UserLoginProcess.ShowProgress(); will hide UI. 
-- @param msg: message string. If nil, it means 100% finished. 
-- @param percentage: value in [0,100]. If nil, it will just increase the self.percentage by step or 10. 
-- @param step: the step to increase when percentage is nil. default to 10. 
function UserLoginProcess.ShowProgress(msg, percentage, step)
	commonlib.log(msg);
end

-- establish the first rest connection with the initial gateway game server. 
function UserLoginProcess.Proc_ConnectRestGateway()
	UserLoginProcess.ShowProgress("正在建立连接...\n", 0);
	
	-- max number of login server to retry in sequence. 
	-- set to 0 to disable retry and a dialog is displayed to the user. 
	local max_retry_count = 2;
	local cur_retry_count = 0;
	
	if(paraworld.use_game_server) then
		
		local function StartConnect_()
			commonlib.log("try connecting to game server the %d times\n", cur_retry_count+1);
			-- set redirecting to true to prevent disconnection message box to appear. 
			System.User.IsRedirecting = true;
			local res = GameServer.rest.client:start(nil, 0, function(msg)
				if(msg and msg.connected) then
					MainLogin:next_step({IsRestGatewayConnected = true});
				else
					if(cur_retry_count<max_retry_count) then
						cur_retry_count = cur_retry_count + 1;
						UserLoginProcess.ShowProgress(string.format("正在建立连接...(第%d次尝试)", cur_retry_count+1), 0);
						StartConnect_();
					else
						System.User.IsRedirecting = true;
						UserLoginProcess.Fail([[ 服务器的链接无法建立, 请稍候再试 ]]);
					end	
				end
			end);
			-- ParaEngine.Sleep(3);
			if( res ~= 0) then
				UserLoginProcess.Fail("服务器的链接无法建立\n");
			else
				MainLogin:next_step({IsRestGatewayConnected = true});	
			end
		end
		StartConnect_();
	else
		MainLogin:next_step({IsRestGatewayConnected = true});
	end
end

function UserLoginProcess.Proc_Registration()
	UserLoginProcess.ShowProgress("正在注册, 请等待...\n");
	
	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_Registration"}, "user_login_process_stage_progress_log", function(msg)
	end);
	
	paraworld.users.Registration(commonlib.deepcopy(MainLogin.state.reg_user), "TaoMee", function(msg)
		if(not msg) then
			UserLoginProcess.Fail("无法连接到服务器", {IsRegistrationRequested=true, IsRegUserRequested=false});
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
			MainLogin.state.auth_user.username = tostring(msg.nid);
			MainLogin:next_step({IsRegUserRequested = false, IsRegUserConfirmRequested = true});
			
		elseif(msg.errorcode) then	
			if(msg.errorcode == 401) then
				UserLoginProcess.Fail("这个Email已经注册过啦!", {IsRegistrationRequested=true, IsRegUserRequested=false});
				-- send log information
				paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_Registration_email_registered"}, 
					"user_login_process_stage_fail_log", function(msg)
				end);
			else
				log("error: can not register through paraworld.users.Registration, errorcode:"..msg.errorcode.."\n")
				UserLoginProcess.Fail("暂时无法注册，请稍候再试", {IsRegistrationRequested=true, IsRegUserRequested=false});
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
		commonlib.applog("Proc_Registration timed out")
		UserLoginProcess.Fail("用户注册超时了, 可能服务器在维护中", {IsRegistrationRequested=true, IsRegUserRequested=false});
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
	}
	UserLoginProcess.ShowProgress("验证用户身份\n");
	commonlib.applog("Start Proc_Authentication");
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Chat/Main.lua");
	System.App.Chat.CleanUp();
	
	commonlib.echo(msg);
	
	--[[
	-- define a base class with constructor
	local client = commonlib.gettable("GameServer.rest.client");
	-- set to true to output all IO to log
	client.debug_stream = true;
	]]
	
	paraworld.auth.AuthUser(msg, "login", function (msg)		
		if(msg==nil) then
			UserLoginProcess.Fail("连接的主机没有反应,连接尝试失败\n");
		elseif(msg.issuccess) then				
			System.User.Name = values.username;
			System.User.Password = values.password;
			System.User.LastAuthGameTime = ParaGlobal.GetGameTime();
			System.User.LastAuthServerTime = msg.dt or "2009-11-23 21:18:38"; -- yyyy-MM-dd HH:mm:ss					
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
		end;
		commonlib.log("AAA\n")
	end, nil, 20000, function(msg)
		-- timeout request
		commonlib.applog("Proc_Authentication timed out")
		UserLoginProcess.Fail("用户验证超时了, 可能服务器太忙了, 或者您的网络质量不好.");
	end)	

end

-- verify nickname and avatar CCS info
-- if no nickname and avatar CCS infomation is filled, remind the user to choose a permernent nickname and avatar
function UserLoginProcess.Proc_VerifyNickName()
	UserLoginProcess.ShowProgress("正在获取人物信息");
	
	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_VerifyNickName"}, "user_login_process_stage_progress_log", function(msg)
	end);
	
	System.App.profiles.ProfileManager.GetUserInfo(System.User.nid, "Proc_VerifyNickName", function(msg)
		if(msg == nil or not msg.users or not msg.users[1]) then
			commonlib.echo(msg)
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
	end, "access plus 0 day", 20000, function(msg)
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
	
end

-- Sync server objects and proceed to Proc_SyncGlobalStore()
function UserLoginProcess.Proc_VerifyServerObjects()
	UserLoginProcess.ShowProgress("正在同步世界变量");
	
	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_VerifyServerObjects"}, "user_login_process_stage_progress_log", function(msg)
	end);
	
	NPL.load("(gl)script/apps/Aries/Scene/main.lua");
	MyCompany.Aries.Scene.GetAllServerObjects(function(msg)
		if(msg.issuccess == true) then
			-- continue with the next stage
			MainLogin:next_step({IsServerObjectsVerified = true});
			
		elseif(msg.issuccess == false) then
		    log("warning: error fetching server objects\n");
		    commonlib.echo(msg);
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
end

-- Sync all bag items with user inventory and proceed to Proc_VerifyInventory
function UserLoginProcess.Proc_SyncGlobalStore()
	UserLoginProcess.ShowProgress("正在同步物品描述");
	
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
		commonlib.log("error: failed loading GlobalStore.IDRegions config file: %s, using default\n", filename);
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
		if(node.attr and node.attr.from and node.attr.to) then
			table.insert(gsidRegions, {tonumber(node.attr.from), tonumber(node.attr.to)});
		end
	end
	
	local gsidLists = {};
	
	local accum = 0;
	local gsids = "";
	local _, pair;
	for _, pair in ipairs(gsidRegions) do
		local i;
		for i = pair[1], pair[2] do
			accum = accum + 1;
			gsids = gsids..i..",";
			if(accum == 10) then
				gsidLists[gsids] = false;
				accum = 0;
				gsids = "";
			end
		end
	end
	if(gsids ~= "") then
		gsidLists[gsids] = false;
	end
	local i = 0;
	local gsids, hasReplied;
	for gsids, hasReplied in pairs(gsidLists) do
		i = i + 1;
		System.Item.ItemManager.GetGlobalStoreItem(gsids, "Proc_SyncGlobalStore_"..i, function(msg)
			-- TODO: we don't care if the globalstore item templates are really replied, response is success
			--		for more unknown item templates please refer to Item_Unknown for late item visualization or manipulation
			-- NOTE: global store item can be directly accessed from memory by ItemManager.GetGlobalStoreItemInMemory(gsid);
			gsidLists[gsids] = true;
			local allReplied = true;
			local _, bReply;
			for _, bReply in pairs(gsidLists) do
				if(bReply == false) then
					allReplied = false;
					break;
				end
			end
			if(allReplied == true) then
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
end

function UserLoginProcess.Proc_SyncExtendedCost()
	UserLoginProcess.ShowProgress("正在同步物品兑换描述");
	
	-- send log information
	paraworld.PostLog({action = "user_login_process_stage_progress", msg="Proc_SyncExtendedCost"}, "user_login_process_stage_progress_log", function(msg)
	end);
	
	-- uncomment to skip this step
	-- MainLogin:next_step({IsExtendedCostSynced = true});
	-- do return end
	
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
		if(node.attr and node.attr.from and node.attr.to) then
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
		System.Item.ItemManager.GetExtendedCostTemplate(exid, "Proc_SyncExtendedCostTemplate_"..i, function(msg)
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
			-- after downloading current user inventory, verify user avatar
			MainLogin:next_step({IsEssentialItemsVerified = true});
		else
			UserLoginProcess.Fail("同步基础物品失败，请稍候再试");
			-- send log information
			paraworld.PostLog({action = "user_login_process_stage_fail", msg = "Proc_VerifyEssentialItems_fail"}, 
				"user_login_process_stage_fail_log", function(msg)
			end);
			return;
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
	
	local item = System.Item.ItemManager.GetMyMountPetItem();
	if(item and item.guid > 0) then
		-- load homeland config
		NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
		Map3DSystem.App.HomeLand.HomeLandConfig.Load();
		-- init the dragon data
		NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandProvider.lua");
		System.App.HomeLand.HomeLandProvider.PetInit(System.User.nid, function(msg)
			if(msg and not msg.errorcode) then
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
		    log("warning: error fetching friends\n");
		    commonlib.echo(msg);
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
					commonlib.applog("warning: jabber client is not connected ater 20 seconds, we will sign in without IM. Some game functions may not be available.\n")
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
	UserLoginProcess.jabber_timer:Change(0, nil);
	
	-- init Aries specific features
	NPL.load("(gl)script/apps/Aries/Chat/Main.lua");
	MyCompany.Aries.Chat.Init();
	
	if(UserLoginProcess.rememberusername and System.User.IsAuthenticated) then
		-- since we have successfully logged in, let us save user info to local disk
		local userInfo = {user_nid = tostring(System.User.nid), user_name = System.User.NickName, password=nil,
			asset_table={
				-- TODO: for andy: just replace this with the real CCS string. 
				CCSInfoStr=System.UI.CCS.GetCCSInfoString(nil, true),
			}};
		if(UserLoginProcess.rememberpassword) then
			userInfo.password = System.User.Password;
		end
		MyCompany.Aries.LocalUserSelectPage:SaveUserInfo(userInfo);
	end	
end