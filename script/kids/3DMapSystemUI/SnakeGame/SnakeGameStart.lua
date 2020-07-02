--[[
Author(s): Leio
Date: 2007/12/21
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/SnakeGameStart.lua");
------------------------------------------------------------
		
]]
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/TimerIDFactorySnakeGame.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/ContainerControlSnakeGame.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/ControlListSnakeGame.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/SnakeGameBodyPart.lua");
if(not Map3DSystem.UI.SnakeGameStart) then Map3DSystem.UI.SnakeGameStart={}; end
Map3DSystem.UI.SnakeGameStart.TileSize=8;
Map3DSystem.UI.SnakeGameStart.MadeGiftTimerID=nil;
Map3DSystem.UI.SnakeGameStart.ControlList=nil;
Map3DSystem.UI.SnakeGameStart.GameLevel=nil;
Map3DSystem.UI.SnakeGameStart.TotalEatNum=nil;
Map3DSystem.UI.SnakeGameStart.Score=nil;
Map3DSystem.UI.SnakeGameStart.SnameGameScene=nil;

Map3DSystem.UI.SnakeGameStart.MadeDotNumber=1;
Map3DSystem.UI.SnakeGameStart.MadeGiftNumber=1;
Map3DSystem.UI.SnakeGameStart.MadeGiftInterval=10;
Map3DSystem.UI.SnakeGameStart.GiftAliveTime=5;

Map3DSystem.UI.SnakeGameStart.StartEatNum=4;
Map3DSystem.UI.SnakeGameStart.StartScore=0;
Map3DSystem.UI.SnakeGameStart.StartLevel=1;

function Map3DSystem.UI.SnakeGameStart.Init(SnameGameScene,GameLevel,TotalEatNum,Score)
	Map3DSystem.UI.SnakeGameStart.SnameGameScene=SnameGameScene;
	Map3DSystem.UI.SnakeGameStart.GameLevel=GameLevel;
	Map3DSystem.UI.SnakeGameStart.TotalEatNum=TotalEatNum;
	Map3DSystem.UI.SnakeGameStart.Score=Score;
	Map3DSystem.UI.SnakeGameStart.Made();
	Map3DSystem.UI.SnakeGameStart.MadeBG()
end
function Map3DSystem.UI.SnakeGameStart.MadeBG()
	local self=Map3DSystem.UI.SnakeGameStart;
	local SnameGameScene=self.SnameGameScene;
	local model=SnameGameScene.AssetModel;
	
	local assetTex2 = ParaAsset.LoadTexture("","Texture/3DMapSystem/SnakeGame/BG2.png",1);
	local c,r=table.getn(self.ControlList.TileList[1]),table.getn(self.ControlList.TileList);
	
	for i=1,r do
		local temp={};
		for j=1,c do
				temp[j] = ParaScene.CreateMeshPhysicsObject("tile"..r..c,model,1,1,1,false,"1,0,0,0,1,0,0,0,1,0,0,0");
			if( temp[j]:IsValid())then
				local x,y,z=(j-1)-c/2,0,(1-i)+r/2;
				temp[j]:SetPosition(x,y,z);
				temp[j]:SetReplaceableTexture(1,assetTex2);
				
				SnameGameScene.Scene:AddChild(temp[j]);
			end
		end	
		--self.MeshTileList[i]=	temp;
	end
end
function Map3DSystem.UI.SnakeGameStart.Made()
	
	local self=Map3DSystem.UI.SnakeGameStart;
	local _SceneGraph=self.SnameGameScene.Scene;
	local _ControlList=Map3DSystem.UI.ControlListSnakeGame:new();
		  self.ControlList=_ControlList;
		  _ControlList.MadeDotNumber=self.MadeDotNumber;
		  _ControlList.MadeGiftNumber=self.MadeGiftNumber;
		  local TileList={};
		  for i=1,self.TileSize do
			  local temp={};
			  for j=1,self.TileSize do
					temp[j]=1;
			  end
			  TileList[i]=temp;
		  end
		  _ControlList.TileList=TileList;
	local ContainerControlSnakeGame=Map3DSystem.UI.ContainerControlSnakeGame;
	 ContainerControlSnakeGame.Init(_SceneGraph,_ControlList,self.TileSize,self.GameLevel,self.TotalEatNum,self.Score)
		  ------add head
			self.MadeHead();
		  ------add body
		  ------add balk
			self.MadeBalk(_ControlList.TileType.Balk);
		  ------add dot
			self.MadeDot();
		  ------add gift
			self.MadeGift();
		  
		  ContainerControlSnakeGame.Update();
end
function Map3DSystem.UI.SnakeGameStart.MadeHead()
	 
		  local _Position={x=3,y=2};
		  local _CurDir="East";
		  Map3DSystem.UI.ContainerControlSnakeGame.SetHead(_Position,_CurDir)
end
function Map3DSystem.UI.SnakeGameStart.MadeBody()
	--ContainerControlSnakeGame.SetBodyList(list)
end
function Map3DSystem.UI.SnakeGameStart.MadeBalk(type)	
	 local self=Map3DSystem.UI.SnakeGameStart;		
			local list=self.StaticBalkList()
			local r=math.random(table.getn(list));
				  list=self.Balk(list[r])
		   Map3DSystem.UI.ContainerControlSnakeGame.SetBalkList(list)
end
function Map3DSystem.UI.SnakeGameStart.MadeDot()
	 Map3DSystem.UI.ContainerControlSnakeGame.SetDotList(Map3DSystem.UI.SnakeGameStart.MadeDotNumber)
end
function Map3DSystem.UI.SnakeGameStart.MadeGift()
	 local self=Map3DSystem.UI.SnakeGameStart;
		   self.MadeGiftTimerID=Map3DSystem.UI.TimerIDFactorySnakeGame.Made();
		   NPL.SetTimer(self.MadeGiftTimerID,self.MadeGiftInterval,string.format(";Map3DSystem.UI.ContainerControlSnakeGame.SetGiftList(%d)",Map3DSystem.UI.SnakeGameStart.MadeGiftNumber));	 
end
function Map3DSystem.UI.SnakeGameStart.Clear()
	 local self=Map3DSystem.UI.SnakeGameStart;
		   NPL.KillTimer(self.MadeGiftTimerID); 
end
function Map3DSystem.UI.SnakeGameStart.ClearTimeIDList()
		Map3DSystem.UI.SnakeGameStart.Clear();
		Map3DSystem.UI.ContainerControlSnakeGame.ClearTimeIDList();
end
function Map3DSystem.UI.SnakeGameStart.StaticBalkList()
	local list={
				{{x=3,y=3}},
				{{x=3,y=3},{x=3,y=4}},
				{{x=3,y=3},{x=5,y=3}},
				{{x=3,y=3},{x=6,y=4}}
				
	}
	return list;
end
function Map3DSystem.UI.SnakeGameStart.Balk(list)
	local balklist={};
	for i=1,table.getn(list) do
			local PrePosition={x=0,y=0};
			local Position=list[i];
			local CurDir="";
			local CurBodyType=4;--TileType.Balk
			local Name="balk";
			local balk=Map3DSystem.UI.FactorySnakeGame.MadeBalk(PrePosition,Position,CurDir,CurBodyType,Name);	
			table.insert(balklist,balk);
	end
	return balklist;
end