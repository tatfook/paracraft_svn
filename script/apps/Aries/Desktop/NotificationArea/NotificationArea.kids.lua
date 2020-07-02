--[[
Title: Desktop Notification Area for Aries App 
Author(s): WangTian
Date: 2009/4/7
Desc: See Also: script/apps/Aries/Desktop/AriesDesktop.lua
Time magazine, private messages, emails, etc. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/NotificationArea.lua");
MyCompany.Aries.Desktop.NotificationArea.Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Mail/MailBox.lua");
local MailBox = commonlib.gettable("MyCompany.Aries.Mail.MailBox");
NPL.load("(gl)script/apps/Aries/Desktop/NotificationArea/NPCTipsPage.lua");
local NPCTipsPage = commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea.NPCTipsPage");
NPL.load("(gl)script/apps/Aries/Books/TimesMagazine/TimesMagazineCabinet.lua");
NPL.load("(gl)script/apps/Aries/Desktop/NotificationArea/NPCTips_GiftBox.lua");
local NPCTips_GiftBox = commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea.NPCTips_GiftBox");
			
NPL.load("(gl)script/ide/Encoding.lua");
local Encoding = commonlib.gettable("commonlib.Encoding");
-- create class
local libName = "AriesDesktopNotificationArea";
local NotificationArea = commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea");
local auto_check_mail_interval = 120000;

-- TimesMagazine url
NotificationArea.TimesMagazine_url = MyCompany.Aries.Books.TimesMagazineCabinet.GetLastUrl();

-- user interface and logics are automatically created using this configuration table. 
local icon_settings = {
	[1] = {
		name="Mail",
		button_name = "mail", 
		MessageNodes = nil,
		-- true to play bounce animation when new message arrives
		bBounceOnReceive = false,
		-- function or type
		onclick = "MyCompany.Aries.Desktop.NotificationArea.OnClickNote", 
		width=51,
		height=45,
		animstyle=23,
		tooltip = "邮件",
		background = "Texture/Aries/Dock/Web/Mail_32bits.png;0 0 51 45",
	},
	[2] = {
		name="Feed",
		button_name = "feed", 
		MessageNodes = {{node_name="RequestRootNode"}, {node_name="StoryRootNode", nopass_types={["request_accept"]=true}}},
		-- true to play bounce animation when new message arrives
		bBounceOnReceive = true,
		-- function or type
		onclick = "MyCompany.Aries.Desktop.NotificationArea.OnClickMSG", 
		width=48,
		height=43,
		animstyle=23,
		tooltip = "消息",
		background = "Texture/Aries/Dock/Web/Feed_32bits.png; 0 0 48 43",
	},
	[3] = {
		name="Telephone",
		button_name = "telephone", 
		MessageNodes = {{node_name="TelephoneMSGRootNode"}},
		-- true to play bounce animation when new message arrives
		bBounceOnReceive = false,
		-- function or type
		onclick = "MyCompany.Aries.Desktop.NotificationArea.OnClickTelephoneMSG", 
		width=50,
		height=50,
		animstyle=23,
		tooltip = "呼叫",
		background = "Texture/Aries/Dock/Web/Telephone_32bits.png; 0 0 50 50",
	},
	[4] = {
		name="FamilyChat",
		button_name = "FamilyChat", 
		MessageNodes = {{node_name="FamilyChatMSGRootNode", }},
		-- true to play bounce animation when new message arrives
		bBounceOnReceive = false,
		-- function or type
		onclick = "MyCompany.Aries.Desktop.NotificationArea.OnClickMSG", 
		width=50,
		height=50,
		animstyle=23,
		tooltip = "家族聊天",
		background = "Texture/Aries/Dock/Web/Telephone_32bits.png; 0 0 50 50",
	},
	[5] = {
		name="FamilyJoinRequest",
		button_name = "FamilyJoinRequest", 
		MessageNodes = { {node_name="StoryRootNode", pass_types={["request_accept"]=true}}, },
		-- true to play bounce animation when new message arrives
		bBounceOnReceive = true,
		-- function or type
		onclick = "MyCompany.Aries.Desktop.NotificationArea.OnClickMSG", 
		width=48,
		height=43,
		animstyle=23,
		tooltip = "家族申请",
		background = "Texture/Aries/Dock/Web/Feed_32bits.png; 0 0 48 43",
	},
}
if(System.options.version and System.options.version == "teen")then
	icon_settings = {
	[1] = {
		name="Feed",
		button_name = "feed", 
		MessageNodes = {{node_name="RequestRootNode"}, {node_name="StoryRootNode", nopass_types={["request_accept"]=true}}},
		-- true to play bounce animation when new message arrives
		bBounceOnReceive = true,
		-- function or type
		onclick = "MyCompany.Aries.Desktop.NotificationArea.OnClickMSG", 
		width=32,
		height=43,
		animstyle=23,
		tooltip = "消息",
		background = "Texture/Aries/Dock/Web/Feed_32bits.png; 0 0 48 43",
	},
	[2] = {
		name="Telephone",
		button_name = "telephone", 
		MessageNodes = {{node_name="TelephoneMSGRootNode"}},
		-- true to play bounce animation when new message arrives
		bBounceOnReceive = false,
		-- function or type
		onclick = "MyCompany.Aries.Desktop.NotificationArea.OnClickTelephoneMSG", 
		width=50,
		height=50,
		animstyle=23,
		tooltip = "呼叫",
		background = "Texture/Aries/Dock/Web/Telephone_32bits.png; 0 0 50 50",
	},
}
end

-- get parent container
function NotificationArea.GetParentContainer()
	local notification = ParaUI.GetUIObject("NotificationArea");
	if(notification:IsValid()) then
		return notification;
	end
end

-- virtual function: create UI
function NotificationArea.Create()
	local _notification = ParaUI.CreateUIObject("container", "NotificationArea", "_lt", 4, 4, 440, 64);
	_notification.background = "";
	_notification:GetAttributeObject():SetField("ClickThrough", true);
	--_notification.onframemove = ";MyCompany.Aries.Desktop.NotificationArea.OnNotificationFramemove();";
	_notification:AttachToRoot();
	
	local _magazine = ParaUI.CreateUIObject("button", "Magazine", "_lt", 0, 0, 52, 51);
	_magazine.background = "Texture/Aries/Dock/Web/Magazine_32bits.png; 0 0 52 51";
	_magazine.animstyle = 23;
	_magazine.onclick = ";MyCompany.Aries.Desktop.NotificationArea.OnClickMagazine();";
	_magazine.tooltip = "哈奇月刊";
	_notification:AddChild(_magazine);
	
	-- show new magazine after 10 minutes
	NotificationArea.news_timer = NotificationArea.news_timer or commonlib.Timer:new({callbackFunc = function(timer)
		local lastReadTimesMagazine = MyCompany.Aries.app:ReadConfig("LastReadTimesMagazine_"..System.App.profiles.ProfileManager.GetNID(), nil);
		if(lastReadTimesMagazine ~= NotificationArea.TimesMagazine_url) then
			NotificationArea:DispatchEvent({type = "has_unread_magazine" , TimesMagazine_url = NotificationArea.TimesMagazine_url});
		end
		timer:Change();
	end})
	NotificationArea.news_timer:Change(600000, nil);

	local NotificationArea = commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea");
	NotificationArea:AddEventListener("has_unread_magazine", function()
			if(NotificationArea.IsFunctionAvailable("magazine"))then
				local lastReadTimesMagazine = MyCompany.Aries.app:ReadConfig("LastReadTimesMagazine_"..System.App.profiles.ProfileManager.GetNID(), nil);
				if(lastReadTimesMagazine ~= NotificationArea.TimesMagazine_url) then
					local _newMagazineAvaiable = ParaUI.CreateUIObject("container", "NewMagazineAvaiable", "_lt", 20, 30, 64, 32);
					_newMagazineAvaiable.background = "Texture/Aries/Dock/NEW_magazine_32bits.png";
					_newMagazineAvaiable.enabled = false;
					_notification:AddChild(_newMagazineAvaiable);
			
					local fileName = "script/UIAnimation/CommonIcon.lua.table";
					UIAnimManager.LoadUIAnimationFile(fileName);
					UIAnimManager.PlayUIAnimationSequence(_magazine, fileName, "Bounce", true);
				end
			end
		end, NotificationArea, "NotificationArea");
	NotificationArea:AddEventListener("magazine_opened", function()
			if(ParaUI.GetUIObject("NewMagazineAvaiable"):IsValid() == true) then
				MyCompany.Aries.app:WriteConfig("LastReadTimesMagazine_"..System.App.profiles.ProfileManager.GetNID(), NotificationArea.TimesMagazine_url);
				ParaUI.Destroy("NewMagazineAvaiable");
				
				local _notification = ParaUI.GetUIObject("NotificationArea");
				if(_notification and _notification:IsValid() == true) then
					local _magazine = _notification:GetChild("Magazine");
					if(_magazine and _magazine:IsValid() == true) then
						local fileName = "script/UIAnimation/CommonIcon.lua.table";
						UIAnimManager.LoadUIAnimationFile(fileName);
						UIAnimManager.StopLoopingUIAnimationSequence(_magazine, fileName, "Bounce");
					end
				end
			end
		end, NotificationArea, "NotificationArea");
	
	-- now create each button according to button settings
	local index, btnInfo
	for index, btnInfo in ipairs(icon_settings) do
		local _button = ParaUI.CreateUIObject("button", btnInfo.name, "_lt", (52 + 20)*index, 0, btnInfo.width or 50, btnInfo.height or 50);
		_button.background = btnInfo.background;
		if(btnInfo.animstyle) then
			_button.animstyle = btnInfo.animstyle;
		end
		if(type(btnInfo.onclick) == "string") then
			btnInfo.onclick = commonlib.getfield(btnInfo.onclick);
		end
		local btnInfo_ = btnInfo;
		_button:SetScript("onclick", function()
			if(type(btnInfo_.onclick) == "function") then
				btnInfo_.onclick(btnInfo_.MessageNodes, btnInfo_.name);
			end
		end);
		
		_notification:AddChild(_button);
		_button.visible = false;
		_button.tooltip = btnInfo.tooltip or "消息";
		local _btnUnreadNum = ParaUI.CreateUIObject("button", btnInfo.name.."UnreadNum", "_lt", (52 + 20)*index +52 - 16, 30, 32, 32);
		_btnUnreadNum.background = "Texture/Aries/Dock/UnreadNum_32bits.png";
		_btnUnreadNum.text = "0";
		_btnUnreadNum.font = System.DefaultLargeBoldFontString;
		_guihelper.SetFontColor(_btnUnreadNum, "0 124 2");
		_guihelper.SetUIColor(_btnUnreadNum, "255 255 255");
		_btnUnreadNum.enabled = false;
		_notification:AddChild(_btnUnreadNum);
		_btnUnreadNum.visible = false;
		

		if(btnInfo.name == "Mail")then
			NotificationArea.CheckEmail(30000);

			_button.visible = true;

			-- unread email count. 
			NPL.load("(gl)script/apps/Aries/Mail/MailBox.lua");
			MyCompany.Aries.Mail.MailBox:AddEventListener("unread_mail_change", function(self, event)
				if(event.unread_mail) then
					NotificationArea.ShowNoteBtn(true,event.unread_mail or 0)
				end
			end, NotificationArea, "NotificationArea");
		end
	end
	
	-- init note's window
	NPL.load("(gl)script/apps/Aries/Mail/MailClient.lua");
	MyCompany.Aries.Quest.Mail.MailClient.Init();
end

-- the new kids theme. 
function NotificationArea.CreateV2()
	local _notification = ParaUI.CreateUIObject("container", "NotificationArea", "_lt", 210, 10, 320, 64);
	_notification.background = "";
	_notification:SetField("ClickThrough", true);
	_notification:AttachToRoot();
	if(System.options.IsMobilePlatform) then
		--_notification:SetField("SelfPaint", true);
	end
	
	-- now create each button according to button settings
	local index, btnInfo
	for index, btnInfo in ipairs(icon_settings) do
		local _button = ParaUI.CreateUIObject("button", btnInfo.name, "_rt", (-32*index)-10, 0, 32, 32);
		_button.background = btnInfo.background;
		if(btnInfo.animstyle) then
			_button.animstyle = btnInfo.animstyle;
		end
		if(type(btnInfo.onclick) == "string") then
			btnInfo.onclick = commonlib.getfield(btnInfo.onclick);
		end
		local btnInfo_ = btnInfo;
		_button:SetScript("onclick", function()
			if(type(btnInfo_.onclick) == "function") then
				btnInfo_.onclick(btnInfo_.MessageNodes, btnInfo_.name);
			end
		end);
		
		_notification:AddChild(_button);
		_button.visible = false;
		_button.tooltip = btnInfo.tooltip or "消息";
		local _btnUnreadNum = ParaUI.CreateUIObject("button", btnInfo.name.."UnreadNum", "_rt", (-32*index), 20, 20, 20);
		_btnUnreadNum.background = "Texture/Aries/Dock/UnreadNum_32bits.png";
		_btnUnreadNum.text = "0";
		_btnUnreadNum.font = System.DefaultLargeBoldFontString;
		_guihelper.SetFontColor(_btnUnreadNum, "0 124 2");
		_guihelper.SetUIColor(_btnUnreadNum, "255 255 255");
		_btnUnreadNum.enabled = false;
		_notification:AddChild(_btnUnreadNum);
		_btnUnreadNum.visible = false;
	end
	local test_magazine_animation = false;
	NotificationArea.news_timer = NotificationArea.news_timer or commonlib.Timer:new({callbackFunc = function(timer)
		local lastReadTimesMagazine = MyCompany.Aries.app:ReadConfig("LastReadTimesMagazine_"..System.App.profiles.ProfileManager.GetNID(), nil);
		if(test_magazine_animation or lastReadTimesMagazine ~= NotificationArea.TimesMagazine_url) then
			NotificationArea:DispatchEvent({type = "has_unread_magazine" , TimesMagazine_url = NotificationArea.TimesMagazine_url});
		end
		timer:Change();
	end})
	NotificationArea.news_timer:Change(if_else(test_magazine_animation, 1000, 600000), nil);

	-- init note's window
	NPL.load("(gl)script/apps/Aries/Mail/MailClient.lua");
	MyCompany.Aries.Quest.Mail.MailClient.Init();
end

function NotificationArea.ResetPosition()
end

local MSGTYPE = commonlib.gettable("MyCompany.Aries.Desktop.MSGTYPE");

local function_available_map = 
{
	["magazine"] = true,
	--["mail"] = true,
	--["feed"] = true,
	--["telephone"] = true,
}

-- @param sFuncName: one of the function_available_map keys, such as "magazine"
function NotificationArea.IsFunctionAvailable(sFuncName)
end

-- virtual function: Desktop window handler
function NotificationArea.MSGProc(msg)
	if(msg.type == MSGTYPE.ON_LEVELUP or msg.type == MSGTYPE.ON_ACTIVATE_DESKTOP) then
		local level = msg.level;
		local bNeedRefresh;
		if(level>6) then
			-- do nothing
			local name, bAvailable
			for name, bAvailable in pairs(function_available_map) do
				if(not bAvailable) then
					function_available_map[name] = true;
					bNeedRefresh = true;
				end
			end
		else
			function_available_map["magazine"] = (level>=4);
			bNeedRefresh = true;
		end
		if(bNeedRefresh) then
			NotificationArea.RefreshAvailableFunctions();
		end
		if(msg.type == MSGTYPE.ON_LEVELUP) then
			NPCTipsPage.OnLevelup(level);
		elseif(msg.type == MSGTYPE.ON_ACTIVATE_DESKTOP) then
			NPCTips_GiftBox.TryPushGifts();
		end
	end
end

function NotificationArea.RefreshAvailableFunctions()
	local name, bAvailable
	for name, bAvailable in pairs(function_available_map) do
		NotificationArea.SetButtonEnabled(name, bAvailable);
	end
end
-- set notification button enabled
-- mainly for idle mode
function NotificationArea.SetButtonEnabled(type, enabled)
	local uiobj_name;
	if(type == "magazine") then
		uiobj_name = "Magazine";
	elseif(type == "mail") then
		uiobj_name = "Mail";
	elseif(type == "feed") then
		uiobj_name = "Feed";
	elseif(type == "telephone") then
		uiobj_name = "Telephone";
	end
	if(uiobj_name) then
		local _notification = ParaUI.GetUIObject("NotificationArea");
		if(_notification and _notification:IsValid() == true) then
			local _magazine = _notification:GetChild(uiobj_name);
			_magazine.enabled = enabled;
		end
	end
end

-- refresh the message count in UI. 
-- @param name: which channel to refresh, such as "Feed", "Telephone"
function NotificationArea.RefreshMessageCount(name)
	local index, btnInfo
	for index, btnInfo in ipairs(icon_settings) do
		if((btnInfo.name == name or btnInfo.button_name == name) and btnInfo.MessageNodes) then
			local button_name = btnInfo.name;
			-- refresh the request count of the request icon
			local _notification = ParaUI.GetUIObject("NotificationArea");
			if(_notification:IsValid()) then
				local _button = _notification:GetChild(button_name);
				local _UnreadNum = _notification:GetChild(button_name.."UnreadNum");

				-- count unread feeds
				local countUnread = 0;

				local _, node_info;
				for  _, node_info in ipairs(btnInfo.MessageNodes) do
					local rootNodeName = node_info.node_name;
					local filter = node_info.filter;
					local pass_types = node_info.pass_types;
					local nopass_types = node_info.nopass_types;
					-- count unread messages
					local rootNode = NotificationArea[rootNodeName];
					if(rootNode) then
						local count = rootNode:GetChildCount();
						local i;
						for i = 1, count do
							local node = rootNode:GetChild(i);
							if( node.bShown ~= true 
								and (not filter or (node.commandName or ""):match(filter)) 
								and (not pass_types or pass_types[node.type or node.msg_type]) 
								and (not nopass_types or not nopass_types[node.type or node.msg_type])) then

								countUnread = countUnread + (node.count or 1);
							end
						end
					end
				end
				if(btnInfo.name == "Mail")then
					countUnread = countUnread + (MyCompany.Aries.Mail.MailBox.UnReadMail or 0)
				end

				if(countUnread == 0) then
					_button.visible = false;
					_UnreadNum.visible = false;
					_UnreadNum.text = "0";
				else
					if(btnInfo.bBounceOnReceive) then
						-- flash if increase
						if(tonumber(_UnreadNum.text) and countUnread > tonumber(_UnreadNum.text)) then
							UIAnimManager.PlayCustomAnimation(1600, function(elapsedTime)
								local _notification = ParaUI.GetUIObject("NotificationArea");
								if(_notification:IsValid()) then
									local _button = _notification:GetChild(button_name);
									local _UnreadNum = _notification:GetChild(button_name.."UnreadNum");
									local alpha = math.mod(elapsedTime, 300);
									if(alpha <= 150) then
										alpha = 0;
									elseif(alpha <= 300) then
										alpha = 255;
									end
									_button.color = "255 255 255 "..alpha;
									if(elapsedTime == 1600) then
										_button.color = "255 255 255 255";
									end
								end
							end);
						end
					else
						_button.color = "255 255 255 255";
					end
					_button.visible = true;
					_UnreadNum.visible = true;
					_UnreadNum.text = tostring(countUnread);
				end
			end
		end
	end
end

-- refresh request count on every server proxy response
function NotificationArea.RefreshFeedCount()
	NotificationArea.RefreshMessageCount("Feed");
	NotificationArea.RefreshMessageCount("FamilyJoinRequest");
end

-- virtual function: refresh request count on every server proxy response
function NotificationArea.RefreshTelephoneCount()
	NotificationArea.RefreshMessageCount("Telephone")
end

-- virtual function: 
function NotificationArea.ShowNoteBtn(bShow,cnt)
	--local noteBtn = ParaUI.GetUIObject("Mail");
	--always display mail button
	--[[if(noteBtn:IsValid())then
		noteBtn.visible = bShow;
	end
	]]
	--local noteUnreadNum  = ParaUI.GetUIObject("MailUnreadNum");
	--if(noteUnreadNum:IsValid())then
		--if(cnt == (0 or "0"))then
			--noteUnreadNum.text = ""
			--noteUnreadNum.visible = false;
		--else
			--noteUnreadNum.text = tostring(cnt);
			--noteUnreadNum.visible = bShow;
		--end
	--end
	MyCompany.Aries.Mail.MailBox.RefreshGlobalUI();
end

-- automatically check email after nTimeToStart milliseconds
function NotificationArea.CheckEmail(nTimeToStart)
	if(NotificationArea.mail_timer) then
		NotificationArea.mail_timer:Change(nTimeToStart or 30000,auto_check_mail_interval);
	else
		NotificationArea.mail_timer = commonlib.Timer:new({callbackFunc = function(timer)
			if(MailBox.SendUnReadMailNotification)then
				MailBox.SendUnReadMailNotification()
			else
				NotificationArea.mail_timer:Change();		
			end
		end});
		NotificationArea.mail_timer:Change(nTimeToStart or 30000,auto_check_mail_interval);
	end
end

-- virtual function: 
function NotificationArea.OnClickNote()
	NPL.load("(gl)script/apps/Aries/Mail/MailManager.lua");

	
	if(MyCompany.Aries.Quest.Mail.MailManager.HasMail())then
		MyCompany.Aries.Quest.Mail.MailManager.ShowMail();
	else
		NotificationArea.CheckEmail(0);
		MyCompany.Aries.Mail.MailBox.ShowPage();
	end
	NotificationArea.ShowNoteBtn(true,MyCompany.Aries.Desktop.NotificationArea.UnReadMail or 0)
end

function NotificationArea.OnClickMagazine()
	if(mouse_button~="right") then
		-- ParaGlobal.ShellExecute("open", "http://www.paracraft.cn/archives/1121", "", "", 1);
		ParaGlobal.ShellExecute("open", "https://times.keepwork.com/latest", "", "", 1);
	else
		NPL.load("(gl)script/apps/Aries/Books/TimesMagazine/TimesMagazineCabinet.lua");
		MyCompany.Aries.Books.TimesMagazineCabinet.ShowPage();
	end
	--_guihelper.MessageBox("是否打开《哈奇月刊》图书馆? <br/>(点'否'将打开新闻页面)", function(res)
		--if(res and res == _guihelper.DialogResult.Yes) then
			--NPL.load("(gl)script/apps/Aries/Books/TimesMagazine/TimesMagazineCabinet.lua");
			--MyCompany.Aries.Books.TimesMagazineCabinet.ShowPage();
		--elseif(res == _guihelper.DialogResult.No) then
			--ParaGlobal.ShellExecute("open", "http://www.paracraft.cn/archives/1121", "", "", 1);
		--end
	--end, _guihelper.MessageBoxButtons.YesNoCancel);
end

-- virtual function: 
function NotificationArea.OnClickMagazineImp()
	local url = NotificationArea.TimesMagazine_url;
	
	NPL.load("(gl)script/apps/Aries/Books/BookPreloadAssets.lua");
	--local download_list = MyCompany.Aries.Books.BookPreloadAssets.GetAssetList(url);

	local download_list = MyCompany.Aries.Books.TimesMagazineCabinet.PreInitLast();
	
	NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/PreLoaderDialog.lua");
	commonlib.echo("=============before TimesMagazine");
	Map3DSystem.App.MiniGames.PreLoaderDialog.StartDownload({download_list = download_list,txt = {"正在打开时报，请稍等......"}},function(msg)
	commonlib.echo("=============after TimesMagazine");
		commonlib.echo(msg);
		if(msg and msg.state == "finished")then
			
			-- call hook for OnOpenTimeMagazine
			local msg = { aries_type = "OnOpenTimeMagazine", gsid = gsid, count = count, wndName = "main"};
			CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
			
			-- TODO: dirty code to show the empty magazine
			System.App.Commands.Call("File.MCMLWindowFrame", {
				-- url = "script/apps/Aries/Books/TimesMagazine/TimesMagazine_v1.html", 
				url = url, 
				name = "TimesMagazine", 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 2,
				allowDrag = false,
				directPosition = true,
					align = "_ct",
						x = -960/2+50,
						y = -560/2+20,
						width = 960,
						height = 560,
			});
			MyCompany.Aries.app:WriteConfig("LastReadTimesMagazine_"..System.App.profiles.ProfileManager.GetNID(), NotificationArea.TimesMagazine_url);
			NotificationArea:DispatchEvent({type = "magazine_opened" , TimesMagazine_url = NotificationArea.TimesMagazine_url});
		end
	end)
	
	-- send log information
	paraworld.PostLog({action = "misc_read_timemagazine_log", url = url}, 
		"misc_read_timemagazine_log", function(msg)
	end);
end
