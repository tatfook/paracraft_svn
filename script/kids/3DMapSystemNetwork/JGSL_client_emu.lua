--[[
Title: OBSOLETED: use JGSL.client:new({IsEmulated=true}) instead. Client emulation
Author(s): LiXizhi
Date: 2008/12/23
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_msg_def.lua");

if(not Map3DSystem.JGSL_client_emu) then Map3DSystem.JGSL_client_emu = {};end;

-- it just displays whatever messages it receive. 
local function activate()
end
NPL.this(activate);
