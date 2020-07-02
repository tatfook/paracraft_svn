--[[
Title: The Kids Movie UI
Author(s): LiXizhi(code&logic)
Date: 2006/2/27
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/kids/saveworld.lua","");
NPL.load("(gl)script/kids/saveworld.lua");
------------------------------------------------------------
]]
-- requires:
NPL.load("(gl)script/kids/kids_db.lua");
NPL.load("(gl)script/ide/gui_helper.lua");
local L = CommonCtrl.Locale("KidsUI");

-- KidsUI: Kids UI library 
if(not KidsUI) then KidsUI={}; end

--[[ save the current world immediately without doing any error checking or report. This is usually called by ParaIDE from the save world menu. ]]
function KidsUI.SaveWorldImmediate()
	-- save to database
	kids_db.SaveWorldToDB();
	
	-- save others
	if( ParaTerrain.IsModified() == true) then
		ParaTerrain.SaveTerrain(true,true);
	else
		ParaTerrain.SaveTerrain(false,false);
	end	

	local player = ParaScene.GetObject("<player>");
	if(player:IsValid()==true) then
		local x,y,z = player:GetPosition();
		local OnloadScript = ParaTerrain.GetTerrainOnloadScript(x,z);
	end
end

-- save all modified terrain
-- @param bSaveEverything: if true everything is saved, if false only modified content are saved. 
function KidsUI.SaveWorld_OnOK(bSaveEverything)
	KidsUI.SaveWorld_CloseWindow();
	
	-- save to database
	kids_db.SaveWorldToDB();
	
	if(bSaveEverything)then 
		-- save everything
		ParaScene.SetModified(true);
		local x,y,z = ParaScene.GetPlayer():GetPosition();
		
		-- save everything within 500 meters radius from the current character
		ParaTerrain.SetContentModified(x,z, true, 65535);
		ParaTerrain.SetContentModified(x+500,z+500, true, 65535);
		ParaTerrain.SetContentModified(x+500,z-500, true, 65535);
		ParaTerrain.SetContentModified(x-500,z+500, true, 65535);
		ParaTerrain.SetContentModified(x-500,z-500, true, 65535);
		ParaTerrain.SaveTerrain(true,true);
		
		local nCount = ParaScene.SaveAllCharacters();
		_guihelper.MessageBox(string.format(L"%d loaded characters in the scene are saved. All visible world near the current player are saved.",nCount));
	else
		-- save others
		if( ParaTerrain.IsModified() == true) then
			ParaTerrain.SaveTerrain(true,true);
			local player = ParaScene.GetObject("<player>");
			
			if(player:IsValid()==true) then
				local x,y,z = player:GetPosition();
				local OnloadScript = ParaTerrain.GetTerrainOnloadScript(x,z);
				_guihelper.MessageBox(L"scene has been saved to:\n"..OnloadScript);
			else
				_guihelper.MessageBox(L"scene has been saved.\n");
			end
		else 
			_guihelper.MessageBox(L"scene is not modified");
		end
	end	
end

function KidsUI.SaveWorld_CloseWindow()
	KidsUI.PopState("KidsUISaveWorld");
	ParaUI.Destroy("IDE_SAVEWORLD_MSGBOX");
end

---------------------------
-- save world dialog
----------------------------
if(not KidsUI.SaveWorldDialog) then KidsUI.SaveWorldDialog={}; end

function KidsUI.SaveWorldDialog.Show()
	-- display a dialog asking for options
	local temp = ParaUI.GetUIObject("IDE_SAVEWORLD_MSGBOX");
	if(temp:IsValid()==false) then 
		local _this,_parent;
		local width, height = 461, 240
		_this=ParaUI.CreateUIObject("container","IDE_SAVEWORLD_MSGBOX", "_ct",-width/2,-height/2-50,width, height);
		_this:AttachToRoot();
		_this.background="Texture/msg_box.png";
		_this:SetTopLevel(true); -- _this.candrag and TopLevel and not be true simultanously 
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "button1", "_lt", 33, 23, 64, 64)
		_this.background="Texture/kidui/right/btn_save.png";
		_this.tooltip = L"Click the save button to save your current world";
		_guihelper.SetUIColor(_this, "255 255 255");
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 105, 43, 300, 16)
		_this.text = L"Do you want to save your current world?";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label3", "_lt", 105, 71, 256, 16)
		_this.text = kids_db.world.name;
		_this:GetFont("text").color = "0 100 0";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "button2", "_rb",  -326, -50, 92, 27)
		_this.text=L"Save";
		_this.tooltip=L"Save only modified content (fast)";
		_this.onclick=";KidsUI.SaveWorld_OnOK(false);";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button3", "_rb", -228, -50, 92, 27)
		_this.text=L"Save Full";
		_this.tooltip=L"Save everything in the scene (slow)";
		_this.onclick=";KidsUI.SaveWorld_OnOK(true);";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button4", "_rb", -113, -50, 92, 27)
		_this.text=L"Cancel";
		_this.onclick=";KidsUI.SaveWorld_CloseWindow();";	
		_parent:AddChild(_this);

		-- panel1
		_this = ParaUI.CreateUIObject("container", "panel1", "_fi", 19, 107, 21, 56)
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 103, 11, 296, 16)
		_this.text = L"Upload my 3D world to community site";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label4", "_lt", 103, 42, 296, 16)
		_this.text = L"Upload my screen shot";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button5", "_lt", 14, 7, 83, 25)
		_this.text = L"publish";
		_this.onclick = ";KidsUI.SaveWorldDialog.OnClickPublishWorld();"
		--_this.background = "Texture/kidui/explorer/button.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button6", "_lt", 14, 38, 83, 25)
		_this.text = L"snapshot";
		--_this.background = "Texture/kidui/explorer/button.png";
		_this.onclick = ";KidsUI.SaveWorldDialog.OnClickUpload();"
		_this.tooltip = L"Upload your work";
		_parent:AddChild(_this);
		
		KidsUI.PushState({name = "KidsUISaveWorld", OnEscKey = KidsUI.SaveWorld_CloseWindow});
	end	
end

function KidsUI.SaveWorldDialog.OnClickUpload()
	KidsUI.SaveWorld_CloseWindow();
	KidsUI.OnClickUpload();
end

function KidsUI.SaveWorldDialog.OnClickPublishWorld()
	KidsUI.SaveWorld_CloseWindow();
	
	if(not kids_db.User.IsAuthenticated) then
		_guihelper.MessageBox(L"In order to upload your work, you need to login to our community web site", function ()
			NPL.load("(gl)script/network/LoginBox.lua");
			LoginBox.Show(true, KidsUI.SaveWorldDialog.PublishWorld_imp);
		end)
	else
		KidsUI.SaveWorldDialog.PublishWorld_imp();
	end	
end

function KidsUI.SaveWorldDialog.PublishWorld_imp()
	NPL.load("(gl)script/network/KM_WorldUploader.lua");
	KM_WorldUploader.ShowUIForTask(KM_WorldUploader.NewTask({source=kids_db.world.name, type = KM_WorldUploader.TaskType.NormalWorld}));
end

local function activate()
	-- TODO: use better and dedicated UI. 
	if(kids_db.world.readonly) then
		_guihelper.MessageBox(L"This world is ready-only, you can not save it.");
	elseif(not kids_db.User.HasRight("Save")) then
		_guihelper.MessageBox(L"You do not have permission to save the world");
	else
		-- this asks the user to upload images
		if(not kids_db.User.userinfo.HasUploadedUserWork)then
			_guihelper.MessageBox(L"Do you know that you can upload screen shot of your 3d world to our community website? Please click the flashing button on the left bottom of the screen.");
		end	
		local tmp = ParaUI.GetUIObject("btnUploadUserWork");
		if(tmp:IsValid()==true) then
			tmp.highlightstyle="4outsideArrow";
		end
				
		-- display a dialog asking for options
		KidsUI.SaveWorldDialog.Show();
	end	
end
NPL.this(activate);