--[[
Title: 
Author(s): LiXizhi
Date: 2018/7/25
Desc: this is same as AssetsManager.lua
use the lib:
------------------------------------------------------------
local AutoUpdater = NPL.load("AutoUpdater");
local a = AutoUpdater:new()
a:onInit("test/","npl_mod/AutoUpdater/configs/paracraft.xml",function(state)
	echo(state)
end)
a:check(nil,function()
	echo({a:getCurVersion(), a:getLatestVersion()});
	if(a:isNeedUpdate())then
		a:download();
	else
		echo("latest version!");
	end
end);
------------------------------------------------------------
]]
NPL.load("./AssetsManager.lua");
local AssetsManager = commonlib.gettable("Mod.AutoUpdater.AssetsManager");

local AutoUpdater = commonlib.inherit(AssetsManager, NPL.export());

function AutoUpdater:ctor()
end

-- virtual function: relative path like "database/globalstore.db", sometimes we may need to secretely change the case or filename. 
function AutoUpdater:FilterStoragePath(filename)
	return filename;
end

-- virtual function: return true if one wants to skip downloading the given filename
function AutoUpdater:FilterFile(filename)
end