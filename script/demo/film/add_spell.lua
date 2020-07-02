--[[
Title: The demo bar UI
Author(s): LiXizhi
Date: 2005/9
Revised: 2005/11
use the lib:
]]
NPL.load("(gl)script/ide/gui_helper.lua");

-- the skill kits lib
if(not SkillKits) then SkillKits = {}; end

-- missile target string.
SkillKits.target = "<2>"; -- hand
-- current selected spell ID.
SkillKits.SpellID = 0;	-- current selected spell ID
-- the missile source
SkillKits.source = "<player>"; -- current player
--[[ set the target of the missile object.
@param sTarget
]]
function SkillKits.SetTarget(sTarget)
	if(type(sTarget) == "number") then
		SkillKits.target = string.format("<%d>", tonumber(sTarget));
		SkillKits.NewSpell(SkillKits.SpellID);
	elseif(type(sTarget) == "string") then
		SkillKits.target = sTarget;
	end
	local temp = ParaUI.GetUIObject("spell_target_text");
	if (temp:IsValid() == true) then
		temp.text = SkillKits.target;
	end
end

--[[set the target to be the one in the text box.]]
function SkillKits.UpdateTarget()
	local temp = ParaUI.GetUIObject("spell_target_text");
	if (temp:IsValid() == true) then
		SkillKits.target = temp.text;
	end
end

--[[ create a new spell using the current target and source with the specified spell ]]
function SkillKits.NewSpell(SpellID)
	SkillKits.SpellID = SpellID;
	local player = ParaScene.GetObject(SkillKits.source);
	
	if(SpellID == 1) then
		-- this is just a test
		--local asset = ParaAsset.LoadParaX("", "Item/ObjectComponents/Weapon/Knife_1H_Dagger_B_01.m2");
		local asset = ParaAsset.LoadStaticMesh("", "model/03生活/旗帜.x");
		if((asset == nil) or (asset:IsValid()==false))then
			_guihelper.MessageBox("模型不存在，可能您在使用精简版."); 
			return;
		end
		player:ToCharacter():AddAttachment(asset,2);
	else
		player:ToCharacter():CastEffect(SpellID,SkillKits.target);
	end
end

--[[ create a new spell using the current target and source with the specified spell ]]
function SkillKits.RemoveSpell()
	local player = ParaScene.GetObject(SkillKits.source);
	player:ToCharacter():CastEffect(-1);
end

local function activate()
	local temp=ParaUI.GetUIObject("spell_main_cont");
	if (temp:IsValid() == false) then
	local __this,__parent,__font,__texture;

	__this=ParaUI.CreateUIObject("container","spell_main_cont", "_lt",440,100,360,480);
	__this:AttachToRoot();
	__this.scrollable=false;
	__this.background="Texture/cr_zoo.png";
	__this.candrag=true;
	__this.receivedrag = true;

	__this=ParaUI.CreateUIObject("text","text", "_lt",25,23,100,22);
	__parent=ParaUI.GetUIObject("spell_main_cont");__parent:AddChild(__this);
	__this.text="添加特效";
	__this.autosize=true;
	__this.candrag=false;
	
	
	__this=ParaUI.CreateUIObject("text","text", "_lt",25,60,100,22);
	__parent=ParaUI.GetUIObject("spell_main_cont");__parent:AddChild(__this);
	__this.text="目标：";
	__this.autosize=true;
	__this.candrag=false;
	
	__this=ParaUI.CreateUIObject("imeeditbox","spell_target_text", "_lt",80,55,120,30);
	__parent=ParaUI.GetUIObject("spell_main_cont");__parent:AddChild(__this);
	__this.text=SkillKits.target;
	__this.background="Texture/box.png;";
	__this.candrag=false;
	__this.readonly=false;
	
	__this=ParaUI.CreateUIObject("button","button1", "_lt",200,55,60,30);
	__parent=ParaUI.GetUIObject("spell_main_cont");__parent:AddChild(__this);
	__this.text="确定";
	__this.background="Texture/b_up.png;";
	__this.onclick="(gl)/script/empty.lua;SkillKits.UpdateTarget();";
	__this.candrag=false;
	
	__this=ParaUI.CreateUIObject("button","button1", "_lt",260,55,60,30);
	__parent=ParaUI.GetUIObject("spell_main_cont");__parent:AddChild(__this);
	__this.text="取消";
	__this.background="Texture/b_up.png;";
	__this.onclick="(gl)/script/empty.lua;SkillKits.RemoveSpell();";
	__this.candrag=false;
	
	__this=ParaUI.CreateUIObject("button","button1", "_lt",80,100,60,30);
	__parent=ParaUI.GetUIObject("spell_main_cont");__parent:AddChild(__this);
	__this.text="左手";
	__this.background="Texture/b_up.png;";
	__this.onclick="(gl)/script/empty.lua;SkillKits.SetTarget(1);";
	__this.candrag=false;
	
	__this=ParaUI.CreateUIObject("button","button1", "_lt",150,100,60,30);
	__parent=ParaUI.GetUIObject("spell_main_cont");__parent:AddChild(__this);
	__this.text="右手";
	__this.background="Texture/b_up.png;";
	__this.onclick="(gl)/script/empty.lua;SkillKits.SetTarget(2);";
	__this.candrag=false;
	
	__this=ParaUI.CreateUIObject("button","button1", "_lt",220,100,60,30);
	__parent=ParaUI.GetUIObject("spell_main_cont");__parent:AddChild(__this);
	__this.text="头";
	__this.background="Texture/b_up.png;";
	__this.onclick="(gl)/script/empty.lua;SkillKits.SetTarget(11);";
	__this.candrag=false;
	
	__this=ParaUI.CreateUIObject("button","button1", "_lt",80,135,60,30);
	__parent=ParaUI.GetUIObject("spell_main_cont");__parent:AddChild(__this);
	__this.text="左肩";
	__this.background="Texture/b_up.png;";
	__this.onclick="(gl)/script/empty.lua;SkillKits.SetTarget(5);";
	__this.candrag=false;
	
	__this=ParaUI.CreateUIObject("button","button1", "_lt",150,135,60,30);
	__parent=ParaUI.GetUIObject("spell_main_cont");__parent:AddChild(__this);
	__this.text="右肩";
	__this.background="Texture/b_up.png;";
	__this.onclick="(gl)/script/empty.lua;SkillKits.SetTarget(6);";
	__this.candrag=false;
	
	__this=ParaUI.CreateUIObject("button","button1", "_lt",220,135,60,30);
	__parent=ParaUI.GetUIObject("spell_main_cont");__parent:AddChild(__this);
	__this.text="身体";
	__this.background="Texture/b_up.png;";
	__this.onclick="(gl)/script/empty.lua;SkillKits.SetTarget(0);";
	__this.candrag=false;
	
		
	-- 一行的开始
	local nRow, nCol = 0,0;
	__parent=ParaUI.GetUIObject("spell_main_cont");
	for i= 1,24 do
		__this=ParaUI.CreateUIObject("button","b1", "_lt",30+50*nCol,180+50*nRow,40,40);
		__parent:AddChild(__this);
		if(i<10) then
			__this.background=string.format("Texture/skillicon/0%d.png", i);
		else
			__this.background=string.format("Texture/skillicon/%d.png", i);
		end
		__this.onclick=string.format([[(gl)script/empty.lua;SkillKits.NewSpell(%d);]], i);
		__this.candrag=true;
		
		if(nCol>=5) then
			nCol = 0;
			nRow=nRow+1;
		else
			nCol = nCol+1;
		end
	end
		
	__this=ParaUI.CreateUIObject("button","close_button", "_lt",240,395,60,30);
	__parent=ParaUI.GetUIObject("spell_main_cont");__parent:AddChild(__this);
	__this.text="关闭";
	__this.background="Texture/b_up.png;";
	__this.onclick="(gl)empty.lua;ParaUI.Destroy(\"spell_main_cont\");";
	__this.candrag=false;

	end
end
NPL.this(activate);
 