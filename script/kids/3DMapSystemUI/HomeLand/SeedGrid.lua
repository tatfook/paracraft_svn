--[[
Title: SeedGrid
Author(s): Leio
Date: 2009/6/16
Desc:
绑定一个物体，显示提醒信息，在哪里可以放，在哪里放不下去
改动：
2009/6/16 操作规则是：显示所有可以被相交的箭头，检测鼠标坐标与每一个格子的热区是否相交，如果为true，把这个箭头的状态改为选择状态arrow:SetSelected(true);
2009/8/5 操作规则是：检测鼠标坐标与每一个格子的热区是否相交，如果为true,显示出箭头提醒arrow:SetVisible(true);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/SeedGrid.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/Objects/Building3D.lua");
NPL.load("(gl)script/ide/Display/Containers/MiniScene.lua");
NPL.load("(gl)script/ide/Display/Util/ObjectsCreator.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
local SeedGrid = {
	name = "SeedGrid_instance",
	
	node = nil,
	boxes = nil,
	selectedIndex = nil,
	miniScene = nil,
	defaultH = 0,
	defaultArrow = "model/06props/v3/headarrow.x",
}
commonlib.setfield("Map3DSystem.App.HomeLand.SeedGrid",SeedGrid);
function SeedGrid:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self;
	o:Init();
	return o
end
function SeedGrid:Init()
	self.boxes = {};
	self.name = ParaGlobal.GenerateUniqueID();
	CommonCtrl.AddControl(self.name, self);
end
function SeedGrid:GetBox()
	return self.boxes[self.selectedIndex];
end
function SeedGrid.WaitForAssetLoaded(sName)
	local self = CommonCtrl.GetControl(sName);
	if(self)then
		self:_BindNode(self.node);
	end
end
function SeedGrid:BindNode(node,callbackFunc)
	if(not node)then return end;
	self.node = node;
	self.callbackFunc = callbackFunc;
	local entity;
	local root = node:GetRoot();
	if(root)then
		entity = root:GetEntity(node);
	end
	if(entity)then
		entity:GetAttributeObject():SetField("On_AssetLoaded", string.format(";Map3DSystem.App.HomeLand.SeedGrid.WaitForAssetLoaded('%s');",self.name))
	end
end
-- 绑定一个花圃
function SeedGrid:_BindNode(node)
	if(not node)then return end;
	--self.node = node;
	local singlebox = Map3DSystem.App.HomeLand.HomeLandConfig.GridBox;
	local entity;
	local root = node:GetRoot();
	if(root)then
		entity = root:GetEntity(node);
	end
	if(entity)then
		local nXRefCount = entity:GetXRefScriptCount();
		local x,y,z = node:GetPosition();
		local i=0;
		--box是相对坐标
		for i=0,nXRefCount-1 do
			local box = {};
			box.pos_x, box.pos_y, box.pos_z = entity:GetXRefScriptPosition(i);
			box.pos_x = box.pos_x - x;
			box.pos_y = box.pos_y - y;
			box.pos_z = box.pos_z - z;
			box.obb_x = singlebox.x;
			box.obb_y = singlebox.y;
			box.obb_z = singlebox.z;
			
			
			box.bindSeed = nil;
			table.insert(self.boxes,box);
		end
	end
	--local x,y,z = node:GetPosition();
	--local k;
	--local w = 4;
	--for k = 1,5 do
		--local px,py,pz = 0,0,(0 + k * w/2);
		--local box = {pos_x = px, pos_y = py, pos_z = pz,obb_x = w,obb_y = w,obb_z = w, bindSeed = nil,};
		--table.insert(self.boxes,box);
	--end
	if(not self.miniScene)then
		self.miniScene = CommonCtrl.Display.Containers.MiniScene:new();
		self.miniScene:Init();
		
	end
	if(not self.sprite)then
		self.sprite = CommonCtrl.Display.Containers.Sprite3D:new();
		self.sprite:Init();
		self.miniScene:AddChild(self.sprite);
	end
	self:UpdatePosition()
	local k,box;
	for k,box in ipairs(self.boxes) do
		local arrow = CommonCtrl.Display.Objects.Building3D:new()
		arrow:Init();
		arrow:SetPosition(box.pos_x,(box.pos_y + self.defaultH),box.pos_z)
		arrow:SetAssetFile(self.defaultArrow);
		self.sprite:AddChild(arrow);
	end
	self:Reset();
	if(self.callbackFunc)then
		self.callbackFunc();
		self.callbackFunc = nil;
	end
end
function SeedGrid:UpdatePosition()
	if(self.node and self.sprite)then
		local x,y,z = self.node:GetPosition();
		self.sprite:SetPosition(x,y,z);
		local k,box;
		for k,box in ipairs(self.boxes) do
			if(box and box.bindSeed)then
				local position = {
					pos_x = box.pos_x + x,
					pos_y = box.pos_y + y,
					pos_z = box.pos_z + z,
					};
				box.bindSeed:SetPosition(position.pos_x,position.pos_y,position.pos_z);
				
			end
		end
	end
end
--function SeedGrid:UpdateFacing()
	--local entity;
	--local root = self.node:GetRoot();
	--if(root)then
		--entity = root:GetEntity(self.node);
		--if(entity)then
			--local k,box;
			--for k,box in ipairs(self.boxes) do
				--if(box and box.bindSeed)then
					--
					--local facing = entity:GetXRefScriptFacing(k);
					--commonlib.echo("================");
					--commonlib.echo(facing);
					--if(facing)then
						--box.bindSeed:SetFacing(facing);
					--end
				--end
			--end
		--end
	--end
--end
--控制所有箭头的显示
function SeedGrid:ShowArrow(bShow)
	if(self.sprite)then
		self.sprite:SetVisible(bShow);
	end
end
function SeedGrid:Selected(selectedIndex)
	self.selectedIndex = selectedIndex;
	local k,box;
	for k,box in ipairs(self.boxes) do
		local arrow = self.sprite:GetChildAt(k);
		if(arrow)then
				arrow:SetVisible(false);
			if(self.selectedIndex == k)then
				arrow:SetVisible(true);
				self:HookSeedGridSelected();
			end
		end
	end
end
function SeedGrid:HookSeedGridSelected()
	local msg = { 
			aries_type = "SeedGridSelected",
			wndName = "homeland",
		};
	--commonlib.echo("HookSeedGridSelected");
	--commonlib.echo(msg);
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
end
function SeedGrid:Reset()
	local k,box;
	for k,box in ipairs(self.boxes) do
		local arrow = self.sprite:GetChildAt(k);
		if(arrow)then
			if(self.selectedIndex ~= k)then
				arrow:SetVisible(false);
			end
		end
	end
end
function SeedGrid:PutDownAt(seed,index)
	if(not seed or not index)then return end
	--self.selectedIndex = index;
	--self:PutDown(seed);
	local box = self.boxes[index];
	if(box)then
		box.bindSeed = seed;
		local x,y,z = self.node:GetPosition();
		seed:SetPosition(x + box.pos_x,y + box.pos_y,z + box.pos_z);
		if(seed.SetGrid and self.node)then
			local id = self.node:GetUID();
			seed:SetGrid(id.."|"..index);
		end
		seed.seedgrid = self;
	end
end
--移除格子
function SeedGrid:RemoveSeed(seed)
	if(not seed)then return end
	local g = seed:GetGrid();
	commonlib.echo("seed:GetGrid()");
	commonlib.echo(g);
	if(g)then
		local __,__,__,index = string.find(g,"(.+)|(.+)");
		index = tonumber(index);
		local box = self.boxes[index];
		if(box)then
			box.bindSeed = nil;
			seed.seedgrid = nil;
		end
	end
end
function SeedGrid:PutDown(seed)
	if(self:CanPutDown())then
		local box = self.boxes[self.selectedIndex];
		box.bindSeed = seed;
		local x,y,z = self.node:GetPosition();
		seed:SetPosition(x + box.pos_x,y + box.pos_y,z + box.pos_z);
		if(seed.SetGrid and self.node)then
			local id = self.node:GetUID();
			local index = self.selectedIndex;
			seed:SetGrid(id.."|"..index);
		end
		seed.seedgrid = self;
		--self:Reset();
	end
end
function SeedGrid:TipBox(index)
	if(self.sprite)then
		local newarrow = self.sprite:GetChildAt(index);
		if(oldarrow)then
			oldarrow:SetVisible(false);
		end
		if(newarrow)then
			newarrow:SetVisible(true);
		end
	end
end
function SeedGrid:CanPutDown()
	if(self.selectedIndex)then
		local box = self.boxes[self.selectedIndex];
		if(box)then
			if(not box.bindSeed)then
				return true;
			end
		end
	end
end
function SeedGrid:Update(point)
	if(not point)then return end
	local k,box;
	local x,y,z = self.node:GetPosition();
	self:Reset();
	for k,box in ipairs(self.boxes) do
		if(box and not box.bindSeed)then
			local _box = {
				pos_x = box.pos_x + x,
				pos_y = box.pos_y + y,
				pos_z = box.pos_z + z,
				obb_x = box.obb_x,
				obb_y = box.obb_y,
				obb_z = box.obb_z,
				};
			local result = CommonCtrl.Display.Util.ObjectsCreator.Contains(point,_box)	
			if(result)then
				self:TipBox(k);
				return true,k;
			end
		end
	end
end