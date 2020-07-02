--[[
Title: 
Author(s): Leio
Date: 2011/07/06
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Family/FamilyMsg.lua");
local FamilyMsg = commonlib.gettable("Map3DSystem.App.Family.FamilyMsg");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Family/FamilyMsg.lua");
local FamilyManager = commonlib.gettable("Map3DSystem.App.Family.FamilyManager");
local FamilyMsg = commonlib.gettable("Map3DSystem.App.Family.FamilyMsg");

function FamilyMsg.SendMessage(nid,msg)
	LOG.std(nil, "info","FamilyMsg.SendMessage",{nid = nid,msg = msg});
	if(not msg or not nid or nid == Map3DSystem.User.nid)then return end
	if(FamilyManager.global_jc)then
		Map3DSystem.App.profiles.ProfileManager.GetJID(nid, function(jid)
			if(jid)then
				FamilyManager.global_jc:activate(jid..":".."script/apps/Aries/Family/FamilyManager.lua", msg);
			end
		end);
	end
end
function FamilyMsg.HandleMessage(msg)
	LOG.std(nil, "info","FamilyMsg.HandleMessage",msg);
	if(not msg)then return end
	if(msg.msg_type == "got_quit_info")then
		--族长 副族长收到 队员退出家族的消息
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("family", {
			family_msg_type = msg.msg_type,
			from_nid = msg.from_nid,
			to_nid = msg.to_nid,
			familyid = msg.familyid,
			familyname = msg.familyname,
			
			ShowCallbackFunc = function(msg) FamilyMsg.Quit_Handle(msg) end,
		});
	elseif(msg.msg_type == "request_accept")then
		--请求加入家族
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("family", {
			family_msg_type = msg.msg_type,
			from_nid = msg.from_nid,
			to_nid = msg.to_nid,
			familyid = msg.familyid,
			familyname = msg.familyname,
			
			ShowCallbackFunc = function(msg) FamilyMsg.Request_Accept_Handle(msg) end,
		});
	elseif(msg.msg_type == "accept_request")then
		--加入家族成功
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("family", {
			family_msg_type = msg.msg_type,
			from_nid = msg.from_nid,
			to_nid = msg.to_nid,
			familyid = msg.familyid,
			familyname = msg.familyname,
			
			ShowCallbackFunc = function(msg) FamilyMsg.Accept_Request_Handle(msg) end,
		});
		MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"},79015);
	elseif(msg.msg_type == "refuse_request")then
		--加入家族失败
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("family", {
			family_msg_type = msg.msg_type,
			from_nid = msg.from_nid,
			to_nid = msg.to_nid,
			familyid = msg.familyid,
			familyname = msg.familyname,
			
			ShowCallbackFunc = function(msg) FamilyMsg.Refuse_Request(msg) end,
		});
	elseif(msg.msg_type == "fired")then
		NPL.load("(gl)script/apps/Aries/Chat/FamilyChatWnd.lua");
		MyCompany.Aries.Chat.FamilyChatWnd.Show(false);
		local jc = MyCompany.Aries.Chat.FamilyChatWnd.GetJC();
		if(jc) then
			jc:LeaveRoom()
		end
		--被踢出家族
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("family", {
			family_msg_type = msg.msg_type,
			from_nid = msg.from_nid,
			to_nid = msg.to_nid,
			familyid = msg.familyid,
			familyname = msg.familyname,
			
			ShowCallbackFunc = function(msg) FamilyMsg.DoFire_Handle(msg) end,
		});
	elseif(msg.msg_type == "invite")then
		--邀请加入
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("family", {
			family_msg_type = msg.msg_type,
			from_nid = msg.from_nid,
			to_nid = msg.to_nid,
			familyid = msg.familyid,
			familyname = msg.familyname,
			
			ShowCallbackFunc = function(msg) FamilyMsg.DoInvite_Hnadle(msg) end,
		});
	elseif(msg.msg_type == "invite_accept")then
		--邀请被接受
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("family", {
			family_msg_type = msg.msg_type,
			from_nid = msg.from_nid,
			to_nid = msg.to_nid,
			familyid = msg.familyid,
			familyname = msg.familyname,
			
			ShowCallbackFunc = function(msg) FamilyMsg.Accept_Request_Invite(msg) end,
		});
		MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"},79015);
	elseif(msg.msg_type == "hand_headman")then
		--转让族长
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("family", {
			family_msg_type = msg.msg_type,
			from_nid = msg.from_nid,
			to_nid = msg.to_nid,
			familyid = msg.familyid,
			familyname = msg.familyname,
			
			ShowCallbackFunc = function(msg) FamilyMsg.DoHand_Headman_Handle(msg) end,
		});
	elseif(msg.msg_type == "appoint_assistant")then
		--任命副族长
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("family", {
			family_msg_type = msg.msg_type,
			from_nid = msg.from_nid,
			to_nid = msg.to_nid,
			familyid = msg.familyid,
			familyname = msg.familyname,
			
			ShowCallbackFunc = function(msg) FamilyMsg.DoAppoint_Assistant_Handle(msg) end,
		});
	elseif(msg.msg_type == "fire_assistant")then
		--撤销副族长
		MyCompany.Aries.Desktop.NotificationArea.AppendFeed("family", {
			family_msg_type = msg.msg_type,
			from_nid = msg.from_nid,
			to_nid = msg.to_nid,
			familyid = msg.familyid,
			familyname = msg.familyname,
			
			ShowCallbackFunc = function(msg) FamilyMsg.DoQuit_Assistant_Handle(msg) end,
		});
	end
end
--拒绝申请加入
function FamilyMsg.Refuse_Request(msg)
	if(not msg)then return end
	local msg_type = msg.family_msg_type;
	local from_nid = msg.from_nid;
	local to_nid = msg.to_nid;
	local familyid = msg.familyid;
	local familyname = msg.familyname;

	local s = string.format([[对不起，你的申请被家族：%s(%s)拒绝了，你可以在家族管理处加入其他家族。]],familyname or "", tostring(familyid));
	_guihelper.MessageBox(s);
end
--加入家族成功
function FamilyMsg.Accept_Request_Handle(msg)
	if(not msg)then return end
	local msg_type = msg.family_msg_type;
	local from_nid = msg.from_nid;
	local to_nid = msg.to_nid;
	local familyid = msg.familyid;
	local familyname = msg.familyname;

	local s = string.format([[你已经加入家族：%s(%s)。]],familyname or "", tostring(familyid));
	_guihelper.MessageBox(s);

	
end
--被踢出家族
function FamilyMsg.DoFire_Handle(msg)
	if(not msg)then return end
	local msg_type = msg.family_msg_type;
	local from_nid = msg.from_nid;
	local to_nid = msg.to_nid;
	local familyid = msg.familyid;
	local familyname = msg.familyname;

	local s = string.format([[你被家族%s(%s)开除了。你可以在家族管理处加入其他家族。]],familyname or "", tostring(familyid));
	_guihelper.MessageBox(s);
end
--邀请加入
function FamilyMsg.DoInvite_Hnadle(msg)
	if(not msg)then return end
	local msg_type = msg.family_msg_type;
	local from_nid = msg.from_nid;
	local to_nid = msg.to_nid;
	local familyid = msg.familyid;
	local familyname = msg.familyname;
	local s = string.format([[<div style='margin-left:15px;margin-top:10px;'>%s邀请你加入家族：%s(%s),你要加入吗？</div>]],FamilyMsg.GetNameStr(from_nid),familyname or "", tostring(familyid));
	_guihelper.MessageBox(s,function(res)
		if(res and res == _guihelper.DialogResult.Yes) then
			--发送申请
			local msg = {
				familyid = familyid,
			}
			commonlib.echo("========before paraworld.Family.AcceptInvite");
			commonlib.echo(msg);
			paraworld.Family.AcceptInvite(msg,"",function(msg)
				commonlib.echo("========after paraworld.Family.AcceptInvite");
				commonlib.echo(msg);
				if(msg and msg.issuccess)then
					_guihelper.MessageBox(string.format("你已经成功加入了家族%s(%s)",familyname or "",familyid or 0));
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

					FamilyMsg.SendMessage(from_nid,{
						msg_type = "invite_accept",
						from_nid = to_nid,
						to_nid = from_nid,
						familyid = familyid,
						familyname = familyname,
					});
				end
			end);
		end
	end, _guihelper.MessageBoxButtons.YesNo, nil, nil, true); -- true for isNotTopLevel
end
--邀请被接受
function FamilyMsg.Accept_Request_Invite(msg)
	if(not msg)then return end
	local msg_type = msg.family_msg_type;
	local from_nid = msg.from_nid;
	local to_nid = msg.to_nid;
	local familyid = msg.familyid;
	local familyname = msg.familyname;

	local s = string.format([[%s已经接受你的邀请，加入了你的家族。]],FamilyMsg.GetNameStr(from_nid));
	_guihelper.MessageBox(s,nil,nil,nil,nil,true);
end
--转让族长
function FamilyMsg.DoHand_Headman_Handle(msg)
	if(not msg)then return end
	local msg_type = msg.family_msg_type;
	local from_nid = msg.from_nid;
	local to_nid = msg.to_nid;
	local familyid = msg.familyid;
	local familyname = msg.familyname;

	local s = string.format([[太棒了！你已经被%s任命为[%s]的族长了！要多多关心家族成员哦！]],FamilyMsg.GetNameStr(from_nid),familyname or "");
	_guihelper.MessageBox(s,nil,nil,nil,nil,true);
end
--任命副族长
function FamilyMsg.DoAppoint_Assistant_Handle(msg)
	if(not msg)then return end
	local msg_type = msg.family_msg_type;
	local from_nid = msg.from_nid;
	local to_nid = msg.to_nid;
	local familyid = msg.familyid;
	local familyname = msg.familyname;

	local s = string.format([[太棒了！你已经被%s任命为[%s]的副族长了！]],FamilyMsg.GetNameStr(from_nid),familyname or "");
	_guihelper.MessageBox(s,nil,nil,nil,nil,true);
end
--撤销副族长
function FamilyMsg.DoQuit_Assistant_Handle(msg)
	if(not msg)then return end
	local msg_type = msg.family_msg_type;
	local from_nid = msg.from_nid;
	local to_nid = msg.to_nid;
	local familyid = msg.familyid;
	local familyname = msg.familyname;

	local s = string.format([[真遗憾，你不再是[%s]的副族长了！]],familyname or "");
	_guihelper.MessageBox(s);
end
--申请加入家族
function FamilyMsg.GetNameStr_2(nid)
	if(not nid)then return "" end;
	nid = tostring(nid);
	local s_name = string.format([[<a onclick="Map3DSystem.App.Family.FamilyMsg.ShowFullProfile" param1='%s'><pe:name nid='%s' linked=false/>(%s)</a>]],nid,nid,nid);
    local s_magic = string.format([[<div style="float:left;">魔法星:<aries:mountpet-status2 name="mlel" nid='%s' type="mlel" showzero="true" style="width:20px;"/>级</div>]],nid);
    local s_combat_level = string.format([[<div style="float:left;">战斗等级:<aries:mountpet-status2 name="combat_level" nid='%s' type="combatlel" hideifnotvip="true" style="width:20px;"/>级</div>]],nid);
	local s = string.format([[%s<br/>%s,%s<br/>]],s_name,s_magic,s_combat_level);
	return s;
end
function FamilyMsg.GetNameStr(nid)
	if(not nid)then return "" end;
	local s = string.format([[<a onclick="Map3DSystem.App.Family.FamilyMsg.ShowFullProfile" param1='%s'><pe:name nid='%s' linked=false/>(%s)</a><br/>]],tostring(nid),tostring(nid),tostring(nid));
	return s;
end
function FamilyMsg.ShowFullProfile(nid)
	if(not nid)then return end
	System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
end
--族长 副族长收到队员退出家族的消息
function FamilyMsg.Quit_Handle(msg)
	local msg_type = msg.family_msg_type;
	local from_nid = msg.from_nid;
	local to_nid = msg.to_nid;
	local familyid = msg.familyid;
	local familyname = msg.familyname;

	local s = string.format("<div style='margin-left:15px;margin-top:10px;'>%s已经退出你的家族。</div>",FamilyMsg.GetNameStr_2(from_nid));
	_guihelper.MessageBox(s);
end
--申请加入家族
function FamilyMsg.Request_Accept_Handle(msg)
	if(not msg)then return end
	local msg_type = msg.family_msg_type;
	local from_nid = msg.from_nid;
	local to_nid = msg.to_nid;
	local familyid = msg.familyid;
	local familyname = msg.familyname;

	local s = string.format("<div style='margin-left:15px;margin-top:10px;'>%s申请加入你的家族。你同意他的申请吗？</div>",FamilyMsg.GetNameStr_2(from_nid));
	_guihelper.MessageBox(s,function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				local msg = {
					familyid = familyid,
					requestnid = from_nid,
				}
				paraworld.Family.AcceptRequest(msg,"group",function(msg)
					if(msg and msg.issuccess)then
					
						local s = string.format([[%s已经加入你的家族了。]],FamilyMsg.GetNameStr_2(from_nid));
						_guihelper.MessageBox(s);
						
						-- auto refresh the user self info in memory for family update
						System.App.profiles.ProfileManager.GetUserInfo(nil, nil, function(msg)
							-- force get family info
							MyCompany.Aries.Friends.GetMyFamilyInfo(function(msg)
								-- auto connect to family chat room
								MyCompany.Aries.Chat.FamilyChatWnd.ConnectToMyFamilyChatRoom();
							end, "access plus 0 day");
						end, "access plus 0 day");

						--成功加入家族 回执申请者
						FamilyMsg.SendMessage(from_nid,{
							msg_type = "accept_request",
							from_nid = to_nid,
							to_nid = from_nid,
							familyid = familyid,
							familyname = familyname,
							
						});
					elseif(msg and msg.errorcode)then
						--TODO:通过错误码 识别：家园人数已满，米米号已经加入其他家族
						--人数已满
						if(msg.errorcode == 433)then
							local s = string.format([[你的家族人数已满，不能加入成员了！]]);
							_guihelper.MessageBox(s);
						end
					end
				end);
			else
				--拒绝加入家族 回执申请者
				FamilyMsg.SendMessage(from_nid,{
					msg_type = "refuse_request",
					from_nid = to_nid,
					to_nid = from_nid,
					familyid = familyid,
					familyname = familyname,
				});
			end
	end, _guihelper.MessageBoxButtons.YesNo, nil, nil, true); -- true for isNotTopLevel
end