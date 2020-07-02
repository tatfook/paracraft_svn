--[[
Title: Quest system server and client.
Author(s): WangTian
Date: 2008/12/10
use the lib:
In Aquarius, the first quest imlementation is the welcome quest and creator tutorial similar to WoW quest and SimCity tutorial.
Although local paraworld runtime is both client and server at the same time in this version. We leave an interface and 
complete opcode definition to switch to online server and MMORPG-like quest system. We extend the quest design to support both the 
client side requirement detect(tutorial/local logic) and server side detect(MMORPG). Aquarius uses the former template to complete 
the public world NPC logics and creator tutorial.

All quest related data is transfered through messages. All quest message definations are in MSGDef. Main client and server file are 
neuron files that activates each other by sending messages. On both end(client and server) MSGHanlder handles the receive message traffic.
On client side, user interface communicates with Client functions if required and register message handler callback functions to 
respond to server message. On server side, Server and MSGHandler_Server directly perform database query and update according to 
quest logics.

BIG PICTURE:
															 |
										MSGHandler_Client	 |		MSGHandler_Server
	Aquarius					Client			|		   MSGDef			|		Server							Database
								  | 			|			 |				|		  |
	DialogWnd	AcceptQuest ---> Send --------------------  CMSG  ------> Recv ---------------> UpdateQuestStatus
	ListWnd		SayHelloToNPC-|	  |				|			 |				|		  |		|-- SelectQuestList			DB
	Tracker		UpdateTracker <-------------- Recv <------  SMSG  ----------------- Send <----- OnQuestComplete
								  |				|			 |				|		  |
												|			 |				|
															 |

The implementation of each component is shown above and this file is a public main entrance of all quest features.


------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemQuest/Main.lua");
Map3DSystem.Quest.Init();
------------------------------------------------------------
]]

if(not Map3DSystem.Quest) then Map3DSystem.Quest = {};end;
--if(not Map3DSystem.Quest.Server) then Map3DSystem.Quest.Server = {}; end
--if(not Map3DSystem.Quest.Client) then Map3DSystem.Quest.Client = {}; end
--if(not Map3DSystem.Quest.Server.MSGHandler) then Map3DSystem.Quest.Server.MSGHandler = {}; end
--if(not Map3DSystem.Quest.Client.MSGHandler) then Map3DSystem.Quest.Client.MSGHandler = {}; end
--if(not Map3DSystem.Quest.DB) then Map3DSystem.Quest.DB = {}; end
--if(not Map3DSystem.Quest_MSG) then Map3DSystem.Quest_MSG = {}; end
---- TODO: provide interface for quest log data access
--if(not Map3DSystem.Quest.Client.Log) then Map3DSystem.Quest.Client.Log = {}; end
--
--NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_DB.lua");
--NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_MSGDef.lua");
--NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_Server.lua");
--NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_Client.lua");
--NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_MSGHandler_Server.lua");
--NPL.load("(gl)script/kids/3DMapSystemQuest/Quest_MSGHandler_Client.lua");
--
--local Quest_Server = Map3DSystem.Quest.Server;
--local Quest_Client = Map3DSystem.Quest.Client;
local Quest = Map3DSystem.Quest;
--
---- log all client and server message trafic
--Quest.DebugQuestMessage = false;

-- default neuron files for client and server. 
Quest.DefaultServerFile = "script/kids/3DMapSystemQuest/Quest_Server.lua";
Quest.DefaultClientFile = "script/kids/3DMapSystemQuest/Quest_Client.lua";

-- reset if not reset before
function Quest.ResetIfNot()
	if(not Quest.IsResetBefore) then
		Quest.IsResetBefore = true;
		Quest.Reset();
	end
end

function Quest.Reset()
	-- logout server 
	-- reset quest server gateway
end

---- send a message to client
---- @param UID: the UID of a client. If this is nil. Messages is sent to all active clients.
---- @param neuronfile: if nil, the DefaultClientFile is used
--function Quest.SendToClient(UID, msg, neuronfile)
	---- TODO: send to specific client
	---- currently in Aquarius project, the message is send directly to itself
	--NPL.activate((neuronfile or Quest.DefaultClientFile), msg);
--end

function Quest.Init()
	-- make these files accessible by other machines
	NPL.AddPublicFile(Quest.DefaultServerFile, 1);
	NPL.AddPublicFile(Quest.DefaultClientFile, 2);
	
	-- client net server
	NPL.StartNetServer("192.168.0.102", "60022");
	commonlib.applog("quest server is started. ")
	
	-- add the server address
	NPL.AddNPLRuntimeAddress({host = "192.168.0.102", port = "60011", nid = "questserver"})
end

-- send a message to server
-- @param SID: the SID of a server.
-- @param neuronfile: if nil, the DefaultServerFile is used
function Quest.SendToServer(msg)
	while(true) do
		local ret = NPL.activate("(worker1)questserver:"..Quest.DefaultServerFile, msg);
		if(ret == 0) then
			break;
		end
	end
	--while( NPL.activate("(worker1)questserver:"..Quest.DefaultServerFile, msg) ~= 0 ) do end
	--{TestCase = "TP", data="from client"}
end

-- receive a message from server
function Quest.RecvFromServer(msg)
	log("Quest.RecvFromServer(msg)\n");
	commonlib.echo(msg);
end

local function activate()
	Quest.RecvFromServer(msg);
end

NPL.this(activate);
