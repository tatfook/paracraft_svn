--[[
Title: 
Author(s): Leio
Date: 2011/07/06
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Family/FamilyHelper.lua");
local FamilyHelper = commonlib.gettable("Map3DSystem.App.Family.FamilyHelper");
local id_or_name = "aaaaa1";
FamilyHelper.DoRequest(id_or_name);
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
NPL.load("(gl)script/apps/Aries/Family/FamilyMsg.lua");
local FamilyMsg = commonlib.gettable("Map3DSystem.App.Family.FamilyMsg");
NPL.load("(gl)script/apps/Aries/Family/FamilyManager.lua");
local FamilyManager = commonlib.gettable("Map3DSystem.App.Family.FamilyManager");
local FamilyHelper = commonlib.gettable("Map3DSystem.App.Family.FamilyHelper");
--查找家族
function FamilyHelper.Search(id_or_name,callbackFunc)
	if(not id_or_name)then
		if(callbackFunc)then
			callbackFunc();
		end
		return;
	end
	local msg = {
		idorname = id_or_name,
		cache_policy = "access plus 0 day",
	}
	LOG.std(nil, "info","before FamilyHelper.Search",msg);
	paraworld.Family.Get(msg,"group",function(msg)
		LOG.std(nil, "info","after FamilyHelper.Search",msg);
		if(msg and not msg.errorcode)then
			local family_info = msg;--家族信息
			if(callbackFunc)then
				callbackFunc({
					family_info = family_info,
				});
			end
		else
			if(callbackFunc)then
				callbackFunc();
			end
		end
	end)
end
--查找热门家族
function FamilyHelper.SearchHotFamily(callbackFunc)
	local msg = {};
	LOG.std(nil, "info","before FamilyHelper.SearchHotFamily",msg);
	paraworld.Family.GetHot(msg,"",function(msg)
	LOG.std(nil, "info","after FamilyHelper.SearchHotFamily",msg);
		if(msg and msg.list)then
			local list = FamilyHelper.GetMyRegionList(msg.list);
			if(callbackFunc)then
				callbackFunc({
					list = list,
				});
			end
		else
			if(callbackFunc)then
				callbackFunc();
			end
		end
	end);
end
--查找最新家族
function FamilyHelper.SearchNewestFamily(callbackFunc)
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
	LOG.std(nil, "info","before FamilyHelper.SearchNewestFamily",msg);
	paraworld.Family.GetNewest(msg,"",function(msg)
	LOG.std(nil, "info","after FamilyHelper.SearchNewestFamily",msg);
		if(msg and msg.list)then
			local list = FamilyHelper.GetMyRegionList(msg.list);
			if(callbackFunc)then
				callbackFunc({
					list = list,
				});
			end
		else
			if(callbackFunc)then
				callbackFunc();
			end
		end
	end);
end
--申请加入家族
function FamilyHelper.DoRequest(id_or_name)
	id_or_name = tostring(id_or_name);
	if(not id_or_name)then
		return;
	end
	if(FamilyHelper.LoadRequestToday(id_or_name) >= 10 )then
		_guihelper.MessageBox("每天同一家族只能申请10次，请改天再来申请加入家族。");
		return
	end
	System.App.profiles.ProfileManager.GetUserInfo(nil, nil, function(msg)
		if(msg and msg.users and msg.users[1]) then
			local user = msg.users[1];
			local family = user.family;
			if(family and family ~= "")then
				--已经加入家族
				_guihelper.MessageBox("你已经加入其他家族，不能重复加入家族。如果想加入新的家族，请先退出原有家族。");
				return
			end
		end
		FamilyHelper.Search(id_or_name,function(msg)
			if(msg and msg.family_info)then
				local family_info = msg.family_info;
				local familyid = family_info.id;
				local admin = family_info.admin;
				local deputy = family_info.deputy;
				local familyname = family_info.name;
				local msg = {
					familyid = familyid;
				}
				local n = FamilyHelper.LoadRequestToday(id_or_name);
				FamilyHelper.SaveRequestToday(id_or_name,n + 1);
				paraworld.Family.Request(msg,"group",function(msg)
					if(msg and msg.issuccess)then
						local id;
						local is_message_received;
						for id in string.gfind(deputy, "([^,]+)") do
							id = tonumber(id);
							FamilyMsg.SendMessage(id,{
								msg_type = "request_accept",
								from_nid = Map3DSystem.User.nid,
								to_nid = id,
								familyid = familyid,
								familyname = familyname,
							});
						end
						FamilyMsg.SendMessage(admin,{
								msg_type = "request_accept",
								from_nid = Map3DSystem.User.nid,
								to_nid = admin,
								familyid = familyid,
								familyname = familyname,
							})
						_guihelper.MessageBox("已经向家族管理者发出申请，请耐心等待对方答复。");
					end
				end);
			else
				_guihelper.MessageBox("家族不存在！");
			end
		end)
	end)
end
--保存今天申请加入家族的次数
function FamilyHelper.SaveRequestToday(id_or_name,n)
	local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local nid = Map3DSystem.User.nid;
	nid = tostring(nid);
	local key = string.format("FamilyHelper.SaveRequestToday%s_%s_%s",today,tostring(id_or_name),nid);
	MyCompany.Aries.Player.SaveLocalData(key,n);
end
--加载今天申请加入家族的次数
function FamilyHelper.LoadRequestToday(id_or_name)
	local today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local nid = Map3DSystem.User.nid;
	nid = tostring(nid);
	local key = string.format("FamilyHelper.SaveRequestToday%s_%s_%s",today,tostring(id_or_name),nid);
	return MyCompany.Aries.Player.LoadLocalData(key,0);
end
-- Only return family list of my region
function FamilyHelper.GetMyRegionList(list)
	local tmplist = {};
	for _,familyitem in pairs(list) do
		local admin_nid = familyitem.admin;
		if(ExternalUserModule:CanViewUser(admin_nid))then
			table.insert(tmplist,familyitem);
		end
	end
	return tmplist;
end