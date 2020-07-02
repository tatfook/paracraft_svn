--[[
Title: Blueprint app for Paraworld
Author(s): LiXizhi
Date: 2008/1/12
Desc: 
db registration insert script
INSERT INTO apps VALUES (NULL, 'Blueprint_GUID', 'Blueprint', '1.0.0', 'http://www.paraengine.com/apps/Blueprint_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/BlueprintApp/IP.xml', '', 'script/kids/3DMapSystemApp/BlueprintApp/app_main.lua', 'Map3DSystem.App.Blueprint.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/BlueprintApp/app_main.lua");
------------------------------------------------------------
]]

commonlib.setfield("Map3DSystem.App.Blueprint", {});

-- requires

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.Blueprint.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a Blueprint command link in the main menu 
		local commandName = "File.New.NewBlueprint";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "新建工程图", icon = "Texture/3DMapSystem/common/package_add.png", });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			-- add to back.
			command:AddControl("mainmenu", pos_category);
			
			commandName = "File.Open.OpenBlueprint";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "打开工程图", icon = "Texture/3DMapSystem/common/package.png",});
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			-- add to back.
			command:AddControl("mainmenu", pos_category);
		end
	else
		-- place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		-- e.g. 
		Map3DSystem.App.Blueprint.app = app; -- keep a reference
		app.about = "blue print app"
		app.HomeButtonText = "工程图--首页";
		app.Title = "工程图";
		app.icon = "Texture/3DMapSystem/AppIcons/Blueprint_64.dds"
		app.SubTitle = "创造、共享3D工程图纸";
		app:SetHelpPage("WelcomePage.html");
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.Blueprint.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("File.New.NewBlueprint");
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
function Map3DSystem.App.Blueprint.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.Blueprint.OnExec(app, commandName, params)
	if(commandName == "File.New.NewBlueprint") then
		-- actual code of processing the command goes here. 
		
		NPL.load("(gl)script/kids/3DMapSystemApp/BlueprintApp/BomWnd.lua");
		
		local bom --  = {radius= 10, center = {x,y,z}};
		bom = Map3DSystem.App.Blueprint.CreateNewBom(bom);
		Map3DSystem.App.Blueprint.SelectBom(bom);
		
		--_guihelper.MessageBox("工程图应用程序为Alpha演示版: \n你可以在围墙内创建任何物品. 然后依次点击打包和保存")
		
	elseif(commandName == "File.Open.OpenBlueprint") then
		
		NPL.load("(gl)script/ide/OpenFileDialog.lua");
		local ctl = CommonCtrl.OpenFileDialog:new{
			name = "BlueprintOpenFile",
			alignment = "_ct",
			left=-256, top=-150,
			width = 512,
			height = 380,
			parent = nil,
			fileextensions = {"工程图文件(*.bom)",},
			folderlinks = {
				{path = app:GetAppDirectory(), text = "我的工程图"},
				{path = "model/", text = "常用工程图"},
			},
			onopen = function(sCtrlName, filename)
				if(filename~="") then
					NPL.load("(gl)script/kids/3DMapSystemApp/BlueprintApp/BomWnd.lua");
					
					local bom = Map3DSystem.App.Blueprint.LoadBomFromFile(filename);
					if(bom~=nil) then
						bom.center.x, bom.center.y,bom.center.z = ParaScene.GetPlayer():GetPosition();
						Map3DSystem.App.Blueprint.SelectBom(bom);
					else
						_guihelper.MessageBox("无法打开工程图文件:"..filename);
					end
				end	
			end
		};
		ctl:Show(true);
			
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.Blueprint.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.Blueprint.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.Blueprint.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.Blueprint.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.Blueprint.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.Blueprint.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.Blueprint.DoQuickAction()
end


-- Add terrain, sky and ocean button to the toolbar. 
function Map3DSystem.App.Blueprint.OnActivateDesktop()
	Map3DSystem.App.Commands.Call("File.WelcomePage", {url="script/kids/3DMapSystemApp/BlueprintApp/WelcomePage.html"})
	
	Map3DSystem.UI.AppTaskBar.AddCommand("File.New.NewBlueprint");
	Map3DSystem.UI.AppTaskBar.AddCommand("File.Open.OpenBlueprint");
end

-- deactivate:clear miniscene graphs if any. 
function Map3DSystem.App.Blueprint.OnDeactivateDesktop()
	if(Map3DSystem.App.Blueprint.SaveBom) then
		Map3DSystem.App.Blueprint.SaveBom.OnDestory();
	end	
	if(Map3DSystem.App.Blueprint.BomWnd) then
		Map3DSystem.App.Blueprint.BomWnd.OnDestroy()
	end	
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
function Map3DSystem.App.Blueprint.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.Blueprint.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.Blueprint.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.Blueprint.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.Blueprint.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.Blueprint.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.Blueprint.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.Blueprint.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.Blueprint.DoQuickAction();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_ACTIVATE_DESKTOP) then
		Map3DSystem.App.Blueprint.OnActivateDesktop();
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DEACTIVATE_DESKTOP) then
		Map3DSystem.App.Blueprint.OnDeactivateDesktop();
		
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end