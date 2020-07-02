--[[
Title: standard Login window 
Author(s): LiXizhi
Date: 2008/1/24
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Login/LoginWnd.lua");
Map3DSystem.App.Login.ShowLoginWnd(app);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
local L = CommonCtrl.Locale("IDE");

NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

-- create class
local LoginWnd = {};
commonlib.setfield("Map3DSystem.App.Login.LoginWnd", LoginWnd);

-- predefined addresses
LoginWnd.CommunitySite = CommonCtrl.Locale("KidsUI")("community.aspx");
LoginWnd.RegistrationPage = CommonCtrl.Locale("KidsUI")("Register.aspx")

-- tab pages
LoginWnd.tabpages = {"loginbox_login", "loginbox_alreadylogin", "loginbox_waiting", };

-- @param nIndex: 1 or 2 or 3
function LoginWnd.SwitchTabWindow(nIndex)
	if(LoginWnd.tabpages~=nil) then
		_guihelper.SwitchVizGroupByIndex(LoginWnd.tabpages, nIndex);
		if(nIndex == 1) then
			-- the login window
			ParaUI.GetUIObject("loginbox_UserName").text = Map3DSystem.User.Name;
			ParaUI.GetUIObject("loginbox_PassWord").text = Map3DSystem.User.Password;
		elseif(nIndex == 2) then
			-- the login status: usually already log in
			if(Map3DSystem.User.IsAuthenticated) then
				ParaUI.GetUIObject("loginbox_loginstatus").text = string.format(L"Hi, %s. You are already signed in.", Map3DSystem.User.Name);
				if(LoginWnd.OnSignedIn~=nil) then
					LoginWnd.Close();
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
-- @param _parent: parent window inside which the content is displayed. it can be nil.
function Map3DSystem.App.Login.LoginWnd.Show(bShow, _parent, parentWindow)
	local _this;
	Map3DSystem.App.Login.LoginWnd.parentWindow = parentWindow;
	
	_this=ParaUI.GetUIObject("LoginWnd_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		if(_parent==nil) then
			local width, height = 370, 420
			_this=ParaUI.CreateUIObject("container","LoginWnd_cont","_ct",-width/2, -height/2-50,width, height);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", "LoginWnd_cont", "_fi",0,0,0,0);
			_this.background = ""
			_parent:AddChild(_this);
		end	
		_parent = _this;

		---------------------------------------
		-- loginbox_login
		_this = ParaUI.CreateUIObject("container", "loginbox_login", "_fi", 0,0,0,0)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		-- Title text
		_this = ParaUI.CreateUIObject("text", "LoginMessage", "_lt", 5, 18, 200, 16)
		_this.text = L"Please login using your account";
		_this:GetFont("text").color = "0 120 0";
		_parent:AddChild(_this);
		
		-- name:
		local left, top, width, height= 5, 55, 130, 22;
		_this = ParaUI.CreateUIObject("text", "label1", "_lt", left, top, 55, 16)
		_this.text = L"User name:";
		_parent:AddChild(_this);
	
		_this = ParaUI.CreateUIObject("imeeditbox", "loginbox_UserName", "_lt", left+60, top, width, height)
		_parent:AddChild(_this);

		-- password:
		top = top + height + 5;
		_this = ParaUI.CreateUIObject("text", "label2", "_lt", left, top, 55, 16)
		_this.text = L"Password:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "loginbox_PassWord", "_lt", left+60, top, width, height)
		_this.PasswordChar = "*";
		_parent:AddChild(_this);

		-- domain:
		top = top + height + 5;
		
		_this = ParaUI.CreateUIObject("text", "label7", "_lt", left, top, 64, 16)
		_this.text = L"Domain:";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local domainTable = CommonCtrl.Locale("KidsUI"):GetTable("login domain table");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "loginbox_comboBoxDomain",
			alignment = "_lt",
			left = left+60,
			top = top,
			width = width,
			height = height,
			dropdownheight = 70,
 			parent = _parent,
			text = domainTable[1],
			items = domainTable,
		};
		ctl:Show();
		
		-- remember check box
		top = top + height + 5;
		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "loginbox_checkboxRememberUserNamePassword",
			alignment = "_lt",
			left = left,
			top = top,
			width = 200,
			height = height,
			parent = _parent,
			isChecked = true,
			text = L"Remember user name and password",
		};
		ctl:Show();

		-- login/register button
		top = top + height + 10;
		_this = ParaUI.CreateUIObject("button", "loginbox_btnLogin", "_lt", left, top , 80, height)
		_this.text = L"Login";
		_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/btn_bg_highlight.png: 4 4 4 4";
		_this.onclick = ";Map3DSystem.App.Login.LoginWnd.OnClickBtnLogin();"
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "loginbox_btnRegister", "_lt", left+85, top, 80, height)
		_this.text = L"Register";
		_this.onclick = ";Map3DSystem.App.Login.LoginWnd.OnClickRegister();"
		_parent:AddChild(_this);
		
		---------------------------------------
		-- loginbox_alreadylogin
		_this = ParaUI.CreateUIObject("container", "loginbox_alreadylogin", "_fi", 0,0,0,0)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent = ParaUI.GetUIObject("LoginWnd_cont");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "loginbox_loginstatus", "_lt", 5, 17, 200, 16)
		_this:GetFont("text").color = "165 42 42";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "loginbox_logout", "_lt", 27, 70, 80, 22)
		_this.text = L"sign out";
		_this.onclick = ";Map3DSystem.App.Login.LoginWnd.OnClickLogout();"
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btn", "_mt", 27, 130, 17, 28)
		_this.text = L"visit community website";
		_this.tooltip = LoginWnd.CommunitySite;
		_this.onclick = ";Map3DSystem.App.Login.LoginWnd.OnClickGotoCommunitySite();"
		_parent:AddChild(_this);

		-- loginbox_waiting
		_this = ParaUI.CreateUIObject("container", "loginbox_waiting", "_fi", 0,0,0,0)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent = ParaUI.GetUIObject("LoginWnd_cont");
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
	end	
	if(bShow) then
		-- switch to a tab page
		if(Map3DSystem.User.IsAuthenticated) then
			LoginWnd.SwitchTabWindow(2)
		else
			LoginWnd.SwitchTabWindow(1)
		end	
	else
		
	end
end

-- callback function
LoginWnd.OnSignedIn = nil;

-- set the call back function which will be called after user successfully logs in. 
function LoginWnd.SetLoginCallBack(funcPtr)
	LoginWnd.OnSignedIn =funcPtr;
end

function LoginWnd.OnSignedIn_imp()
	if(Map3DSystem.User.IsAuthenticated) then
		if(LoginWnd.OnSignedIn~=nil) then
			if(type(LoginWnd.OnSignedIn) == "string") then
				NPL.DoString(LoginWnd.OnSignedIn);
			elseif(type(LoginWnd.OnSignedIn) == "function") then
				LoginWnd.OnSignedIn();
			end	
		end
	end	
end

-- open the community website
function LoginWnd.OnClickGotoCommunitySite()
	Map3DSystem.App.Commands.Call("File.WebBrowser", LoginWnd.CommunitySite);
end

-- close window
function LoginWnd.Close()
	ParaUI.Destroy("LoginWnd_cont");
	LoginWnd.OnSignedIn_imp();
end

-- called when user logs in.
function LoginWnd.OnClickBtnLogin(sCtrlName)
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
		LoginWnd.SwitchTabWindow(3);
		-- since it might take some time for the web service to load; we may display the waiting dialog by forcing render twice.
		--ParaEngine.ForceRender();ParaEngine.ForceRender();
		
		-- send out the web serivce
		local msg = {
			username = username,
			Password = password,
		}
		paraworld.auth.AuthUser(msg, "LoginWnd", LoginWnd.AuthUser_Callback, msg)
	end
end

-- web service call back
function LoginWnd.AuthUser_Callback(msg, params)
	if(msg~=nil and msg.result) then
		Map3DSystem.User.Name = params.username;
		Map3DSystem.User.Password = params.Password;
		LoginWnd.SwitchTabWindow(2);
		
		if(not Map3DSystem.User.userinfo.IsCommunityMember) then
			Map3DSystem.User.userinfo.IsCommunityMember =  true;
			Map3DSystem.User.SaveUserInfo();
		end
		
		-- save the user info to file for next time log in		
		local checkBox = CommonCtrl.GetControl("loginbox_checkboxRememberUserNamePassword");
		if (checkBox~=nil and checkBox.isChecked) then
			Map3DSystem.User.SaveCredential(Map3DSystem.User.Name, Map3DSystem.User.Password);
		else
			-- TODO: delete the config/npl_credential.txt file	
		end
		-- check version as a background process, TODO: have a better auto patcher than manually update. 
		if(true) then
			LoginWnd.CheckVersion();
		end	
	elseif(msg==nil) then
		_guihelper.MessageBox(L"Network is not available, please try again later");
		LoginWnd.Close();
	else
		LoginWnd.SwitchTabWindow(2);
	end
end

-- check whether the client needs to be updated. 
function LoginWnd.CheckVersion()
	-- send out the web serivce
	paraworld.auth.CheckVersion({}, "LoginWnd", LoginWnd.CheckVersion_Callback)
end

function LoginWnd.CheckVersion_Callback(msg)
	--commonlib.DumpWSResult("CheckVersion_Callback");
	if(msg ~= nil) then
		if(msg.ClientVersion ~= ParaEngine.GetVersion()) then
			LoginWnd.UpdateURL = msg.UpdateURL;
			if(not msg.ClientMustUpdate) then
				_guihelper.MessageBox(L"A new version is detected. Do you want to update now?", function()
					Map3DSystem.App.Commands.Call("File.WebBrowser", LoginWnd.UpdateURL);
				end)
			else
				_guihelper.MessageBox(L"A new version is detected. You must update in order to use networking functions. Do you want to update now?", function()
					Map3DSystem.App.Commands.Call("File.WebBrowser", LoginWnd.UpdateURL);
				end)
			end
		else
			log("Client version verified via web service\n");
		end
	else
		log("Unable to Check version via web service\n");
	end
end

-- open our community web site's registration page
function LoginWnd.OnClickRegister()
	ParaEngine.SetWindowedMode(true);
	Map3DSystem.App.Commands.Call("File.WebBrowser", LoginWnd.RegistrationPage);
end
	
-- log out
function LoginWnd.OnClickLogout()
	if(Map3DSystem.User.IsAuthenticated) then
		Map3DSystem.User.IsAuthenticated = false;
		-- TODO: do a real server side logout and destroy sessions: paraworld.auth.Logout({}, "LoginWnd")
		LoginWnd.SwitchTabWindow(1);
	else
		LoginWnd.SwitchTabWindow(1);
	end
end


-- display the main Login window for the current user.
function Map3DSystem.App.Login.ShowLoginWnd(_app)
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _wnd = _app:FindWindow("LoginWnd") or _app:RegisterWindow("LoginWnd", nil, Map3DSystem.App.Login.LoginWnd.MSGProc);
	
	local _appName, _wndName, _document, _frame;
	_frame = Map3DSystem.UI.Windows.GetWindowFrame(_wnd.app.name, _wnd.name);
	if(_frame) then
		_appName = _frame.wnd.app.name;
		_wndName = _frame.wnd.name;
		_document = ParaUI.GetUIObject(_appName.."_".._wndName.."_window_document");
	else
		local param = {
			wnd = _wnd,
			--isUseUI = true,
			icon = "Texture/3DMapSystem/MainBarIcon/Modify.png",
			iconSize = 48,
			text = "登陆",
			style = Map3DSystem.UI.Windows.Style[1],
			maximumSizeX = 900,
			maximumSizeY = 1000,
			minimumSizeX = 100,
			minimumSizeY = 100,
			isShowIcon = true,
			--opacity = 100, -- [0, 100]
			isShowMaximizeBox = false,
			isShowMinimizeBox = false,
			isShowAutoHideBox = false,
			allowDrag = true,
			allowResize = false,
			initialPosX = 300,
			initialPosY = 270,
			initialWidth = 210,
			initialHeight = 250,
			
			ShowUICallback =Map3DSystem.App.Login.LoginWnd.Show,
		};
		_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	end
	Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
end

function Map3DSystem.App.Login.LoginWnd.MSGProc(window, msg)
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		Map3DSystem.UI.Windows.ShowWindow(false, Map3DSystem.App.Login.LoginWnd.parentWindow.app.name, msg.wndName);
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end