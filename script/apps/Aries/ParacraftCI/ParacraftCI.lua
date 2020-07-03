--[[
Title: 
Author: chenjinxian
Date: 2020/7/1
Desc: 
-----------------------------------------------
local ParacraftCI = NPL.load("(gl)script/apps/Aries/ParacraftCI/ParacraftCI.lua");
ParacraftCI.StaticInit();
-----------------------------------------------
]]

local ParacraftCI = NPL.export();

ParacraftCI.UpdateScript = 1;
ParacraftCI.UpdateAllMod = 2;
ParacraftCI.UpdateWorldShare = 3;
ParacraftCI.UpdateBuildMod = 4;
ParacraftCI.Finished = 5;
ParacraftCI.ShowBranches = 6;
ParacraftCI.UpdateState = 0;
ParacraftCI.WorldShareBranches = {};
ParacraftCI.GGSBranches = {};

function ParacraftCI.StaticInit()
	ParacraftCI.Reset();
	commonlib.TimerManager.SetTimeout(function()  
		local ci = ParaEngine.GetAppCommandLineByParam("open_ci", false);
		if (ci) then
			ParacraftCI.ShowPage();
		end
	end, 2000)
end

local page;
function ParacraftCI.OnInit()
	page = document:GetPageCtrl();
end
function ParacraftCI.ShowPage(state)
	if (page) then
		page:CloseWindow();
	end
	ParacraftCI.UpdateState = state or 0;
	local params = {
		url = "script/apps/Aries/ParacraftCI/ParacraftCI.html",
		name = "ParacraftCI.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		enable_esc_key = true,
		app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
		directPosition = true,
		align = "_ct",
		x = -480 / 2,
		y = -240 / 2,
		width = 480,
		height = 240,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);

end

function ParacraftCI.Reset()
	ParacraftCI.UpdateState = 0;
	ParacraftCI.WorldShareBranches = {};
	ParacraftCI.GGSBranches = {};
end

function ParacraftCI.OnClose()
	ParacraftCI.Reset();
	page:CloseWindow();
end

function ParacraftCI.GetStateText()
	if (ParacraftCI.UpdateState > 0 and ParacraftCI.UpdateState < ParacraftCI.Finished) then
		return ParacraftCI.StateText[ParacraftCI.UpdateState];
	else
		return L"准备更新";
	end
end

function ParacraftCI.StartUpdate()
	local update_script = page:GetUIValue("UpdateScript", true);
	local update_mod = page:GetUIValue("UpdateMod", true);
	local update_worldshare= page:GetUIValue("UpdateWorldShare", true);
	local update_GGS= page:GetUIValue("UpdateGeneralGameServerMod", true);
	if (update_script) then
		ParacraftCI.GetScript();
	end
	if (update_mod) then
		ParacraftCI.GetBuildInMod();
		ParacraftCI.GetAllMode();
		return;
	end
	if (update_worldshare) then
		local cmd = [[
			pushd "ParacraftBuildinMod/npl_packages/WorldShare"
			git pull
			popd
		]]
		local result = System.os.run(cmd);
	end
	if (update_GGS) then
		local cmd = [[
			pushd "ParacraftBuildinMod/npl_packages/GeneralGameServerMod"
			git pull
			popd
		]]
		local result = System.os.run(cmd);
	end
	if (update_worldshare) then
		ParacraftCI.ShowWorldShareBranches()
	end
	if (update_GGS) then
		ParacraftCI.ShowGGSBranches()
	end
end

function ParacraftCI.ExitApp()
	NPL.load("(gl)script/apps/Aries/Creator/Game/GameDesktop.lua");
	local Desktop = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop");
	Desktop.ForceExit(false);
end

function ParacraftCI.GetScript()
	local cmd = [[
		@echo off 
		CALL :InstallPackage paracraft_svn https://github.com/tatfook/paracraft_svn
		EXIT /B %ERRORLEVEL%

		:InstallPackage
		if exist "%1\README.md" (
			pushd %1
			git reset --hard
			git pull
			popd
		) else (
			rmdir /s /q "%CD%\%1"
			git clone %2
		)
		EXIT /B 0
	]]

	local result = System.os.run(cmd);
	if (result) then
		return true;
	end
end

function ParacraftCI.GetBuildInMod()
	local cmd = [[
		@echo off 
		CALL :InstallPackage ParacraftBuildinMod https://github.com/tatfook/ParacraftBuildinMod
		EXIT /B %ERRORLEVEL%

		:InstallPackage
		if exist "%1\README.md" (
			pushd %1
			git reset --hard
			git pull
			popd
		) else (
			rmdir /s /q "%CD%\%1"
			git clone %2
		)
		EXIT /B 0
	]]

	local result = System.os.run(cmd);
	if (result) then
		return true;
	end
end

function ParacraftCI.GetAllMode()
	local cmd = [[
		@echo off 
		pushd "ParacraftBuildinMod"
		if not exist "npl_packages" ( mkdir npl_packages )

		pushd "npl_packages"

		CALL :InstallPackage AutoUpdater https://github.com/NPLPackages/AutoUpdater
		CALL :InstallPackage STLExporter https://github.com/LiXizhi/STLExporter
		CALL :InstallPackage BMaxToParaXExporter https://github.com/tatfook/BMaxToParaXExporter

		CALL :InstallPackage NPLCAD https://github.com/tatfook/NPLCAD
		CALL :InstallPackage NplCadLibrary https://github.com/NPLPackages/NplCadLibrary
		CALL :InstallPackage ModelVoxelizer https://github.com/NPLPackages/ModelVoxelizer

		CALL :InstallPackage NplCad2 https://github.com/tatfook/NplCad2

		CALL :InstallPackage WorldShare https://github.com/tatfook/WorldShare
		CALL :InstallPackage ExplorerApp https://github.com/tatfook/ExplorerApp
		CALL :InstallPackage EMapMod https://github.com/tatfook/EMapMod
		CALL :InstallPackage CodeBlockEditor https://github.com/tatfook/CodeBlockEditor
		CALL :InstallPackage PluginBlueTooth https://github.com/NPLPackages/PluginBlueTooth
		CALL :InstallPackage GoogleAnalytics https://github.com/NPLPackages/GoogleAnalytics
		CALL :InstallPackage ParaWorldClient https://github.com/tatfook/ParaworldClient

		CALL :InstallPackage PyRuntime https://github.com/tatfook/PyRuntime

		CALL :InstallPackage NplMicroRobot https://github.com/tatfook/NplMicroRobot
		CALL :InstallPackage HaqiMod https://github.com/tatfook/HaqiMod
		CALL :InstallPackage GeneralGameServerMod https://github.com/tatfook/GeneralGameServerMod

		popd
		popd

		EXIT /B %ERRORLEVEL%

		:InstallPackage
		if exist "%1\README.md" (
			pushd %1
			git reset --hard
			git pull
			popd
		) else (
			rmdir /s /q "%CD%\%1"
			git clone %2
		)
		EXIT /B 0
	]]

	local result = System.os.run(cmd);
	if (result) then
		ParacraftCI.ShowWorldShareBranches();
		ParacraftCI.ShowGGSBranches();
	end
end

function ParacraftCI.ShowWorldShareBranches()
	local cmd = [[
		pushd "ParacraftBuildinMod/npl_packages/WorldShare"
		git branch -r
		popd
	]]
	local result = System.os.run(cmd);
	if (result) then
		ParacraftCI.WorldShareBranches = commonlib.split(result, "\n");

		ParacraftCI.UpdateState = ParacraftCI.ShowBranches;
		if (page) then
			page:Refresh(0);
			page:SetValue("WorldShare", ParacraftCI.WorldShareBranches[1]);
			if (#ParacraftCI.GGSBranches > 0) then
				page:SetValue("GeneralGameServerMod", ParacraftCI.GGSBranches[1]);
			end
		end
	end
end

function ParacraftCI.ShowGGSBranches()
	local cmd = [[
		pushd "ParacraftBuildinMod/npl_packages/GeneralGameServerMod"
		git branch -r
		popd
	]]
	local result = System.os.run(cmd);
	if (result) then
		ParacraftCI.GGSBranches = commonlib.split(result, "\n");

		ParacraftCI.UpdateState = ParacraftCI.ShowBranches;
		if (page) then
			page:Refresh(0);
			page:SetValue("GeneralGameServerMod", ParacraftCI.GGSBranches[1]);
			if (#ParacraftCI.WorldShareBranches > 0) then
				page:SetValue("WorldShare", ParacraftCI.WorldShareBranches[1]);
			end
		end
	end
end

function ParacraftCI.GetWorldShareBranches()
	local branches = {};
	for i = 1, #ParacraftCI.WorldShareBranches do
		local name = ParacraftCI.WorldShareBranches[i];
		table.insert(branches, {text=name, value=name});
	end
	return branches;
end

function ParacraftCI.GetGGSBranches()
	local branches = {};
	for i = 1, #ParacraftCI.GGSBranches do
		local name = ParacraftCI.GGSBranches[i];
		table.insert(branches, {text=name, value=name});
	end
	return branches;
end

function ParacraftCI.OnSelectWorldShare(name, value)
	page:SetValue("WorldShare", value);
end

function ParacraftCI.OnSelectGGS(name, value)
	page:SetValue("GeneralGameServerMod", value);
end

function ParacraftCI.SwitchWorldShare()
	local branch = page:GetValue("WorldShare", "master");
	if (branch and #branch > 0) then
		local name = string.sub(branch, string.find(branch, '/')+1);
		if (string.find(name, "master")) then
			name = "master";
		end
		local cmd = string.format([[
			pushd "ParacraftBuildinMod/npl_packages/WorldShare"
			git checkout %s
			git pull
			popd
		]], name);
		local result = System.os.run(cmd);
		if (result) then
			return true;
		end
	end
end

function ParacraftCI.SwitchGGS()
	local branch = page:GetValue("GeneralGameServerMod", "master");
	if (branch and #branch > 0) then
		local name = string.sub(branch, string.find(branch, '/')+1);
		if (string.find(name, "master")) then
			name = "master";
		end
		local cmd = string.format([[
			pushd "ParacraftBuildinMod/npl_packages/GeneralGameServerMod"
			git checkout %s
			git pull
			popd
		]], name);
		local result = System.os.run(cmd);
		if (result) then
			return true;
		end
	end
end

function ParacraftCI.BuildMod()
	local result = ParacraftCI.SwitchWorldShare() and ParacraftCI.SwitchGGS();
	if (result) then
		local build = [[
			@echo off 
			rem author: LiXizhi   date:2017.5.1

			rem update and install packages from git
			rem call InstallPackages.bat

			rem remove old redist folder

			pushd "ParacraftBuildinMod"

			rmdir Mod  /s /q
			rmdir textures  /s /q
			rmdir script  /s /q
			rmdir build  /s /q
			rmdir ParacraftBuildinMod  /s /q
			rmdir npl_mod  /s /q
			mkdir Mod
			mkdir npl_mod
			mkdir textures
			mkdir script
			mkdir ParacraftBuildinMod
			rm ParacraftBuildinMod.zip

			pushd "npl_packages"

			CALL :BuddlePackage AutoUpdater
			CALL :BuddlePackage STLExporter
			CALL :BuddlePackage BMaxToParaXExporter

			CALL :BuddlePackage NPLCAD
			CALL :BuddlePackage NplCadLibrary
			CALL :BuddlePackage ModelVoxelizer

			CALL :BuddlePackage NplCad2
			CALL :BuddlePackage NplBrowserScript

			CALL :BuddlePackage WorldShare
			CALL :BuddlePackage ExplorerApp
			CALL :BuddlePackage EMapMod
			CALL :BuddlePackage CodeBlockEditor
			CALL :BuddlePackage PluginBlueTooth
			CALL :BuddlePackage GoogleAnalytics
			CALL :BuddlePackage ParaWorldClient

			CALL :BuddlePackage PyRuntime

			CALL :BuddlePackage NplMicroRobot
			CALL :BuddlePackage HaqiMod
			CALL :BuddlePackage GeneralGameServerMod

			popd

			rem copy files to ParacraftBuildinMod folder for packaging
			if exist Mod ( xcopy /s /y Mod  ParacraftBuildinMod\Mod\ )
			if exist npl_mod ( xcopy /s /y npl_mod  ParacraftBuildinMod\npl_mod\ )
			if exist textures ( xcopy /s /y textures  ParacraftBuildinMod\textures\ )
			if exist script ( xcopy /s /y script  ParacraftBuildinMod\script\ )
			xcopy /y package.npl  ParacraftBuildinMod\

			call "7z.exe" a ParacraftBuildinMod.zip ParacraftBuildinMod\
			xcopy /y/r ParacraftBuildinMod.zip  ..\
			rem start explorer.exe "%~dp0"

			popd

			EXIT /B %ERRORLEVEL%

			rem Mod, script, texture folder into root directory
			:BuddlePackage
				xcopy /s /y %1\Mod  %1\..\..\Mod\
				if exist %1\Mod ( xcopy /s /y %1\Mod  %1\..\..\Mod\ )
				if exist %1\script ( xcopy /s /y %1\script  %1\..\..\script\ )
				if exist %1\textures ( xcopy /s /y %1\textures  %1\..\..\textures\ )
				if exist %1\npl_mod ( xcopy /s /y %1\npl_mod  %1\..\..\npl_mod\ )

			EXIT /B 0
		]];
		result = System.os.run(build);
		if (result) then
			ParacraftCI.ShowPage(ParacraftCI.Finished);
		end
	end
end