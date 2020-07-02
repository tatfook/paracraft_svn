--[[
Title: Empty shell game file
Author(s):  gosling
Date: 2010/6/3
------------------------------------------------------------
For server build, the command line to use this shell is below. 
- under windows, it is "bootstrapper=\"script/shell_compile.lua\"". 
- under linux shell script, it is 'bootstrapper="script/shell_compile.lua"'
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");

main_state = nil;

local function activate()
	-- commonlib.echo("heart beat: 30 times per sec");
	if(main_state==0) then
		-- this is the main game 
	elseif(main_state==nil) then
		main_state=0;
		log("Hello World from script/shell_compile.lua\n")
		
		NPL.load("(gl)script/installer/BuildParaWorld.lua");
		commonlib.BuildParaWorld.CompileNPLFiles(true)
		commonlib.echo("Compile END !");
		ParaGlobal.Exit(0);
	end	
end
NPL.this(activate);