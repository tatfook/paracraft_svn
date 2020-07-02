--[[
Title: 
Author(s): Leio
Date: 2009/11/16
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/LiteMailPage.lua");
Map3DSystem.App.PENote.LiteMailPage.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
-- default member attributes
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/LiteMailAlertPage.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/litemail/paraworld.litemail.lua");
local LiteMailPage = {
	page = nil,
	type = 1,--投稿的类型 1 镇长信箱 2 镇里的小秘密 500 攻略投稿
	file = "temp/cache/LiteMail",--本地记录 每天申请的次数
}
commonlib.setfield("Map3DSystem.App.PENote.LiteMailPage",LiteMailPage);

function LiteMailPage.OnInit()
	local self = LiteMailPage;
	self.page = document:GetPageCtrl();
end
--@param type:投稿类型
function LiteMailPage.ShowPage(type,args)
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
	local region_id = ExternalUserModule:GetRegionID();

	if (region_id~=0 ) then  -- 非淘米返回
		_guihelper.MessageBox("<div style='margin-left:15px;margin-top:15px;text-align:center'>意见反馈系统暂未开放，在此期间建议去官方论坛发表建议。</div>");
		return
	end

	local self = LiteMailPage;
	self.type = type or 1;
	
	local align = "_ct";
	local x = -235;
	local y = -175;
	local width = 470;
	local height = 350;
	local url = "script/kids/3DMapSystemUI/PENote/Pages/LiteMailPage.html";
	if(CommonClientService.IsTeenVersion())then
		url = "script/kids/3DMapSystemUI/PENote/Pages/LiteMailPage.teen.html";
	end
	if(args)then
		align = args.align or align;
		x = args.x or x;
		y = args.y or y;
		width = args.width or width;
		height = args.height or height;
		url = args.url or url;
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = url, 
			name = "LiteMailPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			--app_key=MyCompany.Taurus.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 3,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = align,
				x = x,
				y = y,
				width = width,
				height = height,
		});
end
function LiteMailPage.ClosePage()
	local self = LiteMailPage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="LiteMailPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
	self.isSending = false;
end
function LiteMailPage.SendMail()
	local self = LiteMailPage;
	if(self.page)then
		local title = self.page:GetUIValue("send_info_title");
		local content = self.page:GetUIValue("send_info");
		--commonlib.echo("!!:SendMail");
		--commonlib.echo(title);
		--commonlib.echo(content);
--
		if(not title or title == "")then
			--_guihelper.MessageBox("标题不能为空哦！");
			Map3DSystem.App.PENote.LiteMailAlertPage.ShowPage()
			return
		end
		if(not content or content == "")then
			--_guihelper.MessageBox("内容不能为空哦！");
			Map3DSystem.App.PENote.LiteMailAlertPage.ShowPage()
			return
		end
		--local s = string.format("投稿成功！\r\n%s\r\n%s",title,content);
		--_guihelper.MessageBox(s);
		
		local title_len = ParaMisc.GetUnicodeCharNum(title);
		if(title_len > 20)then
			_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>标题不能超过20个字，请重新输入吧。</div>");
			return
		end
		local content_len = ParaMisc.GetUnicodeCharNum(content);
		if(content_len > 500)then
			_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>正文不能超过500个字，请重新输入吧。</div>");
			return
		end
		--攻略投稿
		if(self.type == 500)then
			title = string.format("%s[combat]",title or "");
			self.type = 1;
		end
		local msg = {
			nid = Map3DSystem.User.nid,
			cid = self.type or 1,
			title = title,
			msg = content,
		}
		if(self.isSending)then return end
		self.isSending = true;
		local canSend = self.CanSend()
		if(not canSend)then
			_guihelper.MessageBox("<div style='margin-left:15px;margin-top:15px;text-align:center'>感谢小哈奇对我们的支持，今天你已经为小镇贡献了好多好多了呢！期待你明天再来哟O(∩_∩)O!</div>");
			return
		end
	--	commonlib.echo("=========before send mail in LiteMailPage:");
	--	commonlib.echo(msg);
--[[
		paraworld.PostMsg(msg, "LiteMailPage", function(msg)
			self.isSending = false;
	--		commonlib.echo("=========after send mail in LiteMailPage:");
	--		commonlib.echo(msg);
			_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>投稿成功，感谢你的来信！</div>");
			--关闭页面
			self.ClosePage();
		end);
]]
		paraworld.litemail.Add(msg,"LiteMailPage",function(msg)
			self.isSending = false;
			commonlib.echo("=========after send mail in LiteMailPage:");
			commonlib.echo(msg);
			if(msg and msg.issuccess)then
				
				_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>投稿成功，感谢你的来信！</div>");
			else
				_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>投稿失败！</div>");
			end
			--关闭页面
			self.ClosePage();
		end);

	end
end
--今天是否还可以发送申请
--这个函数每次请求 本地文件记录+1
function LiteMailPage.CanSend()
	local self = LiteMailPage;
	local nid = Map3DSystem.User.nid;
	local filepath = string.format("%s_%d.txt",self.file,nid or 0);
	--如果没有文件
	if(not ParaIO.DoesFileExist(filepath)) then
		--创建文件 初始化
		if(ParaIO.CreateNewFile(filepath))then
			local date = ParaGlobal.GetDateFormat("yyyy/MM/dd");
			local args = {
				date = date,--记录日期
				num = 1,--记录次数
			}
			--保存记录
			commonlib.SaveTableToFile(args, filepath)
			ParaIO.CloseFile();
			return true;
		end
	else
		local args = commonlib.LoadTableFromFile(filepath)
		local date = ParaGlobal.GetDateFormat("yyyy/MM/dd");
		if(args)then
			--如果是同一天
			if(args.date == date)then
				args.num = args.num + 1;
			else
				args.num = 1;
			end
			args.date = date;
			
			
		else
			args = {
				date = date,--记录日期
				num = 1,--记录次数
			}
		end
		--保存记录
		commonlib.SaveTableToFile(args, filepath)
		if(args.num < 10 )then
			return true;
		end
	end
end
function LiteMailPage.SendMail_Postlog()
	local self = LiteMailPage;
	if(self.page)then
		local title = self.page:GetUIValue("send_info_title");
		local content = self.page:GetUIValue("send_info");
		if(not title or title == "")then
			_guihelper.MessageBox("标题不能为空哦！");
			return
		end
		if(not content or content == "")then
			_guihelper.MessageBox("内容不能为空哦！");
			return
		end
		
		local title_len = ParaMisc.GetUnicodeCharNum(title);
		if(title_len > 20)then
			_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>标题不能超过20个字，请重新输入吧。</div>");
			return
		end
		local content_len = ParaMisc.GetUnicodeCharNum(content);
		if(content_len > 500)then
			_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>正文不能超过500个字，请重新输入吧。</div>");
			return
		end
		
		content=string.gsub(content,"\r\n",", ");
		local msg = {
			nid = Map3DSystem.User.nid,
			title = title,
			content = content,
		}
		paraworld.PostLog({action = "debug_by_user", msg = msg}, 
							"debug_by_user_log", function(msg)
						end);
		local s = string.format("意见已经提交，感谢您对【%s】的支持！",MyCompany.Aries.ExternalUserModule:GetConfig().product_name or "魔法哈奇")
		_guihelper.MessageBox(s);
		--关闭页面
		self.ClosePage();
	end
end