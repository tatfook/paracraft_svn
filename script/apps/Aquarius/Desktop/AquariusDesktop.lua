--[[
Title: Desktop UI for Aquarius App
Author(s): WangTian
Date: 2008/12/2
Desc: The desktop UI contains: 
	1. left top area: current user and target profile
	2. right middle area: current chat window tabs
	3. right top area: mini map and status arranged around the minimap
	4. middle bottom area: always on top first level function list, it further divides into:
		4.1 Menu, "windows start"-like icon to show all the applications in a window
		4.2 Quick Launch, customizable bar that holds user specific organization
		4.3 Current App, shows the current application icon indicating the running application status
		4.4 UtilBar1, utility bar 1, show small icons of utility
		4.5 UtilBar2, utility bar 2, show large icons of utility
Note: Each area is further divided into 4 files
Area: 
					---------------------------------------------------------
	 zorder = -1 -> | Profile	Target								Mini Map| <- zorder = -1
target zorder = -1 	|														|
					| 													 C	|
					| 													 h	|
					| 													 a	|
					| 													 t	| <- zorder = 2
					|-------|											 T	|
					| 		|											 a	|
					| 	M	|											 b	|
	  zorder = 4 -> |	E	|											 s	|
					| - N - |--------							 -----------|
					|	U	|		|							 |  Notif-  | <- zorder = 1
	 zorder = -1 -> |		|Channel|							 | ication  |
					|		|		|	CurrentApp Toolbar		 |			| <- zorder = 2
					| Menu | QuickLaunch | CurrentApp | UtilBar1 | UtilBar2	| <- zorder = 3
					|┗━━━━━━━━━━━━━Dock━━━━━━━━━━━━━┛ |
					---------------------------------------------------------
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Desktop/AquariusDesktop.lua");
MyCompany.Aquarius.Desktop.InitDesktop();
MyCompany.Aquarius.Desktop.SendMessage({type = MyCompany.Aquarius.Desktop.MSGTYPE.SHOW_DESKTOP, bShow = true});
------------------------------------------------------------
]]

-- create class
local libName = "AquariusDesktop";
local Desktop = {};
commonlib.setfield("MyCompany.Aquarius.Desktop", Desktop);

-- individual files of each UI area
NPL.load("(gl)script/apps/Aquarius/Desktop/Profile.lua");
NPL.load("(gl)script/apps/Aquarius/Desktop/Minimap.lua");
NPL.load("(gl)script/apps/Aquarius/Desktop/Dock.lua");
NPL.load("(gl)script/apps/Aquarius/Desktop/ChatTabs.lua");

-- direct animation manager
NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");


-- messge types
Desktop.MSGTYPE = {
	-- show/hide the task bar, 
	-- msg = {bShow = true}
	SHOW_DESKTOP = 1001,
};

NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
local fileName = "script/UIAnimation/CommonIcon.lua.table.table";
UIAnimManager.LoadUIAnimationFile(fileName);

-- register a timer for time played countup and update the hour and minute text
function Desktop.DoCountTime()
	local date = ParaGlobal.GetDateFormat("yyyy-M-d");
	local readdate = MyCompany.Aquarius.app:ReadConfig("Date", nil);
	if(readdate == date) then
		-- continue with the last time count
		local minutes = MyCompany.Aquarius.app:ReadConfig("Minutes", nil);
		minutes = minutes + 1;
		MyCompany.Aquarius.app:WriteConfig("Minutes", minutes);
		-- update the hour and minute texts if exist
		local _hour = ParaUI.GetUIObject(Desktop.timehour_id);
		if(_hour:IsValid() == true) then
			_hour.text = math.floor(minutes/60).."";
		end
		local _minute = ParaUI.GetUIObject(Desktop.timeminute_id);
		if(_minute:IsValid() == true) then
			_minute.text = math.mod(minutes, 60).."";
		end
	else
		-- start count of the day
		MyCompany.Aquarius.app:WriteConfig("Date", date);
		MyCompany.Aquarius.app:WriteConfig("Minutes", 0);
	end
end

-- call this only once at the beginning of Aquarius. 
-- init desktop components
function Desktop.InitDesktop()
	if(Desktop.IsInit) then return end
	Desktop.IsInit = true;
	Desktop.name = libName;
	
	-- initialize each desktop area
	Desktop.MiniMap.InitMiniMap();
	Desktop.Profile.InitProfile();
	Desktop.ChatTabs.InitChatTabs();
	Desktop.Dock.InitDock();
	
	NPL.load("(gl)script/apps/Aquarius/Desktop/LocalMap.lua");
	Desktop.LocalMap.InitLocalMap();
	
	-- register the text bubble timer
	Desktop.ChatTabs.RegisterDoBubbleTimer();
	
	-- register the notification timer
	Desktop.Dock.RegisterDoNotificationTimer()
	
	NPL.load("(gl)script/apps/Aquarius/BBSChat/BBSChatWnd.lua");
	MyCompany.Aquarius.BBSChatWnd.Show(true);
	
	-- create windows for message handling
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp(Desktop.name);
	Desktop.App = _app;
	Desktop.MainWnd = _app:RegisterWindow("main", nil, Desktop.MSGProc);
end

-- show desktop with animation
-- this funcion is usually called when world is loaded
function Desktop.ShowDesktopWithAnimation()
	
	local _dock = ParaUI.GetUIObject("Dock");
	-- show animation
	local block = UIDirectAnimBlock:new();
	block:SetUIObject(_dock);
	block:SetTime(400);
	block:SetTranslationYRange(56, 0);
	block:SetApplyAnim(true); 
	UIAnimManager.PlayDirectUIAnimation(block);
	
	local _profileArea = ParaUI.GetUIObject("ProfileArea");
	-- show animation
	local block = UIDirectAnimBlock:new();
	block:SetUIObject(_profileArea);
	block:SetTime(400);
	block:SetTranslationXRange(-(72+48*3-8 + 5), 0);
	block:SetApplyAnim(true); 
	UIAnimManager.PlayDirectUIAnimation(block);
	
	local _targetProfileArea = ParaUI.GetUIObject("TargetProfileArea");
	-- show animation
	local block = UIDirectAnimBlock:new();
	block:SetUIObject(_targetProfileArea);
	block:SetTime(400);
	block:SetTranslationYRange(-(72+32+10), 0);
	block:SetApplyAnim(true); 
	UIAnimManager.PlayDirectUIAnimation(block);
	
	local _minimapArea = ParaUI.GetUIObject("MinimapArea");
	-- show animation
	local block = UIDirectAnimBlock:new();
	block:SetUIObject(_minimapArea);
	block:SetTime(400);
	block:SetTranslationXRange(24+2 + 128+6 + 24+2+10, 0);
	block:SetApplyAnim(true); 
	UIAnimManager.PlayDirectUIAnimation(block);
end

-- send a message to Desktop:main window handler
-- Desktop.SendMessage({type = Desktop.MSGTYPE.MENU_SHOW});
function Desktop.SendMessage(msg)
	msg.wndName = "main";
	Desktop.App:SendMessage(msg);
end

-- Desktop window handler
function Desktop.MSGProc(window, msg)
	if(msg.type == Desktop.MSGTYPE.SHOW_DESKTOP) then
		-- show/hide the task bar, 
		-- msg = {bShow = true}
		Desktop.Show(msg.bShow);
	end
end

-- show or hide task bar UI
function Desktop.Show(bShow)
	if(Desktop.IsInit == false) then return end
	if(bShow == true) then
		-- show desktop with animation
		--Desktop.ShowDesktopWithAnimation();
	end
end

local HidenContainers = {};
-- these function pairs is useful in Movie application that will exclusively use the full screen area for movie playback
-- hide all visible containers
-- all visible containers are in HidenContainers table, the containers will be translated to the neibor screen area
-- NOTE: carefully use this function and implement a more precise solution for aquarius if movie playback heavily depends on this exclusive mode
-- Any of the following process will ruin the movie playback and shows additional contianer of window frame object on the screen:
--		MessageBox, ChatWnd, Chatbubble, Notification, InputChannelText, LocalMap or QuestList invoked with keyboard, 
function Desktop.HideAllVisible()
	local _root = ParaUI.GetUIObject("root");
	local _, __, screenwidth, screenheight = _root:GetAbsPosition();
	
	-- traverse all visible root containers
	-- pay attention the GetChildAt function indexed in C++ form which begins at index 0
	local nCount = _root:GetChildCount();
	for i = 0, nCount - 1 do
		local _container = _root:GetChildAt(i);
		if(_container.visible == true) then
			local x, y, width, height = _container:GetAbsPosition();
			-- hide the container to the nearest screen neighbor
			local block = UIDirectAnimBlock:new();
			block:SetUIObject(_container);
			block:SetTime(500);
			if(x * 2 + width) == screenwidth then
				block:SetTranslationXRange(0, 0);
				block:SetTranslationYRange(0, screenheight);
				HidenContainers[_container.id] = {x = 0, y = screenheight};
			elseif((x + width/2) > screenwidth/2 and (y + height/2) > screenheight/2) then
				block:SetTranslationXRange(0, screenwidth);
				block:SetTranslationYRange(0, screenheight);
				HidenContainers[_container.id] = {x = screenwidth, y = screenheight};
			elseif((x + width/2) <= screenwidth/2 and (y + height/2) > screenheight/2) then
				block:SetTranslationXRange(0, -screenwidth);
				block:SetTranslationYRange(0, screenheight);
				HidenContainers[_container.id] = {x = -screenwidth, y = screenheight};
			elseif((x + width/2) > screenwidth/2 and (y + height/2) <= screenheight/2) then
				block:SetTranslationXRange(0, screenwidth);
				block:SetTranslationYRange(0, -screenheight);
				HidenContainers[_container.id] = {x = screenwidth, y = -screenheight};
			elseif((x + width/2) <= screenwidth/2 and (y + height/2) <= screenheight/2) then
				block:SetTranslationXRange(0, -screenwidth);
				block:SetTranslationYRange(0, -screenheight);
				HidenContainers[_container.id] = {x = -screenwidth, y = -screenheight};
			end
			block:SetApplyAnim(true); 
			block:SetCallback(function ()
				_container.translationx = HidenContainers[_container.id].x;
				_container.translationy = HidenContainers[_container.id].y;
				_container:ApplyAnim();
			end);
			UIAnimManager.PlayDirectUIAnimation(block);
		end
	end
	local _this = ParaUI.CreateUIObject("container", "HideAllVisibleBlocker", "_fi", 0, 0, 0, 0);
	_this.background = "";
	-- NOTE: the Blocker is set to a super large zorder to prevent mouse interaction to the translated ui objects
	-- other ui objects that can be used during the movie playback process can be set to a zorder that larger than 1001
	_this.zorder = 1001;
	_this:AttachToRoot();
	
	-- NOTE: turn off the check mouse entrance
	-- BBS channel window entrance and leave is handled by script, since we only make a translation of the container
	--		the window area stays in the screen and CheckMouseEnterance don't take zorder into consideration
	MyCompany.Aquarius.BBSChatWnd.isCheckMouseEnterance = false;
end

-- restore the last hide visible containers in HidenContainers and reset the table to prevent multiple invoke of the restore function
function Desktop.RestoreAllVisible()
	-- NOTE: turn on the check mouse entrance
	MyCompany.Aquarius.BBSChatWnd.isCheckMouseEnterance = true;
	
	ParaUI.Destroy("HideAllVisibleBlocker");
	local id, pos;
	for id, pos in pairs(HidenContainers) do
		local _container = ParaUI.GetUIObject(id);
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_container);
		block:SetTime(500);
		block:SetTranslationXRange(pos.x, 0);
		block:SetTranslationYRange(pos.y, 0);
		block:SetApplyAnim(true); 
		UIAnimManager.PlayDirectUIAnimation(block);
		
		HidenContainers[id] = nil;
	end
end

-- fill uiobject mechanism
-- 
-- this function will append the quest in a userinfo queue
-- the queue will batch the quests and make service call once every 0.1 second
-- once message returned, the call back will find the ui object back to fill in the information, username or photo

Desktop.FillUserNameQueue = {};
Desktop.FillUserPhotoQueue = {};

function Desktop.RegisterDoFillUIObjectTimer()
	-- set fill uiobject user name and user profile timer
	NPL.SetTimer(6543, 0.1, ";MyCompany.Aquarius.Desktop.DoFillUIObjectNameTimer();");
	NPL.SetTimer(6544, 0.1, ";MyCompany.Aquarius.Desktop.DoFillUIObjectPhotoTimer();");
end

function Desktop.DoFillUIObjectNameTimer()
	local nCount = table.getn(Desktop.FillUserNameQueue);
	if(nCount > 0) then
		local i, item;
		for i, item in pairs(Desktop.FillUserNameQueue) do
			if(item.isGetInfoProcessing ~= true) then
				if(item.nid ~= nil) then
					item.isGetInfoProcessing = true;
					System.App.profiles.ProfileManager.GetUserInfo(item.nid, "AquariusFillBackName"..item.nid, function (msg)
						if(msg == nil) then	
							log("error message in . \n");
							return;
						end
						--commonlib.echo(msg);
						
						local username;
						if(msg and msg.users and msg.users[1]) then
							username = msg.users[1].nickname;
						end
						
						if(username == nil or username == "") then
							username = "匿名";
						end
						
						local i, itemName;
						local nids = "";
						
						for i, itemName in pairs(Desktop.FillUserNameQueue) do
							if(itemName.isGetInfoProcessing == true) then
								if(item.nid == itemName.nid) then
									local _obj = ParaUI.GetUIObject(itemName.ObjID)
									if(_obj:IsValid() == true) then
										--log("back name: ".._obj.name.."\n")
										
										if(item.formatstring) then
											_obj.text = string.format(item.formatstring, username);
										else
											_obj.text = username;
										end
									end
									--Desktop.FillUserNameQueue[i] = nil;
									Desktop.FillUserNameQueue[i] = nil;
								end
							end
						end
					end, item.cache_policy);
					--paraworld.users.getInfo({nids = item.nid, fields = "userid,nid,username,nickname,photo"}, "AquariusFillNameGetUserInfo"..item.nid, function(msg)
						--if(msg == nil) then
							--log("error occurs in AquariusFillGetUserInfo\n")
							--return;
						--end
						--local i, user 
						--for i, user in pairs(msg.users) do
							--Desktop.FillBackName(user.userid, user.nid)
						--end
					--end);
				end
			end
		end
	end
end

--function Desktop.FillBackName(uid, nid)
	--paraworld.profile.GetMCML({uid = uid, appkey = "profiles_GUID", }, "AquariusFillBackName"..nid, function(msg)
		--if(msg == nil) then	
			--log("error message in . \n");
			--return;
		--end
		--local profile;
		--local username;
		--
		--if(msg.appkey == "profiles_GUID") then
			--if(type(msg.profile) == "string") then
				---- we will try to convert it to table. 
				--if(string.match(msg.profile, "^%s*{.*}%s*$")) then
					---- app is string serialized from a lua table
					--if(NPL.IsPureData(msg.profile)) then
						--profile = commonlib.LoadTableFromString(msg.profile);
					--else
						--profile = nil;
					--end
				--end
			--end
			--if(profile ~= nil ) then
				--if(profile.UserInfo ~= nil) then
					--username = profile.UserInfo.username;
				--end
			--end
		--end
		--if(username == nil) then
			--username = "匿名";
		--end
		--
		--local i, item;
		--local nids = "";
		--
		--for i, item in pairs(Desktop.FillUserNameQueue) do
			--if(item.isGetInfoProcessing == true) then
				--if(nid == item.nid) then
					--local _obj = ParaUI.GetUIObject(item.ObjID)
					--if(_obj:IsValid() == true) then
						--_obj.text = username;
					--end
					--Desktop.FillUserNameQueue[i] = nil;
				--end
			--end
		--end
	--end);
--end
	
function Desktop.DoFillUIObjectPhotoTimer()
	local nCount = table.getn(Desktop.FillUserPhotoQueue);
	if(nCount > 0) then
		local i, item;
		for i, item in pairs(Desktop.FillUserPhotoQueue) do
			if(item.isGetInfoProcessing ~= true) then
				if(item.nid ~= nil) then
					item.isGetInfoProcessing = true;
					System.App.profiles.ProfileManager.GetUserInfo(item.nid, "AquariusFillBackPhoto"..item.nid, function (msg)
						if(msg == nil) then	
							log("error message in . \n");
							return;
						end
						local photo;
						
						local username;
						if(msg and msg.users and msg.users[1]) then
							photo = msg.users[1].smallphoto;
						end
						
						if(photo == nil or photo == "") then
							photo = "Texture/3DMapSystem/TEMP/Profile/UnKnownPhoto100.png";
						end
						local i, itemPhoto;
						for i, itemPhoto in pairs(Desktop.FillUserPhotoQueue) do
							if(item.nid == itemPhoto.nid) then
								if(itemPhoto.isGetInfoProcessing == true) then
									local _obj = ParaUI.GetUIObject(itemPhoto.ObjID)
									if(_obj:IsValid() == true) then
										_obj.background = photo;
									end
									
									if(Desktop.FillUserPhotoQueue[i].waiting ~= nil) then
										local fileName = "script/UIAnimation/CommonIcon.lua.table.table";
										local _waiting = ParaUI.GetUIObject(Desktop.FillUserPhotoQueue[i].waiting);
										if(_waiting:IsValid() == true) then
											local _spin = _waiting:GetChild("waiting");
											if(_spin:IsValid() == true) then
												UIAnimManager.StopLoopingUIAnimationSequence(_spin, fileName, "Spin");
											end
										end
										ParaUI.Destroy(Desktop.FillUserPhotoQueue[i].waiting);
										--Desktop.FillUserPhotoQueue[i] = nil;
										Desktop.FillUserPhotoQueue[i] = nil;
									end
								end
							end
						end
					end, item.cache_policy);
					--paraworld.users.getInfo({nids = item.nid, fields = "userid,nid,username,nickname,photo"}, "AquariusFillPhotoGetUserInfo"..item.nid, function(msg)
						--if(msg == nil) then
							--log("error occurs in AquariusFillGetUserInfo\n")
							--return;
						--end
						--
						--local i, user 
						--for i, user in pairs(msg.users) do
							--Desktop.FillBackPhoto(user.userid, user.nid);
						--end
					--end);
				end	
			else
				--item.count = item.count or 0;
				--item.count = item.count + 1;
				--if(item.count >= 50) then
					---- remove item if in process queue exceeds 5 seconds
					--Desktop.FillUserPhotoQueue[i] = nil;
				--end
			end
		end		
	end
end

--function Desktop.FillBackPhoto(uid, nid)
	--paraworld.profile.GetMCML({uid = uid, appkey = "profiles_GUID", }, "AquariusFillBackPhoto"..nid, function(msg)
		--if(msg == nil) then	
			--log("error message in . \n");
			--return;
		--end
		--local profile;
		--local photo;
		--if(msg.appkey == "profiles_GUID") then
			--if(type(msg.profile) == "string") then
				---- we will try to convert it to table. 
				--if(string.match(msg.profile, "^%s*{.*}%s*$")) then
					---- app is string serialized from a lua table
					--if(NPL.IsPureData(msg.profile)) then
						--profile = commonlib.LoadTableFromString(msg.profile);
					--else
						--profile = nil;
					--end
				--end
			--end
			--if(profile ~= nil ) then
				--if(profile.UserInfo ~= nil) then
					--photo = profile.UserInfo.photo;
				--end
			--end
		--end
		--if(photo == nil) then
			--photo = "Texture/3DMapSystem/TEMP/Profile/UnKnownPhoto100.png";
		--end
		--
		--local i, item;
		--local nids = "";
		--for i, item in pairs(Desktop.FillUserPhotoQueue) do
			--if(nid == item.nid) then
				--if(item.isGetInfoProcessing == true) then
					--local _obj = ParaUI.GetUIObject(item.ObjID)
					--if(_obj:IsValid() == true) then
						--log("back: ".._obj.name.."\n")
						--_obj.background = photo;
					--end
					--NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
					--local fileName = "script/UIAnimation/CommonIcon.lua.table.table";
					--UIAnimManager.LoadUIAnimationFile(fileName);
					--local _waiting = ParaUI.GetUIObject(Desktop.FillUserPhotoQueue[i].waiting);
					--if(_waiting:IsValid() == true) then
						--local _spin = _waiting:GetChild("waiting");
						--if(_spin:IsValid() == true) then
							--UIAnimManager.StopLoopingUIAnimationSequence(_spin, fileName, "Spin");
						--end
					--end
					--ParaUI.Destroy(Desktop.FillUserPhotoQueue[i].waiting);
					--Desktop.FillUserPhotoQueue[i] = nil;
				--end
			--end
		--end
	--end);
--end

-- fill the ui object with user name according to nid
function Desktop.FillUIObjectWithNameFromNID(_this, nid, cache_policy, formatstring)
	if(_this ~= nil and _this:IsValid() == true) then
		if(_this.type == "container") then
			log("container object don't support text field\n");
			return;
		end
		table.insert(Desktop.FillUserNameQueue, {
			ObjID = _this.id, 
			nid = nid, 
			cache_policy = cache_policy, 
			formatstring = formatstring
		});
	end
end

-- fill the ui object with user name according to nid
function Desktop.FillUIObjectWithPhotoFromNID(_this, nid, cache_policy)
	if(_this ~= nil and _this:IsValid() == true) then
		local _parent = _this.parent;
		if(_parent:IsValid() == true) then
			local x_this, y_this, width_this, height_this = _this:GetAbsPosition();
			local x_parent, y_parent, width_parent, height_parent = _parent:GetAbsPosition();
			
			local name = ParaGlobal.GenerateUniqueID();
			local _waiting = ParaUI.CreateUIObject("container", name, "_lt", 
					- x_parent + x_this + (width_this - 24)/2, - y_parent + y_this + (height_this - 24)/2, 26, 26);
			_waiting.background = "Texture/Aquarius/Common/WaitingShadow_32bits.png; 0 0 26 26";
			_waiting.enabled = false;
			_parent:AddChild(_waiting);
			local _spin = ParaUI.CreateUIObject("container", "waiting", "_lt", 0, 0, 24, 24);
			_spin.background = "Texture/Aquarius/Common/Waiting_32bits.png; 0 0 24 24";
			_waiting:AddChild(_spin);
			
			local fileName = "script/UIAnimation/CommonIcon.lua.table.table";
			if(_spin:IsValid() == true) then
				UIAnimManager.PlayUIAnimationSequence(_spin, fileName, "Spin", true);
			end
			
			table.insert(Desktop.FillUserPhotoQueue, {ObjID = _this.id, nid = nid, cache_policy = cache_policy, waiting = name});
		end
	end
end

-- fill the ui object with user name according to nid,
-- NOTE: without animation
function Desktop.FillUIObjectWithPhotoFromNIDImmediate(_this, nid, cache_policy)
	if(_this ~= nil and _this:IsValid() == true) then
		table.insert(Desktop.FillUserPhotoQueue, {ObjID = _this.id, nid = nid, cache_policy = cache_policy, waiting = nil});
	end
end


--
--function UIAnimManager.GetPathStringFromUIObject(obj)
--
--function UIAnimManager.GetUIObjectFromPathString(path)
