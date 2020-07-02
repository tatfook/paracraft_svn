NPL.load("(gl)script/apps/DBServer/BLL/ExpLelBLL.lua");

local PetEntity = commonlib.gettable("DBServer.PetEntity");


function PetEntity:new(NID, Nickname, Birthday, Level, Friendliness, Strong, Cleanness, Mood, Health, Caress, LastCaressDate, IllDate, Kindness, Intelligence, Agility, Strength, ArchSkillPts, LastUpdateDate, Exp, Energy, M, CombatSchool, Stamina, StaminaDt, Stamina2)
    local _t = {
		NID = NID,
        Nickname = Nickname,
        Birthday = Birthday,
        Level = Level,
        Friendliness = Friendliness,
        Strong = Strong,
        Cleanness = Cleanness,
        Mood = Mood,
        Health = Health,
        Caress = Caress,
        LastCaressDate = LastCaressDate,
        IllDate = IllDate,
        Kindness = Kindness,
        Intelligence = Intelligence,
        Agility = Agility,
        Strength = Strength,
        ArchSkillPts = ArchSkillPts,
        LastUpdateDate = LastUpdateDate,
        Exp = Exp,
        Energy = Energy,
        M = M,
        CombatSchool = CombatSchool,
        Stamina = Stamina,
        StaminaDt = StaminaDt,
        Stamina2 = Stamina2
	};
    setmetatable(_t, self);
    self.__index = self;
    return _t;
end



-- 战斗经验值
function PetEntity:getExp()
	return self.Exp;
end

-- 战斗经验值
function PetEntity:setExp(newExp)
	self.Exp = newExp;
	local _v = ExpLelBLL.computeShowValue(self.Exp);
	self.showExp = _v.showExp;
	self.showCombatLel = _v.showCombatLel;
	self.showNextExp = _v.showNextExp;
end



-- 升级到下一级所需要的亲密度
function PetEntity:getUpdateFriendliness()
	return (self.Level + 1) * (self.Level+ 1) * 2;
end


-- 表示宠物是否寄养状态的物品，若为NULL，表示不是寄养状态
function PetEntity:getAdopted()
	-- TODO:
	return nil;
end


-- 奖章战斗等级
function PetEntity:getBadges()
	-- TODO:
end


-- 战斗等级
function PetEntity:getCombatLel()
	return ExpLelBLL.getCombatLelWithExp(self.Exp);
end


-- 魔法星等级
function PetEntity:getMLel()
	-- TODO
end


-- 显示在客户端的魔法星M值。即当前魔法星等级下的M值
function PetEntity:getShowM()
	-- TODO
end


-- 当魔法星的M值降到该值后，将不会再下降
function PetEntity:getMinM()
	-- TODO
end


-- 魔法星升级到下一等级所需的魔法值。若已是最后一级，则返回99999999
function PetEntity:getNextLevelM()
	-- TODO:
end


-- 最大精力值
function PetEntity:getMaxStamina()
	-- TODO:
end


-- 最大体力值2，青年版使用
function PetEntity:getMaxStamina2()
	-- TODO:
end

