--[[
Author(s): Leio
Date: 2007/12/21
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/GiftFactorySnakeGame.lua");
------------------------------------------------------------
		
]]
if(not Map3DSystem.UI) then Map3DSystem.UI={}; end
local GiftFactorySnakeGame={
	ModleList={"character/v1/06other/baoxiang/baoxiang.x"},
	AnimationList={	
					{type="type_animation",path="character/Animation/Angel/倒地.x",score="0",speed="0"},
					{type="type_animation",path="character/Animation/Angel/弯腰痛苦.x",score="0",speed="0"},	
					{type="type_score",path="none",score="500",speed="none"},
					{type="type_score",path="none",score="200",speed="none"},
					{type="type_score",path="none",score="100",speed="none"},
					{type="type_score",path="none",score="-100",speed="none"},
					{type="type_score",path="none",score="-200",speed="none"},
					{type="type_score",path="none",score="-500",speed="none"},
					{type="type_speed",path="none",score="0",speed="0.5"},
					{type="type_speed",path="none",score="0",speed="1.5"}
					
				}
}
Map3DSystem.UI.GiftFactorySnakeGame=GiftFactorySnakeGame;

function GiftFactorySnakeGame.Made(PrePosition,Position,CurDir,CurBodyType,Name)
	local self=Map3DSystem.UI.GiftFactorySnakeGame;
	
	local bodyPart=Map3DSystem.UI.SnakeGameBodyPart:new();
	local modelPath=self.GetStyle();
		  bodyPart:SetModelPath(modelPath);
	local animation=self.GetAnimation();
		  bodyPart:SetAnimation(animation);
		
		  bodyPart:SetPrePosition(PrePosition.x,PrePosition.y);
		  bodyPart:SetPosition(Position.x,Position.y);
		  bodyPart:SetDirection(CurDir);
		  bodyPart:SetBodyType(CurBodyType);
		  bodyPart:SetName(Name);
	 
	return bodyPart;
end

function GiftFactorySnakeGame.GetStyle()
	local self=Map3DSystem.UI.GiftFactorySnakeGame;
	
	local i=table.getn(self.ModleList)
		  i=math.random(i);
		  return self.ModleList[i];
end
function GiftFactorySnakeGame.GetAnimation()
	local self=Map3DSystem.UI.GiftFactorySnakeGame;
	
	local i=table.getn(self.AnimationList)
		 if(i>0)then
			i=math.random(i);
			return self.AnimationList[i];
		  end
end
