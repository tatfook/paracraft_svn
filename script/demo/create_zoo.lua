--[[
Title: the animals creation dialog and animals creation lib in CreateZoo table.
Author(s): LiXizhi, LiYu
Date: 2005/11
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/demo/create_zoo.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/visibilityGroup.lua");
NPL.load("(gl)script/ide/gui_helper.lua");

-- global states
_newanimal ={};
-- current animal name
_newanimal.name = "animal1";
_newanimal.nameID = 0;
_newanimal.modelname = "熊";
-- whether it is global
_newanimal.IsGlobal = true;
-- model scale
_newanimal.scale = 1.0;
-- skin index 
_newanimal.skinIndex = 1;

_newanimal.skinsCount = 7;
_newanimal.skins = {
	"皮肤1",
	"皮肤2",
	"皮肤3",
	"皮肤4",
	"皮肤5",
	"皮肤6",
	"皮肤7"
};

--[[ zoo animals asset:pairs(modelname, filename)]]
local animlist = {};
animlist["熊"] = "Creature/bear/Bear.m2";
animlist["松鼠"] = "Creature/Squirrel/Squirrel.m2";
animlist["狼"] = "Creature/Wolf/Wolf.m2";
animlist["野猪"] = "Creature/Boar/Boar.m2";
animlist["秃鹰"] = "Creature/CarrionBird/CarrionBird.m2";
animlist["猫"] = "Creature/Cat/Cat.m2";
animlist["小鸡"] = "Creature/Chicken/Chicken.m2";
animlist["奶牛"] = "Creature/Cow/Cow.m2";
animlist["螃蟹"] = "Creature/Crab/Crab.m2";
animlist["鹿"] = "Creature/Deer/Deer.m2";
animlist["青蛙"] = "Creature/Frog/Frog.m2";
animlist["虎"] = "Creature/FrostSabre/FrostSabre.m2";
animlist["羚羊"] = "Creature/Gazelle/Gazelle.m2";
animlist["猩猩"] = "Creature/Gorilla/Gorilla.m2";
animlist["马"] = "Creature/Horse/Horse.m2";
animlist["狮子"] = "Creature/Lion/Lion.m2";
animlist["猫头鹰"] = "Creature/Owl/Owl.m2";
animlist["鹦鹉"] = "Creature/Parrot/Parrot.m2";
animlist["兔子"] = "Creature/Rabbit/Rabbit.m2";
animlist["山羊"] = "Creature/Ram/Ram.m2";
animlist["蝎子"] = "Creature/Scorpion/Scorpion.m2";
animlist["海龟"] = "Creature/SeaTurtle/SeaTurtle.m2";
animlist["绵羊"] = "Creature/Sheep/Sheep.m2";
animlist["麋鹿"] = "Creature/Stag/Stag.m2";
animlist["暴龙"] = "Creature/TRex/trex.m2";
animlist["蜘蛛"] = "Creature/Tarantula/Tarantula.m2";
animlist["虎"] = "Creature/Tiger/Tiger.m2";
animlist["斑马"] = "Creature/Unicorn/Unicorn.m2";
animlist["蟑螂"] = "Creature/cockroach/Cockroach.m2";
animlist["长颈鹿"] = "Creature/giraffe/Giraffe.m2";
animlist["熊猫"] = "Creature/panda/PandaCub.m2";
animlist["蛇"] = "Creature/snake/snake.m2";
animlist["狮鹫"] = "Creature/Gryphon/Gryphon.m2";
--animlist["鹰角兽"] = "Creature/Hippogryph/Hippogryph.m2";
animlist["犀牛"] = "Creature/Kodobeast/RidingKodo.m2";
--animlist["机器鸟"] = "Creature/MechaStrider/MechaStrider.m2";
animlist["迅猛龙"] = "Creature/Raptor/Raptor.m2";
animlist["麋鹿"] = "Creature/Stag/Stag.m2";
animlist["鸵鸟"] = "Creature/Tallstrider/TallStrider.m2";
animlist["亚龙"] = "Creature/Drake/Drake.m2";
--增加
animlist["巨龙"] = "Creature/Dragon/DragonNefarian.m2";
animlist["巨虎"] = "Creature/FrostSabre/FrostSabre.m2";
animlist["鳄鱼"] = "Creature/Crocodile/Crocodile.m2";
animlist["食人鱼"] = "Creature/Frenzy/Frenzy.m2";

_newanimal.creatures = animlist;

-- CreateZoo: animation creation library 
if(not CreateZoo) then CreateZoo={}; end
-- increase skin index and update UI
function CreateZoo.IncSkinIndex()

	if(_newanimal.skinIndex >= _newanimal.skinsCount) then 
		_newanimal.skinIndex = 1;
	else 
		_newanimal.skinIndex = _newanimal.skinIndex + 1; 
	end;
	local __that = ParaUI.GetUIObject("ca_skinIndex");
	__that.text = _newanimal.skins[_newanimal.skinIndex];
end

-- decrease skin index and update UI
function CreateZoo.DecSkinIndex()

	if(_newanimal.skinIndex<=1 ) then 
		_newanimal.skinIndex = _newanimal.skinsCount;
	else 
		_newanimal.skinIndex = _newanimal.skinIndex - 1; 
	end;
	local __that = ParaUI.GetUIObject("ca_skinIndex");
	__that.text = _newanimal.skins[_newanimal.skinIndex];
end

-- increase model scale and update UI
function CreateZoo.IncScale()
	_newanimal.scale = _newanimal.scale *1.2;
	local __that = ParaUI.GetUIObject("ca_modelScale");
	__that.text = string.format("%.4f", _newanimal.scale);
end

-- decrease model scale and update UI
function CreateZoo.DecScale()
	_newanimal.scale = _newanimal.scale /1.2;
	local __that = ParaUI.GetUIObject("ca_modelScale");
	__that.text = string.format("%.4f", _newanimal.scale);
end
-- create a new animal
function CreateZoo.NewAnimal()
	--create global character. It can walk in the entire scene
	local playerChar;
	local player = ParaScene.GetObject("<player>");
	local x,y,z;
	x,y,z = player:GetPosition();
	local fileName = _newanimal.creatures[_newanimal.modelname];
	if(fileName~=nil) then
		-- get name
		local playerName = ParaUI.GetUIObject("ca_name");
		if ((playerName:IsValid() ~= true) or (playerName.text == "")) then
			_guihelper.MessageBox("请输入对象名称");
			return;
		end
		_newanimal.name = playerName.text;
		
		-- check if the name is already used.
		if(ParaScene.GetObject(_newanimal.name):IsValid() == true) then
			_guihelper.MessageBox("对象名称已存在,请用其它名字创建.");
			return;
		end
	
		-- create the new object
		asset = ParaAsset.LoadParaX("", fileName);
		if((asset == nil) or (asset:IsValid()==false))then
			_guihelper.MessageBox("模型不存在，可能您在使用精简版."); 
			return;
		end
	
		player = ParaScene.CreateCharacter(_newanimal.name, asset, "", _newanimal.IsGlobal, 0.35, player:GetFacing(), _newanimal.scale);
		player:SetPosition(x, y, z);
		player:SetPersistent(true);
		
		local att = player:GetAttributeObject();
		--actor senses only player
		att:SetField("GroupID", 1);
		att:SetField("SentientField", 1);
		
		ParaScene.Attach(player);
		playerChar = player:ToCharacter();
		--[[
		if(_newanimal.scale ~= 1.0) then
			-- Note: change the speed. This will ensure that model's speed is unchanged regardless of its size scale.
			playerChar:SetSpeedScale(1.0/_newanimal.scale);
		end]]
		playerChar:SetSkin(_newanimal.skinIndex);
		log("creature ".._newanimal.name.." successfully created.\n");
	else
		log("creature ".._newanimal.modelname.." not found\n");
	end
end

local function activate()
	local __this,__parent,__font,__texture;
	local texture;

	local temp = ParaUI.GetUIObject("CreateAnimals_dialog");
	if (temp:IsValid() == true) then
		CommonCtrl.VizGroup.Show("group1", not temp.visible, "CreateAnimals_dialog");
	else
	CommonCtrl.VizGroup.Show("group1", false);
	CommonCtrl.VizGroup.AddToGroup("group1", "CreateAnimals_dialog");

	__this=ParaUI.CreateUIObject("container","CreateAnimals_dialog", "_lt",50,40,470,610);
	__this:AttachToRoot();
	__this.scrollable=false;
	__this.background="Texture/cr_zoo.png";
	__this.candrag=true;
	
	__this=ParaUI.CreateUIObject("text","ca_text", "_lt",25,40,382,38);
	__parent=ParaUI.GetUIObject("CreateAnimals_dialog");__parent:AddChild(__this);
	__this.text="设定动物名称：";
	__this.autosize=true;
	
	__this=ParaUI.CreateUIObject("imeeditbox","ca_name", "_lt",150,35,85,30);
	__parent=ParaUI.GetUIObject("CreateAnimals_dialog");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/box.png";
	
	__this=ParaUI.CreateUIObject("text","ca_text", "_lt",25,85,382,38);
	__parent=ParaUI.GetUIObject("CreateAnimals_dialog");__parent:AddChild(__this);
	__this.text="设定放置类型：";
	__this.autosize=true;
	
	
	__this=ParaUI.CreateUIObject("button","button", "_lt",150,80,60,30);
	__parent=ParaUI.GetUIObject("CreateAnimals_dialog");__parent:AddChild(__this);
	__this.text="固定";
	__this.background="Texture/b_up.png;";
	__this.onclick=";_newanimal.IsGlobal=false;";
	
	
	__this=ParaUI.CreateUIObject("button","button", "_lt",215,80,60,30);
	__parent=ParaUI.GetUIObject("CreateAnimals_dialog");__parent:AddChild(__this);
	__this.text="移动";
	__this.background="Texture/b_up.png;";
	__this.onclick=";_newanimal.IsGlobal=true;";
	
	
	__this=ParaUI.CreateUIObject("text","ca_text", "_lt",25,130,382,38);
	__parent=ParaUI.GetUIObject("CreateAnimals_dialog");__parent:AddChild(__this);
	__this.text="设定动物类型：";
	__this.autosize=true;
	

	if(_newanimal.creatures~=nil) then
		local objName, ObjFileName;
		local nRow, nCol = 0,0;
		
		__parent=ParaUI.GetUIObject("CreateAnimals_dialog");
		for objName, ObjFileName in pairs(_newanimal.creatures) do
			__this=ParaUI.CreateUIObject("button","b1", "_lt",85+65*nCol,160+35*nRow,60,30);
			__parent:AddChild(__this);
			__this.text=tostring(objName);
			__this.background="Texture/b_up.png;";
			__this.onclick=string.format([[;_newanimal.modelname="%s";]], objName);
			
			
			if(nCol>=4) then
				nCol = 0;
				nRow=nRow+1;
			else
				nCol = nCol+1;
			end
		end
	end
	
	__this=ParaUI.CreateUIObject("text","ca_text", "_lt",25,450,382,38);
	__parent=ParaUI.GetUIObject("CreateAnimals_dialog");__parent:AddChild(__this);
	__this.text="设定动物外皮：";
	__this.autosize=true;
	
	
	__this=ParaUI.CreateUIObject("button","dec_skin", "_lt",150,445,30,30);
	__parent=ParaUI.GetUIObject("CreateAnimals_dialog");__parent:AddChild(__this);
	__this.background="Texture/arr_l.png;";
	__this.onclick=";CreateZoo.DecSkinIndex()";
	
	
	__this=ParaUI.CreateUIObject("text","ca_skinIndex", "_lt",185,450,76,22);
	__parent=ParaUI.GetUIObject("CreateAnimals_dialog");__parent:AddChild(__this);
	__this.text=_newanimal.skins[_newanimal.skinIndex];
	__this.autosize=true;
	
	__this=ParaUI.CreateUIObject("button","inc_skin", "_lt",240,445,30,30);
	__parent=ParaUI.GetUIObject("CreateAnimals_dialog");__parent:AddChild(__this);
	__this.background="Texture/arr_r.png;";
	__this.onclick=";CreateZoo.IncSkinIndex()";
	
	
	__this=ParaUI.CreateUIObject("text","ca_text", "_lt",25,490,382,38);
	__parent=ParaUI.GetUIObject("CreateAnimals_dialog");__parent:AddChild(__this);
	__this.text="设定动物体积：";
	__this.autosize=true;
	
	
	__this=ParaUI.CreateUIObject("button","ScaleDown", "_lt",150,490,20,20);
	__parent=ParaUI.GetUIObject("CreateAnimals_dialog");__parent:AddChild(__this);
	__this.background="Texture/down.png;";
	__this.text="";
	__this.onclick=";CreateZoo.DecScale()";
	
	
	__this=ParaUI.CreateUIObject("text","ca_modelScale", "_lt",185,490,55,20);
	__parent=ParaUI.GetUIObject("CreateAnimals_dialog");__parent:AddChild(__this);
	__this.text= string.format("%.4f", _newanimal.scale);
	__this.autosize=true;
	
	__this=ParaUI.CreateUIObject("button","ScaleUp", "_lt",240,490,20,20);
	__parent=ParaUI.GetUIObject("CreateAnimals_dialog");__parent:AddChild(__this);
	__this.background="Texture/up.png;";
	__this.text="";
	__this.onclick=";CreateZoo.IncScale()";
	
	
	__this=ParaUI.CreateUIObject("button","ca_create", "_lt",150,535,60,30);
	__parent=ParaUI.GetUIObject("CreateAnimals_dialog");__parent:AddChild(__this);
	__this.text="创建";
	__this.background="Texture/b_up.png;";
	__this.onclick=";CreateZoo.NewAnimal()";
	
	
	__this=ParaUI.CreateUIObject("button","closebtn", "_lt",280,535,60,30);
	__parent=ParaUI.GetUIObject("CreateAnimals_dialog");__parent:AddChild(__this);
	__this.text="关闭";
	__this.background="Texture/b_up.png;";
	--__this.onclick=";ParaUI.Destroy(\"CreateAnimals_dialog\");";
	__this.onclick="(gl)script/demo/create_zoo.lua";
	
	
	end
end

NPL.this(activate);
