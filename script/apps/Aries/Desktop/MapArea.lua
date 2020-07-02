--[[
Title: Desktop (Mini)Map Area for Aries App
Author(s): WangTian
Date: 2009/4/7
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/MapArea.lua");
local MapArea = commonlib.gettable("MyCompany.Aries.Desktop.MapArea");
MyCompany.Aries.Desktop.MapArea.Init();
------------------------------------------------------------
]]

-- create class
local libName = "AriesDesktopMapArea";
local MapArea = commonlib.gettable("MyCompany.Aries.Desktop.MapArea");

-- invoked at Desktop.InitDesktop()
function MapArea.Init()
	-- load implementation
	if(System.options.version=="kids") then
		NPL.load("(gl)script/apps/Aries/Desktop/MapArea/MapArea.kids.lua");
		if(System.options.theme == "v2") then
			MapArea.CreateV2();
		else
			MapArea.Create();
		end
	else
		NPL.load("(gl)script/apps/Aries/Desktop/MapArea/MapArea.teen.lua");
		MapArea.Create();
	end
end

-- virtual function: Create UI
function MapArea.Create()
end

-- public API: show or hide the map area, toggle the visibility if bShow is nil
function MapArea.Show(bShow)
	local _mapArea = ParaUI.GetUIObject("MapArea");
	if(_mapArea:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _mapArea.visible;
		end
		_mapArea.visible = bShow;
	end
end

-- virtual public API:enable map teleporting button
function MapArea.EnableButton()
end

-- virtual public API: disable map teleporting button
function MapArea.DisableButton()
end

-- virtual public API: disable map teleporting button
function MapArea.GetParentContainer()
	local _mapArea = ParaUI.GetUIObject("MapArea");
	if(_mapArea:IsValid()) then
		return _mapArea;
	end
end

-- virtual public API
-- @param name: the point name string
-- @param point: {x,y,text,rotation, tooltip, school, width, height, background }. if nil, it will clear the given point. 
-- @param bRefreshImmediate: true to refresh immediately. 
function MapArea.ShowPoint(name, point, bRefreshImmediate)
end

-- virtual API 
-- call this function to enable music programmatically. 
function MapArea.EnableMusic(bChecked)
end

-- refresh the map area page
function MapArea.Refresh()
end

-- virtual public API: this function is called when world is loaded
function MapArea.OnActivateDesktop()
end
