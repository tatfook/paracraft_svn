-- main game loop file template
-- author: [your name], original template by LiXizhi
-- date: 
-- description: main game loop file. 
-- Parameters:
--  test: it needs to be a valid name
-- use the lib:
------------------------------------------------------------
-- NPL.activate("(gl)script/tutorials/explorertest/main.lua");
------------------------------------------------------------

NPL.load("(gl)script/lang/lang.lua");

if(not test) then test={}; end

local function activate()
	if(main_state==0) then
		-- this is the main game loop
	elseif(main_state==nil) then
		-- application entry point
		-- global assets and init scene loading
		ParaAsset.OpenArchive ("xmodels/character.zip");

		-- create main window
		test.CreateMainWindow();
		
		-- set event handlers
		test.ReBindEventHandlers();
			
		-- goto main game
		main_state=0;
	end	
end
NPL.this(activate);


-- just create a hello world window
function test.CreateMainWindow()
	NPL.load("(gl)script/network/explorer.lua");
	local ctl = CommonCtrl.explorer:new{
		name = "explorer1",
		alignment = "_lt",
		left=0, top=0,
		parent = nil,
	};
	ctl:Show();
end

-- bind the event registers
function test.ReBindEventHandlers()
	NPL.load("(gl)script/ide/event_mapping.lua");
	-- register mouse picking event handler
	ParaScene.RegisterEvent("_m_test_pick", ";test.OnMouseClick();");
	-- register key event handler
	ParaScene.RegisterEvent("_k_test_keydown", ";test.OnKeyDownEvent();");
end

-- called when the user clicked its mouse
function test.OnMouseClick()
	if(ParaScene.IsSceneEnabled()~=true) then 
		return
	end
	if(mouse_button == "left") then
	end
end	

-- called when the user hit a key
function test.OnKeyDownEvent()
	if(ParaScene.IsSceneEnabled()==true) then 
		-- TODO:	
	end
	if(virtual_key == Event_Mapping.EM_KEY_SPACE) then	
		-- exit application
		ParaGlobal.ExitApp();
	elseif(virtual_key == Event_Mapping.EM_KEY_F5) then	
		-- bring up the ParaIDE SDK
		NPL.activate("ParaAllInOne.dll");	
	end
end
