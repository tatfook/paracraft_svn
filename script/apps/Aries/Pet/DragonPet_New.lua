--[[
Title: DragonPet_New
Author(s): Leio
Date: 2009/7/15
更新：2009/10/23 
Desc:
use the lib:
------------------------------------------------------------
local nid,petid = nil,nil;
NPL.load("(gl)script/apps/Aries/Pet/DragonPet_New.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Pet/main.lua");

local LOG = LOG;
local ProfileManager = commonlib.gettable("Map3DSystem.App.profiles.ProfileManager");

local DragonPet_New = {
	nid = nil,--坐骑主人的nid
	petid = nil,--坐骑的id
	petState = nil,--坐骑的状态
	old_bean = nil,--上一次的数据
	bean = nil,--现在的数据
	isInAISquare = false,
	
	
	--事件
	loadedFunc = nil,--加载远程数据完成事件
	speakFunc = nil,--说话的事件
	speakInManualFunc = nil,--手动说话的事件
	levelUpFunc = nil,--升级的事件
	normalFunc = nil,--健康情况正常事件
	sickFunc = nil,--生病事件
	deadFunc = nil,--死亡事件
	startSpeakAndLoadTimer = nil,--启动 自动说话 和自动加载数据的timer
	stopSpeakAndLoadTimer = nil,--关闭 自动说话 和自动加载数据的timer
}
commonlib.setfield("MyCompany.Aries.Pet.DragonPet_New",DragonPet_New);
function DragonPet_New:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self;
	o:Init();
	return o
end
function DragonPet_New:Init()
	self.name = ParaGlobal.GenerateUniqueID();
	CommonCtrl.AddControl(self.name, self);
	
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/PetState.lua");		
	self.petState = Map3DSystem.App.HomeLand.PetState:new()	
	
	self.petState:AddEventListener("TimerHandler_Short",self,MyCompany.Aries.Pet.DragonPet_New.TimerHandler_Short);
	self.petState:AddEventListener("TimerHandler_Long",self,MyCompany.Aries.Pet.DragonPet_New.TimerHandler_Long);
end
-- 5分钟更新一次 只说话，不更新成长数据
function DragonPet_New.TimerHandler_Short(self,msg)
	if(not self)then return end
	self:DoSpeak(msg,true);
end
-- 一小时更新一次，说话 和 更新成长数据
function DragonPet_New.TimerHandler_Long(self,msg)
	if(not self)then return end
	self:DoSpeak(msg,true);
	self:GetRemoteValue();
end
-----------------------------------属性
--是否是自己的龙
function DragonPet_New:IsMyPet()
	if(self.nid)then
		if(self.nid == Map3DSystem.User.nid)then
			return true;
		end
	end
end
-- 坐骑所属主人的id
function DragonPet_New:SetNID(id)
	self.nid = id;
end
function DragonPet_New:GetNID()
	return self.nid;
end
-- 坐骑的id
function DragonPet_New:SetPetID(id)
	self.petid = id;
end
function DragonPet_New:GetPetID()
	return self.petid;
end
-- 坐骑的状态
function DragonPet_New:SetPetState(state)
	self.petState = state;
end
function DragonPet_New:GetPetState()
	return self.petState;
end
-- 设置坐骑的成长数据
-- @param bean:成长数据
--[[
/// 返回值：
/// petid 
/// nickname 昵称
/// birthday 生日
/// level 级别
/// friendliness 亲密度
/// strong 体力值
/// cleanness 清洁值
/// mood 心情值
/// nextlevelfr 长级到下一级所需的亲密度
/// health 健康状态
--]]
function DragonPet_New:SetBean(bean)
	if(not bean)then return end
	bean = commonlib.deepcopy(bean);
	self.old_bean = self.bean;
	self.bean = bean;
	if(self.petState)then
		self.petState:BindBean(bean);
	end
end
-- 获取坐骑的成长数据
function DragonPet_New:GetBean()
	return self.bean;
end
-- 记录上一次的生长数据
function DragonPet_New:SetOldBean(bean)
	self.old_bean = bean;
end
-- 获取坐骑上一次的成长数据
function DragonPet_New:GetOldBean()
	return self.old_bean;
end
-- 获取当前的级别
function DragonPet_New:GetLevel()
	if(self.petState)then
		local level = self.petState:GetLevel(self:GetBean());
		if(level == "egg")then
			return 1
		elseif(level == "child")then
			return 2
		elseif(level == "adult")then
			return 3
		end
	end
end
--是否正常
function DragonPet_New:IsNormal()
	if(self.petState)then
		return self.petState:IsNormal();
	end
end
--是否生病
function DragonPet_New:IsSick()
	if(self.petState)then
		return self.petState:IsSick();
	end
end
--是否死亡
function DragonPet_New:IsDead()
	if(self.petState)then
		return self.petState:IsDead();
	end
end
function DragonPet_New:GetPetEntity()
	local nid = self:GetNID();
	--local pet = MyCompany.Aries.Pet.GetUserMountObj(nid);
	--if(pet and pet:IsValid())then
		--return pet;
	--end
	local petid = self:GetPetID();
	local identity = self:GetIdentity();
	local name;
	
	if(identity == "master")then
		-- 在公共世界可以获取到
		local pet = MyCompany.Aries.Pet.GetUserMountObj();
		if(pet and pet:IsValid())then
			return pet;
		end
		--在自己家园中可以获取到
		local ItemManager = System.Item.ItemManager;
		local item = ItemManager.GetItemByGUID(petid);
		if(item and item.guid > 0 and item.GetSceneObjectNameInHomeland) then
			name = item:GetSceneObjectNameInHomeland();
		end
		if(name)then
			local pet = ParaScene.GetCharacter(name);
			if(pet and pet:IsValid())then
				return pet;
			end
		end
	else
		local ItemManager = System.Item.ItemManager;
		local item = ItemManager.GetOPCItemByGUID(nid, petid);
		if(item and item.guid > 0 and item.GetSceneObjectNameInHomeland) then
			name = item:GetSceneObjectNameInHomeland();
		end
		if(name) then
			local pet = ParaScene.GetCharacter(name);
			if(pet and pet:IsValid())then
				return pet;
			end
		end
	end
end
-----------------------------------方法
-- 喂食
-- @param item: 喂食的物品
function DragonPet_New:DoFeed(item,callbackFunc)
	if(not item)then 
		if(callbackFunc and type(callbackFunc) == "function")then
			local msg = {};
			msg.issuccess = false;
			msg.error = 1;
			callbackFunc(msg) ;
		end
		return 
	end
	local type = "feed";
	item.type = type;
	self:DoUserItem(item,callbackFunc);
end
-- 洗澡
-- @param item: 洗澡的物品
function DragonPet_New:DoBath(item,callbackFunc)
	if(not item)then 
		if(callbackFunc and type(callbackFunc) == "function")then
			local msg = {};
			msg.issuccess = false;
			msg.error = 1;
			callbackFunc(msg) ;
		end
		return 
	end
	local type = "bath";
	item.type = type;
	self:DoUserItem(item,callbackFunc);
end
-- 使用玩具
-- @param item: 使用的玩具
function DragonPet_New:DoPlayToy(item,callbackFunc)
	if(not item)then 
		if(callbackFunc and type(callbackFunc) == "function")then
			local msg = {};
			msg.issuccess = false;
			msg.error = 1;
			callbackFunc(msg) ;
		end
		return 
	end
	local type = "playtoy";
	item.type = type;
	self:DoUserItem(item,callbackFunc);
end
-- 喂药
-- @param item: 药品
function DragonPet_New:DoMedicine(item,callbackFunc)
	if(not item)then 
		if(callbackFunc and type(callbackFunc) == "function")then
			local msg = {};
			msg.issuccess = false;
			msg.error = 1;
			callbackFunc(msg) ;
		end
		return 
	end
	local type = "medicine";
	item.type = type;
	self:DoUserItem(item,callbackFunc);
end
-- 复活
-- @param item: 药品
function DragonPet_New:DoRelive(item,callbackFunc)
	if(not item)then 
		if(callbackFunc and type(callbackFunc) == "function")then
			local msg = {};
			msg.issuccess = false;
			msg.error = 1;
			callbackFunc(msg) ;
		end
		return 
	end
	local type = "relive";
	item.type = type;
	self:DoUserItem(item,callbackFunc);
end
-- 特殊动作
-- @param item: 物品
function DragonPet_New:DoEspecial(item,callbackFunc)
	if(not item)then 
		if(callbackFunc and type(callbackFunc) == "function")then
			local msg = {};
			msg.issuccess = false;
			msg.error = 1;
			callbackFunc(msg) ;
		end
		return 
	end
	local type = "especial";
	item.type = type;
	self:DoUserItem(item,callbackFunc);
end
-- 使用不同的物品
-- @param item: 物品
function DragonPet_New:DoUserItem(item,callbackFunc)
	if(not item)then return end
	local nid = self:GetNID();
	local petid = self:GetPetID();
	local guid = item.guid;
	local bag = item.bag;
	self:DoUserItemBefore(item);
	local item_type = item.type;
	
	
	local isMyPet = self:IsMyPet();

	local ItemManager = System.Item.ItemManager;
	local stats = {};
	local item_item = ItemManager.GetItemByGUID(guid);
	if(item_item and item_item.guid > 0) then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(item_item.gsid)
		if(gsItem) then
			stats = gsItem.template.stats;
		end
	end

	--debug 是否是自己的坐骑
	LOG.std("", "debug", "pet", {"check dragon data when use item:", self.bean, isMyPet = isMyPet});
	local msg = {};
	if(item_type == "medicine")then
		--没有生病不允许吃药
		if(not self.petState:IsSick())then
			msg.issuccess = false;
			msg.error = 4001;
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc(msg);
			end
			return
		end
	elseif(item_type == "relive")then
		--没有死亡不允许复活
		if(not self.petState:IsDead())then
			msg.issuccess = false;
			msg.error = 4002;
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc(msg);
			end
			return
		end
	else
		----在非正常状态下，不能喂食，洗澡，玩玩具等
		---- 即在生病和死亡情况下
		--if(not self.petState:IsNormal())then
			--msg.issuccess = false;
			--msg.error = 4003;
			--if(callbackFunc and type(callbackFunc) == "function")then
				--callbackFunc(msg);
			--end
			--return
		--end
		if(self.petState:IsDead())then
			msg.issuccess = false;
			msg.error = 4007;
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc(msg);
			end
			return
		end
		--如果是喂食自己的龙
		if(self:IsMyPet())then
			if(stats[3] and stats[3] < 0)then
				local bean = self:GetBean()
				if(item_type == "feed" and bean and bean.strong <= 0)then
					NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
					_guihelper.Custom_MessageBox("你的抱抱龙的饥饿值为0，不需要再吃消食丸啦！",function(result)
						if(result == _guihelper.DialogResult.OK)then
							commonlib.echo("OK");
						end
					end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
					return
				end
			end
			if(stats[3] and stats[3] >= 0)then
				if(item_type == "feed" and self.petState:IsNotHunger())then
					msg.issuccess = false;
					msg.error = 4004;
					if(callbackFunc and type(callbackFunc) == "function")then
						callbackFunc(msg);
					end
					return
				end
			end
			if(stats[4] and stats[4] >= 0)then
				if(item_type == "bath" and self.petState:IsNotDirty())then
					msg.issuccess = false;
					msg.error = 4005;
					if(callbackFunc and type(callbackFunc) == "function")then
						callbackFunc(msg);
					end
					return
				end
			end
			if(stats[5] and stats[5] >= 0)then
				if(item_type == "playtoy" and ( self.petState:IsSick() or self.petState:IsHunger() or self.petState:IsDirty() ))then
					msg.issuccess = false;
					msg.error = 4006;
					if(callbackFunc and type(callbackFunc) == "function")then
						callbackFunc(msg);
					end
					return
				end
			end
		else
		--如果是喂食其他人的龙
			if(item_type == "feed" and self.petState:FeedIsGreater())then
				msg.issuccess = false;
				msg.error = 4008;
				if(callbackFunc and type(callbackFunc) == "function")then
					callbackFunc(msg);
				end
				return
			end
			if(item_type == "bath" and self.petState:BathIsGreater())then
				msg.issuccess = false;
				msg.error = 4009;
				if(callbackFunc and type(callbackFunc) == "function")then
					callbackFunc(msg);
				end
				return
			end
			if(item_type == "playtoy" and ( self.petState:PlayToyIsGreater() or self.petState:IsSick() or self.petState:IsHunger() or self.petState:IsDirty() ))then
				msg.issuccess = false;
				msg.error = 4010;
				if(callbackFunc and type(callbackFunc) == "function")then
					callbackFunc(msg);
				end
				return
			end
		end
	end
	if(guid)then
		
		
		local msg = {
			sessionkey = Map3DSystem.User.sessionkey,
			nid = nid,
			itemguid = guid,
			petid = petid,
			bag = bag,
			--------------- for local server optimization -------------
			gsid = item_item.gsid,
			add_strong = stats[3] or 0, -- strong
			add_cleanness = stats[4] or 0, -- cleanness
			add_mood = stats[5] or 0, -- mood
			add_friendliness = stats[7] or 0, -- friendliness
			heal_pet = stats[8] or 0,
			revive_pet = stats[9] or 0,
			add_kindness = stats[17] or 0, -- kindness
			add_intelligence = stats[18] or 0, -- intelligence
			add_agility = stats[19] or 0, -- agility
			add_strength = stats[20] or 0, -- strength
			add_archskillpts = stats[21] or 0, -- archskillpts
			--------------- for local server optimization -------------
		}
		LOG.std("", "debug", "pet", {"before use pet item, the nid of user", Map3DSystem.User.nid, msg} );
		paraworld.homeland.petevolved.UseItem(msg,"petevolved",function(msg)	
			local bean = msg;
			LOG.std("", "debug", "pet", {"after used pet item:", bean});
			if(bean)then
				self:SetBean(bean);
				self:DoUserItemAfter(item);
				self:Update();
				msg.issuccess = true;
				if(callbackFunc and type(callbackFunc) == "function")then
					callbackFunc(msg);
				end
			end
		end);
	
	end
end
-- 使用物品之前
-- 如果不需要喂食返回true
function DragonPet_New:DoUserItemBefore(item)
	if(not item)then return end
	local msg;
	if(self.petState)then
		local type = item.type;
		if(type == "feed")then
			if(self:IsMyPet())then
				msg = self.petState:FeedBefore();
			else
				msg = self.petState:FeedBefore_ToGuest();
			end
		elseif(type == "bath")then
			if(self:IsMyPet())then
				msg = self.petState:BathBefore();
			else
				msg = self.petState:BathBefore_ToGuest();
			end
		elseif(type == "playtoy")then
			if(self:IsMyPet())then
				msg = self.petState:PlayToyBefore();
			else
				msg = self.petState:PlayToyBefore_ToGuest();
			end
		elseif(type == "medicine")then
			msg = self.petState:MedicineBefore();
		elseif(type == "especial")then
			msg = self.petState:DoEspecial();
		end
		--喂食的时候在2D面板说话
		self:DoSpeak(msg,false,true);
	end
end
-- 使用物品之后
function DragonPet_New:DoUserItemAfter(item)
	if(not item)then return end
	local msg;
	if(self.petState)then
		local type = item.type;
		if(type == "feed")then
			msg = self.petState:FeedAfter();
		elseif(type == "bath")then
			msg = self.petState:BathAfter();
		elseif(type == "playtoy")then
			msg = self.petState:PlayToyAfter();
		elseif(type == "medicine")then
			msg = self.petState:MedicineAfter();
		elseif(type == "especial")then
			
		end
		--喂食的时候在2D面板说话
		self:DoSpeak(msg,false,true);
	end
end
function DragonPet_New:LoadMasterInfo()
	local msg = {
		nids = tostring(self.nid)
	}
	paraworld.users.getInfo(msg, "getInfo", function(msg)
		if(msg and msg.users and msg.users[1]) then
			self.master_info = msg.users[1]; --{ emoney=0, nickname="leio3", nid=19484, pmoney=0 }
		end
	end)
end
function DragonPet_New:GetMasterInfo()
	return self.master_info;
end
--@param msg: 要说的语言
--@param auto: auto = true 触发自动语言事件
--@param manual: manual = true 触发手动语言事件
function DragonPet_New:DoSpeak(msg,auto,manual)
	if(System.options.version ~= "kids")then
		return
	end
	if(not msg)then return end
	if(type(msg) == "table")then
		return
	end
	
	local name = Map3DSystem.User.nid or tostring(self:GetNID());
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
	local master_info = self:GetMasterInfo();
	if(master_info and master_info.nickname)then
		name = master_info.nickname;
	end
	msg = string.gsub(msg, "%[username%]", name);
	LOG.std("", "debug", "pet", {"DoSpeak", name, msg});
	--语言
	local message = msg;
	self:SpeakByEntity(message);	
	if(manual)then
		if(self.speakInManualFunc and type(self.speakInManualFunc) == "function")then
			local msg = {
				pet_dragon = self,
				message = message
			}
			self.speakInManualFunc(msg);
		end
		--通知语言面板改变文字
		local msg = { pet_action_type = "pet_action_feeding", wndName = "mountpet", language = message,};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
	end
	if(auto)then
		if(self.speakFunc and type(self.speakFunc) == "function")then
			local msg = {
				pet_dragon = self,
				message = message
			}
			self.speakFunc(msg);
		end
	end
end

-- 更新坐骑的显示信息
function DragonPet_New:Update()
	local bean = self:GetBean();
	if(not bean)then return end
	
		
	local preLevel = self.petState:GetLevel(self:GetOldBean());
	local level = self.petState:GetLevel(self:GetBean());
	
	local oldBean = self:GetOldBean();
	local currentBean = self:GetBean();
	
	--如果升级了
	if(not oldBean or ( oldBean and currentBean and (oldBean.level or 0) < (currentBean.level or 0)) )then
		--升级语言
		local msg = self.petState:GetLevelUpMsg(currentBean.level);
		self:DoSpeak(msg,true,true);
		
		--升级了
		if(self.levelUpFunc and type(self.levelUpFunc) == "function")then
			local msg = {
				pet_dragon = self,
			}
			self.levelUpFunc(msg);
		end
		--升级的效果
		self:LevelUpEffect(preLevel,level);
	end
	
	--魔法星升级
	if(not oldBean or ( oldBean and currentBean and (oldBean.mlel or 0)< (currentBean.mlel or 0)) )then
		
		if(self.magic_star_levelUpFunc and type(self.magic_star_levelUpFunc) == "function")then
			local msg = {
				pet_dragon = self,
			}
			self.magic_star_levelUpFunc(msg);
		end
	end
	--魔法星复活 energy 从0变为非0
	if(not oldBean or ( oldBean and currentBean and (oldBean.energy or 0)== 0 and  (currentBean.energy or 0)> 0) )then
		
		if(self.magic_star_rebornFunc and type(self.magic_star_rebornFunc) == "function")then
			local msg = {
				pet_dragon = self,
			}
			self.magic_star_rebornFunc(msg);
		end
	end

	-- combat level update
	if(self:GetNID() == ProfileManager.GetNID() and ( oldBean and currentBean and (oldBean.combatlel or 0) < (currentBean.combatlel or 0)) )then
		
		--升级的效果
		self:LevelUpEffect_combat();

		if(self.combatlelUpFunc and type(self.combatlelUpFunc) == "function")then
			local msg = {
				pet_dragon = self,
			}
			self.combatlelUpFunc(msg);
		end
	end

	--如果正常
	if(self:IsNormal()) then
		if(self.sickFunc and type(self.sickFunc) == "function")then
				local msg = {
					pet_dragon = self,
				}
				self.normalFunc(msg);
		end
	end
	--如果生病了
	if(self:IsSick()) then
		if(self.sickFunc and type(self.sickFunc) == "function")then
				local msg = {
					pet_dragon = self,
				}
				self.sickFunc(msg);
		end
	end
	--如果死亡
	if(self:IsDead()) then
		if(self.deadFunc and type(self.deadFunc) == "function")then
				local msg = {
					pet_dragon = self,
				}
				self.deadFunc(msg);
		end
	end
end
-- 获取坐骑的远程数据
function DragonPet_New:GetRemoteValue(callbackFunc, cache_policy)
	local nid = self:GetNID();
	local petID = self:GetPetID();
	if(not nid or not petID)then return end
	
	if(not cache_policy)then
		cache_policy = cache_policy or "access plus 30 seconds";
	end
	local msg = {
		nid = nid,
		id = petID,
		cache_policy = cache_policy,
	}
	LOG.std("", "debug", "pet", {"begin to load remote value by pet:", msg});
	paraworld.homeland.petevolved.Get(msg, "petevolved", function(msg)	
		-- 绑定远程数据
		local bean = msg;
		LOG.std("", "debug", "pet", {"after loaded remote value by pet:", msg});
		if(bean and not bean.errorcode)then
			self:SetBean(bean);
			self:Update();
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc(msg);
			end
			
			if(self.loadedFunc and type(self.loadedFunc) == "function")then
				local msg = {
					pet_dragon = self,
					bean = bean,
				}
				self.loadedFunc(msg);
			end

			-- call hook for OnUpdatePetGet
			local hook_msg = { aries_type = "OnUpdatePetGet", nid = nid, msg = commonlib.deepcopy(bean), wndName = "main"};
			CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
		end
	end, cache_policy);
end
--仅初始化petstate，不启动自动监听
function DragonPet_New:InitPetState()
	local identity = self:GetIdentity();
	local state = self:GetState();
	local bean = self:GetBean();
	if(self.petState)then
		self.petState:SetIdentity(identity);
		self.petState:ChangeState(state);
		self.petState:BindBean(bean);
	end
	self:LoadMasterInfo();
end
-- 启动自动监听，它会自动产生语言，自动返回坐骑的成长信息
function DragonPet_New:StartMonitor()
	if(self.petState)then
		self.petState:Start();
		if(self.startSpeakAndLoadTimer and type(self.startSpeakAndLoadTimer) == "function")then
			local msg = {
				pet_dragon = self,
			}
			self.startSpeakAndLoadTimer(msg);
		end
	end
end
-- 停止自动监听
function DragonPet_New:StopMonitor()
	if(self.petState)then
		self.petState:Stop();
		if(self.stopSpeakAndLoadTimer and type(self.stopSpeakAndLoadTimer) == "function")then
			local msg = {
				pet_dragon = self,
			}
			self.stopSpeakAndLoadTimer(msg);
		end
	end
end
--以主人的身份/游客的身份来观察坐骑
function DragonPet_New:GetIdentity()
	local nid = self:GetNID();
	if(Map3DSystem.User.nid == nid)then
		return "master";
	else
		return "guest";
	end
end
-- 改变坐骑的状态
-- @param newState:"follow" or "ride" or "home" or "fly"
function DragonPet_New:ChangeState(newState,noSpeak)
	if(self.petState)then
		local msg = self.petState:ChangeState(newState);
		if(not noSpeak)then
			self:DoSpeak(msg,true);
		end
	end
end
-- 返回当前坐骑的驾驭状态
function DragonPet_New:GetState()
	if(self.petState)then
		return self.petState:GetState();
	end
end
function DragonPet_New:CanFollow()
	--local errorCode;
	--local identity = self:GetIdentity();
	----如果是游客，无权改变坐骑的状态
	--if(identity == "guest")then
		--errorCode = 2;
		--return false,errorCode;
	--end
	--if(self.petState)then
		--local nowState = self.petState:GetState();
		--local level = self.petState:GetLevel(self:GetBean());
		--if(nowState == "follow")then
			--errorCode = 2001;
			--return false,errorCode;
		--end
		----死亡状态下不能驾驭
		--if(self.petState:IsDead())then
			--errorCode = 2002;
			--return false,errorCode
		--end
		--return true;
	--end
	return true;
end
function DragonPet_New:CanRide()
	--local errorCode;
	--local identity = self:GetIdentity();
	----如果是游客，无权改变坐骑的状态
	--if(identity == "guest")then
		--errorCode = 2;
		--return false,errorCode;
	--end
	--if(self.petState)then
		--local nowState = self.petState:GetState();
		--local level = self.petState:GetLevel(self:GetBean());	
		--if(level == "egg")then
			--errorCode = 1001;
			--return false,errorCode;
		--end
		--if(nowState == "ride")then
			--errorCode = 1002;
			--return false,errorCode;
		--end
		----TODO:主人在家的时候不能驾驭
		--NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
		--if(Map3DSystem.App.HomeLand.HomeLandGateway.IsInMyHomeland())then
			--errorCode = 1003;
			--return false,errorCode;
		--end
		--if(Map3DSystem.App.HomeLand.HomeLandGateway.IsInOtherHomeland())then
			--errorCode = 1004;
			--return false,errorCode;
		--end
		--errorCode = 1005;
		--return self.petState:IsNormal(),errorCode;
	--end
	return true;
end
function DragonPet_New:CanGoHome()
	--local errorCode;
	--local identity = self:GetIdentity();
	----如果是游客，无权改变坐骑的状态
	--if(identity == "guest")then
		--errorCode = 2;
		--return false,errorCode;
	--end
	--if(self.petState)then
		--local nowState = self.petState:GetState();
		--if(nowState == "home")then
			--errorCode = 3001;
			--return false,errorCode;
		--end
		--return true;
	--end
	return true;
end
function DragonPet_New:DoFollow()
	self:ChangeState("follow");
end
function DragonPet_New:DoRide()
	self:ChangeState("ride");
end
function DragonPet_New:DoGoHome()
	self:ChangeState("home");
end
function DragonPet_New:DoFly()
	self:ChangeState("fly");
end

function DragonPet_New:SpeakByEntity(msg)
	if(msg)then
		local pet = self:GetPetEntity();
		if(pet)then
			local lifeTime = 2;
			if(self.petState)then
				lifeTime = self.petState:GetSpeakLifeTime();
				if(lifeTime)then
					lifeTime = lifeTime/1000;
				end
				headon_speech.Speek(pet.name, "", 0)
				headon_speech.Speek(pet.name, msg, lifeTime, true)
			end
		end
	end
end
function DragonPet_New:ForceSpeakLevelUpMsg(level)
	level = level or 0;
	local msg = self.petState:GetLevelUpMsg(level);
	self:DoSpeak(msg,true,true);
end
--------------------------------------------ai
-- 是否在感应区域内
function DragonPet_New:IsInAISquare()
	return self.isInAISquare;
end
function DragonPet_New:SpeakInSquare()
	local msg = self.petState:SpeakInSquare()	
	self:DoSpeak(msg,false,false);
end
--坐骑升级的效果
function DragonPet_New:LevelUpEffect(preLevel,level)
	local _pet = self:GetPetEntity();
	if(_pet and _pet:IsValid() == true) then
		if(preLevel ~= level) then
			if(preLevel == "egg" and level == "child") then
				MyCompany.Aries.Player.PlayAnimationFromValue(nil, -2);
				System.GSL_client:AddRealtimeMessage({name="anim", value="-2"});
			elseif(preLevel == "child" and level == "adult") then
				MyCompany.Aries.Player.PlayAnimationFromValue(nil, -3);
				System.GSL_client:AddRealtimeMessage({name="anim", value="-3"});
			end
		else
			MyCompany.Aries.Player.PlayAnimationFromValue(nil, -1);
			System.GSL_client:AddRealtimeMessage({name="anim", value="-1"});
		end
		
		--local params = {
			--asset_file = "character/v5/temp/Effect/DampenMagic_Impact_Base.x",
			--binding_obj_name = _pet.name,
			--duration_time = 2600,
			--end_callback = function()
					--if(preLevel ~= level) then
						----改变坐骑的资源文件
						--Map3DSystem.Item.ItemManager.RefreshMyself();
					--end
				--end,
			--stage1_time = 2000,
			--stage1_callback = function()
				--if(_pet and _pet:IsValid() == true) then
					--local params = {
						--asset_file = "character/particles/LevelUp.x",
						--binding_obj_name = _pet.name,
						--duration_time = 800,
					--};
					--local EffectManager = MyCompany.Aries.EffectManager;
					--EffectManager.CreateEffect(params);
				--end
			--end,
		--};
		--if(preLevel ~= level) then --< actually its only egg, minor, major
			--params.asset_file = "character/v5/temp/Effect/DampenMagic_Impact_Base.x";
			--params.duration_time = 2500;
			--params.stage1_time = 2000;
		--else
			--params.asset_file = "character/v5/temp/Effect/Holy_Precast_Uber_Base.x";
			--params.duration_time = 700;
			--params.stage1_time = 500;
		--end
		--local EffectManager = MyCompany.Aries.EffectManager;
		--EffectManager.CreateEffect(params);
		
	end
end

-- level up effect for combat
function DragonPet_New:LevelUpEffect_combat()
	MyCompany.Aries.Player.PlayAnimationFromValue(nil, -7);
	System.GSL_client:AddRealtimeMessage({name="anim", value="-7"});
end
