--[[
Title: HomeLandGateway
Author(s): Leio
Date: 2009/11/8, 2010/9/12 by LiXizhi (now works with WorldManager.lua)
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
local nid = Map3DSystem.User.nid;
Map3DSystem.App.HomeLand.HomeLandGateway.Gohome(nid);
Map3DSystem.App.HomeLand.HomeLandGateway.EditHome();
Map3DSystem.App.HomeLand.HomeLandGateway.SaveHome();
Map3DSystem.App.HomeLand.HomeLandGateway.Away();
Map3DSystem.App.HomeLand.HomeLandGateway.ClearVisualNodes();

-- Added by LiXizhi 2010.1.25. for personal world. 
Map3DSystem.App.HomeLand.HomeLandGateway.GoWorld();

local rootNode = Map3DSystem.App.HomeLand.HomeLandGateway.homelandCanvas.rootNode;
if(rootNode)then
	local node;
	for node in rootNode:Next() do
		if(node)then
			commonlib.echo("===");
			commonlib.echo(node:GetVisible());
			node:SetVisible(true);
			commonlib.echo(node:GetVisible());
		end
	end
end
Map3DSystem.App.HomeLand.HomeLandGateway.homelandCanvas:OpenDoor()
local x,y,z
Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x= x, y = y, z = z});

local player = ParaScene.GetPlayer();
commonlib.echo({player:GetPosition()});
local att = ParaCamera.GetAttributeObject();
commonlib.echo(	{
	att:GetField("CameraObjectDistance", CameraObjectDistance),
	att:GetField("CameraLiftupAngle", CameraLiftupAngle),
	att:GetField("CameraRotY", CameraRotY) 
});
MyCompany.Aries.Player.AddMoney(100000,function(msg) end)
---
local gsid = 10131;
local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
if(command) then
	command:Call({gsid = gsid});
end
--------------------
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
local gsid = 50326;
local bHas,guid = ItemManager.IfOwnGSItem(gsid);
if(guid)then
	ItemManager.DestroyItem(guid,1);
end
--------------------
进入家园执行这个：
--浇水
Map3DSystem.App.HomeLand.HomeLandGateway.WaterAllPlants()
--除虫
Map3DSystem.App.HomeLand.HomeLandGateway.DebugAllPlants(）
-- 收获
Map3DSystem.App.HomeLand.HomeLandGateway.GetAllFruits()
-----------------------
ItemManager.ExtendedCost(nil, nil, nil, function(msg)end, function(msg) 
			commonlib.echo(msg);
		end);
ItemManager.PurchaseItem(50045, 1, function(msg) end, function(msg)
	if(msg) then
	end
end);	
local bean = MyCompany.Aries.Player.GetMyJoybeanCount();

local player = ParaScene.GetPlayer();
local x,y,z = player:GetPosition();
local pos = string.format("{ %f, %f, %f, }",x,y,z);
ParaMisc.CopyTextToClipboard(pos);


local att = ParaCamera.GetAttributeObject();
att:SetField("CameraRotY", 0);

NPL.load("(gl)script/ide/AudioEngine/AudioEngine.lua");
local AudioEngine = commonlib.gettable("AudioEngine");
local audioSource = AudioEngine.CreateGet("DefaultMusicBox");
audioSource:play2d();

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;


NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
Map3DSystem.App.HomeLand.HomeLandGateway.ShowGiftBox();
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandProvider.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandCanvas_New.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
NPL.load("(gl)script/apps/Aries/Scene/AutoCameraController.lua");
NPL.load("(gl)script/apps/Aries/Creator/WorldCommon.lua");
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPane.lua");
NPL.load("(gl)script/apps/Aries/Desktop/MagicStarArea.lua");

NPL.load("(gl)script/apps/Aries/Team/TeamMembersPage.lua");
local TeamMembersPage = commonlib.gettable("MyCompany.Aries.Team.TeamMembersPage");
local MagicStarArea = commonlib.gettable("MyCompany.Aries.Desktop.MagicStarArea");
local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon")
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");

NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
local HomeLandGateway = commonlib.gettable("Map3DSystem.App.HomeLand.HomeLandGateway");
commonlib.partialcopy(HomeLandGateway, {
	homelandCanvas = nil,--一个家园所有显示的物体都被它管理
	roleState = "guest", -- "master" or "guest"	
	locationState = "outside", -- "outside" or "inside"
	editingState = "false", -- "true" or "false"
	
	nid = nil,
	jid = nil,
	cur_worldPath = nil,
	all_fruits_list = {
		17001,--樱桃
		17002,--菠萝
		17003,--竹子
		17004,--紫藤萝
		17044,--西梅
		17045,--麻烦树
		17046,--梅花
		17076,--金菊
		17085,--康乃馨
		17089,--蒲公英
		17090,--糖卷卷
		17091,--泡泡糖
		17092,--夹心蛋糕
		17098,--苹果
		17097,--玉米
		17099,--香蕉
	},
	plant_fruit_map = {
		[30008] = 17001,--樱桃种子
		[30009] = 17002,--菠萝种子
		[30010] = 17003,--竹子种子
		[30011] = 17004,--紫藤萝种子
		[30096] = 17044,--西梅种子
		[30097] = 17045,--麻烦树种子
		[30098] = 17046,--梅花种子
		[30099] = 17076,--金菊种子
		[30117] = 17085,--康乃馨种子
		[30126] = 17089,--蒲公英种子
		[30131] = 17090,--糖卷卷种子
		[30132] = 17091,--泡泡糖种子
		[30133] = 17092,--夹心蛋糕种子
		[30164] = 17098,--苹果种子
		[30163] = 17097,--玉米种子
		[30165] = 17099,--香蕉种子
	},
	positions = {
		["worlds/myworlds/100611_environmenthomeland"] = nil,
		["worlds/myworlds/100409_candyhomeland"] = { 19957.80, 31.50, 20273.11 },
		["worlds/myworlds/100205_newyearhomeland"] = nil,
		["worlds/myworlds/1211_homeland"] = nil,
	},
	cameras = {
		["worlds/myworlds/100611_environmenthomeland"] = { 15.00, 0.33, -1.54 },
		["worlds/myworlds/100409_candyhomeland"] = { 15.00, 0.17, -1.58 },
		["worlds/myworlds/100205_newyearhomeland"] = { 15.00, 0.32, -1.41 },
		["worlds/myworlds/1211_homeland"] = { 15.00, 0.32, -1.41 },
	},
});


-- Enter personal (local) world, so that map switching logics works as expected.  
-- Added by LiXizhi 2010.1.25. 
function HomeLandGateway.GoWorld(nid)
	local self = HomeLandGateway;
	self.nid = nid or System.User.nid;
	self.is_local_world = true;
	LOG.std("", "debug", "HomeLandGateway", "HomeLandGateway.GoWorld")
end

-- call this function to go to the home land of the specified user. 
function HomeLandGateway.Gohome(nid)
	local self = HomeLandGateway;
	LOG.std("", "debug", "HomeLandGateway", "==================before come in home:%d",nid or -1);
	if(MyCompany.Aries.Player.IsInCombat()) then
		LOG.std("", "info", "HomeLandGateway", "can not visit home when player is in combat");
		return;
	end

	if(not self.is_local_world) then
		if(not nid or self.nid == nid)then
			return;
		end
	else
		self.nid = nil;
		self.is_local_world = false;
	end	
	-- TODO: shall we display some user interface here while waiting for download. 
	Map3DSystem.App.HomeLand.HomeLandProvider.LoadXmlFromServer(nid,function(msg)
		LOG.std("", "debug", "HomeLandGateway", "==============after load homeland client data is fetched from server");
		if(msg and msg.bSucceed)then
			local loadXmlFromServerMsg = msg;
			--load world path
			self.GetWorldPath(nid,function(msg)
				if(msg and msg.path)then
					local path = msg.path;
					HomeLandGateway.Gohome_Successful(nid,loadXmlFromServerMsg,path)
				end
			end);
		end
	end)
end
function HomeLandGateway.GetWorldPath(nid,callbackFunc)
	local self = HomeLandGateway;
	
	function my()
		local ItemManager = System.Item.ItemManager;
		local hasGSItem = ItemManager.IfOwnGSItem;
		--local gsid = 39101;
		--local bHas, guid = hasGSItem(gsid);
		--local count = 0;
		--if(bHas == true) then
			--local item = ItemManager.GetItemByGUID(guid);
			--if(item and item.GetWorldPath) then
				--return item:GetWorldPath();
			--end
		--end
		local item = ItemManager.GetItemByBagAndPosition(0, 22);
		if(item and item.GetWorldPath) then
			return item:GetWorldPath();
		end
	end
	function others(nid)
		local ItemManager = System.Item.ItemManager;
		local hasGSItem = ItemManager.IfOPCOwnGSItem;
		--local gsid = 39101;
		--local bHas, guid = hasGSItem(nid,gsid);
		--local count = 0;
		--if(bHas == true) then
			--local item = ItemManager.GetOPCItemByGUID(nid,guid);
			--if(item and item.GetWorldPath) then
				--return item:GetWorldPath();
			--end
		--end
		local item = ItemManager.GetOPCItemByBagAndPosition(nid, 0, 22);
		if(item and item.GetWorldPath) then
			return item:GetWorldPath();
		end
	end
	local path = Map3DSystem.App.HomeLand.HomeLandConfig.DefaultWorld;
	if(Map3DSystem.User.nid == nid)then
		Map3DSystem.Item.ItemManager.GetItemsInBag(0, "homeland", function(msg)
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc({
					path = my() or path,
				});
			end
	
		end, "access plus 10 minutes");
	
	else
		Map3DSystem.Item.ItemManager.GetItemsInOPCBag(nid,0, "homeland", function(msg)
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc({
					path = others(nid) or path,
				});
			end
	
		end, "access plus 0 day");
	end
end

-- this function is called after home land data is fetched from server to load the home world 
function HomeLandGateway.Gohome_Successful(nid,loadXmlFromServerMsg,worldPath)
	local self = HomeLandGateway;
	if(not loadXmlFromServerMsg or not loadXmlFromServerMsg.custom_sprite3D)then
		_guihelper.MessageBox("failed!");
		return;
	end
	if(not nid or self.nid == nid)then
		return;
	end
	self.nid = nid;
	if(self.homelandCanvas)then
		self.homelandCanvas:Away();
		self.homelandCanvas = nil;
	end
	self.cur_worldPath = worldPath;
	worldPath = worldPath or Map3DSystem.App.HomeLand.HomeLandConfig.DefaultWorld;
	
	local function on_finish()
		QuestTrackerPane.Show(false);
		TeamMembersPage.ShowPage(true);
		MagicStarArea.AttachToRoot();
		-- 移动人物到出生点
		local pos = Map3DSystem.App.HomeLand.HomeLandConfig.DefaultBornPlace;
		local x,y,z = pos.x,pos.y,pos.z;

		local position = self.positions[string.lower(worldPath)] or { x, y, z };
		if(position)then
			x = position[1];
			y = position[2];
			z = position[3];
			Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x = tonumber(x) or 20000, y = tonumber(y) or 30, z = tonumber(z) or 20000});
		end
		local camera = self.cameras[string.lower(worldPath)] or { 15.00, 0.32, -1.41 };
		if(camera)then
			local att = ParaCamera.GetAttributeObject();
			att:SetField("CameraObjectDistance", camera[1]);
			att:SetField("CameraLiftupAngle", camera[2]);
			att:SetField("CameraRotY", camera[3]);
		end
			
		--初始化	
		self.homelandCanvas = Map3DSystem.App.HomeLand.HomeLandCanvas_New:new{
			nid = self.nid,
		}
		LOG.std("", "debug", "HomeLandGateway", "get jid in home:")
		Map3DSystem.App.profiles.ProfileManager.GetJID(self.nid, function(jid)
					LOG.std("", "debug", "HomeLandGateway", "get jid in home successful"..tostring(jid))
					self.jid = jid;
					if(self.homelandCanvas)then
						self.homelandCanvas.jid = jid;
					end
				end)
			
		local custom_sprite3D = loadXmlFromServerMsg.custom_sprite3D;
		self.DrawCanvas(custom_sprite3D)
	
		-- send log information
		paraworld.PostLog({action = "homeland_enter", homeland_owner_nid = nid}, 
			"homeland_enter_log", function(msg)	end);
	
		--创建家园npc 挑战之旗
		self.CreateChallengeFlagNpc();
		self.ForceRefreshBag();
	end
	-- 加载场景			
	System.App.Commands.Call(System.App.Commands.GetDefaultCommand("LoadWorld"), {worldpath = worldPath,nid = tostring(nid), on_finish = on_finish,loadtxt="进入家园中,请稍等(首次需要1-2分钟)",});

end

-- set the position of the user when teleport back to the last world e.x. official world
function HomeLandGateway.SetTeleportBackPosition(PosX, PosY, PosZ)
	WorldManager:SetTeleportBackPosition(PosX, PosY, PosZ);
end

-- set the camera setting of the user when teleport back to the last world e.x. official world
function HomeLandGateway.SetTeleportBackCamera(CameraObjectDistance, CameraLiftupAngle, CameraRotY)
	WorldManager:SetTeleportBackCamera(CameraObjectDistance, CameraLiftupAngle, CameraRotY);
end
--清空可见的node
function HomeLandGateway.ClearVisualNodes()
	local self = HomeLandGateway;
	if(not self.IsInMyHomeland())then return end
	if(self.homelandCanvas)then
		self.homelandCanvas:ClearVisualNodes();
		
		-- 移动人物到出生点
		local pos = Map3DSystem.App.HomeLand.HomeLandConfig.DefaultBornPlace;
		local x,y,z = pos.x,pos.y,pos.z;
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x = tonumber(x) or 20000, y = tonumber(y) or 30, z = tonumber(z) or 20000});
	end
end

-- leave home land to return to public world. 
-- obsoleted: try to call WorldManager:TeleportBackCheckSave()
function HomeLandGateway.Away()
	local self = HomeLandGateway;
	if(not self.IsInHomeland())then
		return
	end
	WorldCommon.LeaveWorld(function(result)
		if(_guihelper.DialogResult.Yes == result or _guihelper.DialogResult.No == result) then
			HomeLandGateway.ReturnToPublicWorld();
		end
	end);
end

-- Leave home or personal world and return to public world implementation.  
-- Please note: if world is being edited, we will allow user to confirm saving or cancel leaving. 
function HomeLandGateway.LeavePersonalWorld()
	WorldCommon.LeaveWorld(function(result)
		if(_guihelper.DialogResult.Yes == result or _guihelper.DialogResult.No == result) then
			HomeLandGateway.ReturnToPublicWorld();
		end
	end);
end

-- return to public world implementation.  
function HomeLandGateway.ReturnToPublicWorld()
	local self = HomeLandGateway;
	if(self.homelandCanvas)then
		self.homelandCanvas:Away();
	end
	self.homelandCanvas = nil;
	self.nid = nil;
	self.jid = nil;
	self.is_local_world = nil;
	self.cur_worldPath = nil;
	
	-- return to previous scene. 
	WorldManager:TeleportBack();
	
	-- show the main bar. 
	self.ShowMainBar(true);
	MagicStarArea.AttachToRoot(1);
end

--创建家园的物体
function HomeLandGateway.DrawCanvas(custom_sprite3D)
	local self = HomeLandGateway;
	if(self.homelandCanvas and custom_sprite3D)then
		self.homelandCanvas:DrawNodes(custom_sprite3D);
		
		--local list = self.homelandCanvas:GetUnLinkedSeedGridInfo();
		--commonlib.echo("=========list");
		--commonlib.echo(list);
	end
end

function HomeLandGateway.GetUnLinkedSeedGridInfo()
	local self = HomeLandGateway;
	if(self.homelandCanvas) then
		return self.homelandCanvas:GetUnLinkedSeedGridInfo();
	end
end

--清空家园的物体
function HomeLandGateway.ClearCanvas()
	local self = HomeLandGateway;
	if(self.homelandCanvas)then
		self.homelandCanvas:Clear();
	end
end
-- 是否在自己的家园中
function HomeLandGateway.IsInMyHomeland()
	if(HomeLandGateway.IsInHomeland()) then
		local self = HomeLandGateway;
		if(self.nid and self.nid == Map3DSystem.User.nid )then
			return true;
		else
			return false;
		end
	else
		return false;
	end
end
-- 是否在其他人的家园中
function HomeLandGateway.IsInOtherHomeland()
	if(HomeLandGateway.IsInHomeland()) then
		local self = HomeLandGateway;
		if(self.nid and self.nid ~= Map3DSystem.User.nid)then
			return true;
		else
			return false;
		end
	else
		return false;
	end
end
-- 是否家园中
function HomeLandGateway.IsInHomeland()
	local worldDir = ParaWorld.GetWorldDirectory();
	if(not string.find(string.lower(worldDir), "homeland")) then
		return false;
	end
	
	local self = HomeLandGateway;
	if(self.nid)then
		return true;
	else
		return false;
	end
end
function HomeLandGateway.ShowMainBar(bShow)
	if(type(commonlib.getfield("MyCompany.Aries.Desktop.Dock.Show")) == "function") then
		MyCompany.Aries.Desktop.Dock.Show(bShow);
	end
	if(type(commonlib.getfield("MyCompany.Aries.Desktop.Dock.HideBBSChatWnd")) == "function") then
		MyCompany.Aries.Desktop.Dock.HideBBSChatWnd();
	end
	if(type(commonlib.getfield("MyCompany.Aries.Desktop.HPMyPlayerArea.Show")) == "function") then
		if(MyCompany.Aries.Pet.CombatIsOpened())then
			MyCompany.Aries.Desktop.HPMyPlayerArea.Show(bShow);
		end
	end
	if(type(commonlib.getfield("MyCompany.Aries.Desktop.EXPArea.Show")) == "function") then
		if(MyCompany.Aries.Pet.CombatIsOpened())then
			MyCompany.Aries.Desktop.EXPArea.Show(bShow);
		end
	end
	if(type(commonlib.getfield("MyCompany.Aries.Desktop.AntiIndulgenceArea.Show")) == "function") then
		MyCompany.Aries.Desktop.AntiIndulgenceArea.Show(bShow);
	end
	if(type(commonlib.getfield("MyCompany.Aries.Desktop.MagicStarArea.Show")) == "function") then
		MyCompany.Aries.Desktop.MagicStarArea.Show(bShow);
	end
	TeamMembersPage.ShowPage(bShow);
end
function HomeLandGateway.EditHouse()
	local self = HomeLandGateway;
	if(self.homelandCanvas)then
		self.homelandCanvas:EditHouse();
	end
	-- begin editing house
	local ItemManager = Map3DSystem.Item.ItemManager;
	ItemManager.BeginHomeLandEditing();
	-- hide the dock and monthly paid area
	self.ShowMainBar(false);
	-- hide all pets in homeland
	MyCompany.Aries.Pet.HideMyPetsFromMemoryInHomeland();
	-- refresh myself, hide the mount and follow pet
	System.Item.ItemManager.RefreshMyself();
	
	-- disable camera locking when in edit mode. 
	HomeLandGateway.IsLastCameraEnabled = MyCompany.Aries.AutoCameraController:IsEnabled()
	MyCompany.Aries.AutoCameraController:MakeEnable(false); 

	-- send log information
	paraworld.PostLog({action = "homeland_edit", nid = nid}, 
		"homeland_edit_log", function(msg)
	end);
end
function HomeLandGateway.SaveHouse()
	local self = HomeLandGateway;
	if(self.homelandCanvas)then
		self.homelandCanvas:SaveHouse();
		local s = self.homelandCanvas:ToString();
		Map3DSystem.App.HomeLand.HomeLandProvider.Save(s, function()
			-- leave the editing mode only if all clientdata are all successfully set
			-- show the dock and monthly paid area when the user save the house info
			self.ShowMainBar(true);
			-- refresh all pets in homeland
			if(not self.MyPetHideInHomeland())then
				MyCompany.Aries.Pet.RefreshMyPetsFromMemoryInHomeland();
			end
			-- refresh myself, show the mount and follow pet
			System.Item.ItemManager.RefreshMyself();
		end);
	end
	
	-- disable camera locking when in edit mode. 
	MyCompany.Aries.AutoCameraController:MakeEnable(HomeLandGateway.IsLastCameraEnabled); 

	---- NOTE 2009/12/6: leio, i remove the following line to the callback function
	---- show the dock and monthly paid area when the user save the house info
	--if(type(commonlib.getfield("MyCompany.Aries.Desktop.Dock.Show")) == "function") then
		--MyCompany.Aries.Desktop.Dock.Show(true);
	--end
	---- refresh all pets in homeland
	--MyCompany.Aries.Pet.RefreshMyPetsFromMemoryInHomeland();
	---- refresh myself, show the mount and follow pet
	--System.Item.ItemManager.RefreshMyself();
end
--显示家园访问列表面板
function HomeLandGateway.ShowHomeInfo()
	local self = HomeLandGateway;
	if(self.homelandCanvas)then
		self.homelandCanvas:ShowHomeInfo();
	end
end
--不用进家园 直接显示收礼物的面板
function HomeLandGateway.ShowGiftBox()
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	local can_pass = DealDefend.CanPass();
	if(not can_pass)then
		return
	end
	local nid = Map3DSystem.User.nid;
	local msg = {
		nid = tonumber(nid),
	}
	commonlib.echo("before get gift info");
	commonlib.echo(msg);
	paraworld.homeland.giftbox.Get(msg,"Giftinfo",function(msg)	
		commonlib.echo("after get gift info");
		commonlib.echo(msg);
		if(msg and msg.boxcnt)then
			local giftinfo = msg;

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
					nid = tonumber(nid),
				}
			commonlib.echo("before get gift detail info");
			commonlib.echo(msg);
			paraworld.homeland.giftbox.GetGifts(msg,"Giftinfo",function(msg)
				commonlib.echo("after get gift detail info");
				commonlib.echo(msg);
				if(msg and msg.gifts)then
					--礼物盒详细信息
					local giftinfo_detail = commonlib.deepcopy(msg.gifts);
					NPL.load("(gl)script/apps/Aries/Inventory/TabReceiveGift.lua");
					MyCompany.Aries.Inventory.TabReceiveGiftPage.SetNID(nid)
					MyCompany.Aries.Inventory.TabReceiveGiftPage.BindBean({giftinfo = giftinfo})
					MyCompany.Aries.Inventory.TabReceiveGiftPage.ShowPage(giftinfo_detail);			
				end
			end);

		end
	end);
end
--不进家园 直接送礼物
function HomeLandGateway.GiveGiftToUser(nid)
	local self = HomeLandGateway;
	nid = tostring(nid)
	if(not nid)then return end
	local myself = Map3DSystem.User.nid;
	myself = tostring(myself);
	if(nid == myself)then
		_guihelper.MessageBox("你不用给自己送礼物！");
		return;
	end	
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	local can_pass = DealDefend.CanPass();
	if(not can_pass)then
		return
	end
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
		nid = tonumber(nid),
	}
	commonlib.echo("before get gift info");
	commonlib.echo(msg);
	paraworld.homeland.giftbox.Get(msg,"Giftinfo",function(msg)	
		commonlib.echo("after get gift info");
		commonlib.echo(msg);
		if(msg and msg.boxcnt)then
			local giftinfo = msg;
			if(giftinfo.giftcnt < giftinfo.boxcnt)then
				NPL.load("(gl)script/apps/Aries/Inventory/TabGiveGift.lua");
				MyCompany.Aries.Inventory.TabGiveGiftPage.ShowPage(nid);
				MyCompany.Aries.Inventory.TabGiveGiftPage.SetNID(nid)
			else
					local content = string.format([[<pe:name nid='%s' linked=false/>的礼物盒已经满了，不能再收礼物了，下次再来送礼物吧。]],nid);
					_guihelper.MessageBox(content,nil, _guihelper.MessageBoxButtons.OK,nil,{OK = "知道了"});
			end
		end
	end);
end
--显示礼物盒面板
function HomeLandGateway.ShowGiftInfo()
	local self = HomeLandGateway;
	if(self.homelandCanvas)then
		self.homelandCanvas:ShowGiftInfo();
	end
end
--在刷新家园宠物列表之后
--宠物ai中 在改变宠物列表的时候，需要重新加载
--[[
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
Map3DSystem.App.HomeLand.HomeLandGateway.ReloadFollowPetItems();
--]]
function HomeLandGateway.ReloadFollowPetItems()
	local self = HomeLandGateway;
	if(self.homelandCanvas and self.IsInMyHomeland())then
		local follow_pet_state = self.homelandCanvas:GetCurFollowPetState();
		if(follow_pet_state)then
			commonlib.echo("========HomeLandGateway.ReloadFollowPetItems()");
			follow_pet_state:ReloadPetItems();
		end
	end
end
--在重新加载之前
function HomeLandGateway.Before_ReloadFollowPetItems()
	local self = HomeLandGateway;
	if(self.homelandCanvas and self.IsInMyHomeland())then
		local follow_pet_state = self.homelandCanvas:GetCurFollowPetState();
		if(follow_pet_state)then
			commonlib.echo("========HomeLandGateway.Before_ReloadFollowPetItems()");
			follow_pet_state:StopAllTimers();
			follow_pet_state:ReloadPetItems();
		end
	end
end
function HomeLandGateway.GetNID()
	local self = HomeLandGateway;
	return self.nid;
end
---------------------------------------------------
--操作node
---------------------------------------------------
--是否在编辑状态
function HomeLandGateway.IsEditing()
	local self = HomeLandGateway;
	if(self.homelandCanvas and self.homelandCanvas:GetEditingState() == "true")then
		return true;
	end
	return false;
end
function HomeLandGateway.DoMoveNode()
	local self = HomeLandGateway;
	if(self.homelandCanvas)then
		self.homelandCanvas:DirectlyDragSelectedNode();
	end
end
function HomeLandGateway.DoFacing(v)
	local self = HomeLandGateway;
	if(not self.IsInMyHomeland())then
		return
	end
	if(self.IsEditing())then
		self.homelandCanvas:DoFacingDelta(v);
	end
end
function HomeLandGateway.DoScaling(v)
	local self = HomeLandGateway;
	if(not self.IsInMyHomeland())then
		return
	end
	if(self.IsEditing())then
		
		self.homelandCanvas:DoScalingDelta(v);
		local NormalViewPage = commonlib.gettable("MyCompany.Aries.Inventory.NormalViewPage");
		NormalViewPage.RefreshPage();
	end
end
--回收到背包
function HomeLandGateway.DoRemove()
	local self = HomeLandGateway;
	if(self.homelandCanvas)then
		self.homelandCanvas:DestroyNode();
	end
end
--根据物品系统创建node
function HomeLandGateway.BuildNodeFromItem(type,gsItem,guid)
	local self = HomeLandGateway;
	if(not self.IsInHomeland())then return end
	if(self.homelandCanvas)then
		self.homelandCanvas:BuildNodeFromItem(type,gsItem,guid)
	end
end
---------------------------------------------------
--兼容old版本
---------------------------------------------------
function HomeLandGateway.ReloadGiftInfo()
	local self = HomeLandGateway;
	if(HomeLandGateway.IsInHomeland() and self.homelandCanvas)then
		self.homelandCanvas:ReloadGiftInfo()
	end
end
function HomeLandGateway.ReloadGiftDetail()
	local self = HomeLandGateway;
	if(self.homelandCanvas)then
		self.homelandCanvas:ReloadGiftDetail()
	end
end
-- 获取自己礼物盒的信息和
-- 获取当前家园收到的礼物的详细信息
function HomeLandGateway.GetGiftDetail()
	local self = HomeLandGateway;
	if(self.homelandCanvas)then
		local bean = self.homelandCanvas:GetReadOnlyBean();
		if(bean)then
			return bean.giftinfo,bean.giftinfo_detail;
		end
	end
end
function HomeLandGateway.ClearPug()
	local self = HomeLandGateway;
	local houseinfo = self.GetHomeInfo();
	if(houseinfo and houseinfo.pugcnt)then
		houseinfo.pugcnt = houseinfo.pugcnt - 5;
		if(houseinfo.pugcnt < 0)then
			houseinfo.pugcnt = 0;
		end
	end
end
--获取家园访问量
function HomeLandGateway.GetHomeInfo()
	local self = HomeLandGateway;
	if(self.homelandCanvas)then
		local bean = self.homelandCanvas:GetReadOnlyBean();
		if(bean)then
			return bean.houseinfo;
		end
	end
end
--返回一个列表，包含了 每个nid的信息
function HomeLandGateway.GetUserInfo(nids,callbackFunc)
	if(not nids)then
		if(callbackFunc and type(callbackFunc) == "function")then
			callbackFunc({error = true});
		end
	end
	local msg = {
			nids = nids,
			cache_policy = "access plus 0 day",
		};
		local usersinfo = {};
			commonlib.echo("[begin] get userinfo by HomeLandGateway.GetUserInfo:");
			commonlib.echo(msg);
		paraworld.users.getInfo(msg, "getInfo", function(msg)
			commonlib.echo("[after] get userinfo by HomeLandGateway.GetUserInfo:");
			commonlib.echo(msg);
			if(msg and msg.users)then
				local k,user;
				for k,user in ipairs(msg.users) do
					local nid = user.nid;
					usersinfo[nid] = user; --{ nid=166, nickname="leio"..k,}
				end
				if(callbackFunc and type(callbackFunc) == "function")then
					callbackFunc({usersinfo = usersinfo});
				end
			else
				if(callbackFunc and type(callbackFunc) == "function")then
					callbackFunc({error = true});
				end
			end
		end);
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
function HomeLandGateway.GetPlantsAllInfo()
	local self = HomeLandGateway;
	if(self.homelandCanvas)then
		return self.homelandCanvas:GetPlantsAllInfo();
	end
end
--给所有需要浇水的植物浇水
function HomeLandGateway.WaterAllPlants(callbackFunc)
	local self = HomeLandGateway;
	if(self.homelandCanvas)then
		self.homelandCanvas:WaterAllPlants(callbackFunc)
	end
end
--给所有需要浇水的植物除虫
function HomeLandGateway.DebugAllPlants(callbackFunc)
	local self = HomeLandGateway;
	if(self.homelandCanvas)then
		self.homelandCanvas:DebugAllPlants(callbackFunc)
	end
end
--是否可以 收获所有的果实
function HomeLandGateway.CanGetAllFruits()
	local self = HomeLandGateway;
	if(self.homelandCanvas)then
		return self.homelandCanvas:CanGetAllFruits();
	end
end

--收获所有的果实
function HomeLandGateway.GetAllFruits(callbackFunc)
	local self = HomeLandGateway;
	if(self.homelandCanvas)then
		self.homelandCanvas:GetAllFruits(callbackFunc)
	end
end
--是否在糖果家园
--在糖果家园的时候，整个糖果家园是一个模型 更改了投掷的规则
function HomeLandGateway.IsInCandyHome()
	local self = HomeLandGateway;
	if(self.IsInHomeland())then
		local path = self.cur_worldPath or "";
		local static_path = "worlds/MyWorlds/100409_CandyHomeland";
		path = string.lower(path);
		static_path = string.lower(static_path);
		if(path and static_path)then
			return true;
		end
	end
end
--进入自己的家园 强制刷新
function HomeLandGateway.ForceRefreshBag()
	local self = HomeLandGateway;
	if(self.IsInMyHomeland())then
		Map3DSystem.Item.ItemManager.GetItemsInBag(41, "", function(msg) 
							end, "access plus 0 day");
	end
end
--记录在自己家园中是否隐藏宠物
function HomeLandGateway.SetValue_PetLocalShowInfo(gsid,v)
	local self = HomeLandGateway;
	if(not gsid)then return end
	self.pet_hide_from_homeland = self.pet_hide_from_homeland or self.LoadMyPetLocalShowInfo();
	if(v)then
		self.pet_hide_from_homeland[gsid] = nil;
	else
		--只记录隐藏的宠物
		self.pet_hide_from_homeland[gsid] = true;
	end
	self.SaveMyPetLocalShowInfo(self.pet_hide_from_homeland);
	--如果在自己的家园中
	if(self.IsInMyHomeland() and self.homelandCanvas)then
		self.homelandCanvas:RefreshPetsInHomeland();
	end
end
function HomeLandGateway.LoadMyPetLocalShowInfo()
	local myself = Map3DSystem.User.nid;
	local key = string.format("LoadMyPetLocalShowInfo_%d",myself);
	return MyCompany.Aries.Player.LoadLocalData(key, {});
end
function HomeLandGateway.SaveMyPetLocalShowInfo(v)
	local myself = Map3DSystem.User.nid;
	local key = string.format("LoadMyPetLocalShowInfo_%d",myself);
	MyCompany.Aries.Player.SaveLocalData(key, v);
end
--return clientdata.hide_in_homeland;
function HomeLandGateway.MyPetHideInHomeland()
	local gsid = 985;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local bHas,guid = hasGSItem(gsid);
	if(bHas)then
		local item = ItemManager.GetItemByGUID(guid);
		if(item)then
			local clientdata = item.clientdata;
			if(not clientdata or clientdata == "")then
				clientdata = {};
			else
				clientdata = commonlib.LoadTableFromString(clientdata);
			end
			return clientdata.hide_in_homeland;
		end
	end
end
function HomeLandGateway.SaveMyPetShowState(hide_in_homeland,callbackFunc)
	local self = HomeLandGateway;
	local gsid = 985;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local bHas,guid = hasGSItem(gsid);
	if(bHas)then
		local item = ItemManager.GetItemByGUID(guid);
		if(item)then
			local clientdata = item.clientdata;
			if(not clientdata or clientdata == "")then
				clientdata = {};
			else
				clientdata = commonlib.LoadTableFromString(clientdata);
			end
			clientdata.hide_in_homeland = hide_in_homeland;
			clientdata = commonlib.serialize_compact2(clientdata);
			ItemManager.SetClientData(guid,clientdata,function(msg_setclientdata)
				if(callbackFunc)then
					callbackFunc(msg_setclientdata);
					if(self.IsInMyHomeland())then
						if(not hide_in_homeland)then
							MyCompany.Aries.Pet.RefreshMyPetsFromMemoryInHomeland();
						else
							MyCompany.Aries.Pet.HideMyPetsFromMemoryInHomeland();
						end
					end
				end
			end);
		end
	end
end
function HomeLandGateway.LoadPetShowState(nid,callbackFunc)
	local self = HomeLandGateway;
	nid = tonumber(nid);
	local myself = Map3DSystem.User.nid;
	nid = nid or Map3DSystem.User.nid;
	local gsid = 985;
	if(nid == myself)then
		Map3DSystem.Item.ItemManager.GetItemsInBag(1002, "homeland", function(msg) 
			local hasGSItem = ItemManager.IfOwnGSItem;
			local bHas,guid = hasGSItem(gsid);
			if(bHas)then
				local item = ItemManager.GetItemByGUID(guid);
				if(item)then
					local clientdata = item.clientdata;
					if(not clientdata or clientdata == "")then
						clientdata = {};
					else
						clientdata = commonlib.LoadTableFromString(clientdata);
					end
					if(callbackFunc)then
						callbackFunc({
							clientdata = clientdata,
						});
					end
				end
			end
		end);
	else
		Map3DSystem.Item.ItemManager.GetItemsInOPCBag(nid,1002, "homeland", function(msg)
			local hasGSItem = ItemManager.IfOPCOwnGSItem;
			local bHas,guid = hasGSItem(nid,gsid);
			if(bHas)then
				local item = ItemManager.GetOPCItemByGUID(nid,guid);
				if(item)then
					local clientdata = item.clientdata;
					if(not clientdata or clientdata == "")then
						clientdata = {};
					else
						clientdata = commonlib.LoadTableFromString(clientdata);
					end
					if(callbackFunc)then
						callbackFunc({
							clientdata = clientdata,
						});
					end
				end
			end
		end, "access plus 0 day");
	end
end
-----------------------------------------------------
--创建家园npc
-----------------------------------------------------
--挑战之旗 npc
function HomeLandGateway.CreateChallengeFlagNpc()
	local self = HomeLandGateway;
	local params = { 
		name = "挑战之旗",--家园npc
		position = { 19959.048828, 55, 20278.406250, },
		facing = -0.15686285495758,
		friend_npcs = "",
		scaling_char = 2,
		scaling_model = 1,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",
		assetfile_model = "model/06props/v5/03quest/FighterFlag/FighterFlag.x",
		main_script = "script/apps/Aries/NPCs/Homeland/30348_ChallengeFlag.lua",
		main_function = "MyCompany.Aries.Quest.NPCs.ChallengeFlag.main();",
		predialog_function = "MyCompany.Aries.Quest.NPCs.ChallengeFlag.PreDialog",
		selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
		isdummy = true,
	};-- 挑战之旗 家园npc
	MyCompany.Aries.Quest.NPC.CreateNPCCharacter(30348, params);
end