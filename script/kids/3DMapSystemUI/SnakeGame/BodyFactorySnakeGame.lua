--[[
Author(s): Leio
Date: 2007/12/21
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/BodyFactorySnakeGame.lua");
------------------------------------------------------------
		
]]
if(not Map3DSystem.UI) then Map3DSystem.UI={}; end
local BodyFactorySnakeGame={
	ModleList={},
	AnimationList={
				}
}
Map3DSystem.UI.BodyFactorySnakeGame=BodyFactorySnakeGame;

function BodyFactorySnakeGame.Made(PrePosition,Position,CurDir,CurBodyType,Name)
	local self=Map3DSystem.UI.BodyFactorySnakeGame;
	
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

function BodyFactorySnakeGame.GetStyle()
	local self=Map3DSystem.UI.BodyFactorySnakeGame;
	
	local i=table.getn(self.ModleList)
		  i=math.random(i);
		  return self.ModleList[i];
end
function BodyFactorySnakeGame.GetAnimation()
	local self=Map3DSystem.UI.BodyFactorySnakeGame;
	
	local i=table.getn(self.AnimationList)
		  if(i>0)then
			i=math.random(i);
			return self.AnimationList[i];
		  end
		  
	
end
