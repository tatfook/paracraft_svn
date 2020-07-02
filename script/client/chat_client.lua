--[[
Title: a simple chat client
Author(s): LiXizhi
Date: 2006/10/28
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/ClientServerIncludes.lua");
-- a client send a message to a server like below.
local msg = {
	type = 0,
	text = "Hello server!"
};
NPL.activate("@server:script/server/chat_server.lua",msg);

-- a server can send a message to all its clients like below.
local msg = {
	type = 0,
	text = "Hello all my clients!"
};
NPL.activate("all@local:script/client/chat_client.lua",msg);
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/chat_display.lua");

local L = CommonCtrl.Locale("IDE");

if(not client) then client={}; end

--[[ send a simple chat message to the server, where all clients will receive.
@param text: string of the text. 
The following are supported client to server special commands all special client to server command begins with /cs. For more information, please refer to chat_client.lua.
In case authentication is needed, it will use the current user name and password
restart the game on the server from client, it accept an admin account as parameters
/cs restart
get the statistics for a given user on the server from the client, it accept an admin account as parameters
/cs watch "targetname"
get all local information about this client, including network statistics.
/cs info
speak to all clients loudly.
/cs say [any text here]
@param type: 0 or nil means a normal message. 1 means character head_on message
]]
function client.SendChatMessage(text, type)
	if(type == nil or type ==0) then 
		type = KMNetMsg.CS_ChatNormal;
	elseif(type==1)then	
		type = KMNetMsg.CS_ChatHeadOn;
	else
		return	
	end
	
	-- check for header to see it is a server commmands
	local header = string.sub(text,1,3);
	if( header == "/cs") then
		-- if the text begins with "cs", it is client to server commands
		local nFrom,nTo,str;
		
		local _, _, sText = string.find(text, "(.*)$", 5);
		if(not sText) then return end
		
		-- restart game on server
		nFrom,nTo,str = string.find(sText,"restart$");
		if(nFrom~=nil) then
			local msg = {
				type = KMNetMsg.CS_RestartGame, -- restart the game server.
				username=ParaNetwork.GetLocalNerveReceptorAccountName(),
				password="",
			};
			CommonCtrl.chat_display.AddText("chat_display1", "restarting game on server\n");
			NPL.activate("@server:script/server/init_server.lua",msg);
			return
		end
		
		-- get client info
		nFrom,nTo,str = string.find(sText,"info$");
		if(nFrom~=nil) then
			CommonCtrl.chat_display.AddText("chat_display1", "\nclient information\n\n");
			local statistics = ParaNetwork.GetReceptorStatisticsAsString("", 2);
			_guihelper.MessageBox("==client information==\n"..statistics);
			CommonCtrl.chat_display.AddText("chat_display1", statistics);
			return
		end
		
		-- get an on screen alert to all other clients; friends or administrators can do it. 
		nFrom,nTo,str = string.find(sText,"say (.*)$");
		if(nFrom~=nil) then
			local msg = {
				type = KMNetMsg.CS_ChatSay,
				text = str,
			};
			NPL.activate("@server:script/server/chat_server.lua",msg);
			return
		end
		
		-- unknown commands
		CommonCtrl.chat_display.AddText("chat_display1", "unknown commands:"..sText.."\n");
		return
	else
		local msg = {
			type = type,
			text = text,
		};
		NPL.activate("@server:script/server/chat_server.lua",msg);
	end
end

-- it just displays whatever messages it receive. 
local function activate()
	local username = msg.sender;
	if(username == nil) then
		username = "";
	end
	if(msg.text~=nil) then
		CommonCtrl.chat_display.AddText("chat_display1", string.format("[%s]:%s",username, msg.text));
		log(string.format("chat log [%s] says:%s\r\n",username, msg.text));
		if(msg.type == KMNetMsg.SC_ChatHeadOn) then
			if(username~="") then
				if(username == ParaNetwork.GetLocalNerveReceptorAccountName()) then
					-- in case an inpersonation is used, use the current player's name
					username = ParaScene.GetPlayer().name;
				end
				headon_speech.Speek(username, msg.text, 5);
			end
		elseif(msg.type == KMNetMsg.SC_ChatSay)then
			_guihelper.MessageBox(string.format(L"[%s]says to all: %s\n", username, msg.text));
		end
	end
end

NPL.this(activate);
