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

local function UserLogin()
		----user login
		msg={action="setroster", game_nid=1007,g_rts=1,data_table={user_nid=14431795,signature="1@1007-14431795",roster_list="1234,224,12345671,123026,",last_online_time=1273511111,group_id=1},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
		msg={action="setroster", game_nid=1007,g_rts=1,data_table={user_nid=8509696,signature="1@1007-8509696", roster_list="2313,543,2341233,2341223,",last_online_time=1273511111,group_id=1},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
		msg={action="setroster", game_nid=1007,g_rts=1,data_table={user_nid=123026,signature="1@1007-123026", roster_list="7422,442,12345671,14431795,",last_online_time=1273511111,group_id=1},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
		msg={action="setroster", game_nid=1007,g_rts=1,data_table={user_nid=12345671,signature="1@1007-12345671", roster_list="541,96741,123026,14431795,",last_online_time=1273511111,group_id=1},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
end

local function UserLogin2()
		----user login
		--msg={action="setroster", game_nid=1007,g_rts=1,data_table={user_nid=2440510,signature="1@1007-2440510",roster_list="",last_online_time=1273563320,group_id=1,}}
		msg={tid="~1",nid="78975924",type=13,action="setroster",game_nid=1007,data_table={last_online_time=0,user_nid=78975924,signature="",roster_list="100337537,86117512,24027,88303331,16344,91289001,12464,38784066,50333182,97504333,29627,",group_id=1,},g_rts=4,}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
end

local function UserLogout()
		----user login
		msg={action="logout", game_nid=1007,g_rts=1,data_table={user_nid=123026,group_id=1,}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
end


local function SetPresence()
		----user login
		msg={action="setpresence", game_nid=1007,g_rts=1,data_table={user_nid=2440510,signature="1@1007-2440510",group_id=1,}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
end

local function QueryOnlineFriends()
		----
		msg={action="query_online_friends", game_nid=1007,g_rts=1,data_table={user_nid=12345671}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
end

local function QueryOnlineGroupUsers()
		----
		msg={action="query_online_group_users", game_nid=1007,g_rts=1,data_table={user_nid=12345671,group_id=1}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
end


local function AddFriend()
	    --add friend
	    msg={action="addfriend",game_nid=1007,g_rts=4,data_table={user_nid=12345674, friend_nid=777774}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    
	    msg={action="addfriend",game_nid=1007,g_rts=4,data_table={user_nid=12345674, friend_nid=12345671}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
end

local function GameHeart()
	    
	    --game heart
	    msg={action="gameheart",game_nid=1007,g_rts=2,data_table={roster_list="1234,224,78975923,8894,12345,"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    msg={action="gameheart",game_nid=1007,g_rts=3,data_table={roster_list="1236,"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
end

local function DelFriend()		
	    --del friend
	    msg={action="delfriend",game_nid=1007,g_rts=4,data_table={user_nid=78975924, friend_nid=224}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    msg={action="delfriend",game_nid=1007,g_rts=4,data_table={user_nid=78975924, friend_nid=78975922}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    msg={action="delfriend",game_nid=1007,g_rts=4,data_table={user_nid=78975924, friend_nid=1111}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    msg={action="delfriend",game_nid=1007,g_rts=4,data_table={user_nid=78975922, friend_nid=78975924}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;

end

local function KickInactiveUser()
		--kick inactive user
		msg={action="kick_inactive_user",data_table={time_span=5,}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
end


local function SendMessage()	    
		--sendmsg
	    msg={action="sendmsg",game_nid=1007,g_rts=1,data_table={src_nid=14431795,dest_nid=8509696,msg="send to online user,not friend!"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    msg={action="sendmsg",game_nid=1007,g_rts=1,data_table={src_nid=14431795,dest_nid=123026,msg="send to online user,friend!"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    msg={action="sendmsg",game_nid=1007,g_rts=1,data_table={src_nid=14431795,dest_nid=2440510,msg="send to offline user,friend!"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
end

local function SendMessage2()
		--sendmsg
	    msg={action="sendmsg",game_nid=1007,g_rts=1,data_table={src_nid=14431795,dest_nid=2440510,msg="send to offline msg1!"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    msg={action="sendmsg",game_nid=1007,g_rts=1,data_table={src_nid=14431795,dest_nid=2440510,msg="send to offline msg2!"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    msg={action="sendmsg",game_nid=1007,g_rts=1,data_table={src_nid=14431795,dest_nid=2440510,msg="send to offline msg3!"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    msg={action="sendmsg",game_nid=1007,g_rts=1,data_table={src_nid=14431795,dest_nid=2440510,msg="send to offline msg4!"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    msg={action="sendmsg",game_nid=1007,g_rts=1,data_table={src_nid=14431795,dest_nid=2440510,msg="send to offline msg5!"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    msg={action="sendmsg",game_nid=1007,g_rts=1,data_table={src_nid=14431795,dest_nid=2440510,msg="send to offline msg6!"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    msg={action="sendmsg",game_nid=1007,g_rts=1,data_table={src_nid=14431795,dest_nid=2440510,msg="send to offline msg7!"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    msg={action="sendmsg",game_nid=1007,g_rts=1,data_table={src_nid=14431795,dest_nid=2440510,msg="send to offline msg8!"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
end

local function TestNoGroupID()
		----user login
		msg={action="setroster",game_nid=1007,g_rts=1,data_table={user_nid=2440510, roster_list="",last_online_time=1273563320,group_id=1,}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    --be sure that group id is not loaded.
		--send group msg
		msg={action="sendgroupmsg",game_nid=1007,g_rts=1,data_table={group_id=1,user_nid=14431795,msg="test send group msg"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
	    
end

local function SetGroup()
		--set group
		msg={action="setgroup",game_nid=1007,g_rts=1,data_table={user_nid=14431795,group_id=1,member_list="8509696,14431795,115227091,123026,104912641,2440510,117399752,103247723,107693230,82978380,7716995,48147818,111578236,112871354,1594009,90261448,31455170,71772224,43698577,34220656,106092037,104568172,113028464,17407670,67502578,10823855,128137326,17263889,149804830,12250495,63873436,111537922,15034342,1900989,53023403,11120750,109388454,133799576,7601292,76596555,92119583,36085422,116926576,79861086,9779724,7754902,56239477,37417275,69331,117522930,137362873,127692548,9197786,148833929,74392174,73041490,108665445,142240308,140695035,1851054,"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
end

local function AddGroupMember()
		--add member
		msg={action="addmember",game_nid=1007,g_rts=1,data_table={admin_nid=14431795,group_id=1,add_user_nid=115227091}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
end

local function DelGroupMember()
		--del member
		msg={action="delmember",game_nid=1007,g_rts=1,data_table={admin_nid=123026,group_id=1,del_user_nid=12345671}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
end

local function SendGroupMsg()
		--send group msg
		msg={action="sendgroupmsg",game_nid=1007,g_rts=1,data_table={group_id=1,user_nid=14431795,msg="test send group msg"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
end

local function PrintTable()
	    --print data table
		msg={action="printtable",game_nid=1007,g_rts=1,data_table={type="user_index",path="temp/test/user_index.txt"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
		msg={action="printtable",game_nid=1007,g_rts=1,data_table={type="user_table",path="temp/test/user_table.txt"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
		msg={action="printtable",game_nid=1007,g_rts=1,data_table={type="roster_table",path="temp/test/roster_table.txt"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
		msg={action="printtable",game_nid=1007,g_rts=1,data_table={type="group_index",path="temp/test/group_index.txt"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
		msg={action="printtable",game_nid=1007,g_rts=1,data_table={type="group_table",path="temp/test/group_table.txt"}}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;
end

local function QueryTeam()
		msg={action="queryteam",game_nid=1007,g_rts=1,data_table={user_nid=123026,queried_nid=12345671,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
end

local function AddToTeam()
		msg={action="addteam_member",game_nid=1007,g_rts=1,data_table={user_nid=123026,dest_nid=12345671,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
end

local function DelFromTeam()
		msg={action="delteam_member",game_nid=1007,g_rts=1,data_table={user_nid=12345671,dest_nid=123026,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
end

local function SetTeamLeader()
		msg={action="setteam_leader",game_nid=1007,g_rts=1,data_table={user_nid=12345671,dest_nid=123026,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
end

local function SendTeamMsg()
		msg={action="sendteammsg",game_nid=1007,g_rts=1,data_table={user_nid=123026,msg="test send team msg",},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
end

local function TeamInvite()
		msg={action="team_invite",game_nid=1007,g_rts=1,data_table={user_nid=123026,dest_nid=8509696,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
end

local function TeamJoin()
		msg={action="team_join",game_nid=1007,g_rts=1,data_table={user_nid=8509696,dest_nid=123026,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
end

local function TestCase1()
		-- Add Team Member. TeamLeader 123026, member 12345671, 14431795
		msg={action="addteam_member",game_nid=1007,g_rts=1,data_table={user_nid=123026,dest_nid=12345671,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
		msg={action="addteam_member",game_nid=1007,g_rts=1,data_table={user_nid=123026,dest_nid=14431795,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
		-- Query Team. user 8509696 query user 12345671's team. should return as {123026,12345671,14431795,}
		msg={action="queryteam",game_nid=1007,g_rts=1,data_table={user_nid=8509696,queried_nid=12345671,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
		-- Query Team. user 14431795 query user 8509696's team. should return as {}  
		msg={action="queryteam",game_nid=1007,g_rts=1,data_table={user_nid=14431795,queried_nid=8509696,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
		-- Set Team Leader. OldTeamLeader 123026 transfer its position to user 14431795, new team should be {12345671,123026,14431795,}
		msg={action="setteam_leader",game_nid=1007,g_rts=1,data_table={user_nid=123026,dest_nid=12345671,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	

		-- Query Team. user 12345671 query user 12345671's team. should return as {12345671,123026,14431795,}
		msg={action="queryteam",game_nid=1007,g_rts=1,data_table={user_nid=12345671,queried_nid=12345671,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
		-- Query Team. user 123026 query user 123026's team. should return as {12345671,123026,14431795,}
		msg={action="queryteam",game_nid=1007,g_rts=1,data_table={user_nid=123026,queried_nid=123026,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
		-- Query Team. user 14431795 query user 14431795's team. should return as {12345671,123026,14431795,}
		msg={action="queryteam",game_nid=1007,g_rts=1,data_table={user_nid=14431795,queried_nid=14431795,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	

		-- Set Team Leader. OldTeamLeader 123026 transfer its position to user 14431795, new team should be {14431795,123026,12345671,}
		msg={action="setteam_leader",game_nid=1007,g_rts=1,data_table={user_nid=12345671,dest_nid=14431795,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	

		-- Delete Team Member. TeamLeader 14431795 del user 14431795, new team should be {14431795,12345671,}
		msg={action="delteam_member",game_nid=1007,g_rts=1,data_table={user_nid=123026,dest_nid=123026,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
		-- Send Team Msg,
		msg={action="sendteammsg",game_nid=1007,g_rts=1,data_table={user_nid=123026,msg="test send team msg",},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
		-- Team Invite, user 123026 send an invite msg to user 8509696
		msg={action="team_invite",game_nid=1007,g_rts=1,data_table={user_nid=123026,dest_nid=8509696,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
		-- Team Join, user 8509696 send an apply msg to user 123026's TeamLeader
		msg={action="team_join",game_nid=1007,g_rts=1,data_table={user_nid=8509696,dest_nid=123026,},}
	    while(NPL.activate("imserver:script/apps/IMServer/IMServer.lua", msg) ~=0 ) do end;	
end

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
		
		-- NPL.AddNPLRuntimeAddress({host="192.168.0.229", port="64001", nid="IMServer1"})
		NPL.AddNPLRuntimeAddress({host="127.0.0.1", port="64001", nid="imserver"})
		--SetGroup();
		UserLogin();
		--UserLogin2(); 		
		TestCase1();
		--UserLogout()
		--SetPresence()
		--AddFriend()
		--GameHeart()
		--DelFriend()
		--
		--QueryOnlineFriends();
		--QueryOnlineGroupUsers();
		--SendMessage2();
		--SendGroupMsg();
		--DelGroupMember();
		--AddGroupMember();
		--TestNoGroupID();
		--KickInactiveUser();
		--PrintTable();
		
		log("active end from script/shell_loop_imserverclient.lua\n")
	end	
end
NPL.this(activate);

