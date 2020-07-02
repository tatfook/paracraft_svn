--[[
Title: FreeGrabManager
Author(s): Leio
Date: 2009/7/31
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/FreeGrab/FreeGrabManager.lua");
local grab_manager = Map3DSystem.App.FreeGrab.FreeGrabManager:new();
grab_manager:ShowMainPage();
--grab_manager:Play(1);
--Map3DSystem.App.FreeGrab.FreeGrabManager.grab_manager = grab_manager;
--Map3DSystem.App.FreeGrab.FreeGrabManager.grab_manager:Play(1);
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/FreeGrab/Pages/FreeGrabOptionPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/FreeGrab/Pages/FreeGrabMainPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/FreeGrab/FreeGrabCore.lua");
NPL.load("(gl)script/ide/TextSprite.lua");
local FreeGrabManager ={
	free_grab = nil,
}  
commonlib.setfield("Map3DSystem.App.FreeGrab.FreeGrabManager",FreeGrabManager);
function FreeGrabManager:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self;
	o:OnInit();
	return o
end
function FreeGrabManager:OnInit()
	local name = ParaGlobal.GenerateUniqueID();
	self.name = name;
	CommonCtrl.AddControl(name,self);
	self.free_grab = Map3DSystem.App.FreeGrab.FreeGrabCore:new();
	self.free_grab.manager = self;
	self.free_grab.TimeOverFunc = Map3DSystem.App.FreeGrab.FreeGrabManager.TimeOverFunc;
	self.free_grab.GameStartFunc = Map3DSystem.App.FreeGrab.FreeGrabManager.GameStartFunc;
	self.free_grab.GameReadyUpdateFunc = Map3DSystem.App.FreeGrab.FreeGrabManager.GameReadyUpdateFunc;
	self.free_grab.GameUpdateFunc = Map3DSystem.App.FreeGrab.FreeGrabManager.GameUpdateFunc;
	
	self.LastWorldPath = string.sub(ParaWorld.GetWorldDirectory(), 1, -2);
	local x, y, z = ParaScene.GetPlayer():GetPosition();
	self:SetTeleportBackPosition(x, y, z);
end
function FreeGrabManager:Away()
	self:Stop();
	self:Close();
	-- º”‘ÿ≥°æ∞
	local commandName = System.App.Commands.GetDefaultCommand("LoadWorld");
	System.App.Commands.Call(commandName, {
		worldpath = self.LastWorldPath,
		PosX = self.LastWorldPosX,
		PosY = self.LastWorldPosY,
		PosZ = self.LastWorldPosZ,
	});
end
function FreeGrabManager:Play(level)
	level = level or 1;
	if(self.free_grab:SetLevel(level))then
		self.free_grab:Start();
		self:Show();
	end
end
function FreeGrabManager:Pause()
	self.free_grab.isStart = false;
end
function FreeGrabManager:Resume()
	self.free_grab.isStart = true;
end
function FreeGrabManager:Stop()
	self.free_grab:Stop()
end
function FreeGrabManager.TimeOverFunc(grab)
	if(grab and grab.manager)then
		local self = grab.manager;
		commonlib.echo("time over");
	end
end
function FreeGrabManager.GameStartFunc(grab)
	if(grab and grab.manager)then
		local self = grab.manager;
		local name = self.name.."text_sprite";
		local ctl = CommonCtrl.GetControl(name);
		if(ctl)then
			ctl:Show(false);
		end
		--commonlib.echo("time start");
	end
end
function FreeGrabManager.GameReadyUpdateFunc(grab,msg)
	if(grab and grab.manager)then
		local self = grab.manager;
		self:UpdateReadyBg(msg)
		--local s = string.format("game ready update:%d/%d",msg.cur_step,msg.total_step);
		--commonlib.echo(s);
	end
end
function FreeGrabManager.GameUpdateFunc(grab,msg)
	if(grab and grab.manager)then
		local self = grab.manager;
		self:Update(msg);
		--local s = string.format("game update:%d-%d-%d %d/%d",msg.goldenScore,msg.silverScore,msg.clockScore,msg.cur_time,msg.total_time);
		--commonlib.echo(s);
	end
end
function FreeGrabManager:ShowMainPage()
	NPL.load("(gl)script/kids/3DMapSystemUI/FreeGrab/Pages/FreeGrabMainPage.lua");
	Map3DSystem.App.FreeGrab.FreeGrabMainPage.Bind(self,self.free_grab);
	Map3DSystem.App.FreeGrab.FreeGrabMainPage.ShowPage();
end
function FreeGrabManager:Close()
	local p = ParaUI.GetUIObject(self.name);
	if(p and p:IsValid())then
		ParaUI.Destroy(self.name);
	end
end
function FreeGrabManager:Show()
	self:Close();
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	local parent = ParaUI.CreateUIObject("container", self.name, "_fi", 0,0,0,0);
	parent.background = "";
	parent:AttachToRoot();
	
	--level_text
	local align,left,top,width,height = "_lt",10,10,100,100;
	local _this = ParaUI.CreateUIObject("button", self.name.."level_text", align,left,top,width,height);
	parent:AddChild(_this);
	--score_text
	local align,left,top,width,height = "_lt",10,110,100,100;
	local _this = ParaUI.CreateUIObject("button", self.name.."score_text", align,left,top,width,height);
	parent:AddChild(_this);
	--menu_btn
	local align,left,top,width,height = "_lb",10,-100,100,100;
	local _this = ParaUI.CreateUIObject("button", self.name.."menu_btn", align,left,top,width,height);
	_this.text = "Menu";
	_this.onclick = string.format(";Map3DSystem.App.FreeGrab.FreeGrabManager.DoMenu('%s');",self.name);
	parent:AddChild(_this);
	--progressbar
	local name = self.name.."progressbar"
	NPL.load("(gl)script/ide/progressbar.lua");
	local ctl = CommonCtrl.progressbar:new{
			name = name,
			alignment = "_rt",
			left = 400 - screenWidth - 20,
			top = 40,
			width = 400,
			height = 24,
 			parent = parent,
			Minimum = 0,
			Maximum = 100,
			Step = 10,
			Value = 0,
			block_bg = "Texture/3DMapSystem/Loader/progressbar_filled.png: 7 7 13 7",
			container_bg = "Texture/3DMapSystem/Loader/progressbar_bg.png:7 7 6 6",
			block_color = "255 255 255",
		};
	ctl:Show();
	ctl:SetValue(100);
	CommonCtrl.AddControl(name,ctl);
	--text_sprite
	local name = self.name.."text_sprite"
	NPL.load("(gl)script/ide/TextSprite.lua");
	local align,left,top,width,height = "_lt",(screenWidth - 150)/2,(screenHeight - 31)/2,150,31;
	local ctl = CommonCtrl.TextSprite:new{
		name = name,
		alignment = align,
		left =left,
		top = top,
		width = width,
		height = height,
		parent = parent,
		text = "0123456789 ABCDEF",
	};
	ctl:Show(false);
	ctl:SetText("");
	CommonCtrl.AddControl(name,ctl);
end
function FreeGrabManager:UpdateReadyBg(msg)
	if(not msg)then return end
	local num = msg.total_step - msg.cur_step;
	num = num - 1;
	local name = self.name.."text_sprite";
	local ctl = CommonCtrl.GetControl(name);
	local s_num;
	if(ctl and num)then
		if(num == 0)then
			s_num = "A";
		else
			s_num = tostring(num);
		end
		ctl:Show(true);
		ctl:SetText(s_num);
	end
end
function FreeGrabManager:Update(msg)
	if(not msg)then return end
	local name = self.name.."score_text";
	local ctl = ParaUI.GetUIObject(name);
	if(ctl and ctl:IsValid())then
		local s = string.format("%d-%d-%d",msg.goldenScore,msg.silverScore,msg.clockScore);
		ctl.text = s;
	end
	name = self.name.."level_text";
	ctl = ParaUI.GetUIObject(name);
	if(ctl and ctl:IsValid())then
		local s = string.format("%s",msg.level);
		ctl.text = s;
	end
	
	name = self.name.."progressbar";
	ctl = CommonCtrl.GetControl(name);
	if(ctl and msg.cur_time and msg.total_time)then
		local percent = math.floor(100 * msg.cur_time/msg.total_time);
		ctl:SetValue(100 - percent);
	end
	
end
function FreeGrabManager.DoMenu(sName)
	local self = CommonCtrl.GetControl(sName);
	if(self)then
		self:Pause();
		Map3DSystem.App.FreeGrab.FreeGrabOptionPage.Bind(self,self.free_grab);
		Map3DSystem.App.FreeGrab.FreeGrabOptionPage.ShowPage();
	end
end