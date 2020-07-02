--[[
Title: OddEgg
Author(s): Leio
Date: 2010/03/16
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Playground/30192_OddEgg.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/TriumphSquare/30261_RiddleLampQuestionsLib.lua");
NPL.load("(gl)script/ide/timer.lua");

-- create class
local libName = "OddEgg";
local OddEgg = {
	timer = nil,
};

local eggFormServer = {};
local positions = {
	--第1组 龙龙乐园
	{ 19954.6640625, 1.2343180179596, 19916.255859375 },
	{ 19969.783203125, 1.139909029007, 19940.59765625 },
	{ 19984.375000, 0.324866, 19922.876953, },
	{ 20006.607421875, 0.37978398799896, 19908.2421875 },
	{ 19985.84765625, 0.47498899698257, 19894.328125 },
	{ 19987.529297, 0.523103, 19879.992188, },
	{ 19983.0859375, 0.71508300304413, 19864.701171875 },
	{ 19973.7109375, 1.1458439826965, 19873.533203125 },
	{ 19949.882813, 0.640579, 19869.080078, },
	{ 19936.912109375, 0.85957002639771, 19889.240234375 },
	--第2组 凯旋广场
	{ 20149.40625, 0.44031000137329, 19819.22265625 },
	{ 20175.369140625, 0.15725700557232, 19808.775390625 },
	{ 20184.064453125, 0.14374600350857, 19823.263671875 },
	{ 20199.97265625, 0.21516899764538, 19811.25 },
	{ 20205.693359375, 0.23094700276852, 19836.9921875 },
	{ 20211.35546875, 0.5884929895401, 19873.109375 },
	{ 20182.05078125, 0.17344400286675, 19878.8671875 },
	{ 20163.89,0.38,19863.04 },
	{ 20167.589844, 0.276130, 19826.419922, },
	{ 20155.837890625, 0.54889398813248, 19857.25390625 },
	--第3组  游乐场
	{ 20356.406250, 0.581302, 19862.787109, },
	{ 20375.005859, 0.581599, 19826.757813, },
	{ 20402.861328, 0.581302, 19870.054688, },
	{ 20432.136719, 0.582798, 19836.925781, },
	{ 20427.320313, 0.581301, 19920.681641, },
	{ 20416.136719, 0.581319, 19946.123047, },
	{ 20394.498047, 0.581305, 19950.248047, },
	{ 20382.683594, 0.581301, 19921.353516, },
	{ 20369.156250, 0.581301, 19913.945313, },
	{ 20405.041016, 0.581648, 19834.242188, },
};
local conditions = {
	["intelligent"] = { 
		GetTitle = "我是聪明蛋，要拿我的礼物很容易", 
		GetLabel_Failed_GetByOther = "太遗憾了，你慢了一点点，别人抢先拿走了礼物，你再去别的地方找找怪怪蛋吧！", 
		GetLabel_Failed = "我是智慧蛋，你答错了，礼物不给你！", 
		btn = "ok",
		label = "聪明蛋",
		cost_gsid = nil,
	},
	["miser"] = { 
		GetTitle = "我是守财蛋，我最喜欢的就是奇豆了，我的梦想是存好多好多奇豆，要拿我吐出肚子里的礼物可是要给点好处的，不多，100奇豆就行，怎么样，给不给？  ", 
		GetLabel_Failed_GetByOther = "你给奇豆给的太慢了，我可不等你，别人都把礼物拿走了，你去别的地方找找怪怪蛋吧！ ", 
		GetLabel_Failed = "你100奇豆都没有呀，那你可别想从我这里拿礼物，这里赚奇豆这么容易，你先去赚点奇豆再说吧！", 
		btn = "giveyou",
		label = "守财蛋",
		cost_gsid = -1,
	},
	["jiaojiao"] = { 
		GetTitle = "我是娇娇蛋，我最喜欢漂亮的七色花了，给我一朵七色花，我就把肚子里的礼物给你！", 
		GetLabel_Failed_GetByOther = "唉，你的动作太慢了，我都收了别人的七色花，礼物都已经送他了，你去别的地方找找怪怪蛋吧！", 
		GetLabel_Failed = "你没有七色花哦，龙源密境那边的七色丛林里有很多呢，有空多去摘一点吧！", 
		btn = "giveyou",
		label = "娇娇蛋",
		cost_gsid = 17005,
	},
	["stone"] = { 
		GetTitle = "我是石头蛋，脸皮硬得都有点痒痒了，你把古奇的凿子拿在手上给我挠挠痒，我就把礼物给你！", 
		GetLabel_Failed_GetByOther = "唉，已经有人帮我挠过了，礼物当然也已经送完了，你去别的地方找找怪怪蛋吧！", 
		GetLabel_Failed = "你没有把古奇的凿子拿在手里哦，要是还没有凿子的话，去雪山顶上找古奇吧，他会送你一把的！", 
		btn = "sure",
		label = "石头蛋",
		cost_gsid = nil,
	},
	["hunger"] = { 
		GetTitle = "我是贪吃蛋，最喜欢吃的就是浓香梅花蛋挞了，要是你能给我一个，我就把肚子里的礼物给你！", 
		GetLabel_Failed_GetByOther = "唉，你的动作太慢了， 别人给我的浓香梅花蛋挞我都吃了一半了，礼物都当然已经送他了，你去别的地方找找怪怪蛋吧！", 
		GetLabel_Failed = "你没有浓香梅花蛋挞哦，龙龙乐园的微波炉就能做出来，先多准备点再来找我吧！", 
		btn = "giveyou",
		label = "贪吃蛋",
		cost_gsid = 16026,
	},
}

local gifts = {
	["yoyo_deer"] = { 
		successful = "真是太棒了，居然我肚子里藏的是绝版宠物呦呦鹿哦，你要带它回家吗？ ",
		failed = "呀，你们家有呦呦鹿哦，它不愿意再去了，送你2个梅花种子吧！",
		item_gsid = 10116,
		ex_item_gsid = 30098,
		ex_item_num = 2,
	},
	["mimi_deer"] = { 
		successful = "真是太棒了，居然我肚子里藏的是绝版宠物麋麋鹿哦，你要带它回家吗？",
		failed = "你们家已经有麋麋鹿了，它不愿意再去了哦，送你1份珍珠汤圆吧，吃了能让你的抱抱龙更敏捷哦！",
		item_gsid = 10111,
		ex_item_gsid = 16025,
		ex_item_num = 1,
	},
	["tuo_niao"] = { 
		successful = "真是太不可思议了，居然我肚子里藏的是鸵鸟哦，你要带它回家吗？",
		failed = "你们家已经有鸵鸟了，它不愿意再去了哦，送你2个青蛙椅，把你的家园打扮的更漂亮哦！",
		item_gsid = 10131,--鸵鸟
		ex_item_gsid = 30174,-- 青蛙椅
		ex_item_num = 2,
	},
	["shan_dian"] = { 
		successful = "唉呀，触电了！你可别怪我，肯定是多多搞的恶作剧，把闪电放里面了，你自己多保重，我也先闪了，改天再聊！",
		failed = "",
	},
	["xue_qiu"] = { 
		successful = "哈哈哈哈，多多居然把雪球藏在我里面的，我可真的不知情哦，你现在肯定是哈奇小镇最美丽冻人的哈奇了！",
		failed = " ",
	},
	["none_effect"] = { 
		successful = "讨厌的多多，肯定是愚人节把我制造出来了，里面居然什么都没有！相信我，我之前绝对不知情，我也是个受害者….  ",
		failed = "",
	},
	["bean_5000"] = { 
		successful = "哇，这下发达了，5000奇豆哦！那么多的金灿灿的豆子呀，晃得我眼睛都花了，快收起啦吧！",
		failed = "",
		item_gsid = -1,
	},
	["yu_mao"] = { 
		successful = "这个。。。那个。。。这句话怎么说来的，对了，礼轻情谊重，快把羽毛收起来吧，别让风吹走了，那就啥都没了！",
		failed = "",
		item_gsid = 17075,
	},
	["lei_zhen_yun"] = { 
		successful = "酷~~居然是雷震云，极品家园装扮哦，快快带回去，放到家园里吧，大家一定都很羡慕呢！",
		failed = "",
		item_gsid = 30106,
	},
	["grass"] = { 
		successful = "额~~看来是我太久没动，肚子里居然长草了，你就凑合着拿回去用吧 ！",
		failed = "",
		item_gsid = 17065,
	},
}
local egg_map = {
	"intelligent","miser","jiaojiao","stone","hunger",
}
local gift_map = {
	"yoyo_deer","mimi_deer","tuo_niao","shan_dian","xue_qiu","none_effect","bean_5000","yu_mao","lei_zhen_yun","grass",
}

local egg_npcid = 303711;

commonlib.setfield("MyCompany.Aries.Quest.NPCs.OddEgg", OddEgg);
MyCompany.Aries.Quest.NPCs.OddEgg.egg_map = egg_map;
MyCompany.Aries.Quest.NPCs.OddEgg.gift_map = gift_map;

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function OddEgg.main()
	
end

function OddEgg.On_Timer()
end

function OddEgg.PreDialog(npc_id, instance)
	return false;
end
function OddEgg.GetEggIndex()
	local r = math.random(5);
	return egg_map[r];
end
function OddEgg.GetGiftIndex()
	local r = math.random(100);
	local index = 1;
	if(r <=5 )then
		index = 1;
	elseif(r > 5 and r <= 10)then
		index = 2;
	elseif(r > 10 and r <= 15)then
		index = 3;
	elseif(r > 15 and r <= 30)then
		index = 4;
	elseif(r > 30 and r <= 45)then
		index = 5;
	elseif(r > 45 and r <= 55)then
		index = 6;
	elseif(r > 55 and r <= 65)then
		index = 6;
		--index = 7;--取消5000奇豆的奖励
	elseif(r > 65 and r <= 80)then
		index = 8;
	elseif(r > 80 and r <= 90)then
		index = 9;
	elseif(r > 90 and r <= 100)then
		index = 10;
	end
	return gift_map[index];
end

function OddEgg.main_egg()
end

function OddEgg.PreDialog_egg(npc_id, instance)
	local self = OddEgg;
	self.cur_egg_type = nil;
	self.cur_gift_type = nil;
	self.cur_question = nil;
	self.cur_egg_has_picked = false;
	self.cur_instance = instance;
	
	if(not eggFormServer)then return false end
	local args = eggFormServer[instance];
	if(args)then
		eggFormServer[instance] = args; -- map egges
		self.cur_egg_type = self.egg_map[args.egg_type];
		self.cur_gift_type = self.gift_map[args.gift_type];
		if(self.cur_egg_type == "intelligent")then
			self.cur_question = MyCompany.Aries.Quest.NPCs.RiddleLampQuestionsLib.Get_Question();
		end
		--if(self.timer)then
			--self.timer:Change();
		--else
			--self.timer = commonlib.Timer:new({callbackFunc = function(timer)
				--self.CheckHasPicked();
			--end})		
		--end
		---- start the timer after 0 milliseconds, and signal every 1000 millisecond
		--self.timer:Change(0, 1000);
	end
end
function OddEgg.KillTimer()
	local self = OddEgg;
	if(self.timer)then
		self.timer:Change();
	end
end
function OddEgg.CheckHasPicked()
	local self = OddEgg;
	if(self.cur_instance)then
		local s = string.format("[Aries][ServerObject30371]CheckCanPickObj:%d",self.cur_instance);
		Map3DSystem.GSL_client:SendRealtimeMessage("s30371", {body = s});
	end
end
--return true if the user has 100 bean;
function OddEgg.HasBean_100()
	local mymoney = 0;
	local ProfileManager = System.App.profiles.ProfileManager;
	local myInfo = ProfileManager.GetUserInfoInMemory(ProfileManager.GetNID());
	if(myInfo) then
		mymoney = myInfo.emoney;
	end
	if(mymoney >= 100)then
		return true;
	end
end
--return true if the user has a color flower
function OddEgg.HasColorFlower()
	return hasGSItem(17005);
end
--return true if the user has a chisel
function OddEgg.HasChisel()
	return equipGSItem(1157);
end
--return true if the user has a  egg tart
function OddEgg.HasEggTart()
	return hasGSItem(16026);
end

--是否已经被别人拿走
function OddEgg.GetByOther()
	local self = OddEgg;
	return self.cur_egg_has_picked;
end
--回答是否正确
function OddEgg.IsCorrectAnswer()
	local self = OddEgg;
	if(self.page and self.cur_question)then
		local answer = self.page:GetValue("answer");
		if(answer and answer == self.cur_question.answer)then
			return true;
		end
	end
end
function OddEgg.GetTitleByLabel(label)
	local self = OddEgg;
	local type = self.cur_egg_type;
	local condition = conditions[type];
	if(condition)then
		return condition[label];
	end
end
function OddEgg.GetTitleByLabel_Ex(label)
	local self = OddEgg;
	local type = self.cur_gift_type;
	local gift = gifts[type];
	if(gift)then
		return gift[label];
	end
end
--返回标题
function OddEgg.GetTitle()
	local self = OddEgg;
	return self.GetTitleByLabel("GetTitle");
end
--条件满足
function OddEgg.GetLabel_Successful()
	local self = OddEgg;
	return self.GetTitleByLabel_Ex("successful");
end
--条件失败
function OddEgg.GetLabel_Failed()
	local self = OddEgg;
	return self.GetTitleByLabel("GetLabel_Failed");
end
--已经被别人领走
function OddEgg.GetLabel_Failed_GetByOther()
	local self = OddEgg;
	return self.GetTitleByLabel("GetLabel_Failed_GetByOther");
end
--如果已经有奖励的物品，奖励另外一种物品
function OddEgg.GetLabel_ExtendItem()
	local self = OddEgg;
	return self.GetTitleByLabel_Ex("failed");
end
function OddEgg.Check_Btn_State(label)
	local self = OddEgg;
	if(label)then
		local type = self.cur_egg_type;
		local condition = conditions[type];
		if(condition)then
			if(condition.btn == label)then
				return true;
			end
		end
	end
end
function OddEgg.Is_Ok_Btn()
	local self = OddEgg;
	return self.Check_Btn_State("ok");
end
function OddEgg.Is_GiveYou_Btn()
	local self = OddEgg;
	return self.Check_Btn_State("giveyou");
end
function OddEgg.Is_Sure_Btn()
	local self = OddEgg;
	return self.Check_Btn_State("sure");
end
--满足要求的物品
function OddEgg.IsCorrrectItems()
	local self = OddEgg;
	local type = self.cur_egg_type;
	--守财蛋
	if(type == "miser")then
		return self.HasBean_100();
	--娇娇蛋
	elseif(type == "jiaojiao")then
		return self.HasColorFlower();
	--石头蛋
	elseif(type == "stone")then
		return self.HasChisel();
	--贪吃蛋
	elseif(type == "hunger")then
		return self.HasEggTart();
	end
end
--满足要求的物品后 执行的效果
function OddEgg.Check_Effect()
	local self = OddEgg;
	local type = self.cur_gift_type;
	--闪电
	if(type == "shan_dian")then
		local player = ParaScene.GetPlayer();
		local animation_file = "character/Animation/v5/ElfFemale_Electricshock.x";
		if(player and player:IsValid() and animation_file)then
			Map3DSystem.Animation.PlayAnimationFile(animation_file, player);
		end
	--雪球
	elseif(type == "xue_qiu")then
		local nid = System.App.profiles.ProfileManager.GetNID();
		MyCompany.Aries.Player.HitBySnowBall(nid);
		System.Item.ItemManager.RefreshMyself();
	elseif(type == "none_effect")then
	end
end
--判断是否已经拥有 将要奖励的物品
function OddEgg.Condition_HasItem()
	local self = OddEgg;
	local gift_type = self.cur_gift_type;
	if(gift_type == "yoyo_deer" or gift_type == "mimi_deer" or gift_type == "tuo_niao")then
		local gift = gifts[gift_type];
		if(gift)then
			local gsid = gift.item_gsid;
			if(gsid)then
				return hasGSItem(gsid);
			end
		end
	end
end
--兑换礼物需要销毁的物品
function OddEgg.DeleteItem()
	local self = OddEgg;
	local egg = conditions[self.cur_egg_type];
	if(egg)then
		if(self.cur_egg_type == "miser")then
			--销毁奇豆
			ItemManager.PurchaseItem(50005,1,function(msg)end ,function(msg)
				commonlib.echo("==========after by a 50005_Joybean_Cost100 in OddEgg.Give_Ex_Items()");
				commonlib.echo(msg);
			end)
		elseif(self.cur_egg_type == "jiaojiao" or self.cur_egg_type == "hunger")then
			local cost_gsid = egg.cost_gsid;
			if(cost_gsid)then
				local has,guid,__,__  =  hasGSItem(cost_gsid);
				if(has and guid)then
						commonlib.echo("============before destroy item in OddEgg.DeleteItem()");
						commonlib.echo(guid);
					 ItemManager.DestroyItem(guid, 1, function(msg) end, function(msg)
						commonlib.echo("============after destroy item in OddEgg.DeleteItem()");
						commonlib.echo(msg);
					 end)
				 end
			end
		end
	end
	self.CallServerPickedObj();
end
function OddEgg.CallServerPickedObj()
	local self = OddEgg;
	if(self.cur_instance)then
		local s = string.format("[Aries][ServerObject30371]TryPickObj:%d",self.cur_instance);
		Map3DSystem.GSL_client:SendRealtimeMessage("s30371", {body = s});
	end
end
function OddEgg.Give_Items()
	local self = OddEgg;
	local gift = gifts[self.cur_gift_type];
	commonlib.echo("==========before by a item in OddEgg.Give_Items()");
	commonlib.echo(gift);
	if(gift)then
		if(self.cur_gift_type == "shan_dian" or self.cur_gift_type == "xue_qiu" or self.cur_gift_type == "none_effect")then
			self.Check_Effect();
		else
			local gsid = gift.item_gsid;
			if(gsid)then
				--购买
				if(gsid == -1)then
					MyCompany.Aries.Player.AddMoney(5000,function(msg) end)
				else
					ItemManager.PurchaseItem(gsid,1,function(msg)end ,function(msg)
						commonlib.echo("==========after by a item in OddEgg.Give_Ex_Items()");
						commonlib.echo(msg);
					end)
				end
			end
		end
		self.DeleteItem();
		self.InvokeHook();
	end
end
function OddEgg.Give_Ex_Items()
	local self = OddEgg;
	local gift = gifts[self.cur_gift_type];
	commonlib.echo("==========before by a item in OddEgg.Give_Ex_Items()");
	commonlib.echo(gift);
	if(gift)then
		local gsid = gift.ex_item_gsid;
		local num = gift.ex_item_num;
		if(gsid and num)then
			--购买
			ItemManager.PurchaseItem(gsid,num,function(msg)end ,function(msg)
				commonlib.echo("==========after by a item in OddEgg.Give_Ex_Items()");
				commonlib.echo(msg);
			end)
			self.DeleteItem();
			self.InvokeHook();
		end
	end
end
function OddEgg.InvokeHook()
	local self = OddEgg;
	local msg = { aries_type = "OnOddEggApplyGift", wndName = "main"};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
end
function OddEgg.IsCondition_MaybeDuplicate()
	local self = OddEgg;
	local gift_type = self.cur_gift_type;
	if(gift_type == "yoyo_deer" or gift_type == "mimi_deer" or gift_type == "tuo_niao")then
		return true;
	end
end
function OddEgg.CreateEgg(args)
	local self = OddEgg;
	if(not args)then return end
	local instance_id = args.instance_id;
	local egg_type = args.egg_type;
	local gift_type = args.gift_type;
	if(instance_id and egg_type and gift_type)then
		
		eggFormServer[instance_id] = args; -- map egges
		local pos = positions[instance_id];
		local npcChar = NPC.GetNpcCharacterFromIDAndInstance(egg_npcid, instance_id);
		if(npcChar and npcChar:IsValid() == true) then
			return;
		end
		local model_path = string.format("model/06props/v5/03quest/FunnyEgg/FunnyEgg_0%d.x",math.random(5));
		local params = { 
			name = "怪怪蛋"..instance_id,
			instance = instance_id,
			position = pos,
			facing = 0.89258199930191,
			scaling = 0.8,
			isalwaysshowheadontext =  false,
			assetfile_char = "character/common/dummy/cube_size/cube_size.x",
			assetfile_model = model_path,
			main_script = "script/apps/Aries/NPCs/Playground/30371_OddEgg.lua",
			main_function = "MyCompany.Aries.Quest.NPCs.OddEgg.main_egg();",
			predialog_function = "MyCompany.Aries.Quest.NPCs.OddEgg.PreDialog_egg",
			dialog_page = "script/apps/Aries/NPCs/Playground/30371_OddEgg_dialog.html",
			isdummy = true,
			autofacing = true,
		};
		NPC.CreateNPCCharacter(egg_npcid, params);
	
		local npcChar, _model = NPC.GetNpcCharModelFromIDAndInstance(egg_npcid,instance_id);
		if(npcChar and npcChar:IsValid())then
			npcChar:SnapToTerrainSurface(0);
			if(_model and _model:IsValid())then
				local x,y,z = npcChar:GetPosition();
				_model:SetPosition(x,y,z);
			end
		end	
	end
end
function OddEgg.DeleteEgg(instance_id)
	local self = OddEgg;
	if(not instance_id)then return end
	NPC.DeleteNPCCharacter(egg_npcid, instance_id,true);
	if(self.cur_instance == instance_id)then
		self.KillTimer();
		self.cur_egg_has_picked = true;
	end
end
function OddEgg.OnRecvEgg()
	local self = OddEgg;
	--_guihelper.MessageBox("get a egg!");
	
end
function OddEgg.CanPickObj(canPick,instance_id)
	local self = OddEgg;
	instance_id = tonumber(instance_id);
	if(instance_id and self.cur_instance and self.cur_instance == instance_id)then
		local v = false;
		if(canPick == "true" or canPick == true)then
			v = false;
		else
			v = true;
		end
		self.cur_egg_has_picked = v;
	end
end