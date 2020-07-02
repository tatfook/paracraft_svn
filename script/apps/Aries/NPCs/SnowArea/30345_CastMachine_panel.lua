--[[
Title: CastMachine_panel
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------

NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/30345_CastMachine_panel.lua");
MyCompany.Aries.Quest.NPCs.CastMachine_panel.ShowPage();


NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/30345_CastMachine_panel.lua");
MyCompany.Aries.Quest.NPCs.CastMachine_panel.ToXml()
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/30345_CastMachine_compose_frame.lua");
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/30347_CastSkillHitBoard.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");

-- create class
local libName = "CastMachine_panel";
local CastMachine_panel = {
	selected_index = nil,
	page_state = 0,
	selected_items = nil,
	
	static_odds = {
		{50,20,5,2,1},
		{80,50,15,5,2},
		{100,75,50,15,5},
		{100,90,75,50,10},
		{100,100,100,80,50},
    },
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.CastMachine_panel", CastMachine_panel);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function CastMachine_panel.ToXml()
	local self = CastMachine_panel;
	if(self.Items)then
		local all_str = "";
		local k,v;
		for k,v in ipairs(self.Items) do
			if(k < 100)then
				local kk,node;
				for kk,node in ipairs(v) do
					local label = node.name;
					local id = node.gsid;
					local exid = node.exID;
					local isnew = node.isNew;
					isnew = tostring(isnew);
					if(isnew == "nil")then
						isnew = "";
					end
					local level = k - 1;
					local s = string.format([[<item><id>%d</id><label>%s</label><exid>%d</exid><isnew>%s</isnew><level>%d</level><desc /></item>]],id,label,exid,isnew,level);
					all_str = all_str .. s;
				end
			end
		end
		all_str = string.format("<items>%s</items>",all_str);
		local output_path = "config/Aries/Quests/client_exchange_item_list.xml";
		ParaIO.CreateDirectory(output_path);
		local file = ParaIO.open(output_path, "w");
		if(file:IsValid()) then
			file:WriteString(all_str);
			file:close();
		end
		_guihelper.MessageBox("生成成功："..output_path);
	end
end
CastMachine_panel.Items = {
	--初级
	[1] = {
		{name = "字母E",exID = 729, gsid = 30202,  isNew = true, },

		{name = "蟹壳钢琴",exID = 477, gsid = 30187,  },
		{name = "时光沙漏",exID = 475, gsid = 30185,  },
		
		{name = "丛丛草",exID = 221, gsid = 30026, },
		{name = "不倒翁",exID = 438, gsid = 30102,  },
		{name = "晃晃木马",exID = 439, gsid = 30101,  },
		{name = "向日葵抱枕",exID = 431, gsid = 30166, },
		{name = "荷叶抱枕",exID = 432, gsid = 30167,  },
		{name = "大叶子靠枕",exID = 433, gsid = 30168, },
		
		{name = "巧克力花圃",exID = 397, gsid = 30136, },
		{name = "奶酪复古电话",exID = 398, gsid = 30137, },
		{name = "孔方挂饰",exID = 384, gsid = 30120, },
		{name = "长寿椅",exID = 341, gsid = 30109, },
		{name = "工夫茶几",exID = 344, gsid = 30112,},
		{name = "水蓝栅栏",exID = 216, gsid = 30021, },
		{name = "水蓝小栅栏",exID = 217, gsid = 30022, },
		{name = "棕色栅栏",exID = 218, gsid = 30033, },
		{name = "棕色小栅栏",exID = 219, gsid = 30042, },
		{name = "青草垛",exID = 220, gsid = 30025, },
		{name = "树墩墩",exID = 222, gsid = 30030, },
		{name = "小红花凳",exID = 223, gsid = 30032, },
		{name = "花圃",exID = 224, gsid = 30012, },
	},
	--1 级
	[2] = {
		{name = "字母F",exID = 731, gsid = 30203,  isNew = true, },
		{name = "字母G",exID = 730, gsid = 30204,  isNew = true, },

		{name = "梦香床",exID = 434, gsid = 30169, },
		{name = "橘子糖挂钟",exID = 399, gsid = 30138, },
		{name = "草莓地毯",exID = 400, gsid = 30139, },
		{name = "红鳞金鱼挂饰",exID = 385, gsid = 30119, },
		{name = "绿鳞金鱼挂饰",exID = 386, gsid = 30118, },
		{name = "炫彩陶罐",exID = 342, gsid = 30110,  },
		{name = "竹子栅栏",exID = 225, gsid = 30052, },
		{name = "黄色幸福石",exID = 226, gsid = 30034, },
		{name = "绿色生命石",exID = 227, gsid = 30035, },
		{name = "橙色力量石",exID = 228, gsid = 30036, },
		{name = "紫色魅力石",exID = 229, gsid = 30037, },
		{name = "红色爱心石",exID = 230, gsid = 30038, },
		{name = "蓝色智慧石",exID = 231, gsid = 30039, },
		{name = "白色未来石",exID = 232, gsid = 30040, },
		{name = "青青小石椅",exID = 233, gsid = 30067, },
		{name = "青青小石凳",exID = 234, gsid = 30068, },
		{name = "冰雪花圃",exID = 235, gsid = 30013, },
	},
	[3] = {
		{name = "洗碗台",exID = 751, gsid = 30237,  isNew = true, },
		{name = "字母C",exID = 733, gsid = 30200,  isNew = true, },
		{name = "字母D",exID = 732, gsid = 30201,  isNew = true, },

		{name = "泡泡机",exID = 238, gsid = 30050, },
		{name = "水泡大吊灯",exID = 476, gsid = 30186,  },
		{name = "藤蔓浴缸",exID = 435, gsid = 30170, },
		{name = "拐棍糖秋千",exID = 401, gsid = 30140, },
		{name = "玲珑宫灯",exID = 339, gsid = 30107, },
		{name = "小花鼓",exID = 340, gsid = 30108,  },
		{name = "石雕狮子",exID = 345, gsid = 30113, },
		{name = "石边花盆",exID = 297,gsid = 30103,},--297 30103
		{name = "泡泡池塘",exID = 236, gsid = 30028, },
		{name = "紫藤萝栅栏",exID = 237, gsid = 30053, },
		{name = [[“哈”字气球]],exID = 239, gsid = 30043, },
		{name = [[“奇”字气球]],exID = 240, gsid = 30044, },
		{name = [[“小”字气球]],exID = 241, gsid = 30045, },
		{name = [[“镇”字气球]],exID = 242, gsid = 30046, },
		{name = [[“欢”字气球]],exID = 243, gsid = 30047, },
		{name = [[“迎”字气球]],exID = 244, gsid = 30048, },
		{name = [[“你”字气球]],exID = 245, gsid = 30049, },
		{name = "遮阳伞",exID = 246, gsid = 30088, },
		--247
		{name = "四平八稳冰砖",exID = 248, gsid = 30090, },
		{name = "尖尖冰砖",exID = 249, gsid = 30091, },
		{name = "冰雕心语",exID = 250, gsid = 30059, },
		{name = "冰雕礼盒",exID = 251, gsid = 30060, },
		{name = "青青小石桌",exID = 252, gsid = 30066, },
		{name = "短腿小沙发",exID = 253, gsid = 30085, },
		{name = "短腿小茶几",exID = 254, gsid = 30084, },
		{name = "三层小柜",exID = 255, gsid = 30087, },
	},
	[4] = {
		{name = "字母A",exID = 734, gsid = 30198,  isNew = true, },
		{name = "字母B",exID = 735, gsid = 30199,  isNew = true, },

		{name = "能量池",exID = 478, gsid = 30184, },
		{name = "魔方奶酪床",exID = 402, gsid = 30141, },
		{name = "七彩伞",exID = 298, gsid = 30104, },--298 30104
		{name = "逗逗雪人",exID = 256, gsid = 30069, },
		{name = "丫丫雪人",exID = 257, gsid = 30070, },
		{name = "妮妮雪人",exID = 258, gsid = 30071, },
		{name = "乐乐雪人",exID = 259, gsid = 30072, },
		{name = "大红花凳",exID = 260, gsid = 30092, },
		{name = "古井木桶",exID = 261, gsid = 30058, },
		{name = "冰晶树",exID = 262, gsid = 30078, },
		{name = "雪绒花地毯",exID = 263, gsid = 30081, },
		{name = "毛线娃娃",exID = 264, gsid = 30082, },
		{name = "灯笼花",exID = 265, gsid = 30024, },
		{name = "靓靓衣橱",exID = 266, gsid = 30086, },
		{name = "暖暖雪绒床",exID = 267, gsid = 30083, },
		{name = "许愿灯",exID = 268, gsid = 30095, },
	},
	[5] = {
		{name = "字母X",exID = 736, gsid = 30221,  isNew = true, },
		{name = "字母Y",exID = 737, gsid = 30222,  isNew = true, },

		{name = "檀香木床",exID = 346, gsid = 30114, },
		{name = "七彩树",exID = 299 , gsid = 30105,},--299 30105
		{name = "海苔冰灯",exID = 269, gsid = 30080, },
		{name = "冰晶烛台",exID = 270, gsid = 30079, },
		{name = "晃晃稻草人",exID = 271, gsid = 30065, },
	},
	[100] = {
		{name = "糖果小屋",exID = 597, gsid = 30135, },
		{name = "环保小屋",exID = 437, gsid = 30180, },
		{name = "新春小屋",exID = 300, gsid = 30007, },
		{name = "冰雪小屋",exID = 167, gsid = 30006, },
	},
	[101] = {
		{name = "简易捕兽网",exID = 318, gsid = 17079, },
		{name = "1级捕兽网",exID = 319, gsid = 17080, },
		{name = "2级捕兽网",exID = 320, gsid = 17081, },
		{name = "3级捕兽网",exID = 321, gsid = 17082, },
	},
}
function CastMachine_panel.DS_Func_CastMachine_panel(index)
	local self = CastMachine_panel;
	if(not self.selected_items)then return 0 end
	if(index == nil) then
		return #(self.selected_items);
	else
		return self.selected_items[index];
	end
end
function CastMachine_panel.OnInit()
	local self = CastMachine_panel; 
	self.page = document:GetPageCtrl();
end
function CastMachine_panel.DoClick(index)
	local self = CastMachine_panel; 
	self.selected_index = index;
	self.BindFramePage()
	self.RefreshPage();
end
function CastMachine_panel.ChangeState(index)
	local self = CastMachine_panel;
	index = tonumber(index); 
	if(not index)then return end
	self.page_state = index or 0;
	self.selected_index = 1;
	self.selected_items = self.Items[index + 1];
	
	self.BindFramePage()
	self.RefreshPage();	
end
function CastMachine_panel.ShowPage()
	local self = CastMachine_panel;
	self.Reset();
	self.BindFramePage();
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/SnowArea/30345_CastMachine_panel.html", 
			name = "CastMachine_panel.ShowPage", 
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
function CastMachine_panel.Reset()
	local self = CastMachine_panel;
	self.page_state = 0;
	self.selected_index = 1;
	self.selected_items = self.Items[1];
end
function CastMachine_panel.ClosePage()
	local self = CastMachine_panel;
	if(self.page)then
		self.page:CloseWindow();
	end
end
function CastMachine_panel.RefreshPage()
	local self = CastMachine_panel;
	if(self.page)then
		self.page:Refresh(0.01);
	end
end
--刷新frame
function CastMachine_panel.BindFramePage()
	local self = CastMachine_panel;
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
				}
				MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.Bind(msg);
			end
			
		end
	end
	
end
--获取建造技能级别
function CastMachine_panel.GetCastLevel()
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
function CastMachine_panel.SetPageState(state)
	local self = CastMachine_panel;
	self.page_state = state or 0;
	if(self.page_state < 0)then
		self.page_state = 0;
	end
end
--获取概率
function CastMachine_panel.GetOdds(level)
	local self = CastMachine_panel;
	local state = self.page_state;
	if(level and state)then
		local odds = self.static_odds[level + 1];
		if(odds)then
			odds = odds[state + 1];
			return odds;
		end
	end
end
--开始建造
function CastMachine_panel.DoBuild()
	local self = CastMachine_panel;
	local canBuild = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.CanBuild()
	--缺少物品
	if(not canBuild)then
		local s = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.Error_NeedItems();
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return;
	end
	local exchanged_item_gsid = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.exchanged_item_gsid;
	if(not exchanged_item_gsid)then return end
	--local __,__,__,copies = hasGSItem(exchanged_item_gsid);
	local copies = ItemManager.GetGSItemTotalCopiesInMemory(exchanged_item_gsid);
	copies = copies or 0;
	commonlib.echo("=====copies");
	commonlib.echo(copies);
	--超过最大数
	if(copies >= 100)then
		local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>别再做这个啦，你家仓库都放不下了！先去送点给别人再来做吧！</div>";
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return
	end
	--概率小于100
	local odds = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.odds or 0;
	if(odds < 100)then
		local level = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.cast_level;
		local title = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.exchanged_item_name;
		local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>抱抱龙当前%d级建造技能，建造%s的成功率为%d%%；如果失败，用于建造的材料也将损坏哦，现在就开始建造吗？</div>",
								level,title,odds)
		_guihelper.Custom_MessageBox(s,function(result)
				if(result == _guihelper.DialogResult.Yes)then
					self.__DoBuild();
				else
					commonlib.echo("no");
				end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Cancel_32bits.png; 0 0 153 49"});
		return
	end
	self.__DoBuild();
end
function CastMachine_panel.__DoBuild()
	local self = CastMachine_panel;
	local item = self.selected_items[self.selected_index];
	if(item)then
		local exID = item.exID;
		if(not exID or exID == "")then return end
		commonlib.echo("=========start build");
		commonlib.echo(item);
		ItemManager.ExtendedCost(exID, nil, nil, function(msg)end, function(msg) 
			commonlib.echo("=========after build");
			commonlib.echo(msg);
			--obtains={ [17034]=1 , [-4] = 2},
			--gsid  -1:P币；0:E币；-2:亲密度；-3:爱心值；-4:力量值；-5:敏捷值；-6:智慧值；-7:建筑熟练度
			self.ClosePage();
			if(msg and msg.issuccess)then
				if(msg.obtains)then
					self.__DoBuild__(msg.obtains)
				end
			end
		end);
	end
end
function CastMachine_panel.__DoBuild__(obtains)
	local self = CastMachine_panel;
	local gsid = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.exchanged_item_gsid;
	--失败
	if(not obtains[gsid])then
		local title = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.exchanged_item_name;
		local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>很遗憾，本次%s建造失败了；你可以多试几次，或先把抱抱龙建造技能提升后再来建造！ </div>",
						title);
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return
	end
	local ex_str = "";
	local t = "";
	local ex_num = 0;
	if(obtains[-4])then
		t = "力量值";
		ex_num = obtains[-4];
	elseif(obtains[-6])then
		t = "智慧值";
		ex_num = obtains[-6];
	end
	if(ex_num > 0)then
		ex_str = string.format("并且获得%d点%s。",ex_num,t);
	end
	local title = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.exchanged_item_name;
	local skill = obtains[-7];
	local s = string.format("<div style='margin-left:15px;margin-top:10px;text-align:center'>%s建造成功！抱抱龙提升了%d点建造熟练度；%s建造出的%s是让莫卡帮你出售，还是放回自己仓库呢？</div>",
								title,skill,ex_str,title); 
	-- 通知任务完成一次合成
	local command = System.App.Commands.GetCommand("Aries.Quest.DoAddValue");
	if(command) then
		command:Call({
			increment = { { id = gsid, value = 1}, },
		});
	end
		_guihelper.Custom_MessageBox(s,function(result)
				if(result == _guihelper.DialogResult.Yes)then
					self.DoSell();
				else
					--默认已经放回仓库
				end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/Sell_btn_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/BackToLib_btn_32bits.png; 0 0 153 49"});
end
--出售
function CastMachine_panel.DoSell()
	local title = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.exchanged_item_name;
	local gsid = MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame.exchanged_item_gsid;
	local __,guid,__,__ = hasGSItem(gsid,nil,10001);
	if(not guid)then return end
	commonlib.echo("=====before sell item");
	commonlib.echo(guid);
	ItemManager.SellItem(guid, 1, function(msg) end,function(msg)
		commonlib.echo("=====after sell item");
		commonlib.echo(guid);
		commonlib.echo(msg);
		if(msg and msg.issuccess)then
			local price = msg.deltaemoney or 0;
			local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'> 莫卡已经成功帮你把%s出售啦，当前市场价为%d奇豆！ 快快让你的抱抱龙多做点家装吧，其他的小哈奇都抢着购买呢！</div>",
							title,price);
			_guihelper.Custom_MessageBox(s,function(result)
				
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		end
	end)
	
end