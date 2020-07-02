--[[
Title: the character creation dialog and character creation lib in CreateChar table.
Author(s): LiuHe, LiXizhi
Date: 2005/9
Revised:2005/11
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/demo/create_player.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/gui_helper.lua");
NPL.load("(gl)script/ide/visibilityGroup.lua");

-- global states
_newplayer ={};
-- default race name
_newplayer.race ="human";
-- default sex: 1 for female; 0 for male
_newplayer.sex = 1;

-- current clothes set Index
_newplayer.setIndex = 1;

-- the clothing table
_newplayer.setClothesNum = 11;
local ClothesTable = {};
ClothesTable[1] = {"套装No.1",1,41};
ClothesTable[2] = {"套装No.2",2,81};
ClothesTable[3] = {"套装No.3",3,121};
ClothesTable[4] = {"套装No.4",4,161};
ClothesTable[5] = {"套装No.5",5,181};
ClothesTable[6] = {"套装No.6",6,185};
ClothesTable[7] = {"套装No.7",7,201};
ClothesTable[8] = {"套装No.8",8,206};
ClothesTable[9] = {"套装No.9",9,211};
ClothesTable[10] = {"套装No.10",10,342};
ClothesTable[11] = {"套装No.11",11,402};
_newplayer.setClothes = ClothesTable;

-- CreateChar: character creation library 
if(not CreateChar) then CreateChar={}; end
-- increase clothes index and update UI
function CreateChar.IncSetIndex()

	if(_newplayer.setIndex >= _newplayer.setClothesNum) then 
		_newplayer.setIndex = 1;
	else 
		_newplayer.setIndex = _newplayer.setIndex + 1; 
	end;
	local __that = ParaUI.GetUIObject("cp_setIndex");
	__that.text = _newplayer.setClothes[_newplayer.setIndex][1];
end

-- decrease clothes index and update UI
function CreateChar.DecSetIndex()

	if(_newplayer.setIndex<=1 ) then 
		_newplayer.setIndex = _newplayer.setClothesNum;
	else 
		_newplayer.setIndex = _newplayer.setIndex - 1; 
	end;
	local __that = ParaUI.GetUIObject("cp_setIndex");
	__that.text = _newplayer.setClothes[_newplayer.setIndex][1];
end

-- create a new character based on the current settings
function CreateChar.NewPlayer()
	-- get name
	local playerName = ParaUI.GetUIObject("cp_name");
	if ((playerName:IsValid() ~= true) or (playerName.text == "")) then
		_guihelper.MessageBox("请输入对象名称");
		return;
	end
	_newplayer.name = playerName.text;
	
	-- check if the name is already used.
	if(ParaScene.GetObject(_newplayer.name):IsValid() == true) then
		_guihelper.MessageBox("对象名称已存在,请用其它名字创建.");
		return;
	end
	
	--get asset
	local asset;
	if(_newplayer.race == "human") then
		if(_newplayer.sex == 1) then
			asset = ParaAsset.LoadParaX("", "Character/Human/Female/HumanFemale.m2");
		elseif(_newplayer.sex == 0) then
			asset = ParaAsset.LoadParaX("", "Character/Human/Male/HumanMale.m2");
		end
	elseif(_newplayer.race == "dwarf") then
		if(_newplayer.sex == 1) then
			asset = ParaAsset.LoadParaX("", "Character/Dwarf/Female/DwarfFemale.m2");
		elseif(_newplayer.sex == 0) then
			asset = ParaAsset.LoadParaX("", "Character/Dwarf/Male/DwarfMale.m2");
		end
	elseif(_newplayer.race == "gnome") then
		if(_newplayer.sex == 1) then
			asset = ParaAsset.LoadParaX("", "Character/Gnome/Female/GnomeFemale.m2");
		elseif(_newplayer.sex == 0) then
			asset = ParaAsset.LoadParaX("", "Character/Gnome/Male/GnomeMale.m2");
		end
	elseif(_newplayer.race == "nightelf") then
		if(_newplayer.sex == 1) then
			asset = ParaAsset.LoadParaX("", "Character/NightElf/Female/NightElfFemale.m2");
		elseif(_newplayer.sex == 0) then
			asset = ParaAsset.LoadParaX("", "Character/NightElf/Male/NightElfMale.m2");
		end
	elseif(_newplayer.race == "scourge") then
		if(_newplayer.sex == 1) then
			asset = ParaAsset.LoadParaX("", "Character/Scourge/Female/ScourgeFemale.m2");
		elseif(_newplayer.sex == 0) then
			asset = ParaAsset.LoadParaX("", "Character/Scourge/Male/ScourgeMale.m2");
		end
	elseif(_newplayer.race == "tauren") then
		if(_newplayer.sex == 1) then
			asset = ParaAsset.LoadParaX("", "Character/Tauren/Female/TaurenFemale.m2");
		elseif(_newplayer.sex == 0) then
			asset = ParaAsset.LoadParaX("", "Character/Tauren/Male/TaurenMale.m2");
		end
	elseif(_newplayer.race == "orc") then
		if(_newplayer.sex == 1) then
			asset = ParaAsset.LoadParaX("", "Character/Orc/Female/OrcFemale.m2");
		elseif(_newplayer.sex == 0) then
			asset = ParaAsset.LoadParaX("", "Character/Orc/Male/OrcMale.m2");
		end
	elseif(_newplayer.race == "troll") then
		if(_newplayer.sex == 1) then
			asset = ParaAsset.LoadParaX("", "Character/Troll/Female/TrollFemale.m2");
		elseif(_newplayer.sex == 0) then
			asset = ParaAsset.LoadParaX("", "Character/Troll/Male/TrollMale.m2");
		end
	end
	
	if((asset == nil) or (asset:IsValid()==false))then
		_guihelper.MessageBox("种族模型不存在，可能您在使用精简版."); 
		return;
	end
	
	--create global character. It can walk in the entire scene
	local playerChar;
	local player = ParaScene.GetObject("<player>");
	local x,y,z;
	
	_newplayer.EquipSet = _newplayer.setClothes[_newplayer.setIndex][3];
	x,y,z = player:GetPosition();
	
	player = ParaScene.CreateCharacter(_newplayer.name, asset, "", true, 0.35, player:GetFacing(), 1.0);
	player:SetPersistent(true);
	player:SetPosition(x, y+2.0, z);
	local att = player:GetAttributeObject();
	--actor senses only player
	att:SetField("GroupID", 1);
	att:SetField("SentientField", 1);
		
	ParaScene.Attach(player);
	playerChar = player:ToCharacter();
	playerChar:LoadStoredModel(_newplayer.EquipSet);
	playerChar:SetFocus();
	
	log("creature ".._newplayer.name.." successfully created.\n");
end

local function activate()
	local __this,__parent,__font,__texture;
	local texture;

	local temp = ParaUI.GetUIObject("cp_dialog");
	if (temp:IsValid() == true) then
		CommonCtrl.VizGroup.Show("group1", not temp.visible, "cp_dialog");
	else
	CommonCtrl.VizGroup.Show("group1", false);
	CommonCtrl.VizGroup.AddToGroup("group1", "cp_dialog");

	__this=ParaUI.CreateUIObject("container","cp_dialog", "_lt",50,40,400,610);
	__this:AttachToRoot();
	__this.scrollable=false;
	__this.background="Texture/cr_zoo.png";
	__this.candrag=true;
	
	__this=ParaUI.CreateUIObject("text","cp_text", "_lt",25,40,382,38);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="设定人物姓名：";
	__this.autosize=true;
	
	
	__this=ParaUI.CreateUIObject("imeeditbox","cp_name", "_lt",150,35,85,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/box.png";
	
	__this.readonly=false;
	
	__this=ParaUI.CreateUIObject("text","cp_text", "_lt",25,85,382,38);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="设定人物性别：";
	__this.autosize=true;
	
	
	__this=ParaUI.CreateUIObject("button","male_button", "_lt",150,80,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="男";
	__this.background="Texture/b_up.png;";
	__this.onclick=";_newplayer.sex = 0";
	
	
	__this=ParaUI.CreateUIObject("button","female_button", "_lt",215,80,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="女";
	__this.background="Texture/b_up.png;";
	__this.onclick=";_newplayer.sex = 1";
	
	
	__this=ParaUI.CreateUIObject("text","cp_text", "_lt",25,130,382,38);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="设定人物种族：";
	__this.autosize=true;
	
	
	__this=ParaUI.CreateUIObject("button","race1", "_lt",85,160,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="人类";
	__this.background="Texture/b_up.png;";
	__this.onclick=";_newplayer.race = \"human\"";
	
	
	__this=ParaUI.CreateUIObject("button","race2", "_lt",150,160,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="矮人";
	__this.background="Texture/b_up.png;";
	__this.onclick=";_newplayer.race = \"dwarf\"";
	
	
	__this=ParaUI.CreateUIObject("button","race3", "_lt",215,160,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="侏儒";
	__this.background="Texture/b_up.png;";
	__this.onclick=";_newplayer.race = \"gnome\"";
	
	__this=ParaUI.CreateUIObject("button","race4", "_lt",280,160,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="精灵";
	__this.background="Texture/b_up.png;";
	__this.onclick=";_newplayer.race = \"nightelf\"";
	
	
	__this=ParaUI.CreateUIObject("button","race5", "_lt",85,195,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="亡灵";
	__this.background="Texture/b_up.png;";
	__this.onclick=";_newplayer.race = \"scourge\"";
	
	
	__this=ParaUI.CreateUIObject("button","race6", "_lt",150,195,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="牛头";
	__this.background="Texture/b_up.png;";
	__this.onclick=";_newplayer.race = \"tauren\"";
	
	
	__this=ParaUI.CreateUIObject("button","race7", "_lt",215,195,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="兽人";
	__this.background="Texture/b_up.png;";
	__this.onclick=";_newplayer.race = \"orc\"";
	
	
	__this=ParaUI.CreateUIObject("button","race8", "_lt",280,195,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="巨魔";
	__this.background="Texture/b_up.png;";
	__this.onclick=";_newplayer.race = \"troll\"";
	
	
	__this=ParaUI.CreateUIObject("text","cp_text", "_lt",25,245,382,38);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="设定人物外貌：";
	__this.autosize=true;
	__this.background="Texture/dxutcontrols.dds;0 0 0 0";
	
	
	__this=ParaUI.CreateUIObject("button","left_set", "_lt",150,240,30,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/arr_l.png;";
	__this.onclick=";CreateChar.DecSetIndex()";
	
	
	__this=ParaUI.CreateUIObject("text","cp_setIndex", "_lt",185,245,76,22);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text=_newplayer.setClothes[_newplayer.setIndex][1];
	__this.autosize=true;
	
	
	__this=ParaUI.CreateUIObject("button","right_set", "_lt",266,240,30,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/arr_r.png;";
	__this.onclick=";CreateChar.IncSetIndex()";
	
	__this=ParaUI.CreateUIObject("text","cp_text", "_lt",25,300,382,38);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="设定感知属性：";
	__this.autosize=true;
	__this.background="Texture/dxutcontrols.dds;0 0 0 0";
		
	
	__this=ParaUI.CreateUIObject("button","race8", "_lt",85,330,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="玩家";
	__this.background="Texture/b_up.png;";
	__this.onclick="";
	
	
	__this=ParaUI.CreateUIObject("button","race8", "_lt",150,330,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="电影人";
	__this.background="Texture/b_up.png;";
	__this.onclick="";
	
	
	__this=ParaUI.CreateUIObject("button","race8", "_lt",215,330,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="木头人";
	__this.background="Texture/b_up.png;";
	__this.onclick="";
	
	
	__this=ParaUI.CreateUIObject("button","race8", "_lt",280,330,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="NPC";
	__this.background="Texture/b_up.png;";
	__this.onclick="";
	
	
	__this=ParaUI.CreateUIObject("text","cp_text", "_lt",25,375,382,38);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="设定NPC反映：";
	__this.autosize=true;
	__this.background="Texture/dxutcontrols.dds;0 0 0 0";
	
	
	__this=ParaUI.CreateUIObject("text","cp_text", "_lt",85,405,382,38);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="阵营：";
	__this.autosize=true;
	__this.background="Texture/dxutcontrols.dds;0 0 0 0";
	
	
	__this=ParaUI.CreateUIObject("button","race8", "_lt",150,400,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="正义";
	__this.background="Texture/b_up.png;";
	__this.onclick="";
	
	
	__this=ParaUI.CreateUIObject("button","race8", "_lt",215,400,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="中立";
	__this.background="Texture/b_up.png;";
	__this.onclick="";
	
	
	__this=ParaUI.CreateUIObject("button","race8", "_lt",280,400,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="邪恶";
	__this.background="Texture/b_up.png;";
	__this.onclick="";
	
	
	__this=ParaUI.CreateUIObject("text","cp_text", "_lt",85,445,382,38);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="反映：";
	__this.autosize=true;
	__this.background="Texture/dxutcontrols.dds;0 0 0 0";
	
	
	__this=ParaUI.CreateUIObject("button","race8", "_lt",150,440,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="攻击";
	__this.background="Texture/b_up.png;";
	__this.onclick="";
	
	
	__this=ParaUI.CreateUIObject("button","race8", "_lt",215,440,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="中立";
	__this.background="Texture/b_up.png;";
	__this.onclick="";
	
	
	__this=ParaUI.CreateUIObject("button","race8", "_lt",280,440,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="和平";
	__this.background="Texture/b_up.png;";
	__this.onclick="";
	

	__this=ParaUI.CreateUIObject("button","cp_create", "_lt",120,520,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="创建";
	__this.background="Texture/b_up.png;";
	__this.onclick=";CreateChar.NewPlayer()";
	
	
	__this=ParaUI.CreateUIObject("button","close", "_lt",240,520,60,30);
	__parent=ParaUI.GetUIObject("cp_dialog");__parent:AddChild(__this);
	__this.text="关闭";
	__this.background="Texture/b_up.png;";
	--__this.onclick=";ParaUI.Destroy(\"cp_dialog\");";
	__this.onclick="(gl)script/demo/create_player.lua";
	
	end
end
NPL.this(activate);
