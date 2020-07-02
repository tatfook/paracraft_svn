--[[
Title: synchronizing a remote world with this local computer
Author(s): LiXizhi
Date: 2007/6/21
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/KM_WorldDownloader.lua");
KM_WorldDownloader.ShowUIForTask(KM_WorldDownloader.NewTask({source="http://www.kids3dmovie.com/lixizhi", type = KM_WorldDownloader.TaskType.NormalWorld}));
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
local L = CommonCtrl.Locale("KidsUI");

if(not KM_WorldDownloader) then KM_WorldDownloader={}; end

KM_WorldDownloader.NextNumber = 0;
KM_WorldDownloader.TaskPool = {}; -- a pool of {KM_WorldDownloader.Task} with index Task.source.
KM_WorldDownloader.currentTask = nil; -- the current task that should be displayed via the UI.

-- the download task type
KM_WorldDownloader.TaskType = {
	-- once completed: Task.worldpath, Task.gameserver, Task.spaceserver will be filled
	NormalWorld = 0,
	AdsTexture = 1,
	AdsWorld = 2,
};

KM_WorldDownloader.Task = {
	-- initial source link, usually the URL of the download source, this is also a unique key in the taskpool
	source = nil,
	-- task type: 0 for world downloading task;1 for normal file download
	type = 0,
	-- task priority: not used at the moment
	priority = 0,
	-- a value between 0 and 100
	progress = 0,
	-- download progress text
	ProgressText = "",
	-- if this is nil, the worldURLText will be the same as source
	worldURLText = nil,
	-- a string indicating a sub task download statistics, such as "100KB/2000KB", different tasks may have different formats.
	subtaskStatistics = "",
	-- this is assigned automatically. the larger the value, the later the task is added to the pool
	number = 0,
	-- start time: the time when the task is started. 
	starttime=0,
	-- error code: 0 means no error; 1 means line broken. 
	errorcode = 0,
	-- error message: string
	errormessage = nil,
	-- state: 0 paused, 1 started, -1 stoped
	state = 0,
	-- function be called when stoped. function(task) where task is the task object. Use errorcode and errormessage to get the error
	onstop = nil,
	-- function be called when completed. function(task) where task is the task object. 
	oncomplete = nil,
};
KM_WorldDownloader.Task.__index = KM_WorldDownloader.Task;

-- Create a new task such as KM_WorldDownloader.NewTask({source="http://www.kids3dmovie.com/lixizhi", type = KM_WorldDownloader.TaskType.NormalWorld})
function KM_WorldDownloader.NewTask(o)
	if(not o or not o.source) then
		log("KM_WorldDownloader.NewTask(o) must has a table parameter with a source field\n"); return;
	end
	setmetatable(o, KM_WorldDownloader.Task);
	
	-- assign it a number
	o.number = KM_WorldDownloader.NextNumber;
	KM_WorldDownloader.NextNumber = KM_WorldDownloader.NextNumber + 1;
	-- Add it to task pool
	KM_WorldDownloader.TaskPool[o.source] = o;
	-- start the task immediately
	o:Start();
	return o
end

-- stop and remove a given task from the task pool
function KM_WorldDownloader.DeleteTask(o)
	if(o ~= nil) then
		-- stop it any way
		o:Stop();
		-- remove the current task if they are equal
		if(KM_WorldDownloader.currentTask ~= nil and KM_WorldDownloader.currentTask.source == o.source) then
			KM_WorldDownloader.currentTask = nil;
		end
		-- remove from the task pool
		KM_WorldDownloader.TaskPool[o.source] = nil;
	end
end

-- Get the given task by source string, it may return nil if source is not in the task pool
function KM_WorldDownloader.GetTask(source)
	return KM_WorldDownloader.TaskPool[source];
end

-- display a top level dialog showing everything about a given task.
-- @param task: the task object to display for. If it is nil, the current task is used. Otherwise task becomes the current task.
function KM_WorldDownloader.ShowUIForTask(task)
	local _this,_parent;
	
	if(task~=nil) then
		KM_WorldDownloader.currentTask = task;
	end
	
	_this=ParaUI.GetUIObject("KM_WorldDownloader");
	if(_this:IsValid() == false) then
		
		local width, height = 512, 230
		_this=ParaUI.CreateUIObject("container","KM_WorldDownloader","_ct", -width/2, -height/2-50,width, height);
		--_this.background="Texture/whitedot.png;0 0 0 0";
		_this:SetTopLevel(true);
		_this:AttachToRoot();
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 17, 36, 112, 16)
		_this.text = L"Synchronizing:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "txtDownloadStatistics", "_rt", -142, 106, 112, 16)
		_this.text = "1000KB/1024KB";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "txtDownloadProgress", "_lt", 17, 71, 480, 16)
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "txtResultText", "_lt", 17, 138, 480, 16)
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "worldURL", "_lt", 135, 36, 280, 16)
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/progressbar.lua");
		local ctl = CommonCtrl.progressbar:new{
			name = "KM_WorldDownloadProgressBar",
			alignment = "_mt",
			left = 20,
			top = 99,
			width = 148,
			height = 23,
 			parent = _parent,
			Minimum = 0,
			Maximum = 100,
			Step = 10,
			Value = 0,
			block_color = "97 0 255", -- "10 36 106",
			TopLayer_bg = "Texture/kidui/explorer/progressbar_overlay.png",
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("button", "button1", "_rb", -213, -60, 75, 26)
		_this.text = L"Close";
		_this.onclick=";KM_WorldDownloader.OnDestory();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button3", "_rb", -123, -60, 100, 26)
		_this.text = L"Hide download";
		_this.onclick=";KM_WorldDownloader.OnDestory();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "enterworld", "_lb", 20, -60, 132, 26)
		_this.text = L"Enter world";
		_this.onclick = ";KM_WorldDownloader.EnterNetWorld();";
		_parent:AddChild(_this);
		
		KidsUI.PushState({name = "KM_WorldDownloader", OnEscKey = KM_WorldDownloader.OnDestory});
		
		-- update UI
		KM_WorldDownloader.UpdateUIForTask();
	else
		KM_WorldDownloader.OnDestory();
	end	
end

-- it will first load the downloaded world on the space server, 
--  and then join the game server if any. If the target has not have a game server, it will prompt to the user.
function KM_WorldDownloader.EnterNetWorld(task)
	if(not task) then
		task = KM_WorldDownloader.currentTask;
	end
	if(task~=nil and task.worldpath~=nil) then
		local worldpath = task.worldpath;
		--KM_WorldDownloader.OnDestory();
		
		-- Load the space server world before connecting to the game server(if any)
		kids_db.player.name = kids_db.User.Name;
		local res = KidsUI.LoadWorldImmediate(worldpath);
		if(res==true) then
			-- Do something after the load
			-- TODO: display something so that the user know that the world belongs to a network world owner
			
			-- always join as a guest
			kids_db.User.SetRole("guest");

			-- check if it contains a game server, if so we will try to connect to the game server			
			if(task.gameserver ~=nil and task.gameserver~="")then
				-- get game server name, IP and port. 
				local servername = task.username;
				local IP= string.gsub(task.gameserver, "(.*):.-$", "%1");
				local port = string.gsub(task.gameserver, ".*:(%d+)$", "%1"); 
				if(IP~=nil and port~=nil) then
					-- add DNS record
					log(string.format("DNS record added <%s>  %s  :  %s\r\n", servername, IP, port));
					ParaNetwork.AddNamespaceRecord(servername, IP, tonumber(port));
					
					-- enable network or restart network
					if(ParaNetwork.IsNetworkLayerRunning() == false) then
						ParaNetwork.EnableNetwork(true, kids_db.User.Name, kids_db.User.Password);
					else
						ParaNetwork.Restart();
					end
						
					CommonCtrl.chat_display.AddText("chat_display1", L"Connecting to "..servername.."......\r\n");
					
					-- connecting to the game server
					client.LoginToServer(servername);
				else
					_guihelper.MessageBox("用户没有申请开通游戏服务器，您只能观看世界，不能与其在线交流");
				end	
			end
		elseif(type(res) == "string") then
			-- show the error message
			_guihelper.MessageBox(res);
		end
	else
		log("are you kidding? worldpath is nil");	
	end	
end
-- update the current downloader UI according to a given task. 
-- @param task: if nil, the KM_WorldDownloader.currentTask is used.
function KM_WorldDownloader.UpdateUIForTask(task)
	if(not task) then
		task = KM_WorldDownloader.currentTask;
		if(not task) then
			return
		end	
	end
	_this=ParaUI.GetUIObject("KM_WorldDownloader");
	if(_this:IsValid() == false) then
		return
	end
	if(task.worldURLText==nil) then
		_this:GetChild("worldURL").text = task.source;
	else
		_this:GetChild("worldURL").text = task.worldURLText;
	end	
	_this:GetChild("txtDownloadStatistics").text = task.subtaskStatistics;
	_this:GetChild("txtDownloadProgress").text = task.ProgressText;
	

	local progressBar = CommonCtrl.GetControl("KM_WorldDownloadProgressBar");
	if(progressBar==nil)then
		log("error getting progress bar instance from KM_WorldDownloadProgressBar \r\n");
	else
		progressBar:SetValue(task.progress);
	end	
	
	if(task.type == KM_WorldDownloader.TaskType.NormalWorld or task.type == KM_WorldDownloader.TaskType.AdsWorld) then
		-- for world downloader
		local resultCtl = _this:GetChild("txtResultText");
		if(task.errorcode == 0) then
			if(task.progress == 100) then
				resultCtl.text = L"Successfully synchronized world, click enter world!";
				resultCtl:GetFont("text").color = "0 168 0";
				_this:GetChild("enterworld").enabled = true;
			else
				resultCtl.text = L"Please wait. It may take a few minutes.";
				_this:GetChild("enterworld").enabled = false;
			end	
		else
			_this:GetChild("txtDownloadProgress").text = L"Download is terminated";
			_this:GetChild("txtDownloadProgress"):GetFont("text").color = "255 0 0";
			
			if(task.errorcode == 1) then
				resultCtl.text = L"Server connection is not found or broken";
				resultCtl:GetFont("text").color = "255 0 0";
			else
				if(task.errormessage~=nil) then
					resultCtl.text = task.errormessage;
					resultCtl:GetFont("text").color = "255 0 0";
				end	
			end
		end	
	end
end

-- destory the control
function KM_WorldDownloader.OnDestory()
	KidsUI.PopState("KM_WorldDownloader");
	KM_WorldDownloader.currentTask = nil;
	ParaUI.Destroy("KM_WorldDownloader");
end

-------------------------------------------------
-- KM_WorldDownloader.task functions
-- task stages: Start()->GetIP()->SyncWorld();  Stop();
-------------------------------------------------

-- start this task
function KM_WorldDownloader.Task:Start()
	self.state = 1;
	if(self.type == KM_WorldDownloader.TaskType.NormalWorld) then
		-- for world sync: start the first web stage
		self:GetIP();
	elseif(self.type == KM_WorldDownloader.TaskType.AdsTexture) then
		-- for advertisement demo: 
		self:GetAdsFile();
	elseif(self.type == KM_WorldDownloader.TaskType.AdsWorld) then
		-- for advertisement demo: 
		self:GetAdsWorld();	
	end
end

-- stop this task
-- @param errorcode: [int] it can be nil
-- @param errormessage: [string] it can be nil
function KM_WorldDownloader.Task:Stop(errorcode, errormessage)
	self.state = -1;
	self.errorcode = errorcode;
	self.errormessage = errormessage;
	self:UpdateUI();
	if(self.onstop~=nil) then
		self.onstop(self);
	end
	-- TODO: stop web services
end

-- only update UI if the current UI is this
function KM_WorldDownloader.Task:UpdateUI()
	if(KM_WorldDownloader.currentTask ~= nil and KM_WorldDownloader.currentTask.source == self.source) then
		KM_WorldDownloader.UpdateUIForTask(self);
	end
end
---------------------------------------
-- web stage: get IP of the space server
---------------------------------------
function KM_WorldDownloader.Task:GetIP()
	if(self.state == -1) then return end
	
	local RootSite = string.gsub(self.source, "(http://.*/).-$", "%1"); -- such as "http://localhost:1979/WebServiceSite/"
	local username = string.gsub(self.source, ".*/(.-)$", "%1"); -- such as "LiXizhi"
	if(RootSite~=nil and username~=nil) then
		self.username = username;
		self.ProgressText = L"Connecting remote server, please wait...";
		self:UpdateUI();
		
		-- call web service
		local address = RootSite.."GetIP.asmx";
		NPL.RegisterWSCallBack(address, 
			string.format("local task=KM_WorldDownloader.GetTask(%q);if(task~=nil)then task:GetIP_callback() end", self.source));
		NPL.activate(address, {op="get", username = username});
	end	
end

function KM_WorldDownloader.Task:GetIP_callback()
	if(msg~=nil) then
		-- retrieve data from message
		self.spaceserver = msg.spaceserver;
		self.gameserver = msg.gameserver;
		if(self.spaceserver ~= nil) then
			self.progress = 10;
			self.ProgressText = L"Successfully retrieved IP; now sync with the 3D space server...";
			self:UpdateUI();
			self:SyncSpaceServer();
		else
			self:Stop(2, L"This user does not have any public 3D world");
		end
	else
		-- lost connection
		self:Stop(1);
	end	
end
---------------------------------------
-- web stage: sync with the space server
---------------------------------------
function KM_WorldDownloader.Task:SyncSpaceServer()
	if(self.state == -1) then return end
	if(self.spaceserver~=nil and self.spaceserver~="") then
		local filename = string.gsub(self.spaceserver, "http://(.*)/(.-)%?CRC32=%d+$", "%2");
		if(filename~=nil and filename~="" and string.find(filename, ".+%.zip$") ~= nil) then
			self.worldpath = kids_db.worlddir..filename;
			NPL.SyncFile(self.spaceserver, self.worldpath, 
				string.format("local task=KM_WorldDownloader.GetTask(%q);if(task~=nil)then task:SyncSpaceServer_callback() end", self.source), 
				self.source);
		else
			self:Stop(3, L"Space server type is not supported");
		end
	else
		self:Stop(3, L"The user does not have a space server");
	end
end

KM_WorldDownloader.SyncDataProgressText = L("Now synchronizing 3D space data: %d/%d bytes");
function KM_WorldDownloader.Task:SyncSpaceServer_callback()
	if(msg~=nil) then
		if(msg.DownloadState=="complete") then
			self.progress = 100;
			self.ProgressText = L"3D world file is 100% synchronized!";
			self.subtaskStatistics = string.format("%d%%", msg.PercentDone);
			self:UpdateUI();
			if(self.oncomplete~=nil) then
				self.oncomplete(self);
			end
		elseif(msg.DownloadState=="terminated") then
			self:Stop(4, L"Download is terminated");
		else
			self.progress = (msg.PercentDone/100)*80+20;
			self.ProgressText = string.format(KM_WorldDownloader.SyncDataProgressText, msg.currentFileSize, msg.totalFileSize);
			self.subtaskStatistics = string.format("%d%%", msg.PercentDone);
			self:UpdateUI();
		end
	else
		-- lost connection
		self:Stop(1);
	end
end
-----------------------------------------
-- web stage: get ads texture or flash file from advertisement web service
-----------------------------------------
function KM_WorldDownloader.Task:GetAdsFile()
	-- call web service
	local address = "http://localhost:1225/KidsMovieSite/GetAds.asmx";
	NPL.RegisterWSCallBack(address, 
		string.format("local task=KM_WorldDownloader.GetTask(%q);if(task~=nil)then task:GetAdsFile_callback() end", self.source));
	NPL.activate(address, {op="get"});
end

function KM_WorldDownloader.Task:GetAdsFile_callback()
	if(msg~=nil) then
		_guihelper.MessageBox("we get file "..msg.fileURL);
		if(self.oncomplete~=nil) then
			self.oncomplete(self);
		end
	else
		-- error
		self:Stop(1, "msg is nil");	
	end
end

-----------------------------------------
-- web stage: get the advertised world of the day from the web
-----------------------------------------
KM_WorldDownloader.ClientNumber = math.ceil(ParaGlobal.random()*1000); -- just a little trick for how many times the client has been calling a web service
function KM_WorldDownloader.Task:GetAdsWorld()
	-- call web service
	self.ProgressText = L"Now downloading today's recommended 3D world";
	self:UpdateUI();
	KM_WorldDownloader.ClientNumber = KM_WorldDownloader.ClientNumber+1;
	local address = L("http://www.kids3dmovie.com").."/GetAds.asmx";
	NPL.RegisterWSCallBack(address, 
		string.format("local task=KM_WorldDownloader.GetTask(%q);if(task~=nil)then task:GetAdsWorld_callback() end", self.source));
	NPL.activate(address, {op="get", type = "FreeWorldOfTheDay", ClientNumber = KM_WorldDownloader.ClientNumber, username = kids_db.User.Name});
end

function KM_WorldDownloader.Task:GetAdsWorld_callback()
	if(msg~=nil) then
		-- retrieve data from message
		self.spaceserver = msg.fileURL;
		if(self.spaceserver ~= nil and self.spaceserver~="") then
			local filename = string.gsub(self.spaceserver, "http://(.*)/(.-)%?CRC32=%d+$", "%2");
			self.worldURLText = filename;
			self.progress = 10;
			self.ProgressText = L"Successfully retrieved IP; now sync with the 3D space server...";
			self:UpdateUI();
			self:SyncSpaceServer();
		else
			self:Stop(2, L"No 3D world to download today");
		end
	else
		-- lost connection
		self:Stop(1);
	end	
end
