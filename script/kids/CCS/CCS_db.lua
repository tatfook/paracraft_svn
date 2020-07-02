--[[
Title: character customization database. 
Author(s): LiXizhi
Date: 2007/7/7
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/CCS/CCS_db.lua");
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/CCS/CCS_UI_Predefined.lua");
NPL.load("(gl)script/sqlite/sqlite3.lua");


-- Debug purpose
NPL.load("(gl)script/ide/gui_helper.lua");

if(not CCS_db) then CCS_db={}; end

CCS_db.dbfile = "Database/characters.db";
CCS_db.ModelDir = "character/v3/Child/";
CCS_db.Gender= "Male";
CCS_db.ItemObjectPath = "character/v3/Item/ObjectComponents/";
CCS_db.ItemTexturePath = "character/v3/Item/TextureComponents/";
CCS_db.ItemIdLists = {};
CCS_db.ItemIdSlotLists = {};
CCS_db.FaceStyleLists = {};
CCS_db.FaceIconLists = {};
CCS_db.FaceStyleIterators = {};

CCS_db.CurrentCharacterInfo = {};

-- the following are calculated
CCS_db.ModelName = "Child";
CCS_db.ModelPath = "character/v3/Child/Male/ChildMale.x";

-- character slots
CCS_db.CS_HEAD =0;
CCS_db.CS_NECK = 1;
CCS_db.CS_SHOULDER = 2;
CCS_db.CS_BOOTS = 3;
CCS_db.CS_BELT = 4;
CCS_db.CS_SHIRT = 5;
CCS_db.CS_PANTS = 6;
CCS_db.CS_CHEST = 7;
CCS_db.CS_BRACERS = 8;
CCS_db.CS_GLOVES = 9;
CCS_db.CS_HAND_RIGHT = 10;
CCS_db.CS_HAND_LEFT = 11;
CCS_db.CS_CAPE = 12;
CCS_db.CS_TABARD = 13;

-- item types
CCS_db.IT_HEAD = 1;
CCS_db.IT_NECK=2;--脖子
CCS_db.IT_SHOULDER=3;-- 肩
CCS_db.IT_SHIRT=4;-- 上衣
CCS_db.IT_CHEST=5;-- 胸
CCS_db.IT_BELT=6;
CCS_db.IT_PANTS=7;-- 裤子
CCS_db.IT_BOOTS=8; -- 鞋子
CCS_db.IT_BRACERS=9;
CCS_db.IT_GLOVES=10;-- 手套
CCS_db.IT_RINGS=11;
CCS_db.IT_OFFHAND=12;
CCS_db.IT_DAGGER=13;
CCS_db.IT_SHIELD=14;
CCS_db.IT_BOW=15;
CCS_db.IT_CAPE=16; -- 披风
CCS_db.IT_2HANDED=17;-- 双手
CCS_db.IT_QUIVER=18;
CCS_db.IT_TABARD=19;
CCS_db.IT_ROBE=20;
CCS_db.IT_1HANDED=21;-- 单手
CCS_db.IT_CLAW=22;
CCS_db.IT_ACCESSORY=23;
CCS_db.IT_THROWN=24;
CCS_db.IT_GUN=25;

-- cartoon face component
CCS_db.CFS_FACE = 0;
CCS_db.CFS_WRINKLE = 1;
CCS_db.CFS_EYE = 2;
CCS_db.CFS_EYEBROW = 3;
CCS_db.CFS_MOUTH = 4;
CCS_db.CFS_NOSE = 5;
CCS_db.CFS_MARKS = 6;

-- cartoon face sub type
CCS_db.CFS_SUB_Style = 0;
CCS_db.CFS_SUB_Color = 1;
CCS_db.CFS_SUB_Scale = 2;
CCS_db.CFS_SUB_Rotation = 3;
CCS_db.CFS_SUB_X = 4;
CCS_db.CFS_SUB_Y = 5;

-- reset the base model
function CCS_db.ResetBaseModel(ModelDir, Gender)
	CCS_db.ModelDir = ModelDir;
	CCS_db.Gender = Gender;
	
	-- calculate other paths.
	CCS_db.ModelName = string.gsub(ModelDir, ".*/(.-)/$", "%1");
	CCS_db.ModelPath = string.format("%s%s/%s%s.x", ModelDir, Gender, CCS_db.ModelName, Gender);
end

-- e.g. local player, playerChar = CCS_db.GetPlayerChar();
function CCS_db.GetPlayerChar()
	local player = ObjEditor.GetCurrentObj();
	if(player~=nil and player:IsValid()==true) then
		if(player:IsCharacter()) then
			local playerChar = player:ToCharacter();
			return player, playerChar;
		end
	end	
end


-- return a table containing a list of IDs for a given item type;the last one is always 0
-- @param Type: item types such as CCS_db.IT_CAPE
function CCS_db.GetItemIdListByType(type)
	if(not CCS_db.ItemIdLists[type]) then
		-- only fetch on demand and if it has never been fetched before.
		local result = {};
		local i=1;
		local db = sqlite3.open(CCS_db.dbfile);
		local row;
		for row in db:rows(string.format("select id from ItemDatabase where type=%d",type)) do
			result[i] = tonumber(row.id);
			i = i+1;
		end
		result[i] = 0; -- the last one is always 0, which means no item.
		
		db:close();
		CCS_db.ItemIdLists[type] = result;
	end
	return CCS_db.ItemIdLists[type];
end


-- return a table containing a list of IDs for a given item type;the last one is always 0
-- @param Type: item types such as CCS_db.CS_HAND_RIGHT
function CCS_db.GetItemIdListBySlotType(type)
	if(not CCS_db.ItemIdSlotLists[type]) then
		-- only fetch on demand and if it has never been fetched before.
		local result = {};
		local i=1;
		local db = sqlite3.open(CCS_db.dbfile);
		local row;
		local typeStr;

		if(type == CCS_db.CS_HEAD) then
			typeStr = "1";
		elseif(type == CCS_db.CS_NECK) then
			typeStr = "2";
		elseif(type == CCS_db.CS_SHOULDER) then
			typeStr = "3";
		elseif(type == CCS_db.CS_BOOTS) then
			typeStr = "8";
		elseif(type == CCS_db.CS_BELT) then
			typeStr = "6";
		elseif(type == CCS_db.CS_SHIRT) then
			typeStr = "4";
		elseif(type == CCS_db.CS_PANTS) then
			typeStr = "7";
		elseif(type == CCS_db.CS_CHEST) then
			typeStr = "5".." or ".."type = 20";
		elseif(type == CCS_db.CS_BRACERS) then
			typeStr = "9";
		elseif(type == CCS_db.CS_GLOVES) then
			typeStr = "10";
		elseif(type == CCS_db.CS_HAND_RIGHT) then
			typeStr = "11".." or ".."type = 13"
				.." or ".."type = 15".." or ".."type = 21"
				.." or ".."type = 22".." or ".."type = 24"
				.." or ".."type = 25";
		elseif(type == CCS_db.CS_HAND_LEFT) then
			typeStr = "11".." or ".."type = 12"
				.." or ".."type = 13".." or ".."type = 14"
				.." or ".."type = 18".." or ".."type = 21"
				.." or ".."type = 22".." or ".."type = 23"
				.." or ".."type = 24".." or ".."type = 25";
		elseif(type == CCS_db.CS_CAPE) then
			typeStr = "16";
		elseif(type == CCS_db.CS_TABARD) then
			typeStr = "19";
		end
		
		for row in db:rows(string.format("select id from ItemDatabase where type=%s",typeStr)) do
			result[i] = tonumber(row.id);
			i = i+1;
		end
		--result[i] = 0; -- the last one is always 0, which means no item.
		
		db:close();
		CCS_db.ItemIdSlotLists[type] = result;
	end
	return CCS_db.ItemIdSlotLists[type];
end

-- return a table containing a list of style IDs for the given face component
-- @param nComponentID: such as CCS_db.CFS_FACE
function CCS_db.GetFaceComponentStyleList(nComponentID)
	if(not CCS_db.FaceStyleLists[nComponentID]) then
		-- only fetch on demand and if it has never been fetched before.
		local result = {};
		local i=1;
		local db = sqlite3.open(CCS_db.dbfile);
		local row;
		for row in db:rows(string.format("select Style from CartoonFaceDB where Type=%d",nComponentID)) do
			result[i] = tonumber(row.Style);
			i = i+1;
		end
		
		db:close();
		CCS_db.FaceStyleLists[nComponentID] = result;
	end
	return CCS_db.FaceStyleLists[nComponentID];
end

-- return a table containing a list of Icon path for the given face component
-- @param nComponentID: such as CCS_db.CFS_FACE
function CCS_db.GetFaceComponentIconList(nComponentID)
	if(not CCS_db.FaceIconLists[nComponentID]) then
		-- only fetch on demand and if it has never been fetched before.
		local result = {};
		local i=1;
		local db = sqlite3.open(CCS_db.dbfile);
		local row;
		for row in db:rows(string.format("select Icon from CartoonFaceDB where Type=%d",nComponentID)) do
			result[i] = tostring(row.Icon);
			i = i+1;
		end
		db:close();
		CCS_db.FaceIconLists[nComponentID] = result;
	end
	return CCS_db.FaceIconLists[nComponentID];
end


-- set the face component parameters
-- e.g. CCS_db.SetFaceComponent(CCS_db.CFS_EYE, CCS_db.CFS_SUB_Scale, 0.1);
-- @param nComponentID: such as CCS_db.CFS_FACE
-- @param SubType: such as CCS_db.CFS_SUB_Scale, if this is nil, it will call ResetFaceComponent() instead
-- 0: style: int [0,00]
-- 1: color: 32bits ARGB
-- 2: scale: float in [-1,1]
-- 3: rotation: float in (-3.14,3.14]
-- 4: x: (-128,128]
-- 5: y: (-128,128]
-- @param value: it is abolute for face type and color, and delta value for all other types.
--   if SubType is style and value is nil, it will automatically select the next style
-- @param refreshModel: if nil, it will automatically refresh the character model, otherwise it will not refresh the model.
function CCS_db.SetFaceComponent(nComponentID, SubType, value)
	local player, playerChar = CCS_db.GetPlayerChar();
	if(playerChar~=nil) then
		if(not SubType) then
			return CCS_db.ResetFaceComponent(nComponentID);
		end
		if(not value)then
			if(SubType == CCS_db.CFS_SUB_Style) then
				-- iterate through all available ones in the database
				local samples = CCS_db.GetFaceComponentStyleList(nComponentID);
				if(not CCS_db.FaceStyleIterators[nComponentID]) then
					CCS_db.FaceStyleIterators[nComponentID] = 0;
				else
					CCS_db.FaceStyleIterators[nComponentID] = math.mod(CCS_db.FaceStyleIterators[nComponentID]+1, table.getn(samples));
				end	
				value = samples[CCS_db.FaceStyleIterators[nComponentID]+1];
			else
				return
			end
		end
			
		if(SubType == CCS_db.CFS_SUB_Style or SubType == CCS_db.CFS_SUB_Color) then
			-- value is absolute
			playerChar:SetCartoonFaceComponent(nComponentID, SubType, value);
		else
			-- value is delta
			local oldvalue = playerChar:GetCartoonFaceComponent(nComponentID, SubType);
			playerChar:SetCartoonFaceComponent(nComponentID, SubType, value+oldvalue);
		end	
	end
end

-- reset the given face component to default value
function CCS_db.ResetFaceComponent(nComponentID)
	local player, playerChar = CCS_db.GetPlayerChar();
	if(playerChar~=nil) then	
		playerChar:SetCartoonFaceComponent(nComponentID, CCS_db.CFS_SUB_Color, _guihelper.RGBA_TO_DWORD(255,255,255));
		playerChar:SetCartoonFaceComponent(nComponentID, CCS_db.CFS_SUB_Scale, 0);
		playerChar:SetCartoonFaceComponent(nComponentID, CCS_db.CFS_SUB_Rotation, 0);
		playerChar:SetCartoonFaceComponent(nComponentID, CCS_db.CFS_SUB_X, 0);
		playerChar:SetCartoonFaceComponent(nComponentID, CCS_db.CFS_SUB_Y, 0);
	end
end

function CCS_db.SaveCurrentCharacterCCSInfo()

	CCS_db.LoadIdentityCurrentCharacterInfo();
	
	local player, playerChar = CCS_db.GetPlayerChar();
	
	if(player ~= nil and player:IsValid()==true) then
		if(player:IsCharacter()==true and playerChar:IsCustomModel()==true) then
			CCS_db.CurrentCharacterInfo.skinColor = playerChar:GetBodyParams(0);
			CCS_db.CurrentCharacterInfo.faceType = playerChar:GetBodyParams(1);
			CCS_db.CurrentCharacterInfo.hairColor = playerChar:GetBodyParams(2);
			CCS_db.CurrentCharacterInfo.hairStyle = playerChar:GetBodyParams(3);
			CCS_db.CurrentCharacterInfo.facialHair = playerChar:GetBodyParams(4);
			
			CCS_db.CurrentCharacterInfo.itemHead = playerChar:GetCharacterSlotItemID(0);
			CCS_db.CurrentCharacterInfo.itemNeck = playerChar:GetCharacterSlotItemID(1);
			CCS_db.CurrentCharacterInfo.itemShoulder = playerChar:GetCharacterSlotItemID(2);
			CCS_db.CurrentCharacterInfo.itemBoots = playerChar:GetCharacterSlotItemID(3);
			CCS_db.CurrentCharacterInfo.itemBelt = playerChar:GetCharacterSlotItemID(4);
			CCS_db.CurrentCharacterInfo.itemShirt = playerChar:GetCharacterSlotItemID(5);
			CCS_db.CurrentCharacterInfo.itemPants = playerChar:GetCharacterSlotItemID(6);
			CCS_db.CurrentCharacterInfo.itemChest = playerChar:GetCharacterSlotItemID(7);
			CCS_db.CurrentCharacterInfo.itemBracers = playerChar:GetCharacterSlotItemID(8);
			CCS_db.CurrentCharacterInfo.itemGloves = playerChar:GetCharacterSlotItemID(9);
			CCS_db.CurrentCharacterInfo.itemHandRight = playerChar:GetCharacterSlotItemID(10);
			CCS_db.CurrentCharacterInfo.itemHandLeft = playerChar:GetCharacterSlotItemID(11);
			CCS_db.CurrentCharacterInfo.itemCape = playerChar:GetCharacterSlotItemID(12);
			CCS_db.CurrentCharacterInfo.itemTabard = playerChar:GetCharacterSlotItemID(13);
			
			-- TODO: race and gender
			CCS_db.CurrentCharacterInfo.gender = playerChar:GetGender();
			CCS_db.CurrentCharacterInfo.raceId = playerChar:GetRaceID();
			
			CCS_db.CurrentCharacterInfo.IsCustomModel = true;
		else
			CCS_db.CurrentCharacterInfo.IsCustomModel = false;
			CCS_db.CurrentCharacterInfo.ModelName = "ModelName";
		end
			
		if(player:IsCharacter()==true and playerChar:IsSupportCartoonFace()==true) then
			CCS_db.CurrentCharacterInfo.cartoonFaceType = playerChar:GetCartoonFaceComponent(0, 0);
			CCS_db.CurrentCharacterInfo.cartoonFaceColor = playerChar:GetCartoonFaceComponent(0, 1);
			CCS_db.CurrentCharacterInfo.cartoonFaceScale = playerChar:GetCartoonFaceComponent(0, 2);
			CCS_db.CurrentCharacterInfo.cartoonFaceRotation = playerChar:GetCartoonFaceComponent(0, 3);
			CCS_db.CurrentCharacterInfo.cartoonFaceX = playerChar:GetCartoonFaceComponent(0, 4);
			CCS_db.CurrentCharacterInfo.cartoonFaceY = playerChar:GetCartoonFaceComponent(0, 5);
			
			CCS_db.CurrentCharacterInfo.cartoonWrinkleType = playerChar:GetCartoonFaceComponent(1, 0);
			CCS_db.CurrentCharacterInfo.cartoonWrinkleColor = playerChar:GetCartoonFaceComponent(1, 1);
			CCS_db.CurrentCharacterInfo.cartoonWrinkleScale = playerChar:GetCartoonFaceComponent(1, 2);
			CCS_db.CurrentCharacterInfo.cartoonWrinkleRotation = playerChar:GetCartoonFaceComponent(1, 3);
			CCS_db.CurrentCharacterInfo.cartoonWrinkleX = playerChar:GetCartoonFaceComponent(1, 4);
			CCS_db.CurrentCharacterInfo.cartoonWrinkleY = playerChar:GetCartoonFaceComponent(1, 5);
			
			CCS_db.CurrentCharacterInfo.cartoonEyeType = playerChar:GetCartoonFaceComponent(2, 0);
			CCS_db.CurrentCharacterInfo.cartoonEyeColor = playerChar:GetCartoonFaceComponent(2, 1);
			CCS_db.CurrentCharacterInfo.cartoonEyeScale = playerChar:GetCartoonFaceComponent(2, 2);
			CCS_db.CurrentCharacterInfo.cartoonEyeRotation = playerChar:GetCartoonFaceComponent(2, 3);
			CCS_db.CurrentCharacterInfo.cartoonEyeX = playerChar:GetCartoonFaceComponent(2, 4);
			CCS_db.CurrentCharacterInfo.cartoonEyeY = playerChar:GetCartoonFaceComponent(2, 5);
			
			CCS_db.CurrentCharacterInfo.cartoonEyebrowType = playerChar:GetCartoonFaceComponent(3, 0);
			CCS_db.CurrentCharacterInfo.cartoonEyebrowColor = playerChar:GetCartoonFaceComponent(3, 1);
			CCS_db.CurrentCharacterInfo.cartoonEyebrowScale = playerChar:GetCartoonFaceComponent(3, 2);
			CCS_db.CurrentCharacterInfo.cartoonEyebrowRotation = playerChar:GetCartoonFaceComponent(3, 3);
			CCS_db.CurrentCharacterInfo.cartoonEyebrowX = playerChar:GetCartoonFaceComponent(3, 4);
			CCS_db.CurrentCharacterInfo.cartoonEyebrowY = playerChar:GetCartoonFaceComponent(3, 5);
			
			CCS_db.CurrentCharacterInfo.cartoonMouthType = playerChar:GetCartoonFaceComponent(4, 0);
			CCS_db.CurrentCharacterInfo.cartoonMouthColor = playerChar:GetCartoonFaceComponent(4, 1);
			CCS_db.CurrentCharacterInfo.cartoonMouthScale = playerChar:GetCartoonFaceComponent(4, 2);
			CCS_db.CurrentCharacterInfo.cartoonMouthRotation = playerChar:GetCartoonFaceComponent(4, 3);
			CCS_db.CurrentCharacterInfo.cartoonMouthX = playerChar:GetCartoonFaceComponent(4, 4);
			CCS_db.CurrentCharacterInfo.cartoonMouthY = playerChar:GetCartoonFaceComponent(4, 5);
			
			CCS_db.CurrentCharacterInfo.cartoonNoseType = playerChar:GetCartoonFaceComponent(5, 0);
			CCS_db.CurrentCharacterInfo.cartoonNoseColor = playerChar:GetCartoonFaceComponent(5, 1);
			CCS_db.CurrentCharacterInfo.cartoonNoseScale = playerChar:GetCartoonFaceComponent(5, 2);
			CCS_db.CurrentCharacterInfo.cartoonNoseRotation = playerChar:GetCartoonFaceComponent(5, 3);
			CCS_db.CurrentCharacterInfo.cartoonNoseX = playerChar:GetCartoonFaceComponent(5, 4);
			CCS_db.CurrentCharacterInfo.cartoonNoseY = playerChar:GetCartoonFaceComponent(5, 5);
			
			CCS_db.CurrentCharacterInfo.cartoonMarksType = playerChar:GetCartoonFaceComponent(6, 0);
			CCS_db.CurrentCharacterInfo.cartoonMarksColor = playerChar:GetCartoonFaceComponent(6, 1);
			CCS_db.CurrentCharacterInfo.cartoonMarksScale = playerChar:GetCartoonFaceComponent(6, 2);
			CCS_db.CurrentCharacterInfo.cartoonMarksRotation = playerChar:GetCartoonFaceComponent(6, 3);
			CCS_db.CurrentCharacterInfo.cartoonMarksX = playerChar:GetCartoonFaceComponent(6, 4);
			CCS_db.CurrentCharacterInfo.cartoonMarksY = playerChar:GetCartoonFaceComponent(6, 5);
			
			CCS_db.CurrentCharacterInfo.IsSupportCartoonFace = true;
		else
			CCS_db.CurrentCharacterInfo.IsSupportCartoonFace = false;
		end
	end
end



function CCS_db.LoadCurrentCharacterCCSInfo()

	local player, playerChar = CCS_db.GetPlayerChar();
	
	if(player ~= nil and player:IsValid()==true) then
		if(CCS_db.CurrentCharacterInfo.IsCustomModel == true) then
			
			g = CCS_db.CurrentCharacterInfo.gender;
			r = CCS_db.CurrentCharacterInfo.raceId;
			if(g == 0 and r == 1) then
				CCS_UI_Predefined.ResetBaseModel("character/v3/Human/", "Male");
			elseif(g == 0 and r == 2) then
				CCS_UI_Predefined.ResetBaseModel("character/v3/Child/", "Male");
			elseif(g == 1 and r == 1) then
				CCS_UI_Predefined.ResetBaseModel("character/v3/Human/", "Female");
			elseif(g == 1 and r == 2) then
				CCS_UI_Predefined.ResetBaseModel("character/v3/Child/", "Female");
			end
			
			if(player:IsCharacter()==true and playerChar:IsCustomModel()==true) then
			
				playerChar:SetBodyParams(CCS_db.CurrentCharacterInfo.skinColor, -1, -1, -1, -1);
				playerChar:SetBodyParams(-1, CCS_db.CurrentCharacterInfo.faceType, -1, -1, -1);
				playerChar:SetBodyParams(-1, -1, CCS_db.CurrentCharacterInfo.hairColor, -1, -1);
				playerChar:SetBodyParams(-1, -1, -1, CCS_db.CurrentCharacterInfo.hairStyle, -1);
				playerChar:SetBodyParams(-1, -1, -1, -1, CCS_db.CurrentCharacterInfo.facialHair);
				
				playerChar:SetCharacterSlot(0, CCS_db.CurrentCharacterInfo.itemHead);
				playerChar:SetCharacterSlot(1, CCS_db.CurrentCharacterInfo.itemNeck);
				playerChar:SetCharacterSlot(2, CCS_db.CurrentCharacterInfo.itemShoulder);
				playerChar:SetCharacterSlot(3, CCS_db.CurrentCharacterInfo.itemBoots);
				playerChar:SetCharacterSlot(4, CCS_db.CurrentCharacterInfo.itemBelt);
				playerChar:SetCharacterSlot(5, CCS_db.CurrentCharacterInfo.itemShirt);
				playerChar:SetCharacterSlot(6, CCS_db.CurrentCharacterInfo.itemPants);
				playerChar:SetCharacterSlot(7, CCS_db.CurrentCharacterInfo.itemChest);
				playerChar:SetCharacterSlot(8, CCS_db.CurrentCharacterInfo.itemBracers);
				playerChar:SetCharacterSlot(9, CCS_db.CurrentCharacterInfo.itemGloves);
				playerChar:SetCharacterSlot(10, CCS_db.CurrentCharacterInfo.itemHandRight);
				playerChar:SetCharacterSlot(11, CCS_db.CurrentCharacterInfo.itemHandLeft);
				playerChar:SetCharacterSlot(12, CCS_db.CurrentCharacterInfo.itemCape);
				playerChar:SetCharacterSlot(13, CCS_db.CurrentCharacterInfo.itemTabard);
			end
			
			if(CCS_db.CurrentCharacterInfo.IsSupportCartoonFace == true) then
				
				if(player:IsCharacter()==true and playerChar:IsSupportCartoonFace()==true) then
					
					playerChar:SetCartoonFaceComponent(0, 0, CCS_db.CurrentCharacterInfo.cartoonFaceType);
					playerChar:SetCartoonFaceComponent(0, 1, CCS_db.CurrentCharacterInfo.cartoonFaceColor);
					playerChar:SetCartoonFaceComponent(0, 2, CCS_db.CurrentCharacterInfo.cartoonFaceScale);
					playerChar:SetCartoonFaceComponent(0, 3, CCS_db.CurrentCharacterInfo.cartoonFaceRotation);
					playerChar:SetCartoonFaceComponent(0, 4, CCS_db.CurrentCharacterInfo.cartoonFaceX);
					playerChar:SetCartoonFaceComponent(0, 5, CCS_db.CurrentCharacterInfo.cartoonFaceY);
					
					playerChar:SetCartoonFaceComponent(1, 0, CCS_db.CurrentCharacterInfo.cartoonWrinkleType);
					playerChar:SetCartoonFaceComponent(1, 1, CCS_db.CurrentCharacterInfo.cartoonWrinkleColor);
					playerChar:SetCartoonFaceComponent(1, 2, CCS_db.CurrentCharacterInfo.cartoonWrinkleScale);
					playerChar:SetCartoonFaceComponent(1, 3, CCS_db.CurrentCharacterInfo.cartoonWrinkleRotation);
					playerChar:SetCartoonFaceComponent(1, 4, CCS_db.CurrentCharacterInfo.cartoonWrinkleX);
					playerChar:SetCartoonFaceComponent(1, 5, CCS_db.CurrentCharacterInfo.cartoonWrinkleY);
					
					playerChar:SetCartoonFaceComponent(2, 0, CCS_db.CurrentCharacterInfo.cartoonEyeType);
					playerChar:SetCartoonFaceComponent(2, 1, CCS_db.CurrentCharacterInfo.cartoonEyeColor);
					playerChar:SetCartoonFaceComponent(2, 2, CCS_db.CurrentCharacterInfo.cartoonEyeScale);
					playerChar:SetCartoonFaceComponent(2, 3, CCS_db.CurrentCharacterInfo.cartoonEyeRotation);
					playerChar:SetCartoonFaceComponent(2, 4, CCS_db.CurrentCharacterInfo.cartoonEyeX);
					playerChar:SetCartoonFaceComponent(2, 5, CCS_db.CurrentCharacterInfo.cartoonEyeY);
					
					playerChar:SetCartoonFaceComponent(3, 0, CCS_db.CurrentCharacterInfo.cartoonEyebrowType);
					playerChar:SetCartoonFaceComponent(3, 1, CCS_db.CurrentCharacterInfo.cartoonEyebrowColor);
					playerChar:SetCartoonFaceComponent(3, 2, CCS_db.CurrentCharacterInfo.cartoonEyebrowScale);
					playerChar:SetCartoonFaceComponent(3, 3, CCS_db.CurrentCharacterInfo.cartoonEyebrowRotation);
					playerChar:SetCartoonFaceComponent(3, 4, CCS_db.CurrentCharacterInfo.cartoonEyebrowX);
					playerChar:SetCartoonFaceComponent(3, 5, CCS_db.CurrentCharacterInfo.cartoonEyebrowY);
					
					playerChar:SetCartoonFaceComponent(4, 0, CCS_db.CurrentCharacterInfo.cartoonMouthType);
					playerChar:SetCartoonFaceComponent(4, 1, CCS_db.CurrentCharacterInfo.cartoonMouthColor);
					playerChar:SetCartoonFaceComponent(4, 2, CCS_db.CurrentCharacterInfo.cartoonMouthScale);
					playerChar:SetCartoonFaceComponent(4, 3, CCS_db.CurrentCharacterInfo.cartoonMouthRotation);
					playerChar:SetCartoonFaceComponent(4, 4, CCS_db.CurrentCharacterInfo.cartoonMouthX);
					playerChar:SetCartoonFaceComponent(4, 5, CCS_db.CurrentCharacterInfo.cartoonMouthY);
					
					playerChar:SetCartoonFaceComponent(5, 0, CCS_db.CurrentCharacterInfo.cartoonNoseType);
					playerChar:SetCartoonFaceComponent(5, 1, CCS_db.CurrentCharacterInfo.cartoonNoseColor);
					playerChar:SetCartoonFaceComponent(5, 2, CCS_db.CurrentCharacterInfo.cartoonNoseScale);
					playerChar:SetCartoonFaceComponent(5, 3, CCS_db.CurrentCharacterInfo.cartoonNoseRotation);
					playerChar:SetCartoonFaceComponent(5, 4, CCS_db.CurrentCharacterInfo.cartoonNoseX);
					playerChar:SetCartoonFaceComponent(5, 5, CCS_db.CurrentCharacterInfo.cartoonNoseY);
					
					playerChar:SetCartoonFaceComponent(6, 0, CCS_db.CurrentCharacterInfo.cartoonMarksType);
					playerChar:SetCartoonFaceComponent(6, 1, CCS_db.CurrentCharacterInfo.cartoonMarksColor);
					playerChar:SetCartoonFaceComponent(6, 2, CCS_db.CurrentCharacterInfo.cartoonMarksScale);
					playerChar:SetCartoonFaceComponent(6, 3, CCS_db.CurrentCharacterInfo.cartoonMarksRotation);
					playerChar:SetCartoonFaceComponent(6, 4, CCS_db.CurrentCharacterInfo.cartoonMarksX);
					playerChar:SetCartoonFaceComponent(6, 5, CCS_db.CurrentCharacterInfo.cartoonMarksY);
					
				end
			else
				-- do nothing
			end

			
		else
			--modelname;
		end
	end

end

function CCS_db.LoadIdentityCurrentCharacterInfo()
	CCS_db.CurrentCharacterInfo.cartoonWrinkleType = 0;
	CCS_db.CurrentCharacterInfo.cartoonEyeColor = 0;
	CCS_db.CurrentCharacterInfo.cartoonNoseRotation = 0;
	CCS_db.CurrentCharacterInfo.cartoonFaceColor = 0;
	CCS_db.CurrentCharacterInfo.itemTabard = 0;
	CCS_db.CurrentCharacterInfo.cartoonMarksScale = 0;
	CCS_db.CurrentCharacterInfo.itemChest = 0;
	CCS_db.CurrentCharacterInfo.gender = 0;
	CCS_db.CurrentCharacterInfo.cartoonMarksRotation = 0;
	CCS_db.CurrentCharacterInfo.cartoonEyebrowY = 0;
	CCS_db.CurrentCharacterInfo.faceType = 0;
	CCS_db.CurrentCharacterInfo.cartoonNoseScale = 0;
	CCS_db.CurrentCharacterInfo.cartoonFaceX = 0;
	CCS_db.CurrentCharacterInfo.cartoonNoseColor = 0;
	CCS_db.CurrentCharacterInfo.cartoonEyeType = 0;
	CCS_db.CurrentCharacterInfo.cartoonEyebrowColor = 0;
	CCS_db.CurrentCharacterInfo.cartoonEyeX = 0;
	CCS_db.CurrentCharacterInfo.itemBelt = 0;
	CCS_db.CurrentCharacterInfo.cartoonWrinkleX = 0;
	CCS_db.CurrentCharacterInfo.cartoonFaceY = 0;
	CCS_db.CurrentCharacterInfo.hairColor = 0;
	CCS_db.CurrentCharacterInfo.cartoonWrinkleY = 0;
	CCS_db.CurrentCharacterInfo.cartoonEyeRotation = 0;
	CCS_db.CurrentCharacterInfo.itemShoulder = 0;
	CCS_db.CurrentCharacterInfo.cartoonFaceType = 0;
	CCS_db.CurrentCharacterInfo.itemNeck = 0;
	CCS_db.CurrentCharacterInfo.itemHandLeft = 0;
	CCS_db.CurrentCharacterInfo.cartoonMouthY = 0;
	CCS_db.CurrentCharacterInfo.cartoonMarksType = 0;
	CCS_db.CurrentCharacterInfo.skinColor = 0;
	CCS_db.CurrentCharacterInfo.itemHead = 0;
	CCS_db.CurrentCharacterInfo.itemShirt = 0;
	CCS_db.CurrentCharacterInfo.hairStyle = 0;
	CCS_db.CurrentCharacterInfo.cartoonMouthScale = 0;
	CCS_db.CurrentCharacterInfo.cartoonFaceRotation = 0;
	CCS_db.CurrentCharacterInfo.cartoonMarksX = 0;
	CCS_db.CurrentCharacterInfo.cartoonEyeY = 0;
	CCS_db.CurrentCharacterInfo.itemCape = 0;
	CCS_db.CurrentCharacterInfo.itemPants = 0;
	CCS_db.CurrentCharacterInfo.itemHandRight = 0;
	CCS_db.CurrentCharacterInfo.itemBoots = 0;
	CCS_db.CurrentCharacterInfo.cartoonWrinkleColor = 0;
	CCS_db.CurrentCharacterInfo.cartoonEyeScale = 0;
	CCS_db.CurrentCharacterInfo.cartoonEyebrowRotation = 0;
	CCS_db.CurrentCharacterInfo.cartoonMarksY = 0;
	CCS_db.CurrentCharacterInfo.cartoonNoseY = 0;
	CCS_db.CurrentCharacterInfo.cartoonMarksColor = 0;
	CCS_db.CurrentCharacterInfo.itemGloves = 0;
	CCS_db.CurrentCharacterInfo.cartoonNoseX = 0;
	CCS_db.CurrentCharacterInfo.cartoonWrinkleScale = 0;
	CCS_db.CurrentCharacterInfo.cartoonEyebrowScale = 0;
	CCS_db.CurrentCharacterInfo.cartoonNoseType = 0;
	CCS_db.CurrentCharacterInfo.ModelName = "Default";
	CCS_db.CurrentCharacterInfo.facialHair = 0;
	CCS_db.CurrentCharacterInfo.raceId = 0;
	CCS_db.CurrentCharacterInfo.IsSupportCartoonFace = false;
	CCS_db.CurrentCharacterInfo.cartoonMouthX = 0;
	CCS_db.CurrentCharacterInfo.cartoonMouthType = 0;
	CCS_db.CurrentCharacterInfo.cartoonMouthRotation = 0;
	CCS_db.CurrentCharacterInfo.cartoonMouthColor = 0;
	CCS_db.CurrentCharacterInfo.cartoonEyebrowX = 0;
	CCS_db.CurrentCharacterInfo.cartoonEyebrowType = 0;
	CCS_db.CurrentCharacterInfo.cartoonFaceScale = 0;
	CCS_db.CurrentCharacterInfo.itemBracers = 0;
	CCS_db.CurrentCharacterInfo.cartoonWrinkleRotation = 0;
	CCS_db.CurrentCharacterInfo.IsCustomModel = false;
end

function CCS_db.SaveCharacterCCSInfo(name)

	CCS_db.LoadIdentityCurrentCharacterInfo();

	local player = ParaScene.GetObject(name);
	
	if(player == nil or player:IsValid() == false or player:IsCharacter() == false) then
		return;
	end
	
	local playerChar = player:ToCharacter();
	
	if( playerChar:IsCustomModel()==true ) then
		CCS_db.CurrentCharacterInfo.skinColor = playerChar:GetBodyParams(0);
		CCS_db.CurrentCharacterInfo.faceType = playerChar:GetBodyParams(1);
		CCS_db.CurrentCharacterInfo.hairColor = playerChar:GetBodyParams(2);
		CCS_db.CurrentCharacterInfo.hairStyle = playerChar:GetBodyParams(3);
		CCS_db.CurrentCharacterInfo.facialHair = playerChar:GetBodyParams(4);
		
		CCS_db.CurrentCharacterInfo.itemHead = playerChar:GetCharacterSlotItemID(0);
		CCS_db.CurrentCharacterInfo.itemNeck = playerChar:GetCharacterSlotItemID(1);
		CCS_db.CurrentCharacterInfo.itemShoulder = playerChar:GetCharacterSlotItemID(2);
		CCS_db.CurrentCharacterInfo.itemBoots = playerChar:GetCharacterSlotItemID(3);
		CCS_db.CurrentCharacterInfo.itemBelt = playerChar:GetCharacterSlotItemID(4);
		CCS_db.CurrentCharacterInfo.itemShirt = playerChar:GetCharacterSlotItemID(5);
		CCS_db.CurrentCharacterInfo.itemPants = playerChar:GetCharacterSlotItemID(6);
		CCS_db.CurrentCharacterInfo.itemChest = playerChar:GetCharacterSlotItemID(7);
		CCS_db.CurrentCharacterInfo.itemBracers = playerChar:GetCharacterSlotItemID(8);
		CCS_db.CurrentCharacterInfo.itemGloves = playerChar:GetCharacterSlotItemID(9);
		CCS_db.CurrentCharacterInfo.itemHandRight = playerChar:GetCharacterSlotItemID(10);
		CCS_db.CurrentCharacterInfo.itemHandLeft = playerChar:GetCharacterSlotItemID(11);
		CCS_db.CurrentCharacterInfo.itemCape = playerChar:GetCharacterSlotItemID(12);
		CCS_db.CurrentCharacterInfo.itemTabard = playerChar:GetCharacterSlotItemID(13);
		
		-- TODO: race and gender
		CCS_db.CurrentCharacterInfo.gender = playerChar:GetGender();
		CCS_db.CurrentCharacterInfo.raceId = playerChar:GetRaceID();
		
		CCS_db.CurrentCharacterInfo.IsCustomModel = true;
	else
		CCS_db.CurrentCharacterInfo.IsCustomModel = false;
		
		local name = player:GetPrimaryAsset():GetKeyName();
		if( name == Map3DSystem.UI.MainMenu.DefaultAsset) then
			CCS_db.CurrentCharacterInfo.ModelName = "Default";
		else
			CCS_db.CurrentCharacterInfo.ModelName = name;
		end
	end
		
	if(player:IsCharacter()==true and playerChar:IsSupportCartoonFace()==true) then
		CCS_db.CurrentCharacterInfo.cartoonFaceType = playerChar:GetCartoonFaceComponent(0, 0);
		CCS_db.CurrentCharacterInfo.cartoonFaceColor = playerChar:GetCartoonFaceComponent(0, 1);
		CCS_db.CurrentCharacterInfo.cartoonFaceScale = playerChar:GetCartoonFaceComponent(0, 2);
		CCS_db.CurrentCharacterInfo.cartoonFaceRotation = playerChar:GetCartoonFaceComponent(0, 3);
		CCS_db.CurrentCharacterInfo.cartoonFaceX = playerChar:GetCartoonFaceComponent(0, 4);
		CCS_db.CurrentCharacterInfo.cartoonFaceY = playerChar:GetCartoonFaceComponent(0, 5);
		
		CCS_db.CurrentCharacterInfo.cartoonWrinkleType = playerChar:GetCartoonFaceComponent(1, 0);
		CCS_db.CurrentCharacterInfo.cartoonWrinkleColor = playerChar:GetCartoonFaceComponent(1, 1);
		CCS_db.CurrentCharacterInfo.cartoonWrinkleScale = playerChar:GetCartoonFaceComponent(1, 2);
		CCS_db.CurrentCharacterInfo.cartoonWrinkleRotation = playerChar:GetCartoonFaceComponent(1, 3);
		CCS_db.CurrentCharacterInfo.cartoonWrinkleX = playerChar:GetCartoonFaceComponent(1, 4);
		CCS_db.CurrentCharacterInfo.cartoonWrinkleY = playerChar:GetCartoonFaceComponent(1, 5);
		
		CCS_db.CurrentCharacterInfo.cartoonEyeType = playerChar:GetCartoonFaceComponent(2, 0);
		CCS_db.CurrentCharacterInfo.cartoonEyeColor = playerChar:GetCartoonFaceComponent(2, 1);
		CCS_db.CurrentCharacterInfo.cartoonEyeScale = playerChar:GetCartoonFaceComponent(2, 2);
		CCS_db.CurrentCharacterInfo.cartoonEyeRotation = playerChar:GetCartoonFaceComponent(2, 3);
		CCS_db.CurrentCharacterInfo.cartoonEyeX = playerChar:GetCartoonFaceComponent(2, 4);
		CCS_db.CurrentCharacterInfo.cartoonEyeY = playerChar:GetCartoonFaceComponent(2, 5);
		
		CCS_db.CurrentCharacterInfo.cartoonEyebrowType = playerChar:GetCartoonFaceComponent(3, 0);
		CCS_db.CurrentCharacterInfo.cartoonEyebrowColor = playerChar:GetCartoonFaceComponent(3, 1);
		CCS_db.CurrentCharacterInfo.cartoonEyebrowScale = playerChar:GetCartoonFaceComponent(3, 2);
		CCS_db.CurrentCharacterInfo.cartoonEyebrowRotation = playerChar:GetCartoonFaceComponent(3, 3);
		CCS_db.CurrentCharacterInfo.cartoonEyebrowX = playerChar:GetCartoonFaceComponent(3, 4);
		CCS_db.CurrentCharacterInfo.cartoonEyebrowY = playerChar:GetCartoonFaceComponent(3, 5);
		
		CCS_db.CurrentCharacterInfo.cartoonMouthType = playerChar:GetCartoonFaceComponent(4, 0);
		CCS_db.CurrentCharacterInfo.cartoonMouthColor = playerChar:GetCartoonFaceComponent(4, 1);
		CCS_db.CurrentCharacterInfo.cartoonMouthScale = playerChar:GetCartoonFaceComponent(4, 2);
		CCS_db.CurrentCharacterInfo.cartoonMouthRotation = playerChar:GetCartoonFaceComponent(4, 3);
		CCS_db.CurrentCharacterInfo.cartoonMouthX = playerChar:GetCartoonFaceComponent(4, 4);
		CCS_db.CurrentCharacterInfo.cartoonMouthY = playerChar:GetCartoonFaceComponent(4, 5);
		
		CCS_db.CurrentCharacterInfo.cartoonNoseType = playerChar:GetCartoonFaceComponent(5, 0);
		CCS_db.CurrentCharacterInfo.cartoonNoseColor = playerChar:GetCartoonFaceComponent(5, 1);
		CCS_db.CurrentCharacterInfo.cartoonNoseScale = playerChar:GetCartoonFaceComponent(5, 2);
		CCS_db.CurrentCharacterInfo.cartoonNoseRotation = playerChar:GetCartoonFaceComponent(5, 3);
		CCS_db.CurrentCharacterInfo.cartoonNoseX = playerChar:GetCartoonFaceComponent(5, 4);
		CCS_db.CurrentCharacterInfo.cartoonNoseY = playerChar:GetCartoonFaceComponent(5, 5);
		
		CCS_db.CurrentCharacterInfo.cartoonMarksType = playerChar:GetCartoonFaceComponent(6, 0);
		CCS_db.CurrentCharacterInfo.cartoonMarksColor = playerChar:GetCartoonFaceComponent(6, 1);
		CCS_db.CurrentCharacterInfo.cartoonMarksScale = playerChar:GetCartoonFaceComponent(6, 2);
		CCS_db.CurrentCharacterInfo.cartoonMarksRotation = playerChar:GetCartoonFaceComponent(6, 3);
		CCS_db.CurrentCharacterInfo.cartoonMarksX = playerChar:GetCartoonFaceComponent(6, 4);
		CCS_db.CurrentCharacterInfo.cartoonMarksY = playerChar:GetCartoonFaceComponent(6, 5);
		
		CCS_db.CurrentCharacterInfo.IsSupportCartoonFace = true;
	else
		CCS_db.CurrentCharacterInfo.IsSupportCartoonFace = false;
	end
end


function CCS_db.LoadCharacterCCSInfo(name)

	local player = ParaScene.GetObject(name);
	
	if(player == nil or player:IsValid() == false or player:IsCharacter() == false) then
		return;
	end
	
	local playerChar = player:ToCharacter();
	
	if(CCS_db.CurrentCharacterInfo.IsCustomModel == true) then
		
		g = CCS_db.CurrentCharacterInfo.gender;
		r = CCS_db.CurrentCharacterInfo.raceId;
		if(g == 0 and r == 1) then
			CCS_UI_Predefined.ResetBaseModel2(name, "character/v3/Human/", "Male");
		elseif(g == 0 and r == 2) then
			CCS_UI_Predefined.ResetBaseModel2(name, "character/v3/Child/", "Male");
		elseif(g == 1 and r == 1) then
			CCS_UI_Predefined.ResetBaseModel2(name, "character/v3/Human/", "Female");
		elseif(g == 1 and r == 2) then
			CCS_UI_Predefined.ResetBaseModel2(name, "character/v3/Child/", "Female");
		end
		
		if(player:IsCharacter()==true and playerChar:IsCustomModel()==true) then
		
			playerChar:SetBodyParams(CCS_db.CurrentCharacterInfo.skinColor, -1, -1, -1, -1);
			playerChar:SetBodyParams(-1, CCS_db.CurrentCharacterInfo.faceType, -1, -1, -1);
			playerChar:SetBodyParams(-1, -1, CCS_db.CurrentCharacterInfo.hairColor, -1, -1);
			playerChar:SetBodyParams(-1, -1, -1, CCS_db.CurrentCharacterInfo.hairStyle, -1);
			playerChar:SetBodyParams(-1, -1, -1, -1, CCS_db.CurrentCharacterInfo.facialHair);
			
			playerChar:SetCharacterSlot(0, CCS_db.CurrentCharacterInfo.itemHead);
			playerChar:SetCharacterSlot(1, CCS_db.CurrentCharacterInfo.itemNeck);
			playerChar:SetCharacterSlot(2, CCS_db.CurrentCharacterInfo.itemShoulder);
			playerChar:SetCharacterSlot(3, CCS_db.CurrentCharacterInfo.itemBoots);
			playerChar:SetCharacterSlot(4, CCS_db.CurrentCharacterInfo.itemBelt);
			playerChar:SetCharacterSlot(5, CCS_db.CurrentCharacterInfo.itemShirt);
			playerChar:SetCharacterSlot(6, CCS_db.CurrentCharacterInfo.itemPants);
			playerChar:SetCharacterSlot(7, CCS_db.CurrentCharacterInfo.itemChest);
			playerChar:SetCharacterSlot(8, CCS_db.CurrentCharacterInfo.itemBracers);
			playerChar:SetCharacterSlot(9, CCS_db.CurrentCharacterInfo.itemGloves);
			playerChar:SetCharacterSlot(10, CCS_db.CurrentCharacterInfo.itemHandRight);
			playerChar:SetCharacterSlot(11, CCS_db.CurrentCharacterInfo.itemHandLeft);
			playerChar:SetCharacterSlot(12, CCS_db.CurrentCharacterInfo.itemCape);
			playerChar:SetCharacterSlot(13, CCS_db.CurrentCharacterInfo.itemTabard);
		end
		
		if(CCS_db.CurrentCharacterInfo.IsSupportCartoonFace == true) then
			
			if(player:IsCharacter()==true and playerChar:IsSupportCartoonFace()==true) then
				
				playerChar:SetCartoonFaceComponent(0, 0, CCS_db.CurrentCharacterInfo.cartoonFaceType);
				playerChar:SetCartoonFaceComponent(0, 1, CCS_db.CurrentCharacterInfo.cartoonFaceColor);
				playerChar:SetCartoonFaceComponent(0, 2, CCS_db.CurrentCharacterInfo.cartoonFaceScale);
				playerChar:SetCartoonFaceComponent(0, 3, CCS_db.CurrentCharacterInfo.cartoonFaceRotation);
				playerChar:SetCartoonFaceComponent(0, 4, CCS_db.CurrentCharacterInfo.cartoonFaceX);
				playerChar:SetCartoonFaceComponent(0, 5, CCS_db.CurrentCharacterInfo.cartoonFaceY);
				
				playerChar:SetCartoonFaceComponent(1, 0, CCS_db.CurrentCharacterInfo.cartoonWrinkleType);
				playerChar:SetCartoonFaceComponent(1, 1, CCS_db.CurrentCharacterInfo.cartoonWrinkleColor);
				playerChar:SetCartoonFaceComponent(1, 2, CCS_db.CurrentCharacterInfo.cartoonWrinkleScale);
				playerChar:SetCartoonFaceComponent(1, 3, CCS_db.CurrentCharacterInfo.cartoonWrinkleRotation);
				playerChar:SetCartoonFaceComponent(1, 4, CCS_db.CurrentCharacterInfo.cartoonWrinkleX);
				playerChar:SetCartoonFaceComponent(1, 5, CCS_db.CurrentCharacterInfo.cartoonWrinkleY);
				
				playerChar:SetCartoonFaceComponent(2, 0, CCS_db.CurrentCharacterInfo.cartoonEyeType);
				playerChar:SetCartoonFaceComponent(2, 1, CCS_db.CurrentCharacterInfo.cartoonEyeColor);
				playerChar:SetCartoonFaceComponent(2, 2, CCS_db.CurrentCharacterInfo.cartoonEyeScale);
				playerChar:SetCartoonFaceComponent(2, 3, CCS_db.CurrentCharacterInfo.cartoonEyeRotation);
				playerChar:SetCartoonFaceComponent(2, 4, CCS_db.CurrentCharacterInfo.cartoonEyeX);
				playerChar:SetCartoonFaceComponent(2, 5, CCS_db.CurrentCharacterInfo.cartoonEyeY);
				
				playerChar:SetCartoonFaceComponent(3, 0, CCS_db.CurrentCharacterInfo.cartoonEyebrowType);
				playerChar:SetCartoonFaceComponent(3, 1, CCS_db.CurrentCharacterInfo.cartoonEyebrowColor);
				playerChar:SetCartoonFaceComponent(3, 2, CCS_db.CurrentCharacterInfo.cartoonEyebrowScale);
				playerChar:SetCartoonFaceComponent(3, 3, CCS_db.CurrentCharacterInfo.cartoonEyebrowRotation);
				playerChar:SetCartoonFaceComponent(3, 4, CCS_db.CurrentCharacterInfo.cartoonEyebrowX);
				playerChar:SetCartoonFaceComponent(3, 5, CCS_db.CurrentCharacterInfo.cartoonEyebrowY);
				
				playerChar:SetCartoonFaceComponent(4, 0, CCS_db.CurrentCharacterInfo.cartoonMouthType);
				playerChar:SetCartoonFaceComponent(4, 1, CCS_db.CurrentCharacterInfo.cartoonMouthColor);
				playerChar:SetCartoonFaceComponent(4, 2, CCS_db.CurrentCharacterInfo.cartoonMouthScale);
				playerChar:SetCartoonFaceComponent(4, 3, CCS_db.CurrentCharacterInfo.cartoonMouthRotation);
				playerChar:SetCartoonFaceComponent(4, 4, CCS_db.CurrentCharacterInfo.cartoonMouthX);
				playerChar:SetCartoonFaceComponent(4, 5, CCS_db.CurrentCharacterInfo.cartoonMouthY);
				
				playerChar:SetCartoonFaceComponent(5, 0, CCS_db.CurrentCharacterInfo.cartoonNoseType);
				playerChar:SetCartoonFaceComponent(5, 1, CCS_db.CurrentCharacterInfo.cartoonNoseColor);
				playerChar:SetCartoonFaceComponent(5, 2, CCS_db.CurrentCharacterInfo.cartoonNoseScale);
				playerChar:SetCartoonFaceComponent(5, 3, CCS_db.CurrentCharacterInfo.cartoonNoseRotation);
				playerChar:SetCartoonFaceComponent(5, 4, CCS_db.CurrentCharacterInfo.cartoonNoseX);
				playerChar:SetCartoonFaceComponent(5, 5, CCS_db.CurrentCharacterInfo.cartoonNoseY);
				
				playerChar:SetCartoonFaceComponent(6, 0, CCS_db.CurrentCharacterInfo.cartoonMarksType);
				playerChar:SetCartoonFaceComponent(6, 1, CCS_db.CurrentCharacterInfo.cartoonMarksColor);
				playerChar:SetCartoonFaceComponent(6, 2, CCS_db.CurrentCharacterInfo.cartoonMarksScale);
				playerChar:SetCartoonFaceComponent(6, 3, CCS_db.CurrentCharacterInfo.cartoonMarksRotation);
				playerChar:SetCartoonFaceComponent(6, 4, CCS_db.CurrentCharacterInfo.cartoonMarksX);
				playerChar:SetCartoonFaceComponent(6, 5, CCS_db.CurrentCharacterInfo.cartoonMarksY);
				
			end
		else
			-- do nothing
		end

		
	else
		local assetNew;
		if(CCS_db.CurrentCharacterInfo.ModelName == "Default") then
			assetNew = ParaAsset.LoadParaX("", Map3DSystem.UI.MainMenu.DefaultAsset);
		else
			assetNew = ParaAsset.LoadParaX("", CCS_db.CurrentCharacterInfo.ModelName);
		end
	
		if(assetNew:IsValid() == true) then
			playerChar:ResetBaseModel(assetNew);
		end
	end
end