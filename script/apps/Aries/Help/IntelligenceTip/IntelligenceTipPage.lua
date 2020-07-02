--[[
Title: 
Author(s): leio
Date: 2011/11/16
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Help/IntelligenceTip/IntelligenceTipPage.lua");
local IntelligenceTipPage = commonlib.gettable("MyCompany.Aries.Help.IntelligenceTipPage");
IntelligenceTipPage.DoStart(1,"custom","show_operation");

NPL.load("(gl)script/apps/Aries/Help/IntelligenceTip/IntelligenceTipPage.lua");
local IntelligenceTipPage = commonlib.gettable("MyCompany.Aries.Help.IntelligenceTipPage");
IntelligenceTipPage.DoStartDefault()
------------------------------------------------------------
--]]
NPL.load("(gl)script/apps/Aries/Player/main.lua");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local IntelligenceTipPage = commonlib.gettable("MyCompany.Aries.Help.IntelligenceTipPage");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/ide/XPath.lua");

IntelligenceTipPage.duration = 5000;
IntelligenceTipPage.cur_play_node = nil;
IntelligenceTipPage.cur_play_key = nil;
IntelligenceTipPage.cur_play_index = nil;
IntelligenceTipPage.xml_root = nil;
--get data source
function IntelligenceTipPage.GetFilePath()
	if(CommonClientService.IsKidsVersion())then
		return "config/Aries/Others/intelligence_tip.teen.xml";
	else
		return "config/Aries/Others/intelligence_tip.teen.xml";
	end
end
--[[
NPL.load("(gl)script/apps/Aries/Help/IntelligenceTip/IntelligenceTipPage.lua");
local IntelligenceTipPage = commonlib.gettable("MyCompany.Aries.Help.IntelligenceTipPage");
local item_list = IntelligenceTipPage.SearchNode(1,"quest","60001");
commonlib.echo(item_list);
return {
	{"60001aaaaaaaaaaaaaaa",name="item",n=1,},
	{"60001bbbbbbbbbb",name="item",n=1,},
	{"60001ccccccccccccccc",name="item",n=1,},
	attr={key="60001",},
	name="items",
	n=3,}
--]]
function IntelligenceTipPage.SearchNode(combat_level,activity_type,key)
	local self = IntelligenceTipPage;
	if(not self.xml_root)then
		local file_path = self.GetFilePath();
		self.xml_root = ParaXML.LuaXML_ParseFile(file_path);
	end
	combat_level = combat_level or 0;
	activity_type = activity_type or "default";
	key = key or "default";
	local node;
	for node in commonlib.XPath.eachNode(self.xml_root, "//levels/level") do
		local from = node.attr.from;
		local to = node.attr.to;
		from = tonumber(from);
		to = tonumber(to);
		if(from and to and combat_level >= from and combat_level <= to)then
			local actions_node;
			for actions_node in commonlib.XPath.eachNode(node, "/actions") do
				if(actions_node.attr.activity_type == activity_type)then
					local items_node;
					for items_node in commonlib.XPath.eachNode(actions_node, "/items") do
						if(items_node.attr.key == key)then
							return items_node;
						end				
					end
				end
			end
		end
	end
	for node in commonlib.XPath.eachNode(self.xml_root, "//levels/all_level") do
		return node;
	end
end
function IntelligenceTipPage.DoStartDefault()
	local self = IntelligenceTipPage;
	self.DoStart(-1,nil,nil,true);
end
--active a tooltip
--@parma combat_level:combat level,default value is 0
--@parma activity_type:"custom" or "quest" or "default"
--@parma key:subclass of activity_type can be defined any value
--@parma bRandomIndex:ture start from a random index,otherwise from 1
function IntelligenceTipPage.DoStart(combat_level,activity_type,key,bRandomIndex)
	local self = IntelligenceTipPage;
	--only support teen version
	if(not CommonClientService.IsTeenVersion())then
		return
	end
	combat_level = combat_level or 0;
	activity_type = activity_type or "default";
	key = key or "default";
	local play_key = string.format("%d_%s_%s",combat_level,activity_type,key);
	if(not self.cur_play_key or self.cur_play_key ~= play_key)then
		self.cur_play_key = play_key;
		self.cur_play_index = 1;
	end
	self.cur_play_node = self.SearchNode(combat_level,activity_type,key);
	if(bRandomIndex and self.cur_play_node)then
		local n = table.getn(self.cur_play_node);
		self.cur_play_index = math.random(n);
	end
	if(not self.timer)then
		self.timer = commonlib.Timer:new();
	end
	self.timer.callbackFunc = self.TimerCallback;
	self.timer:Change(0,self.duration);
	if(not self.IsShown())then
		self.ShowPage(true);
	end
end
function IntelligenceTipPage.GetCurPlayNode()
	local self = IntelligenceTipPage;
	if(self.cur_play_node and self.cur_play_index)then
		local node = self.cur_play_node[self.cur_play_index];
		return node;
	end
end
--timer callback function
function IntelligenceTipPage.TimerCallback(timer)
	local self = IntelligenceTipPage;
	if(self.cur_play_node)then
		local n = table.getn(self.cur_play_node);
		self.cur_play_index = self.cur_play_index or 1;
		self.RefreshPage();
		self.cur_play_index = self.cur_play_index + 1;
		if(self.cur_play_index > n)then
			self.cur_play_index = 1;
		end
	end
end
--init page ctrl
function IntelligenceTipPage.OnInit()
	local self = IntelligenceTipPage;
	self.page = document:GetPageCtrl();
end
--show tooltip page
function IntelligenceTipPage.ShowPage(bShow)
	local self = IntelligenceTipPage;
	--only support teen version
	if(not CommonClientService.IsTeenVersion())then
		return
	end
	if(bShow)then
		local is_combat = Player.IsInCombat();
		if(is_combat)then
			return
		end		
		System.App.Commands.Call("File.MCMLWindowFrame", {
					url = "script/apps/Aries/Help/IntelligenceTip/IntelligenceTipPage.teen.html", 
					name = "IntelligenceTipPage.ShowPage", 
					app_key=MyCompany.Aries.app.app_key, 
					--app_key=MyCompany.Taurus.app.app_key, 
					isShowTitleBar = false,
					DestroyOnClose = false, -- prevent many ViewProfile pages staying in memory
					style = CommonCtrl.WindowFrame.ContainerStyle,
					zorder = -1, -- avoid interaction with other normal user interface
					click_through = true, -- allow clicking through
					allowDrag = false,
					bShow = true,
					isPinned = true,
					directPosition = true,
						align = "_rb",
						x = -800,
						y = -90,
						width = 800,
						height = 100,
				});
	else
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name = "IntelligenceTipPage.ShowPage", app_key=MyCompany.Aries.app.app_key, bShow = false});
	end
end
function IntelligenceTipPage.IsShown()
	local self = IntelligenceTipPage;
	if(self.page) then
		return self.page:IsVisible();
	end
end
function IntelligenceTipPage.RefreshPage()
	local self = IntelligenceTipPage;
	if(self.page)then
		self.page:Refresh(0);
	end
end