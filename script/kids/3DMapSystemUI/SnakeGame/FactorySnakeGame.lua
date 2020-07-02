--[[
Author(s): Leio
Date: 2007/12/21
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/FactorySnakeGame.lua");
------------------------------------------------------------
		
]]
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/HeadFactorySnakeGame.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/BalkFactorySnakeGame.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/DotFactorySnakeGame.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/GiftFactorySnakeGame.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/BodyFactorySnakeGame.lua");
if(not Map3DSystem.UI) then Map3DSystem.UI={}; end
local FactorySnakeGame={

}
Map3DSystem.UI.FactorySnakeGame=FactorySnakeGame;
function FactorySnakeGame.MadeHead(PrePosition,Position,CurDir,CurBodyType,Name)
		 return Map3DSystem.UI.HeadFactorySnakeGame.Made(PrePosition,Position,CurDir,CurBodyType,Name);
end
function FactorySnakeGame.MadeBalk(PrePosition,Position,CurDir,CurBodyType,Name)
		 return Map3DSystem.UI.BalkFactorySnakeGame.Made(PrePosition,Position,CurDir,CurBodyType,Name);
end
function FactorySnakeGame.MadeDot(PrePosition,Position,CurDir,CurBodyType,Name)
		 return Map3DSystem.UI.DotFactorySnakeGame.Made(PrePosition,Position,CurDir,CurBodyType,Name);
end
function FactorySnakeGame.MadeGift(PrePosition,Position,CurDir,CurBodyType,Name)
		 return Map3DSystem.UI.GiftFactorySnakeGame.Made(PrePosition,Position,CurDir,CurBodyType,Name);
end
function FactorySnakeGame.MadeBody(PrePosition,Position,CurDir,CurBodyType,Name)
		 return Map3DSystem.UI.BodyFactorySnakeGame.Made(PrePosition,Position,CurDir,CurBodyType,Name);
end