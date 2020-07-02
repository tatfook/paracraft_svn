--[[
Title: SignContractPage
Author(s): Leio
Date: 2012/01/17
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TeenAction/SignContractPage.lua");
local SignContractPage = commonlib.gettable("MyCompany.Aries.Quest.NPCs.TeenAction.SignContractPage");
SignContractPage.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
NPL.load("(gl)script/apps/Aries/Pet/main.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/activationkeys/paraworld.activationkeys.lua");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local SignContractPage = commonlib.gettable("MyCompany.Aries.Quest.NPCs.TeenAction.SignContractPage");
function SignContractPage.ClosePage()
	local self = SignContractPage;
	if(self.pageCtrl)then
		self.pageCtrl:CloseWindow();
	end
end
function SignContractPage.OnInit()
	local self = SignContractPage;
	self.pageCtrl = document:GetPageCtrl();
end
function SignContractPage.ShowPage()
	local self = SignContractPage;
	Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nil, "profilepage", function(msg)
		if(msg and msg.users and msg.users[1]) then
			local user = msg.users[1];
			local introducer = user.introducer;
			if(introducer and introducer ~= -1) then
				local s = string.format("你已经填写过推荐人了,编号是:%d",introducer);
				_guihelper.MessageBox(s);
				return
			end
			self.__ShowPage();
		end
	end,"access plus 0 day");
end
function SignContractPage.__ShowPage()
	local self = SignContractPage;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/TeenAction/SignContractPage.html", 
			name = "SignContractPage.__ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			enable_esc_key = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -275/2,
				y = -160/2,
				width = 275,
				height = 160,
		});
end
function SignContractPage.DoSign()
	local self = SignContractPage;
	if(self.pageCtrl)then
		local bean = MyCompany.Aries.Pet.GetBean();
        if(bean)then
			local nid = self.pageCtrl:GetValue("user_nid_txt");
			local len = ParaMisc.GetUnicodeCharNum(nid);
			if(len == 0)then
				local s = string.format("请输入%s！",MyCompany.Aries.ExternalUserModule:GetConfig().account_name);
				_guihelper.MessageBox(s);
				return;
			end
			if(len < 5 or len > 20)then
				local s = string.format("%s不存在！",MyCompany.Aries.ExternalUserModule:GetConfig().account_name);
				_guihelper.MessageBox(s);
				return;
			end
			local mlel = bean.mlel or 0;
			local combatlel = bean.combatlel or 0;
			local __,__,__,copies = hasGSItem(20043);
			copies = copies or 0;
			local can_pass = false;

			if(mlel >=1)then
				can_pass = true;
			end
			if(not can_pass)then
				_guihelper.MessageBox("1级魔法星用户才能填写推荐人！");
				return;
			end
			nid = tonumber(nid);
			if(nid)then
				if(nid == Map3DSystem.User.nid)then
					local s = string.format("不能输入自己的%s！",MyCompany.Aries.ExternalUserModule:GetConfig().account_name);
					_guihelper.MessageBox(s);
					return;
				end	
				NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
				local s = string.format("确认要输入%s吗？",tostring(nid));
				_guihelper.Custom_MessageBox(s,function(result)
					if(result == _guihelper.DialogResult.Yes)then
						self.__DoSign(nid);
					end
				end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Cancel_32bits.png; 0 0 153 49"});
			else
				local s = string.format("%s不存在！",MyCompany.Aries.ExternalUserModule:GetConfig().account_name);
				_guihelper.MessageBox(s);
			end
		end
	end
end
function SignContractPage.__DoSign(nid)
	local self = SignContractPage;
	if(not nid)then return end
	Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nil, "profilepage", function(msg)
		if(msg and msg.users and msg.users[1]) then
			local user = msg.users[1];
			local introducer = user.introducer;
			if(introducer and introducer ~= -1) then
				local s = string.format("你已经填写过推荐人了,编号是:%d",introducer);
				_guihelper.MessageBox(s);
				return
			end
			local msg = {
				nid = nid,
			}
			local myself = Map3DSystem.User.nid;
			paraworld.activationkeys.IAmInvitedBy(msg,"IAmInvitedBy",function(msg)
				if(msg and msg.issuccess == true)then
					paraworld.PostLog({action = "SignContract", myself = myself, s_nid = nid}, 
						"SignContract_log", function(msg)
					end);
					local s = string.format("你已经成功填写推荐人,编号是:%d",nid);
					_guihelper.MessageBox(s);
				else
					_guihelper.MessageBox("推荐失败！");
				end
				self.ClosePage();
			end);
		end
	end)
end