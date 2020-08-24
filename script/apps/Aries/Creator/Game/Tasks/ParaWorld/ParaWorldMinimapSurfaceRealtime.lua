--[[
Title: ParaWorld Minimap Surface Realtime
Author(s): LiXizhi
Date: 2020/8/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldMinimapSurfaceRealtime.lua");
local ParaWorldMinimapSurfaceRealtime = commonlib.gettable("Paracraft.Controls.ParaWorldMinimapSurfaceRealtime");

-- it is important for the parent window to enable self paint and disable auto clear background. 
window:EnableSelfPaint(true);
window:SetAutoClearBackground(false);
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldMinimapSurface.lua");
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine");
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types");
local ParaWorldMinimapSurfaceRealtime = commonlib.inherit(commonlib.gettable("Paracraft.Controls.ParaWorldMinimapSurface"), commonlib.gettable("Paracraft.Controls.ParaWorldMinimapSurfaceRealtime"));
ParaWorldMinimapSurfaceRealtime:Property({"PlayerColor", "#00ff0080"});

-- mapping from block_id to block color like "#ff0000"
local color_table = nil;

function ParaWorldMinimapSurfaceRealtime:ctor()
end

function ParaWorldMinimapSurfaceRealtime:OnTimer()
	ParaWorldMinimapSurfaceRealtime._super.OnTimer(self);
end

function ParaWorldMinimapSurfaceRealtime:paintEvent(painter)
	if(self.playerX) then
		local x, y = self:WorldToMapPos(self.playerX, self.playerY)
		painter:SetPen(self.PlayerColor);
		painter:DrawRect(x, y, 2, 2);
	end
end