--[[
Title: 
Author(s): WD
Date: 2011/11/18
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Mail/MailBox.lua");
MyCompany.Aries.Mail.MailBox.ShowPage();
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");
NPL.load("(gl)script/apps/Aries/Mail/ViewMail.lua");
NPL.load("(gl)script/ide/EventDispatcher.lua");
NPL.load("(gl)script/apps/Aries/Mail/MailManager.lua");
NPL.load("(gl)script/apps/Aries/Desktop/AvatarBag.lua");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");

local ViewMail = commonlib.gettable("MyCompany.Aries.Mail.ViewMail");
local MailBox = commonlib.inherit(commonlib.EventSystem, commonlib.gettable("MyCompany.Aries.Mail.MailBox"));  
local Avatar_gems_subpage = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_gems_subpage");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local ItemManager = Map3DSystem.Item.ItemManager;
local MSG = _guihelper.MessageBox;
local echo = commonlib.echo;

local EXPIRED_DAYS = 30;
local GIFTS_SLOTS_SIZE = 6;

if(System.options.version =="kids" or not System.options.version or System.options.version == "")then
	MailBox.PageSize = 9;
else
	MailBox.PageSize = 10;
end

MailBox.filter = MailBox.filter or 0;
MailBox.SendBox = {};
MailBox.ReceiveBox = {};
MailBox.DisplayItems = {};
MailBox.Gifts = {};
MailBox.CurrentMail = {};
MailBox.pindex = 0
MailBox.pcnt = 1;
MailBox.MyFriend = MailBox.MyFriend or {};

-- call constructor, since it is a singleton. 
MailBox:ctor();

function MailBox:Init()
	self.page = document:GetPageCtrl();
	if(self.filter ~= 0) then
		self.page:SetValue("tabsMailBx",tostring(self.filter));
	end
end

function MailBox.ShowPage(mail)
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	local can_pass = DealDefend.CanPass();
	if(not can_pass)then return end

	if(CommonClientService.IsTeenVersion())then
		NPL.load("(gl)script/apps/Aries/Mail/MailPage.lua");
		local MailPage = commonlib.gettable("MyCompany.Aries.Mail.MailPage");
		MailPage.ShowPage();
		return
	end
	local Friends = MyCompany.Aries.Friends;
	local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");
	if(Friends and ProfileManager)then
		Friends.GetMyFriends(function(msg)
			local RealCount = Friends.GetFriendCountInMemory();
			local Count = Friends.GetFriendCountInMemory();
			local i;
			for i = 1, Count do
				local nid = Friends.GetFriendNIDByIndexInMemory(i);
				if(not MailBox.ContainNid(nid))then
					ProfileManager.GetUserInfo(nid, "GetUserInfo" .. nid, function(msg)
					if(msg and msg.users and msg.users[1]) then
						local user = msg.users[1];
						table.insert(MailBox.MyFriend,{value=string.format("%s(%s)",user.nickname,user.nid),nid=user.nid,selected = false,});
						end
					end);
					
				end


			end

		end, "access plus 10 minutes");
		
	else
		echo("Friends or ProfileManager instance is not initialized.");
	end

	--make sure the value of width and height is copy from design page
	local width,height = 791,470;
	local page_addr = "script/apps/Aries/Mail/MailBox.html";
	if(System.options.version =="kids" or not System.options.version or System.options.version == "")then
		page_addr = "script/apps/Aries/Mail/MailBox.kids.html";
	end

	local params = {
        url = page_addr, 
        app_key = MyCompany.Aries.app.app_key, 
        name = "MailBox.ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = CommonCtrl.WindowFrame.ContainerStyle,
		enable_esc_key = true,
        --zorder = 2,
        allowDrag = true,
		isTopLevel = false,
        directPosition = true,
        align = "_ct",
        x = -width * 0.5,
        y = -height * 0.5,
        width = width,
        height = height,}
    System.App.Commands.Call("File.MCMLWindowFrame", params);
	if(params._page)then
		params._page.OnClose = MailBox.Clean;
	end

	if(mail)then
		if(not MailBox.ContainNid(mail.nid))then
			table.insert(MailBox.MyFriend,{value=tostring(mail.nid),nid=mail.nid,selected = false,});
		end
		MailBox.WriteMail({nid = mail.nid,title = mail.title});
		MyCompany.Aries.Desktop.AvatarBag:Show("Mail",ViewMail,GIFTS_SLOTS_SIZE, true);
	end
	MailBox.GetAllMail(false,"access plus 5 seconds");
end

function MailBox:FilterItems(arg)
	self.filter = tonumber(arg);
	self:Refresh();
end

function MailBox.ContainNid(nid)
	local i,v
	for i,v in ipairs(MailBox.MyFriend)do
		if(v.nid == nid)then
			return v.nid;
		end
	end
end
function MailBox.GetMyFriends()
	return MailBox.MyFriend;
end
function MailBox.SelectFriend(nid)
	local i,v,b
	for i,v in ipairs(MailBox.MyFriend)do
		if(v.nid == nid)then
			v.selected = true;
			b = 0;
		else
			v.selected = false;
		end
	end

	return b;
end

function MailBox:GetDataSource(index)
	self.Items_Count = 0;
	if(self.DisplayItems)then
		self.Items_Count = #self.DisplayItems;
	end
	local displaycount = math.ceil(self.Items_Count / self.PageSize) * self.PageSize;
	if(displaycount == 0)then
		displaycount = self.PageSize;
	end

	local i;
	for i = self.Items_Count + 1,displaycount do
		self.DisplayItems[i] = { id="",eid="",date="",mail_status=-1,title="",isread=-1,isgetattach=0,expire_days = "",is_selected=false, };
	end

	if(index == nil) then
		return #(self.DisplayItems);
	else
		return self.DisplayItems[index];
	end
end

function MailBox:GetGifts(index)
	local displaycount = math.ceil(#self.Gifts / GIFTS_SLOTS_SIZE) * GIFTS_SLOTS_SIZE;
	if(displaycount == 0)then
		displaycount = GIFTS_SLOTS_SIZE;
	end

	local i;
	for i = #self.Gifts + 1,displaycount do
		self.Gifts[i] = { gsid=-999,copies=1, };
	end
	
	if(index == nil) then
		return #(self.Gifts);
	else
		return self.Gifts[index];
	end
end

function MailBox:OnClickItem(arg)
	
	if(arg)then
		if(self.CurrentMail.eid == arg and ViewMail.IsVisible() and ViewMail.OpMode == ViewMail.RECEIVE_MAIL)then return end;
		local i,v; 
		for i,v in ipairs(self.DisplayItems)do
			if(v.eid == arg and not v.is_selected)then
				v.is_selected = true;
				if(v.mail_status < 3)then
					v.mail_status = v.mail_status + 2;
					MailBox.UnReadMail = MailBox.UnReadMail - 1
					MailBox.RefreshGlobalUI();
				end
				self.CurrentMail = v;
			elseif(v.eid ~= arg)then
				v.is_selected = false;
			end
		end

		MailBox.UpdateDataSource();
		MailBox.ViewMail();
	end
end

function MailBox.RefreshGlobalUI()
	local unread_mail = MailBox.UnReadMail or 0;
	if(System.options.version == "kids") then
		unread_mail = unread_mail + (MyCompany.Aries.Quest.Mail.MailManager.GetLength() or 0);
	end

	MailBox:DispatchEvent({type = "unread_mail_change" , unread_mail = unread_mail});
end

function MailBox.UpdateDataSource()
	MailBox.page:CallMethod("pegvwMailList","SetDataSource",MailBox.DisplayItems);
	MailBox.page:CallMethod("pegvwMailList","DataBind");
end

function MailBox.ViewMail()
	if(MailBox.CurrentMail.eid)then
		MailBox.ReadMail(MailBox.CurrentMail.eid);
	end
end

function MailBox.ReadMail(eid,cache_policy)
	paraworld.email.read({eid = eid, cache_policy = cache_policy}, nil,
	function(msg) 
		MyCompany.Aries.Mail.ViewMail.ShowPage(MailBox,{original_msg = msg, tonid = msg.from,title=msg.title,date=msg.cdate,content=msg.content,isread=msg.isread,isgetattach=msg.isgetattach,attaches=msg.attaches},MailBox.filter);
	end);

end

function MailBox.GetExpiredDays(date)
	local y,m,d = tonumber(string.match(date,"(%d+)-")),tonumber(string.match(date,"-(%d+)-")),tonumber(string.match(date,"-(%d+) "))

	local tt = ViewMail.GetFormattedDate();
	local ty,tm,td = tonumber(string.match(tt,"(%d+)-")),tonumber(string.match(tt,"-(%d+)-")),tonumber(string.match(tt,"-(%d+) "))

	if(tm == m)then
		return EXPIRED_DAYS - (td - d);
	else
		if(math.abs(tm - m) > 1)then
			return 0;
		else
			if(d - td < 0)then return 0 else
			return d - td
			end
		end
	end
end

function MailBox._paraworldDelMail(eid)
	paraworld.email.delete({eid = eid,},nil,function(msg) 
		if(msg and msg.issuccess)then
			MailBox.CurrentMail = {};
			MailBox:OnDeleteMail(eid)
			MailBox.UpdateDataSource();
			ViewMail.Hide();
		end
	end);
end

--[[
	before delete select mail,make sure get all attaches,any unsuccess get must break it
]]
function MailBox.DelSelectMail()
	if(ViewMail.Mail.isgetattach == 0 and #ViewMail.Mail.attaches > 0)then
		_guihelper.Custom_MessageBox("你确定删除该邮件么？<br/>邮件中包含未收附件(删除时会自动收取附件)",function(result)
			if(result == _guihelper.DialogResult.Yes)then
				ViewMail.TakeGoods("DelMail")
			end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "删除", no = "取消", show_label = true});
	else
		_guihelper.Custom_MessageBox("你确定删除该邮件么？", function(result)
			if(_guihelper.DialogResult.Yes == result) then
				MailBox._paraworldDelMail(MailBox.CurrentMail.eid);
			end
		end, _guihelper.MessageBoxButtons.YesNo,{yes = "删除", no = "取消", show_label = true});
	end
end

--change page code on delete mail
function MailBox:OnDeleteMail(eid)
	commonlib.removeArrayItems(MailBox.DisplayItems, 
		function(i, mail) 
			return (mail.eid==eid); 
		end);

	local i,v,cnt
	cnt = 0
	for i,v in ipairs(MailBox.DisplayItems)do
		if(v.eid ~= "")then
			cnt = cnt + 1;
		end
	end
	if(cnt == 1)then
		MailBox.pindex = 0;
	end
end

-- goto a given page. 
function MailBox.getofpage(arg)
	MailBox.pindex = MailBox.pindex or 0;
	if(arg == 0 or arg == "0")then
		if(MailBox.pindex == 0)then return end
		MailBox.pindex = MailBox.pindex - 1;
		
	elseif(arg == 1 or arg == "1")then
		if(MailBox.pindex == (MailBox.pcnt - 1))then return end
		MailBox.pindex = MailBox.pindex + 1;
	end

	MailBox.GetAllMail(true);
end

--
-- @param arg:a flag indicate to get mail list by specified page index.
-- @param cache_policy: nil for 20 seconds, or it can be "access plus 0 day"
function MailBox.GetAllMail(arg,cache_policy)
	local pindex;
	if(arg)then 
		pindex = MailBox.pindex;
	else 
		pindex = 0; 
	end

	paraworld.email.getofpage({nid=nil,pindex=pindex,psize =MailBox.PageSize, cache_policy = cache_policy or "access plus 20 seconds"}, "checkemail",function(msg)
		if(msg and msg.list)then
			if(MailBox.pcnt == 1 or MailBox.pcnt ~= msg.pcnt)then
				MailBox.pcnt = msg.pcnt;
			end
			MailBox.DisplayItems = {};

			local i,v;
			local UnReadMail = 0;
			for i,v in ipairs(msg.list)do
				local mail = {id=v.from,title=v.title,
								eid = v.eid,date=v.cdate,
								mail_status=MailBox.getStatus(v.from,v.isread),
								expire_days=MailBox.GetExpiredDays(v.cdate),isread=v.isread,is_selected=false,
								isgetattach=v.isgetattach,};
				if(v.isread == 0)then
					UnReadMail  = UnReadMail + 1;
				end

				if(mail.eid == MailBox.CurrentMail.eid)then
					mail.is_selected = true;
				end
				table.insert(MailBox.DisplayItems,mail); 
			end

			if(UnReadMail ~= MailBox.UnReadMail)then
				MailBox.UnReadMail = UnReadMail;
				MailBox.RefreshGlobalUI()
			end
			
			MailBox.UpdateDataSource();
			MailBox.page:SetValue("pagecode",
			string.format("%s/%s",MyCompany.Aries.Mail.MailBox.pindex + 1,MyCompany.Aries.Mail.MailBox.pcnt));
		else
			MailBox.pindex = 0;
		end
	end);
end

function MailBox.GetMail()
	MailBox:Clean();
	MailBox.GetAllMail(false);
end

function MailBox.SendUnReadMailNotification()
	paraworld.email.getofpage({nid=nil, pindex=0, psize =MailBox.PageSize, cache_policy = "access plus 5 seconds"}, nil,function(msg)
		if(msg and msg.list)then
			local i,v;
			local UnReadMail = 0;
			for i,v in ipairs(msg.list)do
				if(v.isread == 0)then
					UnReadMail  = UnReadMail + 1;
				end
		
			end

			if(UnReadMail ~= MailBox.UnReadMail)then
				MailBox.UnReadMail = UnReadMail;
				MailBox.RefreshGlobalUI()
			end
		end
	end); 
end

function MailBox.getStatus(from,isread)
	if(from == 0 and isread == 0)then
		return 2;
	elseif(from == 0 and isread == 1)then
		return 4;
	elseif(from ~= 0 and isread == 0)then
		return 1;
	elseif(from ~= 0 and isread ~= 0)then
		return 3;
	end
	return 0xff;
end

function MailBox.WriteMail(mail)
	if(mail and mail.nid)then 
		MyCompany.Aries.Mail.ViewMail.ShowPage(MailBox,mail,MyCompany.Aries.Mail.ViewMail.SEND_MAIL);		
	else
		MyCompany.Aries.Mail.ViewMail.ShowPage(MailBox,nil,MyCompany.Aries.Mail.ViewMail.SEND_MAIL);		
	end
end

function MailBox:IsVisible()
	if(self.page and self.page:IsVisible())then
	return true
	end
end
function MailBox:Refresh(delta)
	if(self.page)then
		self.page:Refresh(delta or 0.1);
	end
end

function MailBox:Clean()
	self.filter = 0;
	MailBox.pcnt = 1;
	MailBox.pindex = 0;
end
function MailBox:CloseWindow()
	ViewMail.Visible = false;
	self.page:CloseWindow();
end

