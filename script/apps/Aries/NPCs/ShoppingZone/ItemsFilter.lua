--[[
Title: 
Author(s): WD
Date: 2011/12/21
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/ItemsFilter.lua");
------------------------------------------------------------
]]


local ItemsFilter = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.ItemsFilter");
local TEEN_VERSION = if_else(System.options.version == "teen",true,false)

if(not TEEN_VERSION)then
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/ItemsConsignment.kids.lua");
else
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/ItemsConsignment.lua");
end

local ItemsConsignment = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.ItemsConsignment");
NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");
local GenericTooltip = CommonCtrl.GenericTooltip:new();
local MSG = _guihelper.MessageBox
local echo = commonlib.echo

 
if(TEEN_VERSION)then
ItemsFilter.filter_list =  {
	{name="item", attr={text="全部",code = 1, is_expanded=true},},

	--装备
	{name="typ", attr={text="装备",code = 2,class=1,is_expanded=false},
		{name="typ",attr={text="武器",code = 100,class=1,subclass={10,11},is_expanded=false},
			{name="item",attr={text="副手",code = 1001,class=1,subclass=10,is_expanded=false},},
			{name="item",attr={text="主手",code = 1003,class=1,subclass=11,is_expanded=false},},
		},
		{name="typ",attr={text="服装",code = 22,class=1,subclass={2,3,4,5,6,7,8,9,12},is_expanded=false},
			{name="item",attr={text="帽子",code = 221,class=1,subclass=2,is_expanded=false},},
			{name="item",attr={text="面具",code = 223,class=1,subclass=3,is_expanded=false},},
			--{name="item",attr={text="4",code = 225,class=1,subclass=4,is_expanded=false},},
			{name="item",attr={text="衣服",code = 227,class=1,subclass=5,is_expanded=false},},
			{name="item",attr={text="裤子",code = 229,class=1,subclass=6,is_expanded=false},},
			{name="item",attr={text="鞋子",code = 231,class=1,subclass=7,is_expanded=false},},
			{name="item",attr={text="披风",code = 233,class=1,subclass=8,is_expanded=false},},
			{name="item",attr={text="手套",code = 235,class=1,subclass=9,is_expanded=false},},
			{name="item",attr={text="护腕",code = 237,class=1,subclass=12,is_expanded=false},},
		},
		{name="typ",attr={text="饰品",code = 4,class=1,subclass={14,15,16,17},is_expanded=false},
			{name="item",attr={text="耳环",code = 239,class=1,subclass=14,is_expanded=false},},
			{name="item",attr={text="手镯",code = 241,class=1,subclass=15,is_expanded=false},},
			{name="item",attr={text="戒指",code = 243,class=1,subclass=16,is_expanded=false},},
			{name="item",attr={text="项链",code = 245,class=1,subclass=17,is_expanded=false},},
		},
		{name="typ",attr={text="炫彩",code = 6,class=1,subclass={18,19,70,71},is_expanded=false},
			{name="item",attr={text="帽子",code = 2319,class=1,subclass=18,is_expanded=false},},
			{name="item",attr={text="衣服",code = 2411,class=1,subclass=19,is_expanded=false},},
			{name="item",attr={text="披风",code = 2413,class=1,subclass=70,is_expanded=false},},
			{name="item",attr={text="鞋子",code = 2415,class=1,subclass=71,is_expanded=false},},
		},
	},
	--符文
	{name="typ",attr={text="符文",code = 8,class=18,subclass=2,is_expanded=false},
		{name="item",attr={text="生命系",code = 81,class=18,subclass=2,is_expanded=false}},
		{name="item",attr={text="烈火系",code = 83,class=18,subclass=2,is_expanded=false},},
		{name="item",attr={text="寒冰系",code = 85,class=18,subclass=2,is_expanded=false},},
		{name="item",attr={text="死亡系",code = 87,class=18,subclass=2,is_expanded=false},},
		{name="item",attr={text="风暴系",code = 89,class=18,subclass=2,is_expanded=false},},
		{name="item",attr={text="平衡系",code = 91,class=18,subclass=2,is_expanded=false},},
		{name="item",attr={text="大地系",code = 93,class=18,subclass=2,is_expanded=false},},
	},

	--消耗品
	{name="typ", attr={text="消耗品",code = 10,class={3,100},subclass={14,10,1}, is_expanded=false},
		{name="item",attr={text="技能卷",code = 101,class=3,subclass=14,is_expanded=false},},
		{name="item",attr={text="药丸",code = 103,keywords="药丸",class=3,subclass=10,is_expanded=false},},
		{name="item",attr={text="食物",code = 105,class=3,subclass=10,is_expanded=false},},
		{name="item",attr={text="能量石",code = 107,class=100,subclass=1,is_expanded=false},},
	},

	--宝石
	{name="typ", attr={text="宝石",code = 12,class=3,subclass={6,7}, is_expanded=false},
		{name="item",attr={text="一级宝石",code = 121,keywords="1级",class=3,subclass=6,is_expanded=false},},
		{name="item",attr={text="二级宝石",code = 123,keywords="2级",class=3,subclass=6,is_expanded=false},},
		{name="item",attr={text="三级宝石",code = 125,keywords="3级",class=3,subclass=6,is_expanded=false},},
		{name="item",attr={text="四级宝石",code = 127,keywords="4级",class=3,subclass=6,is_expanded=false},},
		{name="item",attr={text="五级宝石",code = 129,keywords="5级",class=3,subclass=6,is_expanded=false},},
		{name="item",attr={text="其他",code = 131,class=3,subclass=7,is_expanded=false},},
	},

	{name="typ", attr={text="材料",code = 14,class=3, subclass={2,4},is_expanded=false},
		--[[{name="typ",attr={text="墨水",code = 141,class=3,subclass={2,4},is_expanded=false},
		{name="item",attr={text="墨水",code = 1411,class=3,subclass=2,is_expanded=false},},
		{name="item",attr={text="其他",code = 14111,class=3,subclass=4,is_expanded=false},},		
		},
		{name="typ",attr={text="矿石",code = 143,class=3,subclass={2,4},is_expanded=false},
		{name="item",attr={text="矿石",code = 1431,class=3,subclass=2,is_expanded=false},},		
		{name="item",attr={text="其他",code = 14311,class=3,subclass=4,is_expanded=false},},		
		},
		{name="typ",attr={text="草药",code = 145,class=3,subclass={2,4},is_expanded=false},
		{name="item",attr={text="草药",code = 1415,class=3,subclass=2,is_expanded=false},},
		{name="item",attr={text="其他",code = 14115,class=3,subclass=4,is_expanded=false},},		
		},
		{name="typ",attr={text="结晶",code = 147,class=3,subclass={2,4},is_expanded=false},
		{name="item",attr={text="结晶",code = 14715,class=3,subclass=2,is_expanded=false},},
		{name="item",attr={text="其他",code = 147115,class=3,subclass=4,is_expanded=false},},	
		},
		{name="typ",attr={text="食材",code = 149,class=3,subclass={2,4},is_expanded=false},
		{name="item",attr={text="食材",code = 149715,class=3,subclass=2,is_expanded=false},},
		{name="item",attr={text="其他",code = 1497115,class=3,subclass=4,is_expanded=false},},
		},]]
		{name="item",attr={text="合成材料",code = 149715,class=3,subclass=2,is_expanded=false},},
		{name="item",attr={text="其他",code = 1497115,class=3,subclass=4,is_expanded=false},},
	},
	{name="typ", attr={text="坐骑",code = 16,class=2,subclass={6,8}, is_expanded=false},
		{name="item",attr={text="坐骑",code = 91,class=2,subclass=6,is_expanded=false},},
		{name="item",attr={text="坐骑变身药丸",code = 93,class=2,subclass=8,is_expanded=false},},
	},
	{name="typ", attr={text="兑换物",code = 18,class=3,subclass={5,8},is_expanded=false},
		{name="item",attr={text="兑换物",code = 181,class=2,subclass=5,is_expanded=false},},
		{name="item",attr={text="兑换物标记",code = 183,class=2,subclass=8,is_expanded=false},},
	},
	{name="item", attr={text="杂物",code = -1,is_expanded=false},},
};

else

ItemsFilter.filter_list = ItemsFilter.filter_list or {
--{name="typ",attr={text="宝石",code = 6,class=3,subclass=6,is_expanded=false},
	--{name="item",attr={text="1级宝石",code = 62, keywords="1级", class=3,subclass=6,is_expanded=false},},
	--{name="item",attr={text="2级宝石",code = 64, keywords="2级", class=3,subclass=6,is_expanded=false},},
	--{name="item",attr={text="3级宝石",code = 63, keywords="3级", class=3,subclass=6,is_expanded=false},},
--},
--{name="typ",attr={text="兑换品",code = 3,class=3,subclass=6,is_expanded=false},
	----{name="item", attr={text="4级玄玉",code = 31, keywords="4级", class=3,subclass=8,is_expanded=false},},
	----{name="item", attr={text="5级玄玉",code = 32, keywords="5级", class=3,subclass=8,is_expanded=false},},
	--{name="item",attr={text="仙豆口袋",code = 35, keywords="仙豆口袋",  class=3,subclass=9,is_expanded=false},},
	--{name="item",attr={text="能量石",code = 37, class=100,subclass=1,is_expanded=false},},
	--{name="item", attr={text="火玉",code = 33, keywords="火玉", class=3,subclass=8,is_expanded=false},},
	--{name="item",attr={text="甜甜圈",code = 34, keywords="甜甜圈",  class=3,subclass=4,is_expanded=false},},
	--{name="item", attr={text="全部货币",code = 36, class=3,subclass=8,is_expanded=false},},
--},
--{name="typ", attr={text="武器",code = 7,class=1, subclass=11, is_expanded=false},
	--{name="item", attr={text="全部",code = 71,class=1, subclass=11, is_expanded=false},},
	--{name="item", attr={text="精良", keywords="精良",  code = 72,class=1, subclass=11, is_expanded=false},},
	--{name="item", attr={text="传说", keywords="传说",  code = 73,class=1, subclass=11, is_expanded=false},},
--},
--{name="typ", attr={text="合成",code = 8,class=3, subclass=21, is_expanded=false},
	---- {name="item", attr={text="激怒卡", keywords="激怒", code = 81,class=3, subclass=21, is_expanded=false},},
	--{name="item", attr={text="灵魂碎片", code = 82,class=3, subclass=23, is_expanded=false},},
	--{name="item", attr={text="魂珠", code = 83,class=3, subclass=22, is_expanded=false},},
--},
--{name="typ", attr={text="魂印",code = 2,class=3, subclass=21, is_expanded=false},
	--{name="item", attr={text="全部",code = 200, class=3, subclass=21, is_expanded=false},},
	--{name="item", attr={text="1阶",code = 201, keywords="1",  class=3, subclass=21, is_expanded=false},},
	--{name="item", attr={text="2阶",code = 202, keywords="2",  class=3, subclass=21, is_expanded=false},},
	--{name="item", attr={text="3阶",code = 203, keywords="3",  class=3, subclass=21, is_expanded=false},},
	--{name="item", attr={text="4阶",code = 204, keywords="4",  class=3, subclass=21, is_expanded=false},},
	--{name="item", attr={text="5阶",code = 205, keywords="5",  class=3, subclass=21, is_expanded=false},},
	--{name="item", attr={text="6阶",code = 206, keywords="6",  class=3, subclass=21, is_expanded=false},},
	--{name="item", attr={text="7阶",code = 207, keywords="7",  class=3, subclass=21, is_expanded=false},},
	--{name="item", attr={text="8阶",code = 208, keywords="8",  class=3, subclass=21, is_expanded=false},},
	--{name="item", attr={text="9阶",code = 209, keywords="9",  class=3, subclass=21, is_expanded=false},},
	--{name="item", attr={text="10阶",code = 210, keywords="10",  class=3, subclass=21, is_expanded=false},},
--},
--{name="item",attr={text="镶嵌符",code = 65, class=3,subclass=7,is_expanded=false},},
--{name="item", attr={text="符文卡牌",code = 4, class=18,subclass=2,is_expanded=false},},
--{name="item", attr={text="坐骑",code = 9, class=2,subclass=6,is_expanded=false},},
--{name="item",attr={text="宠物口粮",code = 513, keywords="口粮",  class=3,subclass=4,is_expanded=false},},
--{name="item", attr={text="珍惜品",code = 515,class=3, subclass=9, is_expanded=false},},
--{name="item",attr={text="药丸&门票",code = 53, class=3,subclass=10,is_expanded=false},},
--{name="item",attr={text="其他",code = 514, class=3,subclass=4,is_expanded=false},},

{name="typ",attr={text="卡牌交易",code = 4,class=18,subclass=1,is_expanded=false},
	{name="item",attr={text="生命系",code = 41, class=18,subclass=1,is_expanded=false},},
	{name="item",attr={text="烈火系",code = 42, class=18,subclass=1,is_expanded=false},},
	{name="item",attr={text="寒冰系",code = 43, class=18,subclass=1,is_expanded=false},},
	{name="item",attr={text="死亡系",code = 44, class=18,subclass=1,is_expanded=false},},
	{name="item",attr={text="风暴系",code = 45, class=18,subclass=1,is_expanded=false},},
	{name="item",attr={text="通用",  code = 46, class=18,subclass=1,is_expanded=false},},
},
{name="typ",attr={text="货币交易",code = 3,class=3,subclass=6,is_expanded=false},
	{name="item",attr={text="晶石货币",code = 38, keywords="晶石",  class=3,subclass=9,is_expanded=false},},
	{name="item",attr={text="仙豆口袋",code = 35, keywords="仙豆口袋",  class=3,subclass=9,is_expanded=false},},
	{name="item",attr={text="能量石",code = 37, class=100,subclass=1,is_expanded=false},},
	{name="item", attr={text="火玉",code = 33, keywords="火玉", class=3,subclass=8,is_expanded=false},},
	{name="item",attr={text="甜甜圈",code = 34, keywords="甜甜圈",  class=3,subclass=4,is_expanded=false},},
	{name="item", attr={text="其他货币",code = 36, class=3,subclass=8,is_expanded=false},},
},

{name="typ", attr={text="武器交易",code = 7,class=1, subclass=11, is_expanded=false},
	{name="item", attr={text="全部",code = 71,class=1, subclass=11, is_expanded=false},},
	{name="item", attr={text="精良", keywords="精良",  code = 72,class=1, subclass=11, is_expanded=false},},
	{name="item", attr={text="传说", keywords="传说",  code = 73,class=1, subclass=11, is_expanded=false},},
},

{name="typ", attr={text="魂印合成",code = 8,class=3, subclass=21, is_expanded=false},
	{name="item", attr={text="灵魂碎片", code = 82,class=3, subclass=23, is_expanded=false},},
	{name="item", attr={text="魂珠", code = 83,class=3, subclass=22, is_expanded=false},},
},

{name="typ", attr={text="魂印成品",code = 2,class=3, subclass=21, is_expanded=false},
	{name="item", attr={text="全部",code = 200, class=3, subclass=21, is_expanded=false},},
	{name="item", attr={text="1阶",code = 201, keywords="1",  class=3, subclass=21, is_expanded=false},},
	{name="item", attr={text="2阶",code = 202, keywords="2",  class=3, subclass=21, is_expanded=false},},
	{name="item", attr={text="3阶",code = 203, keywords="3",  class=3, subclass=21, is_expanded=false},},
	{name="item", attr={text="4阶",code = 204, keywords="4",  class=3, subclass=21, is_expanded=false},},
	{name="item", attr={text="5阶",code = 205, keywords="5",  class=3, subclass=21, is_expanded=false},},
	{name="item", attr={text="6阶",code = 206, keywords="6",  class=3, subclass=21, is_expanded=false},},
	{name="item", attr={text="7阶",code = 207, keywords="7",  class=3, subclass=21, is_expanded=false},},
	{name="item", attr={text="8阶",code = 208, keywords="8",  class=3, subclass=21, is_expanded=false},},
	{name="item", attr={text="9阶",code = 209, keywords="9",  class=3, subclass=21, is_expanded=false},},
	{name="item", attr={text="10阶",code = 210, keywords="10",  class=3, subclass=21, is_expanded=false},},
},

{name="typ", attr={text="消耗品",code = 9,class=3, subclass=7, is_expanded=false},
	{name="item",attr={text="魔尘",code = 96, keywords="魔尘",class=3,subclass=9,is_expanded=false},},
	{name="item",attr={text="魔法牌包",code = 97,keywords="魔法牌包", class=3,subclass=9,is_expanded=false},},
	{name="item",attr={text="魔法喇叭",code = 90,  keywords="喇叭",	class=3,subclass=10,is_expanded=false},},
	{name="item",attr={text="药丸&门票",code = 91, class=3,subclass=10,is_expanded=false},},
	{name="item", attr={text="坐骑",code = 92, class=2,subclass=6,is_expanded=false},},
	{name="item", attr={text="符文卡牌",code = 93, class=18,subclass=2,is_expanded=false},},
	{name="item", attr={text="镶嵌符",code = 94, class=3,subclass=7,is_expanded=false},},
	{name="item",	attr={text="宠物口粮",code = 95, keywords="口粮",  class=3,subclass=4,is_expanded=false},},
},

{name="item",attr={text="其他",code = 514, class=3,subclass=4,is_expanded=false},},

--{name="typ", attr={text="符文",code = 7, class=18,subclass=2,is_expanded=false},
	--{name="item",attr={text="生命系",code = 341,class=18,subclass=2,is_expanded=false}},
	--{name="item",attr={text="烈火系",code = 342,class=18,subclass=2,is_expanded=false},},
	--{name="item",attr={text="寒冰系",code = 343,class=18,subclass=2,is_expanded=false},},
	--{name="item",attr={text="死亡系",code = 344,class=18,subclass=2,is_expanded=false},},
	--{name="item",attr={text="风暴系",code = 345,class=18,subclass=2,is_expanded=false},},
	--{name="item",attr={text="通用",code = 346,class=18,subclass=2,is_expanded=false},},
--},
--{name="typ", attr={text="消耗品",code = 5,class=3, is_expanded=false},
	----{name="item",attr={text="所有",code = 51,class=3,is_expanded=false},},
	--{name="item",attr={text="红枣",code = 52, keywords="红枣", class=3,subclass=5,is_expanded=false},},
	--{name="item",attr={text="面包",code = 54, keywords="面包", class=3,subclass=5,is_expanded=false},},
	--{name="item",attr={text="药丸&门票",code = 53, class=3,subclass=10,is_expanded=false},},
--},
--{name="typ",attr={text="宝石",code = 6,class=3,subclass=6,is_expanded=false},},
--{name="item",attr={text="能量石",code = 11,class=100,subclass=1,is_expanded=false},},
--{name="item", attr={text="家具",code = 10, class=9,subclass=2,is_expanded=false},},
};

end

function ItemsFilter:OnClickItem(arg)
	if(not arg)then return end
	local params;

	if(arg.mcmlNode)then
		params = arg.mcmlNode:GetPreValue("this")
	else
		params = arg;
	end

	local school_name = params.text
	self.school_code = GenericTooltip.GetSchoolCode(school_name);
	self.class,self.subclass = params.class,params.subclass
	self.keywords = params.keywords;
	self.quality = params.quality;
	self.pindex = 0;
	local level = params.level;	
	local text = params.text;		
	
	local i,v,i2,v2,i3,v3,i4,v4 
	for i,v in ipairs(self.filter_list)do
		if(v.attr.code == params.code)then 
			if(v.name == "typ")then
				v.attr.is_expanded = not v.attr.is_expanded;
			end
			if(not v.attr.checked and v.name == "item")then
				v.attr.checked = true;
			end
		else
			v.attr.checked = false;
		end


		if(#v > 0)then
			for i2,v2 in ipairs(v)do
				if(v2.attr.code == params.code)then
					if( v2.name == "typ")then
						v2.attr.is_expanded = not v2.attr.is_expanded;
					end
					if(not v2.attr.checked and v2.name == "item")then
						v2.attr.checked = true;
					end
				else
					v2.attr.checked = false;
				end
					
				if(#v2 > 0)then
					for i3,v3 in ipairs(v2)do
						if(v3.attr.code == params.code)then
							if( v3.name == "typ")then
								v3.attr.is_expanded = not v3.attr.is_expanded;
							end
							if(not v3.attr.checked and v3.name == "item")then
								v3.attr.checked = true;
							end
						else
							v3.attr.checked = false;
						end

						if(#v3 > 0)then
							for i4,v4 in ipairs(v3)do
								if(v4.attr.code == params.code)then
									if( v4.name == "typ")then
										v4.attr.is_expanded = not v4.attr.is_expanded;
									end
									if(not v4.attr.checked and v4.name == "item")then
										v4.attr.checked = true;
									end
								else
									v4.attr.checked = false;
								end
						
							end
						end
						
					end
				end
			end
		end
	end
	--echo(self.filter_list)

	if(self.page) then
		self.page:Refresh(0.01);
	end
	if((TEEN_VERSION and math.fmod(params.code,2) == 0) or ((params.code == 5 or params.code == 6) and not TEEN_VERSION))then 
		self.class,self.subclass,ItemsFilter.vars,self.keywords, self.quality = nil,nil,nil,nil, nil;
		self.pindex = nil;
		return;
	end

	--[[
		///     itemclass 物品所属的Class，必传
		///     [ subclass ] 物品所属的SubClass
		///     [ school ] 系别
		///     [ orders ] 排序方式。示例：0,1,-1,0,0 。逗号分隔的每一项分别表示：[0]:品质,[1]:等级,[2]:剩余时间,[3]:出售者,[4]:单价。值0 1 -1分别表示：不排序、升序、降序
		///     pindex 页码
		///     psize 每页的数据量，最大20
	]]
	
	ItemsFilter.vars = text;
	ItemsConsignment.Search("btnSearch", true);
	--ItemsConsignment.GetInShop({itemclass= self.class,subclass=self.subclass,school=self.school_code,pindex=0,psize=20},text)
	--ItemsConsignment.prev_call = "GetInShop";	
end

function ItemsFilter:Init()
	self.page = document:GetPageCtrl();
end

function ItemsFilter:Clean()
	ItemsFilter.class = nil;
	ItemsFilter.subclass = nil;
	ItemsFilter.vars = nil;
	ItemsFilter.keywords = nil;
	ItemsFilter.pindex = nil;
	ItemsFilter.quality = nil;
end

function ItemsFilter:GetDataSource(index)
	return self.filter_list
end