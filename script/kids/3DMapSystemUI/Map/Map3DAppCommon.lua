

if(not Map3DApp) then Map3DApp = {};end;

--Default Font
Map3DApp.DefaultFont = "System";


---------timer id creator------------------------------
--all timer id used in 3d map was created by this class
--------------------------------------------------------
Map3DApp.Timer = {};
Map3DApp.Timer.minTimerID = 200;
Map3DApp.Timer.maxTimerID = Map3DApp.Timer.minTimerID - 1;

function Map3DApp.Timer.GetNewTimerID()
	Map3DApp.Timer.maxTimerID = Map3DApp.Timer.maxTimerID + 1;
	return Map3DApp.Timer.maxTimerID;
end

function Map3DApp.Timer.GetMinTimerID()
	return Map3DApp.Timer.minTimerID;
end

function Map3DApp.Timer:GetMaxTimerID()
	return Map3DApp.Timer.maxTimerID();
end

function Map3DApp.Timer:GetIDCount()
	return Map3DApp.Timer.maxTimerID - Map3DApp.Timer.minTimerID + 1;
end
-----------------------------------------


-----------------------------
----------Queue--------------
local Queue = {
	list = {};
	firstElement =1;
	lastElement = 0;
	elementCount = 0;
	maxElementCount = 0;
}

Map3DApp.Queue = Queue;


function Queue:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function Queue:Dispose()
	self.list = nil;
	self.firstElement = nil;
	self.lastElement = nil;
	self.elementCount = nil;
end

function Queue:AddElement(element)
	if(self.maxElementCount > 0)then
		if(self.elementCount + 1 > self.maxElementCount)then
			return false;
		end
	end
	
	self.lastElement = self.lastElement + 1;
	self.list[self.lastElement] = element;
	self.elementCount = self.elementCount + 1;
	return true;
end

function Queue:PopElement()
	if(self.elementCount < 1)then
		return nil;
	end
	
	local element = self.list[self.firstElement];
	self.list[self.firstElement] = nil;
	self.firstElement = self.firstElement + 1;
	self.elementCount = self.elementCount - 1;
	
	--no element,reset queue
	if(self.elementCount < 1)then
		self.firstElement = 1;
		self.lastElement = 0;
	end
	return element;
end

function Queue:GetElementCount()
	return self.elementCount;
end

--Returns the object at the beginning of the Queue
--without removing it
function Queue:Peek()
	if(self.elementCount < 1)then
		return nil;
	end
	return self.list[self.firstElement];
end

function Queue:LastElement()
	if(self.elementCount < 1)then
		return nil;
	end
	return self.list[self.lastElement];
end

function Queue:GetEnumerator()
	local i = -1;
	return function()
		if(i < self.elementCount)then
			i = i+1;
			return self.list[self.firstElement + i];
		end
	end	
end

function Queue:GetMaxElementCount()
	return self.maxElementCount();
end

function Queue:Clear()
	self.list = {};
	self.firstElement = 1;
	self.lastElement = 0;
	self.elementCount = 0;
end

-----------------

local CycleQueue = {
	--only set this value at init time
	maxElementCount = 0;
	--thers are all private data
	list = {};
	firstElement=1;
	lastElement=0;
	elementCount = 0;
}
Map3DApp.CycleQueue = CycleQueue;

function CycleQueue:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function CycleQueue:Dispose()
	self.list = nil;
end

function CycleQueue:AddElement(element)
	if(self.elementCount >=self.maxElementCount)then
		log("CycleQueue is full,add element failed\n");
		return false;
	end
	
	self.lastElement = math.mod( self.lastElement,self.maxElementCount)+1;
	self.list[self.lastElement] = element;
	self.elementCount = self.elementCount + 1;
	return true
end

function CycleQueue:PopElement()
	if(self.elementCount < 1)then
		return nil;
	end
	
	local element = self.list[self.firstElement];
	self.list[self.firstElement] = nil;
	self.firstElement = math.mod(self.firstElement,self.maxElementCount)+1;
	self.elementCount = self.elementCount - 1;
	
	if(self.elementCount < 1)then
		self.firstElement = 1;
		self.lastElement = 0;
		self.list ={};
	end
	
	return element;
end

function CycleQueue:Peek()
	return self.list[self.firstElement];
end

function CycleQueue:LastElement()
	if(self.elementCount < 1)then
		return nil;
	end
	return self.list[self.lastElement];
end

function CycleQueue:GetEnumerator()
	local i = 0;
	local index = self.firstElement;
	return function()
		if(i<self.elementCount)then
			if(i>0)then
				index = math.mod(index,self.maxElementCount)+1;
			end
			i = i+1;
			print(index);
			return self.list[index];
		else
			return nil;
		end
	end
end

function CycleQueue:GetElementCount()
	return self.elementCount;
end

function CycleQueue:GetMaxElementCount()
	return self.maxElementCount;
end

function CycleQueue:Clear()
	self.list = {};
	self.firstElement = 1;
	self.lastElement = 0;
	self.elementCount = 0;
end

	
