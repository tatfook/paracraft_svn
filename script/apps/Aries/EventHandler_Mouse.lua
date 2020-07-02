--[[
Title: Mouse Cursor and click management for Aries App
Author(s): WangTian
Date: 2009/6/27
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/EventHandler_Mouse.lua");
local HandleMouse = commonlib.gettable("MyCompany.Aries.HandleMouse");
HandleMouse.SetCursorTextStyle(default_cursor_text_style, true)
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Player/main.lua");
NPL.load("(gl)script/apps/Aries/Scene/AutoCameraController.lua");
-- create class
local HandleMouse = commonlib.gettable("MyCompany.Aries.HandleMouse");
local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");
local AutoCameraController = commonlib.gettable("MyCompany.Aries.AutoCameraController");
local Player = commonlib.gettable("MyCompany.Aries.Player");

local default_cursor_text_style = {background="Texture/tooltip2_32bits.PNG: 6 8 5 6", 
	bg_line1="Texture/tooltip2_32bits.PNG;0 0 16 8:6 5 5 2", 
	bg_line2="Texture/tooltip2_32bits.PNG; 0 8 16 8: 6 2 5 5", 
	colormask="255 255 255 255", Spacing=4} 

-- set cursor text style
-- @param style: a table of {background="Texture/tooltip2_32bits.PNG: 6 8 5 6", bg_line1, bg_line2, colormask="255 255 255 204", Spacing=4}. if nil, it will simply apply the default default_cursor_text_style.
-- @param bPostponeUI: if true, it will delay creating the UI object until used. if UI object is already created, it will upate them though. 
function HandleMouse.SetCursorTextStyle(style, bPostponeUI)
	if(style) then
		default_cursor_text_style = style;
	else
		style = default_cursor_text_style;
	end
	
	local _cursorText = ParaUI.GetUIObject("AriesCursorText");
	local _cursorText2 = ParaUI.GetUIObject("AriesCursorText2");
	if(_cursorText:IsValid() == false) then
		if(bPostponeUI) then
			return;
		end
		-- NOTE: create the cursor text beyond the screen area and translation the object to the cursor position
		_cursorText = ParaUI.CreateUIObject("button", "AriesCursorText", "_lt", 0, -100, 1000, 24); 
		_cursorText.enabled = false;

		_cursorText.zorder = -1; -- stay below other ui objects, by LiXizhi 2009.8.14
		_guihelper.SetUIColor(_cursorText, "255 255 255")
		_cursorText:AttachToRoot();
	end
	_cursorText.background = style.background or "";
	_cursorText.colormask = style.colormask or "255 255 255 255";
	_cursorText:GetAttributeObject():SetField("Spacing", style.Spacing or 4);

	if(_cursorText2:IsValid() == false) then
		-- NOTE: create the cursor text beyond the screen area and translation the object to the cursor position
		_cursorText2 = ParaUI.CreateUIObject("button", "AriesCursorText2", "_lt", 0, -76, 1000, 24); 
		_cursorText2.enabled = false;
		_cursorText2.zorder = -1; -- stay below other ui objects, by LiXizhi 2009.8.14
		_guihelper.SetUIColor(_cursorText2, "255 255 255")
		_cursorText2:GetFont("text").format = 0; -- DT_TOP (0x00000000)
		_cursorText2:AttachToRoot();
	end
	_cursorText2.background = style.background or "";
	_cursorText2.colormask = style.colormask or "255 255 255 255";
	_cursorText2:GetAttributeObject():SetField("Spacing", style.Spacing or 4);
end

-- show cursor text like tooltip of ui object
-- @param text: text shown in cursor text area, if nil or empty string, it will hide the cursor text
-- NOTE: this function make an assumption that HandleMouse.ShowCursorForSceneObject() function is called on every mouse move
--		otherwise the tooltip position and content will not be updated
function HandleMouse.ShowCursorText(text, text2, font, fontcolor)
	local _cursorText = ParaUI.GetUIObject("AriesCursorText");
	local _cursorText2 = ParaUI.GetUIObject("AriesCursorText2");
	if(not _cursorText:IsValid() or not _cursorText2:IsValid()) then
		HandleMouse.SetCursorTextStyle();
	end

	if(text == nil or text == "") then
		_cursorText.visible = false;
		_cursorText2.visible = false;
		return;
	end
	if(text2 == nil or text2 == "") then
		_cursorText2.visible = false;
		text2 = "";
		_cursorText.background = default_cursor_text_style.background;
	else
		_cursorText2.visible = true;
		_cursorText.background = default_cursor_text_style.bg_line1;
		_cursorText2.background = default_cursor_text_style.bg_line2;
	end
	
	_cursorText.text = text;
	_cursorText2.text = text2;
	if(font) then
		_cursorText.font = font;
		_cursorText2.font = font;
	end
	if(fontcolor) then
		_guihelper.SetFontColor(_cursorText, fontcolor);
		_guihelper.SetFontColor(_cursorText2, fontcolor);
	end
	local width = _guihelper.GetTextWidth(text, font or System.DefaultFontString);
	local width2 = _guihelper.GetTextWidth(text2, font or System.DefaultFontString);
	local mouseX, mouseY = ParaUI.GetMousePosition();
	_cursorText.translationx = mouseX;
	_cursorText.translationy = 100 + mouseY + 24;
	_cursorText.width = math.max(width, width2) + 10;
	_cursorText.visible = true;
	_cursorText2.translationx = mouseX;
	_cursorText2.translationy = 100 + mouseY + 24;
	_cursorText2.width = math.max(width, width2) + 10;
end

-- get the cursor from game scene object
-- this function is called on mouse move in system event handler
-- @param obj:
function HandleMouse.ShowCursorForSceneObject(obj, bAlwaysShow)
	if(obj ~= nil and obj:IsValid() and obj:IsCharacter()) then
		if(TargetArea.IsShown or bAlwaysShow) then
			local text, text2 = TargetArea.GetCursorTextFromSceneObject(obj);
			HandleMouse.ShowCursorText(text, text2, System.DefaultFontString, "35 35 35");
			return TargetArea.GetCursorFromSceneObject(obj);
		end	
	end
	HandleMouse.ShowCursorText("");
end

-- clear cursor text and highlighted object. 
function HandleMouse.ClearCursorSelection()
	local cursor, cursorfile = HandleMouse.ShowCursorForSceneObject(nil);
	ParaSelection.ClearGroup(2);
	ParaSelection.ClearGroup(0);
	
	Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_CURSOR, cursor = cursor, cursorfile = cursorfile})
end

local enable_hold_left_mouse_move = false;
-- when mouse is down
function HandleMouse.OnMouseDown(nCode, appName, msg)
	if(enable_hold_left_mouse_move) then
		if(msg.mouse_button == "left") then
			if(not HandleMouse.left_move_timer) then
				HandleMouse.left_move_timer = commonlib.Timer:new({callbackFunc = function(timer)
					if(ParaUI.IsMousePressed(0)) then
						-- left button is down
						Map3DSystem.HandleMouse.MoveToMouseCursorPick();
					else
						timer:Change();
					end
				end})
			end
			HandleMouse.left_move_timer:Change(10, 300);
		end	
	end
end


-- when mouse moves
-- msg.cursor is the cursor object, msg.obj contains the mouse over scene object. 
function HandleMouse.OnMouseMove(nCode, appName, msg)
	if(not msg.IsMouseDown) then
		local cursor, cursorfile;
		if(msg.obj) then
			local group = msg.obj:GetSelectGroupIndex();
			if(group ~= 2) then
				if(group <= 0) then
					if(not Player.IsSelfObjectName(msg.obj.name)) then
						-- do not highlight the current player, because it is visually dirty. 
						ParaSelection.AddObject(msg.obj, 2);
					end
					cursor, cursorfile = HandleMouse.ShowCursorForSceneObject(msg.obj, msg.bAlwaysShow);
					msg.cursor = cursor;
				else
					cursor, cursorfile = HandleMouse.ShowCursorForSceneObject(nil);
					ParaSelection.ClearGroup(2);
				end	
				Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_CURSOR, cursor = cursor, cursorfile = cursorfile})
			end
		else
			local cursor, cursorfile = HandleMouse.ShowCursorForSceneObject(nil);
			ParaSelection.ClearGroup(2);
			Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_CURSOR, cursor = cursor, cursorfile = cursorfile})
		end
	end
end


local MainToolBar = commonlib.gettable("MyCompany.Aries.Creator.MainToolBar")
local ReplayMode = commonlib.gettable("MyCompany.Aries.Movie.ReplayMode");
NPL.load("(gl)script/apps/Aries/Creator/ContextMenu.lua");

local last_move_pos = {};
local jump_timer = commonlib.Timer:new({callbackFunc = function(timer)
	last_move_pos.tick_count = last_move_pos.tick_count + 1;
	if(last_move_pos.tick_count >= 8) then
		timer:Change();
		return;
	end
	if(Player.IsInAir()) then
		Map3DSystem.HandleMouse.MovePlayerToPoint(last_move_pos.to_x, last_move_pos.to_y, last_move_pos.to_z);
	else
		Player.Jump();
	end
end})

function HandleMouse.OnMouseUp(nCode, appName, msg)
	if(msg.action == "walkpoint") then
		if(not ReplayMode.IsRecording()) then
			-- resume recording 
			ReplayMode.ResumeRecord();
		end
	elseif(msg.action == "rightclick") then
		if(MainToolBar.IsEditMode) then
			-- show/hide context menu if any
			local obj = ParaScene.MousePick(300, "anyobject"); 
			MyCompany.Aries.Creator.ContextMenu.ShowMenuForObject(obj);
		else
			if(AutoCameraController:GetStyleName() == "2d") then
				if(Player.Jump() or Player.IsAllowJump()) then
					local bMoved, to_x, to_y, to_z = Map3DSystem.HandleMouse.MoveToMouseCursorPick(msg);
					if(bMoved) then
						last_move_pos.to_x, last_move_pos.to_y, last_move_pos.to_z = to_x, to_y, to_z;
						last_move_pos.tick_count = 0;
						jump_timer:Change(100,100);
					end
				end
			end
		end
	end
end