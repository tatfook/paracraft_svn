--[[
Title: 30413_MagicPocket
Author(s): Spring
Date: 2010/12/2
use the lib:
------------------------------------------------------------
script/apps/Aries/NPCs/MagicMoneyBox/30413_MagicPocket.lua
------------------------------------------------------------
]]

-- create class
local libName = "MagicPocket";
local MagicPocket=commonlib.gettable("MyCompany.Aries.Quest.NPCs.MagicPocket");
local VIP = commonlib.gettable("MyCompany.Aries.VIP");
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function MagicPocket.main()
	local self = MagicPocket; 
end

function MagicPocket.Init()
	local gift_item=System.SystemInfo.GetField("MagicPocket") or {};
	local i,_prob=1,0;
	local input_path="config/Aries/VIP/MagicStar_gifts.xml";
	if (table.maxn(gift_item) ==0) then
		local xmlRoot = ParaXML.LuaXML_ParseFile(input_path);
	
		for node in commonlib.XPath.eachNode(xmlRoot, "/MagicStar_Gifts/gift") do
			local item={};
			if(node.attr)then		
				item.gsid = tonumber(node.attr.gsid);
				item.prob = tonumber(node.attr.prob);				
				item.exid = tonumber(node.attr.exid);
				_prob=_prob + item.prob*100;
				item.problvl = _prob;
			end
			i=i+1;
			table.insert(gift_item,item);
		end
		System.SystemInfo.SetField("MagicPocket", gift_item);
	end
end

function MagicPocket.getgiftNum(mlel)
	local gift_take, gift_num;
	if(not mlel) then
		local bean = MyCompany.Aries.Pet.GetBean();
		if(bean) then
			if (bean.mlel) then
				mlel=bean.mlel;
			end
		end    
	end
    local bVIP=VIP.IsVIP();
    if (bVIP) then
        gift_take = ItemManager.GlobalStoreObtainCounts[50317];
        gift_num = mlel+1-gift_take.inweek;
    else
        gift_num = 0;
    end;

    if (gift_num<0) then
        gift_num=0;
    end;
    return gift_num;
end

function MagicPocket.GetGift()
	local gift_item = System.SystemInfo.GetField("MagicPocket");
	local n=table.maxn(gift_item)-1;
	local gift={};
	local j;

	math.randomseed(ParaGlobal.GetGameTime());
	local r = math.random(10000);
	for j=1,n-1 do
		if (gift_item[j].problvl <= r and gift_item[j+1].problvl > r ) then
		--	gift=gift_item[j].gsid;
			gift=gift_item[j];
			break;
		end
	end
	return gift;
end

function MagicPocket.DS_Func(index)
	local gift_item = System.SystemInfo.GetField("MagicPocket");	

	if(index == nil) then
		return #(gift_item);
	else
		return gift_item[index];
	end	
end

function MagicPocket.ShowPage(zorder)
	local self = MagicPocket; 
	
	System.App.Commands.Call("File.MCMLWindowFrame", {
	url = "script/apps/Aries/NPCs/MagicMoneyBox/30413_MagicPocket.html", 
	name = "GetGiftFromMagicPocket", 
	app_key=MyCompany.Aries.app.app_key, 
	isShowTitleBar = false,
	DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
	style = CommonCtrl.WindowFrame.ContainerStyle,
	zorder = zorder or 1,
	allowDrag = false,
	isTopLevel = true,
	directPosition = true,
		align = "_ct",
		x = -800/2,
		y = -500/2,
		width = 800,
		height = 500,
	})
end