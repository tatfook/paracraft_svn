--[[
Title: 
Author(s): leio
Date: 2013/1/21
Desc:  

NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/MinorSkillPage.lua");
local MinorSkillPage = commonlib.gettable("MyCompany.Aries.Desktop.MinorSkillPage");
MinorSkillPage.ShowPage()
MinorSkillPage.IsIdentifier()
MinorSkillPage.GetSkill()
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local MinorSkillPage = commonlib.gettable("MyCompany.Aries.Desktop.MinorSkillPage");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function MinorSkillPage.BuildSkillsTemplate()
	if(CommonClientService.IsTeenVersion())then
		if(not MinorSkillPage.skills)then
			MinorSkillPage.skills = {
				{ gsid = 50390, exp_gsid = 50386, name = "灵魂猎人", label = "", id="hunter", tooltip="通过狩猎怪物，获得可以加工的灵魂碎片。",},
				{ gsid = 50391, exp_gsid = 50388, name = "驯灵师", label = "", id="identifier", tooltip="可以将灵魂碎片精制为灵魂精华。",},
				{ gsid = 50392, exp_gsid = 50387, name = "封印师", label = "", id="rune", tooltip="将灵魂精华加工成符印，用以强化属性。",},
				{ gsid = 50397, exp_gsid = 50398, name = "炼金师", label = "", id="medicine", tooltip="将灵魂精华加工成药剂，大幅度提升属性。",},
			};
		end
		if(not MinorSkillPage.mentor_id_map)then
			MinorSkillPage.mentor_id_map ={
				[50390] = 32110, -- 灵兽猎人
				[50391] = 32111, -- 魔法鉴定师
				[50392] = 32112, -- 魔法工匠
				["totem"] = 37113,
			}
		end
	else
		if(not MinorSkillPage.skills)then
			MinorSkillPage.skills = {
				{ gsid = 50362, exp_gsid = 50355, name = "灵兽猎人", label = "", id="hunter"},
				{ gsid = 50363, exp_gsid = 50356, name = "魔法鉴定师", label = "", id="identifier"},
				{ gsid = 50364, exp_gsid = 50357, name = "魔法工匠", label = "", id="builder"},
			};
		end
		if(not MinorSkillPage.mentor_id_map)then
			MinorSkillPage.mentor_id_map ={
				[50362] = 30533, -- 灵兽猎人
				[50363] = 30534, -- 魔法鉴定师
				[50364] = 30535, -- 魔法工匠
				["totem"] = 30536,
			}
		end
	end
end
function MinorSkillPage.ShowPage()
	MinorSkillPage.BuildSkillsTemplate();
	if(CommonClientService.IsTeenVersion()) then
		if(MyCompany.Aries.Player.GetLevel() <= 15) then
			_guihelper.MessageBox("15级以上才能学习符印生产技能哦~ <br/>快努力升级吧. 完成任务是最快的升级方式");
			return;
		end
	else
		if(MyCompany.Aries.Player.GetLevel() <= 15) then
			_guihelper.MessageBox("15级以上才能学习生活技能哦~ <br/>快努力升级吧. 完成任务是最快的升级方式");
			return;
		end
	end
	
	local url;
	local width;
	local height;
	if(CommonClientService.IsTeenVersion())then
		url = "script/apps/Aries/Desktop/CombatCharacterFrame/MinorSkillPage2.teen.html"; 
		width = 730;
		height = 480;
	else
		url = "script/apps/Aries/Desktop/CombatCharacterFrame/MinorSkillPage.window.html";
		width = 340;
		height = 400;
	end

	local params = {
		url = url, 
		app_key = MyCompany.Aries.app.app_key, 
		name = "MinorSkillPage.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		cancelShowAnimation = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		bToggleShowHide = true,
		-- zorder = 0,
		allowDrag = true,
		-- isTopLevel = true,
		enable_esc_key = true,
		directPosition = true,
			align = "_ct",
			x = -width/2,
			y = -height/2,
			width = width,
			height = height,
	}
    System.App.Commands.Call("File.MCMLWindowFrame", params);
end

-- get the skill table. if return nil, if means not selected. 
function MinorSkillPage.GetSkill()
	MinorSkillPage.BuildSkillsTemplate();
	local _, skill;
	for _, skill in ipairs(MinorSkillPage.skills) do
		local bHas = hasGSItem(skill.gsid);
		if(bHas) then
			return skill;
		end
	end
end

function MinorSkillPage.IsHunter()
	MinorSkillPage.BuildSkillsTemplate();
	local bHas = hasGSItem(MinorSkillPage.skills[1].gsid);
	return bHas;
end

function MinorSkillPage.IsIdentifier()
	MinorSkillPage.BuildSkillsTemplate();
	local bHas = hasGSItem(MinorSkillPage.skills[2].gsid);
	return bHas;
end

function MinorSkillPage.IsBuilder()
	MinorSkillPage.BuildSkillsTemplate();
	local bHas = hasGSItem(MinorSkillPage.skills[3].gsid);
	return bHas;
end



function MinorSkillPage.GotoMentor(gsid)
	if(System.options.version == "teen") then
		if(MyCompany.Aries.Player.GetLevel() <= 15) then
			_guihelper.MessageBox("15级以上才能掌握符印~ <br/>快努力升级吧. 完成任务是最快的升级方式");
			return;
		end
	else
		if(MyCompany.Aries.Player.GetLevel() <= 15) then
			_guihelper.MessageBox("15级以上才能学习生活技能哦~ <br/>快努力升级吧. 完成任务是最快的升级方式");
			return;
		end
	end

	local npc_id = MinorSkillPage.mentor_id_map[gsid or "totem"] or MinorSkillPage.mentor_id_map["totem"]
    local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
    WorldManager:GotoNPC(npc_id, function() end);
end

function MinorSkillPage.OnInit_window()
	MinorSkillPage.page_window = document:GetPageCtrl();
end
function MinorSkillPage.OnInit()
	MinorSkillPage.page = document:GetPageCtrl();
end
function MinorSkillPage.PowerExtendedCost_Handle(msg)
	if(msg)then
		local msg_data = msg.msg or {};
		local input_msg = msg.input_msg or {};
		if(msg_data.issuccess)then
			if(System.options.version == "kids")then
				_guihelper.MessageBox("恭喜你学习生活技能成功！");
			else
				_guihelper.MessageBox("恭喜你学习符印技能成功！");
			end
		else
			if(System.options.version == "kids")then
				_guihelper.MessageBox("学习生活技能失败！");
			else
				_guihelper.MessageBox("学习符印技能失败！");
			end
		end
		if(MinorSkillPage.page)then
			MinorSkillPage.page:Refresh(1);
		end
		if(MinorSkillPage.page_window)then
			MinorSkillPage.page_window:Refresh(1);
		end
	end
end
function MinorSkillPage.DS_Func_skills(index)
	if(not MinorSkillPage.skills)then return 0 end
	if(index == nil) then
		return #(MinorSkillPage.skills);
	else
		return MinorSkillPage.skills[index];
	end
end

