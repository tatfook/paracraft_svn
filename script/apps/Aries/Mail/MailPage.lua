--[[
Title: 
Author(s): leio
Date: 2013/4/8
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Mail/MailPage.lua");
local MailPage = commonlib.gettable("MyCompany.Aries.Mail.MailPage");
MailPage.ShowPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local MailPage = commonlib.gettable("MyCompany.Aries.Mail.MailPage");
MailPage.selected_index = nil;
MailPage.mail_list = nil;
MailPage.page = nil;
function MailPage.OnInit()
	MailPage.page = document:GetPageCtrl();	
end
function MailPage.RefreshPage()
	if(MailPage.page)then
		MailPage.page:Refresh(0);
	end
end
function MailPage.ShowPage()
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	if(not DealDefend.CanPass())then
		return
	end
	local url = "script/apps/Aries/Mail/MailPage.teen.html";
	local params = {
			url = url, 
			name = "MailPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			directPosition = true,
				align = "_ct",
				x = -760/2,
				y = -470/2,
				width = 760,
				height = 470,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	MailPage.selected_index = 1;
	MailPage.LoadMail(nil,nil,"access plus 20 seconds");
end
function MailPage.AutoCheckMail(callbackFunc)
	MailPage.LoadMail(nil,nil,nil,function(msg)
		local cnt = 0;
		if(msg and msg.list)then
			local k,v;
			for k,v in ipairs(msg.list) do
				if(v.isread and v.isread == 0)then
					cnt = cnt + 1;
				end
			end
			if(callbackFunc)then
				callbackFunc({cnt = cnt});
			end
		end
	end)
end
function MailPage.LoadMail(page_index,page_size,cache_policy,callbackFunc)
	local params = {
		nid = nil,
		pindex = page_index or 0,
		psize = page_size or 2000, 
		cache_policy = cache_policy or "access plus 0 seconds"
	}
	paraworld.email.getofpage(params, "checkemail",function(msg)
		if(msg and msg.list)then
			MailPage.mail_list = msg.list;
			--CommonClientService.Fill_List(MailPage.mail_list,50)
			MailPage.RefreshPage();
			if(callbackFunc)then
				callbackFunc(msg);
			end
		end
	end);
end
function MailPage.ds_func_mail(index)
	if(not MailPage.mail_list)then return 0 end
	if(index == nil) then
		return #(MailPage.mail_list);
	else
		return MailPage.mail_list[index];
	end
end
function MailPage.DeleteMail(eid,callbackFunc)
	if(not eid)then
		return
	end
	MailPage.ReadMail(eid,nil,function(msg)
		local mail_detail_info = msg;
		MailPage.__DeleteMail(eid,mail_detail_info,callbackFunc);
	end)
end
function MailPage.__DeleteMail(eid,mail_detail_info,callbackFunc)
	if(not eid or not mail_detail_info)then
		return
	end
	local isgetattach = mail_detail_info.isgetattach;
	local attaches = mail_detail_info.attaches;
	local s;
	local need_get_attaches;
	local function del_mail()
		paraworld.email.delete({eid = eid},"deletemail",function(msg)
            if(callbackFunc)then
				callbackFunc(msg);
			end
        end)
	end
	if(attaches and #attaches > 0 and isgetattach and isgetattach == 0)then
		_guihelper.Custom_MessageBox("你确定删除该邮件么？<br/>邮件中包含未收附件(删除时会自动收取附件)",function(result)
			if(result == _guihelper.DialogResult.Yes)then
				MailPage.GetAttachContent(eid,mail_detail_info,function(msg)
					if(msg and msg.issuccess)then
						del_mail();
					elseif(msg.errorcode == 433)then
						_guihelper.Custom_MessageBox("无法收取附件.附件中的某个物品背包中达到了最大值.<br/> <font color='#ff0000'>是否强制删除邮件(附件将丢失)？</font>",function(result)
							if(result == _guihelper.DialogResult.Yes)then
								del_mail();
							end
						end,_guihelper.MessageBoxButtons.YesNo,{yes = "删除", no = "取消", show_label = true});
					end
				end)
			end
		end,_guihelper.MessageBoxButtons.YesNo);
	else
		_guihelper.Custom_MessageBox("你确定删除该邮件么？",function(result)
			if(result == _guihelper.DialogResult.Yes)then
				 del_mail();
			end
		end,_guihelper.MessageBoxButtons.YesNo);
	end
end
--全部收取
function MailPage.GetAttachContentByID(eid,callbackFunc)
	if(not eid)then
		return
	end
	MailPage.ReadMail(eid,nil,function(msg)
		local mail_detail_info = msg;
		MailPage.GetAttachContent(eid,mail_detail_info,callbackFunc)
	end)
end
--单个收取
function MailPage.GetAttachContentByGsid(eid,gsid,callbackFunc)
	if(not eid or not gsid)then
		return
	end
	MailPage.GetAttachContentByStr(eid,tostring(gsid),callbackFunc)
end
function MailPage.GetAttachContentByStr(eid,attaches_str,callbackFunc)
	if(not eid or not attaches_str or attaches_str == "")then
		return
	end
	--[ errorcode ] 419:用户不存在 497:邮件不存在 417:附件已被提取过 423:没有附件 433:物品数量太多了 493:参考错误 494:解析附件数据时异常
	paraworld.email.getattach({eid = eid,attaches = attaches_str,cache_policy = "access plus 30 seconds"},nil,function(msg) 
		if(msg and msg.issuccess)then
		elseif(msg.errorcode == 433)then
		elseif(msg.errorcode == 423)then
			_guihelper.MessageBox("附件已经不存在了。");
		elseif(msg.errorcode == 417)then
			_guihelper.MessageBox("你的附件已拿走了。");
		elseif(msg.errorcode == 497)then
			_guihelper.MessageBox("邮件不存在。");
		elseif(msg.errorcode == 494)then
			_guihelper.MessageBox("解析附件数据时发生异常。");
		elseif(msg.errorcode == 493)then
			_guihelper.MessageBox("收取附件参数出错。");
		else
			_guihelper.MessageBox("收取附件出错，你可以通过GM提交问题给我们的开发人员!");
		end
		if(callbackFunc)then
			callbackFunc(msg);
		end
	end);
end
function MailPage.GetAttachContent(eid,mail_detail_info,callbackFunc)
	if(not eid or not mail_detail_info)then
		return
	end
	local isgetattach = mail_detail_info.isgetattach;
	local attaches = mail_detail_info.attaches;
	local attaches = mail_detail_info.attaches;
	if(attaches and #attaches > 0 and isgetattach and isgetattach == 0)then
		local s = "";
		local k,v;
		for k,v in ipairs(attaches) do
			if(k == 1)then
				s = tostring(v.gsid);
			else
				s = string.format("%s,%d",s, v.gsid);
			end
		end
		MailPage.GetAttachContentByStr(eid,s,callbackFunc)
	end
end
function MailPage.ReadMail(eid,cache_policy,callbackFunc)
	if(not eid)then return end
	cache_policy = cache_policy or "access plus 0 seconds";
	paraworld.email.read({eid = eid,cache_policy = cache_policy,},nil,function(msg)
		NPL.load("(gl)script/apps/Aries/Desktop/MapArea.lua");
		local MapArea = commonlib.gettable("MyCompany.Aries.Desktop.MapArea");
		MapArea.CheckEmail(5000);
		if(callbackFunc)then
			callbackFunc(msg)
		end
	end);
end
