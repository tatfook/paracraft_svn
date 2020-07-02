--[[
Title: User score page for the home land flag challenger game
Author(s): LiXizhi
Date: 2010/1/30
Desc: This file can also be used as the NPC file for the ScoreBoard NPC, since it contains the NPC functions.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Homeland/FlagGame/UserScoreBoardPage.lua");

-- call this to submit a new score to server. 
MyCompany.Aries.Homeland.FlagGame.UserScoreBoardPage.SubmitScore()
-- 
MyCompany.Aries.Homeland.FlagGame.UserScoreBoardPage.OnTouchFlag();
------------------------------------------------------------
]]

-- create class
local UserScoreBoardPage = commonlib.gettable("MyCompany.Aries.Homeland.FlagGame.UserScoreBoardPage");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

local game_name = "100_FlagGame";
local user_score = MyCompany.Aries.Player.LoadLocalData("FlagGame.user_score", 0);
local user_high_score = MyCompany.Aries.Player.LoadLocalData("FlagGame.user_high_score", 0);

local last_submit_high_score = nil;
-- lowest score on the server 
local last_lowest_score = 0;


function UserScoreBoardPage.main()
end

function UserScoreBoardPage.PreDialog()
	local self = UserScoreBoardPage;
	
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	-- show the panel
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/Homeland/FlagGame/UserScoreBoardPage.html", 
		app_key = MyCompany.Aries.app.app_key, 
		name = "FlagGame.UserScoreBoardPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = style,
		zorder = 2,
		allowDrag = false,
		isTopLevel = true,
		directPosition = true,
			align = "_ct",
			x = -750/2,
			y = -500/2,
			width = 750,
			height = 500,
	});
	return false;
end

local page;
function UserScoreBoardPage.OnInit()
	local self = UserScoreBoardPage;
	self.page = document:GetPageCtrl();
	self.GetRank();
	
	if(user_score > user_high_score) then
		user_high_score = user_score;
	end
	self.page:SetValue("user_high_score", tostring(user_high_score));
end

function UserScoreBoardPage.DS_Func_Items(index)
	local self = UserScoreBoardPage;
	if(not self.ranks)then return nil end
	if(index == nil) then
		return #(self.ranks);
	else
		return self.ranks[index];
	end
end

-- public: submit score of the snow game. This is usually called after user has accomplished a certain achievement. 
function UserScoreBoardPage.SubmitScore()
	local msg = {
		gamename = game_name,
		--score = user_score,
		score = user_high_score,
	}
	last_submit_high_score = user_high_score;
	
	commonlib.echo("begin send minigame score:");
	commonlib.echo(msg);
	paraworld.minigame.SubmitRank(msg,"minigame",function(msg)	
		commonlib.echo("after send minigame score:");
		commonlib.echo(msg);
	end);
	
	UserScoreBoardPage.SaveLocalData();
end

function UserScoreBoardPage.GetScore()
	return user_score;
end

-- public: call this function whenever the current player hit the first flag of a home world. 
-- @param nid: nid of the homeland's owner
function UserScoreBoardPage.OnTouchFlag(nid)
	local times = 1;
	user_score = user_score + 2 * times;
	
	if(user_high_score < user_score) then
		user_high_score = user_score;
	end

	if(user_high_score==user_score and user_high_score > last_lowest_score and (not last_submit_high_score or (user_high_score-last_submit_high_score)>=10)) then
		-- only submit when the user score is higher than the lowest score on board and on multiple of 10. 
		UserScoreBoardPage.SubmitScore()
		UserScoreBoardPage.IsRankFetched = false;
	else
		UserScoreBoardPage.SaveLocalData()
	end
end

-- save local data 
function UserScoreBoardPage.SaveLocalData()
	if(user_score > user_high_score) then
		MyCompany.Aries.Player.SaveLocalData("FlagGame.user_high_score", user_high_score)
	end
	MyCompany.Aries.Player.SaveLocalData("FlagGame.user_score", user_score)
end

function UserScoreBoardPage.GetRank()
	local self = UserScoreBoardPage;
	
	local function update_rank()
		if(not self.ranks) then
			return;
		end
		local bForceSort = false;
		local _, rank
		for _, rank in ipairs(self.ranks) do
			if(rank.nid == System.User.nid and rank.score<user_high_score) then
				rank.score = user_high_score;
				bForceSort = true
				break;
			end
		end
		table.sort(self.ranks, function(left, right)
			return left.score > right.score;
		end)
	end
	if(self.IsRankFetched) then
		update_rank();
		return
	else
		self.IsRankFetched = true;
	end
	local msg = {
		gamename = game_name,
	}
	
	paraworld.minigame.GetRank(msg,"minigame",function(msg)	
		commonlib.echo("minigame FlagGame UserScoreBoardPage ranks:")
		commonlib.echo(msg);
		if(msg and msg.ranks)then
			self.ranks = msg.ranks;
			
			-- computer lowest_score
			local lowest_score = 999999999;
			local _, score 
			for _, score in ipairs(msg.ranks) do
				if(score.score and score.score<lowest_score) then
					lowest_score = score.score;
				end
			end
			last_lowest_score = lowest_score;
			
			if(#(msg.ranks) < 100) then
				last_lowest_score = 0;
			end
			
			-- this is for debuging only, fill in some data. 
			--local i; 
			--for i = 1, 10 do
				--msg.ranks[#(msg.ranks) + 1] = { nid=14861822, score=120-i }
			--end	
			
			update_rank();
			
			if(self.page)then
				self.page:Refresh();
			end
		end
	end);
end

function UserScoreBoardPage.ShowInfo(nid)
	if(not nid or nid == "")then return end
	System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
end