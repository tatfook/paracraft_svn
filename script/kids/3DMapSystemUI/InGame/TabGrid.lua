--[[
Title: Tab Grid control for all CCS and creation
		with two level categories
Author(s): WangTian
Date: 2008/5/19
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/TabGrid.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

if(not Map3DSystem.UI.TabGrid) then Map3DSystem.UI.TabGrid = {}; end

local TabGrid = Map3DSystem.UI.TabGrid;

local sampleParam = {
	
	name = "sampleTabGrid",
	parent = nil,
	background = nil,
	wnd = nil,
	
	zorder = 0,
	
	----------- CATEGORY REGION -----------
	-- Category region is two middle alignment container to the border
	-- These containers work like tab view selecting which category items to show
	Level1 = "Left", -- Left|Right|Top|Bottom, if nil on Level1 information
	Level1BG = "", -- background
	Level1HeadBG = "", -- background between top/left border and the first item
	Level1TailBG = "", -- background between the first item and buttom/right border
	Level1Offset = 10, -- offset of the level 1 category to the very edge of the grid view
	Level1ItemWidth = 48, -- width of level 1 item
	Level1ItemHeight = 48, -- height of level 1 item
	--Level1ItemGap = 8, -- gap between level1 items
	Level1ItemOwnerDraw = function(_parent, level1index, bSelected, tabGrid) end,
	
	--Level1ItemVistaStyle = nil, --  if 4 use _guihelper.SetVistaStyleButton4 to render the item
	
	Level2 = "Top", -- Left|Right|Top|Bottom, if nil on Level2 information
	Level2BG = "", -- background
	Level2HeadBG = "", -- background between top/left border and the first item
	Level2TailBG = "", -- background between the first item and buttom/right border
	Level2Offset = 10, -- offset of the level 2 category to the very edge of the grid view
	Level2ItemWidth = 32, -- width of level 1 item
	Level2ItemHeight = 48, -- height of level 1 item
	--Level2ItemGap = 8, -- gap between level2 items
	Level2ItemOwnerDraw = function(_parent, level2index, bSelected, tabGrid) end,
	
	----------- GRID REGION -----------
	-- Grid region is a gridview control showing the items in the specific category
	-- these four numbers indicating the align to left top and right bottom
	--		fill in the parent window like "_fi" alignment
	nGridBorderLeft = 10,
	nGridBorderTop = 10,
	nGridBorderRight = 10,
	nGridBorderBottom = 10,
	
	nGridCellWidth = 48, -- gridcell width
	nGridCellHeight = 48, -- gridcell height
	nGridCellGap = 8, -- gridview gap between cells
	
	----------- PAGE REGION -----------
	-- Page region has the same width as the gridview
	--		showing the pageleft and pageright button, and the page numbers "2/3"
	--		If no paging is avaiable, disable the page buttons and show "1/1"
	pageRegionHeight = 48,
	pageNumberWidth = 40,
	pageDefaultMargin = 16, --  the margin between the pageleft and page number(or the page number and the pageright)
	
	pageLeftImage = nil,
	pageLeftWidth = 32,
	pageLeftHeight = 32,
	
	pageRightImage = nil,
	pageRightWidth = 32,
	pageRightHeight = 32,
	
	isAlwaysShowPager = false,
	
	----------- FUNCTION REGION -----------
	GetLevel1ItemCount = function() end, --  get the count of the level1 category items
	GetLevel1ItemSelectedForeImage = function(index) end, -- get the selected foreground image of the indexed item
	GetLevel1ItemSelectedBackImage = function(index) end, -- get the selected foreground image of the indexed item
	GetLevel1ItemUnselectedForeImage = function(index) end, -- get the unselected foreground image of the indexed item
	GetLevel1ItemUnselectedBackImage = function(index) end, -- get the unselected foreground image of the indexed item
	GetLevel1ItemTooltip = function(index) end, --  get the tooltip of the item
	
	GetLevel2ItemCount = function(level1index) end, --  get the count of the level2 category items
	GetLevel2ItemSelectedForeImage = function(level1index, level2index) end, -- get the selected foreground image of the indexed item
	GetLevel2ItemSelectedBackImage = function(level1index, level2index) end, -- get the selected foreground image of the indexed item
	GetLevel2ItemUnselectedForeImage = function(level1index, level2index) end, -- get the unselected foreground image of the indexed item
	GetLevel2ItemUnselectedBackImage = function(level1index, level2index) end, -- get the unselected foreground image of the indexed item
	GetLevel2ItemTooltip = function(level1index, level2index) end, --  get the tooltip of the item
	
	GetGridItemCount = function(level1index, level2index) end, --  get the count of the grid category items
	
	isGridView3D = false, -- show the gridview in 3D mode
	
	GetGridItemEnabled = function(level1index, level2index, itemindex) end, -- get the foreground image of the grid item
	--if(isGridView3D == false) then
	GetGridItemForeImage = function(level1index, level2index, itemindex) end, -- get the foreground image of the grid item
	GetGridItemBackImage = function(level1index, level2index, itemindex) end, -- get the background image of the grid item
	--elseif(isGridView3D == true) then
	GetGrid3DItemModel = function(level1index, level2index, itemindex) end, -- get the object model of the grid3d item
	GetGrid3DItemSkin = function(level1index, level2index, itemindex) end, -- get the object texture of the grid3d item
	--end
	
	
	OnClickItem = function(level1index, level2index, itemindex) end, -- onclick callback on item click
};

function TabGrid:new(o)
	-- NOTE: omit the parameter check, assuming all the entries are available
	
	if(Level1 == Level2 and Level1 ~= nil) then
		log("error: TabGrid:new(): level1 and level2 have the same alignment.\n");
		return;
	end
	
	if(o.Level1HeadBG == nil) then
		o.Level1HeadBG = "";
	end
	if(o.Level1TailBG == nil) then
		o.Level1TailBG = "";
	end
	
	if(o.Level2HeadBG == nil) then
		o.Level2HeadBG = "";
	end
	if(o.Level2TailBG == nil) then
		o.Level2TailBG = "";
	end
	
	setmetatable(o, self);
	self.__index = self;
	
	CommonCtrl.AddControl(o.name, o);
	
	return o;
end

function TabGrid:Destroy()
	
	-- destroy the old control
	--if(CommonCtrl.GetControl(self.name.."_TabGrid_GridView") ~= nil) then
		--CommonCtrl.GetControl(self.name.."_TabGrid_GridView"):Destroy();
		--CommonCtrl.DeleteControl(self.name.."_TabGrid_GridView");
	--end
	CommonCtrl.DeleteControl(self.name.."_TabGrid_GridView");
	ParaUI.Destroy(self.name.."_TabGrid");
end

function TabGrid:Show(bShow)
	local _parent = self.parent;
	
	local _tabGrid = ParaUI.GetUIObject(self.name.."_TabGrid");
	if(_tabGrid:IsValid() == false) then
		if(bShow == false) then	
			return;
		end
		
		-- main container
		_tabGrid = ParaUI.CreateUIObject("container", self.name.."_TabGrid", "_fi", 0, 0, 0, 0);
		_tabGrid.background = self.background;
		_tabGrid.zorder = self.zorder or 0;
		if(self.parent ~= nil and self.parent:IsValid() == true) then
			self.parent:AddChild(_tabGrid);
		else
			_tabGrid:AttachToRoot();
		end
		
		local borderX, borderY, borderWidth, borderHeight = 0, 0, 0, 0;
		
		local _level1, _level1Head;
		if(self.Level1 ~= nil) then
			if(self.Level1 == "Left") then
				_level1Head = ParaUI.CreateUIObject("container", "Level1Head", "_lt", 
						0, 0, self.Level1ItemWidth, self.Level1Offset);
				_level1 = ParaUI.CreateUIObject("container", "Level1", "_ml", 
						0, self.Level1Offset, self.Level1ItemWidth, 0);
				borderX = borderX + self.Level1ItemWidth;
			elseif(self.Level1 == "Right") then
				_level1Head = ParaUI.CreateUIObject("container", "Level1Head", "_rt", 
						-self.Level1ItemWidth, 0, self.Level1ItemWidth, self.Level1Offset);
				_level1 = ParaUI.CreateUIObject("container", "Level1", "_mr", 
						0, self.Level1Offset, self.Level1ItemWidth, 0);
				borderWidth = borderWidth + self.Level1ItemWidth;
			elseif(self.Level1 == "Top") then
				_level1Head = ParaUI.CreateUIObject("container", "Level1Head", "_lt", 
						0, 0, self.Level1Offset, self.Level1ItemHeight);
				_level1 = ParaUI.CreateUIObject("container", "Level1", "_mt", 
						self.Level1Offset, 0, 0, self.Level1ItemHeight);
				borderY = borderY + self.Level1ItemHeight;
			elseif(self.Level1 == "Bottom") then
				_level1Head = ParaUI.CreateUIObject("container", "Level1Head", "_lt", 
						0, 0, self.Level1Offset, self.Level1ItemHeight);
				_level1 = ParaUI.CreateUIObject("container", "Level1", "_mb", 
						self.Level1Offset, 0, 0, self.Level1ItemHeight);
				borderHeight = borderHeight + self.Level1ItemHeight;
			end
			_level1Head.background = self.Level1HeadBG;
			_level1Head.enabled = false;
			_tabGrid:AddChild(_level1Head);
			_level1.background = self.Level1BG;
			_tabGrid:AddChild(_level1);
		end
		
		-- NOTE: we assume that level2 has the different alignment to level1
		--		and level1 information is avaiable
		
		local _level2, _level2Head;
		if(self.Level2 ~= nil) then
			if(self.Level2 == "Left") then
				_level2 = ParaUI.CreateUIObject("container", "Level2", "_ml", 
						0, self.Level2Offset, self.Level2ItemWidth, 0);
				borderX = borderX + self.Level2ItemWidth;
				_level2Head = ParaUI.CreateUIObject("container", "Level2Head", "_lt", 
						0, 0, self.Level2ItemWidth, self.Level2Offset);
			elseif(self.Level2 == "Right") then
				_level2 = ParaUI.CreateUIObject("container", "Level2", "_mr", 
						0, self.Level2Offset, self.Level2ItemWidth, 0);
				borderWidth = borderWidth + self.Level2ItemWidth;
				_level2Head = ParaUI.CreateUIObject("container", "Level2Head", "_lt", 
						0, 0, self.Level2ItemWidth, self.Level2Offset);
			elseif(self.Level2 == "Top") then
				_level2 = ParaUI.CreateUIObject("container", "Level2", "_mt", 
						self.Level2Offset, 0, 0, self.Level2ItemHeight);
				borderY = borderY + self.Level2ItemHeight;
				_level2Head = ParaUI.CreateUIObject("container", "Level2Head", "_lt", 
						0, 0, self.Level2Offset, self.Level2ItemHeight);
			elseif(self.Level2 == "Bottom") then
				_level2 = ParaUI.CreateUIObject("container", "Level2", "_mb", 
						self.Level2Offset, 0, 0, self.Level2ItemHeight);
				borderHeight = borderHeight + self.Level2ItemHeight;
				_level2Head = ParaUI.CreateUIObject("container", "Level2Head", "_lt", 
						0, 0, self.Level2Offset, self.Level2ItemHeight);
			end
			_level2Head.background = self.Level2HeadBG;
			_level2Head.enabled = false;
			_tabGrid:AddChild(_level2Head);
			_level2.background = self.Level2BG;
			_tabGrid:AddChild(_level2);
		end
		
		-- grid and page region
		local _gridPage = ParaUI.CreateUIObject("container", "GridPage", "_fi", borderX, borderY, borderWidth, borderHeight);
		_gridPage.background = "";
		_tabGrid:AddChild(_gridPage);
		
		self.borderX = borderX;
		self.borderY = borderY;
		self.borderWidth = borderWidth;
		self.borderHeight = borderHeight;
		
		-- update the control
		self:Update();
	else
		if(bShow == nil) then
			bShow = not _tabGrid.visible;
		end
		_tabGrid.visible = bShow;
	end
end

-- update control
function TabGrid:Update()
	self.LastUpdatedLevel1ItemIndex = self.LastUpdatedLevel1ItemIndex or -1;
	self.LastUpdatedLevel2ItemIndex = self.LastUpdatedLevel2ItemIndex or -1;
	if(self.LastUpdatedLevel1ItemIndex == self.CurrentFocusLevel1ItemIndex
		and self.LastUpdatedLevel2ItemIndex == self.CurrentFocusLevel2ItemIndex) then
		-- cancel update the control if last and current index are the same
		-- return;
	end
	
	-- update level1 items
	self:UpdateLevel1Items();
	-- update level2 items
	self:UpdateLevel2Items();
	-- update grid and page items
	self:UpdateGridPage();
	
	
	-- NOTE: don't SetLevelIndex() in OnChangeLevelIndex funcition, stack over flow
	if(type(self.OnChangeLevelIndex) == "function") then
		self.OnChangeLevelIndex(self.CurrentFocusLevel1ItemIndex, self.CurrentFocusLevel2ItemIndex);
	end
	
	self.LastUpdatedLevel1ItemIndex = self.CurrentFocusLevel1ItemIndex;
	self.LastUpdatedLevel2ItemIndex = self.CurrentFocusLevel2ItemIndex;
end

-- set the level index
-- @param level1: level1 index, if nil leave the level 1 information unchanged
-- @param level2: level2 index, if nil leave the level 2 information unchanged
function TabGrid:SetLevelIndex(level1, level2)
	
	self.CurrentFocusLevel1ItemIndex = level1 or self.CurrentFocusLevel1ItemIndex;
	self.CurrentFocusLevel2ItemIndex = level2 or self.CurrentFocusLevel2ItemIndex;
	
	self:Update();
end

-- get the level index
-- @return level1index and level2index
function TabGrid:GetLevelIndex()
	return self.CurrentFocusLevel1ItemIndex, self.CurrentFocusLevel2ItemIndex;
end

-- set the alignment information
-- @param level1: level1 alignment, if nil leave the level 1 information unchanged
-- @param level2: level2 alignment, if nil leave the level 2 information unchanged
function TabGrid:SetAlignment(level1, level2)
	
	self.Level1 = level1 or self.Level1;
	self.Level2 = level2 or self.Level2;
	
	local _tabGrid = ParaUI.GetUIObject(self.name.."_TabGrid");
	local bShow = _tabGrid.visible;
	ParaUI.Destroy(self.name.."_TabGrid");
	
	self:Show(true);
	self:Show(bShow);
end

-- update the level1 item
function TabGrid:UpdateLevel1Items()
	if(self.Level1 == nil) then
		-- no level1 information available
		return;
	end
	
	local _tabGrid = ParaUI.GetUIObject(self.name.."_TabGrid");
	if(_tabGrid:IsValid() == true) then
		local _level1 = _tabGrid:GetChild("Level1");
		if(_level1:IsValid() == true) then
			-- simply remove all items and create again
			_level1:RemoveAll();
			
			self.CurrentFocusLevel1ItemIndex = self.CurrentFocusLevel1ItemIndex or 1; -- set default focus to the first item
			
			local nCount = self.GetLevel1ItemCount();
			local i;
			for i = 1, nCount do
				local _item;
				if(self.Level1 == "Left" or self.Level1 == "Right") then
					_item = ParaUI.CreateUIObject("container", "item"..i, "_lt", 
							0, self.Level1ItemHeight * (i-1), 
							self.Level1ItemWidth, self.Level1ItemHeight);
				elseif(self.Level1 == "Top" or self.Level1 == "Bottom") then
					_item = ParaUI.CreateUIObject("container", "item"..i, "_lt", 
							self.Level1ItemWidth * (i-1), 0, 
							self.Level1ItemWidth, self.Level1ItemHeight);
				end
				_item.background = "";
				_level1:AddChild(_item);
				
				if(type(self.Level1ItemOwnerDraw) == "function") then
					self.Level1ItemOwnerDraw(_item, i, (i == self.CurrentFocusLevel1ItemIndex), self);
				else
					local _btn = ParaUI.CreateUIObject("button", "btn"..i, "_fi", 0, 0, 0, 0);
					-- default owner draw function
					_btn.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickCategory("%s", %d, nil);]], 
							self.name, i);
					_item:AddChild(_btn);
					if(self.GetLevel1ItemTooltip ~= nil) then
						_btn.tooltip = self.GetLevel1ItemTooltip(i);
					end
					if(i == self.CurrentFocusLevel1ItemIndex) then
						local _selectedForeImage = self.GetLevel1ItemSelectedForeImage(i);
						local _selectedBackImage = self.GetLevel1ItemSelectedBackImage(i);
						_guihelper.SetVistaStyleButton2(_btn, _selectedForeImage, _selectedBackImage);
					else
						local _unselectedForeImage = self.GetLevel1ItemUnselectedForeImage(i);
						local _unselectedBackImage = self.GetLevel1ItemUnselectedBackImage(i);
						_guihelper.SetVistaStyleButton2(_btn, _unselectedForeImage, _unselectedBackImage);
					end
				end -- if(self.Level1ItemOwnerDraw) then
			end
			
			local _level1Tail;
			if(self.Level1 == "Left" or self.Level1 == "Right") then
				_level1Tail = ParaUI.CreateUIObject("container", "Level1Tail", "_ml", 
						0, self.Level1ItemHeight * nCount, 
						self.Level1ItemWidth, 0);
			elseif(self.Level1 == "Top" or self.Level1 == "Bottom") then
				_level1Tail = ParaUI.CreateUIObject("container", "Level1Tail", "_mt", 
						self.Level1ItemWidth * nCount, 0, 
						0, self.Level1ItemHeight);
			end
			_level1Tail.background = self.Level1TailBG;
			_level1:AddChild(_level1Tail);
		end
	end
end

-- update the level2 item
function TabGrid:UpdateLevel2Items()
	if(self.Level2 == nil) then
		-- no level2 information available
		return;
	end
	
	local _tabGrid = ParaUI.GetUIObject(self.name.."_TabGrid");
	if(_tabGrid:IsValid() == true) then
		local _level2 = _tabGrid:GetChild("Level2");
		if(_level2:IsValid() == true) then
			-- simply remove all items and create again
			_level2:RemoveAll();
			
			self.CurrentFocusLevel2ItemIndex = self.CurrentFocusLevel2ItemIndex or 1; -- set default focus to the first item
			
			local nCount = self.GetLevel2ItemCount(self.CurrentFocusLevel1ItemIndex);
			local i;
			for i = 1, nCount do
				local _item;
				if(self.Level2 == "Left" or self.Level2 == "Right") then
					_item = ParaUI.CreateUIObject("container", "item"..i, "_lt", 
							0, self.Level2ItemHeight * (i-1), 
							self.Level2ItemWidth, self.Level2ItemHeight);
				elseif(self.Level2 == "Top" or self.Level2 == "Bottom") then
					_item = ParaUI.CreateUIObject("container", "item"..i, "_lt", 
							self.Level2ItemWidth * (i-1), 0, 
							self.Level2ItemWidth, self.Level2ItemHeight);
				end
				_item.background = "";
				_level2:AddChild(_item);
				
				
				if(type(self.Level2ItemOwnerDraw) == "function") then
					self.Level2ItemOwnerDraw(_item, i, (i == self.CurrentFocusLevel2ItemIndex), self);
				else
					local _btn = ParaUI.CreateUIObject("button", "btn"..i, "_fi", 0, 0, 0, 0);
					_btn.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickCategory("%s", nil, %d);]], 
							self.name, i);
					_item:AddChild(_btn);
					if(self.GetLevel2ItemTooltip ~= nil) then
						_btn.tooltip = self.GetLevel2ItemTooltip(self.CurrentFocusLevel1ItemIndex, i);
					end
					if(i == self.CurrentFocusLevel2ItemIndex) then
						local _selectedForeImage = self.GetLevel2ItemSelectedForeImage(self.CurrentFocusLevel1ItemIndex, i);
						local _selectedBackImage = self.GetLevel2ItemSelectedBackImage(self.CurrentFocusLevel1ItemIndex, i);
						_guihelper.SetVistaStyleButton2(_btn, _selectedForeImage, _selectedBackImage);
					else
						local _unselectedForeImage = self.GetLevel2ItemUnselectedForeImage(self.CurrentFocusLevel1ItemIndex, i);
						local _unselectedBackImage = self.GetLevel2ItemUnselectedBackImage(self.CurrentFocusLevel1ItemIndex, i);
						_guihelper.SetVistaStyleButton2(_btn, _unselectedForeImage, _unselectedBackImage);
					end
				end
			end
			
			local _level2Tail;
			if(self.Level2 == "Left" or self.Level2 == "Right") then
				_level2Tail = ParaUI.CreateUIObject("container", "Level2Tail", "_ml", 
						0, self.Level2ItemHeight * nCount, 
						self.Level2ItemWidth, 0);
			elseif(self.Level2 == "Top" or self.Level2 == "Bottom") then
				_level2Tail = ParaUI.CreateUIObject("container", "Level2Tail", "_mt", 
						self.Level2ItemWidth * nCount, 0, 
						0, self.Level2ItemHeight);
			end
			_level2Tail.background = self.Level2TailBG;
			_level2:AddChild(_level2Tail);
		end
	end
end

-- update the grid and page
function TabGrid:UpdateGridPage()
	local _tabGrid = ParaUI.GetUIObject(self.name.."_TabGrid");
	if(_tabGrid:IsValid() == true) then
		local _gridPage = _tabGrid:GetChild("GridPage");
		if(_gridPage:IsValid() == true) then
			local _, __, width, height = _gridPage:GetAbsPosition();
			
			if(self.lastGridPageWidth == nil) then
				self.lastGridPageWidth = width;
			end
			if(self.lastGridPageHeight == nil) then
				self.lastGridPageHeight = height;
			end
			
			local isSizeChanged = false;
			if(self.lastGridPageWidth ~= width or self.lastGridPageHeight ~= height) then
				isSizeChanged = true;
			end
			
			local nCount = self.GetGridItemCount(self.CurrentFocusLevel1ItemIndex, self.CurrentFocusLevel2ItemIndex);
			
			if(nCount == nil) then
				-- no grid information is avaiable, remove all children
				-- NOTE: this is useful when the tabgrid don't want to display any grid information
				-- e.x: use the tabgrid as a tab
				_gridPage:RemoveAll();
				return;
			end
			
			local nCellWidth = self.nGridCellWidth;
			local nCellHeight = self.nGridCellHeight;
			local nGap = self.nGridCellGap;
			
			local nX = math.floor((width - self.nGridBorderLeft - self.nGridBorderRight + nGap) / (nCellWidth + nGap));
			local nY = math.floor((height - self.nGridBorderTop - self.nGridBorderBottom + nGap) / (nCellHeight + nGap));
			
			-- page region
			local bShowPageRegion = true;
			if((nX * nY) >= nCount and self.isAlwaysShowPager == false) then
				bShowPageRegion = false;
			end
			
			if(bShowPageRegion == true) then
				nX = math.floor((width - self.nGridBorderLeft - self.nGridBorderRight + nGap) / (nCellWidth + nGap));
				nY = math.floor((height - self.pageRegionHeight - self.nGridBorderTop - self.nGridBorderBottom + nGap) / (nCellHeight + nGap));
			end
			
			if(self.CurrentGridLevel1Index == self.CurrentFocusLevel1ItemIndex 
					and self.CurrentGridLevel2Index == self.CurrentFocusLevel2ItemIndex
					and self.CurrentGridClientColumns == nX
					and self.CurrentGridClientRows == nY
					) then
				-- no need to update the grid view
				return;
			end
			
			-- simply remove all items and create again
			_gridPage:RemoveAll();
			
			-- grid view alignment styles according to the category alignment
			local alignment;
			local left, top, width, height;
			if(self.Level1 == "Left" and self.Level2 == "Top") or (self.Level1 == "Top" and self.Level2 == "Left") then
				alignment = "_lt";
			elseif(self.Level1 == "Right" and self.Level2 == "Top") or (self.Level1 == "Top" and self.Level2 == "Right") then
				alignment = "_rt";
			elseif(self.Level1 == "Left" and self.Level2 == "Bottom") or (self.Level1 == "Bottom" and self.Level2 == "Left") then
				alignment = "_lb";
			elseif(self.Level1 == "Right" and self.Level2 == "Bottom") or (self.Level1 == "Bottom" and self.Level2 == "Right") then
				alignment = "_rb";
			elseif(self.Level1 == "Top" and self.Level2 == "Bottom") or (self.Level1 == "Bottom" and self.Level2 == "Top")
					or (self.Level1 == "Left" and self.Level2 == "Right") or (self.Level1 == "Right" and self.Level2 == "Left") then
				alignment = "_ctt";
			elseif(self.Level1 == nil or self.Level2 == nil) then
				if(self.Level1 == "Left" or self.Level2 == "Left" or self.Level1 == "Top" or self.Level2 == "Top") then
					alignment = "_lt";
				elseif(self.Level1 == "Right" or self.Level2 == "Right") then
					alignment = "_rt";
				elseif(self.Level1 == "Bottom" or self.Level2 == "Bottom") then
					alignment = "_ctt";
				end
			end
			
			width = (nCellWidth + nGap) * nX - nGap;
			height = (nCellHeight + nGap) * nY - nGap;
			
			-- page region alignment style
			local pageAlignment = alignment;
			local pageX, pageY, pageWidth, pageHeight;
			pageWidth = (nCellWidth + nGap) * nX - nGap;
			pageHeight = self.pageRegionHeight;
			
			if(bShowPageRegion == true) then
				if(alignment == "_lt") then
					left = self.nGridBorderLeft;
					top = self.nGridBorderTop;
					pageX = self.nGridBorderLeft;
					pageY = self.nGridBorderTop + height;
				elseif(alignment == "_rt") then
					left = - width - self.nGridBorderRight;
					top = self.nGridBorderTop;
					pageX = - width - self.nGridBorderRight;
					pageY = self.nGridBorderTop + height;
				elseif(alignment == "_lb") then
					left = self.nGridBorderLeft;
					top = - height - self.nGridBorderBottom - pageHeight;
					pageX = self.nGridBorderLeft;
					pageY = - self.nGridBorderBottom - pageHeight;
				elseif(alignment == "_rb") then
					left = - width - self.nGridBorderRight;
					top = - height - self.nGridBorderBottom - pageHeight;
					pageX = - width - self.nGridBorderRight;
					pageY = - self.nGridBorderBottom - pageHeight;
				elseif(alignment == "_ctt") then
					left = 0;
					top = self.nGridBorderTop;
					pageX = 0;
					pageY = self.nGridBorderTop + height;
				end
			else
				if(alignment == "_lt") then
					left = self.nGridBorderLeft;
					top = self.nGridBorderTop;
				elseif(alignment == "_rt") then
					left = - width - self.nGridBorderRight;
					top = self.nGridBorderTop;
				elseif(alignment == "_lb") then
					left = self.nGridBorderLeft;
					top = - height - self.nGridBorderBottom;
				elseif(alignment == "_rb") then
					left = - width - self.nGridBorderRight;
					top = - height - self.nGridBorderBottom;
				elseif(alignment == "_ctt") then
					left = 0; top = self.nGridBorderTop;
				end
			end
			
			local columns = nX;
			local rows = math.ceil(nCount/nX);
			
			-- destroy the old control
			if(CommonCtrl.GetControl(self.name.."_TabGrid_GridView") ~= nil) then
				CommonCtrl.GetControl(self.name.."_TabGrid_GridView"):Destroy();
				CommonCtrl.DeleteControl(self.name.."_TabGrid_GridView");
			end
			
			
			local ctl;
			
			if(self.isGridView3D == false or self.isGridView3D == nil) then
				-- grid view for items in 2D mode
				NPL.load("(gl)script/ide/GridView.lua");
				ctl = CommonCtrl.GridView:new{
					name = self.name.."_TabGrid_GridView",
					alignment = alignment,
					left = left, top = top,
					width = width + nGap,
					height = height + nGap,
					cellWidth = nCellWidth + nGap,
					cellHeight = nCellHeight + nGap,
					parent = _gridPage,
					columns = columns,
					rows = rows,
					nX = nX,
					nY = nY,
					
					DrawCellHandler = function (_parent, gridcell) 
							if(self.GridDrawCellHandler ~= nil) then
								self.GridDrawCellHandler(_parent, gridcell, self);
								return;
							end
							
							local tabgrid = self;
							if(_parent == nil or gridcell == nil) then
								return;
							end
							
							if(gridcell ~= nil) then
								local _this = ParaUI.CreateUIObject("button", gridcell.text, "_lt", 0, 0, gridcell.btnWidth, gridcell.btnHeight);
								if(tabgrid.CurrentFocusLevel1ItemIndex == nil) then
									_this.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickItem("%s", nil, %d, %d);]], 
											tabgrid.name, tabgrid.CurrentFocusLevel2ItemIndex, gridcell.index);
								elseif(tabgrid.CurrentFocusLevel2ItemIndex == nil) then
									_this.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickItem("%s", %d, nil, %d);]], 
											tabgrid.name, tabgrid.CurrentFocusLevel1ItemIndex, gridcell.index);
								elseif(tabgrid.CurrentFocusLevel1ItemIndex == nil and self.CurrentFocusLevel2ItemIndex == nil) then
									_this.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickItem("%s", nil, nil, %d);]], 
											tabgrid.name, gridcell.index);
								else
									_this.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickItem("%s", %d, %d, %d);]], 
											tabgrid.name, tabgrid.CurrentFocusLevel1ItemIndex, tabgrid.CurrentFocusLevel2ItemIndex, gridcell.index);
								end
								--_this.background = gridcell.ForeImage;
								_guihelper.SetVistaStyleButton2(_this, gridcell.ForeImage, gridcell.BackImage);
								
								if(gridcell.enabled ~= nil) then
									_this.enabled = gridcell.enabled;
								end
								_this.animstyle = 12;
								_parent:AddChild(_this);
								
								--local _this = ParaUI.CreateUIObject("button", "BG", "_lt", 0, 0, gridcell.btnWidth, gridcell.btnHeight);
								--_this.background = gridcell.BackImage;
								--_this.scalingx = 1.2;
								--_this.scalingy = 1.2;
								--_parent:AddChild(_this);
							end
						end,
					};
				
				-- insert all the items in according to the current category selection
				local i, j;
				for i = 1, rows do
					for j = 1, columns do
						if(((i-1) * nX + j) > nCount) then
							break;
						end
						local cell = CommonCtrl.GridCell:new{
							GridView = nil,
							name = i.."-"..j,
							text = i.."-"..j,
							column = j,
							row = i,
							btnWidth = nCellWidth,
							btnHeight = nCellHeight,
							index = (i-1) * nX + j,
							enabled = self.GetGridItemEnabled(self.CurrentFocusLevel1ItemIndex, 
								self.CurrentFocusLevel2ItemIndex, 
								(i-1) * nX + j),
							ForeImage = self.GetGridItemForeImage(self.CurrentFocusLevel1ItemIndex, 
								self.CurrentFocusLevel2ItemIndex, 
								(i-1) * nX + j),
							BackImage = self.GetGridItemBackImage(self.CurrentFocusLevel1ItemIndex, 
								self.CurrentFocusLevel2ItemIndex, 
								(i-1) * nX + j),
							};
						ctl:InsertCell(cell, "Right");
					end
				end
				
				ctl:Show();
			else
				
				function TabGrid.OnEnterIconMatrix(gridViewName, x, y)
					local ctl = CommonCtrl.GetControl(gridViewName);
					if(ctl ~= nil) then
						local scene = ctl:GetMiniSceneGraph();
						local obj = scene:GetObject(x.."-"..y);
						if(obj:IsValid() == true) then
							local att = obj:GetAttributeObject();
							att:SetField("render_tech", 10);
						end
					end
				end
				
				function TabGrid.OnLeaveIconMatrix(gridViewName, x, y)
					local ctl = CommonCtrl.GetControl(gridViewName);
					if(ctl ~= nil) then
						local scene = ctl:GetMiniSceneGraph();
						local obj = scene:GetObject(x.."-"..y);
						if(obj:IsValid() == true) then
							local att = obj:GetAttributeObject();
							att:SetField("render_tech", 9);
						end
					end
				end
				-- grid view for items in 3D mode
				NPL.load("(gl)script/ide/GridView3D.lua");
				
				ctl = CommonCtrl.GridView3D:new{
					name = self.name.."_TabGrid_GridView",
					alignment = alignment,
					left = left, top = top,
					
					--width = width + nGap,
					--height = height + nGap,
					--cellWidth = nCellWidth + nGap,
					--cellHeight = nCellHeight + nGap,
					
					width = width,
					height = height,
					cellWidth = nCellWidth,
					cellHeight = nCellHeight,
					cellPadding = nGap,
					
					parent = _gridPage,
					columns = columns,
					rows = rows,
					nX = nX,
					nY = nY,
					
					---- TODO: tricky solve
					--renderTargetSize = 1024, -- currently fix the right window problem
					
					DrawCellHandler = function(_parent, cell, filename)
						-- simply attach a drawing board on the position
						local scene = cell.GridView3D:GetMiniSceneGraph();
						--scene:RemoveObject(obj);
						
						if(cell ~= nil) then
							local _this = ParaUI.CreateUIObject("button", cell.text, "_lt", 0, 0, cell.btnWidth, cell.btnHeight);
							_this.background = filename;
							if(cell.enabled ~= nil) then
								_this.enabled = cell.enabled;
							end
							_this.animstyle = 12;
							--_this.onmouseenter = ";Map3DSystem.UI.TabGrid.OnEnterIconMatrix(\""..cell.GridView3D.name.."\", "..cell.column..", "..cell.row..");";
							--_this.onmouseleave = ";Map3DSystem.UI.TabGrid.OnLeaveIconMatrix(\""..cell.GridView3D.name.."\", "..cell.column..", "..cell.row..");";
							--_this.tooltip = cell.tooltip;
							if(self.CurrentFocusLevel1ItemIndex == nil) then
								_this.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickItem("%s", nil, %d, %d);]], 
										self.name, self.CurrentFocusLevel2ItemIndex, cell.index);
							elseif(self.CurrentFocusLevel2ItemIndex == nil) then
								_this.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickItem("%s", %d, nil, %d);]], 
										self.name, self.CurrentFocusLevel1ItemIndex, cell.index);
							elseif(self.CurrentFocusLevel1ItemIndex == nil and self.CurrentFocusLevel2ItemIndex == nil) then
								_this.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickItem("%s", nil, nil, %d);]], 
										self.name, cell.index);
							else
								_this.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickItem("%s", %d, %d, %d);]], 
										self.name, self.CurrentFocusLevel1ItemIndex, self.CurrentFocusLevel2ItemIndex, cell.index);
							end
							_parent:AddChild(_this);
						end
						--
						--local model, skin;
						--model = cell.Model;
						--skin = cell.Skin;
						--
						--local _asset = ParaAsset.LoadStaticMesh("", model);
						--local obj = ParaScene.CreateMeshPhysicsObject(cell.column.."-"..cell.row, _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
						--if(obj:IsValid()) then
							--obj:SetFacing(1.57);
							--obj:GetAttributeObject():SetField("progress", 1);
							--
							--local aabb = {};
							--_asset:GetBoundingBox(aabb);
							--local dx = math.abs(aabb.max_x - aabb.min_x);
							--local dy = math.abs(aabb.max_y - aabb.min_y);
							--local dz = math.abs(aabb.max_z - aabb.min_z);
							--
							--local max = math.max(dx, dy);
							--max = math.max(max, dz);
							--obj:SetScale(4.5/max);
							----obj:SetScale(6.4/max);
							--
							----local offsetX = -(aabb.max_x + aabb.min_x) * 5;
							----local offsetY = -(aabb.max_y + aabb.min_y) * 5;
							--local offsetX = -(aabb.max_x + aabb.min_x) * -11;
							--local offsetY = -(aabb.max_y + aabb.min_y) * 3;
							--
							--obj:SetPosition(cell.logicalX + offsetX, cell.logicalY + offsetY, 0);
							----obj:SetPosition(3.2, -6.4, 0);
							--local att = obj:GetAttributeObject();
							--att:SetField("render_tech", 9);
							--
							--scene:AddChild(obj);
							--
							--if(type(skin) == "table") then
								--local k, v;
								--for k, v in pairs(skin) do
									--local _texture = ParaAsset.LoadTexture("", v, 1);
									--obj:SetReplaceableTexture(k, _texture);
								--end
							--end
						--end
					end,
					};
				
				-- insert all the items in according to the current category selection
				local i, j;
				for i = 1, rows do
					for j = 1, columns do
						if(((i-1) * nX + j) > nCount) then
							break;
						end
						local cell = CommonCtrl.GridCell3D:new{
							GridView = nil,
							name = i.."-"..j,
							text = i.."-"..j,
							column = j,
							row = i,
							btnWidth = nCellWidth,
							btnHeight = nCellHeight,
							cellWidth = nCellWidth,
							cellHeight = nCellHeight,
							index = (i-1) * nX + j,
							enabled = self.GetGridItemEnabled(self.CurrentFocusLevel1ItemIndex, 
								self.CurrentFocusLevel2ItemIndex, 
								(i-1) * nX + j),
							--ForeImage = self.GetGridItemForeImage(self.CurrentFocusLevel1ItemIndex, 
								--self.CurrentFocusLevel2ItemIndex, 
								--(i-1) * nX + j),
							--BackImage = self.GetGridItemBackImage(self.CurrentFocusLevel1ItemIndex, 
								--self.CurrentFocusLevel2ItemIndex, 
								--(i-1) * nX + j),
							Model = self.GetGrid3DItemModel(self.CurrentFocusLevel1ItemIndex, 
								self.CurrentFocusLevel2ItemIndex, 
								(i-1) * nX + j),
							Skin = self.GetGrid3DItemSkin(self.CurrentFocusLevel1ItemIndex, 
								self.CurrentFocusLevel2ItemIndex, 
								(i-1) * nX + j),
							};
						ctl:InsertCell(cell, "Right");
					end
				end
				
				ctl:Show();
			end
			
			-- page region
			if(bShowPageRegion == true) then
				local _pageRegion = ParaUI.CreateUIObject("container", "PageRegion", pageAlignment, pageX, pageY, pageWidth, pageHeight);
				_pageRegion.background = "";
				_gridPage:AddChild(_pageRegion);
				
				local _pageNumber = ParaUI.CreateUIObject("button", "PageNumber", "_ctt", 
						0, 0, self.pageNumberWidth, self.pageRegionHeight);
				_pageNumber.background = "";
				_pageNumber.enabled = true;
				_guihelper.SetFontColor(_pageNumber, self.pageNumberColor or "0 0 0");
				_pageRegion:AddChild(_pageNumber);
				local _pageLeft = ParaUI.CreateUIObject("button", "PageLeft", "_ctt", 
						- self.pageNumberWidth / 2 - self.pageDefaultMargin - self.pageLeftWidth / 2, 
						(self.pageRegionHeight - self.pageLeftHeight) / 2, 
						self.pageLeftWidth, self.pageLeftHeight);
				_pageLeft.background = self.pageLeftImage;
				_pageLeft.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnPageLeft("%s");]], self.name);
				_pageRegion:AddChild(_pageLeft);
				local _pageRight = ParaUI.CreateUIObject("button", "PageRight", "_ctt", 
						self.pageNumberWidth / 2 + self.pageDefaultMargin + self.pageRightWidth / 2, 
						(self.pageRegionHeight - self.pageRightHeight) / 2, 
						self.pageRightWidth, self.pageRightHeight);
				_pageRight.background = self.pageRightImage;
				_pageRight.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnPageRight("%s");]], self.name);
				_pageRegion:AddChild(_pageRight);
				
				-- set current page and total page
				ctl.GridCurrentPage = 1;
				if(nCount == 0) then
					ctl.GridCurrentPage = 0;
				end
				ctl.GridTotalPage = math.ceil(rows/nY);
				
				-- set the page left and page right enabled field
				TabGrid.SetPageInformation(self.name);
			end
			
			-- current grid view level index, indicating which categories currently focused
			self.CurrentGridLevel1Index = self.CurrentFocusLevel1ItemIndex;
			self.CurrentGridLevel2Index = self.CurrentFocusLevel2ItemIndex;
		end
	end
end

-- on change size the width and height is the new 
function TabGrid:OnSize(newWidth, newHeight)
	-- newWidth, newHeight;
	self:UpdateGridPage();
end

-- onclick function of the tabgrid category
-- @param name: name of the TabGrid
-- @param level1index: level1 index
-- @param level2index: level2 index
function TabGrid.OnClickCategory(name, level1index, level2index)
	
	local ctl = CommonCtrl.GetControl(name);
	if(ctl ~= nil) then
		if(level1index ~= nil and ctl.OnClickLevel1 ~= nil) then
			ctl.OnClickLevel1(level1index);
		end
		if(level2index ~= nil and ctl.OnClickLevel2 ~= nil) then
			ctl.OnClickLevel2(level2index);
		end
		ctl.CurrentFocusLevel1ItemIndex = level1index or ctl.CurrentFocusLevel1ItemIndex;
		ctl.CurrentFocusLevel2ItemIndex = level2index or ctl.CurrentFocusLevel2ItemIndex;
		if(level1index ~= nil and ctl.CurrentFocusLevel2ItemIndex ~= nil) then
			-- TODO: we assume that if one level 2 category has items, then all level 2 category has items
			ctl.CurrentFocusLevel2ItemIndex = 1;
		end
		ctl:Update();
	end
end

-- onclick function of the tabgrid item
-- @param name: name of the TabGrid
-- @param level1index: level1 index
-- @param level2index: level2 index
-- @param itemindex: item index
function TabGrid.OnClickItem(name, level1index, level2index, itemindex)
	
	local ctl = CommonCtrl.GetControl(name);
	if(ctl ~= nil) then
		ctl.OnClickItem(level1index, level2index, itemindex);
	end
end

-- Internal use only
-- set the page region information, including:
--		Page left and page right enabled
--		page number: current page / total page
-- @param name: name of the tabgrid control
function TabGrid.SetPageInformation(name)
	local _tabGrid = ParaUI.GetUIObject(name.."_TabGrid");
	if(_tabGrid:IsValid() == true) then
		local _gridPage = _tabGrid:GetChild("GridPage");
		if(_gridPage:IsValid() == true) then
			local _pageRegion = _gridPage:GetChild("PageRegion");
			if(_pageRegion:IsValid() == true) then
				local _pageNumber = _pageRegion:GetChild("PageNumber");
				local _pageLeft = _pageRegion:GetChild("PageLeft");
				local _pageRight = _pageRegion:GetChild("PageRight");
				
				local ctl = CommonCtrl.GetControl(name.."_TabGrid_GridView");
				if(ctl ~= nil) then
					-- update the page information
					_pageNumber.text = ctl.GridCurrentPage.."/"..ctl.GridTotalPage;
					
					-- update the page left right enabled
					if(ctl.GridCurrentPage <= 1) then
						_pageLeft.enabled = false;
					else
						_pageLeft.enabled = true;
					end
					if(ctl.GridCurrentPage >= ctl.GridTotalPage) then
						_pageRight.enabled = false;
					else
						_pageRight.enabled = true;
					end
				end
			end
		end
	end
end

-- onclick function of the tabgrid pageleft
function TabGrid.OnPageLeft(name)
	
	local ctl = CommonCtrl.GetControl(name.."_TabGrid_GridView");
	if(ctl ~= nil) then
		-- NOTE: columns and nX are the same here, actually it's "page up and down"
		if(ctl.GridCurrentPage > 1) then
			ctl:OnShiftUpByCell(ctl.nY);
			ctl.GridCurrentPage = ctl.GridCurrentPage - 1;
			
			TabGrid.SetPageInformation(name);
		end
	end
end

-- onclick function of the tabgrid pageright
function TabGrid.OnPageRight(name)
	
	local ctl = CommonCtrl.GetControl(name.."_TabGrid_GridView");
	if(ctl ~= nil) then
		-- NOTE: columns and nX are the same here, actually it's "page up and down"
		if(ctl.GridCurrentPage < ctl.GridTotalPage) then
			ctl:OnShiftDownByCell(ctl.nY);
			ctl.GridCurrentPage = ctl.GridCurrentPage + 1;
			
			TabGrid.SetPageInformation(name);
		end
	end
end

