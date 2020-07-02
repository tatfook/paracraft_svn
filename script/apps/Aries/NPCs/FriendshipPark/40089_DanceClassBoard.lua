--[[
Title: DanceClassBoard
Author(s): LiXizhi
Date: 2009/12/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FriendshipPark/40089_DanceClassBoard.html
------------------------------------------------------------
]]

-- create class
local DanceClassBoard = commonlib.gettable("MyCompany.Aries.Quest.NPCs.DanceClassBoard");


local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

-- 9005_DidaDance
-- 9006_RobotDance
-- 9007_WindmillDance
-- 9008_TwistDance
-- 9009_RollingDance
-- 9010_ThomasDance

local ds_skills = {
    {level=1, state=1, req_pop = 0, req_skill = 0, gsid=9005, name="滴答舞"},
    {level=2, state=1, req_pop = 2, req_skill = 2, gsid=9006, name="机械舞"},
    {level=3, state=0, req_pop = 8, req_skill = 8, gsid=9007, name="风车舞"},
    {level=4, state=0, req_pop = 20, req_skill = 20, gsid=9008, name="旋转舞"},
    {level=5, state=-1, req_pop = 50, req_skill = 50, gsid=9009, name="翻腾舞"},
    {level=6, state=-1, req_pop = 150, req_skill = 150, gsid=9010, name="托马斯"},
}
local page;

-- 50231_DancerSkillPoint
local skillpoint_gsid = 50231;

function DanceClassBoard.OnInit()
	page = document:GetPageCtrl();
	
	-- update ds_skills
	local _, _, _, copies
	local _, _, _, dance_skill = hasGSItem(skillpoint_gsid);
	dance_skill = dance_skill or 0;

	-- get popularity of the player
	local popularity = 0;
	local ProfileManager = System.App.profiles.ProfileManager;
	local myInfo = ProfileManager.GetUserInfoInMemory(ProfileManager.GetNID());
	if(myInfo) then
		-- TODO: default 222 popularity before API testing
		popularity = myInfo.popularity or 222;
	end
	
	page:SetValue("popularity", tostring(popularity));
	page:SetValue("dance_skill", tostring(dance_skill));
	
	local index, skill
	local last_learnt = true;
	local tolearn_index;
	for index, skill in ipairs(ds_skills) do
		if(skill.req_pop <= popularity and skill.req_skill<=dance_skill) then
			local hasLearnt = hasGSItem(skill.gsid)
			if(hasLearnt) then
				skill.state = 1
			else
				skill.state = 0
				tolearn_index = tolearn_index or index;
			end
		else
			skill.state = -1;
			-- this ensures that we have at least one learn button on the screen. 
			if(not tolearn_index) then
				skill.state = -2;
				tolearn_index = index;
			end	
		end
	end
end

function DanceClassBoard.ClickUnlearntSkill(index)
	local skill = ds_skills[index];
	if(skill) then
		local last_skill = ds_skills[index-1]
		if(last_skill) then
			_guihelper.MessageBox(string.format([[<div style="margin-left:20px;margin-top:20px;">你%s还没学会，先学会那个再来吧！</div>]], last_skill.name));
		end
	end
end

-- learn a given skill
function DanceClassBoard.LearnSkill(index)
	local skill = ds_skills[index];
	if(skill) then
		if(skill.state == -2) then
			--_guihelper.MessageBox(string.format([[<div style="margin-left:20px;margin-top:20px;">你的人气值/熟练度还没达到学习%s的条件哦，赶紧再去努力吧！</div>]], skill.name));
			_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">你的人气值或熟练度还不够哦，赶紧再去努力吧！</div>]]);
			return
		end
		ItemManager.PurchaseItem(skill.gsid, 1, function(msg) end, function(msg)
			log("========== Purchase "..tostring(skill.gsid).." returns: ==========")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				if(index < 6) then
					local name = "";
					local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(skill.gsid);
					if(gsItem) then
						name = gsItem.template.name;
					end
					_guihelper.MessageBox(string.format([[<div style="margin-left:20px;margin-top:20px;">恭喜你学会了%s，晋升为%d级舞者，赶紧去表演给大家看看吧！</div>]], name, index));
				else
					_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">恭喜你学会了所有的舞者课程，成为绝对顶尖的超级舞者！记得把你高超的舞艺表演给大家看哦！</div>]]);
				end
			end
			
			page:Refresh();
		end);
	end	
end

function DanceClassBoard.DS_Func_DanceSkills(index)
	if(index == nil) then
        return #ds_skills;
	else
	    return ds_skills[index];
	end
end

