---+++ Game Server 
| Author | LiXizhi |
| Date	 | 2009.7.20 |
| revisions | 2009.10.7: added GSL_homegrids, GSL_proxy. |

The game server application starts the game server for servicing world and gateway requests.
The game server is implemented in npl scripts, and communicate with the DBRouter for database access.

Each runtime state on game server represents a game world that a user can connect to. This is a stand alone game server 
which means that each runtime state will service all worlds' requests. This is unlike the JGSL which a number of virtual servers cooperate to serve world requests

We call each runtime state on the game server, a virtual world server (or simply world server). The user needs to manually select a world server before he can login. 
Each world server can hosts one or more instances of one or multiple world paths. Each world instance is structured as a dynamic quad tree 
in order to speed up character vicinity activity lookup. 

There is a special runtime state called "rest", which does the job of authentication as well as REST URL queries for clients and other runtime states. 

---+++ Client Boot Procedure
   -->GetServerList to retrieve an automatically assigned initial game server.
   -->client login to the game server: (rest):rest.lua, {url="login", req={username, password}}
   -->get world instances and game server: (rest):rest.lua, {url="worldlist", r={page=1}}
		-->may need to switch to a new game server
   -->connect to a world server instance

---+++ Message protocol
The following shows a request from client to db server and back. 
<verbatim>
==from client to server==
client-->game server:rest.lua {url=url_string, req = {name=value, name=value, }, seq = sequence_number, nid = if_authenticated}
	game server:rest.lua-->NPLRouter:NPLRouter.dll {user_nid = input_msg.nid, game_nid = nid_of_current_game_server, g_rts = "rest", dest="db", ver="1.0", data_table = {url = input_msg.url, req = input_msg.req, seq = input_msg.seq} }
		NPLRouter:NPLRouter.dll-->DBServer:DBServer.lua {user_nid = input_msg.user_nid, game_nid = input_msg.game_nid, g_rts = input_msg.g_rts, ver="1.0", data_table = input_msg.data_table}
			DBServer:DBServer.lua-->DBServer:(any_worker_state)DBServer.dll/(url_handler).cs {}=input_msg
			
(now processing request synchronously in multiple worker threads)

==from server to client==
DBServer:(any_worker_state)DBServer.dll/(url_handler).cs-->NPLRouter:NPLRouter.dll: {user_nid = input_msg.user_nid, game_nid = input_msg.game_nid, g_rts = input_msg.g_rts, ver="1.0", data_table = {seq = input_msg.data_table.seq, data = response_json_string}}


</verbatim>

---+++ World Service
Each world is identified by an id,call world id. world_id is also the runtime state name of the world server. 

World service is mostly about synchronizing a SVN world directory of data. 
Most data objects are comitted by users. Whenever a user commit a group of data, a new auto-increase revision number is assigned to the data. 
Data types are versatile. 

				
			
---+++ How to debug game server during development
We will start the client and server on the same machine. 

---++++ Start Server
Server is started first. Run ParaEngineServer(not client) with following code on shell_loop init. 
<verbatim>
	NPL.StartNetServer("127.0.0.1", "60002");
	NPL.LoadPublicFilesFromXML();
	local worker = NPL.CreateRuntimeState("world1", 0);
	worker:Start();
	NPL.activate("(world1)script/apps/GameServer/GSL_system.lua", {type="restart", config={nid="localhost", ws_id="world1"}});
</verbatim>

Alternatively, the test game server can be started using following bootstrapper at command line of ParaEngineServer.exe

<verbatim>
	"bootstrapper=\"script/apps/GameServer/test/test_bootstrapper_gameserver.xml\""
</verbatim>

---++++ Start Client
Client is started next. One should load a world can run following code after world is loaded. 
There is a sample code in "File.EnterTaurusWorld" command handler in ParaEngineSDK(Taurus)'s app_main file.
<verbatim>
	-- NOTE LiXizhi: 2009.7.30: Remove this in release build. 
	local test_using_local_game_server = true;
	if(test_using_local_game_server) then
		NPL.load("(gl)script/apps/GameServer/GSL.lua");
		
		-- start the game server on the local machine
		local worker = NPL.CreateRuntimeState("world1", 0);
		worker:Start();
		NPL.activate("(world1)script/apps/GameServer/GSL_system.lua", {type="restart", config={nid="localhost", ws_id="world1"}});
		
		NPL.StartNetServer("127.0.0.1", "60001");
		NPL.LoadPublicFilesFromXML();
		
		NPL.AddNPLRuntimeAddress({host = "127.0.0.1", port = "60002", nid = "gs1",});
		
		-- pick a random nid each time we log in
		Map3DSystem.User.nid = tostring(math.floor(ParaGlobal.GetGameTime()*1000)%100000);
		
		commonlib.applog("TODO: remove this in release build: connecting to local game server, ...")
		local run_gs_locally = false;
		if(run_gs_locally) then
			while(NPL.activate("localhost:script/apps/GameServer/test/accept_any.lua", {user_nid = Map3DSystem.GSL.GetNID(), callback=[[Map3DSystem.GSL_client:LoginServer("localhost", "world1");]]})~=0) do end
		else
			while(NPL.activate("gs1:script/apps/GameServer/test/accept_any.lua", {user_nid = Map3DSystem.GSL.GetNID()})~=0) do end
			ParaEngine.Sleep(0.5);
			Map3DSystem.GSL_client:LoginServer("gs1", "world1");
		end	
		commonlib.applog("local game server connected")
	end
</verbatim>

Note: 
   * Multiple clients can be opened, each time a random nid is assigned. 
   * accept_any.lua must be on the public file list. 


Alternatively, one can use the game client test console MCML page on ParaEngine SDK (Taurus)

<verbatim>
	script/apps/GameServer/test/test_gameclient_page.html
</verbatim>

---+++ research work

Foreach GameTick:
  Poll Incoming Messages
  Dispatch Messages to Targets
  Evolve the World for One Tick
  Enqueue Updates to Clients

---+++ Server Configurations Files

---++++ GSL configuration file
The file is usually named in config/GSL.config.xml
<verbatim>
<GSL>
<!--game server modules that should be loaded in per game world thread. Dependency and async loading is supported, so that 
some modules can call other system or module functions asynchrounously and use the result for initialization.
-->
<modules>
  <module src="script/apps/Aries/Combat/ServerObject/CombatService.lua"></module>
  <module src="script/apps/Aries/Quest/QuestService.lua"></module>
  <module src="script/kids/3DMapSystemItem/PowerItemService.lua"></module>
</modules>
<GridServer>
  <!--worldfilter are internally to lower cased-->
  <GridNodeRules>
    <rule worldfilter="^worlds/MyWorlds/.*homeland/$" close_server_ticks="2" fromx="20000" fromy="20000"/>
    <!-- empty rule(worldfilter) maps to any world-->
    <rule fromx="20000" fromy="20000" />
  </GridNodeRules>
</GridServer>
</GSL>
</verbatim>
The following attributes are supported for gridnode rule node 
| name | desc |
| id | the gridrule_id, which can be used in additional to worldfilter for client to specify which world to login. It is recommended to use id which is faster than worldfilter for server side matching. |
| worldfilter | case insensitive, regular expression. |
| npc_file |  |
| timeout_check_ticks | how many ticks to wait until a timeout check is performed. (timeout_check_ticks * GSL_grid.TimeInterval) is the actual inteval. |
| framemove_check_ticks | how many ticks to wait until a frame move of all server objects are performed. (timeout_check_ticks * GSL_grid.TimeInterval) is the actual inteval. |
| close_server_ticks | close the server if it has been empty for this number of ticks.  |
| is_persistent | if true, onframemove will always return true, so that this gridnode will never be closed even if close_server_ticks has passed.   |
| MinStartUser | minimum user count to start the grid node |
| MaxStartUser | max allowed user count. if this is specified, the worldteam_server server_object needs to be used to start the server. |

---++++ game server configuration file
The file is usually named in config/GameServer.config.xml

Most of the time, the client maintains a TCP connection to a single game server. Each game server runs a single
REST interface and multiple virtual world servers(one on each npl state). 
Each virtual world server hosts one GSL_gateway, one GSL_proxy, multiple local GSL_grid nodes and optionally multiple GSL_homegrid nodes. 

Whenever a user requests to connect to a given sub-game world or sub-home world, it asks the GSL_gateway for it on its currently connected virtual world server. 
GSL_gateway will either pick a local GSL_grid node or a GSL_homegrid node on some other virtual world servers. 
If a non-local GSL_homegrid is used, the GSL_proxy object is responsible for mediating messages between the gateway(on address1) and the remote GSL_homegrid(on address2). 

GSL_gateway will pick GSL_homegrid if the requested game world path contains "?nid=client_nid" params. 
(math.mod(client_nid, #homegrids) + 1) is the index of homegrid world server to use for a given nid. 
All game servers should share the same list of homegrids in their configuration file. 

---+++++ config section 
It specifies which ip and port this game server listens to. As well as the nid of the game server.

| *XPath* | *desc* |
| config/[IsPureServer] | "true" or "false", default to false. if true, NPL router and rest is not used. this is usually used for testing game server |
| config/debug | "true" or "false", default to false. if true, game server will dump all messages |
| config/compress_incoming | whether to use compression for incoming connections. |
    This must be true in order for CompressionLevel and CompressionThreshold to take effect |
| config/CompressionLevel | -1, 0-9: Set the zlib compression level to use in case compresssion is enabled. |
    Compression level is an integer in the range of -1 to 9. 
		Lower compression levels result in faster execution, but less compression. Higher levels result in greater compression, 
		but slower execution. The zlib constant -1, provides a good compromise between compression and speed and is equivalent to level 6. |
| config/CompressionThreshold |  when the message size is bigger than this number of bytes, we will use m_nCompressionLevel for compression. 
		For message smaller than the threshold, we will not compress even m_nCompressionLevel is not 0. |
| config/imserver_heartbeat_interval | milliseconds to send heart beat to IM server. If this 0 or does not exist, we will not send heart beat messages to im server. which is usually the case for HomeServer, where user connections are not kept. |
| config/log_level | default to "INFO". This can also be "DEBUG"|
| config/gc_interval | garbage collection interval. default to none. |
| config/gc_opt | this can be "collect" or "step". default to "collect". the first one causes a complete gc cycle;the second is incremental. |
| config/gc_info | default to "false". whether to print gc info periodically. |
| config/gc_setpause | The garbage-collector pause controls how long the collector waits before starting a new cycle. Larger values make the collector less aggressive. Values smaller than 100 mean the collector will not wait to start a new cycle. The default,200, means that the collector waits for the total memory in use to double before starting a new cycle. |
| config/gc_setstepmul | The step multiplier controls the relative speed of the collector relative to memory allocation. Larger values make the collector more aggressive but also increase the size of each incremental step.  Values smaller than 100 make the collector too slow and can result in the collector never finishing a cycle. The default, 200, means that the collector runs at "twice" the speed of memory allocation. |
| config/npl_queue_size| the default npl queue size for each npl thread. defaults to 500. may set to something like 5000 for busy servers. |

---+++++ npl_states section 
It specifies the number of NPL states used to service requests, each state matches to a physical thread. Each npl states hosts a single virtual world server. 
npl state name is therefore the virtual world id. The address of a virtual world server is therefore the combination of its game server nid plus npl state name. 
such as "(world1)gameserver1", where world1 is npl state name, gameserver1 is nid of the game server. 

---+++++ npl_runtime_addresses section 
It specifies known runtime addresses and their nid used by the server: NPL.AddNPLRuntimeAddress(server_address);
NPL runtime will only actively establish connections to known addresses. 

---+++++ homegrids section
It specifies the total lists of homegrids virtual world server addresses. All game servers must maintain and share the same list, 
so that game world login requests are always directed to the same virtual world server address. 
Note: For homegrids, we can use existing virtual world server addresses or we can use dedicated addresses, such as allocating PCs for homegrids only. 
It is good idea to deploy homegrids on not so busy game servers or dedicated PCs on the LAN, where the clients do not connect to directly. 

---++++ NPL.accept atomicity analysis
router tid<--------------nid game
router nid===============>tid game
router my_nid tid<------------------nid game
router tid<--------------nid game
accept
  remove == 
     router Create 3rd conn nid...............>tid game
	 router my_nid<...............tid game
	  accept
  add : stop .., add --
      remove --
	  add stop --, add ..(dead)
	  router tid<***************nid game
	  nid(dead).................>Not replying game
   
	 





       