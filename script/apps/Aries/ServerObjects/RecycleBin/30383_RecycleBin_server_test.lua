--[[
Title: 
Author(s):  Leio
Date: 2010/04/24
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/RecycleBin/30383_RecycleBin_server_test.lua");
RecycleBin_server_test.Refresh();

NPL.load("(gl)script/apps/Aries/ServerObjects/RecycleBin/30383_RecycleBin_server_test.lua");
RecycleBin_server_test.Pick(1,1)
RecycleBin_server_test.Pick(2,2)
RecycleBin_server_test.Pick(3,3)
------------------------------------------------------------
]]
local RecycleBin_server_test = {}
commonlib.setfield("RecycleBin_server_test",RecycleBin_server_test);
local rubbish_prop = {
	1,--可回收垃圾
	2,--厨房垃圾
	3,--有害垃圾
	4,--其他垃圾
}
local rubbish_type = {
	--可回收垃圾
	{ label = "废纸片", item_id = 101, prop = 1, },
	{ label = "废塑料", item_id = 102, prop = 1,},
	{ label = "玻璃块", item_id = 103, prop = 1,},
	{ label = "锈铁皮", item_id = 104, prop = 1,},
	{ label = "小布片", item_id = 105, prop = 1,},
	--厨房垃圾
	{ label = "破蛋壳", item_id = 201, prop = 2,},
	{ label = "烂菜叶", item_id = 202, prop = 2,},
	--有害垃圾
	{ label = "废电池", item_id = 301, prop = 3,},
	{ label = "废灯泡", item_id = 302, prop = 3,},
	{ label = "过期百草丹", item_id = 303, prop = 3,},
	--其他垃圾
	{ label = "破陶罐", item_id = 401, prop = 4,},
	{ label = "渣土", item_id = 402, prop = 4,},
}
local rubbish_place = {
	1,--生命之泉水面上
	2,--小镇广场地面上
	3,--购物街地面上
}
--各个区域随机分布点的总数
local rubbish_place_totals = {
	10,
	10,
	10,
}
function RecycleBin_server_test.IninHoles(list,len)
	if(not list or not len)then return end
	local k;
	for k = 1,len do
		list[k] = { label = k, isEmpty = true, item = nil,  }
	end
end

--------------------
local rubbish_1_holes = {
}
local rubbish_2_holes = {
}
local rubbish_3_holes = {
}

local len = rubbish_place_totals[1];
RecycleBin_server_test.IninHoles(rubbish_1_holes,len)

local len = rubbish_place_totals[2];
RecycleBin_server_test.IninHoles(rubbish_2_holes,len)

local len = rubbish_place_totals[3];
RecycleBin_server_test.IninHoles(rubbish_3_holes,len)

function RecycleBin_server_test.GetEmptyHoles()
	--找到空闲列表
	local list_1 = commonlib.GetEmptyList(rubbish_1_holes,6)
	local list_2 = commonlib.GetEmptyList(rubbish_2_holes,6)
	local list_3 = commonlib.GetEmptyList(rubbish_3_holes,6)
	
	--随机生成物品
	RecycleBin_server_test.MadeRandomItems(list_1,1)
	RecycleBin_server_test.MadeRandomItems(list_2,2)
	RecycleBin_server_test.MadeRandomItems(list_3,3)
	
	return list_1,list_2,list_3;
end
--为每个位置随机分配物品
--@param list:位置列表
--@param square: 在哪个区域生成
function RecycleBin_server_test.MadeRandomItems(list,square)
	if(not list or not square)then return end
	local item_types_len = #rubbish_type;
	local k,v;
	for k,v in ipairs(list) do
		--物品的区域和位置
		local place_square = square;
		local place_index = v.label;
		
		--生成物品的属性
		local item_type_index = math.random(item_types_len);
		local item_type_info = rubbish_type[item_type_index];
		local label = item_type_info.label;
		local item_id = item_type_info.item_id;
		local prop = item_type_info.prop;
		
		local item = {
			label = label,
			item_id = item_id,
			prop = prop,
			place_square = place_square,
			place_index = place_index,
		};
		
		--把生成的新物品记录在 这个洞里面
		--local item = { label = "废纸片", item_id = 101, prop = 1, place_square = 1, place_index = 1, }
		v.item = item;
	end
end
function RecycleBin_server_test.Pick(place_square,place_index)
	if(not place_square or not place_index)then return end
	local holes;
	if( place_square == 1)then
		holes = rubbish_1_holes;
	elseif( place_square == 2)then
		holes = rubbish_2_holes;
	elseif( place_square == 3)then
		holes = rubbish_3_holes;
	end
	local hole_item = holes[place_index];
	commonlib.echo("==================pick item is");
	commonlib.echo(hole_item);
	hole_item.item = nil;--清空hold的物品
	hole_item.isEmpty = true;--恢复为空的位置
end
function RecycleBin_server_test.Refresh()
	local list_1,list_2,list_3 = RecycleBin_server_test.GetEmptyHoles();
	commonlib.echo("===============before refresh");
	--commonlib.echo(rubbish_1_holes);
	--commonlib.echo(rubbish_2_holes);
	--commonlib.echo(rubbish_3_holes);
	
	commonlib.echo("===============list_1");
	commonlib.echo(list_1);
	commonlib.echo("===============list_2");
	commonlib.echo(list_2);
	commonlib.echo("===============list_3");
	commonlib.echo(list_3);
	function upateList(list)
		if(list)then
			local k,v;
			for k,v in ipairs(list) do
				v.isEmpty = false;
			end
		end
	end
	upateList(list_1);
	upateList(list_2);
	upateList(list_3);
	--commonlib.echo("===============after refresh");
	--commonlib.echo(rubbish_1_holes);
	--commonlib.echo(rubbish_2_holes);
	--commonlib.echo(rubbish_3_holes);
end
