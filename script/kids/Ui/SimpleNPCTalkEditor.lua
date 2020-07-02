--[[
Title: editor for simple talk NPC for the current selected character
Author(s): LiXizhi
Date: 2007/5/18
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/Ui/SimpleNPCTalkEditor.lua");
SimpleNPCTalkEditor.Show(true);
-------------------------------------------------------
]]
local L = CommonCtrl.Locale("KidsUI");

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

if(not SimpleNPCTalkEditor) then SimpleNPCTalkEditor={}; end

-- appearance
SimpleNPCTalkEditor.listbox_bg = "Texture/whitedot.png";
SimpleNPCTalkEditor.editbox_long_bg = "Texture/kidui/explorer/editbox256x32.png";
SimpleNPCTalkEditor.dropdownlist_cont_bg = "Texture/kidui/explorer/editbox256x32.png";
SimpleNPCTalkEditor.dropdownarrow_bg = "Texture/kidui/explorer/dropdown_arrow.png";

-- data on the clipboard for copy and paste
SimpleNPCTalkEditor.clipboard = {
	On_Click = "",
};
	
-- how many lines does the editor support.
SimpleNPCTalkEditor.MaxLine = 6;

-- show a top level recorder window
function SimpleNPCTalkEditor.ShowRecorder(bShow, left, top)
	local _this,_parent;
	_this=ParaUI.GetUIObject("SimpleNPCTalkEditor_Recorder_Cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		if(not left) then left = 366 end
		if(not top) then top = 266 end
		local width, height = 330, 200;
		
		-- SimpleNPCTalkEditor_Recorder_Cont recorder
		_this = ParaUI.CreateUIObject("container", "SimpleNPCTalkEditor_Recorder_Cont", "_lt", left, top, width, height)
		_this.background="Texture/kidui/worldmanager/bg.png";
		_this:SetTopLevel(true);
		_this:AttachToRoot();
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "s", "_ct", -width/2+15, -50, width-30, 20)
		_this.text = L"Your voice is now being recorded. Please speak in front of your microphone";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "EB_MMenu_Recorder_Stop_btn", "_ct", -40, 0, 80, 36)
		_this.text = L"Stop";
		_this.onclick=[[;SimpleNPCTalkEditor.StopRecorder();]];
		_parent:AddChild(_this);
	else
		if(bShow~=true) then
			ParaUI.Destroy("SimpleNPCTalkEditor_Recorder_Cont");
		end
	end
	if(bShow) then
		KidsUI.PushState({name = "SimpleNPCTalk recorder", OnEscKey = SimpleNPCTalkEditor.StopRecorder});
	else
		KidsUI.PopState("SimpleNPCTalk recorder");
	end
end

function SimpleNPCTalkEditor.StopRecorder()
	KidsUI.PopState("SimpleNPCTalk recorder");
	
	ParaUI.Destroy("SimpleNPCTalkEditor_Recorder_Cont");
	ParaAudio.StopRecording();
	
	if(SimpleNPCTalkEditor.RecentRecordedVoiceFile~=nil and ParaIO.DoesFileExist(SimpleNPCTalkEditor.RecentRecordedVoiceFile))then
		SimpleNPCTalkEditor.OnInsertMedia_imp(nil, SimpleNPCTalkEditor.RecentRecordedVoiceFile);
	end
end

SimpleNPCTalkEditor.RecentRecordedVoiceFile = nil;
function SimpleNPCTalkEditor.StartRecording()
	local voice_file = ParaWorld.GetWorldDirectory().."Sound/MyVoice"..ParaGlobal.GenerateUniqueID()..".wav";
	SimpleNPCTalkEditor.RecentRecordedVoiceFile = voice_file;
	-- ensure that the media directory exist
	ParaIO.CreateDirectory(voice_file);
	ParaAudio.SetRecordingOutput(voice_file, -1, -1);
	-- release last wave file
	ParaAudio.ReleaseWaveFile(voice_file);
	if(ParaAudio.BeginRecording()) then
		-- TODO: show top level control.
		-- your voice is now being recorded, please speak in front of your microphone.
		SimpleNPCTalkEditor.ShowRecorder(true);
	else
		_guihelper.MessageBox(L"You are not able to record sound. Please make sure you have a microphone installed on your computer. And that you have write permission on system disk.");
	end
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
--@param obj: character object. if nil, the current selected character is used.
function SimpleNPCTalkEditor.Show(bShow)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("SimpleNPCTalkEditor_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		local width, height = 520, 380
		_this=ParaUI.CreateUIObject("container","SimpleNPCTalkEditor_cont","_ct", -width/2, -height/2-50,width, height);
		--_this.background="Texture/kidui/worldmanager/bg.png";
		_guihelper.SetUIColor(_this, "255 255 255 150");
		_this:SetTopLevel(true);
		_this:AttachToRoot();
		_parent = _this;
		
		
		_this = ParaUI.CreateUIObject("button", "button3", "_lt", 115, 27, 71, 23)
		_this.text = L"Copy";
		_this.tooltip = L"Copy the dialog of this character to be applied on other characters";
		_this.onclick=";SimpleNPCTalkEditor.OnClickCopy();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button4", "_lt", 192, 27, 71, 23)
		_this.text = L"Paste";
		_this.tooltip = L"Apply the last copied dialog on this character";
		_this.onclick=";SimpleNPCTalkEditor.OnClickPaste();";
		_parent:AddChild(_this);


		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "NPCTalk_comboBoxEvent",
			alignment = "_mt",
			left = 115,
			top = 57,
			width = 32,
			height = 24,
			dropdownheight = 106,
 			parent = _parent,
 			container_bg = SimpleNPCTalkEditor.dropdownlist_cont_bg,
			editbox_bg = "Texture/whitedot.png;0 0 0 0",
			dropdownbutton_bg = SimpleNPCTalkEditor.dropdownarrow_bg,
			listbox_bg = SimpleNPCTalkEditor.listbox_bg,
			text = "",
			AllowUserEdit = false,
			items = L:GetTable("NPC Event Table"),
		};
		ctl.text = ctl.items[1];
		ctl:Show();
		-- TODO: remove this line if want to support other events in future
		ctl:SetEnabled(false);

		_this = ParaUI.CreateUIObject("button", "button1", "_lt", 28, 17, 64, 64)
		_this.background = CommonCtrl.CKidMiddleContainer.ai_buttons[1].bg;
		_this.tooltip = L"Tips: Enter dialog text on the edit boxes, each paragraph on a single line, then click OK button.";
		_guihelper.SetUIColor(_this, "255 255 255");
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button2", "_lb", 299, -77, 117, 27)
		_this.text = L"Insert Media...";
		_this.onclick=";SimpleNPCTalkEditor.OnClickInsertMedia();";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "button7", "_lb", 218, -77, 75, 27)
		_this.text = L"Record";
		_this.onclick=";SimpleNPCTalkEditor.StartRecording();";
		_parent:AddChild(_this);


		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "NPCTalk_ClaimMarkCheckBox",
			alignment = "_lb",
			left = 28,
			top = -73,
			width = 91,
			height = 24,
			parent = _parent,
			isChecked = false,
			text = L"Wear !",
			tooltip = L"Whether to display a ! mark on the head of the character",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "NPCTalk_QuestMarkCheckBox",
			alignment = "_lb",
			left = 133,
			top = -73,
			width = 91,
			height = 24,
			parent = _parent,
			isChecked = false,
			text = L"Wear ?",
			tooltip = L"Whether to display a ? mark on the head of the character",
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("button", "button6", "_rb", -120, -44, 88, 27)
		_this.text = L"Close";
		_this.onclick=";SimpleNPCTalkEditor.OnDestory();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button5", "_rb", -219, -44, 88, 27)
		_this.text = L"OK";
		_this.onclick=";SimpleNPCTalkEditor.OnClickOKBtn();";
		_parent:AddChild(_this);

		-- NPCTalk_Lines_Cont
		_this = ParaUI.CreateUIObject("container", "NPCTalk_Lines_Cont", "_fi", 28, 87, 17, 84)
		--_this.background = "Texture/EBook/text_bg.png"
		_this.background="Texture/whitedot.png;0 0 0 0";
		--_guihelper.SetUIColor(_this, "255 255 255 128");
		_parent:AddChild(_this);
		_parent = _this;

		local top = 12;
		local i;
		for i=1,SimpleNPCTalkEditor.MaxLine do
			_this = ParaUI.CreateUIObject("imeeditbox", "line"..i, "_mt", 12, top, 15, 26)
			_this.background = "Texture/EBook/line.png";
			_this.onkeyup=string.format([[;SimpleNPCTalkEditor.OnText(%d);]], i);
			_parent:AddChild(_this);
			top = top+30
		end
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
		
		if(bShow == true) then
			_this:SetTopLevel(true);
		end
	end	
	
	if(bShow) then
		KidsUI.PushState({name = "SimpleNPCTalkEditor", OnEscKey = SimpleNPCTalkEditor.OnDestory});
		SimpleNPCTalkEditor.OnLoadFromCharacter();
	else
		KidsUI.PopState("SimpleNPCTalkEditor");
	end
end


-- destory the control
function SimpleNPCTalkEditor.OnDestory()
	ParaUI.Destroy("SimpleNPCTalkEditor_cont");
	KidsUI.PopState("SimpleNPCTalkEditor");
end

function SimpleNPCTalkEditor.OnText(nLineIndex)
	local cont = ParaUI.GetUIObject("NPCTalk_Lines_Cont");
	if(cont:IsValid()==false) then return end
	if(virtual_key == Event_Mapping.EM_KEY_DOWN) then
		-- if the user pressed the enter key, change to the next line.
		if(nLineIndex < SimpleNPCTalkEditor.MaxLine) then
			local nextLine = cont:GetChild("line"..(nLineIndex+1));
			local thisLine = cont:GetChild("line"..nLineIndex);
			if(thisLine:IsValid() and nextLine:IsValid()) then
				nextLine:Focus();
				nextLine:SetCaretPosition(thisLine:GetCaretPosition());
			end	
			cont:GetChild("line"..(nLineIndex+1)):Focus();
		end
	elseif(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER ) then
		-- insert return key
		local thisLine = cont:GetChild("line"..nLineIndex);
		if(thisLine:IsValid()) then
			thisLine.text = thisLine.text.."\\n";
			thisLine:SetCaretPosition(-1);
		end
	elseif(virtual_key == Event_Mapping.EM_KEY_UP)	then
		-- if the user pressed the up key, change to the previous line.
		if(nLineIndex >=2 ) then
			local lastLine = cont:GetChild("line"..(nLineIndex-1));
			local thisLine = cont:GetChild("line"..nLineIndex);
			if(thisLine:IsValid() and lastLine:IsValid()) then
				lastLine:Focus();
				lastLine:SetCaretPosition(thisLine:GetCaretPosition());
			end	
		end
	end	
end

function SimpleNPCTalkEditor.OnClickPaste()
	SimpleNPCTalkEditor.OnLoadFromText(SimpleNPCTalkEditor.clipboard.On_Click);
end

function SimpleNPCTalkEditor.OnClickCopy()
	SimpleNPCTalkEditor.clipboard.On_Click = SimpleNPCTalkEditor.GetAICommandFromUI();
end

-- load character talks to UI.
-- more information, please see OnAICommand.lua
function SimpleNPCTalkEditor.OnLoadFromCharacter()
	local obj = ObjEditor.GetCurrentObj();
	if(obj == nil or obj:IsValid()==false or obj:IsCharacter() == false or filename=="") then
		return
	end
	local playerChar = obj:ToCharacter();
	local att = obj:GetAttributeObject();
	local eventScript = att:GetField("On_Click", "");
	local _,_, param = string.find(eventScript, ";NPL.load%(\"%(gl%)script/AI/templates/SimpleTutorial%.lua\"%);_AI_templates%.SimpleTutorial%.On_Click_str%((.*)%);");
	
	if(param~=nil and param~="") then
		NPL.DoString("SimpleNPCTalkEditor.tmpParam = "..param);
		param = SimpleNPCTalkEditor.tmpParam;
		SimpleNPCTalkEditor.OnLoadFromText(param);
	end
	
	-- update if the character has question mark
	local checkBtn = CommonCtrl.GetControl("NPCTalk_QuestMarkCheckBox");
	if(checkBtn~=nil) then
		local eventScript = att:GetField("OnLoadScript", "");
		if(eventScript==[[;NPL.load("(gl)script/AI/templates/SimpleTutorial.lua");_AI_templates.SimpleTutorial.On_Load("quest");]]) then
			checkBtn:SetCheck(true);
		else
			checkBtn:SetCheck(false);
		end
	end
	
	-- update if the character has claim mark
	local checkBtn = CommonCtrl.GetControl("NPCTalk_ClaimMarkCheckBox");
	if(checkBtn~=nil) then
		local eventScript = att:GetField("OnLoadScript", "");
		if(eventScript==[[;NPL.load("(gl)script/AI/templates/SimpleTutorial.lua");_AI_templates.SimpleTutorial.On_Load("claim");]]) then
			checkBtn:SetCheck(true);
		else
			checkBtn:SetCheck(false);
		end
	end
end

-- load UI with talk parameter
-- @param param: string. 
function SimpleNPCTalkEditor.OnLoadFromText(param)
	if(param~=nil) then
		local cont = ParaUI.GetUIObject("NPCTalk_Lines_Cont");
		if(cont:IsValid()) then
			-- plain text	
			local i=1;
			local w;
			for w in string.gfind(param, "(.-[^\\])\\n") do
				-- this will allow \n to appear in text
				if(i<=SimpleNPCTalkEditor.MaxLine) then
					local line = cont:GetChild("line"..i);
					if(line:IsValid()) then
						line.text = w;
					end
				else
					-- if there are more lines afrer the last editbox, we will just append to the last line and prepend the text with "\\n"
					local line = cont:GetChild("line"..SimpleNPCTalkEditor.MaxLine);
					if(line:IsValid()) then
						line.text = line.text.."\\n"..w;
					end
				end
				i = i+1;
			end
			-- if there are additional lines, just empty them
			while(i<=SimpleNPCTalkEditor.MaxLine) do
				local line = cont:GetChild("line"..i);
				if(line:IsValid()) then
					line.text = "";
				end
				i = i+1;
			end
		end
	end
end

-- @return: return the string AI command (from UI) which can be passed to _AI.DoPlayerTextCommand() to update the character behavior
function SimpleNPCTalkEditor.GetAICommandFromUI()
	local sText = "";
	local cont = ParaUI.GetUIObject("NPCTalk_Lines_Cont");
	if(cont:IsValid()) then
		-- get talk text	
		local i;
		for i=1,SimpleNPCTalkEditor.MaxLine do
			local line = cont:GetChild("line"..i);
			if(line:IsValid()) then
				if(line.text~="") then
					sText = sText..line.text.."\\n";
				end
			end
		end
	end	
	return sText;
end
	
function SimpleNPCTalkEditor.OnClickOKBtn()
	local obj = ObjEditor.GetCurrentObj();
	if(obj == nil or obj:IsValid()==false or obj:IsCharacter() == false or filename=="") then
		return
	end
	local sText = SimpleNPCTalkEditor.GetAICommandFromUI();
	local bClearOnClick = (sText == "");
	--get quest mark if any
	local HasMark = nil;
	local checkBtn = CommonCtrl.GetControl("NPCTalk_ClaimMarkCheckBox");
	if(not HasMark and checkBtn~=nil) then
		if(checkBtn:GetCheck()) then
			sText = "\\!"..sText;
			HasMark = true;
		end
	end
	local checkBtn = CommonCtrl.GetControl("NPCTalk_QuestMarkCheckBox");
	if(not HasMark and checkBtn~=nil) then
		if(checkBtn:GetCheck()) then
			sText = "\\?"..sText;
		end
	end
	_AI.DoPlayerTextCommand(obj, sText);
	
	if(bClearOnClick) then
		obj:GetAttributeObject():SetField("On_Click", "");
	end
	-- close the window
	SimpleNPCTalkEditor.OnDestory();
end


function SimpleNPCTalkEditor.OnClickInsertMedia()
	NPL.load("(gl)script/ide/OpenFileDialog.lua");
	local ctl = CommonCtrl.OpenFileDialog:new{
		name = "NPCTalk_OpenWaveFileDialog",
		alignment = "_ct",
		left=-256, top=-150,
		width = 512,
		height = 380,
		showSubDirLevels = 1;
		parent = nil,
		fileextensions = L:GetTable("Sound and image file extensions table");
		folderlinks = {
			{path = L"Audio Folder", text = L"Sound Lib"},
			{path = ParaWorld.GetWorldDirectory(), text = L"My work"},
			{path = L"Shared Media Folder", text = L"Media lib"},
			{path = L"Advertisement Folder", text = L"Advertisement"},
		},
		FileNamePassFilter = "http://.*", -- we allow user to specify any thing that begins with http://
		onopen = SimpleNPCTalkEditor.OnInsertMedia_imp,
	};
	ctl:Show(true);
end

function SimpleNPCTalkEditor.OnInsertMedia_imp(sCtrlName, filename)
	-- insert sound to the end of the first empty edit box line
	local cont = ParaUI.GetUIObject("NPCTalk_Lines_Cont");
	if(cont:IsValid()) then
		-- get talk text	
		local i;
		for i=1,SimpleNPCTalkEditor.MaxLine do
			local line = cont:GetChild("line"..i);
			if(line:IsValid()) then
				if(line.text=="" or i==SimpleNPCTalkEditor.MaxLine) then
					if(string.find(filename, "http://")~=nil) then
						line.text = string.format("%s <url>%s</url> ", line.text, filename);
					else
						local ext = ParaIO.GetFileExtension(filename);
						if(ext == "wav")then
							line.text = string.format("%s <sound>%s</sound> ", line.text, filename);
						else
							line.text = string.format("%s <image>%s</image> ", line.text, filename);
						end
					end	
					break;
				end
			end
		end
	end	
end