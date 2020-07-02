--[[
Title: RecycleProcess_panel
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------

NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30385_RecycleProcess_panel.lua");
MyCompany.Aries.Quest.NPCs.RecycleProcess_panel.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30385_RecycleProcess_frame.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");

-- create class
local libName = "RecycleProcess_panel";
local RecycleProcess_panel = {
	selected_item = nil,
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.RecycleProcess_panel", RecycleProcess_panel);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

RecycleProcess_panel.Items = {
		{name = "低碳环保灯",exID = 422, gsid = 30155, icon = "",redflower = 8,  desc = "低碳环保灯，可以通过吸收太阳能来发光，不会造成能源浪费，是非常节能的家园装饰呢。<br />兑换条件：8朵小红花。", },
		{name = "轮胎秋千",exID = 423, gsid = 30156, icon = "",redflower = 20, desc = "这个轮胎秋千，可都是拿废弃轮胎改造成的呢，把轮胎刷上漂亮的颜色，再利用起来，真是有创意啊。<br />兑换条件：20朵小红花。", },
		{name = "拼图台阶板",exID = 424, gsid = 30157, icon = "",redflower = 5, desc = "用废弃塑料做的拼图台阶板，属于那种画龙点睛的小装饰，在某些梯台的一侧加上它，就更完美了。<br />兑换条件：5朵小红花。", },
		{name = "十八弯梯台",exID = 425, gsid = 30158, icon = "",redflower = 18, desc = "十八弯梯台，有四个面，每一面都可以接上别的东西，可塑性还真强啊，快看看有什么东西可以跟它接起来吧。<br />兑换条件：18朵小红花。", },
		{name = "十八弯滑梯",exID = 426, gsid = 30159, icon = "",redflower = 18, desc = "十八弯滑梯？真的是十八弯呢，也是废塑料做的，这废塑料的用处还真不小，什么都能做！这个东西要是接在那个梯台上，真是浑然一体呢。<br />兑换条件：18朵小红花。", },
		{name = "铁皮管滑梯",exID = 427, gsid = 30160, icon = "",redflower = 20, desc = "铁皮管滑梯，顾名思义当然是铁皮做的啦！好粗的一条管道，绿色也很养眼嘛。<br />兑换条件：20朵小红花。", },
		{name = "铁皮管梯台",exID = 428, gsid = 30161, icon = "",redflower = 15, desc = "难道是铁皮管滑梯的配套设施？这两个拼在一起肯定很好看吧。<br />兑换条件：15朵小红花。", },
		{name = "轮胎障碍通道",exID = 429, gsid = 30162, icon = "",redflower = 10, desc = "这个轮胎障碍通道，也是用废弃轮胎做的，用它把那些梯台连接起来，可以拼接成一个长的通道呀，你可要有耐心把它们拼起来哟。<br />兑换条件：10朵小红花。", },
}
function RecycleProcess_panel.DS_Func_RecycleProcess_panel(index)
	local self = RecycleProcess_panel;
	if(not self.Items)then return 0 end
	if(index == nil) then
		return #(self.Items);
	else
		return self.Items[index];
	end
end
function RecycleProcess_panel.OnInit()
	local self = RecycleProcess_panel; 
	self.page = document:GetPageCtrl();
end
function RecycleProcess_panel.DoClick(index)
	index = tonumber(index);
	if(not index)then return end
	local self = RecycleProcess_panel; 
	self.selected_item = self.Items[index];
	if(self.selected_item)then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(self.selected_item.gsid);
		if(gsItem and self.page)then
			self.page:SetValue("icon",gsItem.icon);
		end
    end
	self.RefreshPage();
end
function RecycleProcess_panel.ShowPage()
	local self = RecycleProcess_panel;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/TownSquare/30385_RecycleProcess_panel.html", 
			name = "RecycleProcess_panel.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -777/2,
				y = -533/2,
				width = 777,
				height = 533,
		});
	self.DoClick(1)
end
function RecycleProcess_panel.Reset()
	local self = RecycleProcess_panel;
	self.selected_item = self.Items[1];
end
function RecycleProcess_panel.ClosePage()
	local self = RecycleProcess_panel;
	if(self.page)then
		self.page:CloseWindow();
	end
end
function RecycleProcess_panel.RefreshPage()
	local self = RecycleProcess_panel;
	if(self.page)then
		self.page:Refresh(0.01);
	end
end
function RecycleProcess_panel.CanBuild(redflower)
	local self = RecycleProcess_panel;
	local __, guid,__,copies = hasGSItem(17096);
	if(copies)then
		return copies >= redflower;
	end
end
--开始建造
function RecycleProcess_panel.DoBuild()
	local self = RecycleProcess_panel;
	local item = self.selected_item;
	if(not item)then return end
	local label = item.name;
	local redflower = item.redflower;
	local exID = item.exID;
	local canBuild = self.CanBuild(redflower)
	--缺少物品
	if(not canBuild)then
		local s = string.format("<div style='margin-left:15px;margin-top:10px;text-align:center'>喔噢，你的小红花还不够，兑换【%s】需要%d朵小红花，快去捡一些垃圾把它们扔进合适的垃圾桶吧，这样可以获得小红花哦！</div>",label,redflower);
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return;
	end
	--搬家
	local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你确定要用%d朵小红花兑换【%s】吗？</div>",
				redflower,label);
	_guihelper.Custom_MessageBox(s,function(result)
		if(result == _guihelper.DialogResult.Yes)then
			self.ClosePage();
			ItemManager.ExtendedCost(exID, nil, nil, function(msg)end, function(msg)
					commonlib.echo("======after ExtendedCost in RecycleProcess_panel");
					commonlib.echo(msg);
					if(msg.issuccess) then
						
					end
			end);
				
		else
			commonlib.echo("no");
		end
	end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
end


