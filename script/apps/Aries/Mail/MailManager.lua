--[[
Title:
Author(s): Leio
Date: 2010/04/19
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Mail/MailManager.lua");
MyCompany.Aries.Quest.Mail.MailManager.OnInit();
MyCompany.Aries.Quest.Mail.MailManager.PushMailByID(10002);
MyCompany.Aries.Quest.Mail.MailManager.ShowMail();

MyCompany.Aries.Quest.Mail.MailManager.OnReset();  -- clear and init
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Mail/MailState.lua");
NPL.load("(gl)script/apps/Aries/Mail/MailList.lua");
NPL.load("(gl)script/ide/System/localserver/UrlHelper.lua");
local UrlHelper = commonlib.gettable("System.localserver.UrlHelper");

local timehelp = commonlib.gettable("commonlib.timehelp");

local MailList = commonlib.gettable("MyCompany.Aries.Quest.Mail.MailList");
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
NPL.load("(gl)script/apps/Aries/Player/main.lua");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local MailManager = commonlib.gettable("MyCompany.Aries.Quest.Mail.MailManager")
commonlib.partialcopy(MailManager, {
	timer = nil,
	run_secondes = nil,
	duration = 10000,--10秒检查一次，邮件发送的时间最好是10秒的整数倍
	systemMailPool = nil,
	mail_index = nil,
	hasInit = false,
	send_map = {},--记录已经发送过的邮件 
});

function MailManager.OnReset()
	local self = MailManager;
	self.hasInit = false;
	self.OnInit();
end
function MailManager.OnInit()
	local self = MailManager;
	--只被初始化一次
	if(not self.hasInit)then
		self.hasInit = true;
		if(not self.timer)then
			self.timer = commonlib.Timer:new({callbackFunc = function(timer)
				 self.OnUpdate()
			end})
		end
		-- start the timer after 0 milliseconds
		self.timer:Change(0, self.duration);
		self.run_secondes = 0;
		self.systemMailPool = {};
		self.mail_index = 0;
		
		self.SetMailDefaultValue();
	else
		-- start the timer after 0 milliseconds
		if(self.timer) then
			self.timer:Change(0, self.duration);
		end
	end
	LOG.std("", "system", "MailManager", "Initialized");
end

--set default value to every mail
function MailManager.SetMailDefaultValue()
	local self = MailManager;
	local mails = MailList.SystemTimerMails;
	if(not mails)then return end
	local k,mail;
	for k,mail in pairs(mails) do
		mail.cameraPosition = mail.cameraPosition or { 8.857349395752, 0.26208779215813, 2.9278204441071 };
		mail.title_bg = mail.title_bg or [[<div style="margin-left:0px;margin-top:0px;width:512px;height:128px;background:url(Texture/Aries/PENote/penote_title_32bits.png# 0 0 580 115)" />]];
		mail.npc_bg = mail.npc_bg or [[<div style="margin-left:0px;margin-top:0px;width:238px;height:440px;background:url(Texture/Aries/PENote/penote_papa_32bits.png# 0 0 238 440)" />]];
		mail.mail_page = mail.mail_page or "script/apps/Aries/Mail/MailTemplate/Mail_Template_Default.html";
		mail.sendnum = mail.sendnum or 1;--默认发一次
		mail.sendmaxnum = mail.sendmaxnum or 1;--最多发送次数
	end
end

local function checkFunc(mail)
	local canSendFunc = mail.canSendFunc;
	local canSend_params = mail.canSend_params;
	local canSend = true;
	if(canSendFunc and type(canSendFunc) == "function")then
		canSend = canSendFunc(canSend_params);
	end
	return canSend;
end

local function Mail_GetSendExactTime(mail)
	if(mail.send_exact_time) then
		if(not mail.send_exact_time_ms) then
			mail.send_exact_time_ms = timehelp.TimeStrToMill(mail.send_exact_time);
		end
		return mail.send_exact_time_ms;
	end
end

local function Mail_GetSendTimeSinceLast(mail)
	if(mail.sendtime)then
		if(not mail.sendtime_secs) then
			mail.sendtime_secs = MailManager.GetSecondsFromStr(mail.sendtime);
		end
		return mail.sendtime_secs;
	end
end

function MailManager.CanSend(mail)
	local self = MailManager;
	if(not mail)then return end

	--如果有发送的准确时间
	local send_exact_time_ms = Mail_GetSendExactTime(mail);

	if(send_exact_time_ms)then
		local date = self.date;
		local time = self.time;
		local now_millisecs = self.now_millisecs or 0;

		--具体哪一天
		if(mail.send_exact_date)then
			if(timehelp.IsSameDate(date,mail.send_exact_date))then
				if(now_millisecs >= send_exact_time_ms and now_millisecs < (send_exact_time_ms + 30000))then
					return checkFunc(mail);
				end
			end
		else
			--当天
			if(now_millisecs >= send_exact_time_ms and now_millisecs < (send_exact_time_ms + 30000))then
				return checkFunc(mail);
			end
		end
	else
		--游戏运行持续时间
		local sendtime = Mail_GetSendTimeSinceLast(mail);
		if(sendtime and self.run_secondes >= ((mail.last_sent_time or 0) + sendtime) )then
			return checkFunc(mail);
		end
	end
end

function MailManager.OnUpdate()
	local self = MailManager;
	local mails = MailList.SystemTimerMails;
	if(not mails)then return end
	local k,mail;
	local region_id = ExternalUserModule:GetRegionID();

	self.date = ParaGlobal.GetDateFormat("yyyy-MM-dd")
	self.time = ParaGlobal.GetTimeFormat("H:mm:ss");
	self.now_millisecs = timehelp.TimeStrToMill(self.time);

	for k,mail in pairs(mails) do
		if(not mail.disabled) then
			local canSend = self.CanSend(mail);
			--屏蔽邮件
			if(region_id and region_id ~= 0)then
				if(k == 9000 or k == 9002 or k == 9003 or k == 9004 or k == 9005 or k == 9006)then
					canSend = false;
				end
			end
			if(canSend)then
				if(MailList.RealNameContent[k])then
					local realname_node = 	MailList.RealNameContent[k];
					if(Player.IsRealName())then
						mail.content = realname_node.content_realname; 
					else
						mail.content = realname_node.content; 
					end
				end
				mail.id = k;
				mail.sendnum = mail.sendnum or 1;--默认发一次
				mail.sendmaxnum = mail.sendmaxnum or 1;--最多发送次数
				if(mail.sendnum <= mail.sendmaxnum)then
					--LOG.std("", "debug", "MailManager", "===========MailManager.PushMail");
					--LOG.std("", "debug", "MailManager", mail);
					MailManager.PushMail(mail);
				end
			end
		end
	end
	self.run_secondes = self.run_secondes + self.duration / 1000
end

function MailManager.GetSecondsFromStr(time)
	if(not time)then return end
	local __,__,hour,min,sec = string.find(time,"(.+):(.+):(.+)");
	return timehelp.GetSeconds(hour,min,sec);
end
function MailManager.PushMailByID(id)
	local self = MailManager;
	local mail = self.GetMail(id);
	self.PushMail(mail);
end
function MailManager.PushMail(msg)
	local self = MailManager;
	if(not msg or not self.systemMailPool)then return end
	local mail = msg;
	table.insert(self.systemMailPool,msg);
	local len = #self.systemMailPool;

	mail.sendnum = mail.sendnum + 1;
	mail.last_sent_time = self.run_secondes;

	if(mail.sendnum > mail.sendmaxnum) then
		mail.disabled = true;
	end
	if(type(mail.pre_send_func) == "function") then
		if(mail.pre_send_func(mail)==false) then
			return;
		end
	end

	MyCompany.Aries.Desktop.NotificationArea.ShowNoteBtn(true,len);
end
function MailManager.HasMail()
	local self = MailManager;
	local msgPool = self.systemMailPool;
	if(not msgPool)then return end
	local len = #msgPool;
	if(len > 0)then
		return true;
	end
end

function MailManager.GetLength()
	local self = MailManager;
	local msgPool = self.systemMailPool;
	if(not msgPool)then return end
	local len = #msgPool;
	return len;
end
--当前打开的邮件要显示的信息
function MailManager.GetCurMail()
	local self = MailManager;
	return self.cur_show_mail;
end

-- show and pop the first mail in the mail queue if any. 
-- @param onclose: nil or a callback function when page is closed. 
function MailManager.ShowMail(on_close)
	local self = MailManager;
	local msgPool = self.systemMailPool;
	if(not msgPool)then return end
	local len = #msgPool;
	
	local msg = msgPool[len];
	table.remove(msgPool,len);
	len =  #msgPool;
	LOG.std("", "debug", "MailManager", "show mail:");
	LOG.std("", "debug", "MailManager", msg);
	if(msg and msg.mail_page)then
		local page_params = {id = msg.id};
		if(msg.page_params)then
			page_params = msg.page_params;
		end
		local url = UrlHelper.BuildURLQuery(msg.mail_page, page_params);
		LOG.std("", "debug", "MailManager", url);
		self.cur_show_mail = msg;
		local show_pos = msg.show_pos or { align = "_ct", left = -920/2, top = -512/2, width = 920, height = 512, };
		self.mail_index = self.mail_index + 1;
		local params = {
			url = url, 
			name = "MailManager.ShowMail" .. self.mail_index, 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true,
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 0,
			allowDrag = false,
			directPosition = true,
				align = show_pos.align,
				x = show_pos.left,
				y = show_pos.top,
				width = show_pos.width,
				height = show_pos.height,
		};
		System.App.Commands.Call("File.MCMLWindowFrame", params);
		if(params._page) then
			params._page.OnClose = on_close;
		end
	end
	self.CheckIsEmpty();
end


function MailManager.CheckIsEmpty()
	local len = 0;
	len = len + MailManager.GetLength() or 0;
	if(len <= 0)then
		MyCompany.Aries.Desktop.NotificationArea.ShowNoteBtn(false,len);
	else
		MyCompany.Aries.Desktop.NotificationArea.ShowNoteBtn(true,len);
	end
end
function MailManager.GetLastAuthServerTime()
	local year, mon, day, hours, minutes, seconds = string.match(System.User.LastAuthServerTime, "^(.+)-(.+)-(.+)%s(.+):(.+):(.+)$");
	year = tonumber(year);
	mon = tonumber(mon);
	day = tonumber(day);
	hours = tonumber(hours);
	minutes = tonumber(minutes);
	seconds = tonumber(seconds);
	if(year and mon and day and hours and minutes and seconds)then
		return year, mon, day, hours, minutes,seconds
	end
end
function MailManager.GetMail(id)
	if(not id)then return end
	local mail = MailList.SystemTimerMails[id];
	if(mail)then
		mail.id = id;
		return mail;
	end
end
