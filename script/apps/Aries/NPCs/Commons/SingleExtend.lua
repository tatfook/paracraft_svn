--[[
Title: SingleExtend
Author(s): Leio
Date: 2010/03/30

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Commons/SingleExtend.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
-- create class
local libName = "SingleExtend";
local SingleExtend = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.SingleExtend", SingleExtend);
local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- 红枫叶兑换物品
--[[
NPL.load("(gl)script/apps/Aries/NPCs/Commons/SingleExtend.lua");
	local msg = {
		req_num = 2,
		exID = 392,
		ex_name = "围棋凳",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
--]]
function SingleExtend.RedLeafDoExtend(msg,callbackfunc)
	if(not msg or not msg.req_num or not msg.exID)then return end
	local req_num = msg.req_num;
	local exID = msg.exID;
	local ex_name = msg.ex_name or "";
	
	
	function DoExchange()
		local __,__,__,copies = hasGSItem(17077);
		copies = copies or 0;
		if(copies < req_num)then
			_guihelper.Custom_MessageBox("<div style='margin-left:15px;margin-top:25px;text-align:center'>你的红枫叶还不够哦，再多去其他哈奇家找找挑战之旗吧！</div>",function(result)
				if(result == _guihelper.DialogResult.OK)then
					commonlib.echo("OK");
				end
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		else
			commonlib.echo("====== before SingleExtend.RedLeafDoExtend");
			commonlib.echo(exID);
			ItemManager.ExtendedCost(exID, nil, nil, function(msg)end, function(msg)
					commonlib.echo("======after SingleExtend.RedLeafDoExtend");
					commonlib.echo(msg);
					if(msg.issuccess) then
						if(callbackfunc)then
							callbackfunc();
						end
					end
			end)
		end
	end
	DoExchange()
	--local s = string.format("<div style='margin-left:15px;margin-top:25px;text-align:center'>我是%s，%d片红枫叶就可以带我回家哦，你确认要带我回家吗？</div>",ex_name,req_num);
	--_guihelper.Custom_MessageBox(s,function(result)
		--if(result == _guihelper.DialogResult.Yes)then
			--DoExchange()
		--else
			--
		--end
	--end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Cancel_32bits.png; 0 0 153 49"});
end