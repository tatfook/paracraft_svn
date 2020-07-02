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
NPL.load("(gl)script/apps/Aries/Books/TimesMagazine/TimesMagazineCabinet.lua");
NPL.load("(gl)script/ide/Encoding.lua");
local Encoding = commonlib.Encoding;
-- create class
local libName = "AriesDesktopNotificationArea";
local NotificationArea = commonlib.inherit(commonlib.EventSystem, commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea"));
NotificationArea:ctor();

-- data keeping
-- current tabs of chat window
NotificationArea.TelephoneMSGRootNode = CommonCtrl.TreeNode:new({Name = "Telephone",});
NotificationArea.FamilyChatMSGRootNode = CommonCtrl.TreeNode:new({Name = "FamilyChat",});
NotificationArea.RequestRootNode = CommonCtrl.TreeNode:new({Name = "Feed",});
NotificationArea.StoryRootNode = CommonCtrl.TreeNode:new({Name = "Feed",});

-- invoked at Desktop.InitDesktop()
function NotificationArea.Init()
	-- load implementation
	if(System.options.version=="kids") then
		NPL.load("(gl)script/apps/Aries/Desktop/NotificationArea/NotificationArea.kids.lua");
		if(System.options.theme == "v2") then
			NotificationArea.CreateV2();
		else
			NotificationArea.Create();
		end
	else
		NPL.load("(gl)script/apps/Aries/Desktop/NotificationArea/NotificationArea.teen.lua");
		NotificationArea.Create();
	end
	NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
	local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
	LobbyClientServicePage.OnInitClient();
end

local MSGTYPE = commonlib.gettable("MyCompany.Aries.Desktop.MSGTYPE");
-- virtual function: Desktop window handler
function NotificationArea.MSGProc(msg)
	if(msg.type == MSGTYPE.ON_LEVELUP) then
		local level = msg.level;
	end
end

-- public api: show or hide the notification area, toggle the visibility if bShow is nil
function NotificationArea.Show(bShow)
	local _notificationArea = ParaUI.GetUIObject("NotificationArea");
	if(_notificationArea:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _notificationArea.visible;
		end
		_notificationArea.visible = bShow;
	end
end

-- virtual function: set notification button enabled
-- mainly for idle mode
function NotificationArea.SetButtonEnabled(type, enabled)
end

-- virtual public api: refresh request count on every server proxy response
function NotificationArea.RefreshFeedCount()
end

-- virtual public api: refresh request count on every server proxy response
function NotificationArea.RefreshTelephoneCount()
end

-- virtual public api:
function NotificationArea.ShowNoteBtn(bShow,cnt)
end

-- virtual public api
function NotificationArea.OnClickNote()
end

-- virtual public api
function NotificationArea.OnClickMagazine()
end

-- public api: click a given group of message
-- @param MessageNodes: a table such as { {node_name="RequestRootNode"}, {node_name="StoryRootNode"}}
function NotificationArea.OnClickMSG(MessageNodes, btnName)
	local _, node_info;
	for  _, node_info in ipairs(MessageNodes) do
		local rootNodeName = node_info.node_name;
		local filter = node_info.filter;
		local pass_types = node_info.pass_types;
		local nopass_types = node_info.nopass_types;
		-- count unread messages
		local rootNode = NotificationArea[rootNodeName];
		if(rootNode) then
			local count = rootNode:GetChildCount();
			local i;
			for i = count, 1, -1 do
				local node = rootNode:GetChild(i);
				if( node.bShown ~= true 
					and (not filter or (node.commandName or ""):match(filter)) 
					and (not pass_types or pass_types[node.type or node.msg_type]) 
					and (not nopass_types or not nopass_types[node.type or node.msg_type])) then
					
					if(node.commandName) then
						-- remove latest contact messages, if node contains the commandName param
						rootNode:RemoveChildByName(node.Name);

						if(System.options.version ~= "kids")then
							System.App.Commands.Call(node.commandName,{JID = node.JID});
						else
							-- show the latest contact ChatWnd
							System.App.Commands.Call(node.commandName);
						end
					else
						-- otherwise, we will only mark the message as already shown, but do not remove it from the list. 
						node.bShown = true;
					end
					if(node.ShowCallbackFunc) then
						node.ShowCallbackFunc(node);
					end

					NotificationArea.RefreshMessageCount(btnName or rootNode.Name);
					return;
				end
			end
		end
	end
end

-- refresh the message count in UI. 
-- @param name: which channel to refresh, such as "Feed", "Telephone"
function NotificationArea.RefreshMessageCount(name)
end

-- public api: onclick the telephone message it will pick the latest contact in the TelephoneMSGRootNode and show the ChatWnd
function NotificationArea.OnClickTelephoneMSG()
	NotificationArea.OnClickMSG({{node_name="TelephoneMSGRootNode"}});
end

-- public api: onclick the telephone message it will pick the latest contact in the TelephoneMSGRootNode and show the ChatWnd
function NotificationArea.OnClickFamilyChatMSG()
	NotificationArea.OnClickMSG({{node_name="FamilyChatMSGRootNode"}});
end

-- public api: pick the latest request and wait for user confirmation
function NotificationArea.OnClickFeed()
	NotificationArea.OnClickMSG({{node_name="RequestRootNode"}, {node_name="StoryRootNode"}});
end

-- public api: append a new general message
-- @param msg: message to be appended
-- @param rootNodeName: if nil, it is "TelephoneMSGRootNode", it can also be "FamilyChatMSGRootNode"
-- e.g. {Name = command.name, icon = icon, nid = nid, tooltip = text, presenceicon = presenceicon, commandName = command.name}
function NotificationArea.AppendMSG(msg, rootNodeName)
	rootNodeName = rootNodeName or "TelephoneMSGRootNode";
	local rootNode = NotificationArea[rootNodeName];
	if(rootNode) then
		local node = rootNode:GetChildByName(msg.Name);
		if(node) then
			node.count = node.count + 1;
		else
			msg.count = 1;
			rootNode:AddChild(CommonCtrl.TreeNode:new(msg));
		end
	end
	NotificationArea.RefreshMessageCount(rootNode.Name);
end

-- append a feed message
-- @param type: "request"|"story"|"quest"
-- @param node: feed data node
function NotificationArea.AppendFeed(type, node)
	if(type == "request") then
		NotificationArea.RequestRootNode:AddChild(CommonCtrl.TreeNode:new(node));
	elseif(type == "story") then
		NotificationArea.StoryRootNode:AddChild(CommonCtrl.TreeNode:new(node));
	elseif(type == "family") then
		NotificationArea.FamilyChatMSGRootNode:AddChild(CommonCtrl.TreeNode:new(node));
	end
	-- automatically refresh the feed icon count
	NotificationArea.RefreshFeedCount();
end

-- get feed by its node.Name parameter. 
function NotificationArea.GetFeedByName(Name)
	-- check unshown request messages
	local count = NotificationArea.RequestRootNode:GetChildCount();
	local i;
	for i = 1, count do
		local node = NotificationArea.RequestRootNode:GetChild(i);
		if(node.bShown ~= true and node.Name == Name) then
			return commonlib.deepcopy(node);
		end
	end
	-- check unshown request messages
	local count = NotificationArea.StoryRootNode:GetChildCount();
	local i;
	for i = 1, count do
		local node = NotificationArea.StoryRootNode:GetChild(i);
		if(node.bShown ~= true and node.Name == Name) then
			return commonlib.deepcopy(node);
		end
	end
end