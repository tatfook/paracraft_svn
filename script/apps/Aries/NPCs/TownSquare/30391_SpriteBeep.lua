--[[
Title: SpriteBeep
Author(s): Leio
Date: 2009/12/7

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30391_SpriteBeep.lua");
local place_square = 1;
local place_index = 1;
Map3DSystem.GSL_client:SendRealtimeMessage("s30391", {body="[Aries][ServerObject30391]TryPickObj:"..place_square..":"..place_index});

------------------------------------------------------------
]]
local LOG = LOG;
-- create class
local libName = "SpriteBeep";
local SpriteBeep = commonlib.gettable("MyCompany.Aries.Quest.NPCs.SpriteBeep");
SpriteBeep.cur_place_square = nil;
SpriteBeep.place_index = nil;

local include_note = 9
local static_hole_num = 6;
local sprite_maps = {};--已有的怪
local speak_timer = commonlib.Timer:new({callbackFunc = function(timer)
	LOG.std("", "debug", "SpriteBeep", timer.id.." on timer")
	local k,v;
	for k,v in pairs(sprite_maps) do
		local id = k;
		local place_square = v.place_square;
		local tooltip_index = v.tooltip_index;
		local r = math.random(3);
		if(r >= 2)then
			SpriteBeep.Speek(id,place_square,tooltip_index);
		end
	end
end})

local assets_map = {
	{ label = "水咕噜", total_holes = static_hole_num, assetFile = "character/v5/10mobs/HaqiTown/WaterBubble/WaterBubble.x", },
	{ label = "枯木怪", total_holes = static_hole_num, assetFile = "character/v5/10mobs/HaqiTown/TreeMonster/TreeMonster.x", },
	{ label = "金苍蝇", total_holes = static_hole_num, assetFile = "character/v5/10mobs/HaqiTown/IronBee/IronBee.x", },
	{ label = "粘土巨人", total_holes = static_hole_num, assetFile = "character/v5/10mobs/HaqiTown/StoneMonster/StoneMonster.x", },
	{ label = "松木妖", total_holes = static_hole_num, assetFile = "character/v5/10mobs/HaqiTown/DeadTreeMonster/DeadTreeMonster.x", },
	{ label = "邪恶雪人", total_holes = static_hole_num, assetFile = "character/v5/10mobs/HaqiTown/EvilSnowman/EvilSnowman.x", },
	{ label = "铁壳怪", total_holes = static_hole_num, assetFile = "character/v5/10mobs/HaqiTown/IronShell/IronShell.x", },
	{ label = "烈火蟹", total_holes = static_hole_num, assetFile = "character/v5/10mobs/HaqiTown/RedCrab/RedCrab.x", },
	{ label = "沙漠毒蝎", total_holes = static_hole_num, assetFile = "character/v5/10mobs/HaqiTown/SandScorpion/SandScorpion.x", },
	--{ label = "火鬃怪", total_holes = static_hole_num, assetFile = "character/v5/10mobs/HaqiTown/FireRockyOgre/FireRockyOgre.x", },
	--{ label = "火毛怪", total_holes = static_hole_num, assetFile = "character/v5/10mobs/HaqiTown/BlazeHairMonster/BlazeHairMonster.x", },
	
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
	{ label = "", total_holes = static_hole_num, },
}
local tooltip_libs = {
	{
		"咕噜咕噜，你们的家园等着被我淹没吧！哈哈哈",
		"你们小镇环境还真不错嘛，哈哈，马上就是我们的天下啦！",
		"我的水攻可是很强的，很快就会让你尝试到被淹没的感觉！",
	},
	{
		"嗷呜！~~你们的森林马上就是我的天下！",
		"嗷嗞嗷嗞！我要让你们在我的树林里迷路，让你永远走不出来！哈哈哈",
		"你想把我赶出小镇吗，哈哈，别做梦了！",
	},
	{
		"我们可是很团结的，就凭你们这点本事，小镇马上将是我们的啦！ ",
		"你想现在就赶我走吗，呵，告诉你，好戏才刚刚上演！",
		"嗡嗡嗡！想试一下我毒刺的感觉吗！",
	},
	{
		"好歹我也是个粘土巨人，就凭你们随便就能把我扳倒吗？",
		"真是笑话，你以为我现在不出招就代表你很厉害吗，逗逗你而已！",
		"不久，你们家园的泥土全部会被我粘走的，哈哈哈哈！",
	},
	{
		"哇吧哇吧，我看上去很善良吧，是啊，很快我会让你们见识到我有多“善良”哈哈哈！",
		"啧啧啧，别费劲了，做无力的反抗是改变不了我们要占领小镇的事实的！",
		"我们是来复仇的，挡我者，呵，你知道结果的！",
	},
	{
		"让你尝试一下冰冻的感觉吧，我想十万年都不能动肯定很有意思吧！",
		"你们的雪山真是个不错的地方啊，哈哈，很快小镇就是我们的啦！",
		"你肯定不知道吧，我的冰坚固起来可是很吓人的啊！",
	},
	{
		"我看起来就很硬吧，哈哈，很快就会让你们知道我到底有多坚硬！",
		"阳光海岸的环境真不错，马上这里将会是我们的天下！",
		"让铁壳敲敲你的脑袋肯定是件很有趣的事吧！",
	},
	{
		"想尝尝被钳的感觉吗，我相信很快就会会让们你体会到的！",
		"螃蟹你见过不少吧，像我这种烈火蟹，想尝尝我的厉害吗？",
		"你真以为看到的只是虚影吗，很快让你看看我的真身！",
	},
	{
		"生活在沙漠上的我，性格坚韧，我尾巴上的针可是很久都没扎扎人咯！",
		"看我锋利的外表，你肯定知道我有多厉害了吧！",
		"你们这些小罗喽最好让到一边，等着看我们怎么占领小镇把！",
	},
	{
		"啊哦！我最喜欢和哈奇玩喷火的游戏了，只是对你们来说太危险了吧！？哈哈",
		"火焰山洞有我太多的伙伴了，肯定有机会让你见识见识的！",
		"哟哟，不是被我的杀气吓到了吧，对，你们应该就这点本事吧！",
	},
	{
		"啊哈哈，火焰山洞的熔岩真好吃，要不要来点？！",
		"你以为你看到的只是虚幻的吗，哈哈，我可是很快就会真实的出现在你面前！",
		"我的火焰会把你们的家园都给烧成灰的！哈哈哈！！",
	},
}
local all_holes = {
	--水咕噜
	{
		{ 20009.714844, -1.249228, 20009.435547, },
		{ 20003.824219, 0.007834, 20030.017578, },
		{ 20066.841797, -2.101639, 20027.855469, },
		{ 20029.185547, -3.885290, 19989.771484, },
		{ 20010.189453, -3.273421, 19992.810547, },
		{ 19984.458984, 1.145665, 20014.791016, },
	},
	--枯木怪
	{
		{ 19950.562500, 3.892114, 20026.716797, },
		{ 19942.306641, 5.487996, 20044.203125, },
		{ 19912.673828, 8.845162, 20057.962891, },
		{ 19940.326172, 0.177640, 19998.408203, },
		{ 19920.332031, 8.853371, 20072.001953, },
		{ 19917.373047, 8.881139, 20097.833984, },
	},
	--金苍蝇
	{
		{ 19793.384766, 8.627041, 20055.558594, },
		{ 19769.798828, 8.817418, 20063.003906, },
		{ 19730.511719, 7.865498, 20082.748047, },
		{ 19667.511719, 6.570646, 20087.326172, },
		{ 19633.589844, 10.338051, 20100.677734, },
		{ 19620.259766, 11.670800, 20112.507813, },
	},
	--粘土巨人
	{
		{ 19566.865234, 11.655954, 20174.619141, },
		{ 19579.732422, 12.017240, 20191.408203, },
		{ 19545.603516, 13.189221, 20126.785156, },
		{ 19610.164063, 6.911617, 20032.767578, },
		{ 19638.064453, 7.132224, 20002.435547, },
		{ 19672.189453, 8.217219, 20004.917969, },
	},
	--松木妖
	{
		{ 19941.769531, 24.950724, 20205.042969, },
		{ 19919.281250, 24.893585, 20196.085938, },
		{ 19915.320313, 24.855156, 20215.619141, },
		{ 19981.490234, 28.568516, 20207.308594, },
		{ 19959.882813, 26.201666, 20183.257813, },
		{ 19906.392578, 24.882771, 20225.087891, },
	},
	--邪恶雪人
	{
		{ 20096.695313, 27.253609, 20354.132813, },
		{ 20093.814453, 27.238796, 20314.613281, },
		{ 20060.162109, 27.232847, 20307.416016, },
		{ 19998.660156, 28.420198, 20313.888672, },
		{ 19948.908203, 38.812115, 20296.957031, },
		{ 19881.531250, 32.655979, 20256.414063, },
	},
	--铁壳怪
	{
		{ 20049.339844, -4.586094, 19582.705078, },
		{ 20035.951172, -1.375446, 19634.962891, },
		{ 20101.384766, -1.247690, 19653.287109, },
		{ 20142.464844, -1.295553, 19638.337891, },
		{ 20179.080078, -1.878199, 19609.863281, },
		{ 20216.306641, -2.244944, 19599.404297, },
	},
	--烈火蟹
	{
		{ 20236.115234, -2.135133, 19602.843750, },
		{ 20263.517578, -1.847053, 19622.099609, },
		{ 20240.277344, -1.444001, 19638.468750, },
		{ 20178.261719, -1.268377, 19640.148438, },
		{ 20155.277344, -2.386208, 19601.162109, },
		{ 20118.144531, -1.466583, 19615.566406, },
	},
	--沙漠毒蝎
	{
		{ 20054.541016, -1.367517, 19638.947266, },
		{ 20082.404297, -1.755001, 19613.849609, },
		{ 20109.792969, -2.075070, 19595.644531, },
		{ 20130.830078, -1.563414, 19617.076172, },
		{ 20262.714844, -2.012587, 19600.968750, },
		{ 20308.054688, -1.377117, 19650.394531, },
	},
	----火鬃怪
	--{
		--{ 20175.041016, 3.890022, 20001.892578, },
		--{ 20210.591797, 4.061450, 19996.042969, },
		--{ 20215.728516, 3.924940, 20051.875000, },
		--{ 20194.064453, 3.916804, 20097.441406, },
		--{ 20162.316406, 3.899775, 20097.638672, },
		--{ 20184.546875, 3.923680, 20125.505859, },
	--},
	----火毛怪
	--{
		--{ 20179.558594, 3.901740, 20117.142578, },
		--{ 20144.525391, 11.510248, 20116.623047, },
		--{ 20170.345703, 3.877287, 20067.906250, },
		--{ 20204.126953, 3.875043, 20049.808594, },
		--{ 20214.218750, 3.916703, 20022.117188, },
		--{ 20220.703125, 3.915203, 20092.001953, },
	--},
	--纸条
	{
{ 19991.117188, 0.229088, 20014.097656, },
{ 20001.347656, -1.830426, 20000.312500, },
{ 19991.494141, -3.630171, 19987.421875, },
{ 20002.830078, -4.163382, 19980.171875, },
{ 20025.298828, -1.168449, 20042.419922, },
{ 20076.804688, -1.503818, 20055.039063, },
	},
	--纸条
	{
{ 19908.701172, 8.880562, 20089.339844, },
{ 19888.009766, 8.742620, 20077.464844, },
{ 19880.757813, 8.489891, 20050.777344, },
{ 19855.406250, 8.113218, 20039.875000, },
{ 19843.626953, 8.841310, 20023.962891, },
{ 19815.636719, 8.841518, 20035.169922, },
	},
	--纸条
	{
{ 19614.742188, 11.037171, 20097.611328, },
{ 19653.033203, 7.038331, 20094.382813, },
{ 19675.105469, 6.938030, 20097.009766, },
{ 19616.824219, 11.537107, 20126.751953, },
{ 19565.179688, 11.995167, 20155.287109, },
{ 19556.716797, 11.185997, 20167.451172, },
	},
	--纸条
	{
{ 19875.689453, 33.089436, 20253.777344, },
{ 19910.455078, 35.643528, 20289.349609, },
{ 19982.250000, 30.803761, 20310.882813, },
{ 20055.722656, 27.092173, 20314.166016, },
{ 20073.181641, 27.240780, 20340.306641, },
{ 20085.314453, 27.202366, 20338.099609, },
	},
	--纸条
	{
{ 20182.998047, -1.262797, 19639.917969, },
{ 20209.847656, -2.207718, 19604.244141, },
{ 20229.820313, -1.871628, 19613.054688, },
{ 20139.027344, -1.454298, 19627.910156, },
{ 20084.527344, -3.687419, 19583.371094, },
{ 20117.453125, -4.039441, 19576.158203, },
	},
	----纸条
	--{
--{ 20213.046875, 3.916696, 20092.796875, },
--{ 20190.003906, 3.100119, 19948.656250, },
--{ 20190.757813, 3.708679, 19981.996094, },
--{ 20193.570313, 3.881562, 20003.003906, },
--{ 20176.990234, 3.887842, 20027.587891, },
--{ 20197.257813, 3.886785, 20126.873047, },
	--},
}
--local len = #assets_map;
--for i = 1, len do
	--all_holes[i] = {};
	--for k = 1, static_hole_num do
		--if(not all_holes[i][k])then
			--all_holes[i][k] = {};
		--end
		--local hole =  all_holes[i][k];
		--hole[1] = 20070 + 5 * k;
		--hole[2] = 0.5;
		--hole[3] = 19732 + i * 5;
	--end
--end
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
-- SpriteBeep.main
function SpriteBeep.main()
	-- start the timer after 0 milliseconds, and signal every 1000 millisecond
	speak_timer:Change(0, 2000)
end
function SpriteBeep.PreDialog()
end
function SpriteBeep.main_item()
end

function SpriteBeep.PreDialog_item(npc_id, instance)
	local self = SpriteBeep;
	local place_square,place_index = SpriteBeep.ParseID(npc_id);
	if(place_square and place_index)then
		self.place_square = place_square;
		self.place_index = place_index;
		local tooltip_index = math.random(3);
		--self.Speek(npc_id,place_square,tooltip_index);
		SpriteBeep.DoKill();
		--显示纸条
		if(place_square > include_note)then
			NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/30360_FootprintNote.lua");
			local r = math.mod(npc_id,4) + 1;
			MyCompany.Aries.Quest.NPCs.FootprintNote.ShowPage(r);
		end
    end
	return false;
end
function SpriteBeep.DoKill()
	local self = SpriteBeep;
	local place_square,place_index = self.place_square,self.place_index;
	if(place_square and place_index)then
		Map3DSystem.GSL_client:SendRealtimeMessage("s30391", {body="[Aries][ServerObject30391]TryPickObj:"..place_square..":"..place_index});
	end
end
function SpriteBeep.MadeID(place_square,place_index)
	local self = SpriteBeep;
	if(not place_square or not place_index)then return end
	local head = 30391;
	place_square = string.format("%.2d",place_square);--最多100个区域
	place_index = string.format("%.2d",place_index);--每个区域最多100个位置，超过数量，解析将会出错
	local id = tostring(head)..place_square..place_index;
	return tonumber(id);
end
function SpriteBeep.ParseID(id)
	local self = SpriteBeep;
	id = tostring(id);
	if(not id)then return end
	local place_square,place_index = string.match(id,"30391(%d%d)(%d%d)");
	place_square = tonumber(place_square);
	place_index = tonumber(place_index);
	return place_square,place_index;
end
function SpriteBeep.CreateSprite(place_square,place_index,tooltip_index)
	local self = SpriteBeep;
	local id = SpriteBeep.MadeID(place_square,place_index);
	if(place_square == 5)then
		commonlib.echo("===========testindex");
		commonlib.echo({place_square,place_index,tooltip_index});
	end
	local item_info = assets_map[place_square];
	
	local pos = SpriteBeep.GetItemPos(place_square,place_index);
	if(not id or not item_info or not pos or not tooltip_index)then return end
	
	local npcChar = NPC.GetNpcCharacterFromIDAndInstance(id);
	if(npcChar and npcChar:IsValid() == true) then
		return;
	end
	
	local label = string.format("%s:%d",item_info.label,tooltip_index);
	--暂时用西瓜资源
	local assetFile = item_info.assetFile or "model/06props/v5/05other/Watermelon/Watermelon.x";
	local params;
	--显示为纸条
	if(place_square > include_note)then
		--最多每个区域显示三个怪物纸条
		if(place_index > 3)then
			pos[2] = -10000;
		end
		
		local r = math.mod(id,4) + 1;
		assetFile = string.format("model/06props/v5/03quest/ScripBigFeet/ScripMobs0%d.x",r);
		params = { 
			name = label,
			position = pos,
			facing = 0.89258199930191,
			scaling = 1,
			isalwaysshowheadontext = false,
			scaling_char = 1,
			assetfile_char = "character/common/dummy/cube_size/cube_size.x",
			assetfile_model = assetFile,
			cursor = "Texture/Aries/Cursor/select.tga",
			main_script = "script/apps/Aries/NPCs/TownSquare/30391_SpriteBeep.lua",
			main_function = "MyCompany.Aries.Quest.NPCs.SpriteBeep.main_item();",
			predialog_function = "MyCompany.Aries.Quest.NPCs.SpriteBeep.PreDialog_item",
			isdummy = true,
			autofacing = false,
		};
	else
		--最多每个区域显示两个怪
		if(place_index > 2)then
			pos[2] = -10000;
		end
		params = { 
			name = label,
			position = pos,
			facing = 0.89258199930191,
			scaling = 1,
			directscaling = true,
			isalwaysshowheadontext = false,
			--scaling_char = 1,
			--scaling_model = 1,
			assetfile_char = assetFile,
			assetfile_model = "model/common/aries_npc_boundingvolumn/aries_npc_boundingvolumn.x",
			cursor = "Texture/Aries/Cursor/select.tga",
			main_script = "script/apps/Aries/NPCs/TownSquare/30391_SpriteBeep.lua",
			main_function = "MyCompany.Aries.Quest.NPCs.SpriteBeep.main_item();",
			predialog_function = "MyCompany.Aries.Quest.NPCs.SpriteBeep.PreDialog_item",
			isdummy = true,
			autofacing = false,
		};
	end
	NPC.CreateNPCCharacter(id, params);
	sprite_maps[id] = {place_square = place_square, tooltip_index = tooltip_index, };
end
function SpriteBeep.Speek(id,place_square,tooltip_index)
	local self = SpriteBeep;
	if(not id or not place_square or not tooltip_index or place_square > include_note)then return end
	local npcChar = NPC.GetNpcCharacterFromIDAndInstance(id);
	local tooltip = tooltip_libs[place_square][tooltip_index];
	if(npcChar and npcChar:IsValid() == true and tooltip) then
		--headon_speech.MaxConcurrentSpeech = 20;
		headon_speech.Speek(npcChar.name or "", headon_speech.GetBoldTextMCML(tooltip), 5);
	end
end
function SpriteBeep.DestroyInstance(place_square,place_index)
	local self = SpriteBeep;
	local id = SpriteBeep.MadeID(place_square,place_index);
	if(not id)then return end
	NPC.DeleteNPCCharacter(id);
	sprite_maps[id] = nil;
end
function SpriteBeep.GetItemPos(place_square,place_index)
	local self = SpriteBeep;
	if(place_square and place_index)then
		local holes = all_holes[place_square];
		if(holes)then
			return holes[place_index];
		end
	end
end