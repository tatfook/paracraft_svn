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



-- ս������ֵ
function PetEntity:getExp()
	return self.Exp;
end

-- ս������ֵ
function PetEntity:setExp(newExp)
	self.Exp = newExp;
	local _v = ExpLelBLL.computeShowValue(self.Exp);
	self.showExp = _v.showExp;
	self.showCombatLel = _v.showCombatLel;
	self.showNextExp = _v.showNextExp;
end



-- ��������һ������Ҫ�����ܶ�
function PetEntity:getUpdateFriendliness()
	return (self.Level + 1) * (self.Level+ 1) * 2;
end


-- ��ʾ�����Ƿ����״̬����Ʒ����ΪNULL����ʾ���Ǽ���״̬
function PetEntity:getAdopted()
	-- TODO:
	return nil;
end


-- ����ս���ȼ�
function PetEntity:getBadges()
	-- TODO:
end


-- ս���ȼ�
function PetEntity:getCombatLel()
	return ExpLelBLL.getCombatLelWithExp(self.Exp);
end


-- ħ���ǵȼ�
function PetEntity:getMLel()
	-- TODO
end


-- ��ʾ�ڿͻ��˵�ħ����Mֵ������ǰħ���ǵȼ��µ�Mֵ
function PetEntity:getShowM()
	-- TODO
end


-- ��ħ���ǵ�Mֵ������ֵ�󣬽��������½�
function PetEntity:getMinM()
	-- TODO
end


-- ħ������������һ�ȼ������ħ��ֵ�����������һ�����򷵻�99999999
function PetEntity:getNextLevelM()
	-- TODO:
end


-- �����ֵ
function PetEntity:getMaxStamina()
	-- TODO:
end


-- �������ֵ2�������ʹ��
function PetEntity:getMaxStamina2()
	-- TODO:
end

