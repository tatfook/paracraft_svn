--[[
Author(s): Leio
Date: 2007/12/21
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/ControlListSnakeGame.lua");
------------------------------------------------------------
		
]]
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/FactorySnakeGame.lua");
if(not Map3DSystem.UI) then Map3DSystem.UI={}; end
local ControlListSnakeGame={
	
}
Map3DSystem.UI.ControlListSnakeGame=ControlListSnakeGame;
function ControlListSnakeGame:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	
	o.TileList={};
	o.SnakeList={};
	o.DotList=nil;
	o.GiftList={};
	o.TileType={None=1,Head=2,Dot=3,Balk=4,Gift=5,Body=6};
	o.MadeDotNumber=nil;
	o.MadeGiftNumber=nil;
	o.NameIndex=1;
	return o;
end
--------------
function ControlListSnakeGame:SetHead(_Position,_CurDir)
	local list=self:GetHead(_Position,_CurDir);
		  self:UpdateTileList(list);
		  
		  for i=1,table.getn(list) do  
			  table.insert(self.SnakeList,list[i]);
		  end
		  
	return list;
		  
end
function ControlListSnakeGame:SetDotList(n)
	
	local list=self:GetDotList(n);
		  self:UpdateTileList(list);
		  self.DotList=list;
	return list;
end
function ControlListSnakeGame:SetBalkList(list)
	--local list=self:GetBalkList(n);
		  self:UpdateTileList(list);
	return list;
end
function ControlListSnakeGame:SetGiftList(n)
	local list=self:GetGiftList(n);
		  self:UpdateTileList(list);
		   --self.GiftList=list;
		   for i=1,table.getn(list) do  
			  table.insert(self.GiftList,list[i]);
		  end
	return list;
end
function ControlListSnakeGame:SetBodyList(list)
		  self:UpdateTileList(list);
		   for i=1,table.getn(list) do  
			  table.insert(self.SnakeList,list[i]);
		  end
	return list;
end
-------------
function ControlListSnakeGame:GetHead(_Position,_CurDir)
	local list={};
	local n=1;
	for i=1,n do
		local PrePosition={x=0,y=0};
		local Position=_Position;
		local CurDir=_CurDir;
		local CurBodyType=self.TileType.Head;
		local Name=self:GetName();
		list[i]=Map3DSystem.UI.FactorySnakeGame.MadeHead(PrePosition,Position,CurDir,CurBodyType,Name);
	end
	return list;
end
function ControlListSnakeGame:GetDotList(n)
	local list={};
	for i=1,n do
		local PrePosition={x=0,y=0};
		local Position=self:GetRandomPosition();
		local CurDir="";
		local CurBodyType=self.TileType.Dot;
		local Name=self:GetName();
		list[i]=Map3DSystem.UI.FactorySnakeGame.MadeDot(PrePosition,Position,CurDir,CurBodyType,Name);
		self.TileList[Position.y][Position.x]=list[i];
	end
	return list;
end
function ControlListSnakeGame:GetBalkList(n)
	local list={};
	for i=1,n do
		local PrePosition={x=0,y=0};
		local Position=self:GetRandomPosition();
		local CurDir="";
		local CurBodyType=self.TileType.Balk;
		local Name=self:GetName();
		list[i]=Map3DSystem.UI.FactorySnakeGame.MadeBalk(PrePosition,Position,CurDir,CurBodyType,Name);
		self.TileList[Position.y][Position.x]=list[i];
	end
	return list;
end
function ControlListSnakeGame:GetGiftList(n)
	local list={};
	for i=1,n do
		local PrePosition={x=0,y=0};
		local Position=self:GetRandomPosition();
		local CurDir="";
		local CurBodyType=self.TileType.Gift;
		local Name=self:GetName();
		list[i]=Map3DSystem.UI.FactorySnakeGame.MadeGift(PrePosition,Position,CurDir,CurBodyType,Name);
		self.TileList[Position.y][Position.x]=list[i];
	end
	return list;
end

function ControlListSnakeGame:GetRandomPosition()
	local c,r=table.getn(self.TileList[1]),table.getn(self.TileList);
	--local c,r=8,8;
	local x,y=math.random(c),math.random(r);
	while (self.TileList[y][x]~=self.TileType.None) do
				
				 x,y=math.random(c),math.random(r);
					
	end
	
	return {x=x,y=y};
	
end
------------------------
function ControlListSnakeGame:GetName()
	self.NameIndex=self.NameIndex+1;
	return "name_"..self.NameIndex;
end

function ControlListSnakeGame:DotEaten(x,y)
	
	local part=self.TileList[y][x];
	local newDotList,newGiftList=nil,nil;
	
	local type=part:GetBodyType();
	local index,bool=nil,false;
	
	if (type==self.TileType.Dot) then
		index,bool=self:IsEqual(self.DotList,part)
		
		
		if(bool)then
			--log(string.format("index:%s\n",index));
			self.DotList[index]=nil;
		end
		if(self:IsEmpty(self.DotList)) then
			newDotList=self:SetDotList(self.MadeDotNumber);
		end
	elseif(type==self.TileType.Gift) then
		index,bool=self:IsEqual(self.GiftList,part)
		if(bool)then
			self.GiftList[index]=nil;
		end
		--[[ 
		if(self:IsEmpty(self.GiftList)) then
			newGiftList=self:SetGiftList(self.MadeGiftNumber);
		end
		-]]
	end
	self:Clear(x,y);
	return newDotList,newGiftList;
end

function ControlListSnakeGame:UpdateTileList(list)
	local len=table.getn(list);
	for i=1,len do
		local bodyPart=list[i];
		if (bodyPart~=self.TileType.None) then
			local x,y=bodyPart:GetPosition();
			self.TileList[y][x]=bodyPart;
		end
	end
end

function ControlListSnakeGame:Clear(x,y)
	local bodyPart=self.TileList[y][x];
	if(bodyPart~=self.TileType.None)then
		self.TileList[y][x]=self.TileType.None;
	end
end
function ControlListSnakeGame:IsEqual(list,part)
	--[[
	local len=table.getn(list);
	for i=1,len do
		if(list[i]==part)then
			return i,true;
         else
			return i,false;
         end
	end
	-]]
	
	for i,v in pairs(list) do
		if(v~=nil) then
			if(v:GetName()==part:GetName())then
				return i,true;
			end
		end
         
        
	end
	 
	return nil,false;
         
end

function ControlListSnakeGame:IsEmpty(list)
	local bool=true;
	if (list==nil) then	
		return bool;
	end
	
	for i,v in pairs(list) do
         if ( v~=nil) then
			bool=false;
			
			return bool;
		end
	end
	
	return bool;
end