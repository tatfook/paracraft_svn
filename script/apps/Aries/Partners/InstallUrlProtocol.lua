--[[
Title: Url protocol install
Author(s):  LiXizhi
Company: ParaEngine
Date: 2012/9/14
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Partners/InstallUrlProtocol.lua");
local InstallUrlProtocol = commonlib.gettable("MyCompany.Aries.Partners.InstallUrlProtocol");
InstallUrlProtocol.CheckInstallWithUI()
------------------------------------------------------------
]]


local InstallUrlProtocol = commonlib.gettable("MyCompany.Aries.Partners.InstallUrlProtocol");

local kids_protocol = {
	protocol_name = "haqi",
	app_path = ParaIO.GetCurDirectory(0).."HaqiLauncherKids.mem.exe",
	--installer_path = ParaIO.GetCurDirectory(0).."HaqiLauncherKids.exe",
	shell_app_path = nil,
}

-- get a table containing the current protocol info. 
function InstallUrlProtocol.GetProtocolInfo()
	local protocol = kids_protocol;
	if(protocol and not protocol.shell_app_path) then
		local shell_app_path = string.format("%q single=\"true\" %%1", protocol.app_path);
		shell_app_path = shell_app_path:gsub("/", "\\");
		protocol.shell_app_path = shell_app_path;
	end
	return protocol;
end

-- check if url protocol installed. 
function InstallUrlProtocol.HasURLProtocol()
	local info = InstallUrlProtocol.GetProtocolInfo();
	if(info) then
		local protocol_name, shell_app_path = info.protocol_name,  info.shell_app_path;
		
		local has_protocol = ParaGlobal.ReadRegStr("HKCR", protocol_name, "URL Protocol");
		if(has_protocol == "") then
			has_protocol = ParaGlobal.ReadRegStr("HKCR", protocol_name, "");
			if(has_protocol == "URL:ParaEngine") then
				local cmd = ParaGlobal.ReadRegStr("HKCR", protocol_name.."/shell/open/command", "");
				if(cmd) then
					cmd = cmd:gsub("/", "\\");
					if(string.lower(cmd)==string.lower(shell_app_path)) then
						return true;
					end
				end
			end
		end
	end
end


-- use a timer to check if timer is installed.
-- @param callbackFunc: a callback function (bIsInstalled, sErrorMsg) end
-- @param timeout: how many seconds to time out if use has not successfully installed the protocol. default to 30.
function InstallUrlProtocol.InstallURLProtocol(callbackFunc, timeout)
	if(InstallUrlProtocol.HasURLProtocol()) then
		if(callbackFunc) then
			callbackFunc(true);
		end
		return;
	else
		timeout = timeout or 30;

		InstallUrlProtocol.InstallURLProtocol_imp();
		local seconds_count = 1;
		local timer = commonlib.Timer:new({callbackFunc = function(timer)
			if(InstallUrlProtocol.HasURLProtocol()) then
				if(callbackFunc) then
					callbackFunc(true);
				end
				timer:Change();
			else
				seconds_count = seconds_count + 1;
				if(seconds_count > timeout) then
					if(callbackFunc) then
						callbackFunc(false, "timed out");
					end
					timer:Change();
				end
			end
		end})
		timer:Change(1000, 1000);
	end
end

function InstallUrlProtocol.InstallURLProtocol_imp()
	if(System.options.version == "teen") then
		return;
	end
	local info = InstallUrlProtocol.GetProtocolInfo()
	if(info) then
		local protocol_name, shell_app_path, app_path = info.protocol_name,  info.shell_app_path, info.app_path;

		local has_protocol = InstallUrlProtocol.HasURLProtocol();
		if(not has_protocol) then
			if(	ParaGlobal.WriteRegStr("HKCR", protocol_name, "", "URL:ParaEngine") and 
				ParaGlobal.WriteRegStr("HKCR", protocol_name, "URL Protocol", "") and
				ParaGlobal.WriteRegStr("HKCR", protocol_name.."/shell/open/command", "", shell_app_path)) then
				-- install protocol if we already have the rights such as on windows XP.
				LOG.std(nil, "System", "Url Protocol", "successfully installed URL protocol %s", protocol_name)
			else
				-- use launcher exe with admin rights to install the protocol.
				local shell_path = info.installer_path or app_path;
				shell_path = shell_path:gsub("/", "\\");
				LOG.std(nil, "System", "Url Protocol", "access may be denied. try using launcher %s to install %s", shell_path, protocol_name)
				ParaGlobal.ShellExecute("runas", shell_path, " urlprotocol=\"true\"", "", 1);
			end
		else
			LOG.std(nil, "System", "Url Protocol", "URL protocol %s already exist", protocol_name)
		end
	end
end

-- this is application level function. 
-- @param callbackFunc: only called when protocol is installed. 
function InstallUrlProtocol.CheckInstallWithUI(callbackFunc)
	if(InstallUrlProtocol.HasURLProtocol()) then
		if(callbackFunc) then
			callbackFunc();
		end
		return true;
	else
		if(System.options.IsWebBrowser) then
			_guihelper.MessageBox("抱歉, Web版暂时不支持分享功能，请使用旁边的其他的分享方式或使用客户端版本运行游戏");
		else
			_guihelper.MessageBox("开启分享功能， 需要您先同意激活haqi协议! 是否现在就激活？<br/>(您的防火墙软件或操作系统可能会弹出确认提示， 请放心点击确认或允许)", function(res)
				if(res and res == _guihelper.DialogResult.Yes) then
					-- pressed YES
					InstallUrlProtocol.InstallURLProtocol(function(bSuccess)
						if(bSuccess) then
							_guihelper.MessageBox("恭喜！您已经成功激活了分享功能!");
							if(callbackFunc) then
								callbackFunc();
							end
						else
							_guihelper.MessageBox("如果您不希望开启自动分享， 您依旧可以通过旁边的其他分享方式分享你的作品");
						end
					end)
				end
			end, _guihelper.MessageBoxButtons.YesNo);
		end
	end
end