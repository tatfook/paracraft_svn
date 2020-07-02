--[[
Title: CheerBalloon
Author(s): WangTian
Date: 2009/8/20

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30302_7CheerBalloon.lua
------------------------------------------------------------
]]

-- create class
local libName = "CheerBalloon";
local CheerBalloon = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.CheerBalloon", CheerBalloon);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

--17016_CheerCard_Ha
--17017_CheerCard_Qi
--17018_CheerCard_Xiao
--17019_CheerCard_Zhen
--17020_CheerCard_Huan
--17021_CheerCard_Ying
--17022_CheerCard_Ni

--30043_CheerBalloon_Ha
--30044_CheerBalloon_Qi
--30045_CheerBalloon_Xiao
--30046_CheerBalloon_Zhen
--30047_CheerBalloon_Huan
--30048_CheerBalloon_Ying
--30049_CheerBalloon_Ni

--17023_CheerCard_Sheng
--17024_CheerCard_Dan
--17025_CheerCard_Bing
--17026_CheerCard_Xue
--17027_CheerCard_Le
--17028_CheerCard_Jie


-- CheerBalloon.main
function CheerBalloon.main()
end

-- CheerBalloon timer
function CheerBalloon.On_Timer()
end

local texts = {"哈", "奇", "小", "镇", "欢", "迎", "你"};

-- predialog function of 7 different balloons

function CheerBalloon.PreDialog_Ha()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30302);
	memory.dialog_state = 1;
	return true;
end

function CheerBalloon.PreDialog_Qi()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30302);
	memory.dialog_state = 2;
	return true;
end

function CheerBalloon.PreDialog_Xiao()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30302);
	memory.dialog_state = 3;
	return true;
end

function CheerBalloon.PreDialog_Zhen()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30302);
	memory.dialog_state = 4;
	return true;
end

function CheerBalloon.PreDialog_Huan()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30302);
	memory.dialog_state = 5;
	return true;
end

function CheerBalloon.PreDialog_Ying()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30302);
	memory.dialog_state = 6;
	return true;
end

function CheerBalloon.PreDialog_Ni()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30302);
	memory.dialog_state = 7;
	return true;
end

function CheerBalloon.TryExchange(index)
	local require_gsid = 17016 + index - 1;
	local text = texts[index];
	local exid = 94 + index - 1;
	
	local bHas, guid, __, copies = hasGSItem(require_gsid, 12);
	if(bHas and copies >= 2) then
		-- extended cost CheerBalloon
		ItemManager.ExtendedCost(exid, guid..",2|", {12}, function(msg)end, function(msg)
			log("+++++++ExtendedCost "..exid..": Get_CheerBalloon return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess) then
				_guihelper.MessageBox(string.format([[<div style="margin-top:24px;margin-left:10px;">恭喜你，成功获得了1个“%s”字气球，放在你家园的仓库里了，有空记得摆出来哦！</div>]], text));
			end
		end);
	else
		_guihelper.MessageBox([[<div style="margin-top:24px;margin-left:5px;width:300px;">你还没有收集到贺卡呢，收集齐了再来找我吧！贺卡会现在七彩泡泡机掉落的礼盒里哦！</div>]]);
	end
	
end
