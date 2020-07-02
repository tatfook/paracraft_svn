--[[
Title: code behind for page 30133_HaqiAmbassadorSignContract_panel.html
Author(s): Leio
Date: 2009/12/7
Desc:  script/apps/Aries/NPCs/Ambassador/30133_HaqiAmbassadorSignContract_panel.html

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Ambassador/30133_HaqiAmbassadorSignContract_panel.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
NPL.load("(gl)script/apps/Aries/Pet/main.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/activationkeys/paraworld.activationkeys.lua");
local HaqiAmbassadorSignContract_panel = {
	state = 0,--0 没有签约 1 已经签约
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.HaqiAmbassadorSignContract_panel", HaqiAmbassadorSignContract_panel);
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
local hasGSItem = ItemManager.IfOwnGSItem;
function HaqiAmbassadorSignContract_panel.OnInit()
	local self = HaqiAmbassadorSignContract_panel;
	self.pageCtrl =  document:GetPageCtrl();
end
function HaqiAmbassadorSignContract_panel.ClosePage()
	local self = HaqiAmbassadorSignContract_panel;
	if(self.pageCtrl)then
		self.pageCtrl:CloseWindow();
	end
end
function HaqiAmbassadorSignContract_panel.RefreshPage()
	local self = HaqiAmbassadorSignContract_panel;
	if(self.pageCtrl)then
		self.pageCtrl:Refresh(0);
	end
end
function HaqiAmbassadorSignContract_panel.Load()
	local self = HaqiAmbassadorSignContract_panel;
	self.state = 0;
	Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nil, "profilepage", function(msg)
	commonlib.echo("load user info");
	commonlib.echo(msg);
		if(msg and msg.users and msg.users[1]) then
			local user = msg.users[1];
			local introducer = user.introducer;
			if(introducer and introducer ~= -1) then
				self.state = 1;
				self.RefreshPage();
			end
		end
	end);
	local command = System.App.Commands.GetCommand("Aries.Quest.DoAddValue");
	if(command) then
		command:Call({
			increment = { { id = 79103, value = 1}, },
		});
	end
end
function HaqiAmbassadorSignContract_panel.DoSign()
	local self = HaqiAmbassadorSignContract_panel;
	if(self.pageCtrl)then
		local bean = MyCompany.Aries.Pet.GetBean();
        if(bean)then
			local nid = self.pageCtrl:GetValue("key_txt");
			local len = ParaMisc.GetUnicodeCharNum(nid);
			if(len == 0)then
				local s = string.format("请输入%s！",MyCompany.Aries.ExternalUserModule:GetConfig().account_name);
				_guihelper.MessageBox(s);
				return;
			end
			--NOTE:mm号只接受5-9位的号码 
			local region_id = ExternalUserModule:GetRegionID();
			if(region_id == 0)then
				if(len < 5 or len > 9)then
					local s = string.format("%s不存在！",MyCompany.Aries.ExternalUserModule:GetConfig().account_name);
					_guihelper.MessageBox(s);
					return;
				end
			end
			if(len > 20)then
				local s = string.format("%s不存在！",MyCompany.Aries.ExternalUserModule:GetConfig().account_name);
				_guihelper.MessageBox(s);
				return;
			end
			local mlel = bean.mlel or 0;
			local combatlel = bean.combatlel or 0;
			local __,__,__,copies = hasGSItem(20043);
			copies = copies or 0;
			local can_pass = false;

			if(mlel >=1 or (combatlel >= 30 and copies >= 50))then
				can_pass = true;
			end
			if(not can_pass)then
				_guihelper.MessageBox("1级魔法星或者30级以上并获得50个英雄谷奖章，才能填写推荐人！");
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
				local s = string.format("确认要输入%d并且签约吗？",nid);
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
function HaqiAmbassadorSignContract_panel.__DoSign(nid)
	local self = HaqiAmbassadorSignContract_panel;
	if(not nid)then return end
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	if(self.state == 0)then
		Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nil, "profilepage", function(msg)
			if(msg and msg.users and msg.users[1]) then
				commonlib.echo("user info HaqiAmbassadorSignContract_panel");
				commonlib.echo(msg);
				local user = msg.users[1];
				local introducer = user.introducer;
				if(introducer and introducer ~= -1) then
					_guihelper.MessageBox("你已经签约过了！");
					return
				end
				local msg = {
					nid = nid,
				}
				commonlib.echo("before to send nid in HaqiAmbassadorSignContract_panel");
				commonlib.echo(msg);
				local myself = Map3DSystem.User.nid;
				paraworld.activationkeys.IAmInvitedBy(msg,"IAmInvitedBy",function(msg)
					commonlib.echo("after to send nid in HaqiAmbassadorSignContract_panel");
					commonlib.echo(msg);
					if(msg and msg.issuccess == true)then
						paraworld.PostLog({action = "SignContract", myself = myself, s_nid = nid}, 
							"SignContract_log", function(msg)
						end);
						Map3DSystem.App.profiles.ProfileManager.GetJID(nid, function(jid)
							if(jid)then
								MyCompany.Aries.Quest.Mail.MailClient.SendMessage({
									msg_type = "redfruit_remind",
									nid = Map3DSystem.User.nid,
									mail_id = 10026,
								},jid);
							end
						end)
					else
						_guihelper.MessageBox("签约失败！");
					end
					self.state = 1;
					self.RefreshPage();
				end);
			end
		end)
	end
end