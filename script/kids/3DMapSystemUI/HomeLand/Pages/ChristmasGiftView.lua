--[[
Title: code behind for page ChristmasGiftView.html
Author(s): Leio
Date: 2009/12/15
Desc:  script/kids/3DMapSystemUI/HomeLand/Pages/ChristmasGiftView.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/ChristmasGiftView.lua");
MyCompany.Aries.Inventory.ChristmasGiftViewPage.christmas_gifts = {
	{guid = 0, label = "很特别的家园装扮——晃晃稻草人，这可是买不到的特别东西哦！",},
	{guid = 0, label = "家园装扮——青青小石桌，放在你在家园中一定很漂亮！",},
	{guid = 0, label = "家园装扮——青青小石椅，让你的家园更温馨！",},
	{guid = 0, label = "家园装扮——青青小石凳，让你的家园更漂亮！",},
	{guid = 0, label = "家园装扮——竹子栅栏，给你的家园带来春天的气息！",},
	{guid = 0, label = "家园装扮——冰雕礼盒，跟这个大雪纷飞的圣诞最相配！",},
	{guid = 0, label = "晶晶石，这是多科特博士托我转交给你的圣诞礼物，快去沙滩上试试他的新发明吧！",},
	{guid = 0, label = "又大又圆的西瓜，它能作出抱抱龙最喜欢的食品哦！",},
}
MyCompany.Aries.Inventory.ChristmasGiftViewPage.ShowPage();
-------------------------------------------------------
]]
local ChristmasGiftViewPage = {
	christmas_gifts = nil,
};
commonlib.setfield("MyCompany.Aries.Inventory.ChristmasGiftViewPage", ChristmasGiftViewPage);
function ChristmasGiftViewPage.DS_Func_Items(index)
	local self = ChristmasGiftViewPage;
	if(not self.christmas_gifts_group)then return 0 end
	if(index == nil) then
		return #(self.christmas_gifts_group);
	else
		return self.christmas_gifts_group[index];
	end
end
function ChristmasGiftViewPage.ShowPage()
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
	local self = ChristmasGiftViewPage;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/HomeLand/Pages/ChristmasGiftView.html", 
			name = "ChristmasGiftViewPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -735/2,
				y = -545/2,
				width = 735,
				height = 545,
		});
end
function ChristmasGiftViewPage.ClosePage()
	local self = ChristmasGiftViewPage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="ChristmasGiftViewPage.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,bDestroy = true,});
	self.canvas = nil;
	self.node = nil;
	self.curState = nil;
	self.christmas_gifts = nil;
	self.christmas_gifts_group = nil;
end
function ChristmasGiftViewPage.TakeGift()
	local self = ChristmasGiftViewPage;
	if(self.canvas)then
		self.canvas:TakeawayChristmasGiftToday(function()
			--在关闭面板的时候，清空选中的物体
			--if(self.canvas and self.canvas.nodeProcessor)then
				--self.canvas.nodeProcessor.selectedNode = nil;
			--end
			local s = "";
			if(self.christmas_gifts_group)then
				local k,v;
				for k,v in ipairs(self.christmas_gifts_group) do
					local num = v.num;
					local name = v.name;
					s = s .. string.format("%d个%s,",num,name);
				end
				s = s.."已经放入你的仓库当中了。";
			end
			s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>%s</div>",s);
			_guihelper.MessageBox(s);
			self.ClosePage();
		end);
	end
end
function ChristmasGiftViewPage.Init(canvas,node,combinedState,christmas_gifts,christmas_gifts_group)
	local self = ChristmasGiftViewPage;
	commonlib.echo("=======christmas_gifts");
	commonlib.echo(christmas_gifts);
	if(not canvas or not node or not combinedState or not christmas_gifts)then return end
	self.canvas = canvas;
	self.node = node;
	self.ChangeState(combinedState);
	self.christmas_gifts = christmas_gifts;
	self.christmas_gifts_group = christmas_gifts_group;
end

function ChristmasGiftViewPage.ChangeState(combinedState)
	local self = ChristmasGiftViewPage;
	if(not combinedState)then return end
	if(combinedState == "master_outside_true" or combinedState == "master_inside_true")then
		self.curState = "master_edit";
	elseif(combinedState == "master_outside_false" or combinedState == "master_inside_false")then
		self.curState = "master_view";
	elseif(combinedState == "guest_outside_false" or combinedState == "guest_inside_false")then
		self.curState = "guest_view";
	end		
end