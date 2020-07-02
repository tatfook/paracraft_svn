--[[
Title: 
Author(s): Leio
Company: ParaEnging Co. & Taomee Inc.
Date: 2009/11/8
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandCanvas_New.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
NPL.load("(gl)script/ide/Display3D/SceneCanvas.lua");
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");
NPL.load("(gl)script/ide/Display3D/HomeLandCommonNode.lua");
NPL.load("(gl)script/ide/Display3D/SeedGridNode.lua");
NPL.load("(gl)script/ide/Display3D/HouseNode.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandNodeProcessor.lua");

NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/PlantView_New.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/RoomEntryView.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/PlantGridView.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/NormalView.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/ChristmasGiftView.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/MusicBox.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/EnergyPool.lua");

NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/paraworld.homeland.home.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/paraworld.homeland.plantevolved.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/paraworld.homeland.petevolved.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/paraworld.homeland.giftbox.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/paraworld.homeland.house.lua");

NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/PetState.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/FollowPetState.lua");

NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/HomeDetail.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/HomeProfile.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/MyHomelandIndoor.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/MyHomelandOutdoor.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/MyHomelandStore.lua");

NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/NormalView.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/PlantGridView.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/RoomEntryView.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/SeedView.lua");

NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");

NPL.load("(gl)script/ide/AudioEngine/AudioEngine.lua");
local AudioEngine = commonlib.gettable("AudioEngine");
local HomeLandGateway = commonlib.gettable("Map3DSystem.App.HomeLand.HomeLandGateway");

local HomeLandCanvas_New = {
	sceneManager = nil,
	rootNode = nil,
	canvas = nil,
	nodeProcessor = nil,
	
	nid = nil,--谁的家园
	jid = nil,--家园主人的jid
	isBuildingNode = false,--是否正在创建一个物体，当创建完毕，才能继续创建新的
	roleState = "guest", -- "master" or "guest"	
	locationState = "outside", -- "outside" or "inside"
	editingState = "false", -- "true" or "false"
	-- "master_outside_true" or "master_outside_false" 
	-- "master_inside_true" or "master_inside_false" 
	-- "guest_outside_false" or "guest_inside_false" 
	
	indoorOrigin = nil,--在室内的起点
	inRoomNode = nil,--现在是在哪个房屋的室内
	outdoorOrigin = nil,--在室外的起点
	
	limitBuildNodeTimer = nil,--限定创建物体的timer 功能: 不能创建太快
	
	minHouseNodeHeight = 100,--室内模型的最低高度
	houseNodeHeightStep = 20,--每个室内模型分配的高度
	buildNodeRadius = 0,
	buildNodeRadiusStep = 2,
	buildNodeMaxRadius = 10,
	buildNodeAngle = 0,
	buildNodeAngleStep = 30,
	buildNodeMaxAngle = 360,
	last_x = 0,
	last_y = 0,
	last_z = 0,
	
	ChristmasSocksTag = nil,--圣诞袜tag it is a table
}
commonlib.setfield("Map3DSystem.App.HomeLand.HomeLandCanvas_New",HomeLandCanvas_New);
function HomeLandCanvas_New:new (o)
	o = o or {}   -- create object if user does not provide one
	o.Nodes = {};
	setmetatable(o, self)
	self.__index = self
	o:Init();
	return o
end

function HomeLandCanvas_New:Init()
	if(self.nid == Map3DSystem.User.nid)then
		self.roleState = "master";	
	else
		self.roleState = "guest";	
	end
	
	local sceneManager = CommonCtrl.Display3D.SceneManager:new();
	local rootNode = CommonCtrl.Display3D.SceneNode:new{
		root_scene = sceneManager,
	}
	local canvas = CommonCtrl.Display3D.SceneCanvas:new{
		rootNode = rootNode,
		sceneManager = sceneManager,
	}
	local nodeProcessor = Map3DSystem.App.HomeLand.HomeLandNodeProcessor:new{
		canvas = canvas,
		parent_canvas = self,
		roleState = self.roleState,--身份
		OnSelectedNodeFunc = self.OnSelectedNodeFunc,--选中/取消选中 事件
	};
	self.sceneManager = sceneManager;
	self.rootNode = rootNode;
	self.canvas = canvas;
	self.nodeProcessor = nodeProcessor;
	
	canvas:AddEventListener("mouse_over",HomeLandCanvas_New.DoMouseOver,self);
	canvas:AddEventListener("mouse_out",HomeLandCanvas_New.DoMouseOut,self);
	canvas:AddEventListener("mouse_down",HomeLandCanvas_New.DoMouseDown,self);
	canvas:AddEventListener("mouse_up",HomeLandCanvas_New.DoMouseUp,self);
	canvas:AddEventListener("mouse_move",HomeLandCanvas_New.DoMouseMove,self);
	canvas:AddEventListener("stage_mouse_down",HomeLandCanvas_New.DoMouseDown_Stage,self);
	canvas:AddEventListener("stage_mouse_up",HomeLandCanvas_New.DoMouseUp_Stage,self);
	canvas:AddEventListener("stage_mouse_move",HomeLandCanvas_New.DoMouseMove_Stage,self);
	canvas:AddEventListener("child_selected",HomeLandCanvas_New.DoChildSelected,self);
	canvas:AddEventListener("child_unselected",HomeLandCanvas_New.DoChildUnSelected,self);
	
	--在登录家园后，map所有已经创建的物体，没有记录新创建的物体
	self.allBuildNodesMap = {};
	
	--家园的一些列信息
	--[[
	--家园的信息
	self.houseinfo = {
			 flowercnt=21,
			 name="??gggg",
			 pugcnt=14,
			 visitcnt=3,
			 visitors="nid|05/08/2009 21:02:31,nid|05/08/2009 21:01:41" 
			}
			
	--访问者的信息
	self.usersinfo = {
		{ nid=166, nickname="leio1", userid="71d6a011-69da-4a4a-bcea-750d2ac954cd",visitdate="05/08/2009 21:02:31"}
	}
	self.giftinfo
	/// <summary>
    /// 取得指定的用户的礼品盒
    /// 接收参数：
    ///     nid
    /// 返回值：
    ///     boxcnt （所拥有的礼品盒数）
    ///     giftcnt （共收到了多少礼物）
    ///     sendcnt （共向别人赠送了多少礼品）
    ///     [ errorcode ]
    /// </summary>
    
	self.giftinfo_detail
	
	/// 取得指定用户收到的所有礼物
    /// 接收参数：
    ///     nid
    /// 返回值：
    ///     gifts[list]
    ///         id
    ///         from
    ///         gsid
    ///         msg
    ///         adddate
    ///     [ errorcode ]
  
    主人的个人信息
	self.homemaster_info = { emoney=0, nickname="leio3", nid=19484, pmoney=0 }
	--]]
	--每次进入别人的家园，只能投一次鲜花/泥巴
	self.guests = {hasSendFlower = false, hasSendPug = false, hasRemindForReceiver = false,};
	
	--室内物体的起点
	self.indoorOrigin = Map3DSystem.App.HomeLand.HomeLandConfig.IndoorOrigin;
	self.indoorOrigin = self.indoorOrigin or {x = 19963, y = 50000, z = 20304}
	
	self.outdoorOrigin = Map3DSystem.App.HomeLand.HomeLandConfig.OutdoorOrigin ;
	self.outdoorOrigin = self.outdoorOrigin or {x = 0, y = 0, z = 0}
	
	self.limitBuildNodeTimer = commonlib.Timer:new{
		callbackFunc = HomeLandCanvas_New.BuildNodeTimer_Update,
	}
	self.limitBuildNodeTimer.holder = self;
end

function HomeLandCanvas_New.DoMouseOver(self,event)
	self.nodeProcessor:DoMouseOver(event);
end
function HomeLandCanvas_New.DoMouseOut(self,event)
	self.nodeProcessor:DoMouseOut(event);
end
function HomeLandCanvas_New.DoMouseDown(self,event)
	self.nodeProcessor:DoMouseDown(event);
end
function HomeLandCanvas_New.DoMouseUp(self,event)
	self.nodeProcessor:DoMouseUp(event);
end
function HomeLandCanvas_New.DoMouseMove(self,event)
	self.nodeProcessor:DoMouseMove(event);
end
function HomeLandCanvas_New.DoChildSelected(self,event)
	self.nodeProcessor:DoChildSelected(event);
end
function HomeLandCanvas_New.DoChildUnSelected(self,event)
	self.nodeProcessor:DoChildUnSelected(event);
end
function HomeLandCanvas_New.DoMouseDown_Stage(self,event)
	self.nodeProcessor:DoMouseDown_Stage(event);
end
function HomeLandCanvas_New.DoMouseUp_Stage(self,event)
	self.nodeProcessor:DoMouseUp_Stage(event);
end
function HomeLandCanvas_New.DoMouseMove_Stage(self,event)
	self.nodeProcessor:DoMouseMove_Stage(event);
end
function HomeLandCanvas_New:Clear()
	if(self.canvas)then
		self.canvas:ClearAll()
	end
end
---------------------------------------------------
--OnSelectedNodeFunc
---------------------------------------------------
function HomeLandCanvas_New.OnSelectedNodeFunc(msg)
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
	if(msg and msg.parent_canvas)then
		local self = msg.parent_canvas;
		local oldnode = msg.oldnode;
		local node = msg.node;
		
		--TODO:绑定属性面板
		if(node)then
			if(self.editingState == "false")then
				local type = node:GetType();
				commonlib.echo("============now type");
				commonlib.echo(type);
				if(type == "PlantE")then
					--如果没有播放动画的时候（浇水 除虫等）

					commonlib.echo(MyCompany.Aries.Inventory.PlantViewPage_New.anim_isplaying);
					if(not MyCompany.Aries.Inventory.PlantViewPage_New.anim_isplaying)then
						MyCompany.Aries.Inventory.PlantViewPage_New.ClosePage();
						self:LoadOnlyOnePlantE_Remote(node,function()
							MyCompany.Aries.Inventory.PlantViewPage_New.Init(self,node,node.bean,self:GetCommixState());
							MyCompany.Aries.Inventory.PlantViewPage_New.ShowPage();
						end)
						
					end
				elseif(type == "OutdoorHouse")then
					--暂时不显示 打扫房屋的功能
					--MyCompany.Aries.Inventory.RoomEntryViewPage.ClosePage();
					--MyCompany.Aries.Inventory.RoomEntryViewPage.Init(self,node,node.bean,self:GetCommixState());
					--MyCompany.Aries.Inventory.RoomEntryViewPage.ShowPage();
				elseif(type == "Grid")then
					local state = self:GetCommixState();
					local isshow = false;
					if(state == "master_outside_true")then
						isshow = true;
					elseif(state == "master_outside_false")then
						if(hitTestNodeIndex)then
							isshow = true;
						end
					end
					MyCompany.Aries.Inventory.PlantGridViewPage.ClosePage();
					MyCompany.Aries.Inventory.PlantGridViewPage.Init(self,node,{},state);
					MyCompany.Aries.Inventory.PlantGridViewPage.ShowPage();
					--invoke
					if(type == "Grid")then
						local msg = { 
								aries_type = "SeedGridSelected",--花圃被选中
								wndName = "homeland",
							};
						
						commonlib.echo("Invoke SeedGridSelected");
						commonlib.echo(msg);
						CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
					end
				else
				
					local internalTyle = self:GetExtendsObjectType_OutdoorOther(node);
					if(internalTyle == "MusicBox")then
						--音乐盒
						MyCompany.Aries.Inventory.MusicBoxPage.ClosePage();
						MyCompany.Aries.Inventory.MusicBoxPage.Init(self,node,self:GetCommixState());
						MyCompany.Aries.Inventory.MusicBoxPage.ShowPage();
					end
					if(internalTyle == "EnergyPool")then
						--能量池
						MyCompany.Aries.Inventory.EnergyPoolPage.ClosePage();
						MyCompany.Aries.Inventory.EnergyPoolPage.Init(self,node,self:GetCommixState());
						MyCompany.Aries.Inventory.EnergyPoolPage.ShowPage();
					end
					--MyCompany.Aries.Inventory.NormalViewPage.ClosePage();
					--MyCompany.Aries.Inventory.NormalViewPage.Init(self,node,{},self:GetCommixState());
					--MyCompany.Aries.Inventory.NormalViewPage.ShowPage();
				end
			else
				MyCompany.Aries.Inventory.NormalViewPage.ClosePage();
				MyCompany.Aries.Inventory.NormalViewPage.Init(self,node,{},self:GetCommixState());
				MyCompany.Aries.Inventory.NormalViewPage.ShowPage();
			end
		else
			self:CloseAllPanelPage();
		end
	end
end
--销毁屏幕左侧的面板
function HomeLandCanvas_New:CloseAllPanelPage()
	MyCompany.Aries.Inventory.RoomEntryViewPage.ClosePage();
	MyCompany.Aries.Inventory.PlantGridViewPage.ClosePage();
	MyCompany.Aries.Inventory.NormalViewPage.ClosePage();
	MyCompany.Aries.Inventory.PlantViewPage_New.ClosePage();
	MyCompany.Aries.Inventory.MusicBoxPage.ClosePage();
	MyCompany.Aries.Inventory.EnergyPoolPage.ClosePage();
end
---------------------------------------------------
--handle extends object
---------------------------------------------------
function HomeLandCanvas_New:GetExtendsObjectType_OutdoorOther(node)
	if(not node)then return end
	local type = node:GetType();
	if(type == "OutdoorOther")then
		local guid = node:GetGUID();
		local gsItem,item = self:GetGlobalItem(guid);
		if(gsItem and item)then
			local descfile = gsItem.descfile;
			if(descfile and descfile ~= "")then
				descfile = commonlib.LoadTableFromString(descfile);
				if(descfile)then
					if(descfile.internalType ~= nil)then
						--圣诞袜已经下架
						if(descfile.internalType ~= "ChristmasSocks")then
							return descfile.internalType;
						end
					end
				end
			end
		end
	end
end
---------------------------------------------------
--remote plants
---------------------------------------------------
--根据植物的成长情况，设置follow_pet_state要说的话
--msg 是所有植物的成长情况
function HomeLandCanvas_New:SetPlantData_FollowPetState(msg)
	local nid = self.nid;
	local follow_pet_state = self.follow_pet_state;
	if(follow_pet_state)then
		if(msg and msg.items)then
			local k,item;
			local plants = {};
			for k,item in ipairs(msg.items) do
				local id = item.id;
				local feedscnt = item.feedscnt;
				local isdroughted = item.isdroughted;
				local isbuged = item.isbuged;
				
				local gsItem = self:GetGlobalItem(id);
				local plant_descritor = "";
				if(gsItem and gsItem.template)then
					local template = gsItem.template
					plant_descritor = template.description or "";
				end
				--{ name = "1", has_fruit = nil, is_bug = nil, is_drought = nil, is_normal = true, },
				local name = plant_descritor;
				local has_fruit = false;
				if(feedscnt and feedscnt > 0)then
					has_fruit = true;
				end
				local is_normal = true;
				if(isdroughted == true or isbuged == true)then
					is_normal = false;
				end
				local args = {
					name = name,
					has_fruit = has_fruit,
					is_bug = isbuged,
					is_drought = isdroughted,
					is_normal = is_normal,
				}
				table.insert(plants,args);
				follow_pet_state:SetPlantData(plants);
				return
			end
		end
		follow_pet_state:SetPlantData(nil);
	end
end
function HomeLandCanvas_New:LoadPlantE_Remote(callbackFunc)
	local node;
	local ids = "";
	local mapping = {};
	for node in self.rootNode:Next() do
		if(node)then
			commonlib.echo(node:GetParams());
			local type = node:GetType();
			if(type == "PlantE")then
				local guid = node:GetGUID();
				if(guid)then
					if(ids == "")then
						ids = guid;
					else
						ids = ids..","..guid;
					end
					mapping[guid] = node;
				end	
			end
		end
	end
	ids = tostring(ids);
	-- 加载plants成长数据
			local msg = {
						nid = self.nid,
						ids = tostring(ids),
					}
					commonlib.echo("load plants grown info before in home:");
					commonlib.echo(msg);
					--如果没有植物 不发送请求
					if(not ids or ids == "")then return end
	paraworld.homeland.plantevolved.GetAllDescriptors(msg,"plantevolved",function(msg)	
					commonlib.echo("load plants grown info after in home:");
					commonlib.echo(msg);
						if(msg and msg.items)then
							local k,item;
							for k,item in ipairs(msg.items) do
								local id = item.id;
								id = tonumber(id);
								local node = mapping[id];
								if(node)then
									self:BindNode_PlantE(node,item);
								end
							end
						end
						if(callbackFunc and type(callbackFunc) == "function")then
							--发送植物的成长信息
							callbackFunc(msg);
						end
					end);
end
--绑定每一个植物的远程数据
function HomeLandCanvas_New:BindNode_PlantE(node,bean)
	if(not node or not bean)then return end
	local type = node:GetType();
	if(type == "PlantE")then
		node:SetBean(bean);
		self:ReloadAssetFile_Plant(node);
	end
end
--重新加载一棵植物的远程数据
function HomeLandCanvas_New:LoadOnlyOnePlantE_Remote(node,callbackFunc)
	if(not node)then return end
	local guid = node:GetGUID();
	guid = tostring(guid);
	if(not guid)then return end
	-- 加载plants成长数据
	local msg = {
				nid = self.nid,
				ids = guid,
			}
	commonlib.echo("load only one plant grown info before in home:");
	commonlib.echo(msg);
	paraworld.homeland.plantevolved.GetAllDescriptors(msg,"plantevolved",function(msg)	
	commonlib.echo("load only one plant grown info after in home:");
	commonlib.echo(msg);
		if(msg and msg.items)then
			local item = msg.items[1];
			if(item)then
				self:BindNode_PlantE(node,item);
			end
		end
		if(callbackFunc and type(callbackFunc) == "function")then
			--发送植物的成长信息
			callbackFunc(msg);
		end
	end);
end
---------------------------------------------------
--remote OutdoorHouse
---------------------------------------------------
-- 绑定房屋入口
function HomeLandCanvas_New:LoadOutdoorHouse_Remote(callbackFunc)
	local node;
	local ids = "";
	local mapping = {};
	for node in self.rootNode:Next() do
		if(node)then
			local type = node:GetType();
			if(type == "OutdoorHouse")then
				local guid = node:GetGUID();
				if(guid)then
					if(ids == "")then
						ids = guid;
					else
						ids = ids..","..guid;
					end
					mapping[guid] = node;
				end	
			end
		end
	end
	ids = tostring(ids);

	local msg = {
			nid = self.nid,
			guids = tostring(ids),
		}
			commonlib.echo("before get house info");
			commonlib.echo(msg);
			--如果没有房屋 不发送请求
			if(not ids or ids == "")then return end
		paraworld.homeland.house.GetHouseInfo(msg,"house",function(msg)	
						commonlib.echo("after get house info");
						commonlib.echo(msg);
						if(msg and msg.houses)then
							local k,item;
							for k,item in ipairs(msg.houses) do
								local id = item.guid;
								id = tonumber(id);
								local node = mapping[id];
								if(node)then
									self:BindNode_OutdoorHouse(node,item)
								end
							end
							if(callbackFunc and type(callbackFunc) == "function")then
								--发送房屋的成长信息
								callbackFunc(msg);
							end
						end
			end);
end
--绑定每一个房屋的远程数据
function HomeLandCanvas_New:BindNode_OutdoorHouse(node,bean)
	if(not node or not bean)then return end
	local type = node:GetType();
	if(type == "OutdoorHouse")then
		node:SetBean(bean);
	end
end
--get description of node from global store 
function HomeLandCanvas_New:GetGlobalItem(guid)
	if(not guid)then return end
	local ItemManager = Map3DSystem.Item.ItemManager;
	local item;
	if(Map3DSystem.App.HomeLand.HomeLandGateway.IsInMyHomeland())then
		item = ItemManager.GetItemByGUID(guid);
	elseif(Map3DSystem.App.HomeLand.HomeLandGateway.IsInOtherHomeland())then
		local nid = self.nid;
		item = ItemManager.GetOPCItemByGUID(nid, guid);
	end
	if(item)then 
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid)
		return gsItem,item;
	end
end
--重新加载植物的资源
function HomeLandCanvas_New:ReloadAssetFile_Plant(node)
	local bean = node.bean;
	local gsItem,__ = self:GetGlobalItem(bean.id);
	if(not gsItem)then return end
	local temlateConfig =  Map3DSystem.App.HomeLand.HomeLandConfig.ParsePlantE(gsItem.descfile);
	if(node and bean and temlateConfig)then
		local level = bean.level;
		local assets;
		if(bean.isbuged and bean.isdroughted)then
			assets = temlateConfig["assets_drought_bug"];
		elseif(bean.isbuged)then
			assets = temlateConfig["assets_bug"];
		elseif(bean.isdroughted)then
			assets = temlateConfig["assets_drought"];
		else
			assets = temlateConfig["assets_normal"];
		end
		if(not assets)then return end
		local len = #assets;
		if(not level)then
			level = 0;
		end
		level = level + 1;
		if(level > len)then
			level = len;
		end
		local assetFile = assets[level];
		commonlib.echo({"ReloadAssetFile_Plant:",assetFile,"level",level,"len",len});
		if(assetFile)then
			local s = node.assetfile;
			if(s ~= assetFile)then
				node.assetfile = assetFile;
				node:Detach();
				--TODO:处理已经选中的问题
				self.rootNode:AddChild(node);
			end
		end
	end
end
--------------------------------------------------------------------------
--宠物 
--------------------------------------------------------------------------
-- 刷新宠物
function HomeLandCanvas_New:RefreshPetsInHomeland()
	local nid = self.nid;
	local ItemManager = Map3DSystem.Item.ItemManager;
	if(nid == Map3DSystem.User.nid)then
		ItemManager.LoadPetsInHomeland(nil, function(msg)
			-- leio: i manually refresh the pets in homeland to solve the non-pet-exist bug
			MyCompany.Aries.Pet.RefreshMyPetsFromMemoryInHomeland();
			
			--通知宠物ai 人物已经进入家园
			if(self.follow_pet_state)then
				self.follow_pet_state:SetInHome();
			end
		end, "access plus 10 minutes");
	else
		ItemManager.LoadPetsInHomeland(nid, function(msg)
			-- leio: i manually refresh the pets in homeland to solve the non-pet-exist bug
			MyCompany.Aries.Pet.RefreshOPCPetsFromMemoryInHomeland(nid);
			--通知宠物ai 人物已经进入家园
			if(self.follow_pet_state)then
				self.follow_pet_state:SetInHome();
			end
		end, "access plus 10 minutes");
	end
end
--是否暂停 宠物ai
function HomeLandCanvas_New:PauseFollowPetState(v)
	local follow_pet_state = self:GetCurFollowPetState();
	if(follow_pet_state)then
		if(v)then
			follow_pet_state:Pause();
		else
			follow_pet_state:Resume();
		end
	end
end
function HomeLandCanvas_New:ReloadFollowPetItems()
	local follow_pet_state = self:GetCurFollowPetState();
	if(follow_pet_state)then
		follow_pet_state:ReloadPetItems();
	end
end
--在重新加载之前
function HomeLandCanvas_New:Before_ReloadFollowPetItems()
	local follow_pet_state = self:GetCurFollowPetState();
	if(follow_pet_state)then
		follow_pet_state:StopAllTimers();
		follow_pet_state:ReloadPetItems();
	end
end
function HomeLandCanvas_New:GetCurFollowPetState()
	return self.follow_pet_state;
end
--------------------------------------------------------------------------
--记录访问量 
--------------------------------------------------------------------------
function HomeLandCanvas_New:DoVisit()
	if(self.nid ~= Map3DSystem.User.nid)then
		local msg = {
				sessionkey = Map3DSystem.User.sessionkey,
				homenid = self.nid,
				
			}
		commonlib.echo("before add visitors:");
		commonlib.echo(msg);
		paraworld.homeland.home.Visit(msg,"home",function(msg)	
			commonlib.echo("after add visitors:");
			commonlib.echo(msg);
			if(msg and msg.issuccess)then
			
			end
		end);
	end
end
--------------------------------------------------------------------------
--加载访问信息 
--------------------------------------------------------------------------
function HomeLandCanvas_New:LoadVisitors()
	function loadDetail(visitors)
		if(not visitors)then return end
		commonlib.echo("=========visitors");
		commonlib.echo(visitors);
		local userdate = {};
		local user;
		local nids = "";
		local nids_table = {};
		for user in string.gfind(visitors, "[^,]+") do
			local __,__,id,date = string.find(user,"(.+)|(.+)");

			nids = nids..id..",";
			id = tonumber(id);
			if(id)then
				table.insert(nids_table,id);
			end
			if(date)then
				local __,__,date_temp = string.find(date,"(.-)%s");
				date = date_temp;
			end
			userdate[tonumber(id)] = date or "";
		end

		local nCounter = 0;
		local nTotalCounter = #nids_table;
		local usersinfo = {};
		local _, user_nid;
		for _, user_nid in ipairs(nids_table) do
			Map3DSystem.App.profiles.ProfileManager.GetUserInfo(user_nid, "GetUserInfo", function (msg)
				nCounter = nCounter + 1;
				if(msg and msg.users and msg.users[1]) then
					local users = msg.users
					local user = users[1];
					local nid = user.nid;
					local date = userdate[nid];
					user = commonlib.deepcopy(user);
					if(user)then
						user.visitdate = date;
					end
					table.insert(usersinfo,user);
				end
				if(nTotalCounter == nCounter) then
					self.usersinfo = usersinfo;
				end
			end, "access plus 1 year");
		end

		--local msg = {
			--nids = nids,
			--cache_policy = "access plus 0 day",
		--};
		--local usersinfo = {};
		--commonlib.echo("before load user detail info");
		--commonlib.echo(msg);
		--paraworld.users.getInfo(msg, "Homeinfo", function(msg)
			--commonlib.echo("after load user detail info");
			--commonlib.echo(msg);
			--if(msg and msg.users)then
				--local k,user;
				--for k,user in ipairs(msg.users) do
					--local nid = user.nid;
					--local date = userdate[nid];
					--user = commonlib.deepcopy(user)
					--if(user)then
						--user.visitdate = date;
						--table.insert(usersinfo,user);
					--end
				--end
				----for k = 1,50 do
					----table.insert(usersinfo,{ nid=166, nickname="leio"..k,visitdate="05/08/2009"});
				----end	
				----访问列表	可以为空	
				--self.usersinfo = usersinfo;
			--end
		--end);
	end
	
	local msg = {
		nid = self.nid,
	}
	commonlib.echo("before load visitors:");
	commonlib.echo(msg);
	paraworld.homeland.home.GetHomeInfo(msg,"home",function(msg)
		--[[
			echo:return {
			 flowercnt=21,
			 name="??gggg",
			 pugcnt=14,
			 visitcnt=3,
			 visitors="nid|05/08/2009 21:02:31,nid|05/08/2009 21:01:41" 
			}
		]]	
		commonlib.echo("after load visitors:");
		commonlib.echo(msg);
		if(msg)then	
			--家园信息
			self.houseinfo = msg;
			--更新访问量信息
			self:UpdateVisitors(self.houseinfo.visitcnt)
			loadDetail(msg.visitors)
			
			--------------------------跟随宠物ai 设置访问情况 --暂时只要有总的访问量就认为true
			local follow_pet_state = self.follow_pet_state;
			if(follow_pet_state)then
				--判断今天是否有人访问过家园
				local r = self:TodayHasVisited(msg)
				follow_pet_state:SetVisitedData(r);
			end
		end
	end);
end

function HomeLandCanvas_New:ReloadHomeInfo()

end
--今天是否被访问过
function HomeLandCanvas_New:TodayHasVisited(msg)
	if(not msg)then return false end
	local visitcnt = msg.visitcnt;
	local visitors = msg.visitors;
	if(visitors)then
		for user in string.gfind(visitors, "[^,]+") do
			local __,__,id,date = string.find(user,"(.+)|(.+)");
			commonlib.echo(date);
			if(date)then
				local __,__,date_temp = string.find(date,"(.-)%s");
				local r = self:IsToday(date_temp);
				if(r and visitcnt > 0)then
					return true;
				end
			end
		end
	end
	return false;
end
--[[
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
local t = Map3DSystem.App.HomeLand.HomeLandGateway.IsToday("10/11/2009");
commonlib.echo(t);
t = Map3DSystem.App.HomeLand.HomeLandGateway.IsToday("10/22/2009");
commonlib.echo(t);
--]]
--是否是今天
function HomeLandCanvas_New:IsToday(date)
	if(not date)then return false end
	local __,__,n_month,n_day,n_year = string.find(date,"(.+)/(.+)/(.+)");
	n_day = tonumber(n_day);
	n_month = tonumber(n_month);
	n_year = tonumber(n_year);
	
	local today = ParaGlobal.GetDateFormat("M/d/yyyy");
	local __,__,t_month,t_day,t_year = string.find(today,"(.+)/(.+)/(.+)");
	t_day = tonumber(t_day);
	t_month = tonumber(t_month);
	t_year = tonumber(t_year);
	
	if(n_day and n_month and n_year and t_day and t_month and t_year)then
		if(n_day == t_day and n_month == t_month and n_year == t_year)then
			return true;
		end
	end
	return false;
end
--更新访问量显示
function HomeLandCanvas_New:UpdateVisitors(visitcnt)
	MyCompany.Aries.Inventory.HomeProfilePage.UpdateVisitors(visitcnt)
end
--更新礼物盒数量显示
function HomeLandCanvas_New:UpdateGiftNum(giftcnt,boxcnt)
	MyCompany.Aries.Inventory.HomeProfilePage.UpdateGiftNum(giftcnt,boxcnt)
end
--------------------------------------------------------------------------
--礼物盒
--------------------------------------------------------------------------
--重新加载礼物盒的信息
function HomeLandCanvas_New:ReloadGiftInfo()
	-- 礼物盒信息
	local giftinfo = {};
	--[[
	/// <summary>
    /// 取得指定的用户的礼品盒
    /// 接收参数：
    ///     nid
    /// 返回值：
    ///     boxcnt （所拥有的礼品盒数）
    ///     giftcnt （共收到了多少礼物）
    ///     sendcnt （共向别人赠送了多少礼品）
    ///     [ errorcode ]
    /// </summary>
    --]]
	local msg = {
		nid = self.nid,
	}
	commonlib.echo("before get gift info");
	commonlib.echo(msg);
	paraworld.homeland.giftbox.Get(msg,"Giftinfo",function(msg)	
		commonlib.echo("after get gift info");
		commonlib.echo(msg);
		if(msg and msg.boxcnt)then
			giftinfo = commonlib.deepcopy(msg);
			--礼物盒信息
			self.giftinfo = giftinfo;
			
			--更新礼物盒子数量的显示
			self:UpdateGiftNum(giftinfo.giftcnt,giftinfo.boxcnt);
			
			--------------------------跟随宠物ai 设置礼物情况
			local follow_pet_state = self.follow_pet_state;
			if(follow_pet_state)then
				if(giftinfo.giftcnt > 0)then
					follow_pet_state:SetGiftData(true);
				else
					follow_pet_state:SetGiftData(false);
				end
			end
		end
	end);
end
--重新加载收到的礼物的信息
function HomeLandCanvas_New:ReloadGiftDetail()
	-- 加载礼物情况
	local giftinfo_detail = {};
	--[[
	/// 取得指定用户收到的所有礼物
    /// 接收参数：
    ///     nid
    /// 返回值：
    ///     gifts[list]
    ///         id
    ///         from
    ///         gsid
    ///         msg
    ///         adddate
    ///     [ errorcode ]
    --]]

	local msg = {
			nid = self.nid,
		}
	commonlib.echo("before get gift detail info");
	commonlib.echo(msg);
	paraworld.homeland.giftbox.GetGifts(msg,"Giftinfo",function(msg)
		commonlib.echo("after get gift detail info");
		commonlib.echo(msg);
		if(msg and msg.gifts)then
			giftinfo_detail = commonlib.deepcopy(msg.gifts);
			--礼物盒详细信息
			self.giftinfo_detail = giftinfo_detail;
			
		end
	end);
end
--------------------------------------------------------------------------
--主人信息
--------------------------------------------------------------------------
function HomeLandCanvas_New:LoadHomeMasterInfo()
	local nid = tostring(self.nid);
	local msg = {
		nids = nid
	}
	paraworld.users.getInfo(msg, "getInfo", function(msg)
		if(msg and msg.users and msg.users[1]) then
			self.homemaster_info = msg.users[1]; --{ emoney=0, nickname="leio3", nid=19484, pmoney=0 }
		end
	end)
end
--------------------------------------------------------------------------
--创建和室外房屋关联的 室内模型
function HomeLandCanvas_New:CreateIndoorNode(outdoorNode)
	if(not outdoorNode)then return end
	--物品系统的guid
	local guid = outdoorNode:GetGUID();
	
	outdoorNode.ReadyGoFunc = HomeLandCanvas_New.GotoFunc;
	--室内默认起点
	local indoorOrigin = self.indoorOrigin;
	local gsItem = self:GetGlobalItem(guid);
	if(gsItem)then
		local indoor_assetfile = Map3DSystem.App.HomeLand.HomeLandConfig.ParseHomeEntry(gsItem.descfile);
		if(indoor_assetfile)then
			indoor_assetfile = indoor_assetfile.indoor;
		end
		commonlib.echo("=============indoor_assetfile CreateIndoorNode");
		commonlib.echo(indoor_assetfile);
		local x,y,z = indoorOrigin.x,indoorOrigin.y,indoorOrigin.z;
		local indoor_node = CommonCtrl.Display3D.HouseNode:new{
			x = x,
			y = y,
			z = z,
			assetfile = indoor_assetfile or "model/01building/v5/01house/PoliceStation/Indoor.x",
			type = "IndoorHouse",
			ReadyGoFunc = HomeLandCanvas_New.GotoFunc,
		};
		self.rootNode:AddChild(indoor_node);
		
		outdoorNode.holder = self;
		indoor_node.holder = self;
		
		outdoorNode:EnabledAssetLoaded();
		indoor_node:EnabledAssetLoaded();
		--关联node
		outdoorNode:SetLinkedHouse(indoor_node);
		indoor_node:SetLinkedHouse(outdoorNode);
	end
end
--根据物体的类型 返回起始点
function HomeLandCanvas_New:GetNodeOrigin(type)
	local origin = {x = 0,y = 0,z = 0};
	if(not type)then return origin end
	--枚举室内物体
	if(type == "Furniture")then
		origin = self.indoorOrigin;
	else
		origin = self.outdoorOrigin;
	end
	return origin;
end
function HomeLandCanvas_New:GetChildCount()
	if(self.rootNode)then
		return self.rootNode:GetChildCount();
	end
end
--控制音乐盒的播放
function HomeLandCanvas_New:PlayMusic(node,b)
	if(not node)then return end
	local type = node:GetType()
	local entity = node:GetEntity();
	local internalType = self:GetExtendsObjectType_OutdoorOther(node);
	if(internalType == "MusicBox")then
		node:SetMusicBoxPlaying(b);
		--播放/停止 音乐
		local guid = node:GetGUID();
		local gsItem,item = self:GetGlobalItem(guid);
		if(gsItem and item)then
			local descfile = gsItem.descfile;
			descfile = Map3DSystem.App.HomeLand.HomeLandConfig.ParseMusicBox(descfile);
			if(descfile and descfile.wavefile)then
				local wavefile = descfile.wavefile;
				local assetfile;
				if(b)then
					--ParaAudio.PlayWaveFile(wavefile, 1000);
					--use new audio api
					local audioSource = AudioEngine.CreateGet(wavefile);
					audioSource:play2d();
					--hold wave file
					self.wavefile = wavefile;
					
					assetfile = descfile.playfile;
					if(assetfile)then
						--播放音乐
						node:Detach();
						node.assetfile = assetfile;
						self.rootNode:AddChild(node);
					end
				else
					--ParaAudio.StopWaveFile(wavefile, true);
					local audioSource = AudioEngine.CreateGet(wavefile);
					audioSource:stop();
					--clear wave fiel
					self.wavefile = nil;
					
					assetfile = gsItem.assetfile;--默认模型是停止状态
					if(assetfile)then
						--停止音乐
						node:Detach();
						node.assetfile = assetfile;
						self.rootNode:AddChild(node);
					end
				end
			end
		end
	end
end
--所有的室内物品应用物理
function HomeLandCanvas_New:SetAllNodePhysics_Indoor(b)
	local node;
	for node in self.rootNode:Next() do
		local type = node:GetType()
		local entity = node:GetEntity();
		if(entity)then
			if(type == "Furniture")then
				entity:EnablePhysics(b);
			end
		end
	end
end
--设置每个物体的物理，只有在物体被创建出来 设置才有效
function HomeLandCanvas_New:EnablePhysics(node)
	if(not node)then return end
	local type = node:GetType()
	local entity = node:GetEntity();
	if(entity)then
		if(type == "Furniture" and self.editingState == "true")then
			entity:EnablePhysics(false);
		end
	end
end
--创建家园的物体
function HomeLandCanvas_New:DrawNodes(custom_sprite3D)
	if(not custom_sprite3D or not custom_sprite3D.Next)then return end
	self.createdNodeNum = 0;
	local node;
	for node in custom_sprite3D:Next() do
		if(node)then
			local type = node:GetType();
			local origin = self:GetNodeOrigin(type);
			--转换为绝对坐标
			node:SetPositionDelta(origin.x,origin.y,origin.z);
			--在室内保存物体后，其他物体是在visible = false 状态下，在这里恢复所有的显示
			self.rootNode:AddChild(node);
			node:SetVisible(true);
			
			if(type == "OutdoorHouse")then
				--创建和室外房屋关联的 室内模型
				self:CreateIndoorNode(node);
			end
			
			
			local uid = node:GetUID();
			--map 已经创建的物体
			self.allBuildNodesMap[uid] = node;
			
			--设置每个物体的物理
			--self:EnablePhysics(node)
			
			--检查音乐盒播放状态
			local internalType = self:GetExtendsObjectType_OutdoorOther(node);
			if(internalType == "MusicBox")then
				local b = node:GetMusicBoxPlaying();
				commonlib.echo("=====b");
				commonlib.echo(b);
				self:PlayMusic(node,b);
			end
		end
	end
	--记录创建物品的数量
	local createdNodeNum = self:GetChildCount();
	commonlib.echo("==============Homeland DrawNodes Num");
	commonlib.echo(createdNodeNum);
			
	--花圃--植物
	for node in custom_sprite3D:Next() do
		if(node)then
			local type = node:GetType();
			if(type == "PlantE")then
				local uid = node:GetUID();
				--如果已经植物已经被花圃绑定
				local id = node:GetSeedGridNodeUID();
				local gridNode = self.allBuildNodesMap[id];
				if(gridNode)then
					local g_type = gridNode:GetType();
					if(g_type == "Grid")then
						gridNode:SetGridInfo(1,uid);
					end
				end
			end
		end
	end
	--生成跟随宠物自动说话
	self.follow_pet_state = Map3DSystem.App.HomeLand.FollowPetState:new{
		nid = self.nid,
	}
	Map3DSystem.App.HomeLand.FollowPetState.LoadPets(self.nid,function(msg)
		if(msg and msg.data)then
			local follow_pet_datasource = msg.data;
			self.follow_pet_state:SetPetsData(follow_pet_datasource);
		end
	end, "access plus 10 minutes");	
	
	
	--创建按钮面板
	self:RefreshHomeProfilePage()
	
	-- 加载plants成长数据
	self:LoadPlantE_Remote(function(msg)
		--根据植物成长情况，设置语言
		self:SetPlantData_FollowPetState(msg);
	end)
	--加载房屋的成长数据
	self:LoadOutdoorHouse_Remote();
	
	-- 记录访问量
	self:DoVisit();
	--加载访问信息
	self:LoadVisitors()
	
	-- 礼物盒信息
	self:ReloadGiftInfo()
	-- 加载礼物情况
	self:ReloadGiftDetail()
	
	--加载此家园拥有者的个人信息
	self:LoadHomeMasterInfo()
	
	
	ParaSelection.SetMaxItemNumberInGroup(1,5000)
	
		
	--检测自己的坐骑是否是 驾驭状态
	MyCompany.Aries.Pet.ForceFollowMe();
	HomeLandGateway.LoadPetShowState(self.nid,function(msg)
		if(msg and msg.clientdata)then
			local hide_in_homeland = msg.clientdata.hide_in_homeland;
			if(hide_in_homeland)then
				--donothing
			else
				local nid = self.nid;
				if(not nid or nid == Map3DSystem.App.profiles.ProfileManager.GetNID())then
					--刷新宠物
					self:RefreshPetsInHomeland(nid);
				else
					--如果进入其他家园 实例化一个坐骑
					MyCompany.Aries.Pet.InitOPCDragonPet(nid,function(msg)
						--刷新宠物
						self:RefreshPetsInHomeland();
					end);
				end
			end
		end
	end)
end
--旋转
function HomeLandCanvas_New:DoFacingDelta(facing)
	facing = tonumber(facing);
	self.nodeProcessor:SetFacingDelta(facing);
end
--缩放
function HomeLandCanvas_New:DoScalingDelta(scaling)
	scaling = tonumber(scaling);
	self.nodeProcessor:SetScalingDelta(scaling);
end
--开始拖拽
function HomeLandCanvas_New:DirectlyDragSelectedNode()
	--自定义的拖拽
	self.nodeProcessor:DirectlyDragSelectedNode()
end
--------------------------------------------------------------------------
--Invoke
--[[
local msg = { 
		aries_type = "SeedGridSelected", --花圃被选中
		wndName = "homeland",
	};
local msg = { 
		aries_type = "SeedPlanted", --种植
		wndName = "homeland",
	};
--]]
--------------------------------------------------------------------------
--返回目前没有有种植的花圃
function HomeLandCanvas_New:GetUnLinkedSeedGridInfo()
	local seedgrid_list = {};
	local node;
	for node in self.rootNode:Next() do
		local type = node:GetType();
		if(type == "Grid")then
			local r = node:HasLinkedNode();
			if(not r)then
				local x,y,z = node:GetPosition();
				table.insert(seedgrid_list,{x = x,y = y,z = z});
			end
		end
	end
	return seedgrid_list;
end
--------------------------------------------------------------------------
--不同的状态
--------------------------------------------------------------------------
function HomeLandCanvas_New:GetRoleState()
	--获取不同的角色权限
	return self.roleState;
end
function HomeLandCanvas_New:GetLocationState()
	--获取不同的位置，室外or室内
	return self.locationState;
end
function HomeLandCanvas_New:GetEditingState()
	return self.editingState;
end
-- 返回混合状态
function HomeLandCanvas_New:GetCommixState()
	local roleState,locationState,editingState = self:GetRoleState(),self:GetLocationState(),self:GetEditingState()
	local result = string.format("%s_%s_%s",roleState,locationState,editingState);
	return result;
end

--------------------------------------------------------------------------
--控制按钮 面板显示
--------------------------------------------------------------------------
function HomeLandCanvas_New:GetReadOnlyBean()
	local bean = {
		houseinfo = self.houseinfo,
		usersinfo = self.usersinfo,
		giftinfo = self.giftinfo,
		giftinfo_detail = self.giftinfo_detail,
		homemaster_info = self.homemaster_info,
	}
	return bean;
end
--按钮
function HomeLandCanvas_New:RefreshHomeProfilePage(destroyAwayBtn)
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/HomeProfile.lua");
	MyCompany.Aries.Inventory.HomeProfilePage.ChangeState(self:GetCommixState());
	MyCompany.Aries.Inventory.HomeProfilePage.ShowPage();
	
	if(destroyAwayBtn)then
		MyCompany.Aries.Inventory.HomeProfilePage.AwayButton_Destroy()
	end
end
--显示仓库列表
function HomeLandCanvas_New:ShowItemLibs()
	local _combinedState = self:GetCommixState();
	if(_combinedState == "master_outside_true")then
		NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/MyHomelandOutdoor.lua");
		MyCompany.Aries.Inventory.MyHomelandOutdoorPage.ShowPage()		
	elseif(_combinedState == "master_inside_true")then
		NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/MyHomelandIndoor.lua");
		MyCompany.Aries.Inventory.MyHomelandIndoorPage.ShowPage()
	end
end
--关闭仓库列表
function HomeLandCanvas_New:HideItemLibs()
	local _combinedState = self:GetCommixState();
	if(_combinedState == "master_outside_false")then
		NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/MyHomelandOutdoor.lua");
		MyCompany.Aries.Inventory.MyHomelandOutdoorPage.ClosePage()		
	elseif(_combinedState == "master_inside_false")then
		NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/MyHomelandIndoor.lua");
		MyCompany.Aries.Inventory.MyHomelandIndoorPage.ClosePage()
	end
end
--显示家园访问列表面板
function HomeLandCanvas_New:ShowHomeInfo()
	
	local s = self.guests;
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/HomeDetail.lua");
	local bean = self:GetReadOnlyBean();
	MyCompany.Aries.Inventory.HomeDetailPage.Bind(self,self.nid,bean,s)
	MyCompany.Aries.Inventory.HomeDetailPage.ShowPage()
end
--显示礼物盒面板
function HomeLandCanvas_New:ShowGiftInfo()
	if(System.options.disable_trading) then
		_guihelper.MessageBox("因个人账户安全原因，物品交换/邮件系统进行维护。预计将在下次更新后修复功能，若提前恢复交易功能不做另行通知。");
		return;
	end

	local bean = self:GetReadOnlyBean();
	if(self.roleState == "guest")then
		if(self.giftinfo)then
			if(self.giftinfo.giftcnt < self.giftinfo.boxcnt)then
				NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
				local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
				local can_pass = DealDefend.CanPass();
				if(not can_pass)then
					return
				end
				NPL.load("(gl)script/apps/Aries/Inventory/TabGiveGift.lua");
				MyCompany.Aries.Inventory.TabGiveGiftPage.ShowPage(self.nid);
				MyCompany.Aries.Inventory.TabGiveGiftPage.SetNID(self.nid)
				MyCompany.Aries.Inventory.TabGiveGiftPage.BindBean(bean)
			else
				if(bean and bean.homemaster_info)then
					local _name = bean.homemaster_info.nickname or self.nid;
					local content = string.format("[%s]的礼物盒已经满了，不能再收礼物了，下次再来送礼物吧。",_name);
					_guihelper.MessageBox(content,nil, _guihelper.MessageBoxButtons.OK,nil,{OK = "知道了"});
								
							--注意：现在每次进入家园，点击都有效
							local guests = self.guests;
							if(guests and not guests.hasRemindForReceiver)then
								guests.hasRemindForReceiver = true;
												
								-- 提醒家园的主人
								NPL.load("(gl)script/apps/Aries/Mail/MailClient.lua");
								MyCompany.Aries.Quest.Mail.MailClient.SendMessage({
									msg_type = "gift_remind",
									sender = Map3DSystem.User.nid,
									mail_id = 8001,
								},self.jid);

							end
				end
			end
		end
	else
		NPL.load("(gl)script/apps/Aries/Inventory/TabReceiveGift.lua");
		MyCompany.Aries.Inventory.TabReceiveGiftPage.ShowPage();
		MyCompany.Aries.Inventory.TabReceiveGiftPage.SetNID(self.nid)
		MyCompany.Aries.Inventory.TabReceiveGiftPage.BindBean(bean)
	end
end
--编辑家园
function HomeLandCanvas_New:EditHouse()
	--如果已经在编辑状态 只显示物品列表
	if(self.editingState == "true")then
		self:ShowItemLibs();
		return
	end
	self.editingState = "true";
	self.nodeProcessor.editMode = "edit";
	
	--所有的室内物品 取消物理
	self:SetAllNodePhysics_Indoor(false);
	self:UnSelected();
	self:ShowItemLibs();
	--刷新按钮
	self:RefreshHomeProfilePage(true)
	
	--暂停跟随宠物的说话
	self:PauseFollowPetState(true);
	
	--关闭传送门
	self:CloseDoor();
end
--保存家园
function HomeLandCanvas_New:SaveHouse()
	self.editingState = "false";
	self.nodeProcessor.editMode = "view";
	--如果是拖拽状态 停止它
	--self.nodeProcessor:DirectlyStopDragSelectedNode();
	
	--所有的室内物品恢复物理
	self:SetAllNodePhysics_Indoor(true);
	self:UnSelected();
	
	self:HideItemLibs();
	--刷新按钮
	self:RefreshHomeProfilePage();
	
	--恢复跟随宠物的说话
	self:PauseFollowPetState(false);
	
	--确保所有的物体 不显示选中状态
	self:HideNodeSelected();
	--恢复半径
	self.buildNodeRadius = 1;
	self.buildNodeAngle = 0;
	
	--打开传送门
	self:OpenDoor();
end
--清空可见的node
function HomeLandCanvas_New:ClearVisualNodes()
	self:UnSelected();
	local node;
	for node in self.rootNode:Pre() do
		if(node)then
			node:Detach();
			if(node.CloseDoor)then
				node:CloseDoor();
			end
		end
	end	
	--如果有音乐在播放，停止它
	if(self.wavefile)then
		--ParaAudio.StopWaveFile(self.wavefile, true);
		local audioSource = AudioEngine.CreateGet(self.wavefile);
		audioSource:stop();
		self.wavefile = nil;
	end
	
	--在室外
	self.locationState = "outside";
	self.inRoomNode = nil;
	
	--刷新按钮
	self:RefreshHomeProfilePage();
	--销毁按钮
	self:CloseAllPanelPage();
	--重置房屋的监听
	CommonCtrl.Display3D.HouseNode.ClearAndResetGlobalData();
end
--离开家园
function HomeLandCanvas_New:Away()
	commonlib.echo("============away");
	local follow_pet_state = self.follow_pet_state;
	if(follow_pet_state)then
		follow_pet_state:Stop()
	end
	MyCompany.Aries.Pet.StopDragonPetOthers();
	if(self.canvas)then
		self.canvas:UnHook();
	end
	--如果有音乐在播放，停止它
	if(self.wavefile)then
		--ParaAudio.StopWaveFile(self.wavefile, true);
		local audioSource = AudioEngine.CreateGet(self.wavefile);
		audioSource:stop();
		self.wavefile = nil;
	end
	--销毁按钮
	self:CloseAllPanelPage();
	MyCompany.Aries.Inventory.HomeProfilePage.ClosePage();
	MyCompany.Aries.Inventory.HomeDetailPage.ClosePage();
	--重置房屋的监听
	CommonCtrl.Display3D.HouseNode.ClearAndResetGlobalData();
end
--取消选中的物体
function HomeLandCanvas_New:UnSelected()
	if(self.nodeProcessor)then
		self.nodeProcessor:UnSelected();
	end
end
---------------------------------------------------
--创建node
---------------------------------------------------
function HomeLandCanvas_New.BuildNodeTimer_Update(timer)
	if(timer and timer.holder)then
		local self = timer.holder;
		self.isBuildingNode = false;
	end
end
function HomeLandCanvas_New:CanBuildNodeFromItem(type)
	if(not type)then return end
	if(self.editingState ~= "true")then
		--在非编辑状态下只有选中花圃 才能种植 植物
		if(type == "PlantE")then
			local selectedNode,linkedNode = self.nodeProcessor:GetSelectedNodeAndLinkedNode();
			--关联花圃
			if(selectedNode)then
				local n_type = selectedNode:GetType();
				if(n_type == "Grid")then
					local r = selectedNode:HasLinkedNode();
					if(not r)then
						return true
					end
				end
			end
		end
		return false;
	else
		if(type == "PlantE")then
			return false;
		end
		return true;
	end
	
end
--根据物品系统创建node
function HomeLandCanvas_New:BuildNodeFromItem(type,gsItem,guid)
	if(not type or not gsItem or not guid)then return end
	--记录创建物品的数量
	local createdNodeNum = self:GetChildCount();
	commonlib.echo("================homeland created node num");
	commonlib.echo(createdNodeNum);
	--创建物品数量限制
	local max_item_count = MyCompany.Aries.VIP.GetHomeLandItemMaxCount() or 600;
	if(createdNodeNum > max_item_count)then
		local s = format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你的家园中只能放下%d件物品，已经达到上限了，不能放下更多物品了。 魔法星等级越高，能放的物品越多.</div>", max_item_count);
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return
	end
	--判断是否可以创建
	if(not self:CanBuildNodeFromItem(type))then
		return
	end
	if(self.isBuildingNode)then
		_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>你点击的速度太快了！</div>");
		return
	end
	self.isBuildingNode = true;
	--if(self.limitBuildNodeTimer)then
		----500毫秒后停止
		--self.limitBuildNodeTimer:Change(500,nil);
	--end
	--绝对坐标
	local x,y,z = self:GetBuildNodePostion();
	local assetfile = gsItem.assetfile;
	local node;
	
	local indoor_node;
	--获取起点 室外 室内模型的起点不一样
	--在保存的时候需要转换为相对坐标
	local origin = self:GetNodeOrigin(type);
	
	if(type == "Grid")then
		node = CommonCtrl.Display3D.SeedGridNode:new{
			x = x,--绝对坐标
			y = y,
			z = z,
			assetfile = assetfile or "model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x",
			
		};
	elseif(type == "OutdoorHouse")then
		node = CommonCtrl.Display3D.HouseNode:new{
			x = x,--绝对坐标
			y = y,
			z = z,
			--assetfile = "model/01building/v5/01house/PoliceStation/Indoor.x",
			--assetfile = "model/01building/v5/01house/PoliceStation/PoliceStation.x",
			assetfile = assetfile,
			type = "OutdoorHouse",
			default_openstate = false,--在编辑状态下，关闭自动传送的功能
			ReadyGoFunc = HomeLandCanvas_New.GotoFunc,
		};
		--室内默认起点
		local indoorOrigin = self.indoorOrigin;
		
		local indoor_table = Map3DSystem.App.HomeLand.HomeLandConfig.ParseHomeEntry(gsItem.descfile);
		local indoor_assetfile;
		if(indoor_table)then
			indoor_assetfile = indoor_table.indoor;
		end
		commonlib.echo("=============indoor_assetfile");
		commonlib.echo(indoor_assetfile);
		commonlib.echo(indoorOrigin);
				
		indoor_node = CommonCtrl.Display3D.HouseNode:new{
			x = indoorOrigin.x,--绝对坐标
			y = indoorOrigin.y,
			z = indoorOrigin.z,
			assetfile = indoor_assetfile or "model/01building/v5/01house/PoliceStation/Indoor.x",
			type = "IndoorHouse",
			--在创建房屋的时候，同时创建室内，室内的传送门，可以让它打开，不打开的话，在第一次进入室内的时候，好像室内的传送门没有显示出来
			default_openstate = true,
			ReadyGoFunc = HomeLandCanvas_New.GotoFunc,
		};
		
		
		--关联node
		node:SetLinkedHouse(indoor_node);
		indoor_node:SetLinkedHouse(node);
	else
		node = CommonCtrl.Display3D.HomeLandCommonNode:new{
			x = x,--绝对坐标
			y = y,
			z = z,
			assetfile = assetfile or "model/06props/shared/pops/muzhuang.x",
			type = type,
		};
		--如果现在身在室内
		if(self.inRoomNode and self.locationState == "inside")then
			local uid = self.inRoomNode:GetUID();
			--室内物体是属于哪个 室外房屋模型的
			node:SetOutdoorNodeUID(uid);
		end
	end
	--如果没有node 返回
	if(not node)then 
		self.isBuildingNode = false;
		return 
	end
	--关联item的guid
	node:SetGUID(guid);
	local gsid = gsItem.gsid;
	--关联item的gsid
	node:SetGSID(gsid);
	--传入起点坐标，保存相对坐标
	local clientdata = node:ClassToMcml({origin = origin});
	commonlib.echo("==============build a node:");
	commonlib.echo({type = type, origin = origin});
	commonlib.echo(clientdata);
	if(type == "PlantE")then
		--可种植 只能在室外
		local canLinkedGridNode = nil;
		local selectedNode,linkedNode = self.nodeProcessor:GetSelectedNodeAndLinkedNode();
		--关联花圃
		if(selectedNode)then
			local n_type = selectedNode:GetType();
			if(n_type == "Grid")then
				local r = selectedNode:HasLinkedNode();
				if(not r)then
					selectedNode:SetGridInfo(1,node:GetUID());
					node:SetSeedGridNodeUID(selectedNode:GetUID());
					
					--记住暂时放下植物的花圃
					canLinkedGridNode = selectedNode;
				end
			end
		end

		--保存字符串 在花圃吸附植物后 植物的坐标有变化
		local clientdata = node:ClassToMcml({origin = origin});	
		
		Map3DSystem.Item.ItemManager.GrowHomeLandPlant(guid, clientdata, function(msg)
			self.isBuildingNode = false;
			commonlib.echo("added a plant:");
			commonlib.echo(msg);
			if(msg and msg.issuccess_setclientdata == false)then	
				commonlib.echo("==========setclientdata failed");
				--取消关联
				if(canLinkedGridNode)then
					canLinkedGridNode:SetGridInfo(1,nil);
					node:SetSeedGridNodeUID(nil);
				end
				return
			end
			if(msg and msg.issuccess)then
				--创建出来
				self.rootNode:AddChild(node);
				node:SetGUID(msg.appended_guid);
				--根据返回的信息，初始化植物成长的数据
				local bean = msg;
				self:BindNode_PlantE(node,bean)
				
				if(canLinkedGridNode)then
					--重新吸附植物 因为在AddChild之前 不能吸附
					canLinkedGridNode:SnapToGrid();
				end
	
				
				--清空选中的物体
				self:UnSelected();
				--创建后默认被选中
				self:DirectDispatchChildSelectedEvent(node)
				
				local x,y,z = node:GetPosition();
				--invoke 
				local msg = { 
						aries_type = "SeedPlanted",--种植
						wndName = "homeland",
						x = x,
						y = y,
						z = z,
					};
				
				commonlib.echo("Invoke SeedPlanted");
				commonlib.echo(msg);
				CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
			else
				--取消关联
				if(canLinkedGridNode)then
					canLinkedGridNode:SetGridInfo(1,nil);
					node:SetSeedGridNodeUID(nil);
				end
				self.isBuildingNode = false;
			end
		end,nil,function()
			--timeout callback
			self.isBuildingNode = false;
			--取消关联
			if(canLinkedGridNode)then
				canLinkedGridNode:SetGridInfo(1,nil);
				node:SetSeedGridNodeUID(nil);
			end
			commonlib.echo("==============build a node time out");
		end);
					
	elseif(type == "OutdoorHouse")then
		--房屋入口
		Map3DSystem.Item.ItemManager.GrowHomeLandHouse(guid, clientdata, function(msg)
			self.isBuildingNode = false;
			commonlib.echo("added a house:");
			commonlib.echo(msg);
			if(msg and msg.issuccess_setclientdata == false)then	
				commonlib.echo("==========setclientdata failed");
				return
			end
			if(msg and msg.issuccess == true) then
				--创建出来
				commonlib.echo("====before outdoor house1");
				self.rootNode:AddChild(node);
				commonlib.echo("====after outdoor house1");
				node:SetGUID(msg.appended_guid);
				
				commonlib.echo("====before outdoor house2");
				commonlib.echo(indoor_node:GetEntityParams());
				self.rootNode:AddChild(indoor_node);
				commonlib.echo("====after outdoor house2");
				
				node.holder = self;
				indoor_node.holder = self;
				node:EnabledAssetLoaded();
				indoor_node:EnabledAssetLoaded();
				
				
				--绑定房屋的成长数据
				local bean = msg;
				self:BindNode_OutdoorHouse(node,bean);
				
				--清空选中的物体
				self:UnSelected();
				--创建后默认被选中
				self:DirectDispatchChildSelectedEvent(node)
				
			end
		end,nil,function()
			--timeout callback
			self.isBuildingNode = false;
			commonlib.echo("==============build a node time out");
		end);
	else
		--普通物品
		Map3DSystem.Item.ItemManager.AppendHomeLandItem(guid, clientdata, function(msg)
			self.isBuildingNode = false;
			commonlib.echo("added a normal object:");
			commonlib.echo(msg);
			if(msg and msg.issuccess_setclientdata == false)then	
				commonlib.echo("==========setclientdata failed");
				return
			end
			if(msg and msg.issuccess == true) then
				--创建出来
				self.rootNode:AddChild(node);
				node:SetGUID(msg.appended_guid);
				
				--清空选中的物体
				self:UnSelected();
				--创建后默认被选中
				self:DirectDispatchChildSelectedEvent(node)
				
				local internalType = self:GetExtendsObjectType_OutdoorOther(node);
				--如果是音乐盒
				if(internalType == "MusicBox")then
					self:PlayMusic(node,true);
				end
				--设置物理 室内的物体没有物理
				self:EnablePhysics(node);
				local x,y,z = node:GetPosition();
				commonlib.echo({x,y,z});
				local hook_msg = { 
						aries_type = "OnItemMovedFromStoreToHomeland", 
						wndName = "homeland",
						x = x,
						y = y,
						z = z,
				};
				CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
			end
		end,nil,function()
			--timeout callback
			self.isBuildingNode = false;
			commonlib.echo("==============build a node time out");
		end);
	end
end
function HomeLandCanvas_New:DestroyNode()
	local selectedNode,linkedNode = self.nodeProcessor:GetSelectedNodeAndLinkedNode();
	if(selectedNode)then
		if(linkedNode)then
			_guihelper.MessageBox("<div style='margin-left:15px;margin-top:15px;text-align:center'>花圃上面有植物，不能被回收！</div>");
			return 
		end
		local type = selectedNode:GetType();
		if(type == "OutdoorHouse")then
			NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
			local guid = selectedNode:GetGUID();
			local gsItem,item = self:GetGlobalItem(guid);
			local name = "";
			if(gsItem and gsItem.template)then
				name = gsItem.template.name;
			end
			local s = string.format("<div style='margin-left:15px;margin-top:15px;text-align:center'>收回[%s]会把小屋中的家具一同收回仓库。你确定要收回吗？</div>",name);
			_guihelper.Custom_MessageBox(s,function(result)
				if(result == _guihelper.DialogResult.Yes)then
					local link_outdoor_nodes = self:GetIndoorNodes(selectedNode) or {};
					commonlib.echo("=================check link_outdoor_nodes in HomeLandCanvas_New:DestroyNode()");
					if(link_outdoor_nodes)then
						local k,node;
						for k,node in ipairs(link_outdoor_nodes) do
							local type = node:GetType();
							local origin = self:GetNodeOrigin(type);
							local s = node:ClassToMcml({origin = origin});
							commonlib.echo(s);
						end
						table.insert(link_outdoor_nodes,selectedNode);
						local cur_index = 1;
						function removeNodes(nodes)
							if(not nodes)then return end
							local node = nodes[cur_index];
							if(not node)then return end
							local guid = node:GetGUID();
							local ItemManager = Map3DSystem.Item.ItemManager;
							commonlib.echo("==============guid in DestroyNode");
							commonlib.echo(guid);
							ItemManager.RemoveHomeLandItem(guid, function(msg)
									commonlib.echo(msg);
									if(msg.issuccess == true) then
										node:Detach();
										cur_index = cur_index + 1;
										removeNodes(nodes)
									end
										
							end);
						end
						commonlib.echo("============before remove indoornode");
						removeNodes(link_outdoor_nodes)
						commonlib.echo("============after remove indoornode");
						
						self:UnSelected();
					end
				end
			end,_guihelper.MessageBoxButtons.YesNo);
		else
			self:__DestroyNode(selectedNode);
		end
	end
end
function HomeLandCanvas_New:__DestroyNode(selectedNode)
	if(selectedNode)then
		local guid = selectedNode:GetGUID();
		commonlib.echo("============remove");
		commonlib.echo(guid);
		local ItemManager = Map3DSystem.Item.ItemManager;
		
		--检查扩展的node
		local internalType = self:GetExtendsObjectType_OutdoorOther(selectedNode);
		--如果是音乐盒
		if(internalType == "MusicBox")then
			--因为回收仓库，所以停止播放音乐
			self:PlayMusic(selectedNode,false);
		end
		ItemManager.RemoveHomeLandItem(guid, function(msg)
				commonlib.echo("============after remove");
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					selectedNode:Detach();
					self:UnSelected();
					
				end
					
		end);
		
	end
end
--直接发送 node选中事件
function HomeLandCanvas_New:DirectDispatchChildSelectedEvent(node)
	if(self.canvas)then
		self.canvas:DirectDispatchChildSelectedEvent(node);
	end
end
--取消所有物体显示
function HomeLandCanvas_New:HideNodeSelected()
	local node;
	for node in self.rootNode:Next() do
		if(node)then
			local entity = node:GetEntity();
			if(entity)then
				ParaSelection.AddObject(entity,-1);
			end
		end
	end
end
--第一个位置为脚下
function HomeLandCanvas_New:GetBuildNodePostion()
	local x,y,z = ParaScene.GetPlayer():GetPosition();
	--如果是在室内 只允许在脚下创建物体
	if(self.inRoomNode and self.locationState == "inside")then
		return x,y,z;
	end
	local old_x,old_y,old_z = self.last_x,self.last_y,self.last_z;
	if(old_x ~= x or old_y ~= y or old_z ~= z)then
		--新位置
		self.buildNodeRadius = 0;
		self.buildNodeAngle = 0;
		self.last_x,self.last_y,self.last_z = x,y,z;
	end

	if(self.buildNodeRadius == 0 and self.buildNodeAngle == 0)then
		self.buildNodeRadius = self.buildNodeRadius + self.buildNodeRadiusStep;
		return x,y,z;
	else
		self.buildNodeAngle = self.buildNodeAngle + self.buildNodeAngleStep;
		if(self.buildNodeAngle > self.buildNodeMaxAngle)then
			self.buildNodeAngle = 0;
			
			self.buildNodeRadius = self.buildNodeRadius + self.buildNodeRadiusStep;
			if(self.buildNodeRadius > self.buildNodeMaxRadius)then
				self.buildNodeRadius = 0;
			end
		end
	end
	
	local angle = self.buildNodeAngle * 3.14/180;
	x = x + self.buildNodeRadius * math.cos(angle);
	z = z - self.buildNodeRadius * math.sin(angle);
	return x,y,z;
end
---------------------------------------------------
--[[
室内模型统一放在一个高度
进入某个室内，把其他室内物体visible = false
--]]
---------------------------------------------------
function HomeLandCanvas_New.GotoFunc(node)
	if(not node or not node.linked_node or not node.holder)then return end
	--self
	local self = node.holder;
	--传送的绝对坐标
	local x,y,z = node.linked_node:GetAbsComeBackPosition();
	commonlib.echo("===============ready go to");
	commonlib.echo({x,y,z});
	
	local type = node.linked_node:GetType();
	if(type == "OutdoorHouse")then
		self:ComeoutHouse(x,y,z);
	elseif(type == "IndoorHouse")then
		self:ComeinHouse(node,node.linked_node,x,y,z);
	end
	
end
--进入outdoorNode
function HomeLandCanvas_New:ComeinHouse(outdoorNode,indoorNode,x,y,z)
	commonlib.echo("===============ComeinHouse");
	commonlib.echo({x,y,z});
	if(not outdoorNode or not indoorNode)then return end
	commonlib.echo(outdoorNode:GetUID());
	local node;
	local uid = outdoorNode:GetUID();
	for node in self.rootNode:Next() do
		if(node)then
			local type = node:GetType();
			local belongto_outdoor_uid = node:GetOutdoorNodeUID();
			
			if(uid == belongto_outdoor_uid)then
				node:SetVisible(true);
			else
				--隐藏node
				node:SetVisible(false);
			end
		end
	end
	indoorNode:SetVisible(true);
	--在室内
	self.locationState = "inside";
	self.inRoomNode = outdoorNode;
	
	if(x and y and z)then
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x= x, y = y, z = z});
		ParaScene.GetPlayer():SetFacing(3.14);
	end
	self:CloseDoor()
	self:OpenDoor()
	--刷新按钮
	self:RefreshHomeProfilePage();
end
--离开outdoorNode
function HomeLandCanvas_New:ComeoutHouse(x,y,z)
	commonlib.echo("===============ComeoutHouse");
	commonlib.echo({x,y,z});
	if(x and y and z)then
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x= x, y = y, z = z});
		ParaScene.GetPlayer():SetFacing(3.14);
	end
	
	local node;
	for node in self.rootNode:Next() do
		if(node)then
			node:SetVisible(true);
			if(node.OpenDoor)then
				node:OpenDoor();
			end
		end
	end
	--在室外
	self.locationState = "outside";
	self.inRoomNode = nil;
	
	self:OpenDoor()
	--刷新按钮
	self:RefreshHomeProfilePage();
	
end
function HomeLandCanvas_New:OpenDoor()
	local node;

	--如果在室内
	if(self.inRoomNode)then
		local linkNode = self.inRoomNode:GetLinkedHouse();
		for node in self.rootNode:Next() do
			--打开两个相关的 node
			if(node == self.inRoomNode or node == linkNode)then
				if(node.OpenDoor)then
					node:OpenDoor();
					commonlib.echo("==========open");
					commonlib.echo(node:GetUID());
				end
			else
				if(node.CloseDoor)then
					node:CloseDoor();
					commonlib.echo("==========close");
					commonlib.echo(node:GetUID());
				end
			end
		end
	else
		for node in self.rootNode:Next() do
			if(node and node.OpenDoor)then
				node:OpenDoor();
			end
		end
	end
end
function HomeLandCanvas_New:CloseDoor()
	local node;
	for node in self.rootNode:Next() do
		if(node and node.CloseDoor)then
			node:CloseDoor();
		end
	end
end
function HomeLandCanvas_New:SaveSingleNodeClientData(node,callbackFunc)
	if(node)then
		local ItemManager = System.Item.ItemManager;
		--在自己家园
		if(self.nid and self.nid == Map3DSystem.User.nid)then
			local type = node:GetType();
			local origin = self:GetNodeOrigin(type);
			local clientdata = node:ClassToMcml({origin = origin});
			local guid = node:GetGUID();
			clientdata = string.gsub(clientdata, "AssetFile=[^:]- ", "AssetFile=\"$assetfile$\" ");
			commonlib.echo("============before SaveSingleNodeClientData");
			commonlib.echo(clientdata);
			ItemManager.SetClientData(guid,clientdata,function(msg_setclientdata)
				commonlib.echo("============after SaveSingleNodeClientData");
				commonlib.echo(msg_setclientdata);
				if(callbackFunc and type(callbackFunc) == "function")then
					callbackFunc({
						
					});
				end
			end);
		end
	end
end
---------------------------------------------------
--ToString
---------------------------------------------------
function HomeLandCanvas_New:ToString()
	local node;
	local r = "";
	commonlib.echo("==================save homeland data to string");
	for node in self.rootNode:Next() do
		local isChange = node:GetPropertyIsChanged();
		if(isChange)then
			local type = node:GetType();
			local origin = self:GetNodeOrigin(type);
			local s = node:ClassToMcml({origin = origin});
			commonlib.echo(s);
			r = r..s.."\r\n";
		end
	end	
	commonlib.echo("==================end save homeland data to string");
	return r;
end
-------------------------------------------------
--获取家园里面所有植物的成长情况
--[[
	local r = {
		need_water = {},
		need_debug = {},
		can_gain = {},
	}
--]]
-------------------------------------------------
function HomeLandCanvas_New:GetPlantsAllInfo()
	local need_water = {};
	local need_debug = {};
	local can_gain = {};
	local node;
	for node in self.rootNode:Next() do
		local type = node:GetType();
		if(type == "PlantE")then
			local bean = node.bean;
			if(bean)then
				--需要浇水
				if(bean.isdroughted)then
					table.insert(need_water,node);
				end
				--需要除虫
				if(bean.isbuged)then
					table.insert(need_debug,node);
				end
				--可以收获
				if(bean.feedscnt and bean.feedscnt > 0)then
					table.insert(can_gain,node);
				end
			end
		end
	end	
	return need_water,need_debug,can_gain;
end
--给所有需要浇水的植物浇水
function HomeLandCanvas_New:WaterAllPlants(callbackFunc)
	local need_water,need_debug = self:GetPlantsAllInfo();
	local len = 0;
	if(need_water)then
		len = #need_water;
	end
	if(len <= 0)then return end
	local ids = "";
	local k,v;
	local node_map = {};--植物map
	for k,v in ipairs(need_water) do
		local bean = v.bean;
		if(bean and bean.id)then
			node_map[bean.id] = v;--map
			local id = tostring(bean.id);
			if(k == 1)then
				ids = id;
			else
				ids = ids..","..id;
			end
		end
	end
	if(ids == "")then return end
	local msg = {
		nid = Map3DSystem.User.nid,
		ids = ids,
	}
	commonlib.echo("=========before water all plants");
	commonlib.echo(msg);
	paraworld.homeland.plantevolved.WaterPlants(msg,"",function(msg)
		commonlib.echo("=========after water all plants");
		commonlib.echo(msg);
		if(msg and msg.issuccess)then
			local list = msg.list;
			if(list)then
				local k,v;
				for k,v in ipairs(list) do
					local id = v.id;
					if(node_map[id])then
						local node = node_map[id];
						local bean = v;
						self:BindNode_PlantE(node,bean)
					end
				end
			end
			if(callbackFunc)then
				callbackFunc();
			end
		end
	end);
end
--给所有需要除虫的植物除虫
function HomeLandCanvas_New:DebugAllPlants(callbackFunc)
	local need_water,need_debug = self:GetPlantsAllInfo();
	local len = 0;
	if(need_debug)then
		len = #need_debug;
	end
	if(len <= 0)then return end
	local ids = "";
	local k,v;
	local node_map = {};--植物map
	for k,v in ipairs(need_debug) do
		local bean = v.bean;
		if(bean and bean.id)then
			node_map[bean.id] = v;--map
			local id = tostring(bean.id);
			if(k == 1)then
				ids = id;
			else
				ids = ids..","..id;
			end
		end
	end
	if(ids == "")then return end
	local msg = {
		nid = Map3DSystem.User.nid,
		ids = ids,
	}
	commonlib.echo("=========before debug all plants");
	commonlib.echo(msg);
	paraworld.homeland.plantevolved.Debug(msg,"",function(msg)
		commonlib.echo("=========after debug all plants");
		commonlib.echo(msg);
		if(msg and msg.issuccess)then
			local list = msg.list;
			if(list)then
				local k,v;
				for k,v in ipairs(list) do
					local id = v.id;
					if(node_map[id])then
						local node = node_map[id];
						local bean = v;
						self:BindNode_PlantE(node,bean)
					end
				end
			end
			if(callbackFunc)then
				callbackFunc();
			end
		end
	end);
end
--是否可以收获某种植物
--如果已经拥有的数量 + 将要收获的数量大于 100，返回false
function HomeLandCanvas_New:CanGetFruit(bean)
	if(not bean)then return end;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local equipGSItem = ItemManager.IfEquipGSItem;
	
	--- map of plan_gsid --- fruit_gisd 
	local plant_fruit_map = Map3DSystem.App.HomeLand.HomeLandGateway.plant_fruit_map;
	local id = bean.id;
	local gsItem = self:GetGlobalItem(id);
	local can_get_fruit = bean.feedscnt or 0;--可以收获的数量
	local plant_gsid = -1;
	
	if(gsItem)then
		plant_gsid =  gsItem.gsid;
	end
	
	local fruit_gisd;
	--如果是糖豆豆植物
	if(plant_gsid == 30134)then
		fruit_gisd = 9505;
	else
		fruit_gisd = plant_fruit_map[plant_gsid];
	end
	if(fruit_gisd)then
		local fruit_gsItem = ItemManager.GetGlobalStoreItemInMemory(fruit_gisd);
		local maxcopiesinstack = 100;
		if(fruit_gsItem and fruit_gsItem.template)then
			maxcopiesinstack = fruit_gsItem.template.maxcopiesinstack;
		end
		local __,__,__,copies = hasGSItem(fruit_gisd);
		copies = copies or 0;
		commonlib.echo("==========max fruit number:"..fruit_gisd);
		commonlib.echo(maxcopiesinstack);
		commonlib.echo("==========now fruit number:"..fruit_gisd);
		commonlib.echo(copies);
		commonlib.echo("==========will get fruit number:"..fruit_gisd);
		commonlib.echo(can_get_fruit);
		commonlib.echo("==========can get fruit number:"..fruit_gisd);
		commonlib.echo(maxcopiesinstack - copies);
		copies = copies + can_get_fruit
		if(copies > maxcopiesinstack)then
			return
		end
	end
	return true;
end
--是否可以全部收获，如果某个果实数量已经超过限制就返回false
function HomeLandCanvas_New:CanGetAllFruits()
	local need_water,need_debug,can_gain = self:GetPlantsAllInfo();
	if(can_gain)then
		for k,v in ipairs(can_gain) do
			local bean = v.bean;
			if(bean)then
				local result = self:CanGetFruit(bean);
				--如果任意一个不能收 返回nil
				if(not result)then
					return;
				end
			end
		end
	end
	return true;
end
--收获所有的果实
function HomeLandCanvas_New:GetAllFruits(callbackFunc)
	local need_water,need_debug,can_gain = self:GetPlantsAllInfo();
	local len = 0;
	if(can_gain)then
		len = #can_gain;
	end
	if(len <= 0)then return end
	local ids = "";
	local k,v;
	local node_map = {};--植物map
	for k,v in ipairs(can_gain) do
		local bean = v.bean;
		if(bean and bean.id)then
			node_map[bean.id] = v;--map
			local id = tostring(bean.id);
			if(k == 1)then
				ids = id;
			else
				ids = ids..","..id;
			end
		end
	end
	if(ids == "")then return end
	local msg = {
		ids = ids,
	}
	commonlib.echo("=========before gain all of fruits");
	commonlib.echo(msg);
	paraworld.homeland.plantevolved.GainFruits(msg,"",function(msg)
		commonlib.echo("=========after gain all of fruits");
		commonlib.echo(msg);
		if(msg and msg.issuccess)then
			for k,v in ipairs(can_gain) do
				local node = v;
				local linked_uid = node:GetSeedGridNodeUID();
				local linked_node = self.rootNode:GetChildByUID(linked_uid);
				if(linked_node and linked_node.SetGridInfo)then
					--取消链接
					linked_node:SetGridInfo(1,"");
				end
				node:Detach();
			end
			--刷新bag
			Map3DSystem.Item.ItemManager.GetItemsInBag(12, "plantevolved", function(msg) 
			
			end, "access plus 0 day");
			--关闭操作植物的面板
			MyCompany.Aries.Inventory.PlantViewPage_New.ClosePage();
			if(callbackFunc)then
				callbackFunc();
			end
		end
	end);
end
--获取这个房屋室内所有的物品
--@param node:房屋模型
function HomeLandCanvas_New:GetIndoorNodes(outdoorNode)
	if(not outdoorNode)then return end
	local node;
	local outdoor_uid = outdoorNode:GetUID();
	local result;
	commonlib.echo("================GetIndoorNodes");
	commonlib.echo(outdoor_uid);
	commonlib.echo("============");
	for node in self.rootNode:Next() do
		if(node)then
			if(outdoor_uid == node:GetOutdoorNodeUID())then
				if(not result)then
					result = {};
				end
				commonlib.echo(node:GetUID());
				table.insert(result,node);
			end
		end
	end
	return result;
end