--[[
Title: BigToothOgre
Author(s): Leio
Date: 2010/04/24

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30379_BigToothOgre.lua");
MyCompany.Aries.Quest.NPCs.BigToothOgre.TestHit(200)
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30379_BigToothOgre.lua");
local uid = "20100427T065034.889303-192";
MyCompany.Aries.Quest.NPCs.BigToothOgre.TestPickObj(uid)

NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30379_BigToothOgre.lua");
MyCompany.Aries.Quest.NPCs.BigToothOgre.RecoverNpcAndItems();
------------------------------------------------------------
]]

-- create class
local libName = "BigToothOgre";
local BigToothOgre = {
	cur_anger = 0,
	max_anger = 300,
	cur_level = 0,--level is 0--2
	cur_pos_index = 1,
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.BigToothOgre", BigToothOgre);
--大牙怪的位置
--local ogre_positions = {
	--{ 20096.560546875, 0.24123176932335, 19740.8828125},
	--{ 20076.109375, 0.47456032037735, 19736.9609375},
	--{ 20052.5703125, 0.49286359548569, 19739.826171875},
	--{ 20108.39453125, 0.4999965429306, 19753.7265625},
--}
local ogre_positions = {
	{ 20060.263671875, 1.5, 19801.51953125}, --小镇广场
	{ 19957.0859375, 0.67906188964844, 19884.951171875}, --龙龙乐园
	{ 19801, 0.0045943260192871, 19914.134765625},--农场
	{ 20190.81640625, 3.4999990463257, 19685.72265625},--购物街
}
local ogre_facing = {
	-1.8,2.1,0.2,-1.9,
}
--牌子的位置
local ogre_panel_positions = {
	{ 20054.451171875, 1.5000009536743, 19802.267578125},
	{19950.689453125, 0.89292597770691, 19888.2578125},
	{19803.0859375, -0.071084000170231, 19920.498046875},
	{20184.443359375, 3.4999558925629, 19683.703125},
}
--local k;
--for k = 1, 4 do
	--ogre_panel_positions[k] = {};
	--ogre_panel_positions[k][1] = ogre_positions[k][1] + 3;
	--ogre_panel_positions[k][2] = ogre_positions[k][2];
	--ogre_panel_positions[k][3] = ogre_positions[k][3];
--end
local ogre_panel_rotation = {
	{ w=0.020794741809368, x=0, y=0.9997838139534, z=0 },
	{ w=0.96891242265701, x=0, y=0.24740371108055, z=0 },
	{ w=0.92106091976166, x=0, y=-0.38941848278046, z=0 },
	{ w=0.020794725045562, x=0, y=0.99978375434875, z=0 },
}
local gift_positions = {
	
}
--礼物的相对位置
local radius_gift = 7;
local i = 1;
for i = 1, 45 do
	gift_positions[i] = {};
	local a = (6.28 / 45 * i);
	local radius = radius_gift + math.random(0,300)/100;
	gift_positions[i][1] = 0 + math.cos(a) * radius;
	gift_positions[i][2] = 0;
	gift_positions[i][3] = 0 + math.sin(a) * radius;
	gift_positions[i][2] = ParaTerrain.GetElevation(gift_positions[i][1], gift_positions[i][3]);
end

local gift_gsid_maps = {
	{ gsid = 30147, label = "姜饼小白人", file = "model/02furniture/v5/CandyHouseDeco/ToyCandy/ToyCandy_01.x",},
	{ gsid = 30148, label = "姜饼小黑人", file = "model/02furniture/v5/CandyHouseDeco/ToyCandy/ToyCandy_02.x",},
	{ gsid = 30149, label = "香蕉壁灯", file = "model/02furniture/v5/CandyHouseDeco/BananaLight/BananaLight.x",},
	{ gsid = 30150, label = "糖纸地毯", file = "model/02furniture/v5/CandyHouseDeco/CandyCarpet/CandyCarpet_02.x",},
	{ gsid = 30151, label = "饼干画框", file = "model/02furniture/v5/CandyHouseDeco/BiscuitPhotoframe/BiscuitPhotoframe.x",},
}
local stages_texture = {
	"character/v5/01human/MolarOgre/MolarOgre_01.dds",
	"character/v5/01human/MolarOgre/MolarOgre_02.dds",
	"character/v5/01human/MolarOgre/MolarOgre_03.dds",
}
local ogre_npc_id = 303791;
local ogre_panel_id = 303792;
local gift_start_uid = 10000;
local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
function BigToothOgre.main()
	local self = BigToothOgre;
	self.RecoverNpcAndItems();
	-- hook into OnThrowableHit
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnThrowableHit") then
				if(msg.msg.nid == System.App.profiles.ProfileManager.GetNID()) then
					local msg = msg.msg;
					commonlib.echo(msg);
					-- on hit dirty elk with snow ball
					if(msg.throwItem.gsid == 9505) then
						local tooth_ogre = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(ogre_npc_id,self.cur_pos_index or 1);
						if(tooth_ogre and tooth_ogre:IsValid() == true) then
							local _, name;
							for _, name in pairs(msg.hitObjNameList or {}) do
								if(name == tooth_ogre.name) then
									-- hit on self
									Map3DSystem.GSL_client:SendRealtimeMessage("s30379", {body="[Aries][ServerObject30379]OnHit:1"});
									-- auto show snowman select page 
									MyCompany.Aries.Desktop.TargetArea.ShowNPCSelectPage(ogre_npc_id,self.cur_pos_index or 1);
								end
							end
						end
					end
				end
			end
		end, 
	hookName = "OnThrowableHit_30379_BigToothOgre", appName = "Aries", wndName = "throw"});
end
function BigToothOgre.recover_main()
	
end
function BigToothOgre.PreDialog()
	local self = BigToothOgre;
	NPL.load("(gl)script/ide/headon_speech.lua");
	local npcChar = NPC.GetNpcCharacterFromIDAndInstance(ogre_npc_id,self.cur_pos_index);
	if(npcChar and npcChar:IsValid() == true) then
		headon_speech.Speek(npcChar.name or "", headon_speech.GetBoldTextMCML("快喂我点糖豆豆吧，我最爱吃糖豆豆！"), 5);
	end
	return false;
end
function BigToothOgre.TestPickObj(uid)
	if(not uid)then return end
	Map3DSystem.GSL_client:SendRealtimeMessage("s30379", {body="[Aries][ServerObject30379]TryPickObj:"..uid});
end
function BigToothOgre.TestHit(v)
	if(not v)then
		v = 40;
	end
	Map3DSystem.GSL_client:SendRealtimeMessage("s30379", {body="[Aries][ServerObject30379]OnHit:"..v});
end
function BigToothOgre.UpdateLevel()
	local self = BigToothOgre;
	--level is 0 to 2
	local level = math.floor(self.cur_anger/100);
	commonlib.echo("==========BigToothOgre.UpdateLevel");
	commonlib.echo(self.cur_level);
	commonlib.echo(level);
	if(self.cur_level < level)then
		--升级
		--_guihelper.MessageBox(self.cur_anger..":升级到："..level);
		self.SetStage(level)
		self.cur_level = level;
	else
		--_guihelper.MessageBox(self.cur_anger.."目前级别："..level);
	end
end
-- replaceable texture
function BigToothOgre.SetStage(level)
	local self = BigToothOgre;
	local level = level + 1
	if(level > 3) then
		return;
	end
	local npc = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(ogre_npc_id,self.cur_pos_index);
	if(npc and npc:IsValid() == true) then
		local assetfile = stages_texture[level];
		if(assetfile)then
			npc:SetReplaceableTexture(1, ParaAsset.LoadTexture("", assetfile, 1));
		end
	end
end
function BigToothOgre.SetCurAnger(anger)
	local self = BigToothOgre;
	commonlib.echo("==========anger");
	commonlib.echo(anger);
	self.cur_anger = anger;
	self.UpdateLevel();
end

--生成礼物
function BigToothOgre.CreateGiftInstance(uid,gift_type,place_index,center_index,noAnim)
	local self = BigToothOgre;
	uid = tonumber(uid);
	gift_type = tonumber(gift_type);
	place_index = tonumber(place_index);
	center_index = tonumber(center_index);
	center_index = center_index or 1;
	commonlib.echo("==========BigToothOgre.CreateGiftInstance");
	commonlib.echo(uid);
	commonlib.echo(gift_type);
	commonlib.echo(place_index);
	commonlib.echo(center_index);
	
	if(not uid or not gift_type or not place_index or not center_index)then return end
	local npcChar = NPC.GetNpcCharacterFromIDAndInstance(uid);
	if(npcChar and npcChar:IsValid() == true) then
		return;
	end
	
	local pos = gift_positions[place_index];
	commonlib.echo("==========pos");
	commonlib.echo(pos);
	local center = ogre_positions[center_index];
	commonlib.echo("==========center");
	commonlib.echo(center);
	
	local noew_pos = {};
	noew_pos[1] = pos[1] + center[1];
	noew_pos[2] = pos[2] + center[2];
	noew_pos[3] = pos[3] + center[3];
	commonlib.echo(noew_pos);
	--礼物信息
	local gift_info = gift_gsid_maps[gift_type];
	if(not gift_info)then return end
	local gsid = gift_info.gsid;
	local label = gift_info.label;
	local assetFile = gift_info.file;
	local params = { 
		name = label,
		--instance = index,
		position = noew_pos,
		facing = 0.89258199930191,
		scaling = 0.8,
		isalwaysshowheadontext = false,
		scaling_char = 1.5,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",
		assetfile_model = assetFile,
		cursor = "Texture/Aries/Cursor/Pick.tga",
		main_script = "script/apps/Aries/NPCs/TownSquare/30379_BigToothOgre.lua",
		main_function = "MyCompany.Aries.Quest.NPCs.BigToothOgre.main_gift();",
		predialog_function = "MyCompany.Aries.Quest.NPCs.BigToothOgre.PreDialog_gift",
		isdummy = true,
		autofacing = false,
	};
	NPC.CreateNPCCharacter(gift_start_uid + uid, params);
	if(not noAnim)then
		BigToothOgre.ThrowGift(gift_start_uid + uid,place_index,center_index)
	end
end
function BigToothOgre.ThrowGift(uid,index,center_index)
	local self = BigToothOgre;
	if(not uid or not index) then
		return;
	end
	local position = gift_positions[index];
	center_index = center_index or self.cur_pos_index;
	local center = ogre_positions[center_index];
	
	local c_x, c_y, c_z = center[1], center[2], center[3];
	local x, y, z = position[1] + c_x, position[2] + c_y, position[3] + c_z;
	
	
	local duration_time = math.mod(index, 7) * 0.2 + math.mod(index, 5) * 0.5;
	local height = (20 / 8) * duration_time * duration_time;
	duration_time = duration_time * 1000;
	
	UIAnimManager.PlayCustomAnimation(duration_time, function(elapsedTime)
		local gift, gift_model = MyCompany.Aries.Quest.NPC.GetNpcCharModelFromIDAndInstance(uid);
		if(gift and gift_model) then
			if(elapsedTime == duration_time) then
				gift:SetPosition(x, y, z);
				gift_model:SetPosition(x, y, z);
			else
				local t_x = c_x - (c_x - x) * (elapsedTime / duration_time);
				local t_z = c_z - (c_z - z) * (elapsedTime / duration_time);
				local t = math.abs(elapsedTime - duration_time / 2) / 1000;
				local t_y = y + height - 0.5 * 20 * t * t;
				gift:SetPosition(t_x, t_y, t_z);
				gift_model:SetPosition(t_x, t_y, t_z);
			end
		end
	end);
end
function BigToothOgre.main_gift()
end
function BigToothOgre.PreDialog_gift(npc_id, instance)
	local self = BigToothOgre;
	commonlib.echo("==========BigToothOgre.npc_id");
	commonlib.echo(npc_id);
	local uid = npc_id - gift_start_uid;
	if(not uid)then return end
	Map3DSystem.GSL_client:SendRealtimeMessage("s30379", {body="[Aries][ServerObject30379]TryPickObj:"..uid});
	return false;
end
function BigToothOgre.DestroyGiftInstance(uid)
	local self = BigToothOgre;
	uid = tonumber(uid);
	commonlib.echo("==========BigToothOgre.DestroyGiftInstance");
	commonlib.echo(uid);
	NPC.DeleteNPCCharacter(gift_start_uid + uid);
	if(self.cur_lived_items)then
		self.cur_lived_items[uid] = nil;
	end
end
function BigToothOgre.RecvGift(gift_type)
	gift_type = tonumber(gift_type);
	commonlib.echo("==========BigToothOgre.RecvGift");
	if(not gift_type)then return end
	local gift_info = gift_gsid_maps[gift_type];
	
	if(not gift_info)then return end
	local gsid = gift_info.gsid;
	local label = gift_info.label;
	ItemManager.PurchaseItem(gsid, 1, function(msg)
		if(msg) then
			log("+++++++SnowMan.OnRecvGift#"..tostring(gsid).." Purchase item return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess) then
				_guihelper.MessageBox(string.format([[<div style="margin-top:24px;margin-left:20px;">恭喜你获得一个%s，已经放进你家园仓库啦！</div>]], label));
			end
		end
	end);
end
--重新生成大牙怪
function BigToothOgre.RebornIndex(index)
	local self = BigToothOgre;
	index = tonumber(index);
	commonlib.echo("==========BigToothOgre.RebornIndex");
	commonlib.echo(index);
	self.cur_anger = 0;
	self.cur_level = 0;
	local old_index = self.cur_pos_index;
	self.cur_pos_index = index;
	self.DeleteNPC(old_index);
	self.CreateNPC(index);
end
function BigToothOgre.BackupAnger(anger)
	local self = BigToothOgre;
	commonlib.echo("==========BigToothOgre.BackupAnger");
	commonlib.echo(anger);
	self.cur_anger = anger;
	self.cur_level = math.floor(self.cur_anger/100);
	
end
--备份当前礼物列表，在加载公共世界后，读取当前礼物生成的情况
function BigToothOgre.BackupLivedItems(lived_items)
	local self = BigToothOgre;
	commonlib.echo("==========BigToothOgre.BackupLivedItems");
	commonlib.echo(lived_items);
	self.cur_lived_items = lived_items;
	--if(self.cur_lived_items)then
		--local k,item;
		--for k,item in pairs(self.cur_lived_items) do
			--self.CreateGiftInstance(item.uid,item.gift_type,item.place_index,nil,true);
		--end
	--end
end
--备份当前怪物的位置，在加载公共世界后，读取怪物当前的位置
function BigToothOgre.BackupBornIndex(index)
	local self = BigToothOgre;
	commonlib.echo("==========BigToothOgre.BackupBornIndex");
	commonlib.echo(index);
	self.cur_pos_index = index;
	--在登录成功后 从这里创建NPC
	if(not self.hasBuild)then
		self.RecoverNpcAndItems();
		self.hasBuild = true;
	end
end
function BigToothOgre.DeleteNPC(pos_index)
	local self = BigToothOgre;
	pos_index = tonumber(pos_index);
	if(not pos_index)then return end
	NPC.DeleteNPCCharacter(ogre_npc_id,1);
	NPC.DeleteNPCCharacter(ogre_npc_id,2);
	NPC.DeleteNPCCharacter(ogre_npc_id,3);
	NPC.DeleteNPCCharacter(ogre_npc_id,4);
	GameObject.DeleteGameObjectCharacter(ogre_panel_id);
end
--重新创建NPC
function BigToothOgre.CreateNPC(pos_index)
	local self = BigToothOgre;
	pos_index = tonumber(pos_index);
	if(not pos_index)then return end
	local pos =  ogre_positions[pos_index];
	if(not pos)then return end
	commonlib.echo("===============BigToothOgre.CreateNPC");
	commonlib.echo(ogre_npc_id);
	commonlib.echo(pos_index);
	commonlib.echo(pos);
	local npcChar = NPC.GetNpcCharacterFromIDAndInstance(ogre_npc_id,pos_index);
	if(npcChar and npcChar:IsValid() == true) then
		return;
	end
	commonlib.echo("===============BigToothOgre.CreateNPC2");
	local facing = ogre_facing[pos_index];
	local params = {
		name = "大牙怪"..pos_index,
		instance = pos_index,
		position = pos,
		facing = facing or 0,
		--scaling = 1,
		scaling_char = 0.8,
		scaling_model = 1,
		--directscaling = true,
		isalwaysshowheadontext = false,
		--assetfile_char = "character/common/dummy/elf_size/elf_size.x",
		assetfile_char = "character/v5/01human/MolarOgre/MolarOgre.x",
		--assetfile_model = "model/06props/v5/03quest/SnowMen/SnowMan_Yellow.x",
		
		main_script = "script/apps/Aries/NPCs/TownSquare/30379_BigToothOgre.lua",
		main_function = "MyCompany.Aries.Quest.NPCs.BigToothOgre.recover_main();",
		predialog_function = "MyCompany.Aries.Quest.NPCs.BigToothOgre.PreDialog",
		selected_page = "script/apps/Aries/NPCs/TownSquare/30379_BigToothOgre_selected.html",
		isdummy = true,
	}; -- 大牙怪
	NPC.CreateNPCCharacter(ogre_npc_id, params);
	self.SetStage(self.cur_level);
	--提示牌
	local panel_pos = ogre_panel_positions[pos_index];
	local panel_rotation = ogre_panel_rotation[pos_index];
	if(not panel_pos)then return end
	local params = { 
		name = "大牙怪 提示牌",
		position = panel_pos,
		facing = 0,
		scaling = 1.2,
		rotation = panel_rotation,
		--scaling_model = 0.8,
		scaling_char = 2,
		assetfile_model = "model/06props/v5/02street/WoodenEntrancePanel/WoodenEntrancePanel_MolarOgre.x",
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",
		gameobj_type = "MCMLPage",
		page_url = "script/apps/Aries/NPCs/TownSquare/30379_BigToothOgre_panel.html",
	};
	GameObject.CreateGameObjectCharacter(ogre_panel_id,params);
end
--重新恢复目前npc的位置 级别 和已经产生的物品
function BigToothOgre.RecoverNpcAndItems()
	local self = BigToothOgre;
	self.cur_pos_index = self.cur_pos_index or 1;
	self.cur_level = self.cur_level or 0;
	self.cur_anger = self.cur_anger or 0;
	self.cur_lived_items = self.cur_lived_items or {};
	self.DeleteNPC(self.cur_pos_index);
	self.CreateNPC(self.cur_pos_index);
	local k,item;
	commonlib.echo("=================BigToothOgre.RecoverNpcAndItems1");
	for k,item in pairs(self.cur_lived_items) do
		commonlib.echo(item);
		NPC.DeleteNPCCharacter(item.uid);
		self.CreateGiftInstance(item.uid,item.gift_type,item.place_index,item.center_index,true);
	end
	commonlib.echo("=================BigToothOgre.RecoverNpcAndItems");
	commonlib.echo(self.cur_pos_index);
	commonlib.echo(self.cur_level);
	commonlib.echo(self.cur_anger);
	commonlib.echo(self.cur_lived_items);
end
function BigToothOgre.TestIndex(a,b)
	commonlib.echo("=================BigToothOgre.TestIndex");
	commonlib.echo(a);
	commonlib.echo(b);
end
function BigToothOgre.TestIndex1()
	commonlib.echo("=================BigToothOgre.TestIndex1");
end
