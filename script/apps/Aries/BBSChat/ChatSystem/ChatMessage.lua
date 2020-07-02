--[[
Title: Chat Message Struct
Author(s): LiXizhi
Date: 2011/3/14
Desc:  The compressor is also here
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatMessage.lua");
local ChatMessage = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatMessage");
ChatMessage.CompressMsg({ChannelIndex=1, fromschool="fire", words="谢谢"})
-------------------------------------------------------
]]
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
local ChatMessage = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatMessage");

local chat_msg_codec;
local server_msg_codec;

-- call this function once
function ChatMessage.GetCodec()	
	if(not chat_msg_codec) then
		NPL.load("(gl)script/ide/Codec/TableCodec.lua");
		local TableCodec = commonlib.gettable("commonlib.TableCodec");
		chat_msg_codec = TableCodec:new();

		NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/BattleQuickWord.lua");
		local BattleQuickWord = commonlib.gettable("MyCompany.Aries.ChatSystem.BattleQuickWord");
		local default_words = BattleQuickWord.GetQuickWordAsArray()

		-- tell the codec how to compress the data
		chat_msg_codec:AddFields({
			{name="ChannelIndex", default_value=ChatChannel.EnumChannels.NearBy},
			{name="from", default_value=nil},
			{name="fromname", default_value=nil},
			{name="fromisvip", default_value=nil},
			{name="fromschool", default_value=nil, frequent_values={"fire", "ice", "storm","life", "death","myth", "balance"}},
			{name="to", default_value=nil},
			{name="toname", default_value=nil},
			{name="toisvip", default_value=nil},
			{name="toschool", default_value=nil, frequent_values={"fire", "ice", "storm","life", "death","myth", "balance"}},
			{name="words", default_value=nil, frequent_values=default_words},
		});
	end
	return chat_msg_codec;
end

function ChatMessage.GetCodecServer()	
	if(not server_msg_codec) then
		NPL.load("(gl)script/ide/Codec/TableCodec.lua");
		local TableCodec = commonlib.gettable("commonlib.TableCodec");
		server_msg_codec = TableCodec:new();

		-- tell the codec how to compress the data
		server_msg_codec:AddFields({
			{name="ChannelIndex", default_value=ChatChannel.EnumChannels.NearBy},
			{name="from", default_value=nil},
			{name="fromname", default_value=nil},
			{name="fromisvip", default_value=nil},
			{name="fromschool", default_value=nil, frequent_values={"fire", "ice", "storm","life", "death","myth", "balance"}},
			{name="to", default_value=nil},
			{name="toname", default_value=nil},
			{name="toisvip", default_value=nil},
			{name="toschool", default_value=nil, frequent_values={"fire", "ice", "storm","life", "death","myth", "balance"}},
		});
	end
	return server_msg_codec;
end

-- convert from string to message data
function ChatMessage.DecompressMsgServer(msg_str)	
	if(type(msg_str) == "string") then
		local codec = ChatMessage.GetCodecServer();
		return codec:Decode(msg_str);
	end
end


-- convert from message data to string
function ChatMessage.CompressMsg(msg_data)
	if(type(msg_data) == "table") then
		local codec = ChatMessage.GetCodec();
		local str = codec:Encode(msg_data);
		if(str) then
			-- remove any "\\\r", "\\\n" in code since gsl string forbid it. 
			str = str:gsub("\\[\r\n]", "");
		end
		return str;
	end
end

-- convert from string to message data
function ChatMessage.DecompressMsg(msg_str)	
	if(type(msg_str) == "string") then
		local codec = ChatMessage.GetCodec();
		return codec:Decode(msg_str);
	end
end