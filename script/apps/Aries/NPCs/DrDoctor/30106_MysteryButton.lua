--[[
Title: MysteryButton
Author(s): Leio
Date: 2009/11/30

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/DrDoctor/30106_MysteryButton.lua
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");

-- create class
local libName = "MysteryButton";
local MysteryButton = {
	duration = 5000,--毫秒
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.MysteryButton", MysteryButton);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- MysteryButton.main
function MysteryButton.main()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30106);
	commonlib.echo("==================MysteryButton.main");
	commonlib.echo(memory);
	if(memory)then
		--如果有物体，确保它存在
		if(memory.generate_item == "stone")then
			commonlib.echo("==================MysteryButton Rebuild stone");
			GameObject.DeleteGameObjectCharacter(301061);
			MysteryButton.CreateStone();
		elseif(memory.generate_item == "bean")then
			commonlib.echo("==================MysteryButton Rebuild bean");
			GameObject.DeleteGameObjectCharacter(301062);
			MysteryButton.CreateBean();
		end
	end
end
--hook奇豆/晶晶石 是否已经被捡取
function MysteryButton.HookHandler(nCode, appName, msg, value)
	if(msg.aries_type == "OnGameObjectPick")then
			
		if(msg.gameobj_id == 301061 or msg.gameobj_id == 301062)then
			local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30106);
			commonlib.echo(memory);
			if(memory)then
				memory.generate_item = nil;
			end
		end
	end
	return nCode;
end
function MysteryButton.PreDialog()
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = MysteryButton.HookHandler, 
		hookName = "MysteryButton.main", appName = "Aries", wndName = "main"});
			
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30106);
	--[[
		memory = {
			isEnabled = false,--任务是否已经开启（5分钟内任务有效）
			timer = nil,
			total_millisecond = 0,--任务持续的时间
			generate_item = nil,nil or stone or bean
			state = 0, -- 0 不可点击 1：电击 2：产生晶晶石 3：产生奇豆
		}
	--]]
	if(memory) then
		if(not memory.timer)then
			memory.timer = commonlib.Timer:new({callbackFunc = function(timer)
				MysteryButton.UpdateTimer();
			end})
		end	
		memory.timer:Change(0,MysteryButton.duration);
		
		--如果已经起效
		if(memory.isEnabled)then
			memory.state = 0;
			return
		end
			
		memory.isEnabled = true;
		local r = math.random(0,100);
		--电击
		if( r >= 0 and r < 40)then
			memory.state = 1;
			MysteryButton.DoLightning();
			--return false;
		--晶晶石
		elseif( r >= 40 and r <70 )then
			memory.state = 2;
			memory.generate_item = "stone";
			MysteryButton.CreateStone();
		--奇豆
		elseif( r >= 70)then
			memory.state = 3;
			memory.generate_item = "bean";
			MysteryButton.CreateBean()
		end
	end
end
function MysteryButton.UpdateTimer()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30106);
	if(memory)then
		if(not memory.total_millisecond)then
			memory.total_millisecond = MysteryButton.duration;
		else
			memory.total_millisecond = memory.total_millisecond + MysteryButton.duration;
		end
		commonlib.echo("==================MysteryButton.UpdateTimer");
		commonlib.echo(memory.total_millisecond);
		--如果超过2分钟
		if(memory.total_millisecond >= 120000)then
			--消失产生的物品
			if(memory.generate_item)then
				--销毁物品
				commonlib.echo("==================MysteryButton destroy");
				commonlib.echo(memory.generate_item);
				if(memory.generate_item == "stone")then
					GameObject.DeleteGameObjectCharacter(301061);
				else
					GameObject.DeleteGameObjectCharacter(301062);
				end
				memory.generate_item = nil;
			end
		end
		--如果超过5分钟
		if(memory.total_millisecond >= 300000)then
			memory.isEnabled = false;
			memory.total_millisecond = 0;
			commonlib.echo("==================MysteryButton finished");
			if(memory.timer)then
				memory.timer:Change();
			end	
		end
	end
end
--取消电击
function MysteryButton.DoClearLightning(from, to)
	if(from == 2 and to == -1)then
		local player = ParaScene.GetPlayer();
		local animation_file = "";
		if(player and player:IsValid() and animation_file)then
			Map3DSystem.Animation.PlayAnimationFile(animation_file, player);
		end
	end
end
--电击
function MysteryButton.DoLightning()
	local player = ParaScene.GetPlayer();
	local animation_file = "character/Animation/v5/ElfFemale_Electricshock.x";
	if(player and player:IsValid() and animation_file)then
		Map3DSystem.Animation.PlayAnimationFile(animation_file, player);
	end
end
--产生晶晶石
function MysteryButton.CreateStone()
	local pickcount = 1;
	local x,y,z = 19935,10009.5,20109;
	local assetfile = "model/06props/v5/03quest/CrystalRock/CrystalRock.x";
	local gsid = 17029;
	local name = "晶晶石";
	local params = {
		name = name,
		gsid = gsid,
		position = { x,y,z },
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",
		assetfile_model = assetfile,
		facing = 0,
		scaling = 1.0,
		pickdist = 12,
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		isalwaysshowheadontext = false,
		pick_count = pickcount,
	};
	local acinus = GameObject.CreateGameObjectCharacter(301061, params);
end
--产生奇豆
function MysteryButton.CreateBean()
	local pickcount = 50;
	local r = math.random(0,100);
	if(r <= 50)then
		pickcount = 50;
	elseif(r > 50 and r <= 80)then
		pickcount = 100;
	elseif(r > 80 and r <= 95)then
		pickcount = 200;
	else
		pickcount = 300;
	end
	local x,y,z = 19935,10009.5,20109;
	local assetfile = "model/06props/v5/JoyBean/JoyBean.x";
	local gsid = 0;
	local name = "奇豆";
	local params = {
		name = name,
		gsid = gsid,
		position = { x,y,z },
		assetfile_char = assetfile,
		facing = 0,
		scaling = 1,
		pickdist = 12,
		gameobj_type = "FreeItem",
		isdeleteafterpick = true,
		isalwaysshowheadontext = false,
		pick_count = pickcount,
	};
	local acinus = GameObject.CreateGameObjectCharacter(301062, params);
end