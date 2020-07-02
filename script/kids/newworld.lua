--[[
Title: The Kids Movie UI
Author(s): LiXizhi(code&logic)
Date: 2006/1/26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/newworld.lua");
NPL.activate("(gl)script/kids/newworld.lua","");
------------------------------------------------------------
]]
-- requires:
NPL.load("(gl)script/kids/BasicSetting.lua");
NPL.load("(gl)script/kids/kids_db.lua");
NPL.load("(gl)script/ide/gui_helper.lua");
local L = CommonCtrl.Locale("KidsUI");

-- KidsUI: Kids UI library 
if(not KidsUI) then KidsUI={}; end

-- create a new world at path
--@param newworldpath such as "worlds/LiXizhi"
--@param BaseWorldPath: from which world the new world is derived. It can be nil if the empty world should be used. 
--@param bUseBaseWorldNPC: if this is true, base world NPC are inherited.
--@return the error message is returned as a string. otherwise true is returned.
function KidsUI.CreateWorldImmediate(NewWorldpath, BaseWorldPath, bUseBaseWorldNPC)
	kids_db.world.name = NewWorldpath;
	kids_db.SetDefaultFileMapping(NewWorldpath);
	-- ensure that the directory exists.
	ParaIO.CreateDirectory(NewWorldpath.."/log.txt");
	if(ParaIO.DoesFileExist(kids_db.world.sConfigFile, true) == true) then
		return L"world with the same name already exist. To use the name, please manually delete the folder ./"..NewWorldpath;
	else
		if(kids_db.SetBaseWorldName(BaseWorldPath) ==  true) then
			local sConfigFileName = ParaWorld.NewWorld(NewWorldpath, kids_db.world.sBaseWorldCfgFile);
			if(sConfigFileName ~= "") then
				kids_db.world.sConfigFile = sConfigFileName;
				-- copy the base world's attribute file to the newly created world.
				-- so that environment and initial character position are preserved. 
				if(kids_db.world.sBaseWorldAttFile~=nil) then
					ParaIO.CopyFile(kids_db.world.sBaseWorldAttFile, kids_db.world.sAttributeDbFile, true);
				end
				
				if(bUseBaseWorldNPC and kids_db.world.sBaseWorldNPCFile~=nil) then
					ParaIO.CopyFile(kids_db.world.sBaseWorldNPCFile, kids_db.world.sNpcDbFile, true);
				end
				
				--TODO: keep other info from the user.
				return true;
			else 
				return L"Failed creating the world";
			end
		else
			return L"The base world does not exist";
		end
	end
end

-- when the user new world button is clicked.
function KidsUI.NewWorld_OnOK()
	local worldpath, BaseWorldPath;
	
	local tmp = ParaUI.GetUIObject("NewWorld_baseworld_txt");
	if(tmp:IsValid() == true) then 
		BaseWorldPath = tmp.text;
	end
				
	local tmp = ParaUI.GetUIObject("NewWorld_name_txt");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		if(sName == "") then
			_guihelper.MessageBox(L"world name can not be empty".."\n");
		elseif(sName == "_emptyworld") then
			_guihelper.MessageBox(L"_emptyworld presents an empty world. Please use another name.".."\n");
		else
			worldpath = kids_db.worlddir..sName;-- append the world dir name
			
			-- create a new world
			local res = KidsUI.CreateWorldImmediate(worldpath, BaseWorldPath);
			if(res == true) then
				--TODO: keep other info from the user.
				-- load next UI
				KidsUI.NewWorldCreatedUI();
			elseif(type(res) == "string") then
				_guihelper.MessageBox(res);
			end
		end
	end
end

function KidsUI.NewWorld_OnCancel()
	ParaUI.Destroy("NewWorld_cont");
	KidsUI.PopState("newworld");
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

function KidsUI.NewWorld_OnParentWorldListSelect()
	local tmp = ParaUI.GetUIObject("listbox_parentworldnames");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		tmp = ParaUI.GetUIObject("NewWorld_baseworld_txt");
		if(tmp:IsValid() == true) then 
			tmp.text = kids_db.worlddir..sName;
		end
	end
end

local function activate()
	local _this,_parent,__font,__texture;
	KidsUI.PushState({name = "newworld", OnEscKey = KidsUI.NewWorld_OnCancel});
	
	_this=ParaUI.CreateUIObject("container","NewWorld_cont", "_fi",0,0,0,0);
	_this:AttachToRoot();
	_this:SetTopLevel(true);
	_parent=_this;
	
	KidsUI.UseStartupBackground(_this);
	
	_this=ParaUI.CreateUIObject("container","title", "_ct",-380,-380,773,224);
	_this.background="Texture/kidui/main/title.png;0 0 773 224";
	_parent:AddChild(_this);

	_this=ParaUI.CreateUIObject("container","middlecont", "_ct",-195,-210,400,512);
	_this.background="Texture/kidui/main/001_bg.png;0 0 400 512";
	_parent:AddChild(_this);
	_this.candrag=false;
	_parent=_this;

	local left, top, width, height = 35, 80, 110, 25;
	local left1, width1 = 145, 200
	--世界名称
	_this=ParaUI.CreateUIObject("text","s", "_lt",left, top, width, height);
	_parent:AddChild(_this);
	--_this.background="Texture/kidui/main/worldname.png";
	_this.text = L"World Name";
	
	_this=ParaUI.CreateUIObject("imeeditbox","NewWorld_name_txt", "_lt",left1, top, width1, height);
	_parent:AddChild(_this);
	_this.background="Texture/kidui/main/bg_266X48.png";
	top = top+height+5;
	
	--创建者
	_this=ParaUI.CreateUIObject("text","s", "_lt",left, top, width, height);
	_parent:AddChild(_this);
	--_this.background="Texture/kidui/main/builder.png";
	_this.text = L"Author Name";
	
	_this=ParaUI.CreateUIObject("imeeditbox","name4", "_lt",left1, top, width1, height);
	_parent:AddChild(_this);
	_this.background="Texture/kidui/main/bg_266X48.png";
	top = top+height+5;
	
	--派生自
	_this=ParaUI.CreateUIObject("text","s", "_lt",left,top,width,height);
	_parent:AddChild(_this);
	--_this.background="Texture/kidui/main/paisheng.png";
	_this.text=L"Derived from";
	
	_this=ParaUI.CreateUIObject("imeeditbox","NewWorld_baseworld_txt", "_lt",left1, top, width1, height);
	_parent:AddChild(_this);
	_this.background="Texture/kidui/main/bg_266X48.png";
	top = top+height+5;

	-- parent world list	
	left = 32;
	width,height = 315,245;
	_this=ParaUI.CreateUIObject("listbox","listbox_parentworldnames", "_lt",left,top,width,height);
	_parent:AddChild(_this);
	_this.scrollable=true;
	_this.background="Texture/kidui/main/bg_269X152.png";
	_this.itemheight=15;
	_this.wordbreak=false;
	_this.onselect=";KidsUI.NewWorld_OnParentWorldListSelect();";
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
	_this.onclick=[[;KidsUI.NewWorld_OnOK();]];

	--取消
	_this=ParaUI.CreateUIObject("button","cancel", "_lt",235,top,width,height);
	_parent:AddChild(_this);
	_this.background=L"Texture/kidui/main/cancel.png";
	_this.onclick=";KidsUI.NewWorld_OnCancel();";

	--简要说明 left display region
	_this=ParaUI.CreateUIObject("container","left_display_cont", "_lt",35,250,256,340);
	_parent=ParaUI.GetUIObject("NewWorld_cont");_parent:AddChild(_this);
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
	_this.text = L"new world instructions";
	_this.autosize=true;
	_this:DoAutoSize();
	_parent:InvalidateRect();
end
NPL.this(activate);

-- show another UI, whenever a new world has been successfully created.
function KidsUI.NewWorldCreatedUI()
	ParaUI.Destroy("NewWorld_cont");
	-- _guihelper.MessageBox(sName.."创建成功。请点击下一步。");
	
	_this=ParaUI.CreateUIObject("container","NewWorld_cont", "_fi",0,0,0,0);
	_this:AttachToRoot();
	_parent = _this;
	
	KidsUI.UseStartupBackground(_this);
	
	-- show congratulation text	
	local left, top, width, height = 85, 30, 721, 205;
	_this=ParaUI.CreateUIObject("container","congratulations", "_lt",left, top, width, height);
	_this.background=L"Texture/kidui/main/congratulations.png";
	_parent:AddChild(_this);
	top = top+height+65;
	
	-- tips of the day control is displayed here
	NPL.load("(gl)script/kids/ui/TipsOfDay.lua");
	
	left = 200
	width,height = 190, 41
	_this=ParaUI.CreateUIObject("container","tipsofday", "_lt",left, top, width,height);
	_this.background=L"Texture/kidui/main/tipsofday.png";
	_parent:AddChild(_this);
	top = top+height;
	
	local ctl = CommonCtrl.TipsOfDay:new{
		name = "TipsOfDay1",
		title = "",
		alignment = "_1t",
		left=left, top=top,
		width = 403,
		height = 290,
		imageWidth = 403,
		imageHeight = 256,
		pageindex = nil,
		content = kids_db.tipsofday,
		parent = _parent,
	};
	ctl:Show();

	-- another Start Game button
	_this=ParaUI.CreateUIObject("button","s", "_rb",-150, -80, 128, 64);
	_parent:AddChild(_this);
	_this.background=L"Texture/kidui/main/startgame.png";
	_this.highlightstyle="4outsideArrow";
	_this.animstyle = 11;
	_this.onclick = ";KidsUI.NewWorldCreated_OnStartGameBtn();";
end

function KidsUI.NewWorldCreated_OnStartGameBtn()
	if(kids_db.world.sConfigFile ~= "") then
		kids_db.UseDefaultFileMapping();
		if(KidsUI.LoadWorld() == true) then
			-- TODO: show something when the world is created for the first time.
		else
			_guihelper.MessageBox(kids_db.world.name..L" Failed loading the world.");
			KidsUI.NewWorld_OnCancel();
		end
	end
end