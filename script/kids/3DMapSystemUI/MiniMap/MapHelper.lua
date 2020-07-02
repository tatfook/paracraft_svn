--[[
Title: 
Author(s): Leio
Date: 2011/04/22
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/MapHelper.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/ExternalInterface.lua");
local MapHelper = commonlib.gettable("Map3DSystem.App.MiniMap.MapHelper");
MapHelper.size = 533.33;
--生成多少层的tile result = {1,2,3,4,5}
function MapHelper.OnGetMapLevel(start_level,end_level)
	start_level = tonumber(start_level) or 0;
	end_level = tonumber(end_level) or 0;
	start_level = start_level + 1;
	end_level = end_level + 1;
	local len = end_level - start_level;
	local result = {};
	local k;
	for k = start_level,end_level do
		table.insert(result,k);
	end
	return result;
end
function MapHelper.CreateTiles_Handle(start_index,len,start_level,end_level,world_path)
	commonlib.echo("=========MapHelper.CreateTiles_Handle");
	commonlib.echo({start_index = start_index, len = len,x = x,y = y,w = w,h = h,start_level = start_level,end_level = end_level,world_path = world_path});
	local self = MapHelper;
	local x = start_index * self.size;
	local y = x;
	local w = len * self.size;
	local h = len * self.size;
	local  tiles_path = string.format("%s/tiles",world_path);
	ParaIO.CreateDirectory(tiles_path.."/");
	--生成切片
	NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/DummySatellite.lua");
	local DummySatellite = Map3DSystem.App.MiniMap.DummySatellite;
	DummySatellite.viewRect = {
			left = x,
			top = y,
			width = w,
			height = h,
		}
	DummySatellite.default_folder = tiles_path;
	local r = self.OnGetMapLevel(start_level,end_level);
	if(not r)then return end
	DummySatellite.levelRange = r;
	DummySatellite.imagesize = 256;
	Map3DSystem.App.MiniMap.DummySatellite.GenMapNodes();
	--合成图片，只合成最后一层的图片
		
	local level = #DummySatellite.levelRange - 1;
	local len = math.pow(2,level);
		
	--composeImage(source_image,save_clip,level,self.region);
	local param = string.format("compose %s %s %d %s","map.png",tiles_path,level,self.size);
	commonlib.echo("===========ready compose image");
	commonlib.echo(param);
end
function MapHelper.ReloadRegion_Handle(start_index,len)
	local self = MapHelper;
	--开始的索引
	local start_x = start_index;
	local start_y = start_index;
	local xx,yy
	local xx_len = start_x + len - 1;
	local yy_len = start_y + len - 1; 
	for xx = start_x, xx_len do
		for yy = start_y, yy_len do
			local image_path = string.format("%s/%s_%d_%d.png","regions","move",yy,xx);
			image_path = "%WORLD%/"..image_path;
			local x = (xx + 0.5) * self.size;
			local dy = yy_len - yy;
			local y = (start_x + dy + 0.5) * self.size;
					
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
function MapHelper.Jump_Handle(x,y,z)
	commonlib.echo("======MapHelper.Jump_Handle");
	commonlib.echo({x = x, y = y, z = z});
	Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x = x, y = y, z = z});
end
function MapHelper.ShowRegion_Handle(x,z)
	Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x = x, z = z});
	local att = ParaTerrain.GetAttributeObjectAt(x,z);
	att:SetField("CurrentRegionName", "move");
	commonlib.echo{ 
		CurrentRegionName = att:GetField("CurrentRegionName", ""),
		CurrentRegionFilepath = att:GetField("CurrentRegionFilepath", ""),
		NumOfRegions = att:GetField("NumOfRegions", 0), 
	};
	_guihelper.MessageBox(att:GetField("CurrentRegionFilepath", ""));
end
function MapHelper.LoadNPCInWorld_ByFile(filepath)
	commonlib.echo("======MapHelper.LoadNPCInWorld_ByFile");
	commonlib.echo(filepath);
	if(not filepath)then return end
	local mcmlNode = ParaXML.LuaXML_ParseFile(filepath);
	local node;
	for node in commonlib.XPath.eachNode(mcmlNode, "//NPCList/NPC") do
		MapHelper.LoadNPCInWorld_BySingleNode(node)
	end
end
function MapHelper.LoadNPCInWorld_BySingleStr(str)
	commonlib.echo("======MapHelper.LoadNPCInWorld_ByStr");
	commonlib.echo(str);
	if(not str)then return end
	local mcmlNode = ParaXML.LuaXML_ParseString(str);
	MapHelper.LoadNPCInWorld_BySingleNode(mcmlNode[1]);
end
function MapHelper.LoadNPCInWorld_BySingleNode(node)
	if(not node)then return end
	local function get_pos(pos)
		if(not pos)then return end
		local a
		local result = {};
		for a in string.gfind(pos, "[^,]+") do
			table.insert(result,tonumber(a));
		end
		return result;
	end
	local name = node.attr.name;
	local npc_id = tonumber(node.attr.npc_id);
	local position = node.attr.position;
	local scaling = tonumber(node.attr.scaling);
	local facing = tonumber(node.attr.facing);
	local assetfile_char = nil;
	local scale_char = nil;
	local assetfile_model = nil;
	local scaling_model = nil;
	local ccsinfo_teen;
	
	position = get_pos(position);
	if(npc_id and position)then
		local char_node;
		for char_node in commonlib.XPath.eachNode(node, "//assetfile_char") do
			assetfile_char = char_node.attr.filename;
			scale_char = tonumber(char_node.attr.scale_char);
			if(char_node.attr.ccsinfo_teen) then
				ccsinfo_teen = NPL.LoadTableFromString(char_node.attr.ccsinfo_teen);
			end
			break;
		end
		local model_node;
		for model_node in commonlib.XPath.eachNode(node, "//assetfile_model") do
			assetfile_model = model_node.attr.filename;
			scaling_model = tonumber(model_node.attr.scaling_model);
			break;
		end

		local params = {
			name = name,
			position = position,
			facing = facing,
			scaling = scaling,
			assetfile_char = assetfile_char,
			scale_char = scale_char,
			assetfile_model = assetfile_model,
			scaling_model = scaling_model,
			isalwaysshowheadontext = true,
			ccsinfo = node.attr.ccsinfo,
			ccsinfo_teen = ccsinfo_teen,
		}
		MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(npc_id);
		MyCompany.Aries.Quest.NPC.CreateNPCCharacter(npc_id, params);
	end
end
function MapHelper.TestCall_Handle(s)
	if(not s)then return end
	_guihelper.MessageBox(s);
	ExternalInterface.Call("test_hello_wnd_call",{
			info = "received " .. s,
		});
end