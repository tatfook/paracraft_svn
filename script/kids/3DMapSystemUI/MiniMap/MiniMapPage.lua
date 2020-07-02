--[[
Title: Mini Map Page
Author(s): LiXizhi
Date: 2008/6/22
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/MiniMapPage.lua");
Map3DSystem.App.MiniMap.MiniMapPage.Show()
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/MiniMapWnd.lua");

-- create class
local MiniMapPage = {};
commonlib.setfield("Map3DSystem.App.MiniMap.MiniMapPage", MiniMapPage);

-- on init show the current avatar in pe:avatar
function MiniMapPage.OnInit()
	local self = document:GetPageCtrl();
	self:SetNodeValue("FixMap", Map3DSystem.UI.MiniMapWnd.IsMapFixed());
end

MiniMapPage.Name = "MiniMapDlg";

-- toggle show/hide mini map window
-- @param x,y: position at which to display the window. If nil, the center of screen is used. 
function MiniMapPage.Show(bShow, x, y)
	-- TODO: ensure x,y is inside window area. 
	local _this,_parent;
	_this=ParaUI.GetUIObject(MiniMapPage.Name);
	
	if(not _this:IsValid()) then
		if(bShow == false) then return end
		bShow = true;
		
		local width, height = 140, 160;
		if(x==nil and  y==nil) then
			_this = ParaUI.CreateUIObject("container", MiniMapPage.Name, "_rt", -width, 0, width, height)
		else
			_this = ParaUI.CreateUIObject("container", MiniMapPage.Name, "_lt", x, y, width, height)
		end	
		_this.background = "Texture/3DMapSystem/MiniMap/BG.png:30 30 30 30";
		_this:AttachToRoot();
		_this.zorder = -1;
		_parent = _this;
		
		if(MiniMapPage.MyPage == nil) then
			MiniMapPage.MyPage = Map3DSystem.mcml.PageCtrl:new({url="script/kids/3DMapSystemUI/MiniMap/MiniMapPage.html"});
		end	
		MiniMapPage.MyPage:Create("MiniMapPage", _parent, "_fi", 0, 0, 0, 0)
		_this = _parent;
	else
		if(bShow==nil) then
			bShow = not _this.visible;
		end
		if(not bShow) then
			MiniMapPage.OnClose()
		end
	end
end

-- whether to rotate map or not. 
function MiniMapPage.OnCheckFixMap(checked)
	Map3DSystem.UI.MiniMapWnd.SetMapFixed(checked);
end

-- open using external system web browser, such as ie
function MiniMapPage.OnClose()
	ParaUI.Destroy(MiniMapPage.Name);
end