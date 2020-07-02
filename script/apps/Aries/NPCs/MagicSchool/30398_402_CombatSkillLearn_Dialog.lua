--[[
Title: 30398_402_CombatSkillLearn_Dialog
Author(s): Spring
Date: 2010/06/25
use the lib:
------------------------------------------------------------
script/apps/Aries/NPCs/MagicSchool/30398_402_CombatSkillLearn_Dialog.lua
------------------------------------------------------------
]]

-- create class
local libName = "CombatSkillLearn_Dialog";
local CombatSkillLearn_Dialog={};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.CombatSkillLearn_Dialog", CombatSkillLearn_Dialog);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function CombatSkillLearn_Dialog.main()
	local self = CombatSkillLearn_Dialog; 
end

function CombatSkillLearn_Dialog.PreDialog(npc_id, instance)
	local self = CombatSkillLearn_Dialog; 
	local NPC = MyCompany.Aries.Quest.NPC;
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(npc_id);
		
	memory.learned = 1;
	return true;			
end

function CombatSkillLearn_Dialog.LearnSkill(npc_id)
	local self = CombatSkillLearn_Dialog; 
	npc_id = tonumber(npc_id);
	if(npc_id)then
		self.ShowPage(npc_id);
	end
end

function CombatSkillLearn_Dialog.JuniorLearnSkill()
	commonlib.echo("==========================System.options.version:"..System.options.version)
	if(System.options.version=="teen") then
		local classID = MyCompany.Aries.Combat.GetSchoolGSID();
		local self = CombatSkillLearn_Dialog; 
		-- 各初级导师ID
		local JuniorTeacher={[986]=31005,[987]=31006,[988]=31007,[990]=31008,[991]=31009,};
		local classID = tonumber(classID)
		local teacherID = JuniorTeacher[classID];

		commonlib.echo("==========================teacherID:"..teacherID)
		if(teacherID)then
			self.ShowPage(teacherID);
		end	
	end	
end

function CombatSkillLearn_Dialog.ShowPage(npc_id)
	local self = CombatSkillLearn_Dialog; 
	if(System.options.version=="kids") then
		MyCompany.Aries.Pet.GetRemoteValue(nil,function(msg)
				System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/NPCs/MagicSchool/CombatSkillLearn_panel.kids.html?npc_id="..npc_id, 
				name = "CombatSkillLearn_Dialog.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 1,
				allowDrag = false,
				isTopLevel = true,
				directPosition = true,
					align = "_ct",
					x = -890/2,
					y = -510/2,
					width = 890,
					height = 510,
			});
		end)
	else
		MyCompany.Aries.Pet.GetRemoteValue(nil,function(msg)
				System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/NPCs/MagicSchool/CombatSkillLearn_panel.teen.html?npc_id="..npc_id, 
				name = "CombatSkillLearn_Dialog.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 1,
				allowDrag = true,
				isTopLevel = true,
				directPosition = true,
					align = "_ct",
					x = -700/2,
					y = -500/2,
					width = 700,
					height = 500,
			});
		end)
	end
end
