--[[
Title: combat system minion server for Aries App
Author(s): WangTian
Date: 2012/6/24
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/minion_server.lua");

NOTE: minion_server object is valid and only valid when the related player is in combat on one arena (alive or dead)
		the minion_server object is destroyed immediately after player fled from the arena or finish the combat(victory or defeated)
------------------------------------------------------------
]]
local format = format;
-- create class
local libName = "AriesCombat_Server_Minion";
local Minion = commonlib.gettable("MyCompany.Aries.Combat_Server.Minion");

-- combat server
local combat_server = commonlib.gettable("MyCompany.Aries.Combat_Server.combat_server");
-- card server
local Card = commonlib.gettable("MyCompany.Aries.Combat_Server.Card");
-- arena class
local Arena = commonlib.gettable("MyCompany.Aries.Combat_Server.Arena");

NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");

local LOG = LOG;
local string_format = string.format;
local table_insert = table.insert;
local string_lower = string.lower;
local math_ceil = math.ceil;

local minion_templates = {};

-- init minion stats from config xml
function Minion.InitMinionStatsIfNot()
	if(not minion_templates) then
		local path = "config/Aries/Minion/MinionStats_Teen.xml"
		if(System.options.version == "teen") then
			path = "config/Aries/Minion/MinionStats_Teen.xml"
		else
			path = "config/Aries/Minion/MinionStats_Teen.xml"
		end
		local xmlRoot = ParaXML.LuaXML_ParseFile(path);
		if(not xmlRoot) then
			LOG.std(nil, "error", "Minion", "file %s does not exist", path);
		end

		for each_minion in commonlib.XPath.eachNode(xmlRoot, "/MinionStats/minion") do
			local fields = {};
			local each_field;
			for each_field in commonlib.XPath.eachNode(each_minion, "/field") do
				local name = each_stat.attr.name;
				local value = tonumber(each_stat.attr.value);
				if(name and value) then
					fields[name] = value;
				end
			end
			all_item_set_effect[tonumber(each_itemset.attr.id)] = stats;
		end
	end
end

-- get base minion params from minion gsid
function Minion.GetBaseMinionParams(minion_gsid)
	return {};
end