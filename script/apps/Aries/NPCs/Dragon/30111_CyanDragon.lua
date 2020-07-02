--[[
Title: CyanDragon
Author(s): WangTian
Date: 2009/7/30

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30111_CyanDragon.lua
------------------------------------------------------------
]]

-- create class
local libName = "CyanDragon";
local CyanDragon = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.CyanDragon", CyanDragon);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

function CyanDragon.CanShow()
	local bean = MyCompany.Aries.Pet.GetBean();
    if(bean and bean.combatlel >= 5)then
        return true;
	else
		return false;
    end
end

function CyanDragon.doResetTrainingPoint(callbackFunc)
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	if(not DealDefend.CanPass())then
		return
	end
	if(System.options.version=="kids") then
		local s = string.format("<div style='margin-left:-15px;margin-top:5px;text-align:left'>你需要重新学习你的魔法吗？<br/>【注意】遗忘的魔法不包括任务获得的魔法，遗忘后你的训练点将被还原，并扣除<font color='#ff0000'>100</font>魔豆！</div>");
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.Yes)then
				System.Item.ItemManager.ResetTrainingPoint(function(msg) 
					if(msg.issuccess == true) then
						local s = string.format("<div style='margin-left:10px;margin-top:10px;text-align:left'>恭喜你获得重新学习魔法的机会，快去学习你想修习的魔法吧！</div>");
						_guihelper.MessageBox(s,callbackFunc,_guihelper.MessageBoxButtons.OK);
					else
						if (msg.errorcode==427) then
							local s = string.format("<div style='margin-left:10px;margin-top:10px;text-align:left'>小哈奇你现在不需要洗点哦！你没有学习过辅修魔法哦！</div>");
							_guihelper.MessageBox(s);
						end
					end
				end, function(msg) end, 10000, function()
					_guihelper.MessageBox("网络有故障，你等一会再来吧\n");
				end);
			end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no ="Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});

	else

		local s = string.format("<div style='margin-left:5px;margin-top:5px;text-align:left'>你需要重新学习别系的魔法吗？<br/>【注意】遗忘后你的潜力点将被重置，并扣除<font color='#ff0000'>100</font>魔豆！</div>");
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.Yes)then
				System.Item.ItemManager.ResetTrainingPoint(function(msg) 
					if(msg.issuccess == true) then
						local s = string.format("<div style='margin-left:10px;margin-top:10px;text-align:left'>恭喜你获得重新学习魔法的机会，快去学习你想修习的魔法吧！</div>");
						_guihelper.MessageBox(s);
					else
						if (msg.errorcode==427) then
							local s = string.format("<div style='margin-left:10px;margin-top:10px;text-align:left'>你现在不需要洗点！你没有学习过辅修魔法！</div>");
							_guihelper.MessageBox(s);
						end
					end
				end, function(msg) end, 10000, function()
					_guihelper.MessageBox("网络有故障，你等一会再来吧\n");
				end);
			end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no ="Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});

	end
end

-- CyanDragon.main
function CyanDragon.main()
end