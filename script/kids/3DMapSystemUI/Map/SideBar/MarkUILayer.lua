--[[
Title: the UI layer for drawing the marks according to the current view region. 
Author(s): LiXizhi, Leio zhang, refactored by LiXizhi 2008.2.11
Date: 2008/1/24
Desc: it will reuse a pool of mark buttons. UI layer is automatically bind to visible mark Node in MyMapWnd
It does so by calling: Map3DApp.MyMapWnd.IteratorNextVisibleMarkNode()
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/MarkUILayer.lua");
Map3DApp.MarkUILayer.Init(MapBrowserName)
-- call this to update the UI layer. 
Map3DApp.MarkUILayer.OnViewRegionChange();
------------------------------------------------------------
]]
 
if(not Map3DApp.MarkUILayer)then Map3DApp.MarkUILayer={};end

-- the max number of cached mark buttons allowed
Map3DApp.MarkUILayer.MaxMarkDisplayed = 50;

-- an array of cached MarkButton
local MarkList={};
Map3DApp.MarkUILayer.MapBrowserName=nil;

-----------------------------------------------
-- Each mark button is associated with a UI object and a markInfo object. 
-- Mark buttons are reused as many as possible when view region changed. 
-----------------------------------------------
local MarkButton = {
	-- the treeView mark Node associated with this button
	markNode=nil,
	-- name of UI objects associated with this button
	name=nil,
	-- this is increased by 1 on each frame move. so that we know when a button is last used. 
	counter = 0,
	-- private: automatically set for text display during rotation. 
	textOffset_X = 0,
	textOffset_Y = 0,
}
Map3DApp.MarkButton = MarkButton;

function MarkButton:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function MarkButton:reset()
	self.markNode = nil;
	self.counter = 0;
end

-- update the UI object according to the markInfo. it does not update position.
-- @param parentWnd: it can be nil. but passing it will speed up this function.
function MarkButton:UpdateUI(parentWnd)
	if(parentWnd == nil) then
		local mapBrowser=CommonCtrl.GetControl(Map3DApp.MarkUILayer.MapBrowserName);
		parentWnd= mapBrowser:GetWnd();
		if(not parentWnd:IsValid()) then
			return;
		end
	end
	local markInfo = self.markNode.tag;
	--
	-- button 
	--
	local _this = parentWnd:GetChild(self.name);
	if(not _this:IsValid()) then
		-- create button if not done before
		_this = ParaUI.CreateUIObject("button", self.name, "_lt", 0, 0, 18, 18)
		_this.onclick = string.format(";Map3DApp.MarkButton.OnClickMark(%q);",self.name);
		_this.ondragbegin = string.format(";Map3DApp.MarkButton.MarkerDragBegin(%q);",parentWnd.name);
		_this.ondragend = ";Map3DApp.MarkButton.MarkerDragEnd();";
		parentWnd:AddChild(_this);
	end
	_this.background = markInfo:GetIcon() or "";
	_this.tooltip=markInfo.markTitle;
	-- TODO: dragging is only possible when node is not locked. 
	_this.candrag = not markInfo.Locked;
	self.cursor_x, self.cursor_y = markInfo:GetCursorPt();
	
	--
	-- text
	--
	_this = parentWnd:GetChild("t"..self.name);
	local textWidth = 100;
	if(not _this:IsValid()) then
		_this = ParaUI.CreateUIObject("text", "t"..self.name, "_lt", 0, 0, textWidth, 18)
		parentWnd:AddChild(_this);
	end	
	if(markInfo.bShowText) then
		_this.text = markInfo.markTitle;
		_this.scalingx = markInfo.textScale;
		_this.scalingy = markInfo.textScale;
		_this.rotation = markInfo.textRot;
		-- LXZ: use auto text shadow? does not look very good. 
		--_this.shadow = true;
		if(markInfo.textColor) then
			_this:GetFont("text").color = markInfo.textColor;
		end	
		
		-- tricky code to align text with button icon
		if(markInfo.textRot >=0) then
			self.textOffset_X = -self.cursor_x + math.cos(markInfo.textRot)*(textWidth*markInfo.textScale)/2 - textWidth/2;
			self.textOffset_Y = -self.cursor_y + 18 + math.sin(markInfo.textRot)*(textWidth*markInfo.textScale)/2;
		else
			self.textOffset_X = -self.cursor_x + math.cos(markInfo.textRot)*(textWidth*markInfo.textScale)/2 - textWidth/2;
			self.textOffset_Y = -self.cursor_y - 18 + math.sin(markInfo.textRot)*(textWidth*markInfo.textScale)/2;
		end
		
	else
		_this.text = "";
	end
end

-- update the position and visibility
-- @param pixelX, pixelY: if nil, the button will be hidden
-- @param parentWnd: it can be nil. but passing it will speed up this function.
function MarkButton:UpdatePosition(pixelX, pixelY, parentWnd)
	if(parentWnd == nil) then
		local mapBrowser=CommonCtrl.GetControl(Map3DApp.MarkUILayer.MapBrowserName);
		parentWnd= mapBrowser:GetWnd();
		if(not parentWnd:IsValid()) then
			return;
		end
	end
	-- for button
	local _this = parentWnd:GetChild(self.name);
	if(_this:IsValid()) then
		if(pixelX) then
			_this.x = pixelX - self.cursor_x;
			_this.y = pixelY - self.cursor_y;
			_this.visible = true;
		else
			_this.visible = false;
		end	
	end
	-- for text
	_this = parentWnd:GetChild("t"..self.name);
	if(_this:IsValid()) then
		if(pixelX and self.markNode.tag.bShowText) then
			_this.visible = true;
			_this.translationx = pixelX + self.textOffset_X;
			_this.translationy = pixelY + self.textOffset_Y; -- offside a little to display below it. 
		else
			_this.visible = false;
		end	
	end	
end

function MarkButton.MarkerDragBegin(parentName)
	ParaUI.AddDragReceiver(parentName);
end

function MarkButton.MarkerDragEnd()
	local i = tonumber(dragging_control);
	local btn = MarkList[i];
	if(btn) then
		local mark=btn.markNode.tag;
		if(mark) then
			local mapBrowser=CommonCtrl.GetControl(Map3DApp.MarkUILayer.MapBrowserName);
			local parentWnd= mapBrowser:GetWnd();
			if(parentWnd:IsValid()) then
				local _this = parentWnd:GetChild(btn.name);
				
				if(_this:IsValid()) then
					local px, py, pwidth, pheight = parentWnd:GetAbsPosition();
					local mx, my, mwidth, mheight = _this:GetAbsPosition();
					local cursor_x, cursor_y = mark:GetCursorPt();
					local xx,yy,ww,hh = mx-px+cursor_x,my-py+cursor_y,mwidth-pwidth,mheight-pheight;
					xx,yy=Map3DApp.MarkUILayer.ToDouble(xx,yy)
					mark.x=xx;
					mark.y=yy;
					-- refresh UI layer
					Map3DApp.MarkUILayer.OnViewRegionChange()
				end	
			end	
		end	
	end	
end

--[[ TODO: user clicks the mark, show a pop up UI 
mouse over: display balloon
left click: zoom in and display dialog
right click: display dialog
]]
function MarkButton.OnClickMark(btnName)
	local i = tonumber(btnName);
	local btn = MarkList[i];
	if(btn) then
		local mark = btn.markNode.tag;
		local mapBrowser=CommonCtrl.GetControl(Map3DApp.MarkUILayer.MapBrowserName);
		local x,y=mark.x,mark.y;
		--log(string.format("%s,%s\n",x,y));
		mapBrowser:JumpTo3D(x,y);
		--[[ TODO: 
		if(mark.IsLocal==true)then
			Map3DApp.Map3DAppMcmlMarkControl.ShowWindow(Map3DApp.Map3DAppMyMapContainer.MyMapViewName,nil,"modify",MarkInfoID);
		elseif(mark.IsLocal==false)then
			Map3DApp.Map3DAppMcmlMarkControl_view.ShowWindow(nil,nil,MarkInfoID);
		end]]
	end	
end

-----------------------------------------------
-- mark UI layer. 
-----------------------------------------------
-- call this function to bind the UI layer to the map window. It listens for ViewRegionChange event of the map window. 
function Map3DApp.MarkUILayer.Init(MapBrowserName)
	Map3DApp.MarkUILayer.MapBrowserName=MapBrowserName;
	local mapBrowser=CommonCtrl.GetControl(Map3DApp.MarkUILayer.MapBrowserName);
	if(mapBrowser~=nil)then
		mapBrowser:AddListener("markUILayer",Map3DApp.MarkUILayer);
		--mapBrowser.onViewRegionChange = Map3DApp.MarkUILayer.OnViewRegionChange;
	end
end

-- frame counter, increased by 1 for each OnViewRegionChange() call
local counter = 0;
-- event called when the view region is changed such as by panning and scaling the camera. 

function Map3DApp.MarkUILayer:SetMessage(sender,msg,data)
	if(msg == Map3DApp.Msg.mapViewRegionChanged)then
		Map3DApp.MarkUILayer.OnViewRegionChange(sender);
	end
end

function Map3DApp.MarkUILayer.OnViewRegionChange(sender)
	local mapBrowser = CommonCtrl.GetControl(sender);
	counter = counter + 1;
	Map3DApp.MarkUILayer.UpdateMarkPosition(counter);
	--[[
	local mapBrowser=CommonCtrl.GetControl(Map3DApp.MarkUILayer.MapBrowserName);
	if(mapBrowser==nil)then
		log("mapBrowser is nil \n");
		return;
	end
	-- we will display marks in both 2D and 3D mode. 
	counter = counter + 1;
	Map3DApp.MarkUILayer.UpdateMarkPosition(counter);
	
	--if(mapBrowser:GetDisplayMode() == Map3DApp.Global.DisplayState.D2)then
	--end
	--]]
end	

-----------------------------------------------
-- methods 
-----------------------------------------------
-- update mark position
-- @param counter: it is a counter increased by 1 during ViewRegionChange. We can use it to estimate when a node is added recently. 
function Map3DApp.MarkUILayer.UpdateMarkPosition(counter)
	local mapBrowser=CommonCtrl.GetControl(Map3DApp.MarkUILayer.MapBrowserName);
	local parentWnd= mapBrowser:GetWnd();
	if((not parentWnd) or (not parentWnd:IsValid())) then
		return;
	end
	local x,y ,_,viewRegionSize= mapBrowser:GetViewParams();
	local _,_,wndWidth,wndHeight = mapBrowser:GetWndPosition();
	local minX,minY,maxX,maxY=x-viewRegionSize/2,y-viewRegionSize/2,x+viewRegionSize/2,y+viewRegionSize/2
	x=x-viewRegionSize/2;
	y=y-viewRegionSize/2;
	
	local markNode;
	if(Map3DApp.MyMapWnd.IteratorNextVisibleMarkNode() == nil)then
		return;
	end
	
	for markNode in Map3DApp.MyMapWnd.IteratorNextVisibleMarkNode() do
		local mark=markNode.tag;
		if(mark) then
			local px,py = mark.x,mark.y;
			if(px>=minX and px<=maxX and py>=minY and py<=maxY)then
				-- if the mark Node is inside the view region, add it. 
				local btn = Map3DApp.MarkUILayer.AddMark(markNode, counter);
				if(btn) then
					local pixelX,pixelY;
					-- convert normalized world pt from [0-1] to pixel control position
					pixelX=(px-x)*wndWidth/viewRegionSize;
					pixelY=(py-y)*wndHeight/viewRegionSize;
					-- update btn position
					btn:UpdatePosition(pixelX, pixelY, parentWnd);
				else
					-- already reached max number of visible marks allowed. 
					break;	
				end	
			end
		end
	end
	
	-- make all buttons whose counter is smaller than current counter invisible
	local i, btn
	for i,btn in ipairs(MarkList) do
		if(btn.counter < counter) then
			-- hide button.
			btn:UpdatePosition(nil, nil, parentWnd);
		end
	end
end

-- add a new mark to the pool, it will reuse mark buton already in the pool if markInfo is the same.
-- @param counter: it is a counter increased by 1 during ViewRegionChange. We can use it to estimate when a node is added recently. 
-- @return: it returns the mark button added or it will nil if pool is full. we should stop calling AddMark after the pool is full. 
function  Map3DApp.MarkUILayer.AddMark(markNode,counter)
	local i, btn
	local minCounterIndex;
	local minCounter = nil;
	for i,btn in ipairs(MarkList) do
		if(btn.markNode == markNode) then
			-- return if already exist
			btn.counter = counter
			return btn;
		else
			if(not minCounter or btn.counter<minCounter) then
				minCounter = btn.counter;
				minCounterIndex = i;
			end
		end
	end
	if(table.getn(MarkList) < Map3DApp.MarkUILayer.MaxMarkDisplayed)then
		-- create a new one in the button pool if we have not reached MaxMarkDisplayed
		local btn = MarkButton:new{markNode=markNode, counter=counter, name = tostring(table.getn(MarkList)+1)}
		table.insert(MarkList, btn);
		btn:UpdateUI();
		return btn;
	else
		-- if the pool is used up, we will pick the oldest one to replace with . 
		if((minCounterIndex+1) < counter) then
			btn = MarkList[minCounterIndex];
			btn.markNode = markNode;
			btn.folderInfo = folderInfo;
			btn.counter = counter
			btn:UpdateUI();
			return btn;
		else
			-- we can display no more buttons, since the pool has no button to spare. return nil. 	
		end
	end
end

-- remove marks whose markNode is the same as input
-- @param markNode: the treeView mark Node
function Map3DApp.MarkUILayer.RemoveMark(markNode)
	local i, btn
	for i,btn in ipairs(MarkList) do
		if(btn.markNode == markNode or btn.folderInfo ==folderInfo) then
			-- free and reset the button.
			btn:reset();
		end
	end
end

-- clear all cached UI marks. 
function Map3DApp.MarkUILayer.ClearAll()
	local i, btn
	for i,btn in ipairs(MarkList) do
		btn:reset();
	end
end

-- convert normalized world pt from [0-1] to pixel control position
function  Map3DApp.MarkUILayer.ToPixel(px,py)
	local mapBrowser=CommonCtrl.GetControl(Map3DApp.MarkUILayer.MapBrowserName);
	local x,y ,__,viewRegionSize= mapBrowser:GetViewParams();
	local __,__,wndWidth,wndHeight = mapBrowser:GetWndPosition();
	
	x=x-viewRegionSize/2;
	y=y-viewRegionSize/2;
	local pixelX,pixelY;
	pixelX=(px-x)*wndWidth/viewRegionSize;
	pixelY=(py-y)*wndHeight/viewRegionSize;
	--log(string.format("pixelX:%s,pixelY:%s,%s,%s,%s,%s,%s\n",pixelX,pixelY,x,y,viewRegionSize,wndWidth,wndHeight));
	--log(string.format("%s,%s,'%s'\n",px,py));
	return pixelX,pixelY;
end
-- convert pixel control position to normalized world pt in [0-1]
function  Map3DApp.MarkUILayer.ToDouble(pixelX,pixelY)
	local mapBrowser=CommonCtrl.GetControl(Map3DApp.MarkUILayer.MapBrowserName);
	local x,y ,__,viewRegionSize= mapBrowser:GetViewParams();
	local __,__,wndWidth,wndHeight = mapBrowser:GetWndPosition();
	
	x=x-viewRegionSize/2;
	y=y-viewRegionSize/2;
	local px,py;
	px=(pixelX*viewRegionSize)/wndWidth+x;
	py=(pixelY*viewRegionSize)/wndHeight+y;
	return px,py;
end
