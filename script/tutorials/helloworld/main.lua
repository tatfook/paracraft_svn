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

NPL.load("(gl)script/tutorials/helloworld/chat_client.lua");
NPL.load("(gl)script/tutorials/helloworld/chat_server.lua");

NPL.load("(gl)script/lang/lang.lua");
NPL.load("(gl)script/ide/action_table.lua");
NPL.load("(gl)script/ide/object_editor.lua");

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
		
		_this=ParaUI.CreateUIObject("button","s", "_lt",100,100, 100, 25);
		_this.text = "load world";
		NPL.load("(gl)script/tutorials/helloworld/loadworld.lua");
		_this.onclick  = [[;LoadworldUI.LoadWorldImmediate("worlds/LiXizhi");helloworld.ReBindEventHandlers();]];
		_parent:AddChild(_this);
		
		_this=ParaUI.CreateUIObject("button","s", "_lt",100,130, 100, 25);
		_this.text = "I am server";
		_this.onclick  = ";helloworld.StartServer();";
		_parent:AddChild(_this);
		
		_this=ParaUI.CreateUIObject("button","s", "_lt",250,130, 100, 25);
		_this.text = "server Say hello";
		_this.onclick  = ";helloworld.ServerSayHello();";
		_parent:AddChild(_this);
		
		
		_this=ParaUI.CreateUIObject("button","s", "_lt",100,160, 100, 25);
		_this.text = "I am client";
		_this.onclick  = ";helloworld.StartClient();";
		_parent:AddChild(_this);
		
		_this=ParaUI.CreateUIObject("button","s", "_lt",250,160, 100, 25);
		_this.text = "client say hello";
		_this.onclick  = ";helloworld.ClientSayHello();";
		_parent:AddChild(_this);
	end	
end

function helloworld.StartServer()
	
	-- enable the network	
	ParaNetwork.EnableNetwork(true, "server", "123");
	Loadworld_db.player.name = ParaNetwork.GetLocalNerveCenterName();
	
	LoadworldUI.LoadWorldImmediate("worlds/LiXizhi");
	helloworld.ReBindEventHandlers();
	
	
	ParaNetwork.Restart();
	ParaWorld.SetServerState(1);
	
end

function helloworld.StartClient()
	-- enable the network	
	ParaNetwork.EnableNetwork(true, "client", "123");
	Loadworld_db.player.name = ParaNetwork.GetLocalNerveCenterName();
	
	LoadworldUI.LoadWorldImmediate("worlds/LiXizhi");
	helloworld.ReBindEventHandlers();
	
	ParaNetwork.Restart();
	ParaNetwork.AddNamespaceRecord("server", "192.168.0.101", 60001);
	ParaNetwork.ConnectToCenter("server");
	
	ParaWorld.SetServerState(2);
	
end

function helloworld.OnNetworkEvent()

end

function helloworld.ServerSayHello()
	server.BroadcastMessage("hello all!", 1)
end

function helloworld.ClientSayHello()
	client.SendChatMessage("hello server", 0);
end

-- bind the event registers
function helloworld.ReBindEventHandlers()
	NPL.load("(gl)script/ide/event_mapping.lua");
	-- register mouse picking event handler
	ParaScene.RegisterEvent("_m_helloworld_pick", ";helloworld.OnMouseClick();");
	-- register key event handler
	ParaScene.RegisterEvent("_k_helloworld_keydown", ";helloworld.OnKeyDownEvent();");
	-- register key event handler
	ParaScene.RegisterEvent("_n_helloworld_net", ";helloworld.OnNetworkEvent();");

	-- show a display window	
	NPL.load("(gl)script/ide/chat_display.lua");
	local ctl = CommonCtrl.chat_display:new{
		name = "chat_display1",
		alignment = "_lt",
		left=0, top=0,
		width = 300,height = 50,
		max_lines = 5,
		parent = nil,
	};
	ctl:Show();
	-- at any time, one can call. 
	CommonCtrl.chat_display.AddText("chat_display1", "Hi, there!");

end

-- called when the user clicked its mouse
function helloworld.OnMouseClick()
	if(ParaScene.IsSceneEnabled()~=true) then 
		return	
	end
	if(mouse_button == "left") then
		local obj = ParaScene.MousePick(40, "anyobject");
		if(obj:IsValid()==true) then
			ObjEditor.SetCurrentObj(obj);
			
			
			local char = ParaScene.GetPlayer():ToCharacter();
			if(char:IsValid())then
				char:MountOn(obj);
			end
		end	
		--obj:ToCharacter():RemoveAttachment(11);
		--obj:ToCharacter():AddAttachment(KidsUI.HeadArrowAsset, 11);
	end
end	

-- called when the user hit a key
function helloworld.OnKeyDownEvent()
	if(ParaScene.IsSceneEnabled()==true) then 
			
		-- TODO:	
		if(virtual_key == Event_Mapping.EM_KEY_O) then	
			ParaScene.SetGlobalWater(true, 5);
		elseif(virtual_key == Event_Mapping.EM_KEY_P) then	
			local player = ParaScene.GetPlayer();
			if(player:IsValid()) then
				player:SetDensity(0.3);
			end
		elseif(virtual_key == Event_Mapping.EM_KEY_V) then	
			ParaAudio.PlayWaveFile("script/tutorials/helloworld/Example.wav",3);
			
		elseif(virtual_key == Event_Mapping.EM_KEY_C) then	
			ParaGlobal.CreateProcess("c:\\windows\\notepad.exe", "\"c:\\windows\\notepad.exe\" c:\\test.txt", true); 
		elseif(virtual_key == Event_Mapping.EM_KEY_N) then	
			helloworld.ClientSayHello();
		elseif(virtual_key == Event_Mapping.EM_KEY_B) then	
			helloworld.ServerSayHello();	
			
		elseif(virtual_key == Event_Mapping.EM_KEY_SPACE) then	
			-- space key to jump
			local char = ParaScene.GetPlayer():ToCharacter();
			if(char:IsValid())then
				char:AddAction(action_table.ActionSymbols.S_JUMP_START);
			end
		end
	end
	if(virtual_key == Event_Mapping.EM_KEY_SPACE) then	
		-- exit application
		
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
	elseif(virtual_key == Event_Mapping.EM_KEY_0) then	
		-- test external animation
		NPL.load("(gl)script/ide/action_table.lua");
		action_table.TestExternalAnimation()
	end	
end
