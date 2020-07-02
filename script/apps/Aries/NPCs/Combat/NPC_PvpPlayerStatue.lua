--[[
Title: Player statue(sculpture) for high ranking players in the last seasos
Author(s): LiXizhi
Date: 2010/9/20
Desc: We will use a shader to render the pvp player. 

use the lib:
------------------------------------------------------------
-- One pass: to dump to log file
-- checkout: alienbrain://PARA2/KidsMovie:595/ParaEngineSDK/config/Aries/Ranking/ranking_region0.xml
NPL.load("(gl)script/apps/Aries/NPCs/Combat/NPC_PvpPlayerStatue.lua");
local PvpPlayerStatue = commonlib.gettable("MyCompany.Aries.Quest.NPCs.PvpPlayerStatue");
PvpPlayerStatue.load_champions_rank_from_file()
-- second params: 7 nids: storm, ice, fire, life, death, 1v1_all, 2v2_all
PvpPlayerStatue.DumpAccordingToCurrentGlodRankingList("201306", nil, {251764232,11905947,63283879,234015445,99771655,63283879,224111697});

-- step 1: intranet: get data without ccs
NPL.load("(gl)script/apps/Aries/NPCs/Combat/NPC_PvpPlayerStatue.lua");
local PvpPlayerStatue = commonlib.gettable("MyCompany.Aries.Quest.NPCs.PvpPlayerStatue");
PvpPlayerStatue.DumpAccordingToCurrentGlodRankingList("201109", false);

-- step 2: internet: refresh ccs 
NPL.load("(gl)script/apps/Aries/NPCs/Combat/NPC_PvpPlayerStatue.lua");
local PvpPlayerStatue = commonlib.gettable("MyCompany.Aries.Quest.NPCs.PvpPlayerStatue");
PvpPlayerStatue.DumpChampionsCCSParams();

-- Only dumping to file again
PvpPlayerStatue.dump_champions_rank_to_file();

-- In NPC config file, we can add
<main main_script="script/apps/Aries/NPCs/Combat/NPC_PvpPlayerStatue.lua" main_function="MyCompany.Aries.Quest.NPCs.PvpPlayerStatue.main();"/>
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatProfile.lua");
local RankingServer = commonlib.gettable("MyCompany.Aries.GoldRankingList.RankingServer");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
local PvpPlayerStatue = commonlib.gettable("MyCompany.Aries.Quest.NPCs.PvpPlayerStatue");
local CCS = commonlib.gettable("Map3DSystem.UI.CCS");
local pe_player = commonlib.gettable("MyCompany.Aries.mcml_controls.pe_player");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
local OPC = commonlib.gettable("MyCompany.Aries.OPC");

local sculpture_effect_handle = 1003;
local sculpture_shader_file = "script/ide/Effect/Shaders/Sculpture.fxo";
local headon_text_color = "255 128 128";
-- sculpture effect will render a model with grey statue-like material
-- @return effect, effect_tech_id: 
function PvpPlayerStatue.CreateGetSculptureEffect()
	local effect = ParaAsset.GetEffectFile("sculpture");
	if(effect:IsValid() == false)then
		LOG.std(nil, "debug", "PvpPlayerStatue", "shader file %s is loaded", sculpture_shader_file)
		effect = ParaAsset.LoadEffectFile("sculpture", sculpture_shader_file);
		effect = ParaAsset.GetEffectFile("sculpture");
		effect:SetHandle(sculpture_effect_handle);
		local params = effect:GetParamBlock();
		-- TODO: replace with values
		params:SetBoolean("g_bEnvironmentMap",false);
		params:SetTexture(1, "model/common/sculpture/marbleTex.dds");
		-- params:SetTexture(2, "model/common/sculpture/skyBox.dds");
		-- params:SetTexture(2, "model/skybox/skybox15/3.dds");
	else
		local handle = effect:GetHandle();
		if(handle == -1)then
			effect:SetHandle(sculpture_effect_handle);	
		end
	end
	return effect, sculpture_effect_handle;
end


--[[ champions: TODO: this may be read from xml table or game server in future.

---++ how to set ccs_params. 
	-- Method1: call below and paste clipboard
	NPL.load("(gl)script/apps/Aries/NPCs/Combat/NPC_PvpPlayerStatue.lua");
	local PvpPlayerStatue = commonlib.gettable("MyCompany.Aries.Quest.NPCs.PvpPlayerStatue");
	PvpPlayerStatue.DumpAccordingToCurrentGlodRankingList("201106");

	-- MyCompany.Aries.Quest.NPCs.PvpPlayerStatue.DumpChampionsCCSParams()

	-- Method2:  use following code to get "ccs_params" of any given player
	NPL.load("(gl)script/apps/Aries/mcml/pe_avatar.lua");
	local pe_player = commonlib.gettable("MyCompany.Aries.mcml_controls.pe_player");
	local nid_number = 237677592
	pe_player.GetCCSParams(nid_number, "self", function(params)
		commonlib.echo({nid_number, ccs_params=params});
	end)

	BTW: we can replace #1297 with #0
---++ anim_file
	character/Animation/v5/ElfFemale_sit.x
	
]]

local school_attr_map = {
	storm = {name = "风暴", text_color="255 204 0" } ,
	fire = {name = "烈火",text_color="255 51 0" } ,
	ice = {name = "寒冰",text_color="51 153 255" } ,
	life = {name = "生命",text_color="0 204 0" } ,
	death = {name = "死亡",text_color="51 51 51" } ,
}

-- in the following order: storm, fire, ice, life, death, 1v1, 2v2, family1, family2, family3, family4, family5, 
local champions_players = {{nid=101261741,name="〓梅☆西〓",text_color="255 204 0",school="风暴",anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose1.x",ccs_params={characterslot_info_string="1716#0#0#0#0#0#0#0#0#0#1788#0#0#0#0#0#1723#1198#1765#1730#1764#1737#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},{nid=32479240,name="God~典伊",text_color="51 153 255",school="寒冰",anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose1.x",ccs_params={characterslot_info_string="1307#0#0#0#0#0#0#0#0#0#1788#0#0#0#0#0#1549#1067#1765#1630#1764#1736#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},{nid=200452951,name=" 〓怀☆念〓",text_color="255 51 0",school="烈火",anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose1.x",ccs_params={characterslot_info_string="1714#0#0#0#0#0#0#0#0#0#1788#0#0#0#0#0#1721#1009#1765#1728#1764#1735#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},{nid=169536637,name="〓雷☆伊〓",text_color="0 204 0",school="生命",anim_file="",ccs_params={characterslot_info_string="1718#0#0#0#0#0#0#0#0#0#1788#0#0#0#0#0#1725#1203#1765#1732#1764#1739#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},{nid=227064418,name="╘*.恶魔 绝′",text_color="51 51 51",school="死亡",anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose2.x",ccs_params={characterslot_info_string="0#0#0#0#0#0#0#0#0#0#1788#0#0#0#0#0#1221#1222#1765#1195#1764#1738#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},{nid=32479240,name="God~典伊",text_color="255 204 0",school="风暴",title="1v1冠军",anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose1.x",ccs_params={characterslot_info_string="1307#0#0#0#0#0#0#0#0#0#1788#0#0#0#0#0#1549#1067#1765#1630#1764#1736#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},{nid=101261741,name="〓梅☆西〓",text_color="255 204 0",school="风暴",title="2v2冠军",anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose1.x",ccs_params={characterslot_info_string="1716#0#0#0#0#0#0#0#0#0#1788#0#0#0#0#0#1723#1198#1765#1730#1764#1737#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},{nid=101261741,name="〓梅☆西〓",text_color="0 204 0",school="生命",title="快乐游子族家族英雄",anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose1.x",ccs_params={characterslot_info_string="1716#0#0#0#0#0#0#0#0#0#1788#0#0#0#0#0#1723#1198#1765#1730#1764#1737#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},{nid=264170469,name="小小山",text_color="0 204 0",school="生命",title="ooo家族家族英雄",anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose1.x",ccs_params={characterslot_info_string="1718#0#0#0#0#0#0#0#0#0#1688#1296#0#0#0#0#1725#1051#1765#1732#1764#1589#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},{nid=68231158,name="❈提拉米苏❈",text_color="0 204 0",school="生命",title="永远の童话家族英雄",anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose1.x",ccs_params={characterslot_info_string="1718#0#0#0#0#0#0#0#0#0#1788#0#0#0#0#0#1725#1098#1118#1732#1764#1739#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},{nid=86092004,name="雪宁凌",text_color="0 204 0",school="生命",title="◢██◣家族英雄",anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose2.x",ccs_params={characterslot_info_string="1201#0#0#0#0#0#0#0#0#0#1189#1022#0#0#0#0#1092#1139#1765#1100#1764#1737#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},{nid=32479240,name="God~典伊",text_color="0 204 0",school="生命",title="God~家族英雄",anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose1.x",ccs_params={characterslot_info_string="1307#0#0#0#0#0#0#0#0#0#1788#0#0#0#0#0#1549#1067#1765#1630#1764#1736#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},{nid=63283879,name="God~雅典娜",text_color="51 153 255",school="生命",title="挑战英雄",anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose1.x",ccs_params={characterslot_info_string="1714#0#0#0#0#0#0#0#0#0#1788#0#0#0#0#0#1721#1057#0#1728#1764#1735#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},{nid=68231158,name="❈提拉米苏❈",text_color="51 153 255",school="生命",title="挑战英雄",anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose2.x",ccs_params={characterslot_info_string="1718#0#0#0#0#0#0#0#0#0#1788#0#0#0#0#0#1725#1098#1118#1732#1764#1739#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},{nid=101261741,name="〓梅☆西〓",text_color="51 153 255",school="生命",title="挑战英雄",anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose1.x",ccs_params={characterslot_info_string="1716#0#0#0#0#0#0#0#0#0#1788#0#0#0#0#0#1723#1198#1765#1730#1764#1737#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},{nid=210002337,name="〓金☆灵〓",text_color="51 153 255",school="生命",title="挑战英雄",anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose1.x",ccs_params={characterslot_info_string="1716#0#0#0#0#0#0#0#0#0#1749#0#0#0#0#0#1723#1104#1765#1730#1764#1737#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},{nid=210002337,name="〓金☆灵〓",text_color="51 153 255",school="生命",title="挑战英雄",anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose1.x",ccs_params={characterslot_info_string="1716#0#0#0#0#0#0#0#0#0#1749#0#0#0#0#0#1723#1104#1765#1730#1764#1737#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},}

-- mapping from region id to region data
local champions_players_regions = {
	[0] = champions_players,
	[2] = {},
}

--[[{
	{name="╘*.天使 零′", school="风暴", nid="226649540", text_color="255 204 0", anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose1.x", ccs_params={characterslot_info_string="1532#0#0#0#0#0#0#0#0#0#1749#0#0#0#0#0#1103#1193#1194#1280#0#1713#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},
	{name="飞翔", school="寒冰", nid="137223993", text_color="51 153 255", anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose1.x", ccs_params={characterslot_info_string="1340#0#0#0#0#0#0#0#0#0#1685#0#0#0#0#0#1552#1067#1214#1368#0#1713#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},
	{name="◥雲▣長◤", school="烈火", nid="200452951", text_color="255 51 0", anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose1.x", ccs_params={characterslot_info_string="1714#0#0#0#0#0#0#0#0#0#1747#0#0#0#0#0#1721#1057#0#1728#0#1713#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},
	{name="雷伊", school="生命", nid="169536637", text_color="0 204 0", anim_file="", ccs_params={characterslot_info_string="1718#0#0#0#0#0#0#0#0#0#1684#0#0#0#0#0#1725#0#0#1369#0#1713#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},
	{name="莫西", school="死亡", nid="92083451", text_color="51 51 51", anim_file="character/Animation/v5/Elf_animation/ElfFemale_pose2.x", ccs_params={characterslot_info_string="1535#0#0#0#0#0#0#0#0#0#1648#0#0#0#0#0#1455#1101#1079#1458#0#1676#0#0#0#0#",cartoonface_info_string="0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#",assetfile="character/v3/Elf/Female/ElfFemale.xml",facial_info_string="0#1#0#1#1#",},},
}]]
-- how they appear in a line in the 3d scene
local champions_standpoint_map = {1, 3, 2, 4, 5,    6,7,     8,9,10,11,12,   13,14,15,16}
local champions_families = {{text_color="255 51 0",model_scale=1.2,model_file="model/06props/v5/02street/KempBanner/KempBanner01.x",char_offset=9,family_id="226649540",familyname="快乐游子族",},{text_color="255 204 0",model_scale=1.1,model_file="model/06props/v5/02street/KempBanner/KempBanner02.x",char_offset=7,family_id="137223993",familyname="ooo家族",},{text_color="51 153 255",model_scale=1,model_file="model/06props/v5/02street/KempBanner/KempBanner03.x",char_offset=6.5,family_id="200452951",familyname="永远の童话",},{familyname="◢██◣",text_color="255 51 0",model_file="model/06props/v5/02street/KempBanner/KempBanner01.x",char_offset=9,family_id="226649540",model_scale=1.2,},{familyname="&美得冒泡&",text_color="255 51 0",model_file="model/06props/v5/02street/KempBanner/KempBanner01.x",char_offset=9,family_id="226649540",model_scale=1.2,},}
-- mapping from region id to region data
local champions_families_regions = {
	[0] = champions_families,
	[2] = {},
}
--[[{
	{name="AA冠军家族", family_id="226649540", text_color="255 51 0", model_scale=1.2, char_offset=9, model_file="model/06props/v5/02street/KempBanner/KempBanner01.x", },
	{name="BB亚军家族", family_id="137223993", text_color="255 204 0", model_scale=1.1, char_offset=7, model_file="model/06props/v5/02street/KempBanner/KempBanner02.x", },
	{name="CC季军家族", family_id="200452951", text_color="51 153 255", model_scale=1,  char_offset=6.5,  model_file="model/06props/v5/02street/KempBanner/KempBanner03.x", },
}]]


-- this function can be called as many times as one like. only the first time takes effect. 
function PvpPlayerStatue.LoadRanking()
	if(PvpPlayerStatue.is_loading) then
		return;
	end
	PvpPlayerStatue.is_loading = true;
	-- here we just simply load from file. 
	PvpPlayerStatue.load_champions_rank_from_file();
end

-- save current champions data to file:
-- @param rank_date: if nil it is last month like "201109"
-- @param filename: if nil, it is "config/Aries/Ranking/ranking_region%d.xml"
function PvpPlayerStatue.load_champions_rank_from_file(filename)
	filename = filename or format("config/Aries/Ranking/ranking_region%d.xml", MyCompany.Aries.ExternalUserModule:GetRegionID())
	LOG.std(nil, "info", "PvpPlayerStatue", "rank file loaded from %s", filename)

	local xmlDocIP = ParaXML.LuaXML_ParseFile(filename);
	if(xmlDocIP) then
		local node = commonlib.XPath.selectNode(xmlDocIP, "/ranking/players");
		
		if(node) then
			if(node.attr and node.attr.standpoint) then
				champions_standpoint_map = NPL.LoadTableFromString(node.attr.standpoint);
				--echo(champions_standpoint_map)
			end
			local nodes = commonlib.XPath.selectNodes(node, '//player');
			local index, node
			for index, node in ipairs(nodes) do
				if(node[1]) then
					champions_players[index] = NPL.LoadTableFromString(node[1]);
					--echo(champions_players[index])
				end
			end
		end
		local nodes = commonlib.XPath.selectNodes(xmlDocIP, '/ranking/families/pvp/family');
		if(nodes and #nodes>0) then
			local index, node
			for index, node in ipairs(nodes) do
				if(node[1]) then
					champions_families[index] = NPL.LoadTableFromString(node[1]);
					--echo(champions_families[index])
				end
			end
		else
			LOG.std(nil, "warn", "PvpPlayerStatue", "no pvp family node")
		end
	else
		LOG.std(nil, "warn", "PvpPlayerStatue", "unable to open rank file at %s", filename)
	end
end

-- save current champions data to file:
-- @param rank_date: if nil it is last month like "201109"
-- @param filename: if nil, it is "config/Aries/Ranking/ranking_region%d.xml"
function PvpPlayerStatue.dump_champions_rank_to_file(rank_date, filename)
	echo("==============champions_players===============");
	local str = commonlib.serialize_compact(champions_players):gsub("[\r\n]", ""):gsub("\\r", ""):gsub("\\\"", "\"");
	commonlib.log(str.."\n");

	NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingListMain.lua");
	NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingPKListMain_history.lua");
	local GoldRankingListMain = commonlib.gettable("MyCompany.Aries.GoldRankingList.GoldRankingListMain");
	local GoldRankingPKListMain = commonlib.gettable("MyCompany.Aries.GoldRankingList.GoldRankingPKListMain");
	rank_date = rank_date or GoldRankingListMain.GetLastMonthDateStr()
	
	-- now writing to file
	
	filename = filename or format("config/Aries/Ranking/ranking_region%d.xml", MyCompany.Aries.ExternalUserModule:GetRegionID())
	ParaIO.CreateDirectory(filename);

	local file = ParaIO.open(filename, "w");
	if(file:IsValid()) then
		echo("======= dump_champions_rank_to_file: "..filename);
		file:WriteString(format([[<!-- auto generated by
		NPL.load("(gl)script/apps/Aries/NPCs/Combat/NPC_PvpPlayerStatue.lua");
		local PvpPlayerStatue = commonlib.gettable("MyCompany.Aries.Quest.NPCs.PvpPlayerStatue");
		PvpPlayerStatue.DumpAccordingToCurrentGlodRankingList('%s');
		--PvpPlayerStatue.dump_champions_rank_to_file('%s') 
-->
]], rank_date, rank_date));

		file:WriteString(format("<ranking date='%s'>\n", rank_date));
		file:WriteString(format("<players standpoint='%s'>\n", commonlib.serialize_compact(champions_standpoint_map)));
		local _, player
		for _, player in ipairs(champions_players) do
			file:WriteString(format("	<player nid='%s' name='%s'>\n		%s\n	</player>\n", player.nid,  commonlib.Encoding.EncodeStr(player.name), 
				commonlib.Encoding.EncodeStr(commonlib.serialize_compact(player)) ));
		end
		file:WriteString("</players>\n");
		file:WriteString("<families>\n");
		file:WriteString("	<pvp>\n");
		local _, family
		for _, family in ipairs(champions_families) do
			file:WriteString(format("	<family id='%s' name='%s'>\n		%s\n	</family>\n", family.family_id,  commonlib.Encoding.EncodeStr(family.familyname), 
				commonlib.Encoding.EncodeStr(commonlib.serialize_compact(family)) ));
		end
		file:WriteString("	</pvp>\n");
		file:WriteString("	<pve>\n");
		file:WriteString("	</pve>\n");
		file:WriteString("</families>\n");
		file:WriteString("</ranking>\n");
		file:close();
	end	
end

-- only used to dump ccs params to log.
function PvpPlayerStatue.DumpChampionsCCSParams(rank_date)
	local id, info
	local nCount = #champions_players;
	local i = 0;
	for id, info in ipairs(champions_players) do
		pe_player.GetCCSParams(info.nid, "self", function(params)
			champions_players[id].ccs_params = params;
			-- commonlib.echo({info.nid, ccs_params=params});
			i = i+1;
			if(nCount == i) then
				PvpPlayerStatue.dump_champions_rank_to_file(rank_date);
			end
		end)
	end
end

-- this function will automatically local file
-- the log file contains table that should be copied.
-- @param rankdate: such as "201106", which means 2011.6. if nil, it is previous month.
-- @param bRefreshCCS: default to true. 
function PvpPlayerStatue.DumpAccordingToCurrentGlodRankingList(rank_date, bRefreshCCS, force_nids)
	NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingListMain.lua");
	NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingPKListMain_history.lua");
	local GoldRankingListMain = commonlib.gettable("MyCompany.Aries.GoldRankingList.GoldRankingListMain");
	local GoldRankingPKListMain = commonlib.gettable("MyCompany.Aries.GoldRankingList.GoldRankingPKListMain");

	local nAllCount = #champions_players;
	local nCount = 0;
	local is_family_rank_finished;
	force_nids = force_nids or {};

	local function try_dump_players()
		--if(nCount == nAllCount and is_family_rank_finished) then
		-- subtract 2 from "nAllCount",because "1v1" and "2v2" don't need show;
		if(nCount == (nAllCount -2)  and is_family_rank_finished) then
			PvpPlayerStatue.dump_champions_rank_to_file(rank_date);
		end
	end

	local function FetchUserInfo(id, nid, name, title)
		champions_players[id].nid = nid;
		champions_players[id].name = name;
		champions_players[id].title = title or champions_players[id].title;

		if(bRefreshCCS ~= false) then
			echo({"fetching-begin", nid, })
			pe_player.GetCCSParams(nid, nil, function(params)
				echo({"fetching-done", nid, })
				champions_players[id] = champions_players[id] or commonlib.deepcopy(champions_players[1]);
				champions_players[id].ccs_params = params;

				--local school = OPC.GetSchool(nid);
				--if(school and school~="unknown") then
					--champions_players[id].school = school_attr_map[school].name;
					--champions_players[id].text_color = school_attr_map[school].text_color;
				--end

				nCount = nCount + 1;
				try_dump_players();
			end)
		else
			nCount = nCount + 1;
			try_dump_players();
		end
	end
	
	local function UpdateUser(rank_id, id, data_index, nid)
		data_index = data_index or 1;
		echo({"begin ranking_id", rank_id})

		--if(nid and rank_id:match("^pk_")) then
			--
			--Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nid, "pe:name"..tostring(nid), function(msg)
				--if(msg and msg.users and msg.users[1]) then
					--local user = msg.users[1];
					--local nickname = user.nickname;
					--FetchUserInfo(id, nid, nickname);
				--end
			--end);
		if(rank_id:match("^pk_")) then
			local year, mm = string.match(rank_date,"(%d%d%d%d)(%d%d)");
			local dd = 1;
			year = tonumber(year);
			mm = tonumber(mm) + 1;
			local date = string.format("%04d%02d%02d",year,mm,dd);
			-- date is the last day of the "rank_id".for example,if rankdate is  "201106",then date is "20110630";
			date = commonlib.timehelp.get_next_date_str(date, -1);
			GoldRankingListMain.GetRankingData(rank_id,date,function(msg)
				if(msg and msg[1]) then
					local usernid =  msg[1]["nid"];

					Map3DSystem.App.profiles.ProfileManager.GetUserInfo(usernid, "pe:name"..tostring(usernid), function(msg)
						if(msg and msg.users and msg.users[1]) then
							local user = msg.users[1];
							local nickname = user.nickname;
							FetchUserInfo(id, usernid, nickname);
						end
					end);
				end
			end,"access plus 1 year");

			--Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nid, "pe:name"..tostring(nid), function(msg)
				--if(msg and msg.users and msg.users[1]) then
					--local user = msg.users[1];
					--local nickname = user.nickname;
					--FetchUserInfo(id, nid, nickname);
				--end
			--end);
		else
			GoldRankingPKListMain.GetRankingData(rank_id, rank_date, function(data)
				echo({"end ranking_id", rank_id})
				if(data and data[data_index]) then
					echo({"has data", rank_id})
					FetchUserInfo(id, data[data_index].nid, data[data_index].name)
				else
					echo({"no data", rank_id})
				end
			end)
		end
	end

	UpdateUser("pk_1v1_storm", 1, nil, force_nids[1]);
	UpdateUser("pk_1v1_ice", 2, nil, force_nids[2]);
	UpdateUser("pk_1v1_fire", 3, nil, force_nids[3]);
	UpdateUser("pk_1v1_life", 4, nil, force_nids[4]);
	UpdateUser("pk_1v1_death", 5, nil, force_nids[5]);
	-- "1v1" and "2v2" don't need show now;
	--UpdateUser("pk_1v1_all", 6, nil, force_nids[6]);
	--UpdateUser("pk_2v2_all", 7, nil, force_nids[7]);
	
	GoldRankingPKListMain.GetFamilyRankingData("family_pk", rank_date, function(data)
		if(data) then
			local i
			for i=1, 5 do
				champions_families[i] = champions_families[i] or commonlib.deepcopy(champions_families[1]);
				champions_families[i].familyname = data[i].familyname;
				FetchUserInfo(7+i, data[i].nid1, data[i].name1, data[i].familyname.."家族英雄")
			end
			is_family_rank_finished = true;
			try_dump_players();
			echo("==============champions_families===============");
			echo(champions_families);
		end
	end)

	UpdateUser("storm_All_Boss", 13, 1);
	UpdateUser("life_All_Boss", 14, 1);
	UpdateUser("fire_All_Boss", 15, 1);
	UpdateUser("ice_All_Boss", 16, 1);
	UpdateUser("death_All_Boss", 17, 1);
end


-- show ranking list
function PvpPlayerStatue.GoldRankingPKList_HistoryShow(npc_id, instance)
	NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingPKListMain_history.lua");
	local rank_name;
	if(instance) then
		instance = champions_standpoint_map[instance] or instance;
		if(npc_id == 30426) then
			-- family flags
			rank_name = "family_pk";
		else
			-- players
			if(instance>=13 and instance<=17) then
				if(instance == 13) then
					rank_name = "storm_All_Boss";
				elseif(instance == 14) then
					rank_name = "life_All_Boss";
				elseif(instance == 15) then
					rank_name = "fire_All_Boss";
				elseif(instance == 16) then
					rank_name = "ice_All_Boss";
				elseif(instance == 17) then
					rank_name = "death_All_Boss";
				else
					rank_name = "All_Boss";
				end
			elseif(instance>=8 and instance<=12) then
				rank_name = "family_pk";
			elseif(instance== 7) then
				rank_name = "pk_2v2_all";
			elseif(instance== 6) then
				rank_name = "pk_1v1_all";
			elseif(instance== 5) then
				rank_name = "pk_1v1_death";
			elseif(instance== 4) then
				rank_name = "pk_1v1_life";
			elseif(instance== 3) then
				rank_name = "pk_1v1_fire";
			elseif(instance== 2) then
				rank_name = "pk_1v1_ice";
			elseif(instance== 1) then
				rank_name = "pk_1v1_storm";
			end
		end
	end
	if(rank_name and rank_name:match("^pk_")) then
		NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingListMain.lua");
		MyCompany.Aries.GoldRankingList.GoldRankingListMain.ShowPage(rank_name, nil, "pk");
	else
		MyCompany.Aries.GoldRankingList.GoldRankingPKListMain.ShowMainWnd(2, rank_name);
	end
end

-- this function is called whenever the family flag NPC is initially created in the scene. 
function PvpPlayerStatue.familyflag_main(npc_char_name, npc_id, params)
	if(ExternalUserModule:GetConfig().disable_family_flag) then
		local npcChar, npcModel = NPC.GetNpcCharModelFromIDAndInstance(npc_id, params.instance);
		if(npcChar and npcChar:IsValid() and npcModel and npcModel:IsValid()) then
			npcModel:SetVisible(false);
			npcChar:SetVisible(false);
		end
		return
	end	


	PvpPlayerStatue.LoadRanking();

	local npcChar, npcModel = NPC.GetNpcCharModelFromIDAndInstance(npc_id, params.instance);
	if(npcChar and npcChar:IsValid() and npcModel and npcModel:IsValid()) then
		local champions_families = champions_families_regions[MyCompany.Aries.ExternalUserModule:GetRegionID()] or champions_families;
		local family_info = champions_families[params.instance] or champions_families[1];
		if(family_info) then
			local display_name = format("%s", family_info.familyname);
			npcChar:SetDynamicField("DisplayName", display_name);
			
			npcChar:SetDynamicField("HeadOnDisplayColor", family_info.text_color or headon_text_color);
			System.ShowHeadOnDisplay(true, npcChar, display_name, family_info.text_color or headon_text_color,{y = 1.6});
			-- make the champion of all slightly larger 1.2 times
			npcChar:SetScale(1);

			-- offset y, so that name char is on top of the platform. 
			npcChar:SetPosition(params.position[1], params.position[2]+(family_info.char_offset or 0), params.position[3]);

			-- reset base model
			npcModel = commonlib.ResetModelAsset(npcModel, family_info.model_file)

			-- rescale it
			npcModel:SetScale(family_info.model_scale or 1);
		else
			npcModel:SetVisible(false);
			npcChar:SetVisible(false);
		end
	end
end

-- pk_2v2_all, pk_1v1_all is now hidden
local invisible_map = {[6]=true,[7]=true};

-- this function is called whenever the player statue NPC is initially created in the scene. 
function PvpPlayerStatue.main(npc_char_name, npc_id, params)
	if(ExternalUserModule:GetConfig().disable_pvp_statues) then
		local npcChar, npcModel = NPC.GetNpcCharModelFromIDAndInstance(npc_id, params.instance);
		if(npcChar and npcChar:IsValid()) then
			npcChar:SetVisible(false);
			npcModel:SetVisible(false);
		end
		return;
	end	

	PvpPlayerStatue.LoadRanking();

	local npcChar, npcModel = NPC.GetNpcCharModelFromIDAndInstance(npc_id, params.instance);
	
	if(npcChar and npcChar:IsValid()) then
		if(invisible_map[params.instance]) then
			npcChar:SetVisible(false);
			npcModel:SetVisible(false);
			return;
		end

		local champions_players = champions_players_regions[MyCompany.Aries.ExternalUserModule:GetRegionID()] or champions_players;
		local player_info = champions_players[champions_standpoint_map[params.instance] or params.instance] or champions_players[1];
		if(player_info) then
			local effect, effect_tech_id = PvpPlayerStatue.CreateGetSculptureEffect();
			npcChar:SetField("render_tech",effect_tech_id);
			-- Biped rendering will now be sorted with "RenderImportance". It is good practice to set all custom effect to the same non-zero RenderImportance value, so that there is less cost when switching effect file. 
			npcChar:SetField("RenderImportance", 3);
			-- freeze the animation
			npcChar:SetField("IsAnimPaused", true);

			local display_name = format("%s\n%s", player_info.title or (player_info.school or "").."冠军", player_info.name or "");
			npcChar:SetDynamicField("DisplayName", display_name);
			
			npcChar:SetDynamicField("HeadOnDisplayColor", player_info.text_color or headon_text_color);
			System.ShowHeadOnDisplay(true, npcChar, display_name, player_info.text_color or headon_text_color,{y = 1.6});

			if(player_info.ccs) then
				CCS.ApplyCCSInfoString(npcChar, player_info.ccs);
			elseif(player_info.ccs_params) then
				-- player_info.ccs_params.assetfile = "character/v3/Elf/Female/ElfFemale_LOD15.x";
				pe_player.ApplyCCSParamsToChar(npcChar, player_info.ccs_params);
			end
			
			-- make the champion of all slightly larger 1.2 times
			npcChar:SetScale(4);

			-- offset y, so that player is on top of the platform. 
			npcChar:SetPosition(params.position[1], params.position[2]+1.05, params.position[3]);
			
			if(player_info.anim_file and player_info.anim_file~="") then
				Map3DSystem.Animation.PlayAnimationFile(player_info.anim_file, npcChar);
			end
			-- npcChar:ToCharacter():PlayAnimation(0);
			-- LOG.std(nil, "debug", "PvpPlayerStatue", "shader effect %d is applied to %s", effect_tech_id, npc_char_name)
		else
			npcChar:SetVisible(false);
			npcModel:SetVisible(false);
		end
	end
end

-----------------------------------------------
-- for dynamic flags
-----------------------------------------------

local last_family_rank = {};

function PvpPlayerStatue.OnClickFamilyPvpHistory()
	NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingListMain.teen.lua");
	MyCompany.Aries.GoldRankingList.GoldRankingListMain.ShowPage("family_pvp", true);
end

function PvpPlayerStatue.OnClickFamilyPveHistory()
	NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingListMain.teen.lua");
	MyCompany.Aries.GoldRankingList.GoldRankingListMain.ShowPage("family_pve", true);
end

-- load dynamic ranking 
-- @param rank_name: "family_pve" or "family_pvp"
function PvpPlayerStatue.OnCheckLoadDynamicFamilyRank(rank_name)
	if(not last_family_rank[rank_name]) then
		last_family_rank[rank_name] = {};

		-- Load from last season's rank from server. 
		local item = RankingServer.GetRankByName(rank_name, nil, MyCompany.Aries.ExternalUserModule:GetRegionID());
		if(not item) then
			return
		end
		local date = commonlib.timehelp.get_next_date_str(item.last_rank_date, -1);
		local region = ExternalUserModule:GetRegionID();

		RankingServer.GetRanking(rank_name, date, item.school, region, function(msg, rank)
			if(type(msg) == "table") then
				last_family_rank[rank_name] = {};
				local i;
				for i=1,3 do
					if(msg[i]) then
						last_family_rank[rank_name][i] = msg[i].tag or ""
					else
						last_family_rank[rank_name][i] = ""
					end
				end
				LOG.std(nil, "debug", "OnUpdateFamilyFlags "..rank_name, last_family_rank[rank_name]);
				PvpPlayerStatue.OnUpdateFamilyFlags(rank_name);
			end
		end, "access plus 1 year");
	end
end

function PvpPlayerStatue.OnFrameMoveFamilyFlagsPVE()
	PvpPlayerStatue.OnCheckLoadDynamicFamilyRank("family_pve");
end

function PvpPlayerStatue.OnFrameMoveFamilyFlagsPVP()
	PvpPlayerStatue.OnCheckLoadDynamicFamilyRank("family_pvp");
end

local family_flag_npc_id = {
	["family_pve"] = {},
	["family_pvp"] = {},
}
function PvpPlayerStatue.Dynamic_family_pve_flag_main(npc_char_name, npc_id, params)
	PvpPlayerStatue.OnUpdateFamilyFlags("family_pve", npc_id, params);
end

function PvpPlayerStatue.Dynamic_family_pvp_flag_main(npc_char_name, npc_id, params)
	PvpPlayerStatue.OnUpdateFamilyFlags("family_pvp", npc_id, params);
end

-- update flag name. 
function PvpPlayerStatue.OnUpdateFamilyFlags(rank_name, npc_id, params)
	local npc_ids = family_flag_npc_id[rank_name];
	if(npc_id and not npc_ids[npc_id]) then
		local my_rank_index;
		local npc_id_, npc_data, rank_index;
		for npc_id_, npc_data in pairs(npc_ids) do
			rank_index = npc_data.rank_index;
			if(npc_id < npc_id_) then
				npc_ids[npc_id_].rank_index = rank_index + 1;
				if(not my_rank_index or my_rank_index > rank_index) then
					my_rank_index = rank_index;
				end
			else
				if(not my_rank_index or my_rank_index <= rank_index) then
					my_rank_index = rank_index + 1;
				end
			end
		end
		npc_ids[npc_id] = {params=params, rank_index = my_rank_index or 1};
	end

	if(not last_family_rank[rank_name]) then
		return;
	end

	local npc_id_, npc_data, rank_index;
	for npc_id_, npc_data in pairs(npc_ids) do
		rank_index = npc_data.rank_index;
		if(not npc_id or npc_id == npc_id_) then
			local npcChar, npcModel = NPC.GetNpcCharModelFromIDAndInstance(npc_id_);
			if(npcChar and npcChar:IsValid() and npcModel and npcModel:IsValid()) then
				local display_name = last_family_rank[rank_name][rank_index]
				if(display_name) then
					npcChar:SetDynamicField("DisplayName", display_name);
					local params = npc_data.params;
					local HeadOnDisplayColor
					if(params) then
						if(params.name2 and params.name2~="") then
							display_name = format("{%s}+{%s}",display_name, params.name2)
						end
						HeadOnDisplayColor = params.HeadOnDisplayColor
					end
					System.ShowHeadOnDisplay(true, npcChar, display_name, HeadOnDisplayColor or NPC.HeadOnDisplayColor, {y = 8});

				else
					npcModel:SetVisible(false);
					npcChar:SetVisible(false);
				end
				npcChar:SetField("On_FrameMove", "");
			end
		end
	end
end
