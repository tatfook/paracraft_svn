--[[
Title: Objects Add page
Author(s): LiXizhi
Date: 2009/2/8
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Objects/ObjectSelectPage.lua");
------------------------------------------------------------
]]

local ObjectSelectPage = {};
commonlib.setfield("Map3DSystem.App.Creator.ObjectSelectPage", ObjectSelectPage)

-- singleton page instance. 
local page;

-- called to init page
function ObjectSelectPage.OnInit()
	page = document:GetPageCtrl();
end

------------------------
-- page events
------------------------

function ObjectSelectPage.OnClose()
end

function ObjectSelectPage.OnRefresh()
	page:Refresh(0);
end
function ObjectSelectPage.HookSelectedMsg()
	
end
