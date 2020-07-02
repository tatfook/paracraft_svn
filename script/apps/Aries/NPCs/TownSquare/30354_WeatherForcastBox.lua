--[[
Title: WeatherForcastBox
Author(s): andy
Date: 2010/02/06

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30354_WeatherForcastBox.lua
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
-- create class
local libName = "WeatherForcastBox";
local WeatherForcastBox = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WeatherForcastBox", WeatherForcastBox);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WeatherForcastBox.main
function WeatherForcastBox.main()
end

-- WeatherForcastBox.PreDialog
function WeatherForcastBox.PreDialog(npc_id, instance)
	--_guihelper.Custom_MessageBox("<div style='margin-left:15px;margin-top:25px;text-align:center'>我是不倒翁，3片红枫叶就可以带我回家哦，你确认要带我回家吗？</div>",function(result)
		--if(result == _guihelper.DialogResult.Yes)then
			--WeatherForcastBox.DoExchange()
		--else
			--
		--end
	--end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Cancel_32bits.png; 0 0 153 49"});
	return false;
end