--[[
Title: HomeLandError
Author(s): Leio
Date: 2009/5/6
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandError.lua");
------------------------------------------------------------
]]
local HomeLandError = {
	
}
commonlib.setfield("Map3DSystem.App.HomeLand.HomeLandError",HomeLandError);
--一般情况
HomeLandError[1] = {error = "值为空！"}
HomeLandError[2] = {error = "没有权限！"}
-- 坐骑驾驭情况
HomeLandError[1001] = {error = "抱抱龙现在力气太小了，等它长到5级的时候，才可以背着你兜风哦！"} -- 现在还不够级别，不能驾驭！
HomeLandError[1002] = {error = "现在已经是驾驭状态了！"}
HomeLandError[1003] = {error = "现在你在自己的家园中，不能驾驭！"}
HomeLandError[1004] = {error = "现在你在别人的家园中，不能驾驭！"}
HomeLandError[1005] = {error = "只有在健康的情况下，才能驾驭！"}
-- 坐骑跟随情况
HomeLandError[2001] = {error = "现在已经是跟随状态了！"}
HomeLandError[2002] = {error = "你的抱抱龙已经死亡了，不能再跟着你了！快回家看看它吧！！"}
-- 坐骑送回家情况
HomeLandError[3001] = {error = "现在已经在家了！"}
--喂食情况
HomeLandError[4001] = {error = "没有生病，不需要吃药！"}
HomeLandError[4002] = {error = "没有死亡，不需要复活！"}
HomeLandError[4003] = {error = "生病或者死亡了，不能使用物品！"}--废弃了
HomeLandError[4004] = {error = "坐骑现在不饿！"}
HomeLandError[4005] = {error = "坐骑现在不脏！"}
HomeLandError[4006] = {error = "坐骑现在不郁闷！"}
HomeLandError[4007] = {error = "坐骑已经死亡了！"}
HomeLandError[4008] = {error = "体力值>=300！"}
HomeLandError[4009] = {error = "清洁值>=300！"}
HomeLandError[4010] = {error = "心情值>=300！"}
function HomeLandError.ShowInfo(info)
	if(not info or info == "")then
		info = "未知错误！";
	end
	_guihelper.MessageBox(info);
end
