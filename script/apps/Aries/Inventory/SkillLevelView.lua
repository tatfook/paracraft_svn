--[[
Title: code behind for page SkillLevelView.html
Author(s): WangTian
Date: 2010/1/22
Desc:  script/apps/Aries/Inventory/SkillLevelView.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local SkillLevelViewPage = {};
commonlib.setfield("MyCompany.Aries.Inventory.SkillLevelViewPage", SkillLevelViewPage);

-- The data source for items
function SkillLevelViewPage.DS_Func_Skills(dsTable, index, pageCtrl)      
	if(index == nil) then
		return 3;
	else
		if(index == 1) then
			return {isEmpty = false, 
				skill_url = SkillLevelViewPage.GetURL(1), 
				icon = SkillLevelViewPage.GetIcon(1),
				tooltip = SkillLevelViewPage.GetTooltip(1),
			};
		--elseif(index == 2) then
			--return {isEmpty = false, 
				--skill_url = SkillLevelViewPage.GetURL(2), 
				--icon = SkillLevelViewPage.GetIcon(2),
				--tooltip = SkillLevelViewPage.GetTooltip(2),
			--};
		elseif(index <= 3) then
			return {isEmpty = true};
		end
	end
end

function SkillLevelViewPage.GetURL(index)
	if(index == 1) then
		return "script/apps/Aries/Inventory/Skills/Architecture_Skill_Progress.html";
	--elseif(index == 2) then
		--return "script/apps/Aquarius/Profile/house.html";
	end
end

function SkillLevelViewPage.GetIcon(index)
	if(index == 1) then
		return "Texture/Aries/Inventory/Skill/Archi_Skill_icon_32bits.png";
	--elseif(index == 2) then
		--return "Texture/Aries/Inventory/Skill/Archi_Skill_icon_32bits.png";
	end
end

function SkillLevelViewPage.GetTooltip(index)
	if(index == 1) then
		return "建筑技能";
	--elseif(index == 2) then
		--return "捕捉技能";
	end
end
