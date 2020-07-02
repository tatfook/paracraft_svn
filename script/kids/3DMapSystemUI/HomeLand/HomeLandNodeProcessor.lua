--[[
Title: 
Author(s): Leio
Date: 2009/11/8
use the lib:
在View模式下
点击选中物体

在Edit模式下
第一次点击，选中物体
第二次点击，物体吸附在鼠标上
第三次点击，物体放下
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandNodeProcessor.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Display3D/SceneNodeProcessor.lua");
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");

local HomeLandNodeProcessor = commonlib.inherit(CommonCtrl.Display3D.SceneNodeProcessor, {
	selectedNode = nil,--被选中的物体 
	editMode = "view", --view or edit
	roleState = "master",--"master" or "guest"
	arrowRootNode = nil,--箭头显示的迷你场景
	dragRootNode = nil,--拖拽显示的迷你场景
	dragContainer = nil,--拖拽的父容器，存在于dragRootNode里面
	isDrag = false,--是否正在拖拽
	dragLastX = 0,--拖拽移动的上一个位置
	dragLastY = 0,
	dragLastZ = 0,
	-- 针对选择的物体，点击的次数 在edit模式下有效
	clickNum = 0,
	readyDragNode = nil,--在clickNum = 1 是准备移动的node
	
	canvas = nil,-- it is a SceneCanvas instance
	parent_canvas = nil, -- it is a HomeLandCanvas_New instance
	--event
	OnSelectedNodeFunc = nil,--当选中/取消选中 一个物体的时候发送的事件
}, function(o)
		--------------------
		--箭头显示的迷你场景
		--------------------
		local scene = CommonCtrl.Display3D.SceneManager:new{
			type = "miniscene",
		};
		local rootNode = CommonCtrl.Display3D.SceneNode:new{
			root_scene = scene,
		} 
		o.arrowRootNode = rootNode;
		--------------------
		--拖拽显示的迷你场景
		--------------------
		local scene = CommonCtrl.Display3D.SceneManager:new{
			type = "miniscene",
		};
		local rootNode = CommonCtrl.Display3D.SceneNode:new{
			root_scene = scene,
		} 
		o.dragRootNode = rootNode;
end)

commonlib.setfield("Map3DSystem.App.HomeLand.HomeLandNodeProcessor",HomeLandNodeProcessor);
--对 IndoorHouse 不做任何处理
function HomeLandNodeProcessor:CanPass(event)
	if(event and event.currentTarget)then
		local node = event.currentTarget;
		if(node and node.GetType)then
			if(node:GetType() == "IndoorHouse")then
				return false;
			end
		end	
	end
	return true;
end
function HomeLandNodeProcessor:DoMouseDown(event)
	--commonlib.echo("===========DoMouseDown");

end
function HomeLandNodeProcessor:DoMouseUp(event)
	--commonlib.echo("===========DoMouseUp");
	
end
function HomeLandNodeProcessor:DoMouseMove(event)
	--commonlib.echo("===========DoMouseMove");

end
--[[
event.msg = {
  IsComboKeyPressed=false,
  IsMouseDown=false,
  MouseDragDist={ x=0, y=0 },
  dragDist=269,
  lastMouseDown={ x=782, y=488 },
  lastMouseUpButton="right",
  lastMouseUpTime=6699.6712684631,
  lastMouseUp_x=789,
  lastMouseUp_y=496,
  mouse_button="right",
  mouse_x=559,
  mouse_y=196,
  virtual_key=242,
  wndName="mouse_move" 
}
--]]
function HomeLandNodeProcessor:DoMouseOver(event)
	if(not self:CanPass(event))then
		return
	end
	if(event and event.msg)then
		local msg = event.msg;
		--mouseover mouseout 不需要区分左右键
		if(not self.isDrag)then
			self:ShowTip(event);
		end
	end
end
function HomeLandNodeProcessor:DoMouseOut(event)
	if(not self:CanPass(event))then
		return
	end
	if(event and event.msg)then
		local msg = event.msg;
		--mouseover mouseout 不需要区分左右键
		if(not self.isDrag)then
			self:HideTip(event);
		end
	end
end
function HomeLandNodeProcessor:DoChildSelected(event)
	if(not self:CanPass(event))then
		return
	end
	if(event and event.msg)then
		local msg = event.msg;
		if(msg.mouse_button == "left")then
			if(not self.isDrag)then
				self:SelectedNode(event);
			end
		end
	end
end
function HomeLandNodeProcessor:DoChildUnSelected(event)
	if(not self:CanPass(event))then
		return
	end
	if(event and event.msg)then
		local msg = event.msg;
		if(msg.mouse_button == "left")then
			if(not self.isDrag)then
				self:UnSelectedNode(event);
			end
		end
	end
end
function HomeLandNodeProcessor:DoMouseDown_Stage(event)
	--commonlib.echo("===========DoMouseDown_Stage");
end
function HomeLandNodeProcessor:DoMouseUp_Stage(event)
	if(not self:CanPass(event))then
		--return
	end
	if(event and event.msg)then
		local msg = event.msg;
		local currentTarget = event.currentTarget;
		if(msg.mouse_button == "left")then
			if(self.editMode == "edit")then
				--如果不是在拖拽情况下
				if(not self.isDrag)then
					local selectedNode,linkedNode = self:GetSelectedNodeAndLinkedNode();
					if(selectedNode)then
						--第一次点击
						if(self.clickNum == 0)then
							self.clickNum = self.clickNum + 1;
							--记录点击的物体
							self.readyDragNode = selectedNode;
						elseif(self.clickNum == 1)then
							--第二次点击 而且是同一个物体
							if(selectedNode == self.readyDragNode)then
								self.clickNum = 2;
								self:StartDrag();
							else
								--如果不是同一个物体
								--记录点击的物体
								self.readyDragNode = selectedNode;
							end
						end
						event.canReturn.value = false;--截断鼠标事件
					else
						self.clickNum = 0;
						self.readyDragNode = nil;
						self:UnSelected();
					end
				else
					event.canReturn.value = false;--截断鼠标事件
					self:StopDrag();
					self.clickNum = 1;
				end
			else
				local selectedNode,linkedNode = self:GetSelectedNodeAndLinkedNode();
				if(selectedNode)then
					local type = selectedNode:GetType();
					if(type ~= "IndoorHouse")then
						event.canReturn.value = false;--截断鼠标事件
					end
				end
			end
		end
	end
end
function HomeLandNodeProcessor:DoMouseMove_Stage(event)
	--不pick室内这个模型
	if(not self:CanPass(event))then
		return
	end
	--commonlib.echo("===========DoMouseMove_Stage");
	if(self.isDrag and self.dragContainer)then
		local pt = ParaScene.MousePick(70, "point");
		if(pt:IsValid())then
			local x,y,z = pt:GetPosition();
			local dx = x - self.dragLastX;
			local dy = y - self.dragLastY;
			local dz = z - self.dragLastZ;
			self:UpdateMirrorDragNodePos(dx,dy,dz);
			self.dragLastX,self.dragLastY,self.dragLastZ = x,y,z;
		end
	end
end
--更新拖拽镜像的位置
function HomeLandNodeProcessor:UpdateMirrorDragNodePos(dx,dy,dz)
	if(self.dragContainer)then
		--dy = math.max(dy,0);
		local x,y,z = self.dragContainer:GetPosition();
		x = x + dx;
		y = y + dy;
		z = z + dz;
		self.dragContainer:SetPosition(x,y,z);
	end
end
function HomeLandNodeProcessor:Reset()
	self.clickNum = 0;
	self.readyDragNode = nil;
	self.selectedNode = nil;
end
--选中一个物体
function HomeLandNodeProcessor:SelectedNode(event)
	if(not event)then return end
	local target = event.currentTarget;
	if(target)then
		local type = target:GetType();
		if(type ~= "Grid")then
			self:ShowSelected(target,true);
			--记住被选中的物体
			self:SetSelectedNode(target);
		elseif(type == "Grid")then
			local node = target:HasLinkedNode()
			if(node)then
				--如果seedgrid有关联的node,显示node被选中
				self:ShowSelected(node,true);
				--记住被选中的物体 是关联的node
				self:SetSelectedNode(node);
			else
				--如果在浏览状态下显示箭头
				if(self.editMode == "view")then
					--如果是主人身份
					if(self.roleState == "master")then
						--如果没有 显示seedgrid上面的箭头提示
						self:ShowArrow(target,true)
						--self:ShowSelected(target,true)
					end
				else
					--显示选中花圃
					self:ShowSelected(target,true)
				end
				self:SetSelectedNode(target);
			end
		end
	end
end
--取消选中一个物体
function HomeLandNodeProcessor:UnSelectedNode(event)
	if(not event)then return end
	local target = event.currentTarget;
	if(target)then
		local type = target:GetType();
		if(type ~= "Grid")then
			self:ShowSelected(target,false);
		elseif(type == "Grid")then
			--如果在浏览状态下
			if(self.editMode == "view")then
				--隐藏箭头
				self:ShowArrow(target,false);
				--self:ShowSelected(target,false);
			else
				--取消选中花圃
				self:ShowSelected(target,false)
			end
			--如果seedgrid有关联的node
			local node = target:HasLinkedNode()
			if(node)then
				self:ShowSelected(node,false);
			end
		end
	end
	self:SetSelectedNode(nil);
end
--显示提示
function HomeLandNodeProcessor:ShowTip(event)
	if(not event)then return end
	local target = event.currentTarget;
	if(target)then
		local type = target:GetType();
		if(type ~= "Grid")then
			if(target ~= self.selectedNode)then
				self:ShowSelected(target,true);
			end
		elseif(type == "Grid")then
			local node = target:HasLinkedNode()
			if(node)then
				if(node ~= self.selectedNode)then
					--如果seedgrid有关联的node,显示node被选中
					self:ShowSelected(node,true);
				end
			else
				--如果在浏览状态下显示箭头
				if(self.editMode == "view")then
					--如果是主人身份
					if(self.roleState == "master")then
						if(target ~= self.selectedNode)then
							--如果没有 显示seedgrid上面的箭头提示
							self:ShowArrow(target,true)
							--self:ShowSelected(target,true)
						end
					end
				else
					if(target ~= self.selectedNode)then
						--显示选中花圃
						self:ShowSelected(target,true)
					end
				end
			end
		end
	end
end
--隐藏提示
function HomeLandNodeProcessor:HideTip(event)
	if(not event)then return end
	local target = event.currentTarget;
	if(target)then
		local type = target:GetType();
		if(type ~= "Grid")then
			if(target ~= self.selectedNode)then
				self:ShowSelected(target,false);
			end
		elseif(type == "Grid")then
			--如果在浏览状态下
			if(self.editMode == "view")then
				commonlib.echo("====================view");
				commonlib.echo(target:GetUID());
				if(self.selectedNode)then
					commonlib.echo("====================selectedNode");
					commonlib.echo(self.selectedNode:GetUID());
				end
				if(target ~= self.selectedNode)then
					--隐藏箭头
					self:ShowArrow(target,false);
					--self:ShowSelected(target,false)
				end
			else
				if(target ~= self.selectedNode)then
					--显示选中花圃
					self:ShowSelected(target,false)
				end
			end
			--如果seedgrid有关联的node
			local node = target:HasLinkedNode()
			if(node)then
				if(node ~= self.selectedNode)then
					self:ShowSelected(node,false);
				end
			end
		end
	end
end

--是否显示花圃上面的箭头
function HomeLandNodeProcessor:ShowArrow(seedGridNode,bShow)
	if(not seedGridNode)then return end
	if(self.arrowRootNode)then
		self.arrowRootNode:Detach();
		if(bShow)then
			local x,y,z = seedGridNode:GetPosition();
			local arrow = CommonCtrl.Display3D.SceneNode:new{
				x = x,
				y = y,
				z = z,
				assetfile = "model/06props/v3/headarrow.x",
			};
			self.arrowRootNode:AddChild(arrow);
		end	
	end
end
--在选中花圃的前提下，链接一个node后，更新选中的对象为node
function HomeLandNodeProcessor:SnapAndSelected()
	if(not self.selectedNode)then return end
	local target = self.selectedNode;
	local type = target:GetType();
	if(type == "Grid")then
		self:ShowArrow(target,false)
		local node = target:HasLinkedNode()
		if(node)then
			--如果seedgrid有关联的node,显示node被选中
			self:ShowSelected(node,true);
			--记住被选中的物体 是关联的node
			self:SetSelectedNode(node);
		end
	end
end
--取消选中已经选中的node
function HomeLandNodeProcessor:UnSelected()
	local target = self.selectedNode;
	if(target)then
		local type = target:GetType();
		if(type ~= "Grid")then
			self:ShowSelected(target,false);
		elseif(type == "Grid")then
			--隐藏箭头
			self:ShowArrow(target,false);
		end
	end
	--如果在拖拽状态 停止拖拽
	self:DirectlyStopDragSelectedNode();
	self:SetSelectedNode(nil);
end
--记录被选中的node，如果node=nil 取消选中
function HomeLandNodeProcessor:SetSelectedNode(node)
	local old = self.selectedNode;
	self.selectedNode = node;
	if(self.OnSelectedNodeFunc and type(self.OnSelectedNodeFunc) == "function")then
		local msg = {
			oldnode = old,
			node = node,
			parent_canvas = self.parent_canvas,
		}
		self.OnSelectedNodeFunc(msg);
	end
end
--返回选中的node 和它关联的花圃
function HomeLandNodeProcessor:GetSelectedNodeAndLinkedNode()
	if(self.selectedNode and self.canvas and self.canvas.rootNode)then
		local selectedNodeUID  = self.selectedNode:GetUID();
		local type = self.selectedNode:GetType();
		if(type ~= "Grid")then
			local linkedUID = self.selectedNode:GetSeedGridNodeUID();
			local linkedNode;
			if(linkedUID and linkedUID ~= selectedNodeUID)then
				linkedNode = self.canvas.rootNode:GetChildByUID(linkedUID);
				return self.selectedNode,linkedNode;
			end
		end
		return self.selectedNode;
	end
end
function HomeLandNodeProcessor:ShowSelected(node,bShow)
	if(node)then
		local id = node:GetEntityID();
		local obj = ParaScene.GetObject(id);
		if(obj and obj:IsValid())then
			if(bShow)then
				if(self.editMode == "view")then
					local type = node:GetType();
					if(type == "PlantE" or self:CanInteractNodeOnViewMode_OutdoorOther(node))then
					--if(type == "PlantE" or type == "OutdoorHouse" or self:CanInteractNodeOnViewMode_OutdoorOther(node))then
						--obj:GetAttributeObject():SetField("showboundingbox", true);
						ParaSelection.AddObject(obj,1);
					end
				else
					--obj:GetAttributeObject():SetField("showboundingbox", true);
					ParaSelection.AddObject(obj,1);
				end
				obj:LoadPhysics();
			else
				--obj:GetAttributeObject():SetField("showboundingbox", false);
				ParaSelection.AddObject(obj,-1);
			end
		end
	end
end
function HomeLandNodeProcessor:CanInteractNodeOnViewMode_OutdoorOther(node)
	if(self.parent_canvas)then
		return self.parent_canvas:GetExtendsObjectType_OutdoorOther(node);
	end
end
--设置编辑模式 "view" or "edit"
function HomeLandNodeProcessor:SetEditMode(mode)
	self.editMode = mode;
end
function HomeLandNodeProcessor:GetEditMode()
	return self.editMode;
end
--facing delta
function HomeLandNodeProcessor:SetFacingDelta(facing)
	if(facing and self.editMode == "edit")then
		local selectedNode,linkedNode = self:GetSelectedNodeAndLinkedNode();
		if(selectedNode)then
			selectedNode:SetFacingDelta(facing);
			selectedNode:SetPropertyIsChanged(true);
		end
		if(linkedNode)then
			linkedNode:SetFacingDelta(facing);
			linkedNode:SetPropertyIsChanged(true);
		end
		
		local hook_msg = { aries_type = "OnHomelandItemRotated", wndName = "homeland"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	end
end
HomeLandNodeProcessor.VIP_Scale_Map = {
	[0] = 1.1,
	[1] = 1.2,
	[2] = 1.4,
	[3] = 1.6,
	[4] = 1.8,
	[5] = 2.0,
	[6] = 2.2,
	[7] = 2.4,
	[8] = 2.6,
	[9] = 2.8,
	[10] = 3,
}
function HomeLandNodeProcessor:CheckVIP(node,v)
	if(not node)then
		return
	end
	if(node.GetType)then
		local type = node:GetType() or "";
		if(type == "Furniture")then
			_guihelper.MessageBox("室内家具不能缩放！");
			return
		end
	end
	local Pet = commonlib.gettable("MyCompany.Aries.Pet");
	local bean = Pet.GetBean() or {};
	local energy = bean.energy or 0;
	local m = bean.m or 0;
	local mlel = bean.mlel or 0;
	if(mlel <= 0 and energy == 0)then
		local s = string.format("你还没有成为我们的魔法星用户，开通魔法星后可以立即体验！现在就开通魔法星吗？");
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.Yes)then
			else
				local gsid=998;
				Map3DSystem.mcml_controls.pe_item.OnClickGSItem(gsid,true);	
			end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/GotMagicStone_32bits.png; 0 0 153 49"});
		return;
	else
		local scaling = node:GetScale() or 1;
		local scaling_result = scaling + v;
		local max_scale = HomeLandNodeProcessor.VIP_Scale_Map[mlel] or 1;
		if(v > 0)then
			--zoom in
			if(mlel < 10)then
				if((scaling_result - max_scale) > 0.001)then
					local s = string.format("你的魔法星等级还不够，补充多点能量石即可获得更完美体验！现在就补充能量石吗？");
					_guihelper.Custom_MessageBox(s,function(result)
						if(result == _guihelper.DialogResult.Yes)then
						else
							local gsid=998;
							Map3DSystem.mcml_controls.pe_item.OnClickGSItem(gsid,true);	
						end
					end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/GotMagicStone_32bits.png; 0 0 153 49"});
					return;
				end
			end
			if( (scaling_result - max_scale) > 0.001)then
				--_guihelper.MessageBox("不能再大啦，再大就把天撑破啦！");
				return
			end
			return true;
		else
			--zoom out
			if((0.5 - scaling_result) > 0.001)then
				--_guihelper.MessageBox("不能再小啦！再小蚂蚁都看不见啦！");
				return
			end
			return true;
		end
	end
end
--scaling delta
function HomeLandNodeProcessor:SetScalingDelta(scaling)
	if(scaling and self.editMode == "edit")then
		local selectedNode,linkedNode = self:GetSelectedNodeAndLinkedNode();
		local can_pass = self:CheckVIP(selectedNode,scaling);
		if(not can_pass)then
			return
		end
		if(selectedNode)then
			selectedNode:SetScalingDelta(scaling);
			selectedNode:SetPropertyIsChanged(true);
		end
		if(linkedNode)then
			linkedNode:SetScalingDelta(scaling);
			linkedNode:SetPropertyIsChanged(true);
		end
		
		local hook_msg = { aries_type = "OnHomelandItemScaling", wndName = "homeland"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	end
end
--position delta
function HomeLandNodeProcessor:SetPositionDelta(dx,dy,dz)
	if(dx and dy and dz and self.editMode == "edit")then
		local selectedNode,linkedNode = self:GetSelectedNodeAndLinkedNode();
		if(selectedNode)then
			selectedNode:SetPositionDelta(dx,dy,dz);
			selectedNode:SetPropertyIsChanged(true);
		end
		if(linkedNode)then
			linkedNode:SetPositionDelta(dx,dy,dz);
			linkedNode:SetPropertyIsChanged(true);
		end
	end
end
--在self.clickNum = 1时 直接拖拽选中的同一个物体
function HomeLandNodeProcessor:DirectlyDragSelectedNode()
	local selectedNode,linkedNode = self:GetSelectedNodeAndLinkedNode();
	if(self.clickNum == 1 and selectedNode == self.readyDragNode)then
		self.clickNum = 2;
		self:StartDrag();
	end
end
function HomeLandNodeProcessor:DirectlyStopDragSelectedNode()
	if(self.clickNum == 2)then
		self:StopDrag();
		self:Reset();
	end
end
--开始拖拽
function HomeLandNodeProcessor:StartDrag()
	if(not self.dragRootNode)then return end
	self.dragRootNode:Detach();
	local container = CommonCtrl.Display3D.SceneNode:new{
		node_type = "container",
		x = 0,
		y = 0,
		z = 0,
		visible = true,
	};
	self.dragRootNode:AddChild(container);
	
	local mirror_1;
	local mirror_2;
	local selectedNode,linkedNode = self:GetSelectedNodeAndLinkedNode();
	if(selectedNode)then
		local mirror_1 = selectedNode:Clone();
		container:AddChild(mirror_1);
		self:ShowSelected(selectedNode,false);
		selectedNode:SetVisible(false);
		
		--以selectedNode的坐标为准
		self.isDrag = true;
		self.dragLastX,self.dragLastY,self.dragLastZ = selectedNode:GetPosition();
		
		--属性已经改变
		selectedNode:SetPropertyIsChanged(true);
	end
	if(linkedNode)then
		local mirror_2 = linkedNode:Clone();
		container:AddChild(mirror_2);
		
		linkedNode:SetVisible(false);
		self.dragLastX,self.dragLastY,self.dragLastZ = linkedNode:GetPosition();
		
		--属性已经改变
		linkedNode:SetPropertyIsChanged(true);
	end
	--记录拖拽的父容器
	self.dragContainer = container;
	
	local hook_msg = { aries_type = "OnHomelandItemPicked", wndName = "homeland"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
end
--停止拖拽
function HomeLandNodeProcessor:StopDrag()
	if(not self.dragRootNode or not self.dragContainer)then return end
	local selectedNode,linkedNode = self:GetSelectedNodeAndLinkedNode();
	self:UpdateNodePosition(selectedNode,1);
	self:UpdateNodePosition(linkedNode,2);
	self.isDrag = false;
	self.dragRootNode:Detach();
	
	--依旧显示面板
	self.selectedNode = nil;
	if(self.canvas)then
		self.canvas:DirectDispatchChildSelectedEvent(selectedNode);
	end
	local hook_msg = { aries_type = "OnHomelandItemDropped", wndName = "homeland"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
end
--通过镜像的位置更新真实node的坐标
function HomeLandNodeProcessor:UpdateNodePosition(node,mirrorNodeIndex)
	if(not node or not mirrorNodeIndex or not self.dragContainer)then return end
	local mirror_node = self.dragContainer:GetChild(mirrorNodeIndex);
	if(mirror_node)then
		local renderParams = mirror_node:GetRenderParams();
		if(renderParams)then
			local x,y,z = renderParams.x,renderParams.y,renderParams.z;
			node:SetPosition(x,y,z);
			node:SetVisible(true);
			--local type = node:GetType();
			--if(type == "Grid")then
				--local entity = node:GetEntity();
				--if(entity)then
					--entity:SnapToTerrainSurface(0);
				--end
			--end
		end
	end
end