--[[
Title: code behind for page EnergyPool.html
Author(s): Leio
Date: 2010/08/02
Desc:  script/kids/3DMapSystemUI/HomeLand/Pages/EnergyPool.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/EnergyPool.lua");
MyCompany.Aries.Inventory.EnergyPoolPage.ShowPage();
-------------------------------------------------------
]]
local EnergyPoolPage = {
};
commonlib.setfield("MyCompany.Aries.Inventory.EnergyPoolPage", EnergyPoolPage);
local EffectManager = commonlib.gettable("MyCompany.Aries.EffectManager");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
function EnergyPoolPage.ShowPage()
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
	local pos = Map3DSystem.App.HomeLand.HomeLandConfig.Panel_ShowPos;
	local self = NormalViewPage;	
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/HomeLand/Pages/EnergyPool.html", 
			name = "EnergyPoolPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			directPosition = true,
				align = pos.align,
				x = pos.left,
				y = pos.top,
				width = pos.width,
				height = pos.height,
		});
end
function EnergyPoolPage.ClosePage()
	local self = EnergyPoolPage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="EnergyPoolPage.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,bDestroy = true,});
		
	--在关闭面板的时候，清空选中的物体
	if(self.canvas and self.canvas.nodeProcessor)then
		self.canvas.nodeProcessor.selectedNode = nil;
	end
	
	self.canvas = nil;
	self.node = nil;
	self.curState = nil;
end
function EnergyPoolPage.Init(canvas,node,combinedState)
	local self = EnergyPoolPage;
	self.canvas = canvas;
	self.node = node;
	self.ChangeState(combinedState);
end
function EnergyPoolPage.DoAction()
	local self = EnergyPoolPage;
	if(self.canvas and self.node)then
		NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
		if(MsgHandler) then
			local curHP = MsgHandler.GetCurrentHP()
			local MaxHP = MsgHandler.GetMaxHP()
			local half_hp = MaxHP/2;
			--最多加大一半的血
			if(curHP < half_hp) then
				local need_hp = half_hp - curHP;
				MsgHandler.HealByWisp(need_hp);
				local player = ParaScene.GetPlayer();
				local px, py, pz = player:GetPosition();
				local params = {
					asset_file = "character/v5/09effect/Wisp/Wisp_hit.x",
					binding_obj_name = wisp_name,
					start_position = {px, py, pz},
					duration_time = 500,
					force_name = nil,
					begin_callback = function() end,
					end_callback = nil,
					stage1_time = nil,
					stage1_callback = nil,
					stage2_time = nil,
					stage2_callback = nil,
				};
				EffectManager.CreateEffect(params);
			else
				_guihelper.MessageBox([[<div style="text-align:center;margin-top:20px;">能量池最多只能恢复你50%的血量！</div>]]);
			end
		end
		self.ClosePage();
	end
end
function EnergyPoolPage.ChangeState(combinedState)
	local self = EnergyPoolPage;
	if(not combinedState)then return end
	if(combinedState == "master_outside_true" or combinedState == "master_inside_true")then
		self.curState = "master_edit";
	elseif(combinedState == "master_outside_false" or combinedState == "master_inside_false")then
		self.curState = "master_view";
	elseif(combinedState == "guest_outside_false" or combinedState == "guest_inside_false")then
		self.curState = "guest_view";
	end		
end