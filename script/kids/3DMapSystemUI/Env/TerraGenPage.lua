--[[
Title: TerraGenPage
Author(s): LiXizhi
Date: 2009/1/30
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Env/TerraGenPage.lua");
local TerraGenPage = commonlib.gettable("Map3DSystem.App.Env.TerraGenPage")
TerraGenPage.OnCloneTerrainTile("0_0", "1_1")
------------------------------------------------------------
]]

local TerraGenPage = commonlib.gettable("Map3DSystem.App.Env.TerraGenPage")

NPL.load("(gl)script/kids/3DMapSystemUI/Env/TerrainBrushMarker.lua");
local TerrainBrushMarker = Map3DSystem.App.Env.TerrainBrushMarker;

-- singleton page instance. 
local page;


-- current brush
local curBrush = {
	x=nil,y=nil,z=nil,
	radius=15,
}

-- called to init page
function TerraGenPage.OnInit()
	page = document:GetPageCtrl();
	NPL.load("(gl)script/kids/3DMapSystemUI/Env/SwitchEnvEditorMode.lua");
	Map3DSystem.App.Env.SwitchEnvEditorMode("TerraGenPage");
	
	curBrush.x,curBrush.y,curBrush.z = ParaScene.GetPlayer():GetPosition();
	page:SetNodeValue("pos_x", curBrush.x);
	page:SetNodeValue("pos_z", curBrush.z);
	page:SetNodeValue("radius", curBrush.radius);
	
	TerraGenPage.BeginEditing();
	TerraGenPage.UpdateCurrentBrush();
end

------------------------
-- public methods
------------------------

-- when user select a tool it will enter 3d editing mode, where the miniscenegraph should draw markers
function TerraGenPage.BeginEditing()
	TerraGenPage.RegisterHooks()
end
-- when user pressed esc key, it will quit the 3d editing mode. and the mini scenegraph should be deleted. 
function TerraGenPage.EndEditing()
	TerrainBrushMarker.Clear()
	TerraGenPage.UnregisterHooks()
end

function TerraGenPage.RegisterHooks()
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	CommonCtrl.os.hook.SetWindowsHook({hookType = hookType, 		 
		hookName = "TerraGen_key_down_hook", appName = "input", wndName = "key_down",
		callback = TerraGenPage.OnKeyDown});
end

function TerraGenPage.UnregisterHooks()
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "TerraGen_key_down_hook", hookType = hookType});
end

function TerraGenPage.OnKeyDown(nCode, appName, msg)
	if(nCode==nil) then return end
	
	if(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_ESCAPE))then
		-- exit editing mode. 
		TerraGenPage.EndEditing();
		return;
	end	
	return nCode; 
end

-- update the terrain brush. 
-- @param brush: {x,y,z,radius}, all fields can be nil. 
-- @param bRefreshUI: if true the UI will be updated according to input
function TerraGenPage.UpdateCurrentBrush(brush, bRefreshUI)
	if(brush) then
		commonlib.partialcopy(curBrush, brush);
		if(not brush.y and (brush.x or brush.z)) then
			curBrush.y = ParaTerrain.GetElevation(curBrush.x, curBrush.z);
		end
	end
	-- validate data
	if(curBrush.radius < 2) then
		curBrush.radius = 2;
	end
	
	if(bRefreshUI) then
		page:SetUIValue("pos_x", curBrush.x);
		page:SetUIValue("pos_z", curBrush.z);
		page:SetUIValue("radius", curBrush.radius);
	end	
	TerraGenPage.RefreshMarker();
end

-- refresh the marker. 
function TerraGenPage.RefreshMarker()
	TerrainBrushMarker.DrawBrush({x=curBrush.x,y=y,z=curBrush.z,radius = curBrush.radius});
end

------------------------
-- page events
------------------------

-- Close the page
function TerraGenPage.OnClose()
end

function TerraGenPage.OnSetPosX(value)
	TerraGenPage.UpdateCurrentBrush({x = value});
end

function TerraGenPage.OnSetPosZ(value)
	TerraGenPage.UpdateCurrentBrush({z = value});
end

function TerraGenPage.OnSetRadius(value)
	TerraGenPage.UpdateCurrentBrush({radius = value});
end

function TerraGenPage.OnSetCurrentPlayerPos()
	local x,y,z = ParaScene.GetPlayer():GetPosition();
	TerraGenPage.UpdateCurrentBrush({x=x,y=y,z=z}, true)
end

function TerraGenPage.OnSetCurrentPlayerHeight()
	local x,y,z = ParaScene.GetPlayer():GetPosition();
	page:SetUIValue("relative_y", y);
end

-- generate heightmap to a specified file
function TerraGenPage.OnGenHeightFieldFile(name, values)
	TerraGenPage.RefreshMarker();
	NPL.load("(gl)script/ide/SaveFileDialog.lua");
	local ctl = CommonCtrl.SaveFileDialog:new{
		name = "SaveFileDialog1",
		alignment = "_ct",
		left=-256, top=-150,
		width = 512,
		height = 380,
		parent = nil,
		fileextensions = {"height field(*.raw)",},
		folderlinks = {
			{path = "/", text = "root"},
			{path = "model/others/terrain/", text = "heightfields"},
			{path = "worlds/", text = "worlds"},
		},
		onopen = function(ctrlName, filename)
			if(filename == "") then
				return 
			end
			if(not string.find(filename, "raw$")) then
				filename = filename..".raw";
			end
			
			local x,z  = values.pos_x, values.pos_z;
			local relative_y = values.relative_y or 0;
			local radius = values.radius;
			local tilesize = ParaTerrain.GetAttributeObjectAt(x,z):GetField("size", 533.333);
			local spacing = tilesize/128;	
			local nRadius = math.floor(radius/spacing)
			local nSize = nRadius*2+1;
			_guihelper.MessageBox(string.format("确定要生成高度图到文件: %s\n分辨率为%d*%d?", filename, nSize, nSize), function()
				local file = ParaIO.open(filename, "w");
				if(file:IsValid()) then
					local from_x = math.floor(x/spacing) - nRadius
					local from_y = math.floor(z/spacing) - nRadius
					local i,j
					for j=from_y, from_y+nSize-1 do
						for i=from_x, from_x+nSize-1 do
							local height = ParaTerrain.GetElevation(i*spacing, j*spacing);
							file:WriteFloat(height-relative_y);
						end
					end
					file:close();
					commonlib.log("height field map is successfully saved to %s\n", filename);
				end
			end);
		end
	};
	ctl:Show(true);
end

-- add a selected raw heightfield file to specified region. 
function TerraGenPage.OnApplyHeightFieldFile(name, values)
	TerraGenPage.RefreshMarker();
	NPL.load("(gl)script/ide/OpenFileDialog.lua");
	local ctl = CommonCtrl.OpenFileDialog:new{
		name = "OpenFileDialog1",
		alignment = "_ct",
		left=-256, top=-150,
		width = 512,
		height = 380,
		parent = nil,
		fileextensions = {"height field(*.raw)",},
		folderlinks = {
			{path = "/", text = "root"},
			{path = "model/others/terrain/", text = "heightfields"},
			{path = "worlds/", text = "worlds"},
		},
		onopen = function(ctrlName, filename)
			-- apply terrain height field file. 
			local x,z  = values.pos_x, values.pos_z;
			local y = ParaTerrain.GetElevation(x,z);
			
			local brush = {
				type = "MergeHeightField",
				x = x,
				y = y,
				z = z,
				filename = filename, 
			}
			-- use the specified radius
			if(values.useHeightMapRadius) then
				local nSize = math.sqrt(ParaIO.GetFileSize(filename) / 4);
				local tilesize = ParaTerrain.GetAttributeObjectAt(x,z):GetField("size", 533.333);
				brush.radius = tilesize/128*nSize;	
			else
				brush.radius = values.radius;
			end
			Map3DSystem.SendMessage_env({
				type = Map3DSystem.msg.TERRAIN_HeightField, 
				brush=brush,
				MergeOperation = tonumber(values.MergeOperation),
				weight1 = values.weight1,
				weight2 = values.weight2,
				smoothpixels = values.smoothpixels, -- number of pixels to smooth at the edge
			})
			-- force update even the camera does not move
			ParaTerrain.UpdateTerrain(true);
		end
	};
	ctl:Show(true);
end

--[[ 
one may need to call this function twice if the root world.config.xml has not been generated
sample code

NPL.load("(gl)script/kids/3DMapSystemUI/Env/TerraGenPage.lua");
local TerraGenPage = commonlib.gettable("Map3DSystem.App.Env.TerraGenPage")
local from_x, from_y = 36,38;
local to_x, to_y = 38,36;

local x, y
for x = from_x, to_x do
	for y = from_y, to_y, -1 do
		TerraGenPage.OnCloneTerrainTile(format("%d_%d", x, y), format("%d_%d", x-3, y))
	end
end

local to_x, to_y = 37,36;
local x, y
for x = from_x, to_x do
	for y = from_y, to_y, -1 do
		TerraGenPage.OnCloneTerrainTile("37_35", format("%d_%d", x, y))
	end
end


]]
function TerraGenPage.OnCloneTerrainTile(txtSrcCoordinates, txtDestCoordinates)
    -- copy only used files, this way we can support clone a world from assets manifest files. 
	local base_world = Map3DSystem.World:new();
	local worldpath = ParaWorld.GetWorldDirectory();
	worldpath = string.gsub(worldpath, "[/\\]+$", "")
	base_world:SetDefaultFileMapping(worldpath);

	local src_x, src_z;
    if(txtSrcCoordinates) then
        src_x, src_z = txtSrcCoordinates:match("(%d+)%D*(%d+)")
        src_x = tonumber(src_x);
        src_z = tonumber(src_z);
    end

    local dest_x, dest_z;
    if(txtDestCoordinates) then
        dest_x, dest_z = txtDestCoordinates:match("(%d+)%D*(%d+)")
        dest_x = tonumber(dest_x);
        dest_z = tonumber(dest_z);
    end
	local search_path = format("_%d_%d", src_x, src_z);
    local dest_path = format("_%d_%d", dest_x, dest_z);

    if(search_path == dest_path) then
        return
    end

	local config_file = ParaIO.OpenAssetFile(base_world.sConfigFile);
	
	if(config_file:IsValid()) then
		-- find all referenced files
		
		local x, y, z = ParaScene.GetPlayer():GetPosition();
	    local attr = ParaTerrain.GetAttributeObjectAt(x,z);
        local region_width = attr:GetField("size", 533.3333); 

        local offset_x = (dest_x - src_x)*region_width
        local offset_z = (dest_z - src_z)*region_width

		local text = config_file:GetText();

		local has_dest_config;
		local w;
		
		for w in string.gmatch(text, "[^\r\n]+") do
			w = string.match(w, "[^/]+config%.txt$");
			if(w) then
				local config_file_name = worldpath.."/config/"..w;
				
				if(w:match(dest_path)) then		
					has_dest_config = true;
				elseif(w:match(search_path)) then
					local file = ParaIO.OpenAssetFile(config_file_name);
					if(file:IsValid()) then
						local src_name = config_file_name:gsub("%.config%.txt$", ".mask");
						local dest_name = src_name:gsub(search_path, dest_path);
						if(src_name~=dest_name) then
							ParaIO.CopyFile(src_name, dest_name, true);
						end

						local tile_text = file:GetText();
						
                        local new_config_file_name = config_file_name:gsub(search_path, dest_path);
                        local file_new = ParaIO.open(new_config_file_name, "w");
				        if(file_new:IsValid()) then
                            local txt = tile_text:gsub(search_path, dest_path)
                            file_new:WriteString(txt);
                            file_new:close();
                        end
						
                        local filename
                        for filename in tile_text:gmatch("%%WORLD%%/([^\r\n]+)") do
                            local src_name = worldpath.."/"..filename;
                            local dest_name = src_name:gsub(search_path, dest_path);
                            if(src_name~=dest_name) then
								echo({src_name, dest_name})
                                ParaIO.CopyFile(src_name, dest_name, true);
									
								if(dest_name:match("%.onload%.lua$")) then
                                    local file_new = ParaIO.open(dest_name, "r");
                                    if(file_new:IsValid()) then
                                        local text = file_new:GetText();
                                        local out = {};
                                        local w;
				                        for w in string.gmatch(text, "[^\r\n]+") do
											w = w:gsub(search_path, dest_path);
                                            local pre, pos, post = w:match("^(.*:SetPosition%()([^%)]+)(%).*)$");
                                            if(pre and pos and post) then 
                                                local x, y, z = pos:match("([^,]+),([^,]+),([^,]+)");
                                                x = x + offset_x
                                                z = z + offset_z
                                                w = string.format("%s%.2f,%.2f,%.2f%s", pre, x, y, z, post)
                                            end 
                                            out[#out+1] = w;
                                        end
                                        file_new:close();

                                        local file_new = ParaIO.open(dest_name, "w");
				                        if(file_new:IsValid()) then
                                            local txt = table.concat(out, "\r\n");
                                            file_new:WriteString(txt);
                                            file_new:close();
                                        end
                                    end
                                end
                            end
                        end
                        
						file:close();
					else
						LOG.std(nil, "error", "TerraClonePage", "unable to open file %s", filename)
					end
				end
			end	
		end
		config_file:close();

		if(not has_dest_config) then
			local new_x, new_z = (dest_x+0.5)*region_width, (dest_z+0.5)*region_width
			ParaScene.GetPlayer():SetPosition(new_x, 0, new_z);
			local attr = ParaTerrain.GetAttributeObjectAt(x,z);
			attr:SetField("IsModified", true)
			ParaTerrain.SaveTerrain(false, false);
			LOG.std(nil, "warn", "TerraClonePage", "generating root config. one may need to call this function twice")
		end
	else
		LOG.std(nil, "error", "TerraClonePage", "unable to open file %s", filename)
	end
end