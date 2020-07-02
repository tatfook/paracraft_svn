--[[
Title: advanced CCS modification page
Author(s): WangTian
Date: 2009/5/5
Desc: script/kids/3DMapSystemUI/CCS/AdvCCSModifyTeenPage.html
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/AdvCCSModifyTeenPage.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");


-- create class
local AdvCCSModifyTeenPage = {};
commonlib.setfield("Map3DSystem.App.CCS.AdvCCSModifyTeenPage", AdvCCSModifyTeenPage);

-- on init show the current avatar in pe:avatar
function AdvCCSModifyTeenPage.OnInit()
	local self = document:GetPageCtrl();
	if(not self) then 
		log("warning: page control not found\n")
		return 
	end
	local player = ParaScene.GetPlayer();
	local playerChar = player:ToCharacter();
	-- set to cartoon face
	playerChar:SetBodyParams(-1, -1, -1, -1, 1);
	
	--NPL.load("(gl)script/sqlite/sqlite3.lua");
	--local _dbfile = "database/characters.db";
	--local db = sqlite3.open(_dbfile);
	--if(db == nil) then
		--log("error: open database file: ".._dbfile.."\n");
		--return;
	--end
	--AdvCCSModifyTeenPage._db = db;

	-- set to the teen character path setting
	ParaScene.SetCharacterRegionPath(32, "character/v6/Item/Head/");
	ParaScene.SetCharacterRegionPath(34, "character/v6/Item/Weapon/");
	ParaScene.SetCharacterRegionPath(19, "character/v6/Item/ShirtTexture/");
	ParaScene.SetCharacterRegionPath(20, "character/v6/Item/ShirtTexture/");
	ParaScene.SetCharacterRegionPath(23, "character/v6/Item/FootTexture/");
	ParaScene.SetCharacterRegionPath(38, "character/v6/Item/WingTexture/");
	ParaScene.SetCharacterRegionPath(39, "character/v6/Item/Back/");
	
	local CharTexSize = 512; -- the recommended size is 256, however 512 is the original size of component textures, 2007.7.7 by LiXizhi
	local FaceTexSize = 256; 
	local offset_scaling = FaceTexSize/256;
	local regions = {
		--
		-- character face regions: left, top, width, height
		--
		{0, 0, CharTexSize, CharTexSize},	-- base
		{0, 0, CharTexSize/2, CharTexSize/4},	-- arm upper
		{0, CharTexSize/4, CharTexSize/2, CharTexSize/4},	-- arm lower
		{0, CharTexSize/2, CharTexSize/2, CharTexSize/8},	-- hand
		{0, CharTexSize/8*5, CharTexSize/2, CharTexSize/8},	-- face upper
		{0, CharTexSize/8*6, CharTexSize/2, CharTexSize/4},	-- face lower
		{CharTexSize/2, 0, CharTexSize/2, CharTexSize/4},	-- torso upper
		{CharTexSize/2, CharTexSize/4, CharTexSize/2, CharTexSize/8},	-- torso lower
		{CharTexSize/2, CharTexSize/8*3, CharTexSize/2, CharTexSize/4}, -- leg upper
		{CharTexSize/2, CharTexSize/8*5, CharTexSize/2, CharTexSize/4},-- leg lower
		{CharTexSize/2, CharTexSize/8*7, CharTexSize/2, CharTexSize/8},	-- foot
		{0, CharTexSize/8*6, CharTexSize/2, CharTexSize/4},	-- wings

		--
		-- character face regions: center_x, center_y, default_width, default_height
		--
		{FaceTexSize/2, FaceTexSize/2, FaceTexSize, FaceTexSize},	-- face base
		{FaceTexSize/2, FaceTexSize/2, FaceTexSize, FaceTexSize},	-- wrinkle
		{FaceTexSize/2+30*offset_scaling, FaceTexSize/2, FaceTexSize/4, FaceTexSize/4},	-- eye right
		{FaceTexSize/2+33*offset_scaling, FaceTexSize/2-20*offset_scaling, FaceTexSize/4, FaceTexSize/4},	-- eye bow right
		{FaceTexSize/2, FaceTexSize/2+41*offset_scaling, FaceTexSize/4, FaceTexSize/4},	-- mouth
		{FaceTexSize/2, FaceTexSize/2+12*offset_scaling, FaceTexSize/4, FaceTexSize/4},	-- nose
		{FaceTexSize/2, FaceTexSize/2, FaceTexSize, FaceTexSize},	-- mark

		--
		-- aries character skin regions: left, top, width, height
		--
		{0, 0, CharTexSize, CharTexSize/2}, -- CR_ARIES_CHAR_SHIRT,
		{0, CharTexSize/2, CharTexSize, CharTexSize/2}, -- CR_ARIES_CHAR_SHIRT_OVERLAYER
		{CharTexSize/2, CharTexSize/2, CharTexSize/2, CharTexSize/2}, -- CR_ARIES_CHAR_PANT,
		{0, CharTexSize/2, CharTexSize/2, CharTexSize/8},	-- CR_ARIES_CHAR_HAND
		{0, CharTexSize/8*6, CharTexSize/2, CharTexSize/4},	-- CR_ARIES_CHAR_FOOT
		{0, CharTexSize/8*4, CharTexSize/2, CharTexSize/4}, -- CR_ARIES_CHAR_GLASS

		--
		-- aries pet skin regions: left, top, width, height
		--
		{0, 0, CharTexSize/2, CharTexSize/2}, -- CR_ARIES_PET_HEAD,
		{CharTexSize/2, 0, CharTexSize/2, CharTexSize}, -- CR_ARIES_PET_BODY,
		{CharTexSize/2, CharTexSize/2, CharTexSize/2, CharTexSize/2}, -- CR_ARIES_PET_TAIL,
		{0, CharTexSize/2, CharTexSize/2, CharTexSize/2}, -- CR_ARIES_PET_WING,

		{0, 0, CharTexSize, CharTexSize}, -- CR_ARIES_CHAR_SHIRT_TEEN,
	};
	ParaScene.SetCharTextureSize(CharTexSize, FaceTexSize);

	local nRegionIndex, coords;
	for nRegionIndex, coords in ipairs(regions) do
		ParaScene.SetCharRegionCoordinates(nRegionIndex-1, coords[1], coords[2], coords[3], coords[4]);
	end
end

function AdvCCSModifyTeenPage.UpdateDragonSkin_Purple()
	AdvCCSModifyTeenPage.UpdateDragonSkin(1)
end

function AdvCCSModifyTeenPage.UpdateDragonSkin_Red()
	AdvCCSModifyTeenPage.UpdateDragonSkin(2)
end

function AdvCCSModifyTeenPage.UpdateDragonSkin_Green()
	AdvCCSModifyTeenPage.UpdateDragonSkin(3)
end

function AdvCCSModifyTeenPage.UpdateDragonSkin_Orange()
	AdvCCSModifyTeenPage.UpdateDragonSkin(4)
end

function AdvCCSModifyTeenPage.UpdateDragonSkin_DarkPurple()
	AdvCCSModifyTeenPage.UpdateDragonSkin(5)
end

function AdvCCSModifyTeenPage.UpdateDragonSkin_DarkRed()
	AdvCCSModifyTeenPage.UpdateDragonSkin(6)
end

function AdvCCSModifyTeenPage.UpdateDragonSkin(i)
	local replaceable_r1;
	local assetname = ParaScene.GetPlayer():GetPrimaryAsset():GetKeyName();
	if(string.find(assetname, "character/v3/PurpleDragonMajor/Female/")) then
		replaceable_r1 = "character/v3/PurpleDragonMajor/Female/SkinColor0"..i..".dds";
	end
	if(replaceable_r1) then
		ParaScene.GetPlayer():SetReplaceableTexture(1, ParaAsset.LoadTexture("", replaceable_r1, 1));
	end
end

function AdvCCSModifyTeenPage.OnChangeAsset()
	--local _obj = Map3DSystem.obj.GetObject(Map3DSystem.App.Creator.target);
	local _obj = ParaScene.GetPlayer();
	if(_obj ~= nil and _obj:IsValid())then
		local newasset = document:GetPageCtrl():GetUIValue("newasset");
		if(newasset) then
			local asset = ParaAsset.LoadParaX("", newasset);
			_obj:ToCharacter():ResetBaseModel(asset);
		end
	end	
end

function AdvCCSModifyTeenPage.ClickDBUpdate()
	_guihelper.MessageBox("确认更新数据库？\n\n请确认database/characters.db文件为只读，数据更新需要花些时间，请耐心等待\n", function ()
				Map3DSystem.UI.CCS.DB.AutoGenerateItems();
				_guihelper.CloseMessageBox();
			end);
end

function AdvCCSModifyTeenPage.ClickLeftHandUpdate(name, mcmlNode)
	if(mcmlNode) then
        local gsid = mcmlNode:GetNumber("gsid");
        if(gsid) then
			AdvCCSModifyTeenPage.HandUpdate(gsid, 0);
		end
	end
end

function AdvCCSModifyTeenPage.ClickRightHandUpdate(name, mcmlNode)
	if(mcmlNode) then
        local gsid = mcmlNode:GetNumber("gsid");
        if(gsid) then
			AdvCCSModifyTeenPage.HandUpdate(gsid, 1);
		end
	end
end

function AdvCCSModifyTeenPage.ClickHatUpdate(name, mcmlNode)
	if(mcmlNode) then
        local gsid = mcmlNode:GetNumber("gsid");
        if(gsid) then
			local playerChar = ParaScene.GetPlayer():ToCharacter();
			playerChar:SetCharacterSlot(0, 0);
		end
	end
end

function AdvCCSModifyTeenPage.ClickBackUpdate(name, mcmlNode)
	if(mcmlNode) then
        local gsid = mcmlNode:GetNumber("gsid");
        if(gsid) then
			local playerChar = ParaScene.GetPlayer():ToCharacter();
			playerChar:SetCharacterSlot(26, 0);
		end
	end
end

function AdvCCSModifyTeenPage.HandUpdate(gsid, hand)
	local playerChar = ParaScene.GetPlayer():ToCharacter();
	if(gsid and hand == 0) then
		playerChar:SetCharacterSlot(11, gsid);
	elseif(gsid and hand == 1) then
		playerChar:SetCharacterSlot(10, gsid);
	end
end

function AdvCCSModifyTeenPage.ClickAvaterUpdate(name, mcmlNode)
    if(mcmlNode) then
        local gsid = mcmlNode:GetNumber("gsid");
        local slot = mcmlNode:GetNumber("slot");
        if(gsid and slot) then
			local playerChar = ParaScene.GetPlayer():ToCharacter();
			
			playerChar:SetCharacterSlot(slot, gsid);
        end
		local playerChar = ParaScene.GetPlayer():ToCharacter();
		if(playerChar:GetCharacterSlotItemID(0) > 1) then -- IT_Head
			playerChar:SetBodyParams(-1, -1, 0, 0, -1); -- int hairColor, int hairStyle
		end
    end
end

function AdvCCSModifyTeenPage.DS_Func_Hairs(index)
	if(index ~= nil) then
		local style = math.floor((index-1)/7) + 1;
		local color = math.mod(index-1, 7) + 1;
		if(index > 56) then
			return;
		end
		local filename = "character/v3/Elf/Hair0"..style.."_0"..color..".dds";
		if(ParaIO.DoesFileExist(filename)==true) then
			return {img = filename, style = style, color = color, tooltip = filename};
		else
			return {img = "Texture/Taurus/Question.png", style = style, color = color, tooltip = filename};
		end
	elseif(index == nil) then
		return 56;
	end
end

function AdvCCSModifyTeenPage.TestHair(style, color)
	
	local player = ParaScene.GetPlayer();
	local playerChar = player:ToCharacter();
	playerChar:SetBodyParams(-1, -1, -1, style, -1);
	
	playerChar:SetBodyParams(-1, -1, color-1, -1, -1);
end

function AdvCCSModifyTeenPage.DS_Func_BaseSkins(index)
	if(index ~= nil) then
		if(index == 1) then
			return {img = "character/v3/Elf/Female/ElfFemaleSkin00_00.dds", color = index-1};
		elseif(index == 2) then
			return {img = "character/v3/Elf/Female/ElfFemaleSkin00_01.dds", color = index-1};
		elseif(index == 3) then
			return {img = "character/v3/Elf/Female/ElfFemaleSkin00_02.dds", color = index-1};
		elseif(index == 4) then
			return {img = "character/v3/Elf/Female/ElfFemaleSkin00_03.dds", color = index-1};
		elseif(index == 5) then
			return {img = "character/v3/Elf/Female/ElfFemaleSkin00_04.dds", color = index-1};
		elseif(index == 6) then
			return {img = "character/v3/Elf/Female/ElfFemaleSkin00_05.dds", color = index-1};
		elseif(index == 7) then
			return {img = "character/v3/Elf/Female/ElfFemaleSkin00_06.dds", color = index-1};
		elseif(index == 8) then
			return {img = "character/v3/Elf/Female/ElfFemaleSkin00_07.dds", color = index-1};
		elseif(index == 9) then
			return {img = "character/v3/Elf/Female/ElfFemaleSkin00_08.dds", color = index-1};
		elseif(index == 10) then
			return {img = "character/v3/Elf/Female/ElfFemaleSkin00_09.dds", color = index-1};
		elseif(index == 11) then
			return {img = "character/v3/Elf/Female/ElfFemaleSkin00_10.dds", color = index-1};
		end
	elseif(index == nil) then
		return 11;
	end
end

function AdvCCSModifyTeenPage.TestSkin(color)
	local player = ParaScene.GetPlayer();
	local playerChar = player:ToCharacter();
	playerChar:SetBodyParams(color, -1, -1, -1, -1);
	local playerAsset = player:GetPrimaryAsset():GetKeyName();
	if(playerAsset ~= nil and string.find(string.lower(playerAsset), "female")) then
		playerChar:SetBodyParams(-1, -1, -1, -1, 1);
		playerChar:SetCartoonFaceComponent(0, 0, color + 100);
		playerChar:SetCartoonFaceComponent(1, 0, -1);
		playerChar:SetCartoonFaceComponent(2, 0, -1);
		playerChar:SetCartoonFaceComponent(3, 0, -1);
		playerChar:SetCartoonFaceComponent(4, 0, -1);
		playerChar:SetCartoonFaceComponent(5, 0, -1);
		--playerChar:SetCartoonFaceComponent(6, 0, -1);
	else
		playerChar:SetBodyParams(-1, -1, -1, -1, 1);
		playerChar:SetCartoonFaceComponent(0, 0, color + 200);
		playerChar:SetCartoonFaceComponent(1, 0, -1);
		playerChar:SetCartoonFaceComponent(2, 0, -1);
		playerChar:SetCartoonFaceComponent(3, 0, -1);
		playerChar:SetCartoonFaceComponent(4, 0, -1);
		playerChar:SetCartoonFaceComponent(5, 0, -1);
		--playerChar:SetCartoonFaceComponent(6, 0, -1);
	end
end

function AdvCCSModifyTeenPage.TestFace(color)
	color = tonumber(color);
	local player = ParaScene.GetPlayer();
	local playerChar = player:ToCharacter();
	local playerAsset = player:GetPrimaryAsset():GetKeyName();
	if(playerAsset ~= nil and string.find(string.lower(playerAsset), "female")) then
		playerChar:SetBodyParams(-1, -1, -1, -1, 1);
		playerChar:SetCartoonFaceComponent(6, 0, color + 100);
	else
		playerChar:SetBodyParams(-1, -1, -1, -1, 1);
		playerChar:SetCartoonFaceComponent(6, 0, color + 200);
	end
end

function AdvCCSModifyTeenPage.TestEyeAddon(index)
	index = tonumber(index);
	local player = ParaScene.GetPlayer();
	local playerChar = player:ToCharacter();
	if(index == 0) then
		playerChar:SetBodyParams(-1, -1, -1, -1, 1);
	elseif(index == 1) then
		playerChar:SetBodyParams(-1, index, -1, -1, 2);
	elseif(index == 2) then
		playerChar:SetBodyParams(-1, index, -1, -1, 2);
	end
end

function AdvCCSModifyTeenPage.TestWings(index)
	index = tonumber(index);
	local player = ParaScene.GetPlayer();
	local playerChar = player:ToCharacter();
	if(index == 0) then
		playerChar:SetCharacterSlot(21, 0)
	elseif(index == 1) then
		playerChar:SetCharacterSlot(21, 1065)
	elseif(index == 2) then
		playerChar:SetCharacterSlot(21, 341)
	end
end

function AdvCCSModifyTeenPage.GetDS_Func_CartoonFace(index_Func)
	return function (index)
		if(index ~= nil) then
			if(index_Func == 1) then
				if(index > 40) then
					return;
				end
				local filename = "character/v3/CartoonFace/FaceDeco/marks_"..string.format("%02d", index-1)..".png";
				return {img = filename, tooltip = filename, type = index_Func, style = index,};
			elseif(index_Func == 6) then
				if(index > 11) then
					return;
				end
				local filename = "character/v3/CartoonFace/Mark/marks_"..string.format("%02d", index+9)..".png";
				return {img = filename, tooltip = filename, type = index_Func, style = index,};
			else
				if(index > 100) then
					return;
				end
				if(index_Func == 2) then
					local filename = "character/v3/CartoonFace/Eye/Eye_"..string.format("%02d", index-1)..".png";
					return {img = filename, tooltip = filename, type = index_Func, style = index,};
				elseif(index_Func == 3) then
					local filename = "character/v3/CartoonFace/Eyebrow/Eyebrow_"..string.format("%02d", index-1)..".png";
					return {img = filename, tooltip = filename, type = index_Func, style = index,};
				elseif(index_Func == 4) then
					local filename = "character/v3/CartoonFace/Mouth/mouth_"..string.format("%02d", index-1)..".png";
					return {img = filename, tooltip = filename, type = index_Func, style = index,};
				elseif(index_Func == 5) then
					local filename = "character/v3/CartoonFace/Nose/nose_"..string.format("%02d", index-1)..".png";
					return {img = filename, tooltip = filename, type = index_Func, style = index,};
				end
			end
		elseif(index == nil) then
			if(index_Func == 1) then
				return 40;
			elseif(index_Func == 6) then
				return 11;
			else
				return 100;
			end
		end
	end
end

function AdvCCSModifyTeenPage.TestCartoonFace(type, style)

	local player = ParaScene.GetPlayer();
	local playerChar = player:ToCharacter();
	-- set to cartoon face
	playerChar:SetBodyParams(-1, -1, -1, -1, 1);
	if(type == 6) then
		playerChar:SetCartoonFaceComponent(type, 0, style);
	else
		playerChar:SetCartoonFaceComponent(type, 0, style - 1);
	end
	
    local _this = ParaUI.GetUIObject("Custom_ComposedFace");
    if(_this:IsValid() == true) then
		_this.background = ParaScene.GetPlayer():GetReplaceableTexture(7):GetFileName();
    end
end

local FaceTexSize = 256;

function AdvCCSModifyTeenPage.Custom_ComposedFace(params)
	
	ParaUI.Destroy("Custom_ComposedFace");
	
    local _this = ParaUI.CreateUIObject("container", "Custom_ComposedFace", params.alignment, params.left, params.top, params.width, params.height);
	_this.background = ParaScene.GetPlayer():GetReplaceableTexture(7):GetFileName();
	_this.enabled = false;
	params.parent:AddChild(_this);
	
	-- tricky show the eye component on compose face texture init
	AdvCCSModifyTeenPage.ClickCartoonFaceComponent("Eye");
end

function AdvCCSModifyTeenPage.ClickCartoonFaceComponent(value)
    local _composed = ParaUI.GetUIObject("Custom_ComposedFace");
    if(_composed:IsValid() == true) then
        _composed:RemoveAll();
        
        if(value == "Wrinkle" or value == "Mark") then
            local _guide = ParaUI.CreateUIObject("container", "Wrinkle", "_lt", 0, 0, FaceTexSize, FaceTexSize);
	        _guide.background = "texture/alphadot.png";
	        _composed:AddChild(_guide);
        elseif(value == "Eye") then
            local _guide = ParaUI.CreateUIObject("container", "Eye", "_lt", FaceTexSize*3/8-30, FaceTexSize*3/8, FaceTexSize/4, FaceTexSize/4);
	        _guide.background = "texture/alphadot.png";
	        _composed:AddChild(_guide);
    	    
            local _guide = ParaUI.CreateUIObject("container", "Eye", "_lt", FaceTexSize*3/8+30, FaceTexSize*3/8, FaceTexSize/4, FaceTexSize/4);
	        _guide.background = "texture/alphadot.png";
	        _composed:AddChild(_guide);
        elseif(value == "Eyebrow") then
            local _guide = ParaUI.CreateUIObject("container", "Eyebrow", "_lt", FaceTexSize*3/8-33, FaceTexSize*3/8-20, FaceTexSize/4, FaceTexSize/4);
	        _guide.background = "texture/alphadot.png";
	        _composed:AddChild(_guide);
    	    
            local _guide = ParaUI.CreateUIObject("container", "Eyebrow", "_lt", FaceTexSize*3/8+33, FaceTexSize*3/8-20, FaceTexSize/4, FaceTexSize/4);
	        _guide.background = "texture/alphadot.png";
	        _composed:AddChild(_guide);
        elseif(value == "Mouth") then
            local _guide = ParaUI.CreateUIObject("container", "Mouth", "_lt", FaceTexSize*3/8, FaceTexSize*3/8+41, FaceTexSize/4, FaceTexSize/4);
	        _guide.background = "texture/alphadot.png";
	        _composed:AddChild(_guide);
        elseif(value == "Nose") then
            local _guide = ParaUI.CreateUIObject("container", "Nose", "_lt", FaceTexSize*3/8, FaceTexSize*3/8+12, FaceTexSize/4, FaceTexSize/4);
	        _guide.background = "texture/alphadot.png";
	        _composed:AddChild(_guide);
        end
    end
end


function AdvCCSModifyTeenPage.GetDS_Func_CharacterSlot(index_Func)
	return function (index)
		if(index ~= nil) then
			if(index_Func == 1) then
				-- head
				if(index > 40) then
					return;
				end
				return {img = "character/v3/CartoonFace/FaceDeco/marks_"..string.format("%02d", index-1)..".png", type = index_Func, style = index,};
			elseif(index_Func == 6) then
				if(index > 11) then
					return;
				end
				return {img = "character/v3/CartoonFace/Mark/marks_"..string.format("%02d", index+9)..".png", type = index_Func, style = index,};
			else
				if(index > 100) then
					return;
				end
				if(index_Func == 2) then
					return {img = "character/v3/CartoonFace/Eye/Eye_"..string.format("%02d", index-1)..".png", type = index_Func, style = index,};
				elseif(index_Func == 3) then
					return {img = "character/v3/CartoonFace/Eyebrow/Eyebrow_"..string.format("%02d", index-1)..".png", type = index_Func, style = index,};
				elseif(index_Func == 4) then
					return {img = "character/v3/CartoonFace/Mouth/mouth_"..string.format("%02d", index-1)..".png", type = index_Func, style = index,};
				elseif(index_Func == 5) then
					return {img = "character/v3/CartoonFace/Nose/nose_"..string.format("%02d", index-1)..".png", type = index_Func, style = index,};
				end
			end
		elseif(index == nil) then
			if(index_Func == 1) then
				return 40;
			elseif(index_Func == 6) then
				return 11;
			else
				return 100;
			end
		end
	end
end

function AdvCCSModifyTeenPage.TestCharacterSlot(type, style)

	local player = ParaScene.GetPlayer();
	local playerChar = player:ToCharacter();
	-- set to cartoon face
	playerChar:SetBodyParams(-1, -1, -1, -1, 1);
	playerChar:SetCartoonFaceComponent(type, 0, style);
	
    --local _this = ParaUI.GetUIObject("Custom_ComposedFace");
    --if(_this:IsValid() == true) then
		--_this.background = ParaScene.GetPlayer():GetReplaceableTexture(7):GetFileName();
    --end
end

--local SkinTexSize = 256;
--
--function AdvCCSModifyTeenPage.Custom_ComposedSkin(params)
--end



--function AdvCCSModifyTeenPage.TestNameConvention()
	---- get the current character 
	---- check the naming and convension in the character directory
	--local player = ParaScene.GetPlayer();
	--local playerAsset = player:GetPrimaryAsset():GetKeyName();
	--if(playerAsset ~= nil) then
		--local ext = string.lower(ParaIO.GetFileExtension(playerAsset));
		--local fileName;
		--local directory;
		--if(ext ~= "x") then
			---- this is a Para-X file
			--fileName = ParaIO.GetFileName(playerAsset);
			--directory = string.gsub(playerAsset, fileName, "");
		--elseif(ext ~= "xml") then
			---- this is an xml desc character file with LoD
			--fileName = ParaIO.GetFileName(playerAsset);
			--directory = string.gsub(playerAsset, fileName, "");
		--else
			---- not an engine acceptable file extension
		--end
			--
		--local nMaxNumFiles = 5000;
		---- check the base skins
		--local search_result = ParaIO.SearchFiles(directory, "*.dds", "", 0, nMaxNumFiles, 0);
		--local nCount = search_result:GetNumOfResult();
		--local i = 0;
		--for i = 0, nCount - 1 do
			--local skins = search_result:GetItem(i);
			--
			--local nGeoSetPos = string.find(sTexFileName_TU, "Hairs_");
			--
			--search_result
		--end
		--if(search_result) then
		--end
		--
		--searchfiles
		--directory
		--
		---- check the hair styles
		--
		---- check the wings styles
		--
		---- check the wings styles
			--
	--end
--end





-- take screen shot of the character pe:avatar. 
function AdvCCSModifyTeenPage.TakeAvatarSnapshot()
	-- taking the snapshot calling the AvatarRegPage.lua function
	NPL.load("(gl)script/kids/3DMapSystemUI/CCS/AvatarRegPage.lua");
	Map3DSystem.App.CCS.AvatarRegPage.TakeAvatarSnapshot();
end

-- load the current player to canvas
function AdvCCSModifyTeenPage.OnRefreshAvatar()
	local self = document:GetPageCtrl();
	if(not self) then 
		log("warning: page control not found\n")
		return 
	end
	
	local ctl = self:FindControl("avatar");
	if(ctl and ParaScene.GetPlayer():IsValid()) then
		ctl:ShowModel({
			["IsCharacter"] = true,
			["y"] = 0,
			["x"] = 0,
			["facing"] = -1.57,
			["name"] = "avatar",
			["z"] = 0,
			["AssetFile"] = ParaScene.GetPlayer():GetPrimaryAsset():GetKeyName(),
			["CCSInfoStr"] = Map3DSystem.UI.CCS.GetCCSInfoString(ParaScene.GetPlayer()),
		});
	end
end

-- save the user avatar information
function AdvCCSModifyTeenPage.OnClickSave()

	local self = document:GetPageCtrl();
	if(not self) then 
		log("warning: page control not found")
		return 
	end
	
	if(name ~= Map3DSystem.User.Name) then
		-- LXZ: is it really needed? 2008.6.21
		-- paraworld.ShowMessage("请先切换到你的主角\n");
		-- return 
	end
	
	local player = ParaScene.GetPlayer();
	local name = ParaScene.GetPlayer().name;
	
	local PlayerAsset = player:GetPrimaryAsset():GetKeyName();
	local ccsinfo = Map3DSystem.UI.CCS.GetCCSInfoString(player);
	
	local profile = Map3DSystem.App.CCS.app:GetMCMLInMemory() or {};
	if(type(profile) ~= "table") then
		profile = {};
	end
	profile.CharParams = profile.CharParams or {};
	
	-- modified lxz 2008.6.21
	local CharParams = {
		AssetFile = PlayerAsset,
		CCSInfoStr = ccsinfo,
	}
	if(not commonlib.partialcompare(profile.CharParams, CharParams)) then
		self:SetUIValue("result", "正在更新, 请稍候...");
		commonlib.partialcopy(profile.CharParams, CharParams);
		
		Map3DSystem.App.CCS.app:SetMCML(nil, profile, function (uid, appkey, bSucceed)
			if(bSucceed) then
				self:SetUIValue("result", "更新成功！ 谢谢！")
			else
				self:SetUIValue("result", "暂时无法更新，请稍候再试")
			end	
		end)
	else
		self:SetUIValue("result", "您并没有做任何修改")
	end	
end



















-- 26 for IT_MASK, CS_FACE_ADDON


function AdvCCSModifyTeenPage.Custom_OriginalCCSMain(params)
    
    ParaUI.Destroy("Custom_OriginalCCSMain");
    
    local _this = ParaUI.CreateUIObject("container", "Custom_OriginalCCSMain", params.alignment, params.left, params.top, params.width, params.height);
	_this.background = "";
	params.parent:AddChild(_this);
	
	local _parent = _this;
	
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/TabGrid.lua");
	
	NPL.load("(gl)script/kids/3DMapSystemUI/CCS/DB.lua");
	
	local _tab_INV = ParaUI.CreateUIObject("container", "Tab_INV", "_mr", 0, 0, 60, 0);
	_tab_INV.background = "";
	_parent:AddChild(_tab_INV);
	
	local _inventorySelector = ParaUI.CreateUIObject("container", "Selector", "_fi", 0, 0, 60, 0);
	_inventorySelector.background = "";
	_parent:AddChild(_inventorySelector);
	
	
	NPL.load("(gl)script/ide/TreeView.lua");
	local tabPagesNode_INV = CommonCtrl.TreeNode:new({Name = "CCS_TabControlRootNode_INV"});
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "Hat", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_Head.png"}));
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "Shoulder", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_Shoulder.png"}));
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "Shirt", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_Chest.png"}));
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "Gloves", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_Gloves.png"}));
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "Pants", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_Pants.png"}));
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "Boots", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_Boots.png"}));
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "LeftHand", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_HandLeft.png"}));
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "RightHand", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_HandRight.png"}));
	tabPagesNode_INV:AddChild(CommonCtrl.TreeNode:new({tooltip = "Tabard", icon = "Texture/3DMapSystem/CCS/RightPanel/IT_Cape.png"}));
	
	NPL.load("(gl)script/ide/TabControl.lua");
    
    CommonCtrl.DeleteControl("CCS_TabControl_Inventory");
    
	local ctl = CommonCtrl.TabControl:new{
			name = "CCS_TabControl_Inventory",
			parent = _tab_INV,
			background = nil,
			alignment = "_fi",
			wnd = nil,
			left = 0,
			top = 0,
			width = 0,
			height = 0,
			zorder = 0,
			
			TabAlignment = "Right", -- Left|Right|Top|Bottom, Top if nil
			TabPages = tabPagesNode_INV, -- CommonCtrl.TreeNode object, collection of tab pages
			TabHeadOwnerDraw = function(_parent, tabControl) 
					local _head = ParaUI.CreateUIObject("container", "Item", "_fi", 0, 0, 0, 0);
					_head.background = "Texture/3DMapSystem/Creator/tabcontrol_bg_32bits.png;32 0 32 14:20 13 11 0";
					_head.enabled = false;
					_parent:AddChild(_head);
					local _head = ParaUI.CreateUIObject("button", "Item", "_lb", 20, -40, 32, 32);
					_head.background = "Texture/3DMapSystem/Creator/PageUp.png";
					_head.onclick = ";CommonCtrl.TabControl.PageBackward(\""..tabControl.name.."\");";
					_parent:AddChild(_head);
				end, --function(_parent, tabControl) end, -- area between top/left border and the first item
			TabTailOwnerDraw = function(_parent, tabControl) 
					local _tail = ParaUI.CreateUIObject("container", "Item", "_fi", 0, 0, 0, 0);
					_tail.background = "Texture/3DMapSystem/Creator/tabcontrol_bg_32bits.png;32 52 32 12:20 0 11 11";
					_tail.enabled = false;
					_parent:AddChild(_tail);
					local _tail = ParaUI.CreateUIObject("button", "Item", "_lt", 20, 8, 32, 32);
					_tail.background = "Texture/3DMapSystem/Creator/PageDown.png";
					_tail.onclick = ";CommonCtrl.TabControl.PageForward(\""..tabControl.name.."\");";
					_parent:AddChild(_tail);
				end, --function(_parent, tabControl) end, -- area between the last item and buttom/right border
			TabStartOffset = 40, -- start of the tabs from the border
			TabItemOwnerDraw = function(_parent, index, bSelected, tabControl) 
					if(bSelected == true) then
						local _item = ParaUI.CreateUIObject("container", "Item", "_fi", 0, 0, 0, 0);
						_item.background = "Texture/3DMapSystem/Creator/tabcontrol_bg_32bits.png;32 14 32 37:17 16 14 16";
						_item.enabled = false;
						_parent:AddChild(_item);
					else
						local _item = ParaUI.CreateUIObject("container", "Item", "_fi", 0, 0, 0, 0);
						_item.background = "Texture/3DMapSystem/Creator/tabcontrol_bg_32bits.png;32 11 32 3:20 1 11 1";
						_item.enabled = false;
						_parent:AddChild(_item);
					end
					local node = tabControl.TabPages:GetChild(index);
					local _item = ParaUI.CreateUIObject("button", "Item", "_lt", 22, 8, 32, 32);
					_item.background = node.icon;
					_item.onclick = string.format(";CommonCtrl.TabControl.OnClickTab(%q, %s);", tabControl.name, index);
					_parent:AddChild(_item);
				end, --function(_parent, index, bSelected, tabControl) end, -- owner draw item
			TabItemWidth = 60, -- width of each tab item
			TabItemHeight = 48, -- height of each tab item
			MaxTabNum = 8, -- maximum number of the tabcontrol, pager required when tab number exceeds the maximum
			OnSelectedIndexChanged = function(fromIndex, toIndex)
				local ctl = CommonCtrl.GetControl("InventoryTabGrid");
				if(ctl ~= nil) then
					ctl:SetLevelIndex(toIndex);
				end
			end,
		};
	ctl:Show(true);
	
	-- default to shirt
	ctl:SetSelectedIndex(3);
	
	-- unmount the item according to current character slot on the current character
	function OnClickUnmountCurrentCharacterSlot()
		
		local ctl = CommonCtrl.GetControl("InventoryTabGrid");
		if(ctl ~= nil) then
			local level1index, _ = ctl:GetLevelIndex();
			local component;
			if(level1index == 1) then
				component = Map3DSystem.UI.CCS.DB.CS_HEAD;
			elseif(level1index == 2) then
				component = Map3DSystem.UI.CCS.DB.CS_SHOULDER;
			elseif(level1index == 3) then
				component = Map3DSystem.UI.CCS.DB.CS_SHIRT;
			elseif(level1index == 4) then
				component = Map3DSystem.UI.CCS.DB.CS_GLOVES;
			elseif(level1index == 5) then
				component = Map3DSystem.UI.CCS.DB.CS_PANTS;
			elseif(level1index == 6) then
				component = Map3DSystem.UI.CCS.DB.CS_BOOTS;
			elseif(level1index == 7) then
				component = Map3DSystem.UI.CCS.DB.CS_HAND_LEFT;
			elseif(level1index == 8) then
				component = Map3DSystem.UI.CCS.DB.CS_HAND_RIGHT;
			elseif(level1index == 9) then
				component = Map3DSystem.UI.CCS.DB.CS_CAPE;
			end
			
			
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj = ParaScene.GetPlayer()});
			
			-- temporarily directly mount the item on the selected character
			local player, playerChar = Map3DSystem.UI.CCS.DB.GetPlayerChar();
			if(playerChar~=nil) then
				playerChar:SetCharacterSlot(component, 0);
			end
			
			-- TODO: general implementation
			-- mount the default shirt or pant for human female and male
			local player = ParaScene.GetPlayer();
			local assetName = player:GetPrimaryAsset():GetKeyName();
			
			if(string.find(assetName, "HumanFemale.x") ~= nil) then
				if(component == Map3DSystem.UI.CCS.DB.CS_SHIRT) then
					playerChar:SetCharacterSlot(component, 10);
				elseif(component == Map3DSystem.UI.CCS.DB.CS_PANTS) then
					playerChar:SetCharacterSlot(component, 12);
				end
			end
			
			if(string.find(assetName, "HumanMale.x") ~= nil) then
				if(component == Map3DSystem.UI.CCS.DB.CS_SHIRT) then
					playerChar:SetCharacterSlot(component, 11);
				elseif(component == Map3DSystem.UI.CCS.DB.CS_PANTS) then
					playerChar:SetCharacterSlot(component, 13);
				end
			end
			
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
		end
	end
	
	CommonCtrl.DeleteControl("InventoryTabGrid");
	local ctl = CommonCtrl.GetControl("InventoryTabGrid");
	if(ctl == nil) then
		local param = {
			name = "InventoryTabGrid",
			parent = _inventorySelector,
			background = "Texture/3DMapSystem/Creator/tabcontrol_bg_32bits.png;0 0 32 64:16 16 1 16",
			wnd = wnd,
			
			----------- CATEGORY REGION -----------
			Level1 = "Right",
			Level1BG = "",
			Level1HeadBG = "Texture/3DMapSystem/Desktop/RightPanel/BarBGTop.png; 0 0 50 24",
			Level1TailBG = "Texture/3DMapSystem/Desktop/RightPanel/BarBGBottom.png; 0 0 50 64: 1 0 1 63",
			Level1Offset = 24,
			Level1ItemWidth = 0,
			Level1ItemHeight = 50,
			--Level1ItemGap = 8,
			
			Level1ItemOwnerDraw = function (_parent, level1index, bSelected, tabGrid)
				-- background
				if(bSelected) then
					local _back = ParaUI.CreateUIObject("container", "back", "_fi", 0, 0, 0, 0);
					_back.background = tabGrid.GetLevel1ItemSelectedBackImage(level1index);
					_parent:AddChild(_back);
				else
					local _back = ParaUI.CreateUIObject("container", "back", "_fi", 0, 0, 0, 0);
					_back.background = tabGrid.GetLevel1ItemUnselectedBackImage(level1index);
					_parent:AddChild(_back);
				end
				
				-- icon
				local _btn = ParaUI.CreateUIObject("button", "btn"..level1index, "_lt", 11, 9, 32, 32);
				if(bSelected) then
					_btn.background = tabGrid.GetLevel1ItemSelectedForeImage(level1index);
				else
					_btn.background = tabGrid.GetLevel1ItemUnselectedForeImage(level1index);
				end
				_btn.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickCategory("%s", %d, nil);]], 
						tabGrid.name, level1index);
				_parent:AddChild(_btn);
			end,
			
			--Level2 = "Top",
			--Level2Offset = 48,
			--Level2ItemWidth = 32,
			--Level2ItemHeight = 48,
			--Level2ItemGap = 0,
			
			----------- GRID REGION -----------
			nGridBorderLeft = 0,
			nGridBorderTop = 8,
			nGridBorderRight = 0,
			nGridBorderBottom = 0,
			
			nGridCellWidth = 48,
			nGridCellHeight = 48,
			nGridCellGap = 8, -- gridview gap between cells
			
			----------- PAGE REGION -----------
			pageRegionHeight = 48,
			pageNumberWidth = 40,
			pageDefaultMargin = 16,
			pageNumberColor = "0 0 0",
			
			pageLeftImage = "Texture/3DMapSystem/Desktop/RightPanel/PreviousPage32.png",
			pageLeftWidth = 24,
			pageLeftHeight = 24,
			
			pageRightImage = "Texture/3DMapSystem/Desktop/RightPanel/NextPage32.png",
			pageRightWidth = 24,
			pageRightHeight = 24,
			
			isAlwaysShowPager = true,
			
			isGridView3D = true, -- show 3D grid
			
			----------- FUNCTION REGION -----------
			GetLevel1ItemCount = function() return 9; end,
			GetLevel1ItemSelectedForeImage = function(index)
					if(index == 1) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Head.png";
					elseif(index == 2) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Shoulder.png";
					elseif(index == 3) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Chest.png";
					elseif(index == 4) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Gloves.png";
					elseif(index == 5) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Pants.png";
					elseif(index == 6) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Boots.png";
					elseif(index == 7) then return "Texture/3DMapSystem/CCS/RightPanel/IT_HandLeft.png";
					elseif(index == 8) then return "Texture/3DMapSystem/CCS/RightPanel/IT_HandRight.png";
					elseif(index == 9) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Cape.png";
					end
				end,
			GetLevel1ItemSelectedBackImage = function(index)
					return "Texture/3DMapSystem/Desktop/RightPanel/TabSelected.png; 0 0 50 64: 24 16 12 12";
				end,
			GetLevel1ItemUnselectedForeImage = function(index)
					if(index == 1) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Head.png";
					elseif(index == 2) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Shoulder.png";
					elseif(index == 3) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Chest.png";
					elseif(index == 4) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Gloves.png";
					elseif(index == 5) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Pants.png";
					elseif(index == 6) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Boots.png";
					elseif(index == 7) then return "Texture/3DMapSystem/CCS/RightPanel/IT_HandLeft.png";
					elseif(index == 8) then return "Texture/3DMapSystem/CCS/RightPanel/IT_HandRight.png";
					elseif(index == 9) then return "Texture/3DMapSystem/CCS/RightPanel/IT_Cape.png";
					end
				end,
			GetLevel1ItemUnselectedBackImage = function(index)
					return "Texture/3DMapSystem/Desktop/RightPanel/TabUnSelected.png; 0 0 50 64";
				end,
			
			
			GetGridItemEnabled = function()
					return true;
				end,
			
			GetGridItemCount = function(level1index, level2index)
					return table.getn(Map3DSystem.UI.CCS.DB.AuraInventoryID[level1index]);
				end,
			GetGrid3DItemModel = function(level1index, level2index, itemindex)
					return Map3DSystem.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].model;
				end,
			GetGrid3DItemSkin = function(level1index, level2index, itemindex)
					return Map3DSystem.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin;
				end,
			
			OnClickItem = function(level1index, level2index, itemindex)
					
					if(mouse_button == "right") then
						local param = {
							AssetFile = Map3DSystem.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].model, 
							x = 0, y = 0, z = 0, 
							ReplaceableTextures = {
								[2] = Map3DSystem.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[1],
								[3] = Map3DSystem.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[2],
								[4] = Map3DSystem.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[3],
								[5] = Map3DSystem.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[4],},
						};
						Map3DSystem.UI.Creator.ShowPreview(param);
					elseif(mouse_button == "left") then
						local component;
						if(level1index == 1) then
							component = Map3DSystem.UI.CCS.DB.CS_HEAD;
						elseif(level1index == 2) then
							component = Map3DSystem.UI.CCS.DB.CS_SHOULDER;
						elseif(level1index == 3) then
							component = Map3DSystem.UI.CCS.DB.CS_SHIRT;
						elseif(level1index == 4) then
							component = Map3DSystem.UI.CCS.DB.CS_GLOVES;
						elseif(level1index == 5) then
							component = Map3DSystem.UI.CCS.DB.CS_PANTS;
						elseif(level1index == 6) then
							component = Map3DSystem.UI.CCS.DB.CS_BOOTS;
						elseif(level1index == 7) then
							component = Map3DSystem.UI.CCS.DB.CS_HAND_LEFT;
						elseif(level1index == 8) then
							component = Map3DSystem.UI.CCS.DB.CS_HAND_RIGHT;
						elseif(level1index == 9) then
							component = Map3DSystem.UI.CCS.DB.CS_CAPE;
						end
						
						Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj = ParaScene.GetPlayer()});
						
						-- temporarily directly mount the item on the selected character
						local player, playerChar = Map3DSystem.UI.CCS.DB.GetPlayerChar();
						if(playerChar~=nil) then
							--playerChar:SetCharacterSlot(component, Map3DSystem.UI.CCS.DB.AuraInventoryID[level1index][itemindex]);
							Map3DSystem.UI.CCS.Inventory.SetCharacterSlot(player, component, Map3DSystem.UI.CCS.DB.AuraInventoryID[level1index][itemindex]);
						end
						
						Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
						
					end
				end,
		};
		ctl = Map3DSystem.UI.TabGrid:new(param);
	end
	
	ctl:Show(true);
	
	-- default to shirt 
	ctl:SetLevelIndex(3);
	
	local _tools = ParaUI.CreateUIObject("container", "Tools", "_lb", 4, -44, 245, 40);
	_tools.background = "Texture/3DMapSystem/Creator/container_32bits.png:7 7 7 7";
	_parent:AddChild(_tools);
	
	-- remove item button
	local _remove = ParaUI.CreateUIObject("button", "Remove", "_lt", 4, 4, 32, 32);
	_remove.background = "Texture/3DMapSystem/common/reset.png";
	_remove.onclick = ";OnClickUnmountCurrentCharacterSlot();";
	_remove.tooltip = "卸下当前装备";
	_tools:AddChild(_remove);
end