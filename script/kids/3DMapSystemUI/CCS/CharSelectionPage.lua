--[[
Title: character selection page
Author(s): WangTian
Date: 2008/6/12
Desc: script/kids/3DMapSystemApp/CCS/CharSelectionPage.html is the character selection page for 
		the CCS application.
	The character selection page will display a 3D avatar on the right and a list of avaiable characters that use can choose from
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/CharSelectionPage.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");

-- create class
local CharSelectionPage = {};
commonlib.setfield("Map3DSystem.App.CCS.CharSelectionPage", CharSelectionPage);

-- avatar db table, the name property is [race]/[gender] or normal character model path
CharSelectionPage.avatars = {
	{name = "Human/Male", ext="xml",desc="男青年", ccsinfo = "0#0#4#2#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#214#0#135#163#0#0#0#0#0#0#0#", bg = "character/v3/Human/snapshots/avatar_human_male_1.png"},
	{name = "Human/Female", ext="xml", desc="女青年", ccsinfo = "0#0#0#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#216#0#113#155#0#0#0#0#0#0#0#", bg = "character/v3/Human/snapshots/avatar_human_female_1.png"},
	
	{name = "Human/Male", ext="xml", desc="小帅哥", ccsinfo = "0#0#1#2#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#231#0#122#177#0#0#0#0#0#0#0#", bg = "character/v3/Human/snapshots/avatar_human_male_2.png"},
	{name = "Human/Female", ext="xml", desc="邻家女孩", ccsinfo = "0#0#6#4#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#235#0#114#170#0#0#0#0#0#0#0#", bg = "character/v3/Human/snapshots/avatar_human_female_2.png"},
	
	{name = "Human/Male", ext="xml", desc="运动男孩", ccsinfo = "0#0#2#2#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#217#0#119#169#0#0#0#0#0#0#0#", bg = "character/v3/Human/snapshots/avatar_human_male_3.png"},
	{name = "Human/Female", ext="xml", desc="淑女", ccsinfo = "0#0#2#3#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#229#0#115#166#0#0#0#0#0#0#0#", bg = "character/v3/Human/snapshots/avatar_human_female_3.png"},
	
	{name = "Human/Male", ext="xml", desc="叛逆男孩", ccsinfo = "0#0#2#0#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#252#0#148#178#0#0#0#0#0#0#0#", bg = "character/v3/Human/snapshots/avatar_human_male_4.png"},
	{name = "Human/Female", ext="xml", desc="时尚女孩", ccsinfo = "0#0#3#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#227#0#118#168#0#0#0#0#0#0#0#", bg = "character/v3/Human/snapshots/avatar_human_female_4.png"},
};
				
-- datasource function for pe:gridview
function CharSelectionPage.DS_Avatar_Func(index)
	if(index == nil) then
		return #(CharSelectionPage.avatars);
	else
		return CharSelectionPage.avatars[index];
	end
end

-- take screen shot of the character pe:avatar. 
function CharSelectionPage.TakeAvatarSnapshot()
	-- taking the snapshot calling the AvatarRegPage.lua function
	NPL.load("(gl)script/kids/3DMapSystemUI/CCS/AvatarRegPage.lua");
	Map3DSystem.App.CCS.AvatarRegPage.TakeAvatarSnapshot();
end

-- User select a character in the gridview list, change the 3d display in pe:avatar window
function CharSelectionPage.UpdateChar(index)
	local info = CharSelectionPage.avatars[index];
	if(not info or not document) then 
		log("warning: document not found\n")
		return 
	end
	local self = document:GetPageCtrl();
	if(not self) then 
		log("warning: page control not found\n")
		return 
	end
	-- get current loggin user ID as the uid
	local uid = Map3DSystem.App.profiles.ProfileManager.GetUserID() or "";
	
	-- get race and gender or (normal character model path) from btnName
	-- btnName: [race]/[gender]
	-- btnName: normal character model path
	btnName = string.lower(info.name);
	local _slash = string.find(info.name, "/");
	local race, gender;
	if(_slash ~= nil) then
		race = string.sub(info.name, 1, _slash - 1);
		gender = string.sub(info.name, _slash + 1, -1);
		
		local modelPath;
		if(string.lower(gender) ~= "female" and string.lower(gender) ~= "male") then
			-- this is a normal character model file path
			-- TODO: more strict model file name check
			modelPath = info.name;
		else
			-- NOTE: assume the model file path is according to the format:
			--		character/v3/[race]/[gender]/[race][gender].x
			modelPath = string.format([[character/v3/%s/%s/%s%s.]]..(info.ext or "x"), race, gender, race, gender);
		end
		
		-- update description text
		self:SetUIValue("desc", info.desc)
		
		-- update avatar display
		-- hardcoded mount appearance
		race = string.lower(race);
		gender = string.lower(gender);
		
		local ctl = self:FindControl("avatar");
		if(ctl) then
			ctl:ShowModel({
				["IsCharacter"] = true,
				["y"] = 0,
				["x"] = 0,
				["facing"] = -1.57,
				["name"] = "pe:avatar:"..uid,
				["z"] = 0,
				["AssetFile"] = modelPath,
				["CCSInfoStr"] = info.ccsinfo,
			});
		end
		CharSelectionPage.CurrentSelectRace = race;
		CharSelectionPage.CurrentSelectGender = gender;
		
		CharSelectionPage.CurrentSelectDesc = info.desc;
		
		-- keep params for saving
		CharSelectionPage.CharParams = CharSelectionPage.CharParams or {};
		CharSelectionPage.CharParams.AssetFile = modelPath;
		CharSelectionPage.CharParams.CCSInfoStr = info.ccsinfo;
	end
end

-- Accept the current preview avatar and save to CCSApp profile
function CharSelectionPage.OnAccept(btnName, values, bindingContext)
	local self = document:GetPageCtrl();
	if(not self) then 
		log("warning: page control not found")
		return 
	end
	
	local race = CharSelectionPage.CurrentSelectRace;
	local gender = CharSelectionPage.CurrentSelectGender;
	if(race == nil or gender == nil) then
		-- update submission text
		self:SetUIValue("SubmitMSG", "您并没有做任何修改");
	else
		if(CharSelectionPage.CharParams) then
			local player = ParaScene.GetPlayer();
			local asset = ParaAsset.LoadParaX("", CharSelectionPage.CharParams.AssetFile);
			player:ToCharacter():ResetBaseModel(asset);
			Map3DSystem.UI.CCS.ApplyCCSInfoString(player, CharSelectionPage.CharParams.CCSInfoStr);
			
			-- for facial update
			NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Main2.lua");
			Map3DSystem.UI.CCS.Main2.UpdatePanelUIEnabled();
			Map3DSystem.UI.CCS.Main2.UpdateFacialPanel();
		end
		-- update submission text
		self:SetUIValue("SubmitMSG", "您选择了"..CharSelectionPage.CurrentSelectDesc);
	end
end

-- just exit to call back. 
function CharSelectionPage:Leave()
	self:Close();
end