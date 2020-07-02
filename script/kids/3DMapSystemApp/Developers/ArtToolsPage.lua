--[[
Title: code behind page for ArtToolsPage.html
Author(s): LiXizhi
Date: 2008/9/3
Desc: some tools that the artists uses. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Developers/ArtToolsPage.lua");
-------------------------------------------------------
]]
local L = CommonCtrl.Locale("ParaWorld");
NPL.load("(gl)script/kids/3DMapSystemApp/Translator/Translator.lua");

local ArtToolsPage = {};
commonlib.setfield("Map3DSystem.App.Developers.ArtToolsPage", ArtToolsPage)

---------------------------------
-- page event handlers
---------------------------------
local page;
-- init
function ArtToolsPage.OnInit()
	page = document:GetPageCtrl();

	--local files = Map3DSystem.App.Developers.app:ReadConfig("RecentlyTranslatedFiles", {})
	--local index, value
	--for index, value in ipairs(files) do
		--self:SetNodeValue("filepath", value);
	--end
	--self:SetNodeValue("filepath", "");
end

function ArtToolsPage.OnClickWorldStripperPage()
	Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemApp/worlds/WorldStripperPage.html", title="World Stripper", DisplayNavBar = true, DestroyOnClose=true});
end

function ArtToolsPage.OnClickUpdaterPage()
	Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemApp/Assets/UpdaterPage.html", title="Updater Page", DisplayNavBar = true, DestroyOnClose=true});
end

function ArtToolsPage.OnClickObjectInstancesEditor()
	NPL.load("(gl)script/PETools/Aries/ObjectInstancesEditor.lua");
	MyCompany.PETools.Editors.ObjectInstancesEditor.ShowPage();
end

function ArtToolsPage.OnClickShowReport(bChecked)
	Map3DSystem.App.Commands.Call("Creation.ShowReport", bChecked);
end

function ArtToolsPage.OnClickShowWireFrame(bChecked)
	ParaScene.GetAttributeObject():SetField("UseWireFrame", bChecked);
end

function ArtToolsPage.OnClickShowOBB(bChecked)
	Map3DSystem.App.Commands.Call("Creation.ShowOBB", bChecked);
end

function ArtToolsPage.OnClickEnableAssetWatcher()
	NPL.load("(gl)script/ide/FileSystemWatcher.lua");
	commonlib.FileSystemWatcher.EnableAssetFileWatcher();
end

function ArtToolsPage.OnClickShowMiniSceneStats(bChecked)
	NPL.load("(gl)script/ide/MinisceneManager.lua");
	CommonCtrl.MinisceneManager.ShowStatsOnUI(bChecked);
end

function ArtToolsPage.OnClickShowPhysicsDebug(bChecked)
	local nMode;
	if(bChecked) then
		nMode = -1;
	else
		nMode = 0;
	end
	ParaScene.GetAttributeObject():SetField("PhysicsDebugDrawMode", nMode);
end

function ArtToolsPage.OnClickOpenAsset()
	Map3DSystem.App.Commands.Call("File.Open.Asset");
	page:CloseWindow();
end	

function ArtToolsPage.OnClickCreatorAssets()
	Map3DSystem.App.Commands.Call("Profile.Assets");
	page:CloseWindow();
end	

function ArtToolsPage.OnClickAnimationPage()
	Map3DSystem.App.Commands.Call("Profile.CCS.AnimationPage");
	page:CloseWindow();
end	

function ArtToolsPage.OnClickMapPosPage()
	Map3DSystem.App.Commands.Call("File.MapPosLogPage");
	page:CloseWindow();
end	

function ArtToolsPage.OnPlayAnimID()
	local animID = document:GetPageCtrl():GetUIValue("animID", "0");
	animID = tonumber(string.match(animID, "%d+"));
	if(animID~=nil) then
		ParaScene.GetPlayer():ToCharacter():PlayAnimation(animID);
	end
end

function ArtToolsPage.OnClickCCSItemEditor()
	Map3DSystem.App.Commands.Call("Profile.CCS.ItemEditor");
	page:CloseWindow();
end

function ArtToolsPage.OnClickGenMiniMapPage()
	Map3DSystem.App.Commands.Call("Profile.GenerateMiniMap");
	page:CloseWindow();
end

function ArtToolsPage.OnClickPortalEditor()
	Map3DSystem.App.Commands.Call("Creation.PortalSystem");
	page:CloseWindow();
end

function ArtToolsPage.OnClickToggleClickMove()
	if(not Map3DSystem.options.StopClickMoveChar) then
		Map3DSystem.options.StopClickMoveChar = false;
	end
	Map3DSystem.options.StopClickMoveChar = not Map3DSystem.options.StopClickMoveChar;
end
