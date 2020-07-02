--[[
Title: 
Author(s): Leio
Date: 2009/10/10
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/ChildrenResearchPage.lua");
Map3DSystem.App.PENote.ChildrenResearchPage.ShowPage();

NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/ChildrenResearchPage.lua");
Map3DSystem.App.PENote.PENote_Client:SendMessage({  to_nid = Map3DSystem.User.nid,
																		from_nid = nil,
																		note = "children_research",
																		date = "2010/03/18",
																	},Map3DSystem.User.jid);
-------------------------------------------------------
]]
-- default member attributes
local ChildrenResearchPage = {
	page = nil,

	fromname = nil,
	toname = nil,
	content = nil,
}
commonlib.setfield("Map3DSystem.App.PENote.ChildrenResearchPage",ChildrenResearchPage);

function ChildrenResearchPage.OnInit()
	local self = ChildrenResearchPage;
	self.page = document:GetPageCtrl();
end
function ChildrenResearchPage.ShowPage()
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/PENote/Pages/ChildrenResearchPage.html", 
			name = "ChildrenResearchPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -1020/2,
				y = -680/2,
				width = 1020,
				height = 680,
		});
end
function ChildrenResearchPage.ClosePage()
	local self = ChildrenResearchPage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="ChildrenResearchPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
	self.Clear();
end
function ChildrenResearchPage.Bind(toname,fromname,content,date)
	local self = ChildrenResearchPage;
	self.fromname = fromname;
	self.toname = toname;
	self.content = content;
	self.date = date;
end
function ChildrenResearchPage.Clear()
	local self = ChildrenResearchPage;
	self.page = nil;
	self.fromname = nil;
	self.toname = nil;
	self.content = nil;
	self.date = nil;
end
function ChildrenResearchPage.HasAnswered()
	local self = ChildrenResearchPage;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	return hasGSItem(50296);
end
function ChildrenResearchPage.DoAnswer()
	local self = ChildrenResearchPage;
	if(self.HasAnswered())then return end
	if(self.page)then
		local sex = self.page:GetValue("sex");
		local age = self.page:GetValue("age");
		sex = tonumber(sex);
		age = tonumber(age);
		if(not sex or not age or age < 5)then
			NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
			_guihelper.Custom_MessageBox("<div style='margin-left:15px;margin-top:25px;text-align:center'>你的题目还没答完哦，答完了我会给你送2000奇豆呢！</div>",function(result)
				if(result == _guihelper.DialogResult.OK)then
					commonlib.echo("OK");
				end
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return
		end
		local title = "哈奇小镇小调查";
		local sex_label;
		local age_label;
		if(sex == 0)then
			sex_label = "boy";--男
		else
			sex_label = "girl";
		end
		
		--if(age == 5)then
			--age_label = "6岁以下";
		--elseif(age == 17)then
			--age_label = "16岁以上";
		--else
			--age_label = age.."岁";
		--end
		local content = string.format("nid:%d,gender:%s,age:%d",Map3DSystem.User.nid,sex_label,age);
		--local content = string.format("米米号：%d,性别：%s,年纪：%s",Map3DSystem.User.nid,sex_label,age_label);
		local msg = {
				nid = Map3DSystem.User.nid,
				cid = 101,
				title = title,
				msg = content,
			}
--		commonlib.echo("=========before send mail in ChildrenResearchPage:");
--		commonlib.echo(msg);
		paraworld.litemail.Add(msg,"ChildrenResearchPage",function(msg)
--			commonlib.echo("=========after send mail in ChildrenResearchPage:");
--			commonlib.echo(msg);
			if(msg and msg.issuccess)then
				
				_guihelper.Custom_MessageBox("<div style='margin-left:15px;margin-top:25px;text-align:center'>谢谢小哈奇的配合，帕帕给你的2000奇豆放到你包里了！</div>",function(result)
					if(result == _guihelper.DialogResult.OK)then
--						commonlib.echo("========before extend FinishAgeSurvey");
						System.Item.ItemManager.ExtendedCost(381, nil, nil, function(msg) 
--							commonlib.echo("========after extend FinishAgeSurvey");
--							commonlib.echo(msg);
							if(msg and msg.issuccess)then
							
							end
						end);
					end
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			else
				_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>提交失败！</div>");
			end
			--关闭页面
			self.ClosePage();
		end);
	end
end
