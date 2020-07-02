--[[
Title: 
Author(s): leio
Date: 2010/06/06
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Instance/Pages/InstanceMenuPage.lua");
local InstanceMenuPage = commonlib.gettable("MyCompany.Aries.Instance.InstanceMenuPage");
InstanceMenuPage.ShowPage({
	title = "穿过这道神秘的能量门就是试炼之塔，你准备好了吗？",
	{label = "试炼之塔-初阶", worldname = "HaqiTown_LightHouse_S1",},
	{label = "试炼之塔-中阶", worldname = "HaqiTown_LightHouse_S2",},
	{label = "试炼之塔-高阶", worldname = "HaqiTown_LightHouse_S3",},
},function(selected_node)
	_guihelper.MessageBox(selected_node);
end);
------------------------------------------------------------
]]
local InstanceMenuPage = commonlib.gettable("MyCompany.Aries.Instance.InstanceMenuPage");
--@param menu_list:要显示的列表 关键字 label 
--[[
menu_list = {
	title = "穿过这道神秘的能量门就是试炼之塔，你准备好了吗？"
	{label = "试炼之塔-初阶", worldname = "HaqiTown_LightHouse_S1",},
	{label = "试炼之塔-中阶", worldname = "HaqiTown_LightHouse_S2",},
	{label = "试炼之塔-高阶", worldname = "HaqiTown_LightHouse_S3",},
}
--]]
function InstanceMenuPage.ShowPage(menu_list,selectedCallbackFunc)
	if(not menu_list)then return end
	InstanceMenuPage.menu_list = menu_list;
	InstanceMenuPage.selectedCallbackFunc = selectedCallbackFunc;
	local url = "script/apps/Aries/Instance/Pages/InstanceMenuPage.teen.html";
	local params = {
				url = url, 
				name = "InstanceMenuPage.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
				zorder = zorder,
				directPosition = true,
					align = "_ct",
					x = -400/2,
					y = -300/2,
					width = 400,
					height = 300,
		}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
end
function InstanceMenuPage.DoClick(index)
	if(InstanceMenuPage.menu_list)then
		local selected_node = InstanceMenuPage.menu_list[index];
		if(InstanceMenuPage.selectedCallbackFunc)then
			InstanceMenuPage.selectedCallbackFunc(selected_node);
		end
	end
	InstanceMenuPage.selectedCallbackFunc = nil;
	InstanceMenuPage.menu_list = nil;
end
function InstanceMenuPage.DS_Func_Items(index)
	if(not InstanceMenuPage.menu_list)then return 0 end
	if(index == nil) then
		return #(InstanceMenuPage.menu_list);
	else
		return InstanceMenuPage.menu_list[index];
	end
end