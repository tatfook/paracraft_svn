--[[
Title: Main menu UI for 3D Map system
Author(s): WangTian
Date: 2007/8/30
Desc: Show the main menu UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MainMenu.lua");
Map3DSystem.UI.MainMenu.LoadMainMenuUI();
------------------------------------------------------------
]]

--[[ ------ DEPRECATED ------

NPL.activate("(gl)script/kids/ui/Load3DMapSystemUI.lua");
NPL.load("(gl)script/kids/3DMapSystem_Data.lua");
NPL.load("(gl)script/kids/3DMapSystem_Misc.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HeadonPanel.lua");

local L = CommonCtrl.Locale("Kids3DMap");

-------------------------------------
-- main menu UI information
-------------------------------------
-- default asset displayed if the user haven't specify any apperance to the player character
Map3DSystem.UI.MainMenu.DefaultAsset = "character/v1/02animals/01land/luobin/luobin.x";
-- if the selected character in main menu modified, NOTE: temporarily depracated
Map3DSystem.UI.MainMenu.IsCurrentCharacterModified = false;
-- OnClickCharacterIndex, internal user only, solely for OnClickCharacter
Map3DSystem.UI.MainMenu.OnClickCharacterIndex = 0;
-- appearance file name that contains the 10 character appearance information
Map3DSystem.UI.MainMenu.AppearanceFileName = "";
-- radius of the character circle
Map3DSystem.UI.MainMenu.RadiusCharacterCircle = 3.5;
Map3DSystem.UI.MainMenu.CentreCharacterCircle = {255, 0, 255};


-- Function LoadMainMenuUI: load the main menu UI
function Map3DSystem.UI.MainMenu.LoadMainMenuUI()

	-- set appearance information and load all characters for selection
	Map3DSystem.UI.MainMenu.OnPreEnterMainMenu();
	
	-- make Kids3DMap LoginBox invisible
	local _this, _parent;
	_this = ParaUI.GetUIObject("Kids3DMap_LoginBox");
	if(_this:IsValid() == true) then
		_this.visible = false;
	end
	
	-- TODO: check online user (every certain time period)
	-- TODO: check news
	-- TODO: combine the following information to the Map3DSystem.Network.Status table
	local onlineUser = 100;
	local newsNum = 2;
	local newsTable = {};
	newsTable.One = "News one";
	newsTable.Two = "News two";
	
	-- container: news box, Kids3DMap_MainMenuBox_NewsBox
	_this = ParaUI.CreateUIObject("container", "Kids3DMap_MainMenuBox_NewsBox","_rt", -256, 0, 256, 512);
	_this.background = "Texture/3DMapSystem/MainMenu/NewsBox_BG.png";
	_this:AttachToRoot();
	_parent = _this;
	
	_this = ParaUI.CreateUIObject("text", "NewsBox_Textbox_OnlineUser", "_lt", 30, 100, 200, 32)
	_this.text = L"Current Online User:";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("text", "NewsBox_Textbox_OnlineUserCount", "_lt", 130, 100, 100, 32)
	_this.text = ""..onlineUser;
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("text", "NewsBox_Textbox_News", "_lt", 30, 140, 200, 32)
	_this.text = L"News today:";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("text", "NewsBox_Textbox_NewsContent", "_lt", 40, 170, 200, 40*newsNum)
	-- TODO: list all the news in the table
	_this.text = newsTable.One .. "\r\n" .. newsTable.Two;
	_parent:AddChild(_this);
	
	
	-- container: right bottom box, Kids3DMap_MainMenuBox_RightBottomBox
	_this = ParaUI.CreateUIObject("container", "Kids3DMap_MainMenuBox_RightBottomBox","_rb", -256, -256, 256, 256);
	_this.background = "Texture/3DMapSystem/MainMenu/RightBottomBox_BG.png";
	_this:AttachToRoot();
	_parent = _this;
	
	-- button: Save all characters
	_this = ParaUI.CreateUIObject("button", "RightBottomBox_SaveBtn", "_lt", 30, 80, 128, 32);
	_this.background = "Texture/3DMapSystem/MainMenu/RightBottomBox_SaveBtn.png";
	_this.text = L"Save all characters";
	_this.onclick = ";Map3DSystem.UI.MainMenu.OnClickSaveAllCharacters();";
	_parent:AddChild(_this);
	
	-- button: Test1
	_this = ParaUI.CreateUIObject("button", "RightBottomBox_Test1Btn", "_lt", 30, 140, 128, 32)
	_this.text = "Test1";
	_this.onclick = ";Map3DSystem.UI.MainMenu.OnClickTest1();";
	_parent:AddChild(_this);
	
	-- button: Leave main menu
	_this = ParaUI.CreateUIObject("button", "RightBottomBox_Test2Btn", "_lt", 30, 200, 128, 32)
	_this.text = "Leave main menu";
	_this.onclick = ";Map3DSystem.UI.MainMenu.OnLeaveMainMenu();";
	_parent:AddChild(_this);
	
end -- function Map3DSystem.UI.MainMenu.LoadMainMenuUI()

-- ChangeCharacterModelByIndex: change the character base model according to model menu select index
-- Internal use only
function Map3DSystem.UI.MainMenu.ChangeCharacterModelByIndex(index)
	-- get the character object
	local obj = ParaScene.GetObject("Character"..Map3DSystem.UI.MainMenu.OnClickCharacterIndex);
	if(obj~=nil and obj:IsValid()==true) then
		if(obj:IsCharacter()==true) then
			local assetName = kids_db.items[6][index].ModelFilePath;
			local assetNew = ParaAsset.LoadParaX("", assetName);
			-- reset base model according to kids_db.items entry
			obj:ToCharacter():ResetBaseModel(assetNew);
		end
	end
end

-- onclick method of test1 button
function Map3DSystem.UI.MainMenu.OnClickTest1()
	Map3DSystem.UI.HeadonPanel.CloseHeadonPanel();
end

-- called on leave the main menu (before the scene loaded)
function Map3DSystem.UI.MainMenu.OnLeaveMainMenu()
	-- Check if the appearance table been modified
	if( Map3DSystem.UI.MainMenu.IsAppearanceTableModified() ) then
		-- TODO: remind the user to save the appearance information
		-- TODO: if yes, save the information to the appearance file
		-- TODO: if no, use old appearance file information to enter world,
		--		also remind the user it's old appearance character
		-- TODO: synchronize the apperance file
		_guihelper.MessageBox("Appearance Modified, do you wanna save");
	else
		-- TODO: continue
		_guihelper.MessageBox("Not modified");
	end
end

-- Check if the appearance table, Map3DSystem.User.Players.AppearanceInfo, been modified
function Map3DSystem.UI.MainMenu.IsAppearanceTableModified()
	local table1, table2;
	local isEqual;
	NPL.load("(gl)script/kids/3DMapSystem_Misc.lua");
	-- check appearanceInfo table slot [0, 9]
	for i = 0, 9 do
		CCS_db.SaveCharacterCCSInfo("Character"..i);
		table1 = Map3DSystem.User.Players.AppearanceInfo["CharacterSlot"..i];
		table2 = CCS_db.CurrentCharacterInfo;
		isEqual = Map3DSystem.Misc.IsEqualTable(table1, table2);
		if(isEqual == false) then
			return true;
		end
	end
	
	return false;
end

-- Check if the appearance slot, Map3DSystem.User.Players.AppearanceInfo.CharacterSlot[0,9], been modified
function Map3DSystem.UI.MainMenu.IsAppearanceSlotModifiedByIndex(index)
	local table1, table2;
	CCS_db.SaveCharacterCCSInfo("Character"..index);
	table1 = Map3DSystem.User.Players.AppearanceInfo["CharacterSlot"..index];
	table2 = CCS_db.CurrentCharacterInfo;
	NPL.load("(gl)script/kids/3DMapSystem_Misc.lua");
	return Map3DSystem.Misc.IsEqualTable(table1, table2);
end

-- onclick method of the "Save all characters" button
function Map3DSystem.UI.MainMenu.OnClickSaveAllCharacters()
	-- show exclusive message box during saving process, acturally it's very quick
	Map3DSystem.Misc.ShowExclusiveMessageBox( "Please wait during saving progress" );
	-- save the login chracters appearance information
	Map3DSystem.UI.MainMenu.SaveAllLoginCharactersAppearanceInfo();
end

-- onclick method of the "EnterWorld" button
function Map3DSystem.UI.MainMenu.OnClickEnterWorld()
	--Map3DSystem.UI.SwitchToState("MapExplorer");
	NPL.load("(gl)script/kids/3DMapSystemUI/MapExplorer.lua");
	Map3DSystem.UI.MapExplorer.ToggleMapExplorerUI();
end

-- Get the current appearance table according to CurrentSelectedCharacterIndex
function Map3DSystem.UI.MainMenu.GetCurrentAppearanceTable()
	local index = Map3DSystem.Player.CurrentSelectedCharacterIndex;
	if(index ~= nil and index < 10 and index >= 0) then
		if (Map3DSystem.User.Players.AppearanceInfo) then
			return Map3DSystem.User.Players.AppearanceInfo["CharacterSlot"..index];
		end
	end
	return nil;
end

-- onclick method of main menu character
function Map3DSystem.UI.MainMenu.OnClickCharacter()
	Map3DSystem.UI.MainMenu.OnSwitchCharacter(Map3DSystem.UI.MainMenu.OnClickCharacterIndex);
end

-- called on switching characters
function Map3DSystem.UI.MainMenu.OnSwitchCharacter(targetIndex)

	if(Map3DSystem.UI.MainMenu.IsCurrentCharacterModified == true) then
		-- TODO: remind the user to save the character before go on
		-- NOTE: currently this field is depracated
		--		 use function: Map3DSystem.UI.MainMenu.IsAppearanceSlotModifiedByIndex instead
	else
		local isDefault = Map3DSystem.UI.MainMenu.IsDefaultCharacter(targetIndex);
		if(isDefault) then
			-- Remind the user to create a character
			_guihelper.MessageBox("You can create a new character using the modify panel.");
		else
			-- Display CCS modify window
		end
		
	end
	
	
	Map3DSystem.Player.CurrentSelectedCharacterIndex = targetIndex;
	
	
	-- TODO: fix camera problem
	ParaCamera.GetAttributeObject():CallField("FreeCameraMode");
	local target = ParaScene.GetObject("Character"..targetIndex.."_invisible_camera");
	ParaCamera.FollowObject(target);
	ParaCamera.GetAttributeObject():CallField("FollowMode");
	-- show the head on panel according to OnClickCharacterIndex
	Map3DSystem.UI.HeadonPanel.ShowHeadonPanel("Character"..targetIndex);
end

-- check if the indexed character a default character
function Map3DSystem.UI.MainMenu.IsDefaultCharacter(index)
	local t = Map3DSystem.User.Players.AppearanceInfo["CharacterSlot"..index];
	if (t.IsCustomModel == false) then
		if(t.ModelName == "Default") then
			return true;
		end
	end
	return false;
end

-- use in Map3DSystem.UI.MainMenu only
function Map3DSystem.UI.MainMenu.ReadAppearanceInfo(filename)
	local file = ParaIO.open(filename, "r");
	Map3DSystem.User.Players.AppearanceInfo = {};
	local body = file:GetText();
	if(type(body) == "string") then
		if(string.len(body) > 4000) then
			-- very long string stored in main appearance information file
			local indexStart, indexEnd = 2, 2;
			for i = 0, 9 do 
				indexStart = string.find(body, "{", indexEnd);
				entryStart = string.find(body, "\"", indexEnd, indexStart);
				entryEnd = string.find(body, "\"", entryStart+1, indexStart);
				indexEnd = string.find(body, "}", indexEnd+1);
				NPL.DoString("Map3DSystem.User.Players.AppearanceInfo."..string.sub(body, entryStart+1, entryEnd-1).." = "..string.sub(body, indexStart, indexEnd));	
			end
		else
			NPL.DoString("Map3DSystem.User.Players.AppearanceInfo = "..body);
		end
	end
	file:close();
	
	return commonlib.tmptable;
end -- function Map3DSystem.UI.MainMenu.ReadAppearanceInfo(filename)

-- function called before user enter the main menu
function Map3DSystem.UI.MainMenu.OnPreEnterMainMenu()

	-- TODO: get the appearance file name, and synchronize the file with server version
	Map3DSystem.UI.MainMenu.AppearanceFileName = "AppearanceInfo.ini";
	
	-- TODO: wait until the file is synchronized.
	Map3DSystem.UI.MainMenu.LoadAllLoginCharacters();
end

-- load all characters, appearance information 
function Map3DSystem.UI.MainMenu.LoadAllLoginCharacters()
	-- read the main AppearanceInfo table from Map3DSystem.UI.MainMenu.AppearanceFileName
	Map3DSystem.UI.MainMenu.ReadAppearanceInfo("Account/"..Map3DSystem.UI.MainMenu.AppearanceFileName);
	-- load default asset
	local assetDefault = ParaAsset.LoadParaX("", Map3DSystem.UI.MainMenu.DefaultAsset);
	if((assetDefault == nil) or (assetDefault:IsValid() == false))then
		log("Default character model does not exist:\r\n");
		return;
	end
	-- initial values
	local radiusCharacterCircle = Map3DSystem.UI.MainMenu.RadiusCharacterCircle;
	local x = Map3DSystem.UI.MainMenu.CentreCharacterCircle[1];
	local y = Map3DSystem.UI.MainMenu.CentreCharacterCircle[2];
	local z = Map3DSystem.UI.MainMenu.CentreCharacterCircle[3];
	local dX, dZ = 0 , 0;
	local facing = -2.198;
	
	for i = 0, 9 do
		-- create the characters
		obj = ParaScene.CreateCharacter("Character"..i, assetDefault, "", true, 0.35, 0.0, 1.0);
		obj:SetPersistent(true);
		dX = radiusCharacterCircle*math.sin(0.628*i);
		dZ = radiusCharacterCircle*math.cos(0.628*i);
		obj:SetPosition(x + dX, 0, z + dZ);
		facing = facing + 0.628;
		obj:SetFacing(facing);
		ParaScene.Attach(obj);
		obj.onclick = ";Map3DSystem.UI.MainMenu.OnClickCharacterIndex = "..i..";Map3DSystem.UI.MainMenu.OnClickCharacter();";
	end
	
	
	CCS_db.CurrentCharacterInfo =Map3DSystem.Misc.CopyTable(Map3DSystem.User.Players.AppearanceInfo.CharacterSlot0);
	CCS_db.LoadCharacterCCSInfo("Character0");
	CCS_db.CurrentCharacterInfo =Map3DSystem.Misc.CopyTable(Map3DSystem.User.Players.AppearanceInfo.CharacterSlot1);
	CCS_db.LoadCharacterCCSInfo("Character1");
	CCS_db.CurrentCharacterInfo =Map3DSystem.Misc.CopyTable(Map3DSystem.User.Players.AppearanceInfo.CharacterSlot2);
	CCS_db.LoadCharacterCCSInfo("Character2");
	CCS_db.CurrentCharacterInfo =Map3DSystem.Misc.CopyTable(Map3DSystem.User.Players.AppearanceInfo.CharacterSlot3);
	CCS_db.LoadCharacterCCSInfo("Character3");
	CCS_db.CurrentCharacterInfo =Map3DSystem.Misc.CopyTable(Map3DSystem.User.Players.AppearanceInfo.CharacterSlot4);
	CCS_db.LoadCharacterCCSInfo("Character4");
	CCS_db.CurrentCharacterInfo =Map3DSystem.Misc.CopyTable(Map3DSystem.User.Players.AppearanceInfo.CharacterSlot5);
	CCS_db.LoadCharacterCCSInfo("Character5");
	CCS_db.CurrentCharacterInfo =Map3DSystem.Misc.CopyTable(Map3DSystem.User.Players.AppearanceInfo.CharacterSlot6);
	CCS_db.LoadCharacterCCSInfo("Character6");
	CCS_db.CurrentCharacterInfo =Map3DSystem.Misc.CopyTable(Map3DSystem.User.Players.AppearanceInfo.CharacterSlot7);
	CCS_db.LoadCharacterCCSInfo("Character7");
	CCS_db.CurrentCharacterInfo =Map3DSystem.Misc.CopyTable(Map3DSystem.User.Players.AppearanceInfo.CharacterSlot8);
	CCS_db.LoadCharacterCCSInfo("Character8");
	CCS_db.CurrentCharacterInfo =Map3DSystem.Misc.CopyTable(Map3DSystem.User.Players.AppearanceInfo.CharacterSlot9);
	CCS_db.LoadCharacterCCSInfo("Character9");
	
	local radiusCameraCircle = 4.0;
	
	facing = -2.198 + 3.14;
	
	for i = 0, 9 do
		obj = ParaScene.CreateCharacter("Character"..i.."_invisible_camera", "", "", true, 0.05, 3.9, 1.0);
		obj:GetAttributeObject():SetField("SentientField", 0);--senses nobody
		obj:SetDensity(10);
		dX = radiusCharacterCircle*math.sin(0.628*i);
		dZ = radiusCharacterCircle*math.cos(0.628*i);
		obj:SetPosition(x + dX, 0, z + dZ);
		facing = facing + 0.628;
		obj:SetFacing(facing);
		ParaScene.Attach(obj);
	end
	
	--TODO: fix camera problem
	Map3DSystem.Player.CurrentSelectedCharacterIndex = 0;
	Map3DSystem.UI.MainMenu.OnClickCharacter();
end


function Map3DSystem.UI.MainMenu.SaveAllLoginCharactersAppearanceInfo()

	CCS_db.SaveCharacterCCSInfo("Character0");
	Map3DSystem.User.Players.AppearanceInfo.CharacterSlot0 = Map3DSystem.Misc.CopyTable(CCS_db.CurrentCharacterInfo);
	CCS_db.SaveCharacterCCSInfo("Character1");
	Map3DSystem.User.Players.AppearanceInfo.CharacterSlot1 = Map3DSystem.Misc.CopyTable(CCS_db.CurrentCharacterInfo);
	CCS_db.SaveCharacterCCSInfo("Character2");
	Map3DSystem.User.Players.AppearanceInfo.CharacterSlot2 = Map3DSystem.Misc.CopyTable(CCS_db.CurrentCharacterInfo);
	CCS_db.SaveCharacterCCSInfo("Character3");
	Map3DSystem.User.Players.AppearanceInfo.CharacterSlot3 = Map3DSystem.Misc.CopyTable(CCS_db.CurrentCharacterInfo);
	CCS_db.SaveCharacterCCSInfo("Character4");
	Map3DSystem.User.Players.AppearanceInfo.CharacterSlot4 = Map3DSystem.Misc.CopyTable(CCS_db.CurrentCharacterInfo);
	CCS_db.SaveCharacterCCSInfo("Character5");
	Map3DSystem.User.Players.AppearanceInfo.CharacterSlot5 = Map3DSystem.Misc.CopyTable(CCS_db.CurrentCharacterInfo);
	CCS_db.SaveCharacterCCSInfo("Character6");
	Map3DSystem.User.Players.AppearanceInfo.CharacterSlot6 = Map3DSystem.Misc.CopyTable(CCS_db.CurrentCharacterInfo);
	CCS_db.SaveCharacterCCSInfo("Character7");
	Map3DSystem.User.Players.AppearanceInfo.CharacterSlot7 = Map3DSystem.Misc.CopyTable(CCS_db.CurrentCharacterInfo);
	CCS_db.SaveCharacterCCSInfo("Character8");
	Map3DSystem.User.Players.AppearanceInfo.CharacterSlot8 = Map3DSystem.Misc.CopyTable(CCS_db.CurrentCharacterInfo);
	CCS_db.SaveCharacterCCSInfo("Character9");
	Map3DSystem.User.Players.AppearanceInfo.CharacterSlot9 = Map3DSystem.Misc.CopyTable(CCS_db.CurrentCharacterInfo);
	
	NPL.load("(gl)script/kids/3DMapSystem_Misc.lua");
	if(Map3DSystem.UI.MainMenu.AppearanceFileName ~= nil) then
		--TODO: get appearance file name
		Map3DSystem.Misc.SaveTableToFile(Map3DSystem.User.Players.AppearanceInfo, "Account/"..Map3DSystem.UI.MainMenu.AppearanceFileName);
		--TODO: synchronize appearance file with server version
	else
		Map3DSystem.Misc.SaveTableToFile(Map3DSystem.User.Players.AppearanceInfo, "Account/"..Map3DSystem.UI.MainMenu.AppearanceFileName);
		--TODO: synchronize appearance file with server version
	end
	
	--ParaUI.Destroy("Map3D_MainMenu_Save_WaitingBox");
	Map3DSystem.Misc.DestroyExclusiveMessageBox( )
end

]] ------ DEPRECATED ------