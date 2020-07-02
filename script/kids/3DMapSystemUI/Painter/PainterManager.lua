--[[
Author(s): Leio, revised 2008.1.29 by LiXizhi, revised 2008.6.15 by LiXizhi
Date: 2007/11/7
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Painter/PainterManager.lua");
------------------------------------------------------------
PainterManager.painter_width = 320;
PainterManager.painter_height = 320;
PainterManager.imagesize_w = 256;
PainterManager.imagesize_h = 256;
PainterManager.OnCloseCallBack = nil;
PainterManager.OnSaveCallBack = nil;
PainterManager.ShowPainter(true,"_lt",0,0, _parent);
PainterManager.LoadFromTexture("Texture/whitedot.png");
]]

local PainterManager = {}
commonlib.setfield("Map3DSystem.UI.PainterManager", PainterManager);
if(not Map3DSystem.UI.PainterManager) then Map3DSystem.UI.PainterManager={}; end
PainterManager.PainterIsMouseDown = false;
PainterManager.name = "Map3DSystem.UI.PainterManager";
PainterManager.imagesize_w = 256;
PainterManager.imagesize_h = 256;
PainterManager.scale = 1;
PainterManager.pen_width = 4;
PainterManager.pen_minstep = 8; -- how minimum distance between two pixel, usually proportional to pen width.
PainterManager.painter_width = 320;--320=256*1.25;
PainterManager.painter_height = 320;
PainterManager.diskTexture = nil;
PainterManager.session_step=0;
PainterManager.path = {x={}, y={}};
PainterManager.pathsize = 0;
PainterManager.History = {};
PainterManager.OnCloseCallBack = nil;
PainterManager.OnSaveCallBack = nil;
PainterManager.canvas_max_w=783+1;
PainterManager.canvas_max_h=478+1;
PainterManager.canvas_min_w=100;
PainterManager.canvas_min_h=100;

PainterManager.textures = {
	[1] = "Texture/3dMapSystem/Painter/01.png",
	[2] = "Texture/3dMapSystem/Painter/02.png",
	[3] = "Texture/3dMapSystem/Painter/03.png",
	[4] = "Texture/3dMapSystem/Painter/04.png",
	[5] = "Texture/3dMapSystem/Painter/05.png",
	[6] = "Texture/3dMapSystem/Painter/06.png",
}
PainterManager.palette = {
	[1] = {color="255 0 0 64", file="Texture/3dMapSystem/Painter/color_red.png"},
	[2] = {color="255 255 0", file="Texture/3dMapSystem/Painter/color_yellow.png"},
	[3] = {color="0 0 255",file="Texture/3dMapSystem/Painter/color_blue.png"},
	[4] = {color="0 255 0",file="Texture/3dMapSystem/Painter/color_green.png"},
	[5] = {color="100 0 100",file="Texture/3dMapSystem/Painter/color_purple.png"},
	[6] = {color="0 255 255",file="Texture/3dMapSystem/Painter/color_cyan.png"},
	[7] = {color="0 0 0",file="Texture/3dMapSystem/Painter/color_black.png"},
	[8] = {color="255 255 255 0",file="Texture/3dMapSystem/Painter/color_white.png"},
}
			
-- how to smooth the pen path {[0]=1} will use the original one.
PainterManager.genericfilter = {
	[-2] = 0.1,
	[-1] = 0.2,
	[0] = 0.4,
	[1] = 0.2,
	[2] = 0.1,
}; 

-- show or hide the kids painter control
-- @param alignment, left, top: can be nil. default to "_lt",0,0
function PainterManager.ShowPainter(bShow, alignment, left, top,_parentWnd)
	local _this,_parent;
	local _this = ParaUI.GetUIObject("KidsPainterCtl");
	if(_this:IsValid() == false) then 
		if(bShow == false) then return	end
		bShow = true;
		local dc = ParaUI.CreateGraphics("Map3DSystem.UI.PainterManager");
		if(dc:IsValid())then
			-- set render target
			local rendertarget = ParaAsset.LoadRenderTarget("my_canvas"..PainterManager.imagesize_w,PainterManager.imagesize_w,PainterManager.imagesize_h);	
			dc:SetRenderTarget(rendertarget);
			
			-- create a default red pen
			PainterManager.SetCurrentPen("255 0 0", PainterManager.pen_width, "");
			
			-- test disk image
			-- PainterManager.LoadFromTexture("Texture/whitedot.png");
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
			if(_parentWnd~=nil) then
				_this=ParaUI.CreateUIObject("container","KidsPainterCtl", "_fi", 5,0,5,5);
				_parentWnd:AddChild(_this);
				_this.background = "";
			else	
				_this=ParaUI.CreateUIObject("container","KidsPainterCtl", alignment,left,top,320,385);
				_this:SetTopLevel(true);
				_this:AttachToRoot();
			end	
			
			_parent = _this;
			local _,_, width = _parent:GetAbsPosition();
			PainterManager.painter_width = width;
			PainterManager.painter_height = width;
			
			-- container for painter event handling
			_this=ParaUI.CreateUIObject("container","KidsPainter_cont", "_lt",0,0,PainterManager.painter_width,PainterManager.painter_height);
			_parent:AddChild(_this);
			_this:SetBGImage(rendertarget);
			-- use point filtering by default. 
			_this:GetAttributeObject():SetField("UsePointTextureFiltering", true);
			
			--_this.scrollable=true;
			_this.onmousedown = ";Map3DSystem.UI.PainterManager.OnMouseDown();"
			_this.onmouseup = ";Map3DSystem.UI.PainterManager.OnMouseUp();"
			_this.onmousemove = ";Map3DSystem.UI.PainterManager.OnMouseMove();"
			
			----------------------------------------------------
			-- tool pannel
			----------------------------------------------------
			_this=ParaUI.CreateUIObject("container","bar_bg", "_fi",0,320,0,0);
			_this.background="";
			_parent:AddChild(_this);
			_this:BringToBack();
			_parent = _this;
			
			left, top,width, height = 184, 2, 32, 32;
			-- reset
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, top,width, height);
			_this.background="Texture/3dMapSystem/Painter/reset.png;0 0 32 32";
			_this.tooltip="重置为原始案";
			_this.onclick = ";Map3DSystem.UI.PainterManager.Reset();";
			_parent:AddChild(_this);
			--_this.animstyle = 11;
			left = left+width;
			
			-- pen eraser 
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, top,width, height);
			_this.background="Texture/3dMapSystem/Painter/erase.png;0 0 32 32";
			_this.tooltip="橡皮";
			_this.onclick = ";Map3DSystem.UI.PainterManager.SelectEraser();";
			_parent:AddChild(_this);
			--_this.animstyle = 11;
			left = left+width;
			
			-- undo
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, top,width, height);
			_this.background="Texture/3dMapSystem/Painter/undo.png;0 0 32 32";
			_this.tooltip="撤销";
			_this.onclick = ";Map3DSystem.UI.PainterManager.Undo();";
			_parent:AddChild(_this);
			--_this.animstyle = 11;
			left = left+width;
			
			
			-- save
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, top,width, height);
			_this.tooltip="保存";
			_this.background="Texture/3dMapSystem/Painter/save.png;0 0 32 32";
			_this.onclick = [[;Map3DSystem.UI.PainterManager.OnClickSave();]];
			_parent:AddChild(_this);
			--_this.animstyle = 11;
			
			
			local max_pen_w_h=21
			-- pen size: 1
			local baseline = 39
			left = 184;
			width, height = 16,16;
			
			top=(max_pen_w_h-height)/2+baseline;
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, top,width, height);
			_this.background="Texture/3dMapSystem/Painter/pen1.png";
			_this.onclick = ";Map3DSystem.UI.PainterManager.SetCurrentPen(nil, 1, nil);";
			_parent:AddChild(_this);
			--_this.animstyle = 11;
			left = left+width;
			
			-- pen size: 2
			--width, height = 10,10;
			top=(max_pen_w_h-height)/2+baseline;
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, top,width, height);
			_this.background="Texture/3dMapSystem/Painter/pen2.png";
			_this.onclick = ";Map3DSystem.UI.PainterManager.SetCurrentPen(nil, 3, nil);";
			_parent:AddChild(_this);
			--_this.animstyle = 11;
			left = left+width;
			
			-- pen size: 3
			--width, height = 14,14;
			top=(max_pen_w_h-height)/2+baseline;
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, top,width, height);
			_this.background="Texture/3dMapSystem/Painter/pen3.png";
			_this.onclick = ";Map3DSystem.UI.PainterManager.SetCurrentPen(nil, 6, nil);";
			_parent:AddChild(_this);
			--_this.animstyle = 11;
			left = left+width;
			
			-- pen size: 4
			--width, height = 17,17;
			top=(max_pen_w_h-height)/2+baseline;
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, top,width, height);
			_this.background="Texture/3dMapSystem/Painter/pen4.png";
			_this.onclick = ";Map3DSystem.UI.PainterManager.SetCurrentPen(nil, 9, nil);";
			_parent:AddChild(_this);
			--_this.animstyle = 11;
			left = left+width;
			
			
			-- pen size: 5
			--width, height = 21,21;
			top=(max_pen_w_h-height)/2+baseline;
			_this=ParaUI.CreateUIObject("button","b", "_lt",left, top,width, height);
			_this.background="Texture/3dMapSystem/Painter/pen5.png";
			_this.onclick = ";Map3DSystem.UI.PainterManager.SetCurrentPen(nil, 12, nil);";
			_parent:AddChild(_this);
			--_this.animstyle = 11;
			left = left+width;
			
			-- texture pens
			left, top,width, height = 0,2, 32,32;
			local nRows = 2;
			local nCols = 3;
			for i=1, nRows do
				left=83;
				for j=1, nCols do
					local nIndex = (i-1)*nCols+j;
					_this=ParaUI.CreateUIObject("button","b","_lt",left,top,width, height);
					_parent:AddChild(_this);
					_this.background=PainterManager.textures[nIndex];
					_this.onclick=string.format([[;Map3DSystem.UI.PainterManager.OnTextureClick(%s);]],nIndex);
					left=left+width;
				end
				top=top+height;
			end
			
			-- color palette
			left, top,width, height = 0,2, 20,20;
			local nRows = 2;
			local nCols = 4;
			for i=1, nRows do
				left=2;
				for j=1, nCols do
					local nIndex = (i-1)*nCols+j;
					_this=ParaUI.CreateUIObject("button","b","_lt",left,top,width, height);
					_parent:AddChild(_this);
					_this.onclick = string.format([[;Map3DSystem.UI.PainterManager.SetCurrentPen("%s", nil, "");]], PainterManager.palette[nIndex].color);
					_this.background=PainterManager.palette[nIndex].file;
					left=left+width;
				end
				top=top+height;
			end
		
			PainterManager.scale = PainterManager.painter_width/rendertarget:GetWidth();
			PainterManager.PainterIsMouseDown = false;
			PainterManager.last_x = nil;
			PainterManager.last_y = nil;
		end	
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
	end	
end

-- this function should be called when window is closed. 
function Map3DSystem.UI.PainterManager.OnClose()
	ParaUI.Destroy("KidsPainterCtl");
	Map3DSystem.UI.PainterManager.ShowPainter(false);
	
	if(Map3DSystem.UI.PainterManager.OnCloseCallBack~=nil) then
		Map3DSystem.UI.PainterManager.OnCloseCallBack();
	end
end

function PainterManager.OnTextureClick(nIndex)
	local tex = PainterManager.textures[nIndex];
	if(tex~=nil) then
		PainterManager.SetCurrentPen("255 255 255", nil, tex);
	end
end

function PainterManager.PushHistory(value)
	local n = table.getn(PainterManager.History);
	if(not n) then n=0 end
	PainterManager.History[n+1] = value;
end

function PainterManager.PopHistory()
	local n = table.getn(PainterManager.History);
	local v = PainterManager.History[n];
	if(not v) then
		v = 0;
	else
		PainterManager.History[n] = nil;
	end
	return v;
end

function PainterManager.Undo()
	local dc = ParaUI.CreateGraphics("Map3DSystem.UI.PainterManager");
	if(dc:IsValid())then
		local count = PainterManager.PopHistory();
		dc:Undo(count);
		dc.invalidate = true;
	end
end

-- select a eraser
function PainterManager.SelectEraser()
	local dc = ParaUI.CreateGraphics("Map3DSystem.UI.PainterManager");
	if(dc:IsValid())then
		local bg = dc:GetDiskTexture();
		if(bg:IsValid()) then
			PainterManager.SetCurrentPen("255 255 255", 10, bg:GetKeyName());
		else
			PainterManager.SetCurrentPen("255 255 255", 10, nil);
		end
	end
	--[[
	local _this = ParaUI.GetUIObject("KidsPainter_cont");
	local texture = _this:GetTexture("background");
	texture.rect = "0 0 100 100";
	]]
	
end

-- set the painter width to scale times the current size.
function PainterManager.ScalePainter(scale)
	local width = PainterManager.painter_width*scale;
	local height=PainterManager.painter_height*scale;
	
	if(width >PainterManager.canvas_max_w) then  return end
	if(width <PainterManager.canvas_min_w) then return end
	if(height > PainterManager.canvas_max_h) then return end
	if(height < PainterManager.canvas_min_h) then return end
	local temp = ParaUI.GetUIObject("KidsPainter_cont");
	if(temp:IsValid()==true) then
		if( math.abs(temp.width-width)>1) then
			temp.width = width;
			temp.height = height;
			
			PainterManager.painter_width = width;
			PainterManager.painter_height = height;
			
			local dc = ParaUI.CreateGraphics("Map3DSystem.UI.PainterManager");
			if(dc:IsValid())then
				local rendertarget = dc:GetRenderTarget();
				if(rendertarget:IsValid()==true) then
					PainterManager.scale = PainterManager.painter_width/rendertarget:GetWidth();
				end	
			end	
		end
	end
end

-- load the painter with a given image
function PainterManager.LoadFromTexture(filename)
	local dc = ParaUI.CreateGraphics("Map3DSystem.UI.PainterManager");
	if(dc:IsValid())then
		local diskTexture = ParaAsset.LoadTexture("",filename, 1);
		dc:LoadFromTexture(diskTexture);
		PainterManager.History = {};
	end
end

function PainterManager.GetRenderTarget()
	local dc = ParaUI.CreateGraphics("Map3DSystem.UI.PainterManager");
	if(dc:IsValid())then
		return dc:GetRenderTarget();
	end
end

function PainterManager.GetDiskTexture()
	local dc = ParaUI.CreateGraphics("Map3DSystem.UI.PainterManager");
	if(dc:IsValid())then
		return dc:GetDiskTexture();
	end
end

function PainterManager.GetDiskTextureFileName()
	local dc = ParaUI.CreateGraphics("Map3DSystem.UI.PainterManager");
	if(dc:IsValid())then
		return dc:GetDiskTexture():GetKeyName();
	end
	return ""
end

function PainterManager.Reset()
	local dc = ParaUI.CreateGraphics("Map3DSystem.UI.PainterManager");
	if(dc:IsValid())then
		dc:Reset();
		PainterManager.History = {};
	end
end

-- called when user click the save button
function PainterManager.OnClickSave()
	-- invoke the callback, otherwise use the default save function.
	if(PainterManager.OnSaveCallBack~=nil) then
		PainterManager.OnSaveCallBack();
	else
		-- ask the user whether to save file.
		local filename;
		local dc = ParaUI.CreateGraphics("Map3DSystem.UI.PainterManager");
		if(dc:IsValid())then
			if(filename==nil) then
				local bg = dc:GetDiskTexture();
				if(bg:IsValid()==true) then
					filename = bg:GetKeyName();
				else
					filename = "temp/KidsPainterTemp.jpg";
				end
			end
		end	
		_guihelper.MessageBox(string.format("您确定要保存到:%s ?", filename), function()
			local res = PainterManager.SaveAs(filename);
			if(res ~= true) then
				_guihelper.MessageBox(string.format("无法保存:%s, 可能文件为只读的或您没有权限。", filename));
			end
		end);
	end
end

-- save file to disk. undo operations will not be valid any more.
function PainterManager.SaveAs(filename)
	local dc = ParaUI.CreateGraphics("Map3DSystem.UI.PainterManager");
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
			PainterManager.ResetPath();
			PainterManager.History = {};
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
function PainterManager.SetCurrentPen(color, width, texture)
	local dc = ParaUI.CreateGraphics("Map3DSystem.UI.PainterManager");
	if(dc:IsValid())then
		local pen = dc:CreatePen("mypen");
		if(width~=nil) then
			pen.width = width;
			PainterManager.pen_width = width;
			PainterManager.pen_minstep = width*2; -- the step is automatically adjusted according to the pen size.
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
function PainterManager.GetImagePosition(screen_x, screen_y)
	local temp = ParaUI.GetUIObject("KidsPainter_cont");
	if(temp:IsValid()==true) then
		-- get relative click position in control
		local x,y = temp:GetAbsPosition();
		x,y = screen_x - x, screen_y - y;
		x=x/PainterManager.scale;
		y=y/PainterManager.scale;
		return x,y;
	end	
end

function PainterManager.ResetPath()
	PainterManager.pathsize = 0;
end

function PainterManager.AddPointToPath(x,y)
	PainterManager.pathsize = PainterManager.pathsize+1;
	PainterManager.path.x[PainterManager.pathsize] = x;
	PainterManager.path.y[PainterManager.pathsize] = y;
end	

function PainterManager.GetPathPointAt(index)
	local x,y;
	if(index<=0) then
		x,y = PainterManager.path.x[1], PainterManager.path.y[1];
	elseif(index>=PainterManager.pathsize)then	
		x,y = PainterManager.path.x[PainterManager.pathsize], PainterManager.path.y[PainterManager.pathsize];
	else
		x,y = PainterManager.path.x[index], PainterManager.path.y[index];
	end
	return x,y;
end

-- filterweight[0] = 0.4, filterweight[1] = 0.4
function PainterManager.SmoothPath(filterweight)
	if(not filterweight) then
		filterweight = PainterManager.genericfilter;
	end
	local i,k,weight, value_x, value_y, temp_x, temp_y;
	for i=1,PainterManager.pathsize do
		value_x,value_y = 0,0;
		for k,weight in pairs(filterweight) do
			temp_x, temp_y = PainterManager.GetPathPointAt(i+k);
			value_x = value_x + temp_x*weight;
			value_y = value_y + temp_y*weight;
		end
		PainterManager.path.x[i] = value_x;
		PainterManager.path.y[i] = value_y;
	end
end

function PainterManager.OnMouseDown()
	local dc = ParaUI.GetGraphics("Map3DSystem.UI.PainterManager");
	if(dc:IsValid()==true) then
		PainterManager.PainterIsMouseDown = false;
		local x,y = PainterManager.GetImagePosition(mouse_x, mouse_y);
		PainterManager.last_x = x;
		PainterManager.last_y = y;
		PainterManager.session_step = 0;
		PainterManager.ResetPath();
		PainterManager.AddPointToPath(x,y)
	end
end

function PainterManager.OnMouseMove()
	if(not PainterManager.last_x) then
		return
	end
	local dc = ParaUI.GetGraphics("Map3DSystem.UI.PainterManager");
	if(dc:IsValid()==true) then
		PainterManager.PainterIsMouseDown = false;
		local x,y = PainterManager.GetImagePosition(mouse_x, mouse_y);
		if((math.abs(PainterManager.last_x-x)+math.abs(PainterManager.last_y-y))> PainterManager.pen_minstep) then
			dc:DrawLine(PainterManager.last_x, PainterManager.last_y, x, y);
			PainterManager.session_step = PainterManager.session_step +2;
			dc.invalidate = true;
			PainterManager.last_x = x;
			PainterManager.last_y = y;
			PainterManager.AddPointToPath(x,y);
		end
	end
end

function PainterManager.OnMouseUp()
	if(not PainterManager.last_x) then
		return
	end
	local dc = ParaUI.GetGraphics("Map3DSystem.UI.PainterManager");
	if(dc:IsValid()==true) then
		PainterManager.PainterIsMouseDown = false;
		local x,y = PainterManager.GetImagePosition(mouse_x, mouse_y);
		PainterManager.last_x = x;
		PainterManager.last_y = y;
		PainterManager.AddPointToPath(x,y);
			
		if(PainterManager.session_step>0)then
			dc:Undo(PainterManager.session_step);
			-- smooth the path.
			PainterManager.SmoothPath();
			local i;
			for i=1,PainterManager.pathsize-1 do
				dc:DrawLine(PainterManager.path.x[i], PainterManager.path.y[i], PainterManager.path.x[i+1], PainterManager.path.y[i+1]);
			end
			PainterManager.PushHistory((PainterManager.pathsize-1)*2);
		else
			if((math.abs(PainterManager.last_x-x)+math.abs(PainterManager.last_y-y))> PainterManager.pen_width) then
				dc:DrawLine(PainterManager.last_x, PainterManager.last_y, x, y);
				PainterManager.PushHistory(2);
			else
				dc:DrawLine(x, y, x, y);
				PainterManager.PushHistory(1);
			end
		end
		
		dc.invalidate = true;
	end
	PainterManager.last_x = nil;
	PainterManager.last_y = nil;
end
function PainterManager.SetWndPosition(width ,height)
	--log("#:"..string.format("%s",width)..":"..string.format("%s",height).."\n");
	local temp = ParaUI.GetUIObject("bar_bg"); 
	temp.x=width-temp.width;		
	temp.y=height-temp.height;
	
	local width = width;
	local height=height-temp.height;
	
	
	local temp = ParaUI.GetUIObject("KidsPainter_cont");
	if(temp:IsValid()==true) then
		if( math.abs(temp.width-width)>1) then
			temp.width = width;
			temp.height = height;
			
			PainterManager.painter_width = width;
			PainterManager.painter_height = height;
			
			local dc = ParaUI.CreateGraphics("Map3DSystem.UI.PainterManager");
			if(dc:IsValid())then
				local rendertarget = dc:GetRenderTarget();
				if(rendertarget:IsValid()==true) then
					PainterManager.scale = PainterManager.painter_width/rendertarget:GetWidth();
				end	
			end	
		end
	end
	
end

function PainterManager.SetCanvasPositionToCenter()
	local _this = ParaUI.GetUIObject("KidsPainter_cont"); 
end
