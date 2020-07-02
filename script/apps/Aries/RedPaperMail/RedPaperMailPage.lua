--[[
Title: RedPaperMail
Author(s): Leio
Date: 2010/02/06
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/RedPaperMail/RedPaperMailPage.lua");
MyCompany.Aries.RedPaperMailPage.ShowPageByIndex(1)
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
NPL.load("(gl)script/apps/Aries/RedPaperMail/RedPaperMail.lua");

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local RedPaperMailPage = {
	nickname = "",
	date = "",
	paper = nil,
	question = nil,
};
commonlib.setfield("MyCompany.Aries.RedPaperMailPage", RedPaperMailPage);
function RedPaperMailPage.OnInit()
	local self = RedPaperMailPage;
	self.pageCtrl = document:GetPageCtrl();
end
function RedPaperMailPage.ShowPageByIndex(index)
	local self = RedPaperMailPage;
	local nids = Map3DSystem.User.nid;
	Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nid, "", function (msg)
		if(msg and msg.users and msg.users[1]) then
			--user info
			self.nickname = msg.users[1].nickname;
			
			self.paper,self.question = MyCompany.Aries.RedPaperMail.GetQuestByIndex(index);
			self.date = MyCompany.Aries.RedPaperMail.GetServerDate();
			self.__ShowPage();
		end
	end);
end
function RedPaperMailPage.ShowPage()
	local self = RedPaperMailPage;
	local nids = Map3DSystem.User.nid;
	Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nid, "", function (msg)
		if(msg and msg.users and msg.users[1]) then
			--user info
			self.nickname = msg.users[1].nickname;
			
			self.paper,self.question = MyCompany.Aries.RedPaperMail.GetQuest();
			self.date = MyCompany.Aries.RedPaperMail.GetServerDate();
			self.__ShowPage();
		end
	end);
end

function RedPaperMailPage.__ShowPage()
	local self = RedPaperMailPage;
	if(not self.paper or not self.question)then return end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/RedPaperMail/RedPaperMailPage.html", 
			name = "RedPaperMailPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -1018/2,
				y = -666/2,
				width = 1018,
				height = 666,
		});
end
function RedPaperMailPage.ClosePage()
	local self = RedPaperMailPage;
	if(self.pageCtrl)then
		self.pageCtrl:CloseWindow();
	end
end
function RedPaperMailPage.RefreshPage()
	local self = RedPaperMailPage;
	if(self.pageCtrl)then
		self.pageCtrl:Refresh(0.01);
	end
end
function RedPaperMailPage.CheckAnswer()
	local self = RedPaperMailPage;
	if(self.pageCtrl and self.question and self.paper)then
		local isRight;
		local r = self.pageCtrl:GetValue("answer");
		r = tonumber(r);
		if(r and r == self.question.answer)then
			isRight = true;
		end
		if(not isRight)then
			_guihelper.Custom_MessageBox("<div style='margin-left:15px;margin-top:25px;text-align:center'>喔噢，你的答案不对哦，再想想看吧！</div>",function(result)
				if(result == _guihelper.DialogResult.OK)then
					self.RefreshPage();
				end
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return
		end
		local title = self.paper.reward_label or "";
		local s = string.format("<div style='margin-left:15px;margin-top:25px;text-align:center'>答对了，我送你%s和收集品新年礼券，新年礼券在元宵节前后可以用来抽奖呢，要多留意呀</div>",
			title);
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.OK)then
				self.ClosePage();
				--获得物品和 礼券
				self.DoExchange();
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	end
end
--兑换
function RedPaperMailPage.DoExchange()
	local self = RedPaperMailPage;
	if(self.paper and self.paper.exID)then
		local exID = self.paper.exID;
		commonlib.echo("=========start exchange in RedPaperMailPage");
		commonlib.echo(exID);
		ItemManager.ExtendedCost(exID, nil, nil, function(msg)end, function(msg) 
			commonlib.echo("=========after exchange in RedPaperMailPage");
			commonlib.echo(msg);
			if(msg and msg.issuccess)then
			end
		end);
	end
end
--是否有这个选项
function RedPaperMailPage.HasQuestion(index)
	local self = RedPaperMailPage;
	index = tonumber(index);
	if(not index or not self.question)then return end
	local option = self.question.option;
	if(option)then
		if(option[index])then
			return true;
		end
	end
end
function RedPaperMailPage.GetLabel(index)
	local self = RedPaperMailPage;
	if(self.HasQuestion(index))then
		return self.question.option[index];
	end
end
