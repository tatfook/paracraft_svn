--[[
Title: code behind for page SmileySelector.html
Author(s): WangTian
Date: 2009/5/4
Desc:  script/apps/Aries/Desktop/SmileySelector.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
local ChatEdit = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatEdit");

local SmileySelectorPage = commonlib.gettable("MyCompany.Aries.Desktop.SmileySelectorPage");

-- animated or static smileys
local smileys = {
	--[1] = "Texture/Aries/Smiley/face01_32bits.png",
	--[2] = "Texture/Aries/Smiley/face02_32bits.png",
	--[3] = "Texture/Aries/Smiley/face03_32bits.png",
	--[4] = "Texture/Aries/Smiley/face04_32bits.png",
	--[5] = "Texture/Aries/Smiley/face05_32bits.png",
	--[6] = "Texture/Aries/Smiley/face06_32bits.png",
	--[7] = "Texture/Aries/Smiley/face07_32bits.png",
	--[8] = "Texture/Aries/Smiley/face08_32bits.png",
	--[9] = "Texture/Aries/Smiley/face09_32bits.png",
	--[10] = "Texture/Aries/Smiley/face10_32bits.png",
	--[11] = "Texture/Aries/Smiley/face11_32bits.png",
	--[12] = "Texture/Aries/Smiley/face12_32bits.png",
	--[13] = "Texture/Aries/Smiley/face13_32bits.png",
	--[14] = "Texture/Aries/Smiley/face14_32bits.png",
	--[15] = "Texture/Aries/Smiley/face15_32bits.png",
	
	"Texture/Aries/Smiley/face01_32bits.png",
	"Texture/Aries/Smiley/animated/face02_32bits_fps10_a003.png",
	"Texture/Aries/Smiley/animated/face03_32bits_fps10_a003.png",
	"Texture/Aries/Smiley/animated/face04_32bits_fps10_a005.png",
	"Texture/Aries/Smiley/animated/face05_32bits_fps10_a004.png",
	"Texture/Aries/Smiley/animated/face06_32bits_fps10_a003.png",
	"Texture/Aries/Smiley/animated/face07_32bits_fps10_a003.png",
	"Texture/Aries/Smiley/animated/face08_32bits_fps10_a005.png",
	"Texture/Aries/Smiley/animated/face09_32bits_fps10_a005.png",
	"Texture/Aries/Smiley/animated/face10_32bits_fps10_a005.png",
	"Texture/Aries/Smiley/animated/face11_32bits_fps10_a004.png",
	"Texture/Aries/Smiley/face12_32bits.png",
	"Texture/Aries/Smiley/animated/face13_32bits_fps10_a003.png",
	"Texture/Aries/Smiley/face14_32bits.png",
	"Texture/Aries/Smiley/face15_32bits.png",
};

-- data source for head slot items
function SmileySelectorPage.DS_Func_Smileys(index)
	if(index ~= nil and index <= #(smileys)) then
		return {background = smileys[index], ID = index};
	elseif(index ~= nil and index <= 15) then
		return {background = "", ID = index};
	elseif(index == nil) then
		return 15;
	end
end



-- purchase the item directly from global store
function SmileySelectorPage.Show(index)
	--_guihelper.MessageBox(index);
	
	if(index > #(smileys)) then
		return;
	end
	
	local str_MCML = string.format([[<img style="margin-left:6px;width:64px;height:64px;background:url(%s)" />]], smileys[tonumber(index)]);
	
	-- force sending to nearby players(second param is 1)
	ChatEdit.SendTextSilent(str_MCML, ChatChannel.EnumChannels.NearBy)

	MyCompany.Aries.Desktop.Dock.OnClickSmiley(false);
end