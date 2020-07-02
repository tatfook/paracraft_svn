--[[
Title: a simple chat server
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

if(not server) then server={}; end

--[[ broadcast a simple chat message to all its clients
@param text: string of the text.
@param type: 0 or nil means a normal message. 1 means character head_on message
]]
function server.BroadcastMessage(text, type)
	if(type == nil or type ==0) then 
		type = KMNetMsg.SC_ChatNormal;
	elseif(type==1)then	
		type = KMNetMsg.SC_ChatHeadOn;
	else
		return	
	end
	local msg = {
		type = type,
		text = text,
	};
	CommonCtrl.chat_display.AddText("chat_display1", "[server_broadcasted]:"..text);
	NPL.activate("all@local:script/client/chat_client.lua",msg);
end

--[[ it just forward any type=0 message it receives to all its clients. ]]
local function activate()
	local username = NPL.GetSrcUserName();
	msg.sender = username;
	if((msg.type == KMNetMsg.CS_ChatNormal or msg.type == KMNetMsg.CS_ChatSay) and msg.text~=nil) then
		CommonCtrl.chat_display.AddText("chat_display1", string.format("[%s]:%s",username, msg.text));
		NPL.activate("all@local:script/client/chat_client.lua",msg);
	elseif(msg.type == KMNetMsg.CS_ChatHeadOn and msg.text~=nil) then
		CommonCtrl.chat_display.AddText("chat_display1", string.format("[%s]:%s",username, msg.text));
		-- username headon display
		if(username~="") then
			headon_speech.Speek(username, msg.text, 5);
		end
		NPL.activate("all@local:script/client/chat_client.lua",msg);
	end
end
NPL.this(activate);
