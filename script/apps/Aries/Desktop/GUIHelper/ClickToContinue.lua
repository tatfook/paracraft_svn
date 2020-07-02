--[[
Title: Click to continue when app lost focus
Author(s): LiXizhi
Date: 2010/9/2
Desc: In a web browser, when the window loses focus, the render frame rate will be low, 
we should tell the user to click on the window to continue. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/ClickToContinue.lua");
local ClickToContinue = commonlib.gettable("MyCompany.Aries.Desktop.GUIHelper.ClickToContinue");
ClickToContinue.FrameMove();
------------------------------------------------------------
]]
local ClickToContinue = commonlib.gettable("MyCompany.Aries.Desktop.GUIHelper.ClickToContinue");

local bHasShownOverLay = false;
-- only only when in web browser mode
local bOnlyShownInWebBrowserMode = true;
local page;
local last_render_time = 0;

-- call this function regularly to check for app focus and automatically display the UI. 
-- this function is usually called at interval 0.5 seconds
function ClickToContinue.FrameMove(bForceMove)
	if(bForceMove or not bOnlyShownInWebBrowserMode or System.options.IsWebBrowser) then
		local bAppHasFocus = ParaEngine.GetAttributeObject():GetField("AppHasFocus", true);
		if(System.options.disable_click_to_continue) then
			bAppHasFocus = true;
		end

		ClickToContinue.Show(not bAppHasFocus);

		-- automatically adjust frame rate so that it is very low 0.5 FPS when in web browser mode and focus is lost. 
		if(bAppHasFocus) then
			ParaEngine.GetAttributeObject():SetField("Enable3DRendering", true) 
		else
			local curTime = ParaGlobal.timeGetTime();
			if( (curTime - last_render_time)>300 ) then
				last_render_time = curTime;
				ParaEngine.GetAttributeObject():SetField("Enable3DRendering", true);
				ClickToContinue.timer = ClickToContinue.timer or commonlib.Timer:new({callbackFunc = function(timer)
					ParaEngine.GetAttributeObject():SetField("Enable3DRendering", false);
				end})
				ClickToContinue.timer:Change(10,nil);
			end

			ClickToContinue.frame_timer = ClickToContinue.frame_timer or commonlib.Timer:new({callbackFunc = function(timer)
				local bAppHasFocus = ParaEngine.GetAttributeObject():GetField("AppHasFocus", true);
				if(bAppHasFocus) then
					ClickToContinue.FrameMove(true);
					timer:Change();
				end
			end})
			ClickToContinue.frame_timer:Change(10,10);
		end
	end
	
end

-- show/hide the overlay
function ClickToContinue.Show(bShow)
	if(bShow) then
		local ui_object = ParaUI.GetUIObject("_click_to_continue_");
		if (ui_object:IsValid()) then
			if(not ui_object.visible) then
				ui_object.visible = true;
				LOG.std("", "system", "ClickToContinue", "app lost focus and click to continue is shown")
			end
		else
			ui_object = ParaUI.CreateUIObject("container", "_click_to_continue_", "_fi", 0,0,0,0);
			ui_object.background = "";
			ui_object.zorder = 6000;
			ui_object:AttachToRoot();

			if(not page) then
				page = Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Desktop/GUIHelper/ClickToContinue.html"});
			end

			page:Create("ClickToContinue", ui_object, "_fi", 0, 0, 0, 0);
			LOG.std("", "system", "ClickToContinue", "app lost focus and click to continue is shown")
		end
		bHasShownOverLay = true;
	elseif(bShow == false) then
		bHasShownOverLay = false;
		local ui_object = ParaUI.GetUIObject("_click_to_continue_");
		if (ui_object:IsValid() and ui_object.visible) then
			ui_object.visible = false;
			LOG.std("", "system", "ClickToContinue", "app focus gain and click to continue is hidden")	
			ClickToContinue.OnShowDelayMask();
		end
	end
end

-- delay one second. 
function ClickToContinue.OnShowDelayMask(duration)
	local _this = ParaUI.GetUIObject("_click_to_continue_delay_");
	if(not _this:IsValid()) then
		_this = ParaUI.CreateUIObject("button", "_click_to_continue_delay_", "_fi", 0,0,0,0);
		_this.background = "";
		_this:SetScript("onclick", ClickToContinue.RemoveDelayMask);
		_this.zorder = 6000;
		_this:AttachToRoot();
		ClickToContinue.hide_timer = ClickToContinue.hide_timer or commonlib.Timer:new({callbackFunc = function(timer)
			ClickToContinue.RemoveDelayMask();
		end})
		-- delay for one seconds
		ClickToContinue.hide_timer:Change(duration or 1000,nil);
	end
end

function ClickToContinue.RemoveDelayMask()
	ParaUI.Destroy("_click_to_continue_delay_");
end

-- called by the mcml page. 
function ClickToContinue.Hide()
	ClickToContinue.Show(false);
end