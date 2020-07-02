--[[
Title: code behind for page interests.html
Author(s): LiXizhi
Date: 2009/1/1
Desc:  script/apps/Aquarius/Profile/interests.html?uid=&nid=
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local interestsPage = {};
commonlib.setfield("MyCompany.Aquarius.interestsPage", interestsPage)

---------------------------------
-- page event handlers
---------------------------------

-- init
function interestsPage.OnInit()
	local page = document:GetPageCtrl();
	local uid = page:GetRequestParam("uid") or Map3DSystem.App.profiles.ProfileManager.GetUserID();
	
	Map3DSystem.App.profiles.ProfileManager.GetMCML(uid, Map3DSystem.App.appkeys["profiles"], function(uid, appkey, bSucceed, profile)
		if(profile and profile.UserInfo) then
			local UserInfo = profile.UserInfo;
			-- commonlib.echo(UserInfo)
			
			if(UserInfo.interest) then
				page:SetValue("interest", UserInfo.interest)
			end	
			if(UserInfo.relationship) then
				page:SetValue("relationship", UserInfo.relationship)
			end
			local function checkboxSet(fieldname)
				if(UserInfo[fieldname]) then
					local num
					for num in string.gmatch(UserInfo[fieldname], "%d+") do
						page:SetValue(fieldname..num, true);
					end
				end
			end	
			checkboxSet("color")
			checkboxSet("meeting")
			checkboxSet("music")
		end
	end)
end

function interestsPage.OnSubmit(name, values)
	local page = document:GetPageCtrl();
	local new_values = {};
	if(values.interest) then
		new_values.interest = string.gsub(values.interest, "[\r\n]+$","");
	end	
	new_values.relationship = values.relationship;

	local function checkboxGet(fieldname, from, to)
		local value;
		local num
		for num = from, to do 
			if(values[fieldname..tostring(num)]) then
				value = (value or "")..tostring(num)..","
			end	
		end
		return value
	end	
	new_values.color = checkboxGet("color", 1,16);
	new_values.meeting = checkboxGet("meeting", 1,10);
	new_values.music = checkboxGet("music", 1,10);
			
	page:SetUIValue("result", "正在更新, 请稍候...")
	Map3DSystem.App.profiles.ProfileManager.SaveToProfile(new_values, function(bSucceed)
		if(bSucceed) then
			page:SetUIValue("result", "更新成功")
		else
			page:SetUIValue("result", "更新失败")
		end
	end)
end

function interestsPage.OnClose()
	document:GetPageCtrl():CloseWindow();
end
