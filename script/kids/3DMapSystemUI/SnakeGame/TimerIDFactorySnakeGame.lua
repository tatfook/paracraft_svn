--[[
Author(s): Leio
Date: 2007/12/26
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/TimerIDFactorySnakeGame.lua");
------------------------------------------------------------
		
]]

if(not Map3DSystem.UI.TimerIDFactorySnakeGame) then Map3DSystem.UI.TimerIDFactorySnakeGame={}; end
Map3DSystem.UI.TimerIDFactorySnakeGame.ID=50;
function Map3DSystem.UI.TimerIDFactorySnakeGame.Made()
	Map3DSystem.UI.TimerIDFactorySnakeGame.ID=Map3DSystem.UI.TimerIDFactorySnakeGame.ID+1;
	return Map3DSystem.UI.TimerIDFactorySnakeGame.ID;
end
function Map3DSystem.UI.TimerIDFactorySnakeGame.Clear()
	Map3DSystem.UI.TimerIDFactorySnakeGame.ID=50;
end