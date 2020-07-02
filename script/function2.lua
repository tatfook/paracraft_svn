--[[
Title: menu item 2 handler
Author(s): LiXizhi
Date: 2006/7/15
Desc: reserved for debugging
Use Lib:
-------------------------------------------------------
NPL.activate("(gl)script/function2.lua");
-------------------------------------------------------
]]

local function activate(intensity)
	
	-- Do anything u want, here 
	--NPL.activate("D:/lxzsrc/ParaEngine/ParaEngine plugins/samples/HelloWorld/Debug/HelloWorld.dll","1");
	--NPL.activate("D:/lxzsrc/ParaEngine/ParaEngine plugins/samples/HelloWorldMFC/Debug/HelloWorldMFC.dll", "1");
	--NPL.activate("D:/lxzsrc/ParaEngine/ParaEngine plugins/samples/HelloworldManaged/Debug/HelloworldManaged.dll", "1");
	NPL.activate("ParaAllInOne.dll");
	
	--NPL.activate("D:/lxzsrc/ParaEngine/ParaEngine plugins/samples/HelloWorldMFC/Release/HelloWorldMFC.dll", "1");
	--NPL.activate("D:/lxzsrc/ParaEngine/ParaEngine plugins/samples/HelloWorld/Release/HelloWorld.dll");
end
NPL.this(activate);