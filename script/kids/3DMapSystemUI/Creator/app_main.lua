--[[
Title: Creator app for Paraworld
Author(s): Andy, LiXizhi
Date: 2008/1/5, revised 2008.6.15 LiXizhi
Desc: 
---++ Creation.CreateObject
   * Map3DSystem.App.Commands.Call("Creation.NormalModel", objParams);
	where objParams is the object parameters to be created. for more information, please see object_editor
---++ Creator.NormalModel
show the creator panel for this category of object
   * Map3DSystem.App.Commands.Call("Creation.NormalModel");
---++ Creator.NormalCharacter
show the creator panel for this category of object
   * Map3DSystem.App.Commands.Call("Creation.NormalCharacter");
---++ Creator.BuildingComponents
show the creator panel for this category of object
   * Map3DSystem.App.Commands.Call("Creation.BuildingComponents");
---++ Creation.UpdatePanels
	whenever the selection changed, we need to call following command to update panels.
   * Map3DSystem.App.Commands.Call("Creation.UpdatePanels");
---++ Creation.ShowOBB
	show or hide the object bounding box. if params is nil, it will toggle display
   * Map3DSystem.App.Commands.Call("Creation.ShowOBB", true);
---++ Creation.ShowReport
	show or hide the graphics report. if params is nil, it will toggle display
   * Map3DSystem.App.Commands.Call("Creation.ShowReport", true);	
---++ modify page
show or hide the modify panel. Modify panel is valid for both character and static model. And they share the same mcml page.
   * show the modify panel: Map3DSystem.App.Commands.Call("Creation.Modify");
   * hide the modify panel: Map3DSystem.App.Commands.Call("Creation.Modify", {bShow=false});

---++ property page
Each scene object may have zero or several property pages, depending on the type of the scene object and applications installed.  
Normal character has CharPropertyPage defined in CreatorApp. It can be invoked by 
   * Map3DSystem.App.Commands.Call("Creation.CharProperty");
Object with replaceable textures(r2) has ObjTexPropertyPage defined in CreatorApp. It can be invoked by 
   * Map3DSystem.App.Commands.Call("Creation.ObjTexProperty");

To automatically invoke the appropriate property or modify page(whichever is important) of the currently selected or context menu object. Call below.
   * Map3DSystem.App.Commands.Call("Creation.DefaultProperty");	-- for selected object
   * Map3DSystem.App.Commands.Call("Creation.DefaultProperty", {target="contextmenu"}); -- for context menu object
   * Map3DSystem.App.Commands.Call("Creation.DefaultProperty", {target=""}); -- hide all property page
Above function can be invoked by other applications, since it does not rely on any scene object hook. 

db registration insert script
INSERT INTO apps VALUES (NULL, 'Creator_GUID', 'Creator', '1.0.0', 'http://www.paraengine.com/apps/Creator_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/Creator/IP.xml', '', 'script/kids/3DMapSystemUI/Creator/app_main.lua', 'Creator.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/app_main.lua");
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("ParaWorld");


-- requires

-- create class
local Creator = {};
commonlib.setfield("Map3DSystem.App.Creator", Creator);


-- "selection" or "contextmenu". where to get the object in concern. 	
-- i.e. local obj = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target);
Creator.target = "selection";

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Creator.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		local commandName = "Creation.NormalModel";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, ButtonText = L"模型", icon = "Texture/3DMapSystem/Creator/Level1_NM.png", 
				app_key = app.app_key,});
		end
		
		local commandName = "Creation.NormalCharacter";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, ButtonText = L"人物", icon = "Texture/3DMapSystem/Creator/Level1_NC.png", 
				app_key = app.app_key,});
		end
		
		local commandName = "Creation.BuildingComponents";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, ButtonText = L"部件", icon = "Texture/3DMapSystem/Creator/Level1_BCS.png", 
				app_key = app.app_key,});
		end
		
		local commandName = "Creation.ObjectEditor";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, ButtonText = "物体编辑", icon = "Texture/3DMapSystem/Creator/Objects/Object_Edit.png", 
				app_key = app.app_key,});
		end
		local commandName = "Creation.ModifyByPickObj";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, ButtonText = L"修改属性", icon = "Texture/3DMapSystem/common/wand.png", 
				app_key = app.app_key,});
		end
		local commandName = "Creation.Modify";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, ButtonText = L"编辑面板", icon = "Texture/3DMapSystem/common/wand.png", 
				app_key = app.app_key,});
		end
		
		local commandName = "Creation.CharProperty";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, ButtonText = L"人物属性", icon = "Texture/3DMapSystem/common/color_swatch.png", 
				app_key = app.app_key,});
		end
		
		local commandName = "Creation.ObjTexProperty";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, ButtonText = L"贴图属性", icon = "Texture/3DMapSystem/common/color_swatch.png", 
				app_key = app.app_key,});
		end
		
		local commandName = "Creation.DefaultProperty";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, ButtonText = L"属性", icon = "Texture/3DMapSystem/common/color_swatch.png", 
				app_key = app.app_key,});
		end
		
		local commandName = "Creation.UpdatePanels";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, 
				app_key = app.app_key,});
		end
		
		local commandName = "Creation.PortalSystem";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, ButtonText = "Portal System", icon="Texture/3DMapSystem/Creator/Level1_NM.png",
				app_key = app.app_key,});
		end
		
	else
		Creator.app = app; -- keep a reference
		
		app.icon =  "Texture/3DMapSystem/AppIcons/painter_64.dds";
		app.Title = L"创造";
		app.SubTitle = L"创造3D世界的工具集";
		
		app.about =  "creator world function set."
		app.HomeButtonText = L"创造工具集";
		app:SetHelpPage("WelcomePage.html");
		app.HideHomeButton = true;
		
		local commandName = "Creation.CreateObject";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key,});
		end
		
		local commandName = "Creation.ShowOBB";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, ButtonText = "显示/隐藏包围盒", icon="Texture/3DMapSystem/common/bricks.png",
				app_key = app.app_key,});
		end
		
		local commandName = "Creation.ShowReport";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, ButtonText = "显示/隐藏图形报告", icon="Texture/3DMapSystem/common/chart_line.png",
				app_key = app.app_key,});
		end
	end
end

-- Receives notification that the Add-in is being unloaded.
function Creator.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("Profile.Creator");
		if(command == nil) then
			command:Delete();
		end
	end
end

-- This is called when the command's availability is updated
-- When the user clicks a command (menu or mainbar button), the QueryStatus event is fired. 
-- The QueryStatus event returns the current status of the specified named command, whether it is enabled, disabled, 
-- or hidden in the CommandStatus parameter, which is passed to the msg by reference (or returned in the event handler). 
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
-- @param statusWanted: what status of the command is queried. it is of type Map3DSystem.App.CommandStatusWanted
-- @return: returns according to statusWanted. it may return an integer by adding values in Map3DSystem.App.CommandStatus.
function Creator.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Creator.OnExec(app, commandName, params)
	if(commandName == "Creation.CreateObject") then
		if(not params) then return end
		local obj_params = params;
		-- create the item according to the params
		local isRandomFacing = false;
		local isRandomSize = false;
		local player = ParaScene.GetPlayer();
			
		-- position
		if(not obj_params.x)then
			local x,y,z= player:GetPosition();
			obj_params.x = x;
			obj_params.y = y;
			obj_params.z = z;
		end
		if(not obj_params.facing and obj_params.IsCharacter)then
			obj_params.facing = player:GetFacing();
		end
		
		-- apply random facing
		if(isRandomFacing == true) then
			local lastFacing = Creator.LastRandomFacing or 0;
			local thisFacing = ParaGlobal.random() * 6.28;
			
			while math.abs(lastFacing - thisFacing) < 1.57 or math.abs(lastFacing - thisFacing) > 4.71 do
				thisFacing = ParaGlobal.random() * 6.28;
			end
			obj_params.facing = thisFacing;
			Creator.LastRandomFacing = thisFacing;
		end
			
		if(not obj_params.IsCharacter) then
			if(Map3DSystem.UI.Creator.isBCSActive == true) then
				-- BCS components
				Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params=obj_params});
			else
				Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CopyObject, obj_params = obj_params});
			end
		elseif(obj_params.IsCharacter == true) then
			-- create object by sending a message
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params=obj_params});
		end
		
		if(obj_params.IsCharacter) then
			-- play "CreateCharacter" animation
			Map3DSystem.Animation.SendMeMessage({
					type = Map3DSystem.msg.ANIMATION_Character,
					obj_params = nil, --  <player>
					animationName = "CreateCharacter",
					});
			-- play "CharacterBorn" animation
			Map3DSystem.Animation.SendMeMessage({
					type = Map3DSystem.msg.ANIMATION_Character,
					obj_params = Map3DSystem.obj.GetObjectParams("lastcreated"), -- newly create object
					animationName = "CharacterBorn",
					});
		else
			-- play "RaiseTerrain" animation
			Map3DSystem.Animation.SendMeMessage({
					type = Map3DSystem.msg.ANIMATION_Character,
					obj_params = nil, --  <player>
					animationName = "RaiseTerrain",
					});
		end		
	elseif(commandName == "Creation.NormalModel") then
		-- show the Creator main window, and switch to Normal Model category
		if(type(params)=="table" and params.bShow== false) then
			if(commonlib.getfield("Map3DSystem.UI.Creator.ShowMainWnd")) then
				Map3DSystem.UI.Creator.ShowMainWnd(false);
			end	
			return 
		end
		NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Main.lua");
		
		Map3DSystem.UI.Creator.ShowMainWnd(true);
		local ctl = CommonCtrl.GetControl("CreationTabGrid");
		if(ctl ~= nil) then
			ctl:SetLevelIndex(1, 1);
		end
		Map3DSystem.UI.Creator.SwitchCategory(1);
		--local command = Map3DSystem.App.Commands.GetCommand(commandName);
		--local _app = Map3DSystem.App.Creator.app._app;
		--local _wnd = _app:FindWindow("MainWnd")
		--local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
		--if(frame ~= nil) then
			--frame:SetIcon(command.icon);
			--frame:SetText(command.ButtonText);
		--end
		
	elseif(commandName == "Creation.NormalCharacter") then
		-- show the Creator main window, and switch to Normal Character category
		if(type(params)=="table" and params.bShow== false) then
			if(commonlib.getfield("Map3DSystem.UI.Creator.ShowMainWnd")) then
				Map3DSystem.UI.Creator.ShowMainWnd(false);
			end	
			return 
		end
		NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Main.lua");
		Map3DSystem.UI.Creator.ShowMainWnd(true);
		local ctl = CommonCtrl.GetControl("CreationTabGrid");
		if(ctl ~= nil) then
			ctl:SetLevelIndex(3, 1);
		end
		Map3DSystem.UI.Creator.SwitchCategory(3);
		
		--local command = Map3DSystem.App.Commands.GetCommand(commandName);
		--local _app = Map3DSystem.App.Creator.app._app;
		--local _wnd = _app:FindWindow("MainWnd")
		--local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
		--if(frame ~= nil) then
			--frame:SetIcon(command.icon);
			--frame:SetText(command.ButtonText);
		--end
		
	elseif(commandName == "Creation.BuildingComponents") then
		-- show the Creator main window, and switch to BCS category
		if(type(params)=="table" and params.bShow== false) then
			if(commonlib.getfield("Map3DSystem.UI.Creator.ShowMainWnd")) then
				Map3DSystem.UI.Creator.ShowMainWnd(false);
			end	
			return 
		end
		NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Main.lua");
		Map3DSystem.UI.Creator.ShowMainWnd(true);
		local ctl = CommonCtrl.GetControl("CreationTabGrid");
		if(ctl ~= nil) then
			ctl:SetLevelIndex(2, 1);
		end
		Map3DSystem.UI.Creator.SwitchCategory(2);
		
		--local command = Map3DSystem.App.Commands.GetCommand(commandName);
		--local _app = Map3DSystem.App.Creator.app._app;
		--local _wnd = _app:FindWindow("MainWnd")
		--local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
		--if(frame ~= nil) then
			--frame:SetIcon(command.icon);
			--frame:SetText(command.ButtonText);
		--end
	elseif(commandName == "Creation.UpdatePanels") then	
		local _app = app._app;
		if(_app) then
			--local bVisible_ObjModifyPage
			--local bVisible_CharPropertyPage
			--local bVisible_ObjTexProperty
			--local selectObj;
			--if(Creator.target~="") then
				--selectObj = Map3DSystem.obj.GetObject(Creator.target);
			--end	
			--
			--if(selectObj ~= nil and selectObj:IsValid()) then
				--if(selectObj:IsCharacter()) then
					--Map3DSystem.App.Commands.Call("Creation.ObjTexProperty", {bShow=false})
				--else
					--Map3DSystem.App.Commands.Call("Creation.CharProperty", {bShow=false})
				--end
			--else
				---- close all panels if no object is selected. 
				--Map3DSystem.App.Commands.Call("Creation.Modify", {bShow=false})
				--Map3DSystem.App.Commands.Call("Creation.CharProperty", {bShow=false})
				--Map3DSystem.App.Commands.Call("Creation.ObjTexProperty", {bShow=false})
			--end
	
			local _wnd = _app:FindWindow("ObjModifyPage");
			if(_wnd and _wnd:IsVisible()) then
				Creator.ObjModifyPage.UpdatePanelUI();
			end
			local _wnd = _app:FindWindow("CharPropertyPage");
			if(_wnd and _wnd:IsVisible()) then
				Creator.CharPropertyPage.UpdatePanelUI();
			end
			local _wnd = _app:FindWindow("ObjTexProperty");
			if(_wnd and _wnd:IsVisible()) then
				Creator.ObjTexProperty.UpdatePanelUI();
			end
		end	
	elseif(commandName == "Creation.ObjectEditor") then	
		-- show or hide ObjModifyPage
		-- call below to show the window
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Creator/Objects/ObjectsPage.html", name="ObjectsEditor", 
			app_key = app.app_key, 
			isShowTitleBar = true, 
			allowDrag = true,
			bToggleShowHide = true,
			icon = "Texture/3DMapSystem/Creator/Objects/Object_Edit.png",
			text = "物体编辑器",
			initialWidth = 220, -- initial width of the window client area
			initialHeight = 440, -- initial height of the window client area
			directPosition = true,
				align = "_rb",
				x = -220,
				y = -544,
				width = 220,
				height = 464,
			opacity = 90,
		});
		
	elseif(commandName == "Creation.ModifyByPickObj") then
		local obj = ParaScene.MousePick(40, "4294967295");	
		if(obj and obj:IsValid())then
			commonlib.echo("=============aaa");
			Map3DSystem.obj.SetObject(obj)
			Map3DSystem.App.Commands.Call("Creation.DefaultProperty", {target = nil});
		end
	elseif(commandName == "Creation.Modify") then
		-- show or hide ObjModifyPage
		NPL.load("(gl)script/kids/3DMapSystemUI/Creator/ObjModifyPage.lua");
		if(params and params.bShow==false) then
			-- hide the window
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="ObjModifyPage", app_key = app.app_key, bShow = false,});
		else
			-- call below to show the window
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				url="script/kids/3DMapSystemUI/Creator/ObjModifyPage.html", name="ObjModifyPage", 
				app_key = app.app_key, 
				isShowTitleBar = true, 
				isShowMinimizeBox = false,
				allowDrag = true,
				opacity = 90,
				initialPosX = 0, 
				initialPosY = 0, 
				initialWidth = 200, 
				initialHeight = 400,
				icon = "Texture/3DMapSystem/common/wand.png",
				text = L"编辑",
			});
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				name="ObjTexPropertyPage", app_key = app.app_key, bShow = false});
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				name="CharPropertyPage", app_key = app.app_key, bShow = false});
		end	
		Creator.ObjModifyPage.UpdatePanelUI();
	elseif(commandName == "Creation.CharProperty") then
		-- show or hide ObjModifyPage
		NPL.load("(gl)script/kids/3DMapSystemUI/Creator/CharPropertyPage.lua");
		if(params and params.bShow==false) then
			-- hide the window
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="CharPropertyPage", app_key = app.app_key, bShow = false,});
		else
			-- call below to show the window
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				url="script/kids/3DMapSystemUI/Creator/CharPropertyPage.html", name="CharPropertyPage", 
				app_key = app.app_key, 
				isShowTitleBar = true, 
				isShowMinimizeBox = false,
				allowDrag = true,
				opacity = 90,
				initialPosX = 0, 
				initialPosY = 0, 
				initialWidth = 200, 
				initialHeight = 400,
				icon = "Texture/3DMapSystem/common/color_swatch.png",
				text = L"属性",
			});
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				name="ObjModifyPage", app_key = app.app_key, bShow = false});
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				name="ObjTexPropertyPage", app_key = app.app_key, bShow = false});
		end	
		Creator.CharPropertyPage.UpdatePanelUI();
	elseif(commandName == "Creation.ObjTexProperty") then
		-- show or hide ObjTexPropertyPage
		NPL.load("(gl)script/kids/3DMapSystemUI/Creator/ObjTexPropertyPage.lua");
		if(params and params.bShow==false) then
			-- hide the window
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="ObjTexPropertyPage", app_key = app.app_key, bShow = false,});
		else
			-- call below to show the window
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				url="script/kids/3DMapSystemUI/Creator/ObjTexPropertyPage.html", name="ObjTexPropertyPage", 
				app_key = app.app_key, 
				isShowTitleBar = true, 
				isShowMinimizeBox = false,
				allowDrag = true,
				opacity = 90,
				initialPosX = 0, 
				initialPosY = 0, 
				initialWidth = 200, 
				initialHeight = 400,
				icon = "Texture/3DMapSystem/common/color_swatch.png",
				text = L"属性",
			});
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				name="ObjModifyPage", app_key = app.app_key, bShow = false});
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				name="CharPropertyPage", app_key = app.app_key, bShow = false});
		end	
		Creator.ObjTexPropertyPage.UpdatePanelUI();	
	elseif(commandName == "Creation.DefaultProperty") then
		-- show the default page for the target object. where params.target must be "selection" or "contextmenu"
		local target;
		if(params) then
			target = params.target;
		end
		Creator.ShowDefaultObjectPage(target)
	elseif(commandName == "Creation.PortalSystem") then	
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Creator/PortalSystemPage.html", 
			name="PortalSystemPage", 
			icon="Texture/3DMapSystem/Creator/Level1_NM.png",
			app_key = app.app_key, 
			isShowTitleBar = true, 
			allowDrag = true,
			initialPosX = 0, 
			initialPosY = 0, 
			initialWidth = 320, 
			initialHeight = 450,
			text = "Portal System",
			DestroyOnClose = true,
		});
		--Map3DSystem.App.Creator.PortalSystemPage.BuildCanvas()
	elseif(commandName == "Creation.ShowReport") then	
		if(params==nil) then
			ParaScene.GetAttributeObject():SetField("GenerateReport", not ParaScene.GetAttributeObject():GetField("GenerateReport", false));
		elseif(type(params)=="boolean")then
			ParaScene.GetAttributeObject():SetField("GenerateReport", params);
		end
	elseif(commandName == "Creation.ShowOBB") then	
		if(params==nil) then
			ParaScene.GetAttributeObject():SetField("ShowBoundingBox", not ParaScene.GetAttributeObject():GetField("ShowBoundingBox", false));
		elseif(type(params)=="boolean")then
			ParaScene.GetAttributeObject():SetField("ShowBoundingBox", params);
		end
	elseif(app:IsHomepageCommand(commandName)) then
		Creator.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Creator.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Creator.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Creator.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Creator.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Creator.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Creator.DoQuickAction()
end

function Creator.OnActivateDesktop()
	Map3DSystem.UI.AppTaskBar.AddCommand("Creation.NormalModel");
	Map3DSystem.UI.AppTaskBar.AddCommand("Creation.NormalCharacter");
	Map3DSystem.UI.AppTaskBar.AddCommand("Creation.BuildingComponents")--:Call();
	Map3DSystem.UI.AppTaskBar.AddCommand("Creation.Modify");
	Map3DSystem.UI.AppTaskBar.AddCommand("Env.sky");
	Map3DSystem.UI.AppTaskBar.AddCommand("Env.terrain");
	Map3DSystem.UI.AppTaskBar.AddCommand("Env.ocean")
	if(System.options.IsEditorMode) then
		Map3DSystem.UI.AppTaskBar.AddCommand("Creation.ObjectEditor");
	end
	--Map3DSystem.UI.AppTaskBar.AddCommand("Creation.DefaultProperty");
	
	autotips.AddIdleTips(L"这里你可以创造出植物, 动物, 建筑物, 交通工具等")
	autotips.AddIdleTips(L"用建筑部件盖一层或多层的房子: 请先建地基")
	autotips.AddIdleTips(L"在你盖房子前, 可以先将地表铲平")
	autotips.AddIdleTips(L"按Esc键取消选择")
	autotips.AddIdleTips(L"你可以在画板类的物体上涂鸦, 点击这类物体时,左侧会出现画板")
	autotips.AddIdleTips(L"点击物体, 然后点击平移, 可以将物体移到当前人物的脚下")
	autotips.AddIdleTips(L"你可以赋予人物各种角色, 请创建并点击人物")
	autotips.AddIdleTips(L"你可以改变部分动物的皮肤颜色, 比如黑猫, 白猫")
	autotips.AddIdleTips(L"鼠标右键点击物体, 察看属性")
	autotips.AddIdleTips(L"请经常保存您的世界")
	
	Map3DSystem.App.Commands.Call("File.WelcomePage", {url="script/kids/3DMapSystemUI/Creator/WelcomePage.html"})
		
	-- change desktop mode
	Map3DSystem.UI.AppDesktop.ChangeMode("edit")
	
	-- hook into the "object" and update the modify panel
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = Creator.Hook_SceneObjectSelected, 
		hookName = "CreatorSelectionHook", appName = "scene", wndName = "object"});
	
	-- hook into the "onsize" and update the main window
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = Creator.Hook_ScreenSizeChanged, 
		hookName = "CreatorOnSizeHook", appName = "input", wndName = "onsize"});
end

function Creator.Hook_ScreenSizeChanged(nCode, appName, msg)
	Map3DSystem.UI.Creator.OnSize(msg.width, msg.height);
	return nCode
end

-- "scene" object window hook. we will show object page accordingly. 
function Creator.Hook_SceneObjectSelected(nCode, appName, msg)
	
	if(msg.type == Map3DSystem.msg.OBJ_DeselectObject or msg.type == Map3DSystem.msg.OBJ_DeleteObject) then
		-- hide modify panel whenever object deselected or deleted
		Creator.ShowDefaultObjectPage("");
		
		Map3DSystem.UI.Creator.Hook_ObjectSelection(nCode, appName, msg)
		
	elseif(msg.type == Map3DSystem.msg.OBJ_SelectObject) then
		-- show modify or property panel (whichever is more important) whenever object selected
		Creator.ShowDefaultObjectPage("selection");
		
		Map3DSystem.UI.Creator.Hook_ObjectSelection(nCode, appName, msg)
	end	
	return nCode
end

-- show modify or property panel, whichever is more important to the currently selected object
-- @param target: nil or "" or "selection" or "contextmenu".  if nil, it default to "selection". It specifies where to get the object in concern. 
-- if "", all panels are hidden. 
function Creator.ShowDefaultObjectPage(target)
	-- change target. 
	Creator.target = target or "selection"
	local selectObj;
	if(Creator.target~="") then
		selectObj = Map3DSystem.obj.GetObject(Creator.target);
		log("no target found\n")
	end	
	
	if(selectObj ~= nil and selectObj:IsValid()) then
		if(selectObj:IsCharacter()) then
			local player = ParaScene.GetPlayer();
			if(player:equals(selectObj) == true) then
				-- show ObjModifyPage if current player is selected. 
				Map3DSystem.App.Commands.Call("Creation.Modify");
			else
				-- show CharPropertyPage if none-player is selected. 
				Map3DSystem.App.Commands.Call("Creation.CharProperty");
			end
		else -- model
			if(selectObj:GetNumReplaceableTextures() > 0) then
				-- show ObjModifyPage as well
				Map3DSystem.App.Commands.Call("Creation.Modify");
				-- show ObjTexPropertyPage if model with replaceable texture (r2) is selected. 
				Map3DSystem.App.Commands.Call("Creation.ObjTexProperty");
			else
				-- show ObjModifyPage if model without replaceable texture is selected. 
				Map3DSystem.App.Commands.Call("Creation.Modify");
			end
		end
	else
		-- close all panels if no object is selected. 
		Map3DSystem.App.Commands.Call("Creation.Modify", {bShow=false})
		Map3DSystem.App.Commands.Call("Creation.CharProperty", {bShow=false})
		Map3DSystem.App.Commands.Call("Creation.ObjTexProperty", {bShow=false})
	end
end

function Creator.OnDeactivateDesktop()
	NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Main.lua");
	Map3DSystem.UI.Creator.OnDeactivate();
	-- unhook from the "object"
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "CreatorSelectionHook", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET})
	-- unhook from the "onsize"
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "CreatorOnSizeHook", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET})
end

-- called whenever a world is being closed.
function Creator.OnWorldClosed()
	NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Main.lua");
	Map3DSystem.UI.Creator.DestroyMainWnd();
end

-------------------------------------------
-- client world database function helpers.
-------------------------------------------

------------------------------------------
-- all related messages
------------------------------------------
-----------------------------------------------------
-- APPS can be invoked in many ways: 
--	Through app Manager 
--	mainbar or menu command or buttons
--	Command Line 
--  3D World installed apps
-----------------------------------------------------
function Creator.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Creator.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Creator.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Creator.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Creator.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Creator.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Creator.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Creator.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Creator.DoQuickAction();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_ACTIVATE_DESKTOP) then
		Creator.OnActivateDesktop();
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DEACTIVATE_DESKTOP) then
		Creator.OnDeactivateDesktop();
		Map3DSystem.App.Commands.Call("Profile.Inventor.Stop");
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_WORLD_CLOSING) then
		-- called whenever a world is being closed.
		Creator.OnWorldClosed();
	

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end