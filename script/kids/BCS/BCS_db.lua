--[[
Title: character customization database. 
Author(s): WangTian
Date: 2007/7/24
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/BCS/BCS_db.lua");
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/sqlite/sqlite3.lua");

if(not BCS_db) then BCS_db={}; end

BCS_db.dbfile = "Database/characters.db";

BCS_db.GroundDir = "model/v3/components/ground/";
BCS_db.BlockDir = "model/v3/components/block/";
BCS_db.DoorDir = "model/v3/components/door/";
BCS_db.WindowDir = "model/v3/components/window/";
BCS_db.ChimneyDir = "model/v3/components/chimney/";
BCS_db.BlocktopDir = "model/v3/components/blocktop/";
BCS_db.DecoDir = "model/v3/components/deco/";

-- Debug purpose
NPL.load("(gl)script/ide/gui_helper.lua");

BCS_db.PathLists = {};


-- building block types BB stands for building block
BCS_db.BB_GROUND =0;
BCS_db.BB_BLOCK = 1;
BCS_db.BB_DOOR = 2;
BCS_db.BB_WINDOW = 3;
BCS_db.BB_CHIMNEY = 4;
BCS_db.BB_BLOCKTOP = 5;
BCS_db.BB_DECO = 6;

-- marker types
BCS_db.MARKER_FREE_POINT = 0;
BCS_db.MARKER_WALL_POINT = 1;
BCS_db.MARKER_BLOCKTOP_POINT = 2;
BCS_db.MARKER_GROUND_POINT = 3;
BCS_db.MARKER_FREE_LINE = 4;
BCS_db.MARKER_WALL_LINE = 5;
BCS_db.MARKER_BLOCKTOP_LINE = 6;
BCS_db.MARKER_GROUND_LINE = 7;





-- return a table containing a list of IDs for the given BCS type
-- @param type: such as BCS_db.MARKER_FREE_POINT
function BCS_db.GetBCSBlockPathList(type)
	if(not BCS_db.PathLists[type]) then
		-- only fetch on demand and if it has never been fetched before.
		local result = {};
		local i=1;
		local db = sqlite3.open(BCS_db.dbfile);
		local row;
		local typeStr;
		
		if(type == BCS_db.MARKER_FREE_POINT) then
			typeStr = "0 or type= 1 or type = 2 or type = 3 or type = 4 or type = 5 or type = 6";
		elseif(type == BCS_db.MARKER_WALL_POINT) then
			typeStr = "2 or type = 3 or type = 4";
		elseif(type == BCS_db.MARKER_BLOCKTOP_POINT) then
			typeStr = "1 or type = 4 or type = 5";
		elseif(type == BCS_db.MARKER_GROUND_POINT) then
			typeStr = "1 or type = 6";
		end
		
		for row in db:rows(string.format("select Path from BuildingBlockDB where Type= %s",typeStr)) do
			result[i] = tostring(row.Path);
			i = i+1;
		end
		
		
		db:close();
		BCS_db.PathLists[type] = result;
	end
	return BCS_db.PathLists[type];
end