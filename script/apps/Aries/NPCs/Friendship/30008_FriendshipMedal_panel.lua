--[[
Title: code behind for page 30008_FriendshipMedal_panel.html
Author(s): Leio
Date: 2009/12/7
Desc:  script/apps/Aries/NPCs/Friendship/30008_FriendshipMedal_panel.html

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Friendship/30008_FriendshipMedal_panel.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/paraworld.homeland.giftbox.lua");
local FriendshipMedal_panel = {
	sendNum = 0,--送礼物的次数
	boxNum = 0,--礼物盒的数量
	
	a_level_num = 10,--赠送礼物达到10次，可领取“友情木徽章”
	b_level_num = 11,--赠送礼物达到50次，可领取“友情铜徽章”
	c_level_num = 12,--赠送礼物达到200次，可领取“友情银徽章”
	d_level_num = 13,--赠送礼物达到800次，可领取“友情金徽章”
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.FriendshipMedal_panel", FriendshipMedal_panel);
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
--20005 友情木徽章
--20001 友情铜徽章
--20002 友情银徽章
--20003 友情金徽章
function FriendshipMedal_panel.OnInit()
	local self = FriendshipMedal_panel;
	self.pageCtrl =  document:GetPageCtrl();
end
function FriendshipMedal_panel.Reset()
	local self = FriendshipMedal_panel;
	self.sendNum = 0;
	self.boxNum = 0;
end
function FriendshipMedal_panel.RefreshPage()
	local self = FriendshipMedal_panel;
	if(self.pageCtrl)then
		self.pageCtrl:Refresh(0.01);
	end
end
function FriendshipMedal_panel.ClosePage()
	local self = FriendshipMedal_panel;
	if(self.pageCtrl)then
		self.pageCtrl:CloseWindow();
	end
end
--是否包含 木徽章
function FriendshipMedal_panel.HasMedal_A()
	local self = FriendshipMedal_panel;
	return hasGSItem(20005);
end
--是否包含 铜徽章
function FriendshipMedal_panel.HasMedal_B()
	local self = FriendshipMedal_panel;
	local r = false;
	if(self.HasMedal_A() and hasGSItem(20001))then
		r = true;
	end
	return r;
end
--是否包含 银徽章
function FriendshipMedal_panel.HasMedal_C()
	local self = FriendshipMedal_panel;
	local r = false;
	if(self.HasMedal_B() and hasGSItem(20002))then
		r = true;
	end
	return r;
end
--是否包含 金徽章
function FriendshipMedal_panel.HasMedal_D()
	local self = FriendshipMedal_panel;
	local r = false;
	if(self.HasMedal_C() and hasGSItem(20003))then
		r = true;
	end
	return r;
end
function FriendshipMedal_panel.ShowMedal()
	local self = FriendshipMedal_panel;
	if(not self.HasMedal_A())then
		return "A";
	end
	if(not self.HasMedal_B())then
		return "B";
	end
	if(not self.HasMedal_C())then
		return "C";
	end
	if(not self.HasMedal_D())then
		return "D";
	end
end
function FriendshipMedal_panel.ShowMedal_A()
	local self = FriendshipMedal_panel;
	if(self.sendNum < self.a_level_num and not self.HasMedal_A() )then
		return true;
	end
end
function FriendshipMedal_panel.ShowMedal_B()
	local self = FriendshipMedal_panel;
	if(self.sendNum >= self.a_level_num and self.sendNum < self.b_level_num and not self.HasMedal_B() )then
		return true;
	end
end
function FriendshipMedal_panel.ShowMedal_C()
	local self = FriendshipMedal_panel;
	if(self.sendNum >= self.b_level_num and self.sendNum < self.c_level_num and not self.HasMedal_C() )then
		return true;
	end
end
function FriendshipMedal_panel.ShowMedal_D()
	local self = FriendshipMedal_panel;
	if(self.sendNum >= self.c_level_num and self.sendNum < self.d_level_num and not self.HasMedal_D() )then
		return true;
	end
end
function FriendshipMedal_panel.GetMedal_A()
	local self = FriendshipMedal_panel;
	self.GetMedal("A");
end
function FriendshipMedal_panel.GetMedal_B()
	local self = FriendshipMedal_panel;
	self.GetMedal("B");
end
function FriendshipMedal_panel.GetMedal_C()
	local self = FriendshipMedal_panel;
	self.GetMedal("C");
end
function FriendshipMedal_panel.GetMedal_D()
	local self = FriendshipMedal_panel;
	self.GetMedal("D");
end
--兑换徽章
function FriendshipMedal_panel.GetMedal(type)
	local self = FriendshipMedal_panel;
	if(type == "A")then
		if(self.ShowMedal_A())then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px">你还没有赠送10份礼物呢，继续加油吧！</div>]]);
			return;
		end
	elseif(type == "B")then
		if(self.ShowMedal_B())then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px">你还没有赠送50份礼物呢，继续加油吧！</div>]]);
			return;
		end
	elseif(type == "C")then
		if(self.ShowMedal_C())then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px">你还没有赠送200份礼物呢，继续加油吧！</div>]]);
			return;
		end
	elseif(type == "D")then
		if(self.ShowMedal_D())then
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px">你还没有赠送800份礼物呢，继续加油吧！</div>]]);
			return;
		end
	end
	
	local msg = {
		nid = Map3DSystem.User.nid,
	}
	commonlib.echo("=====FriendshipMedal_panel before TakeHortation:");
	commonlib.echo(msg);
	paraworld.homeland.giftbox.TakeHortation(msg,"TakeHortation",function(msg)	
		commonlib.echo("=====FriendshipMedal_panel after TakeHortation:");
		commonlib.echo(msg);
		if(msg and msg.issuccess)then
				--重新加载礼物盒信息
				self.GetGiftInfo(function(args)
					if(args and args.issuccess)then
						local title = "";
						if(type == "A")then
							title = "木";
						elseif(type == "B")then
							title = "铜";
						elseif(type == "C")then
							title = "银";
						elseif(type == "D")then
							title = "金";
						end
						local s = string.format([[<div style="margin-left:20px;margin-top:5px">恭喜你获得%s徽章，你可以在资料面板中看到它哦！<br />你的礼物盒也增加到了%d个，可以收到更多礼物了！</div>]],title,self.boxNum);
						self.RefreshPage();--刷新页面
						_guihelper.MessageBox(s);
					end
				
				end)
		else
			--_guihelper.MessageBox("获取友情徽章失败！");
		end
	end);
end
--获取礼物盒信息
function FriendshipMedal_panel.GetGiftInfo(callbackFunc)
	local self = FriendshipMedal_panel;
	local msg = {
		nid = Map3DSystem.User.nid,
	}
	commonlib.echo("=====FriendshipMedal_panel before get gift info");
	commonlib.echo(msg);
	paraworld.homeland.giftbox.Get(msg,"Giftinfo",function(msg)	
		commonlib.echo("=====FriendshipMedal_panel after get gift info");
		commonlib.echo(msg);
		if(msg)then
			self.sendNum = msg.sendcnt or 0;--送礼物数量
			self.boxNum = msg.boxcnt or 0;--礼物盒数量
			--刷新bag
			Map3DSystem.Item.ItemManager.GetItemsInBag(10062, "MedalBag", function(msg)
				if(callbackFunc and type(callbackFunc) == "function")then
					callbackFunc({
						issuccess = true,
					});
				end
			end, "access plus 0 day");
		else
			if(callbackFunc and type(callbackFunc) == "function")then
					callbackFunc({
						issuccess = false,
					});
			end
		end
	end);
end