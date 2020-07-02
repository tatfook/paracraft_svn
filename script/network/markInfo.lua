
--[[

*****this file is deprecated******




NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/network/mapMark_db.lua");
NPL.load("(gl)script/network/localMapMark_db.lua");
-------------------------------------------------------------------
local markInfo = {
	markID = "myID",
	level = 1,
	location = "China",
	isOnline = false,
	detail = "Game Create World", 
	logo = nil;
	markStyle = "Texture/worldMap/mark_1.png";
	displayLvl = 1;
	coordinate_x = 0,
	coordinate_y = 0,
	editable = false;
}
CommonCtrl.markInfo = markInfo;
 
function markInfo:new (o)
	o = o or {}  
	setmetatable(o, self)
	self.__index = self
	return o
end
 
function markInfo:GetMarkID()
	return self.markID;
end

function markInfo:GetLevel()
	return self.level;
end

function markInfo:GetLocation()
	return self.location;
end

function markInfo:GetIsOnline()
	return self.isOnline;
end

function markInfo:SetIsOnline(bOnline)
	self.isOnline = bOnline;
end

function markInfo:GetDetail()
	return self.detail;
end

function markInfo:GetLogo()
	return self.logo;
end

function markInfo:GetCoordinate()
	if( self == nil)then	
		log(".....nil\n");
	end
	return self.coordinate_x,self.coordinate_y;
end

function markInfo:SetCoordinate(x,y)
	self.coordinate.x = x;
	self.coordinate.y = y;
end

function markInfo:SetDisplayLvl(_level)
	self.displayLvl = _level;
end

function markInfo:GetDisplayLvl()
	return self.displayLvl;
end

function markInfo:GetMarkStyle()
	return self.markStyle;
end

function markInfo:SetMarkStyle(_markStyle)
	self.markStyle = _markStyle;
end

function markInfo:SetEditable(_isEditable)
	self.editable = _isEditable;
end

function markInfo:IsEditable()
	return self.editable;
end

function markInfo:SetLocation(location)
	self.location = location;
end

function markInfo:SetDetail(detail)
	self.detail = detail;
end

	
--]]

