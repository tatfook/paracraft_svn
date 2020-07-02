--[[
Title: Empty shell game loop file
Author(s):  LiXizhi
Date: 2009/5/3
Desc: this is mostly used to test modules by server. 
This loop file can be activated by bootstrapper file "config/bootstrapper_emptyshell.xml"
For server build, the command line to use this shell_loop is below. 
- under windows, it is "bootstrapper=\"config/bootstrapper_emptyshell.xml\"". 
- under linux shell script, it is 'bootstrapper="config/bootstrapper_emptyshell.xml"'
use the lib:
------------------------------------------------------------
For server build, the command line to use this shell_loop is below. 
- under windows, it is "bootstrapper=\"script/shell_loop_testrouter.lua\"". 
- under linux shell script, it is 'bootstrapper="script/shell_loop_testrouter.lua"'

------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");

main_state = nil;

local function activate()
	-- commonlib.echo("heart beat: 30 times per sec");
	if(main_state==0) then
		-- this is the main game loop
	elseif(main_state==nil) then
	NPL.StartNetServer("127.0.0.1", "60002");
	input = input or {};
	
		main_state=0;
		log("Hello World from script/testrouterclient.lua\n")
		
		-- add all public files
		NPL.LoadPublicFilesFromXML("config/NPLPublicFiles.xml");
		
		--NPL.AddNPLRuntimeAddress({host="192.168.0.51", port="60001", nid="Router1"})
		NPL.AddNPLRuntimeAddress({host="114.80.99.123", port="21001", nid="Router1"})
		
	    
		msg={nid=78975924,g_rts=1,content="/usr/local/server/im/user_table.txt"}
	    while(NPL.activate("Router1:script/apps/NPLRouter/IMDispatcher.lua", msg) ~=0 ) do end;
	    
		log("active end from script/testrouterclient.lua\n")
	end	
end
NPL.this(activate);