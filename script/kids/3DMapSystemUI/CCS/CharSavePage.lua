--[[
Title: character save page
Author(s): WangTian
Date: 2008/6/12
Desc: script/kids/3DMapSystemApp/CCS/CharSavePage.html is the character save page for 
		the CCS application.
	The character selection page will display a 3D avatar on the right and a list of operation that user can take
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/CharSavePage.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");


-- create class
local CharSavePage = {};
commonlib.setfield("Map3DSystem.App.CCS.CharSavePage", CharSavePage);

-- on init show the current avatar in pe:avatar
function CharSavePage.OnInit()
	local self = document:GetPageCtrl();
	if(not self) then 
		log("warning: page control not found\n")
		return 
	end
end


-- take screen shot of the character pe:avatar. 
function CharSavePage.TakeAvatarSnapshot()
	-- taking the snapshot calling the AvatarRegPage.lua function
	NPL.load("(gl)script/kids/3DMapSystemUI/CCS/AvatarRegPage.lua");
	Map3DSystem.App.CCS.AvatarRegPage.TakeAvatarSnapshot();
end

-- load the current player to canvas
function CharSavePage.OnRefreshAvatar()
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
function CharSavePage.OnClickSave()

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