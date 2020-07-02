--[[
Title: A profile window for displaying a user profile.
Author(s): LiXizhi, WangTian
Date: 2008/2/14
Desc: it display the user photo, quick action and friend list on the left column; basic profile info and all application boxes are displayed in a mcml binded tree view control on the right side. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfileWnd.lua");
Map3DSystem.App.profiles.ShowProfile(profile)
-------------------------------------------------------
]]

-- current package binding context
local bindingContext;

if(not Map3DSystem.App.profiles.ProfileWnd) then Map3DSystem.App.profiles.ProfileWnd = {} end

--Map3DSystem.App.profiles.ProfileWnd.profileOnDisplay = nil;
Map3DSystem.App.profiles.ProfileWnd.uidOnDisplay = nil;

Map3DSystem.App.profiles.ProfileWnd.maxPhotoDisplayWidth = 200;
--Map3DSystem.App.profiles.ProfileWnd.maxPhotoDisplayHeight = 300;

-- create and display a profile window for a given uid.
function Map3DSystem.App.profiles.ShowProfile(uid)
	bindingContext = commonlib.BindingContext:new();
	bindingContext._uid = uid;
	
	Map3DSystem.App.profiles.ProfileWnd.uidOnDisplay = uid;
	
	--bindingContext = commonlib.BindingContext:new();
	--bindingContext._profile = profile;
	
	--bindingContext:AddBinding(package, "text", "AssetManager.NewAsset#packageName", commonlib.Binding.ControlTypes.ParaUI_editbox, "text")
	
	--Map3DSystem.App.profiles.ProfileWnd.profileOnDisplay = profile;
	
	NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");
	
	local profile = Map3DSystem.App.profiles.ProfileManager.GetProfile(uid);
	
	if(profile == nil) then
		profile = Map3DSystem.App.profiles.profile:new({userid = uid});
		Map3DSystem.App.profiles.ProfileManager.profiles[uid] = profile;
		
		-- download all the profile information
		Map3DSystem.App.profiles.ProfileManager.DownloadUserInfo(uid);
		--Map3DSystem.App.profiles.ProfileManager.DownloadMCML(uid);
		Map3DSystem.App.profiles.ProfileManager.DownloadFriends(uid);
	else
		--if(profile.LastDownloadTime == nil) then -- TODO: check the last update time
		--end
	end
	
	-- show profile window
	Map3DSystem.App.profiles.ProfileWnd.Show(true, nil, nil);
	
	-- hook the profile download and update
	Map3DSystem.App.profiles.RegisterProfileListener(
		"ProfileWndDisplay", 
		Map3DSystem.App.profiles.ProfileWnd.UpdateHookCallback, 
		nil -- debugUserID, 
		-- TODO: return uid or uids in the web service call
		);
	
end

-- hook callback function called whenever the profiles for uids is downloaded or updated.
-- update the user informaton, online status, friends and MCML profile if needed.
-- @param uids: List of user ids. This is a comma-separated list of user ids. if nil it will hook to all messages.
function Map3DSystem.App.profiles.ProfileWnd.UpdateHookCallback(uids)
	--if(uids == nil) then
		--log("nil\n");
	--else
		--log(uids.."\n");
	--end
	
	local debugUserID = "6ea1ce24-bdf7-4893-a053-eb5fd2a74281";
	
end

function Map3DSystem.App.profiles.ProfileWnd.MSGProc(window, msg)
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		-- close the profile window;
		Map3DSystem.App.profiles.ProfileWnd.Show(false);
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end

-- create the dialog
function Map3DSystem.App.profiles.ProfileWnd.Show(bShow, _parent, parentWindow)
	
	local _this;
	
	-- allow only one user profile display at a time
	local uid = Map3DSystem.App.profiles.ProfileWnd.uidOnDisplay;
	
	-- save the parentWindow
	
	local _profileWnd = ParaUI.GetUIObject("profiles.ProfileWnd");
	if(_profileWnd:IsValid() == false) then
		if(bShow == false) then return; end
		bShow = true;
		if(_parent == nil) then
			_profileWnd = ParaUI.CreateUIObject("container", "profiles.ProfileWnd", "_lt", 0, 50, 600, 600);
			--_profileWnd.background = "";
			_profileWnd:AttachToRoot();
		else
			_profileWnd = ParaUI.CreateUIObject("container", "profiles.ProfileWnd", "_fi", 0, 0, 0, 0);
			--_profileWnd.background = "";
			_parent:AddChild(_profileWnd);
		end
		
		local _left = ParaUI.CreateUIObject("container", "Left", "_ml", 0, 0, 200, 0);
		--_left.background = "";
		_profileWnd:AddChild(_left);
		
		local _right = ParaUI.CreateUIObject("container", "Right", "_fi", 200, 0, 0, 0);
		--_right.background = "";
		_profileWnd:AddChild(_right);
		
		-- left bar tree view
		-- NOTE: left bar and right bar use the same DrawNodeHandler
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = "ProfileWnd.LeftBarTreeView",
			alignment = "_fi",
			container_bg = "Texture/tooltip_text.PNG",
			left = 0, top = 0,
			width = 0, height = 0,
			parent = _left,
			DrawNodeHandler = Map3DSystem.App.profiles.ProfileWnd.OwnerDrawBarBoxHandler,
		};
		
		ctl:Show();
		
		-- get profile
		local profile = Map3DSystem.App.profiles.ProfileManager.GetProfile(uid);
		if(profile == nil) then
			profile = Map3DSystem.App.profiles.profile:new({userid = uid});
			ProfileManager.profiles[uid] = profile;
		end
		-- add left bar treenode, force update
		Map3DSystem.App.profiles.ProfileWnd.AddLeftBarNode(profile, true);
		
		ctl:Update();
		ctl:Update();
		
		-- right bar tree view
		-- NOTE: left bar and right bar use the same DrawNodeHandler
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = "ProfileWnd.RightBarTreeView",
			alignment = "_fi",
			container_bg = "Texture/tooltip_text.PNG",
			left = 0, top = 0,
			width = 0, height = 0,
			parent = _right,
			DrawNodeHandler = Map3DSystem.App.profiles.ProfileWnd.OwnerDrawBarBoxHandler,
		};
		
		ctl:Show();
		
		-- add right bar treenode, force update
		Map3DSystem.App.profiles.ProfileWnd.AddRightBarNode(profile);
		
		ctl:Update();
		ctl:Update();
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end
end

-- add the left bar tree node
-- e.x.: photo, Quick action links and current online status
--@param: profile, user profile
--@param: bForceUpdate, force update profile information
function Map3DSystem.App.profiles.ProfileWnd.AddLeftBarNode(profile, bForceUpdate)
	if(profile == nil or profile.userid == nil) then
		log("error: ProfileWnd.AddLeftBarNode bad param profile, table expected got nil\n");
		return;
	end
	
	local ctl = CommonCtrl.GetControl("ProfileWnd.LeftBarTreeView");
	
	if(ctl ~= nil) then
		-- add "photo"
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new(
			{Text = "photo", 
			type = "Default.photo", 
			--photo = profile:getUserPhoto(),
			photo = "",
			profile = profile,
			NodeHeight = 250,
			}));
		if(profile:getUserPhoto() == nil) then
			-- TODO: call web service to get photo from web
		end
			
		---- TODO: debug purpose
		--photo = "Texture/cr_obj.png";
		--
		--if(photo ~= nil) then
			--ctl.RootNode:AddChild(CommonCtrl.TreeNode:new(
				--{Text = "photo", 
				--type = "Default.photo", 
				--photo = photoPath,
				--profile = profile,
				--NodeHeight = 60
				--}));
		--else
			--ctl.RootNode:AddChild(CommonCtrl.TreeNode:new(
				--{Text = "photo", 
				--type = "Default.photo", 
				--photo = nil,
				--profile = profile,
				--NodeHeight = 250,
				--}));
		--end
		
		-- add "QuickActionLinks"
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new(
			{Text = "QuickActionLinks", 
			type = "Default.QuickActionLinks", 
			profile = profile,
			NodeHeight = 200,
			}));
		
		-- add "current online status"
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new(
			{Text = "OnLineStatus", 
			type = "Default.OnLineStatus", 
			userStatus = profile:getUserStatus(),
			profile = profile,
			NodeHeight = 32,
			}));
		if(profile:getUserStatus() == nil) then
			-- TODO: call web service to user online status
		end
		
		-- add "Friends"
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new(
			{Text = "Friends", 
			type = "Default.Friends",
			--friends = profile:getFriends(),
			profile = profile,
			NodeHeight = 100,
			}));
	end
end

function Map3DSystem.App.profiles.ProfileWnd.AddRightBarNode(profile)

	local ctl = CommonCtrl.GetControl("ProfileWnd.RightBarTreeView");
	if(ctl ~= nil) then
		-- add "application icons"
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new(
			{Text = "ApplicationIcons", 
			type = "Default.ApplicationIcons", 
			profile = profile, 
			NodeHeight = 100, 
			}));
	end
	-- add "basic information"
	-- add "information"
	-- add "wall"
end


-- treeview owner draw handler
-- OwnerDrawBarBoxHandler ONLY cares about the apperance information, DON'T issue any web service(RPC) calls
-- NOTE: left bar and right bar use the same DrawNodeHandler
function Map3DSystem.App.profiles.ProfileWnd.OwnerDrawBarBoxHandler(_parent, treeNode)
	if(_parent == nil or treeNode == nil) then
		return;
	end
	
	local _this;
	local left = 2 + treeNode.TreeView.DefaultIndentation * treeNode.Level; -- indentation of this node. 
	local top = 2;
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	if(treeNode:GetChildCount() > 0) then
		-- this is a profile box tag, toggle expand and collapse
		-- including a named tag and a cross sign indicating the hide profile box
		return;
		
		---- node that contains children. We shall display some
		--_this = ParaUI.CreateUIObject("button","b","_lt", left, top , 20, 20);
		--_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		--_parent:AddChild(_this);
		--left = left + 22;
		--
		--if(treeNode.Expanded) then
			--_this.background = "Texture/unradiobox.png";
		--else
			--_this.background = "Texture/radiobox.png";
		--end
	end
	
	if(treeNode.profile ~= nil) then
		if(treeNode.type == "Default.photo") then
			-- photo: 
			--	"": no profile photo
			--	non-empty string: photo url
			--	nil: wait for photo path information
			if(treeNode.photo ~= "") then
				if(treeNode.photo == nil) then
					-- waiting for web service reply
					local _waiting = ParaUI.CreateUIObject("container", "waiting", "_ct", -32, -32, 64, 64);
					_waiting.background = "Texture/3DMapSystem/common/waiting.png";
					_parent:AddChild(_waiting);
				else
					--load texture from photo url
					local _photo = ParaAsset.LoadTexture("", treeNode.photo, 1);
					local _width = _photo:GetWidth();
					local _height = _photo:GetHeight();
					
					local maxPhotoDisplayWidth = Map3DSystem.App.profiles.ProfileWnd.maxPhotoDisplayWidth;
					--local maxPhotoDisplayHeight = Map3DSystem.App.profiles.ProfileWnd.maxPhotoDisplayHeight;
					
					if(_width >= maxPhotoDisplayWidth) then
						local scale = maxPhotoDisplayWidth / _width;
						_width = maxPhotoDisplayWidth;
						_height = scale * _height;
					end
					
					local _photoCont = ParaUI.CreateUIObject("container", "photo", "_ct", - _width / 2, - _height / 2, _width, _height);
					_photoCont:SetBGImage(_photo);
					_parent:AddChild(_photoCont);
					
					-- reset the node height
					_parent.height = _height;
					treeNode.NodeHeight = _height;
				end
			else
				--no profile photo. remind the user to upload a profile picture
				local _remindUpload = ParaUI.CreateUIObject("container", "RemindUpload", "_ct", -100, -125, 200, 250);
				_remindUpload.background = "Texture/3DMapSystem/Profile/UnKnownPhoto.png";
				_parent:AddChild(_remindUpload);
				
				local _uploadBtn = ParaUI.CreateUIObject("button", "pleaseUpload", "_mb", 0, 8, 0, 24);
				_uploadBtn.background = "";
				_uploadBtn.text = "Upload a profile picture";
				_uploadBtn.onclick = ""; -- TODO: show the upload picture dialog
				_remindUpload:AddChild(_uploadBtn);
			end
		elseif(treeNode.type == "Default.QuickActionLinks") then
			local height = 0;
			local i = 0;
			local j; -- TODO: debug purpose
			for j = 1, 4 do
				-- traverse through all the applications that require quick action links
				local actionlink = ParaUI.CreateUIObject("button", "link"..i, "_mt", 0, i * 24, 0, 24);
				if(j == 1) then
					actionlink.text = "Super Poke";
				elseif(j == 2) then
					actionlink.text = "View Books";
				elseif(j == 3) then
					actionlink.text = "Send a gift";
				elseif(j == 4) then
					actionlink.text = "Invite to activity";
				end
				actionlink.background = "Texture/3DMapSystem/Profile/QuickActionLinkBG.png: 4 4 4 4";
				_parent:AddChild(actionlink);
				local removeicon = ParaUI.CreateUIObject("button", "removelink"..i, "_rt", -24, i * 24, 24, 24);
				removeicon.background = "Texture/3DMapSystem/common/Close.png";
				_parent:AddChild(removeicon);
				
				i = i + 1;
			end
			-- default action links: send message, poke, view friends and add to friends
			local defaultactionlink = ParaUI.CreateUIObject("button", "defaultlink1", "_mt", 0, i * 24, 0, 24);
			defaultactionlink.text = "Send him/her a message";
			defaultactionlink.background = "Texture/3DMapSystem/Profile/QuickActionLinkBG.png: 4 4 4 4";
			_parent:AddChild(defaultactionlink);
			i = i + 1;
			local defaultactionlink = ParaUI.CreateUIObject("button", "defaultlink2", "_mt", 0, i * 24, 0, 24);
			defaultactionlink.text = "Poke him/her";
			defaultactionlink.background = "Texture/3DMapSystem/Profile/QuickActionLinkBG.png: 4 4 4 4";
			_parent:AddChild(defaultactionlink);
			i = i + 1;
			local bIsFriend;
			bIsFriend = true;
			if(bIsFriend == true) then
				-- between friends
				-- TODO: view the friend list in additional friend profile box
			else
				-- not yet friends
				local defaultactionlink = ParaUI.CreateUIObject("button", "defaultlink3", "_mt", 0, i * 24, 0, 24);
				defaultactionlink.text = "View Friends";
				defaultactionlink.background = "Texture/3DMapSystem/Profile/QuickActionLinkBG.png: 4 4 4 4";
				_parent:AddChild(defaultactionlink);
				i = i + 1;
				local defaultactionlink = ParaUI.CreateUIObject("button", "defaultlink4", "_mt", 0, i * 24, 0, 24);
				defaultactionlink.text = "Add to friends";
				defaultactionlink.background = "Texture/3DMapSystem/Profile/QuickActionLinkBG.png: 4 4 4 4";
				_parent:AddChild(defaultactionlink);
				i = i + 1;
			end
			
			-- reset the node height
			_parent.height = i * 24;
			treeNode.NodeHeight = i * 24;
		elseif(treeNode.type == "Default.OnLineStatus") then
			if(treeNode.userStatus == Map3DSystem.App.profiles.userStatus.Online) then
				local onlinetext = ParaUI.CreateUIObject("text", "onlinenow", "_mt", 0, 8, 0, 24);
				onlinetext.text = "I am online now.";
				_parent:AddChild(onlinetext);
				local onlineicon = ParaUI.CreateUIObject("container", "onlineicon", "_rt", -40, 0, 32, 32);
				onlineicon.background = "Texture/3DMapSystem/IM/online.png";
				_parent:AddChild(onlineicon);
			elseif(treeNode.userStatus == Map3DSystem.App.profiles.userStatus.Offline) then
				-- TODO: implement the other user status
			end
		elseif(treeNode.type == "Default.ApplicationIcons") then
			-- get current profile application count
			local nCountApp = 16;
			
			-- 5 cell columns grid view
			local rows = math.ceil(nCountApp / 5);
			
			local ctl = CommonCtrl.GetControl("ProfileApplicationGridView");
			if(ctl ~= nil) then
				CommonCtrl.DeleteControl(ctl.name);
			end
			
			NPL.load("(gl)script/ide/GridView.lua");
			ctl = CommonCtrl.GridView:new{
				name = "ProfileApplicationGridView",
				alignment = "_lt",
				container_bg = "Texture/tooltip_text.png",
				left = 10, top = 0,
				width = 180,
				height = rows * 36,
				cellWidth = 36,
				cellHeight = 36,
				parent = _parent,
				columns = 5,
				rows = rows,
				DrawCellHandler = Map3DSystem.App.profiles.ProfileWnd.OwnerDrawApplicationGridCellHandler,
			};
			
			-- TODO: add the application icons according to the profile application list
			local i;
			for i = 1, 16 do
				local cell = CommonCtrl.GridCell:new{
					GridView = nil,
					name = "app"..i,
					text = "app"..i,
					index = i,
					column = 1,
					row = 1,
					};
				ctl:AppendCell(cell, "Right");
			end
			
			ctl:Show();
			
			-- reset the node height
			_parent.height = rows * 36;
			treeNode.NodeHeight = rows * 36;
		elseif(treeNode.type == "Default.Friends") then
			
			-- get current profile application count
			local nCountApp = 16;
			
			-- 5 cell columns grid view
			local rows = math.ceil(nCountApp / 5);
			
			local ctl = CommonCtrl.GetControl("ProfileApplicationGridView");
			if(ctl ~= nil) then
				CommonCtrl.DeleteControl(ctl.name);
			end
			
			NPL.load("(gl)script/ide/GridView.lua");
			ctl = CommonCtrl.GridView:new{
				name = "ProfileApplicationGridViewDEBUG",
				alignment = "_lt",
				container_bg = "Texture/tooltip_text.png",
				left = 10, top = 0,
				width = 180,
				height = rows * 36,
				cellWidth = 36,
				cellHeight = 36,
				parent = _parent,
				columns = 5,
				rows = rows,
				DrawCellHandler = Map3DSystem.App.profiles.ProfileWnd.OwnerDrawApplicationGridCellHandler,
			};
			
			-- TODO: add the application icons according to the profile application list
			local i;
			for i = 1, 16 do
				local cell = CommonCtrl.GridCell:new{
					GridView = nil,
					name = "app"..i,
					text = "app"..i,
					index = i,
					column = 1,
					row = 1,
					};
				ctl:AppendCell(cell, "Right");
			end
			
			ctl:Show();
			
			-- reset the node height
			_parent.height = rows * 36;
			treeNode.NodeHeight = rows * 36;
		end
	end
end

function Map3DSystem.App.profiles.ProfileWnd.OwnerDrawApplicationGridCellHandler(_parent, gridcell)
	if(_parent == nil or gridcell == nil) then
		return;
	end
	
	if(gridcell.text ~= nil) then
		local _this = ParaUI.CreateUIObject("button", gridcell.text, "_fi", 2, 2, 2, 2);
		-- TODO: temp application icon debug purpose
		if(gridcell.index < 10) then
			_this.background = "Texture/face/0"..gridcell.index..".png";
		else
			_this.background = "Texture/face/"..gridcell.index..".png";
		end
		_this.animstyle = 12;
		_this.tooltip = gridcell.text;
		_this.onclick = ";_guihelper.MessageBox(\"".."application click on:"..gridcell.row.." "..gridcell.column.."\");";
		_parent:AddChild(_this);
	end
end