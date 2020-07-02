-- main game loop file template
-- author: [your name], original template by LiXizhi
-- date: 
-- description: main game loop file. 
-- Parameters:
--  helloworld: it needs to be a valid name
-- use the lib:
------------------------------------------------------------
-- NPL.activate("(gl)script/tutorials/helloworld/main.lua");
------------------------------------------------------------

NPL.load("(gl)script/lang/lang.lua");

if(not helloworld) then helloworld={}; end

local function activate()
	if(main_state==0) then
		-- this is the main game loop
	elseif(main_state==nil) then
		-- application entry point
		-- global assets and init scene loading
		ParaAsset.OpenArchive ("xmodels/character.zip");

		-- create main window
		helloworld.CreateMainWindow();
		
		-- set event handlers
		helloworld.ReBindEventHandlers();
			
		-- goto main game
		main_state=0;
	end	
end
NPL.this(activate);


-- just create a hello world window
function helloworld.CreateMainWindow()
	local _this, _parent;
	_this = ParaUI.GetUIObject("helloworld_app_ctl");
	if(_this:IsValid() == false) then 
		local width, height = 500,200;
		_this=ParaUI.CreateUIObject("container","helloworld_app_ctl", "_ct",-width/2,-height/2,width, height);
		_this:AttachToRoot();
		_parent=_this;
		
		_this=ParaUI.CreateUIObject("text","s", "_lt",100,50, 300, 25);
		_this.text = [[Hello World!
Start up tips:
	- Edit "config/bootstrapper.xml" to set your game loop file
	- press ENTER to start an hello world application.
	- If you have ParaIDE installed, press F5 key to launch SDK window.
 Press SPACE key to exit]];
		
		_parent:AddChild(_this);
	end	
end

-- bind the event registers
function helloworld.ReBindEventHandlers()
	NPL.load("(gl)script/ide/event_mapping.lua");
	-- register mouse picking event handler
	ParaScene.RegisterEvent("_m_helloworld_pick", ";helloworld.OnMouseClick();");
	-- register key event handler
	ParaScene.RegisterEvent("_k_helloworld_keydown", ";helloworld.OnKeyDownEvent();");
end

-- called when the user clicked its mouse
function helloworld.OnMouseClick()
	if(ParaScene.IsSceneEnabled()~=true) then 
		return
	end
	if(mouse_button == "left") then
	end
end	

-- called when the user hit a key
function helloworld.OnKeyDownEvent()
	if(ParaScene.IsSceneEnabled()==true) then 
		-- TODO:	
	end
	if(virtual_key == Event_Mapping.EM_KEY_SPACE) then	
		-- exit application
		ParaGlobal.ExitApp();
	elseif(virtual_key == Event_Mapping.EM_KEY_F5) then	
		-- bring up the ParaIDE SDK
		NPL.activate("ParaAllInOne.dll");	
	elseif(virtual_key == Event_Mapping.EM_KEY_LSHIFT) then	
		-- 'left shift' key to mount on closest character
		local player = ParaScene.GetPlayer();
		local char = player:ToCharacter();
		if(char:IsValid())then
			local nCount = player:GetNumOfPerceivedObject();
			local closest = nil;
			local min_dist = 100000;
			for i=0,nCount-1 do
				local gameobj = player:GetPerceivedObject(i);
				local dist = gameobj:DistanceTo(player);
				if( dist < min_dist) then
					closest = gameobj;
					min_dist = dist;
				end
			end
			if(closest~=nil) then
				if((closest:IsGlobal() ==true) and (closest:IsCharacter() == true) and (closest:IsOPC()==false)) then
					if(char:IsMounted()) then
						ParaScene.TogglePlayer();
					else
						if(closest:HasAttachmentPoint(0)==true) then
							char:MountOn(closest)
						end
						closest:ToCharacter():SetFocus();
					end
				else
					_guihelper.MessageBox(L"You can not take control of this character");
				end
			end
		end
	elseif(virtual_key == Event_Mapping.EM_KEY_RETURN) then	
		if(main_state == 0) then
			NPL.load("(gl)script/ide/loadworld.lua");
			IDEUI.LoadWorldImmediate("worlds/helloworld")
			helloworld.ReBindEventHandlers();
		end	
	elseif(virtual_key == Event_Mapping.EM_KEY_0) then	
		-- test external animation
		NPL.load("(gl)script/ide/action_table.lua");
		action_table.TestExternalAnimation()
	end
end
