--[[
Title: code behind page for MovieClipToolBar_Page.html
Author(s): Leio Zhang
Date: 2008/10/20
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieClipToolBar_Page.lua");
-------------------------------------------------------
]]
local MovieClipToolBar_Page = {
	name = "MovieClipToolBar_Page_instance",
	mcToolBar = nil,
};
commonlib.setfield("Map3DSystem.Movie.MovieClipToolBar_Page", MovieClipToolBar_Page)
---------------------------------
-- page event handlers
---------------------------------

-- load default values.
function MovieClipToolBar_Page.OnInit()
	local self = document:GetPageCtrl();
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieToolBar.lua");
	local mcToolBar = Map3DSystem.Movie.MovieToolBar:new();
	MovieClipToolBar_Page.mcToolBar = mcToolBar;
end
function MovieClipToolBar_Page.ShowPlayerView(params) 

end
function MovieClipToolBar_Page.DataBind(mcmlNode,movieEditor)
	if(not mcmlNode or not movieEditor)then return; end
	local self = MovieClipToolBar_Page;
	self.mcToolBar:DataBind(mcmlNode,movieEditor);
end
function MovieClipToolBar_Page.OnSelected(param,param2)
	if(not param)then return; end
	local self = MovieClipToolBar_Page;
	if(not self.mcToolBar)then return; end
	self.mcToolBar:OnSelected(param,param2);
end

