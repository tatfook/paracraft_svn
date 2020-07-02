--[[
Title: Item editor for 3D Map system
Author(s): WangTian
Date: 2007/10/26
Desc: editor for programers to test their items
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/TestPanel.lua");
Map3DSystem.UI.TestPanel.Show();
------------------------------------------------------------
--]]

if(not Map3DSystem.UI.TestPanel) then Map3DSystem.UI.TestPanel = {} end

local L = CommonCtrl.Locale("Kids3DMap");

-- @param bShow: show or hide the panel 
function Map3DSystem.UI.TestPanel.Show(bShow)
	local _this;
	local _parent = ParaUI.GetUIObject("test_panel");
	if(_parent:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _parent.visible;
		end
		_parent.visible = bShow;
	else
		if(bShow == false) then return	end
		
		local _parent = ParaUI.CreateUIObject("container", "test_panel", "_rt", -150, 24, 150, 350);
		_parent:AttachToRoot();
		local _this = ParaUI.CreateUIObject("button", "test1", "_lt", 10, 10, 128, 32);
		_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/btn_bg_highlight.png: 4 4 4 4";
		_this.text = "test1";
		_this.onclick = ";Map3DSystem.UI.TestPanel.Test1();";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "test2", "_lt", 10, 50, 128, 32);
		_this.text = "test2";
		_this.onclick = ";Map3DSystem.UI.TestPanel.Test2();";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "test3", "_lt", 10, 90, 128, 32);
		_this.text = "test3";
		_this.onclick = ";Map3DSystem.UI.TestPanel.Test3();";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "test4", "_lt", 10, 130, 128, 32);
		_this.text = "test4";
		_this.onclick = ";Map3DSystem.UI.TestPanel.Test4();";
		_parent:AddChild(_this);
		
		ParaScene.Enable3DCanvas(0, true);
		_this = ParaUI.CreateUIObject("3dcanvas", "tempCanvas", "_lt", 15, 170, 120, 120);
		_this.canvasindex = 0;
		_this.background = "";
		_parent:AddChild(_this);
	end
end

-- test the main app list with the existing mainbar user interface
function Map3DSystem.UI.TestPanel.TestAppList()
	
end


function Map3DSystem.UI.TestPanel.Test1()
	
	-- TODO: leave this painter test for Leio
	--Map3DSystem.UI.Painter.OnClick();
	
	NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotShop.lua");
	Map3DSystem.UI.RobotShop.OnClick();
	
	--local _panel = ParaUI.CreateUIObject("container", "testIconSize", "_ct", -500, 0, 1000, 100);
	--_panel:AttachToRoot();
	--
	--for i = 0, 12 do
		--local _this = ParaUI.CreateUIObject("button", "1", "_lt", 70* i, 10, 16 + 4 * i, 16 + 4 * i);
		--_this.background = ParaUI.GetUIObject("MainBar_icons_1").background;
		--_panel:AddChild(_this);
	--end
	
	
	
	
	--_guihelper.MessageBox("Test1 clicked!\r\n");
	--Map3DSystem.UI.MainBar.ShowBarWithAnimation(true);
	--Map3DSystem.UI.MainBar.ShowAllBarIconsWithAnimation(true, Map3DSystem.UI.Animation.Style8.Flat, 8);
	
	--NPL.load("(gl)script/ide/UIAnim/UIAnimBlock.lua");
--
	--local ctl = UIAnimBlock:new{
			--name = "UIAnimationBlock1",
			--text = "testTXT",
		--};
		--
	--ctl = UIAnimBlock:new{
			--text = "testTXT",
		--};
		
		
	-- NPL.load("(gl)script/ide/commonlib.lua");
	-- local animTable = commonlib.LoadTableFromFile("script/UIAnimation/Test_UIAnimFile.lua.table");
	
	--NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
	--local fileName = "script/UIAnimation/Test_UIAnimFile.lua.table";
	--local file = UIAnimManager.LoadUIAnimationFile(fileName);
	--
	--fileName = "script/UIAnimation/CommonIcon.lua.table";
	--file = UIAnimManager.LoadUIAnimationFile(fileName);
	
	
	--Map3DSystem.Misc.SaveTableToFile(file, "TestTable/File.ini");
	
	
	
	
	
	
	--local _this = ParaUI.CreateUIObject("container", "testKey", "_lt", 20, 10, 800, 128);
	--_this.background = "Texture/3DMapSystem/IM/greymsn.png: 8 8 8 8";
	--_this:GetTexture("background").color = "58 177 222";
	--_this:AttachToRoot();
	
	
	
	
	--ctl = UIAnimBlock:new(animTable.UIAnimation[1].ScaleX);
	--
	--local val = ctl:getValue(1, 400);
	--log("getValue: "..val.."\r\n");
		
	--Map3DSystem.Misc.SaveTableToFile(ctl, "TestTable/ctl1.ini");
	--Map3DSystem.Misc.SaveTableToFile(UIAnimationBlock.AllObjects, "TestTable/AllObjects1.ini");
	--
	--ctl.text = "crazy";
	--Map3DSystem.Misc.SaveTableToFile(ctl, "TestTable/ctl2.ini");
	--Map3DSystem.Misc.SaveTableToFile(UIAnimationBlock.AllObjects, "TestTable/AllObjects2.ini");
	--ctl:TestOORead();
	--ctl.onclickevent();
	--
	--ctl:Destroy();
	--Map3DSystem.Misc.SaveTableToFile(ctl, "TestTable/ctl3.ini");
	--Map3DSystem.Misc.SaveTableToFile(UIAnimationBlock.AllObjects, "TestTable/AllObjects3.ini");
	--
	--if(ctl == nil) then
		--log("ctl is nil\r\n");
	--else
		--log("ctl is not nil\r\n");
	--end

end

function TestAnimationWithID(nAnimID)
	if(nAnimID>0) then
		if(not player) then
			player = ParaScene.GetPlayer();
		end
		player:ToCharacter():PlayAnimation(nAnimID);
	end
end

function ShowTestAnimationWithID()
	if(ParaUI.GetUIObject("ShowTestAnimationWithID"):IsValid() == true) then
		return;
	end
	local _parent = ParaUI.CreateUIObject("container", "ShowTestAnimationWithID", "_lt", 0, 0, 500, 200);
	_parent:AttachToRoot();
	
	local _this = ParaUI.CreateUIObject("button", "_", "_lt", 20, 20, 80, 32);
	_this.text = "测试死亡动作";
	_this.onclick = ";TestAnimationWithID(1);";
	_parent:AddChild(_this);
	
	local _this = ParaUI.CreateUIObject("button", "_", "_lt", 120, 20, 80, 32);
	_this.text = "测试徒手攻击动作";
	_this.onclick = ";TestAnimationWithID(16);";
	_parent:AddChild(_this);
	
	local _this = ParaUI.CreateUIObject("button", "_", "_lt", 20, 120, 64, 32);
	_this.text = "关闭";
	_this.onclick = ";ParaUI.Destroy(\"ShowTestAnimationWithID\");";
	_parent:AddChild(_this);
end

-- open a file dialog that allows a user to select an animation file to play for the current character
-- please note that the current character model must support external animation and matches the initial bone animation in the animation file.
function Map3DSystem.UI.TestPanel.TestExternalAnimation()
	-- allows a user to select an animation file to play for the current character
	NPL.load("(gl)script/ide/action_table.lua");
	NPL.load("(gl)script/ide/OpenFileDialog.lua");
	local ctl = CommonCtrl.OpenFileDialog:new{
		name = "OpenFileDialogAnim",
		alignment = "_lt",
		left = 0, top = 0,
		width = 500,
		height = 600,
		parent = nil,
		fileextensions = {"all files(*.x)" },
		folderlinks = {
			{path = "character/Animation/v3/", text = "v3"},
			{path = "character/Animation/Angel/", text = "Angel"},
			{path = "character/Animation/", text = "动作库"},
			{path = "character/Animation/hs/", text = "HS测试"},
		},
		showSubDirLevels = 1,
		onopen = ABC,
	};
	ctl:Show(true);
end

function ABC(sCtrlName, filename)
	action_table.PlayAnimationFile(filename);
	Map3DSystem.UI.TestPanel.TestExternalAnimation()
end

function Map3DSystem.UI.TestPanel.Test2()
	--_guihelper.MessageBox("Test2 clicked!\r\n");
	
	Map3DSystem.UI.TestPanel.TestExternalAnimation()
	
	
	--Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_Show, bShow = true,});
	--Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_SwitchStatus, sStatus = "none",});
	--Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_Show, bShow = nil,});
	
	
	
	
	
	--local _testCont = ParaUI.CreateUIObject("container", "testKey", "_lt", 20, 10, 800, 128);
	--_testCont.background = "Texture/3DMapSystem/IM/greymsn.png";
	--_testCont:GetTexture("background").color = "58 177 222";
	--_testCont:AttachToRoot();
	--
	--local _testCont = ParaUI.CreateUIObject("container", "testKey", "_lt", 20, 10, 800, 700);
	--_testCont.background = "Texture/3DMapSystem/TEST/TEST.PNG: 85 29 28 13";
	--_testCont.visible = false;
	--_testCont:AttachToRoot();
	--
	--local _font = "myriad pro"; --kozuka gothic pro
	----local _font = "helvetica";
	--local _bBold = false;
	--if(_bBold == true) then
		--boldStr = "bold";
	--else
		--boldStr = "regular";
	--end
	----local _scaling = 1.0625;
	--local _scaling = 0.9375;
	----local _scaling = 1;
	--
	--local i;
	--for i = 12, 24 do
		--local _testEdit = ParaUI.CreateUIObject("text", "testText", "_lt", 10, 50*i - 600, 790, 50);
		--_testCont:AddChild(_testEdit);
		--_testEdit.text = "QWERTYUIOPASDFGHJKLZXCVBNM qwertyuiopasdfghjklzxcvbnm "..i.." "..boldStr;
		----_testEdit.font = "System;15;norm";
		--_testEdit.font = _font..";"..i..";"..boldStr..";true";
		--_testEdit.scalingx = _scaling;
		--_testEdit.scalingy = _scaling;
		--_testEdit:GetFont("text").color = "255 255 255";
	--end
	
	
	--NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
	--local fileName = "script/UIAnimation/Test_UIAnimFile.lua.table";
	--local file = UIAnimManager.LoadUIAnimationFile(fileName);
	--
	--for i = 1, 110 do
		--local x = file.UIAnimation[1].TranslationX:getValue(3, 16*i);
		--log(16*i.." val: "..x.."\n");
	--end
	
	--
	--NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
	--local _icon = ParaUI.GetUIObject("MainBar_icons_1");
	--
	----local fileName = "script/UIAnimation/Test_UIAnimFile.lua.table";
	----UIAnimManager.PlayUIAnimationSequence(_icon, fileName, "Show", true);
	--
	--local fileName = "script/UIAnimation/CommonIcon.lua.table";
	--UIAnimManager.PlayUIAnimationSequence(_icon, fileName, "Flash", true);
	----UIAnimManager.PlayUIAnimationSequence(_icon, fileName, "Hide", false);
	
	
	-- UI animation test
	
	--local _panel = ParaUI.GetUIObject("test_panel");
	--NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
	--local fileName = "script/UIAnimation/CommonIcon.lua.table";
	--UIAnimManager.PlayUIAnimationSequence(_panel, fileName, "Show", false);
	
	
	--Map3DSystem.UI.MainBar.ShowBarWithAnimation(false);
	--Map3DSystem.UI.MainBar.ShowAllBarIconsWithAnimation(false, Map3DSystem.UI.Animation.Style8.Flat, 8);
end

function OnDEMOMouseEnter()
	log("Enter\n");
end
function OnDEMOMouseLeave()
	log("Leave\n");
end

function Map3DSystem.UI.TestPanel.Test3()
	ShowTestAnimationWithID()
	
	do return end
	
	--NPL.load("(gl)script/test/TestGridView.lua");
	--TestGridView();
	
	ParaUI.Destroy("sdas");
	
	CommonCtrl.DeleteControl("Dock1");
	
	local _parent = ParaUI.CreateUIObject("container", "sdas", "_fi", 50, 100, 50, 100);
	_parent:AttachToRoot();
	
	NPL.load("(gl)script/ide/Dock.lua");
	local _dock = CommonCtrl.GetControl("Dock1");
	if(_dock == nil)then
		_dock = CommonCtrl.Dock:new{
			name = "Dock1",
			parent = _parent,
			height = 64,
		};
	end
	
	
	_dock:InsertGroup("apps", 1);
	_dock:InsertGroup("stacks", 2);
	_dock:InsertGroup("feed", 3);
	_dock:InsertItemToGroup("creator", 1, 1);
	_dock:InsertItemToGroup("chat", 2, 1);
	_dock:InsertItemToGroup("map", 3, 1);
	_dock:InsertItemToGroup("more...", 4, 1, 24);
	--_dock:InsertItemToGroup("chat1", 1, 2);
	--_dock:InsertItemToGroup("chat2", 2, 2);
	--_dock:InsertItemToGroup("chat3", 3, 2);
	_dock:InsertItemToGroup("message", 1, 3);
	_dock:InsertItemToGroup("notification", 2, 3);
	_dock:InsertItemToGroup("invitation", 3, 3);
	
	_dock:Show();
	_dock:Update();
	
	_dock:InsertItemToGroup("chat1", 1, 2);
	
	--_dock:RemoveItemFromGroupByIndex(1, 2);
	--_dock:RemoveItemFromGroupByIndex(3, 3);
	_dock:Update();
	
	_guihelper.PrintTableStructure(UIDirectAnimationPool, "TestTable/UIDirectAnimationPool.ini");
	
	
	local _dock = ParaUI.GetUIObject("Dock_Dock1");
	
	_guihelper.PrintUIObjectStructure(_dock, "TestTable/DockUI.ini");
	
	
	
	local _parent = ParaUI.CreateUIObject("container", "fewqgq", "_lt", 300, 300, 64, 64);
	_parent:AttachToRoot();
	
	local _this = ParaUI.CreateUIObject("button", "greqgrq", "_lt", 0, 0, 48, 48);
	_parent:AddChild(_this);
	
	local function abc()
		log("callback1\n");
	end
	
	NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
	local block = UIDirectAnimBlock:new();
	block:SetUIObject(_this);
	block:SetTime(120);
	block:SetXRange(0, 50);
	block:SetWidthRange(48, 128);
	block:SetHeightRange(48, 128);
	--block:SetCallback("log(\"string callback\"\n)");
	
	UIAnimManager.PlayDirectUIAnimation(block);
	
	block = UIDirectAnimBlock:new();
	block:SetUIObject(_this);
	block:SetTime(120);
	block:SetXRange(50, 0);
	block:SetYRange(50, 0);
	block:SetWidthRange(128, 48);
	block:SetHeightRange(128, 48);
	--block:SetCallback(abc);
	
	UIAnimManager.PlayDirectUIAnimation(block);
	
	
	---- Leio's open folder dialog
	--NPL.load("(gl)script/ide/OpenFolderDialog.lua");
	--local dialog = CommonCtrl.OpenFolderDialog:new();
	--dialog:Show();
	
	
	--local area1 = ParaUI.CreateUIObject("container", "area1", "_lt", 200, 200, 100, 100);
	--area1.onmouseenter = ";OnDEMOMouseEnter();";
	--area1.onmouseleave = ";OnDEMOMouseLeave();";
	--area1:AttachToRoot();
	--local area2 = ParaUI.CreateUIObject("container", "area2", "_lt", 250, 250, 100, 100);
	--area2.onmouseenter = ";OnDEMOMouseEnter();";
	--area2.onmouseleave = ";OnDEMOMouseLeave();";
	--area2:AttachToRoot();
	
	
	--NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
	--local _icon = ParaUI.GetUIObject("MainBar_icons_1");
	--
	----local fileName = "script/UIAnimation/Test_UIAnimFile.lua.table";
	----UIAnimManager.StopLoopingUIAnimationSequence(_icon, fileName, "Flash");
	--
	--local fileName = "script/UIAnimation/CommonIcon.lua.table";
	--UIAnimManager.PlayUIAnimationSequence(_icon, fileName, "Show", false);
	----UIAnimManager.StopLoopingUIAnimationSequence(_icon, fileName, "Bounce");
	
	
	----_guihelper.MessageBox("Test3 clicked!\r\n");
	--Map3DSystem.UI.MainBar.ShowBarWithAnimation(nil);
	--Map3DSystem.UI.MainBar.ShowAllBarIconsWithAnimation(nil, Map3DSystem.UI.Animation.Style8.Flat, 8);
	
	
	
	--local _testCont = ParaUI.CreateUIObject("container", "testKey", "_lt", 200, 300, 200, 100);
	--_testCont:AttachToRoot();
	--
	--local _testEdit = ParaUI.CreateUIObject("imeeditbox", "testEdit", "_lt", 50, 25, 100, 50);
	--_testCont:AddChild(_testEdit);
	--_testEdit.onkeyup = ";Map3DSystem.UI.MainBar.TestKeyUp();";
	--_testEdit.onkeydown = ";Map3DSystem.UI.MainBar.TestKeyDown();";
	

	--local obj = Map3DSystem.obj.GetObjectParams("selection");
	--Map3DSystem.UI.CCS.ApplyCCSInfoString(obj, sInfo);
	
	
	
	--local r1 = Map3DSystem.UI.Profile.RemoveMyClient("paraengine@paraweb3d.com");
	--local r2 = Map3DSystem.UI.Profile.RemoveMyServer("lixizhi@paraweb3d.com");
	--
	--if (r1 == true) then Map3DSystem.UI.Profile.AppendMyLog("paraengine@paraweb3d.com removed from client"); end
	--if (r2 == true) then Map3DSystem.UI.Profile.AppendMyLog("lixizhi@paraweb3d.com removed from server"); end
	--
	--Map3DSystem.UI.Profile.AppendMyLog("paraengine@paraweb3d.com removed from client");
	
	
	
	
	--NPL.load("(gl)script/test/TestBagCtl.lua");
	--TestBagCtl();
	
	
	
	
	--NPL.load("(gl)script/kids/3DMapSystemData/DBAssets.lua");
	--local itemTable = {};
	--local item = {
		  --["Reserved4"] = "R4",
		  --["Reserved3"] = "R3",
		  --["Reserved1"] = "R1",
		  --["Reserved2"] = "R2",
		  --["Price"] = 0,
		  --["IconAssetName"] = "Tree",
		  --["ModelFilePath"] = "model/05plants/02tree/01tree/tree02/tree020_v.x",
		  --["IconFilePath"] = "model/05plants/02tree/01tree/tree02/tree020.x.png",
		--};
	--Map3DSystem.DB.AddItem(itemTable, item);
	--local item2 = {
		  --["Reserved4"] = "R4",
		  --["Reserved3"] = "R3",
		  --["Reserved1"] = "R1",
		  --["Reserved2"] = "R2",
		  --["Price"] = 0,
		  --["IconAssetName"] = "Tree",
		  --["ModelFilePath"] = "model/05plants/02tree/01tree/tree02/tree020_v.x",
		  --["IconFilePath"] = "model/05plants/02tree/01tree/tree02/tree020.x.png",
		--};
	--Map3DSystem.DB.AddItem(itemTable, item2);
	--
	--local commandName = "Creator.Normal Model.TEST";
	--local command = Map3DSystem.App.Commands.GetCommand(commandName);
	--if(command == nil) then
		--command = Map3DSystem.App.Commands.AddNamedCommand({
				--name = commandName, 
				--app_key = nil, 
				--group = {
					--["name"] = "NM_TESTTree",
					--["rootpath"] = "model/01building/",
					--["text"] = "TEST",
					--icon = "Texture/3DMapSystem/MainBarIcon/Creator/LargeBuilding.png",
					--tooltip = "TEST",
				--};
				--items = itemTable,
			--});
		---- add command to creator category
		--local pos_category = commandName;
		---- add to back.
		--command:AddControl("creator", pos_category); -- , 5);
	--end
	
	
	
	
	--NPL.load("(gl)script/kids/3DMapSystemData/DBAssets.lua");
	--local itemTable = {};
	--local item = {
		  --["Reserved4"] = "R4",
		  --["Reserved3"] = "R3",
		  --["Reserved1"] = "R1",
		  --["Reserved2"] = "R2",
		  --["Price"] = 0,
		  --["IconAssetName"] = "Tree",
		  --["ModelFilePath"] = "model/05plants/02tree/01tree/tree02/tree020_v.x",
		  --["IconFilePath"] = "model/05plants/02tree/01tree/tree02/tree020.x.png",
		--};
	--Map3DSystem.DB.AddItem(itemTable, item);
	--local item2 = {
		  --["Reserved4"] = "R4",
		  --["Reserved3"] = "R3",
		  --["Reserved1"] = "R1",
		  --["Reserved2"] = "R2",
		  --["Price"] = 0,
		  --["IconAssetName"] = "Tree",
		  --["ModelFilePath"] = "model/05plants/02tree/01tree/tree02/tree020_v.x",
		  --["IconFilePath"] = "model/05plants/02tree/01tree/tree02/tree020.x.png",
		--};
	--Map3DSystem.DB.AddItem(itemTable, item2);
	--
	--local group =
		--{
			--["name"] = "NM_TESTTree",
			--["rootpath"] = "model/01building/",
			--["text"] = "TEST",
			--icon = "Texture/3DMapSystem/MainBarIcon/Creator/LargeBuilding.png",
			--tooltip = "TEST",
		--};
	--Map3DSystem.DB.AddGroup("Normal Model", group, itemTable, true);
	
	-- Remove the group from creation menu
	--Map3DSystem.DB.RemoveGroup("NM_TESTTree", true);
	
	
	
	
	
	--local area1 = ParaUI.CreateUIObject("container", "area1", "_lt", 200, 200, 50, 50);
	--area1:AttachToRoot();
	--local area1icon = ParaUI.CreateUIObject("button", "area1icon", "_lt", 5, 5, 40, 40);
	--area1icon.text = "1";
	--area1:AddChild(area1icon);
	--local area2 = ParaUI.CreateUIObject("container", "area2", "_lt", 250, 200, 50, 50);
	--area2:AttachToRoot();
	--local area2icon = ParaUI.CreateUIObject("button", "area2icon", "_lt", 5, 5, 40, 40);
	--area2icon.text = "2";
	--area2:AddChild(area2icon);
	--local area3 = ParaUI.CreateUIObject("container", "area3", "_lt", 300, 200, 50, 50);
	--area3:AttachToRoot();
	--
	--area3:AddChild(area2icon);
	--area2icon.x = 5;
	--area2icon.y = 5;
	
	
	
	
	--
	--local testDrag = ParaUI.CreateUIObject("button", "testDrag", "_lt", 200, 200, 50, 50);
	--testDrag.ondragbegin = [[;ParaUI.AddDragReceiver("testDragCont");]];
	--testDrag.candrag = true;
	--testDrag:AttachToRoot();
	--
	--local _testDragCont = ParaUI.CreateUIObject("container", "testDragCont", "_lt", 300, 300, 200, 200);
	--_testDragCont:SetTopLevel(true);
	--_testDragCont.candrag = true;
	--_testDragCont:AttachToRoot();
	--local _testDragInside = ParaUI.CreateUIObject("container", "testInside", "_fi", 50, 50, 50, 50);
	--_testDragCont:AddChild(_testDragInside);
	
	
	
	--local _app = CommonCtrl.os.CreateGetApp("fdsaf");
	--local _wnd = _app:RegisterWindow("fdsaf", nil, Map3DSystem.UI.KidsMovieOriginal.WebBrowserMSGProc);
	--
			--local param = {
				--wnd = _wnd,
				----isUseUI = true,
				--mainBarIconSetID = 17, -- or nil
				--icon = "Texture/3DMapSystem/MainBarIcon/Modify.png",
				--iconSize = 48,
				--text = "商城（全部应用程序）",
				--style = Map3DSystem.UI.Windows.Style[1],
				--maximumSizeX = 800,
				--maximumSizeY = 650,
				--minimumSizeX = 700,
				--minimumSizeY = 500,
				--isShowIcon = true,
				----opacity = 100, -- [0, 100]
				--isShowMaximizeBox = false,
				--isShowMinimizeBox = false,
				--isShowAutoHideBox = false,
				--allowDrag = true,
				--allowResize = false,
				--initialPosX = 150,
				--initialPosY = 100,
				--initialWidth = 500,
				--initialHeight = 500,
				--isTopLevel = true,
				--
	--NPL.load("(gl)script/kids/3DMapSystemUI/Movie/VideoRecorder.lua");
				--ShowUICallback = Map3DSystem.Movie.VideoRecorder.Show,
				--
			--};
	--_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
end

function Map3DSystem.UI.TestPanel.TestKeyDown()
	log("KeyDown:"..virtual_key.."\n");
end

function Map3DSystem.UI.TestPanel.TestKeyUp()
	log("KeyUp:"..virtual_key.."\n");
end


function Map3DSystem.UI.TestPanel.Test4()
	
	local i;
	for i = 1, 36 do
		local _hue = ParaUI.CreateUIObject("container", "_lt", "1", 30 + 24 * i, 100, 24, 24);
		_hue.background = "Texture/painter_solid.png";
		
		local R, G, B = _guihelper.HSL2RGB2(i/37, 0.5, 0.5);
		
		_hue.color = R.." "..G.." "..B.." 255";
		log((i/37).." "..R.." "..G.." "..B.."\n");
		_hue:AttachToRoot();
	end
	
	--local R, G, B = _guihelper.HSL2RGB2(0.33, 0.79, 0.52);
	
	do return end
	
	
	local obj = Map3DSystem.obj.GetObjectParams("selection");
	
	obj = ParaScene.GetPlayer();
	
	sInfo = Map3DSystem.UI.CCS.GetCCSInfoString(obj);
	
	local filename = obj:GetPrimaryAsset():GetKeyName();
	log(filename.."\n"..sInfo.."\n");
	
	do return end
	
	local _ml = ParaUI.CreateUIObject("container", "_mr", "_mr", 100, 100, 100, 100);
	_ml:AttachToRoot();
	
	_ml.candrag = true;
	
	local _resizer = ParaUI.GetUIObject("Assets_GUID_AssetManager_resizer");
	
	local x_resizer, y_resizer, width_resizer, height_resizer = _resizer:GetAbsPosition();
	commonlib.log({x_resizer, y_resizer, width_resizer, height_resizer});
	
	do return end
	
	
	
	local function ABC(n)
		local columns = 1;
		while(n > (columns * columns)) do
			columns = columns + 1;
		end
		local rows = math.ceil(n/columns);
		return rows, columns;
	end
	
	local i = 1;
	for i = 1, 20 do
		log(string.format("%d: (%d, %d)\n", i, ABC(i)));
	end
	
	local str = "206,210,206,210";
	NPL.DoString(string.format([[ret = string.char(%s);]], str));
	log(ret.."\n")
	ret = nil;
	
	do return end
	
	local _panel = ParaUI.CreateUIObject("container", "FeedPanel", "_lt", 100, 100, 100, 100);
	_panel:AttachToRoot();
	
	local fileName = "script/UIAnimation/CommonIcon.lua.table";
	UIAnimManager.PlayUIAnimationSequence(_panel, fileName, "Show", false);
	
	do return end
	
	
	
	
	
	local _ml = ParaUI.CreateUIObject("container", "_ml", "_ml", 0, 0, 100, 0);
	_ml:AttachToRoot();
	_ml.height = 100;
	
			local _, __, width, height = _ml:GetAbsPosition();
			
			log(" "..width.." "..height.."\n");
			
	local _mr = ParaUI.CreateUIObject("container", "_mr", "_mr", 0, 0, 100, 0);
	_mr:AttachToRoot();
	_mr.height = 100;
	
			local _, __, width, height = _mr:GetAbsPosition();
			
			log(" "..width.." "..height.."\n");
			
	--NPL.load("(gl)script/test/TestGridView.lua");
	--TestGridView();
	
	do return end
	
	local _ml = ParaUI.CreateUIObject("container", "_mr", "_mr", 100, 100, 100, 100);
	_ml:AttachToRoot();
	
	_ml.candrag = true;
	_ml.height = 300;
	_ml.height = 100;
	
	--_ml.x = -50;
	--_ml.width = 50;
	
	
	do return end
	
	
	ParaAsset.OpenArchive("worlds/Templates/Favorites/尼罗河.zip", true);
	
	
	local t = ParaUI.CreateUIObject("button", "test", "_lt", 200, 200, 50, 50);
	t.background = "worlds/Templates/Favorites/尼罗河/Favorite_5.png";
	t:AttachToRoot();
	
	local texture = ParaAsset.LoadTexture("", "worlds/Templates/Favorites/尼罗河/Favorite_5.png", 1);
	
	local width = texture:GetWidth()
	local height = texture:GetHeight()
	
	log(width.." "..height.."\n");
	
	
	
	
	
	
	--NPL.load("(gl)script/test/TestGridView3D.lua");
	--TestGridView3D();
	
	
	--NPL.load("(gl)script/ide/ProjectTemplates/ProjectTemplatesWnd.lua");
	--ProjectTemplatesWnd.NewProject()
	
	
	
	--local panel = ParaUI.GetUIObject("test_panel");
	--local t3 = panel:GetChild("test3");
	--t3.enable = false;
	--
	--_guihelper.MessageBox("Test4 clicked!\r\n");
	
	
	--NPL.load("(gl)script/test/TestGridView.lua");
	--TestGridView();
	
	
	--NPL.load("(gl)script/kids/3DMapSystemUI/ApplicationManager.lua");
	--Map3DSystem.ApplicationManager.LoadApplication("Poke");
	
	
	
	-- NOTE: test CCS preview model with replaceable texture 
	--
	--local _obj = Map3DSystem.obj.GetObject("selection");
	--local _number = _obj:GetNumReplaceableTextures();
	--log("replaceable: ".._number.."\n");
	--
	--local _TL = "character/v3/Item/TextureComponents/TorsoLowerTexture/MomoMale05_he_TL_U.DDS"
	--local _TU = "character/v3/Item/TextureComponents/TorsoUpperTexture/MomoMale05_he_TU_U.DDS"
	--local _AL = "character/v3/Item/TextureComponents/ArmLowerTexture/MomoMale05_he_AL_U.DDS"
	--local _AU = "character/v3/Item/TextureComponents/ArmUpperTexture/MomoMale05_he_AU_U.DDS"
	--
	---- apply the texture
	--local texture_TL = ParaAsset.LoadTexture("", _TL, 1);
	--local texture_TU = ParaAsset.LoadTexture("", _TU, 1);
	--local texture_AL = ParaAsset.LoadTexture("", _AL, 1);
	--local texture_AU = ParaAsset.LoadTexture("", _AU, 1);
	--_obj:SetReplaceableTexture(0, texture_TL);
	--_obj:SetReplaceableTexture(1, texture_TU);
	--_obj:SetReplaceableTexture(2, texture_AL);
	--_obj:SetReplaceableTexture(3, texture_AU);
	
	
	
	--NPL.load("(gl)script/test/TestXPath.lua");
	--TestXPath();
	
	--local desc = 
	--{
		--ShowIcon = true;
		--ToolTip = L"Sky";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Sky.png; 0 0 48 48";
		--Type = "Panel";
		--ShowUICallback = Map3DSystem.UI.Sky.ShowUI;
		--CloseUICallback = Map3DSystem.UI.Sky.CloseUI;
		--MouseEnterCallback = Map3DSystem.UI.Sky.OnMouseEnter;
		--MouseLeaveCallback = Map3DSystem.UI.Sky.OnMouseLeave;
	--};
	--Map3DSystem.UI.MainBar.AddItem(desc, 17);
	
	
	--_guihelper.MessageBox("Test4 clicked!\r\n");
	
	--local istestautohide = false;
	--if(istestautohide) then
		--local _testAutoHide = ParaUI.CreateUIObject("container", "testautohide", "_lt", 200, 300, 200, 100);
		--_testAutoHide:AttachToRoot();
		--_testAutoHide.onmouseenter = ";Map3DSystem.UI.MainBar.TestEnter();";
		--_testAutoHide.onmouseleave = ";Map3DSystem.UI.MainBar.TestLeave();";
		--
		--local _btn = ParaUI.CreateUIObject("button", "btnAutoHideTest", "_rt", -70, 10, 50, 50);
		--_btn.onclick = ";Map3DSystem.UI.MainBar.TestToggle();";
		--_btn.text = "on";
		--Map3DSystem.UI.MainBar.autoHideToggle = true;
		--_testAutoHide:AddChild(_btn);
	--end
	--
	--if(abc) then
		--Map3DSystem.UI.Modify.CloseUI();
		--abc = false;
	--else
		--Map3DSystem.UI.Modify.ShowUI();
		--abc = true;
	--end
	
	--NPL.load("(gl)script/kids/3DMapSystemUI/BCS/DB.lua");
	--Map3DSystem.UI.BCS.DB.SortBCSDB();
	
	
	local obj = Map3DSystem.obj.GetObjectParams("selection");
	
	obj = ParaScene.GetPlayer();
	
	sInfo = Map3DSystem.UI.CCS.GetCCSInfoString(obj);
	
	local filename = obj:GetPrimaryAsset():GetKeyName();
	log(filename.."\n"..sInfo.."\n");
	
	
	--Map3DSystem.UI.CCS.Predefined.GetFacialInfo(Map3DSystem.obj.GetObjectParams("selection"))
	--Map3DSystem.UI.CCS.DB.GetCartoonfaceInfo(Map3DSystem.obj.GetObjectParams("selection"))
	--Map3DSystem.UI.CCS.Inventory.GetCharacterSlotInfo(Map3DSystem.obj.GetObjectParams("selection"))
	--
	--NPL.load("(gl)script/kids/3DMapSystem_Misc.lua");
	--Map3DSystem.Misc.SaveTableToFile(Map3DSystem.obj.GetObjectParams("selection"), "TestTable/obj_PARAM.ini");
	
	
	--NPL.load("(gl)script/kids/3DMapSystem_Misc.lua");
	--Map3DSystem.Misc.SaveTableToFile(autotips.tips, "TestTable/tips.ini");
	
	
	--local r1 = Map3DSystem.UI.Profile.AddMyClient("paraengine@paraweb3d.com");
	--local r2 = Map3DSystem.UI.Profile.AddMyServer("lixizhi@paraweb3d.com");
	--if (r1 == true) then Map3DSystem.UI.Profile.AppendMyLog("paraengine@paraweb3d.com added to client"); end
	--if (r2 == true) then Map3DSystem.UI.Profile.AppendMyLog("lixizhi@paraweb3d.com added to server"); end
	
	
	--NPL.load("(gl)script/kids/3DMapSystemUI/Creation/MainMenu.lua");
	--Map3DSystem.UI.Creation.MainMenu.InitUI();
	
	--
	--local clientIP = ParaXML.LuaXML_ParseFile("script/apps/sample/clientIP.xml");
	--
	--NPL.load("(gl)script/kids/3DMapSystem_Misc.lua");
	--Map3DSystem.Misc.SaveTableToFile(clientIP, "TestTable/clientIP.ini");
	
end