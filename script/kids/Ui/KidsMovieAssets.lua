--[[
Title: All assets in the kidsmovie application.
Author(s): LiXizhi
Date: 2006/7/7
Desc: all assets in the kids movie. it will automatically load bonus assets from database.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/ui/KidsMovieAssets.lua");
ObjEditor.LoadKidsMovieAssets();
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/object_editor.lua");

function ObjEditor.LoadKidsMovieAssets()
	ObjEditor.assets ={
	 {name="建筑", rootpath = "model/01建筑/"},
	 {name="家具", rootpath = "model/02家具/"},
	 {name="生活", rootpath = "model/03生活/"},
	 {name="装饰", rootpath = "model/04装饰/"},
	 
	 {name="植物", rootpath = "model/05植物/"},
	 {name="其它", rootpath = "model/others/"}, -- for script and height files
	 {name="人物", rootpath = "character/"},
	 {name="测试", rootpath = "model/test/"},
         {name="杂物", rootpath = "model/pops/"},
	 --{name="矿石", rootpath = "model/06矿石/"},
	};
	log("kids movie asset loaded\r\n");
end

