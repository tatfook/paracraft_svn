--[[
Title: EBook main window
Author(s): LiXizhi
Date: 2007/4/12
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/EBook/EBook.lua");
EBook.Show();
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/EBook/EBook_db.lua");
NPL.load("(gl)script/EBook/EBook_MainMenu.lua");
NPL.load("(gl)script/EBook/EBook_MediaMenu.lua");

local L = CommonCtrl.Locale("KidsUI");

if(not EBook) then EBook={}; end

-- properties 
EBook.default_book = L"Default Book"; 
EBook.last_voice_file = nil; -- last played voicefile
EBook.last_music_file = nil; -- last played music file
-- if the current book is a zipped book, we will completed disable book editing functions.
EBook.bIsZipBook = false;
-- width of text control
EBook.TextContentWidth = 260;

-- the index of the first book in the EBook.allbooks. firstbook is shown as the first book in the current book page 
EBook.firstbookIndex = 1;
-- how many books to be displayed on the single screen. 
EBook.MaxBookPerScreen = 4;
-- an array all books sorted by name
EBook.allbooks = {};

-- appearance
EBook.main_bg = "Texture/kidui/explorer/bg.png"
EBook.panel_bg = "Texture/kidui/explorer/panel_bg.png"
EBook.panel_sub_bg = "Texture/kidui/explorer/panel_sub_bg.png"
EBook.button_bg = "Texture/kidui/explorer/button.png"
EBook.listbox_bg = "Texture/kidui/explorer/listbox_bg.png"
EBook.dropdownarrow_bg = "Texture/kidui/explorer/dropdown_arrow.png"
EBook.dropdownlist_cont_bg = "Texture/kidui/explorer/editbox256x32.png"
EBook.editbox_bg = "Texture/kidui/explorer/editbox128x32.png"
EBook.editbox_long_bg = "Texture/kidui/explorer/editbox256x32.png"

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function EBook.Show(bShow)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("EBook_canvas_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		local left, top;
		local width, height = 790, 560
		-- EBook
		_this = ParaUI.CreateUIObject("container", "EBook_canvas_cont", "_fi", 0,0,0,0)
		_this.background = "Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "255 255 255 150"); -- fade the background
		_this:SetTopLevel(true);
		_this:AttachToRoot();
		_parent = _this;

		-- background
		_this = ParaUI.CreateUIObject("container", "s", "_ct", -460, -375, 932, 698)
		_this.background = L"Texture/EBook/ebook_bg.png";
		_this.enabled = false;
		_parent:AddChild(_this);
		
		-- true EBook container
		_this = ParaUI.CreateUIObject("container", "EBook", "_ct", -460, -375, 932, 698)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("button", "EB_Close", "_rt", -52, 3, 32, 32);--  "_rb", -80, -60, 32, 32)
		_this.background="Texture/EBook/close.png";
		_this.animstyle = 22;
		_this.onclick = ";EBook.Show(false);";
		_this.tooltip = L"Close";
		_parent:AddChild(_this);
		
		--_this = ParaUI.CreateUIObject("button", "EB_Close", "_rb", -48, -60, 48, 32)
		--_this.onclick = ";EBook.Show(false);";
		--_this.text = L"Close"
		--_this:GetFont("text").color = "0 0 139";
		--_guihelper.SetVistaStyleButton(_this, "Texture/whitedot.png;0 0 0 0", "Texture/EBook/button_bg_layer.png");
		--_guihelper.SetUIFontFormat(_this, 4);-- make text align to left, and vertical centered
		--_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "EB_BookTitle_Text", "_lt", 246, 100, 200, 16)
		_this.text = "EB_BookTitle_Text";
		_this:GetFont("text").color = "0 0 139";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "EB_AuthorName_Text", "_lt", 555, 100, 152, 16)
		_this.text = "EB_AuthorName_Text";
		_this:GetFont("text").color = "0 0 139";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_MainMenu", "_lt", 0, 32, 128, 128)
		_this.background="Texture/EBook/mainmenu.png";
		_this.animstyle = 12;
		_this.onclick = ";EBook.OnClickMainMenu();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_Help", "_lt", 66, 642, 32, 32)
		_this.background="Texture/EBook/help.png";
		_this.onclick = ";EBook.OnClickHelp();";
		_this.tooltip = L"Open Help Book";
		_this.animstyle = 12;
		_parent:AddChild(_this);
		
		-- panel1
		_this = ParaUI.CreateUIObject("container", "panel1", "_lt", 28, 185, 111, 438)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "EB_BookBrowse_Up_btn", "_lt", 34, 43, 32, 16)
		_this.background="Texture/EBook/up.png";
		_this.animstyle = 12;
		_this.onclick = ";EBook.OnClickBookBrowse_Up_btn();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_BookBrowse_Down_btn", "_lb", 38, -42, 32, 16)
		_this.background="Texture/EBook/down.png";
		_this.animstyle = 12;
		_this.onclick = ";EBook.OnClickBookBrowse_Down_btn();";
		_parent:AddChild(_this);

		left, top = 30, 65;
		width, height = 32,64;
		local i;
		for i=1,EBook.MaxBookPerScreen do
			_this = ParaUI.CreateUIObject("button", "EB_BookIcon"..i, "_lt", left, top, width, height);
			_this.background = "Texture/whitedot.png;0 0 0 0";
			_this.onclick = string.format(";EBook.OnClickOpenBook(%d);", i);
			_parent:AddChild(_this);
			
			top = top + height;
			_this = ParaUI.CreateUIObject("button", "EB_BookIconText"..i, "_lt", left-30, top, width+30*2, 16);
			_this.background = "Texture/whitedot.png;0 0 0 0";
			_this:GetFont("text").color = "0 0 139";
			_this.onclick = string.format(";EBook.OnClickOpenBook(%d);", i);
			_parent:AddChild(_this);
			top = top + 18;
		end

		-- EB_Book_Cont
		_this = ParaUI.CreateUIObject("container", "EB_Book_Cont", "_fi", 145, 113, 120, 75)
		_parent = ParaUI.GetUIObject("EBook");
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "EB_PageTitle_Text", "_lt", 105, 33, 200, 16)
		_this:GetFont("text").color = "0 0 139";
		_parent:AddChild(_this);

		--_this = ParaUI.CreateUIObject("text", "label2", "_rb", -199, -29, 96, 16)
		--_this.text = "Page number";
		--_this:GetFont("text").color = "0 0 139";
		--_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_PageMedia_Menu", "_lt", 322, 4, 48, 48)
		_this.background="Texture/EBook/mediamenu.png";
		_this.animstyle = 12;
		_this.onclick = ";EBook.OnClickMediaMenu();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_EnterPageWorld_Btn", "_lt", 420, 320, 64, 64)
		_this.background="Texture/EBook/enterworld.png";
		_this.animstyle = 22;
		_this.onclick = ";EBook.OnClickEnterPageWorld();";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "EB_PlayPageSound_Btn", "_lt", 518, 336, 128, 32)
		_this.background="Texture/EBook/playsound.png";
		_this.onclick = ";EBook.OnClickPlayPageSound_Btn();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_Canvas_scaledown_btn", "_lt", 580, 278, 32, 32)
		_this.background="Texture/EBook/minify.png";
		_this.onclick = ";EBook.OnClickCanvas_scaledown_btn();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_Canvas_scaleup_btn", "_lt", 543, 278, 32, 32)
		_this.background="Texture/EBook/magnify.png";
		_this.onclick = ";EBook.OnClickCanvas_scaleup_btn();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "EB_PageNumber_Editbox", "_rb", -60, -44, 37, 26)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_Goto_page_btn", "_rb", -36, -36, 32, 32)
		_this.background="Texture/EBook/goto.png";
		_this.animstyle = 12;
		_this.onclick = ";EBook.OnClickGoto_page_btn();";
		_parent:AddChild(_this);

		-- EB_PageMedia_Cont
		_this = ParaUI.CreateUIObject("container", "EB_PageMedia_Cont", "_lt", 333, 53, 294, 223)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		--_this.scrollable = true;
		_parent:AddChild(_this);
		_parent = _this;

	
		NPL.load("(gl)script/EBook/ImageViewer.lua");
		local ctl = CommonCtrl.ImageViewer:new{
			name = "EB_Canvas_Btn",
			alignment = "_lt",
			left=0, top=0,
			width = _parent.width,
			height = _parent.height,
			parent = _parent,
			imagefile = "Texture/whitedot.png;0 0 0 0";
		};
		ctl:Show();

		NPL.load("(gl)script/ide/FlashPlayerControl.lua");
		local ctl = CommonCtrl.FlashPlayerControl:new{
			name = "EB_Canvas_Flash",
			FlashPlayerIndex = 0,
			alignment = "_fi",
			left=0, top=0,
			width = 0,
			height = 0,
			parent = _parent,
		};
		ctl:Show();

		-- EB_PageText_cont
		_this = ParaUI.CreateUIObject("container", "EB_PageText_cont", "_lt", 29, 77, 280, 390)
		_this.scrollable = true;
		_parent = ParaUI.GetUIObject("EB_Book_Cont");
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "EB_PageText", "_lt", 10, 17, EBook.TextContentWidth, 16)
		_this:GetFont("text").color = "0 0 139";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_PreviousPage_Btn", "_rb", -226, -60, 64, 32)
		_this.background=L"Texture/EBook/lastpage.png";
		_this.onclick = ";EBook.OnClickPreviousPage_Btn();";
		_this.animstyle = 12;
		_parent = ParaUI.GetUIObject("EBook");
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_NextPage_Btn", "_rb", -160, -60, 64, 32)
		_this.background=L"Texture/EBook/nextpage.png";
		_this.onclick = ";EBook.OnClickNextPage_Btn();";
		_this.animstyle = 12;
		_parent:AddChild(_this);
		
		
		_this = ParaUI.CreateUIObject("button", "EB_LockBook_btn", "_lb", 155, -66, 32, 32)
		_this.background="Texture/EBook/locked.png";
		_this.onclick = ";EBook.LockBook();";
		_this.tooltip = L"Lock/Unlock book";
		_parent:AddChild(_this);

		-- EB_BookEditorBar
		_this = ParaUI.CreateUIObject("container", "EB_BookEditorBar", "_lb", 195, -70, 313, 40)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "EB_NewPage_Btn", "_lt", 4, 4, 32, 32)
		_this.background="Texture/EBook/newpage.png";
		_this.animstyle = 12;
		_this.onclick = ";EBook.OnClickNewPage_Btn();";
		_this.tooltip = L"Create a new page";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_RemovePage_Btn", "_lt", 36, 4, 32, 32)
		_this.background="Texture/EBook/deletepage.png";
		_this.animstyle = 12;
		_this.onclick = ";EBook.OnClickRemovePage_Btn();";
		_this.tooltip = L"Delete current page";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_EditPageTitle_Btn", "_lt", 76, 4, 32, 32)
		_this.background="Texture/EBook/edittitle.png";
		_this.animstyle = 12;
		_this.tooltip = L"Edit page title";
		_this.onclick = ";EBook.OnClickEditPageTitle();"
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_EditPageText_Btn", "_lt", 110, 4, 32, 32)
		_this.background="Texture/EBook/edittext.png";
		_this.animstyle = 12;
		_this.tooltip = L"Edit page content";
		_this.onclick = ";EBook.OnClickEditPageText();"
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "EB_PageStyle_comboBox",
			alignment = "_lt",
			left = 159,
			top = 8,
			width = 140,
			height = 24,
			dropdownheight = 72,
 			parent = _parent,
 			container_bg = EBook.dropdownlist_cont_bg,
			editbox_bg = "Texture/whitedot.png;0 0 0 0",
			dropdownbutton_bg = EBook.dropdownarrow_bg,
			listbox_bg = EBook.listbox_bg,
			text = L"standard",
			items = {L"standard",L"delux",L"simple",},
		};
		ctl:Show();
		ctl:SetEnabled(false);
		
		-- load the default book if any
		if(EBook_db.book ==nil and EBook.default_book~=nil) then
			local res = EBook.OpenBook(EBook.default_book);
			if(res~=true and type(res) == "string") then
				-- display the error message if any.
				_guihelper.MessageBox(res);
			end
		end
		-- update book anyway
		EBook.UpdateBookShelf(true);
		EBook.UpdateBook();
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
		if(bShow == true) then
			_this:SetTopLevel(true);
			-- update book anyway
			EBook.UpdateBook();
		else
			-- ensure that book media are freed
			CommonCtrl.OneTimeAsset.Add("EBook media", nil);
		end
	end	
	
	if(bShow) then
		KidsUI.PushState({name = "EBook", OnEscKey = "EBook.Show(false);"});
	else
		KidsUI.PopState("EBook");
		EBook_MainMenu.Show(false);
		EBook_MediaMenu.Show(false);
	end
end

-- destory the control
function EBook.OnDestory()
	ParaUI.Destroy("EBook_canvas_cont");
end

---------------------------------
-- events
---------------------------------

-- click to show the mainmenu
function EBook.OnClickMainMenu()
	local x,y,width,height = ParaUI.GetUIObject("EB_MainMenu"):GetAbsPosition();
	EBook_MainMenu.Show(true, x,y+height);
end

-- click to show the media menu
function EBook.OnClickMediaMenu()
	local x,y,width,height = ParaUI.GetUIObject("EB_PageMedia_Menu"):GetAbsPosition();
	EBook_MediaMenu.Show(true, x-200,y+height);
end

function EBook.OnClickPlayPageSound_Btn()
	EBook.PlayPageAudio();
end

function EBook.OnClickCanvas_scaledown_btn()
	local page = EBook_db.GetCurrentPage();
	
	if(page.mediafile==nil or page.mediafile=="") then return end
	
	CommonCtrl.ImageViewer.Scale("EB_Canvas_Btn", -0.2)
end

function EBook.OnClickCanvas_scaleup_btn()
	local page = EBook_db.GetCurrentPage();
	
	if(page.mediafile==nil or page.mediafile=="") then return end
	
	CommonCtrl.ImageViewer.Scale("EB_Canvas_Btn", 0.2)
end


function EBook.OnClickPreviousPage_Btn()
	EBook.OnGotoPage(EBook_db.book.currentpage-1);
end

function EBook.OnClickNextPage_Btn()
	EBook.OnGotoPage(EBook_db.book.currentpage+1);
end

function EBook.OnClickGoto_page_btn()
	local pageNumber = tonumber(ParaUI.GetUIObject("EB_PageNumber_Editbox").text);
	-- if it is the current page, we will just show the next page, which is really a tricky logic.
	if(EBook_db.book.currentpage == pageNumber) then
		pageNumber = pageNumber +1;
	end
	EBook.OnGotoPage(pageNumber);
end

-- create a new page just after the current page.
function EBook.OnClickNewPage_Btn()
	local res = EBook_db.NewPage({
		pagetitle = string.format(L"Chapter %d", EBook_db.book.pagesCount+1),
		pagetext = L"Enter your text here...",
	}, EBook_db.book.currentpage);
	
	if(res == true) then
		EBook.OnGotoPage(EBook_db.book.currentpage+1);
		EBook.UpdatePage();
	elseif(type(res) == "string") then
		_guihelper.MessageBox(res);	
	end	
end

-- remove the current page. 
function EBook.OnClickRemovePage_Btn()
	local page = EBook_db.GetCurrentPage();
	if(page~=nil) then 
		_guihelper.MessageBox(string.format(L"Are you sure you want to delete the current page %s ?", tostring(page.pagetitle)), function()
			local res = EBook_db.RemovePage(EBook_db.book.currentpage);
			if(res) then
				EBook.UpdatePage();
			elseif(type(res) == "string") then
				_guihelper.MessageBox(res);
			end
		end);
	end	
end

-- call this to edit the page text
function EBook.OnClickEditPageTitle()
	local ctl = CommonCtrl.GetControl("EBookTitleEditor");
	if(ctl==nil or ParaUI.GetUIObject("EBookTitleEditor"):IsValid()==false) then
		NPL.load("(gl)script/EBook/PopupEditor.lua");
		ctl = CommonCtrl.PopupEditor:new{
			name = "EBookTitleEditor",
			alignment = "_lt",
			left=0, top=0,
			width = 300,
			height = 100,
			item_count = 2,
			item_height = 26,
			item_spacing = 2,
			parent = nil,
			on_ok = EBook.OnTitleChanged,
		};	
	end
	local tmp = ParaUI.GetUIObject("EB_PageTitle_Text");
	if(tmp:IsValid()) then
		local x,y = tmp:GetAbsPosition();
		ctl:Show(true, tmp.text, x, y+30);
	end
end

function EBook.OnTitleChanged(ctl, text)
	if(text~=nil) then
		ParaUI.GetUIObject("EB_PageTitle_Text").text = text;
		local page = EBook_db.GetCurrentPage();
		if(page~=nil) then 
			page.pagetitle = text;
		end
	end
end

-- call this to edit the page text
function EBook.OnClickEditPageText()
	local ctl = CommonCtrl.GetControl("EBookPageTextEditor");
	if(ctl==nil or ParaUI.GetUIObject("EBookPageTextEditor"):IsValid()==false) then
		NPL.load("(gl)script/EBook/PopupEditor.lua");
		ctl = CommonCtrl.PopupEditor:new{
			name = "EBookPageTextEditor",
			alignment = "_lt",
			left=0, top=0,
			width = EBook.TextContentWidth+10*3, -- add some spacing
			textwidth = EBook.TextContentWidth,
			height = 390,
			item_count = 12,
			item_height = 26,
			item_spacing = 2,
			parent = nil,
			on_ok = EBook.OnPageTextChanged,
		};	
	end
	local tmp = ParaUI.GetUIObject("EB_PageText");
	if(tmp:IsValid()) then
		local x,y = tmp:GetAbsPosition();
		ctl:Show(true, tmp.text, x-10, y+30);
	end
end

function EBook.OnPageTextChanged(ctl, text)
	if(text~=nil) then
		ParaUI.GetUIObject("EB_PageText").text = text;
		local page = EBook_db.GetCurrentPage();
		if(page~=nil) then 
			page.pagetext = text;
		end
	end
end

function EBook.OnClickBookBrowse_Down_btn()
	EBook.firstbookIndex = EBook.firstbookIndex+EBook.MaxBookPerScreen;
	EBook.UpdateBookShelf();
end
function EBook.OnClickBookBrowse_Up_btn()
	EBook.firstbookIndex = EBook.firstbookIndex-EBook.MaxBookPerScreen;
	EBook.UpdateBookShelf();
end

-- @param pageNumber: error message is displayed if invalid page number.
function EBook.OnGotoPage(pageNumber)
	if(pageNumber~=nil) then
		if(EBook_db.book.currentpage ~= pageNumber) then 
			if(pageNumber<=0) then
				--_guihelper.MessageBox("page number must be above 0");	
			elseif(pageNumber>EBook_db.book.pagesCount) then
				--_guihelper.MessageBox(string.format("The book does not contain page number %d",pageNumber));	
			else
				EBook_db.book.currentpage = pageNumber;
				EBook.UpdatePage();
			end
		end
	else
		--_guihelper.MessageBox("invalid page number");	
	end	
end

-- call open use click the book icon
-- @param nIndex: book icon index, normally 1-4
function EBook.OnClickOpenBook(nIndex)
	local bookname = EBook.allbooks[EBook.firstbookIndex+nIndex-1];
	if(bookname~=nil) then
		local res = EBook.OpenBook(bookname);
		if(res~=true and type(res) == "string") then
			-- display the error message if any.
			_guihelper.MessageBox(res);
		end
	end
end

---------------------------------
-- update method
---------------------------------

-- call this function to open a certain book by name.
function EBook.OpenBook(bookname)
	local res = EBook_db.LoadEBookByName(bookname);
	if(res) then
		-- update UI, since new book is loaded.
		if(string.find(bookname, ".*%.zip$")~=nil) then
			EBook.bIsZipBook = true;
			-- make all zip file readonly
			EBook_db.book.readonly = true;
		else
			EBook.bIsZipBook = false;
		end	
		EBook.UpdateBook();
	end
	return res;
end

-- call this function to update book list on the bookshelf
-- @param refreshBookList: if this is true, EBook.allbooks will be refreshed from the disk file.
function EBook.UpdateBookShelf(refreshBookList)

	-- EBook.allbooks will be refreshed from the disk file.
	if(refreshBookList) then
		EBook.allbooks = {};
		commonlib.SearchFiles(EBook.allbooks, ParaIO.GetCurDirectory(0)..EBook_db.library_path, {"*.", "*.zip",}, 0, 50, true);	
	end
	
	-- validate firstbookIndex
	local nTotalBooks = table.getn(EBook.allbooks);
	if(EBook.firstbookIndex<=0) then
		EBook.firstbookIndex = nTotalBooks-EBook.MaxBookPerScreen;
		if(EBook.firstbookIndex<=0) then
			EBook.firstbookIndex = 1;
		end
	end	
	if(EBook.firstbookIndex>nTotalBooks) then
		EBook.firstbookIndex = 1;
	end	
	
	-- update UI.
	local i;
	for i=1,EBook.MaxBookPerScreen do
		local nIndex = EBook.firstbookIndex+i-1;
		local IconBtn, TextBtn;
		IconBtn = ParaUI.GetUIObject("EB_BookIcon"..i);
		TextBtn = ParaUI.GetUIObject("EB_BookIconText"..i);
		local bookname = EBook.allbooks[nIndex];
		if(bookname~=nil) then
			if(string.find(bookname, ".*%.zip$")~=nil) then
				IconBtn.background = "Texture/EBook/book_zipped.png";
				IconBtn.tooltip = string.format(L"%s(readonly)", bookname);
				bookname = string.gsub(bookname, "(.*)%.zip$", "%1"); -- get rid of the book zip file extension for display 
			else
				IconBtn.background = "Texture/EBook/book_normal.png";
				IconBtn.tooltip = bookname;
			end	
			
			local MasLetters = 10;
			if(string.len(bookname)>MasLetters) then
				TextBtn.text = string.sub(bookname, 0, MasLetters-2)..".."; -- display only the first few letters.
			else
				TextBtn.text = bookname;
			end	
		else
			IconBtn.background = "Texture/whitedot.png;0 0 0 0";
			TextBtn.text = "";
		end
	end

end
-- call this function when the book in the current EBook_db is changed, such as loaded.
function EBook.UpdateBook()
	local _this;
	if(EBook_db.book == nil) then 
		-- TODO: show a blank book
		return 
	end
	ParaAudio.StopCategory("Background");
	ParaUI.GetUIObject("EB_BookTitle_Text").text = EBook_db.book.bookname;
	ParaUI.GetUIObject("EB_AuthorName_Text").text = EBook_db.book.author;
	-- play some initial sound or animation?
	EBook.UpdatePage();
	
	if(EBook.bIsZipBook) then
		-- TODO: may be display a zip book mark at the EB_LockBook_btn location
		local editorbar = ParaUI.GetUIObject("EB_BookEditorBar");
		local lockButton = ParaUI.GetUIObject("EB_LockBook_btn");
		local MediaMenu = ParaUI.GetUIObject("EB_PageMedia_Menu");
		lockButton.visible = false;
		editorbar.visible = false;
		MediaMenu.visible = false;
	else
		EBook.LockBook(EBook_db.book.readonly);
	end
end

-- call this if the current book is changed.
function EBook.UpdatePage()
	EBook.UpdatePageText();
	EBook.UpdatePageMedia();
	EBook.PlayPageAudio();
end

-- call this if the page media is changed.
function EBook.UpdatePageMedia()
	local page = EBook_db.GetCurrentPage();
	if(page==nil) then return end
	
	local ImageViewer = CommonCtrl.GetControl("EB_Canvas_Btn");
	local FlashViewer = CommonCtrl.GetControl("EB_Canvas_Flash");
	
	if(not ImageViewer or not FlashViewer) then return end
	
	local fileExtension;
	if(page.mediafile ~= nil) then
		fileExtension = string.gsub(page.mediafile, ".*%.(%a%a%a)$", "%1");
	end
	
	-- this ensure that old images are freed first
	CommonCtrl.OneTimeAsset.Add("EBook media", page.mediafile);
	
	if(fileExtension ~=nil and (fileExtension=="swf" or fileExtension=="flv")) then
		-- this is a flash movie
		ImageViewer:SetImage(nil);
		FlashViewer:LoadMovie(page.mediafile);
		--TODO: bring to front
	else
		-- this is a just an ordinary image
		FlashViewer:LoadMovie(nil);
		ImageViewer:SetImage(page.mediafile);
		--TODO: bring to front
	end	
	
	-- set the tooltips
	local _this = ParaUI.GetUIObject("EB_EnterPageWorld_Btn");
	if(page.worldpath == nil) then
		_this.enabled = false;
		_this.tooltip = "";
	else
		_this.enabled = true;
		_this.tooltip = string.format(L"Click to enter the world of:\r\n%s", page.worldpath)
	end
	
	-- update sound button
	local bHasSound = page.music_file~=nil or page.voice_file~=nil;
	ParaUI.GetUIObject("EB_PlayPageSound_Btn").enabled = bHasSound;
end

-- call this if the current page text is changed.
function EBook.UpdatePageText()
	local page = EBook_db.GetCurrentPage();
	if(page==nil) then return end

	if(page.pagetitle==nil)then page.pagetitle = "" end
	ParaUI.GetUIObject("EB_PageTitle_Text").text = page.pagetitle;
	if(page.text==nil)then page.text = "" end
	ParaUI.GetUIObject("EB_PageText").text = page.pagetext;
	if(EBook_db.book.currentpage==nil)then EBook_db.book.currentpage = 1 end
	ParaUI.GetUIObject("EB_PageNumber_Editbox").text = tostring(EBook_db.book.currentpage);
end

-- called to play the page music associated with the page. 
function EBook.PlayPageAudio()
	local page = EBook_db.GetCurrentPage();
	if(page==nil) then return end
	
	-- stop the last page audio if any.
	if(EBook.last_music_file~=nil and EBook.last_music_file~=page.music_file) then
		ParaAudio.StopWaveFile(EBook.last_music_file, true);
	end
	if(EBook.last_voice_file~=nil and EBook.last_voice_file~=page.voice_file) then
		ParaAudio.StopWaveFile(EBook.last_voice_file, true);
	end
	
	local bHasSound = false;
	-- play the current page audio: music
	if(page.music_file==nil or page.music_file == "") then 
		-- Play no sound?
	elseif(ParaIO.DoesFileExist(page.music_file, true)) then
		-- play music
		ParaAudio.PlayWaveFile(page.music_file, 0); -- play with no loop.
		bHasSound = true;
	else	
		-- music for invalid music path
	end
	
	-- play the current page audio: voice
	if(page.voice_file==nil or page.voice_file == "") then 
		-- Play no sound?
	elseif(ParaIO.DoesFileExist(page.voice_file, true)) then
		-- play voice
		ParaAudio.PlayWaveFile(page.voice_file, 0); -- play with no loop.
		bHasSound = true;
	else	
		-- voice for invalid voice path
	end
	
	ParaUI.GetUIObject("EB_PlayPageSound_Btn").enabled = bHasSound;
end

-- make the book read-only or not.
-- @param bLock, if nil it will be toggled.
function EBook.LockBook(bLock)
	if(bLock==nil) then
		bLock = not EBook_db.book.readonly;
	end
	EBook_db.book.readonly = bLock;
	
	local editorbar = ParaUI.GetUIObject("EB_BookEditorBar");
	local lockButton = ParaUI.GetUIObject("EB_LockBook_btn");
	local MediaMenu = ParaUI.GetUIObject("EB_PageMedia_Menu");
	
	if(bLock) then
		lockButton.visible = true;
		lockButton.background="Texture/EBook/locked.png";
		editorbar.visible = false;
		MediaMenu.visible = false;
	else
		lockButton.visible = true; 
		lockButton.background="Texture/EBook/unlocked.png";
		editorbar.visible = true;
		MediaMenu.visible = true;
	end
end

-----------------------------------------
-- in-game related functions
-----------------------------------------

-- this function is called immediately after the book world is loaded. 
-- it will reset the player position and movie clips for the world associated with the current book page. 
--@param bShow: boolean to show or hide the necessary book world UI. if nil, it will toggle current setting. 
function EBook.ResetBookWorld(bShow)
	local _this,_parent;
	_this=ParaUI.GetUIObject("EBook_ReturnToBookBtn");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		
		_this = ParaUI.CreateUIObject("button", "EBook_ReturnToBookBtn", "_rb", -70, -256, 64, 64)
		_this.background="Texture/EBook/returntobook.png";
		_this.animstyle = 22;
		_this.tooltip = L"return to book";
		_this.onclick = ";EBook.OnClickReturnToBookBtn();";
		_this:AttachToRoot();
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
	end	
	-- Load book.
	EBook_db.AutoLoadPageWorld();
end	

-- called when the user click the return to book button.
-- TODO: maybe in future, I shall use a popup menu instead of a single button in the game.
function EBook.OnClickReturnToBookBtn()
	if(mouse_button == "left") then
		EBook_db.AutoSavePageWorld();
		EBook.Show(true);
	elseif(mouse_button == "right")	 then
		if(EBook_db.book.readonly) then
			_guihelper.MessageBox(L"This book is read only. Page save is ignored.");
		else
			local page = EBook_db.GetCurrentPage();
			if(not page) then return end
			
			-- display a dialog asking for options
			local temp = ParaUI.GetUIObject("IDE_BOOKWORLD_RETURN_MSGBOX");
			if(temp:IsValid()==false) then 
				local _this,_parent;
				local width, height = 370,150
				_this=ParaUI.CreateUIObject("container","IDE_BOOKWORLD_RETURN_MSGBOX", "_ct",-width/2,-height/2-50,width, height);
				_this:AttachToRoot();
				_this.background="Texture/msg_box.png";
				_this:SetTopLevel(true); -- _this.candrag and TopLevel and not be true simultanously 
				_parent = _this;
				
				_this=ParaUI.CreateUIObject("text","s", "_lt",15,11,width-40,20);
				_parent:AddChild(_this);
				_this.text=string.format(L"Do you want to save the screen shot of the current world to the book?\r\nCurrent book chapter is %s", tostring(page.pagetitle));
				
				width, height = 70, 26
				_this=ParaUI.CreateUIObject("button","s", "_rb",-270, -40,width+45, height);
				_parent:AddChild(_this);
				_this.text=L"Save(No GUI)";
				_this.tooltip=L"Save screen shot without 2D graphic user interface";
				_this.onclick=";EBook.OnClickSaveToBookWithOption(false);";
				
				_this=ParaUI.CreateUIObject("button","s", "_rb",-150, -40,width, height);
				_parent:AddChild(_this);
				_this.text=L"Save";
				_this.tooltip=L"Save screen shot with everything";
				_this.onclick=";EBook.OnClickSaveToBookWithOption(true);";
				
				_this=ParaUI.CreateUIObject("button","IDE_HELPER_MSGBOX_CANCEL", "_rb",-80, -40,width, height);
				_parent:AddChild(_this);
				_this.text=L"Cancel";
				_this.onclick=";ParaUI.Destroy(\"IDE_BOOKWORLD_RETURN_MSGBOX\");";	
			end	
		end		
	end	
end

function EBook.OnClickSaveToBookWithOption(bSaveWithGUI)
	ParaUI.Destroy("IDE_BOOKWORLD_RETURN_MSGBOX");
	if(bSaveWithGUI) then
		-- save with GUI
		ParaUI.ShowCursor(false);
		ParaEngine.ForceRender();ParaEngine.ForceRender(); -- since we take image on backbuffer, we will render it twice to make sure the backbuffer is updated
		--ParaEngine.Sleep(0.1); -- this gives the graphics card some time to refresh screen buffer under full screen mode, since we will later take a screen shot
		-- save and take screen shot
		EBook_db.SavePageWorld();
		
		ParaUI.ShowCursor(true);
		EBook.Show(true);
	else
		-- save without GUI
		ParaUI.GetUIObject("root").visible = false;
		ParaUI.ShowCursor(false);
		ParaEngine.ForceRender();ParaEngine.ForceRender(); -- since we take image on backbuffer, we will render it twice to make sure the backbuffer is updated
		--ParaEngine.Sleep(0.1);-- this gives the graphics card some time to refresh screen buffer under full screen mode, since we will later take a screen shot
		
		-- save and take screen shot
		EBook_db.SavePageWorld();
		
		ParaUI.ShowCursor(true);
		ParaUI.GetUIObject("root").visible = true;
		EBook.Show(true);
	end
end

-- on click the page world
function EBook.OnClickEnterPageWorld()
	local page = EBook_db.GetCurrentPage();
	if(not page) then return end	
	
	if(page.worldpath~=nil) then
		local res = KidsUI.LoadWorldImmediate(page.worldpath);
		if(res==true) then
			-- Do something after the load	
			EBook.ResetBookWorld(true);
			
			-- in case the book is readonly, so is any world associated with it.
			if(EBook.bIsZipBook or EBook_db.book.readonly) then
				kids_db.world.readonly = true;
				kids_db.User.SetRole("poweruser");
			else
				kids_db.User.SetRole("administrator");
			end
		elseif(type(res) == "string") then
			-- show the error message
			_guihelper.MessageBox(res);
		end
	end
end

-- open the help book
function EBook.OnClickHelp()
	local bookname = L"Book of Help";
	if(bookname~=nil) then
		local res = EBook.OpenBook(bookname);
		if(res~=true and type(res) == "string") then
			-- display the error message if any.
			_guihelper.MessageBox(res);
		end
	end
end