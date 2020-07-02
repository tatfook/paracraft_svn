--[[
Title: The EBook Database
Author(s): LiXizhi
Date: 2007/4/12
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/EBook/EBook_db.lua");

-- EBook_db.book contains the current book
EBook_db.NewBook(filename);
EBook_db.NewPage(page);
EBook_db.LoadEBookFromFile(filename);
EBook_db.SaveCurrentEBook();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
local L = CommonCtrl.Locale("ParaWorld");

-- EBook_db: 
if(not EBook_db) then EBook_db={}; end

EBook_db.webservice_UploadUserFile  = L("UploadUserFile.asmx");
EBook_db.webservice_SubmitEBook  = L("SubmitEBook.asmx");
--EBook_db.webservice_UploadUserFile = "http://localhost:1225/KidsMovieSite/UploadUserFile.asmx";
--EBook_db.webservice_SubmitEBook = "http://localhost:1225/KidsMovieSite/SubmitEBook.asmx";
EBook_db.DefaultCategoryID = 110; -- default ebook category id on the community website.
EBook_db.IsUploadFinished = true;
EBook_db.articleURL = "";
EBook_db.msg = nil; -- upload message in progress
EBook_db.callbackScript=nil;

EBook_db.library_path = "EBooks/";
EBook_db.MaxBookPages = 200;
-- an entire book can be inside a zip file, e.g. "EBooks/MyBook" can be zipped to "EBooks/MyBook.zip"
-- please note that files in the zip book file must be relative path like "MyBook/*.*" in the above case.
EBook_db.LastZipBookFile = nil;

-- the current book
EBook_db.book = nil;
-- the empty book template.
EBook_db.empty_book = {
	book_path = nil, -- such as "EBooks/MyBook/"
	book_file = nil, -- such as "EBooks/MyBook/MyBook.book.lua"
	media_path = nil, -- such as "EBooks/MyBook/media/"
	worlds_path = nil, -- such as "EBooks/MyBook/worlds/"
	author = "LiXizhi",
	createtime = "2007-4-12",
	bookname = L"an empty book",
	style = L"standard", -- book style, such  as layout, etc
	abstract = nil, -- abstract of the book, usually less than 50 words.
	readonly = false, -- whether read only
	currentpage = 1, -- index of the current page
	pagesCount = 0;
	UnusedPageID = 1; -- the next unused page ID, increased by one for each new page created.
	-- the actual page is in array at [1], [2], etc. template pages are in key, value pairs.
	pages  = {
		PageTempate_empty = {
			pageid = 1, -- usually same as the page index, unless we support insert pages in future.
			pagetitle = "untitled",
			pagetext = "enter your text here",
			pagestyle = "empty", -- appearance of the page
			mediafile = nil, -- the media file associated with the page
			mediascale = 1,
			-- the world file path associated with the page, usually book.worlds_path.."w"..pageid
			-- sometimes, it can also be an URL beginning with http
			worldpath = nil, 
			autosave_world = false, -- whether the world info such as player position associated with the page is automatically saved.
			PlayerName = nil, 
			PlayerPos = nil, -- such as {100,0 200}
			PlayerModel = nil, -- main player model file
			ClipFile = nil, -- the clip file in the world to play.
			voice_file = nil, -- the voice file path, usually book.media_path..pageid.."_voice.wav"
			music_file = nil, -- the music file path, usually 
		}
	},
	-- this table is not serialized.
	edit_att = {
		is_modified = false,
	}
};

function EBook_db.GetCurrentBook()
	return EBook_db.book;
end

-- @param bookpath: such as EBooks/MyBook
-- @param book: which book to set. 
function EBook_db.SetBookPath(bookpath, book)
	-- use current book if nil.
	if(book == nil) then
		book = EBook_db.book
	end
	book.book_path = bookpath.."/";
	book.book_file = book.book_path..ParaIO.GetFileName(bookpath)..".book.lua";
	book.media_path = book.book_path.."media/";
	book.worlds_path = book.book_path.."worlds/";
end

-- create a new page at the end f the book.
-- @param page: this can be nil, a partial page, etc.
-- @param nInsertAfter: the page index after which the new page is added. it can be nil, which means the end of page. 
-- @return: return true or an error message.
function EBook_db.NewPage(page, nInsertAfter)
	if(EBook_db.MaxBookPages <=EBook_db.book.pagesCount) then
		return string.format(L"In this edition, you can only create books with no more than %d pages.", EBook_db.MaxBookPages);
	end
	page = page or {}   -- create object if user does not provide one
		
	-- set page id
	page.pageid = EBook_db.book.UnusedPageID;
	-- always enable auto save world.
	page.autosave_world = false;
	-- set page scale
	page.mediascale = 1;
	-- generate the next unused page ID
	EBook_db.book.UnusedPageID = EBook_db.book.UnusedPageID+1;
	-- insert the page to the book.
	return EBook_db.InsertPage(page, nInsertAfter);
end

-- insert a page
-- @param page: page to be added
-- @param nInsertAfter: the page index after which the new page is added. it can be nil, which means the end of page. 
function EBook_db.InsertPage(page, nInsertAfter)
	if(nInsertAfter == nil or nInsertAfter>=EBook_db.book.pagesCount) then
		-- increase page count
		EBook_db.book.pagesCount = EBook_db.book.pagesCount + 1;
		-- add the page
		EBook_db.book.pages[EBook_db.book.pagesCount] = page;
	else
		-- insert a page in the middle.
		if(nInsertAfter<=1)	then
			nInsertAfter = 1;
		end
		local i;
		for i=EBook_db.book.pagesCount, nInsertAfter+1, -1 do
			EBook_db.book.pages[i+1] = EBook_db.book.pages[i];
		end
		-- increase page count
		EBook_db.book.pagesCount = EBook_db.book.pagesCount + 1;
		-- add the page
		EBook_db.book.pages[nInsertAfter+1] = page;
	end
	return true;
end

-- remove a page at a given index
-- return true if succeed, or nil if can not remove the only left page
function EBook_db.RemovePage(nPageIndex)
	if(nPageIndex>=1 or nPageIndex<=EBook_db.book.pagesCount) then
		-- can not remove the only left page
		if(EBook_db.book.pagesCount == 1) then
			return
		end
		-- remove the page
		local i;
		for i=nPageIndex, EBook_db.book.pagesCount do
			EBook_db.book.pages[i] = EBook_db.book.pages[i+1];
		end
		-- decrease page count
		EBook_db.book.pages[EBook_db.book.pagesCount] = nil;
		EBook_db.book.pagesCount = EBook_db.book.pagesCount-1;
		-- if the current page is out of range, adjust it. 
		if(EBook_db.book.currentpage>EBook_db.book.pagesCount) then
			EBook_db.book.currentpage = EBook_db.book.pagesCount;
		end
		return true;
	end
end

-- create a new book by name at default library_path. 
-- One needs to fill the author info etc, in the current book at a later time. And Call the SaveCurrentEBook() function to write the new book to file.
-- error message is returned in the false parameter. or true if succeed.
function EBook_db.NewBook(bookName)
	-- try to make bookName a valid file name. 
	bookName = string.gsub(bookName, "(%S+)", "%1");
	if(bookName == nil or bookName=="") then
		return L"Please enter a valid book name with letters only.";
	end
	local bookpath = EBook_db.library_path..bookName;
	
	-- make sure we can create directory and files.
	ParaIO.CreateDirectory(bookpath.."/log.txt");
	ParaIO.CreateDirectory(bookpath.."/media/");
	ParaIO.CreateDirectory(bookpath.."/worlds/");
	local logfile = bookpath.."/log.txt";
	local file = ParaIO.open(logfile, "w");
	if(file:IsValid()) then
		file:close();
	else
		return L"Unable to create the book, perhaps you do not have access right to the disk directory.";
	end
	
	-- create a new book. 
	local book = {
		author = "",
		createtime = ParaGlobal.GetDateFormat(nil),
		bookname = bookName,
		style = L"standard", -- book style, such  as layout, etc
		readonly = false, -- whether read only
		pagesCount = 0,
		currentpage = 1,
		UnusedPageID = 1, -- the next unused page ID, increased by one for each new page created.
		pages = {},
		edit_att = {
			is_modified = true,
		}
	}
	-- set book path
	EBook_db.SetBookPath(bookpath, book);
	
	if(ParaIO.DoesFileExist(book.book_file, true)) then
		return L"book already exist, please use a different book name."
	end
	-- set the current book
	EBook_db.book = book;

	return true;
end

-- @param bookname: this is just the book directory name or the zip file name. like "MyBook".
-- @param true or error message
function EBook_db.LoadEBookByName(bookname)
	if(string.find(bookname, ".*%.zip$")~=nil) then
		-- if it is a zip file 
		local bookzipfile = EBook_db.library_path..bookname;
		if(bookzipfile~=EBook_db.LastZipBookFile) then
			if(EBook_db.LastZipBookFile~=nil) then
				ParaAsset.CloseArchive(EBook_db.LastZipBookFile);
			end
			-- open zip archive with relative path
			ParaAsset.OpenArchive(bookzipfile, true);
			EBook_db.LastZipBookFile = bookzipfile;
		end	
		
		local search_result = ParaIO.SearchFiles("","*.", bookzipfile, 0, 10, 0);
		local nCount = search_result:GetNumOfResult();
		if(nCount>0) then
			-- just use the first directory in the world zip file as the world name.
			local Name = search_result:GetItem(0);
			Name = string.gsub(Name, "[/\\]$", "");
			bookname = string.gsub(bookname, "(.*)%.zip$", Name); -- get rid of the zip file extension for display 
		else
			-- make it the directory path
			bookname = string.gsub(bookname, "(.*)%.zip$", "%1"); -- get rid of the zip file extension for display 		
		end
		
		if(bookname == nil) then
			return L"invalid zip file"
		end
	end	
	
	local bookfile = EBook_db.library_path..bookname.."/"..bookname..".book.lua";
	return EBook_db.LoadEBookFromFile(bookfile)
end

-- @param filename: load EBook by book file, such as "EBooks/MyBook/MyBook.book.lua"
function EBook_db.LoadEBookFromFile(filename)
	-- just reload and execute the file
	if(filename==nil) then
		filename = "temp/ebook_temp.lua"
	end
	EBook_db.tempbook = nil;
	
	-- TODO: valid pure data for security, since filename is not trusted.
	NPL.load("(gl)"..filename, true);
	log("opened book "..filename.."\r\n");
	
	if(EBook_db.tempbook~=nil) then
		EBook_db.book = EBook_db.tempbook;
		EBook_db.book.currentpage = 1;
		EBook_db.tempbook = nil;
		return true;
	else
		return L"invalid book file"
	end
end

--[[ save current ebook to file 
EBook_db.SaveAssetToFile("temp/ebook_temp.lua");
]]
function EBook_db.SaveCurrentEBook()
	local filename = EBook_db.book.book_file;
	
	if(EBook_db.book.readonly) then
		return L"This book is read only. It can not be saved."
	end
	-- make sure the directory exist
	ParaIO.CreateDirectory(filename);
	
	-- save to file
	local file = ParaIO.open(filename, "w");
	if(file:IsValid()) then
		log("printing EBook_db to "..filename.."\r\n")
		file:WriteString("--[[\r\n");
		file:WriteString("--Auto generated by ParaEngine's EBook_db.SaveCurrentEBook() method. \r\nDo not edit this file yourself.\r\n");
		file:WriteString("]]\r\n");
		
		file:WriteString("EBook_db.tempbook = \r\n");
		commonlib.serializeToFile(file, EBook_db.book);
		file:close();
		return true;
	else
		return L"Failed saving file to "..filename.."\r\n";
	end
end

-- return the current page or nil.
function EBook_db.GetCurrentPage()
	if(EBook_db.book.currentpage== nil) then EBook_db.book.currentpage=1 end
	if(EBook_db.book.currentpage>=1 and EBook_db.book.currentpage<=EBook_db.book.pagesCount) then
		return EBook_db.book.pages[EBook_db.book.currentpage];
	else
		-- if invalid page, set the current page to the first page
		EBook_db.book.currentpage = 1;
		return EBook_db.book.pages[EBook_db.book.currentpage];
	end
end

-- return true or nil
function EBook_db.GotoPage(nPageNumber)
	if(EBook_db.book.currentpage== nil) then EBook_db.book.currentpage=1 end
	if(EBook_db.book.currentpage>=1 and EBook_db.book.currentpage<=EBook_db.book.pagesCount) then
		EBook_db.book.currentpage = nPageNumber;
		return true;
	end
end

-- save everything (world name, player position, movie clips, etc) in the current 3d world 
-- to the associated world info of the current page. 
function EBook_db.AutoSavePageWorld()
	if(EBook_db.book.readonly) then
		return L"This book is read only. Page save is ignored."
	end
	local page = EBook_db.GetCurrentPage();
	if(not page) then return end
	
	-- automatically save world
	if(page.autosave_world) then
		EBook_db.SavePageWorld();
	end	
end

-- get the screen shot file path of this page
function EBook_db.GetPageScreenShotPath()
	local page = EBook_db.GetCurrentPage();
	if(not page) then return end
	return string.format("%sSnapShot%d.jpg", EBook_db.book.media_path, page.pageid);
end

-- just save the page world, even if autosave is not enabled.
-- however, if the book is read-only, it is not saved.
function EBook_db.SavePageWorld()
	if(EBook_db.book.readonly) then
		return
	end
	
	local page = EBook_db.GetCurrentPage();
	if(not page) then return end
	page.worldpath = Map3DSystem.World.name;
	log(tostring(page.worldpath).." book page world saved\r\n")
	
	local player = ParaScene.GetPlayer();
	if(player:IsValid()) then
		local char = player:ToCharacter();
		local x,y,z = player:GetPosition();
		if(not page.PlayerPos) then page.PlayerPos = {} end
		page.PlayerPos[1] = x;
		page.PlayerPos[2] = y;
		page.PlayerPos[3] = z;
		page.PlayerModel =  player:GetPrimaryAsset():GetKeyName();
		page.PlayerName = player.name;
		-- take a snapshot for this page
		local snapshot = EBook_db.GetPageScreenShotPath();
		if(snapshot~=nil) then
			ParaMovie.TakeScreenShot(snapshot, 640, 480);
			ParaAsset.LoadTexture("",snapshot,1):UnloadAsset();
			page.mediafile = snapshot;
		end	
		return true;
	end
end
-- this function is called immediately after the book world is loaded. 
-- it will reset the world's player and movie clip according to the current book page. 
function EBook_db.AutoLoadPageWorld()
	local page = EBook_db.GetCurrentPage();
	if(not page) then return end
	
	--log(tostring(page.worldpath).." book page world loaded\r\n")
	
	local PlayerAsset;
	if(not page.PlayerModel) then
		PlayerAsset = CommonCtrl.Locale("IDE")("asset_defaultPlayerModel");
	else
		PlayerAsset = page.PlayerModel;
	end	
	 
	local player;
	if(page.PlayerName ~= nil) then
		-- ensure there is a player with the given name
		player = ParaScene.GetObject(page.PlayerName);
		if(player:IsValid() == false) then
			-- try use the main player
			player = ParaScene.GetObject(Map3DSystem.Player.name);
			if(player:IsValid() == false) then
				-- if there is no player with the given name, create the player
				local asset = ParaAsset.LoadParaX("", PlayerAsset);
				player = ParaScene.CreateCharacter(page.PlayerName, asset, "", true, 0.35, 3.9, 1.0);	
			end
		end
		-- ensure it has the camera focus
		local playerChar = player:ToCharacter();
		playerChar:SetFocus();
		ParaCamera.FirstPerson(0, 5,0.4);
		
		-- ensure the player has the same model asset
		if(PlayerAsset ~=  player:GetPrimaryAsset():GetKeyName()) then
			local asset = ParaAsset.LoadParaX("", PlayerAsset);
			playerChar:ResetBaseModel(asset);
		end
		
		-- ensure it is at the given location
		if(page.PlayerPos~=nil) then
			player:SetPosition(page.PlayerPos[1], page.PlayerPos[2], page.PlayerPos[3]);
		end	
		
		-- TODO: load the movie clip
	end
	
end

-- submit the current EBook via webservice
-- TODO: we should move the many UI related _guihelper.MessageBox(), etc to EBook_MainMenu.OnClickPublish_UploadToWeb. 
--  for simplicity, I just mixed UI and BLLogic in EBook_db class.
function EBook_db.SubmitEBook()
	if(EBook_db.book.readonly) then	
		_guihelper.MessageBox(L"This book is read-only. You can only publish a book which is editable.");
		return;
	end
	if(not Map3DSystem.User.IsAuthenticated) then
		_guihelper.MessageBox(L"In order to upload your work, you need to login to our community web site", function ()
			NPL.load("(gl)script/network/LoginBox.lua");
			LoginBox.Show(true, EBook_db.SubmitEBook_imp);
		end)
	else
		EBook_db.SubmitEBook_imp();
	end	
end

function EBook_db.SubmitEBook_imp(callbackScript)
	if(not EBook_db.IsUploadFinished) then
		_guihelper.MessageBox(L"Please wait until the last transmission is finished.");
		return;
	end 
	
	EBook_db.callbackScript = callbackScript;
	
	local msg = {
		username = Map3DSystem.User.Name,
		password = Map3DSystem.User.Password,
		category = EBook_db.DefaultCategoryID,
		book = {
			bookname = EBook_db.book.bookname,
			author = EBook_db.book.author,
			createtime = EBook_db.book.createtime,
			style = EBook_db.book.style,
			pagesCount = EBook_db.book.pagesCount,
			pages = {},
		},
	};
	EBook_db.msg = msg;
	local i;
	for i=1, EBook_db.book.pagesCount do
		local page = EBook_db.book.pages[i];
		msg.book.pages[i] = {
			pagetitle = page.pagetitle,
			pagetext = page.pagetext,
			pagestyle = page.pagestyle,
			mediafile = page.mediafile, -- the media file associated with the page
		}
	end
	
	_guihelper.MessageBox(L"Uploading ebook, please wait patiently...\n");
	
	-- continue with stage 1.
	EBook_db.SubmitEBook_UploadPageMedia(1);
end

function EBook_db.SubmitEBook_UploadPageMedia(step)
	
	EBook_db.IsUploadFinished = true; 
	--EBook_db.msg.book.pagesCount
	local snapshot = EBook_db.msg.book.pages[step].mediafile;
	local ext = "";
	if(snapshot ~= nil ) then
		ext = ParaIO.GetFileExtension(snapshot);
	end
	if( ext== "jpg") then
		local file = ParaIO.open(snapshot, "r");
		if(file:IsValid()) then
			local msg = {
				username = Map3DSystem.User.Name,
				password = Map3DSystem.User.Password,
				ImgIn = file,
				Filename = "ebook_"..EBook_db.msg.book.bookname.."_"..step..".jpg",
				Overwrite = true,
			}
			NPL.RegisterWSCallBack(EBook_db.webservice_UploadUserFile, string.format("EBook_db.UploadUserFile_Callback(%d);", step));
			NPL.activate(EBook_db.webservice_UploadUserFile, msg);
			EBook_db.IsUploadFinished = false; 
			file:close();
		else
			_guihelper.MessageBox(L"Unable to upload your work, your local file does not exist".."\n");
		end	
	else
		_guihelper.MessageBox(string.format(L"Your current account can not upload 3D EBook with page media extension %s\n", ext));
		msg = {
			fileURL = "", --"http://www.kids3dmovie.com/cn/images/noimage.gif",
		}
		EBook_db.UploadUserFile_Callback(step);
	end	
end

function EBook_db.UploadUserFile_Callback(step)
	EBook_db.IsUploadFinished = true; 
	if(msg~=nil and msg.fileURL~=nil) then
		if(true) then
			_guihelper.MessageBox(string.format(L"Successfully uploaded page %d: %s\n\n", step, tostring(msg.fileURL)));
			-- save media URL.
			EBook_db.msg.book.pages[step].mediafile = msg.fileURL;
			
			-- submit ebook if it is the last step
			if(step == EBook_db.msg.book.pagesCount) then
				NPL.RegisterWSCallBack(EBook_db.webservice_SubmitEBook, "EBook_db.SubmitEBook_Callback();");
				NPL.activate(EBook_db.webservice_SubmitEBook, EBook_db.msg);
				EBook_db.IsUploadFinished = false; 
			elseif(step < EBook_db.msg.book.pagesCount) then
				EBook_db.SubmitEBook_UploadPageMedia(step+1);
			end
		else
			_guihelper.MessageBox(L"Unable to upload your work\n"..msg.fileURL.."\n");
		end	
	elseif(msg==nil) then
		_guihelper.MessageBox(L"Network is not available, please try again later".."\n");
	else
		_guihelper.MessageBox(L"We are unable to upload your work to the community website\n");
	end	
end
		
function EBook_db.SubmitEBook_Callback()
	EBook_db.IsUploadFinished = true; 
	if(msg~=nil and msg.id~=nil and  msg.id>0 and msg.articleURL~=nil) then
		EBook_db.articleURL = msg.articleURL;
		
		-- TODO: move this to UI layer.
		_guihelper.MessageBox(string.format(L"Work successfully uploaded:\nURL is %s\nDo you want to view it in a web browser?\n\n", msg.articleURL), function ()
			ParaGlobal.ShellExecute("open", "iexplore.exe", EBook_db.articleURL, nil, 1); 
		end);
		-- TODO: call callbackScript() with msg.articleURL;
	else
		_guihelper.MessageBox(L"Unable to upload your work\n"..tostring(msgerror).."\n");
	end	
end

-- save the entire book as the zip file
function EBook_db.SaveAsZipFile()
	if(EBook_db.book.readonly) then	
		_guihelper.MessageBox(L"This book is read-only. You can only publish a book which is editable.");
		return;
	end	
	
	local zipfile = string.gsub(EBook_db.book.book_path, "(.*)/$", "%1.zip");
	if(zipfile~=nil) then
		if(not ParaIO.DoesFileExist(zipfile)) then
			EBook_db.SaveZipFile(zipfile);
		else
			-- TODO
			_guihelper.MessageBox(string.format(L"The EBook file %s already exists. Do you want to overwrite it?", zipfile),  
				string.format("EBook_db.SaveZipFile(%q)", zipfile));
		end	
	end	
end

-- save and overwrite without asking any question
function EBook_db.SaveZipFile(zipfile)
	local writer = ParaIO.CreateZip(zipfile,"");
	writer:AddDirectory(EBook_db.book.bookname, EBook_db.book.book_path.."*.*", 6);
	writer:close();	
	_guihelper.MessageBox(string.format(L"The EBook %s is successfully generated and ready for publication. Do you want to open its folder with windows explorer?", zipfile),  function ()
		local absPath = string.gsub(ParaIO.GetCurDirectory(0)..zipfile, "/", "\\");
		if(absPath~=nil) then
			ParaGlobal.ShellExecute("open", "explorer.exe", absPath, nil, 1); 
		end	
	end);
end