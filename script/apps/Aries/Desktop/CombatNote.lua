--[[
Title: 
Author(s): Leio
Date: 2011/01/27
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/CombatNote.lua");
local CombatNote = commonlib.gettable("MyCompany.Aries.Desktop.CombatNote");
commonlib.echo(CombatNote.mobs);
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");

local CombatNote = commonlib.gettable("MyCompany.Aries.Desktop.CombatNote");

CombatNote.mobs = QuestHelp.GetHeroDragonData();
CombatNote.cur_level_mobs = {};
function CombatNote.ShowPage()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	local params = {
		url = "script/apps/Aries/Desktop/CombatNote.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "CombatNote.ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -600/2,
            y = -420/2,
            width = 600,
            height =450,
    };
    System.App.Commands.Call("File.MCMLWindowFrame",  params);
end
--@param mobLevel_1:怪的开始等级
--@param mobLevel_2:怪的结束等级
--@param mobTypeNum:怪种类的数量
--@param n1 n2 n3 :对应每种怪的数量
function CombatNote.FindMobHelpFunc(mobLevel_1,mobLevel_2,mobTypeNum,n1,n2,n3,excludeBoos)
	local self = CombatNote;
	local candidates = self.FindMobsRange(mobLevel_1,mobLevel_2,excludeBoos);
	local result = {};
	if(candidates)then
		local len = #candidates;
		local list = commonlib.GetRandomList(len,mobTypeNum);
		
		function push(i,n)
			local index = list[i];
			local mob = candidates[index];
			if(mob and n > 0)then
				mob = self.CloneMob(mob,n);
				table.insert(result,mob);
			end
		end
		n1 = n1 or 0;
		n2 = n2 or 0;
		n3 = n3 or 0;
		if(n1 > 0)then
			push(1,n1);
		end
		if(n2 > 0)then
			push(2,n2);
		end
		if(n3 > 0)then
			push(3,n3);
		end
	end
	return result;
end
--find mobs which level between beginLevel and endLevel
function CombatNote.FindMobsRange(beginLevel,endLevel,excludeBoos)
	local self = CombatNote;
	if(not beginLevel or not endLevel)then return end
	beginLevel = math.min(beginLevel,endLevel);
	endLevel = math.max(beginLevel,endLevel);
	local k,mob;
	local candidates = {};
	for k,mob in pairs(self.mobs) do
		if(mob.level >= beginLevel and mob.level <= endLevel)then
			local item = {
				type = mob.type,
				--label = mob.label,
				--level = mob.level,
				--place = mob.place,
			}
			if(excludeBoos)then
				if(not mob.isBoos)then
					table.insert(candidates,item);
				end
			else
				table.insert(candidates,item);
			end
		end
	end
	return candidates;
end
function CombatNote.CloneMob(mob,n)
	local self = CombatNote;
	if(not mob or not n)then return end
	mob = commonlib.deepcopy(mob);
	mob["cur_num"] = 0;
	mob["req_num"] = n;
	return mob;
end