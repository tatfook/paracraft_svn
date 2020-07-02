--[[
Title: defines data entity and interface for trade client
Add by:WD
Company: ParaEnging Co.
Date: 2011/10/11
--]]
NPL.load("(gl)script/apps/GameServer/TradeService/GSL_TradeClient.lua");

if(System.options.version =="kids" or not System.options.version or System.options.version == "")then
	NPL.load("(gl)script/apps/Aries/Trade/TradeClientPage.kids.lua");
elseif(System.options.version =="teen")then
	NPL.load("(gl)script/apps/Aries/Trade/TradeClientPage.teen.lua");
end

NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
NPL.load("(gl)script/apps/GameServer/TradeService/GSL_TradeData.lua");
local TradeMSG = commonlib.gettable("Map3DSystem.GSL.Trade.TradeMSG")

local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");
local trade_container = commonlib.gettable("Map3DSystem.GSL.Trade.trade_container");
local TradeClient = commonlib.gettable("MyCompany.Aries.Trade.TradeClient");
local trade_transaction = commonlib.gettable("Map3DSystem.GSL.Trade.trade_transaction");
local ItemManager = Map3DSystem.Item.ItemManager;
local GetItemByID = ItemManager.GetGlobalStoreItemInMemory;
local GetItemsCount = ItemManager.GetItemCountInBag;
local hasGSItem = ItemManager.IfOwnGSItem;
local MSG = _guihelper.MessageBox;

TradeClient.MAX_SLOTS = 6;
TradeClient.trade_canceled = false;
TradeClient.partner_accepted = nil;
TradeClient.can_shake = false;

function TradeClient:Init(partner_nid)
	self.trade_transaction = trade_transaction:new();
	self.trade_transaction:add_player(partner_nid);
	self.trade_container1 = self.trade_transaction.trad_cont1;
	self.trade_container2 = self.trade_transaction.trad_cont2;
	
	TradeClient.initialized = true;
	--for local use
	TradeClient.SendData = trade_container:new();
	TradeClient.ReceiveData = trade_container:new();

	self.partner_nid = tonumber(partner_nid);
end

function TradeClient:RegisterEventHandler()
	self.tradeclient = Map3DSystem.GSL.Trade.GSL_TradeClient.GetSingleton();
	self.tradeclient:AddEventListener("on_trade_request", function(self,msg)
		if(msg.from_nid and not TradeClient.partner_nid) then
			--if is trading,cannot trade with others
			_guihelper.CloseMessageBox(true);
			_guihelper.CloseCustom_MessageBox();
			--TODO:20s check
			TradeClient.can_shake = false;
			TradeClient.timer = TradeClient.timer or commonlib.Timer:new({callbackFunc = function(timer)
					timer:Change();
					if(not TradeClient.can_shake)then
						_guihelper.CloseMessageBox(true);
						_guihelper.CloseCustom_MessageBox();
						_guihelper.MessageBox("接受交易请求已超时。");
						return;
					end
			end});
			TradeClient.timer:Change(20000);
			
			NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
			local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
			if(MsgHandler.IsInCombat()) then
				TradeClient.can_shake = true;
				-- reject the trade request if user in in combat
				TradeClient.tradeclient:RejectTrade();
				TradeClient.partner_accepted = false;
				return;
			end

			NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
			
			_guihelper.Custom_MessageBox(string.format([[来自<pe:name nid='%s' useyou="false" linked="false" />(%s)的交易请求。]],msg.from_nid,msg.from_nid), function(res)
					TradeClient.can_shake = true;
					if(res and res == _guihelper.DialogResult.Yes) then
						NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
						local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
						local can_pass = DealDefend.CanPass(function()
							TradeClient.tradeclient:AcceptTrade(); 
							TradeClient.partner_accepted = true;
							MyCompany.Aries.Trade.TradeClientPage.ShowPage(msg.from_nid,true);
						end);

						if(not can_pass) then
							--TradeClient.tradeclient:RejectTrade();
							--TradeClient.partner_accepted = false;
						else
							TradeClient.tradeclient:AcceptTrade(); 
							TradeClient.partner_accepted = true;
							MyCompany.Aries.Trade.TradeClientPage.ShowPage(msg.from_nid,true);
						end
					else
						TradeClient.tradeclient:RejectTrade();
						TradeClient.partner_accepted = false;
						--MyCompany.Aries.Trade.TradeClient.trade_canceled = true;
						--MyCompany.Aries.Trade.TradeClient:Clean();
					end
			end, _guihelper.MessageBoxButtons.YesNo,{show_label = true, yes = "接受", no = "拒绝"});
		elseif(msg.from_nid and TradeClient.partner_nid and msg.from_nid ~= TradeClient.partner_nid) then
			--TODO:trade request is from third partner.
			--TODO:before partner accepted,request third partner.
		end
	end);

	local tc = self;
	self.tradeclient:AddEventListener("on_trade_update", function(self,msg)
		if(msg.trad_trans) then
			-- this is the trade_transaction class instance, one can call its methods. 
			-- TODO: trandlate data and refresh page
			--commonlib.echo("=============on_trade_update================");
			--commonlib.echo(msg.trad_trans);
			TradeClient.trade_container1,TradeClient.trade_container2 =TradeClient.tradeclient:get_containers();
			--commonlib.echo("from server to client:TradeClient.trade_container1")
			--commonlib.echo(TradeClient.trade_container1)
			--commonlib.echo("from server to client:TradeClient.trade_container2")
			--commonlib.echo(TradeClient.trade_container2)
			if(not TradeClient.SendData or not TradeClient.ReceiveData) then
				return
			end
			
			TradeClient.SendData.money = TradeClient.trade_container1.money;
			TradeClient.SendData.is_confirmed = TradeClient.trade_container1.is_confirmed;
			TradeClient.SendData.is_ok = TradeClient.trade_container1.is_ok;
			TradeClient.SendData.items = {};

			TradeClient.ReceiveData.money = TradeClient.trade_container2.money;
			TradeClient.ReceiveData.is_confirmed = TradeClient.trade_container2.is_confirmed;
			TradeClient.ReceiveData.is_ok = TradeClient.trade_container2.is_ok;
			TradeClient.ReceiveData.items = {};

			local i,v;
			for i,v in ipairs(TradeClient.trade_container1.items)do
				local item_table = MyCompany.Aries.Trade.TradeClientPage:BuildDisplayTable(tonumber(v[3]),tonumber(v[1]),nil,nil,v[2]);
				if(item_table)then
					table.insert(TradeClient.SendData.items,item_table);
				end
			end
			
			for i,v in ipairs(TradeClient.trade_container2.items)do
				local item_table = MyCompany.Aries.Trade.TradeClientPage:BuildDisplayTable(tonumber(v[3]),tonumber(v[1]),nil,nil,v[2]);
				if(item_table)then
					table.insert(TradeClient.ReceiveData.items,item_table);
				end
			end

			--compare receive items with transaction
			MyCompany.Aries.Trade.TradeClientPage:Update();

		elseif(msg.is_cancel) then
			-- trade canceled
			--commonlib.echo("=============trade canceled================");
			if(not TradeClient.trade_canceled)then
				if(MyCompany.Aries.Trade.TradeClientPage:IsVisible())then
					_guihelper.MessageBox("交易已取消。");
					TradeClient.trade_canceled = true;
					MyCompany.Aries.Trade.TradeClientPage:CloseWindow();
				end
				
			end
			
		elseif(msg.is_complete) then
			-- trade completed
			--commonlib.echo("=============trade completed================");
			_guihelper.MessageBox("交易完成");
			MyCompany.Aries.Trade.TradeClientPage:CloseWindow();
			
			tc:OnTradeComplete(msg);

		elseif(msg.is_failed) then
			-- trade failed
			--commonlib.echo("=============trade failed================");
			local errorcode = msg.errorcode;
			local reason;
			if(errorcode == 424) then
				reason = "有一方的物品超过了最多可拥有的数量";
			elseif(errorcode == 497) then
				reason = "用来交换的物品不存在";
			elseif(errorcode == 493) then
				reason = "参数错误";
			elseif(errorcode == 445) then
				reason = "用户没有验证安全密码";
			end
			_guihelper.MessageBox(format("交易失败了<br/>原因:%s", reason or tostring(errorcode)));
			MyCompany.Aries.Trade.TradeClientPage:CloseWindow();	
		end
	end);
end

-- after trade is complete, we need to update the items and call the hooks and update UI accordingly. 
function TradeClient:OnTradeComplete(msg)
	local updates, adds;
	if(msg.nid0 == tostring(System.User.nid)) then
		updates = msg.ups0;
		adds = msg.adds0;
	else
		updates = msg.ups1;
		adds = msg.adds1;
	end
	local items_to_add = ItemManager.UpdateBagItems(updates, adds);
	--update magic bean within bag
	--ItemManager.GetItemsInBag( 0, "0", function(msg)end, "access plus 0 minutes");

	--if(items_to_add) then
		---- via user interface
		--MyCompany.Aries.Desktop.Dock.OnExtendedCostNotification({adds = items_to_add})
	--end
end

-- callback
function TradeClient:AcceptRequestTrade(partner_nid,callback)
	TradeClient.tradeclient:RequestTradeWith(partner_nid,function(bSucceed)
		if(bSucceed)then
			if(callback and type(callback) == "function")then
				--print("MyCompany.Aries.Trade.TradeClient.partner_nid:" .. (MyCompany.Aries.Trade.TradeClient.partner_nid or "nil"));
				callback(MyCompany.Aries.Trade.TradeClient.partner_nid,true);
			end
			--not show dialog after other accepted
			--[[
			_guihelper.MessageBox(string.format("%s接受了你的交易请求。",MyCompany.Aries.Trade.TradeClient.partner_nid),function(res)
				if(res and res == _guihelper.DialogResult.Yes) then
					if(callback)then
						callback(MyCompany.Aries.Trade.TradeClient.partner_nid,true);
					end
				else
					MyCompany.Aries.Trade.TradeClient.trade_canceled = true;
					MyCompany.Aries.Trade.TradeClient.tradeclient:SendMessage(TradeMSG.TRADE_CANCEL, {from_nid= Map3DSystem.User.nid,});
				end
			end, _guihelper.MessageBoxButtons.YesNo);
			]]
			
		else
			_guihelper.MessageBox(string.format([[<pe:name nid='%s' useyou="false" linked="false" />(%s)拒绝了你的交易请求。]],MyCompany.Aries.Trade.TradeClient.partner_nid,MyCompany.Aries.Trade.TradeClient.partner_nid));
			MyCompany.Aries.Trade.TradeClientPage.can_shake = true;
			MyCompany.Aries.Trade.TradeClient.trade_canceled = true;
			MyCompany.Aries.Trade.TradeClient:Clean();
		end
	end);
end

function TradeClient:SendItemUpdate()
	-- TODO: Translate data to trad_cont
	if(self.tradeclient) then
		--self.trade_container1.nid = self.SendData.nid;
		self.trade_container1.money = self.SendData.money;
		self.trade_container1.is_confirmed = self.SendData.is_confirmed;
		
		if(not self.trade_container1.is_confirmed)then
			self.SendData.is_ok = false;
		end

		self.trade_container1.is_ok = self.SendData.is_ok;

		local i,v;
		if(self.trade_container1.money and self.trade_container1.money > 0)then
			local bhas,copies;
			for i,v in ipairs(self.SendData.items)do
				if(v.gsid == 984)then
					bhas = true;	
					if(v.copies ~= self.trade_container1.money)then
						if(not self.trade_container1.money or self.trade_container1.money == 0)then
							table.remove(self.SendData.items,i);
						else
						v.copies = self.trade_container1.money
						end
					end
					break;
				end
			end
			
			if(not bhas)then	
				local __,guid,__,copies = hasGSItem(984);
				table.insert(self.SendData.items,{gsid = 984,guid =guid,copies = self.trade_container1.money});	
			end
		end

		self.trade_container1.items = {};
		for i,v in ipairs(self.SendData.items)do
			local item = {v.guid,v.copies, v.gsid,v.server_data};
			--local item = {v.guid,v.copies, 17213 or v.gsid,v.server_data}; -- test fake gsid
			table.insert(self.trade_container1.items,item);	
		end

		--commonlib.echo("from client to server:self.trade_container1========================")
		--commonlib.echo(self.trade_container1)
		self.trade_container1.money = 0
		self.tradeclient:SendItemsUpdate(self.trade_container1);
	end
end

function TradeClient:CheckItem(gsid)
	if(self and self.ReceiveData and #self.ReceiveData.items > 0)then
		local items = self.ReceiveData.items;
		local i,v;
		for i,v in ipairs(items)do
			if(v.gsid == gsid)then
				return true
			end
		end
	end
	return false;
end

function TradeClient:CalcMoney()
	self.SendData.money = self.SendData.money or 0;
	local commission = self.SendData.money * 5 / 100;
	if(commission > 0  and commission < 1)then 
		commission = 1;
	else
		local i,f = math.modf(commission);
		if(type(f) == "number" and f > 0)then
			commission = i + 1;
		end
	end
	
	if(TradeClient.GetMagicBean() < (commission + self.SendData.money))then
		MSG("你的魔豆不足以进行本次交易。");
		return 
	end
	return commission;
end

function TradeClient:TradeDone()
	if(System.options.version == "teen")then
		self:SetDone(true);
		self:SendItemUpdate();
		return;
	end
	local receive_money;
	local send_money = self.SendData.money;
	local receive_items = self.ReceiveData.items;
	local item;
	for i = 1, #receive_items do
		item = receive_items[i];
		if(item.gsid == 984) then
			receive_money = item.copies;
			break;
		end
	end	
	local words = "";
	if(send_money or receive_money) then
		local receive_words = "";
		local send_words = "";
		if(receive_money and (receive_money ~= 0 or receive_money ~= "0")) then
			receive_words = string.format("<div>获得<font style = 'font-size:14px;base-font-size:14;font-weight:bold;color:#FF0000;'>%d</font>魔豆</div>",receive_money);
		end
		if(send_money and (send_money ~= 0 or send_money ~= "0")) then
			send_words = string.format("<div>失去<font style = 'font-size:14px;base-font-size:14;font-weight:bold;color:#FF0000;'>%d</font>魔豆</div>",send_money);
		end
		words = string.format("<div>本次交易：</div>%s%s<br/>是否确定交易？",receive_words,send_words);
		_guihelper.MessageBox(words,function(result)
			if(result == _guihelper.DialogResult.Yes) then
				self:SetDone(true);
				self:SendItemUpdate();	
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	else
		self:SetDone(true);
		self:SendItemUpdate();
	end	
	--self:SetDone(true);
	--self:SendItemUpdate();
end

function TradeClient:Clean()
	if(not self.trade_canceled)then	
		--commonlib.echo("send cancel msg.");
		self.tradeclient:CancelTrade();--player cancel trade operation.
	end
	self.trade_container1 = nil;
	self.trade_container2 = nil;
	self.trade_transaction = nil;
	self.SendData = nil;
	self.ReceiveData = nil;
	self.initialized = nil;
	self.trade_canceled = nil;
	self.partner_accepted = nil;
	self.partner_nid = nil;
	self.can_shake = true;
	self.timer = nil;
end

--@return:send data components is returned.
function TradeClient:GetSendDataProperties()
	if(self.SendData)then
		--commonlib.echo(self.SendData);
		return self.SendData.money,self.SendData.items,self.SendData.is_confirmed,self.SendData.is_ok;
	end
	return 0;
end

function TradeClient:GetReceiveDataProperties()
	if(self.ReceiveData)then
		return self.ReceiveData.money,self.ReceiveData.items,self.ReceiveData.is_confirmed,self.ReceiveData.is_ok;
	end
	return 0;
end

function TradeClient:SetSendGoods(goods,j)
	if(goods)then
		local i,v;

		if(not j)then
			table.insert(self.SendData.items,goods);
		end

		self.trade_container1.items = {};
		for i,v in ipairs(self.SendData.items)do
			local item = {v.guid,v.copies,v.gsid, v.server_data};
			table.insert(self.trade_container1.items,item);	
		end
		--commonlib.echo("self.trade_container1.items");
		--commonlib.echo(self.trade_container1.items);
	end
end

function TradeClient:GetSendDataProperties2()
	local money,is_confirmed,is_ok;
	if(self.SendData)then
		if(self.SendData.money == 0 or not self.SendData.money)then
			money = "";
		else
			money = self.SendData.money; 
		end

		is_confirmed = self.SendData.is_confirmed or false;
		is_ok = self.SendData.is_ok or false;
		return money,is_confirmed,is_ok;
	end
	return nil;
end

function TradeClient:GetReceiveDataProperties2()
	local money,is_confirmed,is_ok;
	if(self.ReceiveData)then
		if(self.ReceiveData.money == 0 or not self.ReceiveData.money)then
			money = "";
		else
			money = self.ReceiveData.money; 
		end

		is_confirmed = self.ReceiveData.is_confirmed or false;
		is_ok = self.ReceiveData.is_ok or false;
		return money,is_confirmed,is_ok;
	end
	return nil;
end

function TradeClient.GetMagicBean()
    local __,__,__,copies = hasGSItem(984);
    copies = copies or 0;
    return copies;
end

function TradeClient:SetPay(money)
	if(money)then
		if(type(money) == "string" and type(tonumber(money)) == "number")then
			self.SendData.money = tonumber(money); 
		elseif(type(money) == "number" )then 
			self.SendData.money = money; 
		end
	end
end

--if two sides trade is completed,may not be change complete state
function TradeClient:SetLock() 
	self.SendData.is_confirmed = not self.SendData.is_confirmed;
	if(not self.SendData.is_ok or not self.ReceiveData.is_ok)then
		self:SetDone(false);
	end
end

function TradeClient:SetDone(is_ok) 
	self.SendData.is_ok  = is_ok;
end

function TradeClient:GetTradePartner()
	return self.partner_nid;
end

--[[
	check whether has data to sent,if not return false
]]
function TradeClient:CheckSendData()
	if((self.SendData.money == 0 or self.SendData.money == "" or not self.SendData.money) and #self.SendData.items == 0)then
		return false;
	end
	return true;
end

