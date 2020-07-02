--[[
Title: CombatPetHelper
Author(s): Leio 
Date: 2010/12/11
Desc: 
2012.9.13: added pet talks by LiXizhi. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetHelper.lua");
local CombatPetHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetHelper");
echo(CombatPetHelper.GetPetTalk(10162, "entercombat"))
echo(CombatPetHelper.GetPetTalk(10162, "attack"))
echo(CombatPetHelper.GetPetTalk(10162, "leavecombat"))
echo(CombatPetHelper.GetPetTalk(10162, nil))
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetProvider.lua");
local CombatPetProvider = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetProvider");
-- create class
local CombatPetHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetHelper");
CombatPetHelper.client_provider = nil;
CombatPetHelper.server_provider = nil;
function CombatPetHelper.GetClientProvider()
	local self = CombatPetHelper;
	if(not self.client_provider)then
		local isteen = CommonClientService.IsTeenVersion();
		self.client_provider = CombatPetProvider:new({
			isteen = isteen,
		});
		self.client_provider:LoadConfigFile();
	end
	return self.client_provider;
end
function CombatPetHelper.GetServerProvider(isteen)
	local self = CombatPetHelper;
	if(not self.server_provider)then
		self.server_provider = CombatPetProvider:new(
		{
			isteen = isteen,
			isremote = true,
		});
		self.server_provider:LoadConfigFile();
	end
	return self.server_provider;
end


-- load the pet talk if not.
-- return the load talk
function CombatPetHelper.CheckLoadPetTalk()
	if(not CombatPetHelper.pet_talks) then
		CombatPetHelper.pet_talks = {};
		NPL.load("(gl)script/ide/Document/ExcelDocReader.lua");
		local ExcelDocReader = commonlib.gettable("commonlib.io.ExcelDocReader");
		local reader = ExcelDocReader:new();

		-- schema is optional, which can change the row's keyname to the defined value. 
		reader:SetSchema({
			[1] = {name="gsid", type="number"},
			[2] = {name="name", type="string"},
			[3] = {name="entercombat", type="string"},
			[4] = {name="attack", type="string"},
			[5] = {name="leavecombat", type="string"},
			[6] = {name="standby1", type="string"},
			[7] = {name="standby2", type="string"},
			[8] = {name="standby3", type="string"},
			[9] = {name="gohome", type="string"},
		})
		-- read from the second row
		local filename = if_else(System.options.version=="kids",  "config/Aries/Others/pet_talks.kids.excel.xml", "config/Aries/Others/pet_talks.teen.excel.xml");
		if(reader:LoadFile(filename, 2)) then 
			local rows = reader:GetRows();
			local _, row
			for _, row in ipairs(rows) do
				if(row.gsid) then
					CombatPetHelper.pet_talks[row.gsid] = row;
				end
			end
		end
	end
	return CombatPetHelper.pet_talks;
end

-- get the next pet talk. When pet is summoned we can pick a pet talk to show to the user. 
-- @param gsid: the pet gsid number
-- @param talk_index or talk_name: the pet talk index, if nil, it will be a random standby talk in the pool. 
--  Available talk_name is "entercombat", "attack" , "leavecombat", "standby1", "standby2", "standby3", "gohome"
-- @return string or nil. if nil, no talk is found for the given gsid. 
function CombatPetHelper.GetPetTalk(gsid, talk_index)
	local isteen = CommonClientService.IsTeenVersion();
	if(isteen) then
		local r = math.random(0, 100);
		if(r <= 80) then
			return nil;
		end
	end
	if(gsid) then
		local pet_talks = CombatPetHelper.CheckLoadPetTalk();
		if(pet_talks) then
			local talk = pet_talks[gsid] or pet_talks[1]; -- gsid 1 is the default talk. 
			if(talk) then
				if(not talk_index) then
					talk_index = "standby"..tostring(math.random(1,3));
				end
				return talk[talk_index] or talk["standby1"];
			end
		end
	end
	-- return "this is a test talk from"..tostring(gsid);
end