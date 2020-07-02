--[[
Title: Login and payment api for qvod
Author: LiXizhi
Date: 2011.6.17
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/Aries/Partners/qvod/server_api.lua");
-----------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua"); 
local server_api = commonlib.gettable("MyCompany.Aries.Partners.qvod.server_api");

NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

local is_inited;

function server_api.init()	
	if(is_inited) then
		return
	end

--	NPL.load("(gl)script/apps/GameServer/rest_webservice_wrapper.lua");
--	NPL.load("(gl)script/kids/3DMapSystemApp/API/webservice_wrapper.lua");

--	paraworld.CreateRESTJsonWrapper("paraworld.qvod.auth", "http://login.api.kuaiwan.com/s2s/game/login/");
	is_inited = true;	
end

function server_api.on_loginrequest(msg)
	server_api.init();

	-- invoke the rest 
	local callback = msg.callback;
	local forward = msg.forward;
	local isTeenVer=msg.params.v;
	if (isTeenVer) then
		isTeenVer=tonumber(isTeenVer)
	else
		isTeenVer=0;
	end
	local kw_siteid="SZPE";
	local kw_gameid="8000008";
	local kw_key="51B4507D258DE690ECBF725200297142";

	if (isTeenVer==1) then
		kw_siteid="PRAQ";
		kw_gameid="93496";
		kw_key="A6B44822C6F885305BE74D854C57DC0E";	
	else
		kw_siteid="SZPE";
		kw_gameid="8000008";
		kw_key="51B4507D258DE690ECBF725200297142";
	end
	local utime = ParaGlobal.timeGetTime();
	local username=	msg.params.user;
	local passwd = msg.params.passwd;
	local ip = msg.params.ip;

	-- kuaiwan super passwd ÐèÒªÓÃ¶ÌºÅÂëµÇÂ¼
	if (string.lower(ParaMisc.md5(passwd))=="618ba5293ccbc236160b51902c53446b" and (ip=="119.145.5.34" or ip=="192.168.0.61" or ip=="192.168.0.113" or ip=="192.168.0.60" or ip=="192.168.0.105")) then
		local outputmsg={};
		outputmsg.email = "";
		outputmsg.result=0;
		outputmsg.gameflag="true";
		local display_nid=string.match(username,"(%d+)") or "0";
		outputmsg.nid= tonumber(display_nid);
		outputmsg.forward = forward;
		LOG.std(nil,"debug","auth_kuaiwan_callbackmsg",outputmsg);
		NPL.activate(callback,outputmsg);
		return
	end

	local codeparam="game_id="..kw_gameid.."&key="..kw_key.."&key_ver=0&site_id="..kw_siteid.."&time="..utime.."&user_name="..username.."&user_password="..passwd;
	local codesign=string.lower(ParaMisc.md5(codeparam));			
	local inputmsg=	{
		site_id = kw_siteid,
		user_name = username,
		user_password = passwd,
		game_id = kw_gameid,
		key_ver = "0",
		time = utime,
		sign = codesign,
		fields = "session_id,real_name",
		format = "json",
	};
	LOG.std(nil,"debug","qvod.on_loginrequest",inputmsg);

	local outputmsg={};
--	paraworld.qvod.auth(inputmsg,"test",function (resultmsg)
	paraworld.auth.qvod(inputmsg,"qvod_auth",function (resultmsg)
		LOG.std(nil,"debug","kuaiwan_resultms",resultmsg);
		if(resultmsg ~= nil) then
			local result = tonumber(resultmsg.result);
			if(result==1) then  -- login successfull
				outputmsg.email = resultmsg.email or username;
				outputmsg.sessionid=resultmsg.session_id;
				outputmsg.real_name=resultmsg.real_name;
				outputmsg.result=0;
				outputmsg.gameflag="true";
				local display_nid=string.match(resultmsg.user_id,"kw_(%d+)");
				outputmsg.nid= tonumber(display_nid);
			else
				if (result==505)then
					outputmsg.result = 407;  -- user or passwd wrong
				else
					outputmsg.result = 501;  -- other error
				end				
			end
		end
		outputmsg.forward = forward;
		LOG.std(nil,"debug","auth_kuaiwan_callbackmsg",outputmsg);
		NPL.activate(callback,outputmsg);
		
	end);
end

function server_api.on_getuserinfo(msg)
	server_api.init();

	-- invoke the rest 
	local callback = msg.callback;
	local forward = msg.forward;
	local isTeenVer=msg.params.v;
	if (isTeenVer) then
		isTeenVer=tonumber(isTeenVer)
	else
		isTeenVer=0;
	end

	local kw_siteid="SZPE";
	local kw_gameid="8000008";
	local kw_key="51B4507D258DE690ECBF725200297142";
	if (isTeenVer==1) then
		kw_siteid="PRAQ";
		kw_gameid="93496";
		kw_key="A6B44822C6F885305BE74D854C57DC0E";	
	else
		kw_siteid="SZPE";
		kw_gameid="8000008";
		kw_key="51B4507D258DE690ECBF725200297142";
	end

	local utime = ParaGlobal.timeGetTime();
	local username=	msg.forward.data_table.req.username;
	local passwd = msg.forward.data_table.req.password;

	local codeparam="game_id="..kw_gameid.."&key="..kw_key.."&key_ver=0&site_id="..kw_siteid.."&time="..utime.."&user_name="..username.."&user_password="..passwd;
	local codesign=string.lower(ParaMisc.md5(codeparam));			
	local inputmsg=	{
		site_id = kw_siteid,
		user_name = username,
		user_password = passwd,
		game_id = kw_gameid,
		key_ver = "0",
		time = utime,
		sign = codesign,
		fields = "session_id,real_name",
		format = "json",
	};
	LOG.std(nil,"debug","qvod.on_getuserinfo",inputmsg);

	local outputmsg={};
--	paraworld.qvod.auth(inputmsg,"test",function (resultmsg)
	paraworld.auth.qvod(inputmsg,"test",function (resultmsg)
		LOG.std(nil,"debug","kuaiwan_getuserinfo",resultmsg);
		if(resultmsg ~= nil) then
			local result = tonumber(resultmsg.result);
			if(result==1) then  -- login successfull
				outputmsg.realname = resultmsg.real_name;
				outputmsg.sex=0;
				outputmsg.birthday=0;
				outputmsg.result=0;
				outputmsg.idno=0;
				local display_nid=string.match(resultmsg.user_id,"kw_(%d+)");
				outputmsg.nid= tonumber(display_nid);
			else
				if (result==505)then
					outputmsg.result = 407;  -- user or passwd wrong
				else
					outputmsg.result = 501;  -- other error
				end				
			end
		end
		outputmsg.forward = forward;
		LOG.std(nil,"debug","auth_kuaiwan_callbackmsg",outputmsg);
		NPL.activate(callback,outputmsg);
		
	end);
end