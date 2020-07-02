--[[
Title: Value Tracker
Author(s): LiXizhi
Date: 2008/12/28
Desc: a class for tracking the history of values. 
	It is used for network values such as player positions, etc.
	It keeps a history of most recent (time, value) pairs.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/ValueTracker.lua");
local vtracker = Map3DSystem.JGSL.ValueTracker:new()
-- vtracker:SetSize(2) -- default is 2
vtracker:Push(10,"a")
vtracker:Push(11,"b")
vtracker:Push(12,"c")
print(vtracker:GetValue(), vtracker:GetTime(), vtracker:IsConstant())
vtracker:Push(13,"c")
vtracker:Push(14,"c")
print(vtracker:GetValue(), vtracker:GetTime(), vtracker:IsConstant())
vtracker:Push(15,"d")
print(vtracker:GetValue(), vtracker:GetTime(), vtracker:IsConstant())
print(vtracker:GetValue(-1), vtracker:GetTime(-1), vtracker:IsConstant())

-- output should be:
-->c	12	false-->c	14	true-->d	15	false-->c	14	false
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");

if(not Map3DSystem.JGSL.ValueTracker) then Map3DSystem.JGSL.ValueTracker = {};end;

local JGSL = Map3DSystem.JGSL;
local ValueTracker = Map3DSystem.JGSL.ValueTracker;

-- default size is 2, which keeps just one history item. 
function ValueTracker:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self

	-- for data keeping. 
	o.pos = 0;
	o.times = {};
	o.values = {};
	o:SetSize(2);
	return o
end

-- make the tracker empty
function ValueTracker:Reset()
	local nSize = self:GetSize();
	local i;
	for i=1, nSize do
		self.times[i] = nil;
	end
	self.pos = 1;
end

-- Get how many items to be kept in the tracker 
function ValueTracker:GetSize()
	return self.size;
end

-- set how many items to be kept in the tracker
function ValueTracker:SetSize(nSize)
	self.size = nSize;

	if(self.pos<=0 or self.pos>self.size) then
		self.pos = 1;
	end	
	table.resize(self.times, self.size, nil);
	table.resize(self.values, self.size, nil);
end


-- push a new item to the tracker.
-- @param time 
-- @param value 
function ValueTracker:Push(time, value)
	self.pos = self.pos+1;
	if(self.pos>self.size) then
		self.pos = 1;
	end
	self:Update(time, value);
end

-- only push the new item to the tracker, if its value is changed from the newest object in history. 
-- @param time 
-- @param value 
-- @return true if push is performed. 
function ValueTracker:CheckPush(time, value)
	if(self:GetValue() ~= value and value~=nil) then
		self:Push(time, value);
		return true
	end	
end

-- update the current (latest) value 
-- @param time 
-- @param value 
function ValueTracker:Update(time, value)
	self.times[self.pos] = time;
	self.values[self.pos] = value;
end

-- get the time in history. 
-- @param nPos 0 means current one, -1 means last one. 1 means first one
function ValueTracker:GetTime(nPos)
	nPos = nPos or 0;
	nPos = self.pos+nPos;
	if(nPos<1) then
		nPos = nPos + self.size;
		if(nPos>=1) then
			return self.times[nPos];
		end	
	elseif(nPos>self.size) then
		nPos = nPos - self.size;
		if(nPos>=1) then
			return self.times[nPos];
		end	
	else
		return self.times[nPos];
	end
	return nil;
end

-- return true if the content is newer than time
-- @param time: the time value to compare with the lastest item in history
function ValueTracker:IsUpdated(time)
	local t = self:GetTime();
	return (t and t>time);
end

-- get the value in history. 
-- @param nPos 0 means current one, -1 means last one. 1 means first one
-- @return nil, if not one is found
function ValueTracker:GetValue(nPos)
	nPos = nPos or 0;
	nPos = self.pos+nPos;
	if(nPos<1) then
		nPos = nPos + self.size;
		if(nPos>=1) then
			return self.values[nPos];
		end	
	elseif(nPos>self.size) then
		nPos = nPos - self.size;
		if(nPos>=1) then
			return self.values[nPos];
		end	
	else
		return self.values[nPos];
	end
	-- this should never be called
	return;
end


-- return true if the last value. i.e. GetValue(0) is the same as the passed value
-- if the last value is empty, it will always return false.
-- @param right with which to compare
-- @return 
function ValueTracker:CompareWith(right)
	if(self.times[self.pos] == nil) then
		return false;
	end	
	return (self.values[self.pos] == right);
end

-- return whether all values in the tracker are the same. 
-- @note: if any slot of the tracker is empty, this function will return false.
function ValueTracker:IsConstant()
	local bFirstValue = true;
	local bConstant = false;
	local lastValue;
	local i;
	for i=1, self.size do
		if( self.times[i] ~= nil) then
			if(bFirstValue) then
				lastValue = self.values[i];
				bConstant = true;
				bFirstValue = nil;
			else
				if(lastValue ~= self.values[i]) then
					return false;
				end	
			end
		else
			return false;
		end	
	end
	return bConstant;
end