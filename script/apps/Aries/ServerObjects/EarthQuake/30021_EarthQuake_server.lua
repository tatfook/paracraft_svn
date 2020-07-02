--[[
Title: Server agent template class
Author(s): 
Date: 2009/11/15
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/EarthQuake/30021_EarthQuake_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local EarthQuake_server = {}

Map3DSystem.GSL.config:RegisterNPCTemplate("earthquake", EarthQuake_server)

local shaketimes = {
	{shaked = false, time = "11:55", shakerange = {"11-45", "12-05"},},
	{shaked = false, time = "13:05", shakerange = {"12-55", "13-15"},},
	{shaked = false, time = "17:00", shakerange = {"16-50", "17-10"},},
	{shaked = false, time = "20:30", shakerange = {"20-20", "20-40"},},
	
	
	-- DEBUG purpose:
	--{shaked = false, time = "11:17", shakerange = {"20-20", "20-40"},},
};

--local i = 10;
--for i = 10, 23 do
	--table.insert(shaketimes, {shaked = false, time = i..":".."10", shakerange = {"??-??", "??-??"},});
	--table.insert(shaketimes, {shaked = false, time = i..":".."25", shakerange = {"??-??", "??-??"},});
	--table.insert(shaketimes, {shaked = false, time = i..":".."40", shakerange = {"??-??", "??-??"},});
	--table.insert(shaketimes, {shaked = false, time = i..":".."55", shakerange = {"??-??", "??-??"},});
--end

local currentTime = 0;

function EarthQuake_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = EarthQuake_server.OnNetReceive;
	self.OnFrameMove = EarthQuake_server.OnFrameMove;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = EarthQuake_server.AddRealtimeMessage;
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function EarthQuake_server:OnNetReceive(from_nid, gridnode, msg, revision)
	---- echo real time message to client
	--self:AddRealtimeMessage(msg)
end

local nextupdate_time = 0;

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function EarthQuake_server:OnFrameMove(curTime, revision)
	if(curTime > nextupdate_time) then
		nextupdate_time = curTime + 10000;
		
		local time = ParaGlobal.GetTimeFormat("HH:mm");
		
		local i;
		for i = 1, #shaketimes do
			local shaketime = shaketimes[i];
			if(time == shaketime.time and shaketime.shaked == false) then
				shaketime.shaked = true;
				-- boardcast to all hosting clients
				local msg = "[Aries][ServerObject30021]shaketownass";
				self:AddRealtimeMessage(msg);
			end
		end
	end
	
	
	--local old_value = self:GetValue("versioned_data");
	--old_value.nCount = old_value.nCount + 1;
	--self:SetValue("versioned_data", old_value, revision);
end