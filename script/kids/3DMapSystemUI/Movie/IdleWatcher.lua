--[[
Title: IdleWatcher
Author(s): Leio Zhang
Date: 2009/1/9
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/IdleWatcher.lua");
------------------------------------------------------------
]]
local IdleWatcher = {
	_isIdle = false,
	idleIntervalID = 1999,
	idleInterval = 2,
}
commonlib.setfield("Map3DSystem.Movie.IdleWatcher",IdleWatcher);
-- event
function IdleWatcher.idleInterrupted()

end
-- event
function IdleWatcher.idleTimeout()

end
function IdleWatcher.stop()
	NPL.KillTimer(IdleWatcher.idleIntervalID);
end
function IdleWatcher.start()
	IdleWatcher.stop();
	NPL.SetTimer(IdleWatcher.idleIntervalID, IdleWatcher.idleInterval, ";Map3DSystem.Movie.IdleWatcher.onIdleTimeout()");
	NPL.ChangeTimer(IdleWatcher.idleIntervalID,IdleWatcher.idleInterval * 1000,IdleWatcher.idleInterval * 1000)
end
function IdleWatcher.isIdle()
	return IdleWatcher._isIdle
end

function IdleWatcher.interuptIdle()
	local wasIdle = IdleWatcher._isIdle;
	IdleWatcher._isIdle = false;
	IdleWatcher.start();
	if (wasIdle)then
		-- dispatch event
		IdleWatcher.idleInterrupted(); -- show 
	end
end
function IdleWatcher.onIdleTimeout()
	IdleWatcher._isIdle = true;
	IdleWatcher.stop();
	-- dispatch event
	IdleWatcher.idleTimeout() -- hide
end
