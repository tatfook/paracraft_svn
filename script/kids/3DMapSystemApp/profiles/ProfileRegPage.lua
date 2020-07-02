--[[
Title: Profile registration (setting) page control
Author(s): LiXizhi
Date: 2008/3/20
Desc: editing user profile during registration or normal use
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfileRegPage.lua");
Map3DSystem.App.profiles.RegPage:Create("profiles.RegPage", parent, "_fi", 0,0,0,0);
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");

-- create class
local RegPage = Map3DSystem.mcml.PageCtrl:new({url="script/kids/3DMapSystemApp/profiles/ProfileRegPage.html"});
Map3DSystem.App.profiles.RegPage = RegPage;

-- function to be called when user completed or skipped all app registration steps. 
RegPage.OnFinishedFunc = nil;

-- it is called before page UI is about to be created. 
function RegPage.OnInit()
	local self = document:GetPageCtrl();
	if(not self) then 
		log("warning: page control not found")
		return 
	end
	-- get the mcml data
	local profile = Map3DSystem.App.profiles.app:GetMCMLInMemory() or {};
	if(type(profile) ~="table") then
		log("warning: invalid profile box mcml data\n table expected got string.\n")
		commonlib.log(profile)
		return;
	end
	commonlib.log(profile);
	
	-- change tab page according to profile parameter
	local tabpage = self:GetRequestParam("tab");
    if(tabpage and tabpage~="") then
        self:SetNodeValue("ProfileTabParent", tabpage);
    end
    
	-- extract userinfo from profile.UserInfo
	if(profile.UserInfo) then
		-- all known fields in profile.UserInfo (only keys are used, the value is just for human reading)
		local fields = Map3DSystem.App.profiles.app:GetProfileDefinition().UserInfo;
		
		-- update MCML for each known field in profile
		local name, v
		for name, v in pairs(fields) do 
			if(profile.UserInfo[name]~=nil) then
				self:SetNodeValue(name, profile.UserInfo[name])
			end
		end
		
		if(not tabpage) then
			-- automatically select a tab for the user to fill in data, currently only the basic info page and photo page are actually required. 
			if(fields.username == nil or fields.username == "") then
				-- use the default basic info page
			elseif(fields.photo == nil or fields.photo == "") then
				-- open photo page. 
				self:SetNodeValue("ProfileTabParent", "uploadphoto");
			end
		end	
	end	
end

-- display page update status. 
-- @param tabName: like "basic", "work", "contact". It will find a pe:label control called "tabName_result", 
-- if the control does not exist, it will display a popup message
function RegPage:UpdatePageStatus(msgBody, tabName)
	if(not tabName) then
		paraworld.ShowMessage(msgBody)
	else
		if(self:GetNode(tabName.."_result")) then
			self:SetUIValue(tabName.."_result", msgBody);
		end
	end
end

-- save the name value pairs to mcml of the profile application and commit
function RegPage:SaveToProfile(values, tabName)
	local profile = Map3DSystem.App.profiles.app:GetMCMLInMemory() or {};
	if(type(profile) ~= "table") then
		profile = {};
	end
	
	profile.UserInfo = profile.UserInfo or {};
	
	if(not commonlib.partialcompare(profile.UserInfo, values)) then
		commonlib.partialcopy(profile.UserInfo, values);
		RegPage.UpdatePageStatus(self, "正在更新, 请稍候...", tabName)
		Map3DSystem.App.profiles.app:SetMCML(nil, profile, function (uid, appkey, bSucceed)
			if(bSucceed) then
				RegPage.UpdatePageStatus(self, "更新成功！ 谢谢！", tabName)
			else
				RegPage.UpdatePageStatus(self, "暂时无法更新，请稍候再试", tabName)
			end	
		end)
	else
		RegPage.UpdatePageStatus(self, "您并没有做任何修改", tabName)
	end	
end

---------------------------------
-- page event handlers
---------------------------------

-- When clicks the basic info save button in the MCML page: ProfileRegPage.html  
function RegPage.OnSaveBasicInfo(sCtrlName, values)
	if(values.username=="") then
		_guihelper.MessageBox("姓名不能为空")
		return
	end
	RegPage.SaveToProfile(document:GetPageCtrl(), values, "basic")
end

-- When clicks the contact info save button in the MCML page: ProfileRegPage.html  
function RegPage.OnSaveContactInfo(sCtrlName, values)
	RegPage.SaveToProfile(document:GetPageCtrl(), values, "contact")
end

-- When clicks the relationship save button in the MCML page: ProfileRegPage.html  
function RegPage.OnSaveRelationship(sCtrlName, values)
	RegPage.SaveToProfile(document:GetPageCtrl(), values, "dating")
end

-- When clicks the personal info save button in the MCML page: ProfileRegPage.html  
function RegPage.OnSavePersonalInfo(sCtrlName, values)
	RegPage.SaveToProfile(document:GetPageCtrl(), values, "personal")
end


-- When clicks the education info save button in the MCML page: ProfileRegPage.html  
function RegPage.OnSaveEducationInfo(sCtrlName, values)
	RegPage.SaveToProfile(document:GetPageCtrl(), values, "education")
end

-- When clicks the education info save button in the MCML page: ProfileRegPage.html  
function RegPage.OnSaveWorkInfo(sCtrlName, values)
	RegPage.SaveToProfile(document:GetPageCtrl(), values, "work")
end

-- temp image file, a resized image will be saved to this place
local tmpPhotoFileName = "temp/myphoto.jpg";

-- called when a photo file is selected. 
function RegPage.OnSelectPhotoFile(name, filename)
	RegPage.OnRefreshPhotoFile();
end

-- refresh user file
function RegPage.OnRefreshPhotoFile()
	local self = document:GetPageCtrl();
	local filename = commonlib.Encoding.Utf8ToDefault(self:GetUIValue("photopath"));
	
	local _,_,ext = string.find(filename, "%.(%w+)$")
	if(ext) then
		ext = string.lower(ext)
	end	
	if(ext and (ext == "jpg" or ext == "png" or ext == "bmp" or ext == "dds" or ext == "tga")) then
		filename = string.gsub(filename, "\\", "/");
		-- resize image and change file extension and saved to a temp place
		local width, height, filesize = ParaMovie.GetImageInfo(filename)
		if(filesize and filesize>0) then
			local maxWidth, maxHeight = 200, 150;
			local bNeedResize;
			if(width>maxWidth) then
				height = math.floor(height*maxWidth/width)
				width = maxWidth;
				bNeedResize = true;
			end
			if(height>maxHeight) then
				width = math.floor(width*maxHeight/height)
				height = maxHeight;
				bNeedResize = true;
			end
			
			commonlib.log("image file %s is copyed and resized to %s with new size %d %d\n", commonlib.Encoding.DefaultToUtf8(filename), tmpPhotoFileName, width, height)
			ParaMovie.ResizeImage(filename, width, height, tmpPhotoFileName)
			
			ParaAsset.LoadTexture("",tmpPhotoFileName,1):UnloadAsset();
			self:SetUIValue("photo", tmpPhotoFileName);
			RegPage.UpdatePageStatus(self, "请保存您的更改", "uploadphoto")
		else
			RegPage.UpdatePageStatus(self, "无法获得图片文件信息")
		end
	else
		RegPage.UpdatePageStatus(self, string.format("不支持图片格式%s\n请使用jpg, png, bmp, tga, dds格式的图片", tostring(ext)), "uploadphoto")
	end
end

-- upload a user profile image file 
-- When clicks upload photo button in the MCML page: ProfileRegPage.html  
function RegPage.OnUploadUserPhoto(sCtrlName, values)
	local self = document:GetPageCtrl();
	local filename = commonlib.Encoding.Utf8ToDefault(self:GetUIValue("photopath"));
	if(filename and string.find(filename, "^http://")) then
		-- if input is an url, we do not need to upload file. 
		RegPage.SaveToProfile(self, {["photo"] = filename})
	else
		-- if input is a local file, we will upload file first. 
		filename = self:GetUIValue("photo");
		if(filename) then
			filename = string.gsub(filename, ";.*$", "")
		end	
		if(filename ~= tmpPhotoFileName) then
			RegPage.UpdatePageStatus(self, "请尚未指定新图片", "uploadphoto")
			return
		end
		
		
		RegPage.UpdatePageStatus(self, "正在上传, 请稍候...", "uploadphoto")
		local msg = {
			isphoto = true,
			-- this tells that the photo is a head photo. 
			isHeadPic = true,
			src = filename,
			filepath = "profiles/myphoto.jpg",      
			overwrite = 1, -- overwrite it.
		};
		local res = paraworld.map.UploadFileEx(msg, "paraworld", function(msg)
			local bSuccess, errormsg = paraworld.check_result(msg)
			if(bSuccess and msg.fileURL) then
				RegPage.UpdatePageStatus(self, "成功上传", "uploadphoto")
				commonlib.log("uploading user photo succeeded\n")
				RegPage.SaveToProfile(self, {["photo"] = msg.fileURL}, "uploadphoto")
			else
				if(msg and msg.fileSize) then
					RegPage.UpdatePageStatus(self, string.format("正在上传: %d KB", math.floor(tonumber(msg.fileSize)/1000)), "uploadphoto")
				else	
					RegPage.UpdatePageStatus(self, "无法上传: "..tostring(errormsg), "uploadphoto")
					commonlib.log("warning: failed uploading user photo\n")
					commonlib.echo(msg)
				end	
			end
		end)
		if(res == paraworld.errorcode.LoginRequired) then
			RegPage.UpdatePageStatus(self, "请先登陆", "uploadphoto")
		end
	end
end
