--[[
Title:
Author(s): leio
Date: 2017/10/10
Desc:
use the lib:
-- step 1. check version
-- step 2. download asset manifest and download assets
-- step 3. decompress and move files
------------------------------------------------------------
local AssetsManager = NPL.load("AutoUpdater");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/XPath.lua");
NPL.load("(gl)script/ide/System/os/GetUrl.lua");
NPL.load("(gl)script/ide/System/Util/ZipFile.lua");
local ZipFile = commonlib.gettable("System.Util.ZipFile");
local AssetsManager = commonlib.inherit(nil,commonlib.gettable("Mod.AutoUpdater.AssetsManager"));
local FILE_LIST_FILE_EXT = ".p"
local next_value = 0;
local try_redownload_max_num = 3;
AssetsManager.global_instances = AssetsManager.global_instances or {};
AssetsManager.defaultVersionFilename = "version.txt";

local function get_next_value()
    next_value = next_value + 1;
    return next_value;
end
AssetsManager.State = {
	UNCHECKED = get_next_value(),
	PREDOWNLOAD_VERSION = get_next_value(),
	DOWNLOADING_VERSION = get_next_value(),
	VERSION_CHECKED = get_next_value(),
	VERSION_ERROR = get_next_value(),
	PREDOWNLOAD_MANIFEST = get_next_value(),
	DOWNLOADING_MANIFEST = get_next_value(),
	MANIFEST_DOWNLOADED = get_next_value(),
	MANIFEST_ERROR = get_next_value(),
	PREDOWNLOAD_ASSETS = get_next_value(),
	DOWNLOADING_ASSETS = get_next_value(),
	ASSETS_DOWNLOADED = get_next_value(),
	ASSETS_ERROR = get_next_value(),
	PREUPDATE = get_next_value(),
	UPDATING = get_next_value(),
	UPDATED = get_next_value(),
	FAIL_TO_UPDATED = get_next_value()
};
AssetsManager.UpdateFailedReason = {
	MD5 = get_next_value(),
    Uncompress = get_next_value(),
    Move = get_next_value()
};
-- suppose version number "1.2.3", where 1 is the first(major) version, 2 is the second version, 3 is the third version.*/
AssetsManager.CheckVersionEnum = {
	CheckVersion_SameAsLast = 0,
	CheckVersion_FirstVersionChanged = 1,
	CheckVersion_SecondVersionChanged = 2,
	CheckVersion_ThirdVersionChanged = 3,
	CheckVersion_LocalVersionIsNewer = 100,
    CheckVersion_Error = -1
};
function AssetsManager:ctor()
    self.id = ParaGlobal.GenerateUniqueID();
    AssetsManager.global_instances[self.id] = self;
    self.configs = {
        version_url = nil,
        hosts = {},
    }

    self.writablePath = nil;
    self.storagePath = nil;
    self.destStoragePath = nil;

    self.localVersionTxt = nil;
    self._cacheVersionPath = nil;
    self._cacheManifestPath = nil;

    self._curVersion = nil;
    self._latestVersion = nil;
    self._needUpdate = false;
    self._comparedVersion = nil;
    self._hasVersionFile = false;

    self._downloadUnits = {}; -- children is download_unit

    self._failedDownloadUnits = {};
    self._failedUpdateFiles = {};

    self._manifestTxt = "";

	self.validHostIndex = 1;

    self.try_num = 1;

    self._totalSize = 0;
end

function AssetsManager:onInit(writablePath,config_filename,event_callback,moving_file_callback)
    local storagePath = writablePath .. "caches/";
    local destStoragePath = writablePath;
	local localVersionTxt = writablePath .. AssetsManager.defaultVersionFilename;

    self.writablePath = writablePath;
    self.storagePath = storagePath;
    self.destStoragePath = destStoragePath;

    self.localVersionTxt = localVersionTxt;
    self._cacheVersionPath = storagePath .. "version.manifest";
    self._cacheManifestPath = storagePath .. "project.manifest";
    self._assetsCachesPath = nil;

    self.moving_file_callback = moving_file_callback

    self.event_callback = event_callback;
	LOG.std(nil, "info", "AssetsManager", "localVersionTxt:%s",self.localVersionTxt);
	LOG.std(nil, "info", "AssetsManager", "_cacheVersionPath:%s",self._cacheVersionPath);
	LOG.std(nil, "info", "AssetsManager", "_cacheManifestPath:%s",self._cacheManifestPath);
	LOG.std(nil, "info", "AssetsManager", "config_filename:%s", config_filename or "");
	
    self:loadConfig(config_filename)
end
function AssetsManager:callback(state, ...)
    if(self.event_callback)then
        self.event_callback(state, ...);
    end
end
function AssetsManager:loadConfig(filename)
    if(not filename)then return end
    local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
	    LOG.std(nil, "error", "AssetsManager", "file %s does not exist",filename);
		return
	end
    local node;
    -- Getting version_url
	for node in commonlib.XPath.eachNode(xmlRoot, "/configs/version") do
        self.configs.version_url = node[1];
	end
    -- Getting patch hosts
	for node in commonlib.XPath.eachNode(xmlRoot, "/configs/hosts/host") do
        self.configs.hosts[#self.configs.hosts+1] = node[1];
	end
	LOG.std(nil, "info", "AssetsManager:loadConfig", self.configs);
end

-- step 1. check version
-- @param callback: function(bSucceed) end
function AssetsManager:check(version,callback)
    self:callback(self.State.PREDOWNLOAD_VERSION);
    self._hasVersionFile = ParaIO.DoesFileExist(self.localVersionTxt);
	if(not self._hasVersionFile and self.localVersionTxt == (ParaIO.GetWritablePath()..AssetsManager.defaultVersionFilename)) then
		self.localVersionTxt = AssetsManager.defaultVersionFilename;
		self._hasVersionFile = ParaIO.DoesFileExist(self.localVersionTxt);
	end

    self._manifestTxt = "";
    self._totalSize = 0;

    if(not version or version == "")then
        self:loadLocalVersion();
    else
        self._curVersion = version;
    end
	LOG.std(nil, "info", "AssetsManager", "local version is: %s",self._curVersion);
    self:downloadVersion(function(bSucceed)
		if(bSucceed) then
			LOG.std(nil, "info", "AssetsManager", "remote version is: %s",self._latestVersion);
			self._comparedVersion = self:compareVersions();
			LOG.std(nil, "info", "AssetsManager", "compared result is: %d",self._comparedVersion);
			self._assetsCachesPath = self.storagePath .. self._latestVersion;
			LOG.std(nil, "info", "AssetsManager", "Assets Cache Path is: %s",self._assetsCachesPath);
			ParaIO.CreateDirectory(self._assetsCachesPath);
			self:callback(self.State.VERSION_CHECKED);
		end
        if(callback)then
            callback(bSucceed);
        end
    end);
end
function AssetsManager:loadLocalVersion()
    self._curVersion = "0";
    local file = ParaIO.open(self.localVersionTxt, "r");
	if(file:IsValid()) then
        local txt = file:GetText();
        if(txt)then
            txt = string.gsub(txt,"[%s\r\n]","");
            local __,v = string.match(txt,"(.+)=(.+)");
            self._curVersion = v;
        end
	else
		LOG.std(nil, "warn", "AssetsManager", "file %s not FOUND", self.localVersionTxt);	
	end
end

-- @param callback: function(bSucceed) end
function AssetsManager:downloadVersion(callback)
    local version_url = self.configs.version_url;
    if(version_url)then
        self:callback(self.State.DOWNLOADING_VERSION);
        version_url = string.format("%s?v=%s",version_url,ParaGlobal.GetDateFormat("yyyy-M-d"));
	    LOG.std(nil, "info", "AssetsManager:downloadVersion url is:", version_url);
        System.os.GetUrl(version_url, function(err, msg, data)
			self._latestVersion = nil
	        if(err == 200)then
                if(data)then
                    local body = "<root>" .. data .. "</root>";
                    local xmlRoot = ParaXML.LuaXML_ParseString(body);
                    if(xmlRoot)then
                        for node in commonlib.XPath.eachNode(xmlRoot, "//UpdateVersion") do
                            self._latestVersion = node[1];
                            break;
	                    end

						-- find hosts in version.txt
						local index = 1;
						for node in commonlib.XPath.eachNode(xmlRoot, "//FullUpdatePackUrl") do
							local fullUpdatePackUrl = node[1];
							if(fullUpdatePackUrl) then
								-- if the path already ends with "/", we will use it as root url. 
								if(not fullUpdatePackUrl:match("/$")) then
									-- if the path contains coredownload/, we will remove everything after it. 
									fullUpdatePackUrl = fullUpdatePackUrl:gsub("coredownload.*$", "")
								end
								table.insert(self.configs.hosts, index, fullUpdatePackUrl);
								LOG.std(nil, "info", "AssetsManager", "adding host: %s in version file", fullUpdatePackUrl);
								index = index + 1;
								-- remove duplicates
								for i=index, #self.configs.hosts do
									if(self.configs.hosts[i] == fullUpdatePackUrl) then
										LOG.std(nil, "info", "AssetsManager", "remove duplicates at %d", i);
										table.remove(self.configs.hosts, i);
										break;
									end
								end
							else
								LOG.std(nil, "info", "AssetsManager", "FullUpdatePackUrl not found");
								echo(node);
							end
	                    end
						-- echo(self.configs.hosts)

                        if(callback)then
							if(self._latestVersion) then
								callback(true);
								return
							end
                        end
                    end
                end
            end
			if(not self._latestVersion) then
				LOG.std(nil, "warn", "AssetsManager:downloadVersion err:", err);
                self:callback(self.State.VERSION_ERROR);
				if(callback) then
					callback(false);
				end
            end
        end);
    end
end
function AssetsManager:compareVersions()
    if (self._curVersion == "0") then
		self._needUpdate = true;
		return self.CheckVersionEnum.CheckVersion_FirstVersionChanged;
	end
	if (self._curVersion == self._latestVersion) then
		self._needUpdate = false;
		return self.CheckVersionEnum.CheckVersion_SameAsLast;
    end

    local function get_versions(version_str)
        local result = {};
        for s in string.gfind(version_str or "", "%d+") do
            table.insert(result, tonumber(s));
		end
        return result;
    end

    local cur_version_list = get_versions(self._curVersion);
    local latestVersion_list = get_versions(self._latestVersion);

    if(#cur_version_list < 3 or #latestVersion_list < 3)then
		return self.CheckVersionEnum.CheckVersion_Error;
    end
    if(cur_version_list[1] < latestVersion_list[1])then
        self._needUpdate = true;
		return self.CheckVersionEnum.CheckVersion_FirstVersionChanged;
	elseif(cur_version_list[1] == latestVersion_list[1]) then
		if(cur_version_list[2] < latestVersion_list[2])then
			self._needUpdate = true;
			return self.CheckVersionEnum.CheckVersion_SecondVersionChanged;
		elseif(cur_version_list[2] == latestVersion_list[2])then
			if(cur_version_list[3] < latestVersion_list[3])then
				self._needUpdate = true;
				return self.CheckVersionEnum.CheckVersion_ThirdVersionChanged;
			elseif(cur_version_list[3] == latestVersion_list[3])then
				self._needUpdate = false;
				return self.CheckVersionEnum.CheckVersion_SameAsLast;
			end
		end
    end
	self._needUpdate = false;
	return self.CheckVersionEnum.CheckVersion_LocalVersionIsNewer;
end

-- step 2. download asset manifest and download assets
function AssetsManager:download()
	if (not self._needUpdate)then
		return;
    end
	self.validHostIndex = 1;
    self.try_num = 1;
	self:downloadManifest(self._comparedVersion, self.validHostIndex);
end
function AssetsManager:downloadManifest(ret, hostServerIndex)
    local len = #self.configs.hosts;
    if (hostServerIndex > len)then
		return;
    end
	local updatePackUrl;
	if (self.CheckVersionEnum.CheckVersion_FirstVersionChanged == ret or self.CheckVersionEnum.CheckVersion_SecondVersionChanged == ret) then
		updatePackUrl = self:getPatchListUrl(true, hostServerIndex);
	elseif(self.CheckVersionEnum.CheckVersion_ThirdVersionChanged == ret)then
		updatePackUrl = self:getPatchListUrl(false, hostServerIndex);
	else
		updatePackUrl = self:getPatchListUrl(true, hostServerIndex);
	end
	self:callback(self.State.PREDOWNLOAD_MANIFEST);
	local hostServer = self.configs.hosts[hostServerIndex];
	LOG.std(nil, "info", "AssetsManager", "checking host server: %s",hostServer);
	LOG.std(nil, "info", "AssetsManager", "updatePackUrl is : %s",updatePackUrl);

	self:callback(self.State.DOWNLOADING_MANIFEST);
    System.os.GetUrl(updatePackUrl, function(err, msg, data)
        if(err == 200 and data)then
			self:callback(self.State.MANIFEST_DOWNLOADED);
            self:parseManifest(data);
            self:downloadAssets();
        else
            local len = #self.configs.hosts;
            if(self.validHostIndex >= len)then
                self:callback(self.State.MANIFEST_ERROR);
                return
            end
            self.validHostIndex = self.validHostIndex + 1;
	        self:downloadManifest(self._comparedVersion, self.validHostIndex);
        end
    end)
end
function AssetsManager:getPatchListUrl(is_full_list, nCandidate)
    local len = #self.configs.hosts;
	nCandidate = math.min(nCandidate, len);
	nCandidate = math.max(nCandidate, 1);
	local hostServer = self.configs.hosts[nCandidate];
	if (is_full_list) then
		local url;
		-- like this:"http://update.61.com/haqi/coreupdate/coredownload/0.7.272/list/full.txt"
		if (not self._latestVersion or self._latestVersion == "") then
			url = hostServer .. "coredownload/list/full" .. FILE_LIST_FILE_EXT;
		else
			url = hostServer .. "coredownload/" .. self._latestVersion .. "/list/full" .. FILE_LIST_FILE_EXT;
        end
		return url;
	else
		-- like this:"http://update.61.com/haqi/coreupdate/coredownload/0.7.272/list/patch_0.7.0.txt"
		return hostServer .. "coredownload/" .. self._latestVersion .. "/list/patch_" .. self._curVersion .. FILE_LIST_FILE_EXT;
	end
end

function AssetsManager:parseManifest(data)
    local hostServer = self.configs.hosts[self.validHostIndex];
	LOG.std(nil, "info", "AssetsManager", "the valid host server is: %s",hostServer);
    local function split(str)
        local result = {};
        local s;
        for s in string.gfind(str, "[^,]+") do
            table.insert(result,s);
		end
        return result;
    end
    -- check duplicated urls
    local duplicated_urls = {};
    local line;
    for line in string.gmatch(data,"([^\r\n]*)\r?\n?") do
        if(line and line ~= "")then
            local arr = split(line);
            if(#arr > 2)then
                local filename = arr[1];
				if(not self:FilterFile(filename)) then
					local md5 = arr[2];
					local size = arr[3];
					local file_size = tonumber(size) or 0;
					self._totalSize = self._totalSize + file_size;
					local download_path = string.format("%s,%s,%s.p", filename, md5, size);
					local download_unit = {
						srcUrl = string.format("%scoredownload/update/%s", hostServer, download_path),
						storagePath = self._assetsCachesPath .. "/" .. self:FilterStoragePath(filename),
						customId = filename,
						hasDownloaded = false,
						totalFileSize = file_size,
						PercentDone = 0,
						md5 = md5,
					}
					if(ParaIO.DoesFileExist(download_unit.storagePath))then
						if(self:checkMD5(download_unit.storagePath,md5))then
							LOG.std(nil, "info", "AssetsManager", "this file has existed: %s",download_unit.storagePath);
							download_unit.hasDownloaded = true;
						end
					end
                    local srcUrl = download_unit.srcUrl;
                    if(not duplicated_urls[srcUrl])then
					    table.insert(self._downloadUnits,download_unit);
                        duplicated_urls[srcUrl] = true;
                    else
						LOG.std(nil, "debug", "AssetsManager", "found duplicated url: %s",srcUrl);
                    end
				end
            end
        end
    end
    local len = #self._downloadUnits;
	LOG.std(nil, "info", "AssetsManager", "the length of downloadUnits:%d",len);
end

-- virtual function: return true if one wants to skip downloading the given filename
function AssetsManager:FilterFile(filename)
	
end

-- virtual function: relative path like "database/globalstore.db", sometimes we may need to secretely change the case or filename. 
function AssetsManager:FilterStoragePath(filename)
	return filename;
end


function AssetsManager:getMD5(filename)
    local file = ParaIO.open(filename,"r");
    if(file:IsValid()) then
        local txt = file:GetText(0,-1);
        local v = ParaMisc.md5(txt);
        file:close();
        return v;
    end
end
function AssetsManager:checkMD5(filename,md5)
    local v = self:getMD5(filename);
    if(v ~= md5)then
	    LOG.std(nil, "debug", "AssetsManager", "checking md5 is wrong: %s %s %s",tostring(v),tostring(md5),tostring(filename));
        return false
    else
	    LOG.std(nil, "debug", "AssetsManager", "checking md5 is right: %s",tostring(filename));
    end
    return true;
end
function AssetsManager:downloadAssets()
    self:callback(self.State.PREDOWNLOAD_ASSETS);
    self.download_next_asset_index = 1;
    self:downloadNextAsset(self.download_next_asset_index);
end
function AssetsManager:downloadNextAsset(index)
    local len = #self._downloadUnits;
    if(index > len)then
        local len = #self._failedDownloadUnits;
        if(len > 0)then
	        LOG.std(nil, "info", "AssetsManager", "download assets uncompleted by loop:%d",self.try_num);
            if(self.try_num < try_redownload_max_num)then
                self.try_num = self.try_num + 1;
                self._failedDownloadUnits = {};
                self:downloadAssets();
            else
                self:callback(self.State.ASSETS_ERROR);
            end
        else
            -- finished
	        LOG.std(nil, "info", "AssetsManager", "all of assets have been downloaded");
			self:setAllDownloaded();
            self:callback(self.State.ASSETS_DOWNLOADED);
        end
        return
    end
    local unit = self._downloadUnits[index];
    if(unit)then
        if(not unit.hasDownloaded)then
	        LOG.std(nil, "info", "AssetsManager", "downloading: %s",unit.srcUrl);
	        LOG.std(nil, "info", "AssetsManager", "temp storagePath: %s",unit.storagePath);
            local callback_str = string.format([[Mod.AutoUpdater.AssetsManager.downloadCallback("%s","%s")]],self.id,unit.customId);
			NPL.AsyncDownload(unit.srcUrl, unit.storagePath, callback_str, unit.customId);
        else
            self:downloadNext();
        end
    end
end
function AssetsManager:downloadNext()
    self.download_next_asset_index = self.download_next_asset_index + 1;
    self:downloadNextAsset(self.download_next_asset_index);
end
function AssetsManager.downloadCallback(manager_id,id)
    local manager = AssetsManager.global_instances[manager_id];
    if(not manager)then
        return
    end
    if(msg)then
        manager:callback(manager.State.DOWNLOADING_ASSETS);
        local download_unit = manager._downloadUnits[manager.download_next_asset_index];
        local rcode = msg.rcode;
        if((rcode and rcode ~= 200) or (msg.code and msg.code ~= 0)) then
	        LOG.std(nil, "warn", "AssetsManager", "download failed: %s, code: %d",download_unit.srcUrl, msg.code or 0);
            table.insert(manager._failedDownloadUnits,download_unit);
            manager:downloadNext();
            return
        end
        local PercentDone = msg.PercentDone or 0;
        local totalFileSize = msg.totalFileSize or 0;
        download_unit.PercentDone = PercentDone;
        if(PercentDone == 100)then
            download_unit.hasDownloaded = true;
            if(totalFileSize ~= download_unit.totalFileSize)then
	            LOG.std(nil, "warn", "AssetsManager", "the size of this file is wrong possibly due to slow connection: %s",download_unit.storagePath);
            else
	            LOG.std(nil, "debug", "AssetsManager", "download finished: %s",download_unit.srcUrl);
	            LOG.std(nil, "debug", "AssetsManager", "save at: %s",download_unit.storagePath);
            end
            manager:downloadNext();

        end
    end
end
function AssetsManager:getPercent()
    local size = 0;
    local k,v;
    for k,v in pairs(self._downloadUnits) do
        local totalFileSize = v.totalFileSize or 0;
        local PercentDone = v.PercentDone or 0;
        if(v.hasDownloaded)then
            size = size + totalFileSize;
        else
            size = size + totalFileSize * PercentDone;
        end
    end
    local percent;
    if(not self._totalSize or self._totalSize == 0)then
        percent = 0;
    else
        percent = size / self._totalSize;
    end
    return percent;
end

function AssetsManager:getTotalSize()
    return self._totalSize
end

function AssetsManager:getDownloadedSize()
    return self:getPercent() * self._totalSize
end

function AssetsManager:isAllDownloaded()
	return self.isAllDownloaded_;
end

function AssetsManager:setAllDownloaded()
	self.isAllDownloaded_ = true;
end

-- step 3. decompress and move files
function AssetsManager:apply()
    self:callback(self.State.PREUPDATE);
    local version_storagePath = "";
	local version_name;
    local version_abs_app_dest_folder;
    local len = #self._downloadUnits; --include version.txt if it is existed
    
	local k = 1
    timer = commonlib.Timer:new({callbackFunc = function(timer)
        local v = self._downloadUnits[k]
        if not v then -- moving file finished
            self:deleteOldFiles();
            self._needUpdate = false;
            local has_error = false;
            for filename, errorCode in pairs(self._failedUpdateFiles) do
                has_error = true;
		        self:callback(self.State.FAIL_TO_UPDATED, filename, errorCode);
                break;
            end
            if(not has_error)then
                -- if the version.txt does not exist in the latest assets
                -- create it with the latest_version in caches folder
                if(not version_name)then
                    local latest_version = self:getLatestVersion();
                    if(not latest_version)then
	                    LOG.std(nil, "error", "AssetsManager", "can't find latest version to update at last");
                        self:callback(self.State.FAIL_TO_UPDATED);
                        return
                    end
                    version_name = string.format("%s/%s/%s",self.storagePath, latest_version, AssetsManager.defaultVersionFilename);
                    local file = ParaIO.open(version_name, "w");
				    if(file:IsValid()) then
                        local content = string.format("ver=%s\n",latest_version);
					    file:WriteString(content);
					    file:close();
				    end
                    version_abs_app_dest_folder = self.writablePath .. AssetsManager.defaultVersionFilename;
                end

                -- version.txt
                if(version_storagePath and ParaIO.DeleteFile(version_storagePath) ~= 1)then
	                LOG.std(nil, "error", "AssetsManager", "failed to delete file: %s",version_storagePath);
		        end
		        if(not ParaIO.MoveFile(version_name, version_abs_app_dest_folder))then
	                LOG.std(nil, "error", "AssetsManager", "failed to move file: %s -> %s",version_name, version_abs_app_dest_folder);
                    self:callback(self.State.FAIL_TO_UPDATED, version_abs_app_dest_folder, self.UpdateFailedReason.Move);
                    return
		        end
		        self._hasVersionFile = true;

		        ParaIO.DeleteFile(self.storagePath);
                self:callback(self.State.UPDATED);
            end 
            timer:Change()
            return 
        end

        local storagePath = v.storagePath or "";
        local indexOfLastSeparator = string.find(storagePath, ".[^.]*$");
        local name = string.sub(storagePath,0,indexOfLastSeparator-1);
        local app_dest_folder = name;
		if(name:sub(1, #self._assetsCachesPath) == self._assetsCachesPath) then
			app_dest_folder =  name:sub(#self._assetsCachesPath+1, -1);
		end

		app_dest_folder = app_dest_folder:gsub("^/", "");
        app_dest_folder = self.writablePath .. app_dest_folder;
        if (not self:checkMD5(storagePath,v.md5)) then
	        LOG.std(nil, "error", "AssetsManager", "failed to compare md5 file: %s",storagePath);
			self._failedUpdateFiles[app_dest_folder] = self.UpdateFailedReason.MD5;
            ParaIO.DeleteFile(storagePath);
		else
			if (not self:decompress(storagePath, name))then
	            LOG.std(nil, "error", "AssetsManager", "failed to uncompress file: %s",storagePath);
			    self._failedUpdateFiles[app_dest_folder] = self.UpdateFailedReason.Uncompress;
                ParaIO.DeleteFile(storagePath);
			else
                local version_filename = ParaIO.GetFileName(app_dest_folder);
                version_filename = string.lower(version_filename);
				if (version_filename ~= AssetsManager.defaultVersionFilename)then
                    if(ParaIO.DeleteFile(storagePath) ~= 1)then
	                    LOG.std(nil, "error", "AssetsManager", "failed to delete file: %s",storagePath);
                    end
                    ParaIO.CreateDirectory(app_dest_folder);
					if(not ParaIO.MoveFile(name, app_dest_folder))then
	                    LOG.std(nil, "error", "AssetsManager", "failed to move file: %s -> %s",name, app_dest_folder);
                        self._failedUpdateFiles[app_dest_folder] = self.UpdateFailedReason.Move;
                    end

	                LOG.std(nil, "info", "AssetsManager", "moving file(%d/%d):%s",k, len,app_dest_folder);

                    if self.moving_file_callback and type(self.moving_file_callback) == "function" then
                        self.moving_file_callback(app_dest_folder, k, len)
                    end
				else
					version_storagePath = storagePath;
					version_name = name;
					version_abs_app_dest_folder = app_dest_folder;
				end
			end
        end

        k = k + 1
    end})
    timer:Change(0, 100)
end
function AssetsManager:decompress(sourceFileName,destFileName)
    if(not sourceFileName or not destFileName)then return end
    local file = ParaIO.open(sourceFileName,"r");
    if(file:IsValid())then
        local content = file:GetText(0,-1);
        local dataIO = {content = content, method = "gzip"};
        if(NPL.Decompress(dataIO)) then
            if(dataIO and dataIO.result)then
                ParaIO.CreateDirectory(destFileName);
				local file = ParaIO.open(destFileName, "w");
				if(file:IsValid()) then
					file:write(dataIO.result,#dataIO.result);
					file:close();
				end
                return true
            end
		end
    end
    return false;
end
function AssetsManager:deleteOldFiles()
    local delete_file_path = string.format("%sdeletefile.list", self.writablePath);
	LOG.std(nil, "info", "AssetsManager", "beginning delete old files from:%s",delete_file_path);
    local file = ParaIO.open(delete_file_path,"r");
    if(file:IsValid())then
        local content = file:GetText();
        local name;
        for name in string.gfind(content, "[^,]+") do
            name = string.gsub(name,"%s","");
			local full_path = string.format("%s%s", self.writablePath, name);
            if(ParaIO.DoesFileExist(full_path))then
                if(not ParaIO.DeleteFile(full_path) ~= 1)then
	                LOG.std(nil, "waring", "AssetsManager", "can't delete the file:%s",full_path);
                end
            end
		end
		file:close();
    else
	    LOG.std(nil, "info", "AssetsManager", "can't open file:%s",delete_file_path);
    end
	LOG.std(nil, "info", "AssetsManager", "finished delete old files from:%s",delete_file_path);
end
function AssetsManager:isNeedUpdate()
    return self._needUpdate;
end
function AssetsManager:hasVersionFile()
    return self._hasVersionFile;
end
function AssetsManager:getCurVersion()
    return self._curVersion;
end
function AssetsManager:getLatestVersion()
    return self._latestVersion;
end
-- get the number value of version
-- @param {string} version - "0.0.1"
-- return {number}
function AssetsManager.getVersionNumberValue(version)
    if(not version)then
        return -1;
    end
    local function get_versions(version_str)
        local result = {};
        for s in string.gfind(version_str, "%d+") do
            table.insert(result, tonumber(s));
		end
        return result;
    end
    local version_list = get_versions(version);
      if(#version_list < 3 )then
		return -1;
    end
    local v = version_list[1] * 1000 * 1000 + version_list[2] * 1000 + version_list[3]
    return v;
end