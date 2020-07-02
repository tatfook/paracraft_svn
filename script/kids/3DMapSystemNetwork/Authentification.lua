--[[
Title: Authentification Network methods for 3D Map system
Author(s): WangTian
Date: 2007/8/30
Desc: Authentification Network methods for 3D Map system
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/Authentification.lua");
Map3DSystem.Network.Authentification.xxx();
------------------------------------------------------------
]]


NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

commonlib.echo("\n obsoleted Map3DSystem.Network.Authentification\n\n")
if(not Map3DSystem.Network.Authentification) then Map3DSystem.Network.Authentification = {}; end

function Map3DSystem.Network.Authentification.Login(username, password, domain, callback)

	local webservice_AuthUser  = CommonCtrl.Locale("KidsUI")("AuthUser.asmx");
	
	-- login to remote server using AuthUser.asmx web service
	if(username~=nil and password~=nil) then
		--LoginBox.SwitchTabWindow(3);
		-- since it might take some time for the web service to load
		
		-- send out the web serivce
		local msg = {
			username = username,
			Password = password,
			Login = true,
		}
		
		Map3DSystem.Network.Authentification.Login_Caller_Callback = callback;
		
		local callbackString = string.format("Map3DSystem.Network.Authentification.Login_Callback(\"%s\", \"%s\");", username, password);
		NPL.RegisterWSCallBack(webservice_AuthUser, callbackString);
		NPL.activate(webservice_AuthUser, msg);
	end
end

function Map3DSystem.Network.Authentification.Login_Callback(username, password)

	if(msg == true) then
		Map3DSystem.User.IsAuthenticated = true;
		Map3DSystem.User.Name = username;
		Map3DSystem.User.Password = password;
		--LoginBox.SwitchTabWindow(2);
		
		if(not Map3DSystem.User.userinfo.IsCommunityMember) then
			Map3DSystem.User.userinfo.IsCommunityMember =  true;
			Map3DSystem.User.userinfo.SaveUserInfo();
		end
		
		-- save the user info to file for next time log in		

		--kids_db.User.SaveCredential(username, password);
		
		--Map3DSystem.ShowAuthenticatedUI()
		
	elseif(msg==nil) then
		_guihelper.MessageBox("Network is not available, please try again later");
	else
		--LoginBox.SwitchTabWindow(2);
		_guihelper.MessageBox("Not Authenticated.");
	end
	
	if(Map3DSystem.Network.Authentification.Login_Caller_Callback) then
		Map3DSystem.Network.Authentification.Login_Caller_Callback(username, password);
	end
end