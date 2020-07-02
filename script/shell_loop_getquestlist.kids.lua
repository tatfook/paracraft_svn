--[[
Title: Empty shell game file
Author(s):  spring
Date: 2012/11/21
------------------------------------------------------------
For server build, the command line to use this shell_loop is below. 
- under windows, it is "bootstrapper=\"script/shell_loop_getquestlist.kids.lua\"". 
- under linux shell script, it is 'bootstrapper="script/shell_loop_getquestlist.teen.lua"'
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");

main_state = nil;

local function activate()	
	if(main_state==0) then
		-- this is the main game loop
	elseif(main_state==nil) then
		main_state=0;
		log("Hello World from script/shell_loop_getquestlist.kids.lua\n")
		
		NPL.load("(gl)script/apps/Aries/Quest/QuestHelp2.lua");
		local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
		QuestHelp.BuildChart("kids",true);
		commonlib.echo("Get quest_chart.kids.csv saved END !");
		ParaGlobal.Exit(0);

	end	
end
NPL.this(activate);