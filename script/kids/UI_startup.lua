--[[
Title: The Kids Movie UI
Author(s): LiXizhi(code&logic)
Date: 2006/1/26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/UI_startup.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/object_editor.lua");

-- Revised by WangTian 2007-8-30
--NPL.load("(gl)script/kids/3DMapSystem_Data.lua");
--NPL.load("(gl)script/kids/3DMapSystemUI/EscPopup.lua");

local L = CommonCtrl.Locale("KidsUI");

-- KidsUI: Kids UI library 
if(not KidsUI) then KidsUI={}; end
KidsUI.StartupImage = L"StartupImage";--"Texture/kidui/startup_seq/static_startup.jpg";
KidsUI.StartupVideo = L"StartupVideo";--"video/KidsMovieStart_V1.wmv";
-- if KidsUI.StartupTexSeq.file is nil, the video will be used.
KidsUI.StartupTexSeq = {file=L"StartupTexSeq", asset = nil,};
KidsUI.CommunitySite = L("community.aspx");

-- tutorials in this worlds
KidsUI.TutorialLevels = {
	[1] = {name = L("tutorial1","name"), path = L("tutorial1","path"), tooltip = L("tutorial1","tooltip")},
	[2] = {name = L("tutorial2","name"), path = L("tutorial2","path"), tooltip = L("tutorial2","tooltip")},
	[3] = {name = L("tutorial3","name"), path = L("tutorial3","path"), tooltip = L("tutorial3","tooltip")},
};
KidsUI.LeftStartupBoxPages = {"KidsUI_Intro", "KidsUI_About", "KidsUI_Tutorials", "KidsUI_Tips"};

-- make the background of the control to be the start up image, video or animated sequence.
--@param _this: a container UI object
--@param bForceImage: if true, it will force use image,instead of video. 
function KidsUI.UseStartupBackground(_this,bForceImage)
	if(bForceImage==true or (not ReleaseBuild) or ParaEngine.IsDebugging() == true) then
		_this.background=KidsUI.StartupImage;
	else
		if(KidsUI.StartupTexSeq.file~=nil) then
			if(not KidsUI.StartupTexSeq.asset) then
				KidsUI.StartupTexSeq.asset = ParaAsset.LoadTexture("startup_seq", KidsUI.StartupTexSeq.file, 2);
				KidsUI.StartupTexSeq.asset:SetTextureFPS(15);
			end	
			_this.background=KidsUI.StartupTexSeq.file;
		elseif(ParaIO.DoesFileExist(KidsUI.StartupVideo)==true)	then
			_this.background="Texture/whitedot.png;0 0 0 0";
			-- AVI or WMV player
			local ctl=ParaUI.CreateUIObject("video","init_media_player", "_fi",0,0,0,0);
			ctl:LoadFile(KidsUI.StartupVideo);
			ctl:PlayVideo();
			_this:AddChild(ctl);
		else	
			_this.background=KidsUI.StartupImage;
		end	
	end	
end


-- show a list of tutorial levels that are in this version.
-- @param parentName: if nil, "left_display_cont" is used. 
function KidsUI.ShowTutorialWindow(parentName)
	local _this, _parent, tmp;
	
	KidsUI.LastLeftContainerShowIndex = 3;
	_guihelper.SwitchVizGroupByIndex(KidsUI.LeftStartupBoxPages, 3);
	if(ParaUI.GetUIObject("KidsUI_Tutorials"):IsValid()) then 		
		return; 	
	end
	
	if(not parentName) then
		parentName = "left_display_cont";
	end
	tmp = ParaUI.GetUIObject(parentName);
	if(tmp:IsValid()==false) then return end
	
	_this=ParaUI.CreateUIObject("container","KidsUI_Tutorials", "_lt",60,60,240,300);
	_this.background="Texture/whitedot.png;0 0 0 0";
	_this.scrollable = true;
	tmp:AddChild(_this);
	_parent = _this;
	
	local left, top, width, height = 5,7,174, 42;
	_this=ParaUI.CreateUIObject("button","s", "_lt",left, top, width, height);
	_this.background=L"Texture/kidui/main/tczpx.png";
	_guihelper.SetUIColor(_this, "255 255 255");
	_this.tooltip = L"UserWorkShow_Tooltips";
	_parent:AddChild(_this);
	top = top+height;
	
	left = left+10;
	_this = ParaUI.CreateUIObject("button", "btn1", "_lt", left, top, 80, 30);
	_this.onclick = ";KidsUI.OnNetworkPick();";
	_this.text = L"Random pick"
	_this.tooltip = L"Randomly download a user submitted 3D world";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button", "btn1", "_lt", left+90, top, 80, 30);
	_this.onclick = string.format([[;ParaGlobal.ShellExecute("open", "iexplore.exe", "%s", nil, 1);]], KidsUI.CommunitySite);
	_this.text = L"Participate";
	_this.tooltip = L"Click me! More surprises waiting for you!";
	_parent:AddChild(_this);
	
	
	left, top, width, height = 5,100,174, 42;
	_this=ParaUI.CreateUIObject("button","s", "_lt",left, top, width, height);
	_this.background=L"Texture/kidui/main/tutorials.png";
	_guihelper.SetUIColor(_this, "255 255 255");
	_parent:AddChild(_this);
	
	top = top+height;
	left = left+10;
	
	local frontpageBooks = L:GetTable("FrontPage Books");
	if(frontpageBooks~=nil) then
		local bookcount = table.getn(frontpageBooks);
		
		width, height = 24,48;
		local i;
		for i=1,bookcount do
			local bookinfo = frontpageBooks[i];
			if(bookinfo~=nil) then
				_this = ParaUI.CreateUIObject("button", "b"..i, "_lt", left, top, width, height);
				_this.background = "Texture/EBook/book_zipped.png";
				_this.onclick = string.format(";KidsUI.OnLoadFrontPageBook(%d);", i);
				_this.tooltip = bookinfo.tooltip;
				_parent:AddChild(_this);
				
				top = top + height;
				_this = ParaUI.CreateUIObject("button", "t", "_lt", left+width+10, top-37, 150, 30);
				_guihelper.SetVistaStyleButton(_this, "Texture/whitedot.png;0 0 0 0", "Texture/EBook/button_bg_layer.png");
				_guihelper.SetUIFontFormat(_this, 4);-- make text align to left, and vertical centered
				_this.text= bookinfo.name;
				_this:GetFont("text").color = "0 0 139";
				_this.onclick = string.format(";KidsUI.OnLoadFrontPageBook(%d);", i);
				_parent:AddChild(_this);
			end	
		end
	end	
	
	--_parent:InvalidateRect();
end

-- random pick a network work to download
function KidsUI.OnNetworkPick()
	NPL.load("(gl)script/network/KM_WorldDownloader.lua");
	KM_WorldDownloader.ShowUIForTask(KM_WorldDownloader.NewTask({source=L"User work show: random pick", type = KM_WorldDownloader.TaskType.AdsWorld}));
end

-- load a front page book at the given index, such as 1-3
function KidsUI.OnLoadFrontPageBook(nIndex)
	local frontpageBooks = L:GetTable("FrontPage Books");
	if(frontpageBooks~=nil) then
		local bookcount = table.getn(frontpageBooks);
		if(nIndex>=0 and nIndex<=bookcount) then
			local bookinfo = frontpageBooks[nIndex];
			if(bookinfo~=nil) then
				NPL.load("(gl)script/EBook/EBook.lua");
				
				EBook.Show(true);
				local res = EBook.OpenBook(bookinfo.path);
				if(res==true) then
					-- 
				elseif(type(res) == "string") then
					-- display the error message if any.
					_guihelper.MessageBox(res);
				end
			end	
		end
	end	
end

-- load tutorial world at the given index
function KidsUI.OnLoadTutorial(nIndex)
	local tutoWorld = KidsUI.TutorialLevels[nIndex];
	if(tutoWorld~=nil) then
		KidsUI.bShowTipsIcon = true;
		if(KidsUI.LoadWorldImmediate(tutoWorld.path))then
			kids_db.User.SetRole("friend");
		end
	else
		log("tutorial world at following index does not exist "..nIndex)	
	end
end

-- display a text in the left container of the startup window
-- @param text: nil or some text or number. if it is nil, the tutorial window is displayed. If it is number, it is treated as a string index
function KidsUI.ShowTips(text)
	local _this, _parent, tmp;
	if(not text) then
		 _guihelper.SwitchVizGroupByIndex(KidsUI.LeftStartupBoxPages, KidsUI.LastLeftContainerShowIndex);
		return;
	end
	if(type(text)=="number") then
		text = L("KidsUI_StartScreen_button_tips_"..text);
	end
	
	_guihelper.SwitchVizGroupByIndex(KidsUI.LeftStartupBoxPages, 4);
	
	tmp = ParaUI.GetUIObject("left_display_cont");
	if(tmp:IsValid()==false) then return end
	
	-- recreate new tips.
	
	_parent = ParaUI.GetUIObject("KidsUI_Tips");
	if(_parent:IsValid()==false) then 
		_this=ParaUI.CreateUIObject("container","KidsUI_Tips", "_lt",60,60,240,300);
		_this.background="Texture/whitedot.png;0 0 0 0";
		tmp:AddChild(_this);
		_parent = _this;
		
		_this=ParaUI.CreateUIObject("text","s", "_lt",0,0,_parent.width-20, 50);
		_this:GetFont("text").color = "0 0 139";
		_parent:AddChild(_this);
		_this.text = text;
	else
		_this = _parent:GetChild("s");
		if(_this:IsValid()) then
			_this.text = text;
		end
	end
end

-- show introduction. it can be a movie or some text
function KidsUI.ShowIntroWindow()
	local _this, _parent, tmp;
	
	KidsUI.LastLeftContainerShowIndex = 1;
	_guihelper.SwitchVizGroupByIndex(KidsUI.LeftStartupBoxPages, 1);
	
	if(ParaUI.GetUIObject("KidsUI_Intro"):IsValid()) then 		
		return; 	
	end
	
	tmp = ParaUI.GetUIObject("left_display_cont");
	if(tmp:IsValid()==false) then return end
	
	_this=ParaUI.CreateUIObject("container","KidsUI_Intro", "_lt",60,60,240,300);
	_this.background="Texture/whitedot.png;0 0 0 0";
	tmp:AddChild(_this);
	_parent = _this;
	
	local left, top, width, height = 10,10,174, 42;
	_this=ParaUI.CreateUIObject("container","instructions", "_lt",left, top, width, height);
	_this.background=L"Texture/kidui/main/instructions.png";
	_parent:AddChild(_this);
	
	top = top + height+3;
	_this=ParaUI.CreateUIObject("container","c", "_lt",0,top,_parent.width,_parent.height-top);
	_this.background="Texture/whitedot.png;0 0 0 0";
	_this.scrollable = true;
	_parent:AddChild(_this);
	_parent = _this;
		
	_this=ParaUI.CreateUIObject("text","s", "_lt",0,0,_parent.width-20, 50);
	_parent:AddChild(_this);
	_this.text = L"IntroText";
	_this.autosize=true;
	_this:DoAutoSize();
	_parent:InvalidateRect();
end

function KidsUI.ShowAboutWindow()
	local _this, _parent, tmp;
	
	KidsUI.LastLeftContainerShowIndex = 2;
	_guihelper.SwitchVizGroupByIndex(KidsUI.LeftStartupBoxPages, 2);
	if(ParaUI.GetUIObject("KidsUI_About"):IsValid()) then 		
		return; 	
	end
	
	tmp = ParaUI.GetUIObject("left_display_cont");
	if(tmp:IsValid()==false) then return end
	
	_this=ParaUI.CreateUIObject("container","KidsUI_About", "_lt",60,60,240,300);
	_this.background="Texture/whitedot.png;0 0 0 0";
	_this.scrollable = true;
	tmp:AddChild(_this);
	_parent = _this;
	
	local left, top, width, height = 0,0,220, 50;
	
	_this=ParaUI.CreateUIObject("text","s", "_lt",left, top,width, height);
	_parent:AddChild(_this);
	_this.text = L"Kids Movie Platform\n- 2007 New Year Edition";
	top = top + height;	
	
	_this=ParaUI.CreateUIObject("button","s", "_lt",left, top,200, 30);
	_parent:AddChild(_this);
	_this.text = L"Go to official website";
	_this.tooltip = KidsUI.CommunitySite;
	_this.onclick = string.format([[;ParaGlobal.ShellExecute("open", "iexplore.exe", "%s", nil, 1);]], KidsUI.CommunitySite);
	top = top + height+5;
		
	if(ParaEngine.IsProductActivated() == true)  then
		_this=ParaUI.CreateUIObject("text","s", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text = L"Product is registered.";
		_this:GetFont("text").color = "255 0 0";
		
		_this=ParaUI.CreateUIObject("button","s", "_lt",left, top+20,80, 30);
		_parent:AddChild(_this);
		_this.text = L"register"
		_this.onclick = ";KidsUI.OnBtnRegisterProduct();";
		
		top = top + height;
	--elseif(DemoBuild) then
		--_this=ParaUI.CreateUIObject("text","s", "_lt",left, top,width, height);
		--_parent:AddChild(_this);
		--_this.text = L"You are running demo version.";
		--_this:GetFont("text").color = "255 0 0";
		--top = top + 70;
		
	else	
		_this=ParaUI.CreateUIObject("text","s", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		_this.text = L"Product is unregistered.\r\nEnter license code below";
		_this:GetFont("text").color = "255 0 0";
		top = top + height;
		
		height =25
		_this=ParaUI.CreateUIObject("editbox","editbox_license_code", "_lt",left, top,width, height);
		_parent:AddChild(_this);
		top = top + height+5;
		
		_this=ParaUI.CreateUIObject("button","s", "_lt",left, top,80, height);
		_parent:AddChild(_this);
		_this.text = L"register"
		_this.onclick = ";KidsUI.OnBtnRegisterProduct();";
		top = top + height+5;
	end
	
	_this=ParaUI.CreateUIObject("text","s", "_lt",left, top,width, height);
	_parent:AddChild(_this);
	_this.text = L"Team";
	_this.autosize=true;
	_this:DoAutoSize();
	_parent:InvalidateRect();
end

function KidsUI.OnBtnRegisterProduct()
	local tmp = ParaUI.GetUIObject("editbox_license_code")
	if(tmp:IsValid() == true) then 
		local productkey = tostring(tmp.text);
		if(ParaEngine.ActivateProduct(productkey) == true) then
			-- horay. Thank you for purchasing!
			ParaUI.Destroy("KidsUI_About");
			KidsUI.ShowAboutWindow();
			_guihelper.MessageBox(L"Thank you very much for purchasing our product!",
				string.format([[NPL.load("(gl)script/kids/Ui/RegisterProduct.lua");RegisterProduct.Show("%s");]], productkey))
		else
			_guihelper.MessageBox(L"Your license code is incorrect. Please enter code like below \n1234-1234-1234-1234");
		end
	else
		-- let the user enter license code again
		if(kids_db.User.userinfo.IsProductRegistered) then
			_guihelper.MessageBox(L"Your product is already register. You can submit or update your registration info with us. Do you want to do it now?", function()
				NPL.load("(gl)script/kids/Ui/RegisterProduct.lua");
				RegisterProduct.Show(ParaEngine.GetProductKey(""));
			end);
		else
			NPL.load("(gl)script/kids/Ui/RegisterProduct.lua");
			RegisterProduct.Show(ParaEngine.GetProductKey(""));
		end	
	end
end

-- set window text
function KidsUI.SetStartUpText(item)
	local tmp = ParaUI.GetUIObject("demo_startup_text")
	if(tmp:IsValid() == true) then 
		if(item == "copyright") then
			tmp.text = L"IntroText";
		elseif (item=="team") then
			tmp.text = L"Team";
		elseif (item=="scene2") then
		tmp.text = [[
此场景２不存在
测试用户可编辑
"script/usertest.lua"
测试ＮＰＬ脚本相关的功能]];
		end
	end
end

--[[create new world]]
function KidsUI.Startup_OnNewWorld()
	--ParaUI.Destroy("KidsUI_Startup_cont");
	--NPL.activate("(gl)script/kids/newworld.lua", "");
	NPL.load("(gl)script/EBook/EBook.lua");
	EBook.Show(true);
end
--[[Load a world]]
function KidsUI.Startup_LoadWorld()
	NPL.load("(gl)script/kids/WorldManager.lua");
	WorldManager.Show(true);
end

--[[Load Demo Scene 2]]
function KidsUI.TaskWorld()
	NPL.load("script/usertest.lua", true);
	KidsUI.SetStartUpText("scene2");
end

--[[Load GUI demo]]
function KidsUI.DemoGUI()
	NPL.activate("(gl)script/ide/gui_ide.lua", "");
	ParaUI.Destroy("KidsUI_Startup_cont");
end

--[[show networking pannel]]
function KidsUI.ShowNetworking()
	NPL.load("(gl)script/network/LoginBox.lua");
	if(not kids_db.User.IsAuthenticated) then
		LoginBox.Show(true, KidsUI.ShowNetworking_imp);
	else
		KidsUI.ShowNetworking_imp();
	end	
end

function KidsUI.ShowNetworking_imp()
	if(KidsMovie_FunctionSet_Networking) then
		-- this is the old panel, which is no longer used. 
		--NPL.load("(gl)script/network/NetworkPannel.lua");
		--network.Show(true);
		
		-- new style Kids 3D world explorer window. 
		local ExpCtl = CommonCtrl.GetControl("KidsExplorer");
		if(ExpCtl==nil)then
			NPL.load("(gl)script/network/explorer.lua");
			ExpCtl = CommonCtrl.explorer:new{
				name = "KidsExplorer",
				parent = nil,
			};	
		end
		ExpCtl:Show(true);
	else
		-- network function is disabled for this release
		
		-- right click the OK button to run the secret network version anyway
		if(mouse_button=="right") then
			-- new style Kids 3D world explorer window. 
			local ExpCtl = CommonCtrl.GetControl("KidsExplorer");
			if(ExpCtl==nil)then
				NPL.load("(gl)script/network/explorer.lua");
				ExpCtl = CommonCtrl.explorer:new{
					name = "KidsExplorer",
					parent = nil,
				};	
			end
			ExpCtl:Show(true);
		else
			-- open the windows explorer
			_guihelper.MessageBox(L"Function is only available to community edition users.", function ()
				ParaGlobal.ShellExecute("open", "iexplore.exe", L"community.aspx", nil, 1); 
			end);
		end	
	end
end

--[[when the user exits]]
function KidsUI.OnExit(bForceNormal)
	if(ParaEngine.IsDebugging() and not bForceNormal)then
		_guihelper.MessageBox([[Do you want to update install files at ./_InstallFiles according to InstallFiles.txt and temp/filelog.txt ?]], 
			[[ParaIO.UpdateMirrorFiles("_InstallFiles/", true);KidsUI.OnExit(true);]])
	else
		if(ParaEngine.IsProductActivated()) then
			-- exit directly, if the product is registered
			ParaGlobal.ExitApp();
		else
			-- display a logo page 101 before exiting for demo version users.
			KidsUI.Exiting = true;
			KidsUI.reset();
			KidsUI.ReBindEventHandlers();
			KidsUI.ShowLogoPage(101, 2000);
		end	
	end
end

-- create the main window
function KidsUI.CreateStartupWnd()
	KidsUI.PushState("UI_startup");
	local _this,_parent,__font,__texture;
	
	if(ParaUI.GetUIObject("KidsUI_Startup_cont"):IsValid() == true) then 
		log("warning: startup recreated\n");
		return
	end
	
	_this=ParaUI.CreateUIObject("container","KidsUI_Startup_cont", "_fi",0,0,0,0);
	_this:AttachToRoot();
	_parent = _this;
		
	KidsUI.UseStartupBackground(_this, true);

	_this=ParaUI.CreateUIObject("container","title", "_lt",10,10,256,32);
	_this.background=L"Texture/kidui/main/title.png";
	_parent:AddChild(_this);

	_this=ParaUI.CreateUIObject("container","c1", "_ct",-150,-230,300,512);
	_this.background="Texture/kidui/main/001_bg.png";
	_parent:AddChild(_this);
	
	_parent = _this;
	
	local left, top = 54, 25;
	local width, height = 192, 80;
	local animStyle = 21;

	_this=ParaUI.CreateUIObject("container","line", "_ct",-128,-710,256,512);
	_this.background="Texture/kidui/main/001_bg_line.png";
	_parent:AddChild(_this);

	--开创世界
	_this=ParaUI.CreateUIObject("button","create", "_lt",left, top,width, height);
	_parent:AddChild(_this);
	_this.background=L"Texture/kidui/main/create.png";
	_this.onclick=";KidsUI.Startup_OnNewWorld();";
	_this.onmouseenter=";KidsUI.ShowTips(1);"
	_this.onmouseleave=";KidsUI.ShowTips(nil);"
	_this.animstyle = animStyle;
	top = top+height;
	
	--读取世界
	_this=ParaUI.CreateUIObject("button","demo1", "_lt",left, top,width, height);
	_parent:AddChild(_this);
	_this.background=L"Texture/kidui/main/load.png";
	_this.onclick=";KidsUI.Startup_LoadWorld();";
	_this.onmouseenter=";KidsUI.ShowTips(2);"
	_this.onmouseleave=";KidsUI.ShowTips(nil);"
	_this.animstyle = animStyle;
	top = top+height;

	--网络世界
	_this=ParaUI.CreateUIObject("button","demo2", "_lt",left, top,width, height);
	_parent:AddChild(_this);
	_this.background=L"Texture/kidui/main/network.png";
	_this.onclick=";KidsUI.ShowNetworking();";
	_this.onmouseenter=";KidsUI.ShowTips(3);"
	_this.onmouseleave=";KidsUI.ShowTips(nil);"
	_this.animstyle = animStyle;
	top = top+height;
	
	--系统设置
	_this=ParaUI.CreateUIObject("button","gui", "_lt",left, top,width, height);
	_parent:AddChild(_this);
	_this.background=L"Texture/kidui/main/setting.png";
	_this.onclick=";KidsUI.ShowSettings(true);";
	_this.onmouseenter=";KidsUI.ShowTips(4);"
	_this.onmouseleave=";KidsUI.ShowTips(nil);"
	_this.animstyle = animStyle;
	top = top+height;

	--退出
	_this=ParaUI.CreateUIObject("button","para", "_lt",left, top,width, height);
	_parent:AddChild(_this);
	_this.background=L"Texture/kidui/main/exit.png";
	_this.onclick=";KidsUI.OnExit();";
	_this.animstyle = animStyle;
	top = top+height;
	
	-- 关于及注册
	left = left-28;
	height = 64;
    
	_this=ParaUI.CreateUIObject("button","About", "_lt",left, top,64,height );
	_parent:AddChild(_this);
	_this.background=L"Texture/kidui/main/about.png";
	_this.onclick=";KidsUI.ShowAboutWindow();";
	
	--教程
	_this=ParaUI.CreateUIObject("button","Tutorial", "_lt",left+64, top,128,height);
	_parent:AddChild(_this);
	_this.background=L"Texture/kidui/main/tutorial.png";
	_this.onclick=";KidsUI.ShowTutorialWindow();";
	
	--介绍
	_this=ParaUI.CreateUIObject("button","intro", "_lt",left+192, top,64,height );
	_parent:AddChild(_this);
	_this.background=L"Texture/kidui/main/intro.png";
	_this.onclick=";KidsUI.ShowIntroWindow();";
		
	-- copy right info at bottom	
	_parent = ParaUI.GetUIObject("KidsUI_Startup_cont");

	_this=ParaUI.CreateUIObject("text","s", "_lb",15,-67,500,20);
	_parent:AddChild(_this);
	_this:GetFont("text").color = "255 255 0";
	_this.text=L"Product Customer Service";

	_this=ParaUI.CreateUIObject("text","copyright", "_lb",15,-45,382,20);
	_parent:AddChild(_this);
	_this:GetFont("text").color = "255 255 0";
	_this.text=string.format("%s\r\n%s", L("Kids Movie Platform Version"), L("Copyright@2004-2007 ParaEngine Tech Studio"));

	-- left display region
	_this=ParaUI.CreateUIObject("container","left_display_cont", "_ct",-512,-206,310,400);
	_parent:AddChild(_this);
	_this.background="Texture/kidui/main/c_bg.png;0 0 380 422";
	_this.candrag=false;
	
	-- tutorial window is loaded by default if registered, or display the register about window. 
	
	KidsUI.ShowTutorialWindow();
	
	if(ParaEngine.IsProductActivated()) then
		if(not kids_db.User.userinfo.IsProductRegistered) then
			_guihelper.MessageBox(L"You have not activated your product on our community website. Do you want to activate now?", "KidsUI.OnBtnRegisterProduct()");
		end
	else
		_guihelper.MessageBox(L"Your product is not registered. If you have license code, please click OK button and then enter license code.", "KidsUI.ShowAboutWindow()");
	end	
	
	--[[
	_this=ParaUI.CreateUIObject("text","demo_startup_text", "_lt",10,10,220,20);
	_parent=ParaUI.GetUIObject("left_display_cont");_parent:AddChild(_this);
	_this:GetFont("text").color = "255 255 255";
	_this.text="";
	KidsUI.SetStartUpText("copyright");]]
end

-- reset the scene
function KidsUI.reset()
	ParaScene.Reset();
	ParaUI.ResetUI();
	ParaAsset.GarbageCollect();
	if(KidsUI.StartupTexSeq.asset~=nil)then
		KidsUI.StartupTexSeq.asset:UnloadAsset();
	end
	ParaGlobal.SetGameStatus("disable");
	if(_AI~=nil and _AI.temp_memory~=nil) then
		_AI.temp_memory = {}
	end
	KidsUI.ResetState();
	collectgarbage();
	log("scene has been reset\n");
end

-- restart to the startup window.
function KidsUI.restart()
	KidsUI.reset()
	main_state="startup";
end

--[[ action to perform when the esc key is pressed.
valid value is:
"popup": display a dialog to ask for user confirmation
"startup": quit to when the application start up.
"newworld": quite to newworld dialog 
]]

KidsUI.OnEscKey_action = "popup";

--[[invoked when the esc key is pressed.
perform action according to KidsUI.OnEscKey_action
when the function exits, the KidsUI.OnEscKey_action is set to "popup"
]]
function KidsUI.OnEscKey(bShow)
	local leftCont = CommonCtrl.GetControl("kidleftcontainer");
	if(leftCont~=nil and leftCont.state == "object")then
		ParaAudio.PlayUISound("Btn7");
		-- selected nothing
		ObjEditor.SetCurrentObj(nil);
		leftCont.SwitchUI("environment");
		
		local midCont = CommonCtrl.GetControl("kidmiddlecontainer");	
		if(midCont~=nil and midCont.state ~= "text")then
			midCont.SwitchUI("text");	
		end
		
		-- remove arrow from old
		if(KidsUI.LastSelectedCharacterName~=nil) then
			local lastplayer = ParaScene.GetCharacter(KidsUI.LastSelectedCharacterName);
			if(lastplayer:IsValid()==true)then
				lastplayer:ToCharacter():RemoveAttachment(11);
				KidsUI.LastSelectedCharacterName = nil;
			end
		end
		
	elseif(KidsUI.OnEscKey_action == "popup") then
	
		if(application_name == "kidsmovie") then
		
			local _this,_parent,__font,__texture;
			_this = ParaUI.GetUIObject("exit_main_cont")
			
			if(_this:IsValid() == false) then 
				if(bShow == false) then return	end
				bShow = true;
				_this=ParaUI.CreateUIObject("container","exit_main_cont", "_ct",-100,-175,210,360);
				_this:AttachToRoot();
				_this.scrollable=false;
				_this:SetTopLevel(true);
				_this.background="Texture/kidui/main/bg_348X424.png;0 0 348 424";

				_parent=_this;
				local left, top = 26,20;
				local width, height = 156,62;-- original size 196,78;
				local animStyle = 21;
				--restart
				_this=ParaUI.CreateUIObject("button","btn", "_lt",left, top,width, height);
				_parent:AddChild(_this);
				_this.text="";
				_this.background=L"Texture/demo/b_quit.png";
				_this.onclick=[[;KidsUI.OnEscKey(false);_guihelper.MessageBox("]]..L"Do you wish to restart the game?"..[[","KidsUI.restart();");]]
				_this.animstyle = animStyle;
				top = top+height+2;
				
				--载入场景
				_this=ParaUI.CreateUIObject("button","btn", "_lt",left, top,width, height);
				_parent:AddChild(_this);
				_this.text="";
				_this.background=L"Texture/demo/b_load.png";
				_this.onclick=";KidsUI.OnEscKey(false);KidsUI.Startup_LoadWorld();";
				_this.animstyle = animStyle;
				top = top+height+2;

				--保存场景
				_this=ParaUI.CreateUIObject("button","btn", "_lt",left, top,width, height);
				_parent:AddChild(_this);
				_this.text="";
				_this.background=L"Texture/demo/b_save.png";
				_this.onclick="(gl)script/kids/saveworld.lua;KidsUI.OnEscKey(false);";
				_this.animstyle = animStyle;
				top = top+height+2;

				--网络
				_this=ParaUI.CreateUIObject("button","btn", "_lt",left, top,width, height);
				_parent:AddChild(_this);
				_this.background=L"Texture/demo/b_net.png";
				_this.onclick=[[;KidsUI.OnEscKey();KidsUI.ShowNetworking();]];
				_this.animstyle = animStyle;
				top = top+height+2;

				--退出程序
				_this=ParaUI.CreateUIObject("button","btn", "_lt",left, top,width, height);
				_parent:AddChild(_this);
				_this.text="";
				_this.background=L"Texture/demo/b_altf4.png";
				_this.onclick=";KidsUI.OnEscKey(false);KidsUI.OnExit();";
				_this.animstyle = animStyle;
			else
				if(bShow == nil) then
					bShow = (_this.visible == false);
				end
				_this.visible = bShow;
				if(bShow) then
					_this:SetTopLevel(true);
				end
			end
			if(bShow) then
				KidsUI.PushState({name = "EscKeyPanel", OnEscKey = "KidsUI.OnEscKey(false);"});
			else
				KidsUI.PopState("EscKeyPanel");
			end	
		
		elseif(application_name == "3DMapSystem") then
			KidsUI.OnEscKey_action = "popup_3DMapSystem";
		end
		
	elseif(KidsUI.OnEscKey_action == "startup") then
		KidsUI.restart();
	elseif(KidsUI.OnEscKey_action == "newworld") then
		KidsUI.reset();
		KidsUI.Startup_OnNewWorld();
	end
	
	if(KidsUI.OnEscKey_action == "popup_3DMapSystem") then
		if(State_3DMapSystem == "Startup") then
			--Map3DSystem.UI.EscPopup.ToggleEscPopupUI();
		elseif(State_3DMapSystem == "MainMenu") then
			--Map3DSystem.UI.EscPopup.ToggleEscPopupUI();
			if(Map3DSystem.UI.MapExplorer.IsShowEscPopupUI == true) then
				Map3DSystem.UI.MapExplorer.ToggleMapExplorerUI();
			end
		elseif(State_3DMapSystem == "InGame") then
			--Map3DSystem.UI.EscPopup.ToggleEscPopupUI();
		end
	end
	
	if(application_name == "kidsmovie") then
	-- reset default action to popup
		KidsUI.OnEscKey_action = "popup";
	elseif(application_name == "3DMapSystem") then
		KidsUI.OnEscKey_action = "popup_3DMapSystem";
	end
	
end
On_EscKey = KidsUI.OnEscKey;