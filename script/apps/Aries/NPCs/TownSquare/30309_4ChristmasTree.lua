--[[
Title: ChristmasTree
Author(s): WangTian
Date: 2009/8/20

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30309_4ChristmasTree.lua
------------------------------------------------------------
]]

-- create class
local libName = "ChristmasTree";
local ChristmasTree = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.ChristmasTree", ChristmasTree);

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

--30054_ChristmasTree_Kuai
--30055_ChristmasTree_Le
--30056_ChristmasTree_Sheng
--30057_ChristmasTree_Dan
--30058_WellBarrel
--30059_IceHeartTalk
--30060_IceGiftBox

--17023_CheerCard_Xin
--17024_CheerCard_Nian
--17025_CheerCard_Kuai
--17026_CheerCard_Le


-- ChristmasTree.main
function ChristmasTree.main()
end

-- ChristmasTree timer
function ChristmasTree.On_Timer()
end

--local texts = {"圣诞树“快”", "圣诞树“乐”", "圣诞树“圣”", "圣诞树“诞”", "古井木桶", "冰雕心语", "冰雕礼盒"};
local texts = {"圣诞树“新”", "圣诞树“年”", "圣诞树“快”", "圣诞树“乐”", "古井木桶", "冰雕心语", "冰雕礼盒"};

-- predialog function of 7 different objects

function ChristmasTree.PreDialog_Kuai()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30309);
	--memory.dialog_state = 1;
	memory.dialog_state = 3;
	return true;
end

function ChristmasTree.PreDialog_Le()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30309);
	--memory.dialog_state = 2;
	memory.dialog_state = 4;
	return true;
end

function ChristmasTree.PreDialog_Xin()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30309);
	memory.dialog_state = 1;
	return true;
end

function ChristmasTree.PreDialog_Nian()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30309);
	memory.dialog_state = 2;
	return true;
end

function ChristmasTree.PreDialog_Sheng()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30309);
	memory.dialog_state = 3;
	return true;
end

function ChristmasTree.PreDialog_Dan()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30309);
	memory.dialog_state = 4;
	return true;
end

function ChristmasTree.PreDialog_WellBarrel()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30309);
	memory.dialog_state = 5;
	return true;
end

function ChristmasTree.PreDialog_IceHeartTalk()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30309);
	memory.dialog_state = 6;
	return true;
end

function ChristmasTree.PreDialog_IceGiftBox()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30309);
	memory.dialog_state = 7;
	return true;
end

-- 669 Get_30190_ChristmasTree_Xin 
-- 670 Get_30191_ChristmasTree_Nian 
-- 671 Get_30054_ChristmasTree_Kuai 
-- 672 Get_30055_ChristmasTree_Le 

function ChristmasTree.TryExchange(index)
	local text = texts[index];
	local require_gsid = 17016 + index - 1;
	local exid = 133 + index - 1;
	
	if(index >= 1 and index <= 4) then
		-- NOTE: new cards and tree reward
		require_gsid = 17023 + index - 1;
		exid = 669 + index - 1;
	end
	
	local bHas, guid, __, copies = hasGSItem(require_gsid, 12);
	if(index >= 1 and index <= 4 and bHas and copies >= 2) then
		-- extended cost ChristmasTree
		ItemManager.ExtendedCost(exid, guid..",2|", {12}, function(msg) end, function(msg)
			log("+++++++ExtendedCost "..exid..": Get_ChristmasTree1 return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess) then
				_guihelper.MessageBox(string.format([[<div style="margin-top:24px;margin-left:10px;">恭喜你，成功获得了1个%s，放在你家园的仓库里了，有空记得摆出来哦！</div>]], text));
			end
		end);
	elseif(index >= 5 and index <= 7 and bHas and copies >= 3) then
		-- extended cost ChristmasTree
		ItemManager.ExtendedCost(exid, guid..",3|", {12}, function(msg)end, function(msg)
			log("+++++++ExtendedCost "..exid..": Get_ChristmasTree2 return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess) then
				_guihelper.MessageBox(string.format([[<div style="margin-top:24px;margin-left:10px;">恭喜你，成功获得了1个%s，放在你家园的仓库里了，有空记得摆出来哦！</div>]], text));
			end
		end);
	else
		_guihelper.MessageBox([[<div style="margin-top:24px;margin-left:5px;width:300px;">你还没有收集到贺卡呢，收集齐了再来找我吧！贺卡会现在七彩泡泡机掉落的礼盒里哦！</div>]]);
	end
end