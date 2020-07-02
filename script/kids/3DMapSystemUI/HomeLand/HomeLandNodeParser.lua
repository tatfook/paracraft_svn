--[[
Title: HomeLandNodeParser
Author(s): Leio
Date: 2009/11/8
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandNodeParser.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");
NPL.load("(gl)script/ide/Display3D/HomeLandCommonNode.lua");
NPL.load("(gl)script/ide/Display3D/SeedGridNode.lua");
NPL.load("(gl)script/ide/Display3D/HouseNode.lua");
local HomeLandNodeParser = {
}
commonlib.setfield("Map3DSystem.App.HomeLand.HomeLandNodeParser",HomeLandNodeParser);
function HomeLandNodeParser.Float2(data)
	if(type(data) == "number") then
		local v = string.format("%.2f", data);
		v = tonumber(v);
		return v;
	end	
end
function HomeLandNodeParser.commonProperty(mcmlNode)
	local self = HomeLandNodeParser;
	if(not mcmlNode)then return; end
	local params = {};
	params.x = mcmlNode:GetNumber("x");
	params.y =mcmlNode:GetNumber("y");
	params.z =mcmlNode:GetNumber("z");
	params.facing =mcmlNode:GetNumber("facing");
	params.scaling =mcmlNode:GetNumber("scaling");
	params.visible = mcmlNode:GetBool("visible");
	params.ischaracter = mcmlNode:GetBool("IsCharacter");
	params.homezone = mcmlNode:GetString("homezone");
	params.assetfile = mcmlNode:GetString("AssetFile");
	
	params.x = self.Float2(params.x);
	params.y = self.Float2(params.y);
	params.z = self.Float2(params.z);
	params.facing = self.Float2(params.facing);
	params.scaling = self.Float2(params.scaling);
	return params;
end
-----------------------------------
-- Sprite3D control
-----------------------------------
local Sprite3D = {};
HomeLandNodeParser.Sprite3D = Sprite3D;
function Sprite3D.create(mcmlNode)
	local params = HomeLandNodeParser.commonProperty(mcmlNode);
	if(not params)then return end
	local node = CommonCtrl.Display3D.SeedGridNode:new{
				node_type = "container",
				x = params.x or 0,
				y = params.y or 0,
				z = params.z or 0,
				facing = params.facing or 1,
				scaling = params.scaling or 1,
				visible = params.visible,
		}
	local name = mcmlNode:GetString("name");
	if(name)then
		node:SetUID(name);
	end
	local childnode;
	for childnode in mcmlNode:next() do		
		local child = Map3DSystem.App.HomeLand.HomeLandNodeParser.create(childnode)
		if(type(child) == "table") then
			node:AddChild(child,nil,true);
		end	
	end
	return node;
end
-----------------------------------
-- HomeLandObj_B
-----------------------------------
local HomeLandObj_B = {};
HomeLandNodeParser.HomeLandObj_B = HomeLandObj_B;
function HomeLandObj_B.create(mcmlNode)
	local params = HomeLandNodeParser.commonProperty(mcmlNode);
	local HomeLandObj = mcmlNode:GetString("HomeLandObj");--物体类型
	if(not params)then return end
	
	local node;
	if(HomeLandObj == "Grid")then
		node = CommonCtrl.Display3D.SeedGridNode:new{
				x = params.x,
				y = params.y,
				z = params.z,
				facing = params.facing,
				scaling = params.scaling,
				visible = params.visible,
				assetfile = params.assetfile,
				ischaracter = params.ischaracter,
				type = HomeLandObj,
		};
	elseif(HomeLandObj == "OutdoorHouse")then
		node = CommonCtrl.Display3D.HouseNode:new{
				x = params.x,
				y = params.y,
				z = params.z,
				facing = params.facing,
				scaling = params.scaling,
				visible = params.visible,
				assetfile = params.assetfile,
				ischaracter = params.ischaracter,
				type = HomeLandObj,
		}
	else
		node = CommonCtrl.Display3D.HomeLandCommonNode:new{
				x = params.x,
				y = params.y,
				z = params.z,
				facing = params.facing,
				scaling = params.scaling,
				visible = params.visible,
				assetfile = params.assetfile,
				ischaracter = params.ischaracter,
				type = HomeLandObj,
		}
	end
	if(node)then
		local uid =  mcmlNode:GetString("name");
		if(uid and node.SetUID)then
			node:SetUID(uid);
		end
		
		local gridInfo = mcmlNode:GetString("GridInfo");
		--if(gridInfo and node.SetGrid)then
			----在植物属性上设置 GridInfo=\"20091015T084400.953125-295|1\"
			--node:SetGrid(gridInfo);
			--
			--if(HomeLandObj == "PlantE" and node.SetSeedGridNodeUID)then
				----关联花圃的uid
				--local __,__,id,index = string.find(gridInfo,"(.+)|(.+)");
				--node:SetSeedGridNodeUID(id);
			--end
		--end
		if(gridInfo and HomeLandObj == "PlantE" and node.SetSeedGridNodeUID)then
			--关联花圃的uid
			local __,__,id,index = string.find(gridInfo,"(.+)|(.+)");
			node:SetSeedGridNodeUID(id);
		end
			
		--物体关联的item guid
		local guid =  mcmlNode:GetNumber("guid");
		if(guid and node.SetGUID)then
			node:SetGUID(guid);
		end
		--物体关联的item gsid
		local gsid =  mcmlNode:GetNumber("gsid");
		if(gsid and node.SetGSID)then
			node:SetGSID(gsid);
		end
		--音乐盒的音乐是否播放
		local music_isplaying =  mcmlNode:GetBool("music_isplaying");
		if(music_isplaying and node.SetMusicBoxPlaying)then
			node:SetMusicBoxPlaying(music_isplaying);
		end
		
		
		--在室内模型上设置 它是属于哪个室外房屋的
		local belongto_outdoor_uid = mcmlNode:GetString("belongto_outdoor_uid");
		if(belongto_outdoor_uid and node.SetOutdoorNodeUID)then
			node:SetOutdoorNodeUID(belongto_outdoor_uid);
		end
		return node;
	end
end

------------------------------------------------------------
-- Map3DSystem.App.HomeLand.HomeLandNodeParser.control_mapping
------------------------------------------------------------
HomeLandNodeParser.control_mapping = {
	["Sprite3D"] = HomeLandNodeParser.Sprite3D,
	["HomeLandObj_B"] = HomeLandNodeParser.HomeLandObj_B,
	}
function HomeLandNodeParser.create(mcmlNode) 
	if(not mcmlNode)then return; end
	local ctl = HomeLandNodeParser.control_mapping[mcmlNode.name];
	if (ctl and ctl.create) then
		-- if there is a known control_mapping, use it and return
		return ctl.create(mcmlNode);
	else
		-- if no control mapping found, create each child node. 
		local childnode;
		if(mcmlNode.next)then
			for childnode in mcmlNode:next() do
				HomeLandNodeParser.create(childnode);
			end
		end
	end
end

