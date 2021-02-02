--[[
Title: TestVisualScene
Author(s): leio
Date: 2021/2/2
Desc: 
use the lib:
------------------------------------------------------------
local TestVisualScene = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/VisualScene/Test/TestVisualScene.lua");
--TestVisualScene.TestEditor();
--TestVisualScene.TestFollowMagicRun();
TestVisualScene.TestFollowTeacherRun();
TestVisualScene.TestFollowTeacher_ChangeAssetFile();
------------------------------------------------------------
--]]
local Editor = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/VisualScene/UI/Editor.lua");
local VisualSceneLogic = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/VisualScene/VisualSceneLogic.lua");
local TestVisualScene = NPL.export();

function TestVisualScene.TestEditor()

    local editor = Editor:new():onInit();
    local node, code_component, movieclip_component = editor:createBlockCodeNode();
    code_component:setCode(
[[registerClickEvent(function()
    say("hello!", 2)

end)

local p_x,p_y,p_z = getPos("@p");
setPos(p_x - 1,p_y,p_z - 1)
turnTo("@p")
anim(0)
say("hello!", 2)
while(true) do
  if(((distanceTo("@p")) > (4))) then
    turnTo("@p")
    
    local x,y,z = getPos();
    local p_x,p_y,p_z = getPos("@p");
    setPos(x,p_y,z)
    anim(4)
    moveForward(3, 0.5)
  else
    turnTo("@p")
    anim(0)
  end
end
]])
    editor:run();
end
function TestVisualScene.TestFollowMagicRun()
    local editor = VisualSceneLogic.createOrGetEditor()
    if(not editor)then
        return
    end
    local node, code_component, movieclip_component = editor:createOrGetFollowMagic();
    if(node and code_component and movieclip_component)then
        -- active magic by internal code
        node:run();
    end
end
function TestVisualScene.TestFollowMagicStop()
    local editor = VisualSceneLogic.createOrGetEditor()
    if(not editor)then
        return
    end
    local node, code_component, movieclip_component = editor:createOrGetFollowMagic();
    if(node and code_component and movieclip_component)then
        -- stop magic by internal code
        node:stop();
    end
end
--[[
TestVisualScene.TestFollowTeacher_ChangeAssetFile("character/CC/02human/paperman/Male_teacher.x")
TestVisualScene.TestFollowTeacher_ChangeAssetFile("character/CC/02human/keepwork/avatar/pp.x")
TestVisualScene.TestFollowTeacher_ChangeAssetFile("character/CC/02human/keepwork/avatar/lala.x")
TestVisualScene.TestFollowTeacher_ChangeAssetFile("character/CC/02human/keepwork/avatar/kk.x")
--]]

function TestVisualScene.TestFollowTeacher_ChangeAssetFile(assetfile)
    assetfile = assetfile or "character/CC/02human/paperman/boy01.x";

    local editor = VisualSceneLogic.createOrGetEditor()
    if(not editor)then
        return
    end
    local node, code_component, movieclip_component = editor:createOrGetFollowTeacher();
    if(node and code_component and movieclip_component)then
        node:stop();
        movieclip_component:changeAssetFile(assetfile);
        node:run();
    end

end
function TestVisualScene.TestFollowTeacherRun()
    local editor = VisualSceneLogic.createOrGetEditor()
    if(not editor)then
        return
    end
    local node, code_component, movieclip_component = editor:createOrGetFollowTeacher();
    if(node and code_component and movieclip_component)then
        node:run();
    end
end
function TestVisualScene.TestFollowTeacherStop()
    local editor = VisualSceneLogic.createOrGetEditor()
    if(not editor)then
        return
    end
    local node, code_component, movieclip_component = editor:createOrGetFollowTeacher();
    if(node and code_component and movieclip_component)then
        node:stop();
    end
end