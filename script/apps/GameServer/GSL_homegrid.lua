--[[
Title:  GSL Home Grid (grid server)
Author(s): LiXizhi
Date: 2008/8/3
Desc: GSL_grid and GSL_homegrid are two different managers of GSL_gridnode. They create GSL_gridnode on the user's demand. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_homegrid.lua");
Map3DSystem.GSL_homegrid:Restart();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/apps/GameServer/GSL.lua");
NPL.load("(gl)script/apps/GameServer/GSL_msg_def.lua");
NPL.load("(gl)script/apps/GameServer/GSL_history.lua");
NPL.load("(gl)script/apps/GameServer/GSL_gridnode.lua");
NPL.load("(gl)script/apps/GameServer/GSL_gridnode_manager.lua");

local gridnode_manager = commonlib.gettable("Map3DSystem.GSL.gridnode_manager");
local GSL_homegrid = gridnode_manager:new(commonlib.gettable("Map3DSystem.GSL_homegrid"));
-- home grid real time frame move interval is slightly longer?  
GSL_homegrid.TimerInterval = 300;

local function activate()
	GSL_homegrid:activate(msg, true);
end
NPL.this(activate);
