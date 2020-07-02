--[[
Title: PENoteTemplate
Author(s): Leio
Date: 2009/9/25
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/PENoteTemplate.lua");
local PENoteTemplate = Map3DSystem.App.PENote.PENoteTemplate;
local note = {
	to_name = "leio1",
	from_name = "leio",
	content = "test",
	show_template = Map3DSystem.App.PENote.PENoteTemplate.GOHOME,
}
PENoteTemplate.Show(note);
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/TimeRemindPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/GiftRemindPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/GotoPlacePage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
local PENoteTemplate = {
	name = "PENoteTemplate_instance",
	GOHOME = "gohome",--礼物盒提醒
	TIMEREMIND = "timeremind",--关闭服务器时间提醒
	FromManagerTo10000 = "FromManagerTo10000",--发送给10000号的消息
	GOTOPLACE = "gotoplace",--立刻到某个地方
	CHALLENGEFLAG = "challengeflag",--在家园挑战 挑战之旗
	REDPAPER_TEMPLATE = "redpaper_template",--拜年 发红包
	CHILDREN_RESEARCH = "children_research",--哈奇小镇小调查
}
commonlib.setfield("Map3DSystem.App.PENote.PENoteTemplate",PENoteTemplate);
function PENoteTemplate.Show(note)
	commonlib.echo("==============PENoteTemplate.Show");
	commonlib.echo(note);
	--礼物盒提醒
	if(note.show_template == PENoteTemplate.GOHOME)then
		PENoteTemplate.Show_GOHOME(note);
	--关闭服务器时间提醒
	elseif(note.show_template == PENoteTemplate.TIMEREMIND)then
		PENoteTemplate.Show_TIMEREMIND(note);
	--发送给10000号的消息
	elseif(note.show_template == PENoteTemplate.FromManagerTo10000)then
		PENoteTemplate.Show_FromManagerTo10000(note);
	--立刻到某个地方
	elseif(note.show_template == PENoteTemplate.GOTOPLACE)then
		PENoteTemplate.Show_GOTOPLACE(note);
	--在家园挑战 挑战之旗
	elseif(note.show_template == PENoteTemplate.CHALLENGEFLAG)then
		PENoteTemplate.Show_Flag(note)
	--拜年 发红包
	elseif(note.show_template == PENoteTemplate.REDPAPER_TEMPLATE)then
		PENoteTemplate.Show_RedPaper(note)
	--哈奇小镇小调查
	elseif(note.show_template == PENoteTemplate.CHILDREN_RESEARCH)then
		PENoteTemplate.Show_ChildrenResearch(note)
	end
end
function PENoteTemplate.ShowUserInfo(nid)
	if(not nid)then return end
	System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
end
--拜年 发红包
function PENoteTemplate.Show_RedPaper(note)
	NPL.load("(gl)script/apps/Aries/RedPaperMail/RedPaperMailPage.lua");
	MyCompany.Aries.RedPaperMailPage.ShowPage()
	--MyCompany.Aries.RedPaperMailPage.ShowPageByIndex(1)
end
--在家园挑战 挑战之旗
function PENoteTemplate.Show_Flag(note)
if(not note)then return end
	local from_nid = note.from_nid or "";
	
	local nids = tostring(from_nid);
	Map3DSystem.App.HomeLand.HomeLandGateway.GetUserInfo(nids,function(msg)
		if(msg and not msg.error and msg.usersinfo)then
			local usersinfo = msg.usersinfo;
			userinfo = usersinfo[from_nid] or {};
			local name = userinfo.nickname or "";
			local s = string.format([[<div style='margin-left:15px;margin-top:15px;'><a onclick="Map3DSystem.App.PENote.PENoteTemplate.ShowUserInfo" param1='%d'>%s(%d)</a>成功触摸到了你家的挑战之旗，你也获得了1片红枫叶哦！</div>]],from_nid,name,from_nid);
			_guihelper.Custom_MessageBox(s,function(result)
				if(result == _guihelper.DialogResult.OK)then
					Map3DSystem.Item.ItemManager.GetItemsInBag(12, "", function(msg2)
						
					end, "access plus 0 day");
				end
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		end
	end);
end
--礼物盒提醒 立即回家
function PENoteTemplate.Show_GOHOME(note)
	if(not note)then return end
	local to_label = note.to_label or "";
	local from_label = note.from_label or "";
	local to_nid = note.to_nid or "";
	local from_nid = note.from_nid or "";
	
	
	local nids = to_nid .."," .. from_nid;
	Map3DSystem.App.HomeLand.HomeLandGateway.GetUserInfo(nids,function(msg)
		if(msg and not msg.error and msg.usersinfo)then
			local usersinfo = msg.usersinfo;
			local to_userinfo = usersinfo[to_nid] or {};
			local from_userinfo = usersinfo[from_nid] or {};
			
			local to_name = to_userinfo.nickname or to_nid;
			local from_name = from_userinfo.nickname or from_nid;
			
			to_label = string.gsub(to_label,"%%name%%",to_name);
			from_label = string.gsub(from_label,"%%name%%",from_name);
			from_label = string.format("%s(%d)",from_label,from_nid);
			local content = note.content;
			
			local date = note.date;
			Map3DSystem.App.PENote.GiftRemindPage.Bind(to_label,from_label,content,date);
			Map3DSystem.App.PENote.GiftRemindPage.ShowPage()
			
		else
			
		end
	end);
end
--立刻到某个地方
function PENoteTemplate.Show_GOTOPLACE(note)
	if(not note)then return end
	local to_label = note.to_label or "";
	local from_label = note.from_label or "";
	local to_nid = note.to_nid or "";
	
	
	local nids = tostring(to_nid);
	Map3DSystem.App.HomeLand.HomeLandGateway.GetUserInfo(nids,function(msg)
		if(msg and not msg.error and msg.usersinfo)then
			local usersinfo = msg.usersinfo;
			local to_userinfo = usersinfo[to_nid] or {};
		
			
			local to_name = to_userinfo.nickname or to_nid;
			local from_name = "哈奇小镇公民管理处";
			
			to_label = string.gsub(to_label,"%%name%%",to_name);
			from_label = string.gsub(from_label,"%%name%%",from_name);
			
			local content = note.content;
			
			local date = note.date;
			local goto;
			local camera;
			local goto_type;--跳转类型 nil is --抱抱龙5级 "pet_level_5"
			if(note.tag)then
				goto = note.tag.goto;
				camera = note.tag.camera;
				goto_type = note.tag.goto_type;
				if(goto_type and goto_type == "spring_bottle")then
					from_label = "罗德镇长";
				end
			end
			local msg = {
				to_label = to_label,
				from_label = from_label,
				content = content,
				date = date,
				goto = goto,
				camera = camera,
				goto_type = goto_type,
			}
			Map3DSystem.App.PENote.GotoPlacePage.Bind(msg);
			Map3DSystem.App.PENote.GotoPlacePage.ShowPage()
		end
	end);
end
--服务器关闭提醒
function PENoteTemplate.Show_TIMEREMIND(note)
	if(not note)then return end
	local to_label = note.to_label or "";
	local from_label = note.from_label or "";
	local to_nid = note.to_nid or "";
	
	
	local nids = tostring(to_nid);
	Map3DSystem.App.HomeLand.HomeLandGateway.GetUserInfo(nids,function(msg)
		if(msg and not msg.error and msg.usersinfo)then
			local usersinfo = msg.usersinfo;
			local to_userinfo = usersinfo[to_nid] or {};
		
			
			local to_name = to_userinfo.nickname or to_nid;
			local from_name = "哈奇小镇公民管理处";
			
			to_label = string.gsub(to_label,"%%name%%",to_name);
			from_label = string.gsub(from_label,"%%name%%",from_name);
			
			local content = note.content;
			
			local date = note.date;
			Map3DSystem.App.PENote.TimeRemindPage.Bind(to_label,from_label,content,date);
			Map3DSystem.App.PENote.TimeRemindPage.ShowPage()
			
		else
			
		end
	end);
end
--发送给10000号的消息
function PENoteTemplate.Show_FromManagerTo10000(note)
	commonlib.echo("===================note");
	commonlib.echo(note);
	if(not note)then return end
	local info = note.tag or "";
	NPL.load("(gl)script/apps/Aries/Chat/SystemChat.lua");
	MyCompany.Aries.Chat.SystemChat.ShowPage(info);
end
--哈奇小镇小调查
function PENoteTemplate.Show_ChildrenResearch(note)
	if(not note)then return end
	local to_label = note.to_label or "";
	local from_label = note.from_label or "";
	local to_nid = note.to_nid or "";
	
	
	local nids = tostring(to_nid);
	Map3DSystem.App.HomeLand.HomeLandGateway.GetUserInfo(nids,function(msg)
		if(msg and not msg.error and msg.usersinfo)then
			local usersinfo = msg.usersinfo;
			local to_userinfo = usersinfo[to_nid] or {};
		
			
			local to_name = to_userinfo.nickname or to_nid;
			local from_name = "哈奇小镇公民管理处";
			
			to_label = string.gsub(to_label,"%%name%%",to_name);
			from_label = string.gsub(from_label,"%%name%%",from_name);
			
			local content = note.content;
			
			local date = note.date;
			Map3DSystem.App.PENote.ChildrenResearchPage.Bind(to_label,from_label,content,date);
			Map3DSystem.App.PENote.ChildrenResearchPage.ShowPage()
		end
	end);
end