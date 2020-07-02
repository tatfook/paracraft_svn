--[[
Title: kids painter help 
Author(s): LiXizhi
Date: 2007-1-15
Desc: a standalone paint brush application.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/ui/kidspainter.lua");
KidsPainter.painter_width = 320;
KidsPainter.imagesize = 256;
KidsPainter.OnCloseCallBack = nil;
KidsPainter.OnSaveCallBack = nil;
KidsPainter.ShowPainter(true);
KidsPainter.LoadFromTexture("Texture/whitedot.png");
-------------------------------------------------------
]]
local L = CommonCtrl.Locale("KidsUI");

if(not KidsPainter) then KidsPainter={}; end
KidsPainter.PainterIsMouseDown = false;
KidsPainter.name = "KidsPainter";
KidsPainter.imagesize = 256;
KidsPainter.scale = 1;
KidsPainter.pen_width = 4;
KidsPainter.pen_minstep = 8; -- how minimum distance between two pixel, usually proportional to pen width.
KidsPainter.painter_width = 320;--320=256*1.25;
KidsPainter.diskTexture = nil;
KidsPainter.session_step=0;
KidsPainter.path = {x={}, y={}};
KidsPainter.pathsize = 0;
KidsPainter.History = {};
KidsPainter.OnCloseCallBack = nil;
KidsPainter.OnSaveCallBack = nil;
KidsPainter.textures = {
	[1] = "Texture/kidui/middle/painter/01.png",
	[2] = "Texture/kidui/middle/painter/02.png",
	[3] = "Texture/kidui/middle/painter/03.png",
	[4] = "Texture/kidui/middle/painter/04.png",
	[5] = "Texture/kidui/middle/painter/05.png",
	[6] = "Texture/kidui/middle/painter/06.png",
}
KidsPainter.palette = {
	[1] = {cx=63, cy=196, color="255 0 0", file="Texture/kidui/middle/painter/color_red.png"},
	[2] = {cx=47, cy=172, color="255 255 0", file="Texture/kidui/middle/painter/color_yellow.png"},
	[3] = {cx=43, cy=144, color="0 0 255",file="Texture/kidui/middle/painter/color_blue.png"},
	[4] = {cx=50, cy=117, color="0 255 0",file="Texture/kidui/middle/painter/color_green.png"},
	[5] = {cx=70, cy=92,  color="100 0 100",file="Texture/kidui/middle/painter/color_purple.png"},
	[6] = {cx=97, cy=78,  color="0 255 255",file="Texture/kidui/middle/painter/color_cyan.png"},
	[7] = {cx=125, cy=78, color="0 0 0",file="Texture/kidui/middle/painter/color_black.png"},
	[8] = {cx=152, cy=82, color="255 255 255",file="Texture/kidui/middle/painter/color_white.png"},
}
			
-- how to smooth the pen path {[0]=1} will use the original one.
KidsPainter.genericfilter = {
	[-2] = 0.1,
	[-1] = 0.2,
	[0] = 0.4,
	[1] = 0.2,
	[2] = 0.1,
}; 

-- show or hide the kids painter control
-- @param alignment, left, top: can be nil. default to "_lt",0,0
function KidsPainter.ShowPainter(bShow, alignment, left, top)
	local _this,_parent;
	local _this = ParaUI.GetUIObject("KidsPainterCtl");
	if(_this:IsValid() == false) then 
		if(bShow == false) then return	end
		bShow = true;
		local dc = ParaUI.CreateGraphics("KidsPainter");
		if(dc:IsValid())then
			-- set render target
			local rendertarget = ParaAsset.LoadRenderTarget("my_canvas"..KidsPainter.imagesize,KidsPainter.imagesize,KidsPainter.imagesize);	
			dc:SetRenderTarget(rendertarget);
			
			-- create a default red pen
			KidsPainter.SetCurrentPen("255 0 0", KidsPainter.pen_width, "");
			
			-- test disk image
			KidsPainter.LoadFromTexture("Texture/whitedot.png");
			-- some other test here
			--dc:Clear("0 0 255");
			--dc:DrawLine(0,0, 100, 100);
			--dc:DrawPoint(30,60);

			dc.invalidate = true;
	
			if(not alignment) then alignment = "_lt" end
			if(not left) then left = 0 end
			if(not top) then top = 0 end
			
			local width, height;
			-- container	
			_this=ParaUI.CreateUIObject("container","KidsPainterCtl", alignment,left,top,680,572);
			_this.background="Texture/whitedot.png";
			_guihelper.SetUIColor(_this, "255 255 200 50");
			_this:SetTopLevel(true);
			_this:AttachToRoot();
			_parent = _this;
			
			-- container for painter event handling
			_this=ParaUI.CreateUIObject("container","KidsPainter_cont", "_lt",170,0,KidsPainter.painter_width,KidsPainter.painter_width);
			_parent:AddChild(_this);
			_this:SetBGImage(rendertarget);
			_this.onmousedown = ";KidsPainter.OnMouseDown();"
			_this.onmouseup = ";KidsPainter.OnMouseUp();"
			_this.onmousemove = ";KidsPainter.OnMouseMove();"
			
			-- pannel
			_this=ParaUI.CreateUIObject("container","c", "_lb",0,-256,680,256);
			_this.background="Texture/kidui/middle/painter/bg.png;0 0 680 256";
			_parent:AddChild(_this);
			_this:BringToBack();
			_parent = _this;
			
			-- scale up
			left, top,width, height = 275, 178, 38, 42;
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, top,width, height);
			_this.background="Texture/kidui/middle/painter/scaleup.png;0 0 38 42";
			_this.onclick = ";KidsPainter.ScalePainter(1.25);";
			--_this.animstyle = 11;
			_parent:AddChild(_this);
			left = left+width+2;
			
			-- scale down
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, top,width, height);
			_this.background="Texture/kidui/middle/painter/scaledown.png;0 0 38 42";
			_this.onclick = ";KidsPainter.ScalePainter(0.8);";
			_parent:AddChild(_this);
			--_this.animstyle = 11;
			left = left+width+2;
			
			-- undo
			top,width, height = 190, 43,27;
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, top,width, height);
			_this.background="Texture/kidui/middle/painter/undo.png;0 0 43 27";
			_this.onclick = ";KidsPainter.Undo();";
			_parent:AddChild(_this);
			--_this.animstyle = 11;
			left = left+width+2;
			
			-- reset
			top,width, height = 178, 56,39;
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, top,width, height);
			_this.background="Texture/kidui/middle/painter/reset.png;0 0 56 39";
			_this.onclick = ";KidsPainter.Reset();";
			_parent:AddChild(_this);
			--_this.animstyle = 11;
			left = left+width+2;
			
			-- save
			top,width, height = 178, 36,36;
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, top,width, height);
			_this.background="Texture/kidui/right/btn_save.png";
			_this.onclick = [[;KidsPainter.OnClickSave();]];
			_parent:AddChild(_this);
			--_this.animstyle = 11;
			
			-- pen eraser 
			left, top,width, height = 505,205, 50,41;
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, top,width, height);
			_this.background="Texture/kidui/middle/painter/erase.png;0 0 50 41";
			_this.onclick = ";KidsPainter.SelectEraser();";
			_parent:AddChild(_this);
			_this.animstyle = 11;
			
			-- pen size: 1
			local baseline = 128
			left = 575;
			width, height = 19,119;
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, baseline-height,width, height);
			_this.background="Texture/kidui/middle/painter/pen1.png;0 0 19 119";
			_this.onclick = ";KidsPainter.SetCurrentPen(nil, 10, nil);";
			_parent:AddChild(_this);
			_this.animstyle = 11;
			left = left+width;
			
			-- pen size: 2
			width, height = 13,99;
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, baseline-height,width, height);
			_this.background="Texture/kidui/middle/painter/pen2.png;0 0 13 99";
			_this.onclick = ";KidsPainter.SetCurrentPen(nil, 6, nil);";
			_parent:AddChild(_this);
			_this.animstyle = 11;
			left = left+width;
			
			-- pen size: 3
			width, height = 11,78;
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, baseline-height,width, height);
			_this.background="Texture/kidui/middle/painter/pen3.png;0 0 11 78";
			_this.onclick = ";KidsPainter.SetCurrentPen(nil, 3, nil);";
			_parent:AddChild(_this);
			_this.animstyle = 11;
			left = left+width;
			
			-- pen size: 4
			width, height = 11,66;
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, baseline-height,width, height);
			_this.background="Texture/kidui/middle/painter/pen4.png;0 0 11 66";
			_this.onclick = ";KidsPainter.SetCurrentPen(nil, 1, nil);";
			_parent:AddChild(_this);
			_this.animstyle = 11;
			left = left+width;
			
			-- texture pens
			left, top,width, height = 113,114, 36,52;
			local nRows = 2;
			local nCols = 3;
			for i=1, nRows do
				left=113;
				for j=1, nCols do
					local nIndex = (i-1)*nCols+j;
					_this=ParaUI.CreateUIObject("button","b","_lt",left,top,width, height);
					_parent:AddChild(_this);
					_this.background=KidsPainter.textures[nIndex];
					_this.onclick=string.format([[;KidsPainter.OnTextureClick(%s);]],nIndex);
					left=left+width;
				end
				top=top+height;
			end
			
			-- color palette
			width = 24;
			local radius = 11;
			local i;
			for i=1,8 do
				_this=ParaUI.CreateUIObject("button","b", "_lt", KidsPainter.palette[i].cx-radius, KidsPainter.palette[i].cy-radius, width, width);
				_this.onclick = string.format([[;KidsPainter.SetCurrentPen("%s", nil, "");]], KidsPainter.palette[i].color);
				_this.background=KidsPainter.palette[i].file;
				_parent:AddChild(_this);
			end
			
			-- exit button
			_this=ParaUI.CreateUIObject("button","b", "_lt",600, 210, 36, 36);
			_this.onclick = ";KidsPainter.OnClose();"
			_this.tooltip = L"Close";
			_this.background="Texture/player/close.png";
			_parent:AddChild(_this);
			
			KidsPainter.scale = KidsPainter.painter_width/rendertarget:GetWidth();
			KidsPainter.PainterIsMouseDown = false;
			KidsPainter.last_x = nil;
			KidsPainter.last_y = nil;
		end	
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
	end	
	if(bShow) then
		KidsUI.PushState({name = "KidsPainter", OnEscKey = KidsPainter.OnClose});
		_this:SetTopLevel(true);
	else
		KidsUI.PopState("KidsPainter");
	end
end

function KidsPainter.OnClose()
	KidsPainter.ShowPainter(false);
	
	if(KidsPainter.OnCloseCallBack~=nil) then
		KidsPainter.OnCloseCallBack();
	end
end

function KidsPainter.OnTextureClick(nIndex)
	local tex = KidsPainter.textures[nIndex];
	if(tex~=nil) then
		KidsPainter.SetCurrentPen("255 255 255", nil, tex);
	end
end

function KidsPainter.PushHistory(value)
	local n = table.getn(KidsPainter.History);
	if(not n) then n=0 end
	KidsPainter.History[n+1] = value;
end

function KidsPainter.PopHistory()
	local n = table.getn(KidsPainter.History);
	local v = KidsPainter.History[n];
	if(not v) then
		v = 0;
	else
		KidsPainter.History[n] = nil;
	end
	return v;
end

function KidsPainter.Undo()
	local dc = ParaUI.CreateGraphics("KidsPainter");
	if(dc:IsValid())then
		local count = KidsPainter.PopHistory();
		dc:Undo(count);
		dc.invalidate = true;
	end
end

-- select a eraser
function KidsPainter.SelectEraser()
	local dc = ParaUI.CreateGraphics("KidsPainter");
	if(dc:IsValid())then
		local bg = dc:GetDiskTexture();
		if(bg:IsValid()) then
			KidsPainter.SetCurrentPen("255 255 255", 10, bg:GetKeyName());
		else
			KidsPainter.SetCurrentPen("255 255 255", 10, nil);
		end
	end
end

-- set the painter width to scale times the current size.
function KidsPainter.ScalePainter(scale)
	local width = KidsPainter.painter_width*scale;
	if(width > 400) then return end
	if(width < 200) then return end
	local temp = ParaUI.GetUIObject("KidsPainter_cont");
	if(temp:IsValid()==true) then
		if( math.abs(temp.width-width)>1) then
			temp.width = width;
			temp.height = width;
			
			KidsPainter.painter_width = width;
			
			local dc = ParaUI.CreateGraphics("KidsPainter");
			if(dc:IsValid())then
				local rendertarget = dc:GetRenderTarget();
				if(rendertarget:IsValid()==true) then
					KidsPainter.scale = KidsPainter.painter_width/rendertarget:GetWidth();
				end	
			end	
		end
	end
end

-- load the painter with a given image
function KidsPainter.LoadFromTexture(filename)
	local dc = ParaUI.CreateGraphics("KidsPainter");
	if(dc:IsValid())then
		local diskTexture = ParaAsset.LoadTexture("",filename, 1);
		dc:LoadFromTexture(diskTexture);
		KidsPainter.History = {};
	end
end

function KidsPainter.GetRenderTarget()
	local dc = ParaUI.CreateGraphics("KidsPainter");
	if(dc:IsValid())then
		return dc:GetRenderTarget();
	end
end

function KidsPainter.GetDiskTexture()
	local dc = ParaUI.CreateGraphics("KidsPainter");
	if(dc:IsValid())then
		return dc:GetDiskTexture();
	end
end

function KidsPainter.GetDiskTextureFileName()
	local dc = ParaUI.CreateGraphics("KidsPainter");
	if(dc:IsValid())then
		return dc:GetDiskTexture():GetKeyName();
	end
	return ""
end

function KidsPainter.Reset()
	local dc = ParaUI.CreateGraphics("KidsPainter");
	if(dc:IsValid())then
		dc:Reset();
		KidsPainter.History = {};
	end
end

-- called when user click the save button
function KidsPainter.OnClickSave()
	-- invoke the callback, otherwise use the default save function.
	if(KidsPainter.OnSaveCallBack~=nil) then
		KidsPainter.OnSaveCallBack();
	else
		KidsPainter.SaveAs();
	end
end

-- save file to disk. undo operations will not be valid any more.
function KidsPainter.SaveAs(filename)
	local dc = ParaUI.CreateGraphics("KidsPainter");
	if(dc:IsValid())then
		if(filename==nil) then
			local bg = dc:GetDiskTexture();
			if(bg:IsValid()==true) then
				filename = bg:GetKeyName();
			else
				filename = "temp/KidsPainterTemp.jpg";
			end
		end
		if(dc:SaveAs(filename)==true) then
			KidsPainter.ResetPath();
			KidsPainter.History = {};
			return true;
		else
			return ("kids painter unable to save file "..filename.."\r\n");	
		end	
	end
end

-- set the current pen
-- all parameters can be nil
-- @param color: e.g."255 0 0"
-- @param width: in pixel such as 1,4,8
-- @param texture: if this is "", no texture will be used.
function KidsPainter.SetCurrentPen(color, width, texture)
	local dc = ParaUI.CreateGraphics("KidsPainter");
	if(dc:IsValid())then
		local pen = dc:CreatePen("mypen");
		if(width~=nil) then
			pen.width = width;
			KidsPainter.pen_width = width;
			KidsPainter.pen_minstep = width*2; -- the step is automatically adjusted according to the pen size.
		end	
		if(color~=nil) then
			pen.color = color;
		end	
		if(texture~=nil) then
			pen.texture = texture
		end	
		dc:SetCurrentPen(pen);
	end
end

-- get the image position from the screen space mouse position
function KidsPainter.GetImagePosition(screen_x, screen_y)
	local temp = ParaUI.GetUIObject("KidsPainter_cont");
	if(temp:IsValid()==true) then
		-- get relative click position in control
		local x,y = temp:GetAbsPosition();
		x,y = screen_x - x, screen_y - y;
		x=x/KidsPainter.scale;
		y=y/KidsPainter.scale;
		return x,y;
	end	
end

function KidsPainter.ResetPath()
	KidsPainter.pathsize = 0;
end

function KidsPainter.AddPointToPath(x,y)
	KidsPainter.pathsize = KidsPainter.pathsize+1;
	KidsPainter.path.x[KidsPainter.pathsize] = x;
	KidsPainter.path.y[KidsPainter.pathsize] = y;
end	

function KidsPainter.GetPathPointAt(index)
	local x,y;
	if(index<=0) then
		x,y = KidsPainter.path.x[1], KidsPainter.path.y[1];
	elseif(index>=KidsPainter.pathsize)then	
		x,y = KidsPainter.path.x[KidsPainter.pathsize], KidsPainter.path.y[KidsPainter.pathsize];
	else
		x,y = KidsPainter.path.x[index], KidsPainter.path.y[index];
	end
	return x,y;
end

-- filterweight[0] = 0.4, filterweight[1] = 0.4
function KidsPainter.SmoothPath(filterweight)
	if(not filterweight) then
		filterweight = KidsPainter.genericfilter;
	end
	local i,k,weight, value_x, value_y, temp_x, temp_y;
	for i=1,KidsPainter.pathsize do
		value_x,value_y = 0,0;
		for k,weight in pairs(filterweight) do
			temp_x, temp_y = KidsPainter.GetPathPointAt(i+k);
			value_x = value_x + temp_x*weight;
			value_y = value_y + temp_y*weight;
		end
		KidsPainter.path.x[i] = value_x;
		KidsPainter.path.y[i] = value_y;
	end
end

function KidsPainter.OnMouseDown()
	local dc = ParaUI.GetGraphics("KidsPainter");
	if(dc:IsValid()==true) then
		KidsPainter.PainterIsMouseDown = false;
		local x,y = KidsPainter.GetImagePosition(mouse_x, mouse_y);
		KidsPainter.last_x = x;
		KidsPainter.last_y = y;
		KidsPainter.session_step = 0;
		KidsPainter.ResetPath();
		KidsPainter.AddPointToPath(x,y)
	end
end

function KidsPainter.OnMouseMove()
	if(not KidsPainter.last_x) then
		return
	end
	local dc = ParaUI.GetGraphics("KidsPainter");
	if(dc:IsValid()==true) then
		KidsPainter.PainterIsMouseDown = false;
		local x,y = KidsPainter.GetImagePosition(mouse_x, mouse_y);
		if((math.abs(KidsPainter.last_x-x)+math.abs(KidsPainter.last_y-y))> KidsPainter.pen_minstep) then
			dc:DrawLine(KidsPainter.last_x, KidsPainter.last_y, x, y);
			KidsPainter.session_step = KidsPainter.session_step +2;
			dc.invalidate = true;
			KidsPainter.last_x = x;
			KidsPainter.last_y = y;
			KidsPainter.AddPointToPath(x,y);
		end
	end
end

function KidsPainter.OnMouseUp()
	if(not KidsPainter.last_x) then
		return
	end
	local dc = ParaUI.GetGraphics("KidsPainter");
	if(dc:IsValid()==true) then
		KidsPainter.PainterIsMouseDown = false;
		local x,y = KidsPainter.GetImagePosition(mouse_x, mouse_y);
		KidsPainter.last_x = x;
		KidsPainter.last_y = y;
		KidsPainter.AddPointToPath(x,y);
			
		if(KidsPainter.session_step>0)then
			dc:Undo(KidsPainter.session_step);
			-- smooth the path.
			KidsPainter.SmoothPath();
			local i;
			for i=1,KidsPainter.pathsize-1 do
				dc:DrawLine(KidsPainter.path.x[i], KidsPainter.path.y[i], KidsPainter.path.x[i+1], KidsPainter.path.y[i+1]);
			end
			KidsPainter.PushHistory((KidsPainter.pathsize-1)*2);
		else
			if((math.abs(KidsPainter.last_x-x)+math.abs(KidsPainter.last_y-y))> KidsPainter.pen_width) then
				dc:DrawLine(KidsPainter.last_x, KidsPainter.last_y, x, y);
				KidsPainter.PushHistory(2);
			else
				dc:DrawLine(x, y, x, y);
				KidsPainter.PushHistory(1);
			end
		end
		
		dc.invalidate = true;
	end
	KidsPainter.last_x = nil;
	KidsPainter.last_y = nil;
end



