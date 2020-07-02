--[[
Title: 
Author(s): leio
Date: 2013/5/14
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyHelper.lua");
local LobbyHelper = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyHelper");
local gsid = LobbyHelper.GetGsidByWorld("Global_HaqiTown_TreasureHouse",4)
echo("=========gsid");
echo(gsid);

NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyHelper.lua");
local LobbyHelper = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyHelper");
local is_opened = LobbyHelper.IsOpened(nil,"TreasureHouse_1_hero")
echo("=========is_opened");
echo(is_opened);
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");
NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
NPL.load("(gl)script/ide/Document/ExcelDocReader.lua");
local ExcelDocReader = commonlib.gettable("commonlib.io.ExcelDocReader");
local LobbyHelper = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyHelper");
function LobbyHelper.GetBossGsidList()
	local __,list = LobbyHelper.GetConfig();
	local mode_list = {1,2,3,4};
	local result = {};
	local k,v;
	for k,v in ipairs(list) do
		local worldname = v.worldname;
		local kk,mode;
		for kk,mode in ipairs(mode_list) do
			local key = string.format("mode_%d_gsid",mode);
			if(v[key])then
				local gsid = v[key];
				local node = {
					worldname = v.worldname,	
					gsid = gsid,
					mode = mode,
				}
				table.insert(result,node);
			end
		end
	end
	return result;
end
function LobbyHelper.GetConfig()
	if(LobbyHelper.rows_map)then
		return LobbyHelper.rows_map,LobbyHelper.rows_list;
	end
	local config_path = "config/Aries/LobbyService_Teen/id_maps.xml";
	local reader = ExcelDocReader:new();
	reader:SetSchema({
		{name="label", type="string"},
		{name="worldname", type="string"},
		{name="mode_1_gsid", type="number"},
		{name="mode_2_gsid", type="number"},
		{name="mode_3_gsid", type="number"},
		{name="mode_4_gsid", type="number"},
		{name="mode_5_gsid", type="number"},
	})
	LobbyHelper.rows_map = {};
	LobbyHelper.rows_list = {};
	if(reader:LoadFile(config_path, 2)) then 
		local rows = reader:GetRows();
		local _, row
		for _, row in ipairs(rows) do
			if(row.worldname)then
				LobbyHelper.rows_map[row.worldname] = row;
				table.insert(LobbyHelper.rows_list,row);
			end
		end
	end
	return LobbyHelper.rows_map,LobbyHelper.rows_list;
end
--获取副本难度的gsid
--@param worldname:
--@param mode:难度 1,2，3,4,5
function LobbyHelper.GetGsidByWorld(worldname,mode)
	local config = LobbyHelper.GetConfig();
	if(config and worldname and mode)then
		local template = config[worldname];
		if(template)then
			local key = string.format("mode_%d_gsid",mode);
			return template[key];
		end
	end
end
--获取闯过副本的次数
--@param nid:
--@param worldname:
--@param mode:
--@param is_server:
function LobbyHelper.GetCntByWorld(nid,worldname,mode,is_server)
	local gsid = LobbyHelper.GetGsidByWorld(worldname,mode);
	if(gsid)then
		if(is_server)then
			local __,__,__,copies = PowerItemManager.IfOwnGSItem(nid,gsid);
			copies = copies or 0;
			return copies;
		else
			local hasItem,guid,bag,copies = ItemManager.IfOwnGSItem(gsid);
			copies = copies or 0;
			return copies;
		end
	end
	return 0;
end
function LobbyHelper.GetCnt(nid,gsid,is_server)
	if(gsid)then
		if(is_server)then
			local __,__,__,copies = PowerItemManager.IfOwnGSItem(nid,gsid);
			copies = copies or 0;
			return copies;
		else
			local hasItem,guid,bag,copies = ItemManager.IfOwnGSItem(gsid);
			copies = copies or 0;
			return copies;
		end
	end
	return 0;
end
--副本是否可以开启
function LobbyHelper.IsOpened(nid,keyname,is_server)
	if(not keyname)then
		return;
	end
	local game_templates = LobbyClient:GetGameTemplates();
	local template = game_templates[keyname];
	if(template)then
		local level_condition = true;
		local pre_world_condition = true;

		local worldname = template.worldname;
		local min_level = template.min_level;
		local max_level = template.max_level;
		local pre_world_id = template.pre_world_id;

		local combat_level = 0;
		if(is_server)then
			local userinfo = PowerItemManager.GetUserAndDragonInfoInMemory(nid)
			if(userinfo and userinfo.dragon)then
				combat_level = userinfo.dragon.combatlel;
			end
		else
			local bean = MyCompany.Aries.Pet.GetBean();
			if(bean) then
				combat_level = bean.combatlel;
			end
		end
		if(min_level)then
			if(combat_level < min_level)then
				level_condition = false;
			end
		end
		if(pre_world_id)then
			local cnt = LobbyHelper.GetCnt(nid,pre_world_id,is_server);
			if(cnt <= 0)then
				pre_world_condition = false;
			end
		end
		return level_condition and pre_world_condition;
	end
end