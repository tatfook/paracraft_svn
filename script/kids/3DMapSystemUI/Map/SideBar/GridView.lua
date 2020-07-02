--[[
Title:
Author(s):Sun Lingfeng
Date: 2008/2/22
Note: 
Use the lib:
------------------------------------------------------------

-------------------------------------------------------
]]

local Cell = {
	ID = nil,
	isEmpty = nil,
	image = nil,
	data = nil,
}
Map3DApp.GridCell = Cell;

function Cell:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

-------image grid view----------
local ImageGridView = {
	name = "igv",
	
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 300,
	
	parent = nil,
	
	cells = {},
	cellCount = 0,
	maxCellCount = 10,
	cellWidth = 0,
	cellHeight = 0,
	
	columnCount = 0,
	rowCount = 0,
	cellSpaceX = 4,
	cellSpaceY = 4,
	
	onCellClick = nil;
}
Map3DApp.ImageGridView = ImageGridView;

function ImageGridView:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	CommonCtrl.AddControl(o.name,o);

	for i = 1,o.maxCellCount do
		o.cells[i] = Map3DApp.GridCell:new{
				ID = i,
				isEmpty = true,
				image = nil,
				--TODO:delete this
				--data = Map3DApp.ModelData:new{
					--model = "model/map3D/building/bank/bank_6.x";
				--},
				data = nil,
		};
	end

	return o;
end

function ImageGridView:Show(bShow)
	local _this,_parent;
	if(self.name == nil)then
		log("map grid view name can not be nil\r\n");
		return;
	end
	
	_this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		self:RecreateUI();
	else
		if(bShow == nil)then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end
end

function ImageGridView:Resize(x,y,width,height)
	self.left = x;
	self.top = y;
	self.width = width;
	self.height = height;

	self:RecreateUI();
end

--delete all cell data
function ImageGridView:Reset()
	for i = 1,self.maxCellCount do
		self.cells[i].isEmpty = true;
		self.cells[i].data = nil;
	end
	self.cellCount = 0;
end

--dataSet is type of modelInfo
function ImageGridView:SetData(dataSet)
	if(dataSet == nil)then
		return;
	end
	
	self:Reset();
	while(self.cellCount<self.maxCellCount and dataSet[self.cellCount+1])do
		self.cellCount = self.cellCount + 1;
		self.cells[self.cellCount].isEmpty = false;
		self.cells[self.cellCount].data = dataSet[i];
		
		if(dataSet[self.cellCount].GetImage)then
			local image = dataSet[self.cellCount]:GetImage();
			if(image and image ~= "")then
				self.cells[self.cellCount].image = image;
			else
				self.cells[self.cellCount].image = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 24 24";
			end
		end
		
		if(dataSet[self.cellCount].GetName)then
			self.cells[self.cellCount].name = dataSet[self.cellCount]:GetName();
		end
	end
	self:RefreshCells();
end

--add new data to a cell
function ImageGridView:AddCell(image,data)
	if(self:IsFull())then
		return;
	end
	
	for i = 1,self.maxCellCount do
		if(self.cells[i].isEmpty)then
			self.cells[i].image = image;
			self.cells[i].data = data;
			self.cells[i].isEmpty = false;
			self.cellCount = self.cellCount + 1;
			break
		end
	end	
end

function ImageGridView:RemoveCellByID(cellID)
	if(self.cells[cellID])then
		self.cells[cellID].isEmpty = true;
		self.cells[cellID].data = nil;
		self.cells[cellID].image = nil;
		self.cellCount = self.cellCount - 1;
	end
end

function ImageGridView:RefreshCells()
	for i = 1,self.maxCellCount do
		local _this = ParaUI.GetUIObject(self.name..self.cells[i].ID);
		if(_this:IsValid())then
			if(self.cells[i].isEmpty)then
				_this.visible = false;
			else
				_this.visible = true;
				self:DrawCell(_this,self.cells[i]);
			end
		end
	end		
end

function ImageGridView:DrawCell(parent,cell)
	local _this = ParaUI.GetUIObject(self.name..cell.ID.."btn");
	if(_this:IsValid() == false)then
		_this = ParaUI.CreateUIObject("button",self.name..cell.ID.."btn","_fi",0,0,0,0);
		parent:AddChild(_this);
	end
	
	if(cell.image)then
		_this.background = cell.image;
	end
	_this.tooltip = cell.name;
	
	_this.onclick = string.format(";Map3DApp.ImageGridView.OnCellClick(%q,%d)",self.name,cell.ID);
end

--return true when all cell is occupied
function ImageGridView:IsFull()
	return self.cellCount >= self.maxCellCount;
end

function ImageGridView:GetMaxCellCount()
	return self.maxCellCount;
end

function ImageGridView:Destroy()
	self.cells = nil;
	self.parent = nil;
	ParaUI.Destroy(self.name);
end

function ImageGridView.SetOnCellClickCallback(callback)
	self.onCellClick = callback;
end


--=============private===========================
--create ui resource
function ImageGridView:RecreateUI()
	ParaUI.Destroy(self.name);
	
	local _this,_parent;	
	--create control container
	_this = ParaUI.CreateUIObject("container",self.name,self.alignment, self.left, self.top, self.width, self.height);
	_this.scrollable = false;
	--set background 
	if(self.bgImage ~= nil)then
		_this.background = self.bgImage;
	end
	if(self.parent == nil)then
		_this:AttachToRoot();
	else
		self.parent:AddChild(_this);
	end
	_parent = _this;
	
	self.rowCount = math.floor((self.width - self.cellSpaceX) / (self.cellWidth + self.cellSpaceX));
	self.columnCount = math.ceil(self.maxCellCount / self.rowCount);
	if(self.columnCount * (self.cellSpaceY + self.cellHeight) > self.height)then
		_this.scrollable = true;	
		scrollBarWidth = _this.scrollbarwidth;
		self.rowCount = math.floor((self.width - 4 - _this.scrollbarwidth)/ (self.cellWidth + 4));
		self.columnCount = math.ceil(self.maxCellCount / self.rowCount);
	end
	
	--create container for each cell
	for i = 1,self.maxCellCount do
		local y = math.ceil(i/self.rowCount);
		local x = i - (y-1) * self.rowCount;
		x = (x - 1) * (self.cellSpaceX + self.cellWidth) + self.cellSpaceX;
		y = (y - 1) * (self.cellSpaceY + self.cellHeight) + self.cellSpaceY;
		_this = ParaUI.CreateUIObject("container",self.name..self.cells[i].ID,"_lt",x,y,self.cellWidth,self.cellHeight);
		--_this.background = "";
		_parent:AddChild(_this);
	end
end

--
function ImageGridView.OnCellClick(ctrName,cellID)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		return;
	end
	
	if(self.onCellClick)then
		self.onCellClick(self.cells[cellID]);
	end
end

