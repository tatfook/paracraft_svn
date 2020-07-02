--[[
Title: MotherDayMail
Author(s): Leio
Date: 2009/12/7

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30384_RecycleBin.lua");
------------------------------------------------------------
]]
-- create class
local libName = "MotherDayMail";
local MotherDayMail = {
	items = {
		{ nid = 1054955, title = "妈妈教我剪纸", pic = "9", },
		{ nid = 9264054, title = "妈妈我爱你！", pic = "1", },
		{ nid = 109857438, title = "妈妈教我写作业", pic = "5", },
		{ nid = 41603275, title = "送给妈妈的爱", pic = "6", },
		
		{ nid = 40130145, title = "母亲节", pic = "4", },
		{ nid = 873890, title = "我和妈妈点红烛", pic = "11", },
		{ nid = 1413190, title = "妈妈辛苦了~", pic = "10", },
		{ nid = 16173298, title = "给老妈喝茶", pic = "3", },
		
		{ nid = 133676174, title = "鲜花送妈妈", pic = "8", },
		{ nid = 36050100, title = "母亲", pic = "2", },
		{ nid = 117079287, title = "送您一束花，妈妈", pic = "7", },
	},
	hasSort = false,
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.MotherDayMail", MotherDayMail);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
-- MotherDayMail.main
function MotherDayMail.main()
	if(MotherDayMail.items and not MotherDayMail.hasSort)then
		MotherDayMail.hasSort = true;
		table.sort(MotherDayMail.items,function(a,b)
			local p_1 = tonumber(a.pic);
			local p_2 = tonumber(b.pic);
			if(p_1 and p_2)then
				return p_1 < p_2
			end
		end);
	end
end

function MotherDayMail.PreDialog(npc_id, instance)
	local self = MotherDayMail;
	NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/LiteMailPage.lua");
	local args = {
		align = "_ct",
		x = -793/2,
		y = -510/2,
		width = 793,
		height = 510,
		url = "script/kids/3DMapSystemUI/PENote/Pages/MotherDayMailPage.html",
	}
	Map3DSystem.App.PENote.LiteMailPage.ShowPage(100,args);
	return false;
end

function MotherDayMail.DS_Func_Items(index)
	local self = MotherDayMail;
	if(not self.items)then return 0 end;
	local len = table.getn(self.items);
	if(index ~= nil) then
		return self.items[index] or {};
	elseif(index == nil) then
		return len;
	end
end
