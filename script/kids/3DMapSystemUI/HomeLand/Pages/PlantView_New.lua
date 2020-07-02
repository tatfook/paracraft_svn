--[[
Title: code behind for page PlantView_New.html
Author(s): Leio
Date: 2009/7/23
Desc:  script/kids/3DMapSystemUI/HomeLand/Pages/PlantView_New.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/PlantView_New.lua");
MyCompany.Aries.Inventory.PlantViewPage_New.GOGOGO()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Team/TeamWorldInstancePortal.lua");
local TeamWorldInstancePortal = commonlib.gettable("MyCompany.Aries.Team.TeamWorldInstancePortal");
NPL.load("(gl)script/ide/Display3D/SceneNodeHeadonSpeech.lua");
local PlantViewPage_New = {
	anim_isplaying =false,
};
commonlib.setfield("MyCompany.Aries.Inventory.PlantViewPage_New", PlantViewPage_New);

function PlantViewPage_New.ShowPage()
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
	local pos = Map3DSystem.App.HomeLand.HomeLandConfig.Panel_ShowPos;
	local self = PlantViewPage_New;
	local isinteam = TeamWorldInstancePortal.IsInTeam();
	left = pos.left;
	if(isinteam)then
		left = left + 180;
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/HomeLand/Pages/PlantView_New.html", 
			name = "PlantViewPage_New.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			click_through = true,
			directPosition = true,
				align = pos.align,
				x = left,
				y = pos.top,
				width = pos.width,
				height = pos.height,
		});
	if(not self.sceneNodeHeadonSpeech)then
		self.sceneNodeHeadonSpeech = CommonCtrl.Display3D.SceneNodeHeadonSpeech:new();
	end
end
function PlantViewPage_New.ClosePage()
	
	local self = PlantViewPage_New;
	if(self.IsPlayingAnims())then return end
	--在关闭面板的时候，清空选中的物体
	if(self.canvas and self.canvas.nodeProcessor)then
		self.canvas.nodeProcessor.selectedNode = nil;
	end
	self.Clear();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="PlantViewPage_New.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
end
function PlantViewPage_New.ClosePageWaitForAnimFinished()
	local self = PlantViewPage_New;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="PlantViewPage_New.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
end

function PlantViewPage_New.DoClick(name)
	local self = PlantViewPage_New;
	if(name == "water")then
		self.Water();
	elseif(name == "debug")then
		self.Debug();
	elseif(name == "gain")then
		self.GainFruits();
	elseif(name == "delete")then
		self.Delete();
	elseif(name == "go")then
		self.GOGOGO();
	end
end
function PlantViewPage_New.Clear()
	local self = PlantViewPage_New;
	--if(self.node)then
		--self.node:SetSelected(false);
	--end
	self.show = false;
	self.canvas = nil;
	self.node = nil;
	self.bean = nil;
	self.page = nil;
	self.curState = nil;
	self.anim_isplaying = false;
end
function PlantViewPage_New.Init(canvas,node,bean,combinedState)
	local self = PlantViewPage_New;
	if(not canvas or not node or not bean)then return end
	self.BindCanvas(canvas)
	self.BindNode(node)
	self.BindBean(bean)
	self.ChangeState(combinedState);
	
end
function PlantViewPage_New.BindCanvas(canvas)
	local self = PlantViewPage_New;
	self.canvas = canvas;
end
function PlantViewPage_New.BindNode(node)
	local self = PlantViewPage_New;
	self.node = node;
end
function PlantViewPage_New.BindBean(bean)
	local self = PlantViewPage_New;
	self.bean = bean;
end

function PlantViewPage_New.IsPlayingAnims()
	local self = PlantViewPage_New;
	return self.anim_isplaying;
end
--是否长满所有的级别
function PlantViewPage_New.IsSaturation()
	local self = PlantViewPage_New;
    local bean = self.bean;
    if(bean and bean.level and bean.totallevel and bean.grownvalue and bean.update)then
        if( bean.level >= bean.totallevel and bean.grownvalue >= bean.update)then
            return true;
        end
    end
end
function PlantViewPage_New.IsNotSaturation()
	local self = PlantViewPage_New;
    return not self.IsSaturation();
end
-- 是否需要浇水
function PlantViewPage_New.CanWater()
	local self = PlantViewPage_New;
	if(not self.bean or not self.node)then return end
	return self.bean.isdroughted and not self.IsPlayingAnims()
end
-- 是否需要除虫
function PlantViewPage_New.CanDebug()
	local self = PlantViewPage_New;
	if(not self.bean or not self.node)then return end
	return self.bean.isbuged and not self.IsPlayingAnims();
end
-- 是否可以收获果实
function PlantViewPage_New.CanGainFruits()
	local self = PlantViewPage_New;
	if(not self.bean or not self.node)then return end
	--if(self.bean.feedscnt and self.bean.feedscnt > 0 and not self.IsPlayingAnims())then
		--return true;
	--end
	if(self.IsSaturation() and not self.IsPlayingAnims())then
		return true;
	end
end
-- 是否可以删除
function PlantViewPage_New.CanDelete()
	local self = PlantViewPage_New;
	if(not self.bean or not self.node)then return end
	return not self.IsPlayingAnims();
end
-- 浇水
function PlantViewPage_New.Water()
	local self = PlantViewPage_New;
	if(self.CanWater())then
		local msg = {
			nid = Map3DSystem.App.HomeLand.HomeLandGateway.GetNID(),
			id = self.bean.id,
		}
		commonlib.echo("begin to water:");
		commonlib.echo(msg);
		paraworld.homeland.plantevolved.Water(msg,"plantevolved",function(msg)	
			commonlib.echo("after water:");
			commonlib.echo(msg);
			if(msg)then
				local bean =  commonlib.deepcopy(msg);
				self.anim_isplaying = true;
				self.DoAnimation(self.node,"water",function()
					commonlib.echo("==============water animation finished!");
					self.anim_isplaying = false;
					self.Update(bean);
					self.ClosePage();
					
					log("TODO: this is a temparory code to call hook of water other player homeland plant\n")
					local msg = { aries_type = "OnWaterPlant"};
					msg.wndName = "main";
					msg.nid = Map3DSystem.App.HomeLand.HomeLandGateway.GetNID();
					CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
					
					local msg = { aries_type = "onWaterPlant_MPD"};
					msg.wndName = "main";
					msg.nid = Map3DSystem.App.HomeLand.HomeLandGateway.GetNID();
					CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
				
				end)
			end
		end);
	else
		_guihelper.MessageBox("现在不需要浇水！")
	end
end
function PlantViewPage_New.DoAnimation(node,anim_type,callbackFunc)
	local self = PlantViewPage_New;
	if(self.sceneNodeHeadonSpeech)then
		if(node)then
			local width,height = 128,128;
			local x,y,z = node:GetPosition();
			local str_MCML = "";
			if(anim_type == "water")then
				y = y - 3;
				str_MCML = string.format("<img style=\"margin-left:6px;width:%dpx;height:%dpx;\" src=%q />", width, height, "Texture/Aries/Homeland/anims/water/v1/water_32bits_fps30_a003.png");
			elseif(anim_type == "debug")then
				y = y - 3.2;
				str_MCML = string.format("<img style=\"margin-left:6px;width:%dpx;height:%dpx;\" src=%q />", width, height, "Texture/Aries/Homeland/anims/debug/v1/debug_32bits_fps24_a004.png");
			elseif(anim_type == "delete")then
				y = y - 3;
				str_MCML = string.format("<img style=\"margin-left:6px;width:%dpx;height:%dpx;\" src=%q />", width, height, "Texture/Aries/Homeland/anims/delete/v1/delete_32bits_fps24_a008.png");
			elseif(anim_type == "hand")then
				y = y - 3;
				str_MCML = string.format("<img style=\"margin-left:6px;width:%dpx;height:%dpx;\" src=%q />", width, height, "Texture/Aries/Homeland/anims/hand/v1/hand_32bits_fps30_a010.png");
			end
			self.sceneNodeHeadonSpeech:Speak({
				text = str_MCML,
				x = x,
				y = y,
				z = z,
				nLifeTime = 1,
				speakOverFunc = function(speechNode)
					if(callbackFunc and type(callbackFunc) == "function")then
						callbackFunc();
					end
				end
			});
		end
	end
end
-- 除虫
function PlantViewPage_New.Debug()
	local self = PlantViewPage_New;
	if(self.CanDebug())then
		local msg = {
			nid = Map3DSystem.App.HomeLand.HomeLandGateway.GetNID(),
			id = self.bean.id,
		}
		commonlib.echo("begin to debug:");
		commonlib.echo(msg);
		paraworld.homeland.plantevolved.Debug(msg,"plantevolved",function(msg)
			commonlib.echo("after debug:");
			commonlib.echo(msg);	
			if(msg)then
				local bean =  commonlib.deepcopy(msg);
				self.anim_isplaying = true;
				self.DoAnimation(self.node,"debug",function()
					commonlib.echo("==============debug animation finished!");
					self.Update(bean);
					self.anim_isplaying = false;
					self.ClosePage();
					
					local msg = { aries_type = "OnDebugPlant"};
					msg.wndName = "main";
					msg.nid = Map3DSystem.App.HomeLand.HomeLandGateway.GetNID();
					CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
				
					local msg = { aries_type = "onDebugPlant_MPD"};
					msg.wndName = "main";
					msg.nid = Map3DSystem.App.HomeLand.HomeLandGateway.GetNID();
					CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);

				end)
				--local x,y,size,scaling,node_id = self.GetAnimParam(self.node)
				--self.anim_isplaying = true;
				--self.ClosePageWaitForAnimFinished();
				--self.PlayAnim_debug(x,y,size,scaling,node_id,function(name)
						--
						--self.PlayAnim_alpha(name,function(s)
							--self.Update(bean);
							--self.anim_isplaying = false;
							--self.ClosePage();
						--end)
				--end)
				--local msg = { aries_type = "OnDebugPlant"};
				--msg.wndName = "main";
				--msg.nid = Map3DSystem.App.HomeLand.HomeLandGateway.GetNID();
				--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
			end
		end);
	else
		_guihelper.MessageBox("现在不需要除虫！")
	end
end
--背包是否已经超过最大数量
function PlantViewPage_New.IsMaxNum(gsid)
	if(not gsid)then return end
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local equipGSItem = ItemManager.IfEquipGSItem;

	local count = 0;
	local bHas, guid = hasGSItem(gsid);
	if(bHas == true) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			count = item.copies;
		end
	end
	commonlib.echo("==============count");
	commonlib.echo(count);
	if(count >= 100)then
		return true
	end
end
--收获
function PlantViewPage_New.GainFruits()
	local self = PlantViewPage_New;
	if(self.CanGainFruits())then
		--get global item 
		local gsItem = self.canvas:GetGlobalItem(self.node.bean.id);
		local plant_descritor = "";
		local gsid = -1;
		---commonlib.echo("===========gsItem");
		---commonlib.echo(gsItem);
		if(gsItem and gsItem.template)then
			local template = gsItem.template
			plant_descritor = template.description or "";
			gsid = gsItem.gsid;
			--if(self.IsMaxNum(gsItem.gsid))then
				--local s = string.format("你拥有太多%s，背包放不下了，暂时不能收获。",plant_descritor);
				--_guihelper.MessageBox(s);
				--return
			--end
		end
		local place_str = "背包";
		if(gsid and gsid == 30134)then
			place_str = "投掷道具栏";
		end
		local canGetFruit = self.canvas:CanGetFruit(self.node.bean);
		if(not canGetFruit)then
			local s = string.format([[<div style="margin-left:20px;margin-top:20px;">你%s里的%s已经装得太满了，先把%s清理下再来收割吧！</div>]],place_str,plant_descritor,place_str);
			_guihelper.MessageBox(s);
			return
		end
		local msg = {
			ids = tostring(self.bean.id),
		}
		local plant_id = self.bean.id;
		local can_get_fruit = self.bean.feedscnt or 0;
		commonlib.echo("begin to gain fruits:");
		commonlib.echo(msg);
		paraworld.homeland.plantevolved.GainFruits(msg,"plantevolved",function(msg)	
			commonlib.echo("after gain fruits:");
			commonlib.echo(msg);
			if(msg and msg.issuccess)then
				local bean =  msg;
				local allowgaincnt = bean.allowgaincnt;
				commonlib.echo("=================allowgaincnt");
				commonlib.echo(allowgaincnt);
				--刷新bag
				Map3DSystem.Item.ItemManager.GetItemsInBag(12, "plantevolved"..(plant_id or 0), function(msg) 
					end, "access plus 0 day");
				Map3DSystem.Item.ItemManager.GetItemsInBag(72, "plantevolved"..(plant_id or 0), function(msg) 
					end, "access plus 0 day");
				--clone a node
				--local clonenode = self.node:CloneNoneID();
					
				if(not allowgaincnt or allowgaincnt == 0)then
					--铲除
					if(self.canvas)then
						self.anim_isplaying = true;
						self.DoAnimation(self.node,"hand",function()
							commonlib.echo("==============hand animation finished!");
							self.anim_isplaying = false;
							local linked_uid = self.node:GetSeedGridNodeUID();
							local linked_node = self.canvas.rootNode:GetChildByUID(linked_uid);
							if(linked_node and linked_node.SetGridInfo)then
								--取消链接
								linked_node:SetGridInfo(1,"");
							end
							self.node:Detach();
							self.ClosePage();
							local s = string.format("恭喜你收获了%d个<b style='font-size:14'>%s</b><br/>已经放入你的%s中了！",can_get_fruit,plant_descritor,place_str);
							_guihelper.MessageBox(s);
						end);
					end
						
					--commonlib.echo("begin to delete plant:");
					--commonlib.echo(plant_id);
					--Map3DSystem.Item.ItemManager.RemoveHomeLandPlant(plant_id, function(msg)
					--commonlib.echo("after delete plant:");
					--commonlib.echo(msg);
					--if(msg and msg.issuccess)then
						--
					--else
						--commonlib.echo({"delete plant faild",self.bean});
					--end
					--end)
				else
							self.anim_isplaying = true;
							self.DoAnimation(self.node,"hand",function()
								commonlib.echo("==============hand animation finished!");
								self.anim_isplaying = false;
								self.Update(bean);
								self.ClosePage();
								local s = string.format("恭喜你收获了%d个<b style='font-size:14'>%s</b><br/>已经放入你的%s中了！",can_get_fruit,plant_descritor,place_str);
								_guihelper.MessageBox(s);
							end)
								
							--local x,y,size,scaling,node_id = self.GetAnimParam(self.node,"hand")
							--self.anim_isplaying = true;
							--self.ClosePageWaitForAnimFinished();
							--self.PlayAnim_hand(x,y,size,scaling,node_id,function(name)
									--
									--self.PlayAnim_alpha(name,function(s)
										--self.Update(bean);
										--self.anim_isplaying = false;
										--self.ClosePage();
										--local s = string.format("恭喜你收获了%d个<b style='font-size:14'>%s</b><br/>已经放入你的背包中了！",can_get_fruit,plant_descritor);
										--_guihelper.MessageBox(s);
									--end)
							--end)
				end
				
			end
		end);
	else
		_guihelper.MessageBox("还不能收获！")
	end
end
----收获
--function PlantViewPage_New.GainFruits()
	--local self = PlantViewPage_New;
	--if(self.CanGainFruits())then
		----get global item 
		--local gsItem = self.canvas:GetGlobalItem(self.node.bean.id);
		--local plant_descritor = "";
		--if(gsItem and gsItem.template)then
			--local template = gsItem.template
			--plant_descritor = template.description or "";
			--if(self.IsMaxNum(gsItem.gsid))then
				--local s = string.format("你拥有太多%s，背包放不下了，暂时不能收获。",plant_descritor);
				--_guihelper.MessageBox(s);
				--return
			--end
		--end
		--local msg = {
			--sessionkey = Map3DSystem.User.sessionkey,
			--id = self.bean.id,
		--}
		--local plant_id = self.bean.id;
		--local can_get_fruit = self.bean.feedscnt or 0;
		--commonlib.echo("begin to gain fruits:");
		--commonlib.echo(msg);
		--paraworld.homeland.plantevolved.GainFruits(msg,"plantevolved",function(msg)	
			--commonlib.echo("after gain fruits:");
			--commonlib.echo(msg);
			--if(msg and msg.issuccess)then
				--local bean =  msg;
				--local allowgaincnt = bean.allowgaincnt;
				--commonlib.echo("=================allowgaincnt");
				--commonlib.echo(allowgaincnt);
				----刷新bag
				--NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
				--local bag = Map3DSystem.App.HomeLand.HomeLandConfig.Bag_Fruit or 12;
				--if(bag) then
					--Map3DSystem.Item.ItemManager.GetItemsInBag(bag, "plantevolved"..(plant_id or 0), function(msg) 
					--end, "access plus 0 day");
				--end
				----clone a node
				----local clonenode = self.node:CloneNoneID();
					--
				--if(not allowgaincnt or allowgaincnt == 0)then
					----铲除
					--commonlib.echo("begin to delete plant:");
					--commonlib.echo(plant_id);
					--Map3DSystem.Item.ItemManager.RemoveHomeLandPlant(plant_id, function(msg)
					--commonlib.echo("after delete plant:");
					--commonlib.echo(msg);
					--if(msg and msg.issuccess)then
						--if(self.canvas)then
							--self.anim_isplaying = true;
							--self.DoAnimation(self.node,"hand",function()
								--commonlib.echo("==============hand animation finished!");
								--self.anim_isplaying = false;
								--local linked_uid = self.node:GetSeedGridNodeUID();
								--local linked_node = self.canvas.rootNode:GetChildByUID(linked_uid);
								--if(linked_node and linked_node.SetGridInfo)then
									----取消链接
									--linked_node:SetGridInfo(1,"");
								--end
								--self.node:Detach();
								--self.ClosePage();
								--local s = string.format("恭喜你收获了%d个<b style='font-size:14'>%s</b><br/>已经放入你的背包中了！",can_get_fruit,plant_descritor);
								--_guihelper.MessageBox(s);
							--end);
						--end
					--else
						--commonlib.echo({"delete plant faild",self.bean});
					--end
				--end)
				--else
							--self.anim_isplaying = true;
							--self.DoAnimation(self.node,"hand",function()
								--commonlib.echo("==============hand animation finished!");
								--self.anim_isplaying = false;
								--self.Update(bean);
								--self.ClosePage();
								--local s = string.format("恭喜你收获了%d个<b style='font-size:14'>%s</b><br/>已经放入你的背包中了！",can_get_fruit,plant_descritor);
								--_guihelper.MessageBox(s);
							--end)
								--
							----local x,y,size,scaling,node_id = self.GetAnimParam(self.node,"hand")
							----self.anim_isplaying = true;
							----self.ClosePageWaitForAnimFinished();
							----self.PlayAnim_hand(x,y,size,scaling,node_id,function(name)
									----
									----self.PlayAnim_alpha(name,function(s)
										----self.Update(bean);
										----self.anim_isplaying = false;
										----self.ClosePage();
										----local s = string.format("恭喜你收获了%d个<b style='font-size:14'>%s</b><br/>已经放入你的背包中了！",can_get_fruit,plant_descritor);
										----_guihelper.MessageBox(s);
									----end)
							----end)
				--end
				--
			--end
		--end);
	--else
		--_guihelper.MessageBox("还不能收获！")
	--end
--end
--删除
function PlantViewPage_New.Delete()
	local self = PlantViewPage_New;
	if(not self.CanDelete())then return end
		--get global item 
		local gsItem = self.canvas:GetGlobalItem(self.node.bean.id);
		local plant_descritor = "";
		if(gsItem and gsItem.template)then
			local template = gsItem.template
			plant_descritor = template.description or "";
		end
	local s = string.format("你确定要铲除<b style='font-size:14'>%s</b>么？",plant_descritor);
	_guihelper.MessageBox(s, function(result) 
			if(_guihelper.DialogResult.Yes == result) then
				commonlib.echo("begin to delete plant:");
				commonlib.echo(tostring(self.bean.id));
				Map3DSystem.Item.ItemManager.RemoveHomeLandPlant(self.bean.id, function(msg)
					commonlib.echo("after delete plant:");
					commonlib.echo(msg);
					if(msg and msg.issuccess)then
							if(self.canvas)then
								self.anim_isplaying = true;
								self.DoAnimation(self.node,"delete",function()
									commonlib.echo("==============delete animation finished!");
									self.anim_isplaying = false;
									
									local linked_uid = self.node:GetSeedGridNodeUID();
									local linked_node = self.canvas.rootNode:GetChildByUID(linked_uid);
									if(linked_node and linked_node.SetGridInfo)then
										--取消链接
										linked_node:SetGridInfo(1,"");
									end
									self.node:Detach();
									self.ClosePage();
								end);
								--
								--local x,y,size,scaling,node_id = self.GetAnimParam(self.node)
								--self.anim_isplaying = true;
								--self.ClosePageWaitForAnimFinished();
								--self.PlayAnim_delete(x,y,size,scaling,node_id,function(name)
										--
										--self.PlayAnim_alpha(name,function(s)
											--self.anim_isplaying = false;
											--local linked_uid = self.node:GetSeedGridNodeUID();
											--local linked_node = self.canvas.rootNode:GetChildByUID(linked_uid);
											--if(linked_node and linked_node.SetGridInfo)then
												----取消链接
												--linked_node:SetGridInfo(1,"");
											--end
											--self.node:Detach();
											----self.canvas:RemoveChild(self.node);
											----Map3DSystem.App.HomeLand.HomeLandMouse.CheckPlantE(self.node);
											----Map3DSystem.App.HomeLand.HomeLandMouse.Clear();
											--self.ClosePage();
										--end)
								--end)

						
							end
					else
							commonlib.echo({"delete plant faild",self.bean});
					end
				end)
			elseif(_guihelper.DialogResult.No == result) then
				
			end
		end, _guihelper.MessageBoxButtons.YesNo);
end
--加速
function PlantViewPage_New.GOGOGO()
	local self = PlantViewPage_New;
	if(not self.bean)then return end
	local msg = {
			nid = Map3DSystem.App.HomeLand.HomeLandGateway.GetNID(),
			plantInstanceID = self.bean.id,
			h = 5,
		}
		commonlib.echo("begin to speed:");
		commonlib.echo(msg);
		paraworld.homeland.plantevolved.GoGoGo(msg,"plantevolved",function(msg)	
			commonlib.echo("after speed:");
			commonlib.echo(msg);
			if(msg and msg.issuccess)then
				local msg = {
						nid = Map3DSystem.App.HomeLand.HomeLandGateway.GetNID(),
						ids = tostring(self.bean.id),
					}
				commonlib.echo("begin to get plant info by speed:");
				commonlib.echo(msg);	
			paraworld.homeland.plantevolved.GetAllDescriptors(msg,"plantevolved",function(msg)	
				commonlib.echo("after get plant info by speed:");
				commonlib.echo(msg);	
								if(msg and msg.items)then
									local bean =  commonlib.deepcopy(msg.items[1]);
									self.Update(bean);
									self.ClosePageWaitForAnimFinished();
									self.ClosePage();
								end
							end);
			end
		end);
end

-- 更新成长的数据，不更新UI
function PlantViewPage_New.Update(bean)
	local self = PlantViewPage_New;
	if(not self.canvas or not self.node)then return end
	self.bean = bean;
	self.canvas:BindNode_PlantE(self.node,bean)
	self.UpdateUI();
end
function PlantViewPage_New.UpdateUI()
	
end
function PlantViewPage_New.ChangeState(combinedState)
	local self = PlantViewPage_New;
	if(not combinedState)then return end
	if(combinedState == "master_outside_true" or combinedState == "master_inside_true")then
		self.curState = "master_edit";
	elseif(combinedState == "master_outside_false" or combinedState == "master_inside_false")then
		self.curState = "master_view";
	elseif(combinedState == "guest_outside_false" or combinedState == "guest_inside_false")then
		self.curState = "guest_view";
	end		
end
function PlantViewPage_New.GetPlantName()
	local self = PlantViewPage_New;
	if(self.canvas and self.node)then
		local guid = self.node:GetGUID();
		local gsItem,item = self.canvas:GetGlobalItem(guid);
		if(gsItem and gsItem.template)then
			return gsItem.template.description;
		end
	end
end
function PlantViewPage_New.GetNextLevelTime()
	local self = PlantViewPage_New;
	if(self.bean)then
		return self.MinutesToFullTime(self.bean.updatetime);
	end
end
function PlantViewPage_New.GetGainTime()
	local self = PlantViewPage_New;
	if(self.bean)then
		return self.MinutesToFullTime(self.bean.gaintime);
	end
end
--分钟转化为 小时and分钟
function PlantViewPage_New.MinutesToFullTime(m)
	local self = PlantViewPage_New;
	m = tonumber(m);
	if(not m)then return end
	local hour = math.floor(m/60);
	local minu = m - hour * 60;
	return hour,minu;
end
