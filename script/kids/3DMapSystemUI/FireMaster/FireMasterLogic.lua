--[[
Title: FireMasterLogic
Author(s): Leio
Date: 2009/7/31
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/FireMaster/FireMasterLogic.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display2D/Rectangle2D.lua");
NPL.load("(gl)script/ide/Storyboard/Storyboard.lua");
NPL.load("(gl)script/ide/Storyboard/TimeSpan.lua");
local FireMasterLogic ={
	root_offset = {dx = 0, dy = 0},
	hole_mask = {w = 128, h = 172 },
	holemap = {
		--{ x = 592,y = 201},
		{ x = 686,y = 236},
		{ x = 456,y = 220},
		{ x = 552,y = 269},
		{ x = 295,y = 257},
		{ x = 701,y = 329},
		{ x = 518,y = 389},
		{ x = 212,y = 348},
		{ x = 249,y = 450},
		{ x = 717,y = 463},
		{ x = 493,y = 491},
	},
	bg = {x = 0, y = 0, w = 1020, h = 680,texture = "Texture/Aries/MiniGame/FireMaster/bg_2.png;0 0 1020 680",},
	bg_mask = {x = 0, y = 0, w = 1020, h = 680,texture = "Texture/Aries/MiniGame/FireMaster/mask.png;0 0 1020 680",},
	egg = {x = 0, y = 0, w = 128, h = 172,texture = "Texture/Aries/MiniGame/FireMaster/egg.png;0 0 128 138",},
	egg_hited = {x = 0, y = 0, w = 128, h = 172,texture = "Texture/Aries/MiniGame/FireMaster/egg.png;128 0 128 138",},
	firemaster = {x = 0, y = 0, w = 128, h = 172,texture = "Texture/Aries/MiniGame/FireMaster/firemaster.png;0 0 128 138",},
	firemaster_hited = {x = 0, y = 0, w = 128, h = 172,texture = "Texture/Aries/MiniGame/FireMaster/firemaster.png;128 0 128 138",},

	particle = {x = 0, y = 0, w = 461, h = 119,texture = "Texture/Aries/MiniGame/FireMaster/onhit_effect/onhit_effect_01.png;",},
	qidou = {x = 0, y = 0, w = 334, h = 336,texture = "Texture/Aries/MiniGame/FireMaster/others/qidou.png",},
	zhu = {x = 0, y = 0, w = 248, h = 232,texture = "Texture/Aries/MiniGame/FireMaster/others/huolingzhu.png",},
	
	sinker_up = {x = 0, y = 0, w = 270, h = 223,texture = "Texture/Aries/MiniGame/FireMaster/sinker_1.png;0 0 270 223",},
	sinker_down = {x = 0, y = 0, w = 270, h = 223,texture = "Texture/Aries/MiniGame/FireMaster/sinker_2.png;0 0 270 223",},
	sinker_disabled = {x = 0, y = 0, w = 270, h = 223,texture = "Texture/Aries/MiniGame/FireMaster/sinker_3.png;0 0 270 223",},
	close = {x = 0, y = 0, w = 54, h = 54,texture = "Texture/Aries/Common/Close_Big_54_32bits.png#0 0 54 54",},
	
	max_hit_rect = {offset_x = 0, offset_y = -150, w = 128, h = 150},--角色最大热区
	max_sinker_hit_rect = {offset_x = 0, offset_y = -20,w = 96, h = 20},--锤子最大热区
	max_translation = {x = 0, y = 138 },
	
	--------------------------------------------
	max_tollgate = 1,--最大关卡数
	cur_tollgate = 1,--当前关卡
	
	duration_step = 50,
	made_node_step = 20,
	min_blackout_duration = 1000,--最小中断时间，毫秒
	max_blackout_duration = 3000,--最大中断时间，毫秒
	blackout_duration = 1000,--中断时间，毫秒,默认值为最小值，递增
	
	min_at_top_duration = 800,--最小在顶端停留的时间
	max_at_top_duration = 5000,--最大在顶端停留的时间
	at_top_duration = 5000,--在顶端停留的时间,默认值为最大值，递减
	
	min_made_child_duration = 500,--最小产生对象的周期
	max_made_child_duration = 1500,--最大产生对象的周期
	made_child_duration = 1500,--产生对象的周期,默认值为最大值，递减
	
	min_shownum = 4,--最少一次触发显示node的数量
	max_shownum = 8,--最多一次触发显示node的数量
	shownum = 4,--一次触发显示node的数量,默认值为最小值，递增
	
	min_tollgate_duration = 5000,--最小每一关持续的时间
	max_tollgate_duration = 60000,--最长每一关持续的时间
	tollgate_duration = 60000,--每一关持续的时间,默认值为最大值，递减
	
	min_eggshowPercent = 20,--最小出现egg的几率
	max_eggshowPercent = 100,--最大出现egg的几率
	eggshowPercent = 20,--出现egg的几率,默认值为最小值，递增
	--------------------------------------------
	hited_duration = 5000,--被击中后持续显示的时间
	update_duration = 50,--刷新周期
	show_speed = 25,--显示的速度
	debug = false,--是否是debug状态
	getbean_percent = 99,--产生奇豆概率
	getzhu_percent = 99,--产生火龙珠概率
	
	configPath = "Texture/Aries/MiniGame/FireMaster/config.txt",
	cur_score = 0,--击中数量
	cur_score_bean = 0,--获得奇豆数量
	cur_score_zhu = 0,--获得或龙珠数量
	cur_tollgate_runtime = 0,--当前运行的时间
	now_blackout_time = 0,--中断持续的时间的计数器
	now_time = 0,--运行时间的计数器
	max_time = 100,--达到后now_time = 0
	timerID = 65434,
	isStart = false,
	isBlackout = false,--是否被中断
	
	sprite_list = nil,
	animators = nil,
	activedNodes = nil,
	
	--装角色的容器
	sprite = nil,
	--击中的粒子效果的容器
	particle_sprite = nil,
	--装鼠标的容器
	cursor_sprite = nil,
	
	OnMsg = nil,
	
}  
commonlib.setfield("Map3DSystem.App.FireMaster.FireMasterLogic",FireMasterLogic);
function FireMasterLogic:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self;
	o:OnInit();
	return o
end
function FireMasterLogic:OnInit()
	local name = ParaGlobal.GenerateUniqueID();
	self.name = name;
	CommonCtrl.AddControl(name,self);
	self:Load();
	self:Reset();
end
function FireMasterLogic:Load()
	local config = commonlib.LoadTableFromFile(self.configPath);
	if(config)then
		local k,v;
		for k,v in pairs(config) do
			self[k] = v;
		end
	end
end
function FireMasterLogic:InitSprite(sprite)
	if(not sprite)then return end
	self.sprite = sprite;
	self.sprite_list = {};
	local k,v;
	for k,v in ipairs(self.holemap) do
		local w,h = self.hole_mask.w,self.hole_mask.h;
		local left,top,width,height = (v.x - w * 0.5),(v.y - h),w,h;
		local _this = ParaUI.CreateUIObject("container", self.name..k, "_lt", left,top,width,height);
		--_this.fastrender = false;
		_this.background = "";
		self.sprite:AddChild(_this);
		self.sprite_list[k] = _this;
	end
end
function FireMasterLogic:BuildNode(basic_x,basic_y,index)
	local node = {      basic_x = basic_x,
						basic_y = basic_y,
						at_top_time = 0,--达到最大位移后，目前等待的计数器，如果超过最大等待时间，产生相反方向的位移
						show_hited_time = 0,--被击中后，持续显示的计数器
						now_state = "at_bottom",--现在的状态 "at_bottom" or "moving" or "at_top"
						move_direction = -1,--初始是向上移动
						isActived = false,--是否被激活，激活后开始产生运动
						isBinded = false,--是否已经绑定一个可视化的对象
						bindedSprite = nil,--绑定一个可视化的对象
						hited = false,
						identity = "firemaster",--"firemaster" or"egg"
						dx = 0,
						dy = 0,--相对位移，初始的时候，先移动到最下方
						--dy = self.hole_mask.h,--相对位移，初始的时候，先移动到最下方
						x = 0,--绝对坐标
						y = 0,
						w = 0,
						h = 0,
						hole_index = index,--在哪个洞里面
					};
	
	return node;
end
function FireMasterLogic:Start()
	if(not self.isStart)then
		self.isStart = true;
		local sec = self.update_duration/1000
		NPL.SetTimer(self.timerID, sec, string.format(";Map3DSystem.App.FireMaster.FireMasterLogic.Update('%s');",self.name));
		self:CreateActivedNodes();
		self:SetGameVar();
		if(self.cursor_sprite)then
			self.cursor_sprite.visible = true;
		end
	end
end
function FireMasterLogic:Pause()
	if(self.isStart)then
		self.isStart = false;
	else
		self.isStart = true;
	end
end
function FireMasterLogic:Stop()
	NPL.KillTimer(self.timerID);
	self:StopAllEffect();
	self:Reset();
end
function FireMasterLogic:NextLevel()
	if(self.cur_tollgate < self.max_tollgate )then
		self.cur_tollgate = self.cur_tollgate + 1;
		self.isStart = true;
		--self:SetGameVar();
	end
end
function FireMasterLogic:SetGameVar()
	if(self.cur_tollgate > 0 and self.cur_tollgate < self.max_tollgate)then
		--中断时间 递增
		if(self.blackout_duration < self.max_blackout_duration)then
			self.blackout_duration = self.blackout_duration + self.duration_step;
		else
			self.blackout_duration = self.max_blackout_duration;
		end
		--在顶端停留的时间 递减
		if(self.at_top_duration >= self.min_at_top_duration)then
			self.at_top_duration = self.at_top_duration - self.duration_step;
		else
			self.at_top_duration = self.min_at_top_duration;
		end
		--产生对象的周期  递减
		if(self.made_child_duration >= self.min_made_child_duration)then
			self.made_child_duration = self.made_child_duration - self.duration_step;
		else
			self.made_child_duration = self.min_made_child_duration;
		end
		
		--每一关持续的时间   递减
		if(self.tollgate_duration >= self.min_tollgate_duration)then
			self.tollgate_duration = self.tollgate_duration - self.duration_step;
		else
			self.tollgate_duration = self.min_tollgate_duration;
		end
		--出现egg的几率  递增
		if(self.eggshowPercent < self.max_eggshowPercent)then
			self.eggshowPercent = self.eggshowPercent + 1;
		else
			self.eggshowPercent = self.max_eggshowPercent;
		end
		--一次触发显示node的数量
		local step = math.floor(self.cur_tollgate/(self.made_node_step or 20));
		self.shownum = self.min_shownum + step;
		if(self.shownum > self.max_shownum)then
			self.shownum = self.max_shownum;
		end
		local s = string.format("关数：%d \n 中断时间:%d \n 在顶端停留的时间:%d \n 产生对象的周期:%d \n 每一关持续的时间:%d \n 出现egg的几率:%d \n 一次触发显示node的数量:%d \n",
						self.cur_tollgate,
						self.blackout_duration,
						self.at_top_duration,
						self.made_child_duration,
						self.tollgate_duration,
						self.eggshowPercent,
						self.shownum);
		commonlib.echo(s);
	end
end
--进度监听
function FireMasterLogic:ProgressMonitor()
	local game_state;
	if(self.cur_tollgate_runtime > self.tollgate_duration)then
		--time over
		--已达到最后一关
		if(self.cur_tollgate >= self.max_tollgate)then
			game_state = "timeover_gameover";
		else	
			game_state = "timeover";
			
		end
		self:Reset();
	end
	local msg = {
			game_state = game_state,--游戏状态
			cur_score = self.cur_score,--积分
			cur_score_bean = self.cur_score_bean,
			cur_score_zhu = self.cur_score_zhu,
			cur_tollgate = self.cur_tollgate,--当前关卡
			cur_tollgate_runtime = self.cur_tollgate_runtime,
			tollgate_duration = self.tollgate_duration,
		}
	if(self.OnMsg)then
		self.OnMsg(msg);
	end
	self.cur_tollgate_runtime = self.cur_tollgate_runtime + self.update_duration;
end
function FireMasterLogic:ClearSprite()
	if(self.animators)then
		local k,node;
		for k,node in ipairs(self.animators) do
			self:ResetNode(node);
		end
	end
end
--重置
function FireMasterLogic:Reset()
	self.isStart = false;
	self.isBlackout = false;
	self.now_time = 0;
	self.now_blackout_time = 0;
	
	self.cur_tollgate_runtime = 0;
	
	self:ClearSprite();
	--初始化动画单元
	self.animators = {};
	local k,v;
	for k,v in ipairs(self.holemap) do
		local node = self:BuildNode(v.x,v.y,k);
		table.insert(self.animators,node);
	end
	--已经被激活的nodes
	self.activedNodes = {};
	--self:ClearSprite();
	if(self.cursor_sprite)then
		self.cursor_sprite.x = self.bg.w - self.sinker_up.w;
		self.cursor_sprite.y = self.bg.h - self.sinker_up.h;
		self.cursor_sprite.background = self.sinker_up.texture;
	end
	--TODO:显示鼠标
end
function FireMasterLogic:CreateActivedNodes()
	local nodes = self:GetNodes();
	if(nodes)then
		local k,node;
		for k,node in ipairs(nodes) do
			table.insert(self.activedNodes,node);
		end
	end		
	local compareFunc = CommonCtrl.TreeNode.GenerateGreaterCFByField("hole_index");
	table.sort(self.activedNodes, compareFunc)
end
function FireMasterLogic.Update(sName)
	local self = CommonCtrl.GetControl(sName);
	if(self)then
		if(self.isStart)then
			--一直更新时间计数器
			self.now_time = self.now_time + 1;
			local time = self.now_time * self.update_duration;
			--如果没有被冲断
			if(not self.isBlackout)then
				if(time >= self.made_child_duration)then
					--	产生新的node
					self:CreateActivedNodes();
					self.now_time = 0;
				end
			else
				--更新中断的时间计数器
				self.now_blackout_time = self.now_blackout_time + 1;
				local time = self.now_blackout_time * self.update_duration;
				--如果达到中断的总时间
				if(time >= self.blackout_duration)then
					self.now_blackout_time = 0;
					self.isBlackout = false;
					--恢复鼠标正常显示
					if(self.cursor_sprite)then
						self.cursor_sprite.background = self.sinker_up.texture;
					end
				end	
			end
			self:UpdateActivedNodes();
			if(self.now_time > self.max_time)then
				self.now_time = 0;
			end
			self:ProgressMonitor();
		end
	end
	
end
function FireMasterLogic:UpdateActivedNodes()
	local k,node;
	for k,node in ipairs(self.activedNodes) do
		if(node and node.isActived)then
			self:UpdateNode(node);
			
			--如果没有被击中
			if(not node.hited)then
				local now_state = node.now_state;
				if(now_state == "at_bottom")then
					node.move_direction = -1;
					node.now_state = "moving";
					local identity = node.identity;
					if(identity == "egg")then
						self:Effect_Egg_Up(node);
					else
						self:Effect_Master_Up(node);
					end
				end
				if(node.now_state == "moving")then
					node.dy = node.dy + self.show_speed * node.move_direction;
				end
				--如果在最上面
				if(node.dy < 0 and node.move_direction == -1)then
					--如果是向上移动
						node.now_state = "at_top";
						node.at_top_time = node.at_top_time + 1;
						local time = node.at_top_time * self.update_duration;
						if(time >= self.at_top_duration)then
							node.at_top_time = 0;
							--改变移动方向
							node.move_direction = 1;
							node.now_state = "moving";
							if(identity == "egg")then
								self:Effect_Egg_Down(node);
							else
								self:Effect_Master_Down(node);
							end
						end	
					
				elseif(node.dy > self.max_translation.y and node.move_direction == 1)then
					--已经在最下方
					self:ResetNode(node);
				end
			else
				--如果被击中
				 node.show_hited_time = node.show_hited_time + 1;
				 local time = node.show_hited_time * self.update_duration;
				 if(time >= self.hited_duration)then
					--重置
					self:ResetNode(node);
					node.show_hited_time = 0;
				end	
			end
		end
	end
end
function FireMasterLogic:UpdateNode(node)
	if(not node)then return end
	local isBinded = node.isBinded;
	if(not isBinded)then
		--创建可视化对象
		local identity = node.identity;
		local info;
		if(identity == "egg")then
			info = self.egg;
		else
			info = self.firemaster;
		end
		node.w = info.w;
		node.h = info.h;
		node.x = node.dx + self.root_offset.x;
		node.y = node.dy + self.root_offset.y;
		node.isBinded = true;
		
		local left,top,width,height = node.x,node.y,node.w,node.h;
		local _this = ParaUI.CreateUIObject("container", self.name..node.hole_index, "_lt", left,top,width,height);
		_this.background = "";
		--_this.background = info.texture;
		node.bindedSprite = _this;
		local parent_sprite = self.sprite_list[node.hole_index];
		if(parent_sprite)then
			parent_sprite:AddChild(_this);
		end
	end
	
	local bindedSprite = node.bindedSprite;
	if(bindedSprite)then
		local x,y,texture;
		x = node.dx;
		y = node.dy;
		local info;
		local identity = node.identity;
		--如果没有被击中
		if(not node.hited)then
			if(identity == "egg")then
				info = self.egg;
			else
				info = self.firemaster;
			end
		else
			if(identity == "egg")then
				info = self.egg_hited;
			else
				info = self.firemaster_hited;
			end
			bindedSprite.background = "";
		end
		texture = info.texture;
		--bindedSprite.x = x;
		--bindedSprite.y = y;
		--local bg = bindedSprite.background
		--if(bg ~= texture)then
			--bindedSprite.background = texture;
		--end
	end
	self:DrawHitRect(node);
	--self:DrawMovingRect(node);
	
end
function FireMasterLogic:ResetNode(node)
	if(not node)then return end
	local bindedSprite = node.bindedSprite;
	if(bindedSprite)then
		-- destroy
		ParaUI.Destroy(self.name..node.hole_index);
	end
	if(self.activedNodes)then
		for k,child in ipairs(self.activedNodes) do
			if(node == child)then
				table.remove(self.activedNodes,k);
				break;
			end
		end
	end
	node.basic_x = node.basic_x;
	node.basic_y = node.basic_y;
	node.at_top_time = 0;--达到最大位移后，目前等待的计数器，如果超过最大等待时间，产生相反方向的位移
	node.show_hited_time = 0;--被击中后，持续显示的计数器
	node.now_state = "at_bottom";--现在的状态 "at_bottom" or "moving" or "at_top"
	node.move_direction = -1;--初始是向上移动
	node.isActived = false;--是否被激活，激活后开始产生运动
	node.isBinded = false;--是否已经绑定一个可视化的对象
	node.bindedSprite = nil;--绑定一个可视化的对象
	node.hited = false;
	node.identity = "firemaster";--"firemaster" or"egg"
	node.dx = 0;
	node.dy = 0;--相对位移
	--node.dy = self.hole_mask.h;--相对位移
	node.x = 0;--绝对坐标
	node.y = 0;
	node.w = 0;
	node.h = 0;
	node.hole_index = node.hole_index;
	node.up_effect = nil;--往上运动的mc
	node.down_effect = nil;--往下运动的mc
	node.hit_effect = nil;--被击中的mc
end
--随机找多个将要被激活的对象
function FireMasterLogic:GetNodes()
	local total = math.random(1,self.shownum);
	local k;
	local result = {};
	for k = 1,total do
		local node = self:GetNextNode();
		if(node)then
			node.isActived = true;
			table.insert(result,node);
		end
	end
	return result;
end
--随机找一个将要被激活的对象
function FireMasterLogic:GetNextNode()
	local result = {};
	local k,v;
	for k,v in ipairs(self.animators) do
		if(not v.isActived)then
			table.insert(result,v);
		end
	end
	local len = #result;
	local egg_random = math.random(1,100);
	local identity;
	--根据一定的几率生成不同类型的对象
	if(egg_random < self.eggshowPercent)then
		identity = "egg";
	else
		identity = "firemaster";
	end
	if(len > 0)then	
		local index = math.random(1,len);
		local node = result[index];
		node.identity = identity;
		return node;
	end
end
function FireMasterLogic:DoHitNode(point)
	local node,sinker_rect = self:GetActivedNodeByPoint(point);
	if(node and node.now_state == "at_top" and not node.hited)then	
		--如果角色热区和锤子热区相交
			node.hited = true;
			local identity = node.identity;
			if(identity == "egg")then
				self.isBlackout = true;
				self:UpdateNode(node)
				self.cursor_sprite.background = self.sinker_disabled.texture;
			else
				self.cur_score = self.cur_score + 1;
				local p = math.random(1,100);
				if( p < 50 )then
					local pp = math.random(self.getbean_percent,100);
					if(pp <= self.getbean_percent)then
						self.cur_score_bean = self.cur_score_bean + 1;
						self:Effect_GetBean_GetZhu(node,sinker_rect,"bean")
					end
				else
					local pp = math.random(self.getzhu_percent,100);
					if(pp <= self.getzhu_percent)then
						self.cur_score_zhu = self.cur_score_zhu + 1;
						self:Effect_GetBean_GetZhu(node,sinker_rect,"zhu")
					end
				end
			end
			if(identity == "egg")then
				self:Effect_Egg_OnHit(node);
			else
				self:Effect_Master_OnHit(node);
			end
			self:Effect_Hit(node,sinker_rect);
	end
end
function FireMasterLogic:GetActivedNodeByPoint(point)
	if(not point or not self.activedNodes)then return end
	local sinker_rect = self:GetSinkerHitRect(point);
	self:DrawSinkerHitRect(sinker_rect);
	local k,node;
	for k,node in ipairs(self.activedNodes) do
		local rect = self:GetNodeHitRect(node);
		--如果角色热区和锤子热区相交
		if(rect and sinker_rect and rect:Intersects(sinker_rect))then
			return node,sinker_rect;
		end
	end
end
function FireMasterLogic:GetNodeHitRect(node)
	if(not node)then return end
	--绝对坐标
		--local x = node.basic_x + (-node.w * 0.5 ) + node.x + node.dx;
		--local y = node.basic_y + (-node.h) + node.y + node.dy;
		--local rect = CommonCtrl.Display2D.Rectangle2D:new{
			--x = x + self.max_hit_rect.offset_x,
			--y = y + self.max_hit_rect.offset_y,
			--width = self.max_hit_rect.w,
			--height = self.max_hit_rect.h,
		--}
		local x = node.basic_x + (-node.w * 0.5 ) + node.x + node.dx;
		local y = node.basic_y  + node.y + node.dy;
		local rect = CommonCtrl.Display2D.Rectangle2D:new{
			x = x + self.max_hit_rect.offset_x,
			y = y + self.max_hit_rect.offset_y,
			width = self.max_hit_rect.w,
			height = self.max_hit_rect.h,
		}
	return rect;
end
function FireMasterLogic:DrawSinkerHitRect(rect)
	if(not rect)then return end
	if(self.debug)then
		local name = self.name.."sinker";
		ParaUI.Destroy(name);
		local left,top,width,height = rect:GetLTWH();
		local _this = ParaUI.CreateUIObject("container", name, "_lt", left,top,width,height);
		self.sprite:AddChild(_this);
	end
end
function FireMasterLogic:DrawMovingRect(node)
	if(self.debug)then
		local name = self.name..node.hole_index.."DrawMovingRect";
		ParaUI.Destroy(name);
		local rect = self:GetNodeHitRect(node);
		local x,y,width,height = rect:GetLTWH();
		local left,top,width,height = x + node.dx, y + node.dy,node.w,node.h;
		local _this = ParaUI.CreateUIObject("container", name, "_lt", left,top,width,height);
		self.sprite:AddChild(_this);
	end
end
function FireMasterLogic:DrawHitRect(node)
	if(self.debug)then
		local rect = self:GetNodeHitRect(node);
		local name = self.name..node.hole_index.."draw";
		ParaUI.Destroy(name);
		if(rect and node.now_state == "at_top")then
			local left,top,width,height = rect:GetLTWH();
			local _this = ParaUI.CreateUIObject("container", name, "_lt", left,top,width,height);
			self.sprite:AddChild(_this);
		end
	end
end
function FireMasterLogic:DoMouseUp()
	if(not self.isBlackout)then
		if(self.cursor_sprite)then
			self.cursor_sprite.background = self.sinker_up.texture;
		end
	end
end
function FireMasterLogic:DoMouseDwon(point)
	if(not self.isBlackout)then
		if(self.cursor_sprite)then
			self.cursor_sprite.background = self.sinker_down.texture;
		end
		self:DoHitNode(point);
	end
end
function FireMasterLogic:DoMouseMove(point)
	if(not point)then return end
	if(self.cursor_sprite)then
		if(not self.isBlackout)then
			self.cursor_sprite.x = point.x - self.sinker_up.w * 0.5;
			self.cursor_sprite.y = point.y - self.sinker_up.h * 0.5;
		end
	end
end
--获取锤子热区
--point 是鼠标坐标
function FireMasterLogic:GetSinkerHitRect(point)
	local x = point.x - self.sinker_up.w * 0.5;
	local y = point.y + self.sinker_up.h * 0.5;
	local rect = CommonCtrl.Display2D.Rectangle2D:new{
			x = x + self.max_sinker_hit_rect.offset_x,
			y = y + self.max_sinker_hit_rect.offset_y,
			width = self.max_sinker_hit_rect.w,
			height = self.max_sinker_hit_rect.h,
		}
	return rect;
end
function FireMasterLogic:Effect_Master_Up(node)
	if(not node)then return end
	local identity = node.identity;
	if(identity == "egg")then
		return 
	end
	if(node.down_effect)then
		node.down_effect:End();
		node.down_effect = nil;
	end
	local hole_index = node.hole_index;
	local parent = self.sprite_list[hole_index];
	if(not parent)then return end
	local name = "Effect_Master_Up"..hole_index;
	local _this = ParaUI.CreateUIObject("container", name, "_lt", node.x,node.y,node.w,node.h);
	_this.background = "Texture/Aries/MiniGame/FireMaster/master_anim/master_anim_01.png";
	local id = _this.id;
	parent:AddChild(_this);
	
	local frame = CommonCtrl.Storyboard.TimeSpan.GetFrames("00:00:05");
	local storyboard = CommonCtrl.Storyboard.Storyboard:new();
	storyboard:SetDuration(frame);
	node.up_effect = storyboard;
	storyboard.OnPlay = function(s)
					
	end
	storyboard.OnUpdate = function(s)
		if(s)then
			local cur_frame = s:GetCurFrame();
			local step = 10;
			local frame = 0;
			local k;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,1,id);
			
			frame = frame + 2;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,2,id);
			frame = frame + 2;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,3,id);
			frame = frame + 2;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,5,id);
			
			frame = frame + step;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,6,id);
			frame = frame + step;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,7,id);
			frame = frame + step;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,6,id);
			frame = frame + step;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,7,id);
		end		
	end
	storyboard.OnEnd = function(s)
		ParaUI.Destroy(name);		
	end
	storyboard:Play();
end
function FireMasterLogic:Effect_Master_Down(node)
	if(not node)then return end
	local identity = node.identity;
	if(identity == "egg")then
		return 
	end
	local hole_index = node.hole_index;
	if(node.up_effect)then
		node.up_effect:End();
		node.up_effect = nil;
	end
	
	local parent = self.sprite_list[hole_index];
	if(not parent)then return end
	local name = "Effect_Master_Down"..hole_index;
	local _this = ParaUI.CreateUIObject("container", name, "_lt", node.x,node.y,node.w,node.h);
	local id = _this.id;
	_this.background = "Texture/Aries/MiniGame/FireMaster/master_anim/master_anim_07.png";
	parent:AddChild(_this);
	
	local frame = CommonCtrl.Storyboard.TimeSpan.GetFrames("00:00:00.5");
	local storyboard = CommonCtrl.Storyboard.Storyboard:new();
	storyboard:SetDuration(frame);
	node.down_effect = storyboard;
	storyboard.OnPlay = function(s)
					
	end
	storyboard.OnUpdate = function(s)
		if(s)then
			local cur_frame = s:GetCurFrame();
			local frame = 0;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,7,id);
			
			frame = frame + 2;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,3,id);
			frame = frame + 2;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,2,id);
			frame = frame + 1;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,1,id);
			frame = frame + 1;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,-1,id);
		end		
	end
	storyboard.OnEnd = function(s)
		ParaUI.Destroy(name);		
	end
	storyboard:Play();
end
function FireMasterLogic:Effect_Master_Up_ChangeBG(frame,cur_frame,index,id)
	if(type(id) ~= "number")then
		return 
	end
	local _this = ParaUI.GetUIObject(id);
	if(not _this:IsValid())then return end
	if(frame == cur_frame)then
		local s ;
		if(index == -1)then
			s = "";
		elseif(index > 0 and index < 10)then
			s = string.format("Texture/Aries/MiniGame/FireMaster/master_anim/master_anim_0%d.png",index);
		else
			s =  string.format("Texture/Aries/MiniGame/FireMaster/master_anim/master_anim_%d.png",index);
		end
		_this.background = s;
	end
end
function FireMasterLogic:Effect_Hit_ChangeBG(frame,cur_frame,index,id)
	if(type(id) ~= "number")then
		return 
	end
	local _this = ParaUI.GetUIObject(id);
	if(not _this:IsValid())then return end
	if(frame == cur_frame)then
		local s ;
		if(index == -1)then
			s = "";
		elseif(index > 0 and index < 10)then
			s = string.format("Texture/Aries/MiniGame/FireMaster/onhit_effect/onhit_effect_0%d.png",index);
		else
			s =  string.format("Texture/Aries/MiniGame/FireMaster/onhit_effect/onhit_effect_%d.png",index);
		end
		_this.background = s;
	end
end
function FireMasterLogic:Effect_Master_OnHit(node)
	if(not node)then return end
	local identity = node.identity;
	if(identity == "egg")then
		return 
	end
	local hole_index = node.hole_index;
	if(node.up_effect)then
		node.up_effect:End();
		node.up_effect = nil;
	end
	if(node.down_effect)then
		node.down_effect:End();
		node.down_effect = nil;
	end

	local parent = self.sprite_list[hole_index];
	if(not parent)then return end
	local name = "Effect_Master_OnHit"..hole_index;
	local _this = ParaUI.CreateUIObject("container", name, "_lt", node.x,node.y,node.w,node.h);
	local id = _this.id;
	_this.background = "Texture/Aries/MiniGame/FireMaster/master_anim/master_anim_09.png";
	parent:AddChild(_this);
	
	local frame = CommonCtrl.Storyboard.TimeSpan.GetFrames("00:00:01");
	local storyboard = CommonCtrl.Storyboard.Storyboard:new();
	storyboard:SetDuration(frame);
	node.hit_effect = storyboard;
	storyboard.OnPlay = function(s)
					
	end
	storyboard.OnUpdate = function(s)
		if(s)then
			local cur_frame = s:GetCurFrame();
			local frame = 0;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,9,id)
			frame = frame + 20;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,10,id)
			frame = frame + 2;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,11,id)
			frame = frame + 2;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,-1,id)
			
		end		
	end
	storyboard.OnEnd = function(s)
		ParaUI.Destroy(name);		
	end
	storyboard:Play();
end
function FireMasterLogic:Effect_Hit(node,sinker_rect)
	if(not node or not sinker_rect)then return end
	local hole_index = node.hole_index;
	local center = sinker_rect:GetCenter();
	
	local parent = self.particle_sprite;
	if(not parent)then return end
	local name = "Effect_Hit"..hole_index;
	local left,top,width,height = self.particle.x,self.particle.y,self.particle.w,self.particle.h;
	local _this = ParaUI.CreateUIObject("container", name, "_lt", left,top,width,height);
	local id = _this.id;
	_this.x = center.x - width/2;
	_this.y = center.y - height / 2;
	_this.background = "Texture/Aries/MiniGame/FireMaster/onhit_effect/onhit_effect_01.png";
	parent:AddChild(_this);
	
	local frame = CommonCtrl.Storyboard.TimeSpan.GetFrames("00:00:0.5");
	local storyboard = CommonCtrl.Storyboard.Storyboard:new();
	storyboard:SetDuration(frame);
	node.hit_effect = storyboard;
	storyboard.OnPlay = function(s)
					
	end
	storyboard.OnUpdate = function(s)
		if(s)then
			local cur_frame = s:GetCurFrame();
			local frame = 0;
			self:Effect_Hit_ChangeBG(frame,cur_frame,1,id)
			frame = frame + 2;
			self:Effect_Hit_ChangeBG(frame,cur_frame,2,id)
			frame = frame + 2;
			self:Effect_Hit_ChangeBG(frame,cur_frame,3,id)
			frame = frame + 2;
			self:Effect_Master_Up_ChangeBG(frame,cur_frame,-1,id)
			
		end		
	end
	storyboard.OnEnd = function(s)
		ParaUI.Destroy(name);		
	end
	storyboard:Play();
end
function FireMasterLogic:Effect_Egg_Up(node)
	if(not node)then return end
	local identity = node.identity;
	if(identity ~= "egg")then
		return 
	end
	if(node.down_effect)then
		node.down_effect:End();
		node.down_effect = nil;
	end
	local hole_index = node.hole_index;
	local parent = self.sprite_list[hole_index];
	if(not parent)then return end
	local name = "Effect_Egg_Up"..hole_index;
	local _this = ParaUI.CreateUIObject("container", name, "_lt", node.x,node.y,node.w,node.h);
	_this.background = "Texture/Aries/MiniGame/FireMaster/egg_anim/egg_anim_01.png";
	local id = _this.id;
	parent:AddChild(_this);
	
	local frame = CommonCtrl.Storyboard.TimeSpan.GetFrames("00:00:05");
	local storyboard = CommonCtrl.Storyboard.Storyboard:new();
	storyboard:SetDuration(frame);
	node.up_effect = storyboard;
	storyboard.OnPlay = function(s)
					
	end
	storyboard.OnUpdate = function(s)
		if(s)then
			local cur_frame = s:GetCurFrame();
			local step = 10;
			local frame = 0;
			local k;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,1,id);
			
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,2,id);
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,3,id);
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,4,id);
			
		end		
	end
	storyboard.OnEnd = function(s)
		ParaUI.Destroy(name);		
	end
	storyboard:Play();
end
function FireMasterLogic:Effect_Egg_Down(node)
	if(not node)then return end
	local identity = node.identity;
	if(identity ~= "egg")then
		return 
	end
	if(node.up_effect)then
		node.up_effect:End();
		node.up_effect = nil;
	end
	local hole_index = node.hole_index;
	local parent = self.sprite_list[hole_index];
	if(not parent)then return end
	local name = "Effect_Egg_Down"..hole_index;
	local _this = ParaUI.CreateUIObject("container", name, "_lt", node.x,node.y,node.w,node.h);
	_this.background = "Texture/Aries/MiniGame/FireMaster/egg_anim/egg_anim_04.png";
	local id = _this.id;
	parent:AddChild(_this);
	
	local frame = CommonCtrl.Storyboard.TimeSpan.GetFrames("00:00:01");
	local storyboard = CommonCtrl.Storyboard.Storyboard:new();
	storyboard:SetDuration(frame);
	node.up_effect = storyboard;
	storyboard.OnPlay = function(s)
					
	end
	storyboard.OnUpdate = function(s)
		if(s)then
			local cur_frame = s:GetCurFrame();
			local step = 10;
			local frame = 0;
			local k;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,4,id);
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,3,id);
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,2,id);
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,1,id);
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,-1,id);
			
		end		
	end
	storyboard.OnEnd = function(s)
		ParaUI.Destroy(name);		
	end
	storyboard:Play();
end
function FireMasterLogic:Effect_Egg_OnHit(node)
	if(not node)then return end
	local identity = node.identity;
	if(identity ~= "egg")then
		return 
	end
	local hole_index = node.hole_index;
	if(node.up_effect)then
		node.up_effect:End();
		node.up_effect = nil;
	end
	if(node.down_effect)then
		node.down_effect:End();
		node.down_effect = nil;
	end

	local parent = self.sprite_list[hole_index];
	if(not parent)then return end
	local name = "Effect_Egg_OnHit"..hole_index;
	local _this = ParaUI.CreateUIObject("container", name, "_lt", node.x,node.y,node.w,node.h);
	_this.background = "Texture/Aries/MiniGame/FireMaster/egg_anim/egg_anim_06.png";
	local id = _this.id;
	parent:AddChild(_this);
	
	local frame = CommonCtrl.Storyboard.TimeSpan.GetFrames("00:00:01");
	local storyboard = CommonCtrl.Storyboard.Storyboard:new();
	storyboard:SetDuration(frame);
	node.hit_effect = storyboard;
	storyboard.OnPlay = function(s)
					
	end
	storyboard.OnUpdate = function(s)
		if(s)then
			local cur_frame = s:GetCurFrame();
			local frame = 0;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,6,id)
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,5,id)
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,6,id)
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,5,id)
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,6,id)
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,5,id)
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,6,id)
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,5,id)
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,6,id)
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,5,id)
			frame = frame + 2;
			self:Effect_Egg_Up_ChangeBG(frame,cur_frame,-1,id)
			
		end		
	end
	storyboard.OnEnd = function(s)
		ParaUI.Destroy(name);		
	end
	storyboard:Play();
end
function FireMasterLogic:Effect_Egg_Up_ChangeBG(frame,cur_frame,index,id)
	if(type(id) ~= "number")then
		return 
	end
	local _this = ParaUI.GetUIObject(id);
	if(not _this:IsValid())then return end
	if(frame == cur_frame)then
		local s ;
		if(index == -1)then
			s = "";
		elseif(index > 0 and index < 10)then
			s = string.format("Texture/Aries/MiniGame/FireMaster/egg_anim/egg_anim_0%d.png",index);
		else
			s =  string.format("Texture/Aries/MiniGame/FireMaster/egg_anim/egg_anim_%d.png",index);
		end
		_this.background = s;
	end
end
function FireMasterLogic:Effect_GetBean_GetZhu(node,sinker_rect,type)
	if(not node or not sinker_rect)then return end
	local hole_index = node.hole_index;
	local center = sinker_rect:GetCenter();
	
	local info;
	local background;
	if(type == "bean")then
		background = "Texture/Aries/MiniGame/FireMaster/others/qidou.png";
		info = self.qidou;
	else	
		background = "Texture/Aries/MiniGame/FireMaster/others/huolingzhu.png";
		info = self.zhu
	end
	
	local parent = self.particle_sprite;
	if(not parent)then return end
	local name = "Effect_GetBean"..hole_index;
	local left,top,width,height = info.x,info.y,info.w,info.h;
	local _this = ParaUI.CreateUIObject("container", name, "_lt", left,top,width,height);
	_this.x = center.x - width/2;
	_this.y = center.y - height / 2;
	
	_this.background = background;
	parent:AddChild(_this);
	
	local frame = CommonCtrl.Storyboard.TimeSpan.GetFrames("00:00:0.5");
	local storyboard = CommonCtrl.Storyboard.Storyboard:new();
	storyboard:SetDuration(frame);
	node.getbean_effect = storyboard;
	storyboard.OnPlay = function(s)
					
	end
	storyboard.OnUpdate = function(s)
		if(s)then
			local cur_frame = s:GetCurFrame();
			_this.y = _this.y - 20;
			local alpha = 255 * (1 - cur_frame/frame);
			local c = string.format("255 255 255 %s",math.floor(alpha));
			_this.color = c;
		end		
	end
	storyboard.OnEnd = function(s)
		ParaUI.Destroy(name);		
	end
	storyboard:Play();
end
function FireMasterLogic:StopAllEffect()
	if(self.animators)then
		local k,node;
		for k,node in ipairs(self.animators) do
			if(node.up_effect)then
				node.up_effect:End();
				node.up_effect = nil;
			end
			if(node.down_effect)then
				node.down_effect:End();
				node.down_effect = nil;
			end
			if(node.hit_effect)then
				node.hit_effect:End();
				node.hit_effect = nil;
			end
		end
	end
end