--[[
Title: code behind page for MovieListPage.html
Author(s): LiXizhi
Date: 2008/8/19
Desc: It displays a list of movies that are associated with the current world. 
all movie scripts are stored at world_dir/movies/*.xml files. 

One can get a movie list programmatically, by calling 
<verbatim>
	local movielist = Map3DSystem.Movie.MovieListPage.GetMovieList();
</verbatim>

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieListPage.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MoviePlayerPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieScript.lua");
NPL.load("(gl)script/ide/Animation/Motion/PreLoader.lua");
local MovieListPage = {};
commonlib.setfield("Map3DSystem.Movie.MovieListPage", MovieListPage)
Map3DSystem.Movie.MovieListPage.SelectedMovieManager = nil;
-- requires the movie manager. 
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieManager.lua");
local MovieManager = Map3DSystem.Movie.MovieManager;

---------------------------------
-- page event handlers
---------------------------------
-- singleton page object
local page;

-- template db table
MovieListPage.dsMovies = nil;

-- datasource function for pe:gridview
function MovieListPage.DS_Func(index)
	if(index == nil) then
		return #(MovieListPage.dsMovies);
	else
		return MovieListPage.dsMovies[index];
	end
end

-- only return the sub folders of the current folder
-- @param rootfolder: the folder which will be searched.
-- @param nMaxFilesNum: one can limit the total number of files in the search result. Default value is 50. the search will stop at this value even there are more matching files.
-- @param filter: if nil, it defaults to "*."
-- @return a table array containing relative to rootfolder file name.
function MovieListPage.SearchFiles(output, rootfolder,nMaxFilesNum, filter)
	if(rootfolder == nil) then return; end
	if(filter == nil) then filter = "*." end
	
	output = output or {};
	local sInitDir = ParaIO.GetCurDirectory(0)..rootfolder.."/";
	local search_result = ParaIO.SearchFiles(sInitDir,filter, "", 0, nMaxFilesNum or 50, 0);
		local nCount = search_result:GetNumOfResult();		
		local nextIndex = #output+1;
		local i;
		for i = 0, nCount-1 do 
			output[nextIndex] = search_result:GetItemData(i, {});
			nextIndex = nextIndex + 1;
		end
		search_result:Release();
	return output;	
end

-- add a given movie script to datasource
function MovieListPage.AddMovieScriptToDS(movieInfo)
	if(not movieInfo.filename) then return end
	if(not movieInfo.Title) then
		movieInfo.Title = string.match(movieInfo.filename, "([^/\\]+)%.xml$") or movieInfo.filename
	end
	table.insert(MovieListPage.dsMovies, movieInfo);
end

--@param bForceRefresh: if true, it will refresh the movie list. 
--@return: return an array of {filename, Title, writedate, }
function MovieListPage.GetMovieList(bForceRefresh)
	if(not MovieListPage.dsMovies or bForceRefresh) then
		-- get all contents in worldsfolder/movies folder. 
		local folderPath = ParaWorld.GetWorldDirectory().."movies";
		
		-- clear ds
		MovieListPage.dsMovies = {};
		
		-- add files
		MovieListPage.filter = "*.xml";
		if(MovieListPage.filter~=nil and MovieListPage.filter~="")then
			-- add files, but exclude folders. 
			local filter;
			local output = {};
			for filter in string.gfind(MovieListPage.filter, "([^%s;]+)") do
				MovieListPage.SearchFiles(output, folderPath,MovieListPage.MaxItemPerFolder, filter);
			end
			if(#output>0) then
				local _, item;
				for _, item in ipairs(output) do
					if(string.find(item.filename,"%.")) then
						-- we will skip folders since they are already added.
						MovieListPage.AddMovieScriptToDS({filename = folderPath.."/"..item.filename, 
							writedate = item.writedate, filesize=item.filesize})
					end	
				end
			end
		end
		
		-- REMOVE THIS LINE: add and show the test movie script.
		--MovieListPage.AddMovieScriptToDS({filename = "script/kids/3DMapSystemUI/Movie/test/test_moviescript.xml", })
	end	
	return MovieListPage.dsMovies
end	
function MovieListPage.OnClickLogout()
	Map3DSystem.App.Commands.Call("File.Logout");
end
-- load default values.
function MovieListPage.OnInit()
	page = document:GetPageCtrl();
	MovieListPage.page = page;
	-- get movie list
	MovieListPage.GetMovieList(true);
end

-- close the movie list page
function MovieListPage.OnClickClose()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="MovieListPage", 
		app_key=MyCompany.Apps.VideoRecorder.app.app_key, 
		bShow = false,bDestroy = true,});
end

-- create a new movie, display create new movie dialog
function MovieListPage.OnClickNewMovie()
	MovieListPage.OnClickClose();
	local templateFile = "script/kids/3DMapSystemUI/Movie/test/empty_moviescript.xml"
	local name =  ParaGlobal.GenerateUniqueID();
	local newFile = ParaWorld.GetWorldDirectory().."movies/Movie"..name..".xml";
	
	if(ParaIO.CopyFile(templateFile, newFile, true))then
		MovieListPage.AddMovieScriptToDS({filename = newFile, })
		Map3DSystem.Movie.MovieEditPage.ShowMoviePage(newFile)
	end
	-- TODO: create in-memory movie script 
	-- TODO: display MovieEditPage.html 
end

-- @param filename: play the movie script. 
function MovieListPage.OnClickPlayMovie(filename)
	if(not filename)then return; end
	Map3DSystem.App.Commands.Call("File.PlayMovieScript", filename);
	MovieListPage.OnClickClose()
end

-- @param filename: edit the movie script. 
function MovieListPage.OnClickEditMovie(filename)
	if(not filename)then return; end
	MovieListPage.OnClickClose();
	NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieEditPage.lua");
	local moviescript = Map3DSystem.Movie.MovieScriptManager.GetScript(filename)
	if(moviescript)then
		CommonCtrl.Animation.Motion.PreLoader.DataBind(moviescript)
		CommonCtrl.Animation.Motion.PreLoader.CreateAllObjects()
		Map3DSystem.Movie.MovieEditPage.ShowMoviePage(filename)
	end
end

-- @param filename: delete the movie script. 
function MovieListPage.OnClickDeleteMovie(filename)
	if(not filename)then return; end
	local name = string.match(filename, "([^/\\]+)%.xml$") or filename
	_guihelper.MessageBox(string.format("你确定要删除:%s?", name), function()
					Map3DSystem.Movie.MoviePlayerPage.DoStop();
					Map3DSystem.Movie.MovieScriptManager.RemoveScript(filename);
					ParaIO.DeleteFile(filename)
					MovieListPage.OnClickClose();
					Map3DSystem.Movie.MovieListPage.SelectedMovieManager = nil;
					Map3DSystem.Movie.MovieEditPage.Clear()
				end)
	
end
function MovieListPage.ClearGlobalValue()
	Map3DSystem.Movie.MovieListPage.SelectedMovieManager = nil;
end
