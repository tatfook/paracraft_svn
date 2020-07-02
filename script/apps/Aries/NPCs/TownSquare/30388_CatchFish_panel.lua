--[[
Title: CatchFish_panel
Author(s): Leio
Date: 2009/12/7

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30388_CatchFish_panel.lua");
MyCompany.Aries.Quest.NPCs.CatchFish_panel.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30388_CatchFish.lua");
-- create class
local CatchFish_panel = {
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.CatchFish_panel", CatchFish_panel);
function CatchFish_panel.OnInit()
	local self = CatchFish_panel;
	self.page = document:GetPageCtrl();
end
function CatchFish_panel.ShowPage()
	local self = CatchFish_panel;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/TownSquare/30388_CatchFish_panel.html", 
			name = "CatchFish_panel.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			--app_key=MyCompany.Taurus.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = -10,
			allowDrag = false,
			click_through = true,
			directPosition = true,
				align = "_ctb",
				x = 0,
				y = 0,
				width = 960,
				height = 560,
		});
	
end
function CatchFish_panel.ClosePage()
	local self = CatchFish_panel;
	if(self.page)then
		self.page:CloseWindow();
	end
end
function CatchFish_panel.OnUpdateTime(sec)
	local self = CatchFish_panel;
	sec = tonumber(sec);
	if(self.page and sec)then
		sec = string.format("%.2d",sec);
		--self.page:SetUIValue("time_text_sprite",sec);
		MyCompany.Aries.Quest.NPCs.CatchFish.UpdateClockUI(sec);
	end
end
function CatchFish_panel.OnUpdateNetNum(num)
	local self = CatchFish_panel;
	num = MyCompany.Aries.Quest.NPCs.CatchFish.GetNetNum();
	if(self.page)then
		self.page:SetUIValue("net_text_sprite",num or 0);
	end
end
function CatchFish_panel.OnUpdateFishNum(num)
	local self = CatchFish_panel;
	num = MyCompany.Aries.Quest.NPCs.CatchFish.GetFishNum();
	if(self.page)then
		self.page:SetUIValue("fish_text_sprite",num or 0);
	end
end
function CatchFish_panel.OnUpdateUI()
	local self = CatchFish_panel;
	if(self.page)then
		local net_node = MyCompany.Aries.Quest.NPCs.CatchFish.GetSelectedNetNode();
		local s = string.format("目前使用的是：%s",net_node.label);
		self.page:SetUIValue("net_type",s);	
		self.page:SetUIValue("net_text_sprite",MyCompany.Aries.Quest.NPCs.CatchFish.GetNetNum() or 0);
		self.page:SetUIValue("fish_text_sprite",MyCompany.Aries.Quest.NPCs.CatchFish.GetFishNum() or 0);

		local catchfish = MyCompany.Aries.Quest.NPCs.CatchFish;
		local str;
		if(catchfish.autoMode) then
			str = "停止捕鱼";
		else
			str = "自动捕鱼";
		end
		self.page:SetUIValue("auto_fish",str);	

		local s1= "捕鱼器准备就绪";
		local s2;
		if(catchfish.canAutoFishNets[catchfish.selected_net_gsid]) then
			local value;
			if(catchfish.selected_net_gsid == 17465) then
				value = "100%";
			elseif(catchfish.selected_net_gsid == 17466) then
				value = "85%";
			elseif(catchfish.selected_net_gsid == 17467) then
				value = "75%";
			end
			s2 = string.format("%s几率捕到鱼",value or 0);
			if(catchfish.autoMode) then
				s1= "正在捕鱼中...";
			end
		else
			s1 = "";
			s2 = "";	
		end
		self.page:SetUIValue("Apparatus_show_1",s1);	
		self.page:SetUIValue("Apparatus_show_2",s2);	
	end
end






