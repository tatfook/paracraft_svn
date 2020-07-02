--[[
Title: 
Author(s): leio
Date: 2012/3/14
Desc:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
local can_pass = DealDefend.CanPass(function()    
	-- unlocked
end);
if(not can_pass)then
	return
end

------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestTimeStamp.lua");
local QuestTimeStamp = commonlib.gettable("MyCompany.Aries.Quest.QuestTimeStamp");
NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.dealdefend.lua");
local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
DealDefend.is_locked = true;--是否已经解锁
DealDefend.has_lock_password = false;--是否已经设置交易密码
--是否已经通过paraworld.dealdefend.CheckSecPass检测
DealDefend.has_checked = false;
--是否已经锁定
function DealDefend.IsLocked()
	local self = DealDefend;
	return self.is_locked;
end
--是否已经具有交易密码
function DealDefend.HasLockPassword()
	local self = DealDefend;
	return self.has_lock_password;
end
function DealDefend.HasChecked()
	local self = DealDefend;
	return self.has_checked;
end


-- @param callbackFunc: nil or a function() end , when called it mean that the user has unlocked. If the function returns true, this function will not be called. 
-- @return true if it is unlocked. 
function DealDefend.CanPass(callbackFunc)
	local self = DealDefend;
	if(DealDefend.HasLockPassword() and DealDefend.IsLocked())then
		 NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
		_guihelper.Custom_MessageBox("你的物品正受到交易密码的保护。请先解锁！",function(result)
			if(result == _guihelper.DialogResult.Yes)then
				NPL.load("(gl)script/apps/Aries/DealDefend/DealUnLockPage.lua");
				local DealUnLockPage = commonlib.gettable("MyCompany.Aries.DealDefend.DealUnLockPage");
				DealUnLockPage.ShowPage(nil, callbackFunc);
			end
		end,_guihelper.MessageBoxButtons.YesNo);
		return false;
	end
	return true;
end
--登陆初始化
function DealDefend.LoadState(callbackFunc)
	local self = DealDefend;
	paraworld.dealdefend.CheckSecPass(nil,"",function(msg)
		if(msg)then
			self.has_checked = true;
			--是否已经设置密码
			self.has_lock_password = msg.hassecpass;	
		end
		if(callbackFunc)then
			callbackFunc();
		end
	end)
end
function DealDefend.Reset()
	local self = DealDefend;
	self.is_locked = true;--是否已经解锁
	self.has_lock_password = false;--是否已经设置交易密码
	self.has_checked = false;
end
--是否已经发送过重置申请
function DealDefend.HasResetPassword()
	local self = DealDefend;
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean and bean.resetsecdt)then
        return true;
    end
end
--检测清空密码是否生效
function DealDefend.ResetPassword_Successful_InMemory()
	local self = DealDefend;
	if(not self.HasResetPassword())then
		return
	end
	local date1,date2 = DealDefend.GetTime();
    local a_1 = commonlib.GetMillisecond_Date(date1);
	local a_2 = commonlib.GetMillisecond_Date(date2);
	if(a_2 >= a_1)then
		return true;
	end
end
--返回 重置密码申请时间,目前时间
function DealDefend.GetTime()
	local self = DealDefend;
	local bean = MyCompany.Aries.Pet.GetBean();
	local date1 = bean.resetsecdt;
    local date,time = QuestTimeStamp.GetClientDateTime();
    local date2 = string.format("%s %s",date,time);
	return date1,date2;
end