--[[
Title: The demo main loop
Author(s): LiYu (art UI), LiXizhi(code logic)
Date: 2006/1/18
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/demo4zju/main.lua");
------------------------------------------------------------
]]
ParaGlobal.SetGameLoop("(gl)script/demo4zju/main.lua");

NPL.load("(gl)script/demo4zju/demoUI.lua");
NPL.load("(gl)script/kids/UI_startup.lua");

main_state=nil;
local function activate()
	if(main_state==0) then
		-- this is the main game loop
	elseif(main_state==nil) then
		-- global assets and init scene loading
		ParaAsset.OpenArchive ("xmodels/ParaWorldDemo.zip"); -- open mpg archive
		ParaAsset.OpenArchive ("xmodels/character.zip");
		-- ParaAsset.LoadSound ("click", "sound/PopupInfo.wav", true);
		ParaAsset.LoadStaticMesh ("skybox", "xmodels/skyboxSnow.x");
		ParaScene.CreateSkyBox ("MySkyBox", "skybox", 160,160,160, 0);
		ParaScene.SetFog(true, "0.7 0.7 1.0", 40.0, 120.0, 0.7);
		
		DemoUI.CreateStartupWnd();
		main_state=0;
		log("demo loaded\n");
	end
	
end
NPL.this(activate);
