--[[
Title: The BBS Chat window
Author(s): WangTian
Company: ParaEnging Co. & Taomee Inc.
Date: 2009/4/10
Desc: 
Version History:
2009-8-8		by LiXizhi: simplied to use GSL. GSL will actively inform client of new messages, so no polling is needed. 
2011-1-6		by LiXizhi: all UI functions in this class is redirected to ChatWnd.html(lua) for API compatibility

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/BBSChat/BBSChatWnd.lua");
-- OBSOLETED: 
MyCompany.Aries.BBSChatWnd.Show(bShow);

-- when received a message just call
MyCompany.Aries.BBSChatWnd.AddDialog(nid, content, channel)
------------------------------------------------------------
]]
--NPL.load("(gl)script/apps/Aries/Chat/BattleChat.lua");
-- create class
NPL.load("(gl)script/apps/Aries/BBSChat/ChatWnd.lua");
NPL.load("(gl)script/ide/Encoding.lua");
local Encoding = commonlib.gettable("commonlib.Encoding");
local ChatWnd = commonlib.gettable("MyCompany.Aries.ChatWnd");

local BBSChatWnd = commonlib.gettable("MyCompany.Aries.BBSChatWnd");
BBSChatWnd.name = "AriesBBSChat";
local format = format;

-- NOTE: the Channel_Notify notification channel is depracated, the notification is unified in the notification area
-- NOTE: update the channel name at world load end and clear all channel messages 
BBSChatWnd.channels = {
	[1] = {name = "Channel_Say",	color = "000000", text = "1.当前", bShow = true, },
	[2] = {name = "Channel_World",	color = "0000FF", text = "2.本地", bShow = true, },
	[3] = {name = "Channel_Public", color = "FFFFFF", text = "3.综合", bShow = true, },
	[4] = {name = "Channel_Trade",	color = "FFD700", text = "4.交易", bShow = true, },
	[5] = {name = "Channel_Ads",	color = "FF0000", text = "5.广告", bShow = true, },
	[6] = {name = "Channel_Official", color = "FFFF00", text = "官方公告", bShow = true, },
	-- [7] = {name = "Channel_Notify",	color = "808080", text = "提示"},
};

-- current channel that the user send message to, default to 1
BBSChatWnd.CurrentChannelIndex = 1;

function BBSChatWnd.UpdateChannelName()
	local worldpath = ParaWorld.GetWorldDirectory();
	
	-- replace slash with underscore
	worldpath = string.gsub(worldpath, "/", "_");
	
	BBSChatWnd.channels[1].name = "Channel_Say_"..worldpath;
	BBSChatWnd.channels[2].name = "Channel_World_"..worldpath;
end

-- @param channels: if nil, it is the default channels.
function BBSChatWnd.ClearChannelMessges(channels)
	ChatWnd.ClearChannelMessges(channels or {1});
end

-- show or hide task bar UI
function BBSChatWnd.Show(bShow)
	if(bShow) then
		ChatWnd.ShowPage()
	else
		ChatWnd.HidePage()
	end
end

-- show or hide task bar UI
function BBSChatWnd.IsShow()
	return ChatWnd.IsShow();
end

function BBSChatWnd.ToggleHide()
	if(bShow) then
		ChatWnd.HidePage()
	else
		ChatWnd.ShowPage()
	end
end

-- public: This function is called by the GSL_client whenever it receives a message or when the current user sends out a message. 
-- @param nid: who sends the message. if nil, it is the current player 
-- @param content: chat dialog, it may be mcml string. 
-- @param channel: nil or the channel index. if nil, it is the default index 1
function BBSChatWnd.AddDialog(nid, content, channel)
	if(not content) then return end
	
	--if( MyCompany.Aries.Chat.BattleChat.IsActive() ) then
		--MyCompany.Aries.Chat.BattleChat.RecvText(nid,content,channel);
	--end

	if(string.find(content, "%[Aries%]") == 1) then
		--commonlib.echo("!!!:AddDialog 1");
			
		local nid = string.match(content, "^%[Aries%]%[UserNicknameUpdate%]:(%d+)$");
		if(nid) then
			--commonlib.echo("!!!:AddDialog 2");
				
			nid = tonumber(nid);
			BBSChatWnd.RecvUserNicknameUpdate(nid);
		end
		local nid = string.match(content, "^%[Aries%]%[UserPopularityUpdate%]:(%d+)$");
		if(nid) then
			--commonlib.echo("!!!:AddDialog 3");
				
			nid = tonumber(nid);
			BBSChatWnd.RecvUserPopularityUpdate(nid);
		end
	else
		--commonlib.echo("!!!:AddDialog 4");
		local _channel = channel;
		local channelIndex = channel or 1;
		local color = BBSChatWnd.channels[channelIndex].color;
		local channelText = BBSChatWnd.channels[channelIndex].text;
		local channel = BBSChatWnd.channels[channelIndex];
		local user_name;
		
		local player;
		if(nid == nil) then
			--commonlib.echo("!!!:AddDialog 5");

			-- current player
			local name = MyCompany.Aries.Pet.GetUserCharacterName();
			local player = ParaScene.GetObject(name);
			if(player:IsValid() == true) then
				headon_speech.Speek(player.name, content, 5);
				user_name = System.User.NickName or "我";
			end
		else
			--commonlib.echo("!!!:AddDialog 6");

			-- some other player from network.
			nid = tostring(nid);
			player = ParaScene.GetObject(nid);
			
			-- display head on text only if the character is within 60*60 meters. 
			if(player:IsValid() and player:DistanceToCameraSq()<3600) then
				headon_speech.Speek(player.name, content, 5);
			end
		end
			
		if(_channel == 3)then

			MyCompany.Aries.ChatWnd.AppendTeamChat({1,2,3}, nid, user_name, nil, content, channelText, color)
		else
			MyCompany.Aries.ChatWnd.AppendTeamChat(nil, nid, user_name, nil, content, channelText, color)

		end
	end
end


-- send a message 
-- @param force_channel: force sending using a given channel. If nil, it means the current. This can be 1 for nearby players
function BBSChatWnd.SendMSG(text, force_channel)
	-- TODO: validate the text (length and filter sensitive word) and convert to mcml if needed. 
	if(type(text) == "string" and text~="") then
		local channel = force_channel or MyCompany.Aries.ChatWnd.GetCurChannelIndex();

		BBSChatWnd.last_send_time = BBSChatWnd.last_send_time or 0;
		local curTime = ParaGlobal.timeGetTime();
		if((curTime-BBSChatWnd.last_send_time) < 3000) then
			LOG.warn("you are speaking too fast.");
			return;
		end
		BBSChatWnd.last_send_time = curTime;

		text = MyCompany.Aries.Chat.BadWordFilter.FilterString(text);
		
		if( channel == 3)then
			MyCompany.Aries.Team.TeamClientLogics:SendTeamChatMessage(text);
			--BBSChatWnd.AddDialog(nil, text, 3);
		else
			Map3DSystem.GSL_client:AddRealtimeMessage({name="chat", value=text})
			BBSChatWnd.AddDialog(nil, text);
		end
		--if(text == "whosyourdaddy") then
			--System.App.Commands.Call("File.MCMLBrowser", {url="script/apps/Aries/Debug/ResetQuestState.html", name="MyMCMLBrowser", title="MCML browser", DisplayNavBar = true, width=1000, height=700, DestroyOnClose=true});
		--else
			--Map3DSystem.GSL_client:AddRealtimeMessage({name="chat", value=text})
			--BBSChatWnd.AddDialog(nil, text);
		--end

	end	
end

function BBSChatWnd.SendUserNicknameUpdate()
	Map3DSystem.GSL_client:AddRealtimeMessage({name="chat", value="[Aries][UserNicknameUpdate]:"..System.App.profiles.ProfileManager.GetNID()});
end

function BBSChatWnd.RecvUserNicknameUpdate(nid)
	if(nid) then
		-- auto get the userinfo
		local ProfileManager = System.App.profiles.ProfileManager;
		ProfileManager.GetUserInfo(nid, "BBSChatWnd.RecvUserNicknameUpdate", function()end, "access plus 0 day");
	end
end

function BBSChatWnd.SendUserPopularityUpdate(nid)
	if(nid) then
		Map3DSystem.GSL_client:AddRealtimeMessage({name="chat", value="[Aries][UserPopularityUpdate]:"..nid});
	end
end

function BBSChatWnd.RecvUserPopularityUpdate(nid)
	-- only update popularity for friends
	if(nid and (MyCompany.Aries.Friends.IsFriendInMemory(nid) or nid == System.App.profiles.ProfileManager.GetNID())) then
		-- auto get the userinfo
		local ProfileManager = System.App.profiles.ProfileManager;
		ProfileManager.GetUserInfo(nid, "BBSChatWnd.RecvUserPopularityUpdate", function()end, "access plus 0 day");
	end
end