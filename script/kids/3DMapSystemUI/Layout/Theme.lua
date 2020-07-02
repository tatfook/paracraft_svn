--[[
Title: paraworld theme
Author(s): WangTian
Date: 2008/1/4
Desc: paraworld theme enables the user to change the appearance of certain or all paraworld UI elements
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");

-- Theme package: A theme package contains an .xml theme desc file and a set of required textures.
--		The required textures are installed in a specific directory Themes/***/ e.x. Themes/mac/*.png  %ThemeDir% = Themes/***/
--		The theme file is installed in the directory Themes/ e.x. Themes/mac.theme.xml
--
-- Desc: The following discusses the format of a theme files used in ParaWorld. A theme file is 
--		an .xml document that is divided into sections, which specify visual elements that appear 
--		on ParaWorld. Section names are wrapped in xml comments ( <!-- --> ) in the .xml file.
--
-- The following sections are implemented.
--		1. Official Features Icons
--		2. Fonts
--		3. Colors
--		4. Cursors
--		5. Mainbar Appearance
--		6. Mainmenu Appearance
--		7. DefaultWindow Appearance

if(not Map3DSystem.UI.Theme) then Map3DSystem.UI.Theme = {} end

--------------------------------------
--	1. Official Features Icons
--------------------------------------

Map3DSystem.UI.Theme.Sample.CreatorIcon = "%ThemeDir%/Creation.png; 0 0 48 48";
Map3DSystem.UI.Theme.Sample.MapIcon = "";
Map3DSystem.UI.Theme.Sample.ChatIcon = "";
Map3DSystem.UI.Theme.Sample.ChatIcon = "";



--		2. Fonts
--		3. Colors
--		4. Cursors
--		5. Mainbar Appearance
--		6. Mainmenu Appearance
--		7. DefaultWindow Appearance