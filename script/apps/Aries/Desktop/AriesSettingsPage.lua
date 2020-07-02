--[[
Title: code behind for page AriesSettingsPage.html
Author(s): LiXizhi
Date: 2009/10/18
Desc:  script/apps/Aries/Desktop/AriesSettingsPage.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/AriesSettingsPage.lua");
MyCompany.Aries.Desktop.AriesSettingsPage.AutoAdjustGraphicsSettings(true, function(bChanged) end)
local stats = MyCompany.Aries.Desktop.AriesSettingsPage.GetPCStats()
MyCompany.Aries.Desktop.AriesSettingsPage.DoCheckMinimumSystemRequirement();
-------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/Scene/main.lua");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");

local AriesSettingsPage = commonlib.gettable("MyCompany.Aries.Desktop.AriesSettingsPage");

local recommended_resolution = {1020,595}
local recommended_resolution_web_browser = {960,560}
local recommended_resolution_teen = {1280,760}


local page;
-- purchase the item directly from global store
function AriesSettingsPage.OnInit()
	page = document:GetPageCtrl();
	page.OnClose = AriesSettingsPage.OnClose;
	
	-- load the current settings. 
	local att = ParaEngine.GetAttributeObject();
	page:SetNodeValue("checkBoxFullScreenMode", att:GetField("IsFullScreenMode", false))
	page:SetNodeValue("comboBoxMultiSampleType", tostring(att:GetField("MultiSampleType", 0)))
	page:SetNodeValue("comboBoxMultiSampleQuality", tostring(att:GetField("MultiSampleQuality", 0)))
	
	page:SetNodeValue("checkBoxInverseMouse", att:GetField("IsMouseInverse", false))
	page:SetNodeValue("graphic_quality", tostring(att:GetField("Effect Level", 0)))
	page:SetNodeValue("ScreenResolution", string.format("%d × %d", att:GetDynamicField("ScreenWidth", 1020), att:GetDynamicField("ScreenHeight", 680)))
	page:SetNodeValue("TotalDragTime", att:GetField("TotalDragTime", 0));
	page:SetNodeValue("SmoothFramesNum", att:GetField("SmoothFramesNum", 0));
	-- page:SetNodeValue("texture_lod", tostring(att:GetField("TextureLOD", 0)))
	
	page:SetNodeValue("checkBoxFreeWindowSize", not att:GetField("IgnoreWindowSizeChange", true))
	
	local AutoCameraController = commonlib.gettable("MyCompany.Aries.AutoCameraController");
	if(AutoCameraController.IsEnabled) then
		page:SetNodeValue("checkBoxLockCamera", AutoCameraController:IsEnabled())
	end

	local att = ParaScene.GetAttributeObject();
	page:SetNodeValue("checkBoxUseShadow", att:GetField("SetShadow", false))
	-- page:SetNodeValue("checkBoxUseGlow", att:GetField("FullScreenGlow", false))
	page:SetNodeValue("trackBarViewDistance", ParaCamera.GetAttributeObject():GetField("FarPlane", 120))
	page:SetNodeValue("trackBarVolume", ParaAudio.GetVolume())
	page:SetNodeValue("EnableSound", ParaAudio.GetVolume()>0)

	local bChecked = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.EnableBackgroundMusic",true, true);
	page:SetNodeValue("EnableBackgroundMusic", bChecked);

	local bChecked = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.hide_family_name",false);
	page:SetNodeValue("hide_family_name", bChecked);

	page:SetNodeValue("checkBoxShowHeadOnDisplay", att:GetField("ShowHeadOnDisplay", true))
	local bChecked = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.checkBoxEnableTeamInvite",true);
	page:SetNodeValue("checkBoxEnableTeamInvite", bChecked);

	local bChecked = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.checkBoxEnableHeadonTextScaling",true);
	page:SetNodeValue("checkBoxEnableHeadonTextScaling", bChecked);

	local bChecked = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.checkBoxAllowAddFriend",true);
	page:SetNodeValue("checkBoxAllowAddFriend", bChecked);

	local bChecked = System.options.EnableFriendTeleport;
	page:SetNodeValue("checkBoxEnableFriendTeleport", bChecked);
	
	local bChecked = System.options.EnableAutoPickSingleTarget;
	page:SetNodeValue("checkBoxEnableAutoPickSingleTarget", bChecked);
	
	local bChecked = System.options.EnableForceHideHead;
	page:SetNodeValue("checkBoxEnableForceHideHead", bChecked);
	
	local bChecked = System.options.EnableForceHideBack;
	page:SetNodeValue("checkBoxEnableForceHideBack", bChecked);

	local FamilyChatWnd = commonlib.gettable("MyCompany.Aries.Chat.FamilyChatWnd");
	page:SetNodeValue("checkBoxDisableFamilyChat", FamilyChatWnd.is_blocked);
	
	local bChecked = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.checkBoxAutoHPPotion",true);
	page:SetNodeValue("checkBoxAutoHPPotion", bChecked);
	
	if(System.options.version=="teen") then
		NPL.load("(gl)script/apps/Aries/Desktop/Dock/LoopTips.lua");
		local LoopTips = commonlib.gettable("MyCompany.Aries.Desktop.LoopTips");
		page:SetNodeValue("checkBoxRightBottomTips", LoopTips.is_expanded);
	end
end

function AriesSettingsPage.OnClose()
end

-- shader version
local function GetShaderVersion()
	local stats = AriesSettingsPage.GetPCStats();
	local ps_Version = stats.ps;
	local vs_Version = stats.vs;
	local shader_version = 0;
	if(vs_Version > ps_Version) then
		shader_version = ps_Version;
	else
		shader_version = vs_Version;
	end
	return shader_version;
end

local min_requirement_data = nil;

function AriesSettingsPage.onclickShowHeadOnDisplay(bChecked)
    ParaScene.GetAttributeObject():SetField("ShowHeadOnDisplay", bChecked);
end

function AriesSettingsPage.onclickFreeWindowSize(bChecked)
    ParaEngine.GetAttributeObject():SetField("IgnoreWindowSizeChange", not bChecked);
end

function AriesSettingsPage.checkBoxEnableTeamInvite(bChecked)
	MyCompany.Aries.Player.SaveLocalData("AriesSettingsPage.checkBoxEnableTeamInvite", bChecked);
end

function AriesSettingsPage.checkBoxDisableFamilyChat(bChecked)
	-- MyCompany.Aries.Player.SaveLocalData("AriesSettingsPage.checkBoxDisableFamilyChat", bChecked);
	NPL.load("(gl)script/apps/Aries/Chat/FamilyChatWnd.lua");
	local FamilyChatWnd = commonlib.gettable("MyCompany.Aries.Chat.FamilyChatWnd");
	FamilyChatWnd.BlockChat(bChecked);
end

function AriesSettingsPage.checkBoxAutoHPPotion(bChecked)
	MyCompany.Aries.Player.SaveLocalData("AriesSettingsPage.checkBoxAutoHPPotion", bChecked);
end

function AriesSettingsPage.checkBoxEnableHeadonTextScaling(bChecked)
	MyCompany.Aries.Player.SaveLocalData("AriesSettingsPage.checkBoxEnableHeadonTextScaling", bChecked);
	ParaScene.GetAttributeObject():SetField("HeadOn3DScalingEnabled", bChecked);
end

function AriesSettingsPage.checkBoxAllowAddFriend(bChecked)
	MyCompany.Aries.Player.SaveLocalData("AriesSettingsPage.checkBoxAllowAddFriend", bChecked);
	System.options.isAllowAddFriend = bChecked;
end


function AriesSettingsPage.checkBoxEnableFriendTeleport(bChecked)
	System.options.EnableFriendTeleport = bChecked;
	MyCompany.Aries.Player.SaveLocalData("AriesSettingsPage.EnableFriendTeleport", bChecked);
	ParaScene.GetAttributeObject():SetField("checkBoxEnableFriendTeleport", bChecked);
end

function AriesSettingsPage.checkBoxEnableAutoPickSingleTarget(bChecked)
	System.options.EnableAutoPickSingleTarget = bChecked;
	MyCompany.Aries.Player.SaveLocalData("AriesSettingsPage.EnableAutoPickSingleTarget", bChecked);
	ParaScene.GetAttributeObject():SetField("checkBoxEnableAutoPickSingleTarget", bChecked);
end

function AriesSettingsPage.checkBoxEnableForceHideHead(bChecked)
	System.options.EnableForceHideHead = bChecked;
	MyCompany.Aries.Player.SaveLocalData("AriesSettingsPage.EnableForceHideHead", bChecked);
	ParaScene.GetAttributeObject():SetField("checkBoxEnableForceHideHead", bChecked);
	-- force refresh avatar
	System.Item.ItemManager.RefreshMyself();
end

function AriesSettingsPage.checkBoxEnableForceHideBack(bChecked)
	System.options.EnableForceHideBack = bChecked;
	MyCompany.Aries.Player.SaveLocalData("AriesSettingsPage.EnableForceHideBack", bChecked);
	ParaScene.GetAttributeObject():SetField("checkBoxEnableForceHideBack", bChecked);
	-- force refresh avatar
	System.Item.ItemManager.RefreshMyself();
end

function AriesSettingsPage.onclickLockCamera(bChecked)
    MyCompany.Aries.AutoCameraController:MakeEnable(bChecked); 
end

function AriesSettingsPage.checkBoxRightBottomTips(bChecked)
	NPL.load("(gl)script/apps/Aries/Desktop/Dock/LoopTips.lua");
	local LoopTips = commonlib.gettable("MyCompany.Aries.Desktop.LoopTips");
	LoopTips.OnCheckExpandBtn(bChecked)
end

-- check if minimum requirement is met to run the game. 
-- @param bShowUI: true to display UI when minimum requirement is not met. 
-- @param callbackFunc: the callback function (result, msg, bContinue)  end, in case bShowUI is true. the callback is called after user has clicked OK;
-- @return result, msg: There are three possible outcome: 1 user is qualified to run; 0 user is not fully qualified to run but can run in low resolution mode; -1 can not run no matter what. 
-- Text message is also shown to the user. 
function AriesSettingsPage.CheckMinimumSystemRequirement(bShowUI, callbackFunc)
	
	local result = 1;
	local sMsg = "";
	if(System.options.IsMobilePlatform or System.options.IsTouchDevice) then
		-- skip for mobile platform check
	else
		min_requirement_data = {};
		local function SetResult(res, msg)
			if(result>res) then
				result = res;
				min_requirement_data.result = res;
			end
			if(msg) then
				min_requirement_data.sMsg = sMsg.."<br/>"..msg;
				sMsg = sMsg.."\n"..msg;
			end
		end

		local stats = AriesSettingsPage.GetPCStats();
		if(stats.memory and stats.memory<500) then
			if(stats.memory<300) then
				SetResult(-1, "您的电脑内存太小了");
			else
				SetResult(0, "您的电脑内存太小了");
			end
		end
	
		if(stats.ps<2 or stats.vs < 2) then
			SetResult(0, "您的电脑显卡太旧了");
		end

		if(bShowUI) then
			-- TODO: FOR testing, set result to 0 or -1
			-- SetResult(0, "您的电脑显卡太旧了<br/>您的电脑内存太小了");
			if(result<=0) then
				local params = {
					url = "script/apps/Aries/Desktop/AriesMinRequirementPage.html", 
					name = "AriesMinRequirementWnd", 
					isShowTitleBar = false,
					DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
					style = CommonCtrl.WindowFrame.ContainerStyle,
					zorder = 2,
					isTopLevel = true,
					directPosition = true,
						align = "_ct",
						x = -550/2,
						y = -380/2,
						width = 550,
						height = 380,
				}
				System.App.Commands.Call("File.MCMLWindowFrame", params);
				params._page.OnClose = function()
					if(callbackFunc) then
						callbackFunc(result, sMsg);
					end
				end
				return result, sMsg;
			end
		end
	end
	if(callbackFunc) then
		callbackFunc(result, sMsg);
	end
	return result, sMsg;
end

-- get a table containing all kinds of stats for this computer. 
-- @return {videocard, os, memory, ps, vs}
function AriesSettingsPage.GetPCStats()
	NPL.load("(gl)script/ide/System/os/os.lua");
	return System.os.GetPCStats();
end

--return monitor resolution
--return width,height
function AriesSettingsPage.GetMonitorResolution()
	local att = ParaEngine.GetAttributeObject();
	local res = att:GetField("MonitorResolution",{1024,768})
	return res[1], res[2];
end

--return all supported display mode
--return value: { {width,height,refreshRate},{width,height,refreshRate}...}
function AriesSettingsPage.GetSupportDisplayMode()
	local att = ParaEngine.GetAttributeObject();
	local displayStr = att:GetField("DisplayMode","");
	if(displayStr == "")then
		return nil;
	end
	
	local result = {};
	local match;
	for match in string.gmatch(displayStr,"%d+ %d+ %d+") do
		local displayMode = {};
		displayMode.width,displayMode.height,displayMode.refreshRate = string.match(match,"(%d+) (%d+) (%d+)");
		table.insert(result,displayMode);
	end
	return result;
end

-- get a table containing {result, sMsg} as in CheckMinimumSystemRequirement;
function AriesSettingsPage.GetMinRequirementData()
	if(not min_requirement_data) then
		AriesSettingsPage.CheckMinimumSystemRequirement();
	end
	return min_requirement_data;
end

-- automatically adjust according to current graphics card shader version. 
-- @param bShowUI: true to display UI for user confirmation. 
-- @param callbackFunc: the callback function when settings have been adjusted. function(bChanged)  end
-- @param OnChangeCallback: nil or a callback function that is invoked before changes are applied. 
-- It gives the caller a chance to drop any changes made by returning false. e.g. in web edition, we can not modified changes directly,instead we need to invoke via IPC to change. 
function AriesSettingsPage.AutoAdjustGraphicsSettings(bShowUI, callbackFunc, OnChangeCallback)
	if(System.os.GetPlatform()~="win32" or System.options.IsTouchDevice) then
		-- skip this for mobile and touch device
		if(type(callbackFunc) == "function") then
			callbackFunc(false);
		end
		return;
	end

	local att = ParaEngine.GetAttributeObject();
	local shader_version = GetShaderVersion();
	
	NPL.load("(gl)script/apps/Aries/Player/main.lua");
	local is_user_confirmed = MyCompany.Aries.Player.LoadLocalData("user_confirmed", false, true);
	
	local effect_level = att:GetField("Effect Level", 0);
	local screen_resolution = att:GetField("ScreenResolution", {800, 600}); 
	local new_screen_resolution;
	local new_effect_level;
	local use_terrain_normal;

	-- uncomment to test a given setting. 
	-- local new_screen_resolution = {400,300};
	-- local new_effect_level = 0;
	
	if(shader_version < 3) then
		-- for shader version smaller than 2, use 800*600 as default. 
		if(screen_resolution[1] > 800) then
			new_screen_resolution = {800, 533}
		end
		
		if(shader_version < 2) then
			if(effect_level ~= 1024) then
				new_effect_level = 1024;
			end
		elseif(shader_version < 3) then	
			if(effect_level > 0 and effect_level<100) then
				new_effect_level = 0;
			end
		end
		-- if video card is old, we will not use 32bits textures, which saves lots of video memory. 
		ParaEngine.GetAttributeObject():SetField("Is32bitsTextureEnabled", false)
		ParaScene.GetAttributeObjectOcean():SetField("IsAnimateFFT", false);
		use_terrain_normal = false;
	end

	local stats = AriesSettingsPage.GetPCStats();
	-- local test_low_memory = true; -- comment this at release time
	if(test_low_memory) then
		LOG.warn("this test line should be removed");
		stats.memory = 512;
	end
	
	local res_width, res_height = AriesSettingsPage.GetMonitorResolution();
	if(System.options.version=="teen") then
		NPL.load("(gl)script/apps/Aries/Player/main.lua");

		if(att:GetField("IsFullScreenMode",false) == false) then
			-- windowed mode
			recommended_resolution = recommended_resolution_teen;	
			if((res_width-60)<recommended_resolution[1]) then
				recommended_resolution[1] = res_width - 60;
			end
			if((res_height-80)<recommended_resolution[2]) then
				recommended_resolution[2] = res_height - 80;
			end
		end
	end
	recommended_resolution[1] = math.min(res_width, recommended_resolution[1]);
	recommended_resolution[2] = math.min(res_height, recommended_resolution[2]);

	if(System.options.IsWebBrowser) then
		recommended_resolution = recommended_resolution_web_browser;

		if(screen_resolution[1]>recommended_resolution[1] or screen_resolution[1] > recommended_resolution[2]) then
			-- for web version, the maximum resolution for web to start initially is this.  
			new_screen_resolution = recommended_resolution;
		end
	end

	if(shader_version >= 3 and effect_level == 0) then
		if(stats.memory and stats.memory>2000) then
			-- if shader version is high and physical memory is large, we will enable mesh reflection when effect level is high. 
			ParaScene.GetAttributeObjectOcean():SetField("EnableMeshReflection", true)
		end
	end
	
	-- if system memory is small, we will not use 32bits textures. 
	if(stats.memory and stats.memory < 600) then
		ParaEngine.GetAttributeObject():SetField("Is32bitsTextureEnabled", false);
		use_terrain_normal = false;
	end
	if(stats.memory and stats.memory < 2000) then
		-- we will assume memory over 2G is high end computer, so only animate FFT on it.  
		ParaScene.GetAttributeObjectOcean():SetField("IsAnimateFFT", false);
	end
	if(use_terrain_normal == false) then
		ParaTerrain.GetAttributeObject():SetField("UseNormals", false);
	end

	if(shader_version >= 3 and stats.memory>2000) then
		-- this allows us to change the resolution by dragging the window size. 
		ParaEngine.GetAttributeObject():SetField("IgnoreWindowSizeChange", false);
		-- only set when the computer is pretty cool. 
		
		if(not stats.IsFullScreenMode) then
			if(not System.options.IsWebBrowser) then
				if(screen_resolution[1]<recommended_resolution[1] or screen_resolution[1] < recommended_resolution[2]) then
					-- this is the recommended resolution for good computers with shader 3 and memory >2GB
					new_screen_resolution = recommended_resolution;
				end
			end
		end
		LOG.std(nil, "system", "settings", "enabled render resolution matching with window size, because your system is good enough.");
	end

	if(is_user_confirmed) then
		-- tricky: if the user has already confirmed changing the resolution, we will ignore auto modifications. 
		-- such that user can use a smaller or bigger resolution or effect regardless of its hardware. 
		new_effect_level =nil;
		if(not System.options.IsWebBrowser) then
			new_screen_resolution = nil;
		end
	end

	if(System.options.open_resolution) then
		local w,h = string.match(System.options.open_resolution,"(%d+)[^%d]+(%d+)");
		new_screen_resolution = {tonumber(w),tonumber(h)};
	end

	if(new_effect_level or new_screen_resolution) then
		local function ApplyChanges()
			local bApplyChange = true;
			if(OnChangeCallback) then
				local params = {
					shader_version = shader_version, -- number
					new_effect_level = new_effect_level, -- number
					new_screen_resolution = new_screen_resolution, -- nil or {x,y}
				}
				bApplyChange = (OnChangeCallback(params)~=false)
			end
			if(bApplyChange) then
				if(new_screen_resolution) then
					if(System.options.IsWebBrowser) then
						commonlib.app_ipc.ActivateHostApp("change_resolution", nil, new_screen_resolution[1], new_screen_resolution[2]);
					else	
						att:SetField("ScreenResolution", new_screen_resolution); 
					end	
				end	
				if(new_effect_level) then
					AriesSettingsPage.AdjustGraphicsSettingsByEffectLevel(new_effect_level)
					if(use_terrain_normal == false) then
						ParaEngine.GetAttributeObject():SetField("UseNormals", use_terrain_normal);
					end
				end
				if(new_screen_resolution) then
					att:CallField("UpdateScreenMode");
				end	
				ParaEngine.WriteConfigFile("config/config.txt");
				if(type(callbackFunc) == "function") then
					callbackFunc(true);
				end
			else
				callbackFunc(false);
			end	
		end
		
		if(bShowUI) then
			local text;
			if(new_effect_level == 1024) then
				_guihelper.MessageBox("为了更好的运行程序, 我们建议您购买新的3D显卡。我们即将自动为您调整为最低的3D画面质量", function(res)
					ApplyChanges();
				end, _guihelper.MessageBoxButtons.OK)
			else
				_guihelper.MessageBox("我们发现您的计算机显卡比较旧, 为了更好的运行程序, 您是否希望我们自动为您调整为较低的画面质量？", function(res)
					if(res and res == _guihelper.DialogResult.Yes) then
						ApplyChanges();
					else
						if(type(callbackFunc) == "function") then
							callbackFunc(false);
						end
					end	
				end, _guihelper.MessageBoxButtons.YesNo)
			end
			
		else
			ApplyChanges();
		end
	else
		if(type(callbackFunc) == "function") then
			callbackFunc(false);
		end
	end
end

-- set graphics settings by effect level.  This function can be called at the beginning. 
-- @param value: -1024, -1, 0,1,2
function AriesSettingsPage.AdjustGraphicsSettingsByEffectLevel(effect_level)
	local att = ParaEngine.GetAttributeObject();
	local att_ocean = ParaScene.GetAttributeObjectOcean();
	
	local FarPlane = 420;
	att:SetField("Effect Level", effect_level);
	
	local shader_version = GetShaderVersion();
	
	if(effect_level == 1024) then
		att:SetField("TextureLOD", 1);
		att:SetField("SetShadow", false);
		
		att_ocean:SetField("EnableTerrainReflection", false)
		att_ocean:SetField("EnableMeshReflection", false)
		att_ocean:SetField("EnablePlayerReflection", false)
		att_ocean:SetField("EnableCharacterReflection", false)
		
		FarPlane = 100;
				
	elseif(effect_level == -1) then
		att:SetField("TextureLOD", 1);
		att:SetField("SetShadow", false);
	
		att_ocean:SetField("EnableTerrainReflection", false)
		att_ocean:SetField("EnableMeshReflection", false)
		att_ocean:SetField("EnablePlayerReflection", false)
		att_ocean:SetField("EnableCharacterReflection", false)
		
		FarPlane = 120;
		
	elseif(effect_level == 0) then
		att:SetField("TextureLOD", 0);
		att:SetField("SetShadow", false);
	
		att_ocean:SetField("EnableTerrainReflection", false)
		att_ocean:SetField("EnableMeshReflection", false)
		att_ocean:SetField("EnablePlayerReflection", false)
		att_ocean:SetField("EnableCharacterReflection", false)
		
		if(shader_version > 2) then
			FarPlane = 420;
		else
			FarPlane = 220;
		end	
		
	elseif(effect_level == 1) then
		att:SetField("TextureLOD", 0);
		att:SetField("SetShadow", true);
	
		att_ocean:SetField("EnableTerrainReflection", true)
		att_ocean:SetField("EnableMeshReflection", true)
		att_ocean:SetField("EnablePlayerReflection", false)
		att_ocean:SetField("EnableCharacterReflection", false)
		
		FarPlane = 420;
		
	elseif(effect_level == 2) then
		att:SetField("TextureLOD", 0);
		att:SetField("SetShadow", true);
		
		att_ocean:SetField("EnableTerrainReflection", true)
		att_ocean:SetField("EnableMeshReflection", true)
		att_ocean:SetField("EnablePlayerReflection", true)
		att_ocean:SetField("EnableCharacterReflection", true)
		
		FarPlane = 420;
	end

	att:SetField("UseDropShadow", not att:GetField("SetShadow", false));
	
	if(FarPlane) then
		local FarPlane_range = {from=100,to=420}
		local FogStart_range = {from=50,to=80}
		local FogEnd_range	 = {from=70,to=130}
		
		value = (FarPlane-FarPlane_range.from) / (FarPlane_range.to- FarPlane_range.from);
		att:SetField("FogEnd", FogEnd_range.from + (FogEnd_range.to - FogEnd_range.from) * value);
		att:SetField("FogStart", FogStart_range.from + (FogStart_range.to - FogStart_range.from) * value);
		ParaCamera.GetAttributeObject():SetField("FarPlane", FarPlane);
	end	
end

function AriesSettingsPage.OnClickEnableSound(bChecked)
	if(page)then
		if(bChecked == true) then
			page:SetValue("trackBarVolume", 1)
			ParaAudio.SetVolume(1);
		else
			page:SetValue("trackBarVolume", 0)
			ParaAudio.SetVolume(0);
		end
	end
	local MapArea = commonlib.gettable("MyCompany.Aries.Desktop.MapArea");
	if(MapArea.EnableMusic) then
		MapArea.EnableMusic(bChecked);
	end
end

function AriesSettingsPage.OnClickEnableBackgroundMusic(bChecked)
	MyCompany.Aries.Player.SaveLocalData("AriesSettingsPage.EnableBackgroundMusic", bChecked, true)
	System.options.EnableBackgroundMusic = bChecked;
	if(bChecked) then
		Scene.ResumeRegionBGMusic()
	else
	    Scene.StopRegionBGMusic();
	end
end

function AriesSettingsPage.OnClick_hide_family_name(bChecked)
	MyCompany.Aries.Player.SaveLocalData("AriesSettingsPage.hide_family_name", bChecked)
	System.options.hide_family_name = bChecked;

	MyCompany.Aries.Player.ShowHeadonTextForNID(tostring(System.User.nid));

	local nid, agent;
	for nid, agent in System.GSL_client:EachAgent() do
		if(agent:has_avatar()) then
			MyCompany.Aries.Player.ShowHeadonTextForNID(nid);
		end
	end
end

function AriesSettingsPage.OnClickEnableSound_ByArea(bChecked)
	if(page)then
		if(bChecked == true) then
			page:SetValue("trackBarVolume", 1)
			ParaAudio.SetVolume(1);
		else
			page:SetValue("trackBarVolume", 0)
			ParaAudio.SetVolume(0);
		end
		page:SetValue("EnableSound", bChecked);
	end
end
function AriesSettingsPage.OnOK()
	local bNeedUpdateScreen,value, bNeedRestart;
	local bForceShadow, ForceFarPlane;
	-- load the current settings. 
	local att = ParaEngine.GetAttributeObject();
	local att_engine = att;
	local value;
	if(not System.options.IsWebBrowser) then
		value = page:GetValue("checkBoxFullScreenMode");
		if(att:GetField("IsFullScreenMode",false) ~= value) then
			bNeedUpdateScreen = true;
		end	
		att:SetField("IsFullScreenMode", value);
		ParaUI.GetUIObject("root"):GetAttributeObject():SetField("EnableIME", value);
	end

	value = tonumber(page:GetValue("comboBoxMultiSampleType"));
	if(value) then
		bNeedRestart = bNeedRestart or (att:GetField("MultiSampleType",0) ~= value);
		att:SetField("MultiSampleType", value);
	end	
	
	value = tonumber(page:GetValue("comboBoxMultiSampleQuality"));
	if(value) then
		bNeedRestart = bNeedRestart or (att:GetField("MultiSampleQuality",0) ~= value);
		att:SetField("MultiSampleQuality", value);
	end	

	value = page:GetValue("checkBoxInverseMouse");
	if(type(value) == "boolean") then 
		att:SetField("IsMouseInverse", value);
	end	
	
	value = tonumber(page:GetValue("graphic_quality"));
	if(value) then
		commonlib.echo({graphic = value})
		if(value ~= att:GetField("Effect Level", 0)) then
			att:SetField("Effect Level", value);
			-- the set may be unsuccessful in case graphics card does not support it, so we will fetch it again here. 
			value = att:GetField("Effect Level", value);
			
			if(value == 1024) then
				value = -1024;
			end
			
			if(value<0) then
				att:SetField("TextureLOD", 1);
			else
				att:SetField("TextureLOD", 0);
			end	
			local att_ocean = ParaScene.GetAttributeObjectOcean();
			
			if(value>=1) then
				-- force using shadow if user selected high graphic mode
				bForceShadow = true;
				att_ocean:SetField("EnableTerrainReflection", true)
				att_ocean:SetField("EnableMeshReflection", true)
				ForceFarPlane = 420;
			else	
				bForceShadow = false
				att_ocean:SetField("EnableTerrainReflection", false)
				att_ocean:SetField("EnableMeshReflection", false)
			end
			if(value == -1) then
				ForceFarPlane = 200;
			elseif(value <= -1) then
				ForceFarPlane = 100;
			end
			
			if(value>=2) then
				att_ocean:SetField("EnablePlayerReflection", true)
				att_ocean:SetField("EnableCharacterReflection", true)
				att:SetField("MultiSampleQuality", 0);
				att:SetField("MultiSampleType", 0);
			else
				att_ocean:SetField("EnablePlayerReflection", false)
				att_ocean:SetField("EnableCharacterReflection", false)
				att:SetField("MultiSampleQuality", 0);
				att:SetField("MultiSampleType", 0);
			end
		end
	end
	
	if(not System.options.IsWebBrowser) then
		value = page:GetValue("ScreenResolution");
		local x,y = string.match(value or "", "(%d+)%D+(%d+)");
		if(x~=nil and y~=nil) then
			x = tonumber(x)
			y = tonumber(y)
			if(x~=nil and y~=nil) then
				local size = {x, y};
				local oldsize = att:GetField("ScreenResolution", {1020,680});
				if(oldsize[1] ~=x or oldsize[2]~= y) then
					bNeedUpdateScreen = true;
				end
				if(System.options.IsWebBrowser) then
					commonlib.app_ipc.ActivateHostApp("change_resolution", nil, size[1], size[2]);
				else	
					att:SetField("ScreenResolution", size);
				end	
			end
		end
	end
	
	local att = ParaScene.GetAttributeObject();
	
	if(bForceShadow~=nil) then
		value = bForceShadow;
	else
		value = page:GetValue("checkBoxUseShadow");
	end
	
	if(value~=nil and att:GetField("SetShadow", false)~=value) then
		att:SetField("SetShadow", value)
	end
	
	att:SetField("UseDropShadow", not att:GetField("SetShadow", false));
	
	local FarPlane = ForceFarPlane or page:GetValue("trackBarViewDistance"); 
	if(FarPlane) then
		local FarPlane_range = {from=100,to=420}
		local FogStart_range = {from=50,to=80}
		local FogEnd_range	 = {from=70,to=130}
		
		value = (FarPlane-FarPlane_range.from) / (FarPlane_range.to- FarPlane_range.from);
		att:SetField("FogEnd", FogEnd_range.from + (FogEnd_range.to - FogEnd_range.from) * value);
		att:SetField("FogStart", FogStart_range.from + (FogStart_range.to - FogStart_range.from) * value);
		ParaCamera.GetAttributeObject():SetField("FarPlane", FarPlane);
		
		att_engine:SetDynamicField("ViewDistance", FarPlane);
	end	
	
	value = tonumber(page:GetValue("trackBarVolume"));
	
	if(value) then
		if(not page:GetValue("EnableSound", true)) then
			value = 0;
		end
		
		att_engine:SetDynamicField("SoundVolume", value);
		-- set all volumes
		ParaAudio.SetVolume(value);
	end	
	
	page:CloseWindow();
	
	if(bNeedUpdateScreen) then
		_guihelper.MessageBox("您的显示设备即将改变:如果您的显卡不支持, 需要您重新登录。是否继续?", function ()
			ParaEngine.GetAttributeObject():CallField("UpdateScreenMode");
			-- we will save to "config.new.txt", so the next time the game engine is started, it will ask the user to preserve or not. 
			ParaEngine.WriteConfigFile("config/config.new.txt");
		end)
	else
		ParaEngine.WriteConfigFile("config/config.new.txt");
	end

	if(bNeedRestart or bNeedUpdateScreen) then
		NPL.load("(gl)script/apps/Aries/Player/main.lua");
		MyCompany.Aries.Player.SaveLocalData("user_confirmed", true, true, false)
	end
		
	if(bNeedRestart) then
		_guihelper.MessageBox("保存成功, 某些设置需要重启才能生效, 请重新启动客户端");
		--_guihelper.MessageBox("保存成功, 某些设置需要重启才能生效, 是否现在重新启动客户端", function()
			--MyCompany.Aries.Desktop.Dock.PostLogoutTime(function()
				--Map3DSystem.App.Commands.Call("Profile.Aries.Restart", {method="hard"});
			--end);
		--end)
	end
end

function AriesSettingsPage.OnCancel()
	page:CloseWindow();
end