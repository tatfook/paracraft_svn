--[[
Title: CombatSkillLearn
Author(s): spring
Date: 2010/06/21

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/MagicSchool/CombatSkillLearn.lua");
------------------------------------------------------------
]]

-- create class

local libName = "CombatSkillLearn";
local CombatSkillLearn = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatSkillLearn");

NPL.load("(gl)script/apps/Aries/NPCs/MagicSchool/HaqiTrial.lua");

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local skills={};

local AllSkills=commonlib.createtable("MyCompany.Aries.Quest.NPCs.CombatSkillLearn.AllSkills",{});
local AllRunes=commonlib.createtable("MyCompany.Aries.Quest.NPCs.CombatSkillLearn.AllRunes",{});
local AllGoldCards=commonlib.createtable("MyCompany.Aries.Quest.NPCs.CombatSkillLearn.AllGoldCards",{});

local classprop_gsid = MyCompany.Aries.Combat.GetSchoolGSID();
local classnm={[988]="风暴系",[990]="生命系",[991]="死亡系",[987]="寒冰系",[986]="烈火系",};

local NPC_MentorID=commonlib.createtable("MyCompany.Aries.Quest.NPCs.CombatSkillLearn.NPC_MentorID",{
	[988]=30398,[990]=30399,[991]=30400,[987]=30401,[986]=30402,[992]=30112,
});

--	local proptype={["fire"]=986,["ice"]=987,["storm"]=988,["myth"]=989,["life"]=990,["death"]=991,["balance"]=992,} -- 系别
local proptype={["fire"]=986,["ice"]=987,["storm"]=988,["life"]=990,["death"]=991,["balance"]=992,} -- 系别

local tips_gsid22000;
if(System.options.version=="kids") then
	tips_gsid22000="训练点";
else
	tips_gsid22000="潜力点";
end

-- CombatSkillLearn.main
function CombatSkillLearn.main()
	local self = CombatSkillLearn; 
end

function CombatSkillLearn.DS_Func_CombatSkillLearn(index)
	local self = CombatSkillLearn;
	if(index == nil) then
		return #(skills);
	else
		return skills[index];
	end	
end

local this_npc_id = nil;

-- only the first call will load from config file
function CombatSkillLearn.DoInit()
	if(CombatSkillLearn.IsInited) then
		return 
	else
		CombatSkillLearn.IsInited = true;
	end
	local self = CombatSkillLearn; 
	local config_file; 
	local mentorlist={};
	if(System.options.version=="kids") then
		config_file="config/Aries/Mentor/7Mentor.xml";
	else
		config_file="config/Aries/Mentor/7Mentor.teen.xml";
	end

	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading mentor config file: %s\n", config_file);
		return;
	end
	
	local bean = System.App.profiles.ProfileManager.GetUserInfoInMemory();
	local mylevel;
	if(bean) then
		mylevel = bean.combatlel or 1;
	end

	local npc_id;
	local pass,_,__,passcopies = hasGSItem(22000); -- 是否有训练点

	local _mentor;	
	for _mentor in commonlib.XPath.eachNode(xmlRoot, "/Mentors/Mentors_ID/mentor") do		
		npc_id = tonumber(_mentor.attr.npcid);
		mentorlist[npc_id]=_mentor.attr.name;
	end

	for  npc_id in pairs(mentorlist) do
		local xmlnode="/Mentors/NPC_"..npc_id;	

		local desc, each_mentor;

		skills={}; -- 初始化 mentor 的技能表

		for each_mentor in commonlib.XPath.eachNode(xmlRoot, xmlnode) do
			--commonlib.echo(each_mentor);
			desc = each_mentor.attr.desc;
			mentortype = tonumber(each_mentor.attr.class);
			-- create skills;
			local each_skill,i=nil,1;	
			local is_last_canlearn = false;	

			-- required skill
			for each_skill in commonlib.XPath.eachNode(each_mentor, "/skill") do
				skills[i]={};
				skills[i].gsid = tonumber(each_skill.attr.gsid);			
				skills[i].exID = tonumber(each_skill.attr.exID);

				if (System.options.version=="kids") then
					local notautolearn = each_skill.attr.notautolearn;
					if (notautolearn) then
						skills[i].notautolearn = true;
					end
				end
				
				if (each_skill.attr.other_exID)	then
					skills[i].other_exID = tonumber(each_skill.attr.other_exID);
				else -- 没有 other_exID 仅本系可学
					skills[i].other_exID = nil;
				end
				skills[i].skilltype=0;
				skills[i].mentortype=mentortype;

				if (mentortype==0) then
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(skills[i].gsid)
					if(gsItem)then
						local assetkey = gsItem.assetkey or "";
						assetkey = string.lower(assetkey);
						local prop = string.match(assetkey,"^%d+_(%a+)_.+") or "";
						if (proptype[prop]) then
							skills[i].classtype = proptype[prop];
						else
							skills[i].classtype = 0; -- 通用系
						end
					else
						--commonlib.echo("Wrong skill id!"..skills[i].gsid);
					end
				else
					skills[i].classtype = mentortype;
				end

				--commonlib.echo("======read from mentor.xml: mentortype, skills[i].gsid, skills[i].exID =====");
				--log(npc_id.."|"..mentortype.."|"..i.."|"..skills[i].gsid..","..skills[i].exID.."\n");

				if (skills[i].gsid == 0 ) then
					skills[i].name = "?"
					skills[i].skillHas = false;
					skills[i].skillCanStudy = false;
					skills[i].needlevel = "?";
					skills[i].tips = "";
				else
			 		local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(skills[i].gsid);
					skills[i].name = gsItem.template.name;			

					local sHas = hasGSItem(skills[i].gsid);
					skills[i].skillHas = sHas;
					local exTemplate = nil;
					if (skills[i].exID and (skills[i].classtype == tonumber(classprop_gsid) or skills[i].classtype == 0)) then
						exTemplate = ItemManager.GetExtendedCostTemplateInMemory(skills[i].exID);
					else
						if (skills[i].other_exID) then --外系可以学习
							exTemplate = ItemManager.GetExtendedCostTemplateInMemory(skills[i].other_exID);
						end
					end
					local skillCanStudyFrm, skillCanStudyPre, precondiPre = false,false,"";
					local skillCanStudy, needlevel, skillstatus = false,0,1;

					-- skillstatus: -1:已学, 0: 可以学习, 1: 等级不够, 2: 仅本系可学，3: 训练点不够, 4: 还有低级技能未学
					if(exTemplate)then
						skillCanStudy, needlevel, skillstatus = self.TakeCondi(exTemplate.pres);
					else -- 没有 other_exID 仅本系可学，外系 skillCanStudy = false
						-- 取该技能需要的战斗等级
						local exTemplate0;
						if (skills[i].exID) then
							exTemplate0 = ItemManager.GetExtendedCostTemplateInMemory(skills[i].exID);
							_,needlevel = self.TakeCondi(exTemplate0.pres);
						elseif (skills[i].other_exID) then
							exTemplate0 = ItemManager.GetExtendedCostTemplateInMemory(skills[i].other_exID);
							_,needlevel = self.TakeCondi(exTemplate0.pres);
						end

						--commonlib.echo(exTemplate0);
						skillCanStudy = false;
					end
										
					if(System.options.version=="kids") then
					-- Note by LiXizhi: the player can only learn the lowest one.  i.e. there can only be one highlighted learn button. 
						if(not is_last_canlearn and skillCanStudy) then
							if(not sHas) then
								is_last_canlearn = true;
							end
						else 
							if(is_last_canlearn and mentortype~=0) then
								skillCanStudy = false;
							end
						end
					end

					if (skills[i].classtype == tonumber(classprop_gsid) and skills[i].exID) then
						skills[i].tips = "本系免费学习";
						skills[i].learnpoints = 0;
					elseif (skills[i].classtype == 0) then
						skills[i].tips = "任何系别均可免费学习";
						skills[i].learnpoints = 0;
					else
						if (exTemplate) then
							if (next(exTemplate.froms)~=nil) then
								local points= tonumber(exTemplate.froms[1].value);
								skills[i].tips = string.format("需要 %d 个%s",points,tips_gsid22000);
								skills[i].learnpoints = points;
							else
								skills[i].tips = "任何系别均可免费学习";
								skills[i].learnpoints = 0;
							end
						else
							skills[i].tips = "仅本系可学习"
							skills[i].learnpoints = 999;
						end
						if (skills[i].learnpoints>0 and (not pass or passcopies<skills[i].learnpoints)) then
							skillCanStudy = false;
						end
					end				

					skills[i].skillCanStudy = skillCanStudy;
					skills[i].needlevel = needlevel;		
				end
				i=i+1;
			end
			-- option skill
			for each_skill in commonlib.XPath.eachNode(each_mentor, "/optionskill") do
				skills[i]={};
				skills[i].gsid = tonumber(each_skill.attr.gsid);			
				skills[i].exID = tonumber(each_skill.attr.exID);		
				skills[i].other_exID = tonumber(each_skill.attr.other_exID);
				needlevel=tonumber(each_skill.attr.needlevel);
				skills[i].tips = each_skill.attr.tips;
				skills[i].skilltype=1;

				if (System.options.version=="kids") then
					local notautolearn = each_skill.attr.notautolearn;
					if (notautolearn) then
						skills[i].notautolearn = true;
					end
				end

				if (mentortype==0) then
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(skills[i].gsid)
					if(gsItem)then
						local assetkey = gsItem.assetkey or "";
						assetkey = string.lower(assetkey);
						local prop = string.match(assetkey,"^%d+_(%a+)_.+") or "";
						skills[i].classtype = proptype[prop];
					else
						-- commonlib.echo("Wrong skill id!"..skills[i].gsid);
						commonlib.echo("Wrong skill id!");
					end
				else
					skills[i].classtype = mentortype;
				end

				if (skills[i].gsid == 0 ) then
					skills[i].name = "?"
					skills[i].skillHas = false;
					skills[i].skillCanStudy = false;
					skills[i].needlevel = "?";
					skills[i].tips = "";
				else
			 		local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(skills[i].gsid);
					skills[i].name = gsItem.template.name;			
					local sHas = hasGSItem(skills[i].gsid);
					skills[i].skillHas=sHas;

					local skillCanStudy,skillstatus=false,1;

					if(mylevel>=needlevel) then
						skillCanStudy = true;
						skillstatus =0;
					else 
						skillCanStudy = false;
						skillstatus = 1;
					end

					skills[i].skillCanStudy = skillCanStudy;
					skills[i].skillstatus = skillstatus;
					skills[i].needlevel = needlevel;
				end
				i=i+1;
			end

			-- magicbook skill
			for each_skill in commonlib.XPath.eachNode(each_mentor, "/magicbook") do
				skills[i]={};
				skills[i].gsid = tonumber(each_skill.attr.gsid);			
				needlevel=tonumber(each_skill.attr.needlevel);
				skills[i].tips = each_skill.attr.tips;
				skills[i].skilltype=2;
				skills[i].notautolearn = false;

				if (mentortype==0) then
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(skills[i].gsid)
					if(gsItem)then
						local assetkey = gsItem.assetkey or "";
						assetkey = string.lower(assetkey);
						local prop = string.match(assetkey,"^%d+_(%a+)_.+") or "";
						skills[i].classtype = proptype[prop];
					else
						-- commonlib.echo("Wrong skill id!"..skills[i].gsid);
						commonlib.echo("Wrong skill id!");
					end
				else
					skills[i].classtype = mentortype;
				end

				if (skills[i].gsid == 0 ) then
					skills[i].name = "?"
					skills[i].skillHas = false;
					skills[i].skillCanStudy = false;
					skills[i].needlevel = "?";
					skills[i].tips = "";
				else
			 		local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(skills[i].gsid);
					skills[i].name = gsItem.template.name;			
					local sHas = hasGSItem(skills[i].gsid);
					skills[i].skillHas=sHas;

					local skillCanStudy,skillstatus=false,1;
					
					if(mylevel>=needlevel and skills[i].classtype==tonumber(classprop_gsid)) then
						skillCanStudy = true;
						skillstatus = 0;
					else 
						skillCanStudy = false;
						skillstatus = 1;
					end

					skills[i].skillCanStudy = skillCanStudy;
					skills[i].skillstatus = skillstatus;
					skills[i].needlevel = needlevel;
				end
				i=i+1;
			end
			--commonlib.echo("============skills no order===============");
			--commonlib.echo(skills);
			local n=i-1;
			local j,k;
			local tempskill={};
			for j=1,n-1 do
				for k=j+1,n do
					local j_lvl = tonumber(string.match(skills[j].needlevel,"^(%d+).*") or "0");
					local k_lvl = tonumber(string.match(skills[k].needlevel,"^(%d+).*") or "0");

					if (j_lvl>k_lvl) then
						tempskill=skills[j];
						skills[j]=skills[k];
						skills[k]=tempskill;
					end
				end
			end
			--commonlib.echo("============skills after order===============");
			--commonlib.echo(skills);

		end

		--commonlib.echo("============skills===============NPC："..npc_id);
		--commonlib.echo(skills);
		AllSkills[npc_id]=commonlib.deepcopy(skills);
	end
end

function CombatSkillLearn.RuneDoInit()
	if(CombatSkillLearn.IsRuneInited) then
		return 
	else
		CombatSkillLearn.IsRuneInited = true;
	end
	local self = CombatSkillLearn; 
	local config_file;
	if(System.options.version=="kids") then
		config_file="config/Aries/Others/all_rune.kids.xml";
	else
		config_file="config/Aries/Others/all_rune.teen.xml";
	end

	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading rune config file: %s\n", config_file);
		return;
	end
	
	local school_id;
	for  school_id in pairs(NPC_MentorID) do
		local xmlnode="/ALL_RUNE/Rune_"..school_id;	

		local rune_school;
		local runes={}; -- 初始化

		for rune_school in commonlib.XPath.eachNode(xmlRoot, xmlnode) do
			local each_rune,i=nil,1;
			for each_rune in commonlib.XPath.eachNode(rune_school, "/item") do
				runes[i]={};
				runes[i].gsid = tonumber(each_rune.attr.gsid);		
				i=i+1;			
			end
		end
		AllRunes[school_id]=commonlib.deepcopy(runes);
	end
	--commonlib.echo("==================AllRunes");
	--commonlib.echo(AllRunes);
end

function CombatSkillLearn.GoldCardDoInit()
	if(CombatSkillLearn.IsGoldCardInited) then
		return 
	else
		CombatSkillLearn.IsGoldCardInited = true;
	end
	local self = CombatSkillLearn; 
	local config_file;
	if(System.options.version=="kids") then
		config_file="config/Aries/Others/all_goldcard.kids.xml";	
	end

	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading goldcards config file: %s\n", config_file);
		return;
	end
	
	local school_id;
	for  school_id in pairs(NPC_MentorID) do
		local xmlnode="/ALL_GoldCards/GoldCard_"..school_id;	

		local _school;
		local cards={}; -- 初始化

		for _school in commonlib.XPath.eachNode(xmlRoot, xmlnode) do
			local each_goldcard,i=nil,1;
			for each_goldcard in commonlib.XPath.eachNode(_school, "/item") do
				cards[i]={};
				cards[i].gsid = tonumber(each_goldcard.attr.gsid);		
				i=i+1;			
			end
		end
		AllGoldCards[school_id]=commonlib.deepcopy(cards);
	end
end

function CombatSkillLearn.OnInit(npc_id,nofilter)
	
	this_npc_id = npc_id;

	local self = CombatSkillLearn; 
	if(document) then
		self.page = document:GetPageCtrl();
	end

	-- 2011.9.21 new modified for DoInit by Spring
	CombatSkillLearn.DoInit();

	local bean = MyCompany.Aries.Pet.GetBean();
	local mylevel;
	if(bean) then
		mylevel = bean.combatlel or 1;
	end

	local s_index;
	local is_last_canlearn=false;
	local pass,_,__,passcopies = hasGSItem(22000); -- 是否有训练点

	skills = commonlib.deepcopy(AllSkills[npc_id] or {});

	local canlearnskill = 0;
	for s_index in ipairs(skills) do
		local skillCanStudy = skills[s_index].skillCanStudy;
		local skillstatus = skills[s_index].skillstatus;
		local sHas = hasGSItem(skills[s_index].gsid);
		skills[s_index].skillHas=sHas;

		if (skills[s_index].skilltype==0) then
			local exTemplate,needlevel=nil,0;
			if (skills[s_index].classtype == tonumber(classprop_gsid)) then
				exTemplate = ItemManager.GetExtendedCostTemplateInMemory(skills[s_index].exID);
			else
				if (skills[s_index].other_exID) then --外系可以学习
					exTemplate = ItemManager.GetExtendedCostTemplateInMemory(skills[s_index].other_exID);
				end
			end
			-- skillstatus: -1:已学, 0: 可以学习, 1: 等级不够, 2: 仅本系可学，3: 训练点不够, 4: 还有低级技能未学
			if(exTemplate)then
				skillCanStudy, needlevel,skillstatus = self.TakeCondi(exTemplate.pres);
			end

			if(System.options.version=="kids") then
				if(not is_last_canlearn and skillCanStudy) then
					if(not sHas) then
						is_last_canlearn = true;
						canlearnskill=skills[s_index].gsid;
					end
				else 
					if(is_last_canlearn and skills[s_index].mentortype~=0) then
						if (skillCanStudy) then
							skillstatus = 4;
						end
						skillCanStudy = false;
					end
				end
			end

			if (skills[s_index].classtype ~= tonumber(classprop_gsid) and skills[s_index].classtype~=0 and (skills[s_index].learnpoints>0 and ((not pass) or (passcopies and passcopies< skills[s_index].learnpoints)))) then
				if (skills[s_index].learnpoints == 999) then
					skillstatus = 2;
				else
					skillstatus = 3;
				end
				
				skillCanStudy = false;
			end
		end
		if (sHas) then
			skills[s_index].canlearnskill = 0;
			skills[s_index].skillstatus = -1;
		else
			skills[s_index].canlearnskill = canlearnskill;
			skills[s_index].skillstatus = skillstatus;
		end
		skills[s_index].skillCanStudy = skillCanStudy;
	end
	AllSkills[npc_id]=commonlib.deepcopy(skills);

	if (not nofilter) then -- 对于外系用户，过滤掉仅本系学习的技能
		local _skills = {};
		_skills = commonlib.deepcopy(skills);
		skills={};
		for s_index in ipairs(_skills) do
			if (((not _skills[s_index].other_exID) and (tonumber(_skills[s_index].learnpoints)==999)) or (_skills[s_index].skilltype==2 and _skills[s_index].classtype ~= tonumber(classprop_gsid)) ) then
			else
				table.insert(skills,_skills[s_index]);
			end
		end
	end
	commonlib.echo("==========OnInit skills")
	--commonlib.echo(skills)
	-- ++ 2011.9.21 new modified for DoInit by Spring

end

function CombatSkillLearn.TakeCondi(condi)
	local gsid,level,needlevel, skillCanStudy;
	skillCanStudy=false;
	needlevel=0;

	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		level = bean.combatlel or 0;
	end

	local SchoolJudge, LvlJudge, GsidJudge, status=true,true,true,0;
	if (condi) then
		for k,v in pairs(condi) do
				gsid = tonumber(v.key);
				
				if (gsid == -14) then  -- 判断前置条件中战斗等级的要求
					needlevel = tonumber(v.value);
					if (level >= needlevel) then
						LvlJudge =true;
					else
						status =1;
						LvlJudge =false;
        			end	
				elseif (gsid == -18) then  -- 判断前置条件中对系别的要求
					if (classprop_gsid == tonumber(v.value)) then
						SchoolJudge = true;
					else
						status = 2;
						SchoolJudge = false;
        			end
				elseif (gsid>0) then  -- 判断前置条件中对某物品的要求
					local bhas,_,_,copies= hasGSItem(gsid);
					if (bhas and copies>=tonumber(v.value)) then
						GsidJudge = true;
					else
						if (gsid==22000) then
							status = 3;
						else
							status = 4;
						end
						GsidJudge = false;
					end
				end
		end		
		skillCanStudy = LvlJudge and SchoolJudge and GsidJudge;
	end
	return skillCanStudy,needlevel,status;
end

function CombatSkillLearn.ClosePage()

	NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
	local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");

	if(this_npc_id) then
		QuestHelp.SayGoodbyeToNPC(this_npc_id);
	end

	local self = CombatSkillLearn;
	if(self.page)then
		self.page:CloseWindow();
	end
end

--根据gsid，获取卷轴名
function CombatSkillLearn.GetSkillNameByLevel(gsid)
	local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);

	if(gsItem) then
		return gsItem.template.name;
	end
end

function CombatSkillLearn.RefreshPage()
	local self = CombatSkillLearn;
	if(self.page)then
		self.page:Refresh(0.01);
	end
end

function CombatSkillLearn.HasStudy(index)
	local self = CombatSkillLearn;	
	local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(skills[index].gsid);
	local name = gsItem.template.name;
	local s =string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>%s这个魔法你已经学会了，去学习新的魔法吧！!</div>",name);
	_guihelper.Custom_MessageBox(s,function(result)
			
	end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	return
end

function CombatSkillLearn.CanNotStudy(index)
	local self = CombatSkillLearn;
	local skill = skills[index];
	local gsid = tonumber(skill.gsid);	
	local s;
	if (gsid == 0) then
		s ="<div style='margin-left:15px;margin-top:20px;text-align:center'>新的魔法还在研究中，请耐心等待!</div>";
	else
		local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
		local name = gsItem.template.name;
		if (skill.skilltype==2 and skill.classtype~=tonumber(classprop_gsid)) then
			s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>%s是%s专有魔典技能，你不是这个系的不能获得哦，去自己系看看吧！</div>",name,classnm[skill.classtype]);
		else
			if (skill.skillstatus) then
			-- skillstatus: 0: 可以学习, 1: 等级不够, 2: 仅本系可学，3: 训练点不够, 4: 还有低级技能未学							
				if  (skill.skillstatus==1) then
					s =string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你现在等级还不符合学习条件，暂时还不能学习%s!</div>",name);
				elseif (skill.skillstatus==2) then
					s =string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>%s 仅本系可学，可惜你不是这个系的!</div>",name);
				elseif (skill.skillstatus==3) then
					s =string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你的 [ %s ] 不够啊，暂时还不能学习%s!</div>",tips_gsid22000,name);
				elseif (skill.skillstatus==4) then
					if (skill.canlearnskill) then
						if (skill.canlearnskill>0) then
							local _gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(skill.canlearnskill);
							local _name = _gsItem.template.name;
							s =string.format("<div style='margin-left:15px;margin-top:20px;'>你还有低级技能 [ %s ] 未学，暂时还不能学习%s!赶快先去学 [ %s ] 吧!</div>",_name,name,_name);
						else
							s =string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你还有低级技能未学，暂时还不能学习%s!</div>",name);
						end
					else
						s =string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你还有低级技能未学，暂时还不能学习%s!</div>",name);
					end
				end
			else
				s =string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你现在还不符合学习条件，暂时还不能学习%s，好好看看还缺什么条件吧!</div>",name);
			end
		end
	end
	_guihelper.Custom_MessageBox(s,function(result)			
	end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	return
end


function CombatSkillLearn.doEquip(gsid)  -- 自动给玩家把新卡片装入战斗背包
	local MyCardsManager;
	if(System.options.version=="kids") then
		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardDeckSubPage.lua");
		MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
	else
		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardManager.teen.lua");
		MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
	end

    local gsid = tonumber(gsid);
    local cardMaxnum = MyCardsManager.singlecard_maxnum;
    local cardItem =ItemManager.GetGlobalStoreItemInMemory(gsid);	
	if (MyCardsManager.class_maxnum ~= 0 and cardItem.template.stats[136]==MyCardsManager.class_type) then
        cardMaxnum=MyCardsManager.class_maxnum;
	end	

	local include,count_combat,count_rune,thiscardNum = MyCardsManager.InCombatBag(gsid);

	--commonlib.echo("==========auto doEquip card")
	--commonlib.echo(gsid)
	--commonlib.echo(cardMaxnum)
	--commonlib.echo(hasCardNum)

	-- 如果不是魔光技能，则只放 最大数量-1 张
	-- if ((gsid<22292 or gsid>22296) and (System.options.version~="kids")) then 
	local i;
	if ((System.options.version=="kids")) then 
		cardMaxnum = cardMaxnum-1; 
		for i=thiscardNum, cardMaxnum-1 do
			MyCardsManager.DoAppend(gsid);
			commonlib.echo("==========auto doEquip card2")
			if(not MyCardsManager.CanEquip())then
				return 
			end
		end    
	else -- 青年版非白卡，只放1张
		if (gsid<22292 or gsid>22296) then 
			if (gsid>23000) then
				MyCardsManager.DoAppend(gsid);
				commonlib.echo("==========auto doEquip card2")
				if(not MyCardsManager.CanEquip())then
					return 
				end
			else --青年版白卡非魔光，放3张
				MyCardsManager.BatchAddCardsTeen(gsid,thiscardNum, cardMaxnum-2);
				--for i=thiscardNum, cardMaxnum-2 do
					--MyCardsManager.DoAppend(gsid);
					--commonlib.echo("==========auto doEquip card2")
					--commonlib.echo(thiscardNum)
					--commonlib.echo(cardMaxnum)
					--if(not MyCardsManager.CanEquip())then
						--return 
					--end
				--end  
			end
		else -- 魔光，则放最大数量-1 张（4张）	
			MyCardsManager.BatchAddCardsTeen(gsid,thiscardNum, cardMaxnum-1);		
			--for i=thiscardNum, cardMaxnum-1 do
				--MyCardsManager.DoAppend(gsid);
				--commonlib.echo("==========auto doEquip card2")
				--commonlib.echo(thiscardNum)
				--commonlib.echo(cardMaxnum)
				--if(not MyCardsManager.CanEquip())then
					--return 
				--end
			--end   
		end
	end

end

function CombatSkillLearn.ContinueLearnSkill(exID)	
	if(not exID) then return end
	local self = CombatSkillLearn;	
	local state = MyCompany.Aries.Pet.GetState();
	local index=CombatSkillLearn.index or 0;
	
	ItemManager.ExtendedCost(exID, nil, nil, function(msg) end, function(msg)
		if(msg) then
			--log("+++++++GetSkillLevel_Combat_Skill_Level return: +++++++\n")
			--commonlib.echo(msg);
			if(msg.issuccess == true) then
				self.RefreshPage();

				local skill = skills[index];
				if(not skill)then return end
				local skillname=self.GetSkillNameByLevel(skill.gsid);
				CombatSkillLearn.doEquip(skill.gsid); -- 自动给玩家把新卡片装入战斗背包
				local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>恭喜你学会了【%s】魔法卡片，快打开背包看看吧！</div>",skillname);
				_guihelper.Custom_MessageBox(s,function(result)
					if(result == _guihelper.DialogResult.Yes)then

						if(System.options.version=="kids") then
							-- 儿童版
							NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCharMainFramePage.lua");
							local CombatCharacterFrame = commonlib.gettable("MyCompany.Aries.Desktop.CombatCharacterFrame");
							if (CombatCharacterFrame) then
								--显示抱抱龙资料
								CombatCharacterFrame.ShowMainWnd(2);
								--显示学会技能的卡片背包
								NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardDeckSubPage.lua");
								local state = MyCompany.Aries.Inventory.Cards.MyCardsManager.GetPropByTemplateGsid(skill.gsid);
								MyCompany.Aries.Inventory.Cards.MyCardsManager.SetPageState(state);
								self.ClosePage();
							end

						else
							-- 青年版
							NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardManager.teen.lua");
							local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
							local state = MyCardsManager.GetPropByTemplateGsid(skill.gsid);
							MyCardsManager.SetPageState(state);
							MyCardsManager.ShowPage();		
							self.ClosePage();					
						end

					end
				end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OpenBag_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
				return
			end
		end
	end,"none");
end

--lev 1---4
function CombatSkillLearn.DoStudy(index)
	local self = CombatSkillLearn;	

	local bean = MyCompany.Aries.Pet.GetBean();

	if(System.options.version=="kids") then
		local state = MyCompany.Aries.Pet.GetState();
		--没有 跟随 或者 驾驭
		if(state == "home")then
			local s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你的抱抱龙都没过来，不能学习哦，先把他带来再说吧！</div>";
			_guihelper.Custom_MessageBox(s,function(result)
			
			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return
		end
	end

	local thisClass = true;
	local exID;
	local skill = skills[index];
	if (not skill) then return end

	if (skill.classtype ~= tonumber(classprop_gsid) and skill.classtype~=0) then
		thisClass = false;
		local pass, _, __, copies = hasGSItem(22000);
		if (skill.skilltype==1) then
			local s;
			if (pass) then
				s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>这是个选修技能，你要达到%s，并且要一个%s，找%s，努力吧！</div>",skill.needlevel,tips_gsid22000,skill.tips);
			else
				s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>这是个选修技能，你要达到%s，并且要一个%s，找%s。你没有%s啊，现在还不能学习，努力吧！</div>",skill.needlevel,tips_gsid22000,skill.tips,tips_gsid22000);
			end
			_guihelper.Custom_MessageBox(s,function(result)				
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return

		end

		if (skill.skilltype==2) then
			local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>这是个%s专有魔典技能，你不是这个系的不能获得哦，去自己系看看吧！</div>",classnm[skill.classtype]);
			_guihelper.Custom_MessageBox(s,function(result)				
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return
		end

		if(skill.learnpoints>0 and (not pass or copies<skill.learnpoints))then
			local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>学习这个技能需要到达%s，并且需要 %d 个%s，你现在还不能学习，再去修炼一下再来吧！</div>",skill.needlevel,skill.learnpoints,tips_gsid22000);
			_guihelper.Custom_MessageBox(s,function(result)				

			end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return
		end

	else
		if (skill.skilltype==1) then
			local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>这是个选修技能，学习这个技能需要找%s，快去吧！</div>",skill.tips);
			_guihelper.Custom_MessageBox(s,function(result)				
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			return
		end

		if(System.options.version=="teen") then
			if (skill.skilltype==2) then
				if (skill.tips=="召唤兽使者处兑换") then
					local npcid=31078;
					local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
					local worldname,position,camera=WorldManager:GetWorldPositionByNPC(npcid);
					position={19873.96,37.43,19915.63};
					camera = {15,0.27,3.71};
					WorldManager:GotoWorldPosition(worldname,position,camera,function()
						local self = CombatSkillLearn; 
						self.page:CloseWindow();
						local _app = Map3DSystem.App.AppManager.GetApp(MyCompany.Aries.app.app_key);
						if(_app and _app._app) then
							_app = _app._app;
							local _wnd = _app:FindWindow("ProfilePane.ShowPage") 
							if (_wnd) then
								local _wndFrame = _wnd:GetWindowFrame();
								if (_wndFrame) then
									-- close ProfilePane
									_wnd:SendMessage(nil,{type=CommonCtrl.os.MSGTYPE.WM_CLOSE});
								end
							end
						end
					end,nil,true);  
					return 
				else				
					local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>这是个魔典技能，你达到%s级，通过%s就可以获得，努力吧！</div>",skill.needlevel,skill.tips);
					_guihelper.Custom_MessageBox(s,function(result)				
						end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
					return
				end
			end
		end
	end

	local skillname = self.GetSkillNameByLevel(skill.gsid);
	local s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>你确定要学习%s魔法？",skillname);
	_guihelper.Custom_MessageBox(s,function(result)
		if(result == _guihelper.DialogResult.Yes )then
			--学习战斗技能
			if (thisClass) then
				exID=skill.exID;
			else
				exID=skill.other_exID;
			end

			local gsItem = ItemManager.GetGlobalStoreItemInMemory(skill.gsid);
			--local gsItem = ItemManager.GetGlobalStoreItemInMemory(skills[index].gsid+1000);
			CombatSkillLearn.index= index;
			--第一次学习2个魔力点以上的卡片，需要回答哈奇勇士大测验
			if( gsItem.template.stats[134] >= 2 and mentortype~=0 ) then
				MyCompany.Aries.Quest.NPCs.HaqiTrial.Show(exID);
			else
				CombatSkillLearn.ContinueLearnSkill(exID);
			end
		end
	end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/OK_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});

end

-- 儿童版自动学习本系技能
function CombatSkillLearn.KidsAutoStudy()
	CombatSkillLearn.DoInit();
	local bean = MyCompany.Aries.Pet.GetBean();
	local mylevel;
	if(bean) then
		mylevel = bean.combatlel or 0;
	end

	local LearnedID = nil;

	local myMentor = NPC_MentorID[classprop_gsid];
	local Tskills = {};
	Tskills = commonlib.deepcopy(AllSkills[myMentor]);

	local s_index;
	log("+++++++ auto Learn Skill: mylevel +++++++\n")
	--commonlib.echo("mylvl:"..mylevel);
	for s_index in ipairs(Tskills) do
		local sHas = hasGSItem(Tskills[s_index].gsid);

		-- log("+++++++ Skill: +++++++\n")
		--commonlib.echo("gsid:"..Tskills[s_index].gsid);
		--commonlib.echo(sHas);
		if (sHas) then
		else
			if (Tskills[s_index].needlevel<=mylevel and (not Tskills[s_index].notautolearn)) then
				local exID=Tskills[s_index].exID;

				log("+++++++ auto Learn Skill: +++++++\n")
				--commonlib.echo("exID:"..exID .. ",skill:"..Tskills[s_index].gsid);

				ItemManager.ExtendedCost(exID, nil, nil, function(msg) end, function(msg)
					if(msg) then
						if(msg.issuccess == true) then
							local skill = Tskills[s_index];
							if(not skill)then return end
							CombatSkillLearn.doEquip(skill.gsid); -- 自动给玩家把新卡片装入战斗背包
							if (mylevel>0) then -- 0 级以上才给予提示
								local color = "#f8f8f8";
								local tooltip = "page://script/apps/Aries/Inventory/Cards/CardsTooltip.html?gsid="..skill.gsid;
								local name_with_a = string.format(
									[[<a tooltip="%s" style="margin-left:0px;float:left;background:url()"><div style="float:left;margin-top:-2px;color:%s;">[%s]</div></a>]], 
									tooltip, color, skill.name);								
								local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
								ChatChannel.AppendChat({
											ChannelIndex = ChatChannel.EnumChannels.ItemObtain, 
											fromname = "", 
											fromschool = classprop_gsid, 
											fromisvip = false, 
											words = "你获得了新技能: "..name_with_a,
											is_direct_mcml = true,
											bHideSubject = true,
											bHideTooltip = true,
											bHideColon = true,
										});
									
								NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
								local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
								DockTip.GetInstance():PushGsid(skill.gsid, "AutoLearnSpell")

								-------------------------------------
								LearnedID = s_index;
							end
						end
					end
				end,"none");

				Tskills[s_index].skillHas=true;
				Tskills[s_index].skillCanStudy=true;
			end
		end
			
		UIAnimManager.PlayCustomAnimation(300, function(elapsedTime)
			if(elapsedTime >= 300 and LearnedID) then
				local system_looptip = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips.system_looptip");
				system_looptip.LearnedID = LearnedID;
				CombatSkillLearn.ShowPageWithTip(false)
			end
		end);
	end
	AllSkills[myMentor]=commonlib.deepcopy(Tskills);
end

-----------------
-- 青年版 获得指定等级的所有白卡（本系+辅修+平衡）
function CombatSkillLearn.GetSkills_AllWhiteCard(_lvl)
	local bean = MyCompany.Aries.Pet.GetBean();
	local mylevel;
	if(bean) then
		mylevel = bean.combatlel or 0;
	end
	local lvl=0;
	if (not lvl) then
		lvl = mylevel;
	else
		lvl=_lvl;
	end
    local ds = MyCompany.Aries.Combat.GetMyQualifiedCardGSIDsAtLevel(lvl);
	commonlib.echo("========================GetSkills_Allwhite")
	commonlib.echo(lvl)
	--commonlib.echo(ds)

    local ItemManager = System.Item.ItemManager;
    local output={}
    local count=0
	local _,_gsid;
    for _,_gsid in ipairs(ds) do
	    local _t={};
	    local gsItem = ItemManager.GetGlobalStoreItemInMemory(_gsid);
	    if(gsItem)then
		    _t={gsid=_gsid, name=gsItem.template.name,needlevel=gsItem.template.stats[138]};
		    table.insert(output,_t);
		    count=count+1
	    end
    end
	
    local tmpnode={};
	local k;
    for k=1,count-1 do
	    for j=k, count do
		    if ( output[k].needlevel > output[j].needlevel ) then
			    tmpnode = output[k];
			    output[k] = output[j];
			    output[j] = tmpnode;
		    end
	    end
    end
	return output;
end

function CombatSkillLearn.GetSkills_white_kids(SchoolId,_lvl,_shift_id)
	local _shift_gsid=0;
	if (_shift_id) then
		_shift_gsid = tonumber(_shift_id)
	end
	local output = {};
	for i = 1,#skills do
		--local _item = skills[i];
		local gsid = skills[i].gsid + _shift_gsid;
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem) then
			local item = commonlib.copy(skills[i]);
			item.gsid = gsid;
			table.insert(output,item);
		end
    end
	return output;
end

-- 青年版 获得指定系别/等级的白卡
function CombatSkillLearn.GetSkills_white(SchoolId,_lvl,_shift_id)
	if(System.options.version=="kids") then
		return CombatSkillLearn.GetSkills_white_kids(SchoolId,_lvl,_shift_id);
	end
	local SchoolId = tonumber(SchoolId)
	local bean = MyCompany.Aries.Pet.GetBean();
	local mylevel;
	if(bean) then
		mylevel = bean.combatlel or 0;
	end
	local lvl=0;
	if (not lvl) then
		lvl = mylevel;
	else
		lvl=_lvl;
	end
    local ds = MyCompany.Aries.Combat.GetQualifiedCardGSIDsBySchoolAndLevel(SchoolId, lvl);
	--commonlib.echo("========================GetSkills_white")
	--commonlib.echo(SchoolId)
	--commonlib.echo(lvl)
	--commonlib.echo(ds)

	local _shift_gsid=0;
	if (_shift_id) then
		_shift_gsid = tonumber(_shift_id)
	end
    local ItemManager = System.Item.ItemManager;
    local output={}
    local count=0
	local _,_gsid;
    for _,_gsid in ipairs(ds) do
	    local _t={};
	    local gsItem = ItemManager.GetGlobalStoreItemInMemory(_gsid);
	    if(gsItem)then
		    _t={gsid=_gsid+_shift_gsid, name=gsItem.template.name,needlevel=gsItem.template.stats[138]};
		    table.insert(output,_t);
		    count=count+1
	    end
    end
	
    local tmpnode={};
	local k;
    for k=1,count-1 do
	    for j=k, count do
		    if ( output[k].needlevel > output[j].needlevel ) then
			    tmpnode = output[k];
			    output[k] = output[j];
			    output[j] = tmpnode;
		    end
	    end
    end
	return output;
end

-- 青年版自动学习本系技能
function CombatSkillLearn.TeenAutoStudy()
	local bean = MyCompany.Aries.Pet.GetBean();
	local mylevel;
	if(bean) then
		mylevel = bean.combatlel or 0;
	end
	local SchoolId = tonumber(classprop_gsid)
	local oldLvl = System.User.oldLvl or 0;
	local Tskills_old = CombatSkillLearn.GetSkills_AllWhiteCard(oldLvl);
	log("+++++++ TeenAutoStudy old+++++++\n")
	--commonlib.echo(oldLvl)
	--commonlib.echo(Tskills_old)
	ItemManager.GetItemsInBag(24, "ariesitems_24", function(msg)
		if(msg) then
			log("+++++++ TeenAutoStudy msg+++++++\n")
			--commonlib.echo(msg)

--			if(msg.issuccess == true) then		
				local newSkills={};
				if (mylevel>0) then
					System.User.oldLvl = mylevel;
					local Tskills = {};
					local _i;
					for _i=oldLvl+1,mylevel do 
						local _Tskills = CombatSkillLearn.GetSkills_AllWhiteCard(_i) or {};
						local _index;
						for _index in ipairs(_Tskills) do
							table.insert(Tskills,_Tskills[_index]);
						end
					end
					local _index;
					for _index in ipairs(Tskills) do
						local __index;
						local _gsid = Tskills[_index].gsid;
						local find_id = false;
						for __index in ipairs(Tskills_old) do
							local __gsid = Tskills_old[__index].gsid;
							if (_gsid == __gsid) then
								find_id = true;
								break;
							end
						end
						if (not find_id) then
							table.insert(newSkills,Tskills[_index]);
						end
					end
				else
					newSkills = commonlib.deepcopy(Tskills_old);
				end

				local s_index;
				log("+++++++ TeenAutoStudy NewSKill +++++++\n")
				commonlib.echo("newlvl mylvl:"..mylevel);
				--commonlib.echo(newSkills);

				for s_index in ipairs(newSkills) do
			
					log("+++++++ auto Learn Skill: +++++++\n")

					local skill = newSkills[s_index];
					if(not skill)then return end

					--commonlib.echo(skill.gsid);

					CombatSkillLearn.doEquip(skill.gsid); -- 自动给玩家把新卡片装入战斗背包
					if (mylevel>0) then -- 0 级以上才给予提示
						local color = "#f8f8f8";
						local tooltip = "page://script/apps/Aries/Inventory/Cards/CardsTooltip.html?gsid="..skill.gsid;
						local name_with_a = string.format(
							[[<a tooltip="%s" style="margin-left:0px;float:left;background:url()"><div style="float:left;margin-top:-2px;color:%s;">[%s]</div></a>]], 
							tooltip, color, skill.name);								
						local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
						ChatChannel.AppendChat({
									ChannelIndex = ChatChannel.EnumChannels.ItemObtain, 
									fromname = "", 
									fromschool = classprop_gsid, 
									fromisvip = false, 
									words = "你获得了新技能: "..name_with_a,
									is_direct_mcml = true,
									bHideSubject = true,
									bHideTooltip = true,
									bHideColon = true,
								});
									
						NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
						local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
						DockTip.GetInstance():PushGsid(skill.gsid, "AutoLearnSpell")
					end				

				end -- for s_index
--			end -- if(msg.issuccess == true)
		end
	end, "access plus 1 minutes");
		
end
-----------------

function CombatSkillLearn.GetPageCtrl()
	local self = CombatSkillLearn;
	return self.page;
end

function CombatSkillLearn.ShowPageWithTip(bShow)
	if(System.options.version=="kids") then
		return
	else
		if (bShow) then
			local _app = Map3DSystem.App.AppManager.GetApp(MyCompany.Aries.app.app_key);
			if(_app and _app._app) then
				_app = _app._app;
				local _wnd = _app:FindWindow("CombatSkillLearn_Dialog.ShowPage") 
				if (_wnd) then
					local _wndFrame = _wnd:GetWindowFrame();
					if (_wndFrame) then
						-- close autotips
						_wnd:SendMessage(nil,{type=CommonCtrl.os.MSGTYPE.WM_CLOSE});
					end
				end
			end
		end

		local mentor=NPC_MentorID[MyCompany.Aries.Combat.GetSchoolGSID()];	
		System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/NPCs/MagicSchool/CombatSkillLearn_panel.teen.html?poptip=1&npc_id="..mentor, 
				name = "CombatSkillLearn_Dialog.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 1,
				bShow = bShow,
				allowDrag = true,
				isTopLevel = true,
				directPosition = true,
					align = "_ct",
					x = -700/2,
					y = -500/2,
					width = 700,
					height = 500,
			})

		if (bShow) then
			local ppage=CombatSkillLearn.GetPageCtrl();
			if (ppage) then
				local system_looptip = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips.system_looptip");
				local LearnedID = system_looptip.LearnedID or 1;
				local pageindex = math.ceil(LearnedID/7);
				ppage:CallMethod("skillpane", "GotoPage", pageindex);
			end
		end
	end
end

function CombatSkillLearn.GetSkill(cGsid)
	local c_skill={};
	for _npcid in pairs(AllSkills) do
	 local _skills=commonlib.deepcopy(AllSkills[_npcid]);
	 for _index in ipairs(_skills) do
		if (_skills[_index].gsid==cGsid) then
			c_skill=commonlib.deepcopy(_skills[_index]);
			break;
		end
	 end
	end
	return c_skill;
end

-- The data source for items
function CombatSkillLearn.DS_Func_SkillsDeck(dsTable, index, class,subclass,showNum,card_maxnum,page_ctrl)    
  if(not dsTable.status) then
      -- use a default cache
    if(index == nil) then
			dsTable.Count = 100;
			CombatSkillLearn.GetItems(class, subclass, "access plus 5 minutes", dsTable,showNum,card_maxnum,page_ctrl);
			return dsTable.Count;
    else
			if(index <= 100) then
				return {guid = 0};
			end
    end
  elseif(dsTable.status == 2) then
    if(index == nil) then
			return dsTable.Count;
    else
			return dsTable[index];
    end
  end 
end

function CombatSkillLearn.GetItems(class, subclass, cachepolicy, output,showNum,card_maxnum,page_ctrl)
	--默认显示6个
	showNum = showNum or 6;
	-- find the right bag for inventory items
	local bags;

	if(class == "combat") then
		CombatSkillLearn.DoInit();
		bags = {24};
	elseif(class == "rune") then
		bags = {25};
	elseif(class == "gold") then
		bags = {24};
	end
	if(bags == nil) then
		bags = {bag};
	end
	if(bags == nil) then
		-- return empty datasource table, if no bag id is specified
		output.Count = 0;
		commonlib.resize(output, output.Count)
		return;
	end
	-- fetching inventory items
	output.status = 1;

	if(class == "rune" and subclass~="all") then -- 技能百科 符文列表（非自有） all:自有
		CombatSkillLearn.RuneDoInit();
		local show_list = AllRunes[proptype[subclass]];

		local node={};
		local count = 0;

		if (show_list) then
			for _,node in ipairs(show_list) do
				local _t={};
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(node.gsid);
				if(gsItem)then
					_t={gsid=node.gsid, name=gsItem.template.name,needlevel=gsItem.template.stats[138]};
					table.insert(output,_t);
					count = count + 1;
				end
			end
		end
		local displaycount = math.ceil(count/showNum) * showNum;
		if(count == 0) then
			displaycount = showNum;
		end
		output.Count = displaycount;
		output.status = 2;
		if(page_ctrl) then
			page_ctrl:Refresh(0.1);
		end

	elseif(class == "gold" and subclass~="all") then -- 技能百科 符文列表（非自有） all:自有
		CombatSkillLearn.GoldCardDoInit();
		local show_list = AllGoldCards[proptype[subclass]];

		local node={};
		local count = 0;

		if (show_list) then
			for _,node in ipairs(show_list) do
				local _t={};
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(node.gsid);
				if(gsItem)then
					_t={gsid=node.gsid, name=gsItem.template.name,needlevel=gsItem.template.stats[138] or 0};
					table.insert(output,_t);
					count = count + 1;
				end
			end
		end
		local displaycount = math.ceil(count/showNum) * showNum;
		if(count == 0) then
			displaycount = showNum;
		end
		output.Count = displaycount;
		output.status = 2;
		if(page_ctrl) then
			page_ctrl:Refresh(0.1);
		end

	elseif (class == "pet") then   -- 技能百科 战宠技能列表
		NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetHelper.lua");
		local CombatPetHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetHelper");
		local provider = CombatPetHelper.GetClientProvider();
		local pets_map,_= provider:GetAllPets();
		local pet_cards,_cards={},{};
		local count=0;
		local mycount=0;		
		local petid;

		--commonlib.echo("==================pets_map")
		--commonlib.echo(pets_map)
		for petid in pairs(pets_map) do
			local maxlvl=pets_map[petid].max_level+1;
--			local cards=pets_map[petid].append_card_level[maxlvl];
			local cards= provider:GetTemplateMaxLevelCards(petid);
			local card_id;
			for _,card_id in ipairs(cards) do
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(card_id);
				if (gsItem) then
					local _t={gsid=card_id, name=gsItem.template.name, pet=pets_map[petid].label, petid=petid, petlvl=maxlvl};
					if (not _cards[card_id]) then
						_cards[card_id]=petid;
						pet_cards[petid]= pet_cards[petid] or {};
						table.insert(pet_cards[petid],_t);
						count = count + 1;	
					end					
				end
			end
		end

		if (subclass=="mypets") then --  自有战宠
			local nid = tostring(System.User.nid);
			
			ItemManager.LoadPetsInHomeland(nid, function(msg)
				local cnt = ItemManager.GetFollowPetCount(nid) or 0;
				local i;		
				for i = 1, cnt do
					local item = ItemManager.GetFollowPetByOrder(nid, i);
					if(item)then
						local provider = CombatPetHelper.GetClientProvider();
						local is_combat_pet = 0;
						local is_combat,isvip;
						local _cards={};
						if(provider)then
							is_combat,isvip = provider:IsCombatPet(item.gsid);
							if(is_combat)then
								_cards = commonlib.deepcopy(pet_cards[item.gsid]);
							end
						end	
						local __card;
						if (_cards) then
							for _,__card in ipairs(_cards) do
								table.insert(output,__card);
								mycount = mycount + 1;
							end
						end
					end
				end		
		--commonlib.echo("===========my pets output")
		--commonlib.echo(output)	
				output.Count = math.ceil(mycount/showNum) * showNum; 				
			end);
			
		elseif (subclass=="allpets") then -- 游戏所有战宠
			local petid;
			for petid in pairs(pet_cards) do
				if (next(pet_cards[petid])~=nil) then
					local _cards = commonlib.deepcopy(pet_cards[petid]);
					local __card;
					if (_cards) then
						for _,__card in ipairs(_cards) do
							table.insert(output,__card);
						end
					end
				end
			end
			output.Count = math.ceil(count/showNum) * showNum; 
		end
		--commonlib.echo("===========pets output")
		--commonlib.echo(output)
		output.status = 2;
		if(page_ctrl) then
			page_ctrl:Refresh(0.1);
		end

	else -- 技能百科 自有普通/符文 卡片
		bags.ReturnCount = 0;
		local _, bag;
		local prop = "";
		for _, bag in ipairs(bags) do
			ItemManager.GetItemsInBag(bag, "ariesitems_"..bag, function(msg)
				bags.ReturnCount = bags.ReturnCount + 1;
				if(bags.ReturnCount >= #bags) then
					if(msg and msg.items) then
						local count = 0;
						local combat_count = 0;
						local __, bag;
						for __, bag in ipairs(bags) do
							local i;
							for i = 1, ItemManager.GetItemCountInBag(bag) do
								local item = ItemManager.GetItemByBagAndOrder(bag, i);
								if(item ~= nil) then
									local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid)
									if(gsItem)then
										local assetkey = gsItem.assetkey or "";
										assetkey = string.lower(assetkey);
										prop = string.match(assetkey,"^%d+_(%a+)_.+") or "";
										--all metal wood water fire earth
										if(subclass == "all" or (prop == subclass))then
											--24号包排除 经验石
											if(item.gsid ~= 22000)then
												local _t={};
												if(class == "combat") then
													_t = CombatSkillLearn.GetSkill(item.gsid);
												elseif(class == "rune") then
													_t = {gsid=item.gsid, name=gsItem.template.name, needlevel=gsItem.template.stats[138] or 0 };
												elseif(class == "gold") then
													local isgold = string.lower(string.match(assetkey,".+_(%a+)$") or "");
													if (isgold=="gold") then
														_t = {gsid=item.gsid, name=gsItem.template.name, needlevel=gsItem.template.stats[138] or 0};
													end
												end;
												if (next(_t)~=nil) then
													combat_count = combat_count + 1;
													table.insert(output,_t);	
												end
											end
										end
									end
								end
							end
							count = combat_count;
						end
						--commonlib.echo("===============output");
						--commonlib.echo(output);
						local n=count;
						local j,k;
						local tempskill={};
						for j=1,n-1 do
							for k=j+1,n do
								local j_school=tonumber(output[j].classtype or 0);
								local k_school=tonumber(output[k].classtype or 0);
								if (j_school>k_school) then
									tempskill=output[j];
									output[j]=output[k];
									output[k]=tempskill;
								end
								if (j_school==k_school) then
									local j_lvl = tonumber(string.match(output[j].needlevel,"^(%d+).*") or "0");
									local k_lvl = tonumber(string.match(output[k].needlevel,"^(%d+).*") or "0");

									if (j_lvl>k_lvl) then
										tempskill=output[j];
										output[j]=output[k];
										output[k]=tempskill;
									end
								end
							end
						end
						--commonlib.echo("========output");
						--commonlib.echo(output);
						if (output[1]) then
							if (next(output[1])==nil) then
								table.remove(output,1);
							end
						end
						-- fill the 6 tiles per page
						local displaycount = math.ceil(count/showNum) * showNum;
						if(count == 0) then
							displaycount = showNum;
						end
						local i;
						output.Count = displaycount;
					end

					-- fetched inventory items
					output.status = 2;
					if(page_ctrl) then
						page_ctrl:Refresh(0.1);
					end
				end
			end, cachepolicy);
		end -- for _, bag in ipairs(bags)
	end --if(class == "rune" and subclass~="all") 
end

function CombatSkillLearn.ShowSkillEncyclopedia(zorder)
	zorder = zorder or 1;
	local params = {
	url = "script/apps/Aries/NPCs/MagicSchool/SkillEncyclopedia.teen.html", 
	name = "SkillEncyclopediaTeen", 
	app_key=MyCompany.Aries.app.app_key, 
	isShowTitleBar = false,	
	DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
	style = CommonCtrl.WindowFrame.ContainerStyle,
	zorder = zorder,
	allowDrag = true,
	enable_esc_key = true,
	directPosition = true,
		align = "_ct",
		x = -560/2,
		y = -470/2,
		width = 760,
		height = 470,
	cancelShowAnimation = true,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params)
end

function CombatSkillLearn.ShowSkillEncyclopedia_kids(zorder)
	zorder = zorder or 1;
	local params = {
	url = "script/apps/Aries/NPCs/MagicSchool/SkillEncyclopedia.kids.html", 
	name = "SkillEncyclopediaKids", 
	app_key=MyCompany.Aries.app.app_key, 
	isShowTitleBar = false,	
	DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
	style = CommonCtrl.WindowFrame.ContainerStyle,
	zorder = zorder,
	allowDrag = true,
	enable_esc_key = true,
	directPosition = true,
		align = "_ct",
		x = -560/2,
		y = -470/2,
		width = 760,
		height = 470,
	cancelShowAnimation = true,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params)
end

local SkillEncyclopedia_whiteCards={};
function CombatSkillLearn.GetSkillEncyclopedia_whiteCards(SchoolId,card_filter)	
	--commonlib.echo("========================SkillEncyclopedia_whiteCards")
	--commonlib.echo(SchoolId)
	local _shift={
		["white"]=0,
		["green"]=19000,
		["blue"]=20000,
		["purple"]=21000,
	}

	if (SchoolId=="none") then
		SkillEncyclopedia_whiteCards={};
	else
		SkillEncyclopedia_whiteCards = CombatSkillLearn.GetSkills_white(SchoolId,100,_shift[card_filter]);
	end

	--commonlib.echo(SkillEncyclopedia_whiteCards)
end

function CombatSkillLearn.DS_Func_SkillEncyclopedia_whiteCards(index)
    if(index == nil) then
		return #(SkillEncyclopedia_whiteCards);
    else
		return SkillEncyclopedia_whiteCards[index]
    end	
end