--[[
Title: Desktop AntiIndulgence Area for Aries App
Author(s): Leio
Revision: 2011.5.22 teen version API compatible by Xizhi
Date: 2010/07/30
See Also: script/apps/Aries/Desktop/AriesDesktop.lua
Area: 
	---------------------------------------------------------
	| Notification									Quest	|
	|														|
	| T														|
	| a													 	|
	| g													 	|
	| e													 	|
	| t													 	|
	| 													 S	|
	| 													 p	|
	| 													 e	|
	|													 c	|
	|													 i	|
	|													 a	|
	|													 l	|
	| 														|
	| Map		  | -------- Dock -------- |		Monthly	|
	---------------------------------------------------------
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
MyCompany.Aries.Desktop.AntiIndulgenceArea.Init();

NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");
local ItemManager = commonlib.gettable("System.Item.ItemManager");
local hasGSItem = ItemManager.IfOwnGSItem;
local hasItem,guid = hasGSItem(994)
if(hasItem)then
	local item = ItemManager.GetItemByGUID(guid);
	local date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local used_sec = 1 * 3600*1000;
	local info = {date = date,used_sec = used_sec,}
	local clientdata = commonlib.serialize_compact2(info);	
	System.User.used_sec_load = used_sec;
	AntiIndulgenceArea.used_sec	 = used_sec;
	ItemManager.SetClientData(guid,clientdata,function(msg)
		AntiIndulgenceArea.UpdateUI();
	end);
end
------------------------------------------------------------
]]
local MapArea = commonlib.gettable("MyCompany.Aries.Desktop.MapArea");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
local ItemManager = commonlib.gettable("System.Item.ItemManager");
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local Player = commonlib.gettable("MyCompany.Aries.Player");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local NPCTipsPage = commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea.NPCTipsPage");

-- create class
local AntiIndulgenceArea = commonlib.createtable("MyCompany.Aries.Desktop.AntiIndulgenceArea", {
	isEnabled_music = true,
	timer = nil,
	date = nil,--今天的日期 "2010-01-01"
	used_sec = nil,--今天消耗的时间 毫秒
});

AntiIndulgenceArea.name = "AntiIndulgenceArea_instance";

-- invoked at Desktop.InitDesktop()
function AntiIndulgenceArea.Init()
	NPL.load("(gl)script/apps/Aries/Desktop/MapArea.lua");
	NPL.load("(gl)script/apps/Aries/Quest/QuestHelp2.lua");
	NPL.load("(gl)script/apps/Aries/Scene/main.lua");
	NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
	NPL.load("(gl)script/ide/TooltipHelper.lua");
	NPL.load("(gl)script/apps/Aries/Desktop/NotificationArea/NPCTipsPage.lua");

	local self = AntiIndulgenceArea;
	if(System.options.version == "kids" and (System.options.theme ~= "v2")) then
		local _area = ParaUI.CreateUIObject("container", self.name.."AntiIndulgenceArea", "_rb", -95, -55, 83, 34);
		_area.background = "Texture/Aries/Combat/CombatState/timer_32bits.png; 0 0 83 34";
		_area:AttachToRoot();

		local btn = ParaUI.CreateUIObject("button", self.name.."btn", "_lt", 7,7,21,22);
		btn.background = "Texture/Aries/Combat/CombatState/close_32bits.png; 0 0 21 22";
		btn.onclick = ";MyCompany.Aries.Desktop.AntiIndulgenceArea.OnClickEnableSound();";
		btn.zorder = 1;
		_area:AddChild(btn);

		local _txt = ParaUI.CreateUIObject("button", self.name.."txt", "_ctt", 12, 2, 60, 30);
		_txt.font= "System;12";
		_txt.background = "";
		_guihelper.SetFontColor(_txt, "255 255 255")
		_guihelper.SetUIFontFormat(_txt, 5);
		_area:AddChild(_txt);
		-- _txt.tooltip = "剩余战斗时间";
		
		--加载背景音乐状态
		self.LoadMusicState();
	end
	self.UpdateUI();
	if(not self.timer)then
		self.timer = commonlib.Timer:new({callbackFunc = function(timer)
			local remained_sec = self.GetRemainedSec();
			--NOTE:持续记录用户当天在线时间
			--if(remained_sec and remained_sec > 0)then
				if(self.date and self.used_sec)then
					self.used_sec = self.used_sec + timer.delta;
					self.SaveTime();
					self.UpdateUI();
					self.ShowTip();
				end
			--end
		end})
	end
	self.LoadTime(function()
		if(self.used_sec)then
			self.used_sec = self.used_sec - 60000;
			if(self.used_sec < 0)then
				self.used_sec = 0;
			end
		end
		--启动计时器

		self.timer:Change(0,60000);
	end);

	--初始化副本CD
	NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
	local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
	LobbyClientServicePage.DoLoadWorldInstanceCnt();
end
function AntiIndulgenceArea.LoadMusicState()
	local self = AntiIndulgenceArea;
	local key = string.format("Aries_AntiIndulgenceArea_Music_%d",System.User.nid or 0);
	local b = MyCompany.Aries.Player.LoadLocalData(key, true);
	self.isEnabled_music = not b;
	self.OnClickEnableSound();
end
--记录背景音乐状态：开启or关闭
function AntiIndulgenceArea.SetMusicState(b)
	local self = AntiIndulgenceArea;
	local key = string.format("Aries_AntiIndulgenceArea_Music_%d",System.User.nid or 0);
	MyCompany.Aries.Player.SaveLocalData(key,b);
end
function AntiIndulgenceArea.LoadTime(callbackFunc)
	local self = AntiIndulgenceArea;
		local gsid = 994;
		local bagFamily = 1002;

		System.User.used_sec_load = 0;

		ItemManager.GetItemsInBag(bagFamily, "994_AntiIndulgenceTag", function(msg)
				local hasGSItem = ItemManager.IfOwnGSItem;
				local hasItem,guid = hasGSItem(gsid);
				if(hasItem)then
					local item = ItemManager.GetItemByGUID(guid);
					if(item)then
						local clientdata = item.clientdata;
						LOG.std("", "system", "AntiIndulgence", clientdata);
						if(clientdata == "")then
							clientdata = "{}"
						end
						LOG.std("", "system", "AntiIndulgence", "==========before commonlib.LoadTableFromString(clientdata) in 994_AntiIndulgenceTag");
						clientdata = commonlib.LoadTableFromString(clientdata) or {};
						LOG.std("", "system", "AntiIndulgence", "==========after commonlib.LoadTableFromString(clientdata) in 994_AntiIndulgenceTag");
						LOG.std("", "system", "AntiIndulgence", clientdata);
						
						if(clientdata and type(clientdata) == "table")then
							local info = clientdata;
							local date = info.date;
							local used_sec = info.used_sec;

							local today = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
							--如果没有记录
							if(not date)then
								self.date = today;
								self.used_sec = 0;
							else
								--如果是第二天,从新开始记录
								if(date ~= today)then
									self.date = today;
									self.used_sec = 0;
								else
									self.date = date;
									self.used_sec = used_sec;
								end
							end
							System.User.used_sec_load = self.used_sec or 0;

							if(callbackFunc and type(callbackFunc) == "function")then
								callbackFunc({
								});
							end
						end
					
					end
				end
			end, "access plus 1 minutes");
end
--clientdata is a table
function AntiIndulgenceArea.SaveTime(callbackFunc)
	local self = AntiIndulgenceArea;
	local gsid = 994;
	local bagFamily = 1002;
	LOG.std("", "system", "serverselect", "=========before save 994_AntiIndulgenceTag");
	ItemManager.GetItemsInBag(bagFamily, "994_AntiIndulgenceTag", function(msg)
		local hasGSItem = ItemManager.IfOwnGSItem;
		local hasItem,guid = hasGSItem(gsid)
		if(hasItem)then
			local item = ItemManager.GetItemByGUID(guid);
			if(item)then
				paraworld.auth.Ping({}, "getsvrtime", function(msg)
					LOG.std(nil, "system", "getsvrtime", "get ...%s", commonlib.serialize_compact(msg));
					if(msg.srvtime) then
						local svrtime = msg.srvtime;
						local hh,mm,ss = string.match(svrtime,"(%d+):(%d+):(%d+)");
						if (not System.User.login_time) then
							System.User.login_time= hh*3600 + mm*60 + ss;
							self.used_sec = System.User.used_sec_load;  -- ms
						else
							self.used_sec = System.User.used_sec_load + (hh*3600 + mm*60 + ss - System.User.login_time)*1000;  --ms
						end
					else
						self.used_sec = System.User.used_sec_load;
					end
					--序列化
					local date = self.date;
					local used_sec = self.used_sec;
					local info = {
						date = date,
						used_sec = used_sec,
					}
					local clientdata = commonlib.serialize_compact2(info);
						LOG.std("", "system", "AntiIndulgence", "============after save 994_AntiIndulgenceTag");
						LOG.std("", "system", "AntiIndulgence", clientdata);
					ItemManager.SetClientData(guid,clientdata,function(msg_setclientdata)
						LOG.std("", "system", "AntiIndulgence", "============after save 994_AntiIndulgenceTag");
						LOG.std("", "system", "AntiIndulgence", msg_setclientdata);
						if(callbackFunc and type(callbackFunc) == "function")then
							callbackFunc({
								
							});
						end
					end);
				end, "access plus 0 day");
			end
		end
	end, "access plus 30 minutes");
end
-- show or hide the map area, toggle the visibility if bShow is nil
function AntiIndulgenceArea.Show(bShow)
	if(System.options.version ~= "kids") then
		return
	end
	local self = AntiIndulgenceArea;
	local _area = ParaUI.GetUIObject(self.name.."AntiIndulgenceArea");
	if(_area:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _area.visible;
		end
		_area.visible = bShow;
	end
end
--由系统设置面板更改
function AntiIndulgenceArea.OnClickEnableSound_BySetting(bChecked)
	local self = AntiIndulgenceArea;
	self.isEnabled_music = not bChecked;
	if(self.isEnabled_music)then
		self.isEnabled_music = false;
		ParaAudio.SetVolume(0);
	else
		self.isEnabled_music = true;
		ParaAudio.SetVolume(1);
	end
	self.UpdateUI();
	self.SetMusicState(self.isEnabled_music);
end
function AntiIndulgenceArea.OnClickEnableSound()
	local self = AntiIndulgenceArea;
	if(self.isEnabled_music)then
		self.isEnabled_music = false;
		ParaAudio.SetVolume(0);
	else
		self.isEnabled_music = true;
		ParaAudio.SetVolume(1);
	end
	self.UpdateUI();
	self.SetMusicState(self.isEnabled_music);
	NPL.load("(gl)script/apps/Aries/Desktop/AriesSettingsPage.lua");
	MyCompany.Aries.Desktop.AriesSettingsPage.OnClickEnableSound_ByArea(self.isEnabled_music);
end

function AntiIndulgenceArea.UpdateUI()
	local self = AntiIndulgenceArea;
	local system_looptip = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips.system_looptip");
	local btn = ParaUI.GetUIObject(self.name.."btn");
	if(btn and btn:IsValid())then
		if(self.isEnabled_music)then
			btn.background = "Texture/Aries/Combat/CombatState/open_32bits.png; 0 0 26 26";
			btn.tooltip = "关闭音乐";
		else
			btn.background = "Texture/Aries/Combat/CombatState/close_32bits.png; 0 0 26 26";
			btn.tooltip = "打开音乐";
		end
	end
	local remained_sec = self.GetRemainedSec();
	local _txt = ParaUI.GetUIObject(self.name.."txt");
	if(_txt and _txt:IsValid())then
		local s = commonlib.timehelp.MillToTimeStr(remained_sec,"h-m") or "";
		_txt.text = s;
		local time_tip_str = "";
		if(remained_sec <= 60)then
			_txt:GetFont("text").color = "255 0 0";
			time_tip_str = "今天已经没有战斗时间了！";

			-- 启动主动提醒
			NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
			local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
			if (not system_looptip.notime_tip) then
				system_looptip.notime_tip=true;
				local tiptype;			
				local r = math.ceil(ParaGlobal.random()*100);
				local c = r%2;
				if (c==1) then
					tiptype="GetTime1";
				else
					tiptype="GetTime2";
				end
				AutoTips.ShowPage(tiptype);
			end
		else
			time_tip_str  = string.format("战斗剩余时间:%s",s);
		end
		_txt.tooltip = time_tip_str;
	end
	self.AutoShowMail(); 
	local time = commonlib.timehelp.MillToTimeStr(remained_sec,"h-m") or "";
	if(MapArea.SetBtnTime)then
		MapArea.SetBtnTime(time);
	end

	if (System.options.version == "kids") then
		NPL.load("(gl)script/apps/Aries/Desktop/MiJiuHuLu.lua");
	else
		NPL.load("(gl)script/apps/Aries/Desktop/MiJiuHuLu.teen.lua");
	end
	local MiJiuHuLu = commonlib.gettable("MyCompany.Aries.Desktop.MiJiuHuLu");
	local time = AntiIndulgenceArea.GetUsedSec();
	if(MiJiuHuLu.UpdataTime)then		
		MiJiuHuLu.UpdataTime(time);		
	end

	if(System.options.version == "kids") then
		NPL.load("(gl)script/apps/Aries/Desktop/Functions/FateCard.lua");
		local FateCard = commonlib.gettable("MyCompany.Aries.Desktop.FateCard");
		--local time = AntiIndulgenceArea.GetUsedSec();
		if(FateCard.UpdataTime)then		
			--echo("00000000000000");
			--echo(time);
			FateCard.UpdataTime(time);		
		end
	end

	local current_time = MyCompany.Aries.Scene.GetElapsedSecondsSince0000();
	local bean = MyCompany.Aries.Pet.GetBean();
	local mylevel;
	if(bean) then
		mylevel = bean.combatlel or 0;
	end
	
	-- 19:00 以后，40级以上50级以下,青年版提醒英雄谷战场开放
	if (current_time>68400 and mylevel>=40 and mylevel<50 and System.options.version=="teen" and (not system_looptip.redmushroom_tip)) then
		system_looptip.redmushroom_tip = true;
		NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
		local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
		AutoTips.ShowPage("BattleField");
		--AutoTips.ShowPage("RedMushroom");
	end
	-- frame move
	NPCTipsPage.OnFrameMove(); 
end

function AntiIndulgenceArea.IsInHoliday()
	local self = AntiIndulgenceArea;
	local date = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	--local year, month, day = string.match(date, "^(%d+)%-(%d+)%-(%d+)$");
	--local week = Scene.GetDayOfWeek();
	--if(year and month and day) then
		--year = tonumber(year);
		--month = tonumber(month);
		--day = tonumber(day);
		--if(month == 7 or month == 8 or week == 1 or  week == 6 or  week == 7 or (month == 3 and day == 30))then
			--return true;
		--end
	--end
	NPL.load("(gl)script/ide/TooltipHelper.lua");
	local HolidayHelper = commonlib.gettable("CommonCtrl.HolidayHelper");
	local b = HolidayHelper.IsHoliday(date,CommonClientService.IsTeenVersion())
	return b;
end
function AntiIndulgenceArea.GetTotalSeconds()
	local self = AntiIndulgenceArea;
	if(self.IsInHoliday())then
		return 5 * 60 * 60 * 1000;
	else
		return 2 * 60 * 60 * 1000;
	end
end
--今天使用的时间 返回的是秒
function AntiIndulgenceArea.GetUsedTime()
	local self = AntiIndulgenceArea;
	local time = self.GetUsedSec();
	time = math.floor(time/1000);
	return time;
end
--今天使用的时间 返回的是毫秒
function AntiIndulgenceArea.GetUsedSec()
	local self = AntiIndulgenceArea;
	local used_sec = self.used_sec or 0;
	return used_sec;
end
--今天剩余的时间
function AntiIndulgenceArea.GetRemainedSec()
	if(Player.IsRealName())then
		return 3600;
	end
	local self = AntiIndulgenceArea;
	local totalSeconds = self.GetTotalSeconds();
	local used_sec = self.used_sec or 0;
	local remained_sec = totalSeconds - used_sec;
	remained_sec = math.max(0,remained_sec);

	return remained_sec;
end
--放沉迷是否有效
function AntiIndulgenceArea.IsAntiSystemIsEnabled()
	local self = AntiIndulgenceArea;
	if(Player.IsRealName())then
		return;
	end
	--if(QuestHelp.IsPowerUser(Map3DSystem.User.nid))then
		--return;
	--end
	local remained_sec = self.GetRemainedSec();
	if(remained_sec <= 60)then
		return true;
	end	
end
function AntiIndulgenceArea.AutoShowMail()
	local self = AntiIndulgenceArea;
	local remained_sec = self.GetRemainedSec();
	if(remained_sec <= 60)then
		if(not self.show_time_mail)then
			NPL.load("(gl)script/apps/Aries/Mail/MailManager.lua");
			MyCompany.Aries.Quest.Mail.MailManager.PushMailByID(10003);
			self.show_time_mail = true;
		end
	end
end
function AntiIndulgenceArea.ShowMail()
	local date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local key = string.format("Aries_AntiIndulgenceArea_ShowMail_%s",date);
	local b = MyCompany.Aries.Player.LoadLocalData(key, false);
	if(not b)then
		MyCompany.Aries.Player.SaveLocalData(key,true);
		NPL.load("(gl)script/apps/Aries/Mail/MailManager.lua");
		MyCompany.Aries.Quest.Mail.MailManager.PushMailByID(10003);
	end
end
--[[
	1.	周一至周四。淘米实施更为严格的防沉迷标准，超过2小时即无任何收益（包括对战、任务、小游戏等）
	2.	周五至周日。
		1)	3小时以内。正常收益。
		2)	4-5小时。所有收益减半（包括对战、任务、小游戏等）
		3)	5小时以上。即无任何收益（包括对战、任务、小游戏等）
--]]
function AntiIndulgenceArea.GetLootScale()
	local self = AntiIndulgenceArea;
	local scale = 1;
	--实名用户 和 特殊用户
	--if(Player.IsRealName() or QuestHelp.IsPowerUser(Map3DSystem.User.nid))then
		--return scale;
	--end
	--实名用户
	if(Player.IsRealName())then
		return scale;
	end
	local used_sec = self.GetUsedTime();
	local is_holiday = self.IsInHoliday()
	if(not is_holiday)then
		if(used_sec >= 3600 * 2)then
			scale = 0;
		end
	else
		if(used_sec >= 3600 * 3 and used_sec < 3600 * 5 )then
			scale = 0.5
		elseif(used_sec >= 3600 * 5)then
			scale = 0;
		end		
	end
	return scale;
end
function AntiIndulgenceArea.ShowTip()
	local self = AntiIndulgenceArea;
	local is_holiday = self.IsInHoliday()
	if(CommonClientService.IsTeenVersion())then
		local s;
		if(not Player.IsRealName())then
			local used_sec = self.GetUsedTime();
			local a_start = commonlib.timehelp.GetSeconds(1,0,0);
			local a_end = commonlib.timehelp.GetSeconds(1,59,0);
			if(used_sec >= a_start and used_sec <= a_end)then
				s = "您尚未实名认证,今日累计在线1小时,累计3小时后收益减半,5小时后收益为零!"
			end
			local b_start = commonlib.timehelp.GetSeconds(2,0,0);
			local b_end = commonlib.timehelp.GetSeconds(2,59,0);
			if(used_sec >= b_start and used_sec <= b_end)then
				s = "您尚未实名认证,今日累计在线2小时,累计3小时后收益减半,5小时后收益为零!"
			end
		end
		local loot_scale = AntiIndulgenceArea.GetLootScale();
		if(is_holiday)then
			if(loot_scale == 0)then
				s = "你今天累计在线时间已超过5小时，不再能获得任何战斗收益！"
			elseif(loot_scale == 0.5)then
				s = "你今天累计在线时间已超过3个小时，战斗收益减半！"
			end	
		else
			if(loot_scale == 0)then
				s = "你今天累计在线时间已超过2小时，不再能获得任何战斗收益！"
			end
		end
		if(s)then
			BroadcastHelper.PushLabel({
									label = s,
									shadow = true,
									bold = true,
									font_size = 14,
									scaling = 1.2,
									color="255 0 0",
									background = "Texture/Aries/Common/gradient_white_32bits.png",background_color = "#1f3243",
								});
		end
	end
end
