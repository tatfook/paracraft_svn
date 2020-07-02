--[[
Title: code behind for page avatar.html
Author(s): LiXizhi
Date: 2009/1/1
Desc:  script/apps/Aquarius/Profile/avatar.html?uid=&nid=
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local avatarPage = {};
commonlib.setfield("MyCompany.Aquarius.avatarPage", avatarPage)

---------------------------------
-- page event handlers
---------------------------------

-- init
function avatarPage.OnInit()
	--local self = document:GetPageCtrl();
	--local name = self:GetRequestParam("name")
	--self:SetNodeValue("fileName", name);
end

-- take screen shot of the character pe:avatar. 
function avatarPage.TakeAvatarSnapshot()
	-- taking the snapshot calling the AvatarRegPage.lua function
	NPL.load("(gl)script/kids/3DMapSystemUI/CCS/AvatarRegPage.lua");
	Map3DSystem.App.CCS.AvatarRegPage.TakeAvatarSnapshot();
end

-- load the current player to canvas
function avatarPage.OnRefreshAvatar()
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
function avatarPage.OnSubmit()
	local self = document:GetPageCtrl();
	if(not self) then 
		log("warning: page control not found")
		return 
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

function avatarPage.OnClose()
	document:GetPageCtrl():CloseWindow();
end