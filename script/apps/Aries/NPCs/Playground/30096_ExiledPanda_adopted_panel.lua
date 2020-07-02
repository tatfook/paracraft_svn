--[[
Title: code behind for page 30096_ExiledPanda_adopted_panel.html
Author(s): LiXizhi
Date: 2010/1/4
Desc: 
Use Lib:
-------------------------------------------------------
script/apps/Aries/NPCs/Playground/30096_ExiledPanda_adopted_panel.html
-------------------------------------------------------
]]
local ExiledPanda_adopted_panel = commonlib.gettable("MyCompany.Aries.Quest.NPCs.ExiledPanda_adopted_panel");

local page;
local game_name = "100_AdoptedPandas";


function ExiledPanda_adopted_panel.OnInit()
	page = document:GetPageCtrl();
	ExiledPanda_adopted_panel.GetRank();
end

function ExiledPanda_adopted_panel.DS_Func(index)
	local self = ExiledPanda_adopted_panel;
	if(not self.ranks)then return nil end
	if(index == nil) then
		return #(self.ranks);
	else
		return self.ranks[index];
	end
end

function ExiledPanda_adopted_panel.GetRank()
	local self = ExiledPanda_adopted_panel;

	if(self.IsRankFetched) then
		return
	else
		self.IsRankFetched = true;
	end
	local msg = {
		gamename = game_name,
	}
	paraworld.minigame.GetRank(msg,"minigame",function(msg)	
		if(msg and msg.ranks)then
			self.ranks = msg.ranks;
			
			-- tricky: nid is old owner, score is nid of the new user. 
			local _, rank;
			for _, rank in ipairs(self.ranks) do 
				rank.old_nid = rank.nid
				rank.new_nid = rank.score
			end
			
			if(page)then
				page:Refresh();
			end
		end
	end);
end

function ExiledPanda_adopted_panel.ShowInfo(nid)
	nid = tostring(nid)
	if(not nid or nid == "")then return end
	System.App.Commands.Call("Profile.Aries.ShowFullProfile", {nid = nid});
end