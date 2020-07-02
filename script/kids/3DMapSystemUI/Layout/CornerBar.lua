--[[
Title: corner bar in InGame UI for 3D Map system
Author(s): WangTian
Date: 2007/12/14
Desc: Show the corner bar in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Layout/CornerBar.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");



function Map3DSystem.UI.CornerBar.ShowLeftBottom()
	
	-- left bottom corner bar
	local _leftBottom = ParaUI.CreateUIObject("container", "LeftBottom_CornerBar", "_lb", 
		0, 0, 128, Map3DSystem.UI.MainBar.BarBGHeight);
	_leftBottom.onclick = ";Map3DSystem.UI.CornerBar.OnClickLeftBottomCornerBar();";
	_leftBottom:AttachToRoot();
	
	_bar:AddChild(_this);
end

function Map3DSystem.UI.CornerBar.ShowRightBottom()
	
end

function Map3DSystem.UI.CornerBar.OnClickLeftBottomCornerBar()
	-- show the full bar
	
end