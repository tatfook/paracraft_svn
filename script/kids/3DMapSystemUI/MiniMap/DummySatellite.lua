--[[
Title: 模拟卫星，抓取世界生成图片
Author(s): Leio
Date: 2009/8/28
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/DummySatellite.lua");
local DummySatellite = Map3DSystem.App.MiniMap.DummySatellite;
DummySatellite.viewRect = {
		left = 19200,
		top = 19200,
		width = 1600,
		height = 1600,
	}
DummySatellite.levelRange = {1,2,3}
Map3DSystem.App.MiniMap.DummySatellite.GenMapNodes()


NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/DummySatellite.lua");
local DummySatellite = Map3DSystem.App.MiniMap.DummySatellite;
local x,y,z = ParaScene.GetPlayer():GetPosition();
DummySatellite.GenMap_Manual("test_map.png",x,y,z,512,30)


NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/DummySatellite.lua");
local DummySatellite = Map3DSystem.App.MiniMap.DummySatellite;
local imagefolder = "test";
local x,y,z = ParaScene.GetPlayer():GetPosition();
local radius = 50;
local camera_height = 100;
local slice_num = 1;
local imagesize = 512;
DummySatellite.GenMap_Manual2(imagefolder,x,y,z,radius,camera_height,slice_num,imagesize)
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/ExternalInterface.lua");
local DummySatellite = {
	imagesize = 256,
	viewRect = {
		left = 19400,
		top = 19400,
		width = 1200,
		height = 1200,
	},
	levelRange = {
		1,
		2,
		3,
		4,
		5,
		6,
	},
	min_height = 20,
	default_height = 10,
	default_folder = "temp/tiles",
	curLevel = nil,
	curX = nil,
	curY = nil,
	curLevelTileNodes = nil,
	allTileNodes = nil,
};
commonlib.setfield("Map3DSystem.App.MiniMap.DummySatellite", DummySatellite);
function DummySatellite.SetAvatarPos(x,y,z)
	local player = ParaScene.GetPlayer();
	if(not x or not y or not z)then return end
	if(player and player:IsValid())then
		player:SetPosition(x,y,z);
		player:SnapToTerrainSurface(0);
	end		
end
function DummySatellite.GetAvatarPos()
	local player = ParaScene.GetPlayer();
	if(player and player:IsValid())then
		local x,y,z = player:GetPosition();
		x = string.format("%.2f",x);
		y = string.format("%.2f",y);
		z = string.format("%.2f",z);
		local p = {
			x = x,
			y = y,
			z = z,
		}
		ExternalInterface.Call("minimap_avatar_params",p);
	end		
end
-- 把世界一定区域切割成地图碎片,以中心点(x,y,z)半径为radius的范围生成slice_num*slice_num张地图切片,每张大小imagesize
-- @param imagefolder:保存的文件夹
-- @param x:地图区域采样 中心点坐标 x
-- @param y:地图区域采样 中心点坐标 y
-- @param z:地图区域采样 中心点坐标 z
-- @param radius:地图区域采样 半径
-- @param camera_height:摄影机相对 y 值高度，默认30
-- @param slice_num:切割图片的数量 slice_num*slice_num
-- @param imagesize:生成每张地图切片的大小，默认128px
-- @param level:地图第几层，默认为0
function DummySatellite.GenMap_Manual2(imagefolder,x,y,z,radius,camera_height,slice_num,imagesize,level)
	local self = DummySatellite;
	local draw_size = radius * 2;
	local slice_size = draw_size / slice_num;
	level = level or 0
	local slice_img_size = imagesize or 128;
	local left = x - radius;
	local top = z - radius;
	local player = ParaScene.GetPlayer();
	local state = ParaScene.CaptureSceneState()
	ParaUI.GetUIObject("root").visible = false;
	ParaUI.ShowCursor(false);
	ParaScene.EnableMiniSceneGraph(false);

	local k,kk;
	local r = slice_size / 2
	for k = 1,slice_num do
		local c_x = left +  (k-1) * slice_size + slice_size / 2;
		for kk = 1,slice_num do
			local c_z = top +  (kk-1) * slice_size + slice_size / 2;
			--commonlib.echo({c_x,c_z});
			local s = string.format("%s/%d_%d_%d.png",imagefolder,level,slice_num - kk + 1,k);
			DummySatellite.GenMap_TakeShot(s,c_x,y,c_z,r,camera_height,slice_img_size)
		end
	end
	ParaScene.RestoreSceneState(state);
	ParaUI.GetUIObject("root").visible = true;
	ParaUI.ShowCursor(true);
	ParaCamera.SwitchPerspectiveView()

	if(player and player:IsValid())then
		player:ToCharacter():SetFocus();
	end
	ExternalInterface.Call("DummySatellite.GenMap_Manual2.Finished");

end
function DummySatellite.GenMap_TakeShot(imagepath,x,y,z,radius,height,imagesize)
	local self = DummySatellite;
	radius = radius or 512;
	height = height  or 30;
	imagesize = imagesize or 512
	local center_x = x;
	local center_y = z;
	local height = y + height;
	
	local att = ParaScene.GetAttributeObject(); 
	att:SetField("FogStart", height);
	att:SetField("FogEnd", height); -- setting FogStart == FogEnd, will ignore min popup distance according to view angle. 
	att:SetField("EnableFog", false);
	
	ParaCamera.SwitchOrthoView(radius * 2, radius * 2)
	local att = ParaCamera.GetAttributeObject(); 
	att:SetField("FarPlane", height+100);
	att:SetField("AspectRatio", 1);
	att:SetField("FieldOfView", 1.57);
	ParaCamera.SetLookAtPos(center_x, height - 5, center_y);
	ParaCamera.SetEyePos(5, 1.57, -1.57);
	att:CallField("FrameMove");
		
	ParaEngine.ForceRender();ParaEngine.ForceRender();
	ParaMovie.TakeScreenShot(imagepath, imagesize, imagesize);
end
--生成地图预览图片
function DummySatellite.GenMap_Manual(imagepath,x,y,z,radius,height,imagesize)
	local self = DummySatellite;
	local player = ParaScene.GetPlayer();
	local state = ParaScene.CaptureSceneState()
	radius = radius or 512;
	height = height  or 30;
	imagesize = imagesize or 512
	local center_x = x;
	local center_y = z;
	local height = y + height;
	
	local att = ParaScene.GetAttributeObject(); 
	att:SetField("FogStart", height);
	att:SetField("FogEnd", height); -- setting FogStart == FogEnd, will ignore min popup distance according to view angle. 
	att:SetField("EnableFog", false);
	
	ParaCamera.SwitchOrthoView(radius * 2, radius * 2)
	local att = ParaCamera.GetAttributeObject(); 
	att:SetField("FarPlane", height+100);
	att:SetField("AspectRatio", 1);
	att:SetField("FieldOfView", 1.57);
	ParaCamera.SetLookAtPos(center_x, height - 5, center_y);
	ParaCamera.SetEyePos(5, 1.57, -1.57);
	att:CallField("FrameMove");
	
	ParaUI.GetUIObject("root").visible = false;
	ParaUI.ShowCursor(false);
	ParaScene.EnableMiniSceneGraph(false);
		
	ParaEngine.ForceRender();ParaEngine.ForceRender();
	ParaMovie.TakeScreenShot(imagepath, imagesize, imagesize);

	ParaScene.RestoreSceneState(state);
	ParaUI.GetUIObject("root").visible = true;
	ParaUI.ShowCursor(true);
	ParaCamera.SwitchPerspectiveView()

	if(player and player:IsValid())then
		player:ToCharacter():SetFocus();
	end
	_guihelper.MessageBox("生成成功！");
end
function DummySatellite.GenMap(level,maxLevel,x,y)
	local self = DummySatellite;
	if(not level or not maxLevel or not x or not y)then return end
	local cur_level = math.min(level,maxLevel);
	local max_level = math.max(level,maxLevel);
	--被画区域的开始点
	local start_x,start_y = self.viewRect.left,self.viewRect.top;
	--被画区域的长宽
	local w,h = self.viewRect.width,self.viewRect.height;
	--在当前层每个tile的radius
	local radius = w/math.pow(2,cur_level);
	
	local center_x = x * radius * 2 + start_x + radius;
	local center_y = y * radius * 2 + start_y + radius;
	local imagesize= self.imagesize
	--commonlib.echo({level,radius,center_x,center_y});
	
	local height = radius;
	
	
	--local y = ParaTerrain.GetElevation(center_x, center_y);
	local att = ParaScene.GetAttributeObject(); 
	att:SetField("FogStart", height);
	att:SetField("FogEnd", height); -- setting FogStart == FogEnd, will ignore min popup distance according to view angle. 
	att:SetField("EnableFog", false);
	
	ParaCamera.SwitchOrthoView(radius * 2, radius * 2)
	local att = ParaCamera.GetAttributeObject(); 
	att:SetField("FarPlane", height+100);
	att:SetField("AspectRatio", 1);
	att:SetField("FieldOfView", 1.57);
	ParaCamera.SetLookAtPos(center_x, height - 5, center_y);
	ParaCamera.SetEyePos(5, 1.57, -1.57);
	att:CallField("FrameMove");
	
	ParaUI.GetUIObject("root").visible = false;
	ParaUI.ShowCursor(false);
	ParaScene.EnableMiniSceneGraph(false);
		
	ParaEngine.ForceRender();ParaEngine.ForceRender();
	y = math.pow(2,cur_level - 1) - y - 1;
	local imagepath = string.format("%s/%d_%d_%d.png",self.default_folder,level - 1,y,x);
	--commonlib.echo("========imagepath");
	--commonlib.echo(imagepath);
	ParaMovie.TakeScreenShot(imagepath, imagesize, imagesize);
	
end
function DummySatellite.GenMapNodes(level)
	local self = DummySatellite;
	local state = ParaScene.CaptureSceneState()
	self.allTileNodes = self.GenTileNodes();
	local maxLevel = table.getn(self.levelRange);
	
	function _gen(nodes)
		if(nodes)then
			local __,node
			for __,node in ipairs(nodes) do
				if(node)then
					--commonlib.echo(node);
					self.GenMap(node.level,maxLevel,node.x,node.y)
				end
			end
		end
	end
	if(level)then
		local nodes = self.GenLevelTile(level)
		_gen(nodes)
	else
		local k,v;
		for k,v in ipairs(self.levelRange) do
			local nodes = self.GenLevelTile(v)
			_gen(nodes)
		end
	end
	ParaScene.RestoreSceneState(state);
	ParaUI.ShowCursor(true);
	ParaCamera.SwitchPerspectiveView()
end

function DummySatellite.GenLevelTile(level)
	local self = DummySatellite;
	if(not self.allTileNodes)then return end
	local nodes = self.allTileNodes[level];
	local result;
	if(nodes)then
		result = {};
		local row = table.getn(nodes);
		local col = table.getn(nodes[1]);
		local r,c;
		for r = 1, row do
			for c = 1,col do
				local node = nodes[r][c];
				if(node)then
					table.insert(result,node);
				end
			end
		end
	end
	return result;
end
--生成所有层的nodes
function DummySatellite.GenTileNodes()
	local self = DummySatellite;
	local allTileNodes = {};
	local k,v;
	for k,v in ipairs(self.levelRange) do
		local nodes = self.GenLevelTileNodes(v);
		if(nodes)then
			table.insert(allTileNodes,nodes);
		end
	end
	return allTileNodes;
end
--生成一层的nodes
function DummySatellite.GenLevelTileNodes(level)
	if(not level)then return end
	local self = DummySatellite;
	local tileNodes = {};
	local row = math.pow(2,level - 1);
	local col =  math.pow(2,level - 1);
	local r,c;
	for r = 1, row do
		local row_nodes = {};
		for c = 1 , col do
			local node = {x = c - 1,y = r - 1,level = level};
			table.insert(row_nodes,node);
		end
		table.insert(tileNodes,row_nodes);
	end
	return tileNodes;
end