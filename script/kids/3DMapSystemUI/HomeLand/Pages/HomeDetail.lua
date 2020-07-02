--[[
Title: code behind for page HomeDetail.html
Author(s): Leio
Date: 2009/7/23
Desc:  script/kids/3DMapSystemUI/HomeLand/Pages/HomeDetail.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/HomeDetail.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
local HomeDetailPage = {
	page = nil,
	home_name = nil,
};
commonlib.setfield("MyCompany.Aries.Inventory.HomeDetailPage", HomeDetailPage);
function HomeDetailPage.Init()
	local self = HomeDetailPage;
	self.page = document:GetPageCtrl();
end
function HomeDetailPage.DS_Func_Items(index)
	local self = HomeDetailPage;
	if(not self.usersinfo)then return 0 end
	if(index == nil) then
		return #(self.usersinfo);
	else
		return self.usersinfo[index];
	end
end
function HomeDetailPage.ShowPage()
	local self = HomeDetailPage;
	if(self.canvas)then
		local combinedState = self.canvas:GetCommixState();
		self.ChangeState(combinedState);
	end
	--清空访问列表
	self.usersinfo = nil;
	if(self.bean and self.bean.usersinfo)then
		self.usersinfo = commonlib.deepcopy(self.bean.usersinfo);
		local k,v;
		for k,v in ipairs(self.usersinfo) do
			if(v.visitdate)then
				v.visitdate = string.gsub(v.visitdate, "%s.*$", "");
			end
			local nid = v.nid;
			v.priority = k;
			if(nid)then
				local isOnline = MyCompany.Aries.Friends.IsUserOnlineInMemory(nid);
				local isFriend = MyCompany.Aries.Friends.IsFriendInMemory(nid);
				if(isOnline and isFriend)then
					local priority = k - 10000;
					v.priority = priority;
				end
			end
		end
		table.sort(self.usersinfo, function(a, b)
			return (a.priority < b.priority);
	    end);
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/HomeLand/Pages/HomeDetail.html", 
			name = "HomeDetailPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -640/2,
				y = -250,
				width = 653,
				height = 467,
		});
	
end

function HomeDetailPage.ClosePage()
	local self = HomeDetailPage;
	self.Clear();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="HomeDetailPage.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,bDestroy = true,});
end

function HomeDetailPage.Clear()
	local self = HomeDetailPage;
	self.show = false;
	self.canvas = nil;
	self.node = nil;
	self.bean = nil;
	self.page = nil;
	self.curState = nil;
	self.homeinfo = nil;
end
--[[
	bean
	--家园的一些列信息
	--家园的信息
	houseinfo = {
			 flowercnt=21,
			 name="??gggg",
			 pugcnt=14,
			 visitcnt=3,
			 visitors="nid|05/08/2009 21:02:31,nid|05/08/2009 21:01:41" 
			}
			
	--访问者的信息
	usersinfo = {
		{ nid=166, nickname="leio1", userid="71d6a011-69da-4a4a-bcea-750d2ac954cd",visitdate="05/08/2009 21:02:31"}
	}
	giftinfo
	/// <summary>
    /// 取得指定的用户的礼品盒
    /// 接收参数：
    ///     nid
    /// 返回值：
    ///     boxcnt （所拥有的礼品盒数）
    ///     giftcnt （共收到了多少礼物）
    ///     sendcnt （共向别人赠送了多少礼品）
    ///     [ errorcode ]
    /// </summary>
    
	giftinfo_detail
	
	/// 取得指定用户收到的所有礼物
    /// 接收参数：
    ///     nid
    /// 返回值：
    ///     gifts[list]
    ///         id
    ///         from
    ///         gsid
    ///         msg
    ///         adddate
    ///     [ errorcode ]
  
    主人的个人信息
	homemaster_info = { emoney=0, nickname="leio3", nid=19484, pmoney=0 }

	-------
	homeinfo = {
		hasSendFlower = false, 
		hasSendPug = false,
	}
]]
function HomeDetailPage.Bind(canvas,nid,bean,homeinfo)
	local self = HomeDetailPage;
	if(not canvas or not homeinfo)then return end
	self.canvas = canvas;
	self.nid = nid;
	self.bean = bean;
	self.homeinfo = homeinfo;
end
function HomeDetailPage.BindCanvas(canvas)
	local self = HomeDetailPage;
	self.canvas = canvas;
end
function HomeDetailPage.BindNode(node)
	local self = HomeDetailPage;
	self.node = node;
end
function HomeDetailPage.BindBean(bean)
	local self = HomeDetailPage;
	self.bean = bean;
end
function HomeDetailPage.ChangeState(combinedState)
	local self = HomeDetailPage;
	if(not combinedState)then return end
	if(combinedState == "master_outside_true" or combinedState == "master_inside_true")then
		self.curState = "master_view";
	elseif(combinedState == "master_outside_false" or combinedState == "master_inside_false")then
		self.curState = "master_view";
	elseif(combinedState == "guest_outside_false" or combinedState == "guest_inside_false")then
		self.curState = "guest_view";
	end		
end
function HomeDetailPage.isGuestView()
	local self = HomeDetailPage;
	return self.curState == "guest_view";
end
function HomeDetailPage.isMasterView()
	local self = HomeDetailPage;
	return self.curState == "master_view"; 
end
function HomeDetailPage.isMasterEdit()
	local self = HomeDetailPage;
	return self.curState == "master_edit";
end
function HomeDetailPage.getHomeName()
	local self = HomeDetailPage;
	if(self.bean and self.bean.houseinfo)then
		return self.bean.houseinfo.name;
	end
end
function HomeDetailPage.getVisitNum()
	local self = HomeDetailPage;
	if(self.bean and self.bean.houseinfo)then
		return self.bean.houseinfo.visitcnt;
	end
end
function HomeDetailPage.getFlowerNum()
	local self = HomeDetailPage;
	if(self.bean and self.bean.houseinfo)then
		return self.bean.houseinfo.flowercnt;
	end
end
function HomeDetailPage.getBugNum()
	local self = HomeDetailPage;
	if(self.bean and self.bean.houseinfo)then
		return self.bean.houseinfo.pugcnt;
	end
end

function HomeDetailPage.DoRename()
	local self = HomeDetailPage;
	self.curState = "master_edit";
	if(self.page)then
		self.page:Refresh(0.1);
	end
end
function HomeDetailPage.DoSave()
	local self = HomeDetailPage;
	local homename_text = self.page:GetValue("home_name");
	if(homename_text)then
		NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
		local maxlen = Map3DSystem.App.HomeLand.HomeLandConfig.HomeNameMax;
		local txt = homename_text;
		local txt_len = string.len(txt);
		if(txt_len <=0)then
			_guihelper.MessageBox("名称不能为空！");
			return;
		elseif(txt_len  > maxlen)then
			_guihelper.MessageBox(string.format("你的名称太长了，换一个吧！",maxlen));
			return;
		else
			local msg = {
					sessionkey = Map3DSystem.User.sessionkey,
					name = txt,
				}
				paraworld.homeland.home.Update(msg,"home",function(msg)	
					if(msg and msg.issuccess)then
						self.curState = "master_view";
						self.bean.houseinfo.name = txt;
						if(self.page)then
							self.page:Refresh(0.1);
						end
					end
				end);
		end
	end
end
function HomeDetailPage.DoFlower()
	local self = HomeDetailPage;
	if(not self or not self.bean or not self.nid or not self.homeinfo or not self.bean.houseinfo)then return end
	local nid = self.nid;
	local content;
	local name = "";
	local homemaster_info = self.bean.homemaster_info;
	if(homemaster_info)then
		name = homemaster_info.nickname or "";
	end
	if(nid ~= Map3DSystem.User.nid)then
		local msg = {
			homenid = nid,
			sessionkey = Map3DSystem.User.sessionkey,
		}
		local content;
		if(self.homeinfo.hasSendFlower == false)then
			paraworld.homeland.home.SendFlower(msg,"home",function(msg)	
					if(msg and msg.issuccess)then
						if(not self.bean.houseinfo.flowercnt)then
							self.bean.houseinfo.flowercnt = 0;
						end
						self.bean.houseinfo.flowercnt = self.bean.houseinfo.flowercnt + 1;
						self.homeinfo.hasSendFlower = true;
						self.homeinfo.hasSendPug = true;
						content = string.format("你已经给%s(%d)的家园献上了一朵鲜花。",name,nid);
						_guihelper.MessageBox(content, nil, _guihelper.MessageBoxButtons.OK,nil,{OK = "知道了"});
						
						local hook_msg = { aries_type = "OnSendFlower", to = self.nid, wndName = "main"};
						CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
						
						local hook_msg = { aries_type = "onSendFlower_MPD", to = self.nid, wndName = "main"};
						CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);

						if(self.page)then
							self.page:Refresh(0.1);
						end
					end
			end);
		else
			content = string.format("你已经评价过这个家园了，下次再来吧。",name);
			_guihelper.MessageBox(content, nil, _guihelper.MessageBoxButtons.OK,nil,{OK = "知道了"});
		end

	else
		content = "你只能为其他人的家园投鲜花或丢泥巴哦。";
		_guihelper.MessageBox(content, nil, _guihelper.MessageBoxButtons.OK,nil,{OK = "知道了"});
	end
	
end
function HomeDetailPage.DoPug()
	local self = HomeDetailPage;
	if(not self or not self.bean or not self.nid or not self.homeinfo  or not self.bean.houseinfo)then return end
	local nid = self.nid;
	local content;
	local homemaster_info = self.bean.homemaster_info;
	local name = "";
	if(homemaster_info)then
		name = homemaster_info.nickname or "";
	end
	if(nid ~= Map3DSystem.User.nid)then
		local msg = {
				sessionkey = Map3DSystem.User.sessionkey,
				homenid = nid,
			}
		local content;
		if(self.homeinfo.hasSendPug == false)then	
			paraworld.homeland.home.SendPug(msg,"home",function(msg)	
				if(msg and msg.issuccess)then
					if(not self.bean.houseinfo.pugcnt)then
						self.bean.houseinfo.pugcnt = 0;
					end
					self.bean.houseinfo.pugcnt = self.bean.houseinfo.pugcnt + 1;
					self.homeinfo.hasSendFlower = true;
					self.homeinfo.hasSendPug = true;
					content = string.format("你已经给%s(%d)的家园丢了一块泥巴。",name,nid);
					_guihelper.MessageBox(content, nil, _guihelper.MessageBoxButtons.OK,nil,{OK = "知道了"});
					if(self.page)then
						self.page:Refresh(0.1);
					end
				end
			end);
		else
			content = string.format("你已经评价过这个家园了，下次再来吧。",name);
			_guihelper.MessageBox(content, nil, _guihelper.MessageBoxButtons.OK,nil,{OK = "知道了"});
		end
	else
		content = "你只能为其他人的家园投鲜花或丢泥巴哦。";
		_guihelper.MessageBox(content, nil, _guihelper.MessageBoxButtons.OK,nil,{OK = "知道了"});
	end
end
function HomeDetailPage.ShowUserInfo(nid)
	if(not nid)then return end
	System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
end
--是否可以投鲜花/泥巴
function HomeDetailPage.CanVote()
	local self = HomeDetailPage;
	if(not self or not self.bean or not self.nid or not self.homeinfo  or not self.bean.houseinfo)then return false end
	local nid = self.nid;
	if(nid == Map3DSystem.User.nid)then
		return false;
	end
	if(self.homeinfo.hasSendFlower or self.homeinfo.hasSendPug)then
		return false;
	end
	return true;
end
-------------------------------------------------
function HomeDetailPage.ShowFastChannelPage()
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/HomeLand/Pages/HomeFastChannel.html", 
			name = "HomeDetailPage.ShowFastChannelPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -322/2,
				y = -216,
				width = 322,
				height = 216,
		});
end