--[[
Title: Generate Mini Map Page
Author(s): LiXizhi
Date: 2008/10/5
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/GenMiniMapPage.lua");
Map3DSystem.App.MiniMap.GenMiniMapPage.Show()
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/MiniMapWnd.lua");

-- create class
local GenMiniMapPage = {
	save_clip = "tiles",
	source_image = "test.png",
	save_region = "regions",
	
	swfile = "Map.swf",
	region = 533.33,
	x = 35 * 533.33, --19200
	y = 35 * 533.33,--19200
	w = 4 * 533.33, --1600
	h = 4 * 533.33, --1600
};
commonlib.setfield("Map3DSystem.App.MiniMap.GenMiniMapPage", GenMiniMapPage);

-- on init show the current avatar in pe:avatar
function GenMiniMapPage.OnInit()
	local self = GenMiniMapPage;
	local page = document:GetPageCtrl();
	local minimap_filePath = ParaWorld.GetWorldDirectory().."minimap.png";
	if(ParaIO.DoesFileExist(minimap_filePath, true)) then
		ParaAsset.LoadTexture("", minimap_filePath, 1):UnloadAsset(); -- reload texture
		page:SetNodeValue("preview", minimap_filePath);
	end
    page:SetValue("txt_save_clip",self.save_clip);
    page:SetValue("txt_source_image",self.source_image);
    page:SetValue("txt_save_region",self.save_region);
	
	self.page = page;
end

-- generate a mini map and save it to temp/minimap.png. 
function GenMiniMapPage.OnGenMap(name, values)
	local radius = tonumber(values["radius"])
	local center_x = tonumber(values["pos_x"])
	local center_y = tonumber(values["pos_y"]);
	local imagesize= tonumber(values["imagesize"]);

	local state = ParaScene.CaptureSceneState()
	
	local y = ParaTerrain.GetElevation(center_x, center_y);
	local height = radius;
	local att = ParaScene.GetAttributeObject(); 
	att:SetField("FogStart", height);
	att:SetField("FogEnd", height); -- setting FogStart == FogEnd, will ignore min popup distance according to view angle. 
	att:SetField("EnableFog", false);
	
	local att = ParaCamera.GetAttributeObject(); 
	att:SetField("FarPlane", height+50);
	att:SetField("AspectRatio", 1);
	att:SetField("FieldOfView", 1.57);
	ParaCamera.SetLookAtPos(center_x, y+height, center_y);
	ParaCamera.SetEyePos(5, 1.57, -1.57);
	
	att:CallField("FrameMove");
	
	ParaUI.GetUIObject("root").visible = false;
	ParaUI.ShowCursor(false);
	ParaScene.EnableMiniSceneGraph(false);
		
	ParaEngine.ForceRender();ParaEngine.ForceRender();
	local imagepath = "temp/minimap.png";
	ParaMovie.TakeScreenShot(imagepath, imagesize, imagesize);
	
	ParaScene.RestoreSceneState(state);
	ParaUI.ShowCursor(true);
	
	local page = document:GetPageCtrl();
	ParaAsset.LoadTexture("", imagepath, 1):UnloadAsset(); -- reload texture
	page:SetUIValue("preview", imagepath);
	
	_guihelper.MessageBox("Successfully generated minimap. Do you want to apply it to the current world?", GenMiniMapPage.OnSaveMap)
end

function GenMiniMapPage.OnEditMap()
	local minimap_filePath = ParaWorld.GetWorldDirectory().."minimap.png";
	Map3DSystem.App.Commands.Call("File.WinExplorer", minimap_filePath);
end

function GenMiniMapPage.OnSaveMap()
	local minimap_filePath = ParaWorld.GetWorldDirectory().."minimap.png";
	local minimap_size = 533.33
	
	-- replace current mini map file, and cause the mini map to reload. 
	local function CopyAndApplyMiniMap_()
		ParaIO.CopyFile("temp/minimap.png", minimap_filePath, true);
		ParaAsset.LoadTexture("", minimap_filePath, 1):UnloadAsset(); -- reload texture
		_guihelper.MessageBox("mini map file applied. You may need to reload the world to see its effect")
	end
	if(ParaIO.DoesFileExist(minimap_filePath, false)) then
		_guihelper.MessageBox(string.format("mini map file %s already exist. To you want to overwrite it with the current one?", minimap_filePath), CopyAndApplyMiniMap_)
	else
		CopyAndApplyMiniMap_();
	end
end
function GenMiniMapPage.OnGetMapLevel(i)
	i = tonumber(i);
	if(not i)then return end
	if(i == -1 )then
		return {1,2,3,4};
	else
		i = i + 1;
		local result = {};
		local k;
		for k = 1,i do
			result[k] = k;
		end
		return result;
	end
end
function GenMiniMapPage.OnGenRegionMap(name, values)
	local self = GenMiniMapPage;
	if(not self.page)then return end
	--世界路径
	local world_path = ParaWorld.GetWorldDirectory();
	
	--生成切片的路径
	local save_clip = self.page:GetValue("txt_save_clip");
	save_clip = world_path..save_clip;
	--合成图片的路径
	local source_image = self.page:GetValue("txt_source_image");
	source_image = world_path..source_image;
	--生成region的路径
	local save_region = self.page:GetValue("txt_save_region");
	local save_region_relative = save_region;
	save_region = world_path..save_region;
	--地图层数
	local map_level = self.page:GetValue("maplevel_value");
	--生成的region大小
	local region_size = self.page:GetValue("region_size_value");
	--生成的region的格式
	local region_pixelformat = self.page:GetValue("region_pixelformat_value");
	ParaIO.CreateDirectory(save_clip.."/");
	ParaIO.CreateDirectory(save_region.."/");
	
	
	local start_index = tonumber(values["start_index"]);
	local end_index = tonumber(values["end_index"]);

	local x = start_index * self.region;
	local y = x;
	local dx = end_index - start_index;
	local w = dx * self.region;
	local h = w;

	--local x = tonumber(values["genminimap_x"]) or self.x;
	--local y = tonumber(values["genminimap_y"]) or self.y;
	--local w = tonumber(values["genminimap_w"]) or self.w;
	--local h = tonumber(values["genminimap_h"]) or self.h;
	local title = self.page:GetValue("attvalue");
	
	if(name == "btnGenRegionMap")then
		--生成切片
		NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/DummySatellite.lua");
		local DummySatellite = Map3DSystem.App.MiniMap.DummySatellite;
		DummySatellite.viewRect = {
				left = x,
				top = y,
				width = w,
				height = h,
			}
		DummySatellite.default_folder = save_clip;
		local r = self.OnGetMapLevel(map_level);
		if(not r)then return end
		DummySatellite.levelRange = r;
		Map3DSystem.App.MiniMap.DummySatellite.GenMapNodes();
		--合成图片，只合成最后一层的图片
		
		local level = #DummySatellite.levelRange - 1;
		local len = math.pow(2,level);
		
		--composeImage(source_image,save_clip,level,self.region);
		local param = string.format("compose %s %s %d %s",source_image,save_clip,level,self.region);
		commonlib.echo("===========ready compose image");
		commonlib.echo(param);
		if(ParaGlobal.ShellExecute("open", "ImageComposer.exe", param, ParaIO.GetCurDirectory(0), 5)) then 
			commonlib.echo("============comose image successful");
		end; 
		
	elseif(name == "btnSaveRegionMap")then
		--切割成region
		GenMiniMapPage.ReloadRegion(x,y,w,h,title,source_image,save_region,region_size,region_pixelformat,false,save_region_relative);	
	elseif(name == "btnShowSwfMap")then
		--预览地图
		NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/SwfMapPage.lua");
		Map3DSystem.App.MiniMap.SwfMapPage.viewRect = {
			left = x,
			top = y,
			width = w,
			height = h,
		}
		Map3DSystem.App.MiniMap.SwfMapPage.swfile = self.swfile
		Map3DSystem.App.MiniMap.SwfMapPage.tilesFolder = save_clip.."/";
		
		Map3DSystem.App.Commands.Call("Profile.ShowSwfMapPage");
		--Map3DSystem.App.MiniMap.SwfMapPage.ShowPage();
		
	elseif(name == "btnShowTile")then
		--验证tile
		
		local x, _, y = ParaScene.GetPlayer():GetPosition();
		local att = ParaTerrain.GetAttributeObjectAt(x,y);
		att:SetField("CurrentRegionName", title  or "move");
		commonlib.echo{ 
			CurrentRegionName = att:GetField("CurrentRegionName", ""),
			CurrentRegionFilepath = att:GetField("CurrentRegionFilepath", ""),
			NumOfRegions = att:GetField("NumOfRegions", 0), 
		};
		_guihelper.MessageBox(att:GetField("CurrentRegionFilepath", ""));
	elseif(name == "btnReloadRegionMap")then
		-- 重新加载region
		GenMiniMapPage.ReloadRegion(x,y,w,h,title,source_image,save_region,region_size,region_pixelformat,true,save_region_relative);
	elseif(name == "btnEditRegionMap")then
		--Map3DSystem.App.Commands.Call("File.WinExplorer", world_path);
		local absPath = string.gsub(world_path, "/", "\\");
		commonlib.echo(absPath);
		ParaGlobal.ShellExecute("open", "explorer.exe", absPath, "", 1); 
	elseif(name == "snap")then
		--校正坐标
		local xx = math.floor(x/self.region);
		local yy = math.floor(y/self.region);
		local ww = math.floor(w/self.region);
		local hh = math.floor(h/self.region);
		x = xx * self.region;
		y = yy * self.region;
		w = ww * self.region;
		h = hh * self.region;
		
		self.page:SetValue("genminimap_x",x);
		self.page:SetValue("genminimap_y",y);
		self.page:SetValue("genminimap_w",w);
		self.page:SetValue("genminimap_h",h);
	elseif(name == "default_snap")then
		--还原到默认值
		x = self.x;
		y = self.y;
		w = self.w;
		h = self.h;
		
		self.page:SetValue("genminimap_x",x);
		self.page:SetValue("genminimap_y",y);
		self.page:SetValue("genminimap_w",w);
		self.page:SetValue("genminimap_h",h);
	end
end
--切割成region or 重新加载
function GenMiniMapPage.ReloadRegion(x,y,w,h,title,source_image,save_region,region_size,region_pixelformat,reload,save_region_relative)
		local self = GenMiniMapPage;
		--开始的索引
		local start_x = math.floor(x / self.region);
		local start_y = math.floor(y / self.region);
				
		--数量
		local end_x = math.floor(w / self.region);
		local end_y = math.floor(h / self.region);
		
		
		--deComposeImage(source_image,start_x,end_x,save_region,title);
		local param = string.format("decompose %s %d %d %s %s %s %s",source_image,start_x,end_x,save_region,title,tostring(region_size),tostring(region_pixelformat));
		commonlib.echo(param);
		
		if(not reload)then
			ParaGlobal.ShellExecute("open", "ImageComposer.exe", param, ParaIO.GetCurDirectory(0), 5);
		end  
		
			local xx,yy
			local xx_len = start_x + end_x - 1;
			local yy_len = start_y + end_y - 1 
			for xx = start_x, xx_len do
				for yy = start_y, yy_len do
					local image_path = string.format("%s/%s_%d_%d.png",save_region_relative,title,yy,xx);
					image_path = "%WORLD%/"..image_path;
					local x = (xx + 0.5) * self.region;
					local dy = yy_len - yy;
					local y = (start_x + dy + 0.5) * self.region;
					--local y = (yy + 0.5) * self.region;
					
					ParaScene.GetPlayer():SetPosition(x,0,y);
					local att = ParaTerrain.GetAttributeObjectAt(x,y); 

					commonlib.echo{ 
						type = title  or "move",
						image_path = image_path,
						x = x,
						z = y,
					};
					
					--create a region layer if not done before. 
					att:SetField("CurrentRegionName", title  or "move");
					att:SetField("CurrentRegionFilepath", image_path);
					
					commonlib.echo{ 
						CurrentRegionName = att:GetField("CurrentRegionName", ""),
						CurrentRegionFilepath = att:GetField("CurrentRegionFilepath", ""),
						NumOfRegions = att:GetField("NumOfRegions", 0), 
					};
				end
			end
			
end
function GenMiniMapPage.OnUpdateMapPoints()
	_guihelper.MessageBox("TODO:");
end

function GenMiniMapPage.ShowNewMiniMap()
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/MiniMap/NewMiniMap.html", 
			name="NewMiniMapPage", 
			app_key = Map3DSystem.App.MiniMap.app.app_key, 
			allowDrag = true,
			initialPosX = 0, 
			initialPosY = 0, 
			initialWidth = 1000,
			initialHeight = 850,
			text = "New Mini Map Page",
			DestroyOnClose = true,
		});
end

function GenMiniMapPage.SetSwfRect()
	local x = GenMiniMapPage.x;
	local y = GenMiniMapPage.y;
	local w = GenMiniMapPage.w;
	local h = GenMiniMapPage.h;
		NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/SwfMapPage.lua");
		Map3DSystem.App.MiniMap.SwfMapPage.viewRect = {
			left = x,
			top = y,
			width = w,
			height = h,
		};
end

function  GenMiniMapPage.GetSaveClip()
	local world_path = ParaWorld.GetWorldDirectory();
	local save_clip = world_path .. GenMiniMapPage.page:GetValue("txt_save_clip") .. "/";
	return save_clip;
end