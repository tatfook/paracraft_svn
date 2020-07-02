--[[
Title: 
Author(s): Leio
Date: 2010/01/30
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Help/MapHelp.lua");
MyCompany.Aries.Help.MapHelp.BuildFromLocalMapHtml();

NPL.load("(gl)script/apps/Aries/Help/MapHelp.lua");
MyCompany.Aries.Help.MapHelp.OnInit();

NPL.load("(gl)script/apps/Aries/Help/MapHelp.lua");
local r = MyCompany.Aries.Help.MapHelp.ParseXMLFile("config/Aries/MapGuides/FindNpc.xml");
commonlib.echo(r);

--生成xml文件
NPL.load("(gl)script/apps/Aries/Help/MapHelp.lua");
MyCompany.Aries.Help.MapHelp.ParseCsvToXmlFile("temp/mapguides/FindNpc.csv","temp/mapguides/FindGame.csv","temp/mapguides/FindItem.csv","temp/mapguides/FindNpc.xml","temp/mapguides/FindGame.xml","temp/mapguides/FindItem.xml");
------------------------------------------------------------
--]]

NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");

-- create class
local MapHelp = {
	isLoaded = false,
	find_npc_file = "config/Aries/MapGuides/FindNpc.xml",
	find_game_file = "config/Aries/MapGuides/FindGame.xml",
	find_item_file = "config/Aries/MapGuides/FindItem.xml",

	
	find_npc_map = nil,
	find_game_map = nil,
	find_item_map = nil,
	

	place = {
		["magicforest"] = { AvatarPosition = { 19909.43,11.22,20101.18,}, CameraPosition = {8.71,0.08,2.92,}, },
		["cyandragon"] = { AvatarPosition = { 20193.87,6.15,19990.38,}, CameraPosition = {15.00,0.24,-1.47,}, },
		["aquahorse"] = { AvatarPosition = { 19913.50,-2.40,19776.20,}, CameraPosition = {14.00,0.28,2.09,}, },
		["watermill"] = { AvatarPosition = { 19804.31,3.31,19597.90,}, CameraPosition = {8.86,0.33,-2.72,}, },
		["adventure"] = { AvatarPosition = { 20034.55,0.90,19631.83,}, CameraPosition = {7.13,0.10,1.86,}, },
		["sunshinestation"] = { AvatarPosition = { 20207.55,0.28,19609.29,}, CameraPosition = {8.86,0.14,-1.52,}, },
		["carnival"] = { AvatarPosition = { 20001.36,2.81,19879.09,}, CameraPosition = {7.49,0.11,-2.91,}, },
		["farmhousechick"] = { AvatarPosition = { 19895.78,2.34,19900.09,}, CameraPosition = {8.68,0.02,-3.01,}, },
		["townsquare"] = { AvatarPosition = { 20069.58,2.79,19741.63,}, CameraPosition = {8.86,0.07,-1.84,}, },
		["shoppingzone"] = { AvatarPosition = { 20168.90,5.83,19711.97,}, CameraPosition = {10.00,0.08,-2.50,}, },
		["dragonorien"] = { AvatarPosition = { 19927.48,2.10,19991.50,}, CameraPosition = {8.29,0.03,-1.81,}, },
		["lifespring"] = { AvatarPosition = { 19997.70,1.65,20007.54,}, CameraPosition = {11.03,0.09,-0.70,}, },
		["triumphsquare"] = { AvatarPosition = { 20139.68,2.66,19794.05,}, CameraPosition = {11.55,0.09,-0.51,}, },
		["library"] = { AvatarPosition = { 20193.07,9.27,19737.76,}, CameraPosition = {10.00,0.25,-0.33,}, },
		["snowarea1"] = { AvatarPosition = { 19812.81,26.93,20172.52,}, CameraPosition = {8.86,0.16,-1.56,}, },
		["squirrelvalley"] = { AvatarPosition = { 20031.93,29.95,20310.85,}, CameraPosition = {8.86,0.30,-0.62,}, },
		["snowarea3"] = { AvatarPosition = { 19755.04,77.37,20382.95,}, CameraPosition = {11.79,0.13,-2.58,}, },
		["rockyforest"] = { AvatarPosition = { 19739.62,7.50,20077.70,}, CameraPosition = {14.26,0.27,-2.79,}, },
		["starcarnival"] = { AvatarPosition = { 20313.94,-1.12,19839.36,}, CameraPosition = {8.86,0.17,-0.20,}, },
		["watermelonfield"] = { AvatarPosition = { 19784.04,1.26,19881.61,}, CameraPosition = {9.74,-0.01,2.38,}, },
		["seedfield"] = { AvatarPosition = { 19698.51,2.45,19845.02,}, CameraPosition = {8.86,0.16,2.93,}, },
		["starrylane"] = { AvatarPosition = { 19682.05,7.70,19994.02,}, CameraPosition = {12.84,0.18,-3.06,}, },
		["timeportal"] = { AvatarPosition = { 20429.79,-4.07,19607.93,}, CameraPosition = {8.86,0.22,1.53,}, },
		["forestogre"] = { AvatarPosition = { 19532.13,11.23,20116.49,}, CameraPosition = {13.10,0.32,-0.98,}, },
		["fireogre"] = { AvatarPosition = { 20372.44,0.95,20139.88,}, CameraPosition = {15.00,0.08,-0.83,}, },
		["blazingdesert"] = { AvatarPosition = { 20355.18,-1.49,20294.25,}, CameraPosition = {11.91,0.26,-1.18,}, },
		["townhall"] = { AvatarPosition = { 20066.15,6.57,19887.60,}, CameraPosition = {9.63,0.25,-0.78,}, },
		["familymanagementoffice"] = { AvatarPosition = { 20083.88,0.56,19826.41,}, CameraPosition = {13.00,0.25,-0.87,}, },
		["industryarea"] = { AvatarPosition = { 19976.09,6.28,19688.82,}, CameraPosition = {8.86,0.29,-1.33,}, },
		["honeybeefield"] = { AvatarPosition = { 19763.03,3.71,19781.98,}, CameraPosition = {14.00,0.25,0.04,}, },
		["lighthouse"] = { AvatarPosition = { 19860.55,6.77,19520.01,}, CameraPosition = {8.86,0.25,2.67,}, },
		["policestation"] = { AvatarPosition = { 20034.04,2.93,19818.38,}, CameraPosition = {7.13,0.12,-1.52,}, },
		["homeland"] = { label = "家园", isHomeland = true, AvatarPosition = {0, 0, 0}, CameraPosition = {0, 0, 0},},
	},
};
commonlib.setfield("MyCompany.Aries.Help.MapHelp", MapHelp);
--从LocalMap.html 获取跳转点的信息
function MapHelp.BuildFromLocalMapHtml()
	local self = MapHelp;
	local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
	local world_info = WorldManager:GetReturnWorld()
	
	-- local url = world_info.worldpath.."/LocalMap.html";
	local url = world_info.local_map_url or "script/apps/Aries/Desktop/WorldMaps/LocalMap.html";
	commonlib.echo("=========url");
	commonlib.echo(url);
	local xmlRoot = ParaXML.LuaXML_ParseFile(url);
	xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
	NPL.load("(gl)script/ide/XPath.lua");
	local mcmlNode;
	local place = {};
	local childnode;
	for childnode in commonlib.XPath.eachNode(xmlRoot, "//pe:mark") do
		local label = childnode:GetString("label") or "";
		local AvatarPosition = childnode:GetString("AvatarPosition") or "";
		local CameraPosition = childnode:GetString("CameraPosition") or "";
		local AvatarPosition = string.gsub(AvatarPosition, " ", "");
		local CameraPosition = string.gsub(CameraPosition, " ", "");
		local sceneX, sceneY, sceneZ = string.match(AvatarPosition, "([%-%.%d]+),([%-%.%d]+),([%-%.%d]+)");
		sceneX = tonumber(sceneX);
		sceneY = tonumber(sceneY);
		sceneZ = tonumber(sceneZ);
		local CameraObjectDistance, CameraLiftupAngle, CameraRotY = string.match(CameraPosition, "([%-%.%d]+),([%-%.%d]+),([%-%.%d]+)");
		CameraObjectDistance = tonumber(CameraObjectDistance);
		CameraLiftupAngle = tonumber(CameraLiftupAngle);
		CameraRotY = tonumber(CameraRotY);
		if(label and label ~= "")then
			place[label] = {
				AvatarPosition = { sceneX, sceneY, sceneZ },
				CameraPosition = { CameraObjectDistance, CameraLiftupAngle, CameraRotY },
			}
			local s = string.format([[["%s"] = { AvatarPosition = { %.2f,%.2f,%.2f,}, CameraPosition = {%.2f,%.2f,%.2f,}, },]],label,sceneX, sceneY, sceneZ,CameraObjectDistance, CameraLiftupAngle, CameraRotY);
			commonlib.echo(s);
		end
	end
	--local node;
	--for node in commonlib.XPath.eachNode(xmlRoot, "//pe:mcml") do
		--mcmlNode = node;
		--break;
	--end
	--function find(parentnode)
		--if(not parentnode or not parentnode.next)then return end
		--local childnode;
		--for childnode in parentnode:next() do
			--if(childnode.name == "pe:map")then
				--return childnode;
			--else
				--find(childnode)
			--end
		--end
	--end
	--local node = find(mcmlNode);
	--local place = {};
	--if(node)then
		--local childnode;
		--for childnode in node:next() do
			--if(childnode.name == "pe:mark")then
				--local label = childnode:GetString("label") or "";
				--local AvatarPosition = childnode:GetString("AvatarPosition") or "";
				--local CameraPosition = childnode:GetString("CameraPosition") or "";
				--local AvatarPosition = string.gsub(AvatarPosition, " ", "");
				--local CameraPosition = string.gsub(CameraPosition, " ", "");
				--local sceneX, sceneY, sceneZ = string.match(AvatarPosition, "([%-%.%d]+),([%-%.%d]+),([%-%.%d]+)");
				--sceneX = tonumber(sceneX);
				--sceneY = tonumber(sceneY);
				--sceneZ = tonumber(sceneZ);
				--local CameraObjectDistance, CameraLiftupAngle, CameraRotY = string.match(CameraPosition, "([%-%.%d]+),([%-%.%d]+),([%-%.%d]+)");
				--CameraObjectDistance = tonumber(CameraObjectDistance);
				--CameraLiftupAngle = tonumber(CameraLiftupAngle);
				--CameraRotY = tonumber(CameraRotY);
				--if(label and label ~= "")then
					--place[label] = {
						--AvatarPosition = { sceneX, sceneY, sceneZ },
						--CameraPosition = { CameraObjectDistance, CameraLiftupAngle, CameraRotY },
					--}
					--local s = string.format([[["%s"] = { AvatarPosition = { %.2f,%.2f,%.2f,}, CameraPosition = {%.2f,%.2f,%.2f,}, },]],label,sceneX, sceneY, sceneZ,CameraObjectDistance, CameraLiftupAngle, CameraRotY);
					--commonlib.echo(s);
				--end
				--
			--end			
		--end
	--end
end
--[[
<Item>
    <Name>麻烦树种子</Name>
    <Desc></Desc>
    <KeyPointLabel>家族管理处</KeyPointLabel>
    <KeyPoint>familymanagement</KeyPoint>
    <Position>20306.578125, 0.768661, 19737.480469|10.090211, 0.246445, 0.373684</Position>
    <Gsid>30097</Gsid>
	<World>0</World>
  </Item>
  to:
  {
	Name = "",Desc = "",KeyPointLabel = "",KeyPoint = "",Position = "",CameraPosition = "",Gsid = "",World = "",
  }
--]]
function MapHelp.ParseXMLFile(filepath)
	local self = MapHelp;
	LOG.std("", "debug","MapHelp.ParseXMLFile",filepath);

	if(not filepath)then return end

	local xmlRoot = ParaXML.LuaXML_ParseFile(filepath);
	local line;
	local result = {};
	local result_map = {};
	for line in commonlib.XPath.eachNode(xmlRoot, "/Items/Item") do
		local k,node;
		local item = {};
		for k,node in ipairs(line) do
			local name = node.name;
			local value = node[1];
			if(name == "Position")then
				if(value == "player") then
					item["Position"] = "player";
				elseif(value)then
					local section;
					local index = 0;
					for section in string.gfind(value, "[^|]+") do
						index = index + 1;
						if(section)then
							section = string.format("{%s}",section);
							section =  NPL.LoadTableFromString(section);
							if(index == 1)then
								item["Position"] = section;
							else
								item["CameraPosition"] = section;
							end
						end
					end
				end
			elseif(name == "Gsid")then
				value = tonumber(value);
				item[name] = value;
			elseif(name == "World")then
				value = tonumber(value) or 0;
				item[name] = value;
			elseif(name == "InstanceName")then
				value = tostring(value);
				if(value)then
					--转换为小写
					value = string.lower(value);
				end
				item[name] = value;

			else
				item[name] = value;
			end
		end
		table.insert(result,item);
		local InstanceName = item.InstanceName;
		if(InstanceName)then
			result_map[InstanceName] = item;
		end
	end
	return result,result_map;
end
function MapHelp.ParseCsvToXmlFile(npc_file,game_file,item_file,save_npc_file,save_game_file,save_item_file)
	local self = MapHelp;
	self.ParseCsvToXmlFile_Npc_Game(npc_file,save_npc_file);
	self.ParseCsvToXmlFile_Npc_Game(game_file,save_game_file);
	self.ParseCsvToXmlFile_Item(item_file,save_item_file);
end
function MapHelp.ParseCsvToXmlFile_Npc_Game(filepath,savefile)
	local self = MapHelp;
	if(not filepath)then return end
	local line;
	local file = ParaIO.open(filepath, "r");
	local xml_str = "";
	if(file:IsValid()) then
		line=file:readline();
		while line~=nil do 
			local __,__, Name,Desc,KeyPointLabel,KeyPoint,Position,CameraPosition= string.find(line,"(.+),(.+),(.+),(.+),(.+),(.+)");
			local pos = "";
			if(Position)then
				local __,__,x,y,z = string.find(Position,"(.+)|(.+)|(.+)");
				if(x and y and z)then
					Position = string.format("%s,%s,%s",x,y,z);
				end
			end
			if(CameraPosition)then
				local __,__,x,y,z = string.find(CameraPosition,"(.+)|(.+)|(.+)");
				if(x and y and z)then
					CameraPosition = string.format("%s,%s,%s",x,y,z);
				end
			end
			pos = string.format("%s|%s",Position or "",CameraPosition or "");
			if(filepath == "temp/mapguides/FindNpc.csv" or filepath == "temp/mapguides/FindGame.csv")then
				KeyPointLabel = "";
				KeyPoint = "";
			end
			local s = string.format("<Item><Name>%s</Name><Desc>%s</Desc><KeyPointLabel>%s</KeyPointLabel><KeyPoint>%s</KeyPoint><Position>%s</Position><Gsid></Gsid></Item>",Name or "",Desc or "",KeyPointLabel or "",KeyPoint  or "",pos  or "");
			xml_str = xml_str .. s;
			line=file:readline();
		end
		file:close();
	end
	xml_str = string.format([[<?xml version="1.0" encoding="utf-8"?><Items>%s</Items>]],xml_str);
	local file = ParaIO.open(savefile, "w");
	if(file:IsValid() == true) then
		file:WriteString(xml_str);
		file:close();
	end
end
function MapHelp.ParseCsvToXmlFile_Item(filepath,savefile)
	local self = MapHelp;
	if(not filepath)then return end
	local line;
	local file = ParaIO.open(filepath, "r");
	local xml_str = "";
	if(file:IsValid()) then
		line=file:readline();
		while line~=nil do 
			commonlib.echo(line);
			local __,__, Name,Desc,KeyPointLabel,KeyPoint,Gsid= string.find(line,"(.+),(.+),(.+),(.+),(.+)");
			local s = string.format("<Item><Name>%s</Name><Desc>%s</Desc><KeyPointLabel>%s</KeyPointLabel><KeyPoint>%s</KeyPoint><Position></Position><CameraPosition></CameraPosition><Gsid>%s</Gsid></Item>",Name,Desc,KeyPointLabel,KeyPoint,Gsid);
			xml_str = xml_str .. s;
			line=file:readline();
		end
		file:close();
	end
	xml_str = string.format([[<?xml version="1.0" encoding="utf-8"?><Items>%s</Items>]],xml_str);
	local file = ParaIO.open(savefile, "w");
	if(file:IsValid() == true) then
		file:WriteString(xml_str);
		file:close();
	end
end
function MapHelp.GotoPlaceByItem(item)
	if(item)then
		--优先级
		--1 Position and CameraPosition
		--2 KeyPoint
		--2.1 homeland
		--2.2 map key point
		local Position = item.Position;
		local CameraPosition = item.CameraPosition or {8.7055797576904, 0.22789761424065, 2.9984774589539};
		local KeyPoint = item.KeyPoint;
		local World = item.World or 0;
		local insame_world = QuestHelp.InSameWorldByNum(World);
		if(not insame_world)then
			local world_info = QuestHelp.GetWorldInfoByNum(World);
			if(world_info) then
				_guihelper.MessageBox(format("<div style='margin-left:15px;margin-top:35px;text-align:center'>目标在【%s】,无法直接传送.<br/>请从地图跳转. </div>", world_info.world_title or ""));
			else
				_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>不在当前岛屿，无法传送！</div>");
			end
			
			return
		end
		local pos;
		local camera;
		if(Position and CameraPosition)then
			pos = Position;
			camera = CameraPosition;
			if(pos and camera and pos[1] ~= 0 and pos[3] ~= 0)then
				local msg = { aries_type = "OnMapTeleport", 
						position = pos, 
						camera = camera, 
						wndName = "map", 
					};
				CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
			end
		else
			if(KeyPoint == "homeland")then
				NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
				local nid = Map3DSystem.User.nid;
				Map3DSystem.App.HomeLand.HomeLandGateway.Gohome(nid);
			else
				local place = MapHelp.place[KeyPoint];
				if(not place)then return end
				pos = place.AvatarPosition;
				camera = place.CameraPosition;
				if(pos and camera and pos[1] ~= 0 and pos[3] ~= 0)then
					local msg = { aries_type = "OnMapTeleport", 
							position = pos, 
							camera = camera, 
							wndName = "map", 
						};
					CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
				end
			end
		end
	end
end