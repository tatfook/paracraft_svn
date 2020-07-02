--[[
Title: HaqiAmbassador
Author(s): Leio
Date: 2009/12/7

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Ambassador/30132_HaqiAmbassador.lua");
MyCompany.Aries.Quest.NPCs.HaqiAmbassador.ShowPanelOnRightBtn()
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
NPL.load("(gl)script/kids/3DMapSystemApp/API/activationkeys/paraworld.activationkeys.lua");
NPL.load("(gl)script/apps/Aries/NPCs/Ambassador/30132_HaqiAmbassador_panel.lua");
-- create class
local libName = "HaqiAmbassador";
local HaqiAmbassador = {
	hasTakeCode = false,
	canTakeCode = false,
	codeList = nil,--激活码列表
	fruitsNum = 0,--红心果数量
	friendsNum = 0,--传播数量
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.HaqiAmbassador", HaqiAmbassador);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- HaqiAmbassador.main
function HaqiAmbassador.main()
	-- refresh the quest icon
	--local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	--QuestArea.AppendQuestStatus("script/apps/Aries/NPCs/Ambassador/30132_HaqiAmbassador_panel.html", 
		--"normal", "Texture/Aries/Item/50187_RedHeartFruit.png", "大使任务", nil, 1, nil, function()
			--HaqiAmbassador.ShowPage();
		--end);
end

function HaqiAmbassador.PreDialog()
	local self = HaqiAmbassador;
	self.hasTakeCode = false;
	self.canTakeCode = false;
	self.codeList = nil;
	self.fruitsNum = 0;
	self.friendsNum = 0;
end
function HaqiAmbassador.GetAllInfo(callbackFunc)
	local self = HaqiAmbassador;
	Map3DSystem.Item.ItemManager.GetItemsInBag(30132, "ActivationKeyBag", function(msg)
		--标识是否 已经领取过激活码
		self.LoadActivationKeyItem();
		self.GetFruitsNum();--获取红心果数量
		self.GetFriendsNum();--获取传播给好友的数量
		
		--加载坐骑的数据
		local bean = MyCompany.Aries.Pet.GetBean();
		if(bean) then
			local level = bean.level or 0;
			if(level > 2)then
				self.canTakeCode = true;
			else
				self.canTakeCode = false;
			end
		end
		----加载获取体验码的数据
		--self.LoadCode(function(msg)
			--if(msg and msg.issuccess)then
				----加载坐骑的数据
				--self.LoadPet(function(msg)
					--if(msg and msg.issuccess)then
						--commonlib.echo("======================HaqiAmbassador.PreDialog1");
					--end
				--end)
			--end
		--end)
		if(callbackFunc and type(callbackFunc) == "function")then
			callbackFunc();
		end
	end, "access plus 0 day");
end
--刷新bag
function HaqiAmbassador.RefreshBag(callbackFunc)
	Map3DSystem.Item.ItemManager.GetItemsInBag(30132, "ActivationKeyBag", function(msg)
		if(callbackFunc and type(callbackFunc) == "function")then
			callbackFunc();
		end
	end, "access plus 20 minutes");
end
--获取红心果数量
function HaqiAmbassador.GetFruitsNum()
	local self = HaqiAmbassador;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	--local gsid = 50187;
	local gsid = 50337;
	local bHas, guid = hasGSItem(gsid);
	local count = 0;
	local item;
	if(bHas == true) then
		item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			count = item.copies;
		end
	end
	self.fruitsNum = count;
	return count;
end
--获取传播给好友的数量
function HaqiAmbassador.GetFriendsNum()
	local self = HaqiAmbassador;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	--local gsid = 50328;
	local gsid = 50339;--热心果
	local bHas, guid, __, count= hasGSItem(gsid);
	count = count or 0;
	--local item;
	--if(bHas == true) then
		--item = ItemManager.GetItemByGUID(guid);
		--if(item and item.guid > 0) then
			--count = item.copies;
		--end
	--end
	--count = count + self.GetFruitsNum();
	self.friendsNum = count;
	return count;
end
--加载标识 是否领取激活码的 item
function HaqiAmbassador.LoadActivationKeyItem()
	local self = HaqiAmbassador;
	local gsid = 50194;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local bHas, guid = hasGSItem(gsid);
	local count = 0;
	if(bHas == true) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			count = item.copies;
		end
	end
	if( count > 0)then
		self.hasTakeCode = true;--标识已经领取过激活码
	end
end
--加载获取体验码的数据
function HaqiAmbassador.LoadCode(callbackFunc)
	local self = HaqiAmbassador;
	local nid = Map3DSystem.User.nid;
	local msg = {
		nid = nid,
	}
	commonlib.echo("before load activationkeys");
	commonlib.echo(msg);
	paraworld.activationkeys.GetActivationKeys(msg,"GetActivationKeys ",function(msg)
		commonlib.echo("after load activationkeys");
		commonlib.echo(msg);
		self.codeList = msg.list;--激活码列表
		if(callbackFunc and type(callbackFunc) == "function")then
			callbackFunc({
				issuccess = true,
			});
		end
	end);
end
--加载坐骑的数据
function HaqiAmbassador.LoadPet(callbackFunc)
	local self = HaqiAmbassador;
	local ItemManager = System.Item.ItemManager;
	local level = MyCompany.Aries.Player.GetDragonLevel();
	if(level > 2)then
		self.canTakeCode = true;
	else
		self.canTakeCode = false;
	end
	if(callbackFunc and type(callbackFunc) == "function")then
		callbackFunc({
			issuccess = true,
		});
	end
end
--是否已经领取过体验码
function HaqiAmbassador.HasTakeCode()
	local self = HaqiAmbassador;
	return self.hasTakeCode;
end
--是否可以领取体验码
function HaqiAmbassador.CanTakeCode()
	local self = HaqiAmbassador;
	return self.canTakeCode;
end
function HaqiAmbassador.ShowPanel(from, to)
	local self = HaqiAmbassador;
	if((from == 2 and to == 10) or (from == 3 and to == 10))then
	
		self.LoadCode(function(msg)
			self.ShowPanelPage(2);
		end);
	elseif(from == 1 and to == 3)then
		self.TakeCode();
	elseif(from == 5 and to == -1)then
		
		self.LoadCode(function(msg)
			self.ShowPanelPage(2);
		end);
	end
end
function HaqiAmbassador.ShowPanelPage(state)
	local self = HaqiAmbassador;
	MyCompany.Aries.Quest.NPCs.HaqiAmbassador_panel.Bind(state,self.codeList,self.fruitsNum,self.friendsNum);
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	-- show the panel
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/NPCs/Ambassador/30132_HaqiAmbassador_panel.html", 
		app_key = MyCompany.Aries.app.app_key, 
		name = "30132_HaqiAmbassador_panel", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = style,
		zorder = 2,
		allowDrag = false,
		isTopLevel = true,
		directPosition = true,
			align = "_ct",
			x = -855/2,
			y = -561/2,
			width = 855,
			height = 561,
	});
end
--领取体验码
function HaqiAmbassador.TakeCode()
	local gsid = 50194;
	local gsid_key = "50194_ActivationKeyFetched";
	local ItemManager = System.Item.ItemManager;
	ItemManager.PurchaseItem(gsid,1,function(msg)
		
	end,function(msg) 
		if(msg) then
			log("+++++++Purchase "..gsid_key.." return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				
				self.hasTakeCode = true;
				
			end
		end
	end, nil, "none");
end
--直接显示面板
function HaqiAmbassador.ShowPanelOnRightBtn()
	local self = HaqiAmbassador;
	self.GetAllInfo(function()
		self.LoadCode(function(msg)
			local state = 2;
			--if(not self.canTakeCode or not self.hasTakeCode)then
				--state = 0;
			--end
			self.ShowPanelPage(state);
		end);
	end)
	
end

function HaqiAmbassador.ShowPage()
	local self = HaqiAmbassador;
	Map3DSystem.Item.ItemManager.GetItemsInBag(30132, "ActivationKeyBag", function(msg)
		self.GetFruitsNum();--获取红心果数量
		self.GetFriendsNum();--获取传播给好友的数量
		self.ShowPanelPage(2)
	end, "access plus 0 day");
end
function HaqiAmbassador.CanShow()
	local region_id = ExternalUserModule:GetRegionID();
	if(region_id == 0)then
		return true;
	end
end