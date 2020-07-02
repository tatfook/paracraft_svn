--[[
Title: 
Author(s): zrf
Date: 2010/12/28
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30416_WoodenEntrance.lua");
------------------------------------------------------------
]]


local WoodenEntrance = commonlib.gettable("MyCompany.Aries.Quest.NPCs.WoodenEntrance");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function WoodenEntrance.Init()
	WoodenEntrance.page = document:GetPageCtrl();
end

function WoodenEntrance.HasMedal(index)
	index = tonumber(index);
	local gsid = 20024 + index;
	return hasGSItem(gsid);
end

WoodenEntrance.floors= { 7, 25, 60, 100, };

function WoodenEntrance.ShowMedal()
	local i;
	for i=1,4 do
		if(not WoodenEntrance.HasMedal(i))then
			return i;
		end
	end
end

function WoodenEntrance.OnClickGetMedal(index)
	index = tonumber(index);
	local gsid = 20024 + index;
	local gsitem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	local name = "";
	if(gsitem)then
		name = gsitem.template.name;
	end

	local bhas,_,__,count = hasGSItem(50333);
	--commonlib.echo("!!!!!!!!!!!!!!:OnClickGetMedal 0");
	--commonlib.echo(count);
	--commonlib.echo(WoodenEntrance.floors[index]);

	if( not count or count < WoodenEntrance.floors[index])then
		_guihelper.MessageBox(string.format([[<div style="margin-left:20px;margin-top:20px">要获得%s徽章，需要打到试炼之塔的第%d层才可以哦！继续加油吧！</div>]], name, WoodenEntrance.floors[index]));
		return;
	end
	local exid = 664 + index;
	ItemManager.ExtendedCost(exid, nil, nil, function(msg)end, function(msg)
		if(msg and msg.issuccess == true)then
			if(WoodenEntrance.page)then
				WoodenEntrance.page:Refresh(0.01);
			end
			_guihelper.MessageBox(string.format( [[<div style="margin-left:20px;margin-top:20px">恭喜你获得%s徽章，在资料面板中可以看到它哦！</div>]], name) );
		end
	end);
end

function WoodenEntrance.GetFloor()
	local bhas,_,__,count = hasGSItem(50333);
	if(bhas and count)then
		return count;
	else
		return 0;
	end
end

function WoodenEntrance.main()

end

function WoodenEntrance.PreDialog()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	-- show the panel
    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/NPCs/TownSquare/30416_WoodenEntrance_Panel.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "30416_WoodenEntrance_Panel", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -655/2,
            y = -512/2,
            width = 655,
            height = 512,
    });
	System.SendMessage_obj({type = System.msg.OBJ_DeselectObject, obj = nil});
	return false;
end