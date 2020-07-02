--[[
Title: Desktop (Mini)Map Area for Aries App
Author(s): LiXizhi
Date: 2011/5/22
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/MapArea.lua");
MyCompany.Aries.Desktop.MapArea.Init();
-- call this on world load
MyCompany.Aries.Desktop.MapArea.OnWorldLoaded()
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp2.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/Map/LocalMap.lua");
NPL.load("(gl)script/apps/Aries/Mail/MailBox.lua");
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestPathfinderNavUI.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local LocalMap = commonlib.gettable("MyCompany.Aries.Desktop.LocalMap");
local MailBox = commonlib.gettable("MyCompany.Aries.Mail.MailBox");

-- create class
local MapArea = commonlib.gettable("MyCompany.Aries.Desktop.MapArea");
local QuestPathfinderNavUI = commonlib.gettable("MyCompany.Aries.Quest.QuestPathfinderNavUI");
local Player = commonlib.gettable("MyCompany.Aries.Player");

local auto_check_mail_interval = 120000;
local page;
NPL.load("(gl)script/apps/Aries/Mail/MailPage.lua");
local MailPage = commonlib.gettable("MyCompany.Aries.Mail.MailPage");
-- virtual function: Create UI
function MapArea.Create()
	local self = MapArea;
	local _parent = ParaUI.CreateUIObject("container", "MapArea", "_rt", -170, 0, 170, 220);
	_parent.background = "";
	_parent.zorder = -2;
	_parent:GetAttributeObject():SetField("ClickThrough", true);
	_parent:AttachToRoot();

	MapArea.ShowHuluOrNot();
	page = page or Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Desktop/MapArea/MapArea.teen.html",click_through = true,
		SelfPaint = System.options.IsMobilePlatform,
	});
	-- one can create a UI instance like this. 
	page:Create("Aries_MiniMapArea_mcml", _parent, "_fi", 0, 0, 0, 0);

	-- unread email count. 
	--NPL.load("(gl)script/apps/Aries/Mail/MailBox.lua");
	--MyCompany.Aries.Mail.MailBox:AddEventListener("unread_mail_change", function(self, event)
		--if(event.unread_mail) then
			--MapArea.Refresh_MailCnt(event.unread_mail);
		--end
	--end, MapArea, "MapArea");
end

local texdata = { 
    -- {left=18000,top=18000,right=22000,bottom=22000,background="Texture/Aries/WorldMaps/Teen/FlamingPhoenixIsland.png",}, 
};

function MapArea.DS_Func_MapTexture(index)
	if(index==nil)then
        return #texdata;
    else
        return texdata[index];
    end
end

function MapArea.OnInit()
	NPL.load("(gl)script/apps/Aries/Scene/AutoCameraController.lua");
	MyCompany.Aries.AutoCameraController:Init();
	if(Player) then
		local curMode = Player.LoadLocalData("CameraMode", "3d");
		
		MapArea.CheckEmail(5000);

		MyCompany.Aries.AutoCameraController:ApplyStyle(curMode);
		page:SetValue("btnCameraMode", curMode=="3d");
		
		-- load music state
		local bEnableMusic = MyCompany.Aries.Player.LoadLocalData("enable_music", true);
		if(bEnableMusic)then
			ParaAudio.SetVolume(1);
		else
			ParaAudio.SetVolume(0);
		end
		page:SetNodeValue("EnableSound", bEnableMusic);
	end
end

function MapArea.CheckEmail(nTimeToStart)
	if(MapArea.mail_timer) then
		MapArea.mail_timer:Change(nTimeToStart or 30000,auto_check_mail_interval);
	else
		MapArea.mail_timer = commonlib.Timer:new({callbackFunc = function(timer)
			if(MailPage.AutoCheckMail)then
				MailPage.AutoCheckMail(function(msg)
					if(msg and msg.cnt)then
						MapArea.Refresh_MailCnt(msg.cnt);
					end
				end)
			else
				MapArea.mail_timer:Change();		
			end
		end});
		MapArea.mail_timer:Change(nTimeToStart or 30000,auto_check_mail_interval);
	end
end
-- if a map is specified, and should be displayed. 
-- a instanced world has no map, and the map area displays a exit button by which to exit the current scene.  
function MapArea.HasLocalMap()
	return #texdata > 0;
end

-- this function should be called whenever the world is changed. 
function MapArea.OnActivateDesktop()
	if(page) then
		local cur_world = WorldManager:GetCurrentWorld();
		if(cur_world and cur_world.local_map_settings) then
			texdata[1] = cur_world.local_map_settings;
		else
			texdata[1] = nil;
		end
		MapArea.HighLightLeaveWorldBtn = nil;
		page:CallMethod("aries_mini_map", "ClearPoints");
		page:Refresh();
	end
	
	QuestPathfinderNavUI.RefreshTarget();
end

-- refresh camera mode
function MapArea.RefreshCameraMode(show_marker)
	if(page) then
		local Player = commonlib.getfield("MyCompany.Aries.Player");
		local curMode = Player.LoadLocalData("CameraMode", "") or "3d";
		if(curMode ~= "") then
			page:SetValue("btnCameraMode", curMode=="3d");
		end
		MapArea.IsShowCameraTip = show_marker;
		page:Refresh(0.01);
	end
end

function MapArea.HighLightLeaveWorld()
	MapArea.HighLightLeaveWorldBtn = true;
	page:Refresh();
end

-- virtual Public API:enable map teleporting button
function MapArea.EnableButton()
	-- TODO: enable: btn_teleport in mcml page
end

-- virtual Public API: disable map teleporting button
function MapArea.DisableButton()
	-- TODO: disable: btn_teleport in mcml page
end


-- get if other players are allowed to be drawn. 
function MapArea.IsRenderOtherPlayers()
	local cur_value = ParaScene.GetAttributeObject():GetField("MaxCharTriangles", System.options.MaxCharTriangles_show);
	return (cur_value > System.options.MaxCharTriangles_hide);
end

-- toggle render characters in the scene. 
function MapArea.ToggleRenderPlayers()
	if(MapArea.IsRenderOtherPlayers())  then
		ParaScene.GetAttributeObject():SetField("MaxCharTriangles", System.options.MaxCharTriangles_hide);
		if(page) then
			page:SetValue("btnTogglePlayers", false);
		end
	else
		ParaScene.GetAttributeObject():SetField("MaxCharTriangles", System.options.MaxCharTriangles_show);
		if(page) then
			page:SetValue("btnTogglePlayers", true);
		end
	end
end

-- toggle music. this is onclick callback
function MapArea.OnClickToggleMusic(bChecked)
	if(bChecked)then
		ParaAudio.SetVolume(1);
	else
		ParaAudio.SetVolume(0);
	end
	MyCompany.Aries.Player.SaveLocalData("enable_music",bChecked);
end

-- call this function to enable music programmatically. 
function MapArea.EnableMusic(bChecked)
	if(page) then
		page:SetValue("EnableSound", bChecked)
	end
	MapArea.OnClickToggleMusic(bChecked);
end

function MapArea.ShowCalendar()
	NPL.load("(gl)script/apps/Aries/Desktop/Calendar.teen.lua");
	local Calendar = commonlib.gettable("MyCompany.Aries.Desktop.Calendar");
	Calendar.ShowPage();
end


function MapArea.ShowMailBox()
	NPL.load("(gl)script/apps/Aries/Mail/MailPage.lua");
	local MailPage = commonlib.gettable("MyCompany.Aries.Mail.MailPage");
	MailPage.ShowPage();
end

function MapArea.Refresh_MailCnt(cnt)
	if(not page) then return end
	if(not cnt or MapArea.mailCount == cnt)then return end
	MapArea.mailCount = cnt;

	local _mailCount = page:FindControl("MailCount");
	if(_mailCount) then
		if(cnt == 0) then
			_mailCount.visible = false;
		else
			_mailCount.visible = true;
			_mailCount.text = tostring(cnt);
		end
	end
end


function MapArea.ShowRank()
	NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingListMain.teen.lua");
	local GoldRankingListMain = commonlib.gettable("MyCompany.Aries.GoldRankingList.GoldRankingListMain");
	GoldRankingListMain.ShowMainWnd()
end

-- virtual public API
-- @param name: the point name string
-- @param point: {x,y,text,rotation, tooltip, school, width, height, background,zorder }. if nil, it will clear the given point. 
-- @param bRefreshImmediate: true to refresh immediately. 
function MapArea.ShowPoint(name, point, bRefreshImmediate)
	if(page)then
		page:CallMethod("aries_mini_map", "ShowPoint", name, point, bRefreshImmediate);
		LocalMap.ShowPoint(name, point);
	end
end

function MapArea.Refresh()
	if(page)then
		page:Refresh(.1);
	end
end

local Show_Tip_AntiIndulgenceArea = 0;
function MapArea.ShowHelpTip()
    local _adult = Player.IsAdult();
    if (_adult == 0) then
		NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
		local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");
		local loot_scale = AntiIndulgenceArea.GetLootScale();
		if(loot_scale < 1)then
			--local cnt = MyCompany.Aries.Player.LoadLocalData("Show_Tip_AntiIndulgenceArea", 0)
			local cnt = Show_Tip_AntiIndulgenceArea;
			cnt = cnt or 0;
			if(cnt <= 5)then
				page:SetValue("TooltipsPPT", "tip_1")
				-- MyCompany.Aries.Player.SaveLocalData("Show_Tip_AntiIndulgenceArea", cnt + 1)
				Show_Tip_AntiIndulgenceArea = Show_Tip_AntiIndulgenceArea + 1;
			end
		end
	end
end
function MapArea.SetBtnTime(time)
	--if(QuestHelp.IsPowerUser(Map3DSystem.User.nid))then
		--return
	--end
	if(page)then
		MapArea.ShowHelpTip();
		page:SetValue("timeBtn",time);
	end
end

function MapArea.ShowHuluOrNot()
	NPL.load("(gl)script/apps/Aries/Desktop/MiJiuHuLu.teen.lua");
	local MiJiuHuLu = commonlib.gettable("MyCompany.Aries.Desktop.MiJiuHuLu");
	if (MiJiuHuLu.HasAllHulu()) then
		MapArea.showhulu = false;
	else
		MapArea.showhulu = true;
	end
end

function MapArea.ShowMijiuhulu(show)
	if(page) then
		local _hulu = page:FindControl("ElfGift");
		if(_hulu)then
			_hulu.visible = show;
		end
		page:SetUIValue("MiJiuHuLuTips", "");
	else
		local _hulu = ParaUI.GetUIObject("ElfGift");
		if(_hulu)then
			_hulu.visible = show;
		end
		local _hulutip = ParaUI.GetUIObject("MiJiuHuLuTips");
		if(_hulutip)then
			_hulutip.visible = show;
		end
	end
	MapArea.showhulu = show;
end

function MapArea.SetMiJiuHuLuTips(tips)
	if(page) then
		page:SetUIValue("MiJiuHuLuTips", tips);
	else
		local _hulutips = ParaUI.GetUIObject("MiJiuHuLuTips");
		if(_hulutips)then
			_hulutips.text = tips;
		end
	end
end

function MapArea.FlashMiJiuHuLu(bbounce)
	if(bbounce == false)then
		MapArea.BounceLower_Static_Icon("ElfGift","stop")
	else
		MapArea.BounceLower_Static_Icon("ElfGift","bouncelower")
	end	
end

function MapArea.Bounce_Static_Icon(name,bounce_or_stop)
	local _icon;
	if(page) then
		_icon = page:FindControl(name);
	else
		local _Area = ParaUI.GetUIObject("MapArea");
		if(_Area and _Area:IsValid() == true)  then
			_icon = _Area:GetChild(name);
		end
	end

	if(_icon and _icon:IsValid()) then
		if(bounce_or_stop == "bounce") then
			local fileName = "script/UIAnimation/CommonIcon.lua.table";
			UIAnimManager.LoadUIAnimationFile(fileName);
			UIAnimManager.PlayUIAnimationSequence(_icon, fileName, "Bounce", true);
		elseif(bounce_or_stop == "stop") then
			local fileName = "script/UIAnimation/CommonIcon.lua.table";
			UIAnimManager.LoadUIAnimationFile(fileName);
			UIAnimManager.StopLoopingUIAnimationSequence(_icon, fileName, "Bounce");
		end
	end
end

function MapArea.BounceLower_Static_Icon(name,bounce_or_stop)
	local _icon;
	if(page) then
		_icon = page:FindControl(name);
	else
		local _Area = ParaUI.GetUIObject("MapArea");
		if(_Area and _Area:IsValid() == true)  then
			_icon = _Area:GetChild(name);
		end
	end

	if(_icon and _icon:IsValid()) then
		if(bounce_or_stop == "bouncelower") then
			local fileName = "script/UIAnimation/CommonIcon.lua.table";
			UIAnimManager.LoadUIAnimationFile(fileName);
			UIAnimManager.PlayUIAnimationSequence(_icon, fileName, "BounceLower", true);
		elseif(bounce_or_stop == "stop") then
			local fileName = "script/UIAnimation/CommonIcon.lua.table";
			UIAnimManager.LoadUIAnimationFile(fileName);
			UIAnimManager.StopLoopingUIAnimationSequence(_icon, fileName, "BounceLower");
		end
	end
end