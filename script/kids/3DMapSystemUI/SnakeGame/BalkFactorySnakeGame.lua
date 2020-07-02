--[[
Author(s): Leio
Date: 2007/12/21
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/BalkFactorySnakeGame.lua");
------------------------------------------------------------
		
]]
if(not Map3DSystem.UI) then Map3DSystem.UI={}; end
local BalkFactorySnakeGame={
	ModleList={"character/v1/02animals/01land/niu/niu.x"},
	AnimationList={
				}
}
Map3DSystem.UI.BalkFactorySnakeGame=BalkFactorySnakeGame;

function BalkFactorySnakeGame.Made(PrePosition,Position,CurDir,CurBodyType,Name)
	local self=Map3DSystem.UI.BalkFactorySnakeGame;
	
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

function BalkFactorySnakeGame.GetStyle()
	local self=Map3DSystem.UI.BalkFactorySnakeGame;
	
	local i=table.getn(self.ModleList)
		  i=math.random(i);
		  return self.ModleList[i];
end
function BalkFactorySnakeGame.GetAnimation()
	local self=Map3DSystem.UI.BalkFactorySnakeGame;
	
	local i=table.getn(self.AnimationList)
		  if(i>0)then
			i=math.random(i);
			return self.AnimationList[i];
		  end
end
