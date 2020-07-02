
--[[

*****this file is deprecated******


-- common control library
NPL.load("(gl)script/ide/common_control.lua");

if(not MapSystem) then MapSystem = {};end
MapSystem.fovOver2 = math.pi/12;

if(not Map3DCanvas) then Map3DCanvas={}; end
Map3DCanvas.sceneName = "map3D";

Map3DCanvas.isInited = false;
Map3DCanvas.isMouseDown = false;
Map3DCanvas.lastMousePosX = 0;
Map3DCanvas.lastMousePosY = 0;

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function Map3DCanvas.Show(bShow)
	local _this=ParaUI.GetUIObject("Map3DCanvas_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then
			 return;	
		end
		bShow = true;
		Map3DCanvas.Initialization();
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
	end	
end

-- destory the control
function Map3DCanvas.OnDestory()
	ParaUI.Destroy("Map3DCanvas_cont");
end

function Map3DCanvas.Initialization()
	if( Map3DCanvas.isInited)then
		return;
	end
	
	--create 3dmap container;
	local _this,_parent;
	_this=ParaUI.CreateUIObject("container","Map3DCanvas_cont","_lt",0,0,800,800);
	_this.onmouseup = ";Map3DCanvas.OnMouseUp();";
	_this.onmousewheel = ";Map3DCanvas.OnMouseWheel();";
	_this.onmousemove = ";Map3DCanvas.OnMouseMove();";
	_this.onmousedown = ";Map3DCanvas.OnMouseDown();";
	_this.ondoubleclick = ";Map3DCanvas.OnDoubleClick();";
	_this:AttachToRoot();
	_parent = _this;
	
	_this = ParaUI.CreateUIObject("button","btnReset","_lt",50,10,16,16);
	--_this.onclick = ";Map3DCanvas.OnPitch()";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button","btnAddPitch","_lt",70,10,16,16);
	_this.onclick = ";Map3DCanvas.IncreasePitch()";
	_this.tooltip = "Add Pitch"
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button","btnDecreasePitch","_lt",90,10,16,16);
	_this.onclick = ";Map3DCanvas.DecreasePitch()";
	_this.tooltip = "Decrease Pitch"
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button","btnRotateLeft","_lt",110,10,16,16);
	_this.onclick = ";Map3DCanvas.RotateLeft()";
	_this.tooltip = "rotate left"
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button","btnRotateRight","_lt",130,10,16,16);
	_this.onclick = ";Map3DCanvas.RotateRight()";
	_this.tooltip = "rotate right"
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button","btn","_lt",150,10,16,16);
	_this.onclick = "";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button","btnRotateRight","_lt",170,10,16,16);
	_this.onclick = "";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button","btnRotateRight","_lt",190,10,16,16);
	_this.onclick = "";
	_parent:AddChild(_this);
		
	--create the miniSceneGraph
	Map3DCanvas.InitSceneGraph();
	Map3DCanvas.isInited = true;
end

-- create and initialize the map3DCanvas call this only once
function Map3DCanvas.InitSceneGraph()
	if(Map3DCanvas.isInited)then
		return;
	end
	local scene = ParaScene.GetMiniSceneGraph(Map3DCanvas.sceneName);
	scene:Reset();
	scene:SetRenderTargetSize(800,800);
	scene:EnableCamera(true);
	scene:EnableActiveRendering(true);
	
	-- assign the texture to UI
	local tmp = ParaUI.GetUIObject("Map3DCanvas_cont");
	if(tmp:IsValid()) then
		tmp:SetBGImage(scene:GetTexture());
	end
end


-------------------------------------------
--here are codes for mouse event
------------------------------------------
function Map3DCanvas.OnMouseDown()
	Map3DCanvas.lastMousePosX = mouse_x;
	Map3DCanvas.lastMousePosY = mouse_y;
	Map3DCanvas.isMouseDown = true;
end

function Map3DCanvas.OnMouseUp()
	Map3DCanvas.isMouseDown = false;
	local temp = ParaUI.GetUIObject("Map3DCanvas_cont");
	if(not temp:IsValid()) then
		log("error getting control Map3DCanvas.OnMouseUp\n");
		return
	end
	
	--local x,y, width, height = temp:GetAbsPosition();
	--local scene = ParaScene.GetMiniSceneGraph("map3D");
	---- sample code for try to pick a 3D object	
	---- do a mouse: using filter "", it can also be "biped", "mesh", etc
	--local obj = scene:MousePick(mouse_x-x, mouse_y-y, 500, "mesh");
	--if(obj:IsValid()) then
--
	--end
end

function Map3DCanvas.OnMouseMove()
	if( Map3DCanvas.isMouseDown)then
		local dx,dy;
		dx = Map3DCanvas.lastMousePosX - mouse_x;
		dy = Map3DCanvas.lastMousePosY - mouse_y;
		if( math.abs(dx) == 0 and math.abs(dy) == 0)then
				
			return;
		end
		Map3DCanvas.lastMousePosX = mouse_x;
		Map3DCanvas.lastMousePosY = mouse_y;
		MapManager.Move(dx,dy);
	end
end

function Map3DCanvas.OnMouseWheel()
	MapManager.OnZoom(-mouse_wheel);
end

function Map3DCanvas.OnDoubleClick()

end

function Map3DCanvas.GetScene()
	return ParaScene.GetMiniSceneGraph(Map3DCanvas.sceneName);
end

function Map3DCanvas.IncreasePitch()
	MapManager.Pitch(1);
end

function Map3DCanvas.DecreasePitch()
	MapManager.Pitch(-1);
end

function Map3DCanvas.RotateLeft()
	MapManager.Rotate(1);
end

function Map3DCanvas.RotateRight()
	MapManager.Rotate(-1);
end

function Map3DCanvas.OnYaw()
	log("on yaw not impliment yet\n");
end
--]]

