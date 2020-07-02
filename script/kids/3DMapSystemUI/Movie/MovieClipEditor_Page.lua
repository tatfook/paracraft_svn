--[[
Title: code behind page for MovieClipEditor_Page.html
Author(s): LiXizhi
Date: 2008/8/19
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieClipEditor_Page.lua");
Map3DSystem.Movie.MovieClipEditor_Page.Show()
-------------------------------------------------------
]]
local MovieClipEditor_Page = {
	name = "MovieClipEditor_Page_instance",
	mcEditor = nil,
};
commonlib.setfield("Map3DSystem.Movie.MovieClipEditor_Page", MovieClipEditor_Page)
---------------------------------
-- page event handlers
---------------------------------

-- load default values.
function MovieClipEditor_Page.OnInit()
	local self = document:GetPageCtrl();
end
function MovieClipEditor_Page.ShowPlayerView(params) 
	NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieClipEditor.lua");
	local alignment,left,top,width,height,parent =  params.alignment,params.left,params.top,params.width,params.height,params.parent;
	local editor = Map3DSystem.Movie.MovieClipEditor:new{
		alignment = alignment,
		left = left,
		top = top,
		width = width,
		height = height, 
		parent = parent,
	}
	editor:Show(true)
	MovieClipEditor_Page.mcEditor = editor;
end
function MovieClipEditor_Page.DataBind(clip,moviescript) 
	local self = MovieClipEditor_Page;
	if(not clip or not self.mcEditor)then return; end
	self.mcEditor:DataBind(clip,moviescript)
end
function MovieClipEditor_Page.DoCloneKeyFrame() 
	local self = MovieClipEditor_Page;
	if(not self.mcEditor)then return; end
	self.mcEditor:CloneSelectedKeyFrame()
end
function MovieClipEditor_Page.DoRemoveKeyFrame() 
	local self = MovieClipEditor_Page;
	if(not self.mcEditor)then return; end
	self.mcEditor:RemoveSelectedKeyFrame();
end
function MovieClipEditor_Page.Show(clip,moviescript,width,height)
	NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieClipEditor_Page.lua");
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Movie/MovieClipEditor_Page.html", name="MovieClipEditor_Page", 
			app_key=MyCompany.Apps.VideoRecorder.app.app_key, 
			text = "制作电影",
			isShowCloseBox = false,
			allowResize = false,
			initialPosX = 115,
			initialPosY = 0,
			initialWidth = width or 640,
			initialHeight = height or 280,
			bToggleShowHide = false,
			bShow = true,
			DestroyOnClose = true,
		});
		--Map3DSystem.Movie.MovieClipEditor_Page.CreateFrame_1()
		--clip = MovieClipEditor_Page.test_root_mc
		Map3DSystem.Movie.MovieClipEditor_Page.DataBind(clip,moviescript)
end
function MovieClipEditor_Page.ShowToolBar(mcmlNode)
	NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieClipToolBar_Page.lua");
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Movie/MovieClipToolBar_Page.html", name="MovieClipToolBar_Page", 
			app_key=MyCompany.Apps.VideoRecorder.app.app_key, 
			text = "工具条",
			isShowTitleBar = true, 
			isShowCloseBox = false,
			initialPosX = 0,
			initialPosY = 0,
			initialWidth = 110,
			initialHeight = 280,
			bToggleShowHide = false,
			bShow = true,
			DestroyOnClose = true,
		});
		Map3DSystem.Movie.MovieClipToolBar_Page.DataBind(mcmlNode,MovieClipEditor_Page.mcEditor);
end
function MovieClipEditor_Page.Close()
	MovieClipEditor_Page.DoStop();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
	name="MovieClipEditor_Page", 
		app_key=MyCompany.Apps.VideoRecorder.app.app_key, 	
		bShow = false,bDestroy = true,
	});
	MovieClipEditor_Page.CloseToolBar();	
	Map3DSystem.App.Commands.Call("File.CloseAllPropertyPanel");
end
function MovieClipEditor_Page.CloseToolBar()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
	name="MovieClipToolBar_Page", 
		app_key=MyCompany.Apps.VideoRecorder.app.app_key, 	
		bShow = false,bDestroy = true,
	});
end
function MovieClipEditor_Page.DoPlay()
	local self = MovieClipEditor_Page;
	if(not self.mcEditor)then return; end
	self.mcEditor:DoPlay();
end
function MovieClipEditor_Page.DoPause()
	local self = MovieClipEditor_Page;
	if(not self.mcEditor)then return; end
	self.mcEditor:DoPause();
end
function MovieClipEditor_Page.DoResume()
	local self = MovieClipEditor_Page;
	if(not self.mcEditor)then return; end
	self.mcEditor:DoResume();
end
function MovieClipEditor_Page.DoStop()
	local self = MovieClipEditor_Page;
	if(not self.mcEditor)then return; end
	self.mcEditor:DoStop();
end
function MovieClipEditor_Page.DoZoomOut()
	local self = MovieClipEditor_Page;
	if(not self.mcEditor)then return; end
	self.mcEditor:DoZoomOut();
end
function MovieClipEditor_Page.DoZoomIn()
	local self = MovieClipEditor_Page;
	if(not self.mcEditor)then return; end
	self.mcEditor:DoZoomIn();
end
function MovieClipEditor_Page.GetFocus()
	Map3DSystem.App.Commands.Call("File.GetPlayerFocus");
end
function MovieClipEditor_Page.MapPosLogPage()
	Map3DSystem.App.Commands.Call("File.MapPosLogPage");
end
function MovieClipEditor_Page.DoMoveToPre()
	local self = MovieClipEditor_Page;
	if(not self.mcEditor)then return; end
	self.mcEditor:MoveToPre();
end
function MovieClipEditor_Page.DoMoveToNext()
	local self = MovieClipEditor_Page;
	if(not self.mcEditor)then return; end
	self.mcEditor:MoveToNext();
end