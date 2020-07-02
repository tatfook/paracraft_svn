--[[
Title: inventory window of a given user
Author(s): LiXizhi
Date: 2008/1/12
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Inventory/InventoryWnd.lua");
Map3DSystem.App.Inventory.ShowMyInventory(app);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/Inventory/BagCtl.lua");

commonlib.setfield("Map3DSystem.App.Inventory.InventoryWnd", {});

-- the current logged in user's root bag object. of type Map3DSystem.App.Inventory.Bag
Map3DSystem.App.Inventory.UserBag = nil;

-- display the main inventory window for the current user.
function Map3DSystem.App.Inventory.ShowMyInventory(_app)
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _wnd = _app:FindWindow("InventoryWnd") or _app:RegisterWindow("InventoryWnd", nil, Map3DSystem.App.Inventory.InventoryWnd.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
	
	if(frame ~= nil) then
		frame:Show2(bShow);
		return;
	end
	
	local sampleWindowsParam = {
		wnd = _wnd, -- a CommonCtrl.os.window object
		
		isShowTitleBar = true, -- default show title bar
		isShowToolboxBar = false, -- default hide title bar
		isShowStatusBar = false, -- default show status bar
		
		alignment = "Free", 
		
		isFastRender = true,
		
		icon = "Texture/3DMapSystem/Inventory/Inventory_32.png",
		text = "背包",
		
		style = CommonCtrl.WindowFrame.DefaultStyle,
		
		maximumSizeX = 400,
		maximumSizeY = 400,
		minimumSizeX = 400,
		minimumSizeY = 400,
		isShowIcon = true,
		--opacity = 100, -- [0, 100]
		isShowMaximizeBox = false,
		isShowMinimizeBox = false,
		isShowCloseBox = false,
		allowDrag = true,
		allowResize = false,
		initialPosX = 670,
		initialPosY = 300,
		initialWidth = 320, -- 320+9
		initialHeight = 256, -- 256+24+25
		
		ShowUICallback =Map3DSystem.App.Inventory.InventoryWnd.Show,
	};
	
	frame = CommonCtrl.WindowFrame:new2(sampleWindowsParam);
	frame:Show2(bShow);
	
	
	local _wnd = _app:FindWindow("InventoryWndMini") or _app:RegisterWindow("InventoryWndMini", nil, Map3DSystem.App.Inventory.InventoryWnd.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
	
	if(frame ~= nil) then
		frame:Show2(bShow);
		return;
	end
	
	local sampleWindowsParam = {
		wnd = _wnd, -- a CommonCtrl.os.window object
		
		isShowTitleBar = true, -- default show title bar
		isShowToolboxBar = false, -- default hide title bar
		isShowStatusBar = false, -- default show status bar
		
		alignment = "Free", 
		
		isFastRender = true,
		
		icon = "Texture/3DMapSystem/Inventory/Inventory_32.png",
		text = "Mini背包",
		
		style = CommonCtrl.WindowFrame.DefaultStyle,
		
		maximumSizeX = 400,
		maximumSizeY = 400,
		minimumSizeX = 400,
		minimumSizeY = 400,
		isShowIcon = true,
		--opacity = 100, -- [0, 100]
		isShowMaximizeBox = false,
		isShowMinimizeBox = false,
		isShowCloseBox = false,
		allowDrag = true,
		allowResize = false,
		initialPosX = 30,
		initialPosY = 300,
		initialWidth = 192, 
		initialHeight = 256, 
		
		ShowUICallback = Map3DSystem.App.Inventory.InventoryWnd.ShowTestMini,
	};
	
	frame = CommonCtrl.WindowFrame:new2(sampleWindowsParam);
	frame:Show2(bShow);
end

-- get the current user bag and retrieve data
-- the user bag contains local, profile, and app inventory data. 
function Map3DSystem.App.Inventory.GetCurrentUserRootBag()
	local bag = Map3DSystem.App.Inventory.UserBag;
	if(bag == nil) then
		-- init the user bag if we have not done so. 
		bag = Map3DSystem.App.Inventory.Bag:new({})
		Map3DSystem.App.Inventory.UserBag = bag;
		bag.objects = {};
		
		-- TODO: remove this test data
		--bag.objects[1] = Map3DSystem.App.Command:new({name = "1", ButtonText = "物品1", IsTradable = nil, icon=nil});
		--bag.objects[2] = Map3DSystem.App.Command:new({name = "2", ButtonText = "物品2", IsTradable = nil, icon=nil});
		--bag.objects[3] = Map3DSystem.App.Command:new({name = "3", ButtonText = "物品3", IsTradable = nil, icon=nil});
		
		-- TODO: add local items that are on the disk of local computer.
		-- TODO: update the BagCtl gridview on add object into bag
		bag:AddObject({name = "1", ButtonText = "物品1", IsTradable = nil, icon = "Texture/3DMapSystem/Inventory/TempIcons/Block.png"});
		bag:AddObject({name = "2", ButtonText = "物品2", IsTradable = nil, icon = "Texture/3DMapSystem/Inventory/TempIcons/Golf.png"});
		bag:AddObject({name = "3", ButtonText = "物品3", IsTradable = nil, icon = "Texture/3DMapSystem/Inventory/TempIcons/Mushroombaby.png"});
		-- TODO: add profile based items. 
		-- TODO: add inventory app based items: if any 
	end
	return bag;
end

function Map3DSystem.App.Inventory.GetTestMiniBag()
	local bag = Map3DSystem.App.Inventory.TestMiniBag;
	if(bag == nil) then
		-- init the user bag if we have not done so. 
		bag = Map3DSystem.App.Inventory.Bag:new({})
		Map3DSystem.App.Inventory.TestMiniBag = bag;
		bag.objects = {};
		
		-- TODO: remove this test data
		--bag.objects[1] = Map3DSystem.App.Command:new({name = "1", ButtonText = "物品1", IsTradable = nil, icon=nil});
		--bag.objects[2] = Map3DSystem.App.Command:new({name = "2", ButtonText = "物品2", IsTradable = nil, icon=nil});
		--bag.objects[3] = Map3DSystem.App.Command:new({name = "3", ButtonText = "物品3", IsTradable = nil, icon=nil});
		
		-- TODO: add local items that are on the disk of local computer.
		-- TODO: update the BagCtl gridview on add object into bag
		bag:AddObject({name = "6", ButtonText = "物品1", IsTradable = nil, icon = "Texture/3DMapSystem/Inventory/TempIcons/Notebook.png"});
		bag:AddObject({name = "7", ButtonText = "物品2", IsTradable = nil, icon = "Texture/3DMapSystem/Inventory/TempIcons/Pants.png"});
		bag:AddObject({name = "8", ButtonText = "物品3", IsTradable = nil, icon = "Texture/3DMapSystem/Inventory/TempIcons/Shirt.png"});
		-- TODO: add profile based items. 
		-- TODO: add inventory app based items: if any 
	end
	return bag;
end

--NOTE: InventoryWnd or Map3DSystem.App.Inventory.InventoryWnd is the rootbag of a user
--		
-- @param bShow: boolean to show or hide. if nil, it will toggle current setting.
-- @param _parent: parent window inside which the content is displayed. it can be nil.
function Map3DSystem.App.Inventory.InventoryWnd.Show(bShow, _parent, parentWindow)
	local _this;
	Map3DSystem.App.Inventory.InventoryWnd.parentWindow = parentWindow;
	
	_this = ParaUI.GetUIObject("InventoryWnd_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		if(_parent == nil) then
			_this = ParaUI.CreateUIObject("container", "InventoryWnd_cont", "_lt", 0, 50, 150, 300);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", "InventoryWnd_cont", "_lt", 0, 0, 320, 256);
			_this.background = ""
			_parent:AddChild(_this);
		end	
		_parent = _this;
		
		local ctl = Map3DSystem.App.Inventory.BagCtl:new{
			name = "CurrentUserRootBagCtl",
			left = 0,
			top = 0,
			
			slotBG = "Texture/3DMapSystem/Inventory/SlotBG.png",
			highLightBG = "",
			
			type = nil,
			rows = 4,
			columns = 5,
			itemwidth = 64,
			itemheight = 64,
			parent = _parent,
			
			bag = Map3DSystem.App.Inventory.GetCurrentUserRootBag(),
		};
		ctl:Show();
		
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		
		_parent = _this;
	end	
	if(bShow) then
	else	
	end
end

-- show mini bag
function Map3DSystem.App.Inventory.InventoryWnd.ShowTestMini(bShow, _parent, parentWindow)
	local _this;
	Map3DSystem.App.Inventory.InventoryWnd.parentWindow = parentWindow;
	
	_this = ParaUI.GetUIObject("InventoryWndMini_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		if(_parent == nil) then
			_this = ParaUI.CreateUIObject("container", "InventoryWndMini_cont", "_lt", 0, 50, 150, 300);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", "InventoryWndMini_cont", "_lt", 0, 0, 320, 256);
			_this.background = ""
			_parent:AddChild(_this);
		end	
		_parent = _this;
		
		local ctl = Map3DSystem.App.Inventory.BagCtl:new{
			name = "TestMiniBagCtl",
			left = 0,
			top = 0,
			
			slotBG = "Texture/3DMapSystem/Inventory/SlotBG.png",
			highLightBG = "",
			
			type = nil,
			rows = 4,
			columns = 3,
			itemwidth = 64,
			itemheight = 64,
			parent = _parent,
			
			bag = Map3DSystem.App.Inventory.GetTestMiniBag(),
		};
		ctl:Show();
		
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		
		_parent = _this;
	end	
	if(bShow) then
	else	
	end
end

function Map3DSystem.App.Inventory.InventoryWnd.MSGProc(window, msg)
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		Map3DSystem.UI.Windows.ShowWindow(false, Map3DSystem.App.Inventory.InventoryWnd.parentWindow.app.name, msg.wndName);
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end