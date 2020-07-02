--[[
Title: Objects Move page
Author(s): LiXizhi
Date: 2009/2/8
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Objects/ObjectMovePage.lua");
------------------------------------------------------------
]]

local ObjectMovePage = {};
commonlib.setfield("Map3DSystem.App.Creator.ObjectMovePage", ObjectMovePage)

-- singleton page instance. 
local page;

-- called to init page
function ObjectMovePage.OnInit()
	page = document:GetPageCtrl();
end

------------------------
-- page events
------------------------

function ObjectMovePage.OnClose()
end

function ObjectMovePage.OnRefresh()
	page:Refresh(0.01);
end
