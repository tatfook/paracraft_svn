--[[
Title: vote page
Author(s): LiXizhi
Date: 2012/11/19
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/NotificationArea/vote.lua");
local vote = commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea.vote");
vote.ShowPage("20120622", true);

local vote_date = "20121126";
if(vote.HasAnyVote(vote_date)) then
	vote.ShowPage(vote_date);
end
------------------------------------------------------------
]]
local vote = commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea.vote");

-- vote version
local default_version = "20120622";

-- @param date: like "20120622"
function vote.hasValidVote(date)
	local version = date or default_version;
    local today=ParaGlobal.GetDateFormat("yyyyMMdd");
	NPL.load("(gl)script/apps/Aries/Books/TimesMagazineWeb/TimesMagazineWeb.lua");
	local TimesMagazineWeb = commonlib.gettable("MyCompany.Aries.Books.TimesMagazineWeb");
	local allvotes = TimesMagazineWeb.LoadVote();

	local voteconf_list,vote_list,choicelist;
	local deadline;

	if(version and allvotes)then
		voteconf_list = commonlib.deepcopy(allvotes[version]);
		if(voteconf_list) then
			deadline =  voteconf_list["deadline"];		
			if (today>deadline) then
				return false
			else
				return true
			end
		end
	end
	return false
end

-- @param date: like "20120622"
function vote.HasVoted(date)
	local version = date or default_version;

	if(System.User.IsVoted) then
		return System.User.IsVoted;
	else
		local key = string.format("post_%s_%s",version,tostring(Map3DSystem.User.nid));
		local isPost = MyCompany.Aries.Player.LoadLocalData(key, false);
		System.User.IsVoted = isPost;
		return isPost;
	end
end

-- whether there is any available vote to show. 
function vote.HasAnyVote(date)
	return not vote.HasVoted(date) and vote.hasValidVote(date);
end

-- this function is called when user has summited
function vote.InvokeSuccessCallback(date)
	if(vote.callback) then
		vote.callback(date);
		vote.callback = nil;
	end
end

-- @param date: like "20120622"
-- @param IsActiveClick: if nil, we will not show unless player level is above 3. 
function vote.ShowPage(date, IsActiveClick, callback)
	local version = date or default_version;
	vote.callback = callback;

	-----------------------------
	-- temp disabled this. by Xizhi
	-----------------------------

	-- this will prevent vote to show up in level 0 cg movie. 
	if (not IsActiveClick) then
		if(MyCompany.Aries.Player.GetLevel()<3)  then
			return;
		end
	end

	local _hasVote = vote.hasValidVote(version);    
	if (not _hasVote) then
		if (IsActiveClick) then
			_guihelper.MessageBox("目前没有调查！");
		end
		return
	end

    if(vote.HasVoted(version)) then
		if (IsActiveClick) then
			_guihelper.MessageBox("本次调查你已参加过了！");
		end
		return
	end

	-- 青年版启动强制投票, always show on first start
	if (System.options.version=="kids") then
		local params = {
					url = "script/apps/Aries/Desktop/Functions/VoteTemplate.kids.html?ver="..version, 
					name = "VoteTemplate.ShowPage", 
					app_key=MyCompany.Aries.app.app_key, 
					isShowTitleBar = false,
					DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
					enable_esc_key = true,
					style = CommonCtrl.WindowFrame.ContainerStyle,
					allowDrag = true,
					zorder = 10,
					directPosition = true,
						align = "_ct",
						x = -760/2,
						y = -560/2,
						width = 760,
						height = 560,
			}
		System.App.Commands.Call("File.MCMLWindowFrame", params);	
	else
		local params = {
					url = "script/apps/Aries/Desktop/Functions/VoteTemplate.teen.html?ver="..version, 
					name = "VoteTemplate.ShowPage", 
					app_key=MyCompany.Aries.app.app_key, 
					isShowTitleBar = false,
					DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
					enable_esc_key = true,
					style = CommonCtrl.WindowFrame.ContainerStyle,
					allowDrag = true,
					zorder = 10,
					directPosition = true,
						align = "_ct",
						x = -760/2,
						y = -560/2,
						width = 760,
						height = 560,
			}
		System.App.Commands.Call("File.MCMLWindowFrame", params);	
		if(params._page and Dock.OnClose) then
			params._page.OnClose = function(bDestroy)
				Dock.OnClose("VoteTemplate.ShowPage")
			end
		end	
	end
end