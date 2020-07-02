--[[
Title: Desktop Profile Area for Aquarius App
Author(s): WangTian
Date: 2008/12/2
See Also: script/apps/Aquarius/Desktop/AquariusDesktop.lua
Area: 
	---------------------------------------------------------
	| Profile										Mini Map|
	|														|
	| 													 C	|
	| 													 h	|
	| 													 a	|
	| 													 t	|
	| 													 T	|
	| 													 a	|
	| 													 b	|
	|													 s	|
	|														|
	|														|
	|														|
	|														|
	| Menu | QuickLaunch | CurrentApp | UtilBar1 | UtilBar2	|
	|┗━━━━━━━━━━━━━Dock━━━━━━━━━━━━━┛ |
	---------------------------------------------------------
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Desktop/Profile.lua");
MyCompany.Aquarius.Desktop.Profile.InitProfile();
------------------------------------------------------------
]]

-- create class
local libName = "AquariusDesktopProfile";
local Profile = {};
commonlib.setfield("MyCompany.Aquarius.Desktop.Profile", Profile);


-- data keeping
-- current icons of Profile area
Profile.RootNode = CommonCtrl.TreeNode:new({Name = "ProfileRoot",});

Profile.SelfActionsNode = Profile.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "自身操作", Name = "SelfActionsRoot"}));
	Profile.SelfActionsNode:AddChild(CommonCtrl.TreeNode:new({CommandName = "", params = nil, icon = "Texture/Aquarius/Desktop/Profile_Action_Profile_32bits.png;0 0 21 16"}));
	Profile.SelfActionsNode:AddChild(CommonCtrl.TreeNode:new({CommandName = "", params = nil, icon = "Texture/Aquarius/Desktop/Profile_Action_AddFriend_32bits.png;0 0 21 16"}));
	Profile.SelfActionsNode:AddChild(CommonCtrl.TreeNode:new({CommandName = "", params = nil, icon = "Texture/Aquarius/Desktop/Profile_Action_Chat_32bits.png;0 0 21 16"}));
	Profile.SelfActionsNode:AddChild(CommonCtrl.TreeNode:new({type = "separator"}));
	Profile.SelfActionsNode:AddChild(CommonCtrl.TreeNode:new({CommandName = "", params = nil, icon = "Texture/Aquarius/Desktop/Profile_Action_GotoRoom_32bits.png;0 0 21 16"}));
	Profile.SelfActionsNode:AddChild(CommonCtrl.TreeNode:new({CommandName = "", params = nil, icon = "Texture/Aquarius/Desktop/Profile_Action_GotoWorld_32bits.png;0 0 21 16"}));
	Profile.SelfActionsNode:AddChild(CommonCtrl.TreeNode:new({CommandName = "", params = nil, icon = "Texture/Aquarius/Desktop/Profile_Action_GotoUser_32bits.png;0 0 21 16"}));
	Profile.SelfActionsNode:AddChild(CommonCtrl.TreeNode:new({type = "separator"}));
	Profile.SelfActionsNode:AddChild(CommonCtrl.TreeNode:new({CommandName = "", params = nil, icon = "Texture/Aquarius/Desktop/Profile_Action_Block_32bits.png;0 0 21 16"}));
	
	
Profile.OPCActionsNode = Profile.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "玩家操作", Name = "OPCActionsRoot"}));
	Profile.OPCActionsNode:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.ViewProfile", tooltip = "查看他/她的信息", params = nil, icon = "Texture/Aquarius/Desktop/Profile_Action_Profile_32bits.png;0 0 21 16"}));
	Profile.OPCActionsNode:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.AddAsFriend", tooltip = "添加为好友", params = nil, icon = "Texture/Aquarius/Desktop/Profile_Action_AddFriend_32bits.png;0 0 21 16"}));
	Profile.OPCActionsNode:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Chat.ChatWithContactImmediate", tooltip = "私聊", params = nil, icon = "Texture/Aquarius/Desktop/Profile_Action_Chat_32bits.png;0 0 21 16"}));
	Profile.OPCActionsNode:AddChild(CommonCtrl.TreeNode:new({type = "separator"}));
	Profile.OPCActionsNode:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.NA", tooltip = "去他/她的家（此版本尚未开放）", params = nil, icon = "Texture/Aquarius/Desktop/Profile_Action_GotoRoom_32bits.png;0 0 21 16"}));
	Profile.OPCActionsNode:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.NA", tooltip = "去他/她的星球（此版本尚未开放）", params = nil, icon = "Texture/Aquarius/Desktop/Profile_Action_GotoWorld_32bits.png;0 0 21 16"}));
	Profile.OPCActionsNode:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.TeleportToUser", tooltip = "去找他/她", params = nil, icon = "Texture/Aquarius/Desktop/Profile_Action_GotoUser_32bits.png;0 0 21 16"}));
	Profile.OPCActionsNode:AddChild(CommonCtrl.TreeNode:new({type = "separator"}));
	Profile.OPCActionsNode:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.NA", tooltip = "屏蔽（此版本尚未开放）", params = nil, icon = "Texture/Aquarius/Desktop/Profile_Action_Block_32bits.png;0 0 21 16"}));
	
	
-- invoked at Desktop.InitDesktop()
function Profile.InitProfile()
	
	-- hook into the "object" and update the 
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = Profile.Hook_SceneObjectSelected, 
		hookName = "ProfileSelectionHook", appName = "scene", wndName = "object"});
		
	-- Profile area
	local _profile = ParaUI.CreateUIObject("container", "ProfileArea", "_lt", 3, 3, 192, 85); --72+48*3-8, 72 + 32);
	_profile.background = "";
	_profile.zorder = -1;
	_profile:AttachToRoot();
	
		local _name = ParaUI.CreateUIObject("button", "Name", "_lt", 61, 3, 129, 19);
		_name.background = "Texture/Aquarius/Desktop/Profile_NameSlot_32bits.png; 0 0 32 19: 15 9 15 9";
		_name.text = "..."; --"李小多";
		_name.font = "Tahoma;12;bold";
		_guihelper.SetFontColor(_name, "42 132 84");
		_profile:AddChild(_name);
		
		local _BG = ParaUI.CreateUIObject("container", "BG", "_lt", 0, 0, 192, 66);
		_BG.background = "Texture/Aquarius/Desktop/Profile_BG_32bits.png: 80 30 20 20";
		_profile:AddChild(_BG);
		
		local _portrait = ParaUI.CreateUIObject("container", "Portrait", "_lt", 5, 5, 56, 56);
		_portrait.background = "Texture/Aquarius/Desktop/Profile_MyPhotoSlot_32bits.png; 0 0 108 108";
		_profile:AddChild(_portrait);
			local _BG = ParaUI.CreateUIObject("container", "BG", "_lt", 0, 0, 56, 56);
			--_BG.background = "Texture/Aquarius/Desktop/Profile_MyPhotoSlot_32bits.png; 0 0 56 56";
			_BG.background = "Texture/Aquarius/Desktop/Profile_MyPhotoSlot_32bits.png; 30 30 4 4";
			_portrait:AddChild(_BG);
			local _icon = ParaUI.CreateUIObject("button", "Icon", "_lt", 0, 0, 56, 56);
			_icon.background = "Texture/3DMapSystem/TEMP/Profile/UnKnownPhoto100.png";
			--_icon.background = "";
			_icon.onclick = ";System.App.Commands.Call(\"Profile.Aquarius.EditProfile\");";
			_icon.tooltip = "我的个人信息";
			_portrait:AddChild(_icon);
			
			local _highlight = ParaUI.CreateUIObject("button", "Highlight", "_lt", 0, 0, 56, 56);
			_guihelper.SetVistaStyleButton3(_highlight, 
				"Texture/Aquarius/Desktop/Transparent_32bits.png", 
				"Texture/Aquarius/Desktop/Profile_MyPhotoHighLight_HL_32bits.png", 
				"Texture/Aquarius/Desktop/Transparent_32bits.png", 
				"Texture/Aquarius/Desktop/Profile_MyPhotoHighLight_Pressed_32bits.png");
			_highlight.onclick = ";System.App.Commands.Call(\"Profile.Aquarius.EditProfile\");";
			_portrait:AddChild(_highlight);
			
			local _shadow = ParaUI.CreateUIObject("container", "InnerShadow", "_lt", 0, 0, 56, 56);
			_shadow.background = "Texture/Aquarius/Desktop/Profile_MyPhotoHighLight_InnerShadow_32bits.png: 20 20 20 20";
			_shadow.enabled = false;
			_portrait:AddChild(_shadow);
			
		local _separator = ParaUI.CreateUIObject("container", "Separator", "_lt", 64, 24, 2, 37);
		_separator.background = "Texture/Aquarius/Desktop/Profile_Separator_32bits.png";
		_profile:AddChild(_separator);
		local _separator = ParaUI.CreateUIObject("container", "Separator", "_lt", 184, 24, 2, 37);
		_separator.background = "Texture/Aquarius/Desktop/Profile_Separator_32bits.png";
		_profile:AddChild(_separator);
			
		local _apperence = ParaUI.CreateUIObject("container", "Apperence", "_lt", 69, 25, 112, 36);
		--_apperence.background = "Texture/Aquarius/Profile/Profile_BG.png;4 0 12 16: 4 4 4 4";
		_apperence.background = "";
		_profile:AddChild(_apperence);
			local _bg = ParaUI.CreateUIObject("container", "ShirtBG", "_lt", 38*0, 0, 36, 36);
			_bg.background = "Texture/Aquarius/Desktop/Profile_MyShowSlot_32bits.png; 0 0 36 36";
			_apperence:AddChild(_bg);
			local _shirt = ParaUI.CreateUIObject("button", "Shirt", "_lt", 38*0 + 3, 3, 30, 30);
			--_shirt.background = "Texture/Aquarius/IT_Head.png";
			_shirt.background = "";
			_shirt.tooltip = "我最喜爱的衣服（此版本尚未开放）";
			--_shirt.text = "衣服";
			_apperence:AddChild(_shirt);
			local _bg = ParaUI.CreateUIObject("container", "PantsBG", "_lt", 38*1, 0, 36, 36);
			_bg.background = "Texture/Aquarius/Desktop/Profile_MyShowSlot_32bits.png; 0 0 36 36";
			_apperence:AddChild(_bg);
			local _pants = ParaUI.CreateUIObject("button", "Pants", "_lt", 38*1 + 3, 3, 30, 30);
			--_pants.background = "Texture/Aquarius/IT_Chest.png";
			_pants.background = "";
			_pants.tooltip = "我最喜爱的裤子（此版本尚未开放）";
			--_pants.text = "裤子";
			_apperence:AddChild(_pants);
			local _bg = ParaUI.CreateUIObject("container", "BootsBG", "_lt", 38*2, 0, 36, 36);
			_bg.background = "Texture/Aquarius/Desktop/Profile_MyShowSlot_32bits.png; 0 0 36 36";
			_apperence:AddChild(_bg);
			local _boots = ParaUI.CreateUIObject("button", "Boots", "_lt", 38*2 + 3, 3, 30, 30);
			--_boots.background = "Texture/Aquarius/IT_Gloves.png";
			_boots.background = "";
			_boots.tooltip = "我最喜爱的鞋子（此版本尚未开放）";
			--_boots.text = "鞋";
			_apperence:AddChild(_boots);
		local _actionBar = ParaUI.CreateUIObject("container", "ActionBar", "_lt", 6, 61, 180, 24);
		_actionBar.background = "Texture/Aquarius/Desktop/Profile_ActionSlot_32bits.png;0 0 64 24: 12 12 12 11";
		_profile:AddChild(_actionBar);
		_actionBar:BringToBack();
		
		-- hide the myself action bar
		_actionBar.visible = false;
		
		local i;
		local left = 6;
		for i = 1, Profile.SelfActionsNode:GetChildCount() do
			local node = Profile.SelfActionsNode:GetChild(i);
			if(node.type == "separator") then
				local _separator = ParaUI.CreateUIObject("container", "Separator", "_lt", left + 1, 6, 4, 16);
				_separator.background = "Texture/Aquarius/Desktop/Profile_ActionSlot_Separator_32bits.png";
				_actionBar:AddChild(_separator);
				left = left + 9;
			else
				local _btn = ParaUI.CreateUIObject("button", "Btn", "_lt", left, 6, 21, 16);
				_btn.background = node.icon;
				_btn.onclick = ";_guihelper.MessageBox("..i..");";
				_actionBar:AddChild(_btn);
				left = left + 21;
			end
		end
	
	
	-- Target Profile area
	local _profile = ParaUI.CreateUIObject("container", "TargetProfileArea", "_lt", 220, 3, 192, 85); --72+48*3-8, 72 + 32);
	_profile.background = "";
	_profile.zorder = -1;
	_profile:AttachToRoot();
	_profile.visible = false;
	
		local _name = ParaUI.CreateUIObject("button", "Name", "_lt", 61, 3, 129, 19);
		_name.background = "Texture/Aquarius/Desktop/Profile_NameSlot_32bits.png; 0 0 32 19: 15 9 15 9";
		_name.text = "..."; --"李小多";
		_name.font = "Tahoma;12;bold";
		_guihelper.SetFontColor(_name, "42 132 84");
		_profile:AddChild(_name);
		
		local _BG = ParaUI.CreateUIObject("container", "BG", "_lt", 0, 0, 192, 66);
		_BG.background = "Texture/Aquarius/Desktop/Profile_BG_32bits.png: 80 30 20 20";
		_profile:AddChild(_BG);
		
		local _portrait = ParaUI.CreateUIObject("container", "Portrait", "_lt", 5, 5, 56, 56);
		_portrait.background = "Texture/Aquarius/Desktop/Profile_MyPhotoSlot_32bits.png; 0 0 108 108";
		_profile:AddChild(_portrait);
			local _BG = ParaUI.CreateUIObject("container", "BG", "_lt", 0, 0, 56, 56);
			--_BG.background = "Texture/Aquarius/Desktop/Profile_MyPhotoSlot_32bits.png; 0 0 56 56";
			_BG.background = "Texture/Aquarius/Desktop/Profile_MyPhotoSlot_32bits.png; 30 30 4 4";
			_portrait:AddChild(_BG);
			local _icon = ParaUI.CreateUIObject("button", "Icon", "_lt", 0, 0, 56, 56);
			_icon.background = "Texture/3DMapSystem/TEMP/Profile/UnKnownPhoto100.png";
			--_icon.background = "";
			_icon.tooltip = "查看他/她的个人信息";
			_icon.onclick = ";MyCompany.Aquarius.Desktop.Profile.CallOPCAction(1);";
			_portrait:AddChild(_icon);
			local _highlight = ParaUI.CreateUIObject("button", "Highlight", "_lt", 0, 0, 56, 56);
			_guihelper.SetVistaStyleButton3(_highlight, 
				"Texture/Aquarius/Desktop/Transparent_32bits.png", 
				"Texture/Aquarius/Desktop/Profile_MyPhotoHighLight_HL_32bits.png", 
				"Texture/Aquarius/Desktop/Transparent_32bits.png", 
				"Texture/Aquarius/Desktop/Profile_MyPhotoHighLight_Pressed_32bits.png");
			_highlight.onclick = ";MyCompany.Aquarius.Desktop.Profile.CallOPCAction(1);";
			_portrait:AddChild(_highlight);
			--local _highlight = ParaUI.CreateUIObject("container", "Highlight", "_lt", 0, 0, 56, 56);
			--_highlight.background = "Texture/Aquarius/Desktop/Profile_MyPhotoHighLight_32bits.png; 0 0 92 92";
			--_highlight.enabled = false;
			--_portrait:AddChild(_highlight);
			
			local _shadow = ParaUI.CreateUIObject("container", "InnerShadow", "_lt", 0, 0, 56, 56);
			_shadow.background = "Texture/Aquarius/Desktop/Profile_MyPhotoHighLight_InnerShadow_32bits.png: 20 20 20 20";
			_shadow.enabled = false;
			_portrait:AddChild(_shadow);
			
		local _separator = ParaUI.CreateUIObject("container", "Separator", "_lt", 64, 24, 2, 37);
		_separator.background = "Texture/Aquarius/Desktop/Profile_Separator_32bits.png";
		_profile:AddChild(_separator);
		local _separator = ParaUI.CreateUIObject("container", "Separator", "_lt", 184, 24, 2, 37);
		_separator.background = "Texture/Aquarius/Desktop/Profile_Separator_32bits.png";
		_profile:AddChild(_separator);
			
		local _apperence = ParaUI.CreateUIObject("container", "Apperence", "_lt", 69, 25, 112, 36);
		--_apperence.background = "Texture/Aquarius/Profile/Profile_BG.png;4 0 12 16: 4 4 4 4";
		_apperence.background = "";
		_profile:AddChild(_apperence);
			local _bg = ParaUI.CreateUIObject("container", "ShirtBG", "_lt", 38*0, 0, 36, 36);
			_bg.background = "Texture/Aquarius/Desktop/Profile_MyShowSlot_32bits.png; 0 0 36 36";
			_apperence:AddChild(_bg);
			local _shirt = ParaUI.CreateUIObject("button", "Shirt", "_lt", 38*0 + 3, 3, 30, 30);
			--_shirt.background = "Texture/Aquarius/IT_Head.png";
			_shirt.background = "";
			_shirt.tooltip = "他/她最喜爱的衣服（此版本尚未开放）";
			--_shirt.text = "衣服";
			_apperence:AddChild(_shirt);
			local _bg = ParaUI.CreateUIObject("container", "PantsBG", "_lt", 38*1, 0, 36, 36);
			_bg.background = "Texture/Aquarius/Desktop/Profile_MyShowSlot_32bits.png; 0 0 36 36";
			_apperence:AddChild(_bg);
			local _pants = ParaUI.CreateUIObject("button", "Pants", "_lt", 38*1 + 3, 3, 30, 30);
			--_pants.background = "Texture/Aquarius/IT_Chest.png";
			_pants.background = "";
			_pants.tooltip = "他/她最喜爱的裤子（此版本尚未开放）";
			--_pants.text = "裤子";
			_apperence:AddChild(_pants);
			local _bg = ParaUI.CreateUIObject("container", "BootsBG", "_lt", 38*2, 0, 36, 36);
			_bg.background = "Texture/Aquarius/Desktop/Profile_MyShowSlot_32bits.png; 0 0 36 36";
			_apperence:AddChild(_bg);
			local _boots = ParaUI.CreateUIObject("button", "Boots", "_lt", 38*2 + 3, 3, 30, 30);
			--_boots.background = "Texture/Aquarius/IT_Gloves.png";
			_boots.background = "";
			_boots.tooltip = "他/她最喜爱的鞋子（此版本尚未开放）";
			--_boots.text = "鞋";
			_apperence:AddChild(_boots);
		local _actionBar = ParaUI.CreateUIObject("container", "ActionBar", "_lt", 6, 61, 180, 24);
		_actionBar.background = "Texture/Aquarius/Desktop/Profile_ActionSlot_32bits.png;0 0 64 24: 12 12 12 11";
		_profile:AddChild(_actionBar);
		_actionBar:BringToBack();
		local i;
		local left = 6;
		for i = 1, Profile.OPCActionsNode:GetChildCount() do
			local node = Profile.OPCActionsNode:GetChild(i);
			if(node.type == "separator") then
				local _separator = ParaUI.CreateUIObject("container", "Separator", "_lt", left + 1, 6, 4, 16);
				_separator.background = "Texture/Aquarius/Desktop/Profile_ActionSlot_Separator_32bits.png";
				_actionBar:AddChild(_separator);
				left = left + 9;
			else
				local _btn = ParaUI.CreateUIObject("button", "Btn", "_lt", left, 6, 21, 16);
				_btn.background = node.icon;
				_btn.tooltip = node.tooltip;
				_btn.onclick = ";MyCompany.Aquarius.Desktop.Profile.CallOPCAction("..i..");";
				_actionBar:AddChild(_btn);
				left = left + 21;
			end
		end
	
	---- quicklaunch
	--local _quicklaunchTest = ParaUI.CreateUIObject("container", "QuicklaunchTest", "_rt", -420, 200, 420, 50); --72+48*3-8, 72 + 32);
	--_quicklaunchTest.background = "";
	--_quicklaunchTest.zorder = 1;
	--_quicklaunchTest:AttachToRoot();
	--
	--NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");
	--local pageCtrl = Map3DSystem.mcml.PageCtrl:new({
		--url = "script/apps/Aquarius/Desktop/QuickLaunchPage.html",
	--});
	--
	--pageCtrl:Create("QuicklaunchTest_pageCtrl", _quicklaunchTest, "_fi", 0, 0, 0, 0);
	
	---- quicklaunch
	---- currently we only limit the root bags to 5 like wow
	--local _myRootBagsTest = ParaUI.CreateUIObject("container", "MyRootBagsTest", "_rb", -48*5, -48-50, 48*5, 48); --72+48*3-8, 72 + 32);
	--_myRootBagsTest.background = "";
	--_myRootBagsTest.zorder = 1;
	--_myRootBagsTest:AttachToRoot();
	--
	--NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");
	--local pageCtrl = Map3DSystem.mcml.PageCtrl:new({
		--url = "script/apps/Aquarius/Inventory/MyBaseBags.html",
	--});
	--
	--pageCtrl:Create("MyRootBagsTest_pageCtrl", _myRootBagsTest, "_fi", 0, 0, 0, 0);
end

function Profile.CallOPCAction(index)
	local node = Profile.OPCActionsNode:GetChild(index);
	if(node ~= nil) then
		local commandName = node.CommandName;
		local command = System.App.Commands.GetCommand(commandName);
		if(command ~= nil) then
			if(Profile.TargetNID ~= nil) then
				System.App.profiles.ProfileManager.GetUserInfo(Profile.TargetNID, "Profile.CallOPCAction", function(msg)
					if(msg ~= nil) then
						if(msg.users ~= nil) then
							if(msg.users[1] ~= nil) then
								command:Call({
									uid = msg.users[1].userid,
								});
							end
						end
					end
				end);
			end
		end
	end
end

function Profile.UpdateUserName()
	local _profile = ParaUI.GetUIObject("ProfileArea");
	if(_profile:IsValid() == true) then
		local _name = _profile:GetChild("Name");
		MyCompany.Aquarius.Desktop.FillUIObjectWithNameFromNID(_name, System.User.nid, "access 0 day");
	end
end

function Profile.UpdateUserPhoto()
	local _profile = ParaUI.GetUIObject("ProfileArea");
	if(_profile:IsValid() == true) then
		local _apperence = _profile:GetChild("Portrait");
		local _icon = _apperence:GetChild("Icon");
		MyCompany.Aquarius.Desktop.FillUIObjectWithPhotoFromNID(_icon, System.User.nid, "access 0 day");
	end
end

function Profile.UpdateUserApperence()
	local _profile = ParaUI.GetUIObject("ProfileArea");
	if(_profile:IsValid() == true) then
		local player = ParaScene.GetPlayer();
		if(player:IsValid() == true and player:ToCharacter():IsCustomModel() == true) then
			local playerChar = player:ToCharacter();
			
			local function GetLevel1IndexAndItemIndex(ID)
				if(ID == nil) then
					return;
				end
				local IDs = System.UI.CCS.DB.AuraInventoryID;
				local index1, index2;
				for index1, _ in pairs(IDs) do
					for index2, __ in pairs(_) do
						if(__ == ID) then
							return index1, index2;
						end
					end
				end
			end
			
			
			local itemShirt = playerChar:GetCharacterSlotItemID(5);
			
			local level1index, itemindex = GetLevel1IndexAndItemIndex(itemShirt);
			if(level1index ~= nil and itemindex ~= nil) then
				local param = {
					AssetFile = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].model, 
					x = 0, y = 0, z = 0, 
					ReplaceableTextures = {
						[2] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[1],
						[3] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[2],
						[4] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[3],
						[5] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[4],},
				};
				NPL.load("(gl)script/ide/Canvas3D.lua");
				local ctl = CommonCtrl.GetControl("SelfProfileShirt");
				if(not ctl) then
					ctl = CommonCtrl.Canvas3D:new{
						name = "SelfProfileShirt",
						alignment = "_lt",
						left = 2, top = 2,
						width = 32,
						height = 32,
						parent = _profile:GetChild("Apperence"):GetChild("ShirtBG"),
						autoRotateSpeed = 0,
						IsActiveRendering = false,
						miniscenegraphname = "SelfProfileShirt",
						RenderTargetSize = 32,
					};
				else
					ctl.parent = _profile:GetChild("Apperence"):GetChild("ShirtBG");
				end	
				ctl:Show(true); 
				ctl:ShowModel(param);
				ctl:CameraSetEyePosByAngle(-1.5, 0, 1.2);
				ctl:Draw();
			end
			
			local itemPants = playerChar:GetCharacterSlotItemID(6);
			
			local level1index, itemindex = GetLevel1IndexAndItemIndex(itemPants);
			if(level1index ~= nil and itemindex ~= nil) then
				local param = {
					AssetFile = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].model, 
					x = 0, y = 0, z = 0, 
					ReplaceableTextures = {
						[2] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[1],
						[3] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[2],
						[4] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[3],
						[5] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[4],},
				};
				NPL.load("(gl)script/ide/Canvas3D.lua");
				local ctl = CommonCtrl.GetControl("SelfProfilePants");
				if(not ctl) then
					ctl = CommonCtrl.Canvas3D:new{
						name = "SelfProfilePants",
						alignment = "_lt",
						left = 2, top = 2,
						width = 32,
						height = 32,
						parent = _profile:GetChild("Apperence"):GetChild("PantsBG"),
						autoRotateSpeed = 0,
						IsActiveRendering = false,
						miniscenegraphname = "SelfProfilePants",
						RenderTargetSize = 32,
					};
				else
					ctl.parent = _profile:GetChild("Apperence"):GetChild("PantsBG");
				end	
				ctl:Show(true); 
				ctl:ShowModel(param);
				ctl:CameraSetEyePosByAngle(-1.5, 0, 1.2);
				ctl:Draw();
			end
						
			local itemBoots = playerChar:GetCharacterSlotItemID(3);
			
			local level1index, itemindex = GetLevel1IndexAndItemIndex(itemBoots);
			if(level1index ~= nil and itemindex ~= nil) then
				local param = {
					AssetFile = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].model, 
					x = 0, y = 0, z = 0, 
					ReplaceableTextures = {
						[2] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[1],
						[3] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[2],
						[4] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[3],
						[5] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[4],},
				};
				NPL.load("(gl)script/ide/Canvas3D.lua");
				local ctl = CommonCtrl.GetControl("SelfProfileBoots");
				if(not ctl) then
					ctl = CommonCtrl.Canvas3D:new{
						name = "SelfProfileBoots",
						alignment = "_lt",
						left = 2, top = 2,
						width = 32,
						height = 32,
						parent = _profile:GetChild("Apperence"):GetChild("BootsBG"),
						autoRotateSpeed = 0,
						IsActiveRendering = false,
						miniscenegraphname = "SelfProfileBoots",
						RenderTargetSize = 32,
					};
				else
					ctl.parent = _profile:GetChild("Apperence"):GetChild("BootsBG");
				end	
				ctl:Show(true); 
				ctl:ShowModel(param);
				ctl:CameraSetEyePosByAngle(-1.5, 0, 1.2);
				ctl:Draw();
			end
			
			local _shirt = _profile:GetChild("Apperence"):GetChild("Shirt");
			_shirt.onclick = ";MyCompany.Aquarius.Desktop.Profile.ShowSelfPreview("..itemShirt..");";
			local _pants = _profile:GetChild("Apperence"):GetChild("Pants");
			_pants.onclick = ";MyCompany.Aquarius.Desktop.Profile.ShowSelfPreview("..itemPants..");";
			local _boots = _profile:GetChild("Apperence"):GetChild("Boots");
			_boots.onclick = ";MyCompany.Aquarius.Desktop.Profile.ShowSelfPreview("..itemBoots..");";
			
		end
	end
end

function Profile.ShowSelfPreview(ID)
	
	local function GetLevel1IndexAndItemIndex(ID)
		if(ID == nil) then
			return;
		end
		local IDs = System.UI.CCS.DB.AuraInventoryID;
		local index1, index2;
		for index1, _ in pairs(IDs) do
			for index2, __ in pairs(_) do
				if(__ == ID) then
					return index1, index2;
				end
			end
		end
	end
	
	local level1index, itemindex = GetLevel1IndexAndItemIndex(ID);
	
	if(level1index ~= nil and itemindex ~= nil) then
		local param = {
			AssetFile = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].model, 
			x = 0, y = 0, z = 0, 
			ReplaceableTextures = {
				[2] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[1],
				[3] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[2],
				[4] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[3],
				[5] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[4],},
		};
		-- create a preview box
		local x, y = ParaUI.GetMousePosition();
		local temp = ParaUI.GetUIObjectAtPoint(x, y);
		if(temp:IsValid() == true) then
			while(temp.parent.name ~= "__root") do
				temp = temp.parent;
			end
			local abs_x, abs_y, abs_width, abs_height = temp:GetAbsPosition();
			
			local _fullBtn = ParaUI.GetUIObject("Profile_Self_Preview");
			if(_fullBtn:IsValid() == false) then
				_fullBtn = ParaUI.CreateUIObject("container", "Profile_Self_Preview", "_fi", 0, 0, 0, 0);
				_fullBtn.background = "";
				_fullBtn.zorder = 3; -- set above creator main window
				_fullBtn:AttachToRoot();
				local _ = ParaUI.CreateUIObject("button", "btn", "_fi", 0, 0, 0, 0);
				_.background = "";
				_.onclick = ";ParaUI.GetUIObject(\"Profile_Self_Preview\").visible = false;";
				_fullBtn:AddChild(_);
				local _preview = ParaUI.CreateUIObject("container", "_preview_cont", "_lt", abs_x , y + 100, 140, 140);
				_preview.background = "Texture/3DMapSystem/Chat/message_bg.png:7 7 7 7";
				_fullBtn:AddChild(_preview);
			end
			
			_fullBtn.visible = true;
			
			local _preview = _fullBtn:GetChild("_preview_cont");
			_preview.x = 53;
			_preview.y = 72;
			
			NPL.load("(gl)script/ide/Canvas3D.lua");
			local ctl = CommonCtrl.GetControl("Canvas_Profile_Self_Preview");
			if(not ctl) then
				ctl = CommonCtrl.Canvas3D:new{
					name = "Canvas_Profile_Self_Preview",
					alignment = "_lt",
					left = 6, top = 6,
					width = 128,
					height = 128,
					parent = _preview,
					autoRotateSpeed = 0.3,
					IsActiveRendering = true,
					miniscenegraphname = "Canvas_CCS_Preview",
					RenderTargetSize = 128,
				};
			else
				ctl.parent = _preview;
			end	
			ctl:Show(true);
			ctl:ShowModel(param);
			ctl:CameraSetEyePosByAngle(-1.5, 0, 1.2);
		end
	end
end

-- hook into the character selection, and change the target profile page
function Profile.Hook_SceneObjectSelected(nCode, appName, msg)
	
	if(nCode == nil) then return end
	
	if(msg.type == Map3DSystem.msg.OBJ_DeselectObject or msg.type == Map3DSystem.msg.OBJ_DeleteObject) then
		-- hide the target profile box
		Profile.ShowTarget("");
	elseif(msg.type == Map3DSystem.msg.OBJ_SelectObject) then
		-- show the target profile box according to the selected object
		Profile.ShowTarget("selection");
	end	
	return nCode;
end

-- show the target profile according to the param
-- @param target: 
--		if nil, show selected 
--		if "selection", show selected 
--		if "", object deselected, hide box
function Profile.ShowTarget(target)
	-- change target. 
	Profile.target = target or "selection"
	local selectObj;
	if(Profile.target ~= "") then
		selectObj = Map3DSystem.obj.GetObject(Profile.target);
	end	
	
	local _profile = ParaUI.GetUIObject("TargetProfileArea");
	if(_profile:IsValid() == false) then
		log("error: TargetProfileArea not created on Profile.ShowTarget() call\n")
		return;
	end
	if(selectObj ~= nil and selectObj:IsValid()) then
		if(selectObj:IsCharacter()) then
			-- character
			local player = ParaScene.GetPlayer();
			if(player:equals(selectObj) == true) then
				-- hide the profile box
				_profile.visible = false;
			else
				-- show the profile box
				_profile.visible = true;
				
				local _actionBar = _profile:GetChild("ActionBar");
				
				local att = selectObj:GetAttributeObject();
				local isOPC = att:GetDynamicField("IsOPC", false);
				
				if(isOPC == false) then
					-- NPC character
					local _portrait = _profile:GetChild("Portrait");
					local _icon = _portrait:GetChild("Icon");
					local param = ObjEditor.GetObjectParams(selectObj);
					_icon.background = param.AssetFile..".png";
					local _name = _profile:GetChild("Name");
					_name.background = "Texture/Aquarius/Desktop/Profile_NameSlot_NPC_32bits.png; 0 0 32 19: 15 9 15 9";
					_guihelper.SetFontColor(_name, "230 230 230");
					_name.text = selectObj.name;
					
					local _apperence = _profile:GetChild("Apperence")
					_apperence.enabled = false;
					
					_profile:GetChild("Apperence"):GetChild("ShirtBG"):RemoveAll();
					_profile:GetChild("Apperence"):GetChild("PantsBG"):RemoveAll();
					_profile:GetChild("Apperence"):GetChild("BootsBG"):RemoveAll();
					
					Profile.TargetNID = nil;
					_actionBar.visible = false;
				elseif(isOPC == true) then
					-- OPC character
					local _portrait = _profile:GetChild("Portrait");
					local _icon = _portrait:GetChild("Icon");
					local param = ObjEditor.GetObjectParams(selectObj);
					_icon.background = "";
					local _name = _profile:GetChild("Name");
					_name.background = "Texture/Aquarius/Desktop/Profile_NameSlot_OPC_32bits.png; 0 0 32 19: 15 9 15 9";
					_guihelper.SetFontColor(_name, "230 230 230");
					local nid = string.gsub(selectObj.name, "@.*$", "");
					_name.text = nid;
					
					local _apperence = _profile:GetChild("Apperence")
					_apperence.enabled = true;
					
					Profile.TargetNID = nid;
					_actionBar.visible = true;
					
					MyCompany.Aquarius.Desktop.FillUIObjectWithNameFromNID(_name, nid)
					MyCompany.Aquarius.Desktop.FillUIObjectWithPhotoFromNID(_icon, nid)
					
					Profile.UpdateOPCApperence(selectObj);
				end
			end
		else
			-- model
			-- hide the profile box
			Profile.TargetNID = nil;
			_profile.visible = false;
		end
	else
		-- hide the profile box
		Profile.TargetNID = nil;
		_profile.visible = false;
		
		---- close all target related panels if no object is selected. 
		--System.App.Commands.Call("Creation.Modify", {bShow=false})
		--System.App.Commands.Call("Creation.CharProperty", {bShow=false})
		--System.App.Commands.Call("Creation.ObjTexProperty", {bShow=false})
	end
end


function Profile.UpdateOPCApperence(player)
	local _profile = ParaUI.GetUIObject("TargetProfileArea");
	if(_profile:IsValid() == true) then
		if(player:IsValid() == true and player:ToCharacter():IsCustomModel() == true) then
			local playerChar = player:ToCharacter();
			
			local function GetLevel1IndexAndItemIndex(ID)
				if(ID == nil) then
					return;
				end
				local IDs = System.UI.CCS.DB.AuraInventoryID;
				local index1, index2;
				for index1, _ in pairs(IDs) do
					for index2, __ in pairs(_) do
						if(__ == ID) then
							return index1, index2;
						end
					end
				end
			end
			
			
			local itemShirt = playerChar:GetCharacterSlotItemID(5);
			
			local level1index, itemindex = GetLevel1IndexAndItemIndex(itemShirt);
			if(level1index ~= nil and itemindex ~= nil) then
				local param = {
					AssetFile = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].model, 
					x = 0, y = 0, z = 0, 
					ReplaceableTextures = {
						[2] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[1],
						[3] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[2],
						[4] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[3],
						[5] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[4],},
					};
				
				NPL.load("(gl)script/ide/Canvas3D.lua");
				local ctl = CommonCtrl.GetControl("OPCProfileShirt");
				if(not ctl) then
					ctl = CommonCtrl.Canvas3D:new{
						name = "OPCProfileShirt",
						alignment = "_lt",
						left = 2, top = 2,
						width = 32,
						height = 32,
						parent = _profile:GetChild("Apperence"):GetChild("ShirtBG"),
						autoRotateSpeed = 0,
						IsActiveRendering = false,
						miniscenegraphname = "OPCProfileShirt",
						RenderTargetSize = 32,
					};
				else
					ctl.parent = _profile:GetChild("Apperence"):GetChild("ShirtBG");
				end	
				ctl:Show(true); 
				ctl:ShowModel(param);
				ctl:CameraSetEyePosByAngle(-1.5, 0, 1.2);
				ctl:Draw();
			end
			
			local itemPants = playerChar:GetCharacterSlotItemID(6);
			
			local level1index, itemindex = GetLevel1IndexAndItemIndex(itemPants);
			if(level1index ~= nil and itemindex ~= nil) then
				local param = {
					AssetFile = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].model, 
					x = 0, y = 0, z = 0, 
					ReplaceableTextures = {
						[2] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[1],
						[3] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[2],
						[4] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[3],
						[5] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[4],},
					};
				NPL.load("(gl)script/ide/Canvas3D.lua");
				local ctl = CommonCtrl.GetControl("OPCProfilePants");
				if(not ctl) then
					ctl = CommonCtrl.Canvas3D:new{
						name = "OPCProfilePants",
						alignment = "_lt",
						left = 2, top = 2,
						width = 32,
						height = 32,
						parent = _profile:GetChild("Apperence"):GetChild("PantsBG"),
						autoRotateSpeed = 0,
						IsActiveRendering = false,
						miniscenegraphname = "OPCProfilePants",
						RenderTargetSize = 32,
					};
				else
					ctl.parent = _profile:GetChild("Apperence"):GetChild("PantsBG");
				end	
				ctl:Show(true); 
				ctl:ShowModel(param);
				ctl:CameraSetEyePosByAngle(-1.5, 0, 1.2);
				ctl:Draw();
			end
			
			local itemBoots = playerChar:GetCharacterSlotItemID(3);
			
			local level1index, itemindex = GetLevel1IndexAndItemIndex(itemBoots);
			if(level1index ~= nil and itemindex ~= nil) then
				local param = {
					AssetFile = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].model, 
					x = 0, y = 0, z = 0, 
					ReplaceableTextures = {
						[2] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[1],
						[3] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[2],
						[4] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[3],
						[5] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[4],},
					};
				NPL.load("(gl)script/ide/Canvas3D.lua");
				local ctl = CommonCtrl.GetControl("OPCProfileBoots");
				if(not ctl) then
					ctl = CommonCtrl.Canvas3D:new{
						name = "OPCProfileBoots",
						alignment = "_lt",
						left = 2, top = 2,
						width = 32,
						height = 32,
						parent = _profile:GetChild("Apperence"):GetChild("BootsBG"),
						autoRotateSpeed = 0,
						IsActiveRendering = false,
						miniscenegraphname = "OPCProfileBoots",
						RenderTargetSize = 32,
					};
				else
					ctl.parent = _profile:GetChild("Apperence"):GetChild("BootsBG");
				end	
				ctl:Show(true); 
				ctl:ShowModel(param);
				ctl:CameraSetEyePosByAngle(-1.5, 0, 1.2);
				ctl:Draw();
			end
			
			local _shirt = _profile:GetChild("Apperence"):GetChild("Shirt");
			_shirt.onclick = ";MyCompany.Aquarius.Desktop.Profile.ShowOPCPreview("..itemShirt..");";
			local _pants = _profile:GetChild("Apperence"):GetChild("Pants");
			_pants.onclick = ";MyCompany.Aquarius.Desktop.Profile.ShowOPCPreview("..itemPants..");";
			local _boots = _profile:GetChild("Apperence"):GetChild("Boots");
			_boots.onclick = ";MyCompany.Aquarius.Desktop.Profile.ShowOPCPreview("..itemBoots..");";
			
		end
	end
end

function Profile.ShowOPCPreview(ID)
	
	local function GetLevel1IndexAndItemIndex(ID)
		if(ID == nil) then
			return;
		end
		local IDs = System.UI.CCS.DB.AuraInventoryID;
		local index1, index2;
		for index1, _ in pairs(IDs) do
			for index2, __ in pairs(_) do
				if(__ == ID) then
					return index1, index2;
				end
			end
		end
	end
	
	local level1index, itemindex = GetLevel1IndexAndItemIndex(ID);
	
	if(level1index ~= nil and itemindex ~= nil) then
		local param = {
			AssetFile = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].model, 
			x = 0, y = 0, z = 0, 
			ReplaceableTextures = {
				[2] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[1],
				[3] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[2],
				[4] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[3],
				[5] = System.UI.CCS.DB.AuraInventoryPreview[level1index][itemindex].skin[4],},
		};
		
		-- create a preview box
		local x, y = ParaUI.GetMousePosition();
		local temp = ParaUI.GetUIObjectAtPoint(x, y);
		if(temp:IsValid() == true) then
			while(temp.parent.name ~= "__root") do
				temp = temp.parent;
			end
			local abs_x, abs_y, abs_width, abs_height = temp:GetAbsPosition();
			
			local _fullBtn = ParaUI.GetUIObject("Profile_OPC_Preview");
			if(_fullBtn:IsValid() == false) then
				_fullBtn = ParaUI.CreateUIObject("container", "Profile_OPC_Preview", "_fi", 0, 0, 0, 0);
				_fullBtn.background = "";
				_fullBtn.zorder = 3; -- set above creator main window
				_fullBtn:AttachToRoot();
				local _ = ParaUI.CreateUIObject("button", "btn", "_fi", 0, 0, 0, 0);
				_.background = "";
				_.onclick = ";ParaUI.GetUIObject(\"Profile_OPC_Preview\").visible = false;";
				_fullBtn:AddChild(_);
				local _preview = ParaUI.CreateUIObject("container", "_preview_cont", "_lt", abs_x , y + 100, 140, 140);
				_preview.background = "Texture/3DMapSystem/Chat/message_bg.png:7 7 7 7";
				_fullBtn:AddChild(_preview);
			end
			
			_fullBtn.visible = true;
			
			local _preview = _fullBtn:GetChild("_preview_cont");
			_preview.x = 274;
			_preview.y = 72 + 24;
			
			NPL.load("(gl)script/ide/Canvas3D.lua");
			local ctl = CommonCtrl.GetControl("Canvas_Profile_OPC_Preview");
			if(not ctl) then
				ctl = CommonCtrl.Canvas3D:new{
					name = "Canvas_Profile_OPC_Preview",
					alignment = "_lt",
					left = 6, top = 6,
					width = 128,
					height = 128,
					parent = _preview,
					autoRotateSpeed = 0.3,
					IsActiveRendering = true,
					miniscenegraphname = "Canvas_CCS_Preview",
					RenderTargetSize = 128,
				};
			else
				ctl.parent = _preview;
			end	
			ctl:Show(true);
			ctl:ShowModel(param);
			ctl:CameraSetEyePosByAngle(-1.5, 0, 1.2);
		end
	end
end