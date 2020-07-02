--[[
Author(s): Leio
Date: 2007/12/21
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/ContainerControlSnakeGame.lua");
------------------------------------------------------------
		
]]
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/TimerIDFactorySnakeGame.lua");
if(not Map3DSystem.UI) then Map3DSystem.UI={}; end
local ContainerControlSnakeGame={
	SceneGraph=nil,
	Direction={North="North",South="South",East="East",West="West"},
	Dir=nil,
	IsSnakeAlive=nil,
	ControlList=nil,
	TileSize=nil,
	Speed=nil,
	SpeedList=nil,
	TimerInterval=nil,
	HeadPlayer=nil,
	GameLevel=nil,
	EatGiftAnimationStartList=nil,
	EatNum=nil,
	Score=nil,
	TotalEatNum=nil,
	TimeIDList=nil,
}
Map3DSystem.UI.ContainerControlSnakeGame=ContainerControlSnakeGame;
function ContainerControlSnakeGame.Init(_SceneGraph,_ControlList,_TileSize,_GameLevel,TotalEatNum,Score)
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
		  self.Clear();
		  self.SceneGraph=_SceneGraph;
		  self.ControlList=_ControlList;
		  self.TileSize=_TileSize;
		  self.SpeedList={1.5/20,1.8/20,2/20,2.2/20,2.5/20,2.8/20,3/20,4/20};	  
		  local temp_GameLevel=math.floor(_GameLevel/10)+1;	  
		  self.Speed=self.SpeedList[temp_GameLevel];
		  self.TimerInterval=0.2*self.Speed;
		  self.HeadPlayer=nil;
		  self.GameLevel=_GameLevel;
		  self.EatGiftAnimationStartList={};
		  self.EatNum=0;
		  self.TotalEatNum=TotalEatNum;
		  self.Score=Score;
		  self.TimeIDList={};
	NPL.load("(gl)script/ide/event_mapping.lua");
	ParaScene.RegisterEvent("_k_snakegame_keydown", ";Map3DSystem.UI.ContainerControlSnakeGame.OnKeyDownEvent();");
end
function ContainerControlSnakeGame.Clear()
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	
	self.SceneGraph=nil;
	self.Direction={North="North",South="South",East="East",West="West"};
	self.Dir=nil;
	self.IsSnakeAlive=nil;
	self.ControlList=nil;
	self.TileSize=nil;
	self.Speed=nil;
	self.SpeedList=nil;
	self.TimerInterval=nil;
	self.GameLevel=nil;
	self.EatGiftAnimationStartList=nil;
	self.EatNum=nil;
	self.TotalEatNum=nil;
	self.Score=nil;
	
	
end
function ContainerControlSnakeGame.ClearTimeIDList()
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	if(self.TimeIDList==nil)then
		return;
	end
	for i,v in pairs(self.TimeIDList) do
         if ( v~=nil) then
         
         NPL.KillTimer(v);
		end
	end
end
function ContainerControlSnakeGame.DotEaten(part,x,y)
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	local newDotList,newGiftList=self.ControlList:DotEaten(x,y);
		  
	local name=part:GetName();	
		  self.ClearAssetObject(name);
	
	if (newDotList~=nil) then
		for i=1,table.getn(newDotList) do
			local newDot=newDotList[i];
				  self.CreateCharacter(newDot);
		end
	end
	--[[
	if (newGiftList~=nil) then
		for i=1,table.getn(newGiftList) do
			local newGift=newGiftList[i];
				  self.CreateCharacter(newGift);
		end
		self.GiftInterval(newGiftList);
	end
	-]]
end
function ContainerControlSnakeGame.AddBodyPart(part)
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	local x,y=-1,-1;
	
	local len=table.getn(self.ControlList.SnakeList);
	local lastBodyPart=self.ControlList.SnakeList[len];
	local x,y=lastBodyPart:GetPosition();
	local lastBodyPart_dir=lastBodyPart:GetDirection();
	
	
	if(lastBodyPart_dir==self.Direction.North)then 
		x=x;
		y=y+1;
	elseif(lastBodyPart_dir==self.Direction.South) then
		x=x;
		y=y-1;
	elseif(lastBodyPart_dir==self.Direction.East) then
		x=x-1;
		y=y;
	elseif(lastBodyPart_dir==self.Direction.West) then
		x=x+1;
		y=y;
	end
	
	local name="body_"..len
	
	local body_1=Map3DSystem.UI.SnakeGameBodyPart:new();
	
		  body_1:SetPosition(x,y);
		  body_1:SetDirection(lastBodyPart_dir);
		  body_1:SetBodyType(self.ControlList.TileType.Body); 
		  body_1:SetName(name); 
		  body_1:SetModelPath(part:GetModelPath());
		  self.SetBodyList({body_1});
		  
end
function ContainerControlSnakeGame.ClearAssetObject(name)
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	local temp=self.SceneGraph:GetObject(name);
		  if(temp:IsValid())then
			self.SceneGraph:DestroyObject(name);
		  end
end
function ContainerControlSnakeGame.Update()
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	
	if(self.IsSnakeAlive==false)then
		return;
	end
	local head=self.ControlList.SnakeList[1];
	local x,y=head:GetPosition();
	
	
	if(self.Dir==self.Direction.North)then 
		y=y-1;
	elseif(self.Dir==self.Direction.South) then
		y=y+1;
	elseif(self.Dir==self.Direction.East) then
		x=x+1;
	elseif(self.Dir==self.Direction.West) then
		x=x-1;
	end
	
	
	
	if (x<1 or x>self.TileSize or y<1 or y>self.TileSize) then
		self.IsSnakeAlive=false;
		--_guihelper.MessageBox("越界");
		Map3DSystem.UI.SnakeGameMain.GotoLost();
		return;
	end
	
	local part=self.ControlList.TileList[y][x];
	
	if(part~=self.ControlList.TileType.None)then
		local type=part:GetBodyType();
		
		if (type==self.ControlList.TileType.Dot) then
			
			if(self.EatNum<self.TotalEatNum-1)then
				self.EatNum=self.EatNum+1;
				self.SetScore(100);
				
			else 
				--nextlevel
				self.SetScore(100);
				Map3DSystem.UI.SnakeGameMain.GotoNextLevel()
				return;
			end
			self.AddBodyPart(part);
			self.DotEaten(part,x,y);
			
		elseif (type==self.ControlList.TileType.Gift) then
			self.DotEaten(part,x,y);
			self.EatGift(part);
		elseif (type==self.ControlList.TileType.Balk or type==self.ControlList.TileType.Body) then
			self.IsSnakeAlive=false;
			--_guihelper.MessageBox("接触");
			Map3DSystem.UI.SnakeGameMain.GotoLost();
			return;
		end
	end
	
	-----------####
	
	local len=table.getn(self.ControlList.SnakeList);
	--[[
	--
		for i=1,len do
			local bodyPart=self.ControlList.SnakeList[i];
			local temp_x,temp_y=bodyPart:GetPosition();
			self.ControlList.TileList[temp_y][temp_x]=self.ControlList.TileType.None;
		end
	--]]
	local xx,yy,dir_dir=x,y,self.Dir;
	for i=1,len do
		local bodyPart=self.ControlList.SnakeList[i];
		local temp_x,temp_y=bodyPart:GetPosition();
		local temp_dir=bodyPart:GetDirection();
		local timeID=500+i;
		self.ControlList.TileList[temp_y][temp_x]=self.ControlList.TileType.None;
		bodyPart:SetPrePosition(temp_x,temp_y);
		bodyPart:SetPosition(xx,yy);
		
		bodyPart:SetDirection(dir_dir);
		self.ControlList.TileList[yy][xx]=bodyPart;
		self.TimeIDList[timeID]=timeID;
		
		------
		--[[
		local bodyType=bodyPart:GetBodyType();
		local face=bodyPart:GetDirection();
		local name=bodyPart:GetName();	
		local player=self.SceneGraph:GetObject(name);
		local c,r=self.TileSize,self.TileSize;
		local zzz,xxx=xx,yy
		
		if( player:IsValid()) then
		local xxx,yyy,zzz=(zzz-1)-c/2,0,(1-xxx)+r/2;
		--log(string.format("%s,%s,%s\n",x,y,z));
		
		
		player:SetPosition(xxx,yyy,zzz);
		self.SetFaceing(player,face);
		end
		--]]
		------------
		NPL.SetTimer(timeID,self.TimerInterval,string.format(";Map3DSystem.UI.ContainerControlSnakeGame.UpdatePosition(%d,%d)",i,timeID));
		xx,yy=temp_x,temp_y;
		dir_dir=temp_dir;
		
	end

	self.Dir=self.ControlList.SnakeList[1]:GetDirection();
	------------####
	
end
function ContainerControlSnakeGame.GiftInterval(list)
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	
	for i,v in pairs(list) do
		if(v~=nil)then
			local timeID=Map3DSystem.UI.TimerIDFactorySnakeGame.Made();
			local name=v:GetName();
				  v:SetTimeStart(0);
				  v:SetTimeID(timeID);
				  self.TimeIDList[timeID]=timeID;
				  name=string.format("'%s'",name);
				  NPL.SetTimer(timeID,1,string.format(";Map3DSystem.UI.ContainerControlSnakeGame.StartGiftInterval(%s)",name));
		end
	end
end
function Map3DSystem.UI.ContainerControlSnakeGame.StartGiftInterval(name)
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	local part,index;
	for i,v in pairs(self.ControlList.GiftList) do
		local _name=v:GetName();

		if(_name==name)then
			index=i;
			part=self.ControlList.GiftList[i];
			
			break;
		end
	end
	if(part~=nil)then
		  if(part:GetTimeStart()<Map3DSystem.UI.SnakeGameStart.GiftAliveTime)then
			part:SetTimeStart(part:GetTimeStart()+1);
		  else
			part:SetTimeStart(0);
			local timeID=part:GetTimeID();
			NPL.KillTimer(timeID);
			self.TimeIDList[timeID]=nil;
			local x,y=part:GetPosition();
			local _,newGiftList=self.DotEaten(part,x,y);
				if(newGiftList~=nil)then
					  self.GiftInterval(newGiftList);
				end
			self.ControlList.GiftList[index]=nil;
		  end
	end
end
function ContainerControlSnakeGame.EatGift(part)
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	
	local timeID=part:GetTimeID();
		  NPL.KillTimer(timeID);
		 
	local animation=  part:GetAnimation();
	local type=animation.type;
	local score=animation.score;
	local speed=animation.speed;
	local path=animation.path;
	if(type=="type_animation")then
		  local player=self.HeadPlayer;
		  self.PlayAnimationFile(animation.path, player)
		  
		   if(score~="none")then
			self.SetScore(score);
		  end
		  if(speed~="none")then
			local temp_GameLevel=math.floor(self.GameLevel/10)+1;
				  self.Speed=self.SpeedList[temp_GameLevel]*speed;
		  end
		  
		  ------------
		  local timeID=Map3DSystem.UI.TimerIDFactorySnakeGame.Made();
		  self.EatGiftAnimationStartList[timeID]=0;
		  type=string.format("'%s'",type);
		  self.TimeIDList[timeID]=timeID;
		  NPL.SetTimer(timeID,1,string.format(";Map3DSystem.UI.ContainerControlSnakeGame.EatGiftAnimation(%s,%d,%s,%s)",type,timeID,score,speed));
	elseif(type=="type_speed") then
		   local temp_GameLevel=math.floor(self.GameLevel/10)+1;
		   self.Speed=self.SpeedList[temp_GameLevel]*speed;
		   
		   ------------
		   local timeID=Map3DSystem.UI.TimerIDFactorySnakeGame.Made();
		  self.EatGiftAnimationStartList[timeID]=0;
		  type=string.format("'%s'",type);
		  self.TimeIDList[timeID]=timeID;
		  NPL.SetTimer(timeID,1,string.format(";Map3DSystem.UI.ContainerControlSnakeGame.EatGiftAnimation(%s,%d,%s,%s)",type,timeID,score,speed));
	elseif(type=="type_score") then
		   self.SetScore(score);
	end
	
		 
end
function ContainerControlSnakeGame.EatGiftAnimation(type,timeID,score,speed)
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
		   self.EatGiftAnimationStartList[timeID]= self.EatGiftAnimationStartList[timeID]+1;
			
			if(self.EatGiftAnimationStartList[timeID]>4)then
			
				if(type=="type_animation")then
				  local player=self.HeadPlayer;	
						self.PlayAnimationFile("character/Animation/angel/走路.x", player)
						
						if(speed~="none")then
							local temp_GameLevel=math.floor(self.GameLevel/10)+1;
							self.Speed=self.SpeedList[temp_GameLevel];
						end
						
				elseif(type=="type_speed") then
					   local temp_GameLevel=math.floor(self.GameLevel/10)+1;
					   self.Speed=self.SpeedList[temp_GameLevel];
				end	
				self.TimeIDList[timeID]=nil;
				NPL.KillTimer(timeID);
			end
	
end
function ContainerControlSnakeGame.UpdatePosition(i,timeID)
	
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	local bodyPart=self.ControlList.SnakeList[i];
	local startX,startY=bodyPart:GetPrePosition();
	local endX,endY=bodyPart:GetPosition();
	local speed,speed2=self.Speed,self.Speed+self.Speed/10;
	
	local temp_endX=startX+speed;
	local temp_endY=startY+speed;
	local dir_x,dir_y=1,1;
	local dir=bodyPart:GetDirection();
	if(dir==self.Direction.North)then 
		
		dir_y=-1;
	elseif(dir==self.Direction.South) then
		dir_y=1;
	elseif(dir==self.Direction.East) then
		dir_x=1;
	elseif(dir==self.Direction.West) then
		dir_x=-1;
	end
	if (math.abs(temp_endX-endX)<=speed2 and math.abs(temp_endY-endY)<=speed2 ) then
		--log(string.format("kill:%s\n",timeID));
		NPL.KillTimer(timeID);
		self.TimeIDList[timeID]=nil;
		Map3DSystem.UI.ContainerControlSnakeGame.Update()
	end
	
	
	if (math.abs(temp_endX-endX)<=speed2) then
		temp_endX=endX;
	else
		temp_endX=startX+speed*dir_x;
	end
	if (math.abs(temp_endY-endY)<=speed2) then
		temp_endY=endY;
		
	else
		temp_endY=startY+speed*dir_y;
	end
	
	
	bodyPart:SetPrePosition(temp_endX,temp_endY);
	
	
	
		local bodyPart=self.ControlList.SnakeList[i];
		local bodyType=bodyPart:GetBodyType();
		local face=bodyPart:GetDirection();
		local name=bodyPart:GetName();	
		local player=self.SceneGraph:GetObject(name);
		local c,r=self.TileSize,self.TileSize;
		local z,x=temp_endX,temp_endY
		
		if( player:IsValid()) then
		local x,y,z=(z-1)-c/2,0,(1-x)+r/2;
		--log(string.format("%s,%s,%s\n",x,y,z));
		
		
		player:SetPosition(x,y,z);
		self.SetFaceing(player,face);
		end
		
end
-------------
function ContainerControlSnakeGame.SetHead(_Position,_CurDir)
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	local list=self.ControlList:SetHead(_Position,_CurDir);
	
		  self.PushPlayerList(list);
end
function ContainerControlSnakeGame.SetBodyList(list)
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	local list=self.ControlList:SetBodyList(list);
	
		  self.PushPlayerList(list);
end
function ContainerControlSnakeGame.SetDotList(n)
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	
	local list=self.ControlList:SetDotList(n);
	
		  self.PushPlayerList(list);
		  
end
function ContainerControlSnakeGame.SetBalkList(list)
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	local list=self.ControlList:SetBalkList(list);

		  self.PushPlayerList(list);
end
function ContainerControlSnakeGame.SetGiftList(n)
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	local list=self.ControlList:SetGiftList(n);
		  self.PushPlayerList(list);
		  self.GiftInterval(list);
end
--------------
function ContainerControlSnakeGame.PushPlayerList(list)
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	for _,v in pairs(list) do
       
        self.CreateCharacter(v);
    end
end
function ContainerControlSnakeGame.CreateCharacter(bodyPart)
	
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	local c,r=self.TileSize,self.TileSize;
	local assetChar;
	local name=bodyPart:GetName();
	local bodyType=bodyPart:GetBodyType();
	local face=bodyPart:GetDirection();
	local modelPath=bodyPart:GetModelPath();
	local z,x=bodyPart:GetPosition();
	
	assetChar = ParaAsset.LoadParaX("", modelPath);
	
	local player = ParaScene.CreateCharacter (name, assetChar, "", true, 0.2, 3.9, 1.0);
	if( player:IsValid()) then
		local x,y,z=(z-1)-c/2,0,(1-x)+r/2;
		player:SetPosition(x,y,z);
		if (bodyType==self.ControlList.TileType.Head) then 
			player:SetScale(1.2);
			self.PlayAnimationFile("character/Animation/angel/走路.x",player);	
			self.HeadPlayer=player;	
		end
		self.SetFaceing(player,face);
		self.SceneGraph:AddChild(player);
	end	
	
end
function ContainerControlSnakeGame.PlayAnimationFile(filename, player)
	local nAnimID = ParaAsset.CreateBoneAnimProvider(-1, filename, filename, true);
	if(nAnimID>0) then
		player:ToCharacter():PlayAnimation(nAnimID);
	end
end
function Map3DSystem.UI.ContainerControlSnakeGame.OnKeyDownEvent()
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	local dir=self.Dir;
	if( (virtual_key == Event_Mapping.EM_KEY_LEFT or virtual_key == Event_Mapping.EM_KEY_A )and dir~=self.Direction.East) then	
		dir=self.Direction.West;--left
		self.Dir=dir;
		--self.Update();
	elseif( (virtual_key == Event_Mapping.EM_KEY_RIGHT or virtual_key == Event_Mapping.EM_KEY_D ) and dir~=self.Direction.West) then	
		dir=self.Direction.East;--right
		self.Dir=dir;
		--self.Update();
	elseif( (virtual_key == Event_Mapping.EM_KEY_UP or virtual_key == Event_Mapping.EM_KEY_W ) and dir~=self.Direction.South) then	
		dir=self.Direction.North;--up
		self.Dir=dir;
		--self.Update();
	elseif( (virtual_key == Event_Mapping.EM_KEY_DOWN or virtual_key == Event_Mapping.EM_KEY_S ) and dir~=self.Direction.North) then	
		dir=self.Direction.South;--down
		self.Dir=dir;
		--self.Update();
	end
	--log("dir:"..dir.."\n");
	--self.Clear();
	
	
end
function ContainerControlSnakeGame.SetFaceing(player,face)
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
	local facing;
	local pi=3.14;
	if(face==self.Direction.North)then 
		facing=3*pi/2;
	elseif(face==self.Direction.South) then
		facing=pi/2;
	elseif(face==self.Direction.East) then
		facing=0;
	elseif(face==self.Direction.West) then
		facing=pi;
	else
		facing=0;
	end
	player:SetFacing(facing);
end

function ContainerControlSnakeGame.SetScore(v)
	local self=Map3DSystem.UI.ContainerControlSnakeGame;
		  self.Score=self.Score+v;
		  Map3DSystem.UI.SnakeGameMain.UpdateText(self.GameLevel,self.Score);
end