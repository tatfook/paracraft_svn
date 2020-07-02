--[[
Title: Aries Registration Page
Author(s): LiXizhi
Date: 2009/8/4
Desc:  script/apps/Aries/Login/NewAvatarDisplayPage.html
Creating a new avatar, provide nick name, etc, for newly registered users. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/NewAvatarDisplayPage.lua");
-------------------------------------------------------
]]
local NewAvatarDisplayPage = commonlib.gettable("MyCompany.Aries.NewAvatarDisplayPage")

---------------------------------
-- page event handlers
---------------------------------
-- singleton page
local page;
local MainLogin = commonlib.gettable("MyCompany.Aries.MainLogin");

-- example ccs string: "0#1#0#1#1#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#0#0#0#0#0#0#0#1034#1029#1010#0#1003#1022#21001#0#0#0#"
-- full ccsinfostring sections:
--  0# 1# 0#1# 1#@ 0# F#0#0#0#0# 0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0# @0#0#0#0#0#0#0#0#0#0#0#0#1034#1029#1010#0#1003#1022#21001#0#0#0#
-- |S1|  | S2 |   |S1|          |S3                                                                      |S4
-- section 1 is the id of character skin and cartoon face base texture 
-- section 2 is the hair style and color info
-- section 3 is the cartoon face info except the base face texture
-- section 4 is read from item system 
-- rest of the character string function are the same in Aries
-- 
NewAvatarDisplayPage.Choices = nil;

-- kids unisex settings
NewAvatarDisplayPage.Choices_kids = {
	cartoonface_info = {
		[1] = { section = "0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#8#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face01_32bits.png;0 0 48 48"},
		[2] = { section = "0#F#0#0#0#0#9#F#0#0#0#0#9#F#0#0#0#0#10#F#0#0#0#0#8#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face02_32bits.png;0 0 48 48"},
		[3] = { section = "0#F#0#0#0#0#10#F#0#0#0#0#10#F#0#0#0#0#11#F#0#0#0#0#9#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face03_32bits.png;0 0 48 48"},
		[4] = { section = "0#F#0#0#0#0#4#F#0#0#0#0#6#F#0#0#0#0#7#F#0#0#0#0#6#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face04_32bits.png;0 0 48 48"},
		[5] = { section = "0#F#0#0#0#0#11#F#0#0#0#0#11#F#0#0#0#0#12#F#0#0#0#0#10#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face05_32bits.png;0 0 48 48"},
		[6] = { section = "0#F#0#0#0#0#8#F#0#0#0#0#7#F#0#0#0#0#8#F#0#0#0#0#6#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face06_32bits.png;0 0 48 48"},
		[7] = { section = "0#F#0#0#0#0#5#F#0#0#0#0#8#F#0#0#0#0#9#F#0#0#0#0#7#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face07_32bits.png;0 0 48 48"},
		[8] = { section = "0#F#0#0#0#0#2#F#0#0#0#0#2#F#0#0#0#0#4#F#0#0#0#0#3#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face08_32bits.png;0 0 48 48"},
		[9] = { section = "0#F#0#0#0#0#7#F#0#0#0#0#3#F#0#0#0#0#5#F#0#0#0#0#4#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face09_32bits.png;0 0 48 48"},
	}, -- section 3
	hair_info = {
		[1] = { section = "0#1#", icon = "Texture/Aries/Login/NewAvatar/Hair01_32bits.png;0 0 48 48"},
		[2] = { section = "0#2#", icon = "Texture/Aries/Login/NewAvatar/Hair02_32bits.png;0 0 48 48"},
		[3] = { section = "0#4#", icon = "Texture/Aries/Login/NewAvatar/Hair03_32bits.png;0 0 48 48"},
		[4] = { section = "0#5#", icon = "Texture/Aries/Login/NewAvatar/Hair04_32bits.png;0 0 48 48"},
		[5] = { section = "0#6#", icon = "Texture/Aries/Login/NewAvatar/Hair05_32bits.png;0 0 48 48"},
		[6] = { section = "0#7#", icon = "Texture/Aries/Login/NewAvatar/Hair06_32bits.png;0 0 48 48"},
		[7] = { section = "0#8#", icon = "Texture/Aries/Login/NewAvatar/Hair07_32bits.png;0 0 48 48"},
	}, -- section 2
	skin_info = {
		[1] = { section = "0#", icon = "Texture/Aries/Login/NewAvatar/Skin01_32bits.png;0 0 48 48"},
		[2] = { section = "1#", icon = "Texture/Aries/Login/NewAvatar/Skin02_32bits.png;0 0 48 48"},
		[3] = { section = "2#", icon = "Texture/Aries/Login/NewAvatar/Skin03_32bits.png;0 0 48 48"},
		--[4] = { section = "3#", icon = "Texture/Aries/Login/NewAvatar/Skin04_32bits.png;0 0 48 48"},
		[4] = { section = "4#", icon = "Texture/Aries/Login/NewAvatar/Skin05_32bits.png;0 0 48 48"},
		--[6] = { section = "5#", icon = "Texture/Aries/Login/NewAvatar/Skin06_32bits.png;0 0 48 48"},
	}, -- section 1
	clothes = {
		{shirt = 1050, pants = 1051, wrist = 0, boots = 1052, icon = "Texture/Aries/Login/NewAvatar/Clothes_01_32bits.png;0 0 48 48"},
		{shirt = 1053, pants = 1054, wrist = 0, boots = 1055, icon = "Texture/Aries/Login/NewAvatar/Clothes_02_32bits.png;0 0 48 48"},
		{shirt = 1056, pants = 1057, wrist = 0, boots = 1058, icon = "Texture/Aries/Login/NewAvatar/Clothes_03_32bits.png;0 0 48 48"},
		{shirt = 1059, pants = 1060, wrist = 0, boots = 1061, icon = "Texture/Aries/Login/NewAvatar/Clothes_04_32bits.png;0 0 48 48"},
		{shirt = 1062, pants = 1063, wrist = 0, boots = 1064, icon = "Texture/Aries/Login/NewAvatar/Clothes_05_32bits.png;0 0 48 48"},
		{shirt = 1103, pants = 1104, wrist = 0, boots = 1105, icon = "Texture/Aries/Login/NewAvatar/Clothes_06_32bits.png;0 0 48 48"},
	},
	genders = {
		982, -- teen female elf
		983, -- teen male elf
	},
};

-- female teen elf settings
NewAvatarDisplayPage.Choices_teen_female = {
	cartoonface_info = {
		[1] = { is_selected = true,section = "0#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#100#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/teen/Face01_32bits.png;0 0 48 48"},
		[2] = { is_selected = false,section = "0#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#101#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/teen/Face02_32bits.png;0 0 48 48"},
		[3] = { is_selected = false,section = "0#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#102#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/teen/Face03_32bits.png;0 0 48 48"},
	}, -- section 3
	hair_info = {
		[1] = { is_selected = true,section = "0#3#", icon = "Texture/Aries/Login/NewAvatar/teen/Hair03_32bits.png;0 0 48 48"},
		[2] = { is_selected = false,section = "0#2#", icon = "Texture/Aries/Login/NewAvatar/teen/Hair02_32bits.png;0 0 48 48"},
		[3] = { is_selected = false,section = "0#1#", icon = "Texture/Aries/Login/NewAvatar/teen/Hair01_32bits.png;0 0 48 48"},
	}, -- section 2
	skin_info = {
		[1] = { is_selected = true,section = "0#", icon = "Texture/Aries/Login/NewAvatar/teen/Skin01_32bits.png;0 0 48 48"},
		[2] = { is_selected = false,section = "1#", icon = "Texture/Aries/Login/NewAvatar/teen/Skin02_32bits.png;0 0 48 48"},
		[3] = { is_selected = false,section = "2#", icon = "Texture/Aries/Login/NewAvatar/teen/Skin03_32bits.png;0 0 48 48"},
	}, -- section 1
	clothes = {
		--{shirt = 1276, pants = 0, wrist = 0, boots = 1366, icon = "Texture/Aries/Login/NewAvatar/Clothes_01_32bits.png;0 0 48 48"}, -- level 10
		{shirt = 1001, pants = 0, wrist = 0, boots = 1002, icon = "Texture/Aries/Login/NewAvatar/Clothes_01_32bits.png;0 0 48 48"}, -- level 10
		--{shirt = 1320, pants = 0, wrist = 0, boots = 1410, icon = "Texture/Aries/Login/NewAvatar/Clothes_01_32bits.png;0 0 48 48"}, -- level 30
		--{shirt = 1001, pants = 0, wrist = 0, boots = 1002, icon = "Texture/Aries/Login/NewAvatar/Clothes_01_32bits.png;0 0 48 48"},
		--{shirt = 1053, pants = 1054, wrist = 0, boots = 1055, icon = "Texture/Aries/Login/NewAvatar/Clothes_02_32bits.png;0 0 48 48"},
		--{shirt = 1056, pants = 1057, wrist = 0, boots = 1058, icon = "Texture/Aries/Login/NewAvatar/Clothes_03_32bits.png;0 0 48 48"},
		
	},
	-- if provided, the user must wear this regardless of its choice 
	force_cloth = {shirt = 1001, pants = 0, wrist = 0, boots = 1002, icon = "Texture/Aries/Login/NewAvatar/Clothes_01_32bits.png;0 0 48 48"},
	genders = {
		982, -- teen female elf
		983, -- teen male elf
	},
};

-- female teen elf settings
NewAvatarDisplayPage.Choices_teen_male = {
	cartoonface_info = {
		[1] = { is_selected = true,section = "0#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#200#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/teen/Face04_32bits.png;0 0 48 48"},
		[2] = { is_selected = false,section = "0#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#201#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/teen/Face05_32bits.png;0 0 48 48"},
		[3] = { is_selected = false,section = "0#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#202#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/teen/Face06_32bits.png;0 0 48 48"},
	}, -- section 3
	hair_info = {
		[1] = { is_selected = true,section = "0#1#", icon = "Texture/Aries/Login/NewAvatar/teen/Hair04_32bits.png;0 0 48 48"},
		[2] = { is_selected = false,section = "0#2#", icon = "Texture/Aries/Login/NewAvatar/teen/Hair05_32bits.png;0 0 48 48"},
		[3] = { is_selected = false,section = "0#3#", icon = "Texture/Aries/Login/NewAvatar/teen/Hair06_32bits.png;0 0 48 48"},
	}, -- section 2
	skin_info = {
		[1] = { is_selected = true,section = "0#", icon = "Texture/Aries/Login/NewAvatar/teen/Skin01_32bits.png;0 0 48 48"},
		[2] = { is_selected = false,section = "1#", icon = "Texture/Aries/Login/NewAvatar/teen/Skin02_32bits.png;0 0 48 48"},
		[3] = { is_selected = false,section = "2#", icon = "Texture/Aries/Login/NewAvatar/teen/Skin03_32bits.png;0 0 48 48"},
	}, -- section 1
	clothes = {
		--{shirt = 1276, pants = 0, wrist = 0, boots = 1366, icon = "Texture/Aries/Login/NewAvatar/Clothes_01_32bits.png;0 0 48 48"}, -- level 10
		{shirt = 1001, pants = 0, wrist = 0, boots = 1002, icon = "Texture/Aries/Login/NewAvatar/Clothes_01_32bits.png;0 0 48 48"}, -- level 10
		--{shirt = 1320, pants = 0, wrist = 0, boots = 1410, icon = "Texture/Aries/Login/NewAvatar/Clothes_01_32bits.png;0 0 48 48"}, -- level 30
		--{shirt = 1001, pants = 0, wrist = 0, boots = 1002, icon = "Texture/Aries/Login/NewAvatar/Clothes_01_32bits.png;0 0 48 48"},
		--{shirt = 1053, pants = 1054, wrist = 0, boots = 1055, icon = "Texture/Aries/Login/NewAvatar/Clothes_02_32bits.png;0 0 48 48"},
		--{shirt = 1056, pants = 1057, wrist = 0, boots = 1058, icon = "Texture/Aries/Login/NewAvatar/Clothes_03_32bits.png;0 0 48 48"},
	},
	-- if provided, the user must wear this regardless of its choice 
	force_cloth = {shirt = 1001, pants = 0, wrist = 0, boots = 1002, icon = "Texture/Aries/Login/NewAvatar/Clothes_01_32bits.png;0 0 48 48"},
	genders = {
		982, -- teen female elf
		983, -- teen male elf
	},
};

NewAvatarDisplayPage.UserChoice = {
	cartoonface_info = 1, -- section 3
	hair_info = 1, -- section 2
	skin_info = 1, -- section 1
	clothes = 1,
	gender = 1, -- 1 for female, 2 for male
};

NewAvatarDisplayPage.asset_table = {
    name = "Aries_CreateNewAvatar_ingame",
    AssetFile="character/v3/Elf/Female/ElfFemale.xml",
	--CCSInfoStr="1#1#1#1#1#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#336#337#0#0#0#0#0#0#0#0#0#1005#1006#0#1007#0#0#0#0#0#0#",
	CCSInfoStr = "0#1#0#1#1#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#0#0#0#0#0#0#0#1027#1029#1031#0#1032#0#0#0#0#0#",
	IsCharacter = true,
    x=0,y=0,z=0,
};


local randomnames;

-- init
function NewAvatarDisplayPage.OnInit(asset_table)
	page = document:GetPageCtrl();
	
	-- use current player position and set dummy 
	local player = ParaScene.GetPlayer();
	local x,y,z = player:GetPosition();
	local facing = player:GetFacing();
	
	local node = page:GetNode("CreateNewAvatar");
	if(node) then
		if(System.options.version=="teen") then
			-- use mcml location.
			local pos_y = node:GetNumber("ExternalOffsetY")+node:GetNumber("LookAtHeight");
			player:SetPosition(node:GetNumber("ExternalOffsetX"), pos_y, node:GetNumber("ExternalOffsetZ"));
			facing = node:GetNumber("DefaultRotY")-3.14;
			player:SetFacing(facing);
			player:SetDensity(0); -- so it does not falldown
			
			--local Pet = commonlib.gettable("MyCompany.Aries.Pet");
			--asset_table.scaling = Pet.GetMainCharScaling();
		else
			-- use world main player location
			node:SetAttribute("ExternalOffsetX", x);
			node:SetAttribute("ExternalOffsetY", y);
			node:SetAttribute("ExternalOffsetZ", z);
			node:SetAttribute("DefaultRotY", facing + 3.14);
		end
	end
	
	asset_table.facing = facing;
	NewAvatarDisplayPage.facing = facing;

	if(System.options.version=="teen") then
		NewAvatarDisplayPage.Choices = if_else(NewAvatarDisplayPage.UserChoice.gender==1, NewAvatarDisplayPage.Choices_teen_female, NewAvatarDisplayPage.Choices_teen_male);
		page:SetNodeValue("gender", if_else(NewAvatarDisplayPage.UserChoice.gender==1, "female", "male"));
	else
		NewAvatarDisplayPage.Choices = NewAvatarDisplayPage.Choices_kids;
	end

	-- refresh
	NewAvatarDisplayPage.RefreshAvatar();

	-- init random name
	if(System.User.nickname) then
		if(page) then
			page:SetValue("nickname", System.User.nickname);
		end
	else
		if(System.options.version=="kids") then
			NewAvatarDisplayPage.OnRandomName();
		end
	end
end

-- return nil for kids version, 982 or 983 for teen female and male
function NewAvatarDisplayPage.GetGenderItem()
	local gender = if_else(System.options.version=="kids", nil, NewAvatarDisplayPage.Choices.genders[NewAvatarDisplayPage.UserChoice.gender] or 0);
	return gender;
end

function NewAvatarDisplayPage.RefreshAvatar()
	local section1 = NewAvatarDisplayPage.Choices.skin_info[NewAvatarDisplayPage.UserChoice.skin_info].section;
	local section2 = NewAvatarDisplayPage.Choices.hair_info[NewAvatarDisplayPage.UserChoice.hair_info].section;
	local section3 = NewAvatarDisplayPage.Choices.cartoonface_info[NewAvatarDisplayPage.UserChoice.cartoonface_info].section;
	local clothes = NewAvatarDisplayPage.Choices.clothes[NewAvatarDisplayPage.UserChoice.clothes];
	local shirt = clothes.shirt;
	local pants = clothes.pants;
	local wrist = clothes.wrist;
	local boots = clothes.boots;
	local gender = if_else(System.options.version=="kids", 0, NewAvatarDisplayPage.Choices.genders[NewAvatarDisplayPage.UserChoice.gender] or 0);
	
	local section_face = section1;
	local section_shirt = shirt;
	local section_boots = boots;
	if(System.options.version == "teen") then
		local skin_id = string.match(section1, "^(%d+)#$");
		if(skin_id) then
			section_face = if_else(NewAvatarDisplayPage.UserChoice.gender == 1, tonumber(skin_id) + 100, tonumber(skin_id) + 200).."#";
		end
		section_shirt = if_else(NewAvatarDisplayPage.UserChoice.gender == 1, shirt + 40000, shirt + 30000);
		section_boots = if_else(NewAvatarDisplayPage.UserChoice.gender == 1, boots + 40000, boots + 30000);
	end
	--  0# 1# 0#1# 1#@ 0# F#0#0#0#0# 0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0# @0#0#0#0#0#0#0#0#0#0#0#0#1034#1029#1010#0#1003#0#0#0#0#0#
	-- |S1|  | S2 |   |S1|          |S3                                                                      |S4
	NewAvatarDisplayPage.asset_table.CCSInfoStr = section1.."1#"..section2.."1#@"..section_face.."F#0#0#0#0#"..section3.."@0#0#0#0#0#"..gender.."#0#0#0#0#0#0#"..section_shirt.."#"..pants.."#"..section_boots.."#0#"..wrist.."#0#0#0#0#0#"
	commonlib.echo(NewAvatarDisplayPage.asset_table.CCSInfoStr);
	--page:Refresh(0.1);
	local canvasCtl = page:FindControl("CreateNewAvatar");
	if(canvasCtl) then
		canvasCtl:ShowModel(NewAvatarDisplayPage.asset_table);
	end
end

function NewAvatarDisplayPage.OnKeyup(ctrl)
	local ctrl = page:FindControl(ctrl);
	NewAvatarDisplayPage.nickname = ctrl.text;
end

function NewAvatarDisplayPage.OnClickItem_kids(index, choice)
	local ds;
	if(index == "1") then
		ds = NewAvatarDisplayPage.Choices.cartoonface_info;
	elseif(index == "2") then
		ds = NewAvatarDisplayPage.Choices.hair_info;
	elseif(index == "3") then
		ds = NewAvatarDisplayPage.Choices.skin_info;
	elseif(index == "4") then
		ds = NewAvatarDisplayPage.Choices.clothes;
	end
	
	if(index == "1") then
		NewAvatarDisplayPage.UserChoice.cartoonface_info = tonumber(choice);
	elseif(index == "2") then
		NewAvatarDisplayPage.UserChoice.hair_info = tonumber(choice);
	elseif(index == "3") then
		NewAvatarDisplayPage.UserChoice.skin_info = tonumber(choice);
	elseif(index == "4") then
		NewAvatarDisplayPage.UserChoice.clothes = tonumber(choice);
	end
	commonlib.echo({index, choice});
	commonlib.echo(NewAvatarDisplayPage.UserChoice);
	NewAvatarDisplayPage.RefreshAvatar()
end

function NewAvatarDisplayPage.OnClickItem(index,mcmlNode)
	local ds;
	local i,v;
	local choice = mcmlNode:GetAttribute("param1");
	choice = tonumber(choice);
	
	if(index == "11" or index == "12") then
		ds = NewAvatarDisplayPage.Choices.cartoonface_info;
	elseif(index == "21" or index == "22") then
		ds = NewAvatarDisplayPage.Choices.hair_info;
	elseif(index == "31" or index == "32") then
		ds = NewAvatarDisplayPage.Choices.skin_info;
	elseif(index == "41" or index == "42") then
		ds = NewAvatarDisplayPage.Choices.clothes;
	end

	if(index == "11" or index == "12") then
		NewAvatarDisplayPage.UserChoice.cartoonface_info = tonumber(choice);
	elseif(index == "22" or index == "22") then
		NewAvatarDisplayPage.UserChoice.hair_info = tonumber(choice);
	elseif(index == "31" or index == "32") then
		NewAvatarDisplayPage.UserChoice.skin_info = tonumber(choice);
	elseif(index == "41" or index == "42") then
		NewAvatarDisplayPage.UserChoice.clothes = tonumber(choice);
	end

	commonlib.echo({index, choice});
	commonlib.echo(NewAvatarDisplayPage.UserChoice);
	
	for i,v in pairs(ds)do
		if(i == choice)then
			v.is_selected = true;
		else
			v.is_selected = false;
		end
	end

	NewAvatarDisplayPage.RefreshAvatar()
	NewAvatarDisplayPage:RefreshPage();
end

function NewAvatarDisplayPage:RefreshPage(delta)
	local page = self.page or document:GetPageCtrl();
	
	if(page)then
		page:Refresh(delta or 0.1);
	end
end

function NewAvatarDisplayPage.OnRandom()
	local k,v;
	local r = math.random(1, #(NewAvatarDisplayPage.Choices.cartoonface_info) * 100);
	NewAvatarDisplayPage.UserChoice.cartoonface_info = math.ceil(r/100);
	for k,v in pairs(NewAvatarDisplayPage.Choices.cartoonface_info)do
		if(k == NewAvatarDisplayPage.UserChoice.cartoonface_info)then
			v.is_selected = true;
		else
			v.is_selected = false;
		end
	end

	local r = math.random(1, #(NewAvatarDisplayPage.Choices.hair_info) * 100);
	NewAvatarDisplayPage.UserChoice.hair_info = math.ceil(r/100);
	for k,v in pairs(NewAvatarDisplayPage.Choices.hair_info)do
		if(k == NewAvatarDisplayPage.UserChoice.hair_info)then
			v.is_selected = true;
		else
			v.is_selected = false;
		end
	end

	local r = math.random(1, #(NewAvatarDisplayPage.Choices.skin_info) * 100);
	NewAvatarDisplayPage.UserChoice.skin_info = math.ceil(r/100);
	for k,v in pairs(NewAvatarDisplayPage.Choices.skin_info)do
		if(k == NewAvatarDisplayPage.UserChoice.skin_info)then
			v.is_selected = true;
		else
			v.is_selected = false;
		end
	end

	local r = math.random(1, #(NewAvatarDisplayPage.Choices.clothes) * 100);
	NewAvatarDisplayPage.UserChoice.clothes = math.ceil(r/100);
	for k,v in pairs(NewAvatarDisplayPage.Choices.clothes)do
		if(k == NewAvatarDisplayPage.UserChoice.clothes)then
			v.is_selected = true;
		else
			v.is_selected = false;
		end
	end

	NewAvatarDisplayPage.RefreshAvatar();
	NewAvatarDisplayPage:RefreshPage();
end

-- this is for teen version only. 
function NewAvatarDisplayPage.OnCheckNickName()
	local self = NewAvatarDisplayPage;
	self.nickname = page:GetValue("nickname");
	--[[if(string.find(self.nickname," "))then
		_guihelper.MessageBox("名字包含空格字符！");
		return
	end
	]]
	self.nickname = string.gsub(self.nickname," ","");
	if(string.len(self.nickname) == 0)then
		_guihelper.MessageBox("请给你的角色取一个有效的名字！");
		return
	end

	local count_charCN = math.floor((string.len(self.nickname) - ParaMisc.GetUnicodeCharNum(self.nickname))/2);
	local count_weight = ParaMisc.GetUnicodeCharNum(self.nickname) + count_charCN;
		
	local certified_nickname = MyCompany.Aries.Chat.BadWordFilter.FilterStringForUserName(self.nickname);
	if(certified_nickname ~= self.nickname) then
		_guihelper.MessageBox(format("你的昵称中包含非法语言:%s", self.nickname));
	elseif(count_weight > 16) then
		_guihelper.MessageBox("你的昵称太长了，请挑选一个短点的吧。");
	else
		paraworld.users.CheckNickName({nname=self.nickname}, nil, function(msg)
			if(msg) then
				if(msg.nid and msg.nid == -1) then
					_guihelper.MessageBox(format("恭喜！ [%s]可以使用！", NewAvatarDisplayPage.nickname));
				else
					_guihelper.MessageBox(format("抱歉！ [%s]已经被使用， 请换个名字试试吧！", NewAvatarDisplayPage.nickname));
				end
			end
		end)
	end
end

function NewAvatarDisplayPage.OnRandomName()
	if(page) then
		if(not randomnames) then
			local randomname_xmlRoot = ParaXML.LuaXML_ParseFile("config/NewbieNames.xml");
			local each_name;
			for each_name in commonlib.XPath.eachNode(randomname_xmlRoot, "/newbie_names/name") do
				randomnames = randomnames or {};
				table.insert(randomnames, each_name.attr.value);
			end
		end
		local name = "开心哈奇";
		if(randomnames) then
			name = randomnames[math.random(1, #randomnames)];
		end
		page:SetValue("nickname", name);
	end
end

function NewAvatarDisplayPage.DS_Func_Faces(index)
	if(index == nil) then
		return #(NewAvatarDisplayPage.Choices.cartoonface_info);
	elseif(index) then
		return NewAvatarDisplayPage.Choices.cartoonface_info[index];
	end
end

function NewAvatarDisplayPage.DS_Func_Hair(index)
	if(index == nil) then
		return #(NewAvatarDisplayPage.Choices.hair_info);
	elseif(index) then
		return NewAvatarDisplayPage.Choices.hair_info[index];
	end
end

function NewAvatarDisplayPage.DS_Func_SkinColor(index)
	if(index == nil) then
		return #(NewAvatarDisplayPage.Choices.skin_info);
	elseif(index) then
		return NewAvatarDisplayPage.Choices.skin_info[index];
	end
end

function NewAvatarDisplayPage.DS_Func_Clothes(index)
	if(index == nil) then
		return #(NewAvatarDisplayPage.Choices.clothes);
	elseif(index) then
		return NewAvatarDisplayPage.Choices.clothes[index];
	end
end

function NewAvatarDisplayPage.UpdateButtonEnableness()
	local nickname = page:GetValue("nickname");
    if(nickname == "") then
		page:SetUIEnabled("selected_btn", false);
		page:SetUIEnabled("tooltip_btn", true);
    elseif(nickname ~= "") then
		page:SetUIEnabled("selected_btn", true);
		page:SetUIEnabled("tooltip_btn", false);
    end
end

function NewAvatarDisplayPage.OnPrev()
	--page:CloseWindow();
end

-- set HasActivationCode to true if one wants to skip activation code check. 
local HasActivationCode = false;
function NewAvatarDisplayPage.OnNext()
	if(not HasActivationCode) then
		NewAvatarDisplayPage.OnCheckActivationCode();
	else
		NewAvatarDisplayPage.OnCreateAvatar()
	end	
end

function NewAvatarDisplayPage.OnCheckActivationCode()
	if(page) then
		local ctl = page:FindControl("ActivationCode");
		if(not ctl) then
			NewAvatarDisplayPage.OnCreateAvatar()
			return;
		end

		-- check activation code. 
		local sActivationCode = page:GetUIValue("ActivationCode");
		if(sActivationCode == "" or #sActivationCode<=3 or #sActivationCode>10) then
			_guihelper.MessageBox("请输入体验码")
			return
		end
		
		-- remove additional space
		sActivationCode = string.gsub(sActivationCode, "%s", "");
		
		---- secret universal activation code
		--if(sActivationCode == "7654321") then
			--HasActivationCode = true;
			--NewAvatarDisplayPage.OnCreateAvatar();
			--return
		--end
		local function on_failed_activate()
			if(System.options.isAB_SDK) then
				_guihelper.MessageBox("SDK版可以跳过体验码，是否现在进入游戏？", function()
					NewAvatarDisplayPage.OnCreateAvatar();
				end)
			end
		end
		paraworld.users.UseCDKey({keycode=sActivationCode}, "test", function(msg)
			commonlib.echo(msg)
			-- result 0:成功 1:CDKEY不存在 2:CDKEY已被使用
			if(msg.result == 0) then
				HasActivationCode = true;
				NewAvatarDisplayPage.OnCreateAvatar();
			elseif(msg.result == 1) then
				_guihelper.MessageBox("体验码:"..sActivationCode.."无效", on_failed_activate)
			elseif(msg.result == 2) then
				_guihelper.MessageBox("体验码:"..sActivationCode.."已经被使用过了", on_failed_activate)
			end
		end);
	end	
end

function NewAvatarDisplayPage.GetActivationCode()
	local url = MyCompany.Aries.ExternalUserModule:GetConfig().activation_code_url or "http://haqi2.paraengine.com/getinvitecode.html";
	if(url) then
		ParaGlobal.ShellExecute("open", url, "", "", 1);
	end
end

function NewAvatarDisplayPage.GotoWebSite()
	local official_site_url = MyCompany.Aries.ExternalUserModule:GetConfig().official_site_url;
	if(official_site_url) then
		ParaGlobal.ShellExecute("open", official_site_url, "", "", 1);
	end
end

function NewAvatarDisplayPage.OnCreateAvatar()
	if(page) then
		local self = NewAvatarDisplayPage;
		self.nickname = page:GetValue("nickname");
		self.nickname = string.gsub(self.nickname," ","");
		if(string.len(self.nickname) == 0)then
			_guihelper.MessageBox("请给你的角色取一个有效的名字！");
			return
		end

		local count_charCN = math.floor((string.len(self.nickname) - ParaMisc.GetUnicodeCharNum(self.nickname))/2);
		local count_weight = ParaMisc.GetUnicodeCharNum(self.nickname) + count_charCN;
		
		local certified_nickname = MyCompany.Aries.Chat.BadWordFilter.FilterStringForUserName(self.nickname);
		if(certified_nickname ~= self.nickname) then
			_guihelper.MessageBox(format("你的昵称中包含非法语言:%s", self.nickname));
			do return end;
		elseif(count_weight > 16) then
			_guihelper.MessageBox("你的昵称太长了，请挑选一个短点的吧。");
			do return end;
		end
		log("-------- NewAvatarDisplayPage.OnNext() --------\n")
		commonlib.echo(string.len(self.nickname));
		
		local section1 = NewAvatarDisplayPage.Choices.skin_info[NewAvatarDisplayPage.UserChoice.skin_info].section;
		local section2 = NewAvatarDisplayPage.Choices.hair_info[NewAvatarDisplayPage.UserChoice.hair_info].section;
		local section3 = NewAvatarDisplayPage.Choices.cartoonface_info[NewAvatarDisplayPage.UserChoice.cartoonface_info].section;
		local clothes = NewAvatarDisplayPage.Choices.force_cloth or NewAvatarDisplayPage.Choices.clothes[NewAvatarDisplayPage.UserChoice.clothes];
		local shirt = clothes.shirt;
		local pants = clothes.pants;
		local wrist = clothes.wrist;
		local boots = clothes.boots;
		
		
		local section_face = section1;
		local section_shirt = shirt;
		local section_boots = boots;
		if(System.options.version == "teen") then
			local skin_id = string.match(section1, "^(%d+)#$");
			if(skin_id) then
				section_face = if_else(NewAvatarDisplayPage.UserChoice.gender == 1, tonumber(skin_id) + 100, tonumber(skin_id) + 200).."#";
			end
			section_shirt = if_else(NewAvatarDisplayPage.UserChoice.gender == 1, shirt + 40000, shirt + 30000);
			section_boots = if_else(NewAvatarDisplayPage.UserChoice.gender == 1, boots + 40000, boots + 30000);
		end

		local base_avatar_string = section1.."1#"..section2.."1#@"..section_face.."F#0#0#0#0#"..section3.."@";
		commonlib.echo(base_avatar_string);
		commonlib.echo(shirt);
		commonlib.echo(pants);
		commonlib.echo(wrist);
		commonlib.echo(boots);
		
		if(not base_avatar_string or not pants) then
			return;
		end
		
		local list = {};
		if(shirt ~= 0) then
			table.insert(list, shirt);
		end
		if(pants ~= 0) then
			table.insert(list, pants);
		end
		if(wrist ~= 0) then
			table.insert(list, wrist);
		end
		if(boots ~= 0) then
			table.insert(list, boots);
		end

		-- goto next page
		local function OnNextPage()
			page:CloseWindow();
			-- send log information
			paraworld.PostLog({action = "create_role_success"}, "create_role_success_log", function(msg)
			end);
			-- send log information
			paraworld.PostLog({action = "joybean_obtain_newavatar"}, "joybean_obtain_newavatar_log", function(msg)
			end);
			-- proceed to next step. 
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = if_else(System.options.version=="kids", "script/apps/Aries/Login/NewAvatarFinishPage.html","script/apps/Aries/Login/NewAvatarFinishPage.teen.html").."?canvasvalue="..NewAvatarDisplayPage.asset_table.CCSInfoStr, 
				name = "NewAvatarFinishPage", 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 2,
				allowDrag = false,
				directPosition = true,
					align = "_fi",
					x = 0,
					y = 0,
					width = 0,
					height = 0,
				cancelShowAnimation = true,
			});
		end
						
		local ItemManager = System.Item.ItemManager;
		
		local function FinishCreateAvatar()
			-- 999_ccsinfo_user with base_avatar_string as clientdata
			_guihelper.MessageBox(nil)
			ItemManager.PurchaseItem(999, 1, function(msg)
				if(msg) then
					log("+++++++Purchase item #999 return: +++++++\n")
					commonlib.echo(msg);
					-- 424: 购买数量超过限制 
					if(msg.issuccess == true or msg.errorcode == 424) then
						OnNextPage()
					end
				end
			end, function(msg) end, base_avatar_string, "none", false);
		end
		
		local is_gender_finished = false;

		local function TryEndCreateAvatar()
			if(not is_gender_finished) then
				return;
			end
			local _, bReturned;
			for _, bReturned in ipairs(list) do
				if(bReturned ~= true) then
					return;
				end
			end
			
			FinishCreateAvatar();			
		end

		-- now purchase the gender item
		local gender_item = NewAvatarDisplayPage.GetGenderItem();
		if(gender_item) then
			ItemManager.PurchaseItem(gender_item, 1, function(msg)
				LOG.std(nil, "system", "newplayer", "gender is selected and item %s purchased", tostring(gender_item));
				is_gender_finished = true;
				TryEndCreateAvatar();
			end, nil, nil, "none");
		else
			is_gender_finished = true;
		end

		
		
		local function ContinueAvatarItemPurchase()
			-- gsid from 1050 to 1064
			-- 5 pairs init registration clothes
			-- 1050 1051 1052 ...
			
			-- purchase shirt pants wrist boots if choose
			local _, gsid;
			for _, gsid in ipairs(list) do
				ItemManager.PurchaseItem(gsid, 1, function(msg)
					if(msg) then
						log("+++++++Purchase item #"..tostring(gsid).." return: +++++++\n")
						commonlib.echo(msg);
						if(msg.issuccess == true or msg.errorcode == 424) then
						--if(msg.issuccess) then
							-- msg.guid: newly purchased item guid
							if(msg.adds and msg.adds[1]) then
								ItemManager.EquipItem(msg.adds[1].guid, function(msg)
									if(msg.issuccess == true) then
										log("+++++++ equip item #"..shirt.." afterward return: +++++++\n")
										commonlib.echo(msg);
									end
									list[_] = true;
									TryEndCreateAvatar();
								end, 1, gsid, false);
							else
								list[_] = true;
								TryEndCreateAvatar();
							end
						else
							if(msg.errorcode== 419) then
								_guihelper.MessageBox("账号长期不登录已经被注销,请用其他账号登录");
							else
								list[_] = true;
								TryEndCreateAvatar();
							end
						end
					else
						list[_] = true;
						TryEndCreateAvatar();
					end
				end, function(msg) end, nil, "none", false);
			end
			
			---- throwable
			--local ItemManager = System.Item.ItemManager;
			--ItemManager.PurchaseItem(9501, 1, function(msg)
				--if(msg) then
					--log("+++++++Purchase item #9501 return: +++++++\n")
				--end
			--end, function(msg) end, nil, "none", false);
			--local ItemManager = System.Item.ItemManager;
			--ItemManager.PurchaseItem(9502, 1, function(msg)
				--if(msg) then
					--log("+++++++Purchase item #9502 return: +++++++\n")
				--end
			--end, function(msg) end, nil, "none", false);
			--ItemManager.PurchaseItem(9002, 1, function(msg)
				--if(msg) then
					--log("+++++++Purchase item 9002_LoopDance1 return: +++++++\n")
				--end
			--end, function(msg) end, nil, "none", false);
			--ItemManager.PurchaseItem(9003, 1, function(msg)
				--if(msg) then
					--log("+++++++Purchase item 9003_LoopDance2 return: +++++++\n")
				--end
			--end, function(msg) end, nil, "none", false);
		end
		
		-- all purchase items returned
		local msg = {
			nickname = self.nickname,
		};
		if(System.options.version == "kids") then
			paraworld.users.setInfo(msg, "SetNickNameInCreateAvatar", function(msg)
				log("+++++++ SetNickNameInCreateAvatar return: +++++++\n")
				if(msg and msg.issuccess == true) then
					_guihelper.MessageBox("正在初始化人物, 请稍候")
					ContinueAvatarItemPurchase();
				else
					if(msg.errorcode == 418) then
						_guihelper.MessageBox("该昵称已经有人使用了，请选择其他昵称");
					else
						_guihelper.MessageBox("该昵称不能使用");
					end
				end
			end);
		else
			paraworld.users.setInfo2(msg, nil, function(msg)
				if(msg and msg.issuccess == true) then
					ContinueAvatarItemPurchase();
				else
					LOG.std(nil, "warn", "NewAvatarDisplayPage", "paraworld.users.setInfo2 error code "..tostring(msg.errorcode));
					if(msg.errorcode == 418) then
						_guihelper.MessageBox(format("抱歉！ [%s]已经被使用， 请换个名字试试吧！", NewAvatarDisplayPage.nickname));
					else
						_guihelper.MessageBox("该昵称不能使用");
					end
				end
			end);
		end
	end
end	