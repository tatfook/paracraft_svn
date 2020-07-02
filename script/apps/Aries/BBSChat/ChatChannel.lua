--[[
Title: 
Author(s): zrf
Date: 2011/3/8
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/BBSChat/ChatChannel.lua");
MyCompany.Aries.ChatChannel.AppendChat(2,191822478,"oo~00",191822478,"恋上天山雪","saldglsa;dgsdgdsg");
commonlib.echo( MyCompany.Aries.ChatChannel.GetChat(2) );
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/Encoding.lua");
--NPL.load("(gl)script/apps/Aries/Team/TeamMembersPage.lua");

local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatChannel");
local Encoding = commonlib.gettable("commonlib.Encoding");
local VIP = commonlib.gettable("MyCompany.Aries.VIP");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
--local TeamMembersPage = commonlib.gettable("MyCompany.Aries.Team.TeamMembersPage");

ChatChannel.channels = {
--{name=""},
{name="附近",bshow=true,color="ffff99",},
{name="小队",bshow=true,color="6699ff",},
{name="单聊",bshow=true,color="FF00FF",},
{name="家族",bshow=true,color="00B050",},
{name="团队",bshow=true,color="ffa74f",},
{name="地区",bshow=true,color="0099cc",},
{name="组队",bshow=true,color="00ffc8",},
{name="交易",bshow=true,color="ff89be",},
{name="本服广播",bshow=true,color="ff89be",},
{name="跨服广播",bshow=true,color="ff89be",},
{name="系统广播",bshow=true,color="ff89be",},
};

ChatChannel.chatmaxcount = 200;
ChatChannel.chatdata = ChatChannel.chatdata or {};


--[[---------------------------------------------------------------------------------------------------
设置聊天记录有新消息时的回调函数
--]]---------------------------------------------------------------------------------------------------
function ChatChannel.SetAppendEventCallback(callback)
	ChatChannel.callback = callback;
end


--[[---------------------------------------------------------------------------------------------------
设置消息发送的过滤器,用户发送消息时会根据AddFilter的顺序来依次调用回调函数
--]]---------------------------------------------------------------------------------------------------
function ChatChannel.AddFilter(callback)
	if(type(callback)~="function")then
		commonlib.echo("error: callback 必须是个回调函数 in ChatChannel.AddFilter");
		return;
	end

	if(ChatChannel.WordsFilter== nil)then
		ChatChannel.WordsFilter = {};
	end

	table.insert( ChatChannel.WordsFilter, callback );
end



--[[---------------------------------------------------------------------------------------------------
设置聊天记录有新消息时的回调函数的过滤器,只有接受到指定频道的新消息才会触发SetAppendEventCallback设置的回调函数

	ChannelIndexAssemble:	nil		无过滤器,任何新消息都会触发
							table	包含多个频道的数组,只有该数组包含的频道新消息才会触发,如{2,3,4}
							number	指定单个频道,只有该频道新消息能触发回调
--]]---------------------------------------------------------------------------------------------------
function ChatChannel.SetAppendEventCallbackFilter(ChannelIndexAssemble)
	ChatChannel.ChannelIndexAssemble = ChannelIndexAssemble;
	local i;

	if(ChannelIndexAssemble==nil)then
		for i=1,#(ChatChannel.AppendFilter) do
			ChatChannel.AppendFilter[i] = true;
		end		
	elseif(type(ChannelIndexAssemble)=="number")then
		for i=1,#(ChatChannel.AppendFilter) do
			if(ChannelIndexAssemble == i)then
				ChatChannel.AppendFilter[i] = true;
			else
				ChatChannel.AppendFilter[i] = false;
			end
		end	
	elseif(type(ChannelIndexAssemble)=="table")then
		for i=1,#(ChatChannel.AppendFilter) do
			ChatChannel.AppendFilter[i] = false;
		end		
		for i=1,#(ChannelIndexAssemble) do
			ChatChannel.AppendFilter[ChannelIndexAssemble[i]] = true;
		end		
	end
end


--[[---------------------------------------------------------------------------------------------------
往消息记录中追加新消息, 如果本消息在SetAppendEventCallbackFilter中被指定, 
将会执行SetAppendEventCallback设置的回调函数并将该消息当做参数传递进去

	ChannelIndex:	对应ChatChannel.channels中的频道索引号
	from:			消息发送者的nid
	fromname:		消息发送者的昵称
	to:				消息接收者的nid
	toname:			消息接收者的昵称
	words:			消息内容
--]]---------------------------------------------------------------------------------------------------
function ChatChannel.AppendChat(ChannelIndex, from, fromname, to, toname, words )
	local channel = ChatChannel.channels[ChannelIndex];
	if(channel == nil)then
		commonlib.echo("error: 错误的频道索引 in ChatChannel.AppendChat");
		return;
	end

	local str = "";
	if(from==nil and to)then
		str = string.format([[<div style="color:#%s">【%s】你对<pe:name nid='%s' value='%s' style="margin-left:-3px;"/>说:%s</div>]],channel.color,channel.name,to,toname, words);
	elseif(from and to==nil)then
		str = string.format([[<div style="color:#%s">【%s】<pe:name nid='%s' value='%s' style="margin-left:-3px;"/>对你说:%s</div>]],channel.color,channel.name,from,fromname, words);
	elseif(from and to )then
		str = string.format([[<div style="color:#%s">【%s】<pe:name nid='%s' value='%s' style="margin-left:-3px;"/>对<pe:name nid='%s' value='%s' style="margin-left:-3px;"/>说:%s</div>]],channel.color,channel.name,from,fromname,to,toname,words);
	else
		commonlib.echo("error: from and to must be specified in ChatChannel.AppendChat");
		return;		
	end
	
	local tmp = {ChannelIndex=ChannelIndex,from=from,to=to,words = str,};
	table.insert( ChatChannel.chatdata, tmp );

	if(#(ChatChannel.chatdata) > ChatChannel.chatmaxcount)then
		table.remove( ChatChannel.chatdata, 1 ); 
	end

	if(ChatChannel.callback and type(ChatChannel.callback)=="function" and ChatChannel.AppendFilter[ChannelIndex]==true )then
		--commonlib.echo("!!:ChatChannel.AppendChat");
		ChatChannel.callback(tmp,true);
	end
end


--[[---------------------------------------------------------------------------------------------------
获取指定频道的消息记录

	ChannelIndexAssemble:	nil		获取所有消息
							table	包含多个频道的数组,只获取数组中的包含的频道消息,如{2,3,4}
							number	指定单个频道,只获取该频道消息
--]]---------------------------------------------------------------------------------------------------
function ChatChannel.GetChat(ChannelIndexAssemble)
	local result = {};
	local i;

	if(type(ChannelIndexAssemble)==nil)then
		for i=1,#(ChatChannel.chatdata) do
			local chat = ChatChannel.chatdata[i];
			table.insert(result, chat );
		end		
	elseif(type(ChannelIndexAssemble)=="number")then
		for i=1,#(ChatChannel.chatdata) do
			local chat = ChatChannel.chatdata[i];
			if(chat.ChannelIndex == ChannelIndexAssemble)then
				table.insert(result, chat );
			end
		end
	elseif(type(ChannelIndexAssemble)=="table")then
		for i=1,#(ChatChannel.channels) do
			ChatChannel.channels[i].bshow = false;
		end
		for i=1,#(ChannelIndexAssemble) do
			ChatChannel.channels[ChannelIndexAssemble[i]].bshow = true;
		end

		for i=1,#(ChatChannel.chatdata) do
			local chat = ChatChannel.chatdata[i];
			if(ChatChannel.channels[chat.ChannelIndex].bshow==true)then
				table.insert( result, chat );
			end
		end	
	end

	return result;
end


--[[---------------------------------------------------------------------------------------------------
发送消息

	ChannelIndexAssemble:	nil		获取所有消息
							table	包含多个频道的数组,只获取数组中的包含的频道消息,如{2,3,4}
							number	指定单个频道,只获取该频道消息
--]]---------------------------------------------------------------------------------------------------
function ChatChannel.SendMsg( ChannelIndexAssemble, to, toname, words )
	if(ChatChannel.WordsFilter)then
		local i;
		for i=1,#(ChatChannel.WordsFilter) do
			local tmp = ChatChannel.WordsFilter[i];
			if(tmp and type(tmp)=="function")then
				words = tmp(ChannelIndexAssemble, to, toname, words);
			end
		end
	end



end




if(ChatChannel.AppendFilter==nil)then
	ChatChannel.AppendFilter = {};
	local i;
	for i=1,#(ChatChannel.channels) do
		table.insert( ChatChannel.AppendFilter, true );
	end
end

if(ChatChannel.ChannelIndexAssemble==nil)then
	ChatChannel.SetAppendEventCallbackFilter();
end