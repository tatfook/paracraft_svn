--[[
Title: Flag Game
Author(s): LXZ  for leio
Date: 2010/1/30
Desc:家园抢旗子的游戏，可以有些细节，使之操作性和乐趣更强。
[概述] 可以是6面旗帜， 类似7色花， 统计时间。 可以按照旗子编号顺序拾取（标准分），也可以不按（最小分），
分别是两种得分。 
1. 开始只显示1面， 拾取后， 启动类似7色花的UI（多一个重新记时按钮）， 3D场景中显示出另外5面的位置。 
2. 编辑状态下，显示6面，位置根据NID随机。 
3. 挑战者的奖励和完成时间（标准分）挂钩， 这样标准分用654321，然后Shift才是最快的；
   最小分要选择合理的次序，善用跳跃和Shift配合才行。 挑战者拿到第一面时有一个基本奖励。 
4. 创造者只要别人拿到第一面时就可以给奖励。 其他的奖励属于挑战者额外的收获。 
5. 6面都拿到，完成时间<30并且刷新个人最好成绩的人， 自动在家族系统中发消息：XXX挑战了XXX的家园用时XX秒。 
   如果创造者在线， 发IM信息给创造者， 创造者只显示当时收到过的最新的标准分/最小分的IM通知。 
   这样创造者可以个人组织一些挑战和颁奖活动

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Homeland/FlagGame/FlagGame.lua");

MyCompany.Aries.Homeland.FlagGame.BeginGame()
MyCompany.Aries.Homeland.FlagGame.EndGame()
------------------------------------------------------------
]]

local FlagGame = commonlib.gettable("MyCompany.Aries.Homeland.FlagGame");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

-- current flags for nid. 
local flags = {
	-- {x = 0,y = 0,z = 0, touch_time = 0, is_touched = false},
	-- {x = 0,y = 1,z = 0, touch_time = 0, is_touched = false},
}

-- this is called when homeland is loaded. 
-- @param nid: string of user nid. it is used as the random seed to generate all the flag positions. So that different users are different. 
--    if nil, it is the current user nid. 
function FlagGame.BeginGame(nid)
	nid = nid or System.User.nid;
	FlagGame.GenerateFlags(nid)
	FlagGame.ShowFlags(1);
end

-- this is called when homeland is unloaded. 
function FlagGame.EndGame()
	FlagGame.ShowFlags(0);
end

-- this is called when user hit a flag in the homeland. 
-- this is called in flag NPC on perception callbacks. 
-- @param nFlagIndex: flag index that the user touched
function FlagGame.OnHitFlag(nFlagIndex)
	-- TODO:
	local bIsEditMode = false;
	if(bIsEditMode) then
		return;
	end
	local flag = flags[nFlagIndex];
	if(not flag) then
		commonlib.log("warning: no flag is found for %d\n", nFlagIndex)
		return
	end
	
	flag.is_touched = true;
	
	-- TODO: hide the flag in the scene, since it is touched. 
	
	if(nFlagIndex == 1) then
		flag.rewarded = true
		-- TODO: given reward if not
		-- all other flags if not. 
		-- FlagGame.ShowFlags();
	else
		
	end
end

-- we should restart timing all over again. 
function FlagGame.OnRestartTiming()
	
end

-- show NPC flags in the scene for a given nid
-- @param count: how many flags to show. it can be 0 to hide all flags, 1 to display the first flag or nil to display all of them. 
function FlagGame.ShowFlags(count)
	count = count or #flags;
	local nFlagIndex, flag
	for nFlagIndex, flag in ipairs(flags) do
		if(nFlagIndex <= nFlagIndex) then
			-- show the flag NPC
			-- TODO: 
		else
			-- hide the flag NPC
			-- TODO: 
		end
	end
end

-- generate flags for a given nid
-- @param nid: string of user nid. it is used as the random seed to generate all the flag positions. So that different users are different. 
function FlagGame.GenerateFlags(nid)
	local nid = tonumber(nid);
	if(not nid) then
		commonlib.applog("invalid nid");
		return
	end
	
	flags = {};
	local nFlagCount = 6;
	
	-- TODO: generate 6 flags using nid as random seed. 
end