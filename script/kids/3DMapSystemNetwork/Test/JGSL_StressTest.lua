--[[
Title:  Several stress test case
Author(s): LiXizhi
Date: 2009/5/1
Desc: Please see the test result in JGSL_StressTest.lua.result file.

an empty message like below takes 156 bytes.
<message from='106102@test.pala5.cn/pe' to='100101@test.pala5.cn' xml:lang='en' type='normal'>
<body>{type=1,}</body>
<subject>NI:20</subject>
</message>
 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/Test/JGSL_StressTest.lua");

-- stress test with 50 concorrent clients. 
Tests.JGSL_Server_Throughput({ClientCount=2, Time = 10, Iterations=2, NoClient=false, Interval=100});
-- stress test by just creating a single server and flush to jabber clusters with huge number of different client messages.
Tests.JGSL_Server_Throughput({ClientCount=10, Time = 10, Iterations=1, NoClient=true});
-- use 100 servers to send messages to 20 clients for 10 seconds.
Tests.JGSL_Server_Throughput({ServerCount =100, ClientCount=20, Time = 10, Iterations=1, NoClient=true});

-- Tests.JGSL_Server_Throughput({ClientCount=10, Time = 10, Iterations=10});
--Tests.JGSL_Server_Throughput({ServerCount =100, ClientCount=20, Time = 10, Iterations=1, NoClient=true});
--Tests.JGSL_Server_Throughput({ServerCount =1, ClientCount=1000, Time = 30, Iterations=2, NoClient=true});
--Tests.JGSL_Server_Throughput({ServerCount =1, ClientCount=1, Time = 2, Iterations=1, NoClient=true});
--Tests.JGSL_Server_Throughput({ServerCount =1, ClientCount=2, Time = 20, Iterations=10, NoClient=false});


--Tests.JGSL_Server_Throughput({ServerCount = 5, ClientCount=1, Time = 60, Iterations=500, NoClient=false});
-- (ejabberd server is on 1 CPU VM machine)
-- server 2900 sent msg/second. client 2824 received per second. 
--Tests.JGSL_Server_Throughput({ServerCount =1, ClientCount=1, Time = 20, Iterations=500, NoClient=false});

-- server 3400 sent msg/second. server 274 offline msg per second. 
--Tests.JGSL_Server_Throughput({ServerCount =1, ClientCount=1, Time = 20, Iterations=500, NoClient=true});

-- server 3450 sent msg/second. server 276 offline msg per second. 
--Tests.JGSL_Server_Throughput({ServerCount =1, ClientCount=500, Time = 20, Iterations=1, NoClient=true});

-- server 5200 sent msg/second. server 263 offline msg per second. 
-- Tests.JGSL_Server_Throughput({ServerCount = 2, ClientCount = 1, Time = 20, Iterations=500, NoClient=true});

-- server 4200 sent msg/second. client 3900 received per second. client 1800 sent. 
-- Tests.JGSL_Server_Throughput({ServerCount = 2, ClientCount = 1, Time = 20, Iterations=500, NoClient=false});

-- Tests.JGSL_Server_Throughput({ServerCount = 200, ClientCount=1, Time = 2, Iterations=1, NoClient=false});
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemNetwork/Test/JGSL_StressTest.lua");

local neuronFileName = "script/kids/3DMapSystemNetwork/Test/JGSL_StressTest.lua";

if(not Tests) then Tests={}; end

local params;
local MsgType = {
	SC_PING = 1,
	CS_PING_ECHO = 2,
}
-- reports
local stats = {
	RequestsPerSecond = 0;
	nTotalRequests = 0,
	TimePerRequest = 0,
	-- number of messages sent by the server but not reached to the client
	UnreachedServerMsg = 1,
	FromTime = 0,
	EndTime = 0,
	-- number of flush count
	SentCount = 0, 
	-- number of messages sent to clients
	SentMsgCount = 0, 
	clients = {},
	servers = {},
	-- only start when all clients have replied at least once
	bStarted = false,
}
-- output the reports to log file. 
local function OutputStats()
	local _,stat;
	for _, stat in pairs(stats.clients) do 
		if(type(stat) == "table" and stat.jc) then
			stat.stat = stat.jc:GetStatistics(stat.stat or {});
		end
	end
	for _, stat in pairs(stats.servers) do 
		if(type(stat) == "table" and stat.jc) then
			stat.stat = stat.jc:GetStatistics(stat.stat or {});
		end
	end
	commonlib.echo(stats);
end	

--[[ test the through put per game server node on Ejabberd server cluster. 
On the same computer(single ParaEngine instance), it will create one server and N clients, the server sends ping message to all clients repeatedly, 
the client echoes the server message. 
The server will report on things like, 
  requests per second, round trip latency, total requests processed
@param input:  a table containing test case parameters. 
{
	-- a maximum of accounts, such as 1-300, defaults to 100
	ClientCount = 100,
	-- the server flushes the client every few milli-seconds. In each cycle, how many unique messages are sent from server to client. 
	-- increase this value and ClientCount at the same time to test the limit of the server.
	-- default to 1. it could be 1-1000
	Iterations = 1,
	-- how many seconds to test after all connections are up.
	Time = 10,
}
]]
function Tests.JGSL_Server_Throughput(input)
	input = commonlib.inherit({
		-- the number of servers to spawn
		ServerCount = 1,
		-- the first client id
		FirstServerID = 106100,
		-- a function that returns the user name of the server given an nIndex;
		GetServerUserName = function(self, nIndex)
			return tostring(self.FirstServerID+nIndex).."@test.pala5.cn";
		end,
		-- a function that returns the user password of the Server given an nIndex;
		GetServerPassword = function(self, nIndex)
			return "guestABC123";
		end,
		
		-- a maximum of accounts, such as 1-300, defaults to 100
		ClientCount = 100,
		-- the server flushes the client every few milli-seconds. In each cycle, how many unique messages are sent from server to client. 
		-- increase this value and ClientCount at the same time to test the limit of the server.
		-- default to 1. it could be 1-1000
		Iterations = 1,
		-- the server flushes the client every Interval milli-seconds. default is 10. 
		Interval = 10,
		-- the data to be sent per message. Filling in large text to test throughput
		--data = [[1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
--1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
--1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
--1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
--1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
--1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
--1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
--1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
--1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
--1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
--]],
		-- if no client is set to true, the client will not be connected. 
		NoClient = true,
		-- the first client id
		FirstClientID = 100100,
		-- a function that returns the user name of the client given an nIndex;
		GetClientUserName = function(self, nIndex)
			return tostring(self.FirstClientID+nIndex).."@test.pala5.cn";
		end,
		-- a function that returns the user password of the client given an nIndex;
		GetClientPassword = function(self, nIndex)
			return "guestABC123";
		end,
	}, input)
	params = input;
	
	JabberClientManager.AddStringMap(20, neuronFileName);
	
	local function CreateServer()
		local i;
		for i=1, params.ServerCount do
			local jc = JabberClientManager.CreateJabberClient(params:GetServerUserName(i));
			if(not jc:GetIsAuthenticated()) then
				jc.Password = params:GetServerPassword(i);
				jc:ResetAllEventListeners();
				jc:AddEventListener("JE_OnConnect", "commonlib.echo(msg)");
				jc:AddEventListener("JE_OnAuthenticate", "Tests.OnServerAuthenticated()");
				jc:AddEventListener("JE_OnDisconnect", "commonlib.echo(msg)");
				--jc:AddEventListener("JE_OnAuthError", "commonlib.echo(msg)");
				jc:AddEventListener("JE_OnMessage", "Tests.OnServerMessage()");
				jc:Connect();
			end
			stats.servers[params:GetServerUserName(i)] = {jc = jc};
		end
		
		stats.ServerCount = params.ServerCount;
		stats.ClientCount = params.ClientCount;
		
		-- create a timer that periodically send messages to all clients. 
		NPL.load("(gl)script/ide/timer.lua");
		local mytimer;
		mytimer = commonlib.Timer:new({
			callbackFunc = function(timer)
				local jc1 = stats.servers[params:GetServerUserName(1)].jc;
				if(not jc1:GetIsAuthenticated()) then
					return 
				end
				local curTime = ParaGlobal.GetGameTime();
				
				if (stats.bStarted) then
					if(not stats.finished)then
						local lastCount = stats.SentMsgCount;
						local from = ParaGlobal.timeGetTime()
						local s;
						for s=1, params.ServerCount do
							local bIsQueueFull;
							local jid = params:GetServerUserName(s);
							local jc = stats.servers[jid].jc;
							if(jc:GetIsAuthenticated()) then
								-- start flushing the clients
								local nIter;
								for nIter = 1, params.Iterations do
									if(bIsQueueFull) then
										break
									end
									local i;
									for i=1, params.ClientCount do
										local jid = params:GetClientUserName(i);
										local bSuc = jc:activate(jid..":"..neuronFileName, {
											type=MsgType.SC_PING,
											serverTime = curTime,
											data = params.data,
										});
										if(bSuc) then
											stats.SentMsgCount = stats.SentMsgCount + 1;
										else
											bIsQueueFull = true;
											break;
										end
									end
								end
							end
						end
						local to = ParaGlobal.timeGetTime();
						commonlib.echo({cycle_delta = to-from, cnt = stats.SentMsgCount - lastCount, from = from})
					end
				elseif(not params.NoClient)then
					-- send a first packet to client
					local bIsQueueFull;
					local i;
					for i=1, params.ClientCount do
						if(bIsQueueFull) then
							break
						end
						local jid = params:GetClientUserName(i);
						if(not stats.clients[jid].connected and JabberClientManager.CreateJabberClient(jid):GetIsAuthenticated()) then
							bIsQueueFull = not jc1:activate(jid..":"..neuronFileName, {
								type=MsgType.SC_PING,
								serverTime = curTime,
							});
						end	
					end
				end
				if(stats.bStarted) then
					if((stats.FromTime + params.Time*1000) < curTime) then
						log("Finished Stress test. See Reports Below: \n")
						if(not stats.finished) then
							stats.finished = true;
							stats.EndTime = curTime;
							mytimer:Change(5000, 5000);
						end	
						stats.ElapsedTime = curTime - stats.FromTime;
						
						if(params.NoClient) then
							stats.nTotalRequests = stats.UnreachedServerMsg
						end
						stats.RequestsPerSecond = stats.nTotalRequests/(stats.EndTime - stats.FromTime)*1000;
						-- generate report. 
						OutputStats();
					else
						stats.SentCount = stats.SentCount + 1;
					end	
				end
			end});
		mytimer:Change(0, params.Interval); -- start timer
	end
	local function CreateClients()
		local i;
		for i=1, params.ClientCount do
			local jc = JabberClientManager.CreateJabberClient(params:GetClientUserName(i));
			if(not jc:GetIsAuthenticated()) then
				jc.Password = params:GetClientPassword(i);
				jc:ResetAllEventListeners();
				jc:AddEventListener("JE_OnConnect", "commonlib.echo(msg)");
				jc:AddEventListener("JE_OnAuthenticate", "commonlib.echo(msg)");
				jc:AddEventListener("JE_OnDisconnect", "commonlib.echo(msg)");
				--jc:AddEventListener("JE_OnAuthError", "commonlib.echo(msg)");
				jc:AddEventListener("JE_OnMessage", "Tests.OnClientMessage()");
				jc:Connect();
			end
			stats.clients[params:GetClientUserName(i)] = {jc = jc};
		end
	end
	if(not params.NoClient) then
		CreateClients();
	end	
	CreateServer();
end

function Tests.OnServerMessage()
	stats.UnreachedServerMsg = stats.UnreachedServerMsg + 1;
end

function Tests.OnServerAuthenticated()
	if(params.NoClient) then
		local s;
		for s=1, params.ServerCount do
			local jid = params:GetServerUserName(s);
			local jc = stats.servers[jid].jc;
			if(not jc:GetIsAuthenticated()) then
				return
			end
		end
		stats.FromTime = ParaGlobal.GetGameTime();
		commonlib.log("\nstress test started: at %d\n\n", stats.FromTime);
		stats.bStarted = true;
	end	
end

function Tests.OnClientMessage()
	local stat = stats.clients[msg.jckey];
	if(stat) then
		stat.UnreachedServerMsg = (stat.UnreachedServerMsg or 0) + 1;
	end
end

-- the receiver for remote activation. 
local function activate()
	-- msg.from may be of format "name@server/resource", so we need to remove resource
	local from = string.gsub(msg.from, "/.*$", "");
	local to = msg.jckey;
	
	--commonlib.echo(msg)
	if(msg.type==MsgType.SC_PING) then
		local jc = JabberClientManager.CreateJabberClient(to);
		if(jc:GetIsAuthenticated()) then
			local bSuc = jc:activate(from..":"..neuronFileName, {
				type=MsgType.CS_PING_ECHO,
				serverTime = msg.serverTime,
				clientTime = ParaGlobal.GetGameTime(),
			});
			local stat = stats.clients[to];
			stat.SC_PING_cnt = (stat.SC_PING_cnt or 0) + 1;
			if(bSuc) then
				stat.SC_PING_Suc_cnt = (stat.SC_PING_Suc_cnt or 0) + 1;
			else
				--commonlib.log("unable to echo SC_PING: %s, requests %d\n", to, stat.SC_PING_Suc_cnt);
			end
		end	
	elseif(msg.type==MsgType.CS_PING_ECHO) then
		if(stats.bStarted) then
			stats.TimePerRequest = (stats.TimePerRequest*stats.nTotalRequests + (msg.clientTime - msg.serverTime))/(stats.nTotalRequests+1);
			stats.nTotalRequests = stats.nTotalRequests+1;
			local stat = stats.clients[from];
			stat.TotalRequests = (stat.TotalRequests or 0) + 1;
		else
			-- only start when all clients have replied at least once
			stats.clients[from].connected = true;
			stats.bStarted = true;
			local i;
			for i=1, params.ClientCount do
				local jc = JabberClientManager.CreateJabberClient(params:GetClientUserName(i));
				local stat = stats.clients[params:GetClientUserName(i)];
				if(not stat.connected) then
					stats.bStarted = false;
					break;
				end
			end
			if(stats.bStarted) then
				stats.FromTime = ParaGlobal.GetGameTime();
				commonlib.log("\nstress test started: at %d\n\n", stats.FromTime);
			end
		end			
	end
end
NPL.this(activate)