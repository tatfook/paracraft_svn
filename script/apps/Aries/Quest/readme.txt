---++ Quest System 
| Author(s) | Initial draft LiXizhi |
| Date | 2010.8.20 |

---+++ Overview
A MMO-like quest system is implemented using GSL(game server lite) and Item system. 

Quest template is stored in data field of global store item template, thus both client and server see a synchronized copy of all quests(maybe thousands) in the game.  
Each quest item template has a unique gsid in the global store, and it contains information like quest requirements, goals, rewards, start npc, finish npc, next_request_chain, etc.  

---++++ QuestProvider
NPL.load("(gl)script/apps/Aries/Quest/QuestProvider.lua");
local QuestProvider = commonlib.gettable("MyCompany.Aries.Quest.QuestProvider");

QuestProvider provides all the low level access to the quest template data source. This class read all quest related global store items, and save them in indexable tables with graph references. 
Several accessor functions should be provided for ease of accessing quest template data. This class is shared by both client and server. 

---++++ QuestLogics
NPL.load("(gl)script/apps/Aries/Quest/QuestLogics.lua");
local QuestLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestLogics");

QuestLogics is the business logic layer for quest system. It provides all the high level access to the quest data source.
Quest Logics is a standalone set of quest processing functions based on the static quest templates(QuestProvider) and a player's quest status (QuestPlayer). 
For example, given a player' quest status as input, it can compute all available tasks, tasks that are completed, etc. This class is shared by both client and server.

---++++ QuestPlayer
NPL.load("(gl)script/apps/Aries/Quest/QuestPlayer.lua");
local QuestPlayer = commonlib.gettable("MyCompany.Aries.Quest.QuestPlayer");

QuestPlayer is a per player (nid) instanced class. Each QuestPlayer instance contains all the quest item data relavent to a given user(nid). This class is shared by both client and server.
Each GSL_agent has a reference to the quest player instance. 
QuestPlayer is the input to the QuestLogics to trace quest status per player. QuestPlayer also manages quest item persistency. i.e. it will set the server data associated with quest items via PowerItemManager class. 

---++++ PowerItemManager
NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager")

This class is mostly only used by the game server to update server data of quest items and call power database API. Internally it calls PowerAPI(see below)

---++++ PowerAPI
NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.PowerAPI.lua");
PowerAPI class is the game server edition of item API wrapper (paraworld.inventory.lua). Internally it calls power version rest API calls.

---++++ rest_webservice_wrapper 
NPL.load("(gl)script/apps/GameServer/rest_webservice_wrapper.lua");
Add a new API called GameServer.rest.client.CreateRESTJsonWrapperLocal(), which can be used to create power version rest API calls on the game server. 
Internally it calls rest_local(see below) to generate the power version API calls with callbacks.

---++++ rest_local
NPL.load("(gl)script/apps/GameServer/rest_local.lua");
local rest_local = commonlib.gettable("GameServer.rest_local");

this class is used by the game server to make rest DB API calls using the local NPL runtime. GameServer.rest is used to service REST api for the clients, 
whereas GameServer.rest_local is used to service REST api for the game server itself. A request sent to rest_local is forwarded directly to NPL router, and DB replies are routed to local callback functions. 
Unlike GameServer.rest which runs in a single thread, GameServer.rest_local runs in each gateway thread. Internally, GameServer.rest_local send request directly to rounter, but the replies is first sent to 
rest and then forwarded from rest thread to rest_local thread in the same NPL runtime. 

Timer based timeout should be replaced by garbage collection based time out in rest_local. 

---++++ QuestServer
NPL.load("(gl)script/apps/Aries/Quest/ServerObject/QuestServer.lua");
local QuestServer = commonlib.gettable("MyCompany.Aries.Quest.QuestServer");

NPL.load("(gl)script/apps/Aries/Quest/ServerObject/QuestServer_handlers.lua");
local QuestServer_handlers = commonlib.gettable("MyCompany.Aries.Quest.QuestServer_handlers");

NPL.load("(gl)script/apps/Aries/Quest/ServerObject/QuestPlayerManager.lua");
local QuestPlayerManager = commonlib.gettable("MyCompany.Aries.Quest.QuestPlayerManager");

QuestServer is the high level logics of a quest server object on the game server. This class runs in each virtual world thread. 
Because each NPL thread may host multiple game world (thus having multiple Quest Server objects), however, all the QuestServer object instances shares the same data structure on it belonging to the world thread.
The most important data structure shared is the QuestPlayerManager which contains all the QuestPlayer instances. 
The combat server system or the client endpoints may send messages to the QuestServer object, all such requests are routed to QuestServer_handlers for processing. 
Most processing involves calling functions on QuestPlayer to update quest status and quest item server data. 

QuestServer communicates with client by means of sending replies to QuestClient

When a user connect or disconnect QuestPlayerManager should init/release player data minimize memory usage. 

---++++ QuestClient
NPL.load("(gl)script/apps/Aries/Quest/QuestServer.lua");

This is the client side server object for communicating with the game server. It also provides data interface for client side UI and NPC rendering. 
QuestClient needs to translate some quest replies to standard rest API replies locally, so that the client item interface can be synchronized with the game server. 

---++++ NPC.lua
NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
NPC class should be extended to support displaying quest status on NPC head as well as quest related dialog boxes. It calls (register callbacks) the QuestClient to obtain data for NPC rendering and data communications, 
thus as accept new quests, select quest rewards. 

---++++ QuestListPage
script/apps/Aries/Quest/QuestListPage.html
UI class for rendering quest lists. 

---++++ quest MCML tags
NPL.load("(gl)script/apps/Aries/mcml/pe_aries_quest.lua");
for displaying some quest related UI components, such as wheather. 