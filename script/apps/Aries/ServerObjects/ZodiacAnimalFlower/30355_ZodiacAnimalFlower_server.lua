--[[
Title: Server agent template class
Author(s): 
Date: 2009/11/15
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/ZodiacAnimalFlower/30355_ZodiacAnimalFlower_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local ZodiacAnimalFlower_server = {}

Map3DSystem.GSL.config:RegisterNPCTemplate("zodiacanimalflower", ZodiacAnimalFlower_server)

local bloomperiods = {
	{bloomed = false, opentime = "11:00", closetime = "12:00", },
	{bloomed = false, opentime = "15:00", closetime = "20:00", },
	{bloomed = false, opentime = "20:00", closetime = "21:00", },
	
	-- DEBUG purpose:
	--{bloomed = false, opentime = "20:00", closetime = "21:00", },
};

---- DEBUG purpose:
--local hour;
--for hour = 8, 23 do
	--local minute;
	--for minute = 1, 29 do
		--table.insert(bloomperiods, {
			--bloomed = false, 
			--opentime = hour..":"..string.format("%02d", minute * 2 - 1), 
			--closetime = hour..":"..string.format("%02d", minute * 2), 
		--});
	--end
--end

local currentTime = 0;

function ZodiacAnimalFlower_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = ZodiacAnimalFlower_server.OnNetReceive;
	self.OnFrameMove = ZodiacAnimalFlower_server.OnFrameMove;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = ZodiacAnimalFlower_server.AddRealtimeMessage;
	
	-- update the normal update bloomed
	self:SetValue("bloomed", "false", revision);
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function ZodiacAnimalFlower_server:OnNetReceive(from_nid, gridnode, msg, revision)
	---- echo real time message to client
	--self:AddRealtimeMessage(msg)
end

local nextupdate_time = 0;

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function ZodiacAnimalFlower_server:OnFrameMove(curTime, revision)
	if(curTime > nextupdate_time) then
		nextupdate_time = curTime + 10000;
		
		local time = ParaGlobal.GetTimeFormat("HH:mm");
		
		local i;
		for i = 1, #bloomperiods do
			local bloomperiod = bloomperiods[i];
			if(time == bloomperiod.opentime and bloomperiod.bloomed == false) then
				bloomperiod.bloomed = true;
				-- update the normal update bloomed
				self:SetValue("bloomed", "true", revision);
				self:SetValue("bloomperiod_opentime", bloomperiod.opentime, revision);
				local random_animal = tostring(math.random(1, 12));
				self:SetValue("random_animal", random_animal, revision);
				-- boardcast to all hosting clients
				local msg = "[Aries][ServerObject30355]FlowerOpen:"..random_animal;
				self:AddRealtimeMessage(msg);
			end
			if(time == bloomperiod.closetime and bloomperiod.bloomed == true) then
				bloomperiod.bloomed = false;
				-- update the normal update bloomed
				self:SetValue("bloomed", "false", revision);
				self:SetValue("bloomperiod_opentime", bloomperiod.opentime, revision);
				self:SetValue("random_animal", "0", revision);
				-- boardcast to all hosting clients
				local msg = "[Aries][ServerObject30355]FlowerClose";
				self:AddRealtimeMessage(msg);
			end
		end
	end
	
	
	--local old_value = self:GetValue("versioned_data");
	--old_value.nCount = old_value.nCount + 1;
	--self:SetValue("versioned_data", old_value, revision);
end