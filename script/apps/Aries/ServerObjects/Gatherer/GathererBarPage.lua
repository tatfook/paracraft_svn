--[[
Title: 
Author(s): Leio
Date: 2012/03/06
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
GathererBarPage.Start({ duration = 2000, title = "±ÍÃ‚≤‚ ‘", disable_shortkey = true,});
------------------------------------------------------------
]]
local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
GathererBarPage.timer = nil;
GathererBarPage.tick = 0;
GathererBarPage.interval = 10;

function GathererBarPage.OnInit()
	local self = GathererBarPage;
	self.page = document:GetPageCtrl();
end

-- show a time line before excute custom function 
-- @param args:can be nil,default value is args = { duration = 2000, title = nil, disable_shortkey = true,}
--  auto_resume= true, if true, we will not restart but resume previous tick if any. 
-- @param cancelCallback:actived if user touch cancel keys like "esc" "space" or avatar position is moved
-- @param finishedCallback:actived if time line is go to over normally
function GathererBarPage.Start(args,cancelCallback,finishedCallback)
	local self = GathererBarPage;
	args = args or {};
	local duration = args.duration or 2000;
	if(not self.timer)then
		self.timer = commonlib.Timer:new();
	end
	
	if(not args.auto_resume or not self.timer:IsEnabled()) then
		self.tick = 0;
	end
	
	self.title= args.title;
	self.disable_shortkey = args.disable_shortkey;
	self.duration = duration;
	self.cancelCallback = cancelCallback;
	self.finishedCallback = finishedCallback;
	self.timer.callbackFunc = GathererBarPage.Timer_Callback;

	--ParaAudio.PlayUISound("Gather_teen");

	local player = ParaScene.GetPlayer();
	if(player and player:IsValid())then
		self.temp_x,self.temp_y,self.temp_z = player:GetPosition();
		local params = {
			url = "script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.html", 
			name = "GathererClientLogics.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = false,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 10000,
			allowDrag = false,
			directPosition = true,
				align = args.align or "_ctb",
				x = args.x or 0,
				y = args.y or -120,
				width = args.width or 200,
				height = args.height or 29,
			}
		System.App.Commands.Call("File.MCMLWindowFrame", params);
		if(self.page)then
			self.page:SetValue("progressbar",0);
		end
		self.timer:Change(0,self.interval);
	end
end
function GathererBarPage.Timer_Callback(timer)
	local self = GathererBarPage;
	if(self.timer)then
		local esc_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_ESCAPE) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_SPACE);
		local player = ParaScene.GetPlayer();
		if(player and player:IsValid())then
			local x,y,z = player:GetPosition();
			if(not self.disable_shortkey)then
				if(esc_pressed or not self.temp_x or not self.temp_y or not self.temp_z or x ~= self.temp_x or y ~= self.temp_y or z ~= self.temp_z )then
					self.timer:Change();
					if(self.page)then
						self.page:CloseWindow();
					end
					if(self.cancelCallback)then
						self.cancelCallback();
					end
					return;
				end
			end
		end
		local delta = self.timer:GetDelta(200);

		if(self.tick < self.duration)then
			if(self.page)then
				self.page:SetValue("progressbar",100 * (self.tick/self.duration));
			end
			self.tick = self.tick + delta;
		else
			if(self.page)then
				self.page:SetValue("progressbar",100 * (self.tick/self.duration));
				self.page:CloseWindow();
			end
			self.timer:Change();
			if(self.finishedCallback)then
				self.finishedCallback();
			end
		end
	end	
end