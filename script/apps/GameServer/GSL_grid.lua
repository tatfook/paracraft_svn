--[[
Title:  GSL Grid (grid server)
Author(s): LiXizhi
Date: 2008/8/3, refactored to support GSL_homegrid 2009.10.8
Desc: GSL_grid and GSL_homegrid are two different managers of GSL_gridnode. They create GSL_gridnode on the user's demand. 
This is a public file which the client can activate directly. GSL_proxy is supported, which allows a client to communicate to GSL_homegrids via this file.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_grid.lua");
Map3DSystem.GSL_grid:Restart();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/apps/GameServer/GSL.lua");
NPL.load("(gl)script/apps/GameServer/GSL_msg_def.lua");
NPL.load("(gl)script/apps/GameServer/GSL_history.lua");
NPL.load("(gl)script/apps/GameServer/GSL_gridnode.lua");

NPL.load("(gl)script/apps/GameServer/GSL_gridnode_manager.lua");
local gridnode_manager = commonlib.gettable("Map3DSystem.GSL.gridnode_manager");
local GSL_grid = gridnode_manager:new(commonlib.gettable("Map3DSystem.GSL_grid"));

local function activate()
	GSL_grid:activate(msg);
end
NPL.this(activate);
