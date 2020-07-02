--[[
Title: Aries Main login page
Author(s): WangTian, LiXizhi
Date: 2009/4/6
Desc:  script/apps/Aries/Login/MainLoginPage.html?cmdredirect=Profile.HomePage
Login stages are following. Offline mode can be enabled only when network is not found and the user has signed in before. 
stage==nil: initial stage
stage==1: paraworld.auth.GetServerList
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
NPL.load("(gl)script/apps/Aries/Login/MainLoginPage.lua");
MyCompany.Aries.LoginPage.Proc_Start(values, funcCallBack, bSkipAppRegistration)
-------------------------------------------------------
]]
local L = CommonCtrl.Locale("ParaWorld");

local LoginPage = {};
commonlib.setfield("MyCompany.Aries.LoginPage", LoginPage)

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
	paraworld.auth.GetServerList(nil, "GetAriesServerList", function(msg)
		if(LoginPage.stage >= 1) then
			return
		end
		LoginPage.stage = 1;
		commonlib.log("login stage %d: Getting server list\n", LoginPage.stage)
		
		if(msg == nil) then
			paraworld.ShowMessage("获取服务器列表失败，请查看网络连接\n");
			
			-- NOTE: LiXizhi 2009.7.30. if web test server is done, procede.  remove this when server is fine. 
			--commonlib.applog("---------------remove me------------")
			--paraworld.ShowMessage("正在验证用户身份, 请等待...", nil, _guihelper.MessageBoxButtons.Nothing)
			--LoginPage.Proc_Authentication(values, funcCallBack, bSkipAppRegistration);
			
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
	if(paraworld.use_game_server) then
		if( GameServer.rest.client:start(nil, 1) ~= 0) then
			paraworld.ShowMessage("与GameServer的链接, 无法建立");
		end
	end
	
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
			System.User.LastAuthGameTime = ParaGlobal.GetGameTime();
			--System.User.ChatDomain = values.domain;
			
			paraworld.ShowMessage(L"登陆成功, 正在同步用户信息, 请稍候...", nil, _guihelper.MessageBoxButtons.Nothing);
			if(not MyCompany.Aries.app:ReadConfig("Registered", false)) then
				MyCompany.Aries.app:WriteConfig("Registered", true);
			end
			if(values.rememberpassword) then
				System.User.SaveCredential(System.User.Name, System.User.Password);
			end
			MyCompany.Aries.app:WriteConfig("rememberpassword", values.rememberpassword);
			
			-- call the get info once logged in, to validate the fullname, we assume that the CachePolicy is "1 day"
			-- TODO: this policy will fail if user stay up across two days, the first paraworld.users.getInfo call on the next day 
			--		will execute the post function twice. First one is an immediate return from local server and the second is 
			--		returned from a new established web service call.
			--System.App.profiles.ProfileManager.GetUserInfo(nil,nil,nil, "access plus 0 day");
			-- System.App.profiles.ProfileManager.GetMCML();
			
			-- ProfileManager.GetMCML(uid, Map3DSystem.App.appkeys["profiles"], callbackFunc)
			-- paraworld.profile.GetMCML({uid = System.User.userid, }, "AriesMyselfMCML");
			
			-- download full profile and may optionally invoke app registration pages.
			LoginPage.LoginCallBack = funcCallBack;
			LoginPage.bSkipAppRegistration = bSkipAppRegistration;
			
			--LoginPage.Proc_DownloadProfile(System.User.sessionkey, System.User.userid)
			
			LoginPage.Proc_VerifyNickName();
			
			--LoginPage.Proc_Complete();
		else
			if(msg.errorcode == 412) then
				paraworld.ShowMessage(string.format("%s\n\n%s", tostring(msg.info), 
					"账号未激活, 我们需要您通过Email等方式确认您的身份后才能登陆\n是否希望重新发送确认信到你注册时提供的邮箱?"), function()
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
			_selectNickName.background = "Texture/Aries/Login/MessageBox_32bits.png:8 8 16 16";
			_panel:AddChild(_selectNickName);
			
			local _text = ParaUI.CreateUIObject("text", "NickName", "_lt", 30, 25, 290, 40);
			_text.font = System.DefaultLargeBoldFontString;
			_text.text = "    为你的角色起一个昵称吧，它是你在这个社区中的名号，也将是其他人区分你和别的玩家最重要的标识呢！\n\n    每个玩家的昵称都是独一无二的，所以尽量让它独具特色，彰显你自己的个性吧！";
			_selectNickName:AddChild(_text);
			
			local _nickname = ParaUI.CreateUIObject("imeeditbox", "Proc_VerifyNickName", "_lt", 60, 150, 130, 24);
			_selectNickName:AddChild(_nickname);
			
			local _confirm = ParaUI.CreateUIObject("button", "Confirm", "_lt", 205, 150, 80, 24);
			_confirm.onclick = ";MyCompany.Aries.LoginPage.SelectNickName();";
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

-- Download profile and proceed to Proc_SyncGlobalStore()
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
			LoginPage.Proc_SyncGlobalStore();
		else
			-- paraworld.ShowMessage("无法从服务器获取用户信息, 可能服务器正忙, 请稍候再试.");
			-- NOTE: for offline mode, proceed anyway. Find a better way, since this could be Online mode error as well.
			log("DownloadFullProfile: failed. Proceed to offline mode anyway. \n")
			LoginPage.Proc_SyncGlobalStore();
		end
	end, "access plus 0 day"); -- added a cache policy that will always get the full profile in download full profile stage
end

-- Sync all bag items with user inventory and proceed to Proc_VerifyInventory
function LoginPage.Proc_SyncGlobalStore()
	paraworld.ShowMessage("正在同步物品描述", nil, _guihelper.MessageBoxButtons.Nothing);
	
	if(LoginPage.stage >= 5) then
		return
	end
	
	LoginPage.stage = 5;
	commonlib.log("login stage %d: Proc_SyncGlobalStore\n", LoginPage.stage);
	
	-- TODO: global store regions are read from the GetServerList file
	-- TODO: we can also specify some of the regions are newly modified, with a cache policy 
	
	local gsidRegions = {
		{1001, 1040}, -- avatar apparels and hand-held
		{9001, 9003}, -- character animation
		{9501, 9503}, -- throwable
		{10001, 10001}, -- mount pet dragon
		{10101, 10110}, -- follow pet
		{11001, 11008}, -- mount pet apparel
		{15001, 15001}, -- pet animation
		{16001, 16020}, -- consumable
		{17001, 17007}, -- collectable
		{19001, 19001}, -- reading
		{20001, 20008}, -- medals
		{21001, 21005}, -- quest related, acinus
		{30001, 30018}, -- home land plants
		{50001, 50041}, -- quest tags
	};
	
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
				-- continue to Proc_VerifyInventory() if all gsids templates are fetched
				LoginPage.Proc_VerifyInventory();
			end
		end, "access plus 0 day");
	end
end

-- Sync all bag items with user inventory and proceed to Proc_VerifyPet
function LoginPage.Proc_VerifyInventory()
	paraworld.ShowMessage("正在获取物品信息", nil, _guihelper.MessageBoxButtons.Nothing);
	
	System.Item.ItemManager.GetItemsInAllBags(nil, function(bSucceed)
		-- NOTE: GetItemsInAllBags callbackFunc(bSucceed) is not fully tested, might return twice or more
		if(LoginPage.stage >= 6) then
			return
		end
		
		LoginPage.stage = 6;
		commonlib.log("login stage %d: Proc_VerifyInventory\n", LoginPage.stage)
		
		if(bSucceed) then
			-- after downloading current user inventory, verify user avatar
			LoginPage.Proc_VerifyPet();
		else
			-- paraworld.ShowMessage("无法从服务器获取物品信息, 可能服务器正忙, 请稍候再试.");
			-- NOTE: for offline mode, proceed anyway. Find a better way, since this could be Online mode error as well.
			log("GetItemsInAllBags: failed. Proceed to offline mode anyway. \n")
			LoginPage.Proc_VerifyPet();
		end
	end, "access plus 0 day"); -- added a cache policy that will always get the inventory data
end

function LoginPage.Proc_VerifyPet()
	--paraworld.ShowMessage("Proc_VerifyPet");
	paraworld.ShowMessage("正在获取宠物信息", nil, _guihelper.MessageBoxButtons.Nothing);
	
	if(LoginPage.stage >= 7) then
		return
	end
	LoginPage.stage = 7;
	commonlib.log("login stage %d: Proc_VerifyPet\n", LoginPage.stage);
	
	--初始化坐骑的数据
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandProvider.lua");
	Map3DSystem.App.HomeLand.HomeLandProvider.PetInit(System.User.nid);
	
	local ItemManager = System.Item.ItemManager;
	local bOwn, guid = ItemManager.IfOwnGSItem(10001);
	if(bOwn == true and guid > 0) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			log("Leio: init the pet here, the pet is already fetched in stage 6\nMount Pet item:")
			commonlib.echo({item.guid, item.gsid})
			commonlib.echo("call init of the pet item here to fetch the data, when received call LoginPage.Proc_VerifyFriends()\n");
			LoginPage.Proc_VerifyFriends();
		else
			LoginPage.Proc_VerifyFriends();
		end
	else
		-- directly enter world
		-- if nude avatar the user is first login to the community, launch the tutorial
		LoginPage.Proc_VerifyFriends();
	end
end

function LoginPage.Proc_VerifyFriends()
	paraworld.ShowMessage("正在获取好友信息", nil, _guihelper.MessageBoxButtons.Nothing);
	ParaUI.Destroy("SelectNickName_panel");
	ParaUI.Destroy("SelectAvatar_panel");
	
	if(LoginPage.stage >= 8) then
		return
	end
	LoginPage.stage = 8;
	commonlib.log("login stage %d: Proc_VerifyFriends\n", LoginPage.stage)
	
	NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
	MyCompany.Aries.Friends.GetMyFriends(function(msg)
		if(msg.issuccess == true) then
			-- continue with the next stage
			LoginPage.Proc_Complete();
		elseif(msg.issuccess == false) then
		    log("warning: error fetching friends\n");
		    commonlib.echo(msg);
			paraworld.ShowMessage("获取好友信息失败，请稍候再试");
		end
	end, "access plus 0 day");
end


-- login procedure completed. 
function LoginPage.Proc_Complete()
	if(LoginPage.stage >= 10) then
		return
	end
	LoginPage.stage = 10;
	commonlib.log("login stage %d: Proc_Complete\n", LoginPage.stage)
	
	paraworld.ShowMessage("准备装载世界, 请稍候...", nil, _guihelper.MessageBoxButtons.Nothing);
	
	-- login to jabber chat 
	NPL.load("(gl)script/kids/3DMapSystemUI/Chat/Main.lua");
	System.App.Chat.OneTimeInit();
	
	-- TODO: LiXizhi 2008.12.24. Connect to the world if it is not yet connected. 
	System.App.Chat.AddEventListener("JE_OnAuthenticate", function(msg)
		System.App.Commands.Call("File.ConnectAriesWorld");
	end)
	
	-- init Aries specific features
	NPL.load("(gl)script/apps/Aries/Chat/Main.lua");
	MyCompany.Aries.Chat.Init();
		
	if(type(LoginPage.LoginCallBack) =="function") then
		-- call the user call back
		LoginPage.LoginCallBack();
	end
end