--[[
Title: code behind for page TabMount.html
Author(s): WangTian
Date: 2009/4/24
Desc:  script/apps/Aries/Inventory/TabMount.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Pet/main.lua");
local TabMountPage = {
	editState = false,--�Ƿ����ڸ������������
	language = nil,--ιʳ��ʱ�����������
	speak_timer = nil,
	page = nil,
	isFirstShow = false,--�Ƿ��ǵ�һ����ʾ
};
commonlib.setfield("MyCompany.Aries.Inventory.TabMountPage", TabMountPage);
function TabMountPage.OnInit()
	local self = TabMountPage;
	self.page = document:GetPageCtrl();
	if(not self.isFirstShow)then
		self.isFirstShow = true;
		--���¼����Լ�����ĳɳ�����
		MyCompany.Aries.Pet.GetRemoteValue(nil,function(msg)
			if(self.page)then
				self.page:Refresh(0.01);	
			end
		end)
	end
end
-- data source for items
function TabMountPage.DS_Func_Items(index)
	if(index ~= nil) then
		return {};
	elseif(index == nil) then
		return 0;
	end
end
function TabMountPage.SetEditState(v)
	local self = TabMountPage;
	self.editState = v;
end
function TabMountPage.GetEditState()
	local self = TabMountPage;
	return self.editState
end

function TabMountPage.RegisterHook()
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = MyCompany.Aries.Inventory.TabMountPage.HookHandler, 
		hookName = "TabMountPage_PetAction", appName = "Aries", wndName = "main"});
end


function TabMountPage.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "TabMountPage_PetAction", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
		
	MyCompany.Aries.Inventory.TabMountPage.language = nil;
	if(TabMountPage.speak_timer)then
		TabMountPage.speak_timer:Change();
	end
end
function TabMountPage.HookHandler(nCode, appName, msg, value)
	if(msg.pet_action_type == "pet_action_feeding")then
		TabMountPage.language = msg.language;
		
		--ˢ�������� MyCompany.Aries.Inventory.RefreshMainWnd(2);
		
		--˵������
		NPL.load("(gl)script/ide/timer.lua");
		if(TabMountPage.speak_timer)then
			TabMountPage.speak_timer:Change();
		else
			TabMountPage.speak_timer = commonlib.Timer:new({callbackFunc = function(timer)
				--�������
				TabMountPage.language = nil;
				if(TabMountPage.page)then
					TabMountPage.page:Refresh(0.1);
				end
			end})
		end
		--5000 millisecond �����
		TabMountPage.speak_timer:Change(5000, nil)
	end
	return nCode;
end