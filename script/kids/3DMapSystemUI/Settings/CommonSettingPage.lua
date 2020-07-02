--[[
Title: code behind of CommonSettingPage
Author(s): LiXizhi
Date: 2008.8.23
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Settings/CommonSettingPage.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");

-- create class
local CommonSettingPage = {};
commonlib.setfield("Map3DSystem.App.Settings.CommonSettingPage",  CommonSettingPage);
local page;
-- init
function CommonSettingPage.OnInit()
	page = document:GetPageCtrl();
	self = page;
	-- load the current settings. 
	local att = ParaEngine.GetAttributeObject();
	self:SetNodeValue("checkBoxFullScreenMode", att:GetField("IsFullScreenMode", false))
	self:SetNodeValue("comboBoxMultiSampleType", tostring(att:GetField("MultiSampleType", 0)))
	self:SetNodeValue("comboBoxMultiSampleQuality", tostring(att:GetField("MultiSampleQuality", 0)))
	
	self:SetNodeValue("checkBoxInverseMouse", att:GetField("IsMouseInverse", false))
	local size = att:GetField("ScreenResolution", {1024,768});
	self:SetNodeValue("comboBoxScreenResolution", string.format("%d × %d", size[1], size[2]))
	self:SetNodeValue("graphic_quality", tostring(att:GetField("Effect Level", 0)))
	self:SetNodeValue("texture_lod", tostring(att:GetField("TextureLOD", 0)))
	
	local att = ParaScene.GetAttributeObject();
	self:SetNodeValue("checkBoxUseShadow", att:GetField("SetShadow", false))
	self:SetNodeValue("checkBoxUseGlow", att:GetField("FullScreenGlow", false))
	self:SetNodeValue("trackBarViewDistance", ParaCamera.GetAttributeObject():GetField("FarPlane", 120))
	self:SetNodeValue("trackBarVolume", ParaAudio.GetBGMusicVolume())
	
	local att = ParaScene.GetAttributeObjectOcean();
	self:SetNodeValue("checkBoxTerrainReflection", att:GetField("EnableTerrainReflection", false))
	self:SetNodeValue("comboBoxObjectReflection", att:GetField("EnableMeshReflection", false))
	self:SetNodeValue("checkBoxPlayerReflection", att:GetField("EnablePlayerReflection", false))
	self:SetNodeValue("checkBoxCharacterReflection", att:GetField("EnableCharacterReflection", false))
	
	self:SetNodeValue("comboBoxLocale", ParaEngine.GetLocale())
end

-- save settings. 
function CommonSettingPage.OnSaveGraphics(name, values)
	local bNeedUpdateScreen,value, bNeedRestart;
	
	-- load the current settings. 
	local att = ParaEngine.GetAttributeObject();
	value = values["checkBoxFullScreenMode"];
	bNeedUpdateScreen = bNeedUpdateScreen or (att:GetField("IsFullScreenMode",false) ~= value);
	att:SetField("IsFullScreenMode", value);
	
	value = tonumber(values["comboBoxMultiSampleType"]);
	bNeedRestart = bNeedRestart or (att:GetField("MultiSampleType",0) ~= value);
	att:SetField("MultiSampleType", value);
	
	value = tonumber(values["comboBoxMultiSampleQuality"]);
	bNeedRestart = bNeedRestart or (att:GetField("MultiSampleQuality",0) ~= value);
	att:SetField("MultiSampleQuality", value);
	
	
	value = values["comboBoxScreenResolution"];
	local _,_, x,y = string.find(value, "(%d+)%D+(%d+)");
	if(x~=nil and y~=nil) then
		x = tonumber(x)
		y = tonumber(y)
		if(x~=nil and y~=nil) then
			local size = {x, y};
			
			local oldsize = att:GetField("ScreenResolution", {1024,768});
			if(oldsize[1] ~=x or oldsize[2]~= y) then
				bNeedUpdateScreen = true;
			end	
			att:SetField("ScreenResolution", size);
		end
	end
	
	att:SetField("Effect Level", tonumber(values["graphic_quality"]))
	att:SetField("TextureLOD", tonumber(values["texture_lod"]))
	
	
	local att = ParaScene.GetAttributeObject();
	
	att:SetField("SetShadow", values["checkBoxUseShadow"])
	att:SetField("FullScreenGlow", values["checkBoxUseGlow"])
	
	local FarPlane = values["trackBarViewDistance"];
	att:SetField("FogEnd", FarPlane*0.5);
	att:SetField("FogStart", FarPlane*0.4);
	ParaCamera.GetAttributeObject():SetField("FarPlane", FarPlane);
	
	local att = ParaScene.GetAttributeObjectOcean();
	att:SetField("EnableTerrainReflection", values["checkBoxTerrainReflection"])
	att:SetField("EnableMeshReflection", values["comboBoxObjectReflection"])
	att:SetField("EnablePlayerReflection", values["checkBoxPlayerReflection"])
	att:SetField("EnableCharacterReflection", values["checkBoxCharacterReflection"])

	if(values["comboBoxLocale"] ~= ParaEngine.GetLocale()) then
		ParaEngine.SetLocale(values["comboBoxLocale"])
		bNeedRestart = true;
	end	

	if(bNeedUpdateScreen) then
		_guihelper.MessageBox("您的显示设备即将改变:如果您的显卡不支持,可能会出现异常。是否继续?", function ()
			ParaEngine.GetAttributeObject():CallField("UpdateScreenMode");
			-- we will save to "config.new.txt", so the next time the game engine is started, it will ask the user to preserve or not. 
			ParaEngine.WriteConfigFile("config/config.new.txt");
		end)
	else
		ParaEngine.WriteConfigFile("config/config.new.txt");	
	end
	
	if(page) then
		if(not bNeedRestart) then
			page:SetUIValue("graphics_result", "保存成功")
		else
			page:SetUIValue("graphics_result", "保存成功, 某些设置需要重启才能生效")
		end
	end
end

-- save settings. 
function CommonSettingPage.OnSaveSounds(name, values)
	local value;
	local att = ParaScene.GetAttributeObject();
	value = values["trackBarVolume"];
	-- set all volumes
	ParaAudio.SetBGMusicVolume(value);
	ParaAudio.SetDialogVolume(value);
	ParaAudio.SetAmbientSoundVolume(value);
	ParaAudio.SetUISoundVolume(value);
	ParaAudio.Set3DSoundVolume(value);
	ParaAudio.SetInteractiveSoundVolume(value);
			
	ParaEngine.WriteConfigFile("config/config.txt");
	page:SetUIValue("sounds_result", "保存成功")
end

-- save settings. 
function CommonSettingPage.OnSaveControl(name, values)
	local value;
	
	local att = ParaEngine.GetAttributeObject();
	att:SetField("IsMouseInverse", values["checkBoxInverseMouse"]);
	
	ParaEngine.WriteConfigFile("config/config.txt");
	page:SetUIValue("control_result", "保存成功")
end

function CommonSettingPage.OnDeleteCacheFile()
	_guihelper.MessageBox("你确定要删除HTTP临时文件么?", function()
		ParaIO.DeleteFile("temp/cache/*.*");
		ParaIO.DeleteFile("temp/tempdatabase/*.*");
		ParaIO.DeleteFile("temp/tempdownloads/*.*");
	end)
end
function CommonSettingPage.OnDeleteCacheCharTexFile()
	_guihelper.MessageBox("你确定要删除贴图临时文件么?", function()
		ParaIO.DeleteFile("temp/composeface/*.*");
		ParaIO.DeleteFile("temp/composeskin/*.*");
	end)
end
function CommonSettingPage.OnDeleteCacheLocalServer()
	_guihelper.MessageBox("你确定要删除历史记录临时文件么?", function()
		-- TODO: 
		--ParaIO.DeleteFile("database/localserver.db");
		--ParaIO.DeleteFile("temp/webcache/*.*");
	end)
end
function CommonSettingPage.OnDeleteCacheAll()
	_guihelper.MessageBox("你确定要删除所有临时文件么?", function()
		ParaIO.DeleteFile("temp/cache/*.*");
		ParaIO.DeleteFile("temp/composeface/*.*");
		ParaIO.DeleteFile("temp/composeskin/*.*");
	end)
end