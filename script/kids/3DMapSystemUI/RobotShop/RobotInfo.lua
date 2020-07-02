--[[
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotInfo.lua");
------------------------------------------------------------
--]]
if(not Map3DSystem)then Map3DSystem = {};end
if(not Map3DSystem.Map)then Map3DSystem.Map = {};end
if(not Map3DSystem.Map.RobotShop)then Map3DSystem.Map.RobotShop = {};end

local robotInfo = {
	ID=nil,
	RobotID=nil,
	Name=nil,
	Specialty=nil,
	Race=nil,
	Price=nil,
	PicURL=nil,
	ModelPath=nil,
	Used=nil,
}
Map3DSystem.Map.RobotShop.RobotInfo = robotInfo;

function robotInfo:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end


function robotInfo:Test()
	local t={};
	t.name="ddddd";
	log(string.format("%s",t.name));
end
function robotInfo:Destroy()
	
end


