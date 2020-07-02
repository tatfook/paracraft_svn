--[[
Title: CombatCard Manager
Author(s): spring
Date: 2011/7/27
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardManager.teen.lua");
MyCompany.Aries.Inventory.Cards.MyCardsManager.GetRemoteCombatBag()

强制显示背包: NPL.load("(gl)script/apps/Aries/app_main.lua"); 714行
强制显示卡片分类：NPL.load("(gl)script/apps/Aries/NPCs/MagicSchool/CombatSkillLearn.lua"); 263行


NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardManager.teen.lua");
local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
MyCardsManager.GetRemoteCombatBag(callbackFunc)
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");

local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");

local Combat = commonlib.gettable("MyCompany.Aries.Combat");

MyCardsManager.ViewPageCtrl = nil;
MyCardsManager.combat_bags = {}; --战斗背包
--MyCardsManager.equip_bags ={}; --装备背包
--MyCardsManager.equip_maxNum =12; --装备背包最大容量
-- MyCardsManager.rune_bags现在改完符文快捷栏包    2015.3.17  lipeng
MyCardsManager.rune_bags ={}; --符文背包
-- MyCardsManager.rune_maxNum为8，剩余1个用来打开符文列表    2015.3.17  lipeng
MyCardsManager.rune_maxNum =8; --符文背包最大容量
MyCardsManager.runebag_gsid=0;
MyCardsManager.MainSchoolName="";
MyCardsManager.SecondarySchoolName="";

MyCardsManager.combatbag_gsid=24001;
MyCardsManager.maxNum = 18;  -- 初始背包最大容量
MyCardsManager.canEquipNum = 18; -- 初始背包可放最多卡片数
MyCardsManager.singlecard_maxnum = 5;  -- 单张卡片最大容量
MyCardsManager.class_maxnum=0; -- 某系别卡片最大容量
MyCardsManager.class_type=0; -- 背包属于的系别
MyCardsManager.equipNum = 0; -- 当前背包内放入的卡片数量
MyCardsManager.equipRuneNum = 0; -- 当前背包内放入的符文数量
MyCardsManager.cardNum = 0; -- 当前拥有的技能卡片数量
MyCardsManager.equipCardNum = 0; -- 当前拥有的装备卡片数量

MyCardsManager.dsCards={}; -- 当前应拥有的卡片
MyCardsManager.dsDispCards={}; -- 当前展示的卡片

MyCardsManager.runeList={}; -- 所有的符文
MyCardsManager.runeListMap={}; -- 所有的符文

MyCardsManager.quickRuneMap={}; -- 快捷符文包中符文gsid和位置对应关系

local is_ds_fetched = false;
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local BigCardNumPerPage = 6; -- 卡牌页单页显示大卡数量
local IconNumPerPage = 49; -- 卡牌页单页显示图标数量

function MyCardsManager.GetPropByTemplateGsid(templategsid)
	local self = MyCardsManager;
	if(not templategsid)then return "all" end
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(templategsid)
	if(gsItem)then
		local assetkey = gsItem.assetkey or "";
		assetkey = string.lower(assetkey);
		--local prop = string.match(assetkey,".+_(.+)$") or "";
		local prop = string.match(assetkey,"^%d+_(%a+)_.+") or "";
		
		if(prop == "storm")then
			return prop;
		elseif(prop == "life")then
			return prop;
		elseif(prop == "ice")then
			return prop;
		elseif(prop == "fire")then
			return prop;
		elseif(prop == "death")then
			return prop;
		elseif(prop == "balance")then
			return prop;
--		elseif(prop == "myth")then
--			return "earth";
		else
			return "all";
		end
	end
	return "all";
end

--打开指定的技能分类
function MyCardsManager.SetPageState(state)
	local self = MyCardsManager;
	state = tostring(state);
	if(not state)then return end
	self.TabValue = state;
	if(self.ViewPageCtrl)then
		self.ViewPageCtrl:Refresh(0.01);
	end
end

--打开符文指定的技能分类
function MyCardsManager.SetRunePage()
	local self = MyCardsManager;
	self.card_type = "rune";
	if(self.ViewPageCtrl)then
		self.ViewPageCtrl:Refresh(0.01);
	end
end

--打开普通技能分类
function MyCardsManager.SetCombatCardPage()
	local self = MyCardsManager;
	self.card_type = "combat";
	if(self.ViewPageCtrl )then
		self.ViewPageCtrl:Refresh(0.01);
	end
end

function MyCardsManager.Set_PageCtrl(page)
	local self = MyCardsManager;
	self.ViewPageCtrl = page;
end

--clientdata is a table
function MyCardsManager.Bag_RemoteSave(callbackFunc)
	local self = MyCardsManager;
	if(not self.combat_bags)then return end

	local bagFamily=0;
	if (self.combatbag_gsid==0) then
		local deck=ItemManager.GetItemByBagAndPosition(0, 24); -- 战斗背包种类
		self.combatbag_gsid = deck.gsid;
	end
	local gsid=self.combatbag_gsid;

	local hasGSItem = ItemManager.IfOwnGSItem;
	local hasItem,guid = hasGSItem(gsid)
	if(hasItem)then
		local item = ItemManager.GetItemByGUID(guid);
		if(item)then
			--序列化
			local bags = {};
			local k,v;
			for k,v in ipairs(self.combat_bags) do
				if(v.gsid and v.gsid ~= 0)then
					--转换key
					table.insert(bags,v.gsid);
				end
			end
			for k,v in ipairs(self.rune_bags) do
				if(v.gsid and v.gsid ~= 0)then
					--转换key
					table.insert(bags,v.gsid);
				end
			end
			local clientdata = commonlib.serialize_compact2(bags);
			echo("============save card bag");
			echo(clientdata);

			ItemManager.SetClientData(guid,clientdata,function(msg_setclientdata)
				if(callbackFunc and type(callbackFunc) == "function")then
					callbackFunc({								
					});
				end
			end, nil, nil, nil, nil, true); -- true for bForceNILQuenename
			-- NOTE: 2012/12/12: nil queue name for setclientdata, this function can be called multiple times at the same time
			--					 webapi pre_function is a must for clientdata update
		end
	end
end

function MyCardsManager.Bag_RemoteLoad(callbackFunc)
	local self = MyCardsManager;
	local bagFamily=0;
	local gsid= self.combatbag_gsid;

	local hasGSItem = ItemManager.IfOwnGSItem;
	local hasItem,guid = hasGSItem(gsid);
	if(hasItem)then
		local item = ItemManager.GetItemByGUID(guid);
		--commonlib.echo(item);
		if(item)then
			local clientdata = item.clientdata;
			if(clientdata == "")then
				clientdata = "{}"
			end
			clientdata = commonlib.LoadTableFromString(clientdata);
			echo("========== (clientdata) in combat bag");
			echo(clientdata);

			if(clientdata and type(clientdata) == "table")then
				local bags = {};
				local runebags={};
				local count_card={};
				local k;
				for k = 1,self.maxNum do
					bags[k] = {gsid = 0};
				end
				local k,v;
				local i_combatbag,i_runebag=1,1;
				for k,v in ipairs(clientdata) do
					v = tonumber(v);
					if(v)then
						--转换key
						if(v<23000 or v>24000) then
							local vhasItem = hasGSItem(v);
							if (vhasItem) then
								-- 强制纠错，如果用户某卡牌在战斗背包中拥有数量非法，强制为正常数量
								local _v=0;
								if (v<23000) then
									_v = v;
								elseif (v>=41001 and v<=41999) then
									_v = v-19000;
								elseif (v>=42001 and v<=42999) then
									_v = v-20000;
								elseif (v>=43001 and v<=43999) then
									_v = v-21000;
								elseif (v>=44001 and v<=44999) then
									_v = v-22000;
								end
								if (count_card[_v]) then
									count_card[_v]=count_card[_v]+1;
								else
									count_card[_v]=1;
								end
								if (count_card[_v]<=self.singlecard_maxnum) then
									bags[i_combatbag] = {gsid = v};
									i_combatbag = i_combatbag + 1;
								end
							end
						elseif(v>=23000 and v<24000) then
							local vhasItem = hasGSItem(v);
							if (vhasItem) then
								runebags[i_runebag] = {gsid = v};
								MyCardsManager.quickRuneMap[v] = {index = i_runebag}
								i_runebag = i_runebag + 1;
							end
						end						
					end
				end
				if(i_runebag < 8) then
					for i = i_runebag, 8 do
						runebags[i] = {gsid = 0};
					end
				end
				self.combat_bags = bags;
				self.rune_bags = runebags;

				if(callbackFunc and type(callbackFunc) == "function")then
					callbackFunc({
					});
				end
			end
					
		end
	end
end

function MyCardsManager.InitCombatBag_RemoteLoad(callbackFunc)
	local self = MyCardsManager;
	local bagFamily=0;

	-- 从配置文件加载所有符文  2015.3.17 lipeng
	MyCardsManager.LoadRune();

	local deck=ItemManager.GetItemByBagAndPosition(0, 24); -- 战斗背包种类
	commonlib.echo("===================Initdeck")
	--commonlib.echo(deck)
	-- 如果玩家0号包24号位置没有背包物品，则从1号包取物品24001（麻布口袋）装到玩家0号包24号位置
	if (deck.guid==0) then
		ItemManager.GetItemsInBag(1, "1_CombatBagDesc", function(msg)
				local hasGSItem = ItemManager.IfOwnGSItem;
				local hasItem,guid = hasGSItem(24001);
				if(hasItem)then
					local item = ItemManager.GetItemByGUID(guid);
					if(item and item.guid > 0)then
						item:OnClick("left");
						self.combatbag_gsid=24001;
					end
				end
			end, "access plus 5 minutes");
	else
		self.combatbag_gsid=deck.gsid;		
	end

	local bag=24;
	local prop="";
	ItemManager.GetItemsInBag(bag, "ariesitems_24", function(msg)
		end, "access plus 15 seconds");
end

function MyCardsManager.Bag_Clip()
	MyCardsManager.quickRuneMap = {};
	local self = MyCardsManager;
	local maxNum=0;
	local equipNum=0;

	maxNum=self.maxNum;
	if(next(self.combat_bags)==nil) then return end

	local _combat_bags = {};
	local legal_card = {};
	local _illegal_card = {};
	for _,_card in ipairs(self.combat_bags) do
		local gsid = _card.gsid;
		local bMax = self.IsAddMax(gsid);
		if (not bMax) then
			-- mark legal card
			legal_card[gsid]=1;
			local gsid_white;
			local NoNeed_WhiteCard = nil;
			if (gsid<23000) then
				table.insert(_combat_bags,_card);
			elseif (gsid>=41001 and gsid<=41999) then
				gsid_white = gsid-19000;			
				local beOK = self.CanAddToCombatBag(gsid,gsid_white);
				if (beOK) then
					table.insert(_combat_bags,_card);
				end
			elseif (gsid>=42001 and gsid<=42999) then
				gsid_white = gsid-20000;
				local beOK = self.CanAddToCombatBag(gsid,gsid_white);
				if (beOK) then
					table.insert(_combat_bags,_card);
				end
			elseif (gsid>=43001 and gsid<=43999) then
				gsid_white = gsid-21000;
				local beOK = self.CanAddToCombatBag(gsid,gsid_white);
				if (beOK) then
					table.insert(_combat_bags,_card)
				end
			elseif (gsid>=44001 and gsid<=44999) then
				gsid_white = gsid-22000;
				local beOK = self.CanAddToCombatBag(gsid,gsid_white);
				if (beOK) then
					table.insert(_combat_bags,_card);
				end
			end
		else
			if (not legal_card[gsid]) then
				-- keep illegal cards
				table.insert(_illegal_card,_card);				
			end
		end
	end

	-- 处理原战斗背包中卡牌数量不合规的卡牌	
	for _,_card in pairs(_illegal_card) do
		-- 取还可以放入的合法数量
		local lnum = self.GetCorrectNum(_card.gsid,_combat_bags);
		if (lnum>0) then
			table.insert(_combat_bags,_card);
		end
	end

	self.combat_bags = commonlib.deepcopy(_combat_bags);

	local k,len = 1,maxNum;
	local count,j = 0,0;
	for k = 1,len do
		local node = self.combat_bags[k];
		if(not node)then
			self.combat_bags[k] = {gsid = 0};
		elseif(node.gsid ~= 0)then
			count = count + 1;
		end
	end
	self.equipNum = count;

	local tmpnode={};
	for k=1,len-1 do
		for j=k, len do
			local mod_k = self.combat_bags[k].gsid % 1000;
			local mod_j = self.combat_bags[j].gsid % 1000;
			if ( mod_k < mod_j ) then
				tmpnode = self.combat_bags[k];
				self.combat_bags[k] = self.combat_bags[j];
				self.combat_bags[j] = tmpnode;
			end
		end
	end
	
	maxNum=self.rune_maxNum;
	k,len = 1,maxNum;
	count = 0;
	if (next(self.rune_bags)~=nil) then
		for k = 1,len do
			local node = self.rune_bags[k];
			if(not node)then			
				self.rune_bags[k] = {gsid = 0};
			elseif(node.gsid ~= 0)then				
				local _,_,_,_copies=hasGSItem(node.gsid)
				MyCardsManager.quickRuneMap[node.gsid] = {index = k}
				self.rune_bags[k] = {gsid=node.gsid,copies=_copies};
				count = count + 1;
			end
		end
	else
		for k = 1,len do
			self.rune_bags[k] = {gsid = 0};
		end
		count=0;
	end
	self.equipRuneNum = count;

	local _i,_card;
	local _cards={};
	local _count=0;

	echo("======Bag_Clip dsCards:");
	-- echo(self.combat_bags);
				
	for _i,_card in ipairs(self.dsCards) do
		local include,count_combat,count_rune,thiscardNum = MyCardsManager.InCombatBag(_card.gsid);
		-- rune cards
		if (_card.gsid>=23000 and _card.gsid<24000) then
			if (not include) then
				_count = _count + 1;
				_cards[_count] = commonlib.deepcopy(self.dsCards[_i]);
			end
		elseif (_card.gsid>24000 or _card.gsid<23000) then -- combat cards
			if ((_card.copies - thiscardNum)>0) then
				_count = _count + 1;
				local __card = commonlib.deepcopy(self.dsCards[_i]);						
				__card.copies = __card.copies - thiscardNum;
				_cards[_count] = commonlib.deepcopy(__card);
			end
		end				
	end
	_cards.Count = _count;
	_cards.status= 2;
	MyCardsManager.dsDispCards = commonlib.deepcopy(_cards);

	local _i=0;
	local bMode = MyCardsManager.GetBigCardMode();
	local _cardtype = self.card_type or "combat";

	local rune_buytip=true;
	if (not bMode) then
		if (MyCardsManager.dsDispCards.Count<IconNumPerPage) then
			for _i=MyCardsManager.dsDispCards.Count+1,IconNumPerPage do
				if (_cardtype=="rune" and rune_buytip) then
					MyCardsManager.dsDispCards[_i]={guid=0,gsid=0,buytip=true};
					rune_buytip=false;
				else
					MyCardsManager.dsDispCards[_i]={guid=0,gsid=0};
				end
			end
			MyCardsManager.dsDispCards.Count = IconNumPerPage;
		end
	else
		if (MyCardsManager.dsDispCards.Count<BigCardNumPerPage) then
			for _i=MyCardsManager.dsDispCards.Count+1,BigCardNumPerPage do
				if (_cardtype=="rune" and rune_buytip) then
					MyCardsManager.dsDispCards[_i]={guid=0,gsid=0,buytip=true};
					rune_buytip=false;
				else
					MyCardsManager.dsDispCards[_i]={guid=0,gsid=0};
				end
			end
			MyCardsManager.dsDispCards.Count = BigCardNumPerPage;
		end

	end
	commonlib.echo("======Bag_Clip:self.combat_bags");
	--commonlib.echo(self.combat_bags);
	--commonlib.echo("======Bag_Clip:self.rune_bags");
	--commonlib.echo(self.rune_bags);
	--commonlib.echo(MyCardsManager.dsDispCards);
end

--放入战斗背包列表
--script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardDeckSubPage.html
function MyCardsManager.Bag_DS_Func_Items(index)
	local self = MyCardsManager;
	if(not is_ds_fetched) then return end 
	if(not self.combat_bags)then return 0 end
	if(index == nil) then
		return #(self.combat_bags);
	else
		return self.combat_bags[index];
	end
end

function MyCardsManager.CombatBagIsNull()
	local self = MyCardsManager;
	if(not self.combat_bags)then
		return true;
	end
	local k,v;
	for k,v in ipairs(self.combat_bags) do
		if(v.gsid and v.gsid ~= 0)then
			return false;
		end
	end
	return true;
end

--是否已经在战斗背包or符文背包
--返回include:是否包含,count：已经携带的数量
function MyCardsManager.InCombatBag(gsid)
	local self = MyCardsManager;
	if(not gsid or not self.combat_bags)then return end	
	local k,v;
	local include = false;
	local gsid = tonumber(gsid);
	local count_combat,count_rune,thiscardNum = 0,0,0;

	if (gsid<23000 or gsid>24000) then
		for k,v in ipairs(self.combat_bags) do
			if(v.gsid == gsid)then
				include = true;
				thiscardNum = thiscardNum + 1;
			end
			if(v.gsid and v.gsid ~= 0)then
				count_combat = count_combat + 1;
			end
		end
	elseif(gsid>=23000 and gsid<24000) then
		for k,v in ipairs(self.rune_bags) do
			if(v.gsid == gsid)then
				include = true;
				thiscardNum = thiscardNum + 1;
			end
			if(v.gsid and v.gsid ~= 0)then
				count_rune = count_rune + 1;
			end
		end
	end
--	commonlib.echo("================InCombatBag=========");
	return include,count_combat,count_rune,thiscardNum;
end

function MyCardsManager.CanAddToCombatBag(gsid,gsid_white)
	local NoNeed_WhiteCard = nil;
	local gsItem_this = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if (gsItem_this) then
		NoNeed_WhiteCard = gsItem_this.template.stats[250];
	end
	local chkhas = hasGSItem(gsid_white);	
	if (not chkhas and not NoNeed_WhiteCard) then
		return false
	else
		return true
	end
end

-- cbag 中还可放入的 gsid 卡牌的数量
function MyCardsManager.GetCorrectNum(gsid,cbag)
	local self = MyCardsManager;
	local gsid = tonumber(gsid);
	local sHas,_,__,copies = hasGSItem(gsid);
	local include,count_combat,count_rune,thiscardNum = self.InCombatBag(gsid);

	if (sHas) then
		if (copies<thiscardNum) then
			local k,card;
			local leftnum=0;
			local count_card={};
			for k,card in ipairs(cbag) do
				local vhasItem = hasGSItem(card.gsid);
				local v = tonumber(card.gsid);
				if (vhasItem and v==gsid) then
					leftnum = leftnum + 1; 
					local _v= v  % 1000;
					if (count_card[_v]) then
						count_card[_v]=count_card[_v]+1;					
					else
						count_card[_v]=1;
					end
					if (count_card[_v]>=self.singlecard_maxnum) then		
						return 0;
					end					
				end
			end --for
			return copies-leftnum;
		end
		local k,card;
		local leftnum=0;
		local count_card={};
		for k,card in ipairs(cbag) do
			local vhasItem = hasGSItem(card.gsid);
			local v = tonumber(card.gsid);
			if (vhasItem and v==gsid) then
				local _v= v  % 1000;
				if (count_card[_v]) then
					count_card[_v]=count_card[_v]+1;
					leftnum = leftnum + 1; 
				else
					count_card[_v]=1;
					leftnum = 1;
				end
				if (count_card[_v]>=self.singlecard_maxnum) then		
					return 0;
				end				
			end
		end --for
		return self.singlecard_maxnum-leftnum;
	else
		return 0;
	end
end

function MyCardsManager.IsAddMax(gsid)
	local self = MyCardsManager;
	local sHas,_,__,copies = hasGSItem(gsid);
	local include,count_combat,count_rune,thiscardNum = self.InCombatBag(gsid);

	--local s=string.format("=============gsid:%d, copies:%d, inbag:%d",gsid,copies,thiscardNum);
	--commonlib.echo(s)	

	if (sHas) then
		if (copies<thiscardNum) then
			return true
		end
		local k,card;
		local count_card={};
		for k,card in ipairs(self.combat_bags) do
			local vhasItem = hasGSItem(card.gsid);
			local v = tonumber(card.gsid);
			if (vhasItem and v==gsid) then
				-- 强制纠错，如果用户某卡牌在战斗背包中拥有数量非法，强制为正常数量
				local _v= v  % 1000;
				if (count_card[_v]) then
					count_card[_v]=count_card[_v]+1;
				else
					count_card[_v]=1;
				end
				if (count_card[_v]>self.singlecard_maxnum) then
					--local s=string.format("=============gsid:%d, v:%d, _v:%d, count:%d, singleMax:%d",gsid,v, _v, count_card[_v],self.singlecard_maxnum);
					--commonlib.echo(self.combat_bags)
					--commonlib.echo(s)			
					return true
				end				
			end
		end --for
	end -- if 
	return false;
end

--添加到战斗背包
--绿卡gsid范围为 41001 ~ 41999
--蓝卡gsid范围为 42001 ~ 42999
--紫卡gsid范围为 43001 ~ 43999
--橙卡gsid范围为 44001 ~ 44999
--对应一张白卡 可以靠偏移量找到他对应的绿卡 蓝卡 紫卡 和 橙卡
function MyCardsManager.AppendToCombatBag(gsid,callbackFunc)
	local self = MyCardsManager;
	
	commonlib.echo("=========append");
	--commonlib.echo(gsid);

	if(not gsid)then return end	
	local include,count_combat,count_rune,thiscardNum = self.InCombatBag(gsid);
	
	--local current_time = MyCompany.Aries.Scene.GetElapsedSecondsSince0000();
	--commonlib.echo(current_time)
	--commonlib.echo(self.last_send_time)
	--if (self.last_send_time) then
		--if((current_time - self.last_send_time)<1) then
			--_guihelper.MessageBox("你点击的太快了")
			--return;
		--end
	--end

	local function ShowCanNotAddToCombatBagMsg(gsid, gsid_white)
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid_white);
		local _name = "该类卡牌";
		if(gsItem) then
			_name = gsItem.template.name;
		end
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem) then
			local short_school_id = gsItem.template.stats[136];
			if(short_school_id) then
				local school_gsid = Combat.Get_school_gsid_from_short_id(short_school_id);
				if(school_gsid) then
					local school_name = Combat.GetSchoolNameByGSID(school_gsid);
					if(school_name) then
						local s = string.format("你没有学习%s系的魔法，因此不能使用这张卡。", school_name);
						_guihelper.MessageBox(s);
						return;
					end
				end
			end
		end
		local s = string.format("你还没有获得%s的白色卡牌，不能使用高等级卡牌！", _name);
		_guihelper.MessageBox(s);
	end

	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);		
	local _name = "该类卡牌";
	if(gsItem)then
		_name = gsItem.template.name;				
	end	
	if (self.IsAddMax(gsid)) then		
		local s=string.format("%s 已经达到携带上限！",_name);		
		_guihelper.MessageBox(s);
		return
	end
	
	local lvlneed=gsItem.template.stats[138];
	local bean = System.App.profiles.ProfileManager.GetUserInfoInMemory();
	local mylevel;
	if(bean) then
		mylevel = bean.combatlel or 1;
	end
	if (lvlneed) then
		if (lvlneed>mylevel) then
			local s=string.format("你的等级还不够，不能使用%s！",_name);		
			_guihelper.MessageBox(s);
			return
		end
	end
	--commonlib.echo(count_combat);
	--commonlib.echo(self.maxNum);	

	--如果超出最大数量
	local gsid=tonumber(gsid);
	if(gsid>=23000 and gsid<24000 and (include or count_rune >= self.rune_maxNum)) then
		return
	end
	if ((gsid<23000 or gsid>24000)) then
		local gsid_white,gsid_green,gsid_blue,gsid_violet,gsid_orange=0,0,0,0,0,0;    
        if (gsid<23000) then
            gsid_white = gsid;
            gsid_green = gsid+19000;
            gsid_blue  = gsid+20000;
            gsid_violet= gsid+21000;
            gsid_orange= gsid+22000;
        elseif (gsid>=41001 and gsid<=41999) then
            gsid_white = gsid-19000;
			local beOK = self.CanAddToCombatBag(gsid, gsid_white);
			if (not beOK) then
				ShowCanNotAddToCombatBagMsg(gsid, gsid_white);
				return;
			end
            gsid_green = gsid;
            gsid_blue  = gsid+1000;
            gsid_violet= gsid+2000;
            gsid_orange= gsid+3000;            
        elseif (gsid>=42001 and gsid<=42999) then
            gsid_white = gsid-20000;
			local beOK = self.CanAddToCombatBag(gsid,gsid_white);
			if (not beOK) then
				ShowCanNotAddToCombatBagMsg(gsid, gsid_white);
				return;
			end
            gsid_green = gsid-1000;
            gsid_blue  = gsid;
            gsid_violet= gsid+1000;
            gsid_orange= gsid+2000;               
        elseif (gsid>=43001 and gsid<=43999) then
            gsid_white = gsid-21000;
			local beOK = self.CanAddToCombatBag(gsid,gsid_white);
			if (not beOK) then
				ShowCanNotAddToCombatBagMsg(gsid, gsid_white);
				return;
			end
            gsid_green = gsid-2000;
            gsid_blue  = gsid-1000;
            gsid_violet= gsid;
            gsid_orange= gsid+1000;   
        elseif (gsid>=44001 and gsid<=44999) then
            gsid_white = gsid-22000;
			local beOK = self.CanAddToCombatBag(gsid,gsid_white);
			if (not beOK) then
				ShowCanNotAddToCombatBagMsg(gsid, gsid_white);
				return;
			end
            gsid_green = gsid-3000;
            gsid_blue  = gsid-2000;
            gsid_violet= gsid-1000;
            gsid_orange= gsid;  
        end
		local thiscardAllNum = 0;
		local _,__,___,thiscardNum_white = self.InCombatBag(gsid_white);
		local _,__,___,thiscardNum_green = self.InCombatBag(gsid_green);
		local _,__,___,thiscardNum_blue  = self.InCombatBag(gsid_blude);
		local _,__,___,thiscardNum_violet= self.InCombatBag(gsid_violet);
		local _,__,___,thiscardNum_orange= self.InCombatBag(gsid_orange);
		thiscardNum_white = thiscardNum_white or 0;
		thiscardNum_green = thiscardNum_green or 0;
		thiscardNum_blue  = thiscardNum_blue or 0;
		thiscardNum_violet= thiscardNum_violet or 0;
		thiscardNum_orange= thiscardNum_orange or 0;
		thiscardAllNum = thiscardNum_white + thiscardNum_green + thiscardNum_blue + thiscardNum_violet + thiscardNum_orange;
		
		if (thiscardAllNum >= self.singlecard_maxnum) then
			return
		end
	end	

	if(count_combat >= self.maxNum )then
		return
	end


	local k,v;
	if (gsid<23000 or gsid>24000) then
		for k,v in ipairs(self.combat_bags) do
			if(v.gsid == 0)then
				v.gsid = gsid;
				break;
			end
		end

		--commonlib.echo("=========append==self.combat_bags");
		--commonlib.echo(self.combat_bags);
	elseif (gsid>=23000 and gsid<24000) then
		for k,v in ipairs(self.rune_bags) do
			if(v.gsid == 0)then
				v.gsid = gsid;
				break;
			end
		end
		--commonlib.echo("===========self.rune_bags");
		--commonlib.echo(self.rune_bags);
	end
	self.Bag_Clip();
	--self.last_send_time = current_time;
	--保存
	MyCardsManager.Bag_RemoteSave(function()
		--commonlib.echo("================RemoteSave refresh MyCardsBagPageCtrl===========");
		MyCardsManager.RefreshPage();
	end)
end

function MyCardsManager.chkgsid(_gsid)
	local self = MyCardsManager;
	if(not _gsid)then return false end	
	local gsid=tonumber(_gsid);
	local include,count_combat,count_rune,thiscardNum = self.InCombatBag(gsid);		
	--如果超出最大数量
	if(count_combat >= self.maxNum )then
		return false
	end	
	if(gsid>=23000 and gsid<24000 and (include or count_rune >= self.rune_maxNum)) then
		return false
	end
	if (self.IsAddMax(gsid)) then
		return false
	end

	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);		
	local lvlneed=gsItem.template.stats[138];
	local bean = System.App.profiles.ProfileManager.GetUserInfoInMemory();
	local mylevel;
	if(bean) then
		mylevel = bean.combatlel or 1;
	end
	if (lvlneed) then
		if (lvlneed>mylevel) then
			return false
		end
	end
	if ((gsid<23000 or gsid>24000)) then
		local gsid_white,gsid_green,gsid_blue,gsid_violet,gsid_orange=0,0,0,0,0,0;    
        if (gsid<23000) then
            gsid_white = gsid;
            gsid_green = gsid+19000;
            gsid_blue  = gsid+20000;
            gsid_violet= gsid+21000;
            gsid_orange= gsid+22000;
        elseif (gsid>=41001 and gsid<=41999) then
			gsid_white = gsid-19000;
			local beOK = self.CanAddToCombatBag(gsid, gsid_white);
			if (not beOK) then
				return false;
			end
			gsid_green = gsid;
			gsid_blue  = gsid+1000;
			gsid_violet= gsid+2000;
			gsid_orange= gsid+3000;            
        elseif (gsid>=42001 and gsid<=42999) then
			gsid_white = gsid-20000;
			local beOK = self.CanAddToCombatBag(gsid,gsid_white);
			if (not beOK) then
				return false;
			end
			gsid_green = gsid-1000;
			gsid_blue  = gsid;
			gsid_violet= gsid+1000;
			gsid_orange= gsid+2000;               
        elseif (gsid>=43001 and gsid<=43999) then
            gsid_white = gsid-21000;
			local beOK = self.CanAddToCombatBag(gsid,gsid_white);
			if (not beOK) then
				return false
			end
            gsid_green = gsid-2000;
            gsid_blue  = gsid-1000;
            gsid_violet= gsid;
            gsid_orange= gsid+1000;   
        elseif (gsid>=44001 and gsid<=44999) then
			gsid_white = gsid-22000;
			local beOK = self.CanAddToCombatBag(gsid,gsid_white);
			if (not beOK) then
				return false
			end
			gsid_green = gsid-3000;
			gsid_blue  = gsid-2000;
			gsid_violet= gsid-1000;
			gsid_orange= gsid;  
        end
		local thiscardAllNum = 0;
		local _,__,___,thiscardNum_white = self.InCombatBag(gsid_white);
		local _,__,___,thiscardNum_green = self.InCombatBag(gsid_green);
		local _,__,___,thiscardNum_blue  = self.InCombatBag(gsid_blude);
		local _,__,___,thiscardNum_violet= self.InCombatBag(gsid_violet);
		local _,__,___,thiscardNum_orange= self.InCombatBag(gsid_orange);
		thiscardNum_white = thiscardNum_white or 0;
		thiscardNum_green = thiscardNum_green or 0;
		thiscardNum_blue  = thiscardNum_blue or 0;
		thiscardNum_violet= thiscardNum_violet or 0;
		thiscardNum_orange= thiscardNum_orange or 0;
		thiscardAllNum = thiscardNum_white + thiscardNum_green + thiscardNum_blue + thiscardNum_violet + thiscardNum_orange;
		
		if (thiscardAllNum >= self.singlecard_maxnum) then
			return false
		end
	end	
	return true
end

function MyCardsManager.BatchAddCardsTeen(gsid,begin_num,end_num)
	local self=MyCardsManager;
	commonlib.echo("=========batch append");
	--commonlib.echo(gsid)
	commonlib.echo(begin_num)
	commonlib.echo(end_num)
	for i=begin_num, end_num-1 do
		local _chk=self.chkgsid(gsid);
		if (not _chk) then return end;
		local k,v;		
		if (gsid<23000 or gsid>24000) then
			for k,v in ipairs(self.combat_bags) do
				if(v.gsid == 0)then
					v.gsid = gsid;
					break;
				end
			end
		elseif (gsid>=23000 and gsid<24000) then
			for k,v in ipairs(self.rune_bags) do
				if(v.gsid == 0)then
					v.gsid = gsid;
					break;
				end
			end
		end
		if(not self.CanEquip())then
			return 
		end		
	end
	self.Bag_Clip();
	--保存
	MyCardsManager.Bag_RemoteSave(function()
		MyCardsManager.RefreshPage();
	end)	
end
--从战斗背包移除所有卡牌
function MyCardsManager.RemoveAllCardsFromCombatBag()
	local self = MyCardsManager;
	local k,v,i;
	i=1;
	for k,v in ipairs(self.combat_bags) do
		if(v.gsid ~=0)then
			self.combat_bags[i]={gsid=0};
			i=i+1;
		end
	end			
	i=1;
	for k,v in ipairs(self.rune_bags) do
		if(v.gsid ~=0)then
			self.rune_bags[i]={gsid=0};
			i=i+1;
		end
	end
	self.Bag_Clip();
	--保存
	MyCardsManager.Bag_RemoteSave(function()
		MyCardsManager.RefreshPage();
	end)
end

--从战斗背包移除
function MyCardsManager.RemoveFromCombatBag(gsid,bagIndex,callbackFunc)
	local self = MyCardsManager;
	if(not gsid)then return end	
	local k,v,i;
	commonlib.echo("=========remove");
	--commonlib.echo(self.combat_bags);

	if (gsid<23000 or gsid>24000) then
		if (self.combat_bags[bagIndex].gsid==gsid) then
			self.combat_bags[bagIndex]={gsid=0};
		end

		i=1;
		for k,v in ipairs(self.combat_bags) do
			if(v.gsid ~=0)then
				self.combat_bags[i]={gsid=v.gsid};
				i=i+1;
			end
		end
		for j=i,self.maxNum do
			self.combat_bags[j]={gsid=0};	
		end
		--commonlib.echo(self.combat_bags);
	elseif (gsid>=23000 and gsid<24000) then
		if (self.rune_bags[bagIndex].gsid==gsid) then
			self.rune_bags[bagIndex]={gsid=0};
		end

		i=1;
		for k,v in ipairs(self.rune_bags) do
			if(v.gsid ~=0)then
				self.rune_bags[i]={gsid=v.gsid};
				i=i+1;
			end
		end
		for j=i,self.rune_maxNum do
			self.rune_bags[j]={gsid=0};	
		end
		--commonlib.echo(self.rune_bags);
	end

	self.Bag_Clip();
	--保存
	MyCardsManager.Bag_RemoteSave(function()
		MyCardsManager.RefreshPage();
	end)
end

function MyCardsManager.RefreshPage()
	local self = MyCardsManager;
	if(self.ViewPageCtrl)then
		self.ViewPageCtrl:Refresh(0.01);
	end
end

--卡片是否超过最大携带量
function MyCardsManager.CanEquip()
	local self = MyCardsManager;
	if(self.equipNum >= self.canEquipNum)then
		return false;
	end
	return true;
end

--符文是否超过最大携带量
function MyCardsManager.CanEquipRune()
	local self = MyCardsManager;
	if(self.equipRuneNum >= self.rune_maxNum - 1)then
		return false;
	end
	return true;
end

--携带
function MyCardsManager.DoAppend(gsid)
	local self = MyCardsManager;
	--commonlib.echo("==========auto doEquip card3")
	self.AppendToCombatBag(gsid,callbackFunc);
end

--取消携带
function MyCardsManager.DoRemove(gsid,bagIndex)
	local self = MyCardsManager;
    --commonlib.echo("==========gsid:"..gsid.."|"..bagIndex);
	gsid=tonumber(gsid);
	bagIndex=tonumber(bagIndex)
	self.RemoveFromCombatBag(gsid,bagIndex,callbackFunc);
end

--是否拥有卡片获得的权利
function MyCardsManager.HasCardTemplagte(templategsid)
	local self = MyCardsManager;
	if(templategsid)then
		return hasGSItem(templategsid);
	end
	local bag = 24;
	for i = 1, ItemManager.GetItemCountInBag(bag) do
		local item = ItemManager.GetItemByBagAndOrder(bag, i);
		if(item ~= nil) then
			local gsid = item.gsid;
			--排除 经验石
			if(gsid and gsid ~= 22000)then
				local bHas = hasGSItem(gsid);
				if(bHas)then
					return true;
				end
			end
		end
	end
end

function MyCardsManager.GetLocalCombatBag()
	local self = MyCardsManager;
	return self.combat_bags;
end

function MyCardsManager.GetLocalRuneBag()
	local self = MyCardsManager;
	return self.rune_bags;
end

function MyCardsManager.GetRemoteCombatBag(callbackFunc)
	local self = MyCardsManager;
	local deck=ItemManager.GetItemByBagAndPosition(0, 24); -- 战斗背包种类
	
	local classprop_gsid = MyCompany.Aries.Combat.GetSchoolGSID();
	local class_cardnum={
	[986]=171, [987]=172, [988]=173, [989]=174, [990]=175, [991]=176, [992]=177, -- 根据系别取单个卡片张数
	[171]=6,   [172]=7,   [173]=8,   [174]=9,   [175]=10,  [176]=11,  [177]=12,  -- 根据系别对应属性，取背包系别
	}
	local deckitem;

	---- 初始化装备背包，如果玩家装备里没有卡片，将 self.equip_maxNum 个gsid 置0，显示空格
	--local i;
	--for i=1,self.equip_maxNum do
		--self.equip_bags[i]={gsid=0};
	--end
	---- NOTE: deck cards and follow pet cards are now separated due to follow pet swapping during combat
	----		follow pet cards is not included as static structure in entercombat information
	--local equipbag = MyCompany.Aries.Combat.GetEquipCards();  -- 取玩家当前的装备里的卡片
	--local equipbag_pet = MyCompany.Aries.Combat.GetPetCards();  -- fetch follow pet cards
	--if(equipbag and equipbag_pet) then
		--local i, m, k, v;
		--m = 0;
		--i = 0;
		--for k, v in pairs(equipbag) do
			--local j;
			--for j = 1, v do 
				--m = i + j;				
				--if(m <= self.equip_maxNum) then
					--self.equip_bags[m] = {gsid = k};
				--else
					--break;
				--end
			--end
			--i = i + v; 
		--end	
		--for k, v in pairs(equipbag_pet) do
			--local j;
			--for j = 1, v do 
				--m = i + j;				
				--if(m <= self.equip_maxNum) then
					--self.equip_bags[m] = {gsid = k};
				--else
					--break;
				--end
			--end
			--i = i + v; 
		--end	
		--self.equipCardNum = m;
	--end
--
	--commonlib.echo("===============self.equip_bags============");
	--commonlib.echo(self.equip_bags);
	--commonlib.echo(self.equipCardNum);

	if (deck and deck.guid~=0) then
		self.combatbag_gsid=deck.gsid;
		deckitem=ItemManager.GetGlobalStoreItemInMemory(self.combatbag_gsid);
		if (deckitem) then
			self.canEquipNum=deckitem.template.stats[167];
			self.maxNum=deckitem.template.stats[167];
			self.singlecard_maxnum=deckitem.template.stats[170];
			self.class_maxnum=deckitem.template.stats[class_cardnum[classprop_gsid]] or 0;
			self.class_type=class_cardnum[class_cardnum[classprop_gsid]] or 0;
		end
		-- commonlib.echo("===============self.Maxmum:"..self.maxNum.."====self.combatbag_gsid:"..self.combatbag_gsid);
		self.Bag_RemoteLoad(function() -- get combatbag
			self.Bag_Clip();
			--保存
			MyCardsManager.Bag_RemoteSave(function()
			end)
			if(callbackFunc)then
				callbackFunc();
			end
		end);
	else
		self.canEquipNum = 0;
		self.maxNum = 0;
		self.singlecard_maxnum = 0;
		self.class_maxnum = 0;
		self.class_type = 0;
	end
	--commonlib.echo("===============self.rune_bags============");
	--commonlib.echo(self.rune_bags);
end

function MyCardsManager.GetEquipRuneNum()
	return MyCardsManager.equipRuneNum or 0;
end

function MyCardsManager.GetEquipCardNum()
	return MyCardsManager.equipCardNum or 0;
end

function MyCardsManager.OnOpen()
	local self = MyCardsManager;
	if(self.isOpened)then 	return	end
	self.isOpened = true;
	self.GetRemoteCombatBag(function()
	end);
end

function MyCardsManager.OnClose()
	local self = MyCardsManager;
	self.isOpened = false;
end

--获取自己背包的数量
function MyCardsManager.GetCanEquipNum()
	local self = MyCardsManager;
	return self.canEquipNum;
end

--function MyCardsManager.Equip_DS_Func_Items(index)
	--local self = MyCardsManager;
	--if(not is_ds_fetched) then return end 
	--if(not self.equip_bags)then return 0 end
	--if(index == nil) then
		--return #(self.equip_bags);
	--else
		--return self.equip_bags[index];
	--end
--end

function MyCardsManager.Rune_DS_Func_Items(index)
	local self = MyCardsManager;
	if(not is_ds_fetched) then return end 
	if(not self.rune_bags)then 
		return 0 
	else
		MyCardsManager.UpdateQuickRune();
	end
	if(index == nil) then
		return #(self.rune_bags);
	else
		return self.rune_bags[index];
	end
end

local bBigCardMode = nil;

function MyCardsManager.Init(new_gsid,card_type,sub_class)	
	MyCardsManager.SecondarySchool = {[969]="fire",[970]="ice",[971]="storm",[972]="myth",[973]="life",[974]="death",[975]="balance",};

	-- 从配置文件加载所有符文  2015.3.17 lipeng
	MyCardsManager.LoadRune();

	if(bBigCardMode == nil) then
		MyCardsManager.MainSchoolName = MyCompany.Aries.Combat.GetSchool(System.User.nid);
		local SecondarySchoolGSID = MyCompany.Aries.Combat.GetSecondarySchoolGSID();
		SecondarySchoolGSID = tonumber(SecondarySchoolGSID);
		MyCardsManager.SecondarySchoolName = MyCardsManager.SecondarySchool[SecondarySchoolGSID];
		if(MyCompany.Aries and MyCompany.Aries.app) then
			bBigCardMode = MyCompany.Aries.app:ReadConfig("bBigCardMode", true);
		end
	end

	local is_immediate_result = true;
	local getnew = false;
	if (next(MyCardsManager.dsCards)~=nil) then
		if (card_type~=MyCardsManager.dsCards.cardtype) then
			getnew = true;
		elseif (sub_class~=MyCardsManager.dsCards.subclass) then
			getnew = true;
		end
	end

	if (not is_ds_fetched or new_gsid) then
		MyCardsManager.dsCards = {status = nil, };
		local page_norefresh = true;
		local _class_type="all";
		if (sub_class) then
			_class_type=sub_class;
		end

		MyCardsManager.GetItems(card_type, _class_type, "access plus 15 seconds", MyCardsManager.dsCards, nil,nil,page_norefresh,new_gsid);
		commonlib.echo("=============init_combat_card")
	elseif (getnew) then
		commonlib.echo("=============init_combat_card new type")
		--commonlib.echo(card_type)
		--commonlib.echo(MyCardsManager.dsCards.cardtype)

		MyCardsManager.dsCards = {status = nil, };
		local page_norefresh = true;
		if (card_type=="combat") then
			local _class_type="all";
			if (sub_class) then
				_class_type=sub_class;
			end
			MyCardsManager.GetItems(card_type, _class_type, "access plus 15 seconds", MyCardsManager.dsCards, nil,nil,page_norefresh,new_gsid);
		else
			MyCardsManager.GetItems(card_type, "all", "access plus 15 seconds", MyCardsManager.dsCards, nil,nil,page_norefresh,new_gsid);
		end
	end
	
	MyCardsManager.GetRemoteCombatBag(function()
		is_ds_fetched = true;
		if(not is_immediate_result) then
			MyCardsManager.RefreshPage();
		end
	end);
	is_immediate_result = false;	
end

function MyCardsManager.SetBigCardMode(bMode)
	bBigCardMode = bMode;
	MyCardsManager.Bag_Clip();
end

function MyCardsManager.GetBigCardMode()
	return bBigCardMode;
end

-- all items
MyCardsManager.CombatDeckInventory = MyCardsManager.CombatDeckInventory or {Count = 0};
-- filtered items in the current selected category
MyCardsManager.CombatDeckShowItems = MyCardsManager.CombatDeckShowItems or {Count = 0};

function MyCardsManager.GetCombatDeckItems(page, call_back)
	
	MyCardsManager.CombatDeckShowItems.Count = 7;

	local bags = { 1, };
	MyCardsManager.CombatDeckInventory.status = 1;  -- 初始化，未获取GetItemsInBag
	local itemmanager = System.Item.ItemManager;
	bags.ReturnCount = 0;
	for _,bag in ipairs(bags) do
		local bIsImmediateResult = true;
		itemmanager.GetItemsInBag( bag, "ariesitems_" .. bag, function(msg)
			bags.ReturnCount = bags.ReturnCount + 1;
			-- when all bags are fetched.
			if( bags.ReturnCount >= #bags)then
				if(msg and msg.items)then
					local count = 0;
					local __,bag;
					for __,bag in ipairs(bags) do
						local i;
						local bagitem_count = itemmanager.GetItemCountInBag(bag);
						for i = 1, bagitem_count do
							local item = itemmanager.GetItemByBagAndOrder(bag, i);
							if( item ~= nil )then
								MyCardsManager.CombatDeckInventory[count+ i] = { guid=item.guid,gsid=item.gsid};
							end
						end
						count = count + bagitem_count;
					end

					-- create dummy items, so that it is multiple is 5 cells
					local displaycount = math.ceil(count / 6) * 6;
					if(count == 0 )then
						displaycount = 5;
					end

					local i;
					for i = count + 1, displaycount do
						MyCardsManager.CombatDeckInventory[i] = { guid = 0 };
					end
					MyCardsManager.CombatDeckInventory.Count = count;
				end

				MyCardsManager.CombatDeckFilter();
				MyCardsManager.CombatDeckInventory.status = 2; -- 获取了GetItemsInBag标志
				if(page) then
					page:Refresh(0.01);
				end
				if(call_back) then
					call_back(bIsImmediateResult);
				end
			end
		end, "access plus 15 minutes");
		bIsImmediateResult = nil;
	end
end

function MyCardsManager.CombatDeckFilter()
	local deck=ItemManager.GetItemByBagAndPosition(0, 24); -- 战斗背包种类
	local item={};
	local gsItem;
	local _deck={}; -- 标记已列入显示table的卡包

	MyCardsManager.CombatDeckShowItems = {Count = 0};
	if (deck and deck.guid~=0) then  -- 当前口袋
		item= {gsid=deck.gsid, guid=deck.guid, };
		gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(tonumber(item.gsid));
		if(gsItem)then		
			item.name = gsItem.template.name;	
			item.maxNum = tonumber(gsItem.template.stats[167]) or 0;
			item.singlecard_maxNum = tonumber(gsItem.template.stats[170]) or 0;
		end 
		MyCardsManager.CombatDeckShowItems.Count = MyCardsManager.CombatDeckShowItems.Count + 1;
		item.isCombatDeck = 1;
		table.insert(MyCardsManager.CombatDeckShowItems,item);
		_deck[deck.gsid]=1;
	end
	for _, item in ipairs(MyCardsManager.CombatDeckInventory) do -- 其他口袋
		if(item.guid~=0)then
			if (not _deck[item.gsid]) then
				gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(tonumber(item.gsid));
				if(gsItem)then
					local class = tonumber(gsItem.template.class);
					local subclass = tonumber(gsItem.template.subclass);
					local bagfamily = gsItem.template.bagfamily;
					
					if ( class == 19 and subclass == 1) then				
						MyCardsManager.CombatDeckShowItems.Count = MyCardsManager.CombatDeckShowItems.Count + 1;
						local maxNum = tonumber(gsItem.template.stats[167]) or 0; -- 口袋可装最多卡牌数	
						local singlecard_maxNum = tonumber(gsItem.template.stats[170]) or 0; -- 可装单张卡片最多张数	
						item.name = gsItem.template.name;
						item.maxNum = maxNum;
						item.singlecard_maxNum = singlecard_maxNum;
						item.isCombatDeck= 0;
						table.insert(MyCardsManager.CombatDeckShowItems,item);
					end
				end
				_deck[item.gsid]=1;
			end
		end
	end

	local i,j;
	local tmpItem={};
	for i = 1,MyCardsManager.CombatDeckShowItems.Count-1 do	-- 按口袋可装最大卡牌数和卡包gsid大小 逆排序	
		for j = i+1,MyCardsManager.CombatDeckShowItems.Count do
			local iMaxnum = MyCardsManager.CombatDeckShowItems[i].maxNum;
			local jMaxnum = MyCardsManager.CombatDeckShowItems[j].maxNum;
			
			local iGsid = MyCardsManager.CombatDeckShowItems[i].gsid;
			local jGsid = MyCardsManager.CombatDeckShowItems[j].gsid;

			if (iMaxnum < jMaxnum) then
				tmpItem = MyCardsManager.CombatDeckShowItems[i];
				MyCardsManager.CombatDeckShowItems[i] = MyCardsManager.CombatDeckShowItems[j];
				MyCardsManager.CombatDeckShowItems[j] = tmpItem;
			elseif (iMaxnum == jMaxnum and iGsid<jGsid) then
				tmpItem = MyCardsManager.CombatDeckShowItems[i];
				MyCardsManager.CombatDeckShowItems[i] = MyCardsManager.CombatDeckShowItems[j];
				MyCardsManager.CombatDeckShowItems[j] = tmpItem;
			end
		end
	end
	if (MyCardsManager.CombatDeckShowItems.Count < 7) then
		local _item= {gsid=0, guid=0, };
		table.insert(MyCardsManager.CombatDeckShowItems,_item);
		MyCardsManager.CombatDeckShowItems.Count = MyCardsManager.CombatDeckShowItems.Count+1;		
	end
	--commonlib.echo("============combatdeck===")
	--commonlib.echo(MyCardsManager.CombatDeckShowItems)

end

-- ds function of the current selected sub category
function MyCardsManager.CombatDeckDS_Func(index)
	if(MyCardsManager.CombatDeckInventory.status == 2)then
		if(index == nil)then
			return MyCardsManager.CombatDeckShowItems.Count;
		else
			if (next(MyCardsManager.CombatDeckShowItems)~=nil) then
				return MyCardsManager.CombatDeckShowItems[index];
			else -- 如果 MyCardsManager.GetCombatDeckItems 获取所有卡包超时，这里容错
				return MyCardsManager.CombatDeckShowItems.Count;
			end
		end
	else
		if(index==nil)then
			return 0;
		else
			if(index<=6)then
				return {guid = 0};
			end
		end
	end
end

-- 当前卡牌
function MyCardsManager.DS_Func_CardsDeck(dsTable, index, class,subclass,showNum,card_maxnum,new_gsid)    
	-- commonlib.echo("======DS_Func_CardsDeck:");	
	
    if(not dsTable.status) then
        -- use a default cache
        if(index == nil) then
			MyCardsManager.dsCards = {status = nil, Count=100 };
			MyCardsManager.GetItems(class, subclass, "access plus 5 minutes", MyCardsManager.dsCards,showNum,card_maxnum,nil,new_gsid);
			return MyCardsManager.dsCards.Count;
        else
			if(index <= 100) then
				return {guid = 0};
			end
        end
    elseif(dsTable.status == 2) then
        if(index == nil) then
			return MyCardsManager.dsDispCards.Count;			
        else
			return MyCardsManager.dsDispCards[index];
        end
    end 
end

-- judge if the card canbe used
function MyCardsManager.IfCardBeUsed(gsid)
	local self = MyCardsManager;

	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	local bean = System.App.profiles.ProfileManager.GetUserInfoInMemory();
	local mylevel;
	if(bean) then
		mylevel = bean.combatlel or 1;
	end

	local lvlneed=gsItem.template.stats[138];

	if (lvlneed) then
		if (lvlneed>mylevel) then
			return false;
		end
	end

	if (gsid>24000) then
		local gsid_white=0;    
		if (gsid>=41001 and gsid<=41999) then
			gsid_white = gsid-19000;
		elseif (gsid>=42001 and gsid<=42999) then
			gsid_white = gsid-20000;
		elseif (gsid>=43001 and gsid<=43999) then
			gsid_white = gsid-21000;
		elseif (gsid>=44001 and gsid<=44999) then
			gsid_white = gsid-22000;
		end
		local beOK = self.CanAddToCombatBag(gsid,gsid_white);
		if (not beOK) then		
			return false;
		end
	 end
	 return true;
end

-- 获取当前卡牌
function MyCardsManager.GetItems(class, subclass, cachepolicy, output,showNum,card_maxnum,NoRefresh,new_gsid)
	local self = MyCardsManager;
	--默认显示6个
--	showNum = showNum or 6;
	local bags;
	if(class == "combat") then
		bags = {24};
	elseif(class == "rune") then
		bags = {25};
	end
	if(bags == nil) then
		bags = {24};
	end
	if(bags == nil) then
		-- return empty datasource table, if no bag id is specified
		output.Count = 0;
		commonlib.resize(output, output.Count)
		return;
	end
	-- fetching inventory items
	output.status = 1;
	
	bags.ReturnCount = 0;

	local _, bag;
	local prop = "";
	for _, bag in ipairs(bags) do
		ItemManager.GetItemsInBag(bag, "ariesitems_"..bag, function(msg)
			bags.ReturnCount = bags.ReturnCount + 1;
			if(bags.ReturnCount >= #bags) then
				if(msg and msg.items) then			
					local count = 0;
					local combat_count = 0;
					local __, bag;
					local _output={};
					for __, bag in ipairs(bags) do
						local i;
						for i = 1, ItemManager.GetItemCountInBag(bag) do
							local item = ItemManager.GetItemByBagAndOrder(bag, i);
							if(item ~= nil) then
								local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid)
								-- only list the card which can be used
								if(gsItem and self.IfCardBeUsed(item.gsid))then
									local assetkey = gsItem.assetkey or "";
									assetkey = string.lower(assetkey);
									prop = string.match(assetkey,"^%d+_(%a+)_.+") or "";

									if (not gsItem.template.stats[134]) then
										local s = string.format("Error! %d doesnot has pips!",item.gsid)
										_guihelper.MessageBox(s)
									else
										--all storm ice life fire death
										if(subclass == "all" or (prop == subclass))then
											--24号包排除 经验石
											if(item.gsid ~= 22000)then
												combat_count = combat_count + 1;
												_output[combat_count] = {guid = item.guid, gsid = item.gsid, pips=gsItem.template.stats[134], copies=item.copies, modgsid=item.gsid%1000,};
											end
										elseif (subclass=="other") then
											if (prop~= MyCardsManager.MainSchoolName and prop~= MyCardsManager.SecondarySchoolName) then
												if (item.gsid ~= 22000)then
													combat_count = combat_count + 1;
													_output[combat_count] = {guid = item.guid, gsid = item.gsid, pips=gsItem.template.stats[134], copies=item.copies, modgsid=item.gsid%1000,};
												end
											end
										end -- subclass judge
									end
								end
							end
						end
						if (bag==24) then
							MyCardsManager.cardNum = combat_count;
						end
						count = combat_count;

						_output.status = 2;
						_output.Count = count;
						self.dsCards = commonlib.deepcopy(_output);
					end

					local i,j,_i;
					if (new_gsid) then
						for i = 1, count do						
							if (self.dsCards[i].gsid==new_gsid) then
								local tmpnode={};
								tmpnode = self.dsCards[1];
								self.dsCards[1] = self.dsCards[i];
								self.dsCards[i] = tmpnode;
								break;
							end
						end		
						_i=2;				
					else
						_i=1;
					end

					for i = _i, count-1 do
						for j=i+1, count do			
							if (self.dsCards[j].pips > self.dsCards[i].pips ) then
								local tmpnode={};
								tmpnode = self.dsCards[i];
								self.dsCards[i] = self.dsCards[j];
								self.dsCards[j] = tmpnode;	
							elseif (self.dsCards[j].pips==self.dsCards[i].pips) then
								if (self.dsCards[j].modgsid>self.dsCards[i].modgsid) then
									local tmpnode={};
									tmpnode = self.dsCards[i];
									self.dsCards[i] = self.dsCards[j];
									self.dsCards[j] = tmpnode;		
								elseif (self.dsCards[j].modgsid == self.dsCards[i].modgsid)then
									if (self.dsCards[j].gsid > self.dsCards[i].gsid) then
										local tmpnode={};
										tmpnode = self.dsCards[i];
										self.dsCards[i] = self.dsCards[j];
										self.dsCards[j] = tmpnode;	
									end
								end
							end
						end
					end
				end

				local _,_card;
				local _cards={};
				if (not MyCardsManager.CardFilter or MyCardsManager.CardFilter=="all") then
					MyCardsManager.CardFilter="all";
				else
					for _,_card in ipairs(self.dsCards) do
						local gsItem = ItemManager.GetGlobalStoreItemInMemory(_card.gsid);
						if (gsItem) then
							if (MyCardsManager.CardFilter=="white") then							
								if (gsItem.template.stats[221]==0) then
									table.insert(_cards,_card);
								end
							end
							if (MyCardsManager.CardFilter=="green") then
								if (gsItem.template.stats[221]==1) then
									table.insert(_cards,_card);
								end
							end
							if (MyCardsManager.CardFilter=="blue") then
								if (gsItem.template.stats[221]==2) then
									table.insert(_cards,_card);
								end
							end
							if (MyCardsManager.CardFilter=="purple") then
								if (gsItem.template.stats[221]==3) then
									table.insert(_cards,_card);
								end
							end
						end
					end

					self.dsCards=commonlib.deepcopy(_cards);
					self.dsCards.status = 2;
					self.dsCards.Count = #(_cards);
				end

				self.dsCards.cardtype=class;
				self.dsCards.subclass=subclass;
				--commonlib.resize(output, output.Count);
				commonlib.echo("======GetItems output===");
				--commonlib.echo(MyCardsManager.CardFilter);
				--commonlib.echo(new_gsid);
				--commonlib.echo(class);
				--commonlib.echo(subclass);
				--commonlib.echo(self.dsCards);				

				self.Bag_Clip();

				if (not NoRefresh) then
					self.ViewPageCtrl:Refresh(0.1);
				end
			end
		end, cachepolicy);
	end
end

function MyCardsManager.ShowPage(zorder,gsid)
	local self = MyCardsManager; 
	zorder = zorder or 1;
	local _url;
	if (not gsid) then
		_url = string.format("script/apps/Aries/Desktop/CombatCharacterFrame/CombatCard.teen.html");
	else
		_url = string.format("script/apps/Aries/Desktop/CombatCharacterFrame/CombatCard.teen.html?gsid=%d",gsid);
	end

	self.dsCards = {status = nil, };
	local page_norefresh = true;
	self.GetItems("combat", "all", "access plus 5 minutes", self.dsCards, nil,nil,page_norefresh);

	local params = {
		url = _url, 
		name = "CombatCardTeen", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,	
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = zorder,
		allowDrag = true,
		enable_esc_key = true,
		directPosition = true,
			align = "_ct",
			x = -760/2,
			y = -480/2,
			width = 760,
			height = 480,
		cancelShowAnimation = true,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params)
	if(params._page) then
		params._page.OnClose = function(bDestroy)
			Dock.OnClose("CombatCardTeen")
		end
	end
end

function MyCardsManager.AutoEquipRune(gsid)
--[[
    local gsid = tonumber(gsid);
    local include = MyCardsManager.InCombatBag(gsid);

    if (include) then
        return     
    end    
    if(not MyCardsManager.CanEquipRune()) then
		return     
    end
        
    MyCardsManager.DoAppend(gsid);

	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	local RuneName = gsItem.template.name;		

	local color = "#f8f8f8";
	local tooltip = "page://script/apps/Aries/Inventory/Cards/CardsTooltip.html?state=7&amp;gsid="..gsid;
	local name_with_a = string.format(
	   '<a tooltip="%s" style="margin-left:0px;float:left;background:url()"><div style="float:left;margin-top:-2px;color:%s;">[%s]</div></a>',tooltip, color, RuneName);
	   	
	local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
	ChatChannel.AppendChat({
				ChannelIndex = ChatChannel.EnumChannels.ItemObtain, 
				fromname = "", 
				fromschool = MyCompany.Aries.Combat.GetSchoolGSID(), 
				fromisvip = false, 
				words = "新符文: "..name_with_a .."已放入当前战斗背包",
				is_direct_mcml = true,
				bHideSubject = true,
				bHideTooltip = true,
				bHideColon = true,
			});
]]
end

function MyCardsManager.AutoCopyCardsFrmPreDeck(preDeckGSID,curDeckGSID,bRefresh)
	local self = MyCardsManager; 

	local hasGSItem = ItemManager.IfOwnGSItem;
	local curDeckHasItem,curDeckGUID = hasGSItem(curDeckGSID);

	if(curDeckHasItem)then
		local _mItem = ItemManager.GetGlobalStoreItemInMemory(curDeckGSID);
		self.maxNum = _mItem.template.stats[167];
		self.singlecard_maxnum = _mItem.template.stats[170];

		local curDeckItem = ItemManager.GetItemByGUID(curDeckGUID);
		--commonlib.echo("============AutoCopyCardsFrmPreDeck:curDeckItem:"..curDeckGSID);
		--commonlib.echo(curDeckItem);

		if(curDeckItem)then
			self.combatbag_gsid = curDeckGSID;

			local clientdata = curDeckItem.clientdata or "";
			if(clientdata == "")then
				clientdata = "{}"
			end
			clientdata = commonlib.LoadTableFromString(clientdata);

			local i_combatbag,i_runebag=1,1;
			local bags = {};
			local runebags={};

			if(clientdata and type(clientdata) == "table")then
				local k;
				for k = 1,self.maxNum do
					bags[k] = {gsid = 0};
				end
				local k,v;				
				for k,v in ipairs(clientdata) do
					v = tonumber(v);
					if(v)then
						--转换key
						if(v<23000 or v>24000) then
							local vhasItem = hasGSItem(v);
							if (vhasItem) then
								bags[i_combatbag] = {gsid = v};
								i_combatbag = i_combatbag + 1;
							end
						elseif(v>=23000 and v<24000) then
							local vhasItem = hasGSItem(v);
							if (vhasItem) then
								runebags[i_runebag] = {gsid = v};
								i_runebag = i_runebag + 1;
							end
						end						
					end
				end
				self.combat_bags = bags;
				self.rune_bags = runebags;

				self.equipNum = i_combatbag-1; -- 当前背包内放入的卡片数量
				self.equipRuneNum = i_runebag-1; -- 当前背包内放入的符文数量
				if (self.equipNum>0) then
					return -- 如果当前战斗背包有卡片直接返回
				end
			end
	
			local preDeckHasItem,preDeckGUID = hasGSItem(preDeckGSID);
			local preDeckItem = ItemManager.GetItemByGUID(preDeckGUID);
			local _mpreItem = ItemManager.GetGlobalStoreItemInMemory(preDeckGSID);

			commonlib.echo("============AutoCopyCardsFrmPreDeck:preDeckItem");
			--commonlib.echo(preDeckItem);
			if(preDeckItem)then
				local clientdata = preDeckItem.clientdata or "";
				if(clientdata ~= "")then
					clientdata = commonlib.LoadTableFromString(clientdata);
					local _i_combatbag,_i_runebag=1,1;
					local _bags = {};
					local _runebags={};

					if(clientdata and type(clientdata) == "table")then
						local k;
						local _maxNum = _mpreItem.template.stats[167];
						for k = 1,_maxNum do
							_bags[k] = {gsid = 0};
						end
						local k,v;				
						for k,v in ipairs(clientdata) do
							v = tonumber(v);
							if(v)then
								--转换key
								if(v<23000 or v>24000) then
									local vhasItem = hasGSItem(v);
									if (vhasItem) then
										_bags[_i_combatbag] = {gsid = v};
										_i_combatbag = _i_combatbag + 1;
									end
								elseif(v>=23000 and v<24000) then
									local vhasItem = hasGSItem(v);
									if (vhasItem) then
										_runebags[_i_runebag] = {gsid = v};
										_i_runebag = _i_runebag + 1;
									end
								end						
							end
						end

						-- 如果原背包有卡片(_i_combatbag>1), 将原背包卡片放到当前战斗背包 self.combat_bags
						if (_i_combatbag>1) then
							local _combat_bags = {};
							local k,v;
							local totalCardsNum =1;
							local count_card={};	
													
							for k,v in ipairs(_bags) do
								if(v.gsid and v.gsid ~= 0)then
								--转换key
									if (totalCardsNum>self.maxNum) then
										break;
									end

									if (count_card[v.gsid]) then
										count_card[v.gsid]=count_card[v.gsid]+1;
									else
										count_card[v.gsid]=1;
									end
									--commonlib.echo("card:"..v.gsid..",count[v.gsid]:"..count_card[v.gsid]);
									if (count_card[v.gsid]<=self.singlecard_maxnum) then
										_combat_bags[totalCardsNum]={gsid=v.gsid};									
										totalCardsNum = totalCardsNum + 1;
									end
								end
							end
							self.combat_bags = _combat_bags;
							self.equipNum = totalCardsNum-1;

							if (self.equipRuneNum==0) then
								self.equipRuneNum = _i_runebag-1;
								self.rune_bags = _runebags;
							end


			--commonlib.echo("============AutoCopyCardsFrmPreDeck:self.combat_bags");
			--commonlib.echo(self.combat_bags);
			--commonlib.echo(self.rune_bags);

							self.Bag_Clip();
							--保存
							MyCardsManager.Bag_RemoteSave(function()
								commonlib.echo("================AutoCopyCardsFrmPreDeck: RemoteSave refresh MyCardsBagPageCtrl===========");
								if (bRefresh) then
									MyCardsManager.RefreshPage();
								end
							end)

						end -- if (_i_combatbag>1)
					end -- if(clientdata and type(clientdata)

				end -- if(clientdata ~= "")then
			end -- if(preDeckItem)then
							
		end	--if(curDeckItem)then 
	end --if(curDeckHasItem)then 

	if (self.equipNum==0) then
		return false;
	else
		return true;
	end

end

function MyCardsManager.ShowCardTip(gsid,zorder)
	local self = MyCardsManager; 
	zorder = zorder or 1;
	gsid = tonumber(gsid);
	local params = {
		url = "script/apps/Aries/Desktop/CombatCharacterFrame/CardTips.teen.html?gsid="..gsid, 
		name = "CardTips", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,	
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = zorder,
		allowDrag = true,
		enable_esc_key = true,
		directPosition = true,
			align = "_ct",
			x = -526/2,
			y = -370/2,
			width = 526,
			height = 370,
		cancelShowAnimation = true,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params)
end

function MyCardsManager.ResetSecondarySchool()
	local self = MyCardsManager;
	local s = string.format("<div style='margin-left:5px;margin-top:5px;text-align:left'>你需要重新学习辅修系的魔法吗？<br/>【注意】确定重修后，系统将扣除<font color='#ff0000'>50000</font>银币！</div>");
	_guihelper.Custom_MessageBox(s,function(result)
		if(result == _guihelper.DialogResult.Yes)then
				
			local SecondarySchoolGSID = MyCompany.Aries.Combat.GetSecondarySchoolGSID();
			local ResetSecondarySchool_exid={
				[969]=2166,[970]=2167,[971]=2168,[972]=2169,[973]=2170,[974]=2171,[975]=2172,
			}
			local exID = ResetSecondarySchool_exid[SecondarySchoolGSID];

			ItemManager.ExtendedCost(exID, nil, nil, function(msg) end, function(msg)
				if(msg.issuccess) then		
					MyCardsManager.SecondarySchoolName="";
					MyCardsManager.CardFilter="all";
					self.GetItems("combat", "all", "access plus 0 minutes", self.dsCards, nil,nil,true,new_gsid);
					local _url = string.format("script/apps/Aries/Desktop/CombatCharacterFrame/CombatCard.teen.html");
					self.ViewPageCtrl:Init(_url);
					local s = string.format("<div style='margin-left:10px;margin-top:10px;text-align:left'>恭喜你获得重新学习魔法的机会，快去学习你想辅修的魔法吧！</div>");
					_guihelper.MessageBox(s);
				else
					if (msg.errorcode==427) then
						local s = string.format("<div style='margin-left:10px;margin-top:10px;text-align:left'>你没有学习过辅修魔法！</div>");
						_guihelper.MessageBox(s);
					end
				end
			end,"none",nil,nil, 10000, function()
				_guihelper.MessageBox("网络有故障，你等一会再来吧\n");
			end);
		end
	end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no ="Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
end

function MyCardsManager.OpenSetSecondarySchoolWnd(zorder)
	local zorder=zorder or 1;
	System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/Desktop/CombatCharacterFrame/SetSecondarySchool.teen.html", 
				name = "SetSecondarySchool.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
				zorder = zorder,
				directPosition = true,
					align = "_ct",
					x = -480/2,
					y = -290/2,
					width = 480,
					height = 290,
		});	
end

function MyCardsManager.SetSecondarySchool(schoolId)
	local self = MyCardsManager;	
	local SetSecondarySchool_name={
		[969]="烈火系",[970]="寒冰系",[971]="风暴系",[972]="大地系",[973]="生命系",[974]="死亡系",[975]="通用系",
	}
	local schoolId = tonumber(schoolId);
	local SchoolName = SetSecondarySchool_name[schoolId];
	local s = string.format("<div style='margin-left:5px;margin-top:5px;text-align:left'>你确定学习<font color='#ffff00'>%s</font>魔法作为你的辅修系魔法吗？<br/>【注意】确定后，如果重修将需支付<font color='#ffff00'>50000</font>银币！</div>",SchoolName);
	_guihelper.Custom_MessageBox(s,function(result)
		if(result == _guihelper.DialogResult.Yes)then
				
			local SetSecondarySchool_exid={
				[969]=2159,[970]=2160,[971]=2161,[972]=2162,[973]=2163,[974]=2164,[975]=2165,
			}
			local exID = SetSecondarySchool_exid[schoolId];

			ItemManager.ExtendedCost(exID, nil, nil, function(msg) end, function(msg)
				if(msg.issuccess) then
					MyCardsManager.SecondarySchoolName = MyCardsManager.SecondarySchool[schoolId];
					MyCardsManager.CardFilter="all";
					self.GetItems("combat", "all", "access plus 0 minutes", self.dsCards, nil,nil,true,new_gsid);
					local _url = string.format("script/apps/Aries/Desktop/CombatCharacterFrame/CombatCard.teen.html");
					self.ViewPageCtrl:Init(_url);
					local s = string.format("<div style='margin-left:10px;margin-top:10px;text-align:left'>恭喜你学会辅修系魔法: %s！</div>",SchoolName);
					_guihelper.MessageBox(s);
				else
					if (msg.errorcode==427) then
						local s = string.format("<div style='margin-left:10px;margin-top:10px;text-align:left'>你没有达到30级！</div>");
						_guihelper.MessageBox(s);
					end
				end
			end, "none");
		end
	end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no ="Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
end

function MyCardsManager.OpenBuyNewCombatDeckWnd(zorder)
	local zorder=zorder or 1;
	System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/Desktop/CombatCharacterFrame/BuyCombatDecks.teen.html", 
				name = "BuyCombatDecks.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
				zorder = zorder,
				directPosition = true,
					align = "_ct",
					x = -480/2,
					y = -290/2,
					width = 480,
					height = 290,
		});	
end

function MyCardsManager.BuyCombatDeck(_exid,_bag_gsid,_name,_currname)
	ItemManager.ExtendedCost(_exid, nil, nil, function(msg) end, function(msg)
		if(msg.issuccess) then					
			--local s = string.format("<div style='margin-left:10px;margin-top:10px;text-align:left'>你获得了新卡包:%s</div>",_name);
			--_guihelper.MessageBox(s);
			local color = "#f8f8f8";
			local tooltip = "page://script/apps/Aries/Inventory/Cards/CardsTooltip.html?gsid=".._bag_gsid;
			local name_with_a = string.format(
				[[<a tooltip="%s" style="margin-left:0px;float:left;background:url()"><div style="float:left;margin-top:-2px;color:%s;">[%s]</div></a>]], 
				tooltip, color, _name);								
			local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
			ChatChannel.AppendChat({
						ChannelIndex = ChatChannel.EnumChannels.ItemObtain, 
						fromname = "", 
						fromschool = classprop_gsid, 
						fromisvip = false, 
						words = "你获得了新卡包: "..name_with_a,
						is_direct_mcml = true,
						bHideSubject = true,
						bHideTooltip = true,
						bHideColon = true,
					});
			MyCardsManager.RefreshPage();						
		else
			if (msg.errorcode==427) then
				local s = string.format("<div style='margin-left:10px;margin-top:10px;text-align:left'>%s不足，购买失败！</div>",_currname);
				_guihelper.MessageBox(s);
			end
		end
	end,"none",nil,nil, 10000, function()
		_guihelper.MessageBox("网络有故障，你等一会再来吧\n");
	end);	
end

function MyCardsManager.LoadRune(_filename)
	if(next(MyCardsManager.runeList)) then
		return;
	end
	local filename = _filename or "config/Aries/Cards/RuneList.teen.xml";
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	local index = 1;
	if(xmlRoot) then
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "/runelist/rune") do
			if(node.attr and node.attr.gsid and node.attr.gsid ~= "") then
				local gsid = tonumber(node.attr.gsid);
				local _,guid,_,copies=hasGSItem(gsid)
				local rune = {gsid = gsid, guid = guid or 0, copies = copies or 0};
				table.insert(MyCardsManager.runeList,rune);
				MyCardsManager.runeListMap[gsid] = {index = index};
				index = index + 1;
			end
		end
	end
	local rune_num = #MyCardsManager.runeList;
	--MyCardsManager.runeList.number = rune_num;
	if(rune_num < 49) then
		for i = rune_num + 1, 49 do
			table.insert(MyCardsManager.runeList,{gsid = 0,});
		end
	end
end

function MyCardsManager.UpdateRuneList()
	for i = 1, #MyCardsManager.runeList do
		local gsid = MyCardsManager.runeList[i]["gsid"];
		local _, _, _, copies = hasGSItem(gsid);
		MyCardsManager.runeList[i]["copies"] = copies or 0;
	end
end

function MyCardsManager.UpdateRuneInfo()
	MyCardsManager.UpdateRuneList();
	MyCardsManager.UpdateQuickRune();
end

function MyCardsManager.GetRuneList()
	if(not next(MyCardsManager.runeList)) then
		MyCardsManager.LoadRune()
	else
		MyCardsManager.UpdateRuneList()
	end
	return MyCardsManager.runeList;
end

function MyCardsManager.DS_Func_Rune(index)
	if(not next(MyCardsManager.runeList)) then
		MyCardsManager.LoadRune()
	else
		MyCardsManager.UpdateRuneList();
	end
	if(not index) then
		return #MyCardsManager.runeList;
	else
		return MyCardsManager.runeList[index];
	end
end

-- state:0 is not in combat ; 1 is in combat
function MyCardsManager.ShowRuneListPage(state,zorder)
	local params = {
		url = "script/apps/Aries/Combat/UI/MyRunes.teen.html?state="..state, 
		name = "CombatRuneTeen", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,	
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = zorder or 5,
		allowDrag = false,
		enable_esc_key = true,
		directPosition = true,
			align = "_ct",
			x = -430/2,
			y = -450/2,
			width = 430,
			height = 450,
		cancelShowAnimation = true,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params)
end

function MyCardsManager.UpdateQuickRune()
	local beChangeRunbags = false;
	local removeRuneIndex;
	local CardPickerRunesAtHandList = MsgHandler.CardPickerRunesAtHandList or {};
	for _, pair in ipairs(CardPickerRunesAtHandList) do
		local gsid = Combat.Get_gsid_from_rune_cardkey(pair.key);
		if(pair.count == 0 and MyCardsManager.quickRuneMap[gsid]) then
			removeRuneIndex = MyCardsManager.quickRuneMap[gsid]["index"];
			beChangeRunbags = true;
			break;
		end
	end
	if(beChangeRunbags) then
		table.remove(MyCardsManager.rune_bags,removeRuneIndex);
	end
	for i = (#MyCardsManager.rune_bags) + 1, 8 do
		MyCardsManager.rune_bags[i] = {gsid = 0};
	end
	local count = 0;
	MyCardsManager.quickRuneMap = {};
	for i = 1,#MyCardsManager.rune_bags do
		local gsid = MyCardsManager.rune_bags[i]["gsid"];
		if(gsid ~= 0) then
			local _,_,_,copies=hasGSItem(gsid)
			MyCardsManager.rune_bags[i]["copies"] = copies;
			MyCardsManager.quickRuneMap[gsid] = {index = i};
			count = count + 1;
		end
	end
	MyCardsManager.equipRuneNum = count;
end