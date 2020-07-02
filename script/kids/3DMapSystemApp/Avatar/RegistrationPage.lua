--[[
Title: registration page functions for avatar application
Author(s): WangTian
Date: 2008/3/18
Desc: script/kids/3DMapSystemApp/avatar/RegistrationPage.html is the registration page for 
		the avatar application. This NPL file contains all the necessary functions needed during 
		the page interaction. 
	The registration page will display a 3D avatar on the right(using mini scene graph) <pe:avatar>, 
		a list of avaible avatars in the middle(using TreeView) <pe:treeview>, 
		and a brief description of the selected avatar <pe:box>.
Desc: it display the user photo, quick action and friend list on the left column; basic profile info and all application boxes are displayed in a mcml binded tree view control on the right side. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/avatar/RegistrationPage.lua");
-------------------------------------------------------
]]

if(not Map3DSystem.App.Avatar.RegistrationPage) then Map3DSystem.App.Avatar.RegistrationPage = {} end

-- NOTE: only used for the registration page
Map3DSystem.App.Avatar.RegistrationPage.CurrentSelectRace = nil;
Map3DSystem.App.Avatar.RegistrationPage.CurrentSelectGender = nil;

-- callback function to call after the registration page finish or skip
Map3DSystem.App.Avatar.RegistrationPage.CallbackFunc = nil;

-- Launch the registration page in the centor of the screen
-- BrowserWnd goto: script/kids/3DMapSystemApp/avatar/RegistrationPage.html
-- @param browsername: browser name to show the registration page
-- @param callbackFunc: callback function to call after the registration page finish or skip
function Map3DSystem.App.Avatar.RegistrationPage.LaunchPage(browsername, callbackFunc)
	
	Map3DSystem.App.Avatar.RegistrationPage.CallbackFunc = callbackFunc;
	
	NPL.load("(gl)script/kids/3DMapSystemApp/mcml/BrowserWnd.lua");
	
	local ctl = CommonCtrl.GetControl(browsername);
	if(ctl ~= nil) then
		ctl:Goto("script/kids/3DMapSystemApp/avatar/RegistrationPage.html");
		-- TODO: apply a cache policy
		--ctl:Goto("script/kids/3DMapSystemApp/avatar/RegistrationPage.html", System.localserver.CachePolicy:new("access plus 1 day"));
	end
end

-- User select the a character in the treeview list
-- Change the object in pe:avatar window
-- @param btnName: [race]/[gender] or normal character model path
-- @see: function pe_avatar.create
function Map3DSystem.App.Avatar.RegistrationPage.UpdateAvatar(btnName, values, bindingContext)
	
	-- get current loggin user ID as the uid
	local uid = Map3DSystem.App.profiles.ProfileManager.GetUserID();
	
	-- TODO: debug purpose only
	if(uid == nil) then
		uid = "6ea1ce24-bdf7-4893-a053-eb5fd2a74281";
	end
	
	-- get race and gender or (normal character model path) from btnName
	-- btnName: [race]/[gender]
	-- btnName: normal character model path
	btnName = string.lower(btnName);
	local _slash = string.find(btnName, "/");
	local race, gender;
	if(_slash ~= nil) then
		race = string.sub(btnName, 1, _slash - 1);
		gender = string.sub(btnName, _slash + 1, -1);
		
		local modelPath;
		if(string.lower(gender) ~= "female" and string.lower(gender) ~= "male") then
			-- this is a normal character model file path
			-- TODO: more strict model file name check
			modelPath = btnName;
		else
			-- NOTE: assume the model file path is according to the format:
			--		character/v3/[race]/[gender]/[race][gender].x
			modelPath = string.format([[character/v3/%s/%s/%s%s.x]], race, gender, race, gender);
		end
		
		local ctl = CommonCtrl.GetControl("pe:avatar:canvas:"..uid);
		
		-- hardcoded mount appearance
		race = string.lower(race);
		gender = string.lower(gender);
		local sInfo;
		if(race == "human" and gender == "male") then
			sInfo = "0#0#4#0#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#72#0#75#78#0#0#0#0#0#0#0#";
		elseif(race == "human" and gender == "female") then
			sInfo = "0#0#3#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#70#0#66#67#0#0#0#0#0#0#0#";
		elseif(race == "angel" and gender == "male") then
			sInfo = "0#0#4#0#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@16#0#17#25#0#18#20#0#0#23#0#0#0#0#";
		elseif(race == "angel" and gender == "female") then
			sInfo = "0#0#0#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#8#0#27#26#0#0#22#0#0#0#0#";
		elseif(race == "momo" and gender == "male") then
			sInfo = "0#0#0#0#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@28#0#33#71#0#36#7#0#0#6#0#0#0#0#";
		elseif(race == "horse" and gender == "female") then
			sInfo = "0#0#0#0#0#@@0#0#0#0#0#60#58#0#0#0#0#0#0#0#";
		elseif(race == "witch" and gender == "female") then
			sInfo = "0#0#2#2#0#@@0#0#0#0#0#43#0#0#0#0#0#0#0#0#";
		elseif(race == "witch2" and gender == "female") then
			sInfo = "0#0#2#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#25#0#80#78#0#0#0#0#0#0#0#";
		elseif(race == "child" and gender == "male") then
			sInfo = "0#0#1#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#49#0#0#0#0#0#0#0#0#";
		elseif(race == "child" and gender == "female") then
			sInfo = "0#0#1#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#43#0#0#0#0#0#0#0#0#";
		elseif(race == "human2" and gender == "male") then
			sInfo = "0#0#1#1#0#@@0#0#0#0#0#51#0#0#0#0#0#0#0#0#";
		elseif(race == "human2" and gender == "female") then
			sInfo = "0#0#1#1#0#@@0#0#0#8#0#50#0#0#0#0#0#0#0#0#";
		end
			
		ctl:ShowModel({
			["IsCharacter"] = true,
			["y"] = 0,
			["x"] = 0,
			["facing"] = -1.57,
			["name"] = "pe:avatar:"..uid,
			["z"] = 0,
			["AssetFile"] = modelPath,
			["CCSInfoStr"] = sInfo,
		});
		
		Map3DSystem.App.Avatar.RegistrationPage.CurrentSelectRace = race;
		Map3DSystem.App.Avatar.RegistrationPage.CurrentSelectGender = gender;
		
		do return end
		
		---------------------------------------------
		-- original implementation
		---------------------------------------------
		
		local scene = ParaScene.GetMiniSceneGraph("pe_avatar:"..uid);
		scene:RemoveObject("avatar");
		
		-- main player: at 0,0,0
		local obj,player, asset;
		asset = ParaAsset.LoadParaX("", modelPath);
		obj = ParaScene.CreateCharacter("avatar", asset, "", true, 0.35, 0.5, 1);
		if(obj:IsValid() == true) then
			obj:SetPosition(0, 0, 0);
			obj:SetScaling(2.5);
			obj:SetFacing(2);
		    
			scene:AddChild(obj);
			
			Map3DSystem.App.Avatar.RegistrationPage.CurrentSelectRace = race;
			Map3DSystem.App.Avatar.RegistrationPage.CurrentSelectGender = gender;
			
			-- NOTE: the assets are not yet loaded
			--NPL.load("(gl)script/kids/3DMapSystemUI/CCS/DefaultAppearance.lua");
			--Map3DSystem.UI.CCS.DefaultAppearance.MountDefaultAppearance(obj);
			
			-- hardcoded mount appearance
			race = string.lower(race);
			gender = string.lower(gender);
			local sInfo;
			if(race == "human" and gender == "male") then
				sInfo = "0#0#4#0#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#72#0#75#78#0#0#0#0#0#0#0#";
			elseif(race == "human" and gender == "female") then
				sInfo = "0#0#3#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#70#0#66#67#0#0#0#0#0#0#0#";
			elseif(race == "angel" and gender == "male") then
				sInfo = "0#0#4#0#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@16#0#17#25#0#18#20#0#0#23#0#0#0#0#";
			elseif(race == "angel" and gender == "female") then
				sInfo = "0#0#0#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#8#0#27#26#0#0#22#0#0#0#0#";
			elseif(race == "momo" and gender == "male") then
				sInfo = "0#0#0#0#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@28#0#33#71#0#36#7#0#0#6#0#0#0#0#";
			elseif(race == "horse" and gender == "female") then
				sInfo = "0#0#0#0#0#@@0#0#0#0#0#60#58#0#0#0#0#0#0#0#";
			elseif(race == "witch" and gender == "female") then
				sInfo = "0#0#2#2#0#@@0#0#0#0#0#43#0#0#0#0#0#0#0#0#";
			elseif(race == "witch2" and gender == "female") then
				sInfo = "0#0#2#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#25#0#80#78#0#0#0#0#0#0#0#";
			elseif(race == "child" and gender == "male") then
				sInfo = "0#0#1#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#49#0#0#0#0#0#0#0#0#";
			elseif(race == "child" and gender == "female") then
				sInfo = "0#0#1#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#43#0#0#0#0#0#0#0#0#";
			elseif(race == "human2" and gender == "male") then
				sInfo = "0#0#1#1#0#@@0#0#0#0#0#51#0#0#0#0#0#0#0#0#";
			elseif(race == "human2" and gender == "female") then
				sInfo = "0#0#1#1#0#@@0#0#0#8#0#50#0#0#0#0#0#0#0#0#";
			end
			
			-- apply the CCS information
			Map3DSystem.UI.CCS.ApplyCCSInfoString(obj, sInfo);
		end
	end
end


-- Skip the avatar registration page
function Map3DSystem.App.Avatar.RegistrationPage.OnSkip(btnName, values, bindingContext)
	_guihelper.MessageBox("Skip this step\n");
	Map3DSystem.App.Avatar.RegistrationPage.Leave();
end

-- Accept the current preview avatar
function Map3DSystem.App.Avatar.RegistrationPage.OnAccept(btnName, values, bindingContext)
	
	local race = Map3DSystem.App.Avatar.RegistrationPage.CurrentSelectRace;
	local gender = Map3DSystem.App.Avatar.RegistrationPage.CurrentSelectGender;
	if(race == nil or gender == nil) then
		_guihelper.MessageBox("Select an character first\n");
	else
		-- TODO:accept race and gender and update avatar information
		_guihelper.MessageBox(string.format("accept %q and %q and update avatar information\n", race, gender), Map3DSystem.App.Avatar.RegistrationPage.Leave);
	end
end

-- Accept the current preview avatar callback
function Map3DSystem.App.Avatar.RegistrationPage.Leave()

	-- call the registration page callback function to return to the login process
	Map3DSystem.App.Avatar.RegistrationPage.CallbackFunc();
	Map3DSystem.App.Avatar.RegistrationPage.CallbackFunc = nil;
	
	-- destroy the RegistrationPage browser window
	local ctl = CommonCtrl.GetControl("Avatar.RegistrationPage");
	ctl:Destroy();
end