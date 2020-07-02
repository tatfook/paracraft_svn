--[[
Title: 
Author(s): Leio
Date: 2009/8/29
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/SwfMapPage.lua");
Map3DSystem.App.MiniMap.SwfMapPage.viewRect = {
	left = 19400,
	top = 19400,
	width = 1200,
	height = 1200,
}
Map3DSystem.App.MiniMap.SwfMapPage.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashPlayerControl.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
-- default member attributes
local SwfMapPage = {
	-- the top level control name
	name = "SwfMiniMapPage1",
	background = "", -- current background, it can be a swf file or image file.
	-- normal window size
	align = "_lt",
	left = 20,
	top = 20,
	width = 550,
	height = 550, 
	viewRect = {
		left = 19400,
		top = 19400,
		width = 1200,
		height = 1200,
	},
	swfile = "Map.swf",
	tilesFolder = "temp/tiles/",
}
commonlib.setfield("Map3DSystem.App.MiniMap.SwfMapPage",SwfMapPage);

function SwfMapPage.OnInit()
	local self = SwfMapPage;
	self.page = document:GetPageCtrl();
end
--@param app: defualt value is MyCompany.Taurus.app
function SwfMapPage.ShowPage(app,isnewminimap)
	local self = SwfMapPage;
	app = app or MyCompany.Taurus.app;
	SwfMapPage.bIsNewMiniMap = isnewminimap or false;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/MiniMap/SwfMapPage.html", 
			name = "SwfMapPage.SwfMapPage", 
			app_key = app.app_key, 
			isShowTitleBar = true,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			--style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			directPosition = true,
				align = self.align,
				x = self.left,
				y = self.top,
				width = self.width,
				height = self.height,
				text = "世界地图",
		});
	if(self.page)then
		local ctl = self.page:FindControl("flashctl");
		if(ctl)then
			local index = ctl.FlashPlayerIndex;
			local x,y,w,h = self.viewRect.left,self.viewRect.top,self.viewRect.width,self.viewRect.height
			local func_args = {
						funcName = "InitPostion",
						args = {
							x,y,w,h
						}
					} 
			commonlib.CallFlashFunction(index, func_args)
			
			local func_args = {
						funcName = "SetFolder",
						args = {
							self.tilesFolder,
						}
					} 
			commonlib.CallFlashFunction(index, func_args)
		end
	end
	
end
function SwfMapPage.ClosePage()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="MiniGames.SwfMapPage", 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,bDestroy = true,});
end


function SwfMapPage.SetPosRange(xRange,yRange)
	local self = SwfMapPage;
	local center_x = self.viewRect.left + self.viewRect.width/2;
	local center_y = self.viewRect.top + self.viewRect.height/2;
	local x = center_x + xRange * self.viewRect.width/2;
	local z = center_y - yRange * self.viewRect.height/2;
	

	Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x = x, z = z});
end
function SwfMapPage.GetPosRange()
	local self = SwfMapPage;
	local x,__,y = ParaScene.GetPlayer():GetPosition();
	local center_x = self.viewRect.left + self.viewRect.width/2;
	local center_y = self.viewRect.top + self.viewRect.height/2;
	
	local xRange = 2 * (x - center_x)/self.viewRect.width;
	local yRange = -2 * (y - center_y)/self.viewRect.height;--取反
	
	return xRange,yRange,x,y;
end 
--CallNPLFromAs
--跳转到某个位置
function SwfMapPage.GoToPosByRange(xRange,yRange)
	local self = SwfMapPage;
	self.SetPosRange(xRange,yRange)
end
function SwfMapPage.GoToPos(x,y)
	if(SwfMapPage.bIsNewMiniMap)then
		NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/NewMiniMap.lua");
		Map3DSystem.App.MiniMap.NewMiniMap.SetWorldPos(x,y);
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x = x, z = y});
		if(SwfMapPage.page)then
			SwfMapPage.page:CloseWindow();
		end
	else
		local self = SwfMapPage;
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x = x, z = y});
	end
end