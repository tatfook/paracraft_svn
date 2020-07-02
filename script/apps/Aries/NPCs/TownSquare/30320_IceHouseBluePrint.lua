--[[
Title: IceHouseBluePrint
Author(s): WangTian
Date: 2009/8/20

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30320_IceHouseBluePrint.lua
------------------------------------------------------------
]]

-- create class
local libName = "IceHouseBluePrint";
local IceHouseBluePrint = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.IceHouseBluePrint", IceHouseBluePrint);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;


-- 17038_IceHouseBluePrint 冰雪小屋的图纸
function IceHouseBluePrint.main()
	
end



function IceHouseBluePrint.PreDialog()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30320);
	memory.dialog_state = nil;
	if(IceHouseBluePrint.HasOutOfDate())then
		memory.dialog_state = 1;
	elseif(IceHouseBluePrint.HasIceHouseBluePrint())then
		memory.dialog_state = 2;	
	else
		IceHouseBluePrint.GetBluePrint();
		return true;
	end
end

function IceHouseBluePrint.HasIceHouseBluePrint()
	 return hasGSItem(17038);--是否已经有冰雪小屋的图纸
end
--是否已经过期
function IceHouseBluePrint.HasOutOfDate()
	local today = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local outofdate = "2010-01-15";
	today = IceHouseBluePrint.GetDateFromString(today);
	outofdate = IceHouseBluePrint.GetDateFromString(outofdate);
	commonlib.echo("=================IceHouseBluePrint.HasOutOfDate");
	commonlib.echo(today);
	commonlib.echo(outofdate);
	if(today and outofdate)then
		if(today < outofdate)then
			return false;
		end
	end
	return true;
end
--转换日期为数值 2009-12-16 to 20091216 
function IceHouseBluePrint.GetDateFromString(date)
	if(not date)then return end
	local year, month, day = string.match(date, "^(%d+)%-(%d+)%-(%d+)$");
	if(year and month and day)then
		local result = year..month..day;
		result = tonumber(result);
		return result
	end
end
--获取图纸
function IceHouseBluePrint.GetBluePrint()
	if(not IceHouseBluePrint.HasIceHouseBluePrint())then
		ItemManager.PurchaseItem(17038, 1, function(msg) end, function(msg) 
			log("+++++++Purchase item 17038_IceHouseBluePrint return: +++++++\n")
			commonlib.echo(msg);
			IceHouseBluePrint.ShowPanel();
		end);
	end
end
function IceHouseBluePrint.ShowPanel()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	-- show the panel
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/NPCs/TownSquare/30320_IceHouseBluePrint_panel.html", 
		app_key = MyCompany.Aries.app.app_key, 
		name = "30320_IceHouseBluePrint_panel", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = style,
		zorder = 2,
		allowDrag = false,
		isTopLevel = true,
		directPosition = true,
			align = "_ct",
			x = -920/2,
			y = -515/2,
			width = 920,
			height = 515,
	});
end





