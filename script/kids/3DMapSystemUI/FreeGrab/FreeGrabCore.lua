--[[
Title: FreeGrabCore
Author(s): Leio
Date: 2009/7/31
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/FreeGrab/FreeGrabCore.lua");
local grab = Map3DSystem.App.FreeGrab.FreeGrabCore:new();
grab:Start();
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/Storyboard/Storyboard.lua");
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");
NPL.load("(gl)script/ide/Display3D/AvatarQueue.lua");
NPL.load("(gl)script/ide/Display/Util/ObjectsCreator.lua");
local FreeGrabCore ={
	levels = {
		"Texture/Aries/MiniGame/FreeGrab/a.txt",
		"Texture/Aries/MiniGame/FreeGrab/b.txt",
		"Texture/Aries/MiniGame/FreeGrab/a.txt",
	},
	timerID = 12537,
	default_snapshot = "Texture/Aries/MiniGame/FreeGrab/default_snapshot.png",
	default_play_mode = "walk",--"walk" or "drive"	
	default_driver_model = "character/v3/PurpleDragonMajor/Female/PurpleDragonMajorFemale.xml",	--默认被驾驭的模型
	default_world_path = "worlds/MyWorlds/0920_homeland",
	default_born_origin = {x = 19965, y = 29.836856842041, z = 20312},--默认出生的位置
	default_coin_origin = {x = 19965, y = 29.836856842041, z = 20312},--默认coin的原点
	play_effect_duration = "00:00:01",-- 播放效果的时间
	
	default_hitest_box = {offset_x = 2,offset_y = 2,offset_z = 2,},--默认热区范围
	default_golden_model = "model/06props/v3/headarrow.x",
	default_golden_particle = "model/07effect/v5/Firecracker/Firecracker1.x",
	default_golden_worth = 20,
	
	default_silver_model = "model/06props/v3/headexclaimed.x",
	default_silver_particle = "model/07effect/v5/Firecracker/Firecracker1.x",
	default_silver_worth = 10,
	
	default_clock_model = "model/06props/v3/headquest.x",
	default_clock_particle = "model/07effect/v5/WaterBalloon/WaterBalloon1.x",
	default_clock_worth = 5,
	
	default_total_time = 60000,--毫秒，默认一关游戏的时间
	default_update_duration = 50,--毫秒，刷新周期
	default_ready_time = 4000,--毫秒，准备开始的时间
	
	curLevel = 1,
	maxLevel = 1,
	allLevelDescriptor = nil,--所有关数的描述
	curLevelDescriptor = nil,--当前关的描述
	curLevelNodes = nil,--当前关的nodes
	goldenScore = 0,--击中的数量	
	silverScore = 0,	
	clockScore = 0,	
	isStart = false,--是否开始
	isReadyStart = false,--是否预备开始
	curLevelTime = 0,--当前关游戏运行的时间
	curReadyTime = 0,--当前等待进入时间
	
	avatar_queue = nil,
	entityContainer = nil,--coin 容器
	playEffectContainer = nil,--播放效果的容器
	rootContainer = nil,
	curLevel_Dec = nil,--当前关的描述
	--event
	TimeOverFunc = nil,--这一关的时间到
	GameStartFunc = nil,--这一关游戏开始
	GameReadyUpdateFunc = nil,--准备开始，倒数更新阶段
	GameUpdateFunc = nil,--游戏更新阶段
}  
commonlib.setfield("Map3DSystem.App.FreeGrab.FreeGrabCore",FreeGrabCore);
function FreeGrabCore:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self;
	o:OnInit();
	return o
end
function FreeGrabCore:OnInit()
	local name = ParaGlobal.GenerateUniqueID();
	self.name = name;
	CommonCtrl.AddControl(name,self);

	self.allLevelDescriptor = {};
	
	--加载所有关数的描述
	self:LoadAllLevelDescriptor()
	

	local scene = CommonCtrl.Display3D.SceneManager:new();
	--rootContainer
	self.rootContainer = CommonCtrl.Display3D.SceneNode:new{
		root_scene = scene,
	}
	--entityContainer
	self.entityContainer = CommonCtrl.Display3D.SceneNode:new{
		node_type = "container",
	};
	self.rootContainer:AddChild(self.entityContainer);
	--playEffectContainer
	self.playEffectContainer = CommonCtrl.Display3D.SceneNode:new{
		node_type = "container",
	};
	self.rootContainer:AddChild(self.playEffectContainer);
	
	
end
function FreeGrabCore:SetLevel(value)
	if(value >0 and value <= self.maxLevel)then
		self.curLevel = value;
		return true;
	end
end
--返回当前关游戏的总时间
function FreeGrabCore:GetCurLevelTotalTime()
	local d = self:GetCurLevelDescriptor();
	if(d)then
		return d.total_time;
	end
end
--返回当前关的描述
function FreeGrabCore:GetCurLevelDescriptor()
	if(not self.curLevel_Dec)then
		local d = self.allLevelDescriptor[self.curLevel];
		self.curLevel_Dec = commonlib.deepcopy(d);
	end
	return self.curLevel_Dec;
end
function FreeGrabCore:GetAllLevelDescriptor()
	return self.allLevelDescriptor;
end
--加载所有关数的描述
function FreeGrabCore:LoadAllLevelDescriptor()
	if(self.levels)then
		local k,path;
		for k,path in ipairs(self.levels) do
			local r = self:LoadSingleLevelDescriptor(path);
			if(r)then
				r.level_index = tostring(k);
				table.insert(self.allLevelDescriptor,r);
			end
		end
		--记录总共关数的数量
		self.maxLevel = #self.allLevelDescriptor;
		return self.allLevelDescriptor;
	end
end
--加载某一关的所有内容的描述
--[[
--游戏关数的描述
	levelDescriptor = {
		{
		world_path = nil,
		born_origin = nil,
		coin_origin = nil,
		play_mode = nil,
		driver_model = nil,--被驾驭的模型，如果play_mode = "drive"
		coin_nodes = {
			{
				entity_node = nil,
				type = "golden",--"golden" or "silver" or "clock"
				x = 0,
				y = 0,
				z = 0,
			},
		},
		snapshot = nil,
		golden_model = nil,
		golden_particle = nil,
		golden_worth = nil,
		
		silver_model = nil,
		silver_particle = nil,
		silver_worth = nil,
		
		clock_model = nil,
		clock_particle = nil,
		clock_worth = nil,
		
		total_time = nil,
		
		level_index = nil,
		},
	}
--]]
function FreeGrabCore:LoadSingleLevelDescriptor(path)
	if(not path or path == "")then return end
	local r = commonlib.LoadTableFromFile(path);
	if(r and type(r)=="table")then
		r.world_path = r.world_path or self.default_world_path;
		r.born_origin = r.born_origin or self.default_born_origin;
		r.coin_origin = r.coin_origin or self.default_coin_origin;
		r.play_mode = r.play_mode or self.default_play_mode;
		r.driver_model = r.driver_model or self.default_driver_model;
		
		r.golden_model = r.golden_model or self.default_golden_model;
		r.golden_particle = r.golden_particle or self.default_golden_particle;
		r.golden_worth = r.golden_worth or self.default_golden_worth;
		
		r.silver_model = r.silver_model or self.default_silver_model;
		r.silver_particle = r.silver_particle or self.default_silver_particle;
		r.silver_worth = r.silver_worth or self.default_silver_worth;
		
		r.clock_model = r.clock_model or self.default_clock_model;
		r.clock_particle = r.clock_particle or self.default_clock_particle;
		r.clock_worth = r.clock_worth or self.default_clock_worth;
		
		r.total_time = r.total_time or self.default_total_time;
		r.snapshot = r.snapshot or self.default_snapshot;
		
		if(r.coin_nodes)then
			local k,node;
			for k,node in ipairs(r.coin_nodes) do
				node.x = node.x + r.coin_origin.x;
				node.y = node.y + r.coin_origin.y;
				node.z = node.z + r.coin_origin.z;
			end
		end
		return r;
	end
end
function FreeGrabCore:Start()
	self:ReStart();
end
function FreeGrabCore:ReStart()
	--原来的描述
	self.curLevel_Dec = nil;
	local cur_descriptor = self:GetCurLevelDescriptor();
	if(cur_descriptor)then
		local worldpath = cur_descriptor.world_path;
		local born_origin = cur_descriptor.born_origin;
		local play_mode = cur_descriptor.play_mode;
		local driver_model = cur_descriptor.driver_model;
		
		self.playEffectContainer:ClearAllChildren();
		self.entityContainer:ClearAllChildren();
		-- 加载场景	
		local commandName = System.App.Commands.GetDefaultCommand("LoadWorld");
		System.App.Commands.Call(commandName, {worldpath = worldpath});
		self:Stop();
		local sec = self.default_update_duration/1000
		NPL.SetTimer(self.timerID, sec, string.format(";Map3DSystem.App.FreeGrab.FreeGrabCore.Update('%s');",self.name));
		--创建当前关的coin
		self:BuildAllNodes();
		
		local x,y,z = born_origin.x,born_origin.y,born_origin.z;
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x= tonumber(x) or 20000, z=tonumber(z) or 20000});
		-- 角色队列
		if(self.avatar_queue)then
			self.avatar_queue:ClearAllChildren();
			self.avatar_queue:Stop();
		end
		self.avatar_queue = CommonCtrl.Display3D.AvatarQueue:new();
		--如果是开车
		if(play_mode == "drive")then
			local drive_node = CommonCtrl.Display3D.SceneNode:new{
				x = 0,
				y = 0,
				z = 0,
				old_x = 0,
				old_y = 0,
				old_z = 0,
				assetfile = driver_model,
				ischaracter = true,
				update_with_character = false,
			};
			self.avatar_queue:AddChild(drive_node);
			self.avatar_queue:Start();
			self.avatar_queue:ControlByPlayer();
			self.avatar_queue:MountOn(drive_node);
		else
			self.avatar_queue:Start();
			self.avatar_queue:ControlByPlayer();
		end
		self.curLevelTime = 0;
		self.curReadyTime = 0;
		self.isReadyStart = true;
		self.isStart = false;
		
		
	end
end
function FreeGrabCore:Pause()
	if(self.isStart)then
		self.isStart = false;
	else
		self.isStart = true;
	end
end
function FreeGrabCore:Stop()
	NPL.KillTimer(self.timerID);
end
function FreeGrabCore.Update(sName)
	local self = CommonCtrl.GetControl(sName);
	if(self)then
		if(self.isStart)then
			local total_time = self:GetCurLevelTotalTime();
			self.curLevelTime = self.curLevelTime + self.default_update_duration;
			if(self.curLevelTime >= total_time)then
				if(self.TimeOverFunc)then
					self.TimeOverFunc(self);
				end
				--停止游戏
				self.isStart = false;
				self.isReadyStart = false;
			else
				
			end
		end
		if(self.isReadyStart)then
			self.curReadyTime = self.curReadyTime + self.default_update_duration;
			
			if(self.curReadyTime >= self.default_ready_time)then
				--游戏开始
				self.isStart = true;
				self.isReadyStart = false;
				if(self.GameStartFunc)then
					self.GameStartFunc(self);
				end
			else
				self:GameReadyUpdateHandle()
			end
		end
		self:UpdateHandle();
	end
end
function FreeGrabCore:GameReadyUpdateHandle()
	if(self.GameReadyUpdateFunc)then
		local msg = {};
		msg.cur_step = math.floor(self.curReadyTime/1000);
		msg.total_step = math.floor(self.default_ready_time/1000);
		self.GameReadyUpdateFunc(self,msg);
	end
end
function FreeGrabCore:UpdateHandle()
	local des = self:GetCurLevelDescriptor();
	if(not des or not des.coin_nodes)then return end
	local nodes = des.coin_nodes;
	local point;
	local actived_node = self.avatar_queue.actived_node;
	if(actived_node)then
		point = {
			x = actived_node.x,
			y = actived_node.y,
			z = actived_node.z,
		}
	end
	if(nodes and point)then
		local k,node;
		for k,node in ipairs(nodes) do
			local type = node.type;
			local x,y,z = node.x,node.y,node.z;
			local hitest_box = self.default_hitest_box;
			local box = {};
			box.pos_x = x;
			box.pos_y = y;
			box.pos_z = z;
			box.obb_x = hitest_box.offset_x;
			box.obb_y = hitest_box.offset_y;
			box.obb_z = hitest_box.offset_z;
			local result = CommonCtrl.Display.Util.ObjectsCreator.Contains(point,box)	
			if(result)then
				if(type == "golden")then
					self.goldenScore = self.goldenScore + 1;
				elseif(type == "silver")then
					self.silverScore = self.silverScore + 1;
				elseif(type == "clock")then
					--TODO:增加时间
					self.clockScore = self.clockScore + 1;
				end
				table.remove(nodes,k);
				self:DestroyNode(node);
				break;
			end
		end
	end
	if(self.GameUpdateFunc)then
		local msg = {};
		msg.cur_time = self.curLevelTime;
		msg.total_time = self:GetCurLevelTotalTime();
		msg.level = self.curLevel;
		msg.goldenScore = self.goldenScore;
		msg.silverScore = self.silverScore;	
		msg.clockScore = self.clockScore;
		msg.single_golden_worth = des.golden_worth;
		msg.single_silver_worth = des.silver_worth;
		msg.single_clock_worth = des.clock_worth;
		self.GameUpdateFunc(self,msg);
	end
end
function FreeGrabCore:BuildAllNodes()
	if(not self.entityContainer)then return end
	local des = self:GetCurLevelDescriptor();
	if(not des or not des.coin_nodes)then return end
	local nodes = des.coin_nodes;
	
	self.entityContainer:ClearAllChildren();
	local coin_origin = des.coin_origin;
	if(des and nodes)then
		local k,node;
		for k,node in ipairs(nodes) do
			local assetfile;
			local type = node.type;
			if(type == "golden")then
				assetfile = des.golden_model;
			elseif(type == "silver")then
				assetfile = des.silver_model;
			elseif(type == "clock")then
				assetfile = des.clock_model;
			end
			local entity_node = CommonCtrl.Display3D.SceneNode:new{
				x = node.x,
				y = node.y,
				z = node.z,
				assetfile = assetfile,
			};
			--hook a entity_node
			node.entity_node = entity_node;
			self.entityContainer:AddChild(entity_node);
		end
	end
end
function FreeGrabCore:DestroyNode(node)
	if(not node)then return end
	local des = self:GetCurLevelDescriptor();
	local entity_node = node.entity_node;
	entity_node:Detach();
	local type = node.type;
	if(self.playEffectContainer)then
		local assetfile;
		local x,y,z = node.x,node.y,node.z;
		if(type == "golden")then
			assetfile = des.golden_particle;
		elseif(type == "silver")then
			assetfile = des.silver_particle;
		elseif(type == "clock")then
			assetfile = des.clock_particle;
		end
		
		local effect_node = CommonCtrl.Display3D.SceneNode:new{
				x = x,
				y = y,
				z = z,
				assetfile = assetfile,
			};
		self.playEffectContainer:AddChild(effect_node);
		NPL.load("(gl)script/ide/Storyboard/TimeSpan.lua");
		local frame = CommonCtrl.Storyboard.TimeSpan.GetFrames(self.play_effect_duration);
		local storyboard = CommonCtrl.Storyboard.Storyboard:new();
		
		storyboard:SetDuration(frame);
		storyboard.OnPlay = function(s)
			
		end
		storyboard.OnUpdate = function(s)
			--local x,y,z = effect_node:GetPosition();
			--effect_node:SetPosition(x,y,z);
			--commonlib.echo({s._frame,frame});
		end
		storyboard.OnEnd = function(s)
			effect_node:Detach();
		end
		storyboard:Play();
	end
end