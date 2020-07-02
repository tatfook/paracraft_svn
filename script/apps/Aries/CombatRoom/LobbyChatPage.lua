--[[
Title:  
Author(s): leio
Date: 2011/05/04
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyChatPage.lua");
local LobbyChatPage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyChatPage");
LobbyChatPage.RefreshTreeView();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Encoding.lua");
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
NPL.load("(gl)script/apps/Aries/SlashCommand/SlashCommand.lua");

local Encoding = commonlib.gettable("commonlib.Encoding");
local SlashCommand = commonlib.gettable("MyCompany.Aries.SlashCommand.SlashCommand");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
local LobbyChatPage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyChatPage");

LobbyChatPage.name = "LobbyChatPage_instance";
-- public: call this once at init time. 
function LobbyChatPage.InitSystem()
	if(LobbyChatPage.IsInited) then
		return
	end
	LobbyChatPage.IsInited = true;
	NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatWindow.lua");
	MyCompany.Aries.ChatSystem.ChatWindow.InitSystem();
	ChatChannel.SetAppendEventCallback_LobbyChat(LobbyChatPage.AppendChatMessage);
end



-- only called by LobbyChatPage.html
function LobbyChatPage.Init()
	LobbyChatPage.page = document:GetPageCtrl();
	LobbyChatPage.InitSystem();
end

-- create the treeview for log display
function LobbyChatPage.CreateTreeView(param, mcmlNode)

    local _container = ParaUI.CreateUIObject("container", LobbyChatPage.name.."chatwindow_tvcon", "_lt", param.left,param.top,param.width,param.height);
	_container.background = "";
	_container:GetAttributeObject():SetField("ClickThrough", true);
	param.parent:AddChild(_container);

	local scrollbar_width = 16;
	local ctl = LobbyChatPage.GetTreeView(_container, scrollbar_width, 0, param.width-scrollbar_width, param.height);
	ctl:Show(true, nil, true);
	local _parentctl = ParaUI.GetUIObject(ctl.name);
	_parentctl:GetChild("main").onmousewheel = string.format(";MyCompany.Aries.CombatRoom.LobbyChatPage.OnTreeViewMouseWheel()");

	local vscrollbar = ParaUI.CreateUIObject("scrollbar", LobbyChatPage.name.."ChatWindow_CreateTreeView_VScrollBar","_ml", 0, 0, scrollbar_width, 0);
	vscrollbar.visible = true;
	vscrollbar:SetPageSize(param.height);
	vscrollbar.onchange = ";MyCompany.Aries.CombatRoom.LobbyChatPage.OnScrollBarChange()";

	local states = {[1] = "highlight", [2] = "pressed", [3] = "disabled", [4] = "normal"};
	local i;
	for i = 1, 4 do
		vscrollbar:SetCurrentState(states[i]);
		texture=vscrollbar:GetTexture("track");
		texture.texture="Texture/Aries/ChatSystem/gundongtiaobg_32bits.png;0 0 16 32";
		texture=vscrollbar:GetTexture("up_left");
		texture.texture="Texture/Aries/ChatSystem/arrow1_32bits.png;6 6 16 16";
		texture=vscrollbar:GetTexture("down_right");
		texture.texture="Texture/Aries/ChatSystem/arrow2_32bits.png;6 6 16 20";
		texture=vscrollbar:GetTexture("thumb");
		texture.texture="Texture/Aries/ChatSystem/arrow3_32bits.png;0 0 16 31";
	end
	_container:AddChild(vscrollbar);

end

function LobbyChatPage.OnTreeViewMouseWheel()
	CommonCtrl.TreeView.OnTreeViewMouseWheel("LobbyChatPage.TreeView");
	LobbyChatPage.RefreshScrollBar();
end

function LobbyChatPage.OnScrollBarChange()
	local ctl = LobbyChatPage.GetTreeView();
	local vscrollbar = ParaUI.GetUIObject(LobbyChatPage.name.."ChatWindow_CreateTreeView_VScrollBar");
	if(ctl and vscrollbar:IsValid())then
		ctl.ClientY = vscrollbar.value;
		ctl:RefreshUI();
	end
end

function LobbyChatPage.RefreshScrollBar()
	local ctl = LobbyChatPage.GetTreeView();
	local vscrollbar = ParaUI.GetUIObject(LobbyChatPage.name.."ChatWindow_CreateTreeView_VScrollBar");
	if(ctl and vscrollbar:IsValid())then
		local TreeViewHeight = ctl.height;
		-- update track range and thumb location.
		vscrollbar:SetTrackRange( 0, ctl.RootNode.LogicalBottom );
		if( ctl.VerticalScrollBarStep > ( ctl.RootNode.LogicalBottom - TreeViewHeight ) / 2 ) then
			vscrollbar:SetStep( ( ctl.RootNode.LogicalBottom - TreeViewHeight ) / 2 );
		else
			vscrollbar:SetStep( ctl.VerticalScrollBarStep );
		end		

		vscrollbar.value = ctl.ClientY;
		vscrollbar.scrollbarwidth = ctl.VerticalScrollBarWidth;
	end 
end

-- render callback for each text node in tree view. 
function LobbyChatPage.DrawTextNodeHandler(_parent, treeNode)
	if(_parent == nil or treeNode == nil) then
		return;
	end
	local _this;
	local height = 12; -- just big enough
	local nodeWidth = treeNode.TreeView.ClientWidth;
	local oldNodeHeight = treeNode:GetHeight();
	local chatdata = treeNode.chatdata;
	local fromvip = "";
	local tovip = "";
	local fromschool = "";
	local toschool="";
	local words = Encoding.EncodeStr(chatdata.words or "");
	if(chatdata.is_direct_mcml) then
		words = chatdata.words or "";
	end
	local fromname = Encoding.EncodeStr(chatdata.fromname or "");
	local toname = Encoding.EncodeStr(chatdata.toname or "");
	local color = "000000";
	--if(chatdata.fromisvip)then
		--fromvip = [[<img src="Texture/Aries/Friends/MagicStarSmall_32bits.png; 0 0 22 22" style="width:16px;height:17px;"/>]];
	--end
	--if(chatdata.toisvip)then
		--tovip = [[<img src="Texture/Aries/Friends/MagicStarSmall_32bits.png; 0 0 22 22" style="width:16px;height:17px;"/>]];
	--end

	if(chatdata.from and chatdata.fromschool )then
		fromschool = string.format([[<img src="Texture/Aries/Combat/HPSlots/%s_32bits.png; 0 0 24 24" style="margin-left:-5px;width:16px;height:16px;"/>]], chatdata.fromschool );
	end

	if(chatdata.to and chatdata.toschool )then
		toschool = string.format([[<img src="Texture/Aries/Combat/HPSlots/%s_32bits.png; 0 0 24 24" style="margin-left:-5px;width:16px;height:16px;"/>]], chatdata.toschool );
	end

	
	if(chatdata.from==System.App.profiles.ProfileManager.GetNID() and chatdata.to)then
		mcmlStr = string.format([[<div style="line-height:14px;font-size:12px;color:#%s;">[%s]你对[%s%s<a 
				tooltip="" style="margin-left:0px;float:left;height:12px;background:url()" name="x"
				onclick="" param1='%d'>
				<div style="float:left;margin-top:-2px;color:#%s;">%s</div></a><div style="float:left;margin-left:-5px;">]：%s</div></div>]],
				color, chatdata.channelname, toschool, tovip,
				chatdata.to,color, toname, words);
	elseif(chatdata.from and chatdata.to==nil)then
		mcmlStr = string.format([[<div style="line-height:14px;font-size:12px;color:#%s;">[%s][%s%s<a 
				tooltip="" style="margin-left:0px;float:left;height:12px;background:url()" name="x" 
				onclick="" param1='%d'>
				<div style="float:left;margin-top:-2px;color:#%s;">%s</div></a><div style="float:left;margin-left:-5px;">]：%s</div></div>]],
				color, chatdata.channelname, fromschool, fromvip,
				chatdata.from,color, fromname, words);
				
	elseif(chatdata.from and chatdata.to )then
		mcmlStr = string.format([[<div style="line-height:14px;font-size:12px;color:#%s;">[%s][%s%s<a 
				tooltip="" style="margin-left:0px;float:left;height:12px;background:url()" name="x" 
				onclick="" param1='%d'>
				<div style="float:left;margin-top:-2px;color:#%s;">%s</div>
				</a><div style="float:left;margin-left:-5px;">]对[</div>%s%s<a style="margin-left:0px;float:left;height:12px;background:url()" name="x" 
				tooltip="" onclick="" param1='%d'>
				<div style="float:left;margin-top:-2px;color:#%s;">%s</div></a><div style="float:left;margin-left:-5px;">]：%s</div></div>]],
				color, chatdata.channelname, fromschool, fromvip,
				chatdata.from,color, fromname, toschool, tovip,
				chatdata.to,color, toname, words);
				
	else
		mcmlStr = string.format([[<div style="line-height:16px;font-size:12px;font-weight:bold;color:#%s;">[%s]%s</div>]],color,chatdata.channelname, words);
	end

	if(mcmlStr ~= nil) then
		local xmlRoot = ParaXML.LuaXML_ParseString(mcmlStr);
		if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
			local xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
							
			local myLayout = Map3DSystem.mcml_controls.layout:new();
			myLayout:reset(0, 0, nodeWidth, height);
			Map3DSystem.mcml_controls.create("lobby_chat", xmlRoot, nil, _parent, 0, 0, nodeWidth, height,nil, myLayout);
			local usedW, usedH = myLayout:GetUsedSize()
			if(usedH>height) then
				return usedH;
			end
		end
	end
end

function LobbyChatPage.GetTreeView(parent, left, top, width, height)
	local ctl = CommonCtrl.GetControl("LobbyChatPage.TreeView");
	if(not ctl)then
		ctl = CommonCtrl.TreeView:new{
			name = "LobbyChatPage.TreeView",
			alignment = "_lt",
			left = left or 0,
			top = top or 0,
			width = width or 350,
			height = height or 200,
			parent = parent,
			container_bg = nil,
			DefaultIndentation = 2,
			NoClipping = false,
			ClickThrough = true,
			DefaultNodeHeight = 14,
			VerticalScrollBarStep = 14,
			VerticalScrollBarPageSize = 14 * 5,
			NoClipping = false,
			HideVerticalScrollBar = true,
			DrawNodeHandler = LobbyChatPage.DrawTextNodeHandler,
		};
		CommonCtrl.AddControl("LobbyChatPage.TreeView",ctl);
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

function LobbyChatPage.AppendChatMessage(chatdata,needrefresh)
	--commonlib.echo("=========LobbyChatPage.AppendChatMessage");
	--commonlib.echo(chatdata);
	if(chatdata==nil or type(chatdata)~="table")then
		commonlib.echo("error: chatdata 不可为空 in LobbyChatPage.AppendChatMessage");
		return;
	end
	if(chatdata.ChannelIndex == ChatChannel.EnumChannels.BroadCast)then
		if(chatdata.words and string.match(chatdata.words,"lobby|(.+)|lobby"))then
			NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
			local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
			local words = LobbyClientServicePage.GetLobbyCallMsg(chatdata.from,chatdata.words);
			if(not words)then
				return
			end
		end
	end
	local ctl = LobbyChatPage.GetTreeView();
	local rootNode = ctl.RootNode;
	
	if(rootNode:GetChildCount() > 200) then
		rootNode:RemoveChildByIndex(1);
	end

	rootNode:AddChild(CommonCtrl.TreeNode:new({
			Name = "text", 
			chatdata = chatdata,
		}));

	if(needrefresh)then
		LobbyChatPage.RefreshTreeView();
	end
end

function LobbyChatPage.Clear()
	local ctl = LobbyChatPage.GetTreeView();
	if(ctl)then
		local rootNode = ctl.RootNode;
		rootNode:ClearAllChildren();
	end
end

-- refresh the tree view. 
-- TODO: only refresh whenever the tree view is visible, otherwise we will postpone until it is visible again. 
function LobbyChatPage.RefreshTreeView()
	if (LobbyChatPage.page) then
		local ctl = LobbyChatPage.GetTreeView();
		if(ctl) then
			local parent = ParaUI.GetUIObject(LobbyChatPage.name.."chatwindow_tvcon");
			if(parent:IsValid())then
				ctl.parent = parent;
				ctl:Update(true);
			end
		end
		LobbyChatPage.RefreshScrollBar();
	end
end

