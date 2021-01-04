--[[
Title: a Macro base class
Author(s): LiXizhi
Date: 2021/1/2
Desc: a macro is a set of recordable command that is triggered by a short user action, like clicking or typing. 
The concept is from VBA of MS Office. 

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/Macro.lua");
local Macro = commonlib.gettable("MyCompany.Aries.Game.Macro");
-------------------------------------------------------
]]
-------------------------------------
-- single Macro base
-------------------------------------
NPL.load("(gl)script/ide/System/Core/ToolBase.lua");
local Macro = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("MyCompany.Aries.Game.Macro"));
Macro:Property({"Name", "Macro"});

function Macro:ctor()
end

--virtual :
function Macro:Play()
end

--virtual :
function Macro:Record()
end



