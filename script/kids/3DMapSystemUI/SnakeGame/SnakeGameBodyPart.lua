--[[
Author(s): Leio
Date: 2007/12/17
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/SnakeGameBodyPart.lua");
------------------------------------------------------------
		
]]
if(not Map3DSystem.UI) then Map3DSystem.UI={}; end

local BodyPart={
	Position={x=nil,y=nil},
	PrePosition={x=nil,y=nil},
	--Direction={"North","South","East","West"},
	--BodyType={"A","B","C","D"},
	CurDir=nil,
	CurBodyType=nil,
	Name=nil,
	ModelPath=nil,
	Animation=nil,
	TimeID=nil,
	TimeStart=nil,
}
Map3DSystem.UI.SnakeGameBodyPart=BodyPart;
function BodyPart:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	
	
	o.Position={x=nil,y=nil};
	o.PrePosition={x=nil,y=nil};
	return o;
end

function BodyPart:SetPrePosition(x,y)
	if(x==nil or y==nil) then return end;
	self.PrePosition.x=x;
	self.PrePosition.y=y;
end
function BodyPart:GetPrePosition()
	return self.PrePosition.x,self.PrePosition.y;
end
function BodyPart:SetPosition(x,y)
	if(x==nil or y==nil) then return end;
	self.Position.x=x;
	self.Position.y=y;
end
function BodyPart:GetPosition()
	return self.Position.x,self.Position.y;
end
function BodyPart:SetDirection(dir)
	if(dir==nil) then return end;
	self.CurDir=dir;
end
function BodyPart:GetDirection()
	return self.CurDir;
end
function BodyPart:SetBodyType(type)
	if(type==nil) then return end;
	self.CurBodyType=type;
end
function BodyPart:GetBodyType()
	return self.CurBodyType;
end
function BodyPart:SetName(name)
	if(name==nil) then return end;
	self.Name=name;
end
function BodyPart:GetName()
	return self.Name;
end
function BodyPart:SetModelPath(path)
	if(path==nil) then return end;
	self.ModelPath=path;
end
function BodyPart:GetModelPath()
	return self.ModelPath;
end

function BodyPart:SetAnimation(v)
	if(v==nil) then return end;
	self.Animation=v;
end
function BodyPart:GetAnimation()
	return self.Animation;
end
function BodyPart:SetTimeID(id)
	if(id==nil) then return end;
	self.TimeID=id;
end
function BodyPart:GetTimeID()
	return self.TimeID;
end
function BodyPart:SetTimeStart(v)
	if(v==nil) then return end;
	self.TimeStart=v;
end
function BodyPart:GetTimeStart()
	return self.TimeStart;
end



        