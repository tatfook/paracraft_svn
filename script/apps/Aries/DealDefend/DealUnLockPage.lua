--[[
Title: 
Author(s): leio
Date: 2012/3/15
Desc:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/DealDefend/DealUnLockPage.lua");
local DealUnLockPage = commonlib.gettable("MyCompany.Aries.DealDefend.DealUnLockPage");
DealUnLockPage.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/DealDefend/DealLockPage.lua");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local DealUnLockPage = commonlib.gettable("MyCompany.Aries.DealDefend.DealUnLockPage");
local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");

DealUnLockPage.edit_state = "do_unlock";-- "do_unlock" or "do_manage"
function DealUnLockPage.OnInit()
	local self = DealUnLockPage;
	self.page = document:GetPageCtrl();
end

-- @param callbackFunc: called when page is closed and unlocked. 
function DealUnLockPage.ShowPage(edit_state, callbackFunc)
	local self = DealUnLockPage;
	self.edit_state = edit_state or "do_unlock";
	local url = "";
	if(CommonClientService.IsKidsVersion())then
		url = "script/apps/Aries/DealDefend/DealUnLockPage.html";
	else
		url = "script/apps/Aries/DealDefend/DealUnLockPage.teen.html";
	end
	local params = {
		url = url, 
		name = "DealUnLockPage.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		zorder = 1000,
		directPosition = true,
			align = "_ct",
			x = -500/2,
			y = -400/2,
			width = 500,
			height = 400,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	

	if(callbackFunc) then
		params._page.OnClose = function()
			if(not edit_state or edit_state == "do_unlock") then
				if(not DealDefend.HasLockPassword() or not DealDefend.IsLocked()) then
					callbackFunc();
				end
			end
		end
	end

	if(self.page)then
		local _editbox = self.page:FindControl("password_user");
		if(_editbox and _editbox.Focus)then
			_editbox:Focus();
		end
	end	
end
function DealUnLockPage.IsOK()
	local self = DealUnLockPage;
	if(not self.page)then
		return
	end
	local bIsOK=true;
	local ErrorColor = "#FF0000";
	local GoodColor = "#00aa00";
	local password_user = self.page:GetValue("password_user");	
	local passwdlen = string.len(password_user);

	self.page:SetUIValue("password_label", "");

	if(passwdlen == 0 ) then
		self.page:SetUIValue("password_label", "交易密码不能为空");
		self.page:CallMethod("password_label", "SetUIColor", ErrorColor);
		bIsOK=false;
	end
	self.page:SetUIEnabled("confirm_btn", bIsOK);
	return bIsOK;
end