--[[
Title: CastSkillHitBoard
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/30347_CastSkillHitBoard.lua");
MyCompany.Aries.Quest.NPCs.CastSkillHitBoard.ShowPage();
------------------------------------------------------------
]]

-- create class
local libName = "CastSkillHitBoard";
local CastSkillHitBoard = {
	skills_template = {
		{strength = 8, intelligence = 10, archskillpts = 0,},
		{strength = 40, intelligence = 50, archskillpts = 40,},
		{strength = 300, intelligence = 200, archskillpts = 270,},
		{strength = 1000, intelligence = 1500, archskillpts = 960,},
	},
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.CastSkillHitBoard", CastSkillHitBoard);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- CastSkillHitBoard.main
function CastSkillHitBoard.main()
	local self = CastSkillHitBoard; 
end
function CastSkillHitBoard.DS_Func_CastSkillHitBoard(index)
	local self = CastSkillHitBoard;
	if(not self.skills_template)then return 0 end
	if(index == nil) then
		return #(self.skills_template);
	else
		return self.skills_template[index];
	end
end
function CastSkillHitBoard.OnInit()
	local self = CastSkillHitBoard; 
	self.page = document:GetPageCtrl();
end
function CastSkillHitBoard.PreDialog(npc_id, instance)
	local self = CastSkillHitBoard; 
	self.ShowPage();
	return false;
end
function CastSkillHitBoard.ShowPage()
	local self = CastSkillHitBoard;
	--重新加载龙的数据，确保是最新的
	MyCompany.Aries.Pet.GetRemoteValue(nil,function(msg)
			System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/SnowArea/30347_CastSkillHitBoard_panel.html", 
			name = "CastSkillHitBoard.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -890/2,
				y = -510/2,
				width = 890,
				height = 510,
		});
	end)
end
function CastSkillHitBoard.ClosePage()
	local self = CastSkillHitBoard;
	if(self.page)then
		self.page:CloseWindow();
	end
end
function CastSkillHitBoard.HasLevel_1()
	local self = CastSkillHitBoard;
	return hasGSItem(21101);
end
function CastSkillHitBoard.HasLevel_2()
	local self = CastSkillHitBoard;
	return hasGSItem(21102) and self.HasLevel_1();
end
function CastSkillHitBoard.HasLevel_3()
	local self = CastSkillHitBoard;
	return hasGSItem(21103) and self.HasLevel_2();
end
function CastSkillHitBoard.HasLevel_4()
	local self = CastSkillHitBoard;
	return hasGSItem(21104) and self.HasLevel_3();
end
function CastSkillHitBoard.HasMedal()
	local self = CastSkillHitBoard;
	return hasGSItem(20020) and self.HasLevel_4();
end
function CastSkillHitBoard.CanStudyLevel_1(lev)
	local self = CastSkillHitBoard;
	local bean = MyCompany.Aries.Pet.GetBean();
	local skills_template = self.skills_template[1];
	local strength,intelligence,archskillpts = skills_template.strength,skills_template.intelligence,skills_template.archskillpts;
	if(bean and not self.HasLevel_1())then
		if(bean.strength >= strength and bean.intelligence >= intelligence and bean.archskillpts >= archskillpts)then
			return true;
		end
	end
	return false,strength,intelligence,archskillpts;
end
function CastSkillHitBoard.CanStudyLevel_2()
	local self = CastSkillHitBoard;
	local bean = MyCompany.Aries.Pet.GetBean();
	local skills_template = self.skills_template[2];
	local strength,intelligence,archskillpts = skills_template.strength,skills_template.intelligence,skills_template.archskillpts;
	commonlib.echo("=====bean");
	commonlib.echo(bean);
	if(bean and not self.HasLevel_2())then
		if(bean.strength >= strength and bean.intelligence >= intelligence and bean.archskillpts >= archskillpts)then
			return true;
		end
	end
	return false,strength,intelligence,archskillpts;
end
function CastSkillHitBoard.CanStudyLevel_3()
	local self = CastSkillHitBoard;
	local bean = MyCompany.Aries.Pet.GetBean();
	local skills_template = self.skills_template[3];
	local strength,intelligence,archskillpts = skills_template.strength,skills_template.intelligence,skills_template.archskillpts;
	if(bean and not self.HasLevel_3())then
		if(bean.strength >= strength and bean.intelligence >= intelligence and bean.archskillpts >= archskillpts)then
			return true;
		end
	end
	return false,strength,intelligence,archskillpts;
end
function CastSkillHitBoard.CanStudyLevel_4()
	local self = CastSkillHitBoard;
	local bean = MyCompany.Aries.Pet.GetBean();
	local skills_template = self.skills_template[4];
	local strength,intelligence,archskillpts = skills_template.strength,skills_template.intelligence,skills_template.archskillpts;
	if(bean and not self.HasLevel_4())then
		if(bean.strength >= strength and bean.intelligence >= intelligence and bean.archskillpts >= archskillpts)then
			return true;
		end
	end
	return false,strength,intelligence,archskillpts;
end
function CastSkillHitBoard.CanGetMedal()
	local self = CastSkillHitBoard;
	return self.HasLevel_4() and not self.HasMedal();
end
--检测上一级有没有学习
function CastSkillHitBoard.CheckPreLevel(lev)
	local self = CastSkillHitBoard;
	if(lev == 1)then
		return true;
	elseif(lev == 2)then
		if(self.HasLevel_1())then
			return true;
		end
	elseif(lev == 3)then
		if(self.HasLevel_2())then
			return true;
		end
	elseif(lev == 4)then
		if(self.HasLevel_3())then
			return true;
		end
	end
end
--检测当前级别 能不能学习
function CastSkillHitBoard.CheckCurLevel(lev)
	local self = CastSkillHitBoard;
	if(lev == 1)then
		return self.CanStudyLevel_1();
	elseif(lev == 2)then
		return self.CanStudyLevel_2();
	elseif(lev == 3)then
		return self.CanStudyLevel_3();
	elseif(lev == 4)then
		return self.CanStudyLevel_4();
	end
end
--lev 1---4
function CastSkillHitBoard.DoStudy(lev)
	local self = CastSkillHitBoard;
	lev = tonumber(lev);
	if(not lev)then return end
	local state = MyCompany.Aries.Pet.GetState();
	--没有 跟随 或者 驾驭
	if(state == "home")then
		local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你的抱抱龙都没过来，不能学习技能哦，先把他带来再说吧！</div>";
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return
	end
	local bean = MyCompany.Aries.Pet.GetBean();
	--龙的级别低于5级
	if(bean.level < 5)then
		local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你的抱抱龙还小呢，等他5级以上再来学建造技能吧！</div>";
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return
	else
		local pass = self.CheckPreLevel(lev);
		if(not pass)then
			local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你的抱抱龙%d级建造技能还没有学完呢，要循序渐进哦！</div>"
						,lev - 1);
			_guihelper.Custom_MessageBox(s,function(result)
				
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return
		end
	end
	local pass,strength,intelligence,archskillpts= self.CheckCurLevel(lev);
	if(not pass)then
		local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>学习%d级建造技能需要达到力量值：%d点；智慧值：%d点，建造熟练度:%d点，你的条件还不符合，继续去努力吧！ </div>"
						,lev,strength,intelligence,archskillpts);
			_guihelper.Custom_MessageBox(s,function(result)
				
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return
	end
	--学习技能
	local exID;
	if(lev == 1)then
		exID = 272;
	elseif(lev == 2)then
		exID = 273;
	elseif(lev == 3)then
		exID = 274;
	elseif(lev == 4)then
		exID = 275;
	end
	if(not exID)then return end
	ItemManager.ExtendedCost(exID, nil, nil, function(msg) end, function(msg)
		if(msg) then
			log("+++++++GetSkillLevel_Architecture_Skill_Level return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				self.ClosePage();
				local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>太棒了，你的抱抱龙学会了%d级建造技能，快带他去建造台上大显身手吧！</div>"
							,lev);
				_guihelper.Custom_MessageBox(s,function(result)
					
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			end
		end
	end,"none");
end
--领取奖章
function CastSkillHitBoard.GetMedal()
	local self = CastSkillHitBoard;
	if(self.HasMedal())then
		local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你的抱抱龙已经领取过建造奖章啦，不能重复获得！</div>";
		_guihelper.Custom_MessageBox(s,function(result)
			
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return
	else
		--没有达到4级
		if(not self.HasLevel_4())then
			local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>抱抱龙建造技能还没有达到4级，不能领取建造奖章，快去练习练习吧！</div>";
			_guihelper.Custom_MessageBox(s,function(result)
				
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return
		else
			local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你把抱抱龙培养的很不错！<br/>这枚顶级建造技能奖章颁发给你，你可以在抱抱龙资料面板中把它放出来啦！</div>";
			_guihelper.Custom_MessageBox(s,function(result)
				if(result == _guihelper.DialogResult.OK)then
					--获取奖章
					ItemManager.ExtendedCost(280, nil, nil, function(msg) end, function(msg)
					if(msg) then
						log("+++++++ExtendedCost Award_20020_ArchitectureSkillMedal return: +++++++\n")
						commonlib.echo(msg);
						self.ClosePage();
					end
				end,"none");
	
				end
			end,_guihelper.MessageBoxButtons.OK);
		end
	end
end
