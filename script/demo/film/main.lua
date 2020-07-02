--[[ 
Title: film UI for ParaEngine
Author(s): LiXizhi
Date: 2005/11
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/demo/film/main.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/visibilityGroup.lua");
NPL.load("(gl)script/movie/movielib.lua");
NPL.load("(gl)script/ide/gui_helper.lua");

_demo_film_pages = {"film_record", "film_play", "film_list"};

local function activate()
	local __this,__parent,__font,__texture;

	local temp = ParaUI.GetUIObject("film_main");
	if (temp:IsValid() == true) then
		CommonCtrl.VizGroup.Show("group1", not temp.visible, "film_main");
		_movie.EnableMovieLib(not temp.visible);
	else
		CommonCtrl.VizGroup.Show("group1", false);
		CommonCtrl.VizGroup.AddToGroup("group1", "film_main");


		__this=ParaUI.CreateUIObject("container","film_main", "_lt",50,80,360,540);
		__this:AttachToRoot();
		__this.scrollable=false;
		__this.background="Texture/user_bro.png";
		__this.candrag=true;

		__this=ParaUI.CreateUIObject("button","film_record", "_lt",50,30,80,30);
		__parent=ParaUI.GetUIObject("film_main");__parent:AddChild(__this);
		__this.text="电影录制";
		__this.background="Texture/b_up.png;";
		__this.onclick="(gl)script/demo/film/film_form.lua";

		__this=ParaUI.CreateUIObject("button","film_play", "_lt",135,30,80,30);
		__parent=ParaUI.GetUIObject("film_main");__parent:AddChild(__this);
		__this.text="电影播放";
		__this.background="Texture/b_up.png;";
		__this.onclick="(gl)script/demo/film/player_form.lua";

		__this=ParaUI.CreateUIObject("button","film_list", "_lt",220,30,80,30);
		__parent=ParaUI.GetUIObject("film_main");__parent:AddChild(__this);
		__this.text="角色列表";
		__this.background="Texture/b_up.png;";
		__this.onclick="(gl)script/demo/film/list_form.lua";

		__this=ParaUI.CreateUIObject("button","close_button", "_lt",240,460,60,30);
		__parent=ParaUI.GetUIObject("film_main");__parent:AddChild(__this);
		__this.text="关闭";
		__this.background="Texture/b_up.png;";
		--__this.onclick="ParaUI.Destroy(\"film_main\");_demo_film_openedwin=nil;";
		__this.onclick="(gl)script/demo/film/main.lua";

		NPL.activate("(gl)script/demo/film/film_form.lua");	
		
		_movie.EnableMovieLib(true);
	end
end
NPL.this(activate);
