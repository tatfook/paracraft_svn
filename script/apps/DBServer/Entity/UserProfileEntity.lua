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

-- ʱ��
function UserProfileEntity:getLuck()
	local _dtNow = os.date("*t");
	if(self.luckDate.year == _dtNow.year and self.luckDate.month == _dtNow.month and self.luckDate.day == _dtNow.day) then
		return self.luck;
	else
		local _ary = DBSettings.lucks();
		return _ary[self.NID % (table.getn(_ary))];
	end
end

-- ʱ��
function UserProfileEntity:setLuck(newLuck)
	self.luck = newLuck;
end


-- �û���ǰ�İ�ȫ״̬
-- ����û�δ���ð�ȫ���룬���ߵ�������֤���˰�ȫ���룬�򷵻�true
function UserProfileEntity:getSecurityState()
	local _dtNow = os.date("*t");
	return self.SecPass == "" or (self.SecPassVerify.year == _dtNow.year and self.SecPassVerify.month == _dtNow.month and self.SecPassVerify.day == _dtNow.day);
end


-- ���û��ı������ĵȼ������ޱ��������򷵻�0
function UserProfileEntity:getHaqiLevel()
	return (self.dragon and self.dragon.Level) or 0;
end


-- ���û������������ϸ��Ϣ
function UserProfileEntity:getFamily()
	-- TODO:
end


-- �Ƿ����ȡ�鷳�����ӣ�����ȼ����ڵ���10��������ӵ��ħ����?���Ϊħ��������ֵ���ڣ��������Ҳ������κμ��壩
function UserProfileEntity:canGainTroubleTree()
	return (self:getHaqiLevel() >= 10 or self.dragon.Energy > 0) and self:getFamily();
end


-- �Ƿ�ɴ������壨�����������ȡ�鷳�����ӵ������⣬������ӵ���鷳����ʵ��
function UserProfileEntity:canCreateFamily()
	-- TODO:
end


-- ���û��ļ�԰
function UserProfileEntity:getHome()
	-- TODO:
end



-- �û��ı�������Ŀǰ�İ汾������һ���򿪵�Transaction��ʹ��
function UserProfileEntity:getDragon()
	-- TODO:
end


function UserProfileEntity:getDragon_NotComputeAttr()
	return self.dragon;
end



