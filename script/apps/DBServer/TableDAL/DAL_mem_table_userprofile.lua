NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_mem_table.lua");

local DAL_mem_table_userprofile = commonlib.inherit(DAL_mem_table, commonlib.gettable("DBServer.TableDAL.DAL_mem_table_userprofile"));


function DAL_mem_table_userprofile.getEntityFromCursor(row)
	return UserProfileEntity:new(tonumber(row.NID), row.Nickname, row.FirstName, row.LastName, row.Birthday, row.Gender, row.RegisterArea, row.Photo, row.Email, tonumber(row.PMoney), tonumber(row.EMoney), row.Family, tonumber(row.Popularity), row.Votes, row.LastVote, tonumber(row.Introducer), tonumber(row.luck), row.luckDate,
            row.Pet_Nickname, row.Pet_Birthday, tonumber(row.Pet_Level), tonumber(row.Pet_Friendliness), tonumber(row.Pet_Strong), tonumber(row.Pet_Cleanness), tonumber(row.Pet_Mood), tonumber(row.Pet_Health), tonumber(row.Pet_Caress), row.Pet_LastCaressDate, row.Pet_IllDate, tonumber(row.Pet_Kindness), tonumber(row.Pet_Intelligence), tonumber(row.Pet_Agility), tonumber(row.Pet_Strength), tonumber(row.Pet_ArchSkillPts), row.Pet_LastUpdateDate, tonumber(row.Pet_Exp), tonumber(row.Pet_Energy), tonumber(row.Pet_M), tonumber(row.Pet_CombatSchool),
            row.SecAPt, row.SecPass, row.SecPassVerify, row.ResetSecDt, tonumber(row.Stamina), row.StaminaDt, tonumber(row.AccumMoDou), tonumber(row.Stamina2));
end