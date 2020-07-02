--[[
Title: HaqiGroupClient
Author(s): Leio
Date: 2010/01/12

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupClient.lua");

"request_accept" 申请加入
"accept_request" 请求处理成功

"fired" 踢出家族

"invite" 邀请加入

"hand_headman" 转让族长
"appoint_assistant" 任命副族长
"fire_assistant" 撤销副族长
--发送申请
local msg = {
	type = "request_accept",
	nid = nid,
	jid = jid,
	nickname = nickname,
	group_id = group_id,
	group_name = group_name,
}
local dest_jid;
MyCompany.Aries.Quest.NPCs.HaqiGroupClient.SendMessage(msg,dest_jid);

--发送邀请

------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.family.lua");
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupManage.lua");
local HaqiGroupClient = {
	DefaultFile = "script/apps/Aries/NPCs/TownSquare/30341_HaqiGroupClient.lua",
	isInit = false,
}
commonlib.setfield("MyCompany.Aries.Quest.NPCs.HaqiGroupClient",HaqiGroupClient);

NPL.load("(gl)script/ide/Encoding.lua");
local Encoding = commonlib.gettable("commonlib.Encoding");

function HaqiGroupClient.Init()
	local self = HaqiGroupClient;
	if(not self.jc)then
		self.isInit = true;
		self.jc = JabberClientManager.CreateJabberClient(Map3DSystem.User.jid);
	end
end
function HaqiGroupClient.GetJC()
	local self = HaqiGroupClient;
	return self.jc;
end
function HaqiGroupClient.GetJID()
	return Map3DSystem.User.jid;
end

local seq = 0;
local msg_queue = {};

local function GetNextID()
	seq = seq + 1;
	return seq;
end

-- refactored by LiXizhi to add callback
-- send a message with callback
-- @param nid: target nid
-- @param msg: the message to sent
-- @param callbackFunc: nil of a callback function(msg_out) end, if msg_out is nil, it means timed out
-- @param timeout: in millisecond when callbackFunc() will be called.  default to 5000
-- @param bIgnoreRateController: 
-- @return true if succeed
function HaqiGroupClient.SendMessage(msg,jid, callbackFunc, timeout, bIgnoreRateController)
	local self = HaqiGroupClient;
	commonlib.echo("==============HaqiGroupClient.SendMessage");
	commonlib.echo({msg,jid});
	if(msg and self.jc and jid)then

		if(callbackFunc and msg) then
			local seq = GetNextID();
			local callback = {
				callbackFunc=callbackFunc, 
				timer = commonlib.Timer:new({callbackFunc = function(timer)
					LOG.std(nil, "info","HaqiGroupClient.SendMessage",msg);
					callbackFunc();
				end}),
			};
			msg_queue[seq] = callback;
			msg.seq = seq;
			callback.timer:Change(timeout or 5000, nil);
		end

		local bSuc = self.jc:activate(jid..":"..self.DefaultFile, msg, bIgnoreRateController);
		commonlib.echo("==============bSuc")
		commonlib.echo(bSuc)
		return bSuc;
	end
end

function HaqiGroupClient.HandleMessage(msg)

	local self = HaqiGroupClient;
	commonlib.echo("==============HaqiGroupClient.HandleMessage");
	commonlib.echo(msg);
	if(not msg)then return end
	if(msg.type == "got_quit_info")then
		--族长 副族长收到 队员退出家族的消息
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("story", {
			type = msg.type,
			nid = msg.nid,
			jid = msg.jid,
			nickname = msg.nickname,
			
			group_id = msg.group_id,
			group_name = msg.group_name,
			
			sender_nid = msg.sender_nid,
			sender_jid = msg.sender_jid,
			sender_nickname = msg.sender_nickname,
			
			ShowCallbackFunc = function(msg) HaqiGroupClient.Quit_Handle(msg) end,
		});
	elseif(msg.type == "request_accept")then
		if(MyCompany.Aries.Quest.NPCs.HaqiGroupManage.IsBlackMember(msg.nid))then
			return
		end
		--请求加入家族
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("story", {
			type = msg.type,
			nid = msg.nid,
			jid = msg.jid,
			nickname = msg.nickname,
			
			group_id = msg.group_id,
			group_name = msg.group_name,
			
			sender_nid = msg.sender_nid,
			sender_jid = msg.sender_jid,
			sender_nickname = msg.sender_nickname,
			
			ShowCallbackFunc = function(msg) HaqiGroupClient.Request_Accept(msg) end,
		});
	elseif(msg.type == "accept_request")then
		--加入家族成功
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("story", {
			type = msg.type,
			nid = msg.nid,
			jid = msg.jid,
			nickname = msg.nickname,
			
			group_id = msg.group_id,
			group_name = msg.group_name,
			
			sender_nid = msg.sender_nid,
			sender_jid = msg.sender_jid,
			sender_nickname = msg.sender_nickname,
			
			ShowCallbackFunc = function(msg) HaqiGroupClient.Accept_Request(msg) end,
		});
	elseif(msg.type == "refuse_request")then
		--加入家族失败
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("story", {
			type = msg.type,
			nid = msg.nid,
			jid = msg.jid,
			nickname = msg.nickname,
			
			group_id = msg.group_id,
			group_name = msg.group_name,
			
			sender_nid = msg.sender_nid,
			sender_jid = msg.sender_jid,
			sender_nickname = msg.sender_nickname,
			
			ShowCallbackFunc = function(msg) HaqiGroupClient.Refuse_Request(msg) end,
		});
	elseif(msg.type == "fired")then
		NPL.load("(gl)script/apps/Aries/Chat/FamilyChatWnd.lua");
		MyCompany.Aries.Chat.FamilyChatWnd.Show(false);
		local jc = MyCompany.Aries.Chat.FamilyChatWnd.GetJC();
		if(jc) then
			jc:LeaveRoom()
		end
		--被踢出家族
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("story", {
			type = msg.type,
			nid = msg.nid,
			jid = msg.jid,
			nickname = msg.nickname,
			
			group_id = msg.group_id,
			group_name = msg.group_name,
			
			sender_nid = msg.sender_nid,
			sender_jid = msg.sender_jid,
			sender_nickname = msg.sender_nickname,
			
			ShowCallbackFunc = function(msg) HaqiGroupClient.Fired(msg) end,
		});
	elseif(msg.type == "invite")then
		--邀请加入
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("story", {
			type = msg.type,
			nid = msg.nid,
			jid = msg.jid,
			nickname = msg.nickname,
			
			group_id = msg.group_id,
			group_name = msg.group_name,
			
			sender_nid = msg.sender_nid,
			sender_jid = msg.sender_jid,
			sender_nickname = msg.sender_nickname,
			
			ShowCallbackFunc = function(msg) HaqiGroupClient.Invite(msg) end,
		});
	elseif(msg.type == "invite_accept")then
		--邀请被接受
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("story", {
			type = msg.type,
			nid = msg.nid,
			jid = msg.jid,
			nickname = msg.nickname,
			
			group_id = msg.group_id,
			group_name = msg.group_name,
			
			sender_nid = msg.sender_nid,
			sender_jid = msg.sender_jid,
			sender_nickname = msg.sender_nickname,
			
			ShowCallbackFunc = function(msg) HaqiGroupClient.Accept_Request_Invite(msg) end,
		});
	elseif(msg.type == "hand_headman")then
		--转让族长
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("story", {
			type = msg.type,
			nid = msg.nid,
			jid = msg.jid,
			nickname = msg.nickname,
			
			group_id = msg.group_id,
			group_name = msg.group_name,
			
			sender_nid = msg.sender_nid,
			sender_jid = msg.sender_jid,
			sender_nickname = msg.sender_nickname,
			
			ShowCallbackFunc = function(msg) HaqiGroupClient.Hand_Headman(msg) end,
		});
	elseif(msg.type == "appoint_assistant")then
		--任命副族长
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("story", {
			type = msg.type,
			nid = msg.nid,
			jid = msg.jid,
			nickname = msg.nickname,
			
			group_id = msg.group_id,
			group_name = msg.group_name,
			
			sender_nid = msg.sender_nid,
			sender_jid = msg.sender_jid,
			sender_nickname = msg.sender_nickname,
			
			ShowCallbackFunc = function(msg) HaqiGroupClient.Appoint_Assistant(msg) end,
		});
	elseif(msg.type == "fire_assistant")then
		--撤销副族长
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("story", {
			type = msg.type,
			nid = msg.nid,
			jid = msg.jid,
			nickname = msg.nickname,
			
			group_id = msg.group_id,
			group_name = msg.group_name,
			
			sender_nid = msg.sender_nid,
			sender_jid = msg.sender_jid,
			sender_nickname = msg.sender_nickname,
			
			ShowCallbackFunc = function(msg) HaqiGroupClient.Fire_Assistant(msg) end,
		});
	end
end
--转让族长
function HaqiGroupClient.Hand_Headman(msg_client)
	local link_str = HaqiGroupClient.GetLinkStr(msg_client.nickname or "",msg_client.nid or 0);
	local s = string.format("<div style='margin-left:15px;margin-top:10px;'>太棒了！你已经被%s<br/>任命为[%s]的族长了！要多多关心家族成员哦！</div>",link_str,msg_client.group_name or "");
	_guihelper.Custom_MessageBox(s,function(result)
		MyCompany.Aries.Quest.NPCs.HaqiGroupManage.ShowPage(true);		
	end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/NPCs/HaqiGroup/group_view_btn_32bits.png; 0 0 153 49"}, nil, true); -- true for isNotTopLevel
end
function HaqiGroupClient.ShowFullProfile(nid)
	if(not nid)then return end
	System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
end
--申请加入家族
function HaqiGroupClient.GetLinkStr_2(nickname,nid)
	if(not nickname or not nid)then return "" end
	nickname = Encoding.EncodeStr(nickname)
	nid = tostring(nid);
	local s_name = string.format([[<a onclick="MyCompany.Aries.Quest.NPCs.HaqiGroupManage.ShowFullProfile" param1='%s'><pe:name nid='%s' linked=false/>(%s)</a>]],nid,nid,nid);
    local s_magic = string.format([[<div style="float:left;">魔法星:<aries:mountpet-status2 name="mlel" nid='%s' type="mlel" showzero="true" style="width:20px;"/>级</div>]],nid);
    local s_combat_level = string.format([[<div style="float:left;">战斗等级:<aries:mountpet-status2 name="combat_level" nid='%s' type="combatlel" hideifnotvip="true" style="width:20px;"/>级</div>]],nid);
	local s = string.format([[%s<br/>%s,%s<br/>]],s_name,s_magic,s_combat_level);
	return s;
end
function HaqiGroupClient.GetLinkStr(nickname,nid)
	if(not nickname or not nid)then return "" end
	nickname = Encoding.EncodeStr(nickname)
	local s = string.format([[<a onclick="MyCompany.Aries.Quest.NPCs.HaqiGroupClient.ShowFullProfile" param1='%s'>%s(%s)</a>]],tostring(nid),nickname,tostring(nid));
	return s;
end
--任命副族长
function HaqiGroupClient.Appoint_Assistant(msg_client)
	local link_str = HaqiGroupClient.GetLinkStr(msg_client.nickname or "",msg_client.nid or 0);
	local s = string.format("<div style='margin-left:15px;margin-top:10px;'>太棒了！你已经被%s<br/>任命为[%s]的副族长了！</div>",link_str,msg_client.group_name or "");
	_guihelper.Custom_MessageBox(s,function(result)
		MyCompany.Aries.Quest.NPCs.HaqiGroupManage.ShowPage(true);		
	end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/NPCs/HaqiGroup/group_view_btn_32bits.png; 0 0 153 49"}, nil, true); -- true for isNotTopLevel
end
--撤销副族长
function HaqiGroupClient.Fire_Assistant(msg_client)
	local s = string.format("<div style='margin-left:15px;margin-top:10px;text-align:center'>真遗憾，你不再是[%s]的副族长了！</div>",msg_client.group_name or "");
	_guihelper.Custom_MessageBox(s,function(result)
		MyCompany.Aries.Quest.NPCs.HaqiGroupManage.ShowPage(true);
	end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/NPCs/HaqiGroup/group_view_btn_32bits.png; 0 0 153 49"}, nil, true); -- true for isNotTopLevel
end
--族长 副族长收到队员退出家族的消息
function HaqiGroupClient.Quit_Handle(msg_client)
	local link_str = HaqiGroupClient.GetLinkStr_2(msg_client.nickname or "",msg_client.nid or 0);
	local s = string.format("<div style='margin-left:15px;margin-top:10px;'>%s已经退出你的家族。</div>",link_str);
	_guihelper.MessageBox(s);
end
--请求加入家族
function HaqiGroupClient.Request_Accept(msg_client)
	local link_str = HaqiGroupClient.GetLinkStr_2(msg_client.nickname or "",msg_client.nid or 0);
	local s = string.format("<div style='margin-left:15px;margin-top:10px;'>%s申请加入你的家族。你同意他的申请吗？</div>",link_str);
	_guihelper.MessageBox(s,function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				local msg = {
					familyid = msg_client.group_id,
					requestnid = msg_client.nid,
				}
				commonlib.echo("========before accept request in HaqiGroupClient.Request_Accept");
				commonlib.echo(msg);
				paraworld.Family.AcceptRequest(msg,"group",function(msg)
					commonlib.echo("========after accept request in HaqiGroupClient.Request_Accept");
					commonlib.echo(msg);
					if(msg and msg.issuccess)then
					
						local link_str = HaqiGroupClient.GetLinkStr_2(msg_client.nickname or "",msg_client.nid or 0);
						local s = string.format([[<div style='margin-left:15px;margin-top:10px;'>%s已经加入你的家族了。</div>]],link_str);
						_guihelper.Custom_MessageBox(s,function(result)
								
						end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"}, nil, true); -- true for isNotTopLevel
	
						--成功加入家族 回执申请者
						HaqiGroupClient.SendMessage({
							type = "accept_request",
							nid = msg_client.nid,
							jid = msg_client.jid,
							group_id = msg_client.group_id,
							group_name = msg_client.group_name,
							
						},msg_client.jid, nil, nil, true);
					elseif(msg and msg.errorcode)then
						--TODO:通过错误码 识别：家园人数已满，米米号已经加入其他家族
						--家园人数已满
						if(msg.errorcode == 433)then
							local s = [[<div style='margin-left:15px;margin-top:10px;'>你的家族人数已满，不能加入成员了！</div>]];
							_guihelper.Custom_MessageBox(s,function(result)
									
							end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"}, nil, true); -- true for isNotTopLevel
						end
					end
				end);
			else
				--拒绝申请加入
				HaqiGroupClient.SendMessage({
						type = "refuse_request",
						nid = msg_client.nid,
						jid = msg_client.jid,
						group_id = msg_client.group_id,
						group_name = msg_client.group_name,
							
					},msg_client.jid, nil, nil, true);
			end
	end, _guihelper.MessageBoxButtons.YesNo, nil, nil, true); -- true for isNotTopLevel
end
--拒绝申请加入
function HaqiGroupClient.Refuse_Request(msg_client)
	local s = string.format([[<div style='margin-left:15px;margin-top:10px;text-align:center'>对不起，你的申请被家族：%s(%s)拒绝了，你可以在家族管理处加入其他家族。</div>]],msg_client.group_name or "",MyCompany.Aries.Quest.NPCs.HaqiGroupManage.FormatID(msg_client.group_id));
	_guihelper.Custom_MessageBox(s,function(result)
			
	end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"}, nil, true); -- true for isNotTopLevel
end
--加入家族成功
function HaqiGroupClient.Accept_Request(msg_client)
	-- auto refresh the user self info in memory for family update
	System.App.profiles.ProfileManager.GetUserInfo(nil, nil, function(msg)
		-- force get family info
		MyCompany.Aries.Friends.GetMyFamilyInfo(function(msg)
			-- auto connect to family chat room
			MyCompany.Aries.Chat.FamilyChatWnd.ConnectToMyFamilyChatRoom();
		end, "access plus 0 day");
	end, "access plus 0 day");
	-- send nickname update to chat channel
	MyCompany.Aries.BBSChatWnd.SendUserNicknameUpdate();
	local s = string.format([[<div style='margin-left:15px;margin-top:10px;text-align:center'>你已经加入家族：%s(%s)，你可以使用下方的“家族”按钮查看家族信息。</div>]],msg_client.group_name or "",MyCompany.Aries.Quest.NPCs.HaqiGroupManage.FormatID(msg_client.group_id));
	_guihelper.Custom_MessageBox(s,function(result)
			
	end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"}, nil, true); -- true for isNotTopLevel
end
--被踢出家族
function HaqiGroupClient.Fired(msg_client)
	-- auto refresh the user self info in memory for family update
	System.App.profiles.ProfileManager.GetUserInfo(nil, nil, nil, "access plus 0 day");
	-- send nickname update to chat channel
	MyCompany.Aries.BBSChatWnd.SendUserNicknameUpdate();
	-- auto leave family chat room
	MyCompany.Aries.Chat.FamilyChatWnd.LeaveMyFamilyChatRoom();
	local s = string.format([[<div style='margin-left:15px;margin-top:10px;text-align:center'>你被家族：%s(%s)开除了。你可以在家族管理处加入其他家族。</div>]],msg_client.group_name or "",MyCompany.Aries.Quest.NPCs.HaqiGroupManage.FormatID(msg_client.group_id));
	_guihelper.Custom_MessageBox(s,function(result)
			
	end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"}, nil, true); -- true for isNotTopLevel
end
--加入家族成功 被邀请
function HaqiGroupClient.Accept_Request_Invite(msg_client)
	local link_str = HaqiGroupClient.GetLinkStr(msg_client.nickname or "",msg_client.nid or 0);
	local s = string.format([[<div style='margin-left:15px;margin-top:10px;'>%s已经接受你的邀请，加入了你的家族。</div>]],link_str);
	_guihelper.Custom_MessageBox(s,function(result)
			
	end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"}, nil, true); -- true for isNotTopLevel
end
--邀请加入
function HaqiGroupClient.Invite(msg_client)
	local link_str = HaqiGroupClient.GetLinkStr(msg_client.sender_nickname or "",msg_client.sender_nid or 0);
	local s = string.format([[<div style='margin-left:15px;margin-top:10px;'>%s邀请你加入家族：%s(%s),你要加入吗？</div>]],link_str,msg_client.group_name or "",MyCompany.Aries.Quest.NPCs.HaqiGroupManage.FormatID(msg_client.group_id));
	_guihelper.MessageBox(s,function(res)
		if(res and res == _guihelper.DialogResult.Yes) then
			--发送申请
			local msg = {
				familyid = msg_client.group_id,
			}
			commonlib.echo("===============before request_accept in HaqiGroupClient.Invite");
			commonlib.echo(msg);
			paraworld.Family.AcceptInvite(msg,"",function(msg)
				commonlib.echo("===============after request_accept in HaqiGroupClient.Invite");
				commonlib.echo(msg);
				if(msg and msg.issuccess)then
					_guihelper.MessageBox(string.format("你已经成功加入了家族%s(%s)",msg_client.group_name or "",msg_client.group_id or 0));
					-- auto refresh the user self info in memory for family update
					System.App.profiles.ProfileManager.GetUserInfo(nil, nil, function(msg)
						-- force get family info
						MyCompany.Aries.Friends.GetMyFamilyInfo(function(msg)
							-- auto connect to family chat room
							MyCompany.Aries.Chat.FamilyChatWnd.ConnectToMyFamilyChatRoom();
						end, "access plus 0 day");
					end, "access plus 0 day");
					-- send nickname update to chat channel
					MyCompany.Aries.BBSChatWnd.SendUserNicknameUpdate();
					HaqiGroupClient.SendMessage({
						type = "invite_accept",
						nid = msg_client.nid,
						jid = msg_client.jid,
						nickname = msg_client.nickname,
						
						group_id = msg_client.group_id,
						group_name = msg_client.group_name,
					},msg_client.sender_jid, nil, nil, true);
				end
			end);
			
			
				
			
		end
	end, _guihelper.MessageBoxButtons.YesNo, nil, nil, true); -- true for isNotTopLevel
end
--获取某个人的详细信息 包括jid
function HaqiGroupClient.GetUserInfo(nid,callbackFunc,cache_policy)
	if(not nid)then
		nid = Map3DSystem.User.nid;
	end
	commonlib.echo("===before get user info in HaqiGroupClient");
	commonlib.echo(nid);
	Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nid, "HaqiGroupClient.GetUserInfo", function (msg)
		commonlib.echo("====after get user info in HaqiGroupClient");
		commonlib.echo(msg);
		if(msg and msg.users and msg.users[1]) then
			--user info
			local result = msg.users[1];
			
			--jid
			Map3DSystem.App.profiles.ProfileManager.GetJID(nid, function(jid)
				commonlib.echo("====get jid in HaqiGroupClient！")
				commonlib.echo(jid)
				result.jid = jid;
				
				if(callbackFunc)then
					callbackFunc(result);
				end
			end)
		end
	end,cache_policy or "access plus 0 day")
end

local function activate()
	if( HaqiGroupClient.isInit and msg.jckey == HaqiGroupClient.GetJID()) then
		if(msg.seq_r) then
			-- this is just a confirm reply message. invoke callback
			local callback = msg_queue[msg.seq_r];
			if(callback and callback.callbackFunc) then
				callback.callbackFunc(msg);
				if(callback.timer) then
					callback.timer:Change();
				end
			end
		else
			-- this is a request message. handle it and immediately send confirm message. 
			HaqiGroupClient.HandleMessage(msg)
			if(msg.seq and msg.jid) then
				-- this does nothing but to confirm that we have received the request. 
				HaqiGroupClient.SendMessage({msg_type="confirm", seq_r = msg.seq}, msg.jid, nil, nil, true);
			end
		end
		
	end	
end
NPL.this(activate);

