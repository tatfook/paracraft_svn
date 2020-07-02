--[[
Title: Desktop Minimap Area for Aries App (Not Used)
Author(s): WangTian
Date: 2008/12/2
See Also: script/apps/Aries/Desktop/AriesDesktop.lua
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
NPL.load("(gl)script/apps/Aries/Desktop/MiniMap.lua");
MyCompany.Aries.Desktop.MiniMap.InitMiniMap()
------------------------------------------------------------
]]

-- create class
local libName = "AriesDesktopMinimap";
local MiniMap = commonlib.gettable("MyCompany.Aries.Desktop.MiniMap");

-- Not used: invoked at Desktop.InitDesktop()
function MiniMap.InitMiniMap()

	-- Minimap area
	--local _minimap = ParaUI.CreateUIObject("container", "MinimapArea", "_rt", -168 - 3, 3, 168, 190);
	local _minimap = ParaUI.CreateUIObject("container", "MinimapArea", "_rt", 3, 3, 168, 190);
	_minimap.background = "";
	_minimap.zorder = -1;
	_minimap:AttachToRoot();
		local _minimapContent = ParaUI.CreateUIObject("container", "MinimapContent", "_lt", 22, 0, 146, 176);
		_minimapContent.background = "Texture/Aries/Desktop/Minimap_BG_32bits.png:18 32 18 20";
		_minimap:AddChild(_minimapContent);
		-- show the page on the minimap content
		MiniMap.MinimapPage = System.mcml.PageCtrl:new({url="script/apps/Aries/Desktop/MinimapPage.html"});
		MiniMap.MinimapPage:Create("AriesMinimapPage", _minimapContent, "_fi", 10, 30, 9, 18);
		local _text = ParaUI.CreateUIObject("button", "Text", "_lt", 10, 6, 128, 18);
		_text.background = "";
		_text.text= "李小多的家";
		_text.enabled = false;
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
