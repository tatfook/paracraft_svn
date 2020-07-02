--[[
Title:  GSL cells within a GSL_gridnode
Author(s): LiXizhi
Date: 2009/10/25
Desc: GSL_cells can be used with a GSL_gridnode instance to more effectively manage real time updates. 
It subdevides a gridnode region into evenly sized cells. When an agent's location changes, the agent's home cell is updated automatically. 
By using cells to manage mobile agents within a GSL_gridnode, we can send real time updates only to an agent's nearby entities. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_gridnode_cells.lua");
local CellManager = commonlib.gettable("Map3DSystem.GSL.CellManager");
CellManager:new({gridnode = gridNode, cellsize=40,})
-----------------------------------------------------------
]]
local GridNode = commonlib.gettable("Map3DSystem.GSL.GridNode");
local CellManager = commonlib.gettable("Map3DSystem.GSL.CellManager");

-- default neuron files for client and server. 
local DefaultClientFile = "script/apps/GameServer/GSL_client.lua"; 

------------------------------
-- cell class
------------------------------
-- a cell is a sub region inside a gridnode. It keeps references to all agents (entities) that are geographically inside the cell region. 
local cell = {
	-- tile index x in the cell manager
	cx,
	-- tile index y in the cell manager
	cy,
	-- pointer to the cell manager
	cell_manager = nil,
	-- a mapping from agent nid to agent object. 
	agents = nil,
	agent_count = 0,
	
	-- NPL, creatures, etc. 
	ServerObjects = nil,
	
	-- a pool of real time messages. Each time the server receives a real time message from an agent, it will append the message string to realtime_msg[agent.nid]. 
	-- during the next server real time update interval, the server just boardcasts all real time messages to all agents in the world. 
	realtime_msg = nil,
	-- number of combined nid messages in realtime_msg
	realtime_msgcount = 0,
}

function cell:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o.agents = o.agents or {};
	o.ServerObjects = o.ServerObjects or {};
	o.realtime_msg = o.realtime_msg or {};
	return o
end

-- remove a given agent in the cell. One must ensure that the agent exist in the cell prior to this call. 
function cell:RemoveAgent(agent)
	self.agents[agent.nid] = nil;
	self.agent_count = self.agent_count - 1;
	-- remove realtime messages related to this agent. 
	self.realtime_msg[agent.nid] = nil;
	agent.cell = nil;
	-- TODO: inform grid node about this
end

-- add a given agent to the cell
-- One must ensure that the agent does not exist in the cell prior to this call. 
function cell:AddAgent(agent)
	self.agents[agent.nid] = agent;
	self.agent_count = self.agent_count + 1;
	agent.cell = self;
	-- TODO: inform grid node about this
end

-- add a given server agent to the cell
-- One must ensure that the agent does not exist in the cell prior to this call. 
function cell:AddServerAgent(serveragent)
	self.ServerObjects[serveragent.id] = agent;
	serveragent.cell = self;
end

-- remove a given server agent in the cell. One must ensure that the agent exist in the cell prior to this call. 
function cell:RemoveServerAgent(serveragent)
	self.ServerObjects[serveragent.id] = nil;
	serveragent.cell = nil;
end

-- whether the cell is empty
function cell:IsEmpty()
	return (self.agent_count == 0);
end

local neighbour_coordi_x = {-1,0,1,-1,0,1,-1,0,1,};
local neighbour_coordi_y = {-1,-1,-1,0,0,0,1,1,1,};
-- get the neighbouring cell by index
-- @param index: in range [1,9]. index is like the numeric keyboard. where 5 is the current cell, 7 upper left, 3 if bottom right. 
function cell:GetNeighbour(index)
	local cx,cy = cell.cx + neighbour_coordi_x[index], cell.cy + neighbour_coordi_y[index];
	return cell.cell_manager:FindCell(cx,cy);
end

-- an agent just visited this cell. 
-- it will need to send cell updates to the agent
-- @param agent: the agent that is visiting the cell
-- @param is_first_time: if true, it will be the first time that the agent visit the cell, in that case it will try to send everything in the cell. 
function cell:VisitBy(agent, is_first_time)
	-- TODO: 
end

-- add an agent message to the pool of real time messages. Each time the server receives a real time message from an agent, it will append the message string to realtime_msg[agent.nid]. 
-- during the next server real time update interval, the server just boardcasts all real time messages to all agents in the world. 
-- @param fromNID: the string nid of the agent sending the message. 
-- @param msgData: the opcode encoded message string.
function cell:AddRealtimeMessage(fromNID, msgData)
	local data = self.realtime_msg[fromNID]
	if(data) then
		-- append the message: shall we remove redundent ones?
		self.realtime_msg[fromNID] = data..","..msgData;
	else
		-- add the message
		self.realtime_msg[fromNID] = msgData;
		self.realtime_msgcount =  self.realtime_msgcount + 1;
	end	
end

------------------------------
-- cell manager class
------------------------------

-- a CellManager instance is associated with a GSL_gridnode instance for managing all cells inside the grid node. 
commonlib.partialcopy(CellManager, {
	-- the grid node that owns this cell manager 
	gridnode = nil,
	-- grid tile pos, it marks the simulation region within the self.worldpath. 
	-- from (x*size, y*size) to (x*size+size, y*size+size)
	cellsize = 64,
	-- half of max cell count in a row 
	max_cells = 64,
	-- mapping from cell index to the cell object. The cell object contains all agents(entities) inside a given cell region. 
	cells = nil,
	-- the default cell object. if no cell is found, the self:GetCell() method returns the default cell object
	default_cell = nil,
});

function CellManager:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o:Reset();
	return o
end

-- regenerate session and become a new server. This is usually called by Map3DSystem.GSL.Reset()
-- call this to reset the server to inital disconnected state where there is a new session key, no history, no timer, no agents. 
function CellManager:Reset()
	-- preallocate cell object 
	self.cells = {};
	-- create the default cell
	self.default_cell = cell:new({cell_manager = self});
end

-- get the cell object. if no cell is found, the function returns the default cell object
-- @param cx,cy: the cell matrix position. They are usually in the range [1,self.cellsize]. 
function CellManager:GetCell(cx,cy)
	return self.cells[cy * self.max_cells + cx] or self.default_cell;
end

-- create get the cell at the given cell coordinates
-- @return the cell or nil if out of range. 
function CellManager:CreateGetCell(cx,cy)
	local index = cy * self.max_cells + cx;
	local cell = self.cells[index]
	if(cell) then
		return cell;
	else
		cell = cell:new({cx = cx, cy = cy, cell_manager = self});
		self.cells[index] = cell;
	end
	return cell;
end

-- return the cell coordinate pairs 
-- @param x,y: global position. 
-- @return cx,cy the cell coordinate pairs
function CellManager:GetCellCoordByPoint(x, y)
	x = math.floor((x - self.gridnode.x) / self.cellsize);
	y = math.floor((y - self.gridnode.y) / self.cellsize);
	if(math.abs(x)<self.max_cells and math.abs(y)<self.max_cells) then
		return x,y;
	end
end

-- same as GetCell(), except that it will return nil, if no cell is found. 
function CellManager:FindCell(cx,cy)
	return self.cells[cy * self.max_cells + cx];
end

-- relocate a server object. 
function CellManager:RelocateServerObject(serveragent)
	if(not serveragent.x) then
		serveragent.cell = nil;
		return;
	end
	local cx, cy = self:GetCellCoordByPoint(serveragent.x, serveragent.y);
	if(cx) then
		local old_cell = serveragent.cell;
		if(old_cell) then
			if( (old_cell.cx ~= cx) or (old_cell.cy ~= cy) ) then
				old_cell:RemoveServerAgent(serveragent);
				local new_cell = self:CreateGetCell(cx,cy);
				new_cell:AddServerAgent(serveragent);
				return true;
			end
		else
			local new_cell = self:CreateGetCell(cx,cy);
			new_cell:AddServerAgent(serveragent);
			return true;
		end
	end	
end

-- relocate the agent to its current location
-- @param agent: the GSL_agent object. 
-- @param cx, cy: the new tile position to put the agent to. please note that 
-- @return true if cell is either changed or added for the first time. it return false if cell is not changed. 
function CellManager:RelocateAgent(agent)
	if(not agent.x) then 
		agent.cell = nil;
		return;
	end

	local cx, cy = self:GetCellCoordByPoint(agent.x, agent.y);
	if(cx) then
		local old_cell = agent.cell;
		if(old_cell) then
			if( (old_cell.cx ~= cx) or (old_cell.cy ~= cy) ) then
				old_cell:RemoveAgent(agent);
				local new_cell = self:CreateGetCell(cx,cy);
				new_cell:AddAgent(agent);
				return true;
			end
		else
			local new_cell = self:CreateGetCell(cx,cy);
			new_cell:AddAgent(agent);
			return true;
		end
	end	
end


-- send all pending real time messages to all agents in all cells. 
function CellManager:BroadcastRealtimeMessage(neuronfile)
	local cells_data = {};
	local out_msg = {
		type = GSL_msg.SC_RealtimeUpdate, 
		cells = cells_data,
		-- inject grid node id, to packet now. 
		id = self.id,
	};
	local index, center_cell, cell, i;
	for index, center_cell in pairs(self.cells) do
		-- for each agent in the cell, visit all neighbouring cells including its own. 
		local nid, agent;
		for nid, agent in pairs(center_cell.agents) do
			-- visit 9 cells(including its own)
			for i = 1,9 do
				cell = center_cell:GetNeighbour(i);
				if (cell) then
					cell:VisitBy(agent, false);
				end
			end
		end	
	end
end