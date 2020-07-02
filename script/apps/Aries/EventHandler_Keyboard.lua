--[[
Title: Keyboard management for Aries App
Author(s): LiXizhi
Date: 2009/6/27
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/EventHandler_Keyboard.lua");
local HandleKeyboard = commonlib.gettable("MyCompany.Aries.HandleKeyboard");
HandleKeyboard.OnKeyDownProc
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Player/main.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/mcml/pe_hotkey.lua");
local hotkey_manager = commonlib.gettable("Map3DSystem.mcml_controls.hotkey_manager");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");
local ReplayMode = commonlib.gettable("MyCompany.Aries.Movie.ReplayMode");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
-- create class
local HandleKeyboard = commonlib.gettable("MyCompany.Aries.HandleKeyboard");

-- whether we are dialog mode. 
local is_dialog_mode = nil;
local dialog_mode_OnKeyDownProc = nil;

-- called when eventer dialog mode. when all key are disabled except the esc key. 
function HandleKeyboard.EnterDialogMode(OnKeyDownProc)
	is_dialog_mode = true;
	dialog_mode_OnKeyDownProc = OnKeyDownProc;
	if(Dock.SetCanExit) then
		Dock.SetCanExit(false);
	end
end

function HandleKeyboard.LeaveDialogMode()
	is_dialog_mode = nil;
	if(Dock.SetCanExit) then
		Dock.SetCanExit(true);
	end
end


-- key event handler (hook function)
function HandleKeyboard.OnKeyDownProc(nCode, appName, msg)
	-- return the nCode to be passed to the next hook procedure in the hook chain. 
	-- in most cases, if nCode is nil, the hook procedure should do nothing. 
	if(nCode==nil) then return end
	
	local input = msg;
	local event_map = Event_Mapping;
	if(input.IsSceneEnabled and not input.IsComboKeyPressed) then 
		-- fixed by LiXizhi 2011.1.3: what happens when user pressed the shift key while loading a world.
		local worldinfo = WorldManager:GetCurrentWorld();

		if(hotkey_manager.handle_key_event(virtual_key)) then
			return;
		end

		if(is_dialog_mode) then
			-- we will disable all key event during dialog mode. 
			if(dialog_mode_OnKeyDownProc) then
				dialog_mode_OnKeyDownProc(virtual_key);
			end
			nCode = nil;
			return;
		end

		if(virtual_key == event_map.EM_KEY_SPACE) then
			nCode = nil;
			Map3DSystem.App.Commands.Call("Profile.Aries.Jump");
		elseif(virtual_key == event_map.EM_KEY_X) then
			-- X key to talk to nearest npc. 
			System.App.Commands.Call("Profile.Aries.TalkToNearestNPC"); 
		end	
		
		if(worldinfo.can_reverse_time) then
			if(virtual_key == event_map.EM_KEY_LSHIFT) then
				if(not ReplayMode.isFreezeReverse) then
					nCode = nil;
					-- enter Time Reverse Movie Mode. 
					ReplayMode.moviekey_timer:Change(0, 100);
				end
			else
				if(not ReplayMode.IsRecording()) then
					if(ReplayMode.moviekey_timer:IsEnabled()) then
						-- resume recording if user hit any key. 
						ReplayMode.moviekey_timer:Change();
						ReplayMode.ResumeRecord();
					end
				end
			end
		end
	end	
	if(msg.virtual_key == event_map.EM_KEY_F11) then
		-- taking a screen shot. 
		nCode = nil;
		NPL.load("(gl)script/apps/Aries/Creator/SharePhotosPage.lua");
		MyCompany.Aries.Creator.SharePhotosPage.TakeSnapshot()
	end
	return nCode;
end