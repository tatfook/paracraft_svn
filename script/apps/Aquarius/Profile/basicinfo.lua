--[[
Title: code behind for page basicinfo.html
Author(s): LiXizhi
Date: 2009/1/1
Desc:  script/apps/Aquarius/Profile/basicinfo.html?uid=&nid=
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local basicinfoPage = {};
commonlib.setfield("MyCompany.Aquarius.basicinfoPage", basicinfoPage)

---------------------------------
-- page event handlers
---------------------------------
-- init
function basicinfoPage.OnInit()
	local page = document:GetPageCtrl();
	local uid = page:GetRequestParam("uid") or Map3DSystem.App.profiles.ProfileManager.GetUserID();
	
	Map3DSystem.App.profiles.ProfileManager.GetMCML(uid, Map3DSystem.App.appkeys["profiles"], function(uid, appkey, bSucceed, profile)
		if(profile and profile.UserInfo) then
			local UserInfo = profile.UserInfo;
			-- commonlib.echo(UserInfo)
			
			if(UserInfo.selfdescription) then
				page:SetValue("selfdescription", UserInfo.selfdescription)
			end	
			page:SetValue("blood", tostring(UserInfo.blood or 0))
			local birth_year = tonumber(UserInfo.birth_year);
			if(birth_year and birth_year>0) then
				local thisyear = tonumber(string.match(ParaGlobal.GetDateFormat("yyyy-M-d"), "^%d+"));
				local age = thisyear - birth_year;
				if(age>0) then
					page:SetValue("age", tostring(age))
				end	
			end
			if(UserInfo.gender) then
				page:SetValue("gender", UserInfo.gender)
			end	
			if(UserInfo.horoscope) then
				page:SetValue("horoscope", UserInfo.horoscope)
			end
		end
	end)
	
end

function basicinfoPage.OnSubmit(name, values)
	local page = document:GetPageCtrl();
	local new_values = {};
	new_values.horoscope = values.horoscope
	new_values.gender = values.gender
	new_values.blood = values.blood
	if(values.selfdescription) then
		new_values.selfdescription = string.gsub(values.selfdescription, "[\r\n]+$","");
	end	
	
	if(values.age) then
		local age = tonumber(values.age);
		if(age > 0) then
			local thisyear = tonumber(string.match(ParaGlobal.GetDateFormat("yyyy-M-d"), "^%d+"));
			new_values.birth_year = thisyear - age;
		end
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

function basicinfoPage.OnClose()
	document:GetPageCtrl():CloseWindow();
end