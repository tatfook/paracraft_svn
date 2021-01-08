--[[
Title: Editor
Author(s): leio
Date: 2021/1/7
Desc: 
use the lib:
------------------------------------------------------------
local Editor = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/VisualScene/UI/Editor.lua");
local editor = Editor:new();
local node, code_component, movieclip_component = editor:createNode(editor.Scene.RootNode, "", { 19128, 5, 19197 }, { 19128, 5, 19196 });
code_component:setCodeFileName("test/follow.lua")

local node, code_component, movieclip_component = editor:createNode(editor.Scene.RootNode, "", { 19125, 5, 19202 }, { 19125, 5, 19203 });
code_component:setCode('say("hi"); wait(2); say("bye")wait(2); say("")')
editor:run();

echo(editor:toJson(),true);
------------------------------------------------------------
--]]
local ComponentFactory = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/VisualScene/ComponentFactory.lua");
ComponentFactory.registerComponents();

local Scene = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/VisualScene/Scene.lua");
local SceneNode = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/VisualScene/SceneNode.lua");

NPL.load("(gl)script/ide/System/Core/ToolBase.lua");
local Editor = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), NPL.export());

Editor:Property({"Uid", "", auto = true,  camelCase = true, });
Editor:Property({"Name", "", auto = true,  camelCase = true, });
Editor:Property({"Scene", auto = true, type = "Scene", camelCase = true, });

function Editor:ctor()
    self.Scene = Scene:new();
end
function Editor:run()
    self.Scene.RootNode:run();
end
function Editor:stop()
    self.Scene.RootNode:stop();
end
function Editor:clear()
    self.Scene:clear();
end
function Editor:createNode(parent, name, position_code, position_movieclip)
    local node = SceneNode:new();
    node.Name = name;
    parent:addChild(node);
    local code_component = ComponentFactory.getComponent("CodeComponent"):new()
    code_component:setName("code_component");
    code_component:setBlockPosition(position_code);
    node:addComponent(code_component);

    local movieclip_component = ComponentFactory.getComponent("MovieClipComponent"):new()
    movieclip_component:setBlockPosition(position_movieclip);
    node:addComponent(movieclip_component);
    return node, code_component, movieclip_component;
end
function Editor:toJson()
    local object = {};
    object.Uid = self.Uid;
    object.Name = self.Name;
    if(self.Scene)then
        object.Scene = self.Scene:toJson();
    end
    return object;
end
