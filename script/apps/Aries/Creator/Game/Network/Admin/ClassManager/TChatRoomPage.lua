﻿--[[
Title: Class List 
Author(s): Chenjinxian
Date: 2020/7/6
Desc: 
use the lib:
-------------------------------------------------------
local TChatRoomPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Admin/ClassManager/TChatRoomPage.lua");
TChatRoomPage.ShowPage()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/SmileyPage.lua");
local SmileyPage = commonlib.gettable("MyCompany.Aries.ChatSystem.SmileyPage");
local ClassManager = NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Admin/ClassManager/ClassManager.lua");
local TChatRoomPage = NPL.export()

local page;

function TChatRoomPage.OnInit()
	page = document:GetPageCtrl();
end

function TChatRoomPage.ShowPage(onClose)
	TChatRoomPage.result = false;
	local params = {
		url = "script/apps/Aries/Creator/Game/Network/Admin/ClassManager/TChatRoomPage.html", 
		name = "TChatRoomPage.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		enable_esc_key = true,
		click_through = true, 
		app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
		directPosition = true,
		align = "_ct",
		x = -750 / 2,
		y = -533 / 2,
		width = 750,
		height = 533,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);

	params._page.OnClose = function()
		if(onClose) then
			onClose(TChatRoomPage.result);
		end
	end
end

function TChatRoomPage.Refresh()
	if (page) then
		ClassManager.LoadClassroomInfo(ClassManager.CurrentClassroomId, function(classId, projectId, roomId)
			page:CloseWindow();
			TChatRoomPage.ShowPage();
		end);
	end
end

function TChatRoomPage.OnClose()
	TChatRoomPage.result = true;
	page:CloseWindow();
end

function TChatRoomPage.GetClassName()
	return ClassManager.ClassNameFromId(ClassManager.CurrentClassId);
end

function TChatRoomPage.GetClassPeoples()
	return L"班级成员 10/20";
end

function TChatRoomPage.InviteAll()
end

function TChatRoomPage.InviteOne()
end

function TChatRoomPage.ClassItems()
	local items = {};
	for i = 1, #ClassManager.StudentList do
		local member = ClassManager.StudentList[i];
		items[i] = {name = member.user.username, teacher = member.user.tLevel == 1, online = member.online};
	end
	return items;
end

function TChatRoomPage.GetShortName(name)
	local len = commonlib.utf8.len(name);
	if (len > 2) then
		return commonlib.utf8.sub(name, len-1);
	else
		return name;
	end
	return name;
end

function TChatRoomPage.SendMessage()
	local text = page:GetValue("MessageText", nil);
	if (text and text ~= "") then
		ClassManager.SendMessage("msg:"..text);
		page:SetValue("MessageText", "");
		page:Refresh(0);
	else
		--_guihelper.MessageBox(L"");
	end
end

function TChatRoomPage.AppendChatMessage(chatdata, needrefresh)
	if(chatdata==nil or type(chatdata)~="table")then
		commonlib.echo("error: chatdata 不可为空 in TChatRoomPage.AppendChatMessage");
		return;
	end

	local ctl = TChatRoomPage.GetTreeView();
	local rootNode = ctl.RootNode;
	
	if(rootNode:GetChildCount() > ClassManager.ChatDataMax) then
		rootNode:RemoveChildByIndex(1);
	end

	rootNode:AddChild(CommonCtrl.TreeNode:new({
		Name = "text", 
		chatdata = chatdata,
	}));

	if(needrefresh)then
		TChatRoomPage.RefreshTreeView();
	end
end

function TChatRoomPage.CreateTreeView(param, mcmlNode)
	local _container = ParaUI.CreateUIObject("container", "SChatRoomPage_tvcon", "_lt", param.left,param.top,param.width,param.height);
	_container.background = "";
	_container:GetAttributeObject():SetField("ClickThrough", false);
	param.parent:AddChild(_container);
	
	-- create get the inner tree view
	local ctl = TChatRoomPage.GetTreeView(nil, _container, 0, 0, param.width, param.height);
	ctl:Show(true, nil, true);
end

function TChatRoomPage.DrawTextNodeHandler(_parent, treeNode)
	if(_parent == nil or treeNode == nil) then
		return;
	end

	local mcmlStr = ClassManager.MessageToMcml(treeNode.chatdata);
	if(mcmlStr ~= nil) then
		local xmlRoot = ParaXML.LuaXML_ParseString(mcmlStr);
		if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
			local xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
							
			local height = 12; -- just big enough
			local nodeWidth = treeNode.TreeView.ClientWidth;
			local myLayout = Map3DSystem.mcml_controls.layout:new();
			myLayout:reset(0, 0, nodeWidth-5, height);
			Map3DSystem.mcml_controls.create("bbs_lobby", xmlRoot, nil, _parent, 0, 0, nodeWidth-5, height,nil, myLayout);
			local usedW, usedH = myLayout:GetUsedSize()
			if(usedH>height) then
				return usedH;
			end
		end
	end
end

function TChatRoomPage.GetTreeView(name, parent, left, top, width, height, NoClipping)
	name = name or "TChatRoomPage.TreeView"
	local ctl = CommonCtrl.GetControl(name);
	if(not ctl)then
		left = left or 0;
		left = left + 5;
		ctl = CommonCtrl.TreeView:new{
			name = name,
			alignment = "_lt",
			left = left,
			top = top or 0,
			width = width or 480,
			height = height or 330,
			parent = parent,
			container_bg = nil,
			DefaultIndentation = 2,
			NoClipping = NoClipping==true,
			ClickThrough = false,
			DefaultNodeHeight = 14,
			VerticalScrollBarStep = 14,
			VerticalScrollBarPageSize = 14 * 5,
			VerticalScrollBarWidth = 10,
			HideVerticalScrollBar = false,
			DrawNodeHandler = TChatRoomPage.DrawTextNodeHandler,
		};
	elseif(parent)then
		ctl.parent = parent;
	end

	if(width)then
		ctl.width = width;
	end

	if(height)then
		ctl.height= height;
	end

	if(left)then
		ctl.left= left;
	end

	if(top)then
		ctl.top = top;
	end
	return ctl;
end

function TChatRoomPage.RefreshTreeView()
	if (page) then
		local ctl = TChatRoomPage.GetTreeView();
		if(ctl) then
			local parent = ParaUI.GetUIObject("SChatRoomPage_tvcon");
			if(parent:IsValid())then
				ctl.parent = parent;
				ctl:Update(true);
			end
		end
	end
end

