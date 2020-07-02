--[[
Title: a bag contains stuffs of a person, a bag may contain other bags of the same person.
Author(s): LiXizhi, WangTian
Date: 2008/1/16
Desc: the bag concept is similar to folder in windows. We can exchange items between bags of the same persons, different persons, a shop and a person. 
We can also link a character with a given bag for the character to sell goods while the user is offline. 

NOTE: implemented by WangTian, the bag control is a universal item container. The control displays in grid view and 
	almost all the items allows drag and drop. According to develop note 2008/1/17, drag and drop between different bags 
	works in different dragging behaviors.

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Inventory/BagCtl.lua");
local ctl = Map3DSystem.App.Inventory.BagCtl:new{
	name = "BagCtl1",
	alignment = "_lt",
	left=0, top=0,
	width = 512,
	height = 290,
	parent = nil,
};
ctl:Show();
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-----------------------------------------------------
-- bag object 
-----------------------------------------------------

-- bag status. 
Map3DSystem.App.Inventory.BagStatus = {
	-- unsynchronized
	LocalBag = nil,
	Unsynchronized = 1,
	Synchronized = 2,
};

-- how items in a bag should be drawn
Map3DSystem.App.Inventory.BagDisplayOption = {
	GridIconOnly = nil, 
	GridIconText = 1,
	ListIconText = 2,
};

-- how items in a bag should be drawn
Map3DSystem.App.Inventory.BagType = {
	-- the bag is the root bag of a given user
	RootBag = nil, 
	-- give box: objects in the bag are given to the current user free of charge, 
	-- either because of the user just make them, obtained as trophy, or received as gifts from feeds. 
	GiveBox = 1,
	-- all objects in the bag are for sale. Most marcket pages in application home page uses OnSaleBag to sell products to visitors. 
	-- personal users can also link sub bags to some of their virtual characters to let them sell their own products to other visitors. 
	OnSaleBag = 2,
};

-- NOTE: revised by WangTian
-- how items in a bag should be drawn
Map3DSystem.App.Inventory.BagType = {
	-- the bag is the root bag of a given user
	RootBag = 1, 
	-- the bag is the sub bag of a root bag
	MiniBag = 2, 
	-- give box: objects in the bag are given to the current user free of charge, 
	-- either because of the user just make them, obtained as trophy, or received as gifts from feeds. 
	GiveBox = 3,
	-- all objects in the bag are for sale. Most marcket pages in application home page uses OnSaleBag to sell products to visitors. 
	-- personal users can also link sub bags to some of their virtual characters to let them sell their own products to other visitors. 
	OnSaleBag = 4,
	-- exchange bag: objects in the bag are for exchange purpose, ExchangeBagSelf shows the objects user want to exchange,
	-- and ExchangeBagOpponent shows the opponent objects exchange back
	ExchangeBagSelf = 5,
	ExchangeBagOpponent = 6,
};


-- a single bag template containing stuffs of a person, a bag may contain other bags of the same person. 
-- the bag concept is similar to folder in windows. We can exchange items between bags. 
Map3DSystem.App.Inventory.Bag = {
	-- the bag id in the server's bag database. If this is a locally created bag, id is nil. 
	id = nil, 
	-- the user_id of this bag's owner, if nil it means local or the current user.  
	owner_id = nil,
	-- name of this bag, like folder name. 
	name = nil,
	-- display name of the bag
	text = nil,
	-- E price and P price. only for display purposes, if the bag carries some money.  
	priceE = nil,
	priceP = nil,
	-- array {} of tradable item commands (some commands will open other bag objects)
	objects = nil,
	-- capacity of the bag
	capacity = 49,
	-- bag type of Map3DSystem.App.Inventory.BagType
	BagType = nil,
	-------------------------------------------
	-- appearances
	-------------------------------------------
	-- how many rows and columns of the bag
	col = 7,
	row = 7,
	-- which page to display, starting from 1
	pageNo = nil,
	-- display option of type Map3DSystem.App.Inventory.BagDisplayOption
	DisplayOption = nil,
	-- a filter function(item) return true; end, that will return true if the given item in bag should be shown,
	-- we can use it to display only a subset of items in the bag. 
	FilterFunc = nil,
	-- status of this bag. current it is not USED.
	status = nil,
};

-- a list of active bags in the scene.
Map3DSystem.App.Inventory.Bags = {};

-- create a new bom
function Map3DSystem.App.Inventory.Bag:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	if(o.objects == nil) then
		o.objects = {};
	end
	return o	
end

-- clear all objects
function Map3DSystem.App.Inventory.Bag:ClearAll()
	self.objects = nil;
	self.priceE = nil;
	self.priceP = nil;
end

-- add a new object to the bag. One need to call manually update the UI of the bag. 
-- it may return nil if bag is full. otherwise return true. 
function Map3DSystem.App.Inventory.Bag:AddObject(obj)
	self.objects = self.objects or {};
	if(table.getn(self.objects) < self.capacity) then
		self.objects[table.getn(self.objects)+1] = obj;
		return true;
	end	
end

-----------------------------------------------------
-- bag control for displaying a bag object
-----------------------------------------------------

-- default member attributes
local BagCtl = {
	-- the top level control name
	name = "BagCtl1",
	-- normal window size
	--alignment = "_lt", -- NOTE: bag control don't suggest "_fi" alignment
	left = 0,
	top = 0,
	--width = 300,
	--height = 290, 
	parent = nil,
	-- UI backgrounds
	slotBG = "",
	highLightBG = "",
	-- bag information
	type = nil, --  of type: Map3DSystem.App.Inventory.BagType
	rows = 8,
	columns = 6,
	slotwidth = 64,
	slotheight = 64,
	itemwidth = 48,
	itemheight = 48,
	itemXoffset = 8,
	itemYoffset = 8,
	-- the Map3DSystem.App.Inventory.InventoryWnd.Bag object that this control is bound to.
	bag = nil,
}
Map3DSystem.App.Inventory.BagCtl = BagCtl;

-- record all bag control names, mainly for bag items drag
-- drag receiver UI container in the AllBagCtlNames table will be added on drag begin
BagCtl.AllBagCtlNames = {};

-- constructor
function BagCtl:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	CommonCtrl.AddControl(o.name, o);
	
	table.insert(BagCtl.AllBagCtlNames, o.name);
	
	return o;
end

-- Destroy the UI control
function BagCtl:Destroy()
	-- TODO: untested
	local i, v;
	for i, v in ipairs(BagCtl.AllBagCtlNames) do
		if(v == self.name) then
			break;
		end
	end
	table.remove(BagCtl.AllBagCtlNames, i);
	
	ParaUI.Destroy(self.name.."_Bag");
end

function BagCtl.RandomIcon()
	-- randomly generated icon
	local index = math.random(1, 3);
	local tempicons = {
		[1] = "Texture/3DMapSystem/Inventory/TempIcons/Icon1.png; 0 0 48 48",
		[2] = "Texture/3DMapSystem/Inventory/TempIcons/Icon2.png; 0 0 48 48",
		[3] = "Texture/3DMapSystem/Inventory/TempIcons/Icon3.png; 0 0 48 48",
	};
	
	return tempicons[index];
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function BagCtl:Show(bShow)
	local _this,_parent;
	if(self.name == nil)then
		log("BagCtl instance name can not be nil\r\n");
		return
	end
	
	_this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		local width = self.slotwidth * self.columns;
		local height = self.slotheight * self.rows;
		
		_this = ParaUI.CreateUIObject("container", self.name.."_Bag", "_lt", self.left, self.top, width, height);
		_parent = _this;
		
		if(self.parent == nil) then
			_this:AttachToRoot();
		else
			_this.background = "";
			self.parent:AddChild(_this);
		end
		
		NPL.load("(gl)script/ide/GridView.lua");
		local ctl = CommonCtrl.GridView:new{
			name = self.name.."_BagGrid",
			alignment = "_lt",
			left = 0,
			top = 0,
			width = width,
			height = height,
			cellWidth = self.slotwidth,
			cellHeight = self.slotheight,
			parent = _parent,
			columns = self.columns,
			rows = self.rows,
			DrawCellHandler = BagCtl.DrawCellHandler,
			
			fastrender = true,
			
			bagCtl = self,
			};
		
		--local i;
		--for i = 1, table.getn(self.bag.objects) do
			--local icon = self.bag.objects.icon;
			--local name = self.bag.objects.name;
			--
			--local cell = CommonCtrl.GridCell:new{
				--GridView = nil,
				--name = name,
				--text = name,
				--column = 1,
				--row = 1,
				--empty = false,
				--icon = BagCtl.RandomIcon(), -- TODO: currently randomly generated icon
				--};
			--
			--ctl:InsertCell(cell, "Right");
		--end
		
		-- traverse through the bag control to initiate the bag control
		local i, j;
		for i = 1, self.rows do
			for j = 1, self.columns do
				local object = self.bag.objects[(i - 1) * self.rows + j];
				if(object ~= nil) then
					-- fill with bag item
					local cell = CommonCtrl.GridCell:new{
						GridView = nil,
						name = i.."-"..j,
						text = i.."-"..j,
						column = j,
						row = i,
						isEmpty = false,
						bagObjectIndex = (i - 1) * self.columns + j,
						icon = object.icon,
						};
					ctl:InsertCell(cell, "Right");
				else
					-- empty cell
					local cell = CommonCtrl.GridCell:new{
						GridView = nil,
						name = i.."-"..j,
						text = i.."-"..j,
						column = j,
						row = i,
						isEmpty = true,
						bagObjectIndex = (i - 1) * self.columns + j,
						icon = nil,
						};
					
					ctl:InsertCell(cell, "Right");
				end
			end
		end
	
		ctl:Show();
		
		self.GridView = ctl;
		
		-- container visible at drag begin and invisible at drag end
		-- drag reciever is a proxy container catching the bag item UI object at the end of the dragging process
		-- which provides bag item transfer between bag controls
		local recv = ParaUI.CreateUIObject("container", self.name.."_BagGrid_DragReceiver", "_fi", 0,0,0,0);
		
		recv.background = ""; -- DEBUG purpose
		
		recv.visible = false;
		_parent:AddChild(recv);
		
		-- NOTE: this button will be RemoveAll() during the draging process
		--local recvBtn = ParaUI.CreateUIObject("button", self.name.."_BagGrid_DragReceiver_Btn", "_fi", 0,0,0,0);
		----_this.background = "";
		--recv:AddChild(recvBtn);
		
		--NPL.load("(gl)script/ide/TreeView.lua");
		--local ctl = CommonCtrl.TreeView:new{
			--name = self.name.."TreeViewObjList",
			--alignment = "_fi",
			--left = 3,
			--top = 39,
			--width = 3,
			--height = 46,
			--parent = _parent,
			--DefaultIndentation = 5,
			--DefaultNodeHeight = 24,
			--container_bg = "Texture/3DMapSystem/ContextMenu/BG2.png:8 8 8 8",
			--onclick = Map3DSystem.App.Inventory.BagCtl.OnClickItemNode,
			--bag = self.bag,
		--};
		--self:FillTreeView(ctl);
		--ctl:Show(true);
		
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
	end	
end

-- make a button inventory slot style
-- @param uiobject: button UI object
-- @param backgroundImage: background image always shows on slot
-- @param highlightImage: highlight image shows only on mouse over indicating available slot for item 
--			or item outer glow highlight
function BagCtl.SetSlotStyleButton(uiobject, backgroundImage, highlightImage)
	if(uiobject~=nil and uiobject:IsValid())then
		local texture;
		
		if(backgroundImage ~= nil) then
			uiobject:SetActiveLayer("background");
			uiobject.background = backgroundImage; 
			
			uiobject:SetCurrentState("highlight");
			uiobject.color="255 255 255";
			uiobject:SetCurrentState("pressed");
			uiobject.color="255 255 255";
			uiobject:SetCurrentState("disabled");
			uiobject.color="255 255 255 100";
			uiobject:SetCurrentState("normal");
			uiobject.color="255 255 255";
			
			uiobject:SetActiveLayer("artwork");
		end
		
		if(highlightImage ~= nil) then
			uiobject:SetActiveLayer("artwork");
			uiobject.background = highlightImage; 
			
			uiobject:SetCurrentState("highlight");
			uiobject.color="255 255 255 200";
			uiobject:SetCurrentState("pressed");
			uiobject.color="255 255 255 255";
			uiobject:SetCurrentState("normal");
			uiobject.color="0 0 0 0";
			uiobject:SetCurrentState("disabled");
			uiobject.color="0 0 0 0";
		end
	end
end

-- draw cell according to bag gridcell, if item cell draw, draw item with slot. 
-- if empty cell, draw only empty slot
function BagCtl.DrawCellHandler(_parent, gridcell)
	if(_parent == nil or gridcell == nil) then
		return;
	end
	
	if(gridcell ~= nil) then
		
		local bagCtl = gridcell.GridView.bagCtl;
		local width = gridcell.GridView.cellWidth;
		local height = gridcell.GridView.cellHeight;
		
		-- background slot
		local _this = ParaUI.CreateUIObject("button", "slot", "_fi", 0,0,0,0);
		BagCtl.SetSlotStyleButton(_this, "Texture/3DMapSystem/Inventory/SlotBG.png", 
			"Texture/3DMapSystem/Inventory/HighLight2.png");
		_parent:AddChild(_this);
		
		if(gridcell.isEmpty == false) then
			-- item cell
			_this = ParaUI.CreateUIObject("button", "item", "_fi", 8,8,8,8);
			_this.background = gridcell.icon;
			_this.candrag = true;
			_this.onclick = string.format([[;Map3DSystem.App.Inventory.BagCtl.OnClick("%s", %d);]], bagCtl.name, gridcell.bagObjectIndex);
			_this.ondragbegin = string.format([[;Map3DSystem.App.Inventory.BagCtl.OnDragBegin("%s", %d);]], bagCtl.name, gridcell.bagObjectIndex);
			_this.ondragmove = string.format([[;Map3DSystem.App.Inventory.BagCtl.OnDragMove("%s", %d);]], bagCtl.name, gridcell.bagObjectIndex);
			_this.ondragend = string.format([[;Map3DSystem.App.Inventory.BagCtl.OnDragEnd("%s", %d);]], bagCtl.name, gridcell.bagObjectIndex);
			_parent:AddChild(_this);
		else
			-- empty cell
			_this = ParaUI.CreateUIObject("button", "empty", "_fi", 8,8,8,8);
			_this.onclick = string.format([[;Map3DSystem.App.Inventory.BagCtl.OnClick("%s", %d);]], bagCtl.name, gridcell.bagObjectIndex);
			_this.background = "";
			_this.candrag = false;
			_parent:AddChild(_this);
		end
	end
end

function BagCtl:GetItemUIParentByIndex(bagItemIndex)
	local gridViewName = self.name.."_BagGrid";
	local gridView = CommonCtrl.GetControl(gridViewName);
	return gridView:GetCellUIParentByIndex(bagItemIndex);
end

function BagCtl:GetItemUIParentByRowAndColumn(bagItemRow, bagItemColumn)
	local gridViewName = self.name.."_BagGrid";
	local gridView = CommonCtrl.GetControl(gridViewName);
	return gridView:GetCellUIParentByIndex(bagItemIndex);
end


------------------------ DEBUG PURPOSE ------------------------
function BagCtl.OnFakeMouseMove()
	
	--local BagCtl = Map3DSystem.App.Inventory.BagCtl;
	if(BagCtl.isClickDrag == true
		and BagCtl.CurrentClickDragItemBagName ~= nil
		and BagCtl.CurrentClickDragItemBagObjectIndex ~= nil) then
		-- get the click dragging UI object
		local bagName = BagCtl.CurrentClickDragItemBagName;
		local bagObjectIndex = BagCtl.CurrentClickDragItemBagObjectIndex;
		local offsetX = BagCtl.CurrentClickDragItemUIOffsetX;
		local offsetY = BagCtl.CurrentClickDragItemUIOffsetY;
		
		local bagCtl = CommonCtrl.GetControl(bagName);
		local _cellParent = bagCtl:GetItemUIParentByIndex(bagObjectIndex);
		if(_cellParent:IsValid() == true) then
			local _item = _cellParent:GetChild("item");
			local x, y, width, height = _item:GetAbsPosition();
			local mouseX, mouseY = ParaUI.GetMousePosition();
			_item.translationx = mouseX - (x + offsetX);
			_item.translationy = mouseY - (y + offsetY);
			_cellParent:BringToFront();
			local _ui = _cellParent;
			while(_ui.parent.name ~= "__root") do
				_ui = _ui.parent;
			end
			_ui:BringToFront();
		end
	end
end

function BagCtl.StartFakeMouseMoveTimer()
	NPL.load("(gl)script/ide/timer.lua");
	BagCtl.timer = BagCtl.timer or commonlib.Timer:new({callbackFunc = BagCtl.OnFakeMouseMove});
	BagCtl.timer:Change(100, 100);
end

BagCtl.StartFakeMouseMoveTimer();

function BagCtl.SceneClickDuringClickDrag()
	-- TODO: destroy item
	_guihelper.MessageBox("Do you want to destroy this object?");
end

function BagCtl.SceneDropDuringClickDrag()
	-- TODO: destroy item
	_guihelper.MessageBox("Do you want to destroy this object?");
end

------------------------ DEBUG PURPOSE ------------------------


-- onclick bagctl object will grab the object beneath the mouse cursor
-- the object then become a floating object on screen waiting for the drop operation(left click),
-- or the cancel operation(right click)
function BagCtl.OnClick(bagName, bagObjectIndex)
	local bagCtl = CommonCtrl.GetControl(bagName);
	
	local bagObject = bagCtl.bag.objects[bagObjectIndex];
	
	--BagCtl.isClickDrag;
	--BagCtl.isHoldDrag;
	--BagCtl.CurrentClickDragItemBagObjectIndex;
	--BagCtl.CurrentClickDragItemBagName;
	
	if(bagObject == nil) then
		-- empty cell
		if(BagCtl.isClickDrag ~= true
			and BagCtl.CurrentClickDragItemBagObjectIndex == nil
			and BagCtl.CurrentClickDragItemBagName == nil) then
			-- no action
		else
			-- finish click drag
			BagCtl.SwapObject(BagCtl.CurrentClickDragItemBagName, 
					BagCtl.CurrentClickDragItemBagObjectIndex, 
					bagName, 
					bagObjectIndex);
			BagCtl.isClickDrag = false;
			BagCtl.CurrentClickDragItemBagName = nil;
			BagCtl.CurrentClickDragItemBagObjectIndex = nil;
		end
	else
		-- bag item
		if(BagCtl.isClickDrag ~= true
			and BagCtl.CurrentClickDragItemBagObjectIndex == nil
			and BagCtl.CurrentClickDragItemBagName == nil) then
			-- begin click drag
			BagCtl.isClickDrag = true;
			BagCtl.CurrentClickDragItemBagName = bagName;
			BagCtl.CurrentClickDragItemBagObjectIndex = bagObjectIndex;
			local x, y = ParaUI.GetMousePosition();
			local _temp = ParaUI.GetUIObjectAtPoint(x, y);
			if(_temp:IsValid() == true) then
				
				local abs_x, abs_y = _temp:GetAbsPosition();
				local r_x, r_y = x - abs_x, y - abs_y;
				BagCtl.CurrentClickDragItemUIOffsetX = r_x;
				BagCtl.CurrentClickDragItemUIOffsetY = r_y;
			end
		else
			-- swap this item with current click drag item
			BagCtl.SwapObject(BagCtl.CurrentClickDragItemBagName, 
					BagCtl.CurrentClickDragItemBagObjectIndex, 
					bagName, 
					bagObjectIndex);
			if(BagCtl.CurrentClickDragItemBagName == bagName 
				and BagCtl.CurrentClickDragItemBagObjectIndex == bagObjectIndex) then
				BagCtl.isClickDrag = false;
				BagCtl.CurrentClickDragItemBagName = nil;
				BagCtl.CurrentClickDragItemBagObjectIndex = nil;
			end
		end
	end
	
	----bagCtl.name, gridcell.bagObjectIndex
	--
	--local cellParent = bagCtl:GetItemUIParentByIndex(bagObjectIndex);
	--if(cellParent:IsValid() == true) then
		----local root = ParaUI.GetUIObject("root");
		--local x, y, width, height = cellParent:GetAbsPosition();
		--local mouseX, mouseY = ParaUI.GetMousePosition();
		--
		---- track the 
		--
		----------------------------------------------------------
		---- Note by WangTian 2008-1-31. 
		---- I try to hook the "mouse_move" window in "input" application, but I found that
		---- the mouse position changes only on mouse click and only hooks when mouse over the "root" UI object
		----------------------------------------------------------
		--
		---- hook into the "mouse_move" window in "input" application, and detect the mouse to 
		---- translate the object icon position
		--CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC, 
			--callback = function(nCode, appName, msg)
				---- return the nCode to be passed to the next hook procedure in the hook chain. 
				---- in most cases, if nCode is nil, the hook procedure should do nothing. 
				--if(nCode == nil) then return end
				---- TODO: do your code here
				--_guihelper.MessageBox("mouse position: "..msg.mouse_x.." "..msg.mouse_y.."\n");
				--return nCode;
			--end, 
			--hookName = "BagObjectMoveHook", appName = "input", wndName = "mouse_move"});
		--
		---- unhook 
		----CommonCtrl.os.hook.UnhookWindowsHook({hookName = "BagObjectMoveHook", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC})
		--
	--end
end

-- envisible the drag receiver, currently envisible all BagCtl drag receiver to allow receiving item drag
function BagCtl.OnDragBegin(bagName, bagObjectIndex)
	local i, v;
	for i, v in ipairs(BagCtl.AllBagCtlNames) do
		local recv = ParaUI.GetUIObject(v.."_BagGrid_DragReceiver");
		if(recv:IsValid() == true) then
			recv.visible = true;
			ParaUI.AddDragReceiver(v.."_BagGrid_DragReceiver");
		end
	end
	
	ParaUI.AddDragReceiver("root");
	
	if(BagCtl.isClickDrag == true) then
		BagCtl.OnClick(bagName, bagObjectIndex);
		BagCtl.isClickDrag = false;
		BagCtl.CurrentClickDragItemBagName = nil;
		BagCtl.CurrentClickDragItemBagObjectIndex = nil;
	end
	
	BagCtl.isHoldDrag = true;
	BagCtl.CurrentHoldDragItemBagName = bagName;
	BagCtl.CurrentHoldDragItemBagObjectIndex = bagObjectIndex;
end

function BagCtl.OnDragMove(bagName, bagObjectIndex)
end

function BagCtl.OnDragEnd(bagName, bagObjectIndex)
	
	-- TODO: continue with the drag process
	
	local x, y = ParaUI.GetMousePosition();
	local temp = ParaUI.GetUIObjectAtPoint(x, y);
	
	if(temp.name == "item" and temp.parent.name == "__root") then
		-- TODO: remove UI object from the root 
		temp.parent.Remove("item");
		BagCtl.SceneDropDuringClickDrag();
		local bag = CommonCtrl.GetControl(bagName);
		if(bag ~= nil) then
			local bagGrid = CommonCtrl.GetControl(bagName.."_BagGrid");
			bagGrid:Update();
		end
		BagCtl.OnClick(bagName, bagObjectIndex);
	end
	
	-- invisible the drag receiver, currently invisible all BagCtl drag receiver 
	--	to deny receiveing item drag
	local i, v;
	for i, v in ipairs(BagCtl.AllBagCtlNames) do
		local recv = ParaUI.GetUIObject(v.."_BagGrid_DragReceiver");
		if(recv:IsValid() == true) then
			recv.visible = false;
			recv:RemoveAll();
		end
	end
	
	if(temp:IsValid() == true) then
		local parentName = temp.parent.name;
		local index = string.find(parentName, "_BagGrid_DragReceiver");
		if(index ~= nil) then
			local recvBagName = string.sub(parentName, 1, index - 1);
			local ctl = CommonCtrl.GetControl(recvBagName.."_BagGrid");
			local cell = ctl:GetCellByCursor();
			
			-- cell tranfer
			BagCtl.SwapObject(bagName, 
			--BagCtl.MoveObject(bagName, 
					bagObjectIndex, 
					recvBagName, 
					ctl:RowAndColumnToIndex(cell.row, cell.column));
			BagCtl.OnClick(BagCtl.CurrentHoldDragItemBagName, BagCtl.CurrentHoldDragItemBagObjectIndex);
			
			BagCtl.isHoldDrag = false;
			BagCtl.CurrentHoldDragItemBagName = nil;
			BagCtl.CurrentHoldDragItemBagObjectIndex = nil;
		end
	end
end

-- move one item from the source bag to the destination bag
-- positions are indicated by bag index
function BagCtl.MoveObject(srcBagName, srcBagObjectIndex, destBagName, destBagObjectIndex)
	
	log("MoveObject:"..srcBagName.." "..srcBagObjectIndex.." "..destBagName.." "..destBagObjectIndex.."\n");
	
	local srcBag = CommonCtrl.GetControl(srcBagName);
	local destBag = CommonCtrl.GetControl(destBagName);
	if(srcBag ~= nil and destBag ~= nil) then
		if(srcBagName == destBagName and srcBagObjectIndex == destBagObjectIndex) then
			-- the same source and dest bag and object index
			local srcGrid = CommonCtrl.GetControl(srcBagName.."_BagGrid");
			srcGrid:Update();
			return;
		end
		
		-- move the bag item
		local bagItem = srcBag.bag.objects[srcBagObjectIndex];
		destBag.bag.objects[destBagObjectIndex] = bagItem;
		srcBag.bag.objects[srcBagObjectIndex] = nil;
		
		-- move the grid cell
		local srcGrid = CommonCtrl.GetControl(srcBagName.."_BagGrid");
		local destGrid = CommonCtrl.GetControl(destBagName.."_BagGrid");
		local srcCell = srcGrid:GetCellByIndex(srcBagObjectIndex);
		local destCell = destGrid:GetCellByIndex(destBagObjectIndex);
		
		-- move the cell information
		destCell.isEmpty = false;
		destCell.bagObjectIndex = destBagObjectIndex;
		destCell.icon = srcCell.icon;
		srcCell.isEmpty = true;
		srcCell.bagObjectIndex = srcBagObjectIndex;
		srcCell.icon = "";
		
		-- update the UI on both source and destination gridview
		srcGrid:Update();
		destGrid:Update();
	end
end

-- swap between the source bag item and the destination bag item
-- both positions are indicated by bag index
function BagCtl.SwapObject(srcBagName, srcBagObjectIndex, destBagName, destBagObjectIndex)
	
	log("SwapObject:"..srcBagName.." "..srcBagObjectIndex.." "..destBagName.." "..destBagObjectIndex.."\n");
	
	local srcBag = CommonCtrl.GetControl(srcBagName);
	local destBag = CommonCtrl.GetControl(destBagName);
	if(srcBag ~= nil and destBag ~= nil) then
		if(srcBagName == destBagName and srcBagObjectIndex == destBagObjectIndex) then
			-- the same source and dest bag and object index
			local srcGrid = CommonCtrl.GetControl(srcBagName.."_BagGrid");
			srcGrid:Update();
			return;
		end
		
		-- swap the bag items
		local bagItem = srcBag.bag.objects[srcBagObjectIndex];
		srcBag.bag.objects[srcBagObjectIndex] = destBag.bag.objects[destBagObjectIndex];
		destBag.bag.objects[destBagObjectIndex] = bagItem;
		
		-- swap the grid cell
		local srcGrid = CommonCtrl.GetControl(srcBagName.."_BagGrid");
		local destGrid = CommonCtrl.GetControl(destBagName.."_BagGrid");
		local srcCell = srcGrid:GetCellByIndex(srcBagObjectIndex);
		local destCell = destGrid:GetCellByIndex(destBagObjectIndex);
		
		-- swap the cell information
		local isEmpty = destCell.isEmpty;
		destCell.isEmpty = srcCell.isEmpty;
		srcCell.isEmpty = isEmpty;
		
		local icon = destCell.icon;
		destCell.icon = srcCell.icon;
		srcCell.icon = icon;
		
		destCell.bagObjectIndex = destBagObjectIndex;
		srcCell.bagObjectIndex = srcBagObjectIndex;
		
		-- update the UI on both source and destination gridview
		srcGrid:Update();
		destGrid:Update();
	end
end

-- close the given control
function BagCtl.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting BagCtl instance "..sCtrlName.."\r\n");
		return;
	end
	self.GridView = nil;
	ParaUI.Destroy(self.name);
end

-- clicked the tree node. 
function Map3DSystem.App.Inventory.BagCtl.OnClickItemNode(treeNode)
	
end

---- update treeview according to self.bag data, call ctl:Update(); later to update UI. 
--function BagCtl:FillTreeView(ctl)
	--if(ctl~=nil and self.bag~=nil) then
		--local node = ctl.RootNode;
		--
		---- clear and refill data
		--node:ClearAllChildren();
		--
		--local index, obj;
		--for index, obj in ipairs(self.bag.objects) do
			--if(self.bag.FilterFunc~=nil and not self.bag.FilterFunc(obj)) then
				---- filter item. 
			--else
				--node:AddChild( CommonCtrl.TreeNode:new({Name = obj.name, Text = obj.ButtonText, Icon = obj.icon, IsTradable = true}) );	
			--end
		--end
	--end	
--end
--