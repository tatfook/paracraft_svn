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
NPL.activate("@server:script/tutorials/helloworld/chat_server.lua",msg);

-- a server can send a message to all its clients like below.
local msg = {
	type = 0,
	text = "Hello all my clients!"
};
NPL.activate("all@local:script/tutorials/helloworld/chat_client.lua",msg);
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/chat_display.lua");
NPL.load("(gl)script/ide/headon_speech.lua");
if(not client) then client={}; end

--[[ send a simple chat message to the server, where all clients will receive.
@param text: string of the text.
@param type: 0 or nil means a normal message. 1 means character head_on message
]]
function client.SendChatMessage(text, type)
	if(type == nil) then type = 0 end
	local msg = {
		type = type,
		text = text,
	};
	CommonCtrl.chat_display.AddText("chat_display1", "sent to server");
	NPL.activate("@server:script/tutorials/helloworld/chat_server.lua",msg);
end

-- it just displays whatever messages it receive. 
local function activate()
	local username = msg.sender;
	if(username == nil) then
		username = "";
	end
	if(msg.text~=nil) then
		CommonCtrl.chat_display.AddText("chat_display1", msg.text);
		log(msg.text.."\n");
	end
end

NPL.this(activate);
