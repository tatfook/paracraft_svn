--[[
Title: The demo bar UI
Author(s): LiXizhi,LiYu, LiuHe, 
Date: 2005/9
Revised: 2005/11
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/main_window.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/gui_helper.lua");

-- DemoBar: demo bar UI library 
if(not DemoBar) then DemoBar={}; end

-- position of the demobar
--DemoBar.pos = {x=0, y=675};
DemoBar.pos = {x=20, y=0}; -- put the demo bar on top.

-- Create DemoBar Buttons
function DemoBar.CreateDemoBarButtons()
	local __this,__parent,__font,__texture;
	local texture;

	local temp=ParaUI.GetUIObject("main_window_btn_cont");
	if (temp:IsValid() == false) then

	__this=ParaUI.CreateUIObject("container","main_window_btn_cont", "_lt",0,5,830,30);
	__parent=ParaUI.GetUIObject("main_window");__parent:AddChild(__this);
	texture=__this:GetTexture("background");
	texture.transparency=0;--[0-255]
	
	--[[
	__this=ParaUI.CreateUIObject("button","change_clothes", "_lt",36,0,80,30);
	__parent=ParaUI.GetUIObject("main_window_btn_cont");__parent:AddChild(__this);
	__this.text="属 性";
	__this.background="Texture/b_up.png;";
	__this.onclick="(gl)script/demo/state/main.lua";
	
	]]
	
	__this=ParaUI.CreateUIObject("button","create_player", "_lt",36,0,80,30);
	__parent=ParaUI.GetUIObject("main_window_btn_cont");__parent:AddChild(__this);
	__this.text="创建人物";
	__this.background="Texture/b_up.png;";
	__this.onclick="(gl)script/demo/create_player.lua";
	
	
	__this=ParaUI.CreateUIObject("button","create_player", "_lt",116,0,80,30);
	__parent=ParaUI.GetUIObject("main_window_btn_cont");__parent:AddChild(__this);
	__this.text="创建动物";
	__this.background="Texture/b_up.png;";
	__this.onclick="(gl)script/demo/create_zoo.lua";
	
	
	__this=ParaUI.CreateUIObject("button","create_object", "_lt",196,0,80,30);
	__parent=ParaUI.GetUIObject("main_window_btn_cont");__parent:AddChild(__this);
	__this.text="物体管理";
	__this.background="Texture/b_up.png";
	__this.onclick="(gl)script/demo/object/main.lua";
	
	
	__this=ParaUI.CreateUIObject("button","create_object", "_lt",276,0,80,30);
	__parent=ParaUI.GetUIObject("main_window_btn_cont");__parent:AddChild(__this);
	__this.text="地图编辑";
	__this.background="Texture/b_up.png";
	__this.onclick="(gl)script/demo/mapediter/main.lua";
		
	
	__this=ParaUI.CreateUIObject("button","create_object", "_lt",356,0,80,30);
	__parent=ParaUI.GetUIObject("main_window_btn_cont");__parent:AddChild(__this);
	__this.text="电 影";
	__this.background="Texture/b_up.png";
	__this.onclick="(gl)script/demo/film/main.lua";
	
	
	__this=ParaUI.CreateUIObject("imeeditbox","goname_box", "_lt",436,0,80,30);
	__parent=ParaUI.GetUIObject("main_window_btn_cont");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/box.png;";
	
	
	__this=ParaUI.CreateUIObject("button","btn_show_objectlist_", "_lt",516,0,30,30);
	__parent=ParaUI.GetUIObject("main_window_btn_cont");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/skill/arr_up.png;";
	__this.onclick=";DemoBar.ShowObjectList()";
		
	
	__this=ParaUI.CreateUIObject("button","go_button", "_lt",546,0,80,30);
	__parent=ParaUI.GetUIObject("main_window_btn_cont");__parent:AddChild(__this);
	__this.text="搜 索";
	__this.background="Texture/b_up.png;";
	__this.onclick=";DemoBar.SearchObject()";
	
	
	__this=ParaUI.CreateUIObject("button","create_object", "_lt",626,0,80,30);
	__parent=ParaUI.GetUIObject("main_window_btn_cont");__parent:AddChild(__this);
	__this.text="设 置";
	__this.background="Texture/b_up.png";
	__this.onclick="(gl)script/demo/setting/t7_setting.lua";
	
	
	__this=ParaUI.CreateUIObject("button","create_object", "_lt",706,0,80,30);
	__parent=ParaUI.GetUIObject("main_window_btn_cont");__parent:AddChild(__this);
	__this.text="录 像";
	__this.background="Texture/b_up.png";
	__this.onclick="(gl)script/demo/recorder/main.lua";
	
	
	__this=ParaUI.CreateUIObject("button","right_button", "_lt",786,0,30,30);
	__parent=ParaUI.GetUIObject("main_window_btn_cont");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/arr_l.png;";
	__this.onclick=";DemoBar.DeleteDemoBarButtons()";
	
	
	end
end
function DemoBar.DeleteDemoBarButtons()
	ParaUI.Destroy("main_window_btn_cont");
end

function DemoBar.SearchObject()

	local playerName = ParaUI.GetUIObject("goname_box");
	if (playerName:IsValid() ~= true) then
		log("search name text UI not exists \n");
		return;
	end
	local playerChar;
	local player = ParaScene.GetObject(playerName.text);
	if(player:IsValid() == true) then
		playerChar = player:ToCharacter();
		playerChar:SetFocus();
	else
		_guihelper.MessageBox("对象没找到");
	end
end

--[[
get the object list in a string.
@param nPageNo: the page number beginning from 1.
]]
function DemoBar.GetNameList(nPageNo)
	local sNames="";
	-- TODO:implement per page display. Currently,everything is displayed.
	local nMaxNumberPerPage = 30;
	if(not nPageNo)then nPageNo=1; end
	local player = ParaScene.GetObject("<player>");
	local playerCur = player;
	local i=0;
	while(playerCur:IsValid() == true) do
		sNames = sNames..playerCur.name.."\n";
		playerCur = ParaScene.GetNextObject(playerCur);
		i=i+1;
		if(i>nMaxNumberPerPage) then
			sNames = sNames.."(more)";
			break; 
		end
		if(playerCur:equals(player) == true) then
			break; -- cycled to the beginning again.
		end
	end
	return sNames;
end

--[[ set focus on a specified character]]
function DemoBar.SetFocus(actor_name)
	local player = ParaScene.GetObject(actor_name);
	player:ToCharacter():SetFocus();
end

--[[ display the object list dialog pop up]]
function DemoBar.ShowObjectList()
	
	local temp = ParaUI.GetUIObject("globalobject_list_cont");
	if (temp:IsValid() == true) then
		ParaUI.Destroy("globalobject_list_cont");
	else
		--[[get the position of the search text]]
		local x,y;
		local width,height = 150,180;
		temp = ParaUI.GetUIObject("main_window");
		if (temp:IsValid() == true) then
			x = temp.x;
			y = temp.y;
			temp = ParaUI.GetUIObject("btn_show_objectlist_");
			if (temp:IsValid() == true) then
				x = x+temp.x+temp.width-width; if(x<0) then x=0; end
				y = y - height; if(y<0) then y=0; end
			end
		else
			x,y = 0,0;
		end
		local __this,__parent,__font,__texture;
		__this=ParaUI.CreateUIObject("container","globalobject_list_cont", "_lt",x,y,width,height);
		__this:AttachToRoot();
		__this.scrollable=false;
		__this.background="Texture/player/outputbox.png";
		
		__texture=__this:GetTexture("background");
		__texture.transparency=180;--[0-255]
		
		__this=ParaUI.CreateUIObject("container","cont1", "_lt",10,5,width-15,height-30);
		__parent=ParaUI.GetUIObject("globalobject_list_cont");__parent:AddChild(__this);
		__this.scrollable=true;
		__texture=__this:GetTexture("background");
		__texture.transparency=0;--[0-255]
		
		--create a list of buttons 
		-- TODO:implement per page display. Currently,everything is displayed.
		local nMaxNumberPerPage = 30;
		if(not nPageNo)then nPageNo=1; end
		local player = ParaScene.GetObject("<player>");
		local playerCur = player;
		local i=0;
		__parent=__this; -- "cont1"
		while(playerCur:IsValid() == true) do
			-- create a button
			__this=ParaUI.CreateUIObject("button","b1", "_lt",0,i*15,width-20,15);
			__parent:AddChild(__this);
			__this.text=playerCur.name;
			__texture=__this:GetTexture("background");
			__texture.transparency=0;--[0-255]
			__this.onclick=";DemoBar.SetFocus(\""..playerCur.name.."\");";
 			
			playerCur = ParaScene.GetNextObject(playerCur);
			i=i+1;
			if(i>nMaxNumberPerPage) then
				__this=ParaUI.CreateUIObject("text","text1", "_lt",0,i*15,width-20,15);
				__parent:AddChild(__this);
				__this.text="下面还有...";
				__texture=__this:GetTexture("background");
				__texture.transparency=0;--[0-255]
				break; 
			end
			if(playerCur:equals(player) == true) then
				break; -- cycled to the beginning again.
			end
		end
		
		__this=ParaUI.CreateUIObject("button","b1", "_lt",width-30,height-30,30,30);
		__parent=ParaUI.GetUIObject("globalobject_list_cont");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/arr_no.png;";
		__this.onclick=";ParaUI.Destroy(\"globalobject_list_cont\");";
 		

		__this=ParaUI.CreateUIObject("button","b1", "_lt",width-90,height-30,30,30);
		__parent=ParaUI.GetUIObject("globalobject_list_cont");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/arr_l.png;";
		__this.onclick="";
		
		
		__this=ParaUI.CreateUIObject("button","b2", "_lt",width-60,height-30,30,30);
		__parent=ParaUI.GetUIObject("globalobject_list_cont");__parent:AddChild(__this);
		__this.text="";
		__this.background="Texture/arr_r.png;";
		__this.onclick="";
		
	end
end

local function activate()
	local __this,__parent,__font,__texture;
	
	__this=ParaUI.CreateUIObject("container","main_window", "_lt",DemoBar.pos.x,DemoBar.pos.y,830,60);
	__this:AttachToRoot();
	__this.scrollable=false;
	__this.candrag=true;
	__this.background="Texture/dxutcontrols.dds;0 0 0 0";
	__texture=__this:GetTexture("background");
	__texture.transparency=127;--[0-255]
	__this=ParaUI.CreateUIObject("button","left_button", "_lt",5,5,30,30);
	__parent=ParaUI.GetUIObject("main_window");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/arr_r.png;";
	__this.onclick=";DemoBar.CreateDemoBarButtons()";
	
	
	--if(application_name ~= "kidsmovie") then
		----调用技能栏快捷按钮
		--NPL.activate("(gl)script/demo/skill/skill.lua");
	--end
end
NPL.this(activate);
