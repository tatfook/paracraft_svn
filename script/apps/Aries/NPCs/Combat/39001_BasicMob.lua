--[[
Title: BasicMob
Author(s): WangTian
Date: 2009/8/24

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Combat/39001_BasicMob.lua
------------------------------------------------------------
]]

-- create class
local libName = "BasicMob";
local BasicMob = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.BasicMob", BasicMob);

local Pet = commonlib.gettable("MyCompany.Aries.Pet");

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- BasicMob.main
function BasicMob.main()
end

-- BasicMob.PreDialog
function BasicMob.PreDialog()
	if(System.options.version == "teen") then
		-- TODO: teen version predialog here. 
		NPL.load("(gl)script/apps/Aries/NPCs/Combat/39000_BasicArena.lua");
		local BasicArena = commonlib.gettable("MyCompany.Aries.Quest.NPCs.BasicArena");
		BasicArena.Set_immortal_countdown();
		return false;
	end
	local isadopted = false;
	local isdead = false;
	local dragon_level = 0;
	local bean = Pet.GetBean();
	if(bean) then
		--isadopted = bean.isadopted;
		--if(bean.health == 2) then
			--isdead = true;
		--end
		dragon_level = bean.level;
	end
	
	local whereIsDragon = "home";

	local item = ItemManager.GetMyMountPetItem();
	if(item and item.guid > 0) then
		whereIsDragon = item:WhereAmI();
	end

	--if(dragon_level < 3) then
		--_guihelper.MessageBox([[<div style="margin-left:10px;margin-top:20px;">
		--你的抱抱龙还太小，等他长大才能与黑暗魔法战斗！</div>]]);
	--elseif(isadopted == true) then
		--_guihelper.MessageBox([[<div style="margin-left:10px;margin-top:20px;width:290px;">
		--安吉奶奶在照顾你的抱抱龙，快快领回他吧！
		--小镇需要他与黑暗魔法战斗！</div>]]);
	--elseif(isdead == true)then
		--_guihelper.MessageBox([[<div style="margin-left:10px;margin-top:20px;">
		--你的抱抱龙已经死亡了，快快复活他吧！
		--小镇需要他与黑暗魔法战斗！</div>]]);
	--elseif(whereIsDragon == "home") then
		--_guihelper.MessageBox([[<div style="margin-left:10px;margin-top:20px;">
		--小镇处于危险之中，快快带上你的抱抱龙与黑暗魔法战斗吧！</div>]]);
	--elseif(not Pet.CombatIsOpened())then
		--_guihelper.MessageBox([[<div style="margin-left:10px;margin-top:20px;">
		--小镇处于危险之中，快快带上你的抱抱龙，找青龙学习战斗技能吧！</div>]]);
	--end
	if(whereIsDragon == "home") then
		_guihelper.MessageBox([[<div style="margin-left:10px;margin-top:20px;">
		小镇处于危险之中，快快带上你的抱抱龙与黑暗魔法战斗吧！</div>]]);
	elseif(not Pet.CombatIsOpened())then
		_guihelper.MessageBox([[<div style="margin-left:10px;margin-top:20px;">
		小镇处于危险之中，快快带上你的抱抱龙，找青龙学习战斗技能吧！</div>]]);
	end
	return false;
end
