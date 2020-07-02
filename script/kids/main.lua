--[[
Title: The Kids Movie main loop
Author(s):  LiXizhi(code logic)
Date: 2006/1/26
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/kids/main.lua");
------------------------------------------------------------
]]
application_name = "kidsmovie";

NPL.load("(gl)script/lang/lang.lua"); -- localization init
CommonCtrl.Locale.AutoLoadFile("script/lang/KidsUI-zhCN.lua");
CommonCtrl.Locale.AutoLoadFile("script/lang/KidsUI-enUS.lua");

ParaGlobal.SetGameLoop("(gl)script/kids/main.lua");
NPL.load("(gl)script/kids/kids_init.lua");
--NPL.load("(gl)script/kids/3DMapSystemApp/AppManager.lua");

ParaUI.SetCursorFromFile(":IDR_DEFAULT_CURSOR");

main_state=nil;

if(not KidsUI) then KidsUI={}; end

local function activate()
	if(main_state==0) then
		-- this is the main game loop
	elseif(main_state==nil) then	
		-- global assets and init scene loading
		if(not ReleaseBuild) then
			ParaAsset.OpenArchive ("xmodels/ParaWorldDemo.zip"); -- open archive
			ParaAsset.OpenArchive ("xmodels/character.zip");-- open archive
		else
			--ParaAsset.OpenArchive ("xmodels/main.zip"); -- open archive
		end	
		KidsUI.LoadDefaultKidsUITheme();
		KidsUI.ReBindEventHandlers();
		
		-- show logo
		KidsUI.ShowLogoPage(1,150);
		main_state=0;
	elseif(main_state=="startup") then
		KidsUI.ReBindEventHandlers();
		
		KidsUI.CreateStartupWnd();
		-- disable network unpon restart
		ParaNetwork.EnableNetwork(false, "","");
		
		-- NOTE by Andy: New version of audio engine interface
		-- EnableAudioBank will initialize the target audio bank for playing
		-- Bank resource will be released by audio engine by default when exit
		-- Classic call of EnableAudioBank and DisableAudioBank is:
			-- Call EnableAudioBank(name) when entering a new world.
			-- Call DisableAudioBank(name) when leaving an existing world.
		-- More details, please refer to the audio engine manual.
		--if(ParaEngine.IsDebugging() == false) then
			ParaAudio.EnableAudioBank("Kids");
		--end
		
		-- Play back ground music
		ParaSettingsUI.StopCategories("3DSound", "Ambient", "Default", "Dialog", "Interactive", "Music", "UI");--[["Background",]]
		ParaAudio.PlayBGMusic("Kids_Title");
		
		main_state=0;
	end
	
end

NPL.this(activate);
