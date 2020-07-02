--[[
Title: PortalSystemPage code behind file
Author(s): LiXizhi
Date: 2008/9/11
Desc: for testing only
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/PortalSystemPage.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/GlobalInventor.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/ZonePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/PortalPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/StaticObjPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/ZoneListPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/ZoneNode.lua");
NPL.load("(gl)script/ide/Display/Objects/Building3D.lua");
NPL.load("(gl)script/ide/Display/Containers/Sprite3D.lua");
NPL.load("(gl)script/ide/Encoding.lua");
local L = CommonCtrl.Locale("IDE");

local PortalSystemPage = {};
commonlib.setfield("Map3DSystem.App.Creator.PortalSystemPage", PortalSystemPage)
PortalSystemPage.TemplateFileName = "PortalTemplate.xml";
-- init 
function PortalSystemPage.OnInit()
	PortalSystemPage.page = document:GetPageCtrl();
	-- enable portal rendering when up. 
	
	PortalSystemPage.TurnOnPortal()
end
function PortalSystemPage.TurnOnPortal()
	local self = PortalSystemPage;
	if(self.PortalTurnon)then
		self.PortalTurnon = false;
		ParaScene.GetAttributeObject():SetField("ShowPortalSystem", false);
		ParaScene.GetAttributeObject():SetField("EnablePortalZone", false);
	else
		ParaScene.GetAttributeObject():SetField("ShowPortalSystem", true);
		ParaScene.GetAttributeObject():SetField("EnablePortalZone", true);
		self.PortalTurnon = true;
	end
end
function PortalSystemPage.BuildCanvas()
	NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/GlobalInventor.lua");
	NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Gears/ToolBar.lua");
	Map3DSystem.App.Inventor.Gears.ToolBar.Show();
	NPL.load("(gl)script/kids/3DMapSystemUI/Creator/PortalCanvas.lua");
	local lite3DCanvas =  Map3DSystem.App.Creator.PortalCanvas:new{
		sceneType = "Scene", -- "MiniScene" or "Scene"
		autoPick = true, -- it is always false when sceneType = "MiniScene"
	}
	local config = {
		lite3DCanvas = lite3DCanvas,
		canHistory = false,  -- it is only enabled when lite3DCanvas.autoPick = false.
		canKeyControl = true,
		canContexMenu = false,
	}
	Map3DSystem.App.Commands.Call("Profile.Inventor.Start",config);
end
-- show/hide portal rendering. 
function PortalSystemPage.OnShowPortalSystem(bShow)
	ParaScene.GetAttributeObject():SetField("ShowPortalSystem", bShow);
end

-- create a new zone node
function PortalSystemPage.NewZoneNode(params)
	if(not params)then return end;	
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	local commandManager =Map3DSystem.App.Inventor.GlobalInventor.commandManager;	
	local node = Map3DSystem.App.Creator.ZoneNode:new();
	node:Init();
	node:SetEntityParams(params);
	if(lite3DCanvas)then
		lite3DCanvas:UnselectAll();
		lite3DCanvas:AddChild(node);	
		node:SetSelected(true)
		lite3DCanvas:Update();
		Map3DSystem.App.Creator.PortalCanvasView.OnRefresh()
	end
end
-- create a new portal node
function PortalSystemPage.NewPortalNode(params)
	if(not params)then return end;	
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	local commandManager =Map3DSystem.App.Inventor.GlobalInventor.commandManager;	
	local node = Map3DSystem.App.Creator.PortalNode:new();
	node:Init();
	node:SetEntityParams(params);
	if(lite3DCanvas)then
		lite3DCanvas:UnselectAll();
		lite3DCanvas:AddChild(node);
		node:SetSelected(true)
		lite3DCanvas:Update();
		Map3DSystem.App.Creator.PortalCanvasView.OnRefresh()
	end
end
function PortalSystemPage.ConstructParams_Zone()
	local params = {};
	params["x"], params["y"], params["z"] = ParaScene.GetPlayer():GetPosition();
	params["facing"] = 0;
	params["width"] = 1;
	params["height"] = 1;
	params["depth"] = 1;
	params["zoneplanes"] = "0.5,0,0;0,0,0;-0.5,0,0;0,1,0;0,0,0.5;0,0,-0.5;"
	params["scaling"] = 1;
	params["rotation"] = {};
	params["rotation"]["x"] = 0;
	params["rotation"]["y"] = 0;
	params["rotation"]["z"] = 0;
	params["rotation"]["w"] = 1;
	return params;
end
function PortalSystemPage.ConstructParams_Portal()
	local params = {};
	params["x"], params["y"], params["z"] = ParaScene.GetPlayer():GetPosition();
	params["facing"] = 0;
	params["width"] = 0.5;
	params["height"] = 1;
	params["depth"] = 0.1;
	params["portalpoints"] = "-0.25,0,0;-0.25,1,0;0.25,1,0;0.25,0,0;"
	params["homezone"] = "";
	params["targetzone"] = "";
	params["scaling"] = 1;
	params["rotation"] = {};
	params["rotation"]["x"] = 0;
	params["rotation"]["y"] = 0;
	params["rotation"]["z"] = 0;
	params["rotation"]["w"] = 1;
	return params;
end

function PortalSystemPage.FrameGoTo(url)
	local page = PortalSystemPage.page;
	local frame = page:GetNode("subpage");
	if(frame)then
		frame.pageCtrl:Goto(url);
	end
end
function PortalSystemPage.OnStopInventor()
	NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/GlobalInventor.lua");
	Map3DSystem.App.Inventor.GlobalInventor.Stop()
end
------------------------------------------------------------
-- PortalMetasParser
------------------------------------------------------------
local PortalMetasParser = {
	--url = "script/kids/3DMapSystemUI/Creator/ZonePortal_MetaFile_Example.xml",
	--modelName = "",
}
commonlib.setfield("Map3DSystem.App.Creator.PortalMetasParser", PortalMetasParser)
function PortalMetasParser.Load()
	local self = PortalMetasParser;
	if(not self.url or not self.modelName)then return end
	--local groups = {};
	local group;
	local xmlRoot = ParaXML.LuaXML_ParseFile(self.url);
	if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
		-- parsing the data nodes and generate redundant information for data management. 
		xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
		NPL.load("(gl)script/ide/XPath.lua");
		
		self.rootNode = nil;
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "//meta") do
			self.rootNode = node;
			break;
		end
		if(self.rootNode) then
			--local meta;
			--for meta in self.rootNode:next() do
				--local group = self.Group(meta);
				--if(group)then
					--table.insert(groups,group);
				--end
			--end
			group = self.Group(self.rootNode);
		end
	end
	return group;
end
function PortalMetasParser.Header(mcmlNode)

end
function PortalMetasParser.Zone(mcmlNode)
	if(not mcmlNode)then return end
	local node = Map3DSystem.App.Creator.ZoneNode:new();
	node:Init();
	local params = {};
	local x,y,z;
		
	local name,facing,width,height,depth,zoneplanes;
	local params = {};
	
	local pos = mcmlNode:GetString("pos");
	local __,__,x,y,z = string.find(pos,"(.+),(.+),(.+)");
	x = tonumber(x);
	y = tonumber(y);
	z = tonumber(z);
	local min_box = mcmlNode:GetString("min");
	local __,__,min_box_x,min_box_y,min_box_z = string.find(min_box,"(.+),(.+),(.+)");
	min_box_x = tonumber(min_box_x);
	min_box_y = tonumber(min_box_y);
	min_box_z = tonumber(min_box_z);
	
	local max_box = mcmlNode:GetString("max");
	local __,__,max_box_x,max_box_y,max_box_z = string.find(max_box,"(.+),(.+),(.+)");
	max_box_x = tonumber(max_box_x);
	max_box_y = tonumber(max_box_y);
	max_box_z = tonumber(max_box_z);
	
	width = max_box_x - min_box_x;
	height = max_box_y - min_box_y;
	depath = max_box_z - min_box_z;
		
	name = mcmlNode:GetString("name");
	name = PortalMetasParser.modelName.."_z"..name
	zoneplanes = mcmlNode[1];

	params["x"] = x or 255;
	params["y"] = y or 0;
	params["z"] = z or 255;
	params["facing"] = facing or 0;
	params["width"] = width or 1;
	params["height"] = height or 1;
	params["depth"] = depath or 1;
	params["zoneplanes"] = zoneplanes or "0.5,0,0;0,0,0;-0.5,0,0;0,1,0;0,0,0.5;0,0,-0.5;";
	params["scaling"] = 1;
	params["rotation"] = {};
	params["rotation"]["x"] = 0;
	params["rotation"]["y"] = 0;
	params["rotation"]["z"] = 0;
	params["rotation"]["w"] = 1;
	params["name"] = name or node:GetUID();

	node:SetEntityParams(params);

	node:SetUID(name);
	return node;
end
function PortalMetasParser.Portal(mcmlNode)
	if(not mcmlNode)then return end
	local node = Map3DSystem.App.Creator.PortalNode:new();
	node:Init();
	local name,facing,width,height,depth,portalpoints,homezone,targetzone;
	
	local params = {};
	local pos = mcmlNode:GetString("pos");
	local __,__,x,y,z = string.find(pos,"(.+),(.+),(.+)");
	x = tonumber(x);
	y = tonumber(y);
	z = tonumber(z);
	local min_box = mcmlNode:GetString("min");
	local __,__,min_box_x,min_box_y,min_box_z = string.find(min_box,"(.+),(.+),(.+)");
	min_box_x = tonumber(min_box_x);
	min_box_y = tonumber(min_box_y);
	min_box_z = tonumber(min_box_z);
	
	local max_box = mcmlNode:GetString("max");
	local __,__,max_box_x,max_box_y,max_box_z = string.find(max_box,"(.+),(.+),(.+)");
	max_box_x = tonumber(max_box_x);
	max_box_y = tonumber(max_box_y);
	max_box_z = tonumber(max_box_z);
	
	width = max_box_x - min_box_x;
	height = max_box_y - min_box_y;
	depath = max_box_z - min_box_z;
		
	name = mcmlNode:GetString("name");
	name = PortalMetasParser.modelName.."_p"..name
	portalpoints = mcmlNode[1];
	homezone = mcmlNode:GetString("homezone");
	if(homezone ~= "")then
		homezone = PortalMetasParser.modelName.."_z"..homezone
	end
	targetzone = mcmlNode:GetString("targetzone");
	if(targetzone ~= "")then
		targetzone = PortalMetasParser.modelName.."_z"..targetzone
	end
	params["x"] = x or 255;
	params["y"] = y or 0;
	params["z"] = z or 255;
	params["facing"] = facing or 0;
	params["width"] = width or 0.5;
	params["height"] = height or 1;
	params["depth"] = depath or 0.1;
	params["portalpoints"] = portalpoints or "-0.25,0,0;-0.25,1,0;0.25,1,0;0.25,0,0;";
	params["homezone"] = homezone or "";
	params["targetzone"] = targetzone or "";
	params["name"] = name or node:GetUID();
	params["scaling"] = 1;
	params["rotation"] = {};
	params["rotation"]["x"] = 0;
	params["rotation"]["y"] = 0;
	params["rotation"]["z"] = 0;
	params["rotation"]["w"] = 1;
	node:SetEntityParams(params);
	
	node:SetUID(name);
	return node;
end
function PortalMetasParser.Xref(mcmlNode)
	if(not mcmlNode)then return end
	local node = CommonCtrl.Display.Objects.Building3D:new();
	node:Init();
	local params = {};
	local pos = mcmlNode:GetString("pos");
	local __,__,x,y,z = string.find(pos,"(.+),(.+),(.+)");
	x = tonumber(x);
	y = tonumber(y);
	z = tonumber(z);
	
	local AssetFile = mcmlNode:GetString("filename");
	local name = mcmlNode:GetString("name");
	name = PortalMetasParser.modelName.."_s"..name
	local homezone = mcmlNode:GetString("homezone");
	if(homezone ~= "")then
		homezone = PortalMetasParser.modelName.."_z"..homezone
	end
	params["x"] = x or 255;
	params["y"] = y or 0;
	params["z"] = z or 255;
	params["AssetFile"] = AssetFile or "";
	params["name"] = name or node:GetUID();
	params["homezone"] = homezone or "";
	params["scaling"] = 1;
	params["rotation"] = {};
	params["rotation"]["x"] = 0;
	params["rotation"]["y"] = 0;
	params["rotation"]["z"] = 0;
	params["rotation"]["w"] = 1;
	node:SetEntityParams(params);
	node:SetUID(name);
	return node;
end
function PortalMetasParser.Group(meta)
	if(not meta)then return end;
	local self = PortalMetasParser;
	local group =  CommonCtrl.Display.Containers.Sprite3D:new();
	group:Init();
	-- zones
	local zones = meta:GetChild("zones");
	if(zones)then	
		local group_zones = CommonCtrl.Display.Containers.Sprite3D:new();
		group_zones:Init();
		local v;
		for v in zones:next() do
			local node = self.Zone(v);
			group_zones:AddChild(node);
		end
		group:AddChild(group_zones);
	end
	-- portals
	local portals = meta:GetChild("portals");
	if(portals)then
		local group_portals =  CommonCtrl.Display.Containers.Sprite3D:new();
		group_portals:Init();
		local v;
		for v in portals:next() do
			local node = self.Portal(v);
			group_portals:AddChild(node);
		end
		group:AddChild(group_portals);
	end
	
	-- xrefs
	local xrefs = meta:GetChild("xrefs");
	if(xrefs)then 
		local group_xrefs =  CommonCtrl.Display.Containers.Sprite3D:new();
		group_xrefs:Init();
		local v;
		for v in xrefs:next() do
			local node = self.Xref(v);
			group_xrefs:AddChild(node);
		end
		group:AddChild(group_xrefs);
	end
	
	return group;
end
------------------------------------------------------------
-- GenMiniMapTest
--[[
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/PortalSystemPage.lua");
--Map3DSystem.App.Creator.GenMiniMapTest.OnMain(1,500)
Map3DSystem.App.Creator.GenMiniMapTest.MadeGrid()
--]]
------------------------------------------------------------
local GenMiniMapTest = {}
commonlib.setfield("Map3DSystem.App.Creator.GenMiniMapTest", GenMiniMapTest)
function GenMiniMapTest.OnMain(level,radius)
	local center_x,center_z = 20000,20000;
	--local radius = 255;
	local imagesize = math.pow(2,level) * 256;
	local outFilePath = "temp/minimap/minimap_"..level..".png";
	GenMiniMapTest.OnGenMap(radius,center_x,center_z,imagesize,outFilePath)
end
-- generate a mini map and save it to temp/minimap.png. 
function GenMiniMapTest.OnGenMap(radius,center_x,center_y,imagesize,outFilePath)
	if(not radius or not center_x or not center_y or not imagesize or not outFilePath)then return end
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
	local imagepath = outFilePath;
	ParaMovie.TakeScreenShot(imagepath, imagesize, imagesize);
	
	ParaScene.RestoreSceneState(state);
	ParaUI.ShowCursor(true);
	

	ParaAsset.LoadTexture("", imagepath, 1):UnloadAsset(); -- reload texture

	_guihelper.MessageBox("Successfully generated minimap."..outFilePath)
end
function GenMiniMapTest.MadeGrid()
	local k,len = 1,5;
	for k = 1,len do
		GenMiniMapTest.Grid(k)
	end
end
function GenMiniMapTest.Grid(level)
	if(not level)then return; end
	local filename = "temp/minimap/"..level..".grd";
	level = math.pow(2,level);
	local k,v;
	local s = "";
	for k = 0,level do
		s = s .. 256*k.."\r\n";
	end
	s = s.."-\r\n"..s;
	local file = ParaIO.open(filename, "w");
	if(file:IsValid()) then
		file:WriteString(s);
	end	
	file:close();
end