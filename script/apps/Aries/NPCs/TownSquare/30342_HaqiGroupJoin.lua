--[[
Title: HaqiGroupJoin
Author(s): Leio
Date: 2010/01/09

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30342_HaqiGroupJoin.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupManage.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.family.lua");

-- create class
local libName = "HaqiGroupJoin";
local HaqiGroupJoin = {
	page_state = 0, -- 0: 最新列表 1: 查找结果 2：热门家族
	newest_grouplist = nil,--最新列表
	find_grouplist = nil,--查找结果
	hot_grouplist = nil,--热门家族
	page = nil,
	selected_item = nil,--选中的item
	selected_index = nil,--选中的索引
	
	file = "temp/cache/HaqiGroupJoin",--本地记录 每天申请的次数
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.HaqiGroupJoin", HaqiGroupJoin);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");

function HaqiGroupJoin.OnInit()
	local self = HaqiGroupJoin;
	self.page = document:GetPageCtrl();
end
function HaqiGroupJoin.Reset()
	local self = HaqiGroupJoin;
	self.page_state = 0;
	self.newest_grouplist = nil;
	self.find_grouplist = nil;
	self.selected_item = nil;
	self.selected_index = nil;--选中的索引
end
-- HaqiGroupJoin.main
function HaqiGroupJoin.main()
	local self = HaqiGroupJoin;
	self.Reset();
end

-- Only return family list of my region
function HaqiGroupJoin.GetMyRegionList(list)
	local self = HaqiGroupJoin;
	local tmplist = {};
	for _,familyitem in pairs(list) do
		local admin_nid = familyitem.admin;
		if(ExternalUserModule:CanViewUser(admin_nid))then
			table.insert(tmplist,familyitem);
		end
	end
	return tmplist;
end

-- HaqiGroupJoin.PreDialog
function HaqiGroupJoin.PreDialog()
	local self = HaqiGroupJoin;
	self.GetNewestGroupList(function()
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/TownSquare/30342_HaqiGroupJoin_panel.html", 
			name = "HaqiGroupJoin.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -434/2,
				y = -475/2,
				width = 434,
				height = 475,
		});
		self.DoSelected(1);
	end)
	
	return false;
end
--获取热门家族
function HaqiGroupJoin.GetHotGroupList(callbackFunc)
	local self = HaqiGroupJoin;
    local msg = {};
    commonlib.echo("===========before get hot group list in HaqiGroupJoin.GetHotGroupList");
    commonlib.echo(msg);
	paraworld.Family.GetHot(msg,"",function(msg)
		 commonlib.echo("===========after get hot group list in HaqiGroupJoin.GetHotGroupList");
		 commonlib.echo(msg);
		if(msg and msg.list)then
			--self.hot_grouplist = msg.list;
			self.hot_grouplist = self.GetMyRegionList(msg.list);
			
			if(callbackFunc)then
				callbackFunc();
			end
		end
	end);
	
end
--获取最新的家族列表
function HaqiGroupJoin.GetNewestGroupList(callbackFunc)
	local self = HaqiGroupJoin;
	--[[
	[host]/API/Family/GetNewest         
		/// <summary>
        /// 取得最新成立的100个家族
        /// 接收参数：
        ///     无
        /// 返回值：
        ///     list [list]
        ///         id  家族ID
        ///         name  家族名称
        ///         membercnt  家族成员数
        ///         maxcontain  当前该家族可容纳的最大成员数
        /// </summary>
    --]]
    local msg = {};
    commonlib.echo("===========before get newest group list in HaqiGroupJoin.GetNewestGroupList");
    commonlib.echo(msg);
	paraworld.Family.GetNewest(msg,"",function(msg)
		 commonlib.echo("===========after get newest group list in HaqiGroupJoin.GetNewestGroupList");
		 commonlib.echo(msg);
		if(msg and msg.list)then
			--self.newest_grouplist = msg.list;
			self.newest_grouplist = self.GetMyRegionList(msg.list);

			if(callbackFunc)then
				callbackFunc();
			end
		end
	end);
	
end
--查找家族
function HaqiGroupJoin.GetGroup(id,callbackFunc)
	local self = HaqiGroupJoin;
	--[[
	/// <summary>
        /// 取得指定的家族的详细信息
        /// 接收参数：
        ///     idorname  家族ID或家族名称
        /// 返回值：
        ///     id  家族ID
        ///     name  家族名称
        ///     desc  家族宣言
        ///     level  家族级别
        ///     admin  家族家族的NID
        ///     deputy  String，家族所有的副族长的NID，多个NID之间用英文逗号分隔
        ///     members  String，家族所有成员的NID，多个NID之间用英文逗号分隔
        ///     maxcontain  最大可拥有的家族成员数
        ///     createdate  创建时间 yyyy-MM-dd HH:mm:ss
        ///     [ errorcode ]  (提供的参数不符合要求  数据不存在或已被删除<家族不存在>  未知的错误)
        /// </summary>
    --]]
	local msg = {
		idorname = id,
	}
	
	commonlib.echo("===========before get a group in HaqiGroupJoin.GetGroup");
	commonlib.echo(msg);
	paraworld.Family.Get(msg,"group",function(msg)
		commonlib.echo("===========after get a group in HaqiGroupJoin.GetGroup");
		commonlib.echo(msg);
		if(msg and not msg.errorcode)then
			if (ExternalUserModule:CanViewUser(msg.admin)) then  --  如果找到的家族是当前分区家族返回 true, else 返回 false
				--转换members to membercnt		
				self.SetMembercnt(msg);
				self.find_grouplist = {msg};
				if(callbackFunc)then
					callbackFunc({
						issuccess = true
					}
					);
				end
			else
				if(callbackFunc)then
					callbackFunc({
						issuccess = false
					}
					);
				end
			end
		else
			if(callbackFunc)then
				callbackFunc({
					issuccess = false
				}
				);
			end
		end
	end)
end
function HaqiGroupJoin.DoNewestGroup()
	local self = HaqiGroupJoin;
	if(not self.newest_grouplist)then
		self.GetNewestGroupList(function()
			self.page_state = 0;
			self.DoSelected(1);
		end)
	else
		self.page_state = 0;
		self.DoSelected(1);
	end
end
--热门家族
function HaqiGroupJoin.DoHotGroup()
	local self = HaqiGroupJoin;
	if(not self.hot_grouplist)then
		self.GetHotGroupList(function()
			self.page_state = 2;
			self.DoSelected(1);
		end)
	else
		self.page_state = 2;
		self.DoSelected(1);
	end
end
function HaqiGroupJoin.ShowFastChannelPage()
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/TownSquare/30342_HaqiGroupJoin_find.html", 
			name = "HaqiGroupJoin.ShowFastChannelPage", 
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
function HaqiGroupJoin.DoFind(id)
	local self = HaqiGroupJoin;
	if(not id or id == "")then return end
	--close page
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="HaqiGroupJoin.ShowFastChannelPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
			
	self.GetGroup(id,function(msg)
		if(msg and msg.issuccess)then
			self.page_state = 1;
			self.DoSelected(1);
		else
			local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>这个家族不存在，请重新输入。</div>";
			_guihelper.Custom_MessageBox(s,function(result)
				
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		end
	end);
end
--选中一条记录
function HaqiGroupJoin.DoSelected(index)
	local self = HaqiGroupJoin;
	if(self.page_state == 0)then
		if(self.newest_grouplist)then
			self.selected_item = self.newest_grouplist[index];
		end
	elseif(self.page_state == 1)then
		if(self.find_grouplist)then
			self.selected_item = self.find_grouplist[index];
		end
	elseif(self.page_state == 2)then
		if(self.hot_grouplist)then
			self.selected_item = self.hot_grouplist[index];
		end
	end
	self.selected_index = index;
	if(self.selected_item)then
		--显示家族宣言 
		local content = self.selected_item.desc;
		if(self.page)then
			self.page:SetValue("content_info",content or "");
			self.page:Refresh(0.01);
		end
	end
end
--申请加入
function HaqiGroupJoin.DoJoin()
	local self = HaqiGroupJoin;
	if(not self.selected_item)then
		local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>请选择一个家族。</div>";
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return;
	end
	--当天申请加入次数
	local name,id = self.selected_item.name,self.selected_item.id;
	local n = self.LoadRequestToday(id);
	if(n >= 10)then
		local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>每天同一家族只能申请10次，请改天再来申请加入家族。</div>";
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return;
	end
	--人数已经满
	local is_full = self.IsFull();
	if(is_full)then
		local name,id = self.selected_item.name,self.selected_item.id;
		local s = string.format([[<div style='margin-left:15px;margin-top:20px;text-align:center'>%s(%s)人数已满，无法加入。你可以选择其他家族加入。</div>]],name,MyCompany.Aries.Quest.NPCs.HaqiGroupManage.FormatID(id));
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return;
	end
	
	local join_requirement = self.selected_item.join_requirement;
	if(join_requirement)then
		local combat_level = join_requirement[1] or 0;
		local magic_star_level = join_requirement[2] or 0;
		local bean = MyCompany.Aries.Pet.GetBean();
		if(bean) then
			if(bean.combatlel and bean.combatlel < combat_level)then
				local s = string.format("这个家族要求你的战斗等级为%d级,才能申请加入！",combat_level);
				_guihelper.MessageBox(s);
				return;
			end
			if (bean.mlel and bean.mlel < magic_star_level) then
				local s = string.format("这个家族要求你的魔法星等级为%d级,才能申请加入！",magic_star_level);
				_guihelper.MessageBox(s);
				return;
			end
		end    
	end
	HaqiGroupJoin.DoRequest()
	
	
end
function HaqiGroupJoin.DoJoinGroup(id)
	local self = HaqiGroupJoin;
	if(not id)then return end
	commonlib.echo("======id");
	commonlib.echo(id);
	self.GetGroup(id,function(msg)
		if(msg and msg.issuccess)then
			local list = self.find_grouplist;
			if(list and list[1])then
				self.selected_item = list[1];
				self.DoJoin();
			end
		
		end
	end);
end
function HaqiGroupJoin.DoRequest()
	local self = HaqiGroupJoin;
	--[[
	/// <summary>
        /// 取得指定的家族的详细信息
        /// 接收参数：
        ///     idorname  家族ID或家族名称
        /// 返回值：
        ///     id  家族ID
        ///     name  家族名称
        ///     desc  家族宣言
        ///     level  家族级别
        ///     admin  家族家族的NID
        ///     deputy  String，家族所有的副族长的NID，多个NID之间用英文逗号分隔
        ///     members  String，家族所有成员的NID，多个NID之间用英文逗号分隔
        ///     maxcontain  最大可拥有的家族成员数
        ///     createdate  创建时间 yyyy-MM-dd HH:mm:ss
        ///     [ errorcode ]  (提供的参数不符合要求  数据不存在或已被删除<家族不存在>  未知的错误)
        /// </summary>
    --]]
	if(self.selected_item)then
		commonlib.echo("=====selected_item");
		commonlib.echo(self.selected_item);
		local nid_list = {};
		local admin = self.selected_item.admin;
		if(admin)then
			table.insert(nid_list,admin);
		end
		local deputy = self.selected_item.deputy;
		if(deputy)then
			local exist;
			for exist in string.gfind(deputy, "([^,]+)") do
				exist = tonumber(exist);
				table.insert(nid_list,exist);
			end
		end
		MyCompany.Aries.Quest.NPCs.HaqiGroupClient.GetUserInfo(nil,function(msg)
			local is_joined = false;
			if(msg.family and msg.family ~= "")then
				--已经加入家族
				is_joined = true; 
			end
			if(is_joined)then
				local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你已经加入其他家族，不能重复加入家族。如果想加入新的家族，请先退出原有家族。</div>";
				_guihelper.Custom_MessageBox(s,function(result)
					
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
				return;
			end
			
			local args = {
				type = "request_accept",
				nid = msg.nid,
				jid = msg.jid,
				nickname = msg.nickname,
				group_id = self.selected_item.id,
				group_name = self.selected_item.name,
			}
			
			local msg = {
				familyid = self.selected_item.id;
			}

			local n = self.LoadRequestToday(self.selected_item.id);
			self.SaveRequestToday(self.selected_item.id,n + 1);
			commonlib.echo("==========before request in HaqiGroupJoin.DoRequest()");
			commonlib.echo(msg);
			paraworld.Family.Request(msg,"group",function(msg)
				commonlib.echo("==========after request in HaqiGroupJoin.DoRequest()");
				commonlib.echo(msg);
				
				if(msg and msg.issuccess)then
					commonlib.echo("=========request_accept in HaqiGroupJoin.DoRequest()");
					commonlib.echo(args);
					commonlib.echo(nid_list);
					local is_message_received;
					local k,dest_nid;
					local is_ignore_ratecontrol;
					for k,dest_nid in ipairs(nid_list) do
						Map3DSystem.App.profiles.ProfileManager.GetJID(dest_nid, function(jid)
							if(jid)then
								local bIsSucceed = MyCompany.Aries.Quest.NPCs.HaqiGroupClient.SendMessage(args,jid, function(msg)
									if(msg) then
										if(not is_message_received) then
											local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>已经向家族管理者发出申请，请耐心等待对方答复。</div>";
											_guihelper.Custom_MessageBox(s,function(result)
											end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
											is_message_received = true;
										end
									elseif(is_message_received==nil) then
										is_message_received = false;
										_guihelper.MessageBox("家族管理员不在线， 请换个时间再申请吧");
									end
								end, nil, is_ignore_ratecontrol);
								if(not bIsSucceed) then
									_guihelper.MessageBox("你发送请求的频率太高了,请稍候再试");
									return;
								else
									is_ignore_ratecontrol = true;
								end
							end
						end)
					end
				end
			end);
			
		end)
		
	end
end
--保存今天申请加入家族的次数
function HaqiGroupJoin.SaveRequestToday(id_or_name,n)
	local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local nid = Map3DSystem.User.nid;
	nid = tostring(nid);
	local key = string.format("HaqiGroupJoin.SaveRequestToday%s_%s_%s",today,tostring(id_or_name),nid);
	MyCompany.Aries.Player.SaveLocalData(key,n);
end
--加载今天申请加入家族的次数
function HaqiGroupJoin.LoadRequestToday(id_or_name)
	local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local nid = Map3DSystem.User.nid;
	nid = tostring(nid);
	local key = string.format("HaqiGroupJoin.SaveRequestToday%s_%s_%s",today,tostring(id_or_name),nid);
	return MyCompany.Aries.Player.LoadLocalData(key,0);
end
--是否满员
function HaqiGroupJoin.IsFull()
	local self = HaqiGroupJoin;
	--如果是从paraworld.Family.Get过来的数据
	if(self.selected_item and self.selected_item.members)then
		local members = self.selected_item.members;
		local maxcontain = self.selected_item.maxcontain;
		-- NOTE: change of return format of msg.members 
		-- OLD: 
		--///     members  String，家族所有成员的NID，多个NID之间用英文逗号分隔
		-- NEW: 
		--///     members[list]  家族所有成员
		--///         nid  NID
		--///         contribute  对家族的贡献度
		--///         last  最后签到的时间，yyyy-MM-dd
		local len = 0;
		---------------- old implementation ----------------
		--if(members)then
			--local exist;
			--for exist in string.gfind(members, "([^,]+)") do
				--len = len + 1;
			--end
		--end
		----------------------------------------------------
		len = #(members);
		if(len >= maxcontain)then
			return true;
		end
	end
	--paraworld.Family.GetNewest
	if(self.selected_item and self.selected_item.membercnt)then
		local membercnt = self.selected_item.membercnt;
		local maxcontain = self.selected_item.maxcontain;
		if(membercnt >= maxcontain)then
			return true;
		end
	end
end
function HaqiGroupJoin.SetMembercnt(item)
	local self = HaqiGroupJoin;
	if(not item)then return end
	if(item.members)then
		-- NOTE: change of return format of msg.members 
		-- OLD: 
		--///     members  String，家族所有成员的NID，多个NID之间用英文逗号分隔
		-- NEW: 
		--///     members[list]  家族所有成员
		--///         nid  NID
		--///         contribute  对家族的贡献度
		--///         last  最后签到的时间，yyyy-MM-dd
		---------------- old implementation ----------------
		--local len = 0;
		--local exist;
		--for exist in string.gfind(item.members, "([^,]+)") do
			--len = len + 1;
		--end
		--item.membercnt = len;
		----------------------------------------------------
		item.membercnt = #(item.members);
	end
end