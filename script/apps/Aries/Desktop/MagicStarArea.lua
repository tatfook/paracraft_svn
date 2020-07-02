--[[
Title: For magic star and shop. 
Author(s): Leio
Date: 2010/10/27
Desc: This area is only used in kids version. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/MagicStarArea.lua");
local MagicStarArea = commonlib.gettable("MyCompany.Aries.Desktop.MagicStarArea");
MagicStarArea.Init();
MagicStarArea.AttachToRoot();
MagicStarArea.Bounce_Static_Icon("bounce");
MagicStarArea.Bounce_Static_Icon("stop");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.lua");
NPL.load("(gl)script/apps/Aries/Pet/main.lua");
local Pet = commonlib.gettable("MyCompany.Aries.Pet");
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/ide/TooltipHelper.lua");
NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatWindow.lua");
local TooltipHelper = commonlib.gettable("CommonCtrl.TooltipHelper");
-- create class
local MagicStarArea = commonlib.gettable("MyCompany.Aries.Desktop.MagicStarArea");
local btn_id;
MagicStarArea.name = "EXPArea_instance";
-- invoked at Desktop.InitDesktop()
function MagicStarArea.Init()
	if(System.options.version~="kids") then
		return;
	end
	if(System.options.theme == "v2") then
		return;
	end
	local self = MagicStarArea;
	--local _area = ParaUI.CreateUIObject("container", self.name.."MagicStarArea", "_rb", -75, -218, 47, 165);
	local _area = ParaUI.CreateUIObject("container", self.name.."MagicStarArea", "_rb", -75, -163, 47, 96);
	_area.background = "";
	_area:AttachToRoot();

	local tooltip = self.GetTooltip();
	local btn = ParaUI.CreateUIObject("button", self.name.."btn", "_lt", 3,0,45,45);
	btn.background = "Texture/Aries/Dock/Web/magic_star_32bits.png; 0 0 45 45";
	btn.onclick = ";MyCompany.Aries.Desktop.MagicStarArea.DoClick();";
	btn.animstyle = 22;
	_area:AddChild(btn);
	self.SetTimer();
	btn_id = btn.id;
	TooltipHelper.BindObjTooltip(btn_id,"script/apps/Aries/Desktop/MagicStarArea.html",-200,-70,10,10,2000, true, true, true, true);

	local tooltip = self.GetTooltip();
	local btn = ParaUI.CreateUIObject("button", self.name.."shop_btn", "_lt", -3,50,52,55);
	--btn.background = "Texture/Aries/HaqiShop/ShopIcon_32bits.png; 0 0 48 55";
	btn.background = "Texture/Aries/HaqiShop/shop2_32bits.png; 0 0 52 55";
	btn.onclick = ";MyCompany.Aries.HaqiShop.ShowMainWnd();";
	btn.tooltip= "哈奇商城";
	btn.animstyle = 22;
	_area:AddChild(btn);

	--local btntest = ParaUI.CreateUIObject("button", self.name.."test_btn", "_lt", 0,105,48,55);
	--btntest.background = "Texture/Aries/HaqiShop/ShopIcon_32bits.png; 0 0 48 55";
	--btntest.onclick = ";MyCompany.Aries.ChatSystem.ChatWindow.SwitchShow();";
	--btntest.tooltip= "聊天测试";
	--btntest.animstyle = 22;
	--_area:AddChild(btntest);
end

-- public api: bring the zorder to top
function MagicStarArea.AttachToRoot(zorder)
	local self = MagicStarArea;
	local _area = ParaUI.GetUIObject(self.name.."MagicStarArea");
	if(_area and _area:IsValid())then
		_area.zorder = zorder or 10
	end
end

function MagicStarArea.DoHideTooltip()
	local self = MagicStarArea;
	TooltipHelper.HideObjTooltip(btn_id);
end
function MagicStarArea.DoClick()
	local self = MagicStarArea;
	--MyCompany.Aries.Desktop.MagicStarArea.OnShowMagicPanel();
	MyCompany.Aries.Desktop.Dock.ShowCharPage(5);

	if(self.is_bounce)then
		self.Bounce_Static_Icon("stop");
		self.is_bounce = false;
		self.SetTimer();
	end
	self.DoHideTooltip();
end

-- public api: show or hide the map area, toggle the visibility if bShow is nil
function MagicStarArea.Show(bShow)
	if(System.options.version~="kids") then
		return;
	end

	local self = MagicStarArea;
	local _hpBottleArea = ParaUI.GetUIObject(self.name.."MagicStarArea");
	if(_hpBottleArea:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _hpBottleArea.visible;
		end
		_hpBottleArea.visible = bShow;
	end
end

function MagicStarArea.OnShowMagicPanel()
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	if(not DealDefend.CanPass())then
        return
    end
	NPL.load("(gl)script/apps/Aries/Help/MagicStarHelp/MagicStarHelp.lua");
	MyCompany.Aries.Help.MagicStarHelp.ShowPage();
end

function MagicStarArea.GetNewBounceDuration()
	local self = MagicStarArea;
	local index = math.random(5);
	local bounce_duration = index * 60000;
	return bounce_duration;
end

function MagicStarArea.SetTimer()
	local self = MagicStarArea;
	local static_duration = 5000;
	if(not self.timer)then
		self.timer = commonlib.Timer:new({callbackFunc = function(timer)
			self.cur_runsec = self.cur_runsec + static_duration;
			if(self.cur_runsec >= static_duration * 2 and self.is_bounce)then
				self.Bounce_Static_Icon("stop");
				self.is_bounce = false;
			elseif(self.cur_runsec >= self.total_runsec and not self.is_bounce)then
				self.total_runsec =  self.GetNewBounceDuration();
				self.Bounce_Static_Icon("bounce");
				self.is_bounce = true;
				self.cur_runsec = 0;

			end
		end})
	end	
	self.cur_runsec = 0;
	self.total_runsec = self.GetNewBounceDuration();
	self.timer:Change(0,static_duration);
end

function MagicStarArea.Bounce_Static_Icon(bounce_or_stop)
	local self = MagicStarArea;
	local _icon = ParaUI.GetUIObject(self.name.."btn");
	if(_icon and _icon:IsValid() == true) then
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

function MagicStarArea.GetTooltip()
	local self = MagicStarArea;
	local bean = Pet.GetBean();
	local s = "";
	if(bean)then
		local m = bean.m or 0;
		local energy = bean.energy or 0;
		local mlel = bean.mlel or 0;
		if(m == 0 and energy == 0)then
			s = "魔法星拥有神奇的本领，快用能量石激活魔法星的魔力吧！";
		else
			s = string.format("魔法星:%d级\r\n能量值剩余:%d天",mlel,energy);
		end
	end
	return s;
end

function MagicStarArea.OnClickBecomeVIP()
	if(System.options.version == "kids") then
		Map3DSystem.Item.ItemManager.UseOrBuy_EnergyStone();
	else
		_guihelper.MessageBox("你还不是魔法星用户，获得能量石即可成为魔法星用户(VIP会员)尊享多种游戏特权！你现在需要购买能量石吗？", function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				-- purchase enery stone directly
				Map3DSystem.mcml_controls.pe_item.OnClickGSItem(998,true);
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	end
end