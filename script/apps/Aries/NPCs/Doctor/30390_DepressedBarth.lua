--[[
Title: DepressedBarth
Author(s): Leio
Date: 2010/05/20

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30090_DepressedBarth.lua
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/Desktop/QuestArea.lua");
-- create class
local libName = "DepressedBarth";
local DepressedBarth = {
	
	
	items = {
		[17100] = { 20285.126953125, -0.019013551995158, 19773.599609375, scaling = 1, name = "小喇叭", assetFile = "character/v3/Pet/YYCZ/Loudhailer.x",},--小喇叭
		[17101] = { 20245.951171875, 0.48850217461586, 19740.697265625, scaling = 1, name = "鼓槌", assetFile = "character/v3/Pet/YYCZ/Drumstick.x",},--鼓槌
		[17102] = { 20009.970703125, 0.53297370672226, 19900.322265625,  scaling = 3, name = "发条", assetFile = "character/v3/Pet/YYCZ/Clockwork.x",},--发条
		[17103] = { 20067.685546875, 0.50004237890244, 19722.26171875, scaling = 1, name = "甲壳", assetFile = "character/v3/Pet/YYCZ/Carapace.x",},--甲壳
		[17104] = { 20027.8125, -3.4257564544678, 19597.658203125, scaling = 1, name = "玻璃珠", assetFile = "character/v3/Pet/YYCZ/CrystalBall.x",},--玻璃珠
		[17105] = { 20138.916015625, 0.49983891844749, 19781.841796875, scaling = 1, name = "小圆鼓", assetFile = "character/v3/Pet/YYCZ/SideDrum.x",},--小圆鼓
	},
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.DepressedBarth", DepressedBarth);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- DepressedBarth.main
function DepressedBarth.main()
	DepressedBarth.RefreshStatusState();
end

function DepressedBarth.PreDialog(npc_id, instance)
	local self = DepressedBarth;
end
function DepressedBarth.main_item()
end

function DepressedBarth.PreDialog_item(npc_id, instance)
	local self = DepressedBarth;
	local gsid = string.match(npc_id,"30390(.+)");
	gsid = tonumber(gsid);
	if(gsid)then
		self.GetItem(gsid);
		NPC.DeleteNPCCharacter(npc_id);
	end
	return false;
end
function DepressedBarth.GetItem(gsid)
	local self = DepressedBarth;
	if(not gsid or hasGSItem(gsid))then return end
	ItemManager.PurchaseItem(gsid, 1, function(msg) end, function(msg)
        if(msg) then
        end
    end);
end
function DepressedBarth.DoOpen()
	local self = DepressedBarth;
	if(not self.IsOpened())then
		ItemManager.PurchaseItem(50307, 1, function(msg) end, function(msg)
	        if(msg) then
		        log("+++++++Purchase  50307_MakeToyGuy_Acquire  return: +++++++\n")
		        commonlib.echo(msg);
		        self.RefreshStatusState()
	        end
        end,nil,"none");
	end
end
function DepressedBarth.IsOpened()
	return hasGSItem(50307);
end
function DepressedBarth.IsFinished()
	return hasGSItem(10133);
end
function DepressedBarth.HasFullItems()
	return hasGSItem(17100) and hasGSItem(17101) and hasGSItem(17102) and hasGSItem(17103) and hasGSItem(17104) and hasGSItem(17105);
end
function DepressedBarth.DoExchange()
	local self = DepressedBarth;
	if(self.IsOpened() and not self.IsFinished())then
		ItemManager.ExtendedCost(436, nil, nil, function(msg)end, function(msg) 
				log("+++++++ Extended cost 436: Get_10133_FollowPetYYCZ return: +++++++\n")
				commonlib.echo(msg);
				DepressedBarth.RefreshStatusState()
		end);
	end
end
--任务开启后 生成可以捡取的物品
function DepressedBarth.RefreshItemsState()
	local self = DepressedBarth;
	if(self.IsOpened() and not self.IsFinished())then
		self.BuildGameObject(17100);
		self.BuildGameObject(17101);
		self.BuildGameObject(17102);
		self.BuildGameObject(17103);
		self.BuildGameObject(17104);
		self.BuildGameObject(17105);
	end
end
function DepressedBarth.BuildGameObject(gsid)
	local self = DepressedBarth;
	if(not gsid)then return end
	
	local id = 30390 .. gsid;
	NPC.DeleteNPCCharacter(id);
	if(hasGSItem(gsid))then
		return
	end
	local item = self.items[gsid];
	if(item)then
		local pos = {item[1],item[2],item[3],};
		local assetFile = item.assetFile;
		local name = item.name;
		local scaling = item.scaling or 1;
		
		local params = { 
			name = name,
			position = pos,
			facing = 0,
			--scaling_char = 1.5,
			scaling = scaling,
			isalwaysshowheadontext = false,
			assetfile_char = assetFile,
			--assetfile_model = assetFile,
			cursor = "Texture/Aries/Cursor/Pick.tga",
			main_script = "script/apps/Aries/NPCs/Doctor/30390_DepressedBarth.lua",
			main_function = "MyCompany.Aries.Quest.NPCs.DepressedBarth.main_item();",
			predialog_function = "MyCompany.Aries.Quest.NPCs.DepressedBarth.PreDialog_item",
			isdummy = true,
		};
		NPC.CreateNPCCharacter(id, params);
		local npcChar, _model = NPC.GetNpcCharModelFromIDAndInstance(id);
		if(npcChar and npcChar:IsValid())then
			npcChar:SnapToTerrainSurface(0);
			if(_model and _model:IsValid())then
				local x,y,z = npcChar:GetPosition();
				_model:SetPosition(x,y,z);
			end
		end	
	end
end
function DepressedBarth.CanShow()
	local self = DepressedBarth;
	if(self.IsOpened() and not self.IsFinished()) then
		return true;
	end	
end
function DepressedBarth.ShowStatus()
	MyCompany.Aries.Desktop.QuestArea.ShowNormalQuestStatus("script/apps/Aries/NPCs/Doctor/30390_DepressedBarth_status.html");
end
function DepressedBarth.RefreshStatusState()
	local self = DepressedBarth;
	--if(self.IsOpened() and not self.IsFinished()) then
		--local QuestArea = MyCompany.Aries.Desktop.QuestArea;
		--QuestArea.AppendQuestStatus("script/apps/Aries/NPCs/Doctor/30390_DepressedBarth_status.html", 
			--"normal", "Texture/Aries/Quest/Props/barth_32bits.png;0 0 80 75", "忧郁的巴斯", nil, 40, nil);
			--
	--else
		---- hide the save gucci quest icon
		--local QuestArea = MyCompany.Aries.Desktop.QuestArea;
		--QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Doctor/30390_DepressedBarth_status.html");
	--end
	self.RefreshItemsState();
	if(self.IsFinished())then
		--NPC.DeleteNPCCharacter(30390);
	end
end
