--[[
Title: The Kids Movie UI
Author(s): LiXizhi(code&logic)
Date: 2006/1/26
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/kids/loadworld.lua","");
NPL.load("(gl)script/kids/loadworld.lua");
------------------------------------------------------------
]]
-- requires:
NPL.load("(gl)script/kids/kids_init.lua");
NPL.load("(gl)script/kids/kids_db.lua");
NPL.load("(gl)script/kids/UI_startup.lua");
NPL.load("(gl)script/ide/gui_helper.lua");
NPL.load("(gl)script/ide/FileDialog.lua");
NPL.load("(gl)script/ide/ParaEngineSettings.lua");
			
local L = CommonCtrl.Locale("KidsUI");

KidsUI.DefaultLoadWorld = L("tutorial1","path");

--[[ load a world immediately without doing any error checking or report. This is usually called by ParaIDE from the Load world menu. 
@param worldpath: the directory containing the world config file, such as "sample","worlds/demo" 
or it can also be a [worldname].zip file that contains the world directory. 
]]
function KidsUI.LoadWorldImmediate(worldpath)
	if(string.find(worldpath, ".*%.zip$")~=nil) then
		-- open zip archive with relative path
		kids_db.world.worldzipfile = worldpath;
		
		ParaAsset.OpenArchive(worldpath, true);
		ParaIO.SetDiskFilePriority(-1);
		
		local search_result = ParaIO.SearchFiles("","*.", worldpath, 0, 10, 0);
		local nCount = search_result:GetNumOfResult();
		if(nCount>0) then
			-- just use the first directory in the world zip file as the world name.
			local WorldName = search_result:GetItem(0);
			WorldName = string.gsub(WorldName, "[/\\]$", "");
			worldpath = string.gsub(worldpath, "([^/\\]+)%.zip$", WorldName); -- get rid of the zip file extension for display 
		else
			-- make it the directory path
			worldpath = string.gsub(worldpath, "(.*)%.zip$", "%1"); -- get rid of the zip file extension for display 		
		end
		kids_db.world.readonly = true;
		
		-- create and apply a sandbox for read only world, such as those downloaded from the network. 
		NPL.load("(gl)script/ide/sandbox.lua");
		local sandbox = ParaSandBox:GetSandBox("script/kids/km_sandbox_file.lua");
		sandbox:Reset();
		ParaSandBox.ApplyToWorld(sandbox);
	else
		kids_db.world.worldzipfile = nil;
		kids_db.world.readonly = nil;	
		ParaIO.SetDiskFilePriority(0);
		
		-- do not use a sandbox for writable world.
		NPL.load("(gl)script/ide/sandbox.lua");
		ParaSandBox.ApplyToWorld(nil);
	end
	
	kids_db.world.name = worldpath;
	kids_db.UseDefaultFileMapping();
	if(ParaIO.DoesFileExist(kids_db.world.sConfigFile, true) == true) then
		if(KidsUI.LoadWorld() == true) then
			return true;
		else
			return worldpath..L" failed loading the world."
		end
	else
		return worldpath..L" world does not exist"
	end	
end

-- clear the scene and load the world using the settings in the kids_db, return false if failed.
function KidsUI.LoadWorld()
	-- clear the scene
	KidsUI.reset();
	
	if(kids_db.world.sConfigFile ~= "") then
		-- disable the game 
		ParaSettingsUI.StopCategories("3DSound", "Ambient", "Background", "Default", "Dialog", "Interactive", "Music", "UI");
		ParaScene.EnableScene(false);
		NPL.load("(gl)script/ide/LoaderUI.lua");
		CommonCtrl.LoaderUI.Logo_Texture = L"LoaderImage";
		CommonCtrl.LoaderUI.Start(100);
		CommonCtrl.LoaderUI.SetProgress(10);
		
		-- open archives
		ParaAsset.OpenArchive ("xmodels/ParaWorldDemo.zip"); 
		ParaAsset.OpenArchive ("xmodels/character.zip");
	
		ParaAudio.PlayBGMusic("Kids_BG");
		CommonCtrl.LoaderUI.SetProgress(20);
		
		-- create world
		ParaScene.CreateWorld("", 32000, kids_db.world.sConfigFile); 
		CommonCtrl.LoaderUI.SetProgress(30);
		
		-- load from database
		kids_db.LoadWorldFromDB();
		CommonCtrl.LoaderUI.SetProgress(30);
		
		
		-- load different UI for different applications
		if(application_name == "kidsmovie") then
			NPL.activate("(gl)script/kids/ui/LoadMainGameUI.lua");
		elseif(application_name == "3DMapSystem") then
		
			if(State_3DMapSystem == "Startup") then
				--NPL.activate("(gl)script/kids/ui/Load3DMapSystemUI.lua");
			elseif(State_3DMapSystem == "MainMenu") then
				--NPL.activate("(gl)script/kids/ui/LoadMainGameUI.lua");
				NPL.activate("(gl)script/kids/ui/Load3DMapSystemUI.lua", "TargetState = \"MainMenu\"");
			-- state MapExplorer is depracated
			elseif(State_3DMapSystem == "InGame") then
				NPL.activate("(gl)script/kids/ui/Load3DMapSystemUI.lua", "TargetState = \"InGame\"");
			
				--NPL.activate("(gl)script/kids/ui/LoadMainGameUI.lua");
				--
				--NPL.load("(gl)script/kids/3DMapSystem_Data.lua");
				--NPL.load("(gl)script/kids/ui/Load3DMapSystemUI.lua");
				
				--Map3DSystem.UI.SwitchToState("InGame");
				
				
				--State_3DMapSystem = "InGame";
				--NPL.activate("(gl)script/kids/ui/Load3DMapSystemUI.lua");
				--NPL.activate("(gl)script/kids/ui/Load3DMapAdditionalUI.lua");
			end
		end
		CommonCtrl.LoaderUI.SetProgress(100);
		-- we have built the scene, now we can enable the game
		ParaScene.EnableScene(true);
		CommonCtrl.LoaderUI.End();
		
		KidsUI.PushState("game");
		
		-- call the onload script for the given world
		local sOnLoadScript = ParaWorld.GetWorldDirectory().."onload.lua";
		if(ParaIO.DoesFileExist(sOnLoadScript)==true)then
			NPL.activate("(gl)"..sOnLoadScript);
		end

		if(not kids_db.User.userinfo.HideWelcomeWorldWindow)then
			NPL.load("(gl)script/kids/Ui/WelcomeScreen.lua");
			WelcomeScreen.Show("HideWelcomeWorldWindow", L"WelcomeWorldWindowMedia","lefttop_normal");
		end	
		
		return true;
	else
		return false;
	end
end

-- load the local world
function KidsUI.LoadWorld_OnOK()
	-- disable network, so that it is local.
	ParaNetwork.EnableNetwork(false, "","");
	
	local tmp = ParaUI.GetUIObject("LoadWorld_name_txt");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		if(sName == "") then
			_guihelper.MessageBox(L"world name can not be empty");
		else
			kids_db.world.name = sName;
			kids_db.UseDefaultFileMapping();
			if(ParaIO.DoesFileExist(kids_db.world.sConfigFile, true) == true) then
				if(KidsUI.LoadWorld() == true) then
						--NPL.activate("(gl)script/kids/RightClick/RCP.lua", "");
						--KidsUI.ShowModePannel();
				else
					_guihelper.MessageBox(kids_db.world.name..L"failed loading the world.");
					NPL.activate("(gl)script/kids/loadworld.lua","");
				end
			else
				_guihelper.MessageBox(kids_db.world.name..L" world does not exist");
			end
		end
	end
end

function KidsUI.LoadWorld_OnCancel()
	ParaUI.Destroy("loadworld_cont");
	KidsUI.PopState("loadworld");
	if(KidsUI.GetState() == "UI_startup") then
		-- during startup
		main_state="startup";
		--KidsUI.restart();
	else
		-- during game playing
		if(KidsUI.StartupTexSeq.asset~=nil)then
			KidsUI.StartupTexSeq.asset:UnloadAsset();
		end	
	end	
end

function KidsUI.LoadWorld_OnWorldListSelect()
	local tmp = ParaUI.GetUIObject("listbox_worldnames");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		tmp = ParaUI.GetUIObject("LoadWorld_name_txt");
		if(tmp:IsValid() == true) then 
			tmp.text = kids_db.worlddir..sName;
		end
	end
end

local function activate()
	local _this,_parent,__font,__texture;

	local bFromStartup = KidsUI.GetState()=="UI_startup";
	
	KidsUI.PushState({name = "loadworld", OnEscKey = KidsUI.LoadWorld_OnCancel});
	KidsUI.bShowTipsIcon = nil;
	
	_this=ParaUI.CreateUIObject("container","loadworld_cont", "_fi",0,0,0,0);
	_this:AttachToRoot();
	_parent=_this;
	
	if(bFromStartup==true) then
		KidsUI.UseStartupBackground(_this);
	else
		KidsUI.UseStartupBackground(_this, true); -- use image
	end	
	
    _this=ParaUI.CreateUIObject("container","title", "_ct",-380,-380,773,224);
	_this.background="Texture/kidui/main/title.png;0 0 773 224";
	_parent:AddChild(_this);
	
	_this=ParaUI.CreateUIObject("container","middlecont", "_ct",-195,-210,400,512);
	_this.background="Texture/kidui/main/001_bg.png;0 0 400 512";
	_parent:AddChild(_this);
	_this.candrag=false;
	_parent=_this;
	
	local left, top, width, height = 35, 80, 110, 25;
	--读取世界
	_this=ParaUI.CreateUIObject("text","s", "_lt",left, top, width, height);
	_parent:AddChild(_this);
	--_this.background="Texture/kidui/main/loadworld.png";
	_this.text = L"World Name";
	
	left, width = 145, 200
	_this=ParaUI.CreateUIObject("imeeditbox","LoadWorld_name_txt", "_lt",left, top,width,height);
	_parent:AddChild(_this);
	_this.text=KidsUI.DefaultLoadWorld;
	_this.background="Texture/kidui/main/bg_266X48.png";
	top = top+height+5;
	
	left = 32;
	width,height = 315,300;
	_this=ParaUI.CreateUIObject("listbox","listbox_worldnames", "_lt",left, top,width,height);
	_parent:AddChild(_this);
	_this.scrollable=true;
	_this.background="Texture/kidui/main/bg_269X152.png";
	_this.itemheight=15;
	_this.wordbreak=false;
	_this.onselect=";KidsUI.LoadWorld_OnWorldListSelect();";
	_this.ondoubleclick=";KidsUI.LoadWorld_OnOK();";
	_this.font="System;11;norm";
	_this.scrollbarwidth=20;
	
	-- list all sub directories in the User directory.
	CommonCtrl.InitFileDialog(ParaIO.GetCurDirectory(0)..kids_db.worlddir,"*.", 0, 150, _this);
	top = top+height+10;
	
	width,height = 121,59
	--确定
	_this=ParaUI.CreateUIObject("button","ok", "_lt",35,top,width,height);
	_parent:AddChild(_this);
	_this.background=L"Texture/kidui/main/ok.png";
	_this.onclick=[[;KidsUI.LoadWorld_OnOK();]];

	--取消
	_this=ParaUI.CreateUIObject("button","cancel", "_lt",235,top,width,height);
	_parent:AddChild(_this);
	_this.background=L"Texture/kidui/main/cancel.png";
	_this.onclick=";KidsUI.LoadWorld_OnCancel();";
	
	--简要说明 left display region
	_this=ParaUI.CreateUIObject("container","left_display_cont", "_lt",35,250,256,340);
	_parent=ParaUI.GetUIObject("loadworld_cont");_parent:AddChild(_this);
	_this.background="Texture/kidui/main/c_bg.png;0 0 256 340";
	_parent = _this;
	
	local left, top, width, height = 10,20,174, 42;
	_this=ParaUI.CreateUIObject("container","instructions", "_lt",left+10, top, width, height);
	_this.background=L"Texture/kidui/main/instructions.png";
	_parent:AddChild(_this);
	
	top = top + height+3;
	_this=ParaUI.CreateUIObject("container","c", "_lt",left,top,_parent.width-left,_parent.height-top);
	_this.background="Texture/whitedot.png;0 0 0 0";
	_this.scrollable = true;
	_parent:AddChild(_this);
	_parent = _this;
	
	_this=ParaUI.CreateUIObject("text","s", "_lt",0,0,_parent.width-20, 50);
	_parent:AddChild(_this);
	_this.text = L"load world instructions";
	_this.autosize=true;
	_this:DoAutoSize();
	_parent:InvalidateRect();
	
	-- 教程 right display region
	_this=ParaUI.CreateUIObject("container","right_display_cont", "_lt",733,250,256,340);
	_parent=ParaUI.GetUIObject("loadworld_cont");_parent:AddChild(_this);
	_this.background="Texture/kidui/main/c_bg.png;0 0 256 340";
	_parent = _this;
	
	KidsUI.ShowTutorialWindow("right_display_cont")
end
NPL.this(activate);

