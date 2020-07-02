--[[
Title: 
Author(s): Leio
Date: 2009/12/25
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Books/IllustratedPetBook.lua");
-------------------------------------------------------
]]

local IllustratedPetBook = {
	pets = {
		{gsid = 10133,name = "玩具人", bg = "Texture/Aries/Books/IllustratedPetBook/10133_toyman_32bits.png;0 0 550 430", had = false, limited = false},
		{gsid = 10132,name = "水晶兔", bg = "Texture/Aries/Books/IllustratedPetBook/10132_crystalbunny_32bits.png;0 0 550 430", had = false, limited = false},
		{gsid = 10131,name = "鸵鸟", bg = "Texture/Aries/Books/IllustratedPetBook/10131_Ostrich_32bits.png;0 0 550 430", had = false, limited = false},
		{gsid = 10105,name = "西瓜仔", bg = "Texture/Aries/Books/IllustratedPetBook/10105_watermelonbaby_32bits.png;0 0 550 430", had = false, limited = false},
		{gsid = 10130,name = "小燕子", bg = "Texture/Aries/Books/IllustratedPetBook/10130_swallow_32bits.png;0 0 550 430", had = false, limited = false},
		{gsid = 10129,name = "元宵宝宝", bg = "Texture/Aries/Books/IllustratedPetBook/10129_yuanxiaobaby_32bits.png;0 0 550 430", had = false, limited = true},
		
		{gsid = 10117,name = "百变鼠", bg = "Texture/Aries/Books/IllustratedPetBook/10117_mouse_32bits.png;0 0 550 430", had = false, limited = true},
		{gsid = 10118,name = "百变牛", bg = "Texture/Aries/Books/IllustratedPetBook/10118_cow_32bits.png;0 0 550 430", had = false, limited = true},
		{gsid = 10119,name = "百变虎", bg = "Texture/Aries/Books/IllustratedPetBook/10119_tiger_32bits.png;0 0 550 430", had = false, limited = true},
		{gsid = 10120,name = "百变兔", bg = "Texture/Aries/Books/IllustratedPetBook/10120_rabbit_32bits.png;0 0 550 430", had = false, limited = true},
		{gsid = 10121,name = "百变龙", bg = "Texture/Aries/Books/IllustratedPetBook/10121_dragon_32bits.png;0 0 550 430", had = false, limited = true},
		{gsid = 10122,name = "百变蛇", bg = "Texture/Aries/Books/IllustratedPetBook/10122_snake_32bits.png;0 0 550 430", had = false, limited = true},
		{gsid = 10123,name = "百变马", bg = "Texture/Aries/Books/IllustratedPetBook/10123_horse_32bits.png;0 0 550 430", had = false, limited = true},
		{gsid = 10124,name = "百变羊", bg = "Texture/Aries/Books/IllustratedPetBook/10124_sheep_32bits.png;0 0 550 430", had = false, limited = true},
		{gsid = 10125,name = "百变猴", bg = "Texture/Aries/Books/IllustratedPetBook/10125_monkey_32bits.png;0 0 550 430", had = false, limited = true},
		{gsid = 10126,name = "百变鸡", bg = "Texture/Aries/Books/IllustratedPetBook/10126_cock_32bits.png;0 0 550 430", had = false, limited = true},
		{gsid = 10127,name = "百变狗", bg = "Texture/Aries/Books/IllustratedPetBook/10127_dog_32bits.png;0 0 550 430", had = false, limited = true},
		{gsid = 10128,name = "百变猪", bg = "Texture/Aries/Books/IllustratedPetBook/10128_pig_32bits.png;0 0 550 430", had = false, limited = true},
		
		{gsid = 10116,name = "呦呦鹿", bg = "Texture/Aries/Books/IllustratedPetBook/10116_yoyodeer_32bits.png;0 0 550 430", had = false, limited = true},
		{gsid = 10115,name = "松鼠", bg = "Texture/Aries/Books/IllustratedPetBook/10115_squirrel_32bits.png;0 0 550 430", had = false, limited = false},
		{gsid = 10114,name = "熊猫", bg = "Texture/Aries/Books/IllustratedPetBook/10114_panda_32bits.png;0 0 550 430", had = false, limited = true},
		{gsid = 10113,name = "飞飞", bg = "Texture/Aries/Books/IllustratedPetBook/10113_feifei_32bits.png;0 0 550 430", had = false, limited = false},
		{gsid = 10112,name = "金刚蜗牛", bg = "Texture/Aries/Books/IllustratedPetBook/10112_snail_32bits.png;0 0 550 430", had = false, limited = false},
		{gsid = 10111,name = "麋麋鹿", bg = "Texture/Aries/Books/IllustratedPetBook/10111_milu_32bits.png;0 0 550 430", had = false, limited = true},
		{gsid = 10106,name = "旺旺狗", bg = "Texture/Aries/Books/IllustratedPetBook/10106_dog_32bits.png;0 0 550 430", had = false, limited = false},
		{gsid = 10104,name = "罗莉猫", bg = "Texture/Aries/Books/IllustratedPetBook/10104_cat_32bits.png;0 0 550 430", had = false, limited = false},
		{gsid = 10107,name = "跳蚤鸡", bg = "Texture/Aries/Books/IllustratedPetBook/10107_chicken_32bits.png;0 0 550 430", had = false, limited = false},
		{gsid = 10110,name = "皇冠蛇", bg = "Texture/Aries/Books/IllustratedPetBook/10110_snake_32bits.png;0 0 550 430", had = false, limited = false},
		{gsid = 10103,name = "蘑菇噜", bg = "Texture/Aries/Books/IllustratedPetBook/10103_mogu_32bits.png;0 0 550 430", had = false, limited = false},
		{gsid = 10108,name = "小蓝马", bg = "Texture/Aries/Books/IllustratedPetBook/10108_horse_32bits.png;0 0 550 430", had = false, limited = false},
		{gsid = 10102,name = "大眼蜂", bg = "Texture/Aries/Books/IllustratedPetBook/10102_lee_32bits.png;0 0 550 430", had = false, limited = false},
		{gsid = 10109,name = "吵吵葱头", bg = "Texture/Aries/Books/IllustratedPetBook/10109_congtou_32bits.png;0 0 550 430", had = false, limited = false},
		{gsid = 10101,name = "闹闹菜头", bg = "Texture/Aries/Books/IllustratedPetBook/10101_caitou_32bits.png;0 0 550 430", had = false, limited = false},
	}
}
commonlib.setfield("MyCompany.Aries.Books.IllustratedPetBook",IllustratedPetBook);
function IllustratedPetBook.DS_Func_Items(index)
	local self = IllustratedPetBook;
	if(not self.items)then return 0 end;
	local len = table.getn(self.items);
	if(index ~= nil) then
		return self.items[index] or {};
	elseif(index == nil) then
		return len;
	end
end

function IllustratedPetBook.OnInit()
	local self = IllustratedPetBook;
	
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local equipGSItem = ItemManager.IfEquipGSItem;

	self.items = {};
	if(self.pets)then
		local k,v;
		for k,v in ipairs(self.pets) do
			local gsid = v.gsid;
			local item = commonlib.deepcopy(v);
			local bHas, guid = hasGSItem(gsid);
			item.had = bHas;
			table.insert(self.items,item);
		end
	end
end
