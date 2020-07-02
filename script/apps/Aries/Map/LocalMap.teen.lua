--[[
Title: Local large map 
Author(s): LiXizhi
Date: 2011/8/19
Desc:  script/apps/Aries/Map/LocalMap.teen.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Map/LocalMap.teen.lua");
-------------------------------------------------------s
]]
NPL.load("(gl)script/apps/Aries/Help/MapHelp.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestPathfinderNavUI.lua");
local QuestPathfinderNavUI = commonlib.gettable("MyCompany.Aries.Quest.QuestPathfinderNavUI");
local MapHelp = commonlib.gettable("MyCompany.Aries.Help.MapHelp");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");
local LocalMap = commonlib.gettable("MyCompany.Aries.Desktop.LocalMap");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
local BasicArena = commonlib.gettable("MyCompany.Aries.Quest.NPCs.BasicArena");

-- loaded npc files mapping from world name to data source. 
local npc_maps = {};
local page;
function LocalMap.OnInit()
	page = document:GetPageCtrl();
end

-- return the world name of the current quest only if it is different from the current world
function LocalMap.GetCurrentQuestWorldName()
	local world_info = QuestPathfinderNavUI.GetCurrentQuestWorld();
	if(world_info) then
		if(WorldManager:GetCurrentWorld().name ~= world_info.name) then
			return world_info.name;
		end
	end
end

-- get proper arena position for teleport. 
function LocalMap.GetArenaTeleportPosByArenaID(arena_id)
	local arena_data_map = MsgHandler.Get_arena_data_map();
	if(arena_data_map and arena_id) then
		local arena = arena_data_map[arena_id];
		return MsgHandler.GetArenaTeleportPos(arena);
	end
end

function LocalMap.GetNPCDataSource()
	local cur_world = WorldManager:GetCurrentWorld();
    if(cur_world and cur_world.name) then
		local cur_map = npc_maps[cur_world.name];
		if(not cur_map) then
			local npc_list = NPCList.GetNPCList();
			if(npc_list) then
				cur_map = {name="world", attr={text = (cur_world.world_title or "当前世界")} };
				local npc_id, npc;
				for npc_id, npc in pairs(npc_list) do
					-- if the "can_teleport" attribute is false we will skip the npc
					if(npc.can_teleport ~= false and npc.name~="") then

						local name = npc.name;
						if(npc.name2) then
							name = format("%s %s", name, npc.name2);
						end
						cur_map[#cur_map+1] = {name="npc", attr={id=npc_id, 
								Name = name, 
								Desc = name, 
								index = npc.index or 0,
							}};
					end
				end
				-- sort by index or order
				table.sort(cur_map, function(a, b) return (a.attr.index)<(b.attr.index) end)
			end

			cur_map = cur_map or empty_npc_data_source;
			npc_maps[cur_world.name] = cur_map;
		end
		LocalMap.MergeArenaDataSource(cur_map)
		return cur_map;
	end
end

-- rebuild the arena data source if it has not been build before.
-- this usually happens when user opens map too early(before arena data is available.)
function LocalMap.MergeArenaDataSource(cur_map)
	if(not cur_map) then
		return;
	end
	local arenas = cur_map[#cur_map];
	if(arenas and arenas.name == "arena_parent" and #arenas>0) then
		if(LocalMap.last_arena_data_map == MsgHandler.Get_arena_data_map()) then
			return;
		else
			-- arena data expired, we will rebuild the arena map. 
			cur_map[#cur_map] = nil;
		end
	end

	if(true or System.options.isAB_SDK) then
		-- in case, it is an instanced world, we will also show all arena data. 
		local arena_data_map = MsgHandler.Get_arena_data_map();
		LocalMap.last_arena_data_map = arena_data_map;
		if(arena_data_map) then
			local arenas = {name="arena_parent", attr={id=0, 
					index = 0,
				}};
			local arena_id, arena;
			for arena_id, arena in pairs(arena_data_map) do
				if(arena.p_x) then
					local name;
					if(arena.mobs) then
						local _, mob;
						for _, mob in ipairs(arena.mobs) do
							local displayname = mob.displayname.." "..(mob.level or 0).."级";
							if(name == nil) then
								name = displayname;
							else
								name = name..","..displayname;
							end
						end
					end
					if(not name) then
						if(arena.mode == "free_pvp") then
							name = "自由PvP法阵";
						elseif(arena.mode == "pve") then
							name = "PvE法阵";
						else
							name = "竞技法阵";
						end
					end
							
					arenas[#arenas+1] = {name="arena", attr={id=arena_id, 
						Name = name, 
						Desc = name, 
						index = (arena_id or 0), -- make it appear after NPC
					}};
				end
			end
			if(#arenas>0) then
				arenas.attr.Name = format("法阵与怪物(%d)", #arenas);
				-- sort by index or order
				table.sort(arenas, function(a, b) return (a.attr.index)<(b.attr.index) end)
				cur_map[#cur_map+1] = arenas;
			end
		end
	end
end
-- Not used: 
function LocalMap.GetNPCDataSource_npc_map_file()
	local cur_world = WorldManager:GetCurrentWorld();
    if(cur_world and cur_world.npc_map_file) then
		if(npc_maps[cur_world.npc_map_file]) then
			return npc_maps[cur_world.npc_map_file];
		else
			local cur_map,temp_map = MapHelp.ParseXMLFile(cur_world.npc_map_file);
			if(cur_map)then
				local k,item;
				local clone_map = {name="world", attr={text = (cur_world.world_title or "当前世界")} };
				for k,item in ipairs(cur_map) do
					local noshow = item["NoShowInMap"];
					if(not noshow or noshow == "" or noshow == "false")then
						table.insert(clone_map,{name="npc", attr=item});
					end
				end
				cur_map = clone_map;
			else
				LOG.std(nil, "error", "LocalMap", "unable to parse NPC map file %s", cur_world.npc_map_file)
			end
			cur_map = cur_map or empty_npc_data_source;
			npc_maps[cur_world.npc_map_file] = cur_map;
			return cur_map;
		end
	else
		return empty_npc_data_source;
	end
end
-- let the path tracking to track the given npc
function LocalMap.TrackingNPC(npc)
	if(npc and npc.id) then
		local npc_id  = npc.id;
		local npc = NPCList.GetNPCByID(npc_id)
		if(npc and npc.position) then
			local worldname, position, camera = WorldManager:GetWorldPositionByNPC(npc_id);
			local params = {
				x = npc.position[1],
				y = npc.position[2],
				z = npc.position[3],
				jump_pos = position,
				camPos = camera,
				worldInfo = WorldManager:GetCurrentWorld(),
				radius = 4,
				targetName = npc.name,
			}
			QuestPathfinderNavUI.RefreshPage(true);
			QuestPathfinderNavUI.SetTargetQuest(params)
		end
	end
end

function LocalMap.ClosePage()
	local msg = { aries_type = "OnCloseLocalMap", wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
    page:CloseWindow();
end

function LocalMap.ShowNodeInMapArea()
	-- for cached points from external api. 
	if(LocalMap.points) then
		local points = LocalMap.points;
		LocalMap.points = nil;
		local name, point
		for name, point in pairs(points) do
			LocalMap.ShowPoint(name, point);
		end
	end
	if(LocalMap.last_clicknode)then
		local id = LocalMap.last_clicknode.id;
		local npc = NPCList.GetNPCByID(id);
		if(page and npc and npc.position) then
			local map_mark_name = "quest";
			
			local x = npc.position[1];
			local y = npc.position[3];
			local tooltip = string.format("%s(%d,%d)",npc.name or "",x,y);
			local params = {
				x = npc.position[1],
				y = npc.position[3],
				width = 16,
				height = 16,
				tooltip = tooltip,
				text = npc.name,
				background = "Texture/Aries/Common/ThemeTeen/others/quest_jump_32bits.png",
			}
			LocalMap.ShowPoint(map_mark_name,params);
		end
	end    
end

-- virtual public API
-- @param name: the point name string
-- @param point: {x,y,text,rotation, tooltip, school, width, height, background,zorder }. if nil, it will clear the given point. 
-- @param bRefreshImmediate: true to refresh immediately. 
function LocalMap.ShowPoint(name, point, bRefreshImmediate)
	if(page)then
		if(LocalMap.points) then
			LocalMap.points[name] = nil;
		end
		page:CallMethod("aries_teen_local_map", "ShowPoint", name, point, bRefreshImmediate);
	else
		LocalMap.points = LocalMap.points or {};
		LocalMap.points[name] = point;
	end
end
