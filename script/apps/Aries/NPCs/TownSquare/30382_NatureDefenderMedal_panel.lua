--[[
Title: code behind for page 30382_NatureDefenderMedal_panel.html
Author(s): Leio
Date: 2009/12/7
Desc:  script/apps/Aries/NPCs/TownSquare/30382_NatureDefenderMedal_panel.html

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30382_NatureDefenderMedal_panel.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/paraworld.homeland.giftbox.lua");
local NatureDefenderMedal_panel = {
	sendNum = 0,--送礼物的次数
	
	a_level_num = 20,--20次，可领取“环保卫士木徽章”
	b_level_num = 100,--100次，可领取“环保卫士铜徽章”
	c_level_num = 300,--300次，可领取“环保卫士银徽章”
	d_level_num = 500,--500次，可领取“环保卫士金徽章”
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.NatureDefenderMedal_panel", NatureDefenderMedal_panel);
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
--20021 环保卫士木徽章
--20022 环保卫士铜徽章
--20023 环保卫士银徽章
--20024 环保卫士金徽章
function NatureDefenderMedal_panel.OnInit()
	local self = NatureDefenderMedal_panel;
	self.pageCtrl =  document:GetPageCtrl();
end
function NatureDefenderMedal_panel.Reset()
	local self = NatureDefenderMedal_panel;
	self.sendNum = 0;
end
function NatureDefenderMedal_panel.RefreshPage()
	local self = NatureDefenderMedal_panel;
	if(self.pageCtrl)then
		self.pageCtrl:Refresh(0.01);
	end
end
function NatureDefenderMedal_panel.ClosePage()
	local self = NatureDefenderMedal_panel;
	if(self.pageCtrl)then
		self.pageCtrl:CloseWindow();
	end
end
--是否包含 木徽章
function NatureDefenderMedal_panel.HasMedal_A()
	local self = NatureDefenderMedal_panel;
	return hasGSItem(20021) or hasGSItem(20022) or hasGSItem(20023) or hasGSItem(20024) ;
end
--是否包含 铜徽章
function NatureDefenderMedal_panel.HasMedal_B()
	local self = NatureDefenderMedal_panel;
	return hasGSItem(20022) or hasGSItem(20023) or hasGSItem(20024) ;
end
--是否包含 银徽章
function NatureDefenderMedal_panel.HasMedal_C()
	local self = NatureDefenderMedal_panel;
	return hasGSItem(20023) or hasGSItem(20024) ;
	
end
--是否包含 金徽章
function NatureDefenderMedal_panel.HasMedal_D()
	local self = NatureDefenderMedal_panel;
	return hasGSItem(20024);
end
function NatureDefenderMedal_panel.ShowMedal()
	local self = NatureDefenderMedal_panel;
	if(not self.HasMedal_A())then
		return "A";
	end
	if(not self.HasMedal_B())then
		return "B";
	end
	if(not self.HasMedal_C())then
		return "C";
	end
	if(not self.HasMedal_D())then
		return "D";
	end
end
function NatureDefenderMedal_panel.ShowMedal_A()
	local self = NatureDefenderMedal_panel;
	if(self.sendNum < self.a_level_num and not self.HasMedal_A() )then
		return true;
	end
end
function NatureDefenderMedal_panel.ShowMedal_B()
	local self = NatureDefenderMedal_panel;
	if(self.sendNum >= self.a_level_num and self.sendNum < self.b_level_num and not self.HasMedal_B() )then
		return true;
	end
end
function NatureDefenderMedal_panel.ShowMedal_C()
	local self = NatureDefenderMedal_panel;
	if(self.sendNum >= self.b_level_num and self.sendNum < self.c_level_num and not self.HasMedal_C() )then
		return true;
	end
end
function NatureDefenderMedal_panel.ShowMedal_D()
	local self = NatureDefenderMedal_panel;
	if(self.sendNum >= self.c_level_num and self.sendNum < self.d_level_num and not self.HasMedal_D() )then
		return true;
	end
end
function NatureDefenderMedal_panel.GetMedal_A()
	local self = NatureDefenderMedal_panel;
	self.GetMedal("A");
end
function NatureDefenderMedal_panel.GetMedal_B()
	local self = NatureDefenderMedal_panel;
	self.GetMedal("B");
end
function NatureDefenderMedal_panel.GetMedal_C()
	local self = NatureDefenderMedal_panel;
	self.GetMedal("C");
end
function NatureDefenderMedal_panel.GetMedal_D()
	local self = NatureDefenderMedal_panel;
	self.GetMedal("D");
end
--兑换徽章
function NatureDefenderMedal_panel.GetMedal(type)
	local self = NatureDefenderMedal_panel;
	if(type == "A")then
		if(self.ShowMedal_A())then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px">要获得环保卫士土徽章，需要将垃圾正确分类20次才可以哦！继续加油吧！</div>]]);
			return;
		end
	elseif(type == "B")then
		if(self.ShowMedal_B())then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px">要获得环保卫士铜徽章，需要将垃圾正确分类100次才可以哦！继续加油吧！</div>]]);
			return;
		end
	elseif(type == "C")then
		if(self.ShowMedal_C())then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px">要获得环保卫士银徽章，需要将垃圾正确分类300次才可以哦！继续加油吧！</div>]]);
			return;
		end
	elseif(type == "D")then
		if(self.ShowMedal_D())then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px">要获得环保卫士金徽章，需要将垃圾正确分类500次才可以哦！继续加油吧！</div>]]);
			return;
		end
	end
	local title = "";
	local exID = nil;
	if(type == "A")then
		title = "木";
		exID = 417;
	elseif(type == "B")then
		title = "铜";
		exID = 418;
	elseif(type == "C")then
		title = "银";
		exID = 419;
	elseif(type == "D")then
		title = "金";
		exID = 420;
	end
	commonlib.echo("======befroe get nature defender medal");
	commonlib.echo(exID);
	if(exID)then
		ItemManager.ExtendedCost(exID, nil, nil, function(msg)end, function(msg)
			commonlib.echo("======after get nature defender medal");
			commonlib.echo(msg);
			if(msg.issuccess) then
				local s = string.format([[<div style="margin-left:20px;margin-top:5px">恭喜你获得环保卫士%s徽章，在资料面板中可以看到它哦！</div>]],title);
				self.RefreshPage();--刷新页面
				_guihelper.MessageBox(s);				
			end
		end)
	end
end
