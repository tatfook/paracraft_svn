--[[
Title: HomeLandMouse
Author(s): Leio
Date: 2009/4/8
Desc:在家园中，控制鼠标的行为
主要有两个阶段
浏览阶段：鼠标点击带交互的物体，会根据不同的物体，显示不同的面板（由UIManager控制）
编辑家园阶段：
第一次点击，选中物体
第二次点击，物体吸附在鼠标上
第三次点击，物体放下
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandMouse.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/SeedGrid.lua");
NPL.load("(gl)script/ide/Display/Containers/MiniScene.lua");
NPL.load("(gl)script/ide/Display/Containers/Scene.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandObj.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandCanvas.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/paraworld.homeland.plantevolved.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
local HomeLandMouse = {
	-- 选中的物体
	selectedNode = nil,
	-- 选中物体的镜像
	mirrorSelectedNode = nil,
	-- 与选中的物体相交叉的物体,hitTestNode是一个Grid类型的对象
	hitTestNode = nil,
	--hitTestNode绑定的SeedGrid第几个位置被选中
	hitTestNodeIndex = nil,
	-- 针对选择的物体，点击的次数
	clickNum = 0,
	-- 一个家园的画布，一个家园将在这个画布上显示出来
	canvas = nil,
	-- 当选中一个物体后，将在miniScene上显示它的镜像
	miniScene = nil,
	
	objWithMouse = nil,
	
}
commonlib.setfield("Map3DSystem.App.HomeLand.HomeLandMouse",HomeLandMouse);
function HomeLandMouse.Init()
	HomeLandMouse.DrawMirrorOfSelectedNode_Scene = CommonCtrl.Display.Containers.MiniScene:new();
	HomeLandMouse.DrawMirrorOfSelectedNode_Scene:Init();
end
function HomeLandMouse.RegHook()
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	local o = {hookType = hookType, 		 
		hookName = "HomeLandMouse_mouse_down_hook", appName = "input", wndName = "mouse_down"}
			o.callback = HomeLandMouse.OnMouseDown;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "HomeLandMouse_mouse_move_hook", appName = "input", wndName = "mouse_move"}
			o.callback = HomeLandMouse.OnMouseMove;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "HomeLandMouse_mouse_up_hook", appName = "input", wndName = "mouse_up"}
			o.callback = HomeLandMouse.OnMouseUp;
	CommonCtrl.os.hook.SetWindowsHook(o);
end
function HomeLandMouse.UnHook()
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "HomeLandMouse_mouse_down_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "HomeLandMouse_mouse_move_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "HomeLandMouse_mouse_up_hook", hookType = hookType});
end
function HomeLandMouse.OnMouseUp(nCode, appName, msg)
	local self = HomeLandMouse;
	if(not self.canvas)then return nCode end;
	local roleState,locationState,editingState = self.canvas:GetRoleState(),self.canvas:GetLocationState(),self.canvas:GetEditingState()
	if(editingState == "false")then 
		if(not self.selectedNode or msg.mouse_button == "right")then
			return nCode;
		end
	else
		if(not self.selectedNode)then
			return nCode;
		end
	end
	return nil;
end
function HomeLandMouse.OnMouseMove(nCode, appName, msg)
	local self = HomeLandMouse;
	if(not self.canvas)then return nCode end;
	local roleState,locationState,editingState = self.canvas:GetRoleState(),self.canvas:GetLocationState(),self.canvas:GetEditingState()
	self.UpateNodeMouse();
	if(editingState == "false" and roleState == "master")then 
		self.HitTestSeedGridIndex();
	else
		if(self.clickNum == 2 )then
			self.Update_DrawMirrorOfSelectedNode();
		end
	end
	return nCode;
end
function HomeLandMouse.OnMouseDown(nCode, appName, msg)
	local self = HomeLandMouse;
	if(not self.canvas)then return end;
	self.hitTestNode = nil;
	self.hitTestNodeIndex = nil;
	local roleState,locationState,editingState = self.canvas:GetRoleState(),self.canvas:GetLocationState(),self.canvas:GetEditingState()
	if(editingState == "false")then 
		if(msg.mouse_button == "left")then
			local node = self.canvas:Selected();
			if(node)then
				local type = node.HomeLandObj;
				if(type ==  Map3DSystem.App.HomeLand.ObjEnum.Grid and node.seedgrid and roleState == "master")then
					local pt = ParaScene.MousePick(70, "point");
					if(pt:IsValid())then
						local x,y,z = pt:GetPosition();
						local point = {x = x,y = y,z = z};
						local result,hitTestNodeIndex = node.seedgrid:Update(point);
						if(result)then
							self.hitTestNode = node;
							self.hitTestNodeIndex = hitTestNodeIndex;
						end
					end
				end
				self.SwapSelectedNode(node);
				return nCode;
			else
				self.Clear();
			end
		end
		--if(self.clickNum ~= 2)then
			--return nCode;
		--end	
	else
		if(msg.mouse_button == "right")then
			if(self.clickNum ~= 2)then
				local node = self.canvas:Selected();		
				if(node)then
					local type = node.HomeLandObj;
					local canDirectMove = Map3DSystem.App.HomeLand.CanGridItems[type];
					if(not canDirectMove)then
						self.SwapSelectedNode(node);
						self.DoMoveNode();
					end
				end	
			end
		elseif(msg.mouse_button == "left")then
			-- 在移动的情况下
			if(self.clickNum == 2)then
				local result = self.canvas:PutDownNode(self.selectedNode);
				if(result)then
					-- 放下物体
					self.clickNum = 1;
					local type = self.selectedNode.HomeLandObj;
					-- 更新选中物体的属性
					self.Update_SelectedNode();
					self.Remove_DrawMirrorOfSelectedNode();				
				end
			else
				local node = self.canvas:Selected();
				if(node)then
					if( node ~= self.selectedNode)then
						self.clickNum = 1;
						self.SwapSelectedNode(node);			
					else
						local type = node.HomeLandObj;
						local canDirectMove = Map3DSystem.App.HomeLand.CanGridItems[type];
						if(not canDirectMove)then
							self.DoMoveNode();
						end
					end
				else
					self.Clear();
				end
			end
			--return nil;
		end
	end
	return nCode
	--if(self.clickNum ~= 2)then
		--return nCode;
	--end	
end
function HomeLandMouse.SwapSelectedNode(node)
	if(not node)then return end
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
	local self = HomeLandMouse;
	-- 取消选中上一个物体
	if(self.selectedNode)then
		self.selectedNode:SetSelected(false);
		self.canvas:UpdatePropertyPanel(self.selectedNode,false);
		if(self.selectedNode.HomeLandObj == Map3DSystem.App.HomeLand.ObjEnum.Grid)then
			if(self.selectedNode.seedgrid)then
				self.selectedNode.seedgrid:Selected(nil);
			end
		end
	end
	self.selectedNode = node;	
	local type = node.HomeLandObj;
	if(self.canvas.editingState == "true" and Map3DSystem.App.HomeLand.ObjCanSelectedAtEdit[type])then
		self.selectedNode:SetSelected(true);
		self.canvas:UpdatePropertyPanel(self.selectedNode,true);
	elseif(self.canvas.editingState == "false" and Map3DSystem.App.HomeLand.ObjCanSelectedAtView[type])then
		local config = Map3DSystem.App.HomeLand.HomeLandConfig;
		if(config.View_ShowSelectedTip == "true")then
			if(self.selectedNode.HomeLandObj ~= Map3DSystem.App.HomeLand.ObjEnum.Grid)then
				self.selectedNode:SetSelected(true);
			end
		end
		if(self.selectedNode.HomeLandObj == Map3DSystem.App.HomeLand.ObjEnum.Grid)then
			if(self.selectedNode.seedgrid)then
				self.selectedNode:SetSelected(false);
				self.selectedNode.seedgrid:Selected(self.hitTestNodeIndex);
			end
		end
		self.canvas:UpdatePropertyPanel(self.selectedNode,true,self.hitTestNodeIndex);
	end
	
end
function HomeLandMouse.Clear()
	local self = HomeLandMouse;
	self.clickNum = 0;
	self.mirrorSelectedNode = nil;
	if(self.selectedNode)then
		self.selectedNode:SetSelected(false);
		self.canvas:UpdatePropertyPanel(self.selectedNode,false);
		if(self.selectedNode.seedgrid)then
			self.selectedNode.seedgrid:Selected(nil);
		end
		self.selectedNode = nil;
	end
end
function HomeLandMouse.UpateNodeMouse()
	local self = HomeLandMouse;
	local node = self.canvas:MousePick();
	if(self.objWithMouse == node)then
		return false;
	end
	local oldObjWithMouse = self.objWithMouse;
	self.objWithMouse = node;
	local obj;
	local bean;
	if(oldObjWithMouse)then
		-- mouse leave
		if(self.selectedNode ~= oldObjWithMouse)then
			oldObjWithMouse:SetSelected(false);
			local type = oldObjWithMouse.HomeLandObj;
		end
	end
	if(self.objWithMouse)then
		-- mouse over
		if(self.selectedNode ~= self.objWithMouse)then
			local type = self.objWithMouse.HomeLandObj;
				if(self.canvas.editingState == "true" and Map3DSystem.App.HomeLand.ObjCanSelectedAtEdit[type] )then
					if(self.clickNum == 2 and type == Map3DSystem.App.HomeLand.ObjEnum.Grid )then
					
					else
					self.objWithMouse:SetSelected(true);
					end
				elseif(self.canvas.editingState == "false" and Map3DSystem.App.HomeLand.ObjCanSelectedAtView[type])then
					local config = Map3DSystem.App.HomeLand.HomeLandConfig;
					if(config.View_ShowSelectedTip == "true")then
						if(self.objWithMouse.HomeLandObj ~= Map3DSystem.App.HomeLand.ObjEnum.Grid)then
							self.objWithMouse:SetSelected(true);
						end
					end
				end
		end
	end
end
-----------------------------------------------------------------------
-- draw selected nodes
-----------------------------------------------------------------------
function HomeLandMouse.PutDownPlantE()
	local self = HomeLandMouse;
	if(self.hitTestNode and self.selectedNode)then
			--放到格子中
			local seedgrid = self.hitTestNode.seedgrid;
			if(seedgrid and seedgrid:CanPutDown())then
					local clientdata = self.selectedNode:ClassToMcml();
					NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
					commonlib.echo("初始化植物成长的数据");
					commonlib.echo(clientdata);
					Map3DSystem.Item.ItemManager.GrowHomeLandPlant(self.selectedNode.guid, clientdata, function(msg)
							commonlib.echo("初始化植物成长的数据---之后：");
							commonlib.echo(msg);
							if(msg and msg.issuccess)then
								self.selectedNode:SetGUID(msg.appended_guid);
								--根据返回的信息，初始化植物成长的数据
								local bean = msg;
								self.canvas:BindNode_PlantE(self.selectedNode,bean)
								seedgrid:PutDown(self.selectedNode);
								seedgrid:Selected(nil);
								self.selectedNode:SetVisible(true);
								self.canvas:UpdatePropertyPanel(self.selectedNode,true,self.hitTestNodeIndex);
								local clientdata = self.selectedNode:ClassToMcml();
								commonlib.echo("放下种子后：");
								commonlib.echo(clientdata);
								local guid = msg.appended_guid;
								local item = Map3DSystem.Item.ItemManager.GetItemByGUID(guid);
								if(item and item.bag) then
									local msg = {
										guid = msg.appended_guid,
										bag = item.bag, -- usually this bag will be 10001 or 10002~10009
										clientdata = clientdata,
									};
									paraworld.inventory.SetClientData(msg, "PutDownPlantE"..guid, function(msg)
										if(msg.issuccess == false) then
											log("error: failed modify items of homeland\n")
										end
									end);
								end
							end
					end)
			end
	end
end
function HomeLandMouse.RecoverNode(node)
	local self = HomeLandMouse;
	if(not node)then return end;
	local seedgrid = node.seedgrid;
	if(seedgrid)then
		seedgrid:Selected(nil);
	end
	self.canvas:HideGrid();
	self.clickNum = 1;
	self.DoRemove();
end
function HomeLandMouse.Update_SelectedNode()
	local self = HomeLandMouse;
	if(not self.mirrorSelectedNode or not self.selectedNode)then return end
	self.Update_DrawMirrorOfSelectedNode()
	local type = self.selectedNode.HomeLandObj;
	if(type == Map3DSystem.App.HomeLand.ObjEnum.PlantE)then
		--self.Update_SelectedNode_PlantE();
	else
		self.Update_SelectedNode_Normal();
	end
end
function HomeLandMouse.Update_SelectedNode_Normal()
	local self = HomeLandMouse;
	if(not self.mirrorSelectedNode or not self.selectedNode)then return end
	local params = self.mirrorSelectedNode:GetEntityParams();
	self.selectedNode:SetEntityParams(params);
	self.selectedNode:UpdateEntity();
	self.selectedNode:SetVisible(true);
	self.selectedNode:SetSelected(true);
	self.canvas:UpdatePropertyPanel(self.selectedNode,true);
	if(self.selectedNode.seedgrid)then
		self.selectedNode.seedgrid:UpdatePosition();
	end
	self.CheckRoomEntry(self.selectedNode);
end
function HomeLandMouse.HitTestSeedGridIndex()
	local self = HomeLandMouse;
	local pt = ParaScene.MousePick(70, "point");	
	if(pt:IsValid())then
		local x,y,z = pt:GetPosition();
		
		NPL.load("(gl)script/ide/Display/Util/ObjectsCreator.lua");
		if(not self.canvas.custom_sprite3D)then return end
			local len = self.canvas.custom_sprite3D:GetNumChildren();
			local k,node;
			local point = {x = x,y = y,z = z};
			for k = 1,len do
				--找出grid类型的对象
				node = custom_sprite3D:GetChildAt(k);
				local classtype = node.HomeLandObj;
				if(classtype == Map3DSystem.App.HomeLand.ObjEnum.Grid)then
					--检测它绑定的SeedGrid
					if(node.seedgrid)then
						local result,hitTestNodeIndex = node.seedgrid:Update(point);
						--commonlib.echo({result,point});
						--if(result)then
							--self.hitTestNode = node;
							--self.hitTestNodeIndex = hitTestNodeIndex;
						--end
					end
				end
			end
	end	
	
end
--update 2009/10/11
--如果是移动花圃的镜像，现在直接更新花圃的位置 and 和它关联的植物（如果有的话）
--其他类型的物品移动的还是镜像，在放下物体后，通过镜像更新真实物体的位置
function HomeLandMouse.DirectUpdateSeedGrid(x,y,z)
	local self = HomeLandMouse;
	if(self.selectedNode)then
		local type = self.selectedNode.HomeLandObj;
		if(type == Map3DSystem.App.HomeLand.ObjEnum.Grid)then
			if(x and y and z)then
				self.selectedNode:SetPosition(x,y,z);
			end
			if(self.selectedNode.seedgrid)then
				self.selectedNode.seedgrid:UpdatePosition();
			end
		end
	end
end
function HomeLandMouse.Update_DrawMirrorOfSelectedNode()
	local self = HomeLandMouse;
	if(not self.mirrorSelectedNode)then return end
	self.mirrorSelectedNode:SetVisible(true);
	self.selectedNode:SetVisible(false);
	-- limit the mouse move object to terrain surface, this will effect the homeland editing
	--local pt = ParaScene.MousePick(70, "point");
	local pt = ParaScene.MousePick(70, "walkpoint");	
	if(pt:IsValid())then
		local x,y,z = pt:GetPosition();
		self.mirrorSelectedNode:SetPosition(x,y,z);	
		
		--如果是移动花圃的镜像，现在直接更新花圃的位置 and 和它关联的植物（如果有的话）
		self.DirectUpdateSeedGrid(x,y,z)
		
		--NPL.load("(gl)script/ide/Display/Util/ObjectsCreator.lua");
		--if(not self.canvas.custom_sprite3D)then return end
		--local type = self.selectedNode.HomeLandObj;
		--local canGridItem = Map3DSystem.App.HomeLand.CanGridItems[type];
		--if(canGridItem)then
			--self.hitTestNode = nil
			--local len = self.canvas.custom_sprite3D:GetNumChildren();
			--local k,node;
			--local point = {x = x,y = y,z = z};
			--local box1 = self.mirrorSelectedNode:GetViewBox();
			--for k = 1,len do
				--node = custom_sprite3D:GetChildAt(k);
				--local classtype = node.HomeLandObj;
				--if(classtype == "Grid")then
					--if(node.seedgrid)then
						--local result = node.seedgrid:Update(point);
						----commonlib.echo({result,point});
						--if(result)then
							--self.hitTestNode = node;
						--end
					--end
				--end
			--end
		--end
	end	
	
end
function HomeLandMouse.Create_DrawMirrorOfSelectedNode(node)
	local self = HomeLandMouse;
	local miniScene = self.DrawMirrorOfSelectedNode_Scene;
	if(not miniScene or not node)then return end;
	local clone_node = node:CloneNoneID();
	self.mirrorSelectedNode = clone_node;
	miniScene:Clear();
	miniScene:AddChild(self.mirrorSelectedNode);
	self.mirrorSelectedNode:SetVisible(false);
end
function HomeLandMouse.Remove_DrawMirrorOfSelectedNode()
	local self = HomeLandMouse;
	--local miniScene = self.DrawMirrorOfSelectedNode_Scene;
	--if(not miniScene or not node)then return end;
	--miniScene:Clear();
	if(self.mirrorSelectedNode)then
		self.mirrorSelectedNode:SetVisible(false);
	end
end
-----------------------------------------------------------
function HomeLandMouse.DoMoveNode()
	local self = HomeLandMouse;
	if(self.selectedNode)then
		self.clickNum = 2;
		-- 创建一个镜像Node，准备移动
		self.Create_DrawMirrorOfSelectedNode(self.selectedNode);	
	end
end
function HomeLandMouse.IsRemove()
	local self = HomeLandMouse;
	return (self.clickNum == 2)
end
function HomeLandMouse.DoRemove()
	local self = HomeLandMouse;
	if(self.selectedNode and self.clickNum == 1)then
		local type = self.selectedNode.HomeLandObj;
		if(type == Map3DSystem.App.HomeLand.ObjEnum.RoomEntry)then
			_guihelper.MessageBox("房屋暂时不能移除！");
			return
		elseif(type == Map3DSystem.App.HomeLand.ObjEnum.Grid)then
			local uid = self.selectedNode:GetUID();
			--花圃上面还有植物
			if(self.canvas:FindNodeInGrid(uid))then
				_guihelper.MessageBox("花圃上面有植物，不能被回收！");
				return;
			else
				self.DoRemove_Internal(self.selectedNode);
			end
		else
			self.DoRemove_Internal(self.selectedNode);
		end
	end
end
function HomeLandMouse.DoRemove_Internal(node)
	local self = HomeLandMouse;
	if(not node)then return end
	local guid = node:GetGUID();
	local ItemManager = Map3DSystem.Item.ItemManager;
	ItemManager.RemoveHomeLandItem(guid, function(msg)
			if(msg.issuccess == true) then
					self.canvas:RemoveChild(self.selectedNode);
					self.Clear();
				end
	end);
end
--检测房屋入口是否需要更新
--因为房屋入口绑定了入口和出口的位置信息，在改变它的位移和旋转后
--绑定的提醒信息（模型/粒子）位置同样需要更新
function HomeLandMouse.CheckRoomEntry(node)
	if(not node)then return end
	local self = HomeLandMouse;
	local type = node.HomeLandObj;
	if(type == Map3DSystem.App.HomeLand.ObjEnum.RoomEntry)then
		self.canvas:UpdateEntryPos(node);
	end
end
--检测可种植的植物，在删除的时候
--更新和它绑定的花圃
function HomeLandMouse.CheckPlantE(node)
	if(not node)then return end
	local self = HomeLandMouse;
	local type = node.HomeLandObj;
	if(type == Map3DSystem.App.HomeLand.ObjEnum.PlantE)then
		local seedgrid = node.seedgrid;
		if(seedgrid)then
			seedgrid:RemoveSeed(node);
		end
	end
end
function HomeLandMouse.DoFacing(facing)
	if(not facing)then return end
	local self = HomeLandMouse;
	if(self.selectedNode)then
		self.selectedNode:SetFacingDelta(facing);
		self.CheckRoomEntry(self.selectedNode);
	end
end
function HomeLandMouse.ComeIn()
	local self = HomeLandMouse;
	if(self.canvas)then
		self.canvas:ComeIn();
	end
end
function HomeLandMouse.ComeOut()
	local self = HomeLandMouse;
	if(self.canvas)then
		self.canvas:ComeOut();
	end
end
function HomeLandMouse.BuildNodeFromItem(type,gsItem,guid)
	if(not type or not gsItem or not guid)then return end
	local self = HomeLandMouse;
	local param = {};
	param.bg = gsItem.icon;
	param.file = gsItem.assetfile;
	param.type = type;
	local obj_node = Map3DSystem.App.HomeLand.HomeLandMouse.BuildNode(param,guid,true);
	
	if(obj_node)then
		local clientdata = obj_node:ClassToMcml();
		if(type == Map3DSystem.App.HomeLand.ObjEnum.RoomEntry)then
			Map3DSystem.Item.ItemManager.GrowHomeLandHouse(guid, clientdata, function(msg)
				commonlib.echo("加入房屋（有成长）");
				commonlib.echo(msg);
						if(msg.issuccess == true) then
							local obj_node = Map3DSystem.App.HomeLand.HomeLandMouse.BuildNode(param,guid,false);
							obj_node:SetGUID(msg.appended_guid);
							local bean = msg;
							self.canvas:BindNode_RoomEntry(obj_node,bean,true)
						end
			end);
		elseif(type ~= Map3DSystem.App.HomeLand.ObjEnum.PlantE)then
			Map3DSystem.Item.ItemManager.AppendHomeLandItem(guid, clientdata, function(msg)
				commonlib.echo("加入普通物品（没有成长）");
				commonlib.echo(msg);
						if(msg.issuccess == true) then
							local obj_node = Map3DSystem.App.HomeLand.HomeLandMouse.BuildNode(param,guid,false);
							obj_node:SetGUID(msg.appended_guid);
						end
			end);
		end
	end
end
-- 创建一个Node
function HomeLandMouse.BuildNode(node,guid,notAttach)
	if(not node or not guid)then return end
	local self = HomeLandMouse;
	local x,y,z = ParaScene.GetPlayer():GetPosition();
	if(self.canvas)then
		local baseObject;
		local bean;
		-- 暂时这样划分
		if(node.type == "PlantE")then
	
			baseObject= Map3DSystem.App.HomeLand.HomeLandObj_B:new()
			baseObject.HomeLandObj = Map3DSystem.App.HomeLand.ObjEnum.PlantE;
			-- 假设远程数据已经加载
		--[[
 ///     items[list]
    ///         id：唯一标识
    ///         level：当前级别
    ///         isdroughted：是否处于干旱状态
    ///         isbuged：是否处于虫害状态
    ///         allowremove：是否允许当前用户铲除该植物
    ///         feedscnt：果实数量
]]

		bean = {id = 1,level = 1,isdroughted = false,isbuged = false,allowremove = false,feedscnt = 0};	
		elseif(node.type == "PetE")then
			--[[
			["friendliness"]=0,["strong"]=0,["nextlevelfr"]=0,["cleanness"]=0,["petid"]=2,["health"]=0,["nickname"]="",["level"]=-1,["birthday"]="05/15/2009 11:31:08",["mood"]=0,
]]
			bean = {petid = 2, friendliness = 0, strong = 0, nextlevelfr = 0, cleanness = 0, health = 0, nickname = "boy", level = -1, birthday = "05/15/2009 11:31:08", mood = 0,};
			baseObject= Map3DSystem.App.HomeLand.HomeLandObj_A:new()
			baseObject.HomeLandObj = Map3DSystem.App.HomeLand.ObjEnum.PetE;
		elseif(node.type == "Pet")then
		
		elseif(node.type == "RoomEntry")then
			baseObject= Map3DSystem.App.HomeLand.HomeLandObj_B:new()
			baseObject.HomeLandObj = Map3DSystem.App.HomeLand.ObjEnum.RoomEntry;
			bean = {};
		elseif(node.type == "Plant")then
			baseObject= Map3DSystem.App.HomeLand.HomeLandObj_B:new()
			baseObject.HomeLandObj = Map3DSystem.App.HomeLand.ObjEnum.Plant;
			bean = {};
		elseif(node.type == "Grid")then
			baseObject= Map3DSystem.App.HomeLand.HomeLandObj_B:new()
			baseObject.HomeLandObj = Map3DSystem.App.HomeLand.ObjEnum.Grid;
			bean = {};
		elseif(node.type == "OutdoorOther")then
			baseObject= Map3DSystem.App.HomeLand.HomeLandObj_B:new()
			baseObject.HomeLandObj = Map3DSystem.App.HomeLand.ObjEnum.OutdoorOther;
			bean = {};
		elseif(node.type == "Furniture")then
			baseObject= Map3DSystem.App.HomeLand.HomeLandObj_B:new()
			baseObject.HomeLandObj = Map3DSystem.App.HomeLand.ObjEnum.Furniture;
			bean = {};
			
		end
		if(not baseObject)then return end
		baseObject:Init();
		baseObject:SetAssetFile(node.file);
		baseObject:SetGUID(guid);
		local params = baseObject:GetEntityParams();
		
		baseObject:SetEntityParams(params);
		baseObject:SetPosition(x,y,z);
		baseObject:SetProgress(0.1);
		if(notAttach)then
			--return baseObject;
		end
		self.canvas:AddChild(baseObject);
		
		self.clickNum = 1;
		-- 取消选中上一个物体
		if(self.selectedNode)then
			self.selectedNode:SetSelected(false);
			self.canvas:UpdatePropertyPanel(self.selectedNode,false);
		end
		self.selectedNode = baseObject;	
		self.selectedNode:SetSelected(true);
		
		-- 如果是格子
		local type = self.selectedNode.HomeLandObj;
		if(type == Map3DSystem.App.HomeLand.ObjEnum.Grid)then
			local node = self.selectedNode;
			if(not node.seedgrid)then
				node.seedgrid = Map3DSystem.App.HomeLand.SeedGrid:new();
				node.seedgrid:BindNode(baseObject);
			end
		end
		-- 如果是直接移动的物体
		local type = self.selectedNode.HomeLandObj;
		--local canDirectMove = Map3DSystem.App.HomeLand.CanGridItems[type];
		--if(canDirectMove)then
			--commonlib.echo({"移动node：",self.selectedNode:GetUID(),params.name,guid});
			--self.DoMoveNode();
			--self.canvas:ShowGrid();
		--end
		if(type == Map3DSystem.App.HomeLand.ObjEnum.PlantE)then
			self.selectedNode:SetSelected(false);
			self.selectedNode:SetVisible(false);
			self.PutDownPlantE();
		else
			self.canvas:UpdatePropertyPanel(self.selectedNode,true);
		end
		return baseObject;
	end
end
--hook 创建物体
function HomeLandMouse.InvokeBuildNode(node)
	if(not node)then return end
	local params = node:GetEntityParams();
	local msg = { 
			aries_type = "GetNodeParams",
			wndName = "main",
			params = params,
		};
	--commonlib.echo("InvokeBuildNode");
	--commonlib.echo(msg);
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
end
function HomeLandMouse.EditHouse()
	local self = HomeLandMouse;
	if(not self.canvas)then return end
	self.Clear();
	self.canvas:EditHouse();
	-- begin editing house
	local ItemManager = Map3DSystem.Item.ItemManager;
	ItemManager.BeginHomeLandEditing();
	-- hide the dock and monthly paid area
	if(type(commonlib.getfield("MyCompany.Aries.Desktop.Dock.Show")) == "function") then
		MyCompany.Aries.Desktop.Dock.Show(false);
	end
	-- hide all pets in homeland
	MyCompany.Aries.Pet.HideMyPetsFromMemoryInHomeland();
	-- refresh myself, hide the mount and follow pet
	System.Item.ItemManager.RefreshMyself();
	
	--暂停跟随宠物ai
	Map3DSystem.App.HomeLand.HomeLandGateway.PauseFollowPetState(true)
end
function HomeLandMouse.SaveHouse()
	local self = HomeLandMouse;
	if(self.clickNum ~= 2 and self.canvas)then
		self.canvas:SaveHouse();
		self.Clear();
	end
	-- show the dock and monthly paid area when the user save the house info
	if(type(commonlib.getfield("MyCompany.Aries.Desktop.Dock.Show")) == "function") then
		MyCompany.Aries.Desktop.Dock.Show(true);
	end
	-- refresh all pets in homeland
	MyCompany.Aries.Pet.RefreshMyPetsFromMemoryInHomeland();
	-- refresh myself, show the mount and follow pet
	System.Item.ItemManager.RefreshMyself();
	
	--恢复跟随宠物ai
	Map3DSystem.App.HomeLand.HomeLandGateway.PauseFollowPetState(false)
end