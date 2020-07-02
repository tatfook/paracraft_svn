--[[
Title: LoginBox with current login status displayed
Author(s): LiXizhi
Date: 2007/5/11
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/LoginBox.lua");
LoginBox.Show();
LoginBox.Show(true, function()
	--DO something here if logged in.
end);
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/kids_db.lua");
local L = CommonCtrl.Locale("IDE");
		
if(not LoginBox) then LoginBox={}; end

-- web service
LoginBox.webservice_AuthUser  = CommonCtrl.Locale("KidsUI")("AuthUser.asmx");
--LoginBox.webservice_AuthUser  = "http://www.paraengine.com/AuthUser.asmx";
LoginBox.webservice_CheckVersion = CommonCtrl.Locale("KidsUI")("CheckVersion.asmx");
--LoginBox.webservice_CheckVersion = "http://localhost:1225/KidsMovieSite/CheckVersion.asmx";

LoginBox.CommunitySite = CommonCtrl.Locale("KidsUI")("community.aspx");

-- appearance
LoginBox.button_bg = "Texture/kidui/explorer/button.png"
LoginBox.listbox_bg = "Texture/kidui/explorer/listbox_bg.png"
LoginBox.dropdownarrow_bg = "Texture/kidui/explorer/dropdown_arrow.png"
LoginBox.dropdownlist_cont_bg = "Texture/kidui/explorer/editbox256x32.png"
LoginBox.editbox_bg = "Texture/kidui/explorer/editbox128x32.png"

-- tab pages
LoginBox.tabpages = {"loginbox_login", "loginbox_alreadylogin", "loginbox_waiting", };

-- @param nIndex: 1 or 2 or 3
function LoginBox.SwitchTabWindow(nIndex)
	if(LoginBox.tabpages~=nil) then
		_guihelper.SwitchVizGroupByIndex(LoginBox.tabpages, nIndex);
		if(nIndex == 1) then
			-- the login window
			ParaUI.GetUIObject("loginbox_UserName").text = kids_db.User.Name;
			ParaUI.GetUIObject("loginbox_PassWord").text = kids_db.User.Password;
		elseif(nIndex == 2) then
			-- the login status: usually already log in
			if(kids_db.User.IsAuthenticated) then
				ParaUI.GetUIObject("loginbox_loginstatus").text = string.format(L"Hi, %s. You are already signed in.", kids_db.User.Name);
				if(LoginBox.OnSignedIn~=nil) then
					LoginBox.Close();
				end
			else
				ParaUI.GetUIObject("loginbox_loginstatus").text = L"Unable to login, perhaps your user name and password is invalid.";
			end	
		elseif(nIndex == 3)	then
			-- waiting...
		end
	end	
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
-- @param OnSignedIn: string or function or nil; the script or function to be executed when user is authenticated. 
-- if OnSignedIn is not nil, the login window will be automatically closed once logged in. Otherwise, it will display the login-status 
-- and user has to manually close the loginbox.
function LoginBox.Show(bShow, OnSignedIn)
	LoginBox.OnSignedIn = OnSignedIn;
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("LoginBox_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		local width, height = 370, 420
		_this=ParaUI.CreateUIObject("container","LoginBox_cont","_ct", -width/2, -height/2-50,width, height);
		_this.background="Texture/net_bg.png;0 0 470 395";
		_this:SetTopLevel(true);
		_this:AttachToRoot();
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("button", "button2", "_rb", -121, -50, 101, 28)
		_this.text = L"Close";
		_this.onclick = ";LoginBox.Close();"
		_parent:AddChild(_this);

		-- tabControl1
		NPL.load("(gl)script/ide/gui_helper.lua");
		_this = ParaUI.CreateUIObject("container", "tabControl1", "_fi", 22, 40, 20, 65)
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		_parent = ParaUI.GetUIObject("tabControl1");
		-- loginbox_login
		_this = ParaUI.CreateUIObject("container", "loginbox_login", "_fi", 4, 21, 4, 4)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "LoginMessage", "_lt", 16, 12, 256, 16)
		_this.text = L"Please login using your account";
		_this:GetFont("text").color = "165 42 42";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 16, 65, 88, 16)
		_this.text = L"User name:";
		_parent:AddChild(_this);
	
		_this = ParaUI.CreateUIObject("imeeditbox", "loginbox_UserName", "_lt", 117, 62, 139, 26)
		_this.background=LoginBox.editbox_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "loginbox_PassWord", "_lt", 117, 102, 139, 26)
		_this.background=LoginBox.editbox_bg;
		_this.PasswordChar = "*";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "loginbox_btnLogin", "_lt", 19, 231, 101, 28)
		_this.text = L"Login";
		_this.onclick = ";LoginBox.OnClickBtnLogin();"
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "loginbox_btnRegister", "_lt", 155, 231, 101, 28)
		_this.text = L"Register";
		_this.onclick = ";LoginBox.OnClickRegister();"
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label7", "_lt", 16, 146, 64, 16)
		_this.text = L"Domain:";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "loginbox_checkboxRememberUserNamePassword",
			alignment = "_lt",
			left = 19,
			top = 189,
			width = 350,
			height = 20,
			parent = _parent,
			isChecked = true,
			text = L"Remember user name and password",
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 16, 105, 80, 16)
		_this.text = L"Password:";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local domainTable = CommonCtrl.Locale("KidsUI"):GetTable("login domain table");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "loginbox_comboBoxDomain",
			alignment = "_lt",
			left = 117,
			top = 147,
			width = 200,
			height = 26,
			dropdownheight = 106,
 			parent = _parent,
 			container_bg = LoginBox.dropdownlist_cont_bg,
			editbox_bg = "Texture/whitedot.png;0 0 0 0",
			dropdownbutton_bg = LoginBox.dropdownarrow_bg,
			listbox_bg = LoginBox.listbox_bg,
			text = domainTable[1],
			items = domainTable,
		};
		ctl:Show();

		-- loginbox_alreadylogin
		_this = ParaUI.CreateUIObject("container", "loginbox_alreadylogin", "_fi", 4, 21, 4, 4)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent = ParaUI.GetUIObject("tabControl1");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "loginbox_loginstatus", "_lt", 24, 17, 270, 16)
		_this:GetFont("text").color = "165 42 42";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "loginbox_logout", "_lt", 27, 70, 101, 28)
		_this.text = L"sign out";
		_this.onclick = ";LoginBox.OnClickLogout();"
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btn", "_mt", 27, 130, 17, 28)
		_this.text = L"visit community website";
		_this.tooltip = LoginBox.CommunitySite;
		_this.onclick = ";LoginBox.OnClickGotoCommunitySite();"
		_parent:AddChild(_this);

		-- loginbox_waiting
		_this = ParaUI.CreateUIObject("container", "loginbox_waiting", "_fi", 4, 21, 4, 4)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent = ParaUI.GetUIObject("tabControl1");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label3", "_lt", 14, 21, 224, 16)
		_this.text = L"Please wait while login ...";
		_this:GetFont("text").color = "165 42 42";
		_parent:AddChild(_this);

		--_this = ParaUI.CreateUIObject("button", "button1", "_lt", 17, 73, 101, 28)
		--_this.text = L"Stop login";
		--_parent:AddChild(_this);
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
		if(bShow == true) then
			_this:SetTopLevel(true);
		end
	end	
	if(bShow) then
		KidsUI.PushState({name = "LoginBox", OnEscKey = LoginBox.Close});
		
		-- switch to a tab page
		if(kids_db.User.IsAuthenticated) then
			LoginBox.SwitchTabWindow(2)
		else
			LoginBox.SwitchTabWindow(1)
		end	
	else
		KidsUI.PopState("LoginBox");
	end
end

LoginBox.OnSignedIn = nil;
function LoginBox.OnSignedIn_imp()
	if(kids_db.User.IsAuthenticated) then
		if(LoginBox.OnSignedIn~=nil) then
			if(type(LoginBox.OnSignedIn) == "string") then
				NPL.DoString(LoginBox.OnSignedIn);
			elseif(type(LoginBox.OnSignedIn) == "function") then
				LoginBox.OnSignedIn();
			end	
		end
	end	
end

function LoginBox.OnClickGotoCommunitySite()
	ParaGlobal.ShellExecute("open", "iexplore.exe", LoginBox.CommunitySite, nil, 1); 
end

-- close window
function LoginBox.Close()
	KidsUI.PopState("LoginBox");
	ParaUI.Destroy("LoginBox_cont");
	LoginBox.OnSignedIn_imp();
end

-- called when user logs in.
function LoginBox.OnClickBtnLogin(sCtrlName)
	-- get the following input from the UI
	local username, password, domainname;
	
	tmp = ParaUI.GetUIObject("loginbox_UserName");
	if(tmp:IsValid() == true) then 
		username = tmp.text;
		if(user == "") then
			_guihelper.MessageBox(L"Please enter your user name\r\n");
			return;
		end
	end
	tmp = ParaUI.GetUIObject("loginbox_PassWord");
	if(tmp:IsValid() == true) then 
		password = tmp.text;
		if(password == "") then
			_guihelper.MessageBox(L"Password can not be empty\n");
			return;
		end
	end
	
	tmp = CommonCtrl.GetControl("loginbox_comboBoxDomain");
	if(tmp~=nil) then 
		domainname = tmp:GetText();
	end
	-- login to remote server using AuthUser.asmx web service
	if(username~=nil and password~=nil) then
		LoginBox.SwitchTabWindow(3);
		-- since it might take some time for the web service to load; we may display the waiting dialog by forcing render twice.
		--ParaEngine.ForceRender();ParaEngine.ForceRender();
		
		-- send out the web serivce
		local msg = {
			username = username,
			Password = password,
			Login = true,
		}
		NPL.RegisterWSCallBack(LoginBox.webservice_AuthUser, string.format("LoginBox.AuthUser_Callback(\"%s\", \"%s\");", username, password));
		NPL.activate(LoginBox.webservice_AuthUser, msg);
	end
end

-- web service call back
function LoginBox.AuthUser_Callback(username, password)
	if(msg == true) then
		kids_db.User.IsAuthenticated = true;
		kids_db.User.Name = username;
		kids_db.User.Password = password;
		LoginBox.SwitchTabWindow(2);
		
		if(not kids_db.User.userinfo.IsCommunityMember) then
			kids_db.User.userinfo.IsCommunityMember =  true;
			kids_db.User.SaveUserInfo();
		end
		
		-- save the user info to file for next time log in		
		local checkBox = CommonCtrl.GetControl("loginbox_checkboxRememberUserNamePassword");
		if (checkBox~=nil and checkBox.isChecked) then
			kids_db.User.SaveCredential(username, password);
		else
			-- TODO: delete the config/npl_credential.txt file	
		end
		-- check version as a background process, TODO: have a better auto patcher than manually update. 
		if(true) then
			LoginBox.CheckVersion();
		end	
	elseif(msg==nil) then
		_guihelper.MessageBox(L"Network is not available, please try again later");
		LoginBox.Close();
	else
		LoginBox.SwitchTabWindow(2);
	end
end

function LoginBox.CheckVersion()
	-- send out the web serivce
	local msg = {
		username = username,
		ClientVersion = ParaEngine.GetVersion(),
		ServerVersion = "1.0",
	}
	NPL.RegisterWSCallBack(LoginBox.webservice_CheckVersion, "LoginBox.CheckVersion_Callback()");
	NPL.activate(LoginBox.webservice_CheckVersion, msg);
end

function LoginBox.CheckVersion_Callback()
	--commonlib.DumpWSResult("CheckVersion_Callback");
	if(msg ~= nil) then
		if(msg.ClientVersion ~= ParaEngine.GetVersion()) then
			LoginBox.UpdateURL = msg.UpdateURL;
			if(not msg.ClientMustUpdate) then
				_guihelper.MessageBox(L"A new version is detected. Do you want to update now?", function()
					ParaGlobal.ShellExecute("open", "iexplore.exe", LoginBox.UpdateURL, nil, 1); 
				end)
			else
				_guihelper.MessageBox(L"A new version is detected. You must update in order to use networking functions. Do you want to update now?", function()
					ParaGlobal.ShellExecute("open", "iexplore.exe", LoginBox.UpdateURL, nil, 1); 
				end)
			end
		else
			log("Cilent version verified via web service\n");
		end
	else
		log("Unable to Check version via web service\n");
	end
end

-- open our community web site's registration page
function LoginBox.OnClickRegister()
	ParaEngine.SetWindowedMode(true);
	ParaGlobal.ShellExecute("open", "iexplore.exe", CommonCtrl.Locale("KidsUI")("Register.aspx"), "", 1); 
end
	
-- log out
function LoginBox.OnClickLogout()
	if(kids_db.User.IsAuthenticated) then
		kids_db.User.IsAuthenticated = false;
		LoginBox.SwitchTabWindow(1);
	else
		LoginBox.SwitchTabWindow(1);
	end
end