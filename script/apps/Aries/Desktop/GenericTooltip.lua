--[[
Title: code behind for generic tooltip design page
Author(s): WD, lixizhi
Date: 2011/09/21

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");
local itemname = CommonCtrl.GenericTooltip.GetItemMCMLText(gsid, count, bIsSelf);
local GenericTooltip = CommonCtrl.GenericTooltip:new();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_equipment_subpage.lua");
NPL.load("(gl)script/apps/Aries/Player/main.lua");
NPL.load("(gl)script/kids/3DMapSystemItem/Item_CombatApparel.lua");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetHelper.lua");
local CombatPetHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetHelper");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetConfig.lua");
local CombatPetConfig = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetConfig");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");
local Avatar_equipment_subpage = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equipment_subpage");

local TEEN_VERSION = if_else(System.options.version == "teen",true,false)
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local hasOPCGSItem = ItemManager.IfOPCOwnGSItem;
local equipOPCGSItem = ItemManager.IfOPCEquipGSItem;
local getItemByGsid = ItemManager.GetGlobalStoreItemInMemory;
local getItemByGuid = ItemManager.GetItemByGUID;
local getEquippedItem = ItemManager.GetEquippedItem;
--@param nid.
--@param guid.
local GetOPCItemByNidGuid = ItemManager.GetOPCItemByGUID;
local GetExtTemp = ItemManager.GetExtendedCostTemplateInMemory;
local echo = commonlib.echo;
local str_find = string.find;
local str_fmt = string.format;
local str_sub = string.sub;
local str_gmatch = string.gmatch;
local min = math.min;
local floor = math.floor;
local ceil = math.ceil;
local modf = math.modf;

local WHITE = "#ffffff";
local BLUE = "#0099ff";
local GREEN = "#00cc33";
local PURPLE = "#c648e1";
local YELLOW = "#ff9a00";
local RED = "#ff0000";
local GRAY = "fcf5bd";
local CURRENT_EQUIP_COLOR = "#fcf776";
local EQUIP_STATS_COLOR = "#f0a607";
local LIMITED_COLOR = "#ff0000"; --"#fe6102";
local DEFAULT_COLOR = "#52dff4";

local GREEN2 = "#40dd2a";
local RED2 = "#f61909";
local static_gem_shape_map;
local BG_SLOTTING,BG_UNSLOTTING;
if(TEEN_VERSION)then
	NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_equip_exchange.lua");
	BG_SLOTTING =	[[<div><div style="float:left;width:16px;height:16px;background:url(Texture/Aries/Common/ThemeTeen/shop/bg_slotting_32bits.png#1 1 53 53)"></div><div style="float:left;margin-left:2px;">可镶嵌</div></div>]];
	BG_UNSLOTTING = [[<div><div style="float:left;width:16px;height:16px;background:url(Texture/Aries/Common/ThemeTeen/shop/bg_unslotting_32bits.png#1 1 53 53)"></div><div style="float:left;margin-left:2px;">未开孔</div></div>]]; 
else
	NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_equip_exchange.kids.lua");
	CURRENT_EQUIP_COLOR = "#000000";
	BG_SLOTTING =	[[<div  style="margin-top:-2px;"><div style="float:left;width:16px;height:16px;margin-top:4px;background:url(Texture/Aries/Common/EmptySocket_32bits.png)"></div><div style="float:left;">可镶嵌</div></div>]];
	--BG_UNSLOTTING = [[<div><div style="float:left;width:20px;height:20px;background:url(Texture/Aries/Common/PotencialSocket_32bits.png)"></div><div style="float:left;">未开孔</div></div>]]; 
	--BG_SLOTTING =	[[<div><div style="float:left;"><img src="texture/Aries/Common/EmptySocket_32bits.png" style="width:24px;height:24px;"/></div><div style="float:left;">可镶嵌</div></div>]];
	--BG_UNSLOTTING = [[<div><div style="float:left;"><img src="texture/Aries/Common/PotencialSocket_32bits.png" style="width:24px;height:24px;"/></div><div style="float:left;">未开孔</div></div>]];
end

local KIDS_HDR_COLOR = "#2f528b"
local KIDS_DEFAULT_COLOR = "#022a57"
local KIDS_BINDING_COLOR = "#022A57"
local KIDS_TARGET_COLOR = "#710093"
local KIDS_LEVEL_LIMITED = "#cb002e"
local KIDS_PLUS_COLOR = "#5eb8d4"
local KIDS_EQUIP_SUIT = "#C33E00"
local KIDS_UNEQUIP_SUIT = "#535a74"


local Avatar_equip_exchange = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equip_exchange");
local STATS_COLOR_TABLE = { [1] = "#f61909",
							[2] = "#fee11c",
							[3] = "#40dd2a",
							[4] = "#fb3bba",
							[5] = "#ff6600"};
--[[
等级
加移动速度
加血
加超魔
加攻击
加防御
加命中
有效期
文字介绍

]]

local level_map = if_else(TEEN_VERSION,{
	[10] = 2,
	[9] = 5,
	[8] = 10,
	[7] = 15,
	[6] = 20,
	[5] = 25,
	[4] = 30,
	[3] = 35,
	[2] = 40,
},{
	[10] = 3,
	[9] = 5,
	[8] = 10,
	[7] = 15,
	[6] = 20,
	[5] = 25,
	[4] = 30,
});

local  content_map = if_else(TEEN_VERSION,{
        [10] = "自动战斗药丸 x 50<br/>奇豆小钱袋 x 10",
        [9] = "奇豆大钱袋 x 5<br/>经验强化药丸 x 5",
        [8] = "假日努力药丸 x 5<br/>小飞马 x 1",
        [7] = "1级攻击石 x 5<br/>1级魔力石 x 5<br/>静水灵体 x 1",
        [6] = "魔力爆发符文 x 1<br/>2级结晶 x 10<br/>白水晶 x 10",
        [5] = "小仙兔 x 1<br/>2级攻击石 x 5<br/>2级魔力石 x 5",
        [4] = "连环结界 x 5<br/>顶级战宠口粮 x 2<br/>西瓜热力饮 x 20",
        [3] = "香梅瓜餐宴 x 1<br/>3级攻击石 x 1",
        [2] = "绿水晶 x 50<br/>3级超魔石 x 1<br/>超级经验药丸 x 1<br/>金豆 x 50",
    },{
    [10] = "仙豆x10、抱抱龙百科全书",
    [9] = "仙豆x20、亲密丸x4",
    [8] = "仙豆x30、1级血精石、1级月光镜、亲密丸x8",
    [7] = "仙豆x40、1级血精石、1级月光镜、高级亲密丸x1",
    [6] = "仙豆x50、1级血精石、1级月光镜、抱抱龙技能手册",
    [5] = "仙豆x60、1级血精石、1级月光镜",
    [4] = "仙豆x70、2级血精石、2级月光镜",
});

local colour_map = 
{
	[0] = WHITE,
	[1] = GREEN,
	[2] = BLUE,
	[3] = PURPLE,
	[4] = YELLOW,};
local code_map = 
{
	[10] = "副手",
	[11] = "主手",
	[2] = "帽子",
	[5] = "衣服",
	[7] = "鞋子",
	[8] = "披风",
	[9] = "手套",
	[14] = "耳环",
	[15] = "手镯",
	[16] = "戒指",
	[17] = "项链",
	[18] = "帽子(炫彩装)",
	[19] = "衣服(炫彩装)",
	[70] = "其他(炫彩装)",
	[71] = "手持(炫彩装)",
	[72] = "玩具(炫彩装)",
	[4] = "其他",
	[71] = "鞋子",
	[6] = "裤子",
	[12] = "腰带", -- 青年版 2012/11/13 添加
};
local stat_map = {

[3] = {str_format="抱抱龙饥饿值:%s", type="str_format"},
[4] = {str_format="抱抱龙清洁值:+%s", type="str_format"},
[5] = {str_format="抱抱龙心情值:+%s", type="str_format"},
[7] = {str_format="抱抱龙亲密度:+%s", type="str_format"},
[20] = {str_format="抱抱龙力量值:+%s", type="str_format"},
[19] = {str_format="抱抱龙敏捷值:+%s", type="str_format"},
[18] = {str_format="抱抱龙智慧值:+%s", type="str_format"},
[17] = {str_format="抱抱龙爱心值:+%s", type="str_format"},
[21] = {str_format="抱抱龙建造熟练度:+%s", type="str_format"},

[34] = {str_format="点击使用增加%s点经验", type="str_format"},
[45] = {str_format="恢复 %s%% HP", type="str_format"},
[46] = {str_format="最大有效期:%s天", type="str_format"},
[10047] = {str_format="最大有效期:%s小时", type="str_format"},
[10048] = {str_format="最大有效期:当天有效", type="str_format"},
[10049] = {str_format="最大有效期:本月有效", type="str_format"},
[59] = {str_format="移动速度:+%s%%", type="str_format"},
[101]= {str_format="HP:+%s", type="str_format"},
[102] = {str_format="超级魔力点生成率:+%s%%", type="str_format"},
[103] = {str_format="通用命中率:+%s%%", type="str_format"},
[104] = {str_format="烈火命中率:+%s%%", type="str_format"},

[105] = {str_format="寒冰命中率:+%s%%", type="str_format"},
[106] = {str_format="风暴命中率:+%s%%", type="str_format"},
[107] = {str_format="大地命中率:+%s%%", type="str_format"},
[108] = {str_format="生命命中率:+%s%%", type="str_format"},
[109] = {str_format="死亡命中率:+%s%%", type="str_format"},

[110] = {str_format="平衡命中率:+%s%%", type="str_format"},
[111] = {str_format="通用攻击:", type="va_format"},
[112] = {str_format="烈火攻击:", type="va_format"},
[113] = {str_format="寒冰攻击:", type="va_format"},
[114] = {str_format="风暴攻击:", type="va_format"},

[115] = {str_format="大地攻击:", type="va_format"},
[116] = {str_format="生命攻击:", type="va_format"},
[117] = {str_format="死亡攻击:", type="va_format"},
[118] = {str_format="平衡攻击:", type="va_format"},
[119] = {str_format="通用防御:", type="va_format"},

[120] = {str_format="烈火防御:", type="va_format"},
[121] = {str_format="寒冰防御:", type="va_format"},
[122] = {str_format="风暴防御:", type="va_format"},
[123] = {str_format="大地防御:", type="va_format"},
[124] = {str_format="生命防御:", type="va_format"},

[125] = {str_format="死亡防御:", type="va_format"},
[126] = {str_format="平衡防御:", type="va_format"},

[134] = {str_format="消耗魔力点:%s", type="str_format"},
[135] = {str_format="使用成功率:%s%%", type="str_format"},

[151] = {str_format="全系攻击:+%s%%", type="str_format"},
[152] = {str_format="烈火攻击:+%s%%", type="str_format"},
[153] = {str_format="寒冰攻击:+%s%%", type="str_format"},

[154] = {str_format="风暴攻击:+%s%%", type="str_format"},
[155] = {str_format="大地攻击:+%s%%", type="str_format"},
[156] = {str_format="生命攻击:+%s%%", type="str_format"},
[157] = {str_format="死亡攻击:+%s%%", type="str_format"},
[158] = {str_format="平衡攻击:+%s%%", type="str_format"},

[159] = {str_format="全系防御:+%s%%", type="str_format"},
[160] = {str_format="烈火防御:+%s%%", type="str_format"},
[161] = {str_format="寒冰防御:+%s%%", type="str_format"},
[162] = {str_format="风暴防御:+%s%%", type="str_format"},
[163] = {str_format="大地防御:+%s%%", type="str_format"},

[164] = {str_format="生命防御:+%s%%", type="str_format"},
[165] = {str_format="死亡防御:+%s%%", type="str_format"},
[166] = {str_format="平衡防御:+%s%%", type="str_format"},

[182] = {str_format="治疗加成:+%s%%", type="str_format"},
[183] = {str_format="被治疗加成:+%s%%", type="str_format"},

[188] = {str_format="通用闪避:+%s%%", type="str_format", scale=0.1},

[189] = {str_format="烈火闪避:+%s%%", type="str_format"},
[190] = {str_format="寒冰闪避:+%s%%", type="str_format"},
[191] = {str_format="风暴闪避:+%s%%", type="str_format"},
[192] = {str_format="大地闪避:+%s%%", type="str_format"},
[193] = {str_format="生命闪避:+%s%%", type="str_format"},

[194] = {str_format="死亡闪避:+%s%%", type="str_format"},
[195] = {str_format="平衡闪避:+%s%%", type="str_format"},
[196] = {str_format="暴击:+%s%%", type="str_format"},
[197] = {str_format="烈火暴击:+%s%%", type="str_format"},
[198] = {str_format="寒冰暴击:+%s%%", type="str_format"},

[199] = {str_format="风暴暴击:+%s%%", type="str_format"},
[200] = {str_format="大地暴击:+%s%%", type="str_format"},
[201] = {str_format="生命暴击:+%s%%", type="str_format"},
[202] = {str_format="死亡暴击:+%s%%", type="str_format"},
[203] = {str_format="平衡暴击:+%s%%", type="str_format"},

[204] = {str_format="韧性:+%s%%", type="str_format"},
[205] = {str_format="烈火韧性:+%s%%", type="str_format"},
[206] = {str_format="寒冰韧性:+%s%%", type="str_format"},
[207] = {str_format="风暴韧性:+%s%%", type="str_format"},
[208] = {str_format="大地韧性:+%s%%", type="str_format"},

[209] = {str_format="生命韧性:+%s%%", type="str_format"},
[210] = {str_format="死亡韧性:+%s%%", type="str_format"},
[211] = {str_format="平衡韧性:+%s%%", type="str_format"},
[212] = {str_format="通用穿透:+%s%%", type="str_format"},
[213] = {str_format="烈火穿透:+%s%%", type="str_format"},

[214] = {str_format="寒冰穿透:+%s%%", type="str_format"},
[215] = {str_format="风暴穿透:+%s%%", type="str_format"},
[216] = {str_format="大地穿透:+%s%%", type="str_format"},
[217] = {str_format="生命穿透:+%s%%", type="str_format"},
[218] = {str_format="死亡穿透:+%s%%", type="str_format"},
[219] = {str_format="平衡穿透:+%s%%", type="str_format"},

[224] = {str_format="暴击强度:+%s(%s%%)", type="str_format"},
[225] = {str_format="韧性强度:+%s(%s%%)", type="str_format"},
[226] = {str_format="攻击:", type="va_format"},
[227] = {str_format="烈火攻击:", type="va_format"},
[228] = {str_format="寒冰攻击:", type="va_format"},

[229] = {str_format="风暴攻击:", type="va_format"},
[230] = {str_format="大地攻击:", type="va_format"},
[231] = {str_format="生命攻击:", type="va_format"},
[232] = {str_format="死亡攻击:", type="va_format"},
[233] = {str_format="平衡攻击:", type="va_format"},

[234] = {str_format="防御:", type="va_format"},
[235] = {str_format="烈火防御:", type="va_format"},
[236] = {str_format="寒冰防御:", type="va_format"},
[237] = {str_format="风暴防御:", type="va_format"},
[238] = {str_format="大地防御:", type="va_format"},

[239] = {str_format="生命防御:", type="va_format"},
[240] = {str_format="死亡防御:", type="va_format"},
[241] = {str_format="平衡防御:", type="va_format"},
[242] = {str_format="HP上限:+%s%%", type="str_format"},
[243] = {str_format="命中:+%s%%", type="str_format"},
[244] = {str_format="命中强度:+%s(%s%%)", type="str_format"},
--[178] = {str_format="能量值:+%s", type="str_format"},
--[179] = {str_format="M值:+%s", type="str_format"},
[180] = {desc="需要魔法星才能使用", type="desc"},

[253] = {str_format="蘑菇积分:%s", type="str_format"},
[254] = {str_format="暴击:+%s%%", type="str_format"},
[255] = {str_format="韧性:+%s%%", type="str_format"},
--[253] = {str_format="蘑菇积分:", type="va_format"},
--[253] = {str_format="蘑菇积分:%s", type="str_format"},

[256] = {str_format="致命一击:+%s%%", type="str_format"},
[376] = {str_format="暴击伤害:+%s%%", type="str_format"},

[512] = {desc="可签名物品", type="desc"},

}

if(not TEEN_VERSION) then
	stat_map[151] = {str_format="伤害:+%s%%", type="str_format"};
	stat_map[159] = {str_format="受到伤害:-%s%%", type="str_format"};
	stat_map[234] = {str_format="受到伤害:-", type="va_format"};
	stat_map[188] = {str_format="绝对防御:+%s%%", type="str_format", scale=0.1};
end

if(TEEN_VERSION) then
	stat_map[102] = {str_format="双倍魔力生成率:+%s%%", type="str_format"};
end

local key_words_map = {"速度","HP","魔力","攻击","防御",
						"命中","闪避","暴击","韧性","穿透","伤害","受到伤害",
						"治疗","维持时间","抱抱龙","使用成功率","蘑菇积分","致命一击"};

--[[
	color value reference:
	blue 0099ff
	green 00cc33
	purple c648e1
	gray fcf5bd
	current equip fcf776
	equip stats f0a607
	limited equip da0202 change to #fe6102
	equip quality: -1未知 0白 1绿 2蓝 3紫 4橙 
--]]


local ObjectTooltipInfo = {
	user_nid,
	gsid = -999, 
	guid = -999,
	name = "",--object display name
	icon = "",
	quality = -1, -- -1 means unknown.

	durability = "",-- for equip durability.
	level = "",
	bind_self = "",
	school = "",
	item_type = "", -- item type

	self_stats = "",
	--extra mount attr
	extra_stats = "",

	hold_slots = 0,--hold slots count of equip.
	usable_slots = 0,--usable slots count of equip.
	unusable_slots = 0,
	equiped_list_count = 0,
	total_equip_list_count = 0,

	equip_suit_name = "",--display equip suit name.
	equiped_list = "",
	trade = "",

	equipsuit_mount_stats = "",
	card_list = "",
	avatar_school = "",
	equip_compare_url = "",

	item = {},
	goods = {},
	description = "",
	socketing_description = "",
	addon_perperty_section = "",
	diff_stats = {},
	ordered_stat = {
	[1] = {[59]=59,},
	[2] = {},
	[3] = {},
	[4] = {},
	[5] = {},
	[6] = {},
	[7] = {},
	[8] = {},
	[9] = {},
	[10] = {},
	[11] = {},
	[12] = {},
	[13] = {},
	[14] = {},
	[15] = {},
	[16] = {},
	[17] = {[46] = 46,[10047] = 10047,[10048] = 10048,[10049] = 10049,},
	[18] = {},
	},
};

CommonCtrl.GenericTooltip = ObjectTooltipInfo;

function ObjectTooltipInfo:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	o.value = o.value or "";
	return o;
end

function ObjectTooltipInfo:LOG(caption,obj)
	if(false)then
		echo(caption);
		echo(obj);
	end
end

-- get stats word
-- return the formated stat string and type
function ObjectTooltipInfo.GetStatMap(stat_id)
	if(stat_id) then
		return stat_map[stat_id];
	end
end
-- 将所有stat按key_words_map中定义的类型分类保存，不在其中的不记录
function ObjectTooltipInfo:_GenOrderedStats()
	local i,v1
	for i,v1 in ipairs(self.ordered_stat)do
		local k,v	
		for k,v in pairs(stat_map)do
			if(i==3)then
				if(v.str_format and str_find(v.str_format,key_words_map[i]) and not str_find(v.str_format,"每魔力点"))then
					if(not self.ordered_stat[i][k] or (self.ordered_stat[i][k] and self.ordered_stat[i][k] ~= k))then
						self.ordered_stat[i][k] = k;
					end
				end
			elseif(v.str_format and str_find(v.str_format,key_words_map[i]) )then
				if(not self.ordered_stat[i][k] or (self.ordered_stat[i][k] and self.ordered_stat[i][k] ~= k))then
					self.ordered_stat[i][k] = k;
				end
			end
			self.ordered_stat[i]["diff_stats"] = 0;
			self.ordered_stat[i]["key_typ"] = nil;
		end
	end	
	self.ordered_stat[1][59] = 59;
	--self.ordered_stat[12][178] = 178;
	--self.ordered_stat[12][179] = 179;
	self.ordered_stat[12][180] = 180;
	self.ordered_stat[12][34] = 34;
	self.ordered_stat[17][46] = 46;
	self.ordered_stat[17][10047] = 10047;
	self.ordered_stat[17][10048] = 10048;
	self.ordered_stat[17][10049] = 10049;

end

function ObjectTooltipInfo:InitEquippedItem()
	self.equipped_item, self.isEquipped = nil,nil;	
	if(not self.item)then return end
	self.equipped_item, self.isEquipped = getEquippedItem(self.item);

	if(self.item and self.item.template.class == 2 and self.item.template.subclass == 6) then
		local equipped_item = ItemManager.GetItemByBagAndPosition(0, 33);
		if(equipped_item and equipped_item.guid > 0) then
			self.equipped_item, self.isEquipped = equipped_item, true;
		end
	end
end

--[[
	@param arg:an item type
]]
function ObjectTooltipInfo:IsEquip(arg)
	if(self.gsid == 0 and not arg)then return end
	if(self.gsid and arg)then self.item = arg end
	return (self.item and self.item.template and self.item.template.class == 1); 
end

function ObjectTooltipInfo:GetGUID(gsid)
	local _, guid, __, copies = hasGSItem(gsid)
	return guid or -999;
end

--223 装备的绑定方式，1:使用后绑定；2:获得即绑定 
function ObjectTooltipInfo:IsBinding(goods,external)
	if(not external)then
		goods = goods or self.goods;
	else
		goods = goods 
	end

	local binding;
	if(goods and goods.GetBinding)then
		binding = goods:GetBinding();
	end
	local item = getItemByGsid(goods.gsid)
	--2:获得即绑定 
	if(item and item.template and item.template.stats[223] == 2)then return true end
	--1:使用后绑定；
	if(binding and binding > 0)then return true end
	return false;
end

function ObjectTooltipInfo:CheckBinding(gsid,external)
	local guid = self:GetGUID(gsid)
	local goods = getItemByGuid(guid);
	
	if(self:IsBinding(goods,true))then return true 
	else return false end
end

--[[
	@param arg:school id.
	@return multi_value:name of school is returned.
--]]
function ObjectTooltipInfo.GetSchool(arg)
	if(not arg)then return end

	if(arg == 6)then
		return "烈火系","fire";
	elseif(arg == 7) then
		return "寒冰系","ice";
	elseif(arg == 8) then
		return "风暴系","storm";
	elseif(arg == 9) then
		return "大地系","myth";
	elseif(arg == 10) then
		return "生命系","life";
	elseif(arg == 11) then
		return "死亡系","death";
	else
		return ;
	end
end

function ObjectTooltipInfo.GetSchoolCode(arg)
	if(not arg)then return end

	if(arg == ("烈火系" or "fire"))then
		return 6;
	elseif(arg == ("寒冰系" or "ice")) then
		return 7;
	elseif(arg == ("风暴系" or "storm")) then
		return 8;
	elseif(arg == ("大地系" or "myth")) then
		return 9;
	elseif(arg == ("生命系" or "life")) then
		return 10;
	elseif(arg == ("死亡系" or "death")) then
		return 11;
	elseif(arg == ("通用" or "平衡系" or "balance")) then
		return 12;
	else
		return ;
	end
end


function ObjectTooltipInfo.GetEquipColor(qty)
	return colour_map[qty] or DEFAULT_COLOR;
end

--[[
	@param arg:the subclass
	@return:item type is returned.
--]]
function ObjectTooltipInfo.GetItemType(arg)
	if(not arg)then return nil end
	return code_map[arg] or ""
end

function ObjectTooltipInfo:GetStatsByType(typ, value)
    if(typ and value) then
		if(typ == 185 and not stat_map[typ]) then
			if(TEEN_VERSION) then
				stat_map[185] = {str_format="双倍魔力点:%s", type="str_format"};
			else
				stat_map[185] = {str_format="初始超级魔力点:%s", type="str_format"};
			end
		elseif(typ == 184 and not stat_map[typ]) then
			if(TEEN_VERSION) then
				stat_map[184] = {str_format="初始魔力点:%s", type="str_format"};
			else
				stat_map[184] = {str_format="初始普通魔力点:%s", type="str_format"};
			end
		end
		
		local stat_tmpl = stat_map[typ];

		local original_value = value;
		if(typ == 224 or typ == 225 or typ == 244) then 
			value = value * 100 / (50 + Combat.GetMyCombatLevel() * 50);
			value = string.format("%.2f", value);  -- ATTENTION: this is a string value
		end
		if(typ == 376) then
			value = value/10;
			value = string.format("%s", value); 
		end

		if(stat_tmpl) then
			if(stat_tmpl.desc and stat_tmpl.type == "desc") then
				if(typ == 180) then
					return str_fmt([[<div style="color:%s">%s</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_EQUIP_SUIT),stat_tmpl.desc);
				else
					return str_fmt([[<div style="color:%s">%s</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR),stat_tmpl.desc);
				end
			end
			if(value == 0)then return end
			if(stat_tmpl.str_format and stat_tmpl.type == "str_format") then
				if(typ == 3) then
					if(value and value > 0) then
						return str_fmt(stat_tmpl.str_format, "+"..tostring(value))
					else
						return str_fmt(stat_tmpl.str_format, tostring(value))
					end
				elseif(typ == 34) then
					return str_fmt(stat_tmpl.str_format, tostring(value * 100))
				elseif((typ == 188 or typ == 243) and System.options.version == "teen" )then
					return str_fmt(stat_tmpl.str_format, tostring(value / 10))
				elseif((typ == 188 or typ == 243) and System.options.version == "kids" )then
					return str_fmt(stat_tmpl.str_format, tostring(value / 10))
				elseif((typ == 254 or typ == 255) and System.options.version == "teen" )then
					return str_fmt(stat_tmpl.str_format, tostring(value / 10))
				elseif(typ == 46)then
					return str_fmt(stat_tmpl.str_format, tostring(value) or if_else(self.item and self.item.template and self.item.template.expiretime,self.item.template.expiretime or 0,0));
				elseif(typ == 10047)then
					return str_fmt(stat_tmpl.str_format, tostring(value) or if_else(self.item and self.item.template and self.item.template.expiretime,self.item.template.expiretime or 0,0));
				elseif(typ == 10048)then
					return str_fmt(stat_tmpl.str_format, tostring(value) or if_else(self.item and self.item.template and self.item.template.expiretime,self.item.template.expiretime or 0,0));
				elseif(typ == 10049)then
					return str_fmt(stat_tmpl.str_format, tostring(value) or if_else(self.item and self.item.template and self.item.template.expiretime,self.item.template.expiretime or 0,0));
				elseif(typ == 253) then
					-- 253 any_ranking_requirement(CG) 物品穿着必须任意pvp积分 1v1 2v2 有一个达到即可 青年版第一次使用 
					local require_any_ranking = value;
					if(require_any_ranking) then
						local isValid = false;
						local ranking = Combat.GetMyPvPRanking("1v1");
						if(ranking and ranking >= require_any_ranking) then
							isValid = true;
						end
						local ranking = Combat.GetMyPvPRanking("2v2");
						if(ranking and ranking >= require_any_ranking) then
							isValid = true;
						end
						if(not isValid) then
							return str_fmt([[<div style="color:%s">%s</div>]],if_else(TEEN_VERSION,RED,RED), str_fmt(stat_tmpl.str_format, tostring(value)));
						end
					end
					return str_fmt(stat_tmpl.str_format, tostring(value));
				else
					if(typ == 224 or typ == 225 or typ == 244) then 
						return str_fmt(stat_tmpl.str_format, original_value, tostring(value));
					else
						return str_fmt(stat_tmpl.str_format, tostring(value));
					end
				end
			elseif(stat_tmpl.type == "va_format" ) then
				if(System.options.version == "teen") then
					if(TEEN_VERSION)then
						return str_fmt("%s+%s(%s%%)",stat_tmpl.str_format,value,value);
					else
						return str_fmt([[<div style="float:left;">%s</div><div style="float:left;color:%s">%s</div>]],str_fmt("%s+%s",stat_tmpl.str_format,value),if_else(vlaue and value > 0,"#5eb8d4","#c33e00"),str_fmt("(%s%%)",value));	
					end
				else
					return str_fmt("%s+%s%%",stat_tmpl.str_format,value,value);
				end
			end
		end

    end
end


--display stats by specify order
function ObjectTooltipInfo:SetDesc(type,desc)
	local i,v
	for i,v in ipairs(self.ordered_stat)do
		if(v[type] and v[type] == type)then
			v[type] = desc;
			break;
		end
	end
end
--[[
	@param gsid:item gsid,if gsid is nil,then get stats of self.
	@return:text format of html is returned.
--]]
function ObjectTooltipInfo:getStatsByGsid(ordered,gsid)
	local item;	
	local text = "";
	local type, value;

	if(gsid)then
		item = getItemByGsid(gsid);
	else
		item = self.item;
	end

	if(item and item.template)then
		local stats = item.template.stats
		self:LOG("item.template.stats",stats);

		local level_limit = stats[138];
		level_limit = level_limit or stats[168];
		if(level_limit)then
			if(Player.GetLevel() < level_limit)then
				self.level = str_fmt([[<div style="color:%s;font-weight:bold;">使用等级:%s</div>]],if_else(TEEN_VERSION,LIMITED_COLOR,KIDS_LEVEL_LIMITED),level_limit);
			else
				self.level = str_fmt([[<div style="color:%s">使用等级:%s</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR),level_limit);
			end
		end
		
		-- 186 cooldown_rounds(CG)
		local cooldown_count = stats[186];
		if(cooldown_count) then
			self.level = self.level .. str_fmt([[<div style="color:%s">冷却回合:%s</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR),cooldown_count);
		end

		-- 134 pipcost_card_or_qualification(C)
		local pips_count = stats[134];
		if(pips_count) then
			if(TEEN_VERSION) then
				if(pips_count > 100) then
					pips_count = "全部";
				end
				self.level = self.level .. str_fmt([[<div style="color:%s">消耗魔力点:%s</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR),pips_count);
			end
		end
		
		if(ordered)then
			local i,v

			for type, value in pairs(stats) do
				local word = self:GetStatsByType(type, value);
				if(word)then
					self:SetDesc(type,word);
				end
			end
			
			--echo(new_stats);			
			for i,v in ipairs(self.ordered_stat) do
				local k1,v1
				for k1,v1 in pairs(v)do
					if(v1 and v1 ~= k1 and k1 ~= "diff_stats" and k1 ~= "key_typ")then
						local color = if_else(TEEN_VERSION, DEFAULT_COLOR, KIDS_DEFAULT_COLOR);
						if(k1 == 46) then
							color = if_else(TEEN_VERSION, LIMITED_COLOR, KIDS_LEVEL_LIMITED);
							local RemainingDays = self:getStatExpireRemainingDays()
							if(RemainingDays and RemainingDays ~= "") then
								color = if_else(TEEN_VERSION, DEFAULT_COLOR, KIDS_DEFAULT_COLOR);
							end
						elseif(k1 == 10047) then
							color = if_else(TEEN_VERSION, LIMITED_COLOR, KIDS_LEVEL_LIMITED);
							local RemainingDays = self:getStatExpireRemainingDays()
							if(RemainingDays and RemainingDays ~= "") then
								color = if_else(TEEN_VERSION, DEFAULT_COLOR, KIDS_DEFAULT_COLOR);
							end
						elseif(k1 == 10048) then
							color = if_else(TEEN_VERSION, LIMITED_COLOR, KIDS_LEVEL_LIMITED);
							local RemainingDays = self:getStatExpireRemainingDays()
							if(RemainingDays and RemainingDays ~= "") then
								color = if_else(TEEN_VERSION, DEFAULT_COLOR, KIDS_DEFAULT_COLOR);
							end
						end
						local new_stats = str_fmt([[<div style="color:%s">%s</div>]], color, v1);						
						if(not str_find(self.self_stats,new_stats,1,true) or self.gsid ~= gsid)then
							text = text .. new_stats
						end
					end
				end
			end

		else
			for type, value in pairs(stats) do
				local word = self:GetStatsByType(type, value);
				if(word) then
					local color = if_else(TEEN_VERSION, DEFAULT_COLOR, KIDS_DEFAULT_COLOR);
					if(type == 46) then
						color = if_else(TEEN_VERSION, LIMITED_COLOR, KIDS_LEVEL_LIMITED);
						local RemainingDays = self:getStatExpireRemainingDays()
						if(RemainingDays and RemainingDays ~= "") then
							color = if_else(TEEN_VERSION, DEFAULT_COLOR, KIDS_DEFAULT_COLOR);
						end
					elseif(type == 10047) then
						color = if_else(TEEN_VERSION, LIMITED_COLOR, KIDS_LEVEL_LIMITED);
						local RemainingDays = self:getStatExpireRemainingDays()
						if(RemainingDays and RemainingDays ~= "") then
							color = if_else(TEEN_VERSION, DEFAULT_COLOR, KIDS_DEFAULT_COLOR);
						end
					elseif(type == 10048) then
						color = if_else(TEEN_VERSION, LIMITED_COLOR, KIDS_LEVEL_LIMITED);
						local RemainingDays = self:getStatExpireRemainingDays()
						if(RemainingDays and RemainingDays ~= "") then
							color = if_else(TEEN_VERSION, DEFAULT_COLOR, KIDS_DEFAULT_COLOR);
						end
					end
					local new_stats = str_fmt([[<div style="color:%s">%s</div>]], color, word);
					if(not str_find(self.self_stats,new_stats,1,true) or self.gsid ~= gsid)then
						text = text .. new_stats
					end
				end
			end
		end

		local RemainingDays = self:getStatExpireRemainingDays()
		if(RemainingDays and RemainingDays ~= "")then
			local new_stats = str_fmt([[<div style="color:%s">剩余有效期:%s</div>]], if_else(TEEN_VERSION,LIMITED_COLOR,KIDS_LEVEL_LIMITED),RemainingDays);
			text = text .. new_stats;
		end
	end	
	return text;
end

function ObjectTooltipInfo:getTempStats(code,value)
	if(self.item and self.item.template)then
		if(code)then
			if(value)then
				return self.item.template.stats[code] or value
			else
				return self.item.template.stats[code]
			end
		end
	end
end

function ObjectTooltipInfo:IsMountPetTranPill(persist_time_exid)
	persist_time_exid = persist_time_exid or self:getTempStats(51);
	if(self.item and self.item.template and persist_time_exid and self.item.template.subclass == 6 and self.item.template.class == 2 )then
		return true;
	end
	return false;
end

function ObjectTooltipInfo:getExchangeTemp(exid,gsid)
	local temp = GetExtTemp(exid);
	if(temp)then
		return temp.tos or {}
	end

	self:LOG("GetExtTemp","unrecognize exid: " .. (exid or "nil"))
	return {};
end

function ObjectTooltipInfo:breakLineProcess(text)
	text = text or ""
	local v = string.gsub(text, "%#", "<br/>")
	v = string.gsub(v, "\n", "<br/>")
	return v or "";
end

function ObjectTooltipInfo:getStatExpireRemainingDays()
	if(self.gsid < 0 or not self.gsid)then return "" end
    
	local _, d, h, m = ItemManager.ExpireRemainingTime(self.goods);
	if(_ and _ > 0 and d and h and m) then
		if(d > 0) then
			return format("%d天", d);
		elseif(h > 0) then
			return format("%d小时", h);
		elseif(m > 0) then
			return format("%d分钟", m);
		end
	elseif(_ and _ < 0) then
		return "已经过期";
	else
		return "";
	end

    --if(self.gsid >= 1789 and self.gsid <= 1794) then
        local expiretime;
        if(self.item)then
            if(self.item.template.expiretype == 1 and self.item.template.expiretime) then
                expiretime = self.item.template.expiretime;
            end
        end
        if(self.goods and self.goods.obtaintime and expiretime) then
            local year, month, day, hour, mins = string.match(self.goods.obtaintime, "^(%d-)%-(%d-)%-(%d-)%D(%d+)%D(%d+)");
		    if(year and month and day) then
			    year = tonumber(year)
			    month = tonumber(month)
			    day = tonumber(day)
                if(year and month and day) then
                    local daysfrom_1900_1_1 = commonlib.GetDaysFrom_1900_1_1(year, month, day);
                    local serverdate = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
                    local year, month, day = string.match(serverdate, "^(%d+)%-(%d+)%-(%d+)$");
		            if(year and month and day) then
			            year = tonumber(year)
			            month = tonumber(month)
			            day = tonumber(day)
                        if(year and month and day) then
                            local daysfrom_1900_1_1_today = commonlib.GetDaysFrom_1900_1_1(year, month, day);
                            if(daysfrom_1900_1_1_today and daysfrom_1900_1_1) then
								local days_left = daysfrom_1900_1_1 + expiretime - daysfrom_1900_1_1_today;

								hour = tonumber(hour);
								mins = tonumber(mins);

								local server_time = MyCompany.Aries.Scene.GetServerTime()
								if(server_time) then
									local now_hour, now_mins = server_time:match("^(%d+)%D(%d+)");
									now_hour = tonumber(now_hour);
									now_mins = tonumber(now_mins);

									if(days_left>0) then
										return format("%d天", days_left);
									elseif(now_hour < hour) then
										return format("%d小时", hour - now_hour);
									elseif(now_hour ==  hour and now_mins < mins) then
										return format("%d分钟", mins - now_mins);
									else
										return "已经过期";
									end
								end
                            end
                        end
                    end
                end
            end
        end
    --end

    return "";
end

--function for test self equipped item and current item
function ObjectTooltipInfo:EquippedItemTest()
	if(self.equipped_item and self.equipped_item.guid ~= self.guid and not self.user_nid)then return true end
	return false;
end

function ObjectTooltipInfo:SetupDiffStats()
	local i3,v3
	for i3,v3 in ipairs(self.ordered_stat)do
		if(v3.diff_stats ~= 0)then
			local with_percent = false;
			if(TEEN_VERSION) then
				if(v3.key_typ == "速度" or v3.key_typ == "魔力" or v3.key_typ == "攻击" or v3.key_typ == "防御") then
					with_percent = true;
				end
			end
			self.diff_stats[#self.diff_stats + 1] = str_fmt([[<div style="color:%s;">%s:%s%s</div>]],
			if_else(v3.diff_stats > 0,GREEN2,RED2),v3.key_typ or "unknown attr",if_else(v3.diff_stats > 0,"+",""),
			v3.diff_stats..if_else(with_percent, "%", ""));
		end
	end
end

local skipped_diff_stats = {
	[253] = true,
};

function ObjectTooltipInfo:CalcDiffStats(src_item,dest_item)
	self:LOG("src_item:" ,(src_item or "nil"));
	self:LOG("dest_item:" ,(dest_item or "nil"));

	if(dest_item and dest_item.template.class == 2 and dest_item.template.subclass == 6) then
		local exid = dest_item.template.stats[51];
		if(exid) then
			local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
			if(exTemplate and exTemplate.tos and exTemplate.tos[1] and exTemplate.tos[1].key) then
				local gsid = exTemplate.tos[1].key;
				local pill_globalstoreitem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				if(pill_globalstoreitem) then
					dest_item = pill_globalstoreitem;
				end
			end
		end
	end

	local src_item_stats;
	if(src_item and src_item.template and src_item.template.stats) then
		src_item_stats = src_item.template.stats
	else
		src_item_stats = {};
	end

	local dest_item_stats;
	if(dest_item and dest_item.template and dest_item.template.stats) then
		dest_item_stats = dest_item.template.stats;
	else
		dest_item_stats = {};
	end

	for k,v in pairs(src_item_stats)do
		for i3,v3 in ipairs(self.ordered_stat)do
			if(not skipped_diff_stats[k] and stat_map[k] and stat_map[k].str_format and key_words_map[i3])then
				if(str_find(stat_map[k].str_format,key_words_map[i3]))then
					v3.diff_stats = v3.diff_stats - v 
					if(not v3.key_typ)then
						v3.key_typ = key_words_map[i3]
						break;
					end
				end
					
			end
		end
	end
	for k,v in pairs(dest_item_stats)do
		for i3,v3 in ipairs(self.ordered_stat)do
			if(not skipped_diff_stats[k] and stat_map[k] and stat_map[k].str_format and key_words_map[i3])then
				if(str_find(stat_map[k].str_format,key_words_map[i3]))then
					v3.diff_stats = v3.diff_stats + v 
					if(not v3.key_typ)then
						v3.key_typ = key_words_map[i3]
						break;
					end
				end
					
			end
		end
	end

end

function ObjectTooltipInfo.GetItemTooltip(gsid)
    local has,guid,bag,copies = hasGSItem(gsid)
    return string.format("page://script/apps/Aries/Desktop/GenericTooltip_InOne.html?gsid=%s&guid=%s",gsid,guid or -999);   
end

function ObjectTooltipInfo.IsPet(gsItem)
    if (gsItem.template.class==11 and gsItem.template.subclass==1) then
        return true;
    else
        return false;
    end
end

local schoolnm={[988]="风暴系",[990]="生命系",[991]="死亡系",[987]="寒冰系",[986]="烈火系",};
function ObjectTooltipInfo.GetPetMaxlvlProp(gsid, item_instance)
	if(TEEN_VERSION)then
		return ObjectTooltipInfo.GetPetMaxlvlProp_Teens(gsid, item_instance);
	else
		return ObjectTooltipInfo.GetPetMaxlvlProp_Kids(gsid, item_instance);
	end
end
function ObjectTooltipInfo.GetPetMaxlvlProp_Kids(gsid, item_instance)
	local provider = CombatPetHelper.GetClientProvider();
	local pets_map = provider:GetAllPets();
	local pet_node = pets_map[gsid];
	if(not pet_node)then
		return "";
	end
	local exp = 0;
	local bHasItem,guid; -- = hasGSItem(gsid);
	item_instance = ItemManager.GetItemByGUID(guid);
	if(item_instance and item_instance.GetExp)then
		exp = item_instance:GetExp();
	end
	--当前级别附加属性卡牌
	local cur_props_list = provider:Get_Props_List(provider:GetCurLevelProps(gsid,exp)) or {};
	local cur_cards_list = provider:Get_Cards_List(provider:GetCurLevelCards(gsid,exp)) or {};
	--满级附加属性卡牌
	local max_props_list = provider:Get_Props_List(provider:GetTemplateMaxLevelProps(gsid)) or {};
	local max_cards_list = provider:Get_Cards_List(provider:GetTemplateMaxLevelCards(gsid)) or {};

    local isvippet = pet_node.isvip or false;
    local needschool = pet_node.school_requirement or "";
    local requirelvl = pet_node.combatlevel_requirement or 0;
	
	local level,cur_exp,total_exp,isfull,state,state_str = provider:IsFull(gsid,exp);
	local s="";
	if (requirelvl>0) then
		if(Player.GetLevel() < requirelvl)then
			s = str_fmt([[%s<div style="color:%s;font-weight:bold;">需要战斗等级:%s</div>]], s, if_else(TEEN_VERSION,LIMITED_COLOR, KIDS_LEVEL_LIMITED),requirelvl);
		else
			s = str_fmt([[%s<div >需要战斗等级:%s</div>]], s, requirelvl);
		end
    end
    local level_str = "";
	if(bHasItem)then
		if(isfull)then
			level_str = string.format([[<div style="color:%s;font-weight:bold">满级</div>]],if_else(TEEN_VERSION,"#5bf00f", "#000000"));
		else
			if(state == "senior")then
				level_str = string.format([[<div style="color:#651502;">%s:%d级</div>]],state_str,level);
			else
				level_str = string.format([[<div>%s:%d级</div>]],state_str,level);
			end
		end
		s = s .. level_str;
	end    
	
	if(isfull or not bHasItem)then
		if(max_props_list and #max_props_list > 0)then
			s = s.."满级附加属性：<div style='margin-left:10px;'>";
			local k,v; 
			for k,v in pairs(max_props_list) do
				s = format("%s%s<br/>", s, ObjectTooltipInfo:GetStatsByType(v.stat_id,v.value));
			end
			s = s .. "</div>";
		end
		if(max_cards_list and #max_cards_list > 0)then
			s= s .. "满级卡片：<div style='margin-left:10px;'>"
			for k,v in ipairs(max_cards_list) do
				s=format("%s<pe:item gsid=\"%s\" style=\"width:36px;height:36px;margin-left:1px;margin-top:1px;\"/>",s,v.gsid);
			end
			s = s .. "</div>";
		end
	else
		if(cur_props_list and #cur_props_list > 0)then
			s = s.."当前附加属性：<div style='margin-left:10px;'>";
			local k,v; 
			for k,v in pairs(cur_props_list) do
				s = format("%s%s<br/>", s, ObjectTooltipInfo:GetStatsByType(v.stat_id,v.value));
			end
			s = s .. "</div>";
		end
		if(cur_cards_list and #cur_cards_list > 0)then
			s= s .. "当前卡片：<div style='margin-left:10px;'>"
			for k,v in ipairs(cur_cards_list) do
				s=format("%s<pe:item gsid=\"%s\" style=\"width:36px;height:36px;margin-left:1px;margin-top:1px;\"/>",s,v.gsid);
			end
			s = s .. "</div>";
		end
		if(max_props_list and #max_props_list > 0)then
			s = s.."满级附加属性：<div style='margin-left:10px;'>";
			for k,v in pairs(max_props_list) do
				s = format("%s%s<br/>", s, ObjectTooltipInfo:GetStatsByType(v.stat_id,v.value));
			end
			s = s .. "</div>";
		end
		if(max_cards_list and #max_cards_list > 0)then
			s= s .. "满级卡片：<div style='margin-left:10px;'>"
			for k,v in ipairs(max_cards_list) do
				s=format("%s<pe:item gsid=\"%s\" style=\"width:36px;height:36px;margin-left:1px;margin-top:1px;\"/>",s,v.gsid);
			end
			s = s .. "</div>";
		end
	end
    if (isvippet) then
        s=format("%s魔法星用户专用<br/>",s);
    end

    if (needschool~="") then            
        s=format("%s%s专用<br/>",s,schoolnm[tonumber(needschool)]);
    end
    return s;
end
function ObjectTooltipInfo.GetPetMaxlvlProp_Teens(gsid, item_instance)
	local exp = 0;
	local bHasItem,guid = hasGSItem(gsid);
	item_instance = ItemManager.GetItemByGUID(guid);
	if(item_instance and item_instance.GetExp)then
		exp = item_instance:GetExp();
	end
	local pet_config = CombatPetConfig.GetInstance_Client();
	local levels_info = pet_config:GetLevelsInfo(gsid,exp)
	local row = pet_config:GetRow(gsid);
	if(not levels_info or not row)then
		return
	end
	local cur_level = levels_info.cur_level;
	local is_full = levels_info.is_full;
	local stat_list = levels_info.stat_list;
	local entity_stat_list = levels_info.entity_stat_list;
	local cards_list = levels_info.cards_list;
	local entity_cards_list = levels_info.entity_cards_list;

	local cur_stat_list = levels_info.cur_stat_list;
	local cur_entity_stat_list = levels_info.cur_entity_stat_list;
	local cur_cards_list = levels_info.cur_cards_list;
	local cur_entity_cards_list = levels_info.cur_entity_cards_list;

	if(bHasItem)then
		stat_list = cur_stat_list;
		entity_stat_list = cur_entity_stat_list;
		cards_list = cur_cards_list;
		entity_cards_list = cur_entity_cards_list;
	end
	local s="";
	if(stat_list and #stat_list > 0)then
		s = s.."属性(辅助主人)：<div style='margin-left:10px;'>";
		local k,v; 
		for k,v in pairs(stat_list) do
			if(v.stat and v.value)then
				s = format("%s%s<br/>", s, ObjectTooltipInfo:GetStatsByType(v.stat,v.value) or "");
			end
		end
		s = s .. "</div>";
	end
	if(cards_list and #cards_list > 0)then
		s= s .. "卡片(辅助主人)：<div style='margin-left:10px;'>"
		for k,v in ipairs(cards_list) do
			if(v.gsid)then
				s=format("%s<pe:item gsid=\"%d\" style=\"width:36px;height:36px;margin-left:1px;margin-top:1px;\"/>",s,v.gsid);
			end
		end
		s = s .. "</div>";
	end
	local s1 = s;
	s = "";
	if(entity_stat_list and #entity_stat_list > 0)then
		s = s.."属性(自身战力)：<div style='margin-left:10px;'>";
		local k,v; 
		for k,v in pairs(entity_stat_list) do
			if(v.stat and v.value)then
				s = format("%s%s<br/>", s, ObjectTooltipInfo:GetStatsByType(v.stat,v.value) or "");
			end
		end
		s = s .. "</div>";
	end
	if(entity_cards_list and #entity_cards_list > 0)then
		s= s .. "卡片(自身战力)：<div style='margin-left:10px;'>"
		for k,v in ipairs(entity_cards_list) do
			if(v.gsid)then
				s=format("%s<pe:item gsid=\"%d\" style=\"width:36px;height:36px;margin-left:1px;margin-top:1px;\"/>",s,v.gsid);
			end
		end
		s = s .. "</div>";
	end
	local s2 = s;
	local level_str = "";
	if(bHasItem)then
		if(is_full)then
			level_str = string.format("满级(%d)",cur_level);
		else
			level_str = string.format("等级:%d",cur_level);
		end
	end
	s = string.format([[%s<div style="width:320px;"><div style="float:left;width:160px;">%s</div><div style="float:left;width:160px;">%s</div></div>]],level_str,s2,s1)
    return s;
end

function ObjectTooltipInfo:IsFashionEquip(subclass)
	return subclass == 18 or subclass == 19 or subclass == 70 or subclass == 71;
end

--load information of object for display
function ObjectTooltipInfo:Init()
	self.page = document:GetPageCtrl();

	self.gsid  = self.page:GetRequestParam("gsid");
	self.guid = self.page:GetRequestParam("guid")
	self.user_nid = self.page:GetRequestParam("nid")
	self.hdr = self.page:GetRequestParam("hdr");
	self.exp = self.page:GetRequestParam("exp");
	self.serverdata = self.page:GetRequestParam("serverdata");
	if(self.serverdata) then
		self.with_serverdata = true;
	end
	if(self.serverdata == "") then
		self.serverdata = nil;
	end
	
	self.gsid = tonumber(self.gsid) or -999;
	self.guid = tonumber(self.guid) or -999;
	
	self:LOG("self.gsid",self.gsid);
	self:LOG("self.guid",self.guid);
	self:LOG("self.user_nid",self.user_nid);
	
	local equip_from_shop;
	local test_guid = self:GetGUID(self.gsid)
	if(not self.guid or self.guid == -999 or test_guid ~= self.guid)then
		if(self.guid == -999)then
			equip_from_shop = 0;
		end
	end
	self.user_nid = if_else(not self.user_nid or self.user_nid == "nil",nil,tonumber(self.user_nid))
	self.avatar_school = Combat.GetSchool(self.user_nid);

	self.item = getItemByGsid(self.gsid);	
	if(not equip_from_shop)then
		if(self.serverdata) then
			self.guid = 0;
			self.goods = ItemManager.CreateItem({gsid = self.gsid, guid=0, serverdata = self.serverdata, copies = 1});
		else
			if(self.guid == test_guid or not self.user_nid )then
				if(self.guid and self.guid > 0) then
					self.goods = getItemByGuid(self.guid);
				else
					self.guid = self:GetGUID(self.gsid)
					self.goods = getItemByGuid(self.guid);
				end
			else
				self:LOG("GetOPCItemByNidGuid:",self.guid);
				self.goods = GetOPCItemByNidGuid(self.user_nid,self.guid);	
			end
		end
	else
		if(self.serverdata) then
			self.goods = ItemManager.CreateItem({gsid = self.gsid, guid=self.guid, serverdata = self.serverdata, copies = 1});
			-- if items has serverdata it will not be equipment from shop
			equip_from_shop = nil;
		end
	end
	if(self.goods and self.goods.serverdata and self.goods.serverdata~="") then
		local get_server_data = self.goods.GetServerData or System.Item.Item_CombatApparel.GetServerData;
		local server_data = get_server_data(self.goods);
		if(type(server_data) == "table") then
			if(server_data.voucher and server_data.voucher.code) then
				self.extra_stats = self.extra_stats..format("<div style='color:%s;'>活动码:%s</div>", if_else(TEEN_VERSION,YELLOW,KIDS_LEVEL_LIMITED), tostring(server_data.voucher.code));
			end
		end
	end

	self:LOG("self.item",self.item);
	self:LOG("self.goods",self.goods);
	
	if(not self.item.gsid)then return;end
	ObjectTooltipInfo:_GenOrderedStats();
	--set equip color by quality
	self.quality = self:getTempStats(221, -1);

	local item_name = "undefined name";
	if(self.item and self.item.template)then
		local gsid = self:getTempStats(56);

		if(gsid)then
			local item = getItemByGsid(gsid);
			item_name= item.template.name or "undefined name"
		else
			item_name= self.item.template.name or "undefined name"
		end
	end
		
	local addon_level;
	if(self.goods and self.goods.CanHaveAddonProperty and self.goods:CanHaveAddonProperty()) then
		addon_level = self.goods:GetAddonLevel();
        local attack_absolute = self.goods:GetAddonAttackAbsolute() or self.goods:GetAddonAttackPercentage();
        if(attack_absolute and attack_absolute > 0) then
            self.addon_perperty_section = format([[%s<div style="font-size:12px;color:%s;">强化攻击: +%s%%</div>]], self.addon_perperty_section, if_else(TEEN_VERSION,"#40dd2a",KIDS_EQUIP_SUIT),attack_absolute);
		end
        local resist_absolute = self.goods:GetAddonResistAbsolute();
        if(resist_absolute and resist_absolute > 0) then
			if(System.options.version == "teen") then
				self.addon_perperty_section = format([[%s<div style="font-size:12px;color:%s;">强化防御: +%s%%</div>]], self.addon_perperty_section, if_else(TEEN_VERSION,"#40dd2a",KIDS_EQUIP_SUIT),resist_absolute);
			elseif(System.options.version == "kids") then
				self.addon_perperty_section = format([[%s<div style="font-size:12px;color:%s;">强化受到伤害: -%s%%</div>]], self.addon_perperty_section, if_else(TEEN_VERSION,"#40dd2a",KIDS_EQUIP_SUIT),resist_absolute);
			end
            
		end
		local hp_absolute = self.goods:GetAddonHpAbsolute();
        if(hp_absolute and hp_absolute > 0) then
            self.addon_perperty_section = format([[%s<div style="font-size:12px;color:%s;">强化HP: +%s</div>]], self.addon_perperty_section, if_else(TEEN_VERSION,"#40dd2a",KIDS_EQUIP_SUIT),hp_absolute);
		end
		local criticalstrike_percent = self.goods:GetCriticalStrikePercent();
        if(criticalstrike_percent and criticalstrike_percent > 0) then
            self.addon_perperty_section = format([[%s<div style="font-size:12px;color:%s;">强化暴击: +%s</div>]], self.addon_perperty_section, if_else(TEEN_VERSION,"#40dd2a",KIDS_EQUIP_SUIT),criticalstrike_percent);
		end
		local resilience_percent = self.goods:GetResiliencePercent();
        if(resilience_percent and resilience_percent > 0) then
            self.addon_perperty_section = format([[%s<div style="font-size:12px;color:%s;">强化韧性: +%s</div>]], self.addon_perperty_section, if_else(TEEN_VERSION,"#40dd2a",KIDS_EQUIP_SUIT),resilience_percent);
		end

		if(addon_level == 0)then
			self.addon_perperty_section = format([[<div style="font-size:12px;color:%s;">尚未强化</div>]],if_else(TEEN_VERSION,"#40dd2a",KIDS_EQUIP_SUIT));
		else
			item_name = item_name .. "+" .. tostring(addon_level);
        end
    end

	local RemainingDays = self:getStatExpireRemainingDays()
	if(RemainingDays and RemainingDays ~= "")then
		item_name = format([[%s<span style="color:%s">(%s)</span>]], item_name, if_else(TEEN_VERSION,LIMITED_COLOR,KIDS_LEVEL_LIMITED),RemainingDays);
	end

	local equip_color = self.GetEquipColor(self.quality);


	local pet_config = CombatPetConfig.GetInstance_Client();
	if(TEEN_VERSION and pet_config:IsCombatPet(self.gsid))then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(self.gsid);
		--青年版宠物品质
		local pet_name = "";
		if(gsItem)then
			pet_name = gsItem.template.name;
		end
			self.name = pet_config:BuildColorName(pet_name,self.gsid);
		--if(not self.hdr or self.hdr == "")then
			--pet_name = pet_config:BuildColorName(pet_name,self.gsid);
			--self.name = pet_name;
		--else
			--self.name = string.format([[<div style="color:%s;">%s</div>%s]],CURRENT_EQUIP_COLOR,self.hdr,pet_name);
		--end
	else
		if(not self.hdr or self.hdr == "")then
			self.name = str_fmt([[<div style="color:%s;">%s</div>]],if_else(TEEN_VERSION,equip_color,if_else(addon_level,KIDS_TARGET_COLOR,KIDS_DEFAULT_COLOR)),item_name);
		else
			self.name = str_fmt([[<div style="color:%s;">%s</div><div style="color:%s;">%s</div>]],
				if_else(TEEN_VERSION,CURRENT_EQUIP_COLOR,KIDS_HDR_COLOR), self.hdr,
				if_else(TEEN_VERSION,equip_color,if_else(addon_level, KIDS_TARGET_COLOR, KIDS_DEFAULT_COLOR)), item_name);
		end
	end
	self.diff_stats = {}
	
	self:InitEquippedItem();
	if(self:EquippedItemTest())then
		local src_item = getItemByGsid(self.equipped_item.gsid)
		self:CalcDiffStats(src_item,self.item);

		local attack_absolute2;
		if(self.equipped_item.CanHaveAddonProperty and self.equipped_item:CanHaveAddonProperty()) then
			attack_absolute2 = self.equipped_item:GetAddonAttackAbsolute() or self.equipped_item:GetAddonAttackPercentage() --if_else(TEEN_VERSION,self.goods:GetAddonAttackAbsolute(),self.goods:GetAddonAttackPercentage());
			if(attack_absolute2 and attack_absolute2 > 0) then
				if(attack_absolute and attack_absolute > 0)then	
					self.ordered_stat[4].diff_stats = self.ordered_stat[4].diff_stats + attack_absolute - attack_absolute2				
				else
					self.ordered_stat[4].diff_stats = self.ordered_stat[4].diff_stats - attack_absolute2				
				end	
				self.ordered_stat[4].key_typ = "攻击"				
			else
				if(attack_absolute and attack_absolute > 0)then
					self.ordered_stat[4].diff_stats = self.ordered_stat[4].diff_stats + attack_absolute					
					self.ordered_stat[4].key_typ = "攻击"
				end
			end
		else
			if(attack_absolute and attack_absolute > 0)then
				self.ordered_stat[4].diff_stats = self.ordered_stat[4].diff_stats + attack_absolute					
				self.ordered_stat[4].key_typ = "攻击"
			end
		end

		local resist_absolute2;
		if(self.equipped_item.CanHaveAddonProperty and self.equipped_item:CanHaveAddonProperty()) then
			resist_absolute2 = self.equipped_item:GetAddonResistAbsolute() or self.equipped_item:GetAddonResistAbsolute()
			if(resist_absolute2 and resist_absolute2 > 0) then
				if(resist_absolute and resist_absolute > 0)then	
					self.ordered_stat[5].diff_stats = self.ordered_stat[5].diff_stats + resist_absolute - resist_absolute2				
				else
					self.ordered_stat[5].diff_stats = self.ordered_stat[5].diff_stats - resist_absolute2				
				end	
				self.ordered_stat[5].key_typ = "防御"				
			else
				if(resist_absolute and resist_absolute > 0)then
					self.ordered_stat[5].diff_stats = self.ordered_stat[5].diff_stats + resist_absolute					
					self.ordered_stat[5].key_typ = "防御"
				end
			end
		else
			if(resist_absolute and resist_absolute > 0)then
				self.ordered_stat[5].diff_stats = self.ordered_stat[5].diff_stats + resist_absolute					
				self.ordered_stat[5].key_typ = "防御"
			end
		end


	end
		
	if(self.item.template.canexchange and self.item.template.cangift )then
		if(self.item.template.class == 1 and not self.item.template.stats[521] and  self.goods and self.goods.IsUsed and self.goods:IsUsed()) then
			self.trade = str_fmt([[<div style="color:%s;">已使用(不可交易)</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR));
		else
			self.trade = str_fmt([[<div style="color:%s;">可交易</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR));
		end
	else
		if(TEEN_VERSION) then
			if(self.with_serverdata) then
				self.trade = str_fmt([[<div style="color:%s;">%s</div>]], YELLOW, "绑定物品");
			else
				if(not equip_from_shop) then
					self.trade = str_fmt([[<div style="color:%s;">%s</div>]], YELLOW, "绑定物品");
				end
			end
		else
			if(not equip_from_shop) then
				self.trade = str_fmt([[<div style="color:%s;">%s</div>]], KIDS_LEVEL_LIMITED, "不可交易");
			end
		end
	end
	
	if(self.item.template.stats[61]) then
		if(TEEN_VERSION) then
			self.trade = str_fmt([[<div style="color:%s;">飞行坐骑</div>]], YELLOW);
		end
	end
	
	if(self.guid ~= -999 and self.gsid == -999)then
		self.icon = str_fmt([[<pe:slot isclickable="false" guid="%d" style="width:48px;height:48px;"/>]],self.guid);
	elseif(self.guid ~= -999 and self.gsid ~= -999) then
		self.icon = str_fmt([[<pe:item isclickable="false" gsid="%d" style="width:48px;height:48px;"/>]],self.gsid);
	elseif(self.gsid ~= -999) then
		self.icon = str_fmt([[<pe:item isclickable="false" gsid="%d" style="width:48px;height:48px;"/>]],self.gsid);
	end

	local closest_level,content_17150,canopen_17150;
	if(self.gsid == 17150)then
		local bHas_17150, _, __, copies_17150 = hasGSItem(50320);
		if(bHas_17150 and copies_17150) then
			closest_level = level_map[copies_17150];
			content_17150 = content_map[copies_17150];
			if(closest_level) then
				local mylevel = Combat.GetMyCombatLevel();
				if(closest_level <= mylevel) then
					canopen_17150 = true;
				else
					canopen_17150 = false;
				end
			end
		end
		local item_name = "";
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(17150);
		if(gsItem) then
			item_name = gsItem.template.name;
		end
		self.name = str_fmt([[<div style="color:%s">%s</div>]], if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR), item_name);
		if(canopen_17150)then
		self.description = self.description .. str_fmt([[<div style="color:%s">可打开</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR));
		else
		self.description = self.description .. str_fmt([[<div style="color:%s;">%s级可打开</div>]],if_else(TEEN_VERSION,LIMITED_COLOR,KIDS_LEVEL_LIMITED),(closest_level or content_map[10]));
		end

		self.description = self.description .. str_fmt([[<div style="color:%s"><div >包含:</div><div style="margin-left:10px;">%s</div></div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR),(content_17150 or content_map[10]));
		return;
	end

	if(self:IsEquip())then
		local durability;
		local max_durability = self:getTempStats(222);
		if(max_durability and self.goods and self.goods.GetDurability)then
			durability = self.goods:GetDurability();
			if(durability < 0)then durability = 0 end
		end

		if(durability and max_durability)then
			if(durability >= (max_durability*0.2))then
				self.durability = str_fmt([[<div style="color:%s">耐久度:%s/%s</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR),durability,max_durability);
			else
				self.durability = str_fmt([[<div style="color:%s;">耐久度:%s/%s</div>]],LIMITED_COLOR,durability,max_durability);
			end
		elseif(max_durability)then
			self.durability = str_fmt([[<div style="color:%s">耐久度:%s/%s</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR),max_durability,max_durability);
		end
	end

	if(RemainingDays and RemainingDays ~= "")then
		self.durability = format([[%s<div style="color:%s">使用中</div>]], self.durability or "", if_else(TEEN_VERSION,LIMITED_COLOR,KIDS_LEVEL_LIMITED));
	end

	--mount pets
	local persist_time_exid = self:getTempStats(51);
	local bPetTranPills = self:IsMountPetTranPill(persist_time_exid)
	-- if the stats[56] or stats[57] is not nil, this is the combat pill
	local stats_ref = self:getTempStats(56) or self:getTempStats(57);

	if(bPetTranPills)then
		local i,v 

		for i,v in pairs(self.item.template.stats)do
			if(i == 138)then
				self.level = str_fmt([[<div style="color:%s">使用等级:%s</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR),v);
			else
				local word = self:GetStatsByType(i, v);
				if(word)then
					self:SetDesc(i,word);
				end
			end
		end

		if(self.item.template.expiretype == 1 and self.item.template.expiretime) then
			local persist_time = self.item.template.expiretime;
			local word = self:GetStatsByType(46, persist_time);
			if(word)then
				self:SetDesc(46,word);
			end
		elseif(self.item.template.expiretype == 2 and self.item.template.expiretime) then
			local persist_time = self.item.template.expiretime;
			local word = self:GetStatsByType(10047, persist_time);
			if(word)then
				self:SetDesc(10047,word);
			end
		elseif(self.item.template.expiretype == 3 and self.item.template.expiretime == 1) then
			local persist_time = self.item.template.expiretime;
			local word = self:GetStatsByType(10048, persist_time);
			if(word)then
				self:SetDesc(10048,word);
			end
		elseif(self.item.template.expiretype == 5) then
			local persist_time = self.item.template.expiretime;
			local word = self:GetStatsByType(10049, persist_time);
			if(word)then
				self:SetDesc(10049,word);
			end
		end

		local items = ObjectTooltipInfo:getExchangeTemp(persist_time_exid);

		for i,v in ipairs(items)do
			self.self_stats  = self.self_stats .. self:getStatsByGsid(0,v.key);
		end
	elseif(not bPetTranPills and persist_time_exid)then
		self.description = self:breakLineProcess(self.item.template.description)
	elseif(self.item and self.item.template and self.item.template.subclass == 6 and self.item.template.class == 2 )then
		self.self_stats  = self:getStatsByGsid(0);
	elseif(self.item and self.item.template and self.item.template.subclass == 8 and self.item.template.class == 2 )then
		if(self.item.template.expiretype == 1 and self.item.template.expiretime) then
			local persist_time = self.item.template.expiretime;
			local word = self:GetStatsByType(46, persist_time);
			if(word)then
				self:SetDesc(46,word);
			end
		elseif(self.item.template.expiretype == 2 and self.item.template.expiretime) then
			local persist_time = self.item.template.expiretime;
			local word = self:GetStatsByType(10047, persist_time);
			if(word)then
				self:SetDesc(10047,word);
			end
		elseif(self.item.template.expiretype == 3 and self.item.template.expiretime == 1) then
			local persist_time = self.item.template.expiretime;
			local word = self:GetStatsByType(10048, persist_time);
			if(word)then
				self:SetDesc(10048,word);
			end
		elseif(self.item.template.expiretype == 5) then
			local persist_time = self.item.template.expiretime;
			local word = self:GetStatsByType(10049, persist_time);
			if(word)then
				self:SetDesc(10049,word);
			end
		end

		self.self_stats  = self:getStatsByGsid(0);
	elseif(self.item.template.subclass == 2 and self.item.template.class == 100 )then
	else
		if(self.item.template.expiretype == 1 and self.item.template.expiretime) then
			local persist_time = self.item.template.expiretime;
			local word = self:GetStatsByType(46, persist_time);
			if(word)then
				self:SetDesc(46,word);
			end
		elseif(self.item.template.expiretype == 2 and self.item.template.expiretime) then
			local persist_time = self.item.template.expiretime;
			local word = self:GetStatsByType(10047, persist_time);
			if(word)then
				self:SetDesc(10047,word);
			end
		elseif(self.item.template.expiretype == 3 and self.item.template.expiretime) then
			local persist_time = self.item.template.expiretime;
			local word = self:GetStatsByType(10048, persist_time);
			if(word)then
				self:SetDesc(10048,word);
			end
		elseif(self.item.template.expiretype == 5) then
			local persist_time = self.item.template.expiretime;
			local word = self:GetStatsByType(10049, persist_time);
			if(word)then
				self:SetDesc(10049,word);
			end
		end
		self.self_stats  = self:getStatsByGsid(0);
	end
	
	if(stats_ref)then
		self.self_stats = self.self_stats .. self:getStatsByGsid(0,stats_ref);
	end

	if(self.item.template.maxcopiesinstack and self.item.template.maxcopiesinstack > 1)then
		local title = if_else(TEEN_VERSION, "拥有上限", "堆叠上限");
		self.self_stats = self.self_stats .. str_fmt([[<div style="color:%s">%s：%s</div>]], if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR), title, if_else(self.item.template.maxcopiesinstack>=99999,"无限制",self.item.template.maxcopiesinstack) )
	end

	if(self.IsPet(self.item)) then
		local s = self.GetPetMaxlvlProp(self.item.gsid, self.goods);
		self.self_stats = self.self_stats .. s;
	end


	self:LOG("self.self_stats:",self.self_stats)

	--if(self.gsid == 12001)then
		--self.description = [[<div>平日使用,使用后20场战斗经验<br/>加成100%,可以和假日努力药丸<br/>叠加</div>]]
		--return;
	--end
	
	if(self.item and self.item.template and self.item.template.description ~= self.item.template.name)then
		local stats_34 = self.item.template.stats[34];
		local stats_56 = self:getTempStats(56)
		local stats_62 = self:getTempStats(62);--stats_62{1 = RED,2 = YELLOW}

		if(stats_34)then
			local stats_34_desc = str_fmt(stat_map[34].str_format, tostring(stats_34 * 100))
			if(stats_34_desc ~= self.item.template.description)then
				self.description = self:breakLineProcess(self.item.template.description)	
			end
		elseif(stats_56)then
			local item = getItemByGsid(stats_56)
			self.description = self:breakLineProcess(item.template.description)
		elseif(stats_62)then
			self.description = self:breakLineProcess(self.item.template.description)
			self.description = str_fmt([[<div style="color:%s;">%s</div>]],STATS_COLOR_TABLE[stats_62] or DEFAULT_COLOR,self.description);
		else
			self.description = self:breakLineProcess(self.item.template.description)		
		end
	end

	local max_capacity = self:getTempStats(167);
	if(max_capacity and max_capacity > 0)then
		self.description = self.description ..str_fmt([[<div style="color:%s">最多可放卡牌:%s张</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR),max_capacity);
	end

	local repeat_count = self:getTempStats(170);
	if(repeat_count and repeat_count > 0)then
		self.description = self.description ..str_fmt([[<div style="color:%s">单张卡牌最多可放:%s张</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR),repeat_count);
	end

	if(self.item and self.item.click_url) then
		self.description = self.description ..str_fmt([[<div style="color:%s">点击打开网站</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR));
	end

	if(System.options.isAB_SDK and (self.gsid or self.guid) ) then
		self.description = self.description ..str_fmt([[<div>guid:%d gsid:%d</div>]],self.guid or 0, self.gsid or 0);
		if(self.guid~=nil and self.goods and type(self.goods.serverdata) == "string"  and type(self.goods.serverdata) ~= "") then
			self.description = self.description ..str_fmt([[<div>svrdata:%s</div>]],commonlib.Encoding.EncodeStr(self.goods.serverdata));
		end
	end

	if(self:IsEquip())then
		if(self.item.template.canexchange and self.item.template.cangift )then
			local binding = self:IsBinding(self.goods,true);
			self:LOG("binding:" ,(binding or "nil"));
			--187 is_unisex_teen(C) 装备区分男女 不区分男女写1 

			if(binding)then
				self.bind_self = str_fmt([[<div style="color:%s;">已绑定</div>]],if_else(TEEN_VERSION,LIMITED_COLOR,KIDS_BINDING_COLOR));
			else
				self.bind_self = "未绑定";
			end
		end
		local stats_521 = self:getTempStats(521);
		if(stats_521 == 1) then
			if(self.goods and self.goods.GetServerData) then
				local svrdata = self.goods:GetServerData();
				if(svrdata and svrdata.money) then
					-- TODO: show gems and sign code. 
					self.description = format([[%s<div style="text-align:center;color:%s">%s</div>]], self.description or "", if_else(TEEN_VERSION,LIMITED_COLOR,"#0000a0"), string.format("%.1f克拉", svrdata.money/100));
					local max_gems_to_display = 49+2;
					local gem_count = math.min(max_gems_to_display, math.floor(svrdata.money/100));
					local gem_index;
					local gem_str = "<div>";
					
					if(gem_count>0) then
						-- tricky: this is heart shape
						static_gem_shape_map = static_gem_shape_map or {
							{0,1,1,0,1,1,0},
							{1,0,0,1,0,0,1},
							{1,0,1,1,1,0,1},
							{1,0,1,1,1,0,1},
							{0,1,0,1,0,1,0},
							{0,0,1,0,1,0,0},
							{0,0,0,1,0,0,0},
						};
						local gem_x,gem_y = 0,0;
						for gem_x = 1, #static_gem_shape_map do
							local row = static_gem_shape_map[gem_x];
							for gem_y = 1, #row do
								if(gem_count>0) then
									if(row[gem_y] == 1) then
										gem_count = gem_count - 1;
										gem_str = gem_str..[[<div style="float:left;width:24px;height:24px;background:url(Texture/Aries/Item/PinkDiamond_32Bits_fps4_a004.png);"/>]]
									else
										gem_str = gem_str..[[<div style="float:left;width:24px;height:24px;"/>]]
									end
								else
									break;
								end
							end
							if(gem_count>0) then
								gem_str = gem_str.."<br/>"
							else
								break;
							end
						end
					end
					for gem_index = 1, gem_count do
						gem_str = gem_str..[[<div style="float:left;width:24px;height:24px;background:url(Texture/Aries/Item/PinkDiamond_32Bits_fps4_a004.png);"/>]]
					end
					gem_str = gem_str.."</div>"
					self.description = self.description..gem_str;

					if(svrdata.sign_text) then
						self.description = format([[%s<div style="text-align:center;color:%s">%s</div>]], self.description or "", if_else(TEEN_VERSION,LIMITED_COLOR,"#0000a0"), format("\"%s\"", commonlib.Encoding.EncodeStr(svrdata.sign_text)));
					end
					if(svrdata.nid) then
						local userinfo = Map3DSystem.App.profiles.ProfileManager.GetUserInfoInMemory(svrdata.nid)
						if(userinfo and userinfo.nickname) then
							self.description = format([[%s<div style="text-align:right;color:%s">%s</div>]], self.description or "", if_else(TEEN_VERSION,LIMITED_COLOR,"#0000a0"), format("来自:%s", commonlib.Encoding.EncodeStr(userinfo.nickname)));
						else
							Map3DSystem.App.profiles.ProfileManager.GetUserInfo(svrdata.nid, "generictip", function (msg)end,"access plus 1 year");
							self.description = format([[%s<div style="text-align:right;color:%s">%s</div>]], self.description or "", if_else(TEEN_VERSION,LIMITED_COLOR,"#0000a0"), format("来自:%s", svrdata.nid));
						end
					end
				else
					self.description = format([[%s<div style="text-align:center;color:%s">还没有签名<br/>需2人交换后才能使用</div>]], self.description or "", if_else(TEEN_VERSION,LIMITED_COLOR,"#0000a0"));
				end
			end
		end
	end

	local school_stats = self:getTempStats(137) or self:getTempStats(246);
	local cn_school,en_school = self.GetSchool(school_stats);

	if(cn_school and en_school)then
		if(self.avatar_school == en_school)then
			self.school = str_fmt([[<div style="color:%s">%s:%s</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR),if_else(not self:getTempStats(246),"系别","推荐系别"),cn_school);
		else
			self.school = str_fmt([[<div style="color:%s;">%s:%s</div>]],if_else(TEEN_VERSION,LIMITED_COLOR,KIDS_LEVEL_LIMITED),if_else(not self:getTempStats(246),"系别","推荐系别"),cn_school);
		end
	end

	if(self.item and self.item.template)then
		self:LOG("self.item.template.subclass:" , (self.item.template.subclass or "nil"))
		local item_type = self.GetItemType(self.item.template.subclass);
		if(item_type and self:IsEquip()) then
			self.item_type = str_fmt([[<div style="color:%s">类型:%s</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR),item_type);
			if(self:IsFashionEquip(self.item.template.subclass)) then
				self.item_type = self.item_type..str_fmt([[<div style="color:%s">属性可与装备叠加</div>]],if_else(TEEN_VERSION,DEFAULT_COLOR,KIDS_DEFAULT_COLOR));
			end
		end
		self:LOG("item_type:" ,(item_type or "nil"));
	end
	
	--get card info of equip
	--currently card id is on range between [139,150]
	local cardIndex,cardList,cardItem = 0,{};
	for cardIndex = 139,150 do
		cardItem = getItemByGsid(self:getTempStats(cardIndex));
		if(cardItem)then
			cardList[#cardList + 1] = cardItem.gsid;
		end
	end

	if(#cardList > 0)then
		self.card_list = if_else(TEEN_VERSION,"<div>包含卡片:</div>",str_fmt([[<div style="color:%s">包含卡片:</div>]],KIDS_DEFAULT_COLOR));
		for cardIndex = 1, #cardList do
			if(math.mod(cardIndex,2) == 0)then
				self.card_list = self.card_list .. str_fmt([[<pe:item gsid="%s" isclickable="false" style="margin-top:2px;margin-bottom:2px;margin-left:2px;width:89px;height:125px;"/><br/>]],cardList[cardIndex]);
			else
				if(cardIndex == #cardList and cardIndex == 1)then
					self.card_list = self.card_list .. str_fmt([[<pe:item gsid="%s" isclickable="false" style="margin-top:2px;margin-left:28px;margin-bottom:2px;width:89px;height:125px;"/>]],cardList[cardIndex]);
				elseif(cardIndex == #cardList and cardIndex ~= 1)then
					self.card_list = self.card_list .. str_fmt([[<pe:item gsid="%s" isclickable="false" style="margin-top:2px;margin-left:45px;margin-bottom:2px;width:89px;height:125px;"/>]],cardList[cardIndex]);
				else
					self.card_list = self.card_list .. str_fmt([[<pe:item gsid="%s" isclickable="false" style="margin-top:2px;margin-bottom:2px;margin-left:0px;width:89px;height:125px;"/>]],cardList[cardIndex]);
				end
			end
		end

	end
	
	--get slots info of equip
	local subclass,equip_level,class
	if(self.item and self.item.template)then
		class= self.item.template.class
		subclass = self.item.template.subclass
		if(self.item.template.stats)then
			equip_level = self.item.template.stats[138] or self.item.template.stats[168] 
		end
	end

	if((TEEN_VERSION and self.quality > 0) or not TEEN_VERSION)then
		local typ = Avatar_equipment_subpage:GetEquipTyp(class,subclass);

		--get user slotting count
		if(self.hdr ~= "将要换购的装备" and typ and equip_from_shop)then --for equip of shop,never slotting
			local holecnt;
			if(not TEEN_VERSION)then
				holecnt = self:getTempStats(36,0)
				self.hold_slots = holecnt;
				self.usable_slots = holecnt;
			elseif(TEEN_VERSION)then
				self.hold_slots,self.usable_slots = Avatar_equipment_subpage:GetSlotsInfo(self.item, equip_level, typ); 
			end
			for i = 1,self.usable_slots do
				self.extra_stats = self.extra_stats .. BG_SLOTTING;
			end
					
			if(self.usable_slots < self.hold_slots)then
				for i = self.usable_slots,self.hold_slots - 1 do
					self.extra_stats = self.extra_stats .. BG_UNSLOTTING;
				end
			end
		elseif(typ and self.hdr == "将要换购的装备")then		
			--get extra stats of gems
			local i,v;
			local _holdgems;
			if(Avatar_equipment_subpage.GetIncomingEquipGems)then
				_holdgems = Avatar_equipment_subpage:GetIncomingEquipGems()
			end

			local holecnt;
			if(not TEEN_VERSION)then
				holecnt = self:getTempStats(36,0)
				self.hold_slots = holecnt;
				self.usable_slots = holecnt;
			elseif(TEEN_VERSION)then
				self.hold_slots,self.usable_slots = Avatar_equipment_subpage:GetSlotsInfo(self.item, equip_level, typ); 
			end

			local src_gems_item,dest_gems_item = { template = { stats = {},},},{template = { stats = {}, },}
			if(_holdgems) then
				for i,v in ipairs(_holdgems) do
					local gem = getItemByGsid(v.gsid);
					if(self:EquippedItemTest())then
						local k,v
						for k,v in pairs(gem.template.stats)do
							src_gems_item.template.stats[k] = v
						end
					end

					local gem_icon = gem.icon;
					local gem_stats = self:getStatsByGsid(false,v.gsid);
					local gem_name = v.name;
					self.extra_stats = self.extra_stats .. str_fmt([[<div><div style="float:left;width:16px;height:16px;background:url(%s)"></div><div style="float:left;margin-left:2px;">%s</div></div>]],gem_icon,gem_stats,gem_name);
					--self.extra_stats = self.extra_stats .. str_fmt([[<div><div style="float:left;"><img src="%s" style="width:24px;height:24px;"/></div><div style="float:left;margin-top:3px;">%s</div></div>]],gem_icon,gem_stats,gem_name);
				end
			
				if(self.usable_slots > #_holdgems)then
					for i = #_holdgems,self.usable_slots - 1 do
						self.extra_stats = self.extra_stats .. BG_SLOTTING;
					end
				end
			else
				for i = 1,self.usable_slots do
					self.extra_stats = self.extra_stats .. BG_SLOTTING;
				end
			end
			
			if(self:EquippedItemTest())then
				if(self.equipped_item.PrepareSocketedGemsIfNot)then
					self.equipped_item:PrepareSocketedGemsIfNot()
					local _holdgems = self.equipped_item:GetSocketedGems() or {};

					for i,v in ipairs(_holdgems) do
						local gem = getItemByGsid(v);
						local k,v
						for k,v in pairs(gem.template.stats)do
							dest_gems_item.template.stats[k] = v
						end
					end
				end
				self:CalcDiffStats(dest_gems_item,src_gems_item);
			end

			if(self.usable_slots < self.hold_slots)then
				for i = self.usable_slots,self.hold_slots - 1 do
					self.extra_stats = self.extra_stats .. BG_UNSLOTTING;
				end
			end
		elseif(typ)then --for self equip
			local holecnt
			if(self.goods.PrepareSocketedGemsIfNot) then
				self.goods:PrepareSocketedGemsIfNot();
				holecnt = self.goods:GetHoleCount();
			end

			if(not TEEN_VERSION)then
				holecnt = self:getTempStats(36,0)
				self.hold_slots = holecnt;
				self.usable_slots = holecnt;
			elseif(TEEN_VERSION)then
				self.hold_slots,self.usable_slots = Avatar_equipment_subpage:GetSlotsInfo(self.item, equip_level, typ, holecnt); 
			end
		
			self:LOG("self.hold_slots:" ,(self.hold_slots or "nil"));
			self:LOG("self.usable_slots:" ,(self.usable_slots or "nil"));
			self:LOG("holecnt:" ,(holecnt or "nil"));
			self:LOG("equip typ:" ,(typ or "nil"));

			local _holdgems
			if(self.goods.GetSocketedGems)then
				_holdgems = self.goods:GetSocketedGems();
			end

			local src_gems_item,dest_gems_item = { template = { stats = {}, },},{template = { stats = {}, },}
			self:LOG("_holdgems",_holdgems)
			--get extra stats of gems
			local i,v;
			if(_holdgems) then
				for i,v in ipairs(_holdgems) do
					local gem = getItemByGsid(v);
					if(self:EquippedItemTest())then
						local k,v
						for k,v in pairs(gem.template.stats)do
							src_gems_item.template.stats[k] = v
						end
					end

					local gem_icon = gem.icon;
					local gem_stats = self:getStatsByGsid(false,v);
					local gem_name = if_else(gem.template,gem.template.name or "unknown","undefined name");
					self.extra_stats = self.extra_stats .. str_fmt([[<div><div style="float:left;width:16px;height:16px;background:url(%s)"></div><div style="float:left;margin-left:2px;">%s</div></div>]],gem_icon,gem_stats,gem_name);
				end
			
				if(self.usable_slots > #_holdgems)then
					for i = #_holdgems,self.usable_slots - 1 do
						self.extra_stats = self.extra_stats .. BG_SLOTTING;
					end
				end
			else
				for i = 1,self.usable_slots do
					self.extra_stats = self.extra_stats .. BG_SLOTTING;
				end
			end

			self:LOG("self.extra_stats",self.extra_stats)

			if(self:EquippedItemTest())then
				if(self.equipped_item.PrepareSocketedGemsIfNot)then
					self.equipped_item:PrepareSocketedGemsIfNot()
					local _holdgems = self.equipped_item:GetSocketedGems() or {};
					
					for i,v in ipairs(_holdgems) do
						local gem = getItemByGsid(v);
						local k,v
						for k,v in pairs(gem.template.stats)do
							dest_gems_item.template.stats[k] = v
						end
					end
				end
				self:CalcDiffStats(dest_gems_item,src_gems_item);
			end

			if(self.usable_slots < self.hold_slots)then
				for i = self.usable_slots,self.hold_slots - 1 do
					self.extra_stats = self.extra_stats .. BG_UNSLOTTING;
				end
			end
		end
	end

	if(Avatar_equip_exchange)then
		Avatar_equip_exchange:LoadData()
		if(Avatar_equip_exchange and Avatar_equip_exchange.IsExchangableEquip)then
			local isexchangeable = Avatar_equip_exchange:IsExchangableEquip(self.gsid)									
			if(isexchangeable)then
				if(TEEN_VERSION)then
					--self.extra_stats = self.extra_stats .. [[<div style="color:#ff9a00;">可在购物街【达尔莫德】处升级</div>]];
					--self.extra_stats = self.extra_stats .. [[<div style="color:#ff9a00;">可在黎明之都【艾伊莫德】处升级</div>]];
				end
			end
		end	
	end

	if(self:getTempStats(47)) then
		local exid = self:getTempStats(47);
		local exid_tip = self:GetExidTooltip(exid);
		if(exid_tip) then
			self.description = self.description..exid_tip;
		end
	end
	
	-- 70 龙族图腾建造等级(C) 儿童版第一次使用 仅供客户端显示和提示用
	-- 71 增加龙族图腾信仰的经验值(CG) 儿童版第一次使用 
	if(self:getTempStats(71)) then
		local stats_70 = self:getTempStats(70);
		local stats_71 = self:getTempStats(71);
		if(stats_70 and stats_71) then
			local bHas, _, _, copies = ItemManager.IfOwnGSItem(if_else(TEEN_VERSION,50389,50359));
			local _, total_level, cur_level = MyCompany.Aries.Combat.GetStatsFromDragonTotemProfessionAndExp(if_else(TEEN_VERSION,50377,50351), if_else(TEEN_VERSION,50389,50359), copies or 0);
			local item_exp = stats_71;
			local item_level = stats_70;
			local diff = math.floor(math.abs(item_level*3 - (cur_level or 1)) / 3);
			local diff_percent = (1-0.3*diff);
			if(diff_percent > 0) then
				item_exp = math.floor(item_exp * diff_percent);
			else
				item_exp = 0;
			end

			local text;
			if(TEEN_VERSION) then
				text = format([[<div style="color:%s">你的强化属性阶段:%d</div>]], if_else(TEEN_VERSION,LIMITED_COLOR,KIDS_LEVEL_LIMITED), math.floor((cur_level-1)/3)+1)
				text = text..format([[<div>物品强化属性等级:%d</div>]], item_level)
				text = text..format([[<div style="color:%s">可以增加强化属性值:%d</div>]], if_else(TEEN_VERSION,LIMITED_COLOR,KIDS_LEVEL_LIMITED), item_exp)
				text = text.."<div>使用限制：如果选用的符印阶段和强化属性阶段不一致，可增加的强化属性值会有所降低。</div>"
			else
				text = format([[<div style="color:%s">你的信仰阶段:%d</div>]], if_else(TEEN_VERSION,LIMITED_COLOR,KIDS_LEVEL_LIMITED), math.floor((cur_level-1)/3)+1)
				text = text..format([[<div>物品信仰等级:%d</div>]], item_level)
				text = text..format([[<div style="color:%s">可以增加信仰值:%d</div>]], if_else(TEEN_VERSION,LIMITED_COLOR,KIDS_LEVEL_LIMITED), item_exp)
				text = text.."<div>使用限制：如果选用的魂印阶段和信仰阶段不一致，可增加的信仰值会有所降低。</div>"
			end
			
			self.description = self.description..text;
		end
	end

	if(System.options.version == "kids") then
		local gsid = self.gsid;
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem) then
			-- 36 Item_Socket_Count(CS) 装备可镶嵌槽的数量 只能从0变为一个数值 不能改
			local stat_36 = gsItem.template.stats[36];
			if(stat_36 and stat_36 > 0) then
				local title = "可镶嵌宝石种类：<br/>";
				local inventorytype = gsItem.template.inventorytype;
				if(inventorytype == 2) then
					self.socketing_description = title.."HP/攻击/防御/治疗/超魔";
				elseif(inventorytype == 5) then
					self.socketing_description = title.."HP/攻击/防御/治疗/超魔";
				elseif(inventorytype == 8) then
					self.socketing_description = title.."HP/攻击/防御/治疗/超魔";
				elseif(inventorytype == 15) then
					self.socketing_description = title.."防御/命中/治疗/超魔";
				elseif(inventorytype == 11) then
					self.socketing_description = title.."攻击/穿透";
				elseif(inventorytype == 17) then
					self.socketing_description = title.."HP/攻击/防御/治疗/超魔";
				elseif(inventorytype == 16) then
					self.socketing_description = title.."防御/治疗/命中/超魔";
				elseif(inventorytype == 7) then
					self.socketing_description = title.."HP/攻击/防御/治疗/超魔";
				end
			end
		end
	end

	--get equip suit info which singleton equip belong to 
	local itemsetid = if_else(self.item and self.item.template,self.item.template.itemsetid,0);--is equip suit id.
	local src_equipsuit_stats,dest_equipsuit_stats = { template = { stats = {}, },},{template = { stats = {}, },}

	if(itemsetid ~= 0)then
		self.equip_suit_name = Combat.GetItemSetName(itemsetid)

		local components = Combat.GetItemSetComponents(itemsetid);
		if(components) then
			local equip_gsid, _,_equip_suit_table;
			_equip_suit_table = {};
			
			for equip_gsid, _ in pairs(components) do
				local equip_item = getItemByGsid(equip_gsid);
				if(equip_item) then
					local equip_name = if_else(equip_item.template,equip_item.template.name,"undefined name");
					local equiped = false;
					if(not self.user_nid ) then
						equiped = equipGSItem(equip_gsid)
					else
						equiped = equipOPCGSItem(self.user_nid, equip_gsid)
					end
					
					if(not equip_from_shop and equiped) then
						table.insert(_equip_suit_table,1,str_fmt([[<div style="margin-left:10px;color:%s">%s</div>]], if_else(TEEN_VERSION,GREEN,KIDS_EQUIP_SUIT),equip_name));
						self.equiped_list_count = self.equiped_list_count + 1;
					else
						table.insert(_equip_suit_table,str_fmt([[<div style="margin-left:10px;color:%s">%s</div>]], if_else(TEEN_VERSION,GRAY,KIDS_UNEQUIP_SUIT),equip_name));
					end
					self.total_equip_list_count = self.total_equip_list_count + 1;
				end
			end

			--if(self.equiped_list_count < self.total_equip_list_count)then
				--self.equiped_list = self.equiped_list .. str_fmt([[<div style="color:%s;">收齐一套可以产生整套效果</div>]],"#fcf5bd");
			--end

			self.equip_suit_name = str_fmt([[<div style="color:%s;">%s</div>]],if_else(TEEN_VERSION,equip_color,KIDS_DEFAULT_COLOR),self.equip_suit_name .."（"..self.equiped_list_count.."/".. self.total_equip_list_count .."）");	

			self.equiped_list = self.equiped_list .. self.equip_suit_name;
			local i,v;
			for i,v in ipairs(_equip_suit_table)do
				self.equiped_list = self.equiped_list .. v;
			end

			local item_set_effect = Combat.GetItemSetStats(itemsetid);
			if(item_set_effect) then
				self.equiped_list = self.equiped_list ..  str_fmt([[<div style="color:%s;">套装属性</div>]],if_else(TEEN_VERSION,equip_color,KIDS_DEFAULT_COLOR))
				
				local _, item_set_stats_group;
				for _, item_set_stats_group in ipairs(item_set_effect) do
					local stat_type, stat_value;
					for stat_type, stat_value in pairs(item_set_stats_group) do
						if(stat_type ~= item_count and type(stat_type) == "number") then
							local word = self:GetStatsByType(stat_type, stat_value);
							if(not equip_from_shop and self.equiped_list_count >= item_set_stats_group.item_count) then	
								if(word) then
									word = word.."("..item_set_stats_group.item_count.."件)";
									--src_equipsuit_stats.template.stats[type] = value;
									self.equiped_list = self.equiped_list..str_fmt([[<div style="margin-left:10px;color:%s;">%s</div>]], if_else(TEEN_VERSION,GREEN,KIDS_EQUIP_SUIT),word);
								end
							else
								if(word) then
									word = word.."("..item_set_stats_group.item_count.."件)";
									self.equiped_list = self.equiped_list..str_fmt([[<div style="margin-left:10px;color:%s;">%s</div>]], if_else(TEEN_VERSION,GRAY,KIDS_UNEQUIP_SUIT),word);
								end
								--self.equiped_list = self.equiped_list..str_fmt([[<div style="margin-left:10px;color:#888888">未知套装属性</div>]]);
							end
						end
					end
				end
			end

			--self.equiped_list = self.equiped_list .. self.equip_suit_name;
		end 

		
		--get extra attr of equip
		--[[

		--]]
		--self.equipsuit_mount_stats = str_fmt([[<div style="color:%s;">%s</div>]],EQUIP_STATS_COLOR,self.equipsuit_mount_stats);
	end
	if(self:EquippedItemTest() )then
		local src_item = getItemByGsid(self.equipped_item.gsid)
		local itemsetid = (src_item and src_item.template) and src_item.template.itemsetid or 0;--is equip suit id.
		local itemset_stats = Combat.GetItemSetStats(itemsetid) or {};
		local equiped_list_count,total_equip_list_count = 0,0
		local components = Combat.GetItemSetComponents(itemsetid);
		if(components) then
			local equip_gsid, _;
			
			for equip_gsid, _ in pairs(components) do
				local equip_item = getItemByGsid(equip_gsid);
				if(equip_item) then
					local equiped = equipGSItem(equip_gsid);				
					if(equiped) then
						equiped_list_count = equiped_list_count + 1;
					end
					total_equip_list_count = total_equip_list_count + 1
				end
			end
		end
		
		local _, stat_group;
		for _, stat_group in pairs(itemset_stats) do
			if(self:EquippedItemTest())then
				if(equiped_list_count >= stat_group.item_count) then
					local t, v;
					for t, v in pairs(stat_group) do
						if(t ~= "item_count") then
							src_equipsuit_stats.template.stats[t] = (src_equipsuit_stats.template.stats[t] or 0) + v;
						end
					end
				end
			end
		end
		self:CalcDiffStats(src_equipsuit_stats,dest_equipsuit_stats);
	end

	-- 物品描述添加该物品兑换npc所在位置
	if(System.options.version == "kids" and self.item.goto_npc) then
		local npcidTable = self.item.goto_npc;
		
		local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");
		local userinfo = ProfileManager.GetUserInfoInMemory();
		local userlevel = tonumber(userinfo.combatlel);
		local npcid,show_npctips,item,_;
		for _,item in pairs(npcidTable) do
			if(item.maxlevel and item.minlevel) then
				if(userlevel <= tonumber(item.maxlevel) and userlevel >= tonumber(item.minlevel)) then
					npcid = tonumber(item.npcid);
					show_npctips = item.show_npctips;
					break;
				end
			else
				npcid = tonumber(item.npcid);
				show_npctips = item.show_npctips;
				break;
			end
		end
		if(show_npctips) then
			NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
			local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
			NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
			local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");
			local npcinfo, worldname = NPCList.GetNPCByIDAllWorlds(npcid);

			if(npcinfo) then
				NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
				local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
				local _, npc_extrainfo = QuestHelp.BuildNpcListXml();
		

				local npc_name = npcinfo.name;
				local place = npc_extrainfo[npcid].place;
				local worldinfo = WorldManager:GetWorldInfo(worldname);
				local npctips = "兑换NPC:"..worldinfo.world_title.."-"..place.."-"..npc_name.."。".."<br/>".."鼠标左键物品，选择【去看看】按钮可以直接传送到NPC身边。"
				self.npctips = npctips;
			else
				LOG.std("", "error","Login", "the npc("..npcid..")for the npcid can not found");
			end
		end
	end
	
	if(System.options.version == "kids" and self.gsid == 17441 or self.gsid == 17413 or self.gsid == 17578 or self.gsid == 17599 or self.gsid == 17605 or self.gsid == 17606) then
		local list = {
			[17413] = {gsid = 52103, count = 20},
			[17441] = {gsid = 52104, count = 40},
			[17578] = {gsid = 52203, count = 10},
			[17599] = {gsid = 52207, count = 300},
			[17605] = {gsid = 52209, count = 50},
			[17606] = {gsid = 52210, count = 30},
		};
		local markgsid = list[self.gsid]["gsid"];
		local bHas, guid ,_ ,copies = ItemManager.IfOwnGSItem(markgsid);
		if(not bHas) then
			copies = 0;
		end
		--self.opennumbertips = format("封印之力:<font color = '#cb002e'><b>%d/%d</b></font><br/>每次打开口袋会积累“封印之力”,积满后必出极品道具(“封印之力”累积次数只和自己开启口袋次数有关)",copies,list[self.gsid]["count"]);
		self.opennumbertips = format("封印之力:<font color = '#cb002e'><b>%d/%d</b></font><br/>每使用一次该物品都会增加极品道具获得概率,“封印之力”积满后必出极品道具(“封印之力”累积次数只和自己使用该道具次数有关,不满%d次也会开出极品道具)",copies,list[self.gsid]["count"],list[self.gsid]["count"]);
	end

	self:SetupDiffStats();
end

-- @param exid: get exid tip
function ObjectTooltipInfo:GetExidTooltip(exid)
	local tip;
	local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
	if(exTemplate)then
		if(exTemplate.pres) then
			local _, v;
			for _, v in ipairs(exTemplate.pres) do
				local key_num = tonumber(v.key) or 0;
				if (tonumber(v.key)==-104) then
					local value = tonumber(v.value);
					tip = (tip or "")..format("<div>注册%d天后可用</div>", value);

					local userinfo = Map3DSystem.App.profiles.ProfileManager.GetUserInfoInMemory();
					if(userinfo and userinfo.birthday) then
						local can_use_time = commonlib.timehelp.get_next_date_str(userinfo.birthday, value, "%04d-%02d-%02d")
						tip = format("%s<div>请在%s之后使用</div>", tip, can_use_time);
					end
				elseif (key_num<=-201 and key_num>=-299) then
					local obtain_to_use_day = -(key_num+200);
					local gsid = tonumber(v.value);
					local bHas, guid = ItemManager.IfOwnGSItem(gsid);
					tip = format("<div>物品获得%d天后才能使用</div>", obtain_to_use_day);

					if(bHas) then
						local item = ItemManager.GetItemByGUID(guid);
						if(item and item.obtaintime) then
							local can_use_time = commonlib.timehelp.get_next_date_str(item.obtaintime, obtain_to_use_day, "%04d-%02d-%02d")
							tip = format("%s<div>请在%s之后使用</div>", tip, can_use_time);
						end
					end
				end
			end
		end
	end
	return tip;
end

-- @param style_class: nil or something like "class='bordertext'" which is applied to button class. 
function ObjectTooltipInfo.GetItemMCMLText(gsid, count, bIsSelf, style_class)
	if(not gsid) then
		return "";
	end
	local item_name;
	if(gsid == 0) then
		count = count or 1;
		if(TEEN_VERSION) then
			item_name = "银币 x "..count;
		else
			item_name = "奇豆 x "..count;
		end
	elseif(gsid == -13) then
		count = count or 1;
		item_name = count.."经验";
	elseif(gsid == -113) then
		count = count or 1;
		item_name = count.."战宠经验";
	elseif(gsid == -114) then
		count = count or 1;
		item_name = count.."宠物训练点";
	else
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem) then
			local tooltip = "";
			local hasGSItem = System.Item.ItemManager.IfOwnGSItem;
			
			tooltip = "page://script/apps/Aries/Desktop/GenericTooltip_InOne.html?gsid="..gsid;
			
			if(gsItem.template.class == 18 and (gsItem.template.subclass == 1 or gsItem.template.subclass == 2)) then
				tooltip = "page://script/apps/Aries/Inventory/Cards/CardsTooltip.html?state=7&amp;gsid="..gsid;
			end
			
			if(bIsSelf) then
				local bHas, guid = hasGSItem(gsid);
				if(guid) then
					tooltip = tooltip.."&amp;guid="..guid;
				end
			end

			local color = "#f8f8f8";
			local shadow_color;
			local quality = gsItem.template.stats[221];
			if(quality) then
				if(quality == 2) then
					color = "#0060fd";
				elseif(quality == 1) then
					color = "#0bdd2c";
				elseif(quality == 3) then
					color = "#8802e9";
					shadow_color = "shadow-color:#ccffffff;";
				elseif(quality == 4) then
					color = "#f6871a";
					shadow_color = "shadow-color:#ccffffff;";
				elseif(quality == 0) then
					color = "#f8f8f8";
				end
			end
			
			if(gsItem.template.class == 18 and gsItem.template.subclass == 2) then
				color = "#13fff7";
			end

			item_name = string.format(
				[[<input tooltip="%s" type="button" style="float:left;margin-top:2px;height:16px;color:%s;background:;%s" value="[%s]" %s/>]], 
					tooltip, color, shadow_color or "", gsItem.template.name or "", style_class or "");
			if(count) then
				if(System.options.version == "teen")then
					NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/LearnedSkill_subpage.teen.lua");
					local LearnedSkill_subpage = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.LearnedSkill_subpage");
					if(LearnedSkill_subpage.ItemsCates[gsItem.gsid])then
						item_name = item_name.." + "..count;
					else
						item_name = item_name.." x "..count;
					end
				else
					item_name = item_name.." x "..count;
				end
			end
		end
	end
	return item_name or "";
end