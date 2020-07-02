--[[
Title: code behind for page SetCardBagName.html
Author(s): Spring
Date: 2011/10/18
Desc:  script/apps/Aries/Desktop/CombatCharacterFrame/SetCardBagName.lua
Use Lib:
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/SetCardBagName.lua");
-------------------------------------------------------
-------------------------------------------------------
]]
local SetCardBagName = commonlib.gettable("MyCompany.Aries.Inventory.Cards.SetCardBagName");
local ItemManager = System.Item.ItemManager;
local item_name, item_gsid;
local system_cardbaginfo = commonlib.createtable("MyCompany.Aries.Inventory.Cards.SetCardBagName.system_cardbaginfo", {});
local page;
function SetCardBagName.OnInit()
	if (not SetCardBagName.IsInited) then
		local cardbag_info={};
		local filepath = string.format("config/cardbaginfo_%s.txt",System.User.nid);
		if(ParaIO.DoesFileExist(filepath)) then
			cardbag_info = commonlib.LoadTableFromFile(filepath);
		end
		if(next(cardbag_info)~=nil) then
			commonlib.partialcopy(system_cardbaginfo,cardbag_info);			
		end
		SetCardBagName.IsInited = true;
	end	
end

function SetCardBagName.SaveBagInfo(cardbag_info)
	local filepath = string.format("config/cardbaginfo_%s.txt",System.User.nid);
	commonlib.partialcopy(system_cardbaginfo,cardbag_info);	

	if(not ParaIO.DoesFileExist(filepath)) then
		if(ParaIO.CreateNewFile(filepath))then
			commonlib.SaveTableToFile(cardbag_info, filepath);
			ParaIO.CloseFile();
		end
	else
		commonlib.SaveTableToFile(cardbag_info, filepath);
	end
	page:Refresh(0.01);
	--local scardbag_info = commonlib.gettable("MyCompany.Aries.Inventory.Cards.SetCardBagName.system_cardbaginfo");
	--commonlib.echo("==============scardbag_info3");
	--commonlib.echo(scardbag_info);
end

function SetCardBagName.Show(gsid,pageCtrl)
	page = pageCtrl;
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/Desktop/CombatCharacterFrame/SetCardBagName.html?baggsid="..gsid, 
		name = "SetCardBagName", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 10,
		allowDrag = false,
		isTopLevel = true,
		directPosition = true,
			align = "_ct",
			x = -466/2,
			y = -256/2,
			width = 466,
			height = 255,
		});
end

