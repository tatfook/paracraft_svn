--[[
Title: 
Author(s):  WangTian
Date: 2009/4/7
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/BigDipper/30051_BigDipper_client.lua");
------------------------------------------------------------
]]

-- the following are only debug purpose loads, the aries related files are loaded right after startup
NPL.load("(gl)script/apps/Aries/app_main.lua");
NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
NPL.load("(gl)script/apps/Aries/Pet/main.lua");
NPL.load("(gl)script/apps/Aries/Scene/EffectManager.lua");
NPL.load("(gl)script/apps/Aries/NPCs/Carnival/30051_BigDipper.lua");
local BigDipper = commonlib.gettable("MyCompany.Aries.Quest.NPCs.BigDipper");
local string_find = string.find;
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber

-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local BigDipper_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("bigdipper", BigDipper_client)

local slot_count = 20;

function BigDipper_client.CreateInstance(self)
	self.OnNetReceive = BigDipper_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
	
	-- TODO: add your proviate per instance data here
	self.private_data = {some_per_instance_data_here};
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function BigDipper_client:OnNetReceive(client, msgs)
	local BigDipper = BigDipper;
	if(BigDipper.inited ~= true) then
		BigDipper.inited = true;
		BigDipper.main();
	end
	
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			if(string_find(msg, "%[Aries%]") == 1) then
				-- start up the big dipper
				local slots_value = string.match(msg, "^%[Aries%]%[ServerObject30051%]StartUp:([,0123456789]+)$");
				if(slots_value) then
					-- start the dipper
					BigDipper.StartUp();
					
					-- set all dipper slots with users
					local start = 1;
					local finish = slot_count;
					local index = start;
					local nid;
					local nids = {};
					for nid in string.gfind(slots_value, "([^,]+)") do
						
						nid = tonumber(nid);
						table.insert(nids, nid);
						if(nid ~= 0) then
							BigDipper.MountUserOnSlot(tonumber(nid), index);
						end
						
						index = index + 1;
						if(index > finish) then
							break;
						end
					end
					BigDipper.OnUpdateSlotValues(nids);
					
					--_guihelper.MessageBox("startup with "..slots_value);
				end
				-- poll result
				local slots_value = string.match(msg, "^%[Aries%]%[ServerObject30051%]PollResult:([%-,0123456789]+)$");
				if(slots_value) then
					local start = 1;
					local finish = slot_count;
					local index = start;
					local nid;
					local nids = {};
					local winner = "";
					for nid in string.gfind(slots_value, "([^,]+)") do
						nid = tonumber(nid);
						-- append the polling nid and set winner
						if(nid > 0) then
							table.insert(nids, nid);
						elseif(nid < 0) then
							table.insert(nids, -nid);
							winner = -nid;
						end
						index = index + 1;
						if(index > finish) then
							break;
						end
					end
					
					-- visualize the poll process and set winner
					BigDipper.OnRecvPollResult(nids, winner);
				end
				-- empty poll result
				local bEmptyPollResult = string_find(msg, "^%[Aries%]%[ServerObject30051%]PollResult:$");
				if(bEmptyPollResult) then
					BigDipper.OnRecvEmptyPollResult();
				end
				
				-- big dipper is still running
				local bDipperRunning = string_find(msg, "^%[Aries%]%[ServerObject30051%]DipperRunning$");
				if(bDipperRunning) then
					BigDipper.OnRecvDipperRunning();
				end
				-- big dipper is queued successfully
				local bGetTicketSuccess = string_find(msg, "^%[Aries%]%[ServerObject30051%]GetTicketSuccess$");
				if(bGetTicketSuccess) then
					BigDipper.OnRecvGetTicketSuccess();
				end
				-- big dipper is full
				local bDipperFull = string_find(msg, "^%[Aries%]%[ServerObject30051%]DipperFull$");
				if(bDipperFull) then
					BigDipper.OnRecvDipperFull();
				end
				-- user already has the ticket
				local bAlreadyGetTicket = string_find(msg, "^%[Aries%]%[ServerObject30051%]AlreadyGetTicket$");
				if(bAlreadyGetTicket) then
					BigDipper.OnRecvAlreadyGetTicket();
				end
				-- ticket is dropped successfully
				local bDropTicketSuccess = string_find(msg, "^%[Aries%]%[ServerObject30051%]DropTicketSuccess$");
				if(bDropTicketSuccess) then
					BigDipper.OnRecvDropTicketSuccess();
				end
			end
		end
	elseif(msgs == nil) then
		local countdown = self:GetValue("countdown");
		BigDipper.OnUpdateCountdown(countdown);
		
		local slots_value = self:GetValue("slots");
		if(slots_value) then
			-- set all users that have ticket
			local start = 1;
			local finish = slot_count;
			local index = start;
			local nid;
			local nids = {};
			for nid in string.gfind(slots_value, "([^,]+)") do
				nid = tonumber(nid)
				table.insert(nids, nid);
				index = index + 1;
				if(index > finish) then
					break;
				end
			end
			BigDipper.OnUpdateSlotValues(nids);
		end
	end
	
	-- self:AddRealTimeMessage(self.id, msg);
	
	-- one can send real time message to self.id on the server side. 
	-- self:GetValue();
end

--function BigDipper_client.TryPickObject(instance_id)
	--client:AddRealtimeMessage("[Aries][ServerObject30051]TryPickObj:"..instance_id);
--end