--[[
Title: DongDong
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/SnowArea/30346_DongDong.lua
------------------------------------------------------------
]]

-- create class
local libName = "DongDong";
local DongDong = {
	questions = {
		{ label = "保护水环境，我们应该选择使用（）洗衣粉", option = { a = "普通", b = "无磷", c = "廉价", d = "高价", }, answer = "b", },
		
		{ label = "一只燕子仅一个夏季就能捕捉（）只苍蝇、蚊子，对控制疾病有重要作用。", option = { a = "80万", b = "100万", c = "120万", d = "140万", }, answer = "c", },
		
		{ label = "下列哪些做法是正确的（）。 ", option = { a = "公路边种莱", b = "不要饮用新鲜茶叶", c = "儿童吃过多鱼松", }, answer = "b", },
		
		{ label = "居室中什么地方污染最重（）。", option = { a = "卧室 ", b = "客厅", c = "厨房", d = "洗手间", }, answer = "c", },
		
		{ label = "绿色食品指什么食品？（）", option = { a = "蔬菜，水果", b = "绿颜色的食品", c = "安全无污染食品", d = "有丰富营养价值的食品", }, answer = "c", },
		
		{ label = "为保护蓝天，我们在出门时，应该()。 ", option = { a = "尽量选择乘坐舒适的交通工具", b = "使用私人车", c = "尽量选择乘坐公共交通工具", }, answer = "c", },
		
		{ label = "我们常说的噪声污染是指（）", option = { a = "90dB以上", b = "80dB以上 ", c = "50dB以上",}, answer = "b", },
		
		{ label = "减少“白色污染”我们应该（）", option = { a = "自觉地不用、少用难降解的塑料包装袋", b = "乱扔塑料垃圾", c = " 尽量使用塑料制品", }, answer = "a", },
		
		{ label = "使用复印机时，复印机的带高电压的部件与空气进行化学反应产生的臭氧（）", option = { a = "没有影响", b = "对人体健康有害", c = "对人体健康有益", }, answer = "b", },
		
		{ label = "以下说那种是错误的：（）", option = { a = "三个废餐盒可以做一把学生用尺", b = "废易拉罐溶解后可以100%的无数次循环再造成新罐", c = " 废玻璃无法回收利用", }, answer = "c", },
		
		{ label = "下列自然资源中, 属于非可再生自然资源的是（）", option = { a = "水", b = "石油 ", c = "森林", d = "土地", }, answer = "d", },
		
		{ label = "地球上的水, 绝大部分分布在（）", option = { a = "海洋", b = "湖泊", c = "河流", d = "冰川", }, answer = "a", },
		
		{ label = "不属于造成水体污染原因的是（）", option = { a = "工业废水", b = "生活污水", c = "旅运、水运", d = "大气降水", }, answer = "c", },
		
		{ label = "世界上最大的热带雨林区为（）", option = { a = "亚马逊河流域", b = "刚果盆地", c = "中国云南", d = "西西伯利亚平原", }, answer = "a", },
		
		{ label = "世界环境日为每年几月几日?（）", option = { a = "5月6日", b = "3月21日", c = "12月1日", d = " 6月5日", }, answer = "d", },
		
		{ label = "世界野生生物基金会的会徽是（）。", option = { a = "丹顶鹤", b = "大熊猫", c = "骆驼", }, answer = "b", },
		
		{ label = "天山雪莲素有（）之称，因其药用价值而大量被盗挖，已濒临灭绝。 ", option = { a = "雪山花王", b = "雪山之花", c = "雪山之最", }, answer = "a", },
		
		{ label = "环境污染不仅给人类的健康带来危害，而且还具有（）作用。", option = { a = "遗传", b = "传染", c = "破坏",}, answer = "a", },
		
		{ label = "因空气污染引起的酸性降水被称为（）。", option = { a = "酸水", b = "酸雨", c = "酸雾", }, answer = "b", },
		
		{ label = "清洁能源有哪些：（）。", option = { a = "核能、太阳能、地热能", b = "生物能、太阳能和地热能", c = "太阳能、潮汐能、生物能",}, answer = "b", },
		
		{ label = "噪声是（）的祸根。", option = { a = "高血压", b = "冠心病", c = "中风", }, answer = "a", },
		
	},
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.DongDong", DongDong);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- DongDong.main
function DongDong.main()
	local self = DongDong; 
end

function DongDong.PreDialog(npc_id, instance)
	local self = DongDong; 

end
-----------------------------------------
--[[
获取环保小屋的逻辑
获取天然水晶 顺序固定
1 从冬冬获取 第一块天然水晶
2 从白天鹅获取 第二块天然水晶
3 从帕帕获取 第三块天然水晶
--]]
-----------------------------------------
--是否已经拥有环保小屋
function DongDong.HasNaturalHouse()
	local self = DongDong;
	return hasGSItem(30180);
end
function DongDong.HasNaturalCrystal_1()
	local self = DongDong;
	if(self.GetNaturalCrystal() == 1)then
		return true;
	end
end
function DongDong.HasNaturalCrystal_2()
	local self = DongDong;
	if(self.GetNaturalCrystal() == 2)then
		return true;
	end
end
function DongDong.HasNaturalCrystal_3()
	local self = DongDong;
	if(self.GetNaturalCrystal() == 3)then
		return true;
	end
end
function DongDong.GetNaturalCrystal()
	local self = DongDong;
	local __,__,__,copies = hasGSItem(17112);
	copies = copies or 0;
	return copies;
end
--回答是否正确
function DongDong.IsCorrectAnswer(sName)
	local self = DongDong;
	if(sName and self.page and self.cur_question)then
		local answer = self.page:GetValue(sName);
		if(answer and answer == self.cur_question.answer)then
			return true;
		end
	end
end
-- get a question from libs
function DongDong.Get_Question()
	local self = DongDong;
	local libs = self.questions;
	if(libs)then
		local len = #libs;
		local index = math.random(len);
		return libs[index];
	end
end
function DongDong.GiveNaturalCrystal_1()
	local self = DongDong;
	if(not self.HasNaturalCrystal_1())then
		self.GiveNaturalCrystal();
	end
end
function DongDong.GiveNaturalCrystal_2()
	local self = DongDong;
	if(not self.HasNaturalCrystal_2())then
		self.GiveNaturalCrystal();
	end
end
function DongDong.GiveNaturalCrystal_3()
	local self = DongDong;
	if(not self.HasNaturalCrystal_3())then
		self.GiveNaturalCrystal();
	end
end
function DongDong.GiveNaturalCrystal()
	local self = DongDong;
	ItemManager.PurchaseItem(17112, 1, function(msg) end, function(msg)
    end);
end
