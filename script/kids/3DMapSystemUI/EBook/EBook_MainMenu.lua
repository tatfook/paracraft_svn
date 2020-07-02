--[[
Title: Main Menu for ebook
Author(s): LiXizhi
Date: 2007/4/12
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/EBook/EBook_MainMenu.lua");
EBook_MainMenu.Show();
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/EBook/EBook.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/EBook/EBook_db.lua");
NPL.load("(gl)script/ide/FileDialog.lua");

local L = CommonCtrl.Locale("ParaWorld");

if(not EBook_MainMenu) then EBook_MainMenu={}; end

-- properties
EBook_MainMenu.NeedsRefresh = true;

-- appearance
EBook_MainMenu.main_bg = "Texture/kidui/explorer/bg.png"
EBook_MainMenu.pagetab_bg = "Texture/kidui/explorer/pagetab.png"
EBook_MainMenu.pagetab_selected_bg = "Texture/kidui/explorer/pagetab_selected.png"
EBook_MainMenu.panel_bg = "Texture/kidui/explorer/panel_bg.png"
EBook_MainMenu.panel_sub_bg = "Texture/kidui/explorer/panel_sub_bg.png"
EBook_MainMenu.button_bg = "Texture/kidui/explorer/button.png"
EBook_MainMenu.listbox_bg = "Texture/kidui/explorer/listbox_bg.png"
EBook_MainMenu.dropdownarrow_bg = "Texture/kidui/explorer/dropdown_arrow.png"
EBook_MainMenu.dropdownlist_cont_bg = "Texture/kidui/explorer/editbox256x32.png"
EBook_MainMenu.editbox_bg = "Texture/kidui/explorer/editbox128x32.png"
EBook_MainMenu.editbox_long_bg = "Texture/kidui/explorer/editbox256x32.png"

-- tab pages
EBook_MainMenu.tabpages = {"EB_MenuPage_MyBooks", "EB_MenuPage_NewBook", "EB_MenuPage_Download", "EB_MenuPage_Publish",};
EBook_MainMenu.tabbuttons = {"EB_MenuPage_MyBooks_TabBtn", "EB_MenuPage_NewBook_TabBtn", "EB_MenuPage_Download_TabBtn", "EB_MenuPage_Publish_TabBtn", };

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function EBook_MainMenu.Show(bShow, left, top)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("EBook_MainMenu");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		EBook_MainMenu.NeedsRefresh = true;
		if(not left) then left = 66 end
		if(not top) then top = 66 end
		local width, height = 556, 300
		-- EBook_MainMenu
		_this = ParaUI.CreateUIObject("container", "EBook_MainMenu", "_lt", left, top, width, height)
		_this.background="Texture/EBook/menu_bg.png";
		_this.onmouseup=";EBook_MainMenu.OnClose();";
		_this:SetTopLevel(true);
		_this:AttachToRoot();
		_parent = _this;

		
		-- EB_MainMenu_LeftCont
		_this = ParaUI.CreateUIObject("container", "EB_MainMenu_LeftCont", "_lt", 15, 27, 128, 256)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		height = 32;
		top = 0;
		local spacing = 5;
		
		_this = ParaUI.CreateUIObject("button", "EB_MenuPage_MyBooks_TabBtn", "_mt", 0, top, 0, height)
		_guihelper.SetVistaStyleButton(_this, L"Texture/EBook/menu_mybooks.png", "Texture/EBook/button_bg_layer.png");
		_this.onclick = ";EBook_MainMenu.SwitchMainTabs(1);";
		--_this.onmouseenter = ";EBook_MainMenu.SwitchMainTabs(1);";
		_parent:AddChild(_this);
		top = top + height+spacing;

		_this = ParaUI.CreateUIObject("button", "EB_MenuPage_NewBook_TabBtn", "_mt", 0, top, 0, height)
		_guihelper.SetVistaStyleButton(_this, L"Texture/EBook/menu_newbook.png", "Texture/EBook/button_bg_layer.png");
		_this.onclick = ";EBook_MainMenu.SwitchMainTabs(2);";
		_parent:AddChild(_this);
		top = top + height+spacing;

		_this = ParaUI.CreateUIObject("button", "EB_MenuPage_Download_TabBtn", "_mt", 0, top, 0, height)
		_guihelper.SetVistaStyleButton(_this, L"Texture/EBook/menu_downbook.png", "Texture/EBook/button_bg_layer.png");
		_this.onclick = ";EBook_MainMenu.SwitchMainTabs(3);";
		_parent:AddChild(_this);
		top = top + height+spacing;

		_this = ParaUI.CreateUIObject("button", "EB_MenuPage_Publish_TabBtn", "_mt", 0, top, 0, height)
		_guihelper.SetVistaStyleButton(_this, L"Texture/EBook/menu_publish.png", "Texture/EBook/button_bg_layer.png");
		_this.onclick = ";EBook_MainMenu.SwitchMainTabs(4);";
		_parent:AddChild(_this);
		top = top + height+spacing;

		_this = ParaUI.CreateUIObject("button", "EB_MainMenu_Save_btn", "_mt", 0, top, 0, height)
		_guihelper.SetVistaStyleButton(_this, L"Texture/EBook/menu_savebook.png", "Texture/EBook/button_bg_layer.png");
		_this.onclick = ";EBook_MainMenu.OnClickSave_btn();";
		_parent:AddChild(_this);
		top = top + height+spacing;

		_this = ParaUI.CreateUIObject("button", "EB_MainMenu_Back_btn", "_mb", 0, 0, 0, height)
		_guihelper.SetVistaStyleButton(_this, L"Texture/EBook/menu_back.png", "Texture/EBook/button_bg_layer.png");
		_this.onclick=";EBook_MainMenu.OnClose();";
		_parent:AddChild(_this);

		-- EB_MainMenu_RightCont
		NPL.load("(gl)script/ide/gui_helper.lua");
		_this = ParaUI.CreateUIObject("container", "EB_MainMenu_RightCont", "_fi", 155, 17, 12, 17)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent = ParaUI.GetUIObject("EBook_MainMenu");
		_parent:AddChild(_this);
		_parent = _this;

		_parent = ParaUI.GetUIObject("EB_MainMenu_RightCont");
		-- EB_MenuPage_MyBooks
		_this = ParaUI.CreateUIObject("container", "EB_MenuPage_MyBooks", "_fi", 4, 4, 4, 4)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("text", "label7", "_lt", 3, 5, 336, 16)
		_this.text = L"Select a book below and click open button";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("listbox", "EB_MyBooks_ListBox", "_fi", 3, 38, 6, 40)
		_this.background=EBook_MainMenu.panel_sub_bg;
		_this.scrollable = true;
		_this.wordbreak = false;
		_this.itemheight = 18;
		--_this.onselect = ";";
		_this.ondoubleclick = ";EBook_MainMenu.OnClickMyBooks_OpenBook();";
		_this.font = "System;13;norm";
		_this.scrollbarwidth = 20;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_MyBooks_DeleteBook", "_rb", -105, -36, 99, 26)
		_this.text = L"Delete";
		_this.onclick = ";EBook_MainMenu.OnClickMyBooks_DeleteBook();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_MyBooks_OpenBook", "_rb", -221, -36, 99, 26)
		_this.text = L"Open";
		_this.onclick = ";EBook_MainMenu.OnClickMyBooks_OpenBook();";
		_parent:AddChild(_this);

		-- EB_MenuPage_NewBook
		_this = ParaUI.CreateUIObject("container", "EB_MenuPage_NewBook", "_fi", 4, 25, 4, 4)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent = ParaUI.GetUIObject("EB_MainMenu_RightCont");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 6, 12, 288, 16)
		_this.text = L"Enter book name and click OK button";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label3", "_lt", 6, 39, 80, 16)
		_this.text = L"Book Name";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label4", "_lt", 6, 71, 96, 16)
		_this.text = L"Author Name";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("imeeditbox", "EB_NewBook_BookName", "_lt", 109, 36, 167, 26)
		_this.background = EBook_MainMenu.editbox_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("imeeditbox", "EB_NewBook_AuthorName", "_lt", 109, 68, 167, 26)
		_this.background = EBook_MainMenu.editbox_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_NewBook_Create_btn", "_rb", -184, -32, 81, 26)
		_this.text = L"OK";
		_this.onclick = ";EBook_MainMenu.OnNewBook_Create_btn();";
		_parent:AddChild(_this);

		-- EB_MenuPage_Download
		_this = ParaUI.CreateUIObject("container", "EB_MenuPage_Download", "_fi", 4, 25, 4, 4)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent = ParaUI.GetUIObject("EB_MainMenu_RightCont");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 12, 14, 264, 16)
		_this.text = L"Download books from our web site";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label5", "_lt", 12, 86, 192, 16)
		_this.text = L"Total Number of Books:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label6", "_lt", 12, 111, 152, 16)
		_this.text = L"Most recent books:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_Download_URLbtn", "_mt", 118, 45, 12, 23)
		_this.text = L"http://www.kids3dmovie.com";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "EB_Download_TotalBooksNo_Label", "_lt", 210, 86, 16, 16)
		_this.text = "0";
		_this:GetFont("text").color = "192 0 0";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("listbox", "EB_Download_BookList", "_fi", 15, 139, 12, 3)
		_this.scrollable = true;
		_this.wordbreak = false;
		_this.background = EBook_MainMenu.panel_bg;
		_this.itemheight = 18;
		--_this.onselect = ";";
		--_this.ondoubleclick = ";";
		_this.font = "System;13;norm";
		_this.scrollbarwidth = 20;
		_parent:AddChild(_this);

		-- EB_MenuPage_Publish
		_this = ParaUI.CreateUIObject("container", "EB_MenuPage_Publish", "_fi", 4, 25, 4, 4)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent = ParaUI.GetUIObject("EB_MainMenu_RightCont");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "EB_Publish_Upload", "_lt", 33, 27, 139, 32)
		_this.text = L"Upload to web";
		_this.onclick = ";EBook_MainMenu.OnClickPublish_UploadToWeb();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_Publish_Print", "_lt", 33, 74, 139, 31)
		_this.text = L"Print";
		_this.enabled = false;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_Publish_ZipFile", "_lt", 33, 121, 139, 32)
		_this.text = L"Export Zip File";
		_this.onclick = ";EBook_MainMenu.OnClickPublish_ZipFile();";
		_parent:AddChild(_this);

		-- switch to a tab page
		EBook_MainMenu.SwitchMainTabs(-1);
	else
		if(bShow == nil) then
			if(_this.visible == true) then
				_this.visible = false;
			else
				_this.visible = true;
			end
		else
			_this.visible = bShow;
		end
		if(_this.visible == true) then
			EBook_MainMenu.NeedsRefresh = true;
			EBook_MainMenu.SwitchMainTabs(0);
			_this:SetTopLevel(true);
		end
	end	
end

-- destory the control
function EBook_MainMenu.OnDestory()
	ParaUI.Destroy("EBook_MainMenu");
end

-- just hide the window
function EBook_MainMenu.OnClose()
	EBook_MainMenu.Show(false);
end

-- @param nIndex: 1-4
function EBook_MainMenu.SwitchMainTabs(nIndex)
	_guihelper.SwitchVizGroupByIndex(EBook_MainMenu.tabpages, nIndex);
	_guihelper.CheckRadioButtonsByIndex(EBook_MainMenu.tabbuttons, nIndex);
	if(nIndex == 1) then
		-- Load book
		if(EBook_MainMenu.NeedsRefresh) then
			EBook_MainMenu.NeedsRefresh = false;
			local _this = ParaUI.GetUIObject("EB_MyBooks_ListBox");
			if(_this:IsValid()) then
				-- refill all items
				_this:RemoveAll();
				-- list all sub directories in the EBook directory.
				CommonCtrl.InitFileDialog(ParaIO.GetCurDirectory(0)..EBook_db.library_path,{"*.", "*.zip", }, 0, 150, _this);
			end
		end	
	elseif(nIndex == 2) then
		-- New book
	elseif(nIndex == 3) then
		-- Download book
	elseif(nIndex == 4) then
		-- Publish book
	end
end

-----------------------------------
-- new book page
-----------------------------------
function EBook_MainMenu.OnNewBook_Create_btn()
	local bookname, authorname;
	local tmp;
	bookname = ParaUI.GetUIObject("EB_NewBook_BookName").text;
	authorname = ParaUI.GetUIObject("EB_NewBook_AuthorName").text;
	
	local res;
	-- create book
	res = EBook_db.NewBook(bookname);
	
	if(res==true) then
		-- set attributes
		EBook_db.book.author = authorname;
		EBook_db.book.bookname = bookname; -- TODO: book name may be a different name from the book file name

		-- add one new page
		res = EBook_db.NewPage({
			pagetitle = L"Chapter 1",
			pagetext = L"Enter your text here...",
		})
		
		if(res == true) then
			-- save the new book to file.
			res=EBook_db.SaveCurrentEBook();
			if(res == true) then
				res = EBook.OpenBook(bookname);
				if(res) then
					-- update bookshelf, since new book is loaded.
					EBook.UpdateBookShelf(true);
				end	
			end	
		end	
	end
	
	if(res == true)then
		EBook_MainMenu.OnClose();
		_guihelper.MessageBox(L"Book successfully created. You can now edit the book.");
	elseif(type(res) == "string") then
		-- display the error message if any.
		_guihelper.MessageBox(res);
	end
end

-----------------------------------
-- load book page
-----------------------------------
function EBook_MainMenu.OnClickMyBooks_OpenBook()
	local _this = ParaUI.GetUIObject("EB_MyBooks_ListBox");
	if(_this:IsValid()) then
		local bookname = _this.text;
		if(bookname=="") then
			_guihelper.MessageBox(L"Please select a world from the list first");
			return
		end
		local res = EBook.OpenBook(bookname);
		
		if(res == true)then
			EBook_MainMenu.OnClose();
		elseif(type(res) == "string") then
			-- display the error message if any.
			_guihelper.MessageBox(res);
		end
	end
end

function EBook_MainMenu.OnClickMyBooks_DeleteBook()
	local tmp = ParaUI.GetUIObject("EB_MyBooks_ListBox");
	if(tmp:IsValid() == true and tmp.text~="") then  
		local sName = tmp.text;
		local dirPath = string.gsub(EBook_db.library_path..sName, "/", "\\");
		if(dirPath)then
			_guihelper.MessageBox(string.format(L"Are you sure you want to delete %s?\n Deleted files will be moved to %s.", dirPath, "temp\\"..dirPath), 
				string.format([[EBook_MainMenu.OnClickMyBooks_DeleteBook_imp(%q)]], dirPath));
		end
	end
end

-- @param worldpath: which world to delete
function EBook_MainMenu.OnClickMyBooks_DeleteBook_imp(worldpath)
	local targetDir = "temp\\"..worldpath;
	if(ParaIO.CreateDirectory(targetDir) and ParaIO.MoveFile(worldpath, targetDir)) then  
		-- refresh folder
		EBook_MainMenu.NeedsRefresh = true;
		EBook_MainMenu.SwitchMainTabs(1);
	else
		_guihelper.MessageBox(L"Unable to delete. Perhaps you do not have enough access rights"); 
	end
end

-----------------------------------
-- save page
-----------------------------------
function EBook_MainMenu.OnClickSave_btn()
	local res = EBook_db.SaveCurrentEBook();
	if(res == true)then
		EBook_MainMenu.OnClose();
	elseif(type(res) == "string") then
		-- display the error message if any.
		_guihelper.MessageBox(res);
	end
end

-----------------------------------
-- Publish page
-----------------------------------
function EBook_MainMenu.OnClickPublish_UploadToWeb()
	EBook_MainMenu.OnClose();
	EBook_db.SubmitEBook();
end

function EBook_MainMenu.OnClickPublish_ZipFile()
	EBook_MainMenu.OnClose();
	EBook_db.SaveAsZipFile();
end