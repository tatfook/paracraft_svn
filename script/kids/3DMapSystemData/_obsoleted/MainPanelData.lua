--[[
Title: The 3D Map System MainBar Data
Author(s): WangTian
Date: 2007/9/18
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemData/MainPanelData.lua");
------------------------------------------------------------

]]

NPL.load("(gl)script/kids/3DMapSystemData/TableDef.lua");

local L = CommonCtrl.Locale("Kids3DMap");


Map3DSystem.UI.MainPanel.SubPanelOffsetX = 16;
Map3DSystem.UI.MainPanel.SubPanelOffsetY = 24;

Map3DSystem.UI.MainPanel.SubPanelWidth = 460;
Map3DSystem.UI.MainPanel.SubPanelHeight = 150;

-- TODO: temp use
Map3DSystem.UI.MainPanel.PanelBGWidth = 512;
Map3DSystem.UI.MainPanel.PanelBGHeight = 174;

Map3DSystem.UI.MainPanel.ResizerWidth = 16;
Map3DSystem.UI.MainPanel.ResizerHeight = 64;
Map3DSystem.UI.MainPanel.ResizerBG = "Texture/3DMapSystem/MainPanel/ResizerBG.png";


Map3DSystem.UI.MainPanel.WidthSet = {
	[1] = {
		currentWidth = 600,
		minWidth = 600,
		maxWidth = 780,
		allowDrag = true,
		},
	[3] = {
		currentWidth = 600,
		minWidth = 600,
		maxWidth = 600,
		allowDrag = false,
		},
	[5] = {
		currentWidth = 600,
		minWidth = 600,
		maxWidth = 600,
		allowDrag = false,
		},
	[8] = {
		currentWidth = 512,
		minWidth = 512,
		maxWidth = 768,
		allowDrag = false,
		},
	[9] = {
		currentWidth = 512,
		minWidth = 512,
		maxWidth = 768,
		allowDrag = false,
		},
	[10] = {
		currentWidth = 512,
		minWidth = 512,
		maxWidth = 768,
		allowDrag = false,
		},
	};
	
	
Map3DSystem.UI.MainPanel.CurrentActivePanelIndex = nil;

Map3DSystem.UI.MainPanel.App = nil;
Map3DSystem.UI.MainPanel.MainWnd = nil;

Map3DSystem.UI.Creation.WndObject = nil;		
Map3DSystem.UI.Creation.CategoryBoxWndObject = nil;
Map3DSystem.UI.Modify.WndObject = nil;

Map3DSystem.UI.Creation.CategoryBoxStatus = "hide";

Map3DSystem.UI.Creation.PanelPosXOffset = 128;



-- NOTE: depracated
--Map3DSystem.UI.Creation.CategoryIndex = 0;

Map3DSystem.UI.Creation.TotalPage = 0; -- Page: [0, TotalPage-1]
Map3DSystem.UI.Creation.TotalItem = 0;
Map3DSystem.UI.Creation.CurrentPage = 0;
Map3DSystem.UI.Creation.IconMatrixX = 6;
Map3DSystem.UI.Creation.IconMatrixY = 2;


Map3DSystem.UI.Creation.CategoryBoxWidth = 192;
Map3DSystem.UI.Creation.CategoryBoxWidthOffset = 16;
Map3DSystem.UI.Creation.CategoryBoxHeight = 192;

-- the initial size of the side container, it can change according to drag and drop actions
Map3DSystem.UI.Creation.SideContWidth = 128;
Map3DSystem.UI.Creation.SideContHeight = 288;
-- min and max size of the creation side container
Map3DSystem.UI.Creation.SideContWidthMin = 128;
Map3DSystem.UI.Creation.SideContHeightMin = 256;
Map3DSystem.UI.Creation.SideContWidthMax = 256;
Map3DSystem.UI.Creation.SideContHeightMax = 512;
