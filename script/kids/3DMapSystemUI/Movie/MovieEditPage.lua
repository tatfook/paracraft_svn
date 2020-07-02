--[[
Title: code behind page for MovieEditPage.html
Author(s): LiXizhi
Date: 2008/8/19
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieEditPage.lua");
-------------------------------------------------------
]]

local MovieEditPage = {
	MovieManager = nil,
	moviescript = nil,
	moviescript_path = nil,
	MovieAssetsManager = nil,
	page = nil,
};
commonlib.setfield("Map3DSystem.Movie.MovieEditPage", MovieEditPage)
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieManager.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MoviePlayerPage.lua");
---------------------------------
-- page event handlers
---------------------------------

-- load default values.
function MovieEditPage.OnInit()
	local page = document:GetPageCtrl();
	MovieEditPage.page = page;
	local moviescript_path = MovieEditPage.moviescript_path;
	if(moviescript_path)then
		if(not MovieEditPage.MovieManager)then
			MovieEditPage.MovieManager = Map3DSystem.Movie.MovieManager:new();
			-- record a MovieManager which is a global object
			Map3DSystem.Movie.MovieListPage.SelectedMovieManager = MovieEditPage.MovieManager;
		end
	
		NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieScript.lua");
		MovieEditPage.moviescript = Map3DSystem.Movie.MovieScriptManager.GetScript(moviescript_path,true)
		
		if(not MovieEditPage.MovieAssetsManager)then
			MovieEditPage.MovieAssetsManager = Map3DSystem.Movie.AssetsManager:new();
			-- record a MovieAssetsManager which is a global object
			Map3DSystem.Movie.MovieListPage.SelectedMovieManager.MovieAssetsManager = MovieEditPage.MovieAssetsManager;
		end
		local moviescript = MovieEditPage.moviescript;
		MovieEditPage.viewInfos = {
				["pe:movie-clip"] = { nodes = moviescript.clipsNode,
					rootNode = CommonCtrl.TreeNode:new({Text = "胶片", Type = "pe:movie-clip",  Expanded = true,}),},
				["pe:movie-camera"] = { nodes = moviescript.camerasNode,
					rootNode = CommonCtrl.TreeNode:new({Text = "摄像机", Type = "pe:movie-camera",  Expanded = true, }),},
				["pe:movie-sky"] = {nodes = moviescript.skysNode,
					rootNode = CommonCtrl.TreeNode:new({Text = "天空", Type = "pe:movie-sky",  Expanded = true, }),},	
				["pe:movie-land"] = {nodes = moviescript.landsNode,
					rootNode = CommonCtrl.TreeNode:new({Text = "陆地", Type = "pe:movie-land",  Expanded = true, }),},	
				["pe:movie-ocean"] = {nodes = moviescript.oceansNode,
					rootNode = CommonCtrl.TreeNode:new({Text = "海洋", Type = "pe:movie-ocean",  Expanded = true, }),},	
				["pe:movie-caption"] = {nodes = moviescript.captionsNode,
					rootNode = CommonCtrl.TreeNode:new({Text = "字幕", Type = "pe:movie-caption",  Expanded = true, }),},	
				["pe:movie-actor"] = {nodes = moviescript.actorsNode,
					rootNode = CommonCtrl.TreeNode:new({Text = "人物", Type = "pe:movie-actor",  Expanded = true, }),},	
				["pe:movie-building"] = {nodes = moviescript.buildingsNode,
					rootNode = CommonCtrl.TreeNode:new({Text = "建筑", Type = "pe:movie-building",  Expanded = true, }),},	
				["pe:movie-plant"] = {nodes = moviescript.plantsNode,
					rootNode = CommonCtrl.TreeNode:new({Text = "植物", Type = "pe:movie-plant",  Expanded = true, }),},	
				["pe:movie-effect"] = {nodes = moviescript.effectsNode,
					rootNode = CommonCtrl.TreeNode:new({Text = "特效", Type = "pe:movie-effect",  Expanded = true, }),},	
				["pe:movie-sound"] = {nodes = moviescript.soundsNode,
					rootNode = CommonCtrl.TreeNode:new({Text = "声音", Type = "pe:movie-sound",  Expanded = true, }),},	
				["pe:movie-control"] = {nodes = moviescript.controlsNode,
					rootNode = CommonCtrl.TreeNode:new({Text = "控件", Type = "pe:movie-control",  Expanded = true, }),},
				
			}
			
		MovieEditPage.selectedModel = MovieEditPage.viewInfos["pe:movie-clip"];	
			
	
	end	
end
function MovieEditPage.Clear()
	MovieEditPage.OnClickClose(true);
	MovieEditPage.MovieManager = nil;
	MovieEditPage.moviescript = nil;
	MovieEditPage.moviescript_path = nil;
	MovieEditPage.MovieAssetsManager = nil;
	MovieEditPage.page = nil;
	
end
function MovieEditPage.ShowAssetView(type)
	if(not type)then return; end
	MovieEditPage.selectedModel = MovieEditPage.viewInfos[type];
	local rootNode = MovieEditPage.selectedModel["rootNode"];
	rootNode:ClearAllChildren();
	MovieEditPage.UpdateMovieAssets();
end
function MovieEditPage.ShowMovieView(params) 
	local moviescript = MovieEditPage.moviescript;
	local MovieManager = MovieEditPage.MovieManager
	if(moviescript and MovieManager)then
		local _this = ParaUI.GetUIObject("container"..MovieManager.name);
		if(not _this:IsValid()) then
			_this = ParaUI.CreateUIObject("container", "container"..MovieManager.name, params.alignment, params.left, params.top, params.width, params.height);
			params.parent:AddChild(_this);
			MovieManager:CreateViewWnd(_this);	
			MovieEditPage.UpdateMovie();	
		end	
	end
	
end
function MovieEditPage.ShowMovieAssetsView(params) 
	local moviescript = MovieEditPage.moviescript;
	local MovieAssetsManager = MovieEditPage.MovieAssetsManager
	if(moviescript and MovieAssetsManager)then
		local _this = ParaUI.GetUIObject("container"..MovieAssetsManager.name);
		if(not _this:IsValid()) then
			_this = ParaUI.CreateUIObject("container", "container"..MovieAssetsManager.name, params.alignment, params.left, params.top, params.width, params.height);
			params.parent:AddChild(_this);
			MovieAssetsManager:CreateViewWnd(_this);	
			MovieEditPage.UpdateMovieAssets();	
		end	
	end
	
end
function MovieEditPage.UpdateMovie()
	local moviescript = MovieEditPage.moviescript;
	local MovieManager = MovieEditPage.MovieManager
	if(moviescript and MovieManager)then
		MovieManager:DataBind(moviescript);
	end
end
function MovieEditPage.UpdateMovieAssets()
	local moviescript = MovieEditPage.moviescript;
	local MovieAssetsManager = MovieEditPage.MovieAssetsManager
	if(moviescript and MovieAssetsManager)then
		local selectedModel = MovieEditPage.selectedModel;
		MovieAssetsManager:DataBind(moviescript,selectedModel);
	end
end
function MovieEditPage.ShowMoviePage(moviescript_path)
	if(not moviescript_path)then return; end
	MovieEditPage.Clear();
	MovieEditPage.moviescript_path = moviescript_path;
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
		url="script/kids/3DMapSystemUI/Movie/MovieEditPage.html", name="MovieEditPage_editMovie", 
		app_key=MyCompany.Apps.VideoRecorder.app.app_key, 
		text = "编辑电影",
		isShowTitleBar = true, 
		isShowToolboxBar = false, 
		isShowStatusBar = false, 
		isShowMinimizeBox = false,
		allowResize = false,
		initialPosX = (screenWidth-800)/2,
		initialPosY = (screenHeight-560)/2,
		initialWidth = 800,
		initialHeight = 560,
		bToggleShowHide = false,
		bShow = true,
		--DestroyOnClose = true,
	});
	NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieClipEditor_Page.lua");
	Map3DSystem.Movie.MovieClipEditor_Page.Close()
end
function MovieEditPage.ReShow()
	if(not MovieEditPage.MovieManager)then return; end
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
	name="MovieEditPage_editMovie", 
		app_key=MyCompany.Apps.VideoRecorder.app.app_key, 	
		bShow = true,
	});
	NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieClipEditor_Page.lua");
	Map3DSystem.Movie.MovieClipEditor_Page.Close()
end
function MovieEditPage.OnClickClose(bDestroy)
	if(not MovieEditPage.MovieManager)then return; end
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="MovieEditPage_editMovie", 
		app_key=MyCompany.Apps.VideoRecorder.app.app_key, 
		bShow = false,bDestroy  = bDestroy});
end
function MovieEditPage.Save()
	if(not MovieEditPage.moviescript)then return; end
	local moviescript  = MovieEditPage.moviescript;
	moviescript:SaveAs(moviescript.filename);
end
function MovieEditPage.SaveAs()
	if(not MovieEditPage.moviescript)then return; end
	local moviescript  = MovieEditPage.moviescript;
	--moviescript:SaveAs("test_1.xml");
	MovieEditPage.OnSaveAs()
end
function MovieEditPage.OutPut()
	if(not MovieEditPage.moviescript)then return; end
	local moviescript  = MovieEditPage.moviescript;
	moviescript:OutPut("test_2.xml");
end
function MovieEditPage.Preview()
	if(not MovieEditPage.moviescript)then return; end
	local moviescript  = MovieEditPage.moviescript;
	 MovieEditPage.DoPreview(moviescript)
end
function MovieEditPage.DoPreview(moviescript)
	if(not moviescript)then return; end
	Map3DSystem.Movie.MoviePlayerPage.DoOpenWindow()
	local root_clip = moviescript:GetPlayMovieClips();
	Map3DSystem.Movie.MoviePlayerPage.DataBind(root_clip)
	MovieEditPage.OnClickClose()
end

function MovieEditPage.OnSaveAs(himself)
	if(not MovieEditPage.moviescript)then return; end
	local moviescript  = MovieEditPage.moviescript;
	NPL.load("(gl)script/ide/OpenFileDialog.lua");
	local _fileName;
	if(himself)then
		_fileName = moviescript.filename;
	else
		_fileName = string.gsub(moviescript.filename, "([^/\\]+)(%.xml)$", "%1_copy%2");
	end
	local folderPath = ParaWorld.GetWorldDirectory().."movies";
	local ctl = CommonCtrl.OpenFileDialog:new{
		name = "OpenFileDialog1",
		alignment = "_ct",
		left=-256, top=-150,
		width = 512,
		height = 380,
		parent = nil,
		CheckFileExists = false,
		FileName = _fileName,
		fileextensions = {"xml files(*.xml)",},
		folderlinks = {
			{path = folderPath, text = "我的电影"},
		},
		onopen = function(name, filepath)
			if(ParaIO.DoesFileExist(filepath)) then	
				_guihelper.MessageBox(string.format("%s文件已经存在, 确定要覆盖它？", filepath),
				function ()
					moviescript:SaveAs(filepath);
					MovieEditPage.ReOpen(filepath)
				end
				);
				return
			end
			moviescript:SaveAs(filepath);
			MovieEditPage.ReOpen(filepath)
		end
	};
	ctl:Show(true);
end
function MovieEditPage.ReOpen(filename)
	MovieEditPage.OnClickClose(true)
	Map3DSystem.Movie.MovieListPage.OnClickEditMovie(filename)
end
function MovieEditPage.SetMovieInfo()
	if(not MovieEditPage.moviescript)then return; end
	local moviescript  = MovieEditPage.moviescript;
	local name = "测试电影名称"
	moviescript:SetMovieName(name);
	MovieEditPage.page:SetNodeValue("fileName_label",name);
end
-------------------------------------------------------------------------------
-- get the movie list
function MovieEditPage.MovieAssets_GetMovieList()
	local MovieAssetsManager = MovieEditPage.MovieAssetsManager;
	if(not MovieAssetsManager)then return; end
	return MovieAssetsManager:GetMovieList();
end

-- load default values.
function MovieEditPage.MovieAssets_OnInit()
	local self = document:GetPageCtrl();
	-- get current movie list. 
	local movielist = MovieEditPage.MovieAssets_GetMovieList()
	if(movielist) then
		local _, movie
		for _, movie in ipairs(movielist) do
			self:CallMethod("CurMovie", "AddNameValue", movie.filename, movie.Title);
		end
		
	end	
end
function MovieEditPage.SelectedDefaultPath()
	local self = document:GetPageCtrl();
	-- select the default movie
	local path = Map3DSystem.Movie.MovieEditPage.moviescript_path;
	if(not path)then
			path = "";
	end
	self:SetNodeValue("CurMovie",path);
	local Title = string.match(path, "([^/\\]+)%.xml$") or path
	self:SetUIValue("CurMovie",Title);
	-- update the current selection
	--MovieEditPage.MovieAssets_OnSelectMovie("clips", self:GetNodeValue("CurMovie"));
end

