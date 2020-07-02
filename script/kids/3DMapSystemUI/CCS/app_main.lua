--[[
Title: Character custimization system (avatar info) app for Paraworld
Author(s): LiXizhi
Date: 2008/2/14
Desc: Editing character appearances. Managing the default avatar appearance for a user

---++ Profile.CCS.AnimationPage
Play a predefined animation file or its index.
<verbatim>
	-- ShortCutIndex is the index of the animation, usually 1-9. 
	Map3DSystem.App.Commands.Call("Profile.CCS.AnimationPage", {ShortCutIndex = keyNumber})
</verbatim>

---++ character facing target
set the facing of the character to the target
<verbatim>
	Map3DSystem.App.CCS.CharacterFaceTarget(ParaScene.GetPlayer(), x,y,z);
</verbatim>
db registration insert script
INSERT INTO apps VALUES (NULL, 'CCS_GUID', 'CCS', '1.0.0', 'http://www.paraengine.com/apps/CCS_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/CCS/IP.xml', '', 'script/kids/3DMapSystemUI/CCS/app_main.lua', 'Map3DSystem.App.CCS.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/app_main.lua");
------------------------------------------------------------
]]

-- requires

-- create class
commonlib.setfield("Map3DSystem.App.CCS", {});

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.CCS.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a CCS command link in the main menu 
		local commandName = "Profile.MyAvatar";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "我的形象", });
		end
		
		---- e.g. Create a CCS command link in the main menu 
		--local commandName = "Profile.CCS.Facial";
		--local command = Map3DSystem.App.Commands.GetCommand(commandName);
		--if(command == nil) then
			--command = Map3DSystem.App.Commands.AddNamedCommand(
				--{name = commandName,app_key = app.app_key, ButtonText = "卡通脸", 
				--icon = "Texture/3DMapSystem/CCS/Level1_Facial.png", });
			---- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			--local pos_category = commandName;
			---- add to front.
			--command:AddControl("mainmenu", pos_category, 1);
		--end
		--
		---- e.g. Create a CCS command link in the main menu 
		--local commandName = "Profile.CCS.Inventory";
		--local command = Map3DSystem.App.Commands.GetCommand(commandName);
		--if(command == nil) then
			--command = Map3DSystem.App.Commands.AddNamedCommand(
				--{name = commandName,app_key = app.app_key, ButtonText = "装备", 
				--icon = "Texture/3DMapSystem/CCS/Level1_Inventory.png", });
			---- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			--local pos_category = commandName;
			---- add to front.
			--command:AddControl("mainmenu", pos_category, 1);
		--end
		
		-- e.g. Create a CCS command link in the main menu 
		--local commandName = "Profile.CCS.Modify";
		--local command = Map3DSystem.App.Commands.GetCommand(commandName);
		--if(command == nil) then
			--command = Map3DSystem.App.Commands.AddNamedCommand(
				--{name = commandName,app_key = app.app_key, ButtonText = "人物编辑", 
				--icon = "Texture/3DMapSystem/common/color_swatch.png", });
		--end
		
		-- CCS panel command link
		local commandName = "Profile.CCS.FacialPanel";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "面部和皮肤", 
				icon = "Texture/3DMapSystem/CCS/Level1_Facial.png", });
		end
		
		local commandName = "Profile.CCS.CartoonFacePanel";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "卡通脸", 
				icon = "Texture/3DMapSystem/CCS/Level1_CartoonFace.png", });
		end
		
		local commandName = "Profile.CCS.InventoryPanel";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "服装", 
				icon = "Texture/3DMapSystem/CCS/Level1_Inventory.png", });
		end
		
		local commandName = "Profile.CCS.HairPanel";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "头发面板", 
				icon = "Texture/3DMapSystem/CCS/Level1_Hair.png", });
		end
		
		
		-- e.g. Create a CharSelectionPage command link in the main menu 
		local commandName = "Profile.CCS.CharSelectionPage";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "人物外型", 
				icon = "Texture/3DMapSystem/CCS/Level1_Inventory.png", });
		end
		
		-- e.g. Create a CharSavePage command link in the main menu 
		local commandName = "Profile.CCS.CharSavePage";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "保存人物", 
				icon = "Texture/3DMapSystem/common/save.png", });
		end
		
		-- e.g. Create a AnimationPage command link in the main menu 
		local commandName = "Profile.CCS.AnimationPage";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "人物动作", 
				icon = "Texture/3DMapSystem/common/action.png", });
		end
		
		-- e.g. Create a AnimationPage command link in the main menu 
		local commandName = "Profile.CCS.FaceCamera";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "面向摄影机", 
				tooltip="人物转身面向摄影机(1键)",
				icon = "Texture/3DMapSystem/common/action.png", });
		end
		
		local commandName = "Profile.CCS.ItemEditor";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "CCS人物装备编辑器", 
				icon = "Texture/3DMapSystem/common/Catalog.png", });
		end
		
		local commandName = "Profile.CCS.AdvCCSModify";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Elf编辑器", 
				icon = "Texture/3DMapSystem/common/Catalog.png", });
		end
		
		local commandName = "Profile.CCS.AdvCCSModifyTeen";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "青年版编辑器", 
				icon = "Texture/3DMapSystem/common/Catalog.png", });
		end
	else
		-- place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. 
		app.about = "Editing character appearances. Managing the default avatar appearance for a user"
		Map3DSystem.App.CCS.app = app; 
		app.HideHomeButton = true;
		
		app.Title = "人物形象";
		app.icon = "Texture/3DMapSystem/AppIcons/People_64.dds"
		app.SubTitle = "改变3D人物的形象";
				
		-- set profile definition
		app:SetProfileDefinition({
			ProfileBox = true,
			CharParams = {
				["IsCharacter"] = true,
				["y"] = true,
				["x"] = true,
				["facing"] = true,
				["name"] = true,
				["z"] = true,
				["AssetFile"] = true,
				["CCSInfoStr"] = true,
			},
		});
		app:SetSettingPage("AvatarRegPage.html", "我的人物形象");
		app:SetHelpPage("WelcomePage.html");
		
		-- add registration page command, this is required by LoginApp to handler per application user registration. 
		local commandName = "Registration.CCS";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "App注册", });
		end
		
		if(not System.options.mc) then
			NPL.load("(gl)script/kids/3DMapSystemUI/CCS/DB.lua");
			Map3DSystem.UI.CCS.DB.InitBodyParamIDSet();
		
			-- NOTE: 2011.8.8 comment the characters.db parse
			---- update the inventory info
			--Map3DSystem.UI.CCS.DB.GetInventoryDB2();

			-- NOTE 2011/9/14: items with different qualitys with the same level shares the same model, we pick out the alternate model ids
			if(System.options.version == "teen") then
				Map3DSystem.UI.CCS.DB.GetItemDatabaseModelAlternate();
			end
		end
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.CCS.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("Profile.MyAvatar");
		if(command == nil) then
			command:Delete();
		end
	end
	-- TODO: just release any resources at shutting down. 
end

-- This is called when the command's availability is updated
-- When the user clicks a command (menu or mainbar button), the QueryStatus event is fired. 
-- The QueryStatus event returns the current status of the specified named command, whether it is enabled, disabled, 
-- or hidden in the CommandStatus parameter, which is passed to the msg by reference (or returned in the event handler). 
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
-- @param statusWanted: what status of the command is queried. it is of type Map3DSystem.App.CommandStatusWanted
-- @return: returns according to statusWanted. it may return an integer by adding values in Map3DSystem.App.CommandStatus.
function Map3DSystem.App.CCS.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		if(commandName == "Profile.MyAvatar" or commandName == "Registration.CCS") then
			-- return enabled and supported 
			return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
		end
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.CCS.OnExec(app, commandName, params)
	if(commandName == "Profile.MyAvatar") then
		-- TODO: actual code of processing the command goes here. 
		-- e.g.
		_guihelper.MessageBox("CCS application executed. ");
	elseif(commandName == "Registration.CCS" and params) then
		if(params.operation=="query") then
			-- check this application's MCML profile to determine if registration is complete. 
			local profile = app:GetMCMLInMemory() or {};
			if(profile.CharParams and profile.CharParams.AssetFile and profile.CharParams.AssetFile~="") then
				-- if username and photo is available, it means that all required fields are completed. 
				return {RequiredComplete = true, CompleteProgress = 1}
			else
				return {RequiredComplete = false, CompleteProgress = 0.1}
			end
		elseif(params.operation=="show") then
			_guihelper.CloseMessageBox();
			-- 
			-- Show the MCML registration page here. 
			-- 
			if(params.parent) then
				NPL.load("(gl)script/kids/3DMapSystemUI/CCS/AvatarRegPage.lua");
				Map3DSystem.App.CCS.AvatarRegPage.OnFinishedFunc = params.callbackFunc;
				Map3DSystem.App.CCS.AvatarRegPage:Create("CCS.AvatarRegPage", params.parent, "_fi", 0,0,0,0);
			end	
		end
	--elseif(commandName == "Profile.CCS.Facial") then
		---- show the main window with facial tab
		--NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Main2.lua");
		--Map3DSystem.UI.CCS.Main2.ShowMainWnd(true);
		--Map3DSystem.UI.CCS.Main2.ChangeToCCSTab(1);
	--elseif(commandName == "Profile.CCS.Inventory") then
		---- show the main window with inventory tab
		--NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Main2.lua");
		--Map3DSystem.UI.CCS.Main2.ShowMainWnd(true);
		--Map3DSystem.UI.CCS.Main2.ChangeToCCSTab(2);
		
	elseif(commandName == "Profile.CCS.Modify") then
		Map3DSystem.App.Commands.Call("Profile.CCS.FaceCamera") -- lxz: face camera?
		
		-- show the modify window with inventory tab
		NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Main2.lua");
		Map3DSystem.UI.CCS.Main2.ShowMainWnd(true);
		Map3DSystem.UI.CCS.Main2.ChangeToCCSTab(3);
		
	elseif(commandName == "Profile.CCS.FacialPanel") then
		Map3DSystem.App.Commands.Call("Profile.CCS.FaceCamera") -- lxz: face camera?
		
		-- show the modify window with inventory tab
		NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Main2.lua");
		Map3DSystem.UI.CCS.Main2.ShowMainWnd(true);
		Map3DSystem.UI.CCS.Main2.ChangeToCCSTab(1);
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		local _app = Map3DSystem.App.CCS.app._app;
		local _wnd = _app:FindWindow("MainWnd")
		local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
		if(frame ~= nil) then
			frame:SetIcon(command.icon);
			frame:SetText(command.ButtonText);
		end
	elseif(commandName == "Profile.CCS.CartoonFacePanel") then
		Map3DSystem.App.Commands.Call("Profile.CCS.FaceCamera") -- lxz: face camera?
		
		-- show the modify window with inventory tab
		NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Main2.lua");
		Map3DSystem.UI.CCS.Main2.ShowMainWnd(true);
		Map3DSystem.UI.CCS.Main2.ChangeToCCSTab(2);
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		local _app = Map3DSystem.App.CCS.app._app;
		local _wnd = _app:FindWindow("MainWnd")
		local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
		if(frame ~= nil) then
			frame:SetIcon(command.icon);
			frame:SetText(command.ButtonText);
		end
	elseif(commandName == "Profile.CCS.InventoryPanel") then
		Map3DSystem.App.Commands.Call("Profile.CCS.FaceCamera") -- lxz: face camera?
		
		-- show the modify window with inventory tab
		NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Main2.lua");
		Map3DSystem.UI.CCS.Main2.ShowMainWnd(true);
		Map3DSystem.UI.CCS.Main2.ChangeToCCSTab(3);
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		local _app = Map3DSystem.App.CCS.app._app;
		local _wnd = _app:FindWindow("MainWnd")
		local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
		if(frame ~= nil) then
			frame:SetIcon(command.icon);
			frame:SetText(command.ButtonText);
		end
	elseif(commandName == "Profile.CCS.HairPanel") then
		Map3DSystem.App.Commands.Call("Profile.CCS.FaceCamera") -- lxz: face camera?
		
		-- show the modify window with inventory tab
		NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Main2.lua");
		Map3DSystem.UI.CCS.Main2.ShowMainWnd(true);
		Map3DSystem.UI.CCS.Main2.ChangeToCCSTab(4);
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		local _app = Map3DSystem.App.CCS.app._app;
		local _wnd = _app:FindWindow("MainWnd")
		local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
		if(frame ~= nil) then
			frame:SetIcon(command.icon);
			frame:SetText(command.ButtonText);
		end
		
	elseif(commandName == "Profile.CCS.CharSelectionPage") then
		NPL.load("(gl)script/kids/3DMapSystemUI/CCS/CharSelectionPage.lua");
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/CCS/CharSelectionPage.html", name="CharSelectionPage", 
			app_key = app.app_key, 
			
			icon = "Texture/3DMapSystem/CCS/Level1_Inventory.png",
			text = "选择人物形象",
			DestroyOnClose = true,
			
			directPosition = true,
				align = "_ct",
				x = -460/2,
				y = -440/2,
				width = 460,
				height = 440,
		});
		
	elseif(commandName == "Profile.CCS.CharSavePage") then
		NPL.load("(gl)script/kids/3DMapSystemUI/CCS/CharSavePage.lua");
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/CCS/CharSavePage.html", name="CharSavePage", 
			app_key = app.app_key, 
			DestroyOnClose = true,
			
			directPosition = true,
				align = "_ct",
				x = -400/2,
				y = -460/2,
				width = 400,
				height = 460,
			
			icon = "Texture/3DMapSystem/common/save.png",
			text = "保存并上传人物",
		});
	elseif(commandName == "Profile.CCS.AnimationPage") then
		NPL.load("(gl)script/kids/3DMapSystemUI/CCS/AnimationPage.lua");
		
		if(params and params.ShortCutIndex) then
			-- play the animation of the short cut index 
			Map3DSystem.App.CCS.AnimationPage.PlayAnimByIndex(params.ShortCutIndex)
		else
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				url="script/kids/3DMapSystemUI/CCS/AnimationPage.html", name="AnimationPage", 
				app_key = app.app_key, 
				initialWidth = 300, 
				initialHeight = 500, 
				initialPosX = 0, 
				initialPosY = 0, 
				icon = "Texture/3DMapSystem/common/action.png",
				text = "动作",
				bToggleShowHide = true,
				bAutoSize = true,
			});	
		end	
	elseif(commandName == "Profile.CCS.FaceCamera") then	
		Map3DSystem.App.CCS.CharacterFaceCamera(ParaScene.GetPlayer())
		
	elseif(commandName == "Profile.CCS.ItemEditor") then		
		NPL.load("(gl)script/kids/3DMapSystemUI/InGame/ItemEditor.lua");
		Map3DSystem.UI.ItemEditor.Show();
		
	elseif(commandName == "Profile.CCS.AdvCCSModify") then
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/CCS/AdvCCSModifyPage.html", name="AdvCCSModifyPage", 
			app_key = app.app_key,
			
			directPosition = true,
				align = "_lt",
				x = 0,
				y = 10,
				width = 400,
				height = 600,
			
			icon = "Texture/3DMapSystem/common/save.png",
			text = "Elf编辑器",
		});
		
	elseif(commandName == "Profile.CCS.AdvCCSModifyTeen") then
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/CCS/AdvCCSModifyTeenPage.html", name="AdvCCSModifyTeenPage", 
			app_key = app.app_key,
			
			directPosition = true,
				align = "_lt",
				x = 0,
				y = 10,
				width = 400,
				height = 600,
			
			icon = "Texture/3DMapSystem/common/save.png",
			text = "青年版编辑器",
		});
		
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.CCS.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.CCS.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.CCS.DoQuickAction();
	end
end

--@param let the object to face camera.  
function Map3DSystem.App.CCS.CharacterFaceCamera(obj)
	local cx, cy, cz = ParaCamera.GetPosition();
	Map3DSystem.App.CCS.CharacterFaceTarget(obj, cx, cy, cz)
end

-- @param let the object to face camera.  
-- @param cx,cy,cz: the target position in world space to which the obj will face to. 
function Map3DSystem.App.CCS.CharacterFaceTarget(obj, cx,cy,cz)
	if(cx==nil or obj == nil or not obj:IsValid()) then
		return
	end
	
	-- check distance	
	local x,y,z = obj:GetPosition();
	local dx, dy, dz = cx-x, cy-y, cz-z;
	
	local dist = (dx*dx+dz*dz);
	if(dist>0.01)then
		dist = math.sqrt(dist);
		local facing = math.asin(dz/dist)
		if(dx>=0) then
			facing = 3.14159 - facing;
		end
		obj:SetFacing(facing+3.14159);
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.CCS.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.CCS.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.CCS.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.CCS.DoQuickAction()
end

function Map3DSystem.App.CCS.OnActivateDesktop()
	---- Show main window with facial tab
	--local commandName = "Profile.CCS.Facial";
	--local command = Map3DSystem.App.Commands.GetCommand(commandName);
	--if(command) then
		--Map3DSystem.UI.AppTaskBar.AddCommand(command, "toolbar.CCS_Facial")
	--end
	
	---- show the CCS modify panel
	--NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Modify.lua");
	--Map3DSystem.UI.CCS.Modify.ShowMainWnd(true);
	
	autotips.AddIdleTips("你有正常脸和卡通脸俩种, 卡通脸可以改变五官")
	autotips.AddIdleTips("有些人物不能改变外关, 请选择能够改变外观的人物")
	autotips.AddIdleTips("满意后, 请保存你的人物")
	autotips.AddIdleTips("按F1键获取相关帮助")

	Map3DSystem.App.Commands.Call("File.WelcomePage", {url="script/kids/3DMapSystemUI/CCS/WelcomePage.html"})
	--Map3DSystem.UI.AppTaskBar.AddCommand("Profile.CCS.FaceCamera"):Call();
	--Map3DSystem.UI.AppTaskBar.AddCommand("Profile.CCS.CharSelectionPage")
	
	-- Show main window with inventory tab
	--Map3DSystem.UI.AppTaskBar.AddCommand("Profile.CCS.Modify", "toolbar.CCS_Modify"):Call();
	Map3DSystem.UI.AppTaskBar.AddCommand("Profile.CCS.FacialPanel");
	Map3DSystem.UI.AppTaskBar.AddCommand("Profile.CCS.CartoonFacePanel");
	Map3DSystem.UI.AppTaskBar.AddCommand("Profile.CCS.InventoryPanel", "toolbar.InventoryPanel")--:Call();
	Map3DSystem.UI.AppTaskBar.AddCommand("Profile.CCS.HairPanel");
	Map3DSystem.UI.AppTaskBar.AddCommand("Profile.CCS.AnimationPage");
	Map3DSystem.UI.AppTaskBar.AddCommand("Profile.CCS.CharSavePage")
	
	-- hook into the "selection" and update the modify panel
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = Map3DSystem.App.CCS.Hook_SceneObjectSelected, 
		hookName = "CCSSelectionHook", appName = "scene", wndName = "object"});
		
	-- hook into the "onsize" and update the main window
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = Map3DSystem.App.CCS.Hook_ScreenSizeChanged, 
		hookName = "CCSOnSizeHook", appName = "input", wndName = "onsize"});
end

function Map3DSystem.App.CCS.Hook_ScreenSizeChanged(nCode, appName, msg)
	Map3DSystem.UI.CCS.Main2.OnSize(msg.width, msg.height)
	return nCode
end

function Map3DSystem.App.CCS.Hook_SceneObjectSelected(nCode, appName, msg)
	if(msg.type == Map3DSystem.msg.OBJ_SwitchObject) then
		Map3DSystem.UI.CCS.Main2.UpdatePanelUIEnabled();
		Map3DSystem.UI.CCS.Main2.UpdateFacialPanel();
	end
	return nCode
end

function Map3DSystem.App.CCS.OnDeactivateDesktop()
	-- unhook from the "selection"
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "CCSSelectionHook", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET})
	
	-- unhook from the "onsize"
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "CCSOnSizeHook", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET})
end

-- called whenever a new world is loaded (just before the 3d scene is enabled, yet after world data is loaded). 
function Map3DSystem.App.CCS.OnWorldLoad()
	if(commonlib.getfield("MyCompany.Aries") and not System.options.mc) then
		---- load the test avatar in Aries project
		---- TODO: use the avatar information from the current character equipped items
		--Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_ModifyObject, obj=ParaScene.GetPlayer(), 
			--forcelocal = true, 
			--asset_file = "character/v3/Elf/Female/ElfFemale.xml", 
			--CCSInfoStr = "0#0#0#1#0#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#248#0#114#161#0#0#203#0#0#0#0#"})
		------ reset the carema positions to a nearer position
		--ParaCamera.ThirdPerson(0, 5, 0.4, 0);
		
		-- NOTE by Andy 2009/6/18: Group special for Aries project
		NPL.load("(gl)script/apps/Aries/Pet/main.lua");
		if(commonlib.getfield("MyCompany.Aries.SentientGroupIDs")) then
			local player = ParaScene.GetPlayer();
			player:SetGroupID(MyCompany.Aries.SentientGroupIDs["Player"]);
			LOG.std("", "debug", "CCS", "player:SetGroupID(MyCompany.Aries.SentientGroupIDs[Player]);")
		end
		return
	end
	do return end
	
	-- get the character parameter for the current user. And create the current character
	local profile = Map3DSystem.App.CCS.app:GetMCMLInMemory() or {};
	
	if(profile and profile.useItemSysAvatar == true) then
		return;
	end
	
	if(type(profile) ~= "table") then
		profile = {};
	end
	
	-- compatible with old CCS characters, all avatar primary asset points to HumanFemale.xml with LOD
	local CharReplaceMap = {
		["character/v3/human/female/humanfemale.x"] = "character/v3/Human/Female/HumanFemale.xml",
		["character/v3/human/male/humanmale.x"] = "character/v3/Human/Male/HumanMale.xml",
		["character/v3/human2/female/human2female.x"] = "character/v3/Human/Female/HumanFemale.xml",
	};
	
	if(profile.CharParams and profile.CharParams.AssetFile) then
		-- modify the appearance of the current player according to CCS profile box data.
		if(CharReplaceMap[string.lower(profile.CharParams.AssetFile)]) then
			profile.CharParams.AssetFile = CharReplaceMap[string.lower(profile.CharParams.AssetFile)];
		end
		Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_ModifyObject, obj=ParaScene.GetPlayer(), 
			forcelocal = true, asset_file = profile.CharParams.AssetFile, CCSInfoStr = profile.CharParams.CCSInfoStr})
	end
	
	-- random birth spot in radius of 10 meters
	-- NOTE: the radius is testes in AlphaWorld and DoodleWorld in Aquarius Alpha1
	--		user generated world will have multiple birth spots, design needed
	local player = ParaScene.GetPlayer();
	if(player and player:IsValid() == true) then
		local px, py, pz = player:GetPosition();
		player:SetPosition(px - 5 + math.random() * 5, py, pz - 5 + math.random() * 5);
	end
	
	-- show the user nickname overhead
	Map3DSystem.App.profiles.ProfileManager.GetUserInfo(Map3DSystem.User.userID, "AvatarHeadOnDisplay", function(msg)
		if(msg == nil or not msg.users or not msg.users[1]) then
			LOG.std("", "warn", "CCS", {"error in get user info when showing head on display over avatar head", msg});
			return;
		end
		Map3DSystem.ShowHeadOnDisplay(true, player, msg.users[1].nickname);
	end, "access plus 0 day");
end

-- called whenever a world is being closed.
function Map3DSystem.App.CCS.OnWorldClosed()
	NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Main2.lua");
	Map3DSystem.UI.CCS.Main2.DestroyMainWnd();
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
function Map3DSystem.App.CCS.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.CCS.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.CCS.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.CCS.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		msg.response = Map3DSystem.App.CCS.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.CCS.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.CCS.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.CCS.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.CCS.DoQuickAction();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_ACTIVATE_DESKTOP) then
		Map3DSystem.App.CCS.OnActivateDesktop();
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DEACTIVATE_DESKTOP) then
		Map3DSystem.App.CCS.OnDeactivateDesktop();
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_WORLD_LOAD) then
		-- called whenever a new world is loaded (just before the 3d scene is enabled, yet after world data is loaded). 
		Map3DSystem.App.CCS.OnWorldLoad();
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_WORLD_CLOSING) then
		-- called whenever a world is being closed.
		Map3DSystem.App.CCS.OnWorldClosed();
	

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end