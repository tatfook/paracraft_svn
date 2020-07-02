--[[
Title: character customization database for Map 3D system
Author(s): WangTian
Date: 2007/10/29
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/BCS/DB.lua");
-------------------------------------------------------

NOTE: this is an upgrade to the original BCS UI
		see: script/kids/BCS/BCS_db.lua
		
NOTE: currently BCS is integrated to Map 3d system creation panel
]]


NPL.load("(gl)script/sqlite/sqlite3.lua");

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

Map3DSystem.UI.BCS.DB.dbfile = "Database/characters.db";

function Map3DSystem.UI.BCS.DB.ReadBCSAssetFromDB()

	local db = sqlite3.open(Map3DSystem.UI.BCS.DB.dbfile);
	local _name, _path;
	local _s;
	local k, v;
	local i;
	local _groupName;
	for i = 1, 8 do
		if(i == 1) then
			_groupName = "BCS_01base";
		elseif(i == 2) then
			_groupName = "BCS_02block";
		elseif(i == 3) then
			_groupName = "BCS_03blocktop";
		elseif(i == 4) then
			_groupName = "BCS_04stairs";
		elseif(i == 5) then
			_groupName = "BCS_05door";
		elseif(i == 6) then
			_groupName = "BCS_06window";
		elseif(i == 7) then
			_groupName = "BCS_07chimney";
		elseif(i == 8) then
			_groupName = "BCS_08deco";
		end
		
		Map3DSystem.DB.Items[_groupName] = {};
		
		local row;
		local j = 1;
		for row in db:rows(string.format("select Name, Path from BuildingBlockDB_V3 where Type = %d", i)) do
			Map3DSystem.DB.Items[_groupName][j] = {
				["IconAssetName"] = row.Name,
				["ModelFilePath"] = row.Path,
				["IconFilePath"] = row.Path..".png",
				["Price"] = 50,
				["Reserved1"] = "R1",
				["Reserved2"] = "R2",
				["Reserved3"] = "R3",
				["Reserved4"] = "R4",
				};
			j = j + 1;
		end
		
		table.sort(Map3DSystem.DB.Items[_groupName], function(a, b) return a.IconAssetName < b.IconAssetName end);
		
	end
	
	db:close();
end

function Map3DSystem.UI.BCS.DB.SaveBCSAssetToDB()
	local db = sqlite3.open(Map3DSystem.UI.BCS.DB.dbfile);
	local _name, _path;
	local _s;
	local k, v;
	local i;
	local _groupName;
	for i = 1, 8 do
		if(i == 1) then
			_groupName = "BCS_01base";
		elseif(i == 2) then
			_groupName = "BCS_02block";
		elseif(i == 3) then
			_groupName = "BCS_03blocktop";
		elseif(i == 4) then
			_groupName = "BCS_04stairs";
		elseif(i == 5) then
			_groupName = "BCS_05door";
		elseif(i == 6) then
			_groupName = "BCS_06window";
		elseif(i == 7) then
			_groupName = "BCS_07chimney";
		elseif(i == 8) then
			_groupName = "BCS_08deco";
		end
		
		table.sort(Map3DSystem.DB.Items[_groupName], function(a, b) return a.IconAssetName < b.IconAssetName end);
		
		for k, v in pairs(Map3DSystem.DB.Items[_groupName]) do
			--log(k.."\n")
			_name = v.IconAssetName;
			_path = v.ModelFilePath;
			
			_s = string.format("insert into BuildingBlockDB_V3 (Name, Path, Type) values ('%s', '%s', %d)", _name, _path, i);
			db:exec(_s);
		end
	end
	
	db:close();
	
end


function Map3DSystem.UI.BCS.DB.SortBCSDB()
	local _tableTemp = {};
	local db = sqlite3.open(Map3DSystem.UI.BCS.DB.dbfile);
	local _name, _path;
	local _s;
	local k, v;
	local i;
	local _groupName;
	for i = 1, 8 do
		if(i == 1) then
			_groupName = "BCS_01base";
		elseif(i == 2) then
			_groupName = "BCS_02block";
		elseif(i == 3) then
			_groupName = "BCS_03blocktop";
		elseif(i == 4) then
			_groupName = "BCS_04stairs";
		elseif(i == 5) then
			_groupName = "BCS_05door";
		elseif(i == 6) then
			_groupName = "BCS_06window";
		elseif(i == 7) then
			_groupName = "BCS_07chimney";
		elseif(i == 8) then
			_groupName = "BCS_08deco";
		end
		
		_tableTemp[_groupName] = {};
		
		local row;
		local j = 1;
		for row in db:rows(string.format("select Name, Path from BuildingBlockDB_V3 where Type = %d", i)) do
			_tableTemp[_groupName][j] = {
				["IconAssetName"] = row.Name,
				["ModelFilePath"] = row.Path,
				["IconFilePath"] = row.Path..".png",
				["Price"] = 50,
				["Reserved1"] = "R1",
				["Reserved2"] = "R2",
				["Reserved3"] = "R3",
				["Reserved4"] = "R4",
				};
			j = j + 1;
		end
		
		table.sort(_tableTemp[_groupName], function(a, b) return a.IconAssetName < b.IconAssetName end);
		
	end
	
	
	db:exec("delete from BuildingBlockDB_V3");
	
	local _name, _path;
	local _s;
	local k, v;
	local i;
	local _groupName;
	for i = 1, 8 do
		if(i == 1) then
			_groupName = "BCS_01base";
		elseif(i == 2) then
			_groupName = "BCS_02block";
		elseif(i == 3) then
			_groupName = "BCS_03blocktop";
		elseif(i == 4) then
			_groupName = "BCS_04stairs";
		elseif(i == 5) then
			_groupName = "BCS_05door";
		elseif(i == 6) then
			_groupName = "BCS_06window";
		elseif(i == 7) then
			_groupName = "BCS_07chimney";
		elseif(i == 8) then
			_groupName = "BCS_08deco";
		end
		
		
		for k, v in pairs(_tableTemp[_groupName]) do
			--log(k.."\n")
			_name = v.IconAssetName;
			_path = v.ModelFilePath;
			
			_s = string.format("insert into BuildingBlockDB_V3 (Name, Path, Type) values ('%s', '%s', %d)", _name, _path, i);
			db:exec(_s);
		end
	end
	
	db:close();
	
end