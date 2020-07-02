--[[
Title: PartnerUserAPI for all
Author: LiXizhi
Date: 2011.6.17
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/Aries/Partners/PartnerUserAPI.lua");

local worker = NPL.CreateRuntimeState("d1", 0);
worker:Start();
NPL.activate("(d1)script/apps/Aries/Partners/PartnerUserAPI.lua", {action="login", params={from=1, user="spring", passwd="aispring" }});
-----------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua"); 
NPL.load("(gl)script/apps/Aries/Partners/qvod/server_api.lua");

local PartnerUserAPI = commonlib.gettable("MyCompany.Aries.Partners.PartnerUserAPI");

local function activate()
	local msg=msg;
	local action = msg.action;
	local params=msg.params or {};

	-- remove this when ready
	LOG.std(nil, "debug", "PartnerUserAPI", msg);

	local from;
	if (next(params) ~= nil) then
		from = params.from;
	end
	if (from) then
		from = tonumber(from);
		if (from==0) then  --taomee
			NPL.activate("TMInterface.dll",msg);
		elseif (from==2) then  -- kuaiwan
			if (action=="login") then
				LOG.std(nil,"system","PartnerUserAPI",msg);
				MyCompany.Aries.Partners.qvod.server_api.on_loginrequest(msg);
			elseif  (action=="getuserinfo") then
				LOG.std(nil,"system","PartnerUserAPI",msg);
				MyCompany.Aries.Partners.qvod.server_api.on_getuserinfo(msg);
			end
		elseif (from==3 and action=="login") then  -- teen
			NPL.load("(gl)script/apps/Aries/Partners/teen/server_api.teen.lua");
			LOG.std(nil,"system","PartnerUserAPI",msg);
			MyCompany.Aries.Partners.teen.server_api.on_loginrequest(msg);
		end
	else
		NPL.activate("TMInterface.dll",msg);
	end
end

NPL.this(activate);
