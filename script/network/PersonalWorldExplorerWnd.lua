--[[
Title: The base class for a window instance in explorer
Author(s): LiXizhi
Date: 2007/3/23
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/PersonalWorldExplorerWnd.lua");
local ctl = CommonCtrl.PersonalWorldExplorerWnd:new{
	name = "PersonalWorldExplorerWnd1",
	alignment = "_lt",
	left=0, top=0,
	width = 512,
	height = 512,
	parent = nil,
};
ctl:Show();
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/gui_helper.lua");
NPL.load("(gl)script/ide/progressbar.lua");

local L = CommonCtrl.Locale("IDE");

-- define a new control in the common control libary

-- default member attributes
local PersonalWorldExplorerWnd = {
	-- the top level control name
	name = "PersonalWorldExplorerWnd1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 512,
	height = 512, 
	parent = nil,
	-- attribute
	url = "",
	title = "untitled",
	-- session data
	GetIPComplete = false, -- whether GetIP.asmx has successfully retrieved data from the server
	worldname = "", -- name of the world.
	gameserver = "", -- game server address in the format IP:port
	spaceserver = "", -- space server address in the format IP:port
	exchangeserver = "", -- exchange server address in the format IP:port
	SpaceServerSyncComplete = false, -- whether space server file has successfully synchronized with the local machine.
	GameServerSyncComplete = false, -- whether game server has successfully synchronized with the local machine.
}
CommonCtrl.PersonalWorldExplorerWnd = PersonalWorldExplorerWnd;

-- constructor
function PersonalWorldExplorerWnd:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function PersonalWorldExplorerWnd:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function PersonalWorldExplorerWnd:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("PersonalWorldExplorerWnd instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
		-- PersonalWorldCont
		_this = ParaUI.CreateUIObject("container", "PersonalWorldCont", "_fi", 0, 0, 0, 0)
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", self.name.."pw_Homepage_cont_TabBtn", "_lt", 0, 0, 120, 25)
		_this.text = "homepage";
		_this.background="Texture/kidui/explorer/pagetab.png";
		_this.onclick=string.format([[;CommonCtrl.PersonalWorldExplorerWnd.SwitchTabWindow("%s", 0);]],self.name);
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", self.name.."pw_Manage_cont_TabBtn", "_lt", 120, 0, 120, 25)
		_this.background="Texture/kidui/explorer/pagetab.png";
		_this.text = "manage";
		_this.onclick=string.format([[;CommonCtrl.PersonalWorldExplorerWnd.SwitchTabWindow("%s", 1);]],self.name);
		_parent:AddChild(_this);

		_parent = ParaUI.GetUIObject("PersonalWorldCont");
		-- pw_Homepage_cont
		_this = ParaUI.CreateUIObject("container", self.name.."pw_Homepage_cont", "_fi", 0, 28, 4, 4)
		_this.background="Texture/kidui/explorer/panel_bg.png";
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "btnHomeIcon", "_lt", 8, 6, 128, 128)
		_this.background = "Texture/kidui/explorer/home_large.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", self.name.."btnHomeTitle", "_lt", 142, 19, 304, 44)
		_this.background = "Texture/kidui/explorer/hometitle_bk.png";
		_guihelper.SetUIColor(_this, "255 255 255");
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", self.name.."ProgressText", "_lt", 142, 70, 310, 32)
		_parent:AddChild(_this);
		
		local ctl = CommonCtrl.progressbar:new{
			name = self.name.."ProgressBar",
			alignment = "_lt",
			left = 145,
			top = 103,
			width = 301,
			height = 23,
 			parent = _parent,
			Minimum = 0,
			Maximum = 100,
			Step = 10,
			Value = 20,
			block_color = "97 0 255", -- "10 36 106",
			TopLayer_bg = "Texture/kidui/explorer/progressbar_overlay.png",
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("button", "btnEnter3DWorld", "_lt", 454, 66, 115, 31)
		_this.text = L"Enter 3D World";
		_this.background="Texture/kidui/explorer/button.png";
		_this.onclick=string.format([[;CommonCtrl.PersonalWorldExplorerWnd.OnClickEnter3DWorld("%s");]],self.name);
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnOpenWebPage", "_lt", 454, 103, 115, 31)
		_this.text = L"Open Web Site";
		_this.background="Texture/kidui/explorer/button.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnAddComment", "_rb", -163, -39, 34, 26)
		_this.text = L"add";
		_this.background="Texture/kidui/explorer/button.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnFeets", "_rt", -123, 142, 24, 24)
		_this.background="Texture/kidui/explorer/feet.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnLevels", "_rt", -123, 178, 24, 24)
		_this.background="Texture/kidui/explorer/level.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnActivities", "_rt", -123, 213, 24, 24)
		_this.background="Texture/kidui/explorer/event.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnFriends", "_rt", -123, 248, 24, 24)
		_this.background="Texture/kidui/explorer/friends.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label3", "_lt", 142, 142, 152, 16)
		_this.text = L"People's Comments";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label4", "_lb", 142, -58, 136, 16)
		_this.text = L"Leave comment:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("container", "intro_cont", "_ml", 10, 142, 125, 13)
		_this.background="Texture/kidui/explorer/tab_bg.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("container", "friends_cont", "_mr", 3, 294, 120, 13)
		_this.background="Texture/kidui/explorer/tab_bg.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("container", "comments_cont", "_fi", 145, 161, 129, 61)
		_this.background="Texture/kidui/explorer/tab_bg.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "editboxComment", "_mb", 145, 13, 169, 26)
		_this.background="Texture/kidui/explorer/editbox256x32.png";
		_parent:AddChild(_this);

		-- pw_Manage_cont
		_this = ParaUI.CreateUIObject("container", self.name.."pw_Manage_cont", "_fi", 0, 28, 4, 4)
		_this.background="Texture/kidui/explorer/panel_bg.png";
		_parent = ParaUI.GetUIObject("PersonalWorldCont");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "btnUploadServerInfo", "_lt", 134, 178, 103, 29)
		_this.background="Texture/kidui/explorer/button.png";
		_this.text = "Upload";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnRefreshServerInfo", "_lt", 263, 178, 103, 29)
		_this.background="Texture/kidui/explorer/button.png";
		_this.text = "Refresh";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label5", "_lt", 8, 7, 40, 16)
		_this.text = "URL:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "editboxURL", "_lt", 134, 4, 300, 26)
		_this.background="Texture/kidui/explorer/editbox256x32.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label6", "_lt", 8, 39, 120, 16)
		_this.text = "Domain Server:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "editboxDomainServer", "_lt", 134, 36, 300, 26)
		_this.background="Texture/kidui/explorer/editbox256x32.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label7", "_lt", 8, 71, 112, 16)
		_this.text = "Space Server:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "editboxSpaceServer", "_lt", 134, 68, 300, 26)
		_this.background="Texture/kidui/explorer/editbox256x32.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label8", "_lt", 8, 103, 104, 16)
		_this.text = "Game Server:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "editboxGameServer", "_lt", 134, 100, 300, 26)
		_this.background="Texture/kidui/explorer/editbox256x32.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label9", "_lt", 8, 135, 112, 16)
		_this.text = "Lobby Server:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "editboxLobbyServer", "_lt", 134, 132, 300, 26)
		_this.background="Texture/kidui/explorer/editbox256x32.png";
		_parent:AddChild(_this);

		-- switch to a tab page
		PersonalWorldExplorerWnd.SwitchTabWindow(self.name, 0);

	else
		if(bShow == nil) then
			if(_this.visible == true) then
				_this.visible = false;
			else
				_this.visible = true;
			end
		else
			_this.visible = bShow;
		end
	end	
end

-- close the given control
function PersonalWorldExplorerWnd.OnClose_Static(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting PersonalWorldExplorerWnd instance "..sCtrlName.."\r\n");
		return;
	end
	self:OnClose();
end

---------------------------------------------------------
-- private functions
---------------------------------------------------------

-- call this function to set the home world title text.
-- @param sTitle: usually something from the URL. 
function PersonalWorldExplorerWnd:SetHomeWorldTitle(sTitle)
	local _this = ParaUI.GetUIObject(self.name.."btnHomeTitle");
	if(_this:IsValid() == true) then
		_this.text = sTitle;
	end
end	

-- Set the progress according to stage and data associated with the given stage
-- @param stage: nil, param=nil
--  stage = "GetIP", param = [0|1] 0 for begin, 1 for finished.
-- see the code for more details.
function PersonalWorldExplorerWnd:UpdateProgress(stage, param)
	local progressText = "";
	local progressValue = 0;
	if(stage == nil) then
		if(type(param) == "string") then
			progressText = param;
		else
			progressText = "请输入URL以连接";
		end	
		progressValue = 0;
	elseif(stage == "GetIP") then
		if(param == 0) then
			progressText = "正在连接服务器，请稍候...";
			progressValue = 20;
		elseif(param == 1) then
			progressText = "成功的从服务器获得了IP信息";
			progressValue = 40;
		elseif(param == -1) then
			progressText = "服务器连接失败了，也许您的URL有误或服务器暂时不可用";	
			progressValue = 20;
		end
	elseif(stage == "SyncWorldInfo") then
		-- TODO:
	elseif(stage == "SyncSpaceServer") then	
		-- TODO:
	elseif(stage == "SyncGameServer") then	
		-- TODO:
	end
	
	-- update UI (text and progress bar)
	local _this = ParaUI.GetUIObject(self.name.."ProgressText");
	if(_this:IsValid() == true) then
		_this.text = progressText;
	end
	
	local progressBar = CommonCtrl.GetControl(self.name.."ProgressBar");
	if(progressBar==nil)then
		log("error getting progress bar instance from "..sCtrlName.."\r\n");
		return;
	else
		progressBar:SetValue(progressValue);
	end
end

-- @param nIndex: 0 or 1
function PersonalWorldExplorerWnd.SwitchTabWindow(sCtrlName, nIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting PersonalWorldExplorerWnd instance "..sCtrlName.."\r\n");
		return;
	end
	if(nIndex == 0) then
		_guihelper.SwitchVizGroup({self.name.."pw_Homepage_cont", self.name.."pw_Manage_cont", }, self.name.."pw_Homepage_cont");
		_guihelper.CheckRadioButtons({self.name.."pw_Homepage_cont_TabBtn", self.name.."pw_Manage_cont_TabBtn", }, self.name.."pw_Homepage_cont_TabBtn", "255 255 255");
	elseif(nIndex == 1) then
		_guihelper.SwitchVizGroup({self.name.."pw_Homepage_cont", self.name.."pw_Manage_cont", }, self.name.."pw_Manage_cont");
		_guihelper.CheckRadioButtons({self.name.."pw_Homepage_cont_TabBtn", self.name.."pw_Manage_cont_TabBtn", }, self.name.."pw_Manage_cont_TabBtn", "255 255 255");
	end
end

-- called when entering the 3d world. 
function PersonalWorldExplorerWnd.OnClickEnter3DWorld(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting PersonalWorldExplorerWnd instance "..sCtrlName.."\r\n");
		return;
	end
	
	NPL.load("(gl)script/network/KM_HostAndJoinWorld.lua");
	KM_HostAndJoinWorld.OnClickJoinWorld(self.url);	
	
	--[[
	-- only enter the 3d world, when we have successfully retrieved the 3d world IPs.
	if(self.GetIPComplete) then
		if(ParaNetwork.IsNetworkLayerRunning() == false) then
			_guihelper.MessageBox("请先使用您的帐户登陆，才能进入联网的3D世界");
			return
		end
		-- TODO: login here
		ParaNetwork.Restart();
		client.LoginToServer(self.worldname);
	else
		_guihelper.MessageBox("您需要连接到服务器后，才能进入联网的3D世界");
	end
	--]]
end

---------------------------------------------------------
-- the following methods are usually overriden by its derived class
---------------------------------------------------------

-- usually overriden by its derived class.
function PersonalWorldExplorerWnd:GetType()
	return "PersonalWorldExplorerWnd";
end

-- called by explorer when this window should be stopped (stop connecting).
function PersonalWorldExplorerWnd:OnStop()
end

-- called by explorer when this window should be closed and loses its connections
function PersonalWorldExplorerWnd:OnClose()
	self:OnStop();
	self:Destroy();
end

-- called by explorer when this window is informed of changing size. 
-- Usually only the width matters, since the parent will scroll this window if it is too long.
-- @param clientWidth: expected client size of this window 
-- @param clientHeight: expected client size of this window 
function PersonalWorldExplorerWnd:OnSize(clientWidth, clientHeight)
end

-- called by explorer when this window becomes the current active window in the explorer
function PersonalWorldExplorerWnd:OnActive()
end

-- called by explorer when this window becomes an inactive window in the explorer
function PersonalWorldExplorerWnd:OnDeActive()
end

-- called by explorer when this window needs to be refreshed
function PersonalWorldExplorerWnd:OnRefresh()
	self.GetIPComplete = false;
	self.SpaceServerSyncComplete = false;
	self.GameServerSyncComplete = false;
	
	-- update the URL UI display for the home world title
	local WorldTitle = string.gsub(self.url, "http://(.*)$", "%1");
	if(WorldTitle) then
		self:SetHomeWorldTitle(WorldTitle);
	else
		self:SetHomeWorldTitle("URL不正确，请重新输入");
	end	
	
	local RootSite = string.gsub(self.url, "(http://.*/).-$", "%1"); -- such as "http://localhost:1979/WebServiceSite/"
	local worldname = string.gsub(self.url, ".*/(.-)$", "%1"); -- such as "LiXizhi"
	if(RootSite~=nil and worldname~=nil) then
		self:UpdateProgress("GetIP", 0); -- display some text to inform the user our progress from the network delay.
		local address = RootSite.."GetIP.asmx";
		log("calling GetIP web service at: "..address.."\r\n");
		NPL.RegisterWSCallBack(address, 
			string.format([[CommonCtrl.PersonalWorldExplorerWnd.GetIP_Callback("%s", "%s");]], self.name, worldname));
		NPL.activate(address, {op="get", username = worldname});
	else
		self:UpdateProgress(nil, "URL输入不正确，请重新输入");
	end	
end

function PersonalWorldExplorerWnd.GetIP_Callback(sCtrlName, worldname)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting PersonalWorldExplorerWnd instance "..sCtrlName.."\r\n");
		return;
	end
	self.GetIPComplete = true;
	self:UpdateProgress("GetIP", 1);
	
	-- for debugging purposes only
	commonlib.DumpWSResult(worldname.." GetIP result\r\n");
	
	if(msg~=nil and msg.gameserver~=nil) then
		local IP= string.gsub(msg.gameserver, "(.*):.-$", "%1");
		local port = string.gsub(msg.gameserver, ".*:(%d+)$", "%1"); 
		if(IP~=nil and port~=nil) then
			self.worldname = worldname;
			self.gameserver = msg.gameserver;
			self.spaceserver = msg.spaceserver;
			-- add DNS record
			log(string.format("DNS record added <%s>  %s  :  %s\r\n", worldname, IP, port));
			ParaNetwork.AddNamespaceRecord(worldname, IP, tonumber(port));
		else
			
		end	
	end	
	
end

-- get the url of the window
function PersonalWorldExplorerWnd:GetURL()
	return self.url;
end

-- set the url of the window
function PersonalWorldExplorerWnd:SetURL(url)
	self.url = url;
	self:OnRefresh();
end

-- get the title of the window
function PersonalWorldExplorerWnd:GetTitle()
	return self.title;
end

-- set the title of the window
function PersonalWorldExplorerWnd:SetTitle(title)
	self.title = title;
end
