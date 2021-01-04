--[[
Title: Macro Button Click Trigger
Author(s): LiXizhi
Date: 2021/1/4
Desc: a trigger for player movement to a scene position

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Macro.lua");
local Macro = commonlib.gettable("MyCompany.Aries.Game.Macro");
-------------------------------------------------------
]]
-------------------------------------
-- single Macro base
-------------------------------------
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")

local lastCamera = {camobjDist=8, LiftupAngle=0.4, CameraRotY=0}

--@param bx, by, bz: block world position
--@param facing: player facing
function Macros.PlayerMove(bx, by, bz, facing)
	-- TODO: use animation?
	local player = EntityManager.GetPlayer();
	if(player) then
		player:SetBlockPos(bx, by, bz)
		if(facing) then
			player:SetFacing(facing);
		end
	end
end


-- @param camobjDist, LiftupAngle, CameraRotY: if nil, we will restore the last CameraMove macro's values
function Macros.CameraMove(camobjDist, LiftupAngle, CameraRotY)
	if(not camobjDist) then
		camobjDist, LiftupAngle, CameraRotY = lastCamera.camobjDist, lastCamera.LiftupAngle, lastCamera.CameraRotY;
	else
		lastCamera.camobjDist, lastCamera.LiftupAngle, lastCamera.CameraRotY = camobjDist, LiftupAngle, CameraRotY
	end
	-- TODO: use animation?
	ParaCamera.SetEyePos(camobjDist, LifeupAngle, CameraRotY)
end



