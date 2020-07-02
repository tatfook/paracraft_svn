--[[
Title: Lobby BBS channel manager
Author(s): WangTian
Date: 2008/6/24, Doc requirement added LiXizhi. 2008.7.20
Desc:

---++ Message format
<verbatim>
{ 
	uid = user id, 
	date = send date,
	channelName = channel name that this message belongs to,
	channelColor = text color, [optional]
	text = pure or mcml text,
	name = fullname of the user sending the message.
	JID = JID of the user sending the message. 
}
</verbatim>
Please note that in the remote database, we only store three fields {uid, date, content}
Hence, uid, date are read exactly as in the remote database. 
channelColor and channelName are added locally according to local settings when a message is retrieved.
text, name, JID are stored as NPL table in content column. Whenever we received the content field from the server, 
we will decide if it is xml (pure text) or a serialized NPL table string(begins with '{'). If it is table, all table fields
are extracted to the message.

---++ Sending message
Usually when we send messages, we usually send a serialized table string containing {text, name, JID}, such as
{
	uid, 
	channelName, 
	content = commonlib.serialize_compact({text, name, JID});
} 
The text length is limited to 256 characters. 

---++ Displaying message in chat window
we will reconstruct an mcml string from available message fields to display a given message. the reconstruction is as below. 
<p style='color:{msg.channelColor};' >[{msg.channelName}]
	<pe:name value='{msg.name}' uid='{msg.uid}'/>:{msg.text}
</p>
We will display 8 messsages at a time in a screen. 

---++ Getting latest messages
the way client getting messages from server is based on polling. the polling logic is below
- If lastUpdateTime==nil, immediately fetch from the server the lastest 50 messages. 
- If we have just send out a text, immediately fetch from the server the lastest messages since the lastUpdateTime
	we will prevent entering text again until either the last update returned or some serverTimeOut(10 s) is passed.
- If we have not been sending messages then
	if chat window is enabled then
		if the last fetched messages are Not empty
			update from server again activeUpdateInterval( 1 seconds) after the last fetching result is available or some serverTimeOut(10 s) is passed.
		else
			update from server again after activeEmptyUpdateInterval( 5 seconds)	after the last fetching result is available or some serverTimeOut(10 s) is passed.
		end
	else
		if the last fetched messages are Not empty
			update from server again passiveUpdateInterval( 5 seconds) after the last fetching result is available or some serverTimeOut(10 s) is passed.
		else
			update from server again after passiveEmptyUpdateInterval( 10 seconds)	after the last fetching result is available or some serverTimeOut(10 s) is passed.
		end
	end
  end

---++ Getting already fetched messages
Call the following method to retrieve already fetched messages. It can be called as many times by any other applications. 
such as the summon mode. It only returns from the local memory.
<verbatim>
	local msgs = Map3DSystem.App.Chat.ChannelManager.GetFetchedMessages({
		channel = nil, if nil it means from all channels,
		afterDate = nil, if nil it means the latest
		pagesize = 50, return the latest number of message after afterDate
	})
</verbatim>

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Chat/ChannelManager.lua");
Map3DSystem.App.Chat.ChannelManager.AddChannel("Channel_1")
-------------------------------------------------------
]]

-- create class
local ChannelManager = commonlib.gettable("Map3DSystem.App.Chat.ChannelManager");

-- all channel messages are stored in the channels table
-- each entry with a treeview node inside residing all the messages in that channel
-- treeview can use that node as a root node to show the messages directly
ChannelManager.channels = {};

-- text color of the default channel messages
ChannelManager.TextColors = {
		["Public"] = "FAEBD7",
		["Help"] = "ADD8E6",
		["World"] = "32CD32",
		["Chat"] = "FFC0CB",
	};

-- init the channels and the message time
function ChannelManager.Init()
	-- init channels according to chat config
	
	ChannelManager.RootTreeNode = {};
	
	-- TODO: default add the channel
	ChannelManager.AddChannel("Channel_Public", "公共频道");
	ChannelManager.AddChannel("Channel_Help", "帮助频道");
	
	-- init the NextGetMessageDate to the latest Chat connection time
	local time = ParaGlobal.GetTimeFormat("HH:mm:ss");
	local date = ParaGlobal.GetDateFormat("yyyy-M-d");
	local dateStr = date.." "..time;
end

-- init the message on UISetup
function ChannelManager.OnUISetup()

	-- update messages on init fetch the latest 50 message in the BBS
	--ChannelManager.UpdateMessages()
end

ChannelManager.CurrentFocusChannelName = nil;

-- add a channel to manager
function ChannelManager.AddChannel(channelName, channelText)
	local i, v;
	for i, v in ipairs(ChannelManager.channels) do
		if(v.Name == channelName) then
			log("Channel: "..channelName.." already exists\n");
			return;
		end
	end
	
	table.insert(ChannelManager.channels, {Name = channelName, Text = channelText, Icon = "", });
	
	local channelNode = CommonCtrl.TreeNode:new({Name = channelName, });
	ChannelManager.RootTreeNode[channelName] = channelNode;
	
	---- automaticly focus to the latest added channel
	--ChannelManager.ChangeFocusChannel(channelName)
end

-- remove a channel from manager
function ChannelManager.RemoveChannel(channelName)
	local i, v;
	for i, v in ipairs(ChannelManager.channels) do
		if(v.Name == channelName) then
			table.remove(ChannelManager.channels, i);
			
			ChannelManager.RootTreeNode[channelName] = nil;
			
			-- focus to public channel
			ChannelManager.ChangeFocusChannel("Channel_Public");
			return;
		end
	end
	log("Channel: "..channelName.." not found when trying to remove from channels\n");
end

-- get the channel root treenode, it containing all the message information
-- NOTE: this node is the root node of channel manager, all channels post information to this node
function ChannelManager.GetChannelRootTreeNode()
	--for i, v in ipairs(ChannelManager.channels) do
		--if(v.Name == channelName) then
			--return ChannelManager.channels[i];
		--end
	--end
	
	return ChannelManager.RootTreeNode;
end

-- change focus to channel
function ChannelManager.ChangeFocusChannel(channelName)
	if(channelName == "Channel_World") then
		local worldpath = ParaWorld.GetWorldDirectory();
		channelName = "Channel_World_"..worldpath;
		ChannelManager.AddChannel(channelName, "世界频道");
	end
	ChannelManager.CurrentFocusChannelName = channelName;
end

-- get focus channel text
function ChannelManager.GetFocusChannelText()
	for i, v in ipairs(ChannelManager.channels) do
		if(v.Name == ChannelManager.CurrentFocusChannelName) then
			return v.Text;
		end
	end
end

-- append the jabber chat message to the channel root node
function ChannelManager.AppendJabberChatMessage(JID, subject, body)
	local name = Map3DSystem.App.Chat.GetNameFromJID(JID);
	
	local color = ChannelManager.TextColors["Chat"];
	
	local content = string.format("<a style='color:#%s;' >[%s]</a>:<span style='color:#%s;'>%s</span>",
		color, name, color, body);
	
	--local channelNode = ChannelManager.GetChannelRootTreeNode();
	--channelNode:AddChild(CommonCtrl.TreeNode:new({
		--date = nil, 
		--uid = nil, 
		--content = content, 
		--}));
end

-- common show update interval
local isProcessing = false; -- is web service processing
ChannelManager.CommonShowUpdateInterval = 500; -- in milliseconds

-- update 0.1 second after text sent
ChannelManager.TextSentUpdateLatency = 100;

local _elapsedtime = 0;
local _currentTime = 0; --  only for deltatime

-- get all messages from all channels
function ChannelManager.UpdateMessages()
	
	local t = ParaGlobal.GetGameTime(); -- in milliseconds
	local deltaTime = t - _currentTime;
	_currentTime = t;
	
	if(isProcessing == false) then
		
		_elapsedtime = _elapsedtime + deltaTime;
		
		if(_elapsedtime >= ChannelManager.CommonShowUpdateInterval) then
			isProcessing = true;
		else
			return;
		end
	else
		return;
	end
	
	local k, v;
	for k, v in ipairs(ChannelManager.channels) do
		-- update messages from each channel
		local channelName = v.Name;
		local channelText = v.Text;
		local channelNode = ChannelManager.GetChannelRootTreeNode()[channelName];
		local msg = {
			sessionkey = Map3DSystem.User.sessionkey,
			channel = channelName,
			afterDate = v.NextGetMessageDate,
			pageindex = 0,
			pagesize = 50,
		};
		
		if(not Map3DSystem.User.IsAuthenticated) then
			_elapsedtime = 0;
			isProcessing = false;
			return;
		end
		
		paraworld.lobby.GetBBS(msg, "GetLobbyBBSChannelMessages"..channelName, function(msg)
			--log("getlobbymessage "..channelName.."\n");
			--log(commonlib.serialize(msg));
			
			_elapsedtime = 0;
			isProcessing = false;
			
			if(msg) then
				--log("GetBBSmsg: ");
				--commonlib.echo(msg)
				if(msg.errorcode) then
					log("GetBBS error on channel:"..channelName..", errorcode:"..msg.errorcode.."\n")
					return;
				end
				
				local channelName = msg.channel;
				if(msg.msgs) then
					-- append messages to the channel node
					local i, n;
					for i, n in ipairs(msg.msgs) do
						local color = "808080";
						if(channelName == "Channel_Public") then
							color = ChannelManager.TextColors["Public"];
						elseif(channelName == "Channel_Help") then
							color = ChannelManager.TextColors["Help"];
						elseif(string.find(channelName, "Channel_World")) then
							color = ChannelManager.TextColors["World"];
						end
						local contentPlusChannelName = string.format("<span style='color:#%s;' >[%s]</span>%s",
							color, channelText, n.content);
						
						channelNode:AddChild(CommonCtrl.TreeNode:new({
							date = n.date, 
							uid = n.uid, 
							content = contentPlusChannelName, 
							}));
						-- update the NextGetMessageDate
						v.NextGetMessageDate = n.date;
					end
				end
			end
		end);
	end
end

-- post message to the current focus channel
-- @param content: the message content
function ChannelManager.PostMessage(contentStr)
	
	--ChannelManager.lastMSGSentTime = ParaGlobal.GetGameTime(); -- in milliseconds
	
	-- force update
	-- TRICKY: this will delay the auto update
	_elapsedtime = ChannelManager.CommonShowUpdateInterval - ChannelManager.TextSentUpdateLatency;
	isProcessing = false;
	
	local channelName = Map3DSystem.App.Chat.ChannelManager.CurrentFocusChannelName;
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		channel = channelName,
		content = contentStr,
	};
	paraworld.lobby.PostBBS(msg, "PostLobbyBBSChannelMessage", function(msg)
		-- commonlib.log(msg);
		-- TODO for andy 2008.6.27: inform failure, only allows enter subsequent text when this returns?. 
	end);
end


---- fetch messages
---- NOTE: fetch latest message broadcast on all channels between this function call and the last function call
---- @return: {[1] = {uid, content, date}, [2] = ... }
----		if uid is nil, it is a jabber client message
--function ChannelManager.FetchMessages()
	--
	--local channelNode = ChannelManager.GetChannelRootTreeNode();
	--
	--ChannelManager.LastFetchMessagesIndex = ChannelManager.LastFetchMessagesIndex or 0;
	--
	--local nCount = channelNode:GetChildCount();
	--
	--local i;
	--local msgs = {};
	--for i = ChannelManager.LastFetchMessagesIndex + 1, nCount do 
		--local node = channelNode:GetChild(i);
		--table.insert(msgs, {uid = node.uid, content = node.content, date = node.date});
	--end
	--
	--ChannelManager.LastFetchMessagesIndex = nCount;
	--
	--return msgs;
--end
--