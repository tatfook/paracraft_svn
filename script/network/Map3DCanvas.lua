--[[
Title: sample code for map 3d canvas implementation using miniscene graph interface
Author(s): LiXizhi
Date: 2007/8/13
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/Map3DCanvas.lua");
Map3DCanvas.Show();
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

if(not Map3DCanvas) then Map3DCanvas={}; end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function Map3DCanvas.Show(bShow)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("Map3DCanvas_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		_this=ParaUI.CreateUIObject("container","Map3DCanvas_cont","_lt",0,0,512,512);
		--_this.background="Texture/whitedot.png;0 0 0 0";
		_this.onmouseup = ";Map3DCanvas.OnMouseUp();";
		_this.onmousewheel = ";Map3DCanvas.OnMouseWheel();";
		_this.onmousemove = ";Map3DCanvas.OnMouseMove();";
		_this:AttachToRoot();
		_parent = _this;
		
		-- call this only once
		Map3DCanvas.InitSceneGraph();
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

-- create and initialize the scene graph
-- call this only once
function Map3DCanvas.InitSceneGraph()
	local scene = ParaScene.GetMiniSceneGraph("map3D");
	
	------------------------------------
	-- init render target
	------------------------------------
	-- reset scene, in case this is called multiple times
	scene:Reset();
	-- set size
	scene:SetRenderTargetSize(512, 512);
	-- enable camera and create render target
	scene:EnableCamera(true);
	-- render it each frame automatically. 
	-- Note: If content is static, one should disable this, and call scene:draw() in a script timer.
	scene:EnableActiveRendering(true);
	-- If one wants an over lay, here it is.
	--scene:SetMaskTexture(ParaAsset.LoadTexture("","anything you want.dds",1));
	
	------------------------------------
	-- init camera
	------------------------------------
	-- automatically adjust the camera to watch a sphere in its integrity. 
	-- Note: Alternatively, one can call scene:CameraSetLookAtPos() and scene:CameraSetEyePos() to gain precise control.
	scene:CameraZoomSphere(0,0,0,3);
	
	------------------------------------
	-- init scene content
	------------------------------------

	
	local asset = ParaAsset.LoadStaticMesh("","model/06props/shared/pops/huaban.x")
	local assetTex = ParaAsset.LoadTexture("","Texture/sharedmedia/09.JPG",1);
	local assetTex2 = ParaAsset.LoadTexture("","Texture/sharedmedia/08.JPG",1);
	local assetChar = ParaAsset.LoadParaX("", "character/v1/02animals/01land/woniu/woniu.x");
	
	local obj,player;
	obj = ParaScene.CreateMeshPhysicsObject("cell_0_0", asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	if( obj:IsValid())then
		obj:SetPosition(0,0,0);
		obj:GetAttributeObject():SetField("progress",1);
		scene:AddChild(obj);
	end	
	
	obj = ParaScene.CreateMeshPhysicsObject("cell_1_1", asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	if( obj:IsValid())then
		obj:SetPosition(1,0,1);
		obj:GetAttributeObject():SetField("progress",1);
		obj:SetReplaceableTexture(1,assetTex2);
		scene:AddChild(obj);
	end	
	
	obj = ParaScene.CreateMeshPhysicsObject("cell_3_3", asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	if( obj:IsValid())then
		obj:SetPosition(3,0,3);
		obj:GetAttributeObject():SetField("progress",1);
		obj:SetReplaceableTexture(1,assetTex2);
		scene:AddChild(obj);
	end	
	
	-- sample player code
	player = ParaScene.CreateCharacter ("", assetChar, "", true, 0.2, 3.9, 1.0);
	if( player:IsValid()) then
		player:SetPosition(0, 0, 0);
		scene:AddChild(player);
	end	
	
	------------------------------------
	-- assign the texture to UI
	------------------------------------
	local tmp = ParaUI.GetUIObject("Map3DCanvas_cont");
	if(tmp:IsValid()) then
		tmp:SetBGImage(scene:GetTexture());
	end
end

-- sample code for try to pick a 3D object
function Map3DCanvas.OnMouseUp()
	local temp = ParaUI.GetUIObject("Map3DCanvas_cont");
	if(not temp:IsValid()) then
		log("error getting control Map3DCanvas.OnMouseUp\n");
		return
	end
	
	local x,y, width, height = temp:GetAbsPosition();
	local scene = ParaScene.GetMiniSceneGraph("map3D");
	
	-- do a mouse: using filter "", it can also be "biped", "mesh", etc
	local obj = scene:MousePick(mouse_x-x, mouse_y-y, 500, "mesh");
	if(obj:IsValid()) then
		-- just rotate the selected object. 
		if(not lastfacing) then
			lastfacing = 0.4;
		else
			lastfacing = lastfacing +0.4
		end
		obj:SetFacing(lastfacing);
	end
	scene:EnableActiveRendering (true);
end

function Map3DCanvas.OnMouseWheel()

end

function Map3DCanvas.OnMouseMove()

end