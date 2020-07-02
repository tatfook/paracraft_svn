--[[
Title: WishingLamp
Author(s): WangTian
Date: 2009/7/30

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30337_WishingLamp.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30337_WishingLamp_panel.lua");
-- create class
local libName = "WishingLamp";
local WishingLamp = {
	selected_instance = nil,
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishingLamp", WishingLamp);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishingLamp.main
function WishingLamp.main()
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50247);
	local hasItem,guid,bag,copies = hasGSItem(50247);
	copies = copies or 0
	commonlib.echo("gsObtain");
	commonlib.echo(gsObtain);
	commonlib.echo(copies);
	
	if(guid and copies == 1 and gsObtain and gsObtain.inday == 0)then
		--销毁昨天的心愿记录
		ItemManager.DestroyItem(guid,1,function(msg) end,function(msg)
			commonlib.echo("=====destroy 50247_WishLampTag in WishingLamp.main");
			commonlib.echo(msg);
		end)
	end
	-- hook into OnThrowableHit
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnThrowableHit") then
				if(msg.msg.nid == System.App.profiles.ProfileManager.GetNID()) then
					local msg = msg.msg;
					
					if(msg.throwItem.gsid == 9503) then
						local k;
						for k = 1, 10 do
							local lamp = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30337,k);
							if(lamp) then
								if(msg.attackedName == lamp.name) then
									--激活心愿
									WishingLamp.DoActive(k);
									return;
								end
							end
						end
						
					end
				end
			end
		end, 
	hookName = "OnThrowableHit_30337_WishingLamp", appName = "Aries", wndName = "throw"});
end

-- WishingLamp.PreDialog
function WishingLamp.PreDialog()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30337);
	if(MyCompany.Aries.Quest.NPCs.WishingLamp.HasActived()) then
		memory.dialog_state = 1;
	elseif(MyCompany.Aries.Quest.NPCs.WishingLamp.HasWished()) then
		memory.dialog_state = 2;
	else
		memory.dialog_state = 3;
	end
end
--是否已经激活
function WishingLamp.HasActived()
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50247);
	local hasItem,guid,bag,copies = hasGSItem(50247);
	copies = copies or 0
	if(copies == 0 and gsObtain and gsObtain.inday > 0)then
		return true;
	end
	return false;
end
--是否已经许愿
function WishingLamp.HasWished()
	--如果今天已经激活，就不能在许愿
	if(WishingLamp.HasActived())then
		return true;
	end
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50247);
	local hasItem,guid,bag,copies = hasGSItem(50247);
	copies = copies or 0;
	if(copies == 1 and gsObtain and gsObtain.inday > 0)then
		return true;
	end
	return false;
end
--显示许愿的面板
function WishingLamp.ShowWishedPanel()
	WishingLamp.DoWished();
end
--许愿
function WishingLamp.DoWished()
	commonlib.echo("=========before Purchase item #50247_WishLampTag");
	commonlib.echo(WishingLamp.HasWished());
	
	if(WishingLamp.HasWished())then return end
	
	MyCompany.Aries.Quest.NPCs.WishingLamp_panel.ShowPage();
	MyCompany.Aries.Quest.NPCs.WishingLamp_panel.wishedCallbackFunc = function()
		ItemManager.PurchaseItem(50247, 1, function(msg) end, function(msg) 
			log("+++++++Purchase item #50247_WishLampTag return: +++++++\n")
			commonlib.echo(msg);
			--_guihelper.MessageBox("许愿成功！");
			-- close the npc dialog MCML page
			-- unselect the npc to hide the dialog MCML page
			--System.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj = ParaScene.GetPlayer()});
			--System.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject});
			-- show the dialog MCML page
			
			UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
				if(elapsedTime == 500) then
					MyCompany.Aries.Desktop.TargetArea.TalkToNPC(30337, MyCompany.Aries.Quest.NPCs.WishingLamp.selected_instance or 1, false);
				end
			end);
		end);
	end
	
end
--激活心愿
-- @param instance: npc instance id
function WishingLamp.DoActive(instance)
	if(WishingLamp.HasActived())then return end	
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50247);
	local hasItem,guid,bag,copies = hasGSItem(50247);
	if(guid and WishingLamp.HasWished())then
		--激活今天的心愿
		ItemManager.DestroyItem(guid,1,function(msg) end,function(msg)
			commonlib.echo("=====destroy 50247_WishLampTag in WishingLamp.DoActive");
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				--_guihelper.MessageBox("激活心愿成功！");
				-- text reminder
				local Scene = MyCompany.Aries.Scene;
				Scene.ShowRegionLabel("许愿灯带着你的愿望越飞越高了…", "240 226 43");
				-- fly the lamp
				WishingLamp.FlyLamp(instance);
				-- call hook for OnFlyWishingLamp
				local hook_msg = { aries_type = "OnFlyWishingLamp", wndName = "main"};
				CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
			end
		end);
	end
end

-- fly the lamp into the sky
-- @param instance: npc instance id
function WishingLamp.FlyLamp(instance)
	
	local lamp_model = NPC.GetNpcModelFromIDAndInstance(30337, instance);
	if(lamp_model) then
		
		-- NOTE: some lazy effect that frame rate greatly effect the lamp trace
		local x, y, z = lamp_model:GetPosition();
		local velocity_x = 0.01;
		local velocity_y = 0.01;
		local velocity_z = 0.01;
		-- play the fly away effect
		local params = {
			asset_file = "model/06props/v5/03quest/WishLight/WishLight_fire.x",
			ismodel = true,
			--binding_obj_name = lazypanda.name,
			start_position = {x, y, z},
			duration_time = 10000,
			force_name = nil,
			scale = 1,
			elapsedtime_callback = function(elapsedTime, obj)
				-- direct flying
				local last_x, last_y, last_z = obj:GetPosition();
				-- random ractor in x and z coordinates
				velocity_x = velocity_x + math.random(-10, 10) * 0.001;
				velocity_z = velocity_z + math.random(-10, 10) * 0.001;
				obj:SetPosition(last_x + 0.1 * velocity_x, last_y + 0.1 * (velocity_y + (elapsedTime * 0.001)), last_z + 0.1 * velocity_z);
			end,
			begin_callback = function() 
			end,
			end_callback = function() 
			end,
		};
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
		
		-- delete the lamp instance
		NPC.DeleteNPCCharacter(30337, instance);
	end
end