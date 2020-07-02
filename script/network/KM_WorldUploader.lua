--[[
Title: upload a local world to space server
Author(s): LiXizhi
Date: 2007/7/31
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/KM_WorldUploader.lua");
KM_WorldUploader.ShowUIForTask(KM_WorldUploader.NewTask({source="worlds/lixizhi", type = KM_WorldUploader.TaskType.NormalWorld}));
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
local L = CommonCtrl.Locale("KidsUI");

if(not KM_WorldUploader) then KM_WorldUploader={}; end

KM_WorldUploader.webservice_UploadUserFile  = ("UploadUserFile.asmx");
KM_WorldUploader.NextNumber = 0;
KM_WorldUploader.TaskPool = {}; -- a pool of {KM_WorldUploader.Task} with index Task.source.
KM_WorldUploader.currentTask = nil; -- the current task that should be displayed via the UI.
KM_WorldUploader.MaxTotalsize = 4096000; -- user can only upload file size smaller than 4 MB.

-- the Upload task type
KM_WorldUploader.TaskType = {
	NormalWorld = 0,
	AdsTexture = 1,
	AdsWorld = 2,
};

KM_WorldUploader.Task = {
	-- the local world path, such as worlds/lixizhi or worlds/lixizhi.zip. if it is not a zip, it will convert it to a zip file. 
	source = nil,
	-- task type: 0 for world Uploading task;1 for normal file Upload
	type = 0,
	-- task priority: not used at the moment
	priority = 0,
	-- a value between 0 and 100
	progress = 0,
	-- Upload progress text
	ProgressText = "",
	-- if this is nil, the worldURLText will be the same as source
	worldURLText = nil,
	-- a string indicating a sub task Upload statistics, such as "100KB/2000KB", different tasks may have different formats.
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
};
KM_WorldUploader.Task.__index = KM_WorldUploader.Task;

-- Create a new task such as KM_WorldUploader.NewTask({source="worlds/lixizhi", type = KM_WorldUploader.TaskType.NormalWorld})
function KM_WorldUploader.NewTask(o)
	if(not o or not o.source) then
		log("KM_WorldUploader.NewTask(o) must has a table parameter with a source field\n"); return;
	end
	setmetatable(o, KM_WorldUploader.Task);
	
	-- assign it a number
	o.number = KM_WorldUploader.NextNumber;
	KM_WorldUploader.NextNumber = KM_WorldUploader.NextNumber + 1;
	-- Add it to task pool
	KM_WorldUploader.TaskPool[o.source] = o;
	-- start the task immediately
	o:Start();
	return o
end

-- stop and remove a given task from the task pool
function KM_WorldUploader.DeleteTask(o)
	if(o ~= nil) then
		-- stop it any way
		o:Stop();
		-- remove the current task if they are equal
		if(KM_WorldUploader.currentTask ~= nil and KM_WorldUploader.currentTask.source == o.source) then
			KM_WorldUploader.currentTask = nil;
		end
		-- remove from the task pool
		KM_WorldUploader.TaskPool[o.source] = nil;
	end
end

-- Get the given task by source string, it may return nil if source is not in the task pool
function KM_WorldUploader.GetTask(source)
	return KM_WorldUploader.TaskPool[source];
end

-- display a top level dialog showing everything about a given task.
-- @param task: the task object to display for. If it is nil, the current task is used. Otherwise task becomes the current task.
function KM_WorldUploader.ShowUIForTask(task)
	local _this,_parent;
	
	if(task~=nil) then
		KM_WorldUploader.currentTask = task;
	end
	
	_this=ParaUI.GetUIObject("KM_WorldUploader");
	if(_this:IsValid() == false) then
		
		local width, height = 512, 257
		_this=ParaUI.CreateUIObject("container","KM_WorldUploader","_ct", -width/2, -height/2-50,width, height);
		--_this.background="Texture/whitedot.png;0 0 0 0";
		_this:SetTopLevel(true);
		_this:AttachToRoot();
		_parent = _this;
		
		
		_this = ParaUI.CreateUIObject("button", "button1", "_lt", 20, 15, 64, 64)
		_this.background="Texture/kidui/common/uploadpackage.png";
		_guihelper.SetUIColor(_this, "255 255 255");
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 98, 49, 80, 16)
		_this.text = L"Publishing:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "txtUploadStatistics", "_rt", -142, 135, 112, 16)
		_this.text = "1000KB/1024KB";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "txtUploadProgress", "_lt", 17, 100, 208, 16)
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "txtResultText", "_lt", 17, 167, 480, 16)
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "worldURL", "_lt", 184, 49, 280, 16)
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/progressbar.lua");
		local ctl = CommonCtrl.progressbar:new{
			name = "KM_WorldUploadProgressBar",
			alignment = "_mt",
			left = 20,
			top = 128,
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

		_this = ParaUI.CreateUIObject("button", "button1", "_rb", -115, -54, 100, 26)
		_this.text = L"Close";
		_this.onclick=";KM_WorldUploader.OnDestory();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "visitworld", "_lb", 20, -54, 180, 26)
		_this.text = L"visit my web space";
		_this.tooltip = kids_db.GetURLforUser();
		_this.onclick = ";KM_WorldUploader.VisitMyWeb();";
		_parent:AddChild(_this);
		
		KidsUI.PushState({name = "KM_WorldUploader", OnEscKey = KM_WorldUploader.OnDestory});
		
		-- update UI
		KM_WorldUploader.UpdateUIForTask();
	else
		KM_WorldUploader.OnDestory();
	end	
end

function KM_WorldUploader.VisitMyWeb()
	if(KM_WorldUploader.currentTask~=nil) then
		ParaGlobal.ShellExecute("open", "iexplore.exe", kids_db.GetURLforUser(), nil, 1);
	else
		log("are you kidding? worldpath is nil");
	end	
end
-- update the current Uploader UI according to a given task. 
-- @param task: if nil, the KM_WorldUploader.currentTask is used.
function KM_WorldUploader.UpdateUIForTask(task)
	if(not task) then
		task = KM_WorldUploader.currentTask;
		if(not task) then
			return
		end	
	end
	_this=ParaUI.GetUIObject("KM_WorldUploader");
	if(_this:IsValid() == false) then
		return
	end
	if(task.worldURLText==nil) then
		_this:GetChild("worldURL").text = task.source;
	else
		_this:GetChild("worldURL").text = task.worldURLText;
	end	
	_this:GetChild("txtUploadStatistics").text = task.subtaskStatistics;
	_this:GetChild("txtUploadProgress").text = task.ProgressText;
	

	local progressBar = CommonCtrl.GetControl("KM_WorldUploadProgressBar");
	if(progressBar==nil)then
		log("error getting progress bar instance from KM_WorldUploadProgressBar \r\n");
	else
		progressBar:SetValue(task.progress);
	end	
	
	if(task.type == KM_WorldUploader.TaskType.NormalWorld or task.type == KM_WorldUploader.TaskType.AdsWorld) then
		-- for world Uploader
		local resultCtl = _this:GetChild("txtResultText");
		if(task.errorcode == 0) then
			if(task.progress == 100) then
				resultCtl.text = L"successfully uploaded your 3D world";
				resultCtl:GetFont("text").color = "0 168 0";
				_this:GetChild("enterworld").enabled = true;
			else
				resultCtl.text = L"Please wait. It may take a few minutes.";
				_this:GetChild("enterworld").enabled = false;
			end	
		else
			_this:GetChild("txtUploadProgress").text = L"Upload is broken";
			_this:GetChild("txtUploadProgress"):GetFont("text").color = "255 0 0";
			
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
function KM_WorldUploader.OnDestory()
	KidsUI.PopState("KM_WorldUploader");
	KM_WorldUploader.currentTask = nil;
	ParaUI.Destroy("KM_WorldUploader");
end

-------------------------------------------------
-- KM_WorldUploader.task functions
-- task stages: Start()->CompressWorld()->GetIP()->SyncWorld();  Stop();
-------------------------------------------------

-- start this task
function KM_WorldUploader.Task:Start()
	self.state = 1;
	if(self.type == KM_WorldUploader.TaskType.NormalWorld) then
		-- for world sync: start the first stage
		self:CompressWorld();
	end
end

-- stop this task
-- @param errorcode: [int] it can be nil
-- @param errormessage: [string] it can be nil
function KM_WorldUploader.Task:Stop(errorcode, errormessage)
	self.state = -1;
	self.errorcode = errorcode;
	self.errormessage = errormessage;
	self:UpdateUI();
	-- TODO: stop web services
end

-- only update UI if the current UI is this
function KM_WorldUploader.Task:UpdateUI()
	if(KM_WorldUploader.currentTask ~= nil and KM_WorldUploader.currentTask.source == self.source) then
		KM_WorldUploader.UpdateUIForTask(self);
	end
end
---------------------------------------
-- local stage: compress world to zip file
---------------------------------------
function KM_WorldUploader.Task:CompressWorld()
	if(self.state == -1) then return end
	
	self.progress = 10;
	
	if(string.find(self.source, ".*%.zip$")==nil) then
		-- compress the world in self.source, if it is not already compressed
		local worldpath = self.source.."/";
		local zipfile = self.source..".zip";
		local worldname = string.gsub(self.source, ".*/(.-)$", "%1");
		
		local writer = ParaIO.CreateZip(zipfile,"");
		writer:AddDirectory(worldname, worldpath.."*.*", 6);
		writer:close();	
		self.worldzipfile = zipfile;
		self.ProgressText = string.format(L"world is successfully packed to %s and ready for publication.", zipfile);
		self:UpdateUI();
		
		log("world is compressed to "..zipfile.."\n")
		-- ensure some rendering
		ParaEngine.ForceRender();
	else
		self.worldzipfile = self.source;	
	end
	self:GetIP();
end	

---------------------------------------
-- web stage: get IP of the space server
---------------------------------------
function KM_WorldUploader.Task:GetIP()
	if(self.state == -1) then return end
	
	local username = kids_db.User.Name; -- such as "LiXizhi"
	if(username~=nil) then
		self.username = username;
		self.ProgressText = L"Connecting remote server, please wait...";
		self:UpdateUI();
		
		-- call web service
		local address = L("http://www.kids3dmovie.com").."/GetIP.asmx";
		NPL.RegisterWSCallBack(address, 
			string.format("local task=KM_WorldUploader.GetTask(%q);if(task~=nil)then task:GetIP_callback() end", self.source));
		NPL.activate(address, {op="get", username = username});
	else
		-- lost connection
		self:Stop(2,L"world format is not correct");
	end	
end

function KM_WorldUploader.Task:GetIP_callback()
	if(msg~=nil) then
		-- retrieve data from message
		self.spaceserver = msg.spaceserver;
		self.gameserver = msg.gameserver;
		self.spaceserverdomain = msg.spaceserverdomain;
		
		self.progress = 20;
		self:UpdateUI();
		
		if(self.spaceserverdomain == nil or self.spaceserverdomain =="") then
			-- the user does not have a space server domain. 			
			self:Stop(4, L"Your service of 3D space server is not open.");
		else
			self:SyncSpaceServer();
		end
	else
		-- lost connection
		self:Stop(1);
	end	
end
---------------------------------------
-- web stage: sync with the space server
---------------------------------------
function KM_WorldUploader.Task:SyncSpaceServer()
	if(self.state == -1) then return end
	
	local worldzipfile = self.worldzipfile;
	self.worldname = kids_db.User.Name.."_"..string.gsub(worldzipfile, ".*/(.-)$", "%1");
	self.totalsize = ParaIO.GetFileSize(worldzipfile);
	if(self.totalsize>KM_WorldUploader.MaxTotalsize) then
		self:Stop(3, L"Your world is too big; you need to apply to the administrators.");
		return;
	end
	local file = ParaIO.open(worldzipfile, "r");
	if(file:IsValid()) then
		self.ProgressText = string.format(L"Uploading to %s; Total file size %d KB", self.spaceserverdomain, math.floor(self.totalsize/1000) );
		local msg = {
			op = "UploadWorld",
			username = kids_db.User.Name,
			password = kids_db.User.Password,
			ImgIn = file,
			Filename = self.worldname,
			Overwrite = true,
		}
		local uploaderAddress = self.spaceserverdomain.."/UploadUserFile.asmx";
		--local uploaderAddress = "http://localhost:1225/KidsMovieSite".."/UploadUserFile.asmx";
		NPL.RegisterWSCallBack(uploaderAddress, 
			string.format("local task=KM_WorldUploader.GetTask(%q);if(task~=nil)then task:SyncSpaceServer_callback() end", self.source));
		NPL.activate(uploaderAddress, msg);
		file:close();
	else
		_guihelper.MessageBox(L"Unable to upload your work, your local file does not exist".."\n");
	end	
end

function KM_WorldUploader.Task:SyncSpaceServer_callback()
	if(msg~=nil and msg.fileURL~=nil) then
		self.progress = 100;
		self.worldURLText = msg.fileURL;
		self.ProgressText = L"Upload complete!";
		self.subtaskStatistics = string.format("%d bytes", self.totalsize);
		self:UpdateUI();
	elseif(msg==nil) then
		self:Stop(3, _guihelper.MessageBox(L"Network is not available, please try again later".."\n"));
	else
		self:Stop(3, _guihelper.MessageBox(L"We are unable to upload your work to the community website\n"));
	end	
end
