--[[
Title: Macro Player
Author(s): LiXizhi
Date: 2021/1/4
Desc: Macro Player page

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/MacroPlayer.lua");
local MacroPlayer = commonlib.gettable("MyCompany.Aries.Game.Tasks.MacroPlayer");
MacroPlayer.ShowPage();
MacroPlayer.ShowController(false);
-------------------------------------------------------
]]
local KeyEvent = commonlib.gettable("System.Windows.KeyEvent");
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local MacroPlayer = commonlib.inherit(nil, commonlib.gettable("MyCompany.Aries.Game.Tasks.MacroPlayer"));
local page;

function MacroPlayer.OnInit()
	page = document:GetPageCtrl();
	GameLogic.GetFilters():add_filter("Macro_EndPlay", MacroPlayer.OnEndPlay);
	GameLogic.GetFilters():add_filter("Macro_PlayMacro", MacroPlayer.OnPlayMacro);
end

-- @param duration: in seconds
function MacroPlayer.ShowPage()
	MacroPlayer.expectedButton = nil;
	MacroPlayer.expectedKeyButton = nil;
	MacroPlayer.expectedDragButton = nil;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Creator/Game/Macros/MacroPlayer.html", 
			name = "MacroPlayerTask.ShowPage", 
			app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			isShowTitleBar = false,
			bShow = true,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1000,
			allowDrag = false,
			isTopLevel = true,
			directPosition = true,
				align = "_fi",
				x = 0,
				y = 0,
				width = 0,
				height = 0,
		});
	local keyPress = page:FindControl("keyPress");
	if(keyPress) then
		keyPress:SetScript("onkeydown", function()
			local event = KeyEvent:init("keyPressEvent")
			MacroPlayer.OnKeyDown(event)
		end);
	end
	MacroPlayer.ShowCursor(false);
	MacroPlayer.ShowKeyPress(false);
	MacroPlayer.ShowDrag(false);
	MacroPlayer.ShowTip()
	MacroPlayer.ShowEditBox(false);
	
	if(GameLogic.IsReadOnly()) then
		MacroPlayer.ShowController(false);
	end
end

function MacroPlayer.OnPlayMacro(fromLine, macros)
	local progress = math.floor(fromLine / (#macros)*100 + 0.5);
	if(page) then
		page:SetValue("progress", progress);
	end
	return fromLine;
end

function MacroPlayer.OnEndPlay()
	MacroPlayer.CloseWindow();
end

function MacroPlayer.CloseWindow()
	if(page) then
		page:CloseWindow();
		page = nil;
	end
end

function MacroPlayer.OnClickStop()
	GameLogic.Macros:Stop()
end


function MacroPlayer.InvokeTriggerCallback()
	if(MacroPlayer.triggerCallbackFunc) then
		MacroPlayer.triggerCallbackFunc()
		MacroPlayer.triggerCallbackFunc = nil;
	end
end

function MacroPlayer.SetTriggerCallback(callback)
	MacroPlayer.triggerCallbackFunc = callback;
end

local cursorTick = 0;
function MacroPlayer.AnimCursorBtn(bRestart)
	if(page) then
		local cursor = page:FindControl("cursorClick");
		if(MacroPlayer.isDragging) then
			local cursorBtn = page:FindControl("cursorBtn")
			cursorBtn.visible = false
		elseif(cursor and cursor.visible) then
			local x, y, width, height = cursor:GetAbsPosition();
			x = x + 12;
			y = y + 15;
			local cursorBtn = page:FindControl("cursorBtn")
			cursorBtn.visible = true;

			local mouseX, mouseY = ParaUI.GetMousePosition();
			
			local totalTicks = 30;
			cursorTick = bRestart and 0 or (cursorTick + 1);
			local progress = (totalTicks - cursorTick) / totalTicks;
			if(cursorTick >= totalTicks) then
				cursorTick = 0;
			end
			local diffDistance = math.sqrt((mouseX - x)^2 + (mouseY - y)^2)
			if( diffDistance > 16 ) then
				cursorBtn.translationx = math.floor((mouseX - x) * progress + 0.5);
				cursorBtn.translationy = math.floor((mouseY - y) * progress + 0.5);
				MacroPlayer.animCursorTimer = MacroPlayer.animCursorTimer or commonlib.Timer:new({callbackFunc = function(timer)
					MacroPlayer.AnimCursorBtn()
				end})
			else
				cursorBtn.translationx = 0;
				cursorBtn.translationy = 0;
				cursorTick = 0;
			end
			if(MacroPlayer.animCursorTimer) then
				MacroPlayer.animCursorTimer:Change(30);
			end
		end
	end
end

function MacroPlayer.AnimKeyPressBtn(bRestart)
	if(page) then
		local keyPress = page:FindControl("keyPress");
		if(keyPress and keyPress.visible) then
			-- this is important to always focus to the key press control in case the user has clicked elsewhere.
			keyPress:Focus();
			MacroPlayer.animKeyPressTimer = MacroPlayer.animKeyPressTimer or commonlib.Timer:new({callbackFunc = function(timer)
				MacroPlayer.AnimKeyPressBtn()
			end})
			MacroPlayer.animKeyPressTimer:Change(100);
		end
	end
end

local keyMaps = {
	["SLASH"] = "/?",
	["MINUS"] = "-_",
	["PERIOD"] = ".",
	["COMMA"] = ",",
	["SPACE"] = L"空格",
	["EQUALS"] = "=+",
	["ESCAPE"] = "ESC",
}
local function ConvertKeyNameToButtonText(btnText)
	if(btnText) then
		btnText = btnText:gsub("DIK_", "")
		btnText = string.upper(btnText);
		btnText = keyMaps[btnText] or btnText;
	end
	return btnText
end

function MacroPlayer.ShowKeyPress(bShow, button)
	if(page) then
		local keyPress = page:FindControl("keyPress");
		if(keyPress) then
			keyPress.visible = bShow;
			if(bShow) then
				keyPress:SetField("CanHaveFocus", true); 
				keyPress:Focus();

				button = button or ""
				local buttons = {};
				for text in button:gmatch("([%w_]+)") do
					buttons[#buttons+1] = text;
				end
				local left = 5;
				for i=1, 3 do
					local keyBtn = page:FindControl("key"..i);
					local btnText = buttons[i];
					if(btnText) then
						btnText = ConvertKeyNameToButtonText(btnText)
						keyBtn.text = btnText;
						keyBtn.visible = true;
						keyBtn.translationx = left;
						keyBtn:ApplyAnim();
						left = left + keyBtn.width + 5;
					else
						keyBtn.visible = false
					end
				end
				MacroPlayer.AnimKeyPressBtn(true)
			else
				keyPress:SetField("CanHaveFocus", false); 
			end
		end
	end
end

function MacroPlayer.ShowController(bShow)
	if(page) then
		local progressController = page:FindControl("progressController");
		if(progressController) then
			progressController.visible = bShow;
		end
	end
end

-- make it top level anyway, since some other top level window may be called before. 
function MacroPlayer.SetTopLevel()
	if(page) then
		local win = page:GetRootUIObject()
		if(win) then
			-- tricky: this will force bring this window to the top of all top level windows.
			win:SetTopLevel(false);
			win:SetTopLevel(true);
		end
	end
end

function MacroPlayer.ShowCursor(bShow, x, y, button)
	if(page) then
		local cursor = page:FindControl("cursorClick");
		if(cursor) then
			cursor.visible = bShow;
			if(bShow) then
				MacroPlayer.SetTopLevel();
				
				if(x and y) then
					cursor.x = x - 16;
					cursor.y = y - 16;
				end
				button = button or "";
				local left = 16 + 32;
				
				local shiftKey = page:FindControl("shiftKey")
				if(button:match("shift")) then
					shiftKey.visible = true;
					shiftKey.translationx = left;
					shiftKey:ApplyAnim();
					left = left + shiftKey.width + 5;
				else
					shiftKey.visible = false;
				end
				local ctrlKey = page:FindControl("ctrlKey")
				if(button:match("ctrl")) then
					ctrlKey.visible = true;
					ctrlKey.translationx = left;
					ctrlKey:ApplyAnim();
					left = left + ctrlKey.width + 5;
				else
					ctrlKey.visible = false;
				end
				local altKey = page:FindControl("altKey")
				if(button:match("alt")) then
					altKey.visible = true;
					altKey.translationx = left;
					altKey:ApplyAnim();
					left = left + altKey.width + 5;
				else
					altKey.visible = false;
				end


				local mouseBtn = page:FindControl("mouseBtn")
				if(button:match("left")) then
					mouseBtn.visible = true;
					mouseBtn.background = "Texture/Aries/Quest/TutorialMouse_LeftClick_small_32bits.png";
					mouseBtn.translationx = left;
					left = left + 32 + 5;
				elseif(button:match("right")) then
					mouseBtn.visible = true;
					mouseBtn.background = "Texture/Aries/Quest/TutorialMouse_RightClick_small_32bits.png";
					mouseBtn.translationx = left;
					left = left + 32 + 5;
				else
					mouseBtn.visible = false;
				end

				MacroPlayer.AnimCursorBtn(true);
			end
		end
	end
end

-- @return true if user is pressing correct button or false if not. 
function MacroPlayer.CheckButton(button)
	button = button or "";
	local isOK = true;
	if(button:match("left") and mouse_button ~= "left") then
		isOK = false
	end
	if(button:match("right") and mouse_button ~= "right") then
		isOK = false
	end
	if(button:match("ctrl") and not (ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LCONTROL) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RCONTROL))) then
		isOK = false
	end
	if(button:match("shift") and not (ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LSHIFT) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RSHIFT))) then
		isOK = false
	end
	if(button:match("alt") and not (ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LMENU) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RMENU))) then
		isOK = false
	end
	return isOK;
end

function MacroPlayer.OnClickCursor()
	if(MacroPlayer.expectedDragButton) then
		GameLogic.AddBBS("Macro", L"按住鼠标左键不要放手， 同时拖动鼠标到目标点", 5000, "255 0 0");
		return;
	elseif(MacroPlayer.expectedKeyButton and not MacroPlayer.expectedEditBoxText) then
		GameLogic.AddBBS("Macro", L"鼠标移动到这里，但不要点击", 5000, "255 0 0");
		return
	end
	
	local isOK = MacroPlayer.CheckButton(MacroPlayer.expectedButton);
	if(isOK) then
		if(MacroPlayer.expectedEditBoxText) then
			if(not MacroPlayer.expectedButton) then
				GameLogic.AddBBS("Macro", L"请按照指示输入文字", 5000, "255 0 0");
				return;
			else
				MacroPlayer.expectedEditBoxText = nil;
				MacroPlayer.ShowEditBox(false)
			end
		end
		MacroPlayer.expectedButton = nil;
		MacroPlayer.ShowCursor(false)
		MacroPlayer.InvokeTriggerCallback()
	end
end

function MacroPlayer.OnKeyDown(event)
	local button = MacroPlayer.expectedKeyButton or "";
	local isOK = true;
	if(button:match("ctrl") and not event.ctrl_pressed) then
		isOK = false
	end
	if(button:match("shift") and not event.shift_pressed) then
		isOK = false
	end
	if(button:match("alt") and not event.alt_pressed) then
		isOK = false
	end
	local keyname = button:match("(DIK_%w+)");
	if(keyname and keyname~=event.keyname) then
		isOK = false
	end
	local mouseX, mouseY = GameLogic.Macros.GetNextKeyPressWithMouseMove()
	if(mouseX and mouseY) then
		local mX, mY = ParaUI.GetMousePosition()
		local diffDistance = math.sqrt((mouseX - mX)^2 + (mouseY - mY)^2)
		if(diffDistance > 16) then
			isOK = false
			GameLogic.AddBBS("Macro", L"请将鼠标移动到目标点，再按键盘", 5000, "255 0 0");
		end
	end

	if(isOK) then
		if(MacroPlayer.expectedEditBoxText) then
			MacroPlayer.expectedEditBoxText = nil;
			MacroPlayer.ShowEditBox(false)
		end
		MacroPlayer.expectedKeyButton = nil;
		MacroPlayer.ShowKeyPress(false)
		MacroPlayer.ShowCursor(false);
		MacroPlayer.InvokeTriggerCallback()
	end
end

function MacroPlayer.SetClickTrigger(mouseX, mouseY, button, callbackFunc)
	if(page) then
		MacroPlayer.expectedButton = button;
		MacroPlayer.SetTriggerCallback(callbackFunc)
		MacroPlayer.ShowCursor(true, mouseX, mouseY, button)
	end
end

function MacroPlayer.SetKeyPressTrigger(button, callbackFunc)
	if(page) then
		MacroPlayer.expectedKeyButton = button;
		local mouseX, mouseY = GameLogic.Macros.GetNextKeyPressWithMouseMove()
		if(mouseX and mouseY) then
			MacroPlayer.ShowCursor(true, mouseX, mouseY)	
		end
		MacroPlayer.SetTriggerCallback(callbackFunc)
		MacroPlayer.ShowKeyPress(true, button)
	end
end

function MacroPlayer.SetEditBoxTrigger(mouseX, mouseY, text, textDiff, callbackFunc)
	if(page) then
		MacroPlayer.expectedEditBoxText = text;
		MacroPlayer.ShowEditBox(true, text, textDiff)
		MacroPlayer.SetTriggerCallback(callbackFunc)

		-- if we do not need user to enter text, just click to enter
		local keyButtons = Macros.TextToKeyName(textDiff)
		if(keyButtons) then
			MacroPlayer.expectedKeyButton = keyButtons; 
			Macros.SetNextKeyPressWithMouseMove(mouseX, mouseY);
			MacroPlayer.ShowKeyPress(true, keyButtons)
			MacroPlayer.ShowCursor(true, mouseX, mouseY);
		else
			MacroPlayer.expectedButton = "left";
			MacroPlayer.ShowCursor(true, mouseX, mouseY);
		end
	end
end

local dragTick = 0;
function MacroPlayer.AnimDragBtn(bRestart)
	if(page) then
		local startPoint = page:FindControl("startPoint");
		local endPoint = page:FindControl("endPoint");
		if(MacroPlayer.isDragging) then
			startPoint.translationx = 0
			startPoint.translationy = 0
		elseif(startPoint and startPoint.visible) then
			local startX, startY = startPoint:GetAbsPosition();
			local endX, endY = endPoint:GetAbsPosition();
			
			local diffDistance = math.sqrt((endX - startX)^2 + (endY - startY)^2)

			local totalTicks = 80;
			dragTick = bRestart and 0 or (dragTick + 1);
			local progress = (dragTick) / totalTicks;
			if(dragTick >= totalTicks) then
				dragTick = 0;
			end
			
			if( diffDistance > 16 ) then
				startPoint.translationx = math.floor((endX - startX) * progress + 0.5);
				startPoint.translationy = math.floor((endY - startY) * progress + 0.5);
				MacroPlayer.animDragTimer = MacroPlayer.animDragTimer or commonlib.Timer:new({callbackFunc = function(timer)
					MacroPlayer.AnimDragBtn()
				end})
			else
				startPoint.translationx = 0;
				startPoint.translationy = 0;
				dragTick = 0;
			end
			if(MacroPlayer.animDragTimer) then
				MacroPlayer.animDragTimer:Change(30);
			end
		end
	end
end

function MacroPlayer.ShowDrag(bShow, startX, startY, endX, endY, button)
	if(page) then
		local dragPoints = page:FindControl("dragPoints");
		if(dragPoints) then
			dragPoints.visible = bShow;
			if(bShow) then
				local startPoint = page:FindControl("startPoint")
				startPoint.x = startX - 16;
				startPoint.y = startY - 16;
				
				local endPoint = page:FindControl("endPoint")
				endPoint.x = endX - 16;
				endPoint.y = endY - 16;

				MacroPlayer.AnimDragBtn(true)
			end
		end
	end
end

function MacroPlayer.SetDragTrigger(startX, startY, endX, endY, button, callbackFunc)
	if(page) then
		MacroPlayer.expectedDragButton = button;
		MacroPlayer.SetTriggerCallback(callbackFunc)
		MacroPlayer.ShowDrag(true, startX, startY, endX, endY, button)
		MacroPlayer.ShowCursor(true, startX, startY, button)
	end
end

function MacroPlayer.OnDragBegin()
	MacroPlayer.isDragging = true;
	MacroPlayer.isDragButtonCorrect = MacroPlayer.CheckButton(MacroPlayer.expectedDragButton);
	MacroPlayer.isReachedDragTarget = false;
end

function MacroPlayer.OnDragMove()
	if(page) then
		local curPoint = page:FindControl("cursorClick");
		local endPoint = page:FindControl("endPoint");
		if(curPoint) then
			local startX, startY = curPoint:GetAbsPosition();
			local endX, endY = endPoint:GetAbsPosition();
			local diffDistance = math.sqrt((endX - startX)^2 + (endY - startY)^2)
			MacroPlayer.isReachedDragTarget = (diffDistance < 16);
		end
	end

	MacroPlayer.isDragButtonCorrect = MacroPlayer.isDragButtonCorrect and MacroPlayer.CheckButton(MacroPlayer.expectedDragButton);
	if(not MacroPlayer.isDragButtonCorrect) then
		-- TODO: tell user to press correct user
	end
end

function MacroPlayer.OnDragEnd()
	MacroPlayer.isDragging = false;
	MacroPlayer.isDragButtonCorrect = MacroPlayer.isDragButtonCorrect and MacroPlayer.CheckButton(MacroPlayer.expectedDragButton);
	if(MacroPlayer.isDragButtonCorrect) then
		if(MacroPlayer.isReachedDragTarget) then
			MacroPlayer.expectedDragButton = nil;
			MacroPlayer.isReachedDragTarget = nil;
			MacroPlayer.ShowDrag(false)
			MacroPlayer.ShowCursor(false)
			MacroPlayer.InvokeTriggerCallback()
			return
		else
			-- TODO: tell the user to drag to the target location. 
		end
	else
		-- TODO: tell user to press correct user
	end
	MacroPlayer.AnimDragBtn(true)
	MacroPlayer.AnimCursorBtn(true);
end

-- @param text: text or mcml text.  if nil, we will hide it. 
function MacroPlayer.ShowTip(text)
	if(page) then
		local tipWnd = page:FindControl("tipWnd");
		if(text and text~="") then
			tipWnd.visible = true;
			page:SetUIValue("tipText", text)
		else
			tipWnd.visible = false;
			page:SetUIValue("tipText", "")
		end
	end	
end

function MacroPlayer.ShowEditBox(bShow, text, textDiff)
	if(page) then
		local editBox = page:FindControl("editBox");
		editBox.visible = bShow;
		if(bShow) then
			page:SetUIValue("editboxText", text or "")
		end
	end	
end
