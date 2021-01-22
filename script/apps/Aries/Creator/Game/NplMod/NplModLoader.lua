--[[
Title: NplModLoader
Author(s): leio
Date: 2021/1/7
Desc: define nplm config 
use the lib:
------------------------------------------------------------
local NplModLoader = NPL.load("(gl)script/apps/Aries/Creator/Game/NplMod/NplModLoader.lua");
------------------------------------------------------------
--]]

local PATH = NPL.load("(gl)script/ide/STL/path.lua");

NPL.load("(gl)script/ide/System/Core/ObjectPath.lua");
local ObjectPath = commonlib.gettable("System.Core.ObjectPath")
local NplModLoader = NPL.export();

NplModLoader.mod_maps = {};
NplModLoader.storage_root = "npl_extensions"
-- @param options {table}
-- @param options.name {string}: "WinterCam2021"
-- @param options.type {string}: "github"
-- @param options.branch {string}: "master"
-- @param options.source {string}: "https://github.com/NPLPackages/WinterCamp2021"
function NplModLoader:loadMod(options, callback)
    if(not options)then
        if(callback)then
            callback();
        end
        return
    end
    local name = options.name;
    local mod_zip = NplModLoader.mod_maps[name];
    if(not mod_zip)then

        local filepath = self:getModZipPath(name);
        commonlib.echo("==================filepath");
        commonlib.echo(filepath);
        if(ParaIO.DoesFileExist(filepath, true))then
            local config = self:readConfigInZip(name, filepath);
            NplModLoader.mod_maps[name] = config;
            if(callback)then
                callback(config);
            end
            return
        end

        local type = options.type or "github";
        local source = options.source;
        System.os.GetUrl(source, function(err, msg, data)  
            if(err ~= 200)then
                if(callback)then
                    callback();
                end
                return
            end
            commonlib.echo("==================filepath");
            commonlib.echo(filepath);
            commonlib.echo(#data);
		    ParaIO.CreateDirectory(filepath);
            local file = ParaIO.open(filepath, "w");
	        if(file:IsValid() == true) then
			    file:write(data,#data);
		        file:close();
	        end
            
            local config = self:readConfigInZip(name, filepath);
            NplModLoader.mod_maps[name] = config;
            if(callback)then
                callback(config);
            end

        end);

        return
    end
    if(callback)then
        callback();
    end
end
function NplModLoader:getStorageRoot()
    local root = ParaIO.GetCurDirectory(0)
    local s = string.format("%s%s", root, self.storage_root);
    return s;
end
function NplModLoader:getModZipPath(name)
    if(not name)then
        return
    end
    local s = string.format("%s/%s.zip", self:getStorageRoot(), name);
    return s;
end
function NplModLoader:readConfigInZip(name,filepath)
    local filesout = {};

    commonlib.Files.Find(filesout, "", 0, 10, ":.json", filepath);
    commonlib.echo("==============filesout");
    commonlib.echo(filesout,true);
	ParaAsset.OpenArchive(filepath, true);

    for k,v in ipairs(filesout) do
        local item = filesout[k];
        local filename = item.filename;
        filename = string.gsub(filename,"\\", "/");
        local dir,_name = commonlib.Files.splitPath(filename)
        _name = string.lower(_name or "");
        if(_name == "nplm.json")then
            local config_filepath = string.format("%s/%s",self:getStorageRoot(),filename);
            local file = ParaIO.open(config_filepath, "r");
	        if(file:IsValid() == true) then
			    local txt = file:GetText();
		        file:close();
                local out={};
                if(NPL.FromJson(txt, out)) then
	                echo(out);
                end
                if(dir and dir ~= "")then
                    local search_path = string.format("%s/%s",self:getStorageRoot(),dir);
                    commonlib.echo("==============search_path");
                    commonlib.echo(search_path);
	                ParaIO.AddSearchPath(search_path);
                    
                end
	        end
            break
        end
    end
end


