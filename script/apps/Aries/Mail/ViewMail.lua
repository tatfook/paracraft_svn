--[[
Title: 
Author(s): WD
Date: 2011/11/18
use the lib:
------------------------------------------------------------
--for view mail content
NPL.load("(gl)script/apps/Aries/Mail/ViewMail.lua");
MyCompany.Aries.Mail.ViewMail.ShowPage();
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/ide/TooltipHelper.lua");
local AvatarBag = commonlib.gettable("MyCompany.Aries.Desktop.AvatarBag");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local ItemManager = Map3DSystem.Item.ItemManager;
local GetItemByID = ItemManager.GetGlobalStoreItemInMemory;
local GetItemsCount = ItemManager.GetItemCountInBag;
local hasGSItem = ItemManager.IfOwnGSItem;
local GetItemsInBag = ItemManager.GetItemsInBag;
local GetItemByBagAndOrder = ItemManager.GetItemByBagAndOrder;

local ViewMail = commonlib.gettable("MyCompany.Aries.Mail.ViewMail");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local ItemManager = Map3DSystem.Item.ItemManager;
local MSG = _guihelper.MessageBox;
local echo = commonlib.echo;
local table_insert = table.insert;

NPL.load("(gl)script/apps/Aries/Chat/BadWordFilter.lua");
local BadWordFilter = commonlib.gettable("MyCompany.Aries.Chat.BadWordFilter");

ViewMail.PageSize = 10;
ViewMail.filter = ViewMail.filter or 0;
ViewMail.SendBox = {};
ViewMail.ReceiveBox = {};
ViewMail.DisplayItems = {};
ViewMail.Items = {};
ViewMail.RECEIVE_MAIL = 0;
ViewMail.SEND_MAIL = 1;
ViewMail.OpMode = ViewMail.RECEIVE_MAIL;
ViewMail.ParentTable = {name = "",parent};

--mail wrapper for send/receive op
--attachment={{gsid,copies}}
ViewMail.Mail = {tonid="", date="", title="", attaches="", content=""};

function ViewMail.Nid(arg)
	if(arg)then
		ViewMail.Mail.tonid = tonumber(arg);
	else
		return ViewMail.Mail.tonid;
	end
end

function ViewMail.MailDate(arg)
	if(arg)then
		ViewMail.Mail.date = arg;
	else
		return ViewMail.Mail.date;
	end
end
function ViewMail.GetFormattedDate()
	return os.date("%Y-%m-%d %H:%M:%S");
end

function ViewMail.Text(arg)
	if(arg)then
		ViewMail.Mail.content = arg;
	else
		return ViewMail.Mail.content;
	end
end

function ViewMail.GetReceiveMailText()
	local original_text = ViewMail.Text();
	if(original_text) then
		return BadWordFilter.FilterString(original_text);
	end
	return "";
end

function ViewMail.Attachment(arg)
	if(arg)then
		ViewMail.Mail.attaches = arg;
	else
		return ViewMail.Mail.attaches;
	end
end

function ViewMail:Init()
	self.page = document:GetPageCtrl();
	
	if(ViewMail.OpMode == ViewMail.SEND_MAIL)then
		local items = MyCompany.Aries.Desktop.AvatarBag.Items;
		self.DisplayItems = {};

		self.Mail.attaches = "";
		for i,v in ipairs(items)do
			table_insert(ViewMail.DisplayItems,{guid = v.guid,gsid = v.gsid,copies=v.copies,});
			self.Mail.attaches = self.Mail.attaches .. string.format("%s,%s|",v.guid,v.copies);
		end
		self:SetControls();
	end
end

function ViewMail:SetControls()
	if(MyCompany.Aries.Mail.MailBox.SelectFriend)then
		local b = MyCompany.Aries.Mail.MailBox.SelectFriend(ViewMail.Nid())
		if(not b)then
			ViewMail.page:SetValue("ddlFriends",ViewMail.Nid())
		end
	end
	--ViewMail.page:SetValue("txtNid",ViewMail.Nid())
	ViewMail.page:SetValue("txtTitle",ViewMail.MailTitle())
	--self.SetText();

end
function ViewMail.OnSelectFriend(ctrl)
	local self = ViewMail;
	local ddl = self.page:FindControl(ctrl);
	--echo(ctrl);
	if(ddl and ddl.GetValue)then
		local value = ddl:GetValue();
		local nid = tonumber(string.match(value,"%((%d+)%)"));
		ViewMail.Nid(nid);
	end
end
function ViewMail:SetContentCtrl()
	if(self.page)then
		local ctrl = self.page:FindControl("MyTextArea2");
		if(ctrl)then
			ctrl:SetText(ViewMail.Text());
		end 
	end
end

function ViewMail.ShowPage(parent,mail_info,action)
	local self = ViewMail;
	self.ParentTable.parent = self.ParentTable.parent or parent

	if(not self.Visible)then
		self.Visible = true;
	end

	if(action == self.RECEIVE_MAIL)then
		self.Mail = commonlib.deepcopy(mail_info);
		if(mail_info) then
			self.Mail.original_msg = mail_info.original_msg;
		end
		if(MyCompany.Aries.Desktop.AvatarBag)then
			MyCompany.Aries.Desktop.AvatarBag.Clean();
		end
	elseif(mail_info and action == self.SEND_MAIL)then --for reply
		ViewMail.MailTitle(mail_info.title)
		ViewMail.Nid(mail_info.nid)
		ViewMail.Mail = {tonid=tonumber(mail_info.nid) or 0, date="", title=mail_info.title or "", attaches="", content=mail_info.content or ""};
	elseif(action == self.SEND_MAIL)then--write new mail
		ViewMail.Mail = {tonid="", date="", title="", attaches="", content=""};
	end

	ViewMail.DisplayItems = {};

	ViewMail.OpMode = tonumber(action);
	
	if(ViewMail.OpMode == ViewMail.RECEIVE_MAIL and self.Mail.isgetattach == 0)then
		local i,v;
		for i,v in ipairs(self.Mail.attaches)do
			local item = {gsid = v.gsid,copies = v.cnt, serverdata=v.s or v.serverdata or v.svrdata};
			table.insert(ViewMail.DisplayItems,item);
		end
	else
		ViewMail.DisplayItems = {}
	end

	--commonlib.echo(ViewMail.Mail);
	--commonlib.echo(ViewMail.DisplayItems);

	ViewMail:RefreshParent();

end

function ViewMail.Hide()
	ViewMail:Clean()
	AvatarBag.Visible = false;
	ViewMail:RefreshParent();
end

function ViewMail:RefreshParent()
	if(self.ParentTable.parent and self.ParentTable.parent.Refresh)then
		self.ParentTable.parent:Refresh();
	end
end


function ViewMail:GetDataSource(index)
	self.Items_Count = 0;
	--self.DisplayItems = commonlib.deepcopy(self.Attachment());

	if(self.DisplayItems)then
		self.Items_Count = #self.DisplayItems;
	end
	local displaycount = math.ceil(self.Items_Count / self.PageSize) * self.PageSize;
	if(displaycount == 0)then
		displaycount = self.PageSize;
	end

	if(self.OpMode == 1)then
		local i;
		for i = self.Items_Count + 1,displaycount do
			self.DisplayItems[i] = { gsid = -999,guid = -999,copies = 1, };
		end
	end
	
	if(index == nil) then
		return #(self.DisplayItems);
	else
		return self.DisplayItems[index];
	end
end

function ViewMail:GetDataSource2(index)
	self.Items_Count = 0;
	self.Items = commonlib.deepcopy(self.Mail.content.attachment);--?

	if(self.Items)then
		self.Items_Count = #self.Items;
	end
	local displaycount = math.ceil(self.Items_Count / 56) * 56;
	if(displaycount == 0)then
		displaycount = 56;
	end

	local i;
	for i = self.Items_Count + 1,displaycount do
		self.Items[i] = { gsid=-999,guid = -999,copies="", };
	end
	
	if(index == nil) then
		return #(self.Items);
	else
		return self.Items[index];
	end
end

function ViewMail:Refresh(delta)
	ViewMail:RefreshParent();

	if(ViewMail.OpMode == ViewMail.SEND_MAIL)then
		self:SetContentCtrl()
	end
end

function ViewMail:OnClickItem(arg,param1)
	if(param1 and param1 == "cancel")then
		MyCompany.Aries.Desktop.AvatarBag:RemoveItem(arg);
	end
end

function ViewMail.RemoveItem(arg)
	local i,v ;
	for i,v in ipairs(ViewMail.DisplayItems)do
		if(v.guid == arg)then
			table.remove(ViewMail.DisplayItems,i);
			break;
		end
	end
end

function ViewMail.Send()
	if(System.options.disable_trading) then
		_guihelper.MessageBox("因个人账户安全原因，物品交换/邮件系统进行维护。预计将在下次更新后修复功能，若提前恢复交易功能不做另行通知。");
		return;
	end
	local error = ViewMail.SetupPackage();
	if(error)then MSG(error) return; end

	if(	ViewMail.Text() == "" or ViewMail.MailTitle() == "" or 	ViewMail.Nid() == "") then 
		MSG("你的邮件无效，请填写完整！");
		return;
	end

	local title = ViewMail.Mail.title;
	if(title and #title > 128) then
		MSG("标题太长了！");return;
	end
	local content = ViewMail.Mail.content;
	if(content and #content > 512) then
		MSG("内容太长了！");return;
	end

	if(	ViewMail.Text() == "" or ViewMail.MailTitle() == "" or ViewMail.Nid() == "") then 
		MSG("你的邮件无效！");
		return 
	end
	NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
	local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
	local bean = MyCompany.Aries.Pet.GetBean();
	if(CommonClientService.IsTeenVersion() and bean and bean.combatlel and bean.combatlel < 20)then
		MSG("你的等级低于20级，不能发邮件！");
		return
	end
	local nid = ViewMail.Nid();
	if(not MyCompany.Aries.ExternalUserModule:CanViewUser(nid)) then
		_guihelper.MessageBox("不同区之间的用户无法发邮件");
	end

	System.App.profiles.ProfileManager.GetUserInfo(nid, "GetUserInfo", function (msg)
		if(msg and msg.users and msg.users[1]) then
			echo(msg.users[1]);
			local nickname = msg.users[1].nickname;
			local combatlel = msg.users[1].combatlel or 0;
			if(CommonClientService.IsTeenVersion() and combatlel < 20)then
				MSG(string.format("你不能和低于20级的%s发邮件！",nickname));
				return
			end
			paraworld.email.send(ViewMail.Mail,nil, function (msg)
				--log(commonlib.serialize(msg))
				if(msg and msg.issuccess)then
					MyCompany.Aries.Desktop.AvatarBag.Clean();
					ViewMail.Mail = {tonid="", date="", title="", attaches="", content=""};
					ViewMail:Refresh();
					--BroadcastHelper.PushLabel({id="mail", label = "你的邮件已经发出.", max_duration=3000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
					_guihelper.MessageBox("你的邮件已经发出.");
				elseif(msg.errorcode == 426)then
					MSG("发送邮件太频繁，请于1分钟后再发送！");
					--493:参数不正确 419:用户不存在 427:物品不足 426:太频繁 433:邮箱已满
				elseif(msg.errorcode == 419)then
					MSG("你发往的邮件用户不存在！");
				elseif(msg.errorcode == 493)then
					MSG("你的邮件无效！");
				elseif(msg.errorcode == 433)then
					MSG("对方邮箱已满！");
				else
					MSG("发送邮件失败！");
				end
			end)
		end
	end);
end

function ViewMail.SetNid(arg)
	if(arg)then
		local ctrl = ViewMail.page:FindControl(arg);
		ViewMail.Nid(ctrl.text)
	end
end

function ViewMail.SetMailContent()
    local ctrl = ViewMail.page:FindControl("MyTextArea2");
	
	if(ctrl and ctrl.GetText)then
		ViewMail.Text(ctrl:GetText())
	end
    ctrl = ViewMail.page:FindControl("txtTitle");
    if(ctrl and ctrl.GetText)then
		ViewMail.MailTitle(ctrl:GetText())
	end
end

function ViewMail.SetupPackage()
	local ctrl = ViewMail.page:FindControl("MyTextArea2");
	local content;
	if(ctrl and ctrl.GetText)then
		content = ctrl:GetText()
		ViewMail.Text(content);
	end

	ctrl = ViewMail.page:FindControl("txtTitle");
	local title;
	if(ctrl and ctrl.GetText)then
		title = ctrl:GetText();
		ViewMail.MailTitle(title);
	end

	ctrl = ViewMail.page:FindControl("ddlFriends");
	local nid = ctrl:GetValue();

	if(ctrl and nid)then
		if(nid == "")then
			msg = "你还没有输入收件人."
			return msg;
		end

		if(content=="" or not content) then
			msg = "请输入邮件内容"
			return msg;
		else
			if(string.len(content) > 512) then
				msg = "邮件内容太长了"
				return msg;
			end
		end

		if(title=="" or not title) then
			msg = "请输入邮件标题"
			return msg;
		else
			if(string.len(title) > 128) then
				msg = "邮件标题太长了"
				return msg;
			end
		end
		nid = tonumber(nid)
		if(nid)then
			local len = string.len(nid);
			if(len < 5)then msg = "无效的数字帐号."; return msg;end;
			ViewMail.Nid(nid)
		else
			nid = string.match(ctrl:GetValue(),"%((%d+)%)");	
			if(nid)then
				local len = string.len(nid);

				--if(not ViewMail:Check(ctrl.text))then msg = "请输入对方的数字帐号.";return msg;end;
				if(len < 5)then msg = "无效的数字帐号."; return msg;end;
				ViewMail.Nid(nid)
			else
				msg = "请先选择一个好友."
				return msg;
			end
		end

	end

	ViewMail.MailDate(ViewMail.GetFormattedDate());
end

function ViewMail.SetText()
	local ctrl = ViewMail.page:FindControl("MyTextArea2");
	
	if(ctrl and ctrl.GetText)then
		ViewMail.Text(ctrl:GetText())
	end
end

function ViewMail.SetTitle(arg)
	if(arg)then
		local ctrl = ViewMail.page:FindControl(arg);
		if(ctrl and ctrl.GetText)then
			ViewMail.MailTitle(ctrl:GetText())
		end
	end
end

-- set or get mail title
function ViewMail.MailTitle(arg)
	if(arg)then
		ViewMail.Mail.title = arg;
	else
		return ViewMail.Mail.title;
	end
end


function ViewMail.GetReceiveMailTitle()
	local original_text = ViewMail.MailTitle();
	if(original_text) then
		return BadWordFilter.FilterString(original_text);
	end
	return "";
end

function ViewMail.Reply()
	if(System.options.disable_trading) then
		_guihelper.MessageBox("因个人账户安全原因，物品交换/邮件系统进行维护。预计将在下次更新后修复功能，若提前恢复交易功能不做另行通知。");
		return;
	end
	if(ViewMail.Nid() == 0)then MSG("你不需要回复系统邮件！");return end
	ViewMail.DisplayItems = {};
	MyCompany.Aries.Mail.ViewMail.ShowPage(nil,{nid=ViewMail.Nid(),},1);
end

function ViewMail.IsGetAttachment()
	if(ViewMail.Mail.isgetattach == 0 )then
		return false;
	elseif(ViewMail.Mail.isgetattach == 1 )then
		return true;
	end
end

function ViewMail.TakeGoods(arg)
	if(ViewMail.Mail.isgetattach == 1)then MSG("你的附件已拿走了。");return end
	if(#ViewMail.Mail.attaches == 0)then MSG("你的附件已经损坏了，你可以通过GM提交问题给我们的开发人员!。");return end

	if(ViewMail.Mail.isgetattach == 0 and #ViewMail.Mail.attaches > 0)then
		local attaches = ""
		if(arg == "btnGetAll" or arg ==  "DelMail")then
			local i,v
			for i,v in ipairs(ViewMail.DisplayItems)do
				if(v.gsid ~= -999)then
					attaches = attaches .. string.format("%s,",v.gsid);
				end
			end
		elseif(arg and arg ~= "DelMail")then
			attaches = tostring(arg);
		end

		--[ errorcode ] 419:用户不存在 497:邮件不存在 417:附件已被提取过 423:没有附件 433:物品数量太多了 493:参考错误 494:解析附件数据时异常
		paraworld.email.getattach({eid = MyCompany.Aries.Mail.MailBox.CurrentMail.eid,attaches = attaches,cache_policy = "access plus 30 seconds"},nil,function(msg) 
		if(msg and msg.issuccess)then
			local i,v;
			--[[refresh bags
			if(AvatarBag.bags_family)then
				for i,v in ipairs(AvatarBag.bags_family)do
				ItemManager.GetItemsInBag( v, "0", function(msg)end, "access plus 0 minutes");
				end
			end
			]]
			if(arg == "btnGetAll")then
				local size = #ViewMail.DisplayItems
				ViewMail.DisplayItems = {};
				for i = 1, size do
					table.insert(ViewMail.DisplayItems,{guid = -999,gsid = -999,copies = 1});
				end
				ViewMail.Mail.isgetattach = 1;
				if(ViewMail.Mail.original_msg) then
					ViewMail.Mail.original_msg.isgetattach = 1;
				end
			elseif(arg and arg ~= "DelMail")then --get one item
				for i,v in ipairs(ViewMail.DisplayItems)do
					if(v.gsid == arg)then
						--table.remove(ViewMail.DisplayItems,i);
						ViewMail.DisplayItems[i] = {guid = -999,gsid = -999,copies = 1}
						break;
					end
				end

				local b;
				for i,v in ipairs(ViewMail.DisplayItems)do
					if(v.gsid ~= -999)then
						b = 1;
						break;
					end
				end
				if(not b)then
					ViewMail.Mail.isgetattach = 1
					if(ViewMail.Mail.original_msg) then
						ViewMail.Mail.original_msg.isgetattach = 1;
					end
				end
			end

			--MSG("你成功获取了附件。");
			if(arg and arg == "DelMail")then
				ViewMail.Mail.isgetattach = 1
				MyCompany.Aries.Mail.MailBox._paraworldDelMail(MyCompany.Aries.Mail.MailBox.CurrentMail.eid);
				return;
			end

			ViewMail.UpdateDataSource()
		elseif(msg.errorcode == 433)then
			--echo(msg);
			if(arg == "btnGetAll") then
				MSG("附件中的某个物品背包中达到了最大值，请先清理再来收取。");
			-- 防止玩家误删物品 lipeng 2013.12.30
			--elseif(arg ==  "DelMail")then
				--_guihelper.Custom_MessageBox("无法收取附件.附件中的某个物品背包中达到了最大值.<br/> <font color='#ff0000'>是否强制删除邮件(附件将丢失)？</font>",function(result)
					--if(result == _guihelper.DialogResult.Yes)then
						--ViewMail.Mail.isgetattach = 1
						--MyCompany.Aries.Mail.MailBox._paraworldDelMail(MyCompany.Aries.Mail.MailBox.CurrentMail.eid);
					--end
				--end,_guihelper.MessageBoxButtons.YesNo,{yes = "删除", no = "取消", show_label = true});
			else
				MSG("该物品在背包中达到了最大值，请先清理再来收取。");
			end
		elseif(msg.errorcode == 423)then
			--echo(msg);
			MSG("附件已经不存在了。");
		elseif(msg.errorcode == 417)then
			--echo(msg);
			MSG("你的附件已拿走了。");
		elseif(msg.errorcode == 497)then
			--echo(msg);
			MSG("邮件不存在。");
		elseif(msg.errorcode == 494)then
			--echo(msg);
			MSG("解析附件数据时发生异常。");
		elseif(msg.errorcode == 493)then
			--echo(msg);
			MSG("收取附件参数出错。");
		else
			echo(msg);
			MSG("收取附件出错，你可以通过GM提交问题给我们的开发人员!");
		end
	end);
	end
end

function ViewMail.UpdateDataSource()
	ViewMail.page:CallMethod("gvwAttach1","SetDataSource",ViewMail.DisplayItems);
	ViewMail.page:CallMethod("gvwAttach1","DataBind")
end

function ViewMail.IsVisible()
	if(ViewMail.Visible) then
		return true;
	end
end

function ViewMail.SetVisible(arg)
	ViewMail.Visible = arg;
end

function ViewMail:Clean()
	self.DisplayItems = {};
	self.Visible = false;
	MyCompany.Aries.Desktop.AvatarBag.Clean();
end
function ViewMail:CloseWindow()
	self.page:CloseWindow();
end

