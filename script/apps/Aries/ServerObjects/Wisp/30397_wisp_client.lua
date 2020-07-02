--[[
Title: wisp_client
Author(s):  Gosling, rewritten by LiXizhi 2011.5.29
Date: 2010/06/11
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/Wisp/30397_wisp_client.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/app_main.lua");
NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
NPL.load("(gl)script/apps/Aries/Pet/main.lua");
NPL.load("(gl)script/apps/Aries/NPCs/Combat/30397_Wisp.lua");

local Wisp = commonlib.gettable("MyCompany.Aries.Quest.NPCs.Wisp");
local LOG = LOG;
-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local Wisp_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("wisp", Wisp_client)

function Wisp_client.CreateInstance(self)
	self.OnNetReceive = Wisp_client.OnNetReceive;
	-- load from config file
	Wisp.InitScene();
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function Wisp_client:OnNetReceive(client, msgs)
	LOG.std(nil, "debug","wisp_client",msgs);

	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			if(type(msg) == "table") then
				if(msg.type=="update") then
					local wisp_id, instances = msg.wisp_id, msg.instances;
					if(wisp_id and instances) then
						local wisp_scene = Wisp:GetScene(wispscene_id);
						if(wisp_scene) then
							local start = wisp_scene.range[1];
							local finish = wisp_scene.range[2];
							local index = start;
							local exist;
							for exist in string.gfind(instances, "([^,]+)") do
								if(exist == "1") then
									-- LOG.debug(string.format("Wisp_client:OnNetReceive,begin bo create %d",index));
									Wisp.CreateWisp(index);
								elseif(exist == "0") then
									-- LOG.debug(string.format("Wisp_client:OnNetReceive,begin bo destroy %d",index));
									Wisp.DestroyWisp(index);
								end
						
								index = index + 1;
								if(index > finish) then
									break;
								end
							end
						end
					end
				elseif(msg.type=="destroy") then
					local wisp_id = msg.wisp_id;
					if(wisp_id) then
						Wisp.DestroyWisp(wisp_id);
					end
				elseif(msg.type=="recv_wisp") then
					local wisp_id = msg.wisp_id;
					if(wisp_id) then
						Wisp.OnRecvWisp(wisp_id);
					end
				end
			end
		end
	elseif(msgs == nil) then
		-- normal update, we will refresh all wisp scenes 
		local wispscene_id;
		for wispscene_id = 1, Wisp:GetSceneCount() do
			local instances = self:GetValue("wisp"..wispscene_id);
			local wisp_scene = Wisp:GetScene(wispscene_id);
			if(instances and wisp_scene) then
				local start = wisp_scene.range[1];
				local finish = wisp_scene.range[2];
				local index = start;
				local exist;
				for exist in string.gfind(instances, "([^,]+)") do
					if(exist == "1") then
						Wisp.CreateWisp(index);
					elseif(exist == "0") then
						Wisp.DestroyWisp(index);
					end
					index = index + 1;
					if(index > finish) then
						break;
					end
				end
			end
		end
	end
end
