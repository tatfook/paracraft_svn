--[[ NPC NoCombat AI
Author: Spring
Date: 2010/11/22

NPL.load("(gl)script/apps/Aries/NPCs/NPCNoCombat_AI.lua");

function NPCnoCombat_AI.BuildNpcWordsXml(thisworld)	
 --  use this function to load thisworld NPC's gossip table to memory by System.SystemInfo.SetField("NPCnocombat_AI_gossip", result_map);

function NPCnoCombat_AI.On_FrameMove(npcid)
 -- call this function with parameter: npcid 
]]
NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
--local libName = "NPCnoCombat_AI";
local NPCnoCombat_AI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.NPCnoCombat_AI");

-- NPCnoCombat AI framemove
function NPCnoCombat_AI.On_FrameMove(npcid)
	-- 0.3s interval

	local NPCnoCombat = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(npcid);
	local NPCgossip = {};
	local active_range,walk_range = 0,0;
	
	if(NPCnoCombat:IsValid() == true and player:IsValid() == true) then
		
		local dx, dy, dz = NPCnoCombat:GetPosition();
		local px, py, pz = player:GetPosition();
		
		local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
		local targetNPC_instance = MyCompany.Aries.Desktop.TargetArea.TargetNPC_instance;
		
		local dist = NPCnoCombat:DistanceTo(player);
		
		local gossipwords = System.SystemInfo.GetField("NPCnocombat_AI_gossip");
		if(gossipwords) then
			NPCgossip = gossipwords[npcid];			
		end
		if (NPCgossip.active_range) then
			active_range = NPCgossip.active_range;
			walk_range = NPCgossip.walk_range;
			if(memory.dist and memory.dist > active_range and dist <= active_range) then
			
				if(targetNPC_id == npcid and targetNPC_instance ~= instance) then
					-- skip the bark and facing if the dog is not the selected instance
				else
					-- say some gossip when enter 5 meter range
					if (NPCgossip.textwords) then
						headon_speech.Speek(NPCnoCombat.name, headon_speech.GetBoldTextMCML(NPCgossip.textwords), 3);
					end	
				
					if (NPCgossip.audiowords) then
						MyCompany.Aries.Scene.PlayGameSound(NPCgossip.audiowords);
					end
				
					-- walk to the player a little step, automatically face the player
					local NPCnoCombatChar = NPCnoCombat:ToCharacter();
					local s = NPCnoCombatChar:GetSeqController();
					NPCnoCombatChar:Stop();
					s:WalkTo((px - dx)/100, 0, (pz - dz)/100);
				end
			end
			memory.dist = dist;
		
			if(dist <= active_range) then
				-- skip random walk
				if(targetNPC_id == npcid and targetNPC_instance ~= instance) then
					-- continue the random walk if the dog is not the selected instance
				else
					return;
				end
			end
		
			local radius = walk_range*2;
		
			if(memory.born_x == nil) then
				memory.born_x = dx;
			end
			if(memory.born_z == nil) then
				memory.born_z = dz;
			end		
			if(memory.LastWalkTime == nil) then
				memory.LastWalkTime = 0;
			end
		
			local NPCnoCombatChar = NPCnoCombat:ToCharacter();
			local nTime = ParaGlobal.GetGameTime();
		
		-- changes direction every [3, 5] seconds.
			if((nTime - memory.LastWalkTime) > 1000 * math.random(3,5)) then
				-- select a new target randomly
				local s = NPCnoCombatChar:GetSeqController();
				x = (math.random()*2-1)*radius + memory.born_x - dx;
				z = (math.random()*2-1)*radius + memory.born_z - dz;
				NPCnoCombatChar:Stop();
				s:WalkTo(x, 0, z);
				-- save to memory
				memory.LastWalkTime = nTime;
			end
			
		end
	end
end

function NPCnoCombat_AI.BuildNpcWordsXml(thisworld)
	local self = NPCnoCombat_AI;

	-- local result = {};
	local result_map = {};

	-- if thisworld NPCgossip loaded to memory or not
	local gossipwords = System.SystemInfo.GetField("NPCnocombat_AI_gossip");
	if (gossipwords) then
		if (gossipwords[-1].label == thisworld) then
			return
		end
	end

	NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
	local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
	local _,_,worlds_list = QuestHelp.GetWorldList();
	if(not worlds_list)then return end


	local function get_item(node)
		if(not node)then return end
		local k,v;
		local item = {};
		local active_range;
		for k,v in ipairs(node) do
			local name = v.name;
			local value = v[1];
			--NOTE:active_range is number
			if(name == "active_range" or name == "walk_range" )then
				value = tonumber(value);
				active_range = value;
			end
			item[name] = value;
		end
		return item;
	end
	
	local first_item = {
		id = -1,
		label = thisworld,
	}
	-- table.insert(result,first_item);
	result_map[-1] = first_item;
	local k,world_node;
	-- commonlib.echo("-------------worldslist-------------");
	-- commonlib.echo(worlds_list);
	local world = worlds_list[thisworld];
	if(not world)then return end

	local input_path = world.npcfile or "";
	if (input_path == "") then  return end
	
	local node;
	local xmlRoot = ParaXML.LuaXML_ParseFile(input_path);		
	for node in commonlib.XPath.eachNode(xmlRoot, "/NPCList/NPC/") do
		if(node.attr)then
			local item = {};
			local name = node.attr.name;
			local npc_id = tonumber(node.attr.npc_id);
			for node_ex in commonlib.XPath.eachNode(node, "/gossip") do
				item = get_item(node_ex) or {};
				break;
			end
			if(item)then
				if (npc_id and item.textwords) then
					item.id = npc_id;
					item.label = name;
					-- table.insert(result,item);
					result_map[npc_id] = item;
				end
			end
		end
	end
	System.SystemInfo.SetField("NPCnocombat_AI_gossip", result_map);
end
