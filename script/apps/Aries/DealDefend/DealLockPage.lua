--[[
Title: 
Author(s): leio
Date: 2012/3/14
Desc:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/DealDefend/DealLockPage.lua");
local DealLockPage = commonlib.gettable("MyCompany.Aries.DealDefend.DealLockPage");
DealLockPage.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local DealLockPage = commonlib.gettable("MyCompany.Aries.DealDefend.DealLockPage");
DealLockPage.edit_state= "set_lock_psd";--"set_lock_psd" or "change_lock_psd"
function DealLockPage.OnInit()
	local self = DealLockPage;
	self.page = document:GetPageCtrl();
end
function DealLockPage.ShowPage(edit_state)
	local self = DealLockPage;
	self.edit_state = edit_state or "set_lock_psd";
	if(DealDefend.HasLockPassword())then
		self.edit_state = "change_lock_psd";
	end
	local url = "";
	if(CommonClientService.IsKidsVersion())then
		url = "script/apps/Aries/DealDefend/DealLockPage.html";
	else
		url = "script/apps/Aries/DealDefend/DealLockPage.teen.html";
	end
	local params = {
		url = url, 
		name = "DealLockPage.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		directPosition = true,
			align = "_ct",
			x = -500/2,
			y = -400/2,
			width = 500,
			height = 400,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);		
end
function DealLockPage.IsOK()
	local self = DealLockPage;
	if(not self.page)then
		return
	end
	local bIsOK=true;
	local ErrorColor = "#FF0000";
	local GoodColor = "#00aa00";
	local password_user = self.page:GetValue("password_user");	
	local password_deal = self.page:GetValue("password_deal");	
	local password_deal_confirm = self.page:GetValue("password_deal_confirm");	
	local passwdlen = string.len(password_user);
	local passwdlen_deal = string.len(password_deal);
	local passwdlen_deal_confirm = string.len(password_deal_confirm);
	self.page:SetUIValue("password_label", "");
	self.page:SetUIValue("password_deal_label", "");
	self.page:SetUIValue("password_deal_confirm_label", "");

	local is_changing_password = DealLockPage.edit_state ~="set_lock_psd";

	if(passwdlen == 0 and is_changing_password) then
		if(not is_changing_password)then
			self.page:SetUIValue("password_label", "账号登陆密码不能为空");
		else
			self.page:SetUIValue("password_label", "当前交易密码不能为空");
		end
		self.page:CallMethod("password_label", "SetUIColor", ErrorColor);
		bIsOK=false;
	end
	if(password_deal ~= string.match(password_deal, "[a-zA-Z_0-9]+")) then
		self.page:SetUIValue("password_deal_label", "交易密码只能由大小写字母、数字、下划线组成");
		self.page:CallMethod("password_deal_label", "SetUIColor", ErrorColor);
		bIsOK=false;
	elseif( passwdlen_deal == 0 ) then
		self.page:SetUIValue("password_deal_label", "交易密码不能为空");
		self.page:CallMethod("password_deal_label", "SetUIColor", ErrorColor);
		bIsOK=false;
	elseif( passwdlen_deal > 6 ) then	
		self.page:SetUIValue("password_deal_label", "交易密码长度最长6个字节");
		self.page:CallMethod("password_deal_label", "SetUIColor", ErrorColor);
		--self.page:SetUIValue("password_deal", string.sub(password_deal,1,6));
		bIsOK=false;
	end
	if(password_deal ~= password_deal_confirm) then	
		self.page:SetUIValue("password_deal_confirm_label", "两次密码输入不一致哦!请再次输入上面的密码！");
		self.page:CallMethod("password_deal_confirm_label", "SetUIColor", ErrorColor);
		bIsOK=false;
	else
		if(string.len(password_deal_confirm)==0)then
			self.page:SetUIValue("password_deal_confirm_label", "密码不能为空!请再次输入上面的密码，确保一致！");
			self.page:CallMethod("password_deal_confirm_label", "SetUIColor", ErrorColor);
			bIsOK=false;
		else
			self.page:SetUIValue("password_deal_confirm_label", "密码输入一致!");
			self.page:CallMethod("password_deal_confirm_label", "SetUIColor", GoodColor);
		end
	end
	if( passwdlen_deal_confirm > 6 ) then	
		self.page:SetUIValue("password_deal_confirm_label", "交易密码长度最长6个字节");
		self.page:CallMethod("password_deal_confirm_label", "SetUIColor", ErrorColor);
		--self.page:SetUIValue("password_deal_confirm", string.sub(password_deal_confirm,1,6));
		bIsOK=false;
	end
	self.page:SetUIEnabled("confirm_btn", bIsOK);
	return bIsOK;
end
function DealLockPage.DoViewHelp()
	local url = "";
	if(CommonClientService.IsKidsVersion())then
		url = "script/apps/Aries/DealDefend/DealDefendHelpPage.html";
	else
		url = "script/apps/Aries/DealDefend/DealDefendHelpPage.teen.html";
	end
    local params = {
		url = url, 
		name = "DealDefendHelpPage.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		zorder = 1001,
		directPosition = true,
			align = "_ct",
			x = -500/2,
			y = -400/2,
			width = 500,
			height = 400,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);		
end