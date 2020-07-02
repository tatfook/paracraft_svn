--[[
Title: FlowerDocument
Author(s): Leio
Date: 2009/2/24
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeZone/FlowerDocument.lua");
Map3DSystem.App.HomeZone.FlowerDocument.GetInfo()
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.flower.lua");
NPL.load("(gl)script/ide/Display/Objects/Flower.lua");
local FlowerDocument = {
	name = "FlowerDocument_instance",
	isBusying = false,
	flower = nil,
	fruit = "model/05plants/01flower/01flower/flower_test02.x",
	trunk = "model/05plants/01flower/01flower/flower_test.x",
	
	scene = nil,
	flowerLevel = 0, -- 当前花的级别
	grownNum = 0, -- 当前级别浇灌的次数
	grownTotalNum = 0,-- 浇灌的总次数
	remainFruits = 0, -- 树上剩余果实
	fruitsTotals = 0, -- 当前级别可以结出果实的总数
	fruitStore = 0, -- 篮子里面果实总数
	fruitsPosition = nil,
}
commonlib.setfield("Map3DSystem.App.HomeZone.FlowerDocument",FlowerDocument);
function FlowerDocument.Clear()
	FlowerDocument.scene = nil;
	FlowerDocument.isBusying = false;
	FlowerDocument.flower = nil;
end
function FlowerDocument.Load(flower,uid)
	Map3DSystem.CancelForceDonotHighlight()
	FlowerDocument.flower = flower;
	FlowerDocument.uid = uid;
	FlowerDocument.GetInfo();
	
end
function FlowerDocument.CheckState()
	if(FlowerDocument.isBusying)then
		_guihelper.MessageBox("网络正在传输，稍等！");
		return true;
	else
		FlowerDocument.isBusying = true;
	end
end
-- buy a flower
function FlowerDocument.Buy()
	if(FlowerDocument.CheckState())then return end
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		flowertype = 0,
		format = 1,
	}
	paraworld.flower.Add(msg,"flower",function(msg)	
		FlowerDocument.isBusying = false;
		if(msg.issuccess)then
			_guihelper.MessageBox("领养成功！");
		else
			_guihelper.MessageBox("领养失败！");
		end
	end);
end
-- delete the flower item
function FlowerDocument.Delete()
	if(FlowerDocument.CheckState())then return end
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		format = 1,
	}
	paraworld.flower.Delete(msg,"flower",function(msg)	
		FlowerDocument.isBusying = false;
		if(msg.issuccess)then
			_guihelper.MessageBox("清除成功！");
		else
			_guihelper.MessageBox("清除失败！");
		end
	end);
end
-- get flower's info from server
function FlowerDocument.GetInfo()
	if(FlowerDocument.CheckState())then return end
	local self = FlowerDocument;
	local msg = {
		uid = FlowerDocument.uid or Map3DSystem.User.userid,
		format = 1,
	}
	paraworld.flower.Get(msg,"flower",function(msg)	
		FlowerDocument.isBusying = false;
		if(msg.FlowerLevel)then
			self.flowerLevel = msg.FlowerLevel;
			self.grownNum = msg.WaterLevel;
			self.remainFruits = msg.FuritOverplus; 
			self.fruitsTotals = msg.FuritCnt;
			self.fruitStore = msg.Store;
			self.grownTotalNum = msg.WaterCnt;
			local position = msg.Position or "";
			local p;
			self.fruitsPosition = {};
			for p in string.gfind(position,"[^|]+") do
				self.fruitsPosition[p] = p;
			end
			FlowerDocument.DrawFlower();
		end
	end);
end
-- grown flower
function FlowerDocument.Grown(num)
	if(FlowerDocument.CheckState())then return end
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		cnt = num or 1,
		toUID = FlowerDocument.uid,
	}
	paraworld.flower.Water(msg,"flower",function(msg)	
		FlowerDocument.isBusying = false;
		if(msg.issuccess)then
			FlowerDocument.GetInfo();
		else
			_guihelper.MessageBox(string.format("灌溉出错：%d",msg.errorcode));
		end
	end);
end
-- pick a fruit from tree 
function FlowerDocument.PickFruit(position)
	if(FlowerDocument.CheckState())then return end
	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		position = position,
		format = 1,
	}
	paraworld.flower.Store(msg,"flower",function(msg)	
		FlowerDocument.isBusying = false;
		if(msg.issuccess)then
			FlowerDocument.GetInfo();
		else
			_guihelper.MessageBox(string.format("採摘出错：%d",msg.errorcode));
		end
	end);
end
-- construct a class of Flower
function FlowerDocument.DrawFlower()
	local self = FlowerDocument;
	NPL.load("(gl)script/ide/Display/Containers/Scene.lua");
	if(not self.scene)then
		self.scene = CommonCtrl.Display.Containers.Scene:new()
		self.scene:Init();
	else
		self.scene:Clear();
	end
	--if(not flower)then
		--flower = CommonCtrl.Display.Objects.Flower:new()
		--flower:Init();
		--local params = flower:GetEntityParams();
		--params.AssetFile = FlowerDocument.trunk;	
		--flower:SetEntityParams(params);
		--flower:SetPosition(20000,0,20000)	
--
		--self.scene:AddChild(flower);
	--end
	FlowerDocument.AddEventListener(self.flower)	
	FlowerDocument.DrawFruits(self.flower,self.scene)
end
function FlowerDocument.MouseDownHandle(funcHolder,event)
	local self = funcHolder;
	local type = event.type;
	local currentTarget = event.currentTarget;
	if(currentTarget)then
		currentTarget:SetSelected(true);
	end
end
function FlowerDocument.MouseUpHandle(funcHolder,event)
	local self = funcHolder;
	local type = event.type;
	local currentTarget = event.currentTarget;
	if(currentTarget)then
		currentTarget:SetSelected(false);
		FlowerDocument.PickFruit(currentTarget.placeIndex)
	end
end
function FlowerDocument.DrawFruits(flower,scene)
	if(not flower or not scene)then return end;
	local self = FlowerDocument;
	local flowerLevel = self.flowerLevel;--当前级别
	local grownNum = self.grownNum;--浇灌次数
	local grownTotalNum = self.grownTotalNum;--浇灌总次数
	local remainFruits = self.remainFruits;--还剩多少个果实没有被摘掉
	local fruitsTotals = self.fruitsTotals; -- 当前级别可以结出多少个果实
	local fruitStore = self.fruitStore;-- 果篮里面果实的数量
	local fruitsPosition = self.fruitsPosition;-- 果实的位置
	if(not fruitsPosition)then return end
	local root = flower:GetRoot();
	if(root and root.GetEntity)then
		local entity = root:GetEntity(flower)
		if(entity and entity:IsValid())then
			local toX, toY, toZ;	
			local k,v;
			for k,v in pairs(fruitsPosition) do
				v = tonumber(v);
				toX, toY, toZ = entity:GetXRefScriptPosition(v);
				NPL.load("(gl)script/ide/Display/Objects/Building3D.lua");
				local fruit = CommonCtrl.Display.Objects.Building3D:new()
				fruit:Init();
				local params = fruit:GetEntityParams();
				params.AssetFile = FlowerDocument.fruit;
				fruit.placeIndex = v;
				fruit:SetEntityParams(params);	
				fruit:SetPosition(toX, toY, toZ);								
				fruit:AddEventListener("left_mouse_down",FlowerDocument.MouseDownHandle,Map3DSystem.App.HomeZone.FlowerDocument)
				fruit:AddEventListener("left_mouse_up",FlowerDocument.MouseUpHandle,Map3DSystem.App.HomeZone.FlowerDocument)
				scene:AddChild(fruit);
			end
		end
	end
	FlowerDocument.Show()
end
function FlowerDocument.AddEventListener(flower)
	if(not flower)then return end;
	flower:AddEventListener("left_mouse_down",FlowerDocument.MouseDownHandle_flower,Map3DSystem.App.HomeZone.FlowerDocument)
	flower:AddEventListener("left_mouse_up",FlowerDocument.MouseUpHandle_flower,Map3DSystem.App.HomeZone.FlowerDocument)
end
function FlowerDocument.RemoveEventListener(flower)
	if(not flower)then return end;
	flower:RemoveEventListener("left_mouse_down");
	flower:RemoveEventListener("left_mouse_up");
end
function FlowerDocument.MouseDownHandle_flower(funcHolder,event)
	local self = funcHolder;
	local type = event.type;
	local currentTarget = event.currentTarget;
	if(currentTarget)then
		currentTarget:SetSelected(true);
		FlowerDocument.Grown()
	end
end
function FlowerDocument.MouseUpHandle_flower(funcHolder,event)
	local self = funcHolder;
	local type = event.type;
	local currentTarget = event.currentTarget;
	if(currentTarget)then
		currentTarget:SetSelected(false);
	end
end
function FlowerDocument.Show()
	local self = FlowerDocument;
	local flowerLevel = self.flowerLevel;--当前级别
	local grownNum = self.grownNum;--浇灌次数
	local grownTotalNum = self.grownTotalNum;--浇灌总次数
	local remainFruits = self.remainFruits;--还剩多少个果实没有被摘掉
	local fruitsTotals = self.fruitsTotals; -- 当前级别可以结出多少个果实
	local fruitStore = self.fruitStore;-- 果篮里面果实的数量
	local fruitsPosition = self.fruitsPosition;-- 果实的位置
	
	local _parent = ParaUI.GetUIObject(self.name);
	if(_parent:IsValid())then
		ParaUI.Destroy(self.name);
	end
	_parent = ParaUI.CreateUIObject("container", self.name or "", "_lb", 20, -350, 400, 500);
	_parent.background = "";
	_parent:AttachToRoot();
	
	local left,top,width,height = 0,0,100,50;
	local _this = ParaUI.CreateUIObject("button", "b", "_lt", left,top,width,height);
	_this.text = "领养";
	_this.onclick = ";Map3DSystem.App.HomeZone.FlowerDocument.Buy();";
	_parent:AddChild(_this);
	
	local left,top,width,height = 120,0,100,50;
	local _this = ParaUI.CreateUIObject("button", "b", "_lt", left,top,width,height);
	_this.text = "删除";
	_this.onclick = ";Map3DSystem.App.HomeZone.FlowerDocument.Delete();";
	_parent:AddChild(_this);
	
	local left,top,width,height = 0,60,400,300;
	local _this = ParaUI.CreateUIObject("button", "b", "_lt", left,top,width,height);
	_this.text = string.format([[当前级别：%d
								当前级别浇灌次数：%d,共浇灌%d次
								树上剩余果实：%d,已经摘了%d个，果实总数%d]],
				flowerLevel,
				grownNum,grownTotalNum,
				remainFruits,
				fruitStore,
				fruitsTotals);
	_parent:AddChild(_this);
end
------------------------------------------------------------
-- FlowerConfig
--[[
Map3DSystem.ForceDonotHighlight()
Map3DSystem.CancelForceDonotHighlight()
you can add a AppDesktop.PredefinedMode["HomeZone"]
with CanShowNearByXrefMarker = false
]]
------------------------------------------------------------
local FlowerConfig = {
	
}
commonlib.setfield("Map3DSystem.App.HomeZone.FlowerConfig",FlowerConfig);