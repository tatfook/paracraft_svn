---++ Log Service in GSL
Author: LiXizhi
Date: 2011.7.25

---+++ Overview
A network log system for GSL with a web console. 

---+++ Usage
Currently init is automatically called when GSL is started. paraworld.PostServerLog can be used on the main, worlds, rest and lobby thread.
<verbatim>
	NPL.load("(gl)script/apps/GameServer/LogService/GSL_LogClient.lua");
	local logger = Map3DSystem.GSL.GSL_LogClient.GetSingleton();
	logger:init({my_nid=string, logserver_nid = string, logserver_thread_name=string, });

	-- post using default file "GSL"
	paraworld.PostServerLog({action="test", any_data="hello"})
	-- post log to specified file
	paraworld.PostServerLog({action="test", any_data="hello"}, "FileName")
	-- post log with callback from server (DO NOT USE CALLBACK unless you really mean it, it waste resource)
	paraworld.PostServerLog({action="test", any_data="hello"}, nil, function()  echo("log success!")  end)

	-- post log using logger, which is same as above.
	logger:log({action="test", any_data="hello"}, "GSL", function() echo("success!") end)
</verbatim>

---+++ Requirements
   * Cross servers: any machine(GSL_LogClient) can send log messages to a remote or local GSL_LogServer
   * The log interface resembles that of the standard local log.lua
   * XML based log configuration files (can be embedded in global GSL log): 
   * WebConsole: to analize(view and filter) logs. 
   * Giga bytes of log file is supported. The administrator should use external script to trim, zip and backup daily log.
   * log callback is supported, but we strongly recommended to avoid using callbacks, so that there is no round-trip reply message from server. 

---+++ Architecture
Only a single NPL thread is used to write log to prevent racing log file or interlaced log output


---+++ Message Sequence Graph
LogClient								LogServer
GSL_LogClient:				--->		GSL_LogServer
                                        if there is a sequence number, flush data to disk and send reply message. 
Client side callback is invoked   <---  confirmed

