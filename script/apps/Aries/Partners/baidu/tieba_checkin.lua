--[[
Title: QQ login page
Author(s): LiXizhi
Date: 2012/10/25
Desc: QQ login page
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Partners/baidu/tieba_checkin.lua");
local tieba_checkin = commonlib.gettable("MyCompany.Aries.Partners.baidu.tieba_checkin");
tieba_checkin.ShowPage()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Partners/PartnerPlatforms.lua");
local Platforms = commonlib.gettable("MyCompany.Aries.Partners.Platforms");
local tieba_checkin = commonlib.gettable("MyCompany.Aries.Partners.baidu.tieba_checkin");

if(System.options.version == "kids") then
	tieba_checkin.reward_exid = 1815;
	tieba_checkin.reward_check_gsid = 50348;
else
	tieba_checkin.reward_exid = 30188;
	tieba_checkin.reward_check_gsid = 50354;
end

function tieba_checkin.OnInit()
end

function tieba_checkin.OnClosed()
end

-- @param url: the initial url to open
-- @param callback:  a callback function(result) end,  where result is a table {}. containing login result.
--  it defaults to tieba_checkin.OnProcessResultDefault
function tieba_checkin.ShowPage(url, callback)
	if(ParaEngine.GetAttributeObject():GetField("IsFullScreenMode", false)) then
		_guihelper.MessageBox("请先切换到窗口模式, 才能进行贴吧签到！");
		return;
	end
	callback = callback or tieba_checkin.OnProcessResultDefault;
	tieba_checkin.url = url;
	tieba_checkin.callback = callback;
	tieba_checkin.result = {};

	local width, height = 980, 560;
	local params = {
		url = "script/apps/Aries/Partners/baidu/tieba_checkin.html", 
		name = "baidu.tieba_checkinPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		enable_esc_key = true,
		isTopLevel = true,
		zorder = 1000,
		directPosition = true,
			align = "_ct",
			x = -width/2,
			y = -height/2,
			width = width,
			height = height,
	};
	
	System.App.Commands.Call("File.MCMLWindowFrame", params);

	params._page.OnClose = function()
		if(callback) then
			callback(tieba_checkin.result)
		end
	end
end

function tieba_checkin.IsRewardReceived()
	local ItemManager = Map3DSystem.Item.ItemManager;
    local _id = ItemManager.GetGSObtainCntInTimeSpanInMemory(tieba_checkin.reward_check_gsid);
	if(_id and _id.inday>0) then
        return true;
    else
        return false;
    end
end