--[[
Title: code behind for page for BattleMiniMap.html
Author(s): LiXizhi
Date: 2012/12/20
Desc: script/apps/Aries/Combat/Battlefield/BattleMiniMap.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/Battlefield/BattleMiniMap.lua");
local BattleMiniMap = commonlib.gettable("MyCompany.Aries.Battle.BattleMiniMap");
-------------------------------------------------------
]]
local BattleMiniMap = commonlib.gettable("MyCompany.Aries.Battle.BattleMiniMap");

local page
function BattleMiniMap.OnInit()
	page = document:GetPageCtrl();
	BattleMiniMap.page = page;
end

function BattleMiniMap.ShowMiniMapPage()
	System.App.Commands.Call("File.MCMLWindowFrame", {
		-- Add uid to url
		url = "script/apps/Aries/Combat/Battlefield/BattleMiniMap.html", 
		name = "Aries.BattleMiniMap",
		app_key = MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, 
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 200,
		allowDrag = false,
		enable_esc_key = true,
		click_through = true,
		directPosition = true,
			align = "_ct",
			x = -220,
			y = -180,
			width = 256,
			height = 256,
	});
end

-- virtual public API
-- @param name: the point name string
-- @param point: {x,y,text,rotation, tooltip, school, width, height, background,zorder }. if nil, it will clear the given point. 
-- @param bRefreshImmediate: true to refresh immediately. 
function BattleMiniMap.ShowPoint(name, point, bRefreshImmediate)
	if(page) then
		page:CallMethod("battlefield_mini_map", "ShowPoint", name, point);
	end
end

