--[[
Title: 
Author(s): zrf
Date: 2011/3/9
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/BBSChat/ChatWindow.lua");
MyCompany.Aries.ChatWindow.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/BBSChat/ChatChannel.lua");

local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatChannel");
local ChatWindow = commonlib.gettable("MyCompany.Aries.ChatWindow");

ChatWindow.pCurChannel = 1;

-- show the page
function ChatWindow.ShowPage()
	local dockReservedHeight = commonlib.getfield("MyCompany.Aries.Desktop.Dock.ReservedHeight") or 40;
	
	if(not ChatWindow.bcreated)then
		ChatWindow.bcreated = true;
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/BBSChat/ChatWindow.html", 
			app_key = MyCompany.Aries.app.app_key, 
			name = "ChatWindow.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = false,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = false,
			click_through = true,
			zorder = 20,
			directPosition = true,
				align = "_ct",
				x = -450/2,
				y = -300/2,
				width = 450,
				height = 300,
		});
		ChatChannel.SetAppendEventCallback(ChatWindow.AppendChatMessage);
	else
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="ChatWindow.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				bShow = true,bDestroy = false,});		
	end
	ChatWindow.is_shown = true;

	-- this will refresh the current channel if needed. 
	--ChatWnd.RefreshTreeView();
end

function ChatWindow.Init()
	ChatWindow.page = document:GetPageCtrl();
end

function ChatWindow.CreateTreeView(param, mcmlNode)

    local _this = ParaUI.CreateUIObject("container", "chatwindow_tvcon", "_lt", param.left,param.top,param.width,param.height);
	_this.background = "";
	_this:GetAttributeObject():SetField("ClickThrough", true);
	param.parent:AddChild(_this);

	local ctl = ChatWindow.GetTreeView(_this, param.width, param.height);
	-- the second parameter will scroll tot the last element. 
	ctl:Show(true, nil,  true);
end

function ChatWindow.GetTreeView(parent, width, height)
	local ctl = CommonCtrl.GetControl("ChatWindow.GetTreeView");
	if(not ctl)then
		ctl = CommonCtrl.TreeView:new{
			name = "ChatWindow.GetTreeView",
			alignment = "_lt",
			left = 0,
			top = 0,
			width = width or 400,
			height = height or 250,
			parent = parent,
			container_bg = nil,
			DefaultIndentation = 5,
			NoClipping = false,
			ClickThrough = true,
			DefaultNodeHeight = 20,
			VerticalScrollBarStep = 20,
			VerticalScrollBarPageSize = 20 * 5,
			NoClipping = false,
			HideVerticalScrollBar = false, -- true
				
			DrawNodeHandler = function (_parent, treeNode)
				if(_parent == nil or treeNode == nil) then
					return;
				end
				local _this;
				local height = 20; -- just big enough
				local nodeWidth = treeNode.TreeView.ClientWidth;
				local oldNodeHeight = treeNode:GetHeight();

				local mcmlStr = treeNode.chatdata.words;
				if(mcmlStr ~= nil) then
					--mcmlStr = ParaMisc.EncodingConvert("", "HTML", mcmlStr);

					local xmlRoot = ParaXML.LuaXML_ParseString(mcmlStr);
					if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
						local xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
							
						local myLayout = Map3DSystem.mcml_controls.layout:new();
						myLayout:reset(0, 0, nodeWidth, height);
						Map3DSystem.mcml_controls.create("bbs_lobby", xmlRoot, nil, _parent, 0, 0, nodeWidth, height,nil, myLayout);
						local usedW, usedH = myLayout:GetUsedSize()
						if(usedH>height) then
							return usedH;
						end
					end
				end
			end,
		};
	elseif(parent)then
		ctl.parent = parent;
	end
	return ctl;
end

function ChatWindow.AppendChatMessage(chatdata,needrefresh)
	if(chatdata==nil or type(chatdata)~="table")then
		commonlib.echo("error: chatdata 不可为空 in ChatWindow.AppendChatMessage");
		return;
	end

	--commonlib.echo("!!:ChatWindow.AppendChatMessage");
	
	local ctl = ChatWindow.GetTreeView();
	local rootNode = ctl.RootNode;
	
	if(rootNode:GetChildCount() > 200) then
		rootNode:RemoveChildByIndex(1);
	end

	rootNode:AddChild(CommonCtrl.TreeNode:new({
			Name = "text", 
			chatdata = chatdata,
		}));

	if(needrefresh)then
		ChatWindow.RefreshTreeView();
	end
end

function ChatWindow.OnClickTab(name)
	name = tonumber(name);
	local chatdata;
	if(name==0)then
		chatdata = ChatChannel.GetChat({1,2,3,4,5,6,7,8,});
	else
		chatdata = ChatChannel.GetChat(name);		
	end

	--commonlib.echo("!!:OnClickTab");
	--commonlib.echo(name);
--
	--commonlib.echo(chatdata);

	local ctl = CommonCtrl.GetControl("ChatWindow.GetTreeView");
	if(ctl and ctl.RootNode and ctl.RootNode:GetChildCount()>0 )then
		ctl.RootNode:ClearAllChildren();
	end

	local i;
	for i=1,#chatdata do
		local tmp = chatdata[i];
		ChatWindow.AppendChatMessage(tmp);
	end

	ChatWindow.RefreshTreeView();
end

function ChatWindow.RefreshTreeView()
	if(ChatWindow.page and ChatWindow.is_shown ) then

		local ctl = ChatWindow.GetTreeView();
		if(ctl) then
			-- tricky: this will tells us whether the treeview's container UI is created. 
			local parent = ParaUI.GetUIObject("chatwindow_tvcon");
			if(parent:IsValid())then
				ctl.parent = parent;
				ctl:Update(true);
				--commonlib.echo("!!:RefreshTreeView");
			end
		end
	end
end

function ChatWindow.Hide()
	if(ChatWindow.page)then
		ChatWindow.page:CloseWindow();
	end
	ChatWindow.is_shown = false;
end