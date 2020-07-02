--[[
Title: Objects Add page
Author(s): LiXizhi
Date: 2009/2/8
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Objects/ObjectRotatePage.lua");
------------------------------------------------------------
]]

local ObjectRotatePage = {};
commonlib.setfield("Map3DSystem.App.Creator.ObjectRotatePage", ObjectRotatePage)

-- singleton page instance. 
local page;

-- called to init page
function ObjectRotatePage.OnInit()
	page = document:GetPageCtrl();
end

------------------------
-- page events
------------------------

function ObjectRotatePage.OnClose()
end

function ObjectRotatePage.OnRefresh()
	page:Refresh(0.01);
end
