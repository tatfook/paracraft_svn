-- game interface: default main game script loop
-- author: Li,Xizhi 
-- date: 2005-4-9
-- description: this script (gameinterface.lua) is activated every 0.5 sec by AI simulator.
--		it uses a finite state machine.State nil is the inital game state. state 0 is idle.

-- cmd line 
local function main(cmdline)
	if(not cmdline or cmdline == "") then
		return
	end

	local filename;
	filename, cmdline = cmdline:match("^%s*([^%s=]+)%s*(.*)$");
	if(filename and filename:match("lua$")) then
		log("redirect game loop to "..filename.."\n");
		ParaGlobal.SetGameLoop(filename);
		return 0;
	end
end

if(main(ParaEngine.GetAppCommandLine())) then
	return;
end

NPL.load("(gl)script/mainstate.lua"); -- this file can change the main loop or set the main_state value
NPL.load("(gl)script/lang/lang.lua"); -- localization init

local function activate()
	if(main_state==0) then
		-- this is the main game loop
	elseif(main_state==nil) then
	
	elseif(main_state=="ParaWorldEditor") then
		-- for paraworld editor
		ParaGlobal.SetGameLoop("(gl)script/apps/Aquarius/main_loop.lua");
	
	elseif(main_state=="demo_release") then
		-- for demo release. it uses a different game loop script.
		NPL.activate("(gl)script/demo4zju/main.lua", "");
		main_state=0;
	elseif(main_state=="kids") then
		-- for kids UI
		NPL.activate("(gl)script/kids/main.lua", "");
		main_state=0;
		
	elseif(main_state=="3DMapSystem") then
		-- for 3D map system
		NPL.activate("(gl)script/kids/3DMapSystem_main.lua", "");
		
	elseif(main_state=="testproject") then
		-- for kids UI
		NPL.activate("(gl)script/test_project.lua", "");
		main_state=0;	
	elseif(main_state=="andy_test") then
		-- for kids UI
		NPL.activate("(gl)script/andy_test.lua", "");
		main_state=0;	
	end	
end
NPL.this(activate);