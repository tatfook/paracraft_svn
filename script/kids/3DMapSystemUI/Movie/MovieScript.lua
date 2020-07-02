--[[
Title: movie script
Author(s): LiXizhi
Date: 2008/8/19
Desc: movie script is a tree-like hierachy, containing a number of movies, clips, camera shots, and tracks(assets) for cameras, events and sounds, 
each clip contains a number of camera shots that belongs to the same scene. each camera shot references tracks in the assets and movie is defined as the playback of all camera shots in sequence.
movie script can be serialized to and from xml (mcml).
movie script <===> xml(mcml) file

To load a movie script manually
<verbatim>
	NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieScript.lua");
	local MovieScript = Map3DSystem.Movie.MovieScript:new("script/kids/3DMapSystemUI/Movie/test/test_moviescript.xml");
	MovieScript:SaveAs();
</verbatim>

To create/get movie script using the manager class, it ensures that a given script is loaded only once.
<verbatim>
	NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieScript.lua");
	local MovieScript = Map3DSystem.Movie.MovieScriptManager.GetScript("script/kids/3DMapSystemUI/Movie/test/test_moviescript.xml");
	local node = MovieScript:GetMoviesNode();
	local node = MovieScript:GetCamerasNode();
	local node = MovieScript:GetClipsNode();
	local node = MovieScript:GetEventsNode();
	local node = MovieScript:GetSoundsNode();
</verbatim>
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieScript.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieTracks.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieManager.lua");
-- movie script instance class
local MovieScript = {
	filename = nil, 
	-- the root node object
	rootNode = nil,
	
	--
	-- private
	--
	-- keep some references for fast traversal
	-- the movies node
	moviesNode = nil,
	clipsNode = nil,
	assetsNode = nil,
	
	camerasNode = nil,
	skysNode = nil,
	landsNode = nil,
	oceansNode = nil,
	captionsNode = nil,
	actorsNode = nil,
	buildingsNode = nil,
	plantsNode = nil,
	effectsNode = nil,
	soundsNode = nil,
	staticAssetsNode = nil,
	index = 0,
	-- below member's can be imported in a clip once
	limitMember = {
		["pe:movie-camera-item"] = true,
		["pe:movie-sky-item"] = true,
		["pe:movie-land-item"] = true,
		["pe:movie-ocean-item"] = true,
		["pe:movie-caption-item"] = true,
	},
	Icon = 
	{
		["pe:movie-clip"] = "Texture/3DMapSystem/AppIcons/CG_64.dds",
		["pe:movie-camera"] = "Texture/3DMapSystem/AppIcons/VideoRecorder_64.dds",
		["pe:movie-sky"] = "Texture/3DMapSystem/MainBarIcon/Sky.png",
		["pe:movie-land"]= "Texture/3DMapSystem/MainBarIcon/Terrain.png",
		["pe:movie-ocean"]= "Texture/3DMapSystem/MainBarIcon/Water.png",
		["pe:movie-caption"]= "Texture/3DMapSystem/AppIcons/Discussion_64.dds",
		["pe:movie-actor"]= "Texture/3DMapSystem/Creator/Level1_NC.png",
		["pe:movie-building"]= "Texture/3DMapSystem/Creator/Level1_BCS.png",
		["pe:movie-plant"] = "Texture/3DMapSystem/Creator/NM_Trees.png",
		["pe:movie-effect"]= "Texture/3DMapSystem/Creator/NM_Particle.png",
		["pe:movie-sound"]= "Texture/3DMapSystem/AppIcons/Noname2.dds",
		["pe:movie-control"] = "Texture/3DMapSystem/AppIcons/Blueprint_64.dds",
		
		["pe:movie-clip-item"] = "Texture/3DMapSystem/AppIcons/CG_64.dds",
		["pe:movie-camera-item"] = "Texture/3DMapSystem/AppIcons/VideoRecorder_64.dds",
		["pe:movie-sky-item"] = "Texture/3DMapSystem/MainBarIcon/Sky.png",
		["pe:movie-land-item"]= "Texture/3DMapSystem/MainBarIcon/Terrain.png",
		["pe:movie-ocean-item"]= "Texture/3DMapSystem/MainBarIcon/Water.png",
		["pe:movie-caption-item"]= "Texture/3DMapSystem/AppIcons/Discussion_64.dds",
		["pe:movie-actor-item"]= "Texture/3DMapSystem/Creator/Level1_NC.png",
		["pe:movie-building-item"]= "Texture/3DMapSystem/Creator/Level1_BCS.png",
		["pe:movie-plant-item"] = "Texture/3DMapSystem/Creator/NM_Trees.png",
		["pe:movie-effect-item"]= "Texture/3DMapSystem/Creator/NM_Particle.png",
		["pe:movie-sound-item"]= "Texture/3DMapSystem/AppIcons/Noname2.dds",
		["pe:movie-control-item"]= "Texture/3DMapSystem/AppIcons/Blueprint_64.dds",
	}
};
Map3DSystem.Movie.MovieScript = MovieScript;

-- load from a movie script. 
-- @param filename: the movie script file name. 
function MovieScript:new(filename)
	local o = {
		filename = filename,
	};
	
	setmetatable(o, self)
	self.__index = self
	o:Reload();
	return o
end
-- update mapping 
function MovieScript:UpdateMapping(outMapping, node, sIDName)
	outMapping = outMapping or {};
	if(node) then
		local subNode;
		for subNode in node:next() do
			local id = subNode:GetNumber(sIDName);
			if(id)then
				outMapping[id] = subNode;
				self:GetLastID()
			end
		end 
	end
	return outMapping;
end
-- get a unique id
function MovieScript:GetLastID()
	self.index = self.index + 1;
	return self.index;
end		
function MovieScript:CheckExistNodes(parentNode,child_mcmlName)
	if(not parentNode or not child_mcmlName)then return; end
	local node = parentNode:GetChild(child_mcmlName);
	if(not node)then
		node =  Map3DSystem.mcml.new(nil, {name = child_mcmlName})
		parentNode:AddChild(node);
	end
	return node;
end
-- reload movie script from the self.filename 
function MovieScript:Reload()
	if(self.filename == nil) then
		return;
	end	
	local xmlRoot = ParaXML.LuaXML_ParseFile(self.filename);
	if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
		-- parsing the data nodes and generate redundant information for data management. 
		xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
		NPL.load("(gl)script/ide/XPath.lua");
		
		-- root: pe:moviescript
		self.rootNode = nil;
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "//pe:moviescript") do
			self.rootNode = node;
			local lastindex = node:GetNumber("index");
			if(lastindex)then
				self.index = lastindex;
			else
				self.index = 100;
			end
			break;
		end
		
		if(self.rootNode) then
			-- generate redundant information for data management. 
			self.moviesNode = self:CheckExistNodes(self.rootNode,"pe:movies");
			

			self.clipsNode = self:CheckExistNodes(self.rootNode,"pe:movie-clips");
			self.assetsNode = self:CheckExistNodes(self.rootNode,"pe:movie-assets");
			
			self.camerasNode = self:CheckExistNodes(self.assetsNode,"pe:movie-cameras");
			self.skysNode = self:CheckExistNodes(self.assetsNode,"pe:movie-skys");
			self.landsNode = self:CheckExistNodes(self.assetsNode,"pe:movie-lands");
			self.oceansNode = self:CheckExistNodes(self.assetsNode,"pe:movie-oceans");
			self.captionsNode = self:CheckExistNodes(self.assetsNode,"pe:movie-captions");
			self.actorsNode = self:CheckExistNodes(self.assetsNode,"pe:movie-actors");
			self.buildingsNode = self:CheckExistNodes(self.assetsNode,"pe:movie-buildings");
			self.plantsNode = self:CheckExistNodes(self.assetsNode,"pe:movie-plants");
			self.effectsNode = self:CheckExistNodes(self.assetsNode,"pe:movie-effects");		
			self.soundsNode = self:CheckExistNodes(self.assetsNode,"pe:movie-sounds");
			self.controlsNode = self:CheckExistNodes(self.assetsNode,"pe:movie-controls");
			
			self.staticAssetsNode = self:CheckExistNodes(self.rootNode,"pe:movie-static-assets");
			self.actorAssetsNode = self:CheckExistNodes(self.staticAssetsNode,"pe:movie-actor-assets");
			self.buildingAssetsNode = self:CheckExistNodes(self.staticAssetsNode,"pe:movie-building-assets");
			self.plantAssetsNode = self:CheckExistNodes(self.staticAssetsNode,"pe:movie-plant-assets");
			self.controlAssetsNode = self:CheckExistNodes(self.staticAssetsNode,"pe:movie-control-assets");
			
			self:ChangeClipNodes()
			self:ChangeAssetNodes();
			self:ChangeStaticAssetNodes()
			--...
			-- all static asset nodes
			
			-----mapping
			self.movies_mapping = self:UpdateMapping(nil, self.moviesNode, "id");
			self.clips_mapping = self:UpdateMapping(nil, self.clipsNode, "id");
			
			self.cameras_mapping = self:UpdateMapping(nil, self.camerasNode, "id");
			self.skys_mapping = self:UpdateMapping(nil, self.skysNode, "id");
			self.lands_mapping = self:UpdateMapping(nil, self.landsNode, "id");
			self.oceans_mapping = self:UpdateMapping(nil, self.oceansNode, "id");
			self.captions_mapping = self:UpdateMapping(nil, self.captionsNode, "id");
			self.actors_mapping = self:UpdateMapping(nil, self.actorsNode, "id");
			self.buildings_mapping = self:UpdateMapping(nil, self.buildingsNode, "id");
			self.plants_mapping = self:UpdateMapping(nil, self.plantsNode, "id");
			self.effects_mapping = self:UpdateMapping(nil, self.effectsNode, "id");
			self.sounds_mapping = self:UpdateMapping(nil, self.soundsNode, "id");
			self.controls_mapping = self:UpdateMapping(nil, self.controlsNode, "id");
			
			self.actor_assets_mapping = self:UpdateMapping(nil, self.actorAssetsNode, "assetid");
			self.building_assets_mapping = self:UpdateMapping(nil, self.buildingAssetsNode, "assetid");
			self.plant_assets_mapping = self:UpdateMapping(nil, self.plantAssetsNode, "assetid");
			self.control_assets_mapping = self:UpdateMapping(nil, self.controlAssetsNode, "assetid");
			
			
		else
			commonlib.log("warning: failed loading movie script %s, because the pe:moviescript node is not found\n", self.filename);
		end
	else
		commonlib.log("warning: failed loading movie script %s, the file does not exist or has xml syntax errors\n", self.filename);
	end
end
-- save the current movie script 
-- @param filename: if nil, it is self.filename 
function MovieScript:SaveAs(filename)
	filename = filename or self.filename
	local file = ParaIO.open(filename, "w");
	if(file ~= nil and file:IsValid()) then
		local s = self:ToMcml();		
		
		file:WriteString(s)	
	end
	file:close();
end
function MovieScript:OutPut(filename)
	filename = filename or self.filename
	local file = ParaIO.open(filename, "w");
	if(file ~= nil and file:IsValid()) then
		local s = self:GetStoryBoardsMcml();
		file:WriteString(s)	
	end
	file:close();
end
-- return the string of <pe:moviescript>
function MovieScript:ToMcml()
	local movies = self:GetMoviesMcml();
	local clips = self:GetClipsMcml();
	local assets = self:GetAssetsMcml();
	local staticAssets = self:GetStaticAssetsMcml();
	
	local moviescript = string.format('<?xml version="1.0" encoding="utf-8"?>\r\n<pe:moviescript xmlns:pe="www.paraengine.com/pe" index="%s">',self.index);
	moviescript = moviescript.."\r\n"..movies.."\r\n"..clips.."\r\n"..assets.."\r\n"..staticAssets.."\r\n".."</pe:moviescript>";
	moviescript = ParaMisc.EncodingConvert("", "utf-8", moviescript)
	return moviescript;
end
function MovieScript:GetMoviesMcml()
	local node = self.moviesNode;
	local s = self:GetNodesMcml(node).."\r\n";
	local result = string.format("<%s>%s</%s>",node.name,s,node.name);
	return result;
end
function MovieScript:GetClipsMcml()
	local node = self.clipsNode;
	local s = self:GetNodesMcml(node).."\r\n";
	local result = string.format("<%s>%s</%s>",node.name,s,node.name);
	return result;
end
function MovieScript:GetAssetsMcml()
	local nodes = self.assetsNode;
	local node;
	local result = "";
	for node in nodes:next() do
		local s = self:GetNodesMcml(node,true).."\r\n";
		s= string.format("<%s>%s</%s>",node.name,s,node.name);
		result  = result .. "\r\n" ..s;
	end
	local result = string.format("<%s>%s</%s>",nodes.name,result,nodes.name);
	return result;
end
function MovieScript:GetStaticAssetsMcml()
	local nodes = self.staticAssetsNode;
	local node;
	local result = "";
	for node in nodes:next() do
		local s = self:GetStaticNodesMcml(node).."\r\n";
		s= string.format("<%s>%s</%s>",node.name,s,node.name);
		result  = result .. "\r\n" ..s;
	end
	local result = string.format("<%s>%s</%s>",nodes.name,result,nodes.name);
	return result;
end
function MovieScript:TitleToMcml(node)
	local result = "";
	if(not node)then return result; end
	local data = node["TitleValue"] or "";
	result = string.format("<%s>%s</%s>",node.name,data,node.name);
	return result;
end
function MovieScript:McmlToTitle(node)
	if(not node)then return; end
	local v = node[1];
	if(v)then
		node:ClearAllChildren();
		node["TitleValue"] = v;
	end
end
function MovieScript:DescToMcml(node)
	local result = "";
	if(not node)then return result; end
	local data = node["DescValue"] or "";
	result = string.format("<%s>%s</%s>",node.name,data,node.name);
	return result;
end
function MovieScript:McmlToDesc(node)
	if(not node)then return; end
	local v = node[1];
	if(v)then
		node:ClearAllChildren();
		node["DescValue"] = v;
	end
end
function MovieScript:ValueToMcml(nodes)
	local result = "";
	if(not nodes)then return result; end
	local node;
	for node in nodes:next() do
		local enabled = node:GetString("enabled") or "";
		local assetid = node:GetString("assetid") or "";
		result = result .. "\r\n"..string.format('<%s enabled="%s" assetid = "%s" />',node.name,enabled,assetid);
	end
	result = string.format("<%s>%s</%s>",nodes.name,result,nodes.name);
	return result;
end
function MovieScript:ValueToKeyFrames(nodes,parentNode)
	if(not nodes)then return; end
	local v = nodes[1];
	if(v)then
		local keyframes = Map3DSystem.Movie.mcml_controls.create(v);
		if(keyframes)then
			nodes:ClearAllChildren();
			local __KeyFrames__Node = Map3DSystem.mcml.new(nil, {name = "__KeyFrames__Node"})
			__KeyFrames__Node["KeyFrames"] = keyframes;
			nodes:AddChild(__KeyFrames__Node);
			-- like <pe:movie-actor id="121">
			keyframes["ParentMcmlNode"] = parentNode;
		end
	end
end
function MovieScript:ChangeClipNodes()
	local node;
	for node in self.clipsNode:next() do
		local titleNode = node:GetChild("title");
		self:McmlToTitle(titleNode)
		local descNode = node:GetChild("desc");
		self:McmlToDesc(descNode)
	end
end
function MovieScript:ChangeAssetNodes()
	local nodes
	for nodes in self.assetsNode:next() do
		local node;
		for node in nodes:next() do
			local titleNode = node:GetChild("title");
			self:McmlToTitle(titleNode)
			local descNode = node:GetChild("desc");
			self:McmlToDesc(descNode)
			local valueNode = node:GetChild("value");
			self:ValueToKeyFrames(valueNode,node)
		end
	end
end
function MovieScript:ChangeStaticAssetNodes()
	local static_assetNodes = self.staticAssetsNode;
	if(not static_assetNodes)then return; end
	local assetNodes;
		for assetNodes in static_assetNodes:next() do
			if(assetNodes)then
				local node;
				for node in assetNodes:next() do
					local id = node:GetString("assetid");
					if(node and node[1])then
						local value = node[1];
						value = commonlib.LoadTableFromString(value)
						if(value)then
							node[1] = value;
						end
					end
				end
			end
		end
end
function MovieScript:KeyFramesValueToMcml(nodes)
	local result = "";
	if(not nodes)then return result; end
	local node;
	for node in nodes:next() do	
		if(node and node.name == "__KeyFrames__Node")then
			local keyframes = node["KeyFrames"];
			if(keyframes)then
				local str = keyframes:ReverseToMcml();
				if(str)then
					result = result .."\r\n"..str;
				end
			end
		end
	end
	result = string.format("<%s>%s</%s>",nodes.name,result,nodes.name);
	return result;
end
function MovieScript:GetNodesMcml(nodes,type)
	local result = "";
	if(not nodes)then return result; end
	local node;
	local s = "";
	for node in nodes:next() do
		local id = node:GetString("id") or "id is nil";
		local title = self:TitleToMcml(node:GetChild("title"))or "title is nil";
		local desc = self:DescToMcml(node:GetChild("desc"))or "desc is nil";
		local value;
		if(type == nil)then
			value = self:ValueToMcml(node:GetChild("value"))or "value is nil";
		else
			value = self:KeyFramesValueToMcml(node:GetChild("value"))or "KeyFrames value is nil";
		end
		local id_str = string.format([[id ="%s" ]],id);
		local captionid = node:GetString("captionid");
		if(captionid)then
			 id_str = id_str .. string.format([[captionid ="%s" ]],captionid);
		end
		local soundid = node:GetString("soundid");
		if(soundid)then
			 id_str = id_str .. string.format([[soundid ="%s" ]],soundid);
		end
		local s = string.format([[<%s %s>%s%s%s</%s>]],node.name,id_str,title,desc,value,node.name);
		
		result = result .. "\r\n" .. s;
	end
		return result;
end
function MovieScript:GetStaticNodesMcml(nodes)
	local result = "";
	if(not nodes)then return result; end
	local node;
	for node in nodes:next() do
		local assetid = node:GetString("assetid");
		local value =node[1] or "";
		value = commonlib.serialize(value);
		value = "<![CDATA["..value.."]]>";
		local s = string.format('<%s assetid="%s">%s</%s>',node.name,assetid,value,node.name);
		result = result .. "\r\n" .. s;
	end
	return result;
end
-- return a mcmlNode:
--[[<pe:name id ="">
		<title></title>
		<desc></desc>
		<value></value>
	</pe:movie-clip>
--]]
function MovieScript:ConstructNode(mcmlName,update,title,desc,value)
	if(not mcmlName)then return; end;
	local id = self:GetLastID();
	local parent_node = Map3DSystem.mcml.new(nil, {name = mcmlName})
	parent_node:SetAttribute("id",id);
	local node =  Map3DSystem.mcml.new(nil, {name = "title"})
	title = title or self:GetNodeTypeName(mcmlName)..":"..id;
	node["TitleValue"] = title;
	parent_node:AddChild(node);
	
	node =  Map3DSystem.mcml.new(nil, {name = "desc"})
	desc = desc or "";
	--node:SetValue(desc);
	parent_node:AddChild(node);
	
	node =  Map3DSystem.mcml.new(nil, {name = "value"})
	value = value or "";
	--node:SetValue(value);
	parent_node:AddChild(node);
	
	if(update)then
		local name = mcmlName.."s";
		local libs,mapping= self:GetNodesFromMcmlName(name);
		if(libs and mapping)then
			libs:AddChild(parent_node);
			mapping[id] = parent_node;
		end
	end
	return parent_node;
end
function MovieScript:GetAssetNodeFromItemNodeName(mcmlName)
	local nodes,mapping;
	if(mcmlName == "pe:movie-clip-item")then
		nodes,mapping = self:GetNodesFromMcmlName("pe:movie-clips")
	elseif(mcmlName == "pe:movie-camera-item")then
		nodes,mapping = self:GetNodesFromMcmlName("pe:movie-cameras")
	elseif(mcmlName == "pe:movie-sky-item")then
		nodes,mapping = self:GetNodesFromMcmlName("pe:movie-skys")
	elseif(mcmlName == "pe:movie-land-item")then
		nodes,mapping = self:GetNodesFromMcmlName("pe:movie-lands")
	elseif(mcmlName == "pe:movie-ocean-item")then
		nodes,mapping = self:GetNodesFromMcmlName("pe:movie-oceans")
	elseif(mcmlName == "pe:movie-caption-item")then
		nodes,mapping = self:GetNodesFromMcmlName("pe:movie-captions")
	elseif(mcmlName == "pe:movie-actor-item")then
		nodes,mapping = self:GetNodesFromMcmlName("pe:movie-actors")
	elseif(mcmlName == "pe:movie-building-item")then
		nodes,mapping = self:GetNodesFromMcmlName("pe:movie-buildings") 
	elseif(mcmlName == "pe:movie-plant-item")then
		nodes,mapping = self:GetNodesFromMcmlName("pe:movie-plants") 
	elseif(mcmlName == "pe:movie-effect-item")then
		nodes,mapping = self:GetNodesFromMcmlName("pe:movie-effects") 
	elseif(mcmlName == "pe:movie-sound-item")then
		nodes,mapping = self:GetNodesFromMcmlName("pe:movie-sounds") 
	elseif(mcmlName == "pe:movie-control-item")then
		nodes,mapping = self:GetNodesFromMcmlName("pe:movie-controls") 
	end
	return nodes,mapping
end
function MovieScript:GetNodesFromMcmlName(mcmlName)
	if(not mcmlName)then return; end;
	if(mcmlName == "pe:movies")then
		return self.moviesNode,self.movies_mapping;
	elseif(mcmlName == "pe:movie-clips")then
		return self.clipsNode,self.clips_mapping;
	elseif(mcmlName == "pe:movie-assets")then
		return self.assetsNode; -- mapping is nil
	elseif(mcmlName == "pe:movie-cameras")then
		return self.camerasNode,self.cameras_mapping;
	elseif(mcmlName == "pe:movie-skys")then
		return self.skysNode,self.skys_mapping;
	elseif(mcmlName == "pe:movie-lands")then
		return self.landsNode,self.lands_mapping;
	elseif(mcmlName == "pe:movie-oceans")then
		return self.oceansNode,self.oceans_mapping;
	elseif(mcmlName == "pe:movie-captions")then
		return self.captionsNode,self.captions_mapping;
	elseif(mcmlName == "pe:movie-actors")then
		return self.actorsNode,self.actors_mapping;
	elseif(mcmlName == "pe:movie-buildings")then
		return self.buildingsNode,self.buildings_mapping;
	elseif(mcmlName == "pe:movie-plants")then
		return self.plantsNode,self.plants_mapping;
	elseif(mcmlName == "pe:movie-effects")then
		return self.effectsNode,self.effects_mapping;
	elseif(mcmlName == "pe:movie-sounds")then
		return self.soundsNode,self.sounds_mapping;
	elseif(mcmlName == "pe:movie-controls")then
		return self.controlsNode,self.controls_mapping;
	elseif(mcmlName == "pe:movie-static-assets")then
		return self.staticAssetsNode;
	elseif(mcmlName == "pe:movie-actor-assets")then
		return self.actorAssetsNode,self.actor_assets_mapping;
	elseif(mcmlName == "pe:movie-building-assets")then
		return self.buildingAssetsNode,self.building_assets_mapping;
	elseif(mcmlName == "pe:movie-plant-assets")then
		return self.plantAssetsNode,self.plant_assets_mapping;
	elseif(mcmlName == "pe:movie-control-assets")then
		return self.controlAssetsNode,self.control_assets_mapping;
	end
end
-- return a mcmlNode: <pe:name assetid="3"  enabled="true" />
function MovieScript:ConstructItemNode(mcmlName,assetid,enabled)
	if(not mcmlName)then return; end;	
	local node = Map3DSystem.mcml.new(nil, {name = mcmlName,})
	node:SetAttribute("assetid",assetid or "");
	node:SetAttribute("enabled",enabled or "true");
	return node;
end
function MovieScript:ConstructStaticAssetNode(mcmlName,assetid)
	if(not mcmlName or not assetid)then return; end;
	if(mcmlName == "pe:movie-actor" or mcmlName == "pe:movie-building" or mcmlName == "pe:movie-plant" or mcmlName == "pe:movie-control")then	
		mcmlName = mcmlName.."-asset";
		local name = mcmlName.."s";
		local libs,mapping= self:GetNodesFromMcmlName(name);
		if(libs and mapping)then
			local child;
			for child in libs:next() do
				local id = child:GetNumber("assetid");
				if(id == tonumber(assetid))then
					-- can't add the same value
					return;
				end
			end
			local node = Map3DSystem.mcml.new(nil, {name = mcmlName,})
			node:SetAttribute("assetid",assetid or "");
			libs:AddChild(node);
			mapping[assetid] = node;
			return node;
		end
	end
end
function MovieScript:GetNodeTypeName(mcmlName)
	local name;
	if(not mcmlName)then return name end;
	if(mcmlName == "pe:movie" or mcmlName == "pe:movies")then
		name = "电影";
	elseif(mcmlName == "pe:movie-clip" or mcmlName == "pe:movie-clip-item" or mcmlName == "pe:movie-clips")then
		name = "胶片";
	elseif(mcmlName == "pe:movie-camera" or mcmlName == "pe:movie-camera-item" or mcmlName == "pe:movie-cameras")then
		name = "镜头";
	elseif(mcmlName == "pe:movie-sky" or mcmlName == "pe:movie-sky-item" or mcmlName == "pe:movie-skys")then
		name = "天空";
	elseif(mcmlName == "pe:movie-land" or mcmlName == "pe:movie-land-item" or mcmlName == "pe:movie-lands")then
		name = "陆地";
	elseif(mcmlName == "pe:movie-ocean" or mcmlName == "pe:movie-ocean-item" or mcmlName == "pe:movie-oceans")then
		name = "海洋";
	elseif(mcmlName == "pe:movie-caption" or mcmlName == "pe:movie-caption-item" or mcmlName == "pe:movie-captions")then
		name = "字幕";
	elseif(mcmlName == "pe:movie-actor" or mcmlName == "pe:movie-actor-item" or mcmlName == "pe:movie-actors")then
		name = "人物";
	elseif(mcmlName == "pe:movie-building" or mcmlName == "pe:movie-building-item" or mcmlName == "pe:movie-buildings")then
		name = "建筑";
	elseif(mcmlName == "pe:movie-plant" or mcmlName == "pe:movie-plant-item" or mcmlName == "pe:movie-plant")then
		name = "植物";
	elseif(mcmlName == "pe:movie-effect" or mcmlName == "pe:movie-effect-item" or mcmlName == "pe:movie-effects")then
		name = "特效";
	elseif(mcmlName == "pe:movie-sound" or mcmlName == "pe:movie-sound-item" or mcmlName == "pe:movie-sounds")then
		name = "声音";
	elseif(mcmlName == "pe:movie-control" or mcmlName == "pe:movie-control-item" or mcmlName == "pe:movie-controls")then
		name = "控件";
	end
	return name;
end
function MovieScript:DeleteAssetNodeByTargetName(name)
	local node = self:GetAssetNodeByTargetName(name);
	if(node)then
		self:RemoveAssetNode(node);
	end
end
function MovieScript:GetAssetNodeByTargetName(name)
	if(not name)then return end
	local assetsNode = self.assetsNode;
	local assetNode;
	for assetNode in assetsNode:next() do
		local child;
		for child in assetNode:next() do
			local valueNode = child:GetChild("value");
			local node;
			for node in valueNode:next() do	
				if(node and node.name == "__KeyFrames__Node")then
					local keyframes = node["KeyFrames"];
					if(keyframes)then
						if(keyframes.TargetName == name)then
							return child;
						end
					end
				end
			end
		end
	end
end
-- remove <pe:movie-clip id ="1"> or <pe:movie-assets>'s child
function MovieScript:RemoveAssetNode(node)
	if(not node)then return; end
	local mcmlName =node.name;
	local parentNodes,parentMapping;
	local id = node:GetNumber("id");
	parentNodes,parentMapping =  self:GetNodesFromMcmlName(mcmlName.."s");
	node:Detach();
	if(parentMapping)then
		parentMapping[id] = nil;
	end
	if(mcmlName ~= "pe:movie-clip")then
		local clip;
		local deleteList = {};
		for clip in self.clipsNode:next() do
			local valueNode = clip:GetChild("value");
			if(valueNode)then
				local item;
				for item in valueNode:next() do
					local assetid = item:GetNumber("assetid");
					if(id == assetid)then				
						table.insert(deleteList,item);
					end
				end
			end
		end
		-- detach
		for __,v in ipairs(deleteList) do
			v:Detach();
		end
		
		-- deletet static asset node
		local assetName = mcmlName.."-assets";
		local assetNodes,assetMapping = self:GetNodesFromMcmlName(assetName);
		if(assetMapping)then
			local item = assetMapping[id];
			if(item)then
				item:Detach();
				assetMapping[id] = nil;
			end
		end
	else
		local movie;
		local deleteList = {};
		for movie in self.moviesNode:next() do
			local valueNode = movie:GetChild("value");
			if(valueNode)then
				local item;
				for item in valueNode:next() do
					local assetid = item:GetNumber("assetid");
					if(id == assetid)then
						table.insert(deleteList,item);
					end
				end
			end
		end
		-- detach
		for __,v in ipairs(deleteList) do
			v:Detach();
		end
	end	
end
function MovieScript:RemoveAllAssetNode(mcmlName)
	if(not mcmlName)then return; end
	local nodes,__ = self:GetNodesFromMcmlName(mcmlName);
	if(nodes)then
		local deleteList = {};
		local node;
		for node in nodes:next() do
			table.insert(deleteList,node);
		end
		-- detach
		for __,v in ipairs(deleteList) do
			local id = v:GetNumber("id");
			self:RemoveAssetNode(v);
		end
	end
end
function MovieScript:CanImported(parentNode,node)
	if(not parentNode or not node)then return false; end
	local hadLimited = self.limitMember[node.name];	
	if(not hadLimited)then 
		return true;
	end
	local child;
	for child in parentNode:next() do
		if(child.name == node.name)then
			return false;
		end
	end
	return true;
end
function MovieScript:ImportAssetToClip(asset,clip)
	if(not asset or not clip)then return; end
	local mcmlName = asset.name.."-item";
	local assetid = asset:GetString("id");
	local enabled = "true";
	local node = self:ConstructItemNode(mcmlName,assetid,enabled)
	local valueNode = clip:GetChild("value");
	if(valueNode)then
		local can = self:CanImported(valueNode,node);
		if(can)then
			valueNode:AddChild(node);
			return true;
		end
	end
end
function MovieScript:ImportClipToMovie(clip,movie)
	if(not clip or not movie)then return; end
	local mcmlName = clip.name.."-item";
	local assetid = clip:GetString("id");
	local enabled = "true";
	local node = self:ConstructItemNode(mcmlName,assetid,enabled)
	
	local valueNode = movie:GetChild("value");
	if(valueNode)then
		valueNode:AddChild(node);
	end
end
function MovieScript:GetPlayMovieClips()
	local movies = self.moviesNode;
	local movie = movies:GetChild(1);
	local root_mc = CommonCtrl.Animation.Motion.MovieClip:new();
	local root_layer = CommonCtrl.Animation.Motion.LayerManager:new();
	if(movie)then
		local valueNodes = movie:GetChild("value");
		local item;
		for item in valueNodes:next() do
			local id = item:GetNumber("assetid");
			local enabled = item:GetString("enabled");
			if(enabled == "true")then
				local __,mapping = self:GetAssetNodeFromItemNodeName(item.name)
				local clipNode = mapping[id];
				if(clipNode)then
					local clip_valueNodes = clipNode:GetChild("value");
					if(clip_valueNodes)then
						local clip = Map3DSystem.Movie.MovieTrackAdapter.ItemValueNodeToClip(clip_valueNodes,self)
						if(clip)then
							root_layer:AddChild(clip);						
						end
					end
				end
			end
		end	
		root_mc:AddLayer(root_layer);	
		local movie_captionid = movie:GetNumber("captionid");
		local captionNode = self.captions_mapping[movie_captionid];
		if(captionNode)then
			local clip = Map3DSystem.Movie.MovieTrackAdapter.ValueNodeToClip(captionNode:GetChild("value"),captionNode)
			if(clip)then
				local caption_layer = CommonCtrl.Animation.Motion.LayerManager:new();
				caption_layer:AddChild(clip);	
				root_mc:AddLayer(caption_layer);						
			end
		end
		local movie_soundid = movie:GetNumber("soundid");
		local soundNode = self.sounds_mapping[movie_soundid];
		if(soundNode)then
			local clip = Map3DSystem.Movie.MovieTrackAdapter.ValueNodeToClip(soundNode:GetChild("value"),soundNode)
			if(clip)then
				local sound_layer = CommonCtrl.Animation.Motion.LayerManager:new();
				sound_layer:AddChild(clip);	
				root_mc:AddLayer(sound_layer);						
			end
		end
	end
	return root_mc;
end
-- not test
function MovieScript:GetAllStaticObjectsByClip(clip)
	if(not clip)then return; end
	local valueNodes = clip:GetChild("value");
	local result = {};
	local node;
	for node in valueNodes:next() do
		local id = node:GetString("assetid");
		local mapping;
		if(node.name == "pe:movie-actor-item")then
			mapping = self.actor_assets_mapping;
		elseif(node.name == "pe:movie-building-item")then
			mapping = self.building_assets_mapping;
		elseif(node.name == "pe:movie-plant-item")then
			mapping = self.plant_assets_mapping;
		elseif(node.name == "pe:movie-control-item")then
			mapping = self.control_assets_mapping;
		end
		local value = mapping[id];
		if(value)then
			table.insert(result,value);
		end
	end
end
function MovieScript:GetAllStaticObjects()
	local static_assetNodes = self.staticAssetsNode;
	if(static_assetNodes)then
		local result = {};
		local assetNodes;
		for assetNodes in static_assetNodes:next() do
			if(assetNodes)then
				local node;
				for node in assetNodes:next() do
					local id = node:GetString("assetid");
					if(node and node[1])then
						local value = node[1];
						if(value)then
							table.insert(result,value);
						end
					end
				end
			end
		end
		return result;
	end
end
-- get duration of movie
function MovieScript:GetMovieDuration(movieNode)
	if(not movieNode)then return; end
	local frame = 0;
	local valueNode = movieNode:GetChild("value");
	if(valueNode)then
		local item;
		for item in valueNode:next() do
			if(item)then
				local id = item:GetNumber("assetid");
				local enabled = item:GetBool("enabled");
				local __,mapping = self:GetAssetNodeFromItemNodeName(item.name)
				local clipNode = mapping[id];
				if(clipNode and enabled)then
					local d = self:GetClipDuration(clipNode);
					frame = frame + d;
				end
			end
		end
	end
	return frame;
end
-- get duration of cip
function MovieScript:GetClipDuration(clipNode)
	if(not clipNode)then return; end
	local frame = 0;
	local list = self:GetClipNodeKeyFrams(clipNode);
	local k,v;
	for k,v in ipairs(list) do
		local keyframes = v;
		local d = keyframes:GetDuration() or 0;
		if(d>frame)then
			frame = d;
		end
	end
	return frame;
end
-- get duration of cip item
function MovieScript:GetClipItemDuration(clipItemNode)
	if(not clipItemNode)then return; end
	local id = clipItemNode:GetNumber("assetid");
	local __,mapping = self:GetAssetNodeFromItemNodeName(clipItemNode.name)
	if(mapping)then
		local clipNode = mapping[id];
		return self:GetClipDuration(clipNode)
	end
end
-- get duration of asset node
function MovieScript:GetAssetNodeDuration(assetNode)
	if(not assetNode)then return; end
	local keyframes = self:GetNodeKeyFrams(assetNode);
	local frame = 0;
	if(keyframes)then
		frame = keyframes:GetDuration();
	end
	return frame;
end
function MovieScript:GetClipNodeKeyFrams(clipNode)
	if(not clipNode)then return; end
	local result = {}
	local valueNode = clipNode:GetChild("value");
	if(valueNode)then
		local item;
		for item in valueNode:next() do
			if(item)then
				local keyframes = self:GetItemNodeKeyFrams(item)
				if(keyframes)then
					table.insert(result,keyframes);
				end
			end
		end
	end
	return result;
end
function MovieScript:GetItemNodeKeyFrams(itemNode)
	if(not itemNode)then return; end
	local nodes,mapping = self:GetAssetNodeFromItemNodeName(itemNode.name)
	if(mapping)then
		local id = itemNode:GetNumber("assetid");
		local node = mapping[id];
		return self:GetNodeKeyFrams(node);
	end
end
function MovieScript:GetNodeKeyFrams(node)
	if(node)then
		local valueNode = node:GetChild("value");
		if(valueNode)then
			local item;
			for item in valueNode:next() do
				if(item)then
					local frames = item["KeyFrames"];
					return frames;
				end
			end
		end
	end
end
-----------------------------------------
-- MovieScriptManager class
-----------------------------------------

-- name value pairs of all loaded movie script
local scripts = {};

-- a moviescript Manager class that keeps all loaded movie script. 
local MovieScriptManager = {
};
Map3DSystem.Movie.MovieScriptManager = MovieScriptManager;

-- create / get a movie script object
-- @param filename: the movie script file path
function MovieScriptManager.GetScript(filename,forceUpdate)
	local MovieScript = scripts[filename];
	if(not MovieScript or forceUpdate) then
		MovieScript = Map3DSystem.Movie.MovieScript:new(filename);
		-- add to manager. 
		MovieScriptManager.AddScript(filename, MovieScript)
	end	
	return MovieScript;
end

-- add a new script 
function MovieScriptManager.AddScript(filename, movie)
	scripts[filename] = movie;
end

function MovieScriptManager.RemoveScript(filename)
	scripts[filename] = nil;
end