--[[
Title: WarmHeartPage
Author(s): Leio
Date: 2012/01/17
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TeenAction/WarmHeartPage.lua");
local WarmHeartPage = commonlib.gettable("MyCompany.Aries.Quest.NPCs.TeenAction.WarmHeartPage");
WarmHeartPage.ShowPage();
-------------------------------------------------------
]]
local WarmHeartPage = commonlib.gettable("MyCompany.Aries.Quest.NPCs.TeenAction.WarmHeartPage");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
WarmHeartPage.exchange_list = {
	{label = "8星面包", exid = 812, need_heart = 1,},
	{label = "能量石", exid = 813, need_heart = 3,},
	{label = "400战场徽章", exid = 814, need_heart = 6,},
	{label = "1个蒸汽直升机", exid = 815, need_heart = 15,},
}
function WarmHeartPage.OnInit()
	local self = WarmHeartPage;
	self.page = document:GetPageCtrl();
end
function WarmHeartPage.RefreshPage()
	local self = WarmHeartPage;
	if(self.page)then
		self.page:Refresh(0);
	end
end
function WarmHeartPage.ShowPage()
	local self = WarmHeartPage;
	Map3DSystem.Item.ItemManager.GetItemsInBag(30132, "", function(msg)
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/TeenAction/WarmHeartPage.html", 
			name = "WarmHeartPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			enable_esc_key = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -760/2,
				y = -484/2,
				width = 760,
				height = 484,
		});	
	end, "access plus 0 day");
end
function WarmHeartPage.DoExchange(index)
	local self = WarmHeartPage;
	local node = self.exchange_list[index];
	if(not node)then return end
	local __,__,__,copies = hasGSItem(50337);
	copies = copies or 0;
	if(copies < node.need_heart)then
		_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;text-align:center">你的热心果不够哦！</div>]]);
		return;
	end
		
	local exid = node.exid;
	ItemManager.ExtendedCost(exid, nil, nil, function(msg) 
			if(msg and msg.issuccess)then
				local s = string.format([[<div style="margin-left:20px;margin-top:20px;text-align:center">恭喜你成功兑换了%s！</div>]],node.label);
				_guihelper.MessageBox(s);
				self.RefreshPage();
				paraworld.PostLog({action = "redheartfruit_exchange", exid = exid,fruitsNum = node.need_heart,}, 
					"redheartfruit_log", function(msg)
				end);
			end
	end);
end