--[[
Title: ClientUpdaterPage.html code-behind script
Author(s): LiXizhi
Date: 2009/9/9
Desc: using AutoUpdater.dll to update Core ParaEngine Files to latest version

use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/ClientUpdaterPage.lua");
local ClientUpdaterPage = commonlib.gettable("MyCompany.Aries.Login.ClientUpdaterPage")
ClientUpdaterPage.GetClientVersion();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/FileLoader.lua");
NPL.load("(gl)script/ide/app_ipc.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/SwfLoadingBarPage.lua");
local SwfLoadingBarPage = commonlib.gettable("Map3DSystem.App.MiniGames.SwfLoadingBarPage")
local FileLoader = commonlib.gettable("CommonCtrl.FileLoader")
local ClientUpdaterPage = commonlib.gettable("MyCompany.Aries.Login.ClientUpdaterPage")
ClientUpdaterPage.src = nil;

-- if true, we will not update the client. This is mostly used during the development process. 
local DONOT_UPDATE_CLIENT = not ReleaseBuild;
-- if it is web browser, we should not update. 
if(System.options.IsWebBrowser or ParaEngine.GetAppCommandLineByParam("updateurl", "")~="" or ParaEngine.GetAppCommandLineByParam("noupdate", "")=="true") then
	-- since we already updated the client before the core client is loaded, there is no need to do it again here. 
	DONOT_UPDATE_CLIENT = true;
end

-- singleton page
local page;
local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");

-- Note LiXizhi 2009.8.2: this is added to display the page for at least some seconds for users to read ads. 
local update_completed = false;
-- whether to stop after update is complete or paused. The user either restart or exit. 
local stop_after_complete = nil;

-- check timer every this interval 100ms. 
local timer_inverval = 100;
-- how long in ms will the loader page display when finished. default to 1. set this to 10000 to debug the UI. 
local timer_complete_delay = 1;

local percentage = 0;
-- whether we have loaded the bg world
local IsBgWorldLoaded;
-- whether to use flash loader
local bUseFlashLoader = true;
local LastLoaderTextTime; 
local LastLoaderProgressTime; 

-- adjust settings
local function AutoAdjustGraphicsSettings()
	MyCompany.Aries.Desktop.AriesSettingsPage.AutoAdjustGraphicsSettings(false, 
		function(bChanged) 
			NPL.load("(gl)script/apps/Aries/Login/MainLogin.lua");
			if(ParaEngine.GetAttributeObject():GetField("HasNewConfig", false)) then
				ParaEngine.GetAttributeObject():SetField("HasNewConfig", false);
				_guihelper.MessageBox("您上次运行时更改了图形设置. 是否保存目前的显示设置.", function(res)	
					if(res and res == _guihelper.DialogResult.Yes) then
						-- pressed YES
						ParaEngine.WriteConfigFile("config/config.txt");
					end
					MyCompany.Aries.MainLogin:next_step({IsCoreClientUpdated = true});
				end, _guihelper.MessageBoxButtons.YesNo)
			else
				MyCompany.Aries.MainLogin:next_step({IsCoreClientUpdated = true});
			end
		end,
		-- OnChangeCallback, return false if you want to dicard the changes. 
		function(params)
			if(System.options.IsWebBrowser) then
				if(params.new_effect_level) then
					MyCompany.Aries.Desktop.AriesSettingsPage.AdjustGraphicsSettingsByEffectLevel(params.new_effect_level)
				end
				if(params.new_screen_resolution) then
					local x,y = params.new_screen_resolution[1], params.new_screen_resolution[2];
					if(x == 800) then  x = 720 end
					if(y == 533) then y = 480 end
					commonlib.log("ask web browser host to change resolution to %dx%d\n", x,y);
					commonlib.app_ipc.ActivateHostApp("change_resolution", nil, x, y);
				end
				return false;
			end
		end);
end

NPL.load("(gl)script/ide/timer.lua");
ClientUpdaterPage.mytimer = commonlib.Timer:new({callbackFunc = function(timer)
	if(stop_after_complete) then
		return;
	end
	local all_complete = 0;
	if(not update_completed) then
		
		if(DONOT_UPDATE_CLIENT) then
			-- this emulate the core update progress, when DONOT_UPDATE_CLIENT is true. 
			-- +10 is also a good choice, so that some animation is displayed for user to see loader text even everything is ready. 
			if(not ReleaseBuild) then
				percentage = percentage + 100;
			else
				percentage = percentage + 10;
			end
		end	
		
		if(percentage >= 100) then
			update_completed = true;
			timer:Change(timer_complete_delay, nil);
		else
			timer:Change(timer_inverval, nil);
		end
		
		--更新flash进度
		if(bUseFlashLoader) then
			if(SwfLoadingBarPage and SwfLoadingBarPage.Update)then
				SwfLoadingBarPage.Update(percentage/100);
			end
		else
			page:SetUIValue("progressbar",percentage);
			page:SetUIValue("progress_result",percentage.."%");	
		end	
	else
		-- only proceed if mini_assets_preloader is finished. 
		if(ClientUpdaterPage.mini_assets_preloader and ClientUpdaterPage.mini_assets_preloader.isFinished) then
			if(bUseFlashLoader) then
				if(SwfLoadingBarPage and SwfLoadingBarPage.ClosePage)then
					SwfLoadingBarPage.ClosePage();
				end
			end
			-- proceed to next login step. 
			page:CloseWindow();
			
			-- check for graphics settings, this step is moved here so that it will show up in web browser as well.
			NPL.load("(gl)script/apps/Aries/Desktop/AriesSettingsPage.lua");
			MyCompany.Aries.Desktop.AriesSettingsPage.CheckMinimumSystemRequirement(true, function(result, sMsg)
				if(result >=0 ) then
					AutoAdjustGraphicsSettings();
				else
					-- exit because PC is too old. 
				end
			end);
			all_complete = 1;
		else
			if(ClientUpdaterPage.mini_assets_preloader)then
				local p = ClientUpdaterPage.mini_assets_preloader:GetPercent();
				percentage = p*100;
				if(SwfLoadingBarPage and SwfLoadingBarPage.Update)then
					SwfLoadingBarPage.Update(p);
				end
			end
			timer:Change(timer_inverval, nil);	
		end
		
		-- TODO: if reboot is required, change to following state
		-- MainLogin:next_step({IsRebootRequired = true});
	end

	if(System.options.IsWebBrowser) then
		local p = math.floor(percentage);
		if(p>100) then 
			p = 100 
		end
		
		local curTime = ParaGlobal.timeGetTime();
		if(all_complete==1 or (not LastLoaderProgressTime or (curTime - LastLoaderProgressTime)>2000)) then
			local loader_text;
			LastLoaderProgressTime = curTime;
			--if(SwfLoadingBarPage) then
				--loader_text = SwfLoadingBarPage.GetNextLoadingText();
			--end
			loader_text = ""; -- utf8 chinese characters may crash the computer. 
			commonlib.app_ipc.ActivateHostApp("preloader", loader_text, p, all_complete);
		end
	end
end})

----------------------------------------------------------------------------------
-- The following are code from AutoPatcherPage.lua
----------------------------------------------------------------------------------
-- the version file should contain a single line of text such as "1.0.0"
ClientUpdaterPage.sVersionFileName = "version.txt";

-- get the current client version.
-- @param defaultVersion: if this is nil, 
function ClientUpdaterPage.GetClientVersion(defaultVersion)
	if(not ClientUpdaterPage.ClientVersion) then
		local bNeedUpdate = true;
		if( ParaIO.DoesFileExist(ClientUpdaterPage.sVersionFileName)) then
			local file = ParaIO.open(ClientUpdaterPage.sVersionFileName, "r");
			if(file:IsValid()) then
				local text = file:GetText();

				ClientUpdaterPage.ClientVersion = string.match(text,"ver=([^\r\n]*)");
				local major, minor, sub_minor =string.match(text,"ver=(%d+)%.(%d+)%.(%d+)");
				commonlib.log("client version is %d.%d.%d\n", major, minor, sub_minor);

				file:close();
			end
		end
		if(not ClientUpdaterPage.ClientVersion) then
			ClientUpdaterPage.ClientVersion = "0.0.0";
		end

		if (System.options.version=="teen") then
			local config_file="config/Aries/version.xml"; 		
			local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
			if(xmlRoot) then
				local xmlnode="/version/ver";	
				local _each_v,_ver;
				for _each_v in commonlib.XPath.eachNode(xmlRoot, xmlnode) do			
					_class = _each_v.attr.class;
					if (_class) then
						_class = string.lower(_each_v.attr.class);
						if (_class == System.options.version ) then
							_ver = _each_v.attr.value;
						end
					end
				end
				if(_ver) then
					ClientUpdaterPage.ClientVersion = string.format("%sBuild%s",_ver,ClientUpdaterPage.ClientVersion);	
				end
			end
		end
	end
	
	return ClientUpdaterPage.ClientVersion;
end

-- init function. page script fresh is set to false.
function ClientUpdaterPage.OnInit()
	page = document:GetPageCtrl();
	-- start timer
	ClientUpdaterPage.mytimer:Change(10, nil);
	-- ClientUpdaterPage.mytimer:Change(0, nil);
		
	if(bUseFlashLoader) then
		if(SwfLoadingBarPage and SwfLoadingBarPage.ShowPage)then
			SwfLoadingBarPage.ShowPage(
				{ top = -50 }
			);
		end
	end
	
	NPL.load("(gl)script/ide/Encoding.lua");
	NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
		
	-- load the 3D scene when the first UI is displayed. 
	-- TODO: we may wait until the updater has updated this login_bg_worldpath, then load it. So that we can diplay some news and movies specific to that update.  
	MainLogin:next_step({Loaded3DSceneRequested = true, login_bg_worldpath = MyCompany.Aries.ExternalUserModule:GetConfig().login_bg_worldpath});
	
	-- get client version. 
	local client_version = ClientUpdaterPage.GetClientVersion();
	
	ParaEngine.SetWindowText(string.format("%s -- ver %s", MyCompany.Aries.ExternalUserModule:GetConfig().title_url, client_version));
	if(FileLoader and FileLoader.CreateGetLoader)then
		ClientUpdaterPage.mini_assets_preloader = FileLoader.CreateGetLoader("config/Aries/Preloaders/Aries_PreloadList_BeforeLogin.txt");
		ClientUpdaterPage.mini_assets_preloader.logname = "log/Aries_PreloadList_BeforeLogin";
		ClientUpdaterPage.mini_assets_preloader:Start();
	end
	-- activate dll to begin updating
	if(not DONOT_UPDATE_CLIENT) then
		-- curver is the version number of client before it is updated
		-- lastver is the latest version number that we will update to. This is usually fetched from an HTTP service or game server. if "", it will be fetched by the dll. 
		NPL.activate("AutoUpdater.dll", {cmd="update", updatedir="web", curver=ClientUpdaterPage.GetClientVersion(), lastver="",  callback="(gl)script/apps/Aries/Login/ClientUpdaterPage.lua",});
	end
end

-- called when progress increases
function ClientUpdaterPage.OnPackageStep()
	-- TODO: shall we display some advertisement here?
end

-- callback from the AutoUpdater.dll
local function activate()
	LOG.std("", "system", "updater", msg)
	if(msg.ischanged == "no") then
		DONOT_UPDATE_CLIENT = true;
	elseif(ischanged == "unknown") then
		DONOT_UPDATE_CLIENT = true;
		_guihelper.MessageBox("无法确认您是否在使用最新的版本， 请到官方网站重新下载客户端");
		
	elseif(msg.isfinished == "yes") then
		if(msg.allcount == msg.finishcount and msg.filelist) then
			LOG.std("", "system", "updater", "Core ParaEngine Client update completed!");
			update_completed = true;
			stop_after_complete = true;
			LOG.std("", "system", "updater", "update client using %s", msg.filelist)
			local lastmsg = msg;
			
			local is_started;
			local function Restart_()
				if(not is_started) then
					is_started = true;
					
					ParaEngine.GetAttributeObject():SetField("IsWindowClosingAllowed", true);
					NPL.activate("AutoUpdater.dll", {cmd="restart", updatedir="web", version=lastmsg.version, filelist=lastmsg.filelist,});
					ParaGlobal.ExitApp();
				end
			end
			
			-- auto restart after 3 seconds, or let user click the OK button. 
			local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
				Restart_()
			end})
			mytimer:Change(3000, nil)

			_guihelper.MessageBox([[ <div style="padding-left:112px;padding-top:16px;">更新成功！</div><br/><div style="padding-left:84px;padding-top:8px">欢迎进入哈奇小镇。</div>]], function(res)
				if(res and res == _guihelper.DialogResult.OK) then
					Restart_();
				end
			end, _guihelper.MessageBoxButtons.OK)
		else
			stop_after_complete = true;
			
			_guihelper.MessageBox(string.format("你已经下载%d个更新文件中的%d个. 中途遇到网络问题, 请点击[是]继续更新, 点击[否]退出程序", msg.allcount, msg.finishcount), function(res)
				LOG.std("", "error", "updater", "error: Core ParaEngine Client update failed! We are unable to download some files");
				if(res and res == _guihelper.DialogResult.Yes) then
					-- we shall exit and restart
					ParaEngine.GetAttributeObject():SetField("IsWindowClosingAllowed", true);
					NPL.activate("AutoUpdater.dll", {cmd="restartonly"});
					ParaGlobal.ExitApp();
				else
					-- exit directly. 
					ParaEngine.GetAttributeObject():SetField("IsWindowClosingAllowed", true);
					ParaGlobal.ExitApp();
				end	
			end, _guihelper.MessageBoxButtons.YesNo);
		end
	elseif(msg.isfinished == "error") then
		DONOT_UPDATE_CLIENT = true;
		_guihelper.MessageBox("更新没有完成. 请稍候再试, 或到官方网站重新下载客户端");
		
	elseif(msg.finishcount and msg.allcount) then
		local p = msg.finishcount/msg.allcount;
		percentage = math.floor(100*p);
	end	
end
NPL.this(activate);