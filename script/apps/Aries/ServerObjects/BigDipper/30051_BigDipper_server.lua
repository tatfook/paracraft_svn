--[[
Title: Server agent template class
Author(s): 
Date: 2009/11/15
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/BigDipper/30051_BigDipper_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local BigDipper_server = {}

Map3DSystem.GSL.config:RegisterNPCTemplate("bigdipper", BigDipper_server);

local slots = {};
local slot_count = 20;

-- big dipper startup interval
local startup_interval = 300000;
-- pooling after startup
local poll_after_startup = 110000;
local poll_result = "";

local currentTime = 0;
local nextStartupTime = nil;
local nextPollTime = nil;

function BigDipper_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = BigDipper_server.OnNetReceive;
	self.OnFrameMove = BigDipper_server.OnFrameMove;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = BigDipper_server.AddRealtimeMessage;
	
	-- set init value for each slots
	local i;
	for i = 1, slot_count do
		self:SetValue("slots", BigDipper_server.GetSlotsValue(), revision);
	end
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function BigDipper_server:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		if(string.find(msg.body, "%[Aries%]") == 1) then
			local bTryGetTicket = string.find(msg.body, "^%[Aries%]%[ServerObject30051%]TryGetTicket$");
			if(bTryGetTicket) then
				if(nextStartupTime and nextPollTime) then
					if(nextStartupTime > nextPollTime) then
						-- big dipper is still running
						-- tell the user dipper is still running
						local msg = "[Aries][ServerObject30051]DipperRunning";
						self:SendRealtimeMessage(from_nid, msg);
					else
						-- big dipper is waiting for users
						-- first check if user has already got the ticket
						local i;
						for i = 1, slot_count do
							if(slots[i] == from_nid) then
								-- tell the user he has already got the ticket
								local msg = "[Aries][ServerObject30051]AlreadyGetTicket";
								self:SendRealtimeMessage(from_nid, msg);
								return;
							end
						end
						-- then check if there is any available slot
						local bQueued = false;
						local i;
						for i = 1, slot_count do
							if(slots[i] == nil) then
								slots[i] = from_nid;
								bQueued = true;
								break;
							end
						end
						if(bQueued == true) then
							-- update the value
							self:SetValue("slots", BigDipper_server.GetSlotsValue(), revision);
							-- tell the user dipper is queued successfully
							local msg = "[Aries][ServerObject30051]GetTicketSuccess";
							self:SendRealtimeMessage(from_nid, msg);
						else
							-- tell the user dipper is full
							local msg = "[Aries][ServerObject30051]DipperFull";
							self:SendRealtimeMessage(from_nid, msg);
						end
					end
				end
			end
			local bDropTicket = string.find(msg.body, "^%[Aries%]%[ServerObject30051%]DropTicket$");
			if(bDropTicket) then
				local i;
				for i = 1, slot_count do
					if(slots[i] == from_nid) then
						slots[i] = nil;
						-- update the value
						self:SetValue("slots", BigDipper_server.GetSlotsValue(), revision);
						-- tell the user the ticket is dropped successfully
						local msg = "[Aries][ServerObject30051]DropTicketSuccess";
						self:SendRealtimeMessage(from_nid, msg);
						break;
					end
				end
			end
		end
	end
	
	---- echo real time message to client
	--self:AddRealtimeMessage(msg)
end

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function BigDipper_server:OnFrameMove(curTime, revision)
	currentTime = curTime;
	-- init times
	if(not nextStartupTime) then
		nextStartupTime = curTime + startup_interval;
	end
	if(not nextPollTime) then
		nextPollTime = nextStartupTime + poll_after_startup;
	end
	-- check for bigdipper start up
	if(curTime >= nextStartupTime) then
		nextStartupTime = curTime + startup_interval;
		-- startup the bigdipper
		-- boardcast to all hosting clients
		local msg = "[Aries][ServerObject30051]StartUp:"..BigDipper_server.GetSlotsValue();
		self:AddRealtimeMessage(msg);
		-- generate poll result
		BigDipper_server.GeneratePollResult();
		-- clear all slots for next round startup
		BigDipper_server.ClearSlots()
		-- update the value
		self:SetValue("slots", BigDipper_server.GetSlotsValue(), revision);
	end
	-- check for bigdipper poll
	if(curTime >= nextPollTime) then
		nextPollTime = nextStartupTime + poll_after_startup;
		-- startup polling
		-- boardcast to all hosting clients
		local msg = "[Aries][ServerObject30051]PollResult:"..BigDipper_server.GetAndClearPollResult();
		self:AddRealtimeMessage(msg);
	end
	-- update the bigdipper start up count down
	self:SetValue("countdown", nextStartupTime - curTime, revision);
end

function BigDipper_server.ClearSlots()
	slots = {};
end

function BigDipper_server.GetSlotsValue()
	local value = "";
	local i;
	for i = 1, slot_count do
		if(slots[i]) then
			value = value..slots[i]..",";
		else
			value = value.."0,";
		end
	end
	return value;
end

function BigDipper_server.GeneratePollResult()
	local count = 0;
	local i;
	for i = 1, slot_count do
		if(slots[i]) then
			count = count + 1;
		end
	end
	
	if(count == 0) then
		poll_result = "";
	else
		local index = math.random(100, (count + 1) * 100 - 1);
		index = math.floor(index / 100);
		poll_result = "";
		local i;
		for i = 1, slot_count do
			if(slots[i]) then
				if(index == i) then
					poll_result = poll_result.."-"..slots[i]..",";
				else
					poll_result = poll_result..slots[i]..",";
				end
			end
		end
	end
end

function BigDipper_server.GetAndClearPollResult()
	local ret = poll_result;
	poll_result = "";
	return ret;
end