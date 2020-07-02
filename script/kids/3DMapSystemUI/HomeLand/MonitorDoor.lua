--[[
Title: MonitorDoor
Author(s): Leio
Date: 2009/6/15
Desc:
监听的类型有两种
"comein": 监听室外通往室内的入口
在家园中，它的每一个位置是不同的
--
"comeout": 监听室内通往室外的入口
在家园中，它的位置都是相同的
--
逻辑：
在室外，开放所有的"comein"
进入室内，只开放一个"comeout"
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/MonitorDoor.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
NPL.load("(gl)script/ide/Display/Util/ObjectsCreator.lua");
local MonitorDoor = {
	name = "MonitorDoor_instance",
	timerInterval = 3000,
	holder = nil,
	nodes = {},
	pause = false,
	Beep = nil,
}
commonlib.setfield("Map3DSystem.App.HomeLand.MonitorDoor",MonitorDoor);
function MonitorDoor.Init(holder)
	local self = MonitorDoor;
	self.Clear();
	self.holder = holder;
	local timerInterval = Map3DSystem.App.HomeLand.HomeLandConfig.EntryMonitorInterval or self.timerInterval;
	
	NPL.load("(gl)script/ide/timer.lua");
	MonitorDoor.timer = MonitorDoor.timer or commonlib.Timer:new({callbackFunc = MonitorDoor.OnEnterFrame});
	MonitorDoor.timer:Change(timerInterval, timerInterval);
end
function MonitorDoor.Clear()
	local self = MonitorDoor;
	self.nodes = {};
end
function MonitorDoor.Register(node,box)
	local self = MonitorDoor;
	self.nodes[node] = box;
end
function MonitorDoor.UnRegister(node,box)
	local self = MonitorDoor;
	self.nodes[node] = nil;
end
function MonitorDoor.Destroy()
	local self = MonitorDoor;
	if(MonitorDoor.timer) then
		MonitorDoor.timer:Change()
	end
	self.holder = nil;
	self.pause = false;
	self.nodes = {};
end
function MonitorDoor.Pause()
	local self = MonitorDoor;
	self.pause = true;
end
function MonitorDoor.Resume()
	local self = MonitorDoor;
	self.pause = false;
end
-- 残废所有的监听
function MonitorDoor.DisableAllNode()
	local self = MonitorDoor;
	local node,box;
	for node,box in pairs(self.nodes) do
		node.enable = false;
	end
end
-- 恢复室外所有的监听
function MonitorDoor.EnableOutdoorNode()
	local self = MonitorDoor;
	local node,box;
	for node,box in pairs(self.nodes) do
		if(node.type == "comein")then
			node.enable = true;
		end
	end
end
-- 恢复其中一个监听，其它都残废
function MonitorDoor.EnableANode(_node)
	if(not _node)then return end
	local self = MonitorDoor;
	self.DisableAllNode();
	local node,box;
	for node,box in pairs(self.nodes) do
		if(node == _node)then
			node.enable = true;
			break;
		end
	end
end
function MonitorDoor.OnEnterFrame()
	local self = MonitorDoor;
	if(self.pause)then return end
	local node,box;
	local px, py, pz = ParaScene.GetPlayer():GetPosition(); 
	local point = {x = px, y = py, z = pz};
	for node,box in pairs(self.nodes) do
		if(node.enable)then
			if(box)then
				local result = CommonCtrl.Display.Util.ObjectsCreator.Contains(point,box);
				if(result)then
					if(self.Beep)then
						self.Beep(self.holder,node);
					end
				end
			end
		end
	end
end