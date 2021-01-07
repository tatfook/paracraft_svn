--[[
Title: Macro Idle
Author(s): LiXizhi
Date: 2021/1/4
Desc: the user is idling. 

Use Lib:
-------------------------------------------------------
GameLogic.Macros.Idle(1000)
-------------------------------------------------------
]]
-------------------------------------
-- single Macro base
-------------------------------------
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")

-- @param timeMs: milliseconds
-- @return nil or {OnFinish=function() end}
function Macros.Idle(timeMs)
	if(timeMs and timeMs > 0) then
		local callback = {};
		local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
			if(callback.OnFinish) then
				callback.OnFinish();
			end
		end})
		mytimer:Change(timeMs);
		return callback;
	end
end





