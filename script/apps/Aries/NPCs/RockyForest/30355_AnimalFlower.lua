--[[
Title: AnimalFlower
Author(s): Leio
Date: 2010/02/07

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/FollowPets/30355_AnimalFlower.lua");

	local s = "<div style='margin-left:15px;margin-top:15px;text-align:center'>不错不错，你的抱抱龙变成我的样子很酷吧，我左手有一份礼物，右手有一份礼物，你要左手的还是右手的？</div>";
	_guihelper.Custom_MessageBox(s,function(result)
		if(result == _guihelper.DialogResult.Yes)then
			MyCompany.Aries.Quest.NPCs.AnimalFlower.GetGift("left")
		else
			MyCompany.Aries.Quest.NPCs.AnimalFlower.GetGift("right")
		end
	end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/lefthand_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/righthand_32bits.png; 0 0 153 49"});
	
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- create class
local libName = "AnimalFlower";
local AnimalFlower = {
	curStyle = nil,--这次花里面产生的生肖
	gifts = {
		{label = "1个迎春水饺", gsid = 16028, exID = nil, num = 1, },
		{label = "1个五香饭团", gsid = 16029, exID = nil, num = 1, },
		{label = "1个蔬菜三明治", gsid = 16030, exID = nil, num = 1, },
		{label = "1个甜心蛋糕", gsid = 16031, exID = nil, num = 1, },
		{label = "2个迎春水饺", gsid = 16028, exID = nil, num = 2, },
		{label = "2个五香饭团", gsid = 16029, exID = nil, num = 2, },
		{label = "2个蔬菜三明治", gsid = 16030, exID = nil, num = 2, },
		{label = "2个甜心蛋糕", gsid = 16031, exID = nil, num = 2, },
		{label = "2000奇豆", gsid = -1, exID = nil, num = 2000, },
		{label = "2个七彩伞", gsid = nil, exID = 323, num = 2, },
		{label = "1个七彩树", gsid = nil, exID = 324, num = 1, },
		{label = "500奇豆", gsid = -1, exID = nil, num = 500, },
	},
	opentime = nil,
	random_animal = nil,
	animals = {
		{ label = "百变鼠",gsid = 10117, },
		{ label = "百变牛",gsid = 10118, },
		{ label = "百变虎",gsid = 10119, },
		{ label = "百变兔",gsid = 10120, },
		{ label = "百变龙",gsid = 10121, },
		{ label = "百变蛇",gsid = 10122, },
		{ label = "百变马",gsid = 10123, },
		{ label = "百变羊",gsid = 10124, },
		{ label = "百变猴",gsid = 10125, },
		{ label = "百变鸡",gsid = 10126, },
		{ label = "百变狗",gsid = 10127, },
		{ label = "百变猪",gsid = 10128, },
	}
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.AnimalFlower", AnimalFlower);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;
local Quest = MyCompany.Aries.Quest;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- AnimalFlower.main
function AnimalFlower.main()
	local self = AnimalFlower;
end

-- AnimalFlower.On_Timer
function AnimalFlower.On_Timer()
	local self = AnimalFlower;
end

function AnimalFlower.PreDialog(npc_id, instance)
	local self = AnimalFlower;
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30355);
	
	--是否是开花期间
	if(not self.IsAbloomTime())then
		local s = "<div style='margin-left:15px;margin-top:15px;text-align:center'>我还没有到绽放的时间呢，每天的11点，15点，20点，会准时开花的，你先多准备些变身药丸，到时候再来吧！</div>";
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.OK)then
				
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return 
	else
		local item = self.GetThisStyle();
		if(not item)then return end
		local style = item.label or "";
		local s = string.format("<div style='margin-left:15px;margin-top:15px;text-align:center'>嘻嘻，我是%s，这次是我藏在生肖花里面哦，快快让你的抱抱龙变身成我的样子吧，我这里可准备了不少礼物哦！</div>",
			style);
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.Yes)then
				self.Check();
			else
			end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/getgift_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
	end
	
	return false;
end

function AnimalFlower.FlowerOpen(random_animal)
	--_guihelper.MessageBox("ZodiacAnimalFlower.FlowerOpen:"..random_animal);
	local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(30355);
	if(npcChar and npcChar:IsValid() == true) then
		System.Animation.PlayAnimationFile({60}, npcChar);
		UIAnimManager.PlayCustomAnimation(1000, function(elapsedTime)
			local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(30355);
			if(npcChar and npcChar:IsValid() == true) then
				npcChar:ToCharacter():PlayAnimation(70);
			end
		end);
	end
end

function AnimalFlower.FlowerClose()
	--_guihelper.MessageBox("ZodiacAnimalFlower.FlowerClose");
	local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(30355);
	if(npcChar and npcChar:IsValid() == true) then
		System.Animation.PlayAnimationFile({50}, npcChar);
		UIAnimManager.PlayCustomAnimation(1000, function(elapsedTime)
			local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(30355);
			if(npcChar and npcChar:IsValid() == true) then
				npcChar:ToCharacter():PlayAnimation(0);
			end
		end);
	end
end

-- 10117_ZodiacAnimal_Rat
-- 10118_ZodiacAnimal_Ox
-- 10119_ZodiacAnimal_Tiger
-- 10120_ZodiacAnimal_Rabbit
-- 10121_ZodiacAnimal_Dragon
-- 10122_ZodiacAnimal_Snake
-- 10123_ZodiacAnimal_Horse
-- 10124_ZodiacAnimal_Ram
-- 10125_ZodiacAnimal_Monkey
-- 10126_ZodiacAnimal_Rooster
-- 10127_ZodiacAnimal_Dog
-- 10128_ZodiacAnimal_Boar

local effect_name = "ZodiacAnimalFlower_inside_animal_effect";

function AnimalFlower.SetFlowerState(bBloomed)
	
	----DEBUG:
	--bBloomed = true;
	--AnimalFlower.random_animal = 2;
	
	local self = AnimalFlower;
	--_guihelper.MessageBox("ZodiacAnimalFlower.SetFlowerState:"..tostring(bBloomed));
	if(bBloomed) then
		local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(30355);
		if(npcChar and npcChar:IsValid() == true) then
			npcChar:ToCharacter():PlayAnimation(70);
			-- get asset file
			local random_animal_index = AnimalFlower.random_animal;
			local animal_gsid = nil;
			if(random_animal_index and random_animal_index >= 1 and random_animal_index <= 12) then
				animal_gsid = random_animal_index + 10116;
			end
			local asset_file = nil;
			-- find asset file from animal gsid
			if(animal_gsid) then
				local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(animal_gsid);
				if(gsItem) then
					asset_file = gsItem.assetfile;
				end
			end
			local effectGraph = ParaScene.GetMiniSceneGraph("aries_effect");
			if(effectGraph and effectGraph:IsValid() == true) then
				effectGraph:DestroyObject(effect_name);
				if(asset_file) then
					-- create effect if asset file valid
					local asset = ParaAsset.LoadParaX("", asset_file);
					local obj = ParaScene.CreateCharacter(effect_name, asset , "", true, 1.0, 0, 1.0);
					if(obj and obj:IsValid() == true) then
						local x, y, z = npcChar:GetPosition();
						obj:SetPosition(x, y + 1, z);
						obj:SetScale(1.7);
						effectGraph:AddChild(obj);
					end
				end
			end
		end
	else
		local npcChar = Quest.NPC.GetNpcCharacterFromIDAndInstance(30355);
		if(npcChar and npcChar:IsValid() == true) then
			npcChar:ToCharacter():PlayAnimation(0);
			-- destroy effect by all means
			local effectGraph = ParaScene.GetMiniSceneGraph("aries_effect");
			if(effectGraph and effectGraph:IsValid() == true) then
				effectGraph:DestroyObject(effect_name);
			end
		end
	end
	self.isOpen = bBloomed;
end

function AnimalFlower.Bloomperiod_Opentime(opentime)
	local self = AnimalFlower;
	--_guihelper.MessageBox("ZodiacAnimalFlower.Bloomperiod_Opentime:"..tostring(opentime));
	self.opentime = opentime;
end

function AnimalFlower.SetRandomAnimal(random_animal)
	local self = AnimalFlower;
	--_guihelper.MessageBox("ZodiacAnimalFlower.SetRandomAnimal:"..tostring(random_animal));
	self.random_animal = random_animal;
end

function AnimalFlower.Check()
	local self = AnimalFlower;
	--领取过
	if(self.IsGotGiftThisTime())then
		local s = "<div style='margin-left:15px;margin-top:15px;text-align:center'>这次开花的礼物你都已经领取过啦，不能太贪心哦，下次开花再来吧！</div>";
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.OK)then
				
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return
	end
	--龙不在身边
	if(not self.PetIsHere())then
		local s = "<div style='margin-left:15px;margin-top:15px;text-align:center'>你的抱抱龙都没有过来，我怎么知道它是不是变得和我一样了，先把它带过来再说吧！</div>";
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.OK)then
				
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return
	end
	--不一样的生肖
	if(not self.PetIsSameStyle())then
		local item = self.GetThisStyle();
		if(not item)then return end
		local style = item.label or "";
		local s = string.format("<div style='margin-left:15px;margin-top:15px;text-align:center'>我是%s，你的抱抱龙都没变身成我的样子，我可不能给你礼物，先找到药丸变身，让抱抱龙变成我的样子再来领取礼物吧！</div>",
			style);
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.OK)then
				
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return
	end
	local s = "<div style='margin-left:15px;margin-top:15px;text-align:center'>不错不错，你的抱抱龙变成我的样子很酷吧，我左手有一份礼物，右手有一份礼物，你要左手的还是右手的？</div>";
	_guihelper.Custom_MessageBox(s,function(result)
		if(result == _guihelper.DialogResult.Yes)then
			self.GetGift("left")
		else
			self.GetGift("right")
		end
	end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/lefthand_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/righthand_32bits.png; 0 0 153 49"});
end
--随机产出两个礼物
function AnimalFlower.ProduceGift()
	local self = AnimalFlower;
	local gifts = commonlib.deepcopy(self.gifts);
	
	function getGift(gifts)
		local len = table.getn(gifts);
		local index = math.random(len);
		local a =  gifts[index];
		return a;
	end
	
	local a = getGift(gifts);
	local b= getGift(gifts);
	return a,b;
end
function AnimalFlower.GetGift(choose)
	local self = AnimalFlower;
	local left_gift,right_gift = self.ProduceGift();
	local final_gift;
	commonlib.echo("========AnimalFlower.GetGift");
	commonlib.echo(choose);
	commonlib.echo(left_gift);
	commonlib.echo(right_gift);
	if(choose == "left")then
		final_gift = left_gift;
	else
		final_gift = right_gift;
	end
	if(not left_gift or not right_gift)then return end
	--礼物放入背包
	self.DoPurchaseItem(final_gift,function(msg)
		if(msg and msg.issuccess)then
			local s = string.format("<div style='margin-left:15px;margin-top:15px;text-align:center'>嘻嘻，左手里面的是%s， 右手的礼物是%s哦，你选到自己喜欢的了吗？%s送你啦，快快收好哦！</div>",
			left_gift.label,right_gift.label,final_gift.label);
			_guihelper.Custom_MessageBox(s,function(result)
				if(result == _guihelper.DialogResult.OK)then
					--礼物放入背包
					 --self.DoPurchaseItem(final_gift);
				end
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		end
	end);
end
--是否是盛开时间
function AnimalFlower.IsAbloomTime()
	local self = AnimalFlower;
	--if(self.opentime)then
		--local __,__,hour,min = string.find(self.opentime,"(.+):(.+)");
		--hour = tonumber(hour);
		--min = tonumber(min);
		--if(hour and min)then
			--local now_seconds = Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(hour,min,0);
			--
			--local sec_11 = Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(11,0,0);
			--local sec_12 = Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(12,0,0);
			--local sec_15 = Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(15,0,0);
			--local sec_16 = Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(16,0,0);
			--local sec_20 = Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(20,0,0);
			--local sec_21 = Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(21,0,0);
			--
			--if( (now_seconds >= sec_11 and now_seconds <= sec_12) or (now_seconds >= sec_15 and now_seconds <= sec_16) or (now_seconds >= sec_20 and now_seconds <= sec_21))then
				--return true;
			--end
		--end
	--end
	return self.isOpen;
end

--现在是几号
function AnimalFlower.GetDay()
	local self = AnimalFlower;
	local today =  MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	return today;
end
--现在是几点
function AnimalFlower.GetHour()
	local self = AnimalFlower;
	local self = AnimalFlower;
	if(self.opentime)then
		local __,__,hour,min = string.find(self.opentime,"(.+):(.+)");
		hour = tonumber(hour);
		min = tonumber(min);
		if(hour and min)then
			local now_seconds = Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(hour,min,0);
			
			local sec_11 = Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(11,0,0);
			local sec_12 = Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(12,0,0);
			local sec_15 = Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(15,0,0);
			local sec_16 = Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(16,0,0);
			local sec_20 = Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(20,0,0);
			local sec_21 = Map3DSystem.App.MiniGames.AntiIndulgence.GetSecondes(21,0,0);
			
			if( now_seconds >= sec_11 and now_seconds <= sec_12 )then
				return "11";
			end
			if( now_seconds >= sec_15 and now_seconds <= sec_16 )then
				return "15";
			end
			if( now_seconds >= sec_20 and now_seconds <= sec_21 )then
				return "20";
			end
		end
	end
	return "";
end
--花里面是什么生肖
function AnimalFlower.GetThisStyle()
	local self = AnimalFlower;
	if(self.animals and self.random_animal)then
		local item = self.animals[self.random_animal];
		return item;
	end
end
--本次开花时间 是否领取过礼物
function AnimalFlower.IsGotGiftThisTime()
	local self = AnimalFlower;
	local today = self.GetDay();
	local hour = self.GetHour();
	if(not self.IsAbloomTime())then return end
	local nid = Map3DSystem.User.nid;
	local key = string.format("%d_AnimalFlower.GetGift-%s-%s",nid,today,hour);
	commonlib.echo("===========get key in AnimalFlower.IsGotGiftThisTime");
	commonlib.echo(key);
	local r = MyCompany.Aries.Player.LoadLocalData(key, "");
	if(r == "true")then
		return true;
	end
end
--记录这次领取过礼物
function AnimalFlower.TagGotGiftThisTime()
	local self = AnimalFlower;
	local today = self.GetDay();
	local hour = self.GetHour();
	if(not self.IsAbloomTime())then return end
	local nid = Map3DSystem.User.nid;
	local key = string.format("%d_AnimalFlower.GetGift-%s-%s",nid,today,hour);
	commonlib.echo("===========get key in AnimalFlower.TagGotGiftThisTime");
	commonlib.echo(key);
	MyCompany.Aries.Player.SaveLocalData(key, "true");
end
--抱抱龙是否在身边
function AnimalFlower.PetIsHere()
	local self = AnimalFlower;
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	local state = MyCompany.Aries.Pet.GetState();
	if(state ~= "home")then
		return true;
	end
end
--抱抱龙是否 变成一样的生肖
function AnimalFlower.PetIsSameStyle()
	local self = AnimalFlower;
	local item = self.GetThisStyle();
	if(item)then
		local my_gsid = MyCompany.Aries.Player.GetTransformFollowPetGSID();
		commonlib.echo("====item.gsid");
		commonlib.echo(item.gsid);
		commonlib.echo(my_gsid);
		if(item.gsid == my_gsid)then
			return true;
		end
	end
end
function AnimalFlower.DoPurchaseItem(final_gift,callbackFunc)
	local self = AnimalFlower;
	if(not final_gift or not callbackFunc)then return end
	local gsid = final_gift.gsid;
	local num = final_gift.num;
	local exID = final_gift.exID;
	if(exID)then
		commonlib.echo("=========start exchange in AnimalFlower");
		commonlib.echo(exID);
		ItemManager.ExtendedCost(exID, nil, nil, function(msg)end, function(msg) 
			commonlib.echo("=========after exchange in AnimalFlower");
			commonlib.echo(msg);
			if(msg and msg.issuccess)then
				self.TagGotGiftThisTime();
				callbackFunc(msg);
			end
		end);
	elseif(gsid and num)then
		if(gsid == -1)then
			commonlib.echo("=========start addmoney in AnimalFlower");
			MyCompany.Aries.Player.AddMoney(num,function(msg)
			commonlib.echo("=========after addmoney in AnimalFlower");
			commonlib.echo(msg);
				if(msg and msg.issuccess)then
					self.TagGotGiftThisTime();
					callbackFunc(msg);
				end
			end);
		else
			commonlib.echo("=========start purchase in AnimalFlower");
			commonlib.echo(gsid);
			ItemManager.PurchaseItem(gsid, num, function(msg) end, function(msg)
				commonlib.echo("=========after purchase in AnimalFlower");
				commonlib.echo(msg);
				if(msg and msg.issuccess)then
					self.TagGotGiftThisTime();
					callbackFunc(msg);
				end
			end);
		end
	end
end
