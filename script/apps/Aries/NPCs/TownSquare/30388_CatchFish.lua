--[[
Title: CatchFish
Author(s): Leio
Date: 2009/12/7

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30388_CatchFish.lua");
MyCompany.Aries.Quest.NPCs.CatchFish.main();

NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30388_CatchFish.lua");
MyCompany.Aries.Quest.NPCs.CatchFish.MadeUI()


NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30388_CatchFish.lua");
MyCompany.Aries.Quest.NPCs.CatchFish.index = 1;
MyCompany.Aries.Quest.NPCs.CatchFish.CheckStart()

NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30388_CatchFish.lua");
MyCompany.Aries.Quest.NPCs.CatchFish.DoQuitInternal();

------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
NPL.load("(gl)script/apps/Aries/Player/ThrowBall.lua");
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30388_CatchFish_panel.lua");
local net_instance_id = 303881000;
local math_abs = math.abs;
--local net_assetfile = "model/06props/v5/03quest/HunterNet/HunterNet.x";
local net_assetfile = "model/02furniture/v5/FishingTerrace/Fishnet/Fishnet.x";
local fishing_place = {
	{ 20093.29296875, -2.9318652153015, 19470.2578125 , 1.7 },-- x y z facing
	{ 20073.515625, -2.9125950336456, 19472.685546875 , 1.4,},
	
	{ 20061.87890625, -2.8968651294708, 19464.47265625, 0.7, },
	{ 20054.408203125, -2.910210609436, 19457.22265625, 0.5, },
	
	{ 20051.462890625, -2.9307618141174, 19439.982421875, -0.2, },
	{ 20055.970703125, -2.9408488273621, 19431.634765625, -0.3},
	
	{ 20074.08203125, -2.9321601390839, 19419.224609375, -1.4, },
	{ 20084.41015625, -2.9666962623596, 19418.828125, -1.6, },
	
	{ 20107.953125, -2.9825241565704, 19426.041015625, -2.6 },
	{ 20114.341796875, -2.9810838699341, 19432.197265625, -2.6 },
	
	{ 20118.091796875, -2.941025018692, 19449.1796875, 3.1 },
	{ 20112.255859375, -2.9651646614075, 19457.923828125, 2.6 },
}
local fishing_camera_place = {
	{ 4.6585216522217, 0.45075422525406, 1.6421980857849 },
	{ 4.9963841438293, 0.36167815327644, 1.2303860187531 },
	
	{ 5.811306476593, 0.4308295249939, 0.66052639484406, },
	{ 5.811306476593, 0.42582964897156, 0.44052675366402, },
	
	{ 5.811306476593, 0.40582922101021, -0.22947193682194, },
	{ 5.4300646781921, 0.40549213933945, -0.2279558801651, },
	
	{ 6.6870584487915, 0.40541888809204, -1.4020676612854, },
	{ 6.6870584487915, 0.40541887974739, -1.6312549114227, },
	
	{ 6.6870584487915, 0.46041882038116, -2.5812540054321, },
	{ 6.7725095748901, 0.47566735744476, -2.64226770401, },
	
	{ 6.0952587127686, 0.46568277478218, 3.0508394241333, },
	{ 6.0952587127686, 0.48568272590637, 2.5876536369324, },
}
local fishing_out_place = {
	{ 20094.232421875, -2.7326126098633, 19477.87890625 },
	{ 20073.904296875, -2.7058854103088, 19480.31640625 },
	
	{ 20056.892578125, -2.699649810791, 19469.318359375, },
	{ 20049.1875, -2.6961634159088, 19462.25, },
	
	{ 20045.0234375, -2.6293604373932, 19436.607421875, },
	{ 20050.00390625, -2.6976418495178, 19427.947265625, },
	
	{ 20074.71484375, -2.7320473194122, 19412.1875, },
	{ 20083.96484375, -2.7120711803436, 19411.205078125, },
	
	{ 20112.70703125, -2.7230525016785, 19420.88671875, },
	{ 20119.92578125, -2.7138748168945, 19427.5390625, },
	
	{ 20123.373046875, -2.7055759429932, 19453.509765625, },
	{ 20118.291015625, -2.7025547027588, 19461.94921875, },
}
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
-- create class
local libName = "CatchFish";
local CatchFish = {
	index = nil,
	timer = nil,--检测用户是否到达一个钓鱼的范围
	correct_timer = nil,--矫正当用户占据一个钓鱼点的时候，没有收到开始游戏的响应，在一个周期内，恢复初始状态self.in_square = false;
	again_request_timer = nil,--如果站在一个钓鱼点不动，延缓请求时间
	anim_camera_timer = nil,--摄像机动画
	canStart = nil,
	hook_point = nil,--渔网漂浮的位置
	internalQuit = nil,--第一次请求连接成功后，有20秒的等待，如果没有任何响应认为用户自动退出internalQuit = true
	net_num = 0,--目前有多少个渔网
	fish_list = nil,--钓到的鱼
	
	container_x = 0,--绝对坐标
	container_y = 0,
	container_w = 960,
	container_h = 560,
	arrow_w = 256,
	arrow_h = 256,
	drag_btn_size = 54, 
	min_scaling = 0.3,
	strength = 1,
	radius = 3,
	throwTime = "00:00:02",
	autoFishTimer = nil, -- 自动捕鱼用到的定时器
	autoMode = false;

	 fishes = {
		[17106] = { label = "臭脚丫马靴", gsid = 17106, price = 0 ,},
		[17107] = { label = "胖乎乎水母", gsid = 17107, price = 10 ,},
		[17108] = { label = "小毛头泥鳅", gsid = 17108, price = 20 ,},
		[17109] = { label = "呆呆大头鱼", gsid = 17109, price = 30 ,},
		[17110] = { label = "大个头螃蟹", gsid = 17110, price = 50 ,},
		[17111] = { label = "闪闪皇冠鱼", gsid = 17111, price = 80 ,},
		[17288] = { label = "周年宝盒", gsid = 17288, price = 80 ,},
		[17534] = { label = "幸运钻石", gsid = 17534, price = 80 ,},
		[17548] = { label = "甜甜果冻", gsid = 17548, price = 80 ,},
	},
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.CatchFish", CatchFish);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
CatchFish.nets = {
	[17467] = { label = "普通捕鱼器", gsid = 17467, buy_net_exid = 1857, exid = 1854, absolutely_hit = true, net_assetfile = "model/02furniture/v5/FishingTerrace/Fishnet/Fishnet.x", },
	[17466] = { label = "精良捕鱼器", gsid = 17466, buy_net_exid = 1856, exid = 1853, absolutely_hit = true, net_assetfile = "model/02furniture/v5/FishingTerrace/Fishnet/Fishnet.x", },
	[17465] = { label = "卓越捕鱼器", gsid = 17465, buy_net_exid = 0, exid = 1852, absolutely_hit = true,  net_assetfile = "model/02furniture/v5/FishingTerrace/Fishnet/Fishnet.x", },
	[17113] = { label = "捕鱼网", gsid = 17113, buy_net_exid = 1576, exid = 1569, net_assetfile = "model/02furniture/v5/FishingTerrace/Fishnet/Fishnet.x", },
	[17346] = { label = "特大捕鱼网", gsid = 17346, buy_net_exid = 0, exid = 1645, absolutely_hit = true, net_assetfile = "model/02furniture/v5/FishingTerrace/Fishnet/Fishnet01.x", },
	[17347] = { label = "翻倍捕鱼网", gsid = 17347, buy_net_exid = 0, exid = 1605, net_assetfile = "model/02furniture/v5/FishingTerrace/Fishnet/Fishnet02.x", },
	[17348] = { label = "皇冠鱼专用网", gsid = 17348, buy_net_exid = 0, exid = 1606, net_assetfile = "model/02furniture/v5/FishingTerrace/Fishnet/Fishnet03.x", },
	[17349] = { label = "皇冠鱼必中网", gsid = 17349, buy_net_exid = 0, exid = 1646, absolutely_hit = true, net_assetfile = "model/02furniture/v5/FishingTerrace/Fishnet/Fishnet04.x", },
}
CatchFish.canAutoFishNets = {[17465] = true,[17466] = true,[17467] = true,};
CatchFish.selected_net_gsid = 17113;
--是否要删除上一次的渔网
CatchFish.last_net_gsid = nil;
function CatchFish.GetNetGsid()
	return CatchFish.selected_net_gsid or 17113;
end
function CatchFish.GetSelectedNetNode()
	return CatchFish.nets[CatchFish.GetNetGsid()];	
end
function CatchFish.GetNetAssetFile()
	return CatchFish.GetSelectedNetNode().net_assetfile;	
end
-- CatchFish.main
function CatchFish.main()
	if(not CatchFish.timer)then
		CatchFish.timer = commonlib.Timer:new({callbackFunc = function(timer)
			CatchFish.CheckDistance();
		end})
	end
	-- start the timer after 0 milliseconds, and signal every 1000 millisecond
	CatchFish.timer:Change(0, 1000)
	
	if(not CatchFish.correct_timer)then
		CatchFish.correct_timer = commonlib.Timer:new({callbackFunc = function(timer)
			CatchFish.RecoverState();
		end})
	end
	CatchFish.correct_timer:Change(0, 5000)
end

function CatchFish.PreDialog(npc_id, instance)
	local self = CatchFish;

end
--设置摄像机的位置
function CatchFish.DoCameraMotion(callbackFunc)
	local self = CatchFish;
	if(self.index)then
		local camera = fishing_camera_place[self.index];
		
		local att = ParaCamera.GetAttributeObject();
		NPL.load("(gl)script/ide/MotionView.lua");
		local firstnode = {
			CameraObjectDistance = att:GetField("CameraObjectDistance",5),
			CameraLiftupAngle = att:GetField("CameraLiftupAngle",0.4),
			CameraRotY = att:GetField("CameraRotY",0),
		};
		local nodes = {
			{ CameraObjectDistance = firstnode.CameraObjectDistance + 8, CameraLiftupAngle = firstnode.CameraLiftupAngle + 0.4, CameraRotY = firstnode.CameraRotY, duration = 500, motiontype = "easeInQuad"  },
			{ CameraObjectDistance = camera[1], CameraLiftupAngle = camera[2], CameraRotY = camera[3], duration = 500, motiontype = "easeOutQuad"  },
		}
		CommonCtrl.CameraMotionView.Start(nodes,true,function(node)
			if(node)then
				if(node.CameraObjectDistance)then
					att:SetField("CameraObjectDistance", node.CameraObjectDistance);
				end
				if(node.CameraLiftupAngle)then
					att:SetField("CameraLiftupAngle", node.CameraLiftupAngle);
				end
				if(node.CameraRotY)then
					att:SetField("CameraRotY", node.CameraRotY);
				end
			end
		end,
		function()
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc()
			end
		end)
		
	end
end
--做一个标记，如果站在一个钓鱼点不同，延缓连续请求的时间
function CatchFish.StartAagainRequest()
	local self = CatchFish;
	self.again_request = true;
	if(not CatchFish.again_request_timer)then
		CatchFish.again_request_timer = commonlib.Timer:new({callbackFunc = function(timer)
			self.again_request = nil;
		end})
	end
	-- start the timer after 1000 milliseconds, and stop it immediately.
	CatchFish.again_request_timer:Change(10000, nil)
end
function CatchFish.RecoverState()
	local self = CatchFish;
	if(self.in_square)then
		local tag = true;
		local k,v;
		local x,y,z = ParaScene.GetPlayer():GetPosition();
		for k,v in ipairs(fishing_place) do
			local _x,_y,_z = v[1],v[2],v[3];
			local dis_x = math_abs(_x - x);
			local dis_y = math_abs(_y - y);
			local dis_z = math_abs(_z - z);
			local dis = dis_x * dis_x + dis_z * dis_z; -- 水平面位移
			if(dis < 9 and dis_y < 3)then
				tag = false;--此刻用户仍然在一个钓鱼点
				break;
			end
		end
		if(tag)then
			self.in_square = false;--如果不在任何一个钓鱼点
		end
	end
end
--检测用户和 钓鱼点的距离
--如果距离合适 请求开始钓鱼
function CatchFish.CheckDistance()
	local self = CatchFish;
	local k,v;
	local x,y,z = ParaScene.GetPlayer():GetPosition();
	for k,v in ipairs(fishing_place) do
		local _x,_y,_z = v[1],v[2],v[3];
		local dis_x = math_abs(_x - x);
		local dis_y = math_abs(_y - y);
		local dis_z = math_abs(_z - z);
		local dis = dis_x * dis_x + dis_z * dis_z; -- 水平面位移
		--commonlib.echo("========CatchFish.CheckMinDis");
		--commonlib.echo({x,z});
		--commonlib.echo({_x,_z});
		--commonlib.echo(dis);
		if(dis < 9 and dis_y < 3)then
			if(not self.in_square)then
				self.in_square = true;
				self.index = k;
				if(not self.again_request)then
					self.CheckStart();
				end
			end
		end
	end
end
--冷冻或者解冻用户
function CatchFish.SetPlayerFreeze(state)
	local self = CatchFish;
	local player = ParaScene.GetPlayer();
	local playerChar = player:ToCharacter();
	if(state == true)then
		playerChar:Stop();
		ParaScene.GetAttributeObject():SetField("BlockInput", true);
		ParaCamera.GetAttributeObject():SetField("BlockInput", true);
	else
		ParaScene.GetAttributeObject():SetField("BlockInput", false);
		ParaCamera.GetAttributeObject():SetField("BlockInput", false);
	end
end
function CatchFish.SetPlayerPos()
	local self = CatchFish;
	local player = ParaScene.GetPlayer();
	local place = fishing_place[self.index];
	local facing = place[4];
	if(facing)then
		player:SetFacing(facing);
	end
	local x,y,z = place[1],place[2],place[3];
	if(x and y and z)then
		player:SetPosition(x,y,z);
	end
end
--投掷渔网 开始捕鱼
function CatchFish.DoFire()
	local self = CatchFish;
	local player = ParaScene.GetPlayer();
	local facing = player:GetFacing();
	
	local place = fishing_place[self.index];
	local x,y,z = place[1],place[2],place[3];
	local old_facing = place[4];
	
	local rotation = facing + 1.57;
	local _x = x + math.sin(rotation) * self.radius * self.strength;
	local _z = z + math.cos(rotation) * self.radius * self.strength;
	commonlib.echo("===================dofire");
	commonlib.echo({self.radius,self.strength,_x,_z,x,z});
	local startPoint = {
		x = x,
		y = y,
		z = z,
	}
	local endPoint = {
		x = _x,
		y = y - 1.5,
		z = _z,
	}
	self.DestroyNet();
	self.ThrowNet(startPoint,endPoint);
	self.DoReStart();
	self.DestroyNetItem();
	self.net_num = self.net_num - 1;
	--MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateNetNum(self.net_num);
	MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateUI()
	self.wait_net_node = CatchFish.GetSelectedNetNode();
	self.DestroyHelpUI();
end
function CatchFish.ThrowNet(startPoint,endPoint)
	local self = CatchFish;
	if(not startPoint or not endPoint)then return end
	
	local throwModel = CatchFish.GetNetAssetFile();
	--local hitModel = "";
	--local throwAnim = self.page:GetValue("throwAnim");
	local totalTime = self.throwTime;
	
	local player = ParaScene.GetPlayer();
	if(not player or not player:IsValid())then return end
	local x,y,z = player:GetPosition();
	local playerName = player.name;
	--local startPoint = {x = x,y = y,z = z};
	--local endPoint = {x = x,y = y,z = z + 5};
	local nid = Map3DSystem.User.nid;
	local throwItem={
		gsid=0,
		style = throwModel, 
		hitstyle="",
		showpic="",
	  };
   local throwerLevel=0;
   local throwerState="follow"; 
   local defaultAnimationFile = throwAnim or self.default_throwAnim;
	local throwBall = CommonCtrl.ThrowBall:new{
					startPoint = startPoint,
					endPoint = endPoint,
					ballStyle =  throwModel,
					playerName = playerName,
					nid = nid,
					throwItem = throwItem,
					throwerState = throwerState,
					throwerLevel = throwerLevel,
					throwType = "self",
				}
	throwBall.defaultAnimationFile = "character/Animation/v5/Throw.x";
	throwBall.totalTime = totalTime;
	throwBall.OnEnd = function(ball)
		--设置能够钓到鱼的位置
		commonlib.echo("===========set hookpoint");
		commonlib.echo(endPoint);
		self.SetHookPoint(endPoint)
	end
		
	throwBall:Play();
	local msg = throwBall:GetThrowMsg();
	if(msg)then
		msg.hitObjNameList={  }
		NPL.load("(gl)script/apps/Aries/Inventory/Throwable.lua");
		commonlib.echo("==========msg");
		commonlib.echo(msg);
		MyCompany.Aries.Inventory.ThrowablePage.BroadcastAction(msg)
	end
end
--强制离开一个钓鱼点
function CatchFish.ForceAway()
	local self = CatchFish;
	if(self.index)then
		local out_place = fishing_out_place[self.index];
		--退出钓鱼圈
		if(out_place)then
			local x,y,z = out_place[1],out_place[2],out_place[3];
			ParaScene.GetPlayer():SetPosition(x,y,z);
		end
	end
	self.autoFishTimer = nil;
	self.SetPlayerFreeze(false);
	self.in_square = false;
	self.index = nil;
	self.canStart = false;
	self.SetHookPoint(nil);
	self.is_fishing = false;

	self.DestroyUI();
	--关闭面板
	MyCompany.Aries.Quest.NPCs.CatchFish_panel.ClosePage();
	MyCompany.Aries.Desktop.ShowAllAreas();

	CatchFish.selected_net_gsid = nil;
	CatchFish.last_net_gsid = nil;
	local _wnd = MyCompany.Aries.app._app:FindWindow("CatchFish.ShowItemBox");
	if(_wnd) then
		_wnd.MyPage:CloseWindow();
	end
end
--检测这个位置是否可以钓鱼
function CatchFish.CheckStart()
	local index = CatchFish.index;
	if(index)then
		Map3DSystem.GSL_client:SendRealtimeMessage("s30388", {body="[Aries][ServerObject30388]CheckStart:" ..  index});
	end
end
--请求钓鱼
function CatchFish.DoStart()
	local index = CatchFish.index;
	if(index)then
		Map3DSystem.GSL_client:SendRealtimeMessage("s30388", {body="[Aries][ServerObject30388]DoStart:" ..  index});
	end
end
--请求重新开始钓鱼
function CatchFish.DoReStart()
	local index = CatchFish.index;
	if(index)then
		Map3DSystem.GSL_client:SendRealtimeMessage("s30388", {body="[Aries][ServerObject30388]DoReStart:" ..  index});
	end
end
--请求退出
function CatchFish.DoQuit()
	local index = CatchFish.index;
	if(index)then
		Map3DSystem.GSL_client:SendRealtimeMessage("s30388", {body="[Aries][ServerObject30388]DoQuit:" ..  index});
	end
end
--请求退出
function CatchFish.DoQuitInternal()
	local index = CatchFish.index;
	if(index)then
		Map3DSystem.GSL_client:SendRealtimeMessage("s30388", {body="[Aries][ServerObject30388]DoQuitInternal:" ..  index});
	end
end

function CatchFish.GetStamina()
	local self = CatchFish;
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean)then
		return bean.stamina or 0;
	end
	return 0;
end
--是否可以钓鱼的返回
function CatchFish.CheckStartRecv(state)
	local self = CatchFish;
	self.internalQuit = nil;
	if(state == "true")then
		CatchFish.selected_net_gsid = 17113;
		--锁住人物，不能再移动
		self.SetPlayerFreeze(true);
		self.net_num = self.GetNetNum();
		local bean = MyCompany.Aries.Player.GetMyJoybeanCount();
		commonlib.echo("============CatchFish.CheckStartRecv");
		commonlib.echo({net_num = self.net_num, bean = bean,});
		function do_start()
			CatchFish.last_net_gsid = nil;
			if(not self.internalQuit)then
				MyCompany.Aries.Desktop.HideAllAreas();
				local BattleChatArea = commonlib.gettable("MyCompany.Aries.Combat.UI.BattleChatArea");
				BattleChatArea.Show(true);
				
				--记录渔网的数量
				self.net_num = self.GetNetNum();
				self.fish_list = {};--捉到的鱼
						
				self.canStart = true;
				
				self.SetPlayerPos();
				self.DoFollowPet();
				self.DoCameraMotion(function()
					self.DoStart();
				end);
			else
				self.ForceAway();
			end
		end
		if(self.GetStamina() < 10)then
			local s = "";
			--精力值药剂大、中
			local staminaList = {17393,17344,17345};
			local hasStaminaPill = false;
			local pillGUID;
			local k,v;
			local gsid,exid;
			--NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfileManager.lua");
			--local cur_stamina, max_value = MyCompany.Aries.Player.GetStamina();
			for k,v in pairs(staminaList) do
				gsid = tonumber(v);
				gsItem = Map3DSystem.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
				exid = gsItem.template.stats[51];
				hasStaminaPill,pillGUID = Map3DSystem.Item.ItemManager.IfOwnGSItem(gsid,12,nil);	
				if(hasStaminaPill == true) then
					if(gsid == 17393) then
						if(MyCompany.Aries.VIP.IsVIP()) then
							s = format("你的精力值低于10，现在不能捕鱼。发现你的包裹有<pe:item gsid='%d' style='width:32px;height:32px;' isclickable='false'/>,马上使用，继续欢乐赚仙豆！",gsid);
							break;
						end
						--local VIP = commonlib.gettable("MyCompany.Aries.VIP");
						--MyCompany.Aries.VIP.IsVIP
					else
						s = format("你的精力值低于10，现在不能捕鱼。发现你的包裹有<pe:item gsid='%d' style='width:32px;height:32px;' isclickable='false'/>,马上使用，继续欢乐赚仙豆！",gsid);
						break;
					end
				end
			end
			if(s == "") then
				s = format("你的精力值低于10，现在不能捕鱼。马上购买精力值药剂，继续欢乐赚仙豆！");
			end
			if(hasStaminaPill) then
				_guihelper.MessageBox(s,function(result) 
					if(result == _guihelper.DialogResult.Yes) then
						Map3DSystem.Item.ItemManager.ExtendedCost(exid, nil, nil, function(msg) 
							MyCompany.Aries.Desktop.HPMyPlayerArea.UpdateUI();
							_guihelper.MessageBox("你已补充了精力值，可以继续捕鱼了");
						end);
					end
					if(result == _guihelper.DialogResult.No) then
						self.DoQuitInternal();
						self.ForceAway();
						_guihelper.MessageBox("你的精力值低于10，目前不能再捕鱼了，补充了精力值再来吧！");
						return;
					end
				end,_guihelper.MessageBoxButtons.YesNo);
			else
				_guihelper.MessageBox(s,function(result) 
					if(result == _guihelper.DialogResult.Yes) then
						Map3DSystem.mcml_controls.pe_item.OnClickGSItem(17344,true);
					end
					if(result == _guihelper.DialogResult.No) then
						self.DoQuitInternal();
						self.ForceAway();
						_guihelper.MessageBox("你的精力值低于10，目前不能再捕鱼了，补充了精力值再来吧！");
						return;
					end
				end,_guihelper.MessageBoxButtons.YesNo);
				--self.DoQuitInternal();
				--self.ForceAway();
				--_guihelper.MessageBox("你的精力值低于10，今天不能再捕鱼了，明天再来吧！");
				--return;
			end
		end
		do_start();
		if(self.net_num > 0 )then
			--do_start();
		else
			
			--_guihelper.Custom_MessageBox("<div style='margin-left:5px;margin-top:20px;'>你还没有<span style='color:#ff0000'>渔网</span>呢，先去买点渔网再来捕鱼吧！</div>",function(result)
				--self.DoQuitInternal();
				--self.ForceAway();
				--if(result == _guihelper.DialogResult.Yes)then
					--NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
					--local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
					--WorldManager:GotoNPC(30389);
				--end
			--end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/Coming_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
			--return;
			--if(bean <100 )then
				--_guihelper.Custom_MessageBox("<div style='margin-left:15px;margin-top:20px;text-align:center'>有100个奇豆才能来捕鱼！</div>",function(result)
					--if(result == _guihelper.DialogResult.OK)then
						--self.DoQuitInternal();
						--self.ForceAway();
					--end
				--end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/OK_2_32bits.png; 0 0 153 49"});
				--return;
			--end
			--_guihelper.Custom_MessageBox("<div style='margin-left:15px;margin-top:20px;text-align:center'>你愿意交纳100个奇豆购买50个捕鱼网吗，你要是用不完捕鱼网，离开捕鱼场我再给你退吧！</div>",function(result)
				--if(result == _guihelper.DialogResult.Yes)then
					--self.BuyNet(function()
						--
						--do_start();
						--
					--end);
				--else
					--self.DoQuitInternal();
					--self.ForceAway();
				--end
			--end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_2_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
		end
	else
		self.in_square = false;
		self.index = nil;
		self.canStart = false;
		--延缓连续请求时间
		self.StartAagainRequest();
		_guihelper.Custom_MessageBox("<div style='margin-left:15px;margin-top:20px;text-align:center'>哦噢！这里已经有人在捕鱼了，可以等等或者去别的地方看看哦！</div>",function(result)
			if(result == _guihelper.DialogResult.OK)then
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/OK_2_32bits.png; 0 0 153 49"});
	end
end
--成功开始钓鱼的返回
function CatchFish.DoStartRecv(state)
	local self = CatchFish;
	if(state == "true")then
		NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30388_CatchFish_panel.lua");
		MyCompany.Aries.Quest.NPCs.CatchFish_panel.ShowPage();
		--钓鱼进行中
		self.is_fishing = true;
		--_guihelper.MessageBox("游戏开始");
		--MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateNetNum(self.net_num);
		--local num = 0;
		--if(self.fish_net)then
			--num = #self.fish_net;
		--end
		--MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateFishNum(num);
		MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateUI()
	end
end
function CatchFish.DoFinished()
	local self = CatchFish;
	local net_num = self.GetNetNum();
	local bean = 0;
	local s;
	--if(net_num > 0)then
		--bean = net_num * 2;
		--s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你已经离开捕鱼场啦，捕鱼网还有%d个没用完，那就退给你%d个奇豆下次再来玩呀！</div>",
		--net_num or 0,bean or 0);
		--
	--else
		--s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你已经离开捕鱼场啦，今天收获得还好吧，海产物可以卖给汉特哟，记得有空再来玩！</div>";
	--end
	s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你已经离开捕鱼场啦，今天收获得还好吧，海产物可以卖给汉特哟，记得有空再来玩！</div>";
	_guihelper.Custom_MessageBox(s,function(result)
		if(result == _guihelper.DialogResult.OK)then
			--if(net_num > 0)then
			----出售剩余的渔网
			--self.SellAllNetItem();
			--end
		end
	end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/OK_2_32bits.png; 0 0 153 49"});
end
function CatchFish.DoQuitInternalRecv(state)
	local self = CatchFish;
	commonlib.echo("=============DoQuitInternalRecv");
	local self = CatchFish;
	self.internalQuit = true;
end
--退出的返回
function CatchFish.DoQuitRecv(state)
	local self = CatchFish;
	if(state == "true")then
		--_guihelper.MessageBox("直接退出游戏");
		self.DoFinished();
		self.ForceAway();
	end
end
--重新开始的返回
function CatchFish.DoReStartRecv(state)
	local self = CatchFish;
	if(state == "true")then
		--_guihelper.MessageBox("重新开始游戏");
	end
end
--每一轮时间的结束
function CatchFish.OnTimeover(state)
	local self = CatchFish;
	if(state == "true")then
		--_guihelper.MessageBox("游戏时间到");
		self.DoFinished();
		self.ForceAway();
	end
end
--每秒更新一次
function CatchFish.OnFramemove(sec)
	local self = CatchFish;
	if(sec)then
		commonlib.echo("=========used sec");
		commonlib.echo({index = CatchFish.index, sec = sec});
		--MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateTime(sec);
		MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateTime(61 - sec);
	end
end
-------------------------------------------------------------------
function CatchFish.DestroyUI()
	local self = CatchFish;
	ParaUI.Destroy("CatchFish.Container");
	CatchFish.DestroyClockUI();
end
function CatchFish.MadeUI(parent,offset_x,offset_y,radius,throwTime)
	local self = CatchFish;
	offset_x = offset_x or 0;
	offset_y = offset_y or 0;
	self.radius = radius or 3;
	self.throwTime = throwTime;
	self.drag_btn_x = offset_x + (self.container_w - self.drag_btn_size) / 2;--相对坐标
	self.drag_btn_y = offset_y + (self.container_h - self.drag_btn_size) / 2;
	self.drag_center_x = self.container_x + self.drag_btn_x + self.drag_btn_size/2;--绝对坐标
	self.drag_center_y = self.container_y + self.drag_btn_y + self.drag_btn_size/2;--绝对坐标
	
	local left,top,width,height= self.container_x,self.container_y,self.container_w,self.container_h;
	local _this=ParaUI.CreateUIObject("container","CatchFish.Container", "_lt",left,top,width,height);
	_this.background="Texture/whitedot.png;0 0 0 0";
	if(not parent)then
		_this:AttachToRoot();
		_this.zorder = 0;
	else
		parent:AddChild(_this);
		_this.zorder = 0;
	end
	local parent = _this;
	
	local container = _this;
	left,top,width,height = self.drag_btn_x,self.drag_btn_y,self.drag_btn_size,self.drag_btn_size;
	_this=ParaUI.CreateUIObject("container","CatchFish.HoldBtn", "_lt",left,top,width,height);
	_this.background="Texture/Aries/NPCs/CatchFish/red_32bits.png;0 0 54 54";
	parent:AddChild(_this);
	local x = self.drag_btn_x + self.drag_btn_size/2 - self.arrow_w /2
	local y = self.drag_btn_y + self.drag_btn_size/2 - self.arrow_h /2
	left,top,width,height = x,y,self.arrow_w,self.arrow_h;
	_this=ParaUI.CreateUIObject("container","CatchFish.Arrow", "_lt",left,top,width,height);
	_this.background="Texture/Aries/NPCs/CatchFish/arrow_32bits.png;0 0 256 256";
	parent:AddChild(_this);
	self.UpdateArrowVisiable(false);

	if(not container or not container:IsValid())then
		return;
	end
	container.onmouseup = ";MyCompany.Aries.Quest.NPCs.CatchFish.OnMouseUp();";
	container.onmousemove = ";MyCompany.Aries.Quest.NPCs.CatchFish.OnMouseMove();";
	container.onmousedown = ";MyCompany.Aries.Quest.NPCs.CatchFish.OnMouseDown();";
	container.onmouseleave = ";MyCompany.Aries.Quest.NPCs.CatchFish.OnMouseLeave();";
	
	CatchFish.ShowHelpUI();
	CatchFish.ShowClockUI();
end
function CatchFish.ShowHelpUI()
	local showNum = MyCompany.Aries.Player.LoadLocalData("CatchFish.ShowHelpUI", 0);
	if(showNum > 5)then
		return;
	end
	showNum = showNum + 1;
	MyCompany.Aries.Player.SaveLocalData("CatchFish.ShowHelpUI", showNum);
	local parent = ParaUI.GetUIObject("CatchFish.Container");
	if(parent and parent:IsValid())then
		local btn = ParaUI.GetUIObject("CatchFish.HoldBtn");
		if(btn and btn:IsValid())then
			local x = btn.x;
			local y = btn.y;
			local width = btn.width;
			local height = btn.height;
			
			local left,top,width,height = x + width,y,358,64;
			local _this=ParaUI.CreateUIObject("container","CatchFish.ShowHelpUI.Container", "_lt",left,top,width,height);
			_this.background = "Texture/Aries/NPCs/CatchFish/holdtip_32bits.png;0 0 358 64";
			parent:AddChild(_this); 
		end
	end
end
function CatchFish.DestroyHelpUI()
	ParaUI.Destroy("CatchFish.ShowHelpUI.Container");
end
function CatchFish.ShowClockUI()
	local _this=ParaUI.CreateUIObject("container","CatchFish.Clock.Container", "_rt",-128,20,128,128);
	_this.background="Texture/Aries/NPCs/CatchFish/clock_32bits.png; 0 0 128 128";
	_this:AttachToRoot();

	local parent = _this;
	_this=ParaUI.CreateUIObject("container","CatchFish.Clock", "_lt",40,40,50,50);
	_this.background="";
	parent:AddChild(_this);
	NPL.load("(gl)script/ide/TextSprite.lua");
	local ctl = CommonCtrl.TextSprite:new{
		name = "CatchFish.ShowClockUI",
		alignment = "_lt",
		left = 0,
		top = 0,
		width = 50,
		height = 50,
		parent = _this,
		color = "#18aadf", -- "255 255 0 128"
		text = "0123456789 ABCDEF",
		-- the height of the font. the width is determined according to the font image.
		fontsize = 40,
		-- sprite info, below are default settings. 
		image = "Texture/16number.png",
		-- rect is "left top width height"
		sprites = {
			["1"] = {rect = "0 0 20 31", width = 20, height = 32},
			["2"] = {rect = "32 0 19 31", width = 19, height = 32},
			["3"] = {rect = "64 0 19 31", width = 19, height = 32},
			["4"] = {rect = "96 0 19 31", width = 19, height = 32},
			["5"] = {rect = "0 32 20 31", width = 20, height = 32},
			["6"] = {rect = "32 32 19 32", width = 19, height = 32},
			["7"] = {rect = "64 32 19 31", width = 19, height = 32},
			["8"] = {rect = "96 32 19 31", width = 19, height = 32},
			["9"] = {rect = "0 64 19 31", width = 19, height = 32},
			["0"] = {rect = "32 64 19 31", width = 19, height = 32},
			["A"] = {rect = "64 64 22 31", width = 22, height = 32},
			["B"] = {rect = "96 64 20 31", width = 20, height = 32},
			["C"] = {rect = "0 96 19 31", width = 19, height = 32},
			["D"] = {rect = "32 96 19 31", width = 19, height = 32},
			["E"] = {rect = "64 96 19 31", width = 19, height = 32},
			["F"] = {rect = "96 96 19 31", width = 19, height = 32},
		},
	};
	ctl:Show(true);

	-- call update UI function whenever you have changed the properties. 
	ctl:UpdateUI();
	ctl:SetText("00");
	CommonCtrl.AddControl("CatchFish.ShowClockUI",ctl)
end
function CatchFish.DestroyClockUI()
	ParaUI.Destroy("CatchFish.Clock.Container");
end
function CatchFish.UpdateClockUI(v)
	local v = tostring(v);
	local ctl = CommonCtrl.GetControl("CatchFish.ShowClockUI");
	if(v and ctl)then
		ctl:SetText(v);
	end
end
-----------------------------------mouse event
function CatchFish.UpdateArrowXY(x,y)
	local self = CatchFish;
	local arrow = ParaUI.GetUIObject("CatchFish.Arrow");
	if(arrow)then
		if(x and y)then
			local root_x, root_y = 0,0;
			local parent = ParaUI.GetUIObject("CatchFish.Container");
			if(parent and parent:IsValid())then
				root_x, root_y,width_screen, height_screen = parent:GetAbsPosition();
			end
			local dx = x - self.drag_center_x  - root_x;
			local dy = y - self.drag_center_y  - root_y;
			local rotation = math.tanh(-dx/dy);
			--commonlib.echo({rotation,dy,dx});
			local length = dx * dx + dy * dy
			length = math.sqrt(length);
			local scalingy = length/(self.arrow_h / 2 ) + self.min_scaling;
			scalingy = math.min(scalingy,4);
			arrow.scalingy= scalingy;	
			arrow.rotation = rotation;		
			self.strength = scalingy;
			local place = fishing_place[self.index];
			if(place)then
				local player = ParaScene.GetPlayer();
				
				local facing = place[4];
				if(facing)then
					player:SetFacing(facing + rotation);
				end
			end
			
		end
	end
end
function CatchFish.UpdateArrowVisiable(bShow)
	local self = CatchFish;
	local arrow = ParaUI.GetUIObject("CatchFish.Arrow");
	if(arrow)then
		arrow.visible = bShow;
		local x = self.drag_btn_x + self.drag_btn_size/2 - self.arrow_w /2
		local y = self.drag_btn_y + self.drag_btn_size/2 - self.arrow_h /2
		arrow.x = x;
		arrow.y = y;
		arrow.scalingy= self.min_scaling;
	end
end
function CatchFish.OnHit(x,y)
	local self = CatchFish;
	if(not x or not y)then return end
	local root_x, root_y = 0,0;
	local parent = ParaUI.GetUIObject("CatchFish.Container");
	if(parent and parent:IsValid())then
		root_x, root_y,width_screen, height_screen = parent:GetAbsPosition();
	end
	local start_x = self.container_x + root_x;
	local start_y = self.container_y + root_y;
	local btn_size = self.drag_btn_size;
	local btn_x = self.drag_btn_x; 
	local btn_y = self.drag_btn_y; 
	
	local min_x = start_x + btn_x;
	local min_y = start_y + btn_y;
	local max_x = min_x + btn_size;
	local max_y = min_y + btn_size;
	if(x >= min_x and x <= max_x and y >= min_y and y <= max_y)then
		return true;
	end
end
function CatchFish.BtnState(state)
	local self = CatchFish;
	if(not state)then return end
	local path;
	if(self.cur_btn_state ~= state)then
		self.cur_btn_state = state;
		if(state == "default")then
			path = "Texture/Aries/NPCs/CatchFish/red_32bits.png;0 0 54 54";
		elseif(state == "over")then
			path = "Texture/Aries/NPCs/CatchFish/green_32bits.png;0 0 54 54";
		elseif(state == "down")then
			path = "Texture/Aries/NPCs/CatchFish/green_32bits.png;0 0 54 54";
		elseif(state == "default")then
		end
		local btn = ParaUI.GetUIObject("CatchFish.HoldBtn");
		if(btn and path)then
			btn.background = path;
		end
	end
end
function CatchFish.OnMouseDown()
	local cur_time = commonlib.TimerManager.GetCurrentTime();
	if(CatchFish.dofire_time and (cur_time - CatchFish.dofire_time) < 500) then
		_guihelper.MessageBox("你点击太快了，请稍等几秒再试！");
		return
	end
	if(CatchFish.canAutoFishNets[CatchFish.selected_net_gsid]) then
		_guihelper.MessageBox("捕鱼器不能手动投掷，只能自动发射，请点击下方<span style='color:#a00100;font-weight:bold;font-size:14;'>开始捕鱼</span>按钮！");
		return
	end

	local self=CatchFish;
	self.lastMousePosX = mouse_x;
	self.lastMousePosY = mouse_y;
	self.net_num = self.GetNetNum();
	
	self.canDrag = false;
	if(self.GetStamina() < 10)then
		local s = "";
		--精力值药剂大、中
		local staminaList = {17393,17344,17345};
		local hasStaminaPill = false;
		local pillGUID;
		local k,v;
		local gsid,exid;
		--NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfileManager.lua");
		--local cur_stamina, max_value = MyCompany.Aries.Player.GetStamina();
		for k,v in pairs(staminaList) do
			gsid = tonumber(v);
			gsItem = Map3DSystem.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
			exid = gsItem.template.stats[51];
			hasStaminaPill,pillGUID = Map3DSystem.Item.ItemManager.IfOwnGSItem(gsid,12,nil);	
			if(hasStaminaPill == true) then
				if(gsid == 17393) then
					if(MyCompany.Aries.VIP.IsVIP()) then
						s = format("你的精力值低于10，现在不能捕鱼。发现你的包裹有<pe:item gsid='%d' style='width:32px;height:32px;' isclickable='false'/>,马上使用，继续欢乐赚仙豆！",gsid);
						break;
					end
					--local VIP = commonlib.gettable("MyCompany.Aries.VIP");
					--MyCompany.Aries.VIP.IsVIP
				else
					s = format("你的精力值低于10，现在不能捕鱼。发现你的包裹有<pe:item gsid='%d' style='width:32px;height:32px;' isclickable='false'/>,马上使用，继续欢乐赚仙豆！",gsid);
					break;
				end
			end
		end
			
		if(s == "") then
			s = format("你的精力值低于10，现在不能捕鱼。马上购买精力值药剂，继续欢乐赚仙豆！");
		end
		if(hasStaminaPill == true) then
			_guihelper.MessageBox(s,function(result) 
				if(result == _guihelper.DialogResult.Yes) then
					Map3DSystem.Item.ItemManager.ExtendedCost(exid, nil, nil, function(msg) 
						MyCompany.Aries.Desktop.HPMyPlayerArea.UpdateUI();
						_guihelper.MessageBox("你已补充了精力值，可以继续捕鱼了");
					end);
				end
				if(result == _guihelper.DialogResult.No) then
					self.DoQuitInternal();
					self.ForceAway();
					_guihelper.MessageBox("你的精力值低于10，目前不能再捕鱼了，补充了精力值再来吧！");
					return;
				end
			end,_guihelper.MessageBoxButtons.YesNo);
		else
			_guihelper.MessageBox(s,function(result) 
				if(result == _guihelper.DialogResult.Yes) then
					Map3DSystem.mcml_controls.pe_item.OnClickGSItem(17344,true);
				end
				if(result == _guihelper.DialogResult.No) then
					self.DoQuitInternal();
					self.ForceAway();
					_guihelper.MessageBox("你的精力值低于10，目前不能再捕鱼了，补充了精力值再来吧！");
					return;
				end
			end,_guihelper.MessageBoxButtons.YesNo);
			--self.DoQuitInternal();
			--self.ForceAway();
			--_guihelper.MessageBox("你的精力值低于10，今天不能再捕鱼了，明天再来吧！");
			--return;
		end
	end
	if(self.GetNetNum() <= 0)then
		--self.DoQuitInternal();
		--self.ForceAway();
		local net_node = CatchFish.GetSelectedNetNode();
		local label = net_node.label;	
		local gsid = net_node.gsid;
		local buy_net_exid = net_node.buy_net_exid;
		if(not gsid or not buy_net_exid)then
			return
		end	
		NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
		_guihelper.Custom_MessageBox(string.format("你的【%s】没有了，需要购买一些吗？",label),function(result)
			if(result == _guihelper.DialogResult.Yes)then
				local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
				if(command) then
					command:Call({gsid = gsid, exid = buy_net_exid, npc_shop = true, callback = function(params, msg)
						if(msg and msg.issuccess) then
							MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateUI()
						end
					end });
				end
			end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Cancel_32bits.png; 0 0 153 49"});
		return
	end
	if(mouse_button=="left" and self.net_num > 0)then
		self.isLMBDown = true;
		if(self.OnHit(mouse_x,mouse_y))then
			self.BtnState("down");
			self.canDrag = true;
			self.strength = self.min_scaling;
			self.UpdateArrowVisiable(true);
		end
	end
end
function CatchFish.OnMouseUp()
	local self = CatchFish;
	CatchFish.dofire_time = commonlib.TimerManager.GetCurrentTime();
	if(self.isLMBDown and self.canDrag and self.is_fishing and self.net_num > 0)then
		self.DoFire();
	end
	self.isLMBDown = false;
	self.BtnState("default");
	self.UpdateArrowVisiable(false);
end
function CatchFish.OnMouseMove()
	local self = CatchFish;
	if(self.isLMBDown)then
		local dx,dy;
		dx = self.lastMousePosX - mouse_x;
		dy = self.lastMousePosY - mouse_y;
		
		if(self.canDrag)then
			self.UpdateArrowXY(mouse_x,mouse_y)
		end
		self.lastMousePosX = mouse_x;
		self.lastMousePosY = mouse_y;
	else
		if(self.OnHit(mouse_x,mouse_y) and self.net_num > 0)then
			self.BtnState("over");
		else
			self.BtnState("default");
		end
	end
end
function CatchFish.OnMouseLeave()
	local self = CatchFish;
	self.isLMBDown = false;
	self.BtnState("default");
	self.UpdateArrowVisiable(false);
end
-------------------------------------------------------------------
--是否正处于钓鱼状态当中
function CatchFish.IsInFishing()
	local self = CatchFish;
	if(self.is_fishing and self.hook_point)then
		return true;
	end
end
--渔网漂浮的位置
function CatchFish.SetHookPoint(hook_point)
	local self = CatchFish;
	self.hook_point = hook_point;
	if(hook_point)then
		--create a net
		self.CreateNet();
	else
		--destroy a net
		self.DestroyNet();
	end
end
function CatchFish.GetHookPoint()
	local self = CatchFish;
	return self.hook_point;
end
function CatchFish.CreateNet()
	local self = CatchFish;
	if(not self.hook_point)then return end
	self.DestroyNet();
	local pos = {
		self.hook_point.x,
		self.hook_point.y,
		self.hook_point.z,
	}
	local params = { 
		name = "渔网",
		position = pos,
		friend_npcs = "",
		scaling_char = 1,
		scaling_model = 1,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",
		assetfile_model = CatchFish.GetNetAssetFile(),
		--main_script = "script/apps/Aries/NPCs/Homeland/30348_ChallengeFlag.lua",
		--main_function = "MyCompany.Aries.Quest.NPCs.ChallengeFlag.main();",
		--predialog_function = "MyCompany.Aries.Quest.NPCs.ChallengeFlag.PreDialog",
		--selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
		isdummy = true,
	};
	NPC.CreateNPCCharacter(net_instance_id, params);
end
function CatchFish.DestroyNet()
	local self = CatchFish;
	NPC.DeleteNPCCharacter(net_instance_id);
end
function CatchFish.GetNet()
	local self = CatchFish;
	return  NPC.GetNpcCharModelFromIDAndInstance(net_instance_id);
end

--随机获取一条鱼
function CatchFish.GetFish()
	local self = CatchFish;
	local r = math.random(100);
	if( r <= 10)then
		return 17106;
	elseif(r >10 and r <=25)then
		return 17107;
	elseif(r >25 and r <=55)then
		return 17108;
	elseif(r >55 and r <=75)then
		return 17109;
	elseif(r >75 and r <=90)then
		return 17110;
	elseif(r >90 and r <=100)then
		return 17111;
	end
end
function CatchFish.OnHitNet(fish)
	local self = CatchFish;
	local net = self:GetNet();
	if(self.IsInFishing() and net and net:IsValid() and fish and fish:IsValid())then
		local dist = net:DistanceTo(fish);
		if(not self.wait_net_node)then
			return
		end
		local absolutely_hit = false;
		if(self.wait_net_node and self.wait_net_node.absolutely_hit)then
			absolutely_hit = true;
		end
		if(dist < 5 or absolutely_hit)then
			self.SetHookPoint(nil);
			local gsid = self.GetFish();
			if(gsid)then
				--if(gsid ~= 17106)then
					--self.BuyFish(gsid);
					--if(self.fish_list)then
						--table.insert(self.fish_list,gsid);
						--local num = #self.fish_list;
						--
						--MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateFishNum(num);
					--end
				--end
				--self.ShowItemBox(gsid);
				echo("================CatchFish.OnHitNet");
				ItemManager.ExtendedCost(self.wait_net_node.exid, nil, nil, function(msg)end, function(msg)
					echo("================CatchFish.OnHitNet 2");
					echo(msg);
					if(msg.issuccess and msg.obtains)then
						CatchFish.last_net_gsid = nil;
						local behas_gift = false;
						local behas_fish = false;
						local gift_gsid,fish_gsid;
						local gift_count,fish_count;
						local k,v;
						for k,v in pairs(msg.obtains) do
							--echo("111111111111111");
							--echo(msg.obtains);
							if(k > 0 and v > 0)then
								local gsItem = ItemManager.GetGlobalStoreItemInMemory(k);
								if(gsItem and gsItem.template.class == 3) then
									gsid = k;
									local behappen_ShowItemBox = false;
									if(gsid == 17288) then
										
										gift_gsid = gsid;
										gift_count = tonumber(v);
										behas_gift = true;
										--Dock.ShowNotificationInChannel(gsid, 1);
										--if(not behappen_ShowItemBox) then
											--self.ShowItemBox(gsid,self.wait_net_node.exid);	
											--behappen_ShowItemBox = true;
										--end
									elseif(gsid == 17548)then
										gift_gsid = gsid;
										gift_count = tonumber(v);
										behas_gift = true;
										--Dock.ShowNotificationInChannel(gsid, 1);
										
									elseif(self.fish_list)then
										table.insert(self.fish_list,gsid);
										if(self.wait_net_node.exid == 1605)then
											--双倍捕鱼
											table.insert(self.fish_list,gsid);
											--Dock.ShowNotificationInChannel(gsid, 2);
										else
											--Dock.ShowNotificationInChannel(gsid, 1);
										end
										local num = #self.fish_list;

										--MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateFishNum(num);
										MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateUI()

										fish_gsid = gsid;
										fish_count = tonumber(v);
										behas_fish = true;
										--if(not behappen_ShowItemBox) then
											--self.ShowItemBox(gsid,self.wait_net_node.exid);	
											--behappen_ShowItemBox = true;
										--end
										
										commonlib.echo("===========fish_list");
										commonlib.echo(self.fish_list);
									end
									--break;
								end
								if(k == 50401) then
									gsid = k;
									--Dock.ShowNotificationInChannel(gsid, 1);
									MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateUI()
									fish_gsid = gsid;
									fish_count = tonumber(v);
									behas_fish = true;
									--self.ShowItemBox(gsid,self.wait_net_node.exid);
									commonlib.echo("===========fish_list");
									commonlib.echo(self.fish_list);
								end
							end
						end
						if(behas_gift) then
							self.ShowItemBox(gift_gsid,self.wait_net_node.exid,gift_count);
							--Dock.ShowNotificationInChannel(gift_gsid, gift_count);
						else
							self.ShowItemBox(fish_gsid,self.wait_net_node.exid,fish_count);
						end
						if(behas_gift) then
							Dock.ShowNotificationInChannel(gift_gsid, gift_count);		
						end
						if(behas_fish) then
							Dock.ShowNotificationInChannel(fish_gsid, fish_count);		
						end

						
					end
					
				end)
			end
			
			
		end
	end
end
function CatchFish.DoFollowPet()
	local item = ItemManager.GetMyMountPetItem();
	if(item and item.guid > 0) then
		if(item.clientdata == "mount") then
		    item:FollowMe();
		end
	end
end
--获取目前有多少个渔网
function CatchFish.GetNetNum()
	local self = CatchFish;
	local __,__,__,copies = hasGSItem(CatchFish.selected_net_gsid or 17113);
	copies = copies or 0;
	return copies;
end
function CatchFish.GetFishNum()
	if(CatchFish.fish_list)then
		return #CatchFish.fish_list;
	end
	return 0;
end
--购买渔网
function CatchFish.BuyNet(callbackFunc)
	local self = CatchFish;
	ItemManager.ExtendedCost(441, nil, nil, function(msg)end, function(msg)
		commonlib.echo("======Get_50_copies_17113_CatchingFishNet");
		commonlib.echo(msg);
		if(msg.issuccess) then
			if(callbackFunc)then
				callbackFunc();
			end
		end
	end,"none")
end
function CatchFish.SellAllNetItem()
	local has,guid,bag,copies = hasGSItem(17113);
    if(has)then
	commonlib.echo("========before sell net");
		commonlib.echo(guid);
		ItemManager.SellItem(guid, copies, function(msg) end, function(msg)
			commonlib.echo("========after sell net");
			commonlib.echo(msg);
			if(msg and msg.issuccess)then
				
			end
		end)
	end
end
function CatchFish.DestroyNetItem()
	local self = CatchFish;
	local used_net = CatchFish.selected_net_gsid;
	echo("===========used_net");
	echo(used_net);
	echo(CatchFish.last_net_gsid);
	if(not CatchFish.last_net_gsid or used_net ~= CatchFish.last_net_gsid)then
		CatchFish.last_net_gsid = used_net;
	else
		
		local net = CatchFish.nets[CatchFish.last_net_gsid];
		if(net and not net.absolutely_hit) then
			local bHas, guid = hasGSItem(CatchFish.last_net_gsid);
			if(bHas and guid) then
				ItemManager.DestroyItem(guid, 1, function(msg) end, function(msg)
					MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateUI()
				end);
			end
		end
	end
	
end
function CatchFish.BuyFish(gsid,callbackFunc)
	local self = CatchFish;
	if(not gsid)then return end
	ItemManager.PurchaseItem(gsid, 1, function(msg) end, function(msg)
		if(msg) then
		end
	end,nil,"none");
end
function CatchFish.ShowItemBox(gsid,exid,count)
	if(not gsid)then return end
	local num;
	if(count) then
		num = count;
	else
		if(exid == 1605)then
			num = 2;
		else
			num = 1;
		end
	end

	local url = string.format("script/apps/Aries/NPCs/TownSquare/30388_CatchFish_box.html?gsid=%d&num=%d",gsid,num);
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = url, 
			name = "CatchFish.ShowItemBox", 
			app_key=MyCompany.Aries.app.app_key, 
			--app_key=MyCompany.Taurus.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			directPosition = true,
				align = "_ctr",
				x = 0,
				y = 0,
				width = 200,
				height = 240,
		});
end
function CatchFish.DoQuitAll()
	local self = CatchFish;
	self.DoQuit();
	self.DestroyUI();
	NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30388_CatchFish_panel.lua");
	MyCompany.Aries.Quest.NPCs.CatchFish_panel.ClosePage();
end

function CatchFish.AutoFishing()
	local self = CatchFish;
	if(self.autoMode) then
		if(self.autoFishTimer) then
			self.autoMode = false;
			self.autoFishTimer:Change();
			MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateUI()
		else
			LOG.std(nil, "error","MyCompany.Aries.Quest.NPCs.CatchFish.AutoFishing:", "can't find the autoFishTimer");
		end
	else
		--local canAutoFishList = {[17465] = true,[17466] = true,[17467] = true,};
		if(self.canAutoFishNets[CatchFish.selected_net_gsid]) then
			if(not self.autoFishTimer) then
				self.autoFishTimer = commonlib.Timer:new({callbackFunc = function(timer)
					if(self.is_fishing and self.GetNetNum() > 0 and self.GetStamina() >= 10) then
						self.DoAutoFishing();
					else
						timer:Change();
						self.autoMode = false;
						if(self.GetNetNum() <= 0) then
							self.ReplenishNet();
						elseif(self.GetStamina() < 10) then
							self.ReplenishStamina();
						end
					end
					MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateUI()
				end})
			elseif(not self.autoFishTimer:IsEnabled()) then
				self.autoFishTimer:Enable();
			end
			self.autoMode = true;
			local interval;
			if(CatchFish.selected_net_gsid == 17465) then
				interval = 2000;
			elseif(CatchFish.selected_net_gsid == 17466) then
				interval = 2500;
			elseif(CatchFish.selected_net_gsid == 17467) then
				interval = 3000;
			end
			self.autoFishTimer:Change(500,interval);
		else
			_guihelper.MessageBox("只有使用捕鱼器才能自动捕鱼，请点击左下方<span style='color:#a00100;font-weight:bold;font-size:14;'>切换渔网</span>选择捕鱼器吧！");
		end
		
	end
end

function CatchFish.AutoDoFire()
	local self = CatchFish;
	local player = ParaScene.GetPlayer();
	local facing = player:GetFacing();
	
	local place = fishing_place[self.index];
	local x,y,z = place[1],place[2],place[3];
	local old_facing = place[4];
	
	local rotation = facing + 1.57;
	local _x = x + math.sin(rotation)*10;
	local _z = z + math.cos(rotation)*10;
	commonlib.echo("===================doautofire");
	--commonlib.echo({self.radius,self.strength,_x,_z,x,z});
	local startPoint = {
		x = x,
		y = y,
		z = z,
	}
	local endPoint = {
		x = _x,
		y = y - 1.5,
		z = _z,
	}
	self.DestroyNet();
	self.ThrowNet(startPoint,endPoint);
	self.DoReStart();
	self.DestroyNetItem();
	self.net_num = self.net_num - 1;
	--MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateNetNum(self.net_num);
	MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateUI()
	self.wait_net_node = CatchFish.GetSelectedNetNode();
	self.DestroyHelpUI();
end

function CatchFish.ReplenishStamina()
	local self = CatchFish;
	local s = "";
	--精力值药剂大、中
	local staminaList = {17393,17344,17345};
	local hasStaminaPill = false;
	local pillGUID;
	local k,v;
	local gsid,exid;
	for k,v in pairs(staminaList) do
		gsid = tonumber(v);
		gsItem = Map3DSystem.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
		exid = gsItem.template.stats[51];
		hasStaminaPill,pillGUID = Map3DSystem.Item.ItemManager.IfOwnGSItem(gsid,12,nil);	
		if(hasStaminaPill == true) then
			if(gsid == 17393) then
				if(MyCompany.Aries.VIP.IsVIP()) then
					s = format("你的精力值低于10，现在不能捕鱼。发现你的包裹有<pe:item gsid='%d' style='width:32px;height:32px;' isclickable='false'/>,马上使用，继续欢乐赚仙豆！",gsid);
					break;
				end
				--local VIP = commonlib.gettable("MyCompany.Aries.VIP");
				--MyCompany.Aries.VIP.IsVIP
			else
				s = format("你的精力值低于10，现在不能捕鱼。发现你的包裹有<pe:item gsid='%d' style='width:32px;height:32px;' isclickable='false'/>,马上使用，继续欢乐赚仙豆！",gsid);
				break;
			end
		end
	end
	if(s == "") then
		s = format("你的精力值低于10，现在不能捕鱼。马上购买精力值药剂，继续欢乐赚仙豆！");
	end
	if(hasStaminaPill) then
		_guihelper.MessageBox(s,function(result) 
			if(result == _guihelper.DialogResult.Yes) then
				Map3DSystem.Item.ItemManager.ExtendedCost(exid, nil, nil, function(msg) 
					MyCompany.Aries.Desktop.HPMyPlayerArea.UpdateUI();
					_guihelper.MessageBox("你已补充了精力值，可以继续捕鱼了");
				end);
			end
			if(result == _guihelper.DialogResult.No) then
				self.DoQuitInternal();
				self.ForceAway();
				_guihelper.MessageBox("你的精力值低于10，目前不能再捕鱼了，补充了精力值再来吧！");
				return;
			end
		end,_guihelper.MessageBoxButtons.YesNo);
	else
		_guihelper.MessageBox(s,function(result) 
			if(result == _guihelper.DialogResult.Yes) then
				Map3DSystem.mcml_controls.pe_item.OnClickGSItem(17344,true);
			end
			if(result == _guihelper.DialogResult.No) then
				self.DoQuitInternal();
				self.ForceAway();
				_guihelper.MessageBox("你的精力值低于10，目前不能再捕鱼了，补充了精力值再来吧！");
				return;
			end
		end,_guihelper.MessageBoxButtons.YesNo);
	end
end

function CatchFish.ReplenishNet()
	local net_node = CatchFish.GetSelectedNetNode();
	local label = net_node.label;	
	local gsid = net_node.gsid;
	local buy_net_exid = net_node.buy_net_exid;
	if(not gsid or not buy_net_exid)then
		return
	end	
	NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
	_guihelper.Custom_MessageBox(string.format("你的【%s】没有了，需要购买一些吗？",label),function(result)
		if(result == _guihelper.DialogResult.Yes)then
			local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
			if(command) then
				command:Call({gsid = gsid, exid = buy_net_exid, npc_shop = true, callback = function(params, msg)
					if(msg and msg.issuccess) then
						MyCompany.Aries.Quest.NPCs.CatchFish_panel.OnUpdateUI()
					end
				end });
			end
		end
	end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Cancel_32bits.png; 0 0 153 49"});
	return
end

function CatchFish.DoAutoFishing()
	local index = CatchFish.index;
	if(index)then
		Map3DSystem.GSL_client:SendRealtimeMessage("s30388", {body="[Aries][ServerObject30388]DoAutoFishing:" ..  index});
	end
end

function CatchFish.DoAutoFishingRecv(state)
	local self = CatchFish;
	if(state == "true")then
		CatchFish.AutoDoFire();
	end
end