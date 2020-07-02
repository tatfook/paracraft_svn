--[[
Title: RedLeaf_panel
Author(s): Leio
Date: 2010/09/30

use the lib:

------------------------------------------------------------

NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30375_RedLeaf_panel.lua");
MyCompany.Aries.Quest.NPCs.RedLeaf_panel.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/30345_CastMachine_panel.lua");
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/30345_CastMachine_compose_frame.lua");
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/30347_CastSkillHitBoard.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");

-- create class
local libName = "RedLeaf_panel";
local RedLeaf_panel = {
	selected_index = nil,
	page_state = 0,
	selected_items = nil,
	
	static_odds = MyCompany.Aries.Quest.NPCs.CastMachine_panel.static_odds,
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.RedLeaf_panel", RedLeaf_panel);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

RedLeaf_panel.Items = {
	--室外
	[1] = {
		{name = "数字4",exID = 738, gsid = 30228 ,req_num = 8,},
		{name = "数字5",exID = 739, gsid = 30229 ,req_num = 8,},
		{name = "数字6",exID = 740, gsid = 30230 ,req_num = 8,},
		{name = "字母M",exID = 741, gsid = 30210 ,req_num = 8,},
		{name = "字母U",exID = 742, gsid = 30218 ,req_num = 8,},
		{name = "字母V",exID = 743, gsid = 30219 ,req_num = 8,},
		{name = "字母W",exID = 744, gsid = 30220 ,req_num = 8,},
		{name = "字母Z",exID = 745, gsid = 30223 ,req_num = 8,},

		{name = "围棋桌",exID = 391, gsid = 30129 ,req_num = 6,},
		{name = "围棋凳",exID = 392, gsid = 30130,req_num = 2,},
		{name = "绿芽树状桌",exID = 444, gsid = 30181,req_num = 4,},
		{name = "绿芽树状凳",exID = 445, gsid = 30182,req_num = 2,},
		{name = "榕树茶几",exID = 443, gsid = 30178,req_num = 4,},
		{name = "三角玻璃桌",exID = 468, gsid = 30183,req_num = 6,},
		{name = "彩色蝴蝶丛 ",exID = 469, gsid = 30179,req_num = 8,},
		{name = "祈福灯",exID = 490, gsid = 30189,req_num = 8,},
	},
	--室内
	[2] = {
		{name = "大抱熊公仔",exID = 290, gsid = 30100,req_num = 3,},
		{name = "红衫木屏风",exID = 348, gsid = 30116,req_num = 4,},
		{name = "布老虎",exID = 347, gsid = 30115,req_num = 4,},
		{name = "学者书架",exID = 382, gsid = 30127,req_num = 8,},
		{name = "营地马灯",exID = 404, gsid = 30142,req_num = 4,},
		{name = "鸟屋挂钟",exID = 416, gsid = 30146,req_num = 4,},
		{name = "碎花布大抱熊",exID = 421, gsid = 30154,req_num = 4,},
		{name = "青蛙椅",exID = 442, gsid = 30174,req_num = 4,},
		{name = "杂物架",exID = 479, gsid = 30188,req_num = 6,},
	},
	
}
function RedLeaf_panel.DS_Func_RedLeaf_panel(index)
	local self = RedLeaf_panel;
	if(not self.selected_items)then return 0 end
	if(index == nil) then
		return #(self.selected_items);
	else
		return self.selected_items[index];
	end
end
function RedLeaf_panel.OnInit()
	local self = RedLeaf_panel; 
	self.page = document:GetPageCtrl();
end
function RedLeaf_panel.DoClick(index)
	local self = RedLeaf_panel; 
	self.selected_index = index;
	self.BindFramePage()
	self.RefreshPage();
end
function RedLeaf_panel.ChangeState(index)
	local self = RedLeaf_panel;
	index = tonumber(index); 
	if(not index)then return end
	self.page_state = index or 0;
	self.selected_index = 1;
	self.selected_items = self.Items[index + 1];
	
	self.BindFramePage()
	self.RefreshPage();	
end
function RedLeaf_panel.ShowPage()
	local self = RedLeaf_panel;
	self.Reset();
	self.BindFramePage();
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/TownSquare/30375_RedLeaf_panel.html", 
			name = "RedLeaf_panel.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -686/2,
				y = -507/2,
				width = 686,
				height = 507,
		});
end
function RedLeaf_panel.Reset()
	local self = RedLeaf_panel;
	self.page_state = 0;
	self.selected_index = 1;
	self.selected_items = self.Items[1];
end
function RedLeaf_panel.ClosePage()
	local self = RedLeaf_panel;
	if(self.page)then
		self.page:CloseWindow();
	end
end
function RedLeaf_panel.RefreshPage()
	local self = RedLeaf_panel;
	if(self.page)then
		self.page:Refresh(0.01);
	end
end
--刷新frame
function RedLeaf_panel.BindFramePage()
	local self = RedLeaf_panel;
	--local msg = {
		--exID = 271,
		--gsids = { { key=17003, value=2 }, { key=17014, value=1 }, { key=17013, value=1 } },
		--exchanged_gsids = { { key=30065, value=1 }, },
		--cast_level = 0,
		--odds = 50,
	--}
	if(self.selected_items)then
		local item = self.selected_items[self.selected_index];
		if(item)then
			local exID = item.exID;
			local exinfo = item.exinfo;
			local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exID);
			if(exTemplate)then
				local cast_level = self.GetCastLevel();
				local odds = self.GetOdds(cast_level);
				
				local cast_next_level;
				local odds_next_level;
				if(cast_level)then
					cast_next_level = cast_level + 1
					odds_next_level = self.GetOdds(cast_next_level);
				end
				local msg = {
					exID = exID,
					gsids = exTemplate.froms,
					exchanged_gsids = exTemplate.tos,
					cast_level = cast_level,
					odds = odds,
					cast_next_level = cast_next_level,
					odds_next_level = odds_next_level,
					state = "all",
					exinfo = exinfo,
				}
				commonlib.echo("=========================RedLeaf_panel.BindFramePage");
				commonlib.echo(msg);
				MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.Bind(msg);
			end
			
		end
	end
	
end
--获取建造技能级别
function RedLeaf_panel.GetCastLevel()
	if(MyCompany.Aries.Quest.NPCs.CastSkillHitBoard.HasLevel_4())then
		return 4;
	elseif(MyCompany.Aries.Quest.NPCs.CastSkillHitBoard.HasLevel_3())then
		return 3;
	elseif(MyCompany.Aries.Quest.NPCs.CastSkillHitBoard.HasLevel_2())then
		return 2;
	elseif(MyCompany.Aries.Quest.NPCs.CastSkillHitBoard.HasLevel_1())then
		return 1;
	end
	return 0;
end
--设置建造的级别 0--4
function RedLeaf_panel.SetPageState(state)
	local self = RedLeaf_panel;
	self.page_state = state or 0;
	if(self.page_state < 0)then
		self.page_state = 0;
	end
end
--获取概率
function RedLeaf_panel.GetOdds(level)
	local self = RedLeaf_panel;
	local state = self.page_state;
	if(level and state)then
		local odds = self.static_odds[level + 1];
		if(odds)then
			odds = odds[state + 1];
			return odds;
		end
	end
end
function RedLeaf_panel.DoBuild()
	local self = RedLeaf_panel;
	NPL.load("(gl)script/apps/Aries/NPCs/Commons/SingleExtend.lua");
	local item = self.selected_items[self.selected_index];
	if(item)then
		local exID = item.exID;
		local req_num = item.req_num;
		local name = item.name;
		local msg = {
			req_num = req_num,
			exID = exID,
			ex_name = name,
		}
		MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg,function()
			self.ClosePage();
			self.ShowPage();
		end);
	end
end
