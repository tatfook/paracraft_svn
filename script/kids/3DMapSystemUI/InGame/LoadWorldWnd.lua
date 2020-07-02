--[[
Title: Load world window
Author(s): LiXizhi
Date: 2007/4/11
Revised: 2007/10/6
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/LoadWorldWnd.lua");
Map3DSystem.UI.LoadWorldWnd.Show
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/FileDialog.lua");

--KidsUI.DefaultLoadWorld = L("tutorial1","path");
KidsUI.DefaultLoadWorld = "";

if(not Map3DSystem.UI.LoadWorldWnd) then Map3DSystem.UI.LoadWorldWnd={}; end

-- appearance
Map3DSystem.UI.LoadWorldWnd.main_bg = "";

-- @param bShow: show or hide the panel 
-- @param _parent: parent window inside which the content is displayed. it can be nil.
function Map3DSystem.UI.LoadWorldWnd.Show(bShow,_parent,parentWindow)
	local _this;
	local left, top, width, height;

	Map3DSystem.UI.LoadWorldWnd.parentWindow = parentWindow;

	_this=ParaUI.GetUIObject("Map3DSystem.UI.LoadWorldWnd");
	if(_this:IsValid()) then
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
		if(bShow == false) then
			Map3DSystem.UI.LoadWorldWnd.OnDestory();
		end
	else
		if(bShow == false) then return	end
		
		width, height = 480, 512
		-- Map3DSystem.UI.LoadWorldWnd
		_this = ParaUI.CreateUIObject("container", "Map3DSystem.UI.LoadWorldWnd", "_ct", -width/2, -height/2, width, height)
		_this.background=Map3DSystem.UI.LoadWorldWnd.main_bg;
		if(_parent==nil) then
			_this:AttachToRoot();
		else
			_parent:AddChild(_this);
		end
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 3, 11, 440, 16)
		_this.text = "从下面列表中选择一个世界，然后点击打开按钮";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label7", "_lt", 8, 43, 88, 16)
		_this.text = "世界路径";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "WM_LOAD_WorldPath", "_mt", 102, 40, 18, 26)
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("listbox", "WM_LOAD_WorldList", "_fi", 6, 72, 18, 63)
		_this.onselect=";Map3DSystem.UI.LoadWorldWnd.WM_LOAD_WorldList_Select();";
		_this.ondoubleclick=";Map3DSystem.UI.LoadWorldWnd.On_WM_LOAD_OKBtn();";
		_this.wordbreak = false;
		_this.itemheight = 18;
		_this.scrollbarwidth = 20;
		_this.font = "System;13;norm";
		
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "WM_LOAD_OKBtn", "_lb", 6, -41, 105, 26)
		_this.text = "打开";
		_this.onclick=";Map3DSystem.UI.LoadWorldWnd.On_WM_LOAD_OKBtn();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "WM_LOAD_CancelBtn", "_rb", -123, -41, 105, 26)
		_this.text = "取消";
		_this.onclick=";Map3DSystem.UI.LoadWorldWnd.OnClose();"
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "WM_LOAD_DeleteWorldBtn", "_lb", 130, -41, 105, 26)
		_this.text = "删除";
		_this.onclick=";Map3DSystem.UI.LoadWorldWnd.On_WM_DeleteWorldBtn();";
		_parent:AddChild(_this);
	end
	if(bShow) then
		Map3DSystem.UI.LoadWorldWnd.OnRefreshDirectories();
	end
end

-- destory the control
function Map3DSystem.UI.LoadWorldWnd.OnDestory()
	ParaUI.Destroy("Map3DSystem.UI.LoadWorldWnd");
end

function Map3DSystem.UI.LoadWorldWnd.OnClose()
	if(Map3DSystem.UI.LoadWorldWnd.parentWindow~=nil) then
		-- send a message to its parent window to tell it to close. 
		Map3DSystem.UI.LoadWorldWnd.parentWindow:SendMessage(Map3DSystem.UI.LoadWorldWnd.parentWindow.name, CommonCtrl.os.MSGTYPE.WM_CLOSE);
	else
		ParaUI.Destroy("Map3DSystem.UI.LoadWorldWnd");
	end
end
---------------------------
-- for tab page: load world 
---------------------------

-- called to load the local world
function Map3DSystem.UI.LoadWorldWnd.On_WM_LOAD_OKBtn()
	-- disable network, so that it is local.
	ParaNetwork.EnableNetwork(false, "","");
	Map3DSystem.bShowTipsIcon = nil;
	
	local tmp = ParaUI.GetUIObject("WM_LOAD_WorldPath");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		if(sName == "") then
			_guihelper.MessageBox("世界名称不能为空");
		else
			local res = Map3DSystem.LoadWorld(sName);
			if(res==true) then
				-- Do something after the load	
				
				if(Map3DSystem.World.readonly) then
					Map3DSystem.User.SetRole("poweruser");
				else
					Map3DSystem.User.SetRole("administrator");
				end
			elseif(type(res) == "string") then
				-- show the error message
				_guihelper.MessageBox(res);
			end
		end
	end
end

-- called when select a world from the load world list box.
function Map3DSystem.UI.LoadWorldWnd.WM_LOAD_WorldList_Select()
	local tmp = ParaUI.GetUIObject("WM_LOAD_WorldList");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		tmp = ParaUI.GetUIObject("WM_LOAD_WorldPath");
		if(tmp:IsValid() == true) then 
			tmp.text = Map3DSystem.worlddir..sName;
		end
	end
end

function Map3DSystem.UI.LoadWorldWnd.On_WM_DeleteWorldBtn()
	local tmp = ParaUI.GetUIObject("WM_LOAD_WorldList");
	if(tmp:IsValid() == true and tmp.text~="") then 
		local sName = tmp.text;
		local dirPath = string.gsub(Map3DSystem.worlddir..sName, "/", "\\");
		if(dirPath)then
			_guihelper.MessageBox(string.format("您确定要删除%s么？\n删除后的文件将被移动到%s", dirPath, "temp\\"..dirPath), 
				string.format([[Map3DSystem.UI.LoadWorldWnd.On_WM_DeleteWorld_imp(%q)]], dirPath));
		end
	end
end

-- @param worldpath: which world to delete
function Map3DSystem.UI.LoadWorldWnd.On_WM_DeleteWorld_imp(worldpath)
	local targetDir = "temp\\"..worldpath;
	if(ParaIO.CreateDirectory(targetDir) and ParaIO.MoveFile(worldpath, targetDir)) then  
		Map3DSystem.UI.LoadWorldWnd.OnRefreshDirectories();
	else
		_guihelper.MessageBox("无法删除，可能您没有足够的权限."); 
	end
end

--  refresh the directories.
function Map3DSystem.UI.LoadWorldWnd.OnRefreshDirectories()
	local tmp = ParaUI.GetUIObject("WM_LOAD_WorldList");
	if(tmp:IsValid() == true) then 
		tmp:RemoveAll();
		-- list all sub directories in the User directory.
		CommonCtrl.InitFileDialog(ParaIO.GetCurDirectory(0)..Map3DSystem.worlddir,{"*.","*.zip",}, 0, 150, tmp);
	end
end