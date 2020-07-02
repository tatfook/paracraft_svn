--[[
Title: listing all actors Dialog
Author(s): Code: LiXizhi 
Date: 2005/11
]]
NPL.load("(gl)script/movie/movielib.lua");
NPL.load("(gl)script/ide/object_editor.lua");

if(not MovieUI) then MovieUI = {}; end
-- add a new actor
function MovieUI.AddActor()
	local tmp =ParaUI.GetUIObject("movie_actor_name");
	if(tmp:IsValid()==false) then
		return;
	end
	local actorname = tmp.text;
	if(actorname~="") then 
		_movie.NewActor(actorname);
		MovieUI.UpdateActorListUI();
	end
end

-- delete an actor from the the movie list and the scene
function MovieUI.DelActor()
	local tmp =ParaUI.GetUIObject("movie_actor_name");
	if(tmp:IsValid()==false) then
		return;
	end
	local actorname = tmp.text;
	if(actorname~="") then 
		local actor = ParaScene.GetObject(actorname);
		if(actor:IsValid() == true) then
			if(ObjEditor.DelObject(actor) == true) then
				-- remove from movie
				_movie.DeleteActor(actorname);
				-- update the UI
				MovieUI.UpdateActorListUI();
				_guihelper.MessageBox("角色:"..actorname.." 已经从电影列表中删除");
			end
		end
	end
end

-- Remove an actor from the movie list, but not from the scene.
function MovieUI.RemoveActor()
	local tmp =ParaUI.GetUIObject("movie_actor_name");
	if(tmp:IsValid()==false) then
		return;
	end
	local actorname = tmp.text;
	if(actorname~="") then 
		-- remove from movie
		_movie.DeleteActor(actorname);
		-- update the UI
		MovieUI.UpdateActorListUI();
	end
end


--[[ update the actor list UI with the current actors in the movie.
this function is called when loading a new movie
]]
function MovieUI.UpdateActorListUI()
	local __texture;
	local listbox = ParaUI.GetUIObject("actor_list_text");
	if(listbox:IsValid() == true) then
		
		-- refill the list box of objects
		listbox:RemoveAll();
		
		local key, actor;
		local NumOfActors=0;
		for key, actor in pairs(_movie.actors) do
			listbox:AddTextItem(tostring(key));
			NumOfActors = NumOfActors+1;
		end
		
		-- set number of actors
		local temp = ParaUI.GetUIObject("actor_list_count");
		if(temp:IsValid()==true) then 
			temp.text=tostring(NumOfActors);
		end
	end
end

--save to file
function MovieUI.SaveMovieFile() 
	_movie.SaveMovieToFile();
end

local function activate()
	_guihelper.CheckRadioButtons( _demo_film_pages, "film_list", "255 0 0");
			
	local __this,__parent,__font,__texture;
	__this = ParaUI.GetUIObject("player_container");
	if(__this:IsValid() == true) then
		__this.visible = false;
	end
	__this = ParaUI.GetUIObject("film_container");
	if(__this:IsValid() == true) then
		__this.visible = false;
	end

	__this = ParaUI.GetUIObject("list_container");
	if(__this:IsValid() == true) then
		__this.visible=true;
	else
		__this=ParaUI.CreateUIObject("container","list_container", "_lt",30,60,299,390);
		__parent=ParaUI.GetUIObject("film_main");__parent:AddChild(__this);
		__this.scrollable=false;
		__this.background="Texture/item.png;";
		__this.candrag=false;
		__texture=__this:GetTexture("background");
		__texture.transparency=0;--[0-255]
		
		__this=ParaUI.CreateUIObject("imeeditbox","movie_actor_name", "_lt",10,50,105,30);
		__parent=ParaUI.GetUIObject("list_container");__parent:AddChild(__this);
		__this.text=ParaScene.GetObject("<player>").name;
		__this.background="Texture/box.png;";
		__this.candrag=false;
		__this.readonly=false;
		
		__this=ParaUI.CreateUIObject("button","movie_add_actor", "_lt",115,50,60,30);
		__parent=ParaUI.GetUIObject("list_container");__parent:AddChild(__this);
		__this.text="添加";
		__this.background="Texture/b_up.png;";
		__this.onclick=";MovieUI.AddActor()";
		__this.candrag=false;
		
		__this=ParaUI.CreateUIObject("button","movie_del_actor", "_lt",175,50,60,30);
		__parent=ParaUI.GetUIObject("list_container");__parent:AddChild(__this);
		__this.text="删除";
		__this.background="Texture/b_up.png;";
		__this.onclick=";MovieUI.DelActor()";
		__this.candrag=false;
		
		__this=ParaUI.CreateUIObject("button","movie_remove_actor", "_lt",235,50,60,30);
		__parent=ParaUI.GetUIObject("list_container");__parent:AddChild(__this);
		__this.text="移出";
		__this.background="Texture/b_up.png;";
		__this.onclick=";MovieUI.RemoveActor()";
		__this.candrag=false;
		
		__this=ParaUI.CreateUIObject("text","text1", "_lt",10,90,100,22);
		__parent=ParaUI.GetUIObject("list_container");__parent:AddChild(__this);
		__this.text="角色数量：";
		__this.autosize=true;
		__this.background="Texture/dxutcontrols.dds;0 0 0 0";
		__this.candrag=false;
		__texture=__this:GetTexture("background");
		__texture.transparency=255;--[0-255]
		
		__this=ParaUI.CreateUIObject("text","actor_list_count", "_lt",115,90,100,22);
		__parent=ParaUI.GetUIObject("list_container");__parent:AddChild(__this);
		__this.text="0位";
		__this.autosize=true;
		__this.candrag=false;
		
		__this=ParaUI.CreateUIObject("button","actor_list_save", "_lt",10,130,60,30);
		__parent=ParaUI.GetUIObject("list_container");__parent:AddChild(__this);
		__this.text="存盘";
		__this.background="Texture/b_up.png;";
		__this.onclick=";MovieUI.SaveMovieFile()";
		__this.candrag=false;
		
		__this=ParaUI.CreateUIObject("button","actor_list_update", "_lt",70,130,60,30);
		__parent=ParaUI.GetUIObject("list_container");__parent:AddChild(__this);
		__this.text="刷新";
		__this.background="Texture/b_up.png;";
		__this.onclick=";MovieUI.UpdateActorListUI();";
		__this.candrag=false;

		__this=ParaUI.CreateUIObject("listbox","actor_list_text", "_lt",10,160,270,190);
		__parent=ParaUI.GetUIObject("list_container");__parent:AddChild(__this);
		__this.scrollable=true;
		__this.background="Texture/player/outputbox.png;";
	end
	-- update list
	MovieUI.UpdateActorListUI();
end
NPL.this(activate);
