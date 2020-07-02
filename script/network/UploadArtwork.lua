--[[
Title: Upload network panel
Author(s): LiXizhi
Date: 2007/5/21
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/UploadArtwork.lua");
UploadArtwork.Show();
------------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/kids_db.lua");
local L = CommonCtrl.Locale("KidsUI");
		
if(not UploadArtwork) then UploadArtwork={}; end

-- web service
-- for testing local web services
UploadArtwork.webservice_UploadUserFile  = CommonCtrl.Locale("KidsUI")("UploadUserFile.asmx");
UploadArtwork.webservice_SubmitArticle  = CommonCtrl.Locale("KidsUI")("SubmitArticle.asmx");
--UploadArtwork.webservice_UploadUserFile  = "http://localhost:1225/KidsMovieSite/UploadUserFile.asmx";
--UploadArtwork.webservice_SubmitArticle  = "http://localhost:1225/KidsMovieSite/SubmitArticle.asmx";

-- appearance
UploadArtwork.pagetab_bg = "Texture/kidui/worldmanager/tab_unselected.png"
UploadArtwork.pagetab_selected_bg = "Texture/kidui/worldmanager/tab_selected.png"
UploadArtwork.button_bg = "Texture/kidui/explorer/button.png"
UploadArtwork.listbox_bg = "Texture/kidui/explorer/listbox_bg.png"
UploadArtwork.dropdownarrow_bg = "Texture/kidui/explorer/dropdown_arrow.png"
UploadArtwork.dropdownlist_cont_bg = "Texture/kidui/explorer/editbox256x32.png"
UploadArtwork.editbox_bg = "Texture/kidui/explorer/editbox128x32.png"
UploadArtwork.editbox_long_bg = "Texture/kidui/explorer/editbox256x32.png"
-- tab pages
UploadArtwork.tabpages = {"UploadArt_tabPage_Web", "UploadArt_tabPage_Local",};
UploadArtwork.tabbuttons = {"UploadArt_tabPage_Web_TabBtn", "UploadArt_tabPage_Local_TabBtn",};


-- constants
UploadArtwork.historyfile =  "temp/artwork_history.txt";

-- current work
UploadArtwork.current = {
	IsFinished = true,
	category = 101,
	Title = "",
	ImageURL = "",
	articleURL = "",
	Abstract = "",
};

function UploadArtwork.ShowHistory(bShow)
	local _this,_parent;
	_this=ParaUI.GetUIObject("ArtworkHistory_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		local width, height = 370, 470
		_this=ParaUI.CreateUIObject("container","ArtworkHistory_cont","_ct", -width/2, -height/2-50,width, height);
		_this.background="Texture/kidui/worldmanager/bg.png";
		--_guihelper.SetUIColor(_this, "255 255 255 150");
		_this:SetTopLevel(true);
		_this:AttachToRoot();
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("button", "button12", "_rb", -179, -62, 75, 23)
		_this.text = L"Open";
		_this.onclick = ";UploadArtwork.OnClickOpenHistoryItem();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button11", "_rb", -98, -62, 75, 23)
		_this.text = L"Close";
		_this.onclick = ";UploadArtwork.CloseHistoryWnd();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button10", "_lt", 21, 17, 48, 48)
		_this.background="Texture/kidui/common/uploadpackage.png";
		_this.onclick = ";UploadArtwork.OnClickOpenHistoryFile();";
		_this.tooltip = L"Open history files...";
		_guihelper.SetUIColor(_this, "255 255 255");
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label5", "_lt", 75, 31, 160, 16)
		_this.text = L"All my works";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("listbox", "ArtworkHistory_ListBox", "_fi", 21, 77, 23, 68)
		_this.scrollable = true;
		_this.background="Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "255 255 255 150");
		_this.wordbreak = false;
		_this.itemheight = 18;
		--_this.onselect = ";";
		_this.ondoubleclick = ";UploadArtwork.OnClickOpenHistoryItem();";
		_this.font = "System;13;norm";
		_this.scrollbarwidth = 20;
		_parent:AddChild(_this);
		
		local file = ParaIO.open(UploadArtwork.historyfile, "r");
		if(file:IsValid()) then
			local url;
			local nIndex = 1;
			while(true) do 
				url = file:readline();
				if(url~=nil) then
					_this:AddTextItem(url);
					nIndex = nIndex+1;
				else
					break;
				end	
			end;
		end
		file:close();
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
		KidsUI.PushState({name = "ArtworkHistory", OnEscKey = UploadArtwork.CloseHistoryWnd});
	else
		KidsUI.PopState("ArtworkHistory");
	end		
end	

function UploadArtwork.CloseHistoryWnd()
	ParaUI.Destroy("ArtworkHistory_cont");
	KidsUI.PopState("ArtworkHistory");
end

function UploadArtwork.OnClickOpenHistoryItem()
	local text = ParaUI.GetUIObject("ArtworkHistory_ListBox").text;
	if(text ~= "") then
		text = string.gsub(text, ".*%((.*)%)", "%1");
		if(text~=nil and text~="") then
			ParaGlobal.ShellExecute("open", "iexplore.exe", text, nil, 1); 
		end	
	end
end

function UploadArtwork.OnClickOpenHistoryFile()
	ParaGlobal.ShellExecute("open", "notepad.exe", string.gsub(ParaIO.GetCurDirectory(0)..UploadArtwork.historyfile, "/","\\"), nil, 1); 
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function UploadArtwork.Show(bShow)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("UploadArtwork_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		local width, height = 370, 470
		_this=ParaUI.CreateUIObject("container","UploadArtwork_cont","_ct", -width/2, -height/2-50,width, height);
		_this.background="Texture/kidui/worldmanager/bg.png";
		--_guihelper.SetUIColor(_this, "255 255 255 150");
		_this:SetTopLevel(true);
		_this:AttachToRoot();
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("button", "button8", "_lt", 32, 17, 48, 48)
		_this.background="Texture/kidui/common/uploadpackage.png";
		_this.tooltip = L"Upload your work"
		_guihelper.SetUIColor(_this, "255 255 255");
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "label4", "_lt", 86, 33, 232, 16)
		_this.text = L"Upload my screenshot";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button9", "_lb", 32, -53, 75, 23)
		_this.text = L"History...";
		_this.onclick = ";UploadArtwork.ShowHistory(true);";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button6", "_rb", -110, -53, 75, 23)
		_this.text = L"Close";
		_this.onclick = ";UploadArtwork.Close();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button5", "_rb", -203, -53, 75, 23)
		_this.text = L"Upload";
		_this.onclick = ";UploadArtwork.OnClickUpload();";
		_parent:AddChild(_this);

		-- panel1
		_this = ParaUI.CreateUIObject("container", "panel1", "_fi", 32, 71, 35, 59)
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		
		_this = ParaUI.CreateUIObject("container", "uploadArt_Canvas", "_lt", 12, 6, 186, 122)
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 9, 137, 80, 16)
		_this.text = L"Title:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label3", "_lt", 9, 190, 88, 16)
		_this.text = L"Abstract:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 9, 166, 80, 16)
		_this.text = L"Category:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("imeeditbox", "UploadArt_Title", "_mt", 95, 134, 12, 26)
		_this.background=UploadArtwork.editbox_long_bg;
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/MultiLineEditbox.lua");
		local ctl = CommonCtrl.MultiLineEditbox:new{
			name = "UploadArt_TextBody",
			alignment = "_lt",
			left = 12,
			top = 209,
			width = 280,
			height = 131,
			parent = _parent,
			line_count = 4,
			--main_bg = "Texture/whitedot.png;0 0 0 0",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "uploadart_comboBoxArtCategory",
			alignment = "_mt",
			left = 95,
			top = 163,
			width = 12,
			height = 24,
			dropdownheight = 106,
 			parent = _parent,
			text = "",
			AllowUserEdit = false,
			container_bg = UploadArtwork.dropdownlist_cont_bg,
			editbox_bg = "Texture/whitedot.png;0 0 0 0",
			dropdownbutton_bg = UploadArtwork.dropdownarrow_bg,
			listbox_bg = UploadArtwork.listbox_bg,
			items = L:GetTable("Upload arkwork category table"),
		};
		ctl.text = ctl.items[1];
		ctl:Show();

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
		KidsUI.PushState({name = "UploadArtwork", OnEscKey = UploadArtwork.Close});
		
		local snapshot = "Screen Shots/".."auto.jpg";
		if(snapshot~=nil) then
		
			-- save without GUI
			ParaUI.GetUIObject("root").visible = false;
			ParaUI.ShowCursor(false);
			ParaScene.EnableMiniSceneGraph(false);
			ParaEngine.ForceRender();ParaEngine.ForceRender(); -- since we take image on backbuffer, we will render it twice to make sure the backbuffer is updated
			
			-- take a snapshot for the page
			ParaMovie.TakeScreenShot(snapshot, 640, 480);
			ParaAsset.LoadTexture("",snapshot,1):UnloadAsset();
			ParaUI.GetUIObject("uploadArt_Canvas").background = snapshot;
			
			-- restore
			ParaUI.ShowCursor(true);
			ParaUI.GetUIObject("root").visible = true;
			ParaScene.EnableMiniSceneGraph(true);
		end	
	else
		KidsUI.PopState("UploadArtwork");
	end
end

-- close window
function UploadArtwork.Close()
	ParaUI.Destroy("UploadArtwork_cont");
	KidsUI.PopState("UploadArtwork");
end

-- when the user clicked the upload button
function UploadArtwork.OnClickUpload()

	UploadArtwork.current.Title = ParaUI.GetUIObject("UploadArt_Title").text;
	if(UploadArtwork.current.Title == "") then
		UploadArtwork.current.Title = L"My screenshot"; -- give it a default name
	end
	
	local abstractCtrl = CommonCtrl.GetControl("UploadArt_TextBody");
	if(abstractCtrl~=nil)then
		UploadArtwork.current.Abstract = abstractCtrl:GetText();
	else	
		UploadArtwork.current.Abstract = "";
	end

	local categoryCtrl = CommonCtrl.GetControl("uploadart_comboBoxArtCategory");
	if(abstractCtrl~=nil)then
		local text = categoryCtrl:GetText();
		local index, value;
		for index, value in ipairs(categoryCtrl.items) do
			if(value == text) then
				UploadArtwork.current.category = index+100;
			end
		end
	else
		UploadArtwork.current.category = 101;	
	end
	
	if(not kids_db.User.IsAuthenticated) then
		_guihelper.MessageBox(L"In order to upload your work, you need to login to our community web site", function ()
			NPL.load("(gl)script/network/LoginBox.lua");
			LoginBox.Show(true, UploadArtwork.OnClickUpload_imp);
		end)
	else
		UploadArtwork.OnClickUpload_imp();
	end	
end

-- call this function to load image if the user is already authenticated.
function UploadArtwork.OnClickUpload_imp()
	if(UploadArtwork.current.IsFinished == false) then
		_guihelper.MessageBox(L"Please wait until the last transmission is finished.");
		return;
	end 
	UploadArtwork.Close();
	
	_guihelper.MessageBox(L"Uploading your work to the community web, please wait...");
	-- TODO: call web services
	
	-- send out the web serivce
	local snapshot = "Screen Shots/auto.jpg";
	local file = ParaIO.open(snapshot, "r");
	if(file:IsValid()) then
		local msg = {
			username = kids_db.User.Name,
			password = kids_db.User.Password,
			ImgIn = file,
			Filename = "auto.jpg",
			Overwrite = true,
		}
		NPL.RegisterWSCallBack(UploadArtwork.webservice_UploadUserFile, string.format("UploadArtwork.UploadUserFile_Callback(\"%s\");", kids_db.User.Name));
		NPL.activate(UploadArtwork.webservice_UploadUserFile, msg);
		file:close();
		UploadArtwork.current.IsFinished = false; 
	else
		_guihelper.MessageBox(L"Unable to upload your work, your local file does not exist".."\n");
	end	
end

function UploadArtwork.UploadUserFile_Callback(username)
	UploadArtwork.current.IsFinished = true; 
	
	if(msg~=nil and msg.fileURL~=nil) then
		if(string.sub(msg.fileURL, 1, 4)== "http") then
			_guihelper.MessageBox(string.format(L"Screen shot successfully uploaded\n%s\nSending article, please wait...\n\n", tostring(msg.fileURL)));
			UploadArtwork.current.ImageURL = msg.fileURL;
			local msg = {
				username = kids_db.User.Name,
				password = kids_db.User.Password,
				ImageURL = msg.fileURL,
				category = UploadArtwork.current.category,
				Title = UploadArtwork.current.Title,
				Abstract = UploadArtwork.current.Abstract,
			}
			NPL.RegisterWSCallBack(UploadArtwork.webservice_SubmitArticle, string.format("UploadArtwork.SubmitArticle_Callback(\"%s\");", kids_db.User.Name));
			NPL.activate(UploadArtwork.webservice_SubmitArticle, msg);
			UploadArtwork.current.IsFinished = false; 
		else
			_guihelper.MessageBox(L"Unable to upload your work\n"..msg.fileURL.."\n");
		end	
	elseif(msg==nil) then
		_guihelper.MessageBox(L"Network is not available, please try again later".."\n");
	else
		_guihelper.MessageBox(L"We are unable to upload your work to the community website\n");
	end	
end

function UploadArtwork.SubmitArticle_Callback(username)
	UploadArtwork.current.IsFinished = true; 
	
	if(msg~=nil and msg.id~=nil and  msg.id>0 and msg.articleURL~=nil) then
		UploadArtwork.current.articleURL = msg.articleURL;
		
		-- create a back up at screen shot/folder
		ParaIO.CopyFile("Screen Shots/auto.jpg", "Screen Shots/"..UploadArtwork.current.Title..ParaGlobal.GenerateUniqueID()..".jpg", true);
		
		_guihelper.MessageBox(string.format(L"Work successfully uploaded:\nURL is %s\nDo you want to view it in a web browser?\n\n", msg.articleURL), function ()
			ParaGlobal.ShellExecute("open", "iexplore.exe", UploadArtwork.current.articleURL, nil, 1); 
		end);
		
		-- if this is the first time the user load work, we will save it to user file.
		if(not kids_db.User.userinfo.HasUploadedUserWork)then
			kids_db.User.userinfo.HasUploadedUserWork = true;
			kids_db.User.SaveUserInfo();
		end
		
		-- save UploadArtwork.current to file for backup.
		
		--log(commonlib.serialize(UploadArtwork.current));
		local file = ParaIO.open(UploadArtwork.historyfile, "a");
		if(file:IsValid()) then
			--file:SetFilePointer(0,2);-- move to the last line
			file: writeline(string.format("%s(%s)",UploadArtwork.current.Title, UploadArtwork.current.articleURL));
		end
		file:close();
	else
		_guihelper.MessageBox(L"Unable to upload your work\n");
	end
end