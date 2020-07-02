--[[
Title: The BBS Chat window on the left bottom
Author(s): WangTian
Date: 2008/12/2
	2009/1/1 added serverproxy LiXizhi
Desc: It show/hide the chat window on the left bottom. the chat window displays chat message logs and is able to switch 
channel displays. 
Implementation: this can be done either in pure NPL, or pure MCML.
for NPL: we simply code everything in npl.
for MCML: we can create <pe:channel-wnd /> which automatically renders latest content of a given channel.

Aquarius channel specification:
/1	/D、/d	/当前	Channel_Say
/2	/B、/b	/本地	Channel_World
/3	/Z、/z	/综合	Channel_Public
/4	/J、/j	/交易	Channel_Trade
/5	/G、/g	/广告	Channel_Ads
	n/a	n/a	/公告	Channel_Official
	n/a	n/a	/提示	Channel_Notify

we will open channels for all the above except notification, which is locally handled on activities
More specifically Channel_Say and Channel_World name vary from world to world. Since one user can be only under one server at a time, 
we hard code the channel name as "Channel_Say_"..worldpath and "Channel_World_"..worldpath.
e.g. local worldpath = ParaWorld.GetWorldDirectory(); "Channel_World_"..worldpath

According to designer document, Channel_Say channel will display only the messages within 20 metres range.
The server will record all the messages in the world. It's the responsible for the client to decide whether to show the message.

All messages can contain pe:name, pe:worldname, pe:itemname, pe:questname .etc. These are pending TODO list to allow shift click 
message input.

Currently we don't use Map3DSystem channel manager implementation as a start. The API calls are fairly easy. All logics are hard coded in BBSChat

Version History:
2009-2-11		BBSChatWnd show and hide added

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/BBSChat/BBSChatWnd.lua");
MyCompany.Aquarius.BBSChatWnd.Show(bShow);
------------------------------------------------------------
]]

-- create class
local BBSChatWnd = {
	name = "AquariusBBSChat",
};
commonlib.setfield("MyCompany.Aquarius.BBSChatWnd", BBSChatWnd);

-- NOTE: the Channel_Notify notification channel is depracated, the notification is unified in the notification area
-- NOTE: update the channel name at world load end and clear all channel messages 
BBSChatWnd.channels = {
	[1] = {name = "Channel_Say",	color = "000000", text = "1.当前", bShow = true, },
	[2] = {name = "Channel_World",	color = "0000FF", text = "2.本地", bShow = true, },
	[3] = {name = "Channel_Public", color = "FFFFFF", text = "3.综合", bShow = true, },
	[4] = {name = "Channel_Trade",	color = "FFD700", text = "4.交易", bShow = true, },
	[5] = {name = "Channel_Ads",	color = "FF0000", text = "5.广告", bShow = true, },
	[6] = {name = "Channel_Official", color = "FFFF00", text = "官方公告", bShow = true, },
	-- [7] = {name = "Channel_Notify",	color = "808080", text = "提示"},
};

-- current channel that the user send message to, default to 1
BBSChatWnd.CurrentChannelIndex = 1;

-- if true the window position and size is locked
BBSChatWnd.isLocked = true;

-- fetch the latest
BBSChatWnd.NextGetMessageDate = "1000-10-10 10:10:10"

-- the rest BBS server proxy
local serverproxy = paraworld.epoll_serverproxy:new({
	-- fetching at least at this interval
	KeepAliveInterval = 5000,
	-- fetching interval when server is not responding. 
	ServerTimeOut = 20000,
});
-- update 0.1 second after text sent
BBSChatWnd.TextSentUpdateLatency = 100;


function BBSChatWnd.UpdateChannelName()
	local worldpath = ParaWorld.GetWorldDirectory();
	
	-- replace slash with underscore
	worldpath = string.gsub(worldpath, "/", "_");
	
	BBSChatWnd.channels[1].name = "Channel_Say_"..worldpath;
	BBSChatWnd.channels[2].name = "Channel_World_"..worldpath;
end

function BBSChatWnd.ClearChannelMessges()
	NPL.load("(gl)script/ide/TreeView.lua");
	local ctl = CommonCtrl.GetControl("Aquarius_ChannelPage_TreeView");
	if(ctl ~= nil) then
		ctl.RootNode:ClearAllChildren();
	end
end

-- text line height of a message. some fixed line height. 
local FixedLineHeight = 18; 

-- full window height with input field
BBSChatWnd.FullHeight = 220;

-- show or hide task bar UI
function BBSChatWnd.Show(bShow)
	local _this, _parent;
	local left,top,width,height;
	
	_this = ParaUI.GetUIObject(BBSChatWnd.name);
	if(_this:IsValid())then
		if(bShow==nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	else
		if( bShow == false)then
			return;
		end
		
		local left,top,width, height = 0, 0, 350,27;
		local _BBSChatWnd = ParaUI.CreateUIObject("container", BBSChatWnd.name, "_lb", 0, -BBSChatWnd.FullHeight-48-3 + 28, 350, BBSChatWnd.FullHeight);
		--_BBSChatWnd.background = "Texture/Aquarius/mainbar.png;0 0 29 29: 8 25 8 3";
		_BBSChatWnd.background = "";
		_BBSChatWnd.zorder = -1; -- make it stay on bottom. 
		--_BBSChatWnd.onmouseenter = ";MyCompany.Aquarius.BBSChatWnd.DoMouseEnter();";
		--_BBSChatWnd.onmouseleave = ";MyCompany.Aquarius.BBSChatWnd.DoMouseLeave();";
		_BBSChatWnd.onframemove = ";MyCompany.Aquarius.BBSChatWnd.DoFramemove();";
		_BBSChatWnd:AttachToRoot();
		
		-- left bar
		local _leftBar = ParaUI.CreateUIObject("container", "LeftBar", "_ml", 0, 0, 24, 0);
		_leftBar.background = "";
		_BBSChatWnd:AddChild(_leftBar);
			-- Home PageUp PageDown End
			local _end = ParaUI.CreateUIObject("button", "End", "_lt", 0, 28, 27, 29);
			_end.background = "Texture/Aquarius/Desktop/Channel_End_32bits.png; 0 0 27 29";
			_end.onclick = ";MyCompany.Aquarius.BBSChatWnd.ToggleHide();";
			_end.tooltip = "显示/隐藏";
			_leftBar:AddChild(_end);
			local _home = ParaUI.CreateUIObject("button", "Home", "_lt", 0, 28 + 29, 27, 29);
			_home.background = "Texture/Aquarius/Desktop/Channel_Home_32bits.png; 0 0 27 29";
			_home.onclick = ";MyCompany.Aquarius.BBSChatWnd.StepHome();";
			_home.tooltip = "翻到最前";
			_leftBar:AddChild(_home);
			local _pageUp = ParaUI.CreateUIObject("button", "PageUp", "_lt", 0, 28 + 29*2, 27, 29);
			_pageUp.background = "Texture/Aquarius/Desktop/Channel_Up_32bits.png; 0 0 27 29";
			_pageUp.onclick = ";MyCompany.Aquarius.BBSChatWnd.StepUp();";
			_pageUp.tooltip = "上翻";
			_leftBar:AddChild(_pageUp);
			local _pageDown = ParaUI.CreateUIObject("button", "PageDown", "_lt", 0, 28 + 29*3, 27, 29);
			_pageDown.background = "Texture/Aquarius/Desktop/Channel_Down_32bits.png; 0 0 27 29";
			_pageDown.onclick = ";MyCompany.Aquarius.BBSChatWnd.StepDown();";
			_pageDown.tooltip = "下翻";
			_leftBar:AddChild(_pageDown);
			local _end = ParaUI.CreateUIObject("button", "End", "_lt", 0, 28 + 29*4, 27, 29);
			_end.background = "Texture/Aquarius/Desktop/Channel_End_32bits.png; 0 0 27 29";
			_end.onclick = ";MyCompany.Aquarius.BBSChatWnd.StepEnd();";
			_end.tooltip = "翻到最后";
			_leftBar:AddChild(_end);
		
		-- channel background
		local _BG = ParaUI.CreateUIObject("container", "BG", "_fi", 27, 0, 0, 28);
		_BG.background = "Texture/Aquarius/Desktop/Channel_BG_32bits.png: 10 26 10 5";
		_BG.enabled = false;
		_BG.visible = false;
		_BBSChatWnd:AddChild(_BG);
		
		-- channel button
		local _channelBtn = ParaUI.CreateUIObject("button", "ChannelBtn", "_lt", 27, 0, 52, 28);
		--_channelBtn.background = nil;
		--_channelBtn.color = "255 255 255 100";
		--_channelBtn.background = "Texture/Aquarius/Desktop/Channel_Btn_Norm_32bits.png; 0 0 52 28";
		_guihelper.SetVistaStyleButton3(_channelBtn, 
				"Texture/Aquarius/Desktop/Channel_Btn_Norm_32bits.png; 0 0 52 28", 
				"Texture/Aquarius/Desktop/Channel_Btn_Over_32bits.png; 0 0 52 28", 
				"Texture/Aquarius/Desktop/Channel_Btn_Norm_32bits.png; 0 0 52 28", 
				"Texture/Aquarius/Desktop/Channel_Btn_Pressed_32bits.png; 0 0 52 28");
		--_guihelper.SetVistaStyleButton(_channelBtn, "", "Texture/EBook/button_bg_layer.png");
		_channelBtn.visible = false;
		_channelBtn.tooltip = "频道设置";
		_channelBtn.onclick = ";MyCompany.Aquarius.BBSChatWnd.ShowMenu();";
		_BBSChatWnd:AddChild(_channelBtn);
		
		local _inputArea = ParaUI.CreateUIObject("container", "InputArea", "_mb", 27, 0, 0, 28);
		_inputArea.background = "";
		_inputArea.visible = false;
		_BBSChatWnd:AddChild(_inputArea);
		
		local _inputAreaBG = ParaUI.CreateUIObject("button", "BG", "_fi", 0, 0, 0, 0);
		_inputAreaBG.background = "Texture/Aquarius/Desktop/Channel_InputOver_32bits.png: 7 7 7 7";
		--_guihelper.SetVistaStyleButton3(_inputAreaBG, 
				--"Texture/Aquarius/Desktop/Channel_InputNorm_32bits.png: 7 7 7 7", 
				--"Texture/Aquarius/Desktop/Channel_InputOver_32bits.png: 7 7 7 7", 
				--"Texture/Aquarius/Desktop/Channel_InputNorm_32bits.png: 7 7 7 7", 
				--"Texture/Aquarius/Desktop/Channel_InputOver_32bits.png: 7 7 7 7");
		_inputArea:AddChild(_inputAreaBG);
		
			-- [1.Public]
			local _input = ParaUI.CreateUIObject("container", "BG", "_lt", 0, 2, 48, 24);
			--_input.background = "Texture/3DMapSystem/Chat/message.png;0 0 8 16:6 7 1 7";
			_input.background = "";
			_inputArea:AddChild(_input);
			local _input = ParaUI.CreateUIObject("text", "SayToChannel", "_lt", 7, 6, 48, 22);
			_input.text = "[1.当前]";
			_inputArea:AddChild(_input);
		
		local _input = ParaUI.CreateUIObject("imeeditbox", "input", "_mt", 56, 3, 20, 22);
		_input.text = "";
		--_input.background = "Texture/3DMapSystem/Chat/message.png;8 0 8 16:1 7 6 7";
		_input.background = "";
		_input.onkeyup = ";MyCompany.Aquarius.BBSChatWnd.OnInputKeyUp();";
		_input.onchange = ";MyCompany.Aquarius.BBSChatWnd.OnInputKeyChange();";
		_inputArea:AddChild(_input);
		
		-- smiley and actions
		--local _smiley = ParaUI.CreateUIObject("button", "smiley", "_rt", -48, 5, 18, 18);
		--_smiley.background = "Texture/Aquarius/Desktop/Channel_Smiley_32bits.png; 0 0 18 18";
		--_inputArea:AddChild(_smiley);
		--local _action = ParaUI.CreateUIObject("button", "action", "_rt", -24, 4, 18, 20);
		--_action.background = "Texture/Aquarius/Desktop/Channel_Action_32bits.png; 0 0 18 20";
		--_action.onclick = ";MyCompany.Aquarius.BBSChatWnd.OnShowActionMenu();";
		--_inputArea:AddChild(_action);
		
		-- NOTE: action button is moves to the top frame of chat window
		local _action = ParaUI.CreateUIObject("button", "action", "_lt", 84, 2, 18, 20);
		_action.background = "Texture/Aquarius/Desktop/Channel_Action_32bits.png; 0 0 18 20";
		_action.onclick = ";MyCompany.Aquarius.BBSChatWnd.OnShowActionMenu();";
		_action.visible = false;
		_BBSChatWnd:AddChild(_action);
		
		-- change to default channel 1
		BBSChatWnd.ChangeToChannel(1);
		
		---- close button
		--_this = ParaUI.CreateUIObject("button", "close", "_rt", -20, 4, 16, 16);
		--_this.background = "Texture/Aquarius/mainbar.png;77 12 16 16";
		--_this.onclick = ";MyCompany.Aquarius.BBSChatWnd.Show();";
		--_parent:AddChild(_this);
		
		-- channel text treeview
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.GetControl("Aquarius_ChannelPage_TreeView");
		if(ctl == nil) then
			ctl = CommonCtrl.TreeView:new{
				name = "Aquarius_ChannelPage_TreeView",
				alignment = "_fi",
				left = 27 + 6,
				top = 28 + 6,
				width = 6,
				height = 24 + 6,
				parent = _BBSChatWnd,
				container_bg = "",
				DefaultIndentation = 5,
				NoClipping = false;
				DefaultNodeHeight = FixedLineHeight,
				VerticalScrollBarStep = FixedLineHeight,
				VerticalScrollBarPageSize = FixedLineHeight * 5,
				-- lxz: this prevent clipping text and renders faster
				NoClipping = false,
				HideVerticalScrollBar = true,
				DrawNodeHandler = function (_parent, treeNode)
					if(_parent == nil or treeNode == nil) then
						return;
					end
					local _this;
					local height = 100; -- just big enough
					local nodeWidth = treeNode.TreeView.ClientWidth;
					local oldNodeHeight = treeNode:GetHeight();
					
					local mcmlStr = treeNode.content;
					local mcmlNode;
					if(mcmlStr ~= nil) then
						local textbuffer = "<p><div style='text-shadow:true'>"..mcmlStr.."</div></p>";
						--textbuffer = ParaMisc.EncodingConvert("", "HTML", textbuffer);
						local xmlRoot = ParaXML.LuaXML_ParseString(textbuffer);
						if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
							local xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
							mcmlNode = xmlRoot[1];
							mcmlNode:SetAttribute("style", "color:#C8E3F1")
							
							local myLayout = Map3DSystem.mcml_controls.layout:new();
							myLayout:reset(0, 0, nodeWidth, height);
							Map3DSystem.mcml_controls.create("bbs_lobby", mcmlNode, nil, _parent, 0, 0, nodeWidth, height, nil, myLayout);
							
							local _, usedHeight = myLayout:GetUsedSize();
							treeNode.NodeHeight = usedHeight - 6;
							
							if(oldNodeHeight ~= treeNode.NodeHeight) then
								return treeNode.NodeHeight;
							end
						end
					end
					treeNode.TreeView = ctl;
				end,
			};
		end
		ctl:Show();
		ctl:Update(true);
		
		local _resizer_BG = ParaUI.CreateUIObject("container", "Resizer_BG", "_rt", -32, 0, 32, 32);
		_resizer_BG.background = "";
		_resizer_BG.visible = false;
		_BBSChatWnd:AddChild(_resizer_BG);
		
		local _resizer = ParaUI.CreateUIObject("container", BBSChatWnd.name.."_resizer", "_rt", -32, 0, 32, 32);
		_resizer.background = "";
		_resizer.candrag = true;
		_resizer.ondragbegin = ";MyCompany.Aquarius.BBSChatWnd.OnDragBegin();";
		_resizer.ondragmove = ";MyCompany.Aquarius.BBSChatWnd.OnDrag();";
		_resizer.ondragend = ";MyCompany.Aquarius.BBSChatWnd.OnDragEnd();";
		_BBSChatWnd:AddChild(_resizer);
	end
end

-- NOTE: BBSChatWnd now only support right top corner resizing
-- Turn on and off the MouseEnterance at begin and end. This will temporarily 
--		turn off the mouseenter and mouseleave event implemented in script. The mouse cursor is always in the BBS window, 
--		otherwise the new size of BBS window is 300 millisecond slower than mouse cursor movement.
function BBSChatWnd.OnDragBegin()
	BBSChatWnd.isCheckMouseEnterance = false;
end

function BBSChatWnd.OnDragEnd()
	BBSChatWnd.OnDrag();
	BBSChatWnd.isCheckMouseEnterance = true;
end

-- The resizing process will take 
function BBSChatWnd.OnDrag()
	if(BBSChatWnd.isLocked == true) then
		return;
	end
	local _window = ParaUI.GetUIObject(BBSChatWnd.name);
	local _resizer = ParaUI.GetUIObject(BBSChatWnd.name.."_resizer");
	
	local x_window, y_window, width_window, height_window = _window:GetAbsPosition();
	local x_resizer, y_resizer, width_resizer, height_resizer = _resizer:GetAbsPosition();
	local _, _, width_screen, height_screen = ParaUI.GetUIObject("root"):GetAbsPosition();
	
	local minWidth, maxWidth, minHeight, maxHeight = 200, 500, 220, 400;
	local newWidth = x_resizer - x_window + width_resizer;
	
	if(BBSChatWnd.IsEnterChat == true) then
		newHeight = height_screen - y_resizer + (-48-3);
	else
		newHeight = height_screen - y_resizer + (-48-3 + 28);
	end
	
	-- not exceed the min and max
	if(newWidth < minWidth) then
		newWidth = minWidth;
	end
	if(newWidth > maxWidth) then
		newWidth = maxWidth;
	end
	if(newHeight < minHeight) then
		newHeight = minHeight;
	end
	if(newHeight > maxHeight) then
		newHeight = maxHeight;
	end
		
	if(BBSChatWnd.IsEnterChat == true) then
		_window.y = -newHeight-48-3;
	else
		_window.y = -newHeight-48-3 + 28;
	end
	
	_window.width = newWidth;
	_window.height = newHeight;
	BBSChatWnd.FullHeight = newHeight;
	
	local time = ParaGlobal.GetGameTime();
	
	BBSChatWnd.LastSizeTime = BBSChatWnd.LastSizeTime or 0;
	
	-- update the control after 300 millionsecond or more
	if(time - BBSChatWnd.LastSizeTime) > 300 then
		local ctl = CommonCtrl.GetControl("Aquarius_ChannelPage_TreeView");
		if(ctl ~= nil) then
			ctl:Update();
		end
		BBSChatWnd.LastSizeTime = time;
	end
end

BBSChatWnd.isShow = true;

function BBSChatWnd.ToggleHide()
	BBSChatWnd.isShow = not BBSChatWnd.isShow;
	if(BBSChatWnd.isShow == true) then
		BBSChatWnd.isCheckMouseEnterance = true;
		BBSChatWnd.DoMouseEnter();
		local ctl = CommonCtrl.GetControl("Aquarius_ChannelPage_TreeView");
		if(ctl ~= nil) then
			ctl:Show(true);
			ctl:Update(true);
		end
	elseif(BBSChatWnd.isShow == false) then
		BBSChatWnd.LeaveChat();
		BBSChatWnd.isCheckMouseEnterance = false;
		BBSChatWnd.DoMouseLeave();
		local ctl = CommonCtrl.GetControl("Aquarius_ChannelPage_TreeView");
		if(ctl ~= nil) then
			ctl:Show(false);
		end
	end
end

-- scroll functions including Home, Up, Down and End
function BBSChatWnd.StepHome()
	local ctl = CommonCtrl.GetControl("Aquarius_ChannelPage_TreeView");
	if(ctl ~= nil) then
		-- dirty get first node, scroll to the page front
		local firstNode = ctl.RootNode.Nodes[1];
		ctl:Update(nil, firstNode);
	end
end

function BBSChatWnd.StepUp()
	local ctl = CommonCtrl.GetControl("Aquarius_ChannelPage_TreeView");
	if(ctl ~= nil) then
		ctl:ScrollByStep(-FixedLineHeight*3);
	end
end

function BBSChatWnd.StepDown()
	local ctl = CommonCtrl.GetControl("Aquarius_ChannelPage_TreeView");
	if(ctl ~= nil) then
		ctl:ScrollByStep(FixedLineHeight*3);
	end
end

function BBSChatWnd.StepEnd()
	local ctl = CommonCtrl.GetControl("Aquarius_ChannelPage_TreeView");
	if(ctl ~= nil) then
		ctl:Update(true);
	end
end

-- show the channel select menu and lock/unlock button
-- option menu is TopLevel container, and again turn off the MouseEnterance on show menu. The BBS window is always entered when menu is on
function BBSChatWnd.ShowMenu()
	local _BBSChatWnd = ParaUI.GetUIObject(BBSChatWnd.name);
	if(_BBSChatWnd:IsValid()) then
		local _channelBtn = _BBSChatWnd:GetChild("ChannelBtn");
		if(_channelBtn:IsValid()) then
			local _menu = ParaUI.GetUIObject(BBSChatWnd.name.."_Menu");
			if(_menu:IsValid() == false) then
				_menu = ParaUI.CreateUIObject("container", BBSChatWnd.name.."_Menu", "_lt", 0, 0, 100, 150 + 20 + 8);
				_menu:SetTopLevel(true);
				_menu.background = "Texture/Aquarius/Desktop/ChannelOption_BG_32bits.png: 8 24 8 4";
				_menu.onmousedown = ";MyCompany.Aquarius.BBSChatWnd.OnMouseUpMenu()";
				_menu:AttachToRoot();
				
				local _text = ParaUI.CreateUIObject("button", "HeadText", "_lt", 0, 0, 50, 21);
				_text.background = "";
				_text.enabled = false;
				_text.text = "选项";
				_guihelper.SetFontColor(_text, "#aeaeae");
				_menu:AddChild(_text);
				
				local i;
				local nCount = 5; -- we only allow show/hide the first 5 channels, excluding Offical channel
				for i = 1, nCount do
					local channel = BBSChatWnd.channels[i];
					NPL.load("(gl)script/ide/CheckBox.lua");
					local ctl = CommonCtrl.checkbox:new{
						name = "ChannelCheckbox:"..channel.name,
						alignment = "_lt",
						left = 10,
						top = 25*(i-1) + 25,
						width = 80,
						height = 21,
						parent = _menu,
						textcolor = "#aeaeae",
						isChecked = channel.bShow,
						checked_bg = "Texture/Aquarius/Desktop/CheckBox_Checked_32bits.png; 0 0 21 21",
						unchecked_bg = "Texture/Aquarius/Desktop/CheckBox_Unchecked_Norm_32bits.png; 0 0 21 21",
						unchecked_over_bg = "Texture/Aquarius/Desktop/CheckBox_Unchecked_Over_32bits.png; 0 0 21 21",
						text = channel.text,
						oncheck = function(ctrlName, isChecked) 
							local i;
							for i = 1, table.getn(BBSChatWnd.channels) do
								local channel = BBSChatWnd.channels[i];
								if(ctrlName == "ChannelCheckbox:"..channel.name) then
									BBSChatWnd.channels[i].bShow = isChecked;
								end
							end
						end,
					};
					ctl:Show();
				end
				
				local _unlocked = ParaUI.CreateUIObject("button", "UnLocked", "_lt", 16, nCount * 25 + 23, 80, 20);
				_unlocked.background = "";
				_unlocked.text = "锁定窗口";
				_guihelper.SetFontColor(_unlocked, "#aeaeae");
				_unlocked.onclick = ";MyCompany.Aquarius.BBSChatWnd.SetIsLocked(true);";
				_menu:AddChild(_unlocked);
				
				local _locked = ParaUI.CreateUIObject("button", "Locked", "_lt", 16, nCount * 25 + 23, 80, 20);
				_locked.background = "";
				_locked.text = "解除锁定";
				_guihelper.SetFontColor(_locked, "#aeaeae");
				_locked.onclick = ";MyCompany.Aquarius.BBSChatWnd.SetIsLocked(false);";
				_menu:AddChild(_locked);
				
				BBSChatWnd.SetIsLocked(BBSChatWnd.isLocked);
			end
			local x, y, width, height = _channelBtn:GetAbsPosition();
			_menu.x = x;
			_menu.y = y - 150 - 20 - 8;
			_menu.visible = true;
			
			local block = UIDirectAnimBlock:new();
			block:SetUIObject(_menu);
			block:SetTime(200);
			block:SetAlphaRange(0, 1);
			block:SetApplyAnim(true); 
			UIAnimManager.PlayDirectUIAnimation(block);
			
			-- TODO: PushEscState
			BBSChatWnd.isCheckMouseEnterance = false;
		end
	end
end

-- called when the user select a list box item or click outside the menu area
-- turn on the MouseEnterance on show menu to allow mouse enter and leave event generation from script
function BBSChatWnd.OnMouseUpMenu()
	-- hide the menu container if the user clicked outside the menu
	--local _menu = ParaUI.GetUIObject(BBSChatWnd.name.."_Menu");
	--if(_menu:IsValid() == true) then
		--_menu.visible = false;
	--end
	ParaUI.Destroy(BBSChatWnd.name.."_Menu");
	
	--BBSChatWnd.DoMouseLeave()
	
	-- TODO: PopEscState
	
	BBSChatWnd.isCheckMouseEnterance = true;
end

-- set the window resizer lock
function BBSChatWnd.SetIsLocked(isLocked)
	local _wnd = ParaUI.GetUIObject(BBSChatWnd.name);
	local _menu = ParaUI.GetUIObject(BBSChatWnd.name.."_Menu");
	if(_wnd:IsValid() == true and _menu:IsValid() == true) then
		local _resizer_BG = _wnd:GetChild("Resizer_BG");
		local _locked = _menu:GetChild("Locked");
		local _unlocked = _menu:GetChild("UnLocked");
		BBSChatWnd.isLocked = isLocked;
		if(BBSChatWnd.isLocked == true) then
			_unlocked.visible = false;
			_locked.visible = true;
			_resizer_BG.background = "";
		elseif(BBSChatWnd.isLocked == false) then
			_unlocked.visible = true;
			_locked.visible = false;
			_resizer_BG.background = "Texture/Aquarius/Desktop/Channel_Resizer_32bits.png: 1 14 14 1";
		end
	end
end

-- ActionMenu contains all the animations the user can play
-- The actionmenu button is once on the right side of BBSWnd input and then moved to the right side of the channel option menu button
function BBSChatWnd.OnShowActionMenu()
	local ctl = CommonCtrl.GetControl("BBSChatActionMenu");
	if(ctl == nil)then
		ctl = CommonCtrl.ContextMenu:new{
			name = "BBSChatActionMenu",
			width = 130,
			height = 150,
			--container_bg = "Texture/3DMapSystem/ContextMenu/BG2.png:8 8 8 8",
			container_bg = "Texture/3DMapSystem/ContextMenu/BG3.png:8 8 8 8",
			--DrawNodeHandler = Map3DSystem.UI.ContextMenu.DrawMenuItemHandler,
		};
		local node = ctl.RootNode;
		local subNode;
		-- name node: for displaying name of the selected object. Click to display property
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "动作列表", Name = "name", Type="Title", NodeHeight = 26 });
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "----------------------", Name = "titleseparator", Type="separator", NodeHeight = 4 });
		-- for character
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "actions", Name = "actions", Type = "Group", NodeHeight = 0 });
			node:AddChild(CommonCtrl.TreeNode:new({Text = "出拳", Name = "Fist", Type = "Menuitem", onclick = BBSChatWnd.DoAction, Icon = "Texture/face/14.png", anim = "character/Animation/v3/出拳.x"}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "哭泣", Name = "Cry", Type = "Menuitem", onclick = BBSChatWnd.DoAction, Icon = "Texture/face/15.png", anim = "character/Animation/v3/哭泣.x"}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "俯卧撑", Name = "Push-up", Type = "Menuitem", onclick = BBSChatWnd.DoAction, Icon = "Texture/face/16.png", anim = "character/Animation/v3/俯卧撑.x"}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "讨论", Name = "Discuss", Type = "Menuitem", onclick = BBSChatWnd.DoAction, Icon = "Texture/face/18.png", anim = "character/Animation/v3/讨论.x"}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "飞吻", Name = "Kiss", Type = "Menuitem", onclick = BBSChatWnd.DoAction, Icon = "Texture/face/19.png", anim = "character/Animation/v3/飞吻.x"}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "不可一世", Name = "BS", Type = "Menuitem", onclick = BBSChatWnd.DoAction, Icon = "Texture/face/20.png", anim = "character/Animation/v3/不可一世.x"}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "垂头丧气", Name = "Sad", Type = "Menuitem", onclick = BBSChatWnd.DoAction, Icon = "Texture/face/21.png", anim = "character/Animation/v3/垂头丧气.x"}));
			subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "可循环的", Name = "looped", Type = "Menuitem"});	
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "跳舞一", Name = "Dance1", Type = "Menuitem", onclick = BBSChatWnd.DoAction, Icon = "Texture/face/17.png", anim = "character/Animation/v3/跳舞一.x"}));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "跳舞二", Name = "Dance2", Type = "Menuitem", onclick = BBSChatWnd.DoAction, anim = "character/Animation/v3/跳舞二.x"}));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "弹钢琴", Name = "Piano", Type = "Menuitem", onclick = BBSChatWnd.DoAction, anim = "character/Animation/v3/弹钢琴.x"}));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "睡觉", Name = "Sleep", Type = "Menuitem", onclick = BBSChatWnd.DoAction, anim = "character/Animation/v3/睡觉.x"}));
			subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "从动作文件", Name = "fileactions", Type = "Menuitem"});
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "紧张", Name = "nervous", Type = "Menuitem", onclick = BBSChatWnd.DoAction, anim = "character/Animation/v3/紧张.x"}));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "修改大自然", Name = "modi", Type = "Menuitem", onclick = BBSChatWnd.DoAction, anim = "character/Animation/v3/修改大自然.x"}));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "人物诞生", Name = "born", Type = "Menuitem", onclick = BBSChatWnd.DoAction, anim = "character/Animation/v3/人物诞生.x"}));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "修改物体", Name = "modobj", Type = "Menuitem", onclick = BBSChatWnd.DoAction, anim = "character/Animation/v3/修改物体.x"}));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "欢呼", Name = "cheer", Type = "Menuitem", onclick = BBSChatWnd.DoAction, anim = "character/Animation/v3/欢呼.x"}));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "很兴奋的点头", Name = "excit", Type = "Menuitem", onclick = BBSChatWnd.DoAction, anim = "character/Animation/v3/很兴奋的点头.x"}));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "鼓掌", Name = "plaud", Type = "Menuitem", onclick = BBSChatWnd.DoAction, anim = "character/Animation/v3/鼓掌.x"}));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "欢迎", Name = "welcome", Type = "Menuitem", onclick = BBSChatWnd.DoAction, anim = "character/Animation/v3/欢迎.x"}));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "偷笑", Name = "yeah", Type = "Menuitem", onclick = BBSChatWnd.DoAction, anim = "character/Animation/v3/偷笑.x"}));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "再见", Name = "bye", Type = "Menuitem", onclick = BBSChatWnd.DoAction, anim = "character/Animation/v3/再见.x"}));
	end
	
	ctl:Show();
end

-- NOTE: animation file needed encoding from UTF8 to default
function BBSChatWnd.DoAction(node)
	local command = System.App.Commands.GetCommand("Profile.Aquarius.DoSkill");
	if(command) then
		local animfile = commonlib.Encoding.Utf8ToDefault(node.anim)
		command:Call({anim = animfile});
	end
end

-- This function is the callback function of GetBBS service call using serverproxy
function BBSChatWnd.HandleMessage(msg)
	if(not msg) then
		return
	end
	--log("GetBBSmsg: ");
	--commonlib.echo(msg)
	if(msg.errorcode) then
		log("GetBBS error , errorcode:"..msg.errorcode.."\n")
		return;
	end
	
	local preNextGetMessageDate = BBSChatWnd.NextGetMessageDate;
	local hasNewMessage = false;
	local messageDateInMSG;
	
	if(msg.channels) then
		local ctl = CommonCtrl.GetControl("Aquarius_ChannelPage_TreeView");
		if(ctl == nil) then
			log("error: empty channel treeview\n");
			return;
		end
		local rootNode = ctl.RootNode;
	
		-- append messages to the channel node
		local i, n;
		for i, n in ipairs(msg.channels) do
			local channelName = n.channel;
			local msgs = n.msgs;
			
			local color = "000000";
			local channelText;
			local channel;
			local channelIndex;
			if(channelName == BBSChatWnd.channels[1].name) then
				channelIndex = 1;
			elseif(channelName == BBSChatWnd.channels[2].name) then
				channelIndex = 2;
			elseif(channelName == BBSChatWnd.channels[3].name) then
				channelIndex = 3;
			elseif(channelName == BBSChatWnd.channels[4].name) then
				channelIndex = 4;
			elseif(channelName == BBSChatWnd.channels[5].name) then
				channelIndex = 5;
			elseif(channelName == BBSChatWnd.channels[6].name) then
				channelIndex = 6;
			end
			
			if(channelIndex == nil) then
				-- this usually happens when world switching due to the last GetBBS call in the last world returns 
				--		after the world name is reset to the new world
				-- just skip this message and wait for the GetBBS call with the new world name
			else
				channel = BBSChatWnd.channels[channelIndex];
				color = BBSChatWnd.channels[channelIndex].color;
				channelText = BBSChatWnd.channels[channelIndex].text;
				
				local i, msg;
				for i, msg in pairs(msgs) do
					hasNewMessage = true;
					messageDateInMSG = msg.date;
					
					local contentPlusChannelName = "";
					if(channelIndex == 6) then
						contentPlusChannelName = string.format(
							"<span style='color:#%s;' >[%s]</span>%s",
							color, channelText, msg.content);
					else
						contentPlusChannelName = string.format(
							"<span style='color:#%s;' ><a style='color:#%s;' tooltip=\"在此频道发言\" onclick=\"MyCompany.Aquarius.BBSChatWnd.ChannelClick()\" param1="..channelIndex..">[%s]</a></span>%s",
							color, color, channelText, msg.content);
					end
					
					local function CompareDate(date1, date2)
						if(type(date1) ~= "string" or type(date2) ~= "string" ) then
							return;
						end
						local year1, month1, day1, hour1, minute1, second1 = string.match(date1, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)");
						local year2, month2, day2, hour2, minute2, second2 = string.match(date2, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)");
						--local num1 = tonumber(year1.."0000000000")
							--+ tonumber(month1.."00000000")
							--+ tonumber(day1.."000000")
							--+ tonumber(hour1.."0000")
							--+ tonumber(minute1.."00")
							--+ tonumber(second1);
						--local num2 = tonumber(year2.."0000000000")
							--+ tonumber(month2.."00000000")
							--+ tonumber(day2.."000000")
							--+ tonumber(hour2.."0000")
							--+ tonumber(minute2.."00")
							--+ tonumber(second2);
						local numstr1 = string.format("%04d%02d%02d%02d%02d%02d", 
							tonumber(year1), 
							tonumber(month1), 
							tonumber(day1), 
							tonumber(hour1), 
							tonumber(minute1), 
							tonumber(second1)
						);
						local numstr2 = string.format("%04d%02d%02d%02d%02d%02d", 
							tonumber(year2), 
							tonumber(month2), 
							tonumber(day2), 
							tonumber(hour2), 
							tonumber(minute2), 
							tonumber(second2)
						);
						
						local num1 = tonumber(numstr1);
						local num2 = tonumber(numstr2);
						
						-------------------------------------------------------------------------------------
						-- NOTE by andy 2009/1/15: tonumber the manually attached string still has the number conversion
						--		problem, which cause the coming assignment operation fails
						-------------------------------------------------------------------------------------
						
						-------------------------------------------------------------------------------------
						-- NOTE by andy 2009/1/12: lua has a very strange solution to the implementation above
						-- Once a bug came that the tonumber function returns always the same integer regardless of the input:
						-- I guess the final tonumber step tonumber(year2.."0000000000") add some random error when upward casting to large integers
						-- that contains some invalid data in the the last few digits.
						--	log("CompareDate: "..date1.."   "..date2.."\n")
						--		 CompareDate: 2009-1-12 16:10:29   2009-1-12 17:08:39
						--	log("    returns: 0    "..num1.."   "..num2.."\n")
						--			 returns: 0    20090112180224   20090112180224
						-------------------------------------------------------------------------------------
							
						--local num1 = ((((tonumber(year1) * 12 + tonumber(month1)) * 31 + tonumber(day1)) * 24 + tonumber(hour1)) * 60 + tonumber(minute1)) * 60 + tonumber(second1);
						--local num2 = ((((tonumber(year2) * 12 + tonumber(month2)) * 31 + tonumber(day2)) * 24 + tonumber(hour2)) * 60 + tonumber(minute2)) * 60 + tonumber(second2);
						
						if(num1 == num2) then
							return 0, num1, num2;
						elseif(num1 > num2) then
							return 1, num1, num2;
						elseif(num1 < num2) then
							return -1, num1, num2;
						end
					end
					
					local function ParseDate(date1, date2)
						if(type(date1) ~= "string" or type(date2) ~= "string" ) then
							return;
						end
						local year1, month1, day1, hour1, minute1, second1 = string.match(date1, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)");
						local year2, month2, day2, hour2, minute2, second2 = string.match(date2, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)");
						local numstr1 = string.format("%04d%02d%02d%02d%02d%02d", 
							tonumber(year1), 
							tonumber(month1), 
							tonumber(day1), 
							tonumber(hour1), 
							tonumber(minute1), 
							tonumber(second1)
						);
						local numstr2 = string.format("%04d%02d%02d%02d%02d%02d", 
							tonumber(year2), 
							tonumber(month2), 
							tonumber(day2), 
							tonumber(hour2), 
							tonumber(minute2), 
							tonumber(second2)
						);
						return numstr1, numstr2;
					end
					
					--local compare, _, dateNum = CompareDate(BBSChatWnd.NextGetMessageDate, msg.date);
					--
					--if(compare == -1) then
						---- update the NextGetMessageDate
						--BBSChatWnd.NextGetMessageDate = msg.date;
					--end
					
					local _, dateNum = ParseDate(BBSChatWnd.NextGetMessageDate, msg.date);
					
					if(_ ~= nil and dateNum ~= nil) then
						if(_ < dateNum) then
							-- update the NextGetMessageDate
							BBSChatWnd.NextGetMessageDate = msg.date;
						end
						
						if(rootNode:GetChildCount() > 50) then
							rootNode:RemoveChildByIndex(1);
						end
						if(channel.bShow == false) then
							-- don't update the message if the user turn off the channel message
						else
							rootNode:AddChild(CommonCtrl.TreeNode:new({
								date = msg.date, 
								dateNum = dateNum,
								uid = msg.uid, 
								content = contentPlusChannelName, 
								}));
							rootNode.HistoryCount = rootNode.HistoryCount or 0;
							rootNode.HistoryCount = rootNode.HistoryCount + 1;
							-- sort children
							rootNode:SortChildren(CommonCtrl.TreeNode.GenerateLessCFByField("dateNum"))
						end
					end
				end
			end	
		end
	end
	
	if(hasNewMessage == true and preNextGetMessageDate == BBSChatWnd.NextGetMessageDate) then
		-- crazy message repeat bug happened again
		-- one of the date in message as the NextGetMessageDate, otherwise use the current time as the next get message date
		BBSChatWnd.NextGetMessageDate = messageDateInMSG or (ParaGlobal.GetDateFormat("yyyy-M-d").." "..ParaGlobal.GetTimeFormat("H:mm:ss"));
	end
end

-- update the message using serverproxy
---- fetching at least at this interval
--KeepAliveInterval = 5000,
---- fetching interval when server is not responding. 
--ServerTimeOut = 20000,
function BBSChatWnd.UpdateMessage()
	if(not System.User.IsAuthenticated) then
		return;
	end
	-- check if it is time to send another message with our proxy
	if( not serverproxy:CanSendUpdate() ) then
		return
	end
	
	-- update messages for all channel
	-- GetBBS interface is updated, get all channel messages in one service call instead of fetching individually
	local channelNames = "";
	local i, channel;
	for i, channel in ipairs(BBSChatWnd.channels) do
		channelNames = channelNames..channel.name.."|";
	end
	
	local msg = {
		channels = channelNames,
		afterDate = BBSChatWnd.NextGetMessageDate,
		pageindex = 0,
		pagesize = 50,
	};
	
	serverproxy:Call(paraworld.lobby.GetBBS, 
		msg, "GetBBSChatMessages", function(msg)
		--log("----------- getlobbymessage received msg--------- \n");
		--commonlib.echo(msg);
		
		if(msg) then
			serverproxy:OnRespond();
			BBSChatWnd.HandleMessage(msg);
		else	
			-- we have an error. 
			log("warning: paraworld.lobby.GetBBS got an error\n");
		end
	end);
end

-- change to channel and autofocus on input editbox
function BBSChatWnd.ChannelClick(index)
	local index = tonumber(index);
	BBSChatWnd.EnterChat();
	BBSChatWnd.ChangeToChannel(index);
end

-- post message to the current channel
-- @param content: the message content
function BBSChatWnd.PostMessage(contentStr)
	--ChannelManager.lastMSGSentTime = ParaGlobal.timeGetTime(); -- in milliseconds
	
	-- force update
	-- TRICKY: this will delay the auto update
	serverproxy:OffsetLastSendTime(BBSChatWnd.TextSentUpdateLatency-serverproxy.KeepAliveInterval);
	
	local channelName = BBSChatWnd.channels[BBSChatWnd.CurrentChannelIndex].name;
	local out_msg = {
		channel = channelName,
		content = contentStr,
	};
	--log("-----------sending message\n")
	--commonlib.echo(out_msg);
	
	paraworld.lobby.PostBBS(out_msg, "PostBBSChatMessage", function(msg)
		--commonlib.log(msg);
		-- TODO for andy 2008.6.27: inform failure, only allows enter subsequent text when this returns?. 
		if(not msg or not msg.issuccess)  then
			log("warning: paraworld.lobby.PostBBS failed on posting message:\n")
			commonlib.echo(out_msg);
		end
	end);
end

-- BBS chat window generates mouse enter and leave events in script instead of the unreliable onmouseenter and onmouseleave event
local isMouseInWnd = false;
BBSChatWnd.isCheckMouseEnterance = true;

-- bbs chat window frame move
function BBSChatWnd.DoFramemove()
	if(BBSChatWnd.isCheckMouseEnterance == true) then
		local x, y = ParaUI.GetMousePosition();
		--local temp = ParaUI.GetUIObjectAtPoint(x, y);
		--if(temp.name == BBSChatWnd.name.."_Menu") then
			--return;
		--end
		local _BBSChatWnd = ParaUI.GetUIObject(BBSChatWnd.name);
		if(_BBSChatWnd:IsValid()) then
			local wnd_x, wnd_y, wnd_width, wnd_height = _BBSChatWnd:GetAbsPosition();
			if(wnd_x <= x and (wnd_x + wnd_width) > x and wnd_y <= y and (wnd_y + wnd_height) > y) then
				if(isMouseInWnd == false) then
					-- mouseenter
					isMouseInWnd = true;
					BBSChatWnd.DoMouseEnter();
				end
			else
				if(isMouseInWnd == true) then
					-- mouseleave
					isMouseInWnd = false;
					BBSChatWnd.DoMouseLeave();
				end
			end
		end
	end
	
	-- call the update message as much as possible
	BBSChatWnd.UpdateMessage();
	
	-- update the treeviews
	local ctl = CommonCtrl.GetControl("Aquarius_ChannelPage_TreeView");
	if(ctl ~= nil) then
		
		local rootNode = ctl.RootNode;
		--ctl.RootNode = channelRootNode;
		--ctl.RootNode.TreeView = ctl;
		
		---- assign each node with the treeview
		--local nCount = ctl.RootNode:GetChildCount();
		--local i;
		--
		--if(nCount == 0) then
			----return;
		--end
		--for i = 1, nCount do
			--local node = ctl.RootNode:GetChild(i);
			--if(node.TreeView == nil) then
				--node.TreeView = ctl;
			--end
		--end
		
		-- update the treeview only on new message appended
		if(BBSChatWnd.LastHistoryCount ~= ctl.RootNode.HistoryCount) then
			--ctl:Update();
			-- owner draw node handler will update the node height
			
			ctl:Update(true);
			-- NOTE by andy: if only update once the treeview is not actually scroll to the bottom,
			-- TODO: check TreeView:Update(true) logic
			ctl:Update(true);
		end
		
		BBSChatWnd.LastHistoryCount = ctl.RootNode.HistoryCount;
	end
end

-- show the BBSChat window background with animation
function BBSChatWnd.DoMouseEnter()
	local _BBSChatWnd = ParaUI.GetUIObject(BBSChatWnd.name);
	if(_BBSChatWnd:IsValid()) then
		local _BG = _BBSChatWnd:GetChild("BG");
		if(_BG:IsValid()) then
			_BG.visible = true;
			if(UIAnimManager.IsDirectAnimating(_BG)) then
				UIAnimManager.StopDirectAnimation(_BG);
			end
			local block = UIDirectAnimBlock:new();
			block:SetUIObject(_BG);
			block:SetCallfront(function (obj)
				obj.visible = true;
			end); 
			block:SetTime(200);
			block:SetAlphaRange(0.3, 1);
			block:SetXRange(27, 27);
			block:SetWidthRange(0, 0);
			block:SetApplyAnim(true); 
			UIAnimManager.PlayDirectUIAnimation(block);
		end
		local _channelBtn = _BBSChatWnd:GetChild("ChannelBtn");
		if(_channelBtn:IsValid()) then
			_channelBtn.visible = true;
			if(UIAnimManager.IsDirectAnimating(_channelBtn)) then
				UIAnimManager.StopDirectAnimation(_channelBtn);
			end
			local block = UIDirectAnimBlock:new();
			block:SetUIObject(_channelBtn);
			block:SetCallfront(function (obj)
				obj.visible = true;
			end); 
			block:SetTime(200);
			block:SetAlphaRange(0.3, 1);
			block:SetApplyAnim(true); 
			UIAnimManager.PlayDirectUIAnimation(block);
		end
		local _action = _BBSChatWnd:GetChild("action");
		if(_action:IsValid()) then
			_action.visible = true;
			if(UIAnimManager.IsDirectAnimating(_action)) then
				UIAnimManager.StopDirectAnimation(_action);
			end
			local block = UIDirectAnimBlock:new();
			block:SetUIObject(_action);
			block:SetCallfront(function (obj)
				obj.visible = true;
			end); 
			block:SetTime(200);
			block:SetAlphaRange(0.3, 1);
			block:SetApplyAnim(true); 
			UIAnimManager.PlayDirectUIAnimation(block);
		end
		local _resizer_BG = _BBSChatWnd:GetChild("Resizer_BG");
		if(_resizer_BG:IsValid()) then
			_resizer_BG.visible = true;
			if(UIAnimManager.IsDirectAnimating(_resizer_BG)) then
				UIAnimManager.StopDirectAnimation(_resizer_BG);
			end
			local block = UIDirectAnimBlock:new();
			block:SetUIObject(_resizer_BG);
			block:SetCallfront(function (obj)
				obj.visible = true;
			end); 
			block:SetTime(200);
			block:SetAlphaRange(0.3, 1);
			block:SetApplyAnim(true); 
			UIAnimManager.PlayDirectUIAnimation(block);
		end
	end
end

-- hide the BBSChat window background with animation
function BBSChatWnd.DoMouseLeave()
	-- unhide the channle background if channel menu is active
	local x, y = ParaUI.GetMousePosition();
	local _BBSChatWnd = ParaUI.GetUIObject(BBSChatWnd.name);
	if(_BBSChatWnd:IsValid()) then
		--local wnd_x, wnd_y, wnd_width, wnd_height = _BBSChatWnd:GetAbsPosition();
		--if(wnd_x < x and (wnd_x + wnd_width) > x and wnd_y < y and (wnd_y + wnd_height) > y) then
			--return;
		--end
		local _BG = _BBSChatWnd:GetChild("BG");
		if(_BG:IsValid()) then
			if(UIAnimManager.IsDirectAnimating(_BG)) then
				UIAnimManager.StopDirectAnimation(_BG);
			end
			_BG.visible = true;
			local block = UIDirectAnimBlock:new();
			block:SetUIObject(_BG);
			block:SetTime(1000);
			block:SetAlphaRange(1, 0);
			block:SetXRange(27, 27);
			block:SetWidthRange(0, 0);
			block:SetApplyAnim(true); 
			block:SetCallback(function ()
				_BG.visible = false;
			end); 
			UIAnimManager.PlayDirectUIAnimation(block);
		end
		local _channelBtn = _BBSChatWnd:GetChild("ChannelBtn");
		if(_channelBtn:IsValid()) then
			if(UIAnimManager.IsDirectAnimating(_channelBtn)) then
				UIAnimManager.StopDirectAnimation(_channelBtn);
			end
			_channelBtn.visible = true;
			local block = UIDirectAnimBlock:new();
			block:SetUIObject(_channelBtn);
			block:SetTime(1000);
			block:SetAlphaRange(1, 0);
			block:SetApplyAnim(true); 
			block:SetCallback(function ()
				_channelBtn.visible = false;
			end); 
			UIAnimManager.PlayDirectUIAnimation(block);
		end
		local _action = _BBSChatWnd:GetChild("action");
		if(_action:IsValid()) then
			if(UIAnimManager.IsDirectAnimating(_action)) then
				UIAnimManager.StopDirectAnimation(_action);
			end
			_action.visible = true;
			local block = UIDirectAnimBlock:new();
			block:SetUIObject(_action);
			block:SetTime(1000);
			block:SetAlphaRange(1, 0);
			block:SetApplyAnim(true); 
			block:SetCallback(function ()
				_action.visible = false;
			end); 
			UIAnimManager.PlayDirectUIAnimation(block);
		end
		local _resizer_BG = _BBSChatWnd:GetChild("Resizer_BG");
		if(_resizer_BG:IsValid()) then
			_resizer_BG.visible = true;
			if(UIAnimManager.IsDirectAnimating(_resizer_BG)) then
				UIAnimManager.StopDirectAnimation(_resizer_BG);
			end
			local block = UIDirectAnimBlock:new();
			block:SetUIObject(_resizer_BG);
			block:SetTime(1000);
			block:SetAlphaRange(1, 0);
			block:SetApplyAnim(true); 
			block:SetCallback(function ()
				_resizer_BG.visible = false;
			end); 
			UIAnimManager.PlayDirectUIAnimation(block);
		end
	end
end

BBSChatWnd.IsEnterChat = false;

-- user press ENTER key to input
function BBSChatWnd.EnterChat()
	if(BBSChatWnd.isShow == false) then
		-- don't allow enter chat when BBS window is hiden
		return;
	end
	
	-- leave the channel option menu if menu is on
	BBSChatWnd.OnMouseUpMenu();
	
	local _BBSChatWnd = ParaUI.GetUIObject(BBSChatWnd.name);
	if(_BBSChatWnd:IsValid() == true) then
		_BBSChatWnd.y = -BBSChatWnd.FullHeight-48-3;
		local _inputArea = _BBSChatWnd:GetChild("InputArea");
		_inputArea.visible = true;
		local _input = _inputArea:GetChild("input");
		_input:Focus();
		-- push Esc state
		System.PushState({name = "AquariusBBSChat", OnEscKey = BBSChatWnd.LeaveChat});
		BBSChatWnd.IsEnterChat = true;
	end
end

-- user press ESC key to leave channel input
function BBSChatWnd.LeaveChat()
	local _BBSChatWnd = ParaUI.GetUIObject(BBSChatWnd.name);
	if(_BBSChatWnd:IsValid() == true) then
		_BBSChatWnd.y = -BBSChatWnd.FullHeight-48-3 + 28;
		local _inputArea = _BBSChatWnd:GetChild("InputArea");
		_inputArea.visible = false;
		local _input = _inputArea:GetChild("input");
		_input.text = "";
		_input:LostFocus();
		BBSChatWnd.IsEnterChat = false;
	end
end

-- change channel short cut using channel name abbreviation or chinese name
function BBSChatWnd.OnSpace()
	local _BBSChatWnd = ParaUI.GetUIObject(BBSChatWnd.name);
	if(_BBSChatWnd:IsValid() == true) then
		local _inputArea = _BBSChatWnd:GetChild("InputArea");
		-- get the input text and string.lower
		local _input = _inputArea:GetChild("input");
		local inputText = _input.text;
		local heading = string.lower(string.sub(inputText, 1, string.find(inputText, " ")));
		-- find the channel index
		local index;
		if(heading == "/1 " or heading == "/d " or heading == "/当前 ") then
			index = 1;
		elseif(heading == "/2 " or heading == "/b " or heading == "/本地 ") then
			index = 2;
		elseif(heading == "/3 " or heading == "/z " or heading == "/综合 ") then
			index = 3;
		elseif(heading == "/4 " or heading == "/j " or heading == "/交易 ") then
			index = 4;
		elseif(heading == "/5 " or heading == "/g " or heading == "/广告 ") then
			index = 5;
		end
		
		if(index ~= nil) then
			_input.text = string.sub(_input.text, string.find(inputText, " ") + 1);
			BBSChatWnd.ChangeToChannel(index);
		end
	end
end

-- change channel that the user send message to
-- channel index resides in BBSChatWnd.CurrentChannelIndex
-- @param index: channel index
function BBSChatWnd.ChangeToChannel(index)
	if(type(index) ~= "number") then
		log("invalid input: BBSChatWnd.ChangeChannel()\n")
		return;
	end
	local _BBSChatWnd = ParaUI.GetUIObject(BBSChatWnd.name);
	if(_BBSChatWnd:IsValid() == true) then
		local _inputArea = _BBSChatWnd:GetChild("InputArea");
		-- get the input text and string.lower
		local _channelname = _inputArea:GetChild("SayToChannel");
		_channelname.text = "["..BBSChatWnd.channels[index].text.."]";
		_guihelper.SetFontColor(_channelname, "#"..BBSChatWnd.channels[index].color);
		local _input = _inputArea:GetChild("input");
		_guihelper.SetFontColor(_input, "#"..BBSChatWnd.channels[index].color);
	end
	BBSChatWnd.CurrentChannelIndex = index;
end

-- input key up
function BBSChatWnd.OnInputKeyUp()
	if(virtual_key == Event_Mapping.EM_KEY_SPACE) then
		BBSChatWnd.OnSpace();
	elseif(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER) then
		BBSChatWnd.SendMSG();
	elseif(virtual_key == Event_Mapping.EM_KEY_ESCAPE) then
		--BBSChatWnd.LeaveChat();
	end
end

-- input key change
function BBSChatWnd.OnInputKeyChange()
	--if(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER) then
		--BBSChatWnd.SendMSG();
	--elseif(virtual_key == Event_Mapping.EM_KEY_ESCAPE) then
		--log("2\n")
		----BBSChatWnd.LeaveChat();
	--end
end

function BBSChatWnd.SendMSG()
	local inputText = "";
	local _BBSChatWnd = ParaUI.GetUIObject(BBSChatWnd.name);
	if(_BBSChatWnd:IsValid() == true) then
		local _inputArea = _BBSChatWnd:GetChild("InputArea");
		-- get the input text and string.lower
		local _input = _inputArea:GetChild("input");
		inputText = _input.text;
	else
		return;
	end
	
	BBSChatWnd.LeaveChat();
	
	paraworld.users.getInfo({nids = System.User.nid, fields= "userid, nid, username, nickname"}, "AquariusBBSChatUserName", function(msg)
		if(msg == nil) then	
			log("error message in paraworld.users.getInfo call\n");
			return;
		end
		
		local username;
		if(msg and msg.users and msg.users[1]) then
			username = msg.users[1].nickname;
		end
		if(username == nil or username == "") then
			username = "匿名";
		end
		
		if(username == nil) then
			log("invalid username when BBSChatWnd.SendMSG");
			return;
		end
		
		-- empty string will leave the chat status immediately
		if(inputText == "") then
			BBSChatWnd.LeaveChat();
			return;
		end
		
		-- string length exceed 100
		local strLen = string.len(inputText);
		if(strLen > 100) then
			_guihelper.MessageBox("您发的消息太长，请分行发送");
			BBSChatWnd.LeaveChat();
			return;
		end
		
		NPL.load("(gl)script/ide/XPath.lua");
		-- encode the content string
		local sendText = commonlib.XPath.XMLEncodeString(inputText);
		
		-- original implementation
		--local mcmlStr = string.format("<pe:name uid='%s' a_class='a_inverse' value='%s'/>:<span %s>%s</span>",
			--Map3DSystem.App.profiles.ProfileManager.GetUserID() or "", username, QuickChatPage.TextStyle or "", sendText);
		
		local textColor = BBSChatWnd.channels[BBSChatWnd.CurrentChannelIndex].color;
		
		local textStyle = string.format("style='color:#%s'", textColor);
		local divtextStyle = string.format("style='float:left;color:#%s'", textColor);
		
		local mcmlStr = string.format("<pe:name uid='%s' a_%s useyou=false value='%s'/>:<div %s>%s</div>",
			System.App.profiles.ProfileManager.GetUserID() or "", textStyle or "", username, 
			divtextStyle or "", sendText);
		
		BBSChatWnd.PostMessage(mcmlStr);
	end);
end

