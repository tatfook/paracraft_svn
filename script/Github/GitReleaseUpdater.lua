--[[
Title: GitReleaseUpdater
Author(s): leio
Date: 2019.3.25
Desc: download assets from github releases
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/Github/GitReleaseUpdater.lua");
local GitReleaseUpdater = commonlib.gettable("script.Github.GitReleaseUpdater");
local version = nil;
local releases_url = "https://api.github.com/repos/tatfook/NplBrowser/releases?per_page=1000";
local cache_folder = "temp/GitReleaseUpdater/NplBrowser";
local dest_folder = "cef3/";

local git_release_updater = GitReleaseUpdater:new():onInit(releases_url,cache_folder,dest_folder)
local function event_callback(state)
    if(state == GitReleaseUpdater.State.VERSION_CHECKED)then
        git_release_updater:download()
    elseif(state == GitReleaseUpdater.State.ASSETS_DOWNLOADED)then
        git_release_updater:decompress()
    elseif(state == GitReleaseUpdater.State.UPDATED)then
    end
end
local function moving_file_callback(name,k,len)
end
git_release_updater.event_callback = event_callback;
git_release_updater.moving_file_callback = moving_file_callback;

git_release_updater:check(version)
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Util/ZipFile.lua");
local ZipFile = commonlib.gettable("System.Util.ZipFile");
NPL.load("(gl)script/ide/System/os/GetUrl.lua");
local GitReleaseUpdater = commonlib.inherit(nil,commonlib.gettable("script.Github.GitReleaseUpdater"));
local headers = { 
    ['User-Agent'] = 'Satellizer' ,
    ['Accept'] = 'application/vnd.github.preview' ,
};
local next_value = 0;
local try_redownload_max_num = 3;
GitReleaseUpdater.global_instances = {};

local function get_next_value()
    next_value = next_value + 1;
    return next_value;
end
GitReleaseUpdater.State = {
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

GitReleaseUpdater.UpdateFailedReason = {
	MD5 = get_next_value(),
    Uncompress = get_next_value(),
    Move = get_next_value()
};
function GitReleaseUpdater:onInit(releases_url,cache_folder,dest_folder)
    self.cur_version = nil;
    self.releases_url = releases_url;
    self.latest_info = {};
    self.latest_asset_info = {};
    self.cache_folder = cache_folder;
    self.dest_folder = dest_folder;

    self._failedDownloadUnits = {};
    self._failedUpdateFiles = {};
    self.try_num = 1;
    self._totalSize = 0;
    self.isAllDownloaded_ = false;
    self.download_next_asset_index = 0;

    self.event_callback = nil;
    self.moving_file_callback = nil;
    return self;
end
-- @param {string} [version="0.0.0"]: nil to download latest asset 
function GitReleaseUpdater:check(version)
    version = version or "";
    self.cur_version = version;
	LOG.std(nil, "info", "GitReleaseUpdater", "the current version is:%s", version);
    System.os.GetUrl({
        url = self.releases_url,
        headers = headers,
        json = true, 
    }, function(err, msg, data)  
        if(err == 200)then
            for k,v in ipairs(data) do
                if(not v.prerelease and v.assets)then
                    -- set latest info
                    self.latest_info = v;

                    local latest_v = self:getLatestVersion();
		            LOG.std(nil, "info", "GitReleaseUpdater", "the latest version is:%s", latest_v);

                    self:callback(self.State.VERSION_CHECKED);
                    break;
                end
            end
        else
		    LOG.std(nil, "error", "GitReleaseUpdater:check err", err);
		    LOG.std(nil, "error", "GitReleaseUpdater:check msg", msg);
        end 
    end);
end
function GitReleaseUpdater:download()
	if (not self:needUpdate())then
		LOG.std(nil, "warning", "GitReleaseUpdater", "needn't to download");
		return;
    end
    self.try_num = 1;
	self:parseManifest();
    self:downloadAssets();
end

function GitReleaseUpdater:parseManifest()
	LOG.std(nil, "info", "GitReleaseUpdater", "start to parse manifest");
    local assets = self:getLatestAssets();
    for k,asset in ipairs(assets) do
        local size = asset.size or 0;
		self._totalSize = self._totalSize + size;
        local cacheFileName = self:getCacheFileName(asset);
        if(ParaIO.DoesFileExist(cacheFileName))then
			LOG.std(nil, "info", "GitReleaseUpdater", "this file has existed: %s",cacheFileName);
			asset.hasDownloaded = true;
		end
    end
end
function GitReleaseUpdater:downloadAssets()
    self:callback(self.State.PREDOWNLOAD_ASSETS);
    self:downloadNext();
end
function GitReleaseUpdater:downloadNextAsset(index)
    local assets = self:getLatestAssets();
    local len = #assets;
    if(index > len)then
        local len = #self._failedDownloadUnits;
        if(len > 0)then
	        LOG.std(nil, "info", "GitReleaseUpdater", "download assets uncompleted by loop:%d",self.try_num);
            if(self.try_num < try_redownload_max_num)then
                self.try_num = self.try_num + 1;
                self._failedDownloadUnits = {};
                self:downloadAssets();
            else
                self:callback(self.State.ASSETS_ERROR);
            end
        else
            -- finished
	        LOG.std(nil, "info", "GitReleaseUpdater", "all of assets have been downloaded");
			self:setAllDownloaded();
            self:callback(self.State.ASSETS_DOWNLOADED);
        end
        return
    end
    local asset = assets[index];
    if(asset)then
        local url = asset.browser_download_url;
	    LOG.std(nil, "info", "GitReleaseUpdater", "download:[%d/%s]%s",index,len,url);
        self:callback(self.State.DOWNLOADING_ASSETS);
        if(not asset.hasDownloaded)then
            local cacheFileName = self:getCacheFileName(asset);
            System.os.GetUrl({
                url = url,
                headers = headers,
            }, function(err, msg, data)  
                if(err == 200)then
                    local len = #data;
                    if(len == asset.size)then
                        ParaIO.CreateDirectory(cacheFileName);
			            local file = ParaIO.open(cacheFileName, "w");
			            if(file:IsValid()) then
				            file:write(data,#data);
				            file:close();

                            asset.hasDownloaded = true;
		                    LOG.std(nil, "info", "GitReleaseUpdater", "saved file to:%s",cacheFileName);
                            self:downloadNext();
			            end
                    else
                        table.insert(self._failedDownloadUnits,asset);
                        self:downloadNext();
		                LOG.std(nil, "error", "GitReleaseUpdater", "the file size is wrong [%d/%d]%s", len, asset.size,cacheFileName);
                    end
                    
                else
                    table.insert(self._failedDownloadUnits,asset);
                    self:downloadNext();
		            LOG.std(nil, "error", "GitReleaseUpdater:download err", err);
		            LOG.std(nil, "error", "GitReleaseUpdater:download msg", msg);
                end 
            end);
        else
            self:downloadNext();
        end
    end
end
function GitReleaseUpdater:downloadNext()
    self.download_next_asset_index = self.download_next_asset_index + 1;
    self:downloadNextAsset(self.download_next_asset_index);
end
function GitReleaseUpdater:decompress()
    local assets = self:getLatestAssets();
    local len = #assets;
    local index = 1;
    NPL.load("(gl)script/ide/timer.lua");
	local mytimer = commonlib.Timer:new();
    local function decompress_next()
        if(index > len)then
            local failed_len = #self._failedUpdateFiles;
            if(failed_len > 0)then
                LOG.std(nil, "info", "GitReleaseUpdater", "update failed, the length of failed files is:%d",failed_len);
		        self:callback(self.State.FAIL_TO_UPDATED);
                return;
            end
            LOG.std(nil, "info", "GitReleaseUpdater", "decompress files finished");
            self:callback(self.State.UPDATED);
            return
        end
        local asset = assets[index];
        local cacheFileName = self:getCacheFileName(asset);
	    local file_size = ParaIO.GetFileSize(cacheFileName);
        if(file_size == asset.size)then
            self:callback(self.State.UPDATING,asset.name);
            if(self.moving_file_callback)then
                self.moving_file_callback(asset.name, index, len)
            end
            LOG.std(nil, "info", "GitReleaseUpdater", "decompress:%s -> %s",cacheFileName,self.dest_folder);
            NPL.load("(gl)script/ide/timer.lua");
	        mytimer.callbackFunc = function(timer)
                local zipFile = ZipFile:new();
                if(zipFile:open(cacheFileName)) then
	                zipFile:unzip(self.dest_folder);
	                zipFile:close();
                end
                index = index + 1;
                decompress_next(index);
	        end
	        mytimer:Change(200)
        else
            LOG.std(nil, "error", "GitReleaseUpdater", "delete an incorrect file:[%d/%d]%s",asset.size,file_size,cacheFileName);
		    ParaIO.DeleteFile(cacheFileName);
            table.insert(self._failedUpdateFiles,asset);
            index = index + 1;
            decompress_next(index);
        end
        
    end
	decompress_next(index)
	
end
function GitReleaseUpdater:getCacheFileName(asset)
    local latest_v = self:getLatestVersion();
    local cacheFileName = string.format("%s/%s/%s",self.cache_folder,latest_v,asset.name);
    return cacheFileName;
end
function GitReleaseUpdater:needUpdate()
    local latest_v = self:getLatestVersion();
    if(latest_v and latest_v ~= self:getCurVersion())then
        return true
    end
end
function GitReleaseUpdater:getCurVersion()
    return self.cur_version;
end
function GitReleaseUpdater:getLatestVersion()
    return self.latest_info.tag_name;
end
function GitReleaseUpdater:getLatestAssets()
    return self.latest_info.assets;
end
function GitReleaseUpdater:getPercent()
    local size = 0;
    local k,v;
    for k,v in pairs(self:getLatestAssets()) do
        local file_size = v.size or 0;
        if(v.hasDownloaded)then
            size = size + file_size;
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

function GitReleaseUpdater:getTotalSize()
    return self._totalSize
end

function GitReleaseUpdater:getDownloadedSize()
    return self:getPercent() * self._totalSize
end

function GitReleaseUpdater:isAllDownloaded()
	return self.isAllDownloaded_;
end

function GitReleaseUpdater:setAllDownloaded()
	self.isAllDownloaded_ = true;
end
function GitReleaseUpdater:callback(state)
    if(self.event_callback)then
        self.event_callback(state);
    end
end