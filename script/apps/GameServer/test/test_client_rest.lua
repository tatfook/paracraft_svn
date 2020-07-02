--[[
Author: LiXizhi
Date: 2009-7-20
Desc: this emulate a game client. it connect to the game server and test all of its test api
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/test/test_client_rest.lua");
GameServer.test_client:start("script/apps/GameServer/test/local.GameClient.config.xml");
GameServer.test_client:test_Home_Get_sync_many();
GameServer.test_client:test_AuthUser();
GameServer.test_client:SendRequest("AuthUser", {UserName="a", Password=""});
-----------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/rest_client.lua");
local test_client = commonlib.gettable("GameServer.rest.client")
commonlib.setfield("GameServer.test_client", test_client)

-- create wrapper functions
GameServer.rest.client.CreateRESTJsonWrapper("test.auth.AuthUser", "AuthUser")
GameServer.rest.client.CreateRESTJsonWrapper("test.auth.Ping", "Ping");

GameServer.rest.client.CreateRESTJsonWrapper("test.homeland.home.GetHomeInfo", "Home.Get");

-- test AuthUser
function test_client:test_AuthUser(request)
	-- invoke with HTTP POST, where the second parameter is rpc instance name. the same instance share the same callback function. 
	test.auth.AuthUser({username="LiXizhi", password="1234567"}, "test", function(msg)  
		commonlib.applog("client get reply");commonlib.echo(msg);
		self.user_nid = msg.nid;
	end)
end

-- test home.get
function test_client:test_Home_Get()
	-- first authenticate and then call the test 
	local function test_me()
    	test.homeland.home.GetHomeInfo({nid=self.user_nid}, "test", function(msg)  
			commonlib.applog("client get reply");commonlib.echo(msg);	
		end);
	end
	if(self.user_nid) then
		test_me();
	else
		test.auth.AuthUser({username="LiXizhi", password="1234567"}, "test", function(msg)  
			commonlib.applog("client get reply");commonlib.echo(msg);
			self.user_nid = msg.nid;
			test_me();
		end)
	end	
end

--[[ test Ping with massive concurrent requests
test environment: servers(game, router, db) processes are on the same linux machine, sql is on another machine.
test result:
	db worker == 4
		total time: 5219
		request per second: 1916
]]
function test_client:test_Ping_async_many()
	-- first authenticate and then call the test 
	local test_count = 0;
	local LAPC_stats = {
		start_time = 0,
		end_time = 0,
		pool_size = 100,  -- how many concurrent pools
		max_count = 10000, -- how many messages to send
	}
	LAPC_stats.start_time = ParaGlobal.timeGetTime();
	
	-- test_client.debug_stream = true;
	
	local function test_me()
	    local i = 0;
	    local received_count = 0;
	    for i = 1, LAPC_stats.pool_size do
			local PoolName = "test" .. i;
			
			-- callback func
			local function call_back_func()
				received_count = received_count + 1;
				log(tostring(received_count).." replied\n");
				
				--commonlib.applog(PoolName);
				--commonlib.echo(msg);
				
				if(received_count == LAPC_stats.max_count) then
					LAPC_stats.end_time=ParaGlobal.timeGetTime();
					commonlib.log("---------------------result------------------\n")
					commonlib.log("total time: %d\n", LAPC_stats.end_time - LAPC_stats.start_time);
					commonlib.log("request per second: %d\n", 1000*LAPC_stats.max_count/((LAPC_stats.end_time - LAPC_stats.start_time)));
				elseif(received_count < LAPC_stats.max_count) then
					test.auth.Ping({}, PoolName, call_back_func);
				end
			end
			test.auth.Ping({}, PoolName, call_back_func);
		end
	end
	if(self.user_nid) then
		test_me();
	else
		test.auth.AuthUser({username="LiXizhi", password="1234567"}, "test", function(msg)  
			commonlib.applog("client get reply");commonlib.echo(msg);
			self.user_nid = msg.nid;
			test_me();
		end)
	end	
end


--[[ test Homt.Get with massive concurrent requests
test environment: servers(game, router, db) processes are on the same linux machine, sql is on another machine.
test result:
	db worker == 4
		total time: 6516
		request per second: 1534
	db worker == 1
		total time: 15625
		request per second: 640
]]
function test_client:test_Home_Get_async_many()
	-- first authenticate and then call the test 
	local test_count = 0;
	local LAPC_stats = {
		start_time = 0,
		end_time = 0,
		pool_size = 500,  -- how many concurrent pools
		max_count = 10000, -- how many messages to send
	}
	LAPC_stats.start_time = ParaGlobal.timeGetTime();
	
	local function test_me()
	    local i = 0;
	    local received_count = 0;
	    for i = 1, LAPC_stats.pool_size do
			local PoolName = "test" .. i;
			
			-- callback func
			local function call_back_func()
				received_count = received_count + 1;
				log(tostring(received_count).." replied\n");
				
				--commonlib.applog(PoolName);
				--commonlib.echo(msg);
				
				if(received_count == LAPC_stats.max_count) then
					LAPC_stats.end_time=ParaGlobal.timeGetTime();
					commonlib.log("---------------------result------------------\n")
					commonlib.log("total time: %d\n", LAPC_stats.end_time - LAPC_stats.start_time);
					commonlib.log("request per second: %d\n", 1000*LAPC_stats.max_count/((LAPC_stats.end_time - LAPC_stats.start_time)));
				elseif(received_count < LAPC_stats.max_count) then
					test.homeland.home.GetHomeInfo({nid=self.user_nid}, PoolName, call_back_func);
				end
			end
			test.homeland.home.GetHomeInfo({nid=self.user_nid}, PoolName, call_back_func);
		end
	end
	if(self.user_nid) then
		test_me();
	else
		test.auth.AuthUser({username="LiXizhi", password="1234567"}, "test", function(msg)  
			commonlib.applog("client get reply");commonlib.echo(msg);
			self.user_nid = msg.nid;
			test_me();
		end)
	end	
end

--[[ test roundstrip time. Only send next until we got a reply. 
test environment: servers(game, router, db) processes are on the same linux machine, sql is on another machine.
test result:
	total time: 1703
	average round strip: 1.703000(ms)
]]
function test_client:test_Home_Get_sync_many()
	-- first authenticate and then call the test 
	local test_count = 0;
	local LAPC_stats = {
		start_time = 0,
		end_time = 0,
		max_count = 1000,
	}
	LAPC_stats.start_time = ParaGlobal.timeGetTime();
	local function test_me()
	    local PoolName = "test" .. test_count;
		commonlib.log("poolname: %s\n", PoolName);
		test.homeland.home.GetHomeInfo({nid=self.user_nid}, PoolName, function(msg)  
			commonlib.applog("client get reply");commonlib.echo(msg);	
			test_count = test_count + 1;
			if(test_count < LAPC_stats.max_count) then
				test_me();
			else
				LAPC_stats.end_time=ParaGlobal.timeGetTime();
				commonlib.log("---------------------result------------------\n")
				commonlib.log("total time: %d\n", LAPC_stats.end_time - LAPC_stats.start_time);
				commonlib.log("average round strip: %f(ms)\n", ((LAPC_stats.end_time - LAPC_stats.start_time)/LAPC_stats.max_count));
			end
		end);			
	end
	if(self.user_nid) then
		test_me();
	else
		test.auth.AuthUser({username="LiXizhi", password="1234567"}, "test", function(msg)  
			commonlib.applog("client get reply");commonlib.echo(msg);
			self.user_nid = msg.nid;
			test_me();
		end)
	end	
end
