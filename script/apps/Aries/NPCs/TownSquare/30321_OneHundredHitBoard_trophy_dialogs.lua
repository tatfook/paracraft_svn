--[[
Title: Score page for the snow shooting game 
Author(s): LiXizhi
Date: 2009/12/21
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30321_OneHundredHitBoard_trophy_dialogs.lua");

-- call this to submit a new score to server. 
MyCompany.Aries.Quest.NPCs.OneHundredHitBoard.SubmitScore()
-- 
MyCompany.Aries.Quest.NPCs.OneHundredHitBoard.OnHitOther();
MyCompany.Aries.Quest.NPCs.OneHundredHitBoard.OnHitByOther();
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30321_OneHundredHitBoard_page.lua");

-- create class
local OneHundredHitBoard = commonlib.gettable("MyCompany.Aries.Quest.NPCs.OneHundredHitBoard");

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function OneHundredHitBoard.Trophy_PreDialog()
	return true;
end

OneHundredHitBoard.ItemMap = {
[30322] = {text = "我是象征着荣誉的百发百中银杯，分数达到100的小哈奇，才能带我回家！", gsid=30073, item_name="百发百中银杯", isCup=true, score=100},
[30323] = {text = "我是象征着荣誉的百发百中金杯，分数达到500的小哈奇，才能带我回家！", gsid=30074, item_name="百发百中金杯", isCup=true, score=500},
[30324] = {text = "我是象征着荣誉的百发百中钻杯，分数达到1000的小哈奇，才能带我回家！", gsid=30075, item_name="百发百中钻杯", isCup=true, score=1000},
[30325] = {text = "我是冰块，给我20朵雪绒花，我就和你回家！", exid=155, gsid=17040, item_name="冰块", bag_name="家园仓库",flowers=20},
[30326] = {text = "我是冰雪栅栏，给我40朵雪绒花，我就和你回家！", exid=156, gsid=30077, item_name="冰雪栅栏", bag_name="家园仓库",flowers=40},
[30327] = {text = "我是冰晶树，给我60朵雪绒花，我就和你回家！", exid=157, gsid=30078, item_name="冰晶树", bag_name="家园仓库",flowers=60},
[30328] = {text = "我是冰晶烛台，给我200朵雪绒花，我就和你回家！", exid=158, gsid=30079, item_name="冰晶烛台", bag_name="家园仓库",flowers=200},

[30329] = {text = "我是精英投手服，给我100朵雪绒花，我就和你回家！", exid=163, gsid=1111, is_unique=true, item_name="精英投手服", bag_name="背包", flowers=100},
[30330] = {text = "我是精英投手裤，给我80朵雪绒花，我就和你回家！", exid=164, gsid=1112, is_unique=true, item_name="精英投手裤", bag_name="背包",flowers=80},
[30331] = {text = "我是精英投手靴，给我100朵雪绒花，我就和你回家！", exid=165, gsid=1113, is_unique=true, item_name="精英投手靴", bag_name="背包",flowers=100},
[30332] = {text = "我是精英投手手套，给我100朵雪绒花，我就和你回家！", exid=166, gsid=1114, is_unique=true, item_name="精英投手手套", bag_name="背包",flowers=80},

[30333] = {text = "我是精英红妆服，给我100朵雪绒花，我就和你回家！", exid=159, gsid=1107, is_unique=true, item_name="精英红妆服", bag_name="背包",flowers=100},
[30334] = {text = "我是精英红妆短裤，给我80朵雪绒花，我就和你回家！", exid=160, gsid=1108, is_unique=true, item_name="精英红妆短裤", bag_name="背包",flowers=80},
[30335] = {text = "我是精英红妆靴，给我100朵雪绒花，我就和你回家！", exid=161, gsid=1109, is_unique=true, item_name="精英红妆靴", bag_name="背包",flowers=100},
[30336] = {text = "我是精英红妆手套，给我100朵雪绒花，我就和你回家！", exid=162, gsid=1110, is_unique=true, item_name="精英红妆手套", bag_name="背包",flowers=80},
}

local gsid_snow_flower = 50208;

function OneHundredHitBoard.HasEnoughFlower(npc_id)
	local npc = OneHundredHitBoard.ItemMap[npc_id];
	if(npc) then
		local bOwn, _, _, copies = hasGSItem(gsid_snow_flower);
		if(copies and copies>=(npc.flowers or 0)) then
			return true;
		end
	end	
end

function OneHundredHitBoard.HasEnoughScore(npc_id)
	local npc = OneHundredHitBoard.ItemMap[npc_id];
	if(npc) then
		if(OneHundredHitBoard.GetScore() >= (npc.score or 0)) then
			return true;
		end
	end	
end

function OneHundredHitBoard.DoGetCup(npc_id)
	local npc = OneHundredHitBoard.ItemMap[npc_id];
	if(npc and npc.gsid) then
		ItemManager.PurchaseItem(npc.gsid, 1, function(msg)
			end,
			function(msg) 
				OneHundredHitBoard.submitting = false;
				if(msg) then
					if(msg.issuccess == true) then
					end
				end
			end, nil, nil);
	end
end

function OneHundredHitBoard.DoGetItem(npc_id)
	local npc = OneHundredHitBoard.ItemMap[npc_id];
	if(npc and npc.exid) then
		-- extended cost 
		ItemManager.ExtendedCost(npc.exid, nil, nil, function(msg) end, function(msg)
			log("+++++++ExtendedCost "..npc.exid..": OneHundredHitBoard.DoGetItem return: +++++++\n")
			if(msg.issuccess) then
				-- _guihelper.MessageBox(string.format([[<div style="margin-top:24px;margin-left:10px;">恭喜你，成功获得了1个“%s”字气球，放在你家园的仓库里了，有空记得摆出来哦！</div>]], text));
			end
		end);
	end
end

