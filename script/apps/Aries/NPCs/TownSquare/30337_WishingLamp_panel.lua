--[[
Title: 
Author(s): Leio
Date: 2010/01/05
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30337_WishingLamp_panel.lua");
MyCompany.Aries.Quest.NPCs.WishingLamp_panel.ShowPage();
-------------------------------------------------------
]]
-- default member attributes
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/LiteMailAlertPage.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/litemail/paraworld.litemail.lua");
local WishingLamp_panel = {
	page = nil,
	type = 3,--投稿的类型 1 镇长信箱 2 镇里的小秘密 3 心愿
	
	wishedCallbackFunc = nil,--发送信息成功的回调函数
}
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishingLamp_panel",WishingLamp_panel);

function WishingLamp_panel.OnInit()
	local self = WishingLamp_panel;
	self.page = document:GetPageCtrl();
end
--@param type:投稿类型
function WishingLamp_panel.ShowPage()
	local self = WishingLamp_panel;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/TownSquare/30337_WishingLamp_panel.html", 
			name = "WishingLamp_panel.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			--app_key=MyCompany.Taurus.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 3,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -350,
				y = -250,
				width = 700,
				height = 507,
		});
end
function WishingLamp_panel.ClosePage()
	local self = WishingLamp_panel;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="WishingLamp_panel.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
	self.isSending = false;
end
function WishingLamp_panel.SendMail()
	local self = WishingLamp_panel;
	if(self.page)then
		local title = "许愿";
		local content = self.page:GetUIValue("send_info");
		
		if(not content or content == "")then
			_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>内容不能为空哦！</div>");
			return
		end
		
		local content_len = ParaMisc.GetUnicodeCharNum(content);
		if(content_len > 500)then
			_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>正文不能超过500个字，请重新输入吧。</div>");
			return
		end
		local msg = {
			nid = Map3DSystem.User.nid,
			cid = self.type,
			title = title,
			msg = content,
		}
		if(self.isSending)then return end
		self.isSending = true;
		commonlib.echo("=========before send mail in WishingLamp_panel:");
		commonlib.echo(msg);
		paraworld.litemail.Add(msg,"WishingLamp_panel",function(msg)
			self.isSending = false;
			commonlib.echo("=========after send mail in WishingLamp_panel:");
			commonlib.echo(msg);
			--if(msg and msg.issuccess)then
				--
				--_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>许愿成功！</div>");
			--else
				--_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>许愿失败！</div>");
			--end
			--回调函数
			if(self.wishedCallbackFunc)then
				self.wishedCallbackFunc();
			end
			--关闭页面
			self.ClosePage();
		end);
	end
end
