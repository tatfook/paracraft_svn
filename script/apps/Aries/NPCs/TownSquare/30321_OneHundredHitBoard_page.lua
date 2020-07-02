--[[
Title: Score page for the snow shooting game 
Author(s): LiXizhi
Date: 2009/12/21
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30321_OneHundredHitBoard_page.lua");

-- call this to submit a new score to server. 
MyCompany.Aries.Quest.NPCs.OneHundredHitBoard.SubmitScore()
-- 
MyCompany.Aries.Quest.NPCs.OneHundredHitBoard.OnHitOther();
MyCompany.Aries.Quest.NPCs.OneHundredHitBoard.OnHitByOther();
------------------------------------------------------------
]]

-- create class
local OneHundredHitBoard = commonlib.gettable("MyCompany.Aries.Quest.NPCs.OneHundredHitBoard");

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local game_name = "100_OneHunderdShoot";
local user_score = MyCompany.Aries.Player.LoadLocalData("OneHundredHitBoard.user_score", 0);
local user_high_score = MyCompany.Aries.Player.LoadLocalData("OneHundredHitBoard.user_high_score", 0);
local snow_flower_count = MyCompany.Aries.Player.LoadLocalData("OneHundredHitBoard.snow_flower_count", 0);
local hit_count = MyCompany.Aries.Player.LoadLocalData("OneHundredHitBoard.hit_count", 0);
local hitby_count = MyCompany.Aries.Player.LoadLocalData("OneHundredHitBoard.hitby_count", 0);

local last_submit_high_score = nil;
-- lowest score on the server 
local last_lowest_score = 0;
local gsid_snow_flower = 50208;


function OneHundredHitBoard.main()
end

function OneHundredHitBoard.PreDialog()
	local self = OneHundredHitBoard;
	
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	-- show the panel
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/NPCs/TownSquare/30321_OneHundredHitBoard_page.html", 
		app_key = MyCompany.Aries.app.app_key, 
		name = "30321_OneHundredHitBoard_page", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = style,
		zorder = 2,
		allowDrag = false,
		isTopLevel = true,
		directPosition = true,
			align = "_ct",
			x = -950/2,
			y = -500/2,
			width = 950,
			height = 500,
	});
	return false;
end

local page;
function OneHundredHitBoard.OnInit()
	local self = OneHundredHitBoard;
	self.page = document:GetPageCtrl();
	self.GetRank();
	
	local bOwn, _, _, copies = hasGSItem(gsid_snow_flower);
	commonlib.log("current snow flower is %d, old count is %d\n", copies or 0, snow_flower_count);
	copies = copies or 0;
	-- this ensures that snow_flower_count matches the number on the server. 
	if(snow_flower_count < copies or snow_flower_count >= (copies + 20)) then
		snow_flower_count = copies + (snow_flower_count%20) ;
		commonlib.log("corrected snow flower is %d\n", snow_flower_count);
	end
	
	if(user_score > user_high_score) then
		user_high_score = user_score;
	end
	self.page:SetValue("user_high_score", tostring(user_high_score));
	self.page:SetValue("user_score", tostring(user_score));
	self.page:SetValue("snow_flower_count", tostring(snow_flower_count));
	self.page:SetValue("hit_count", tostring(hit_count));
	self.page:SetValue("hitby_count", tostring(hitby_count));
end

function OneHundredHitBoard.DS_Func_Items(index)
	local self = OneHundredHitBoard;
	if(not self.ranks)then return nil end
	if(index == nil) then
		return #(self.ranks);
	else
		return self.ranks[index];
	end
end

-- public: submit score of the snow game. This is usually called after user has accomplished a certain achievement. 
function OneHundredHitBoard.SubmitScore()
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
	
	OneHundredHitBoard.SaveLocalData();
end

function OneHundredHitBoard.GetScore()
	return user_score;
end

-- public: call this function whenever the current player hit another player. 
-- @param times: how many times that we hit others. this is usually nil, which defaults to 1. 
function OneHundredHitBoard.OnHitOther(times)
	times = times or 1
	hit_count = hit_count + 1 * times;
	user_score = user_score + 2 * times;
	snow_flower_count = snow_flower_count + 1 * times;
	
	if(user_high_score < user_score) then
		user_high_score = user_score;
	end
	
	local new_snow_flower_count = math.floor(snow_flower_count/20) * 20;
	local _, _, _, copies = hasGSItem(gsid_snow_flower);
	if(new_snow_flower_count>0 and (not copies or new_snow_flower_count > copies) and not OneHundredHitBoard.submitting) then
		OneHundredHitBoard.submitting = true;
		commonlib.log("begin adding snow flowers %s\n", new_snow_flower_count - (copies or 0));
		
		ItemManager.PurchaseItem(gsid_snow_flower, new_snow_flower_count - (copies or 0), function(msg)
			end,
			function(msg) 
				OneHundredHitBoard.submitting = false;
				if(msg) then
					if(msg.issuccess == true) then
					end
				end
			end, nil, "none");
	end

	if(user_high_score==user_score and user_high_score > last_lowest_score and (not last_submit_high_score or (user_high_score-last_submit_high_score)>=20)) then
		-- only submit when the user score is higher than the lowest score on board and on multiple of 10. 
		OneHundredHitBoard.SubmitScore()
		OneHundredHitBoard.IsRankFetched = false;
	else
		OneHundredHitBoard.SaveLocalData()
	end
end

-- public: call this function whenever the current player is hit by another player. 
function OneHundredHitBoard.OnHitByOther()
	hitby_count = hitby_count + 1;
	if(user_score >= 1) then
		user_score = user_score - 1;
	end	
	
	OneHundredHitBoard.SaveLocalData();
end

-- save local data 
function OneHundredHitBoard.SaveLocalData()
	if(user_score > user_high_score) then
		MyCompany.Aries.Player.SaveLocalData("OneHundredHitBoard.user_high_score", user_high_score)
	end
	MyCompany.Aries.Player.SaveLocalData("OneHundredHitBoard.user_score", user_score)
	MyCompany.Aries.Player.SaveLocalData("OneHundredHitBoard.snow_flower_count", snow_flower_count)
	MyCompany.Aries.Player.SaveLocalData("OneHundredHitBoard.hit_count", hit_count)
	MyCompany.Aries.Player.SaveLocalData("OneHundredHitBoard.hitby_count", hitby_count)
end

function OneHundredHitBoard.GetRank()
	local self = OneHundredHitBoard;
	
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
		commonlib.echo("minigame OneHundredHitBoard ranks:")
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

function OneHundredHitBoard.ShowInfo(nid)
	if(not nid or nid == "")then return end
	System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
end