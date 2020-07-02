--[[
Title: 
Author(s): leio
Date: 2015/3/2
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/mobile/paracraft/Login/AutoUpdatePage.lua");
local AutoUpdatePage = commonlib.gettable("ParaCraft.Mobile.Login.AutoUpdatePage")
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
local AutoUpdatePage = commonlib.gettable("ParaCraft.Mobile.Login.AutoUpdatePage")
function AutoUpdatePage.OnInit()
	AutoUpdatePage.page = document:GetPageCtrl();
end
function AutoUpdatePage.ShowPage()
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/mobile/paracraft/Login/AutoUpdatePage.html", 
		name = "AutoUpdatePage.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 1001,
		allowDrag = false,
		directPosition = true,
			align = "_fi",
			x = 0,
			y = 0,
			width = 0,
			height = 0,
		cancelShowAnimation = true,
	});
	if(not AutoUpdatePage.timer)then
		AutoUpdatePage.timer = commonlib.Timer:new()
		AutoUpdatePage.timer.callbackFunc = AutoUpdatePage.OnTimer;
	end
	AutoUpdatePage.timer:Change(0, 200)

end
function AutoUpdatePage.ClosePage()
	if(AutoUpdatePage.page)then
		AutoUpdatePage.page:CloseWindow();
	end
	if(AutoUpdatePage.timer)then
		AutoUpdatePage.timer:Change(nil);
	end
end
function AutoUpdatePage.Update(percent,tips)
	AutoUpdatePage.page:SetValue("progressbar_normal",percent * 100);
	AutoUpdatePage.page:SetValue("txt_info_normal",tips);
	AutoUpdatePage.page:SetValue("txt_percent_advanced_open",string.format("%d%%",percent * 100));
end
function AutoUpdatePage.OnTimer()
	NPL.activate("AutoUpdater.cpp", {type="auto_update",action = "refresh"})
end
local function activate()
	local msg = msg_auto_update;
	local state = msg.state;
	local bFinished = false;
	if(state == "PREDOWNLOAD_VERSION")then
		AutoUpdatePage.ShowPage();
		AutoUpdatePage.Update(0,L"检查更新");
	elseif(state == "VERSION_ERROR" or state == "MANIFEST_ERROR" or state == "FAIL_TO_ASSETS_DOWNLOAD" or state == "FAIL_TO_UPDATED")then
		AutoUpdatePage.Update(0,state);
	elseif(state == "VERSION_CHECKED" and msg.need_update == true)then
		AutoUpdatePage.Update(0,L"有新版本");
		AutoUpdatePage.cur_version = msg.cur_version;
		AutoUpdatePage.last_version = msg.last_version;
	elseif(state == "VERSION_CHECKED" and msg.need_update == false)then
		AutoUpdatePage.Update(1,L"无新版本");
		bFinished = true;
		AutoUpdatePage.cur_version = msg.cur_version;
	elseif(state == "DOWNLOADING_ASSETS")then
		local unit = 1024 * 1024;
		local s;
		if (msg.total > unit)then
			s = string.format("%.2f/%.2f(MB) v%s -> v%s", msg.downloaded / unit, msg.total / unit,AutoUpdatePage.cur_version or "",AutoUpdatePage.last_version or "");
		else
			s = string.format("%.0f/%.0f(KB)) v%s -> v%s", msg.downloaded / 1024, msg.total / 1024,AutoUpdatePage.cur_version or "",AutoUpdatePage.last_version or "");
		end
		AutoUpdatePage.Update(msg.percent,s);
		LOG.std("", "debug", "AutoUpdate", "downloading:%d/%d %s", msg.cur_file_downloaded or 0,msg.cur_file_total or 0,msg.url);
	elseif(state == "ASSETS_DOWNLOADED")then
		AutoUpdatePage.Update(1,L"资源下载完毕, 准备更新");
		NPL.activate("AutoUpdater.cpp", {type="auto_update",action = "apply"})
	elseif(state == "PREUPDATE")then
		AutoUpdatePage.Update(0,L"准备更新");
	elseif(state == "UPDATING")then
		if(msg.len and msg.len > 0)then
			local percent = msg.index / msg.len;
			AutoUpdatePage.Update(percent,string.format(L"更新(%d/%d) %s",msg.index or 0,msg.len or 0,msg.filepath or ""));
		end
	elseif(state == "UPDATED")then
		AutoUpdatePage.Update(1,L"更新完毕");
		bFinished = true;
	end
	if(bFinished)then
		if(not AutoUpdatePage.finished)then
			AutoUpdatePage.finished = true;
			AutoUpdatePage.ClosePage();
			NPL.load("(gl)script/mobile/paracraft/Login/MainLogin.lua");
			ParaCraft.Mobile.MainLogin:start()
		end
	end
end
NPL.this(activate);