--[[
Title: MysteryAcinusTree
Author(s): WangTian
Date: 2009/7/21

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Police/30004_MysteryAcinusTree.lua
------------------------------------------------------------
]]

-- create class
local libName = "MysteryAcinusTree";
local MysteryAcinusTree = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.MysteryAcinusTree", MysteryAcinusTree);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local prefereditem_avaiable = {
	{gsid = 9501,
	 name = "水球"},
	{gsid = 9502,
	 name = "果冻"},
	{gsid = 9503,
	 name = "炮竹"},
};
-- init the MysteryAcinusTree if the state is 0
function MysteryAcinusTree.InitIfStateZero()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30004);
    if(memory.state == 0) then
	    memory.state = 1;
	    memory.throweditem = nil;
	    -- choose one prefered item by random
	    local ran = math.random(0, 300);
	    if(ran <= 100) then
		    memory.prefereditem_gsid = prefereditem_avaiable[1].gsid;
	    elseif(ran <= 200) then
		    memory.prefereditem_gsid = prefereditem_avaiable[2].gsid;
	    elseif(ran <= 300) then
		    memory.prefereditem_gsid = prefereditem_avaiable[3].gsid;
	    end
	    
		-- hook into OnThrowableHit
		CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
			callback = function(nCode, appName, msg, value)
				if(msg.aries_type == "OnThrowableHit") then
					if(msg.msg.nid == System.App.profiles.ProfileManager.GetNID()) then
						local msg = msg.msg;
						local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30004);
						if(msg.throwItem.gsid == 9501 and msg.endPoint) then
							memory.throweditem = 9501;
							memory.hitposition_x = msg.endPoint.x;
							memory.hitposition_y = msg.endPoint.y;
							memory.hitposition_z = msg.endPoint.z;
						elseif(msg.throwItem.gsid == 9502 and msg.endPoint) then
							memory.throweditem = 9502;
							memory.hitposition_x = msg.endPoint.x;
							memory.hitposition_y = msg.endPoint.y;
							memory.hitposition_z = msg.endPoint.z;
						elseif(msg.throwItem.gsid == 9503 and msg.endPoint) then
							memory.throweditem = 9503;
							memory.hitposition_x = msg.endPoint.x;
							memory.hitposition_y = msg.endPoint.y;
							memory.hitposition_z = msg.endPoint.z;
						end
					end
				end
			end, 
		hookName = "OnThrowableHit_30004_MysteryAcinusTree", appName = "Aries", wndName = "throw"});
	end
end

-- MysteryAcinusTree become healthy
-- it will grow a random colot acinus and play open idle animation after open animation
function MysteryAcinusTree.BecomeHealthy(pretext)

	local mysteryAcinusTree = NPC.GetNpcCharacterFromIDAndInstance(30004);
	if(mysteryAcinusTree and mysteryAcinusTree:IsValid() == true) then
		local acinus = GameObject.GetGameObjectCharacterFromIDAndInstance(30004);
		if(acinus and acinus:IsValid() == true) then
			log("acinus is valid when trying to grow acinus\n");
			return;
		end
		mysteryAcinusTree:ToCharacter():PlayAnimation(60);
		local _notification = ParaUI.GetUIObject("NotificationArea");
		if(_notification:IsValid() == true) then
			local _magazine = _notification:GetChild("Magazine");
			local block = UIDirectAnimBlock:new();
			block:SetUIObject(_magazine);
			block:SetCallback(function ()
				mysteryAcinusTree:ToCharacter():PlayAnimation(70);
			end);
			block:SetTime(1000);
			UIAnimManager.PlayDirectUIAnimation(block);
		end
		
		-- pick a random acinus from 21001 ~ 21004
		local ran = math.random(0, 400);
		local gsid = 21001;
		if(ran <= 100) then
			gsid = 21001;
		elseif(ran <= 200) then
			gsid = 21002;
		elseif(ran <= 300) then
			gsid = 21003;
		elseif(ran <= 400) then
			gsid = 21004;
		end
		
		local pickcount = 1;
		local name = "红色浆果";
		local assetfile = "character/v5/06quest/MysteryAcinusFruit/RedAcinus/RedAcinus.x"
		local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem) then
			name = gsItem.template.name;
			assetfile = gsItem.assetfile;
		end
		
		local ItemManager = System.Item.ItemManager;
		local hasGSItem = ItemManager.IfOwnGSItem;
		if(hasGSItem(gsid)) then
			gsid = 0;
			pickcount = 10;
			local BOLD = headon_speech.GetBoldTextMCML;
			headon_speech.Speek(mysteryAcinusTree.name, BOLD(pretext.."，你真是一个好心的小哈奇，我的奇豆送给你吧！"), 3, true);
		else
			local BOLD = headon_speech.GetBoldTextMCML;
			headon_speech.Speek(mysteryAcinusTree.name, BOLD(pretext.."，你真是一个好心的小哈奇，我的果子送给你吧！"), 3, true);
		end
		
		local params = {
			name = name,
			gsid = gsid,
			position = { mysteryAcinusTree:GetPosition() },
			assetfile_char = assetfile,
			facing = 2,
			scaling = 2.0,
			pickdist = 12,
			gameobj_type = "FreeItem",
			isdeleteafterpick = true,
			isalwaysshowheadontext = false,
			pick_count = pickcount,
		};
		local acinus = GameObject.CreateGameObjectCharacter(300041, params);
		if(acinus and acinus:IsValid() == true) then
			System.MountPlayerOnChar(acinus, mysteryAcinusTree, false);
		end
	end
end

-- MysteryAcinusTree become sick
-- it will remove any acinus if possible and play close animation
function MysteryAcinusTree.BecomeSick()
	local mysteryAcinusTree = NPC.GetNpcCharacterFromIDAndInstance(30004);
	if(mysteryAcinusTree and mysteryAcinusTree:IsValid() == true) then
		local acinus = GameObject.DeleteGameObjectCharacter(300041);
		mysteryAcinusTree:ToCharacter():PlayAnimation(50);
	end
end