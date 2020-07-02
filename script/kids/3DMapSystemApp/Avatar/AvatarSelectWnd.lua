--[[
Title: An avatar selector window for user to select an avatar for ParaWorld
Author(s): WangTian
Date: 2008/3/10
Desc: Avatar selector window will display a 3D avatar on the right(using mini scene graph), 
		a list of avaible avatars in the middle(using GridView), 
		and a brief description of the selected avatar.
Desc: it display the user photo, quick action and friend list on the left column; basic profile info and all application boxes are displayed in a mcml binded tree view control on the right side. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/avatar/AvatarSelectWnd.lua");
Map3DSystem.App.Avatar.ShowAvatarSelectorWnd()
-------------------------------------------------------
]]

if(not Map3DSystem.App.Avatar.AvatarSelectorWnd) then Map3DSystem.App.Avatar.AvatarSelectorWnd = {} end

-- create and display an avatar selector window for user
function Map3DSystem.App.Avatar.ShowAvatarSelectorWnd()
	Map3DSystem.App.Avatar.AvatarSelectorWnd.Show(true, nil, nil);
end

function Map3DSystem.App.Avatar.AvatarSelectorWnd.Show(bShow, _parent, parentWindow)
	
	local _this;
	
	-- save the parentWindow
	
	-- get current user name
	local username;
	-- DEBUG PURPOSE
	username = "Andy";
	-- TODO: destroy both the 2D controls and the 3D mini scene graph
	
	local _selectorWnd = ParaUI.GetUIObject("Avatar.AvatarSelectorWnd");
	if(_selectorWnd:IsValid() == false) then
		if(bShow == false) then return; end
		bShow = true;
		if(_parent == nil) then
			_selectorWnd = ParaUI.CreateUIObject("container", "Avatar.AvatarSelectorWnd", "_lt", 0, 50, 600, 600);
			--_selectorWnd.background = "";
			_selectorWnd:AttachToRoot();
		else
			_selectorWnd = ParaUI.CreateUIObject("container", "Avatar.AvatarSelectorWnd", "_fi", 0, 0, 0, 0);
			--_selectorWnd.background = "";
			_parent:AddChild(_selectorWnd);
		end
		
		local _text = ParaUI.CreateUIObject("text", "text", "_lt", 50, 20, 100, 30);
		_text.text = "Select an Avatar";
		_text.scalingx = 1.5;
		_text.scalingy = 1.5;
		_selectorWnd:AddChild(_text);
		
		local _text = ParaUI.CreateUIObject("container", "text", "_lt", 15, 50, 200, 350);
		_selectorWnd:AddChild(_text);
		
		local _text = ParaUI.CreateUIObject("text", "text", "_lt", 15, 50, 200, 350);
		_text.text = string.format(
[[Welcome, %s!

You havn't chosen any avatar appearance. Now you can choose the way you want to look in ParaWorld!

Choose one of the many different styles we have created for you. And remember, there are almost unlimited choices of how you can look after you enter ParaWorld. You can change your skin, your hair style and color, your clothes and even your own cartoon face!

These are just a few examples of what you can choose to get you started. You’ll have plenty of opportunities to be almost anyone you want should you change your mind later.
]], username);
		_selectorWnd:AddChild(_text);
		
		local _styles = ParaUI.CreateUIObject("container", "styles", "_lt", 230, 50, 136 + 15, 340);
		_selectorWnd:AddChild(_styles);
		
		-- create treeview for the available avatar styles, each treeview node contains male and female avatar for the style
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = "AvatarStylesTreeview",
			alignment = "_fi",
			container_bg = "",
			left = 0,
			top = 0,
			width = 0,
			height = 0,
			parent = _styles,
			VerticalScrollBarStep = 68,
			DrawNodeHandler = Map3DSystem.App.Avatar.AvatarSelectorWnd.OwnerDrawStyleTreeNodeHandler,
		};
		
		local kk, vv;
		-- traverse through all the DB group objects to find all the CCS characters
		for kk, vv in pairs(Map3DSystem.DB.Groups) do
			if(vv.parent == "Normal Character") then
				local k, v;
				for k, v in pairs(Map3DSystem.DB.Items[vv.name]) do
					
					NPL.load("(gl)script/kids/3DMapSystemData/DBAssets.lua");
					local race, gender = Map3DSystem.DB.GetRaceGenderFromModelPath(v.ModelFilePath);
					if(race ~= nil and gender ~= nil) then
						local node = ctl.RootNode:GetChildByName(race);
						if(node == nil) then
							-- if not found insert new style
							node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Name = race, type = "style", NodeHeight = 68}));
							node = node:AddChild(CommonCtrl.TreeNode:new(
								{Name = gender, 
								type = "character", 
								icon = v.IconFilePath, 
								modelPath = v.ModelFilePath,
								NodeHeight = 0}));
						else
							node = node:AddChild(CommonCtrl.TreeNode:new(
								{Name = gender, 
								type = "character", 
								icon = v.IconFilePath, 
								modelPath = v.ModelFilePath,
								NodeHeight = 0}));
						end
					end
				end
			end
		end
		
		ctl:Show();
		
		-------------------------
		-- show avatar in a simple 3d scene using mini scene graph
		-------------------------
		local scene = ParaScene.GetMiniSceneGraph("previewAvatarSelector");
		------------------------------------
		-- init render target
		------------------------------------
		-- set size
		scene:SetRenderTargetSize(256, 256);
		-- reset scene, in case this is called multiple times
		scene:Reset();
		-- enable camera and create render target
		scene:EnableCamera(true);
		-- render it each frame automatically. 
		scene:EnableActiveRendering(true);
		
		local att = scene:GetAttributeObject();
		att:SetField("BackgroundColor", {1, 1, 1});  -- blue background
		att:SetField("ShowSky", false);
		att:SetField("EnableFog", false)
		--[[att:SetField("EnableFog", true);
		att:SetField("FogColor", {1, 1, 1}); -- red fog
		att:SetField("FogStart", 5);
		att:SetField("FogEnd", 25);
		att:SetField("FogDensity", 1);]]
		att:SetField("EnableLight", false)
		att:SetField("EnableSunLight", false)
		scene:SetTimeOfDaySTD(0.3);
		-- set the mini map scene to semitransparent background color
		scene:SetBackGroundColor("255 255 255 100");
		------------------------------------
		-- init camera
		------------------------------------
		scene:CameraSetLookAtPos(0, 2.2, 0);
		scene:CameraSetEyePosByAngle(0, 0.3, 10);
		
		-- main player: at 0,0,0
		local obj,player, asset;
		--asset = ParaAsset.LoadParaX("","character/v1/02animals/01land/chevalier/chevalier.x");
		--asset = ParaAsset.LoadParaX("","character/v3/Pet/MGBB/mgbb.xml");
		asset = ParaAsset.LoadParaX("", Map3DSystem.App.Avatar.DefaultQuestionSign);
		obj = ParaScene.CreateCharacter("previewAvatar", asset, "", true, 0.35, 0.5, 2);
		obj:SetPosition(0, -2.5, 0);
		obj:SetScaling(2.5);
		obj:SetFacing(2);
        
		scene:AddChild(obj);
		
		local _preview = ParaUI.CreateUIObject("container", "preview", "_lt", 380 + 15, 50, 200 - 15, 256);
		_preview:SetBGImageAndRect(scene:GetTexture(), 33, 0, 200 - 15, 256);
		_selectorWnd:AddChild(_preview);
		
		
		local _skip = ParaUI.CreateUIObject("button", "preview", "_lt", 380 + 15, 308, 64, 32);
		_skip.text = "Skip";
		_skip.onclick = ";Map3DSystem.App.Avatar.AvatarSelectorWnd.SkipSelection();";
		_selectorWnd:AddChild(_skip);
		local _accept = ParaUI.CreateUIObject("button", "preview", "_lt", 380 + 15 + 64, 308, 64, 32);
		_accept.text = "Accept";
		_accept.onclick = ";Map3DSystem.App.Avatar.AvatarSelectorWnd.AcceptAvatar();";
		_selectorWnd:AddChild(_accept);
		
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end
end

-- destroy the mini scene graph when user skip or select an avatar
function Map3DSystem.App.Avatar.AvatarSelectorWnd.DestroyMiniScene()
	local scene = ParaScene.GetMiniSceneGraph("previewAvatarSelector");	
end

-- skip the avatar selection window
function Map3DSystem.App.Avatar.AvatarSelectorWnd.SkipSelection()
	_guihelper.MessageBox("Skip avatar selection.\n");
end

-- apply the avatar race and gender
function Map3DSystem.App.Avatar.AvatarSelectorWnd.AcceptAvatar()
	local race = Map3DSystem.App.Avatar.AvatarSelectorWnd.CurrentSelectRace;
	local gender = Map3DSystem.App.Avatar.AvatarSelectorWnd.CurrentSelectGender;
	
	_guihelper.MessageBox("Accept: "..race.." "..gender..".\n");
end

Map3DSystem.App.Avatar.AvatarSelectorWnd.CurrentSelectRace = nil;
Map3DSystem.App.Avatar.AvatarSelectorWnd.CurrentSelectGender = nil;

-- change the avatar selection preview and mount the default appearance information
function Map3DSystem.App.Avatar.AvatarSelectorWnd.OnClickNode(race, gender, modelPath)
	--_guihelper.MessageBox(race.." "..gender.." "..modelPath.."\n");
	
	local scene = ParaScene.GetMiniSceneGraph("previewAvatarSelector");
	scene:RemoveObject("previewAvatar");
	
	-- main player: at 0,0,0
	local obj,player, asset;
	asset = ParaAsset.LoadParaX("", modelPath);
	obj = ParaScene.CreateCharacter("previewAvatar", asset, "", true, 0.35, 0.5, 1);
	if(obj:IsValid() == true) then
		obj:SetPosition(0, 0, 0);
		obj:SetScaling(2.5);
		obj:SetFacing(2);
	    
		scene:AddChild(obj);
		
		Map3DSystem.App.Avatar.AvatarSelectorWnd.CurrentSelectRace = race;
		Map3DSystem.App.Avatar.AvatarSelectorWnd.CurrentSelectGender = gender;
		
		NPL.load("(gl)script/kids/3DMapSystemUI/CCS/DefaultAppearance.lua");
		Map3DSystem.UI.CCS.DefaultAppearance.MountDefaultAppearance(obj);
	end
end

-- style tree node owner draw function
function Map3DSystem.App.Avatar.AvatarSelectorWnd.OwnerDrawStyleTreeNodeHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	
	if(treeNode:GetChildCount() > 0) then
		if(treeNode.type == "style") then
			local maleNode = treeNode:GetChildByName("male");
			if(maleNode ~= nil) then
				local _male = ParaUI.CreateUIObject("button", "male", "_lt", 2, 2, 64, 64);
				_male.onclick = string.format([[;Map3DSystem.App.Avatar.AvatarSelectorWnd.OnClickNode("%s", "%s", "%s");]], 
						treeNode.Name, "male", maleNode.modelPath);
				_male.background = maleNode.icon;
				_parent:AddChild(_male);
			end
			local femaleNode = treeNode:GetChildByName("female");
			if(femaleNode ~= nil) then
				local _female;
				if(maleNode == nil) then
					_female = ParaUI.CreateUIObject("button", "female", "_lt", 2, 2, 64, 64);
				else
					_female = ParaUI.CreateUIObject("button", "female", "_lt", 70, 2, 64, 64);
				end
				_female.onclick = string.format([[;Map3DSystem.App.Avatar.AvatarSelectorWnd.OnClickNode("%s", "%s", "%s");]], 
						treeNode.Name, "female", femaleNode.modelPath);
				_female.background = femaleNode.icon;
				_parent:AddChild(_female);
			end
		end
	end
end