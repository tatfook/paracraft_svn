--[[
Title: code behind for page 30132_HaqiAmbassador_panel.html
Author(s): Leio
Date: 2009/12/7
Desc:  script/apps/Aries/NPCs/Ambassador/30132_HaqiAmbassador_panel.html

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Ambassador/30132_HaqiAmbassador_panel.lua");
-------------------------------------------------------
]]
local HaqiAmbassador_panel = {
	state = 1, -- 0 没有领取或者 抱抱龙不到3级 1领取验证码 2 兑换物品
	last_state = -1,--上一个状态
	codeList = nil,--验证码信息
	fruitsNum = 0,--红心果数量
	friendsNum = 0,--传播数量
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.HaqiAmbassador_panel", HaqiAmbassador_panel);

function HaqiAmbassador_panel.OnInit()
	local self = HaqiAmbassador_panel;
	self.pageCtrl =  document:GetPageCtrl();
end
function HaqiAmbassador_panel.ClosePage()
	local self = HaqiAmbassador_panel;
	if(self.pageCtrl)then
		self.pageCtrl:CloseWindow();
	end
end
function HaqiAmbassador_panel.RefreshPage()
	local self = HaqiAmbassador_panel;
	if(self.pageCtrl)then
		self.pageCtrl:Refresh(0.01);
	end
end
function HaqiAmbassador_panel.Bind(state,codeList,fruitsNum,friendsNum)
	local self = HaqiAmbassador_panel;
	self.state = state;
	self.codeList = codeList;
	self.fruitsNum = fruitsNum;
	self.friendsNum = friendsNum;
	self.last_state = -1;
end
--8星面包
function HaqiAmbassador_panel.TakeItem_Ambassador_1()
	local self = HaqiAmbassador_panel;
	--刷新bag
	MyCompany.Aries.Quest.NPCs.HaqiAmbassador.RefreshBag(function()
		self.fruitsNum = MyCompany.Aries.Quest.NPCs.HaqiAmbassador.GetFruitsNum()
		if(self.fruitsNum < 1)then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">你的热心果不够哦！</div>]]);
			return;
		end
		
		local ItemManager = System.Item.ItemManager;
		ItemManager.ExtendedCost(812, nil, nil, function(msg) 
				log("+++++++ Exchange_RedHeartFruit_Ambassador_Suit return: +++++++\n")
				commonlib.echo(msg);
				if(msg and msg.issuccess)then
					_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">恭喜你成功兑换了8星面包！</div>]]);
					self.fruitsNum = self.fruitsNum - 1;
					self.RefreshPage();
					paraworld.PostLog({action = "redheartfruit_exchange_1", exid = 812,fruitsNum = 1,}, 
						"redheartfruit_log", function(msg)
					end);
				end
		end);
	end)
end
--能量石
function HaqiAmbassador_panel.TakeItem_Ambassador_3()
	local self = HaqiAmbassador_panel;
	--刷新bag
	MyCompany.Aries.Quest.NPCs.HaqiAmbassador.RefreshBag(function()
		self.fruitsNum = MyCompany.Aries.Quest.NPCs.HaqiAmbassador.GetFruitsNum()
		if(self.fruitsNum < 3)then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">你的热心果不够哦！</div>]]);
			return;
		end
		
		local ItemManager = System.Item.ItemManager;
		ItemManager.ExtendedCost(813, nil, nil, function(msg) 
				log("+++++++ Exchange_RedHeartFruit_Ambassador_Suit return: +++++++\n")
				commonlib.echo(msg);
				if(msg and msg.issuccess)then
					_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">恭喜你成功兑换了能量石！</div>]]);
					self.fruitsNum = self.fruitsNum - 3;
					self.RefreshPage();
					paraworld.PostLog({action = "redheartfruit_exchange_2", exid = 813,fruitsNum = 3,}, 
						"redheartfruit_log", function(msg)
					end);
				end
		end);
	end)
end
--300仙豆
function HaqiAmbassador_panel.TakeItem_Ambassador_6()
	local self = HaqiAmbassador_panel;
	--刷新bag
	MyCompany.Aries.Quest.NPCs.HaqiAmbassador.RefreshBag(function()
		self.fruitsNum = MyCompany.Aries.Quest.NPCs.HaqiAmbassador.GetFruitsNum()
		if(self.fruitsNum < 6)then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">你的热心果不够哦！</div>]]);
			return;
		end
		
		local ItemManager = System.Item.ItemManager;
		ItemManager.ExtendedCost(814, nil, nil, function(msg) 
				log("+++++++ Exchange_RedHeartFruit_Ambassador_Suit return: +++++++\n")
				commonlib.echo(msg);
				if(msg and msg.issuccess)then
					_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">恭喜你成功兑换了300仙豆！</div>]]);
					self.fruitsNum = self.fruitsNum - 6;
					self.RefreshPage();
					paraworld.PostLog({action = "redheartfruit_exchange_3", exid = 814,fruitsNum = 6,}, 
						"redheartfruit_log", function(msg)
					end);
				end
		end);
	end)
end
--2个仙兔坐骑药丸
function HaqiAmbassador_panel.TakeItem_Ambassador_10()
	local self = HaqiAmbassador_panel;
	--刷新bag
	MyCompany.Aries.Quest.NPCs.HaqiAmbassador.RefreshBag(function()
		self.fruitsNum = MyCompany.Aries.Quest.NPCs.HaqiAmbassador.GetFruitsNum()
		if(self.fruitsNum < 10)then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">你的热心果不够哦！</div>]]);
			return;
		end
		
		local ItemManager = System.Item.ItemManager;
		ItemManager.ExtendedCost(815, nil, nil, function(msg) 
				log("+++++++ Exchange_RedHeartFruit_Ambassador_Suit return: +++++++\n")
				commonlib.echo(msg);
				if(msg and msg.issuccess)then
					_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">恭喜你成功兑换了2个仙兔坐骑药丸！</div>]]);
					self.fruitsNum = self.fruitsNum - 10;
					self.RefreshPage();
					paraworld.PostLog({action = "redheartfruit_exchange_4", exid = 815,fruitsNum = 10,}, 
						"redheartfruit_log", function(msg)
					end);
				end
		end);
	end)
end

--兑换物品
function HaqiAmbassador_panel.TakeItem_Bean()
	local self = HaqiAmbassador_panel;
	--刷新bag
	MyCompany.Aries.Quest.NPCs.HaqiAmbassador.RefreshBag(function()
		self.fruitsNum = MyCompany.Aries.Quest.NPCs.HaqiAmbassador.GetFruitsNum()
		if(self.fruitsNum < 1)then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">你的红心果不够哦！</div>]]);
			return;
		end
		local ItemManager = System.Item.ItemManager;
		ItemManager.ExtendedCost(127, nil, nil, function(msg) 
				log("+++++++ Exchange_RedHeartFruit_Joybean return: +++++++\n")
				commonlib.echo(msg);
				if(msg and msg.issuccess)then
					_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">恭喜你成功兑换了500奇豆！</div>]]);
				
					self.fruitsNum = self.fruitsNum - 1;
					self.RefreshPage();
				end
		end);
	end)
end

--灯笼花
--改为2星面包 2010/12/23
function HaqiAmbassador_panel.TakeItem_LanternFlower()
	local self = HaqiAmbassador_panel;
	--if(self.HasItem_LanternFlower())then
		--_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">这个宝贝你已经有啦，换点别的吧！</div>]]);
		--return
	--end
	--刷新bag
	MyCompany.Aries.Quest.NPCs.HaqiAmbassador.RefreshBag(function()
		self.fruitsNum = MyCompany.Aries.Quest.NPCs.HaqiAmbassador.GetFruitsNum()
		if(self.fruitsNum < 3)then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">你的红心果不够哦！</div>]]);
			return;
		end
		
		local ItemManager = System.Item.ItemManager;
		ItemManager.ExtendedCost(128, nil, nil, function(msg) 
				log("+++++++ Exchange_RedHeartFruit_LanternFlower return: +++++++\n")
				commonlib.echo(msg);
				if(msg and msg.issuccess)then
					_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">恭喜你成功兑换了2星面包！</div>]]);
					--TODO:refresh bag?
					self.fruitsNum = self.fruitsNum - 3;
					self.RefreshPage();
				end
		end);
	end)
end
--鞭炮灯
function HaqiAmbassador_panel.TakeItem_FireCrackerLamp()
	local self = HaqiAmbassador_panel;
	--刷新bag
	MyCompany.Aries.Quest.NPCs.HaqiAmbassador.RefreshBag(function()
		self.fruitsNum = MyCompany.Aries.Quest.NPCs.HaqiAmbassador.GetFruitsNum()
		if(self.fruitsNum < 3)then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">你的红心果不够哦！</div>]]);
			return;
		end
		
		local ItemManager = System.Item.ItemManager;
		ItemManager.ExtendedCost(187, nil, nil, function(msg) 
				log("+++++++ Exchange_FireCrackerLamp return: +++++++\n")
				commonlib.echo(msg);
				if(msg and msg.issuccess)then
					_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">恭喜你成功兑换了炽焰鞭炮灯！</div>]]);
					--TODO:refresh bag?
					self.fruitsNum = self.fruitsNum - 3;
					self.RefreshPage();
				end
		end);
	end)
end
--哈奇大使帽
function HaqiAmbassador_panel.TakeItem_FeatherHat()
	local self = HaqiAmbassador_panel;
	if(self.HasItem_Ambassador_FeatherHat())then
		_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">这个宝贝你已经有啦，换点别的吧！</div>]]);
		return
	end
	--刷新bag
	MyCompany.Aries.Quest.NPCs.HaqiAmbassador.RefreshBag(function()
		self.fruitsNum = MyCompany.Aries.Quest.NPCs.HaqiAmbassador.GetFruitsNum()
		if(self.fruitsNum < 6)then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">你的红心果不够哦！</div>]]);
			return;
		end
		
		local ItemManager = System.Item.ItemManager;
		ItemManager.ExtendedCost(129, nil, nil, function(msg) 
				log("+++++++ Exchange_RedHeartFruit_Ambassador_FeatherHat return: +++++++\n")
				commonlib.echo(msg);
				if(msg and msg.issuccess)then
					_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">恭喜你成功兑换了哈奇大使帽！</div>]]);
					--TODO:refresh bag?
					self.fruitsNum = self.fruitsNum - 6;
					self.RefreshPage();
				end
		end);
	end)
end
--哈奇大使服
function HaqiAmbassador_panel.TakeItem_Ambassador_Suit()
	local self = HaqiAmbassador_panel;
	if(self.HasItem_Ambassador_Suit())then
		_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">这个宝贝你已经有啦，换点别的吧！</div>]]);
		return
	end
	--刷新bag
	MyCompany.Aries.Quest.NPCs.HaqiAmbassador.RefreshBag(function()
		self.fruitsNum = MyCompany.Aries.Quest.NPCs.HaqiAmbassador.GetFruitsNum()
		if(self.fruitsNum < 10)then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">你的红心果不够哦！</div>]]);
			return;
		end
		
		local ItemManager = System.Item.ItemManager;
		ItemManager.ExtendedCost(130, nil, nil, function(msg) 
				log("+++++++ Exchange_RedHeartFruit_Ambassador_Suit return: +++++++\n")
				commonlib.echo(msg);
				if(msg and msg.issuccess)then
					_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">恭喜你成功兑换了哈奇大使服！</div>]]);
					--TODO:refresh bag?
					self.fruitsNum = self.fruitsNum - 10;
					self.RefreshPage();
				end
		end);
	end)
end
--是否已经有灯笼花
function HaqiAmbassador_panel.HasItem_LanternFlower()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local gsid = 30024;
	local bHas, guid = hasGSItem(gsid);
	return bHas;
end
--是否已经有哈奇大使帽
function HaqiAmbassador_panel.HasItem_Ambassador_FeatherHat()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local gsid = 1078;
	local bHas, guid = hasGSItem(gsid);
	return bHas;
end
--是否已经有哈奇大使服
function HaqiAmbassador_panel.HasItem_Ambassador_Suit()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local gsid = 1075; --|1075,1|1076,1|1077,1|1079,1
	local bHas, guid = hasGSItem(gsid);
	return bHas;
end
function HaqiAmbassador_panel.CopyCode_1()
	local self = HaqiAmbassador_panel;
	local r = self.getKeyByIndex(1);
	ParaMisc.CopyTextToClipboard(r);
end
function HaqiAmbassador_panel.CopyCode_2()
	local self = HaqiAmbassador_panel;
	local r = self.getKeyByIndex(2);
	ParaMisc.CopyTextToClipboard(r);
end
function HaqiAmbassador_panel.CopyCode_3()
	local self = HaqiAmbassador_panel;
	local r = self.getKeyByIndex(3);
	ParaMisc.CopyTextToClipboard(r);
end
function HaqiAmbassador_panel.CopyCode_4()
	local self = HaqiAmbassador_panel;
	local r = self.getKeyByIndex(4);
	ParaMisc.CopyTextToClipboard(r);
end
function HaqiAmbassador_panel.CopyCode_5()
	local self = HaqiAmbassador_panel;
	local r = self.getKeyByIndex(5);
	ParaMisc.CopyTextToClipboard(r);
end
function HaqiAmbassador_panel.CopyCode_domain()
	local self = HaqiAmbassador_panel;
	local r = "http://haqi.61.com/main/";
	ParaMisc.CopyTextToClipboard(r);
end
function HaqiAmbassador_panel.getKeyByIndex(index)
	local self = HaqiAmbassador_panel;
	local codeList = self.codeList or {};
    local r = codeList[index];
    if(r)then
        return r.keycode or "";
    end
    return ""
end
