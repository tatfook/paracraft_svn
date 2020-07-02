NPL.load("(gl)script/tutorials/helloworld/chat_client.lua");
NPL.load("(gl)script/tutorials/helloworld/chat_server.lua");

NPL.load("(gl)script/lang/lang.lua");
NPL.load("(gl)script/ide/action_table.lua");
NPL.load("(gl)script/ide/object_editor.lua");
NPL.load("(gl)script/ide/gui_helper.lua");

if(not CYFTest) then CYFTest={}; end

local function activate()
	if(main_state==0) then
		-- this is the main game loop
	elseif(main_state==nil) then
		-- application entry point
		-- global assets and init scene loading
		--ParaAsset.OpenArchive ("xmodels/character.zip");

		-- create main window
		--helloworld.CreateMainWindow();
		CYFTest.CreateMainWindow()
		-- set event handlers
		--helloworld.ReBindEventHandlers();
			
		-- goto main game
		main_state=0;
	end	
	
	
end
NPL.this(activate);

function CYFTest.CreateMainWindow()
	
	local btnColorSele,text,chkBox
	--btnColorSele = ParaUI.GetUIObject("btnColorSele222");
	btnColorSele = CommonCtrl.GetControl("btnColorSele222");
	if(btnColorSele == nil) then
		
		NPL.load("(gl)script/tutorials/CYFTest/ColorDialog.lua");
		local ctl = CommonCtrl.ColorDialog:new{
			name = "btnColorSele222",
			alignment = "_lt",
			left = 0,
			top = 250,
			width = 200,
			height = 50,
			parent = nil,
			isChecked = false,
			text = "Select Color",
		};
		ctl:Show();
	else
		btnColorSele:Show();
	end
end
