--[[
Title: 
Author(s): leio
Date: 2012/12/10
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CrazyTower/CrazyTowerProvider.lua");
local CrazyTowerProvider = commonlib.gettable("MyCompany.Aries.CrazyTower.CrazyTowerProvider")
------------------------------------------------------------
]]
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local CrazyTowerProvider = commonlib.gettable("MyCompany.Aries.CrazyTower.CrazyTowerProvider")
function CrazyTowerProvider.GetConfigFilePath()
	return "config/Aries/LobbyService/aries.crazytower.xml";
end
-- init game 
function CrazyTowerProvider.Init()
	local filepath = CrazyTowerProvider.GetConfigFilePath();
	local xmlRoot = ParaXML.LuaXML_ParseFile(filepath);
	if(CrazyTowerProvider.is_init)then
		return
	end
	CrazyTowerProvider.is_init = true;
	CrazyTowerProvider.game_templates = {};
	if(not xmlRoot) then
		LOG.std(nil, "error", "CrazyTower", "failed loading world config file %s", filepath);
	else
		local node;
		local world_index = 1;
		for node in commonlib.XPath.eachNode(xmlRoot, "//game") do
			local game_tmpl = {
				name = node.attr.name,
				worldname=node.attr.worldname,
				star = tonumber(node.attr.star),
				desc = node.attr.desc,
				loots = node.attr.loots,
				world_index = world_index,
			}
			table.insert(CrazyTowerProvider.game_templates,game_tmpl);
			world_index = world_index + 1;
		end
	end	
	LOG.std(nil, "system", "CrazyTower", "initialized from file %s", filepath);
end
function CrazyTowerProvider.GetTemplates()
	CrazyTowerProvider.Init();
	return CrazyTowerProvider.game_templates;
end
function CrazyTowerProvider.GetGameTemplate(worldname)
	if(not worldname)then
		return;
	end
	local game_templates = CrazyTowerProvider.GetTemplates();
	local k,v;
	for k,v in ipairs(game_templates) do
		if(v.worldname == worldname)then
			return v;
		end
	end
end
function CrazyTowerProvider.GetLoots(worldname)
	if(not worldname)then
		return
	end
	NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
	local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
	local loots = LobbyClientServicePage.GetLootsByWorldName(worldname,2);
	if(loots)then
        list = {};
        local line;
		for line in string.gfind(loots, "[^|]+") do
            local gsid,cnt = string.match(line,"(.+),(.+)");
            gsid = tonumber(gsid);
            cnt = tonumber(cnt) or 0;
            if(gsid)then
                table.insert(list,{
                    gsid = gsid,
                    cnt = cnt,
                })
            end
        end
		table.sort(list,function(a,b)
			return a.gsid < b.gsid;
		end);
		return list;
    end
end
function CrazyTowerProvider.IsLocked(worldname)
	if(not worldname)then
		return true;
	end
	local node = CrazyTowerProvider.GetGameTemplate(worldname);
	if(node)then
		local world_index = node.world_index or 1;
		world_index = world_index - 1;
		local __,__,__,copies = hasGSItem(50350);
		copies = copies or 0;
		if(copies >= (world_index * 5))then
			return false;
		end
	end
    return true;
end
--最后一个已经开启的副本
function CrazyTowerProvider.LastOpendWorldTempate()
	local __,__,__,copies = hasGSItem(50350);
	copies = copies or 0;
	local index = math.floor(copies/5);
	index = index + 1;
	local templates = CrazyTowerProvider.GetTemplates();
	local k,v;
	for k,v in ipairs(templates) do
		if(v.world_index == index)then
			return v;
		end
	end
end