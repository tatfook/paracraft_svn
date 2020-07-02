--[[
Author(s): Leio
Date: 2007/12/7
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotShopWnd.lua");
------------------------------------------------------------
]]

if( not Map3DSystem.UI.RobotShopWnd) then Map3DSystem.UI.RobotShopWnd = {};end

NPL.load("(gl)script/ide/common_control.lua");

if( not Map3DSystem.UI.RobotShopWnd) then Map3DSystem.UI.RobotShopWnd = {};end
Map3DSystem.UI.RobotShopWnd.SideBarWidth = 200;
Map3DSystem.UI.RobotShopWnd.splitWidth = 15;
Map3DSystem.UI.RobotShopWnd.hideSizeBar = false;
Map3DSystem.UI.RobotShopWnd.name = "Map3DSystem.UI.RobotShopWnd"

function Map3DSystem.UI.RobotShopWnd.Show(bShow,_parent,parentWindow)
	local this;
	local left,top,width,heiht;

	Map3DSystem.UI.RobotShopWnd.parentWnd = parentWindow;

	_this = ParaUI.GetUIObject(Map3DSystem.UI.RobotShopWnd.name);
	if(_this:IsValid())then
		_this.visible = bShow;
		if( not bShow)then
			Map3DSystem.UI.RobotShopWnd.OnDestroy();
		end
	else
		if( bShow == false)then
			return;
		end
		
		_this = ParaUI.CreateUIObject("container",Map3DSystem.UI.RobotShopWnd.name,"_fi",4,4,4,4);
		if( _parent == nil)then
			_this:AttachToRoot();
		else
			_parent:AddChild(_this);
		end
		_parent = _this;
		--_parent.onsize = ";Map3DSystem.UI.RobotShopWnd.Resize()";
		
		local _,_,width,height = _parent:GetAbsPosition();
		local _width = width - Map3DSystem.UI.RobotShopWnd.splitWidth - Map3DSystem.UI.RobotShopWnd.SideBarWidth;
		
		NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotShopManager.lua");
		Map3DSystem.UI.RobotShopManager.ShowRobotShop(true,"_lt",0,0, _parent);
	end
end

function Map3DSystem.UI.RobotShopWnd.OnDestroy()
	--ParaUI.Destroy();
end

function Map3DSystem.UI.RobotShopWnd.OnClose()
	if( Map3Dsystem.UI.MapMainWnd.parentWnd ~= nil)then
		Map3DSystem.UI.RobotShopWnd.parentWnd:SendMessage(Map3DSystem.UI.RobotShopWnd.parentWnd.name,CommonCtrl.os.MSGTYPE.WM_CLOSE);
	else
		ParaUI.Destroy("Map3DSystem.UI.RobotShopWnd");
	end
end

