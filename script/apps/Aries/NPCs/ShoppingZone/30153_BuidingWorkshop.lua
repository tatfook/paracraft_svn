--[[
Title: BuidingWorkshop
Author(s): WangTian
Date: 2009/7/30

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/ShoppingZone/30153_BuidingWorkshop.lua
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");

-- create class
local libName = "BuidingWorkshop";
local BuidingWorkshop = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.BuidingWorkshop", BuidingWorkshop);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- 30006_IceHouse 冰雪小屋
-- 17038_IceHouseBluePrint 冰雪小屋的图纸
-- 17040_IceBrick 冰块
-- 17039_DarkStone 石头

-- BuidingWorkshop.main
function BuidingWorkshop.main()
end
function BuidingWorkshop.PreDialog()
	local self = BuidingWorkshop;
	NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30153_BuildingWorkshop_panel.lua");
	MyCompany.Aries.Quest.NPCs.BuildingWorkshop_panel.ShowPage()
	return false;
	----如果正在播放动画，返回
	--if(self.isComposing)then
		--return false;
	--end
end
function BuidingWorkshop.HasIcsHouse()
	 return hasGSItem(30006);--是否已经有冰雪小屋
end
function BuidingWorkshop.HasIceHouseBluePrint()
	 return hasGSItem(17038);--是否已经有冰雪小屋的图纸
end
function BuidingWorkshop.HasEnoughAssets()
	local hasItem_1,__,__,count_1 = hasGSItem(17040) --冰块
    local hasItem_2,__,__,count_2 = hasGSItem(17039) --石头
    return (hasItem_1 and count_1 and count_1>=15 and hasItem_2 and count_2 and count_2 >=50 )
end
--满足所有的兑换条件
function BuidingWorkshop.CanCompose()
	local self = BuidingWorkshop;
	return (not self.HasIcsHouse() and self.HasIceHouseBluePrint() and self.HasEnoughAssets())
end
--开始合成
function BuidingWorkshop.DoCompose()
	local self = BuidingWorkshop;
	if(not self.CanCompose())then
		commonlib.echo("====can't compose icehouse in BuidingWorkshop");
		return
	end
	commonlib.echo("========before get icehouse in BuidingWorkshop");
	if(not self.timer)then
		self.timer = commonlib.Timer:new({callbackFunc = function(timer)
			self.isComposing = false;
			self.StopAnim();
			
			--兑换
			commonlib.echo("========before extend icehouse in BuidingWorkshop");
			ItemManager.ExtendedCost(167, nil, nil, function(msg) 
				log("+++++++ Get_30006_IceHouse return: +++++++\n")
				commonlib.echo(msg);
				NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
				local s = [[<div style='float:left;margin-left:15px;margin-top:20px;text-align:center'>你已经拥有一座冰雪小屋了。<br/>每人只能拥有一座冰雪小屋，回家看看吧。</div>]];
				_guihelper.Custom_MessageBox(s,function(result)
						if(result == _guihelper.DialogResult.OK)then
								commonlib.echo("OK");
						end
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			end);
		end})
	end
	self.isComposing = true;
	self.timer:Change(2000,nil);
	self.PlayAnim();
end
function BuidingWorkshop.PlayAnim()
	local self = BuidingWorkshop;
	local player = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30153)
	local animation_file = "character/v5/06quest/BulidingCar/BulidingCar_anim.x";
	if(player and player:IsValid() and animation_file)then
		Map3DSystem.Animation.PlayAnimationFile(animation_file, player);
	else
		commonlib.echo("can't find npc 30153");
	end
end
function BuidingWorkshop.StopAnim()
	local self = BuidingWorkshop;
	local player = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30153);
	local animation_file = "";
	if(player and player:IsValid())then
		Map3DSystem.Animation.PlayAnimationFile("", player);
	else
		commonlib.echo("can't find npc 30153");
	end
end