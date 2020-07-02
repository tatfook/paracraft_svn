--[[
Title: code behind for page 30061_MagicMirror_panel.html
Author(s): LiXizhi, based on Andy's 30061_MagicMirror
Date: 2009/12/15
Desc:  script/apps/Aries/NPCs/SunnyBeach/30061_MagicMirror_panel.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/Color.lua");
local Color = commonlib.gettable("System.Core.Color");

local SkinBakerPanelPage = commonlib.gettable("MyCompany.Aries.SkinBakerPanelPage");

SkinBakerPanelPage.Choices = {
	hot_colors = {
		{ colormask="#ffffff"},
		{ colormask="#ffb3da"},
		{ colormask="#cdfc49"},
		{ colormask="#33b7fb"},
		{ colormask="#ffcbb3"},
		{ colormask="#dcfc7f"},
		{ colormask="#67c9fc"},
		{ colormask="#ffdced"},
		{ colormask="#ebffb3"},
		{ colormask="#b3e5ff"},
		{ colormask="#ffecdc"},
		{ colormask="#ebeef0"},
		{ colormask="#d1edfe"},
		{ colormask="#e2d7d8"},
		{ colormask="#c4c5b0"},
		{ colormask="#808080"},
		{ colormask="#606060"},
		{ colormask="#c5b0b2"},
		{ colormask="#999b76"},
		{ colormask="#6a8592"},
		{ colormask="#b0bec5"},
		{ colormask="#9b8076"},
		{ colormask="#7e926a"},
		{ colormask="#395c6e"},
		{ colormask="#6e4d39"},
		{ colormask="#696e39"},
		{ colormask="#68618b"},
		{ colormask="#a73f00"},
		{ colormask="#79a700"},
		{ colormask="#6e3956"},
		{ colormask="#9b769b"},
	},
};

SkinBakerPanelPage.UserChoice = {
	color_mask = nil,
	color_rgb = "#ffffff",
};

SkinBakerPanelPage.asset_table = {
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

function SkinBakerPanelPage.OnInit()
	page = document:GetPageCtrl();
	SkinBakerPanelPage.UserChoice.color_mask = nil;
	SkinBakerPanelPage.IsInit_ = true;
	SkinBakerPanelPage.RefreshAvatar_imp();
	SkinBakerPanelPage.IsInit_ = nil;
end

-- call this as many times as one like, it will only refresh after 300 ms. 
-- @param delayTime: milliseconds to delay before refreshing. 
function SkinBakerPanelPage.RefreshAvatar(delayTime)
	SkinBakerPanelPage.timer = SkinBakerPanelPage.timer or commonlib.Timer:new({callbackFunc = function(timer)
		SkinBakerPanelPage.RefreshAvatar_imp();
	end})
	SkinBakerPanelPage.timer:Change(delayTime or 300, nil)
end

function SkinBakerPanelPage.RefreshAvatar_imp()
	
	my_ccs_info = System.UI.CCS.GetCCSInfoString(nil, true);
	SkinBakerPanelPage.asset_table.CCSInfoStr = my_ccs_info;
	
	if(not my_ccs_info) then
		my_ccs_info = System.UI.CCS.GetCCSInfoString(ParaScene.GetPlayer());
	end
	local base_section, cartoonface_section, equip_section = string.match(my_ccs_info, "^(.+)@(.+)@(.+)$");
	
	if(base_section and cartoonface_section and equip_section) then
		local skin_color_mask;
		if(SkinBakerPanelPage.UserChoice.color_mask) then
			skin_color_mask = SkinBakerPanelPage.UserChoice.color_mask;
			skin_color_mask = string.gsub(skin_color_mask, "^#?0*", "");
			if(skin_color_mask == "ffffff") then
				skin_color_mask = "F"; -- skip default one
			end
		end
		
		commonlib.log("old facial string is %s\n", base_section)
		local skinColor, faceType, hairColor, hairStyle, facialHair = string.match(base_section, "([^#]+)#([^#]+)#([^#]+)#([^#]+)#([^#]*)#?");
		if(hairStyle) then
			-- facialHair is used for skin mask color
			if(skin_color_mask) then
				base_section = string.format("%s#%s#%s#%s#%s#", skinColor, faceType, hairColor, hairStyle, skin_color_mask);
			else
				-- obsent facial hair is the default skin. 
				-- base_section = string.format("%s#%s#%s#%s#", skinColor, faceType, hairColor, hairStyle);
				skin_color_mask = facialHair;
			end
		else	
			skin_color_mask = facialHair;
		end	
		
		SkinBakerPanelPage.asset_table.CCSInfoStr = base_section.."@"..cartoonface_section.."@"..equip_section;
		-- commonlib.log("Skin Baker: new ccs info str is:\n")
		-- commonlib.echo(SkinBakerPanelPage.asset_table.CCSInfoStr);
		
		mirror_ccs_info = base_section.."@"..cartoonface_section.."@";
		local canvasCtl = page:FindControl("MirrorAvatar");
		if(canvasCtl) then
			canvasCtl:ShowModel(SkinBakerPanelPage.asset_table);
		end
		
		-- update UI
		if(SkinBakerPanelPage.IsInit_) then
			SkinBakerPanelPage.UpdateHSLUI(skin_color_mask or "ffffff");
		end	
	end
end

function SkinBakerPanelPage.DS_Func_Skin_hot(index)
	if(index == nil) then
		return #(SkinBakerPanelPage.Choices.hot_colors);
	elseif(index) then
		return SkinBakerPanelPage.Choices.hot_colors[index];
	end
end

-- user picks a new color
function SkinBakerPanelPage.OnClickPickColor(color_mask)
	SkinBakerPanelPage.UpdateHSLUI(color_mask);
	
	SkinBakerPanelPage.UserChoice.color_mask = color_mask;
	-- commonlib.echo(SkinBakerPanelPage.UserChoice);
	SkinBakerPanelPage.RefreshAvatar(0);
end

function SkinBakerPanelPage.OnChangeHSLUI_hsl()
	local hue = page:GetValue("colorHue")
	local saturation = page:GetValue("colorSaturation")
	local lightness = page:GetValue("colorLightness")
	local r,g,b = Color.hsl2rgb(hue, saturation, lightness)
	--commonlib.echo({hue, saturation, lightness})
	--commonlib.echo({r,g,b, string.format("%02x%02x%02x", r,g,b)})
	
	SkinBakerPanelPage.UserChoice.color_mask = string.format("%02x%02x%02x", r,g,b);
	SkinBakerPanelPage.UpdateHSLUI(SkinBakerPanelPage.UserChoice.color_mask, true)
	SkinBakerPanelPage.RefreshAvatar(300);
end

-- Update HSL UI sliders according to a given RGB color. 
-- @param color: rgb string, such as "ffffff"
function SkinBakerPanelPage.UpdateHSLUI(color, bPreserveHSLValue)
	if(color == "F" or color == "1") then
		color = "ffffff";
	end
	commonlib.echo({color = color})
	color = string.gsub(color, "^#", "");
	-- add heading "0" to make a css style color string. 
	color = (string.rep("0", 6-string.len(color)) or "")..color;

	if(not last_color and last_color == color) then
		return;
	else	
		last_color = color;
	end
		
	local r,g,b = string.match(color, "(%x%x)(%x%x)(%x%x)");
	r = tonumber(r, 16);
	g = tonumber(g, 16);
	b = tonumber(b, 16);
	-- commonlib.echo({r=r,g=g,b=b})
	local hue, saturation, lightness = Color.rgb2hsl(r,g,b);
	
	if(not bPreserveHSLValue) then
		page:SetValue("colorHue", hue)
	end	
	
	local node = page:GetNode("saturation_color")
	if(node) then
		local r,g,b = Color.hsl2rgb(page:GetValue("colorHue") or hue,1,0.5);
		local colorS = string.format("%02x%02x%02x", r,g,b)
		-- commonlib.echo({color=color, r=r,g=g,b=b, colorS})
		node:SetAttribute("color", "#"..colorS)
		local color_block = page:FindControl("saturation_color");
		if(color_block and color_block:IsValid()) then
			_guihelper.SetUIColor(color_block, "#"..colorS);
		end
	end	
	
	if(not bPreserveHSLValue) then
		page:SetValue("colorSaturation", saturation)
	end	
	
	if(not bPreserveHSLValue) then
		page:SetValue("colorLightness", lightness)
	end	
	
	local node = page:GetNode("rgb_color_block")
	if(node) then
		node:SetAttribute("color", "#"..color)
		local color_block = page:FindControl("rgb_color_block");
		if(color_block and color_block:IsValid()) then
			_guihelper.SetUIColor(color_block, "#"..color);
		end
	end	
end

function SkinBakerPanelPage.OnClickOK()
	
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	
	-- 17029_CrystalRock
    local bHas_17029, guid_17029 = hasGSItem(17029, 12);
    if(bHas_17029) then
		_guihelper.MessageBox([[<div style="margin-top:24px;margin-left:10px;">需要一颗晶晶石供应能量,才能开始工作<br/>你愿意给我一颗晶晶石吗?</div>]], 
		function(result)
			if(_guihelper.DialogResult.OK == result) then
				local bHas, guid = hasGSItem(999);
				local ItemManager = System.Item.ItemManager;
				local hasGSItem = ItemManager.IfOwnGSItem;
				local bHas, guid = hasGSItem(999);
				if(bHas) then
					ItemManager.SetClientData(guid, mirror_ccs_info, function(msg) 
						if(msg.issuccess == true) then
							-- _guihelper.MessageBox([[<div style="margin-top:24px;margin-left:50px;">神奇的魔镜是不会让你失望的！<br/>快看看自己的新样子吧！</div>]]);
							page:CloseWindow();
							
							-- create effect
							local params = {
								asset_file = "character/v5/09effect/ChangeColor/ChangeColor.x",
								binding_obj_name = ParaScene.GetPlayer().name,
								duration_time = 2600,
								end_callback = function()
									end,
								stage1_time = 2000,
								stage1_callback = function()
									System.Item.ItemManager.RefreshMyself();
								end,
							};
							local EffectManager = MyCompany.Aries.EffectManager;
							EffectManager.CreateEffect(params);
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

function SkinBakerPanelPage.OnClickCancel()
	page:CloseWindow();
end