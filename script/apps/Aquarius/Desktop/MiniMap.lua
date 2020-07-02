--[[
Title: Desktop Minimap Area for Aquarius App
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
NPL.load("(gl)script/apps/Aquarius/Desktop/MiniMap.lua");
MyCompany.Aquarius.Desktop.MiniMap.InitMiniMap()
------------------------------------------------------------
]]

-- create class
local libName = "AquariusDesktopMinimap";
local MiniMap = {};
commonlib.setfield("MyCompany.Aquarius.Desktop.MiniMap", MiniMap);

-- data keeping
-- current icons of minimap area
MiniMap.RootNode = CommonCtrl.TreeNode:new({Name = "DockRoot",});

-- status 1 bar shows on the left side of the minimap area
MiniMap.Status1Node = MiniMap.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "状态1", Name = "Status1Root"}));
	MiniMap.Status1Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.NA", tooltip = "足迹（此版本尚未开放）", params = nil, icon = "Texture/Aquarius/Desktop/Minimap_Icon_Footprint_32bits.png"}));
	MiniMap.Status1Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.NA", tooltip = "回我的家（此版本尚未开放）", params = nil, icon = "Texture/Aquarius/Desktop/Minimap_Icon_Home_32bits.png"}));
	MiniMap.Status1Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.NA", tooltip = "星球（此版本尚未开放）", params = nil, icon = "Texture/Aquarius/Desktop/Minimap_Icon_Star_32bits.png"}));
	--MiniMap.Status1Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "", params = nil, icon = "Texture/Aquarius/Dock/Util4.png"}));
	--MiniMap.Status1Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "", params = nil, icon = "Texture/Aquarius/Dock/Util5.png"}));
	
-- status 2 bar shows on the bottom side of the minimap area
MiniMap.Status2Node = MiniMap.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "状态2", Name = "Status2Root"}));
	MiniMap.Status2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.LocalMap", tooltip = "地图", icon = "Texture/Aquarius/Desktop/Minimap_Icon_Map_32bits.png"}));
	MiniMap.Status2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.NA", tooltip = "场景收藏夹（此版本尚未开放）", icon = "Texture/Aquarius/Desktop/Minimap_Icon_Search_32bits.png"}));
	MiniMap.Status2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.NA", tooltip = "搜索（此版本尚未开放）", icon = "Texture/Aquarius/Desktop/Minimap_Icon_Magnify_32bits.png"}));
	MiniMap.Status2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.MinimapZoomIn", tooltip = "放大", icon = "Texture/Aquarius/Desktop/Minimap_Icon_ScaleUp_32bits.png"}));
	MiniMap.Status2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.MinimapZoomOut", tooltip = "缩小", icon = "Texture/Aquarius/Desktop/Minimap_Icon_ScaleDown_32bits.png"}));
	
	--MiniMap.Status2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "File.AutoLobbyPage", tooltip = "当前世界服务器状态", icon = "Texture/3DMapSystem/common/transmit.png"}));
	--MiniMap.Status2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "File.SaveAndPublish", tooltip = "保存或发布世界", icon = "Texture/3DMapSystem/common/disk.png"}));
	--MiniMap.Status2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "File.ScreenShot", tooltip = "显示截图(F11键)", icon = "Texture/3DMapSystem/common/page_white_camera.png"}));
	--MiniMap.Status2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "File.SubmitBug", tooltip = "发送Bug或建议", icon = "Texture/3DMapSystem/common/bug.png"}));
	--MiniMap.Status2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "File.Exit", tooltip = "退出", icon = "Texture/3DMapSystem/common/shutdown.png"}));
		--Map3DSystem.UI.AppTaskBar.StatusBar.AddTask({name = "HelpPage",icon = "Texture/3DMapSystem/common/help_16.png", 
			--tooltip = L"显示当前应用程序帮助(F1键)", commandName = "File.Help"});
			--
		--Map3DSystem.UI.AppTaskBar.StatusBar.AddTask({name = "HomePage",icon = "Texture/3DMapSystem/common/house.png", 
			--tooltip = L"我的首页", commandName = "Profile.HomePage"});
			
	

-- invoked at Desktop.InitDesktop()
function MiniMap.InitMiniMap()

	-- Minimap area
	local _minimap = ParaUI.CreateUIObject("container", "MinimapArea", "_rt", -168 - 3, 3, 168, 190);
	_minimap.background = "";
	_minimap.zorder = -1;
	_minimap:AttachToRoot();
		local _minimapContent = ParaUI.CreateUIObject("container", "MinimapContent", "_lt", 22, 0, 146, 176);
		_minimapContent.background = "Texture/Aquarius/Desktop/Minimap_BG_32bits.png:18 32 18 20";
		_minimap:AddChild(_minimapContent);
		-- show the page on the minimap content
		MiniMap.MinimapPage = System.mcml.PageCtrl:new({url="script/apps/Aquarius/Desktop/MinimapPage.html"});
		MiniMap.MinimapPage:Create("AquariusMinimapPage", _minimapContent, "_fi", 10, 30, 9, 18);
		local _text = ParaUI.CreateUIObject("button", "Text", "_lt", 10, 6, 128, 18);
		_text.background = "";
		_text.text= "李小多的家";
		_text.enabled= false;
		_text.font= "Tahoma;12;bold";
		_guihelper.SetFontColor(_text, "60 143 51");
		_minimapContent:AddChild(_text);
		
		local _tooltip = ParaUI.CreateUIObject("button", "Tooltip", "_lt", 10, 6, 128, 18);
		_tooltip.tooltip = "当前场景";
		_tooltip.background = "";
		_minimapContent:AddChild(_tooltip);
		
		--_minimapContent.scalingx = 176/128;
		--_minimapContent.scalingy = 176/128;
		--_minimapContent.translationx = -200;
		--_minimapContent.translationy = 200;
		--_minimapContent:ApplyAnim();
		
	local _statusbar1 = ParaUI.CreateUIObject("container", "StatusBar1", "_lt", 0, 28, 64, 150);
	_statusbar1.background = "";
	_minimap:AddChild(_statusbar1);
	_statusbar1:BringToBack();
	
	local i;
	for i = 1, MiniMap.Status1Node:GetChildCount() do
		local node = MiniMap.Status1Node:GetChild(i);
		local _util = ParaUI.CreateUIObject("button", "Status1_"..i, "_lt", 0, (i - 1) * 25, 64, 32);
		_util.background = node.icon;
		_util.tooltip = node.tooltip;
		_util.onclick = ";MyCompany.Aquarius.Desktop.MiniMap.CallStatusbar1Action("..i..");";
		_statusbar1:AddChild(_util);
	end
		
	local _statusbar2 = ParaUI.CreateUIObject("container", "StatusBar2", "_mb", 0, 0, 0, 27);
	_statusbar2.background = "";
	_minimap:AddChild(_statusbar2);
	_statusbar2:BringToFront();
	
	local left = 56;
	local i;
	for i = 1, MiniMap.Status2Node:GetChildCount() do
		local node = MiniMap.Status2Node:GetChild(i);
		local _util = ParaUI.CreateUIObject("button", "Status2_"..i, "_lt", left + (i - 1) * 22, 0, 32, 32);
		_util.background = node.icon;
		_util.tooltip = node.tooltip;
		_util.onclick = ";MyCompany.Aquarius.Desktop.MiniMap.CallStatusbar2Action("..i..");";
		_statusbar2:AddChild(_util);
	end
end

function MiniMap.CallStatusbar1Action(index)
	local node = MiniMap.Status1Node:GetChild(index);
	if(node ~= nil) then
		local commandName = node.CommandName;
		local command = System.App.Commands.GetCommand(commandName);
		if(command ~= nil) then
			command:Call();
		end
	end
end

function MiniMap.CallStatusbar2Action(index)
	local node = MiniMap.Status2Node:GetChild(index);
	if(node ~= nil) then
		local commandName = node.CommandName;
		local command = System.App.Commands.GetCommand(commandName);
		if(command ~= nil) then
			command:Call();
		end
	end
end

-- update the world name after world load
function MiniMap.UpdateWorldName()
	local _minimap = ParaUI.GetUIObject("MinimapArea");
	if(_minimap:IsValid() == true) then
		local _minimapContent = _minimap:GetChild("MinimapContent");
		local _text = _minimapContent:GetChild("Text");
		local worldpath = ParaWorld.GetWorldDirectory();
		if(string.sub(worldpath, -1, -1) == "/") then
			-- remove the additional /
			worldpath = string.sub(worldpath, 1, -2)
		end
		-- TODO: LiXizhi, we should allow user to name the world and save to db attribute table as UTF8 strings. 
		-- if world is not named, we will use its disk file name, but needs to convert to UTF8. 
		local worldName = commonlib.Encoding.DefaultToUtf8(ParaIO.GetFileName(worldpath));
		_text.text = worldName;
	end
end