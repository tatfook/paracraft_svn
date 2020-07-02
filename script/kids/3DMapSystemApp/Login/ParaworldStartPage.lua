--[[
Title: The ParaWorld Start Page
Author(s): LiXizhi
Date: 2008/1/28
Desc: it contains a user customizable mini scene and a MCML browser window.   
The browser window will show StartPage.html by default
if the command line contains "startpage", it will be used as startup page

---++ Switch front page url. 
one can call below to navigate the front page to a different url.
<verbatim>
	Map3DSystem.App.Login.GotoPage(url, cachePolicy)
</verbatim>

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Login/ParaworldStartPage.lua");
Map3DSystem.App.Login.ParaworldStartPage.ShowWnd(app);
Map3DSystem.App.Login.ParaworldStartPage.Show(bShow, _parent, parentWindow)
Map3DSystem.App.Login.GotoPage(url, cachePolicy)
-------------------------------------------------------
]]
local L = CommonCtrl.Locale("ParaWorld");


-- common control library
NPL.load("(gl)script/ide/common_control.lua");

commonlib.setfield("Map3DSystem.App.Login.ParaworldStartPage", {});

-- attributes: 
--Map3DSystem.App.Login.StartPageUrl = "%WIKI%/Main/ParaWorldStartPageMCML";
Map3DSystem.App.Login.StartPageUrl = "script/kids/3DMapSystemApp/Login/StartPage.html";
--Map3DSystem.App.Login.RegPageUrl = "%WIKI%/Main/ParaWorldNewUserRegPageMCML";
Map3DSystem.App.Login.RegPageUrl = "script/kids/3DMapSystemApp/Login/NewUserRegPage.html";
-- login app browser name. 
Map3DSystem.App.Login.browsername = "LoginWnd.ActiveDesktopMCML";
------------------------------------------
-- app config
--
--  "ShowAddressBar": whether to show address bar, default to false. 
--  "StartPageMCML": url of start page default to Map3DSystem.App.Login.StartPageUrl
--  "InitScene": a table of {Text = "缺省背景",FilePath = "worlds/login_world", bRenderNPC = true, bRenderPlayer = nil,} default to Map3DSystem.App.Login.DefaultBGScenes[1]
--  "RecentlyOpenedScenes": a list of table of {Text = "缺省背景",FilePath = "worlds/login_world", bRenderNPC = true, bRenderPlayer = nil,} 
------------------------------------------

-- private: the last bgInfo 
Map3DSystem.App.Login.ParaworldStartPage.LastBGInfo = nil;

-- system bg files. 
local DefaultBGScenes = {
	{
		-- Display Name
		Text = L"官方缺省背景",
		-- world path, either zip file or disk folder is supported. *.jpg, *.png, *.dds, *.bmp, *.avi, *.wmv,*.swf, is also supported.
		FilePath = "worlds/MyWorlds/LoginWorld", 
		-- render to render NPC
		bRenderNPC = true, 
		-- whether to render the current player at zero position. 
		bRenderPlayer = true,
	},
	{
		-- Display Name
		Text = L"新手村背景",
		-- world path, either zip file or disk folder is supported. *.jpg, *.png, *.dds, *.bmp, *.avi, *.wmv,*.swf, is also supported.
		FilePath = L"worlds/Official/新手之路", 
		-- render to render NPC
		bRenderNPC = true, 
		-- whether to render the current player at zero position. 
		bRenderPlayer = true,
	},
	--{
		---- Display Name
		--Text = "官方新闻",
		---- world path, either zip file or disk folder is supported. *.jpg, *.png, *.dds, *.bmp, *.avi, *.wmv,*.swf, is also supported.
		--FilePath = "Texture/productcover_cn.png", 
		---- render to render NPC
		--bRenderNPC = true, 
		---- whether to render the current player at zero position. 
		--bRenderPlayer = nil,
	--},
};
Map3DSystem.App.Login.DefaultBGScenes = DefaultBGScenes;

-- show the desktop window
function Map3DSystem.App.Login.ParaworldStartPage.ShowWnd(_app)
	local _wnd = _app:FindWindow("ParaworldStartPage") or _app:RegisterWindow("ParaworldStartPage", nil, Map3DSystem.App.Login.ParaworldStartPage.MSGProc);
	local _wndFrame = _wnd:GetWindowFrame();
	if(not _wndFrame) then
		_wndFrame = _wnd:CreateWindowFrame{
			icon = "Texture/3DMapSystem/common/action.png",
			text = L"开始桌面页",
			initialWidth = 160,
			maximumSizeX = 800,
			maximumSizeY = 650,
			minimumSizeX = 400,
			minimumSizeY = 250,
			allowDrag = true,
			allowResize = true,
			initialWidth = 600,
			initialHeight = 400,
			ShowUICallback =Map3DSystem.App.Login.ParaworldStartPage.Show,
		};
	end
	_wnd:ShowWindowFrame(true);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
-- @param _parent: parent window inside which the content is displayed. it can be nil.
-- @param url: if nil, it will show the default startup page. otherwise the url is shown. 
function Map3DSystem.App.Login.ParaworldStartPage.Show(bShow, _parent, parentWindow, url)
	local _this;
	Map3DSystem.App.Login.ParaworldStartPage.parentWindow = parentWindow;
	
	_this=ParaUI.GetUIObject("Login.ParaworldStartPage_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		if(_parent==nil) then
			_this=ParaUI.CreateUIObject("container","Login.ParaworldStartPage_cont","_lt",100,50, 606, 390);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", "Login.ParaworldStartPage_cont", "_fi",0,0,0,0);
			_this.background = ""
			_parent:AddChild(_this);
		end	
		_parent = _this;
		
		------------------------------------
		-- canvas
		------------------------------------
		NPL.load("(gl)script/ide/Canvas3D.lua");
		local ctl = CommonCtrl.Canvas3D:new{
			name = "ParaworldStartPage.canvas",
			alignment = "_fi",
			left = 0, top=-100,
			width = 0, -- NOTE: the scene is a little scaled on width with 200 px wider
			height = -10, -- NOTE: the scene is a little scaled on height from 512 to 612
			parent = _parent,
			autoRotateSpeed = 0.05,
			-- making it not interactive
			IsInteractive = false,
			miniscenegraphname = "StartPage",
			IsActiveRendering = true,
		};
		ctl:Show();
		
		
		_this = ParaUI.CreateUIObject("button", "btnChangeBg", "_lt", 10, 10, 90, 20);
		_this.text = L"更改背景";
		_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4";
		_this.onclick = ";Map3DSystem.App.Login.ParaworldStartPage.ShowBGSelectionMenu()";
		_parent:AddChild(_this);
		
		local bShowNavBar = false;
		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "LoginWnd.ShowActiveDesktop",
			alignment = "_lt",
			left = 110,
			top = 12,
			width = 80,
			height = 16,
			parent = _parent,
			isChecked = Map3DSystem.App.Login.app:ReadConfig("ShowAddressBar", bShowNavBar),
			text = L"地址栏",
			oncheck = Map3DSystem.App.Login.ParaworldStartPage.OnShowActiveDesktop,
		};
		ctl:Show();
		
		NPL.load("(gl)script/kids/3DMapSystemApp/mcml/BrowserWnd.lua");
		local ctl = Map3DSystem.mcml.BrowserWnd:new{
			name = Map3DSystem.App.Login.browsername,
			alignment = "_fi",
			left=5, top = 33,
			width = 5,
			height = 0,
			parent = _parent,
		};
		ctl:Show();
		ctl.DisplayNavBar = true;
		ctl.DisplayNavAddress = Map3DSystem.App.Login.app:ReadConfig("ShowAddressBar", bShowNavBar);
		ctl:CreateNavBar(_parent, "_mt", 190, 5, 5,30);

		-- Load last opened bg image
		if(Map3DSystem.App.Login.ParaworldStartPage.LastBGInfo == nil)  then
			-- if file does not exist, use the first system default one. 
			Map3DSystem.App.Login.ParaworldStartPage.LastBGInfo = Map3DSystem.App.Login.app:ReadConfig("InitScene", DefaultBGScenes[1])
		end
		Map3DSystem.App.Login.ParaworldStartPage.SwitchBG(Map3DSystem.App.Login.ParaworldStartPage.LastBGInfo);
	else
		if(not bShow) then
			Map3DSystem.App.Login.ParaworldStartPage.OnDestory()
		end
	end	
end

function Map3DSystem.App.Login.ParaworldStartPage.OnShowActiveDesktop(sCtrlName, IsChecked)
	local activeDeskTop = CommonCtrl.GetControl(Map3DSystem.App.Login.browsername);
	if(activeDeskTop)then
		Map3DSystem.App.Login.app:WriteConfig("ShowAddressBar", IsChecked);
		activeDeskTop:ShowAddressBar(IsChecked);
	end
end

-- user clicked to change bg
function Map3DSystem.App.Login.ParaworldStartPage.OnClickSwitchBG(treeNode)
	local res;
	if(treeNode == nil) then
		res = Map3DSystem.App.Login.ParaworldStartPage.SwitchBG(nil);
	elseif(treeNode.type == "sys") then
		if(treeNode.fileIndex~=nil) then
			local bgInfo = DefaultBGScenes[treeNode.fileIndex];
			res = Map3DSystem.App.Login.ParaworldStartPage.SwitchBG(bgInfo);
		end
	elseif(treeNode.type == "user") then
		local bgInfo = treeNode.bgInfo;
		res = Map3DSystem.App.Login.ParaworldStartPage.SwitchBG(bgInfo);
	end
end


-- allow the user to open a bg from a world, image file, etc. 
function Map3DSystem.App.Login.ParaworldStartPage.OnClickBGFromFile()
	-- show the open file dialog. 
	NPL.load("(gl)script/ide/OpenFileDialog.lua");
	local ctl = CommonCtrl.OpenFileDialog:new{
		name = "OpenFileDialog1",
		alignment = "_ct",
		left=-256, top=-150,
		width = 512,
		height = 380,
		parent = nil,
		fileextensions = {L"3D世界(*.zip;*.)", L"图片(*.jpg; *.png; *.dds)", L"视频(*.avi; *.wmv; *.swf)", L"世界目录(*.)", L"全部文件(*.*)", },
		folderlinks = {
			{path = "worlds/MyWorlds", text = L"我的世界"},
			{path = "worlds/", text = L"全部3D世界"},
			{path = "Texture/", text = L"图片和视频"},
		},
		onopen = function(sCtrlName, filename) 
			local bgInfo = {
				Text = ParaIO.GetFileName(filename);
				FilePath = filename,
			}
			if(Map3DSystem.App.Login.ParaworldStartPage.SwitchBG(bgInfo)) then
			end
		end
	};
	ctl:Show(true);
end


--[[ switching to the bg
@param bgInfo: if nil, an empty bg is used, otherwise {
	-- Display Name
	Text = "帕拉巫缺省背景",
	-- world path, either zip file or disk folder is supported. *.jpg, *.png, *.dds, *.bmp, *.avi, *.wmv,*.swf, is also supported.
	FilePath = "worlds/login_world", 
	-- render to render NPC
	bRenderNPC = true, 
	-- whether to render the current player at zero position. 
	bRenderPlayer = nil,
}
@return: return true if succeed. 
]]
function Map3DSystem.App.Login.ParaworldStartPage.SwitchBG(bgInfo)
	local res;
	ParaScene.DeleteMiniSceneGraph("miniGameScene");
	
	local ctl = CommonCtrl.GetControl("ParaworldStartPage.canvas");
	if(ctl == nil)then
		return;
	end	
	
	Map3DSystem.App.Login.ParaworldStartPage.LastBGInfo = bgInfo;
	
	if(bgInfo == nil or bgInfo.FilePath == nil or bgInfo.FilePath == "") then
		-- if bgInfo is nil, an empty bg is used, 
		ctl:ShowImage("")
		Map3DSystem.UI.Desktop.SetBackgroundImage();
		Map3DSystem.App.Login.ParaworldStartPage.LastBGInfo = {Text=L"无背景"};
		res = true;
	else
		-- some official scenes are no longer supported in the new version, so replace them with user version
		local backward_compatible = {
			["worlds/login_world"] = DefaultBGScenes[1].FilePath,
		}
		if( backward_compatible[bgInfo.FilePath] ) then
			bgInfo.FilePath = backward_compatible[bgInfo.FilePath];
		end
		local _,_, ext = string.find(bgInfo.FilePath, "%.(%w%w%w)$");
		if(ext == nil or ext == "zip") then
			NPL.load("(gl)script/kids/3DMapSystemUI/loadworld.lua");
			local result = Map3DSystem.UI.LoadWorld.LoadWorldImmediate(bgInfo.FilePath, true);
			if(result == true) then
				Map3DSystem.UI.Desktop.SetBackgroundImage("");	
				res = true;
				Map3DSystem.User.SetRole("dummy")
				NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/AppDesktop.lua");
				Map3DSystem.UI.AppDesktop.ChangeMode("dummy")
			elseif(type(result) == "string") then
				_guihelper.MessageBox(result);
			end
			--local worldpath = bgInfo.FilePath;
			--if(ext == "zip") then
				--ParaAsset.OpenArchive(worldpath, true);
				--ParaIO.SetDiskFilePriority(-1);
				--
				--local search_result = ParaIO.SearchFiles("","*.", worldpath, 0, 10, 0);
				--local nCount = search_result:GetNumOfResult();
				--if(nCount>0) then
					---- just use the first directory in the world zip file as the world name.
					--local WorldName = search_result:GetItem(0);
					--WorldName = string.gsub(WorldName, "[/\\]$", "");
					--worldpath = string.gsub(worldpath, "([^/\\]+)%.zip$", WorldName); -- get rid of the zip file extension for display 
				--else
					---- make it the directory path
					--worldpath = string.gsub(worldpath, "(.*)%.zip$", "%1"); -- get rid of the zip file extension for display
				--end
			--else
				--ParaIO.SetDiskFilePriority(0);	
			--end
			--
			---- get world files
			--local WorldName = ParaIO.GetFileName(worldpath);
			--local sAttributeFile = worldpath.."/"..WorldName..".attribute.db";
			--local sNPCFile = worldpath.."/"..WorldName..".NPC.db";
			--local sOnLoadScript = worldpath.."/script/"..WorldName.."_0_0.onload.lua";
			---------------------------
			---- a simple 3d scene using mini scene graph
			---------------------------
			--local scene = ParaScene.GetMiniSceneGraph("miniGameScene");
			--------------------------------------
			---- init render target
			--------------------------------------
			---- set size
			--scene:SetRenderTargetSize(1024, 512);
			---- reset scene, in case this is called multiple times
			--scene:Reset();
			---- enable camera and create render target
			--scene:EnableCamera(true);
			---- render it each frame automatically. 
			--scene:EnableActiveRendering(true);
			--
			--local att = scene:GetAttributeObject();
			--att:SetField("BackgroundColor", {1, 1, 1});  -- blue background
			--att:SetField("ShowSky", false);
			--att:SetField("EnableFog", false)
			----att:SetField("EnableFog", true);
			----att:SetField("FogColor", {1, 1, 1}); -- red fog
			----att:SetField("FogStart", 5);
			----att:SetField("FogEnd", 25);
			----att:SetField("FogDensity", 1);
			--att:SetField("EnableLight", false)
			--att:SetField("EnableSunLight", false)
			--scene:SetTimeOfDaySTD(0.3);
			---- set the mini map scene to semitransparent background color
			--scene:SetBackGroundColor("255 255 255 0");
			--------------------------------------
			---- init camera
			--------------------------------------
			--scene:CameraSetLookAtPos(0,1.5,0);
			--scene:CameraSetEyePosByAngle(0, 0.1, 5);
			--------------------------------------
			---- init scene content
			--------------------------------------
			--NPL.load("(gl)script/ide/MinisceneManager.lua");
			---- load attribute and main scene
			--local worldinfo = CommonCtrl.MinisceneManager.GetWorldAttribute(sAttributeFile);
			---- load mesh: use player location as origin
			--CommonCtrl.MinisceneManager.LoadFromOnLoadScript(scene, sOnLoadScript, worldinfo.PlayerX,worldinfo.PlayerY, worldinfo.PlayerZ)
			---- load NPC: use player location as origin
			--CommonCtrl.MinisceneManager.LoadFromOnNPCdb(scene, sNPCFile, worldinfo.PlayerX,worldinfo.PlayerY, worldinfo.PlayerZ);
		--
			--ctl:ShowMiniscene("miniGameScene");
			--res = true;
		else
			ext = string.lower(ext);
			if(ext == "jpg" or ext == "png" or ext == "dds" or ext == "bmp" or ext == "wmv" or ext == "avi" or ext == "swf") then
				ctl:ShowImage(bgInfo.FilePath)
				Map3DSystem.UI.Desktop.SetBackgroundImage();
				res = true;
			end
		end
	end
	if(res) then
		-- save last result to config file 
		Map3DSystem.App.Login.app:WriteConfig("InitScene", Map3DSystem.App.Login.ParaworldStartPage.LastBGInfo)
		
		if(bgInfo and bgInfo.FilePath and bgInfo.FilePath~="") then
			-- save to recently opened scenes
			local scenes = Map3DSystem.App.Login.app:ReadConfig("RecentlyOpenedScenes", {})
			local bNeedSave;
			-- sort by order
			local index, value, found
			for index, value in ipairs(scenes) do
				if(value.FilePath == bgInfo.FilePath) then
					if(index>1) then
						commonlib.moveArrayItem(scenes, index, 1)
						bNeedSave = true;
					end	
					found = true;
					break;
				end
			end
			if(not found) then
				commonlib.insertArrayItem(scenes, 1, bgInfo)
				bNeedSave = true;
			end
			if(bNeedSave) then
				Map3DSystem.App.Login.app:WriteConfig("RecentlyOpenedScenes", scenes)
				Map3DSystem.App.Login.app:SaveConfig();
			end	
		end	
	end	
	return res;
end

-- bring up a context menu for selecting which bg to display. 
function Map3DSystem.App.Login.ParaworldStartPage.ShowBGSelectionMenu()
	NPL.load("(gl)script/ide/ContextMenu.lua");
	local ctl = CommonCtrl.GetControl("Login.FrontPagePopMenu");
	if(ctl==nil)then
		ctl = CommonCtrl.ContextMenu:new{
			name = "Login.FrontPagePopMenu",
			width = 150,
			height = 160,
			--container_bg = "Texture/3DMapSystem/ContextMenu/BG.png:12 32 12 7",
			--container_bg = "Texture/3DMapSystem/ContextMenu/BG2.png:8 8 8 8",
		};
		local node = ctl.RootNode;
		local parentnode = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "group", Name = "mygroup", Type = "Group", NodeHeight = 0});
		local subNode;
		-- open setting page
		parentnode:AddChild(CommonCtrl.TreeNode:new{Text = L"背景设置...", Icon = "Texture/3DMapSystem/common/monitor.png", Type = "Menuitem", Name = "Settings", onclick = function ()
			local ctl = CommonCtrl.GetControl(Map3DSystem.App.Login.browsername);
			if(ctl)then
				ctl:Goto("script/kids/3DMapSystemApp/Login/setting.html", nil);
			end	
		end});
		-- no bg
		parentnode:AddChild(CommonCtrl.TreeNode:new{Text = L"无背景", Icon = "Texture/3DMapSystem/common/delete.png", Type = "Menuitem",Name = "empty", onclick = function ()
			Map3DSystem.App.Login.ParaworldStartPage.OnClickSwitchBG(nil);
		end});
		parentnode:AddChild(CommonCtrl.TreeNode:new{Text = L"从3D世界或文件...", Icon = "Texture/3DMapSystem/common/ViewFiles.png", Type = "Menuitem",Name = "fromFile", onclick = Map3DSystem.App.Login.ParaworldStartPage.OnClickBGFromFile});
		-- for system defined bg
		node = parentnode:AddChild(CommonCtrl.TreeNode:new{Text = L"系统主题背景", Icon = "Texture/3DMapSystem/common/house.png", Type = "Menuitem",Name = "System"});
			local i, value;
			for index, value in ipairs(DefaultBGScenes) do 
				node:AddChild(CommonCtrl.TreeNode:new({type = "sys", Text = value.Text or commonlib.Encoding.DefaultToUtf8(value.FilePath), Name = "sys", Type = "Menuitem", fileIndex = index, onclick = Map3DSystem.App.Login.ParaworldStartPage.OnClickSwitchBG}));
			end
		-- for user defined bg
		node = parentnode:AddChild(CommonCtrl.TreeNode:new{Text = L"我最近使用过的", Type = "Menuitem", Name = "MyBGs"});
			local scenes = Map3DSystem.App.Login.app:ReadConfig("RecentlyOpenedScenes", {})
			local index, value
			for index, value in ipairs(scenes) do
				node:AddChild(CommonCtrl.TreeNode:new({type = "user",Name = "Recent",Type = "Menuitem", Text = commonlib.Encoding.DefaultToUtf8(value.Text), bgInfo = value, onclick = Map3DSystem.App.Login.ParaworldStartPage.OnClickSwitchBG}))
			end
	end
	local _this=ParaUI.GetUIObject("Login.ParaworldStartPage_cont");
	if(_this:IsValid()) then
		_this = _this:GetChild("btnChangeBg");
		if(_this:IsValid()) then
			local x,y,width,height = _this:GetAbsPosition();
			ctl:Show(x, y+height);
		end
	else
		return;	
	end	
end

-- destory the control
function Map3DSystem.App.Login.ParaworldStartPage.OnDestory()
	ParaUI.Destroy("Login.ParaworldStartPage_cont");
end

----------------------------------
-- MCML page event handlers
----------------------------------

-- User filled out the registration form and submitted 
-- @param values: username, password, password_confirm, birth_day, birth_month, birth_year, email, gender
function Map3DSystem.App.Login.ParaworldStartPage.OnMCML_UserRegister(btnName, values, bindingContext)
	if(btnName == "register") then
		local errormsg = "";
		-- validate name
		if(string.len(values.username)<3) then
			errormsg = errormsg..L"名字太短了\n"
		end
		-- validate password
		if(string.len(values.password)<6) then
			errormsg = errormsg..L"密码太短了\n"
		elseif(values.password~=values.password_confirm) then
			errormsg = errormsg..L"确认密码与密码不一致\n"
		end
		-- validate email
		values.email = string.gsub(values.email, "^%s*(.-)%s*$", "%1")
		if(not string.find(values.email, "^%s*[%w%._%-]+@[%w%.%-]+%.[%a]+%s*$")) then
			errormsg = errormsg..L"Email地址格式不正确\n"
		end
		values.birth_day = tonumber(values.birth_day);
		values.birth_month = tonumber(values.birth_month);
		values.birth_year = tonumber(values.birth_year);
		if(not values.birth_day or not values.birth_month or not values.birth_year) then
			errormsg = errormsg..L"请选择出生日期\n"
		end
		if(errormsg~="") then
			paraworld.ShowMessage(errormsg)
		else
			local msg = {
				-- is this app key needed?
				appkey = "fae5feb1-9d4f-4a78-843a-1710992d4e00",
				username = values.username,
				password = values.password,
				email = values.email,
				gender = values.gender,
				birth_day = values.birth_day,
				birth_month = values.birth_month,
				birth_year = values.birth_year,
				passquestion = L"您是何时出生的?",
				passanswer = string.format("%s.%s.%s", values.birth_year, values.birth_month, values.birth_day)
			};
			paraworld.ShowMessage(L"正在连接注册服务器, 请等待")
			paraworld.users.Registration(msg, "login", function(msg)
				if(paraworld.check_result(msg, true)) then
					paraworld.ShowMessage(L"恭喜！注册成功！\n 请您查收Email激活您的登录帐号.");
					-- start login procedure
					--NPL.load("(gl)script/kids/3DMapSystemApp/Login/LoginProcedure.lua");
					--Map3DSystem.App.Login.Proc_Authentication(values);
				end	
			end);
		end
	end
end

-- user clicks to register a new account.
function Map3DSystem.App.Login.OnClickNewAccount()
	Map3DSystem.UI.Desktop.GotoDesktopPage(Map3DSystem.App.Login.RegPageUrl, System.localserver.CachePolicy:new("access plus 1 day"))
end

-- go to a given page
-- @param url: url of the page
-- @param cachePolicy: nil or a cache policy. if nil, it defaults to 1 day.
function Map3DSystem.App.Login.GotoPage(url, cachePolicy)
	local ctl = CommonCtrl.GetControl(Map3DSystem.App.Login.browsername);
	if(ctl)then
		ctl:Goto(url, cachePolicy or System.localserver.CachePolicy:new("access plus 1 day"));
	end
end

function Map3DSystem.App.Login.ParaworldStartPage.MSGProc(window, msg)
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		window:ShowWindowFrame(false);
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end