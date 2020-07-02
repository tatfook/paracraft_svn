--[[
Title: code behind for page aboutme.html
Author(s): LiXizhi
Date: 2009/1/1
Desc:  script/apps/Aquarius/Profile/aboutme.html?uid=&nid=
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local aboutmePage = {};
commonlib.setfield("MyCompany.Aquarius.aboutmePage", aboutmePage)

---------------------------------
-- page event handlers
---------------------------------

-- init
function aboutmePage.OnInit()
	local page = document:GetPageCtrl();
	local uid = page:GetRequestParam("uid") or Map3DSystem.App.profiles.ProfileManager.GetUserID();
	
	Map3DSystem.App.profiles.ProfileManager.GetMCML(uid, Map3DSystem.App.appkeys["profiles"], function(uid, appkey, bSucceed, profile)
		if(profile and profile.UserInfo) then
			local UserInfo = profile.UserInfo;
			-- commonlib.echo(UserInfo)
			if(UserInfo.username) then
				page:SetValue("username", tostring(UserInfo.username))
			end
			if(UserInfo.gender) then
				page:SetValue("gender", tostring(UserInfo.gender))
			end	
			if(UserInfo.birth_year) then
				page:SetValue("birth_year", tostring(UserInfo.birth_year))
			end
			if(UserInfo.birth_month) then
				page:SetValue("birth_month", tostring(UserInfo.birth_month))
			end
			if(UserInfo.birth_day) then
				page:SetValue("birth_day", tostring(UserInfo.birth_day))
			end
			if(UserInfo.home_province) then
				page:SetValue("home_province", tostring(UserInfo.home_province))
			end
			if(UserInfo.home_city) then
				page:SetValue("home_city", tostring(UserInfo.home_city))
			end
			
			if(UserInfo.office_phone) then
				page:SetValue("office_phone", tostring(UserInfo.office_phone))
			end
			if(UserInfo.emailaddress) then
				page:SetValue("emailaddress", tostring(UserInfo.emailaddress))
			end
			if(UserInfo.msn) then
				page:SetValue("msn", tostring(UserInfo.msn))
			end
			if(UserInfo.website) then
				page:SetValue("website", tostring(UserInfo.website))
			end
			if(UserInfo.qq) then
				page:SetValue("qq", tostring(UserInfo.qq))
			end
			if(UserInfo.mobile_phone) then
				page:SetValue("mobile_phone", tostring(UserInfo.mobile_phone))
			end
			
			
			if(UserInfo.company_name_0) then
				page:SetValue("company_name_0", tostring(UserInfo.company_name_0))
			end
			if(UserInfo.company_workhere_0) then
				page:SetValue("company_workhere_0", tostring(UserInfo.company_workhere_0))
			end
			if(UserInfo.company_year_0) then
				page:SetValue("company_year_0", tostring(UserInfo.company_year_0))
			end
			if(UserInfo.company_desc_0) then
				page:SetValue("company_desc_0", tostring(UserInfo.company_desc_0))
			end
		end
	end)
end

function aboutmePage.OnSubmit(name, values)
	local page = document:GetPageCtrl();
	local new_values = {};
	if(values.username and values.username ~= "") then
		new_values.username = values.username
	end	
	new_values.gender = values.gender
	new_values.birth_year = values.birth_year
	new_values.birth_month = values.birth_month
	new_values.birth_day = values.birth_day
	
	if(values.home_province and values.home_province~="") then
		new_values.home_province = values.home_province
	end	
	if(values.home_city and values.home_city~="") then
		new_values.home_city = values.home_city
	end	
	
	
	if(values.office_phone and values.office_phone~="") then
		new_values.office_phone = values.office_phone
	end
	if(values.emailaddress and values.emailaddress~="") then
		new_values.emailaddress = values.emailaddress
	end
	if(values.msn and values.msn~="") then
		new_values.msn = values.msn
	end
	if(values.website and values.website~="") then
		new_values.website = values.website
	end
	if(values.qq and values.qq~="") then
		new_values.qq = values.qq
	end
	if(values.mobile_phone and values.mobile_phone~="") then
		new_values.mobile_phone = values.mobile_phone
	end
	
	if(values.company_name_0 and values.company_name_0~="") then
		new_values.company_name_0 = values.company_name_0
	end
	if(values.company_workhere_0 and values.company_workhere_0~="") then
		new_values.company_workhere_0 = values.company_workhere_0
	end
	if(values.company_year_0 and values.company_year_0~="") then
		new_values.company_year_0 = values.company_year_0
	end
	if(values.company_desc_0 and values.company_desc_0~="") then
		new_values.company_desc_0 = values.company_desc_0
	end
	
	
	page:SetUIValue("result", "正在更新, 请稍候...")
	Map3DSystem.App.profiles.ProfileManager.SaveToProfile(new_values, function(bSucceed)
		if(bSucceed) then
			page:SetUIValue("result", "更新成功")
		else
			page:SetUIValue("result", "更新失败")
		end
	end)
end

function aboutmePage.OnClose()
	document:GetPageCtrl():CloseWindow();
end