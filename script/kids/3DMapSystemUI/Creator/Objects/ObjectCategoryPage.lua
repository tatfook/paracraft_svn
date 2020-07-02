--[[
Title: Objects Category page
Author(s): LiXizhi
Date: 2009/2/8
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Objects/ObjectCategoryPage.lua");
------------------------------------------------------------
]]

local ObjectCategoryPage = {};
commonlib.setfield("Map3DSystem.App.Creator.ObjectCategoryPage", ObjectCategoryPage)

-- singleton page instance. 
local page;

-- called to init page
function ObjectCategoryPage.OnInit()
	page = document:GetPageCtrl();
end

------------------------
-- page events
------------------------
function ObjectCategoryPage.OnClose()
end
