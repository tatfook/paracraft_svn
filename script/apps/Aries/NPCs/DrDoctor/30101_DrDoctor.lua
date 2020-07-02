--[[
Title: DrDoctor
Author(s): WangTian
Date: 2009/8/1

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30101_DrDoctor.lua
------------------------------------------------------------
]]

-- create class
local libName = "DrDoctor";
local DrDoctor = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.DrDoctor", DrDoctor);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- DrDoctor.main
function DrDoctor.main()
end

-- DrDoctor.On_Timer
function DrDoctor.On_Timer()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30101);
	if(memory.startcounttime) then
		if((ParaGlobal.GetGameTime() - memory.startcounttime) > 30000) then
			memory.startcounttime = nil;
		end
	end
end

-- say level5 quest speech
-- @return: true if the doctor hasn't speak out the the final word
--			false if continue with the next dialog answer condition
function DrDoctor.PreDialog()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	--if(not hasGSItem(50025) or ((hasGSItem(50025) and hasGSItem(50026)))) then
		--return true;
	--end
	
	if(hasGSItem(50025) and not hasGSItem(50026)) then
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30101);
		if(memory) then
			if(memory.donespeek == true) then
				-- already in dialog, refresh the dialog
				-- NOTE: memory.donespeek will be set to false on leaving the dialog
				return true;
			end
			
			if(memory.startcounttime == nil) then
				-- init the speak memory
				-- AI code will handle the memory.startcounttime counting, if it reach 30 seconds it will be nil
				memory.startcounttime = ParaGlobal.GetGameTime();
				memory.speakcount = 0;
			end
			memory.speakcount = memory.speakcount + 1;
			local NPC = MyCompany.Aries.Quest.NPC;
			local drDoctor = NPC.GetNpcCharacterFromIDAndInstance(30101);
			local BOLD = headon_speech.GetBoldTextMCML;
			if(drDoctor and drDoctor:IsValid() == true) then
				if(memory.speakcount == 1) then
					return true;
				elseif(memory.speakcount == 2) then
					return true;
				elseif(memory.speakcount == 3) then
					return true;
				elseif(memory.speakcount == 4) then
					return true;
				elseif(memory.speakcount >= 5) then
					memory.startcounttime = nil;
					memory.speakcount = 0;
					memory.donespeek = true;
					return true;
				end
			end
		end
	elseif(hasGSItem(50215) and not hasGSItem(50216)) then
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30101);
		if(memory) then
			if(memory.donespeek == true) then
				-- already in dialog, refresh the dialog
				-- NOTE: memory.donespeek will be set to false on leaving the dialog
				return true;
			end
			
			if(memory.startcounttime == nil) then
				-- init the speak memory
				-- AI code will handle the memory.startcounttime counting, if it reach 30 seconds it will be nil
				memory.startcounttime = ParaGlobal.GetGameTime();
				memory.speakcount = 10;
			end
			memory.speakcount = memory.speakcount + 1;
			local NPC = MyCompany.Aries.Quest.NPC;
			local drDoctor = NPC.GetNpcCharacterFromIDAndInstance(30101);
			local BOLD = headon_speech.GetBoldTextMCML;
			if(drDoctor and drDoctor:IsValid() == true) then
				if(memory.speakcount == 11) then
					return true;
				elseif(memory.speakcount == 12) then
					return true;
				elseif(memory.speakcount == 13) then
					return true;
				elseif(memory.speakcount >= 14) then
					memory.startcounttime = nil;
					memory.speakcount = 10;
					memory.donespeek = true;
					return true;
				end
			end
		end
	end
	
	return true;
end
--神秘箱子
function DrDoctor.CanShow()
	if(hasGSItem(50025) and not hasGSItem(50026)) then
		return true;
	end
end
--飞飞
function DrDoctor.CanShow_FleaChick()
	if(hasGSItem(50215) and not hasGSItem(50216)) then
		return true;
	end
end
function DrDoctor.CanShow_BunnyQuest()
    NPL.load("(gl)script/apps/Aries/NPCs/DrDoctor/30376_CrystalBunny.lua");
	return MyCompany.Aries.Quest.NPCs.CrystalBunny.IsOpened()
end

function DrDoctor.GetMiniAuraDefenceCardGloves()
	-- 826 Exchange_5_MiniAuraDefenceCard_Gloves 
	-- 1766_PowerfulGloves
	if(hasGSItem(1766)) then
		_guihelper.MessageBox("你已经领取强力防御手套了");
		return;
	end
	_guihelper.MessageBox("想要领取强力防御手套么? 交1000奇豆吧 哈哈~~~~", function(res)
		if(res and res == _guihelper.DialogResult.Yes) then
			ItemManager.ExtendedCost(826, nil, nil, function(msg)
				log("+++++++ 826 Exchange_5_MiniAuraDefenceCard_Gloves return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == false and msg.errorcode == 427) then
					_guihelper.MessageBox("连1000奇豆都没有就来领强力防御手套, 坑爹啊~~~")
				end
			end);
		end
	end, _guihelper.MessageBoxButtons.YesNo);
end