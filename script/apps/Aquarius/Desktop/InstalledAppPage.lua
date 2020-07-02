--[[
Title: code behind for page InstalledAppPage.html
Author(s): LiXizhi
Date: 2009/2/21
Desc:  script/apps/Aquarius/Desktop/InstalledAppPage.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Desktop/InstalledAppPage.lua");
MyCompany.Aquarius.InstalledAppPage.Proc_Authentication(values, funcCallBack, bSkipAppRegistration)
-------------------------------------------------------
]]

local InstalledAppPage = {};
commonlib.setfield("MyCompany.Aquarius.InstalledAppPage", InstalledAppPage)

-- singleton
local page;

---------------------------------
-- page event handlers
---------------------------------
-- init
function InstalledAppPage.OnInit()
	page = document:GetPageCtrl();
end

function InstalledAppPage.OnSwitchApp(app_key)
	_guihelper.MessageBox(app_key)
end

---------------------------------
-- app related functions 
---------------------------------
local UserApps = nil;
local function LoadUserInstalledApp()
	UserApps = {};
	-- load initial data set. 
	local key, app;
	for key, app in Map3DSystem.App.AppManager.GetNextApp() do
		UserApps[#UserApps+1] = {Title = app.Title or app.SubTitle or app.name, app_key = app.app_key, icon = app.icon, about=app.about};
	end
	-- TODO: sort according to some app.order field, where we allow app.order to be customized by user. 
	
	-- I just assign order. at publish time the order should be saved to local app settings. 
	local order; 
	for order, app in ipairs(UserApps) do
		app.order = order;
	end
end

local function GetAppByOrder(order)
	return UserApps[order]
end

local function GetAppOrder(app_key)
	local order; 
	for order, app in ipairs(UserApps) do
		if(app.app_key== app_key) then
			return order;
		end	
	end
end

local function MoveAppOrder(order_from, order_to)
	local order; 
	if(order_from<order_to) then
		for order = order_from, order_to-1, 1 do
			UserApps[order+1], UserApps[order] = UserApps[order], UserApps[order+1]
		end
	elseif(order_from>order_to) then
		for order = order_from, order_to+1, -1 do
			UserApps[order-1], UserApps[order] = UserApps[order], UserApps[order-1]
		end
	end	
end

local function GetAppCount()
	return #UserApps;
end

-- datasource function for pe:gridview
function InstalledAppPage.DS_InstalledApp_Func(index)
	if(not UserApps) then
		LoadUserInstalledApp();
	end
	if(index == nil) then
		return #(UserApps);
	else
		return UserApps[index];
	end
end


---------------------------------
-- dragging box functions 
---------------------------------

-- the app dragger. 
function InstalledAppPage.CreateAppDragger(params, mcmlNode)
	local _this = ParaUI.CreateUIObject("container", "b", params.alignment, params.left, params.top, params.width, params.height);
	params.parent:AddChild(_this);
	_this.background = "Texture/3DMapSystem/common/dragmove.png";
	_this.onmousedown = string.format(";MyCompany.Aquarius.InstalledAppPage.OnMouseDownDragger(%d,%q);", _this.id, mcmlNode:GetAttributeWithCode("app_key"));
	_this.onmousemove = string.format(";MyCompany.Aquarius.InstalledAppPage.OnMouseMoveDragger(%d,%q);", _this.id, mcmlNode:GetAttributeWithCode("app_key"));
	_this.onmouseup = string.format(";MyCompany.Aquarius.InstalledAppPage.OnMouseUpDragger(%d,%q);", _this.id, mcmlNode:GetAttributeWithCode("app_key"));
end

-- drag states
local dragstate = {
	last_down_x = 0,
	last_down_y = 0,
	app_key = nil,
}

-- event
function InstalledAppPage.OnMouseDownDragger(id, app_key)
	dragstate.last_down_x = mouse_x;
	dragstate.last_down_y = mouse_y;
	dragstate.app_key = app_key;
	local dragger = ParaUI.GetUIObject(id);
	if(dragger:IsValid()) then
		local parent = dragger.parent;
		parent.background="Texture/alphadot.png";
	end	
end

-- event
function InstalledAppPage.OnMouseMoveDragger(id, app_key)
	if(dragstate.app_key == app_key) then
		local dragger = ParaUI.GetUIObject(id);
		if(dragger:IsValid()) then
			local parent = dragger.parent;
			parent.translationx = mouse_x - dragstate.last_down_x;
			parent.translationy = mouse_y - dragstate.last_down_y;
			parent:ApplyAnim();
		end
	end	
end

-- event
function InstalledAppPage.OnMouseUpDragger(id, app_key)
	if(dragstate.app_key == app_key) then
		local dragger = ParaUI.GetUIObject(id);
		if(dragger:IsValid()) then
			local parent = dragger.parent;
			parent.translationx = 0;
			parent.translationy = 0;
			parent.background="";
			parent:ApplyAnim();
			
			local x,y, width, height = parent:GetAbsPosition();
			local dx = mouse_x - dragstate.last_down_x;
			local dy = mouse_y - dragstate.last_down_y;
			if(dx>=-100 and dx<=width) then
				local order = GetAppOrder(app_key);
				local orderDest = math.floor(order + dy / height +0.5);
				if(orderDest <=1) then
					orderDest = 1;
				end
				if(orderDest >= GetAppCount()) then
					orderDest = GetAppCount();
				end
				if(orderDest ~= order) then
					MoveAppOrder(order, orderDest)
					page:Refresh(0);
				end
			end
		end
	end	
	dragstate.last_down_x = mouse_x;
	dragstate.last_down_y = mouse_y;
	dragstate.app_key = nil;
end