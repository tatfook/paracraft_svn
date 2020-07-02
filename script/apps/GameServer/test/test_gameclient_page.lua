--[[
Title: code behind for page test_gameclient_page.html
Author(s): LiXizhi
Date: 2009-10-5
Desc:  
Use Lib:
-------------------------------------------------------
script/apps/GameServer/test/test_gameclient_page.html
-------------------------------------------------------
]]
local test_gameclient_page = {};
commonlib.setfield("MyCompany.Aries.test_gameclient_page", test_gameclient_page)

NPL.load("(gl)script/apps/GameServer/GSL.lua");

---------------------------------
-- page event handlers
---------------------------------

local page;
-- init
function test_gameclient_page.OnInit()
	page = document:GetPageCtrl();
	--local name = self:GetRequestParam("name")
	--self:SetNodeValue("fileName", name);
end

local IsInited = false;
local IsStarted = false;

-- user clicks connect
function test_gameclient_page.OnClickConnect(name, values)
	if(not IsInited) then
		IsInited = true;
		
		NPL.StartNetServer("127.0.0.1", "60001");
		NPL.LoadPublicFilesFromXML();
		
		NPL.AddNPLRuntimeAddress({host = "127.0.0.1", port = "60002", nid = "gs1",});

	end	
	if(not IsStarted) then	
		-- pick a random nid each time we log in
		if(values.user_nid == "") then
			Map3DSystem.User.nid = tostring(math.floor(ParaGlobal.GetGameTime()*1000)%100000);
		else
			Map3DSystem.User.nid = values.user_nid;
		end	
		
		commonlib.echo(values);
		
		local servername = values.servername or "world1";
		if(NPL.activate_with_timeout(10, "gs1:script/apps/GameServer/test/accept_any.lua", {user_nid = Map3DSystem.GSL.GetNID()}) == 0) then
			Map3DSystem.GSL_client:LoginServer("gs1", servername, nil, values.home_nid);
			
			commonlib.applog("local game server (%s)gs1 connected", servername)
			page:SetValue("status", string.format("Success: game server connected using nid:%s", Map3DSystem.User.nid));
			IsStarted = true;
		else
			page:SetValue("status", string.format("Failed: game server cannot be connected using nid:%s", Map3DSystem.User.nid));
		end
	end	
end

-- user clicks connect
function test_gameclient_page.OnClickConnectOther(name, values)
	if(not IsInited) then
		IsInited = true;
		
		NPL.StartNetServer("127.0.0.1", "60001");
		NPL.LoadPublicFilesFromXML();
		
		NPL.AddNPLRuntimeAddress({host = values.ip, port = values.port, nid = "gs1",});

	end	
	if(not IsStarted) then	
		-- pick a random nid each time we log in
		if(values.user_nid == "") then
			Map3DSystem.User.nid = tostring(math.floor(ParaGlobal.GetGameTime()*1000)%100000);
		else
			Map3DSystem.User.nid = values.user_nid;
		end	
		
		commonlib.echo(values);
		
		local servername = values.servername or "world1";
		if(NPL.activate_with_timeout(10, "gs1:script/apps/GameServer/test/accept_any.lua", {user_nid = Map3DSystem.GSL.GetNID()}) == 0) then
			Map3DSystem.GSL_client:LoginServer("gs1", servername, nil, values.home_nid);
			
			commonlib.applog("local game server (%s)gs1 connected", servername)
			page:SetValue("status", string.format("Success: game server connected using nid:%s", Map3DSystem.User.nid));
			IsStarted = true;
		else
			page:SetValue("status", string.format("Failed: game server cannot be connected using nid:%s", Map3DSystem.User.nid));
		end
	end	
end

-- user clicks disconnect
function test_gameclient_page.OnClickDisconnect()
	if(IsStarted) then	
		IsStarted = false;
		Map3DSystem.GSL_client:LogoutServer();
		page:SetValue("status", string.format("game server DISCONNECTED using nid:%s", Map3DSystem.User.nid));
	end	
end

-- user send chat message
function test_gameclient_page.OnSendChatMessage()
	local text  = page:GetUIValue("ChatText") or "blablabla";
	Map3DSystem.GSL_client:AddRealtimeMessage({name="chat", value=text})
end

-- whether to log message to log. 
function test_gameclient_page.OnCheckDumpMessage(bChecked)
	if(bChecked) then
		Map3DSystem.GSL.dump_client_msg = true;
	else
		Map3DSystem.GSL.dump_client_msg = false;
	end	
end

NPL.load("(gl)script/apps/Aries/Chat/GSL_muc_client.lua");
function test_gameclient_page.OnSendMucMesssage()
	MyCompany.Aries.Chat.GSL_muc_client:SendMucMessage("this is an muc test message")
end

function test_gameclient_page.OnJoinMucRoom()
	MyCompany.Aries.Chat.GSL_muc_client:JoinRoom(101);
end