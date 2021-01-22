--[[
Title: NplMod
Author(s): leio
Date: 2021/1/7
Desc: 
use the lib:
------------------------------------------------------------
local NplMod = NPL.load("(gl)script/apps/Aries/Creator/Game/NplMod/NplMod.lua");
local config = {
    name = "test",
    dependencies = {
        { name = "WinterCam2021", type = "github", source = "https://codeload.github.com/NPLPackages/WinterCamp2021/zip/main", }
    }
}
local nplmod = NplMod:new();
nplmod:LoadConfig(config, function(bFinished)
    commonlib.echo("=======bFinished");
    commonlib.echo(bFinished);
end);
------------------------------------------------------------
--]]
local NplModLoader = NPL.load("(gl)script/apps/Aries/Creator/Game/NplMod/NplModLoader.lua");
NPL.load("(gl)script/ide/System/Core/ToolBase.lua");
local NplModNode = NPL.load("(gl)script/apps/Aries/Creator/Game/NplMod/NplModNode.lua");
local NplModConfig = NPL.load("(gl)script/apps/Aries/Creator/Game/NplMod/NplModConfig.lua");
local NplMod = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), NPL.export());

function NplMod:ctor()
    self.root_node = NplModNode:new();
end
function NplMod:LoadConfig(config, callback)
    if(not config)then
        return
    end
    local NplmConfig = NplModConfig:new();
    NplmConfig:parse(config);
    self.root_node.NplmConfig = NplmConfig;

    self:LoadModNext(self.root_node, 1, callback);
end
function NplMod:LoadModNext(node, index, callback)
    if(not node or not node.NplmConfig)then
        if(callback)then
            callback()
        end
        return
    end
    local len = node.NplmConfig:getDepLen();
    if(len == 0 or (index > len))then
        if(callback)then
            callback(true)
        end
        return
    end
    local dep = node.NplmConfig:getDepByIndex(index);
    NplModLoader:loadMod(dep, function(nplm_config)
        if(nplm_config)then
            local nplmod_node = NplModNode:new();
            nplmod_node.NplmConfig = nplm_config;
            nplmod_node.Parent = node;
            if(nplm_config:getDepLen() > 0)then
                self:LoadModNext(nplmod_node, 1, function(bFinished)
                    if(bFinished)then
                        self:LoadModNext(node, index + 1, callback);        
                    end
                end)
                return        
            end
        end
        self:LoadModNext(node, index + 1, callback);        
    end)
end
