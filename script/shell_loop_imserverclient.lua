--[[
Title: shell loop file
Author(s):  gosling
Date: 2010/4/27
Desc: this is mostly used to test modules by server. 
This loop file can be activated by bootstrapper file "config/shell_loop_imserverclient.xml"
For server build, the command line to use this shell_loop is below. 
- under windows, it is "bootstrapper=\"config/shell_loop_imserverclient.xml\"". 
- under linux shell script, it is 'bootstrapper="config/shell_loop_imserverclient.xml"'
use the lib:
------------------------------------------------------------
For server build, the command line to use this shell_loop is below. 
- under windows, it is "bootstrapper=\"config/shell_loop_imserverclient.xml\"". 
- under linux shell script, it is 'bootstrapper="config/shell_loop_imserverclient.xml"'
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
		log("Hello World from script/shell_loop_imserverclient.lua\n")
		
		-- add all public files
		NPL.LoadPublicFilesFromXML("config/NPLPublicFiles.xml");
		
		NPL.AddNPLRuntimeAddress({host="192.168.0.229", port="64001", nid="imserver"})
		
		--user login
		msg={action="setroster",user_nid=78975924, game_nid=1001,g_rts=1,roster_list="1234,224,12345671,78975922,"}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
		msg={action="setroster",user_nid=78975923, game_nid=1001,g_rts=1,roster_list="2313,543,2341233,2341223,"}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
		msg={action="setroster",user_nid=78975922, game_nid=1001,g_rts=1,roster_list="7422,442,12345671,78975924,"}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
		msg={action="setroster",user_nid=12345671, game_nid=1001,g_rts=1,roster_list="541,96741,78975922,78975924,"}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    --
	    ----print data table
		--msg={action="printtable",game_nid=1001,g_rts=1,path="/usr/local/server/im/user_table1.txt"}
	    --while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    --
	    ----add friend
	    --msg={action="addfriend",user_nid=12345674, friend_nid=777774,game_nid=1004,g_rts=4}
	    --while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    --
	    ----print data table
		--msg={action="printtable",game_nid=1001,g_rts=1,path="/usr/local/server/im/user_table2.txt"}
	    --while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    --
	    --msg={action="addfriend",user_nid=12345674, friend_nid=12345671,game_nid=1004,g_rts=4}
	    --while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    --
	    ----del friend
	    --msg={action="delfriend",user_nid=78975924, friend_nid=224,game_nid=1004,g_rts=4}
	    --while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    --msg={action="delfriend",user_nid=78975924, friend_nid=78975922,game_nid=1004,g_rts=4}
	    --while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    --msg={action="delfriend",user_nid=78975924, friend_nid=1111,game_nid=1004,g_rts=4}
	    --while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    --msg={action="delfriend",user_nid=78975922, friend_nid=78975924,game_nid=1004,g_rts=4}
	    --while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    --
	    ----print data table
		--msg={action="printtable",game_nid=1001,g_rts=1,path="/usr/local/server/im/user_table3.txt"}
	    --while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    --
	    ----game heart
	    --msg={action="gameheart",game_nid=1002,g_rts=2,roster_list="1234,224,78975923,8894,12345,"}
	    --while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    --msg={action="gameheart",game_nid=1003,g_rts=3,roster_list="1236,"}
	    --while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    --
		----sendmsg
	    --msg={action="sendmsg",src_nid=78975924,dest_nid=78975923,msg="send to online user,not friend!"}
	    --while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    --msg={action="sendmsg",src_nid=78975924,dest_nid=1234,msg="send to online user,friend!"}
	    --while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    --msg={action="sendmsg",src_nid=78975924,dest_nid=564,msg="send to offline user,friend!"}
	    --while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    
	    --print data table
		msg={action="printtable",game_nid=1001,g_rts=1,path="/usr/local/server/im/user_table.txt"}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    
		log("active end from script/shell_loop_imserverclient.lua\n")
	end	
end
NPL.this(activate);