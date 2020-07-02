--[[
NPL.load("(gl)script/ide/mysql/mysql.lua");

NPL.load("(gl)script/apps/DBServer/DBSettings.lua");
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/apps/DBServer/DataAccess.lua");
NPL.load("(gl)script/apps/DBServer/Entity/UserProfileEntity.lua");


local luasql = commonlib.luasql;

MySqlUserProfileProvider = DataAccess:new();

function MySqlUserProfileProvider:new(o)
	o = o or {};
    setmetatable(o, self);
    self.__index = self;
    return o;
end


function MySqlUserProfileProvider:getUserProfileTableName(nid)
	return "userprofile" .. self:getTbIndex(nid);
end



function MySqlUserProfileProvider.getFromRow(row)
	return UserProfileEntity:new(tonumber(row.NID), row.Nickname, row.FirstName, row.LastName, row.Birthday, row.Gender, row.RegisterArea, row.Photo, row.Email, tonumber(row.PMoney), tonumber(row.EMoney), row.Family, tonumber(row.Popularity), row.Votes, row.LastVote, tonumber(row.Introducer), tonumber(row.luck), row.luckDate,
            row.Pet_Nickname, row.Pet_Birthday, tonumber(row.Pet_Level), tonumber(row.Pet_Friendliness), tonumber(row.Pet_Strong), tonumber(row.Pet_Cleanness), tonumber(row.Pet_Mood), tonumber(row.Pet_Health), tonumber(row.Pet_Caress), row.Pet_LastCaressDate, row.Pet_IllDate, tonumber(row.Pet_Kindness), tonumber(row.Pet_Intelligence), tonumber(row.Pet_Agility), tonumber(row.Pet_Strength), tonumber(row.Pet_ArchSkillPts), row.Pet_LastUpdateDate, tonumber(row.Pet_Exp), tonumber(row.Pet_Energy), tonumber(row.Pet_M), tonumber(row.Pet_CombatSchool),
            row.SecAPt, row.SecPass, row.SecPassVerify, row.ResetSecDt, tonumber(row.Stamina), row.StaminaDt, tonumber(row.AccumMoDou), tonumber(row.Stamina2));
end




function MySqlUserProfileProvider:getProfileByNID(nid)
	local _cn = self:getConnection(nid);
	local _tb = self:getUserProfileTableName(nid);
	local _pf = nil;

	local _sql = "select * from " .. _tb .. " where nid=" .. nid .. " for update";
	local _list = self:execReader(_cn.cn, _sql, MySqlUserProfileProvider.getFromRow);
	if(table.getn(_list) > 0) then
		_pf = _list[1];
	end

	return _pf;
end


]]