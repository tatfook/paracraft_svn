--[[
Title: PEBookLoader
Author(s): Leio
Date: 2009/5/26
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/PEBook/PEBookLoader.lua");
------------------------------------------------------------
]]
local PEBookLoader = {
	name = "PEBookLoader_instance",
}
commonlib.setfield("Map3DSystem.App.PEBook.PEBookLoader",PEBookLoader);
function PEBookLoader:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self;
	o:Init();
	return o
end
function PEBook:Init()
	self.name = ParaGlobal.GenerateUniqueID();
	CommonCtrl.AddControl(self.name, self);
end
function PEBookLoader:Load(remotefile)

end
function PEBookLoader.OnComplete(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self)then
		
	end
end