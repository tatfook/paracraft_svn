--[[
Title: Navagation mode in main bar for 3D Map system
Author(s): WangTian
Date: 2007/9/18
Desc: navigation mode function
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/NavMode.lua");
------------------------------------------------------------
Note: for all main bar function icon:
"(gl)script/kids/3DMapSystemData/TableDef.lua": 
		TableTable defination
"(gl)script/kids/3DMapSystemData/MainBarData.lua": 
		Register the onclick callback function
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");

function Map3DSystem.UI.NavMode.OnClick()

	--_guihelper.MessageBox("NavMode click");
	
	local _icon = ParaUI.GetUIObject("MainBar_icons_12");
	if(_icon:IsValid() == true) then
		if(Map3DSystem.UI.NavMode.CurrentMode == "object") then
			--normalImage = "Texture/3DMapSystem/MainBarIcon/navigate_n.png";
			--mouseoverImage = "Texture/3DMapSystem/MainBarIcon/navigate_o.png";
			--disableImage = "Texture/3DMapSystem/MainBarIcon/navigate_d.png";
			--_guihelper.SetVistaStyleButton3(_icon, normalImage, mouseoverImage, disableImage);
			Map3DSystem.UI.MainBar.IconSet[12].NormalIconPath = "Texture/3DMapSystem/MainBarIcon/NavModeOff.png; 0 0 48 48";
			Map3DSystem.UI.NavMode.CurrentMode = "navigate";
			
			local _quickLaunch = ParaUI.GetUIObject("CreationQuickLaunchBar");
			_quickLaunch.visible = false;
			
			_quickLaunch = ParaUI.GetUIObject("AnimationQuickLaunchBar");
			_quickLaunch.visible = false;
			
			Map3DSystem.UI.MainPanel.SendMeMessage({type = CommonCtrl.os.MSGTYPE.WM_CLOSE});
			Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_NavMode, bNavMode = true});
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
			
		elseif(Map3DSystem.UI.NavMode.CurrentMode == "navigate") then
			--normalImage = "Texture/3DMapSystem/MainBarIcon/object_n.png";
			--mouseoverImage = "Texture/3DMapSystem/MainBarIcon/object_o.png";
			--disableImage = "Texture/3DMapSystem/MainBarIcon/object_d.png";
			--_guihelper.SetVistaStyleButton3(_icon, normalImage, mouseoverImage, disableImage);
			Map3DSystem.UI.MainBar.IconSet[12].NormalIconPath = "Texture/3DMapSystem/MainBarIcon/NavModeOn.png; 0 0 48 48";
			Map3DSystem.UI.NavMode.CurrentMode = "object";
			
			local _quickLaunch = ParaUI.GetUIObject("CreationQuickLaunchBar");
			_quickLaunch.visible = true;
			
			_quickLaunch = ParaUI.GetUIObject("AnimationQuickLaunchBar");
			_quickLaunch.visible = true;
			
			Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_NavMode, bNavMode = false});
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
			
		--elseif(Map3DSystem.UI.NavMode.CurrentMode == "object") then
			----normalImage = "Texture/3DMapSystem/MainBarIcon/light_n.png";
			----mouseoverImage = "Texture/3DMapSystem/MainBarIcon/light_o.png";
			----disableImage = "Texture/3DMapSystem/MainBarIcon/light_d.png";
			----_guihelper.SetVistaStyleButton3(_icon, normalImage, mouseoverImage, disableImage);
			--_icon.background = "Texture/3DMapSystem/MainBarIcon/Light_1.png";
			--Map3DSystem.UI.NavMode.CurrentMode = "light";
		end
		
		--if(Map3DSystem.UI.NavMode.CurrentMode == "light") then
			--ParaScene.GetAttributeObject():SetField("ShowLights", true);
		--else
			--ParaScene.GetAttributeObject():SetField("ShowLights", false);
		--end
	end
	
end

function Map3DSystem.UI.NavMode.OnMouseEnter()
end

function Map3DSystem.UI.NavMode.OnMouseLeave()
end

-- switch to navigation mode
-- @param bNav: true to navigation mode, false to allow BCS or other creation clues
function Map3DSystem.UI.NavMode.SwitchNavMode(bNav)
	
	if(bNav == true) then
		--normalImage = "Texture/3DMapSystem/MainBarIcon/navigate_n.png";
		--mouseoverImage = "Texture/3DMapSystem/MainBarIcon/navigate_o.png";
		--disableImage = "Texture/3DMapSystem/MainBarIcon/navigate_d.png";
		--_guihelper.SetVistaStyleButton3(_icon, normalImage, mouseoverImage, disableImage);
		--Map3DSystem.UI.MainBar.IconSet[12].NormalIconPath = "Texture/3DMapSystem/MainBarIcon/NavModeOff.png; 0 0 48 48";
		Map3DSystem.UI.NavMode.CurrentMode = "navigate";
		
		--local _quickLaunch = ParaUI.GetUIObject("CreationQuickLaunchBar");
		--_quickLaunch.visible = false;
		--
		--_quickLaunch = ParaUI.GetUIObject("AnimationQuickLaunchBar");
		--_quickLaunch.visible = false;
		
		--Map3DSystem.UI.MainPanel.SendMeMessage({type = CommonCtrl.os.MSGTYPE.WM_CLOSE});
		--Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_NavMode, bNavMode = true});
		Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
		
	elseif(bNav == false) then
		--normalImage = "Texture/3DMapSystem/MainBarIcon/object_n.png";
		--mouseoverImage = "Texture/3DMapSystem/MainBarIcon/object_o.png";
		--disableImage = "Texture/3DMapSystem/MainBarIcon/object_d.png";
		--_guihelper.SetVistaStyleButton3(_icon, normalImage, mouseoverImage, disableImage);
		--Map3DSystem.UI.MainBar.IconSet[12].NormalIconPath = "Texture/3DMapSystem/MainBarIcon/NavModeOn.png; 0 0 48 48";
		Map3DSystem.UI.NavMode.CurrentMode = "object";
		
		--local _quickLaunch = ParaUI.GetUIObject("CreationQuickLaunchBar");
		--_quickLaunch.visible = true;
		--
		--_quickLaunch = ParaUI.GetUIObject("AnimationQuickLaunchBar");
		--_quickLaunch.visible = true;
		
		--Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_NavMode, bNavMode = false});
		Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
	end
end