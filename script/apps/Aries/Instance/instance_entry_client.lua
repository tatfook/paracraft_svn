--[[
Title: 
Author(s):  WangTian
Date: 2010/11/2
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Instance/instance_entry_client.lua");
------------------------------------------------------------
]]
			
-----------------------------------
 -- a special client NPC on behalf of a server agent, it just shows what is received.
-----------------------------------
local Instance_Entry_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("aries_instance_entry", Instance_Entry_client);

NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");


function Instance_Entry_client.CreateInstance(self)
	self.OnNetReceive = Instance_Entry_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
	
	-- TODO: add your proviate per instance data here
	self.private_data = {some_per_instance_data_here};
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function Instance_Entry_client:OnNetReceive(client, msgs)
	
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	--NPL.load("(gl)script/apps/Aries/app_main.lua");
	--NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	--NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	--NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30301_BubbleMachine.lua");
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			local instance_key, world_name, instance = string.match(msg, "^%[Aries%]%[ServerObject_Instance_Entry%]ValidEntry:(.-)%+(.-)%+(%d+)$");
			if(instance_key and world_name and instance) then
				local Instance = commonlib.gettable("MyCompany.Aries.Instance");
				Instance.EnterTreasureHouse_from_serverobject(instance_key, world_name, instance);
			end
			local bFail = string.find(msg, "^%[Aries%]%[ServerObject_Instance_Entry%]FailEntry$");
			if(bFail) then
				_guihelper.MessageBox([[<div style="margin-top:24px;margin-left:6px;width:300px;">你下手慢啦，这个宝箱已经被其他队伍抢走了，快去其他地方找找吧！</div>]]);
			end
			local world_name, entry_id = string.match(msg, "^%[Aries%]%[ServerObject_Instance_Entry%]DestroyEntry:(.-)%+(%d+)$");
			if(world_name and entry_id) then
				entry_id = tonumber(entry_id);
				local current_worldinfo = WorldManager:GetCurrentWorld();
				local current_worldname = current_worldinfo.name;
				if(current_worldname == world_name) then
					Instance_Entry_client.DestroyInstanceEntry(entry_id);
				end
			end
		end
	elseif(msgs == nil) then
		local worldinfo = WorldManager:GetCurrentWorld();
		if(worldinfo and worldinfo.name) then
			local worldname = worldinfo.name;
			local entries = self:GetValue(worldname.."_entries");
		
			if(entries) then
				local index = 1;
				local exist;
				for exist in string.gfind(entries, "([^,]+)") do
					if(exist == "1") then
						Instance_Entry_client.CreateInstanceEntry(index);
					elseif(exist == "0") then
						Instance_Entry_client.DestroyInstanceEntry(index);
					end
					index = index + 1;
				end
			end
		else
			LOG.std(nil, "warn", "instance_entry_client", "invalid worldinfo or name found.")
		end
	end
	
	-- self:AddRealTimeMessage(self.id, msg);
	
	-- one can send real time message to self.id on the server side. 
	-- self:GetValue();
end

local entry_coords = {
	--["61HaqiTown"] = {
		--{20040.251953125, 0.80515426397324, 19737.3828125},
		--{20040.251953125, 0.80515426397324, 19736.3828125},
		--{20040.251953125, 0.80515426397324, 19735.3828125},
		--{20040.251953125, 0.80515426397324, 19734.3828125},
		--{20040.251953125, 0.80515426397324, 19733.3828125},
		--{20040.251953125, 0.80515426397324, 19732.3828125},
		--{20040.251953125, 0.80515426397324, 19731.3828125},
		--{20040.251953125, 0.80515426397324, 19730.3828125},
		--{20040.251953125, 0.80515426397324, 19729.3828125},
		--{20040.251953125, 0.80515426397324, 19728.3828125},
		--{20040.251953125, 0.80515426397324, 19727.3828125},
		--{20040.251953125, 0.80515426397324, 19726.3828125},
		--{20040.251953125, 0.80515426397324, 19725.3828125},
		--{20040.251953125, 0.80515426397324, 19724.3828125},
		--{20040.251953125, 0.80515426397324, 19723.3828125},
		--{20040.251953125, 0.80515426397324, 19722.3828125},
		--{20040.251953125, 0.80515426397324, 19721.3828125},
		--{20040.251953125, 0.80515426397324, 19720.3828125},
		--{20040.251953125, 0.80515426397324, 19719.3828125},
		--{20040.251953125, 0.80515426397324, 19710.3828125},
	--},
	["61HaqiTown"] = {
		{19983.16,3.35,19857.04},
		{19941.19,3.30,19886.11},
		{19984.25,3.11,19922.79},
		{19678.41,9.78,20108.26},
		{19895.69,11.64,20076.26},
		{20021.80,1.31,20026.03},
		{19839.88,3.89,19899.57},
		{19695.32,2.58,19878.08},
		{20185.54,-0.33,19593.15},
		{20116.35,1.14,19610.33},
		{19902.51,2.79,19566.51},
		{19964.10,3.75,20007.27},
		{19649.75,10.13,19980.43},
		{19766.36,1.19,19774.32},
		{19822.65,29.82,20203.99},
		{20310.56,-1.01,19843.24},
		{20289.88,2.80,19800.69},
		{20387.23,3.36,19862.27},
		{20388.07,3.36,19911.52},
		{19891.19,0.25,19781.41},
	},
	--["FlamingPhoenixIsland"] = {
		--{19813.1328125, 4.8508434295654, 19624.529296875},
		--{19809.484375, 4.8333086967468, 19627.150390625},
		--{19805.98828125, 4.9324617385864, 19629.662109375},
		--{19801.578125, 4.6384496688843, 19632.830078125},
		--{19797.16796875, 4.029016494751, 19635.998046875},
		--{19792.6015625, 3.4025161266327, 19639.279296875},
		--{19788.6484375, 3.572901725769, 19642.119140625},
		--{19785, 3.9612851142883, 19644.740234375},
		--{19781.50390625, 4.2047729492188, 19647.251953125},
		--{19777.8515625, 4.3108701705933, 19649.876953125},
		--{19774.203125, 4.1993827819824, 19652.498046875},
		--{19770.85546875, 4.0729970932007, 19654.904296875},
		--{19766.75, 3.9170598983765, 19657.853515625},
	--},
	["FlamingPhoenixIsland"] = {
		{20188.81,75.28,20151.46},
		{20175.54,75.13,20212.35},
		{19980.07,19.42,19690.32},
		{20057.53,22.09,19651.29},
		{19837.72,69.89,19969.76},
		{19899.39,75.72,19975.56},
		{19713.32,43.02,19864.20},
		{19700.14,34.22,19924.44},
		{19686.63,6.74,19739.36},
		{19842.29,6.22,19632.37},
		{20131.28,66.70,20065.88},
		{19935.00,28.79,19750.13},
	},
	["FrostRoarIsland"] = {
		{19572.54,6.16,20173.63},
		{19729.63,7.47,20092.81},
		{19654.56,7.68,20039.68},
		{19498.70,23.22,19978.08},
		{19361.35,35.91,19721.80},
		{19887.08,7.14,19803.54},
		{19919.97,6.56,19700.51},
		{19701.45,6.36,20367.88},
		{19672.05,6.66,20296.14},
	},
	["AncientEgyptIsland"] = {
		{20206.29,76.45,20108.83},
		{19638.42,20.56,20040.00},
		{19620.69,17.19,19915.40},
		{19944.90,9.45,19908.95},
		{20070.45,50.21,19881.50},
		{19552.59,36.67,19860.34},
		{19445.74,13.00,19859.79},
		{19714.22,7.99,20291.92},
	},
};

function Instance_Entry_client.CreateInstanceEntry(index)
	local worldinfo = WorldManager:GetCurrentWorld();
	local worldname = worldinfo.name;
	local coords = entry_coords[worldname];
	if(coords) then
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.DeleteNPCCharacter(301792, index);
		local params = {
			name = "",
			position = coords[index],
			assetfile_char = "character/common/dummy/cube_size/cube_size.x",
			assetfile_model = "model/06props/v5/03quest/TreasureBox/TreasureBox_01.x",
			facing = 0.91666221618652,
			scale_char = 3,
			scaling_model = 1,
			talk_dist = 6,
			main_script = "script/apps/Aries/Instance/main.lua",
			main_function = "MyCompany.Aries.Instance.InstanceEntrance_Main();",
			predialog_function = "MyCompany.Aries.Instance.EnterInstance_PreDialog",
			dialog_page = "script/apps/Aries/NPCs/Instance/31003_TreasureHouseEntrance_dialog.html",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			instance = index,
		};
		local entry = NPC.CreateNPCCharacter(301792, params);
	end
end

function Instance_Entry_client.DestroyInstanceEntry(index)
	local worldinfo = WorldManager:GetCurrentWorld();
	local worldname = worldinfo.name;
	local coords = entry_coords[worldname];
	if(coords) then
		local NPC = MyCompany.Aries.Quest.NPC;
		NPC.DeleteNPCCharacter(301792, index, true);
	end
end


--function Instance_Entry_client.TryPickObject(instance_id)
	--client:AddRealtimeMessage("[Aries][ServerObject30301]TryPickObj:"..instance_id);
--end