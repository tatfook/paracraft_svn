--[[
Author(s): Leio
Date: 2007/12/7
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotShopManager.lua");
------------------------------------------------------------
		
--]]
NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotInfo.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotDB.lua");
 NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotUIBase.lua");
local L = CommonCtrl.Locale("Kids3DMap");

if(not Map3DSystem.UI.RobotShopManager) then Map3DSystem.UI.RobotShopManager={}; end

function Map3DSystem.UI.RobotShopManager.ShowRobotShop(bShow, alignment, left, top,_parentWnd)
	
	--Map3DSystem.UI.RobotUIBase.Init(_parentWnd);
	--Map3DSystem.UI.RobotUIBase.BuyBtnClick();
	
	--NPL.load("(gl)script/network/Map3DCanvas.lua");
	--Map3DCanvas.Show();
	
	----test snake game
	NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/SnakeGameMain.lua");
	Map3DSystem.UI.SnakeGameMain.Init(_parentWnd)
end

function Map3DSystem.UI.RobotShopManager.OnClose()
	
	if(Map3DSystem.UI.RobotShopManager.OnCloseCallBack~=nil) then
		Map3DSystem.UI.RobotShopManager.OnCloseCallBack();
	end
	
end