--[[
Title: code behind for page uploadphoto.html
Author(s): LiXizhi
Date: 2009/1/1
Desc:  script/apps/Aquarius/Profile/uploadphoto.html?uid=&nid=
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local uploadphotoPage = {};
commonlib.setfield("MyCompany.Aquarius.uploadphotoPage", uploadphotoPage)

---------------------------------
-- page event handlers
---------------------------------

-- init
function uploadphotoPage.OnInit()
	local self = document:GetPageCtrl();
	
	-- refresh photo node
	local photo = System.App.profiles.ProfileManager.GetMyInfo("photo");
	if(photo) then
		self:SetNodeValue("photo", photo);
	end	
end

-- display page update status. 
-- @param tabName: like "basic", "work", "contact". It will find a pe:label control called "tabName_result", 
-- if the control does not exist, it will display a popup message
function uploadphotoPage:UpdatePageStatus(msgBody, tabName)
	if(not tabName) then
		paraworld.ShowMessage(msgBody)
	else
		if(self:GetNode(tabName.."_result")) then
			self:SetUIValue(tabName.."_result", msgBody);
		end
	end
end
-- save the name value pairs to mcml of the profile application and commit
function uploadphotoPage:SaveToProfile(values, tabName)

	-- this is not needed anymore
	-- save to user info
	--paraworld.users.setInfo({
			--sessionkey = System.User.sessionkey,
			--photo = values["photo"],
		--}, "uploadphoto",
		--function(msg)
			--if(msg and msg.issuccess) then
				--uploadphotoPage.UpdatePageStatus(self, "更新成功！ 谢谢！", tabName)
				--commonlib.log("user photo %s successfully uploaded\n", values["photo"])
				---- force refreshing
				--paraworld.users.getInfo({nids = System.User.nid, fields= "userid, nid, username, nickname, photo"}, "AquariusMyselfName");
				---- TODO: think of a way to refresh all related photos in current GUI. 
			--else
				--uploadphotoPage.UpdatePageStatus(self, "暂时无法更新，请稍候再试", tabName)
				--commonlib.echo(msg)
			--end
		--end)
	
	-- refresh mcml userinfo
	System.App.profiles.ProfileManager.SetMCMLUserInfo(values, function (uid, appkey, bSucceed)
		if(bSucceed) then
			uploadphotoPage.UpdatePageStatus(self, "更新成功！ 请点击刷新", tabName)
		end	
	end)
	-- we will refresh user info.
	uploadphotoPage.OnClickRefresh();
end


-- temp image file, a resized image will be saved to this place
local tmpPhotoFileName = "temp/myphoto.jpg";

-- called when a photo file is selected. 
function uploadphotoPage.OnSelectPhotoFile(name, filename)
	uploadphotoPage.OnRefreshPhotoFile();
end

-- refresh the desktop photos
function uploadphotoPage.OnClickRefresh()
	-- force refreshing: the following code may not be working, due to distributed cache system. 
	System.App.profiles.ProfileManager.GetUserInfo(nil, nil, function(msg)
		commonlib.echo(msg)
		-- update the user photo. Maybe a better function in future. 
		MyCompany.Aquarius.Desktop.Profile.UpdateUserPhoto();
	end, "access plus 0 day")
end

-- refresh user file
function uploadphotoPage.OnRefreshPhotoFile()
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
			uploadphotoPage.UpdatePageStatus(self, "请保存您的更改", "uploadphoto")
		else
			uploadphotoPage.UpdatePageStatus(self, "无法获得图片文件信息")
		end
	else
		uploadphotoPage.UpdatePageStatus(self, string.format("不支持图片格式%s\n请使用jpg, png, bmp, tga, dds格式的图片", tostring(ext)), "uploadphoto")
	end
end

-- upload a user profile image file 
-- When clicks upload photo button in the MCML page: ProfileuploadphotoPage.html  
function uploadphotoPage.OnUploadUserPhoto(sCtrlName, values)
	local self = document:GetPageCtrl();
	local filename = commonlib.Encoding.Utf8ToDefault(self:GetUIValue("photopath"));
	if(filename and string.find(filename, "^http://")) then
		-- if input is an url, we do not need to upload file. 
		uploadphotoPage.SaveToProfile(self, {["photo"] = filename})
	else
		-- if input is a local file, we will upload file first. 
		filename = self:GetUIValue("photo");
		if(filename) then
			filename = string.gsub(filename, ";.*$", "")
		end	
		if(filename ~= tmpPhotoFileName) then
			uploadphotoPage.UpdatePageStatus(self, "请尚未指定新图片", "uploadphoto")
			return
		end
		
		uploadphotoPage.UpdatePageStatus(self, "正在上传, 请稍候...", "uploadphoto")
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
				uploadphotoPage.UpdatePageStatus(self, "成功上传", "uploadphoto")
				commonlib.log("uploading user photo %s succeeded\n", msg.fileURL);
				uploadphotoPage.SaveToProfile(self, {["photo"] = msg.fileURL}, "uploadphoto")
			else
				if(msg and msg.fileSize) then
					uploadphotoPage.UpdatePageStatus(self, string.format("正在上传,请耐心等待...(%d KB)", math.floor(tonumber(msg.fileSize)/1000)), "uploadphoto")
				else	
					uploadphotoPage.UpdatePageStatus(self, "无法上传: "..tostring(errormsg), "uploadphoto")
					commonlib.log("warning: failed uploading user photo\n")
					commonlib.echo(msg)
				end	
			end
		end)
		if(res == paraworld.errorcode.LoginRequired) then
			uploadphotoPage.UpdatePageStatus(self, "请先登陆", "uploadphoto")
		end
	end
end
