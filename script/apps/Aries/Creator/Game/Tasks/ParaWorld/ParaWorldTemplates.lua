--[[
Title: paraworld list
Author(s): chenjinxian
Date: 2020/9/8
Desc: 
use the lib:
------------------------------------------------------------
local ParaWorldTemplates = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldTemplates.lua");
ParaWorldTemplates.ShowPage();
-------------------------------------------------------
]]
local ParaWorldTemplates = NPL.export();

local page;
function ParaWorldTemplates.OnInit()
	page = document:GetPageCtrl();
end

function ParaWorldTemplates.ShowPage()
	local params = {
		url = "script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldTemplates.html",
		name = "ParaWorldTemplates.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		enable_esc_key = true,
		app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
		directPosition = true,
		align = "_ct",
		x = -860 / 2,
		y = -400 / 2,
		width = 860,
		height = 400,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);

end

function ParaWorldTemplates.OnClose()
	page:CloseWindow();
end

