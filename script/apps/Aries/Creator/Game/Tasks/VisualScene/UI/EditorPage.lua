--[[
Title: EditorPage
Author(s): leio
Date: 2021/1/7
Desc: 
use the lib:
------------------------------------------------------------
local EditorPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/VisualScene/UI/EditorPage.lua");
EditorPage.ShowPage();
------------------------------------------------------------
--]]
local VisualSceneLogic = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/VisualScene/VisualSceneLogic.lua");
local EditorPage = NPL.export();

local page;
function EditorPage.OnInit()
	page = document:GetPageCtrl();
end

function EditorPage.ShowPage()
    local editor = VisualSceneLogic.createOrGetEditor("first_editor");
    editor:clear();
    EditorPage.editor = editor;

    local node, code_component, movieclip_component = editor:createNode(editor.Scene.RootNode, "", { 19128, 5, 19197 }, { 19128, 5, 19196 });
    code_component:setCodeFileName("test/follow.lua")

    local node, code_component, movieclip_component = editor:createNode(editor.Scene.RootNode, "", { 19125, 5, 19202 }, { 19125, 5, 19203 });
    code_component:setCode('say("hi"); wait(2); say("bye")wait(2); say("")')

    local ds = {};
    local parent = editor.Scene.RootNode;
    local len = parent:getChildCount();
    for k = 1, len do
        local child = parent:getChild(k);
        table.insert(ds,child);
    end

    EditorPage.Current_Item_DS = ds;
	local params = {
			url = "script/apps/Aries/Creator/Game/Tasks/VisualScene/UI/EditorPage.html",
			name = "EditorPage.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			enable_esc_key = true,
			--app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			directPosition = true,
				align = "_lt",
				x = 10,
				y = 30,
				width = 600,
				height = 500,
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
end
