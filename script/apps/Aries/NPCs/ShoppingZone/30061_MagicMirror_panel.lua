--[[
Title: code behind for page 30061_MagicMirror_panel.html
Author(s): WangTian
Date: 2009/10/13
Desc:  script/apps/Aries/NPCs/ShoppingZone/30061_MagicMirror_panel.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local MagicMirrorPanelPage = {};
commonlib.setfield("MyCompany.Aries.MagicMirrorPanelPage", MagicMirrorPanelPage);


MagicMirrorPanelPage.Choices = {
	--cartoonface_info = {
		--[1] = { section = "0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#8#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face01_32bits.png;0 0 48 48"},
		--[2] = { section = "0#F#0#0#0#0#9#F#0#0#0#0#9#F#0#0#0#0#10#F#0#0#0#0#8#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face02_32bits.png;0 0 48 48"},
		--[3] = { section = "0#F#0#0#0#0#10#F#0#0#0#0#10#F#0#0#0#0#11#F#0#0#0#0#9#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face03_32bits.png;0 0 48 48"},
		--[4] = { section = "0#F#0#0#0#0#4#F#0#0#0#0#6#F#0#0#0#0#7#F#0#0#0#0#6#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face04_32bits.png;0 0 48 48"},
		--[5] = { section = "0#F#0#0#0#0#11#F#0#0#0#0#11#F#0#0#0#0#12#F#0#0#0#0#10#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face05_32bits.png;0 0 48 48"},
		--[6] = { section = "0#F#0#0#0#0#8#F#0#0#0#0#7#F#0#0#0#0#8#F#0#0#0#0#6#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face06_32bits.png;0 0 48 48"},
		--[7] = { section = "0#F#0#0#0#0#5#F#0#0#0#0#8#F#0#0#0#0#9#F#0#0#0#0#7#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face07_32bits.png;0 0 48 48"},
		--[8] = { section = "0#F#0#0#0#0#2#F#0#0#0#0#2#F#0#0#0#0#4#F#0#0#0#0#3#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face08_32bits.png;0 0 48 48"},
		--[9] = { section = "0#F#0#0#0#0#7#F#0#0#0#0#3#F#0#0#0#0#5#F#0#0#0#0#4#F#0#0#0#0#0#F#0#0#0#0#", icon = "Texture/Aries/Login/NewAvatar/Face09_32bits.png;0 0 48 48"},
	--}, -- section 3
	hair_info = {
		[1] = { section = "0#1", icon = "Texture/Aries/Login/NewAvatar/Hair01_32bits.png;0 0 48 48"},
		[2] = { section = "0#2", icon = "Texture/Aries/Login/NewAvatar/Hair02_32bits.png;0 0 48 48"},
		[3] = { section = "0#4", icon = "Texture/Aries/Login/NewAvatar/Hair03_32bits.png;0 0 48 48"},
		[4] = { section = "0#5", icon = "Texture/Aries/Login/NewAvatar/Hair04_32bits.png;0 0 48 48"},
		[5] = { section = "0#6", icon = "Texture/Aries/Login/NewAvatar/Hair05_32bits.png;0 0 48 48"},
		[6] = { section = "0#7", icon = "Texture/Aries/Login/NewAvatar/Hair06_32bits.png;0 0 48 48"},
		[7] = { section = "0#8", icon = "Texture/Aries/Login/NewAvatar/Hair07_32bits.png;0 0 48 48"},
	}, -- section 2
	eye_info = {
		[1] = { section = "0", icon = "character/v3/CartoonFace/Eye/Eye_00.png";},
		[2] = { section = "4", icon = "character/v3/CartoonFace/Eye/Eye_04.png";},
		[3] = { section = "5", icon = "character/v3/CartoonFace/Eye/Eye_05.png";},
		[4] = { section = "7", icon = "character/v3/CartoonFace/Eye/Eye_07.png";},
		[5] = { section = "8", icon = "character/v3/CartoonFace/Eye/Eye_08.png";},
		[6] = { section = "9", icon = "character/v3/CartoonFace/Eye/Eye_09.png";},
		[7] = { section = "10", icon = "character/v3/CartoonFace/Eye/Eye_10.png";},
		[8] = { section = "11", icon = "character/v3/CartoonFace/Eye/Eye_11.png";},
	}, 
	eyebrow_info = {
		[1] = { section = "0", icon = "character/v3/CartoonFace/Eyebrow/Eyebrow_00.png";},
		[2] = { section = "2", icon = "character/v3/CartoonFace/Eyebrow/Eyebrow_02.png";},
		[3] = { section = "3", icon = "character/v3/CartoonFace/Eyebrow/Eyebrow_03.png";},
		[4] = { section = "6", icon = "character/v3/CartoonFace/Eyebrow/Eyebrow_06.png";},
		[5] = { section = "7", icon = "character/v3/CartoonFace/Eyebrow/Eyebrow_07.png";},
		[6] = { section = "8", icon = "character/v3/CartoonFace/Eyebrow/Eyebrow_08.png";},
		[7] = { section = "9", icon = "character/v3/CartoonFace/Eyebrow/Eyebrow_09.png";},
		[8] = { section = "10", icon = "character/v3/CartoonFace/Eyebrow/Eyebrow_10.png";},
		[9] = { section = "11", icon = "character/v3/CartoonFace/Eyebrow/Eyebrow_11.png";},
	}, 
	mouth_info = {
		[1] = { section = "0", icon = "character/v3/CartoonFace/Mouth/mouth_00.png";},
		[2] = { section = "4", icon = "character/v3/CartoonFace/Mouth/mouth_04.png";},
		[3] = { section = "5", icon = "character/v3/CartoonFace/Mouth/mouth_05.png";},
		[4] = { section = "7", icon = "character/v3/CartoonFace/Mouth/mouth_07.png";},
		[5] = { section = "8", icon = "character/v3/CartoonFace/Mouth/mouth_08.png";},
		[6] = { section = "9", icon = "character/v3/CartoonFace/Mouth/mouth_09.png";},
		[7] = { section = "10", icon = "character/v3/CartoonFace/Mouth/mouth_10.png";},
		[8] = { section = "11", icon = "character/v3/CartoonFace/Mouth/mouth_11.png";},
		[9] = { section = "12", icon = "character/v3/CartoonFace/Mouth/mouth_12.png";},
	}, 
	nose_info = {
		[1] = { section = "0", icon = "character/v3/CartoonFace/Nose/nose_00.png";},
		[2] = { section = "3", icon = "character/v3/CartoonFace/Nose/nose_03.png";},
		[3] = { section = "4", icon = "character/v3/CartoonFace/Nose/nose_04.png";},
		[4] = { section = "6", icon = "character/v3/CartoonFace/Nose/nose_06.png";},
		[5] = { section = "7", icon = "character/v3/CartoonFace/Nose/nose_07.png";},
		[6] = { section = "8", icon = "character/v3/CartoonFace/Nose/nose_08.png";},
		[7] = { section = "9", icon = "character/v3/CartoonFace/Nose/nose_09.png";},
	}, 
	--skin_info = {
		--[1] = { section = "0#", icon = "Texture/Aries/Login/NewAvatar/Skin01_32bits.png;0 0 48 48"},
		--[2] = { section = "1#", icon = "Texture/Aries/Login/NewAvatar/Skin02_32bits.png;0 0 48 48"},
		--[3] = { section = "2#", icon = "Texture/Aries/Login/NewAvatar/Skin03_32bits.png;0 0 48 48"},
		----[4] = { section = "3#", icon = "Texture/Aries/Login/NewAvatar/Skin04_32bits.png;0 0 48 48"},
		--[4] = { section = "4#", icon = "Texture/Aries/Login/NewAvatar/Skin05_32bits.png;0 0 48 48"},
		----[6] = { section = "5#", icon = "Texture/Aries/Login/NewAvatar/Skin06_32bits.png;0 0 48 48"},
	--}, -- section 1
};

MagicMirrorPanelPage.UserChoice = {
	hair_style = nil, 
	eyebrow_style = nil, 
	eye_style = nil, 
	nose_style = nil, 
	mouth_style = nil, 
};

MagicMirrorPanelPage.asset_table = {
    name = "magicmirror_avatar",
    AssetFile="character/v3/Elf/Female/ElfFemale.xml",
	--CCSInfoStr="1#1#1#1#1#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#336#337#0#0#0#0#0#0#0#0#0#1005#1006#0#1007#0#0#0#0#0#0#",
	CCSInfoStr = "0#1#0#1#1#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#0#0#0#0#0#0#0#1027#1029#1031#0#1032#0#0#0#0#0#",
	IsCharacter = true,
    x=0,y=0,z=0,
};

local my_ccs_info = nil;
local mirror_ccs_info = nil;

local page;
function MagicMirrorPanelPage.OnInit()
	MagicMirrorPanelPage.UserChoice = {};
	page = document:GetPageCtrl();
end

function MagicMirrorPanelPage.RefreshAvatar()
	
	my_ccs_info = System.UI.CCS.GetCCSInfoString(nil, true);
	MagicMirrorPanelPage.asset_table.CCSInfoStr = my_ccs_info;
	
	local base_section, cartoonface_section, equip_section = string.match(my_ccs_info, "^(.+)@(.+)@(.+)$");
	
	if(base_section and cartoonface_section and equip_section) then
		local section0;
		if(MagicMirrorPanelPage.UserChoice.hair_style) then
			section0 = MagicMirrorPanelPage.Choices.hair_info[MagicMirrorPanelPage.UserChoice.hair_style].section;
		end

		local basecolor, faceType, hair_and_hairStyle,facialHair = string.match(base_section, "([^#]+)#([^#]+)#([^#]+#[^#]+)#([^#]*)#?");
		if(basecolor and faceType and hair_and_hairStyle) then
			base_section = string.format("%s#%s#%s#", basecolor, faceType, (section0 or hair_and_hairStyle));
			-- commonlib.echo({facialHair = facialHair, base_section = base_section});
			if(facialHair ~= "") then
				base_section = base_section..facialHair.."#";
			else
				base_section = "F#";
			end
		end
		
		local section3;
		if(MagicMirrorPanelPage.UserChoice.eye_style) then
			section3 = MagicMirrorPanelPage.Choices.eye_info[MagicMirrorPanelPage.UserChoice.eye_style].section;
		end
		local section4;
		if(MagicMirrorPanelPage.UserChoice.eyebrow_style) then
			section4 = MagicMirrorPanelPage.Choices.eyebrow_info[MagicMirrorPanelPage.UserChoice.eyebrow_style].section;
		end
		local section5;
		if(MagicMirrorPanelPage.UserChoice.mouth_style) then
			section5 = MagicMirrorPanelPage.Choices.mouth_info[MagicMirrorPanelPage.UserChoice.mouth_style].section;
		end
		local section6;
		if(MagicMirrorPanelPage.UserChoice.nose_style) then
			section6 = MagicMirrorPanelPage.Choices.nose_info[MagicMirrorPanelPage.UserChoice.nose_style].section;
		end
		
		local i = 0;
		
		
		cartoonface_section = string.gsub(cartoonface_section, "(%d+)#(.-)#0#0#0#0#", function(a, b)
			i = i + 1;
			if(i == 1) then
				return a.."#"..b.."#0#0#0#0#"; -- face
			elseif(i == 2) then
				return a.."#"..b.."#0#0#0#0#"; -- wrinkle
			elseif(i == 3) then
				return (section3 or a).."#"..b.."#0#0#0#0#"; -- eye_style
			elseif(i == 4) then
				return (section4 or a).."#"..b.."#0#0#0#0#"; -- eyebrow
			elseif(i == 5) then
				return (section5 or a).."#"..b.."#0#0#0#0#"; -- mouth
			elseif(i == 6) then
				return (section6 or a).."#"..b.."#0#0#0#0#"; --  nose
			elseif(i == 7) then
				return a.."#"..b.."#0#0#0#0#"; -- marks
			end
		end);
		if(i < 7) then
			log("warning: cartoonface_section is incorrect, so we reset it to a default one\n")
			cartoonface_section = "2#F#0#0#0#0#0#F#0#0#0#0#9#F#0#0#0#0#9#F#0#0#0#0#10#F#0#0#0#0#8#F#0#0#0#0#0#F#0#0#0#0#";
		end
		
		MagicMirrorPanelPage.asset_table.CCSInfoStr = base_section.."@"..cartoonface_section.."@"..equip_section;
		commonlib.echo(MagicMirrorPanelPage.asset_table.CCSInfoStr);
		
		mirror_ccs_info = base_section.."@"..cartoonface_section.."@";
		
		local canvasCtl = page:FindControl("MirrorAvatar");
		if(canvasCtl) then
			canvasCtl:ShowModel(MagicMirrorPanelPage.asset_table);
		end
	end
end

function MagicMirrorPanelPage.DS_Func_Hair(index)
	if(index == nil) then
		return #(MagicMirrorPanelPage.Choices.hair_info);
	elseif(index) then
		return MagicMirrorPanelPage.Choices.hair_info[index];
	end
end

function MagicMirrorPanelPage.DS_Func_Eye(index)
	if(index == nil) then
		return #(MagicMirrorPanelPage.Choices.eye_info);
	elseif(index) then
		return MagicMirrorPanelPage.Choices.eye_info[index];
	end
end

function MagicMirrorPanelPage.DS_Func_EyeBrow(index)
	if(index == nil) then
		return #(MagicMirrorPanelPage.Choices.eyebrow_info);
	elseif(index) then
		return MagicMirrorPanelPage.Choices.eyebrow_info[index];
	end
end

function MagicMirrorPanelPage.DS_Func_Mouth(index)
	if(index == nil) then
		return #(MagicMirrorPanelPage.Choices.mouth_info);
	elseif(index) then
		return MagicMirrorPanelPage.Choices.mouth_info[index];
	end
end

function MagicMirrorPanelPage.DS_Func_Nose(index)
	if(index == nil) then
		return #(MagicMirrorPanelPage.Choices.nose_info);
	elseif(index) then
		return MagicMirrorPanelPage.Choices.nose_info[index];
	end
end

function MagicMirrorPanelPage.OnClickItem(index, choice)
	local ds;
	if(index == "1") then
		ds = MagicMirrorPanelPage.Choices.hair_info;
	elseif(index == "2") then
		ds = MagicMirrorPanelPage.Choices.eye_info;
	elseif(index == "3") then
		ds = MagicMirrorPanelPage.Choices.eyebrow_info;
	elseif(index == "4") then
		ds = MagicMirrorPanelPage.Choices.mouth_info;
	elseif(index == "5") then
		ds = MagicMirrorPanelPage.Choices.nose_info;
	end
	
	if(index == "1") then
		MagicMirrorPanelPage.UserChoice.hair_style = tonumber(choice);
	elseif(index == "2") then
		MagicMirrorPanelPage.UserChoice.eye_style = tonumber(choice);
	elseif(index == "3") then
		MagicMirrorPanelPage.UserChoice.eyebrow_style = tonumber(choice);
	elseif(index == "4") then
		MagicMirrorPanelPage.UserChoice.mouth_style = tonumber(choice);
	elseif(index == "5") then
		MagicMirrorPanelPage.UserChoice.nose_style = tonumber(choice);
	end
	commonlib.echo({index, choice});
	commonlib.echo(MagicMirrorPanelPage.UserChoice);
	MagicMirrorPanelPage.RefreshAvatar()
end

function MagicMirrorPanelPage.OnRandom()
	
	local r = math.random(1, #(MagicMirrorPanelPage.Choices.hair_info) * 100);
	MagicMirrorPanelPage.UserChoice.hair_style = math.ceil(r/100);
	local r = math.random(1, #(MagicMirrorPanelPage.Choices.eye_info) * 100);
	MagicMirrorPanelPage.UserChoice.eye_style = math.ceil(r/100);
	local r = math.random(1, #(MagicMirrorPanelPage.Choices.eyebrow_info) * 100);
	MagicMirrorPanelPage.UserChoice.eyebrow_style = math.ceil(r/100);
	local r = math.random(1, #(MagicMirrorPanelPage.Choices.mouth_info) * 100);
	MagicMirrorPanelPage.UserChoice.mouth_style = math.ceil(r/100);
	local r = math.random(1, #(MagicMirrorPanelPage.Choices.nose_info) * 100);
	MagicMirrorPanelPage.UserChoice.nose_style = math.ceil(r/100);
	
	MagicMirrorPanelPage.RefreshAvatar();
end

function MagicMirrorPanelPage.OnClickOK()
	
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	
	-- 17029_CrystalRock
    local bHas_17029, guid_17029 = hasGSItem(17029, 12);
    if(bHas_17029) then
		_guihelper.MessageBox([[<div style="margin-top:24px;margin-left:10px;">需要一颗晶晶石把我的表面打磨的更光滑,我才能开始工作，你愿意给我一颗晶晶石吗?</div>]], 
		function(result)
			if(_guihelper.DialogResult.OK == result) then
				local bHas, guid = hasGSItem(999);
				local ItemManager = System.Item.ItemManager;
				local hasGSItem = ItemManager.IfOwnGSItem;
				local bHas, guid = hasGSItem(999);
				if(bHas) then
					ItemManager.SetClientData(guid, mirror_ccs_info, function(msg) 
						if(msg.issuccess == true) then
							System.Item.ItemManager.RefreshMyself();
							_guihelper.MessageBox([[<div style="margin-top:24px;margin-left:50px;">神奇的魔镜是不会让你失望的！<br/>快看看自己的新样子吧！</div>]]);
							page:CloseWindow();
						end
					end);
					ItemManager.DestroyItem(guid_17029, 1, function() end);
				end
			end
		end, _guihelper.MessageBoxButtons.OKCancel, nil, "script/apps/Aries/Desktop/GUIHelper/MagicMirrorMessageBox.html");
	else
		_guihelper.MessageBox([[<div style="margin-top:24px;margin-left:10px;">你没有晶晶石，不能让我工作；赶紧去多克特博士营地找找吧！</div>]], 
		function() end, _guihelper.MessageBoxButtons.OK, nil, "script/apps/Aries/Desktop/GUIHelper/MagicMirrorMessageBox.html");
    end
end

function MagicMirrorPanelPage.OnClickCancel()
	page:CloseWindow();
end