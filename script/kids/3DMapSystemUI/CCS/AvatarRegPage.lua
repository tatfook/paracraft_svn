--[[
Title: registration page functions for avatar application
Author(s): WangTian
Date: 2008/3/18, revised 2008.3.21 LXZ
Desc: script/kids/3DMapSystemApp/avatar/RegistrationPage.html is the registration page for 
		the avatar application. This NPL file contains all the necessary functions needed during 
		the page interaction. 
	The registration page will display a 3D avatar on the right(using mini scene graph) <pe:avatar>, 
		a list of avaible avatars in the middle(using TreeView) <pe:treeview>, 
		and a brief description of the selected avatar <pe:box>.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/AvatarRegPage.lua");
Map3DSystem.App.CCS.AvatarRegPage:Create("CCS.AvatarRegPage", parent, "_fi", 0,0,0,0);
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");

-- create class
local AvatarRegPage = Map3DSystem.mcml.PageCtrl:new({url="script/kids/3DMapSystemUI/CCS/AvatarRegPage.html"});
Map3DSystem.App.CCS.AvatarRegPage = AvatarRegPage;

-- avatar db table, the name property is [race]/[gender] or normal character model path
AvatarRegPage.avatars = {
	{name = "Human/Male", desc="男青年", ccsinfo = "0#0#4#2#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#214#0#135#163#0#0#0#0#0#0#0#", bg = "character/v3/Human/snapshots/avatar_human_male_1.png"},
	{name = "Human/Female", desc="女青年", ccsinfo = "0#0#0#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#216#0#113#155#0#0#0#0#0#0#0#", bg = "character/v3/Human/snapshots/avatar_human_female_1.png"},
	
	{name = "Human/Male", desc="小帅哥", ccsinfo = "0#0#1#2#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#231#0#122#177#0#0#0#0#0#0#0#", bg = "character/v3/Human/snapshots/avatar_human_male_2.png"},
	{name = "Human/Female", desc="邻家女孩", ccsinfo = "0#0#6#4#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#235#0#114#170#0#0#0#0#0#0#0#", bg = "character/v3/Human/snapshots/avatar_human_female_2.png"},
	
	{name = "Human/Male", desc="运动男孩", ccsinfo = "0#0#2#2#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#217#0#119#169#0#0#0#0#0#0#0#", bg = "character/v3/Human/snapshots/avatar_human_male_3.png"},
	{name = "Human/Female", desc="淑女", ccsinfo = "0#0#2#3#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#229#0#115#166#0#0#0#0#0#0#0#", bg = "character/v3/Human/snapshots/avatar_human_female_3.png"},
	
	{name = "Human/Male", desc="叛逆男孩", ccsinfo = "0#0#2#0#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#252#0#148#178#0#0#0#0#0#0#0#", bg = "character/v3/Human/snapshots/avatar_human_male_4.png"},
	{name = "Human/Female", desc="时尚女孩", ccsinfo = "0#0#3#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#227#0#118#168#0#0#0#0#0#0#0#", bg = "character/v3/Human/snapshots/avatar_human_female_4.png"},
	
	--{name = "character/v1/01human/baru/baru.x", desc="小学生", ccsinfo = nil, bg = "character/v1/01human/baru/baru.x.png"},
	--{name = "character/v1/01human/boy/boy.x", desc="小男孩", ccsinfo = nil, bg = "character/v1/01human/boy/boy.x.png"},
	--
	--{name = "character/v1/02animals/01land/pigmen/pig.x", desc="小猪", ccsinfo = nil, bg = "character/v1/02animals/01land/pigmen/pig.x.png"},
	--{name = "character/v1/02animals/01land/dog/dog.x", desc="小狗", ccsinfo = nil, bg = "character/v1/02animals/01land/dog/dog.x.png"},
	--
	--{name = "character/v1/02animals/01land/snake/snake.x", desc="蛇", ccsinfo = nil, bg = "character/v1/02animals/01land/snake/snake.x.png"},
	--{name = "character/v1/02animals/01land/guagua/guagua.x", desc="青蛙", ccsinfo = nil, bg = "character/v1/02animals/01land/guagua/guagua.x.png"},
	--
	--{name = "character/v1/02animals/01land/chengcheng/cheng.x", desc="蜘蛛", ccsinfo = nil, bg = "character/v1/02animals/01land/chengcheng/cheng.x.png"},
	--{name = "character/v1/02animals/01land/chevalier/chevalier.x", desc="狗骑士", ccsinfo = nil, bg = "character/v1/02animals/01land/chevalier/chevalier.x.png"},
	
	--{name = "angel/male", desc="天使族小姐", ccsinfo = nil, bg = "character/v1/01human/baru/baru.x.png"},
	--{name = "angel/female", desc="天使族绅士", ccsinfo = nil, bg = "character/v1/01human/boy/boy.x.png"},
	--{name = "momo/male", desc="嬷嬷族小姐", ccsinfo = nil, bg = "character/v1/01human/baru/baru.x.png"},
	--{name = "momo/female", desc="嬷嬷族绅士", ccsinfo = nil, bg = "character/v1/01human/boy/boy.x.png"},
};
				
-- datasource function for pe:gridview
function AvatarRegPage.DS_Avatar_Func(index)
	if(index == nil) then
		return #(AvatarRegPage.avatars);
	else
		return AvatarRegPage.avatars[index];
	end
end

-- function to be called when user completed or skipped all app registration steps. 
-- callback function to call after the registration page finish or skip
AvatarRegPage.OnFinishedFunc = nil;


-- take screen shot of the character pe:avatar. 
function AvatarRegPage.TakeAvatarSnapshot()
	local self = document:GetPageCtrl();
	if(not self) then return end
	
	local filename = "Screen Shots/MyAvatar.png";
	self:CallMethod("avatar", "TakeSnapshot", filename)
	_guihelper.MessageBox(string.format("您的快照保存到了: %s", filename))
end

-- User select a character in the gridview list, change the 3d display in pe:avatar window
function AvatarRegPage.UpdateAvatar(index)
	local info = AvatarRegPage.avatars[index];
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
			modelPath = string.format([[character/v3/%s/%s/%s%s.x]], race, gender, race, gender);
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
		AvatarRegPage.CurrentSelectRace = race;
		AvatarRegPage.CurrentSelectGender = gender;
		
		-- keep params for saving
		AvatarRegPage.CharParams = AvatarRegPage.CharParams or {};
		AvatarRegPage.CharParams.AssetFile = modelPath;
		AvatarRegPage.CharParams.CCSInfoStr = info.ccsinfo;
	end
end

-- Accept the current preview avatar and save to CCSApp profile
function AvatarRegPage.OnAccept(btnName, values, bindingContext)
	
	local self = document:GetPageCtrl();
	if(not self) then 
		log("warning: page control not found")
		return 
	end
	
	local race = AvatarRegPage.CurrentSelectRace;
	local gender = AvatarRegPage.CurrentSelectGender;
	if(race == nil or gender == nil) then
		_guihelper.MessageBox("请选择一个人物");
	else
		if(AvatarRegPage.CharParams) then
			-- save to profile.CharParams
			local profile = Map3DSystem.App.CCS.app:GetMCMLInMemory() or {};
			if(type(profile) ~= "table") then
				profile = {};
			end
			profile.CharParams = profile.CharParams or {};
			
			if(not commonlib.partialcompare(profile.CharParams, AvatarRegPage.CharParams)) then
				paraworld.ShowMessage("正在更新, 请稍候...")
				commonlib.partialcopy(profile.CharParams, AvatarRegPage.CharParams);
				Map3DSystem.App.CCS.app:SetMCML(nil, profile, function (uid, appkey, bSucceed)
					if(bSucceed) then
						paraworld.ShowMessage("更新成功！ 谢谢！")
						self:Leave();
					else
						paraworld.ShowMessage("暂时无法更新，请稍候再试")
					end	
				end)
			else
				paraworld.ShowMessage("您并没有做任何修改")
			end	
		end
	end
end

-- Skip the avatar registration page
function AvatarRegPage.OnSkip(btnName, values, bindingContext)
	local self = document:GetPageCtrl();
	if(not self) then 
		log("warning: page control not found")
		return 
	end
	self:Leave();
end

-- just exit to call back. 
function AvatarRegPage:Leave()
	self:Close();
	
	-- call the registration page callback function to return to the login process
	if(AvatarRegPage.OnFinishedFunc) then
		AvatarRegPage.OnFinishedFunc();
		AvatarRegPage.OnFinishedFunc = nil;
	end	
end