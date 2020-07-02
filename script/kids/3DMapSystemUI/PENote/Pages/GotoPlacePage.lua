--[[
Title: 
Author(s): Leio
Date: 2009/10/10
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/GotoPlacePage.lua");
local msg = {
	to_label = "a",
	from_label = "b",
	content = "hello",
	date = "2009/10/10",
	goto = {20169.15234375, 3.499169588089, 19712.33984375}, 
	camera = {8.2850255966187, 0.20502437651157, -2.6657900810242},
}
Map3DSystem.App.PENote.GotoPlacePage.Bind(msg)
Map3DSystem.App.PENote.GotoPlacePage.ShowPage();
-------------------------------------------------------
]]
-- default member attributes
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
local GotoPlacePage = {
	page = nil,
	goto_type = nil,-- 跳转类型 "catch_pet"
	fromname = nil,
	toname = nil,
	content = nil,
}
commonlib.setfield("Map3DSystem.App.PENote.GotoPlacePage",GotoPlacePage);

function GotoPlacePage.OnInit()
	local self = GotoPlacePage;
	self.page = document:GetPageCtrl();
end
function GotoPlacePage.ShowPage()
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/PENote/Pages/GotoPlacePage.html", 
			name = "GotoPlacePage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			--app_key=MyCompany.Taurus.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -509,
				y = -340,
				width = 1018,
				height = 681,
		});
end
function GotoPlacePage.ClosePage()
	local self = GotoPlacePage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="GotoPlacePage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
	self.Clear();
	--只要关闭页面，就认为阅读成功
	self.GetTag();
end
function GotoPlacePage.Bind(msg)
	local self = GotoPlacePage;
	self.fromname = msg.from_label;
	self.toname = msg.to_label;
	self.content = msg.content;
	self.date = msg.date;
	self.goto = msg.goto;
	self.camera = msg.camera;
	self.goto_type = msg.goto_type;
end
function GotoPlacePage.Goto()
	local self = GotoPlacePage;
	if(self.goto)then
		if(self.camera)then
			self.OnGoto()
		else
			local x,y,z = self.goto[1],self.goto[2],self.goto[3];
			if(not x or not y or not z)then
				x,y,z = self.goto.x,self.goto.y,self.goto.z;
			end
			self.OnGotoByXYZ(x,y,z);
		end
		self.ClosePage();
	end
end
function GotoPlacePage.GetTag()
	local self = GotoPlacePage;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local equipGSItem = ItemManager.IfEquipGSItem;
	if(not self.goto_type)then
		if(not hasGSItem(50264)) then
			-- 50264_HasPostedArchiSkillMail
			ItemManager.PurchaseItem(50264, 1, function(msg) end, function(msg)
				if(msg) then
					log("+++++++Purchase 50264_HasPostedArchiSkillMail return: +++++++\n")
					commonlib.echo(msg);
				end
			end);
		end
	elseif(self.goto_type == "catch_pet")then
		local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
		local key = string.format("GotoPlacePage.Tag.%s",today);
		--MyCompany.Aries.Player.SaveLocalData(key, "true")
	end
end
function GotoPlacePage.Clear()
	local self = GotoPlacePage;
	self.page = nil;
	self.fromname = nil;
	self.toname = nil;
	self.content = nil;
	self.date = nil;
	self.goto = nil;
	self.camera= nil;
end
function GotoPlacePage.OnGoto()
	local self = GotoPlacePage;
	 local position = self.goto;
    local camera = self.camera;
    if(not position or not camera)then return end
    local msg = { aries_type = "OnMapTeleport", 
		    position = position, 
		    camera = camera, 
		    wndName = "map", 
	    };
    CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
end
function GotoPlacePage.OnGotoByXYZ(x,y,z)
	if(not x or not y or not z)then return end
	local self = GotoPlacePage;
    local HomeLandGateway = Map3DSystem.App.HomeLand.HomeLandGateway;
    if(HomeLandGateway.IsInHomeland()) then
        -- leave the homeland and teleport to dongdong
        HomeLandGateway.SetTeleportBackPosition(x, y, z);
        HomeLandGateway.Away();
    else
        -- directly teleport to dongdong
		local params = {
			asset_file = "character/v5/temp/Effect/LoyaltyDown_Impact_Base.x",
			binding_obj_name = ParaScene.GetPlayer().name,
			start_position = nil,
			duration_time = 800,
			force_name = nil,
			begin_callback = function() 
					local player = ParaScene.GetPlayer();
					if(player and player:IsValid() == true) then
						player:ToCharacter():Stop();
					end
				end,
			end_callback = nil,
			stage1_time = 600,
			stage1_callback = function()
					local player = ParaScene.GetPlayer();
					if(player and player:IsValid() == true) then
						player:SetPosition(x,y,z);
					end
				end,
			stage2_time = nil,
			stage2_callback = nil,
		};
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
    end
end
