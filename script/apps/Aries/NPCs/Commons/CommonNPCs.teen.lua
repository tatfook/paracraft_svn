--[[
Title: CommonNPCs
Author(s): WangTian
Date: 2012/10/25

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Commons/CommonNPCs.teen.lua");
------------------------------------------------------------
]]

local CommonNPCs = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CommonNPCs");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");

local NPC_id_Bear = 543208;
local NPC_id_Anchor = 543209;

local bear_life_time = 10000;

function CommonNPCs.GetBearPosition()
	local x, y, z = ParaScene.GetPlayer():GetPosition();
	local radius = 5;
	local facing = ParaScene.GetPlayer():GetFacing();
	x = x + radius * math.sin(facing + 1.57-0.1);
	z = z + radius * math.cos(facing + 1.57-0.1);
	return x, y, z;
end

function CommonNPCs.ShowBear(callbackFunc,auto_show)
	local bear = NPC.GetNpcCharacterFromIDAndInstance(NPC_id_Bear);
	if(bear) then
		local dist = bear:DistanceTo(ParaScene.GetPlayer());
		if(dist < 10) then
			--bear:SetPosition(CommonNPCs.GetBearPosition());
			--bear:SetFacing(ParaScene.GetPlayer():GetFacing() + 3.14);
			headon_speech.Speek(bear.name, "嘿，我在这~~~", 6, true, nil, true);
			return;
		end
	end
	NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
	local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
	GathererBarPage.Start({duration = 1000,}, nil, function()
		CommonNPCs.auto_show = auto_show;
		CommonNPCs.callbackFunc = callbackFunc;
		CommonNPCs.ShowBear_immediate();
	end);
end

function CommonNPCs.ShowBear_immediate()
	NPC.DeleteNPCCharacter(NPC_id_Bear);
	local bear = NPC.GetNpcCharacterFromIDAndInstance(NPC_id_Bear);
	if(not bear) then
		local x, y, z = CommonNPCs.GetBearPosition()
		local params = {
			name = "巴巴多",
			position = {x, y + 1000, z},
			assetfile_char = "character/v6/01human/xiongguai/xiongguai.x",
			--assetfile_model = "character/v5/01human/Dragon/Dragon_physics.x",
			scaling = 3,
			facing = ParaScene.GetPlayer():GetFacing() + 3.14,
			main_script = "",
			main_function = "",
			talkdist = 4,
			predialog_function = "MyCompany.Aries.Quest.NPCs.CommonNPCs.Bear_PreDialog",
			EnablePhysics = false,
		};
		bear = NPC.CreateNPCCharacter(NPC_id_Bear, params);

		local x, y, z = CommonNPCs.GetBearPosition();
		CommonNPCs.PopEffect(x, y, z, function()
			local bear = NPC.GetNpcCharacterFromIDAndInstance(NPC_id_Bear);
			if(bear) then
				bear:SetPosition(CommonNPCs.GetBearPosition());
				headon_speech.Speek(bear.name, "巴巴多外卖熊，竭诚为您服务！", 6, true, nil, true);
				System.Animation.PlayAnimationFile({187}, bear);
				if(CommonNPCs.auto_show)then
					UIAnimManager.PlayCustomAnimation(800, function(elapsedTime)
						if(elapsedTime == 800) then
							CommonNPCs.Bear_PreDialog();
						end
					end);
				end
			end
		end);
	end


	if(not CommonNPCs.timer) then
		CommonNPCs.timer = commonlib.Timer:new({callbackFunc = function()
			if(ParaGlobal.GetGameTime() > (CommonNPCs.ShowBear_time + bear_life_time)) then
				-- stop and clear timer
				CommonNPCs.timer:Change();
				CommonNPCs.timer = nil;
				CommonNPCs.ShowBear_time = nil;
				-- destroy bear
				local bear = NPC.GetNpcCharacterFromIDAndInstance(NPC_id_Bear);
				if(bear and bear:IsValid()) then
					local x, y, z = bear:GetPosition();
					CommonNPCs.PopEffect(x, y, z, function()
						NPC.DeleteNPCCharacter(NPC_id_Bear);
					end);
				end
				CommonNPCs.auto_show = nil;
				CommonNPCs.callbackFunc = nil;
			end
		end});
		CommonNPCs.timer:Change(1000, 1000);
		CommonNPCs.ShowBear_time = ParaGlobal.GetGameTime();
	else
		CommonNPCs.ShowBear_time = ParaGlobal.GetGameTime();
	end
end

function CommonNPCs.Bear_PreDialog()
	if(CommonNPCs.callbackFunc)then
		CommonNPCs.callbackFunc();
	else
		CommonNPCs.ShowBearShop()
	end
	return false;
end

function CommonNPCs.ShowBearShop()
    NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopPage.lua");
    local NPCShopPage = commonlib.gettable("MyCompany.Aries.NPCShopPage");
    NPCShopPage.ShowPage(-1);
end

function CommonNPCs.PopEffect(x, y, z, callback)
	local anchor = NPC.GetNpcCharacterFromIDAndInstance(NPC_id_Anchor);
	if(not anchor) then
		local params = {
			name = "",
			position = {x, y, z},
			assetfile_char = "character/common/dummy/cube_size/cube_size.x",
			--assetfile_model = "character/v5/01human/Dragon/Dragon_physics.x",
			scaling = 0.0000001,
			facing = 0,
			main_script = "",
			main_function = "",
			talkdist = 4,
			predialog_function = "MyCompany.Aries.Quest.NPCs.CommonNPCs.Bear_PreDialog",
			EnablePhysics = false,
		};
		anchor = NPC.CreateNPCCharacter(NPC_id_Anchor, params);
		anchor:SetVisible(false);
	else
		anchor:SetPosition(x, y, z);
	end
	NPL.load("(gl)script/apps/Aries/Combat/SpellCast.lua");
	local SpellCast = commonlib.gettable("MyCompany.Aries.Combat.SpellCast");
	local spell_file = "config/Aries/Spells/Action_BearShop_teen.xml";
	local current_playing_id = ParaGlobal.GenerateUniqueID();
	SpellCast.EntitySpellCast(0, anchor, 1, anchor, 1, spell_file, nil, nil, nil, nil, nil, function()
	end, nil, true, current_playing_id, true);
	
	
	UIAnimManager.PlayCustomAnimation(800, function(elapsedTime)
		if(elapsedTime == 800) then
			if(callback) then
				callback();
			end
		end
	end);
end