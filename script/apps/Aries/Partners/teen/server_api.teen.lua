--[[
Title: Login api for teen
Author: spring
Date: 2011.11.17
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/Aries/Partners/teen/server_api.lua");
-----------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua"); 
local server_api = commonlib.gettable("MyCompany.Aries.Partners.teen.server_api");

NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
local user_table={};
local is_inited;

function server_api.init()	
	if(is_inited) then
		return
	end
	-- 临时用 user.passwd 作为用户帐号认证
	local fin=ParaIO.open("users.passwd","r");
	while true do
		local lines =fin:readline();			
		if not lines then break end;
			
		local l_userid, l_passwd = string.match(lines,"^(%d+),(.+)$");
		local l_user={user=l_userid, passwd=l_passwd};
		table.insert(user_table,l_user);
	end -- while   
	fin:close();
	is_inited = true;	
end

function server_api.on_loginrequest(msg)
	server_api.init();

	-- invoke the rest 
	local callback = msg.callback;
	local forward = msg.forward;

	local username=	msg.params.user;
	local passwd = string.lower(msg.params.passwd);

	local index;
	local result=505;
	for index in ipairs(user_table) do     
		local c_user = user_table[index].user;
		-- local c_passwd = ParaMisc.md5(user_table[index].passwd);
		local c_passwd = string.lower(user_table[index].passwd);
		if (c_user == username and c_passwd==passwd) then
			result=0;
			break;
		end
	end
	LOG.std(nil,"debug","teen.on_loginrequest",msg);
	LOG.std(nil,"debug","teen.on_login result",result);

	local outputmsg={};

	local sessionid = passwd; -- 临时用 passwd 作为 sessionid 返回

	if(result==0) then  -- login successfull
		outputmsg.email = username;
		outputmsg.sessionid = sessionid;
		outputmsg.result=0;
		outputmsg.gameflag="true";
		local display_nid= username;
		outputmsg.nid= tonumber(display_nid);
	else
		if (result==505)then
			outputmsg.result = 407;  -- user or passwd wrong
		else
			outputmsg.result = 501;  -- other error
		end				
	end
	outputmsg.forward = forward;
	LOG.std(nil,"debug","auth_teen_callbackmsg",outputmsg);
	NPL.activate(callback,outputmsg);		
end