--[[
Title: 
Author(s): leio
Date: 2013/4/11
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Mail/WriteMailPage.lua");
local WriteMailPage = commonlib.gettable("MyCompany.Aries.Mail.WriteMailPage");
WriteMailPage.ShowPage(to_nid,title,content)
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfileManager.lua");
local ProfileManager = commonlib.gettable("Map3DSystem.App.profiles.ProfileManager");
NPL.load("(gl)script/apps/Aries/Friends/FriendsManager.lua");
local FriendsManager = commonlib.gettable("MyCompany.Aries.FriendsManager");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Mail/MailPage.lua");
local MailPage = commonlib.gettable("MyCompany.Aries.Mail.MailPage");
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local WriteMailPage = commonlib.gettable("MyCompany.Aries.Mail.WriteMailPage");
WriteMailPage.page_size = 40;
WriteMailPage.max_cnt = 6;
function WriteMailPage.OnInit()
	WriteMailPage.page = document:GetPageCtrl();	
end
function WriteMailPage.RefreshPage()
	if(WriteMailPage.page)then
		WriteMailPage.page:Refresh(0);
	end
end
function WriteMailPage.CheckTempKey(attaches_list)
	if(not attaches_list)then
		return
	end
	local k,v;
	for k,v in ipairs(attaches_list) do
		if(not v.gsid)then
			v.gsid = -10;
		end
	end
end
function WriteMailPage.ShowPage(to_nid,title,content)
	to_nid = tonumber(to_nid);
	if(to_nid and to_nid <=0)then
		_guihelper.MessageBox("系统邮件，不需要回复！");
		return
	end
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	if(not DealDefend.CanPass())then
		return
	end
	WriteMailPage.to_nid = tonumber(to_nid);
	WriteMailPage.title = title or "";
	WriteMailPage.content = content or "";
	WriteMailPage.attaches_list = {};
	WriteMailPage.item_list = {};
	WriteMailPage.bag_is_show = false;
	CommonClientService.Fill_List(WriteMailPage.attaches_list,WriteMailPage.max_cnt);
	WriteMailPage.CheckTempKey(WriteMailPage.attaches_list);
	local url = "script/apps/Aries/Mail/WriteMailPage.teen.html";
	local params = {
			url = url, 
			name = "WriteMailPage.ShowPage", 
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
	WriteMailPage.LoadItems();
	WriteMailPage.LoadFriends();
end
function WriteMailPage.LoadItems()
	local item_list = BagHelper.Search_Memory();
	local result = {};
	if(item_list)then
		local k,v;
		for k,v in ipairs(item_list) do
			local gsid = v.gsid;
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
			if(gsItem and gsItem.template.canexchange and gsItem.template.cangift)then
				local __,__,__,cnt = hasGSItem(gsid);
				cnt = cnt or 0;
				if(cnt > 0)then
					table.insert(result,{
						gsid = gsid,
						cnt = cnt,
					});
				end
			end
		end
	end
	CommonClientService.Fill_List(result,40)
	WriteMailPage.item_list = result;
end
function WriteMailPage.LoadFriends()
	local manager = FriendsManager.CreateOrGetManager();
	manager:SearchBuddyList(function(msg)
		if(msg and msg.list)then
			local list = msg.list;
			local result = {};
			local k,v;
			if(WriteMailPage.to_nid)then
				local searched = false;
				for k,v in ipairs(list) do
					if(WriteMailPage.to_nid == v.nid)then
						searched = true;
						break;
					end
				end
				if(not searched)then
					table.insert(list,{nid = WriteMailPage.to_nid});
				end
			end
			local find;
			local len = #list;
			local function search(index)
				local friend = list[index];
				if(not friend or not friend.nid)then
					if(not find)then
						local node = result[1];
						if(node)then
							node.selected = true;
							WriteMailPage.to_nid = node.nid;
						end
					end
					WriteMailPage.buddy_list = result;
					WriteMailPage.RefreshPage();
					if(WriteMailPage.page)then
						local _editbox = WriteMailPage.page:FindControl("txtTitle");
						if(_editbox and _editbox.Focus)then
							_editbox:Focus();
						end
					end	
					return
				end
				local nid = friend.nid;
				ProfileManager.GetUserInfo(nid, "GetUserInfo" .. nid, function(msg)
					if(msg and msg.users and msg.users[1]) then
						local user = msg.users[1];
						local nickname = user.nickname;
						local combatlel = user.combatlel;
						
						local selected = false;
						if(WriteMailPage.to_nid and WriteMailPage.to_nid == nid)then
							selected = true;
							find = true;
						end
						local node = {
							value = string.format("%s(%s)",nickname,nid),
							nid = nid,
							selected = selected,
							nickname = nickname,
							combatlel = combatlel,
						}
						table.insert(result,node);
						index = index + 1;
						search(index);
					end
				end);
			end
			search(1);
		end
	end)
end
function WriteMailPage.OnSend()
    if(not WriteMailPage.to_nid or not WriteMailPage.page)then
        _guihelper.MessageBox("无效的邮件！");
        return
    end
    local txtTitle = WriteMailPage.page:GetValue("txtTitle");
	local cnt = ParaMisc.GetUnicodeCharNum(txtTitle);
    if(cnt == 0)then
        _guihelper.MessageBox("请输入邮件主题！");
        return
    end
    if(cnt > 128 )then
        _guihelper.MessageBox("主题太长了！");
        return
    end
    local content = WriteMailPage.page:GetValue("content");
	if(not content or content == "")then
		content = txtTitle;
	end
	local cnt = ParaMisc.GetUnicodeCharNum(content);
    if(cnt > 512 )then
        _guihelper.MessageBox("内容太长了！");
        return
    end
    local bean = MyCompany.Aries.Pet.GetBean();
	if(CommonClientService.IsTeenVersion() and bean and bean.combatlel and bean.combatlel < 20)then
		_guihelper.MessageBox("你的等级低于20级，不能发邮件！");
		return
	end
	if(not MyCompany.Aries.ExternalUserModule:CanViewUser(WriteMailPage.to_nid)) then
		_guihelper.MessageBox("不同区之间的用户无法发邮件");
	end
	local node = WriteMailPage.GetSelectedNode();
	if(node)then
		local combatlel = node.combatlel or 0;
		local nickname = node.nickname or "";
		if(CommonClientService.IsTeenVersion() and combatlel < 20)then
			_guihelper.MessageBox(string.format("你不能和低于20级的%s发邮件！",nickname));
			return
		end
		local cost = WriteMailPage.GetCost();
		local __,__,__,copies = hasGSItem(0);
		copies = copies or 0;
		if(copies < cost)then
			_guihelper.MessageBox("你的银币不够，不能发送邮件！");
			return
		end
		local attaches;
		if(WriteMailPage.attaches_list)then
			local k,v;
			for k,v in ipairs(WriteMailPage.attaches_list) do
				local gsid = v.gsid;
				local cnt = v.cnt or 0;
				if(gsid and gsid > 0)then
					local __,guid,__,copies = hasGSItem(gsid);
					copies = copies or 0
					if(guid and cnt > 0 and cnt <= copies )then
						if(not attaches)then
							attaches = string.format("%d,%d",guid,cnt);
						else
							attaches = string.format("%s|%d,%d",attaches,guid,cnt);
						end
					end
				end
			end
		end
		local BadWordFilter = commonlib.gettable("MyCompany.Aries.Chat.BadWordFilter");
		local replaced_name = BadWordFilter.FilterStringForUserName(txtTitle);
		if( replaced_name ~= txtTitle)then
			_guihelper.MessageBox("标题中包含非法字符，无法发送邮件！");
			return;
		end
		replaced_name = BadWordFilter.FilterStringForUserName(content);
		if( replaced_name ~= content)then
			_guihelper.MessageBox("邮件内容中包含非法字符，无法发送邮件！");
			return;
		end
		local msg = {
			tonid = WriteMailPage.to_nid,
			title = txtTitle,
			content = content,
			attaches = attaches,
		}
		paraworld.email.send(msg,nil, function (msg)
			if(msg and msg.issuccess)then
				_guihelper.MessageBox("你的邮件已经发出.");
				WriteMailPage.page:CloseWindow();
				local updates = {
					{gsid = 0,},
				}
				ItemManager.UpdateBagItems(updates)
			elseif(msg.errorcode == 426)then
				_guihelper.MessageBox("发送邮件太频繁，请于1分钟后再发送！");
				--493:参数不正确 419:用户不存在 427:物品不足 426:太频繁 433:邮箱已满
			elseif(msg.errorcode == 419)then
				_guihelper.MessageBox("你发往的邮件用户不存在！");
			elseif(msg.errorcode == 493)then
				_guihelper.MessageBox("你的邮件无效！");
			elseif(msg.errorcode == 433)then
				_guihelper.MessageBox("对方邮箱已满！");
			else
				_guihelper.MessageBox("发送邮件失败！");
			end
		end)
	end
end
function WriteMailPage.GetSelectedNode()
	if(WriteMailPage.to_nid and WriteMailPage.buddy_list)then
		local k,v;
		for k,v in ipairs(WriteMailPage.buddy_list) do
			if(v.nid == WriteMailPage.to_nid)then
				return v;
			end
		end
	end
end
function WriteMailPage.OnSelectFriend(ctrl,value)
    if(value)then
        WriteMailPage.to_nid = tonumber(string.match(value,"%((%d+)%)"));
    end
end
function WriteMailPage.DS_Func(index)
	if(not WriteMailPage.attaches_list)then return 0 end
	if(index == nil) then
		return #(WriteMailPage.attaches_list);
	else
		return WriteMailPage.attaches_list[index];
	end
end
function WriteMailPage.DS_Func_bag(index)
	if(not WriteMailPage.item_list)then return 0 end
	if(index == nil) then
		return #(WriteMailPage.item_list);
	else
		return WriteMailPage.item_list[index];
	end
end
function WriteMailPage.SwapItems(from,to,gsid,cnt)
	if(from and to and gsid)then
		cnt = cnt or 1;
		local len = #from;
		while(len > 0) do
			local node = from[len];
			if(node)then
				if(node.gsid == gsid)then
					node.cnt = node.cnt or 0;
					cnt = math.min(node.cnt,cnt);
					node.cnt = node.cnt - cnt;
					if(node.cnt <= 0)then
						table.remove(from,len);
						break;
					end
				end
			end
			len = len - 1;
		end
		CommonClientService.Fill_List(WriteMailPage.item_list,WriteMailPage.page_size);
		CommonClientService.Fill_List(WriteMailPage.attaches_list,WriteMailPage.max_cnt);
		WriteMailPage.CheckTempKey(WriteMailPage.attaches_list);
		if(cnt <= 0)then
			return
		end
		local k,v;
		for k,v in ipairs(to) do
			if(v.gsid == gsid)then
				v.cnt = v.cnt or 0;
				v.cnt = v.cnt + cnt;
				return
			end
		end
		for k,v in ipairs(to) do
			if(v.gsid == nil or v.gsid < 0)then
				v.gsid = gsid;
				v.cnt = cnt;
				return
			end
		end
	end
	
end
function WriteMailPage.GetCost()
    local cnt = 1000;
    if(WriteMailPage.attaches_list)then
        local k,v;
        for k,v in ipairs(WriteMailPage.attaches_list) do
            if(v.gsid and v.cnt and v.cnt > 0)then
                cnt = cnt + v.cnt * 500;
            end
        end
    end
    return cnt;
end
function WriteMailPage.OnKeyUp_Title()
	if(WriteMailPage.page)then
	end
end