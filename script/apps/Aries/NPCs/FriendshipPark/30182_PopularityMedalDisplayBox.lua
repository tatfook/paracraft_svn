--[[
Title: PopularityMedalDisplayBox
Author(s): Andy, LiXizhi
Date: 2009/12/27

use the lib:
------------------------------------------------------------
script/apps/Aries/NPCs/FriendshipPark/30182_PopularityMedalDisplayBox.lua
------------------------------------------------------------
]]

-- create class
local PopularityMedalDisplayBox = commonlib.gettable("MyCompany.Aries.Quest.NPCs.PopularityMedalDisplayBox");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function PopularityMedalDisplayBox.main()
end

function PopularityMedalDisplayBox.PreDialog()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	style.shadow_bg = "texture/bg_black_20opacity.png";
	style.fillShadowLeft = -10000;
	style.fillShadowTop = -10000;
	style.fillShadowWidth = -10000;
	style.fillShadowHeight = -10000;
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/NPCs/FriendshipPark/30182_PopularityMedalDisplayBox.html", 
		name = "Popularity_MedalDisplayBox",
		app_key = MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		style = style,
		zorder = 2,
		allowDrag = false,
		isTopLevel = true,
		directPosition = true,
			align = "_ct",
			x = -655/2,
			y = -512/2,
			width = 655,
			height = 512,
		DestroyOnClose = true,
	});
	return false;
end

-- get my popularity
function PopularityMedalDisplayBox.GetPopularity()
	-- get popularity of the player
	local popularity = 0;
	local ProfileManager = System.App.profiles.ProfileManager;
	local myInfo = ProfileManager.GetUserInfoInMemory(ProfileManager.GetNID());
	if(myInfo) then
		-- TODO: default 222 popularity before API testing
		popularity = myInfo.popularity or 222;
	end
	return popularity
end

-- 20016_AmateurClassPopularityMedal
-- 20017_ThirdClassPopularityMedal
-- 20018_SecondClassPopularityMedal
-- 20019_FirstClassPopularityMedal
local medal_ds = {
    {req_pop = 20, title="人气木徽章", gsid=20016},
    {req_pop = 100, title="人气铜徽章", gsid=20017},
    {req_pop = 600, title="人气银徽章", gsid=20018},
    {req_pop = 3000, title="人气金徽章", gsid=20019},
}

function PopularityMedalDisplayBox.DS_Func_PopMedal(index)
    if(not index) then
        return #medal_ds;
    else
        return medal_ds[index];
    end
end

local page;
function PopularityMedalDisplayBox.OnInit()
	page = document:GetPageCtrl();
end

function PopularityMedalDisplayBox.GetMedal(index)
    local medal = PopularityMedalDisplayBox.DS_Func_PopMedal(tonumber(index));
    if(medal) then
        if(medal.req_pop <= PopularityMedalDisplayBox.GetPopularity()) then
            ItemManager.PurchaseItem(medal.gsid, 1, function(msg) end, function(msg)
			    commonlib.echo(msg);
			    page:Refresh();
			    _guihelper.MessageBox(string.format([[<div style="margin-left:20px;margin-top:20px">恭喜你获得%s，你可以在资料面板中看到它哦</div>]], medal.title));
		    end);
		else
		    _guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px">你的人气值还不够呢，继续加油吧！</div>]]);
		end    
    end
end