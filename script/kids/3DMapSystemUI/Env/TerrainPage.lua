--[[
Title: Environment Terrain page
Author(s): LiXizhi
Date: 2008/6/8
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Env/TerrainPage.lua");
-- call below to load window
Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
	url="script/kids/3DMapSystemUI/Env/TerrainPage.html", name="TerrainPage", 
	app_key=Map3DSystem.App.appkeys["Env"], 
	isShowTitleBar = false, 
	isShowToolboxBar = false, 
	isShowStatusBar = false, 
	initialWidth = 200, 
	alignment = "Left", 
});
-- one can also do: url = "script/kids/3DMapSystemUI/Env/TerrainPage.html?tab=adv"
------------------------------------------------------------
]]

local TerrainPage = {};
commonlib.setfield("Map3DSystem.App.Env.TerrainPage", TerrainPage)

TerrainPage.Name = "TerrainPage";

-- Terrain texture db table
TerrainPage.terrainTexList = {
	{filename = "Texture/tileset/generic/StoneRoad.dds"},
	{filename = "Texture/tileset/generic/sandRock.dds"},
	{filename = "Texture/tileset/generic/sandSmallRock.dds"},
	{filename = "Texture/tileset/generic/greengrass.dds"},
	{filename = "Texture/tileset/generic/stonegrass.dds"},
	{filename = "Texture/tileset/generic/GridMarker.dds"},
};


-- whether we have searched all textures in disk folder "Texture/tileset/generic"
TerrainPage.DiskSkyBoxAppended = nil;

-- add disk sky box to TerrainPage.terrainTexList
function TerrainPage.AppendDiskSkybox()
	if(TerrainPage.DiskSkyBoxAppended == nil) then
		TerrainPage.DiskSkyBoxAppended = true;
		local rootFolder = "Texture/tileset/generic"
		local output = commonlib.Files.Find({}, rootFolder, 10, 500, "*.dds")
		if(output and #output>0) then
			local function HasItem(filename)
				local _, item
				for _,item in ipairs(TerrainPage.terrainTexList)  do
					if(string.lower(item.filename) == filename) then
						return true;
					end
				end
			end
			
			local _, item;
			for _, item in ipairs(output) do
				
				local newItem = {};
				newItem.filename = string.lower(string.format("%s/%s", rootFolder,item.filename))
				if(not HasItem(newItem.filename)) then
					TerrainPage.terrainTexList[(#TerrainPage.terrainTexList)+1] = newItem;
				end	
			end
		end
	end
end

-- datasource function for pe:gridview
function TerrainPage.DS_TerrainTex_Func(index)
	TerrainPage.AppendDiskSkybox();
	if(index == nil) then
		return #(TerrainPage.terrainTexList);
	else
		return TerrainPage.terrainTexList[index];
	end
end

-- called to init page
function TerrainPage.OnInit()
	local self = TerrainPage;
	self.ClearDataBind();
	local Page = document:GetPageCtrl();
	self.page = Page;
	
	-- change tab page according to profile parameter
	local tabpage = Page:GetRequestParam("tab");
    if(tabpage and tabpage~="") then
        Page:SetNodeValue("TerraPageTab", tabpage);
    end
    
	local att = ParaScene.GetAttributeObject();
	if(att~=nil) then
		-- load the terrain paint texture list for this version.
		local msg = {type = Map3DSystem.msg.TERRAIN_GET_TextureList}
		Map3DSystem.SendMessage_env(msg)
		if(msg.texList) then
			TerrainPage.terrainTexList = msg.texList;
		end	
		
		-- set current terrain height field brush size
		local msg = {type = Map3DSystem.msg.TERRAIN_GET_HeightFieldBrush,}
		Map3DSystem.SendMessage_env(msg)
		Page:SetNodeValue("HeightFieldBrushSize", msg.brush.radius);
		
		-- set current paint brush size
		local msg = {type = Map3DSystem.msg.TERRAIN_GET_PaintBrush,}
		Map3DSystem.SendMessage_env(msg)
		Page:SetNodeValue("TextureBrushSize", msg.brush.radius);
	end	
end

------------------------
-- page events
------------------------

-- 
function TerrainPage.GaussianHill(height)
	local self = TerrainPage;
	height = tonumber(height);
	local x,y,z;
	local player = ParaScene.GetPlayer();
	if(player:IsValid()) then
		x,y,z = player:GetPosition();
	
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_HeightFieldBrush, brush = {
			type = "GaussianHill",
			x=x,
			y=y,
			z=z,
			heightScale = height,
			gaussian_deviation = 0.9,
			smooth_factor = 0.5,
		},})
		
		-- play animation according to terrain height operation
		if(height > 0) then
			Map3DSystem.Animation.SendMeMessage({
					type = Map3DSystem.msg.ANIMATION_Character,
					obj_params = nil, --  <player>
					animationName = "RaiseTerrain",
					});
		elseif(height < 0) then
			Map3DSystem.Animation.SendMeMessage({
					type = Map3DSystem.msg.ANIMATION_Character,
					obj_params = nil, --  <player>
					animationName = "LowerTerrain",
					});
		end
		
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_HeightField,})
		
		if(self.bindingContext and self.bindTarget)then
			self.bindTarget.TerrainType = "GaussianHill";
			self.bindTarget.X = x;
			self.bindTarget.Y = y;
			self.bindTarget.Z = z;
			self.bindTarget.HeightScale = height;
		end
	end
end

-- 
function TerrainPage.Flatten()
	local self = TerrainPage;
	local x,y,z;
	local player = ParaScene.GetPlayer();
	if(player:IsValid()) then
		x,y,z = player:GetPosition();
	
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_HeightFieldBrush, brush = {
			type = "Flatten",
			x=x,
			y=y,
			z=z,
			BrushStrength = 0.3,
			smooth_factor = 1.0,
			FlattenOperation = -1,
		},})

		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_HeightField,})
		
		if(self.bindingContext and self.bindTarget)then
			self.bindTarget.TerrainType = "Flatten";
			self.bindTarget.X = x;
			self.bindTarget.Y = y;
			self.bindTarget.Z = z;
		end
	end
end


-- 
function TerrainPage.Roughen_Smooth(bRoughen)
	local self = TerrainPage;
	if(type(bRoughen) == "string") then
		bRoughen = (bRoughen == "true")
	end
	
	local x,y,z;
	local player = ParaScene.GetPlayer();
	if(player:IsValid()) then
		x,y,z = player:GetPosition();
	
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_HeightFieldBrush, brush = {
			type = "Roughen_Smooth",
			x=x,
			y=y,
			z=z,
			bRoughen = bRoughen,
			smooth_factor = 0.5,
			big_grid = false,
		},})

		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_HeightField,})
		
		if(self.bindingContext and self.bindTarget)then
			self.bindTarget.TerrainType = "Roughen_Smooth";
			self.bindTarget.X = x;
			self.bindTarget.Y = y;
			self.bindTarget.Z = z;
			self.bindTarget.bRoughen = bRoughen;
		end
	end
end

-- called to paint textures on to the terrain surface using the current brushes. 
function TerrainPage.OnTerrainTexturePaint(FileNameOrIndex)
	local self = TerrainPage;
	local x,y,z;
	local player = ParaScene.GetPlayer();
	if(player:IsValid() == true) then
		x,y,z = player:GetPosition();
	
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_PaintBrush, brush = {
			filename = FileNameOrIndex or "",
			x=x,
			y=y,
			z=z,
			bErase = (mouse_button == "right"),
		},})
		
		Map3DSystem.Animation.SendMeMessage({
				type = Map3DSystem.msg.ANIMATION_Character,
				obj_params = nil, --  <player>
				animationName = "ModifyTerrainTexture",
				});
		
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_Paint,})
		
		if(self.bindingContext and self.bindTarget)then
			self.bindTarget.BrushIndex = FileNameOrIndex;
			self.bindTarget.X = x;
			self.bindTarget.Y = y;
			self.bindTarget.Z = z;
		end
	end
end

-- set the current terrain brush size
-- @param nSize: if this is nil, the current brush size is used, if not the current brush size will be set accordingly
function TerrainPage.OnSetTerrainBrushSize(nSize, bSilent)
	local self = TerrainPage;
	nSize = tonumber(nSize);
	-- texture brush radius
	if(nSize~=nil) then
		if(nSize~=nil and nSize>=5 and nSize<=250) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_HeightFieldBrush, brush = {radius = nSize}, })
			if(self.bindingContext and self.bindTarget)then
				self.bindTarget.TerrainBrushSize = nSize;
			end
		else
			log("warning: the height field brush size can only be within (5, 250)\n");
		end		
	end
end

-- set the current terrain texture brush size
-- @param nSize: if this is nil, the current brush size is used, if not the current brush size will be set accordingly
function TerrainPage.OnSetTextureBrushSize(nSize, bSilent)
	local self = TerrainPage;
	nSize = tonumber(nSize);
	-- texture brush radius
	if(nSize~=nil) then
		if(nSize>0.1 and nSize<100) then
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.TERRAIN_SET_PaintBrush, brush = {radius = nSize}, })
			
			if(self.bindingContext and self.bindTarget)then
				self.bindTarget.TextureBrushSize = nSize;
			end
		else
			log("warning:the terrain brush size can only be within (0.1, 100)\n");
		end	
	end
end

function TerrainPage.SetTerrainBrushSize(name, mcmlNode)
    if(mcmlNode) then
        local brushsize = mcmlNode:GetNumber("brushsize");
        if(brushsize) then
            document:GetPageCtrl():SetUIValue("HeightFieldBrushSize", brushsize);
            TerrainPage.OnSetTerrainBrushSize(brushsize)
        end
    end
end

function TerrainPage.SetTextureBrushSize(name, mcmlNode)
    if(mcmlNode) then
        local brushsize = mcmlNode:GetNumber("brushsize");
        if(brushsize) then
            document:GetPageCtrl():SetUIValue("TextureBrushSize", brushsize);
            TerrainPage.OnSetTextureBrushSize(brushsize)
        end
    end
end

-- reset brush settings. 
function TerrainPage.Reset_TerrainMod()
	if(document) then
		local Page = document:GetPageCtrl();
		Page:SetUIValue("HeightFieldBrushSize", 20);
		Page:SetUIValue("TextureBrushSize", 2);
	end	
	TerrainPage.OnSetTerrainBrushSize(20);
	TerrainPage.OnSetTextureBrushSize(2);
end

function TerrainPage.DataBind(bindTarget)
	local self = TerrainPage;
	if(not bindTarget or not self.page)then return; end
	
	self.bindTarget = bindTarget;
	self.bindingContext = commonlib.BindingContext:new();	
	--self.bindingContext:AddBinding(bindTarget, "WaterLevel", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "OceanLevel")
	--self.bindingContext:AddBinding(bindTarget, "Color", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "OceanColorpicker")
	--self.bindingContext:UpdateDataToControls();
	
end
function TerrainPage.ClearDataBind()
	local self = TerrainPage;
	self.bindTarget = nil;
	self.bindingContext = nil;
end