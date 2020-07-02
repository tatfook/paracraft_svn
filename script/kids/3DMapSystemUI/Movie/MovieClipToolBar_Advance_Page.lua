--[[
Title: code behind page for MovieClipToolBar_Advance_Page.html
Author(s): Leio Zhang
Date: 2008/12/1
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieClipToolBar_Advance_Page.lua");
-------------------------------------------------------
]]
local MovieClipToolBar_Advance_Page = {
	name = "MovieClipToolBar_Page_instance",
	mcToolBar = nil,
};
commonlib.setfield("Map3DSystem.Movie.MovieClipToolBar_Advance_Page", MovieClipToolBar_Advance_Page)
---------------------------------
-- page event handlers
---------------------------------

-- load default values.
function MovieClipToolBar_Advance_Page.OnInit()
	local self = document:GetPageCtrl();
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieToolBar.lua");
	local mcToolBar = Map3DSystem.Movie.MovieToolBar:new();
	MovieClipToolBar_Advance_Page.mcToolBar = mcToolBar;
end
function MovieClipToolBar_Advance_Page.ShowPlayerView(params) 

end
function MovieClipToolBar_Advance_Page.DataBind(mcmlNode,movieEditor)
	if(not mcmlNode or not movieEditor)then return; end
	local self = MovieClipToolBar_Advance_Page;
	self.mcToolBar:DataBind(mcmlNode,movieEditor);
end
function MovieClipToolBar_Advance_Page.OnSelected(param,param2)
	if(not param)then return; end
	local self = MovieClipToolBar_Advance_Page;
	if(not self.mcToolBar)then return; end
	self.mcToolBar:OnSelected(param,param2);
end
function MovieClipToolBar_Advance_Page.TabItemClicked()
	Map3DSystem.App.Commands.Call("File.CreateEntityUnhook");
end