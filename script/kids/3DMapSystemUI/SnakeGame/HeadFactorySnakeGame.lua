--[[
Author(s): Leio
Date: 2007/12/21
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/HeadFactorySnakeGame.lua");
------------------------------------------------------------
		
]]
if(not Map3DSystem.UI) then Map3DSystem.UI={}; end
local HeadFactorySnakeGame={
	ModleList={"character/v3/Human/Male/humanmale.x"},
	AnimationList={
				}
}
Map3DSystem.UI.HeadFactorySnakeGame=HeadFactorySnakeGame;

function HeadFactorySnakeGame.Made(PrePosition,Position,CurDir,CurBodyType,Name)
	local self=Map3DSystem.UI.HeadFactorySnakeGame;
	
	local bodyPart=Map3DSystem.UI.SnakeGameBodyPart:new();
	local modelPath=self.GetStyle();
		  bodyPart:SetModelPath(modelPath);
	local animation=self.GetAnimation();
		  bodyPart:SetAnimation();
			
		  bodyPart:SetPrePosition(PrePosition.x,PrePosition.y);
		  bodyPart:SetPosition(Position.x,Position.y);
		  bodyPart:SetDirection(CurDir);
		  bodyPart:SetBodyType(CurBodyType);
		  bodyPart:SetName(Name);
	 
	return bodyPart;
end

function HeadFactorySnakeGame.GetStyle()
	local self=Map3DSystem.UI.HeadFactorySnakeGame;
	
	local i=table.getn(self.ModleList)
		  i=math.random(i);
		  return self.ModleList[i];
end
function HeadFactorySnakeGame.GetAnimation()
	local self=Map3DSystem.UI.HeadFactorySnakeGame;
	
	local i=table.getn(self.AnimationList)
		  if(i>0)then
			i=math.random(i);
			return self.AnimationList[i];
		  end
end
