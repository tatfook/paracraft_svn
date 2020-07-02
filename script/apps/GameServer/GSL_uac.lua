--[[
Title: user access control module in GSL
Author(s): LiXizhi
Date: 2011/2/24
Desc: create a uac object to filter by nid. For example, we can let all nid whose ip is from intranet to pass. 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_uac.lua");
local uac = Map3DSystem.GSL.GSL_uac:new();
uac:SetUAC("admin");
uac:SetUAC("intranet");
if(uac:check_nid("some_nid_1234")) then
end
-----------------------------------------------
]]
local tostring = tostring;
local GSL_uac = commonlib.gettable("Map3DSystem.GSL.GSL_uac");

function GSL_uac:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- set the uac function 
-- @param uac: if "intranet", it means that the nid must be connected with ip "192.168.*" or "127.0.*"
--  if "admin", it means it can be "intranet" or from a list of predefined nids. 
--  if it is "file:[filename]", then it is filename to be loaded, such as  "file:config/Aries/uac/uac_dev.txt"
--  if "everyone", all is allowed. 
function GSL_uac:SetUAC(uac)
	if(uac == "intranet") then
		self.check_nid = GSL_uac.UAC_intranet;
	elseif(uac == "admin") then
		self.check_nid = GSL_uac.UAC_admin;
	elseif(uac == "everyone") then
		self.check_nid = GSL_uac.UAC_everyone;
	else
		local nid_file = uac:match("^file:(.+)$");
		if(nid_file) then
			self.nids = {};
			-- TODO: local file to self.nids
			self.check_nid = GSL_uac.UAC_nid_group;
		end
	end
end

-- virtual: this function will be overwritten. 
function GSL_uac:check_nid(nid)
	return true;
end

-- check_nid function for uac type "intranet"
function GSL_uac:UAC_intranet(nid)
	if(nid) then
		nid = tostring(nid);
		local ip = NPL.GetIP(nid);
		if(ip and (ip:match("^192%.168") or ip:match("^127%.0") or ip:match("^10%."))) then
			-- commonlib.echo("good ip "..ip)
			return true;
		end
	end
end

-- TODO: load admin nids from a local file. 
local admin_nids = {
	["14861822"] = true, -- xizhi
	["46650264"] = true, -- andy
	["800015"] = true, -- Xizhi, taiwan
	["800017"] = true, -- andy, taiwan
};

-- this is a combo of intranet or admin nids
-- check_nid function for uac type "admin"
function GSL_uac:UAC_admin(nid)
	if(nid) then
		return self:UAC_intranet(nid) or admin_nids[nid];
	end
end

-- check_nid function for uac type "file:[filename]"
function GSL_uac:UAC_nid_group(nid)
	if(nid) then
		nid = tostring(nid);
		if(self.nids[nid]) then
			return true;
		end
	end
end

-- allows everyone
function GSL_uac:UAC_everyone(nid)
	return true;
end

