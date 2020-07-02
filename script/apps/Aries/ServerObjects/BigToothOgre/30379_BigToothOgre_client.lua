--[[
Title: 
Author(s):  Leio
Date: 2010/04/24
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/BigToothOgre/30379_BigToothOgre_client.lua");
------------------------------------------------------------
]]


-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local BigToothOgre_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("bigtoothogre", BigToothOgre_client)


function BigToothOgre_client.CreateInstance(self)
	self.OnNetReceive = BigToothOgre_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function BigToothOgre_client:OnNetReceive(client, msgs)
	
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	NPL.load("(gl)script/apps/Aries/app_main.lua");
	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30379_BigToothOgre.lua");
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			if(string.find(msg, "%[Aries%]") == 1) then
				local uid,gift_type,place_index,center_index = string.match(msg, "^%[Aries%]%[ServerObject30379%]CreateGiftInstance:(%d+):(%d+):(%d+):(%d+)$");
				if(uid and gift_type and place_index and center_index)then
					local BigToothOgre = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BigToothOgre");
					if(BigToothOgre) then
						BigToothOgre.CreateGiftInstance(uid,gift_type,place_index,center_index);
					end
				end
				local uid = string.match(msg, "^%[Aries%]%[ServerObject30379%]DestroyGiftInstance:(%d+)$");
				if(uid) then
					local BigToothOgre = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BigToothOgre");
					if(BigToothOgre) then
						BigToothOgre.DestroyGiftInstance(uid);
					end
				end
				local index = string.match(msg, "^%[Aries%]%[ServerObject30379%]RecvGift:(%d+)$");
				if(index) then
					local BigToothOgre = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BigToothOgre");
					if(BigToothOgre) then
						BigToothOgre.RecvGift(index);
					end
				end
				local index = string.match(msg, "^%[Aries%]%[ServerObject30379%]RebornIndex:(%d+)$");
				if(index) then
					local BigToothOgre = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BigToothOgre");
					if(BigToothOgre) then
						--Éú³É´óÑÀ¹Ö
						BigToothOgre.RebornIndex(index);
					end
				end
				local anger = string.match(msg, "^%[Aries%]%[ServerObject30379%]SetCurAnger:(%d+)$");
				if(anger) then
					local BigToothOgre = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BigToothOgre");
					if(BigToothOgre) then
						BigToothOgre.SetCurAnger(anger);
					end
				end
				local a,b = string.match(msg, "^%[Aries%]%[ServerObject30379%]TestIndex1:(%d+):(%d+)$");
				if(a and b) then
					local BigToothOgre = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BigToothOgre");
					if(BigToothOgre) then
						BigToothOgre.TestIndex(a,b);
					end
				end
			end
		end
	elseif(msgs == nil) then
		local lived_items = self:GetValue("BackupLivedItems");
		local BigToothOgre = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BigToothOgre");
		if(BigToothOgre)then
			BigToothOgre.BackupLivedItems(lived_items)
		end
		local index = self:GetValue("BackupBornIndex");
		local BigToothOgre = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BigToothOgre");
		if(BigToothOgre)then
			BigToothOgre.BackupBornIndex(index)
		end
		local anger = self:GetValue("BackupAnger");
		local BigToothOgre = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BigToothOgre");
		if(BigToothOgre)then
			BigToothOgre.BackupAnger(anger)
		end
	end
end
