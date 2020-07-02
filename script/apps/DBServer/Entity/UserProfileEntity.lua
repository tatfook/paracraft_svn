NPL.load("(gl)script/apps/DBServer/Entity/PetEntity.lua");
NPL.load("(gl)script/apps/DBServer/BLL/PetBLL.lua");

local UserProfileEntity = commonlib.gettable("DBServer.UserProfileEntity");
local PetEntity = commonlib.gettable("DBServer.PetEntity");
--[[
UserProfileEntity = {
	NID = 0,
    Nickname = "",
    FirstName = "",
    LastName = "",
    Birthday = os.date("*t"),
    Gender = "",
    RegisterArea = "",
    Photo = "",
    Email = "",
    PMoney = 0,
    EMoney = 0,
    Family = "",
    Popularity = 0,
    Votes = "",
    LastVote = os.date("*t"),
    Introducer = -1,
    luck = 0,
    luckDate = os.date("*t"),
    SecAPt = "",
    SecPass = "",
    SecPassVerify = os.date("*t"),
    ResetSecDt = os.date("*t"),
    AccumMoDou = 0,
	dragon = nil
};
]]



function UserProfileEntity:new(o)
	o = o or {};
	setmetatable(o, self);
    self.__index = self;
    
	-- o.dragon = PetEntity:new(o.NID, o.Pet_Nickname, o.Pet_Birthday, o.Pet_Level, o.Pet_Friendliness, o.Pet_Strong, o.Pet_Cleanness, o.Pet_Mood, o.Pet_Health, o.Pet_Caress, o.Pet_LastCaressDate, o.Pet_IllDate, o.Pet_Kindness, o.Pet_Intelligence, o.Pet_Agility, o.Pet_Strength, o.Pet_ArchSkillPts, o.Pet_LastUpdateDate, o.Pet_Exp, o.Pet_Energy, o.Pet_M, o.Pet_CombatSchool, o.Stamina, o.StaminaDt, o.Stamina2);
	return o;
end

function UserProfileEntity:clone(o)
	local new_obj = {
		NID = o.NID,
        Nickname = o.Nickname,
        FirstName = o.FirstName,
        LastName = o.LastName,
        Birthday = o.Birthday,
        Gender = o.Gender,
        RegisterArea = o.RegisterArea,
        Photo = o.Photo,
        Email = o.Email,
        PMoney = o.PMoney,
        EMoney = o.EMoney,
        Family = o.Family,
        Popularity = o.Popularity,
        Votes = o.Votes,
        LastVote = o.LastVote,
        Introducer = o.Introducer,
        Luck = o.luck,
        LuckDate = o.luckDate,
        SecAPt = o.SecAPt,
        SecPass = o.SecPass,
        SecPassVerify = o.SecPassVerify,
        ResetSecDt = o.ResetSecDt,
        AccumMoDou = o.AccumMoDou,

		Pet_Nickname = Pet_Nickname, 
		Pet_Birthday = Pet_Birthday, 
		Pet_Level = Pet_Level, 
		Pet_Friendliness = Pet_Friendliness, 
		Pet_Strong = Pet_Strong, 
		Pet_Cleanness = Pet_Cleanness, 
		Pet_Mood = Pet_Mood, 
		Pet_Health = Pet_Health, 
		Pet_Caress = Pet_Caress, 
		Pet_LastCaressDate = Pet_LastCaressDate, 
		Pet_IllDate = Pet_IllDate, 
		Pet_Kindness = Pet_Kindness, 
		Pet_Intelligence = Pet_Intelligence, 
		Pet_Agility = Pet_Agility, 
		Pet_Strength = Pet_Strength, 
		Pet_ArchSkillPts = Pet_ArchSkillPts, 
		Pet_LastUpdateDate = Pet_LastUpdateDate, 
		Pet_Exp = Pet_Exp, 
		Pet_Energy = Pet_Energy, 
		Pet_M = Pet_M, 
		Pet_CombatSchool = Pet_CombatSchool, 
		Stamina = Stamina, 
		StaminaDt = StaminaDt, 
		Stamina2 = Stamina2
	};
	return self:new(new_obj);
end

-- 时运
function UserProfileEntity:getLuck()
	local _dtNow = os.date("*t");
	if(self.luckDate.year == _dtNow.year and self.luckDate.month == _dtNow.month and self.luckDate.day == _dtNow.day) then
		return self.luck;
	else
		local _ary = DBSettings.lucks();
		return _ary[self.NID % (table.getn(_ary))];
	end
end

-- 时运
function UserProfileEntity:setLuck(newLuck)
	self.luck = newLuck;
end


-- 用户当前的安全状态
-- 如果用户未设置安全密码，或者当天已验证过了安全密码，则返回true
function UserProfileEntity:getSecurityState()
	local _dtNow = os.date("*t");
	return self.SecPass == "" or (self.SecPassVerify.year == _dtNow.year and self.SecPassVerify.month == _dtNow.month and self.SecPassVerify.day == _dtNow.day);
end


-- 该用户的抱抱龙的等级，若无抱抱龙，则返回0
function UserProfileEntity:getHaqiLevel()
	return (self.dragon and self.dragon.Level) or 0;
end


-- 该用户所属家族的详细信息
function UserProfileEntity:getFamily()
	-- TODO:
end


-- 是否可领取麻烦树种子（哈奇等级大于等于10级，或者拥有魔法星?理解为魔法星能量值大于０？，并且不属于任何家族）
function UserProfileEntity:canGainTroubleTree()
	return (self:getHaqiLevel() >= 10 or self.dragon.Energy > 0) and self:getFamily();
end


-- 是否可创建家族（除了满足可领取麻烦果种子的条件外，还必须拥有麻烦果果实）
function UserProfileEntity:canCreateFamily()
	-- TODO:
end


-- 该用户的家园
function UserProfileEntity:getHome()
	-- TODO:
end



-- 用户的抱抱龙．目前的版本不能在一个打开的Transaction中使用
function UserProfileEntity:getDragon()
	-- TODO:
end


function UserProfileEntity:getDragon_NotComputeAttr()
	return self.dragon;
end



